-- no need for special unlock-handling
-- handling is done via calling ShowUI("compass") prior to issue "showCompass"-event

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
		const char* type;
		const char* control;
		uint32_t controlid;
		uint32_t contextid;
		bool active;
	} CompassMenuEntry;
	typedef struct {
		int x;
		int y;
	} Coord2D;

	void CompassMenuButtonPressed(const char* uisource, const char* buttonid);
	void CompassMenuButtonReleased(const char* uisource, const char* buttonid);
	void ForceMouseCursorVisible(bool forced);
	uint32_t GetAllColorMapEntries(ColorMapEntry* result, uint32_t resultlen);
	Coord2D GetCenteredMousePos(void);
	uint32_t GetCompassMenuMappings(CompassMenuEntry* result, uint32_t resultlen, const char* uisource);
	const char* GetLocalizedText(const uint32_t pageid, uint32_t textid, const char*const defaultvalue);
	uint32_t GetNumAllColorMapEntries(void);
	float GetTextWidth(const char*const text, const char*const fontname, const float fontsize);
	float GetUIScale(const bool scalewithresolution);
	bool IsVRMode();
]]

--- Wrapper ---

local origffistring = ffi.string
ffi.string = function(data) 
	if data ~= nil then
		return origffistring(data)
	else
		DebugError("Invalid parameter for ffi.string() in compass. Check caller!")
		DebugError(TraceBack())
		return ""
	end
end

-- global color lookup
Color = {}

local colorMetatable = {
	__index = function(table, key)
		DebugError(string.format("Color setup error: Tried to access non-existing color '%s'\n\n%s", tostring(key), TraceBack()))
		return { r = 255, g = 0, b = 255, a = 60, glow = 0 }
	end
}
setmetatable(Color, colorMetatable)

local function getColors()
	local n = C.GetNumAllColorMapEntries()
	if n > 0 then
		local buf = ffi.new("ColorMapEntry[?]", n)
		n = C.GetAllColorMapEntries(buf, n)
		for i = 0, n - 1 do
			local id = ffi.string(buf[i].id)
			Color[id] = { r = buf[i].color.red, g = buf[i].color.green, b = buf[i].color.blue, a = buf[i].color.alpha, glow = buf[i].glowfactor }
		end
	end
end

getColors()

-- settings
local config = {
	scalingFactor = 0.0004, -- factor the presentation is scaled in-game (used to scale the ui_anchor value)
	nativePresentationWidth = 1280,
	compassScale = 0.8,

	scaleElements = {
		"compass_core",
		"compass_pointer",
		"compass_background",
	},

	height = 28,
	font = "Zekton",
	fontsize = 12,
	coreFontSize = 24,
	textOffsetX = 5,
	textSpacing = 20,

	radius = 150,
	minWidth = 150,
	frameBorder = 10,
	highlightScale = 1.3,

	numButtons = 8,

	actionTextPageID = 1005,
	stateTextPageID = 1006,

	fadeInDuration = 0.1,

	core = {
		["INPUT_SOURCE_COMPASSMENU"] = {
			text = "1",
			core = Color["compass_1_ring_core"],
			pointer = Color["compass_1_ring_pointer"],
		},
		["INPUT_SOURCE_COMPASSMENU_2"] = {
			text = "2",
			core = Color["compass_2_ring_core"],
			pointer = Color["compass_2_ring_pointer"],
		},
	},
}

-- private member data
local private = {
	compassActive = false,			-- whether the presentation is active
	uiAnchorElement = nil,
	compassElement = nil,
	buttonElements = {},
}

-- local functions forward declarations
local onHideCompass
local onShowCompass
local activateCompass
local deactivateCompass
local hideCompass
local initScale
local showCompass

---------------------------------
-- Gameface lifetime functions --
---------------------------------
function self:onInitialize()
	local scene           = getElement("Scene")
	local contract        = getElement("UIContract", scene)
	private.uiAnchorElement = getElement("Layer.ui_anchor", scene)

	private.compassElement     = getElement("compass", private.uiAnchorElement)
	private.ringPointerElement = getElement("compass_pointer", private.compassElement)

	setElementColorAlpha(getElement("compass_background.Material129", private.compassElement), Color["compass_background"])

	registerForEvent("showCompass", contract, onShowCompass)
	registerForEvent("hideCompass", contract, onHideCompass)

	local buttonMaster = getElement("button", private.compassElement)
	private.buttonElements[1] = buttonMaster
	setElementTextColor(getElement("Text_shortcut", buttonMaster), Color["compass_button_text_shortcut"])
	registerMouseButton(private.buttonElements[1], 1)
	for i = 2, config.numButtons do
		private.buttonElements[i] = clone(buttonMaster, "button" .. i)
		registerMouseButton(private.buttonElements[i], i)
	end

	initScale(private.uiAnchorElement)

	LockPresentation()
