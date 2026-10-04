-- param == { 0, 0, mode }

-- modes:

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef uint64_t UniverseID;
	typedef struct {
		int32_t id;
		const char* name;
	} GameStartGroupInfo;
	typedef struct {
		const char* file;
		const char* icon;
		bool ispersonal;
	} UILogo;
	bool CanOpenWebBrowser(void);
	UILogo GetCurrentPlayerLogo(void);
	uint32_t GetGameStartGroups(GameStartGroupInfo* result, uint32_t resultlen);
	const char* GetGameStartName();
	uint32_t GetNumGameStartGroups(void);
	UniverseID GetPlayerID(void);
	float GetTextHeight(const char*const text, const char*const fontname, const float fontsize, const float wordwrapwidth);
	const char* GetUserData(const char* name);
	bool IsGameModified(void);
	bool IsGameOver(void);
	bool IsTimelinesScenario(void);
	bool IsTutorial(void);
	void OpenWebBrowser(const char* url);
	void SetUserData(const char* name, const char* value);
]]

-- menu variable - used by Helper and used for dynamic variables (e.g. inventory content, etc.)
local menu = {
	name = "HelpMenu"
}

-- config variable - put all static setup here
local config = {
	mainLayer = 5,
	infoLayer = 4,
	mode = "tutorials",
	leftBar = {
		{ name = ReadText(1001, 3314),	icon = "tut_tutorial",	mode = "tutorials",	active = true,				  	helpOverlayID = "tutorials_sidebar_tutorial",		helpOverlayText = ReadText(1028, 8701) },
		{ name = ReadText(1001, 8702),	icon = "tut_external",	mode = "external",	active = C.CanOpenWebBrowser(),	helpOverlayID = "tutorials_sidebar_external",		helpOverlayText = ReadText(1028, 8702) },
	},
	externals = {
		[1] = { id = 40 },
		[2] = { id = 10 },
		[3] = { id = 20 },
		[4] = { id = 30 },
		[5] = { id = 50 },
		[6] = { id = 60 },
		[7] = { id = 70 },
		[8] = { id = 80 },
		[9] = { id = 90 },
		[10] = { id = 100 },
	},
	height = 400,
}

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
	unregisterForEvent("inputModeChanged", getElement("Scene.UIContract"), menu.onInputModeChanged)
	menu.topLevelOffsetY = nil

	UnregisterAddonBindings("ego_detailmonitor", "help")

	menu.selectedData = nil
	menu.preselectmission = nil

	menu.frame = nil
	menu.sideBarTable = nil
	menu.table_toplevel = nil
	menu.table_header = nil
	menu.table_info = nil
	menu.table_button = nil
end

function menu.hotkey(action)
	if action == "INPUT_ACTION_ADDON_DETAILMONITOR_CLOSE_HELP" then
		menu.closeMenu("close")
	end
end

function menu.onShowMenu()
	Helper.setTabScrollCallback(menu, menu.onTabScroll)
	registerForEvent("inputModeChanged", getElement("Scene.UIContract"), menu.onInputModeChanged)

	-- Register bindings
	Helper.setKeyBinding(menu, menu.hotkey)
	RegisterAddonBindings("ego_detailmonitor", "help")

	menu.selectedRows = {}
	menu.selectedCols = {}

	menu.mode = (menu.param and menu.param[3]) or menu.mode or config.mode

	menu.sideBarWidth = Helper.scaleX(Helper.sidebarWidth)

	AddUITriggeredEvent(menu.name, menu.mode)

	-- add content
	menu.setdefaulttable = true
	menu.display(true)
	menu.createMainFrame()
end

function menu.createMainFrame()
	local frameProperties = {
		standardButtons = { back = true, close = true, help = true  },
		width = Helper.viewWidth,
		height = menu.table_button.properties.y + menu.table_button:getFullHeight() + Helper.frameBorder,
		x = 0,
		y = 0,
		layer = config.mainLayer,
	}

	menu.mainFrame = Helper.createFrameHandle(menu, frameProperties)
	menu.mainFrame:setBackground("solid", { color = Color["frame_background_semitransparent"] })

	menu.createPlayerInfo(menu.mainFrame, Helper.playerInfoConfig.width, Helper.playerInfoConfig.height, Helper.playerInfoConfig.offsetX, Helper.playerInfoConfig.offsetY)

	menu.mainFrame:display()
end

