// Editor

/*
TODO:
- Fix possible removal of ship node
- Visualize moved job entries as "changes"
- Show list of deleted job entries, direct option to undelete
- Take order of elements in <jobs> into account (e.g. ship at the end)
- Show documentation (read from XSD)
- TextDB lookup support while editing
- Keyboard cursor navigation in table (Excel style)
- "Merge" functionality for sort-of SVN-aware editing
*/

var editTableID = null;
var xmlDefDoc = null;
var textdbDoc = null;
var customTypes = null;
var customTypePreviews = null;
var theTable = null;
var filterColumns = [];
var blobURL = null;
var curEditRow = null;
var curEditCol = null;
var curEditTextInput = null;
var curEditTextArea = null;
var clickHandled = false;

var re_whitespace = /^[ \t\r\n]*$/;
var typeInputPatterns = {
    integer: "((-?[0-9]+)|(0[xX][0-9a-zA-Z]+))",
    float: "[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?"
};

function loadXMLFile(filename) {
    //var fullpath = "libraries/" + filename;
    var fullpath = filename;
    if (!window.ActiveXObject) {
        // Normal browser
        var xhttp = new XMLHttpRequest();
        xhttp.open("GET", fullpath, false);
        try {
            xhttp.send();
        } catch (e) {
            //alert(e);
            return null;
        }
        return xhttp.responseXML;
    }
    else {
        // Internet Explorer
        var xml = new ActiveXObject("MSXML2.FreeThreadedDOMDocument.6.0");
        // Add namespace prefix, in case the file is a schema
        xml.setProperty("SelectionNamespaces", "xmlns:xs='http://www.w3.org/2001/XMLSchema'");
        xml.setProperty("SelectionLanguage", "XPath");
        xml.async = false;
        try {
            xml.load(fullpath);
        } catch (e) {
            return null;
        }
        if (!xml.documentElement) {
            return null;
        }
        return xml;
    }
}

function evaluateXPath(node, expression, singleresult) {
    if (window.ActiveXObject) {
        // Internet Explorer
        if (singleresult) {
            return node.selectSingleNode(expression);
        }
        // TODO: Convert to Array?
        return node.selectNodes(expression);
    }
    else if (window.XPathEvaluator) {
        // Mozilla
        var xpe = new XPathEvaluator();
        var nsresolver = xpe.createNSResolver((node.ownerDocument == null ? node : node.ownerDocument).documentElement);
        var iterator = xpe.evaluate(expression, node, nsresolver, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null);
        if (singleresult) {
            return iterator.iterateNext();
        }
        var result = [];
        var cur;
        while ((cur = iterator.iterateNext()) != null) {
            result.push(cur);
        }
        return result;
    }
    else {
        // Unsupported
    }
}

function createChildElementWithText(parentnode, childname, textcontent) {
    var childnode = document.createElement(childname);
    childnode.textContent = textcontent;
    parentnode.appendChild(childnode);
}

function convertFormatString(textdbDoc, str) {
    if (textdbDoc) {
        var re = /\{([0-9]+)\, ?([0-9]+)\}/;
        while (true) {
            var result = re.exec(str);
            if (!result || result.length < 3) {
                return str;
            }
            var pageid = result[1];
            var textid = result[2];
            var textnode = evaluateXPath(textdbDoc.documentElement, "/language/page[@id=" + pageid + "]/t[@id=" + textid + "]/text()", true);
            var subststr = (textnode ? textnode.data : ("ReadText" + pageid + "-" + textid));
            str = str.replace(re, subststr);
        }
    }
    return str;
}

function xmlToString(node, indented) {
    var xmlstr = node.xml;
    if (!xmlstr) {
        xmlstr = (new XMLSerializer()).serializeToString(node);
    }
    if (indented) {
        xmlstr = getIndentationBeforeNode(node) + xmlstr;
    }
    return xmlstr;
}

function cloneXMLDocument(doc, root) {
    root = root || doc.documentElement;
    var xmlDoc = document.implementation.createDocument(doc.namespaceURI, root.nodeName, doc.doctype);
    var xmlRoot = xmlDoc.documentElement;
    var attribs = root.attributes;
    for (var i = 0; i < attribs.length; ++i) {
        xmlRoot.setAttribute(attribs[i].name, attribs[i].value);
    }
    var childnodes = root.childNodes;
    for (var i = 0; i < childnodes.length; ++i) {
        xmlRoot.appendChild(xmlDoc.importNode(childnodes[i], true));
    }
    return xmlDoc;
}

function importText() {
    var textdbdef = evaluateXPath(xmlDefDoc.documentElement, "/*/textdb", true);
    if (textdbdef) {
        var textdbpath = textdbdef.getAttribute("path");
        var textdbfile = textdbdef.getAttribute("file");
        if (textdbpath && textdbfile) {
            if (textdbpath.length && textdbpath[textdbpath.length - 1] != '/' && textdbpath[textdbpath.length - 1] != '\\') {
                textdbpath += '/';
            }
            textdbDoc = loadXMLFile(textdbpath + textdbfile);
        }
    }
}

function importCustomTypes() {
    var loadedfiles = {}; // Store loaded files here, so we don't import the same file twice
    customTypes = {};
    customTypePreviews = {};
    var foundnodes = evaluateXPath(xmlDefDoc.documentElement, "/*/types/import");
    for (var i = 0; i < foundnodes.length; ++i) {
        var importnode = foundnodes[i];
        var typename = importnode.getAttribute("type");
        var sourcefile = importnode.getAttribute("source");
        var selectexp = importnode.getAttribute("select");
        var fieldexp = importnode.getAttribute("field");
        var ignoreprefix = importnode.getAttribute("ignoreprefix");
        var allowpreview = importnode.getAttribute("allowpreview");
        var sorted = importnode.getAttribute("sorted");
        if (typename && sourcefile && selectexp && fieldexp) {
            var customType = [];
            customTypes[typename] = customType;
            var datalistNode = document.getElementById("type_" + typename);
            if (datalistNode) {
                while (datalistNode.firstChild) {
                    datalistNode.removeChild(datalistNode.firstChild);
                }
            }
            else {
                datalistNode = document.createElement("datalist");
                datalistNode.id = "type_" + typename;
                document.body.appendChild(datalistNode);
            }
            var customTypePreview = null;
            if (allowpreview) {
                customTypePreview = {};
                customTypePreviews[typename] = customTypePreview;
            }
            var importedxml = loadedfiles[sourcefile];
            if (!importedxml) {
                importedxml = loadXMLFile(sourcefile);
                loadedfiles[sourcefile] = importedxml;
            }
            if (importedxml) {
                var importedelements = evaluateXPath(importedxml.documentElement, selectexp);
                for (var j = 0; j < importedelements.length; ++j) {
                    var curelement = importedelements[j];
                    var xmlobj = evaluateXPath(curelement, fieldexp, true);
                    var value = xmlobj ? (xmlobj.value || xmlobj.data) : null;
                    if (value) {
                        var name = String(value);
                        if (ignoreprefix && (ignoreprefix == "1" || ignoreprefix == "true") && name.lastIndexOf(".") >= 0) {
                            name = name.substr(name.lastIndexOf(".") + 1);
                        }
                        customType.push(name);
                        if (allowpreview) {
                            customTypePreview[name] = curelement;
                        }
                        var optionNode = document.createElement("option");
                        optionNode.value = name;
                        datalistNode.appendChild(optionNode);
                    }
                }
                if (sorted && (sorted == "1" || sorted == "true")) {
                    customType.sort();
                }
            }
        }
    }
}

function importTableColumn(node, group) {
    var column = {
        name: node.getAttribute("name"),
        dummy: false,
        key: false,
        group: group,
        value: node.getAttribute("value"),
        type: node.getAttribute("type"),
        defaultval: node.getAttribute("default"),
        special: false,
        hidden: node.getAttribute("hidden") == "true",
        negate: node.getAttribute("negate") == "true",
        disablerow: node.getAttribute("disablerow") == "true",
        displayXSLT: null,
    };
    var children = node.children;
    for (var i = 0; i < children.length; ++i) {
        var child = children[i];
        if (child.nodeName == "display") {
            // construct a document node for literal result element transform
            var xslDoc = cloneXMLDocument(xmlDefDoc, child);
            // Set xsl:version="1.0"
            xslDoc.documentElement.setAttributeNS("http://www.w3.org/1999/XSL/Transform", "version", "1.0");
            // create XSLT processor and import stylesheet doc
            column.displayXSLT = new XSLTProcessor();
            column.displayXSLT.importStylesheet(xslDoc);
            break;
        }
    }
    return column;
}

