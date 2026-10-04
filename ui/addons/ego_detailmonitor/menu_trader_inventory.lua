-- param == { 0, 0, traderentity, warelist, islockbox, consolecomponent, consoleconnectionname }

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef uint64_t UniverseID;
	void AddPlayerMoney(int64_t money);
	uint32_t GetNumWares(const char* tags, bool research, const char* licenceownerid, const char* exclusiontags);
	UniverseID GetPlayerComputerID(void);
	uint32_t GetWares(const char** result, uint32_t resultlen, const char* tags, bool research, const char* licenceownerid, const char* exclusiontags);
	bool IsWillingToBuyFromPlayer(UniverseID componentid, const char* warename);
	bool IsWillingToSellToPlayer(UniverseID componentid, const char* warename);
	bool TriggerCompSlotAnimation(UniverseID componentid, const char* connectionname, const char* triggername);
]]

-- menu variable - used by Helper and used for dynamic variables (e.g. inventory content, etc.)
local menu = {
	name = "InventoryTraderMenu"
}

-- config variable - put all static setup here
--[[
local config = {
}
]]

-- init menu and register with Helper
local function init()
	Menus = Menus or { }
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end
end

-- cleanup variables in menu, no need for the menu variable to keep all the data while the menu is not active
function menu.cleanup()
	if menu.console and next(menu.console) then
		C.TriggerCompSlotAnimation(ConvertIDTo64Bit(menu.console.component), menu.console.connectionname, "deactivate")
	end
	menu.console = {}

	menu.playermoney = nil
	menu.totalprice = nil

	--menu.commissions = {}
	--menu.discounts = {}
	menu.onplatform = nil
	menu.policefaction = nil
	menu.playerinventory = {}
	menu.traderinventory = {}
	--menu.totalcommission = nil
	--menu.totaldiscount = nil
	menu.shipmentfee = nil

	menu.tradecontainer = nil
	menu.tradedetails = {}
	menu.tradewares = {}
	menu.warecategories = {}
	menu.traderfaction = nil
	menu.trader = nil
	menu.islockbox = nil

	menu.title = nil

	menu.table_top = {}

	menu.queueupdate = nil
	menu.resetrow = nil
	menu.selectedrow = nil
	menu.toprow = nil

	menu.frame = nil
end

function menu.onShowMenu()
	menu.trader = C.GetPlayerComputerID()
	if menu.param[3] then
		menu.trader = ConvertIDTo64Bit(menu.param[3])
	end
	menu.traderfaction = GetComponentData(menu.trader, "owner")
	menu.tradecontainer = GetContextByClass(menu.trader, "container", false)
	menu.onplatform = IsSameComponent(GetContextByClass(menu.trader, "container", false), GetPlayerContextByClass("container"))
	menu.policefaction = GetComponentData(GetComponentData(menu.trader, "zoneid"), "policefaction")
	menu.waresinstock = menu.param[4]
	menu.selectedware = nil
	menu.islockbox = (menu.param[5] and menu.param[5] ~= 0)
	if menu.param[6] and menu.param[7] then
		menu.console = { component = menu.param[6], connectionname = menu.param[7] }
		C.TriggerCompSlotAnimation(ConvertIDTo64Bit(menu.console.component), menu.console.connectionname, "activate")
	end

	menu.title = menu.islockbox and ReadText(20109, 9001) or ReadText(1001, 2434)		-- Safe Deposit Storage, Inventory Items
	menu.skiprowchange = nil

	menu.tradedetails = {}
	menu.table_top = {}

	menu.initData()

	-- add content
	menu.display()
end

function menu.onShowMenuSound()
	-- no sound
end

function menu.findWare(ware)
	for i, data in ipairs(menu.tradewares) do
		if data.ware == ware then
			return i
		end
	end
end

