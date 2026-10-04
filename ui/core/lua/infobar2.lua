-- no need for special unlock-handling
-- infobar2 is kept closed until it's being used
-- handling is done via calling ShowUI("infobar2") prior to issue a "showInfoBar2"-event

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef uint64_t UniverseID;

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
	UniverseID GetExternalViewRefObject(void);
	const char* GetLocalizedText(const uint32_t pageid, uint32_t textid, const char*const defaultvalue);
	float GetUIScale(const bool scalewithresolution);
	bool IsComponentClass(UniverseID componentid, const char* classname);
	bool IsExternalTargetMode();
	bool IsExternalViewActive();
	bool IsFloatingViewActive(void);
	bool IsVRMode();
]]

--- Wrapper ---

local origffistring = ffi.string
ffi.string = function(data) 
	if data ~= nil then
		return origffistring(data)
	else
		DebugError("Invalid parameter for ffi.string() in infobar2. Check caller!")
		DebugError(TraceBack())
		return ""
	end
end

-- text array containing localized text
local L = {
	["externalview_alt2"] = ffi.string(C.GetLocalizedText(1001, 5324, "")),
	["externaltargetview_alt2"] = ffi.string(C.GetLocalizedText(1001, 5328, "")),
	["externalstaticview_alt2"] = ffi.string(C.GetLocalizedText(1001, 5372, "")),
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
local onGamePlanChange
local activateBar
local deactivateBar
local initScale
local setPosition

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

	registerForEvent("showInfoBar2", contract, onShowInfoBar)
	registerForEvent("hideInfoBar2", contract, onHideInfoBar)
	registerForEvent("gameplanchange", contract, onGamePlanChange)

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

function onGamePlanChange(_, gameplan)
	setPosition((gameplan == "external") or (gameplan == "externalfirstperson"))
end

function onShowInfoBar(_, type)
	setPosition(C.IsExternalViewActive())

	local text = ""
	if type == "externalview" then
		local showedittext = C.IsComponentClass(C.GetExternalViewRefObject(), "ship")
		if C.IsFloatingViewActive() then
			text = ffi.string(C.GetLocalizedText(1001, 5370, "")) -- Do not store in L to get the correct input replacements when the input changed
			if text == "" then
				text = ffi.string(C.GetLocalizedText(1001, 5371, L["externalstaticview_alt2"])) -- Do not store in L to get the correct input replacements when the input changed
			end
			showedittext = false
		elseif C.IsExternalTargetMode() then
			text = ffi.string(C.GetLocalizedText(1001, 5326, "")) -- Do not store in L to get the correct input replacements when the input changed
			if text == "" then
				text = ffi.string(C.GetLocalizedText(1001, 5327, L["externaltargetview_alt2"])) -- Do not store in L to get the correct input replacements when the input changed
			end
		else
			text = ffi.string(C.GetLocalizedText(1001, 5322, "")) -- Do not store in L to get the correct input replacements when the input changed
			if text == "" then
				text = ffi.string(C.GetLocalizedText(1001, 5323, L["externalview_alt2"])) -- Do not store in L to get the correct input replacements when the input changed
			end
		end
		if showedittext then
			local edittext = ffi.string(C.GetLocalizedText(1001, 5325, ""))
			if edittext ~= "" then
				text = text .. "\n" .. edittext
			end
		end
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

function setPosition(external)
	if external then
		local width, height = getScreenInfo()
		local aspectratio = width / height
		local xoffset = 430 * aspectratio
		-- If the aspect ratio goes below 4/3 the visible rendered area of the game increases and we need to compensate our world-space positioned presentation accordingly
		if aspectratio < 4 / 3 then
			xoffset = xoffset * (4 / 3) / aspectratio
		end

		setAttribute(private.infobar, "position.x", xoffset)
		setAttribute(private.infobar, "position.y", 190)
		setAttribute(private.textElement, "horzalign", 2)
	else
		setAttribute(private.infobar, "position.x", 0)
		setAttribute(private.infobar, "position.y", 0)
		setAttribute(private.textElement, "horzalign", 1)
	end
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