function importTable(node) {
    if (!node) {
        return;
    }
    var filenode = evaluateXPath(node, "file", true);
    var schemanode = evaluateXPath(node, "schema", true);
    var keycolumnnode = evaluateXPath(node, "column[@key='true']", true);
    var keycolumn = keycolumnnode && importTableColumn(keycolumnnode);
    if (!filenode || !keycolumn) {
        return;
    }
    keycolumn.key = true;
    keycolumn.hidden = false;
    theTable = {
        id: node.getAttribute("id"),
        name: node.getAttribute("name"),
        file: filenode.getAttribute("name"),
        fileselect: filenode.getAttribute("select"),
        schema: schemanode && schemanode.getAttribute("name"),
        schemaselect: schemanode && schemanode.getAttribute("select"),
        keycolumn: keycolumn,
        columns: [ { name: "Changes", special: true } ],
    };
    theTable.xmlDoc = loadXMLFile(theTable.file);
    if (!theTable.xmlDoc || !theTable.fileselect) {
        return;
    }
    theTable.xmlSavedDoc = cloneXMLDocument(theTable.xmlDoc);
    theTable.xmlRowNodes = evaluateXPath(theTable.xmlDoc.documentElement, theTable.fileselect);
    theTable.xmlSavedRowNodes = evaluateXPath(theTable.xmlSavedDoc.documentElement, theTable.fileselect);
    var xsdDoc = theTable.schema && loadXMLFile(theTable.schema);
    if (xsdDoc) {
        theTable.xsdNode = evaluateXPath(xsdDoc.documentElement, theTable.schemaselect, true);
    }
    // Import table columns and columngroups
    var children = node.children;
    var wasgroup = false;
    for (var i = 0; i < children.length; ++i) {
        var child = children[i];
        if (child.nodeName == "column") {
            var column = (child == keycolumnnode ? keycolumn : importTableColumn(child));
            if (column) {
                if (column.disablerow) {
                    theTable.disablerowcolumn = column;
                }
                if (wasgroup) {
                    theTable.columns.push({ name: "", dummy: true });
                }
                theTable.columns.push(column);
                wasgroup = false;
            }
        }
        else if (child.nodeName == "columngroup") {
            var groupname = child.getAttribute("name");
            var groupbase = child.getAttribute("base");
            var grandchildren = child.children;
            theTable.columns.push({ name: groupname, dummy: true });
            for (var j = 0; j < grandchildren.length; ++j) {
                var grandchild = grandchildren[j];
                if (grandchild.nodeName == "column") {
                    var column = importTableColumn(grandchild, { name: groupname, base: groupbase, index: j });
                    if (column) {
                        theTable.columns.push(column);
                    }
                }
            }
            wasgroup = true;
        }
    }
    // Make sure that the last column is not hidden (it must be visible for layout purposes)
    theTable.columns[theTable.columns.length - 1].hidden = false;
    // Set proper hidden flags on dummy columns
    updateColumnGroupVisibilities();
}

function isNodeEmpty(node, ignoreattribs) {
    if (!node) {
        return false;
    }
    if (!ignoreattribs && node.attributes.length != 0) {
        return false;
    }
    if (node.firstChild) {
        var childnode = node.firstChild;
        while (childnode) {
            if (childnode.nodeType != Node.TEXT_NODE) {
                return false;
            }
            if (!re_whitespace.test(childnode.textContent)) {
                return false;
            }
            childnode = childnode.nextSibling;
        }
    }
    return true;
}

function getIndentationBeforeNode(node) {
    var prevsibling = node.previousSibling;
    if (prevsibling && prevsibling.nodeType == Node.TEXT_NODE) {
        var re_whitespace = /(^|\n)([ \t]*)[^\n]*$/;
        var result = re_whitespace.exec(prevsibling.nodeValue);
        if (result && result.length > 2) {
            return result[2];
        }
    }
    return "";
}

function insertChildWithWhitespaceBefore(parent, node, refnode) {
    if (refnode) {
        // Copy indentation whitespace from refnode
        var indent = getIndentationBeforeNode(refnode);
        // Go back to first text node before refnode
        var prevnode = refnode.previousSibling;
        while (prevnode && prevnode.nodeType == Node.TEXT_NODE) {
            refnode = prevnode;
            prevnode = prevnode.previousSibling;
        }
        parent.insertBefore(node, refnode);
        parent.insertBefore(theTable.xmlDoc.createTextNode("\n" + indent), node);
    }
    else {
        // Copy indentation whitespace from parent node, and add some (two spaces by default)
        var parentindent = getIndentationBeforeNode(parent);
        var indent = parentindent + ((parentindent.length != 0 && parentindent[parentindent.length - 1] == "\t") ? "\t" : "  ");
        parent.appendChild(theTable.xmlDoc.createTextNode("\n" + indent));
        parent.appendChild(node);
        parent.appendChild(theTable.xmlDoc.createTextNode("\n" + parentindent));
    }
}

function insertChildWithWhitespaceAfter(parent, node, refnode) {
    // Copy indentation whitespace from refnode
    var indent = getIndentationBeforeNode(refnode);
    var indentnode = theTable.xmlDoc.createTextNode("\n" + indent);
    var nextnode = refnode.nextSibling;
    if (nextnode) {
        // old order: refnode, nextnode
        parent.insertBefore(node, nextnode);
        parent.insertBefore(indentnode, node);
        // new order: refnode, indentnode, node, nextnode
    }
    else {
        parent.appendChild(indentnode);
        parent.appendChild(node);
    }
}

function removeChildWithWhitespace(parent, node) {
    // Remove indentation before childnode
    var prevsibling = node.previousSibling;
    if (prevsibling && prevsibling.nodeType == Node.TEXT_NODE) {
        prevsibling.textContent = prevsibling.textContent.replace(/[ \t]*$/, "");
        if (prevsibling.textContent == "") {
            parent.removeChild(prevsibling);
        }
    }
    // Remove line break after childnode
    var nextsibling = node.nextSibling;
    if (nextsibling && nextsibling.nodeType == Node.TEXT_NODE) {
        nextsibling.textContent = nextsibling.textContent.replace(/^[ \t]*\r?\n/, "");
    }
    // Remove actual node
    parent.removeChild(node);
    // If only whitespace is left, remove all text nodes
    if (isNodeEmpty(parent, true)) {
        while (parent.firstChild) {
            parent.removeChild(parent.firstChild);
        }
    }
}

function isTableDirty() {
    var domTable = document.getElementById("mainTable");
    var domRow = domTable.tBodies[0].firstChild;
    while (domRow) {
        if (domRow.firstChild.className == "dirty") {
            return true;
        }
        domRow = domRow.nextSibling;
    }
    return false;
}

function setDirtyState(cell, rownode, column) {
    if (!column.dummy) {
        if (hasCellValueChanged(rownode, column)) {
            cell.className = "dirty";
            cell.parentNode.firstChild.className = "dirty";
        }
        else if (cell.className != "") {
            cell.className = "";
            var firstcell = cell.parentNode.firstChild;
            var curcell = firstcell.nextSibling;
            var dirty = false;
            while (curcell) {
                if (curcell.className == "dirty") {
                    dirty = true;
                    break;
                }
                curcell = curcell.nextSibling;
            }
            // No more dirty cells
            firstcell.className = dirty ? "dirty" : "";
        }
        if (column.key) {
            // Changing the key can affect all cells in the row!
            // Skip firstChild, which summarises the dirty states
            for (var i = 1; i < theTable.columns.length; ++i) {
                var column = theTable.columns[i];
                if (!column.isdummy && !column.key) {   // prevent further recursion!
                    setDirtyState(cell.parentNode.children[i], rownode, column);
                }
            }
        }
    }
}

function appendDOMElement(parentnode, tagname, properties) {
    var node = document.createElement(tagname);
    if (properties) {
        for (var property in properties) {
            if (properties.hasOwnProperty(property)) {
                if (property == "onclick") {
                    setOnClick(node, properties[property]);
                }
                else if (property == "style") {
                    var styleproperties = properties[property];
                    for (var styleproperty in styleproperties) {
                        if (styleproperties.hasOwnProperty(styleproperty)) {
                            node.style[styleproperty] = styleproperties[styleproperty];
                        }
                    }
                }
                else {
                    node[property] = properties[property];
                }
            }
        }
    }
    parentnode.appendChild(node);
    return node;
}

