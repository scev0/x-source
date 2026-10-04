-- no need for special unlock-handling
-- debug line is kept closed until it's being used --- it closes automatically upon UI mode changes
-- handling is done via calling ShowUI("debugline") prior to issue "showDebugLine"-event

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

	bool GetColorMapEntry(const char* id, ColorMapEntry* result);
	float GetUIScale(const bool scalewithresolution);
	bool IsVRMode();
]]

--- Wrapper ---

local origffistring = ffi.string
ffi.string = function(data) 
	if data ~= nil then
		return origffistring(data)
	else
		DebugError("Invalid parameter for ffi.string() in debugline. Check caller!")
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
	scalingFactor = 0.0004, -- factor the presentation is scaled in-game (used to scale the ui_anchor value)
	textures = {
		"ui\\core\\presentations\\debugline\\debugline_recovered\\gradient_02_diff",
		"ui\\core\\presentations\\debugline\\debugline_recovered\\gradient_alpha_02_diffhq",
		"ui\\core\\presentations\\debugline\\debugline_recovered\\gradient_alpha_02_diffhq-small",
	},
	meshes = {
		"ui\\core\\presentations\\debugline\\debugline#ak10-lod0",
	},
	scaleElements = {
		"white outline",
		"black bar",
		"transparent background",
	},
	extraScalingFactor = 1.1,	-- extra factor to scale the background elements beyond the screen
}

-- private member data
local private = {
	textElement = nil,       -- Text element
	debugLine = nil,         -- DebugLine element
	text = nil,              -- displayed text
	debugLineActive = false, -- indicates whether the debug line is displayed
	lastDisplayTime = 0,     -- time, when the info bar switched the display type (hidden/shown)
	timeout = 0,             -- the timeout, after which the debugline will be hidden (in seconds - 0 = no timeout)
	debugLineShown = false   -- indicates whether the debug line is shown (or hidden)
}

-- local functions forward declarations
local onHideDebugLine
local onShowDebugLine
local activateDebugLine
local deactivateDebugLine
local hideDebugLine
local initScale
local showDebugLine
local setColorHelper

---------------------------------
-- Gameface lifetime functions --
---------------------------------
function self:onInitialize()
	local scene           = getElement("Scene")
	local contract        = getElement("UIContract", scene)
	local uiAnchorElement = getElement("Layer.ui_anchor", scene)

	private.debugLine   = getElement("InfoBar", uiAnchorElement)
	private.textElement = getElement("Text", private.debugLine)

	local color = getColor("text_normal")
	setAttribute(private.textElement, "textcolor.r", color.r)
	setAttribute(private.textElement, "textcolor.g", color.g)
	setAttribute(private.textElement, "textcolor.b", color.b)
	setAttribute(private.textElement, "opacity", color.a)
	setAttribute(private.textElement, "glowfactor", color.glow)
	
	setColorHelper(getElement("white outline.Material129", private.debugLine), nil, getColor("icon_normal"))
	setColorHelper(getElement("black bar.Material129", private.debugLine), nil, getColor("debugline_black_bar"))

	initScale(uiAnchorElement)
	-- we need to preload these things, as saving prevents them from popping in a frame later
	for _, mesh in ipairs(config.meshes) do
		PrepareMesh(mesh)
	end
	for _, texture in ipairs(config.textures) do
		PrepareTexture(texture)
	end

	-- reset mission text
	setAttribute(private.textElement, "textstring", "")

	registerForEvent("showDebugLine", contract, onShowDebugLine)
	registerForEvent("hideDebugLine", contract, onHideDebugLine)

	-- subchannel bar should appear "static" on screen and shouldn't be affected by the "wobbling" camera effect
	DisableCameraEffectSync()

	LockPresentation()
end

function self:onUpdate()
	if not private.debugLineActive then
		return	-- return, if inactive
	end
	
	if private.timeout == 0 then
		return -- no auto hide, nothing to do
	end

	if private.debugLineShown then
		if private.lastDisplayTime + private.timeout < getElapsedTime() then
			hideDebugLine()
		end
	end
end

-------------------------------------
-- Presentation specific callbacks --
-------------------------------------
function onHideDebugLine()
	deactivateDebugLine()
end

function onShowDebugLine(_, text, timeout)
	private.text = text
	private.timeout = timeout
	activateDebugLine()
end

-------------------------------------
-- Presentation specific functions --
-------------------------------------
function activateDebugLine()
	private.debugLineActive = true
	if private.text then
		setAttribute(private.textElement, "textstring", private.text)
	end
	showDebugLine()
end

function deactivateDebugLine()
	hideDebugLine()
	private.debugLineActive = false
end

function showDebugLine()
	private.lastDisplayTime = getElapsedTime()
	private.debugLineShown = true
	goToSlide(private.debugLine, "active")
end

function hideDebugLine()
	private.lastDisplayTime = getElapsedTime()
	private.debugLineShown = false
	goToSlide(private.debugLine, "inactive")
	HidePresentation()
	LockPresentation()
end

function initScale(anchorElement)
	-- apply the overall (normalizing) scale factor - compensates for world-space positioning and presentation setup scaling factor
	-- note: We interpret the scaling factor here the way that the overall presentation setup needs to be scaled so to fit into the worldspace correctly.
	--       Hence, because of that logic/definition we also scale the z-axis.
	setAttribute(anchorElement, "scale.x", config.scalingFactor)
	setAttribute(anchorElement, "scale.y", config.scalingFactor)
	setAttribute(anchorElement, "scale.z", config.scalingFactor)

	-- texture scaling
	local width, height = getScreenInfo()
	local aspectratio = width / height
	local scalingFactor = 0.0125 * 720 / height * config.extraScalingFactor
	-- If the aspect ratio goes below 4/3 the visible rendered area of the game increases and we need to compensate our world-space positioned elements accordingly
	if aspectratio < 4 / 3 then
		scalingFactor = scalingFactor * (4 / 3) / aspectratio
	end

	for _, element in ipairs(config.scaleElements) do
		setAttribute(getElement(element, private.debugLine), "scale.x", scalingFactor * width)
	end

	-- note: no visual elements beside the text element - hence we only need to scale the fontsize to apply the UI scale
	local defaultFontSize = getAttribute(private.textElement, "size")
	-- Note: For the VR version, we explicitly do not want that a change in resolution changes the relative size of UI elements (i.e. they should not become smaller on higher resolutions) but rather leave it completely up to the user to adjust the actual UI
	--       scale via the ui scale config setting.
	setAttribute(private.textElement, "size", defaultFontSize * C.GetUIScale(not C.IsVRMode()))
end

function setColorHelper(element, parent, color)
	SetDiffuseColor(parent or element, color.r, color.g, color.b)
	setAttribute(parent or element, "opacity", color.a)
	setAttribute(element, "glowfactor", color.glow)
end
