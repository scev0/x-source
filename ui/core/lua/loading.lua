-- no need for special unlock-handling
-- presentation is recreated upon use

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
		const char* HintText;
		uint32_t HintID;
	} LoadingHint;
	typedef struct {
		bool active;
		bool reverse;
		uint32_t numtexts;
		uint32_t numinfotexts;
	} ScenarioLoadingData;
	void ContinueGameStart(void);
	void DisableScenarioLoading(void);
	uint32_t GetAllColorMapEntries(ColorMapEntry* result, uint32_t resultlen);
	uint32_t GetIcons(const char** result, uint32_t resultlen, const char* tags);
	LoadingHint GetLoadingHint(const uint32_t excludeid);
	const char* GetLocalizedText(const uint32_t pageid, uint32_t textid, const char*const defaultvalue);
	uint32_t GetNumAllColorMapEntries(void);
	uint32_t GetNumIcons(const char* tags);
	uint32_t GetScenarioLoadingTexts(const char** result, uint32_t resultlen);
	uint32_t GetScenarioLoadingInfoTexts(const char** result, uint32_t resultlen);
	float GetTextHeight(const char*const text, const char*const fontname, const float fontsize, const float wordwrapwidth);
	float GetUIScale(const bool scalewithresolution);
	bool IsDemoVersion();
	ScenarioLoadingData IsScenarioLoading(void);
	bool IsTradeShowVersion(void);
	bool IsVRMode();
	bool IsVRVersion();
	bool IsVROculusTouchActive();
	bool IsVRViveControllerActive();
]]

local utf8 = require("utf8")

--- Wrapper ---

local origffistring = ffi.string
ffi.string = function(data) 
	if data ~= nil then
		return origffistring(data)
	else
		DebugError("Invalid parameter for ffi.string() in loading. Check caller!")
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
	presentationSize      = { x = 1280, y = 720 },
	scaleFactor           = 0.01,
	screenScaleFactor     = 0.907,
	pageID                = 1035, -- the text page ID containing the loading screen texts
	demoPageID            = 1098, -- texts used for the demo version only
	proverbPageID         = 1099, -- the proverbs text page ID
	worldspaceZCorrection = 8,
	defaultScreenDelay    = 10,    -- delay (in s) when switching the default screenshots
	maxDemoScreens        = 0,     -- maximum number of demo screenshots (note: no default demo screens atm)
	maxReleaseScreens     = 5,     -- maximum number of screenshots
	maxVRScreens          = 3,     -- maximum number of VR screenshots
	cycleScreens          = false, -- whether or not we cycle through the default screens
	-- default proverb, in case there's an issue with the textdb entry
	defaultProverb        = "Sometimes I think we're alone in the universe, and sometimes I think we're not. In either case the idea is quite staggering. Arthur C. Clarke (1917 - 2008)",

	scenarioFadeInTime    = 1.5,
	scenarioFadeInDelay   = 1,
	scenarioFadeOutTime   = 1.5,
	scenarioFadeOutDelay  = 3,
	encodedTextSymbols    = { "<", ">", "!", "§", "$", "%", "&", "/", "=", "?" },
	characterProbabilityFactor = 0.1,
	reverseCharacterProbabilityFactor = 0.5,
	scenarioTextLifeTime = 5,
	scenarioNumTexts = 10,
	scenarioStartZ = 4800,

	barScaleX = 1.93,
	font = "Zekton",
	fontSize = 9,
	textHeight = 20,
	loadingCircleHeight = 50,
	proverbTextBoxWidth = 0.296,
	loadingCircleYOffset = -274,
	loadingTextYOffset = -231,
}

