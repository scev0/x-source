-- param == { 0, 0, container, mode, modeparam }
-- NB: container (param[3]) is optional
-- modes:	"movepassenger",		{ { shipwhitelist, customrequirementstext } }
--			"requestship",			{ dockingbay }
--			"transferplayership",	{ { shiplist } }
--			"transferplayerstation",	{ { stationlist } }

-- modes: 
-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef uint64_t UniverseID;
	bool CanDockAtDockingBay(UniverseID shipid, UniverseID dockingbayid);
	const char* CanTeleportPlayerTo(UniverseID controllableid, bool allowcontrolling, bool force);
	UniverseID GetLastPlayerControlledShipID(void);
	const char* GetComponentName(UniverseID componentid);
	const char* GetObjectIDCode(UniverseID componentid);
	UniverseID GetPlayerID(void);
	UniverseID GetTopLevelContainer(UniverseID componentid);
	bool IsShipAtExternalDock(UniverseID shipid);
	bool IsShipBeingRetrieved(UniverseID shipid);
	bool IsUnit(UniverseID controllableid);
	bool RequestShipFromInternalStorage2(UniverseID shipid, bool highpriority, UniverseID refcomponentid);
	void RemoveDockingBayReservation(UniverseID dockingbayid);
	void SetDockingBayReservation(UniverseID dockingbayid, double duration);
	void SetTrackedMenuFullscreen(const char* menu, bool fullscreen);
	bool TakeShipFromInternalStorage(UniverseID shipid, bool highpriority, bool checkonly);
	bool TeleportPlayerTo(UniverseID controllableid, bool allowcontrolling, bool instant, bool force);
	void TriggerInputFeedback(const char* type, const char* idname, const char* triggerid, const char* contextid);
]]

-- menu variable - used by Helper and used for dynamic variables (e.g. inventory content, etc.)
local menu = {
	name = "PlatformUndockMenu",
	smallFontSize = Helper.standardFontSize * 0.9,
	smallFontHeight = Helper.standardTextHeight * 0.9
}

-- config variable - put all static setup here
--[[
local config = {
}
]]

-- init menu and register with Helper
local function init()
	--print("Initializing")
	Menus = Menus or { }
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end
end

-- cleanup variables in menu, no need for the menu variable to keep all the data while the menu is not active
function menu.cleanup()
	--print("Cleaning Up")
	menu.title = nil
	menu.mode = nil
	menu.modeparam = {}
	menu.currentcontainer = nil
	menu.topcontainer = nil
	menu.destination = nil
	menu.expanded = nil
	menu.lastship = nil
	menu.table_containers = nil
	menu.selectedrow = nil
	menu.dockingbayReserveTime = nil

	menu.frame = nil
end

function menu.teleport()
	--print("Teleporting")
	-- TeleportPlayerTo(UniverseID controllableid, bool checkonly, bool allowcontrolling, bool instant, bool force)
	C.TeleportPlayerTo(menu.destination, false, true, true)
	C.TriggerInputFeedback("action", "INPUT_ACTION_UNDOCK", "fasttravel", "")
	--menu.currentcontainer = ConvertIDTo64Bit(GetPlayerContextByClass("container"))
	Helper.closeMenu(menu, "back")
	menu.cleanup()
end

