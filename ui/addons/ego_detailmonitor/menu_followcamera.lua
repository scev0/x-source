
-- param == { 0, 0 }

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef struct {
		float x;
		float y;
		float z;
	} Coord3D;

	UniverseID GetExternalViewRefObject(void);
	Coord3D GetFollowCameraBasePos(void);
	bool HasFollowCameraBasePosChanged(void);
	void ResetFollowCameraBasePos(void);
	void ResetFollowCameraBasePosOverride(void);
	void SaveFollowCameraBasePos(void);
	void SetEditingFollowCameraSettings(bool setting);
	void SetFollowCameraBasePos(Coord3D uipos);
]]

local menu = {
	name = "FollowCameraMenu",
}

local config = {
	width = 400,
	yoffset = 160,
	layer = 2,
	valuenames = {
		{ key = "pos_z", name = ReadText(1001, 12302) },
		{ key = "pos_y", name = ReadText(1001, 12303) },
		{ key = "pos_x", name = ReadText(1001, 12304) },
	},
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
	
	RegisterEvent("playerCameraModeChanged", menu.onPlayerCameraModeChanged)
end

function menu.onPlayerCameraModeChanged(_, mode)
	if menu.shown then
		menu.onCloseElement("close")
	end
end

function menu.cleanup()
	UnregisterAddonBindings("ego_detailmonitor")

	C.SetEditingFollowCameraSettings(false)
	menu.slidercells = {}
	menu.currentMouseOverTable = nil
end

function menu.hotkey(action)
	if action == "INPUT_ACTION_ADDON_DETAILMONITOR_CLOSE_FOLLOWCAM_OFFSET" then
		menu.onCloseElement("close")
	end
end

-- Menu member functions

function menu.onShowMenu()
	menu.limits = {
		pos_x = { min = -100, max = 100 },
		pos_y = { min =    0, max = 100 },
		pos_z = { min =    0, max = 100 },
	}
	menu.slidercells = {}

	-- Register bindings
	Helper.setKeyBinding(menu, menu.hotkey)
	RegisterAddonBindings("ego_detailmonitor", "followcamera")

	menu.createInfoFrame(true)
end

function menu.createInfoFrame(playercontrols)
	menu.playercontrols = playercontrols
	-- remove old data
	Helper.clearDataForRefresh(menu, config.infoLayer)

	local frameProperties = {
		standardButtons = { close = true },
		width = Helper.scaleX(config.width) + 6 * Helper.borderSize,
		x = Helper.viewWidth - Helper.scaleX(config.width) - 6 * Helper.borderSize - 2 * Helper.frameBorder,
		y = Helper.scaleY(config.yoffset),
		layer = config.layer,
		startAnimation = false,
		playerControls = playercontrols,
		keepHUDVisible = true,
		keepCrosshairVisible = true,
	}

	menu.infoFrame = Helper.createFrameHandle(menu, frameProperties)
	menu.infoFrame:setBackground("solid", { color = Color["frame_background_semitransparent"] })

	local tableProperties = {
		width = Helper.scaleX(config.width),
		x = 3 * Helper.borderSize,
		y = 3 * Helper.borderSize,
	}

	local ftable = menu.createTable(menu.infoFrame, tableProperties, playercontrols)

	menu.infoFrame.properties.height = ftable.properties.y + ftable:getVisibleHeight() + 3 * Helper.borderSize

	menu.infoFrame:display()
end

function menu.createTable(frame, tableProperties, playercontrols)
	local numcols = 3
	local ftable = frame:addTable(numcols, { tabOrder = playercontrols and 0 or 1, width = tableProperties.width, x = tableProperties.x, y = tableProperties.y })
	
	local row = ftable:addRow(nil, { fixed = true })
	row[1]:setColSpan(numcols):createText(ReadText(1001, 12301), Helper.headerRowCenteredProperties)

	menu.updatePos()

	-- distance
	for _, entry in ipairs(config.valuenames) do
		menu[entry.key] = math.max(menu.limits[entry.key].min, math.min(menu.limits[entry.key].max, menu[entry.key]))
		local slidercellProperties = {
			height = Helper.standardTextHeight,
			min       = menu.limits[entry.key].min,
			max       = menu.limits[entry.key].max,
			start     = menu[entry.key],
			step      = 1,
			suffix    = "%",
			exceedMaxValue = false,
			hideMaxValue = true,
			readOnly = playercontrols,
		}

		local row = ftable:addRow(not playercontrols, { fixed = true })
		menu.slidercells[entry.key] = row[1]:setColSpan(numcols):createSliderCell(slidercellProperties):setText(entry.name, {  })
		row[1].handlers.onSliderCellChanged = function (_, value) return menu.slidercellPositionChanged(entry.key, value) end
		row[1].handlers.onSliderCellActivated = function() menu.updatePos(); menu.noupdate = true end
		row[1].handlers.onSliderCellDeactivated = function() menu.noupdate = false end
	end

	if not playercontrols then
		local row = ftable:addRow(true, { fixed = true })
		row[1]:createButton({ active = function () return C.HasFollowCameraBasePosChanged() end }):setText(ReadText(1001, 12305), { halign = "center" })
		row[1].handlers.onClick = function () C.SaveFollowCameraBasePos(); menu.onCloseElement("close") end

		row[2]:createButton({  }):setText(ReadText(1001, 12306), { halign = "center" })
		row[2].handlers.onClick = function () C.ResetFollowCameraBasePosOverride() end

		row[3]:createButton({  }):setText(ReadText(1001, 12307), { halign = "center" })
		row[3].handlers.onClick = function () C.ResetFollowCameraBasePos(); menu.onCloseElement("close") end
	else
		local row = ftable:addRow(nil, { fixed = true })
		row[1]:createText(ReadText(1001, 12305), { halign = "center", cellBGColor = function () return C.HasFollowCameraBasePosChanged() and Color["button_background_default"] or Color["button_background_inactive"] end, minRowHeight = Helper.standardButtonHeight, x = 0, y = (Helper.standardButtonHeight - Helper.standardTextHeight) / 2 + 1 })
		row[2]:createText(ReadText(1001, 12306), { halign = "center", cellBGColor = Color["button_background_default"], minRowHeight = Helper.standardButtonHeight, x = 0, y = (Helper.standardButtonHeight - Helper.standardTextHeight) / 2 + 1 })
		row[3]:createText(ReadText(1001, 12307), { halign = "center", cellBGColor = Color["button_background_default"], minRowHeight = Helper.standardButtonHeight, x = 0, y = (Helper.standardButtonHeight - Helper.standardTextHeight) / 2 + 1 })
	end

	return ftable
end

function menu.viewCreated(layer, ...)
end

-- update
menu.updateInterval = 0.1

function menu.onUpdate()
	if not menu.noupdate then
		if menu.currentMouseOverTable and menu.playercontrols then
			menu.createInfoFrame(false)
			menu.noupdate = nil
			return
		elseif (not menu.currentMouseOverTable) and (not menu.playercontrols) then
			menu.createInfoFrame(true)
			menu.noupdate = nil
			return
		end

		menu.updatePos()
		menu.updateSliders()
		
	end
	menu.infoFrame:update()
end

function menu.onRowChanged(row, rowdata, uitable)
end

function menu.onSelectElement(uitable, modified, row)
end

function menu.onCloseElement(dueToClose)
	C.ResetFollowCameraBasePos()
	Helper.closeMenu(menu, dueToClose)
	menu.cleanup()
end

-- table mouse input helper
function menu.onTableMouseOut(uitable, row)
	if menu.currentMouseOverTable and (uitable == menu.currentMouseOverTable) then
		menu.currentMouseOverTable = nil
	end
end

function menu.onTableMouseOver(uitable, row)
	menu.currentMouseOverTable = uitable
end

-- menu helpers

function menu.updatePos()
	local size = GetComponentData(ConvertStringToLuaID(tostring(C.GetExternalViewRefObject())), "size")
	local campos = C.GetFollowCameraBasePos()
	menu.pos_x =  campos.x / (2.5 * size) * 100
	menu.pos_y =  campos.y / (5   * size) * 100
	menu.pos_z = -campos.z / (5   * size) * 100

	for _, entry in ipairs(config.valuenames) do
		if menu[entry.key] < menu.limits[entry.key].min then
			if menu.limits[entry.key].min == 0 then
				menu.limits[entry.key].min = -100
			else
				menu.limits[entry.key].min = 2 * menu.limits[entry.key].min
			end
		end
		if menu[entry.key] > menu.limits[entry.key].max then
			if menu.limits[entry.key].max == 0 then
				menu.limits[entry.key].max = 100
			else
				menu.limits[entry.key].max = 2 * menu.limits[entry.key].max
			end
		end
	end
end

function menu.updateSliders()
	for _, entry in ipairs(config.valuenames) do
		if menu.slidercells[entry.key] then
			menu.slidercells[entry.key]:updateMinValue(menu.limits[entry.key].min)
			menu.slidercells[entry.key]:updateMinSelectValue(menu.limits[entry.key].min)
			menu.slidercells[entry.key]:updateMaxValue(menu.limits[entry.key].max)
			menu.slidercells[entry.key]:updateMaxSelectValue(menu.limits[entry.key].max)

			SetSliderCellValue(menu.slidercells[entry.key].id, menu[entry.key])
		end
	end
end

function menu.slidercellPositionChanged(name, value)
	local size = GetComponentData(ConvertStringToLuaID(tostring(C.GetExternalViewRefObject())), "size")
	menu[name] = value
	local pos = {
		x =  menu.pos_x / 100 * (2.5 * size),
		y =  menu.pos_y / 100 * (5   * size),
		z = -menu.pos_z / 100 * (5   * size),
	}
	C.SetFollowCameraBasePos(pos)
end

init()
