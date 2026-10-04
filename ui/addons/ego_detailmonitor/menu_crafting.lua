
-- param == { 0, 0 }

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef struct {
		const char* id;
		const char* name;
		const char* icon;
		const char* factoryname;
		const char* factorydesc;
		const char* factorymapicon;
		const char* factoryhudicon;
		const char* tags;
		uint32_t tier;
		uint32_t priority;
	} WareGroupInfo2;

	uint32_t GetAllWareGroups2(WareGroupInfo2* result, uint32_t resultlen, const char* matchingtags);
	double GetCurrentGameTime(void);
	uint32_t GetNumAllWareGroups(void);
	uint32_t GetNumWares(const char* tags, bool research, const char* licenceownerid, const char* exclusiontags);
	UniverseID GetPlayerOccupiedShipID(void);
	UniverseID GetPlayerZoneID(void);
	uint32_t GetWares(const char** result, uint32_t resultlen, const char* tags, bool research, const char* licenceownerid, const char* exclusiontags);
	bool IsMouseEmulationActive(void);
]]

local menu = {
	name = "CraftingMenu",
	inventoryData = {
		craftingHistory = {},
		selectedWares = {},
	},
	category = "generalitem",
}

local config = {
	mode = "crafting",
	mainLayer = 5,
	infoLayer = 4,
	contextLayer = 2,
	rowHeight = 17,
	rightAlignTextProperties = {
		halign = "right"
	},
	rightAlignBoldTextProperties = {
		font = Helper.standardFontBold,
		halign = "right",
	},
	mouseOutRange = 100,
	categories = {
		"generalitem",
		"luxuryitem",
		"hardware",
		"curiosity",
		"contraband",
	}
}

local function init()
	Menus = Menus or { }
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end
end

function menu.cleanup()
	menu.infoFrame = nil
	menu.contextFrame = nil

	menu.categoryTable = nil
	menu.infoTable = nil
	menu.buttonTable = nil

	menu.contextMenuMode = nil
	menu.mouseOutBox = nil

	menu.inventoryData.selectedWares = {}

	menu.settoprow = nil
	menu.setselectedrow = nil
end

-- Menu member functions

function menu.refreshInfoFrame(toprow, selectedrow)
	menu.settoprow = toprow or GetTopRow(menu.infoTable)
	menu.setselectedrow = selectedrow or Helper.currentTableRow[menu.infoTable]
	menu.createInfoFrame()
end

function menu.buttonInventoryCraft()
	if menu.inventoryData.mode == "craft" then
		if menu.inventoryData.craftAmount and menu.inventoryData.craftAmount > 0 then
			for _, entry in ipairs(menu.craftable[menu.category] or {}) do
				if entry.ware == menu.inventoryData.craftWare[1] then
					if HasAllResourcesToCraft(nil, menu.inventoryData.craftWare[1], menu.inventoryData.craftAmount) then
						local isunbundleammo, component = GetWareData(menu.inventoryData.craftWare[1], "isunbundleammo", "component")
						if isunbundleammo then
							local playership = C.GetPlayerOccupiedShipID()
							if playership ~= 0 then
								if AddAmmo(ConvertStringTo64Bit(tostring(playership)), component, menu.inventoryData.craftAmount, true) ~= menu.inventoryData.craftAmount then
									-- We're out of ammo space abort
									break
								end
							end
						end
						for _, resource in ipairs(entry.resources) do
							RemoveInventory(nil, resource.ware, menu.inventoryData.craftAmount * resource.data.needed)
						end
						AddInventory(nil, menu.inventoryData.craftWare[1], menu.inventoryData.craftAmount, true)
						table.insert(menu.inventoryData.craftingHistory, 1, { ware = menu.inventoryData.craftWare, amount = menu.inventoryData.craftAmount, time = C.GetCurrentGameTime() })
						PlaySound("ui_crafting_success")
					end
					break
				end
			end
		end
		menu.inventoryData.mode = nil
		menu.inventoryData.craftWare = nil
		menu.inventoryData.craftAmount = nil
	else
		local rowdata = Helper.getCurrentRowData(menu, menu.defaulttable)
		if type(rowdata) == "table" then
			menu.inventoryData.mode = "craft"
			menu.inventoryData.craftWare = Helper.getCurrentRowData(menu, menu.defaulttable)
			menu.inventoryData.craftAmount = 1
		end
	end
	menu.refreshInfoFrame()