function menu.initData()
	menu.playerinventory = GetPlayerInventory()
	menu.traderinventory = GetInventory(menu.trader)
	menu.tradedetails = {}
	menu.tradewares = {}
	menu.totalprice = 0

	-- iscraftingresource, ismodpart, isprimarymodpart
	local craftingwares = {}
	-- ispersonalupgrade
	local upgradewares = {}
	-- tradeonly
	local tradeonlywares = {}
	-- paintmods
	local paintmodwares = {}
	-- else
	local usefulwares = {}

	menu.warecategories = {}

	if menu.islockbox then
		for ware in pairs(menu.playerinventory) do
			local name, avgprice, isbraneitem = GetWareData(ware, "name", "avgprice", "isbraneitem")
			if not isbraneitem then
				table.insert(menu.tradewares, { ware = ware, name = name, price = avgprice })
				menu.tradedetails[ware] = 0
			end
		end
		for ware in pairs(menu.traderinventory) do
			if not menu.tradedetails[ware] then
				local name, avgprice = GetWareData(ware, "name", "avgprice")
				table.insert(menu.tradewares, { ware = ware, name = name, price = avgprice })
				menu.tradedetails[ware] = 0
			end
		end
	else
		-- menu.waresinstock are the wares that this particular trader is interested in trading in. defined in md.NPC_Itemtrader.OnPlatformPopulation_Itemtrader
		for _, waredata in ipairs(menu.waresinstock) do
			local locware = waredata[1]
			--local locprice = menu.traderinventory[locware] and menu.traderinventory[locware].price or GetWareData(locware, "maxprice")
			local locprice = waredata[2]
			local i = menu.findWare(locware)
			if not i then
				if menu.traderinventory[locware] or menu.playerinventory[locware] then
					table.insert(menu.tradewares, { ware = locware, name = GetWareData(locware, "name"), price = locprice })
					menu.tradedetails[locware] = 0
				end
			end
		end
	end
	table.sort(menu.tradewares, Helper.sortName)

	for _, waredata in ipairs(menu.tradewares) do
		local locware = waredata.ware
		local iscraftingresource, ismodpart, isprimarymodpart, ispersonalupgrade, tradeonly, ispaintmod = GetWareData(locware, "iscraftingresource", "ismodpart", "isprimarymodpart", "ispersonalupgrade", "tradeonly", "ispaintmod")
		if iscraftingresource or ismodpart or isprimarymodpart then
			table.insert(craftingwares, locware)
		elseif ispersonalupgrade then
			table.insert(upgradewares, locware)
		elseif tradeonly then
			table.insert(tradeonlywares, locware)
		elseif ispaintmod then
			table.insert(paintmodwares, locware)
		else
			table.insert(usefulwares, locware)
		end
	end
	-- NB: the order in which the categories appear in the menu is defined here
	if #craftingwares > 0 then
		table.insert(menu.warecategories, { name = ReadText(1001, 2827), id = "craftingwares", wares = craftingwares })	-- Crafting Wares
	end
	if #upgradewares > 0 then
		table.insert(menu.warecategories, { name = ReadText(1001, 7716), id = "upgradewares", wares = upgradewares })	-- Spacesuit Upgrades
	end
	if #paintmodwares > 0 then
		table.insert(menu.warecategories, { name = ReadText(1001, 8510), id = "paintmodwares", wares = paintmodwares})	-- Trade Wares
	end
	if #usefulwares > 0 then
		table.insert(menu.warecategories, { name = ReadText(1001, 2828), id = "generalwares", wares = usefulwares })	-- General Wares
	end
	if #tradeonlywares > 0 then
		table.insert(menu.warecategories, { name = ReadText(1001, 2829), id = "tradeonlywares", wares = tradeonlywares})	-- Trade Wares
	end
	--[[
	local numwares = C.GetNumWares("inventory", false, nil, "")
	local wares = ffi.new("const char*[?]", numwares)
	numwares = C.GetWares(wares, numwares, "inventory", false, nil, "")
	for i = 0, numwares-1 do
		local locware = ffi.string(wares[i])
		local locprice = 0
		--local locprice = GetWareData(locware, "avgprice")
		if not menu.tradewares[locware] then
			if menu.traderinventory[locware] then
				locprice = menu.traderinventory[locware].price
			elseif menu.playerinventory[locware] then
				-- if trader doesn't have it and the player has it, buy for max price. otherwise we could have situations where the trader having 1 of an item would make an item more valuable than the trader having none of an item.
				-- unless we interpret the trader's not having any of something as that trader not being interested.
				-- also, TODO: review. since trade price will adjust depending on supply, wouldn't it be profitable to simply buy all items of a type a trader has, then simply sell it all back?
				locprice = GetWareData(locware, "maxprice")
			end

			-- if an item is neither in the trader's inventory nor the player's, we cannot trade it so don't list it.
			if locprice ~= 0 then
				menu.tradewares[locware] = { name = GetWareData(locware, "name"), price = locprice }
			else
				--print(tostring(locware) .. " is in the inventory of neither the player nor the trader.")
			end
		end
	end
	--]]
	menu.discounts = GetComponentData(menu.tradecontainer, "traderdiscounts")
	menu.discounts.totalfactor = 1
	for _, entry in ipairs(menu.discounts) do
		menu.discounts.totalfactor = menu.discounts.totalfactor - entry.amount / 100
	end
	menu.commissions = GetComponentData(menu.tradecontainer, "tradercommissions")
	menu.commissions.totalfactor = 1
	for _, entry in ipairs(menu.commissions) do
		menu.commissions.totalfactor = menu.commissions.totalfactor + entry.amount / 100
	end
