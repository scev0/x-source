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
	typedef struct {
		const char* factionID;
		const char* factionName;
		const char* factionIcon;
	} FactionDetails;
	typedef struct {
		size_t numImportantMails;
		size_t numNormalMails;
	} MailCount;
	typedef struct {
		uint64_t poiID;
		UniverseID componentID;
		const char* messageType;
		const char* connectionName;
		bool isAssociative;
		bool isMissionObjective;
		bool showIndicator;
	} MessageDetails;
	typedef struct {
		bool active;
		bool callbackMode;
		uint32_t barLine;
		float barPercent;
		const char* line1Left;
		const char* line1Right;
		const char* line2Left;
		const char* line2Right;
		const char* line3Left;
		const char* line3Right;
		const char* line4Left;
		const char* line4Right;
		const char* line5Left;
		const char* line5Right;
		const char* missionBarText;
	} MissionInfo3;
	typedef struct {
		int relationStatus;
		int relationValue;
		int relationLEDValue;
		bool isBoostedValue;
	} RelationDetails;
	typedef struct {
		UniverseID softtargetID;
		const char* softtargetConnectionName;
		uint32_t messageID;
	} SofttargetDetails2;
	void AbortCurrentNotification();
	uint32_t GetAllColorMapEntries(ColorMapEntry* result, uint32_t resultlen);
	int GetConfigSetting(const char*const setting);
	const char* GetCurrentTargetMouseButtonMapping(int32_t mousebuttonid, const char* modifiers, bool onclick);
	UniverseID GetEnvironmentObject();
	UniverseID GetExternalTargetViewComponent();
	FactionDetails GetFactionDetails(const char* factionid);
	const char* GetFactionNameForTargetMonitorHack(UniverseID componentid);
	RelationDetails GetFactionRelationStatus2(const char* factionid);
	const char* GetHUDScaleOption(void);
	float GetHUDUIScale(const bool scalewithresolution);
	const char* GetLocalizedInteractiveNotificationKey();
	const char* GetLocalizedText(const uint32_t pageid, uint32_t textid, const char*const defaultvalue);
	MissionInfo3 GetMissionInfo3();
	float GetModeLightIntensity(void);
	int GetNotificationID(const size_t num);
	size_t GetNumAcceptedMissions();
	uint32_t GetNumAllColorMapEntries(void);
	size_t GetNumNotifications();
	uint32_t GetNumRadarModes();
	MailCount GetNumUnreadMails();
	FactionDetails GetOwnerDetails(UniverseID componentid);
	const char* GetPlayerCoverFaction(void);
	size_t GetRadarModeOption(void);
	RelationDetails GetRelationStatus3(const UniverseID componentid, const char*const connectionname);
	SofttargetDetails2 GetSofttarget2();
	float GetTextWidth(const char*const text, const char*const fontname, const float fontsize);
	float GetUIScale(const bool scalewithresolution);
	bool HandleTargetMouseClickOnRadar(bool instantinteract, bool interactwithselectedtarget);
	void HandleTargetMouseDownOnRadar();
	void InvalidateRadarCursorPosition();
	bool IsExternalTargetMode();
	bool IsExternalViewActive();
	bool IsGamePaused(void);
	bool IsObjectKnown(const UniverseID componentid);
	bool IsTargetMonitorNotification(const int notificationid);
	bool IsValidComponent(const UniverseID componentid);
	bool IsVRMode();
	void NotifyDisplayNotification(const int notificationid);
	bool QuickMenuAccess(const char* menu);
	void ReleaseInteractionDescriptor(int32_t id);
	void SetConfigSetting(const char*const setting, const bool value);
	void SetMonitorExtents(const char* monitorid, float x, float y, float width, float height);
	void SetMonitorRenderState(bool state);
	void SetMouseInputBlockedByAnarkElement(int32_t mousebuttonid, const char* modifiers, bool blocked);
	void SetRadarMousePosition(float x, float y);
	bool SetRadarRenderTarget2(const char*const rendertargettexture, const UniverseID referencecomponent, const size_t mapmode);
	bool SetRadarRenderTargetOnTarget2(const char*const rendertargettexture, const UniverseID focuscomponentid, const UniverseID referencecomponent, const size_t mapmode);
	void UnsetRadarRenderTarget();
]]

local utf8 = require("utf8")

--- Wrapper ---
local origffistring = ffi.string
ffi.string = function(data)
	if data ~= nil then
		return origffistring(data)
	else
		DebugError("Invalid parameter for ffi.string() in monitors. Check caller!")
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
	targetMonitorScaleFactor = 0.0002, -- factor the target monitor is scaled in-game (worldspace mode)
	-- note that "-rendertarget" is a requirement from the GFX-system --- if not named like that, it would not be rendered at all
	largeRenderTarget        = "ui\\core\\presentations\\monitors\\monitors_recovered\\targetmonitor-rendertarget",
	smallRenderTarget        = "ui\\core\\presentations\\monitors\\monitors_recovered\\targetmonitor2-rendertarget",
	displayPressHint         = true,  -- indicates whether we display the "Press A" text, when an interactive notification is displayed
	notificationDelay        = 5,     -- time (in s) a notification is being displayed - X3TC values: 100ms per character, min 4s, max 10s
	priorization = {                  -- priorization order (in cases of multiple requests from different systems, the one with the highest priority gets precedence)
		"notification",
		"softtarget",
		"externalTarget",
		"environmentinfo"
	},

	-- notoriety bar settings
	notorietyIconSize = 30, -- size (in px) of icons in table rows

	-- relation text color
	relationColor = {
		[0] = Color["targetmonitor_notoriety_hostile_5"],	-- hostile
		[1] = Color["targetmonitor_notoriety_hostile_4"],	-- enemy
		[2] = Color["targetmonitor_notoriety_neutral_2"],	-- neutral
		[3] = Color["targetmonitor_notoriety_friendly_4"],	-- friendly
		[4] = Color["targetmonitor_notoriety_friendly_4"],	-- member
		[5] = Color["targetmonitor_notoriety_player_1"],	-- own property
		[6] = Color["targetmonitor_notoriety_unknown_1"],	-- unknown
	},

	-- pointer related
	interactPointerID = "target", -- pointerID used when hovering the pointer over the target monitor while in interactive notification is displayed

	-- notoriety bar color settings
	notorietyLEDColor = {
		[4] = Color["targetmonitor_notoriety_friendly_4"], -- first lit (friendly) LED - aka: brightest one - also used as value-text-color
		[3] = Color["targetmonitor_notoriety_friendly_3"], -- second lit (friendly) LED
		[2] = Color["targetmonitor_notoriety_friendly_2"], -- third lit (friendly) LED
		[1] = Color["targetmonitor_notoriety_friendly_1"], -- fourth lit (friendly) LED - aka: darkest one
		[0] = Color["targetmonitor_notoriety_neutral_1"], -- inactive color value
		[-1] = Color["targetmonitor_notoriety_hostile_1"], -- first lit (hostile) LED - aka: darkest one
		[-2] = Color["targetmonitor_notoriety_hostile_2"], -- second lit (hostile) LED
		[-3] = Color["targetmonitor_notoriety_hostile_3"], -- third lit (hostile) LED
		[-4] = Color["targetmonitor_notoriety_hostile_5"], -- fourth lit (hostile) LED - aka: brightest one - also used as value-text-color
		[-5] = Color["targetmonitor_notoriety_hostile_4"], -- special case for enemy color (a bit hacky, but easiest way to get in for now)
	},

	-- matrix specifying the color index in notorietyColor for each relationValue - LEDElement pair - LEDs are specificed from element 1..8 (aka: light colors from right to left)
	notorietyColorMatrix = {
		[-4] = { 0, 0, 0, 0, -1, -2, -3, -4 },
		[-3] = { 0, 0, 0, 0, -2, -3, -4,  0 },
		[-2] = { 0, 0, 0, 0, -5, -5,  0,  0 },
		[-1] = { 0, 0, 0, 0, -5,  0,  0,  0 },
		[0]  = { 0, 0, 0, 0, 0, 0, 0, 0 },
		[1]  = { 0, 0, 0, 4, 0, 0, 0, 0 },
		[2]  = { 0, 0, 4, 3, 0, 0, 0, 0 },
		[3]  = { 0, 4, 3, 2, 0, 0, 0, 0 },
		[4]  = { 4, 3, 2, 1, 0, 0, 0, 0 }
	},

	-- target monitor settings
	maxTargetMonitorTextRows = 8, -- the maximum number of text rows supported in the target monitor
	targetMonitorPresentationWidth = 700,
	targetTickerTextOffsetX = 0,
	targetTickerOverlayTextOffsetX = 5,

	-- radar specific settings
	radarScaleFactor = 0.0002, -- factor the radar is scaled in-game (worldspace mode)
	-- note that "-rendertarget" is a requirement from the GFX-system --- if not named like that, it would not be rendered at all
	radarRenderTarget = "ui\\core\\presentations\\monitors\\monitors_recovered\\radar-rendertarget",
	radarMonitorPresentationHeight = 511,

	-- message ticker settings
	messageTickerScaleFactor = 0.0002, -- factor the message ticker is scaled in-game (worldspace mode)
	messageTickerPresentationWidth = 700,
	messageTickerTextOffsetX = 0,
	messageTickerInvertedTextOffsetX = 5,
	messageTickerBackgroundOffset = -33,
	messageTickerBaseHeight = 62,
	messageTickerMissionColor = Color["messageticker_mission"],
	messageTickerMissionBlinkColor = Color["messageticker_mission_highlight"],
	messageTickerInactiveMissionTextColor = Color["text_notification_text"],
	messageTickeCoverTextColor = Color["messageticker_cover_text"],
	messageTickerMultiLine = {
		maxLines = 3,
		elementOffsetY = -112,
		lineHeight = 34,
		backgroundOffsetY = -4,
		backgroundScale = 0.35,
		backgroundScaleOffset = 0.01,
		mousepickOffsetY = -3,
		mousepickScale = 0.35,
		mousepickScaleOffset = -0.05,
	},
	missionDataFont               = "Zekton", -- font used for the mission data row in the message ticker
	missionDataFontBold           = "Zekton bold", -- font used for the mission story data row in the message ticker
	missionDataFontSize           = 18,       -- fontsize used for the mission data row in the message ticker
	fadeOutDelay                  =  5,       -- time (in s) the message is displayed before the fadeout effect starts
	fadeOutTime                   =  2,       -- time (in s) for the fadeout effect in the message ticker
	blinkAnimTimeOffset           =  3,       -- time offset (in s) the blink animation starts
	-- implementation constrain: blinkAnimTime must be <= fadeOutDelay (or else the fadeOutDelay would start later appruptly somehwere in the middle of the fadeout animation)
	--                           also the animtime for the "blinking" slide of the bar element must match with this value here (#coreUIMed - add sanity check)
	blinkAnimTime                 =  1.4,     -- length (in s) of the blink animation
	numMessageTickerLines         = 13,       -- number of text lines in the message ticker
	-- #coreUILow - read this value from corresponding XAnark config value
	numMissionDetailLines         =  5,       -- number of text lines which can be used to display mission details instead
	messageTickerActive           = false,    -- indicates whether the message ticker is active atm
	mailNotificationElementActive = false,    -- indicates whehter the message ticker's mail notification element is active atm
	needMailNotificationUpdate    = true,     -- indicates whether the mail notification element needs to be updated this cycle
	chatNotificationElementActive = false,    -- indicates whehter the message ticker's chat notification element is active atm
	needChatNotificationUpdate    = true,     -- indicates whether the chat notification element needs to be updated this cycle

	-- messsage bar settings
	missionBarScaleFactor = 0.0002,
	missionBarColor   = Color["messageticker_mission"],
	missionBarBlinkingColor = Color["messageticker_mission_highlight"],

	showRadarInTickerinExternalView = true,
	tickerRenderTarget        = "ui\\core\\presentations\\monitors\\monitors_recovered\\ticker-rendertarget",

	glowfactors = {
		text = 0.5,
	},

	lowAspectRatioCorrection = 112.5,

	showMessagesInTickerOnlyMode = false,

	footerFontSize = 18,
	factionFontSize = 20,
}

-- text array containing localized text
local L = {
	["%u inactive mission(s)"] = ffi.string(C.GetLocalizedText( 1001, 7602, "%u inactive mission(s)")),
	["Allied"]                 = ffi.string(C.GetLocalizedText( 1001, 5203, "Allied")),
	["Enemy"]                  = ffi.string(C.GetLocalizedText( 1001, 5201, "Enemy")),
	["Friendly"]               = ffi.string(C.GetLocalizedText( 1001, 5215, "Friendly")),
	["Hostile"]                = ffi.string(C.GetLocalizedText( 1001, 5212, "Hostile")),
	["INFORMATION"]            = ffi.string(C.GetLocalizedText( 1001, 5209, "INFORMATION")),
	["MESSAGES"]               = ffi.string(C.GetLocalizedText( 1001, 7601, "MESSAGES")),
	["Neutral"]                = ffi.string(C.GetLocalizedText( 1001, 5202, "Neutral")),
	["No mission data"]        = ffi.string(C.GetLocalizedText( 1001, 7603, "No mission data")),
	["Press %s"]               = ffi.string(C.GetLocalizedText( 1001, 5211, "Press %s")),
	["Owned"]                  = ffi.string(C.GetLocalizedText( 1001, 5200, "Owned")),
	["Unknown Faction"]        = ffi.string(C.GetLocalizedText(20212,  301, "Unknown Faction")),
	["Cover active as:"]       = ffi.string(C.GetLocalizedText( 1001, 5216, "Cover active as")) .. ffi.string(C.GetLocalizedText(1001, 120, ":")),
}

-- private member data
local private = {
	anarkElements = { -- table of all Anark elements
		targetMonitor = { -- table of all target monitor related elements
			textOverlay = {        -- target monitor text overlay Anark elements
				mainElement = nil, -- the text overlay main element
				row = {            -- the different text elements for each row
					-- [x] = {     -- the row (1..config.maxTargetMonitorTextRows)
						-- ["left"]  = nil, -- the row's left text element
						-- ["right"] = nil  -- the row's right text element
					-- }
				}
			},
			factionLadder = { -- array of Anark elements for the faction ladder
				--[x]              = nil,   -- faction ladder LED component (1..8)
				mainElement        = nil,   -- the faction ladder main element
				iconMaterial       = nil,   -- faction icon material element
				iconTexture        = nil,   -- faction icon texture element
				valueText          = nil,   -- faction ladder value text element
				relationText       = nil,   -- faction ladder relation text element
				factionText        = nil    -- faction ladder faction text element
			},
			footer                 = nil,   -- the footer (overlay) element
			header                 = nil,   -- the header (overlay) element
			headerText             = nil,   -- the header text (overlay) element
			notorietyBar           = nil,   -- the notoriety bar element
			notorietyBlinking      = nil,   -- blinking notoriety element
			rendertargetElement    = nil,   -- rendertarget element
			largeRendertargetFrame = nil,   -- (large) rendertarget model element
			interactElement        = nil,   -- the element for the interactive target monitor notification effect
			interactiveText        = nil    -- the "press A" text element
		},
		messageTicker = { -- table of Anark elements for the message ticker
			mainElement         = nil, -- the message ticker root element
			notificationElement = nil, -- the mail notification element
			chatNotificationElement = nil, -- the chat notification element
			rendertargetElement = nil, -- rendertarget element
			rendertarget        = nil, -- rendertarget
			row1Element         = nil  -- Anark element for first message ticker row
		},
		missionBar = {
			mainElement  = nil, -- the Anark main mission bar element
			textElement1 = nil, -- the Anark text element (1st element for blink effect) in the mission bar
			textElement2 = nil  -- the Anark text element (2nd element for blink effect) in the mission bar
		},
		radar = { -- table of Anark elements for the separate radar
			mainElement = nil, -- the Anark radar root element
			radarFrame  = nil  -- the Anark radar frame element (i.e. where the holomap is rendered on)
		},
	},
	-- #coreUIMed - review the need for notificationsActive
	notificationsActive              = false, -- indicates whether the notification is active
	targetMonitorNotifications = { -- target monitor notifications sorted by priority
		-- [priority] = { -- FIFO list for player notification IDs
			-- [x] = notificationID
		-- }
	},
	curDescription                   = nil,   -- nil|array struct as retrieved by GetTargetMonitorDetailsBridge() or GetNotificationDetails()
											  -- #coreUIMed - add full array documentation
	softtargetUpdate                 = nil,   -- requested softtarget
	softtargetID                     = 0,     -- softtarget id (if any softtarget is active)
	softtargetTemplateConnectionName = nil,   -- softtarget template connection name (if a softtarget is active and it has a template connection specified)
	stateRequests = { -- list of active/inactive monitor states
		-- [priorityIndex] = true | false
	},
	currentState                    = nil,   -- the name of the current state
	environmentTargetID             = 0,     -- the id of the environment object target (0 if none is set)
	notorietyLadderFactionDetails   = nil,   -- data of the faction associated with the notoriety ladder (nil => inactive notoriety ladder, or component used if specified)
	-- {
		-- [factionID]   = factionID -- the faction id
		-- [factionName] = string    -- the faction name
		-- [factionIcon] = string    -- the faction icon
	-- }
	notorietyLadderComponentDetails = nil,   -- data of the component associated with the notoriety ladder (nil => inactive notoriety ladder, or faction used if specified - takes precedence over notorietyLadderFactionDetails)
	-- {
		-- [component]        = componentID | nil -- nil, if the component is no longer valid
		-- [factionName]      = string -- the component's owning faction name
		-- [relationDetails]  = {
			-- [relationStatus]   = number -- the relation status of the component (0 = hostile, 1 = enemy, 2 = neutral, 3 = friend, 4 = player property, 5 = unknown)
			-- [relationValue]    = number -- the relation value of the component
			-- [relationLEDValue] = number -- the relation LED value of the component
			-- [isBoostedValue]   = boolean -- indicates whether the current relation is boosted (true) or permanent (false)
		-- }
	-- }
	previousRelationDetails         = nil,   -- the relationDetails used in the previous frame (same table structure as notorietyLadderComponentDetails.relationDetails)
	autoClose                       = nil,   -- time at which the current active state closes
	currentNotificationID           = nil,   -- the current notificationID (if any), nil otherwise
	factionLadderActive             = false, -- indicates whether the faction ladder is active
	monitorActive                   = false, -- indicates whether the monitor is active
	environmentObjectSupport        = true,  -- indicates whether the target monitor support for environment object handling is enabled
	hudMonitor                      = false, -- indicates whether we are running the hud target monitor
	externalTargetMode              = false, -- indicates whether we are currently in external target mode
	overlayActive                   = false, -- indicates whether the overlay elements (i.e. header, footer, and text overlay) are active
	notorietyBarActive              = false, -- indicates whether the notoriety bar is active atm
	targetMonitorStateLiveUpdateData = nil,  -- live update value for ongoing component/connection state validation
		-- {
			-- ["referenceComponent"]      = componentID | nil -- the component for which targetmonitorstate is to be queried
			-- ["referenceConnectionName"] = connection name   -- the template connection name for which targetmonitorstate is to be queried
			-- ["expectedTargetMonitorState"] = targetmonitorstate value that we expect to receive from GetLiveData() - if this state changes, enforce refresh
		-- }
	liveUpdateValues                = {      -- liveUpdateValues which are currently displayed (nil, if no values are displayed atm)
		-- [x] = {
			-- ["element"] -- anark text element, retrieving the constructed text
			-- ["referenceComponent"]      = componentID | nil -- the component for which placeholders are to be queried
			-- ["referenceConnectionName"] = connection name   -- the template connection name for which placeholders are to be queried
			-- ["chunks"] = {
				-- [x] = {
					-- ["isPlaceholder"] = true|false -- indicates whether the entry is a placeholder (true) or plain text (false)
					-- ["text"] = text|placeholder -- the text to be displayed or placeholder
				-- }
			-- }
		-- }
	},
	textUIScale                     = 1.0,

	-- radar specific variables
	targetMonitorRadarActive = false, -- indicates whether the target monitor radar is active atm
	separateRadarActive      = false, -- indicates whether the separate radar is active atm
	radarActive              = false, -- indicates whether the (i.e. any) radar is active atm
	radarEnabled             = false, -- indicates whether the game setting is set to have the radar displayed
	radarMapMode             = 0,     -- indicates which mode the radar is in (0: combat radar, 1: same but zoomed in, 2: minimap mode following player, 3: minimap mode showing full sector)
	allowRadar               = true,  -- if set to true, we can display the radar
	enableSeparateRadar      = true,  -- indicates whether the separate radar element is active
	radarRenderTarget        = nil,   -- the radar render target to be used to display the radar
	radarFocusComponent      = 0,     -- the component which the radar should be focused on (0, if focused on current player controlled)
	pointerOverRadar         = false, -- indicates whether the pointer is over the radar element atm
	radarPickFrame           = nil,   -- the Anark radar element used for pointer picking
	radarPickingEnabled      = false, -- indicates whether radar pointer picking is active atm

	-- message ticker specific variables
	inactiveMissionLineActive     = false, -- indicates whether we are displaying the inactive mission line atm
	numMissionDetailLines         = 0,     -- number of currently displayed lines for mission details (or for the "x inactive mission(s)" text)
	curNumMessageLines            = 0,     -- the number of currently displayed ticker *text* lines (ticker lines can have multiple text lines)
	numCurrentMails               = 0,     -- the number of currently displayed unread mails (0..100 - any number >100 is capped at 100)
	numCurrentChats               = -1,    -- the number of currently displayed unread chats (0..100 - any number >100 is capped at 100)
	hasImportantMails             = false, -- inidcates whether we have unread important mails atm (only valid, if numCurrentMails >0)
	messageTickerInitialized      = false, -- indicates whether the message ticker was already initialized
	needMissionDetailsUpdate      = true,  -- indicates whether we need to update the mission details
	needMissionObjectiveBarUpdate = false, -- indicates whether we need to update the mission bar
	missionDetailsCallbackMode    = false, -- indicates whether we are running in callback mode for mission details (i.e. have to re-query the mission details every frame)
	messageTickerNotifications    = {      -- message ticker notifications sorted by priority
		-- [priority] = { -- FIFO list for player notification IDs
			-- [x] = notificationID
		-- }
	},
	messageTickerMessages         = {      -- the currently displayed messages on the message ticker
		-- [x] = {                      -- line number of the message [1, config.numMessageTickerLines]
			-- ["startTime"] = nil|time (in s)  -- time when the message is displayed (nil indicates not initialzed yet)
			-- ["left"|"right"] = {
				-- ["text"]       = string      -- the text
				-- ["font"]       = string      -- the font
				-- ["fontsize"]   = integer     -- the fontsize
				-- ["blinkColor"] = {           -- the text blinking color
					-- ["r"] = integer          -- red text blinking color value
					-- ["g"] = integer          -- green text blinking color value
					-- ["b"] = integer          -- blue text blinking color value
				-- }
				-- ["color"]      = {           -- the text color
					-- ["r"] = integer          -- red text color value
					-- ["g"] = integer          -- green text color value
					-- ["b"] = integer          -- blue text color value
				-- }
			-- }
			-- ["barValue"]         = float|nil -- the value to be displayed as a bar in the line (nil indicates line is not used as a bar)
			-- ["blinking"]         = boolean   -- indicates whether the message is blinking
			-- ["permanent"]        = boolean   -- indicates whether the message is displayed permanently (i.e. no fade out)
			-- ["firstMessageLine"] = boolean   -- indicates whether this message represents the first line (of a potential multi line message)
		-- }
	},
	messageLines = {    -- array for the message lines in the message ticker
			-- [x] = {  -- line number of the message [1, config.numMessageTickerLines]
				-- ["mode"]                   = "text"|"bar"|"inactive" -- indicates the mode the line is currently displayed in
				-- ["time"]                   = float                   -- the fade-out time the line is currently set to
				-- ["textRowElement"]         = AnarkElement            -- the Anark element for the line element (when displaying text)
				-- ["barRowElement"]          = AnarkElement|nil        -- the Anark element for the line element (when displaying a bar) - nil, if the line doesn't support a bar
				-- ["barRowProgressElement1"] = AnarkElement|nil        -- the 1st Anark bar element representing the bar progress - nil, if the line doesn't support a bar
				-- ["barRowProgressElement2"] = AnarkElement|nil        -- the 2nd Anark bar element representing the bar progress - nil, if the line doesn't support a bar
				-- ["barValue"]               = float                   -- the current value represented by the bar
				-- ["left"]                   = AnarkElement            -- the 1st Anark element for the left text element
				-- ["left2"]                  = AnarkElement            -- the 2nd Anark element for the left text element
				-- ["right"]                  = AnarkElement            -- the 1st Anark element for the right text element
				-- ["right2"]                 = AnarkElement            -- the 2nd Anark element for the right text element
			-- }
		-- }
	},
	monitorExtents = {},
}

