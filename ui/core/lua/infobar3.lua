-- no need for special unlock-handling
-- infobar3 is kept closed until it's being used
-- handling is done via calling ShowUI("infobar3") prior to issue a "showInfoBar3"-event

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
		DebugError("Invalid parameter for ffi.string() in infobar3. Check caller!")
		DebugError(TraceBack())
		return ""
	end
end

-- text array containing localized text
local L = {
	["flightassist_alt"] = ffi.string(C.GetLocalizedText(1001, 5331, "")),
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
		[1] = { mode = "inputfeedback", external = false },
		[2] = { mode = "flightassist" },
	},
	inputFeedbackDuration = 2,
}

-- private member data
local private = {
	textElement = nil, -- Text element
	text2Element = nil, -- Text2 element
	infobar = nil,     -- infobar element
	states = {},
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
local setTextColor

---------------------------------
-- Gameface lifetime functions --
---------------------------------
function self:onInitialize()
	local scene           = getElement("Scene")
	local contract        = getElement("UIContract", scene)
	local uiAnchorElement = getElement("Layer.ui_anchor", scene)

	private.infobar     = getElement("infobar", uiAnchorElement)
	private.textElement = getElement("Text", private.infobar)
	private.infobar2     = getElement("infobar2", uiAnchorElement)
	private.text2Element = getElement("Text", private.infobar2)

	local color = getColor("text_normal")
	setTextColor(private.textElement, color)
	setTextColor(private.text2Element, color)

	initScale(uiAnchorElement)

	registerForEvent("showInfoBar3", contract, onShowInfoBar)
	registerForEvent("hideInfoBar3", contract, onHideInfoBar)
	registerForEvent("gameplanchange", contract, onGamePlanChange)

	-- infobars bar should appear "static" on screen and shouldn't be affected by the "wobbling" camera effect
	DisableCameraEffectSync()

	LockPresentation()
	private.islocked = true
end

function self:onUpdate()
	if not next(private.states) then
		if not private.islocked then
			LockPresentation()
			HidePresentation()

			private.islocked = true
		end
	end

	if private.inputFeedbackEndTime and (private.inputFeedbackEndTime < getElapsedTime()) then
		private.inputFeedbackEndTime = nil
		onHideInfoBar(nil, "inputfeedback")
	end
end

-------------------------------------
-- Presentation specific callbacks --
-------------------------------------
function onHideInfoBar(_, type)
	private.requestedTypes[type] = nil
	for i, state in pairs(private.states) do
		if state.type == type then
			if i == 1 then
				local newtype = getCurrentType(C.IsExternalViewActive())
				if newtype then
					onShowInfoBar(nil, newtype)
				else
					deactivateBar(type)
				end
			elseif i == 2 then
				deactivateBar2(type)
			end
		end
	end
end

function onGamePlanChange(_, gameplan)
	local isexternal = gameplan == "external"
	setPosition(isexternal)

	for _, entry in ipairs(config.modePriorities) do
		if entry.external ~= nil then
			for i, state in pairs(private.states) do
				if state.type == entry.mode then
					if (i == 1) and (entry.external ~= isexternal) then
						activateBar2(state)
						local newtype = getCurrentType(isexternal)
						if newtype then
							onShowInfoBar(nil, newtype)
						else
							deactivateBar(state.type)
						end
					elseif (i == 2) and (entry.external == isexternal) then
						activateBar(state)
						deactivateBar2(state.type)
					end
				end
			end
		end
	end
end

function onShowInfoBar(_, newtype, param)
	private.islocked = nil
	local isexternal = C.IsExternalViewActive()
	setPosition(isexternal)
	private.requestedTypes[newtype] = true

	if newtype == "inputfeedback" then
		private.inputFeedbackEndTime = getElapsedTime() + config.inputFeedbackDuration
		if isexternal then
			activateBar2({ type = newtype, text = param })
		else
			activateBar({ type = newtype, text = param })
		end
	else
		local haspriority = getCurrentType(isexternal) == newtype
		if haspriority then
			if newtype == "flightassist" then
				local text = ffi.string(C.GetLocalizedText(1001, 5332, L["flightassist_alt"])) -- Do not store in L to get the correct input replacements when the input changed
				activateBar({ type = newtype, text = text })
			end
		end
	end
end

-------------------------------------
-- Presentation specific functions --
-------------------------------------
function activateBar(state)
	private.states[1] = state
	setAttribute(private.textElement, "textstring", state.text)
	goToSlide(private.infobar, "active")
end

function activateBar2(state)
	private.states[2] = state
	setAttribute(private.text2Element, "textstring", state.text)
	goToSlide(private.infobar2, "active")
end

function deactivateBar(type)
	if (private.states[1].type ~= nil) and (private.states[1].type ~= type) then
		return -- currently not displaying the right type -> do not hide the note
	end

	goToSlide(private.infobar, "inactive")
	private.states[1] = nil
end

function deactivateBar2(type)
	if (private.states[2].type ~= nil) and (private.states[2].type ~= type) then
		return -- currently not displaying the right type -> do not hide the note
	end

	goToSlide(private.infobar2, "inactive")
	private.states[2] = nil
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

		setAttribute(private.textElement, "position.x", xoffset)
		setAttribute(private.textElement, "position.y", 540)
		setAttribute(private.textElement, "horzalign", 2)
	else
		setAttribute(private.textElement, "position.x", 0)
		setAttribute(private.textElement, "position.y", 0)
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

function setTextColor(textelement, color)
	setAttribute(textelement, "textcolor.r", color.r)
	setAttribute(textelement, "textcolor.g", color.g)
	setAttribute(textelement, "textcolor.b", color.b)
	setAttribute(textelement, "opacity", color.a)
	setAttribute(textelement, "glowfactor", color.glow)
end

function getCurrentType(isexternal)
	for _, entry in ipairs(config.modePriorities) do
		if (entry.external == nil) or (entry.external == isexternal) then
			if private.requestedTypes[entry.mode] then
				return entry.mode
			end
		end
	end
end
