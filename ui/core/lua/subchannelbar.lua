-- no need for special unlock-handling
-- practically there's nothing to handle here:
-- a) we are unlocking the presentation before the voiceOutput-event is being triggered (that is the only event we're interested in) (by calling ShowUI("subchannel") before the event is issued)
-- b) we do lock the presentation upon changing between UI modes, but that is only done when we do not want to display any old/pending subtitel anyway --- hence nothing to do here

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
	float GetTextWidth(const char*const text, const char*const fontname, const float fontsize);
	float GetUIScale(const bool scalewithresolution);
	bool IsNPCLineSkippable(void);
	bool IsVRMode();
]]

--- Wrapper ---

local origffistring = ffi.string
ffi.string = function(data) 
	if data ~= nil then
		return origffistring(data)
	else
		DebugError("Invalid parameter for ffi.string() in subchannelbar. Check caller!")
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
	font = "Zekton",
	minBackgroundWidth = 300,
	backgroundHeight = 30,
	backgroundWidthFactor = 1.4,
	enableSkipNote = false,
}

-- private member data
local private = {
	textElement = nil,		-- Text element
	subchannelBar = nil,	-- SubchannelBar element
	text = nil,				-- the text which is being displayed
	deactivate = false      -- indicates whether the bar should deactivate itself
}

-- local functions forward declarations
local onConversationFinished
local onVoiceOutput
local activateBar
local deactivateBar
local hideBar
local initScale
local showBar

---------------------------------
-- Gameface lifetime functions --
---------------------------------
function self:onInitialize()
	local scene           = getElement("Scene")
	local contract        = getElement("UIContract", scene)
	local uiAnchorElement = getElement("Layer.ui_anchor", scene)

	private.subchannelBar = getElement("subchannel", uiAnchorElement)
	private.textElement   = getElement("Text", private.subchannelBar)
	private.backgroundElement = getElement("Background", private.subchannelBar)
	private.skipNoteElement            = getElement("skipnote", uiAnchorElement)
	private.skipNoteTextElement        = getElement("Text", private.skipNoteElement)
	private.skipNoteBackgroundElement  = getElement("bracket", private.skipNoteElement)

	local color = getColor("text_subchannel_normal")
	setAttribute(private.textElement, "textcolor.r", color.r)
	setAttribute(private.textElement, "textcolor.g", color.g)
	setAttribute(private.textElement, "textcolor.b", color.b)
	setAttribute(private.textElement, "opacity", color.a)
	setAttribute(private.textElement, "glowfactor", color.glow)

	local backgroundMaterial = getElement("Material129", private.backgroundElement)
	local color = getColor("subchannel_background")
	SetDiffuseColor(backgroundMaterial, color.r, color.g, color.b)
	setAttribute(backgroundMaterial, "opacity", color.a)
	setAttribute(backgroundMaterial, "glowfactor", color.glow)

	local color = getColor("subchannel_skip_text")
	setAttribute(private.skipNoteTextElement, "textcolor.r", color.r)
	setAttribute(private.skipNoteTextElement, "textcolor.g", color.g)
	setAttribute(private.skipNoteTextElement, "textcolor.b", color.b)
	setAttribute(private.skipNoteTextElement, "opacity", color.a)
	setAttribute(private.skipNoteTextElement, "glowfactor", color.glow)
	local color = getColor("subchannel_skip_background")
	local material = getElement("Material1663", private.skipNoteBackgroundElement)
	SetDiffuseColor(material, color.r, color.g, color.b)
	setAttribute(material, "opacity", color.a)
	setAttribute(material, "glowfactor", color.glow)

	local color = getColor("text_subchannel_normal")
	private.iconColorText = string.format("\027#%02x%02x%02x%02x#", math.floor(color.a * 255 / 100 + 0.5), color.r, color.g, color.b)

	initScale(uiAnchorElement)

	NotifyVoiceOutput(contract)
	NotifyOnConversationFinished(contract)
	NotifyOnStartDialog(contract)
	registerForEvent("voiceOutput", contract, onVoiceOutput)
	registerForEvent("conversationFinished", contract, onConversationFinished)
	registerForEvent("startDialog", contract, onStartDialog)

	-- subchannel bar should appear "static" on screen and shouldn't be affected by the "wobbling" camera effect
	DisableCameraEffectSync()

	LockPresentation()