function setFocusAndSelect(inputfield) {
    inputfield.focus();
    inputfield.setSelectionRange(0 /*inputfield.value.length*/, inputfield.value.length);
}

function setOnClick(node, func, checkresult) {
    if (node == document) {
        // onclick handler in DOM tree root, which is called last: reset clickHandled for next click
        node.onclick = function (e) {
            e = e || window.event;
            if (e.button == 0) {
                if (!clickHandled && func) {
                    func();
                }
                clickHandled = false;
            }
        }
    }
    else if (func) {
        node.onclick = function (e) {
            e = e || window.event;
            if (e.button == 0) {
                if (!clickHandled) {
                    // if checkresult is false, set clickHandled to true anyway
                    clickHandled = func() || !checkresult;
                }
            }
        }
    }
    else {
        node.onclick = null;
    }
}

function addRowFilter(column) {
    if (!column.dummy && !column.special && (column.type == "boolean" || isSimpleTextColumnType(column.type))) {
        document.getElementById("pFilters").style.display = "";
        var domFilterTable = document.getElementById("filterTable");
        var filterrow = document.createElement("tr");
        var inputfield = null;
        // Column name cell
        if (column.group) {
            createChildElementWithText(filterrow, "td", column.group.name + ": " + column.name);
        }
        else {
            createChildElementWithText(filterrow, "td", column.name);
        }
        // Comparison type cell
        var comparetypecell = document.createElement("td");
        var dropdown = document.createElement("select");
        dropdown.size = 1;
        createChildElementWithText(dropdown, "option", "(select)");
        if (column.type == "boolean") {
            createChildElementWithText(dropdown, "option", "is true");
            createChildElementWithText(dropdown, "option", "is false");
        }
        else if (column.type == "integer" || column.type == "float") {
            createChildElementWithText(dropdown, "option", "==");
            createChildElementWithText(dropdown, "option", "!=");
            createChildElementWithText(dropdown, "option", "<");
            createChildElementWithText(dropdown, "option", ">");
            createChildElementWithText(dropdown, "option", "<=");
            createChildElementWithText(dropdown, "option", ">=");
        }
        else {
            createChildElementWithText(dropdown, "option", "is");
            createChildElementWithText(dropdown, "option", "isn't");
            createChildElementWithText(dropdown, "option", "contains");
            createChildElementWithText(dropdown, "option", "doesn't contain");
            createChildElementWithText(dropdown, "option", "begins with");
        }
        createChildElementWithText(dropdown, "option", "changed");
        createChildElementWithText(dropdown, "option", "unchanged");
        dropdown.onchange = function () {
            onRowFilterChanged();
            if (inputfield) {
                inputfield.disabled = (dropdown.value == "changed" || dropdown.value == "unchanged");
            }
        }
        comparetypecell.appendChild(dropdown);
        filterrow.appendChild(comparetypecell);
        // Comparison value cell
        var comparevaluecell = document.createElement("td");
        if (column.type != "boolean") {
            inputfield = document.createElement("input");
            inputfield.type = "text";
            if (column.type == "integer" || column.type == "float") {
                inputfield.placeholder = "(0)";
            }
            else {
                inputfield.placeholder = "(empty)";
            }
            if (customTypes[column.type]) {
                // associate inputfield with HTML5 datalist (NOTE: .list property doesn't work)
                inputfield.setAttribute("list", "type_" + column.type);
            }
            //if (typeInputPatterns[column.type]) {
            //	inputfield.pattern = typeInputPatterns[column.type];
            //}
            inputfield.oninput = onRowFilterChanged;
            comparevaluecell.appendChild(inputfield);
        }
        filterrow.appendChild(comparevaluecell);
        // X button cell
        var buttoncell = document.createElement("td");
        var cancelbutton = document.createElement("button");
        cancelbutton.type = "button";
        cancelbutton.textContent = "X";
        setOnClick(cancelbutton, function () {
            finishEditMode();
            removeRowFilter(filterrow);
            onRowFilterChanged();
        });
        buttoncell.appendChild(cancelbutton);
        filterrow.appendChild(buttoncell);
        domFilterTable.appendChild(filterrow);
        filterColumns.push(column);
        onRowFilterChanged();
    }
}

function removeRowFilter(filterrow) {
    var domFilterTable = filterrow.parentNode;
    var filteridx = Array.prototype.indexOf.call(domFilterTable.children, filterrow);
    if (filteridx >= 0) {
        filterColumns.splice(filteridx, 1);
        domFilterTable.removeChild(filterrow);
        if (!domFilterTable.firstChild) {
            // Last filter removed, hide filter section
            document.getElementById("pFilters").style.display = "none";
        }
        onRowFilterChanged();
    }
}

function checkRowFilter(filterrow, rownode, column) {
    var comparedropdown = filterrow.children[1].firstChild;
    if (comparedropdown.selectedIndex == 0) {
        // nothing selected yet
        return true;
    }
    var comparetype = comparedropdown.value;
    if (comparetype == "changed") {
        return hasCellValueChanged(rownode, column);
    }
    if (comparetype == "unchanged") {
        return !hasCellValueChanged(rownode, column);
    }
    var content = getCellXMLContent(rownode, column);
    if (column.negate) {
        content = !content;
    }
    if (comparetype == "is true")           { return content; }
    if (comparetype == "is false")          { return !content; }

    if (!content) {
        content = "";
    }
    var comparevalue = filterrow.children[2].firstChild.value;
    if (comparetype == "is")                { return content == comparevalue; }
    if (comparetype == "isn't")             { return content != comparevalue; }
    if (comparetype == "contains")          { return content.indexOf(comparevalue) >= 0; }
    if (comparetype == "doesn't contain")   { return content.indexOf(comparevalue) < 0; }
    if (comparetype == "begins with")       { return content.indexOf(comparevalue) == 0; }

    var fcontent = parseFloat(content != "" ? content : 0);
    var fcomparevalue = parseFloat(comparevalue ? comparevalue : 0);
    if (comparetype == "==")                { return fcontent == fcomparevalue; }
    if (comparetype == "!=")                { return fcontent != fcomparevalue; }
    if (comparetype == "<")                 { return fcontent < fcomparevalue; }
    if (comparetype == ">")                 { return fcontent > fcomparevalue; }
    if (comparetype == "<=")                { return fcontent <= fcomparevalue; }
    if (comparetype == ">=")                { return fcontent >= fcomparevalue; }

    return true;
}

function applyRowFilters(rownode) {
    var domFilterTable = document.getElementById("filterTable");
    var filterrows = domFilterTable.children;
    var visible = true;
    for (var i = 0; i < filterrows.length; ++i) {
        var filterrow = filterrows[i];
        var column = filterColumns[i];
        if (!checkRowFilter(filterrow, rownode, column)) {
            visible = false;
        }
    }
    var rowidx = theTable.xmlRowNodes.indexOf(rownode);
    if (rowidx >= 0) {
        var domRow = document.getElementById("mainTable").tBodies[0].children[rowidx];
        if (visible) {
            domRow.style.display = "";
        }
        else {
            domRow.style.display = "none";
        }
    }
}

function onRowFilterChanged() {
    for (var i = 0; i < theTable.xmlRowNodes.length; ++i) {
        applyRowFilters(theTable.xmlRowNodes[i]);
    }
}

function isSimpleTextColumnType(type) {
    if (!type || customTypes[type] || type == "text" || type == "integer" || type == "float") {
        return true;
    }
    return false;
}

function onBoolCheckboxClicked(cell, rownode, column, value) {
    changeCellXMLContentAttribute(rownode, column, value ? "true" : "false");
    if (column.disablerow) {
        cell.parentNode.className = (value ? "disabled" : "");
    }
    applyRowFilters(rownode);
    setDirtyState(cell, rownode, column);
}