end

function menu.display()
	Helper.removeAllWidgetScripts(menu)

	menu.skiprowchange = true
	menu.playermoney = GetPlayerMoney()

	local width = Helper.viewWidth / 2
	local height = Helper.viewHeight / 2
	local xoffset = width / 2
	local yoffset = height / 2

	menu.frame = Helper.createFrameHandle(menu, { width = width + 2 * Helper.borderSize, height = height + 2 * Helper.borderSize, x = xoffset - Helper.borderSize, y = yoffset - Helper.borderSize })
	menu.frame:setBackground("solid", { color = Color["frame_background_semitransparent"] })
	local table_bottom, row

	-- we need table_bottom first because we need the y offset of table_bottom to figure out the height of table_top
	table_bottom = menu.frame:addTable(2, { width = width / 2 - Helper.borderSize, x = width / 2 + 2 * Helper.borderSize, tabOrder = 3 })

	if menu.islockbox then
		for i = 1, 4 do
			local row = table_bottom:addRow(false, { fixed = true })
			row[1]:createText("")
		end
	else
		local row = table_bottom:addRow(false, {fixed = true})
		row[1]:setColSpan(2):createText(ReadText(1001, 2006), Helper.subHeaderTextProperties)		-- Transaction Details
		row[1].properties.halign = "center"

		local row = table_bottom:addRow(false, {fixed = true})
		row[1]:createText((ReadText(1001, 2005) .. ReadText(1001, 120)))		-- Transaction Value:
		row[2]:createText(function() return (ConvertMoneyString(tostring(-menu.totalprice), false, true, nil, true) .. " " .. ReadText(1001, 101)) end, {halign = "right"})
		row[2].properties.color = function() return menu.totalprice < 0 and Color["text_positive"] or (menu.totalprice > 0 and Color["text_negative"] or Color["text_normal"]) end

		local row = table_bottom:addRow(false, {fixed = true})
		row[1]:createText((ReadText(1001, 2003) .. ReadText(1001, 120)))		-- Current Balance
		row[2]:createText(function() return (ConvertMoneyString(tostring(GetPlayerMoney()), false, true, nil, true) .. " " .. ReadText(1001, 101)) end, {halign = "right"})

		local row = table_bottom:addRow(false, {fixed = true})
		row[1]:createText((ReadText(1001, 2004) .. ReadText(1001, 120)))		-- Final Balance
		row[2]:createText(function() return (ConvertMoneyString(tostring(GetPlayerMoney() - menu.totalprice), false, true, nil, true) .. " " .. ReadText(1001, 101)) end, {halign = "right"})
	end

	local row = table_bottom:addRow("buttonrow", { fixed = true })
	row[1]:createButton({ active = function() return menu.totalprice ~= 0 end })
	row[1]:setText(ReadText(1001, 2821), {halign = "center"})		-- Confirm
	row[1].handlers.onClick = function() return menu.buttonConfirm() end
	row[2]:createButton({ active = true, helpOverlayID = "tradermenu_cancel", helpOverlayText = " ", helpOverlayHighlightOnly = true })
	--row[2]:createButton({ active = function() return menu.totalprice ~= 0 end })
	row[2]:setText(ReadText(1001, 64), {halign = "center"})		-- Cancel
	row[2].handlers.onClick = function() return menu.buttonCancel() end

	menu.table_top = menu.frame:addTable(5, { tabOrder = 1, x = Helper.borderSize, y = Helper.borderSize, width = width })
	menu.table_top:setColWidthPercent(2, 15)
	menu.table_top:setColWidthPercent(3, 10)
	menu.table_top:setColWidthPercent(4, 25)
	menu.table_top:setColWidthPercent(5, 10)

	-- standard header
	row = menu.table_top:addRow(false, {fixed = true, bgColor = Color["row_title_background"]})
	row[1]:setColSpan(5):createText(menu.title, Helper.titleTextProperties)

	row = menu.table_top:addRow(false, { fixed = true, bgColor = Color["row_background_unselectable"] })
	row[1]:setBackgroundColSpan(5):createText(ReadText(1001, 45), { font = Helper.standardFontBold })		-- Ware
	row[2]:createText(menu.islockbox and ReadText(1001, 2980) or ReadText(1001, 2808), { font = Helper.standardFontBold, halign = "center" })		-- Average Price, Price
	row[3]:createText(ReadText(1001, 2202), { font = Helper.standardFontBold, halign = "center" })		-- Inventory
	row[5]:createText(menu.islockbox and ReadText(1001, 1400) or ReadText(20208, 40101), { font = Helper.standardFontBold, halign = "center" })		-- Trader

	row = menu.table_top:addRow(false, { fixed = true, bgColor = Color["row_separator"] })
	row[1]:setColSpan(5):createText("", { height = 1 })

	local pricemouseover = ""
	if #menu.discounts > 0 then
		if pricemouseover ~= "" then
			pricemouseover = pricemouseover .. "\n\n"
		end
		pricemouseover = pricemouseover .. ReadText(1001, 2819) .. ReadText(1001, 120)
		for _, entry in ipairs(menu.discounts) do
			pricemouseover = pricemouseover .. "\n· " .. entry.name .. ReadText(1001, 120) .. " " .. entry.amount .. " %"
		end
	end
	if #menu.commissions > 0 then
		if pricemouseover ~= "" then
			pricemouseover = pricemouseover .. "\n\n"
		end
		pricemouseover = pricemouseover .. ReadText(1001, 2820) .. ReadText(1001, 120)
		for _, entry in ipairs(menu.commissions) do
			pricemouseover = pricemouseover .. "\n· " .. entry.name .. ReadText(1001, 120) .. " " .. entry.amount .. " %"
		end
	end

	for i, category in ipairs(menu.warecategories) do
		-- category header
		local row = menu.table_top:addRow(false, {  })
		row[1]:setColSpan(5):createText(category.name, Helper.subHeaderTextProperties)
		row[1].properties.halign = "center"

		for _, ware in ipairs(category.wares) do
			local wareindex = menu.findWare(ware)
			local waredata = menu.tradewares[wareindex]
			if (not menu.selectedware) then
				menu.selectedware = waredata.ware
			end
			
			local startamount = 0
			local pricefactor = 1
			local transactionprice = 0
			if menu.tradedetails[waredata.ware] then
				startamount = menu.tradedetails[waredata.ware]
			end

			row = menu.table_top:addRow(waredata.ware, {})
			row[1]:createText(waredata.name, { color = (menu.policefaction and IsWareIllegalTo(waredata.ware, "player", menu.policefaction)) and Color["text_illegal"] or Color["text_normal"] })
			if menu.islockbox then
				row[2]:createText((ConvertMoneyString(tostring(waredata.price), false, true, nil, true) .. " " .. ReadText(1001, 101)), { halign = "right" })
			else
				if startamount > 0 then
					pricefactor = menu.discounts.totalfactor
				elseif startamount < 0 then
					pricefactor = menu.commissions.totalfactor
				end
				row[2]:createText((ConvertMoneyString(tostring(waredata.price * pricefactor), false, true, nil, true) .. " " .. ReadText(1001, 101)), { halign = "right", mouseOverText = pricemouseover, color = Helper.interpolatePriceColor(waredata.ware, waredata.price * pricefactor, startamount > 0) })
			end
			row[3]:createText((menu.playerinventory[waredata.ware] and menu.playerinventory[waredata.ware].amount or 0) + menu.tradedetails[waredata.ware], { halign = "right" })
			row[5]:createText((menu.traderinventory[waredata.ware] and menu.traderinventory[waredata.ware].amount or 0) - menu.tradedetails[waredata.ware], { halign = "right" })
			local traderamount = 0
			local playeramount = 0
			if menu.traderinventory[waredata.ware] then
				traderamount = menu.traderinventory[waredata.ware].amount
			end
			if menu.playerinventory[waredata.ware] then
				playeramount = math.max(0, menu.playerinventory[waredata.ware].amount)
			end
			if menu.tradedetails[waredata.ware] then
				transactionprice = startamount * math.max(waredata.price * pricefactor, 1)
			end
			local maxSelect = math.max(traderamount, startamount)
			if not menu.islockbox then
				maxSelect = math.floor(math.max(math.min((menu.playermoney - menu.totalprice + transactionprice) / math.max(waredata.price * pricefactor, 1), traderamount), startamount))
			end
			if not C.IsWillingToSellToPlayer(menu.trader, waredata.ware) then
				maxSelect = 0
			end
			if (category.id == "upgradewares") and GetWareData(ware, "isequipment") then
				if playeramount == 0 then
					maxSelect = math.min(1, maxSelect)
				else
					maxSelect = 0
				end
			end
			local minSelect = min
			local mouseovertext = ""
			local allowdrop, ispaintmod = GetWareData(ware, "allowdrop", "ispaintmod")
			-- sic! We discussed on 2025-05-06 that personal upgrades should be able to be stored manually (but not selected then using deposit all)
			if ((not allowdrop) and (category.id ~= "upgradewares")) or (not C.IsWillingToBuyFromPlayer(menu.trader, waredata.ware)) then
				mouseovertext = allowdrop and ReadText(1026, 2807) or ""
				minSelect = 0
			end
			row[4]:createSliderCell({ start = math.min(startamount, maxSelect), min = -playeramount, minSelect = minSelect, max = traderamount, maxSelect = maxSelect, fromCenter = true, rightToLeft = true, mouseOverText = mouseovertext, height = Helper.standardTextHeight })
			row[4].handlers.onSliderCellChanged = function(_, newamount) return menu.updateTradeData(waredata.ware, newamount) end
			row[4].handlers.onSliderCellConfirm = function() menu.refreshMenu() end

			if ispaintmod then
				AddKnownItem("paintmods", ware)
			else
				AddKnownItem("inventory_wares", ware)
			end
		end

		if i < #menu.warecategories then
			row = menu.table_top:addRow(false, {  })
			row[1]:setColSpan(5):createText("")
		end
	end

	if menu.selectedrow then
		menu.table_top:setSelectedRow(menu.selectedrow)
		menu.selectedrow = nil
		if menu.toprow then
			menu.table_top:setTopRow(menu.toprow)
			menu.toprow = nil
		end
	end

	local table_desc = menu.frame:addTable(1, { width = width / 2, x = Helper.borderSize, tabOrder = 3, highlightMode = "off", skipTabChange = true })

	local row = table_desc:addRow(false, { fixed = true })
	row[1]:createText(ReadText(1001, 2404), Helper.subHeaderTextProperties)
	row[1].properties.halign = "center"

	local text = menu.selectedware and GetWareData(menu.selectedware, "description") or ""
	local textwidth = width / 2 - 2 * Helper.standardTextOffsetx
	local description = GetTextLines(text, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), textwidth)
	if #description > 4 then
		description = GetTextLines(text, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), textwidth - Helper.scrollbarWidth)
	end
	for i, line in ipairs(description) do
		local row = table_desc:addRow(true, {  })
		row[1]:createText(line)
		if i == 4 then
			table_desc.properties.maxVisibleHeight = table_desc:getFullHeight()
		end
	end

	local table_footer
	if menu.islockbox then
		table_footer = menu.frame:addTable(4, { width = width, x = Helper.borderSize, tabOrder = 2 })
		table_footer:setColWidth(1, width / 2, false)
		table_footer:setColWidth(3, Helper.standardButtonHeight)

		local row = table_footer:addRow(false, { fixed = true, bgColor = Color["row_separator"] })
		row[1]:setColSpan(4):createText("", { height = 1 })

		local row = table_footer:addRow("transferall", { fixed = true })
		row[1]:createText(ReadText(1001, 2012))
		row[2]:createButton({ active = menu.buttonRetrieveAllActive }):setText("\27[widget_arrow_skip_left_01] " .. ReadText(1001, 2011))
		row[2].handlers.onClick = menu.buttonRetrieveAll
		row[3]:createButton({ active = menu.buttonResetAllActive }):setIcon("menu_reset")
		row[3].handlers.onClick = menu.buttonResetAll
		row[4]:createButton({ active = menu.buttonDepositAllActive }):setText(ReadText(1001, 2010) .. " \27[widget_arrow_skip_right_01]", { halign = "right" })
		row[4].handlers.onClick = menu.buttonDepositAll
	end

	local yoffset = math.max(table_bottom:getVisibleHeight(), table_desc:getVisibleHeight())
	table_bottom.properties.y = height - yoffset
	table_desc.properties.y = height - yoffset
	local maxVisibleHeight = table_desc.properties.y

	if table_footer then
		yoffset = yoffset + table_footer:getVisibleHeight()
		table_footer.properties.y = height - yoffset
		maxVisibleHeight = table_footer.properties.y
	end

	menu.table_top.properties.maxVisibleHeight = maxVisibleHeight - Helper.borderSize

	menu.table_top:addConnection(1, 1, true)
	if table_footer then
		table_footer:addConnection(2, 1)
	end
	table_bottom:addConnection(table_footer and 3 or 2, 1)

	menu.frame:display()