end

function menu.buttonInventoryCancel()
	menu.inventoryData.mode = nil
	menu.inventoryData.craftWare = nil
	menu.inventoryData.craftAmount = nil
	menu.refreshInfoFrame()
end

function menu.buttonInventoryEncyclopedia(ware)
	Helper.closeMenuAndOpenNewMenu(menu, "EncyclopediaMenu", { 0, 0, "Wares", "inventory_wares", ware })
	menu.cleanup()
end

function menu.slidercellInventoryCraft(_, value)
	menu.inventoryData.craftAmount = value
end

function menu.onShowMenu()
	-- Init
	menu.contextMenuWidth = Helper.scaleX(200)

	menu.mode = config.mode

	menu.waregroups = {}
	local n = C.GetNumAllWareGroups()
	local buf = ffi.new("WareGroupInfo2[?]", n)
	n = C.GetAllWareGroups2(buf, n, "craftable")
	for i = 0, n - 1 do
		local id = ffi.string(buf[i].id)
		menu.waregroups[id] = { icon = ffi.string(buf[i].factorymapicon), name = ffi.string(buf[i].name) }
	end

	-- display info
	menu.createInfoFrame()
end

function menu.createInfoFrame()
	-- remove old data
	Helper.clearDataForRefresh(menu, config.infoLayer)

	local frameProperties = {
		width = Helper.playerInfoConfig.width + 2 * Helper.playerInfoConfig.offsetX,
		height = Helper.viewHeight,
		x = (Helper.viewWidth - Helper.playerInfoConfig.width - 2 * Helper.playerInfoConfig.offsetX) / 2,
		y = 0,
		layer = config.infoLayer,
	}

	menu.infoFrame = Helper.createFrameHandle(menu, frameProperties)
	menu.infoFrame:setBackground("solid", { color = Color["frame_background_semitransparent"] })

	local tableProperties = {
		width = Helper.playerInfoConfig.width,
		x = Helper.playerInfoConfig.offsetX,
		y = Helper.playerInfoConfig.offsetY,
	}
	tableProperties.height = Helper.viewHeight - tableProperties.y

	if menu.mode == "crafting" then
		menu.createCrafting(menu.infoFrame, tableProperties)
	end

	menu.infoFrame:display()
end

