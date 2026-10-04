-- #coreUIMed - this could be simplified by dropping handling for the external case and rather add a separate externalui-state for 1st-person view
-- which would disable the whole presentation (like it's done with the cockpit-crosshair)

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef uint64_t UniverseID;
	typedef struct {
		float angle;
		bool inside;
		bool valid;
	} ArrowDetails;
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
		uint64_t poiID;
		UniverseID componentID;
		const char* messageType;
		const char* connectionName;
		bool isAssociative;
		bool isMissionTarget;
		bool isPriorityMissionTarget;
		bool showIndicator;
		bool hasAdditionalOffset;
	} MessageDetails3;
	uint32_t GetAllColorMapEntries(ColorMapEntry* result, uint32_t resultlen);
	ArrowDetails GetCrosshairPlatformGuidanceDetails(const float radius);
	float GetHUDUIScale(const bool scalewithresolution);
	MessageDetails3 GetMessageDetails3(const uint32_t messageid);
	uint32_t GetNumAllColorMapEntries(void);
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
		DebugError("Invalid parameter for ffi.string() in firstperson crosshair. Check caller!")
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
	scalingFactor = 0.0003,            -- factor the presentation is scaled in-game (used to scale the ui_anchor value)
	missionArrowRadius       = 0.063,  -- radius of the mission arrow

	missionArrowColor = Color["crosshair_mission_arrow"],
}

-- private member data
local private = {
	crosshairElement    = nil,   -- crosshair element
	textElement         = nil,   -- text element
	softtargetElement   = nil,   -- softtarget effect element
	crosshairActive     = false, -- indicates whether the crosshair is active atm
	softtargetActive    = false, -- indicates whether the softtarget effect is active atm
	currentInteraction  = nil,   -- the current active interaction (if any)
	interactionText     = nil,   -- the currently displayed interaction text
	softtargetMessageID = nil,   -- the message ID of the current selected target (only, if it has an associated instant action)
	targetText          = "",    -- the current target text
	missionRingElement = nil,                 -- the mission ring element (aka: mission target arrow)
	missionArrowElement = nil,                -- the mission arrow element group (inside the mission ring element)
	missionArrowActive = false,               -- indicates whether the mission arrow is active
	missionArrowHidden = false,               -- indicates whether the mission arrow is hidden atm
}

-- local functions forward declarations
local onGamePlanChange
local onInteractionHidden
local onInteractionShown
local onSofttargetChanged
local onUnlock
local activateCrosshair
local deactivateCrosshair
local initScale
local setColorHelper
local setTextColor
local updateText
local activateMissionArrow
local deactivateMissionArrow
local updateMissionArrow
local updateArrowState

-- Gameface lifetime functions
function self:onInitialize()
	local scene           = getElement("Scene")
	local contract        = getElement("UIContract", scene)
	local uiAnchorElement = getElement("Layer.ui_anchor", scene)

	private.crosshairElement  = getElement("crosshair", uiAnchorElement)
	private.textElement       = getElement("Text", uiAnchorElement)
	private.softtargetElement = getElement("softtarget", uiAnchorElement)

	private.missionRingElement  = getElement("missiontarget", private.crosshairElement)
	private.missionArrowElement = getElement("Group", private.missionRingElement)

	setColorHelper(getElement("arrow sele.ui_gradient_05", private.missionArrowElement), nil, config.missionArrowColor)

	initScale(uiAnchorElement)

	-- colors
	setTextColor(private.textElement, Color["firstperson_crosshair_text"])
	setColorHelper(getElement("crosshair_03.Cylinder13.ui_gradient_05", private.crosshairElement), nil, Color["firstperson_crosshair_crosshair"])
	setColorHelper(getElement("crosshair_03_shadow.Cylinder01.ui_gradient_05", private.crosshairElement), nil, Color["firstperson_crosshair_crosshair_shadow"])
	setColorHelper(getElement("crosshair_03_ring.Cylinder15.ui_gradient_05", private.softtargetElement), nil, Color["firstperson_crosshair_softtarget_ring"])
	setColorHelper(getElement("crosshair_03_shadow.Cylinder15.ui_gradient_05", private.softtargetElement), nil, Color["firstperson_crosshair_softtarget_shadow"])

	NotifyOnConversationStarted(contract)
	NotifyOnConversationFinished(contract)
	
	registerForEvent("conversationStarted",		contract, onConversationStarted)
	registerForEvent("conversationFinished",	contract, onConversationFinished)
	registerForEvent("gameplanchange",			contract, onGamePlanChange)
	registerForEvent("interactionHidden",		contract, onInteractionHidden)
	registerForEvent("interactionShown",		contract, onInteractionShown)
	registerForEvent("softtargetChanged",		contract, onSofttargetChanged)
	registerForEvent("onUnlock",				contract, onUnlock)

	if not C.IsExternalViewActive() then
		activateCrosshair()
	else
		deactivateCrosshair()
	end

	-- initialize text
	updateText()