end

-- widget scripts
function menu.buttonConfirm()
	if not menu.islockbox then
		if not GetComponentData(menu.tradecontainer, "isplayerowned") then
			if menu.totalprice > 0 then
				--print("losing " .. menu.totalprice)
				TransferPlayerMoneyTo(menu.totalprice, menu.tradecontainer)
			else
				--print("getting " .. -menu.totalprice)
				TransferMoneyToPlayer(-menu.totalprice, menu.tradecontainer)
			end
		else
			--print("transferring " .. -menu.totalprice .. " to player account. old amount: " .. GetPlayerMoney() .. " new amount should be: " .. (GetPlayerMoney() - menu.totalprice))
			C.AddPlayerMoney(-menu.totalprice * 100)
			--print("transferred. new amount: " .. GetPlayerMoney())
		end
	end

	-- switch section below with commented-out section below that if we decide to get transport drones working.
	for ware, amount in pairs(menu.tradedetails) do
		if amount > 0 then
			TransferInventoryToPlayer(ware, amount, menu.trader)
		elseif amount < 0 then
			TransferPlayerInventoryTo(ware, -amount, menu.trader)
		end
	end
	--[[
	if menu.onplatform then
		for ware, amount in pairs(menu.tradedetails) do
			if amount > 0 then
				TransferInventoryToPlayer(ware, amount, menu.trader)
			elseif amount < 0 then
				TransferPlayerInventoryTo(ware, -amount, menu.trader)
			end
		end
	else
		local buyorders = {}
		local sellorders = {}
		for ware, amount in pairs(menu.tradedetails) do
			if amount > 0 then
				table.insert(buyorders, {ware, amount})
			elseif amount < 0 then
				table.insert(sellorders, {ware, -amount})
			end
		end
		if next(buyorders) then
			SendTransportDrone(menu.trader, nil, "inventory", buyorders)
		end
		if next(sellorders) then
			SendTransportDrone(nil, menu.trader, "inventory", sellorders)
		end
	end
	]]

	SetNPCBlackboard(menu.trader, "$TradeDone", true)
	-- activate this and remove Helper.closeMenuAndReturn() and menu.cleanup if we later decide to keep the menu open.
	--[[
	menu.initData()
	menu.tallyTotalPrice()
	-- NB: we only need to refresh the menu here because we cannot set button.properties.active to a function and run those functions upon frame:update()
	menu.queueupdate = true
	--]]
	---[[
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
	--]]
	--menu.frame:update()