function changeCellXMLContentElement(rownode, column, newnode) {
    if (column.dummy || !column.value) {
        return false;
    }
    var xpath = "";
    if (column.group && column.group.base && column.group.base.length > 0) {
        xpath = column.group.base;
        if (xpath[xpath.length - 1] != "/") {
            xpath += "/";
        }
    }
    xpath += column.value;
    var re_xpath = /^(([a-z0-9_-]+)\/)*([a-z0-9_-]+)$/;
    if (!re_xpath.test(xpath)) {
        return false;
    }
    var allowed = true;
    var oldnode = getCellXMLObject(rownode, column);
    if (oldnode) {
        // Element already exists
        if (newnode) {
            if (newnode.nodeName != oldnode.nodeName) {
                return false;
            }
            oldnode.parentNode.replaceChild(newnode, oldnode);
        }
        else {
            // Remove node and clean up empty nodes if possible.
            var curnode = oldnode;
            while (curnode != rownode && curnode.parentNode != null && (curnode == oldnode || isNodeEmpty(curnode))) {
                var childnode = curnode;
                curnode = curnode.parentNode;
                removeChildWithWhitespace(curnode, childnode);
            }
        }
    }
    else if (newnode != null) {
        // Element doesn't exist, we have to create it now. We may also have to create parent nodes first.
        var result = re_xpath.exec(xpath);
        var curnode = rownode;
        while (result && result.length >= 4) {
            if (result[3] != newnode.nodeName) {
                return false;
            }
            var nextnodename = result[2];
            var nextnode = evaluateXPath(curnode, nextnodename, true);
            if (!nextnode) {
                if (nextnodename) {
                    nextnode = theTable.xmlDoc.createElement(nextnodename);
                }
                else {
                    nextnode = newnode;
                }
                // Insert node at the top
                var firstelement = null;
                if (curnode.firstChild) {
                    var childnode = curnode.firstChild;
                    while (childnode) {
                        if (childnode.nodeType == Node.ELEMENT_NODE) {
                            firstelement = childnode;
                            break;
                        }
                        childnode = childnode.nextSibling;
                    }
                }
                // Insert before firstelement if found
                insertChildWithWhitespaceBefore(curnode, nextnode, firstelement);
                if (nextnode == newnode) {
                    break;
                }
            }
            curnode = nextnode;
            xpath = xpath.substr(nextnodename.length + 1);
            result = re_xpath.exec(xpath);
        }
    }
    return true;
}

function changeCellXMLContentAttribute(rownode, column, newvalue, checkonly) {
    // NOTE: rownode can be null if checkonly is true
    // First validate that the XPath expression specifies an attribute and that there are no conditions
    // (otherwise to change the content we may have to parse the expression manually)
    if (column.dummy || !column.value) {
        return false;
    }
    var xpath = "";
    if (column.group && column.group.base && column.group.base.length > 0) {
        xpath = column.group.base;
        if (xpath[xpath.length - 1] != "/") {
            xpath += "/";
        }
    }
    xpath += column.value;
    var re_xpath = /^(([a-z0-9_-]+)\/([a-z0-9_-]+\/)*)?@([a-z0-9_-]+)$/;
    if (!re_xpath.test(xpath)) {
        return false;
    }
    var defaultvalue = (column.defaultval != null ? column.defaultval : (column.type == "boolean" ? "false" : ""));
    var allowed = true;
    if (column.key) {
        // Special rules for key cell
        var re_validkey = /^[a-z0-9._-]+$/;
        if (newvalue == defaultvalue || !re_validkey.test(newvalue)) {
            if (!checkonly) {
                alert("Invalid " + column.name + " value: '" + newvalue + "'");
            }
            return false;
        }
        for (var i = 0; i < theTable.xmlRowNodes.length; ++i) {
            if (theTable.xmlRowNodes[i] != rownode && getCellXMLContent(theTable.xmlRowNodes[i], column) == newvalue) {
                if (!checkonly) {
                    alert(column.name + " value '" + newvalue + "' already exists");
                }
                return false;
            }
        }
    }
    if (!checkonly) {
        var xmlobj = getCellXMLObject(rownode, column);
        if (xmlobj) {
            // Value already exists
            if (newvalue != defaultvalue) {
                // Write non-default value
                xmlobj.value = newvalue;
            }
            else {
                // New value is default value: Remove attribute and clean up empty nodes if possible.
                var curnode = rownode;
                if (xpath.lastIndexOf("/") >= 0) {
                    // We can't get the parent of the attribute easily
                    curnode = evaluateXPath(rownode, xpath.substr(0, xpath.lastIndexOf("/")), true);
                }
                curnode.removeAttribute(xmlobj.name);
                while (curnode != rownode && curnode.parentNode != null && isNodeEmpty(curnode)) {
                    var childnode = curnode;
                    curnode = curnode.parentNode;
                    removeChildWithWhitespace(curnode, childnode);
                }
            }
        }
        else if (newvalue != defaultvalue) {
            // Attribute doesn't exist, we have to create it now. We may also have to create element nodes first.
            var result = re_xpath.exec(xpath);
            var curnode = rownode;
            while (result && result.length >= 4) {
                var nextnodename = result[2];
                if (!nextnodename) {
                    var attrname = result[4];
                    curnode.setAttribute(attrname, newvalue);
                    break;
                }
                var nextnode = evaluateXPath(curnode, nextnodename, true);
                if (!nextnode) {
                    // Node doesn't exist yet, create and insert at the top
                    nextnode = theTable.xmlDoc.createElement(nextnodename);
                    var firstelement = null;
                    if (curnode.firstChild) {
                        var childnode = curnode.firstChild;
                        while (childnode) {
                            if (childnode.nodeType == Node.ELEMENT_NODE) {
                                firstelement = childnode;
                                break;
                            }
                            childnode = childnode.nextSibling;
                        }
                    }
                    // Insert before firstelement if found
                    insertChildWithWhitespaceBefore(curnode, nextnode, firstelement);
                }
                curnode = nextnode;
                xpath = xpath.substr(nextnodename.length + 1);
                result = re_xpath.exec(xpath);
            }
        }
        if (column.key) {
            // If changing the key to a key that already exists in the saved XML, we can use that one for comparison with the saved version.
            var savedrownode = evaluateXPath(theTable.xmlSavedDoc.documentElement, "(" + theTable.fileselect + ")[" + column.value + "='" + newvalue + "']", true);
            if (savedrownode) {
                var rowidx = theTable.xmlRowNodes.indexOf(rownode);
                var savedrowidx = theTable.xmlSavedRowNodes.indexOf(savedrownode);
                if (rowidx >= 0 && rowidx != savedrowidx) {
                    if (savedrowidx >= 0) {
                        // A rownode is aleady associated with the saved rownode (but the key has been renamed), remove the association
                        theTable.xmlSavedRowNodes[savedrowidx] = null;
                        // Flag the whole row as dirty after removing association (i.e. it's now considered as a row that didn't exist in saved version before)
                        setDirtyState(getCell(theTable.xmlRowNodes[savedrowidx], column), theTable.xmlRowNodes[savedrowidx], column);
                    }
                    // Renamed row is now recognised as one from the saved version
                    theTable.xmlSavedRowNodes[rowidx] = savedrownode;
                }
            }
        }
    }
    return true;
}

function getCell(rownode, column) {
    var rowidx = theTable.xmlRowNodes.indexOf(rownode);
    var colidx = theTable.columns.indexOf(column);
    if (rowidx >= 0 && colidx >= 0) {
        var domTable = document.getElementById("mainTable");
        return domTable.tBodies[0].children[rowidx].children[colidx];
    }
    return null;
}

function getCellXMLObject(rownode, column) {
    var basenode = rownode;
    if (column.group && column.group.base) {
        var groupbasenode = evaluateXPath(rownode, column.group.base, true);
        if (groupbasenode) {
            basenode = groupbasenode;
        }
    }
    return evaluateXPath(basenode, column.value, true);
}

function getCellXMLContent(rownode, column) {
    var xmlobj = getCellXMLObject(rownode, column);
    if (xmlobj && xmlobj.nodeType == Node.ELEMENT_NODE) {
        return xmlToString(xmlobj, true);
    }
    var value = xmlobj ? (xmlobj.value || xmlobj.data) : null;
    if (column.type == "boolean") {
        var valstr = value || column.defaultval;
        return (valstr == "true" || valstr == "1");
    }
    return value;
}

function getSavedRowNode(rownode) {
    var rowidx = theTable.xmlRowNodes.indexOf(rownode);
    if (rowidx >= 0 && rowidx < theTable.xmlSavedRowNodes.length) {
        return theTable.xmlSavedRowNodes[rowidx];
    }
    return null;
}

function hasCellValueChanged(rownode, column) {
    var savedrownode = getSavedRowNode(rownode);
    if (savedrownode) {
        var content = getCellXMLContent(rownode, column);
        var savedcontent = getCellXMLContent(savedrownode, column);
        if (content == savedcontent) {
            return false;
        }
    }
    return true;
}