-- #coreUILow - actually we'd use proper textid/pageids for the different screens so that they can be translated independent from one another --- since they use the same text in principle though atm, this was deferred
-- text array containing localized text
local L = {
	["ACTIVATE GESTURE STEERING (TOUCH)"] = ffi.string(C.GetLocalizedText(config.pageID, 213, "ACTIVATE GESTURE STEERING (TOUCH)")),
	["ATTENTION: TOUCHING THE LEFT THUMBREST FOR 1 SECOND WILL RESET THE VR POSITION!"] = ffi.string(C.GetLocalizedText(config.pageID, 216, "ATTENTION: TOUCHING THE LEFT THUMBREST FOR 1 SECOND WILL RESET THE VR POSITION!")),
	["ATTENTION: TOUCHING THE RIGHT THUMBREST WILL ACTIVATE GESTURE STEERING!"] = ffi.string(C.GetLocalizedText(config.pageID, 217, "ATTENTION: TOUCHING THE RIGHT THUMBREST WILL ACTIVATE GESTURE STEERING!")),
	["BACK"] = ffi.string(C.GetLocalizedText(config.pageID, 113, "BACK")),
	["BACK (CLICK)"] = ffi.string(C.GetLocalizedText(config.pageID, 303, "BACK (CLICK)")),
	["BREAK / REVERSE"] = ffi.string(C.GetLocalizedText(config.pageID, 102, "BREAK / REVERSE")),
	["BOOST"] = ffi.string(C.GetLocalizedText(config.pageID, 307, "BOOST")),
	["BOOST (CLICK)"] = ffi.string(C.GetLocalizedText(config.pageID, 202, "BOOST (CLICK)")),
	["CONTAINER MAGNET (CLICK)"] = ffi.string(C.GetLocalizedText(config.pageID, 212, "CONTAINER MAGNET (CLICK)")),
	["FIRE PRIMARY WEAPON"] = ffi.string(C.GetLocalizedText(config.pageID, 103, "FIRE PRIMARY WEAPON")),
	["FIRE SECONDARY WEAPON"] = ffi.string(C.GetLocalizedText(config.pageID, 104, "FIRE SECONDARY WEAPON")),
	["FULL REVERSE"] = ffi.string(C.GetLocalizedText(config.pageID, 207, "FULL REVERSE")),
	["INTERACT"] = ffi.string(C.GetLocalizedText(config.pageID, 209, "INTERACT")),
	["INTERACTION MENU"] = ffi.string(C.GetLocalizedText(config.pageID, 114, "INTERACTION MENU")),
	["LEFT"] = ffi.string(C.GetLocalizedText(config.pageID, 219, "LEFT")),
	["Loading..."] = ffi.string(C.GetLocalizedText(1001, 5400, "Loading...")),
	["MAIN MENU"] = ffi.string(C.GetLocalizedText(config.pageID, 105, "MAIN MENU")),
	["NEXT MISSILE"] = ffi.string(C.GetLocalizedText(config.pageID, 109, "NEXT MISSILE")),
	["NEXT WEAPON"] = ffi.string(C.GetLocalizedText(config.pageID, 110, "NEXT WEAPON")),
	["POINTER SELECTION (CLICK)"] = ffi.string(C.GetLocalizedText(config.pageID, 312, "POINTER SELECTION (CLICK)")),
	["RESET VR POSITION (HOLD)"] = ffi.string(C.GetLocalizedText(config.pageID, 206, "RESET VR POSITION (HOLD)")),
	["RIGHT"] = ffi.string(C.GetLocalizedText(config.pageID, 220, "RIGHT")),
	["SECONDARY WEAPON (CLICK)"] = ffi.string(C.GetLocalizedText(config.pageID, 305, "SECONDARY WEAPON (CLICK)")),
	["Starting..."] = ffi.string(C.GetLocalizedText(config.demoPageID, 2, "Starting...")),
	["SETTINGS"] = ffi.string(C.GetLocalizedText(config.pageID, 111, "SETTINGS")),
	["STEERING"] = ffi.string(C.GetLocalizedText(config.pageID, 211, "STEERING")),
	["STEERING / CONTAINER MAGNET (CLICK)"] = ffi.string(C.GetLocalizedText(config.pageID, 116, "STEERING / CONTAINER MAGNET (CLICK)")),
	["STRAFE"] = ffi.string(C.GetLocalizedText(config.pageID, 201, "STRAFE")),
	["STRAFE / BOOST (CLICK)"] = ffi.string(C.GetLocalizedText(config.pageID, 106, "STRAFE / BOOST (CLICK)")),
	-- #coreUILow - used in VR mode only - when relevant, we might wanna rename this to targeting closest hostile however
	["TARGET CLOSEST ENEMY"] = ffi.string(C.GetLocalizedText(config.pageID, 108, "TARGET CLOSEST ENEMY")),
	["TOGGLE GESTURE STEERING (CLICK)"] = ffi.string(C.GetLocalizedText(config.pageID, 310, "TOGGLE GESTURE STEERING (CLICK)")),
	["TOGGLE TARGET LOCK"] = ffi.string(C.GetLocalizedText(config.pageID, 107, "TOGGLE TARGET LOCK")),
	["THROTTLE"] = ffi.string(C.GetLocalizedText(config.pageID, 101, "TROTTLE"))
}

-- private member data
local private = {
	sceneElement = nil,             -- the scene element
	barElement = nil,               -- the progress element
	progressTextElement = nil,      -- the progress text element
	screenshotElement = nil,        -- the screenshot element
	screenTextElement = nil,        -- the screen text element (displaying (optional) text on a screen)
	screenshotTextureElement = nil, -- the screenshot texture element
	loadingCircleElement = nil,     -- the loading circle element
	hintTextElement = nil,          -- the hint text element
	startTextElement = nil,         -- the start text element
	percentageTextElement = nil,    -- the percentage text element
	curProgressText = "",           -- the currently displayed progress text
	curPercentage = 0,              -- the currently displayed percentage
	nextHintTime = 0,               -- next time the hint text is allowed to change
	hintRate = 20,                  -- rate at which hint text is changed
	nextScreen = 0,                 -- time at which the next screenshot will be displayed
	curScreen = 0,                  -- current displayed screenshot
	-- reenable once input system support was added (XR-1106)
	delayGamestart = false,         -- indicates whether the gamestart is delayed until the UI indicates to start the game
	demoMode = false,               -- indicates whether we are in demo (true) or release (false) mode
	enableTooltips = true,          -- indicates whether tooltips are displayed
	maxScreens = nil,               -- maximum number of screenshots
	vrVersion = false,              -- indicates whether we are running the VR version
	curHintText = "",               -- the currently displayed hint text
	curHintID = 0,                  -- the ID of the currently displayed hint text
	initialScreen = nil,            -- the initial loading screen which should be displayed, if any
	initialScreenText = nil,        -- the text to be displayed on the initial loading screen, if any
	initialScreenTime = nil,        -- the time to display the initial loading screen, if any
	displayingProverb = true,       -- indicates whether we are displaying the proverb atm
	textStates = {},
}