end

function menu.buttonCancel()
	-- activate this and remove Helper.closeMenuAndReturn() and menu.cleanup if we later decide to keep the menu open.
	--[[
	menu.initData()
	--menu.tradedetails = {}
	menu.tallyTotalPrice()
	-- NB: we only need to refresh the menu here because we cannot set button.properties.active to a function and run those functions upon frame:update()
	menu.resetrow = true
	menu.queueupdate = true
	--]]
	---[[
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
	--]]
	--menu.frame:update()
end

function menu.buttonRetrieveAllActive()
	for i, category in ipairs(menu.warecategories) do
		if (category.id ~= "upgradewares") and (category.id ~= "paintmodwares") then
			for _, ware in ipairs(category.wares) do
				if C.IsWillingToSellToPlayer(menu.trader, ware) then
					if menu.tradedetails[ware] < (menu.traderinventory[ware] and menu.traderinventory[ware].amount or 0) then
						return true
					end
				end
			end
		end
	end
	return false
end

function menu.buttonRetrieveAll()
	for i, category in ipairs(menu.warecategories) do
		if (category.id ~= "upgradewares") and (category.id ~= "paintmodwares") then
			for _, ware in ipairs(category.wares) do
				if C.IsWillingToSellToPlayer(menu.trader, ware) then
					menu.tradedetails[ware] = menu.traderinventory[ware] and menu.traderinventory[ware].amount or 0
				end
			end
		end
	end

	menu.tallyTotalPrice()
	menu.refreshMenu()
