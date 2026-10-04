-- no need for special unlock-handling
-- infobar4 is kept closed until it's being used
-- handling is done via calling ShowUI("infobar3") prior to issue a "showInfoBar4"-event

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
	const char* GetLocalizedText(const uint32_t pageid, uint32_t textid, const char*const defaultvalue);
	float GetUIScale(const bool scalewithresolution);
	bool IsVRMode();
]]

--- Wrapper ---

local origffistring = ffi.string
ffi.string = function(data) 
	if data ~= nil then
		return origffistring(data)
	else
		DebugError("Invalid parameter for ffi.string() in infobar4. Check caller!")
		DebugError(TraceBack())
		return ""
	end
end

-- text array containing localized text
local L = {
	["paused"] = ffi.string(C.GetLocalizedText(1001, 410, "")),
}

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
}

-- private member data
local private = {
	textElement = nil, -- Text element
	infobar = nil      -- infobar element
}

-- local functions forward declarations
local onShowInfoBar
local onHideInfoBar
local activateBar
local deactivateBar
local initScale

---------------------------------
-- Gameface lifetime functions --
---------------------------------
function self:onInitialize()
	local scene           = getElement("Scene")
	local contract        = getElement("UIContract", scene)
	local uiAnchorElement = getElement("Layer.ui_anchor", scene)

	private.infobar     = getElement("infobar", uiAnchorElement)
	private.textElement = getElement("Text", private.infobar)

	local color = getColor("text_normal")
	setAttribute(private.textElement, "textcolor.r", color.r)
	setAttribute(private.textElement, "textcolor.g", color.g)
	setAttribute(private.textElement, "textcolor.b", color.b)
	setAttribute(private.textElement, "opacity", color.a)
	setAttribute(private.textElement, "glowfactor", color.glow)

	initScale(uiAnchorElement)

	registerForEvent("showInfoBar4", contract, onShowInfoBar)
	registerForEvent("hideInfoBar4", contract, onHideInfoBar)

	-- infobars bar should appear "static" on screen and shouldn't be affected by the "wobbling" camera effect
	DisableCameraEffectSync()

	LockPresentation()
end

-------------------------------------
-- Presentation specific callbacks --
-------------------------------------
function onHideInfoBar()
	deactivateBar()
end

function onShowInfoBar(_, type)
	local text = ""
	if type == "paused" then
		text = L["paused"]
	end

	if text ~= "" then
		activateBar(text)
	end
end

-------------------------------------
-- Presentation specific functions --
-------------------------------------
function activateBar(text)
	setAttribute(private.textElement, "textstring", text)
	goToSlide(private.infobar, "active")
end

function deactivateBar()
	LockPresentation()
	HidePresentation()
end

function initScale(anchorElement)
	-- apply the overall (normalizing) scale factor - compensates for world-space positioning and presentation setup scaling factor
	-- note: We interpret the scaling factor here the way that the overall presentation setup needs to be scaled so to fit into the worldspace correctly.
	--       Hence, because of that logic/definition we also scale the z-axis.
	setAttribute(anchorElement, "scale.x", config.scalingFactor)
	setAttribute(anchorElement, "scale.y", config.scalingFactor)
	setAttribute(anchorElement, "scale.z", config.scalingFactor)

	-- note: no visual elements beside the text element - hence we only need to scale the fontsize to apply the UI scale
	local defaultFontSize = getAttribute(private.textElement, "size")
	-- Note: For the VR version, we explicitly do not want that a change in resolution changes the relative size of UI elements (i.e. they should not become smaller on higher resolutions) but rather leave it completely up to the user to adjust the actual UI
	--       scale via the ui scale config setting.
	setAttribute(private.textElement, "size", defaultFontSize * C.GetUIScale(not C.IsVRMode()))
end