end

function registerMouseButton(element, i)
	local backgroundElement = getElement("button", element)
	registerForEvent("onMouseDown", backgroundElement, function () return onMouseDown(i) end)
	registerForEvent("onMouseUp", backgroundElement, function () return onMouseUp(i) end)
	registerForEvent("onGroupedMouseOut", backgroundElement, function () return onMouseOut(i) end)
	RegisterMouseInteractions(backgroundElement)
end

function self:onUpdate()
	if not private.compassActive then
		return
	end

	if private.fadeInTime then
		local scale = config.compassScale * (1 - (private.fadeInTime - getElapsedTime()) / config.fadeInDuration)
		if scale >= config.compassScale then
			scale = config.compassScale
			private.fadeInTime = nil
		end
		setAttribute(private.compassElement, "scale.x", scale)
		setAttribute(private.compassElement, "scale.y", scale)
	end

	updateControllerSelection()
	updateMousePosition()

	for i = 1, config.numButtons do
		-- scale
		if i == private.selectedButton then
			setAttribute(private.buttonElements[i], "scale.x", config.highlightScale)
			setAttribute(private.buttonElements[i], "scale.y", config.highlightScale)
		else
			setAttribute(private.buttonElements[i], "scale.x", 1)
			setAttribute(private.buttonElements[i], "scale.y", 1)
		end

		-- color
		local materialElement = getElement("button.Material129", private.buttonElements[i])
		if not private.mappings[i] then
			setElementColorAlpha(materialElement, Color["compass_button_unmapped"])
		elseif not private.mappings[i].active then
			setElementColorAlpha(materialElement, Color["compass_button_inactive"])
		elseif i == private.selectedButton then
			setElementColorAlpha(materialElement, Color["compass_button_highlight"])
		else
			setElementColorAlpha(materialElement, Color["compass_button_normal"])
		end
	end
end

function updateControllerSelection()
	local _, angle = GetControllerInfo()
	if private.previousAngle == angle then
		-- stick hasn't been moved, nothing to do
		return
	end

	if angle ~= -1 then
		private.selectedButton = math.ceil(((math.deg(angle) + (360 / (2 * config.numButtons))) % 360) / (360 / config.numButtons))

		setAttribute(private.ringPointerElement, "rotation.z", -angle)
		setAttribute(private.ringPointerElement, "opacity", 100)
	else
		private.selectedButton = nil

		setAttribute(private.ringPointerElement, "opacity", 0)
	end
	private.previousAngle = angle
end

function updateMousePosition()
	local controllerinfo = GetControllerInfo()
	if (controllerinfo == "mouseCursor") or (controllerinfo == "mouseSteering") then
		local mousepos = C.GetCenteredMousePos()

		local diffx = mousepos.x - private.centerPos.x
		local diffy = -mousepos.y - private.centerPos.y

		if diffx * diffx + diffy * diffy >= 2500 then
			local angle = math.atan2(diffy, diffx)
			angle = (math.pi / 2 - angle) % (2 * math.pi)

			private.selectedButton = math.ceil(((math.deg(angle) + (360 / (2 * config.numButtons))) % 360) / (360 / config.numButtons))

			setAttribute(private.ringPointerElement, "rotation.z", -angle)
			setAttribute(private.ringPointerElement, "opacity", 100)
		else
			private.selectedButton = nil

			setAttribute(private.ringPointerElement, "opacity", 0)
		end
	end
end

-------------------------------------
-- Presentation specific callbacks --
-------------------------------------
function onHideCompass(_, source)
	if private.selectedButton and private.mappings[private.selectedButton] and private.mappings[private.selectedButton].active then
		C.CompassMenuButtonPressed(private.inputSource, "INPUT_COMPASSMENU_" .. private.selectedButton)
		C.CompassMenuButtonReleased(private.inputSource, "INPUT_COMPASSMENU_" .. private.selectedButton)

		private.selectedButton = nil
	end

	deactivateCompass()
	private.compassActive = false
	private.previousAngle = nil
	private.fadeInTime = nil
end

function onShowCompass(_, source)
	private.inputSource = source
	private.compassActive = true
	activateCompass()
end