end

function self:onUpdate()
	-- note: we cannot directly deactivate the bar if we get an empty text or a conversation finished event
	-- doing so would cause problems, if we get the onVoiceOutput() in the same frame (with a text):
	-- fire event onVoiceOutput(_, "")
	-- fire event onVoiceOutput(_, "foo")
	--    trigger ShowUI("subchannel") -> unlocks/shows bar
	-- receive onVoiceOutput(_, "")
	--    deactivateBar() -> Lock/HideBar
	-- receive onVoiceOutput(_, "foo")
	--    setText (but do not change the state of the presentation)
	-- Bar remains locked/hidden, due to Lock/HideBar-call
	-- Note:
	-- an alternative solution would have been to add Show/Unlock-calls so we'd ensure the bar is not
	-- locked/hidden when we want to display some text
	if private.deactivate then
		hideBar()
		private.deactivate = false
	end
end

-------------------------------------
-- Presentation specific callbacks --
-------------------------------------
function onConversationFinished()
	deactivateBar()
end

function onStartDialog()
	hideSkipNote()
end

function onVoiceOutput(_, text)
	private.text = text
	if text == "" then
		deactivateBar()
	else
		activateBar()
	end
end

-------------------------------------
-- Presentation specific functions --
-------------------------------------
function activateBar()
	private.deactivate = false
	setAttribute(private.textElement, "textstring", private.text)

	local textWidth = C.GetTextWidth(private.text, config.font, private.fontSize)
	textWidth = math.max(config.minBackgroundWidth, textWidth * config.backgroundWidthFactor)
	setAttribute(private.backgroundElement, "scale.x", textWidth / 100)

	if config.enableSkipNote then
		if IsFirstPerson() and C.IsNPCLineSkippable() then
			setAttribute(private.subchannelBar, "position.y", 50)
			setAttribute(private.skipNoteElement, "position.y", 20)
		else
			setAttribute(private.subchannelBar, "position.y", 0)
			setAttribute(private.skipNoteElement, "position.y", -35)
		end
	end

	showBar()
	showSkipNote()
end

function deactivateBar()
	private.deactivate = true
	hideSkipNote()
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
	local uiscale = C.GetUIScale(not C.IsVRMode())
	private.fontSize = defaultFontSize * uiscale
	setAttribute(private.textElement, "size", private.fontSize)
	setAttribute(private.backgroundElement, "scale.y", config.backgroundHeight * uiscale / 100)

	setAttribute(private.skipNoteTextElement, "size", private.fontSize)
	setAttribute(private.skipNoteBackgroundElement, "scale.y", config.backgroundHeight * uiscale / 100)
end

function showBar()
	goToSlide(private.subchannelBar, "active")
end

function hideBar()
	HidePresentation()
	LockPresentation()
end

function showSkipNote()
	if config.enableSkipNote then
		if C.IsNPCLineSkippable() then
			local inputtext = ffi.string(C.GetLocalizedText(1001, 5380, ""))
			local text = private.iconColorText .. inputtext .. "\27X " .. ffi.string(C.GetLocalizedText(1001, 5381, ""))
			if inputtext ~= "" then
				if not private.skipNoteActive then
					private.skipNoteActive = true
					goToSlide(private.skipNoteElement, "active")
				end
				setAttribute(private.skipNoteTextElement, "textstring", text)
				local fontname = getAttribute(private.skipNoteTextElement, "font")
				local fontsize = getAttribute(private.skipNoteTextElement, "size")
				local textwidth = math.ceil(C.GetTextWidth(text, fontname, fontsize))
				setAttribute(private.skipNoteBackgroundElement, "scale.x", textwidth / 100)
			end
		end
	end
end

function hideSkipNote()
	if config.enableSkipNote then
		if private.skipNoteActive then
			goToSlide(private.skipNoteElement, "inactive")
			private.skipNoteActive = false
		end
	end
end