-- local functions forward declarations
local initProverb
local initVRTexts
local onLoadingDone
local onSkipScreenshot
local setColorHelper
local setPercentage
local setProgressText
local setTextColor
local switchScreenshot
local updateScenarioTexts
local updateScreenshots

---------------------------------
-- Gameface lifetime functions --
---------------------------------
function self:onInitialize()
	private.sceneElement = getElement("Scene")

	local contract           = getElement("UIContract", private.sceneElement)
	local uiAnchorElement    = getElement("Layer.ui_anchor", private.sceneElement)
	local backgroundMaterialElement     = getElement("background.Material126", uiAnchorElement)
	
	private.loadingTextElement = getElement("Text", uiAnchorElement)
	private.barElement            = getElement("bar", uiAnchorElement)
	private.progressTextElement   = getElement("ProgressText", uiAnchorElement)
	private.hintTextElement       = getElement("HintText", uiAnchorElement)
	private.percentageTextElement = getElement("Percentage", uiAnchorElement)
	private.screenshotElement     = getElement("screenshots", uiAnchorElement)
	private.screenTextElement     = getElement("text", private.screenshotElement)
	private.screenshotTextureElement = getElement("default_1.screenshots.material.screen_01_diff", private.screenshotElement)
	private.startTextElement      = getElement("Start", uiAnchorElement)
	private.loadingCircleElement  = getElement("loading_circle", uiAnchorElement)
	private.proverbElement        = getElement("proverb", uiAnchorElement)
	private.dustElement           = getElement("dust", uiAnchorElement)
	private.dustTextMasterElement = getElement("dustText", uiAnchorElement)

	private.dustTextElements = {}
	private.dustTextElements[1] = private.dustTextMasterElement
	setTextColor(private.dustTextElements[1], Color["loadingscreen_scenario_text"])
	private.textStates[1] = {}
	for i = 2, config.scenarioNumTexts do
		private.dustTextElements[i] = clone(private.dustTextMasterElement, "dustText" .. i)
		setTextColor(private.dustTextElements[i], Color["loadingscreen_scenario_text"])
		private.textStates[i] = {}
	end

	if C.IsVRMode() then
		-- reposition/rescale the whole scene to be in worldspace in VR
		setAttribute(uiAnchorElement, "scale.x", config.scaleFactor)
		setAttribute(uiAnchorElement, "scale.y", config.scaleFactor)
		setAttribute(uiAnchorElement, "position.z", config.worldspaceZCorrection)
		SetFullScreenWorldSpace()
	end

	initScale()

	-- clear/initialize the text elements
	setAttribute(private.loadingTextElement, "textstring", L["Loading..."])
	setAttribute(private.progressTextElement, "textstring", "")
	setAttribute(private.hintTextElement, "textstring", "")
	setAttribute(private.startTextElement, "textstring", "")

	setTextColor(private.loadingTextElement, Color["loadingscreen_text"])
	setTextColor(private.progressTextElement, Color["loadingscreen_text"])
	setTextColor(private.hintTextElement, Color["loadingscreen_text"])
	setTextColor(private.startTextElement, Color["loadingscreen_text"])
	setTextColor(private.percentageTextElement, Color["loadingscreen_text"])
	setTextColor(private.screenTextElement, Color["loadingscreen_text"])

	-- init color
	setColorHelper(getElement("title_menu_loading_ring.Material247", private.loadingCircleElement), nil, Color["loadingscreen_circle"])
	setColorHelper(getElement("loadingbar.Material148", private.barElement), nil, Color["loadingscreen_bar"])
	setColorHelper(getElement("loadingbar_background.Material148", private.barElement), nil, Color["loadingscreen_bar_background"])
	setColorHelper(backgroundMaterialElement, nil, Color["loadingscreen_background"])

	local dustelements = { "dust_01", "dust_02", "dust_03", "dust_04" }
	for _, element in ipairs(dustelements) do
		setColorHelper(getElement(element .. ".dust_01", private.dustElement), nil, Color["loadingscreen_scenario_dust"])
	end

	-- set the hint text width
	setAttribute(private.hintTextElement, "boxwidth", 0.85)

	setAttribute(private.proverbElement, "textstring", "")

	registerForEvent("gameLoadingDone", contract, onLoadingDone)
	registerForEvent("skipScreenshot", contract, onSkipScreenshot)

	private.demoMode = C.IsDemoVersion()
	private.vrVersion = C.IsVRVersion()

	local scenariodata = C.IsScenarioLoading()
	private.scenarioMode = scenariodata.active
	if private.scenarioMode then
		private.scenarioReverse = scenariodata.reverse
		private.scenarioTexts = {}
		private.scenarioTextIdx = 0
		if scenariodata.numtexts > 0 then
			private.scenarioTextIdx = 1
			local buf = ffi.new("const char*[?]", scenariodata.numtexts)
			local n = C.GetScenarioLoadingTexts(buf, scenariodata.numtexts)
			for i = 0, n - 1 do
				table.insert(private.scenarioTexts, ffi.string(buf[i]))
			end
		end
		private.scenarioInfoText = ""
		if scenariodata.numinfotexts > 0 then
			local buf = ffi.new("const char*[?]", scenariodata.numinfotexts)
			local n = C.GetScenarioLoadingInfoTexts(buf, scenariodata.numinfotexts)
			for i = 0, n - 1 do
				private.scenarioInfoText = private.scenarioInfoText .. "\n" .. ffi.string(buf[i])
			end
		end
	end

	local _, _, loadCount, isSavegame, numProverbs, initialLoadingScreen, initialLoadingScreenText, initialLoadingScreenTime = GetLoadingInfo()

	if initialLoadingScreen ~= "" then
		private.initialScreen = initialLoadingScreen
		private.initialScreenText = initialLoadingScreenText
		if initialLoadingScreenTime ~= 0 then
			-- only set the initialScreenTime, if we are given a value - otherwise, set it to nil so that the initial screen is displayed indefinitely
			private.initialScreenTime = initialLoadingScreenTime
		end
	end

	if private.demoMode then
		local icontag = C.IsTradeShowVersion() and "tradeshowloadingscreen" or "demoloadingscreen"

		private.screenshots = {}
		local n = C.GetNumIcons(icontag)
		if n > 0 then
			local buf = ffi.new("const char*[?]", n)
			n = C.GetIcons(buf, n, icontag)
			for i = 0, n - 1 do
				table.insert(private.screenshots, ffi.string(buf[i]))
			end
		end

		private.cycleScreens = true
		private.maxScreens = n
		private.curScreen  = math.random(n)

		private.enableTooltips = isSavegame               -- tooltips are only displayed in demo mode, if we load a savegame so to not overload the new player with too much information
		private.delayGamestart = true                     -- so the player has time to read the instructions before starting the demo
	elseif private.vrVersion then
		initVRTexts()
		private.maxScreens     = config.maxVRScreens
		private.delayGamestart = true -- so the player has time to put on his HMD before starting the game
	elseif private.scenarioMode then
		private.enableTooltips = false
		private.nextScreen = nil
		private.displayingProverb = false
	else
		private.screenshots = {}
		local n = C.GetNumIcons("loadingscreen")
		if n > 0 then
			local buf = ffi.new("const char*[?]", n)
			n = C.GetIcons(buf, n, "loadingscreen")
			for i = 0, n - 1 do
				table.insert(private.screenshots, ffi.string(buf[i]))
			end
		end

		private.cycleScreens = true
		private.maxScreens = n
		private.curScreen  = math.random(n)
	end

	if not private.scenarioMode then
		setPercentage(0)
	end

	-- in demo mode we don't display the proverb screen
	if private.demoMode then
		-- note: all we need to do is set the initial slide to display the loading screen directly which will then skip the proverb display
		goToSlide(private.sceneElement, "loading")
	elseif private.scenarioMode then
		setAttribute(private.dustElement, "opacity", 0)
		goToSlide(private.sceneElement, private.scenarioReverse and "loop_reverse" or "loop")
		private.scenarioFadeInStart = getElapsedTime()
	else
		-- initialize the proverb text element
		initProverb(private.proverbElement, numProverbs)

		-- workaround for XR-1519
		goToSlide(private.sceneElement, "proverb")
	end