end

function menu.buttonDepositAllActive()
	for i, category in ipairs(menu.warecategories) do
		if (category.id ~= "upgradewares") and (category.id ~= "paintmodwares") then
			for _, ware in ipairs(category.wares) do
				local allowdrop = GetWareData(ware, "allowdrop")
				if allowdrop and C.IsWillingToBuyFromPlayer(menu.trader, ware) then
					if menu.tradedetails[ware] > -math.max(0, menu.playerinventory[ware] and menu.playerinventory[ware].amount or 0) then
						return true
					end
				end
			end
		end
	end
	return false
end

function menu.buttonDepositAll()
	for i, category in ipairs(menu.warecategories) do
		if (category.id ~= "upgradewares") and (category.id ~= "paintmodwares") then
			for _, ware in ipairs(category.wares) do
				local allowdrop = GetWareData(ware, "allowdrop")
				if allowdrop and C.IsWillingToBuyFromPlayer(menu.trader, ware) then
					menu.tradedetails[ware] = -math.max(0, menu.playerinventory[ware] and menu.playerinventory[ware].amount or 0)
				end
			end
		end
	end

	menu.tallyTotalPrice()
	menu.refreshMenu()
end

function menu.buttonResetAllActive()
	for i, category in ipairs(menu.warecategories) do
		for _, ware in ipairs(category.wares) do
			if menu.tradedetails[ware] ~= 0 then
				return true
			end
		end
	end
	return false