-- table for callback-related functions (currently only used for radar)
local callbacks = {}
-- local functions forward declarations
local activateFactionLadder
local activateMessageTickerBar
local activateMessageTickerText
local activateMonitor
local activateOverlay
local activateRadarPicking
local activateSeparateRadar
local activateState
local activateTargetMonitorRadar
local changeState
local checkMessageTickerActivation
local checkRadarActivation
local closeCurrentState
local constructPlaceholderText
local copyColor
local deactivateCutscene
local deactivateFactionLadder
local deactivateInteraction
local deactivateMessageTickerLine
local deactivateMonitor
local deactivateOverlay
local deactivateRadarPicking
local deactivateSeparateRadar
local deactivateState
local deactivateTargetMonitorNotification
local deactivateTargetMonitorRadar
local displayInactiveMissionLine
local displayMissionBar
local displayMissionDetails
local enableRadar
local enableSeparateRadar
local getLEDColor
local getTargetMonitorDetailsBridge
local getTextChunks
local handleMouseClickRadar
local handleMouseDownRadar
local hideEnvironmentInfo
local hideMissionDetails
local hideNotorietyBar
local hideSofttarget
local hideTargetMonitorNotification
local initEnvironmentObjectSupport
local initNotifications
local initNotorietyData
local initPointerPicking
local initRadarPicking
local initScale
local isBlinkingLED
local isHighestState
local isSeparateRadarEnabled
local isSomethingToDisplay
local isTargetMonitorRadarEnabled
local isValidTargetMonitorDetailsBridgeData
local onChangedEnvironmentObject
local onChatRead
local onChatReceived
local onCutsceneReady
local onCutsceneStopped
local onEnableRadar
local onEnableSeparateRadar
local onExternalTargetViewActive
local onExternalTargetViewInactive
local onGamePlanChange
local onIncomingMail
local onMailRead
local onMissionInfoUpdate
local onMissionObjectiveBarUpdate
local onMouseClickMessageTickerFooter
local onMouseClickMessageTickerNotification
local onMouseClickMessageTickerChatNotification
local onMouseClickMessageTickerRow1
local onMouseClickTargetMonitor
local onNumMissionsChanged
local onPlayerActivityChanged
local onResetHUDColors
local onShowNotification
local onSofttargetChanged
local onTeleportSucceeded
local onToggleRadarMode
local onUnlock
local onUpdateColorMap
local onUpdateHUDColors
local processLiveUpdateValues
local processOverlay
local queueNotification
local prepareLiveUpdateText
local processInteractionDescriptor
local processMessageTickerNotifications
local removeOldestMessage
local removeStateRequest
local requestState
local scaleFont
local setCheckedText
local setColorHelper
local setTextColor
local setTextElement
local shouldDisplayNotorietyBar
local showEnvironmentInfo
local showNotification
local showNotorietyBar
local showSofttarget
local switchTargetMonitorNotification
local toggleRadarMode
local setDecoColors
local setDecoColorsWithIntensity
local setTextWithLineBreaks
local setMultilineLeftRightText
local truncateLeftRightText
local updateActiveState
local updateActivityColor
local updateChatNotification
local updateCoverLine
local updateMailNotification
local updateMessages
local updateMessageStartTimes
local updateMessageTicker
local updateMissionDetails
local updateNotorietyLadder
local updateRadar
local updateRadarTarget
local updateRelationStatusData
local updateTargetMonitorDisplay
local updateTargetMonitorNotifications

---------------------------------
-- Gameface lifetime functions --
---------------------------------
function self:onInitialize()
	-- initialize Anark elements
	local scene                        = getElement("Scene")
	local contract                     = getElement("UIContract", scene)
	local layer                        = getElement("Layer", scene)
	local targetMonitorUIAnchorElement = getElement("ui_anchor", layer)
	local radarUIAnchorElement         = getElement("ui_anchor_2", layer)
	local messageTickerUIAnchorElement = getElement("ui_anchor_3", layer)
	local missionBarUIAnchorElement    = getElement("ui_anchor_4", layer)

	local anarkElements = private.anarkElements

	-- target monitor elements
	local monitorElement        = getElement("Monitor", targetMonitorUIAnchorElement)
	local targetMonitorElements = anarkElements.targetMonitor
	targetMonitorElements.interactElement       = getElement("interact", monitorElement)
	targetMonitorElements.interactBarElement    = getElement("interact_bar", monitorElement)
	targetMonitorElements.rendertargetElement   = getElement("rendertarget", monitorElement)
	targetMonitorElements.largeRendertargetFrame = getElement("rendertarget", targetMonitorElements.rendertargetElement)
	targetMonitorElements.interactiveText       = getElement("Text", targetMonitorElements.interactElement)
	targetMonitorElements.header                = getElement("header", monitorElement)
	targetMonitorElements.headerText            = getElement("header", targetMonitorElements.header)
	targetMonitorElements.footer                = getElement("footer", monitorElement)
	targetMonitorElements.notorietyBar          = getElement("notoriety_bar", monitorElement)
	targetMonitorElements.notorietyBlinking     = getElement("blink", targetMonitorElements.notorietyBar)

	local factionLadderElements = targetMonitorElements.factionLadder
	factionLadderElements.mainElement  = getElement("factionladder", targetMonitorElements.notorietyBar)
	factionLadderElements.iconElement  = getElement("faction_icon", targetMonitorElements.notorietyBar)
	factionLadderElements.iconMaterial = getElement("material", factionLadderElements.iconElement)
	factionLadderElements.iconTexture  = getElement("texture", factionLadderElements.iconMaterial)
	factionLadderElements.valueText    = getElement("value", factionLadderElements.mainElement)
	factionLadderElements.factionText  = getElement("faction_name", targetMonitorElements.notorietyBar)
	factionLadderElements.relationText = getElement("faction_state", targetMonitorElements.notorietyBar)
	for i = 1, 8 do
		factionLadderElements[i] = getElement("faction"..i, factionLadderElements.mainElement)
	end

	setTextColor(targetMonitorElements.headerText, Color["targetmonitor_text"])
	setColorHelper(getElement("line_top.Material834", targetMonitorElements.header), nil, Color["targetmonitor_deco"])
	setTextColor(targetMonitorElements.interactiveText, Color["targetmonitor_interact_text"])
	setColorHelper(getElement("missionbar_middle.Material1045", targetMonitorElements.interactBarElement), nil, Color["targetmonitor_interact_text"])
	setColorHelper(getElement("radar_background.material", targetMonitorElements.rendertargetElement), nil, Color["gravidar_background"])

	local textElements = targetMonitorElements.textOverlay
	textElements.mainElement = getElement("text_overlay", monitorElement)
	for i = 1, config.maxTargetMonitorTextRows do
		textElements.row[i] = {
			["left"]  = getElement("row_" .. i .. ".left", textElements.mainElement),
			["right"] = getElement("row_" .. i .. ".right", textElements.mainElement),
			["backgroundMaterial"] = getElement("row_" .. i .. ".background.Material1013", textElements.mainElement),
		}
	end

	-- radar monitor elements
	local radarElements = anarkElements.radar
	radarElements.mainElement = getElement("radar", radarUIAnchorElement)
	radarElements.radarFrame  = getElement("rendertarget", radarElements.mainElement)

	setColorHelper(getElement("radar_background.material", radarElements.mainElement), nil, Color["gravidar_background"])

	-- message ticker monitor elements
	local messageTickerElements = anarkElements.messageTicker
	messageTickerElements.mainElement = getElement("ticker", messageTickerUIAnchorElement)
	messageTickerElements.notificationElement = getElement("notification", messageTickerElements.mainElement)
	messageTickerElements.chatNotificationElement = getElement("chatnotification", messageTickerElements.mainElement)
	messageTickerElements.rendertargetElement = getElement("rendertarget", messageTickerElements.mainElement)
	messageTickerElements.rendertarget = getElement("rendertarget", messageTickerElements.rendertargetElement)
	messageTickerElements.row1Element         = getElement("row1", messageTickerElements.mainElement)

	setColorHelper(getElement("radar_background.material", messageTickerElements.rendertargetElement), nil, Color["gravidar_background"])

	-- mission bar element
	local missionBarElements = anarkElements.missionBar
	missionBarElements.mainElement = getElement("missionBar", missionBarUIAnchorElement)
	missionBarElements.textElement1 = getElement("Text1", missionBarElements.mainElement)
	missionBarElements.textElement2 = getElement("Text2", missionBarElements.mainElement)

	-- set up the message ticker related data / elements
	for i = 1, config.numMessageTickerLines do
		local lineElement = getElement("row"..i, private.anarkElements.messageTicker.mainElement)
		local barElement
		local progressElement1
		local progressElement2
		if i <= config.numMissionDetailLines then
			-- only the mission detail lines support the bar mode
			barElement       = getElement("bar"..i, private.anarkElements.messageTicker.mainElement)
			progressElement1 = getElement("normal", barElement)
			progressElement2 = getElement("blinking", barElement)
		end
		private.messageLines[i] = {
			["mode"]                   = "inactive",
			["time"]                   = 0,
			["textRowElement"]         = lineElement,
			["textBackgroundElement"]  = getElement("text_background_gradient", lineElement),
			["textMousepickElement"]   = getElement("mousepick", lineElement),
			["barRowElement"]          = barElement,
			["barBackgroundElement"]   = barElement and getElement("text_background_gradient", barElement) or nil,
			["barRowProgressElement1"] = progressElement1,
			["barRowProgressElement2"] = progressElement2,
			["barValue"]               = 0,
			["left"]                   = getElement("left", lineElement),
			["left2"]                  = getElement("left2", lineElement),
			["right"]                  = getElement("right", lineElement),
			["right2"]                 = getElement("right2", lineElement)
		}
	end

	-- initialize target monitor state requests
	for _, value in ipairs(config.priorization) do
		private.stateRequests[value] = false
	end

	-- init radar elements
	-- init private.radarEnabled - defaults to true, if not set
	private.radarEnabled = C.GetConfigSetting("disableradar") ~= 1
	-- init private.radarMapMode - defaults to 0, if not set
	private.radarMapMode = C.GetRadarModeOption()
	-- init private.enableSeparateRadar - defaults to true, if not set
	private.enableSeparateRadar = C.GetConfigSetting("separateRadar") ~= 0

	local external = C.IsExternalViewActive()
	if private.enableSeparateRadar then
		if external and config.showRadarInTickerinExternalView then
			private.radarRenderTarget = config.tickerRenderTarget
			private.radarPickFrame    = private.anarkElements.messageTicker.rendertarget
		else
			private.radarRenderTarget = config.radarRenderTarget
			private.radarPickFrame    = private.anarkElements.radar.radarFrame
		end
	else
		private.radarRenderTarget = config.largeRenderTarget
		private.radarPickFrame    = private.anarkElements.targetMonitor.largeRendertargetFrame
	end

	-- register for relevant events
	registerForEvent("chatMessageRead", contract, onChatRead)
	registerForEvent("chatMessageReceived", contract, onChatReceived)
	registerForEvent("cutsceneReady", contract, onCutsceneReady)
	registerForEvent("cutsceneStopped", contract, onCutsceneStopped)
	registerForEvent("enableRadar", contract, onEnableRadar)
	registerForEvent("enableSeparateRadar", contract, onEnableSeparateRadar)
	registerForEvent("executeNotification", contract, onMouseClickTargetMonitor)
	registerForEvent("externalTargetViewActive", contract, onExternalTargetViewActive)
	registerForEvent("externalTargetViewInactive", contract, onExternalTargetViewInactive)
	registerForEvent("gamePaused", contract, onGamePaused)
	registerForEvent("gameplanchange", contract, onGamePlanChange)
	registerForEvent("gameUnpaused", contract, onGameUnpaused)
	registerForEvent("incomingMail", contract, onIncomingMail)
	registerForEvent("mailRead", contract, onMailRead)
	registerForEvent("missionInfoUpdate", contract, onMissionInfoUpdate)
	registerForEvent("missionObjectiveBarUpdate", contract, onMissionObjectiveBarUpdate)
	registerForEvent("notificationFreed", contract, onNotificationFreed)
	registerForEvent("numMissionsChanged", contract, onNumMissionsChanged)
	registerForEvent("onUnlock", contract, onUnlock)
	registerForEvent("playerActivityChanged", contract, onPlayerActivityChanged)
	registerForEvent("refreshTargetMonitor", contract, onRefreshTargetMonitor)
	registerForEvent("showNotification", contract, onShowNotification)
	registerForEvent("softtargetChanged", contract, onSofttargetChanged)
	registerForEvent("teleportSucceeded", contract, onTeleportSucceeded)
	registerForEvent("tickerOnlyMode", contract, onTickerOnlyMode)
	registerForEvent("toggleRadarMode", contract, onToggleRadarMode)
	registerForEvent("updateColorMap", contract, onUpdateColorMap)
	registerForEvent("updateHUDColors", contract, onUpdateHUDColors)
	registerForEvent("resetHUDColors", contract, onResetHUDColors)
	NotifyOnCutsceneReady(contract)
	NotifyOnCutsceneStopped(contract)
	NotifyOnIncomingMail(contract)
	NotifyOnMailRead(contract)
	NotifyOnMissionInfoUpdate(contract)
	NotifyOnMissionObjectiveBarUpdate(contract)
	NotifyOnNotificationFreed(contract)
	NotifyOnPlayerActivityChanged(contract)
	NotifyOnTeleportSucceeded(contract)

	-- preload render targets to prevent stuttering
	-- note: preloading both rendertargets so that we won't run into issues when switching the radar integration mode
	PrepareRenderTarget(config.largeRenderTarget)
	PrepareRenderTarget(config.smallRenderTarget)
	PrepareRenderTarget(config.radarRenderTarget)
	PrepareRenderTarget(config.tickerRenderTarget)

	local firstperson = IsFirstPerson()
	-- set whether we allow to display the radar and enable displaying environment object support (which we do in all but the 1st-person modes)
	private.allowRadar = not firstperson
	-- #coreUIMed - simplify environmentObjectSupport by just removing the state requests (instead of keeping that additional state)?
	private.environmentObjectSupport = not firstperson

	-- determine external view mode
	if external then
		-- only required in external mode - otherwise it's false
		private.externalTargetMode = C.IsExternalTargetMode()
		if private.externalTargetMode then
			-- no need to enforce - will be initialized implicitly
			requestState("externalTarget", false)
		end
	end

	-- render settings
	SetFullScreenWorldSpace()

	local huduiscaleoption = ffi.string(C.GetHUDScaleOption())

	private.uiScale = C.GetHUDUIScale(not C.IsVRMode())
	if huduiscaleoption ~= "off" then
		local uiScale = math.min(1.6, C.GetUIScale(not C.IsVRMode()))
		private.textUIScale = uiScale / private.uiScale
	else
		private.textUIScale = 1.0
	end

	setAttribute(private.anarkElements.targetMonitor.factionLadder.factionText, "size", scaleFont(config.factionFontSize))
	setAttribute(private.anarkElements.targetMonitor.factionLadder.relationText, "size", scaleFont(config.factionFontSize))
	setAttribute(private.anarkElements.targetMonitor.factionLadder.valueText, "size", scaleFont(config.factionFontSize))

	local textelement = getElement("Monitor.text_overlay", targetMonitorUIAnchorElement)
	local textbackgroundelement = getElement("ui_gradient_04", textelement)
	local monitordata = {
		id = "targetmonitor",
		x = getAttribute(textelement, "position.x") + getAttribute(textbackgroundelement, "position.x"),
		y = getAttribute(textelement, "position.y") + getAttribute(textbackgroundelement, "position.y"),
		width = getAttribute(textbackgroundelement, "scale.x") * 100,
		height = getAttribute(textbackgroundelement, "scale.y") * 100,
	}
	initScale(targetMonitorUIAnchorElement, config.targetMonitorScaleFactor, true, "Monitor", 1, config.targetMonitorPresentationWidth, monitordata)

	local scaleradar = huduiscaleoption ~= "noradar"
	local rendertargetelement = getElement("radar.rendertarget", radarUIAnchorElement)
	local radardata = {
		id = "radar",
		x = getAttribute(rendertargetelement, "position.x") ,
		y = getAttribute(rendertargetelement, "position.y"),
		width = getAttribute(rendertargetelement, "scale.x") * 100,
		height = getAttribute(rendertargetelement, "scale.y") * 100,
	}
	initScale(radarUIAnchorElement, config.radarScaleFactor, scaleradar, "radar", 0, config.radarMonitorPresentationHeight, radardata, 1.15) -- limit max ui scale for the radar to avoid overlap with crosshair

	local footerelement = getElement("ticker.footer", messageTickerUIAnchorElement)
	private.tickerBackgroundElement = getElement("text_background_gradient", footerelement)
	local tickerdata = {
		id = "messageticker",
		x = getAttribute(footerelement, "position.x") + getAttribute(private.tickerBackgroundElement, "position.x"),
		y = getAttribute(footerelement, "position.y") + getAttribute(private.tickerBackgroundElement, "position.y"),
		width = getAttribute(private.tickerBackgroundElement, "scale.x") * 100,
		height = getAttribute(private.tickerBackgroundElement, "scale.y") * 100,
	}
	initScale(messageTickerUIAnchorElement, config.messageTickerScaleFactor, true, "ticker", -1, config.messageTickerPresentationWidth, tickerdata)
	setAttribute(private.tickerBackgroundElement, "position.y", config.messageTickerBackgroundOffset + (math.ceil(config.messageTickerBaseHeight * (1 - private.textUIScale))) / 2)

	initScale(missionBarUIAnchorElement, config.missionBarScaleFactor, true)
	initMissionBarScale()

	-- initialize static text elements
	local targetMonitorFooterTextElement = getElement("Text", private.anarkElements.targetMonitor.footer)
	setAttribute(targetMonitorFooterTextElement, "textstring", L["INFORMATION"])
	setAttribute(targetMonitorFooterTextElement, "size", scaleFont(config.footerFontSize))
	local messageTickerFooterTextElement = getElement("footer.Text", private.anarkElements.messageTicker.mainElement)
	setAttribute(messageTickerFooterTextElement, "textstring", L["MESSAGES"])
	setAttribute(messageTickerFooterTextElement, "size", scaleFont(config.footerFontSize))

	-- initialize static text color values
	local missionBarLines = getElement("mission_bar_lines", private.anarkElements.missionBar.mainElement)
	setTextColor(private.anarkElements.missionBar.textElement1, config.missionBarColor)
	SetDiffuseColor(getElement("mission_bar_lines", missionBarLines), config.missionBarColor.r, config.missionBarColor.g, config.missionBarColor.b)
	setTextColor(private.anarkElements.missionBar.textElement2, config.missionBarBlinkingColor)
	SetDiffuseColor(getElement("mission_bar_lines2", missionBarLines), config.missionBarBlinkingColor.r, config.missionBarBlinkingColor.g, config.missionBarBlinkingColor.b)

	onPlayerActivityChanged()

	-- initialize picking
	initPointerPicking()

	-- update current notifications in the system
	initNotifications()

	-- environment object handling
	initEnvironmentObjectSupport(contract)

	checkRadarActivation()