function onCellClicked(cell, rownode, column) {
    if (curEditRow) {
        // we are in edit mode: If user clicked on currently edited cell, eat the event
        if (curEditRow == rownode && curEditCol == column) {
            return true;
        }
    }
    else if (!column.dummy && !column.special && column.type != "boolean") {
        // entering edit mode
        curEditRow = rownode;
        curEditCol = column;
        writeCellContent(cell, cell.firstChild, rownode, column);
        var domTable = document.getElementById("mainTable");
        domTable.tBodies[0].className = "edit";
        cell.parentNode.className += " edit";           // keep possible "disabled" class
        cell.className = "edit";
        return true;
    }
    return false;
}

function parseXMLNode(xmldoc, xmlstr, ignoreerror) {
    var parser = new DOMParser();
    var tmpdoc;
    try {
        tmpdoc = parser.parseFromString(xmlstr, "text/xml");
        // https://bugzilla.mozilla.org/show_bug.cgi?id=45566
        if (tmpdoc.documentElement.nodeName == "parsererror") {
            throw tmpdoc.documentElement.firstChild.textContent;
        }
    } catch (e) {
        if (!ignoreerror) {
            alert(e);
        }
        return null;
    }
    var node = xmldoc.importNode(tmpdoc.documentElement, true);
    return node;
}

function replaceRowWithXMLChanges(rownode, column, xmlstr) {
    var newrownode = null;
    var previouskeyvalue = null;
    // The XML element specified by column gets replaced by xmlstr
    if (column.key) {
        previouskeyvalue = getCellXMLContent(rownode, column);
        // Regarding XML, the key column represents the whole row node, no just the key
        newrownode = parseXMLNode(theTable.xmlDoc, xmlstr);
        if (!newrownode) {
            return false;
        }
    }
    else {
        // Not the key: Just replace a sub-node (add/remove is also possible, xmlstr may be empty).
        // Even though the rownode itself doesn't have to change, we replace it with a clone anyway
        // so it gets validated properly.
        var newnode = null;
        if (xmlstr && !re_whitespace.test(xmlstr)) {
            newnode = parseXMLNode(theTable.xmlDoc, xmlstr);
            if (!newnode) {
                return false;
            }
        }
        newrownode = rownode.cloneNode(true);
        if (!changeCellXMLContentElement(newrownode, column, newnode)) {
            alert("Cannot insert XML element, possibly incorrect tag name.\nXPath: '" + column.value + "'");
            return false;
        }
    }
    var rowidx = theTable.xmlRowNodes.indexOf(rownode);
    var parent = rownode.parentNode;
    // For testing if the changed node is legal according to the row XPath, replace rownode temporarily and find it
    parent.replaceChild(newrownode, rownode);
    var testrownodes = evaluateXPath(theTable.xmlDoc.documentElement, theTable.fileselect);
    parent.replaceChild(rownode, newrownode);
    if (testrownodes.indexOf(newrownode) < 0) {
        alert("The XML element does not meet the table row requirements.\nXPath: '" + theTable.fileselect + "'");
        return false;
    }
    // Exit edit mode while we are in a stable state!
    exitEditMode();
    // Now replace rownode for real
    parent.replaceChild(newrownode, rownode);
    theTable.xmlRowNodes = evaluateXPath(theTable.xmlDoc.documentElement, theTable.fileselect);
    if (column.key) {
        // Check if the new key provided in XML is actually allowed
        if (!changeCellXMLContentAttribute(newrownode, column, getCellXMLContent(newrownode, column) || "")) {
            // Not allowed, and we have already shown an alert message. Revert to previous value, which should be safe.
            changeCellXMLContentAttribute(newrownode, column, previouskeyvalue);
        }
    }
    // We have to rebuild the table row because the old row still has event handlers that refer to the old rownode
    //buildTable();
    var domRow = document.createElement("tr");
    buildTableRow(domRow, newrownode);
    var tbody = document.getElementById("mainTable").tBodies[0];
    tbody.replaceChild(domRow, tbody.children[rowidx]);
    applyRowFilters(newrownode);
    return true;
}

function applyEditChanges() {
    if (!curEditRow || !curEditCol) {
        return false;
    }
    if (curEditTextArea) {
        if (!replaceRowWithXMLChanges(curEditRow, curEditCol, curEditTextArea.value)) {
            return false;
        }
        // NOTE: We have already exited edit mode at this point
    }
    if (curEditTextInput) {
        if (!changeCellXMLContentAttribute(curEditRow, curEditCol, curEditTextInput.value)) {
            return false;
        }
        applyRowFilters(curEditRow);
        return true;
    }
    // TODO
    return true;
}

function exitEditMode() {
    if (curEditRow && curEditCol) {
        // We are in edit mode. To leave it, clear curEditRow/Col as early as possible
        var editrow = curEditRow;
        var editcol = curEditCol;
        var editcell = getCell(editrow, editcol);
        curEditRow = null;
        curEditCol = null;
        curEditTextInput = null;
        curEditTextArea = null;
        var domTable = document.getElementById("mainTable");
        domTable.tBodies[0].className = "view";
        editcell.parentNode.className = ((theTable.disablerowcolumn && getCellXMLContent(editrow, theTable.disablerowcolumn)) ? "disabled" : "");
        writeCellContent(editcell, editcell.firstChild, editrow, editcol);
        setDirtyState(editcell, editrow, editcol);
    }
}

function finishEditMode() {
    if (applyEditChanges()) {
        exitEditMode();
        return true;
    }
    return false;
}

function moveRow(cell, rownode, direction) {
    if (direction != -1 && direction != 1) {
        return;
    }
    var rowidx = theTable.xmlRowNodes.indexOf(rownode);
    if (rowidx < 0 || rowidx + direction < 0 || rowidx + direction >= theTable.xmlRowNodes.length) {
        return;
    }
    var parentnode = rownode.parentNode;
    removeChildWithWhitespace(parentnode, rownode);
    theTable.xmlRowNodes.splice(rowidx, 1);
    if (rowidx + direction == 0) {
        insertChildWithWhitespaceBefore(parentnode, rownode, theTable.xmlRowNodes[rowidx + direction]);
    }
    else {
        insertChildWithWhitespaceAfter(parentnode, rownode, theTable.xmlRowNodes[rowidx + direction - 1]);
    }
    theTable.xmlRowNodes = evaluateXPath(theTable.xmlDoc.documentElement, theTable.fileselect);
    var savedrownode = theTable.xmlSavedRowNodes[rowidx];
    theTable.xmlSavedRowNodes.splice(rowidx, 1);
    theTable.xmlSavedRowNodes.splice(rowidx + direction, 0, savedrownode);
    var tbody = document.getElementById("mainTable").tBodies[0];
    var tr = tbody.children[rowidx];
    tbody.removeChild(tr);
    tbody.insertBefore(tr, tbody.children[rowidx + direction]);
    if (window.scrollBy) {
        window.scrollBy(0, tbody.children[rowidx].scrollHeight * direction);
    }
}

function copyEditedRow() {
    if (!curEditRow || !curEditCol || !curEditCol.key) {
        return;
    }
    var rownode = curEditRow;
    var keycolumn = curEditCol;
    exitEditMode();
    // Automatically find a unique key value for the copy
    var basecopykeyvalue = getCellXMLContent(rownode, keycolumn) + "_copy";
    var copykeyvalue = basecopykeyvalue;
    var counter = 1;
    while (!changeCellXMLContentAttribute(null, keycolumn, copykeyvalue, true)) {
        ++counter;
        copykeyvalue = basecopykeyvalue + counter;
    }
    var copyrownode = rownode.cloneNode(true);
    var rowidx = theTable.xmlRowNodes.indexOf(rownode);
    insertChildWithWhitespaceAfter(rownode.parentNode, copyrownode, rownode);
    theTable.xmlRowNodes = evaluateXPath(theTable.xmlDoc.documentElement, theTable.fileselect);
    theTable.xmlSavedRowNodes.splice(rowidx + 1, 0, null);		// insert null in saved XML content at same index
    changeCellXMLContentAttribute(copyrownode, keycolumn, copykeyvalue);
    //buildTable();
    var domRow = document.createElement("tr");
    buildTableRow(domRow, copyrownode);
    var tbody = document.getElementById("mainTable").tBodies[0];
    tbody.insertBefore(domRow, tbody.children[rowidx + 1]);
    applyRowFilters(copyrownode);
}