end

function menu.buttonResetAll()
	for i, category in ipairs(menu.warecategories) do
		for _, ware in ipairs(category.wares) do
			menu.tradedetails[ware] = 0
		end
	end

	menu.tallyTotalPrice()
	menu.refreshMenu()
end

-- helper functions
function menu.updateTradeData(ware, newamount)
	newamount = math.floor(newamount)
	menu.tradedetails[ware] = newamount
	--if menu.tradedetails[ware] > 0 then
	--	print("buying " .. menu.tradedetails[ware] .. " " .. GetWareData(ware, "name"))
	--else
	--	print("selling " .. -menu.tradedetails[ware] .. " " .. GetWareData(ware, "name"))
	--end
	menu.tallyTotalPrice()
end

function menu.tallyTotalPrice()
	menu.totalprice = 0
	for ware, amount in pairs(menu.tradedetails) do
		local i = menu.findWare(ware)
		if i then
			local pricefactor = 1
			if amount > 0 then
				pricefactor = menu.discounts.totalfactor
			elseif amount < 0 then
				pricefactor = menu.commissions.totalfactor
			end
			menu.totalprice = menu.totalprice + (amount * menu.tradewares[i].price * pricefactor)
		else
			DebugError("Trying to trade ware but could not find ware. Something is wrong. [Florian]")
		end
	end
end

function menu.onSliderCellDown()
	menu.lock = true
end

menu.updateInterval = 0.1

function menu.onUpdate()
	if menu.queueupdate then
		menu.refreshMenu()
	end
	--menu.frame:update()
end

function menu.refreshMenu()
	menu.lock = nil
	menu.queueupdate = nil
	if not menu.resetrow then
		menu.toprow = GetTopRow(menu.table_top.id)
		menu.selectedrow = Helper.currentTableRow[menu.table_top.id]
	end
	menu.resetrow = nil
	menu.display()
end

function menu.onRowChanged(row, rowdata, uitable)
	if uitable == menu.table_top.id then
		menu.selectedware = rowdata
		if (not menu.skiprowchange) and (not menu.lock) then
			menu.queueupdate = true
		end
		menu.skiprowchange = nil
	end
end

function menu.onCloseElement(dueToClose)
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
end

init()