function onMouseDown(i)
	if private.mappings[i] and private.mappings[i].active then
		private.pressedInput = i
		C.CompassMenuButtonPressed(private.inputSource, "INPUT_COMPASSMENU_" .. i)
	end
end

function onMouseUp(i)
	if private.mappings[i] and private.mappings[i].active and (private.pressedInput == i) then
		C.CompassMenuButtonReleased(private.inputSource, "INPUT_COMPASSMENU_" .. i)
		private.pressedInput = nil

		deactivateCompass()
		private.compassActive = false
	end
end

function onMouseOut(i)
	if private.pressedInput == i then
		C.CompassMenuButtonReleased(private.inputSource, "INPUT_COMPASSMENU_" .. i)
		private.pressedInput = nil
	end
end

-------------------------------------
-- Presentation specific functions --
-------------------------------------
function activateCompass()
	private.mappings = {}
	local buf = ffi.new("CompassMenuEntry[?]", config.numButtons)
	local n = C.GetCompassMenuMappings(buf, config.numButtons, private.inputSource)
	for i = 0, n - 1 do
		local type = ffi.string(buf[i].type)
		if type ~= "" then
			local name = ""
			if type == "action" then
				name = ffi.string(C.GetLocalizedText(config.actionTextPageID, buf[i].controlid, "action " .. buf[i].controlid))
			elseif type == "state" then
				name = ffi.string(C.GetLocalizedText(config.stateTextPageID, buf[i].controlid, "state " .. buf[i].controlid))
			end
			private.mappings[i + 1] = { type = type, control = ffi.string(buf[i].control), active = buf[i].active, name = name, shortcut = GetLocalizedKeyName(type, buf[i].controlid) }
		end
	end

	C.ForceMouseCursorVisible(true)
	showCompass()
end

function deactivateCompass()
	hideCompass()
	C.ForceMouseCursorVisible(false)
end

function showCompass()
	private.compassShown = true
	goToSlide(private.compassElement, "active")

	setAttribute(getElement("compass_text", private.compassElement), "textstring", config.core[private.inputSource].text)
	setElementTextColor(getElement("compass_text", private.compassElement), config.core[private.inputSource].pointer)
	setElementColorAlpha(getElement("compass_core.Material129", private.compassElement), config.core[private.inputSource].core)
	setElementColorAlpha(getElement("Material129", private.ringPointerElement), config.core[private.inputSource].pointer)

	private.fadeInTime = getElapsedTime() + config.fadeInDuration
	setAttribute(private.compassElement, "scale.x", 0)
	setAttribute(private.compassElement, "scale.y", 0)

	local maxY, minY = 0, 0
	local maxX, minX = 0, 0
	for i = 1, config.numButtons do
		goToSlide(private.buttonElements[i], "active")
		
		local backgroundElement = getElement("button", private.buttonElements[i])
		local textActionElement = getElement("Text_action", private.buttonElements[i])
		local textShortcutElement = getElement("Text_shortcut", private.buttonElements[i])

		local nameWidth, shortcutWidth = 0, 0
		if private.mappings[i] then
			setAttribute(textActionElement, "textstring", private.mappings[i].name)
			setElementTextColor(textActionElement, private.mappings[i].active and Color["compass_button_text_control"] or Color["compass_button_text_control_inactive"])
			setAttribute(textShortcutElement, "textstring", private.mappings[i].shortcut)

			nameWidth = math.ceil(C.GetTextWidth(private.mappings[i].name, config.font, config.fontsize * private.uiscale))
			shortcutWidth = math.ceil(C.GetTextWidth(private.mappings[i].shortcut, config.font, config.fontsize * private.uiscale))
		else
			setAttribute(textActionElement, "textstring", "")
			setAttribute(textShortcutElement, "textstring", "")
		end

		local width = math.max(config.minWidth * private.uiscale, nameWidth + shortcutWidth + config.textSpacing * private.uiscale)
		setAttribute(backgroundElement, "scale.x", width / 100)
		local height = getAttribute(backgroundElement, "scale.y") * 100

		setAttribute(textActionElement, "position.x", -width / 2 + config.textOffsetX * private.uiscale)
		setAttribute(textShortcutElement, "position.x", width / 2 - config.textOffsetX * private.uiscale)

		local x_correction = 0
		local y_correction = 0
		if i == 1 then
			y_correction = height / 2
		elseif i >= 2 and i <= 4 then
			x_correction = width / 2
		elseif i == 5 then
			y_correction = -height / 2
		elseif i >= 6 and i <= 8 then
			x_correction = -width / 2
		end

		local r = config.radius * private.uiscale
		local x = r * math.sin((i - 1) * math.rad(360 / config.numButtons)) + x_correction
		local y = r * math.cos((i - 1) * math.rad(360 / config.numButtons)) + y_correction

		setAttribute(private.buttonElements[i], "position.x", x)
		setAttribute(private.buttonElements[i], "position.y", y)

		if i == 1 then
			maxY = y + height / 2
		elseif i >= 2 and i <= 4 then
			maxX = math.max(maxX, x + width / 2)
		elseif i == 5 then
			minY = y - height / 2
		elseif i >= 6 and i <= 8 then
			minX = math.min(minX, x - width / 2)
		end
	end

	-- position
	local screenwidth, screenheight = getScreenInfo()
	local posX, posY = 0, 0
	local controllerinfo = GetControllerInfo()
	if (controllerinfo == "mouseCursor") or (controllerinfo == "mouseSteering") then
		local mousepos = C.GetCenteredMousePos()
		posX, posY = mousepos.x, -mousepos.y
		if posX ~= nil then
			posX = math.max(math.min(posX, screenwidth / 2 - maxX - config.frameBorder), -screenwidth / 2 - minX + config.frameBorder)
			posY = math.max(math.min(posY, screenheight / 2 - maxY - config.frameBorder), -screenheight / 2 - minY + config.frameBorder)

			private.centerPos = { x = posX, y = posY }
		end
	end
	if posX ~= nil then
		setAttribute(private.compassElement, "position.x", posX)
		setAttribute(private.compassElement, "position.y", posY)
	end