end

function setDecoColorsWithIntensity(intensity)
	-- limit intensity to at least 0.5 in the UI for text readibility
	local limitedintensity = math.max(intensity, 0.5)
	local activitycolor = {
		r = private.activityColor.r * limitedintensity,
		g = private.activityColor.g * limitedintensity,
		b = private.activityColor.b * limitedintensity,
		a = private.activityColor.a,
		glow = private.activityColor.glow,
	}
	local activitybackgroundcolor = {
		r = private.activityBGColor.r * intensity,
		g = private.activityBGColor.g * intensity,
		b = private.activityBGColor.b * intensity,
		a = private.activityBGColor.a,
		glow = private.activityBGColor.glow,
	}
	setDecoColors(activitycolor, activitybackgroundcolor)
end

function setDecoColors(activitycolor, activitybackgroundcolor)
	local targetmonitorcolor = activitycolor or Color["targetmonitor_deco"]
	local targetmonitorcolor_background = activitybackgroundcolor or Color["targetmonitor_deco_background"]
	local targetmonitortextcolor = activitycolor or Color["targetmonitor_text"]
	local messagetickercolor = activitycolor or Color["messageticker_deco"]
	local messagetickercolor_background = activitybackgroundcolor or Color["targetmonitor_deco_background"]
	private.messagetickercolor_background = copyColor(messagetickercolor_background)
	if private.tickerOnlyMode and (not private.showTickerOnlyModePermanently) then
		private.messagetickercolor_background.a = 98
	else
		private.messagetickercolor_background.a = 90
	end
	local messagetickertextcolor = activitycolor or Color["messageticker_text"]

	setColorHelper(getElement("ui_gradient_04.Material3446", private.anarkElements.targetMonitor.textOverlay.mainElement), nil, targetmonitorcolor_background)

	for i = 1, config.numMessageTickerLines do
		if i <= config.numMissionDetailLines then
			setColorHelper(getElement("Material3188", private.messageLines[i].barBackgroundElement), private.messageLines[i].barBackgroundElement, private.messagetickercolor_background)
		end
	end

	setColorHelper(getElement("line_top.Material834", private.anarkElements.targetMonitor.footer), nil, targetmonitorcolor)
	setColorHelper(getElement("line_bottom.Material834", private.anarkElements.targetMonitor.footer), nil, targetmonitorcolor)

	setColorHelper(getElement("footer.line_top.Material834", private.anarkElements.messageTicker.mainElement), nil, messagetickercolor)
	setColorHelper(getElement("footer.line_bottom.Material834", private.anarkElements.messageTicker.mainElement), nil, messagetickercolor)

	local parent = getElement("footer.text_background_gradient", private.anarkElements.messageTicker.mainElement)
	setColorHelper(getElement("footer.text_background_gradient.Material3188", private.anarkElements.messageTicker.mainElement), parent, private.messagetickercolor_background)

	setTextColor(getElement("Text", private.anarkElements.targetMonitor.footer), targetmonitortextcolor)
	setTextColor(getElement("footer.Text", private.anarkElements.messageTicker.mainElement), messagetickertextcolor)
	setTextColor(getElement("count", private.anarkElements.messageTicker.notificationElement), messagetickertextcolor)
end

function self:onUpdate()
	if private.autoClose then
		local curtime = getElapsedTime()
		if private.autoClose < curtime then
			closeCurrentState(false)
		else
			local progress = (private.autoClose - curtime) / private.autoCloseDuration
			goToTime(private.anarkElements.targetMonitor.interactBarElement, progress)
		end
	else
		if private.softtargetUpdate then
			if next(private.softtargetUpdate) then
				showSofttarget(table.unpack(private.softtargetUpdate))
			else
				hideSofttarget()
			end
			private.softtargetUpdate = nil
		end

		if private.notorietyLadderFactionDetails or private.notorietyLadderComponentDetails then
			updateNotorietyLadder(private.notorietyLadderFactionDetails, private.notorietyLadderComponentDetails)
		end

		if private.curDescription ~= nil and private.curDescription.requiresKnownCheck and C.IsObjectKnown(private.curDescription.referenceComponent) then
			updateActiveState(true)
			-- #coreUIMed - enable assume() handling
			-- assume(private.curDetails.requiresKnownCheck == false) -- set by updateActiveState()-call
		end

		processLiveUpdateValues()
	end

	updateMessageTicker()
	updateRadar()
	updateActivityColor()
end

-------------------------------------
-- Presentation specific callbacks --
-------------------------------------
function onCutsceneReady(_, cutsceneID)
	if private.curDescription ~= nil and private.curDescription.cutsceneID == cutsceneID then
		goToSlide(private.anarkElements.targetMonitor.rendertargetElement, "small")
	end
end

function onCutsceneStopped(_, cutsceneID)
	if private.curDescription ~= nil and private.curDescription.cutsceneID == cutsceneID then
		closeCurrentState(false) -- notification done due to interrupted cutscene
	end
end

function onNotificationFreed(_, notificationID)
	if private.currentNotificationID ~= nil and private.currentNotificationID == notificationID then
		closeCurrentState(false)
	end
end

function onEnableRadar(_, enable)
	enableRadar(enable)
end

function onEnableSeparateRadar(_, enable)
	enableSeparateRadar(enable)
end

function onExternalTargetViewActive()
	private.externalTargetMode = true
	requestState("externalTarget", false)
	updateRadarTarget()
end

function onExternalTargetViewInactive()
	private.externalTargetMode = false
	removeStateRequest("externalTarget", false)
	updateRadarTarget()
end

function onGamePaused()
	local curtime = getElapsedTime()
	if private.autoClose then
		private.remainingAutoCloseDuration = private.autoClose - curtime
		private.autoClose = nil
	end
	private.pausedTime = curtime

	if private.tickerOnlyMode and (not private.showTickerOnlyModePermanently) then
		private.renderDisabled = true
		C.SetMonitorRenderState(false)
	end
end

function onGameUnpaused()
	local curtime = getElapsedTime()
	if private.remainingAutoCloseDuration then
		private.autoClose = curtime + private.remainingAutoCloseDuration
		private.remainingAutoCloseDuration = nil
	end

	updateMessageStartTimes(curtime, private.pausedTime or 0)
	private.pausedTime = nil

	if private.renderDisabled then
		C.SetMonitorRenderState(true)
		private.renderDisabled = nil
	end
end

function onGamePlanChange(_, gameplan)
	deactivateRadarPicking()

	local mode = "hud"
	local oldAllowRadar = private.allowRadar
	if gameplan == "firstperson" then
		private.allowRadar = false
		private.environmentObjectSupport = false
	elseif gameplan == "external" or gameplan == "externalfirstperson" then
		private.allowRadar = true
		private.environmentObjectSupport = true
		if private.enableSeparateRadar and config.showRadarInTickerinExternalView then
			private.radarRenderTarget = config.tickerRenderTarget
			private.radarPickFrame    = private.anarkElements.messageTicker.rendertarget
		end
	else -- cockpit
		private.allowRadar = true
		private.environmentObjectSupport = true
		if private.enableSeparateRadar and config.showRadarInTickerinExternalView then
			private.radarRenderTarget = config.radarRenderTarget
			private.radarPickFrame    = private.anarkElements.radar.radarFrame
		end
		mode = "cockpit"
	end
	initRadarPicking()

	-- ensure the environment info is removed if displayed atm
	if not private.environmentObjectSupport then
		hideEnvironmentInfo()
	end

	-- update the radar, if the mode was switched
	checkRadarActivation(true)
end

function onIncomingMail()
	private.needMailNotificationUpdate = true
end

function onMailRead()
	private.needMailNotificationUpdate = true
end

function onChatReceived()
	private.needChatNotificationUpdate = true
end

function onChatRead()
	private.needChatNotificationUpdate = true
end

function onMissionInfoUpdate()
	-- we do not trigger the update directly, since that event could happen multiple times per frame - therefore postponing the processing to the normal update cycle
	private.needMissionDetailsUpdate = true
end

function onMissionObjectiveBarUpdate()
	-- we do not trigger the update directly, since that event could happen multiple times per frame - therefore postponing the processing to the normal update cycle
	private.needMissionObjectiveBarUpdate = true
	if private.tickerOnlyMode and (not private.showTickerOnlyModePermanently) then
		private.tickerModeMissionUpdate = getElapsedTime()
	end
end

function onMouseClickMessageTickerFooter(_, delayed)
	if delayed then
		return -- only perform action, if not delayed
	end

	 C.QuickMenuAccess("logbookmenu")
end

function onMouseClickMessageTickerNotification(_, delayed)
	if delayed then
		return -- only perform action, if not delayed
	end

	 C.QuickMenuAccess("messagemenu")
end

function onMouseClickMessageTickerChatNotification(_, delayed)
	if delayed then
		return -- only perform action, if not delayed
	end

	 C.QuickMenuAccess("chat")
end

function onMouseClickMessageTickerRow1(_, delayed)
	-- #coreUIMed - maybe add a check to see if at the point of evaluating the click event we still have an active display of the "inactive missions" line (i.e. prevent cases where in the same frame the inactive mission line was removed)
	if delayed then
		return -- only perform action, if not delayed
	end

	 C.QuickMenuAccess("missionmanagermenu")
end

function callbacks.onMouseDownRadar(element, delayed, modifiers)			handleMouseDownRadar(1, modifiers) end		-- LMB down
function callbacks.onMouseClickRadar(element, delayed, modifiers)			handleMouseClickRadar(1, modifiers) end		-- LMB click
function callbacks.onMouseDblClickRadar(element, delayed, modifiers)		handleMouseClickRadar(2, modifiers) end		-- LMB double-click

function callbacks.onRightMouseDownRadar(element, delayed, modifiers)		handleMouseDownRadar(3, modifiers) end		-- RMB down
function callbacks.onRightMouseClickRadar(element, delayed, modifiers)		handleMouseClickRadar(3, modifiers) end		-- RMB click
function callbacks.onRightMouseDblClickRadar(element, delayed, modifiers)	handleMouseClickRadar(4, modifiers) end		-- RMB double-click

function callbacks.onMiddleMouseDownRadar(element, delayed, modifiers)		handleMouseDownRadar(5, modifiers) end		-- MMB down
function callbacks.onMiddleMouseClickRadar(element, delayed, modifiers)		handleMouseClickRadar(5, modifiers) end		-- MMB click
function callbacks.onMiddleMouseDblClickRadar(element, delayed, modifiers)	handleMouseClickRadar(6, modifiers) end		-- MMB double-click

function callbacks.onSide1MouseDownRadar(element, delayed, modifiers)		handleMouseDownRadar(7, modifiers) end		-- Side Mouse Button 1 down
function callbacks.onSide1MouseClickRadar(element, delayed, modifiers)		handleMouseClickRadar(7, modifiers) end		-- Side Mouse Button 1 click
function callbacks.onSide1MouseDblClickRadar(element, delayed, modifiers)	handleMouseClickRadar(8, modifiers) end		-- Side Mouse Button 1 double-click

function callbacks.onSide2MouseDownRadar(element, delayed, modifiers)		handleMouseDownRadar(9, modifiers) end		-- Side Mouse Button 2 down
function callbacks.onSide2MouseClickRadar(element, delayed, modifiers)		handleMouseClickRadar(9, modifiers) end		-- Side Mouse Button 2 click
function callbacks.onSide2MouseDblClickRadar(element, delayed, modifiers)	handleMouseClickRadar(10, modifiers) end	-- Side Mouse Button 2 double-click

-- Handle mouse-down event on radar
function handleMouseDownRadar(mousebuttonid, modifiers)
	-- Allow input system to process mouse events on the radar element (for details, see targetsystem.lua)
	C.SetMouseInputBlockedByAnarkElement(mousebuttonid, modifiers, false)
	-- Notify engine of mouse-down event on radar to keep track of clicked radar component
	-- NOTE: A click on a radar component only counts if both mouse-down event and mouse-up event happen on the same component (analogous to clicks on Anark elements and HUD geometry)
	local inputstate = ffi.string(C.GetCurrentTargetMouseButtonMapping(mousebuttonid, modifiers, false))
	if inputstate ~= "" then
		C.HandleTargetMouseDownOnRadar()
	end
end

function handleMouseClickRadar(mousebuttonid, modifiers)
	local inputstate = ffi.string(C.GetCurrentTargetMouseButtonMapping(mousebuttonid, modifiers, true))
	if inputstate ~= "" then
		local handled = false

		if inputstate == "INPUT_STATE_TARGETMOUSE_SELECT" then
			handled = C.HandleTargetMouseClickOnRadar(false, false)
		elseif inputstate == "INPUT_STATE_TARGETMOUSE_INTERACTION_MENU" then
			handled = C.HandleTargetMouseClickOnRadar(true, true)
		elseif inputstate == "INPUT_STATE_TARGETMOUSE_SELECT_AND_INTERACT" then
			handled = C.HandleTargetMouseClickOnRadar(false, true)
		else
			DebugError("Radar error. Unhandled target mouse button mapping: " .. inputstate)
		end

		if handled then
			-- Prevent input system from handling this mouse click (for details, see targetsystem.lua)
			C.SetMouseInputBlockedByAnarkElement(mousebuttonid, modifiers, true)
		end
		-- Otherwise, allow clicking "through" the radar on object geometry or empty space
	end
end

function onMouseClickTargetMonitor(_, delayed)
	if not delayed then
		-- #StefanLow - review whether currentNotificationID could have changed
		RaisePlayerInteractionEvent(private.curDescription.interactionID)
	end
end

function callbacks.onMouseOverRadar()
	private.pointerOverRadar = true
end

function callbacks.onMouseOutRadar()
	private.pointerOverRadar = false
	C.InvalidateRadarCursorPosition();
end

function onNumMissionsChanged(_, numMissions)
	-- #coreUIMed - only schedule this event rather than directly evaluating it, since it can be triggered multiple times per frame
	local missionInfo = C.GetMissionInfo3()
	if missionInfo.active then
		return -- nothing to do, if there is an active mission atm
	end

	hideMissionDetails()
	if numMissions > 0 then
		displayInactiveMissionLine(tonumber(numMissions))
	end
end

function onPlayerActivityChanged()
	local activity, activitycolor, activitybackgroundcolor = GetPlayerActivity()
	if activity == "none" then
		activitycolor = nil
		activitybackgroundcolor = nil
	else
		activitycolor = Color[activitycolor]
		activitybackgroundcolor = Color[activitybackgroundcolor]
	end
	private.activityColor = activitycolor
	private.activityBGColor = activitybackgroundcolor
	if activityolor then
		setDecoColorsWithIntensity(C.GetModeLightIntensity())
	else
		setDecoColors(private.activityColor, private.activityBGColor)
	end
end

function onUpdateHUDColors(_, colorstring)
	local colors = {}
	for color in string.gmatch(colorstring, "([^;]+)") do
		table.insert(colors, tonumber(color))
	end
	-- set background colour values to be only 20% of the real value to not make the background too bright
	private.activityColor = { r = colors[1], g = colors[2], b = colors[3], a = 90, glow = 0.5 }
	private.activityBGColor = { r = colors[1] / 5, g = colors[2] / 5, b = colors[3] / 5, a = 75, glow = 0.1 }
	setDecoColors(private.activityColor, private.activityBGColor)
end

function onResetHUDColors()
	private.activityColor = nil
	private.activityBGColor = nil
	setDecoColors(private.activityColor, private.activityBGColor)
