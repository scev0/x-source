
-- param == { 0, 0, mode, modeparam }
-- modes: - "hackpanel",			param: { panelcomponent, panelconnection, paneltype }
--		  - "abortupgrade",			param: { container, task, price }
--		  - "transporter",			param: { transportercomponent, transporterconnection }
--		  - "markashostile",		param: { component }
--		  - "discardstationeditor"	param: { stationeditorcontainer }
--		  - "removebuildstorage",	param: { buildstorage }
--		  - "custom",				param: { title, question, { leftoptionid, leftoptionname[, uicallbackparam, ...] }, { rightoptionid, rightoptionname[, uicallbackparam, ...] }[, uicallbackmode][, preselectoption ("left"|"right")] }
--			uicallbackmodes:		- "invertinput",				param: { rangeid, configname, value }
--									- "autoroll",					param: { value }
--									- "mouse_steering_adaptive",	param: { value }
--									- "stick_steering_adaptive",	param: { value }

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef uint64_t BuildTaskID;
	typedef uint64_t UniverseID;
	typedef struct {
		UniverseID component;
		const char* connection;
	} UIComponentSlot;
	bool CancelConstruction(UniverseID containerid, BuildTaskID id);
	const char* GetControlPanelName(UIComponentSlot controlpanel);
	bool RemoveBuildStorage(UniverseID buildstorageid);
	void SetAutoRoll(bool value);
	void SetInversionSetting(uint32_t uirangeid, const char* parametername, bool value);
	void SetJoystickSteeringAdapative(bool value);
	void SetMouseSteeringAdapative(bool value);
	void SetMouseSteeringInvertedOption(const char* paramname, bool value);
	void SetUserData(const char* name, const char* value);
	void StartControlPanelHack(UIComponentSlot target, const char* paneltypeid);
	void TriggerAutosave(bool checkenabled);
	const char* UndockPlayerShip(bool checkonly);
]]

local menu = {
	name = "UserQuestionMenu",
	saveOption = false,
}

local config = {
	width = 400,
	layer = 2,
	saveOptionVersion = 1,
}

local function init()
	__CORE_DETAILMONITOR_USERQUESTION = __CORE_DETAILMONITOR_USERQUESTION or {
		version = config.saveOptionVersion,
	}
	Menus = Menus or { }
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end

	RegisterEvent("gameSaved", menu.onGameSaved)
end

function menu.cleanup()
	menu.infoFrame = nil

	menu.mode = nil
	menu.modeparam = {}
	menu.hacktarget = nil
	menu.transportertarget = nil
	menu.upgradecontainer = nil
	menu.upgradetask = nil
	menu.upgradeprice = nil
	menu.buildstorage = nil
	menu.saveOption = false
end

-- Menu member functions

function menu.confirm()
	local allowclose = true
	if menu.mode == "hackpanel" then
		C.StartControlPanelHack(menu.hacktarget, menu.modeparam[3])
	elseif menu.mode == "abortupgrade" then
		if C.CancelConstruction(menu.upgradecontainer, menu.upgradetask) then
			if ffi.string(C.UndockPlayerShip(false)) ~= "granted" then
				DebugError("failed undocking.")
			end
		else
			menu.onCloseElement("back", true)
		end
	elseif menu.mode == "transporter" then
		C.TransportPlayerToTarget(menu.transportertarget)
	elseif menu.mode == "markashostile" then
		C.SetRelationBoostToFaction(menu.hostilecomponent, "player", "markedashostile", -1, 1, 600)
	elseif menu.mode == "discardstationeditor" then
		Helper.clearStationEditorState()
	elseif menu.mode == "starttutorial" then
		if menu.modeparam[2] == 1 then
			menu.saveTriggered = true
			if Helper.isOnlineGame() then
				SaveOnlineGame()
			else
				C.TriggerAutosave(false)
			end
			allowclose = false
		else
			C.SetUserData("tutorial_started_from", tostring(menu.modeparam[2]))
			NewGame(menu.modeparam[1])
		end
	elseif menu.mode == "removebuildstorage" then
		C.RemoveBuildStorage(menu.buildstorage)
	end
	if menu.saveOption then
		__CORE_DETAILMONITOR_USERQUESTION[menu.mode] = true
	end
	if allowclose then
		menu.onCloseElement("close")
	end
