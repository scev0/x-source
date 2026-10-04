-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef struct {
		uint32_t red;
		uint32_t green;
		uint32_t blue;
		uint32_t alpha;
	} Color;
	typedef struct {
		const char* id;
		Color color;
		float glowfactor;
	} ColorMapEntry;
	typedef struct {
		uint32_t width;
		uint32_t height;
		uint32_t xHotspot;
		uint32_t yHotspot;
	} CursorInfo;

	bool GetColorMapEntry(const char* id, ColorMapEntry* result);
	int GetConfigSetting(const char*const setting);
	CursorInfo GetCurrentCursorInfo();
	float GetTextHeight(const char*const text, const char*const fontname, const float fontsize, const float wordwrapwidth);
	float GetUIScale(const bool scalewithresolution);
	bool IsVRMode();
]]

--- Wrapper ---

local origffistring = ffi.string
ffi.string = function(data) 
	if data ~= nil then
		return origffistring(data)
	else
		DebugError("Invalid parameter for ffi.string() in dialogmenu. Check caller!")
		DebugError(TraceBack())
		return ""
	end
end

local function getColor(id)
	local buf = ffi.new("ColorMapEntry")
	if C.GetColorMapEntry(id, buf) then
		return { r = buf.color.red, g = buf.color.green, b = buf.color.blue, a = buf.color.alpha, glow = buf.glowfactor }
	else
		return { r = 255, g = 0, b = 255, a = 60, glow = 0 }
	end
end

-- settings
local config = {
	scalingFactor            = 0.0004, -- factor the presentation is scaled in-game (VR-mode-scale)

	nativePresentationWidth  = 1280,

	dialogButtonList = { 315, 270, 225, 45, 90, 135 }, -- positions (in degree) of the buttons in the dialog menu

	color = {
		normal = { -- blue text on blue background
			["text"] = getColor("dialogmenu_normal_text"),
			["background"] = getColor("dialogmenu_normal_background"),
		},
		instant = { -- blue text on blue background
			["text"] = getColor("dialogmenu_instant_text"),
			["background"] = getColor("dialogmenu_instant_text"),
		},
		inactive = { -- grey text on black background
			["text"] = getColor("dialogmenu_inactive_text"),
			["background"] = getColor("dialogmenu_inactive_text"),
		},
		selected = { -- white text on white background
			["text"] = getColor("dialogmenu_selected_text"),
			["background"] = getColor("dialogmenu_selected_text"),
		},
		centerbutton = { -- white text on white background
			["unselected"] = getColor("dialogmenu_center_unselected"),
			["selected"] = getColor("dialogmenu_center_selected"),
		}
	},

	buttonSwitchMap = { -- settings to configure the to-be-selected button priority based on the current selected button and the select-direction
		[0] = {
			["up"]    = {1, 3},
			["down"]  = {3, 6},
			["left"]  = {2, 1, 3},
			["right"] = {5, 4, 6},
		},
		[1] = {
			["up"]    = {},
			["down"]  = {2, 3},
			["left"]  = {},
			["right"] = {4, 5, 6},
		},
		[2] = {
			["up"]    = {1},
			["down"]  = {3},
			["left"]  = {},
			["right"] = {4, 3, 5},
		},
		[3] = {
			["up"]    = {2, 1},
			["down"]  = {},
			["left"]  = {},
			["right"] = {6, 5, 4},
		},
		[4] = {
			["up"]    = {},
			["down"]  = {5, 6},
			["left"]  = {1, 2, 3},
			["right"] = {},
		},
		[5] = {
			["up"]    = {4},
			["down"]  = {6},
			["left"]  = {2, 1, 3},
			["right"] = {},
		},
		[6] = {
			["up"]    = {5, 4},
			["down"]  = {},
			["left"]  = {3, 2, 1},
			["right"] = {},
		}
	},

	-- #coreUIMed - rethink this design --- should be better to link that to the widget system directly... no?
	mouseOverText = {
		maxWidth = 150, -- max width of the mouse over text (so excluding border!)
		offsetX  = 5,   -- offset from the mouse cursor to the mouse over text box
		borderSize = {
			right  = 5,
			left   = 5,
			top    = 2,
			bottom = 3
		},
		fontsize = 9    -- the fontsize in the native presentation size
	},

	glowfactors = {
		text = 0.5,
	},
}