end

function initScale() 
	private.uiScale = math.min(1.5, C.GetUIScale(not C.IsVRMode()))
	
	local loadingoffset = (private.uiScale - 1) * config.loadingCircleHeight / 2
	setAttribute(private.loadingCircleElement, "scale.x", private.uiScale)
	setAttribute(private.loadingCircleElement, "scale.y", private.uiScale)
	setAttribute(private.loadingCircleElement, "position.y", config.loadingCircleYOffset + loadingoffset)
	setAttribute(private.percentageTextElement, "size", config.fontSize * private.uiScale)
	setAttribute(private.percentageTextElement, "position.y", config.loadingCircleYOffset + loadingoffset)

	setAttribute(private.barElement, "scale.x", config.barScaleX * private.uiScale)
	
	local textoffset = (private.uiScale - 1) * config.textHeight / 2
	setAttribute(private.loadingTextElement, "size", config.fontSize * private.uiScale)
	setAttribute(private.loadingTextElement, "position.y", config.loadingTextYOffset + 2 * loadingoffset + textoffset)

	setAttribute(private.hintTextElement, "size", config.fontSize * private.uiScale)
	setAttribute(private.progressTextElement, "size", config.fontSize * private.uiScale)
	setAttribute(private.screenTextElement, "size", config.fontSize * private.uiScale)
	setAttribute(private.startTextElement, "size", config.fontSize * private.uiScale)

	setAttribute(private.proverbElement, "size", config.fontSize * private.uiScale)
	setAttribute(private.proverbElement, "boxwidth", config.proverbTextBoxWidth * private.uiScale)