end

function hideCompass()
	private.compassShown = false
	goToSlide(private.compassElement, "inactive")
	HidePresentation()
	LockPresentation()
end

function initScale(anchorElement)
	local width, height = getScreenInfo()

	-- apply the overall (normalizing) scale factor - compensates for world-space positioning and presentation setup scaling factor
	-- note: We interpret the scaling factor here the way that the overall presentation setup needs to be scaled so to fit into the worldspace correctly.
	--       Hence, because of that logic/definition we also scale the z-axis.
	-- No sure about the 0.907 factor here, but it was consistently off in all resolution, uiscale and aspect ratio combinations. We have the same factor in the widgetsystem actually
	local factor = 1080 / height * 0.907
	local aspectratio = width / height
	-- If the aspect ratio goes below 4/3 the visible rendered area of the game increases and we need to compensate our world-space positioned elements accordingly
	if aspectratio < 4 / 3 then
		factor = factor * (4 / 3) / aspectratio
	end
	setAttribute(anchorElement, "scale.x", config.scalingFactor * factor)
	setAttribute(anchorElement, "scale.y", config.scalingFactor * factor)
	setAttribute(anchorElement, "scale.z", config.scalingFactor * factor)

	private.uiscale = C.GetUIScale(false)

	for _, element in ipairs(config.scaleElements) do
		local anarkelement = getElement(element, private.compassElement)
		setAttribute(anarkelement, "scale.x", getAttribute(anarkelement, "scale.x") * private.uiscale)
		setAttribute(anarkelement, "scale.y", getAttribute(anarkelement, "scale.y") * private.uiscale)
	end

	setAttribute(getElement("compass_text", private.compassElement), "size", config.coreFontSize * private.uiscale)

	for i = 1, config.numButtons do
		setAttribute(getElement("button", private.buttonElements[i]), "scale.y", config.height * private.uiscale / 100)

		local textActionElement = getElement("Text_action", private.buttonElements[i])
		local textShortcutElement = getElement("Text_shortcut", private.buttonElements[i])

		setAttribute(textActionElement, "size", config.fontsize * private.uiscale)
		setAttribute(textShortcutElement, "size", config.fontsize * private.uiscale)
	end
end

function setElementColorAlpha(anarkMaterial, color)
	SetDiffuseColor(anarkMaterial, color.r, color.g, color.b)
	setAttribute(anarkMaterial, "opacity", color.a)
	setAttribute(anarkMaterial, "glowfactor", color.glow or 0)
end

function setElementTextColor(anarkTextElement, color)
	setAttribute(anarkTextElement, "textcolor.r", color.r)
	setAttribute(anarkTextElement, "textcolor.g", color.g)
	setAttribute(anarkTextElement, "textcolor.b", color.b)
	setAttribute(anarkTextElement, "opacity", color.a)
	setAttribute(anarkTextElement, "glowfactor", color.glow or 0)
end