end

function menu.customOption(optionid, optionparameters)
	if menu.modeparam[5] then
		if menu.modeparam[5] == "invertinput" then
			if (optionparameters[3] ~= nil) and (optionparameters[4] ~= nil) and (optionparameters[5] ~= nil) then
				if optionparameters[3] == 0 then
					C.SetMouseSteeringInvertedOption(optionparameters[4], optionparameters[5])
				else
					C.SetInversionSetting(optionparameters[3], optionparameters[4], optionparameters[5])
				end
			end
		elseif menu.modeparam[5] == "autoroll" then
			if (optionparameters[3] ~= nil) then
				C.SetAutoRoll(optionparameters[3])
			end
		elseif menu.modeparam[5] == "mouse_steering_adaptive" then
			if (optionparameters[3] ~= nil) then
				C.SetMouseSteeringAdapative(optionparameters[3])
			end
		elseif menu.modeparam[5] == "stick_steering_adaptive" then
			if (optionparameters[3] ~= nil) then
				C.SetJoystickSteeringAdapative(optionparameters[3])
			end
		end
	end
	AddUITriggeredEvent(menu.name, "selected", optionid)
	menu.onCloseElement("close")
end

function menu.onShowMenu()
	menu.mode = menu.param[3]
	menu.modeparam = menu.param[4]
	if menu.mode == "hackpanel" then
		menu.hacktarget = ffi.new("UIComponentSlot")
		menu.hacktarget.component = ConvertIDTo64Bit(menu.modeparam[1])
		menu.hacktarget.connection = menu.modeparam[2]
	elseif menu.mode == "abortupgrade" then
		menu.upgradecontainer = ConvertIDTo64Bit(menu.modeparam[1])
		menu.upgradetask = ConvertIDTo64Bit(menu.modeparam[2])
		menu.upgradeprice = menu.modeparam[3]
	elseif menu.mode == "transporter" then
		menu.transportertarget = ffi.new("UIComponentSlot")
		menu.transportertarget.component = ConvertIDTo64Bit(menu.modeparam[1])
		menu.transportertarget.connection = menu.modeparam[2]
	elseif menu.mode == "markashostile" then
		menu.hostilecomponent = ConvertIDTo64Bit(menu.modeparam[1])
	elseif menu.mode == "discardstationeditor" then
		Helper.unregisterStationEditorChanges()
	elseif menu.mode == "removebuildstorage" then
		menu.buildstorage = ConvertIDTo64Bit(menu.modeparam[1])
	end

	if __CORE_DETAILMONITOR_USERQUESTION[menu.mode] then
		-- continue immediately
		menu.confirm()
	else
		-- display info
		menu.createInfoFrame()
	end
end

function menu.createInfoFrame()
	-- remove old data
	Helper.clearDataForRefresh(menu, config.infoLayer)

	local frameProperties = {
		standardButtons = {},
		width = Helper.scaleX(config.width) + 6 * Helper.borderSize,
		x = (Helper.viewWidth - Helper.scaleX(config.width)) / 2,
		y = Helper.viewHeight / 2,
		layer = config.layer,
		startAnimation = false,
		playerControls = menu.mode == "markashostile",
	}

	menu.infoFrame = Helper.createFrameHandle(menu, frameProperties)
	menu.infoFrame:setBackground("solid", { color = Color["frame_background_semitransparent"] })

	local tableProperties = {
		width = Helper.scaleX(config.width),
		x = 3 * Helper.borderSize,
		y = 3 * Helper.borderSize,
	}

	local ftable = menu.createTable(menu.infoFrame, tableProperties)

	menu.infoFrame.properties.height = ftable.properties.y + ftable:getVisibleHeight() + 3 * Helper.borderSize
	menu.infoFrame.properties.y = (Helper.viewHeight - menu.infoFrame.properties.height) / 2

	menu.infoFrame:display()