function menu.display(firsttime)
	Helper.removeAllWidgetScripts(menu, config.infoLayer)

	local width = Helper.viewWidth
	local height = Helper.viewHeight
	local xoffset = 0
	local yoffset = 0

	menu.frame = Helper.createFrameHandle(menu, { width = width, x = xoffset, y = yoffset, layer = config.infoLayer })

	menu.createTopLevel(menu.frame)

	width = 2 * (width / 3) - Helper.borderSize - menu.sideBarWidth - Helper.playerInfoConfig.offsetX

	local xoffset = Helper.playerInfoConfig.offsetX + menu.sideBarWidth + Helper.borderSize
	local yoffset = 25

	if menu.mode then
		for _, entry in ipairs(config.leftBar) do
			if entry.mode == menu.mode then
				menu.title = entry.name
			end
		end
	end

	local table_header = menu.frame:addTable(2, { tabOrder = 0, width = width, x = xoffset, y = menu.topLevelOffsetY + Helper.borderSize + yoffset })

	width = (width - Helper.borderSize) / 2
	menu.width = width

	table_header:setColWidth(1, width, false)

	local row = table_header:addRow(false, { fixed = true })
	row[1]:setBackgroundColSpan(2):createText(menu.title, Helper.headerRowCenteredProperties)
	row[2]:createText(" ", Helper.headerRowCenteredProperties)

	yoffset = table_header:getFullHeight() + table_header.properties.y + Helper.borderSize

	if menu.mode then
		local maxheight = Helper.viewHeight - yoffset - Helper.borderSize - Helper.scaleY(Helper.standardButtonHeight) - Helper.frameBorder
		menu.height = math.min(maxheight, Helper.scaleY(config.height))

		local table_info = menu.frame:addTable(2, { tabOrder = 1, width = width, x = xoffset, y = yoffset, maxVisibleHeight = menu.height })
		table_info:setColWidth(1, 20)
		if menu.setdefaulttable then
			table_info.properties.defaultInteractiveObject = true
			menu.setdefaulttable = nil
		end

		if menu.mode == "tutorials" then
			local gamemodules = GetRegisteredModules()
			local groups = {}
			for _, module in ipairs(gamemodules) do
				if (not module.unlockhidden) or module.unlocked then
					local istimelineshub = module.id == "x4ep1_gamestart_hub"
					if module.tutorial then
						local index
						for i, group in ipairs(groups) do
							if group.group == module.group then
								index = i
								break
							end
						end

						if index then
							table.insert(groups[index], module)
						else
							table.insert(groups, { group = module.group, [1] = module })
						end
					end
				end
			end

			local gamestartgroups = {}
			local n = C.GetNumGameStartGroups()
			local buf = ffi.new("GameStartGroupInfo[?]", n)
			n = C.GetGameStartGroups(buf, n)
			for i = 0, n - 1 do
				gamestartgroups[buf[i].id] = ffi.string(buf[i].name)
			end

			for i, group in ipairs(groups) do
				if gamestartgroups[group.group] then
					table_info:addEmptyRow(Helper.headerRow1Height / 4)
					local row = table_info:addRow(false, {  })
					row[2]:createText(gamestartgroups[group.group], Helper.headerRowCenteredProperties)
				elseif i ~= 1 then
					local row = table_info:addRow(false, {  })
					row[2]:createText(" ", { fontsize = 1, height = Helper.borderSize, cellBGColor = Color["row_separator"] })
				end
				for _, module in ipairs(group) do
					if module.available or showunavailable then
						local row = table_info:addRow(module, {  })
						if module.id == menu.preselectOption then
							table_info:setSelectedRow(row.index)
						end

						local available = module.available or (module.extensionid ~= "")
						local mouseovertext
						if C.IsGameModified() then
							if module.budget then
								available = false
								mouseovertext = ReadText(1026, 9916)
							end
						end
						if C.IsGameOver() and module.customeditor then
							available = false
							mouseovertext = ReadText(1026, 2666)
						end
						if module.tutorial then
							if tonumber(ffi.string(C.GetUserData(module.id .. "_completed"))) == 1 then
								local iconsize = Helper.scaleY(Helper.standardTextHeight)
								row[1]:createIcon("widget_tick_01", { color = Color["tutorial_completed"], width = iconsize, height = iconsize, x = row[1]:getWidth() - iconsize, scaling = false })
							end
						end
						row[2]:createText(module.name, { color = ((not available) or (not module.unlocked)) and Color["text_inactive"] or nil })
						if mouseovertext then
							row[2].properties.mouseOverText = mouseovertext
						end
					end
				end
			end
		elseif menu.mode == "external" then
			for _, tutorial in ipairs(config.externals) do
				local row = table_info:addRow({ id = tutorial.id }, {  })
				row[1]:setColSpan(2):createText(ReadText(1027, tutorial.id) .. " \27[mm_externallink]")
			end
		end

		table_info:setTopRow(GetTopRow(menu.table_info))
		table_info:setSelectedRow(Helper.currentTableRow[menu.table_info])

		local table_desc = menu.frame:addTable(1, { tabOrder = 0, width = width, x = xoffset + width + Helper.borderSize, y = yoffset })
		local row = table_desc:addRow(id, {  })
		row[1]:createText(menu.info, { scaling = false, fontsize = Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), height = menu.height, wordwrap = true })

		menu.table_button = menu.frame:addTable(2, { tabOrder = 3, width = width, x = xoffset, y = yoffset + menu.height + Helper.borderSize, skipTabChange = true })
		local row = menu.table_button:addRow(true, { fixed = true })
		row[2]:createButton({}):setText(menu.textButton, { halign = "center" })
		row[2].handlers.onClick = function () return menu.selectEntry(menu.selectedData) end
	end

	-- display view/frame
	menu.frame:display()
