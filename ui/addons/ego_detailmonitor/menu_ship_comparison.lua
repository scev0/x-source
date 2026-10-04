-- param == { 0, 0 }

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef uint64_t UniverseID;
	typedef struct {
		const char* macro;
		uint32_t amount;
		bool optional;
	} UILoadoutAmmoData;
	typedef struct {
		const char* macro;
		const char* path;
		const char* group;
		uint32_t count;
		bool optional;
	} UILoadoutGroupData;
	typedef struct {
		const char* macro;
		const char* upgradetypename;
		size_t slot;
		bool optional;
	} UILoadoutMacroData;
	typedef struct {
		const char* ware;
	} UILoadoutSoftwareData;
	typedef struct {
		const char* macro;
		bool optional;
	} UILoadoutVirtualMacroData;
	typedef struct {
		UILoadoutMacroData* weapons;
		uint32_t numweapons;
		UILoadoutMacroData* turrets;
		uint32_t numturrets;
		UILoadoutMacroData* shields;
		uint32_t numshields;
		UILoadoutMacroData* engines;
		uint32_t numengines;
		UILoadoutGroupData* turretgroups;
		uint32_t numturretgroups;
		UILoadoutGroupData* shieldgroups;
		uint32_t numshieldgroups;
		UILoadoutAmmoData* ammo;
		uint32_t numammo;
		UILoadoutAmmoData* units;
		uint32_t numunits;
		UILoadoutSoftwareData* software;
		uint32_t numsoftware;
		UILoadoutVirtualMacroData thruster;
	} UILoadout;
	typedef struct {
		float HullValue;
		float ShieldValue;
		double ShieldDelay;
		float ShieldRate;
		float GroupedShieldValue;
		double GroupedShieldDelay;
		float GroupedShieldRate;
		float BurstDPS;
		float SustainedDPS;
		float TurretBurstDPS;
		float TurretSustainedDPS;
		float GroupedTurretBurstDPS;
		float GroupedTurretSustainedDPS;
		float ForwardSpeed;
		float BoostSpeed;
		float TravelSpeed;
		float YawSpeed;
		float PitchSpeed;
		float RollSpeed;
		float HorizontalStrafeSpeed;
		float VerticalStrafeSpeed;
		float ForwardAcceleration;
		float HorizontalStrafeAcceleration;
		float VerticalStrafeAcceleration;
		float BoostAcceleration;
		float BoostRechargeRate;
		float BoostMaxDuration;
		float TravelAcceleration;
		float TravelChargeTime;
		uint32_t NumDocksShipMedium;
		uint32_t NumDocksShipSmall;
		uint32_t ShipCapacityMedium;
		uint32_t ShipCapacitySmall;
		uint32_t CrewCapacity;
		uint32_t ContainerCapacity;
		uint32_t SolidCapacity;
		uint32_t LiquidCapacity;
		uint32_t CondensateCapacity;
		uint32_t UnitCapacity;
		uint32_t MissileCapacity;
		uint32_t CountermeasureCapacity;
		uint32_t DeployableCapacity;
		float RadarRange;
	} UILoadoutStatistics5;
	UILoadoutStatistics5 GetLoadoutStatistics5(UniverseID shipid, const char* macroname, UILoadout uiloadout);
	UILoadoutStatistics5 GetMaxLoadoutStatistics5(UniverseID shipid, const char* macroname);
]]

local menu = {
	name = "ShipComparisonMenu",
	encyclopediaMode = "shipcomparison",
}