end

function menu.createTable(frame, tableProperties)
	local hasSaveOption = true
	if (menu.mode == "custom") or (menu.mode == "starttutorial") or (menu.mode == "removebuildstorage") then
		hasSaveOption = false
	end
	local numCols = 6
	if not hasSaveOption then
		numCols = 5
	end

	local ftable = frame:addTable(numCols, { tabOrder = 1, borderEnabled = true, width = tableProperties.width, x = tableProperties.x, y = tableProperties.y, defaultInteractiveObject = true })
	if menu.mode == "custom" then
		local leftwith = math.ceil(C.GetTextWidth(menu.modeparam[3][2] or "", Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize)))
		local rightwidth = math.ceil(C.GetTextWidth(menu.modeparam[4][2] or "", Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize)))
		local minbuttonwidth = 0.2 * tableProperties.width - Helper.borderSize
		local maxbuttonwidth = (tableProperties.width - 4 * Helper.borderSize - 3) / 2

		local buttonwidth = math.max(minbuttonwidth, math.min(maxbuttonwidth, math.max(leftwith, rightwidth) + 2 * Helper.standardTextOffsetx))
		ftable:setColWidth(2, buttonwidth, false)
		ftable:setColWidth(4, buttonwidth, false)
	elseif not hasSaveOption then
		ftable:setColWidth(2, 0.4 * tableProperties.width - Helper.borderSize, false)
		ftable:setColWidth(4, 0.4 * tableProperties.width - Helper.borderSize, false)
	else
		ftable:setColWidth(1, Helper.scaleY(Helper.standardButtonHeight), false)
		ftable:setColWidthPercent(5, 25, false)
		ftable:setColWidthPercent(6, 25, false)
	end

	if menu.mode == "hackpanel" then
		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 9701), Helper.headerRowCenteredProperties)

		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 9702) .. ReadText(1001, 120))
		
		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ffi.string(C.GetControlPanelName(menu.hacktarget)))
	elseif menu.mode == "abortupgrade" then
		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 9703), Helper.headerRowCenteredProperties)

		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 9704), { wordwrap = true })
	elseif menu.mode == "transporter" then
		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 9707), Helper.headerRowCenteredProperties)

		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 9708), { wordwrap = true })
	elseif menu.mode == "markashostile" then
		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 11114), Helper.headerRowCenteredProperties)

		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 9710), { wordwrap = true })
	elseif menu.mode == "discardstationeditor" then
		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 9721), Helper.headerRowCenteredProperties)

		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 9722), { wordwrap = true })
	elseif menu.mode == "starttutorial" then
		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 9728), Helper.headerRowCenteredProperties)

		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 9727), { wordwrap = true })
	elseif menu.mode == "removebuildstorage" then
		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 11667), Helper.headerRowCenteredProperties)

		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 11668), { wordwrap = true })
	elseif menu.mode == "custom" then
		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(menu.modeparam[1] or "", Helper.headerRowCenteredProperties)

		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(menu.modeparam[2] or "", { wordwrap = true })
	end

	local row = ftable:addRow(false, { fixed = true })
	row[1]:setColSpan(numCols):createText("")

	if menu.mode == "custom" then
		local row = ftable:addRow(true, { fixed = true })
		row[2]:createButton({ helpOverlayID = "custom_" .. menu.mode .. "_confirm", helpOverlayText = " ", helpOverlayHighlightOnly = true }):setText(menu.modeparam[3][2] or "", { halign = "center" })
		row[2].handlers.onClick = function () return menu.customOption(menu.modeparam[3][1], menu.modeparam[3]) end
		row[4]:createButton({ helpOverlayID = "custom_" .. menu.mode .. "_confirm", helpOverlayText = " ", helpOverlayHighlightOnly = true }):setText(menu.modeparam[4][2] or "", { halign = "center" })
		row[4].handlers.onClick = function () return menu.customOption(menu.modeparam[4][1], menu.modeparam[4]) end

		if menu.modeparam[6] == "right" then
			ftable:setSelectedCol(4)
		elseif menu.modeparam[6] == "left" then
			ftable:setSelectedCol(2)
		end
	elseif menu.mode == "starttutorial" then
		local row = ftable:addRow(true, { fixed = true })
		row[2]:createButton({ active = function () return IsSavingPossible(false) end, helpOverlayID = "custom_" .. menu.mode .. "_confirm", helpOverlayText = " ", helpOverlayHighlightOnly = true }):setText(ReadText(1001, 9724), { halign = "center" })
		row[2].handlers.onClick = menu.confirm
		row[4]:createButton({ helpOverlayID = "custom_" .. menu.mode .. "_cancel", helpOverlayText = " ", helpOverlayHighlightOnly = true }):setText(ReadText(1001, 64), { halign = "center" })
		row[4].handlers.onClick = function () return menu.onCloseElement("back", true) end
	elseif not hasSaveOption then
		local row = ftable:addRow(true, { fixed = true })
		row[2]:createButton({ helpOverlayID = "custom_" .. menu.mode .. "_confirm", helpOverlayText = " ", helpOverlayHighlightOnly = true }):setText(ReadText(1001, 2821), { halign = "center" })
		row[2].handlers.onClick = menu.confirm
		row[4]:createButton({ helpOverlayID = "custom_" .. menu.mode .. "_cancel", helpOverlayText = " ", helpOverlayHighlightOnly = true }):setText(ReadText(1001, 64), { halign = "center" })
		row[4].handlers.onClick = function () return menu.onCloseElement("back", true) end
		ftable:setSelectedCol(4)
	else
		local row = ftable:addRow(true, { fixed = true })
		row[1]:createCheckBox(function () return menu.saveOption end, { height = Helper.standardButtonHeight })
		row[1].handlers.onClick = function () menu.saveOption = not menu.saveOption end
		row[2]:setColSpan(3):createButton({ bgColor = Color["button_background_hidden"] }):setText(ReadText(1001, 9709))
		row[2].handlers.onClick = function () menu.saveOption = not menu.saveOption end
		row[5]:createButton({ helpOverlayID = "custom_" .. menu.mode .. "_confirm", helpOverlayText = " ", helpOverlayHighlightOnly = true }):setText(ReadText(1001, 2821), { halign = "center" })
		row[5].handlers.onClick = menu.confirm
		row[6]:createButton({ helpOverlayID = "custom_" .. menu.mode .. "_cancel", helpOverlayText = " ", helpOverlayHighlightOnly = true }):setText(ReadText(1001, 64), { halign = "center" })
		row[6].handlers.onClick = function () return menu.onCloseElement("back", true) end
		ftable:setSelectedCol(6)
	end

	return ftable