end

function self:onUpdate()
	-- update the interaction text, if we have a target
	if private.softtargetMessageID then
		local actionName, isPossible = GetActionInfo(private.softtargetMessageID)
		if not isPossible then
			actionName = ""
		end
		if actionName ~= private.targetText then
			private.targetText = actionName
			updateText()
		end
	end

	if private.crosshairActive then
		local platformguidancedetails = C.GetCrosshairPlatformGuidanceDetails(config.missionArrowRadius)
		if platformguidancedetails.valid then
			activateMissionArrow()
		else
			deactivateMissionArrow()
		end

		updateMissionArrow(platformguidancedetails)
	end

	if private.crosshairActivePending then
		private.crosshairActive = true
		private.crosshairActivePending = nil
	end
end

-------------------------------------
-- Presentation specific callbacks --
-------------------------------------
function onGamePlanChange(_, gameplan)
	if gameplan == "externalfirstperson" then
		deactivateCrosshair()
	else
		activateCrosshair()
	end
end

function onConversationStarted()
	if not C.IsExternalViewActive() then
		deactivateCrosshair()
	end
end

function onConversationFinished()
	if not C.IsExternalViewActive() then
		activateCrosshair()
	end
end

function onInteractionHidden(_, interactionID)
	if interactionID == private.currentInteraction then
		-- only nil the text, if we the current interaction was hidden
		-- might occur, when we retrieve successive shown/hidden interaction events
		private.interactionText    = nil
		private.currentInteraction = nil
	end

	-- update displayed text (if required)
	updateText()
end

function onInteractionShown(_, interactionID, interactionText)
	private.currentInteraction = interactionID
	private.interactionText    = interactionText

	-- update displayed text (if required)
	updateText()
end

function onSofttargetChanged(_, softtargetMessageID)
	local exists = (softtargetMessageID ~= nil)
	if exists then
		local messageDetails = C.GetMessageDetails3(softtargetMessageID)
		exists = (messageDetails.componentID ~= 0)
	end

	if exists then
		local _, _, _, instantAction = GetActionInfo(softtargetMessageID)
		if not instantAction then
			-- only display interaction texts for instant actions
			softtargetMessageID = nil
		end
		private.softtargetMessageID = softtargetMessageID
		activateSofttarget()
	else
		deactivateSofttarget()
	end
end

function onUnlock()
	-- reset crosshair state (could have changed when player entered/left stations or started a new game)

	-- deactivate the softtarget marker implicitly --- we could have missed the softtargetchanged event in the last case we showed the firstpersonUI
	-- #StefanMed - better check whether we actually have a softtarget and set the state correctly
	deactivateSofttarget()

	-- we just reset the interaction --- proper handling would not be that easy, since it requires inter-LuaState-handling (state is stored in the target monitor)
	-- #StefanMed - with the change to use target monitor interactions in the dock case now, we might actually want to higher prioritze this one
	onInteractionHidden(nil, private.currentInteraction)

	if not C.IsExternalViewActive() then
		activateCrosshair()
	else
		deactivateCrosshair()
	end
end

------------------------------------
-- Presentation specific function --
------------------------------------
function activateCrosshair()
	if private.crosshairActive then
		return -- already active, nothing to do
	end

	goToSlide(private.crosshairElement, "active")

	if private.softtargetActive then
		goToSlide(private.softtargetElement, "active")
	end

	private.crosshairActivePending = true

	-- reactivate text, if one is specified
	updateText()
end