end

function self:onUpdate()
	if private.displayingProverb then
		-- check if we are still displaying the proverb
		-- #coreUILow - replace with onSlideEnter-based checks
		local _, slidename = getCurrentSlide(private.sceneElement)
		-- issue related to XR-1520
		if string.find(slidename, "proverb") or string.find(slidename, "dummy") then
			return -- nothing to do as long as we are displaying the proverb
		end
		private.displayingProverb = false

		-- switch to the initial screenshot, if any is specified
		if private.initialScreen then
			switchScreenshot("default_1", private.initialScreen, private.initialScreenText, private.initialScreenTime)
		end
	end

	if private.enableTooltips then
		local time = getElapsedTime()
		if private.nextHintTime < time then
			private.nextHintTime = time + private.hintRate
			local hint = C.GetLoadingHint(private.curHintID)
			setHintText(hint)
		end
	end

	if not private.scenarioMode then
		local text, percentage = GetLoadingInfo()
		setPercentage(percentage)
		setProgressText(text)

		updateScreenshots(false)
	elseif not private.continueGameStartTime then
		updateScenarioTexts()
	end

	if private.scenarioFadeOutStart then
		local time = getElapsedTime()
		local opacity = math.max(0, math.min(100, ((private.scenarioFadeOutStart - time) / config.scenarioFadeOutTime) * 100))
		setAttribute(private.dustElement, "opacity", opacity)
		if private.scenarioFadeOutStart < time then
			if private.scenarioReverse then
				C.ContinueGameStart()
				return
			else
				private.scenarioFadeOutStart = nil
				private.continueGameStartTime = time + config.scenarioFadeOutDelay

				setAttribute(private.dustTextElements[1], "position.x", -380)
				setAttribute(private.dustTextElements[1], "position.y", 180)
				setAttribute(private.dustTextElements[1], "position.z", 0)
				setAttribute(private.dustTextElements[1], "opacity", 100)
				setAttribute(private.dustTextElements[1], "horzalign", 0)
				setAttribute(private.dustTextElements[1], "size", math.ceil(7 * private.uiScale))
				setAttribute(private.dustTextElements[1], "textstring", "")
			end
		end
	end

	if private.continueGameStartTime then
		local time = getElapsedTime()
		local cursor = ""
		if (time * 4) % 2 > 1 then
			cursor = "_"
		end
		local textpercent = (config.scenarioFadeOutDelay - private.continueGameStartTime + time) / (config.scenarioFadeOutDelay - 1)
		if textpercent >= 1 then
			setAttribute(private.dustTextElements[1], "textstring", private.scenarioInfoText .. cursor)
		else
			local numchars = utf8.len(private.scenarioInfoText) * textpercent
			local text = utf8.sub(private.scenarioInfoText, 1, numchars)
			setAttribute(private.dustTextElements[1], "textstring", text .. cursor)
		end

		if private.continueGameStartTime < time then
			C.ContinueGameStart()
			return
		end
	end

	if private.scenarioFadeInStart then
		local opacity = math.max(0, math.min(100, ((getElapsedTime() - config.scenarioFadeInDelay - private.scenarioFadeInStart) / config.scenarioFadeInTime) * 100))
		setAttribute(private.dustElement, "opacity", opacity)
		if opacity == 100 then
			private.scenarioFadeInStart = nil
		end
	end
end

-------------------------------------
-- Presentation specific callbacks --
-------------------------------------
function onLoadingDone()
	if private.delayGamestart then
		setAttribute(private.startTextElement, "textstring", L["Starting..."])
	end
	if private.scenarioMode then
		C.DisableScenarioLoading()
		private.scenarioFadeInStart = nil
		private.scenarioFadeOutStart = getElapsedTime() + config.scenarioFadeOutTime
	end
end

function onSkipScreenshot()
	updateScreenshots(true)
end

-------------------------------------
-- Presentation specific functions --
-------------------------------------
function initProverb(textElement, numProverbs)
	local proverbText = config.defaultProverb

	-- note: even though we are using a simple randomized value here, the chances of displaying each proverb differs and is controlled by adding
	--       multiple text references to the same proverb in the textDB
	if numProverbs > 0 then
		local proverbNumber = math.floor(math.random(numProverbs))
		-- proverbs are listed on page 1099 starting from [1, numProverbs]
		proverbText = ffi.string(C.GetLocalizedText(config.proverbPageID, proverbNumber, config.defaultProverb))
	end

	local textheight = C.GetTextHeight(proverbText, config.font, config.fontSize * private.uiScale, config.proverbTextBoxWidth * private.uiScale * 1280)
	setAttribute(textElement, "position.y", textheight / 2)
	setAttribute(textElement, "textstring", proverbText)
	setTextColor(textElement, Color["loadingscreen_text"])