end

function menu.viewCreated(layer, ...)
end

-- update
menu.updateInterval = 0.1

function menu.onUpdate()
	menu.infoFrame:update()
end

function menu.onRowChanged(row, rowdata, uitable)
end

function menu.onSelectElement(uitable, modified, row)
end

function menu.onGameSaved(_, success)
	if menu.saveTriggered then
		menu.saveTriggered = nil
		if menu.mode == "starttutorial" then
			C.SetUserData("tutorial_started_from", tostring(menu.modeparam[2]))
			if success then
				NewGame(menu.modeparam[1])
			end
			menu.onCloseElement("close")
		end
	end
end

function menu.onCloseElement(dueToClose, allowAutoMenu)
	if menu.mode == "discardstationeditor" then
		if dueToClose == "close" then
			Helper.clearStationEditorState()
		elseif dueToClose == "back" then
			-- restore state
			Helper.registerStationEditorChanges()
			Helper.closeMenuAndOpenNewMenu(menu, "StationConfigurationMenu", { 0, 0, menu.modeparam }, true)
			menu.cleanup()
			return
		end
	end
	Helper.closeMenu(menu, dueToClose, allowAutoMenu or (menu.mode ~= "abortupgrade"))
	menu.cleanup()
end

-- menu helpers

init()