function deleteRow(cell, rownode) {
    if (!window.confirm("Delete row: This action cannot be undone. Are you sure you want to continue?")) {
        return;
    }
    exitEditMode();
    var rowidx = theTable.xmlRowNodes.indexOf(rownode);
    removeChildWithWhitespace(rownode.parentNode, rownode);
    theTable.xmlRowNodes = evaluateXPath(theTable.xmlDoc.documentElement, theTable.fileselect);
    theTable.xmlSavedRowNodes.splice(rowidx, 1);
    //buildTable();
    cell.parentNode.parentNode.removeChild(cell.parentNode);
}

function createRowEditOptions(cell, form, rownode) {
    var buttontable = document.createElement("table");
    var textarea = null;
    buttontable.className = "textinput";
    var buttonrow = appendDOMElement(buttontable, "tr");
    var buttoncell = appendDOMElement(buttonrow, "td", { className: "buttons" });
    appendDOMElement(buttoncell, "button", { type: "button", textContent: "Edit XML", onclick: function () {
        if (!textarea) {
            var savedrownode = getSavedRowNode(rownode);
            var editstr = xmlToString(rownode, true);
            var revertstr = savedrownode ? xmlToString(savedrownode, true) : null;
            textarea = createTextArea(form, editstr, revertstr != editstr ? revertstr : null, 15, 80);
        }
        if (curEditTextArea) {
            curEditTextArea = null;
            textarea.parentNode.parentNode.parentNode.style.display = "none";
            if (curEditTextInput) {
                curEditTextInput.disabled = "";
                setFocusAndSelect(curEditTextInput);
            }
        }
        else {
            curEditTextArea = textarea;
            textarea.parentNode.parentNode.parentNode.style.display = "";
            textarea.focus();
            if (curEditTextInput) {
                curEditTextInput.disabled = "disabled";
            }
        }
    }});
    appendDOMElement(buttoncell, "button", { type: "button", textContent: "\u2191", onclick: function () {
        moveRow(cell, rownode, -1);
    }});
    buttoncell.lastChild.style.padding = "0px 4px";
    appendDOMElement(buttoncell, "button", { type: "button", textContent: "\u2193", onclick: function () {
        moveRow(cell, rownode, 1);
    }});
    buttoncell.lastChild.style.padding = "0px 4px";
    appendDOMElement(buttoncell, "button", { type: "button", textContent: "Copy", onclick: function () {
        copyEditedRow();
    }});
    appendDOMElement(buttoncell, "button", { type: "button", textContent: "Delete", onclick: function () {
        deleteRow(cell, rownode);
    }});
    form.appendChild(buttontable);
}

function createTextArea(domnode, value, revertvalue, rows, cols) {
    var textareatable = document.createElement("table");
    textareatable.className = "textinput";
    // textarearow
    var textarearow = appendDOMElement(textareatable, "tr");
    var textareacell = appendDOMElement(textarearow, "td", { className: "text" });
    var textarea = appendDOMElement(textareacell, "textarea", { value: value || "", rows: (rows || 10), cols: (cols || 60) });
    // buttonrow
    var buttonrow = appendDOMElement(textareatable, "tr");
    var buttoncell = appendDOMElement(buttonrow, "td", { className: "buttons" });
    // OK button (checkmark)
    var okbutton = appendDOMElement(buttoncell, "button", { type: "button", title: "Apply changes", textContent: "\u2713", onclick: finishEditMode });
    // Cancel button
    var cancelbutton = appendDOMElement(buttoncell, "button", { type: "button", title: "Cancel and ignore changes", textContent: "X", onclick: exitEditMode });
    if (revertvalue != null) {
        // Revert button (anticlockwise top semicircle arrow)
        var revertbutton = appendDOMElement(buttoncell, "button", { type: "button", title: "Revert to saved value", textContent: "\u21b6", onclick: function () {
            textarea.value = revertvalue;
            textarea.focus();
        }});
    }
    domnode.appendChild(textareatable);
    textarea.focus();
    return textarea;
}

function createTextInput(domnode, placeholder, value, revertvalue, type, minwidth) {
    // create table with one row
    var inputtable = document.createElement("table");
    inputtable.className = "textinput";
    var inputrow = document.createElement("tr");
    // Input cell
    var inputcell = appendDOMElement(inputrow, "td", { className: "text", style: { minWidth: (minwidth || 100) + "px" } });
    var buttoncell = null;
    // Text input field
    var inputfield = appendDOMElement(inputcell, "input", { type: "text", placeholder: placeholder, value: value || "" });
    var dropdown = null;
    var previewrow = null;
    var previewtextarea = null;

    //if (type && typeInputPatterns[type]) {
    //	inputfield.pattern = typeInputPatterns[type].source;
    //}
    if (type && customTypes[type]) {
        // associate inputfield with HTML5 datalist (NOTE: .list property doesn't work)
        inputfield.setAttribute("list", "type_" + type);
        // Add dropdown list selection
        // NOTE: inputfield and dropdown aren't visible simultaneously
        var options = customTypes[type];
        dropdown = document.createElement("select");
        dropdown.size = 1;
        createChildElementWithText(dropdown, "option", "");
        for (var i = 0; i < options.length; ++i) {
            createChildElementWithText(dropdown, "option", options[i]);
        }
        dropdown.value = value || "";       // empty string needed to auto-select empty option
        inputcell.appendChild(dropdown);
        // Make input elements interchangeable and show dropdown selection by default
        if (dropdown.selectedIndex >= 0) {
            inputfield.style.display = "none";
        }
        else {
            // Option not in dropdown list, show text input by default
            dropdown.style.display = "none";
        }
        inputfield.oninput = function () {
            dropdown.value = inputfield.value;
            if (previewtextarea && previewtextarea.style.display == "") {
                previewtextarea.value = (dropdown.selectedIndex > 0) ? xmlToString(customTypePreviews[type][dropdown.value], true) : "";
            }
        }
        dropdown.onchange = function () {
            inputfield.value = dropdown.value;
            if (previewtextarea && previewtextarea.style.display == "") {
                previewtextarea.value = (dropdown.selectedIndex > 0) ? xmlToString(customTypePreviews[type][dropdown.value], true) : "";
            }
        }
        // Add table cell for buttons
        if (!buttoncell) {
            buttoncell = document.createElement("td");
        }
        // Edit type toggle button (pencil)
        var edittypebutton = appendDOMElement(buttoncell, "button", { type: "button", className: "smallbutton", title: "Toggle text input", textContent: "\u270e", onclick: function () {
            if (inputfield.style.display == "none") {
                inputfield.style.display = "";
                dropdown.style.display = "none";
                setFocusAndSelect(inputfield);
            }
            else {
                inputfield.style.display = "none";
                dropdown.style.display = "";
                dropdown.focus();
            }
        }});
        if (customTypePreviews[type]) {
            // View XML button (left-pointing magnifying glass)
            previewrow = document.createElement("tr");
            var previewcell = appendDOMElement(previewrow, "td", { className: "text", colSpan: 2 });
            previewtextarea = appendDOMElement(previewcell, "textarea", { rows: 10, cols: 60, readOnly: true, style: { display: "none" } });
            var viewxmlbutton = appendDOMElement(buttoncell, "button", { type: "button", className: "smallbutton", title: "View XML", textContent: "\ud83d\udd0d", onclick: function () {
                if (previewtextarea.style.display == "none") {
                    previewtextarea.style.display = "";
                    previewtextarea.value = (dropdown.selectedIndex > 0) ? xmlToString(customTypePreviews[type][dropdown.value], true) : "";
                }
                else {
                    previewtextarea.style.display = "none";
                }
            }});
        }
    }
    if (revertvalue != null) {
        if (!buttoncell) {
            buttoncell = document.createElement("td");
        }
        // Revert button (anticlockwise top semicircle arrow)
        var revertbutton = appendDOMElement(buttoncell, "button", { type: "button", className: "smallbutton", title: "Revert to saved value", textContent: "\u21b6", onclick: function () {
            inputfield.value = revertvalue;
            if (dropdown) {
                dropdown.value = revertvalue;
                dropdown.style.display = "none";
                inputfield.style.display = "";
            }
            setFocusAndSelect(inputfield);
        }});
    }
    if (buttoncell) {
        buttoncell.className = "buttons";
        inputrow.appendChild(buttoncell);
    }
    // append table row to cell
    inputtable.appendChild(inputrow);
    if (previewrow) {
        inputtable.appendChild(previewrow);
    }
    domnode.appendChild(inputtable);
    // Focus and set caret position/selection
    if (dropdown && dropdown.style.display == "") {
        dropdown.focus();
    }
    else {
        setFocusAndSelect(inputfield);
    }
    return inputfield;
}