end

function menu.createPlayerInfo(frame, width, height, offsetx, offsety)
	local ftable = frame:addTable(2, { tabOrder = 2, scaling = false, borderEnabled = false, x = offsetx, y = offsety, reserveScrollBar = false })
	ftable:setColWidth(1, menu.sideBarWidth, false)
	ftable:setColWidth(2, width - menu.sideBarWidth - Helper.borderSize, false)

	local row = ftable:addRow(false, { fixed = true, bgColor = Color["player_info_background"] })
	local icon = row[1]:setColSpan(2):createIcon(function () local logo = C.GetCurrentPlayerLogo(); return ffi.string(logo.icon) end, { width = height, height = height, color = Helper.getPlayerLogoColor })

	local textheight = math.ceil(C.GetTextHeight(Helper.playerInfoConfigTextLeft(), Helper.standardFont, Helper.playerInfoConfig.fontsize, width - height - Helper.borderSize))
	icon:setText(Helper.playerInfoConfigTextLeft,	{ fontsize = Helper.playerInfoConfig.fontsize, halign = "left",  x = height + Helper.borderSize, y = (height - textheight) / 2 })
	icon:setText2(Helper.playerInfoConfigTextRight,	{ fontsize = Helper.playerInfoConfig.fontsize, halign = "right", x = Helper.borderSize,          y = (height - textheight) / 2 })

	local spacingHeight = menu.sideBarWidth / 4
	for _, entry in ipairs(config.leftBar) do
		if entry.spacing then
			row = ftable:addRow(false, { fixed = true, bgColor = Color["row_background_blue"] })
			row[1]:createIcon("mapst_seperator_line", { width = menu.sideBarWidth, height = spacingHeight })
		else
			row = ftable:addRow(true, { fixed = true, bgColor = Color["row_background_blue"] })
			row[1]:createButton({ active = entry.active, height = menu.sideBarWidth, bgColor = (menu.mode == entry.mode) and Color["row_background_selected"] or Color["row_title_background"], mouseOverText = entry.name, helpOverlayID = entry.helpOverlayID, helpOverlayText = entry.helpOverlayText} ):setIcon(entry.icon)
			row[1].handlers.onClick = function () return menu.buttonToggleMode(entry.mode) end
		end
	end
end

-- handle created frames
function menu.viewCreated(layer, ...)
	if layer == config.mainLayer then
		menu.sideBarTable = ...
	elseif layer == config.infoLayer then
		menu.table_toplevel, menu.table_header, menu.table_info = ...
	end
end

function menu.createTopLevel(frame)
	menu.topLevelOffsetY = Helper.createTopLevelTab(menu, "help", frame, "", nil, true)
end

function menu.onTabScroll(direction)
	if direction == "right" then
		Helper.scrollTopLevel(menu, "help", 1)
	elseif direction == "left" then
		Helper.scrollTopLevel(menu, "help", -1)
	end
end

function menu.onInputModeChanged(_, mode)
	menu.display()
end

