-- Ingame Options Main Menu

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	bool IsFullscreenCutsceneActive(void);
	bool IsStartmenu();
]]

local utf8 = require("utf8")

local menu = {
	name = "GameModifiedMenu",
}

local function init()
	-- register callbacks
	RegisterEvent("gameModified", menu.onGameModified)
	registerForEvent("cutsceneStopped", getElement("Scene.UIContract"), menu.onCutsceneStopped)

	-- init variables
	menu.isStartmenu = C.IsStartmenu()

	-- register menu
	Menus = Menus or {}
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end
end


--- config ---

local config = {
	optionsLayer = 4,

	font = "Zekton outlined",
	fontBold = "Zekton bold outlined",

	headerFontSize = 13,
	infoFontSize = 9,
	standardFontSize = 10,

	headerTextHeight = 34,
	subHeaderTextHeight = 22,
	standardTextHeight = 19,
	infoTextHeight = 16,

	headerTextOffsetX = 5,
	standardTextOffsetX = 5,
	infoTextOffsetX = 5,
}

config.table = {
	x = 45,
	y = 45,
	width = 710,
	widthExtraWide = 1130,
	widthWithExtraInfo = 370,
	height = 600,
	arrowColumnWidth = 20,
	infoColumnWidth = 330,
}

config.headerTextProperties = {
	font = config.fontBold,
	fontsize = config.headerFontSize,
	x = config.headerTextOffsetX,
	y = 6,
	minRowHeight = config.headerTextHeight,
	titleColor = Color["row_title"],
}

config.standardTextProperties = {
	font = config.font,
	fontsize = config.standardFontSize,
	x = config.standardTextOffsetX,
	y = 2,
}


--- widget hooks ---

function menu.onGameModified()
	if not C.IsFullscreenCutsceneActive() then
		Helper.closeOptionsMenu = true
		OpenMenu("GameModifiedMenu", nil, nil, true)
	else
		menu.checkFullscreenCutscene = true
		NotifyOnCutsceneStopped(getElement("Scene.UIContract"))
	end
end

function menu.onCutsceneStopped(_, cutsceneID)
	if menu.checkFullscreenCutscene then
		if not C.IsFullscreenCutsceneActive() then
			menu.checkFullscreenCutscene = nil
			Helper.closeOptionsMenu = true
			OpenMenu("GameModifiedMenu", nil, nil, true)
		end
	end
end


--- helper functions ---

function menu.cleanup()
	if not menu.isStartmenu then
		if menu.paused then
			Unpause()
			menu.paused = nil
		end
	end

	menu.quitAfterSave = nil

	menu.optionTable = nil

	menu.table = {}
end


--- menus ---

function menu.displayGameModified()
	Helper.clearDataForRefresh(menu, config.optionsLayer)

	menu.optionsFrame = Helper.createFrameHandle(menu, {
		layer = config.optionsLayer,
		x = 0,
		y = 0,
		width = Helper.viewWidth,
		height = Helper.viewHeight,
		standardButtons = { close = true },
		standardButtonX = (Helper.viewWidth - menu.table.width) / 2,
	})

	local ftable = menu.optionsFrame:addTable(4, { tabOrder = 1, x = (Helper.viewWidth - menu.table.width) / 2, y = menu.table.y, width = menu.table.width, maxVisibleHeight = menu.table.height, backgroundID = "solid", backgroundColor = Color["frame_background_notification"] })
	ftable:setColWidth(1, menu.table.arrowColumnWidth, false)
	ftable:setColWidthPercent(3, 33)
	ftable:setColWidthPercent(4, 33)
	ftable:setDefaultCellProperties("button", { height = config.standardTextHeight })
	ftable:setDefaultComplexCellProperties("button", "text", { x = config.standardTextOffsetX, fontsize = config.standardFontSize })

	-- title
	local row = ftable:addRow(nil, { fixed = true })
	row[1]:setColSpan(4):createText(ReadText(1001, 9716), config.headerTextProperties)

	-- info
	local row = ftable:addRow(nil, { fixed = true })
	row[2]:setColSpan(3):createText(ReadText(1001, 9717) .. "\n\n" .. ReadText(1001, 9719), config.standardTextProperties)
	row[2].properties.wordwrap = true

	ftable:addEmptyRow(config.standardTextHeight / 2)

	local height = ftable:getFullHeight()
	menu.optionsFrame.properties.standardButtonY = (Helper.viewHeight - height) / 2
	ftable.properties.y = (Helper.viewHeight - height) / 2
	menu.optionsFrame:setBackground("gradient_alpha_02", {  })
	menu.optionsFrame:setBackground2("tut_gradient_hint_01", { color = Color["frame_background2_notification"], width = menu.table.width + 4 * Helper.borderSize, height = height + 4 * Helper.borderSize, rotationStart = 135 })

	menu.optionsFrame:display()
end


--- Helper hooks ---

function menu.onShowMenu()
	Helper.closeOptionsMenu = false

	if not menu.isStartmenu then
		menu.paused = true
		Pause()
	end

	local tableOffsetX = Helper.scaleX(config.table.x)
	menu.table = {
		x =						tableOffsetX,
		y =						Helper.scaleY(config.table.y),
		width =					math.min(Helper.viewWidth - tableOffsetX, Helper.scaleX(config.table.width)),
		widthExtraWide =		math.min(Helper.viewWidth - tableOffsetX, Helper.scaleX(config.table.widthExtraWide)),
		widthWithExtraInfo =	Helper.scaleX(config.table.widthWithExtraInfo),
		arrowColumnWidth =		Helper.scaleY(config.table.arrowColumnWidth), -- sic - so that the arrow button proportions stay correct
		infoColumnWidth =		math.min((Helper.viewWidth - tableOffsetX) / 3, Helper.scaleX(config.table.infoColumnWidth)),
	}

	menu.displayGameModified()
end

function menu.viewCreated(layer, ...)
	if layer == config.optionsLayer then
		menu.optionTable = ...
	end
end

menu.updateInterval = 0.1
function menu.onUpdate()
	menu.optionsFrame:update()
end

function menu.onRowChanged(row, rowdata, uitable, modified, input, source)
end

function menu.onSelectElement(uitable, modified, row)
	row = row or Helper.currentTableRow[uitable]
end

function menu.closeMenu(dueToClose)
	Helper.closeMenu(menu, dueToClose)
	menu.cleanup()
end

function menu.onCloseElement(dueToClose)
	menu.param = nil
	Helper.closeMenuAndOpenNewMenu(menu, "OptionsMenu", nil, true)
end

init()