local config = {
	leftBar = {
		[1] = { name = ReadText(1001, 2400),	icon = "tlt_encyclopedia",	mode = "encyclopedia" },
		[2] = { name = ReadText(1001, 8201),	icon = "ency_timeline_01",	mode = "timeline" },
		[3] = { name = ReadText(1001, 3700),	icon = "ency_ship_comparison_01",	mode = "shipcomparison" },
	},
	stats = {
		{ id = "HullValue",						name = ReadText(1001, 8048),			unit = ReadText(1001, 118),	type = "float",		accuracy = 0 },
		{ id = "ShieldValue",					name = ReadText(1001, 8049),			unit = ReadText(1001, 118),	type = "float",		accuracy = 0 },
		{ id = "ShieldRate",					name = "   " .. ReadText(1001, 8553),	unit = ReadText(1001, 119),	type = "float",		accuracy = 0 },
		{ id = "ShieldDelay",					name = "   " .. ReadText(1001, 8554),	unit = ReadText(1001, 100),	type = "double",	accuracy = 2,	inverted = true },
		{ id = "GroupedShieldValue",			name = ReadText(1001, 8533),			unit = ReadText(1001, 118),	type = "float",		accuracy = 0,	mouseovertext = ReadText(1026, 8018) },
		{ id = "GroupedShieldRate",				name = "   " .. ReadText(1001, 8553),	unit = ReadText(1001, 119),	type = "float",		accuracy = 0 },
		{ id = "GroupedShieldDelay",			name = "   " .. ReadText(1001, 8554),	unit = ReadText(1001, 100),	type = "double",	accuracy = 2,	inverted = true },
		{ id = "RadarRange",					name = ReadText(1001, 8068),			unit = ReadText(1001, 108),	type = "float",		accuracy = 0 },
		{ id = "BurstDPS",						name = ReadText(1001, 8073),			unit = ReadText(1001, 119),	type = "float",		accuracy = 0 },
		{ id = "SustainedDPS",					name = ReadText(1001, 8074),			unit = ReadText(1001, 119),	type = "float",		accuracy = 0 },
		{ id = "TurretSustainedDPS",			name = ReadText(1001, 8532),			unit = ReadText(1001, 119),	type = "float",		accuracy = 0,	mouseovertext = ReadText(1026, 8017),	capshipid = "GroupedTurretSustainedDPS" },
		{ id = "" },
		{ id = "ForwardSpeed",					name = ReadText(1001, 8051),			unit = ReadText(1001, 113),	type = "float",		accuracy = 0 },
		{ id = "ForwardAcceleration",			name = "   " .. ReadText(1001, 8069),	unit = ReadText(1001, 111),	type = "float",		accuracy = 0 },
		{ id = "BoostSpeed",					name = ReadText(1001, 8052),			unit = ReadText(1001, 113),	type = "float",		accuracy = 0 },
		{ id = "BoostAcceleration",				name = "   " .. ReadText(1001, 8590),	unit = ReadText(1001, 111),	type = "float",		accuracy = 0 },
		{ id = "BoostMaxDuration",				name = "   " .. ReadText(1001, 8592),	unit = ReadText(1001, 100),	type = "float",		accuracy = 1 },
		{ id = "BoostRechargeRate",				name = "   " .. ReadText(1001, 8591),	unit = ReadText(1001, 125),	type = "float",		accuracy = 1 },
		{ id = "TravelSpeed",					name = ReadText(1001, 8053),			unit = ReadText(1001, 113),	type = "float",		accuracy = 0 },
		{ id = "TravelAcceleration",			name = "   " .. ReadText(1001, 8593),	unit = ReadText(1001, 111),	type = "float",		accuracy = 0 },
		{ id = "TravelChargeTime",				name = "   " .. ReadText(1001, 8594),	unit = ReadText(1001, 100),	type = "float",		accuracy = 1,	inverted = true },
		{ id = "HorizontalStrafeSpeed",			name = ReadText(1001, 8559),			unit = ReadText(1001, 113),	type = "float",		accuracy = 1 },
		{ id = "HorizontalStrafeAcceleration",	name = "   " .. ReadText(1001, 8560),	unit = ReadText(1001, 111),	type = "float",		accuracy = 1 },
		{ id = "YawSpeed",						name = ReadText(1001, 8054),			unit = ReadText(1001, 117),	type = "float",		accuracy = 1 },
		{ id = "PitchSpeed",					name = ReadText(1001, 8055),			unit = ReadText(1001, 117),	type = "float",		accuracy = 1 },
		{ id = "RollSpeed",						name = ReadText(1001, 8056),			unit = ReadText(1001, 117),	type = "float",		accuracy = 1 },
		{ id = "" },
		{ id = "ContainerCapacity",				name = ReadText(1001, 8058),			unit = ReadText(1001, 110),	type = "UINT",		accuracy = 0 },
		{ id = "SolidCapacity",					name = ReadText(1001, 8059),			unit = ReadText(1001, 110),	type = "UINT",		accuracy = 0 },
		{ id = "LiquidCapacity",				name = ReadText(1001, 8060),			unit = ReadText(1001, 110),	type = "UINT",		accuracy = 0 },
		{ id = "CondensateCapacity",			name = ReadText(20109, 9801),			unit = ReadText(1001, 110),	type = "UINT",		accuracy = 0 },
		{ id = "" },
		{ id = "NumDocksShipMedium",			name = ReadText(1001, 8524),			unit = "",					type = "UINT",		accuracy = 0 },
		{ id = "ShipCapacityMedium",			name = ReadText(1001, 8526),			unit = "",					type = "UINT",		accuracy = 0 },
		{ id = "NumDocksShipSmall",				name = ReadText(1001, 8525),			unit = "",					type = "UINT",		accuracy = 0 },
		{ id = "ShipCapacitySmall",				name = ReadText(1001, 8527),			unit = "",					type = "UINT",		accuracy = 0 },
		{ id = "" },
		{ id = "CrewCapacity",					name = ReadText(1001, 8057),			unit = "",					type = "UINT",		accuracy = 0 },
		{ id = "UnitCapacity",					name = ReadText(1001, 8061),			unit = "",					type = "UINT",		accuracy = 0 },
		{ id = "MissileCapacity",				name = ReadText(1001, 8062),			unit = "",					type = "UINT",		accuracy = 0 },
		{ id = "DeployableCapacity",			name = ReadText(1001, 8064),			unit = "",					type = "UINT",		accuracy = 0 },
		{ id = "CountermeasureCapacity",		name = ReadText(1001, 8063),			unit = "",					type = "UINT",		accuracy = 0 },
	},
	maxWidth = 1000,
	numberColWidth = 70,
}