-- widget scripts
function menu.buttonToggleMode(mode)
	local oldidx, newidx
	for i, entry in ipairs(config.leftBar) do
		if entry.mode then
			if entry.mode == menu.mode then
				oldidx = i
			end
			if entry.mode == mode then
				newidx = i
			end
		end
		if oldidx and newidx then
			break
		end
	end
	if newidx then
		Helper.updateButtonColor(menu.sideBarTable, newidx + 1, 1, Color["row_background_selected"])
	end
	if oldidx then
		Helper.updateButtonColor(menu.sideBarTable, oldidx + 1, 1, Color["button_background_default"])
	end

	AddUITriggeredEvent(menu.name, mode, menu.mode == mode and "off" or "on")
	if mode == menu.mode then
		PlaySound("ui_negative_back")
		menu.mode = nil
		if oldidx then
			SelectRow(menu.sideBarTable, oldidx + 1)
		end
	else
		menu.setdefaulttable = true
		PlaySound("ui_positive_select")
		menu.mode = mode
		if newidx then
			SelectRow(menu.sideBarTable, newidx + 1)
		end
	end
	menu.selectedData = nil

	menu.display()
end

function menu.deactivatePlayerInfo()
	local oldidx
	for i, entry in ipairs(config.leftBar) do
		if entry.mode then
			if entry.mode == menu.mode then
				oldidx = i
			end
		end
		if oldidx then
			break
		end
	end

	if oldidx then
		Helper.updateButtonColor(menu.sideBarTable, oldidx + 1, 1, Color["button_background_default"])
	end

	PlaySound("ui_negative_back")
	menu.mode = nil
	menu.selectedData = nil
	if oldidx then
		SelectRow(menu.mainTable, oldidx + 1)
	end

	menu.display()
end

-- helper functions
function menu.info()
	local text = ""
	if menu.selectedData then
		if menu.mode == "tutorials" then
			text = menu.selectedData.description
		elseif menu.mode == "external" then
			text =  ReadText(1027, tonumber(menu.selectedData.id + 2))
		end
	end
	text = TruncateText(text, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), menu.width - 2 * Helper.scaleX(Helper.standardTextOffsetx), true, menu.height)

	return text
end

function menu.textButton()
	if menu.mode == "tutorials" then
		if menu.selectedData and menu.selectedData.active then
			return ReadText(1001, 3322)
		else
			return ReadText(1001, 8703)
		end
	elseif menu.mode == "external" then
		return ReadText(1001, 8704)
	end
end

function menu.selectEntry(entry)
	if menu.mode == "tutorials" then
		local value = 1
		if C.IsTutorial() then
			value = 0
		elseif C.IsTimelinesScenario() or (ffi.string(C.GetGameStartName()) == "x4ep1_gamestart_hub") then
			value = 2
		end
		if value == 1 then
			Helper.closeMenuAndOpenNewMenu(menu, "UserQuestionMenu", { 0, 0, "starttutorial", { entry.id, 1 } })
			menu.cleanup()
		else
			C.SetUserData("tutorial_started_from", tostring(value))
			NewGame(entry.id)
			menu.closeMenu("close")
		end
	elseif menu.mode == "external" then
		C.OpenWebBrowser(ReadText(1027, entry.id + 1))
	end
end

menu.updateInterval = 0.1

-- hook to update the menu while it is being displayed
function menu.onUpdate()
	if menu.refresh then
		if menu.refresh < getElapsedTime() then
			menu.refresh = nil
			menu.display()
			return
		end
	end

	menu.frame:update()
end

-- hook if the highlighted row is changed (is also called on menu creation)
function menu.onRowChanged(row, rowdata, uitable)
	if uitable == menu.table_info then
		menu.selectedData = rowdata
	end
end

-- hook if the highlighted row is selected
function menu.onSelectElement(uitable, modified, row, isdblclick, input)
	local rowdata = Helper.getCurrentRowData(menu, uitable)
	if uitable == menu.table_info then
		if (isdblclick or (input ~= "mouse")) then
			menu.selectEntry(rowdata)
		end
	end
end

function menu.closeMenu(dueToClose)
	Helper.closeMenu(menu, dueToClose)
	menu.cleanup()
end

function menu.onCloseElement(dueToClose)
	if menu.mode and (dueToClose == "back") then
		menu.deactivatePlayerInfo()
	else
		menu.closeMenu(dueToClose)
	end
end

init()