function menu.createCrafting(frame, tableProperties)
	menu.inventory = GetPlayerInventory()
	menu.inventoryData.policefaction = GetComponentData(ConvertStringTo64Bit(tostring(C.GetPlayerZoneID())), "policefaction")

	menu.craftable = {}

	local numwares = C.GetNumWares("inventory", false, nil, "paintmod clothingmod personalupgrade equipmentmodpart")
	local wares = ffi.new("const char*[?]", numwares)
	numwares = C.GetWares(wares, numwares, "inventory", false, nil, "paintmod clothingmod personalupgrade equipmentmodpart")
	for i = 0, numwares - 1 do
		local ware = ffi.string(wares[i])
		local waredata = menu.inventory[ware]
		local hasproduction, products, issinglecraft, iscrafting = GetWareData(ware, "hasproductionmethod", "products", "issinglecraft", "iscrafting")
		if (not issinglecraft) or (waredata.amount < 1) then
			if iscrafting and hasproduction then
				menu.createCraftableEntry(ware)
			elseif next(products) then
				for _, product in ipairs(products) do
					menu.createCraftableEntry(product)
				end
			end
		end
	end

	for _, category in ipairs(config.categories) do
		menu.craftable[category] = menu.craftable[category] or {}
		table.sort(menu.craftable[category], function (a, b) return a.data.name < b.data.name end)
	end

	local numcols = #config.categories
	local titletable = frame:addTable(numcols, { tabOrder = 2, borderEnabled = true, width = tableProperties.width, x = tableProperties.x, y = tableProperties.y, maxVisibleHeight = tableProperties.height })
	titletable:setColWidth(2, tableProperties.width / 5, false)
	titletable:setColWidth(3, tableProperties.width / 5, false)
	titletable:setColWidth(4, tableProperties.width / 5, false)

	-- title
	local row = titletable:addRow(nil, { fixed = true, bgColor = Color["row_title_background"] })
	row[1]:setColSpan(numcols):createText(ReadText(1001, 7701), Helper.titleTextProperties)

	-- tabs
	local row = titletable:addRow(true, { fixed = true, borderBelow = false })
	for i, category in ipairs(config.categories) do
		row[i]:createButton({ bgColor = (menu.category == category) and Color["row_background_selected"] or Color["row_background_blue"], helpOverlayID = "crafting_category_"..category, helpOverlayText = " ", helpOverlayHighlightOnly = true }):setText(menu.waregroups[category].name, { halign = "center" })
		row[i].handlers.onClick = function () menu.category = category; menu.refreshInfoFrame() end
		if menu.category == category then
			titletable:setSelectedCol(i)
		end
	end

	local row = titletable:addRow(nil, { fixed = true, bgColor = Color["row_background_selected"] })
	row[1]:setColSpan(numcols):createText(" ", { scaling = false, fontsize = 1, height = Helper.borderSize })

	local yoffset = titletable:getFullHeight() + 2 * Helper.standardContainerOffset
	local infotable = frame:addTable(4, { tabOrder = 1, borderEnabled = true, width = tableProperties.width, x = tableProperties.x, y = tableProperties.y + yoffset, maxVisibleHeight = tableProperties.height - yoffset })
	if menu.setdefaulttable then
		infotable.properties.defaultInteractiveObject = true
		menu.setdefaulttable = nil
	end
	infotable:setColWidth(2, tableProperties.width / 5, false)
	infotable:setColWidth(3, tableProperties.width / 5, false)
	infotable:setColWidth(4, tableProperties.width / 5, false)
	infotable:setDefaultBackgroundColSpan(1, 4)

	if next(menu.craftable[menu.category]) then
		-- header
		row = infotable:addRow(ware, { bgColor = Color["row_background_unselectable"] })
		row[1]:createText(ReadText(1001, 45), { font = Helper.standardFontBold })
		row[2]:createText(ReadText(1001, 1202), config.rightAlignBoldTextProperties)
		row[3]:createText(ReadText(1001, 2413), config.rightAlignBoldTextProperties)
		row[4]:createText(ReadText(1001, 2927), config.rightAlignBoldTextProperties)

		-- entries
		local first = true
		for i, product in ipairs(menu.craftable[menu.category]) do
			AddKnownItem("productionmethods", GetWareData(product.ware, "productionmethod"))
			if not first then
				infotable:addEmptyRow(Helper.standardTextHeight / 2)
			end
			first = false
			menu.addInventoryWareEntry(infotable, product.ware, product.data, true)
			for _, resource in ipairs(product.resources) do
				menu.addInventoryWareEntry(infotable, resource.ware, resource.data, true, true)
			end
		end
	else
		row = infotable:addRow(true, {  })
		row[1]:setColSpan(4):createText("-- " .. ReadText(1001, 32) .. " --", { halign = "center" })
	end

	infotable:setTopRow(menu.settoprow)
	infotable:setSelectedRow(menu.setselectedrow)
	menu.settoprow = nil
	menu.setselectedrow = nil

	-- history & buttons
	local buttontable = frame:addTable(3, { tabOrder = 2, borderEnabled = true, width = tableProperties.width, x = tableProperties.x, y = tableProperties.y + yoffset })

	local row = buttontable:addRow(false, { fixed = true })
	row[1]:setColSpan(3):createText("")

	local row
	if menu.inventoryData.craftingHistory[1] then
		row = buttontable:addRow(nil, { fixed = true, bgColor = Color["row_title_background"] })
		row[1]:setColSpan(3):createText(ReadText(1001, 7707), Helper.titleTextProperties)

		for i = 1, math.min(3, #menu.inventoryData.craftingHistory) do
			local entry = menu.inventoryData.craftingHistory[i]

			row = buttontable:addRow(nil, { fixed = true })
			row[1]:setColSpan(2):createText(entry.amount .. ReadText(1001, 42) .. " " .. entry.ware[2].name)
			row[3]:createText(Helper.convertGameTimeToXTimeString(entry.time), config.rightAlignTextProperties)
		end

		row = buttontable:addRow(nil, { fixed = true })
		row[1]:setColSpan(3):createText("")
	end
	if menu.inventoryData.mode == "craft" then
		row = buttontable:addRow(true, { fixed = true })

		local slidermax = menu.inventoryData.craftWare[2].craftable
		row[1]:setColSpan(3):createSliderCell({ height = Helper.standardButtonHeight, valueColor = Color["slider_value"], min = 0, minSelect = 1, max = slidermax, start = 1 }):setText(menu.inventoryData.craftWare[2].name)
		row[1].handlers.onSliderCellChanged = menu.slidercellInventoryCraft

		row = buttontable:addRow(true, { fixed = true })
		-- cancel button
		row[3]:createButton():setText(ReadText(1001, 64), { halign = "center" })
		row[3].handlers.onClick = menu.buttonInventoryCancel
	else
		row = buttontable:addRow(true, { fixed = true })
	end
	-- craft item button
	row[1]:createButton({ active = true, helpOverlayID = "crafting_craftitem", helpOverlayText = " ", helpOverlayHighlightOnly = true }):setText(ReadText(1001, 7706), { halign = "center" }):setHotkey("INPUT_STATE_DETAILMONITOR_X", { displayIcon = true })
	row[1].handlers.onClick = menu.buttonInventoryCraft
	menu.craftButtonWidth = row[3]:getWidth()

	local maxVisibleHeight = infotable.properties.maxVisibleHeight - buttontable:getFullHeight() - Helper.frameBorder
	buttontable.properties.y = buttontable.properties.y + math.min(maxVisibleHeight, infotable:getFullHeight())
	infotable.properties.maxVisibleHeight = buttontable.properties.y - infotable.properties.y

	titletable:addConnection(1, 1, true)
	infotable:addConnection(2, 1)
	buttontable:addConnection(3, 1)
end

function menu.createInventoryContext(wareinfo, x, y)
	Helper.removeAllWidgetScripts(menu, config.contextLayer)
	PlaySound("ui_positive_click")

	menu.contextFrame = Helper.createFrameHandle(menu, {
		layer = config.contextLayer,
		standardButtons = { close = true },
		width = menu.contextMenuWidth,
		x = x,
		y = 0,
		autoFrameHeight = true,
	})
	menu.contextFrame:setBackground("solid", { color = Color["frame_background_semitransparent"] })

	local ftable = menu.contextFrame:addTable(1, { tabOrder = 4, highlightMode = "off" })

	local counter = 0
	local allowencyclopedia = true
	local allowdrop = 0
	local dropmouseovertext = ReadText(1001, 7714)
	for ware in pairs(menu.inventoryData.selectedWares) do
		counter = counter + 1
		if counter > 1 then
			allowencyclopedia = false
		end
		if GetWareData(ware, "allowdrop") then
			allowdrop = allowdrop + 1
		else
			dropmouseovertext = dropmouseovertext .. "\n" .. GetWareData(ware, "name")
		end
	end

	local title = wareinfo[2].name
	if counter > 1 then
		title = string.format(ReadText(1001, 7713), counter)
	end

	local row = ftable:addRow(false, { fixed = true, bgColor = Color["row_background_blue"] })
	row[1]:createText(title, Helper.titleTextProperties)

	row = ftable:addRow(true, { fixed = true })
	row[1]:createButton({ active = allowencyclopedia, bgColor = allowencyclopedia and Color["button_background_hidden"] or Color["button_background_inactive"] }):setText(ReadText(1001, 2400), { color = allowencyclopedia and Color["text_normal"] or Color["text_inactive"] })
	row[1].handlers.onClick = function () return menu.buttonInventoryEncyclopedia(wareinfo[1]) end

	if menu.contextFrame.properties.x + menu.contextMenuWidth > Helper.viewWidth then
		menu.contextFrame.properties.x = Helper.viewWidth - menu.contextMenuWidth - config.border
	end
	local height = menu.contextFrame:getUsedHeight()
	if y + height > Helper.viewHeight then
		menu.contextFrame.properties.y = Helper.viewHeight - height - config.border
	else
		menu.contextFrame.properties.y = y
	end

	menu.contextFrame:display()

	menu.mouseOutBox = {
		x1 =   menu.contextFrame.properties.x -  Helper.viewWidth / 2                         - config.mouseOutRange,
		x2 =   menu.contextFrame.properties.x -  Helper.viewWidth / 2 + menu.contextMenuWidth + config.mouseOutRange,
		y1 = - menu.contextFrame.properties.y + Helper.viewHeight / 2                         + config.mouseOutRange,
		y2 = - menu.contextFrame.properties.y + Helper.viewHeight / 2 - height                - config.mouseOutRange
	}
end

function menu.closeContextMenu()
	Helper.clearFrame(menu, config.contextLayer)
	menu.contextMenuMode = nil
	menu.mouseOutBox = nil
end

function menu.viewCreated(layer, ...)
	if layer == config.infoLayer then
		menu.categoryTable, menu.infoTable, menu.buttonTable = ...
	end
end

-- update
menu.updateInterval = 0.1

function menu.onUpdate()
	menu.infoFrame:update()

	if menu.mouseOutBox then
		if (GetControllerInfo() ~= "gamepad") or (C.IsMouseEmulationActive()) then
			local curpos = table.pack(GetLocalMousePosition())
			if curpos[1] and ((curpos[1] < menu.mouseOutBox.x1) or (curpos[1] > menu.mouseOutBox.x2)) then
				menu.closeContextMenu()
			elseif curpos[2] and ((curpos[2] > menu.mouseOutBox.y1) or (curpos[2] < menu.mouseOutBox.y2)) then
				menu.closeContextMenu()
			end
		end
	end
end

function menu.onRowChanged(row, rowdata, uitable)
	if uitable == menu.infoTable then
		if menu.mode == "crafting" then
			if type(rowdata) == "table" then
				if menu.inventoryData.mode ~= "craft" then
					local isunbundleammo, component = GetWareData(rowdata[1], "isunbundleammo", "component")
					local ammospace = false
					if isunbundleammo then
						local playership = C.GetPlayerOccupiedShipID()
						if playership ~= 0 then
							ammospace = AddAmmo(ConvertStringTo64Bit(tostring(playership)), component, 1, true) == 1
						end
					end

					local row = 2
					if menu.inventoryData.craftingHistory[1] then
						row = row + math.min(3, #menu.inventoryData.craftingHistory) + 2
					end

					if menu.findInventoryWare(menu.craftable[menu.category], rowdata[1]) then
						local mot_craft = ""
						local active = false
						if rowdata[2].craftable > 0 then
							if (not isunbundleammo) or ammospace then
								mot_craft = ReadText(1026, 3900)
								active = true
							else
								mot_craft = ReadText(1026, 3903)
							end
						else
							mot_craft = ReadText(1026, 3901)
						end

						local desc = Helper.createButton(Helper.createTextInfo(ReadText(1001, 7706), "center", Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), 255, 255, 255, 100), nil, true, active, 0, 0, menu.craftButtonWidth, Helper.scaleY(Helper.standardButtonHeight), nil, { action = "INPUT_STATE_DETAILMONITOR_X", displayIcon = true }, nil, mot_craft, "crafting_craftitem")
						Helper.setCellContent(menu, menu.buttonTable, desc, row, 1, nil, "button", nil, menu.buttonInventoryCraft)
					else
						Helper.setCellContent(menu, menu.buttonTable, Helper.getEmptyCellDescriptor(), row, 1, true, "button")
					end
				end
			end
		end
	end
end

function menu.onSelectElement(uitable, modified, row)
	local rowdata = Helper.getCurrentRowData(menu, uitable)
	if uitable == menu.infoTable then
		if (menu.mode == "crafting") then
			if type(rowdata) == "table" then
				menu.closeContextMenu()
			end
		end
	end
end

function menu.onTableRightMouseClick(uitable, row, posx, posy)
	if menu.mode == "crafting" then
		if uitable == menu.infoTable then
			local rowdata = menu.rowDataMap[uitable] and menu.rowDataMap[uitable][row]
			if type(rowdata) == "table" then
				menu.inventoryData.selectedWares = { [rowdata[1]] = true }

				local x, y = GetLocalMousePosition()
				if x == nil then
					-- gamepad case
					x = posx
					y = -posy
				end
				menu.contextMenuMode = "inventory"
				menu.createInventoryContext(rowdata, x + Helper.viewWidth / 2, Helper.viewHeight / 2 - y)
			end
		end
	end
end

function menu.closeMenu(dueToClose)
	Helper.closeMenu(menu, dueToClose)
	menu.cleanup()
end

function menu.onCloseElement(dueToClose)
	if menu.contextMenuMode then
		menu.closeContextMenu()
	else
		menu.closeMenu(dueToClose)
	end
end

-- menu helpers

function menu.getInventoryName(ware, waredata, showunread, isresource)
	local unread = GetWareData(ware, "isunreadinventory")

	local name = waredata.name
	local color = (isresource or (waredata.craftable > 0)) and Color["text_normal"] or Color["text_inactive"]
	if menu.inventoryData.policefaction and IsWareIllegalTo(ware, "player", menu.inventoryData.policefaction) then
		color = (isresource or (waredata.craftable > 0)) and Color["text_illegal"] or Color["text_illegal_inactive"]
	end
	if showunread and unread then
		name = ColorText["text_warning"] .. "\027[workshop_error]\027X " .. name
	end

	return name, color
end

function menu.addInventoryWareEntry(ftable, ware, waredata, iscrafting, isresource, hideprice)
	local bgColor
	if iscrafting and (not isresource) then
		bgColor = Color["row_background_blue"]
	end
	local row = ftable:addRow({ware, waredata}, { bgColor = bgColor })

	-- name
	local name, color = menu.getInventoryName(ware, waredata, not iscrafting, isresource)
	if isresource then
		name = "    " .. name
	end
	row[1]:setColSpan(hideprice and 4 or 1):createText(name, { font = font, color = color })
	row[1].properties.helpOverlayID = "crafting_ware_"..ware
	row[1].properties.helpOverlayText = " "
	row[1].properties.helpOverlayHeight = row:getHeight()
	row[1].properties.helpOverlayHighlightOnly = true
	row[1].properties.helpOverlayScaling = false
	row[1].properties.helpOverlayUseBackgroundSpan = true

	if not hideprice then
		-- amount
		if isresource then
			row[2]:createText(waredata.amount .. " / " .. waredata.needed, config.rightAlignTextProperties)
			if waredata.amount < waredata.needed then
				row[2].properties.color = Color["text_error"]
			end
		else
			row[2]:createText(waredata.amount, config.rightAlignTextProperties)
		end
		-- base price
		local avgprice = GetWareData(ware, "avgprice")
		row[3]:createText(ConvertMoneyString(avgprice, false, true, 0, true) .. " " .. ReadText(1001, 101), config.rightAlignTextProperties)
		-- total price
		row[4]:createText(ConvertMoneyString(avgprice * waredata.amount, false, true, 0, true) .. " " .. ReadText(1001, 101), config.rightAlignTextProperties)
	end

	local ispaintmod = GetWareData(ware, "ispaintmod")
	if ispaintmod then
		AddKnownItem("paintmods", ware)
	else
		AddKnownItem("inventory_wares", ware)
	end
end

function menu.findInventoryWare(array, ware)
	for _, entry in ipairs(array) do
		if entry.ware == ware then
			return true
		end
	end
	return false
end

function menu.createCraftableEntry(ware)
	local name, buyprice, rawresources, isunbundleammo, component, groupID, groupname = GetWareData(ware, "name", "buyprice", "resources", "isunbundleammo", "component", "groupID", "groupName")
	menu.craftable[groupID] = menu.craftable[groupID] or {}
	if not menu.findInventoryWare(menu.craftable[groupID], ware) then
		local waredata
		if menu.inventory[ware] then
			waredata = menu.inventory[ware]
		else
			waredata = { name = name, amount = 0, price = buyprice }
		end

		local resources = {}
		local resourcecount = 0
		local craftableamount
		if #rawresources > 0 then
			for _, resource in ipairs(rawresources) do
				local resourcedata = menu.inventory[resource.ware]
				if resourcedata then
					resourcecount = resourcecount + resourcedata.amount
					local maxcraftable = math.floor(resourcedata.amount / resource.amount)
					craftableamount = craftableamount and math.min(maxcraftable, craftableamount) or maxcraftable
					table.insert(resources, { ware = resource.ware, data = { name = resourcedata.name, amount = resourcedata.amount, price = resourcedata.price, needed = resource.amount } })
				else
					local resourcename, resourcebuyprice = GetWareData(resource.ware, "name", "buyprice")
					craftableamount = 0
					table.insert(resources, { ware = resource.ware, data = { name = resourcename, amount = 0, price = resourcebuyprice, needed = resource.amount } })
				end
			end
		else
			craftableamount = 0
		end
		resources.count = resourcecount

		if isunbundleammo then
			local playership = C.GetPlayerOccupiedShipID()
			if playership ~= 0 then
				craftableamount = AddAmmo(ConvertStringTo64Bit(tostring(playership)), component, craftableamount, true)
			end
		end
		waredata.craftable = craftableamount

		table.insert(menu.craftable[groupID], { ware = ware, data = waredata, resources = resources })
	end
end

init()