end

function initVRTexts()
	-- gamepad
	local groupElement = getElement("vr_gamepad", private.screenshotElement)
	setAttribute(getElement("Text1", groupElement), "textstring", L["THROTTLE"])
	setAttribute(getElement("Text2", groupElement), "textstring", L["BREAK / REVERSE"])
	setAttribute(getElement("Text3", groupElement), "textstring", L["MAIN MENU"])
	setAttribute(getElement("Text4", groupElement), "textstring", L["STRAFE / BOOST (CLICK)"])
	setAttribute(getElement("Text5", groupElement), "textstring", L["TOGGLE TARGET LOCK"])
	setAttribute(getElement("Text6", groupElement), "textstring", L["TARGET CLOSEST ENEMY"])
	setAttribute(getElement("Text7", groupElement), "textstring", L["NEXT MISSILE"])
	setAttribute(getElement("Text8", groupElement), "textstring", L["NEXT WEAPON"])
	setAttribute(getElement("Text9", groupElement), "textstring", L["FIRE PRIMARY WEAPON"])
	setAttribute(getElement("Text10", groupElement), "textstring", L["FIRE SECONDARY WEAPON"])
	setAttribute(getElement("Text11", groupElement), "textstring", L["FULL REVERSE"])
	-- #coreUIMed - "Text12" was ability menu
	setAttribute(getElement("Text13", groupElement), "textstring", L["BACK"])
	setAttribute(getElement("Text14", groupElement), "textstring", L["INTERACTION MENU"])
	-- #coreUIMed - "Text15" was quick menu
	setAttribute(getElement("Text16", groupElement), "textstring", L["STEERING / CONTAINER MAGNET (CLICK)"])

	-- vive
	groupElement = getElement("vr_vive", private.screenshotElement)
	setAttribute(getElement("Text1", groupElement), "textstring", L["LEFT"])
	setAttribute(getElement("Text2", groupElement), "textstring", L["RIGHT"])
	-- #coreUIMed - "Text2" was ability menu (click)
	setAttribute(getElement("Text4", groupElement), "textstring", L["BACK (CLICK)"])
	-- #coreUIMed - "Text5" was quick menu (click)
	setAttribute(getElement("Text6", groupElement), "textstring", L["SECONDARY WEAPON (CLICK)"])
	setAttribute(getElement("Text7", groupElement), "textstring", L["STRAFE"])
	setAttribute(getElement("Text8", groupElement), "textstring", L["MAIN MENU"])
	setAttribute(getElement("Text9", groupElement), "textstring", L["THROTTLE"])
	setAttribute(getElement("Text10", groupElement), "textstring", L["BOOST"])
	setAttribute(getElement("Text11", groupElement), "textstring", L["SETTINGS"])
	setAttribute(getElement("Text12", groupElement), "textstring", L["FIRE PRIMARY WEAPON"])
	setAttribute(getElement("Text13", groupElement), "textstring", L["TOGGLE GESTURE STEERING (CLICK)"])
	setAttribute(getElement("Text14", groupElement), "textstring", L["RESET VR POSITION (HOLD)"])
	setAttribute(getElement("Text15", groupElement), "textstring", L["POINTER SELECTION (CLICK)"])
	setAttribute(getElement("Text16", groupElement), "textstring", L["STEERING"])

	-- oculus 1
	groupElement = getElement("vr_oculus_1", private.screenshotElement)
	setAttribute(getElement("Text1", groupElement), "textstring", L["LEFT"])
	setAttribute(getElement("Text2", groupElement), "textstring", L["STRAFE"])
	setAttribute(getElement("Text3", groupElement), "textstring", L["BOOST (CLICK)"])
	setAttribute(getElement("Text4", groupElement), "textstring", L["MAIN MENU"])
	setAttribute(getElement("Text5", groupElement), "textstring", L["THROTTLE"])
	-- #coreUIMed - "Text6" was quick menu
	-- #coreUIMed - "Text7" was ability menu
	setAttribute(getElement("Text8", groupElement), "textstring", L["RESET VR POSITION (HOLD)"])
	setAttribute(getElement("Text9", groupElement), "textstring", L["INTERACT"])
	setAttribute(getElement("Text10", groupElement), "textstring", L["BACK"])
	setAttribute(getElement("Text11", groupElement), "textstring", L["ACTIVATE GESTURE STEERING (TOUCH)"])
	setAttribute(getElement("Text12", groupElement), "textstring", L["FULL REVERSE"])
	setAttribute(getElement("Text13", groupElement), "textstring", L["STEERING"])
	setAttribute(getElement("Text14", groupElement), "textstring", L["CONTAINER MAGNET (CLICK)"])
	setAttribute(getElement("Text15", groupElement), "textstring", L["FIRE SECONDARY WEAPON"])
	setAttribute(getElement("Text16", groupElement), "textstring", L["FIRE PRIMARY WEAPON"])
	setAttribute(getElement("Text17", groupElement), "textstring", L["RIGHT"])

	-- oculus 2
	groupElement = getElement("vr_oculus_2", private.screenshotElement)
	setAttribute(getElement("Text1", groupElement), "textstring", L["LEFT"])
	setAttribute(getElement("Text2", groupElement), "textstring", L["RIGHT"])
	setAttribute(getElement("Text3", groupElement), "textstring", L["ATTENTION: TOUCHING THE LEFT THUMBREST FOR 1 SECOND WILL RESET THE VR POSITION!"])
	setAttribute(getElement("Text4", groupElement), "textstring", L["RESET VR POSITION (HOLD)"])

	-- oculus 3
	groupElement = getElement("vr_oculus_3", private.screenshotElement)
	setAttribute(getElement("Text1", groupElement), "textstring", L["LEFT"])
	setAttribute(getElement("Text2", groupElement), "textstring", L["ATTENTION: TOUCHING THE RIGHT THUMBREST WILL ACTIVATE GESTURE STEERING!"])
	setAttribute(getElement("Text3", groupElement), "textstring", L["RIGHT"])
	setAttribute(getElement("Text4", groupElement), "textstring", L["ACTIVATE GESTURE STEERING (TOUCH)"])