local function init()
	Menus = Menus or { }
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end
end

function menu.cleanup()
	unregisterForEvent("inputModeChanged", getElement("Scene.UIContract"), menu.onInputModeChanged)

	menu.infoFrame = nil
	menu.toplevel = nil
	menu.sidebar = nil
	menu.encyclopediaMode = "shipcomparison"
end

-- widget scripts

function menu.buttonToggleEncyclopediaMode(mode)
	if mode == "timeline" then
		Helper.closeMenuAndOpenNewMenu(menu, "TimelineMenu", { 0, 0 }, true)
		menu.cleanup()
	elseif mode == "encyclopedia" then
		Helper.closeMenuAndOpenNewMenu(menu, "EncyclopediaMenu", { 0, 0 }, true)
		menu.cleanup()
	elseif mode == "shipcomparison" then
		AddUITriggeredEvent(menu.name, mode, menu.encyclopediaMode == mode and "off" or "on")
		if menu.encyclopediaMode then
			PlaySound("ui_negative_back")
			menu.encyclopediaMode = nil
		else
			menu.setdefaulttable = true
			PlaySound("ui_positive_select")
			menu.encyclopediaMode = mode
		end
		menu.refresh = true
	end
end

function menu.buttonAddShip()
	Helper.closeMenuAndOpenNewMenu(menu, "ShipConfigurationMenu", { 0, 0, nil, "comparison", { #Helper.shipComparisonData + 1 } })
	menu.cleanup()
end

function menu.buttonEditShip(id)
	Helper.closeMenuAndOpenNewMenu(menu, "ShipConfigurationMenu", { 0, 0, nil, "comparison", { id } })
	menu.cleanup()
end

function menu.buttonRemoveShip(id)
	Helper.removeShipComparison(id)
	menu.refresh = true
end

function menu.deactivateEncyclopediaMode()
	PlaySound("ui_negative_back")
	menu.encyclopediaMode = nil
	SelectRow(menu.sidebar, 3)
	menu.refresh = true
end

-- Menu member functions

function menu.onShowMenu()
	-- Init
	Helper.setTabScrollCallback(menu, menu.onTabScroll)
	registerForEvent("inputModeChanged", getElement("Scene.UIContract"), menu.onInputModeChanged)
	menu.selectedRows = {}

	AddUITriggeredEvent(menu.name, menu.encyclopediaMode)

	-- display main frame
	menu.createFrame()
end

function menu.createTopLevel(frame)
	menu.topLevelOffsetY = Helper.createTopLevelTab(menu, "encyclopedia", frame, "", nil, true)
end

function menu.onTabScroll(direction)
	if direction == "right" then
		Helper.scrollTopLevel(menu, "playerinfo", 1)
	elseif direction == "left" then
		Helper.scrollTopLevel(menu, "playerinfo", -1)
	end
end

function menu.onInputModeChanged(_, mode)
	menu.refresh = true
end

function menu.createFrame()
	-- remove old data
	Helper.clearDataForRefresh(menu, config.infoLayer)

	local frameProperties = {
		standardButtons = {},
		width = Helper.viewWidth,
		height = Helper.viewHeight,
		x = 0,
		y = 0,
		standardButtons = { back = true, close = true, help = true  }
	}
	menu.infoFrame = Helper.createFrameHandle(menu, frameProperties)
	menu.infoFrame:setBackground("solid", { color = Color["frame_background_semitransparent"] })

	menu.sidebarWidth = Helper.scaleX(Helper.sidebarWidth)

	menu.createTopLevel(menu.infoFrame)
	menu.createSideBar(menu.infoFrame)
	if menu.encyclopediaMode == "shipcomparison" then
		menu.createComparisonTable(menu.infoFrame)
	end

	menu.infoFrame:display()
end

function menu.createSideBar(frame)
	local ftable = frame:addTable(1, { tabOrder = 2, width = menu.sidebarWidth, x = Helper.frameBorder, y = menu.topLevelOffsetY + Helper.borderSize, scaling = false, borderEnabled = false, reserveScrollBar = false })

	for _, entry in ipairs(config.leftBar) do
		local mode = entry.mode
		local row = ftable:addRow(true, { fixed = true, bgColor = Color["row_background_blue"] })
		local active = true
		local bgcolor = Color["row_title_background"]
		if entry.mode == "shipcomparison" then
			bgcolor = Color["row_background_selected"]
		end
		row[1]:createButton({ active = active, height = menu.sidebarWidth, bgColor = bgcolor, mouseOverText = entry.name }):setIcon(entry.icon)
		row[1].handlers.onClick = function () return menu.buttonToggleEncyclopediaMode(mode) end
	end

	ftable:setSelectedRow(menu.selectedRows.sidebar)
	menu.selectedRows.sidebar = nil
end

function menu.createComparisonTable(frame)
	local offsetx = Helper.frameBorder + menu.sidebarWidth + Helper.borderSize
	local ftable = frame:addTable(13, { 
		tabOrder = 1,
		width = math.min(Helper.scaleX(config.maxWidth), Helper.viewWidth - offsetx),
		x = offsetx,
		y = menu.topLevelOffsetY + Helper.borderSize,
		maxVisibleHeight = Helper.viewHeight - menu.topLevelOffsetY - Helper.borderSize - Helper.frameBorder,
		highlightMode = "grey",
	})
	if menu.setdefaulttable then
		ftable.properties.defaultInteractiveObject = true
		menu.setdefaulttable = nil
	end
	
	ftable:setColWidth(1, 250)
	for i = 1, 3 do
		ftable:setColWidth(4 * i - 2, config.numberColWidth)
		ftable:setColWidth(4 * i, Helper.standardTextHeight)
		ftable:setColWidth(4 * i + 1, Helper.standardTextHeight)
		ftable:setDefaultColSpan(4 * i - 1, 3)
	end

	local row = ftable:addRow(true, { fixed = true })
	row[1]:createText("")

	for i, entry in ipairs(Helper.shipComparisonData) do
		if i < 4 then
			row[4 * i - 2]:setColSpan(2):createText(GetMacroData(entry.macro, "name"), Helper.subHeaderTextProperties)
			row[4 * i]:createButton({  }):setIcon("menu_edit")
			row[4 * i].handlers.onClick = function () return menu.buttonEditShip(i) end
			row[4 * i + 1]:createButton({  }):setText("x", { halign = "center" })
			row[4 * i + 1].handlers.onClick = function () return menu.buttonRemoveShip(i) end
		end
	end

	local numShips = #Helper.shipComparisonData
	if numShips < 3 then
		row[4 * numShips + 2]:setColSpan(4):createButton({  }):setText(ReadText(1001, 3701), { halign = "center" })
		row[4 * numShips + 2].handlers.onClick = menu.buttonAddShip
	end

	local maxstats = {}
	local shipstats = {}
	for i, entry in ipairs(Helper.shipComparisonData) do
		local ffiloadoutstats = Helper.callLoadoutFunction(entry.upgradeplan, nil, function (loadout, _) return C.GetLoadoutStatistics5(0, entry.macro, loadout) end)
		shipstats[i] = Helper.convertLoadoutStats(ffiloadoutstats)

		local ffimaxloadoutstats = C.GetMaxLoadoutStatistics5(0, entry.macro)
		local maxloadoutstats = Helper.convertLoadoutStats(ffimaxloadoutstats)
		for id, value in pairs(maxloadoutstats) do
			maxstats[id] = math.max(value, maxstats[id] or 0)
		end
	end

	for _, entry in ipairs(config.stats) do
		local row = ftable:addRow(true, {  })

		if entry.id ~= "" then
			row[1]:createText(entry.name .. ((entry.unit ~= "") and (" (" .. entry.unit .. ")") or ""), { mouseOverText = entry.mouseovertext })

			local comparestats = {}
			for i, stats in ipairs(shipstats) do
				if i < 4 then
					local iscapship = IsMacroClass(Helper.shipComparisonData[i].macro, "ship_l") or IsMacroClass(Helper.shipComparisonData[i].macro, "ship_xl")
					local id = entry.id
					if entry.capshipid ~= nil then
						id = iscapship and entry.capshipid or id
					end
					if i == 1 then
						comparestats[entry.id] = stats[id]
					end

					local color = Color["text_normal"]
					if stats[id] > comparestats[entry.id] then
						color = entry.inverted and Color["text_negative"] or Color["text_positive"]
					elseif stats[id] < comparestats[entry.id] then
						color = entry.inverted and Color["text_positive"] or Color["text_negative"]
					end
					local value
					if entry.type == "UINT" then
						value = ConvertIntegerString(Helper.round(stats[id], 0), true, 0, true, false)
					elseif (entry.type == "float") or (entry.type == "double") then
						local int, frac = math.modf(Helper.floor(stats[id], entry.accuracy))
						value = ConvertIntegerString(int, true, 0, true, false)
						if entry.accuracy > 0 then
							frac = Helper.round(math.abs(frac or 0) * (10 ^ entry.accuracy))
							value = value .. ReadText(1001, 105) .. string.format("%0".. (entry.accuracy) .."d", frac)
						end
					end
					row[4 * i - 2]:createText(value, { halign = "right", color = color })
					local posChangeColor, negChangeColor
					if entry.inverted then
						posChangeColor = Color["statusbar_diff_neg_default"]
						negChangeColor = Color["statusbar_diff_pos_default"]
					end
					row[4 * i - 1]:createStatusBar({ current = stats[id], start = comparestats[entry.id], max = maxstats[id], cellBGColor = Color["ship_stat_background"], posChangeColor = posChangeColor, negChangeColor = negChangeColor })
				end
			end
		else
			row[1]:createText("")
		end
	end

	if ftable:hasScrollBar() then
		ftable.properties.highlightMode = "grey"
	end

	ftable:setSelectedRow(menu.setrow or 1)
	if menu.toprow then
		ftable:setTopRow(menu.toprow)
	end
	menu.setrow = nil
	menu.toprow = nil

	return ftable
end

function menu.viewCreated(layer, ...)
	if menu.hasRendertarget then
		menu.toplevel, menu.sidebar, menu.timelineTable, menu.rendertarget, menu.descriptionTable = ...
	else
		menu.toplevel, menu.sidebar, menu.timelineTable, menu.descriptionTable = ...
	end

	if menu.activatecutscene == nil then
		menu.activatecutscene = getElapsedTime()
	end
end

-- update
menu.updateInterval = 0.1

function menu.onUpdate()
	if menu.refresh then
		menu.refresh = nil
		menu.toprow = GetTopRow(menu.timelineTable)
		menu.setrow = Helper.currentTableRow[menu.timelineTable]
		menu.selectedRows.sidebar = Helper.currentTableRow[menu.sidebar]
		menu.createFrame()
		return
	end

	menu.infoFrame:update()
end

function menu.onRowChanged(row, rowdata, uitable)
end

function menu.onSelectElement(uitable, modified, row)
end

function menu.onCloseElement(dueToClose)
	if menu.encyclopediaMode and (dueToClose == "back") then
		menu.deactivateEncyclopediaMode()
		return
	end

	Helper.closeMenu(menu, dueToClose)
	menu.cleanup()
end

init()