end

function onRefreshTargetMonitor(_, componentID, connectionname)
	local update = false
	if componentID ~= 0 then
		if private.curDescription then
			if (private.curDescription.referenceConnectionName == nil) and (connectionname == "") then
				connectionname = nil
			end
			update = (private.curDescription.referenceComponent == componentID) and (private.curDescription.referenceConnectionName == connectionname)
		end
	else
		update = private.currentState == "notification"
	end

	if update then
		updateActiveState(true, true)
	end
end

function onShowNotification(_, notificationID)
	showNotification(notificationID)
end

-- #coreUILow - consider whether a playerShipChanged-event wouldn't be more appropriate
function onTeleportSucceeded()
	-- ensure we update the current radar target if we changed just teleported (f.e. switch from player ship focus component to player
	-- space suit focuscomponent in emergency teleport case)
	-- #coreUILow - reduce the update handling to relevant states (f.e. no softtarget)
	updateRadarTarget()
end

function onTickerOnlyMode(_, enabled, showpermanently)
	private.tickerOnlyMode = enabled
	private.showTickerOnlyModePermanently = showpermanently

	if private.tickerOnlyMode and (not private.showTickerOnlyModePermanently) then
		if C.IsGamePaused() then
			private.renderDisabled = true
			C.SetMonitorRenderState(false)
		end
	end

	if not showpermanently then
		if enabled then
			SetPresentationPosition(3, "messageticker_plain")
			if private.currentState == "notification" then
				if private.curDescription then
					private.curDescription.keepDescription = true
				end
			else
				closeCurrentState(false)
				deactivateMonitor(false)
			end
		else
			SetPresentationPosition(3, "messageticker")
			-- restore softtarget
			local softtargetDetails = C.GetSofttarget2()
			if softtargetDetails.softtargetID ~= 0 then
				showSofttarget(softtargetDetails.softtargetID, ffi.string(softtargetDetails.softtargetConnectionName))
			end
			-- restore environment object
			local objectid = C.GetEnvironmentObject()
			if objectid ~= 0 then
				hideEnvironmentInfo()
				showEnvironmentInfo(objectid)
			end

			updateActiveState(false, true, false, true)
			if private.curDescription then
				private.curDescription.keepDescription = nil
			end
		end
	else
		SetPresentationPosition(3, "messageticker")
		updateActiveState(false, true, false, true)
		if private.curDescription then
			private.curDescription.keepDescription = nil
		end
	end
	onPlayerActivityChanged()
	checkRadarActivation(true)
	updateInteractiveText()

	if ((not enabled) or showpermanently) and private.renderDisabled then
		C.SetMonitorRenderState(true)
		private.renderDisabled = nil
	elseif enabled and (not showpermanently) and private.pausedTime then
		C.SetMonitorRenderState(false)
		private.renderDisabled = true
	end
end

function onToggleRadarMode()
	toggleRadarMode()
end

function onChangedEnvironmentObject()
	if private.environmentObjectSupport then
		hideEnvironmentInfo()

		local objectid = C.GetEnvironmentObject()
		if objectid ~= 0 then
			showEnvironmentInfo(objectid)
		end
	end
end

function onSofttargetChanged(_, softtargetmessageid)
	if softtargetmessageid then
		local softtargetDetails = C.GetSofttarget2()

		-- we have to ensure again that there's really a softtarget because we'd also get this call for already destroyed softtarget messages (those, which
		-- were removed/destroyed in-between the softtarget dispatch call)
		if softtargetDetails.softtargetID ~= 0 then
			private.softtargetUpdate = {softtargetDetails.softtargetID, ffi.string(softtargetDetails.softtargetConnectionName)}
			return
		end
	end

	-- otherwise, reset the softtarget
	private.softtargetUpdate = {}
end

function onUnlock()
	-- reset the presentation, so it displays the correct state

	-- #coreUIHigh -- should this update externalviewstates and HUD/cockpit mode here?

	-- #coreUILow --- XT-3829 - ultimately we'd actually handle restoring the correct monitor state correctly meaning:
		-- set the correct softtarget, if we have one
		-- set the dialog map correctly, if it's active
		-- do not abort the cutscene, if it's still active upon unlocking
		-- proper handle the current selected softtarget action
	-- however, all of these are minor things, and hence can be handled with a very low priority

	-- hide any previous state, in-case it was kept before locking the monitor
	hideSofttarget()

	-- update current notifications in the system
	initNotifications()

	-- note: must be done after initNotifications - otherwise, notifications are still set to active and closeCurrentState() would switch to the next notification (unnecessarily)
	if private.curDescription then
		closeCurrentState(true) -- we must force a state-update here, since we might have missed a notification/event and we didn't unset the map, in case the UI changed modes (for instance from Cockpit to FirstPerson mode)
	end

	if private.environmentObjectSupport then
		-- set initial state of environmental info
		local environmentTargetID = C.GetEnvironmentObject()
		if environmentTargetID ~= 0 then
			showEnvironmentInfo(environmentTargetID)
		else
			hideEnvironmentInfo()
		end
	end

	-- normally we'd have to call updateActiveState here (case: showing "no signal" initially) --- however, that's already done in initNotifications() and show/hideEnvironmentInfo()

	-- reset the pointer over radar state, since we might have missed a mouseOut-event while the presentation was locked
	-- #coreUIMed - properly retrieve the current mouse-over state
	callbacks.onMouseOutRadar()

	checkRadarActivation()
end

function onUpdateColorMap()
	getColors()
end

-------------------------------------
-- Presentation specific functions --
-------------------------------------
function activateFactionLadder()
	if private.factionLadderActive then
		return -- already active
	end

	goToSlide(private.anarkElements.targetMonitor.factionLadder.mainElement, "active")

	private.factionLadderActive = true
end

function activateMessageTickerBar(line, blinking)
	-- make sure the bar is active (and textline is inactive)
	-- note: do not skip the goToSlide() call for the bar element even if we are already in the "bar" line mode, since we might have to restart the blinking effect
	-- #coreUIMed - we need to handle timing here if a line is moved downwards --- in such a case the blinking should neither restart, nor should it be reset to the start but rather continue
	--              at its current time interval
	-- #coreUIMed - optimize and skip the unnecessary goToSlide()-call, if we are already in the right bar slide (i.e. in active slide and blinking is false)
	if line.mode == "text" then
		goToSlide(line.textRowElement, "inactive")
	end

	-- #coreUIMed - assert line.barRowElement ~= nil
	if blinking then
		goToSlide(line.barRowElement, "blinking")
	else
		goToSlide(line.barRowElement, "active")
	end
	line.mode = "bar"
end

function activateMessageTickerText(line)
	-- make sure the text line is active (and textline is inactive)
	if line.mode == "text" then
		return -- text line already displayed, nothing to do
	end

	if line.mode == "bar" then
		goToSlide(line.barRowElement, "inactive")
	end

	local slide = "active"
	if private.tickerOnlyMode and (not private.showTickerOnlyModePermanently) then
		slide = "opaque"
	end
	goToSlide(line.textRowElement, slide)
	line.mode = "text"
end

function activateMonitor(state)
	if private.monitorActive then
		return	-- monitor already active, nothing to do
	end

	-- the monitor is only activated, if the requested state is not the inactive state, or we display the radar on the target monitor
	if (isTargetMonitorRadarEnabled() or (state ~= "inactive")) then
		PlaySound("ui_mon_eve_hud_on_core")
		private.monitorActive = true
	end
end

function activateOverlay()
	if private.overlayActive then
		return -- already active
	end

	goToSlide(private.anarkElements.targetMonitor.footer, "active")
	goToSlide(private.anarkElements.targetMonitor.header, "active")
	goToSlide(private.anarkElements.targetMonitor.textOverlay.mainElement, "active")

	private.overlayActive = true
end

function activateRadarPicking()
	if private.radarPickingEnabled then
		return -- picking already enabled, nothing to do
	end

	RegisterMouseInteractions(private.radarPickFrame)

	private.radarPickingEnabled = true
end

function activateSeparateRadar(force)
	if (not force) and private.separateRadarActive then
		return -- radar already active, nothing to do
	end

	-- #coreUIMed - enable assume() handling
	--assume(not private.targetMonitorRadarActive)
	--assume(not private.radarActive)

	-- note: must be set prior to calling updateRadarTarget()
	private.separateRadarActive = true
	private.radarActive = true

	if not updateRadarTarget() then
		DebugError("Radar error. Failed to display radar. Radar will be inactive.")
		-- #coreUIMed - add better fallback handling (i.e. show no-signal empty monitor maybe?)
		private.radarActive = false
		private.separateRadarActive = false
		return
	end

	if C.IsExternalViewActive() then
		goToSlide(private.anarkElements.messageTicker.rendertargetElement, "large")
		goToSlide(private.anarkElements.radar.mainElement, "inactive")
	else
		goToSlide(private.anarkElements.messageTicker.rendertargetElement, "inactive")
		goToSlide(private.anarkElements.radar.mainElement, "active")
	end

	-- the separate radar has radar picking enabled unconditionally, so activate it implicitly alongside
	activateRadarPicking()
end

function activateState(state, allowPlaySound, refresh)
	local details
	local playSound = true

	-- set the data based on the state
	-- check tickerOnlyMode here, only notifications are allowed in tickerOnlyMode
	local tickeronlymode = private.tickerOnlyMode and (not private.showTickerOnlyModePermanently)
	if (not tickeronlymode) and (state == "softtarget") then
		details = getTargetMonitorDetailsBridge(private.softtargetID, private.softtargetTemplateConnectionName, true)
	elseif (not tickeronlymode) and (state == "externalTarget") then
		-- note: at the time of writing this, focusComponent is ensured to still exist - but since this is retrieved from an external system, we cannot be sure about this
		local focusComponent = C.GetExternalTargetViewComponent()
		details = getTargetMonitorDetailsBridge(focusComponent)
	elseif (not tickeronlymode) and (state == "environmentinfo") then
		-- note: environmentTargetID is not ensured to still be valid at this time (neither in reality, nor concept wise, since this is retrieved from an external system)
		details = getTargetMonitorDetailsBridge(private.environmentTargetID)
	elseif state == "notification" then
		-- #coreUIMed - also add handling for notifications to be treated like the rest of the cases (i.e. set/get details struct and pass that on to updateTargetMonitorDisplay())
		-- then change the inactive state handling below and call deactivateMonitor() if details == nil?
		private.notificationsActive = true
		if not refresh then
			updateTargetMonitorNotifications() -- update the notification immediately, so to correctly swap to the next one, if the notification slide was reactivated
		else
			updateTargetMonitorDisplay(private.curDescription, isTargetMonitorRadarEnabled(), true)
		end
	else -- state == "inactive"
		if isTargetMonitorRadarEnabled() then
			details = {} -- default view (i.e. show radar without any overlay)
		else
			-- deactivate the monitor completely in this case
			deactivateMonitor(allowPlaySound)
			playSound = false
		end
	end

	-- process the data now
	if details ~= nil then
		if details.cutsceneDescriptor or details.interactionID then
			-- if we display a descriptor, mark it for deletion
			-- #coreUIMed - reconsider adding separate struct, so that the external provided data would not
			-- mess around with the deleteDescriptor value
			details.deleteDescriptor = true
		end
		updateTargetMonitorDisplay(details, isTargetMonitorRadarEnabled(), false)
	end

	if playSound then
		PlaySound("ui_mon_eve_change_core")
	end
	-- #coreUIMed add support to abort state activation (on error) - then consider changing the code above (inactive-state) to simply return false
end

function activateTargetMonitorRadar()
	if private.targetMonitorRadarActive then
		return -- radar already active, nothing to do
	end

	-- #coreUIMed - enable assume() handling
	--assume(not private.separateRadarActive)
	--assume(not private.radarActive)

	-- note: must be set prior to calling updateRadarTarget()
	private.targetMonitorRadarActive = true
	private.radarActive = true

	if not updateRadarTarget() then
		DebugError("Radar error. Failed to display radar. Radar will be inactive.")
		-- #coreUIMed - add better fallback handling (i.e. show no-signal empty monitor maybe?)
		private.targetMonitorRadarActive = false
		private.radarActive = false
	end
end

-- #coreUIMed - review the allowPlaySound parameter - a bit hacky and used for quick/dirty approach
--              should be dropped (used only so that deactivating the target monitor as part of the switch to hud mode
--              no sound is being played)
function changeState(state, force, allowPlaySound, refresh, keepCutscene)
	if not force and private.currentState == state then
		return -- correct slide is already active
	end

	local previousState = private.currentState
	private.currentState = state

	deactivateState(previousState, refresh, keepCutscene)
	activateMonitor(state)

	-- note: the monitor will not be activated in certain cases (see activateMonitor for specifics), so we must check this here before activating the state
	if private.monitorActive then
		if (state == "notification") and keepCutscene then
			refresh = false
		end
		activateState(state, allowPlaySound, refresh)
	end
end