function menu.onShowMenu()
	C.SetTrackedMenuFullscreen(menu.name, false)
	--print("Showing Menu")
	if menu.param and menu.param[4] then
		menu.mode = menu.param[4]
		menu.modeparam = menu.param[5] or {}
	else
		menu.mode = nil
	end
	if menu.mode == "movepassenger" then
		if menu.modeparam[1] and (type(menu.modeparam[1]) == "table") then
			for _, ship in ipairs(menu.modeparam[1]) do
				menu.modeparam[1][ConvertIDTo64Bit(ship)] = true
			end
		end
	end

	menu.title = ((menu.mode == "movepassenger") or (menu.mode == "requestship") or (menu.mode == "transferplayership")) and ReadText(1001, 7309) or ((menu.mode == "transferplayerstation") and ReadText(1001, 7313) or ReadText(1001, 7300))	-- Choose Ship, Choose Station, Fast Travel To
	menu.currentcontainer = ConvertIDTo64Bit(GetPlayerContextByClass("container"))
	if menu.param and menu.param[3] then
		menu.topcontainer = ConvertIDTo64Bit(menu.param[3])
	else
		menu.topcontainer = ConvertStringTo64Bit(tostring(C.GetTopLevelContainer(menu.currentcontainer)))
	end
	menu.destination = nil
	menu.expanded = {
		[tostring(menu.topcontainer)] = true,
	}
	menu.lastship = C.GetLastPlayerControlledShipID()
	menu.table_containers = {}

	-- add content
	local dockedships = {}
	if (menu.mode == "transferplayership") or (menu.mode == "transferplayerstation") then
		for _, ship in ipairs(menu.modeparam[1]) do
			table.insert(dockedships, ship)
		end
	else
		dockedships = GetContainedObjectsByOwner("player", ConvertStringToLuaID(tostring(menu.topcontainer)))
		local dockedshipsbyID = {}
		for i, ship in ipairs(dockedships) do
			dockedshipsbyID[ConvertIDTo64Bit(ship)] = true
		end
		local missingdockedships = {}
		for i, ship in ipairs(dockedships) do
			menu.checkParent(ship, dockedshipsbyID, missingdockedships)
		end
		for ship in pairs(missingdockedships) do
			table.insert(dockedships, ConvertStringTo64Bit(ship))
		end
	end

	local component = nil
	local docked = {}
	local topcontainerislisted = nil

	--const char* CanTeleportPlayerTo(UniverseID controllableid, bool allowcontrolling, bool force);
	if (menu.mode ~= "requestship") and (menu.mode ~= "transferplayership") and (menu.mode ~= "transferplayerstation") and IsComponentClass(menu.topcontainer, "ship") and (ffi.string(C.CanTeleportPlayerTo(menu.topcontainer, false, true)) == "granted") then
		table.insert(menu.table_containers, {component = menu.topcontainer, docked = {}})
		topcontainerislisted = true
	end

	-- first pass, add all ships docked at menu.topcontainer
	for i = #dockedships, 1, -1 do
		dockedships[i] = ConvertIDTo64Bit(dockedships[i])
		if (not C.IsComponentClass(dockedships[i], "ship")) and (not C.IsComponentClass(dockedships[i], "station")) then
			table.remove(dockedships, i)
		else
			--print(ffi.string(C.GetComponentName(dockedships[i])))
			--if (ffi.string(C.CanTeleportPlayerTo(dockedships[i], true, true) ~= "granted") and menu.mode ~= "movepassenger" then
				--table.remove(dockedships, i)
			local localname = GetComponentData(dockedships[i], "name")
			local localcontainer
			if (menu.mode ~= "transferplayership") and (menu.mode ~= "transferplayerstation") then
				localcontainer = ConvertIDTo64Bit(GetContextByClass(dockedships[i], "container", false))
			end
			if (menu.mode == "transferplayership") or (menu.mode == "transferplayerstation") or (localcontainer == menu.topcontainer) then
				if IsComponentOperational(dockedships[i]) and not C.IsUnit(dockedships[i]) then
					if not topcontainerislisted then
						table.insert(menu.table_containers, {component = dockedships[i], docked = {}})
					else
						table.insert(menu.table_containers[1].docked, {component = dockedships[i], docked = {}})
					end
				end
				table.remove(dockedships, i)
				--print("inserted " .. localname .. " to table. " .. #menu.table_containers .. " objects now in list. " .. #dockedships .. " ships awaiting processing.")
			end
		end
	end

	if (menu.mode ~= "transferplayership") and (menu.mode ~= "transferplayerstation") then
		-- recursive pass. add succeeding layers of docked ships to table.
		local localiter = menu.table_containers

		local loopcount = 0
		while #dockedships > 0 do
			for i = #dockedships, 1, -1 do
				--print(ffi.string(C.GetComponentName(dockedships[i])))
				local localname = GetComponentData(dockedships[i], "name")
				local localcontainer = ConvertIDTo64Bit(GetContextByClass(dockedships[i], "container", false))
				for j = 1, #localiter do
					if localcontainer == localiter[j].component then
						if IsComponentOperational(dockedships[i]) and not C.IsUnit(dockedships[i]) then
							if localiter[j].docked then
								table.insert(localiter[j].docked, {component = dockedships[i], docked = {}})
							else
								table.insert(localiter[j], {docked = {component = dockedships[i], docked = {}}})
							end
						end
						table.remove(dockedships, i)
						--print("recursive. inserted " .. localname .. " to table. " .. #localiter .. " objects now in list. " .. #localiter[j].docked .. " objects now in docked list. " .. #dockedships .. " ships awaiting processing.")
						break
					end
				end
			end
			for i = 1, #localiter do
				if #localiter[i].docked > 0 then
					localiter = localiter[i].docked
					break
				end
			end
			loopcount = loopcount + 1
			if loopcount > 10000 then
				DebugError("Infinite loop detected. Aborting.")
				break
			end
		end
	end

	for _, object in ipairs(menu.table_containers) do
		menu.recursiveSort(object)
	end
	table.sort(menu.table_containers, menu.sortByComponentName)

	if #menu.table_containers < 1 then
		if (ffi.string(C.CanTeleportPlayerTo(menu.currentcontainer, false, true)) == "granted") and GetComponentData(menu.currentcontainer, "owner") == "player" then
			menu.destination = menu.currentcontainer
			menu.teleport()
		else
			Helper.closeMenu(menu, "back")
			menu.cleanup()
		end
	else
		menu.display()
	end
end

function menu.checkParent(ship, dockedshipsbyID, missingdockedships)
	local containerparent = ConvertIDTo64Bit(GetContextByClass(ship, "container", false))
	if (containerparent ~= menu.topcontainer) and (not dockedshipsbyID[containerparent]) then
		missingdockedships[containerparent] = true
		dockedshipsbyID[containerparent] = true
		menu.checkParent(containerparent, dockedshipsbyID, missingdockedships)
	end
end

function menu.sortByComponentName(a, b)
	local aname = GetComponentData(a.component, "name")
	local bname = GetComponentData(b.component, "name")

	return aname < bname
end

function menu.recursiveSort(object)
	if #object.docked > 1 then
		table.sort(object.docked, menu.sortByComponentName)
	end
	for _, object2 in ipairs(object.docked) do
		menu.recursiveSort(object2)
	end
end

function menu.onShowMenuSound()
	-- no sound
end

function menu.display()
	Helper.removeAllWidgetScripts(menu)

	local width = math.floor(Helper.viewWidth / 5)
	local height = math.ceil(Helper.viewHeight * 2 / 5)
	local xoffset = math.floor((Helper.viewWidth - width) / 2)
	local yoffset = math.floor((Helper.viewHeight - height) / 2)

	--print("initial height: " .. tostring(height))
	menu.frame = Helper.createFrameHandle(menu, { height = height, width = width, x = xoffset, y = yoffset })
	menu.frame:setBackground("solid", { color = Color["frame_background_semitransparent"] })
	local table_header, table_data, table_status, table_button, row

	-- set up a new table
	table_header = menu.frame:addTable(1)
	row = table_header:addRow(nil, { bgColor = Color["row_background_blue"] })
	row[1]:createText(menu.title, Helper.headerRow1Properties)

	-- status table
	table_status = menu.frame:addTable(1)

	row = table_status:addRow(nil, { bgColor = Color["row_background_blue"] })
	row[1]:createText( function() return menu.updateShipStatusText(table_data) end, { fontsize = menu.smallFontSize, wordwrap = true, height = menu.smallFontHeight * 3 })

	table_status.properties.y = height - table_status:getVisibleHeight()

	-- button table
	table_button = menu.frame:addTable(2, { tabOrder = 2 })
	table_button:setColWidth(2, width / 2, false)
	row = table_button:addRow(true, { fixed = true })
	row[2]:createButton({ active = true }):setText("", { halign = "center" })
	if menu.mode == "movepassenger" then
		row[2].properties.text.text = ReadText(1001, 2302)
		row[2].properties.active = menu.isCurrentSelectionWhiteListed
		row[2].handlers.onClick = menu.selectElement
	elseif menu.mode == "transferplayership" then
		row[2].properties.text.text = ReadText(1001, 2302)
		row[2].handlers.onClick = menu.selectElement
	elseif menu.mode == "transferplayerstation" then
		row[2].properties.text.text = ReadText(1001, 2305)
		row[2].handlers.onClick = menu.selectElement
	else
		row[2].properties.text.text = function() local readystate = menu.updateShipStatus(table_data) return readystate and ((readystate == 1 and ReadText(1001, 7305)) or (readystate == 2 and ReadText(1001, 7306)) or (readystate >= 3 and ReadText(1001, 7307))) or ReadText(1001, 7306) end
		row[2].properties.active = function() local readystate = menu.updateShipStatus(table_data) return readystate and (readystate <= 2) or false end
		row[2].handlers.onClick = function() local readystate = menu.updateShipStatus(table_data) return readystate and (readystate <= 2 and menu.selectElement()) end
	end

	table_button.properties.y = table_status.properties.y - Helper.borderSize - table_button:getVisibleHeight()

	-- data table
	table_data = menu.frame:addTable(3, { tabOrder = 1, y = table_header.properties.y + table_header:getVisibleHeight() + Helper.borderSize })
	table_data.properties.maxVisibleHeight = table_button.properties.y - Helper.borderSize - table_data.properties.y
	table_data:setColWidth(1, Helper.standardTextHeight)
	table_data:setColWidth(3, Helper.standardFontSize * 8)

	--[[
	if menu.lastship then
		for _, object in ipairs(menu.table_containers) do
			local loccomponent = object.component
			if loccomponent == menu.lastship then
				menu.addRowDockedShips(object, table_data)
				break
			end
		end
		for _, object in ipairs(menu.table_containers) do
			local loccomponent = object.component
			if loccomponent ~= menu.lastship then
				menu.addRowDockedShips(object, table_data)
			end
		end
	else
		for _, object in ipairs(menu.table_containers) do
			menu.addRowDockedShips(object, table_data)
		end
	end
	]]
	local refComponent64
	if menu.mode == "requestship" then
		if menu.modeparam[1] then
			refComponent64 = ConvertIDTo64Bit(menu.modeparam[1])
		end
	end
	local found = false
	for _, object in ipairs(menu.table_containers) do
		local localcontainer = C.GetContextByClass(object.component, "container", false)
		local hasdockingbayref = false
		if menu.mode == "requestship" then
			if C.IsComponentClass(refComponent64, "dockingbay") then
				hasdockingbayref = true
			end
		end

		local show = false
		if menu.mode ~= "requestship" then
			show = true
		elseif (localcontainer == menu.topcontainer) and (not C.IsShipAtExternalDock(object.component)) then
			if hasdockingbayref then
				show = C.CanDockAtDockingBay(object.component, refComponent64)
			else
				show = C.TakeShipFromInternalStorage(object.component, false, true)
			end
		end

		if show then
			menu.addRowDockedShips(object, table_data)
			found = true
		end
	end
	if not found then
		local row = table_data:addRow(nil, {  })
		row[2]:setColSpan(2):createText(ReadText(1001, 7312))
	end

	if menu.selectedrow then
		table_data:setSelectedRow(menu.selectedrow)
		table_data:setTopRow((menu.selectedrow > 1) and (menu.selectedrow - 1) or menu.selectedrow)
	end

	--height = table_header:getVisibleHeight() + table_data:getVisibleHeight() + table_status:getVisibleHeight()
	--print("used height: " .. tostring(height))

	-- display view/frame
	menu.frame:display()
end

menu.updateInterval = 1.0

-- hook to update the menu while it is being displayed
function menu.onUpdate()
	--print("On Update")
	if menu.mode == "requestship" then
		local curTime = getElapsedTime()
		if (not menu.dockingbayReserveTime) or (menu.dockingbayReserveTime < curTime) then
			C.SetDockingBayReservation(ConvertIDTo64Bit(menu.modeparam[1]), 5.0)
			menu.dockingbayReserveTime = curTime + 4.0
		end
	end
	menu.frame:update()
end

-- hook if the highlighted row is changed (is also called on menu creation)
function menu.onRowChanged(row, rowdata, uitable)
	--print("Row Changed")
	if uitable == menu.defaulttable then
		menu.destination = rowdata
	end
	menu.frame:update()
end

-- hook if the highlighted row is selected
function menu.onSelectElement()
	--print("Element Selected")

	if menu.mode == "movepassenger" then
		if (not menu.modeparam[1]) or (menu.modeparam[1][menu.destination] ~= nil) then
			Helper.closeMenuForSection(menu, "c_movepassenger_destinationselected", ConvertStringToLuaID(tostring(menu.destination)))
		end
	elseif menu.mode == "transferplayership" then
		Helper.closeMenuForSection(menu, "c_transferplayership_shipselected", ConvertStringToLuaID(tostring(menu.destination)))
	elseif menu.mode == "transferplayerstation" then
		Helper.closeMenuForSection(menu, "c_transferplayerstation_stationselected", ConvertStringToLuaID(tostring(menu.destination)))
	else
		local ready = nil

		if menu.destination == menu.topcontainer then
			ready = true
		else
			if not C.IsShipAtExternalDock(menu.destination) then
				ready = false
			else
				local localcontainer = ConvertIDTo64Bit(GetContextByClass(menu.destination, "container", false))
				if localcontainer ~= menu.topcontainer and not C.IsShipAtExternalDock(localcontainer) then
					ready = false
				else
					ready = true
				end
			end
		end

		if not ready then
			if menu.mode == "requestship" then
				C.RemoveDockingBayReservation(ConvertIDTo64Bit(menu.modeparam[1]))
			end
			if C.RequestShipFromInternalStorage2(menu.destination, false, (menu.mode == "requestship") and ConvertIDTo64Bit(menu.modeparam[1]) or C.GetPlayerID()) then
				--print("Request was either granted or queued.")
			else
				--print("Request was denied. Dock is busy.")
			end

			if menu.mode == "requestship" then
				Helper.closeMenu(menu, "back")
				menu.cleanup()
			else
				menu.frame:update()
			end
		else
			menu.teleport()
		end
	end
end

-- hook if the menu is being closed
function menu.onCloseElement(dueToClose)
	--print("Element Closed")
	Helper.closeMenu(menu, dueToClose)
	menu.cleanup()
end

function menu.buttonExpand(component, row)
	--print("Button Expanded")
	if menu.expanded[tostring(component)] then
		menu.expanded[tostring(component)] = nil
	else
		menu.expanded[tostring(component)] = true
	end

	menu.selectedrow = row
	menu.frame:update()
	menu.display()
end

function menu.updateShipStatus(datatable)
	local ready = nil
	local locindex = nil
	for i = 1, #datatable.rows do
		if datatable.rows[i].index == Helper.currentTableRow[menu.defaulttable] then
			locindex = i
			break
		end
	end

	if locindex and datatable.rows and datatable.rows[locindex].rowdata then
		--print("locindex: " .. tostring(locindex) .. " datatable.rows: " .. tostring(datatable.rows) .. " rowdata: " .. tostring(datatable.rows[locindex].rowdata))
		menu.destination = datatable.rows[locindex].rowdata

		if menu.destination == menu.topcontainer then
			ready = true
		else
			local localcontainer = ConvertIDTo64Bit(GetContextByClass(menu.destination, "container", false))

			if not C.IsShipAtExternalDock(menu.destination) or C.IsShipBeingRetrieved(menu.destination) then
				ready = false
			else
				if localcontainer ~= menu.topcontainer and not C.IsShipAtExternalDock(localcontainer) then
					ready = false
				else
					ready = true
				end
			end
		end

		if not ready then
			if C.IsShipBeingRetrieved(menu.destination) then
				ready = 4
			else
				ready = 2
			end
		else
			ready = 1
		end
	end

	return ready
end

function menu.isCurrentSelectionWhiteListed()
	local row = Helper.currentTableRow[menu.defaulttable]
	local ship = menu.rowDataMap[menu.defaulttable] and menu.rowDataMap[menu.defaulttable][row]
	return (ship ~= nil) and ((not menu.modeparam[1]) or (menu.modeparam[1][ship] ~= nil))
end

function menu.updateShipStatusText(datatable)
	local statustext = ""
	if menu.mode == "movepassenger" then
		if not menu.isCurrentSelectionWhiteListed() then
			local row = Helper.currentTableRow[menu.defaulttable]
			local ship = menu.rowDataMap[menu.defaulttable] and menu.rowDataMap[menu.defaulttable][row]
			if ship then
				statustext = GetComponentData(ship, "isplayerowned") and (menu.modeparam[2] and tostring(menu.modeparam[2]) or ReadText(1001, 7310)) or ReadText(1001, 7311)
			end
		end
	elseif (menu.mode == "transferplayership") or (menu.mode == "transferplayerstation") then
		-- nothing to do
	else
		local readystate = menu.updateShipStatus(datatable)
		if readystate then
			if readystate == 1 then
				statustext = ReadText(1001, 7303)	-- This ship is ready to launch.
			elseif readystate == 2 then
				statustext = ReadText(1001, 7301)	-- This ship is currently in internal storage.\nCall the ship to an external dock before undocking.
			elseif readystate == 3 then
				statustext = ReadText(1001, 7302)	-- This ship is currently in internal storage.\nAll external docks are busy at the moment.\nPlease try again later.
			elseif readystate == 4 then
				statustext = ReadText(1001, 7304)	-- "This ship is being moved to an external docking bay.\nIt will be available shortly."
			else
				print("unhandled readystate: " .. tostring(readystate))
			end
		end
	end

	return statustext
end

function menu.shipTextColor(ship)
	local textcolor = Color["text_normal"]

	if menu.mode == "movepassenger" then
		local iswhitelisted = (not menu.modeparam[1]) or menu.modeparam[1][ship]
		textcolor = iswhitelisted and Color["text_normal"] or Color["text_inactive"]
	elseif (menu.mode == "transferplayership") or (menu.mode == "transferplayerstation") then
		-- nothing to do
	else
		if ship ~= menu.topcontainer then
			if not C.IsShipAtExternalDock(ship) or C.IsShipBeingRetrieved(ship) then
				textcolor = Color["ship_retrieval"]
			else
				if ship ~= menu.topcontainer and not C.IsShipAtExternalDock(ship) then
					textcolor = Color["ship_retrieval"]
				end
			end
		end
	end

	return textcolor
end

function menu.addRowDockedShips(object, shiptable, indent)
	local localcomponent = object.component

	if not indent then
		indent = 0
	end

	local locrow = shiptable:addRow(localcomponent, {  })
	local locname = ffi.string(C.GetComponentName(localcomponent))
	local locidcode = ffi.string(C.GetObjectIDCode(localcomponent))
	local rowindex = locrow.index
	--print("adding ship: " .. ffi.string(C.GetObjectIDCode(localcomponent)) .. " " .. GetComponentData(localcomponent, "name") .. "\ntable: " .. tostring(shiptable) .. "\nrow: " .. rowindex)

	if not menu.selectedrow and menu.lastship and localcomponent == menu.lastship then
		--print("the last ship flown is " .. locidcode .. " " .. locname .. " at row " .. row)
		menu.selectedrow = rowindex
	end

	if object.docked and #object.docked > 0 then
		locrow[1]:createButton({ height = Helper.standardTextHeight }):setText(function() return menu.expanded[tostring(localcomponent)] and "-" or "+" end, { halign = "center" })
		locrow[1].handlers.onClick = function() return menu.buttonExpand(localcomponent, rowindex) end
	end

	local macro = GetComponentData(localcomponent, "macro")
	local shipicon = GetComponentData(localcomponent, "icon")
	locrow[2]:createText("\27[" .. shipicon .. "] " .. locname, { halign = "left", color = function() return menu.shipTextColor(localcomponent) end, x = Helper.standardTextOffsetx * indent })
	locrow[3]:createText(locidcode, { halign = "center", color = function() return menu.shipTextColor(localcomponent) end })

	--print("localcomponent: " .. tostring(localcomponent) .. " topcontainer: " .. tostring(menu.topcontainer) .. " expanded? " .. tostring(menu.expanded[tostring(localcomponent)]))
	if menu.expanded[tostring(localcomponent)] then
		for _, dockedobject in ipairs(object.docked) do
			menu.addRowDockedShips(dockedobject, shiptable, indent + 2)
		end
	end
end

init()