-- private member data
local private = {
	autoLock = nil,              -- the time, when the presentation should lock itself (nil, if it shouldn't lock)
	centerButtonElement = nil,   -- the dialog menu's center button element
	interactionEnabled = false,  -- indicates whether interacting with the current dialog menu
	previousAngle = nil,         -- previous updated angle
	curButton = 0,               -- current selected button
	numButtons = 0,              -- number of buttons, the player can select
	buttonList = {},             -- the current button list
	backgroundElement = nil,     -- the dialog menu background element
	dialogButtonList = {         -- list of dialog buttons
		-- [x] = {                -- the button number
			-- [active]           -- indacates whether the button is active
			-- [selectable]       -- indicates whether the button is selectable
			-- [immediate]        -- indicates whether the button is in immediate mode
			-- [element]          -- the button component
			-- [mousePickElement] -- the mouse pick element
			-- [mouseOverText]    -- the to-be-displayed mouse over text, if the mouse hovers over the button
		-- }
	},
	newAction = false,                -- indicates whether a new action has been chosen
	dialogMenuShown = false,          -- indicates whether at the moment the dialog menu is displayed
	autoSelection = false,            -- indicates whether automatic button selection (gamepad mode) is used
	lastStartDialogTime = 0,          -- time when the last start dialog event occurred
	pendingShowDialogMenu = false,    -- indicates whether a new dialog is scheduled to be displayed
	mouseOver = nil,                  -- the button the mouse is currently hovering over
	joystickOver = nil,               -- the button currently highlighted by the joystick
	mouseOverElement = nil,           -- the mousovertext element
	mouseOverTextElement = nil,       -- the mouse over text element
	mouseOverBackgroundElement = nil, -- the mouse over background element
	mouseOverText = nil,              -- information about the current mouse over text display
	mouseOverFontSize = nil,          -- the font size of the mouse over text
	curMousePickElement = nil,        -- the current mouse pick element (if any)
	clampMouseOverTips = false,       -- indicates whether we are clamping the mouse over tips to the screen borders
	enableMouseOverText = false,      -- indicates whether mouse over text is enabled (in the configs)
	viewHeight = nil,                 -- the presentation height
	viewWidth = nil                   -- the presentation width
}

-- local functions forward declarations
local calculateHalfMaxHorizontalScreenExtents
local calculateHalfMaxVerticalScreenExtents
local clickDialogButton
local deg2rad
local initMousePicking
local initScale
local onButtonSelectUp
local onButtonSelectDown
local onButtonSelectRight
local onButtonSelectLeft
local onDialog1MouseClick
local onDialog2MouseClick
local onDialog3MouseClick
local onDialog4MouseClick
local onDialog5MouseClick
local onDialog6MouseClick
local onDialog1MouseOver
local onDialog2MouseOver
local onDialog3MouseOver
local onDialog4MouseOver
local onDialog5MouseOver
local onDialog6MouseOver
local onDialog1POVOver
local onDialog2POVOver
local onDialog3POVOver
local onDialog4POVOver
local onDialog5POVOver
local onDialog6POVOver
local onEnableMouseOverText
local onEnterDialogMenu
local onInputModeChanged
local onLeaveDialogMenu
local onStartDialog
local onStopDialog
local onUnlock
local hideDialogMenu
local initButtonList
local normalizeAngle
local leaveDialogMenu
local removeAutoLock
local resetScheduledShowDialogMenu
local scheduleAutoLock
local scheduleShowDialogMenu
local selectDialogButton
local setColorHelper
local setDialogButtonColor
local setMouseOverPosition
local setMouseOverTextEnabled
local showDialogMenu
local switchButton
local unmapDialogButton
local unselectDialogButton
local unselectMouseJoystickButton
local updateDialogMenuButtons
local updateSelectedButton
local updateSelection
local updateStates

---------------------------------
-- Gameface lifetime functions --
---------------------------------
function self:onInitialize()
	local scene           = getElement("Scene")
	local contract        = getElement("UIContract", scene)
	local uiAnchorElement = getElement("Layer.ui_anchor", scene)
	local dialogelement   = getElement("dialog menu", uiAnchorElement)

	-- retrieve elements
	private.mouseOverElement           = getElement("popupmenu", uiAnchorElement)
	private.mouseOverTextElement       = getElement("Text", private.mouseOverElement)
	private.mouseOverBackgroundElement = getElement("Rectangle", private.mouseOverElement)
	private.centerButtonElement        = getElement("centerbutton", dialogelement)
	private.backgroundElement          = getElement("vr_pointer_blocker", private.centerButtonElement)

	setAttribute(private.mouseOverTextElement, "glowfactor", config.glowfactors.text)

	-- retrieve dialog button list elements
	for i = 1, 6 do
		local buttonElement = getElement("button"..i, dialogelement)
		private.dialogButtonList[i] = {
			["element"]             = buttonElement,
			["colorElements"]       = {
				-- #coreUILow - reduce to non-array since only a single element left
				getElement("bracket.Material1663", buttonElement)
			},
			["text"]                = getElement("Text", buttonElement),
			["instantElement"]      = getElement("instant", buttonElement),
			["shortcutElement"]     = getElement("shortcut", buttonElement),
			["shortcutTextElement"] = getElement("shortcut.Text", buttonElement),
			-- #coreUILow - add assumption that z-position of mousePickElement equals z-position of popupmenu - otherwise slight offset expected for mouse over text
			["mousePickElement"]    = getElement("mousepick", buttonElement)
		}
	end

	-- initialize render related settings
	local vrMode               = C.IsVRMode()
	private.clampMouseOverTips = not vrMode -- only clamp the mouse over tips to the screen border, if we are in 1:1-mapped mode (aka: not in VRMode)
	-- Note: For the VR version, we explicitly do not want that a change in resolution changes the relative size of UI elements (i.e. they should not become smaller on higher resolutions) but rather leave it completely up to the user to adjust the actual UI
	--       scale via the ui scale config setting.
	initScale(uiAnchorElement, dialogelement, C.GetUIScale(not vrMode))
	private.viewWidth, private.viewHeight = getScreenInfo()

	-- load config settings
	setMouseOverTextEnabled(C.GetConfigSetting("mouseovertext") ~= 0)

	registerForEvent("enterDialogMenu", contract, onEnterDialogMenu)
	registerForEvent("leaveDialogMenu", contract, onLeaveDialogMenu)
	registerForEvent("startDialog", contract, onStartDialog)
	registerForEvent("stopDialog", contract, onStopDialog)
	registerForEvent("inputModeChanged", contract, onInputModeChanged)
	registerForEvent("onUnlock", contract, onUnlock)

	-- setup shortcut support
	registerForEvent("dialog1", contract, onDialog1MouseClick)
	registerForEvent("dialog2", contract, onDialog2MouseClick)
	registerForEvent("dialog3", contract, onDialog3MouseClick)
	registerForEvent("dialog4", contract, onDialog4MouseClick)
	registerForEvent("dialog5", contract, onDialog5MouseClick)
	registerForEvent("dialog6", contract, onDialog6MouseClick)

	-- setup shortcut support
	registerForEvent("dialogPOV1", contract, onDialog1POVOver)
	registerForEvent("dialogPOV2", contract, onDialog2POVOver)
	registerForEvent("dialogPOV3", contract, onDialog3POVOver)
	registerForEvent("dialogPOV4", contract, onDialog4POVOver)
	registerForEvent("dialogPOV5", contract, onDialog5POVOver)
	registerForEvent("dialogPOV6", contract, onDialog6POVOver)

	-- setup entry-cycling (up/down/left/right)
	registerForEvent("dialogMenuUp",    contract, onButtonSelectUp)
	registerForEvent("dialogMenuDown",  contract, onButtonSelectDown)
	registerForEvent("dialogMenuRight", contract, onButtonSelectRight)
	registerForEvent("dialogMenuLeft",  contract, onButtonSelectLeft)

	-- mouse over text config
	registerForEvent("enableMouseOverText", contract, onEnableMouseOverText)

	-- notify on game events
	NotifyOnStartDialog(contract)
	NotifyOnStopDialog(contract)

	-- setup elements eligable for mouse-picking
	initMousePicking()

	-- initialize states
	updateStates()
end

function self:onUpdate()
	-- selection updates are only performed in gamepad mode
	if private.interactionEnabled and private.autoSelection then
		updateSelection()
	end

	-- process scheduled showDialogMenu events
	if private.pendingShowDialogMenu then
		showDialogMenu()
	end

	if private.mouseOverText then
		setMouseOverPosition()
	end

	if private.autoLock ~= nil and getElapsedTime() >= private.autoLock then
		removeAutoLock()
		LockPresentation()
		HidePresentation()
	end
end

-------------------------------------
-- Presentation specific callbacks --
-------------------------------------
function onButtonSelectUp()
	switchButton("up")
end

function onButtonSelectDown()
	switchButton("down")
end

function onButtonSelectRight()
	switchButton("right")
end

function onButtonSelectLeft()
	switchButton("left")
end

function onDialog1MouseClick(_, delayed)
	if not delayed then
		clickDialogButton(1)
	end
end

function onDialog2MouseClick(_, delayed)
	if not delayed then
		clickDialogButton(2)
	end
end

function onDialog3MouseClick(_, delayed)
	if not delayed then
		clickDialogButton(3)
	end
end

function onDialog4MouseClick(_, delayed)
	if not delayed then
		clickDialogButton(4)
	end
end

function onDialog5MouseClick(_, delayed)
	if not delayed then
		clickDialogButton(5)
	end
end

function onDialog6MouseClick(_, delayed)
	if not delayed then
		clickDialogButton(6)
	end
end

function onDialog1MouseOver()
	-- #coreUIMed - consider moving to a wrapper function (correspondingly then the code in onDialogXPOVOVer())
	unselectMouseJoystickButton()
	private.mouseOver = 1
	selectDialogButton(1)
	if private.enableMouseOverText then
		showMouseOverText(1)
	end
end

function onDialog2MouseOver()
	unselectMouseJoystickButton()
	private.mouseOver = 2
	selectDialogButton(2)
	if private.enableMouseOverText then
		showMouseOverText(2)
	end
end

function onDialog3MouseOver()
	unselectMouseJoystickButton()
	private.mouseOver = 3
	selectDialogButton(3)
	if private.enableMouseOverText then
		showMouseOverText(3)
	end
end

function onDialog4MouseOver()
	unselectMouseJoystickButton()
	private.mouseOver = 4
	selectDialogButton(4)
	if private.enableMouseOverText then
		showMouseOverText(4)
	end
end

function onDialog5MouseOver()
	unselectMouseJoystickButton()
	private.mouseOver = 5
	selectDialogButton(5)
	if private.enableMouseOverText then
		showMouseOverText(5)
	end
end

function onDialog6MouseOver()
	unselectMouseJoystickButton()
	private.mouseOver = 6
	selectDialogButton(6)
	if private.enableMouseOverText then
		showMouseOverText(6)
	end
end

function onDialog1POVOver()
	unselectMouseJoystickButton()
	private.joystickOver = 1
	selectDialogButton(1)
end

function onDialog2POVOver()
	unselectMouseJoystickButton()
	private.joystickOver = 2
	selectDialogButton(2)
end

function onDialog3POVOver()
	unselectMouseJoystickButton()
	private.joystickOver = 3
	selectDialogButton(3)
end

function onDialog4POVOver()
	unselectMouseJoystickButton()
	private.joystickOver = 4
	selectDialogButton(4)
end

function onDialog5POVOver()
	unselectMouseJoystickButton()
	private.joystickOver = 5
	selectDialogButton(5)
end

function onDialog6POVOver()
	unselectMouseJoystickButton()
	private.joystickOver = 6
	selectDialogButton(6)
end

function onEnableMouseOverText(_, enable)
	setMouseOverTextEnabled(enable)
end

function onEnterDialogMenu()
	if not private.dialogMenuShown then
		return -- no dialog menu displayed atm, hence skip the enter call
	end

	private.interactionEnabled = true

	private.newAction = true
	private.previousAngle = nil
	private.curButton = 0
end

function onInputModeChanged(_, mode)
	if mode == "gamepad" then
		private.autoSelection = true
	else -- mouse mode (aka: either "mouseSteering", "mouseCursor"), joystick mode, or touch mode
		private.autoSelection = false
	end
end

function onLeaveDialogMenu()
	if not private.interactionEnabled then
		-- currently no interaction enabled --- this prevents issues, if the player presses/releases the A-button rather quickly so that a preceding call
		-- to onEnterDialogMenu would have performed nothing (since neither a dialog menu, no dialog menu was active at that time)
		return
	end

	private.interactionEnabled = false

	local button = 0
	if private.joystickOver then
		button = private.joystickOver
	else
		button = private.curButton
	end
	leaveDialogMenu(button)
end

function onStartDialog(_, time)
	private.lastStartDialogTime = time

	-- note: we do not directly call showDialogMenu() here, since a hide-dialog-menu animation might be in progress
	-- processing the showDialogMenu event directly would result in the dialog menu showing the updated dialog menu text entries for the
	-- next dialog prematuraly (i.e. already during the disappear animation)
	scheduleShowDialogMenu()
end

function onStopDialog(_, time)
	if private.lastStartDialogTime > time then
		return -- ignore the call, we got a stopDialog-event after a start dialog event -- keep the current dialog
	end

	hideDialogMenu()
end

function onUnlock()
	-- if we were locked, we might have missed some events -- get the proper gamestate to compensate for that
	updateStates()

	-- also requery the current mouse over text config setting (which we might have missed as well if we were locked)
	setMouseOverTextEnabled(C.GetConfigSetting("mouseovertext") ~= 0)
end

-------------------------------------
-- Presentation specific functions --
-------------------------------------
-- same as calculateHalfMaxVerticalScreenExtents() but for the maximum visible screen's x-position
function calculateHalfMaxHorizontalScreenExtents(element)
	-- see commetns in calculateHalfMaxVerticalScreenExtents()
	-- in addition to the calculation we'd have to convert the vertical FOV to the horizontal one, which we do by multiplying the vertical FOV with the screen aspect ratio which is calculated using the screen height/width

	-- #coreUIMed - generalize this code - in principle only the cameraFOV differs between the horizontal and vertical calculations
	-- #coreUIMed - reenable the code - see P1DEV-471
	--local elementMatrix = Matrix.new()
	--calculateGlobalTransform(element, elementMatrix)
	--local cameraElement = getElement("Scene.Layer.Camera")
	--local cameraMatrix = Matrix.new()
	--calculateGlobalTransform(cameraElement, cameraMatrix)
	--cameraMatrix:invert()
	--elementMatrix = matrix.multiply(cameraMatrix, elementMatrix)
	--local elementCameraDistance = elementMatrix._43

	-- note: cameraFOV can (at least by design) change every frame (due to the camera synchronization) - hence retrieve the value every time
	-- #coreUILow - could be stored and retrieved just once per frame
	--local cameraVerticalFOV = getAttribute(cameraElement, "fov")
	--local cameraHorizontalFOV = cameraVerticalFOV / private.viewHeight * private.viewWidth
	--return math.tan(deg2rad(cameraHorizontalFOV/2)) * elementCameraDistance / config.scalingFactor
	return private.viewWidth / 2
end

-- the function calculates the maximum visible screen's y-position which would still be visible on screen given the position represented by the given element
function calculateHalfMaxVerticalScreenExtents(element)
	-- the simple calculation to determine the max y-position is
	-- maxY = tan(cameraVerticalFOV/2) * distanceOfElementToCamera
	-- however the camera is rotated (i.e. synchronized camera) so that we have to transform the whole space into camera space (that's what we do by taking the inverted camera matrix and multiplying the cameraMatrix with the element's global transformation matrix)
	-- in addition we also have to compensate for the scale factor of the uiAnchorElement (i.e. config.scalingFactor)

	-- note: this calculation still seems to be flawed - testing it shows that the calculated maxY-value seems reasonable (f.e. ~330 on 720 vertical resolutions) but testing it showed still that only part of the box was visible
	-- task put on hold for the time being - P1DEV-471

	-- #coreUIMed - store the camera element rather than retrieving it every time
	-- #coreUIMed - generalize this code - in principle only the cameraFOV differs between the horizontal and vertical calculations
	-- #coreUIMed - reenable the code - see P1DEV-471
	--local elementMatrix = Matrix.new()
	--calculateGlobalTransform(element, elementMatrix)
	--local cameraElement = getElement("Scene.Layer.Camera")
	--local cameraMatrix = Matrix.new()
	--calculateGlobalTransform(cameraElement, cameraMatrix)
	--cameraMatrix:invert()
	--elementMatrix = matrix.multiply(cameraMatrix, elementMatrix)
	--local elementCameraDistance = elementMatrix._43

	-- note: cameraFOV can (at least by design) change every frame (due to the camera synchronization) - hence retrieve the value every time
	-- #coreUILow - could be stored and retrieved just once per frame
	--local cameraVerticalFOV = getAttribute(cameraElement, "fov")
	--return math.tan(deg2rad(cameraVerticalFOV/2)) * elementCameraDistance / config.scalingFactor

	-- fall back to the old code which is at least still accurate for the 1:1-mapped mode in XR (and XRVR non-VR mode)
	return private.viewHeight / 2
end

function clickDialogButton(button)
	if not private.dialogMenuShown or not private.dialogButtonList[button].selectable then
		-- nothing to do, if dialog menu is not shown (this can happen when quickly clicking onto another button, for example, after having clicked on a button while the close animation is being played)
		-- there's also nothing to do if the button is not selecatble at all (can happen when player presses a shortcut key assigned to an unselectable option)
		return
	end

	private.autoSelection = false
	leaveDialogMenu(button)
end

function deg2rad(angle)
	return angle * math.pi / 180
end

function initMousePicking()
	-- init picking areas for dialog menu
	local mouseOverArray = {
		onDialog1MouseOver,
		onDialog2MouseOver,
		onDialog3MouseOver,
		onDialog4MouseOver,
		onDialog5MouseOver,
		onDialog6MouseOver
	}
	local mouseClickArray = {
		onDialog1MouseClick,
		onDialog2MouseClick,
		onDialog3MouseClick,
		onDialog4MouseClick,
		onDialog5MouseClick,
		onDialog6MouseClick
	}
	for i, entry in ipairs(private.dialogButtonList) do
		local element = entry.element
		registerForEvent("onGroupedMouseOver", element, mouseOverArray[i])
		registerForEvent("onGroupedMouseOut", element, unselectMouseJoystickButton)
		registerForEvent("onMouseClick", element, mouseClickArray[i])
		RegisterMouseInteractions(element)
	end

	-- also register the background element, so we do hit something with the VR pointer even in the gaps in-between buttons (or in the area where buttons are not active)
	RegisterMouseInteractions(private.backgroundElement)
end

function hideDialogMenu()
	-- if we are about to show a dialog menu but got the hideDialog-menu call before we actually started showing the menu, prevent the dialog menu from being
	-- displayed at all (this fixes XT-2187 and related situations)
	resetScheduledShowDialogMenu()

	if not private.dialogMenuShown then
		return -- already hidden
	end

	DialogMenuHidden()

	-- hide the dialog menu elements
	goToSlide(private.centerButtonElement, "inactive")
	-- #coreUILow better set private.numButtons when dialog is active and use it here???
	local numButtons = #private.dialogButtonList
	for i = 1, numButtons do
		if private.dialogButtonList[i].active then
			goToSlide(private.dialogButtonList[i].element, "inactive")
			goToSlide(private.dialogButtonList[i].instantElement, "inactive")
			goToSlide(private.dialogButtonList[i].shortcutElement, "inactive")
		end
	end

	scheduleAutoLock(getElapsedTime())
	hideMouseOverText()
	private.dialogMenuShown = false
end

function hideMouseOverText()
	if private.mouseOverText == nil then
		return -- nothing to do
	end

	goToSlide(private.mouseOverElement, "inactive")
	private.mouseOverText = nil
	private.curMousePickElement = nil
end

function initButtonList(buttons)
	-- convert angle (deg2rad) and normalize it
	private.buttonList = {}
	for _, angle in ipairs(buttons) do
		angle = deg2rad(angle)
		table.insert(private.buttonList, normalizeAngle(angle))
	end
end

function initScale(anchorElement, dialogMenuElement, uiScale)
	-- apply the overall (normalizing) scale factor - compensates for world-space positioning and presentation setup scaling factor
	-- note: We interpret the scaling factor here the way that the overall presentation setup needs to be scaled so to fit into the worldspace correctly.
	--       Hence, because of that logic/definition we also scale the z-axis.
	setAttribute(anchorElement, "scale.x", config.scalingFactor)
	setAttribute(anchorElement, "scale.y", config.scalingFactor)
	setAttribute(anchorElement, "scale.z", config.scalingFactor)

	-- scale all elements separately based on the user defined scaling factor (note: scaling only done for x/y axes since we do not want to impact the depth of elements which are normally orthographic to the camera and scaling the depth could also result
	-- in unintended side effects like mouse-picking inaccuracies due to floating point precision issues if the mouse-ray would no longer be determined to have hit the too thin element (correspondingly this would then also result in rendering issues)

	-- scale dialog menu
	-- #coreUILow - the best results we'd actually get by scaling each separate element and the text elements using the proper font size (rather than applying just a single scale factor on top of everything)
	--              but doing that is quite a workload, since we'd not only have to scale each element but also reposition it as well - hence for now it should be good enough to stick with upscaling of the smaller fonts
	local defaultScale = getAttribute(dialogMenuElement, "scale.x")
	setAttribute(dialogMenuElement, "scale.x", defaultScale * uiScale)
	defaultScale = getAttribute(dialogMenuElement, "scale.y")
	setAttribute(dialogMenuElement, "scale.y", defaultScale * uiScale)

	-- the popup menu is recalculating the sizes/positions dynamically based on the displayed text
	-- hence it suffices to set the used fontsize correctly to achieve correct scaling
	private.mouseOverFontSize = config.mouseOverText.fontsize * uiScale
	setAttribute(private.mouseOverTextElement, "size", private.mouseOverFontSize)
end

function leaveDialogMenu(button)
	if button ~= 0 then
		PlaySound("ui_menu_dlg_btn_select_core")
		SelectDialogOption(button)
		hideDialogMenu()
	else
		PlaySound("ui_menu_dlg_btn_selectinvalid_core")
		unselectDialogButton(0)	
	end
end

function normalizeAngle(angle)
	while angle < 0 do
		angle = angle + 2*math.pi
	end

	while angle >= 2*math.pi do
		angle = angle - 2*math.pi
	end

	return angle
end

function removeAutoLock()
	private.autoLock = nil
end

function resetScheduledShowDialogMenu()
	private.pendingShowDialogMenu = false
end

function scheduleAutoLock(time)
	private.autoLock = time
end

function scheduleShowDialogMenu()
	removeAutoLock() -- stop autolock (if it's in progress) since we are about to show the dialog menu again
	private.pendingShowDialogMenu = true
end

function selectDialogButton(button)
	if not private.dialogMenuShown then
		return -- nothing to do, if dialog menu is not shown (this can happen for mouseOver events, for example, after having clicked on a button while the close animation is being played)
	end

	if button == 0 then
		PlaySound("ui_menu_dlg_btn_point_core")
		goToSlide(private.centerButtonElement, "selected")
		setColorHelper(getElement("dialog_new_button.Material1611", private.centerButtonElement), nil, config.color.centerbutton.selected)
		setColorHelper(getElement("Dialog_new_ring.Material1623", private.centerButtonElement), nil, config.color.centerbutton.selected)
	else
		if private.dialogButtonList[button].selectable then
			PlaySound("ui_menu_dlg_btn_point_core")
			goToSlide(private.dialogButtonList[button].element, "selected")
			setDialogButtonColor(private.dialogButtonList[button], true, private.dialogButtonList[button].immediate, true)
		end
	end
end

function setColorHelper(element, parent, color)
	SetDiffuseColor(parent or element, color.r, color.g, color.b)
	setAttribute(parent or element, "opacity", color.a)
	setAttribute(element, "glowfactor", color.glow)
end

function setDialogButtonColor(buttonTableEntry, selectable, immediate, selected)
	local color = config.color.normal
	if selected then
		color = config.color.selected
	elseif not selectable then
		color = config.color.inactive
	elseif immediate then
		color = config.color.instant
	-- else use the normal color
	end

	setAttribute(buttonTableEntry.text, "textcolor.r", color.text.r)
	setAttribute(buttonTableEntry.text, "textcolor.g", color.text.g)
	setAttribute(buttonTableEntry.text, "textcolor.b", color.text.b)
	setAttribute(buttonTableEntry.text, "glowfactor", color.text.glow)

	setAttribute(buttonTableEntry.shortcutTextElement, "textcolor.r", color.text.r)
	setAttribute(buttonTableEntry.shortcutTextElement, "textcolor.g", color.text.g)
	setAttribute(buttonTableEntry.shortcutTextElement, "textcolor.b", color.text.b)
	setAttribute(buttonTableEntry.shortcutTextElement, "glowfactor", color.text.glow)

	for _, element in ipairs(buttonTableEntry.colorElements) do
		SetDiffuseColor(element, color.background.r, color.background.g, color.background.b)
	end
end

function showDialogMenu()
	-- stop the auto-lock of the script
	removeAutoLock()

	local dialogButtonList = {}

	-- activate the dialog menu
	goToSlide(private.centerButtonElement, "unselected")
	setColorHelper(getElement("dialog_new_button.Material1611", private.centerButtonElement), nil, config.color.centerbutton.unselected)
	setColorHelper(getElement("Dialog_new_ring.Material1623", private.centerButtonElement), nil, config.color.centerbutton.unselected)
	local numButtons = #private.dialogButtonList
	local text
	local active, selectable, immediate, shortcutKey
	for i = 1, numButtons do
		text, selectable, immediate, shortcutKey, mouseOverText = GetDialogOption(i)
		active = text ~= ""
		private.dialogButtonList[i].active = active
		private.dialogButtonList[i].immediate = immediate
		private.dialogButtonList[i].selectable = active and selectable
		private.dialogButtonList[i].mouseOverText = mouseOverText
		if active then
			goToSlide(private.dialogButtonList[i].element, "unselected")
			setAttribute(private.dialogButtonList[i].text, "textstring", text)
			setDialogButtonColor(private.dialogButtonList[i], selectable, immediate, false)
			if selectable then
				table.insert(dialogButtonList, config.dialogButtonList[i])
				goToSlide(private.dialogButtonList[i].shortcutElement, "active")
				setAttribute(private.dialogButtonList[i].shortcutTextElement, "textstring", shortcutKey)
			else
				goToSlide(private.dialogButtonList[i].shortcutElement, "inactive")
			end
			if immediate then
				goToSlide(private.dialogButtonList[i].instantElement, "active")
			else
				goToSlide(private.dialogButtonList[i].instantElement, "inactive")
			end
		end
	end

	initButtonList(dialogButtonList)

	-- notifies the game that the dialog menu is displayed (i.e. if a conversation is started, for instance)
	DialogMenuShown()

	private.curButton = 0 -- reset the current button from the previous menu (note: while this will also be reset in onEnterDialogMenu(), this won't be the case for the sticky mode as used with the joystick directional selection handling)
	private.dialogMenuShown = true
	private.pendingShowDialogMenu = false -- we displayed the dialog menu -> reset the state

	-- restore the currently selected button
	if private.mouseOver ~= nil then
		selectDialogButton(private.mouseOver)
	end
end

function setMouseOverPosition()
	-- note: we use the mouse pick element for the relative mouse position, since that element covers the entire dialog menu button box
	local posX, posY = GetRelativeMousePosition(private.curMousePickElement, true)
	if (posX == nil) or ((posX == 0) and (posY == 0)) then
		return -- just keep the text where it was before (note: this can happen in edge cases since we don't ensure atm that the mouse-pick element covers all elements of the current button (f.e. overlapping text is not handled atm))
		       -- #coreUILow - once we ensure this, we can get rid of this check here (and replace it with an assumption check)
			   -- second case happens when the element is first hit and MouseHitPoint is not set yet. 
	end

	local halfMouseOverBoxWidth = private.mouseOverText.width / 2
	local halfMousOverBoxHeight = private.mouseOverText.height / 2

	local globalX = getAttribute(private.curMousePickElement, "position.x") + getAttribute(getElement("parent", private.curMousePickElement), "position.x")
	local globalY = getAttribute(private.curMousePickElement, "position.y") + getAttribute(getElement("parent", private.curMousePickElement), "position.y")

	-- #coreUILow - actually the calculation for the posX is wrong - the cursor is on the screen (i.e. z = d) while the popup/mousepick element is on an element in worldspace (i.e. z = d+z))
	--              hence we'd actually have to adjust the cursorinfo here to calculate the proper projected values in world space - for simplicity we stick woth the actual offsets for now which is kind of good enough
	local offsetX = posX + globalX - halfMouseOverBoxWidth + config.mouseOverText.offsetX
	local offsetY = -posY + globalY + halfMousOverBoxHeight

	if private.clampMouseOverTips then
		-- #coreUIHigh - P1DEV-471 - clamping logic broken (XR/XRVR: non-notable)

		local minY = -calculateHalfMaxVerticalScreenExtents(private.curMousePickElement)
		local maxX = calculateHalfMaxHorizontalScreenExtents(private.curMousePickElement)

		-- note: box is left/top anchored to the mouse cursor by default --- hence only need to check whether it goes off screen to the right or bottom screen borders
		--       (aka: no need to check for left and top screen borders)
		if offsetX + halfMouseOverBoxWidth > maxX then
			-- swap mouse over tooltip anchor point from upper left to upper right
			offsetX = posX - private.mouseOverText.cursorinfo.xHotspot - config.mouseOverText.offsetX - halfMouseOverBoxWidth
		end
		if offsetY - halfMousOverBoxHeight < minY then
			-- clamp at bottom of the screen
			offsetY = minY + halfMousOverBoxHeight
		end
	end

	setAttribute(private.mouseOverElement, "position.x", offsetX)
	setAttribute(private.mouseOverElement, "position.y", offsetY)
end

function setMouseOverTextEnabled(enable)
	if not enable then
		hideMouseOverText()
	end

	-- note: in theory we'd also have to handle the case of enabling the mouse over text config setting here
	-- however, since pracitcally this only occurs in cases where the dialog menu wouldn't be displayed (or at least the mouse cursor wouldn't remain over a selected dialog menu button)
	-- this is nothing we need to bother about in practice

	private.enableMouseOverText = enable
end

function showMouseOverText(button)
	-- #coreUIMed - better have this integrated in the widget system
	local text = private.dialogButtonList[button].mouseOverText
	if text == "" then
		return -- nothing to display
	end

	-- properties
	local fontname            = getAttribute(private.mouseOverTextElement, "font")
	local numlines, textWidth = GetTextNumLines(text, fontname, private.mouseOverFontSize, config.mouseOverText.maxWidth)
	textWidth                 = textWidth or config.mouseOverText.maxWidth
	local width               = textWidth + config.mouseOverText.borderSize.right + config.mouseOverText.borderSize.left
	local textHeight          = C.GetTextHeight(text, fontname, private.mouseOverFontSize, textWidth)
	local height              = textHeight + config.mouseOverText.borderSize.top + config.mouseOverText.borderSize.bottom

	private.mouseOverText = {
		width        = width,
		height       = height,
		cursorinfo   = C.GetCurrentCursorInfo(),
		overrideText = private.mouseOverOverrideText
	}
	private.curMousePickElement = private.dialogButtonList[button].mousePickElement

	-- activate slide
	goToSlide(private.mouseOverElement, "active")

	-- scaling
	setAttribute(private.mouseOverBackgroundElement, "scale.x", width / 100)
	setAttribute(private.mouseOverBackgroundElement, "scale.y", height / 100)

	-- position
	setAttribute(private.mouseOverTextElement, "position.x", -textWidth / 2)
	setAttribute(private.mouseOverTextElement, "position.y", textHeight / 2 + config.mouseOverText.borderSize.top)
	setMouseOverPosition()

	-- text
	setAttribute(private.mouseOverTextElement, "boxwidth", textWidth / config.nativePresentationWidth)
	setAttribute(private.mouseOverTextElement, "textstring", text)
end

function switchButton(direction)
	-- #coreUIMed -- add assume(private.dialogMenuShown)
	if not private.dialogMenuShown then
		return -- nothing to do, if dialog menu is not shown
	end

	local priorities = config.buttonSwitchMap[private.curButton][direction]
	-- #coreUIMed -- add assume(priorities ~= nil)?
	for _, num in ipairs(priorities) do
		if private.dialogButtonList[num].selectable then
			updateDialogMenuButtons(private.curButton, num)
			private.joystickOver = num
			return
		end
	end

	-- no error to end up here - in this case there simply is no active suitable next button to switch to and hence we simply stick with the current one (i.e. noop)
end

function unmapDialogButton(button)
	if button == 0 then
		return 0
	end

	local numButtons = #private.dialogButtonList
	for i = 1, numButtons do
		if private.dialogButtonList[i].selectable then
			if button == 1 then
				return i
			else
				button = button - 1
			end
		end
	end

	DebugError("Presentation error in unmapDialogButton --- button "..tostring(button).." seems to exceed the number of active dialog buttons. Fallback returning 0.")

	return 0
end

function unselectDialogButton(button)
	if not private.dialogMenuShown then
		return -- nothing to do, if dialog menu is not shown (this can happen for mouseOut events, for example, after having clicked on a button while the close animation is being played)
	end

	if button == 0 then
		goToSlide(private.centerButtonElement, "unselected")
		setColorHelper(getElement("dialog_new_button.Material1611", private.centerButtonElement), nil, config.color.centerbutton.unselected)
		setColorHelper(getElement("Dialog_new_ring.Material1623", private.centerButtonElement), nil, config.color.centerbutton.unselected)
	else
		if private.dialogButtonList[button].selectable then 
			setDialogButtonColor(private.dialogButtonList[button], true, private.dialogButtonList[button].immediate, false)
			goToSlide(private.dialogButtonList[button].element, "unselected")
		end
	end
end

function updateDialogMenuButtons(oldButton, newButton)
	unselectMouseJoystickButton()

	-- the order is relevant, since oldButton could equal newButton for the initial call (aka both are 0)
	-- in that case the center button should be displayed as selected --- hence selectDialogButton() must be called last
	unselectDialogButton(oldButton)
	selectDialogButton(newButton)

	-- #coreUIMed - clean the dialog menu up a bit --- should only have one place where curButton is updated
	private.curButton = newButton
end

function unselectMouseJoystickButton()
	if private.mouseOver ~= nil then
		hideMouseOverText()
		unselectDialogButton(private.mouseOver)
		private.mouseOver = nil
	end
	if private.joystickOver then
		unselectDialogButton(private.joystickOver)
		private.joystickOver = nil
	end
end

function updateSelectedButton(angle)
	if angle == -1 then
		-- stick in the center
		private.curButton = 0
		return
	end

	local closestOption = 0 -- (i.e. no selection by default)
	local shortestdiff = nil
	for index, value in ipairs(private.buttonList) do
		local anglediff = math.abs(angle - value)
		anglediff = normalizeAngle(anglediff)
		if anglediff < math.pi / 2 and (shortestdiff == nil or anglediff < shortestdiff) then
			shortestdiff  = anglediff
			closestOption = index
		end
	end

	private.curButton = unmapDialogButton(closestOption)
end

function updateSelection()
	local _, angle = GetControllerInfo()
	if private.previousAngle == angle then
		-- stick hasn't been moved, nothing to do
		return
	end

	private.previousAngle = angle

	local oldButton = private.curButton
	updateSelectedButton(angle)
	local newButton = private.curButton

	if newButton ~= oldButton then
		private.newAction = true
	end

	if not private.newAction then
		return -- no action change
	end

	updateDialogMenuButtons(oldButton, newButton)

	private.newAction = false
end

function updateStates()
	-- reset the mouse-over state
	private.mouseOver = nil
	hideMouseOverText()

	-- reset the joystick POV state
	private.joystickOver = nil

	-- update input mode (in case it was changed)
	onInputModeChanged(nil, GetControllerInfo())

	-- get the proper initial state (in case the UI is reloaded or loaded after a conversation has already been started)
	if IsDialogActive() then
		-- note: we do a normal schedule show dialog menu here (rather than directly opening the menu), since we'd actually retrieve an onStartDialog()-event directly after an onUnlock-event
		-- if we would call showDialogMenu() here directly, we'd end up with two successive calls to display the dialog menu
		scheduleShowDialogMenu()
	else
		scheduleAutoLock(getElapsedTime())
	end
end