function activateSofttarget()
	goToSlide(private.softtargetElement, "active")

	private.softtargetActive = true

	-- update the displayed text (if required)
	updateText()
end

function deactivateCrosshair()
	if not private.crosshairActive then
		return -- already inactive, nothing to do
	end

	if private.missionArrowActive and not private.missionArrowHidden then
		goToSlide(private.missionRingElement, "inactive")
		private.missionArrowActive = false
	end

	goToSlide(private.crosshairElement, "inactive")
	goToSlide(private.softtargetElement, "inactive")

	private.crosshairActive = false

	-- disable text, if one was displayed
	updateText()
end

function deactivateSofttarget()
	goToSlide(private.softtargetElement, "inactive")
	private.targetText = ""

	private.softtargetActive = false
	private.softtargetMessageID = nil

	-- update the displayed text (if required)
	updateText()
end

function initScale(anchorElement)
	-- Note: For the VR version, we explicitly do not want that a change in resolution changes the relative size of UI elements (i.e. they should not become smaller on higher resolutions) but rather leave it completely up to the user to adjust the actual UI
	--       scale via the ui scale config setting.
	local uiScale = C.GetUIScale(not C.IsVRMode())
	local presentationUIScale = C.GetHUDUIScale(not C.IsVRMode())

	-- apply the overall (normalizing) scale factor - compensates for world-space positioning and presentation setup scaling factor
	-- note: We interpret the scaling factor here the way that the overall presentation setup needs to be scaled so to fit into the worldspace correctly.
	--       Hence, because of that logic/definition we also scale the z-axis.
	setAttribute(anchorElement, "scale.x", config.scalingFactor * presentationUIScale)
	setAttribute(anchorElement, "scale.y", config.scalingFactor * presentationUIScale)
	setAttribute(anchorElement, "scale.z", config.scalingFactor * presentationUIScale)

	local textUIScale = uiScale / presentationUIScale

	local defaultFontSize = getAttribute(private.textElement, "size")
	setAttribute(private.textElement, "size", defaultFontSize * textUIScale)
end

function setColorHelper(element, parent, color)
	SetDiffuseColor(parent or element, color.r, color.g, color.b)
	setAttribute(parent or element, "opacity", color.a)
	setAttribute(element, "glowfactor", color.glow)
end

function setTextColor(textelement, color)
	setAttribute(textelement, "textcolor.r", color.r)
	setAttribute(textelement, "textcolor.g", color.g)
	setAttribute(textelement, "textcolor.b", color.b)
	setAttribute(textelement, "glowfactor", color.glow)
end

function updateText()
	local text

	-- if crosshair is inactive, then no text must be displayed
	if not private.crosshairActive then
		text = ""
	elseif private.interactionText ~= nil then
		-- interaction text always takes precedence
		text = private.interactionText
	else
		-- otherwise we show the target text
		text = private.targetText
	end

	setAttribute(private.textElement, "textstring", text)
end

function activateMissionArrow()
	if private.missionArrowActive then
		return -- nothing to do
	end

	if private.crosshairActive and not private.missionArrowHidden then
		goToSlide(private.missionRingElement, "active")
	end
	private.missionArrowActive = true
end

function deactivateMissionArrow()
	if not private.missionArrowActive then
		return -- nothing to do
	end

	if private.crosshairActive and not private.missionArrowHidden then
		goToSlide(private.missionRingElement, "inactive")
	end
	private.missionArrowActive = false
end

function updateMissionArrow(platformguidancedetails)
	if not private.missionArrowActive then
		return -- nothing to do
	end

	if platformguidancedetails.valid then
		private.previousMissiontargetAngle = platformguidancedetails.angle
		updateArrowState(private.missionRingElement, private.missionArrowHidden, platformguidancedetails.inside)
		private.missionArrowHidden = platformguidancedetails.inside
	end

	if not private.missionArrowHidden then
		setAttribute(private.missionArrowElement, "rotation.y", private.previousMissiontargetAngle / 180 * math.pi)
	end
end

function updateArrowState(arrowElement, wasHidden, isHidden)
	if isHidden and not wasHidden then
		goToSlide(arrowElement, "inactive")
	elseif not isHidden and wasHidden then
		goToSlide(arrowElement, "active")
	end
end