function checkMessageTickerActivation()
	local oldstate = private.messageTickerActive
	-- activate the message ticker
	if private.tickerOnlyMode and (not private.showTickerOnlyModePermanently) then
		if ((private.tickerModeMissionUpdate and (private.tickerModeMissionUpdate + 6) or -1) > getElapsedTime()) or (config.showMessagesInTickerOnlyMode and (#private.messageTickerMessages > (private.numMissionDetailLines + (private.coverLineActive and 1 or 0)))) then
			private.messageTickerActive = true
		else
			private.messageTickerActive = false
		end
	else
		if (#private.messageTickerMessages > 0) or (private.numCurrentMails > 0) or (private.numCurrentChats > 0) then
			private.messageTickerActive = true
		else
			private.messageTickerActive = false
		end
	end
	if private.messageTickerActive ~= oldstate then
		goToSlide(private.anarkElements.messageTicker.mainElement, private.messageTickerActive and "active" or "inactive")
	end

	-- activate the mail notification element
	if private.messageTickerActive and (private.numCurrentMails > 0) then
		if not private.mailNotificationElementActive then
			goToSlide(private.anarkElements.messageTicker.notificationElement, "active")
			private.mailNotificationElementActive = true
		end
	elseif private.mailNotificationElementActive then
		goToSlide(private.anarkElements.messageTicker.notificationElement, "inactive")
		private.mailNotificationElementActive = false
	end

	-- activate the chat notification element
	if private.messageTickerActive and OnlineIsCurrentTeamValid() then
		if not private.chatNotificationElementActive then
			goToSlide(private.anarkElements.messageTicker.chatNotificationElement, "active")
			private.needChatNotificationUpdate = true
			private.chatNotificationElementActive = true
		end
	else
		if private.chatNotificationElementActive then
			goToSlide(private.anarkElements.messageTicker.chatNotificationElement, "inactive")
			private.chatNotificationElementActive = false
		end
	end
end

function checkRadarActivation(force)
	if isSeparateRadarEnabled() then
		activateSeparateRadar(force)
	else
		deactivateSeparateRadar()
	end
end

function closeCurrentState(force)
	private.autoClose = nil
	private.remainingAutoCloseDuration = nil

	if private.notificationsActive then
		-- go to next notification
		updateTargetMonitorNotifications()
		return
	end

	removeStateRequest(private.currentState, force)
end

-- function takes chunks and creates the to be displayed text with all placeholders having been replaced
function constructPlaceholderText(chunks, component, connection)
	local text = ""

	for _, entry in ipairs(chunks) do
		if not entry.isPlaceholder then
			text = text..entry.text
		else
			local entryText = GetLiveDataBridge(entry.text, tostring(component), connection)
			if entryText == nil then
				-- if the call didn't return any value, add the placeholder itself
				text = text.."$"..entry.text.."$"
			else
				text = text..entryText
			end
		end
	end

	return text
end

function deactivateCutscene()
	if private.curDescription and private.curDescription.cutsceneID then
		StopCutscene(private.curDescription.cutsceneID)
		private.curDescription.cutsceneID = nil
		if private.curDescription.deleteDescriptor and private.curDescription.cutsceneDescriptor then
			ReleaseCutsceneDescriptor(private.curDescription.cutsceneDescriptor)
			private.curDescription.cutsceneDescriptor = nil
		end
	end
end

function deactivateInteraction()
	if private.curDescription and private.curDescription.interactionID then
		goToSlide(private.anarkElements.targetMonitor.interactElement, "inactive")
		goToSlide(private.anarkElements.targetMonitor.interactBarElement, "inactive")
		TargetMonitorInteractionHidden2(private.curDescription.interactionID)
		if private.curDescription.deleteDescriptor and private.curDescription.interactionID then
			C.ReleaseInteractionDescriptor(private.curDescription.interactionID)
			private.curDescription.interactionID = nil
		end
	end
end

function deactivateMessageTickerLine(line)
	if line.mode == "inactive" then
		return -- line already inactive, nothing to do
	end

	if line.mode == "bar" then
		goToSlide(line.barRowElement, "inactive")
	else -- line.mode == "text"
		goToSlide(line.textRowElement, "inactive")
	end

	line.mode = "inactive"
end

function deactivateMonitor(playSound)
	-- clear the monitor (all parameters false/nil by default)
	updateTargetMonitorDisplay({}, false, false)

	if playSound then
		PlaySound("ui_mon_eve_hud_off_core")
	end

	private.monitorActive = false
end

function deactivateOverlay()
	if not private.overlayActive then
		return -- already inactive
	end

	goToSlide(private.anarkElements.targetMonitor.footer, "inactive")
	goToSlide(private.anarkElements.targetMonitor.header, "inactive")
	goToSlide(private.anarkElements.targetMonitor.textOverlay.mainElement, "inactive")

	-- clear any (potentially used) liveUpdateValues
	private.targetMonitorStateLiveUpdateData = nil
	private.liveUpdateValues = {}

	hideNotorietyBar()

	private.overlayActive = false
end

function deactivateRadarPicking()
	if not private.radarPickingEnabled then
		return -- picking already disabled, nothing to do
	end

	UnregisterMouseInteractions(private.radarPickFrame)
	callbacks.onMouseOutRadar()

	private.radarPickingEnabled = false
end

function deactivateSeparateRadar()
	if not private.separateRadarActive then
		return -- radar already inactive, nothing to do
	end

	-- #coreUIMed - enable assume() handling
	--assume(not private.targetMonitorRadarActive)
	--assume(private.radarActive)

	-- deactivating the radar implicitly deactivates radar picking
	deactivateRadarPicking()

	C.UnsetRadarRenderTarget()
	goToSlide(private.anarkElements.messageTicker.rendertargetElement, "inactive")
	goToSlide(private.anarkElements.radar.mainElement, "inactive")
	private.separateRadarActive = false
	private.radarActive = false
end

function deactivateState(state, refresh, keepCutscene)
	private.autoClose = nil
	private.remainingAutoCloseDuration = nil

	if not keepCutscene then
		-- deactivate any cutscene (is used for notifications as well as other "normal" cases like softtarget display)
		deactivateCutscene()
	end

	-- deactivate any previous interaction (is used for notifications as well as other "normal" cases like softtarget display)
	deactivateInteraction()

	-- deactivate any displayed overlay
	deactivateOverlay()

	if (state == "notification") and (not refresh) then
		deactivateTargetMonitorNotification()
		private.notificationsActive = false
		-- entirely deactivate notifications, if we just displayed the last one
		if not next(private.targetMonitorNotifications) then
			private.stateRequests["notification"] = false
		end
	end
end

function deactivateTargetMonitorNotification()
	if private.currentNotificationID then
		-- also deactivate a cutscene (if it's still running that is)
		deactivateCutscene()

		-- also deactivate the interaction (if it was active in the previous notification)
		deactivateInteraction()

		ReleaseNotification(private.currentNotificationID)
		private.curDescription.keepDescription = nil
		private.currentNotificationID = nil
	end
end

function deactivateTargetMonitorRadar()
	if not private.targetMonitorRadarActive then
		return -- radar already inactive, nothing to do
	end

	-- #coreUIMed - enable assume() handling
	--assume(not private.targetMonitorRadarActive)
	--assume(private.radarActive)

	-- deactivating the radar implicitly deactivates radar picking
	deactivateRadarPicking()

	C.UnsetRadarRenderTarget()
	private.targetMonitorRadarActive = false
	private.radarActive = false
end

function displayInactiveMissionLine(numInactiveMissions)
	local entry = {
		left = {
			text     = string.format(L["%u inactive mission(s)"], tonumber(numInactiveMissions)),
			font     = config.missionDataFont,
			fontsize = scaleFont(config.missionDataFontSize),
			color    = config.messageTickerInactiveMissionTextColor
			-- note: no blinkColor since unused (blinking = false)
		},
		right = {
			text     = "",
			font     = config.missionDataFont,
			fontsize = scaleFont(config.missionDataFontSize),
			color    = config.messageTickerInactiveMissionTextColor
			-- note: no blinkColor since unused (blinking = false)
		},
		blinking = false, -- inactive missions-entry doesn't blink
		permanent = true  -- mission details are displayed permanently (i.e. no timeout)
	}

	if private.inactiveMissionLineActive then
		-- inactive mission line already displayed - simply replace the entry
		private.messageTickerMessages[1] = entry
	else
		-- simply insert the line as the first one (superfluous rows will be handled by the caller)
		table.insert(private.messageTickerMessages, 1, entry)
	end

	-- activate pointer-picking for the row
	RegisterMouseInteractions(private.anarkElements.messageTicker.row1Element)

	private.numMissionDetailLines = 1
	private.inactiveMissionLineActive = true
end

function displayMissionDetails(missionInfo, blinking)
	local entries = {}
	local numLines = 0

	-- process all mission detail lines
	-- (note: processing the lines in reverse, so we put the last line in as the first one - when we process the entries later, we then have the correct ordering in the message ticker rows (with row 1 being the lower most row))
	for i = config.numMissionDetailLines, 1, -1 do
		if missionInfo.barLine == i then
			-- line displays a progress bar

			numLines = numLines + 1
			entries[numLines] = {
				barValue  = missionInfo.barPercent,
				blinking  = blinking,
				permanent = true
			}
		else
			-- line displays normal text (or nothing)

			local invert = i == 1
			local leftLine  = ffi.string(missionInfo["line"..i.."Left"])
			local rightLine = ffi.string(missionInfo["line"..i.."Right"])
			local numtextlines = 1
			leftLine, rightLine, numtextlines = setMultilineLeftRightText({ text = leftLine, font = config.missionDataFont, fontsize = scaleFont(config.missionDataFontSize) }, { text = rightLine, font = config.missionDataFont, fontsize = scaleFont(config.missionDataFontSize) }, config.messageTickerPresentationWidth - (invert and (2 * config.messageTickerInvertedTextOffsetX) or (2 * config.messageTickerTextOffsetX)), "   ")

			-- skip empty lines (as per the interface definition)
			if leftLine ~= "" or rightLine ~= "" then
				numLines = numLines + 1
				entries[numLines] = {
					left = {
						text       = leftLine,
						font       = invert and config.missionDataFontBold or config.missionDataFont,
						fontsize   = scaleFont(config.missionDataFontSize),
						blinkColor = config.messageTickerMissionBlinkColor,
						color      = config.messageTickerMissionColor
					},
					right = {
						text       = rightLine,
						font       = invert and config.missionDataFontBold or config.missionDataFont,
						fontsize   = scaleFont(config.missionDataFontSize),
						blinkColor = config.messageTickerMissionBlinkColor,
						color      = config.messageTickerMissionColor
					},
					numtextlines = numtextlines,
					blinking = blinking,
					permanent = true,     -- mission details are displayed permanently (i.e. no timeout)
					invert = invert,
				}
			end
		end
	end

	-- error handling/fallback in case the mission failed to provide any details
	if numLines == 0 then
		-- create a dummy entry, to prevent UI glitches, if a mission failed to provide any mission details to display (i.e. prevent the case that the message ticker displays nothing while a mission is active which
		-- would be experienced like a bug
		entries[1] = {
			left = {
				text     = L["No mission data"],
				font     = config.missionDataFont,
				fontsize = scaleFont(config.missionDataFontSize),
				color    = config.messageTickerMissionColor
				-- note: no blinkColor since unused (blinking = false)
			},
			right = {
				text     = "",
				font     = config.missionDataFont,
				fontsize = scaleFont(config.missionDataFontSize),
				color    = config.messageTickerMissionColor
				-- note: no blinkColor since unused (blinking = false)
			},
			blinking = false,
			permanent = true, -- mission details are displayed permanently (i.e. no timeout)
		}
		numLines = 1
	end

	-- mark the first line
	entries[numLines].firstMessageLine = true

	-- replace any already displayed mission lines with the new ones
	for i = 1, math.min(numLines, private.numMissionDetailLines) do
		entries[i].startTime = private.messageTickerMessages[i].startTime
		private.messageTickerMessages[i] = entries[i]
	end

	-- insert any remaining lines into the list
	for i = math.min(numLines, private.numMissionDetailLines) + 1, numLines do
		table.insert(private.messageTickerMessages, i, entries[i])
	end

	-- remove any previous (now outdated) mission detail line
	for i = numLines + 1, private.numMissionDetailLines do
		-- note: numLines + 1 is correct here, since removing entries will shift down all following lines
		table.remove(private.messageTickerMessages, numLines + 1)
	end

	-- deactivate pointer-picking for the row (if it was registered before
	if private.inactiveMissionLineActive then
		UnregisterMouseInteractions(private.anarkElements.messageTicker.row1Element)
		private.inactiveMissionLineActive = false
	end

	private.numMissionDetailLines = numLines
end

function updateRadarExtents()
	-- radar extents
	local tickerextents = private.monitorExtents["messageticker"]
	if private.radarEnabled and private.enableSeparateRadar then
		if C.IsExternalViewActive() and config.showRadarInTickerinExternalView then
			-- ticker radar extents
			tickerextents.showingRadar = true
			local rendertargetheight = getAttribute(getElement("rendertarget.radar_background", private.anarkElements.messageTicker.mainElement), "scale.y") * 100 * private.uiScale * config.messageTickerScaleFactor
			C.SetMonitorExtents("messageticker", tickerextents.x, tickerextents.y + rendertargetheight / 2, tickerextents.width, tickerextents.height + rendertargetheight)
			C.SetMonitorExtents("radar", 0, 0, 0, 0)
		else
			-- normal radar extents
			tickerextents.showingRadar = false
			local extents = private.monitorExtents["radar"]
			C.SetMonitorExtents("radar", extents.x, extents.y, extents.width, extents.height)
		end
	else
		-- no radar extents
		tickerextents.showingRadar = false
		C.SetMonitorExtents("radar", 0, 0, 0, 0)
	end
end

function enableRadar(enable)
	private.radarEnabled = enable
	updateRadarExtents()

	-- note: we do have to retrigger the state-check here, even if radarEnabled got disabled (i.e. is[TargetMonitor|Separate]RadarEnabled() now returns false), since that should deactivate the currently displayed
	-- radar (if one is currently displayed, that is)
	if private.allowRadar and (not private.tickerOnlyMode) then
		-- #coreUILow --- could be improved so we determine the actual state upon activating the radar
		-- reset the mouse-over-radar state when the radar is enabled/disabled to prevent outdated highlighted components being displayed
		-- note: this is also required when switching between the integrated/separate radar modes
		callbacks.onMouseOutRadar()

		if private.enableSeparateRadar then
			checkRadarActivation()
		else
			updateActiveState(true)
		end
	end
end

function enableSeparateRadar(enable)
	if private.enableSeparateRadar == enable then
		return -- nothing to do, radar already in proper mode
	end

	-- deactivate the current radar mode
	local reactivateRadar = private.radarEnabled
	if private.radarEnabled then
		enableRadar(false)
	end

	deactivateRadarPicking()
	-- switch the related variables
	if enable then
		if C.IsExternalViewActive() and config.showRadarInTickerinExternalView then
			private.radarRenderTarget = config.tickerRenderTarget
			private.radarPickFrame    = private.anarkElements.messageTicker.rendertarget
		else
			private.radarRenderTarget = config.radarRenderTarget
			private.radarPickFrame    = private.anarkElements.radar.radarFrame
		end
	else
		private.radarRenderTarget = config.largeRenderTarget
		private.radarPickFrame    = private.anarkElements.targetMonitor.largeRendertargetFrame
	end
	initRadarPicking()

	private.enableSeparateRadar = enable

	-- activate the new radar mode
	if reactivateRadar then
		enableRadar(true)
	end
end

-- #StefanMed - simplify getTargetMonitorDetailsBridge and updateTargetMonitorDisplay - they should be combinable now
function getTargetMonitorDetailsBridge(componentID, connectionName, issofttarget)
	-- note: on error, in the GetTargetMonitorDetails()-call, we'd end up with a nil-return here
	local details = GetTargetMonitorDetailsBridge(tostring(componentID), connectionName, issofttarget)

	if not isValidTargetMonitorDetailsBridgeData(details) then
		DebugError("Target monitor error. Failed to retrieve details from GetTargetMonitorDetails. Reverting to default handling.")
		details = {} -- revert using an empty details container and fill with default values
	end

	-- patch the returned data to comply to our internal requirements
	details.referenceComponent = componentID
	details.referenceConnectionName = connectionName
	details.requiresKnownCheck = not C.IsObjectKnown(componentID)

	return details
end

function deactivateFactionLadder()
	if not private.factionLadderActive then
		return -- already inactive
	end

	local factionLadderElements = private.anarkElements.targetMonitor.factionLadder

	goToSlide(factionLadderElements.mainElement, "inactive")

	-- deactivate ladder elements
	for i = 1, 8 do
		goToSlide(factionLadderElements[i], "inactive")
	end

	private.factionLadderActive = false
end

function displayMissionBar(text)
	if text == "" then
		-- if we received a mission update with no explicit text, don't display anything and actually deactivate the bar immediately (so a potentially outdated text
		-- element is hidden immediately)
		goToSlide(private.anarkElements.missionBar.mainElement, "inactive")
		return
	end

	goToSlide(private.anarkElements.missionBar.mainElement, "active")
	-- reset the animation state, if a different text was triggered, while another one is displayed
	goToTime(private.anarkElements.missionBar.mainElement, 0)
	setAttribute(private.anarkElements.missionBar.textElement1, "textstring", text)
	setAttribute(private.anarkElements.missionBar.textElement2, "textstring", text)
end

function getLEDColor(LEDElementNumber, relationLEDValue)
	local colorIndex = config.notorietyColorMatrix[relationLEDValue][LEDElementNumber]
	return config.notorietyLEDColor[colorIndex]
end

function getTextChunks(text)
	if type(text) ~= "string" then
		return text -- early out --- nil or number can return directly --- this ensures that the following algorithm doesn't have to deal with number types and #text won't issue a Lua error
	end

	local chunks = {}

	local placeHolderStart = false
	local placeholderFound = false
	local plainText = ""
	local placeholder = ""

	for i = 1, #text do
		local w = string.sub(text, i, i)
		if w == "$" then
			if not placeHolderStart then
				placeHolderStart = true
			else -- found a $ after a placeholder was started
				-- check if there's any recorded character in the placeholder-text - if so, it's an endtag - otherwise it's an escaped $$
				if placeholder == "" then
					plainText = plainText.."$"
				else
					-- placeholder end-tag found
					if plainText ~= "" then
						-- first we record any previous plainText
						table.insert(chunks, { ["isPlaceholder"] = false, ["text"] = plainText })
					end
					table.insert(chunks, { ["isPlaceholder"] = true, ["text"] = placeholder })
					placeholder = ""
					plainText = ""
					placeholderFound = true
				end
				placeHolderStart = false
			end
		else -- it's not a $, hence record the character in the right element
			if placeHolderStart then
				placeholder = placeholder..w
			else
				plainText = plainText..w
			end
		end
	end

	if placeHolderStart then
		-- case: foo$bar -> plain-text-element with a simple $
		plainText = plainText.."$"..placeholder
	end

	if plainText ~= "" then
		table.insert(chunks, { ["isPlaceholder"] = false, ["text"] = plainText })
	end

	if placeholderFound then
		return chunks
	end

	return plainText -- just plain text - no chunks
end

function hideEnvironmentInfo()
	private.environmentTargetID = 0
	removeStateRequest("environmentinfo", false)
end

function hideMissionDetails()
	for i = 1, private.numMissionDetailLines do
		-- note: 1 is correct here, since removing entries will shift down all following entires
		table.remove(private.messageTickerMessages, 1)
	end
	private.numMissionDetailLines = 0
end

function hideNotorietyBar()
	if not private.notorietyBarActive then
		return -- nothing to do
	end

	private.notorietyLadderFactionDetails   = nil
	private.notorietyLadderComponentDetails = nil
	private.previousRelationDetails         = nil

	goToSlide(private.anarkElements.targetMonitor.notorietyBlinking, "inactive")
	goToSlide(private.anarkElements.targetMonitor.notorietyBar, "inactive")

	private.notorietyBarActive = false
end

function hideSofttarget()
	private.softtargetID = 0
	private.softtargetTemplateConnectionName = nil
	removeStateRequest("softtarget", false)
	updateRadarTarget()
end

function hideTargetMonitorNotification()
	removeStateRequest("notification", false)
end

function initEnvironmentObjectSupport(contract)
	registerForEvent("changedEnvironmentObject", contract, onChangedEnvironmentObject)
	NotifyOnChangedEnvironmentObject(contract)

	-- set initial state of environmental info
	if private.environmentObjectSupport then
		local environmentTargetID = C.GetEnvironmentObject()
		if environmentTargetID ~= 0 then
			showEnvironmentInfo(environmentTargetID)
		end
	end
end

function initPointerPicking()
	-- target monitor
	local interacttexture = getElement("event_monitor_interact", private.anarkElements.targetMonitor.interactElement)
	registerForEvent("onMouseClick", interacttexture, onMouseClickTargetMonitor)
	RegisterMouseInteractions(interacttexture)
	SetPointerOverride(interacttexture, config.interactPointerID)

	-- message ticker
	local footer = getElement("footer", private.anarkElements.messageTicker.mainElement)
	registerForEvent("onMouseClick", footer, onMouseClickMessageTickerFooter)
	RegisterMouseInteractions(footer)
	SetPointerOverride(footer, config.interactPointerID)

	registerForEvent("onMouseClick", private.anarkElements.messageTicker.notificationElement, onMouseClickMessageTickerNotification)
	RegisterMouseInteractions(private.anarkElements.messageTicker.notificationElement)
	SetPointerOverride(private.anarkElements.messageTicker.notificationElement, config.interactPointerID)

	registerForEvent("onMouseClick", private.anarkElements.messageTicker.chatNotificationElement, onMouseClickMessageTickerChatNotification)
	RegisterMouseInteractions(private.anarkElements.messageTicker.chatNotificationElement)
	SetPointerOverride(private.anarkElements.messageTicker.chatNotificationElement, config.interactPointerID)

	registerForEvent("onMouseClick", private.anarkElements.messageTicker.row1Element, onMouseClickMessageTickerRow1)
	SetPointerOverride(private.anarkElements.messageTicker.row1Element, config.interactPointerID)
	-- note: we do not register for mouse interactions just yet for this element, since this is dependent on whether the row displays the inactive missions line

	initRadarPicking()
end

function initRadarPicking()
	-- radar
	registerForEvent("onGroupedMouseOver",      private.radarPickFrame, callbacks.onMouseOverRadar)
	registerForEvent("onGroupedMouseOut",       private.radarPickFrame, callbacks.onMouseOutRadar)
	registerForEvent("onMouseDown",             private.radarPickFrame, callbacks.onMouseDownRadar)
	registerForEvent("onMouseClick",            private.radarPickFrame, callbacks.onMouseClickRadar)
	registerForEvent("onMouseDblClick",         private.radarPickFrame, callbacks.onMouseDblClickRadar)
	registerForEvent("onRightMouseDown",        private.radarPickFrame, callbacks.onRightMouseDownRadar)
	registerForEvent("onRightMouseClick",       private.radarPickFrame, callbacks.onRightMouseClickRadar)
	registerForEvent("onRightMouseDblClick",    private.radarPickFrame, callbacks.onRightMouseDblClickRadar)
	registerForEvent("onMiddleMouseDown",       private.radarPickFrame, callbacks.onMiddleMouseDownRadar)
	registerForEvent("onMiddleMouseClick",      private.radarPickFrame, callbacks.onMiddleMouseClickRadar)
	registerForEvent("onMiddleMouseDblClick",   private.radarPickFrame, callbacks.onMiddleMouseDblClickRadar)
	registerForEvent("onSide1MouseDown",       private.radarPickFrame, callbacks.onSide1MouseDownRadar)
	registerForEvent("onSide1MouseClick",      private.radarPickFrame, callbacks.onSide1MouseClickRadar)
	registerForEvent("onSide1MouseDblClick",   private.radarPickFrame, callbacks.onSide1MouseDblClickRadar)
	registerForEvent("onSide2MouseDown",       private.radarPickFrame, callbacks.onSide2MouseDownRadar)
	registerForEvent("onSide2MouseClick",      private.radarPickFrame, callbacks.onSide2MouseClickRadar)
	registerForEvent("onSide2MouseDblClick",   private.radarPickFrame, callbacks.onSide2MouseDblClickRadar)

	-- note: we do not register for mouse interactions just yet for this element, since this is dependent on the actual radar mode

	updateRadarExtents()
end

function initNotifications()
	-- first abort any playing notification (which was for instance displayed in another target monitor)
	C.AbortCurrentNotification()

	-- clear any current notifications (might be outdated)
	private.targetMonitorNotifications = {}
	private.messageTickerNotifications = {}
	removeStateRequest("notification", false)

	-- and refill the notifications (one after another)
	-- #StefanLow review --- 52-bit-limit due to tonumber()-usage
	local numNotifications = tonumber(C.GetNumNotifications())
	for i = 1, numNotifications do
		showNotification(C.GetNotificationID(i))
	end
end

-- converts description.notorietyComponent to description.notorietyComponentDetails
-- and description.notorietyFaction to description.notorietyFactionDetails
function initNotorietyData(description)
	-- cache any notoriety component data here, so that we do not suffer issues, if the lifetime of the component ends, before we are updating the target monitor details
	-- this can happen, since we do not enforce any restriction on the component being passed on as the notoriety component --- therefore we
	-- a) are checking whether the component still exists
	-- b) cache the current data, if available
	-- c) add data for a fallback case ("unknown"), in case the component data can no longer be retrieved
	-- see XR-825 / XR-197 for cases we ran into this problem --- while these cases have been dealt with properly on the notification system side, we do not ensure proper handling
	-- for mods in the same way --- this fallback case is easier to implement and as safe as the proper approach from a usage point of view
	-- #coreUIMed - this is not 100% correct - if the notorietyComponent is a MT-object it doesn't ensure that the MT-object is persistent! This can lead to differring notoriety data
	-- being displayed if the previously used MT-component is detached and reused for a new temp-component

	-- convert notorietyFaction -> notorietyFactionDetails
	if description.notorietyFaction then
		-- note: The usage of GetFactionDetails() to dictate the faction bar's notoriety state is flawed - for a proper categorization we actually require
		--       the component for which to display the details for, which can differ f.e. for civilian vs. military ships for the enemy range (civilians: [-10,-25] vs. military: [-10,-20])
		--       However, not messing around with the use cases here, since it's a valid case to display the notoriety bar based on faction details only, if dictated to do so through the
		--       GetTargetMonitorDetailsBridge() interface.
		--       #P2Blocker - review if this should changed and the interface no longer provide specifying faction details w/o a valid component
		local factionDetails = C.GetFactionDetails(description.notorietyFaction)
		description.notorietyFactionDetails = {
			factionID   = description.notorietyFaction,
			factionName = ffi.string(factionDetails.factionName),
			factionIcon = ffi.string(factionDetails.factionIcon)
		}
		description.notorietyFaction = nil
	end

	-- retrieve basic component information
	local componentID    = description.notorietyComponent
	local validComponent = (componentID ~= nil and C.IsValidComponent(componentID))

	-- set the notorietyIcon, if it wasn't specified explicitly
	if not description.notorietyIcon then
		if componentID ~= nil then
			-- componentID faction icon takes precedence
			if validComponent then
				local ownerDetails = C.GetOwnerDetails(componentID)
				description.notorietyIcon = ffi.string(ownerDetails.factionIcon)
			else
				-- component is no longer valid - no way to determine faction id - fall-back to unknown faction icon
				description.notorietyIcon = "faction_ownerless"
			end
		elseif description.notorietyFactionDetails then
			-- otherwise use the faction info
			description.notorietyIcon = description.notorietyFactionDetails.factionIcon
		--else
			-- otheriwse nothing to do, notoriety frame is not being displayed
		end
	end

	if componentID == nil then
		return -- no notorietyComponent data at all -> nothing to do
	end

	description.notorietyComponentDetails = {}
	description.notorietyComponent        = nil

	if validComponent then
		-- component is valid -> populate the details structure
		local factionDetails = C.GetOwnerDetails(componentID)
		description.notorietyComponentDetails.componentID     = componentID
		-- #coreUIMed - this is utterly wrong here --- it's calling GetOwner() internally which is incorrect - it MUST call GetUIOwner() instead
		-- could not change at time of writing this due to a veto
		-- note that the difference between GetUIOwner() and GetOwner() is that GetUIOwner() returns the player faction regardless of the target's cover faction (if set to)
		-- this would be the correct behavior in this case too - in practice it won't be triggerred in a vanilla game, since that functionality is not used (it's accessible via Mods however)
		-- the net outcome is that in this case the target monitor would NOT display "player" for player owned stuff anymore, while the rest of the UI would display the object as player owned
		-- (including coloring the target element)
		description.notorietyComponentDetails.factionName     = ffi.string(C.GetFactionNameForTargetMonitorHack(componentID))
		description.notorietyComponentDetails.relationDetails = C.GetRelationStatus3(componentID, "")
	else
		-- failing to initialize component - component already destroyed --- init with fallback data
		description.notorietyComponentDetails.factionName     = L["Unknown Faction"]
		description.notorietyComponentDetails.relationDetails = {
			relationStatus   = 6,
			relationValue    = 0,
			relationLEDValue = 0,
			isBoostedValue   = false
		}
	end
end

function initScale(anchorElement, scale, useUIScale, childElement, direction, width, monitorextents, maxuiscale)
	local presentationUIScale = private.uiScale
	if maxuiscale then
		presentationUIScale = math.min(maxuiscale, presentationUIScale)
	end
	if not useUIScale then
		presentationUIScale = 1
	end

	-- apply the overall (normalizing) scale factor - compensates for world-space positioning and presentation setup scaling factor
	-- note: We interpret the scaling factor here the way that the overall presentation setup needs to be scaled so to fit into the worldspace correctly.
	--       Hence, because of that logic/definition we also scale the z-axis.
	local appliedscale = scale * presentationUIScale
	setAttribute(anchorElement, "scale.x", appliedscale)
	setAttribute(anchorElement, "scale.y", appliedscale)
	setAttribute(anchorElement, "scale.z", appliedscale)

	if childElement then
		local screenwidth, screenheight = getScreenInfo()
		local screenfactor = 1080 / screenheight * 0.907
		local factor = (1 - presentationUIScale) / (2 * screenfactor)
		if presentationUIScale > 1 then
			factor = factor-- / 3
		end
		local correction = (width * factor) / 2

		local mainelement = getElement(childElement, anchorElement)
		local y = getAttribute(mainelement, "position.y")

		local aspectratiocorrection = 0
		local aspectratio = screenwidth / screenheight
		if aspectratio < 1.5 then
			-- Below this aspectratio the monitors are going outside the screen, correct for that in a linear way until the aspect ratio becomes 4/3
			aspectratiocorrection = (1 - (aspectratio - (4 / 3)) * 6) * config.lowAspectRatioCorrection
			-- If the aspect ratio goes below 4/3 the visible rendered area of the game increases and we can use a constant correction
			if aspectratio < 4 / 3 then
				aspectratiocorrection = config.lowAspectRatioCorrection
			end
			-- Correct for UI scale offset
			aspectratiocorrection = aspectratiocorrection / (1 - factor)
		end

		local mainelementoffset = {
			x = direction * (correction - aspectratiocorrection / (1 - factor)),
			y = y - correction,
		}

		if monitorextents.id then
			private.monitorExtents[monitorextents.id] = {
				x = appliedscale * (mainelementoffset.x + monitorextents.x),
				y = appliedscale * (mainelementoffset.y + monitorextents.y),
				width = appliedscale * monitorextents.width,
				height = appliedscale * monitorextents.height,
			}
			C.SetMonitorExtents(monitorextents.id, private.monitorExtents[monitorextents.id].x, private.monitorExtents[monitorextents.id].y, private.monitorExtents[monitorextents.id].width, private.monitorExtents[monitorextents.id].height)
		end
		setAttribute(mainelement, "position.x", mainelementoffset.x)
		setAttribute(mainelement, "position.y", mainelementoffset.y)
	end
end

function initMissionBarScale()
	-- apply UI scale factor
	local defaultFontSize = getAttribute(private.anarkElements.missionBar.textElement1, "size")
	setAttribute(private.anarkElements.missionBar.textElement1, "size", scaleFont(defaultFontSize))
	defaultFontSize = getAttribute(private.anarkElements.missionBar.textElement2, "size")
	setAttribute(private.anarkElements.missionBar.textElement2, "size", scaleFont(defaultFontSize))
	local missionBarGraphicalMainElement = getElement("mission_bar_lines", private.anarkElements.missionBar.mainElement)
	local defaultScale = getAttribute(missionBarGraphicalMainElement, "scale.x")
	setAttribute(missionBarGraphicalMainElement, "scale.x", defaultScale * private.textUIScale)
	-- note: need to scale the z-axis rather than y since the geometries are rotated
	defaultScale = getAttribute(missionBarGraphicalMainElement, "scale.z")
	setAttribute(missionBarGraphicalMainElement, "scale.z", defaultScale * private.textUIScale)
end

function isBlinkingLED(LEDElementNumber, relationLEDValue, boostActive)
	if not boostActive then
		return false -- no boost active, no LED is blinking
	end

	if relationLEDValue == 0 then
		return false -- for a relation of 0, no LED is active
	end

	if relationLEDValue < 0 then
		-- hostile LED-case
		return LEDElementNumber == (4 - relationLEDValue)
	end

	-- friendly LED-case
	return LEDElementNumber == (5 - relationLEDValue)
end

function isHighestState(state)
	for _, value in ipairs(config.priorization) do
		if value == state then
			return true
		elseif private.stateRequests[value] then
			return false
		end
	end

	-- not in the list, so it's not the highest state
	DebugError("Target monitor error. State '"..tostring(state).."' is not registered as a prioritized state.")
	return false
end

function isSeparateRadarEnabled()
	return private.allowRadar and (not private.tickerOnlyMode) and private.radarEnabled and private.enableSeparateRadar
end

-- returns true, if the specified details are resulting in some target monitor display (false, otherwise)
function isSomethingToDisplay(details)
	-- #coreUIMed - quite hacky / redundant --- problematic since code relies on logic in updateTargetMonitorDisplay() (i.e. any updates here should be reflected with corresponding updates in updateTargetMonitorDisplay() and vice versa)
	return details.cutsceneDescriptor ~= nil or details.interactionID ~= nil or details.text ~= nil or details.header ~= nil or details.notorietyIcon ~= nil or details.notorietyFactionDetails ~= nil or details.notorietyComponentDetails ~= nil
end

-- the integrated target monitor radar is only enabled if:
-- 1. we are allowed to use the radar in its current mode (i.e. private.allowRadar = true)
-- 2. the game settings didn't disable the radar (i.e. private.radarEnabled = true)
-- 3. we are not using the separate radar
function isTargetMonitorRadarEnabled()
	return private.allowRadar and (not private.tickerOnlyMode) and private.radarEnabled and not private.enableSeparateRadar
end

function isValidTargetMonitorDetailsBridgeData(details)
	if details == nil then
		return false
	end

	-- #coreUIMed - add additional validation checks here (f.e. text-elements with holes or non-integer indexes, etc.)
	if details.text ~= nil and #details.text > config.maxTargetMonitorTextRows then
		return false
	end

	-- #coreUIMed - consider adding error output here instead of at the caller's side (so we can be more specific about what's wrong)
	return true
end

function processLiveUpdateValues()
	if private.targetMonitorStateLiveUpdateData then
		local targetmonitorstate = GetLiveDataBridge("targetmonitorstate", tostring(private.targetMonitorStateLiveUpdateData.referenceComponent), private.targetMonitorStateLiveUpdateData.referenceConnectionName)
		if targetmonitorstate == "$update$" or targetmonitorstate ~= private.targetMonitorStateLiveUpdateData.expectedTargetMonitorState then
			updateActiveState(true, true)
			return
		end
	end

	local text
	for _, entry in ipairs(private.liveUpdateValues) do
		if entry.left and entry.right then
			local righttext = { text = "", font = entry.right.font, fontsize = entry.right.fontsize }
			if entry.right.chunks then
				righttext.text = constructPlaceholderText(entry.right.chunks, entry.right.referenceComponent, entry.right.referenceConnectionName)
			else
				righttext.text = entry.right.text or ""
			end
			local lefttext = { text = "", font = entry.left.font, fontsize = entry.left.fontsize }
			if entry.left.chunks then
				lefttext.text = constructPlaceholderText(entry.left.chunks, entry.left.referenceComponent, entry.left.referenceConnectionName)
			else
				lefttext.text = entry.left.text or ""
			end

			truncateLeftRightText(lefttext, righttext, config.targetMonitorPresentationWidth)

			setAttribute(entry.right.element, "textstring", righttext.text)
			setAttribute(entry.left.element, "textstring", lefttext.text)
		else
			text = constructPlaceholderText(entry.chunks, entry.referenceComponent, entry.referenceConnectionName)
			text = TruncateText(text, entry.font, entry.fontsize, config.targetMonitorPresentationWidth)
			setAttribute(entry.element, "textstring", text)
		end
	end
end

function processOverlay(details, isNotification)
	-- clear any outdated liveUpdateValues
	private.targetMonitorStateLiveUpdateData = nil
	private.liveUpdateValues = {}

	local component = details.referenceComponent
	local connection = details.referenceConnectionName

	if not isNotification then
		-- prepare a live update for target monitor state, detecting if display has to be refreshed
		local targetmonitorstate = GetLiveDataBridge("targetmonitorstate", tostring(component), connection)
		if targetmonitorstate then
			private.targetMonitorStateLiveUpdateData = {
				["referenceComponent"]          = component,
				["referenceConnectionName"]     = connection,
				["expectedTargetMonitorState"]  = targetmonitorstate
			}
		end
	end

	-- header
	if details.header and details.header.fontsize then
		details.header.fontsize = scaleFont(details.header.fontsize)
	end
	local _, headerlivevalue = setTextElement("left", private.anarkElements.targetMonitor.headerText, details.header, component, connection, true)
	-- truncate header if it is not updated live
	if details.header and details.header.text and not headerlivevalue then
		local headertext = TruncateText(details.header.text, details.header.font or "", details.header.fontsize or 0, config.targetMonitorPresentationWidth)
		setAttribute(private.anarkElements.targetMonitor.headerText, "textstring", headertext)
	end

	-- process all text elements
	local numvalidrows = 0
	if details.textFromBottom and details.text then
		for i = 1, config.maxTargetMonitorTextRows do
			if (details.text[i] ~= nil) and (details.text[i].left or details.text[i].right) then
				numvalidrows = numvalidrows + 1
			end
		end
	end

	local hasnotorietybar = shouldDisplayNotorietyBar(details)
	for i = 1, config.maxTargetMonitorTextRows do
		-- need to update all texts to avoid left-over states, but calculate used text idx, based on details.textFromBottom and numvalidrows
		local textidx = i
		if details.textFromBottom then
			-- check whether row should contain something
			if i > config.maxTargetMonitorTextRows - (hasnotorietybar and 1 or 0) - numvalidrows then
				-- offset textidx to text that should be in this line
				textidx = i - (config.maxTargetMonitorTextRows - numvalidrows)
			else
				-- go to invalid row
				textidx = i + numvalidrows
			end
		end

		local rowallowed = (i ~= config.maxTargetMonitorTextRows) or (not hasnotorietybar)
		local lefttext = {
			element = private.anarkElements.targetMonitor.textOverlay.row[i].left,
			textdata = rowallowed and (details.text ~= nil) and (details.text[textidx] ~= nil) and details.text[textidx].left or nil,
		}
		if lefttext.textdata then
			lefttext.textdata.fontsize = scaleFont(lefttext.textdata.fontsize)
		end
		local righttext = {
			element = private.anarkElements.targetMonitor.textOverlay.row[i].right,
			textdata = rowallowed and (details.text ~= nil) and (details.text[textidx] ~= nil) and details.text[textidx].right or nil,
		}
		if righttext.textdata then
			righttext.textdata.fontsize = scaleFont(righttext.textdata.fontsize)
		end
		setTextLine(lefttext, righttext, component, connection, details.textOverlay)
		if details.textOverlay and ((lefttext.textdata ~= nil) or (righttext.textdata ~= nil)) then
			setColorHelper(private.anarkElements.targetMonitor.textOverlay.row[i].backgroundMaterial, nil, Color["targetmonitor_text_background_overlay"])
		else
			setColorHelper(private.anarkElements.targetMonitor.textOverlay.row[i].backgroundMaterial, nil, Color["targetmonitor_text_background_default"])
		end
	end
end

function queueNotification(notificationID, priority)
	local notificationTable         = private.messageTickerNotifications
	-- #coreUIMed - consider passing targetMonitorNotification as a parameter directly to reduce the need to call IsTargetMonitorNotification()
	local targetMonitorNotification = C.IsTargetMonitorNotification(notificationID)
	if targetMonitorNotification then
		notificationTable = private.targetMonitorNotifications
	end

	local notificationInfos = GetNotificationDetails(notificationID) or {}
	notificationTable[priority] = notificationTable[priority] or {}
	local curtime = private.pausedTime or getElapsedTime()
	table.insert(notificationTable[priority], {
		notificationID = notificationID,
		queueTime = curtime,
		fadeOutDelay = notificationInfos.duration or config.fadeOutDelay
	})

	if targetMonitorNotification then
		requestState("notification", false)
	end
end

function prepareLiveUpdateText(info, element, component, connection)
	local textChunks = getTextChunks(info.text)
	if type(textChunks) ~= "table" then
		return textChunks -- no placeholders, hence use the plain text (but parsed --- so that any $$ is unescaped)
	end

	local liveUpdateValue = {
		["element"]                 = element,
		["referenceComponent"]      = component,
		["referenceConnectionName"] = connection,
		["chunks"]                  = textChunks,
		["font"]                    = info.font,
		["fontsize"]                = info.fontsize,
	}

	return constructPlaceholderText(textChunks, component, connection), liveUpdateValue
end

function updateInteractiveText()
	if config.displayPressHint then
		local text = ""
		local keybinding = ffi.string(C.GetLocalizedInteractiveNotificationKey())
		if keybinding ~= "" then
			text = string.format(L["Press %s"], keybinding)
		end
		setAttribute(private.anarkElements.targetMonitor.interactiveText, "textstring", text)
	end
end

function processInteractionDescriptor(details, isNotification)
	if details.interactionID == nil then
		return -- no descriptor, nothing to do
	end

	local interactSlide = "active"
	if isNotification and not details.silent then
		updateInteractiveText()
	else
		interactSlide = "silent"
	end
	goToSlide(private.anarkElements.targetMonitor.interactElement, interactSlide)
	-- only activate executeNotification handling for gamepad/keyboard actions, if we show a notification (otherwise any interaction is just triggerable with a mouseclick)
	-- also the text is only passed along, if we are in non-silent mode
	local interactionText = details.interactionText
	if details.silent then
		interactionText = ""
	end
	TargetMonitorInteractionShown2(details.interactionID, interactionText, isNotification)
end

function processMessageTickerNotifications()
	-- first we remove any message which timed out
	local curtime = private.pausedTime or getElapsedTime()
	for i = config.numMessageTickerLines, 1, -1 do
		local message = private.messageTickerMessages[i]
		if message and message.startTime ~= nil then
			if message.startTime + message.fadeOutDelay + config.fadeOutTime <= curtime then
				-- message timed out - remove it
				table.remove(private.messageTickerMessages, i)
			end
		end
	end

	if (not private.tickerOnlyMode) or private.showTickerOnlyModePermanently then
		-- next, add any notification we still have enough space for
		local linesLeft = config.numMessageTickerLines - #private.messageTickerMessages
		local firstNonMissionDataLine = private.numMissionDetailLines + (private.coverLineActive and 1 or 0) + 1
		while next(private.messageTickerNotifications) do
			-- find the notification with the highest priority
			local priority       = table.maxn(private.messageTickerNotifications)
			local notificationID = private.messageTickerNotifications[priority][1].notificationID

			local notificationInfos = GetNotificationDetails(notificationID)
			if notificationInfos ~= nil then
				-- skip any notification where we fail to retrieve the data
				-- note: this can be valid (f.e. if the notifcation got removed before we managed to display it)
				local text     = notificationInfos.text
				local numLines = #text
				if numLines > linesLeft then
					break -- requires more lines than we have available atm
				end

				-- we have enough lines -> add to message ticker
				for i = 1, numLines do
					text[i].left.fontsize = scaleFont(text[i].left.fontsize)
					text[i].right.fontsize = scaleFont(text[i].right.fontsize)
					local _, _, numtextlines = setMultilineLeftRightText(text[i].left, text[i].right, config.messageTickerPresentationWidth - 2 * config.messageTickerTextOffsetX, "   ")

					local entry = {
						left             = text[i].left,
						right            = text[i].right,
						numtextlines     = numtextlines,
						blinking         = notificationInfos.blinking, -- store the blinking state in each line to simplify processing
						fadeOutDelay     = notificationInfos.duration or config.fadeOutDelay,
						permanent        = false,                      -- normal messages are not permanent
						firstMessageLine = (i == 1),
					}
					-- insert lines right above the mission data line(s) (if any are displayed)
					table.insert(private.messageTickerMessages, firstNonMissionDataLine, entry)
				end

				-- play any associated sound effect
				if notificationInfos.sound then
					PlaySound(notificationInfos.sound)
				end

				-- update lines left and remove notification from the list
				linesLeft = linesLeft - numLines
			end
			-- #coreUIMed - move to separate function
			ReleaseNotification(notificationID)
			table.remove(private.messageTickerNotifications[priority], 1)
			if #private.messageTickerNotifications[priority] == 0 then
				-- remove entire priority-table, if last notification for the priority was removed
				private.messageTickerNotifications[priority] = nil
			end
		end
	end

	-- check queued messages for time out
	-- if we are in ticker mode, we want to cleanup older messages, to avoid hundreds of messages after closing the menu
	-- but keep some of the highest priority and newest messages
	if private.tickerOnlyMode and (not private.showTickerOnlyModePermanently) then
		local priorityqueuelimit = 10
		local numPriorityMessagesInQueue = 0
		-- iterate over the priorities from highest to lowest
		for priority = 9, 1, -1 do
			if private.messageTickerNotifications[priority] then
				if priority > 1 then
					-- check whether priority queue limit is reached, if so check messages for removal
					-- this will also trigger removal attempts in all lower priorities
					local nummessages = #private.messageTickerNotifications[priority]
					numPriorityMessagesInQueue = numPriorityMessagesInQueue + nummessages
					if numPriorityMessagesInQueue > priorityqueuelimit then
						local nummessagestoremove = math.min(nummessages, numPriorityMessagesInQueue - priorityqueuelimit)
						for i = nummessagestoremove, 1, -1 do
							local notificationEntry = private.messageTickerNotifications[priority][i]
							if notificationEntry.queueTime + notificationEntry.fadeOutDelay + config.fadeOutTime <= curtime then
								table.remove(private.messageTickerNotifications[priority], i)
								numPriorityMessagesInQueue = numPriorityMessagesInQueue - 1
							end
						end
					end
				else
					-- check still queued normal priority messages for removal if they get too old
					local nummessages = #private.messageTickerNotifications[priority]
					for i = nummessages, 1, -1 do
						local notificationEntry = private.messageTickerNotifications[priority][i]
						if notificationEntry.queueTime + notificationEntry.fadeOutDelay + config.fadeOutTime <= curtime then
							table.remove(private.messageTickerNotifications[priority], i)
						end
					end
				end
				if #private.messageTickerNotifications[priority] == 0 then
					-- remove entire priority-table, if last notification for the priority was removed
					private.messageTickerNotifications[priority] = nil
				end
			end
		end
	end
end

function updateMessageStartTimes(curtime, pausedtime)
	for i = config.numMessageTickerLines, 1, -1 do
		local message = private.messageTickerMessages[i]
		if message and (message.startTime ~= nil) then
			message.startTime = math.min(curtime, message.startTime + curtime - pausedtime)
		end
	end
end

function removeOldestMessage()
	-- to remove an old message, we must remove the upper most line and all following lines, until we reach the line marked with "firstMessageLine" which indicates the start of the next message
	table.remove(private.messageTickerMessages)
	while ((#private.messageTickerMessages > 0) and (not private.messageTickerMessages[#private.messageTickerMessages].firstMessageLine)) do
		table.remove(private.messageTickerMessages)
	end
end

function removeStateRequest(state, force)
	private.stateRequests[state] = false
	updateActiveState(force)
end

function requestState(state, force)
	private.stateRequests[state] = true
	updateActiveState(force)
end

function setCheckedText(element, text)
	-- only update the faction text, if it really changed
	-- (note: Anark does not filter setAttribute() calls which do not change the string value, since doing so would have
	-- and unnecessary performance impact due to the required string comparison on each setAttribute-call)

	if getAttribute(element, "textstring") ~= text then
		setAttribute(element, "textstring", text)
	end
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

function setTextElement(halign, element, info, component, connection, setliveupdate, isoverlay)
	local text, liveupdatevalue = ""

	-- #coreUIMed - strengthen this code against missing data (i.e. font, fontsize, color might be missing)
	if info and info.text and info.text ~= "" then
		-- only set text-related values, when text is given
		setAttribute(element, "font", info.font)
		setAttribute(element, "size", info.fontsize)
		setAttribute(element, "position.x", ((halign == "left") and -1 or 1) * ((config.targetMonitorPresentationWidth / 2) - (isoverlay and config.targetTickerOverlayTextOffsetX or config.targetTickerTextOffsetX)))
		setAttribute(element, "textcolor.r", info.color.r)
		setAttribute(element, "textcolor.g", info.color.g)
		setAttribute(element, "textcolor.b", info.color.b)
		setAttribute(element, "glowfactor", info.color.glow or config.glowfactors.text)

		text, liveupdatevalue = prepareLiveUpdateText(info, element, component, connection)
		if setliveupdate then
			table.insert(private.liveUpdateValues, liveupdatevalue)
		end
	end

	setCheckedText(element, text)
	return text, liveupdatevalue
end

function setTextLine(lefttext, righttext, component, connection, isoverlay)
	local lefttextvalue, leftlivevalue = setTextElement("left", lefttext.element, lefttext.textdata, component, connection, nil, isoverlay)
	local righttextvalue, rightlivevalue = setTextElement("right", righttext.element, righttext.textdata, component, connection, nil, isoverlay)

	local islive = leftlivevalue or rightlivevalue
	local leftvalue = leftlivevalue or { element = lefttext.element, text = lefttextvalue, font = lefttext.textdata and lefttext.textdata.font or "", fontsize = lefttext.textdata and lefttext.textdata.fontsize or 0 }
	local rightvalue = rightlivevalue or { element = righttext.element, text = righttextvalue, font = righttext.textdata and righttext.textdata.font or "", fontsize = righttext.textdata and righttext.textdata.fontsize or 0 }

	if islive then
		table.insert(private.liveUpdateValues, { left = leftvalue, right = rightvalue })
	else
		truncateLeftRightText(leftvalue, rightvalue, config.targetMonitorPresentationWidth - 2 * (isoverlay and config.targetTickerOverlayTextOffsetX or config.targetTickerTextOffsetX))
		setCheckedText(leftvalue.element, leftvalue.text)
		setCheckedText(rightvalue.element, rightvalue.text)
	end
end

function shouldDisplayNotorietyBar(details)
	return details.notorietyFactionDetails ~= nil or details.notorietyComponentDetails ~= nil or details.notorietyIcon ~= nil
end

function showEnvironmentInfo(targetid)
	private.environmentTargetID = targetid
	requestState("environmentinfo", false)
end

function showNotification(notificationID)
	local priority = GetNotificationPriority(notificationID)
	if priority == nil then
		return -- ignore - can be nil, if notification was removed already
	end

	queueNotification(notificationID, priority)
end

-- #coreUIMed - cleanup a bit --- mixing show/hide with activate/deactivate with process... not good
function showNotorietyBar(details)
	if not private.notorietyBarActive then
		goToSlide(private.anarkElements.targetMonitor.notorietyBar, "active")
		private.notorietyBarActive = true
	end

	-- icon display
	if details.notorietyIcon then
		-- initially do not use a color --- color is updated in updateNotorietyLadder() each frame (if required)
		SetIcon(private.anarkElements.targetMonitor.factionLadder.iconTexture, details.notorietyIcon, nil, nil, nil, false, config.notorietyIconSize * private.textUIScale, config.notorietyIconSize * private.textUIScale)
	end

	-- notoriety ladder
	private.notorietyLadderFactionDetails   = details.notorietyFactionDetails
	private.notorietyLadderComponentDetails = details.notorietyComponentDetails
	-- #coreUILow - reconsider handling relationStatus here - could directly use relationDetails struct?
	local relationStatus
	-- note: order is important - component info takes precedence!
	if details.notorietyComponentDetails then
		relationStatus = details.notorietyComponentDetails.relationDetails.relationStatus
	elseif details.notorietyFactionDetails then
		-- #coreUIMed - this is a redundant call to C.GetFactionRelationStatus2() here and then in updateNotorietyLadder()...
		local relationDetails = C.GetFactionRelationStatus2(details.notorietyFactionDetails.factionID)
		relationStatus = relationDetails.relationStatus
	end

	if relationStatus ~= nil then
		if details.notorietyEffect then
			goToSlide(private.anarkElements.targetMonitor.notorietyBlinking, "active")
		else
			goToSlide(private.anarkElements.targetMonitor.notorietyBlinking, "inactive")
		end

		-- for the player's faction or for unknown factions we do not show the notoriety ladder
		local activateLadder = (relationStatus < 5)

		if activateLadder then
			activateFactionLadder()
		else
			deactivateFactionLadder()
		end

		updateNotorietyLadder(details.notorietyFactionDetails, details.notorietyComponentDetails)
	else
		deactivateFactionLadder()
		-- #StefanMed - should this be done inside deactivateFactionLadder()?
		goToSlide(private.anarkElements.targetMonitor.notorietyBlinking, "inactive")
	end
end

function toggleRadarMode()
	if isTargetMonitorRadarEnabled() or isSeparateRadarEnabled() then
		private.radarMapMode = private.radarMapMode + 1
		if private.radarMapMode >= C.GetNumRadarModes() then
			private.radarMapMode = 0
		end

		if private.enableSeparateRadar then
			-- #coreUIMed - review this --- maybe better add a force parameter to checkRadarActivation() which enforces a reset of the map render target
			--              to switch it into the new map mode? (same for the target monitor radar case below)
			deactivateSeparateRadar()
			checkRadarActivation()
		else
			deactivateTargetMonitorRadar()
			updateActiveState(true)
		end
	end
end

function showSofttarget(softtargetid, softtargetconnectionname)
	private.softtargetID                     = softtargetid
	private.softtargetTemplateConnectionName = softtargetconnectionname
	requestState("softtarget", isHighestState("softtarget"))
	updateRadarTarget()
end

function switchTargetMonitorNotification()
	-- find the notification with the highest priority
	local priority                = table.maxn(private.targetMonitorNotifications)
	local notificationID          = private.targetMonitorNotifications[priority][1].notificationID
	local notificationInfos       = GetNotificationDetails(notificationID)

	-- if for any reason the notification could not be processed, skip the request
	if notificationInfos then
		private.currentNotificationID = notificationID
		local defaultDuration = config.notificationDelay
		if notificationInfos.cutsceneDescriptor then
			defaultDuration = nil -- by default, cutscene notifications are infinite
		end
		local duration = notificationInfos.duration or defaultDuration
		notificationInfos.duration = duration

		-- patch the retrieved details to comply to our internal structure
		-- #coreUIMed review this - not too good architecture wise IMO
		notificationInfos.requiresKnownCheck = false

		updateTargetMonitorDisplay(notificationInfos, isTargetMonitorRadarEnabled(), true)
		if notificationInfos.sound then
			PlaySound(notificationInfos.sound)
		end

		C.NotifyDisplayNotification(notificationID)
	else
		private.currentNotificationID = nil
	end

	-- remove the current one from the list -- we remove the "notification" immediately, even if the player was not able to see it
	-- #coreUIMed rediscuss whether this really is what the UI designer wants (wasn't decided yet)
	table.remove(private.targetMonitorNotifications[priority], 1)
	if #private.targetMonitorNotifications[priority] == 0 then
		-- remove entire priority-table, if last notification for the priority was removed
		private.targetMonitorNotifications[priority] = nil
	end
end

function setTextWithLineBreaks(lines, maxlines, width, font, fontsize, indentation)
	local text = ""
	for i, line in ipairs(lines) do
		local linebreak = (i > 1) and "\n" or ""
		if indentation and (i > 1) then
			linebreak = linebreak .. indentation
		end
		if maxlines and (i == maxlines) and (#lines > maxlines) then
			local indentationWidth = indentation and math.ceil(C.GetTextWidth(indentation, font, fontsize)) or 0
			if math.ceil(C.GetTextWidth(line .. "...", font, fontsize)) > (width - indentationWidth) then
				text = text .. linebreak .. utf8.sub(line, 1, -3) .. "..."
			else
				text = text .. linebreak .. line .. "..."
			end
			break
		else
			text = text .. linebreak .. line
		end
	end
	return text
end

function setMultilineLeftRightText(lefttext, righttext, width, indentation)
	local numlines = 1

	local indentationWidth = indentation and math.ceil(C.GetTextWidth(indentation, lefttext.font, lefttext.fontsize)) or 0
	if righttext.text ~= "" then
		local spaceWidth = math.ceil(C.GetTextWidth(" ", righttext.font, righttext.fontsize))
		local rightWidth = math.ceil(C.GetTextWidth(righttext.text, righttext.font, righttext.fontsize))
		local leftWidth = math.ceil(C.GetTextWidth(lefttext.text, lefttext.font, lefttext.fontsize))
		if leftWidth + rightWidth + spaceWidth > width then
			if leftWidth > 0.5 * width and rightWidth > 0.5 * width then
				leftWidth = 0.5 * width - indentationWidth
				rightWidth = 0.5 * width - spaceWidth
			elseif leftWidth > 0.5 * width then
				leftWidth = width - rightWidth - spaceWidth - indentationWidth
			elseif rightWidth > 0.5 * width then
				rightWidth = width - leftWidth - spaceWidth
			end
		end
		local leftlines = GetTextLines(lefttext.text, lefttext.font, lefttext.fontsize, leftWidth)
		lefttext.text = setTextWithLineBreaks(leftlines, config.messageTickerMultiLine.maxLines, leftWidth + indentationWidth, lefttext.font, lefttext.fontsize, indentation)
		local rightlines = GetTextLines(righttext.text, righttext.font, righttext.fontsize, rightWidth)
		righttext.text = setTextWithLineBreaks(rightlines, config.messageTickerMultiLine.maxLines, rightWidth, righttext.font, righttext.fontsize)
		numlines = math.max(#leftlines, #rightlines)
	else
		local leftWidth = math.ceil(C.GetTextWidth(lefttext.text, lefttext.font, lefttext.fontsize))
		local leftlines = GetTextLines(lefttext.text, lefttext.font, lefttext.fontsize, width - indentationWidth)
		lefttext.text = setTextWithLineBreaks(leftlines, config.messageTickerMultiLine.maxLines, width, lefttext.font, lefttext.fontsize, indentation)
		numlines = #leftlines
	end
	return lefttext.text, righttext.text, math.min(numlines, config.messageTickerMultiLine.maxLines)
end

function truncateLeftRightText(lefttext, righttext, width)
	-- ignore empty strings (font/fontsize may not be valid)
	local rightWidth = 0
	if righttext.text ~= "" then
		-- righttext may always take at least 80% of the width (if lefttext needs more than 20%, it will get truncated accordingly)
		-- add width of a space character to rightWidth and leftWidth to ensure enough separation between left and right text
		rightWidth = math.ceil(C.GetTextWidth(" " .. righttext.text, righttext.font, righttext.fontsize))
		if rightWidth > 0.8 * width then
			local leftWidth = lefttext.text ~= "" and math.ceil(C.GetTextWidth(" " .. lefttext.text, lefttext.font, lefttext.fontsize)) or 0
			righttext.text = TruncateText(righttext.text, righttext.font, righttext.fontsize, width - math.min(leftWidth, 0.2 * width))
			rightWidth = math.ceil(C.GetTextWidth(" " .. righttext.text, righttext.font, righttext.fontsize))
		end
	end
	if lefttext.text ~= "" then
		lefttext.text = TruncateText(lefttext.text, lefttext.font, lefttext.fontsize, width - rightWidth)
	end
	return lefttext.text, righttext.text
end

function updateActiveState(force, refresh, allowPlaySound, keepCutscene)
	local newState = "inactive" -- if no one wants to show anything, deactivate the target monitor
	for _, state in ipairs(config.priorization) do
		if private.stateRequests[state] then
			newState = state
			break
		end
	end

	changeState(newState, force, allowPlaySound ~= false, refresh, keepCutscene)
end

function updateActivityColor()
	if private.activityColor then
		local intensity = C.GetModeLightIntensity()

		if intensity ~= private.modeLightIntensity then
			private.modeLightIntensity = intensity
			setDecoColorsWithIntensity(intensity)
		end
	end
end

function updateMailNotification()
	local mailcount = C.GetNumUnreadMails()
	local totalcount = mailcount.numImportantMails + mailcount.numNormalMails
	if totalcount > 100 then
		-- cap at 100, as we display only 99+ for >= 100 unread mails
		totalcount = 100
	end

	-- update text display
	if totalcount ~= private.numCurrentMails then
		private.numCurrentMails = totalcount
		local text = tostring(tonumber(totalcount))
		if totalcount == 100 then
			text = "99+"
		end
		-- #coreUILow - move to private element
		setAttribute(getElement("count", private.anarkElements.messageTicker.notificationElement), "textstring", text)
	end

	-- update the mail icon
	local hasImportantMails = (mailcount.numImportantMails > 0)
	if hasImportantMails ~= private.hasImportantMails then
		-- #coreUILow - move to config
		local icon = "mt_message_unread_low"
		local color = Color["messageticker_mail_icon"]
		if hasImporantMails then
			icon = "mt_message_unread_high"
			color = Color["messageticker_mail_icon_highlight"]
		end
		-- #coreUILow - move to private element
		SetIcon(getElement("mail_icon.mail_icon.mt_message_unread_high", private.anarkElements.messageTicker.notificationElement), icon, color.r, color.g, color.b, false, 35, 35)
		setAttribute(getElement("mail_icon.mail_icon", private.anarkElements.messageTicker.notificationElement), "glowfactor", color.glow)
		private.hasImportantMails = hasImporantMails
	end

	-- we just updated the mail notification indicator, reset the value
	private.needMailNotificationUpdate = false
end

function updateChatNotification()
	local unreadchatcount = OnlineGetNumUnreadChatMessages()
	if unreadchatcount > 100 then
		-- cap at 100, as we display only 99+ for >= 100 unread mails
		unreadchatcount = 100
	end

	-- update text display
	if unreadchatcount ~= private.numCurrentChats then
		private.numCurrentChats = unreadchatcount
		local text = tostring(tonumber(unreadchatcount))
		local icon = "mt_chat_unread_high"
		if unreadchatcount == 100 then
			text = "99+"
		elseif unreadchatcount == 0 then
			icon = "mt_chat_unread_low"
			text = ""
		end
		local color = Color["messageticker_mail_icon"]
		local material = getElement("mail_icon.mail_icon", private.anarkElements.messageTicker.chatNotificationElement)
		SetIcon(getElement("mt_chat_unread_high", material), icon, color.r, color.g, color.b, false, 35, 35)
		setAttribute(material, "glowfactor", color.glow)
		-- #coreUILow - move to private element
		setAttribute(getElement("count", private.anarkElements.messageTicker.chatNotificationElement), "textstring", text)
	end

	-- we just updated the mail notification indicator, reset the value
	private.needChatNotificationUpdate = false
end

function updateMessages()
	local curTime = getElapsedTime()
	private.curNumMessageLines = 0
	for i = 1, config.numMessageTickerLines do
		local message = private.messageTickerMessages[i]
		local line    = private.messageLines[i]
		if private.messageTickerActive and (message ~= nil) then
			-- we have an entry for this line
			if message.barValue ~= nil then
				-- we need to display a bar

				activateMessageTickerBar(line, message.blinking)

				private.curNumMessageLines = private.curNumMessageLines + 1
				setAttribute(line.barRowElement, "position.y", config.messageTickerMultiLine.elementOffsetY + private.curNumMessageLines * scaleFont(config.messageTickerMultiLine.lineHeight))

				if message.barValue ~= line.barValue then
					goToTime(line.barRowProgressElement1, message.barValue)
					goToTime(line.barRowProgressElement2, message.barValue)
					line.barValue = message.barValue
				end

				-- note: in principle we should add support for the fading out effect for this line too, but since this is not utilized atm (and not specified in the UI design) didn't add it atm
			else
				-- we should display a text line

				activateMessageTickerText(line)

				-- set the animation (i.e. fade out) time
				local time = 0
				if message.blinking then
					if message.startBlinkTime == nil then
						-- set the startBlinkTime, if it's a new message
						message.startBlinkTime = curTime
					end
					time = math.min(curTime - message.startBlinkTime, config.blinkAnimTime)
					if time == config.blinkAnimTime then
						-- end of blink animation reached
						time = 0
					else
						time = time + config.blinkAnimTimeOffset
					end
				end
				if not message.permanent then
					if message.startTime == nil then
						-- set the startTime, if it's a new message
						message.startTime = curTime
					elseif time == 0 then -- do not override blink time, if we use that one
						time = math.min(math.max(0, (private.pausedTime or curTime) - message.startTime - message.fadeOutDelay), config.fadeOutTime)
					end
				end
				if line.time ~= time then
					goToTime(line.textRowElement, time)
					line.time = time
				end

				local textcolorleft = copyColor(message.left.color)
				local textcolorright = copyColor(message.right.color)
				local backgroundcolor = Color["messageticker_text_background_default"]
				if message.invert then
					backgroundcolor = copyColor(message.left.color)
					backgroundcolor.glow = 0 -- glow on background is too much
					textcolorleft = Color["targetmonitor_deco_background"]
					textcolorright = Color["targetmonitor_deco_background"]
				end
				setColorHelper(getElement("Material3188", line.textBackgroundElement), nil, backgroundcolor)

				-- set the left text element
				-- #coreUIMed - consider using setTextElement() and then also add placeholder text support (if adding, update documentation in notification class accordingly)
				local numlines = message.numtextlines or 1
				private.curNumMessageLines = private.curNumMessageLines + numlines
				local lineheight = math.ceil(config.messageTickerMultiLine.lineHeight * private.textUIScale)
				setAttribute(line.textRowElement, "position.y", config.messageTickerMultiLine.elementOffsetY + private.curNumMessageLines * lineheight)
				local backgroundscale = math.ceil(config.messageTickerMultiLine.backgroundScale * private.textUIScale * 100) / 100
				setAttribute(line.textBackgroundElement, "scale.y", config.messageTickerMultiLine.backgroundScaleOffset + backgroundscale * numlines)
				setAttribute(line.textBackgroundElement, "position.y", math.floor(config.messageTickerMultiLine.backgroundOffsetY * private.textUIScale) --[[ (lineheight - config.messageTickerMultiLine.lineHeight) / 2]] - (numlines - 1) * lineheight / 2)
				local mousepickscale = math.ceil(config.messageTickerMultiLine.mousepickScale * private.textUIScale * 100) / 100
				setAttribute(line.textMousepickElement, "scale.y", config.messageTickerMultiLine.mousepickScaleOffset + mousepickscale * numlines)
				setAttribute(line.textMousepickElement, "position.y", config.messageTickerMultiLine.mousepickOffsetY - (numlines - 1) * lineheight / 2)

				setAttribute(line.left, "textstring", message.left.text)
				setAttribute(line.left, "font", message.left.font)
				setAttribute(line.left, "size", message.left.fontsize)
				setAttribute(line.left, "textcolor.r", textcolorleft.r)
				setAttribute(line.left, "textcolor.g", textcolorleft.g)
				setAttribute(line.left, "textcolor.b", textcolorleft.b)
				setAttribute(line.left, "glowfactor", textcolorleft.glow or config.glowfactors.text)
				setAttribute(line.left, "position.x", (-config.messageTickerPresentationWidth / 2) + (message.invert and config.messageTickerInvertedTextOffsetX or config.messageTickerTextOffsetX))
				setAttribute(line.left2, "textstring", message.left.text)
				setAttribute(line.left2, "font", message.left.font)
				setAttribute(line.left2, "size", message.left.fontsize)
				setAttribute(line.left2, "position.x", (-config.messageTickerPresentationWidth / 2) + (message.invert and config.messageTickerInvertedTextOffsetX or config.messageTickerTextOffsetX))
				if message.blinking then
					-- only set the blinkColor in blinking mode since we ensure not requiring the blinkColor being set, if blinking is false
					setAttribute(line.left2, "textcolor.r", message.left.blinkColor.r)
					setAttribute(line.left2, "textcolor.g", message.left.blinkColor.g)
					setAttribute(line.left2, "textcolor.b", message.left.blinkColor.b)
					setAttribute(line.left2, "glowfactor", message.left.blinkColor.glow or config.glowfactors.text)
				end

				-- set the right text element
				setAttribute(line.right, "textstring", message.right.text)
				setAttribute(line.right, "font", message.right.font)
				setAttribute(line.right, "size", message.right.fontsize)
				setAttribute(line.right, "textcolor.r", textcolorright.r)
				setAttribute(line.right, "textcolor.g", textcolorright.g)
				setAttribute(line.right, "textcolor.b", textcolorright.b)
				setAttribute(line.right, "glowfactor", textcolorright.glow or config.glowfactors.text)
				setAttribute(line.right, "position.x", (config.messageTickerPresentationWidth / 2) - (message.invert and config.messageTickerInvertedTextOffsetX or config.messageTickerTextOffsetX))
				setAttribute(line.right2, "textstring", message.right.text)
				setAttribute(line.right2, "font", message.right.font)
				setAttribute(line.right2, "size", message.right.fontsize)
				setAttribute(line.right2, "position.x", (config.messageTickerPresentationWidth / 2) - (message.invert and config.messageTickerInvertedTextOffsetX or config.messageTickerTextOffsetX))
				if message.blinking then
					-- only set the blinkColor in blinking mode since we ensure not requiring the blinkColor being set, if blinking is false
					setAttribute(line.right2, "textcolor.r", message.right.blinkColor.r)
					setAttribute(line.right2, "textcolor.g", message.right.blinkColor.g)
					setAttribute(line.right2, "textcolor.b", message.right.blinkColor.b)
					setAttribute(line.right2, "glowfactor", message.right.blinkColor.glow or config.glowfactors.text)
				end
			end
		else
			-- make sure the line is inactive
			deactivateMessageTickerLine(line)
		end
	end
end

function updateMessageTicker()
	if private.missionDetailsCallbackMode or private.needMissionDetailsUpdate or private.needMissionObjectiveBarUpdate then
		-- by definition the mission update always blinks upon having retrieved a missionInfoUpdate-event but not if in callback mode
		updateMissionDetails(private.needMissionDetailsUpdate)
	end
	updateCoverLine()
	processMessageTickerNotifications()

	local lineheight = math.ceil(config.messageTickerMultiLine.lineHeight * private.textUIScale)
	setAttribute(private.tickerBackgroundElement, "scale.y", (math.ceil(config.messageTickerBaseHeight * private.textUIScale) + lineheight * private.curNumMessageLines) / 100)

	-- update monitor extents
	local extents = private.monitorExtents["messageticker"]
	if not extents.showingRadar then
		C.SetMonitorExtents("messageticker", extents.x, extents.y + (extents.height * #private.messageTickerMessages) / 2, extents.width, extents.height * (1 + #private.messageTickerMessages))
	end

	if private.needMailNotificationUpdate then
		-- #coreUILow - implementation could be further improved - rather than reevaluating the entire mail notification states, we could just update the changed state
		--              specifically (aka: either only update the number of unread mails directly per mailRead-event or increase the number directly per incomingMail-event)
		updateMailNotification()
	end
	if private.needChatNotificationUpdate then
		-- #coreUILow - implementation could be further improved - rather than reevaluating the entire chat notification states, we could just update the changed state
		--              specifically (aka: either only update the number of unread chats directly per chatRead-event or increase the number directly per incomingChat-event)
		updateChatNotification()
	end
	-- must be called after processing notifications and mission details since this relies on whether any data was scheduled to be displayed
	-- #coreUIMed - make this explicit (pass by parameter)?
	checkMessageTickerActivation()
	updateMessages()
end

function updateMissionDetails(blinking)
	-- check and output the current mission info first
	local missionInfo = C.GetMissionInfo3()

	if private.needMissionObjectiveBarUpdate and missionInfo.active then
		displayMissionBar(ffi.string(missionInfo.missionBarText))
		private.needMissionObjectiveBarUpdate = false
	end

	if not blinking and not private.missionDetailsCallbackMode then
		-- #coreUILow - hackish - maybe better use an explicit argument to indicate if the entire ticker or only the mission bar needs to be updated?
		return -- done, we only needed to update the missionbar
	end

	private.missionDetailsCallbackMode = missionInfo.callbackMode
	if missionInfo.active then
		displayMissionDetails(missionInfo, blinking)
	else -- no active mission atm
		hideMissionDetails()

		-- if we don't have any active mission atm, we display the number of "inactive" missions instead (with standard blue color though)
		-- only in case there are no inactive missions at all, the mission detail lines are completely hidden
		local numInactiveMissions = C.GetNumAcceptedMissions()
		if numInactiveMissions > 0 then
			displayInactiveMissionLine(numInactiveMissions)
		end
	end

	-- remove the oldest message(s) (i.e. top row(s)) in case we added more than the maximum number of rows
	while #private.messageTickerMessages > config.numMessageTickerLines do
		removeOldestMessage()
	end

	-- we just updated the mission details, reset the value
	private.needMissionDetailsUpdate = false
end

function updateCoverLine()
	local coverfaction = ffi.string(C.GetPlayerCoverFaction())
	if coverfaction ~= "" then
		local factionDetails = C.GetFactionDetails(coverfaction)
		local entry = {
			left = {
				text     = L["Cover active as:"],
				font     = config.missionDataFont,
				fontsize = scaleFont(config.missionDataFontSize),
				color    = config.messageTickeCoverTextColor
			},
			right = {
				text     = ffi.string(factionDetails.factionName),
				font     = config.missionDataFont,
				fontsize = scaleFont(config.missionDataFontSize),
				color    = config.messageTickeCoverTextColor
			},
			blinking = false,
			permanent = true,  -- cover details are displayed permanently (i.e. no timeout)
		}

		if private.coverLineActive then
			-- inactive mission line already displayed - simply replace the entry
			private.messageTickerMessages[private.numMissionDetailLines + 1] = entry
		else
			-- simply insert the line after the mission (superfluous rows will be handled by the caller)
			table.insert(private.messageTickerMessages, private.numMissionDetailLines + 1, entry)
		end

		private.coverLineActive = true
	else
		if private.coverLineActive then
			table.remove(private.messageTickerMessages, private.numMissionDetailLines + 1)
		end
		private.coverLineActive = false
	end
end

function updateNotorietyLadder(notorietyFactionDetails, notorietyComponentDetails)
	local relationDetails
	local factionName, oldFactionName
	if notorietyComponentDetails ~= nil then
		updateRelationStatusData(notorietyComponentDetails)
		relationDetails = notorietyComponentDetails.relationDetails

		oldFactionName = notorietyComponentDetails.factionName
		local curFactionName = ffi.string(C.GetFactionNameForTargetMonitorHack(notorietyComponentDetails.componentID))
		if curFactionName ~= oldFactionName then
			notorietyComponentDetails.factionName = curFactionName
		end
		factionName = notorietyComponentDetails.factionName
	else -- use factionID
		factionName = notorietyFactionDetails.factionName
		relationDetails = C.GetFactionRelationStatus2(notorietyFactionDetails.factionID)
	end

	local factionLadderElements = private.anarkElements.targetMonitor.factionLadder

	-- determine the relation color
	local relationColor = config.relationColor[relationDetails.relationStatus]

	-- update relation text and color
	if private.previousRelationDetails == nil or (private.previousRelationDetails.relationStatus ~= relationDetails.relationStatus) or (factionName ~= oldFactionName) then
		local relationText = "" -- empty for unknown/invalid cases -- in case of relationStatus == 5 we do display Unknown Faction without an additional faction text
		if relationDetails.relationStatus == 0 then
			relationText = L["Hostile"]
		elseif relationDetails.relationStatus == 1 then
			relationText = L["Enemy"]
		elseif relationDetails.relationStatus == 2 then
			relationText = L["Neutral"]
		elseif relationDetails.relationStatus == 3 then
			relationText = L["Friendly"]
		elseif relationDetails.relationStatus == 4 then
			relationText = L["Allied"]
		elseif relationDetails.relationStatus == 5 then
			relationText = L["Owned"]
		end
		setCheckedText(factionLadderElements.relationText, relationText)

		-- update the color (icon, factionname, and relation text)
		setAttribute(factionLadderElements.relationText, "textcolor.r", relationColor.r)
		setAttribute(factionLadderElements.relationText, "textcolor.g", relationColor.g)
		setAttribute(factionLadderElements.relationText, "textcolor.b", relationColor.b)
		setAttribute(factionLadderElements.relationText, "glowfactor", relationColor.glow)
		setAttribute(factionLadderElements.factionText, "textcolor.r", relationColor.r)
		setAttribute(factionLadderElements.factionText, "textcolor.g", relationColor.g)
		setAttribute(factionLadderElements.factionText, "textcolor.b", relationColor.b)
		setAttribute(factionLadderElements.factionText, "glowfactor", relationColor.glow)

		local factionIconColor = relationColor
		if relationDetails.relationStatus == 5 then
			-- note: player icons are not colored, since the player can specify his own texture/icon (which can contain specific colors in the texture and hence we'd not colorize it)
			--       i.e. reset to white diffuse color
			factionIconColor = Color["icon_normal"]
		end

		SetDiffuseColor(factionLadderElements.iconMaterial, factionIconColor.r, factionIconColor.g, factionIconColor.b)
		setAttribute(factionLadderElements.iconMaterial, "glowfactor", factionIconColor.glow)

		local font = getAttribute(private.anarkElements.targetMonitor.factionLadder.factionText, "font")
		local fontsize = scaleFont(config.factionFontSize)
		factionName = TruncateText(factionName, font, fontsize, config.targetMonitorPresentationWidth - math.ceil(C.GetTextWidth(" " .. relationText, font, fontsize)) - 125)
		setAttribute(private.anarkElements.targetMonitor.factionLadder.factionText, "textstring", factionName)
	end

	if private.factionLadderActive then
		-- only update the faction ladder, if it's active

		-- set the relation value
		-- #coreUIMed --- is the relationLEDValue comparison check correct here?
		if private.previousRelationDetails == nil or (private.previousRelationDetails.relationValue ~= relationDetails.relationValue or private.previousRelationDetails.relationLEDValue ~= relationDetails.relationLEDValue) then
			local relationTextValue = relationDetails.relationValue
			if relationDetails.relationValue > 0 then
				relationTextValue = "+"..relationDetails.relationValue
			end
			setCheckedText(factionLadderElements.valueText, relationTextValue)
		end

		if private.previousRelationDetails == nil or (private.previousRelationDetails.relationStatus ~= relationDetails.relationStatus) then
			-- update the faction value color
			setAttribute(factionLadderElements.valueText, "textcolor.r", relationColor.r)
			setAttribute(factionLadderElements.valueText, "textcolor.g", relationColor.g)
			setAttribute(factionLadderElements.valueText, "textcolor.b", relationColor.b)
			setAttribute(factionLadderElements.valueText, "glowfactor", relationColor.glow)
		end

		-- update relation LED elements
		if private.previousRelationDetails == nil or (private.previousRelationDetails.isBoostedValue ~= relationDetails.isBoostedValue or private.previousRelationDetails.relationLEDValue ~= relationDetails.relationLEDValue) then
			local slide
			for i = 1, 8 do
				if isBlinkingLED(i, relationDetails.relationLEDValue, relationDetails.isBoostedValue) then
					slide = "blinking"
				else
					slide = "active"
				end

				local materialElement = getElement("Rectangle.material", factionLadderElements[i])
				local elementColor = getLEDColor(i, relationDetails.relationLEDValue)
				SetDiffuseColor(materialElement, elementColor.r, elementColor.g, elementColor.b)

				goToSlide(factionLadderElements[i], slide)
			end
		end
	end

	private.previousRelationDetails = relationDetails
end

function updateRadar()
	if not private.radarActive then
		return -- nothing to do, if radar inactive atm
	end

	-- update the focus component in the radar, if that changes (note: only necessary in external target mode)
	if private.externalTargetMode then
		local focusComponent = C.GetExternalTargetViewComponent()

		if private.radarFocusComponent ~= focusComponent then
			updateRadarTarget(focusComponent)
		end
	end

	if not private.pointerOverRadar then
		return -- nothing more to do, if mouse not over radar atm
	end

	local x, y = GetRelativeMousePosition(private.radarPickFrame, false)
	C.SetRadarMousePosition(x, y)
end

function updateRadarTarget(focusComponent)
	if not private.radarActive then
		return false -- nothing to do, if radar inactive atm
	end

	if focusComponent == nil then
		if private.externalTargetMode then
			focusComponent = C.GetExternalTargetViewComponent()
		else
			focusComponent = 0
		end
	end

	private.radarFocusComponent = focusComponent
	if focusComponent ~= 0 then
		return C.SetRadarRenderTargetOnTarget2(private.radarRenderTarget, private.radarFocusComponent, private.softtargetID, private.radarMapMode)
	end

	return C.SetRadarRenderTarget2(private.radarRenderTarget, private.softtargetID, private.radarMapMode)
end

function updateRelationStatusData(notorietyComponentDetails)
	if notorietyComponentDetails.componentID ~= nil then
		if C.IsValidComponent(notorietyComponentDetails.componentID) then
			notorietyComponentDetails.relationDetails = C.GetRelationStatus3(notorietyComponentDetails.componentID, "")
		else
			-- component became invalid --- set to nil for next call
			notorietyComponentDetails.componentID = nil
		end
	end
end

function updateTargetMonitorDisplay(details, enableTargetMonitorRadar, isNotification)
	-- first we stop anything which was played before
	if private.curDescription then
		if not private.curDescription.keepDescription then
			-- a cutscene?
			deactivateCutscene()
		end

		-- a target monitor interaction?
		deactivateInteraction()
	end

	if (not private.curDescription) or (not private.curDescription.keepDescription) then
		private.curDescription = details
	end

	-- switch the rendertarget to the right slide (and initialize it)
	local slide = "inactive"
	if details.cutsceneDescriptor then
		if details.keepDescription and private.curDescription.cutsceneID then
			slide = "small"
		else
			slide = "noise"
			local interruptcinematicmode = details.interactionID ~= nil and not details.silent
			private.curDescription.cutsceneID = StartCutscene(details.cutsceneDescriptor, config.smallRenderTarget, interruptcinematicmode)
		end
		deactivateTargetMonitorRadar()
	elseif enableTargetMonitorRadar then
		slide = "large"
		activateTargetMonitorRadar()
	else -- target monitor radar not active at all, make sure it's deactivated (f.e. because we just updated the state since the option to disable the radar completely got set)
		deactivateTargetMonitorRadar()
	end
	private.curDescription.keepDescription = nil

	-- #coreUIMed - only reset the rendertarget slide, if we actually used it
	goToSlide(private.anarkElements.targetMonitor.rendertargetElement, slide)

	-- set the radar pointer picking for the target monitor mode, which depends on whether we show any overlay information
	if enableTargetMonitorRadar then
		if not next(details) then
			-- radar picking (for the target monitor) is only enabled while we don't display any overlay -> activate here
			activateRadarPicking()
		else
			deactivateRadarPicking()
		end
	end

	if not next(details) then
		deactivateOverlay()
		return -- we are done, if we don't have to display any further details (i.e. inactive target monitor or radar only display)
	end

	-- display overlay text
	activateOverlay()
	processOverlay(details, isNotification)

	-- display notoriety bar
	initNotorietyData(details)
	if shouldDisplayNotorietyBar(details) then
		showNotorietyBar(details)
	else
		hideNotorietyBar()
	end

	-- display interaction effect
	processInteractionDescriptor(details, isNotification)

	-- auto-close (i.e. duration handling)
	if details.duration and details.duration > 0 then
		private.autoCloseDuration = details.duration
		private.autoClose = getElapsedTime() + private.autoCloseDuration
		private.remainingAutoCloseDuration = nil

		if details.interactionID ~= nil then
			goToSlide(private.anarkElements.targetMonitor.interactBarElement, "active")
			goToTime(private.anarkElements.targetMonitor.interactBarElement, 1)
		end
	end
end

function updateTargetMonitorNotifications()
	-- free any previous notification
	deactivateTargetMonitorNotification()

	repeat
		if not next(private.targetMonitorNotifications) then
			hideTargetMonitorNotification() -- no more notifications to display
			return
		end
		switchTargetMonitorNotification()
	until private.currentNotificationID ~= nil
end

function scaleFont(size)
	return math.ceil(size * private.textUIScale)
end

function copyColor(color)
	return { r = color.r, g = color.g, b = color.b, a = color.a, glow = color.glow }
end