end

function setColorHelper(element, parent, color)
	SetDiffuseColor(parent or element, color.r, color.g, color.b)
	setAttribute(parent or element, "opacity", color.a)
	setAttribute(element, "glowfactor", color.glow)
end

function setPercentage(percentage)
	if private.curPercentage == percentage then
		return -- already up-to-date
	end

	-- display the "Press space to start" text
	if private.delayGamestart and percentage == 100 then
		-- note: must not use memoizing here since the text varies based on the actual input system (i.e. controller/keyboard/etc.)
		--       hence we must retrieve the actual text exactly here/now
		setAttribute(private.startTextElement, "textstring", ffi.string(C.GetLocalizedText(config.demoPageID, 1, "Press $INPUT_ACTION_START_GAME$ to start the game.")))
	end
	if percentage == 100 then
		-- deactivate the spinning loading circle, when the 
		goToSlide(private.loadingCircleElement, "inactive")
	end

	setAttribute(private.percentageTextElement, "textstring", math.floor(percentage).."%")
	goToTime(private.barElement, percentage/100)
	private.curPercentage = percentage
end

function setProgressText(text)
	if private.curProgressText == text then
		return -- already up-to-date
	end
	
	setAttribute(private.progressTextElement, "textstring", text)
	private.curProgressText = text
end

function setHintText(hint)
	if private.curHintID == hint.HintID then
		return -- already up-to-date
	end
	
	private.curHintText = ffi.string(hint.HintText)
	private.curHintID = hint.HintID
	setAttribute(private.hintTextElement, "textstring", private.curHintText)
end

function setTextColor(textelement, color)
	setAttribute(textelement, "textcolor.r", color.r)
	setAttribute(textelement, "textcolor.g", color.g)
	setAttribute(textelement, "textcolor.b", color.b)
	setAttribute(textelement, "glowfactor", color.glow)
end

function switchScreenshot(slide, screen, text, time)
	setAttribute(private.screenTextElement, "textstring", text)
	goToSlide(private.screenshotElement, slide)

	if slide == "default_1" then
		SetIcon(private.screenshotTextureElement, screen, 255, 255, 255, false, config.presentationSize.x * config.screenScaleFactor, config.presentationSize.y * config.screenScaleFactor)
	end

	private.nextScreen = getElapsedTime() + time
end