function writeCellContent(cell, cellcontent, rownode, column) {
    if (column.dummy) {
        return;
    }
    // Remove previous cell content
    while (cellcontent.firstChild) {
        cellcontent.removeChild(cellcontent.firstChild);
    }
    if ((curEditRow != rownode || curEditCol != column)) {
        // view mode
        // Set/update title text
        if (column.group) {
            cell.title = column.group.name + ": " + column.name;
        }
        else {
            cell.title = column.name;
        }
        if (column.type == "boolean") {
            var value = getCellXMLContent(rownode, column);
            var inputnode = document.createElement("input");
            inputnode.type = "checkbox";
            inputnode.checked = (value != column.negate);
            setOnClick(inputnode, function () {
                finishEditMode();
                onBoolCheckboxClicked(cell, rownode, column, inputnode.checked != column.negate);
            });
            cellcontent.appendChild(inputnode);
        }
        else if (column.displayXSLT) {
            var xmlobj = getCellXMLObject(rownode, column);
            if (xmlobj && xmlobj.nodeType == Node.ELEMENT_NODE) {
                // Convert node to document
                var xmldoc = cloneXMLDocument(theTable.xmlDoc, xmlobj);
                var result = column.displayXSLT.transformToFragment(xmldoc, document);
                cellcontent.appendChild(result);
                if (!column.key) {
                    var text = cellcontent.textContent;
                    var truncatelength = 32;
                    if (text.length > truncatelength + 3) {
                        cellcontent.textContent = text.substr(0, truncatelength) + "...";
                    }
                    cell.title += " =\n" + getCellXMLContent(rownode, column);
                }
            }
        }
        else {
            var value = getCellXMLContent(rownode, column);
            if (value) {
                if (column.type == "text") {
                    var converted = convertFormatString(textdbDoc, value);
                    if (converted != value) {
                        cell.title += " = " + value;
                    }
                    value = converted;
                }
                if (!column.key) {
                    var truncatelength = 32;
                    if (column.type == "xmlnode") {
                        truncatelength = 12;
                    }
                    if (value.length > truncatelength + 3) {
                        if (cell.title.indexOf("=") < 0) {
                            cell.title += ((column.type == "xmlnode") ? " =\n" : " = ") + value;
                        }
                        value = value.substr(0, truncatelength) + "...";
                    }
                }
                cellcontent.textContent = value;
            }
        }
    }
    else {
        // edit mode
        cell.title = "";
        var value = getCellXMLContent(rownode, column);
        var revertvalue = null;
        if (hasCellValueChanged(rownode, column)) {
            var savedrownode = getSavedRowNode(rownode);
            if (savedrownode) {
                revertvalue = getCellXMLContent(savedrownode, column) || "";
            }
        }
        var form = document.createElement("form");
        cellcontent.appendChild(form);
        form.onsubmit = finishEditMode;
        if (isSimpleTextColumnType(column.type)) {
            curEditTextInput = createTextInput(form, column.name, value, revertvalue, column.type);
            //if (column.key) {
            //	curEditTextInput.required = "required";
            //}
            if (column.type == "text") {
                // TODO: Improve
            }
        }
        else {
            curEditTextArea = createTextArea(form, value, revertvalue);
        }
        if (column.key) {
            //form.appendChild(document.createElement("br"));
            createRowEditOptions(cell, form, rownode);
        }
    }
}

function updateColumnVisibility(column) {
    var colidx = theTable.columns.indexOf(column);
    if (colidx >= 0) {
        // Set display="none" if column is disabled
        var displaystyle = column.hidden ? "none" : "";
        var domTable = document.getElementById("mainTable");
        if (domTable && domTable.tHead) {
            domTable.tHead.firstChild.children[colidx].style.display = displaystyle;
            var rows = domTable.tBodies[0].children;
            for (var i = 0; i < rows.length; ++i) {
                rows[i].children[colidx].style.display = displaystyle;
            }
        }
        // Set checkbox state in column settings (exclude hidden entries in column settings)
        if (!(column.dummy && column.name == "")) {
            var domColumnSettings = document.getElementById("columnSettings");
            if (domColumnSettings) {
                var checkbox = domColumnSettings.children[colidx].children[column.group ? 1 : 0].firstChild;
                checkbox.checked = !column.hidden;
            }
        }
    }
    return null;
}

function buildFilters() {
    var domDivFilters = document.getElementById("divFilters");
    while (domDivFilters.firstChild) {
        domDivFilters.removeChild(domDivFilters.firstChild);
    }
    if (theTable) {
        // Filters
        filterColumns = [];
        var domFilters = document.createElement("p");
        domFilters.id = "pFilters";
        domFilters.style.display = "none";
        createChildElementWithText(domFilters, "h2", "Filters:");
        var domFilterTable = document.createElement("table");
        domFilterTable.id = "filterTable";
        domFilterTable.className = "filters centered";
        domFilters.appendChild(domFilterTable);
        domDivFilters.appendChild(domFilters);
    }
}

function buildSettings() {
    var domDivSettings = document.getElementById("divSettings");
    while (domDivSettings.firstChild) {
        domDivSettings.removeChild(domDivSettings.firstChild);
    }
    if (theTable) {
        // Toggle checkbox
        var domColumnSettings;
        var domSettingsToggle = document.createElement("p");
        var domSettingsCheckbox = document.createElement("input");
        domSettingsCheckbox.type = "checkbox";
        setOnClick(domSettingsCheckbox, function () {
            finishEditMode();
            if (domSettingsCheckbox.checked) {
                domColumnSettings.style.display = "";
            }
            else {
                domColumnSettings.style.display = "none";
            }
        });
        domSettingsToggle.appendChild(domSettingsCheckbox);
        domSettingsToggle.appendChild(document.createTextNode("Show filter settings"));
        domDivSettings.appendChild(domSettingsToggle);

        // Column settings
        domColumnSettings = document.createElement("table");
        domColumnSettings.id = "columnSettings";
        domColumnSettings.className = "columnSettings centered";
        domColumnSettings.style.display = "none";
        for (var i = 0; i < theTable.columns.length; ++i) {
            var column = theTable.columns[i];
            tr = document.createElement("tr");
            if (i == 0 || (column.dummy && column.name == "")) {
                // Hide row
                var td = document.createElement("td");
                td.colSpan = 4;
                tr.style.display = "none";
                tr.appendChild(td);
            }
            else {
                // add checkbox
                var td = document.createElement("td");
                var inputnode = document.createElement("input");
                inputnode.type = "checkbox";
                inputnode.checked = !column.hidden;
                if (column.key || i == 0 || i + 1 == theTable.columns.length) {
                    // key column and last column may not be hidden
                    inputnode.disabled = true;
                }
                // helper function required due to loop, see buildTable()
                var onclickSetupHelper = function (inputnode, columnidx, column) {
                    setOnClick(inputnode, function () {
                        finishEditMode();
                        column.hidden = !inputnode.checked;
                        if (column.dummy && column.name) {
                            for (var columnidx = 0; columnidx < theTable.columns.length; ++columnidx) {
                                var curcolumn = theTable.columns[columnidx];
                                if (curcolumn.group && curcolumn.group.name == column.name) {
                                    curcolumn.hidden = !inputnode.checked;
                                    updateColumnVisibility(curcolumn);
                                }
                            }
                        }
                        updateColumnVisibility(column);
                        updateColumnGroupVisibilities();
                    });
                }
                onclickSetupHelper(inputnode, i, column);
                td.appendChild(inputnode);
                tr.appendChild(td);
                // add name
                createChildElementWithText(tr, "td", column.name);
                if (column.dummy) {
                    tr.lastChild.style.fontWeight = "bold";
                }
                // indentation trick: Either insert an empty cell on the left, or use colspan for the name cell,
                // so we end up with three cells per row
                if (column.group) {
                    td = document.createElement("td");
                    tr.insertBefore(td, tr.firstChild);
                }
                else {
                    tr.lastChild.colSpan = 2;
                }
                // add filter button
                td = document.createElement("td");
                td.className = "button";
                if (!column.dummy && !column.special && (column.type == "boolean" || isSimpleTextColumnType(column.type))) {
                    var button = document.createElement("button");
                    button.type = "button";
                    button.textContent = "Add row filter";
                    var onclickSetupHelper2 = function (button, column) {
                        setOnClick(button, function () {
                            finishEditMode();
                            addRowFilter(column);
                        });
                    }
                    onclickSetupHelper2(button, column);
                    td.appendChild(button);
                }
                tr.appendChild(td);
            }
            domColumnSettings.appendChild(tr);
        }
        domDivSettings.appendChild(domColumnSettings);
    }
}

