-- no need for special unlock-handling
-- infobar is kept closed until it's being used
-- handling is done via calling ShowUI("infobar") prior to issue a "showInfoBar"-event

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
	bool IsExternalViewActive();
	bool IsVRMode();
]]

--- Wrapper ---

local origffistring = ffi.string
ffi.string = function(data) 
	if data ~= nil then
		return origffistring(data)
	else
		DebugError("Invalid parameter for ffi.string() in infobar. Check caller!")
		DebugError(TraceBack())
		return ""
	end
end

-- text array containing localized text
local L = {
	["autopilot_alt"] = ffi.string(C.GetLocalizedText(1001, 5311, "")),
	["directsteering_alt"] = ffi.string(C.GetLocalizedText(1001, 5352, "")),
	["mousesteering_alt"] = ffi.string(C.GetLocalizedText(1001, 5302, "")),
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
	modePriorities = {
		[1] = "autopilot",
		[2] = "directsteering",
		[3] = "mousesteering",
	},
}

-- private member data
local private = {
	textElement = nil, -- Text element
	infobar = nil,     -- infobar element
	type = nil,         -- the current type which is being displayed
	islocked = nil,
	requestedTypes = {},
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

	registerForEvent("showInfoBar", contract, onShowInfoBar)
	registerForEvent("hideInfoBar", contract, onHideInfoBar)
	registerForEvent("gameplanchange", contract, onGamePlanChange)

	-- infobars bar should appear "static" on screen and shouldn't be affected by the "wobbling" camera effect
	DisableCameraEffectSync()

	LockPresentation()
	private.islocked = true
end

function self:onUpdate()
	if private.type == nil then
		if not private.islocked then
			LockPresentation()
			HidePresentation()

			private.islocked = true
		end
	end
end

-------------------------------------
-- Presentation specific callbacks --
-------------------------------------
function onHideInfoBar(_, type)
	private.requestedTypes[type] = nil
	if next(private.requestedTypes) then
		for _, mode in ipairs(config.modePriorities) do
			if private.requestedTypes[mode] then
				onShowInfoBar(nil, mode)
				break
			end
		end
	else
		deactivateBar(type)
	end
end

function onGamePlanChange(_, gameplan)
	setPosition(gameplan == "external")
end

function onShowInfoBar(_, type)
	private.islocked = nil
	setPosition(C.IsExternalViewActive())
	private.requestedTypes[type] = true

	local haspriority = false
	for _, mode in ipairs(config.modePriorities) do
		if private.requestedTypes[mode] then
			if mode == type then
				haspriority = true
			end
			break
		end
	end

	if haspriority then
		local text = ""
		if type == "autopilot" then
			text = ffi.string(C.GetLocalizedText(1001, 5312, L["autopilot_alt"])) -- Do not store in L to get the correct input replacements when the input changed
		elseif type == "directsteering" then
			text = ffi.string(C.GetLocalizedText(1001, 5351, L["directsteering_alt"])) -- Do not store in L to get the correct input replacements when the input changed
		elseif type == "mousesteering" then
			text = ffi.string(C.GetLocalizedText(1001, 5301, L["mousesteering_alt"])) -- Do not store in L to get the correct input replacements when the input changed
		end

		if text ~= "" then
			activateBar(type, text)
		end
	end
end

-------------------------------------
-- Presentation specific functions --
-------------------------------------
function activateBar(type, text)
	private.type = type
	setAttribute(private.textElement, "textstring", text)
	goToSlide(private.infobar, "active")
end

function deactivateBar(type)
	if private.type ~= nil and private.type ~= type then
		return -- currently not displaying the right type -> do not hide the note
	end

	private.type = nil
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
		setAttribute(private.infobar, "position.y", 540)
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