function updateScenarioTexts()
	local textinterval = config.scenarioTextLifeTime / config.scenarioNumTexts
	local symbols = config.encodedTextSymbols
	local numsymbols = #symbols

	local curtime = getElapsedTime()
	for i = 1, config.scenarioNumTexts do
		local int, frac = math.modf(curtime + i * textinterval)
		local time = int % config.scenarioTextLifeTime + frac
		if private.scenarioFadeOutStart then
			local opacity = math.max(0, math.min(100, ((private.scenarioFadeOutStart - curtime) / config.scenarioFadeOutTime) * 100))
			setAttribute(private.dustTextElements[i], "opacity", opacity)
		else
			if (not private.continueGameStartTime) and ((private.textStates[i].lastupdate == nil) or ((time < textinterval) and (private.textStates[i].lastupdate + textinterval < curtime))) then
				private.textStates[i] = { lastupdate = curtime, text = (private.scenarioTextIdx > 0) and private.scenarioTexts[private.scenarioTextIdx] or "", lasttextupdate = curtime - 1, ignorechar = {} }

				local x = math.random(-config.presentationSize.x, config.presentationSize.x)
				local y = math.random(-config.presentationSize.y, config.presentationSize.y)
				setAttribute(private.dustTextElements[i], "position.x", x)
				setAttribute(private.dustTextElements[i], "position.y", y)

				private.scenarioTextIdx = private.scenarioTextIdx + 1
				if private.scenarioTextIdx > #private.scenarioTexts then
					private.scenarioTextIdx = 1
				end

				local text
				if private.scenarioReverse then
					text = private.textStates[i].text
				else
					text = ""
					for i = 1, utf8.len(private.textStates[i].text) do
						text = text .. symbols[math.random(numsymbols)]
					end
				end
				setAttribute(private.dustTextElements[i], "textstring", text)
			end

			if private.scenarioFadeInStart then
				local opacity = math.max(0, math.min(100, ((curtime - config.scenarioFadeInDelay - private.scenarioFadeInStart) / config.scenarioFadeInTime) * 100))
				setAttribute(private.dustTextElements[i], "opacity", opacity)
			elseif time < textinterval then
				local opacity = frac * 100 / textinterval
				setAttribute(private.dustTextElements[i], "opacity", opacity)
			elseif time > (config.scenarioTextLifeTime - textinterval) then
				local opacity = (1 - frac) * 100 / textinterval
				setAttribute(private.dustTextElements[i], "opacity", opacity)
			end
		end

		if private.textStates[i].lasttextupdate + 0.1 < curtime then
			private.textStates[i].lasttextupdate = curtime

			local text = getAttribute(private.dustTextElements[i], "textstring")
			local probability = (time / config.scenarioTextLifeTime) * (private.scenarioReverse and config.reverseCharacterProbabilityFactor or config.characterProbabilityFactor)
			local revealed = false
			for j = 1, utf8.len(text) do
				if private.scenarioReverse then
					if private.textStates[i].ignorechar[j] then
						text = utf8.remove(text, j, j)
						text = utf8.insert(text, j, symbols[math.random(numsymbols)])
					elseif (not revealed) and (math.random() < probability) then
						revealed = true
						text = utf8.remove(text, j, j)
						text = utf8.insert(text, j, symbols[math.random(numsymbols)])
						private.textStates[i].ignorechar[j] = true
					end
				else
					if not private.textStates[i].ignorechar[j] then
						if math.random() < (1 - probability) then
							text = utf8.remove(text, j, j)
							text = utf8.insert(text, j, symbols[math.random(numsymbols)])
						elseif not revealed then
							revealed = true
							text = utf8.remove(text, j, j)
							text = utf8.insert(text, j, utf8.sub(private.textStates[i].text, j, j))
							private.textStates[i].ignorechar[j] = true
							break
						end
					end
				end
			end
			setAttribute(private.dustTextElements[i], "textstring", text)
		end

		local z
		if private.scenarioReverse then
			z = (time / config.scenarioTextLifeTime) * config.scenarioStartZ
		else
			z = (1 - time / config.scenarioTextLifeTime) * config.scenarioStartZ
		end
		setAttribute(private.dustTextElements[i], "position.z", z)
	end
end

function updateScreenshots(force)
	if private.nextScreen == nil then
		return -- screenshots not enabled -> nothing to do
	end

	if not force and getElapsedTime() < private.nextScreen then
		return -- screenshot not timed out yet
	end

	-- determine the next screen number
	local nextScreen = private.curScreen + 1
	if nextScreen > private.maxScreens then
		if not private.cycleScreens then
			private.nextScreen = nil
			return -- switching to last screenshot, no more updates required
		end

		nextScreen = 1 -- cycle around to first screen
	end

	-- determine the slide prefix
	local slide = "default_1"
	local screenshot = "loading_screen_1"
	if private.vrVersion then
		-- vr version loading screen is still done with slides in the anark presentation due to custom placement of texts in those slides.
		-- Therefore screenshot has no effect in this case

		-- just use the first one for now. There are 3 oculus screens, but no current code seems to use them.
		nextScreen = 1

		local mode = GetControllerInfo()
		if mode == "touch" then
			-- we dynamically switch the screens based on the current input mode
			if C.IsVROculusTouchActive() then
				slide = "vr_oculus_" .. nextScreen
				--screenshot = "loading_vr_oculus_screen_" .. nextScreen
			elseif C.IsVRViveControllerActive() then
				slide = "vr_vive_" .. nextScreen
				--screenshot = "loading_vr_vive_screen_" .. nextScreen
			else
				DebugError("Loading screen error. Unsupported touch controller. Fallback to display gamepad controls.")
				slide = "vr_gamepad_" .. nextScreen
				--screenshot = "loading_vr_gamepad_screen_" .. nextScreen
			end
		else -- mode == "gamepad" || "mouseCursor" || "mouseSteering" || "joystick" <- all of these should result in gamepad-screenshot being used
			slide = "vr_gamepad_" .. nextScreen
			--screenshot = "loading_vr_gamepad_screen_" .. nextScreen
		end
	else
		nextScreen = math.random(private.maxScreens)
		if nextScreen == private.curScreen then
			nextScreen = (nextScreen == private.maxScreens) and 1 or (private.curScreen + 1)
		end
		screenshot = private.screenshots[nextScreen]
	end

	switchScreenshot(slide, screenshot, "", config.defaultScreenDelay)
	private.curScreen = nextScreen
end