function updateColumnGroupVisibilities() {
    // Hide dummy columns ("group headers") if and only if all columns in the group are hidden
    var lastdummycol = null;
    var grouphidden = true;
    for (var i = 0; i < theTable.columns.length; ++i) {
        var column = theTable.columns[i];
        if (column.dummy) {
            if (lastdummycol && lastdummycol.hidden != grouphidden) {
                lastdummycol.hidden = grouphidden;
                updateColumnVisibility(lastdummycol);
            }
            lastdummycol = column;
            grouphidden = true;
        }
        else if (!column.hidden) {
            grouphidden = false;
        }
    }
    if (lastdummycol && lastdummycol.hidden != grouphidden) {
        lastdummycol.hidden = grouphidden;
        updateColumnVisibility(lastdummycol);
    }
}

function buildTableRow(row, rownode) {
    for (var j = 0; j < theTable.columns.length; ++j) {
        var column = theTable.columns[j];
        var cell = document.createElement("td");
        if (j + 1 == theTable.columns.length) {
            cell.colSpan = 2;
        }
        if (column.dummy) {
            cell.className = "dummy";
        }
        else if (j > 0 && hasCellValueChanged(rownode, column)) {
            cell.className = "dirty";
            row.firstChild.className = "dirty";
        }
        // Add cell content
        var cellcontent = document.createElement("div");
        if (column.key) {
            cellcontent.style.fontWeight = "bold";
        }
        cell.appendChild(cellcontent);
        writeCellContent(cell, cellcontent, rownode, column);
        // Because we are in a loop, we have to wrap the onclick setup in a helper function,
        // so each loop iteration creates a different function with different variable values!
        var onclickSetupHelper = function (cell, rownode, column) {
            setOnClick(cell, function () { return onCellClicked(cell, rownode, column); }, true);
        }
        onclickSetupHelper(cell, rownode, column);
        if (column.hidden) {
            cell.style.display = "none";
        }
        row.appendChild(cell);
    }
    if (theTable.disablerowcolumn && getCellXMLContent(rownode, theTable.disablerowcolumn)) {
        row.className = "disabled";
    }
}

function buildTable() {
    var domDivTable = document.getElementById("divTable");
    while (domDivTable.firstChild) {
        domDivTable.removeChild(domDivTable.firstChild);
    }
    if (theTable) {
        var domTable = document.createElement("table");
        {
            domTable.id = "mainTable";
            domTable.className = "base rotated-header";
            var thead = document.createElement("thead");
            var tr = document.createElement("tr");
            thead.appendChild(tr);
            domTable.appendChild(thead);
            var tbody = document.createElement("tbody");
            tbody.className = "view";
            domTable.appendChild(tbody);
            domDivTable.appendChild(domTable);
        }
        curEditRow = null;
        curEditCol = null;
        curEditTextInput = null;
        curEditTextArea = null;
        // create table header
        for (var i = 0; i < theTable.columns.length; ++i) {
            var column = theTable.columns[i];
            var cell = document.createElement("th");
            cell.className = "rotate";
            if (column.dummy) {
                cell.className += " dummy";
            }
            var cellcontent = document.createElement("div");
            createChildElementWithText(cellcontent, "span", column.name);
            cell.appendChild(cellcontent);
            if (i + 1 == theTable.columns.length) {
                cell.style.width = "100px";
            }
            if (column.hidden) {
                cell.style.display = "none";
            }
            domTable.tHead.firstChild.appendChild(cell);
        }
        // Adding dummy column to make table wide enough for right-most rotated column header
        // NOTE: The last column in each row should get colspan="2" to cover this dummy column
        var cell = document.createElement("th");
        var cellcontent = document.createElement("div");
        cellcontent.style.width = "75px";
        cell.appendChild(cellcontent);
        domTable.tHead.firstChild.appendChild(cell);

        // create table body rows
        for (var i = 0; i < theTable.xmlRowNodes.length; ++i) {
            var rownode = theTable.xmlRowNodes[i];
            var row = document.createElement("tr");
            buildTableRow(row, rownode);
            domTable.tBodies[0].appendChild(row);
        }
        setOnClick(document, finishEditMode);
    }
    else {
        domDivTable.textContent = "Import failed";
    }
}

function onReloadTable() {
    if (theTable) {
        if (isTableDirty()) {
            if (!window.confirm("Reloading the file will discard any unsaved changes. Are you sure you want to continue?")) {
                return;
            }
        }
        var xmlDoc = loadXMLFile(theTable.file);
        if (xmlDoc) {
            theTable.xmlDoc = xmlDoc;
            theTable.xmlSavedDoc = cloneXMLDocument(theTable.xmlDoc);
            theTable.xmlRowNodes = evaluateXPath(theTable.xmlDoc.documentElement, theTable.fileselect);
            theTable.xmlSavedRowNodes = evaluateXPath(theTable.xmlSavedDoc.documentElement, theTable.fileselect);
            buildTable();
        }
        else {
            alert("Reloading " + theTable.file + " failed!")
        }
    }
}

function onReloadExternal() {
    importText();
    importCustomTypes();
    buildTable();
}

function onSaveToDisk() {
    if (blobURL) {
        window.URL.revokeObjectURL(blobURL);
    }
    var xmlstr = xmlToString(theTable.xmlDoc);
    // Make sure we have an XML declaration
    if (xmlstr.substr(0, 5) != "<?xml") {
        xmlstr = '<?xml version="1.0" encoding="utf-8"?>\n' + xmlstr;
    }
    // Enforce consistent Windows line endings
    xmlstr = xmlstr.replace(/\r/g, "").replace(/\n/g, "\r\n");
    var file = new Blob([xmlstr], { type: "text/xml" });
    blobURL = window.URL.createObjectURL(file);
    var filename = theTable.file;
    if (filename.lastIndexOf("/") >= 0) {
        filename = substr(filename.lastIndexOf("/") + 1);
    }
    if (filename.lastIndexOf("\\") >= 0) {
        filename = substr(filename.lastIndexOf("\\") + 1);
    }
    var downloadlink = document.getElementById("downloadDummy");
    downloadlink.href = blobURL;
    downloadlink.download = filename;
    downloadlink.click();
}

function onMarkSaved() {
    theTable.xmlSavedDoc = cloneXMLDocument(theTable.xmlDoc);
    theTable.xmlSavedRowNodes = evaluateXPath(theTable.xmlSavedDoc.documentElement, theTable.fileselect);
    //buildTable();
    for (var i = 0; i < theTable.xmlRowNodes.length; ++i) {
        var rownode = theTable.xmlRowNodes[i];
        setDirtyState(getCell(rownode, theTable.keycolumn), rownode, theTable.keycolumn);
        applyRowFilters(rownode);
    }
}

function init(id) {
    editTableID = id;
    // document onclick handler required to reset clickHandled
    setOnClick(document, null);
    // load metadata
    xmlDefDoc = loadXMLFile("editor.xml");
    if (xmlDefDoc) {
        importText();
        importCustomTypes();
        importTable(evaluateXPath(xmlDefDoc.documentElement, "/*/table[@id='" + editTableID + "']", true));
        buildSettings();
        buildFilters();
        buildTable();
        if (theTable) {
            document.getElementById("h1TableName").textContent = theTable.name;
            var pButtons = document.getElementById("pButtons");
            for (var i = 0; i < 4; ++i) {
                pButtons.appendChild(document.createElement("button"));
            }
            var buttons = pButtons.children;
            buttons[0].textContent = "Reload " + theTable.file;
            setOnClick(buttons[0], onReloadTable);
            buttons[1].textContent = "Reload external files/text";
            setOnClick(buttons[1], onReloadExternal);
            buttons[2].textContent = "Save to disk";
            setOnClick(buttons[2], onSaveToDisk);
            buttons[3].textContent = "Mark changes as saved";
            setOnClick(buttons[3], onMarkSaved);
            // keyboard input
            document.onkeydown = function (e) {
                e = e || window.event;
                if (e.which == 27) {        // Esc
                    exitEditMode();
                }
            }
        }
    }
    else {
        document.getElementById("divTable").textContent = "Import failed";
    }
}
