-- no need for special unlock-handling
-- script is never locked

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef struct {
		const char* name;
		uint32_t size;
	} Font;

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
		int x;
		int y;
	} Coord2D;
	typedef struct {
		uint32_t width;
		uint32_t height;
		uint32_t xHotspot;
		uint32_t yHotspot;
	} CursorInfo;
	typedef struct {
		Color color;
		uint32_t width;
		uint32_t height;
		uint32_t x;
		uint32_t y;
		float glowfactor;
	} DropDownIconInfo;
	typedef struct {
		const char* id;
		const char* iconid;
		const char* text;
		const char* text2;
		const char* mouseovertext;
		const char* font;
		Color overrideColor;
		bool displayRemoveOption;
		bool active;
		bool hasOverrideColor;
	} DropDownOption2;
	typedef struct {
		Color color;
		Font font;
		const char* alignment;
		uint32_t x;
		uint32_t y;
		const char* textOverride;
		float glowfactor;
	} DropDownTextInfo;
	typedef struct {
		double x;
		double y;
		bool inactive;
	} GraphDataPoint2;
	typedef struct {
		uint32_t MarkerType;
		uint32_t MarkerSize;
		Color MarkerColor;
		float MarkerGlowFactor;
		uint32_t LineType;
		uint32_t LineWidth;
		Color LineColor;
		float LineGlowFactor;
		size_t NumData;
		bool Highlighted;
		const char* MouseOverText;
	} GraphDataRecord;
	typedef struct {
		size_t DataRecordIdx;
		size_t DataIdx;
		const char* IconID;
		const char* MouseOverText;
	} GraphIcon;
	typedef struct {
		const char* text;
		Font font;
		Color color;
	} GraphTextInfo;
	typedef struct {
		GraphTextInfo label;
		double startvalue;
		double endvalue;
		double granularity;
		double offset;
		bool grid;
		Color color;
		Color gridcolor;
		float glowfactor;
	} GraphAxisInfo;
	typedef struct {
		const char* iconid;
		uint32_t x;
		uint32_t y;
		bool display;
	} HotkeyInfo;
	typedef struct {
		int x;
		int y;
	} ResolutionInfo;
	typedef struct {
		double min;
		double minSelect;
		double max;
		double maxSelect;
		double start;
		double step;
		double infinitevalue;
		uint32_t maxfactor;
		bool exceedmax;
		bool hidemaxvalue;
		bool righttoleft;
		bool fromcenter;
		bool readonly;
		bool useinfinitevalue;
		bool usetimeformat;
	} SliderCellDetails;
	typedef struct {
		uint32_t toprow;
		uint32_t selectedrow;
		uint32_t selectedcol;
		uint32_t shiftstart;
		uint32_t shiftend;
	} TableSelectionInfo;
	typedef struct {
		const char* text;
		int32_t x;
		int32_t y;
		const char* alignment;
		Color color;
		Font font;
		float glowfactor;
	} TextInfo;
	typedef struct {
		const char* iconid;
		Color color;
		uint32_t width;
		uint32_t height;
		int32_t rotationrate;
		uint32_t rotstart;
		float rotduration;
		float rotinterval;
		float initscale;
		float scaleduration;
		float glowfactor;
	} UIFrameTextureInfo;
	typedef struct {
		const char* id;
		const char* text;
		uint32_t x;
		uint32_t y;
		uint32_t width;
		uint32_t height;
		bool highlightonly;
		bool usebackgroundspan;
	} UIOverlayInfo2;
	void ActivateDirectInput(void);
	void ActivateDirectKeyInput(void);
	void ActivateSliderCellInput(void);
	bool CopyToClipboard(const char*const text);
	void DeactivateDirectInput(void);
	void DeactivateDirectKeyInput(void);
	void DeactivateMouseEmulation(void);
	void DeactivateSliderCellInput(void);
	void DisableEncryptedDirectInputMode(void);
	bool DoesSliderCellForceArrows(const int slidercellid);
	void EnableEncryptedDirectInputMode(void);
	uint32_t GetAllColorMapEntries(ColorMapEntry* result, uint32_t resultlen);
	bool GetBoxTextBoxColor(const int boxtextid, Color* color);
	bool GetBoxTextInfo(const int boxtextid, TextInfo* textinfo);
	float GetButtonColorGlowFactor(const int buttonid);
	bool GetButtonHighlightColor(const int buttonid, Color* color);
	float GetButtonHighlightColorGlowFactor(const int buttonid);
	float GetButtonIconGlowFactor(const int buttonid);
	float GetButtonIcon2GlowFactor(const int buttonid);
	float GetButtonTextGlowFactor(const int buttonid);
	bool GetButtonText2Details(const int buttonid, TextInfo* textinfo);
	bool GetCheckBoxColor(const int checkboxid, Color* color);
	float GetCheckBoxGlowFactor(const int checkboxid);
	float GetCheckBoxSymbolGlowFactor(const int checkboxid);
	const char* GetCheckBoxSymbol(const int checkboxid);
	uint32_t GetCloseOnUnhandledClickFrames(int* result, uint32_t resultlen);
	int GetConfigSetting(const char*const setting);
	CursorInfo GetCurrentCursorInfo(void);
	bool GetDropDownColor(const int dropdownid, Color* color);
	float GetDropDownGlowFactor(const int dropdownid);
	float GetDropDownHighlightGlowFactor(const int dropdownid);
	float GetDropDownOptionGlowFactor(const int dropdownid);
	bool GetDropDownHighlightColor(const int dropdownid, Color* color);
	bool GetDropDownHotkeyDetails(const int dropdownid, HotkeyInfo* hotkeyinfo);
	bool GetDropDownIconDetails(const int dropdownid, DropDownIconInfo* iconinfo);
	bool GetDropDownOptionColor(const int dropdownid, Color* color);
	uint32_t GetDropDownOptionOverlayInfo(UIOverlayInfo2* result, uint32_t resultlen, const int dropdownid);
	uint32_t GetDropDownOptions2(DropDownOption2* result, uint32_t resultlen, const int dropdownid);
	uint32_t GetDropDownOptionHeight(const int dropdownid);
	uint32_t GetDropDownOptionWidth(const int dropdownid);
	const char* GetDropDownStartOption(const int dropdownid);
	bool GetDropDownTextDetails(const int dropdownid, DropDownTextInfo* textinfo);
	bool GetDropDownText2Details(const int dropdownid, DropDownTextInfo* textinfo);
	const char* GetEditBoxDefaultText(const int editboxid);
	const char* GetEditBoxDescription(const int editboxid);
	float GetEditBoxGlowFactor(const int editboxid);
	uint32_t GetEditBoxMaxChars(const int editboxid);
	float GetEditBoxTextGlowFactor(const int editboxid);
	uint32_t GetEditBoxTextOffsetX(const int editboxid);
	int32_t GetEditBoxTextOffsetY(const int editboxid);
	float GetFontStringGlowFactor(const int fontstringid);
	bool GetFontStringTitleColor(const int fontstringid, Color* color);
	float GetFontStringTitleGlowFactor(const int fontstringid);
	UIFrameTextureInfo GetFrameBackgroundInfo(const int frameid);
	UIFrameTextureInfo GetFrameBackground2Info(const int frameid);
	UIFrameTextureInfo GetFrameOverlayInfo(const int frameid);
	ResolutionInfo GetGameResolution(void);
	bool GetGraphBackgroundColor(const int graphid, Color* color);
	uint32_t GetGraphData2(GraphDataPoint2* result, uint32_t resultlen, const int graphid, const size_t datarecordidx);
	uint32_t GetGraphDataRecords(GraphDataRecord* result, uint32_t resultlen, int graphid);
	uint32_t GetGraphIcons(GraphIcon* result, uint32_t resultlen, int graphid);
	bool GetGraphTitle(const int graphid, GraphTextInfo* title);
	uint32_t GetGraphType(const int graphid);
	bool GetGraphXAxis(const int graphid, GraphAxisInfo* axis);
	bool GetGraphYAxis(const int graphid, GraphAxisInfo* axis);
	UIOverlayInfo2 GetHelpOverlayInfo2(const int widgetid);
	float GetIconGlowFactor(const int iconid);
	bool GetIconTextDetails(const int iconid, TextInfo* textinfo);
	bool GetIconText2Details(const int iconid, TextInfo* textinfo);
	const char* GetLocalizedText(const uint32_t pageid, uint32_t textid, const char*const defaultvalue);
	float GetMenuWidthScale(void);
	const char* GetMouseOverText(const int widgetid);
	const char* GetMouseOverTextAdditional(const int widgetid);
	uint32_t GetNumAllColorMapEntries(void);
	uint32_t GetNumCloseOnUnhandledClickFrames();
	uint32_t GetNumDropDownOptions(const int dropdownid);
	uint32_t GetNumGraphDataRecords(int graphid);
	uint32_t GetNumGraphIcons(int graphid);
	uint32_t GetNumTableInitialMultiselectedRows(const int tableid);
	uint32_t GetRenderTargetAlpha(const int rendertargetid);
	float GetShieldHullBarGlowFactor(const int shieldhullbarid);
	float GetShieldHullBarShieldPercent(const int shieldhullbarid);
	float GetShieldHullBarHullPercent(const int shieldhullbarid);
	int32_t GetSliderCellAccuracyOverride(const int slidercellid);
	bool GetSliderCellBackgroundColor(const int slidercellid, Color* color);
	bool GetSliderCellFont(const int slidercellid, Font* font);
	bool GetSliderCellInactiveBackgroundColor(const int slidercellid, Color* color);
	const char* GetSliderCellSuffix(const int slidercellid);
	const char* GetSliderCellText(const int slidercellid);
	bool GetSliderCellTextColor(const int slidercellid, Color* color);
	float GetSliderCellTextGlowFactor(const int slidercellid);
	bool GetSliderCellValueColor(const int slidercellid, Color* color);
	float GetSliderCellValueGlowFactor(const int slidercellid);
	bool GetSliderCellNegativeValueColor(const int slidercellid, Color* color);
	float GetSliderCellNegativeValueGlowFactor(const int slidercellid);
	bool GetSliderCellValues(const int slidercellid, SliderCellDetails* values);
	UIOverlayInfo2 GetStandardButtonHelpOverlayInfo2(const int frameid, const char* button);
	uint32_t GetStandardButtonOffsetX(const int frameid);
	uint32_t GetStandardButtonOffsetY(const int frameid);
	float GetStatusBarCurrentValue(const int statusbarid);
	float GetStatusBarMaxValue(const int statusbarid);
	float GetStatusBarStartValue(const int statusbarid);
	bool GetStatusBarTitleColor(const int statusbarid, Color* color);
	bool GetStatusBarValueColor(const int statusbarid, Color* color);
	bool GetStatusBarPosChangeColor(const int statusbarid, Color* color);
	bool GetStatusBarNegChangeColor(const int statusbarid, Color* color);
	bool GetStatusBarMarkerColor(const int statusbarid, Color* color);
	float GetStatusBarTitleGlowFactor(const int statusbarid);
	float GetStatusBarValueGlowFactor(const int statusbarid);
	float GetStatusBarPosChangeGlowFactor(const int statusbarid);
	float GetStatusBarNegChangeGlowFactor(const int statusbarid);
	float GetStatusBarMarkerGlowFactor(const int statusbarid);
	bool GetTableBackgroundColor(const int tableid, Color* color);
	const char* GetTableBackgroundID(const int tableid);
	uint32_t GetTableBackgroundPadding(const int tableid);
	const char* GetTableHighlightMode2(const int tableid);
	uint32_t GetTableInitialMultiselectedRows(uint32_t* result, uint32_t resultlen, const int tableid);
	TableSelectionInfo GetTableInitialSelectionInfo(const int tableid);
	int GetTableNextConnectedTable(const int tableid);
	int GetTablePreviousConnectedTable(const int tableid);
	int GetTableNextHorizontalConnectedTable(const int tableid);
	int GetTablePreviousHorizontalConnectedTable(const int tableid);
	float GetTextHeight(const char*const text, const char*const fontname, const float fontsize, const float wordwrapwidth);
	float GetTextWidth(const char*const text, const char*const fontname, const float fontsize);
	float GetUIScale(const bool scalewithresolution);
	Coord2D GetWidgetSystemSizeOverride(void);
	bool HasFrameBrackets(const int frameid);
	bool HasRenderTargetStartNoise(const int rendertargetid);
	bool HasStartAnimation(void);
	bool IsBoxTextWordWrap(const int boxtextid);
	bool IsCheckBoxActive(const int checkboxid);
	bool IsCheckBoxChecked(const int checkboxid);
	bool IsDropDownActive(const int dropdownid);
	bool IsDropDownMouseOverInteractionAllowed(const int dropdownid);
	bool IsEditBoxActive(const int editboxid);
	bool IsEditBoxInputEncrypted(const int editboxid);
	bool IsEditBoxTextHidden(const int editboxid);
	bool IsEditBoxTextSelectedOnActivation(const int editboxid);
	bool IsMiniWidgetSystemUsed(void);
	bool IsNextStartAnimationSkipped(bool reset);
	bool IsTableMultiSelect(const int tableid);
	bool IsTableRowBorderBelowEnabled(const int tableid, uint32_t row);
	bool IsTableRowInteractive(const int tableid, uint32_t row);
	bool IsTitleFontString(const int fontstringid);
	bool IsTitleStatusBar(const int statusbarid);
	bool SetActiveFrame(const int frameid);
	void SetCheckBoxChecked2(const int checkboxid, bool checked, bool update);
	void SetDropDownCurOption(const int dropdownid, const char* id);
	void SetEditBoxText(const int editboxid, const char* text);
	void SetFlowChartNodeSlider1Value(const int flowchartnodeid, double value);
	void SetFlowChartNodeSlider2Value(const int flowchartnodeid, double value);
	bool SetFrameInteractiveObject(const int frameid, const int objectid);
	void SetMouseCursorPosition(const int32_t posx, const int32_t posy);
	void SetMouseOverTextAdditional(const int widgetid, const char* text);
	void SetSliderCellMaxFactor(const int slidercellid, uint32_t maxfactor);
	void SetSliderCellValue(const int slidercellid, double value);
	void SetWidgetAssociatedElement(const int widgetid, bool value);
	bool ShouldEditBoxRestoreInteractiveObject(const int editboxid);
	bool ShouldRenderTargetBeCleared(const int rendertargetid);
	bool ShowGamepadTextInput(const char* description, uint32_t maxchars, const char* existingtext, bool multilines, bool password);
]]

local utf8 = require("utf8")

--- Wrapper ---

local origffistring = ffi.string
ffi.string = function(data) 
	if data ~= nil then
		return origffistring(data)
	else
		DebugError("Invalid parameter for ffi.string() in widget_fullscreen. Check caller!")
		DebugError(TraceBack())
		return ""
	end
end

__EGO_GLOBALS = {}

function MakeGlobalAvailable(objectname)
	__EGO_GLOBALS[objectname] = _G[objectname]
end

function AddGlobalAccess(funcname, functionimpl)
	_G[funcname] = functionimpl
	MakeGlobalAvailable(funcname)
end

function SetEGOGlobals(env)
	if env == nil then
		return
	end

	for funcname, functionimpl in pairs(__EGO_GLOBALS) do
		env[funcname] = functionimpl
	end
end

config = config or {}

-- settings for testing
config.glowfactors = {
	standardButtons = 0.5,
}

-- settings for boxWidth-calculations
-- #StefanLow - rethink this --- we might better read the real value (the one currently stored in the RenderPresentationHelper as NativePresentationWidth)
config.nativePresentationWidth = 880

config.frame = {
	-- #networkHigh - revert this to 6 layers again, once debugLog was integrated in chatWindow
	maxFrames    = 7,
	layerOffset  = 0.2,
	backgroundElements = { "backgroundTexture", "background2Texture", "overlayTexture" },
	backgroundElementTextures = {
		["backgroundTexture"]	= "backgroundtexture",
		["background2Texture"]	= "background2texture",
		["overlayTexture"]		= "overlaytexture",
	},
}

-- list of valid script handles
config.validScriptHandles = {
	"onButtonDown",
	"onButtonMouseOut",
	"onButtonMouseOver",
	"onButtonSelect",
	"onButtonUp",
	"onCheckBoxMouseOut",
	"onCheckBoxMouseOver",
	"onCheckBoxSelect",
	"onCombinedScrollDown",
	"onCombinedScrollUp",
	"onCursorChanged",
	"onDropDownActivated",
	"onDropDownConfirmed",
	"onDropDownMouseOut",
	"onDropDownMouseOver",
	"onDropDownRemoved",
	"onDropDownSelect",
	"onClick",
	"onColumnChanged",
	"onDoubleClick",
	"onEditBoxActivated",
	"onFlowchartNodeExpanded",
	"onFlowchartNodeCollapsed",
	"onFlowchartNodeSliderActivated",
	"onFlowchartNodeSliderChanged",
	"onFlowchartNodeSliderDeactivated",
	"onHide",
	"onInteractiveElementChanged",
	"onMouseDown",
	"onMouseUp",
	"onMiddleMouseDown",
	"onMiddleMouseUp",
	"onRightClick",
	"onRightMouseDown",
	"onRightMouseUp",
	"onRowChanged",
	"onScrollBarDown",
	"onScrollBarOver",
	"onScrollBarUp",
	"onScrollDown",
	"onScrollUp",
	"onSliderCellActivated",
	"onSliderCellChanged",
	"onSliderCellConfirm",
	"onSliderCellDeactivated",
	"onSliderCellDown",
	"onSliderCellRightOver",
	"onSliderCellRightDown",
	"onSliderCellLeftOver",
	"onSliderCellLeftDown",
	"onSliderCellSkipLeftOver",
	"onSliderCellSkipLeftDown",
	"onSliderCellSkipRightOver",
	"onSliderCellSkipRightDown",
	"onStandardButtonMouseOut",
	"onStandardButtonMouseOver",
	"onTableMouseOut",
	"onTableMouseOver",
	"onTextChanged",
	"onEditBoxDeactivated"
}

config.renderTargetTextureFilename = "ui\\widget\\presentations\\widget_fullscreen\\widget_fullscreen_recovered\\detail_monitor-rendertarget"

-- general (addon environment independent) settings
-- reenable when XT-2500 is fixed
config.verifyPixelExact = false -- indicates whether subpixel-checks are being performed which will issue warnings, if any element tries to use subpixel-positions which will end up in graphical artifacts (see XT-2174)

config.mouseScrollBarThreshold = 5 -- the threshold when using dragging to move the scrollbar in the table
                                   -- note that we have to use a threshold here - if we weren't we might get two successive position updates which differ just by 1 px which result in the table being scrolled twice
								   -- (first down by one row, then up by a row again or vice versa)
config.mouseSliderThreshold = 2 -- the threshold when using dragging to move the bar in the slider - see mouseScrollBarThreshold for further info

-- element dependent configs
config.frame.closeButtonRightOffset = 14 -- 6 px from the border, 8 px => half the texture width
config.frame.closeButtonUpperOffset = 10 -- 2 px from the border, 8 px => half the texture height
config.frame.standardButtonOffset = 2
config.frame.standardButtonWidth    = 16
config.frame.standardButtonOrder    = { "close", "back", "minimize", "help" }
config.frame.standardButtonTextSize = 14

config.boxtext = {
	maxElements = 40,                  -- number of maximal boxtext elements
	borderElements = {
		"border_left",
		"border_right",
		"border_down",
		"border_up",
	},
	borderSize = 3,
}
config.button = {
	-- #StefanMed - combine hotkey icon size with editbox-hotkey-icon size
	hotkeyIconSize = 19,          -- the size (in px) of the hotkey icon
	minButtonSize = 4,            -- the minimal button size (border element sizes (2*2) => 4 px)
	maxElements = 200,            -- number of maximal button elements
	scaleElements = {             -- list of button elements which are to be scaled according to the height/width of the button
		"background",
		"mousepick",
		"value",
		"value2",
	},
	unselectableDefaultTiling = 12 -- default tiling used for the unselectable button texture (based on a 100*100px button)
}
config.checkbox = {
	minCheckBoxSize = 4,              -- the minimal checkbox size (checkbox element sizes (2*2) => 4 px)
	maxElements = 100,                -- number of maximal checkbox elements
	scaleElements = {                 -- list of checkbox elements which are to be scaled according to the height/width of the checkbox
		{"background", 1},
		{"background_black", 0.65},
		{"mousepick", 1},
		{"circle", 0.7},
		{"arrow", 0.7},
	},
	unselectableDefaultTiling = 12    -- default tiling used for the unselectable checkbox texture (based on a 100*100px checkbox)
}
config.dropdown = {
	hotkeyIconSize = 19,              -- the size (in px) of the hotkey icon
	minDropDownSize = 4,              -- the minimal dropdown size (dropdown element sizes (2*2) => 4 px)
	optionSpacing = 3,
	removeOptionSize = 16,
	maxElements = 40,                 -- number of maximal dropdown elements
	maxElementsInit = 5,              -- number of dropdown elements initialized immediately on UI reload (initialization of remaining elements is deferred)
	initPrecedence = 1,               -- precedence for deferred initialization
	maxVisibleOptionsPerElement = 20,
	scaleElements = {                 -- list of dropdown elements which are to be scaled according to the height/width of the dropdown
		"background",
		"mousepick",
		"options_bg",
		"value",
		"value2",
	},
	borderElements = {
		"border_left",
		"border_right",
		"border_down",
	},
	borderSize = 3,
	unselectableDefaultTiling = 12,   -- default tiling used for the unselectable checkbox texture (based on a 100*100px dropdown)
}
config.editbox = {
	hotkeyIconSize = 19,          -- the size (in px) of the hotkey icon
	minEditBoxSize = 4,           -- the minimal editbox size (border element sizes (2*2) => 4 px)
	maxElements = 15,			  -- number of maximal editbox elements
	-- #StefanMed - if it stays like this: single scaleElement is better (no array)
	scaleElements = {             -- list of editbox elements which are to be scaled according to the height/width of the button
		{"background", 0},
		{"background_black", 3},
	},
	cursor = "|",
	cursorHeightFactor = 0.9,
	cursorWidth = 2,
	cursorOffsetX = 1,
	cursorBlinkInterval = 0.5,
	cursorSpeed = 30,
	cursorScrollDelay = 0.5,
	hiddenSymbol = "·",
}
config.graph = {
	maxElements = 1,               -- number of maximal graph elements
	maxTicksPerElement = 40,       -- number of ticks per graph element
	maxDataPointsPerElement = 200, -- number of data points per graph element
	maxIconsPerElement = 5,        -- number of icons per graph element
	axisWidth = 2,                 -- width of the axes
	border = 5,                    -- border between elements of the graph
	iconSize = 20,                 -- size of icons
	dataRecordOffsetZ = -0.004,    -- offset between individual datarecords
	selectionElements = {
		"axis1",
		"axis2",
		"box",
	},
}
config.icon = {
	maxElements = 150, -- number of maximal icon elements
	maxElementsInit = 20, -- number of icon elements initialized immediately on UI reload (initialization of remaining elements is deferred)
	numInitPerFrame = 5, -- number of icon elements initialized per frame during deferred initialization
	initPrecedence = 3, -- precedence for deferred initialization
}
config.miniWidgetsystem = {
	maxTables = 2,
	maxRows = 2
}
config.mouseOverText = {
	maxWidth = 225, -- max width of the mouse over text (so excluding border!)
	offsetX = 5,   -- offset from the mouse cursor
	borderSize = {
		right = 5,
		left = 5,
		top = 2,
		bottom = 3
	},
	fontsize = 9,    -- the fontsize in the native presentation size
}
config.shapes = {
	rectangle = {
		maxElements = 1000 -- number of maximal rectangles
	},
	circle = {
		maxElements = 100 -- number of maximal circles
	},
	triangle = {
		maxElements = 100 -- number of maximal triangles
	}
}
config.slider = {
	-- workaround for XRDEV-2172
	-- remove once properly fixed
	minScrollBarWidth = 59, -- scrollbarArrowLeft (12) + scrollbarSliderLeft (12) + scrollbarSliderDot (11) + scrollbarSliderRight (12) + scrollbarArrowRight (12)
	interval = { -- interval settings (values taken from X3)
		steps = { -- step intervals the slider will be increased when the button/key is held down
			       1,
				   2,
			       5,
			      10,
			      20,
			      50,
			     100,
			     500,
			    1000,
			    5000,
			   10000,
			   50000,
			  100000,
			  500000,
			 1000000,
			 5000000,
			10000000
		},
		initialStepDelay = 1,       -- delay (in s) before the intervalstep will be increased
		stepDelayIncrease = 0.2,	-- delay (in s) each following step increase will delay the next step delay
		maxStepDelay = 2,			-- delay (in s) the step increase will be delayed most
		initialTickDelay = 0.2,     -- delay (in s) at which the slider ticks (while keeping the key pressed down) for the first time
		reoccurrentTickDelay = 0.05 -- delay (in s) at which the slider ticks (while keeping the key pressed down) after having ticked the first time
	}
}
config.slidercell = {
	maxElements = 50, -- number of maximal slidercell elements
	minSliderCellWidth = 48, -- 4 * arrow (12px)
	minSliderCellHeight = 16, -- arrow (16px)
	minValueClickBorder = 4,
	arrowDimensions = {
		width = 12,
		height = 16
	},
	spacing = 5,
	cursor = "|",
	cursorBlinkInterval = 0.5,
	interval = { -- interval settings (values taken from X3)
		steps = { -- step intervals the slider will be increased when the button/key is held down
			       1,
			       5,
			      10,
			      20,
			      50,
			     100,
			     500,
			    1000,
			    5000,
			   10000,
			   50000,
			  100000,
			  500000,
			 1000000,
			 5000000,
			10000000
		},
		initialStepDelay = 1,       -- delay (in s) before the intervalstep will be increased
		stepDelayIncrease = 0.2,	-- delay (in s) each following step increase will delay the next step delay
		maxStepDelay = 2,			-- delay (in s) the step increase will be delayed most
		initialTickDelay = 0.2,     -- delay (in s) at which the slider ticks (while keeping the key pressed down) for the first time
		reoccurrentTickDelay = 0.05 -- delay (in s) at which the slider ticks (while keeping the key pressed down) after having ticked the first time
	},
	max = 10^12,
	min = -10^12
}
config.tableRows = {
	maxCols = 13, -- when changing this number, update the corresponding value in UI::Widget::WidgetConfig::MaxTableCols as well
	maxRows = 170, -- when changing this number, update the corresponding value in UI::Widget::WidgetConfig::MaxTableRows as well
	maxRowsInit = 20, -- number of rows initialized immediately on UI reload (initialization of remaining rows is deferred)
	initPrecedence = 2, -- precedence for deferred initialization
}
config.table = {
	maxTables = 21, -- the number of max available tables (currently reached in map: 6 in main frame, 3 in info frame, 7 in context frame, 2 in the chat window, 1 in the helptext, 2 in the debuglog)
	bordersize = 3,
	titleLineHeight = 3,
	spaceafterheader = 20,
	minScrollBarHeight = 35, -- scrollbarSliderTop (12) + scrollbarSliderBottom (12) + scrollbarSliderDot (11)
	borderElements = { "top", "bottom", "left", "right" }
}
config.shieldhullbar = {
	maxElements = 50 -- max number of bar elements
}
config.statusbar = {
	maxElements = 120, -- max number of bar elements
	markerWidth = 4,
}
config.flowchart = {
	-- allocation limits
	maxFlowcharts = 1,
	maxCols = 30,
	maxNodes = 100,
	maxEdges = 150,
	-- sizes
	horizBorderSize = 5,           -- border size at top and bottom
	nodePaddingHoriz = 10,
	nodePaddingVert = 10,
	-- Anark model metadata
	borderData = {
		[1] = { name = "leftBorder", direction = -1, xscalefactor = 1 },
		[2] = { name = "rightBorder", direction = 1, xscalefactor = -1 }	-- mirrored horizontally
	},
	borderShapeData = {
		[1] = { slide = "rectangle", groupprefix = "lso_rectangle", sideModel = "lso_rectangl", cornerModel = "lso_rectangl", hasExpandGroups = false, baseWidth = 30 },
		[2] = { slide = "stadium",   groupprefix = "lso_circle",    sideModel = "lso_circle_s", cornerModel = "lso_circle_c", hasExpandGroups = true,  baseWidth = 30 },
		[3] = { slide = "hexagon",   groupprefix = "lso_triangle",  sideModel = "lso_triangle", cornerModel = "lso_triangle", hasExpandGroups = true,  baseWidth = 30 },
	},
	slotXOffsetFactors = {
		input = -1,		-- left
		output = 1		-- right
	},
	slotYOffsetFactors = {
		[1] = -1,		-- top
		[2] = 0,		-- center
		[3] = 1			-- bottom
	},
	baseModelHeight = 60,
	baseModelMiddleWidth = 10,
	baseModelOutlineSize = 2.5,
	baseModelConnectorSize = 20,
	baseModelExpandArrowSize = 32,
	baseModelTriangleWidth = 17.3,
	baseModelTriangleHeight = 15,
	barOutlineModelName = "lso_middle_outline.lso_middle_o",
	barFillModelName = "lso_middle_fill.lso_middle_f",
	connectorModelName = "lso_circle.lso_circle",
	expandMouseOverScaleFactor = 1.3,
	expandFramePadding = 2,
}
config.helpoverlay = {
	maxElements = 25,
	borderElements = {
		"border_left",
		"border_right",
		"border_bottom",
		"border_top",
	},
	borderSize = 3,
	iconsize = 38,
	iconToSizeRatio = 98 / 128,
	animationFrequency = 4,
	animationMinValue = 0.1,
	animationMaxValue = 1.0,
}
-- #StefanLow - in principle we'd no longer require table.bar.xxx here (it was historically used when we relied on a texture for the cell background using a transparent edge). Ever since
-- we changed it to a plain solid texture, we'd no longer require these values (and the related calculations - if removing these, the scale-factor in the Anark presentation of table_cell.middle needs to
-- be modified as well)
config.texturesizes = {
	button = {
		borderSize = 2, -- thickness of the button's border line elements in px
	},
	checkbox = {
		borderSize = 2, -- thickness of the checkbox's border line elements in px
	},
	dropdown = {
		borderSize = 2, -- thickness of the dropdown's border line elements in px
	},
	editbox = {
		borderSize = 2, -- thickness of the editbox's border line elements in px
	},
	table = {
		scrollBar = {
			borderElementHeight       = 16, -- height of the upper and lower scrollbar border elements
			sliderBorderElementHeight = 12, -- height of the upper and lower border elements in the slider element of the scrollbar
			sliderCenterElementHeight = 12, -- height of the center part of the slider element in the scrollbar
			width                     = 16  -- width of the scrollbar
		}
	}
}
config.startAnimation = {
	duration      = 0.35,    -- in seconds
	speedFactor   = 0.5,     -- speed factor between first (x expanding) and second (y expanding) part of animation
	initialHeight = 0.008333 -- initial height during first part
}

-- global color lookup
Color = {}
MakeGlobalAvailable("Color")
ColorText = {}
MakeGlobalAvailable("ColorText")

local colorMetatable = {
	__index = function(table, key)
		DebugError(string.format("Color setup error: Tried to access non-existing color '%s'\n\n%s", tostring(key), TraceBack()))
		return { r = 255, g = 0, b = 255, a = 60, glow = 0 }
	end
}
setmetatable(Color, colorMetatable)

local colorTextMetatable = {
	__index = function(table, key)
		DebugError(string.format("Color setup error: Tried to access non-existing color '%s'\n\n%s", tostring(key), TraceBack()))
		return ""
	end
}
setmetatable(ColorText, colorTextMetatable)

-- text array containing localized text
local L = {
	[","] = ffi.string(C.GetLocalizedText(1001, 106, ",")),
	["."] = ffi.string(C.GetLocalizedText(1001, 105, ".")),
	["k"] = ffi.string(C.GetLocalizedText(1001, 300, "k")),
	["M"] = ffi.string(C.GetLocalizedText(1001, 301, "M")),
	["time"] = ffi.string(C.GetLocalizedText(1001, 5500, "time")),
	["%h h %M"] = ffi.string(C.GetLocalizedText(1001, 203, "%h h %M")),
	["slidercell_skip_left"] = ffi.string(C.GetLocalizedText(1026, 5501, "Set left limit.")),
	["slidercell_skip_left_min"] = ffi.string(C.GetLocalizedText(1026, 5502, "Set left limit (minimum).")),
	["slidercell_skip_left_max"] = ffi.string(C.GetLocalizedText(1026, 5503, "Set left limit (maximum).")),
	["slidercell_skip_right"] = ffi.string(C.GetLocalizedText(1026, 5504, "Set right limit.")),
	["slidercell_skip_right_min"] = ffi.string(C.GetLocalizedText(1026, 5505, "Set right limit (minimum).")),
	["slidercell_skip_right_max"] = ffi.string(C.GetLocalizedText(1026, 5506, "Set right limit (maximum).")),
}

-- private member data
local private = {
	-- addon-system-related
	updateScripts = {}, -- functions for update scripts
	hotkeyScripts = {}, -- functions for hotkey scripts
	tabscrollScripts = {}, -- functions for tabscroll scripts
	eventScripts  = {	-- functions for event scripts
		-- [eventname] = {
			-- function
		-- }
	},
	widgetEventScripts = { -- functions for widget event scripts
		-- [widget] = {
			-- [eventname] = {
				-- function
			-- }
		-- }
	},

	-- widget related
	contract      = nil, -- the contract element, receiving Anark events
	anchorElement = nil, -- the anchor element
	master = {		-- all the master elements of the VISIBLE Anark elements, see widgetSystem.initializeMasterElements()
		-- background,
		-- backgroundTexture,
		-- icon,
		-- overlayTexture,
		-- renderTarget,
		-- shieldhullbar,
		-- statusbar,
		table = {	-- master elements for tables
			-- header,
			-- cell,
			-- scrollBar
		},
		miniWidgetSystem = {	-- master elements for the mini widgetsystem
			table = {},
			-- backgroundTexture,
			-- frame_bracket,
			-- overlayTexture,
			-- standardbuttons
		},
	},
	sceneState = {
		-- widgetsystem     = true|false
		-- shapes           = true|false
		-- miniwidgetsystem = true|false
		-- starteffect      = true|false
	},
	elementInit = {
		-- [element] = {
			-- initializer					= initialization function
			-- totalCount					= total number of elements to be initialized
			-- numInitialized				= number of elements that have already been initialized
			-- numInitPerFrame				= number of elements to be initialized per frame after startup
		--}
	},
	elementInitOrder = {
		-- [1] = element, ...
	},
	element = {		-- the visible Anark elements
		tableRows = {
			-- [row] = { -- the used anark row element [1..config.tableRows.maxRows]
				-- [col] = {
					-- element         = cell element (Anark element: table_cell)
				-- }
			-- }
		},
		table = {
			-- [tableindex] = {
				-- header                  = header element
				-- headerText              = header text element
				-- numCols                 = number of columns
				-- numFixedRows            = number of fixed rows
				-- numRows                 = number of rows (i.e. not necessarily the number of displayed columns)
				-- highlightedRows         = current highlighted row number (starts with 1, nil indicates currently no highlighted row)
				-- curRow                  = current selected row number (starts with 1, 0 indicates no selectable rows at all)
				-- topRow                  = row number of the row visible on top (just below the fixed rows, if any)
				-- bottomRow               = row number of the row visible on bottom
				-- topBottomRow            = visible bottom row when the table is at its top position
				-- height                  = height of the table (i.e. max table height excluding table header)
				-- nonFixedSectionHeihgt   = height of the table section covering the non-fixed rows (equals height, if numFixedRows = 0)
				-- offsety                 = offset where the table cells start (i.e. tableoffset - tableheader height)
				-- borderEnabled           = indicates whether the table has a border or not
				-- wrapAround              = indicates whether the table is wrapping around when going up/down past the last row
				-- highlightMode           = indicates how the table selection will be highlighted
				-- granularity             = value each step of the scrollbar the value will be changed
				-- firstSelectableFixedRow = first selectable fixed row in the fixed row section (0, if no selectable fixed row at all or no fixed rows at all)
				-- normalSelectedRow       = the selected row in the normal (aka: non fixed row) section
				-- interactiveRegion       = "normal"|"fixed" - indictes the region the table selection is currently in
				-- interactiveChild = { -- information about the interactive child in the table (if there is one - nil otherwise)
					-- [row]      = the row of the interactive element
					-- [col]      = the column of the interactive element
					-- [element]  = the interactive element (can be nil, if the interactive element is not displayed atm)
					-- [widgetID] = the widgetID of the interactive child
				-- }
				-- cellposx = {
					-- [col] = x cell position offset
				-- }
				-- fixedRowCellposx = {
					-- [col] = x cell position offset
				-- }
				-- columnWidths = {
					-- [col] = column width
				-- }
				-- fixedRowColumnWidths = {
					-- [col] = column width
				-- }
				-- unselectableRows = {
					-- [row] = true -- list of unselectable rows
				-- }
				-- cell = {
					-- [row] = { -- the used anark row element [1..tableElement.displayedRows]
						-- [realRow] = the real table row [1..tableElement.numRows]
						-- [col] = {
							-- element = cell element (Anark element: table_cell)
							-- active  = true|false - indicates whether the cell has been activated
							-- icon    = iconelement in that cell (if any)
							-- button  = {       = button in that cell (if any)
								-- element       = buttonelement
								-- active        = whether the button element is active
								-- previouslyActive = whether the button element was active during the previous state update
								-- color = {     = button color value
									-- r         = red color value
									-- g         = green color value
									-- b         = blue color value
									-- a         = alpha value (defaults to 1)
								-- }
								-- iconColor = { = icon color value
									-- r         = red color value
									-- g         = green color value
									-- b         = blue color value
									-- a         = alpha value (defaults to 1)
								-- }
								-- iconID        = icon ID
								-- swapIconID    = swap icon ID (if any)
								-- icon2Color = {= icon color value
									-- r         = red color value
									-- g         = green color value
									-- b         = blue color value
									-- a         = alpha value (defaults to 1)
								-- }
								-- icon2ID       = icon ID
								-- swapIcon2ID   = swap icon ID (if any)
								-- buttonState = {
									-- mouseClick       = true|false - indicates whether the mouse is currently clicked on the button
									-- mouseOver        = true|false - indicates whether the mouse is currently hovering over the button
									-- keyboard         = true|false - indicates whether the keyboard/gamepad has currently selected the button
									-- keyboardPress    = true|false - indicates whether the keyboard/gamepad has currently selected the button and is pressing the ENTER/A button
								-- }
							-- }
							-- checkbox = {  = checkbox in that cell (if any)
								-- element   = checkboxElement
								-- active    = whether the checkbox element is active
								-- previouslyActive = whether the checkbox element was active during the previous state update
								-- checked   = whether the checkbox element is checked
								-- color = { = checkboc color value
									-- r     = red color value
									-- g     = green color value
									-- b     = blue color value
									-- a     = alpha value (detaults to 1)
								-- }
								-- checkboxState = {
									-- mouseClick       = true|false - indicates whether the mouse is currently clicked on the checkbox
									-- mouseOver        = true|false - indicates whether the mouse is currently hovering over the checkbox
									-- keyboard         = true|false - indicates whether the keyboard/gamepad has currently selected the checkbox
									-- keyboardPress    = true|false - indicates whether the keyboard/gamepad has currently selected the checkbox and is pressing the ENTER/A button
								-- }
							-- }
							-- dropdown = {      = dropdown in that cell (if any)
								-- element       = dropdownelement
								-- active        = whether the dropdown element is active
								-- previouslyActive = whether the dropdown element was active during the previous state update
								-- color = {     = dropdown color value
									-- r         = red color value
									-- g         = green color value
									-- b         = blue color value
									-- a         = alpha value (defaults to 1)
								-- }
								-- iconColor = { = icon color value
									-- r         = red color value
									-- g         = green color value
									-- b         = blue color value
									-- a         = alpha value (defaults to 1)
								-- }
								-- dropdownState = {
									-- mouseClick       = true|false - indicates whether the mouse is currently clicked on the dropdown
									-- mouseOver        = true|false - indicates whether the mouse is currently hovering over the dropdown
									-- keyboard         = true|false - indicates whether the keyboard/gamepad has currently selected the dropdown
									-- keyboardPress    = true|false - indicates whether the keyboard/gamepad has currently selected the dropdown and is pressing the ENTER/A button
								-- }
							-- }
							-- editbox = {              = editbox in that cell (if any)
								-- element              = editboxelement
								-- active               = whether the editbox element is in active input mode
								-- text                 = current editbox text
								-- oldtext              = editbox text before editbox was activated
								-- hotkeyIconActive     = does the editbox display the hotkey icon
								-- color = {            = editbox color value
									-- r                = red color value
									-- g                = green color value
									-- b                = blue color value
									-- a                = alpha value (defaults to 1)
								-- }
								-- cursor               = is the cursor displayed atm
								-- lastcursorupdatetime = real time, cursor was last changed
								-- closeMenuOnBack      = does the "Back" action close the menu or reset the editbox
								-- textOffsetX          = the offset used for the text element
								-- textAlignment        = the alignment used for the text element
								-- cursorWidth          = the width in px of the cursor given the editbox's fontsize
								-- width                = the width in px of the editbox
								-- font                 = the font of the editbox
								-- fontsize             = the font size of the editbox
							-- }
							-- graph = {
								-- element = {           = graph Anark elements
									-- mainElement       = main graph anark element
									-- tickElements      = tick anark elements
									-- dataPointElements = datapoint anark elements
									-- iconElements      = icon anark elements
								-- }
							-- }
							-- slidercell = {           = slidercell in that cell (if any)
								-- element              = slidercellelement
									-- main				= main element
									-- arrow_left		= arrow left
									-- arrow_right		= arrow right
									-- arrow_skip_left	= arrow left
									-- arrow_skip_right	= arrow right
									-- sliderArrowState = { = state of the arrows
										-- left = {         = left arrow
											-- element      = left arrow element
											-- curSlide     = current slide
											-- mouseOver    = is mouse over arrow?
											-- mouseDown    = is mouse down on arrow?
										-- },
										-- right = {        = right arrow
											-- element      = right arrow element
											-- curSlide     = current slide
											-- mouseOver    = is mouse over arrow?
											-- mouseDown    = is mouse down on arrow?
										-- }
									-- }
								-- width                = slidercell width
								-- height               = slidercell height
								-- offsetx              = slidercell offsetx
								-- offsety              = slidercell offsety
								-- fontname             = font name
								-- fontsize             = font size
								-- text                 = slidercell text
								-- textcolor            = slidercell text color
									-- r                = red color value
									-- g                = green color value
									-- b                = blue color value
									-- a                = alpha value
								-- bgcolor              = slidercell background color
									-- r                = red color value
									-- g                = green color value
									-- b                = blue color value
									-- a                = alpha value
								-- valuecolor           = slidercell value color
									-- r                = red color value
									-- g                = green color value
									-- b                = blue color value
									-- a                = alpha value
								-- negativevaluecolor   = slidercell value color for negative values
									-- r                = red color value
									-- g                = green color value
									-- b                = blue color value
									-- a                = alpha value
								-- min                  = slidercell min value
								-- max                  = slidercell max value
								-- exceedmax            = allows player to exceed the max value (requires min >= 0). It will not be displayed but only used for the visuals of the bar
								-- maxfactor            = factor increasing the display ange if exceedmax is true
								-- start                = slidercell start value
								-- step                 = slidercell step size
								-- accuracy             = number format accuracy calculated from step
								-- powaccuracy          = 10^accuracy
								-- cur                  = slidercell current value
								-- oldcur               = slidercell current value backup during input
								-- suffix               = slidercell value suffix
								-- inputActive          = slidercell currently active for input
								-- cursor               = whether the input cursor is currently shown
								-- lastcursorupdatetime = when the cursor display was changed the last time
							-- }
							-- shieldhullbar   = shield/hull bar element in that cell (if any)
							-- statusbar       = status bar element in that cell (if any)
			  			-- }
					-- }
				-- }
				-- scrollBar = {
					-- element          = scrollbar Anark element
					-- sliderElement    = scrollbar slider Anark element
					-- sliderHeight     = height of the scrollbar (i.e. the moving element, not the entire size of the scrollbar, which equals the table height)
					-- height           = height of the entire scrollbar
					-- active           = indicates whether table has a scrollbar
					-- dragOffset       = the relative y-offset between the position of the mouse-cursor on the scrollbar and the scrollbar's center when the scrollbar was clicked on
					-- previousMousePos = the mouse y-position of the previous update-call for the scrollBar update (nil, on first call)
					-- sliderState = {
						-- mouseClick = true|false - indicates whether the mouse is currently clicked on the slider
						-- mouseOver  = true|false - indicates whether the mouse is currently hovering over the slider
						-- curSlide   = string     - current slide of the scrollBar
					-- }
				-- }
				-- mousePick = {
					-- element          = mousepick Anark element
					-- state = {
						-- mouseOver = {
							-- state = true|false - indicates whether the mouse is currently hovering over the table
							-- original = true|false|nil - stores orignal state when state is updated, to be processed in onUpdate() call
							-- row = integer|nil - stores row the mouse is hovering over, if information was available
						-- }
					-- }
				-- }
			-- }
		},
		boxtext = {
			-- [boxtextindex] = boxtextElement
		},
		button = {
			-- [buttonindex] = buttonElement
		},
		checkbox = {
			-- [checkboxindex] = checkboxElement
		},
		dropdown = {
			-- [dropdownindex] = dropdownElement
		},
		editbox = {
			-- [editboxindex] = editboxElement
		},
		flowchart = {
			-- [flowchartindex] = {
				-- ... see widgetSystem.initializeFlowchartElements()
			-- }
		},
		flowchartEdge = {
			-- [flowchartedgeindex] = flowchartEdgeElement
		},
		flowchartNode = {
			-- [flowchartnodeindex] = {
				-- main                         = flowchartNodeElement -- the Anark element
				-- mousepick                    = mousepickElement
				-- leftBorder                   = leftBorderElement
				-- rightBorder                  = rightBorderElement
				-- expand                       = expandElement
				-- status                       = statusElement
				-- connectors                   = connectorsElement
				-- bar1SliderMousepick          = mousepick element of bar1 slider (not necessarily slider1)
				-- bar2SliderMousepick          = mousepick element of bar2 slider (not necessarily slider2)
				-- barData = {
					-- [idx] = {
						-- element              = bar element
						-- sliderMousepick      = mousepick element of bar slider, or nil if no slider supported
						-- assignedSliderIndex  = index in sliderStates table if assigned, otherwise nil
					-- }
				-- }
				-- sliderStates = {
					-- [idx] = {
						-- barIndex             = index in barData if assigned, otherwise nil
						-- mouseDown            = is mouse down on slider?
						-- mouseOver            = is mouse over slider?
					-- }
				-- }
				-- cell                         = associated node or junction data
				-- currentFrameLayer            = layer of flowchart node, used to determine offset of expandedFrameLayer
				-- expandedFrameLayer           = layer of some sub-elements of the node for expanded frame, different from main layer if node is expanded
			-- }
		},
		graph = {
			-- [graphindex] = graphElement
		},
		helpoverlay = {
			-- [helpoverlayindex] = helpoverlayElement
		},
		icon = {
			-- [iconindex] = iconElement
		},
		slidercell = {
			-- [slidercellindex] = slidercellElement
		},
		shieldhullbar = {
			-- [shieldhullbarindex] = shieldHullBarElement
		},
		statusbar = {
			-- [statusbarindex] = statusBarElement
		},
		renderTarget = {
			-- [element] = renderTarget component element
			-- [modelElement] = renderTarget (model) element
			-- [textureString]  = renderTarget texture filename
		},
		shapes = {
			rectangle = {
				-- [rectangleindex] = rectangleElement
			},
			circle = {
				-- [circleindex] = circleElement
			},
			triangle = {
				-- [triangleindex] = triangleElement
			}
		},
		miniWidgetSystem = { -- elements in the mini widgetsyste
			frames = {},
			tableRows = {},
			table = {},
			boxtext = {},
			button = {},
			checkbox = {},
			dropdown = {},
			editbox = {},
			graph = {},
			icon = {},
			progress = {},
			slidercell = {},
			shieldhullbar = {},
			statusbar = {},
			renderTarget = {},
		},
	},
	frames = {      -- the currently active frames (if any)
		-- [frameindex] = {
			-- frame = frame
			-- layer = number,     -- the layer of the frame
			-- tables = {},        -- tables in this frame
			-- rendertargets = {}, -- rendertargets in this frame
			-- flowcharts = {},    -- flowcharts in this frame
			-- offsetx    = nil,	-- xoffset of the frame
			-- offsety    = nil,	-- yoffset of the frame
			-- height     = nil,	-- height of the frame
			-- width      = nil,	-- width of the frame
			-- standardButtons
			-- backElement
			-- closeElement
			-- backButtonShown = false,      -- indicates whether the back button is shown on the frame
			-- closeButtonShown = false,     -- indicates whether the close button is shown on the frame
			-- standardButtonState = {
				-- ["back"] = {
					-- ["mouseClick"] = false, -- indicates whether the mouse is clicked on the button
					-- ["mouseOver"]  = false, -- indicates whether the mouse is over the button
					-- ["curSlide"]   = ""     -- the current slide the button is set to
				-- },
				-- ["close"] = {
					-- ["mouseClick"] = false, -- indicates whether the mouse is clicked on the button
					-- ["mouseOver"]  = false, -- indicates whether the mouse is over the button
					-- ["curSlide"]   = ""     -- the current slide the button is set to
				-- }
			-- },
			-- backgroundTextureData = {
				-- active = false,				-- whether the background texture is active
				-- rotationRate = nil,			-- whether the background texture rotates
				-- rotationStart = nil,
				-- rotationEnd = nil,
				-- rotationDuration = nil,
				-- rotationInterval = nil,
				-- rotationStartTime = nil,
				-- initScale = nil,				-- whether the background texture has an initial scale animation
				-- scaleDuration = nil,
				-- scaleStartTime = nil,
				-- origScale = {},
				-- quadraticFactor = nil,
				-- linearFactor = nil,
			-- },
			-- background2TextureData = { ... },
			-- overlayTextureData = { ... },
		-- }
	},
	activeframe = nil,  -- currently active frame
	offsetx     = nil,	-- xoffset of the entire view
	offsety     = nil,	-- yoffset of the entire view
	height      = nil,	-- height of the entire view
	width       = nil,	-- width of the entire view
	fontHeight  = {		-- memoized fontheights for fontname/fontsize combinations
		-- [fontname] = {
			-- [fontzise] = fontheight
		-- }
	},
	-- #StefanMed - documetnation is misleading - Anark element -- it's actually the tableElement in case of tablechild (button, editbox, for instance)
	associationList = {	-- association list of widgetIDs (key) with the Anark element
		-- [widgetID] = { -- the actual widget ID
			-- #StefanMed clean this up... (special case for button handling is no good)
			-- element     = associated Anark element (ref of private.element entry) - note in case of buttons, this is the buttonElement (table) with element.element being the Anark element
			-- parentx     = parent offset (x)
			-- parenty     = parent offset (y)
			-- parentwidth = parent width
		-- }
	},
	activeEditBox = nil, -- {
		-- editboxID      = widgetID of the editbox,
		-- editboxElement = reference to table[x].cell[row][col].editbox
	-- },
	activeSliderCell = nil, -- {
		-- widgetID      = widgetID of the slidercell,
		-- element       = reference to table[x].cell[row][col].slidercell
	-- },
	nextTickTime = nil,         -- time at which the scrolling will tick next
	nextStepIncreaseTime = nil, -- time at which the scrolling step will be increased next
	scrolling = nil,            -- nil|"left"|"right"
	scrollingElement = nil,     -- the element which is assigned to be scrolled
	curScrollingStep = nil,     -- the step per tick for scrolling
	numStepIncreases = 0,       -- number of step increases for scrolling
	interactiveElement = {      -- the current interactive element, if any
		-- [element]  = reference to private.element entry
		-- [widgetID] = the widgetID of the interactive element
	},
	oldInteractiveElement = {   -- store interactive element, while editbox is active
		-- [element]  = reference to private.element entry
		-- [widgetID] = the widgetID of the previously interactive element
	},
	sliderBarState = {
		["mouseClick"] = false,     -- indicates whether the mouse is clicked on the bar
		["mouseOver"]  = false,     -- indicates whether the mouse is over the arrow
		["curSlide"]   = "inactive" -- the current slide, the bar is displayed in
	},
	-- #StefanMed move to table scrollbar
	scrollBarDrag = nil,          -- the scrollbar which is dragged atm (if any)
	slidercellDrag = nil,         -- indicates whether the slidercell is being dragged and stores the drag properties
	dropDownScrollBarDrag = nil,  -- stores drag properties of currently dragged dropdown scrollbar
	flowchartScrollBarDrag = nil, -- stores drag properties of currently dragged flowchart scrollbar
	flowchartNodeSliderDrag = nil,    -- stores drag properties of the currently dragged flowchartnode slider
	onHideRisen = false,          -- indicates whether onHide was already risen
	pendingFrames = {},           -- the frames which are pending to be displayed
	viewDisplayed = false,
	startAnimationDisplayed = false,
	mouseOverText = nil,              -- indicates an active mouse over text and stores its properties
	-- {
		-- widgetID                   -- associated widget
		-- count                      -- count nested elements registered for mouse, to we don't hide mouse over text if we leave one of the nested elements
		-- width                      -- the total width of the mouse over text
		-- height                     -- the total height of the mouse over text
		-- cursorinfo = CursorInfo    -- information about the mouse cursor at the time the mouse over text is set up
		-- overrideText               -- current override text used instead of the text associated with the widgetID
	-- }
	mouseOverOverrideText = nil,
	drawnShapes = {
		rectangles = {},              -- list of all drawn rectangles
		circles = {},                 -- list of all drawn circles
		triangles = {}                -- list of all drawn triangles
	},
	shapesActivated = false,
	queuedShapes = {},
	miniWidgetSystemUsed = false,
	currentMouseAnarkElement = nil,
	currentMouseWidgetElementLimbo = {},
	helpOverlays = {},
	displayedHelpOverlays = {},
	signalledHelpOverlays = {},
	helpOverlayStates = {},
	uiscale = 1.0,
}

-- addon-system-related
-- note: we encapsulate the addon system related functions, to work around the max 200 local variables limit in Lua (we have more than 200 functions in this file)
local addonSystem = {}

-- widget-system-related
-- note: we encapsulate the widget system related functions, to work around the max 200 local variables limit in Lua (we have more than 200 functions in this file)
-- #StefanMed reorganize config and private settings to be also system dependent
local widgetSystem = {}

---------------------------------
-- Gameface lifetime functions --
---------------------------------
function self:onInitialize()
	 widgetSystem.prepareSize()
	 widgetSystem.getColors()

	-- initialize private data
	private.scene            = getElement("Scene")
	private.contract         = getElement("UIContract", private.scene)
	private.anchorElement    = getElement("Layer.ui_anchor", private.scene)
	private.widgetsystem     = getElement("widgetsystem", private.anchorElement)
	private.miniwidgetsystem = getElement("miniwidgetsystem", private.anchorElement)
	private.shapes           = getElement("shapes", private.anchorElement)
	private.starteffect      = getElement("starteffect", private.anchorElement)
	setAttribute(private.starteffect, "scale.x", private.width / 100)
	setAttribute(private.starteffect, "scale.y", private.height / 100)
	widgetSystem.setElementColorAlpha(getElement("Material418", private.starteffect), Color["menu_start_animation"])

	local mouseoverelement = getElement("popupmenu", private.widgetsystem)
	setAttribute(mouseoverelement, "position.z", getAttribute(mouseoverelement, "position.z") - config.frame.layerOffset)

	widgetSystem.initializeMasterElements()
	widgetSystem.initializeFrameElements()
	widgetSystem.initializeBoxTextElements()
	widgetSystem.initializeButtonElements()
	widgetSystem.initializeCheckBoxElements()
	widgetSystem.initializeDropDownElements()
	widgetSystem.initializeEditBoxElements()
	widgetSystem.initializeFlowchartElements()
	widgetSystem.initializeGraphElements()
	widgetSystem.initializeHelpOverlayElements()
	widgetSystem.initializeIconElements()
	widgetSystem.initializeMiniWidgetSystemElements()
	widgetSystem.initializeShapeElements()
	widgetSystem.initializeRenderTarget()
	widgetSystem.initializeSliderCellElements()
	widgetSystem.initializeShieldHullBarElements()
	widgetSystem.initializeStatusBarElements()
	widgetSystem.initializeTableElements()
	widgetSystem.initializeTableRowElements()

	table.sort(private.elementInitOrder, function(a, b) return private.elementInit[a].precedence < private.elementInit[b].precedence end)

	-- register for events
	registerForEvent("boxtextupdate", private.contract, widgetSystem.onBoxTextUpdate)
	registerForEvent("buttonupdate", private.contract, widgetSystem.onButtonUpdate)
	registerForEvent("back", private.contract, widgetSystem.onBack)
	registerForEvent("checkboxupdate", private.contract, widgetSystem.onCheckBoxUpdate)
	registerForEvent("close", private.contract, widgetSystem.onClose)
	registerForEvent("autoclose", private.contract, widgetSystem.onAutoClose)
	registerForEvent("copy", private.contract, widgetSystem.onCopy)
	registerForEvent("ctrlmovedown", private.contract, function (...) return widgetSystem.onMoveDown("ctrl", ...) end)
	registerForEvent("ctrlmoveup", private.contract, function (...) return widgetSystem.onMoveUp("ctrl", ...) end)
	registerForEvent("ctrlspace", private.contract, function (...) return widgetSystem.onSpace("ctrl", ...) end)
	registerForEvent("cut", private.contract, widgetSystem.onCut)
	registerForEvent("directtextinput", private.contract, widgetSystem.onDirectTextInput)
	registerForEvent("dropdownupdate", private.contract, widgetSystem.onDropDownUpdate)
	registerForEvent("editboxtab", private.contract, widgetSystem.onEditBoxTab)
	registerForEvent("editboxupdate", private.contract, widgetSystem.onEditBoxUpdate)
	registerForEvent("end", private.contract, function (...) return widgetSystem.onEnd(nil, ...) end)
	registerForEvent("flowchartedgeupdate", private.contract, widgetSystem.onFlowchartEdgeUpdate)
	registerForEvent("flowchartnodeupdate", private.contract, widgetSystem.onFlowchartNodeUpdate)
	registerForEvent("frameclose", private.contract, widgetSystem.onFrameClose)
	registerForEvent("frameminimize", private.contract, widgetSystem.onFrameMinimize)
	registerForEvent("frameupdate", private.contract, widgetSystem.onFrameUpdate)
	registerForEvent("fontstringupdate", private.contract, widgetSystem.onFontStringUpdate)
	registerForEvent("gamepadTextInputCancelled", private.contract, widgetSystem.onGamepadTextInputCancelled)
	registerForEvent("gamepadTextInputEntered", private.contract, widgetSystem.onGamepadTextInputEntered)
	registerForEvent("genericEvent", private.contract, widgetSystem.onEvent)
	registerForEvent("home", private.contract, function (...) return widgetSystem.onHome(nil, ...) end)
	registerForEvent("iconupdate", private.contract, widgetSystem.onIconUpdate)
	registerForEvent("inputModeChanged", private.contract, widgetSystem.onInputModeChanged)
	registerForEvent("selectall", private.contract, widgetSystem.onSelectAll)
	registerForEvent("shiftend", private.contract, function (...) return widgetSystem.onEnd("shift", ...) end)
	registerForEvent("shifthome", private.contract, function (...) return widgetSystem.onHome("shift", ...) end)
	registerForEvent("startscrollleft", private.contract, function (...) return widgetSystem.onStartScrollLeft(nil, ...) end)
	registerForEvent("stopscrollleft", private.contract, function (...) return widgetSystem.onStopScrollLeft(nil, ...) end)
	registerForEvent("startctrlscrollleft", private.contract, function (...) return widgetSystem.onStartScrollLeft("ctrl", ...) end)
	registerForEvent("stopctrlscrollleft", private.contract, function (...) return widgetSystem.onStopScrollLeft("ctrl", ...) end)
	registerForEvent("startshiftscrollleft", private.contract, function (...) return widgetSystem.onStartScrollLeft("shift", ...) end)
	registerForEvent("stopshiftscrollleft", private.contract, function (...) return widgetSystem.onStopScrollLeft("shift", ...) end)
	registerForEvent("startshiftctrlscrollleft", private.contract, function (...) return widgetSystem.onStartScrollLeft("shiftctrl", ...) end)
	registerForEvent("stopshiftctrlscrollleft", private.contract, function (...) return widgetSystem.onStopScrollLeft("shiftctrl", ...) end)
	registerForEvent("startscrollright", private.contract, function (...) return widgetSystem.onStartScrollRight(nil, ...) end)
	registerForEvent("stopscrollright", private.contract, function (...) return widgetSystem.onStopScrollRight(nil, ...) end)
	registerForEvent("startctrlscrollright", private.contract, function (...) return widgetSystem.onStartScrollRight("ctrl", ...) end)
	registerForEvent("stopctrlscrollright", private.contract, function (...) return widgetSystem.onStopScrollRight("ctrl", ...) end)
	registerForEvent("startshiftscrollright", private.contract, function (...) return widgetSystem.onStartScrollRight("shift", ...) end)
	registerForEvent("stopshiftscrollright", private.contract, function (...) return widgetSystem.onStopScrollRight("shift", ...) end)
	registerForEvent("startshiftctrlscrollright", private.contract, function (...) return widgetSystem.onStartScrollRight("shiftctrl", ...) end)
	registerForEvent("stopshiftctrlscrollright", private.contract, function (...) return widgetSystem.onStopScrollRight("shiftctrl", ...) end)
	registerForEvent("startremovenextchar", private.contract, widgetSystem.onStartRemoveNextChar)
	registerForEvent("stopremovenextchar", private.contract, widgetSystem.onStopRemoveNextChar)
	registerForEvent("mouseEmulationActivated", private.contract, widgetSystem.onMouseEmulationActivated)
	registerForEvent("mouseEmulationDeactivated", private.contract, widgetSystem.onMouseEmulationDeactivated)
	registerForEvent("movedown", private.contract, function (...) return widgetSystem.onMoveDown(nil, ...) end)
	registerForEvent("moveup", private.contract, function (...) return widgetSystem.onMoveUp(nil, ...) end)
	registerForEvent("pagedown", private.contract, widgetSystem.onPageDown)
	registerForEvent("pageup", private.contract, widgetSystem.onPageUp)
	registerForEvent("removeAllHelpOverlays", private.contract, widgetSystem.onRemoveAllHelpOverlays)
	registerForEvent("removeHelpOverlay", private.contract, widgetSystem.onRemoveHelpOverlay)
	registerForEvent("combinedscrolldown", private.contract, function (...) return widgetSystem.onScrollDown(nil, ...) end)
	registerForEvent("combinedscrollup", private.contract, function (...) return widgetSystem.onScrollUp(nil, ...) end)
	registerForEvent("combinedshiftscrolldown", private.contract, function (...) return widgetSystem.onScrollDown("shift", ...) end)
	registerForEvent("combinedshiftscrollup", private.contract, function (...) return widgetSystem.onScrollUp("shift", ...) end)
	registerForEvent("shieldhullbarupdate", private.contract, widgetSystem.onShieldHullBarUpdate)
	registerForEvent("shiftmovedown", private.contract, function (...) return widgetSystem.onMoveDown("shift", ...) end)
	registerForEvent("shiftmoveup", private.contract, function (...) return widgetSystem.onMoveUp("shift", ...) end)
	registerForEvent("shiftspace", private.contract, function (...) return widgetSystem.onSpace("shift", ...) end)
	registerForEvent("showExtro", private.contract, widgetSystem.onClose)
	registerForEvent("showGameOver", private.contract, widgetSystem.onClose)
	registerForEvent("showHelpOverlay", private.contract, widgetSystem.onShowHelpOverlay)
	registerForEvent("showHighlightOverlay", private.contract, widgetSystem.onShowHighlightOverlay)
	registerForEvent("slidercellupdate", private.contract, widgetSystem.onSliderCellUpdate)
	registerForEvent("space", private.contract, function (...) return widgetSystem.onSpace(nil, ...) end)
	registerForEvent("startselect", private.contract, widgetSystem.onStartSelect)
	registerForEvent("statusbarupdate", private.contract, widgetSystem.onStatusBarUpdate)
	registerForEvent("stopselect", private.contract, widgetSystem.onStopSelect)
	registerForEvent("startinteract", private.contract, widgetSystem.onStartInteract)
	registerForEvent("stopinteract", private.contract, widgetSystem.onStopInteract)
	registerForEvent("tab", private.contract, widgetSystem.onTabInteractiveElement)
	registerForEvent("tabscrollleft", private.contract, widgetSystem.onTabScrollLeft)
	registerForEvent("tabscrollright", private.contract, widgetSystem.onTabScrollRight)
	registerForEvent("tableupdate", private.contract, widgetSystem.onTableUpdate)
	registerForEvent("updateColorMap", private.contract, widgetSystem.onUpdateColorMap)
	registerForEvent("updateScenesDone", private.contract, widgetSystem.onUpdateScenesDone)
	registerForEvent("viewclose", private.contract, widgetSystem.onViewClose)
	registerForEvent("viewremoved", private.contract, widgetSystem.onViewRemoved)

	registerForEvent("onMouseOver", private.widgetsystem, widgetSystem.onMouseOver)
	registerForEvent("onMouseOut", private.widgetsystem, widgetSystem.onMouseOut)

	private.sceneState = {
		["widgetsystem"]     = false,
		["shapes"]           = false,
		["miniwidgetsystem"] = false,
		["starteffect"]      = false,
	}

	-- mouse over text config
	private.enableMouseOverText = C.GetConfigSetting("mouseovertext") ~= 0
	registerForEvent("enableMouseOverText", private.contract, widgetSystem.onToggleMouseOverText)

	-- init
	widgetSystem.initScale(private.anchorElement)

	-- register presentation with widget system
	RegisterWidget()
end

function self:onUpdate()
	local curTime -- intent is to get it once per frame only, hence init with nil and set, when required just once

	widgetSystem.runDeferredElementInitialization()

	-- start animation
	if private.startAnimationStartTime then
		local animationSpeed = (1 + 1 / config.startAnimation.speedFactor) * math.pi / config.startAnimation.duration
		curTime = curTime or getElapsedTime()
		local x = (curTime - private.startAnimationStartTime) * animationSpeed
		local scale_x = math.min(1, 0.5 * (math.sin(x - math.pi / 2) + 1))
		local scale_y = config.startAnimation.initialHeight
		local alpha = 1
		if x >= math.pi then
			scale_x = 1
			scale_y = math.max(config.startAnimation.initialHeight, math.min(1, 0.5 * (math.sin(config.startAnimation.speedFactor * (x - math.pi) - math.pi / 2) + 1)))
			alpha = 1 - scale_y
		end
		setAttribute(private.anchorElement, "scale.x", private.scalingFactor * scale_x)
		setAttribute(private.anchorElement, "scale.y", private.scalingFactor * scale_y)
		setAttribute(private.starteffect, "opacity", Color["menu_start_animation"].a * alpha)
		if x >= (1 + 1 / config.startAnimation.speedFactor) * math.pi then
			private.startAnimationStartTime = nil
			setAttribute(private.anchorElement, "scale.x", private.scalingFactor)
			setAttribute(private.anchorElement, "scale.y", private.scalingFactor)
			setAttribute(private.starteffect, "opacity", 0)
			widgetSystem.setSceneState("starteffect", false)
		end
	end

	-- process pending frame update (cannot be done directly in onFrameUpdate() since we've to activate the widget system first)
	if #private.pendingFrames > 0 then
		private.activeframe = GetActiveFrame()
		if private.activeframe ~= nil then
			local skip = false
			if private.activeEditBox then
				if private.activeEditBox.frameElement.frame ~= private.activeframe then
					if IsValidWidgetElement(private.activeEditBox.frameElement.frame) then
						widgetSystem.setActiveFrame(private.activeEditBox.frameElement)
						skip = true
					end
				end
			end

			if not skip then
				if (private.interactiveElement ~= nil) and (private.interactiveElement.widgetID ~= nil) and IsValidWidgetElement(private.interactiveElement.widgetID) and IsType(private.interactiveElement.widgetID, "table") then
					widgetSystem.removeHighlightBorderTableRow(private.interactiveElement.element)
				end
				private.interactiveElement = nil
				if (private.activeframe ~= 0) and IsValidWidgetElement(private.activeframe) then
					local interactiveWidgetID = GetInteractiveObject(private.activeframe)
					if interactiveWidgetID ~= nil then
						-- can be nil, if frame has no interactive object at all
						widgetSystem.setInteractiveElement(private.activeframe, interactiveWidgetID)
					end
				end
			end
		end

		local hasstartanimation = C.HasStartAnimation()
		-- this also resets the variable
		local isnextstartanimationskipped = C.IsNextStartAnimationSkipped(true)
		if (not private.startAnimationDisplayed) and hasstartanimation then
			private.startAnimationDisplayed = true
			if not isnextstartanimationskipped then
				curTime = curTime or getElapsedTime()
				widgetSystem.setSceneState("starteffect", true)
				private.startAnimationStartTime = curTime
			end
		elseif not hasstartanimation then
			private.startAnimationDisplayed = false
		end

		if not private.viewDisplayed then
			widgetSystem.updateView()
		end
		private.onHideRisen = false

		for _, frame in ipairs(private.pendingFrames) do
			widgetSystem.updateFrame(frame)
		end

		private.pendingFrames = {}
	end

	-- update active editbox if any
	if private.activeEditBox ~= nil then
		curTime = curTime or getElapsedTime()

		local editboxElement = private.activeEditBox.editboxElement
		if private.activeEditBox.scrollLeftStart and (private.activeEditBox.scrollLeftStart + 1 / config.editbox.cursorSpeed <= curTime) then
			private.activeEditBox.scrollLeftStart = curTime
			if private.activeEditBox.isCtrlScroll then
				local startpos = editboxElement.cursorPos
				local first = widgetSystem.findEditBoxWordAtPos(editboxElement, startpos)
				if (first == nil) or (first == startpos) then
					first = widgetSystem.findEditBoxWordAtPos(editboxElement, startpos - 1)
				end
				first = first or 0
				editboxElement.cursorPos = math.max(0, first)
			else
				editboxElement.cursorPos = math.max(0, editboxElement.cursorPos - 1)
			end
			widgetSystem.updateEditBoxTextDisplay(editboxElement)
		end
		if private.activeEditBox.scrollRightStart and (private.activeEditBox.scrollRightStart + 1 / config.editbox.cursorSpeed <= curTime) then
			private.activeEditBox.scrollRightStart = curTime
			if private.activeEditBox.isCtrlScroll then
				local _, _, nextword = widgetSystem.findEditBoxWordAtPos(editboxElement, editboxElement.cursorPos)
				nextword = nextword or utf8.len(editboxElement.text)
				editboxElement.cursorPos = math.min(utf8.len(editboxElement.text), nextword)
			else
				editboxElement.cursorPos = math.min(utf8.len(editboxElement.text), editboxElement.cursorPos + 1)
			end
			widgetSystem.updateEditBoxTextDisplay(editboxElement)
		end
		if private.activeEditBox.removeNextCharStart and (private.activeEditBox.removeNextCharStart + 1 / config.editbox.cursorSpeed <= curTime) then
			private.activeEditBox.removeNextCharStart = curTime
			widgetSystem.removeNextEditBoxChar(private.activeEditBox.editboxID, editboxElement)
		end
		local updatecursor = false
		if editboxElement.mouseClickStart then
			local curPos, rawXPos = widgetSystem.getEditBoxCursorPosFromMouse(private.activeEditBox.frameElement, private.activeEditBox.editboxID, editboxElement)
			if curPos then
				updatecursor = true
				if rawXPos < 0 then
					-- mouse got dragged-out to the left side
					local newtext = widgetSystem.hideText(editboxElement.text, editboxElement.textHidden)
					editboxElement.textDisplayStart = math.max(0, editboxElement.textDisplayStart - 1)
					editboxElement.cursorPos = editboxElement.textDisplayStart

					local availablewidth = editboxElement.width - 2 * (editboxElement.rawTextOffsetX + config.texturesizes.editbox.borderSize)
					newtext = utf8.sub(widgetSystem.hideText(editboxElement.text, editboxElement.textHidden), editboxElement.textDisplayStart, -1)
					while (newtext ~= "") and C.GetTextWidth(newtext, editboxElement.font, editboxElement.fontsize) > availablewidth do
						newtext = utf8.sub(newtext, 1, -2)
					end
					editboxElement.textDisplayEnd = editboxElement.textDisplayStart + utf8.len(newtext)
					setAttribute(getElement("Text", editboxElement.element), "textstring", newtext)
				elseif rawXPos > editboxElement.width then
					-- mouse got dragged-out to the right side
					local newtext = widgetSystem.hideText(editboxElement.text, editboxElement.textHidden)
					editboxElement.textDisplayEnd = math.min(utf8.len(newtext), editboxElement.textDisplayEnd + 1)
					editboxElement.cursorPos = editboxElement.textDisplayEnd

					local availablewidth = editboxElement.width - 2 * (editboxElement.rawTextOffsetX + config.texturesizes.editbox.borderSize)
					newtext = utf8.sub(newtext, 1, editboxElement.textDisplayEnd)
					while (newtext ~= "") and C.GetTextWidth(newtext, editboxElement.font, editboxElement.fontsize) > availablewidth do
						newtext = utf8.sub(newtext, 2, -1)
					end
					editboxElement.textDisplayStart = editboxElement.textDisplayEnd - utf8.len(newtext)
					setAttribute(getElement("Text", editboxElement.element), "textstring", newtext)
				else
					if editboxElement.isClick and (curPos ~= editboxElement.mouseClickStart) then
						editboxElement.isClick = nil
						if (not editboxElement.isShiftClick) or (not editboxElement.shiftStartPos) then
							editboxElement.shiftStartPos = editboxElement.mouseClickStart
						end
						editboxElement.cursorPos = curPos
					elseif not editboxElement.isClick then
						editboxElement.cursorPos = curPos
					end
				end
			else
				-- mouse is no longer over the box, need to cancel
				editboxElement.mouseClickStart = nil
			end
		end

		widgetSystem.updateEditBoxCursor(editboxElement, curTime, private.activeEditBox.scrollLeftStart or private.activeEditBox.scrollRightStart or editboxElement.mouseClickStart)
		widgetSystem.updateEditBoxTextHighlight(editboxElement)
		if updatecursor then
			CallWidgetEventScripts(private.activeEditBox.editboxID, "onCursorChanged", editboxElement.cursorPos, editboxElement.shiftStartPos)
		end
	end
	-- update active slidercell if any
	if private.activeSliderCell ~= nil then
		curTime = curTime or getElapsedTime()
		widgetSystem.updateSliderCellCursor(private.activeSliderCell.element, curTime)
	end

	-- perform any scroll updates
	if private.scrolling ~= nil then
		curTime = curTime or getElapsedTime()
		if private.nextTickTime <= curTime then
			private.nextTickTime = curTime + config.slider.interval.reoccurrentTickDelay
			if private.scrolling == "left" then
				widgetSystem.scrollLeft(private.scrollingElement, widgetSystem.getCurrentInterval())
			else -- scrolling == "right"
				widgetSystem.scrollRight(private.scrollingElement, widgetSystem.getCurrentInterval())
			end
		end
	end

	-- perform slidercell updates
	if private.slidercellScrolling then
		curTime = curTime or getElapsedTime()
		if private.slidercellScrolling.nextTick < curTime then
			widgetSystem.scrollSliderCell()
			private.slidercellScrolling.nextTick = curTime + config.slidercell.interval.reoccurrentTickDelay 
		end
	end

	if private.slidercellDrag then -- = { clickStart = x, clickOffset = xoff, wasDragged = true|false }
		local x = widgetSystem.getSliderCellMousePosition(private.slidercellDrag.frameElement, private.slidercellDrag.widgetID)
		if x then
			local slidercellElement = private.associationList[private.slidercellDrag.widgetID].element
			local oldcur = slidercellElement.cur
			local newcur = widgetSystem.getSliderCellValueFromXPosition(slidercellElement, x - private.slidercellDrag.clickOffset)
			if newcur ~= oldcur then
				widgetSystem.setSliderCellCurValue(slidercellElement, newcur, false, true, true)
				if slidercellElement.cur ~= oldcur then
					widgetSystem.updateSliderCellValue(slidercellElement)
				end
				if math.abs(x - private.slidercellDrag.clickStart) > 0.01 then
					private.slidercellDrag.wasDragged = true
				end
			end
		end
	end

	-- update active dropdown if any
	if private.activeDropDown ~= nil then
		widgetSystem.updateDropDownOption(private.activeDropDown.element)
	end

	-- perform table mouse pick updates
	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		if frameElement then
			for _, tableElement in ipairs(frameElement.tables) do
				widgetSystem.processTableMousePick(tableElement)
			end

			for _, type in ipairs(config.frame.backgroundElements) do
				local data = frameElement[type .. "Data"]
				if data.active then
					-- rotation
					if data.rotationRate ~= 0 then
						curTime = curTime or getElapsedTime()
						data.rotationStartTime = data.rotationStartTime or curTime
						data.rotationLastTime = data.rotationLastTime or curTime
						if (data.rotationDuration == 0) or (data.rotationStartTime + data.rotationDuration > curTime) then
							if data.rotationDuration == 0 then
								setAttribute(frameElement[type .. "Icon"], "rotationuv", ((curTime - data.rotationStartTime) * data.rotationRate + data.rotationStart) % 360)
							else
								setAttribute(frameElement[type .. "Icon"], "rotationuv", (math.sin(0.5 * math.pi * (curTime - data.rotationStartTime) / data.rotationDuration) * data.rotationRate * data.rotationDuration + data.rotationStart) % 360)
							end
						elseif (data.rotationInterval > 0) and (data.rotationLastTime + data.rotationInterval < curTime) then
							data.rotationStartTime = curTime
							data.rotationLastTime = curTime
						else
							setAttribute(frameElement[type .. "Icon"], "rotationuv", data.rotationEnd)
							if data.rotationInterval == 0 then
								-- no future animations, skip the whole block from now on
								data.rotationRate = 0
							end
						end
					end

					-- scale
					if data.initScale ~= 1 then
						curTime = curTime or getElapsedTime()
						data.scaleStartTime = data.scaleStartTime or curTime
						if data.scaleStartTime + data.scaleDuration > curTime then
							local x = curTime - data.scaleStartTime
							setAttribute(getElement(type, frameElement[type]), "scale.x", (data.quadraticFactor * x * x + data.linearFactor * x + data.initScale) * data.origScale.x)
							setAttribute(getElement(type, frameElement[type]), "scale.y", (data.quadraticFactor * x * x + data.linearFactor * x + data.initScale) * data.origScale.y)
						else
							setAttribute(getElement(type, frameElement[type]), "scale.x", data.origScale.x)
							setAttribute(getElement(type, frameElement[type]), "scale.y", data.origScale.y)
							-- no future animation, skip the whole block from now on
							data.initScale = 1
						end
					end
				end
			end
		end
	end

	curTime = curTime or getElapsedTime()
	for id, overlay in pairs(private.displayedHelpOverlays) do
		if overlay.borderonly then
			widgetSystem.updateHelpOverlayColor(overlay.element, private.helpOverlayStates[id], overlay.iconsize, overlay.borderonly, curTime)
		end
	end

	local posX, posY = GetLocalMousePosition()
	posX = (posX and posX ~= 0) and math.floor(posX + 0.5) or private.lastMousePosX
	posY = (posY and posY ~= 0) and math.floor(posY + 0.5) or private.lastMousePosY
	if (posX ~= private.lastMousePosX) or (posY ~= private.lastMousePosY) then
		private.hadNoneMouseInput = nil
		if private.mouseOverText and private.mouseOverText.posOverride then
			widgetSystem.hideMouseOverText(private.mouseOverText.widgetID)
		end
	end
	private.lastMousePosX = posX
	private.lastMousePosY = posY

	if private.mouseOverText then
		widgetSystem.setMouseOverPosition()
	end

	if private.shapesActivated then
		widgetSystem.updateShapes()
	end

	-- call addon update scripts
	CallUpdateScripts()
end

-- onUpdate happens between slide updates and UpdateScenes() (creating the drawlist)
-- That measns changing slides and re-using the elements in onUpdate causes them to be rendered with wrong slides for a frame
-- onUpdateScenesDone() happens afterwards, so slide changes are processed before the next draw
function widgetSystem.onUpdateScenesDone()
	-- perform slider / scrollbar updates
	if private.scrollBarDrag then
		widgetSystem.updateScrollBarPos(private.scrollBarDrag)
	elseif private.dropDownScrollBarDrag then
		widgetSystem.updateDropDownScrollBarPos(private.activeDropDown.widgetID, private.activeDropDown.element)
	elseif private.flowchartScrollBarDrag then
		widgetSystem.updateFlowchartScrollBarPos(private.flowchartScrollBarDrag.element, private.flowchartScrollBarDrag.scrollbar)
	elseif private.flowchartNodeSliderDrag then
		widgetSystem.updateFlowchartNodeSliderPos()
	end
end

--------------------------------------
-- Widget system specific callbacks --
--------------------------------------

function widgetSystem.onBoxTextUpdate(_, boxtextID)
	if not IsValidWidgetElement(boxtextID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local textentry = private.associationList[boxtextID]
	if textentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	-- #StefanMed - refactor and store the component in the associationList as well
	widgetSystem.updateBoxText(boxtextID, textentry.element)
	widgetSystem.updateMouseOverText(boxtextID)
end

function widgetSystem.onButtonUpdate(_, buttonID)
	if not IsValidWidgetElement(buttonID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local buttonentry = private.associationList[buttonID]
	if buttonentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	widgetSystem.updateButton(buttonID, buttonentry.element)
	widgetSystem.updateMouseOverText(buttonID)
end

function widgetSystem.onBack()
	if #private.pendingFrames > 0 then
		-- #StefanMed - review this part - in principle this might cause that successive eventtriggers are unnecessarily delayed now, because if the event occurred before actually displaying the frame
		-- it is skipped now (aka: pressing ESC multiple times in a row might now react slower than necessary)
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if private.activeEditBox ~= nil and (not private.activeEditBox.editboxElement.closeMenuOnBack) then
		-- clear input
		widgetSystem.setEditBoxText(private.activeEditBox.editboxElement, "")
		private.activeEditBox.editboxElement.cursor = false
		widgetSystem.confirmEditBoxInputInternal(private.activeEditBox.editboxID, private.activeEditBox.editboxElement, false)
	elseif private.activeSliderCell then
		widgetSystem.cancelSliderCellInputInternal(private.activeSliderCell.widgetID, private.activeSliderCell.element)
	elseif private.activeDropDown then
		widgetSystem.closeDropDownOptions(private.activeDropDown.widgetID)
	else
		widgetSystem.raiseHideEvent(private.activeframe, "back")
	end
end

function widgetSystem.onCheckBoxUpdate(_, checkboxID)
	if not IsValidWidgetElement(checkboxID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local checkboxentry = private.associationList[checkboxID]
	if checkboxentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	widgetSystem.updateCheckBox(checkboxID, checkboxentry.element)
	widgetSystem.updateMouseOverText(checkboxID)
end

function widgetSystem.onClose()
	if #private.pendingFrames > 0 then
		-- #StefanLow - review this part - in principle this might cause that successive eventtriggers are unnecessarily delayed now, because if the event occurred before actually displaying the frame
		-- it is skipped now (expected to not be a real issue, since it'd require a close-event in nearly the same frame of a newly displayed frame - aka: ESC + DEL -> unlikely to happen --- player would
		-- in most cases press DEL directly).
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	widgetSystem.raiseHideEvent(private.activeframe, "close")
end

function widgetSystem.onAutoClose()
	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		if frameElement and frameElement.frame then
			widgetSystem.raiseHideEvent(frameElement.frame, "auto")
		end
	end
	private.pendingFrames = {}
end

function widgetSystem.onCut()
	if private.activeEditBox ~= nil then
		local editboxElement = private.activeEditBox.editboxElement
		if not editboxElement.encrypted then
			if editboxElement.shiftStartPos and (editboxElement.shiftStartPos ~= editboxElement.cursorPos) then
				local selectedtext = ""
				if editboxElement.cursorPos > editboxElement.shiftStartPos then
					selectedtext = utf8.sub(editboxElement.text, math.max(0, editboxElement.shiftStartPos + 1), editboxElement.cursorPos)
					editboxElement.text = utf8.sub(editboxElement.text, 1, math.max(0, editboxElement.shiftStartPos)) .. utf8.sub(editboxElement.text, editboxElement.cursorPos + 1, -1)
					editboxElement.cursorPos = editboxElement.cursorPos - (editboxElement.cursorPos - editboxElement.shiftStartPos)
				else
					selectedtext = utf8.sub(editboxElement.text, math.max(0, editboxElement.cursorPos + 1), editboxElement.shiftStartPos)
					editboxElement.text = utf8.sub(editboxElement.text, 1, math.max(0, editboxElement.cursorPos)) .. utf8.sub(editboxElement.text, editboxElement.shiftStartPos + 1, -1)
				end
				if selectedtext ~= "" then
					C.CopyToClipboard(selectedtext)
				end
				CallWidgetEventScripts(private.activeEditBox.editboxID, "onTextChanged", editboxElement.text)
				editboxElement.shiftStartPos = nil
				widgetSystem.updateEditBoxTextDisplay(editboxElement)
				widgetSystem.updateEditBoxCursorPosition(editboxElement)
				widgetSystem.updateEditBoxTextHighlight(editboxElement)
				CallWidgetEventScripts(private.activeEditBox.editboxID, "onCursorChanged", editboxElement.cursorPos, editboxElement.shiftStartPos)
			end
		end
	end
end

function widgetSystem.onCopy()
	if private.activeEditBox ~= nil then
		local editboxElement = private.activeEditBox.editboxElement
		if not editboxElement.encrypted then
			if editboxElement.shiftStartPos and (editboxElement.shiftStartPos ~= editboxElement.cursorPos) then
				local selectedtext = ""
				if editboxElement.cursorPos > editboxElement.shiftStartPos then
					selectedtext = utf8.sub(editboxElement.text, math.max(0, editboxElement.shiftStartPos + 1), editboxElement.cursorPos)
				else
					selectedtext = utf8.sub(editboxElement.text, math.max(0, editboxElement.cursorPos + 1), editboxElement.shiftStartPos)
				end
				if selectedtext ~= "" then
					C.CopyToClipboard(selectedtext)
				end
			end
		end
	end
end

function widgetSystem.onEnd(modified)
	if private.activeEditBox ~= nil then
		local editboxElement = private.activeEditBox.editboxElement
		if not editboxElement.encrypted then
			if modified == "shift" then
				editboxElement.shiftStartPos = editboxElement.shiftStartPos or editboxElement.cursorPos
			else
				editboxElement.shiftStartPos = nil
			end
			editboxElement.cursorPos = utf8.len(editboxElement.text)
			widgetSystem.updateEditBoxTextDisplay(editboxElement)
			widgetSystem.updateEditBoxCursorPosition(editboxElement)
			widgetSystem.updateEditBoxTextHighlight(editboxElement)
			CallWidgetEventScripts(private.activeEditBox.editboxID, "onCursorChanged", editboxElement.cursorPos, editboxElement.shiftStartPos)
		end
	end
end

function widgetSystem.onHome(modified)
	if private.activeEditBox ~= nil then
		local editboxElement = private.activeEditBox.editboxElement
		if not editboxElement.encrypted then
			if modified == "shift" then
				editboxElement.shiftStartPos = editboxElement.shiftStartPos or editboxElement.cursorPos
			else
				editboxElement.shiftStartPos = nil
			end
			editboxElement.cursorPos = 0
			widgetSystem.updateEditBoxTextDisplay(editboxElement)
			widgetSystem.updateEditBoxCursorPosition(editboxElement)
			widgetSystem.updateEditBoxTextHighlight(editboxElement)
			CallWidgetEventScripts(private.activeEditBox.editboxID, "onCursorChanged", editboxElement.cursorPos, editboxElement.shiftStartPos)
		end
	end
end

function widgetSystem.onSelectAll()
	if private.activeEditBox ~= nil then
		local editboxElement = private.activeEditBox.editboxElement
		if not editboxElement.encrypted then
			editboxElement.shiftStartPos = 0
			editboxElement.cursorPos = utf8.len(editboxElement.text)
			widgetSystem.updateEditBoxTextDisplay(editboxElement)
			widgetSystem.updateEditBoxCursorPosition(editboxElement)
			widgetSystem.updateEditBoxTextHighlight(editboxElement)
			CallWidgetEventScripts(private.activeEditBox.editboxID, "onCursorChanged", editboxElement.cursorPos, editboxElement.shiftStartPos)
		end
	end
end

function widgetSystem.hideText(text, hide)
	local displaytext = text
	if hide then
		displaytext = ""
		for i = 1, utf8.len(text) do
			displaytext = displaytext .. config.editbox.hiddenSymbol
		end
	end

	return displaytext
end

function widgetSystem.onDirectTextInput(_, char)
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if private.activeEditBox ~= nil then
		local editboxElement = private.activeEditBox.editboxElement
		if char == "\8" then
			if string.len(editboxElement.text) > 0 then
				if editboxElement.shiftStartPos and (editboxElement.shiftStartPos ~= editboxElement.cursorPos) then
					if editboxElement.cursorPos > editboxElement.shiftStartPos then
						editboxElement.text = utf8.sub(editboxElement.text, 1, math.max(0, editboxElement.shiftStartPos)) .. utf8.sub(editboxElement.text, editboxElement.cursorPos + 1, -1)
						editboxElement.cursorPos = editboxElement.cursorPos - (editboxElement.cursorPos - editboxElement.shiftStartPos)
					else
						editboxElement.text = utf8.sub(editboxElement.text, 1, math.max(0, editboxElement.cursorPos)) .. utf8.sub(editboxElement.text, editboxElement.shiftStartPos + 1, -1)
					end
				else
					editboxElement.text = utf8.sub(editboxElement.text, 1, math.max(0, editboxElement.cursorPos - 1)) .. utf8.sub(editboxElement.text, editboxElement.cursorPos + 1, -1)
					editboxElement.cursorPos = editboxElement.cursorPos - 1
				end
				CallWidgetEventScripts(private.activeEditBox.editboxID, "onTextChanged", editboxElement.text)
			end
		else
			local newtext = utf8.sub(editboxElement.text, 1, editboxElement.cursorPos) .. tostring(char) .. utf8.sub(editboxElement.text, editboxElement.cursorPos + 1, -1)
			local cursoroffset = 0
			if editboxElement.shiftStartPos and (editboxElement.shiftStartPos ~= editboxElement.cursorPos) then
				if editboxElement.cursorPos > editboxElement.shiftStartPos then
					newtext = utf8.sub(editboxElement.text, 1, math.max(0, editboxElement.shiftStartPos)) .. tostring(char) .. utf8.sub(editboxElement.text, editboxElement.cursorPos + 1, -1)
					cursoroffset = editboxElement.shiftStartPos - editboxElement.cursorPos
				else
					newtext = utf8.sub(editboxElement.text, 1, math.max(0, editboxElement.cursorPos)) .. tostring(char) .. utf8.sub(editboxElement.text, editboxElement.shiftStartPos + 1, -1)
				end
			end
			if (utf8.len(widgetSystem.hideText(newtext, editboxElement.textHidden)) <= editboxElement.maxChars) then
				editboxElement.text = newtext
				editboxElement.cursorPos = editboxElement.cursorPos + cursoroffset + 1
				CallWidgetEventScripts(private.activeEditBox.editboxID, "onTextChanged", editboxElement.text)
			end
		end
		editboxElement.shiftStartPos = nil
		widgetSystem.updateEditBoxTextDisplay(editboxElement)
		widgetSystem.updateEditBoxCursorPosition(editboxElement)
		widgetSystem.updateEditBoxTextHighlight(editboxElement)
		CallWidgetEventScripts(private.activeEditBox.editboxID, "onCursorChanged", editboxElement.cursorPos, editboxElement.shiftStartPos)
	elseif private.activeSliderCell ~= nil then
		local slidercellElement = private.activeSliderCell.element
		if char == "\8" then
			if string.len(slidercellElement.cur) > 0 then
				-- prevent removal of decimal point by tonumber()
				local usestring = false
				local decimalpoint = string.find(slidercellElement.cur, "%.")
				if decimalpoint then
					usestring = decimalpoint + 1 == string.len(slidercellElement.cur)
				end

				local cur = string.sub(slidercellElement.cur, 1, widgetSystem.getUTF8CharacterPrevIndex(tostring(slidercellElement.cur), string.len(slidercellElement.cur)))
				local number
				if not usestring then
					number = tonumber(cur)
				end
				if number and number >= slidercellElement.minSelect then
					if number >= slidercellElement.minSelect then
						widgetSystem.setSliderCellCurValue(slidercellElement, number, true, true)
					else
						-- in case of backspace accept smaller numbers temporarily in order to enable input of all acceptable numbers
						slidercellElement.cur = number
						local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)
						local value = tonumber(slidercellElement.cur) or slidercellElement.minSelect
						C.SetSliderCellValue(slidercellID, value)
						CallWidgetEventScripts(slidercellID, "onSliderCellChanged", value)
					end
				else
					slidercellElement.cur = cur
					local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)
					local value = tonumber(slidercellElement.cur) or slidercellElement.minSelect
					C.SetSliderCellValue(slidercellID, value)
					CallWidgetEventScripts(slidercellID, "onSliderCellChanged", value)
				end
			end
		elseif char == "-" then
			if (slidercellElement.minSelect < 0) and (string.len(slidercellElement.cur) == 0) then
				slidercellElement.cur = "-"
			end
		elseif char == L["."] then
			local int, frac = math.modf(slidercellElement.step)
			local decimalpoint = string.find(slidercellElement.cur, "%.")
			if (frac > 0) and tonumber(slidercellElement.cur) and (not decimalpoint) then
				slidercellElement.cur = slidercellElement.cur .. L["."]
			end
		else
			local digit = tonumber(char)
			if digit then
				local skip = false
				if tonumber(slidercellElement.cur) then
					local int, frac = math.modf(slidercellElement.cur)
					if frac > 0 then
						frac = math.floor(frac * slidercellElement.powaccuracy + 0.5) / slidercellElement.powaccuracy
						local fracdigits = string.len(string.gsub(frac, "0+%.", ""))
						if fracdigits >= slidercellElement.accuracy then
							skip = true
						end
					end
				end

				if not skip then
					local cur = tonumber(slidercellElement.cur .. digit)
					local curmin = slidercellElement.minSelect
					local curmax = slidercellElement.maxfactor * slidercellElement.maxSelect
					if (curmin >= 0 and cur >= 0 and cur < curmin) or (curmax <= 0 and cur <= 0 and cur > curmax) then
						-- accept smaller absolute numbers temporarily in order to enable input of all acceptable numbers
						slidercellElement.cur = cur
					else
						widgetSystem.setSliderCellCurValue(slidercellElement, cur, true, true)
					end
				end
			end
		end

		widgetSystem.updateSliderCellValue(slidercellElement)
	elseif private.activeDropDown then
		local lowerchar = utf8.lower(char)

		-- check whether we want to gather another char or reset the search
		local curtime = getElapsedTime()
		if (not private.activeDropDown.lastDirectInputTime) or ((private.activeDropDown.lastDirectInputTime + 1) < curtime) then
			private.activeDropDown.directInputString = lowerchar
		else
			private.activeDropDown.directInputString = private.activeDropDown.directInputString .. lowerchar
		end
		private.activeDropDown.lastDirectInputTime = curtime

		for i, entry in ipairs(private.activeDropDown.element.options) do
			if (not entry.deleted) and entry.active then
				local lowertext = utf8.lower(entry.text)

				-- filter out any text enhancements and whitespace
				local k = 1
				for j = 1, utf8.len(lowertext) do
					if k > utf8.len(lowertext) then
						lowertext = ""
						break
					end
					local whitespacestart, whitespaceend = utf8.find(lowertext, "%s+", k)
					if whitespacestart == k then
						-- whitespace found, skip to non-whitespace
						k = whitespaceend + 1
					else
						local escapestart, escapeend = utf8.find(lowertext, "\27", k)
						if escapestart == k then
							-- escape char found, check next char
							local iconstart, iconend = utf8.find(lowertext, "%b[]", k + 1)
							if iconstart == k + 1 then
								-- text icon found, skip to end of [] expression
								k = iconend + 1
							else
								local colorstart, colorend = utf8.find(lowertext, "#.*#", k + 1)
								if colorstart == k + 1 then
									-- text color found, skip to end of ## expression
									k = colorend + 1
								else
									-- normal escape char instruction, skip next char, too
									k = k + 2
								end
							end
						else
							-- real text found, set and break
							lowertext = utf8.sub(lowertext, k)
							break
						end
					end
				end

				if utf8.find(lowertext, private.activeDropDown.directInputString, 1, true) == 1 then
					private.activeDropDown.selected = i

					local _, _, frameElement = widgetSystem.getTableElementByAnarkTableCellElement("dropdown", private.activeDropDown.element.element.main)
					if (oldselected ~= #private.activeDropDown.element.options) and (private.activeDropDown.selected >= private.activeDropDown.element.topOption + private.activeDropDown.element.noofVisibleOptions - 1) then
						-- update topoption if new selected is outside the visible options
						widgetSystem.updateDropDownOptions(private.activeDropDown.widgetID, private.activeDropDown.element, private.activeDropDown.selected + 2 - private.activeDropDown.element.noofVisibleOptions)
					elseif (oldselected ~= 1) and (oldselected ~= 2) and (private.activeDropDown.selected <= private.activeDropDown.element.topOption) then
						-- update topoption if new selected is outside the visible options
						widgetSystem.updateDropDownOptions(private.activeDropDown.widgetID, private.activeDropDown.element, private.activeDropDown.selected - 1)
					end

					if private.activeDropDown.selected ~= private.activeDropDown.highlighted then
						local oldhighlighted = private.activeDropDown.highlighted
						private.activeDropDown.highlighted = private.activeDropDown.selected - (private.activeDropDown.element.topOption or 1) + 1
						widgetSystem.updateDropDownOptionState(private.activeDropDown.element, oldhighlighted)
					end

					break
				end
			end
		end
	end
end

function widgetSystem.onEditBoxTab()
	if private.activeEditBox ~= nil then
		local editboxElement = private.activeEditBox.editboxElement
		local tableElement, tableID, editboxrow, editboxcol = widgetSystem.getTableElementByAnarkTableCellElement("editbox", editboxElement.element)
		local frameElement = widgetSystem.getFrameElementByTableElement(tableElement)

		local startrow = editboxrow
		local startcol = editboxcol + 1
		if startcol > tableElement.numCols then
			startrow = startrow + 1
			if startrow > tableElement.numRows then
				startrow = 1
			end
			startcol = 1
		end

		local displayedRows = tableElement.displayedRows or 0
		for temprow = 1, displayedRows do
			local row = tableElement.cell[temprow].realRow
			if row >= startrow then
				local isNormalRegion = (row > tableElement.numFixedRows)
				for col = 1, tableElement.numCols do
					if (row ~= startrow) or (col >= startcol) then
						local colspan, cellwidth = widgetSystem.getColumnSpanInfo(tableID, tableElement, row, col, not isNormalRegion)
						if colspan ~= 0 then
							local childWidgetID = GetCellContent(tableID, row, col)
							if IsType(childWidgetID, "editbox") then
								widgetSystem.deactivateDirectInputElements()
								local childEditboxElement = private.associationList[childWidgetID].element
								widgetSystem.activateEditBoxInternal(frameElement, childWidgetID, childEditboxElement)
								widgetSystem.selectRow(tableID, row, nil, nil, "user")
								return
							end
						end
					end
				end
			end
		end

		local endrow = editboxrow
		local endcol = editboxcol - 1
		if endcol < 1 then
			endrow = endrow - 1
			if endrow < 1 then
				endrow = tableElement.numRows
			end
			endcol = tableElement.numCols
		end
		
		for temprow = 1, displayedRows do
			local row = tableElement.cell[temprow].realRow
			if row <= endrow then
				local isNormalRegion = (row > tableElement.numFixedRows)
				for col = 1, tableElement.numCols do
					if (row ~= endrow) or (col <= endcol) then
						local colspan, cellwidth = widgetSystem.getColumnSpanInfo(tableID, tableElement, row, col, not isNormalRegion)
						if colspan ~= 0 then
							local childWidgetID = GetCellContent(tableID, row, col)
							if IsType(childWidgetID, "editbox") then
								widgetSystem.deactivateDirectInputElements()
								local childEditboxElement = private.associationList[childWidgetID].element
								widgetSystem.activateEditBoxInternal(frameElement, childWidgetID, childEditboxElement)
								widgetSystem.selectRow(tableID, row, nil, nil, "user")
								return
							end
						end
					end
				end
			end
		end
	end
end

function widgetSystem.onGamepadTextInputEntered(_, text)
	if private.activeEditBox ~= nil then
		local editboxID = private.activeEditBox.editboxID
		local editboxElement = private.activeEditBox.editboxElement
		
		editboxElement.text = text
		CallWidgetEventScripts(editboxID, "onTextChanged", editboxElement.text)
		widgetSystem.confirmEditBoxInputInternal(editboxID, editboxElement, true)
	elseif private.activeSliderCell ~= nil then
		local slidercellID = private.activeSliderCell.widgetID
		local slidercellElement = private.activeSliderCell.element

		slidercellElement.cur = tonumber(text) or ""
		widgetSystem.confirmSliderCellInputInternal(slidercellID, slidercellElement)
	end
end

function widgetSystem.onGamepadTextInputCancelled()
	if private.activeEditBox ~= nil then
		local editboxID = private.activeEditBox.editboxID
		local editboxElement = private.activeEditBox.editboxElement
		
		widgetSystem.cancelEditBoxInputInternal(editboxID, editboxElement)
	elseif private.activeSliderCell ~= nil then
		local slidercellID = private.activeSliderCell.widgetID
		local slidercellElement = private.activeSliderCell.element

		widgetSystem.cancelSliderCellInputInternal(slidercellID, slidercellElement)
	end
end

--local genericEventStats = {}

function widgetSystem.onEvent(_, eventName, arg1)
	-- note: we do not delay dispatching of the event to the addonsystem, since even if we would have a pending frame, the addon system would already be updated correctly and issue the event
	-- onto the correct callbacks

	-- enable here (and above) to get stats about generic events
	--[[
	if eventName == "dumpgenericeventstats" then
		print("============ Generic Event Stats ============")
		for name, count in pairs(genericEventStats) do
			print(name .. ": " .. count)
		end
		return
	elseif eventName == "cleargenericeventstats" then
		genericEventStats = {}
	end
	genericEventStats[eventName] = (genericEventStats[eventName] or 0) + 1--]]

	CallEventScripts(eventName, arg1)
end

function widgetSystem.onFlowchartNodeUpdate(_, flowchartNodeID)
	if not IsValidWidgetElement(flowchartNodeID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local nodeentry = private.associationList[flowchartNodeID]
	if nodeentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	widgetSystem.updateFlowchartNode(flowchartNodeID, nodeentry.element)
	widgetSystem.updateMouseOverText(flowchartNodeID)
end

function widgetSystem.onFlowchartEdgeUpdate(_, flowchartEdgeID)
	if not IsValidWidgetElement(flowchartEdgeID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local edgeentry = private.associationList[flowchartEdgeID]
	if edgeentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	widgetSystem.updateFlowchartEdge(flowchartEdgeID, edgeentry.element)
	widgetSystem.updateMouseOverText(flowchartEdgeID)
end

function widgetSystem.onDropDownUpdate(_, dropdownID)
	if not IsValidWidgetElement(dropdownID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local dropdownentry = private.associationList[dropdownID]
	if dropdownentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	local dropdownElement = dropdownentry.element

	local startOption = ffi.string(C.GetDropDownStartOption(dropdownID))
	if startOption ~= "" then
		for i, entry in ipairs(dropdownElement.options) do
			if startOption == entry.id then
				dropdownElement.curOption = entry
			end
		end
	else
		dropdownElement.curOption = {}
	end

	local n = C.GetNumDropDownOptions(dropdownID)
	local buf = ffi.new("DropDownOption2[?]", n)
	n = C.GetDropDownOptions2(buf, n, dropdownID)
	for i = 0, n - 1 do
		dropdownElement.options[i + 1].text = ffi.string(buf[i].text)
		dropdownElement.options[i + 1].text2 = ffi.string(buf[i].text2)
	end

	local isactive = C.IsDropDownActive(dropdownID)
	if dropdownElement.active ~= isactive then
		if (not isactive) and dropdownElement.optionsshown then
			widgetSystem.closeDropDownOptions(private.activeDropDown.widgetID)
		end
		dropdownElement.active = isactive
		widgetSystem.updateDropDownState(dropdownID, dropdownElement)
	end

	widgetSystem.updateDropDown(dropdownID, dropdownElement)
	local _, _, frameElement = widgetSystem.getTableElementByAnarkTableCellElement("dropdown", dropdownElement.element.main)
	widgetSystem.updateDropDownOptions(frameElement, dropdownID, dropdownElement, dropdownElement.topOption, true)
	widgetSystem.updateMouseOverText(dropdownID)
end

function widgetSystem.onEditBoxUpdate(_, editboxID)
	if not IsValidWidgetElement(editboxID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local editboxentry = private.associationList[editboxID]
	if editboxentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	local editboxElement = editboxentry.element

	local newtext = GetEditBoxText(editboxID)
	if editboxElement.text ~= newtext then
		editboxElement.text = newtext
	end
	local isactive = C.IsEditBoxActive(editboxID)
	if editboxElement.widgetActive ~= isactive then
		if (not isactive) and editboxElement.active then
			widgetSystem.deactivateEditBox(editboxID, editboxElement, false)
		end
		editboxElement.widgetActive = isactive
		widgetSystem.setEditBoxColors(editboxID, editboxElement)
	end

	editboxElement.textHidden = C.IsEditBoxTextHidden(editboxID)
	widgetSystem.setEditBoxText(editboxElement, editboxElement.text)
	widgetSystem.updateMouseOverText(editboxID)
end

function widgetSystem.onFontStringUpdate(_, fontstringID)
	if not IsValidWidgetElement(fontstringID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local textentry = private.associationList[fontstringID]
	if textentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	-- #StefanMed - refactor and store the component in the associationList as well
	widgetSystem.updateFontString(fontstringID, textentry.textComponent, textentry.element, textentry.activeSlide, textentry.inactiveSlide, textentry.curSlide)
	widgetSystem.updateMouseOverText(fontstringID)
end

function widgetSystem.onViewClose()
	if not private.onHideRisen then
		widgetSystem.raiseHideEvent(private.activeframe, "auto")
	end
	private.pendingFrames = {}
	widgetSystem.hideAllElements()
	-- Fallback cleanup - should be part of widgetSystem.hideAllElements() but that requires the script to add shapes only after the frame was updated (see usage of widgetSystem.hideAllElements() in widgetsystem.updateFrame())
	widgetSystem.hideAllShapes()
	private.viewDisplayed = false
	private.startAnimationDisplayed = false
	widgetSystem.clearHelpOverlays()
	-- IMPORTANT - MUST BE DONE AFTER HIDE ALL ELEMENTS (otherwise the slide-changes for elements won't be executed resulting in ghost-elements, when activating the frame the next time)
	-- note: hiding the entire scene was done to improve the performance, if the widget system environment is disabled completely (since that saves us unnecessarily iterating over all cloned
	-- elements in shapes and in the widget system to check whether there's any active element (which there isn't))
	if private.miniWidgetSystemUsed then
		widgetSystem.setSceneState("miniwidgetsystem", false)
	else
		widgetSystem.setSceneState("widgetsystem", false)
	end
end

function widgetSystem.onFrameClose(_, frameID)
	if not private.onHideRisen then
		widgetSystem.raiseHideEvent(frameID, "auto")
	end
	if private.associationList[frameID] then
		widgetSystem.hideFrame(private.associationList[frameID].element)
	end
	if private.startAnimationDisplayed and (not C.HasStartAnimation()) then
		private.startAnimationDisplayed = false
	end

	-- activate the widget system
	local miniWidgetSystemUsed = C.IsMiniWidgetSystemUsed()
	if (not private.viewDisplayed) or (miniWidgetSystemUsed ~= private.miniWidgetSystemUsed) then
		if miniWidgetSystemUsed then
			widgetSystem.switchToMiniWidgetSystem()
			widgetSystem.setSceneState("miniwidgetsystem", true)
		else
			private.miniWidgetSystemUsed = false
			widgetSystem.setSceneState("widgetsystem", true)
		end
	end

	if frameID == private.activeframe then
		if private.mouseOverText then
			widgetSystem.hideMouseOverText(private.mouseOverText.widgetID, true)
		end
		private.interactiveElement = nil
		private.activeframe = GetActiveFrame()
		if private.activeframe and private.activeframe ~= 0 and IsValidWidgetElement(private.activeframe) then
			local interactiveWidgetID = GetInteractiveObject(private.activeframe)
			if interactiveWidgetID ~= nil then
				-- can be nil, if frame has no interactive object at all
				widgetSystem.setInteractiveElement(private.activeframe, interactiveWidgetID, nil, true)
			end
		end
	end
end

function widgetSystem.onFrameMinimize(_, frameID, text)
	if private.associationList[frameID] then
		widgetSystem.hideFrame(private.associationList[frameID].element, true)
		widgetSystem.showMinimizedMenuName(private.associationList[frameID].element, text)
	end

	if frameID == private.activeframe then
		private.interactiveElement = nil
		private.activeframe = GetActiveFrame()
		if private.activeframe and private.activeframe ~= 0 and IsValidWidgetElement(private.activeframe) then
			local interactiveWidgetID = GetInteractiveObject(private.activeframe)
			if interactiveWidgetID ~= nil then
				-- can be nil, if frame has no interactive object at all
				widgetSystem.setInteractiveElement(private.activeframe, interactiveWidgetID, nil, true)
			end
		end
	end
end

function widgetSystem.onFrameUpdate(_, frame)
	if not IsValidWidgetElement(frame) then
		return -- can happen if a view is closed before this callback is processed
	end

	if not private.onHideRisen then
		widgetSystem.raiseHideEvent(frame, "auto")
	end

	if not IsValidWidgetElement(frame) then
		return -- can happen if a view is closed as a result of the risen Hide-event
	end

	table.insert(private.pendingFrames, frame)

	-- activate the widget system
	local miniWidgetSystemUsed = C.IsMiniWidgetSystemUsed()
	if (not private.viewDisplayed) or (miniWidgetSystemUsed ~= private.miniWidgetSystemUsed) then
		if miniWidgetSystemUsed then
			widgetSystem.switchToMiniWidgetSystem()
			widgetSystem.setSceneState("miniwidgetsystem", true)
		else
			private.miniWidgetSystemUsed = false
			widgetSystem.setSceneState("widgetsystem", true)
		end
	end

	ForceAnarkUpdate()
end

function widgetSystem.onIconUpdate(_, iconID)
	if not IsValidWidgetElement(iconID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local iconentry = private.associationList[iconID]
	if iconentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	widgetSystem.updateIcon(iconID, iconentry.element, iconentry.parentx, iconentry.parenty, iconentry.parentwidth)
	widgetSystem.updateMouseOverText(iconID)
end

function widgetSystem.onInputModeChanged(_, mode)
	if (private.interactiveElement ~= nil) and private.interactiveElement.widgetID and IsValidWidgetElement(private.interactiveElement.widgetID) and IsType(private.interactiveElement.widgetID, "table") then
		local tableElement = private.interactiveElement.element
		if (tableElement.highlightMode == "off") and tableElement.scrollBar.active then
			widgetSystem.setScrollBarState(tableElement.scrollBar, "gamepadFocus", mode == "gamepad", private.interactiveElement.widgetID)
		end
	end
end

function widgetSystem.onMouseClickCommon(frameElement)
	local n = C.GetNumCloseOnUnhandledClickFrames()
	if n == 0 then
		return
	end
	local buf = ffi.new("int[?]", n)
	n = C.GetCloseOnUnhandledClickFrames(buf, n)
	for i = 0, n - 1 do
		if buf[i] ~= frameElement.frame then
			widgetSystem.raiseHideEvent(buf[i], "close")
		end
	end
end

function widgetSystem.onMouseClickStandardButton(type, anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local frameElement = widgetSystem.getFrameElementByAnarkStandardButtonElement(anarkElement)
	if frameElement then
		-- can be nil, if we closed the frame before the mouse-event got dispatched
		-- nothing to do otherwise, standard button events are fired in widgetSystem.onMouseUpStandardButton()
		-- no call to widgetSystem.onMouseClickCommon() necessary, otherwise closing a context menu sends an additional unhandled click close
	end
end

function widgetSystem.onMouseClickButton(anarkElement, delayed, modified)
	if delayed then
		return -- ignore delayed clicks
	end

	local buttonElement, frameElement = widgetSystem.getTableCellElementByAnarkElement("button", anarkElement)
	if buttonElement == nil or not buttonElement.active then
		return -- if the button is not active, there's nothing we've to do
	end

	widgetSystem.onMouseClickCommon(frameElement)

	local buttonID = widgetSystem.getWidgetIDByElementEntry(buttonElement)
	widgetSystem.swapButtonIcon(buttonID, buttonElement)

	CallWidgetEventScripts(buttonID, "onClick", "mouse", modified)
end

function widgetSystem.onRightMouseClickButton(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local buttonElement = widgetSystem.getTableCellElementByAnarkElement("button", anarkElement)
	if buttonElement == nil or not buttonElement.active then
		return -- if the button is not active, there's nothing we've to do
	end

	local buttonID = widgetSystem.getWidgetIDByElementEntry(buttonElement)

	local tableElement, widgetID, row, col = widgetSystem.getTableElementByAnarkTableCellElement("button", anarkElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)

	local _, cellwidth = widgetSystem.getColumnSpanInfo(tableID, tableElement, row, col, row <= tableElement.numFixedRows)
	local cellposx = tableElement.cellposx[col] + cellwidth + config.table.bordersize
	local cellposy = tableElement.cellposy[row]
	CallWidgetEventScripts(buttonID, "onRightClick", row, col, cellposx, cellposy)
end

function widgetSystem.onMouseClickCheckBox(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local checkboxElement, frameElement = widgetSystem.getTableCellElementByAnarkElement("checkbox", anarkElement)
	if checkboxElement == nil or not checkboxElement.active then
		return -- if the checkbox is not active, there's nothing we've to do
	end

	local checkboxID = widgetSystem.getWidgetIDByElementEntry(checkboxElement)
	if not IsValidWidgetElement(checkboxID) then
		return -- view might have already been changed
	end

	widgetSystem.onMouseClickCommon(frameElement)

	widgetSystem.toggleCheckBox(checkboxID, checkboxElement)

	CallWidgetEventScripts(checkboxID, "onClick", checkboxElement.checked)
end

function widgetSystem.onMouseClickDropDown(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local dropdownElement, _, frameElement = widgetSystem.getTableCellElementByAnarkElement("dropdown", getElement("parent", anarkElement))
	if dropdownElement == nil or not dropdownElement.active then
		return -- if the button is not active, there's nothing we've to do
	end

	local dropdownID = widgetSystem.getWidgetIDByElementEntry(dropdownElement)
	if not IsValidWidgetElement(dropdownID) then
		return -- view might have already been changed
	end

	widgetSystem.onMouseClickCommon(frameElement)
	
	if (private.activeDropDown ~= nil) and (private.activeDropDown.widgetID == dropdownID) then
		local deleted, active = false, false
		if private.activeDropDown.highlighted ~= 0 then
			local curoption = private.activeDropDown.highlighted + (dropdownElement.topOption or 1) - 1
			deleted = dropdownElement.options[curoption].deleted
			active = dropdownElement.options[curoption].active
			if (not deleted) and active then
				dropdownElement.curOption = dropdownElement.options[curoption]
				C.SetDropDownCurOption(dropdownID, dropdownElement.curOption.id)
				-- we know the mouseout event will happen, we change the state now to avoid flickering in the next frame
				widgetSystem.setDropDownElementState(dropdownID, dropdownElement, "mouseOver", false)
			end
		else
			widgetSystem.hideDropDownOptions(dropdownID, dropdownElement)
		end

		if (not deleted) and active then
			widgetSystem.hideDropDownOptions(dropdownID, dropdownElement)
			widgetSystem.updateDropDown(dropdownID, dropdownElement)

			CallWidgetEventScripts(dropdownID, "onDropDownConfirmed", dropdownElement.curOption.id)
		end
	else
		widgetSystem.showDropDownOptions(frameElement, dropdownID, dropdownElement)
	end
end

function widgetSystem.onMouseClickDropDownPageScroll(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local _, y = GetLocalMouseClickPosition()

	local anarkScrollBarElement = getElement("parent", anarkElement)
	local dropdownElement, _, frameElement = widgetSystem.getTableCellElementByAnarkElement("dropdown", getElement("parent", anarkScrollBarElement))
	local dropdownID = widgetSystem.getWidgetIDByElementEntry(dropdownElement)

	widgetSystem.onMouseClickCommon(frameElement)

	-- for dropdowns the slider is not a top level object
	local sliderPosY = widgetSystem.getScrollBarSliderPosition(anarkScrollBarElement) + dropdownElement.offsety
	if y > sliderPosY then
		widgetSystem.scrollUpDropDown(dropdownID, dropdownElement, dropdownElement.noofVisibleOptions)
	else
		widgetSystem.scrollDownDropDown(dropdownID, dropdownElement, dropdownElement.noofVisibleOptions)
	end
end

function widgetSystem.onMouseClickEditBox(isdblclick, anarkElement, delayed, modified)
	if delayed then
		return -- ignore delayed clicks
	end

	local editboxElement, frameElement = widgetSystem.getTableCellElementByAnarkElement("editbox", anarkElement)
	if editboxElement == nil then
		return -- if the editbox is not visible (or no longer valid), there's nothing we've to do
	end
	
	local editboxID = widgetSystem.getWidgetIDByElementEntry(editboxElement)
	local tableElement, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("editbox", anarkElement)

	widgetSystem.onMouseClickCommon(frameElement)

	if not editboxElement.active then
		widgetSystem.deactivateDirectInputElements()

		widgetSystem.activateEditBoxInternal(frameElement, editboxID, editboxElement)
	elseif not editboxElement.encrypted then
		local bestFit = widgetSystem.getEditBoxCursorPosFromMouse(frameElement, editboxID, editboxElement)
		if bestFit then
			if isdblclick and (modified ~= "shift") then
				local first, second = widgetSystem.findEditBoxWordAtPos(editboxElement, bestFit)
				if first then
					editboxElement.shiftStartPos = first
					editboxElement.cursorPos = second
				end
			elseif editboxElement.mouseClickStart == bestFit then
				editboxElement.mouseClickStart = nil
				if modified == "shift" then
					if not editboxElement.shiftStartPos then
						editboxElement.shiftStartPos = editboxElement.cursorPos
					end
				else
					editboxElement.shiftStartPos = nil
				end

				editboxElement.cursorPos = bestFit
			end
			widgetSystem.updateEditBoxCursorPosition(editboxElement)
			widgetSystem.updateEditBoxTextHighlight(editboxElement)
			CallWidgetEventScripts(editboxID, "onCursorChanged", editboxElement.cursorPos, editboxElement.shiftStartPos)
		end
	end
end

function widgetSystem.onMouseDownEditBox(anarkElement, delayed, modified)
	local editboxElement, frameElement = widgetSystem.getTableCellElementByAnarkElement("editbox", anarkElement)
	if editboxElement == nil then
		return -- if the editbox is not visible (or no longer valid), there's nothing we've to do
	end
	
	local editboxID = widgetSystem.getWidgetIDByElementEntry(editboxElement)
	local tableElement, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("editbox", anarkElement)

	if editboxElement.active and (not editboxElement.encrypted) then
		local bestFit = widgetSystem.getEditBoxCursorPosFromMouse(frameElement, editboxID, editboxElement)
		if bestFit then
			editboxElement.mouseClickStart = bestFit
			editboxElement.isClick = true
			editboxElement.isShiftClick = modified == "shift"
			if modified ~= "shift" then
				editboxElement.shiftStartPos = nil
			end
		end
	end
end

function widgetSystem.onMouseUpEditBox(anarkElement, delayed, modified)
	local editboxElement, frameElement = widgetSystem.getTableCellElementByAnarkElement("editbox", anarkElement)
	if editboxElement == nil then
		return -- if the editbox is not visible (or no longer valid), there's nothing we've to do
	end
	
	local editboxID = widgetSystem.getWidgetIDByElementEntry(editboxElement)
	local tableElement, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("editbox", anarkElement)

	if editboxElement.active and (not editboxElement.encrypted) then
		local bestFit = widgetSystem.getEditBoxCursorPosFromMouse(frameElement, editboxID, editboxElement)
		if bestFit then
			if editboxElement.mouseClickStart and (editboxElement.mouseClickStart ~= bestFit) then
				if (modified ~= "shift") or (not editboxElement.shiftStartPos) then
					editboxElement.shiftStartPos = editboxElement.mouseClickStart
				end
				editboxElement.cursorPos = bestFit
				widgetSystem.updateEditBoxCursorPosition(editboxElement)
				widgetSystem.updateEditBoxTextHighlight(editboxElement)
				CallWidgetEventScripts(editboxID, "onCursorChanged", editboxElement.cursorPos, editboxElement.shiftStartPos)
				editboxElement.mouseClickStart = nil
			end
		end
	end
end

function widgetSystem.onRightMouseClickEditBox(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local editboxElement = widgetSystem.getTableCellElementByAnarkElement("editbox", anarkElement)
	if editboxElement == nil then
		return -- if the editbox is not visible (or no longer valid), there's nothing we've to do
	end

	local editboxID = widgetSystem.getWidgetIDByElementEntry(editboxElement)

	CallWidgetEventScripts(editboxID, "onRightClick")
end

function widgetSystem.onMouseClickGraphDataPoint(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local graphElement, data = widgetSystem.getTableCellElementByAnarkElement("graph", anarkElement)
	if graphElement == nil then
		return
	end
	if data[2].inactive then
		return
	end

	local graphID = widgetSystem.getWidgetIDByElementEntry(graphElement)
	CallWidgetEventScripts(graphID, "onClick", data)
end

function widgetSystem.onMouseClickHelpOverlay(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local rootAnarkElement = getElement("parent", anarkElement)
	for id, entry in pairs(private.displayedHelpOverlays) do
		if entry.element == rootAnarkElement then
			local frameElement = private.overlayAssociation[id]
			widgetSystem.onMouseClickCommon(frameElement)

			if not private.helpOverlayDisplayed then
				private.signalledHelpOverlays[id] = nil
				widgetSystem.hideHelpOverlayID(id)
			end
		end
	end
end

function widgetSystem.onMouseClickPageScroll(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local _, y = GetLocalMouseClickPosition()

	local anarkScrollBarElement = getElement("parent", anarkElement)
	local sliderPosY = widgetSystem.getScrollBarSliderPosition(anarkScrollBarElement)

	local tableElement, frameElement = widgetSystem.getTableElementByScrollBar(anarkScrollBarElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)

	widgetSystem.onMouseClickCommon(frameElement)

	if y > sliderPosY then
		widgetSystem.scrollPageUp(tableID, tableElement)
	else
		widgetSystem.scrollPageDown(tableID, tableElement)
	end
end

function widgetSystem.onMouseRenderTarget(event, anarkElement, delayed, modified)
	if delayed then
		return -- ignore delayed clicks
	end

	local renderTargetElement, frameElement = widgetSystem.getRenderTargetElementByAnarkElement(anarkElement)
	local renderTargetID = widgetSystem.getWidgetIDByElementEntry(renderTargetElement)

	if event == "onClick" then
		widgetSystem.onMouseClickCommon(frameElement)
	end

	CallWidgetEventScripts(renderTargetID, event, modified)
end

function widgetSystem.scrollDownRenderTarget(renderTargetID)
	CallWidgetEventScripts(renderTargetID, "onScrollDown")
end

function widgetSystem.combinedScrollDownRenderTarget(renderTargetID, step)
	CallWidgetEventScripts(renderTargetID, "onCombinedScrollDown", step)
end

function widgetSystem.scrollUpRenderTarget(renderTargetID)
	CallWidgetEventScripts(renderTargetID, "onScrollUp")
end

function widgetSystem.combinedScrollUpRenderTarget(renderTargetID, step)
	CallWidgetEventScripts(renderTargetID, "onCombinedScrollUp", step)
end

function widgetSystem.onMouseClickSliderCellNumber(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement, frameElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	if slidercellElement == nil then
		return -- if the slidercell is not visible (or no longer valid), there's nothing we've to do
	end

	widgetSystem.onMouseClickCommon(frameElement)

	if not slidercellElement.inputActive then
		if not slidercellElement.readonly then
			widgetSystem.deactivateDirectInputElements()

			local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)
			widgetSystem.activateSliderCellInputInternal(slidercellID, slidercellElement)
		end

		local tableElement, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", anarkSliderCellElement)
		widgetSystem.setActiveFrame(frameElement)
		widgetSystem.setInteractiveElement(frameElement.frame, widgetID)
		widgetSystem.selectRow(widgetID, row, nil, nil, "user")

		CallWidgetEventScripts(slidercellID, "onSliderCellDown")
	end
end

function widgetSystem.onMouseOverSliderCellNumber(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", anarkSliderCellElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", true, row)
		
		if not slidercellElement.readonly then
			widgetSystem.setMouseCursorOverrideInternal("textinput")
		end
	end
end

function widgetSystem.onMouseOutSliderCellNumber(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", anarkSliderCellElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", false, row)

		widgetSystem.setMouseCursorOverrideInternal()
	end
end

function widgetSystem.onMouseDownSliderCell(anarkElement)
	widgetSystem.deactivateDirectInputElements()

	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement, frameElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)
	local tableElement, tableID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", anarkSliderCellElement)

	if slidercellElement.inputActive then
		widgetSystem.confirmSliderCellInputInternal(slidercellID, slidercellElement)
	end

	-- check if widget is still valid, the hook in "onSliderCellConfirm" could have destroyed the widget
	if IsValidWidgetElement(slidercellID) then
		if not slidercellElement.readonly then
			local x = widgetSystem.getSliderCellMousePosition(frameElement, slidercellID)
			local curx = widgetSystem.getSliderCellXPositionFromValue(slidercellElement, tonumber(slidercellElement.cur) or 0)
			private.slidercellDrag = { frameElement = frameElement, widgetID = slidercellID, clickStart = x, clickOffset = x - curx, wasDragged = false }
			widgetSystem.setMouseCursorOverrideInternalDrag("slider")

			CallWidgetEventScripts(slidercellID, "onSliderCellActivated")
			CallWidgetEventScripts(slidercellID, "onSliderCellDown")
		end
		widgetSystem.setActiveFrame(frameElement)
		widgetSystem.setInteractiveElement(frameElement.frame, tableID)
		widgetSystem.selectRow(tableID, row, nil, nil, "user")
	end
end

function widgetSystem.onMouseUpSliderCell(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement, frameElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)
	local tableElement, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", anarkSliderCellElement)

	if not slidercellElement.readonly then
		local x = widgetSystem.getSliderCellMousePosition(frameElement, slidercellID)
		if private.slidercellDrag and (private.slidercellDrag.widgetID == slidercellID) then
			if (not private.slidercellDrag.wasDragged) and (math.abs(x - private.slidercellDrag.clickStart) < 0.01) then
				widgetSystem.setSliderCellCurValue(slidercellElement, widgetSystem.getSliderCellValueFromXPosition(slidercellElement, x), false, true)
				widgetSystem.updateSliderCellValue(slidercellElement)
			elseif private.slidercellDrag.wasDragged then
				-- another update to adjust the maxfactor
				widgetSystem.setSliderCellCurValue(slidercellElement, slidercellElement.cur, false, true)
				widgetSystem.updateSliderCellValue(slidercellElement)
			end

			CallWidgetEventScripts(slidercellID, "onSliderCellDeactivated")
			CallWidgetEventScripts(slidercellID, "onSliderCellConfirm", slidercellElement.cur, slidercellElement.cur ~= slidercellElement.oldcur)
		end

		widgetSystem.setMouseCursorOverrideInternalDrag()
		private.slidercellDrag = nil
	end
end

function widgetSystem.onMouseDownSliderCellArrowLeft(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	if slidercellElement == nil then
		return
	end
	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)

	if slidercellElement.inputActive then
		widgetSystem.confirmSliderCellInputInternal(slidercellID, slidercellElement)
	end

	if not slidercellElement.readonly then
		if widgetSystem.startSliderCellScroll(slidercellElement, -1) then
			widgetSystem.setSliderCellArrowState(widgetSystem.getWidgetIDByElementEntry(slidercellElement), "left", "mouseDown", true)
		end
	end

	CallWidgetEventScripts(slidercellID, "onSliderCellActivated")
	CallWidgetEventScripts(slidercellID, "onSliderCellLeftDown")
end

function widgetSystem.onMouseDownSliderCellArrowRight(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	if slidercellElement == nil then
		return
	end
	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)

	if slidercellElement.inputActive then
		widgetSystem.confirmSliderCellInputInternal(slidercellID, slidercellElement)
	end

	if not slidercellElement.readonly then
		if widgetSystem.startSliderCellScroll(slidercellElement, 1) then
			widgetSystem.setSliderCellArrowState(widgetSystem.getWidgetIDByElementEntry(slidercellElement), "right", "mouseDown", true)
		end
	end

	CallWidgetEventScripts(slidercellID, "onSliderCellActivated")
	CallWidgetEventScripts(slidercellID, "onSliderCellRightDown")
end

function widgetSystem.onMouseDownSliderCellArrowSkipLeft(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	if slidercellElement == nil then
		return
	end
	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)

	if slidercellElement.inputActive then
		widgetSystem.confirmSliderCellInputInternal(slidercellID, slidercellElement)
	end

	if not slidercellElement.readonly then
		widgetSystem.setSliderCellArrowState(widgetSystem.getWidgetIDByElementEntry(slidercellElement), "skip_left", "mouseDown", true)
	end

	CallWidgetEventScripts(slidercellID, "onSliderCellActivated")
	CallWidgetEventScripts(slidercellID, "onSliderCellSkipLeftDown")
end

function widgetSystem.onMouseDownSliderCellArrowSkipRight(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	if slidercellElement == nil then
		return
	end
	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)

	if slidercellElement.inputActive then
		widgetSystem.confirmSliderCellInputInternal(slidercellID, slidercellElement)
	end

	if not slidercellElement.readonly then
		widgetSystem.setSliderCellArrowState(widgetSystem.getWidgetIDByElementEntry(slidercellElement), "skip_right", "mouseDown", true)
	end

	CallWidgetEventScripts(slidercellID, "onSliderCellActivated")
	CallWidgetEventScripts(slidercellID, "onSliderCellSkipRightDown")
end

function widgetSystem.onMouseOutSliderCellArrowLeft(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	widgetSystem.setSliderCellArrowState(widgetSystem.getWidgetIDByElementEntry(slidercellElement), "left", "mouseOver", false)

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", anarkSliderCellElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", false, row)
	end
end

function widgetSystem.onMouseOutSliderCellArrowRight(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	widgetSystem.setSliderCellArrowState(widgetSystem.getWidgetIDByElementEntry(slidercellElement), "right", "mouseOver", false)

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", anarkSliderCellElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", false, row)
	end
end

function widgetSystem.onMouseOutSliderCellArrowSkipLeft(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	widgetSystem.setSliderCellArrowState(widgetSystem.getWidgetIDByElementEntry(slidercellElement), "skip_left", "mouseOver", false)

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", anarkSliderCellElement)
	if element then
		widgetSystem.setMouseOverOverride(widgetID)
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", false, row)
	end
end

function widgetSystem.onMouseOutSliderCellArrowSkipRight(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	widgetSystem.setSliderCellArrowState(widgetSystem.getWidgetIDByElementEntry(slidercellElement), "skip_right", "mouseOver", false)

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", anarkSliderCellElement)
	if element then
		widgetSystem.setMouseOverOverride(widgetID)
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", false, row)
	end
end

function widgetSystem.onMouseOverSliderCellArrowLeft(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)
	if not private.slidercellDrag then
		widgetSystem.setSliderCellArrowState(widgetSystem.getWidgetIDByElementEntry(slidercellElement), "left", "mouseOver", true)
	end

	CallWidgetEventScripts(slidercellID, "onSliderCellLeftOver")

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", anarkSliderCellElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", true, row)

		widgetSystem.setMouseCursorOverrideInternal()
	end
end

function widgetSystem.onMouseOverSliderCellArrowRight(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)
	if not private.slidercellDrag then
		widgetSystem.setSliderCellArrowState(widgetSystem.getWidgetIDByElementEntry(slidercellElement), "right", "mouseOver", true)
	end

	CallWidgetEventScripts(slidercellID, "onSliderCellRightOver")

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", anarkSliderCellElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", true, row)

		widgetSystem.setMouseCursorOverrideInternal()
	end
end

function widgetSystem.onMouseOverSliderCellArrowSkipLeft(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)
	if not private.slidercellDrag then
		widgetSystem.setSliderCellArrowState(widgetSystem.getWidgetIDByElementEntry(slidercellElement), "skip_left", "mouseOver", true)
	end

	CallWidgetEventScripts(slidercellID, "onSliderCellSkipLeftOver")
	
	local mouseovertext = slidercellElement.fromcenter and L["slidercell_skip_left"] or (slidercellElement.righttoleft and L["slidercell_skip_left_max"] or L["slidercell_skip_left_min"])
	local inputtext = ffi.string(C.GetMappedInputName("INPUT_STATE_SLIDERCELL_SCROLL_LEFT_SHIFT"))
	if inputtext ~= "" then
		mouseovertext = mouseovertext .. " - " .. inputtext
	end
	widgetSystem.setMouseOverOverride(slidercellID, mouseovertext)

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", anarkSliderCellElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", true, row)

		widgetSystem.setMouseCursorOverrideInternal()
	end
end

function widgetSystem.onMouseOverSliderCellArrowSkipRight(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)
	if not private.slidercellDrag then
		widgetSystem.setSliderCellArrowState(widgetSystem.getWidgetIDByElementEntry(slidercellElement), "skip_right", "mouseOver", true)
	end

	CallWidgetEventScripts(slidercellID, "onSliderCellSkipRightOver")
	
	local mouseovertext = slidercellElement.fromcenter and L["slidercell_skip_right"] or (slidercellElement.righttoleft and L["slidercell_skip_right_min"] or L["slidercell_skip_right_max"])
	local inputtext = ffi.string(C.GetMappedInputName("INPUT_STATE_SLIDERCELL_SCROLL_RIGHT_SHIFT"))
	if inputtext ~= "" then
		mouseovertext = mouseovertext .. " - " .. inputtext
	end
	widgetSystem.setMouseOverOverride(slidercellID, mouseovertext)

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", anarkSliderCellElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", true, row)

		widgetSystem.setMouseCursorOverrideInternal()
	end
end

function widgetSystem.onMouseUpSliderCellArrowLeft(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)
	if not slidercellElement.readonly then
		if widgetSystem.stopSliderCellScroll(slidercellElement) then
			widgetSystem.setSliderCellArrowState(slidercellID, "left", "mouseDown", false)
			CallWidgetEventScripts(slidercellID, "onSliderCellDeactivated")
			CallWidgetEventScripts(slidercellID, "onSliderCellConfirm", slidercellElement.cur, true)
		end
	end
end

function widgetSystem.onMouseUpSliderCellArrowRight(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)
	if not slidercellElement.readonly then
		if widgetSystem.stopSliderCellScroll(slidercellElement) then
			widgetSystem.setSliderCellArrowState(slidercellID, "right", "mouseDown", false)
			CallWidgetEventScripts(slidercellID, "onSliderCellDeactivated")
			CallWidgetEventScripts(slidercellID, "onSliderCellConfirm", slidercellElement.cur, true)
		end
	end
end

function widgetSystem.onMouseUpSliderCellArrowSkipLeft(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)

	if not slidercellElement.readonly then
		widgetSystem.setSliderCellCurValue(slidercellElement, slidercellElement.righttoleft and (slidercellElement.maxfactor * slidercellElement.maxSelect) or slidercellElement.minSelect, false, true)
		widgetSystem.updateSliderCellValue(slidercellElement)

		widgetSystem.setSliderCellArrowState(slidercellID, "skip_left", "mouseDown", false)
		CallWidgetEventScripts(slidercellID, "onSliderCellDeactivated")
		CallWidgetEventScripts(slidercellID, "onSliderCellConfirm", slidercellElement.cur, true)
	end
end

function widgetSystem.onMouseUpSliderCellArrowSkipRight(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)

	if not slidercellElement.readonly then
		widgetSystem.setSliderCellCurValue(slidercellElement, slidercellElement.righttoleft and slidercellElement.minSelect or (slidercellElement.maxfactor * slidercellElement.maxSelect), false, true)
		widgetSystem.updateSliderCellValue(slidercellElement)

		widgetSystem.setSliderCellArrowState(slidercellID, "skip_right", "mouseDown", false)
		CallWidgetEventScripts(slidercellID, "onSliderCellDeactivated")
		CallWidgetEventScripts(slidercellID, "onSliderCellConfirm", slidercellElement.cur, true)
	end
end

function widgetSystem.onRightMouseClickSliderCell(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkElement)
	if slidercellElement == nil or slidercellElement.readonly then
		return -- if the editbox is not visible (or no longer valid), there's nothing we've to do
	end

	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)

	local tableElement, widgetID, row, col = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", anarkElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)

	local _, cellwidth = widgetSystem.getColumnSpanInfo(tableID, tableElement, row, col, row <= tableElement.numFixedRows)
	local cellposx = tableElement.cellposx[col] + cellwidth + config.table.bordersize
	local cellposy = tableElement.cellposy[row]
	CallWidgetEventScripts(slidercellID, "onRightClick", row, col, cellposx, cellposy)
end

function widgetSystem.onMouseClickTableCell(isdblclick, anarkElement, delayed, modified)
	if delayed then
		return -- ignore delayed clicks
	end

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("cell", anarkElement)
	-- check if it's clicked on a table
	if not element then
		-- #StefanMed - refactor so to reset interactive/noninteractive table mouse events --- spares us this check here
		return -- anarkelement isn't a table cell element
	end

	local frameElement = widgetSystem.getFrameElementByTableElement(element)
	widgetSystem.setActiveFrame(frameElement)
	widgetSystem.onMouseClickCommon(frameElement)

	if (not widgetID) or (not IsValidWidgetElement(widgetID)) then
		return -- tableElement was already hidden, can happen when double clicking an already selected table cell
	end

	if not IsInteractive(widgetID) then
		return -- clicked on a table element, but the table isn't interactive
	end

	widgetSystem.setInteractiveElement(frameElement.frame, widgetID, true, false)

	if element.multiSelect then
		if (modified ~= "ctrl") and element.highlightedRows[row] then
			-- enter the already selected row
			widgetSystem.selectRow(widgetID, row, modified, "mouse", "user")
			CallWidgetEventScripts(widgetID, "onClick", modified, row, isdblclick, "mouse")
		else
			-- just select the new row
			widgetSystem.selectRow(widgetID, row, modified, "mouse", "user")
		end
	else
		if element.curRow == row then
			-- enter the already selected row
			CallWidgetEventScripts(widgetID, "onClick", modified, row, isdblclick, "mouse")
		else
			-- just select the new row
			widgetSystem.selectRow(widgetID, row, modified, "mouse", "user")
		end
	end
	if private.activeEditBox ~= nil then
		widgetSystem.confirmEditBoxInputInternal(private.activeEditBox.editboxID, private.activeEditBox.editboxElement, true, true)
	end
	if private.activeSliderCell ~= nil then
		widgetSystem.confirmSliderCellInputInternal(private.activeSliderCell.widgetID, private.activeSliderCell.element)
	end
end

function widgetSystem.onMouseDblClickButton(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local buttonElement = widgetSystem.getTableCellElementByAnarkElement("button", anarkElement)
	if buttonElement == nil or not buttonElement.active then
		return -- if the button is not active, there's nothing we've to do
	end

	local buttonID = widgetSystem.getWidgetIDByElementEntry(buttonElement)
	CallWidgetEventScripts(buttonID, "onDoubleClick")
end

function widgetSystem.onMouseDblClickCheckBox(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local checkboxElement = widgetSystem.getTableCellElementByAnarkElement("checkbox", anarkElement)
	if checkboxElement == nil or not checkboxElement.active then
		return -- if the checkbox is not active, there's nothing we've to do
	end

	local checkboxID = widgetSystem.getWidgetIDByElementEntry(checkboxElement)
	if not IsValidWidgetElement(checkboxID) then
		return -- view might have already been changed
	end

	widgetSystem.toggleCheckBox(checkboxID, checkboxElement)

	CallWidgetEventScripts(checkboxID, "onClick", checkboxElement.checked)
end

function widgetSystem.onMouseDblClickDropDown(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local dropdownElement = widgetSystem.getTableCellElementByAnarkElement("dropdown", getElement("parent", anarkElement))
	if dropdownElement == nil or not dropdownElement.active then
		return -- if the button is not active, there's nothing we've to do
	end
end

function widgetSystem.onRightMouseClickTableCell(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("cell", anarkElement)
	-- check if it's clicked on a table
	if not element then
		-- #StefanMed - refactor so to reset interactive/noninteractive table mouse events --- spares us this check here
		return -- anarkelement isn't a table cell element
	end

	local frameElement = widgetSystem.getFrameElementByTableElement(element)
	widgetSystem.setActiveFrame(frameElement)

	if (not widgetID) or (not IsValidWidgetElement(widgetID)) then
		return -- tableElement was already hidden, can happen when double clicking an already selected table cell
	end

	if element.curRow ~= row then
		-- select the new row
		widgetSystem.selectRow(widgetID, row, "ctrl", "rightmouse", "user")
	end

	CallWidgetEventScripts(widgetID, "onRightClick", row)
end

function widgetSystem.onMouseDownStandardButton(type, anarkElement)
	local frameElement = widgetSystem.getFrameElementByAnarkStandardButtonElement(anarkElement)
	if frameElement then
		local frameID = widgetSystem.getWidgetIDByElementEntry(frameElement)
		widgetSystem.setStandardButtonState(frameID, frameElement, type, "mouseClick", true)
	end
end

function widgetSystem.onMouseDownButton(anarkElement)
	local buttonElement = widgetSystem.getTableCellElementByAnarkElement("button", anarkElement)
	if buttonElement == nil or not buttonElement.active then
		return -- if the button is not active, there's nothing we've to do
	end

	local buttonID = widgetSystem.getWidgetIDByElementEntry(buttonElement)
	if not IsValidWidgetElement(buttonID) then
		return -- view might have already been changed
	end

	widgetSystem.setButtonElementState(buttonID, buttonElement, "mouseClick", true)
end

function widgetSystem.onMouseDownDropDown(anarkElement)
	local dropdownElement = widgetSystem.getTableCellElementByAnarkElement("dropdown", getElement("parent", anarkElement))
	if dropdownElement == nil or not dropdownElement.active then
		return -- if the dropdown is not active, there's nothing we've to do
	end

	local dropdownID = widgetSystem.getWidgetIDByElementEntry(dropdownElement)
	if not IsValidWidgetElement(dropdownID) then
		return -- view might have already been changed
	end
	
	local deleted = false
	if (private.activeDropDown ~= nil) and (private.activeDropDown.widgetID == dropdownID) then
		if private.activeDropDown.highlighted ~= 0 then
			local curoption = private.activeDropDown.highlighted + (dropdownElement.topOption or 1) - 1
			deleted = dropdownElement.options[curoption].deleted
		end
	end

	if not deleted then
		widgetSystem.setDropDownElementState(dropdownID, dropdownElement, "mouseClick", true)
	end
end

function widgetSystem.onMouseDownDropDownRemoveOption(anarkElement)
	local anarkDropDownOptionElement = getElement("parent", anarkElement)
	local dropdownElement = widgetSystem.getTableCellElementByAnarkElement("dropdown", anarkDropDownOptionElement)
	if dropdownElement == nil or not dropdownElement.active then
		return -- if the dropdown is not active, there's nothing we've to do
	end

	local dropdownID = widgetSystem.getWidgetIDByElementEntry(dropdownElement)
	widgetSystem.setDropDownRemoveOptionState(dropdownID, anarkElement, "mouseDown", true)
end

function widgetSystem.onMouseEmulationActivated(anarkElement)
	if private.mouseOverText then
		if private.mouseOverText.posOverride then
			widgetSystem.hideMouseOverText(private.mouseOverText.widgetID)
		end
	end
end

function widgetSystem.onMouseEmulationDeactivated(anarkElement)
	if private.enableMouseOverText then
		if GetControllerInfo() == "gamepad" then
			if private.interactiveElement ~= nil and IsType(private.interactiveElement.widgetID, "table") then
				local tableElement = private.interactiveElement.element
				local interactiveChild = tableElement.interactiveChild

				local mouseoverwidgetid, row, col
				if interactiveChild then
					if ffi.string(C.GetMouseOverText(interactiveChild.widgetID)) ~= "" then
						private.gamepadInteractiveChildMouseOver = true
						mouseoverwidgetid = interactiveChild.widgetID
						row = interactiveChild.row
						col = interactiveChild.col
					end
				elseif tableElement.highlightedBorderRow then
					local isNormalRegion = (tableElement.highlightedBorderRow > tableElement.numFixedRows)
					for col = 1, tableElement.numCols do
						local colspan = widgetSystem.getColumnSpanInfo(private.interactiveElement.widgetID, tableElement, tableElement.highlightedBorderRow, col, not isNormalRegion)
						if colspan ~= 0 then
							local childWidgetID = GetCellContent(private.interactiveElement.widgetID, tableElement.highlightedBorderRow, col)
							if ffi.string(C.GetMouseOverText(childWidgetID)) ~= "" then
								private.gamepadTableMouseOver = true
								mouseoverwidgetid = childWidgetID
								row = tableElement.highlightedBorderRow
							end
						end
					end
				end

				if mouseoverwidgetid then
					local isNormalRegion = (row > tableElement.numFixedRows)
					local cellposx = tableElement.cellposx[1] + tableElement.width
					if col then
						cellposx = isNormalRegion and tableElement.cellposx[col] or tableElement.fixedRowCellposx[col]
						local _, cellwidth = widgetSystem.getColumnSpanInfo(private.interactiveElement.widgetID, tableElement, row, col, not isNormalRegion)
						cellposx = cellposx + cellwidth
					end
					local cellposy = tableElement.cellposy[row]
					widgetSystem.showMouseOverText(mouseoverwidgetid, nil, { x = cellposx, y = cellposy })
				end
			end
		end
	end
end

function widgetSystem.onMouseUpDropDownRemoveOption(anarkElement)
	local anarkDropDownOptionElement = getElement("parent", anarkElement)
	local dropdownElement, _, frameElement = widgetSystem.getTableCellElementByAnarkElement("dropdown", anarkDropDownOptionElement)
	if dropdownElement == nil or not dropdownElement.active then
		return -- if the dropdown is not active, there's nothing we've to do
	end

	local dropdownID = widgetSystem.getWidgetIDByElementEntry(dropdownElement)
	widgetSystem.setDropDownRemoveOptionState(dropdownID, anarkElement, "mouseDown", false)

	if (private.activeDropDown ~= nil) and (private.activeDropDown.widgetID == dropdownID) then
		if private.activeDropDown.highlighted ~= 0 then
			local curoption = private.activeDropDown.highlighted + (dropdownElement.topOption or 1) - 1
			dropdownElement.options[curoption].deleted = true
			if dropdownElement.curOption.id == dropdownElement.options[curoption].id then
				widgetSystem.updateDropDown(dropdownID, dropdownElement)
			end
			widgetSystem.updateDropDownOptions(frameElement, dropdownID, dropdownElement, dropdownElement.topOption, true)
			CallWidgetEventScripts(dropdownID, "onDropDownRemoved", dropdownElement.options[curoption].id)
		end
	end
end

function widgetSystem.onMouseOverDropDownRemoveOption(anarkElement)
	local anarkDropDownOptionElement = getElement("parent", anarkElement)
	local dropdownElement = widgetSystem.getTableCellElementByAnarkElement("dropdown", anarkDropDownOptionElement)
	if dropdownElement == nil or not dropdownElement.active then
		return -- if the dropdown is not active, there's nothing we've to do
	end

	local dropdownID = widgetSystem.getWidgetIDByElementEntry(dropdownElement)
	widgetSystem.setDropDownElementState(dropdownID, dropdownElement, "mouseOver", true)
	widgetSystem.setDropDownRemoveOptionState(dropdownID, anarkElement, "mouseOver", true)

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("dropdown", anarkDropDownOptionElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", true, row)
	end
end

function widgetSystem.onMouseOutDropDownRemoveOption(anarkElement)
	local anarkDropDownOptionElement = getElement("parent", anarkElement)
	local dropdownElement = widgetSystem.getTableCellElementByAnarkElement("dropdown", anarkDropDownOptionElement)
	if dropdownElement == nil or not dropdownElement.active then
		return -- if the dropdown is not active, there's nothing we've to do
	end

	local dropdownID = widgetSystem.getWidgetIDByElementEntry(dropdownElement)
	widgetSystem.setDropDownElementState(dropdownID, dropdownElement, "mouseOver", false)
	widgetSystem.setDropDownRemoveOptionState(dropdownID, anarkElement, "mouseOver", false)

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("dropdown", anarkDropDownOptionElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", false, row)
	end
end

function widgetSystem.onMouseOutStandardButton(type, anarkElement)
	local frameElement = widgetSystem.getFrameElementByAnarkStandardButtonElement(anarkElement)
	if frameElement then
		local frameID = widgetSystem.getWidgetIDByElementEntry(frameElement)
		widgetSystem.setStandardButtonState(frameID, frameElement, type, "mouseOver", false)

		widgetSystem.setMouseCursorOverrideInternal()
	end
end

function widgetSystem.onMouseOutBoxText(anarkElement)
	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("boxtext", anarkElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", false, row)
	end
end

function widgetSystem.onMouseOutButton(anarkElement)
	local buttonElement = widgetSystem.getTableCellElementByAnarkElement("button", anarkElement)
	if buttonElement == nil then
		return
	end

	local buttonID = widgetSystem.getWidgetIDByElementEntry(buttonElement)
	if not IsValidWidgetElement(buttonID) then
		return -- view might have already been changed
	end
	
	if buttonElement.active then
		widgetSystem.setButtonElementState(buttonID, buttonElement, "mouseOver", false)
	end
	
	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("button", anarkElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", false, row)
	end
end

function widgetSystem.onMouseOutCheckBox(anarkElement)
	local checkboxElement = widgetSystem.getTableCellElementByAnarkElement("checkbox", anarkElement)
	if checkboxElement == nil then
		return
	end

	local checkboxID = widgetSystem.getWidgetIDByElementEntry(checkboxElement)
	if not IsValidWidgetElement(checkboxID) then
		return -- view might have already been changed
	end
	
	if checkboxElement.active then
		widgetSystem.setCheckBoxElementState(checkboxID, checkboxElement, "mouseOver", false)
	end
	
	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("checkbox", anarkElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", false, row)
	end
end

function widgetSystem.onMouseOutDropDown(anarkElement)
	local dropdownElement = widgetSystem.getTableCellElementByAnarkElement("dropdown", anarkElement)
	if dropdownElement == nil then
		return
	end

	local dropdownID = widgetSystem.getWidgetIDByElementEntry(dropdownElement)
	if not IsValidWidgetElement(dropdownID) then
		return -- view might have already been changed
	end

	if ffi.string(C.GetMouseOverText(dropdownID)) == "" then
		if dropdownElement.curOption.mouseovertext ~= "" then
			widgetSystem.setMouseOverOverride(dropdownID)
			dropdownElement.mouseOverOverrideSet = nil
		end
	end

	if dropdownElement.active then
		widgetSystem.setDropDownElementState(dropdownID, dropdownElement, "mouseOver", false)
	end

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("dropdown", anarkElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", false, row)
	end

	widgetSystem.setMouseOverOverride(dropdownID, nil, true)
end

function widgetSystem.onMouseOutDropDownScrollBar(anarkElement)
	local anarkDropDownElement = getElement("parent.parent", anarkElement)
	local dropdownElement = widgetSystem.getTableCellElementByAnarkElement("dropdown", anarkDropDownElement)
	local dropdownID = widgetSystem.getWidgetIDByElementEntry(dropdownElement)
	
	widgetSystem.setScrollBarState(dropdownElement.element.scrollBar, "mouseOver", false, dropdownID)
end

function widgetSystem.onMouseOutEditBox(anarkElement)
	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("editbox", anarkElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", false, row)
	end
	widgetSystem.setMouseCursorOverrideInternal()
end

function widgetSystem.onMouseOutGraphDataPoint(anarkElement)
	local graphElement = widgetSystem.getTableCellElementByAnarkElement("graph", anarkElement)
	if graphElement == nil then
		return
	end

	local graphID = widgetSystem.getWidgetIDByElementEntry(graphElement)
	private.mouseOverOverrideText = nil
end

function widgetSystem.onMouseOutGraphIcon(anarkElement)
	local graphElement = widgetSystem.getTableCellElementByAnarkElement("graph", anarkElement)
	if graphElement == nil then
		return
	end

	local graphID = widgetSystem.getWidgetIDByElementEntry(graphElement)
	private.mouseOverOverrideText = nil
end

function widgetSystem.onMouseOutHelpOverlay(anarkElement)
	local rootAnarkElement = getElement("parent", anarkElement)
	for id, entry in pairs(private.displayedHelpOverlays) do
		if entry.element == rootAnarkElement then
			private.helpOverlayStates[id] = nil
			widgetSystem.updateHelpOverlayColor(entry.element, false, entry.iconsize, entry.borderonly, getElapsedTime())
			entry.mouseOver = false
			private.mouseOverOverrideText = nil
		end
	end
end

function widgetSystem.onMouseOutSliderCell(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", anarkSliderCellElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", false, row)

		widgetSystem.setMouseCursorOverrideInternal()
	end
end

function widgetSystem.onMouseOutPageScroll(anarkElement)
	local tableElement = widgetSystem.getTableElementByScrollBar(anarkElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)
	if tableElement then
		widgetSystem.setTableMousePickState(tableID, tableElement, "mouseOver", false)
	end
end

function widgetSystem.onMouseOutTableScrollBar(anarkElement)
	local anarkScrollBarElement = getElement("parent", anarkElement)
	local tableElement = widgetSystem.getTableElementByScrollBar(anarkScrollBarElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)
	if tableElement then
		widgetSystem.setScrollBarState(tableElement.scrollBar, "mouseOver", false, tableID)
	end
end

function widgetSystem.onMouseOutTable(anarkElement)
	local tableElement = widgetSystem.getTableElementByMousePick(anarkElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)
	
	if tableElement then
		widgetSystem.setTableMousePickState(tableID, tableElement, "mouseOver", false)
	end
end

function widgetSystem.onMouseOutTableCell(anarkElement)
	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("cell", anarkElement)
	
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", false, row)
	end
end

function widgetSystem.onMouseOver(_, _, anarkElement)
	local rootAnarkElement = widgetSystem.getRootAnarkElement(anarkElement)
	if private.currentMouseAnarkElement ~= rootAnarkElement then
		private.currentMouseAnarkElement = rootAnarkElement
		if next(private.currentMouseWidgetElementLimbo) then
			widgetSystem.returnElement(private.currentMouseWidgetElementLimbo.type, private.currentMouseWidgetElementLimbo.element)
			private.currentMouseWidgetElementLimbo = {}
		end
	end
	if private.enableMouseOverText then
		if (GetControllerInfo() ~= "gamepad") or C.IsMouseEmulationActive() then
			local widgetID = rootAnarkElement and widgetSystem.getWidgetIDByAnarkElementEntry(rootAnarkElement) or nil
			widgetSystem.showMouseOverText(widgetID)
		end
	end
end

function widgetSystem.onMouseOut(_, anarkElement)
	if private.enableMouseOverText then
		if (GetControllerInfo() ~= "gamepad") or C.IsMouseEmulationActive() then
			local rootAnarkElement = widgetSystem.getRootAnarkElement(anarkElement)
			local widgetID = rootAnarkElement and widgetSystem.getWidgetIDByAnarkElementEntry(rootAnarkElement) or nil
			if private.mouseOverText and (not private.mouseOverText.posOverride) then
				widgetSystem.hideMouseOverText(widgetID)
			end
		end
	end
end

function widgetSystem.onMouseOverStandardButton(type, anarkElement)
	local frameElement = widgetSystem.getFrameElementByAnarkStandardButtonElement(anarkElement)
	if frameElement then
		local frameID = widgetSystem.getWidgetIDByElementEntry(frameElement)
		widgetSystem.setStandardButtonState(frameID, frameElement, type, "mouseOver", true)

		widgetSystem.setMouseCursorOverrideInternal("default")
	end
end

function widgetSystem.onMouseOverBoxText(anarkElement)
	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("boxtext", anarkElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", true, row)
	end
end

function widgetSystem.onMouseOverButton(anarkElement)
	local buttonElement = widgetSystem.getTableCellElementByAnarkElement("button", anarkElement)
	if buttonElement == nil then
		return
	end

	local buttonID = widgetSystem.getWidgetIDByElementEntry(buttonElement)
	if not IsValidWidgetElement(buttonID) then
		return -- view might have already been changed
	end
	
	if buttonElement.active then
		widgetSystem.setButtonElementState(buttonID, buttonElement, "mouseOver", true)
	end

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("button", anarkElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", true, row)
	end
end

function widgetSystem.onMouseOverCheckBox(anarkElement)
	local checkboxElement = widgetSystem.getTableCellElementByAnarkElement("checkbox", anarkElement)
	if checkboxElement == nil then
		return
	end

	local checkboxID = widgetSystem.getWidgetIDByElementEntry(checkboxElement)
	if not IsValidWidgetElement(checkboxID) then
		return -- view might have already been changed
	end
	
	if checkboxElement.active then
		widgetSystem.setCheckBoxElementState(checkboxID, checkboxElement, "mouseOver", true)
	end

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("checkbox", anarkElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", true, row)
	end
end

function widgetSystem.onMouseOverDropDown(anarkElement)
	local dropdownElement, _, frameElement = widgetSystem.getTableCellElementByAnarkElement("dropdown", anarkElement)
	if dropdownElement == nil then
		return
	end

	local dropdownID = widgetSystem.getWidgetIDByElementEntry(dropdownElement)
	if not IsValidWidgetElement(dropdownID) then
		return -- view might have already been changed
	end

	if ffi.string(C.GetMouseOverText(dropdownID)) == "" then
		if dropdownElement.curOption.mouseovertext ~= "" then
			widgetSystem.setMouseOverOverride(dropdownID, dropdownElement.curOption.mouseovertext)
			dropdownElement.mouseOverOverrideSet = true
		end
	end

	if dropdownElement.active then
		widgetSystem.setDropDownElementState(dropdownID, dropdownElement, "mouseOver", true)
		if dropdownElement.allowMouseOverInteraction then
			widgetSystem.showDropDownOptions(frameElement, dropdownID, dropdownElement)
		end
	end

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("dropdown", anarkElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", true, row)
	end
end

function widgetSystem.onMouseOverDropDownScrollBar(anarkElement)
	local anarkDropDownElement = getElement("parent.parent", anarkElement)
	local dropdownElement = widgetSystem.getTableCellElementByAnarkElement("dropdown", anarkDropDownElement)
	local dropdownID = widgetSystem.getWidgetIDByElementEntry(dropdownElement)
	
	widgetSystem.setScrollBarState(dropdownElement.element.scrollBar, "mouseOver", true, dropdownID)
end

function widgetSystem.onMouseOverEditBox(anarkElement)
	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("editbox", anarkElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", true, row)
	end
	widgetSystem.setMouseCursorOverrideInternal("textinput")
end

function widgetSystem.onMouseOverGraphDataPoint(anarkElement)
	local graphElement, data = widgetSystem.getTableCellElementByAnarkElement("graph", anarkElement)
	if graphElement == nil then
		return
	end

	local textx = ""
	local int, frac = math.modf(data[2].x)
	textx = ((data[2].x < 0) and "-" or "") .. ConvertIntegerString(math.abs(int), true, 0, true, false)
	if graphElement.xAxis.hasLabel and ((graphElement.xAxis.label.accuracy + 1) > 0) then
		frac = math.floor(math.abs(frac) * (10 ^ (graphElement.xAxis.label.accuracy + 1)) + 0.5)
		textx = textx .. L["."] .. string.format("%0".. (graphElement.xAxis.label.accuracy + 1) .."d", frac)
	end

	local texty = ""
	int, frac = math.modf(data[2].y)
	texty = ((data[2].y < 0) and "-" or "") .. ConvertIntegerString(math.abs(int), true, 0, true, false)
	if graphElement.yAxis.hasLabel and ((graphElement.yAxis.label.accuracy + 1) > 0) then
		frac = math.floor(math.abs(frac) * (10 ^ (graphElement.yAxis.label.accuracy + 1)) + 0.5)
		texty = texty .. L["."] .. string.format("%0".. (graphElement.yAxis.label.accuracy + 1) .."d", frac)
	end
	
	local graphID = widgetSystem.getWidgetIDByElementEntry(graphElement)
	widgetSystem.setMouseOverOverride(graphID, ((data[1] ~= "") and (data[1] .. " ") or "") .. "(" .. textx .. "; " ..texty .. ")")
end

function widgetSystem.onMouseOverGraphIcon(anarkElement)
	local graphElement, icon = widgetSystem.getTableCellElementByAnarkElement("graph", anarkElement)
	if graphElement == nil then
		return
	end

	local graphID = widgetSystem.getWidgetIDByElementEntry(graphElement)
	widgetSystem.setMouseOverOverride(graphID, icon.mouseOverText)
end

function widgetSystem.onMouseOverHelpOverlay(anarkElement)
	local rootAnarkElement = getElement("parent", anarkElement)
	for id, entry in pairs(private.displayedHelpOverlays) do
		if entry.element == rootAnarkElement then
			private.helpOverlayStates[id] = true
			widgetSystem.updateHelpOverlayColor(entry.element, true, entry.iconsize, entry.borderonly, getElapsedTime())
			entry.mouseOver = true
			local overlayEntry = private.helpOverlays[id]
			widgetSystem.setMouseOverOverride(overlayEntry.widgetID, overlayEntry.overlayinfo.text)
		end
	end
end

function widgetSystem.onMouseOverSliderCell(anarkElement)
	local anarkSliderCellElement = getElement("parent.parent.parent", anarkElement)
	local slidercellElement = widgetSystem.getTableCellElementByAnarkElement("slidercell", anarkSliderCellElement)
	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", anarkSliderCellElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", true, row)

		if not slidercellElement.readonly then
			widgetSystem.setMouseCursorOverrideInternal("slider")
		end
	end
end

function widgetSystem.onMouseOverPageScroll(anarkElement)
	local tableElement = widgetSystem.getTableElementByScrollBar(anarkElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)
	if tableElement then
		widgetSystem.setTableMousePickState(tableID, tableElement, "mouseOver", true)
	end
end

function widgetSystem.onMouseOverTableScrollBar(anarkElement)
	local anarkScrollBarElement = getElement("parent", anarkElement)
	local tableElement = widgetSystem.getTableElementByScrollBar(anarkScrollBarElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)
	if tableElement then
		widgetSystem.setScrollBarState(tableElement.scrollBar, "mouseOver", true, tableID)
	end
end

function widgetSystem.onMouseOverTable(anarkElement)
	local tableElement = widgetSystem.getTableElementByMousePick(anarkElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)

	if tableElement then
		widgetSystem.setTableMousePickState(tableID, tableElement, "mouseOver", true)
	end
end

function widgetSystem.onMouseOverTableCell(anarkElement)
	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("cell", anarkElement)
	
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", true, row)
	end
end

function widgetSystem.onMouseStartDropDownScrollBarDrag(anarkElement)
	local anarkDropDownElement = getElement("parent.parent", anarkElement)
	local dropdownElement = widgetSystem.getTableCellElementByAnarkElement("dropdown", anarkDropDownElement)
	local dropdownID = widgetSystem.getWidgetIDByElementEntry(dropdownElement)

	widgetSystem.startDropDownScrollBarDrag(dropdownID, dropdownElement)
	widgetSystem.setScrollBarState(dropdownElement.element.scrollBar, "mouseClick", true, dropdownID)
end

function widgetSystem.onMouseStartFlowchartScrollBarDrag(anarkElement)
	local anarkScrollBarElement = getElement("parent", anarkElement)
	local scrollbar, flowchartElement, frameElement = widgetSystem.getFlowchartScrollBarByAnarkElement(anarkScrollBarElement)

	if flowchartElement then
		widgetSystem.startFlowchartScrollBarDrag(flowchartElement, scrollbar)
		widgetSystem.setScrollBarState(scrollbar, "mouseClick", true, flowchartElement.data.id)
	end
end

function widgetSystem.onMouseStartScrollBarDrag(anarkElement)
	local anarkScrollBarElement = getElement("parent", anarkElement)
	local tableElement = widgetSystem.getTableElementByScrollBar(anarkScrollBarElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)

	widgetSystem.startScrollBarDrag(tableElement)
	widgetSystem.setScrollBarState(tableElement.scrollBar, "mouseClick", true, tableID)
end

function widgetSystem.onMouseStopDropDownScrollBarDrag(anarkElement)
	local anarkDropDownElement = getElement("parent.parent", anarkElement)
	local dropdownElement = widgetSystem.getTableCellElementByAnarkElement("dropdown", anarkDropDownElement)
	local dropdownID = widgetSystem.getWidgetIDByElementEntry(dropdownElement)

	widgetSystem.stopDropDownScrollBarDrag(dropdownID, dropdownElement)
	widgetSystem.setScrollBarState(dropdownElement.element.scrollBar, "mouseClick", false, dropdownID)
end

function widgetSystem.onMouseStopFlowchartScrollBarDrag(anarkElement)
	local anarkScrollBarElement = getElement("parent", anarkElement)
	local scrollbar, flowchartElement, frameElement = widgetSystem.getFlowchartScrollBarByAnarkElement(anarkScrollBarElement)

	if flowchartElement then
		widgetSystem.stopFlowchartScrollBarDrag(flowchartElement, scrollbar)
		widgetSystem.setScrollBarState(scrollbar, "mouseClick", false, flowchartElement.data.id)
	end
end

function widgetSystem.onMouseStopScrollBarDrag(anarkElement)
	local anarkScrollBarElement = getElement("parent", anarkElement)
	local tableElement = widgetSystem.getTableElementByScrollBar(anarkScrollBarElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)

	if tableElement then
		widgetSystem.stopScrollBarDrag(tableElement)
		widgetSystem.setScrollBarState(tableElement.scrollBar, "mouseClick", false, tableID)
	end
end

function widgetSystem.onMouseUpStandardButton(type, anarkElement)
	local frameElement = widgetSystem.getFrameElementByAnarkStandardButtonElement(anarkElement)

	if frameElement then
		-- can be nil, if we closed the frame before the mouse-event got dispatched
		local frameID = widgetSystem.getWidgetIDByElementEntry(frameElement)
		widgetSystem.setStandardButtonState(frameID, frameElement, type, "mouseClick", false)
		if type == "help" then
			widgetSystem.toggleHelpOverlay()
		else
			widgetSystem.raiseHideEvent(frameElement.frame, type)
		end
	end
end

function widgetSystem.onMouseUpButton(anarkElement)
	local buttonElement = widgetSystem.getTableCellElementByAnarkElement("button", anarkElement)
	if buttonElement == nil or not buttonElement.active then
		return -- if the button is not active, there's nothing we've to do
	end

	local buttonID = widgetSystem.getWidgetIDByElementEntry(buttonElement)
	if not IsValidWidgetElement(buttonID) then
		return -- view might have already been changed
	end
	
	widgetSystem.setButtonElementState(buttonID, buttonElement, "mouseClick", false)
end

function widgetSystem.onMouseUpDropDown(anarkElement)
	local dropdownElement = widgetSystem.getTableCellElementByAnarkElement("dropdown", getElement("parent", anarkElement))
	if dropdownElement == nil or not dropdownElement.active then
		return -- if the dropdown is not active, there's nothing we've to do
	end

	local dropdownID = widgetSystem.getWidgetIDByElementEntry(dropdownElement)
	if not IsValidWidgetElement(dropdownID) then
		return -- view might have already been changed
	end

	widgetSystem.setDropDownElementState(dropdownID, dropdownElement, "mouseClick", false)
end

function widgetSystem.onMoveDown(modified, _, widgetID)
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(widgetID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if elemententry == nil then
		DebugError("Widget system error. Could not retrieve interactive element for moving down.")
		return
	end

	if private.activeEditBox then
		-- editbox is active -> ignore
		return
	end

	if private.activeSliderCell then
		-- slidercell input is active
		widgetSystem.confirmSliderCellInputInternal(private.activeSliderCell.widgetID, private.activeSliderCell.element)
	end

	-- #StefanMed - refactor (no type dependency intended)
	-- #StefanMed - this check could be removed, if we only register sliders for down-scrolling in the Widgetcontroller
	-- #StefanMed - refactor usage of IsType() - get the information once and set it in elemententry (or elemententry.element) so we do not have to query it all the time
	if not IsType(widgetID, "table") then
		-- no error output, since it's a valid call (for instance for sliders which only respond to scrollLeft/Right)
		return -- scrolling down is only supported for sliders
	end

	if (not modified) then
		if private.activeDropDown then
			widgetSystem.moveDropDownSelection(private.activeDropDown.widgetID, private.activeDropDown.element, 1)
			return
		end
	end

	private.hadNoneMouseInput = true

	widgetSystem.moveDown(widgetID, elemententry.element, nil, modified)

	if elemententry.element.interactiveChild then
		widgetSystem.updateEmulatedMouseCursorPosition(widgetID, elemententry.element, elemententry.element.interactiveChild.row, elemententry.element.interactiveChild.col)
	else
		widgetSystem.updateEmulatedMouseCursorPosition(widgetID, elemententry.element, elemententry.element.curRow)
	end
end

function widgetSystem.onMoveUp(modified, _, widgetID)
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(widgetID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if elemententry == nil then
		DebugError("Widget system error. Could not retrieve interactive element for moving up.")
		return
	end

	if private.activeEditBox then
		-- editbox is active -> ignore
		return
	end

	if private.activeSliderCell then
		-- slidercell input is active
		widgetSystem.confirmSliderCellInputInternal(private.activeSliderCell.widgetID, private.activeSliderCell.element)
	end

	-- #StefanMed - refactor (no type dependency intended)
	-- #StefanMed - this check could be removed, if we only register tables for up-scrolling in the Widgetcontroller
	if not IsType(widgetID, "table") then
		-- no error output, since it's a valid call (for instance for sliders which only respond to scrollLeft/Right)
		return -- scrolling up is only supported for sliders
	end
	
	if (not modified) then
		if private.activeDropDown then
			widgetSystem.moveDropDownSelection(private.activeDropDown.widgetID, private.activeDropDown.element, -1)
			return
		end
	end

	private.hadNoneMouseInput = true
	
	widgetSystem.moveUp(widgetID, elemententry.element, nil, modified)

	if elemententry.element.interactiveChild then
		widgetSystem.updateEmulatedMouseCursorPosition(widgetID, elemententry.element, elemententry.element.interactiveChild.row, elemententry.element.interactiveChild.col)
	else
		widgetSystem.updateEmulatedMouseCursorPosition(widgetID, elemententry.element, elemententry.element.curRow)
	end
end

function widgetSystem.onPageDown(_, widgetID)
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(widgetID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if elemententry == nil then
		DebugError("Widget system error. Could not retrieve interactive element for moving page down.")
		return
	end

	-- #StefanMed - refactor (no type dependency intended)
	-- #StefanMed - this check could be removed, if we only register sliders for down-scrolling in the Widgetcontroller
	if not IsType(widgetID, "table") then
		-- no error output, since it's a valid call (for instance for sliders which only respond to scrollLeft/Right)
		return -- scrolling down is only supported for sliders
	end
	
	if private.activeDropDown then
		widgetSystem.moveDropDownSelection(private.activeDropDown.widgetID, private.activeDropDown.element, private.activeDropDown.element.noofVisibleOptions - 1)
		return
	end

	private.hadNoneMouseInput = true

	widgetSystem.pageDown(widgetID, elemententry.element)
end

function widgetSystem.onPageUp(_, widgetID)
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(widgetID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if elemententry == nil then
		DebugError("Widget system error. Could not retrieve interactive element for moving page up.")
		return
	end

	-- #StefanMed - refactor (no type dependency intended)
	-- #StefanMed - this check could be removed, if we only register sliders for down-scrolling in the Widgetcontroller
	if not IsType(widgetID, "table") then
		-- no error output, since it's a valid call (for instance for sliders which only respond to scrollLeft/Right)
		return -- scrolling down is only supported for sliders
	end
	
	if private.activeDropDown then
		widgetSystem.moveDropDownSelection(private.activeDropDown.widgetID, private.activeDropDown.element, -private.activeDropDown.element.noofVisibleOptions + 1)
		return
	end

	private.hadNoneMouseInput = true

	widgetSystem.pageUp(widgetID, elemententry.element)
end

function widgetSystem.onRemoveAllHelpOverlays()
	if not private.helpOverlayDisplayed then
		for id, entry in pairs(private.signalledHelpOverlays) do
			widgetSystem.hideHelpOverlayID(id)
		end
	end
	private.signalledHelpOverlays = {}
end

function widgetSystem.onRemoveHelpOverlay(_, id)
	widgetSystem.removeHelpOverlay(id)
end

function widgetSystem.removeHelpOverlay(id)
	if private.signalledHelpOverlays[id] then
		private.signalledHelpOverlays[id] = nil
		if not private.helpOverlayDisplayed then
			widgetSystem.hideHelpOverlayID(id)
		end
	end
end

function widgetSystem.onScrollDown(modified, _, step)
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if modified == "shift" then
		widgetSystem.performHorizontalScroll(tonumber(step))
	else
		widgetSystem.performVerticalScroll(tonumber(step))
	end
end

function widgetSystem.onScrollUp(modified, _, step)
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if modified == "shift" then
		widgetSystem.performHorizontalScroll(-tonumber(step))
	else
		widgetSystem.performVerticalScroll(-tonumber(step))
	end
end

function widgetSystem.performVerticalScroll(step)
	-- check for dropdown
	if private.activeDropDown ~= nil then
		if private.activeDropDown.element.dropdownState.mouseOver then
			if step > 0 then
				widgetSystem.scrollDownDropDown(private.activeDropDown.widgetID, private.activeDropDown.element, step)
			else
				widgetSystem.scrollUpDropDown(private.activeDropDown.widgetID, private.activeDropDown.element, -step)
			end
			return
		end
	end

	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		-- check for table
		for _, tableElement in ipairs(frameElement.tables) do
			if tableElement.mousePick.state.mouseOver.state then
				local overTableID = widgetSystem.getWidgetIDByElementEntry(tableElement)
				if overTableID then
					if step > 0 then
						widgetSystem.scrollDown(overTableID, tableElement, step)
					else
						widgetSystem.scrollUp(overTableID, tableElement, -step)
					end
					return
				end
			end
		end
		-- check for flowchart
		for _, flowchartElement in ipairs(frameElement.flowcharts) do
			if flowchartElement.mousePick.state.mouseOver.state then
				if step > 0 then
					widgetSystem.scrollFlowchartVertically(flowchartElement, 1, nil, step)
				else
					widgetSystem.scrollFlowchartVertically(flowchartElement, -1, nil, -step)
				end
				return
			end
		end
		-- check for rendertarget
		for _, renderTargetsElement in ipairs(frameElement.rendertargets) do
			local renderTargetID = widgetSystem.getWidgetIDByElementEntry(renderTargetsElement)
			if renderTargetID and widgetSystem.getRenderTargetMousePosition(renderTargetID) then
				if step > 0 then
					widgetSystem.combinedScrollDownRenderTarget(renderTargetID, step)
					-- TODO #Florian - kept for mod compatibility, remove in next project
					for i = 1, step do
						widgetSystem.scrollDownRenderTarget(renderTargetID)
					end
				else
					widgetSystem.combinedScrollUpRenderTarget(renderTargetID, -step)
					-- TODO #Florian - kept for mod compatibility, remove in next project
					for i = 1, -step do
						widgetSystem.scrollUpRenderTarget(renderTargetID)
					end
				end
				return
			end
		end
	end
end

function widgetSystem.performHorizontalScroll(step)
	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		-- check for flowchart
		for _, flowchartElement in ipairs(frameElement.flowcharts) do
			if flowchartElement.mousePick.state.mouseOver.state then
				if step > 0 then
					widgetSystem.scrollFlowchartHorizontally(flowchartElement, 1, nil)
				else
					widgetSystem.scrollFlowchartHorizontally(flowchartElement, -1, nil)
				end
				return
			end
		end
	end
end

function widgetSystem.onShieldHullBarUpdate(_, shieldhullbarid)
	if not IsValidWidgetElement(shieldhullbarid) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local shieldhullbarentry = private.associationList[shieldhullbarid]
	if shieldhullbarentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	widgetSystem.updateShieldHullBar(shieldhullbarentry.element, shieldhullbarid)
	widgetSystem.updateMouseOverText(shieldhullbarid)
end

function widgetSystem.onShowHelpOverlay(_, id)
	private.signalledHelpOverlays[id] = { borderonly = false }
	widgetSystem.showHelpOverlayID(id)
end

function widgetSystem.onShowHighlightOverlay(_, id)
	widgetSystem.showHighlightOverlay(id)
end

function widgetSystem.showHighlightOverlay(id)
	private.signalledHelpOverlays[id] = { borderonly = true }
	widgetSystem.showHelpOverlayID(id, true)
end

function widgetSystem.onSliderCellUpdate(_, slidercellID)
	if not IsValidWidgetElement(slidercellID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local slidercellEntry = private.associationList[slidercellID]
	if slidercellEntry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	local slidercellElement = slidercellEntry.element

	local values = ffi.new("SliderCellDetails")
	if C.GetSliderCellValues(slidercellID, values) then
		slidercellElement.min = values.min
		slidercellElement.minSelect = values.minSelect
		slidercellElement.max = values.max
		slidercellElement.maxSelect = values.maxSelect
		slidercellElement.cur = values.start
		slidercellElement.maxfactor = values.maxfactor
	end

	while slidercellElement.cur > (slidercellElement.maxfactor * slidercellElement.max) do
		slidercellElement.maxfactor = slidercellElement.maxfactor * 2
	end

	widgetSystem.updateSliderCellValue(slidercellElement)
	widgetSystem.updateMouseOverText(slidercellID)

	widgetSystem.updateSliderCellArrowSlide(slidercellElement, "left")
	widgetSystem.updateSliderCellArrowSlide(slidercellElement, "right")
	widgetSystem.updateSliderCellArrowSlide(slidercellElement, "skip_left")
	widgetSystem.updateSliderCellArrowSlide(slidercellElement, "skip_right")
end

function widgetSystem.onStatusBarUpdate(_, statusbarid)
	if not IsValidWidgetElement(statusbarid) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local statusbarentry = private.associationList[statusbarid]
	if statusbarentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	widgetSystem.updateStatusBar(statusbarentry.element, statusbarid)
	widgetSystem.updateMouseOverText(statusbarid)
end

function widgetSystem.onStartScrollLeft(modified, _, widgetID)
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if widgetID and (not IsValidWidgetElement(widgetID)) then
		return -- can happen if a slider/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if widgetID and (elemententry == nil) then
		DebugError("Widget system error. Could not retrieve interactive element for start scrolling left.")
		return
	end

	private.hadNoneMouseInput = true

	local editboxElement
	if widgetID and IsType(widgetID, "editbox") then
		editboxElement = private.associationList[widgetID]
		if editboxElement == nil then
			-- #StefanLow - should we better move the table then to display the assigned box and activate it? --- same with buttons then?
			-- if editboxElement is nil (aka editbox is not on-screen atm), there's nothing for us to do here
			return
		end
		if private.activeEditBox and (widgetID ~= private.activeEditBox.editboxID) then
			-- not the active editbox, ignore
			return
		end
		editboxElement = editboxElement.element
	elseif private.activeEditBox ~= nil and ((widgetID == nil) or IsType(widgetID, "table")) then
		-- #StefanMed - remove the IsType-check alongside changing the passed widgetID to be the actual element instead of the table when pressing ENTER with an active editbox/table
		-- check if widget element is table, so button hotkey doesn't trigger editbox confirm
		widgetID       = private.activeEditBox.editboxID
		editboxElement = private.activeEditBox.editboxElement
	end

	if (editboxElement ~= nil) and (not editboxElement.encrypted) then
		private.activeEditBox.scrollLeftStart = getElapsedTime() + config.editbox.cursorScrollDelay
		if modified == "shiftctrl" then
			editboxElement.shiftStartPos = editboxElement.shiftStartPos or editboxElement.cursorPos
			private.activeEditBox.isCtrlScroll = true
			local startpos = math.min(editboxElement.cursorPos, utf8.len(editboxElement.text))
			local first = widgetSystem.findEditBoxWordAtPos(editboxElement, startpos)
			if (first == nil) or (first == startpos) then
				first = widgetSystem.findEditBoxWordAtPos(editboxElement, startpos - 1)
			end
			first = first or 0
			editboxElement.cursorPos = math.max(0, first)
		elseif modified == "shift" then
			editboxElement.shiftStartPos = editboxElement.shiftStartPos or editboxElement.cursorPos
			editboxElement.cursorPos = math.max(0, editboxElement.cursorPos - 1)
		else
			if modified == "ctrl" then
				private.activeEditBox.isCtrlScroll = true
				local startpos = math.min(editboxElement.cursorPos, utf8.len(editboxElement.text))
				local first = widgetSystem.findEditBoxWordAtPos(editboxElement, startpos)
				if (first == nil) or (first == startpos) then
					first = widgetSystem.findEditBoxWordAtPos(editboxElement, startpos - 1)
				end
				first = first or 0
				editboxElement.cursorPos = math.max(0, first)
			elseif editboxElement.shiftStartPos and (editboxElement.cursorPos ~= editboxElement.shiftStartPos) then
				if editboxElement.cursorPos > editboxElement.shiftStartPos then
					editboxElement.cursorPos = math.max(0, editboxElement.shiftStartPos)
				end
			else
				editboxElement.cursorPos = math.max(0, editboxElement.cursorPos - 1)
			end
			editboxElement.shiftStartPos = nil
		end
		widgetSystem.updateEditBoxTextDisplay(editboxElement)
		widgetSystem.updateEditBoxTextHighlight(editboxElement)
		CallWidgetEventScripts(private.activeEditBox.editboxID, "onCursorChanged", editboxElement.cursorPos, editboxElement.shiftStartPos)
		return
	end

	-- #StefanMed - refactor (no type dependency intended)
	-- #StefanMed - this check could be removed, if we only register sliders for left-scrolling in the Widgetcontroller
	if widgetID and IsType(widgetID, "table") then
		if elemententry.element.interactiveChild and IsType(elemententry.element.interactiveChild.widgetID, "slidercell") then
			if modified == "shift" then
				widgetSystem.setSliderCellArrowState(elemententry.element.interactiveChild.widgetID, "skip_left", "mouseDown", true)
				return
			end
		end

		if not modified then
			widgetSystem.moveLeft(widgetID, elemententry.element)

			if elemententry.element.interactiveChild then
				widgetSystem.updateEmulatedMouseCursorPosition(widgetID, elemententry.element, elemententry.element.interactiveChild.row, elemententry.element.interactiveChild.col)
			else
				widgetSystem.updateEmulatedMouseCursorPosition(widgetID, elemententry.element, elemententry.element.curRow)
			end
		end
	end

	-- no error output, since it's a valid call for any element
end

function widgetSystem.onStopScrollLeft(modified, _, widgetID)
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if widgetID and (not IsValidWidgetElement(widgetID)) then
		return -- can happen if a slider/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if widgetID and (elemententry == nil) then
		DebugError("Widget system error. Could not retrieve interactive element for start scrolling left.")
		return
	end

	if private.activeEditBox ~= nil then
		private.activeEditBox.scrollLeftStart = nil
		private.activeEditBox.isCtrlScroll = nil
		return
	end

	widgetSystem.stopScroll()
	if widgetID and IsType(widgetID, "table") then
		if elemententry.element.interactiveChild and IsType(elemententry.element.interactiveChild.widgetID, "slidercell") then
			if modified == "shift" then
				local slidercellID = elemententry.element.interactiveChild.widgetID
				local slidercellElement = elemententry.element.interactiveChild.element
				widgetSystem.setSliderCellCurValue(slidercellElement, slidercellElement.righttoleft and (slidercellElement.maxfactor * slidercellElement.maxSelect) or slidercellElement.minSelect, false, true)
				widgetSystem.updateSliderCellValue(slidercellElement)

				widgetSystem.setSliderCellArrowState(slidercellID, "skip_left", "mouseDown", false)
				CallWidgetEventScripts(slidercellID, "onSliderCellDeactivated")
				CallWidgetEventScripts(slidercellID, "onSliderCellConfirm", slidercellElement.cur, true)
				return
			end
		end

		if not modified then
			widgetSystem.stopLeft(widgetID, elemententry.element)
		end
	end
end

function widgetSystem.onStartScrollRight(modified, _, widgetID)
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if widgetID and (not IsValidWidgetElement(widgetID)) then
		return -- can happen if a slider/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if widgetID and (elemententry == nil) then
		DebugError("Widget system error. Could not retrieve interactive element for start scrolling right.")
		return
	end

	private.hadNoneMouseInput = true

	local editboxElement
	if widgetID and IsType(widgetID, "editbox") then
		editboxElement = private.associationList[widgetID]
		if editboxElement == nil then
			-- #StefanLow - should we better move the table then to display the assigned box and activate it? --- same with buttons then?
			-- if editboxElement is nil (aka editbox is not on-screen atm), there's nothing for us to do here
			return
		end
		if private.activeEditBox and (widgetID ~= private.activeEditBox.editboxID) then
			-- not the active editbox, ignore
			return
		end
		editboxElement = editboxElement.element
	elseif private.activeEditBox ~= nil and ((widgetID == nil) or IsType(widgetID, "table")) then
		-- #StefanMed - remove the IsType-check alongside changing the passed widgetID to be the actual element instead of the table when pressing ENTER with an active editbox/table
		-- check if widget element is table, so button hotkey doesn't trigger editbox confirm
		widgetID       = private.activeEditBox.editboxID
		editboxElement = private.activeEditBox.editboxElement
	end

	if (editboxElement ~= nil) and (not editboxElement.encrypted) then
		private.activeEditBox.scrollRightStart = getElapsedTime() + config.editbox.cursorScrollDelay
		if modified == "shiftctrl" then
			editboxElement.shiftStartPos = editboxElement.shiftStartPos or editboxElement.cursorPos
			private.activeEditBox.isCtrlScroll = true
			local _, _, nextword = widgetSystem.findEditBoxWordAtPos(editboxElement, math.max(editboxElement.cursorPos, 0))
			nextword = nextword or utf8.len(editboxElement.text)
			editboxElement.cursorPos = math.min(utf8.len(editboxElement.text), nextword)
		elseif modified == "shift" then
			editboxElement.shiftStartPos = editboxElement.shiftStartPos or editboxElement.cursorPos
			editboxElement.cursorPos = math.min(utf8.len(editboxElement.text), editboxElement.cursorPos + 1)
		else
			if modified == "ctrl" then
				private.activeEditBox.isCtrlScroll = true
				local _, _, nextword = widgetSystem.findEditBoxWordAtPos(editboxElement, math.max(editboxElement.cursorPos, 0))
				nextword = nextword or utf8.len(editboxElement.text)
				editboxElement.cursorPos = math.min(utf8.len(editboxElement.text), nextword)
			elseif editboxElement.shiftStartPos and (editboxElement.cursorPos ~= editboxElement.shiftStartPos) then
				if editboxElement.cursorPos < editboxElement.shiftStartPos then
					editboxElement.cursorPos = math.min(utf8.len(editboxElement.text), editboxElement.shiftStartPos)
				end
			else
				editboxElement.cursorPos = math.min(utf8.len(editboxElement.text), editboxElement.cursorPos + 1)
			end
			editboxElement.shiftStartPos = nil
		end
		widgetSystem.updateEditBoxTextDisplay(editboxElement)
		widgetSystem.updateEditBoxTextHighlight(editboxElement)
		CallWidgetEventScripts(private.activeEditBox.editboxID, "onCursorChanged", editboxElement.cursorPos, editboxElement.shiftStartPos)
		return
	end

	-- #StefanMed - refactor (no type dependency intended)
	-- #StefanMed - this check could be removed, if we only register sliders for right-scrolling in the Widgetcontroller
	if widgetID and IsType(widgetID, "table") then
		if elemententry.element.interactiveChild and IsType(elemententry.element.interactiveChild.widgetID, "slidercell") then
			if modified == "shift" then
				widgetSystem.setSliderCellArrowState(elemententry.element.interactiveChild.widgetID, "skip_right", "mouseDown", true)
				return
			end
		end

		if not modified then
			widgetSystem.moveRight(widgetID, elemententry.element)

			if elemententry.element.interactiveChild then
				widgetSystem.updateEmulatedMouseCursorPosition(widgetID, elemententry.element, elemententry.element.interactiveChild.row, elemententry.element.interactiveChild.col)
			else
				widgetSystem.updateEmulatedMouseCursorPosition(widgetID, elemententry.element, elemententry.element.curRow)
			end
		end
	end

	-- no error output, since it's a valid call for any interactive element
end

function widgetSystem.onStopScrollRight(modified, _, widgetID)
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if widgetID and (not IsValidWidgetElement(widgetID)) then
		return -- can happen if a slider/view is closed before this callback is processed
	end

	if private.activeEditBox ~= nil then
		private.activeEditBox.scrollRightStart = nil
		private.activeEditBox.isCtrlScroll = nil
		return
	end

	local elemententry = private.associationList[widgetID]
	if widgetID and (elemententry == nil) then
		DebugError("Widget system error. Could not retrieve interactive element for start scrolling left.")
		return
	end

	widgetSystem.stopScroll()
	if widgetID and IsType(widgetID, "table") then
		if elemententry.element.interactiveChild and IsType(elemententry.element.interactiveChild.widgetID, "slidercell") then
			if modified == "shift" then
				local slidercellID = elemententry.element.interactiveChild.widgetID
				local slidercellElement = elemententry.element.interactiveChild.element
				widgetSystem.setSliderCellCurValue(slidercellElement, slidercellElement.righttoleft and slidercellElement.minSelect or (slidercellElement.maxfactor * slidercellElement.maxSelect), false, true)
				widgetSystem.updateSliderCellValue(slidercellElement)

				widgetSystem.setSliderCellArrowState(slidercellID, "skip_right", "mouseDown", false)
				CallWidgetEventScripts(slidercellID, "onSliderCellDeactivated")
				CallWidgetEventScripts(slidercellID, "onSliderCellConfirm", slidercellElement.cur, true)
				return
			end
		end

		if not modified then
			widgetSystem.stopRight(widgetID, elemententry.element)
		end
	end
end

function widgetSystem.onStartRemoveNextChar(_, widgetID)
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if widgetID and (not IsValidWidgetElement(widgetID)) then
		return -- can happen if a slider/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if widgetID and (elemententry == nil) then
		DebugError("Widget system error. Could not retrieve interactive element for start scrolling right.")
		return
	end

	local editboxElement
	if widgetID and IsType(widgetID, "editbox") then
		editboxElement = private.associationList[widgetID]
		if editboxElement == nil then
			-- #StefanLow - should we better move the table then to display the assigned box and activate it? --- same with buttons then?
			-- if editboxElement is nil (aka editbox is not on-screen atm), there's nothing for us to do here
			return
		end
		if private.activeEditBox and (widgetID ~= private.activeEditBox.editboxID) then
			-- not the active editbox, ignore
			return
		end
		editboxElement = editboxElement.element
	elseif private.activeEditBox ~= nil and ((widgetID == nil) or IsType(widgetID, "table")) then
		-- #StefanMed - remove the IsType-check alongside changing the passed widgetID to be the actual element instead of the table when pressing ENTER with an active editbox/table
		-- check if widget element is table, so button hotkey doesn't trigger editbox confirm
		widgetID       = private.activeEditBox.editboxID
		editboxElement = private.activeEditBox.editboxElement
	end

	if editboxElement ~= nil then
		private.activeEditBox.removeNextCharStart = getElapsedTime() + config.editbox.cursorScrollDelay
		widgetSystem.removeNextEditBoxChar(private.activeEditBox.editboxID, private.activeEditBox.editboxElement)
	end
end

function widgetSystem.onStopRemoveNextChar(_, widgetID)
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if widgetID and (not IsValidWidgetElement(widgetID)) then
		return -- can happen if a slider/view is closed before this callback is processed
	end

	if private.activeEditBox ~= nil then
		private.activeEditBox.removeNextCharStart = nil
	end
end

-- widgetID atm is normally the WidgetID of the child of the view (i.e. table, etc.)
-- only for hotkey-handling it's the actual widget element which is assigned the hotkey
-- #StefanMed - make consistent, so the callback is directly pointing to the actual interactive (child) element?
function widgetSystem.onStartSelect(_, widgetID)
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if (widgetID == nil) or (not IsValidWidgetElement(widgetID)) then
		return -- can happen, when we process multiple keypresses at once (of which one is hiding/changing the view)
	end
	
	private.hadNoneMouseInput = true

	if IsType(widgetID, "editbox") or private.activeEditBox ~= nil then
		-- just skip the call, if we get an editbox or if we are in active editbox input mode
		return
	end

	if IsType(widgetID, "slidercell") or private.activeSliderCell ~= nil then
		-- just skip the call, if we get a slidercell or if we are in active slidercell input mode
		return
	end

	-- #StefanMed - tidy up --- quick and dirty --- works only since we only have buttons with hotkey support
	if IsType(widgetID, "button") then
		-- hotkey case --- just change the button state
		local buttonElement = private.associationList[widgetID]
		-- if buttonElement is nil (aka button is not on-screen atm), there's nothing for us to do here
		if buttonElement ~= nil and buttonElement.element.active then
			widgetSystem.setButtonElementState(widgetID, buttonElement.element, "keyboardPress", true)
		end
		return
	elseif IsType(widgetID, "dropdown") then
		-- hotkey case --- just change the dropdown state
		local dropdownElement = private.associationList[widgetID]
		-- if dropdownElement is nil (aka dropdown is not on-screen atm), there's nothing for us to do here
		if dropdownElement ~= nil and dropdownElement.element.active then
			widgetSystem.setDropDownElementState(widgetID, dropdownElement.element, "keyboardPress", true)
		end
		return
	end

	if private.interactiveElement == nil or not IsType(private.interactiveElement.widgetID, "table") or private.interactiveElement.element.interactiveChild == nil then
		return -- currently no interactive button we need to set the click-state for
	end

	local interactiveElement = private.interactiveElement.element.interactiveChild.element
	-- #StefanLow - better add interactiveChild.isDisplayed to result in self-explanatiory code
	-- dropdownElement can be nil, if the element is not displayed atm - in this case there's nothing to do for us
	if interactiveElement ~= nil then
		local interactiveWidgetID = private.interactiveElement.element.interactiveChild.widgetID
		if IsType(interactiveWidgetID, "button") then
			widgetSystem.setButtonElementState(interactiveWidgetID, interactiveElement, "keyboardPress", true)
		elseif IsType(interactiveWidgetID, "dropdown") then
			widgetSystem.setDropDownElementState(interactiveWidgetID, interactiveElement, "keyboardPress", true)
		end
	end
end

-- see widgetSystem.onStartSelect() for widgetID parameter
function widgetSystem.onStopSelect(_, widgetID)
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	local editboxElement
	if widgetID and IsType(widgetID, "editbox") then
		editboxElement = private.associationList[widgetID]
		if editboxElement == nil then
			-- #StefanLow - should we better move the table then to display the assigned box and activate it? --- same with buttons then?
			-- if editboxElement is nil (aka editbox is not on-screen atm), there's nothing for us to do here
			return
		end
		editboxElement = editboxElement.element
	elseif private.activeEditBox ~= nil and ((widgetID == nil) or IsType(widgetID, "table")) then
		-- #StefanMed - remove the IsType-check alongside changing the passed widgetID to be the actual element instead of the table when pressing ENTER with an active editbox/table
		-- check if widget element is table, so button hotkey doesn't trigger editbox confirm
		widgetID       = private.activeEditBox.editboxID
		editboxElement = private.activeEditBox.editboxElement
	end

	if editboxElement then
		if editboxElement.active then
			widgetSystem.confirmEditBoxInputInternal(widgetID, editboxElement, true)
		else
			local tableElement, tableID, row = widgetSystem.getTableElementByAnarkTableCellElement("editbox", editboxElement.element)
			local frameElement = widgetSystem.getFrameElementByTableElement(tableElement)

			widgetSystem.deactivateDirectInputElements()
			widgetSystem.activateEditBoxInternal(frameElement, widgetID, editboxElement)

			widgetSystem.setActiveFrame(frameElement)
			widgetSystem.setInteractiveElement(frameElement.frame, tableID)
		end
		return
	end

	local slidercellElement
	if IsType(widgetID, "slidercell") then
		slidercellElement = private.associationList[widgetID]
		if slidercellElement == nil then
			-- #StefanLow - should we better move the table then to display the assigned box and activate it? --- same with buttons then?
			-- if editboxElement is nil (aka editbox is not on-screen atm), there's nothing for us to do here
			return
		end
		slidercellElement = slidercellElement.element
	elseif private.activeSliderCell ~= nil and ((widgetID == nil) or IsType(widgetID, "table")) then
		-- #StefanMed - remove the IsType-check alongside changing the passed widgetID to be the actual element instead of the table when pressing ENTER with an active editbox/table
		-- check if widget element is table, so button hotkey doesn't trigger editbox confirm
		widgetID       = private.activeSliderCell.widgetID
		slidercellElement = private.activeSliderCell.element
	end

	if slidercellElement then
		if slidercellElement.inputActive then
			widgetSystem.confirmSliderCellInputInternal(widgetID, slidercellElement)
		else
			widgetSystem.deactivateDirectInputElements()
			widgetSystem.activateSliderCellInputInternal(widgetID, slidercellElement)

			local tableElement, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", slidercellElement.element.main)
			local frameElement = widgetSystem.getFrameElementByTableElement(tableElement)
			widgetSystem.setActiveFrame(frameElement)
			widgetSystem.setInteractiveElement(frameElement.frame, widgetID)
			widgetSystem.selectRow(widgetID, row, nil, nil, "user")
		end
		return
	end

	local dropdownElement
	if IsType(widgetID, "dropdown") then
		dropdownElement = private.associationList[widgetID]
		if dropdownElement == nil then
			-- #StefanLow - should we better move the table then to display the assigned box and activate it? --- same with buttons then?
			-- if editboxElement is nil (aka editbox is not on-screen atm), there's nothing for us to do here
			return
		end
		dropdownElement = dropdownElement.element
	elseif private.activeDropDown ~= nil and ((widgetID == nil) or IsType(widgetID, "table")) then
		-- #StefanMed - remove the IsType-check alongside changing the passed widgetID to be the actual element instead of the table when pressing ENTER with an active editbox/table
		-- check if widget element is table, so button hotkey doesn't trigger editbox confirm
		widgetID        = private.activeDropDown.widgetID
		dropdownElement = private.activeDropDown.element
	end

	if dropdownElement then
		if private.activeDropDown ~= nil then
			local deleted = false
			if private.activeDropDown.selected ~= 0 then
				local curoption = private.activeDropDown.selected
				deleted = dropdownElement.options[curoption].deleted
				if not deleted then
					dropdownElement.curOption = dropdownElement.options[curoption]
					C.SetDropDownCurOption(widgetID, dropdownElement.curOption.id)
					-- we know the mouseout event will happen, we change the state now to avoid flickering in the next frame
					widgetSystem.setDropDownElementState(widgetID, dropdownElement, "mouseOver", false)
				end
			else
				widgetSystem.hideDropDownOptions(widgetID, dropdownElement)
			end

			if (not deleted) and dropdownElement.curOption.active then
				widgetSystem.hideDropDownOptions(widgetID, dropdownElement)
				widgetSystem.updateDropDown(widgetID, dropdownElement)

				CallWidgetEventScripts(widgetID, "onDropDownConfirmed", dropdownElement.curOption.id)
			end
		else
			local _, _, frameElement = widgetSystem.getTableElementByAnarkTableCellElement("dropdown", dropdownElement.element.main)
			widgetSystem.showDropDownOptions(frameElement, widgetID, dropdownElement)
		end
		widgetSystem.setDropDownElementState(widgetID, dropdownElement, "keyboardPress", false)
		return
	end

	-- only check after handling active elements (e.g. editbox, slidercell, dropdown) as these are useable without a valid InteractiveObject
	if (widgetID == nil) or (not IsValidWidgetElement(widgetID)) then
		return -- can happen, when we process multiple keypresses at once (of which one is hiding/changing the view)
	end

	-- #StefanMed - refector the interactiveElement-handling so we do not have a special case for tables here

	-- #StefanMed - tidy up --- quick and dirty --- works only since we only have buttons with hotkey support
	if IsType(widgetID, "button") then
		-- hotkey case
		if IsButtonActive(widgetID) then
			-- only handle the stop-select event, if the button is actually active
			-- #StefanLow --- investigate whether it'd be better to not trigger the events in the first place
			local buttonElement = private.associationList[widgetID]
			-- if buttonElement is nil (aka button is not on-screen atm), there's nothing for us to do here
			if buttonElement ~= nil then
				widgetSystem.setButtonElementState(widgetID, buttonElement.element, "keyboardPress", false)
			end
			CallWidgetEventScripts(widgetID, "onClick", "keyboard")
		end
		return
	elseif IsType(widgetID, "dropdown") then
		-- hotkey case
		if C.IsDropDownActive(widgetID) then
			-- only handle the stop-select event, if the dropdown is actually active
			-- #StefanLow --- investigate whether it'd be better to not trigger the events in the first place
			local dropdownElement = private.associationList[widgetID]
			-- if dropdownElement is nil (aka dropdown is not on-screen atm), there's nothing for us to do here
			if dropdownElement ~= nil then
				widgetSystem.setDropDownElementState(widgetID, dropdownElement.element, "keyboardPress", false)
				local _, _, frameElement = widgetSystem.getTableElementByAnarkTableCellElement("dropdown", dropdownElement.element.element.main)
				widgetSystem.showDropDownOptions(frameElement, widgetID, dropdownElement.element)
			end
			CallWidgetEventScripts(widgetID, "onClick")
		end
		return
	end

	if private.interactiveElement ~= nil then
		local parameter
		local element = private.interactiveElement.element
		widgetID = private.interactiveElement.widgetID
		if IsType(widgetID, "table") and private.interactiveElement.element.interactiveChild ~= nil then
			local interactiveElement = private.interactiveElement.element.interactiveChild.element
			-- #StefanLow - better add interactiveChild.isDisplayed to result in self-explanatiory code
			-- buttonElement can be nil, if the element is not displayed atm - in this case there's nothing to do for us
			if interactiveElement ~= nil then
				local interactiveWidgetID = private.interactiveElement.element.interactiveChild.widgetID
				if IsType(interactiveWidgetID, "button") then
					widgetID = interactiveWidgetID
					widgetSystem.setButtonElementState(interactiveWidgetID, interactiveElement, "keyboardPress", false)
					parameter = "keyboard"
				elseif IsType(interactiveWidgetID, "checkbox") then
					widgetID = interactiveWidgetID
					widgetSystem.toggleCheckBox(interactiveWidgetID, interactiveElement)
					parameter = interactiveElement.checked
				elseif IsType(interactiveWidgetID, "dropdown") then
					widgetSystem.setDropDownElementState(interactiveWidgetID, interactiveElement, "keyboardPress", false)
					if interactiveElement.active then
						widgetID = interactiveWidgetID
						local _, _, frameElement = widgetSystem.getTableElementByAnarkTableCellElement("dropdown", interactiveElement.element.main)
						widgetSystem.showDropDownOptions(frameElement, interactiveWidgetID, interactiveElement)
					end
				elseif IsType(interactiveWidgetID, "editbox") then
					local tableElement, tableID, row = widgetSystem.getTableElementByAnarkTableCellElement("editbox", interactiveElement.element)
					local frameElement = widgetSystem.getFrameElementByTableElement(tableElement)

					widgetID = interactiveWidgetID
					widgetSystem.activateEditBoxInternal(frameElement, interactiveWidgetID, interactiveElement)
				elseif IsType(interactiveWidgetID, "slidercell") then
					if interactiveElement.inputActive then
						widgetSystem.confirmSliderCellInputInternal(interactiveWidgetID, interactiveElement)
					else
						widgetSystem.deactivateDirectInputElements()
						widgetSystem.activateSliderCellInputInternal(interactiveWidgetID, interactiveElement)

						local tableElement, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", interactiveElement.element.main)
						local frameElement = widgetSystem.getFrameElementByTableElement(tableElement)
						widgetSystem.setActiveFrame(frameElement)
						widgetSystem.setInteractiveElement(frameElement.frame, widgetID)
						widgetSystem.selectRow(widgetID, row, nil, nil, "user")
					end
				end
			end
		end
		CallWidgetEventScripts(widgetID, "onClick", parameter)
	end
end

function widgetSystem.onStartInteract(_, widgetID)
	-- STUB
end

function widgetSystem.onStopInteract(_, widgetID)
	if (not widgetID) or (not IsValidWidgetElement(widgetID)) then
		return -- tableElement was already hidden, can happen when double clicking an already selected table cell
	end

	if IsType(widgetID, "table") then
		local tableElement = private.associationList[widgetID].element

		if tableElement.interactiveChild ~= nil then
			local child = tableElement.interactiveChild

			local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)

			local _, cellwidth = widgetSystem.getColumnSpanInfo(tableID, tableElement, child.row, child.col, child.row <= tableElement.numFixedRows)
			local cellposx = tableElement.cellposx[child.col] + cellwidth + config.table.bordersize
			local cellposy = tableElement.cellposy[child.row]

			CallWidgetEventScripts(child.widgetID, "onRightClick", child.row, child.col, cellposx, -cellposy)
		end

		local row = tableElement.highlightedBorderRow
		local cellposx, cellposy
		if row then
			cellposx = tableElement.cellposx[1] + tableElement.width + config.table.bordersize
			cellposy = -tableElement.cellposy[row]
		end
		CallWidgetEventScripts(widgetID, "onRightClick", row, cellposx, cellposy)
	end
end

function widgetSystem.onSpace(modified, _, widgetID)
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(widgetID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if elemententry == nil then
		DebugError("Widget system error. Could not retrieve interactive element for highlighting.")
		return
	end

	-- #StefanMed - refactor (no type dependency intended)
	-- #StefanMed - this check could be removed, if we only register sliders for down-scrolling in the Widgetcontroller
	-- #StefanMed - refactor usage of IsType() - get the information once and set it in elemententry (or elemententry.element) so we do not have to query it all the time
	if not IsType(widgetID, "table") then
		-- no error output, since it's a valid call (for instance for sliders which only respond to scrollLeft/Right)
		return -- scrolling down is only supported for sliders
	end

	widgetSystem.toggleHighlight(widgetID, elemententry.element, modified, "keyboard", "user")
end

function widgetSystem.onTabInteractiveElement()
	if #private.pendingFrames > 0 then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	local found = false
	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		if frameElement.frame and GetInteractiveObject(frameElement.frame) then
			found = true
			break
		end
	end
	if not found then
		return -- view doesn't have any interactive element at all, nothing to do
	end

	if private.interactiveElement then
		if IsType(private.interactiveElement.widgetID, "table") then
			if private.interactiveElement.element.interactiveRegion == "normal" then
				if widgetSystem.swapInteractiveRegion(private.interactiveElement.widgetID, private.interactiveElement.element) then
					return -- swapped from normal to fixed row
				end
			end
		end
	end

	local newWidgetID = SwitchInteractiveObject()
	if newWidgetID == nil then
		DebugError("Widget system error. Failed to swap interactive object.")
		return
	end

	-- we must unset the previous interactive element (aka: the button in the previous table) first
	if private.interactiveElement and private.interactiveElement.element.interactiveChild ~= nil then
		widgetSystem.unsetInteractiveChildElement(private.interactiveElement.element, private.interactiveElement.element.interactiveChild.widgetID, private.interactiveElement.element.interactiveChild.element)
	end

	local activeframe = GetActiveFrame()
	widgetSystem.setActiveFrame(private.associationList[activeframe].element, true)
	widgetSystem.setInteractiveElement(activeframe, newWidgetID, true)
end

function widgetSystem.onTabScrollLeft()
	CallTabScrollScripts("left")
end

function widgetSystem.onTabScrollRight()
	CallTabScrollScripts("right")
end

function widgetSystem.onTableUpdate(_, tableID)
	if not IsValidWidgetElement(tableID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local tableentry = private.associationList[tableID]
	if tableentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	local frameElement = widgetSystem.getFrameElementByTableElement(tableentry.element)

	if #private.pendingFrames > 0 then
		for _, frameID in ipairs(private.pendingFrames) do
			if GetFrameLayer(frameID) == GetFrameLayer(frameElement.frame) then
				return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
			end
		end
	end
	
	widgetSystem.drawTableCells(frameElement, tableID, tableentry.element, tableentry.element.topRow, tableentry.element.bottomRow, tableentry.element.curRow, false, "ctrl")
	widgetSystem.updateMouseOverText(tableID)
end

function widgetSystem.onToggleMouseOverText(_, value)
	widgetSystem.toggleMouseOverText(value)
end

function widgetSystem.onViewRemoved()
	if #private.frames > 0 then
		DebugError("Widget system error. We got a view removed-event with an active frame. Follow-up errors are expected to occur.")
	end

	RegisterWidget()
end

-------------------------------------
-- Widget system related functions --
-------------------------------------
function widgetSystem.addToAssociationList(widgetID, elementEntry, rootAnarkElement, parentX, parentY, parentWidth, textComponent, activeSlide, inactiveSlide, curSlide)
	private.associationList[widgetID] = {
		["element"]       = elementEntry,
		["rootAnarkElement"] = rootAnarkElement,
		["parentx"]       = parentX,
		["parenty"]       = parentY,
		["parentwidth"]   = parentWidth,
		["textComponent"] = textComponent,
		["activeSlide"]   = activeSlide,
		["inactiveSlide"] = inactiveSlide,
		["curSlide"]      = curSlide
	}
	C.SetWidgetAssociatedElement(widgetID, true)
end

-- Interpolate between colors (value == 0.0 results in color0, value == 1.0 results in color1)
function widgetSystem.interpolateColor(color0, color1, value)
	return {
		r = math.floor(value * color1.r + (1.0 - value) * color0.r),
		g = math.floor(value * color1.g + (1.0 - value) * color0.g),
		b = math.floor(value * color1.b + (1.0 - value) * color0.b),
		a = math.floor(value * (color1.a or 100) + (1.0 - value) * (color0.a or 100)),
		glow = math.floor(value * (color1.glow or 0) + (1.0 - value) * (color0.glow or 0)),
	}
end

-- returns the number of rows which need to be moved so that the specified bottom row will be the new bottom row
-- note that a positive number will be returned, if the table is to be moved downwards while a negative value indicates
-- the table to be shifted upwards
function widgetSystem.calculateRowsToMoveByBottomRow(tableID, tableElement, newBottomRow)
	if newBottomRow == tableElement.bottomRow then
		return 0 -- no shifting required, bottomRow is already the requested one
	end

	local curtableheight = 0
	-- ensure that we do not try to display > maxRows number of rows
	local newTopRow = math.max(tableElement.numFixedRows + 1, newBottomRow - tableElement.displayedRows + 1)
	-- calculate row-height starting from new bottomRow to top-row (inverse loop)
	for row = newBottomRow, newTopRow, -1 do
		-- calculate cell scale factor
		local curRowHeight = GetTableRowHeight(tableID, row)

		-- check if we exceed the max table height
		local nextrowheight = curRowHeight
		if row ~= newBottomRow then
			-- add space for border between table rows for rows 2..x
			if C.IsTableRowBorderBelowEnabled(tableID, row) then
				nextrowheight = nextrowheight + config.table.bordersize
			end
		end

		curtableheight = curtableheight + nextrowheight

		if curtableheight > tableElement.nonFixedSectionHeight then
			-- we would exceed the tableheight if we were to display the row - hence the new topRow is row + 1
			newTopRow = row + 1
			break
		end
	end

	-- note: callers ensure this is only called with topRow ~= nil
	return newTopRow - tableElement.topRow
end

-- takes a table and a number of pixels the table is expected to be shifted up/down and returns the actual number of rows which are to be shifted
-- if pixeldiff < 0 the table is expected to be shifted down (i.e. scroll down)
-- if pixeldiff > 0 the table is expected to be shifted up (i.e. scroll up)
-- the function returns 0, if the pixeldiff is less than half the width of the previous/next row
function widgetSystem.calculateRowsToMoveByPixelDiff(tableID, tableElement, pixeldiff)
	-- note: callers ensure by design, that this is only called if topRow ~= nil (aka: that we do have normal rows)
	-- since this is only called as part of dragging the scrollbar which by design only exists, if we have non-fixed rows
	if pixeldiff == 0 then
		return 0 -- simply case --- no calculation needed at all
	end

	local shiftUp = (pixeldiff > 0)

	local pixelToShift = math.abs(pixeldiff)
	local totalRowHeight = 0
	local rowsToShift = 0
	if shiftUp then
		-- check how many rows we have to shift down
		for row = tableElement.topRow, tableElement.numFixedRows + 1, -1 do
			local curRowHeight = GetTableRowHeight(tableID, row)
			totalRowHeight = totalRowHeight + curRowHeight / 2
			if totalRowHeight > pixelToShift then
				break -- done, next row would be less than half-scrolled, hence do not scroll to that
			end
			rowsToShift = rowsToShift + 1
			totalRowHeight = totalRowHeight + curRowHeight / 2
		end
	else
		-- check how many rows we have to shift up
		for row = tableElement.bottomRow, tableElement.numRows do
			local curRowHeight = GetTableRowHeight(tableID, row)
			totalRowHeight = totalRowHeight + curRowHeight / 2
			if totalRowHeight > pixelToShift then
				break -- done, next row would be less than half-scrolled, hence do not scroll to that
			end
			rowsToShift = rowsToShift + 1
			totalRowHeight = totalRowHeight + curRowHeight / 2
		end
	end

	return rowsToShift
end

-- #StefanMed this can actually be precalculated (aka: set tableElement.lastTopRow during setUpTable())
-- returns the number of rows which need to be moved so that the specified top row will be the new top row
-- note that a positive number will be returned, if the table is to be moved downwards while a negative value indicates
-- the table to be shifted upwards
function widgetSystem.calculateRowsToMoveByTopRow(tableID, tableElement, newTopRow)
	-- note: callers ensure this is only called if we have non-fixed rows
	if newTopRow == tableElement.topRow then
		return 0 -- no shifting required, topRow is already the requested one
	end

	local curtableheight = 0
	local maxTopRow
	-- calculate the last row we should actually move down to (so that we do not unnecessarily page down too much and end up with only half the last table cells being displayed)
	for row = tableElement.numRows, tableElement.numFixedRows + 1, -1 do
		-- calculate cell scale factor
		local curRowHeight = GetTableRowHeight(tableID, row)

		-- check if we exceed the max table height
		local nextrowheight = curRowHeight
		if row ~= tableElement.numRows then
			-- add space for border between table rows for rows 2..x
			if C.IsTableRowBorderBelowEnabled(tableID, row) then
				nextrowheight = nextrowheight + config.table.bordersize
			end
		end

		curtableheight = curtableheight + nextrowheight

		if curtableheight > tableElement.nonFixedSectionHeight then
			-- we would exceed the tableheight if we were to display the row - hence the new minTopRow is row + 1
			maxTopRow = row + 1
			break
		end
	end

	local topRow = math.min(maxTopRow, newTopRow)

	return topRow - tableElement.topRow
end

-- return minRowHeight required for the fixed rows
function widgetSystem.calculateFixedRowHeight(tableID, tableElement)
	local numFixedRows = tableElement.numFixedRows
	local minRowHeight = 0
	local numRows      = GetTableNumRows(tableID)

	if numFixedRows > 0 then
		local numBorderElements = 0
		for row = 1, numFixedRows do
			if C.IsTableRowBorderBelowEnabled(tableID, row) then
				numBorderElements = numBorderElements + 1
			end
			minRowHeight = minRowHeight + GetTableRowHeight(tableID, row)
		end
		if numRows == numFixedRows then
			numBorderElements = numBorderElements - 1 -- no border element between fixed rows section and normal row section, if all rows are fixed rows
		end
		minRowHeight = minRowHeight + numBorderElements * config.table.bordersize
	end

	return minRowHeight
end

-- calculates the minimal row height which should be ensured to display the interactive/scrollable table
-- that way we ensure that a table always displays a selectable row including its following (unselectable) rows
--     --------------------
--     - selectable row   -  ---
--     - unselectable row -  - <--- ensure that the table's height is large enough so it can display these three rows all together
--     - unselectable row -  ---
--     - selectable row   -
-- 
-- return minRowHeight
function widgetSystem.calculateMinRowHeight(tableID, tableElement)
	local numRows = GetTableNumRows(tableID)

	if numRows == 0 then
		return 0 -- empty table, early out
	end

	local numFixedRows = tableElement.numFixedRows
	if numFixedRows == numRows then
		return 0 -- all rows are fixed rows, so no non-fixed-row section
	end

	local unselectableRows = tableElement.unselectableRows
	local minRowHeight    = 0
	local startRow        = tableElement.numFixedRows + 1 -- row where the normal section starts
	local curNumRows      = 1
	local curHeight       = GetTableRowHeight(tableID, startRow)
	local curBorderHeight = 0

	for row = startRow, numRows do
		if not unselectableRows[row] then
			-- got next selectable row, update required height for displaying previous rows
			-- add required height for border elements
			curHeight    = curHeight + curBorderHeight
			minRowHeight = math.max(minRowHeight, curHeight)

			-- reset for next row
			curNumRows = 0
			curHeight  = 0
			curBorderHeight = 0
		end

		curNumRows = curNumRows + 1
		curHeight  = curHeight  + GetTableRowHeight(tableID, row)
		if C.IsTableRowBorderBelowEnabled(tableID, row) then
			curBorderHeight = curBorderHeight + config.table.bordersize
		end
	end

	-- calculate last row height (in case it's a selectable one, or the only row at all)
	if numRows == startRow or unselectableRows[numRows] then
		curHeight    = curHeight + curBorderHeight
		minRowHeight = math.max(minRowHeight, curHeight)
	end

	return minRowHeight
end

-- returns the step the slider should be scrolled by when performing a page left/right
-- singleStepSliderWidth = the width the slider would have if it were to represent a single value (i.e. 1)
-- sliderWidth = the actual width of the slider
-- granularity = the granularity the slider should ensure
function widgetSystem.calculateSliderScrollBarPageStep(singleStepSliderWidth, sliderWidth, granularity)
	local step = sliderWidth / singleStepSliderWidth

	-- ensure that we only step by the granularity
	step = step - (step % granularity)

	-- ensure that we at least perform a single step (even if the calculated page step is < granularity)
	step = math.max(step, granularity)

	return step
end

function widgetSystem.convertAlignment(alignment)
	if alignment == "left" then
		return 0
	elseif alignment == "center" then
		return 1
	else -- right
		return 2
	end
end

-- returns the column width in px (restricted to a precision of 0.01% to prevent float inaccuracy problems)
-- We only ensure a precesion of 0.01% when working with percent values so that we don't run into float precision problems
-- for any tablewidth <= 10,000 px.
-- returns true, iff columns could be converted successfully
--         false, indicating an error (most likely exceeding the max table width)
function widgetSystem.convertColumnWidth(columnWidths, columnWidthsInPercent, tablewidth)
	local unaccountedwidths = {}
	local sumAllColumns = 0

	-- calculate sum of all columns and convert percentage values to px values
	local columnwidth
	local extraPixel = nil
	local substractedPixel = false
	for key, value in ipairs(columnWidths) do
		sumAllColumns = sumAllColumns + value
		if value == 0 then
			table.insert(unaccountedwidths, key)
		elseif columnWidthsInPercent then
			columnwidth = value / 100 * tablewidth
			if extraPixel then
				columnwidth = columnwidth - 1
				extraPixel = nil
				substractedPixel = true -- indicates that we already substracted a pixel --- the next ceil hence will not cause an extra pixel being used
			end
			if columnwidth % 1 ~= 0 then
				-- prevent subpixels
				columnwidth = math.ceil(columnwidth)
				if substractedPixel then
					substractedPixel = false
				else
					extraPixel = key
				end
			end
			columnWidths[key] = columnwidth
		end
	end
	if extraPixel then
		columnWidths[extraPixel] = columnWidths[extraPixel] -1
		extraPixel = nil
	end

	-- ensure the sum of all columns doesn't exceed the available table width (i.e. is not > 100% or > tablewidth)
	if columnWidthsInPercent then
		if sumAllColumns > 100 then
			return false
		end
	else -- column widths in px
		if sumAllColumns > tablewidth then
			return false
		end
	end

	-- calculate auto values up to 100% of the table width
	local widthpercolumn
	if #unaccountedwidths ~= 0 then
		local widthleft
		local lastcolumn
		if columnWidthsInPercent then
			widthleft = 100 - sumAllColumns
			-- flooring the remaining percentage, so we won't exceed the table width due to float-precision issues
			-- i.e. the resulting table width can be anything between 99% and 100%
			widthpercolumn = math.floor(widthleft * 100 / #unaccountedwidths) / 100
			lastcolumn = widthleft - (widthpercolumn * (#unaccountedwidths - 1))
			-- always ceil the last pixel (#StefanLow - unittest to prove that assumption is correct)
			lastcolumn = math.ceil(lastcolumn / 100 * tablewidth)
		else
			widthleft = tablewidth - sumAllColumns
			widthpercolumn = math.floor(widthleft / #unaccountedwidths)
			lastcolumn = widthpercolumn - (widthpercolumn * (#unaccountedwidths - 1))
		end
		columnWidths[table.remove(unaccountedwidths)] = lastcolumn
	end

	-- #StefanLow could be done directly above
	-- convert back to px
	if columnWidthsInPercent then
		for _, value in ipairs(unaccountedwidths) do
			columnwidth = widthpercolumn / 100 * tablewidth
			if extraPixel then
				columnwidth = columnwidth - 1
				extraPixel = nil
				substractedPixel = true -- indicates that we already substracted a pixel --- the next ceil hence will not cause an extra pixel being used
			end
			if columnwidth % 1 ~= 0 then
				-- prevent widths using subpixel
				-- ceil the value and for the next column reduce the cell size by one
				columnwidth = math.ceil(columnwidth)
				if substractedPixel then
					substractedPixel = false
				else
					extraPixel = value
				end
			end
			columnWidths[value] = columnwidth
		end
		if extraPixel then
			-- reduce the last column by one so to ensure we've got the correct table width
			columnWidths[value] = columnWidths[value] - 1
		end
	end

	return true -- done
end

function widgetSystem.setHighlightColor(tableElement, row)
	if row and (next(tableElement.noninteractiveRows) == nil) then
		-- nothing to do
		return
	end

	-- border highlight color
	local color = Color["table_row_highlight"]
	if tableElement.highlightMode == "grey" then
		color = Color["table_row_highlight_grey"]
	elseif row then
		if tableElement.noninteractiveRows[row] then
			color = Color["table_row_highlight_grey"]
		end
	end
	for _, entry in ipairs(config.table.borderElements) do
		SetDiffuseColor(tableElement.borderElements[entry], color.r, color.g, color.b)
		setAttribute(tableElement.borderElements[entry], "opacity", color.a)
		local material = getElement("material", tableElement.borderElements[entry])
		setAttribute(material, "glowfactor", color.glow)
	end
end

-- draws the specified portion of the table
-- returns the current table height
function widgetSystem.drawTableCells(frameElement, tableID, tableElement, firstRow, lastRow, curRow, firsttime, modified)
	-- note: caller ensures that firstRow is not null, if we do have non-fixed rows
	-- hide old table cells, so we start anew
	widgetSystem.hideTableCells(frameElement, tableElement)

	local cellposy       = tableElement.offsety
	local curtableheight = 0
	local displayedRows = 0

	-- first we draw the fixed rows
	if tableElement.numFixedRows > 0 then
		curtableheight, _, displayedRows = widgetSystem.drawTableSection(frameElement, tableID, tableElement, 1, tableElement.numFixedRows, displayedRows, cellposy, 0, 0, true, firsttime)
		cellposy = cellposy - curtableheight
	end

	-- next draw the non-fixed rows
	if lastRow > tableElement.numFixedRows then
		if firstRow <= tableElement.numFixedRows then
			firstRow = tableElement.numFixedRows + 1
		end
		tableElement.topRow = firstRow
		curtableheight, lastRow, displayedRows = widgetSystem.drawTableSection(frameElement, tableID, tableElement, firstRow, lastRow, displayedRows, cellposy, curtableheight, tableElement.numFixedRows, false, firsttime)
	end

	tableElement.bottomRow = lastRow
	tableElement.displayedRows = displayedRows

	-- only select rows, if the table is interactive
	if (not firsttime) and IsInteractive(tableID) then
		if tableElement.multiSelect then
			widgetSystem.selectRowInternal(tableID, tableElement, curRow, modified, nil, "user")
			for row in pairs(tableElement.highlightedRows) do
				widgetSystem.highlightTableRow(tableID, tableElement, row)
			end
		else
			widgetSystem.selectRowInternal(tableID, tableElement, curRow, nil, nil, "user")
		end
	end

	return curtableheight
end

function widgetSystem.getColumnSpanInfo(tableID, tableElement, row, col, isFixedRowSection)
	local colspan = GetTableColumnSpan(tableID, row, col)
	local cellwidth = 0
	for i = 1, colspan do
		if isFixedRowSection then
			cellwidth = cellwidth + tableElement.fixedRowColumnWidths[col + i - 1]
		else
			cellwidth = cellwidth + tableElement.columnWidths[col + i - 1]
		end
	end
	cellwidth = cellwidth + config.table.bordersize * (colspan - 1)

	return colspan, cellwidth
end

function widgetSystem.getBackgroundColumnSpanInfo(tableID, tableElement, row, col, isFixedRowSection)
	local backgroundcolspan = GetTableBackgroundColumnSpan(tableID, row, col)
	if backgroundcolspan == 0 then
		for i = col - 1, 1, -1 do
			backgroundcolspan = GetTableBackgroundColumnSpan(tableID, row, i)
			if backgroundcolspan ~= 0 then
				col = i
				break
			end
		end
	end
	local cellwidth = 0
	for i = 1, backgroundcolspan do
		if isFixedRowSection then
			cellwidth = cellwidth + tableElement.fixedRowColumnWidths[col + i - 1]
		else
			cellwidth = cellwidth + tableElement.columnWidths[col + i - 1]
		end
	end
	cellwidth = cellwidth + config.table.bordersize * (backgroundcolspan - 1)

	return col, backgroundcolspan, cellwidth
end

-- draws the specified table cell section at the specified y-position
-- curtableheight specifies the height of any previous table section (if any - 0 otherwise)
-- cellIndexOffset specifies the offset of the cellindex which is to be used for drawing table cells (so that when drawing certain table sections they don't reuse table cells of previous sections)
-- returns tableheight, lastDrawnRow
function widgetSystem.drawTableSection(frameElement, tableID, tableElement, firstRow, lastRow, displayedRows, cellposy, curtableheight, cellIndexOffset, isFixedRowSection, firsttime)
	for row = firstRow, lastRow do
		-- calculate cell scale factor
		local curRowHeight = GetTableRowHeight(tableID, row)

		-- check if we exceed the max table height
		local nextrowheight = curRowHeight
		-- unless for the top row in a table, we may need to shift cells down by the bordersize
		if (curtableheight ~= 0) then
			-- check if the previous row required a border
			if C.IsTableRowBorderBelowEnabled(tableID, row - 1) then
				nextrowheight = nextrowheight + config.table.bordersize
				cellposy = cellposy - config.table.bordersize
			end
		end
		if curtableheight + nextrowheight > tableElement.height then
			lastRow = row - 1
			break -- skip the following lines
		end

		-- if we display the table for the first time leave an extra row available for currentMouseWidgetElementLimbo
		local numTableRowElements = widgetSystem.getNumAvailableTableRowElements()
		if firsttime and (numTableRowElements == 1) then
			DebugError("Widget system error. No more table rows available. Skipping following rows.")
			lastRow = row - 1
			break
		end
		-- get the tablerow anark elements
		tableElement.cell[row - firstRow + 1 + cellIndexOffset] = widgetSystem.getElement("tableRows")
		if tableElement.cell[row - firstRow + 1 + cellIndexOffset] == nil then
			DebugError("Widget system error. No more table rows available. Skipping following rows.")
			lastRow = row - 1
			break
		else
			displayedRows = displayedRows + 1
		end
		curtableheight = curtableheight + nextrowheight

		-- move cellposition down by half the size of the scaled bar texture, so it is positionined correctly at the cellposy
		-- cellposy = cell position for previous row - curRowHeight / 2
		cellposy = cellposy - curRowHeight / 2
		tableElement.cellposy[row] = cellposy

		tableElement.cell[row - firstRow + 1 + cellIndexOffset].realRow = row

		-- move cells to correct layer
		for col = 1, config.tableRows.maxCols do
			local cellelement = tableElement.cell[row-firstRow+1+cellIndexOffset][col].element
			widgetSystem.moveAnarkElementFrameLayer(frameElement, cellelement, 1)
		end

		-- create the table row
		local isColBGSpanned = false
		for col = 1, tableElement.numCols do
			local colspan, cellwidth = widgetSystem.getColumnSpanInfo(tableID, tableElement, row, col, isFixedRowSection)
			if colspan ~= 0 then
				local cellentry = tableElement.cell[row-firstRow+1+cellIndexOffset][col]
				local colElement = cellentry.element
				cellentry.active = true

				local cellbackgroundwidth = cellwidth
				local _, _, backgroundcolspanwidth = widgetSystem.getBackgroundColumnSpanInfo(tableID, tableElement, row, col, isFixedRowSection)
				local isPrevColBGSpanned = isColBGSpanned
				isColBGSpanned = false
				if (col + colspan <= tableElement.numCols) and (GetTableBackgroundColumnSpan(tableID, row, col + colspan) == 0) then
					-- next col doesn't have a background colspan AND we're not the last col (including colspan) -> make cell wider
					cellbackgroundwidth = cellwidth + config.table.bordersize
					isColBGSpanned = true
				end
				local noTextSlide = "inactive"
				local textSlide   = "text"
				if tableElement.borderEnabled then
					noTextSlide = "background"
					textSlide = "textback"
					goToSlide(colElement, "background")
					widgetSystem.setElementPosition(getElement("middle", colElement), (cellbackgroundwidth - cellwidth) / 2, 0, ((cellbackgroundwidth - cellwidth) % 2 ~= 0), false)
					widgetSystem.setElementScale(getElement("middle", colElement), cellbackgroundwidth / 100, curRowHeight / 100)
				end
				-- position the table_cell-Anark element
				local cellposx = isFixedRowSection and tableElement.fixedRowCellposx[col] or tableElement.cellposx[col]
				widgetSystem.setElementPosition(colElement, cellposx + cellwidth/2, cellposy, (cellwidth % 2 ~= 0), (curRowHeight % 2 ~= 0))

				local childWidgetID = GetCellContent(tableID, row, col)
				if IsType(childWidgetID, "fontstring") then
					local textelement = getElement("Text", colElement)
					if C.IsTitleFontString(childWidgetID) then
						textSlide = "title"
						goToSlide(colElement, "title")

						if not tableElement.borderEnabled then
							DebugError("Widget system error. Title fontstring in table cell "..row.."/"..col.." defined in table without cell backgrounds. Currently not supported.")
						end

						widgetSystem.setElementPosition(getElement("titleline", colElement), (cellbackgroundwidth - cellwidth) / 2, -(curRowHeight - config.table.titleLineHeight) / 2, ((cellbackgroundwidth - cellwidth) % 2 ~= 0), false)
						widgetSystem.setElementScale(getElement("titleline", colElement), cellbackgroundwidth / 100, config.table.titleLineHeight / 100)
					end
					widgetSystem.setUpFontString(childWidgetID, colElement, textelement, textSlide, noTextSlide, -cellwidth/2, curRowHeight/2, cellwidth, ((cellposx + cellwidth/2) % 1 ~= 0), (cellposy % 1 ~= 0), frameElement, cellposx, cellposy + curRowHeight/2, backgroundcolspanwidth)
				elseif IsType(childWidgetID, "boxtext") then
					local boxtextelement = widgetSystem.getElement("boxtext")
					if boxtextelement ~= nil then
						widgetSystem.moveAnarkElementFrameLayer(frameElement, boxtextelement.mainElement, 1)
						cellentry.boxtext = {
							["element"] = boxtextelement
						}
						widgetSystem.setUpBoxText(childWidgetID, cellentry.boxtext, cellposx, cellposy + curRowHeight/2, cellwidth, curRowHeight, cellbackgroundwidth, isPrevColBGSpanned, isColBGSpanned)
					else
						DebugError("Widget system error. Already displaying " .. config.boxtext.maxElements .. " boxtexts. Cannot display more. BoxText in table cell " .. row .. "/" .. col .. " will be skipped.")
					end
				elseif IsType(childWidgetID, "icon") then
					local iconelement = widgetSystem.getElement("icon")
					if iconelement ~= nil then
						widgetSystem.moveAnarkElementFrameLayer(frameElement, iconelement, 1)
						widgetSystem.setUpIcon(frameElement, childWidgetID, iconelement, colElement, cellposx, cellposy, cellbackgroundwidth, backgroundcolspanwidth)
						cellentry.icon = iconelement
					else
						if private.miniWidgetSystemUsed then
							DebugError("Widget system error. No icons available in minimal widget system. Icon in table cell "..row.."/"..col.." will be skipped.")
						else
							DebugError("Widget system error. Already displaying "..config.icon.maxElements.." icons. Cannot display more. Icon in table cell "..row.."/"..col.." will be skipped.")
						end
					end
				elseif IsType(childWidgetID, "button") then
					local buttonElement = widgetSystem.getElement("button")
					if buttonElement ~= nil then
						widgetSystem.moveAnarkElementFrameLayer(frameElement, buttonElement, 1)
						cellentry.button = {
							["element"] = buttonElement
						}
						local isSelected = false
						if (tableElement.interactiveChild ~= nil) and (private.interactiveElement ~= nil) and (private.interactiveElement.widgetID == tableID) then
							isSelected = (tableElement.interactiveChild.widgetID == childWidgetID)
						end
						widgetSystem.setUpButton(frameElement, childWidgetID, cellentry.button, isSelected, cellposx, cellposy + curRowHeight / 2, cellbackgroundwidth, curRowHeight, backgroundcolspanwidth)
					else
						if private.miniWidgetSystemUsed then
							DebugError("Widget system error. No buttons available in minimal widget system. Button in table cell "..row.."/"..col.." will be skipped.")
						else
							DebugError("Widget system error. Already displaying "..config.button.maxElements.." buttons. Cannot display more. Button in table cell "..row.."/"..col.." will be skipped.")
						end
					end
				elseif IsType(childWidgetID, "checkbox") then
					local checkboxElement = widgetSystem.getElement("checkbox")
					if checkboxElement ~= nil then
						widgetSystem.moveAnarkElementFrameLayer(frameElement, checkboxElement, 1)
						cellentry.checkbox = {
							["element"] = checkboxElement
						}
						local isSelected = false
						if (tableElement.interactiveChild ~= nil) and (private.interactiveElement ~= nil) and (private.interactiveElement.widgetID == tableID) then
							isSelected = (tableElement.interactiveChild.widgetID == childWidgetID)
						end
						widgetSystem.setUpCheckBox(frameElement, childWidgetID, cellentry.checkbox, isSelected, cellposx, cellposy + curRowHeight / 2, cellwidth, curRowHeight, backgroundcolspanwidth)
					else
						if private.miniWidgetSystemUsed then
							DebugError("Widget system error. No checkboxes available in minimal widget system. Checkbox in table cell "..row.."/"..col.." will be skipped.")
						else
							DebugError("Widget system error. Already displaying "..config.checkbox.maxElements.." checkboxes. Cannot display more. Checkbox in table cell "..row.."/"..col.." will be skipped.")
						end
					end
				elseif IsType(childWidgetID, "dropdown") then
					local dropdownElement = widgetSystem.getElement("dropdown")
					if dropdownElement ~= nil then
						widgetSystem.moveDropDownElementFrameLayer(frameElement, dropdownElement, 1)
						cellentry.dropdown = {
							["element"] = dropdownElement
						}
						local isSelected = false
						if (tableElement.interactiveChild ~= nil) and (private.interactiveElement ~= nil) and (private.interactiveElement.widgetID == tableID) then
							isSelected = (tableElement.interactiveChild.widgetID == childWidgetID)
						end
						widgetSystem.setUpDropDown(frameElement, childWidgetID, cellentry.dropdown, isSelected, cellposx, cellposy+curRowHeight/2, cellwidth, curRowHeight, backgroundcolspanwidth)
					else
						if private.miniWidgetSystemUsed then
							DebugError("Widget system error. No dropdowns available in minimal widget system. Dropdown in table cell "..row.."/"..col.." will be skipped.")
						else
							DebugError("Widget system error. Already displaying "..config.dropdown.maxElements.." dropdowns. Cannot display more. Dropdown in table cell "..row.."/"..col.." will be skipped.")
						end
					end
				elseif IsType(childWidgetID, "editbox") then
					local editboxElement = widgetSystem.getElement("editbox")
					if editboxElement ~= nil then
						widgetSystem.moveAnarkElementFrameLayer(frameElement, editboxElement, 1)
						cellentry.editbox = {
							["element"] = editboxElement
						}
						widgetSystem.setUpEditBox(frameElement, childWidgetID, cellentry.editbox, cellposx+cellwidth/2, cellposy+curRowHeight/2, cellwidth, curRowHeight, backgroundcolspanwidth)
					else
						if private.miniWidgetSystemUsed then
							DebugError("Widget system error. No editboxex available in minimal widget system. Editbox in table cell "..row.."/"..col.." will be skipped.")
						else
							DebugError("Widget system error. Already displaying "..config.editbox.maxElements.." editboxes. Cannot display more. Editbox in table cell "..row.."/"..col.." will be skipped.")
						end
					end
				elseif IsType(childWidgetID, "graph") then
					local graphElement = widgetSystem.getElement("graph")
					if graphElement ~= nil then
						widgetSystem.moveGraphElementFrameLayer(frameElement, graphElement, 1)
						cellentry.graph = {
							["element"] = graphElement
						}
						widgetSystem.setUpGraph(childWidgetID, cellentry.graph, cellposx+cellwidth/2, cellposy+curRowHeight/2, cellwidth, curRowHeight, frameElement, backgroundcolspanwidth)
					else
						if private.miniWidgetSystemUsed then
							DebugError("Widget system error. No graphs available in minimal widget system. Graph in table cell "..row.."/"..col.." will be skipped.")
						else
							DebugError("Widget system error. Already displaying "..config.graph.maxElements.." graphs. Cannot display more. Graph in table cell "..row.."/"..col.." will be skipped.")
						end
					end
				elseif IsType(childWidgetID, "slidercell") then
					local slidercellElement = widgetSystem.getElement("slidercell")
					if slidercellElement ~= nil then
						widgetSystem.moveAnarkElementFrameLayer(frameElement, slidercellElement.main, 1)
						cellentry.slidercell = {
							["element"] = slidercellElement
						}
						widgetSystem.setUpSliderCell(frameElement, childWidgetID, cellentry.slidercell, tableElement.cellposx[col]+cellwidth/2, cellposy+curRowHeight/2, cellwidth, curRowHeight, backgroundcolspanwidth)
					else
						if private.miniWidgetSystemUsed then
							DebugError("Widget system error. No slidercells available in minimal widget system. Slidercell in table cell "..row.."/"..col.." will be skipped.")
						else
							DebugError("Widget system error. Already displaying "..config.slidercell.maxElements.." slidercells. Cannot display more. SliderCell in table cell "..row.."/"..col.." will be skipped.")
						end
					end
				elseif IsType(childWidgetID, "shieldhullbar") then
					local shieldHullBarElement = widgetSystem.getElement("shieldhullbar")
					if shieldHullBarElement ~= nil then
						widgetSystem.moveAnarkElementFrameLayer(frameElement, shieldHullBarElement, 1)
						widgetSystem.setUpShieldHullBar(childWidgetID, shieldHullBarElement, colElement, cellposx, cellposy+curRowHeight/2, cellwidth, curRowHeight)
						cellentry.shieldhullbar = shieldHullBarElement
					else
						if private.miniWidgetSystemUsed then
							DebugError("Widget system error. No shield/hull bar elements available in minimal widget system. Shield/hull bar element in table cell "..row.."/"..col.." will be skipped.")
						else
							DebugError("Widget system error. Already displaying "..config.shieldhullbar.maxElements.." shield/hull bar elements. Cannot display more. Shield/hull bar element in table cell "..row.."/"..col.." will be skipped.")
						end
					end
				elseif IsType(childWidgetID, "statusbar") then
					local statusBarElement = widgetSystem.getElement("statusbar")
					if statusBarElement ~= nil then
						local istitle = C.IsTitleStatusBar(childWidgetID)
						if istitle then 
							goToSlide(colElement, "title")

							if not tableElement.borderEnabled then
								DebugError("Widget system error. Title fontstring in table cell "..row.."/"..col.." defined in table without cell backgrounds. Currently not supported.")
							end

							widgetSystem.setElementPosition(getElement("titleline", colElement), (cellbackgroundwidth - cellwidth) / 2, -(curRowHeight - config.table.titleLineHeight) / 2, ((cellbackgroundwidth - cellwidth) % 2 ~= 0), false)
							widgetSystem.setElementScale(getElement("titleline", colElement), cellbackgroundwidth / 100, config.table.titleLineHeight / 100)

							local color = ffi.new("Color")
							if C.GetStatusBarTitleColor(childWidgetID, color) then
								local material = getElement("titleline.material", colElement)
								SetDiffuseColor(material, color.red, color.green, color.blue)
								setAttribute(material, "opacity", color.alpha)
								setAttribute(material, "glowfactor", C.GetStatusBarTitleGlowFactor(childWidgetID))
							end

							local textelement = getElement("Text", colElement)
							setAttribute(textelement, "textstring", "")
						end

						widgetSystem.moveAnarkElementFrameLayer(frameElement, statusBarElement.element, 1)
						widgetSystem.setUpStatusBar(childWidgetID, statusBarElement, colElement, cellposx, cellposy+curRowHeight/2, cellwidth, curRowHeight, istitle)
						cellentry.statusbar = statusBarElement
					else
						if private.miniWidgetSystemUsed then
							DebugError("Widget system error. No status bar elements available in minimal widget system. Status bar element in table cell "..row.."/"..col.." will be skipped.")
						else
							DebugError("Widget system error. Already displaying "..config.statusbar.maxElements.." status bar elements. Cannot display more. Status bar element in table cell "..row.."/"..col.." will be skipped.")
						end
					end
				else
					DebugError("Widget system error. Table contains unsupported cellcontent. Skipping item in table cell "..row.."/"..col..".")
				end
			end -- if colspan ~= 0
		end -- for col

		-- update the cellposition to the upper position of the next cell (moving the remaining half of the current cell height)
		cellposy = cellposy - curRowHeight/2

		-- set to default color
		widgetSystem.setTableRowColor(tableID, tableElement, row, nil, nil, false)
	end -- for row

	return curtableheight, lastRow, displayedRows
end

-- draws a flowchart background (header, footer or column)
function widgetSystem.drawFlowchartBackground(anarkElement, x, y, width, height, backgroundelementname, materialname, color, slide)
	widgetSystem.setElementPosition(anarkElement, x, y, (width % 2 ~= 0), (height % 2 ~= 0))
	if backgroundelementname then
		local backgroundElement = getElement(backgroundelementname, anarkElement)
		widgetSystem.setElementScale(backgroundElement, width / 100, height / 100)
	end
	if materialname and color then
		local material = getElement(materialname, anarkElement)
		widgetSystem.setElementColorAlpha(material, color)
	end
	if slide then
		goToSlide(anarkElement, slide)
	end
end

-- draws the specified portion of the flowchart
function widgetSystem.drawFlowchartContent(frameElement, flowchartID, flowchartElement)
	-- hide old flowchart content, so we start anew
	widgetSystem.hideFlowchartContent(frameElement, flowchartElement)

	local flowchartData = flowchartElement.data
	if flowchartData.numRows == 0 then
		return
	end

	-- determine number of visible columns and their total width
	local curVisibleWidth = 0
	local lastVisibleCol = 0
	for col = flowchartData.firstVisibleCol, flowchartData.numColumns do
		local curColWidth = flowchartData.columns[col].width
		if curVisibleWidth + curColWidth > flowchartData.maxVisibleWidth then
			break
		end
		curVisibleWidth = curVisibleWidth + curColWidth
		lastVisibleCol = col
	end
	flowchartData.curVisibleWidth = curVisibleWidth
	flowchartData.stretchedVisibleWidth = curVisibleWidth
	flowchartData.lastVisibleCol = lastVisibleCol

	-- determine number of visible rows and their total height
	local curVisibleHeight = 0
	local lastVisibleRow = 0
	for row = flowchartData.firstVisibleRow, flowchartData.numRows do
		local curRowHeight = flowchartData.rowHeights[row]
		if curVisibleHeight + curRowHeight > (flowchartData.maxVisibleHeight - flowchartData.maxCaptionHeight) then
			break
		end
		curVisibleHeight = curVisibleHeight + curRowHeight
		lastVisibleRow = row
	end
	flowchartData.curVisibleHeight = curVisibleHeight
	flowchartData.stretchedVisibleHeight = curVisibleHeight
	flowchartData.lastVisibleRow = lastVisibleRow

	-- determine stretched row heights: if scrollbar exists, stretch to fill visible height, but also stretch invisible cells for more appropriate angles of clipped edges
	local stretchsize, roundingdiff = 0, 0
	local numvisiblecells = (flowchartData.lastVisibleRow - flowchartData.firstVisibleRow + 1)
	if flowchartData.hasVerticalScrollBar and numvisiblecells > 0 then
		stretchsize = math.floor((flowchartData.maxVisibleHeight - flowchartData.maxCaptionHeight - curVisibleHeight) / numvisiblecells)
		roundingdiff = (flowchartData.maxVisibleHeight - flowchartData.maxCaptionHeight - curVisibleHeight) - stretchsize * numvisiblecells
		flowchartData.stretchedVisibleHeight = flowchartData.maxVisibleHeight - flowchartData.maxCaptionHeight
	end
	-- NOTE: curVisibleHeight + (stretchsize * numvisiblecells + roundingdiff) = maxVisibleHeight
	for row, rowheight in ipairs(flowchartData.rowHeights) do
		flowchartData.stretchedRowYOffsets[row] = flowchartData.rowYOffsets[row] + (row - 1) * stretchsize + (row > flowchartData.firstVisibleRow and roundingdiff or 0)
		flowchartData.stretchedRowHeights[row] = rowheight + stretchsize + (row == flowchartData.firstVisibleRow and roundingdiff or 0)
	end

	-- analogously, determine stretched column widths
	stretchsize, roundingdiff = 0, 0
	numvisiblecells = (flowchartData.lastVisibleCol - flowchartData.firstVisibleCol + 1)
	if flowchartData.hasHorizontalScrollBar and numvisiblecells > 0 then
		stretchsize = math.floor((flowchartData.maxVisibleWidth - curVisibleWidth) / numvisiblecells)
		roundingdiff = (flowchartData.maxVisibleWidth - curVisibleWidth) - stretchsize * numvisiblecells
		flowchartData.stretchedVisibleWidth = flowchartData.maxVisibleWidth
	end
	-- NOTE: curVisibleWidth + (stretchsize * numvisiblecells + roundingdiff) = maxVisibleWidth
	for col, coldata in ipairs(flowchartData.columns) do
		flowchartData.stretchedColXOffsets[col] = coldata.offsetx + (col - 1) * stretchsize + (col > flowchartData.firstVisibleCol and roundingdiff or 0)
		flowchartData.stretchedColWidths[col] = coldata.width + stretchsize + (col == flowchartData.firstVisibleCol and roundingdiff or 0)
	end

	local parentx = frameElement.offsetx
	local parenty = frameElement.offsety
	local contentreloffsetx = parentx + (flowchartData.contentOffsetx - flowchartData.stretchedColXOffsets[flowchartData.firstVisibleCol] + (flowchartData.maxVisibleWidth - flowchartData.stretchedVisibleWidth) / 2)
	local contentreloffsety = parenty - (flowchartData.contentOffsety - flowchartData.stretchedRowYOffsets[flowchartData.firstVisibleRow]) - flowchartData.maxCaptionHeight

	-- draw columns
	-- TODO: #flowchart: Take horizontal and vertical scrollbars into account
	local colyoff = parenty - (flowchartData.contentOffsety + flowchartData.maxVisibleHeight / 2)
	local colheight = flowchartData.maxVisibleHeight + 2 * config.table.bordersize
	local flowchartNodeError = false
	for col = flowchartData.firstVisibleCol, flowchartData.lastVisibleCol do
		local coldata = flowchartData.columns[col]
		local colwidth = flowchartData.stretchedColWidths[col]
		local colxoff = math.floor(contentreloffsetx + flowchartData.stretchedColXOffsets[col] + colwidth / 2 + 0.5)
		-- draw column backgrounds
		-- column bgcolor is optional, caption is optional
		local bgslide = coldata.bgColor and (coldata.captionText and "textback" or "background") or (coldata.captionText and "text" or nil)
		if bgslide then
			local columnBackground = flowchartElement.columnBackgrounds[col]
			if columnBackground then
				widgetSystem.drawFlowchartBackground(columnBackground, colxoff, colyoff, colwidth, colheight, "background", "background.material", coldata.bgColor, bgslide)
				if coldata.captionText then
					local textelement = getElement("Text", columnBackground)
					widgetSystem.setElementPosition(textelement, 0, colheight / 2, nil, ((colheight / 2) % 2 ~= 0))
					setAttribute(textelement, "textstring", coldata.captionText)
					setAttribute(textelement, "font", coldata.captionFont)
					setAttribute(textelement, "size", coldata.captionFontSize)
					--setAttribute(textelement, "boxwidth", width - captionleftoffset)
					widgetSystem.setElementTextColor(textelement, coldata.captionColor)
				end
			end
		end
		-- draw nodes and junctions
		if not flowchartNodeError then
			for row = flowchartData.firstVisibleRow, flowchartData.lastVisibleRow do
				local cell = flowchartData.cells[row][col]
				if cell and not flowchartNodeError then
					local rowheight = flowchartData.stretchedRowHeights[row]
					local rowyoff = math.floor(contentreloffsety - (flowchartData.stretchedRowYOffsets[row] + rowheight / 2) + 0.5)
					local flowchartNodeElement = widgetSystem.getElement("flowchartNode")
					if not flowchartNodeElement then
						DebugError("Widget system error. No more flowchart nodes available. Skipping following nodes.")
						flowchartNodeError = true
						break
					end
					cell.nodeElement = flowchartNodeElement
					flowchartNodeElement.cell = cell
					if cell.shape ~= 0 then
						widgetSystem.showFlowchartNode(frameElement, cell.id, flowchartNodeElement, colxoff, rowyoff, colwidth, rowheight)
					else
						widgetSystem.showFlowchartJunction(frameElement, cell.id, flowchartNodeElement, colxoff, rowyoff, colwidth % 2 ~= 0, rowheight % 2 ~= 0)
					end
				end
			end
		end
	end

	-- edges
	for edgeidx, edge in ipairs(flowchartData.edges) do
		local flowchartEdgeElement = widgetSystem.getElement("flowchartEdge")
		if not flowchartEdgeElement then
			DebugError(string.format("Widget system error. No more flowchart edges available. Skipping following edges. (rank >= %s)", edge.rank))
			break
		end
		widgetSystem.refreshFlowchartEdgeData(edge.id, edge)
		if widgetSystem.drawFlowchartEdge(frameElement, edge.id, flowchartEdgeElement, edge, flowchartData) then
			edge.element = flowchartEdgeElement
		else
			widgetSystem.returnElement("flowchartEdge", flowchartEdgeElement)
		end
	end
end

function widgetSystem.addFlowchartConnector(connectorTable, x, y, xUseHalfPixel, yUseHalfPixel, size, color)
	table.insert(connectorTable, {
		x = x,
		y = y,
		xUseHalfPixel = xUseHalfPixel,
		yUseHalfPixel = yUseHalfPixel,
		size = size,
		color = color
	})
end

function widgetSystem.drawFlowchartConnectors(flowchartNodeElement, connectorTable)
	local numconnectors = math.min(#connectorTable, 6)
	for connidx = 1, numconnectors do
		local conndata = connectorTable[connidx]
		local connectorelement = getElement("con" .. connidx, flowchartNodeElement.connectors)
		widgetSystem.setElementPosition(connectorelement, conndata.x, conndata.y, conndata.xUseHalfPixel, conndata.yUseHalfPixel)
		local scale = conndata.size / config.flowchart.baseModelConnectorSize
		widgetSystem.setElementScale(connectorelement, scale, scale)
		local material = getElement(config.flowchart.connectorModelName .. ".Material", connectorelement)
		widgetSystem.setElementColorAlpha(material, conndata.color)
	end
	goToSlide(flowchartNodeElement.connectors, (numconnectors == 0) and "inactive" or ("con" .. numconnectors))
end

-- initializes and draws flowchart node
function widgetSystem.showFlowchartNode(frameElement, flowchartNodeID, flowchartNodeElement, x, y, cellwidth, cellheight)
	-- move node element to correct layer
	widgetSystem.moveAnarkElementFrameLayer(frameElement, flowchartNodeElement.main, 1)
	widgetSystem.addToAssociationList(flowchartNodeID, flowchartNodeElement, flowchartNodeElement.main, x, y)
	-- prepare layer info - expandedFrameLayer will be updated when node is expanded or collapsed
	flowchartNodeElement.currentFrameLayer = frameElement.layer
	flowchartNodeElement.expandedFrameLayer = nil
	flowchartNodeElement.cell.statusslide = "inactive"

	widgetSystem.setElementPosition(flowchartNodeElement.main, x, y, cellwidth % 2 ~= 0, cellheight % 2 ~= 0)

	widgetSystem.refreshFlowchartNodeData(flowchartNodeID, flowchartNodeElement.cell)
	widgetSystem.drawFlowchartNode(flowchartNodeID, flowchartNodeElement)
end

-- draws a flowchart node (also on updates)
function widgetSystem.drawFlowchartNode(flowchartNodeID, flowchartNodeElement)
	local node = flowchartNodeElement.cell
	local width, height = GetSize(flowchartNodeID)
	-- make sure node width is a multiple of 2
	width = math.floor(width / 2 + 0.5) * 2
	local scalefactor = height / config.flowchart.baseModelHeight
	local bordershape = config.flowchart.borderShapeData[node.shape]
	local outlinewidth = config.flowchart.baseModelOutlineSize * scalefactor
	local borderwidth = bordershape.baseWidth * scalefactor
	local middlewidth = width - 2 * borderwidth
	local nodecolors = node.colors

	-- mousepick
	widgetSystem.setElementScale(flowchartNodeElement.mousepick, width / 100, height / 100)

	-- background
	local bgelement = getElement("background", flowchartNodeElement.main)
	widgetSystem.setElementPosition(bgelement, -middlewidth / 2, 0, middlewidth % 2 ~= 0, false)
	widgetSystem.setElementScale(bgelement, middlewidth / config.flowchart.baseModelMiddleWidth, scalefactor)
	widgetSystem.setElementColorAlpha(getElement(config.flowchart.barOutlineModelName .. ".outline", bgelement), nodecolors.outline)
	widgetSystem.setElementColorAlpha(getElement(config.flowchart.barFillModelName .. ".bg_filled", bgelement), nodecolors.background)

	local newExpandedFrameLayer = nil
	if node.expandedframeid then
		newExpandedFrameLayer = IsValidWidgetElement(node.expandedframeid) and GetFrameLayer(node.expandedframeid) or nil
		if not newExpandedFrameLayer then
			-- error, frame doesn't exist any more
			node.expandedframeid = nil
			node.expandedbelow = false
			node.expandedabove = false
			CallWidgetEventScripts(node.id, "onFlowchartNodeCollapsed")
		end
	end
	local expanded = node.expandedbelow or node.expandedabove
	local prevExpanded = node.prevexpandedbelow or node.prevexpandedabove
	local yscalefactor = (node.expandedabove or (not expanded and node.prevexpandedabove)) and -1 or 1	-- mirror borders and expand arrow vertically if expanded above

	if node.expandable then
		-- expand arrow
		widgetSystem.setElementPosition(flowchartNodeElement.expand, -middlewidth / 2, 0, middlewidth % 2 ~= 0, false)
		local expandscale = node.caption.fontsize / config.flowchart.baseModelExpandArrowSize
		widgetSystem.setElementScale(flowchartNodeElement.expand, expandscale, expandscale * yscalefactor)
		local material = getElement("lso_arrow.lso_arrow.Material", flowchartNodeElement.expand)
		local color = Color["flowchart_node_arrow"]
		SetDiffuseColor(material, color.r, color.g, color.b)
		setAttribute(material, "opacity", color.a)
		setAttribute(material, "glowfactor", color.glow)
		goToSlide(flowchartNodeElement.expand, (prevExpanded ~= expanded and "anim" or "") .. (expanded and "down" or "right"))
	end

	-- truncate caption and/or statustext, considering case of overlapping caption and status (caption is left-aligned, status is right-aligned)
	local captionwidth = C.GetTextWidth(node.caption.text, node.caption.font, node.caption.fontsize)
	local statuswidth = (node.statustext and C.GetTextWidth(node.statustext.text, node.statustext.font, node.statustext.fontsize)) or (node.statusicon and node.statusicon.width) or 0
	if node.statusicon and node.statusicon.width == 0 then
		-- no status icon size provided, use default icon width/height
		statuswidth = (config.flowchart.baseModelHeight - 2 * config.flowchart.baseModelOutlineSize) * scalefactor
	end
	local minspacing = (captionwidth > 0 and statuswidth > 0) and 2 or 0
	-- available width for caption + status (without spacing), considering left spacing for expand-element (borderwidth + borderwidth/2) and possible right spacing
	local maxcontentwidth = width - minspacing - borderwidth * 1.5 - (node.statusicon and outlinewidth or borderwidth)
	if captionwidth + statuswidth > maxcontentwidth then
		-- truncate status text (ignore if status is an icon)
		if statuswidth > 0 and node.statustext then
			local maxstatuswidth = maxcontentwidth
			if captionwidth > 0 then
				-- caption is more important than status, don't take up more space than a third of the available width (unless caption text is short enough to allow for more)
				maxstatuswidth = math.max(0, maxcontentwidth / 3 - minspacing, maxcontentwidth - captionwidth - minspacing)
			end
			if maxstatuswidth < statuswidth then
				statuswidth = maxstatuswidth
				node.statustext.text = TruncateText(node.statustext.text, node.statustext.font, node.statustext.fontsize, statuswidth)
			end
		end
		-- truncate caption text
		local maxcaptionwidth = math.max(0, maxcontentwidth - statuswidth - minspacing)
		if captionwidth > 0 and maxcaptionwidth < captionwidth then
			captionwidth = maxcaptionwidth
			node.caption.text = TruncateText(node.caption.text, node.caption.font, node.caption.fontsize, captionwidth)
		end
	end

	-- caption
	local captionelement = getElement("Text", flowchartNodeElement.main)
	local captiondata = node.caption
	local captionheight = C.GetTextHeight(captiondata.text, captiondata.font, captiondata.fontsize, 0)
	local captionleftoffset = borderwidth + borderwidth / 2
	widgetSystem.setElementPosition(captionelement, captionleftoffset - width / 2, captionheight / 2, (width - borderwidth) % 2 ~= 0, captionheight % 2 ~= 0)
	setAttribute(captionelement, "textstring", captiondata.text)
	setAttribute(captionelement, "font", captiondata.font)
	setAttribute(captionelement, "size", captiondata.fontsize)
	setAttribute(captionelement, "boxwidth", width - captionleftoffset)
	widgetSystem.setElementTextColor(captionelement, captiondata.color)
	setAttribute(captionelement, "glowfactor", captiondata.glowfactor)
	-- status
	local statusslide = "inactive"
	if node.statustext then
		statusslide = "text"
		local statuselement = getElement("Text", flowchartNodeElement.status)
		local statusdata = node.statustext
		local statusheight = C.GetTextHeight(statusdata.text, statusdata.font, statusdata.fontsize, 0)
		local statusrightoffset = width - borderwidth
		widgetSystem.setElementPosition(statuselement, statusrightoffset - width / 2, captionheight / 2, width % 2 ~= 0, captionheight % 2 ~= 0)
		setAttribute(statuselement, "horzalign", 2) -- right-aligned
		setAttribute(statuselement, "textstring", statusdata.text)
		setAttribute(statuselement, "font", statusdata.font)
		setAttribute(statuselement, "size", statusdata.fontsize)
		setAttribute(captionelement, "boxwidth", statusrightoffset)
		widgetSystem.setElementTextColor(statuselement, statusdata.color)
		setAttribute(statuselement, "glowfactor", statusdata.glowfactor)
	elseif node.statusicon then
		statusslide = "icon"
		local icondata = node.statusicon
		local iconx, icony, iconwidth, iconheight = icondata.x, icondata.y, icondata.width, icondata.height
		if iconwidth == 0 and iconheight == 0 then
			iconheight = (config.flowchart.baseModelHeight - 2 * config.flowchart.baseModelOutlineSize) * scalefactor
			iconwidth = iconheight
			iconx = width / 2 - outlinewidth - iconwidth / 2
			icony = 0
		end
		local iconElement = getElement("icon", flowchartNodeElement.status)
		local material = getElement("icon", iconElement)
		widgetSystem.setElementPosition(iconElement, iconx, icony)
		local color = icondata.color
		SetIcon(getElement("icon", material), icondata.iconID, color.r, color.g, color.b, false, iconwidth, iconheight)
		setAttribute(material, "opacity", color.a)
		setAttribute(material, "glowfactor", icondata.glowfactor)
		if node.statusbgiconid ~= "" then
			statusslide = node.statusbgiconrotating and "icon2_rotate" or "icon2"
			iconElement = getElement("icon2", flowchartNodeElement.status)
			material = getElement("icon", iconElement)
			widgetSystem.setElementPosition(iconElement, iconx, icony)
			SetIcon(getElement("icon", material), node.statusbgiconid, color.r, color.g, color.b, false, iconwidth, iconheight)
			setAttribute(material, "opacity", color.a)
			setAttribute(material, "glowfactor", icondata.glowfactor)
		end
	end
	-- Update status slide only if it was changed, to prevent resetting animation
	if statusslide ~= node.statusslide then
		node.statusslide = statusslide
		goToSlide(flowchartNodeElement.status, statusslide)
	end
	-- connectors
	local connectors = { }
	for slottype, xoffsetfactor in pairs(config.flowchart.slotXOffsetFactors) do
		-- slottype is input or output
		for slot, slotcolor in ipairs(node[slottype]) do
			if slotcolor then
				local xoffadjustment = 0
				local yoffstep = math.floor(height * 25 / 100)
				if node[slottype][1] and node[slottype][2] and node[slottype][3] then
					-- all three slots are in use: place them at 15% / 50% / 85% of node height (counting from top), instead of 25% / 50% / 75%
					yoffstep = math.floor(height * 35 / 100)
				end
				-- push the non-center slots inwards a bit to fit to the node shape, unless the shape is rectangle
				if bordershape.slide ~= "rectangle" and config.flowchart.slotYOffsetFactors[slot] ~= 0 then
					xoffadjustment = math.floor(yoffstep / 3)
				end
				local yoff = config.flowchart.slotYOffsetFactors[slot] * yoffstep
				widgetSystem.addFlowchartConnector(connectors, xoffsetfactor * (width / 2 - xoffadjustment), -yoff, width % 2 ~= 0, false, node.connectorsize, slotcolor)
			end
		end
	end
	widgetSystem.drawFlowchartConnectors(flowchartNodeElement, connectors)
	-- bars
	local scale = node.scale
	local borderFillColors = { nodecolors.background, nodecolors.background }	-- left and right border
	-- bar colors:
	-- [  blue  |  green  |  brown  |  background  ]
	-- [------------------|                        ]   = scale.value = current amount (blue or blue+green)
	-- [------------------>-->-->---|              ]   = scale.slider1 = min wanted amount (creating buy offer for missing amount - brown)
	-- [--------|   <  <  <                        ]   = scale.slider2 = max wanted amount (creating sell offer for surplus amount - green)
	-- brown bar (diff1) appears only if slider1 is valid and scale.slider1 > scale.value
	-- green bar (diff2) appears only if slider2 is valid and scale.slider2 < scale.value
	local sliderhandles = { }
	local bars = { }
	if scale.max > 0 then
		if scale.value > 0 then
			-- blue, green, or blue+green
			if scale.slider2 < 0 or scale.slider2 >= scale.value then
				-- slider2 is disabled or above current amount, all blue
				table.insert(bars, { value = scale.value, color = nodecolors.value })
			elseif scale.slider2 == 0 then
				-- slider2 is at 0, all green
				table.insert(bars, { value = scale.value, color = nodecolors.diff2 })
			else
				-- blue until slider2, then green
				table.insert(bars, { value = scale.slider2, color = nodecolors.value })
				table.insert(bars, { value = scale.value, color = nodecolors.diff2 })
			end
		end
		if scale.slider1 > scale.value then
			-- brown
			table.insert(bars, { value = scale.slider1, color = nodecolors.diff1 })
		end
		-- adjust border fill colors if shape is not a rectangle
		if #bars > 0 and bordershape.slide ~= "rectangle" then
			borderFillColors[1] = bars[1].color
			if bars[#bars].value >= scale.max then
				borderFillColors[2] = bars[#bars].color
			end
		end
		-- handles
		if scale.step > 0 then
			if scale.slider1 >= 0 then
				table.insert(sliderhandles, { slideridx = 1, value = scale.slider1, yscalefactor = -1 })
			end
			if scale.slider2 >= 0 then
				table.insert(sliderhandles, { slideridx = 2, value = scale.slider2, yscalefactor = 1 })
			end
			-- Check if indices in sliderhandles have to be swapped - if this is a node update, we have to keep the order of handles consistent (slider1 may be enabled after slider2)
			if #sliderhandles == 2 and flowchartNodeElement.barData[1].assignedSliderIndex == 2 then
				sliderhandles[1], sliderhandles[2] = sliderhandles[2], sliderhandles[1]
			end
		end
	end
	-- clear any previous slider associations - however, they may be restored below, so we clear mouseOver/mouseDown states only for sliders that are not restored
	for _, bardata in ipairs(flowchartNodeElement.barData) do
		bardata.assignedSliderIndex = nil
	end
	for stateidx, statedata in ipairs(flowchartNodeElement.sliderStates) do
		if statedata.barIndex and (statedata.barIndex > #sliderhandles or sliderhandles[statedata.barIndex].slideridx ~= stateidx) then
			if statedata.mouseDown then
				statedata.mouseDown = false
				widgetSystem.setMouseCursorOverrideInternalDrag()
				private.flowchartNodeSliderDrag = nil
			end
			if statedata.mouseOver then
				statedata.mouseOver = false
				widgetSystem.setMouseCursorOverrideInternal()
				widgetSystem.setMouseOverOverride(node.id, nil, true)
			end
		end
		statedata.barIndex = nil
	end
	-- determine presentation slide and which Anark elements we have to use
	local slide = "empty"
	local maxbars = 3
	local numbars = math.min(#bars, maxbars)
	local maxsliderhandles = 2
	local numsliderhandles = math.min(#sliderhandles, maxsliderhandles)
	local numanarkgroups = math.max(numbars, numsliderhandles)
	if numanarkgroups > 0 then
		-- Set a slide that enables the required elements, and as few unnecessary elements as possible.
		-- Make sure that all unnecessary slider handles (triangles) are disabled to prevent the corresponding mousepick effect.
		slide = "bar" .. numanarkgroups .. (numsliderhandles > 0 and ("_triangle" .. numsliderhandles) or "")
		-- place or hide all Anark elements (bars and triangles) that the slide activates
		local maxbarwidth = middlewidth
		if bordershape.slide == "rectangle" then
			maxbarwidth = maxbarwidth + 2 * (borderwidth - outlinewidth)
		end
		local leftbarvalue = 0
		for group = 1, numanarkgroups do
			if group <= maxbars then
				local barelement = getElement("lso_middle_fill.lso_middle_f", flowchartNodeElement.barData[group].element)
				local material = getElement("bg_filled", barelement)
				if group <= numbars then
					local bar = bars[group]
					local rightbarvalue = math.max(leftbarvalue, math.min(maxbarwidth, bar.value * maxbarwidth / scale.max))
					widgetSystem.setElementPosition(barelement, -maxbarwidth / 2 + leftbarvalue, 0, maxbarwidth % 2 ~= 0, false)
					widgetSystem.setElementScale(barelement, (rightbarvalue - leftbarvalue) / config.flowchart.baseModelMiddleWidth, (height - 2 * outlinewidth) / (config.flowchart.baseModelHeight - 2 * config.flowchart.baseModelOutlineSize))
					widgetSystem.setElementColorAlpha(material, bar.color)
					leftbarvalue = rightbarvalue
				else
					-- Bar is active but not needed: Hide it
					setAttribute(material, "opacity", 0)
				end
			end
			if group <= numsliderhandles then
				local sliderhandle = sliderhandles[group]
				-- associate bar and slider data
				flowchartNodeElement.barData[group].assignedSliderIndex = sliderhandle.slideridx
				flowchartNodeElement.sliderStates[sliderhandle.slideridx].barIndex = group
				-- show slider handle (triangle)
				local triangleelement = getElement("lso_triangle.lso_triangle", flowchartNodeElement.barData[group].element)
				local material = getElement("Material", triangleelement)
				local offx = -maxbarwidth / 2 + math.min(maxbarwidth, sliderhandle.value * maxbarwidth / scale.max)
				local offy = -height / 2 * sliderhandle.yscalefactor
				local halfpixelx = maxbarwidth % 2 ~= 0
				widgetSystem.setElementPosition(triangleelement, offx, offy, halfpixelx, false)
				widgetSystem.setElementScale(triangleelement, scalefactor, scalefactor * sliderhandle.yscalefactor)
				-- update slider handle color based on slider assignment and recorded mouse state
				widgetSystem.updateFlowchartNodeSliderColor(flowchartNodeElement, sliderhandle.slideridx)
				-- mousepick
				local mousepickelement = flowchartNodeElement.barData[group].sliderMousepick
				-- NOTE: the center of the rectangle covering the triangle is not at the triangle center!
				local mousepickoffy = offy + (config.flowchart.baseModelTriangleHeight / 6 * scalefactor * sliderhandle.yscalefactor)
				widgetSystem.setElementPosition(mousepickelement, offx, mousepickoffy, halfpixelx, false)
				widgetSystem.setElementScale(mousepickelement,
					2.0 * config.flowchart.baseModelTriangleWidth * scalefactor / 100,
					1.3 * config.flowchart.baseModelTriangleHeight * scalefactor / 100)
			end
		end
	end
	-- left and right borders
	local realHeight = height
	for borderidx, border in ipairs(config.flowchart.borderData) do
		local borderelement = flowchartNodeElement[border.name]	-- leftBorder or rightBorder
		widgetSystem.setElementPosition(borderelement, middlewidth / 2 * border.direction, 0)--, middlewidth % 2 ~= 0, false)
		widgetSystem.setElementScale(borderelement, scalefactor * border.xscalefactor, scalefactor * yscalefactor)
		-- determine slide
		local shapeExpanded = expanded and bordershape.hasExpandGroups
		goToSlide(borderelement, bordershape.slide .. (expanded and "_ex" or ""))
		-- set outline color
		local outlinematerialname = string.format("%s_side_%s_outline.%s.outline", bordershape.groupprefix, (shapeExpanded and "expanded" or "collapsed"), bordershape.sideModel)
		local fillmaterialname = string.format("%s_side_collapsed_fill.%s.bg_filled", bordershape.groupprefix, bordershape.sideModel)
		widgetSystem.setElementColorAlpha(getElement(outlinematerialname, borderelement), nodecolors.outline)
		widgetSystem.setElementColorAlpha(getElement(fillmaterialname, borderelement), borderFillColors[borderidx])
		if shapeExpanded then
			local exfillmaterialname = string.format("%s_side_expanded_fill.%s.bg_filled", bordershape.groupprefix, bordershape.sideModel)
			widgetSystem.setElementColorAlpha(getElement(exfillmaterialname, borderelement), nodecolors.background)
		end

		if expanded then
			local expandedFrameLayerElement = getElement("expandedFrameLayer", borderelement)
			local outlines = {
				middle = getElement("middleSection.lso_line_vertical_outline.lso_line_ver", expandedFrameLayerElement),
				side = getElement("lso_line_vertical_outline.lso_line_ver", expandedFrameLayerElement),
				corner = getElement(string.format("%s_corner_outline.%s", bordershape.groupprefix, bordershape.cornerModel), expandedFrameLayerElement)
			}
			local backgrounds = {
				middle = getElement("middleSection.lso_line_vertical_fill.lso_line_ver", expandedFrameLayerElement),
				middleBorder = getElement("middleSection.lso_line_vertical_border_fill.lso_line_ver", expandedFrameLayerElement),
				side = getElement("lso_line_vertical_fill.lso_line_ver", expandedFrameLayerElement),
				corner = getElement(string.format("%s_corner_fill.%s", bordershape.groupprefix, bordershape.cornerModel), expandedFrameLayerElement)
			}
			-- set position and scale:
			-- note: all positions are relative to the inner border edge, scaling is relative to the node height (+/-scalefactor already in effect on parent scale)
			-- expandedFrameLayerElement offset = borderwidth = sidewidth = cornerwidth = cornerheight = middleoutlineheight = nodeheight / 2
			--  +----+------------------+
			--  |    |                  .
			--  |brdr| node (left half) .
			--  |    |                  .
			--  +----*------------------+   * = side outline/background pivot and middle background pivot
			--  |    |                  .
			--  |side|      middle      .
			--  |    |                  .
			--  +----*------------------.   * = corner outline/background pivot and middle outline pivot
			--  |crnr|   middleBorder   .
			--  +----+------------------+
			local _, expandedFrameHeight = GetSize(node.expandedframeid)
			-- add top and bottom padding
			expandedFrameHeight = math.max(expandedFrameHeight + 2 * config.flowchart.expandFramePadding, height / 2)
			realHeight = height + expandedFrameHeight
			-- outline thickness shouldn't be changed, so in all outline cases scale must be 1.0 for either scalex or scaley
			local yposfactor = -1 / scalefactor
			-- middle outline (note: middle outline/background are just side elements rotated by 90 degrees, so x and y are swapped!)
			local posx = 0
			local posy = yposfactor * expandedFrameHeight
			local scalex = (middlewidth / 2) / scalefactor / config.flowchart.baseModelMiddleWidth
			local scaley = 1.0
			widgetSystem.setElementPosition(outlines.middle, posy, posx)
			widgetSystem.setElementScale(outlines.middle, scaley, scalex)
			-- middle border fill
			widgetSystem.setElementPosition(backgrounds.middleBorder, posy, posx)
			widgetSystem.setElementScale(backgrounds.middleBorder, scaley, scalex)
			-- middle background
			posy = yposfactor * height / 2
			scaley = (expandedFrameHeight - 1.0 - outlinewidth) / scalefactor / bordershape.baseWidth
			widgetSystem.setElementPosition(backgrounds.middle, posy, posx)
			widgetSystem.setElementScale(backgrounds.middle, scaley, scalex)
			-- side outline/background
			widgetSystem.setElementPosition(outlines.side, 0, yposfactor * height / 2)
			widgetSystem.setElementPosition(backgrounds.side, 0, yposfactor * height / 2)
			widgetSystem.setElementScale(outlines.side, 1.0, (expandedFrameHeight - height / 2) / scalefactor / config.flowchart.baseModelMiddleWidth)
			widgetSystem.setElementScale(backgrounds.side, 1.0, (expandedFrameHeight - height / 2) / scalefactor / config.flowchart.baseModelMiddleWidth)
			-- corner outline/background (no scaling needed)
			widgetSystem.setElementPosition(outlines.corner, 0, yposfactor * expandedFrameHeight)
			widgetSystem.setElementPosition(backgrounds.corner, 0, yposfactor * expandedFrameHeight)
			-- set outline/background colors
			for _, element in pairs(outlines) do
				widgetSystem.setElementColorAlpha(getElement("outline", element), nodecolors.outline)
			end
			for _, element in pairs(backgrounds) do
				widgetSystem.setElementColorAlpha(getElement("bg_filled", element), nodecolors.background)
			end
		end
	end

	-- move elements related to the expanded frame to the required layer (to expandedFrameLayer on expansion, or back to flowchartnode layer)
	if newExpandedFrameLayer ~= flowchartNodeElement.expandedFrameLayer then
		local fromLayer = flowchartNodeElement.expandedFrameLayer or flowchartNodeElement.currentFrameLayer
		local toLayer = newExpandedFrameLayer or flowchartNodeElement.currentFrameLayer
		if fromLayer ~= toLayer then
			widgetSystem.moveFlowchartNodeBetweenFrameLayers(flowchartNodeElement, fromLayer, toLayer)
		end
		flowchartNodeElement.expandedFrameLayer = newExpandedFrameLayer
	end

	local associationElement = private.associationList[flowchartNodeID]
	local frameElement = widgetSystem.getFrameElementByFlowchartNodeElement(flowchartNodeElement)
	if frameElement then
		widgetSystem.addHelpOverlay(frameElement, flowchartNodeID, associationElement.parentx - width / 2, associationElement.parenty + height / 2, width, realHeight)
	end

	goToSlide(flowchartNodeElement.main, slide)
end

-- initializes and draws a flowchart junction
function widgetSystem.showFlowchartJunction(frameElement, flowchartNodeID, flowchartNodeElement, x, y, xUseHalfPixel, yUseHalfPixel)
	-- move node element to correct layer
	widgetSystem.moveAnarkElementFrameLayer(frameElement, flowchartNodeElement.main, 1)
	widgetSystem.addToAssociationList(flowchartNodeID, flowchartNodeElement, flowchartNodeElement.main, x, y)
	-- place node at junction position and display connector at center (0,0)
	widgetSystem.setElementPosition(flowchartNodeElement.main, x, y, xUseHalfPixel, yUseHalfPixel)

	widgetSystem.drawFlowchartJunction(flowchartNodeID, flowchartNodeElement)
end

-- draws a flowchart junction (also on updates)
function widgetSystem.drawFlowchartJunction(flowchartNodeID, flowchartNodeElement)
	local junction = flowchartNodeElement.cell
	-- junction X offset is half width
	local width, height = GetSize(flowchartNodeID)
	local connectors = { }
	widgetSystem.addFlowchartConnector(connectors, width / 2, 0, width % 2 ~= 0, false, junction.junctionsize, junction.junctioncolor)
	widgetSystem.drawFlowchartConnectors(flowchartNodeElement, connectors)
end

-- Helper for widgetSystem.drawFlowchartEdge()
function widgetSystem.getFlowchartAbsoluteSlotOffset(flowchartData, row, col, slottype, slot)
	local cell = flowchartData.cells[row] and flowchartData.cells[row][col]
	if cell then
		local cellx = flowchartData.stretchedColXOffsets[col] + flowchartData.stretchedColWidths[col] / 2
		local celly = flowchartData.stretchedRowYOffsets[row] + flowchartData.stretchedRowHeights[row] / 2

		local cellwidth, cellheight = GetSize(cell.id)
		local slotx, sloty
		if cell.shape ~= 0 then
			-- see connector placement in widgetSystem.drawFlowchartNode()
			local xoffadjustment = 0
			local yoffstep = math.floor(cellheight * 25 / 100)
			if cell[slottype][1] and cell[slottype][2] and cell[slottype][3] then
				-- all three slots are in use: place them at 15% / 50% / 85% of node height (counting from top), instead of 25% / 50% / 75%
				yoffstep = math.floor(cellheight * 35 / 100)
			end
			-- push the non-center slots inwards a bit to fit to the node shape, unless the shape is rectangle
			if config.flowchart.borderShapeData[cell.shape].slide ~= "rectangle" and config.flowchart.slotYOffsetFactors[slot] ~= 0 then
				xoffadjustment = math.floor(yoffstep / 3)
			end
			slotx = config.flowchart.slotXOffsetFactors[slottype] * (cellwidth / 2 - xoffadjustment)
			sloty = config.flowchart.slotYOffsetFactors[slot] * yoffstep
		else
			-- junction case
			slotx = cellwidth / 2
			sloty = 0
		end
		return math.floor(cellx + slotx + 0.5), math.floor(celly + sloty + 0.5)
	end
end

function widgetSystem.drawFlowchartEdge(frameElement, flowchartEdgeID, flowchartEdgeElement, edge, flowchartData)
	-- determine source and destination positions on the full flowchart, relative to upper left corner (0,0) without top border
	local x0, y0 = widgetSystem.getFlowchartAbsoluteSlotOffset(flowchartData, edge.source.row, edge.source.col, "output", edge.source.slot)
	local x1, y1 = widgetSystem.getFlowchartAbsoluteSlotOffset(flowchartData, edge.dest.row,   edge.dest.col,   "input",  edge.dest.slot)
	-- determine visible part of the full flowchart
	local xmin = flowchartData.stretchedColXOffsets[flowchartData.firstVisibleCol]
	local ymin = flowchartData.stretchedRowYOffsets[flowchartData.firstVisibleRow]
	local xmax = flowchartData.stretchedColXOffsets[flowchartData.lastVisibleCol] + flowchartData.stretchedColWidths[flowchartData.lastVisibleCol] - 1
	local ymax = flowchartData.stretchedRowYOffsets[flowchartData.lastVisibleRow] + flowchartData.stretchedRowHeights[flowchartData.lastVisibleRow] - 1

	-- clip line against min/max rectangle
	-- NOTE: for clipping, vertical range is extended by top/bottom padding size to touch the top/bottom borders, like the column backgrounds
	x0, y0, x1, y1 = ClipLine(x0, y0, x1, y1, xmin, ymin - config.table.bordersize, xmax, ymax + config.table.bordersize)
	if not x0 then
		-- line is not in view
		return false
	end

	-- draw line
	local xdiff = x1 - x0
	local ydiff = y1 - y0
	local edgeLength = math.sqrt(xdiff * xdiff + ydiff * ydiff)
	if edgeLength < 1 then
		return false
	end
	local line = getElement("line", flowchartEdgeElement)
	-- set Z distance: overlapping lines should have different Z values. Set value depending on angle, so only parallel lines have the same value.
	local zmin = 0.0015  -- connectors are at 0.001
	local zmax = 0.0055  -- background is at 0.006
	local angle = math.atan2(-ydiff, xdiff)
	-- add pi and map range [0,2pi] to [zmin,zmax]
	setAttribute(line, "position.z", zmin + (zmax - zmin) * (angle > math.pi and (angle - math.pi) or (angle + math.pi)) / (2 * math.pi))
	widgetSystem.setElementPosition(line,
		frameElement.offsetx + (flowchartData.contentOffsetx + (flowchartData.maxVisibleWidth - flowchartData.stretchedVisibleWidth) / 2 + (x0 - xmin) + (xdiff / 2)),
		frameElement.offsety - (flowchartData.contentOffsety + flowchartData.maxCaptionHeight + (y0 - ymin) + (ydiff / 2)),
		xdiff % 2 ~= 0, ydiff % 2 ~= 0)
	widgetSystem.setElementScale(line, edgeLength / 100, flowchartData.edgeWidth / 100)
	widgetSystem.setElementRotation(line, angle)
	widgetSystem.setElementColorAlpha(getElement("Material", line), edge.color)

	-- move edge element to correct layer
	widgetSystem.moveAnarkElementFrameLayer(frameElement, flowchartEdgeElement, 1)
	widgetSystem.addToAssociationList(flowchartEdgeID, edge, flowchartEdgeElement, 0, 0)
	goToSlide(flowchartEdgeElement, "active")
	return true
end

function widgetSystem.updateFlowchart(flowchartElement)
	local frameElement = widgetSystem.getFrameElementByFlowchartElement(flowchartElement)
	local flowchartData = flowchartElement.data
	-- Prepare nodes for update
	for row = 1, flowchartData.numRows do
		for col = 1, flowchartData.numColumns do
			local cell = flowchartData.cells[row][col]
			if cell and cell.nodeElement and cell.id then
				-- Remember current expanded state so we don't accidentally restart an expand-arrow animation
				cell.prevexpandedbelow = cell.expandedbelow
				cell.prevexpandedabove = cell.expandedabove
				-- collapse node if expandedexpanded node
				if cell.expandedframeid then
					CallWidgetEventScripts(cell.id, "onFlowchartNodeCollapsed")
				end
			end
		end
	end
	widgetSystem.updateFlowchartScrollBars(flowchartElement)
	widgetSystem.drawFlowchartContent(frameElement, flowchartData.id, flowchartElement)
end

function widgetSystem.updateFlowchartScrollBars(flowchartElement)
	local flowchartData = flowchartElement.data
	if flowchartData.hasVerticalScrollBar then
		local scrolloffsety = flowchartData.rowYOffsets[flowchartData.firstVisibleRow]
		local range = flowchartData.fullContentHeight - flowchartData.maxVisibleHeight + flowchartData.maxCaptionHeight
		local percentage = (scrolloffsety < range and scrolloffsety / range or 1.0)	-- prevent div/0
		widgetSystem.updateVerticalScrollBar(flowchartElement.scrollBars.vertical, percentage)
	end
	if flowchartData.hasHorizontalScrollBar then
		local scrolloffsetx = flowchartData.columns[flowchartData.firstVisibleCol].offsetx
		local range = flowchartData.fullContentWidth - flowchartData.maxVisibleWidth
		local percentage = (scrolloffsetx < range and scrolloffsetx / range or 1.0)	-- prevent div/0
		widgetSystem.updateHorizontalScrollBar(flowchartElement.scrollBars.horizontal, percentage)
	end
end

function widgetSystem.refreshFlowchartNodeData(flowchartNodeID, node)
	local newnodedata = GetFlowchartNodeData(flowchartNodeID)
	if newnodedata then
		node.prevexpandedbelow = node.expandedbelow
		node.prevexpandedabove = node.expandedabove
		-- Update node data based on newnodedata
		node.expandedbelow = newnodedata.expandedbelow
		node.expandedabove = newnodedata.expandedabove
		node.expandedframeid = newnodedata.expandedframeid
		node.caption = newnodedata.caption
		node.statustext = newnodedata.statustext
		node.statusicon = newnodedata.statusicon
		node.statusbgiconid = newnodedata.statusbgiconid
		node.statusbgiconrotating = newnodedata.statusbgiconrotating
		node.statusiconmouseovertext = newnodedata.statusiconmouseovertext
		node.colors = newnodedata.colors
		node.scale = newnodedata.scale
		node.expandable = newnodedata.expandable
	end
end

function widgetSystem.updateFlowchartNode(flowchartNodeID, flowchartNodeElement)
	local cell = flowchartNodeElement.cell
	if cell then
		if cell.shape ~= 0 then
			-- Refresh and redraw flowchart node
			widgetSystem.refreshFlowchartNodeData(flowchartNodeID, cell)
			widgetSystem.drawFlowchartNode(flowchartNodeID, flowchartNodeElement)
		else
			-- Currently there's nothing we can update on a junction
			-- Redraw flowchart junction
			widgetSystem.drawFlowchartJunction(flowchartNodeID, flowchartNodeElement)
		end
	end
end

function widgetSystem.refreshFlowchartEdgeData(flowchartEdgeID, edge)
	local newedgedata = GetFlowchartEdgeData(flowchartEdgeID)
	if newedgedata then
		-- Update edge data based on newedgedata
		edge.color = newedgedata.color
	end
end

function widgetSystem.updateFlowchartEdge(flowchartEdgeID, edge)
	if edge and edge.element then
		widgetSystem.refreshFlowchartEdgeData(flowchartEdgeID, edge)
		-- Update color directly
		local flowchartEdgeElement = edge.element
		local line = getElement("line", flowchartEdgeElement)
		widgetSystem.setElementColorAlpha(getElement("Material", line), edge.color)
	end
end

-- Returns row-index, col-index
function widgetSystem.getFlowchartFirstVisibleCell(flowchartID)
	local flowchartentry = private.associationList[flowchartID]
	if flowchartentry == nil then
		return 0, 0
	end
	local flowchartElement = flowchartentry.element
	return flowchartElement.data.firstVisibleRow, flowchartElement.data.firstVisibleCol
end

-- Returns row-index, col-index
function widgetSystem.getFlowchartSelectedCell(flowchartID)
	local flowchartentry = private.associationList[flowchartID]
	if flowchartentry == nil then
		return 0, 0
	end
	local flowchartElement = flowchartentry.element
	return flowchartElement.data.selectedRow, flowchartElement.data.selectedCol
end

function widgetSystem.scrollFlowchartVertically(flowchartElement, direction, page, step)
	local flowchartData = flowchartElement.data
	if flowchartData.hasVerticalScrollBar then
		local row = flowchartData.firstVisibleRow
		local scrollfunc = page and widgetSystem.getFlowchartNumCellsToScrollPage or widgetSystem.getFlowchartNumCellsToScroll
		local numscrollrows = scrollfunc(flowchartData.rowHeights, flowchartData.maxVisibleHeight - flowchartData.maxCaptionHeight, row, direction, step)
		if numscrollrows ~= 0 then
			flowchartData.firstVisibleRow = math.max(1, math.min(flowchartData.numRows, row + numscrollrows * direction))
			widgetSystem.updateFlowchart(flowchartElement)
		end
	end
end

function widgetSystem.scrollFlowchartHorizontally(flowchartElement, direction, page, step)
	local flowchartData = flowchartElement.data
	if flowchartData.hasHorizontalScrollBar then
		local col = flowchartData.firstVisibleCol
		local scrollfunc = page and widgetSystem.getFlowchartNumCellsToScrollPage or widgetSystem.getFlowchartNumCellsToScroll
		local numscrollcols = scrollfunc(flowchartData.colWidths, flowchartData.maxVisibleWidth, col, direction, step)
		if numscrollcols ~= 0 then
			flowchartData.firstVisibleCol = math.max(1, math.min(flowchartData.numColumns, col + numscrollcols * direction))
			widgetSystem.updateFlowchart(flowchartElement)
		end
	end
end

-- takes an table entry in private.element and returns the corresponding widget ID
function widgetSystem.getWidgetIDByElementEntry(elementEntry)
	for widgetID, entry in pairs(private.associationList) do
		if entry.element == elementEntry then
			return widgetID
		end
	end

	-- otherwise return nil
end

-- takes an table entry in private.element and returns the corresponding widget ID
function widgetSystem.getWidgetIDByAnarkElementEntry(anarkElementEntry)
	for widgetID, entry in pairs(private.associationList) do
		if entry.rootAnarkElement == anarkElementEntry then
			return widgetID
		end
	end

	-- otherwise return nil
end

function widgetSystem.getRootAnarkElement(anarkElement)
	local originalAnarkElement = anarkElement
	local result = nil
	while anarkElement ~= private.widgetsystem and anarkElement ~= private.master.flowchart_group do
		result = anarkElement
		anarkElement = getElement("parent", anarkElement)
	end

	if result == private.master.graph then
		local graphElement = widgetSystem.getTableCellElementByAnarkElement("graph", originalAnarkElement)
		if graphElement then
			return graphElement.element.mainElement
		end
	end

	return result
end

function widgetSystem.getCurrentInterval()
	local curTime = getElapsedTime()
	if private.nextStepIncreaseTime == nil then
		-- set for the first time
		private.nextStepIncreaseTime = curTime + config.slider.interval.initialStepDelay
	else
		if private.curScrollingStep >= config.slider.interval.steps[#config.slider.interval.steps] then
			return private.curScrollingStep -- no further step increases
		end
		if private.nextStepIncreaseTime < curTime then
			private.nextStepIncreaseTime = curTime + math.min(config.slider.interval.stepDelayIncrease * private.numStepIncreases + config.slider.interval.initialStepDelay, config.slider.interval.maxStepDelay)
			for _, value in ipairs(config.slider.interval.steps) do
				if value > private.curScrollingStep then
					private.curScrollingStep = value
					break
				end
			end
			private.numStepIncreases = private.numStepIncreases + 1
		end
	end

	return private.curScrollingStep
end

function widgetSystem.getFontHeight(fontname, fontsize)
	-- use memoizing since font/size combinations are quite limited (in most cases we'd only have 1-2 fontname/fontsize combinations within one view
	local fontheightarray = private.fontHeight[fontname]
	if fontheightarray == nil then
		fontheightarray = {}
		private.fontHeight[fontname] = fontheightarray
	end

	local fontheight = fontheightarray[fontsize]
	if fontheight == nil then
		fontheight = GetFontHeight(fontname, fontsize)
		fontheightarray[fontsize] = fontheight
	end

	return fontheight
end

function widgetSystem.getElement(type)
	local elements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem[type] or private.element[type]
	if elements then
		local element = widgetSystem.getElementInternal(type, elements)
		if element then
			-- check if this element is containing the rootAnarkElement the mouse is currently over, if so try to use another element
			if widgetSystem.checkElementByRootAnarkElement(type, element, private.currentMouseAnarkElement) then
				-- if we have another element that we can use instead, move the element to limbo 
				local otherelement = widgetSystem.getElementInternal(type, elements)
				if otherelement then
					private.currentMouseWidgetElementLimbo = { type = type, element = element }
					return otherelement
				end
			end
			return element
		end
	end
end

function widgetSystem.getElementInternal(type, elements)
	if #elements > 0 then
		-- found an unassigned element
		return table.remove(elements)
	elseif not private.miniWidgetSystemUsed and private.elementInit[type] then
		-- not all elements have been initialized yet, we can run the initializer now to retrieve a new element
		widgetSystem.runElementInitializer(type, private.elementInit[type], 1)
		if #elements > 0 then
			return table.remove(elements)
		end
	end
end

function widgetSystem.checkElementByRootAnarkElement(type, widgetElement, rootAnarkElement)
	if (type == "icon") or (type == "button") or (type == "checkbox") or (type == "editbox") or (type == "shieldhullbar") or (type == "flowchartEdge") then
		if widgetElement == rootAnarkElement then
			return true
		end
	elseif (type == "boxtext") or (type == "dropdown") or (type == "graph") then
		if widgetElement.mainElement == rootAnarkElement then
			return true
		end
	elseif (type == "slidercell") or (type == "statusbar") then
		if widgetElement.main == rootAnarkElement then
			return true
		end
	elseif type == "flowchartNode" then
		if widgetElement.main == rootAnarkElement then
			return true
		end
	elseif type == "tableRows" then
		for colIndex = 1, config.tableRows.maxCols do 
			if widgetElement[colIndex].element == rootAnarkElement then
				return true
			end
		end
	elseif type == "table" then
		return false
	elseif type == "flowchart" then
		return false
	end

	return false
end

function widgetSystem.returnElement(type, element)
	local elements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem[type] or private.element[type]
	if elements then
		table.insert(elements, element)
	end
end

function widgetSystem.getShapeElement(type)
	if #private.element.shapes[type] == 0 then
		return -- no more unassigned elements
	end
	
	return table.unpack(table.remove(private.element.shapes[type]))
end

function widgetSystem.getNumAvailableTableRowElements()
	if private.miniWidgetSystemUsed then
		return #private.element.miniWidgetSystem.tableRows
	end
	local numrows = #private.element.tableRows
	if private.elementInit.tableRows then
		-- add number of tableRows that are not initialized yet
		numrows = numrows + (private.elementInit.tableRows.totalCount - private.elementInit.tableRows.numInitialized)
	end
	return numrows
end

function widgetSystem.getTableCellElementByAnarkElement(type, anarkElement)
	-- check all tables
	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		if frameElement then
			for _, tableElement in ipairs(frameElement.tables) do
				for _, rowentry in ipairs(tableElement.cell) do
					for _, columnentry in ipairs(rowentry) do
						if columnentry[type] then
							if type == "dropdown" then
								if columnentry[type].element.mainElement == anarkElement then
									return columnentry[type], { "" }, frameElement
								else
									for _, optionElement in ipairs(columnentry.dropdown.element.optionElements) do
										if optionElement == anarkElement then
											return columnentry.dropdown, widgetSystem.getDropDownOptionByOptionAnarkElement(columnentry.dropdown, optionElement), frameElement
										end
									end
								end
							elseif type == "graph" then
								if columnentry.graph.element.mainElement == anarkElement then
									return columnentry.graph, nil, frameElement
								else
									for _, dataPointElement in ipairs(columnentry.graph.element.dataPointElements) do
										if (getElement("marker1", dataPointElement) == anarkElement) or (getElement("marker2", dataPointElement) == anarkElement) then
											return columnentry.graph, widgetSystem.getGraphDataPointByDataPointAnarkElement(columnentry.graph, dataPointElement), frameElement
										end
									end
									for _, iconElement in ipairs(columnentry.graph.element.iconElements) do
										if (iconElement == anarkElement) or (getElement("icon", iconElement) == anarkElement) or (getElement("background", iconElement) == anarkElement) then
											return columnentry.graph, widgetSystem.getGraphIconByIconAnarkElement(columnentry.graph, iconElement), frameElement
										end
									end
								end
							elseif type == "slidercell" then
								if columnentry[type].element.main == anarkElement then
									return columnentry[type], frameElement
								end
							else
								if columnentry[type].element == anarkElement then
									return columnentry[type], frameElement
								end
							end
						end
					end
				end
			end
		end
	end
	
	-- otherwise return nil
end

function widgetSystem.getFrameElementByAnarkStandardButtonElement(anarkElement)
	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		if frameElement then
			for _, element in ipairs(config.frame.standardButtonOrder) do
				if frameElement[element .. "Element"] == anarkElement then
					return frameElement
				end
			end
		end
	end
end

function widgetSystem.getFrameElementByTableElement(tableElement)
	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		if frameElement then
			for _, table in ipairs(frameElement.tables) do
				if table == tableElement then
					return frameElement
				end
			end
		end
	end
end

function widgetSystem.getFrameElementByFlowchartElement(flowchartElement)
	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		if frameElement then
			for _, flowchart in ipairs(frameElement.flowcharts) do
				if flowchart == flowchartElement then
					return frameElement
				end
			end
		end
	end
end

function widgetSystem.getFrameElementByFlowchartNodeElement(flowchartNodeElement)
	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		if frameElement then
			for _, flowchartElement in ipairs(frameElement.flowcharts) do
				local flowchartData = flowchartElement.data
				for col = 1, flowchartData.numColumns do
					for row = 1, flowchartData.numRows do
						local cell = flowchartData.cells[row][col]
						if cell and cell.nodeElement then
							if cell.nodeElement == flowchartNodeElement then
								return frameElement
							end
						end
					end
				end
			end
		end
	end
end

function widgetSystem.getDropDownOptionByOptionAnarkElement(dropdownElement, optionElement)
	for i, option in ipairs(dropdownElement.options) do
		if option.element == optionElement then
			return { option.mouseovertext, option.text ~= option.truncatedtext and option.text or nil }
		end
	end
end

function widgetSystem.getGraphDataPointByDataPointAnarkElement(graphElement, dataPointElement)
	for i, dataRecord in ipairs(graphElement.datarecords) do
		for j, data in ipairs(dataRecord.data) do
			if data.element == dataPointElement then
				return { dataRecord.mouseovertext, data, i, j }
			end
		end
	end
end

function widgetSystem.getGraphIconByIconAnarkElement(graphElement, iconElement)
	for i, icon in ipairs(graphElement.icons) do
		if icon.element == iconElement then
			return icon
		end
	end
end

function widgetSystem.getDropDownOptionIndexByAnarkElement(dropdownElement, anarkElement)
	for i, optionElement in ipairs(dropdownElement.element.optionElements) do
		if optionElement == anarkElement then
			return i + dropdownElement.topOption - 1
		end
	end
end

-- return next column which needs to be checked for selectability
function widgetSystem.getNextColumn(startCol, minLimit, maxLimit, step, dir)
	local newCol = startCol + step * dir
	if newCol < minLimit or newCol > maxLimit then
		newCol = nil -- next column is out of limits
	end

	return newCol
end

function widgetSystem.getRenderTargetElementByAnarkElement(anarkElement)
	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		if frameElement then
			for _, renderTargetsElement in ipairs(frameElement.rendertargets) do
				if anarkElement == renderTargetsElement.element then
					return renderTargetsElement, frameElement
				end
			end
		end
	end

	-- otherwise return nil
end

-- x, y = widgetSystem.getRenderTargetMousePosition(renderTargetID)
-- returns nil, if there's an error or the cursor is not over the rendertarget
-- returns coordinates [-1,1] --- lower left corner being -1/-1
function widgetSystem.getRenderTargetMousePosition(renderTargetID)
	local renderTargetElement = private.associationList[renderTargetID]
	if renderTargetElement == nil then
		return nil
	end
	local posX, posY, posZ = GetRelativeMousePosition(renderTargetElement.element.modelElement, false)
	return posX * 2 - 1, 1 - posY * 2
end

-- textureFilename = widgetSystem.getRenderTargetTexture(renderTargetID)
function widgetSystem.getRenderTargetTexture(renderTargetID)
	local renderTargetElement = private.associationList[renderTargetID]
	if renderTargetElement == nil then
		return nil, 1, "invalid rendertarget element"
	end

	return renderTargetElement.element.textureString
end

-- sliderPosY = widgetSystem.getScrollBarSliderPosition(anarkScrollBarElement)
-- anarkScrollBarElement -> Anark element: widgetsystem.table_scrollbar
function widgetSystem.getScrollBarSliderPosition(anarkScrollBarElement)
	local scrollbarPosY = getAttribute(anarkScrollBarElement, "position.y")
	local sliderPosY    = getAttribute(getElement("slider", anarkScrollBarElement), "position.y")

	-- the slider position is actually the slider position PLUS the scrollbar position (since the elements are nested)
	return sliderPosY + scrollbarPosY
end

-- sliderPosX = widgetSystem.getHorizontalScrollBarSliderPosition(anarkScrollBarElement)
function widgetSystem.getHorizontalScrollBarSliderPosition(anarkScrollBarElement)
	local scrollbarPosX = getAttribute(anarkScrollBarElement, "position.x")
	local sliderPosX    = getAttribute(getElement("slider", anarkScrollBarElement), "position.x")

	-- the slider position is actually the slider position PLUS the scrollbar position (since the elements are nested)
	return sliderPosX + scrollbarPosX
end

-- returns widgetID of the element in the cell if col/row is selectable, otherwise nil
function widgetSystem.getSelectableCellElement(tableID, row, col, dir, limit)
	if not IsValidWidgetElement(tableID) then
		-- view might have already been changed
		return
	end
	while GetTableColumnSpan(tableID, row, col) == 0 do
		col = col + (dir or -1)
		if ((dir == nil) or (dir == -1)) and (col == 0) then
			-- sanity check, columns 1 .. col should never all be spanned
			return nil, 1
		elseif ((dir == 1) and (col == limit + 1)) then
			-- valid case, we want to move right, but no more unspanned cols
			return nil, limit
		end
	end
	local cellElementID = GetCellContent(tableID, row, col)
	if IsSelectable(cellElementID) then
		return cellElementID, col -- interactive (and selectable) cellelement
	end

	return nil, col
end

function widgetSystem.getShiftStartEndRow(tableID)
	local tableentry = private.associationList[tableID]
	if tableentry == nil then
		return nil, 1, "invalid table element"
	end

	if not widgetSystem.hasNonFixedRows(tableentry.element) then
		return nil, 2, "table does not contain normal (non-fixed) rows"
	end

	return {tableentry.element.shiftStart, tableentry.element.shiftEnd}
end

function widgetSystem.getTableElementByAnarkTableCellElement(type, anarkElement)
	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		if frameElement then
			for _, tableElement in ipairs(frameElement.tables) do
				local displayedRows = tableElement.displayedRows or 0
				for row = 1, displayedRows do
					for col = 1, config.tableRows.maxCols do
						local columnentry = tableElement.cell[row][col]
						if type == "cell" then
							if columnentry.element == anarkElement then
								return tableElement, widgetSystem.getWidgetIDByElementEntry(tableElement), tableElement.cell[row].realRow, col -- found cell, return information
							end
						elseif columnentry[type] then
							if (type == "dropdown") or (type == "boxtext") then
								if columnentry[type].element.mainElement == anarkElement then
									return tableElement, widgetSystem.getWidgetIDByElementEntry(tableElement), tableElement.cell[row].realRow, col -- found cell, return information
								end
							elseif type == "slidercell" then
								if columnentry[type].element.main == anarkElement then
									return tableElement, widgetSystem.getWidgetIDByElementEntry(tableElement), tableElement.cell[row].realRow, col -- found cell, return information
								end
							else
								if columnentry[type].element == anarkElement then
									return tableElement, widgetSystem.getWidgetIDByElementEntry(tableElement), tableElement.cell[row].realRow, col -- found cell, return information
								end
							end
						end
					end
				end
			end
		end
	end
end

function widgetSystem.getTableElementByScrollBar(scrollBarElement)
	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		if frameElement then
			for _, tableElement in ipairs(frameElement.tables) do
				if tableElement.scrollBar.element == scrollBarElement then
					return tableElement, frameElement
				end
			end
		end
	end

	-- otherwise return nil
end

function widgetSystem.getTableElementByMousePick(mousePickElement)
	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		if frameElement then
			for _, tableElement in ipairs(frameElement.tables) do
				if tableElement.mousePick.element == mousePickElement then
					return tableElement
				end
			end
		end
	end

	-- otherwise return nil
end

function widgetSystem.getTopRow(tableID)
	local tableentry = private.associationList[tableID]
	if tableentry == nil then
		return nil, 1, "invalid table element"
	end

	if not widgetSystem.hasNonFixedRows(tableentry.element) then
		return nil, 2, "table does not contain normal (non-fixed) rows"
	end

	return tableentry.element.topRow
end

-- returns the usable table width in px
function widgetSystem.getUsableTableWidth(width, offsetx, numColumns, hasScrollBar)
	numColumns = numColumns or 1
	-- #StefanMed - hack... - actually we wouldn't have to pass along the width here but could get it from the actual frame width - however, this is only created once the frame is assigned --- hence needs refactoring
	local usablewidth = width - offsetx - (numColumns - 1)*config.table.bordersize
	if hasScrollBar then
		usablewidth = usablewidth - config.texturesizes.table.scrollBar.width - config.table.bordersize
	end
	return usablewidth
end

-- #StefanMed - replace with Lua UTF8 library
function widgetSystem.getUTF8CharacterPrevIndex(text, pos)
	if pos <= 0 then
		-- invalid call - given index must be positive (>= 1)
		DebugError("Widget system error. Invalid call to getUTF8CharacterPrevIndex(). Index "..tostring(pos).." is negative.")
		return -1
	end

	local byteLength = #text
	if pos > byteLength then
		-- invalid call - requesting an index past the actual string
		DebugError("Widget system error. Cannot retrieve UTF8 previous index. Index "..tostring(pos).." exceeds bytelength of given text: '"..tostring(text).."' - max valid index is: "..tostring(byteLength)..".")
		return -1
	end

	while pos > 1 do
		if bit.band(string.byte(text, pos), 0xC0) ~= 0x80 then
			-- found control character
			return pos - 1
		end
		pos = pos - 1
	end

	-- no control character found, hence there is no previous character
	return 0
end

function widgetSystem.hasNonFixedRows(tableElement)
	return tableElement.topRow ~= nil
end

function widgetSystem.hideAllElements()
	-- clear association list first, so that successive call to widgetSystem.hideTable() does not unnecessarily remove one entry after another
	private.associationList = {}
	private.interactiveElement = nil

	if private.mouseOverText then
		widgetSystem.hideMouseOverText(private.mouseOverText.widgetID, true)
	end
	private.mouseOverOverrideText = nil

	widgetSystem.hideHelpOverlay(true)

	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		if frameElement and frameElement.frame then
			widgetSystem.hideFrame(frameElement)
		end
	end
end

function widgetSystem.hideButton(buttonElement, iconActive, icon2Active, textActive, text2Active, hotkeyIconActive)
	goToSlide(buttonElement.element, "inactive")
	if iconActive then
		local iconElement = getElement("Icon", buttonElement.element)
		widgetSystem.setElementPosition(iconElement, 0, 0)
		goToSlide(iconElement, "inactive")
	end
	if icon2Active then
		local iconElement = getElement("Icon2", buttonElement.element)
		widgetSystem.setElementPosition(iconElement, 0, 0)
		goToSlide(iconElement, "inactive")
	end
	if textActive then
		setAttribute(getElement("Text", buttonElement.element), "textstring", "")
	end
	if text2Active then
		setAttribute(getElement("Text2", buttonElement.element), "textstring", "")
	end
	if hotkeyIconActive then
		goToSlide(getElement("Hotkey", buttonElement.element), "inactive")
	end
	table.insert(private.element.button, buttonElement.element)
	widgetSystem.removeFromAssociationList(buttonElement)
end

function widgetSystem.hideCheckBox(checkboxElement)
	goToSlide(checkboxElement.element, "inactive")
	table.insert(private.element.checkbox, checkboxElement.element)
	widgetSystem.removeFromAssociationList(checkboxElement)
end

function widgetSystem.hideBoxText(boxtextElement)
	goToSlide(boxtextElement.element.mainElement, "inactive")
	boxtextElement.leftHidden = nil
	boxtextElement.rightHidden = nil
	table.insert(private.element.boxtext, boxtextElement.element)
	widgetSystem.removeFromAssociationList(boxtextElement)
end

function widgetSystem.hideDropDown(dropdownElement, iconActive, hotykeyIconActive)
	if (private.activeDropDown ~= nil) and (private.activeDropDown.element == dropdownElement) then
		widgetSystem.hideDropDownOptions(private.activeDropDown.widgetID, dropdownElement)
		private.activeDropDown = nil
	else
		widgetSystem.hideDropDownOptions(nil, dropdownElement)
	end
	if dropdownElement.mouseOverOverrideSet then
		private.mouseOverOverrideText = nil
		dropdownElement.mouseOverOverrideSet = nil
	end

	goToSlide(dropdownElement.element.mainElement, "inactive")
	local arrowElement = getElement("Arrow", dropdownElement.element.mainElement)
	goToSlide(arrowElement, "inactive")
	for i, optionElement in ipairs(dropdownElement.element.optionElements) do
		goToSlide(optionElement, "inactive")
	end
	if iconActive then
		local iconElement = getElement("Icon", dropdownElement.element.mainElement)
		widgetSystem.setElementPosition(iconElement, 0, 0)
		goToSlide(iconElement, "inactive")
	end
	setAttribute(getElement("Text", dropdownElement.element.mainElement), "textstring", "")
	if hotkeyIconActive then
		goToSlide(getElement("Hotkey", dropdownElement.element.mainElement), "inactive")
	end
	table.insert(private.element.dropdown, dropdownElement.element)
	widgetSystem.removeFromAssociationList(dropdownElement)
end

function widgetSystem.hideEditBox(editboxElement, hotkeyIconActive)
	if editboxElement.active then
		widgetSystem.deactivateEditBox(nil, editboxElement, false)
	end
	goToSlide(editboxElement.element, "inactive")
	setAttribute(getElement("Text", editboxElement.element), "textstring", "")
	setAttribute(getElement("highlight.Material689", editboxElement.element), "opacity", 0)
	setAttribute(getElement("highlight.Material689", editboxElement.element), "glowfactor", 0)
	if hotkeyIconActive then
		goToSlide(getElement("Hotkey", editboxElement.element), "inactive")
	end
	table.insert(private.element.editbox, editboxElement.element)
	widgetSystem.removeFromAssociationList(editboxElement)
end

function widgetSystem.hideFlowchart(frameElement, flowchartElement)
	goToSlide(flowchartElement.mousePick.element, "inactive")
	goToSlide(flowchartElement.headerBackground, "inactive")
	goToSlide(flowchartElement.footerBackground, "inactive")

	widgetSystem.hideVerticalScrollBar(flowchartElement.scrollBars.vertical)
	widgetSystem.hideHorizontalScrollBar(flowchartElement.scrollBars.horizontal)
	widgetSystem.stopFlowchartScrollBarDrag(flowchartElement, flowchartElement.scrollBars.vertical)
	widgetSystem.stopFlowchartScrollBarDrag(flowchartElement, flowchartElement.scrollBars.horizontal)

	widgetSystem.hideFlowchartContent(frameElement, flowchartElement)

	-- reset members
	flowchartElement.data = nil

	local flowchartElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.flowchart or private.element.flowchart
	table.insert(flowchartElements, flowchartElement)
	widgetSystem.removeFromAssociationList(flowchartElement)
end

function widgetSystem.hideFlowchartContent(frameElement, flowchartElement)
	local flowchartData = flowchartElement.data
	for col = 1, flowchartData.numColumns do
		-- hide column background elements
		goToSlide(flowchartElement.columnBackgrounds[col], "inactive")
		-- hide node elements
		for row = 1, flowchartData.numRows do
			local cell = flowchartData.cells[row][col]
			if cell and cell.nodeElement then
				widgetSystem.hideFlowchartNode(frameElement, cell.nodeElement)
				cell.nodeElement.cell = nil
				cell.nodeElement = nil
			end
		end
	end
	-- hide edge elements
	for edgeidx, edge in ipairs(flowchartData.edges) do
		if edge.element then
			widgetSystem.hideFlowchartEdge(frameElement, edge, edge.element)
			edge.element = nil
		end
	end
end

function widgetSystem.hideFlowchartNode(frameElement, flowchartNodeElement)
	goToSlide(flowchartNodeElement.main, "inactive")
	goToSlide(flowchartNodeElement.leftBorder, "inactive")
	goToSlide(flowchartNodeElement.rightBorder, "inactive")
	goToSlide(flowchartNodeElement.expand, "inactive")
	goToSlide(flowchartNodeElement.status, "inactive")
	goToSlide(flowchartNodeElement.connectors, "inactive")

	flowchartNodeElement.cell.statusslide = "inactive"

	for _, bardata in ipairs(flowchartNodeElement.barData) do
		bardata.assignedSliderIndex = nil
	end
	for _, statedata in ipairs(flowchartNodeElement.sliderStates) do
		statedata.barIndex = nil
		if statedata.mouseDown then
			statedata.mouseDown = false
			widgetSystem.setMouseCursorOverrideInternalDrag()
			private.flowchartNodeSliderDrag = nil
		end
		if statedata.mouseOver then
			statedata.mouseOver = false
			widgetSystem.setMouseCursorOverrideInternal()
			widgetSystem.setMouseOverOverride(flowchartNodeElement.cell.id, nil, true)
		end
	end

	if flowchartNodeElement.expandedFrameLayer and flowchartNodeElement.expandedFrameLayer ~= flowchartNodeElement.currentFrameLayer then
		widgetSystem.moveFlowchartNodeBetweenFrameLayers(flowchartNodeElement, flowchartNodeElement.expandedFrameLayer, flowchartNodeElement.currentFrameLayer)
	end
	flowchartNodeElement.expandedFrameLayer = nil
	flowchartNodeElement.currentFrameLayer = nil

	widgetSystem.moveAnarkElementFrameLayer(frameElement, flowchartNodeElement.main, -1)
	widgetSystem.removeFromAssociationList(flowchartNodeElement)
	widgetSystem.returnElement("flowchartNode", flowchartNodeElement)
end

function widgetSystem.hideFlowchartEdge(frameElement, edge, flowchartEdgeElement)
	goToSlide(flowchartEdgeElement, "inactive")

	widgetSystem.moveAnarkElementFrameLayer(frameElement, flowchartEdgeElement, -1)
	widgetSystem.removeFromAssociationList(edge)
	widgetSystem.returnElement("flowchartEdge", flowchartEdgeElement)
end


function widgetSystem.hideFrame(frameElement, keepMinimizedState)
	for _, tableElement in ipairs(frameElement.tables) do
		widgetSystem.moveTableElementFrameLayer(frameElement, tableElement, -1)
		widgetSystem.hideTable(frameElement, tableElement)
	end

	for _, renderTargetElement in ipairs(frameElement.rendertargets) do
		widgetSystem.moveAnarkElementFrameLayer(frameElement, renderTargetElement.element, -1)
		widgetSystem.hideRenderTarget(frameElement, renderTargetElement)
	end

	for _, flowchartElement in ipairs(frameElement.flowcharts) do
		widgetSystem.moveFlowchartElementFrameLayer(frameElement, flowchartElement, -1)
		widgetSystem.hideFlowchart(frameElement, flowchartElement)
	end

	if not keepMinimizedState then
		widgetSystem.hideStandardButtons(frameElement)
	end
	widgetSystem.hideMinimizedMenuName(frameElement)

	widgetSystem.clearHelpOverlays(frameElement)

	-- hide background textures
	for _, type in ipairs(config.frame.backgroundElements) do
		frameElement[type .. "Data"] = {}
		goToSlide(frameElement[type], "inactive")
	end

	-- hide brackets
	goToSlide(frameElement.bracketsElement, "inactive")

	frameElement.tables          = {}
	frameElement.sliders         = {}
	frameElement.rendertargets   = {}
	frameElement.flowcharts      = {}
	frameElement.offsetx         = nil
	frameElement.offsety         = nil
	frameElement.height          = nil
	frameElement.width           = nil
	
	if not keepMinimizedState then
		frameElement.frame       = nil
		widgetSystem.removeFromAssociationList(frameElement)
	end
end

function widgetSystem.hideGraph(graphElement)
	goToSlide(graphElement.element.mainElement, "inactive")
	goToSlide(getElement("axis", graphElement.element.mainElement), "inactive")
	goToSlide(getElement("axis2", graphElement.element.mainElement), "inactive")
	goToSlide(getElement("selection", graphElement.element.mainElement), "inactive")
	for _, tickElement in ipairs(graphElement.element.tickElements) do
		goToSlide(tickElement, "inactive")
	end
	for _, dataPointElement in ipairs(graphElement.element.dataPointElements) do
		goToSlide(dataPointElement, "inactive")
	end
	for _, iconElement in ipairs(graphElement.element.iconElements) do
		goToSlide(iconElement, "inactive")
	end
	table.insert(private.element.graph, graphElement.element)
	widgetSystem.removeFromAssociationList(graphElement)
end

function widgetSystem.hideIcon(iconelement)
	goToSlide(iconelement, "inactive")
	table.insert(private.element.icon, iconelement)
	widgetSystem.removeFromAssociationList(iconelement)
end

function widgetSystem.hideRenderTarget(frameElement, renderTargetElement)
	goToSlide(renderTargetElement.element, "inactive")
	private.element.renderTarget = renderTargetElement
	widgetSystem.removeFromAssociationList(renderTargetElement)
end

function widgetSystem.hideSliderCell(slidercellElement)
	if slidercellElement.inputActive then
		if not tonumber(slidercellElement.cur) then
			widgetSystem.setSliderCellCurValue(slidercellElement, math.max(0, slidercellElement.minSelect), false, false)
		end
		widgetSystem.deactivateSliderCellInput(slidercellElement)
	end

	widgetSystem.stopSliderCellScroll(slidercellElement)

	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)
	if slidercellID then
		widgetSystem.setMouseOverOverride(slidercellID)
		if private.slidercellInputActive == slidercellID then
			C.DeactivateSliderCellInput()
			private.slidercellInputActive = nil
		end
	end
	if slidercellElement.element.main == private.currentMouseAnarkElement then
		widgetSystem.setMouseCursorOverrideInternal()
	end
	if private.slidercellDrag and ((private.associationList[private.slidercellDrag.widgetID] == nil) or (private.associationList[private.slidercellDrag.widgetID].element == slidercellElement)) then
		widgetSystem.setMouseCursorOverrideInternalDrag()
		private.slidercellDrag = nil
	end

	slidercellElement.element.sliderArrowState.left.curSlide = "inactive"
	slidercellElement.element.sliderArrowState.right.curSlide = "inactive"
	slidercellElement.element.sliderArrowState.skip_left.curSlide = "inactive"
	slidercellElement.element.sliderArrowState.skip_right.curSlide = "inactive"
	goToSlide(slidercellElement.element.arrow_left, "inactive")
	goToSlide(slidercellElement.element.arrow_right, "inactive")
	goToSlide(slidercellElement.element.arrow_skip_left, "inactive")
	goToSlide(slidercellElement.element.arrow_skip_right, "inactive")
	goToSlide(slidercellElement.element.main, "inactive")

	table.insert(private.element.slidercell, slidercellElement.element)
	widgetSystem.removeFromAssociationList(slidercellElement)
end

function widgetSystem.hideStandardButtons(frameElement)
	for _, element in ipairs(config.frame.standardButtonOrder) do
		frameElement[element .. "ButtonShown"] = false
		widgetSystem.updateStandardButtonState(frameElement, element)
	end
end

function widgetSystem.hideTable(frameElement, tableElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)
	CallWidgetEventScripts(tableID, "onTableMouseOut")

	-- hide header
	widgetSystem.removeFromAssociationList(tableElement.headerText)
	goToSlide(tableElement.header, "inactive")

	setAttribute(getElement("table_mousepick.Material681", tableElement.mousePick.element), "opacity", 0)
	goToSlide(tableElement.mousePick.element, "inactive")

	widgetSystem.removeHighlightBorderTableRow(tableElement)

	widgetSystem.hideVerticalScrollBar(tableElement.scrollBar)
	if private.scrollBarDrag == tableElement then
		private.scrollBarDrag = nil
	end

	widgetSystem.hideTableCells(frameElement, tableElement)

	-- reset members
	tableElement.borderEnabled           = nil
	tableElement.bottomRow               = nil
	tableElement.cellposx                = nil
	tableElement.displayedRows           = nil
	tableElement.fixedRowCellposx        = nil
	tableElement.columnWidths            = nil
	tableElement.fixedRowColumnWidths    = nil
	tableElement.curRow                  = nil
	tableElement.highlightedRows         = nil
	tableElement.height                  = nil
	tableElement.nonFixedSectionHeight   = nil
	tableElement.numCols                 = nil
	tableElement.numFixedRows            = nil
	tableElement.numRows                 = nil
	tableElement.offsety                 = nil
	tableElement.topBottomRow            = nil
	tableElement.topRow                  = nil
	tableElement.unselectableRows        = nil
	tableElement.interactiveRegion       = nil
	tableElement.normalSelectedRow       = nil
	tableElement.firstSelectableFixedRow = nil
	tableElement.interactiveChild        = nil
	-- icons are cleared in widgetSystem.hideTableCells()
	-- buttons are cleared in widgetSystem.hideTableCells()

	local tableElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.table or private.element.table
	table.insert(tableElements, tableElement)
	widgetSystem.removeFromAssociationList(tableElement)
end

function widgetSystem.hideTableCells(frameElement, tableElement)
	local displayedRows = tableElement.displayedRows or 0
	for row = 1, displayedRows do
		local rowarray = tableElement.cell[row]
		rowarray.realRow = nil

		-- hide middle column elements
		for col = 1, config.tableRows.maxCols do
			local cellelement = rowarray[col].element
			widgetSystem.moveAnarkElementFrameLayer(frameElement, cellelement, -1)

			textelement = getElement("Text", cellelement)
			if rowarray[col].active then
				goToSlide(cellelement, "inactive")
				rowarray[col].active = false
			end
			widgetSystem.removeFromAssociationList(textelement)

			-- hide icon
			if rowarray[col].icon ~= nil then
				widgetSystem.moveAnarkElementFrameLayer(frameElement, rowarray[col].icon, -1)
				widgetSystem.hideIcon(rowarray[col].icon)
				rowarray[col].icon = nil
			end

			-- hide boxtext
			if rowarray[col].boxtext ~= nil then
				local boxtextElement = rowarray[col].boxtext
				widgetSystem.moveAnarkElementFrameLayer(frameElement, boxtextElement.element.mainElement, -1)
				widgetSystem.hideBoxText(boxtextElement)
				rowarray[col].boxtext = nil
			end

			-- hide button
			if rowarray[col].button ~= nil then
				local buttonElement = rowarray[col].button
				widgetSystem.moveAnarkElementFrameLayer(frameElement, buttonElement.element, -1)
				widgetSystem.hideButton(buttonElement, rowarray[col].button.iconActive, rowarray[col].button.icon2Active, rowarray[col].button.textActive, rowarray[col].button.text2Active, rowarray[col].button.hotkeyIconActive)
				rowarray[col].button = nil
			end

			-- hide checkbox
			if rowarray[col].checkbox ~= nil then
				local checkboxElement = rowarray[col].checkbox
				widgetSystem.moveAnarkElementFrameLayer(frameElement, checkboxElement.element, -1)
				widgetSystem.hideCheckBox(checkboxElement)
				rowarray[col].checkbox = nil
			end

			-- hide dropdown
			if rowarray[col].dropdown ~= nil then
				local dropdownElement = rowarray[col].dropdown
				widgetSystem.moveDropDownElementFrameLayer(frameElement, dropdownElement.element, -1)
				widgetSystem.hideDropDown(dropdownElement, dropdownElement.iconActive, dropdownElement.hotykeyIconActive)
				rowarray[col].dropdown = nil
			end

			-- hide editbox
			if rowarray[col].editbox ~= nil then
				local editboxElement = rowarray[col].editbox
				widgetSystem.moveAnarkElementFrameLayer(frameElement, editboxElement.element, -1)
				widgetSystem.hideEditBox(editboxElement, rowarray[col].editbox.hotkeyIconActive)
				rowarray[col].editbox = nil
			end

			-- hide graph
			if rowarray[col].graph ~= nil then
				local graphElement = rowarray[col].graph
				widgetSystem.moveGraphElementFrameLayer(frameElement, graphElement.element, -1)
				widgetSystem.hideGraph(graphElement)
				rowarray[col].graph = nil
			end

			-- hide slidercell
			if rowarray[col].slidercell ~= nil then
				local slidercellElement = rowarray[col].slidercell
				widgetSystem.moveAnarkElementFrameLayer(frameElement, slidercellElement.element.main, -1)
				widgetSystem.hideSliderCell(slidercellElement)
				rowarray[col].slidercell = nil
			end

			-- hide shield/hull bars
			local shieldHullBarElement = rowarray[col].shieldhullbar
			if shieldHullBarElement ~= nil then
				widgetSystem.moveAnarkElementFrameLayer(frameElement, shieldHullBarElement, -1)
				widgetSystem.hideShieldHullBar(shieldHullBarElement)
				rowarray[col].shieldhullbar = nil
			end

			-- hide shield/hull bars
			local statusBarElement = rowarray[col].statusbar
			if statusBarElement ~= nil then
				widgetSystem.moveAnarkElementFrameLayer(frameElement, statusBarElement.element, -1)
				widgetSystem.hideStatusBar(statusBarElement)
				rowarray[col].statusbar = nil
			end
		end

		local tableRowElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.tableRows or private.element.tableRows
		table.insert(tableRowElements, rowarray)
		tableElement.cell[row] = nil
	end
end

function widgetSystem.hideShieldHullBar(shieldHullBarElement)
	goToSlide(shieldHullBarElement, "inactive")
	table.insert(private.element.shieldhullbar, shieldHullBarElement)
	widgetSystem.removeFromAssociationList(shieldHullBarElement)
end

function widgetSystem.hideStatusBar(statusBarElement)
	goToSlide(statusBarElement.element, "inactive")
	table.insert(private.element.statusbar, statusBarElement)
	widgetSystem.removeFromAssociationList(statusBarElement)
end

function widgetSystem.hideVerticalScrollBar(scrollbar)
	goToSlide(scrollbar.element, "inactive")
	goToSlide(scrollbar.sliderElement, "inactive")
	scrollbar.height           = nil
	scrollbar.sliderHeight     = nil
	scrollbar.active           = nil
	scrollbar.dragOffset       = nil
	scrollbar.previousMousePos = nil
	scrollbar.valuePerPixel    = nil
end

function widgetSystem.hideHorizontalScrollBar(scrollbar)
	goToSlide(scrollbar.element, "inactive")
	goToSlide(scrollbar.sliderElement, "inactive")
	scrollbar.width            = nil
	scrollbar.sliderWidth      = nil
	scrollbar.active           = nil
	scrollbar.dragOffset       = nil
	scrollbar.previousMousePos = nil
	scrollbar.valuePerPixel    = nil
end

function widgetSystem.highlightTableRow(tableID, tableElement, row, col)
	-- note: caller ensures that this is only called, if we have non-fixed rows
	tableElement.highlightedRows[row] = true

	-- do not highlight fixed rows
	if row < tableElement.topRow or row > tableElement.bottomRow then
		return -- row not displayed, no highlight to set
	end

	widgetSystem.setTableRowColor(tableID, tableElement, row, ((tableElement.highlightMode == "column") or (tableElement.highlightMode == "backgroundcolumn")) and col or nil, Color["table_row_multiselect"], true)
end

function widgetSystem.highlightTableRows(tableID, tableElement, startrow, endrow)
	if endrow < startrow then
		local buf = startrow
		startrow = endrow
		endrow = buf
	end
	for row = startrow, endrow do
		if tableElement.unselectableRows[row] == nil then
			widgetSystem.highlightTableRow(tableID, tableElement, row)
		end
	end
end

function widgetSystem.removeHighlightTableRows(tableID, tableElement, startrow, endrow)
	if endrow < startrow then
		local buf = startrow
		startrow = endrow
		endrow = buf
	end
	for row = startrow, endrow do
		if tableElement.highlightedRows[row] then
			widgetSystem.removeHighlightTableRow(tableID, tableElement, row)
		end
	end
end

function widgetSystem.toggleHighlight(tableID, tableElement, modified, input, source)
	if tableElement.multiSelect then
		if (not modified) or (modified == "ctrl") then
			widgetSystem.toggleHighlightedTableRow(tableID, tableElement)
			tableElement.shiftStart = tableElement.curRow
		elseif (modified == "shift") then
			widgetSystem.highlightTableRows(tableID, tableElement, tableElement.shiftStart, tableElement.curRow)
		end
		tableElement.shiftEnd = tableElement.curRow

		CallWidgetEventScripts(tableID, "onRowChanged", tableElement.curRow, modified, input, source)
	end
end

function widgetSystem.toggleHighlightedTableRow(tableID, tableElement)
	if tableElement.highlightedRows[tableElement.curRow] then
		widgetSystem.removeHighlightTableRow(tableID, tableElement, tableElement.curRow)
	else
		widgetSystem.highlightTableRow(tableID, tableElement, tableElement.curRow)
	end
end

function widgetSystem.getHighlightedRowsCount(tableElement)
	local count = 0
	for _ in pairs(tableElement.highlightedRows) do
		count = count + 1
	end
	return count
end

function widgetSystem.highlightBorderTableRow(tableID, tableElement, row, col)
	-- note: caller ensures that this is only called, if we have non-fixed rows

	if not IsValidWidgetElement(tableID) then
		-- view might have already been changed
		return
	end

	if (private.activeframe == 0) or (not IsValidWidgetElement(private.activeframe)) then
		-- active frame is invalid
		return
	end

	if (private.interactiveElement == nil) or (private.interactiveElement.widgetID ~= tableID) then
		-- not the interactive object, do not highlight
		return
	end
	
	-- do not highlight fixed rows
	if row < tableElement.topRow or row > tableElement.bottomRow then
		widgetSystem.removeHighlightBorderTableRow(tableElement)
		return -- row not displayed, no highlight to set
	end

	goToSlide(tableElement.borderElements.highlightElement, "active")
	
	-- width and height of the table row / col
	local width = 0
	if tableElement.highlightMode == "column" then
		_, width = widgetSystem.getColumnSpanInfo(tableID, tableElement, row, col, false)
	elseif tableElement.highlightMode == "backgroundcolumn" then
		col, _, width = widgetSystem.getBackgroundColumnSpanInfo(tableID, tableElement, row, col, false)
	else
		width = tableElement.width
	end
	local height = GetTableRowHeight(tableID, row)

	-- position of the upper left corner of the table row
	local offsetx, offsety = ((tableElement.highlightMode == "column") or (tableElement.highlightMode == "backgroundcolumn")) and tableElement.cellposx[col] or tableElement.cellposx[1], tableElement.cellposy[row]

	tableElement.highlightedBorderRow = row
	tableElement.highlightedBorderCol = col

	if private.enableMouseOverText then
		if private.hadNoneMouseInput then
			if ((GetControllerInfo() == "gamepad") and (not C.IsMouseEmulationActive())) or ((not private.mouseOverText) or (private.mouseOverText.posOverride ~= nil)) then
				local mouseoverwidgetid
				for col = 1, tableElement.numCols do
					local colspan = widgetSystem.getColumnSpanInfo(tableID, tableElement, row, col, not isNormalRegion)
					if colspan ~= 0 then
						local childWidgetID = GetCellContent(tableID, tableElement.highlightedBorderRow, col)
						if ffi.string(C.GetMouseOverText(childWidgetID)) ~= "" then
							mouseoverwidgetid = childWidgetID
							break
						end
					end
				end
				if mouseoverwidgetid then
					private.gamepadTableMouseOver = true
					local isNormalRegion = (row > tableElement.numFixedRows)
					local cellposx = tableElement.cellposx[1] + tableElement.width
					local cellposy = tableElement.cellposy[row]
					widgetSystem.showMouseOverText(mouseoverwidgetid, nil, { x = cellposx, y = cellposy })
				elseif private.mouseOverText and (not private.gamepadInteractiveChildMouseOver) then
					private.gamepadTableMouseOver = nil
					widgetSystem.hideMouseOverText(private.mouseOverText.widgetID)
				end
			end
		end
	end

	widgetSystem.setHighlightColor(tableElement, row)

	-- the button (see call above) is already positioned pixel-exact - that means that the following elements must all be positioned >on< non-subpixel-positions (hence no checking at all)
	widgetSystem.setElementPositionUnchecked(tableElement.borderElements.top,    offsetx + (width - config.table.bordersize) / 2, offsety + (height + config.table.bordersize) / 2)
	widgetSystem.setElementPositionUnchecked(tableElement.borderElements.bottom, offsetx + (width + config.table.bordersize) / 2, offsety - (height + config.table.bordersize) / 2)
	widgetSystem.setElementPositionUnchecked(tableElement.borderElements.left,   offsetx -          config.table.bordersize / 2,  offsety           - config.table.bordersize / 2)
	widgetSystem.setElementPositionUnchecked(tableElement.borderElements.right,  offsetx + width  + config.table.bordersize / 2,  offsety           + config.table.bordersize / 2)

	-- scale border elements
	widgetSystem.setElementScale(tableElement.borderElements.top,    (width + config.table.bordersize) / 100,           config.table.bordersize / 100)
	widgetSystem.setElementScale(tableElement.borderElements.bottom, (width + config.table.bordersize) / 100,           config.table.bordersize / 100)
	widgetSystem.setElementScale(tableElement.borderElements.left,            config.table.bordersize / 100,  (height + config.table.bordersize) / 100)
	widgetSystem.setElementScale(tableElement.borderElements.right,           config.table.bordersize / 100,  (height + config.table.bordersize) / 100)
end

function widgetSystem.removeHighlightBorderTableRow(tableElement)
	tableElement.highlightedBorderRow = nil
	goToSlide(tableElement.borderElements.highlightElement, "inactive")
end

----------------------------
-- Element initialization --
----------------------------

function widgetSystem.addDeferredElementInitializer(element, initializer, precedence, totalCount, numInitAtStartup, numInitPerFrame)
	private.elementInit[element] = {
		initializer = initializer,
		precedence = precedence,
		totalCount = totalCount,
		numInitialized = 0,
		numInitPerFrame = numInitPerFrame
	}
	table.insert(private.elementInitOrder, element)
	-- Run minimal initialization at startup
	if numInitAtStartup > 0 then
		widgetSystem.runElementInitializer(element, private.elementInit[element], numInitAtStartup)
	end
end

function widgetSystem.runDeferredElementInitialization()
	if private.elementInitOrder then
		-- only run a single initializer per frame, to avoid low framerate
		for _, element in ipairs(private.elementInitOrder) do
			local initdata = private.elementInit[element]
			if widgetSystem.runElementInitializer(element, initdata, initdata.numInitPerFrame) then
				return
			end
		end
		-- all initializers have finished, clean up
		private.elementInit = { }
		private.elementInitOrder = nil
		--print("#init - completed deferred element initialization")
	end
end

function widgetSystem.runElementInitializer(element, initdata, count)
	local remainingcount = initdata.totalCount - initdata.numInitialized
	if remainingcount <= 0 then
		return false
	end
	count = math.min(count, remainingcount)
	--print(string.format("#init - resuming initialization of elements of type '%s' (%d of %d remaining elements in this frame)", element, count, remainingcount))
	if count > 0 then
		-- During deferred initialization, some elements may already be in use, so the offsets do not necessarily match
		local offset = initdata.numInitialized
		local insertOffset = #private.element[element]
		for index = 1, count do
			local elementdata = initdata.initializer(offset + index)
			private.element[element][insertOffset + index] = elementdata
		end
		initdata.numInitialized = initdata.numInitialized + count
		--if count == remainingcount then
		--	print(string.format("#init - completed initialization of elements of type '%s'", element))
		--end
	end
	return true
end

function widgetSystem.initializeMasterElements()
	local layerElement = private.widgetsystem

	-- #StefanMed - shouldn't we also use the master elements themselves as the first element (i.e. one less clone per element type)?

	-- get general elements
	
	private.master.boxtext               = getElement("boxtext", layerElement)
	private.master.button                = getElement("button", layerElement)
	private.master.checkbox              = getElement("checkbox", layerElement)
	private.master.dropdown              = getElement("dropdown", layerElement)
	private.master.dropdownOption        = getElement("dropdown_option", layerElement)
	private.master.editbox               = getElement("editbox", layerElement)
	private.master.frame_brackets        = getElement("frame_bracket", layerElement)
	private.master.flowchart_group       = getElement("flowchart", layerElement)
	private.master.flowchart_background  = getElement("flowchart.flowchart_background", layerElement)
	private.master.flowchart_node        = getElement("flowchart.flowchart_node", layerElement)
	private.master.flowchart_edge        = getElement("flowchart.flowchart_edge", layerElement)
	private.master.graph                 = getElement("graph", layerElement)
	private.master.graphTick             = getElement("graph.tick", layerElement)
	private.master.graphDataPoint        = getElement("graph.datapoint", layerElement)
	private.master.graphIcon             = getElement("graph.icon", layerElement)
	private.master.helpOverlay           = getElement("helpoverlay", layerElement)
	private.master.icon                  = getElement("icon", layerElement)
	private.master.renderTarget          = getElement("rendertarget", layerElement)
	private.master.slidercell            = getElement("slider2", layerElement)
	private.master.standardButtons       = getElement("standardbuttons", layerElement)
	private.master.shieldhullbar         = getElement("shieldhullbar", layerElement)
	private.master.statusbar             = getElement("statusbar", layerElement)
	for _, type in ipairs(config.frame.backgroundElements) do
		private.master[type]             = getElement(type, layerElement)
	end

	-- get table elements
	local tablearray = private.master.table
	tablearray.header    = getElement("table_header", layerElement)
	tablearray.cell      = getElement("table_cell", layerElement)
	tablearray.scrollBar = getElement("table_scrollbar", layerElement)
	tablearray.mousePick = getElement("table_mousepick", layerElement)
	tablearray.highlight = getElement("table_highlight", layerElement)

	-- get shapes
	private.master.shapeRectangle        = getElement("rectangle", private.shapes)
	private.master.shapeCircle           = getElement("circle", private.shapes)
	private.master.shapeTriangle         = getElement("triangle", private.shapes)

	-- mini widgetsystem
	private.master.miniWidgetSystem.frame_brackets        = getElement("frame_bracket", private.miniwidgetsystem)
	private.master.miniWidgetSystem.standardButtons       = getElement("standardbuttons", private.miniwidgetsystem)
	for _, type in ipairs(config.frame.backgroundElements) do
		private.master.miniWidgetSystem[type]             = getElement(type, private.miniwidgetsystem)
	end
	local minitablearray = private.master.miniWidgetSystem.table
	minitablearray.header    = getElement("table_header", private.miniwidgetsystem)
	minitablearray.cell      = getElement("table_cell", private.miniwidgetsystem)
	minitablearray.scrollBar = getElement("table_scrollbar", private.miniwidgetsystem)
	minitablearray.mousePick = getElement("table_mousepick", private.miniwidgetsystem)
	minitablearray.highlight = getElement("table_highlight", private.miniwidgetsystem)
end

-- set scale parameters depending on resolution
function widgetSystem.prepareSize()
	local widthfactor = C.GetMenuWidthScale()

	local width, height = getScreenInfo()
	private.width, private.height = width, height
	-- use at least 20% of the screen for menus in 16:9 - on wider aspect ratios less is allowed
	local minwidth = 0.2 * private.width * (16 / 9) / (width / height)
	private.width = math.max(minwidth, private.width * widthfactor)
	-- can only return non-default size when cheats are active
	local widgetSystemSizeOverride = C.GetWidgetSystemSizeOverride()
	if widgetSystemSizeOverride.x ~= -1 then
		private.width = widgetSystemSizeOverride.x
	end
	if widgetSystemSizeOverride.y ~= -1 then
		private.height = widgetSystemSizeOverride.y
	end

	private.offsetx, private.offsety = private.width / 2, private.height / 2
	local aspectratio = width / height
	-- This 0.907 factor is weird. Also happens in the overlay presentation and presumably any other presentation, but isn't obvious because we don't care about pixel perfect placement in other cases
	private.scalingFactor = 0.0004 * 1080 / private.height * 0.907
	-- If the aspect ratio goes below 4/3 the visible rendered area of the game increases and we need to compensate our world-space positioned presentation accordingly
	if aspectratio < 4 / 3 then
		private.scalingFactor = private.scalingFactor * (4 / 3) / aspectratio
	end
	private.uiscale = C.GetUIScale(false)
end

function widgetSystem.initScale(anchorElement)
	setAttribute(anchorElement, "scale.x", private.scalingFactor)
	setAttribute(anchorElement, "scale.y", private.scalingFactor)
	setAttribute(anchorElement, "scale.z", private.scalingFactor)
end

function widgetSystem.getColors()
	local n = C.GetNumAllColorMapEntries()
	if n > 0 then
		local buf = ffi.new("ColorMapEntry[?]", n)
		n = C.GetAllColorMapEntries(buf, n)
		for i = 0, n - 1 do
			local id = ffi.string(buf[i].id)
			Color[id] = { r = buf[i].color.red, g = buf[i].color.green, b = buf[i].color.blue, a = buf[i].color.alpha, glow = buf[i].glowfactor }
		end
	end

	for id, color in pairs(Color) do
		ColorText[id] = string.format("\027#%02x%02x%02x%02x#", math.floor(color.a * 255 / 100 + 0.5), color.r, color.g, color.b)
	end
end

function widgetSystem.onUpdateColorMap()
	widgetSystem.getColors()
end


function widgetSystem.initializeRenderTarget()
	-- we work directly with the rendertarget
	private.element.renderTarget = {
		["element"] = private.master.renderTarget,
		["modelElement"]  = getElement("rendertarget", private.master.renderTarget),
		["noiseElement"]  = getElement("noise", private.master.renderTarget),
		["textureString"]   = config.renderTargetTextureFilename
	}

	local renderTargetElement = private.element.renderTarget.element
	registerForEvent("onMouseClick",       renderTargetElement, function (...) return widgetSystem.onMouseRenderTarget("onClick", ...) end)
	registerForEvent("onMouseDblClick",    renderTargetElement, function (...) return widgetSystem.onMouseRenderTarget("onDoubleClick", ...) end)
	registerForEvent("onMouseDown",        renderTargetElement, function (...) return widgetSystem.onMouseRenderTarget("onMouseDown", ...) end)
	registerForEvent("onMouseUp",          renderTargetElement, function (...) return widgetSystem.onMouseRenderTarget("onMouseUp", ...) end)
	registerForEvent("onMiddleMouseDown",  renderTargetElement, function (...) return widgetSystem.onMouseRenderTarget("onMiddleMouseDown", ...) end)
	registerForEvent("onMiddleMouseUp",    renderTargetElement, function (...) return widgetSystem.onMouseRenderTarget("onMiddleMouseUp", ...) end)
	registerForEvent("onRightMouseClick",  renderTargetElement, function (...) return widgetSystem.onMouseRenderTarget("onRightClick", ...) end)
	registerForEvent("onRightMouseDown",   renderTargetElement, function (...) return widgetSystem.onMouseRenderTarget("onRightMouseDown", ...) end)
	registerForEvent("onRightMouseUp",     renderTargetElement, function (...) return widgetSystem.onMouseRenderTarget("onRightMouseUp", ...) end)
	RegisterMouseInteractions(renderTargetElement)

	PrepareRenderTarget(config.renderTargetTextureFilename)
end

function widgetSystem.initializeTableElements()
	for tableindex = 1, config.table.maxTables do
		private.element.table[tableindex] = {}
		local tableElement = private.element.table[tableindex]
		tableElement.header = clone(private.master.table.header, "table"..tableindex.."header")
		tableElement.headerText = getElement("Text", tableElement.header)
		tableElement.scrollBar = {
			["sliderState"] = {
				["mouseClick"] = false,
				["mouseOver"]  = false,
				["gamepadFocus"] = false,
				["curSlide"]   = "inactive"
			}
		}
		tableElement.scrollBar.element = clone(private.master.table.scrollBar, "table"..tableindex.."scrollbar")
		tableElement.scrollBar.sliderElement = getElement("slider", tableElement.scrollBar.element)
		tableElement.mousePick = {
			["state"] = {
				["mouseOver"]  = {
					["state"] = false,
					-- ["original"] = nil,
					-- ["row"] = nil
				}
			}
		}
		tableElement.mousePick.element = clone(private.master.table.mousePick, "table"..tableindex.."mousepick")
		tableElement.borderElements = {}
		tableElement.borderElements.highlightElement = clone(private.master.table.highlight, "table"..tableindex.."highlight")
		for _, entry in ipairs(config.table.borderElements) do
			tableElement.borderElements[entry] = getElement(entry, tableElement.borderElements.highlightElement)
		end
		tableElement.cell = {}

		-- initialize for mouse interactions
		local backgroundSliderBar = getElement("background", tableElement.scrollBar.element)
		local sliderBar = tableElement.scrollBar.sliderElement
		local mousePick = tableElement.mousePick.element
		registerForEvent("onMouseClick",       backgroundSliderBar,            widgetSystem.onMouseClickPageScroll)
		registerForEvent("onMouseDblClick",    backgroundSliderBar,            widgetSystem.onMouseClickPageScroll)
		registerForEvent("onGroupedMouseOver", tableElement.scrollBar.element, widgetSystem.onMouseOverPageScroll)
		registerForEvent("onGroupedMouseOut",  tableElement.scrollBar.element, widgetSystem.onMouseOutPageScroll)
		registerForEvent("onMouseDown",        sliderBar,                      widgetSystem.onMouseStartScrollBarDrag)
		registerForEvent("onMouseUp",          sliderBar,                      widgetSystem.onMouseStopScrollBarDrag)
		registerForEvent("onGroupedMouseOver", sliderBar,                      widgetSystem.onMouseOverTableScrollBar)
		registerForEvent("onGroupedMouseOut",  sliderBar,                      widgetSystem.onMouseOutTableScrollBar)
		registerForEvent("onGroupedMouseOver", mousePick,                      widgetSystem.onMouseOverTable)
		registerForEvent("onGroupedMouseOut",  mousePick,                      widgetSystem.onMouseOutTable)
		RegisterMouseInteractions(backgroundSliderBar)
		-- note the slider must not only be registered for mouse interactions for dragging/dropping support, but rather also so it obstructs clicks on the backgroundSliderBar behind the slider
		RegisterMouseInteractions(sliderBar)
		RegisterMouseInteractions(mousePick)
	end
end

function widgetSystem.initializeTableRowElements()
	-- Partially deferred initialization
	local initializer = function(rowIndex)
		local tableRow = {}
		for colIndex = 1, config.tableRows.maxCols do 
			local cellelement = clone(private.master.table.cell, "row"..rowIndex.."col"..colIndex)
			tableRow[colIndex] = {
				["element"] = cellelement
			}
			registerForEvent("onMouseClick",       cellelement, function (...) return widgetSystem.onMouseClickTableCell(false, ...) end)
			registerForEvent("onMouseDblClick",    cellelement, function (...) return widgetSystem.onMouseClickTableCell(true, ...) end)
			registerForEvent("onRightMouseClick",  cellelement, widgetSystem.onRightMouseClickTableCell)
			registerForEvent("onGroupedMouseOver", cellelement, widgetSystem.onMouseOverTableCell)
			registerForEvent("onGroupedMouseOut",  cellelement, widgetSystem.onMouseOutTableCell)
			RegisterMouseInteractions(cellelement)
		end
		return tableRow
	end
	widgetSystem.addDeferredElementInitializer("tableRows", initializer, config.tableRows.initPrecedence, config.tableRows.maxRows, config.tableRows.maxRowsInit, 1)
end

function widgetSystem.processTableMousePick(tableElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)

	-- if the state changed, fire the events
	for state, value in pairs(tableElement.mousePick.state) do
		if (value.original ~= nil) and (value.original ~= value.state) then
			if state == "mouseOver" then
				if value.state then
					CallWidgetEventScripts(tableID, "onTableMouseOver", value.row)
				else
					CallWidgetEventScripts(tableID, "onTableMouseOut", value.row)
				end
			end
		end
		tableElement.mousePick.state[state].original = nil
	end
end

function widgetSystem.setActiveFrame(frameElement, checked)
	if frameElement.frame ~= private.activeframe then
		if checked or C.SetActiveFrame(frameElement.frame) then
			private.activeframe = frameElement.frame
		end
	end
end

function widgetSystem.setButtonElementState(buttonID, buttonElement, state, value)
	-- if the state changed, fire the events
	if buttonElement.buttonState[state] ~= value then
		if state == "mouseOver" then
			if value then
				local tableElement, tableID, row, col = widgetSystem.getTableElementByAnarkTableCellElement("button", buttonElement.element)
				if (tableElement.highlightMode == "off") or (tableElement.highlightMode == "offnormalscroll") then
					if private.interactiveElement and (private.interactiveElement.widgetID == tableID) then
						if private.interactiveElement.element.interactiveChild ~= nil then
							widgetSystem.unsetInteractiveChildElement(private.interactiveElement.element, private.interactiveElement.element.interactiveChild.widgetID, private.interactiveElement.element.interactiveChild.element)
						end
						widgetSystem.setInteractiveChildElement(tableID, tableElement, row, col, buttonID, buttonElement)
						widgetSystem.selectRowInternal(tableID, tableElement, row)
					end
				end

				CallWidgetEventScripts(buttonID, "onButtonMouseOver")
			else
				CallWidgetEventScripts(buttonID, "onButtonMouseOut")
			end
		else
			if value then
				if state == "keyboard" then
					CallWidgetEventScripts(buttonID, "onButtonSelect")
				elseif state == "mouseClick" or state == "keyboardPress" then
					-- this is the only case where we could in principle change from a non-click to a click-state, check if we actually changed
					local wasClicked = (buttonElement.buttonState["mouseClick"] or buttonElement.buttonState["keyboardPress"])
					if not wasClicked then
						CallWidgetEventScripts(buttonID, "onButtonDown")
					end
				end
			else
				if state == "mouseClick" or state == "keyboardPress" then
					-- this is the only case where we could in principle change from a click to a non-click-state, check if we actually changed
					local wasClicked = (buttonElement.buttonState["mouseClick"] or buttonElement.buttonState["keyboardPress"])
					if wasClicked then
						CallWidgetEventScripts(buttonID, "onButtonUp")
					end
				end
			end
		end
	end

	buttonElement.buttonState[state] = value
	widgetSystem.updateButtonState(buttonID, buttonElement)
end

function widgetSystem.setCheckBoxElementState(checkboxID, checkboxElement, state, value)
	-- if the state changed, fire the events
	if checkboxElement.checkboxState[state] ~= value then
		if state == "mouseOver" then
			if value then
				local tableElement, tableID, row, col = widgetSystem.getTableElementByAnarkTableCellElement("checkbox", checkboxElement.element)
				if (tableElement.highlightMode == "off") or (tableElement.highlightMode == "offnormalscroll") then
					if private.interactiveElement and (private.interactiveElement.widgetID == tableID) then
						if private.interactiveElement.element.interactiveChild ~= nil then
							widgetSystem.unsetInteractiveChildElement(private.interactiveElement.element, private.interactiveElement.element.interactiveChild.widgetID, private.interactiveElement.element.interactiveChild.element)
						end
						widgetSystem.setInteractiveChildElement(tableID, tableElement, row, col, checkboxID, checkboxElement)
						widgetSystem.selectRowInternal(tableID, tableElement, row)
					end
				end

				CallWidgetEventScripts(checkboxID, "onCheckBoxMouseOver")
			else
				CallWidgetEventScripts(checkboxID, "onCheckBoxMouseOut")
			end
		elseif value then
			if state == "keyboard" then
				CallWidgetEventScripts(checkboxID, "onCheckBoxSelect")
			end
		end
	end

	checkboxElement.checkboxState[state] = value
	widgetSystem.updateCheckBoxState(checkboxID, checkboxElement)
end

function widgetSystem.setDropDownElementState(dropdownID, dropdownElement, state, value)
	-- if the state changed, fire the events
	if dropdownElement.dropdownState[state] ~= value then
		if state == "mouseOver" then
			if value then
				local tableElement, tableID, row, col = widgetSystem.getTableElementByAnarkTableCellElement("dropdown", dropdownElement.element.mainElement)
				if (tableElement.highlightMode == "off") or (tableElement.highlightMode == "offnormalscroll") then
					if private.interactiveElement and (private.interactiveElement.widgetID == tableID) then
						if private.interactiveElement.element.interactiveChild ~= nil then
							widgetSystem.unsetInteractiveChildElement(private.interactiveElement.element, private.interactiveElement.element.interactiveChild.widgetID, private.interactiveElement.element.interactiveChild.element)
						end
						widgetSystem.setInteractiveChildElement(tableID, tableElement, row, col, dropdownID, dropdownElement)
						widgetSystem.selectRowInternal(tableID, tableElement, row)
					end
				end

				CallWidgetEventScripts(dropdownID, "onDropDownMouseOver")
			else
				CallWidgetEventScripts(dropdownID, "onDropDownMouseOut")
			end
		elseif value then
			if state == "keyboard" then
				CallWidgetEventScripts(dropdownID, "onDropDownSelect")
			end
		end
	end

	dropdownElement.dropdownState[state] = value
	widgetSystem.updateDropDownState(dropdownID, dropdownElement)
end

function widgetSystem.setDropDownRemoveOptionState(dropdownID, removeOptionElement, state, value)
	local dropdownElement = private.associationList[dropdownID].element
	local stateEntry
	for _, entry in ipairs(dropdownElement.element.removeOptionState) do
		if entry.element == removeOptionElement then
			stateEntry = entry
		end
	end
	if not stateEntry then
		DebugError("Couldn't find state entry for removeOption of dropdown '" .. dropdownID .. "'")
		return
	end
	stateEntry[state] = value

	local colorMode = "normal"
	if stateEntry.mouseDown then
		colorMode = "inverse"
	elseif stateEntry.mouseOver then
		colorMode = "highlight"
	end
	if stateEntry.curColorMode ~= colorMode then
		widgetSystem.setDropDownRemoveOptionColor(dropdownElement, removeOptionElement, colorMode)
		stateEntry.curColorMode = colorMode
	end
end

function widgetSystem.setDropDownRemoveOptionColor(dropdownElement, removeOptionElement, colorMode)
	local r, g, b, a = dropdownElement.textDetails.color.red, dropdownElement.textDetails.color.green, dropdownElement.textDetails.color.blue, dropdownElement.textDetails.color.alpha
	if colorMode == "inverse" then
		r, g, b = widgetSystem.invertColor(r, g, b)
	elseif colorMode == "normal" then
		r = r * 0.8
		g = g * 0.8
		b = b * 0.8
	-- else, it's "highlight" and uses the original color
	end
	local material = getElement("cross.x_part_01.Material8561", removeOptionElement)
	SetDiffuseColor(material, r, g, b)
	setAttribute(material, "opacity", a)
	setAttribute(material, "glowfactor", dropdownElement.textDetails.glowfactor)
	material = getElement("cross.x_part_02.Material8561", removeOptionElement)
	SetDiffuseColor(material, r, g, b)
	setAttribute(material, "opacity", a)
	setAttribute(material, "glowfactor", dropdownElement.textDetails.glowfactor) 
end

-- #StefanLow - split up into setElementPosX/setElementPosY (removes need for x ~= nil / y ~= nil checks)
-- xUseHalfPixel - indicates whether the x-position is to use half-pixel-positioning on even frame widths (otherwise, it's the other way around)
-- yUseHalfPixel - indicates whether the y-position is to use half-pixel-positioning on even frame heights (otherwise, it's the other way around)
function widgetSystem.setElementPosition(anarkElement, x, y, xUseHalfPixel, yUseHalfPixel)
	if config.verifyPixelExact then
		local testx = x
		if testx and ((xUseHalfPixel and (private.offsetx % 1 == 0)) or (not xUseHalfPixel and (private.offsetx % 1 ~= 0))) then
			testx = testx + 0.5
		end
		local testy = y
		if testy and ((yUseHalfPixel and (private.offsety % 1 == 0)) or (not yUseHalfPixel and (private.offsety % 1 ~= 0))) then
			testy = testy + 0.5
		end
		if (testx ~= nil and testx % 1 ~= 0) or (testy ~= nil and testy % 1 ~= 0) then
			DebugError("Widget system warning. Given position for element "..tostring(anarkElement).." uses subpixels. This will lead to graphical issues. x/y: "..tostring(x).." / "..tostring(y).." - using halfpixels (x/y): "..tostring(xUseHalfPixel).." / "..tostring(yUseHalfPixel))
		end
	end

	widgetSystem.setElementPositionUnchecked(anarkElement, x, y)
end

-- sets the element position directly without performing subpixel-positioning checks
function widgetSystem.setElementPositionUnchecked(anarkElement, x, y)
	if x ~= nil then
		setAttribute(anarkElement, "position.x", x)
	end
	if y ~= nil then
		setAttribute(anarkElement, "position.y", y)
	end
end

-- #StefanLow - split up into setElementScaleX/setElementScaleY (removes need for x ~= nil / y ~= nil checks)
function widgetSystem.setElementScale(anarkElement, x, y)
	-- #StefanHigh - reenable (See XT-2498)
	--[[if config.verifyPixelExact then
		if (x ~= nil and (x*100) % 1 ~= 0) or (y ~= nil and (y*100) % 1 ~= 0) then
			DebugError("Widget system warning. Given scale for element "..tostring(anarkElement).." uses subpixels. This will lead to graphical issues. x/y: "..tostring(x).." / "..tostring(y))
		end
	end]]

	if x ~= nil then
		setAttribute(anarkElement, "scale.x", x)
	end
	if y ~= nil then
		setAttribute(anarkElement, "scale.y", y)
	end
end

function widgetSystem.setElementRotation(anarkElement, angle)
	if angle ~= nil then
		setAttribute(anarkElement, "rotation.z", angle)
	end
end

function widgetSystem.setElementColorAlpha(anarkMaterial, color)
	SetDiffuseColor(anarkMaterial, color.r, color.g, color.b)
	setAttribute(anarkMaterial, "opacity", color.a)
	setAttribute(anarkMaterial, "glowfactor", color.glow or 0)
end

function widgetSystem.setElementTextColor(anarkTextElement, color)
	setAttribute(anarkTextElement, "textcolor.r", color.r)
	setAttribute(anarkTextElement, "textcolor.g", color.g)
	setAttribute(anarkTextElement, "textcolor.b", color.b)
	if color.a then
		setAttribute(anarkTextElement, "opacity", color.a)
	end
end

function widgetSystem.setInteractiveElement(frameID, widgetID, allowregionchange, checked)
	if not private.associationList[widgetID] then
		-- valid case - GetInteractiveObject() can return the correct widgetID before the widgetsystem created the association, in which case widgetSystem.updateFrame() will catch it later
		return
	end

	if (private.interactiveElement ~= nil) and IsValidWidgetElement(private.interactiveElement.widgetID) and IsType(private.interactiveElement.widgetID, "table") then
		local tableElement = private.interactiveElement.element
		widgetSystem.removeHighlightBorderTableRow(tableElement)
		if (tableElement.highlightMode == "off") and tableElement.scrollBar.active then
			widgetSystem.setScrollBarState(tableElement.scrollBar, "gamepadFocus", false, private.interactiveElement.widgetID)
		end
	end

	private.interactiveElement = {
		["frameID"]  = frameID,
		["element"]  = private.associationList[widgetID].element,
		["widgetID"] = widgetID
	}

	-- swap fixed regions to normal regions (if possible), when a table becomes the interactive element
	local swappedRegion = false
	if allowregionchange then
		if IsType(widgetID, "table") then
			if private.interactiveElement.element.interactiveRegion == "fixed" then
				widgetSystem.swapInteractiveRegion(private.interactiveElement.widgetID, private.interactiveElement.element)
				swappedRegion = true
			end
		end
	end

	-- set the new interactive child element, if required
	if not swappedRegion and private.interactiveElement.element.interactiveChild ~= nil then
		widgetSystem.setInteractiveChildElement(private.interactiveElement.widgetID, private.interactiveElement.element, private.interactiveElement.element.interactiveChild.row, private.interactiveElement.element.interactiveChild.col, private.interactiveElement.element.interactiveChild.widgetID, private.interactiveElement.element.interactiveChild.element)
	elseif private.mouseOverText then
		if private.mouseOverText.posOverride ~= nil then
			widgetSystem.hideMouseOverText(private.mouseOverText.widgetID)
		end
	end

	if IsType(widgetID, "table") then
		local tableElement = private.interactiveElement.element
		local isNormalRegion = (tableElement.curRow > tableElement.numFixedRows)
		if isNormalRegion then
			if (tableElement.highlightMode ~= "off") and (tableElement.highlightMode ~= "offnormalscroll") then
				local curCol = 1
				if tableElement.interactiveChild ~= nil then
					curCol = tableElement.interactiveChild.col
				end
				widgetSystem.highlightBorderTableRow(widgetID, tableElement, tableElement.curRow, curCol)
			elseif tableElement.highlightMode == "off" then
				if tableElement.scrollBar.active then
					widgetSystem.setScrollBarState(tableElement.scrollBar, "gamepadFocus", true, widgetID)
				end
			end
		end
	end

	if not checked then
		C.SetFrameInteractiveObject(frameID, widgetID)
	end
	CallWidgetEventScripts(frameID, "onInteractiveElementChanged", widgetID)
end

-- tableID           - the widgetID of the table containing the child
-- tableElement      - the table element entry of the table containing the child
-- childWidgetID     - the widgetID of the interactive child
-- childTableElement - the table entry of the element of the child
function widgetSystem.setInteractiveChildElement(tableID, tableElement, row, col, childWidgetID, childTableElement)
	if tableElement.interactiveChild then
		if col ~= tableElement.interactiveChild.col then
			CallWidgetEventScripts(tableID, "onColumnChanged", col)
		end
	end

	if not IsValidWidgetElement(childWidgetID) then
		 -- view might have already been changed
		return
	end

	tableElement.interactiveChild = {
		["row"]      = row,
		["col"]      = col,
		["element"]  = childTableElement,
		["widgetID"] = childWidgetID
	}
	-- only update the state if the interactive element is visible (it can be scrolled out of view, in which case it's not currently associated with an element)
	if not private.associationList[childWidgetID] then
		return
	end
	-- and only if we are the interactive element (in case of multiple tables, only one table is the interactive element for example)
	if childTableElement ~= nil and private.interactiveElement ~= nil and private.interactiveElement.widgetID == tableID then
		if private.slidercellInputActive then
			C.DeactivateSliderCellInput()
			private.slidercellInputActive = nil
		end

		if IsType(childWidgetID, "button") then
			widgetSystem.setButtonElementState(childWidgetID, childTableElement, "keyboard", true)
		elseif IsType(childWidgetID, "checkbox") then
			widgetSystem.setCheckBoxElementState(childWidgetID, childTableElement, "keyboard", true)
		elseif IsType(childWidgetID, "dropdown") then
			widgetSystem.setDropDownElementState(childWidgetID, childTableElement, "keyboard", true)
		elseif IsType(childWidgetID, "editbox") then
			widgetSystem.updateEditBoxColor(childWidgetID, childTableElement, true)
		elseif IsType(childWidgetID, "slidercell") then
			private.slidercellInputActive = childWidgetID
			C.ActivateSliderCellInput()
		end
		-- for other interactive elements, there's nothing to do

		if private.enableMouseOverText then
			if ((GetControllerInfo() == "gamepad") and (not C.IsMouseEmulationActive())) or ((not private.mouseOverText) or (private.mouseOverText.posOverride ~= nil)) then
				if ffi.string(C.GetMouseOverText(childWidgetID)) ~= "" then
					private.gamepadInteractiveChildMouseOver = true
					local isNormalRegion = (row > tableElement.numFixedRows)
					local cellposx = tableElement.cellposx[1] + tableElement.width
					if col then
						cellposx = isNormalRegion and tableElement.cellposx[col] or tableElement.fixedRowCellposx[col]
						local _, cellwidth = widgetSystem.getColumnSpanInfo(tableID, tableElement, row, col, not isNormalRegion)
						cellposx = cellposx + cellwidth
					end
					local cellposy = tableElement.cellposy[row]
					widgetSystem.showMouseOverText(childWidgetID, nil, { x = cellposx, y = cellposy })
				elseif private.mouseOverText and (not private.gamepadTableMouseOver) then
					private.gamepadInteractiveChildMouseOver = nil
					widgetSystem.hideMouseOverText(private.mouseOverText.widgetID)
				end
			end
		end
	end
	
end

function widgetSystem.setSliderCellArrowState(slidercellID, leftRight, state, value)
	if slidercellID ~= nil then
		local slidercellElement = private.associationList[slidercellID].element
		local stateEntry = slidercellElement.element.sliderArrowState[leftRight]
		stateEntry[state] = value
		widgetSystem.updateSliderCellArrowSlide(slidercellElement, leftRight)
	end
end

function widgetSystem.updateSliderCellArrowSlide(slidercellElement, leftRight)
	local stateEntry = slidercellElement.element.sliderArrowState[leftRight]
	local targetSlide = slidercellElement.forceArrows and "disabled" or "inactive"
	local color = slidercellElement.forceArrows and Color["slider_arrow_disabled"] or Color["slider_arrow_normal"]

	if not slidercellElement.readonly then
		local enabled
		local cur = slidercellElement.cur
		if type(cur) ~= "number" then
			cur = slidercellElement.oldcur
		end
		if ((leftRight == "left") or (leftRight == "skip_left")) == (not slidercellElement.righttoleft) then
			enabled = cur > slidercellElement.minSelect
		else
			enabled = cur < slidercellElement.maxSelect or slidercellElement.exceedmax
		end
		if not enabled then
			targetSlide = "disabled"
		elseif stateEntry.mouseDown then
			targetSlide = "click"
		elseif stateEntry.mouseOver then
			targetSlide = "highlight"
		else
			targetSlide = "normal"
		end
		color = Color["slider_arrow_" .. targetSlide]
	end

	if leftRight == "left" then
		local material = getElement("button_arrow_left_01.Material812", slidercellElement.element.arrow_left)
		SetDiffuseColor(material, color.r, color.g, color.b)
		setAttribute(material, "opacity", color.a)
		setAttribute(material, "glowfactor", color.glow)
	elseif leftRight == "skip_left" then
		local material = getElement("button_arrow_left_01.Material812", slidercellElement.element.arrow_skip_left)
		SetDiffuseColor(material, color.r, color.g, color.b)
		setAttribute(material, "opacity", color.a)
		setAttribute(material, "glowfactor", color.glow)
	elseif leftRight == "right" then
		material = getElement("button_arrow_right_01.Material805", slidercellElement.element.arrow_right)
		SetDiffuseColor(material, color.r, color.g, color.b)
		setAttribute(material, "opacity", color.a)
		setAttribute(material, "glowfactor", color.glow)
	elseif leftRight == "skip_right" then
		material = getElement("button_arrow_right_01.Material805", slidercellElement.element.arrow_skip_right)
		SetDiffuseColor(material, color.r, color.g, color.b)
		setAttribute(material, "opacity", color.a)
		setAttribute(material, "glowfactor", color.glow)
	end

	if stateEntry.curSlide ~= targetSlide then
		goToSlide(stateEntry.element, targetSlide)
		stateEntry.curSlide = targetSlide
	end
end

function widgetSystem.updateSliderCellBackground(slidercellElement)
	if slidercellElement.fromcenter then
		local width = slidercellElement.width
		local height = slidercellElement.height

		local inactive = { width = 0, offset = 0, opacity = 0 }

		local leftEnabled, rightEnabled
		local cur = slidercellElement.cur
		if type(cur) ~= "number" then
			cur = slidercellElement.oldcur
		end
		if not slidercellElement.righttoleft then
			leftEnabled = cur > slidercellElement.minSelect
			rightEnabled = cur < slidercellElement.maxSelect or slidercellElement.exceedmax
		else
			leftEnabled = cur < slidercellElement.maxSelect or slidercellElement.exceedmax
			rightEnabled = cur > slidercellElement.minSelect
		end

		if (not leftEnabled) and (not rightEnabled) then
			inactive.width = width
			inactive.opacity = 100
		elseif (not leftEnabled) then
			inactive.width = width / 2
			inactive.offset = -width / 4
			inactive.opacity = 100
		elseif (not rightEnabled) then
			inactive.width = width / 2
			inactive.offset = width / 4
			inactive.opacity = 100
		end

		local inactiveElement = getElement("slider.elements.Rectangle_background3", slidercellElement.element.main)
		widgetSystem.setElementScale(inactiveElement, inactive.width / 100, height / 100)
		widgetSystem.setElementPosition(inactiveElement, inactive.offset, 0, (inactive.width % 2 ~= 0), (height % 2 ~= 0))
		local material = getElement("Material651", inactiveElement)
		setAttribute(material, "opacity", inactive.opacity)
	end
end

function widgetSystem.setScrollBarState(scrollBarElement, state, value, callbackElement)
	local stateEntry = scrollBarElement.sliderState
	stateEntry[state] = value

	local targetSlide = "inactive"
	-- #StefanLow --- this function doesn't need to be designed with inactive scrollbars --- it'll never be called...
	if scrollBarElement.active then
		-- only activate the bar if the scrollbar is actually visible
		if stateEntry.mouseClick then
			targetSlide = "click"
		elseif stateEntry.mouseOver or stateEntry.gamepadFocus then
			targetSlide = "highlight"
		else
			targetSlide = "normal"
		end
	end

	if stateEntry.curSlide ~= targetSlide then
		if stateEntry.curSlide == "click" then
			-- if the previous state was "click" and the current isn't (aka: curSlide ~= targetSlide) -> issue a onScrollBarUp-event
			CallWidgetEventScripts(callbackElement, "onScrollBarUp")
		end
		if targetSlide == "click" then
			CallWidgetEventScripts(callbackElement, "onScrollBarDown")
		elseif targetSlide == "highlight" then
			CallWidgetEventScripts(callbackElement, "onScrollBarOver")
		end
		goToSlide(scrollBarElement.sliderElement, targetSlide)
		stateEntry.curSlide = targetSlide
	end
end

function widgetSystem.setStandardButtonState(frameID, frameElement, button, state, value)
	if frameElement.standardButtonState[button][state] ~= value then
		if state == "mouseOver" then
			if value then
				CallWidgetEventScripts(frameID, "onStandardButtonMouseOver")
			else
				CallWidgetEventScripts(frameID, "onStandardButtonMouseOut")
			end
		end
	end
	frameElement.standardButtonState[button][state] = value
	widgetSystem.updateStandardButtonState(frameElement, button)
end

function widgetSystem.setTableMousePickState(table, tableElement, state, value, row)
	if tableElement.mousePick.state[state].original == nil then
		tableElement.mousePick.state[state].original = tableElement.mousePick.state[state].state
	end

	tableElement.mousePick.state[state].state = value
	tableElement.mousePick.state[state].row = row
end

-- useRowColor indicates whether the rowcolor should be used to color all elements
function widgetSystem.setTableRowColor(tableID, tableElement, row, col, rowcoloroverride, useRowColor)
	if not tableElement.borderEnabled then
		return -- nothing to do without borders being enabled
	end

	local realRow
	if row <= tableElement.numFixedRows then
		realRow = row
	else
		-- note: callers ensure this is only called with row > numFixedRows, if we actually do have non-fixed rows
		realRow = row - tableElement.topRow + 1 + tableElement.numFixedRows
	end

	-- set color of the table background elements
	local columns = tableElement.cell[realRow]
	for i, cell in ipairs(columns) do
		if i > tableElement.numCols then
			-- skip anark elemnts that are currently not used
			break
		end
		if (not col) or (i == col) then
			local tablecellcolor = { GetTableCellColor(tableID, row, i) }
			local rowcolor = { r = tablecellcolor[1], g = tablecellcolor[2], b = tablecellcolor[3], a = tablecellcolor[4] }
			if rowcoloroverride then
				rowcolor = rowcoloroverride
			end

			local element = getElement("middle.material", cell.element)
			SetDiffuseColor(element, rowcolor.r, rowcolor.g, rowcolor.b)
			setAttribute(element, "opacity", rowcolor.a)

			-- set button color
			if cell.button ~= nil then
				local material = getElement("background.Material753", cell.button.element)
				local r, g, b, a
				if useRowColor then
					r = rowcolor.r
					g = rowcolor.g
					b = rowcolor.b
					-- #StefanMed - review --- why should the transparency for buttons change between selected and unselected rows?
					a = rowcolor.a
				else
					-- valid for both active and inactive buttons
					r = cell.button.color.r
					g = cell.button.color.g
					b = cell.button.color.b
					a = cell.button.color.a
				end
				if not cell.button.active then
					-- inactive buttons have to use the unchanged alpha value
					a = cell.button.color.a
				end 
				SetDiffuseColor(material, r, g, b)
				setAttribute(material, "opacity", a)
			end

			-- set dropdown color
			if cell.dropdown ~= nil then
				local inactivecolor = Color["dropdown_background_inactive"]
				local material = getElement("background.Material753", cell.dropdown.element.mainElement)
				local r, g, b, a
				if useRowColor then
					r = rowcolor.r
					g = rowcolor.g
					b = rowcolor.b
					-- #StefanMed - review --- why should the transparency for buttons change between selected and unselected rows?
					a = rowcolor.a
				else
					if cell.dropdown.active then
						r = cell.dropdown.color.r
						g = cell.dropdown.color.g
						b = cell.dropdown.color.b
						a = cell.dropdown.color.a
					else -- inactive button
						r, g, b = inactivecolor.r, inactivecolor.g, inactivecolor.b
					end				
				end
				if not cell.dropdown.active then
					-- inactive buttons have to use the unchanged alpha value
					a = inactivecolor.a
				end 
				SetDiffuseColor(material, r, g, b)
				setAttribute(material, "opacity", a)
			end

			-- set editbox color
			if cell.editbox ~= nil then
				local material = getElement("background.Material689", cell.editbox.element)
				local r, g, b, a
				if useRowColor then
					-- #StefanMed --- investigate and maybe change highlighting behavior to a gray-scale element rather than using colors --- problem is that blending the yellow color twice will result in a brighter yellow color than the one we have for normal table cells.
					-- current solution is that in the highlighted case we simply ignore the editbox-color altogether (by hardcoding the alpha to 0)
					r = rowcolor.r
					g = rowcolor.g
					b = rowcolor.b
					-- #StefanMed - review the case when setting to ~= 0 --- why should the transparency for editboxes change between selected and unselected rows?
					a = 0 --rowcolor.a <- old value - reenable or remove
					glow = 0
				else
					r = cell.editbox.color.r
					g = cell.editbox.color.g
					b = cell.editbox.color.b
					a = cell.editbox.color.a
					glow = cell.editbox.color.glow
				end
				SetDiffuseColor(material, r, g, b)
				setAttribute(material, "opacity", a)
				setAttribute(material, "glowfactor", glow)
			end

			if cell.slidercell ~= nil then
				local material = getElement("slider.elements.Rectangle_background.Material651", cell.slidercell.element.main)
				local r, g, b, a
				if useRowColor then
					-- #StefanMed --- investigate and maybe change highlighting behavior to a gray-scale element rather than using colors --- problem is that blending the yellow color twice will result in a brighter yellow color than the one we have for normal table cells.
					-- current solution is that in the highlighted case we simply ignore the editbox-color altogether (by hardcoding the alpha to 0)
					r = rowcolor.r
					g = rowcolor.g
					b = rowcolor.b
					-- #StefanMed - review the case when setting to ~= 0 --- why should the transparency for slidercells change between selected and unselected rows?
					a = 0 --rowcolor.a <- old value - reenable or remove
				else
					r = cell.slidercell.bgcolor.r
					g = cell.slidercell.bgcolor.g
					b = cell.slidercell.bgcolor.b
					a = cell.slidercell.bgcolor.a
				end
				SetDiffuseColor(material, r, g, b)
				setAttribute(material, "opacity", a)
			end
		end
	end
end

function widgetSystem.toggleMouseOverText(value)
	if (private.mouseOverText ~= nil) then
		widgetSystem.hideMouseOverText(private.mouseOverText.widgetID)
	end
	if private.enableMouseOverText ~= value then
		private.enableMouseOverText = value
	end
end

function widgetSystem.initializeButtonElements()
	for count = 1, config.button.maxElements do
		local buttonElement = clone(private.master.button, "button"..count)
		table.insert(private.element.button, buttonElement)

		local material = getElement("value2.Material753", buttonElement)
		local color = Color["button_background_inactive"]
		SetDiffuseColor(material, color.r, color.g, color.b)
		setAttribute(material, "opacity", color.a)

		-- register for mouse interactions
		registerForEvent("onMouseClick",       buttonElement, widgetSystem.onMouseClickButton)
		registerForEvent("onMouseDblClick",    buttonElement, widgetSystem.onMouseDblClickButton)
		registerForEvent("onMouseDown",        buttonElement, widgetSystem.onMouseDownButton)
		registerForEvent("onMouseUp",          buttonElement, widgetSystem.onMouseUpButton)
		registerForEvent("onRightMouseClick",  buttonElement, widgetSystem.onRightMouseClickButton)
		registerForEvent("onGroupedMouseOver", buttonElement, widgetSystem.onMouseOverButton)
		registerForEvent("onGroupedMouseOut",  buttonElement, widgetSystem.onMouseOutButton)
		RegisterMouseInteractions(buttonElement)
	end
end

function widgetSystem.initializeCheckBoxElements()
	for count = 1, config.checkbox.maxElements do
		local checkboxElement = clone(private.master.checkbox, "checkbox"..count)
		table.insert(private.element.checkbox, checkboxElement)

		-- register for mouse interactions
		registerForEvent("onMouseClick",       checkboxElement, widgetSystem.onMouseClickCheckBox)
		registerForEvent("onMouseDblClick",    checkboxElement, widgetSystem.onMouseDblClickCheckBox)
		registerForEvent("onGroupedMouseOver", checkboxElement, widgetSystem.onMouseOverCheckBox)
		registerForEvent("onGroupedMouseOut",  checkboxElement, widgetSystem.onMouseOutCheckBox)
		RegisterMouseInteractions(checkboxElement)
	end
end

function widgetSystem.initializeBoxTextElements()
	for count = 1, config.boxtext.maxElements do
		local boxtextElement = {}
		boxtextElement.mainElement = clone(private.master.boxtext, "boxtext"..count)

		table.insert(private.element.boxtext, boxtextElement)

		-- register for mouse interactions
		registerForEvent("onGroupedMouseOver", boxtextElement.mainElement, widgetSystem.onMouseOverBoxText)
		registerForEvent("onGroupedMouseOut",  boxtextElement.mainElement, widgetSystem.onMouseOutBoxText)
		RegisterMouseInteractions(boxtextElement.mainElement)
	end
end

function widgetSystem.initializeDropDownElements()
	-- Partially deferred initialization
	local initializer = function(index)
		local dropdownElement = {}

		dropdownElement.mainElement = clone(private.master.dropdown, "dropdown"..index)
		-- register for mouse interactions
		local mousepick = getElement("mousepick", dropdownElement.mainElement)
		registerForEvent("onMouseClick",       mousepick, widgetSystem.onMouseClickDropDown)
		registerForEvent("onMouseDblClick",    mousepick, widgetSystem.onMouseDblClickDropDown)
		registerForEvent("onMouseDown",        mousepick, widgetSystem.onMouseDownDropDown)
		registerForEvent("onMouseUp",          mousepick, widgetSystem.onMouseUpDropDown)
		registerForEvent("onGroupedMouseOver", dropdownElement.mainElement, widgetSystem.onMouseOverDropDown)
		registerForEvent("onGroupedMouseOut",  dropdownElement.mainElement, widgetSystem.onMouseOutDropDown)
		-- note we register mouse click related events on the mousepick helper element, so that they will be obstructed by the sliderbar if any
		RegisterMouseInteractions(mousepick)
		RegisterMouseInteractions(dropdownElement.mainElement)

		local color = Color["dropdown_background_inactive"]
		local material = getElement("value2.Material753", dropdownElement.mainElement)
		SetDiffuseColor(material, color.r, color.g, color.b)
		setAttribute(material, "opacity", color.a)

		dropdownElement.optionElements = {}
		dropdownElement.removeOptionState = {}
		for optionCount = 1, config.dropdown.maxVisibleOptionsPerElement do
			table.insert(dropdownElement.optionElements, clone(private.master.dropdownOption, "dropdownOption"..optionCount))
			local optionElement = dropdownElement.optionElements[optionCount]
			local removeOptionElement = getElement("removeOption", optionElement)
			registerForEvent("onMouseDown",        removeOptionElement, widgetSystem.onMouseDownDropDownRemoveOption)
			registerForEvent("onMouseUp",          removeOptionElement, widgetSystem.onMouseUpDropDownRemoveOption)
			registerForEvent("onGroupedMouseOver", removeOptionElement, widgetSystem.onMouseOverDropDownRemoveOption)
			registerForEvent("onGroupedMouseOut",  removeOptionElement, widgetSystem.onMouseOutDropDownRemoveOption)
			RegisterMouseInteractions(removeOptionElement)

			table.insert(dropdownElement.removeOptionState, {
				["mouseClick"] = false,
				["mouseOver"]  = false,
				["element"]    = removeOptionElement,
				["curColorMode"]   = "inactive"
			})
		end

		dropdownElement.scrollBar = {
			["sliderState"] = {
				["mouseClick"] = false,
				["mouseOver"]  = false,
				["gamepadFocus"] = false,
				["curSlide"]   = "inactive"
			}
		}
		dropdownElement.scrollBar.element = getElement("Scrollbar", dropdownElement.mainElement)
		dropdownElement.scrollBar.sliderElement = getElement("slider", dropdownElement.scrollBar.element)

		local backgroundSliderBar = getElement("background", dropdownElement.scrollBar.element)
		local sliderBar = dropdownElement.scrollBar.sliderElement
		registerForEvent("onMouseClick",       backgroundSliderBar, widgetSystem.onMouseClickDropDownPageScroll)
		registerForEvent("onMouseDblClick",    backgroundSliderBar, widgetSystem.onMouseClickDropDownPageScroll)
		registerForEvent("onMouseDown",        sliderBar,           widgetSystem.onMouseStartDropDownScrollBarDrag)
		registerForEvent("onMouseUp",          sliderBar,           widgetSystem.onMouseStopDropDownScrollBarDrag)
		registerForEvent("onGroupedMouseOver", sliderBar,           widgetSystem.onMouseOverDropDownScrollBar)
		registerForEvent("onGroupedMouseOut",  sliderBar,           widgetSystem.onMouseOutDropDownScrollBar)
		RegisterMouseInteractions(backgroundSliderBar)
		-- note the slider must not only be registered for mouse interactions for dragging/dropping support, but rather also so it obstructs clicks on the backgroundSliderBar behind the slider
		RegisterMouseInteractions(sliderBar)

		return dropdownElement
	end
	widgetSystem.addDeferredElementInitializer("dropdown", initializer, config.dropdown.initPrecedence, config.dropdown.maxElements, config.dropdown.maxElementsInit, 1)
end

function widgetSystem.initializeEditBoxElements()
	for count = 1, config.editbox.maxElements do
		local editboxElement = clone(private.master.editbox, "editbox"..count)
		table.insert(private.element.editbox, editboxElement)

		local color = Color["editbox_background_black"]
		local material = getElement("background_black.Material689", editboxElement)
		SetDiffuseColor(material, color.r, color.g, color.b)
		setAttribute(material, "opacity", color.a)

		-- register for mouse interactions
		registerForEvent("onMouseClick",       editboxElement, function (...) return widgetSystem.onMouseClickEditBox(false, ...) end)
		registerForEvent("onMouseDblClick",    editboxElement, function (...) return widgetSystem.onMouseClickEditBox(true, ...) end)
		registerForEvent("onMouseDown",        editboxElement, widgetSystem.onMouseDownEditBox)
		registerForEvent("onMouseUp",          editboxElement, widgetSystem.onMouseUpEditBox)
		registerForEvent("onRightMouseClick",  editboxElement, widgetSystem.onRightMouseClickEditBox)
		registerForEvent("onGroupedMouseOver", editboxElement, widgetSystem.onMouseOverEditBox)
		registerForEvent("onGroupedMouseOut",  editboxElement, widgetSystem.onMouseOutEditBox)
		RegisterMouseInteractions(editboxElement)
	end
end

function widgetSystem.initializeFrameElements()
	for frameindex = 0, config.frame.maxFrames - 1 do
		private.frames[frameindex] = {}
		local frameElement = private.frames[frameindex]

		frameElement.layer = frameindex

		frameElement.tables = {}
		frameElement.rendertargets = {}
		frameElement.flowcharts = {}
		
		-- backgrounds & overlay
		for _, type in ipairs(config.frame.backgroundElements) do
			frameElement[type] = clone(private.master[type], "frame"..frameindex..type)
			widgetSystem.moveAnarkElementFrameLayer(frameElement, frameElement[type], 1)
			frameElement[type .. "Icon"] = getElement(type .. ".Material642." .. config.frame.backgroundElementTextures[type], frameElement[type])
			frameElement[type .. "Data"] = {}
		end

		-- brackets
		frameElement.bracketsElement = clone(private.master.frame_brackets, "frame"..frameindex.."brackets")
		widgetSystem.moveAnarkElementFrameLayer(frameElement, frameElement.bracketsElement, 1)

		-- to prevent mouse clicks on frames behind this one if they are occluded by the background
		RegisterMouseInteractions(frameElement.backgroundTexture)

		-- standard buttons
		frameElement.standardButtons = clone(private.master.standardButtons, "frame"..frameindex.."standardButtons")
		widgetSystem.moveAnarkElementFrameLayer(frameElement, frameElement.standardButtons, 1)
		frameElement.standardButtonState = {}

		for _, element in ipairs(config.frame.standardButtonOrder) do
			frameElement[element .. "Element"] = getElement(element, frameElement.standardButtons)
			frameElement[element .. "Materials"] = {}
			if element == "close" then
				table.insert(frameElement[element .. "Materials"], "cross.x_part_01.Material8561")
				table.insert(frameElement[element .. "Materials"], "cross.x_part_02.Material8561")
			elseif element == "back" then
				table.insert(frameElement[element .. "Materials"], "arrow.arrow_part_01.Material14115")
				table.insert(frameElement[element .. "Materials"], "arrow.arrow_part_02.Material14115")
			elseif element == "minimize" then
				table.insert(frameElement[element .. "Materials"], "dash.dash_part_01.Material14130")
			elseif element == "help" then
				table.insert(frameElement[element .. "Materials"], "info.icon_help.Material")
			end
			frameElement[element .. "ButtonShown"] = false
			frameElement.standardButtonState[element] = {
				["mouseClick"] = false,
				["mouseOver"]  = false,
				["curSlide"]   = ""
			}

			registerForEvent("onMouseClick",       frameElement[element .. "Element"], function (...) return widgetSystem.onMouseClickStandardButton(element, ...) end)
			registerForEvent("onMouseDown",        frameElement[element .. "Element"], function (...) return widgetSystem.onMouseDownStandardButton(element, ...) end)
			registerForEvent("onMouseUp",          frameElement[element .. "Element"], function (...) return widgetSystem.onMouseUpStandardButton(element, ...) end)
			registerForEvent("onGroupedMouseOver", frameElement[element .. "Element"], function (...) return widgetSystem.onMouseOverStandardButton(element, ...) end)
			registerForEvent("onGroupedMouseOut",  frameElement[element .. "Element"], function (...) return widgetSystem.onMouseOutStandardButton(element, ...) end)

			RegisterMouseInteractions(frameElement[element .. "Element"])
		end
	end
end

function widgetSystem.initializeGraphElements()
	for count = 1, config.graph.maxElements do
		local graphElement = {}
		graphElement["mainElement"] = clone(private.master.graph, "graph"..count)

		local color = Color["graph_selection"]
		local selectionElement = getElement("selection", graphElement.mainElement)
		for i, element in ipairs(config.graph.selectionElements) do
			local material = getElement(element .. ".Material723", selectionElement)
			SetDiffuseColor(material, color.r, color.g, color.b)
			setAttribute(material, "opacity", color.a)
			setAttribute(material, "glowfactor", color.a)
		end

		RegisterMouseInteractions(graphElement.mainElement)
		graphElement["tickElements"] = {}
		for tickCount = 1, config.graph.maxTicksPerElement do
			table.insert(graphElement["tickElements"], clone(private.master.graphTick, "graphTick"..tickCount))
		end
		graphElement["dataPointElements"] = {}
		for datapointCount = 1, config.graph.maxDataPointsPerElement do
			local dataPointElement = clone(private.master.graphDataPoint, "graphDataPoint"..datapointCount)
			table.insert(graphElement["dataPointElements"], dataPointElement)

			local marker1 = getElement("marker1", dataPointElement)
			local marker2 = getElement("marker2", dataPointElement)

			registerForEvent("onGroupedMouseOver", marker1, widgetSystem.onMouseOverGraphDataPoint)
			registerForEvent("onGroupedMouseOut",  marker1, widgetSystem.onMouseOutGraphDataPoint)
			registerForEvent("onGroupedMouseOver", marker2, widgetSystem.onMouseOverGraphDataPoint)
			registerForEvent("onGroupedMouseOut",  marker2, widgetSystem.onMouseOutGraphDataPoint)
			registerForEvent("onMouseClick",       marker1, widgetSystem.onMouseClickGraphDataPoint)
			registerForEvent("onMouseClick",       marker2, widgetSystem.onMouseClickGraphDataPoint)

			RegisterMouseInteractions(marker1)
			RegisterMouseInteractions(marker2)
		end
		graphElement["iconElements"] = {}
		for iconCount = 1, config.graph.maxIconsPerElement do
			local iconElement = clone(private.master.graphIcon, "graphIcon"..iconCount)
			table.insert(graphElement["iconElements"], iconElement)

			registerForEvent("onGroupedMouseOver", iconElement, widgetSystem.onMouseOverGraphIcon)
			registerForEvent("onGroupedMouseOut",  iconElement, widgetSystem.onMouseOutGraphIcon)

			RegisterMouseInteractions(iconElement)
		end
		table.insert(private.element.graph, graphElement)
	end
end

function widgetSystem.initializeHelpOverlayElements()
	for count = 1, config.helpoverlay.maxElements do
		local helpOverlayElement = clone(private.master.helpOverlay, "helpoverlay"..count)
		table.insert(private.element.helpoverlay, helpOverlayElement)

		local background = getElement("background", helpOverlayElement)
		registerForEvent("onGroupedMouseOver", background, widgetSystem.onMouseOverHelpOverlay)
		registerForEvent("onGroupedMouseOut",  background, widgetSystem.onMouseOutHelpOverlay)
		registerForEvent("onMouseClick",       background, widgetSystem.onMouseClickHelpOverlay)
		local icon = getElement("icon", helpOverlayElement)
		registerForEvent("onGroupedMouseOver", icon, widgetSystem.onMouseOverHelpOverlay)
		registerForEvent("onGroupedMouseOut",  icon, widgetSystem.onMouseOutHelpOverlay)
		registerForEvent("onMouseClick",       icon, widgetSystem.onMouseClickHelpOverlay)

		RegisterMouseInteractions(helpOverlayElement)
	end
end

function widgetSystem.initializeIconElements()
	-- Partially deferred initialization
	local initializer = function(index)
		return clone(private.master.icon, "icon"..index)
	end
	widgetSystem.addDeferredElementInitializer("icon", initializer, config.icon.initPrecedence, config.icon.maxElements, config.icon.maxElementsInit, config.icon.numInitPerFrame)
end

function widgetSystem.initializeMiniWidgetSystemElements()
	private.element.miniWidgetSystem.frames[1] = {}
	local frameElement = private.element.miniWidgetSystem.frames[1]

	frameElement.layer = 1

	frameElement.tables = {}
	frameElement.rendertargets = {}
	frameElement.flowcharts = {}
		
	-- backgrounds & overlay
	for _, type in ipairs(config.frame.backgroundElements) do
		frameElement[type] = clone(private.master.miniWidgetSystem[type], "miniWidgetSystemframe"..type)
		widgetSystem.moveAnarkElementFrameLayer(frameElement, frameElement[type], 1)
		frameElement[type .. "Icon"] = getElement(type .. ".Material642." .. config.frame.backgroundElementTextures[type], frameElement[type])
		frameElement[type .. "Data"] = {}
	end

	-- brackets
	frameElement.bracketsElement = clone(private.master.miniWidgetSystem.frame_brackets, "miniWidgetSystemframe".."brackets")
	widgetSystem.moveAnarkElementFrameLayer(frameElement, frameElement.bracketsElement, 1)

	-- to prevent mouse clicks on frames behind this one if they are occluded by the background
	RegisterMouseInteractions(frameElement.backgroundTexture)

	-- standard buttons
	frameElement.standardButtons = clone(private.master.miniWidgetSystem.standardButtons, "miniWidgetSystemframe".."standardButtons")
	widgetSystem.moveAnarkElementFrameLayer(frameElement, frameElement.standardButtons, 1)
	frameElement.standardButtonState = {}

	for _, element in ipairs(config.frame.standardButtonOrder) do
		frameElement[element .. "Element"] = getElement(element, frameElement.standardButtons)
		frameElement[element .. "Materials"] = {}
		if element == "close" then
			table.insert(frameElement[element .. "Materials"], "cross.x_part_01.Material8561")
			table.insert(frameElement[element .. "Materials"], "cross.x_part_02.Material8561")
		elseif element == "back" then
			table.insert(frameElement[element .. "Materials"], "arrow.arrow_part_01.Material14115")
			table.insert(frameElement[element .. "Materials"], "arrow.arrow_part_02.Material14115")
		elseif element == "minimize" then
			table.insert(frameElement[element .. "Materials"], "dash.dash_part_01.Material14130")
		elseif element == "help" then
			table.insert(frameElement[element .. "Materials"], "info.icon_help.Material")
		end
		frameElement[element .. "ButtonShown"] = false
		frameElement.standardButtonState[element] = {
			["mouseClick"] = false,
			["mouseOver"]  = false,
			["curSlide"]   = ""
		}

		registerForEvent("onMouseClick",       frameElement[element .. "Element"], function (...) return widgetSystem.onMouseClickStandardButton(element, ...) end)
		registerForEvent("onMouseDown",        frameElement[element .. "Element"], function (...) return widgetSystem.onMouseDownStandardButton(element, ...) end)
		registerForEvent("onMouseUp",          frameElement[element .. "Element"], function (...) return widgetSystem.onMouseUpStandardButton(element, ...) end)
		registerForEvent("onGroupedMouseOver", frameElement[element .. "Element"], function (...) return widgetSystem.onMouseOverStandardButton(element, ...) end)
		registerForEvent("onGroupedMouseOut",  frameElement[element .. "Element"], function (...) return widgetSystem.onMouseOutStandardButton(element, ...) end)

		RegisterMouseInteractions(frameElement[element .. "Element"])
	end

	for tableindex = 1, config.miniWidgetsystem.maxTables do
		private.element.miniWidgetSystem.table[tableindex] = {}
		local tableElement = private.element.miniWidgetSystem.table[tableindex]
		tableElement.header = clone(private.master.miniWidgetSystem.table.header, "table"..tableindex.."header")
		tableElement.headerText = getElement("Text", tableElement.header)
		tableElement.scrollBar = {
			["sliderState"] = {
				["mouseClick"] = false,
				["mouseOver"]  = false,
				["gamepadFocus"] = false,
				["curSlide"]   = "inactive"
			}
		}
		tableElement.scrollBar.element = clone(private.master.miniWidgetSystem.table.scrollBar, "table"..tableindex.."scrollbar")
		tableElement.scrollBar.sliderElement = getElement("slider", tableElement.scrollBar.element)
		tableElement.mousePick = {
			["state"] = {
				["mouseOver"]  = {
					["state"] = false,
					-- ["original"] = nil,
					-- ["row"] = nil
				}
			}
		}
		tableElement.mousePick.element = clone(private.master.miniWidgetSystem.table.mousePick, "table"..tableindex.."mousepick")
		tableElement.borderElements = {}
		tableElement.borderElements.highlightElement = clone(private.master.miniWidgetSystem.table.highlight, "table"..tableindex.."highlight")
		for _, entry in ipairs(config.table.borderElements) do
			tableElement.borderElements[entry] = getElement(entry, tableElement.borderElements.highlightElement)
		end
		tableElement.cell = {}

		-- initialize for mouse interactions
		local backgroundSliderBar = getElement("background", tableElement.scrollBar.element)
		local sliderBar = tableElement.scrollBar.sliderElement
		local mousePick = tableElement.mousePick.element
		registerForEvent("onMouseClick",       backgroundSliderBar, widgetSystem.onMouseClickPageScroll)
		registerForEvent("onMouseDblClick",    backgroundSliderBar, widgetSystem.onMouseClickPageScroll)
		registerForEvent("onMouseDown",        sliderBar,           widgetSystem.onMouseStartScrollBarDrag)
		registerForEvent("onMouseUp",          sliderBar,           widgetSystem.onMouseStopScrollBarDrag)
		registerForEvent("onGroupedMouseOver", sliderBar,           widgetSystem.onMouseOverTableScrollBar)
		registerForEvent("onGroupedMouseOut",  sliderBar,           widgetSystem.onMouseOutTableScrollBar)
		registerForEvent("onGroupedMouseOver", mousePick,           widgetSystem.onMouseOverTable)
		registerForEvent("onGroupedMouseOut",  mousePick,           widgetSystem.onMouseOutTable)
		RegisterMouseInteractions(backgroundSliderBar)
		-- note the slider must not only be registered for mouse interactions for dragging/dropping support, but rather also so it obstructs clicks on the backgroundSliderBar behind the slider
		RegisterMouseInteractions(sliderBar)
		RegisterMouseInteractions(mousePick)
	end

	for rowIndex = 1, config.miniWidgetsystem.maxRows do
		private.element.miniWidgetSystem.tableRows[rowIndex] = {}
		for colIndex = 1, config.tableRows.maxCols do 
			local cellelement = clone(private.master.miniWidgetSystem.table.cell, "row"..rowIndex.."col"..colIndex)
			private.element.miniWidgetSystem.tableRows[rowIndex][colIndex] = {
				["element"] = cellelement
			}
			registerForEvent("onMouseClick",       cellelement, function (...) return widgetSystem.onMouseClickTableCell(false, ...) end)
			registerForEvent("onMouseDblClick",    cellelement, function (...) return widgetSystem.onMouseClickTableCell(true, ...) end)
			registerForEvent("onGroupedMouseOver", cellelement, widgetSystem.onMouseOverTableCell)
			registerForEvent("onGroupedMouseOut",  cellelement, widgetSystem.onMouseOutTableCell)
			RegisterMouseInteractions(cellelement)
		end
	end
end

function widgetSystem.initializeShapeElements()
	for count = 1, config.shapes.rectangle.maxElements do
		table.insert(private.element.shapes.rectangle, {count, clone(private.master.shapeRectangle, "shapeRectangle"..count)})
	end

	for count = 1, config.shapes.circle.maxElements do
		table.insert(private.element.shapes.circle, {count, clone(private.master.shapeCircle, "shapeCircle"..count)})
	end

	for count = 1, config.shapes.triangle.maxElements do
		table.insert(private.element.shapes.triangle, {count, clone(private.master.shapeTriangle, "shapeTriangle"..count)})
	end
end

function widgetSystem.initializeSliderCellElements()
	for count = 1, config.slidercell.maxElements do
		local slidercellElement = {}
		slidercellElement.main = clone(private.master.slidercell, "slidercell"..count)
		slidercellElement.arrow_left = getElement("slider.slider.arrow_left", slidercellElement.main)
		slidercellElement.arrow_right = getElement("slider.slider.arrow_right", slidercellElement.main)
		slidercellElement.arrow_skip_left = getElement("slider.slider.arrow_skip_left", slidercellElement.main)
		slidercellElement.arrow_skip_right = getElement("slider.slider.arrow_skip_right", slidercellElement.main)
		table.insert(private.element.slidercell, slidercellElement)

		slidercellElement.sliderArrowState = {
			["left"] = {
				["element"]    = slidercellElement.arrow_left,
				["curSlide"]   = "inactive",
				["mouseDown"] = false,
				["mouseOver"]  = false
			},
			["right"] = {
				["element"]    = slidercellElement.arrow_right,
				["curSlide"]   = "inactive",
				["mouseDown"] = false,
				["mouseOver"]  = false
			},
			["skip_left"] = {
				["element"]    = slidercellElement.arrow_skip_left,
				["curSlide"]   = "inactive",
				["mouseDown"] = false,
				["mouseOver"]  = false
			},
			["skip_right"] = {
				["element"]    = slidercellElement.arrow_skip_right,
				["curSlide"]   = "inactive",
				["mouseDown"] = false,
				["mouseOver"]  = false
			},
		}

		local backgroundElement = getElement("slider.elements.Rectangle_background", slidercellElement.main)
		local numberElement = getElement("slider.elements.Rectangle_values", slidercellElement.main)

		-- register for mouse interactions
		registerForEvent("onMouseClick",       numberElement,                      widgetSystem.onMouseClickSliderCellNumber)
		registerForEvent("onGroupedMouseOver", numberElement,                      widgetSystem.onMouseOverSliderCellNumber)
		registerForEvent("onGroupedMouseOut",  numberElement,                      widgetSystem.onMouseOutSliderCellNumber)
		registerForEvent("onMouseDown",        backgroundElement,                  widgetSystem.onMouseDownSliderCell)
		registerForEvent("onMouseUp",          backgroundElement,                  widgetSystem.onMouseUpSliderCell)
		registerForEvent("onGroupedMouseOver", backgroundElement,                  widgetSystem.onMouseOverSliderCell)
		registerForEvent("onGroupedMouseOut",  backgroundElement,                  widgetSystem.onMouseOutSliderCell)
		registerForEvent("onMouseDown",        slidercellElement.arrow_left,       widgetSystem.onMouseDownSliderCellArrowLeft)
		registerForEvent("onMouseDown",        slidercellElement.arrow_right,      widgetSystem.onMouseDownSliderCellArrowRight)
		registerForEvent("onMouseDown",        slidercellElement.arrow_skip_left,  widgetSystem.onMouseDownSliderCellArrowSkipLeft)
		registerForEvent("onMouseDown",        slidercellElement.arrow_skip_right, widgetSystem.onMouseDownSliderCellArrowSkipRight)
		registerForEvent("onMouseUp",          slidercellElement.arrow_left,       widgetSystem.onMouseUpSliderCellArrowLeft)
		registerForEvent("onMouseUp",          slidercellElement.arrow_right,      widgetSystem.onMouseUpSliderCellArrowRight)
		registerForEvent("onMouseUp",          slidercellElement.arrow_skip_left,  widgetSystem.onMouseUpSliderCellArrowSkipLeft)
		registerForEvent("onMouseUp",          slidercellElement.arrow_skip_right, widgetSystem.onMouseUpSliderCellArrowSkipRight)
		registerForEvent("onGroupedMouseOver", slidercellElement.arrow_left,       widgetSystem.onMouseOverSliderCellArrowLeft)
		registerForEvent("onGroupedMouseOver", slidercellElement.arrow_right,      widgetSystem.onMouseOverSliderCellArrowRight)
		registerForEvent("onGroupedMouseOver", slidercellElement.arrow_skip_left,  widgetSystem.onMouseOverSliderCellArrowSkipLeft)
		registerForEvent("onGroupedMouseOver", slidercellElement.arrow_skip_right, widgetSystem.onMouseOverSliderCellArrowSkipRight)
		registerForEvent("onGroupedMouseOut",  slidercellElement.arrow_left,       widgetSystem.onMouseOutSliderCellArrowLeft)
		registerForEvent("onGroupedMouseOut",  slidercellElement.arrow_right,      widgetSystem.onMouseOutSliderCellArrowRight)
		registerForEvent("onGroupedMouseOut",  slidercellElement.arrow_skip_left,  widgetSystem.onMouseOutSliderCellArrowSkipLeft)
		registerForEvent("onGroupedMouseOut",  slidercellElement.arrow_skip_right, widgetSystem.onMouseOutSliderCellArrowSkipRight)
		registerForEvent("onRightMouseClick",  slidercellElement.main,             widgetSystem.onRightMouseClickSliderCell)
		RegisterMouseInteractions(backgroundElement)
		RegisterMouseInteractions(numberElement)
		RegisterMouseInteractions(slidercellElement.arrow_left)
		RegisterMouseInteractions(slidercellElement.arrow_right)
		RegisterMouseInteractions(slidercellElement.arrow_skip_left)
		RegisterMouseInteractions(slidercellElement.arrow_skip_right)
	end
end

function widgetSystem.initializeShieldHullBarElements()
	for count = 1, config.shieldhullbar.maxElements do
		local shieldHullBarElement = clone(private.master.shieldhullbar, "shieldhullbar"..count)
		table.insert(private.element.shieldhullbar, shieldHullBarElement)

		local color = Color["shieldhullbar_shield"]
		local material = getElement("top.material", shieldHullBarElement)
		SetDiffuseColor(material, color.r, color.g, color.b)
		setAttribute(material, "opacity", color.a)
		local color = Color["shieldhullbar_hull"]
		local material = getElement("bottom.material", shieldHullBarElement)
		SetDiffuseColor(material, color.r, color.g, color.b)
		setAttribute(material, "opacity", color.a)
	end
end

function widgetSystem.initializeStatusBarElements()
	for count = 1, config.statusbar.maxElements do
		local statusBarElement = {}
		statusBarElement.element = clone(private.master.statusbar, "statusbar"..count)
		table.insert(private.element.statusbar, statusBarElement)
	end
end

function widgetSystem.initializeFlowchartElements()
	-- flowchart backgrounds
	for count = 1, config.flowchart.maxFlowcharts do
		local flowchartElement = {}
		table.insert(private.element.flowchart, flowchartElement)

		flowchartElement.headerBackground = clone(private.master.flowchart_background, "flowchart_background_header")
		flowchartElement.footerBackground = clone(private.master.flowchart_background, "flowchart_background_footer")
		flowchartElement.columnBackgrounds = { }
		for count = 1, config.flowchart.maxCols do
			table.insert(flowchartElement.columnBackgrounds, clone(private.master.flowchart_background, "flowchart_background_col"..count))
		end

		-- flowchart scrollbars
		flowchartElement.scrollBars = { vertical = { }, horizontal = { } }
		for scrolltype, scrollbar in pairs(flowchartElement.scrollBars) do
			scrollbar["sliderState"] = {
				["mouseClick"] = false,
				["mouseOver"]  = false,
				["gamepadFocus"] = false,
				["curSlide"]   = "inactive"
			}
			scrollbar.type = scrolltype
			-- just use the master element for the table scrollbar
			scrollbar.element = clone(private.master.table.scrollBar)
			scrollbar.sliderElement = getElement("slider", scrollbar.element)

			local backgroundSliderBar = getElement("background", scrollbar.element)
			local sliderBar = scrollbar.sliderElement
			registerForEvent("onMouseClick",       backgroundSliderBar, widgetSystem.onMouseClickFlowchartPageScroll)
			registerForEvent("onMouseDblClick",    backgroundSliderBar, widgetSystem.onMouseClickFlowchartPageScroll)
			registerForEvent("onMouseDown",        sliderBar,           widgetSystem.onMouseStartFlowchartScrollBarDrag)
			registerForEvent("onMouseUp",          sliderBar,           widgetSystem.onMouseStopFlowchartScrollBarDrag)
			registerForEvent("onGroupedMouseOver", sliderBar,           widgetSystem.onMouseOverFlowchartScrollBar)
			registerForEvent("onGroupedMouseOut",  sliderBar,           widgetSystem.onMouseOutFlowchartScrollBar)
			RegisterMouseInteractions(backgroundSliderBar)
			-- note the slider must not only be registered for mouse interactions for dragging/dropping support, but rather also so it obstructs clicks on the backgroundSliderBar behind the slider
			RegisterMouseInteractions(sliderBar)
		end

		flowchartElement.mousePick = {
			["state"] = {
				["mouseOver"]  = {
					["state"] = false,
				}
			}
		}
		local mousePick = clone(private.master.table.mousePick, "flowchart"..count.."mousepick")
		flowchartElement.mousePick.element = mousePick
		registerForEvent("onMouseClick",       mousePick,				widgetSystem.onMouseClickFlowchartBackground)
		registerForEvent("onMouseDblClick",    mousePick,				widgetSystem.onMouseClickFlowchartBackground)
		registerForEvent("onGroupedMouseOver", mousePick,               widgetSystem.onMouseOverFlowchart)
		registerForEvent("onGroupedMouseOut",  mousePick,               widgetSystem.onMouseOutFlowchart)
		-- TODO: onMouseOver/OutFlowchart
		RegisterMouseInteractions(mousePick)
	end

	-- flowchart nodes
	for count = 1, config.flowchart.maxNodes do
		local flowchartNodeElement = {}
		table.insert(private.element.flowchartNode, flowchartNodeElement)

		flowchartNodeElement.main = clone(private.master.flowchart_node, "flowchart_node"..count)
		-- sub-components
		flowchartNodeElement.mousepick = getElement("mousepick", flowchartNodeElement.main)
		flowchartNodeElement.leftBorder = getElement("leftBorder", flowchartNodeElement.main)
		flowchartNodeElement.rightBorder = getElement("rightBorder", flowchartNodeElement.main)
		flowchartNodeElement.expand = getElement("expand", flowchartNodeElement.main)
		flowchartNodeElement.expandArrow = getElement("expand.lso_arrow", flowchartNodeElement.main)
		flowchartNodeElement.status = getElement("status", flowchartNodeElement.main)
		flowchartNodeElement.connectors = getElement("connectors", flowchartNodeElement.main)
		flowchartNodeElement.leftBorderExpandedFrameLayer = getElement("expandedFrameLayer", flowchartNodeElement.leftBorder)
		flowchartNodeElement.rightBorderExpandedFrameLayer = getElement("expandedFrameLayer", flowchartNodeElement.rightBorder)

		flowchartNodeElement.barData = {
			{
				element = getElement("bar1", flowchartNodeElement.main),
				sliderHandleElement = getElement("bar1.lso_triangle", flowchartNodeElement.main),
				sliderMousepick = getElement("bar1.mousepick", flowchartNodeElement.main),
				assignedSliderIndex = nil
			},
			{
				element = getElement("bar2", flowchartNodeElement.main),
				sliderHandleElement = getElement("bar2.lso_triangle", flowchartNodeElement.main),
				sliderMousepick = getElement("bar2.mousepick", flowchartNodeElement.main),
				assignedSliderIndex = nil
			},
			{
				element = getElement("bar3", flowchartNodeElement.main)
				-- no slider supported
			}
		}
		flowchartNodeElement.sliderStates = {
			[1] = {
				barIndex       = nil,
				mouseDown      = false,
				mouseOver      = false
			},
			[2] = {
				barIndex       = nil,
				mouseDown      = false,
				mouseOver      = false
			}
		}

		flowchartNodeElement.bar1SliderMousepick = flowchartNodeElement.barData[1].sliderMousepick
		flowchartNodeElement.bar2SliderMousepick = flowchartNodeElement.barData[2].sliderMousepick

		-- Clicking anywhere in the flowchart node should expand and collapse it - use mousepick element
		registerForEvent("onMouseClick",       flowchartNodeElement.mousepick, function (...) return widgetSystem.onMouseClickFlowchartNode("mousepick", ...) end)
		registerForEvent("onMouseDblClick",    flowchartNodeElement.mousepick, function (...) return widgetSystem.onMouseClickFlowchartNode("mousepick", ...) end)
		registerForEvent("onGroupedMouseOver", flowchartNodeElement.mousepick, widgetSystem.onMouseOverFlowchartNode)
		registerForEvent("onGroupedMouseOut",  flowchartNodeElement.mousepick, widgetSystem.onMouseOutFlowchartNode)
		RegisterMouseInteractions(flowchartNodeElement.mousepick)

		registerForEvent("onMouseDown",        flowchartNodeElement.bar1SliderMousepick, widgetSystem.onMouseStartFlowchartNodeSliderDrag1)
		registerForEvent("onMouseUp",          flowchartNodeElement.bar1SliderMousepick, widgetSystem.onMouseStopFlowchartNodeSliderDrag1)
		registerForEvent("onGroupedMouseOver", flowchartNodeElement.bar1SliderMousepick, widgetSystem.onMouseOverFlowchartNodeSlider1)
		registerForEvent("onGroupedMouseOut",  flowchartNodeElement.bar1SliderMousepick, widgetSystem.onMouseOutFlowchartNodeSlider1)
		RegisterMouseInteractions(flowchartNodeElement.bar1SliderMousepick)

		registerForEvent("onMouseDown",        flowchartNodeElement.bar2SliderMousepick, widgetSystem.onMouseStartFlowchartNodeSliderDrag2)
		registerForEvent("onMouseUp",          flowchartNodeElement.bar2SliderMousepick, widgetSystem.onMouseStopFlowchartNodeSliderDrag2)
		registerForEvent("onGroupedMouseOver", flowchartNodeElement.bar2SliderMousepick, widgetSystem.onMouseOverFlowchartNodeSlider2)
		registerForEvent("onGroupedMouseOut",  flowchartNodeElement.bar2SliderMousepick, widgetSystem.onMouseOutFlowchartNodeSlider2)
		RegisterMouseInteractions(flowchartNodeElement.bar2SliderMousepick)

		flowchartNodeElement.statusIcon = getElement("icon", flowchartNodeElement.status)
		registerForEvent("onMouseClick",       flowchartNodeElement.statusIcon, function (...) return widgetSystem.onMouseClickFlowchartNode("statusIcon", ...) end)
		registerForEvent("onMouseDblClick",    flowchartNodeElement.statusIcon, function (...) return widgetSystem.onMouseClickFlowchartNode("statusIcon", ...) end)
		registerForEvent("onGroupedMouseOver", flowchartNodeElement.statusIcon, widgetSystem.onMouseOverFlowchartNodeStatusIcon)
		registerForEvent("onGroupedMouseOut",  flowchartNodeElement.statusIcon, widgetSystem.onMouseOutFlowchartNodeStatusIcon)
		RegisterMouseInteractions(flowchartNodeElement.statusIcon)
	end

	-- flowchart edges
	for count = 1, config.flowchart.maxEdges do
		local flowchartEdgeElement = clone(private.master.flowchart_edge, "flowchart_edge"..count)
		table.insert(private.element.flowchartEdge, flowchartEdgeElement)
	end
end

function widgetSystem.onMouseClickFlowchartBackground(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end
	local flowchartElement, frameElement = widgetSystem.getFlowchartElementByMousePick(anarkElement)
	if flowchartElement and IsValidWidgetElement(flowchartElement.data.id) then
		widgetSystem.onMouseClickCommon(frameElement)
	end
end

function widgetSystem.onMouseOverFlowchart(anarkElement)
	local flowchartElement = widgetSystem.getFlowchartElementByMousePick(anarkElement)
	if flowchartElement then
		flowchartElement.mousePick.state["mouseOver"].state = true
	end
end

function widgetSystem.onMouseOutFlowchart(anarkElement)
	local flowchartElement = widgetSystem.getFlowchartElementByMousePick(anarkElement)
	if flowchartElement then
		flowchartElement.mousePick.state["mouseOver"].state = false
	end
end

function widgetSystem.getFlowchartElementByMousePick(anarkElement)
	-- check all flowcharts
	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		if frameElement then
			for _, flowchartElement in ipairs(frameElement.flowcharts) do
				if flowchartElement.mousePick.element == anarkElement then
					return flowchartElement, frameElement
				end
			end
		end
	end
	-- otherwise return nil
end

function widgetSystem.onMouseClickFlowchartNode(elementType, anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end
	local flowchartNodeElement, _, frameElement = widgetSystem.getFlowchartNodeElementByAnarkElement(elementType, anarkElement)
	if flowchartNodeElement and IsValidWidgetElement(flowchartNodeElement.cell.id) then
		widgetSystem.onMouseClickCommon(frameElement)

		local node = flowchartNodeElement.cell
		if node.expandedframeid then
			CallWidgetEventScripts(node.id, "onFlowchartNodeCollapsed")
		elseif node.expandable then
			CallWidgetEventScripts(node.id, "onFlowchartNodeExpanded")
		end
	end
end

function widgetSystem.onMouseOverFlowchartNode(anarkElement)
	local flowchartNodeElement, flowchartElement, frameElement = widgetSystem.getFlowchartNodeElementByAnarkElement("mousepick", anarkElement)
	if flowchartNodeElement then
		flowchartElement.mousePick.state["mouseOver"].state = true
		-- scale the child element expandArrow, because the expand element itself already has custom scaling
		local scale = config.flowchart.expandMouseOverScaleFactor
		widgetSystem.setElementScale(flowchartNodeElement.expandArrow, scale, scale)
	end
end

function widgetSystem.onMouseOutFlowchartNode(anarkElement)
	local flowchartNodeElement, flowchartElement, frameElement = widgetSystem.getFlowchartNodeElementByAnarkElement("mousepick", anarkElement)
	if flowchartNodeElement then
		flowchartElement.mousePick.state["mouseOver"].state = false
		widgetSystem.setElementScale(flowchartNodeElement.expandArrow, 1.0, 1.0)
	end
end

function widgetSystem.getFlowchartNodeElementByAnarkElement(elementType, anarkElement)
	-- check all flowchart nodes
	-- elementType can be one of: "main", "mousepick", "leftBorder", "rightBorder", "expand", "status", "connectors", "bar1SliderMousepick", "bar2SliderMousepick", "statusIcon"
	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		for _, flowchartElement in ipairs(frameElement.flowcharts) do
			for _, rowentry in ipairs(flowchartElement.data.cells) do
				for _, cell in ipairs(rowentry) do
					if cell and cell.nodeElement and cell.nodeElement[elementType] == anarkElement then
						return cell.nodeElement, flowchartElement, frameElement
					end
				end
			end
		end
	end
	-- otherwise return nil
end

-- flowchartnode sliders

function widgetSystem.updateFlowchartNodeSliderPos()
	local flowchartNodeElement = private.flowchartNodeSliderDrag.element
	local node = flowchartNodeElement.cell
	local slideridx = private.flowchartNodeSliderDrag.slideridx

	local x = GetLocalMousePosition()
	if x == nil then
		return -- outside the widget frame
	end

	local width, height = GetSize(node.id)
	local scalefactor = height / config.flowchart.baseModelHeight
	local bordershape = config.flowchart.borderShapeData[node.shape]
	local outlinewidth = config.flowchart.baseModelOutlineSize * scalefactor
	local borderwidth = bordershape.baseWidth * scalefactor
	local middlewidth = width - 2 * borderwidth
	local maxbarwidth = middlewidth
	if bordershape.slide == "rectangle" then
		maxbarwidth = maxbarwidth + 2 * (borderwidth - outlinewidth)
	end
	if maxbarwidth <= 0 then
		return
	end
	local valuediff = (x - private.flowchartNodeSliderDrag.startX) * node.scale.max / maxbarwidth
	valuediff = (valuediff > 0 and math.floor(valuediff) or math.ceil(valuediff))
	local newvalue = math.max(0, math.min(private.flowchartNodeSliderDrag.startValue + valuediff, node.scale.max))
	-- setting the slider value causes the flowchartnode to be fully redrawn, so we don't have to update the slider position here.
	-- a full update is necessary anyway because the green/brown bars move together with the sliders.
	if slideridx == 1 then
		if node.scale.slider1 ~= newvalue then
			node.scale.slider1 = newvalue
			C.SetFlowChartNodeSlider1Value(node.id, newvalue)
			CallWidgetEventScripts(node.id, "onFlowchartNodeSliderChanged", 1, newvalue)
		end
	else
		if node.scale.slider2 ~= newvalue then
			node.scale.slider2 = newvalue
			C.SetFlowChartNodeSlider2Value(node.id, newvalue)
			CallWidgetEventScripts(node.id, "onFlowchartNodeSliderChanged", 2, newvalue)
		end
	end
end

function widgetSystem.setFlowchartNodeSliderState(flowchartNodeElement, slideridx, state, value)
	local statedata = flowchartNodeElement.sliderStates[slideridx]
	if statedata.barIndex then
		statedata[state] = value
		widgetSystem.updateFlowchartNodeSliderColor(flowchartNodeElement, slideridx)
	end
end

function widgetSystem.updateFlowchartNodeSliderColor(flowchartNodeElement, slideridx)
	local statedata = flowchartNodeElement.sliderStates[slideridx]
	if statedata.barIndex then
		local node = flowchartNodeElement.cell
		local color = slideridx == 1 and node.colors.slider1 or node.colors.slider2
		if statedata.mouseDown then
			color = Color["flowchart_slider_mousedown"]
		elseif statedata.mouseOver then
			color = widgetSystem.interpolateColor(color, Color["flowchart_slider_mousedown"], 0.5)
		end
		local material = getElement("lso_triangle.lso_triangle.Material", flowchartNodeElement.barData[statedata.barIndex].element)
		widgetSystem.setElementColorAlpha(material, color)
	end
end

function widgetSystem.onMouseStartFlowchartNodeSliderDrag1(anarkElement) widgetSystem.onMouseStartFlowchartNodeSliderDrag(anarkElement, "bar1SliderMousepick", 1) end
function widgetSystem.onMouseStartFlowchartNodeSliderDrag2(anarkElement) widgetSystem.onMouseStartFlowchartNodeSliderDrag(anarkElement, "bar2SliderMousepick", 2) end
function widgetSystem.onMouseStopFlowchartNodeSliderDrag1(anarkElement) widgetSystem.onMouseStopFlowchartNodeSliderDrag(anarkElement, "bar1SliderMousepick", 1) end
function widgetSystem.onMouseStopFlowchartNodeSliderDrag2(anarkElement) widgetSystem.onMouseStopFlowchartNodeSliderDrag(anarkElement, "bar2SliderMousepick", 2) end
function widgetSystem.onMouseOverFlowchartNodeSlider1(anarkElement) widgetSystem.onMouseOverFlowchartNodeSlider(anarkElement, "bar1SliderMousepick", 1) end
function widgetSystem.onMouseOverFlowchartNodeSlider2(anarkElement) widgetSystem.onMouseOverFlowchartNodeSlider(anarkElement, "bar2SliderMousepick", 2) end
function widgetSystem.onMouseOutFlowchartNodeSlider1(anarkElement) widgetSystem.onMouseOutFlowchartNodeSlider(anarkElement, "bar1SliderMousepick", 1) end
function widgetSystem.onMouseOutFlowchartNodeSlider2(anarkElement) widgetSystem.onMouseOutFlowchartNodeSlider(anarkElement, "bar2SliderMousepick", 2) end

function widgetSystem.onMouseStartFlowchartNodeSliderDrag(anarkElement, elementType, barIndex)
	local flowchartNodeElement, flowchartElement, frameElement = widgetSystem.getFlowchartNodeElementByAnarkElement(elementType, anarkElement)
	if flowchartNodeElement then
		local slideridx = flowchartNodeElement.barData[barIndex].assignedSliderIndex
		if slideridx then
			 widgetSystem.startFlowchartNodeSliderDrag(flowchartNodeElement, slideridx)
		end
	end
end

function widgetSystem.startFlowchartNodeSliderDrag(flowchartNodeElement, slideridx)
	widgetSystem.setFlowchartNodeSliderState(flowchartNodeElement, slideridx, "mouseDown", true)
	widgetSystem.setMouseCursorOverrideInternalDrag("slider")
	local node = flowchartNodeElement.cell
	local slidervalue = slideridx == 1 and node.scale.slider1 or node.scale.slider2
	local mouseX = GetLocalMousePosition()
	private.flowchartNodeSliderDrag = { element = flowchartNodeElement, slideridx = slideridx, startValue = slidervalue, startX = mouseX }
	CallWidgetEventScripts(node.id, "onFlowchartNodeSliderActivated", slideridx)
end

function widgetSystem.onMouseStopFlowchartNodeSliderDrag(anarkElement, elementType, barIndex)
	local flowchartNodeElement, flowchartElement, frameElement = widgetSystem.getFlowchartNodeElementByAnarkElement(elementType, anarkElement)
	if flowchartNodeElement then
		local slideridx = flowchartNodeElement.barData[barIndex].assignedSliderIndex
		if slideridx then
			widgetSystem.stopFlowchartNodeSliderDrag(flowchartNodeElement, slideridx)
		end
	end
end

function widgetSystem.stopFlowchartNodeSliderDrag(flowchartNodeElement, slideridx)
	widgetSystem.setFlowchartNodeSliderState(flowchartNodeElement, slideridx, "mouseDown", false)
	widgetSystem.setMouseCursorOverrideInternalDrag()
	local node = flowchartNodeElement.cell
	private.flowchartNodeSliderDrag = nil
	CallWidgetEventScripts(node.id, "onFlowchartNodeSliderDeactivated", slideridx)
end

function widgetSystem.onMouseOverFlowchartNodeSlider(anarkElement, elementType, barIndex)
	local flowchartNodeElement, flowchartElement, frameElement = widgetSystem.getFlowchartNodeElementByAnarkElement(elementType, anarkElement)
	if flowchartNodeElement then
		flowchartElement.mousePick.state["mouseOver"].state = true

		local slideridx = flowchartNodeElement.barData[barIndex].assignedSliderIndex
		if slideridx then
			widgetSystem.setFlowchartNodeSliderState(flowchartNodeElement, slideridx, "mouseOver", true)
			widgetSystem.setMouseCursorOverrideInternal("slider")

			local node = flowchartNodeElement.cell
			local mouseovertext = slideridx == 1 and (node.scale.slider1mouseovertext or "") or (node.scale.slider2mouseovertext or "")
			if mouseovertext ~= "" then
				widgetSystem.setMouseOverOverride(node.id, mouseovertext)
			end
		end
	end
end

function widgetSystem.onMouseOutFlowchartNodeSlider(anarkElement, elementType, barIndex)
	local flowchartNodeElement, flowchartElement, frameElement = widgetSystem.getFlowchartNodeElementByAnarkElement(elementType, anarkElement)
	if flowchartNodeElement then
		flowchartElement.mousePick.state["mouseOver"].state = false

		local slideridx = flowchartNodeElement.barData[barIndex].assignedSliderIndex
		if slideridx then
			widgetSystem.setFlowchartNodeSliderState(flowchartNodeElement, slideridx, "mouseOver", false)
			widgetSystem.setMouseCursorOverrideInternal()
			widgetSystem.setMouseOverOverride(flowchartNodeElement.cell.id, nil, true)
		end
	end
end

function widgetSystem.onMouseOverFlowchartNodeStatusIcon(anarkElement)
	local flowchartNodeElement, flowchartElement, frameElement = widgetSystem.getFlowchartNodeElementByAnarkElement("statusIcon", anarkElement)
	if flowchartNodeElement then
		flowchartElement.mousePick.state["mouseOver"].state = true

		-- scale the child element expandArrow, because the expand element itself already has custom scaling
		local scale = config.flowchart.expandMouseOverScaleFactor
		widgetSystem.setElementScale(flowchartNodeElement.expandArrow, scale, scale)

		local node = flowchartNodeElement.cell
		local mouseovertext = node.statusiconmouseovertext
		if mouseovertext ~= "" then
			widgetSystem.setMouseOverOverride(node.id, mouseovertext)
		end
	end
end

function widgetSystem.onMouseOutFlowchartNodeStatusIcon(anarkElement)
	local flowchartNodeElement, flowchartElement, frameElement = widgetSystem.getFlowchartNodeElementByAnarkElement("statusIcon", anarkElement)
	if flowchartNodeElement then
		flowchartElement.mousePick.state["mouseOver"].state = false

		widgetSystem.setElementScale(flowchartNodeElement.expandArrow, 1.0, 1.0)

		widgetSystem.setMouseOverOverride(flowchartNodeElement.cell.id, nil, true)
	end
end

-- flowchart scroll bars

function widgetSystem.onMouseClickFlowchartPageScroll(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local x, y = GetLocalMouseClickPosition()

	local anarkScrollBarElement = getElement("parent", anarkElement)
	local scrollbar, flowchartElement, frameElement = widgetSystem.getFlowchartScrollBarByAnarkElement(anarkScrollBarElement)

	if flowchartElement then
		widgetSystem.onMouseClickCommon(frameElement)

		if scrollbar.type == "vertical" then
			-- vertical scrollbar
			local sliderPosY = widgetSystem.getScrollBarSliderPosition(anarkScrollBarElement) + flowchartElement.data.offsety
			widgetSystem.scrollFlowchartVertically(flowchartElement, (y > sliderPosY) and -1 or 1, true)
		else
			-- horizontal scrollbar
			local sliderPosX = widgetSystem.getHorizontalScrollBarSliderPosition(anarkScrollBarElement) + flowchartElement.data.offsetx
			widgetSystem.scrollFlowchartHorizontally(flowchartElement, (x > sliderPosX) and 1 or -1, true)
		end
	end
end

function widgetSystem.onMouseOverFlowchartScrollBar(anarkElement)
	local anarkScrollBarElement = getElement("parent", anarkElement)
	local scrollbar, flowchartElement, frameElement = widgetSystem.getFlowchartScrollBarByAnarkElement(anarkScrollBarElement)

	if flowchartElement then
		flowchartElement.mousePick.state["mouseOver"].state = true
		widgetSystem.setScrollBarState(scrollbar, "mouseOver", true, flowchartElement.data.id)
	end
end

function widgetSystem.onMouseOutFlowchartScrollBar(anarkElement, delayed)
	local anarkScrollBarElement = getElement("parent", anarkElement)
	local scrollbar, flowchartElement, frameElement = widgetSystem.getFlowchartScrollBarByAnarkElement(anarkScrollBarElement)

	if flowchartElement then
		flowchartElement.mousePick.state["mouseOver"].state = false
		widgetSystem.setScrollBarState(scrollbar, "mouseOver", false, flowchartElement.data.id)
	end
end

function widgetSystem.getFlowchartScrollBarByAnarkElement(anarkElement)
	-- check all flowcharts
	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		for _, flowchartElement in ipairs(frameElement.flowcharts) do
			for scrolltype, scrollbar in pairs(flowchartElement.scrollBars) do
				if scrollbar.element == anarkElement then
					return scrollbar, flowchartElement, frameElement
				end
			end
		end
	end
	-- otherwise return nil
end

function widgetSystem.updateFlowchartScrollBarPos(flowchartElement, scrollbar)
	local x, y = GetLocalMousePosition()
	if not (x or y) then
		return -- outside the widget frame
	end

	if scrollbar.type == "vertical" then
		-- check whether the mouse cursor was moved by a relevant factor
		if scrollbar.previousMousePos ~= nil and math.abs(scrollbar.previousMousePos - y) < config.mouseScrollBarThreshold then
			return -- mouse hasn't been moved between previous and current call - no mouse change => nothing to do
		end

		-- Note: we must take into account whether the mouse was moved up or down here, since we actually do not perform pixel-exact scrolling of the slider.
		-- That means: The slider position always represents the current position of the table and we scroll the table already as if we'd have dragged the slider half way to the previous/next row.
		-- At that point the slider would jump and the drag position might be above/below the current mouse position. If we'd just compare the difference of the drag position the next time the mouse is moved up/down
		-- we could end up with incorrectly determining that we'd moved the bar down/up -> results in inversed scrollbar movement (was cause of XT-3967)
		local moveDown = scrollbar.previousMousePos ~= nil and scrollbar.previousMousePos > y

		scrollbar.previousMousePos = y

		local newSliderPos = y - scrollbar.dragOffset
		local curSliderPos = widgetSystem.getScrollBarSliderPosition(scrollbar.element)
		local valueDiff = newSliderPos - curSliderPos
		local pixelsToScroll = scrollbar.valuePerPixel * valueDiff

		local direction = (pixelsToScroll > 0 and not moveDown and -1) or (pixelsToScroll < 0 and moveDown and 1)
		if direction then
			local flowchartData = flowchartElement.data
			local row = flowchartData.firstVisibleRow
			local nextrow = flowchartData.firstVisibleRow
			local startoffset = flowchartData.rowYOffsets[row]
			repeat
				row = nextrow
				local nextscrollcount = widgetSystem.getFlowchartNumCellsToScroll(flowchartData.rowHeights, flowchartData.maxVisibleHeight - flowchartData.maxCaptionHeight, row, direction)
				nextrow = row + nextscrollcount * direction
			until nextscrollcount == 0 or (flowchartData.rowYOffsets[nextrow] - startoffset) * direction >= -pixelsToScroll * direction

			if row ~= flowchartData.firstVisibleRow then
				flowchartData.firstVisibleRow = row
				widgetSystem.updateFlowchart(flowchartElement)
			end
		end
	else
		-- check whether the mouse cursor was moved by a relevant factor
		if scrollbar.previousMousePos ~= nil and math.abs(scrollbar.previousMousePos - x) < config.mouseScrollBarThreshold then
			return -- mouse hasn't been moved between previous and current call - no mouse change => nothing to do
		end

		-- See analogous note above
		local moveRight = scrollbar.previousMousePos ~= nil and scrollbar.previousMousePos < x

		scrollbar.previousMousePos = x

		local newSliderPos = x - scrollbar.dragOffset
		local curSliderPos = widgetSystem.getHorizontalScrollBarSliderPosition(scrollbar.element)
		local valueDiff = newSliderPos - curSliderPos
		local pixelsToScroll = scrollbar.valuePerPixel * valueDiff

		local direction = (pixelsToScroll < 0 and not moveRight and -1) or (pixelsToScroll > 0 and moveRight and 1)
		if direction then
			local flowchartData = flowchartElement.data
			local col = flowchartData.firstVisibleCol
			local nextcol = flowchartData.firstVisibleCol
			local startoffset = flowchartData.columns[col].offsetx
			repeat
				col = nextcol
				local nextscrollcount = widgetSystem.getFlowchartNumCellsToScroll(flowchartData.colWidths, flowchartData.maxVisibleWidth, col, direction)
				nextcol = col + nextscrollcount * direction
			until nextscrollcount == 0 or (flowchartData.columns[nextcol].offsetx - startoffset) * direction >= pixelsToScroll * direction

			if col ~= flowchartData.firstVisibleCol then
				flowchartData.firstVisibleCol = col
				widgetSystem.updateFlowchart(flowchartElement)
			end
		end
	end
end

-- Generic helper functions for both vertical and horizontal scrolling in flowchart
function widgetSystem.getFlowchartNumCellsToScroll(cellsizes, totalvisiblesize, firstvisibleindex, scrolldirection, step)
	-- size can be either width or height, and cellsizes is an array of either column widths or row heights.
	-- If we can still scroll in the given direction (+1 or -1), let's find out by how many indices (columns or rows) we should scroll. Since the
	-- sizes can vary within the array and the cells are stretched to the total visible size, we want to avoid scrolling by only one cell forward if
	-- that doesn't reveal another cell on the other side (if the disappearing cell is too small and the next cell is too large to appear on screen).
	-- So we scroll forward as many cells as necessary to reveal at least one new cell on the other side. For scrolling backwards, we have to find
	-- the "reverse element": Scroll backwards as far as possible so that scrolling forwards would get us back to the current view.
	if scrolldirection > 0 then
		local totalneededsize, numvisiblecells = widgetSystem.getFlowchartVisibleCellData(cellsizes, totalvisiblesize, firstvisibleindex)
		-- abort if current cell does not fit on screen (should not happen) or we cannot scroll
		if numvisiblecells == 0 or firstvisibleindex + numvisiblecells > #cellsizes then
			return 0
		end
		-- we scroll far enough to see at least one next cell, so at least the first cell is out of view
		totalneededsize = totalneededsize + cellsizes[firstvisibleindex + numvisiblecells] - cellsizes[firstvisibleindex]
		local cellstoscroll = math.min(#cellsizes - firstvisibleindex - numvisiblecells + 1, step or 1)
		while totalneededsize > totalvisiblesize do
			-- not all cells fit on screen yet, keep removing cells at the beginning (i.e. keep scrolling) until the next cell becomes visible
			totalneededsize = totalneededsize - cellsizes[firstvisibleindex + cellstoscroll]
			cellstoscroll = cellstoscroll + 1
		end
		return cellstoscroll
	else
		if firstvisibleindex > 2 then
			-- find out how much space we need when scrolling one cell backwards
			local totalneededsize = widgetSystem.getFlowchartVisibleCellData(cellsizes, totalvisiblesize, firstvisibleindex - 1)
			-- scroll as far backwards as possible as long as the last cell remains visible
			local cellstoscroll = math.min(firstvisibleindex - 2, step or 1)
			repeat
				cellstoscroll = cellstoscroll + 1
				totalneededsize = totalneededsize + cellsizes[firstvisibleindex - cellstoscroll]
				if totalneededsize > totalvisiblesize then
					return cellstoscroll - 1		-- last cell not visible any more, undo last scroll
				end
			until cellstoscroll == firstvisibleindex - 1
		end
		-- let's scroll back to the first cell (or return 0 if this is already the first cell)
		return firstvisibleindex - 1
	end
end

function widgetSystem.getFlowchartNumCellsToScrollPage(cellsizes, totalvisiblesize, firstvisibleindex, scrolldirection)
	local totalneededsize, numvisiblecells = widgetSystem.getFlowchartVisibleCellData(cellsizes, totalvisiblesize, firstvisibleindex)
	if scrolldirection > 0 then
		-- abort if current cell does not fit on screen (should not happen) or we cannot scroll
		if numvisiblecells == 0 or firstvisibleindex + numvisiblecells > #cellsizes then
			return 0
		end
		-- scroll forward until the last visible cell is out of view, then scroll back once
		local scrollbackcount = widgetSystem.getFlowchartNumCellsToScroll(cellsizes, totalvisiblesize, firstvisibleindex + numvisiblecells, -1)
		local scrollforwardcount = numvisiblecells - scrollbackcount
		if scrollforwardcount > 0 then
			return scrollforwardcount
		end
		-- if scrolled back to 0, just scroll forward once
		return widgetSystem.getFlowchartNumCellsToScroll(cellsizes, totalvisiblesize, firstvisibleindex, 1)
	else
		if firstvisibleindex > 2 then
			-- scroll back until no currently visible cell is visible any more (i.e. until cellstoscroll >= new number of visible cells)
			local cellstoscroll = 0
			repeat
				-- scroll back one cell and treat it as visible
				cellstoscroll = cellstoscroll + 1
				numvisiblecells = numvisiblecells + 1
				totalneededsize = totalneededsize + cellsizes[firstvisibleindex - cellstoscroll]
				-- check how many cells become invisible
				while totalneededsize > totalvisiblesize and numvisiblecells > 0 do
					numvisiblecells = numvisiblecells - 1
					totalneededsize = totalneededsize - cellsizes[firstvisibleindex - cellstoscroll + numvisiblecells]
				end
				-- if original first cell is not visible any more, we are done - undo last scroll, which makes the cell visible again
				if cellstoscroll >= numvisiblecells then
					return cellstoscroll - 1
				end
			until cellstoscroll == firstvisibleindex - 1
		end
		-- let's scroll back to the first cell (or return 0 if this is already the first cell)
		return firstvisibleindex - 1
	end
end

function widgetSystem.getFlowchartVisibleCellData(cellsizes, totalvisiblesize, firstvisibleindex)
	local totalneededsize, numvisiblecells = 0, 0
	while firstvisibleindex + numvisiblecells <= #cellsizes and totalneededsize + cellsizes[firstvisibleindex + numvisiblecells] < totalvisiblesize do
		totalneededsize = totalneededsize + cellsizes[firstvisibleindex + numvisiblecells]
		numvisiblecells = numvisiblecells + 1
	end
	return totalneededsize, numvisiblecells
end

-- Accessed from MWT helper. Returns: frameOffsetX, frameOffsetY, framePaddingX, framePaddingY
function widgetSystem.getFlowchartNodeExpandedFrameData(flowchartNodeID)
	local nodeentry = private.associationList[flowchartNodeID]
	if nodeentry == nil then
		return nil
	end
	local flowchartNodeElement = nodeentry.element
	local node = flowchartNodeElement.cell
	local nodex = private.offsetx + getAttribute(flowchartNodeElement.main, "position.x")
	local nodey = private.offsety - getAttribute(flowchartNodeElement.main, "position.y")
	-- determine required padding for expanded frame
	local _, height = GetSize(node.id)
	local bordershape = config.flowchart.borderShapeData[node.shape]
	local framepaddingx = bordershape.hasExpandGroups and (bordershape.baseWidth * height / config.flowchart.baseModelHeight) or config.flowchart.expandFramePadding
	local framepaddingy = config.flowchart.expandFramePadding
	return nodex, nodey, framepaddingx, framepaddingy
end

function widgetSystem.invertColor(r, g, b)
	return 255 - r, 255 - g, 255 - b
end

function widgetSystem.moveDown(tableID, tableElement, newCurRow, modified)
	-- #StefanMed - this should be stored in the tableelement rather than recalculating every time
	-- get the last selectable row
	local lastSelectableRow = tableElement.numRows
	while tableElement.unselectableRows[lastSelectableRow] ~= nil do
		lastSelectableRow = lastSelectableRow - 1
	end
	-- note: lastSelectableRow will be 0 here, if there are no selectable rows at all
	
	local nextTableID = C.GetTableNextConnectedTable(tableID)
	if (not tableElement.wrapAround) and (nextTableID == 0) and (tableElement.curRow == lastSelectableRow) and (tableElement.bottomRow == tableElement.numRows) then
		return -- table should not wrap around and should not connect to another table and we are already at last element and the bottom part of the table is displayed
	end

	-- find the first selectable row after the given new cur row or the current row (can become numRows + 1, if no rows past curRow are selectable)
	local curRow = newCurRow
	if curRow == nil then
		curRow = tableElement.curRow + 1
		if curRow <= tableElement.numRows then
			if tableElement.highlightMode == "off" then
				-- cannot see the highlight border, change scroll behaviour to avoid "blind" selection changes
				if tableElement.scrollBar.active and (curRow > tableElement.numFixedRows) then
					curRow = tableElement.bottomRow
					if curRow >= tableElement.numRows - 1 then
						-- if we are on the second to last row jump to the end, because the scrollbar will be at the end, too
						-- if we are on the last row jump to next table if any
						curRow = curRow + 1
					end
				elseif (not tableElement.hasSelectableNonFixedChild) and (curRow > tableElement.numFixedRows) then
					-- if there is no scrollbar and not a fixed row, skip to next table
					curRow = tableElement.numRows + 1
				end
			end
		end
	end
	while tableElement.unselectableRows[curRow] ~= nil do
		curRow = curRow + 1
	end
	-- reset curRow to last selectable row (in case we were either given a cur row past the last selectable row or we were already at the last selectable row, in which case curRow would now point to numRows + 1)
	if curRow > tableElement.numRows then
		-- only wrap around the table (or go to next table), if newCurRow is not specified (otherwise we'd end up calling moveUp() again resulting in no wrapping around)
		-- also no wrapping around yet (or going to next table), if we do not display the bottom row yet (cause otherwise we could generate valid tables which never display their (unselectable) bottom row)
		if (tableElement.bottomRow == tableElement.numRows) and (newCurRow == nil) then
			if tableElement.wrapAround then
				-- wrapping around by moving up to the top row
				widgetSystem.moveUp(tableID, tableElement, 1)
				return
			elseif nextTableID ~= 0 then
				local nexttableentry = private.associationList[nextTableID]
				if nexttableentry == nil then
					-- can happen if table got already destroyed
					return
				end
				local nextTableElement = nexttableentry.element
				local frameElement = widgetSystem.getFrameElementByTableElement(nextTableElement)
				if frameElement == nil then
					-- can happen if frame got already destroyed
					return
				end
				local frameID = widgetSystem.getWidgetIDByElementEntry(frameElement)
				if C.SetFrameInteractiveObject(frameID, nextTableID) then
					-- we must unset the previous interactive element (aka: the button in the previous table) first
					if private.interactiveElement and (private.interactiveElement.element.interactiveChild ~= nil) then
						widgetSystem.unsetInteractiveChildElement(private.interactiveElement.element, private.interactiveElement.element.interactiveChild.widgetID, private.interactiveElement.element.interactiveChild.element)
					end

					widgetSystem.setActiveFrame(private.associationList[frameID].element)
					widgetSystem.setInteractiveElement(frameID, nextTableID, false)

					widgetSystem.moveUp(nextTableID, nextTableElement, 1)
				end
				return
			end
		end

		curRow = lastSelectableRow
	end

	--[[local shiftRows = 0
	if widgetSystem.hasNonFixedRows(tableElement) then
		-- shifting is only required, if we have regular rows
		if newTopRow > tableElement.bottomRow then
			-- we moved upwards a row without that one being on screen atm, shift the entire table so that the current selected row is the new bottom row
			shiftRows = widgetSystem.calculateRowsToMoveByBottomRow(tableID, tableElement, tableElement.curRow)
		elseif newTopRow < tableElement.topRow then
			-- the new row is currently not displayed, so shift the entire table to at least the new row
			shiftRows = newTopRow - tableElement.topRow
		end
	end]]

	-- calculate how many rows we have to shift
	local shiftRows = 0
	if widgetSystem.hasNonFixedRows(tableElement) then
		-- shifting rows is only required, if we have regular rows
		if (tableElement.bottomRow ~= tableElement.numRows) or (tableElement.curRow < tableElement.topRow) then
			-- shifting is only required, if we are not showing the bottom row already and the current row is visible (aka: current row not scrolled-out)

			-- determine the new bottomRow which is either the next selectable row after the one we move to (so that the user can see the next row
			-- which will be selected when further scrolling down and the entire content in-between the nextRow and newBottomRow is displayed)
			-- or numRows, if we are at the last selectable row
			local newBottomRow
			if curRow == lastSelectableRow then
				newBottomRow = tableElement.numRows
			else
				newBottomRow = curRow + 1
				while tableElement.unselectableRows[newBottomRow] ~= nil do
					newBottomRow = newBottomRow + 1
				end
				-- note: we know for sure that there is a following selectable row after curRow, since otherwise curRow would equal lastSelectableRow --- hence no further check required here
			end

			if newBottomRow > tableElement.bottomRow then
				-- make sure we shift the table so much that we display the correct bottomRow
				shiftRows = widgetSystem.calculateRowsToMoveByBottomRow(tableID, tableElement, newBottomRow)
			elseif (tableElement.curRow > tableElement.numFixedRows) and (tableElement.curRow < tableElement.topRow) then
				-- we do not display the current row atm (aka: table scrolled out) - hence shift the table, so that the previous row (aka curRow) is the new topRow
				-- we use the curRow here rather than the new curRow (aka: nextRow) since we want to always display a row before the current selected one so the player can see the row which
				-- is going to be selected, if he moves up again afterwards
				shiftRows = tableElement.curRow - tableElement.topRow
			end
		end
	end

	widgetSystem.updateTable(tableID, tableElement, shiftRows, curRow, modified)

	if tableElement.curRow == lastSelectableRow and tableElement.bottomRow ~= tableElement.numRows then
		DebugError("Widget system error. Invalid table setup. We've got a table which doesn't specify a selectable row we could scroll to in order to display the bottom row.")
	end
end

function widgetSystem.moveLeft(tableID, tableElement)
	local isFirstCol = true
	if tableElement.interactiveChild then
		for i = tableElement.interactiveChild.col - 1, 1, -1 do
			if GetTableColumnSpan(tableID, tableElement.curRow, i) ~= 0 then
				if widgetSystem.getSelectableCellElement(tableID, tableElement.curRow, i) then
					isFirstCol = false
					break
				end
			end
		end
	end

	if (not isFirstCol) and (tableElement.interactiveChild == nil) then
		return -- no interactive entry atm, nothing to do
	end

	if private.activeDropDown ~= nil then
		-- Ignore Left-right if a dropdown is active
		return
	end

	-- prefer slidercell input before changing the interactive object
	if tableElement.interactiveChild and IsType(tableElement.interactiveChild.widgetID, "slidercell") then
		if tableElement.interactiveChild.element.inputActive then
			widgetSystem.confirmSliderCellInputInternal(tableElement.interactiveChild.widgetID, tableElement.interactiveChild.element)
		end

		if widgetSystem.startSliderCellScroll(tableElement.interactiveChild.element, -1) then
			widgetSystem.setSliderCellArrowState(tableElement.interactiveChild.widgetID, "left", "mouseDown", true)

			CallWidgetEventScripts(tableElement.interactiveChild.widgetID, "onSliderCellActivated")
			CallWidgetEventScripts(tableElement.interactiveChild.widgetID, "onSliderCellLeftDown")
		end
	elseif isFirstCol then
		local prevTableID = C.GetTablePreviousHorizontalConnectedTable(tableID)
		if prevTableID ~= 0 then
			local prevtableentry = private.associationList[prevTableID]
			if prevtableentry == nil then
				-- can happen if table got already destroyed
				return
			end
			local prevTableElement = prevtableentry.element
			local frameElement = widgetSystem.getFrameElementByTableElement(prevTableElement)
			if frameElement == nil then
				-- can happen if frame got already destroyed
				return
			end
			local frameID = widgetSystem.getWidgetIDByElementEntry(frameElement)
			if C.SetFrameInteractiveObject(frameID, prevTableID) then
				-- we must unset the previous interactive element (aka: the button in the previous table) first
				if private.interactiveElement and (private.interactiveElement.element.interactiveChild ~= nil) then
					widgetSystem.unsetInteractiveChildElement(private.interactiveElement.element, private.interactiveElement.element.interactiveChild.widgetID, private.interactiveElement.element.interactiveChild.element)
				end

				widgetSystem.setActiveFrame(frameElement)
				widgetSystem.setInteractiveElement(frameID, prevTableID, true)
			end
		end
	else
		local startcolumn = math.max(1, tableElement.interactiveChild.col - 1)
		widgetSystem.selectInteractiveElement(tableID, tableElement, tableElement.interactiveChild.row, startcolumn, tableElement.interactiveChild.col, "left")
	end
end

function widgetSystem.stopLeft(tableID, tableElement)
	if tableElement.interactiveChild == nil then
		return -- no interactive entry atm, nothing to do
	end

	if IsType(tableElement.interactiveChild.widgetID, "slidercell") then
		if widgetSystem.stopSliderCellScroll(tableElement.interactiveChild.element) then
			widgetSystem.setSliderCellArrowState(tableElement.interactiveChild.widgetID, "left", "mouseDown", false)
			CallWidgetEventScripts(tableElement.interactiveChild.widgetID, "onSliderCellDeactivated")
			CallWidgetEventScripts(tableElement.interactiveChild.widgetID, "onSliderCellConfirm", tableElement.interactiveChild.element.cur, true)
		end
	end
end

function widgetSystem.moveRight(tableID, tableElement)
	local isLastCol = true
	if tableElement.interactiveChild then
		for i = tableElement.interactiveChild.col + 1, tableElement.numCols do
			if GetTableColumnSpan(tableID, tableElement.curRow, i) ~= 0 then
				if widgetSystem.getSelectableCellElement(tableID, tableElement.curRow, i) then
					isLastCol = false
					break
				end
			end
		end
	end

	if (not isLastCol) and (tableElement.interactiveChild == nil) then
		return -- no interactive entry atm, nothing to do
	end

	if private.activeDropDown ~= nil then
		-- Ignore Left-right if a dropdown is active
		return
	end

	-- prefer slidercell input before changing the interactive object
	if tableElement.interactiveChild and IsType(tableElement.interactiveChild.widgetID, "slidercell") then
		if tableElement.interactiveChild.element.inputActive then
			widgetSystem.confirmSliderCellInputInternal(tableElement.interactiveChild.widgetID, tableElement.interactiveChild.element)
		end

		if widgetSystem.startSliderCellScroll(tableElement.interactiveChild.element, 1) then
			widgetSystem.setSliderCellArrowState(tableElement.interactiveChild.widgetID, "right", "mouseDown", true)

			CallWidgetEventScripts(tableElement.interactiveChild.widgetID, "onSliderCellActivated")
			CallWidgetEventScripts(tableElement.interactiveChild.widgetID, "onSliderCellRightDown")
		end
	elseif isLastCol then
		local nextTableID = C.GetTableNextHorizontalConnectedTable(tableID)
		if nextTableID ~= 0 then
			local nexttableentry = private.associationList[nextTableID]
			if nexttableentry == nil then
				-- can happen if table got already destroyed
				return
			end
			local nextTableElement = nexttableentry.element
			local frameElement = widgetSystem.getFrameElementByTableElement(nextTableElement)
			if frameElement == nil then
				-- can happen if frame got already destroyed
				return
			end
			local frameID = widgetSystem.getWidgetIDByElementEntry(frameElement)
			if C.SetFrameInteractiveObject(frameID, nextTableID) then
				-- we must unset the previous interactive element (aka: the button in the previous table) first
				if private.interactiveElement and (private.interactiveElement.element.interactiveChild ~= nil) then
					widgetSystem.unsetInteractiveChildElement(private.interactiveElement.element, private.interactiveElement.element.interactiveChild.widgetID, private.interactiveElement.element.interactiveChild.element)
				end

				widgetSystem.setActiveFrame(frameElement)
				widgetSystem.setInteractiveElement(frameID, nextTableID, true)
			end
		end
	else
		widgetSystem.selectInteractiveElement(tableID, tableElement, tableElement.interactiveChild.row, tableElement.interactiveChild.col + 1, tableElement.interactiveChild.col, "right")
	end
end

function widgetSystem.stopRight(tableID, tableElement)
	if tableElement.interactiveChild == nil then
		return -- no interactive entry atm, nothing to do
	end

	if IsType(tableElement.interactiveChild.widgetID, "slidercell") then
		if widgetSystem.stopSliderCellScroll(tableElement.interactiveChild.element) then
			widgetSystem.setSliderCellArrowState(tableElement.interactiveChild.widgetID, "right", "mouseDown", false)
			CallWidgetEventScripts(tableElement.interactiveChild.widgetID, "onSliderCellDeactivated")
			CallWidgetEventScripts(tableElement.interactiveChild.widgetID, "onSliderCellConfirm", tableElement.interactiveChild.element.cur, true)
		end
	end
end

function widgetSystem.moveUp(tableID, tableElement, newCurRow, modified)
	-- #coreUIMed - add a check for curRow == firstSelectableRow || firstSelectableFixedRow so to speed up the handling (O(n) -> O(1))
	local prevTableID = C.GetTablePreviousConnectedTable(tableID)
	if (not tableElement.wrapAround) and (prevTableID == 0) and (tableElement.curRow <= 1) then
		return -- already at first element
	end

	-- find the first selectable row before the current row (or the one which we got passed)
	local curRow = newCurRow
	if curRow == nil then
		curRow = tableElement.curRow - 1
		if curRow >= 1 then
			if tableElement.highlightMode == "off" then
				-- cannot see the highlight border, change scroll behaviour to avoid "blind" selection changes
				if tableElement.scrollBar.active and (curRow > tableElement.numFixedRows) then
					curRow = tableElement.topRow
					if curRow <= tableElement.numFixedRows + 1 then
						-- if we are on the second row jump to the first, because the scrollbar will be at the top, too
						-- if we are on the first row jump to prev table if any
						curRow = curRow - 1
					end
				elseif (not tableElement.hasSelectableNonFixedChild) and (curRow > tableElement.numFixedRows) then
					-- if there is no scrollbar and not a fixed row, skip to fixed rows (and succeedingly to the prev table if any)
					curRow = tableElement.numFixedRows
				end
			end
		end
	end
	while tableElement.unselectableRows[curRow] ~= nil do
		curRow = curRow - 1
	end

	-- ensure we don't pass the first row (can happen, when calling moveUp with curRow being set to 1)
	if curRow < 1 then
		-- only wrap around the table (or go to previous table), if newCurRow is not specified (otherwise we'd end up calling moveUp() again resulting in no wrapping around)
		-- also no wrapping around (or going to previous table) yet, if we do not display the top row yet (cause otherwise we could generate valid tables which never display their (unselectable) top row)
		-- if there are only fixed rows there is no top row defined
		if ((tableElement.numFixedRows == tableElement.numRows) or (tableElement.topRow == tableElement.numFixedRows + 1)) and (newCurRow == nil) then
			if tableElement.wrapAround then
				-- wrapping around by moving down to the bottom row
				widgetSystem.moveDown(tableID, tableElement, tableElement.numRows)
				return
			elseif prevTableID ~= 0 then
				local prevtableentry = private.associationList[prevTableID]
				if prevtableentry == nil then
					-- can happen if table got already destroyed
					return
				end
				local prevTableElement = prevtableentry.element
				local frameElement = widgetSystem.getFrameElementByTableElement(prevTableElement)
				if frameElement == nil then
					-- can happen if frame got already destroyed
					return
				end
				local frameID = widgetSystem.getWidgetIDByElementEntry(frameElement)
				if C.SetFrameInteractiveObject(frameID, prevTableID) then
					-- we must unset the previous interactive element (aka: the button in the previous table) first
					if private.interactiveElement and (private.interactiveElement.element.interactiveChild ~= nil) then
						widgetSystem.unsetInteractiveChildElement(private.interactiveElement.element, private.interactiveElement.element.interactiveChild.widgetID, private.interactiveElement.element.interactiveChild.element)
					end

					widgetSystem.setActiveFrame(private.associationList[frameID].element)
					widgetSystem.setInteractiveElement(frameID, prevTableID, false)

					widgetSystem.moveDown(prevTableID, prevTableElement, prevTableElement.numRows)
				end
				return
			end
		end

		-- get the first selectable row
		-- #coreUIMed - speed up by storing the firstSelectableRow upon table creation, so it doesn't have to be recalculated always...
		curRow = 1
		while tableElement.unselectableRows[curRow] ~= nil do
			curRow = curRow + 1
		end
		if curRow > tableElement.numRows then
			-- There are no selectable rows
			curRow = 0
		end
	end

	-- we must calculate the new top row now - we need to move either to the top row (if the curRow is the first selectable normal row)
	-- or to the selectable row before the new selected row (so that the user sees the row before the current selected one -- aka: when going up one more step)
	local newTopRow = curRow - 1
	while tableElement.unselectableRows[newTopRow] ~= nil do
		newTopRow = newTopRow - 1
	end
	newTopRow = math.max(newTopRow, tableElement.numFixedRows + 1) -- ensure we don't pass the first (normal) row (can happen, when calling moveUp with curRow being set to the second selectable row)

	local shiftRows = 0
	if widgetSystem.hasNonFixedRows(tableElement) then
		-- shifting is only required, if we have regular rows
		if tableElement.curRow > tableElement.bottomRow then
			-- we moved upwards a row without that one being on screen atm, shift the entire table so that the current selected row is the new bottom row
			shiftRows = widgetSystem.calculateRowsToMoveByBottomRow(tableID, tableElement, tableElement.curRow)
		elseif newTopRow < tableElement.topRow then
			-- the new row is currently not displayed, so shift the entire table to at least the new row
			shiftRows = newTopRow - tableElement.topRow
		end
	end
	
	widgetSystem.updateTable(tableID, tableElement, shiftRows, curRow, modified)
end

function widgetSystem.pageDown(tableID, tableElement)
	if not widgetSystem.hasNonFixedRows(tableElement) then
		return -- table only contains fixed-rows - nothing to page-down to
	end

	-- if the last selectable row on the current page is selected, scroll the entire table by one page and select last row again, otherwise just select last row
	-- NOTE: pageDown can really select the last selectable row, in contrast to moveDown, which prefers a selectable row above the bottomRow
	if tableElement.curRow >= tableElement.topRow and tableElement.curRow <= tableElement.bottomRow then
		-- calculate the last selectable row on the current page and check if it's currently selected
		local lastSelectableCurRow = tableElement.bottomRow
		while tableElement.unselectableRows[lastSelectableCurRow] ~= nil do
			lastSelectableCurRow = lastSelectableCurRow - 1
		end

		if tableElement.curRow == lastSelectableCurRow then
			-- scroll the entire table by one page
			if tableElement.bottomRow == tableElement.numRows then
				return -- already at last element
			end
			local shiftRows = widgetSystem.calculateRowsToMoveByTopRow(tableID, tableElement, tableElement.bottomRow + 1)
			widgetSystem.updateTable(tableID, tableElement, shiftRows, tableElement.topRow + shiftRows, "ctrl")
		end
	end

	-- after the table was shifted we know the bottom-row and select the bottom most one we can select
	for row = tableElement.bottomRow, tableElement.topRow, -1 do
		if tableElement.unselectableRows[row] == nil then
			-- update the table selection to the bottomRow
			widgetSystem.updateTable(tableID, tableElement, 0, row, "ctrl")
			return
		end
	end

	DebugError("Widget system error. PageDown failed to calculate a selectable row. PageDown will be ignored.")
end

function widgetSystem.pageUp(tableID, tableElement)
	if not widgetSystem.hasNonFixedRows(tableElement) then
		return -- table only contains fixed-rows - nothing to page-up to
	end

	if tableElement.topRow == tableElement.numFixedRows + 1 and tableElement.curRow <= tableElement.topRow then
		return -- already scrolled to the top, and selection at or above first normal row: ignore pageUp
	end

	-- if the first selectable row on the current page is selected, scroll the entire table by one page and select first row again, otherwise just select first row
	-- NOTE: pageUp can really select the first selectable row, in contrast to moveUp, which prefers a selectable row below the topRow
	if tableElement.curRow >= tableElement.topRow and tableElement.curRow <= tableElement.bottomRow then
		-- calculate the first selectable row on the current page and check if it's currently selected
		local firstSelectableCurRow = tableElement.topRow
		while tableElement.unselectableRows[firstSelectableCurRow] ~= nil do
			firstSelectableCurRow = firstSelectableCurRow + 1
		end

		if tableElement.curRow == firstSelectableCurRow then
			-- scroll the entire table by one page
			if tableElement.topRow == tableElement.numFixedRows + 1 then
				return -- already at first element
			end
			local shiftRows = widgetSystem.calculateRowsToMoveByBottomRow(tableID, tableElement, tableElement.topRow - 1)
			widgetSystem.updateTable(tableID, tableElement, shiftRows, tableElement.topRow + shiftRows, "ctrl")
		end
	end

	-- after the table was shifted we know the top-row and select the upper most one we can select
	for row = tableElement.topRow, tableElement.bottomRow do
		if tableElement.unselectableRows[row] == nil then
			-- update the table selection to the topRow
			widgetSystem.updateTable(tableID, tableElement, 0, row, "ctrl")
			return
		end
	end

	DebugError("Widget system error. PageUp failed to calculate a selectable row. PageUp will be ignored.")
end

function widgetSystem.raiseHideEvent(frame, type)
	if private.associationList[frame] then
		CallWidgetEventScripts(frame, "onHide", type)
		if GetControllerInfo() == "gamepad" then
			C.DeactivateMouseEmulation()
		end
		private.onHideRisen = true
	end
end

-- removes the given element from the association list (element being the associated Anark element)
function widgetSystem.removeFromAssociationList(element)
	for widgetID, entry in pairs(private.associationList) do
		if entry.element == element then
			if IsValidWidgetElement(widgetID) then
				local overlayid = ffi.string(C.GetHelpOverlayInfo2(widgetID).id)
				if (overlayid ~= "") and private.displayedHelpOverlays[overlayid] then
					widgetSystem.hideHelpOverlayID(overlayid)
				end
				C.SetWidgetAssociatedElement(widgetID, false)
			end
			private.associationList[widgetID] = nil
			return -- done (we've found and removed the element)
		end
	end
end

function widgetSystem.removeHighlightTableRow(tableID, tableElement, highlightrow)
	-- note: caller ensures that this is only called, if we have non-fixed rows

	if tableElement.highlightedRows == nil then
		return -- highlighted rows data already destroyed
	end

	for row in pairs(tableElement.highlightedRows) do
		-- row not displayed, no highlight to remove
		if (row >= tableElement.topRow) and (row <= tableElement.bottomRow) then
			if (not highlightrow) or (row == highlightrow) then
				widgetSystem.setTableRowColor(tableID, tableElement, row, nil, nil, false)
			end
		end
	end
	if highlightrow then
		tableElement.highlightedRows[highlightrow] = nil
	else
		tableElement.highlightedRows = {}
	end
end

function widgetSystem.scrollDown(tableID, tableElement, step)
	-- note: explicit check for not hasNonFixedRows() not required, since this is implicitly checked by bottomRow == numRows
	-- (aka: we are showing the last row (which is the last fixed row) otherwise the table set-up would have been rejected)
	if tableElement.bottomRow == tableElement.numRows then
		return -- bottom row already shown
	end

	-- prevent scrolling down too much
	if tableElement.bottomRow + step > tableElement.numRows then
		step = widgetSystem.calculateRowsToMoveByBottomRow(tableID, tableElement, tableElement.numRows)
	end

	-- scroll the table down without changing the selected row
	widgetSystem.updateTable(tableID, tableElement, step, tableElement.curRow, "ctrl")
end

function widgetSystem.scrollLeft(sliderElement, step)
	if sliderElement.minSelectableValue == sliderElement.curValue then
		return -- already at left corner
	end

	if sliderElement.curValue - step < sliderElement.minSelectableValue then
		step = math.abs(sliderElement.minSelectableValue - sliderElement.curValue)
	end
	sliderElement.curValue = sliderElement.curValue - step

	widgetSystem.updateSlider(sliderElement)
end

function widgetSystem.scrollPageDown(tableID, tableElement)
	-- note: explicit check for not hasNonFixedRows() not required, since this is implicitly checked by bottomRow == numRows
	-- (aka: we are showing the last row (which is the last fixed row) otherwise the table set-up would have been rejected)
	if tableElement.bottomRow == tableElement.numRows then
		return -- already at the bottom of the table
	end

	-- scroll the entire table by one page but do not alter the current selected row
	local shiftRows = widgetSystem.calculateRowsToMoveByTopRow(tableID, tableElement, tableElement.bottomRow+1)

	-- scroll the table without altering the selected row
	widgetSystem.updateTable(tableID, tableElement, shiftRows, tableElement.curRow, "ctrl")
end

function widgetSystem.scrollPageUp(tableID, tableElement)
	-- caller ensures that topRow is never nil
	if tableElement.topRow == (tableElement.numFixedRows + 1) then
		return -- already at top of the table
	end

	-- scroll the entire table by one page but do not alter the current selected row
	local shiftRows = widgetSystem.calculateRowsToMoveByBottomRow(tableID, tableElement, tableElement.topRow - 1)

	-- scroll the table without altering the selected row
	widgetSystem.updateTable(tableID, tableElement, shiftRows, tableElement.curRow, "ctrl")
end

function widgetSystem.scrollDownDropDown(dropdownID, dropdownElement, steps)
	dropdownElement.lastMousePos = nil
	local _, _, frameElement = widgetSystem.getTableElementByAnarkTableCellElement("dropdown", dropdownElement.element.main)
	widgetSystem.updateDropDownOptions(frameElement, dropdownID, dropdownElement, math.min((dropdownElement.topOption or 1) + (steps or 1), #dropdownElement.options))
end

function widgetSystem.scrollUpDropDown(dropdownID, dropdownElement, steps)
	dropdownElement.lastMousePos = nil
	local _, _, frameElement = widgetSystem.getTableElementByAnarkTableCellElement("dropdown", dropdownElement.element.main)
	widgetSystem.updateDropDownOptions(frameElement, dropdownID, dropdownElement, math.max((dropdownElement.topOption or 1) - (steps or 1), 1))
end

function widgetSystem.scrollRight(sliderElement, step)
	if sliderElement.maxSelectableValue == sliderElement.curValue then
		return -- already at right corner
	end

	if sliderElement.curValue + step > sliderElement.maxSelectableValue then
		step = sliderElement.maxSelectableValue - sliderElement.curValue
	end
	sliderElement.curValue = sliderElement.curValue + step

	widgetSystem.updateSlider(sliderElement)
end

function widgetSystem.scrollUp(tableID, tableElement, step)
	if not widgetSystem.hasNonFixedRows(tableElement) or tableElement.topRow <= (tableElement.numFixedRows + 1) then
		return -- top row already shown (or no non-fixed rows at all)
	end

	-- prevent scrolling up too much
	if tableElement.topRow - step <= tableElement.numFixedRows then
		step = math.abs(widgetSystem.calculateRowsToMoveByTopRow(tableID, tableElement, 1))
	end

	-- scroll the table up without changing the selected row
	widgetSystem.updateTable(tableID, tableElement, -step, tableElement.curRow, "ctrl")
end

-- column | (nil, errorcode, errormessage) = SelectColumn(tableID, column)
-- the table is not scrolled, if the row is not visible atm
function widgetSystem.selectColumn(tableID, column)
	local tableentry = private.associationList[tableID]
	if tableentry == nil then
		return nil, 1, "invalid table element"
	end
	local tableElement = tableentry.element

	if column <= 0 then
		return nil, 2, "column is out of bounds (< 1)"
	end

	if column > tableElement.numCols then
		return nil, 3, "column is out of bounds (exceeds number of columns: "..tableElement.numCols..")"
	end

	if GetTableColumnSpan(tableID, tableElement.curRow, column) == 0 then
		return nil, 4, "column cannot be selected since it is a spanned column"
	end

	local childWidgetID = GetCellContent(tableID, tableElement.curRow, column)

	if not IsSelectable(childWidgetID) then
		return nil, 5, "specified column contains a non-selectable element and hence cannot be selected"
	end

	widgetSystem.selectInteractiveElement(tableID, tableElement, tableElement.curRow, column, nil, "right")
	return column
end

-- determines the interactive element at the given row/col moving towards the given direction and selects it
-- tableID      - the widget ID of the table in which to select the interactive element
-- tableElement - the table representation (entry in private.element)
-- row          - the row in which to select the interactive element
-- col          - the column where to start looking for the interactive element
-- alternateCol - if we failed to determine an interactive element starting from col, select the interactive element at this column
-- direction    - the direction into which to iterate the interactive elements in the row ("left", "right", "rightLeft")
function widgetSystem.selectInteractiveElement(tableID, tableElement, row, col, alternateCol, direction, modified)
	-- #StefanMed - optimize --- should be stored here in Lua upon table set-up
	local step = 0
	local enableDirectionSwap = false
	local dir = 1
	if direction == "left" then
		dir = -1
	elseif direction == "rightLeft" then
		enableDirectionSwap = true
	-- otherwise direction is "right"
	end

	local oldRow
	local oldCol
	local oldElement
	local oldChildWidgetID
	if tableElement.interactiveChild then
		oldRow           = tableElement.interactiveChild.row
		oldCol           = tableElement.interactiveChild.col
		oldElement       = tableElement.interactiveChild.element
		oldChildWidgetID = tableElement.interactiveChild.widgetID
	end

	local childWidgetID
	local curCol
	-- find the selectable column (if any) using the col|direction setting
	repeat
		-- first get the next column
		curCol = widgetSystem.getNextColumn(col, 1, tableElement.numCols, step, dir)
		if curCol == nil then
			-- no further columns in that direction, check if we are allowed to swap directions
			if enableDirectionSwap then
				dir = dir * -1
				enableDirectionSwap = false -- stop swapping directions, since in the other one there's no further suitable column to check
				curCol = widgetSystem.getNextColumn(col, 1, tableElement.numCols, step, dir)
			end
		end

		if curCol ~= nil then
			-- If we are trying to keep the same column (step == 0) and are in the "rightLeft" case (enableDirectionSwap == true), default the direction for selectable cell lookup to left (dir == nil)!
			-- In this case we want to find the cell that spans the current cell, which can only be on the left side
			childWidgetID, curCol = widgetSystem.getSelectableCellElement(tableID, row, curCol, ((step ~= 0) or (not enableDirectionSwap)) and dir or nil, tableElement.numCols)
			if childWidgetID ~= nil then
				break -- we found the next selectable column
			end

			-- it's a column but it's not selectable, swap directions, or increase the step
			if not enableDirectionSwap then
				step = step + 1
			elseif dir == -1 then
				dir = 1 -- swap directions from left to right and increase step
				step = step + 1
			else -- dir == 1 and enableDirectionSwap is true
				dir = -1 -- swap directions from right to left
			end
		end
	until curCol == nil

	if curCol == nil then
		-- we didn't find any suitable column, use the alternate column
		curCol = alternateCol
		if curCol ~= nil then
			childWidgetID, curCol = widgetSystem.getSelectableCellElement(tableID, row, curCol)
		end
	end

	if (not tableElement.multiSelect) or (modified ~= "ctrl") then
		-- unset the previous element, if necessary (aka: if it's visible)
		-- note: There's no need to unset the interactive element, if it was reset to a different AnarkElement (aka: childTableElement changed)
		-- since that is already handled by hiding the button (implicit resetting of element states like button slides)
		if oldElement ~= nil and oldChildWidgetID ~= childWidgetID then
			local associationListEntry = private.associationList[oldChildWidgetID]
			local childTableElement
			if associationListEntry ~= nil then
				childTableElement = associationListEntry.element
			end
			-- can be nil, when scrolled out of view
			if childTableElement ~= nil then
				-- unset the previous element, if the element changed
				widgetSystem.unsetInteractiveChildElement(tableElement, oldChildWidgetID, childTableElement)
			end
		end

		-- set the new element, if necessary (aka: if we have a new element and it's visible)
		if childWidgetID ~= nil then
			-- associationListEntry can be nil, if the currently selected row is out of view (i.e. scrolled out with mouse-scrolling)
			local associationListEntry = private.associationList[childWidgetID]
			local childTableElement
			if associationListEntry ~= nil then
				childTableElement = associationListEntry.element
			end
			-- set the new element, if the element changed
			-- Note: This must be done regardless of whether the row/col changed, since selectInteractiveElement is also used to update the interactive element entry
			-- even if it just redrew a table section (in which case row/col/widgetID are the same, but the AnarkElement representing the widget element likely changed)
			-- this must then also update the interactive entry (namely the childTableElement.element-data) to the new one
			-- If we would not, this would cause problems whenever we use childTableElement.element to determine the anarkElement for a button for example - this caused XR-40.
			widgetSystem.setInteractiveChildElement(tableID, tableElement, row, curCol, childWidgetID, childTableElement)
		elseif private.mouseOverText and (not private.gamepadTableMouseOver) then
			if private.mouseOverText.posOverride ~= nil then
				widgetSystem.hideMouseOverText(private.mouseOverText.widgetID)
			end
		end
	end

	-- trigger column changed callbacks and reset interactive entry (do this, after we updated our own states - aka: after we called (set/unset)InteractiveElement(),
	-- so that any potential changes the callback performs will be done with us having set the states correctly)
	if childWidgetID ~= nil then
		-- we found a cellelement which will become the new selected element
		if oldRow == nil or oldRow ~= row or oldCol ~= curCol then
			local isNormalRegion = (row > tableElement.numFixedRows)

			if isNormalRegion and (tableElement.highlightMode ~= "off") and (tableElement.highlightMode ~= "offnormalscroll") then
				if tableElement.multiSelect then
					if not modified then
						widgetSystem.removeHighlightTableRow(tableID, tableElement)
						widgetSystem.highlightTableRow(tableID, tableElement, row, curCol)
					end
					widgetSystem.highlightBorderTableRow(tableID, tableElement, row, curCol)
				else
					widgetSystem.removeHighlightBorderTableRow(tableElement)
					widgetSystem.highlightBorderTableRow(tableID, tableElement, row, curCol)
				end
			end

			CallWidgetEventScripts(tableID, "onColumnChanged", curCol)
		end
	else
		-- couldn't find any slectable interactive element
		if oldRow ~= nil and oldRow ~= row then
			CallWidgetEventScripts(tableID, "onColumnChanged", nil)
		end

		-- if we ended up here, we didn't find a new (or existing column --- can happen upon row-changes - unset the interactive entry)
		if (not tableElement.multiSelect) or (modified ~= "ctrl") then
			tableElement.interactiveChild = nil
		end
	end
end

function widgetSystem.selectRowExternal(tableID, row, modified, input, source, settableinteractive)
	if settableinteractive then
		local tableentry = private.associationList[tableID]
		if tableentry ~= nil then
			local frameElement = widgetSystem.getFrameElementByTableElement(tableentry.element)
			if frameElement ~= nil then
				if private.interactiveElement and private.interactiveElement.element.interactiveChild ~= nil then
					widgetSystem.unsetInteractiveChildElement(private.interactiveElement.element, private.interactiveElement.element.interactiveChild.widgetID, private.interactiveElement.element.interactiveChild.element)
				end

				widgetSystem.setActiveFrame(frameElement)
				widgetSystem.setInteractiveElement(frameElement.frame, tableID)
			end
		end
	end
	widgetSystem.selectRow(tableID, row, modified, input, source)
end

-- row | (nil, errorcode, errormessage) = SelectRow(tableID, row)
-- the table is not scrolled, if the row is not visible atm
function widgetSystem.selectRow(tableID, row, modified, input, source)
	local tableentry = private.associationList[tableID]
	if tableentry == nil then
		return nil, 1, "invalid table element"
	end
	local tableElement = tableentry.element

	-- try to convert row parameter to number (in case it isn't already)
	local convertedRow = tonumber(row)
	if convertedRow == nil then
		return nil, 2, "row '"..tostring(row).."' is not a number"
	end

	if convertedRow <= 0 then
		return nil, 3, "row is out of bounds (< 1)"
	end

	if convertedRow > tableElement.numRows then
		return nil, 4, "row is out of bounds (exceeds number of rows: "..tableElement.numRows..")"
	end

	if tableElement.unselectableRows[convertedRow] ~= nil then
		return nil, 5, "specified row "..convertedRow.." is unselectable"
	end

	widgetSystem.selectRowInternal(tableID, tableElement, convertedRow, modified, input, source)
	return convertedRow
end

function widgetSystem.selectRowInternal(tableID, tableElement, row, modified, input, source)
	-- enforce highlight updates all the time, so that even if the table is only shifted, the proper row is highlighted
	-- remove highlight from previous row and highlight new one (but only if current row can be selected)

	local curCol = 1
	local direction = "right"
	if tableElement.interactiveChild ~= nil then
		curCol = tableElement.interactiveChild.col
		direction = "rightLeft"
	elseif tableElement.highlightedBorderCol then
		curCol = math.max(1, math.min(tableElement.numCols, tableElement.highlightedBorderCol))
		direction = "rightLeft"
	end

	local addCurRowHighlight, removeCurRowHighlight
	if tableElement.multiSelect then
		if modified == "shift" then
			if tableElement.shiftStart == nil then
				tableElement.shiftStart = tableElement.curRow
			end

			if tableElement.shiftEnd and (
				((tableElement.shiftEnd > tableElement.shiftStart) and (row < tableElement.shiftEnd)) or
				((tableElement.shiftEnd < tableElement.shiftStart) and (row > tableElement.shiftEnd))
			) then
				widgetSystem.removeHighlightTableRows(tableID, tableElement, tableElement.shiftStart, tableElement.shiftEnd)
			end
			tableElement.shiftEnd = row
			if tableElement.curRow ~= row then
				widgetSystem.highlightTableRows(tableID, tableElement, tableElement.shiftStart, row)
			end
			if tableElement.highlightedRows[row] then
				if (row < tableElement.curRow) and (tableElement.curRow > tableElement.shiftStart) then
					removeCurRowHighlight = tableElement.curRow
				elseif (row > tableElement.curRow) and (tableElement.curRow < tableElement.shiftStart) then
					removeCurRowHighlight = tableElement.curRow
				end
			end
		elseif (not modified) or ((input == "mouse") and (modified == "ctrl")) then
			tableElement.shiftStart = row
		end
	end

	local callEvent = false
	if tableElement.unselectableRows[row] == nil then
		if tableElement.curRow ~= row then
			if tableElement.curRow > tableElement.numFixedRows and row <= tableElement.numFixedRows then
				-- switching from non-fixed-region to fixed region
				tableElement.interactiveRegion = "fixed"
				tableElement.normalSelectedRow = tableElement.curRow
			elseif tableElement.curRow <= tableElement.numFixedRows and row > tableElement.numFixedRows then
				-- switching from fixed region to non-fixed-region
				tableElement.interactiveRegion = "normal"
				tableElement.normalSelectedRow = nil
			end
			tableElement.curRow = row
			callEvent = true
		end
		if tableElement.multiSelect then
			if (modified ~= "ctrl") and (tableElement.curRow == row) and (not tableElement.highlightedRows[row]) then
				callEvent = true
			elseif (not modified) and (tableElement.curRow == row) and tableElement.highlightedRows[row] then
				callEvent = true
			end
		end
	end

	local isNormalRegion = (row > tableElement.numFixedRows)

	if (tableElement.highlightMode ~= "off") and (tableElement.highlightMode ~= "offnormalscroll") then
		if (not tableElement.multiSelect) then
			widgetSystem.removeHighlightBorderTableRow(tableElement)
		elseif (not modified) or removeCurRowHighlight then
			widgetSystem.removeHighlightTableRow(tableID, tableElement, removeCurRowHighlight)
		end
	end

	-- no highlighting of new row, curRow is 0 - check is required here for interactive tables which are fully displayed but do not have any selectable row (valid case, but nothing to highlight)
	if tableElement.curRow == 0 then
		return
	end

	if source == nil then
		source = "auto"
	end

	-- only highlight rows in the non-fixed area --- if only fixed rows are used, there's nothing to highlight
	if isNormalRegion and (tableElement.highlightMode ~= "off") and (tableElement.highlightMode ~= "offnormalscroll") then
		if tableElement.multiSelect then
			if (modified ~= "ctrl") and ((modified ~= "shift") or (not removeCurRowHighlight)) then
				widgetSystem.highlightTableRow(tableID, tableElement, tableElement.curRow, curCol)
			elseif (input == "mouse") and (modified == "ctrl") then
				widgetSystem.toggleHighlight(tableID, tableElement, modified, input, source)
			end
			widgetSystem.highlightBorderTableRow(tableID, tableElement, tableElement.curRow, curCol)
		else
			widgetSystem.highlightBorderTableRow(tableID, tableElement, tableElement.curRow, curCol)
		end
	end

	-- important that widgetSystem.selectInteractiveElement is called after CallWidgetEventScripts. Otherwise, row mismatch.
	if callEvent then
		CallWidgetEventScripts(tableID, "onRowChanged", row, modified, input, source)
	end

	-- check the new row for an interactive element and select that
	widgetSystem.selectInteractiveElement(tableID, tableElement, tableElement.curRow, curCol, nil, direction, modified)
end

function widgetSystem.updateEmulatedMouseCursorPosition(tableID, tableElement, row, col)
	if GetControllerInfo() == "gamepad" then
		C.DeactivateMouseEmulation()

		if (row > 0) and (row <= tableElement.numRows) then
			local isNormalRegion = (row > tableElement.numFixedRows)
			local cellposx = tableElement.cellposx[1] + tableElement.width / 2
			if col then
				cellposx = isNormalRegion and tableElement.cellposx[col] or tableElement.fixedRowCellposx[col]
				local _, cellwidth = widgetSystem.getColumnSpanInfo(tableID, tableElement, row, col, not isNormalRegion)
				cellposx = cellposx + cellwidth / 2
			end
			local cellposy = tableElement.cellposy[row]

			C.SetMouseCursorPosition(cellposx, -cellposy)
		end
	end
end

function widgetSystem.getSelectedRows(tableID)
	local tableentry = private.associationList[tableID]
	if tableentry == nil then
		return nil, 1, "invalid table element"
	end
	local tableElement = tableentry.element

	local result = {}

	for row in pairs(tableElement.highlightedRows) do
		table.insert(result, row)
	end
	table.sort(result)

	return result, tableElement.highlightedBorderRow
end

function widgetSystem.setSelectedRows(tableID, rows, curRow)
	local tableentry = private.associationList[tableID]
	if tableentry == nil then
		return nil, 1, "invalid table element"
	end
	local tableElement = tableentry.element

	if not tableElement.multiSelect then
		return nil, 2, "table with ID '" .. tableID .. "' is not a multiselect table."
	end
	if curRow <= 0 then
		return nil, 3, "curRow is out of bounds (< 1)"
	end
	if curRow > tableElement.numRows then
		return nil, 4, "row is out of bounds (exceeds number of rows: "..tableElement.numRows..")"
	end
	if tableElement.unselectableRows[curRow] ~= nil then
		return nil, 5, "specified row "..convertedRow.." is unselectable"
	end

	widgetSystem.removeHighlightTableRow(tableID, tableElement)

	local shiftstart, shiftend
	for _, row in ipairs(rows) do
		if (row > 0) and (row <= tableElement.numRows) then
			if tableElement.unselectableRows[row] == nil then
				if not shiftstart then
					if row == tableElement.highlightedBorderRow then
						shiftstart = row
					end
				end
				shiftend = row
				if row > tableElement.numFixedRows then
					widgetSystem.highlightTableRow(tableID, tableElement, row)
				else
					DebugError("Widget system error. Selected row '" .. row .. "' is invalid. Reason: Fixed row.")
				end
			else
				DebugError("Widget system error. Selected row '" .. row .. "' is invalid. Reason: Unselectable.")
			end
		else
			DebugError("Widget system error. Selected row '" .. row .. "' is invalid. Reason: Out of bounds.")
		end
	end
	widgetSystem.selectRowInternal(tableID, tableElement, curRow, "ctrl")
	if shiftstart == nil then
		-- the current highlightedBorderRow is not selected, so use the first selected row as shiftstart
		shiftstart = rows[1]
	end
	tableElement.shiftStart = shiftstart
	tableElement.shiftend = shiftend
	widgetSystem.selectInteractiveElement(tableID, tableElement, curRow, 1, nil, "right", "shift")
end

function widgetSystem.setMouseCursorOverride(cursorIcon)
	private.pointerOverride = cursorIcon
	if not private.pointerOverrideInternal and not private.pointerOverrideInternalDrag then
		SetPointerOverride(private.widgetsystem, private.pointerOverride)
	end
end

function widgetSystem.setMouseCursorOverrideInternal(cursorIcon)
	private.pointerOverrideInternal = cursorIcon

	if not private.pointerOverrideInternalDrag then
		SetPointerOverride(private.widgetsystem, private.pointerOverrideInternal or private.pointerOverride or "default")
	end
end

function widgetSystem.setMouseCursorOverrideInternalDrag(cursorIcon)
	private.pointerOverrideInternalDrag = cursorIcon

	SetPointerOverride(private.widgetsystem, private.pointerOverrideInternalDrag or private.pointerOverrideInternal or private.pointerOverride or "default")
end

function widgetSystem.setMouseOverOverride(widgetID, override, forceHide)
	private.mouseOverOverrideText = override
	if not IsValidWidgetElement(widgetID) then
		return -- Nothing else to do
	end

	if override == nil then
		if forceHide or (ffi.string(C.GetMouseOverText(widgetID)) == "") then
			widgetSystem.hideMouseOverText(widgetID, true)
		else
			widgetSystem.showMouseOverText(widgetID, true)
		end
	else
		widgetSystem.showMouseOverText(widgetID, true)
	end
end

-- row | (nil, errorcode, errormessage) = widgetSystem.setTopRow(tableID, row)
function widgetSystem.setTopRow(tableID, row)
	local tableentry = private.associationList[tableID]
	if tableentry == nil then
		return nil, 1, "invalid table element"
	end
	local tableElement = tableentry.element

	if row <= 0 then
		return nil, 2, "row is out of bounds (< 1)"
	end

	if row > tableElement.numRows then
		return nil, 3, "row is out of bounds (exceeds number of rows: "..tableElement.numRows..")"
	end

	if row <= tableElement.numFixedRows then
		return nil, 4, "top row cannot be set to a fixed row"
	end

	if not widgetSystem.hasNonFixedRows(tableElement) then
		return nil, 5, "cannot set top row in table not containing normal (non-fixed) rows"
	end

	if row > tableElement.topRow then
		widgetSystem.scrollDown(tableID, tableElement, row - tableElement.topRow)
	elseif row < tableElement.topRow then
		widgetSystem.scrollUp(tableID, tableElement, tableElement.topRow - row)
	end
	-- row == tableentry.topRow - nothing to do

	return tableElement.topRow
end

-- isSelected = indicates whether the button is the current selected one
-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth  = width of the parent (anchor element)
-- parentheight = height of the parent (anchor element)
function widgetSystem.setUpButton(frameElement, buttonID, buttonElement, isSelected, parentx, parenty, parentwidth, parentheight, backgroundcolspanwidth)
	buttonElement.active = IsButtonActive(buttonID)
	buttonElement.previouslyActive = false
	buttonElement.buttonState = {
		["mouseClick"]       = false,
		["keyboard"]         = isSelected,
		["keyboardPress"]    = false,
		["mouseOver"]        = false
	}

	-- propagate parent height/width, unless specified explicitly
	local width, height = GetSize(buttonID)
	if (width == 0) or (width > parentwidth) then
		width = parentwidth
	end
	if height == 0 then
		height = parentheight
	end

	local showHotkey, hotkeyIconID, hotkeyOffsetX, hotkeyOffsetY = GetButtonHotkeyDetails(buttonID)
	-- zero nil-values, so we do not have to check for nil in following calculations
	hotkeyOffsetX = hotkeyOffsetX or 0
	hotkeyOffsetY = hotkeyOffsetY or 0

	-- #StefanMed - this check really doesn't belong here - either perform the check during setUpTable() or refactor the width/height calculation and perform the checks in Button::SetWidth/SetHeight
	local minSize = config.button.minButtonSize
	if showHotkey then
		minSize = minSize + config.button.hotkeyIconSize
	end
	if height < minSize or width < minSize then
		DebugError("Widget system error. Dimensions for button are too small. Button elements will overlap eachother. Dimensions are: width("..tostring(width).." px) height("..tostring(height).." px) - minimum dimensions for this button is "..tostring(minSize).." px")
		-- still display the garbled button so we can see which button is set up incorrectly
	end

	-- position button
	local x, y = GetOffset(buttonID)
	local offsetx = x + parentx + width/2
	local offsety = parenty - y - height/2
	widgetSystem.setElementPosition(buttonElement.element, offsetx, offsety, (width % 2 ~= 0), (height % 2 ~= 0))

	widgetSystem.addHelpOverlay(frameElement, buttonID, x + parentx, parenty - y, width, height, nil, backgroundcolspanwidth)

	-- scale button
	for _, elementName in ipairs(config.button.scaleElements) do
		widgetSystem.setElementScale(getElement(elementName, buttonElement.element), width / 100, height / 100)
	end

	-- set the button state first, so elements are activated in-time
	widgetSystem.updateButtonState(buttonID, buttonElement)

	local font, size = GetButtonTextFont(buttonID)

	-- hotkey
	if showHotkey then
		buttonElement.hotkeyIconActive = true
		local hotkeyElement = getElement("Hotkey", buttonElement.element)
		goToSlide(hotkeyElement, "active")

		local textwidth = C.GetTextWidth(hotkeyIconID, font, size)
		widgetSystem.setElementPosition(hotkeyElement, -width/2 + hotkeyOffsetX - config.texturesizes.button.borderSize, config.texturesizes.button.borderSize - hotkeyOffsetY)
		local color = Color["hotkey"]		local textelement = getElement("Text", hotkeyElement)
		setAttribute(textelement, "textstring", hotkeyIconID)
		setAttribute(textelement, "font", font)
		setAttribute(textelement, "size", size)
		setAttribute(textelement, "textcolor.r", color.r)
		setAttribute(textelement, "textcolor.g", color.g)
		setAttribute(textelement, "textcolor.b", color.b)
		setAttribute(textelement, "opacity", color.a)
		setAttribute(textelement, "glowfactor", color.glow)
	end

	-- icon
	local iconID = GetButtonIcon(buttonID)
	if iconID ~= nil then
		buttonElement.iconActive = true
		local iconElement = getElement("Icon", buttonElement.element)
		goToSlide(iconElement, "active")
		r, g, b, a = GetButtonIconColor(buttonID)
		local glowfactor = C.GetButtonIconGlowFactor(buttonID)
		if not buttonElement.active then
			local color = Color["button_text_inactive"]
			r, g, b = color.r, color.g, color.b
			glowfactor = color.glow
		end
		buttonElement.iconID = iconID
		buttonElement.swapIconID = GetButtonSwapIcon(buttonID)
		buttonElement.iconColor = {
			["r"] = r,
			["g"] = g,
			["b"] = b,
			["a"] = a
		}
		local iconWidth, iconHeight = GetButtonIconSize(buttonID)
		if iconWidth ~= 0 and iconHeight ~= 0 then
			-- icon offsets only apply, if we do not have a full-sized icon (aka: iconWidth and/or iconHeight is != 0)
			local iconOffsetX, iconOffsetY = GetButtonIconOffset(buttonID)
			iconOffsetX = iconOffsetX - width/2 + iconWidth / 2
			iconOffsetY = - iconOffsetY + height/2 - iconHeight / 2
			widgetSystem.setElementPosition(iconElement, iconOffsetX, iconOffsetY)
		else
			iconWidth  = width  - 2*config.texturesizes.button.borderSize
			iconHeight = height - 2*config.texturesizes.button.borderSize
		end
		buttonElement.iconWidth  = iconWidth
		buttonElement.iconHeight = iconHeight
		-- set icon
		local material = getElement("Icon.Icon.Material423", buttonElement.element)
		SetIcon(getElement("Icon", material), iconID, r, g, b, false, iconWidth, iconHeight)
		setAttribute(material, "opacity", a)
		setAttribute(material, "glowfactor", glowfactor)
	end

	-- icon2
	local icon2ID = GetButtonIcon2(buttonID)
	if icon2ID ~= nil then
		buttonElement.icon2Active = true
		local iconElement = getElement("Icon2", buttonElement.element)
		goToSlide(iconElement, "active")
		r, g, b, a = GetButtonIcon2Color(buttonID)
		if not buttonElement.active then
			r, g, b = widgetSystem.invertColor(r, g, b)
		end
		buttonElement.icon2ID = icon2ID
		buttonElement.swapIcon2ID = GetButtonSwapIcon2(buttonID)
		buttonElement.icon2Color = {
			["r"] = r,
			["g"] = g,
			["b"] = b,
			["a"] = a
		}
		local iconWidth, iconHeight = GetButtonIcon2Size(buttonID)
		if iconWidth ~= 0 and iconHeight ~= 0 then
			-- icon offsets only apply, if we do not have a full-sized icon (aka: iconWidth and/or iconHeight is != 0)
			local iconOffsetX, iconOffsetY = GetButtonIcon2Offset(buttonID)
			iconOffsetX = iconOffsetX - width/2 + iconWidth / 2
			iconOffsetY = - iconOffsetY + height/2 - iconHeight / 2
			widgetSystem.setElementPosition(iconElement, iconOffsetX, iconOffsetY)
		else
			iconWidth  = width  - 2*config.texturesizes.button.borderSize
			iconHeight = height - 2*config.texturesizes.button.borderSize
		end
		buttonElement.icon2Width  = iconWidth
		buttonElement.icon2Height = iconHeight
		-- set icon2
		local material = getElement("Icon2.Icon2.Imaterial_icon2", buttonElement.element)
		SetIcon(getElement("icon2", material), icon2ID, r, g, b, false, iconWidth, iconHeight)
		setAttribute(material, "opacity", a)
		local glowfactor = C.GetButtonIcon2GlowFactor(buttonID)
		setAttribute(material, "glowfactor", glowfactor)
	end

	local text = GetButtonText(buttonID)
	if text ~= "" then
		buttonElement.textActive = true
		-- button text
		local alignment = GetButtonTextAlignment(buttonID)
		-- calculate horizontal offset for proper alignment
		local textOffsetX, textOffsetY = GetButtonTextOffset(buttonID)
		if alignment == "left" then
			textOffsetX = textOffsetX - width/2 + config.texturesizes.button.borderSize
		elseif alignment == "center" then
			-- nothing to do
		else -- right
			textOffsetX = -textOffsetX + width/2 - config.texturesizes.button.borderSize
		end
		local textelement = getElement("Text", buttonElement.element)
		widgetSystem.setElementPosition(textelement, textOffsetX, textOffsetY)
		setAttribute(textelement, "horzalign", widgetSystem.convertAlignment(alignment))
		-- text font
		setAttribute(textelement, "font", font)
		setAttribute(textelement, "size", size)
		-- text color is done in widgetSystem.updateButtonState()
	end

	local textinfo = ffi.new("TextInfo")
	local hastext2 = C.GetButtonText2Details(buttonID, textinfo)

	if hastext2 then
		buttonElement.text2Active = true
		buttonElement.text2 = ffi.string(textinfo.text)
		textinfo.alignment = ffi.string(textinfo.alignment)
		buttonElement.text2Color = textinfo.color
		-- calculate horizontal offset for proper alignment
		local offsetx, offsety = textinfo.x, textinfo.y
		if textinfo.alignment == "left" then
			offsetx = offsetx - width/2 + config.texturesizes.button.borderSize
		elseif textinfo.alignment == "center" then
			-- nothing to do
		else -- right
			offsetx = -offsetx + width/2 - config.texturesizes.button.borderSize
		end
		local textelement = getElement("Text2", buttonElement.element)
		widgetSystem.setElementPosition(textelement, offsetx, offsety)
		setAttribute(textelement, "horzalign", widgetSystem.convertAlignment(textinfo.alignment))
		-- text font
		setAttribute(textelement, "font", ffi.string(textinfo.font.name))
		setAttribute(textelement, "size", textinfo.font.size)
		-- text color is done in widgetSystem.updateButtonState()
	end

	widgetSystem.addToAssociationList(buttonID, buttonElement, buttonElement.element, parentx, parenty, parentwidth)
	widgetSystem.updateButton(buttonID, buttonElement)
end

-- isSelected = indicates whether the checkbox is the current selected one
-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth  = width of the parent (anchor element)
-- parentheight = height of the parent (anchor element)
function widgetSystem.setUpCheckBox(frameElement, checkboxID, checkboxElement, isSelected, parentx, parenty, parentwidth, parentheight, backgroundcolspanwidth)
	checkboxElement.active = C.IsCheckBoxActive(checkboxID)
	checkboxElement.previouslyActive = false
	checkboxElement.checked = C.IsCheckBoxChecked(checkboxID)
	checkboxElement.symbol = ffi.string(C.GetCheckBoxSymbol(checkboxID))
	checkboxElement.checkboxState = {
		["mouseClick"]       = false,
		["keyboard"]         = isSelected,
		["keyboardPress"]    = false,
		["mouseOver"]        = false
	}

	-- propagate parent height/width, unless specified explicitly
	local width, height = GetSize(checkboxID)
	if width == 0 then
		width = parentwidth
	end
	if height == 0 then
		height = parentheight
	end

	-- #StefanMed - this check really doesn't belong here - either perform the check during setUpTable() or refactor the width/height calculation and perform the checks in CheckBox::SetWidth/SetHeight
	local minSize = config.checkbox.minCheckBoxSize
	if height < minSize or width < minSize then
		DebugError("Widget system error. Dimensions for checkbox are too small. Checkbox elements will overlap eachother. Dimensions are: width("..tostring(width).." px) height("..tostring(height).." px) - minimum dimensions for this checkbox is "..tostring(minSize).." px")
		-- still display the garbled button so we can see which button is set up incorrectly
	end

	-- position checkbox
	local x, y = GetOffset(checkboxID)
	local offsetx = x + parentx + width/2
	local offsety = parenty - y - height/2
	widgetSystem.setElementPosition(checkboxElement.element, offsetx, offsety, (width % 2 ~= 0), (height % 2 ~= 0))

	widgetSystem.addHelpOverlay(frameElement, checkboxID, x + parentx, parenty - y, width, height, nil, backgroundcolspanwidth)

	-- scale checkbox
	for _, element in ipairs(config.checkbox.scaleElements) do
		widgetSystem.setElementScale(getElement(element[1], checkboxElement.element), width / 100 * element[2], height / 100 * element[2])
	end

	if checkboxElement.symbol == "circle" then
		widgetSystem.setElementScale(getElement("arrow", checkboxElement.element), 0, 0)
	elseif checkboxElement.symbol == "arrow" then
		widgetSystem.setElementScale(getElement("circle", checkboxElement.element), 0, 0)
	end

	-- color
	local color = ffi.new("Color")
	if C.GetCheckBoxColor(checkboxID, color) then
		checkboxElement.color = {
			["r"] = color.red,
			["g"] = color.green,
			["b"] = color.blue,
			["a"] = color.alpha,
			["glow"] = C.GetCheckBoxGlowFactor(checkboxID)
		}
	end
	checkboxElement.symbolglowfactor = C.GetCheckBoxSymbolGlowFactor(checkboxID)

	if not checkboxElement.active then-- inactive checkbox
		local color = Color["checkbox_background_inactive"]
		local material = getElement("background.Material753", checkboxElement.element)
		SetDiffuseColor(material, color.r, color.g, color.b)
		setAttribute(material, "opacity", color.a)
		setAttribute(material, "glowfactor", color.glow)
	end

	-- set the checkbox state first, so elements are activated in-time
	widgetSystem.updateCheckBoxState(checkboxID, checkboxElement)

	widgetSystem.addToAssociationList(checkboxID, checkboxElement, checkboxElement.element, parentx, parenty, parentwidth)
	widgetSystem.updateCheckBox(checkboxID, checkboxElement)
end

-- isSelected = indicates whether the checkbox is the current selected one
-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth  = width of the parent (anchor element)
-- parentheight = height of the parent (anchor element)
function widgetSystem.setUpDropDown(frameElement, dropdownID, dropdownElement, isSelected, parentx, parenty, parentwidth, parentheight, backgroundcolspanwidth)
	dropdownElement.active = C.IsDropDownActive(dropdownID)
	dropdownElement.previouslyActive = false
	dropdownElement.allowMouseOverInteraction = C.IsDropDownMouseOverInteractionAllowed(dropdownID)
	dropdownElement.dropdownState = {
		["mouseClick"]       = false,
		["keyboard"]         = isSelected,
		["keyboardPress"]    = false,
		["mouseOver"]        = false
	}
	
	local hotkeyDetails = {}
	local values = ffi.new("HotkeyInfo")
	if C.GetDropDownHotkeyDetails(dropdownID, values) then
		hotkeyDetails.display = values.display
		hotkeyDetails.iconid = ffi.string(values.iconid)
		hotkeyDetails.x = values.x
		hotkeyDetails.y = values.y
	end

	-- propagate parent height/width, unless specified explicitly
	local width, height = GetSize(dropdownID)
	if width == 0 then
		width = parentwidth
	end
	if height == 0 then
		height = parentheight
	end

	local optionwidth = C.GetDropDownOptionWidth(dropdownID)
	if optionwidth == 0 then
		optionwidth = width
	end
	local optionheight = C.GetDropDownOptionHeight(dropdownID)

	-- #StefanMed - this check really doesn't belong here - either perform the check during setUpTable() or refactor the width/height calculation and perform the checks in CheckBox::SetWidth/SetHeight
	local minSize = config.dropdown.minDropDownSize
	if hotkeyDetails.display then
		minSize = minSize + config.dropdown.hotkeyIconSize
	end
	if height < minSize or width < minSize then
		DebugError("Widget system error. Dimensions for dropdown are too small. Dropdown elements will overlap eachother. Dimensions are: width("..tostring(width).." px) height("..tostring(height).." px) - minimum dimensions for this dropdown is "..tostring(minSize).." px")
		-- still display the garbled dropdown so we can see which dropdown is set up incorrectly
	end

	dropdownElement.width = width
	dropdownElement.optionwidth = optionwidth
	dropdownElement.optionheight = optionheight
	dropdownElement.height = height
	dropdownElement.fullHeight = height

	-- position dropdown
	local x, y = GetOffset(dropdownID)
	dropdownElement.offsetx = x + parentx + width/2
	dropdownElement.offsety = parenty - y - height/2
	widgetSystem.setElementPosition(dropdownElement.element.mainElement, dropdownElement.offsetx, dropdownElement.offsety, (width % 2 ~= 0), (height % 2 ~= 0))

	widgetSystem.addHelpOverlay(frameElement, dropdownID, x + parentx, parenty - y, dropdownElement.width, dropdownElement.height, nil, backgroundcolspanwidth)

	-- scale dropdown
	for _, element in ipairs(config.dropdown.scaleElements) do
		widgetSystem.setElementScale(getElement(element, dropdownElement.element.mainElement), width / 100, height / 100)
	end

	-- options bg
	local optionsBGElement = getElement("options_bg", dropdownElement.element.mainElement)
	local color = ffi.new("Color")
	if C.GetDropDownOptionColor(dropdownID, color) then
		dropdownElement.optioncolor = {
			["r"] = color.red,
			["g"] = color.green,
			["b"] = color.blue,
			["a"] = color.alpha,
			["glow"] = C.GetDropDownOptionGlowFactor(dropdownID),
		}
		
		local material = getElement("Material753", optionsBGElement)
		SetDiffuseColor(material, dropdownElement.optioncolor.r, dropdownElement.optioncolor.g, dropdownElement.optioncolor.b)
		setAttribute(material, "glowfactor", dropdownElement.optioncolor.glow)
	end
	setAttribute(optionsBGElement, "opacity", 0)

	-- update dropdown color for active dropdown (inactive dropdowns have a fixed color and therefore can never change their initially set up color)
	local color = ffi.new("Color")
	if C.GetDropDownColor(dropdownID, color) then
		dropdownElement.color = {
			["r"] = color.red,
			["g"] = color.green,
			["b"] = color.blue,
			["a"] = color.alpha,
			["glow"] = C.GetDropDownGlowFactor(dropdownID),
		}
	end

	local material = getElement("background.Material753", dropdownElement.element.mainElement)
	if dropdownElement.active then
		SetDiffuseColor(material, dropdownElement.color.r, dropdownElement.color.g, dropdownElement.color.b)
		setAttribute(material, "opacity", dropdownElement.color.a)
		setAttribute(material, "glowfactor", dropdownElement.color.glow)
	else -- inactive dropdown
		local color = Color["dropdown_background_inactive"]
		SetDiffuseColor(material, color.r, color.g, color.b)
		setAttribute(material, "opacity", color.a)
		setAttribute(material, "glowfactor", color.glow)
	end

	-- border elements
	for _, element in ipairs(config.dropdown.borderElements) do
		local anarkElement = getElement(element, dropdownElement.element.mainElement)
		widgetSystem.setElementScale(anarkElement, config.dropdown.borderSize / 100, config.dropdown.borderSize / 100)

		if dropdownElement.active then
			local material = getElement("Material753", anarkElement)
			SetDiffuseColor(material, dropdownElement.color.r, dropdownElement.color.g, dropdownElement.color.b)
			setAttribute(material, "glowfactor", dropdownElement.color.glow)
		end
		setAttribute(anarkElement, "opacity", 0)
	end

	dropdownElement.options = {}
	dropdownElement.curOption = {}

	-- hotkey
	if hotkeyDetails.display then
		dropdownElement.hotkeyIconActive = true
		local hotkeyElement = getElement("Hotkey", dropdownElement.element.mainElement)
		goToSlide(hotkeyElement, "active")
		widgetSystem.setElementPosition(hotkeyElement, -width/2 + hotkeyDetails.x + config.dropdown.hotkeyIconSize/2 + config.texturesizes.dropdown.borderSize, height/2 - hotkeyDetails.y - config.dropdown.hotkeyIconSize/2 - config.texturesizes.dropdown.borderSize)
		local color = Color["hotkey"]
		SetIcon(getElement("Icon.material.Icon", hotkeyElement), hotkeyDetails.iconid, color.r, color.g, color.b, true, config.dropdown.hotkeyIconSize, config.dropdown.hotkeyIconSize)
		local material = getElement("Icon.material", hotkeyElement)
		setAttribute(material, "opacity", color.a)
		setAttribute(material, "glowfactor", color.glow)
	end

	-- options
	local hasText2 = false
	local startOption = ffi.string(C.GetDropDownStartOption(dropdownID))
	local n = C.GetNumDropDownOptions(dropdownID)
	local buf = ffi.new("DropDownOption2[?]", n)
	n = C.GetDropDownOptions2(buf, n, dropdownID)
	for i = 0, n - 1 do
		local entry = {}

		entry.id = ffi.string(buf[i].id)
		entry.icon = ffi.string(buf[i].iconid)
		entry.text = ffi.string(buf[i].text)
		entry.text2 = ffi.string(buf[i].text2)
		if entry.text2 ~= "" then
			hasText2 = true
		end
		entry.mouseovertext = ffi.string(buf[i].mouseovertext)
		entry.font = ffi.string(buf[i].font)
		entry.displayRemoveOption = buf[i].displayRemoveOption
		entry.hasOverrideColor = buf[i].hasOverrideColor
		if entry.hasOverrideColor then
			entry.overrideColor = {
				["red"] = buf[i].overrideColor.red,
				["green"] = buf[i].overrideColor.green,
				["blue"] = buf[i].overrideColor.blue,
				["alpha"] = buf[i].overrideColor.alpha
			}
		end
		entry.active = buf[i].active

		table.insert(dropdownElement.options, entry)

		if startOption ~= "" and (startOption == entry.id) then
			dropdownElement.curOption = entry
		end
	end

	dropdownElement.optionOverlays = {}
	local buf = ffi.new("UIOverlayInfo2[?]", n)
	n = C.GetDropDownOptionOverlayInfo(buf, n, dropdownID)
	for i = 0, n - 1 do
		table.insert(dropdownElement.optionOverlays, {
			id = ffi.string(buf[i].id),
			text = ffi.string(buf[i].text),
			x = buf[i].x,
			y = buf[i].y,
			width = buf[i].width,
			height = buf[i].height,
			highlightonly = buf[i].highlightonly,
			usebackgroundspan = buf[i].usebackgroundspan,
		})
	end
	
	-- arrow
	dropdownElement.arrowHeight = height - 2 * config.texturesizes.dropdown.borderSize
	local arrowElement = getElement("Arrow", dropdownElement.element.mainElement)
	goToSlide(arrowElement, "active")
	widgetSystem.setElementPosition(arrowElement, - width / 2 + config.texturesizes.dropdown.borderSize + dropdownElement.arrowHeight / 2)
	widgetSystem.setElementScale(arrowElement, dropdownElement.arrowHeight / 100, dropdownElement.arrowHeight / 100)

	-- iconDetails
	dropdownElement.iconDetails = {}
	local buf = ffi.new("DropDownIconInfo")
	if C.GetDropDownIconDetails(dropdownID, buf) then
		dropdownElement.iconDetails.color = {}
		dropdownElement.iconDetails.color.red = buf.color.red
		dropdownElement.iconDetails.color.green = buf.color.green
		dropdownElement.iconDetails.color.blue = buf.color.blue
		dropdownElement.iconDetails.color.alpha = buf.color.alpha
		dropdownElement.iconDetails.width = buf.width
		dropdownElement.iconDetails.height = buf.height
		dropdownElement.iconDetails.x = buf.x
		dropdownElement.iconDetails.y = buf.y
		dropdownElement.iconDetails.glowfactor = buf.glowfactor

		dropdownElement.iconActive = true
	end

	-- textDetails
	dropdownElement.textDetails = {}
	local buf = ffi.new("DropDownTextInfo")
	if C.GetDropDownTextDetails(dropdownID, buf) then
		dropdownElement.textDetails.color = {}
		dropdownElement.textDetails.color.red = buf.color.red
		dropdownElement.textDetails.color.green = buf.color.green
		dropdownElement.textDetails.color.blue = buf.color.blue
		dropdownElement.textDetails.color.alpha = buf.color.alpha
		dropdownElement.textDetails.fontname = ffi.string(buf.font.name)
		dropdownElement.textDetails.fontsize = buf.font.size
		dropdownElement.textDetails.alignment = ffi.string(buf.alignment)
		dropdownElement.textDetails.x = buf.x
		dropdownElement.textDetails.y = buf.y
		dropdownElement.textDetails.textOverride = ffi.string(buf.textOverride)
		dropdownElement.textDetails.glowfactor = buf.glowfactor

		dropdownElement.textActive = true
	end

	-- textDetails
	dropdownElement.text2Details = {}
	if hasText2 then
		local buf = ffi.new("DropDownTextInfo")
		if C.GetDropDownText2Details(dropdownID, buf) then
			dropdownElement.text2Details.color = {}
			dropdownElement.text2Details.color.red = buf.color.red
			dropdownElement.text2Details.color.green = buf.color.green
			dropdownElement.text2Details.color.blue = buf.color.blue
			dropdownElement.text2Details.color.alpha = buf.color.alpha
			dropdownElement.text2Details.fontname = ffi.string(buf.font.name)
			dropdownElement.text2Details.fontsize = buf.font.size
			dropdownElement.text2Details.alignment = ffi.string(buf.alignment)
			dropdownElement.text2Details.x = buf.x
			dropdownElement.text2Details.y = buf.y
			dropdownElement.text2Details.textOverride = ffi.string(buf.textOverride)
			dropdownElement.text2Details.glowfactor = buf.glowfactor

			dropdownElement.text2Active = true
		end
	end

	-- set the dropdown state first, so elements are activated in-time
	widgetSystem.updateDropDownState(dropdownID, dropdownElement)

	-- icon
	if dropdownElement.iconActive then
		local iconElement = getElement("Icon", dropdownElement.element.mainElement)
		if not dropdownElement.active then
			local color = Color["dropdown_text_inactive"]
			dropdownElement.iconDetails.color.red, dropdownElement.iconDetails.color.green, dropdownElement.iconDetails.color.blue = color.r, color.g, color.b
		end
		if dropdownElement.iconDetails.width ~= 0 and dropdownElement.iconDetails.height ~= 0 then
			-- icon offsets only apply, if we do not have a full-sized icon (aka: iconWidth and/or iconHeight is != 0)
			dropdownElement.iconDetails.x = dropdownElement.iconDetails.x - width/2 + dropdownElement.iconDetails.width / 2 + dropdownElement.arrowHeight
			dropdownElement.iconDetails.y = - dropdownElement.iconDetails.y + height/2 - dropdownElement.iconDetails.height / 2
		else
			dropdownElement.iconDetails.x = dropdownElement.arrowHeight / 2
			dropdownElement.iconDetails.y = 0
			dropdownElement.iconDetails.width  = width  - 2 * config.texturesizes.dropdown.borderSize - dropdownElement.arrowHeight
			dropdownElement.iconDetails.height = height - 2 * config.texturesizes.dropdown.borderSize
		end
		widgetSystem.setElementPosition(iconElement, dropdownElement.iconDetails.x, dropdownElement.iconDetails.y)
		-- icon is set in widgetSystem.updateDropDown()
	end

	-- text
	if dropdownElement.textActive then
		-- calculate horizontal offset for proper alignment
		if dropdownElement.textDetails.alignment == "left" then
			dropdownElement.textDetails.x = dropdownElement.textDetails.x - width/2 + config.texturesizes.button.borderSize + dropdownElement.arrowHeight
		elseif dropdownElement.textDetails.alignment == "center" then
			-- nothing to do
		else -- right
			dropdownElement.textDetails.x = -dropdownElement.textDetails.x + width/2 - config.texturesizes.button.borderSize
		end
		local textelement = getElement("Text", dropdownElement.element.mainElement)
		widgetSystem.setElementPosition(textelement, dropdownElement.textDetails.x, dropdownElement.textDetails.y)
		setAttribute(textelement, "horzalign", widgetSystem.convertAlignment(dropdownElement.textDetails.alignment))
		-- text font
		setAttribute(textelement, "font", dropdownElement.textDetails.fontname)
		setAttribute(textelement, "size", dropdownElement.textDetails.fontsize)
		-- text color is done in widgetSystem.updateDropDownState()
		-- text is set in widgetSystem.updateDropDown()
	end

	-- text2
	if dropdownElement.text2Active then
		-- calculate horizontal offset for proper alignment
		if dropdownElement.text2Details.alignment == "left" then
			dropdownElement.text2Details.x = dropdownElement.text2Details.x - width/2 + config.texturesizes.button.borderSize + dropdownElement.arrowHeight
		elseif dropdownElement.text2Details.alignment == "center" then
			-- nothing to do
		else -- right
			dropdownElement.text2Details.x = -dropdownElement.text2Details.x + width/2 - config.texturesizes.button.borderSize
		end
		local text2element = getElement("Text2", dropdownElement.element.mainElement)
		widgetSystem.setElementPosition(text2element, dropdownElement.text2Details.x, dropdownElement.text2Details.y)
		setAttribute(text2element, "horzalign", widgetSystem.convertAlignment(dropdownElement.text2Details.alignment))
		-- text font
		setAttribute(text2element, "font", dropdownElement.text2Details.fontname)
		setAttribute(text2element, "size", dropdownElement.text2Details.fontsize)
		-- text2 color is done in widgetSystem.updateDropDownState()
		-- text2 is set in widgetSystem.updateDropDown()
	end

	widgetSystem.addToAssociationList(dropdownID, dropdownElement, dropdownElement.element.mainElement, parentx, parenty, parentwidth)
	widgetSystem.updateDropDown(dropdownID, dropdownElement)
end

-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth  = width of the parent (anchor element)
-- parentheight = height of the parent (anchor element)
function widgetSystem.setUpEditBox(frameElement, editboxID, editboxElement, parentx, parenty, parentwidth, parentheight, backgroundcolspanwidth)
	-- propagate parent height/width, unless specified explicitly
	local width, height = GetSize(editboxID)
	if width == 0 then
		width = parentwidth
	end
	if height == 0 then
		height = parentheight
	end

	editboxElement.width = width
	editboxElement.height = height

	local showHotkey, hotkeyIconID, hotkeyOffsetX, hotkeyOffsetY = GetEditBoxHotkeyDetails(editboxID)
	-- zero nil-values, so we do not have to check for nil in following calculations
	hotkeyOffsetX = hotkeyOffsetX or 0
	hotkeyOffsetY = hotkeyOffsetY or 0

	editboxElement.widgetActive = C.IsEditBoxActive(editboxID)
	editboxElement.restoreInteractiveElement = C.ShouldEditBoxRestoreInteractiveObject(editboxID)

	-- #StefanMed - this check really doesn't belong here - either perform the check during setUpTable() or refactor the width/height calculation and perform the checks in EditBox::SetWidth/SetHeight
	local minSize = config.editbox.minEditBoxSize
	if showHotkey then
		minSize = minSize + config.editbox.hotkeyIconSize
	end
	if height < minSize or width < minSize then
		DebugError("Widget system error. Dimensions for editbox are too small. Editbox elements will overlap eachother. Dimensions are: width("..tostring(width).." px) height("..tostring(height).." px) - minimum dimensions for this editbox is "..tostring(minSize).." px")
		-- still display the garbled editbox so we can see which editbox is set up incorrectly
	end

	-- position editbox
	local x, y = GetOffset(editboxID)
	local offsetx = x + parentx
	local offsety = parenty - y - height/2
	widgetSystem.setElementPosition(editboxElement.element, offsetx, offsety, (width % 2 ~= 0), (height % 2 ~= 0))

	widgetSystem.addHelpOverlay(frameElement, editboxID, x + parentx - width / 2, parenty - y, width, height, nil, backgroundcolspanwidth)

	-- scale editbox
	for _, element in ipairs(config.editbox.scaleElements) do
		widgetSystem.setElementScale(getElement(element[1], editboxElement.element), (width - 2 * element[2]) / 100, (height - 2 * element[2]) / 100)
	end

	-- editbox color
	widgetSystem.setEditBoxColors(editboxID, editboxElement)

	editboxElement.font, editboxElement.fontsize = GetEditBoxFont(editboxID)

	-- hotkey
	if showHotkey then
		editboxElement.hotkeyIconActive = true
		local hotkeyElement = getElement("Hotkey", editboxElement.element)
		goToSlide(hotkeyElement, "active")

		local textwidth = C.GetTextWidth(hotkeyIconID, editboxElement.font, editboxElement.fontsize)
		widgetSystem.setElementPosition(hotkeyElement, -width/2 + hotkeyOffsetX - 2 * config.texturesizes.editbox.borderSize, config.texturesizes.editbox.borderSize - hotkeyOffsetY)
		local color = Color["hotkey"]
		local textelement = getElement("Text", hotkeyElement)
		setAttribute(textelement, "textstring", hotkeyIconID)
		setAttribute(textelement, "font", editboxElement.font)
		setAttribute(textelement, "size", editboxElement.fontsize)
		setAttribute(textelement, "textcolor.r", color.r)
		setAttribute(textelement, "textcolor.g", color.g)
		setAttribute(textelement, "textcolor.b", color.b)
		setAttribute(textelement, "opacity", color.a)
		setAttribute(textelement, "glowfactor", color.glow)
	end

	-- editbox text
	editboxElement.textAlignment = GetEditBoxTextAlignment(editboxID)
	-- calculate horizontal offset for proper alignment
	editboxElement.rawTextOffsetX, editboxElement.rawTextOffsetY = C.GetEditBoxTextOffsetX(editboxID), C.GetEditBoxTextOffsetY(editboxID)
	editboxElement.textOffsetX, editboxElement.textOffsetY = editboxElement.rawTextOffsetX, editboxElement.rawTextOffsetY
	if editboxElement.textAlignment == "left" then
		editboxElement.textOffsetX = editboxElement.textOffsetX - width/2 + config.texturesizes.editbox.borderSize
	elseif editboxElement.textAlignment == "center" then
		-- nothing to do
	else -- right
		editboxElement.textOffsetX = -editboxElement.textOffsetX + width/2 - config.texturesizes.editbox.borderSize
	end
	local textelement = getElement("Text", editboxElement.element)
	widgetSystem.setElementPosition(textelement, editboxElement.textOffsetX, editboxElement.textOffsetY)
	setAttribute(textelement, "horzalign", widgetSystem.convertAlignment(editboxElement.textAlignment))
	-- text font
	setAttribute(textelement, "font", editboxElement.font)
	setAttribute(textelement, "size", editboxElement.fontsize)

	-- closemenuonback option
	editboxElement.closeMenuOnBack = GetEditBoxCloseMenuOption(editboxID)

	-- text hidden option
	editboxElement.textHidden = C.IsEditBoxTextHidden(editboxID)
	
	-- input encryption
	editboxElement.encrypted = C.IsEditBoxInputEncrypted(editboxID)

	-- max chars
	editboxElement.maxChars = C.GetEditBoxMaxChars(editboxID)

	-- cursor setup
	local cursorheight = C.GetTextHeight(config.editbox.cursor, editboxElement.font, editboxElement.fontsize, 0)
	local cursorelement = getElement("Cursor.cursor", editboxElement.element)
	widgetSystem.setElementScale(cursorelement, config.editbox.cursorWidth / 100, cursorheight / 100 * config.editbox.cursorHeightFactor)
	local material = getElement("Material1320", cursorelement)
	SetDiffuseColor(material, editboxElement.textColor.r, editboxElement.textColor.g, editboxElement.textColor.b)
	setAttribute(material, "opacity", 0)
	setAttribute(material, "glowfactor", editboxElement.glowfactor)

	-- highlight setup
	editboxElement.selectTextOnActivation = (not editboxElement.encrypted) and C.IsEditBoxTextSelectedOnActivation(editboxID)
	editboxElement.shiftStartPos = nil
	local highlightelement = getElement("highlight", editboxElement.element)
	widgetSystem.setElementScale(highlightelement, nil, cursorheight / 100 * config.editbox.cursorHeightFactor)
	local material = getElement("Material689", highlightelement)
	local color = Color["editbox_border"]
	SetDiffuseColor(material, color.r, color.g, color.b)
	setAttribute(material, "opacity", 0)
	setAttribute(material, "glowfactor", color.glow)

	-- activate the editbox
	goToSlide(editboxElement.element, "active")

	widgetSystem.addToAssociationList(editboxID, editboxElement, editboxElement.element, parentx, parenty, parentwidth)
	editboxElement.defaultText = ffi.string(C.GetEditBoxDefaultText(editboxID))
	editboxElement.description = ffi.string(C.GetEditBoxDescription(editboxID))
	widgetSystem.setEditBoxText(editboxElement, GetEditBoxText(editboxID))
end

function widgetSystem.setEditBoxColors(editboxID, editboxElement)
	-- set color
	if editboxElement.widgetActive then
		local r, g, b, a = GetEditBoxColor(editboxID)
		editboxElement.color = {
			["r"] = r,
			["g"] = g,
			["b"] = b,
			["a"] = a,
			["glow"] = C.GetEditBoxGlowFactor(editboxID),
		}
	else
		editboxElement.color = Color["editbox_inactive"]
	end
	local material = getElement("background.Material689", editboxElement.element)
	SetDiffuseColor(material, editboxElement.color.r, editboxElement.color.g, editboxElement.color.b)
	setAttribute(material, "opacity", editboxElement.color.a)
	setAttribute(material, "glowfactor", editboxElement.color.glow)

	-- set the editbox text color
	if editboxElement.widgetActive then
		local r, g, b, a = GetEditBoxTextColor(editboxID)
		editboxElement.textColor = {
			["r"] = r,
			["g"] = g,
			["b"] = b,
			["a"] = a
		}
		editboxElement.glowfactor = C.GetEditBoxTextGlowFactor(editboxID)
	else
		local color = Color["editbox_inactive"]
		editboxElement.textColor = color
		editboxElement.glowfactor = color.glow
	end
	-- text color is set in widgetSystem.setEditBoxText()

	local material = getElement("Cursor.cursor.Material1320", editboxElement.element)
	SetDiffuseColor(material, editboxElement.textColor.r, editboxElement.textColor.g, editboxElement.textColor.b)
	setAttribute(material, "opacity", 0)
end

function widgetSystem.setEditBoxText(editboxElement, text)
	editboxElement.text = text
	editboxElement.cursorPos = utf8.len(editboxElement.text)
	local newtext
	if editboxElement.active then
		newtext = text
	else
		newtext = TruncateText(text, editboxElement.font, editboxElement.fontsize, (editboxElement.width - 2 * (editboxElement.rawTextOffsetX + config.texturesizes.editbox.borderSize)))
	end
	local textelement = getElement("Text", editboxElement.element)
	if (editboxElement.text ~= "") or editboxElement.active then
		setAttribute(textelement, "textstring", widgetSystem.hideText(newtext, editboxElement.textHidden))
		setAttribute(textelement, "textcolor.r", editboxElement.textColor.r)
		setAttribute(textelement, "textcolor.g", editboxElement.textColor.g)
		setAttribute(textelement, "textcolor.b", editboxElement.textColor.b)
		setAttribute(textelement, "opacity", editboxElement.textColor.a)
	else
		local color = Color["editbox_text_default"]
		setAttribute(textelement, "textstring", editboxElement.defaultText)
		setAttribute(textelement, "textcolor.r", color.r)
		setAttribute(textelement, "textcolor.g", color.g)
		setAttribute(textelement, "textcolor.b", color.b)
		setAttribute(textelement, "opacity", color.a)
	end
	setAttribute(textelement, "glowfactor", editboxElement.glowfactor)
end

-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth = width of the parent (anchor element)
function widgetSystem.setUpFlowchart(frameElement, flowchartID, flowchartElement)
	local parentx = frameElement.offsetx
	local parenty = frameElement.offsety
	local parentwidth = frameElement.width
	local parentheight = frameElement.height

	local flowchartData = GetFlowchartData(flowchartID)
	if not flowchartData then
		return
	end
	-- init static data
	flowchartData.id = flowchartID
	flowchartData.numRows = #flowchartData.rowHeights
	flowchartData.numColumns = #flowchartData.columns
	-- offset relative to the parent with (0, 0) in the upper left corner
	flowchartData.offsetx, flowchartData.offsety = GetOffset(flowchartID)
	flowchartData.width, flowchartData.height = GetSize(flowchartID)
	-- ensure width/height does not exceed frame border
	if flowchartData.width == 0 then
		-- if no flowchart width is specified, use entire available width
		flowchartData.width = parentwidth - flowchartData.offsetx
	else
		flowchartData.width = math.min(flowchartData.width, parentwidth - flowchartData.offsetx)
	end
	if flowchartData.height == 0 then
		-- if no flowchart height is specified, use entire available height
		flowchartData.height = parentheight - flowchartData.offsety
	else
		flowchartData.height = math.min(flowchartData.height, parentheight - flowchartData.offsety)
	end

	local requiredVisibleWidth, requiredVisibleHeight = 1, 1	-- 0 is not enough

	-- init column offsets
	flowchartData.colWidths = { }
	flowchartData.maxCaptionHeight = 0
	local colxoff = 0		-- x offset of first column
	for col, coldata in ipairs(flowchartData.columns) do
		coldata.offsetx = colxoff
		flowchartData.colWidths[col] = coldata.width	-- setting up colWidths so it's analogous with rowHeights (for horizontal scroll bar)
		colxoff = colxoff + coldata.width
		requiredVisibleWidth = math.max(requiredVisibleWidth, coldata.width)
		if coldata.captionText then
			flowchartData.maxCaptionHeight = math.max(flowchartData.maxCaptionHeight, C.GetTextHeight(coldata.captionText, coldata.captionFont, coldata.captionFontSize, 0))
		end
	end

	-- init row offsets
	flowchartData.rowYOffsets = { }
	local rowyoff = 0
	for row, rowheight in ipairs(flowchartData.rowHeights) do
		flowchartData.rowYOffsets[row] = rowyoff
		rowyoff = rowyoff + rowheight
		requiredVisibleHeight = math.max(requiredVisibleHeight, rowheight)
	end

	-- init visible width/height
	-- vertical layout: top border + top padding + content (maxVisibleHeight) + bottom padding + bottom border [+ padding + horizontalscrollbar]
	-- horizontal layout: content (maxVisibleWidth) [+ padding + verticalscrollbar]
	flowchartData.fullContentHeight = rowyoff
	flowchartData.fullContentWidth = colxoff
	flowchartData.contentOffsetx = flowchartData.offsetx
	flowchartData.contentOffsety = flowchartData.offsety + flowchartData.borderHeight + config.table.bordersize	-- add top border and inner padding
	flowchartData.maxVisibleHeight = flowchartData.height - 2 * (flowchartData.borderHeight + config.table.bordersize)	-- subtract borders and inner padding
	flowchartData.maxVisibleWidth = flowchartData.width
	flowchartData.hasVerticalScrollBar = false
	flowchartData.hasHorizontalScrollBar = false
	if flowchartData.fullContentHeight > flowchartData.maxVisibleHeight - flowchartData.maxCaptionHeight then
		-- add vertical scrollbar on right side, subtract scrollbar width and padding
		flowchartData.hasVerticalScrollBar = true
		flowchartData.maxVisibleWidth = flowchartData.maxVisibleWidth - config.texturesizes.table.scrollBar.width - config.table.bordersize
	end
	if flowchartData.fullContentWidth > flowchartData.maxVisibleWidth then
		-- we will add a horizontal scrollbar below the bottom border line, subtract scrollbar height and padding
		flowchartData.hasHorizontalScrollBar = true
		flowchartData.maxVisibleHeight = flowchartData.maxVisibleHeight - config.texturesizes.table.scrollBar.width - config.table.bordersize
		-- adding a horizontal scrollbar can take up enough space that we also need a vertical scrollbar
		if (not flowchartData.hasVerticalScrollBar) and flowchartData.fullContentHeight > flowchartData.maxVisibleHeight - flowchartData.maxCaptionHeight then
			flowchartData.hasVerticalScrollBar = true
			flowchartData.maxVisibleWidth = flowchartData.maxVisibleWidth - config.texturesizes.table.scrollBar.width - config.table.bordersize
		end
	end
	if flowchartData.maxVisibleWidth < requiredVisibleWidth then
		DebugError(string.format("Widget system error. Not enough horizontal space left (%s) to display column of maximal width %s. Skipping flowchart.", flowchartData.maxVisibleWidth, requiredVisibleWidth))
		return
	end
	if flowchartData.maxVisibleHeight - flowchartData.maxCaptionHeight < requiredVisibleHeight then
		DebugError(string.format("Widget system error. Not enough vertical space left (%s) to display row of maximal height %s. Skipping flowchart.", flowchartData.maxVisibleHeight - flowchartData.maxCaptionHeight, requiredVisibleHeight))
		return
	end

	-- determine average height of visible cells (without stretching) for optimal scrollbar slider length (necessary since fullContentHeight also doesn't take stretching into account)
	-- NOTE: The visible content height can vary depending on the scroll state if rows have different heights.
	local avgVisibleContentHeight = 0
	local done = false
	for row = 1, flowchartData.numRows do
		local totalneededsize, numvisiblecells = widgetSystem.getFlowchartVisibleCellData(flowchartData.rowHeights, flowchartData.maxVisibleHeight - flowchartData.maxCaptionHeight, row)
		avgVisibleContentHeight = avgVisibleContentHeight + totalneededsize
		if row + numvisiblecells - 1 >= flowchartData.numRows then
			avgVisibleContentHeight = math.floor(avgVisibleContentHeight / row)
			done = true
			break
		end
	end
	if not done then
		DebugError(string.format("Internal error in widget system: Could not determine average visible height of flowchart cells. numRows=%s", flowchartData.numRows))
		avgVisibleContentHeight = flowchartData.maxVisibleHeight - flowchartData.maxCaptionHeight -- fallback
	end
	-- determine average width of visible cells (without stretching) for optimal scrollbar slider length (necessary since fullContentWidth also doesn't take stretching into account)
	-- NOTE: The visible content width can vary depending on the scroll state if columns have different widths.
	local avgVisibleContentWidth = 0
	done = false
	for col = 1, flowchartData.numColumns do
		local totalneededsize, numvisiblecells = widgetSystem.getFlowchartVisibleCellData(flowchartData.colWidths, flowchartData.maxVisibleWidth, col)
		avgVisibleContentWidth = avgVisibleContentWidth + totalneededsize
		if col + numvisiblecells - 1 >= flowchartData.numColumns then
			avgVisibleContentWidth = math.floor(avgVisibleContentWidth / col)
			done = true
			break
		end
	end
	if not done then
		DebugError(string.format("Internal error in widget system: Could not determine average visible width of flowchart cells. numColumns=%s", flowchartData.numColumns))
		avgVisibleContentWidth = flowchartData.maxVisibleWidth -- fallback
	end

	-- flowchartData fields provided by GetFlowchartData(): selectedRow, selectedCol, firstVisibleRow, firstVisibleCol
	-- flowchartData fields to be calculated in drawFlowchartContent(): lastVisibleRow, lastVisibleCol, curVisibleWidth, curVisibleHeight, stretchedVisibleWidth, stretchedVisibleHeight

	-- If there is no vertical/horizontal scrollbar, make sure that the full content is within the visible area, respectively
	if not flowchartData.hasVerticalScrollBar then
		flowchartData.firstVisibleRow = 1
	end
	if not flowchartData.hasHorizontalScrollBar then
		flowchartData.firstVisibleCol = 1
	end

	-- flowchart arrays to be filled in drawFlowchartContent():
	flowchartData.stretchedColXOffsets = { }
	flowchartData.stretchedRowYOffsets = { }
	flowchartData.stretchedColWidths = { }
	flowchartData.stretchedRowHeights = { }

	-- cells
	flowchartData.cells = { }
	for row = 1, flowchartData.numRows do
		local rowcells = { }
		flowchartData.cells[row] = rowcells
		for col = 1, flowchartData.numColumns do
			local nodeid = GetFlowchartNodeID(flowchartID, row, col)
			local node = nodeid and GetFlowchartNodeData(nodeid) or false
			rowcells[col] = node
			if node then
				node.id = nodeid
				node.prevexpandedbelow = node.expandedbelow
				node.prevexpandedabove = node.expandedabove
				node.incomingEdges = { }
				node.outgoingEdges = { }
			end
		end
	end

	-- edges
	flowchartData.edges = { }
	for edgeidx = 1, flowchartData.numEdges do
		local edgeid = GetFlowchartEdgeID(flowchartID, edgeidx)
		local edge = GetFlowchartEdgeData(edgeid)
		flowchartData.edges[edgeidx] = edge
		edge.id = edgeid
		-- link edge with source and destination nodes
		local sourcenode = flowchartData.cells[edge.source.row] and flowchartData.cells[edge.source.row][edge.source.col]
		local destnode   = flowchartData.cells[edge.dest.row]   and flowchartData.cells[edge.dest.row][edge.dest.col]
		if sourcenode and destnode then
			table.insert(sourcenode.outgoingEdges, edge)
			table.insert(destnode.incomingEdges, edge)
			local edgecountmax = #sourcenode.outgoingEdges
			local edgecountmin = #destnode.incomingEdges
			if edgecountmin > edgecountmax then
				edgecountmax, edgecountmin = edgecountmin, edgecountmax
			end
			edge.rank = edgecountmax + edgecountmin / 1000
		else
			-- should not happen due to validation
			DebugError("Widget system error. Flowchart edge is connected to empty cell")
		end
	end
	table.sort(flowchartData.edges, function(a, b) return a.rank < b.rank end)

	flowchartElement.data = flowchartData

	-- set up mousepick
	goToSlide(flowchartElement.mousePick.element, "active")
	widgetSystem.setElementPosition(flowchartElement.mousePick.element, parentx + (flowchartData.offsetx + flowchartData.width / 2), parenty - (flowchartData.offsety + flowchartData.height / 2))
	widgetSystem.setElementScale(flowchartElement.mousePick.element, flowchartData.width / 100, flowchartData.height / 100)
	
	widgetSystem.addHelpOverlay(frameElement, flowchartID, parentx + flowchartData.offsetx, parenty - flowchartData.offsety, flowchartData.width, flowchartData.height)

	-- draw top and bottom border (static)
	if flowchartData.borderHeight > 0 then
		local borderx = parentx + (flowchartData.offsetx + flowchartData.width / 2)
		local bordery_top = parenty - (flowchartData.offsety + flowchartData.borderHeight / 2)
		local bordery_bottom = parenty - (flowchartData.contentOffsety + flowchartData.maxVisibleHeight + config.table.bordersize + flowchartData.borderHeight / 2)
		widgetSystem.drawFlowchartBackground(flowchartElement.headerBackground, borderx, bordery_top, flowchartData.width, flowchartData.borderHeight, "background", "background.material", flowchartData.borderColor, "background")
		widgetSystem.drawFlowchartBackground(flowchartElement.footerBackground, borderx, bordery_bottom, flowchartData.width, flowchartData.borderHeight, "background", "background.material", flowchartData.borderColor, "background")
	end

	-- TODO: Validate firstVisibleRow/Col
	if flowchartData.hasVerticalScrollBar then
		local scrollbarx = parentx + (flowchartData.offsetx + flowchartData.width - config.texturesizes.table.scrollBar.width)
		local scrollbary = parenty - (flowchartData.contentOffsety)
		widgetSystem.setUpVerticalScrollBar(flowchartElement.scrollBars.vertical, scrollbarx, scrollbary, flowchartData.maxVisibleHeight, avgVisibleContentHeight, flowchartData.fullContentHeight)
	end
	if flowchartData.hasHorizontalScrollBar then
		local scrollbarx = parentx + (flowchartData.contentOffsetx)
		local scrollbary = parenty - (flowchartData.offsety + flowchartData.height - config.texturesizes.table.scrollBar.width)
		widgetSystem.setUpHorizontalScrollBar(flowchartElement.scrollBars.horizontal, scrollbarx, scrollbary, flowchartData.maxVisibleWidth, avgVisibleContentWidth, flowchartData.fullContentWidth)
	end
	widgetSystem.updateFlowchartScrollBars(flowchartElement)

	-- draw flowchart columns, cells and edges
	widgetSystem.drawFlowchartContent(frameElement, flowchartID, flowchartElement)

	widgetSystem.addToAssociationList(flowchartID, flowchartElement, nil, parentx, parenty, parentwidth)
end

function widgetSystem.setUpBoxText(boxtextID, boxtextElement, parentx, parenty, parentwidth, parentHeight, parentBGWidth, isPrevColBGSpanned, isColBGSpanned)
	local width, height = GetSize(boxtextID)
	local x, y          = GetOffset(boxtextID)

	-- propagate parent height/width, unless specified explicitly
	if width == 0 then
		width = parentwidth
	end
	if height == 0 then
		height = parentheight
	end
	SetWidth(boxtextID, width)
	
	local borderWidth = parentBGWidth
	local borderOffset = math.floor((parentBGWidth - parentwidth) / 2)
	if isPrevColBGSpanned then
		boxtextElement.leftHidden = true
		borderWidth = borderWidth + config.table.bordersize
		borderOffset = borderOffset - config.table.bordersize / 2
	end
	if isColBGSpanned then
		boxtextElement.rightHidden = true
	else
		borderWidth = width
	end

	-- position boxtext
	boxtextElement.offsetx = x + parentx + width/2
	boxtextElement.offsety = parenty - y - height/2
	widgetSystem.setElementPosition(boxtextElement.element.mainElement, boxtextElement.offsetx, boxtextElement.offsety, (width % 2 ~= 0), (height % 2 ~= 0))

	-- mousepick
	widgetSystem.setElementScale(getElement("mousepick", boxtextElement.element.mainElement), width / 100, height / 100)

	-- border elements
	for _, element in ipairs(config.boxtext.borderElements) do
		local anarkElement = getElement(element, boxtextElement.element.mainElement)
		if element == "border_left" then
			if not boxtextElement.leftHidden then
				widgetSystem.setElementPosition(anarkElement, -(width - config.boxtext.borderSize) / 2, 0, (width % 2 ~= 0), (height % 2 ~= 0))
				widgetSystem.setElementScale(anarkElement, config.boxtext.borderSize / 100, (height - 2 * config.boxtext.borderSize) / 100)
			end
		elseif element == "border_right" then
			if not boxtextElement.rightHidden then
				widgetSystem.setElementPosition(anarkElement, (width - config.boxtext.borderSize) / 2, 0, (width % 2 ~= 0), (height % 2 ~= 0))
				widgetSystem.setElementScale(anarkElement, config.boxtext.borderSize / 100, (height - 2 * config.boxtext.borderSize) / 100)
			end
		elseif element == "border_down" then
			widgetSystem.setElementPosition(anarkElement, borderOffset, (height - config.boxtext.borderSize) / 2, (width % 2 ~= 0), (height % 2 ~= 0))
			widgetSystem.setElementScale(anarkElement, borderWidth / 100, config.boxtext.borderSize / 100)
		elseif element == "border_up" then
			widgetSystem.setElementPosition(anarkElement, borderOffset, -(height - config.boxtext.borderSize) / 2, (width % 2 ~= 0), (height % 2 ~= 0))
			widgetSystem.setElementScale(anarkElement, borderWidth / 100, config.boxtext.borderSize / 100)
		end
	end

	-- textDetails
	boxtextElement.textDetails = {}
	local buf = ffi.new("TextInfo")
	if C.GetBoxTextInfo(boxtextID, buf) then
		boxtextElement.textDetails.color = {}
		boxtextElement.textDetails.color.red = buf.color.red
		boxtextElement.textDetails.color.green = buf.color.green
		boxtextElement.textDetails.color.blue = buf.color.blue
		boxtextElement.textDetails.color.alpha = buf.color.alpha
		boxtextElement.textDetails.fontname = ffi.string(buf.font.name)
		boxtextElement.textDetails.fontsize = buf.font.size
		boxtextElement.textDetails.alignment = ffi.string(buf.alignment)
		boxtextElement.textDetails.x = buf.x
		boxtextElement.textDetails.y = -buf.y
		boxtextElement.textDetails.glowfactor = buf.glowfactor
	end

	-- text
	-- calculate horizontal offset for proper alignment
	if boxtextElement.textDetails.alignment == "left" then
		boxtextElement.textDetails.x = boxtextElement.textDetails.x - width/2
	elseif boxtextElement.textDetails.alignment == "center" then
		-- nothing to do
	else -- right
		boxtextElement.textDetails.x = -boxtextElement.textDetails.x + width/2
	end
	local textelement = getElement("Text", boxtextElement.element.mainElement)
	widgetSystem.setElementPosition(textelement, boxtextElement.textDetails.x, boxtextElement.textDetails.y + height / 2 - config.boxtext.borderSize)
	setAttribute(textelement, "horzalign", widgetSystem.convertAlignment(boxtextElement.textDetails.alignment))
	-- text font
	setAttribute(textelement, "font", boxtextElement.textDetails.fontname)
	setAttribute(textelement, "size", boxtextElement.textDetails.fontsize)
	-- text/color is set in widgetSystem.updateBoxText()

	goToSlide(boxtextElement.element.mainElement, "active")

	widgetSystem.addToAssociationList(boxtextID, boxtextElement, boxtextElement.element.mainElement, parentx, parenty, parentwidth)
	widgetSystem.updateBoxText(boxtextID, boxtextElement)
end

-- fontstringID = the widgetID of the fontstring
-- textcomponent = the text component element to be activated/deactivated
-- textelement = the text element to be set according to the fonstring
-- activeSlide   = the slidename to go to, when the text is to be activated
-- inactiveSlide = the slidename to go to, when the text is to be deactivated
-- parentx / parenty = position of the text's parent (i.e. anchor position)
-- parentwidth = width of the parent element (i.e. the anchor)
-- parentXSubpixel / parentYSubpixel = indicates, whether the parent of the text element uses subpixel-positions for x/y
-- returns
--    int - the fontstringheight
--    text - the displayed text
function widgetSystem.setUpFontString(fontstringID, textcomponent, textelement, activeSlide, inactiveSlide, parentx, parenty, parentwidth, parentXSubpixel, parentYSubpixel, frameElement, realparentx, realparenty, backgroundcolspanwidth)
	-- get the data
	local alignment     = GetAlignment(fontstringID)
	local wordwrap      = GetWordWrap(fontstringID)
	local width, height = GetSize(fontstringID)
	local x, y          = GetOffset(fontstringID)
	local offsety       = parenty - y

	-- propagate parent width
	SetWidth(fontstringID, (width ~= 0) and math.min(width, parentwidth - x) or (parentwidth - x))

	-- calculate horizontal offset for proper alignment
	local offsetx
	if alignment == "left" then
		offsetx = parentx + x
	elseif alignment == "center" then
		offsetx = parentwidth / 2 + parentx + x / 2
		if offsetx % 1 ~= 0 then
			-- parentwidth or x can be odd - when dividing by 2 (and hence finding the center position)
			-- we must make sure that this doesn't end on a subpixel/halfpixel
			offsetx = offsetx - 0.5
		end
	else -- right
		offsetx = parentwidth + parentx - x
	end

	widgetSystem.addHelpOverlay(frameElement, fontstringID, realparentx - x / 2, realparenty - y, parentwidth, height, nil, backgroundcolspanwidth)

	-- set the element's attributes
	widgetSystem.setElementPosition(textelement, offsetx, offsety, parentXSubpixel, parentYSubpixel)
	setAttribute(textelement, "horzalign", widgetSystem.convertAlignment(alignment))
	setAttribute(textelement, "wordwrap", wordwrap)

	widgetSystem.addToAssociationList(fontstringID, textelement, textcomponent, parentx, parenty, parentwidth - x, textcomponent, activeSlide, inactiveSlide, "inactive")
	local fontheight, text = widgetSystem.updateFontString(fontstringID, textcomponent, textelement, activeSlide, inactiveSlide, "inactive")

	return fontheight + y, text
end

function widgetSystem.setUpGraph(graphID, graphElement, parentx, parenty, parentwidth, parentheight, frameElement, backgroundcolspanwidth)
	-- propagate parent height/width, unless specified explicitly
	local width, height = GetSize(graphID)
	if width == 0 then
		width = parentwidth
	end
	if height == 0 then
		height = parentheight
	end

	-- position graph
	local x, y = GetOffset(graphID)
	local offsetx = x + parentx
	local offsety = parenty - y - height/2
	widgetSystem.setElementPosition(graphElement.element.mainElement, offsetx, offsety, (width % 2 ~= 0), (height % 2 ~= 0))

	widgetSystem.addHelpOverlay(frameElement, graphID, x + parentx - width / 2, parenty - y, width, height, nil, backgroundcolspanwidth)

	-- scale background
	widgetSystem.setElementScale(getElement("background", graphElement.element.mainElement), width / 100, height / 100)
	
	-- background color
	local bgcolor = ffi.new("Color")
	if C.GetGraphBackgroundColor(graphID, bgcolor) then
		local material = getElement("background.Material713", graphElement.element.mainElement)
		SetDiffuseColor(material, bgcolor.red, bgcolor.green, bgcolor.blue)
		setAttribute(material, "opacity", bgcolor.alpha)
	end

	-- title
	local hasTitle = false
	local textElement = getElement("Text", graphElement.element.mainElement)
	local title = ffi.new("GraphTextInfo")
	if C.GetGraphTitle(graphID, title) then
		graphElement.title = {}
		graphElement.title.text = ffi.string(title.text)
		if graphElement.title.text ~= "" then
			hasTitle = true
			-- title text
			setAttribute(textElement, "textstring", graphElement.title.text)
			-- title font
			graphElement.title.fontname = ffi.string(title.font.name)
			graphElement.title.fontsize = title.font.size
			setAttribute(textElement, "font", graphElement.title.fontname)
			setAttribute(textElement, "size", graphElement.title.fontsize)
			-- title color
			setAttribute(textElement, "textcolor.r", title.color.red)
			setAttribute(textElement, "textcolor.g", title.color.green)
			setAttribute(textElement, "textcolor.b", title.color.blue)
			setAttribute(textElement, "opacity", title.color.alpha)
		end
	end
	if hasTitle then
		-- position title
		graphElement.title.titleheight = C.GetTextHeight(graphElement.title.text, graphElement.title.fontname, graphElement.title.fontsize, 0)
		widgetSystem.setElementPosition(textElement, 0, height / 2 - graphElement.title.titleheight / 2 - config.graph.border)
	end

	-- xAxis (1/2)
	graphElement.xAxis = {}
	local xAxisElement = getElement("axis", graphElement.element.mainElement)
	widgetSystem.setUpGraphAxis(graphID, xAxisElement, C.GetGraphXAxis, graphElement.xAxis)

	-- yAxis (1/2)
	graphElement.yAxis = {}
	local yAxisElement = getElement("axis2", graphElement.element.mainElement)
	widgetSystem.setUpGraphAxis(graphID, yAxisElement, C.GetGraphYAxis, graphElement.yAxis)

	-- label dependent offsets
	local xAxisOffsetY = graphElement.xAxis.hasLabel and (graphElement.xAxis.label.labelheight + graphElement.xAxis.label.maxTickHeight + config.graph.border) or 0
	local yAxisOffsetX = graphElement.yAxis.hasLabel and (graphElement.yAxis.label.labelheight + graphElement.yAxis.label.maxTickWidth + config.graph.border) or 0
	local titleOffsetY = hasTitle and (graphElement.title.titleheight + config.graph.border) or 0
	local tickOffsetXRight = 0
	local tickOffsetXLeft = 0
	if graphElement.xAxis.hasLabel then
		tickOffsetXRight = graphElement.xAxis.label.maxTickWidth / 2
		tickOffsetXLeft = graphElement.yAxis.hasLabel and 0 or graphElement.xAxis.label.maxTickWidth / 2
	end
	local tickOffsetYUpper = 0
	local tickOffsetYLower = 0
	if graphElement.yAxis.hasLabel then
		tickOffsetYUpper = hasTitle and 0 or graphElement.yAxis.label.maxTickHeight / 2
		tickOffsetYLower = graphElement.xAxis.hasLabel and 0 or graphElement.yAxis.label.maxTickHeight / 2
	end

	-- xAxis (2/2)
	local axis1Element = getElement("axis1", xAxisElement)
	local axis2Element = getElement("axis2", xAxisElement)
	-- scale
	graphElement.xAxis.width = width - 2 * config.graph.border - yAxisOffsetX - tickOffsetXRight - tickOffsetXLeft
	local xAxisHeight = config.graph.axisWidth
	widgetSystem.setElementScale(axis1Element, graphElement.xAxis.width / 100, xAxisHeight / 100)
	widgetSystem.setElementScale(axis2Element, graphElement.xAxis.width / 100, xAxisHeight / 100)
	-- position
	graphElement.xAxis.offsetX = yAxisOffsetX / 2 - (tickOffsetXRight - tickOffsetXLeft) / 2
	local offsetY1 = -height / 2 + config.graph.border + xAxisOffsetY + tickOffsetYLower
	local offsetY2 = height / 2 - titleOffsetY - config.graph.border - tickOffsetYUpper
	widgetSystem.setElementPosition(axis1Element, graphElement.xAxis.offsetX, offsetY1, (graphElement.xAxis.width % 2 ~= 0), (xAxisHeight % 2 ~= 0))
	widgetSystem.setElementPosition(axis2Element, graphElement.xAxis.offsetX, offsetY2, (graphElement.xAxis.width % 2 ~= 0), (xAxisHeight % 2 ~= 0))
	-- label position
	if graphElement.xAxis.hasLabel then
		widgetSystem.setElementPosition(getElement("Text", xAxisElement), graphElement.xAxis.offsetX, -height / 2 + graphElement.xAxis.label.labelheight / 2 + config.graph.border)
	end
	-- activate
	goToSlide(xAxisElement, graphElement.xAxis.hasLabel and "label" or "nolabel")

	-- yAxis (2/2)
	axis1Element = getElement("axis1", yAxisElement)
	axis2Element = getElement("axis2", yAxisElement)
	-- scale
	local yAxisWidth = config.graph.axisWidth
	graphElement.yAxis.height = height - 2 * config.graph.border - titleOffsetY - xAxisOffsetY - tickOffsetYUpper - tickOffsetYLower
	widgetSystem.setElementScale(axis1Element, yAxisWidth / 100, graphElement.yAxis.height / 100)
	widgetSystem.setElementScale(axis2Element, yAxisWidth / 100, graphElement.yAxis.height / 100)
	-- position
	local offsetX1 = - width / 2 + config.graph.border + yAxisOffsetX + tickOffsetXLeft
	local offsetX2 = width / 2 - config.graph.border - tickOffsetXRight
	graphElement.yAxis.offsetY = xAxisOffsetY / 2 - titleOffsetY / 2 - tickOffsetYUpper / 2 + tickOffsetYLower / 2
	widgetSystem.setElementPosition(axis1Element, offsetX1, graphElement.yAxis.offsetY, (yAxisWidth % 2 ~= 0), (graphElement.yAxis.height % 2 ~= 0))
	widgetSystem.setElementPosition(axis2Element, offsetX2, graphElement.yAxis.offsetY, (yAxisWidth % 2 ~= 0), (graphElement.yAxis.height % 2 ~= 0))
	-- label position
	if graphElement.yAxis.hasLabel then
		widgetSystem.setElementPosition(getElement("Text", yAxisElement), - width / 2 + graphElement.yAxis.label.labelheight / 2 + config.graph.border, graphElement.yAxis.offsetY)
	end
	-- activate
	goToSlide(yAxisElement, graphElement.yAxis.hasLabel and "label" or "nolabel")

	-- ticks
	-- xAxis
	local xAxisRange = graphElement.xAxis.endvalue - graphElement.xAxis.startvalue
	-- first tick is at startvalue + offset, last tick is at or below endvalue
	local xAxisTickRange = xAxisRange - graphElement.xAxis.offset
	local xAxisNoOfTicks = 1 + math.floor(xAxisTickRange / graphElement.xAxis.granularity)
	local tickstep = graphElement.xAxis.granularity * graphElement.xAxis.width / xAxisRange
	local xAxisTickOffset = graphElement.xAxis.offset * graphElement.xAxis.width / xAxisRange

	if xAxisNoOfTicks > config.graph.maxTicksPerElement then
		DebugError("Widget system error. X axis of graph requests " .. xAxisNoOfTicks .. " ticks, but only " .. tostring(config.graph.maxTicksPerElement) .. " are available. Skipping ticks and labels for this axis.")
		xAxisNoOfTicks = 0
	else
		local tickHeight
		-- for scripter intution the grid composed from x-Axis ticks is enabled in the y Axis
		if graphElement.yAxis.grid then
			tickHeight = graphElement.yAxis.height
		else
			tickHeight = 3 * config.graph.axisWidth
		end
		local tickOffsetY = offsety + offsetY1 + 1.5 * config.graph.axisWidth
		for i = 1, xAxisNoOfTicks do
			local tickElement = graphElement.element.tickElements[i]
			-- color
			local material = getElement("tick.Material740", tickElement)
			SetDiffuseColor(material, graphElement.xAxis.color.r, graphElement.xAxis.color.g, graphElement.xAxis.color.b)
			setAttribute(material, "opacity", graphElement.xAxis.color.a)
			-- scale
			widgetSystem.setElementScale(getElement("tick", tickElement), config.graph.axisWidth / 100, tickHeight / 100)
			-- position
			widgetSystem.setElementPosition(tickElement, offsetx + offsetX1 + xAxisTickOffset + tickstep * (i - 1), tickOffsetY)
			if graphElement.yAxis.grid then
				SetDiffuseColor(material, graphElement.yAxis.gridcolor.r, graphElement.yAxis.gridcolor.g, graphElement.yAxis.gridcolor.b)
				setAttribute(material, "opacity", graphElement.yAxis.gridcolor.a)
				widgetSystem.setElementPosition(getElement("tick", tickElement), 0, tickHeight / 2 - 1.5 * config.graph.axisWidth)
			end
			-- text
			if graphElement.xAxis.hasLabel then
				local textElement = getElement("Text", tickElement)
				-- text text
				local text = graphElement.xAxis.label.tickTexts[i]
				setAttribute(textElement, "textstring", text)
				-- text font
				setAttribute(textElement, "font", graphElement.xAxis.label.fontname)
				setAttribute(textElement, "size", graphElement.xAxis.label.fontsize)
				-- text color
				setAttribute(textElement, "textcolor.r", graphElement.xAxis.label.color.r)
				setAttribute(textElement, "textcolor.g", graphElement.xAxis.label.color.g)
				setAttribute(textElement, "textcolor.b", graphElement.xAxis.label.color.b)
				setAttribute(textElement, "opacity", graphElement.xAxis.label.color.a)
				-- glowfactor
				setAttribute(textElement, "glowfactor", graphElement.xAxis.glowfactor)
				-- alignment
				setAttribute(textElement, "horzalign", 1)
				-- text position
				local textheight = C.GetTextHeight(text, graphElement.xAxis.label.fontname, graphElement.xAxis.label.fontsize, 0)
				widgetSystem.setElementPosition(textElement, 0, -textheight)
			end
			local state
			if graphElement.xAxis.hasLabel then
				state = "both"
			else
				state = "tick"
			end
			goToSlide(tickElement, state)
		end
	end

	-- yAxis
	local yAxisRange = graphElement.yAxis.endvalue - graphElement.yAxis.startvalue
	-- first tick is at startvalue + offset, last tick is at or below endvalue
	local yAxisTickRange = yAxisRange - graphElement.yAxis.offset
	local yAxisNoOfTicks = 1 + math.floor(yAxisTickRange / graphElement.yAxis.granularity)
	tickstep = graphElement.yAxis.granularity * graphElement.yAxis.height / yAxisRange
	local yAxisTickOffset = graphElement.yAxis.offset * graphElement.yAxis.height / yAxisRange

	if yAxisNoOfTicks > (config.graph.maxTicksPerElement - xAxisNoOfTicks) then
		DebugError("Widget system error. Y axis of graph requests " .. yAxisNoOfTicks .. " ticks, but only " .. tostring(config.graph.maxTicksPerElement - xAxisNoOfTicks) .. " are available. Skipping ticks and labels for this axis.")
		yAxisNoOfTicks = 0
	else
		local tickWidth
		-- for scripter intution the grid composed from y-Axis ticks is enabled in the x Axis
		if graphElement.xAxis.grid then
			tickWidth = graphElement.xAxis.width
		else
			tickWidth = 3 * config.graph.axisWidth
		end
		local tickOffsetX = offsetx + offsetX1 + 1.5 * config.graph.axisWidth
		for i = 1, yAxisNoOfTicks do
			local tickElement = graphElement.element.tickElements[xAxisNoOfTicks + i]
			-- color
			local material = getElement("tick.Material740", tickElement)
			SetDiffuseColor(material, graphElement.yAxis.color.r, graphElement.yAxis.color.g, graphElement.yAxis.color.b)
			setAttribute(material, "opacity", graphElement.yAxis.color.a)
			-- scale
			widgetSystem.setElementScale(getElement("tick", tickElement), tickWidth / 100, config.graph.axisWidth / 100)
			-- position
			widgetSystem.setElementPosition(tickElement, tickOffsetX, offsety + offsetY1 + yAxisTickOffset + tickstep * (i - 1))
			if graphElement.xAxis.grid then
				SetDiffuseColor(material, graphElement.xAxis.gridcolor.r, graphElement.xAxis.gridcolor.g, graphElement.xAxis.gridcolor.b)
				setAttribute(material, "opacity", graphElement.xAxis.gridcolor.a)
				widgetSystem.setElementPosition(getElement("tick", tickElement), tickWidth / 2 - 1.5 * config.graph.axisWidth, 0)
			end
			-- text
			if graphElement.yAxis.hasLabel then
				local textElement = getElement("Text", tickElement)
				-- text text
				local text = graphElement.yAxis.label.tickTexts[i]
				setAttribute(textElement, "textstring", text)
				-- text font
				setAttribute(textElement, "font", graphElement.yAxis.label.fontname)
				setAttribute(textElement, "size", graphElement.yAxis.label.fontsize)
				-- text color
				setAttribute(textElement, "textcolor.r", graphElement.yAxis.label.color.r)
				setAttribute(textElement, "textcolor.g", graphElement.yAxis.label.color.g)
				setAttribute(textElement, "textcolor.b", graphElement.yAxis.label.color.b)
				setAttribute(textElement, "opacity", graphElement.yAxis.label.color.a)
				-- glowfactor
				setAttribute(textElement, "glowfactor", graphElement.yAxis.glowfactor)
				-- alignment
				setAttribute(textElement, "horzalign", 2)
				-- text position
				local textwidth = C.GetTextWidth(text, graphElement.yAxis.label.fontname, graphElement.yAxis.label.fontsize)
				widgetSystem.setElementPosition(textElement, -config.graph.border - 1.5 * config.graph.axisWidth, 0)
			end
			local state
			if graphElement.yAxis.hasLabel then
				state = "both"
			else
				state = "tick"
			end
			goToSlide(tickElement, state)
		end
	end

	-- data
	graphElement.datarecords = {}
	local n = C.GetNumGraphDataRecords(graphID)
	local buf = ffi.new("GraphDataRecord[?]", n)
	n = C.GetGraphDataRecords(buf, n, graphID)
	for i = 0, n - 1 do
		local record = {}

		record.markerType = "none"
		if buf[i].MarkerType == 1 then
			record.markerType = "square"
		elseif buf[i].MarkerType == 2 then
			record.markerType = "diamond"
		elseif buf[i].MarkerType == 3 then
			record.markerType = "circle"
		end
		record.markerSize = buf[i].MarkerSize
		record.markerColor = {
			r = buf[i].MarkerColor.red,
			g = buf[i].MarkerColor.green,
			b = buf[i].MarkerColor.blue,
			a = buf[i].MarkerColor.alpha,
		}
		record.markerColor.glow = buf[i].MarkerGlowFactor

		record.lineType = "none"
		if buf[i].LineType == 1 then
			record.lineType = "normal"
		elseif buf[i].LineType == 2 then
			record.lineType = "dotted"
		end
		record.lineWidth = buf[i].LineWidth
		record.lineColor = {
			r = buf[i].LineColor.red,
			g = buf[i].LineColor.green,
			b = buf[i].LineColor.blue,
			a = buf[i].LineColor.alpha,
		}
		record.lineColor.glow = buf[i].LineGlowFactor

		record.highlighted = buf[i].Highlighted
		record.mouseovertext = ffi.string(buf[i].MouseOverText)

		record.hasInactiveData = false
		record.data = {}
		local buf2 = ffi.new("GraphDataPoint2[?]", buf[i].NumData)
		local m = C.GetGraphData2(buf2, buf[i].NumData, graphID, i + 1)
		for j = 0, m - 1 do
			if buf2[j].inactive then
				record.hasInactiveData = true
			end
			table.insert(record.data, { x = buf2[j].x, y = buf2[j].y, inactive = buf2[j].inactive })
		end

		table.insert(graphElement.datarecords, record)
	end

	local usedDataPoints = 0
	local minX = offsetx + offsetX1
	graphElement.minX = offsetX1
	local maxX = minX + graphElement.xAxis.width
	local minY = offsety + offsetY1
	graphElement.minY = offsetY1
	local maxY = minY + graphElement.yAxis.height
	for i, dataRecord in ipairs(graphElement.datarecords) do
		local state = "inactive"
		if dataRecord.lineType == "none" then
			if (dataRecord.markerType == "square") or (dataRecord.markerType == "diamond") then
				state = "square"
			elseif dataRecord.markerType == "circle" then
				state = "circle"
			end
		else
			if dataRecord.markerType == "none" then
				state = "line"
			elseif (dataRecord.markerType == "square") or (dataRecord.markerType == "diamond") then
				state = "squareline"
			elseif dataRecord.markerType == "circle" then
				state = "circleline"
			end
		end

		if state ~= "inactive" then
			if #dataRecord.data > (config.graph.maxDataPointsPerElement - usedDataPoints) then
				DebugError("Widget system error. Data record " .. i .. " of graph requests " .. #dataRecord.data .. " data points, but only " .. tostring(config.graph.maxDataPointsPerElement - usedDataPoints) .. " are available. Skipping this data record.")
			else
				local lastX, lastY
				for j, data in ipairs(dataRecord.data) do
					local datastate = state
					local dataPointElement = graphElement.element.dataPointElements[usedDataPoints + j]
					data.element = dataPointElement
					-- different z layers for different data records
					setAttribute(dataPointElement, "position.z", config.graph.dataRecordOffsetZ * i)
					widgetSystem.moveAnarkElementFrameLayer(frameElement, dataPointElement, 1)
					-- current data point position
					local curX = math.floor(minX + (data.x - graphElement.xAxis.startvalue) / xAxisRange * graphElement.xAxis.width)
					local curY = math.floor(minY + (data.y - graphElement.yAxis.startvalue) / yAxisRange * graphElement.yAxis.height)
					-- check whether new data point is visible
					if (curX < minX - 1) or (curX > maxX + 1) or (curY < minY - 1) or (curY > maxY + 1) then
						if dataRecord.lineType ~= "none" then
							if (lastX ~= nil) and (lastY ~= nil) then
								-- find first visible point on line
								local clampedLastX = math.max(minX, math.min(maxX, lastX))
								local clampedLastY = math.max(minY, math.min(maxY, lastY))
								local lambdaX, lambdaY
								if curX == lastX then
									lambdaX = 2 -- both points are outside min, max -> coordinate is not on the line segment (> 1)
								else
									lambdaX = (clampedLastX - lastX) / (curX - lastX)
								end
								if curY == lastY then
									lambdaY = 2 -- both points are outside min, max -> coordinate is not on the line segment (> 1)
								else
									lambdaY = (clampedLastY - lastY) / (curY - lastY)
								end
								-- check whether the first visible point even lies on the current line segment
								if (lambdaX < 0) or (lambdaX > 1) or (lambdaY < 0) or (lambdaY > 1) then
									usedDataPoints = usedDataPoints - 1
								else
									clampedLastX = lastX + math.max(lambdaX, lambdaY) * (curX - lastX)
									clampedLastY = lastY + math.max(lambdaX, lambdaY) * (curY - lastY)
									-- find last visible point on line
									local newX = math.max(minX, math.min(maxX, curX))
									local newY = math.max(minY, math.min(maxY, curY))
									lambdaX = (newX - clampedLastX) / (curX - clampedLastX)
									lambdaY = (newY - clampedLastY) / (curY - clampedLastY)
									local diffX = math.min(lambdaX, lambdaY) * (curX - clampedLastX)
									local diffY = math.min(lambdaX, lambdaY) * (curY - clampedLastY)
									-- icon position
									data.iconX = clampedLastX + diffX / 2
									data.iconY = clampedLastY + diffY / 2
									-- prepare dataPoint position
									widgetSystem.setElementPosition(dataPointElement, clampedLastX + diffX, clampedLastY + diffY)
									-- set up line
									widgetSystem.setUpDataPointLine(dataRecord, data, dataPointElement, diffX, diffY)
									-- activate dataPoint
									goToSlide(dataPointElement, "line")
								end
							end
						else
							-- didn't use the dataPointElement, re use on next iteration
							usedDataPoints = usedDataPoints - 1
						end
					else
						-- position
						widgetSystem.setElementPosition(dataPointElement, curX, curY)
						if dataRecord.lineType ~= "none" then
							if (lastX ~= nil) and (lastY ~= nil) then
								-- find first visible point on line
								local clampedLastX = math.max(minX, math.min(maxX, lastX))
								local clampedLastY = math.max(minY, math.min(maxY, lastY))
								local lambdaX, lambdaY
								if curX == lastX then
									lambdaX = 1
								else
									lambdaX = (curX - clampedLastX) / (curX - lastX)
								end
								if curY == lastY then
									lambdaY = 1
								else
									lambdaY = (curY - clampedLastY) / (curY - lastY)
								end
								local diffX = math.min(lambdaX, lambdaY) * (curX - lastX)
								local diffY = math.min(lambdaX, lambdaY) * (curY - lastY)
								-- icon position
								data.iconX = curX - diffX / 2
								data.iconY = curY - diffY / 2
								-- set up line
								widgetSystem.setUpDataPointLine(dataRecord, data, dataPointElement, diffX, diffY)
							else
								if datastate == "line" then
									datastate = "inactive"
								elseif datastate == "squareline" then
									datastate = "square"
								elseif datastate == "circleline" then
									datastate = "circle"
								end
								-- icon position
								data.iconX = curX
								data.iconY = curY
							end
						end
						-- set up marker
						widgetSystem.setUpDataPointMarker(dataRecord, dataPointElement, data)
						-- state
						goToSlide(dataPointElement, datastate)
					end
					-- store previous data point position
					lastX = curX
					lastY = curY
				end
				usedDataPoints = usedDataPoints + #dataRecord.data
			end
		end
	end

	-- icons
	graphElement.icons = {}
	local n = C.GetNumGraphIcons(graphID)
	local buf = ffi.new("GraphIcon[?]", n)
	n = C.GetGraphIcons(buf, n, graphID)
	for i = 0, n - 1 do
		local icon = {}

		icon.dataRecordIdx = tonumber(buf[i].DataRecordIdx);
		icon.dataIdx = tonumber(buf[i].DataIdx);
		icon.ID = ffi.string(buf[i].IconID);
		icon.mouseOverText = ffi.string(buf[i].MouseOverText);

		table.insert(graphElement.icons, icon)
	end

	for i, icon in ipairs(graphElement.icons) do
		if i > config.graph.maxIconsPerElement then
			DebugError("Widget system error. Graph requests " .. #graphElement.icons .. " icons, but only " .. config.graph.maxIconsPerElement .. " are available. Skipping extra icons.")
			break
		end
		local iconElement = graphElement.element.iconElements[i]
		icon.element = iconElement

		-- scale
		widgetSystem.setElementScale(getElement("background", iconElement), config.graph.iconSize / 100, config.graph.iconSize / 100)
		-- position
		local data = graphElement.datarecords[icon.dataRecordIdx].data[icon.dataIdx]
		local angle = (data.iconAngle or math.rad(-45)) + math.rad(90)
		if angle < math.rad(-90) or angle > math.rad(90) then
			angle = angle + math.pi
		end
		widgetSystem.setElementPosition(iconElement, data.iconX + config.graph.iconSize * math.cos(angle), data.iconY + config.graph.iconSize * math.sin(angle))
		setAttribute(iconElement, "position.z", config.graph.dataRecordOffsetZ * icon.dataRecordIdx)
		widgetSystem.moveAnarkElementFrameLayer(frameElement, iconElement, 1)

		-- icon
		local material = getElement("icon.icon", iconElement)
		SetIcon(getElement("icon", material), icon.ID, nil, nil, nil, false, config.graph.iconSize, config.graph.iconSize)

		goToSlide(iconElement, "active")
	end

	-- activate the graph
	goToSlide(graphElement.element.mainElement, hasTitle and "title" or "notitle")

	widgetSystem.addToAssociationList(graphID, graphElement, graphElement.element.mainElement, parentx, parenty, parentwidth)
end

function widgetSystem.setUpDataPointLine(dataRecord, data, dataPointElement, diffX, diffY)
	-- scale
	local lineHeight = math.sqrt(diffX * diffX + diffY * diffY)
	widgetSystem.setElementScale(getElement("line", dataPointElement), lineHeight / 100, dataRecord.lineWidth / 100)
	-- position
	widgetSystem.setElementPosition(getElement("line", dataPointElement), -diffX / 2, -diffY / 2)
	-- rotation
	data.iconAngle = math.atan2(diffY, diffX)
	widgetSystem.setElementRotation(getElement("line", dataPointElement), data.iconAngle)
	-- color
	local color = dataRecord.lineColor
	if dataRecord.hasInactiveData then
		color.r = color.r / 4
		color.g = color.g / 4
		color.b = color.b / 4
	end
	local material = getElement("line.Material772", dataPointElement)
	SetDiffuseColor(material, color.r, color.g, color.b)
	setAttribute(material, "opacity", color.a)
	setAttribute(material, "glowfactor", color.glow)
end

function widgetSystem.setUpDataPointMarker(dataRecord, dataPointElement, data)
	-- scale
	if (dataRecord.markerType == "square") or (dataRecord.markerType == "diamond") then
		widgetSystem.setElementScale(getElement("marker1", dataPointElement), dataRecord.markerSize / 100, dataRecord.markerSize / 100)
	elseif dataRecord.markerType == "circle" then
		widgetSystem.setElementScale(getElement("marker2", dataPointElement), dataRecord.markerSize / 100, nil, dataRecord.markerSize / 100)
	end
	-- rotation
	if dataRecord.markerType == "diamond" then
		widgetSystem.setElementRotation(getElement("marker1", dataPointElement), math.rad(45))
	end
	-- color
	local color = dataRecord.markerColor
	if data.inactive then
		color.r = color.r / 4
		color.g = color.g / 4
		color.b = color.b / 4
	end
	local material
	if (dataRecord.markerType == "square") or (dataRecord.markerType == "diamond") then
		material = getElement("marker1.Material755", dataPointElement)
		SetDiffuseColor(material, color.r, color.g, color.b)
		setAttribute(material, "opacity", color.a)
		setAttribute(material, "glowfactor", color.glow)
	elseif dataRecord.markerType == "circle" then
		material = getElement("marker2.Material766", dataPointElement)
		SetDiffuseColor(material, color.r, color.g, color.b)
		setAttribute(material, "opacity", color.a)
		setAttribute(material, "glowfactor", color.glow)
	end
end

function widgetSystem.setUpGraphAxis(graphID, axisElement, accessor, axisData)
	local axisLabelElement = getElement("Text", axisElement)
	local axis1Element = getElement("axis1", axisElement)
	local axis2Element = getElement("axis2", axisElement)

	local axis = ffi.new("GraphAxisInfo")
	if accessor(graphID, axis) then
		axisData.label = {}
		axisData.label.text = ffi.string(axis.label.text)
		if axisData.label.text ~= "" then
			axisData.hasLabel = true
			-- label text
			setAttribute(axisLabelElement, "textstring", axisData.label.text)
			-- title font
			axisData.label.fontname = ffi.string(axis.label.font.name)
			axisData.label.fontsize = axis.label.font.size
			setAttribute(axisLabelElement, "font", axisData.label.fontname)
			setAttribute(axisLabelElement, "size", axisData.label.fontsize)
			-- label color
			axisData.label.color = { r = axis.label.color.red, g = axis.label.color.green, b = axis.label.color.blue, a = axis.label.color.alpha }
			setAttribute(axisLabelElement, "textcolor.r", axis.label.color.red)
			setAttribute(axisLabelElement, "textcolor.g", axis.label.color.green)
			setAttribute(axisLabelElement, "textcolor.b", axis.label.color.blue)
			setAttribute(axisLabelElement, "opacity", axis.label.color.alpha)
			-- label glowfactor
			setAttribute(axisLabelElement, "glowfactor", axis.glowfactor)
			-- label height
			axisData.label.labelheight = C.GetTextHeight(axisData.label.text, axisData.label.fontname, axisData.label.fontsize, 0)
		end
		-- axis color
		axisData.color = { r = axis.color.red, g = axis.color.green, b = axis.color.blue, a = axis.color.alpha }
		local material = getElement("Material723", axis1Element)
		SetDiffuseColor(material, axis.color.red, axis.color.green, axis.color.blue)
		setAttribute(material, "opacity", axis.color.alpha)
		material = getElement("Material723", axis2Element)
		SetDiffuseColor(material, axis.color.red, axis.color.green, axis.color.blue)
		setAttribute(material, "opacity", axis.color.alpha)
		-- glowfactor
		axisData.glowfactor = axis.glowfactor
		-- axis startvalue
		axisData.startvalue = axis.startvalue
		-- axis endvalue
		axisData.endvalue = axis.endvalue
		-- axis granularity
		axisData.granularity = axis.granularity
		-- axis granularity
		axisData.offset = axis.offset % axis.granularity
		-- axis grid
		axisData.grid = axis.grid
		-- axis grid color
		axisData.gridcolor = { r = axis.gridcolor.red, g = axis.gridcolor.green, b = axis.gridcolor.blue, a = axis.gridcolor.alpha }

		if axisData.hasLabel then
			-- first tick is at startvalue + offset, last tick is at or below endvalue
			local axisNoOfTicks = 1 + math.floor((axisData.endvalue - axisData.startvalue - axisData.offset) / axisData.granularity)

			-- get the accuracy from the granularity
			axisData.label.accuracy = 0
			local int, frac = math.modf(axisData.granularity)
			-- getting rid of float inaccuracy
			frac = math.floor(frac * math.pow(10, 6) + 0.5)
			if frac > 0 then
				frac = string.gsub(frac, "0+$", "")
				axisData.label.accuracy = #frac
			elseif axisData.granularity >= 10 then
				axisData.label.accuracy = -1
			else
				axisData.label.accuracy = 0
			end

			axisData.label.maxTickWidth = 0
			axisData.label.maxTickHeight = 0
			axisData.label.tickTexts = {}
			for i = 1, axisNoOfTicks do
				local text = ""
				local number = axisData.startvalue + axisData.offset + (i - 1) * axisData.granularity
				local int, frac = math.modf(number)
				int = math.abs(int)
				frac = math.abs(frac)
				text = ((number < 0) and "-" or "") .. ConvertIntegerString(int, true, 0, true, false)
				if axisData.label.accuracy > 0 then
					frac = math.floor(frac * (10 ^ axisData.label.accuracy) + 0.5)
					text = text .. L["."] .. string.format("%0".. axisData.label.accuracy .."d", frac)
				end

				axisData.label.tickTexts[i] = text
				axisData.label.maxTickWidth = math.max(axisData.label.maxTickWidth, C.GetTextWidth(text, axisData.label.fontname, axisData.label.fontsize))
				axisData.label.maxTickHeight = math.max(axisData.label.maxTickHeight, C.GetTextHeight(text, axisData.label.fontname, axisData.label.fontsize, 0))
			end
		end
	end
end

function widgetSystem.selectGraphDataPoint(graphID, recordIdx, dataIdx, selected)
	local graphentry = private.associationList[graphID]
	if graphentry == nil then
		return nil, 1, "invalid graph element"
	end
	local graphElement = graphentry.element

	if (recordIdx <= 0) or (recordIdx > #graphElement.datarecords) then
		return nil, 2, "invalid data record index"
	end

	if (dataIdx <= 0) or (dataIdx > #graphElement.datarecords[recordIdx].data) then
		return nil, 3, "invalid data index"
	end
	
	local selectionElement = getElement("selection", graphElement.element.mainElement)

	local slide = "inactive"
	if selected then
		local data = graphElement.datarecords[recordIdx].data[dataIdx]
		local xAxisRange = graphElement.xAxis.endvalue - graphElement.xAxis.startvalue
		local yAxisRange = graphElement.yAxis.endvalue - graphElement.yAxis.startvalue

		local dataX = math.floor(graphElement.minX + (data.x - graphElement.xAxis.startvalue) / xAxisRange * graphElement.xAxis.width)
		local dataY = math.floor(graphElement.minY + (data.y - graphElement.yAxis.startvalue) / yAxisRange * graphElement.yAxis.height)

		local selection1Element = getElement("axis1", selectionElement)
		local selection2Element = getElement("axis2", selectionElement)

		widgetSystem.setElementScale(selection1Element, graphElement.xAxis.width / 100, config.graph.axisWidth / 100)
		widgetSystem.setElementPosition(selection1Element, graphElement.xAxis.offsetX, dataY, (graphElement.xAxis.width % 2 ~= 0), (config.graph.axisWidth % 2 ~= 0))

		widgetSystem.setElementScale(selection2Element, config.graph.axisWidth / 100, graphElement.yAxis.height / 100)
		widgetSystem.setElementPosition(selection2Element, dataX, graphElement.yAxis.offsetY, (config.graph.axisWidth % 2 ~= 0), (graphElement.yAxis.height % 2 ~= 0))

		local boxElement = getElement("box", selectionElement)
		local boxsize = 2 * graphElement.datarecords[recordIdx].markerSize
		widgetSystem.setElementScale(boxElement, boxsize / 100, boxsize / 100)
		widgetSystem.setElementPosition(boxElement, dataX, dataY, (boxsize % 2 ~= 0), (boxsize % 2 ~= 0))

		slide = "active"
	end

	goToSlide(selectionElement, slide)
end

-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth = width of the parent (anchor element)
function widgetSystem.setUpIcon(frameElement, iconID, iconelement, cellelement, parentx, parenty, parentwidth, backgroundcolspanwidth)
	local width, height = GetSize(iconID)
	local localx, localy = GetOffset(iconID)

	local globalx = parentx + localx
	local globaly = parenty - localy + height / 2
	widgetSystem.addHelpOverlay(frameElement, iconID, globalx, globaly, width, height, nil, backgroundcolspanwidth)

	widgetSystem.setElementPosition(iconelement, parentx, parenty)

	local textinfo = ffi.new("TextInfo")
	local hastext = C.GetIconTextDetails(iconID, textinfo)
	local textinfo2 = ffi.new("TextInfo")
	local hastext2 = C.GetIconText2Details(iconID, textinfo2)

	if hastext or hastext2 then
		goToSlide(iconelement, "icon_text")
	else
		goToSlide(iconelement, "icon")
	end

	widgetSystem.addToAssociationList(iconID, iconelement, cellelement, parentx, parenty, parentwidth)
	widgetSystem.updateIcon(iconID, iconelement, parentx, parenty, parentwidth)
end

-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth = width of the parent (anchor element)
function widgetSystem.setUpRenderTarget(frameElement, renderTargetID, renderTargetElement)
	local parentx = frameElement.offsetx
	local parenty = frameElement.offsety
	local parentwidth = frameElement.width
	local parentheight = frameElement.height

	local localx, localy = GetOffset(renderTargetID)
	local globalx = parentx + localx
	local globaly = parenty - localy

	local width, height = GetSize(renderTargetID)

	widgetSystem.addHelpOverlay(frameElement, renderTargetID, globalx, globaly, width, height)

	-- set pos x/y
	widgetSystem.setElementPosition(renderTargetElement.element, globalx + width / 2, globaly - height / 2)

	local alpha = C.GetRenderTargetAlpha(renderTargetID)
	local material = getElement("rendertarget.material", renderTargetElement.element)
	setAttribute(material, "opacity", alpha)

	-- set scale/size
	widgetSystem.setElementScale(renderTargetElement.modelElement, width / 100, height / 100)
	widgetSystem.setElementScale(renderTargetElement.noiseElement, width / 100, height / 100)
	SetRenderTargetSize(renderTargetElement.textureString, width, height)
	if C.ShouldRenderTargetBeCleared(renderTargetID) then
		C.ClearRendertarget(renderTargetElement.textureString)
	end

	local slide = C.HasRenderTargetStartNoise(renderTargetID) and "noise" or "active"
	goToSlide(renderTargetElement.element, slide)

	widgetSystem.addToAssociationList(renderTargetID, renderTargetElement, renderTargetElement.element, parentx, parenty, parentwidth)
end

function widgetSystem.setRenderTargetNoise(renderTargetID, active)
	local rendertargetEntry = private.associationList[renderTargetID]
	if rendertargetEntry == nil then
		return nil, 1, "invalid rendertarget element"
	end

	goToSlide(rendertargetEntry.element.element, active and "noise" or "active")
end

function widgetSystem.getCurrentMouseOverWidth()
	return math.floor(config.mouseOverText.maxWidth * private.uiscale + 0.5)
end

function widgetSystem.getCurrentMouseOverFont()
	local textElement = getElement("popupmenu.Text", private.widgetsystem)
	local fontsize = math.ceil(config.mouseOverText.fontsize * private.uiscale)

	return getAttribute(textElement, "font"), fontsize
end

-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth  = width of the parent (anchor element)
-- parentheight = height of the parent (anchor element)
function widgetSystem.setUpSliderCell(frameElement, slidercellID, slidercellElement, parentx, parenty, parentwidth, parentheight, backgroundcolspanwidth)
	-- propagate parent height/width, unless specified explicitly
	local width, height = GetSize(slidercellID)
	if width == 0 then
		width = parentwidth
	end
	if height == 0 then
		height = parentheight
	end

	slidercellElement.width = width
	slidercellElement.height = height

	-- #StefanMed - this check really doesn't belong here - either perform the check during setUpTable() or refactor the width/height calculation and perform the checks in SliderCell::SetWidth/SetHeight
	local minHeight = config.slidercell.minSliderCellHeight
	local minWidth = config.slidercell.minSliderCellWidth
	if height < minHeight or width < minWidth then
		DebugError("Widget system error. Dimensions for slidercell are too small. Elements will overlap eachother. Dimensions are: width("..tostring(width).." px) height("..tostring(height).." px) - minimum dimensions for this slidercell is "..tostring(minWidth).." px x "..tostring(minHeight).." px")
		-- still display the garbled slidercell so we can see which slidercell is set up incorrectly
	end

	-- values
	local values = ffi.new("SliderCellDetails")
	if C.GetSliderCellValues(slidercellID, values) then
		slidercellElement.min = values.min
		slidercellElement.minSelect = values.minSelect
		slidercellElement.max = values.max
		slidercellElement.maxSelect = values.maxSelect
		slidercellElement.step = values.step
		slidercellElement.cur = values.start
		slidercellElement.maxfactor = values.maxfactor
		slidercellElement.exceedmax = values.exceedmax
		slidercellElement.hidemaxvalue = values.hidemaxvalue
		slidercellElement.righttoleft = values.righttoleft
		slidercellElement.fromcenter = values.fromcenter
		slidercellElement.readonly = values.readonly
		slidercellElement.useinfinitevalue = values.useinfinitevalue
		slidercellElement.infinitevalue = values.infinitevalue
		slidercellElement.useTimeFormat = values.usetimeformat
	end
	slidercellElement.forceArrows = C.DoesSliderCellForceArrows(slidercellID)

	while slidercellElement.cur > (slidercellElement.maxfactor * slidercellElement.max) do
		slidercellElement.maxfactor = slidercellElement.maxfactor * 2
	end

	-- position slidercell
	local x, y = GetOffset(slidercellID)
	local offsetx = x + parentx - parentwidth / 2 + width / 2
	local offsety = parenty - y - height/2

	widgetSystem.setElementPosition(slidercellElement.element.main, offsetx, offsety, (width % 2 ~= 0), (height % 2 ~= 0))
	
	widgetSystem.addHelpOverlay(frameElement, slidercellID, x + parentx - parentwidth / 2, parenty - y, width, height, nil, backgroundcolspanwidth)

	-- suffix
	slidercellElement.suffix = ffi.string(C.GetSliderCellSuffix(slidercellID))

	local textelements = {}
	textelements.caption = getElement("slider.text elements.caption", slidercellElement.element.main)
	textelements.right = getElement("slider.text elements.value_right", slidercellElement.element.main)

	-- text font
	local font = ffi.new("Font")
	if C.GetSliderCellFont(slidercellID, font) then
		slidercellElement.fontname = ffi.string(font.name)
		slidercellElement.fontsize = font.size
		for _, element in pairs(textelements) do
			setAttribute(element, "font", slidercellElement.fontname)
			setAttribute(element, "size", slidercellElement.fontsize)
		end
	end

	local accuracyoverride = C.GetSliderCellAccuracyOverride(slidercellID)
	local accuracy = 0
	if accuracyoverride == -1 then
		-- get the accuracy from the step size
		local int, frac = math.modf(slidercellElement.step)
		-- getting rid of float inaccuracy
		frac = math.floor(frac * math.pow(10, 6) + 0.5)
		if frac > 0 then
			accuracy = 7 - #tostring(frac)
		else
			i, j = string.find(int, "0+$")
			if i and j then
				accuracy = i - j - 1
			end
		end
	else
		accuracy = accuracyoverride;
	end
	slidercellElement.accuracy = accuracy
	slidercellElement.powaccuracy = math.pow(10, accuracy)

	if slidercellElement.fromcenter then
		slidercellElement.defaultSlide = "fromcenter"
		-- Set bar center width (1 pixel) and height (same as slider height)
		widgetSystem.setElementScale(getElement("slider.elements.Rectangle_barcenter", slidercellElement.element.main), 1 / 100, slidercellElement.height / 100)
	else
		slidercellElement.defaultSlide = "fromleft"
	end

	-- scale elements
	widgetSystem.setElementScale(getElement("slider.elements.Rectangle_background", slidercellElement.element.main), width / 100, height / 100)

	-- background color
	local color = ffi.new("Color")
	if C.GetSliderCellBackgroundColor(slidercellID, color) then
		slidercellElement.bgcolor = {
			["r"] = color.red,
			["g"] = color.green,
			["b"] = color.blue,
			["a"] = color.alpha
		}

		local material = getElement("slider.elements.Rectangle_background.Material651", slidercellElement.element.main)
		SetDiffuseColor(material, color.red, color.green, color.blue)
		setAttribute(material, "opacity", color.alpha)
	end
	
	-- inactive background color
	if C.GetSliderCellInactiveBackgroundColor(slidercellID, color) then
		slidercellElement.inactivebgcolor = {
			["r"] = color.red,
			["g"] = color.green,
			["b"] = color.blue,
			["a"] = color.alpha
		}

		local material = getElement("slider.elements.Rectangle_background3.Material651", slidercellElement.element.main)
		SetDiffuseColor(material, color.red, color.green, color.blue)
		-- actual opcatity is controlled by widgetSystem.updateSliderCellBackground()
		setAttribute(material, "opacity", 0)
	end

	-- NOTE: slider bar color can depend on current value and is set in updateSliderCellValue()
	-- value color
	if C.GetSliderCellValueColor(slidercellID, color) then
		slidercellElement.valuecolor = {
			["r"] = color.red,
			["g"] = color.green,
			["b"] = color.blue,
			["a"] = color.alpha
		}
		slidercellElement.valuecolor.glow = C.GetSliderCellValueGlowFactor(slidercellID)
	end

	-- negative value color
	if C.GetSliderCellNegativeValueColor(slidercellID, color) then
		slidercellElement.negativevaluecolor = {
			["r"] = color.red,
			["g"] = color.green,
			["b"] = color.blue,
			["a"] = color.alpha
		}
		slidercellElement.negativevaluecolor.glow = C.GetSliderCellNegativeValueGlowFactor(slidercellID)
	end

	-- text color
	if C.GetSliderCellTextColor(slidercellID, color) then
		slidercellElement.textcolor = {
			["r"] = color.red,
			["g"] = color.green,
			["b"] = color.blue,
			["a"] = color.alpha
		}
		slidercellElement.glowfactor = C.GetSliderCellTextGlowFactor(slidercellID)

		for _, element in pairs(textelements) do
			setAttribute(element, "textcolor.r", color.red)
			setAttribute(element, "textcolor.g", color.green)
			setAttribute(element, "textcolor.b", color.blue)
			setAttribute(element, "opacity", color.alpha)
			setAttribute(element, "glowfactor", slidercellElement.glowfactor)
		end
	else
		slidercellElement.glowfactor = 0
	end

	-- text position
	widgetSystem.setElementPosition(textelements.caption, -width / 2 + 2 * config.slidercell.arrowDimensions.width + 2 * config.slidercell.spacing, nil)
	widgetSystem.setElementPosition(textelements.right, width / 2 - 2 * config.slidercell.arrowDimensions.width - 2 * config.slidercell.spacing, nil)

	-- text
	slidercellElement.text = ffi.string(C.GetSliderCellText(slidercellID))
	setAttribute(textelements.caption, "textstring", slidercellElement.text)

	-- value text & click area
	widgetSystem.updateSliderCellValue(slidercellElement)

	-- activate the slidercell
	goToSlide(slidercellElement.element.main, slidercellElement.defaultSlide)

	-- arrows
	widgetSystem.setElementPosition(slidercellElement.element.arrow_left, -width / 2 + 1.5 * config.slidercell.arrowDimensions.width + config.slidercell.spacing, nil)
	widgetSystem.setElementPosition(slidercellElement.element.arrow_right, width / 2 - 1.5 * config.slidercell.arrowDimensions.width - config.slidercell.spacing, nil)
	widgetSystem.setElementPosition(slidercellElement.element.arrow_skip_left, -width / 2 + config.slidercell.arrowDimensions.width / 2 + config.slidercell.spacing, nil)
	widgetSystem.setElementPosition(slidercellElement.element.arrow_skip_right, width / 2 - config.slidercell.arrowDimensions.width / 2 - config.slidercell.spacing, nil)
	widgetSystem.updateSliderCellArrowSlide(slidercellElement, "left")
	widgetSystem.updateSliderCellArrowSlide(slidercellElement, "right")
	widgetSystem.updateSliderCellArrowSlide(slidercellElement, "skip_left")
	widgetSystem.updateSliderCellArrowSlide(slidercellElement, "skip_right")

	widgetSystem.updateSliderCellBackground(slidercellElement)

	widgetSystem.addToAssociationList(slidercellID, slidercellElement, slidercellElement.element.main, parentx - parentwidth / 2, parenty, parentwidth)
end

function widgetSystem.setUpStandardButtons(frameID, frameElement)
	local displayButtons = {}
	displayButtons["back"], displayButtons["close"], displayButtons["minimize"], displayButtons["help"] = GetStandardButtons(frameElement.frame)
	if not next(displayButtons) then
		return -- no standard buttons
	end

	local x, y = C.GetStandardButtonOffsetX(frameID), C.GetStandardButtonOffsetY(frameID)

	local width = math.floor(config.frame.standardButtonWidth * private.uiscale + 0.5)
	local gridwidth = width + config.frame.standardButtonOffset
	local offset = (width - config.frame.standardButtonWidth) / 2

	local upperBorder = frameElement.offsety - y - config.frame.closeButtonUpperOffset - offset
	local rightBorder = frameElement.offsetx + frameElement.width - x - config.frame.closeButtonRightOffset - offset

	-- move the button to the correct position
	widgetSystem.setElementPosition(frameElement.standardButtons, rightBorder, upperBorder)

	local buttonOffsets = {}
	local buttoncount = 0
	for _, button in ipairs(config.frame.standardButtonOrder) do
		if displayButtons[button] then
			buttonOffsets[button] = -buttoncount * gridwidth
			buttoncount = buttoncount + 1

			widgetSystem.setElementPosition(frameElement[button .. "Element"], buttonOffsets[button], 0)
			widgetSystem.setElementScale(frameElement[button .. "Element"], width / 16, width / 16)
			frameElement[button .. "ButtonShown"] = true
			widgetSystem.updateStandardButtonState(frameElement, button)

			-- in y direction we just have to substract a half offset to center the overlay on the button, in x direction we need to substract that half and another for the smaller (16px) anark element in the 18px grid
			widgetSystem.addHelpOverlay(frameElement, frameID, rightBorder + buttonOffsets[button] - gridwidth / 2 - config.frame.standardButtonOffset, upperBorder + gridwidth / 2 - config.frame.standardButtonOffset / 2, gridwidth, gridwidth, button)
		end
	end
end

-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth = width of the parent (anchor element)
function widgetSystem.setUpTable(frameElement, tableID, tableElement)
	local parentx = frameElement.offsetx
	local parenty = frameElement.offsety
	local parentwidth = frameElement.width
	local parentheight = frameElement.height

	-- offset relative to the parent with (0, 0) in the upper left corner
	local localx, localy = GetOffset(tableID)
	-- offset relative to the screen with (0, 0) in the middle
	local globalx = parentx + localx
	local globaly = parenty - localy

	-- get table height/width and ensure it does not exceed the frame border
	local _, maxtableheight = GetSize(tableID)
	if maxtableheight == 0 then
		-- if no table height is specified, use entire available height
		maxtableheight = parentheight - localy
	end
	maxtableheight = math.min(maxtableheight, parentheight - localy)
	if maxtableheight <= 0 then
		DebugError("Widget system error. No vertical space left to display the table. Skipping table.")
		return
	end

	local numRows = GetTableNumRows(tableID)

	-- prepare highlight rows
	widgetSystem.removeHighlightBorderTableRow(tableElement)
	tableElement.highlightedRows = {}

	-- set unselectable rows
	tableElement.unselectableRows = {}
	for row = 1, numRows do
		if not IsTableRowSelectable(tableID, row) then
			tableElement["unselectableRows"][row] = true
		end
	end

	-- set noninteratctive rows
	tableElement.noninteractiveRows = {}
	for row = 1, numRows do
		if not C.IsTableRowInteractive(tableID, row) then
			tableElement["noninteractiveRows"][row] = true
		end
	end

	-- set fixed row data
	tableElement["numFixedRows"] = GetTableNumFixedRows(tableID)

	local numBorderRows = 0
	for row = 1, numRows - 1 do
		if C.IsTableRowBorderBelowEnabled(tableID, row) then
			numBorderRows = numBorderRows + 1
		end
	end
	
	-- check whether or not the table should display a scrollbar
	local fullrowheight          = GetTableFullHeight(tableID)
	local requiredRowHeight      = fullrowheight + numBorderRows * config.table.bordersize
	-- #StefanLow - isn't requiredTableHeight a more suitable name
	requiredRowHeight            = math.max(requiredRowHeight, 0) -- empty tables result in a calculated height of -config.table.bordersize, hence set that to 0
	local fixedRowHeight         = widgetSystem.calculateFixedRowHeight(tableID, tableElement)
	local minNormalRowHeight     = widgetSystem.calculateMinRowHeight(tableID, tableElement)
	local minHeightWithScrollBar = math.max(minNormalRowHeight, config.table.minScrollBarHeight) + fixedRowHeight
	-- show scrollbar, if table is interactive and the available height does not suffice to show the entire content
	-- however, do not try to display a scrollbar, if the height doesn't suffice and the size required to show a scrollbar would be larger than the size required to display the actual table content
	local numTableRowElements = widgetSystem.getNumAvailableTableRowElements()
	local scrollBar = IsInteractive(tableID) and ((maxtableheight < requiredRowHeight and requiredRowHeight > minHeightWithScrollBar) or numRows > numTableRowElements)
	local mintableheight
	if scrollBar then
		mintableheight = minHeightWithScrollBar
	else
		-- if no scrollbar is displayed, we must display the entire content
		mintableheight = requiredRowHeight
	end

	-- init displayedRows, will be filled correctly in drawTableCells()
	tableElement["displayedRows"] = 0
	-- calculate table extents
	local columnWidths = { GetTableColumnWidths(tableID) }
	local columnsInPercent = IsTableColumnWidthPercentage(tableID)
	-- if we deploy a scrollbar due to not enough table rows, fix the columnwidths if necessary
	if scrollBar and (numRows > numTableRowElements) and (maxtableheight >= requiredRowHeight) and (not columnsInPercent) then
		local haszero = false
		local maxWidth = 0
		local maxWidthIdx
		for i, columnWidth in ipairs(columnWidths) do
			if columnWidth == 0 then
				haszero = true
				break
			end
			if columnWidth > maxWidth then
				maxWidth = columnWidth
				maxWidthIdx = i
			end
		end
		if not haszero and maxWidthIdx then
			if maxWidth > config.texturesizes.table.scrollBar.width + config.table.bordersize then
				columnWidths[maxWidthIdx] = columnWidths[maxWidthIdx] - config.texturesizes.table.scrollBar.width - config.table.bordersize
			end
		end
	end
	local numCols = #columnWidths
	tableElement["numCols"] = numCols
	-- maxtablewidth specifies the maximal available width for the table (for tables which are < 100% in width, this is not the same as the real table width!)
	local maxtablewidth = parentwidth - localx
	if scrollBar then
		-- reserve enough space for the scrollbar, if it's displayed
		maxtablewidth = maxtablewidth - config.texturesizes.table.scrollBar.width - config.table.bordersize
	end
	-- substract the size required to display borders (i.e. spaces between the columns) -- the number of required borders is numCols - 1 (i.e. |column1 | column2 | column3| --- 2 border elements on each side of column2)
	local maxtablewidthexcludingborders = maxtablewidth - (numCols - 1) * config.table.bordersize
	local success = widgetSystem.convertColumnWidth(columnWidths, columnsInPercent, maxtablewidthexcludingborders)
	-- #StefanMed XT-2500
	local tablewidth = widgetSystem.summarize(columnWidths) + (numCols - 1) * config.table.bordersize
	if not success then
		DebugError("Widget system error. Given/Required column width "..tablewidth.." exceeds the max table width of "..maxtablewidth..". Skipping table.")
		return
	end
	tableElement["columnWidths"] = columnWidths

	-- fixedrow area
	local fixedRowColumnWidths = {}
	for k, v in pairs(columnWidths) do
		fixedRowColumnWidths[k] = v
	end
	if scrollBar then
		fixedRowColumnWidths[#fixedRowColumnWidths] = fixedRowColumnWidths[#fixedRowColumnWidths] + config.texturesizes.table.scrollBar.width + config.table.bordersize
	end
	tableElement["fixedRowColumnWidths"] = fixedRowColumnWidths

	-- set up table heading
	local header = GetHeader(tableID)
	local headerheight, headertext = widgetSystem.setUpFontString(header, tableElement.header, tableElement.headerText, "active", "inactive", globalx, globaly, tablewidth, nil, nil, frameElement, globalx, globaly)

	-- empty table? simple case, we're done
	if numRows == 0 then
		return
	end

	-- move tableoffset to after the header
	if headertext ~= "" then
		-- only move table further down, if the header is specified
		tableoffsety = tableoffsety - headerheight - config.table.spaceafterheader
		maxtableheight = maxtableheight - headerheight - config.table.spaceafterheader
		if maxtableheight < mintableheight then
			DebugError("Widget system error. No vertical space left to display the table content. Only table header is displayed. Skipping table content.")
			return
		end
	elseif mintableheight > maxtableheight then
		-- if we don't display a header and do not have enough space left to display the table content properly, issue an error and do not display anything
		-- since we cannot properly handle scrolling right and/or would display an unscrollable table only half
		-- if we'd not abort here, we'd set the max table height to the min table height to ensure that scrolling is always working (i.e. the mintableheight is calculated to ensure that we can move up/down to
		-- each selectable row and still display the selected row) this will then result in the table being drawn beneath the frame border (since mintableheight in this case is > maxavailabletableheight)
		DebugError("Widget system error. Vertical space left ("..tostring(maxtableheight)..") doesn't suffice to display the requested table (calculated required min height: "..tostring(mintableheight).."). Table will not be displayed.")
		return
	end
	tableElement.width = tablewidth
	tableElement.height = maxtableheight -- must be set, since it's used for drawing the table initially (after which the height is updated to the real table height-value)
	tableElement.nonFixedSectionHeight = tableElement.height - fixedRowHeight -- same as with tableElement.height --- must be set here
	tableElement.offsety = globaly

	-- calculate cell x positions
	local cellposx = {
		[1] = globalx
	}
	for col = 2, numCols do
		table.insert(cellposx, cellposx[col-1] + columnWidths[col-1] + config.table.bordersize)
	end
	tableElement["cellposx"] = cellposx
	tableElement["cellposy"] = {}

	-- calculate cell x positions
	local fixedRowCellposx = {
		[1] = globalx
	}
	for col = 2, numCols do
		table.insert(fixedRowCellposx, fixedRowCellposx[col-1] + fixedRowColumnWidths[col-1] + config.table.bordersize)
	end
	tableElement["fixedRowCellposx"] = fixedRowCellposx

	-- get the first selectable row in the fixed rows
	local firstSelectableFixedRow = 0
	for row = 1, tableElement.numFixedRows do
		if not tableElement["unselectableRows"][row] then
			firstSelectableFixedRow = row
			break
		end
	end

	-- set tableElement data
	tableElement["borderEnabled"]           = IsBorderEnabled(tableID)
	tableElement["curRow"]                  = 0 -- initialized here, so that widgetSystem.selectRow() works right (must be 0, so that selectRow issues a row-selected event)
	tableElement["numRows"]                 = numRows
	-- #coreUILow - not used atm - combine slider/tablescrollbar scrolling code to be consistent and reduce code redundancy?
	tableElement["granularity"]             = 1 -- table scroll granularity is always 1
	tableElement["firstSelectableFixedRow"] = firstSelectableFixedRow
	tableElement["wrapAround"]              = IsTableWrapAround(tableID)
	tableElement["highlightMode"]           = ffi.string(C.GetTableHighlightMode2(tableID))
	tableElement["multiSelect"]             = C.IsTableMultiSelect(tableID)

	-- get the first selectable row in the normal row section
	-- first go through the list of non-fixed-rows to find a selectable one, and only if there is none start with the first fixed row
	local firstSelectableRow = firstSelectableFixedRow
	for row = tableElement.numFixedRows + 1, numRows do
		if firstSelectableRow == firstSelectableFixedRow then
			if not tableElement["unselectableRows"][row] then
				firstSelectableRow = row
			end
		end
		local cellElementID
		local col = 1
		repeat
			cellElementID, col = widgetSystem.getSelectableCellElement(tableID, row, col, 1, numCols)
			if cellElementID then
				tableElement.hasSelectableNonFixedChild = true
				break
			end
			col = col + 1
		until col > numCols
		if (firstSelectableRow ~= firstSelectableFixedRow) and tableElement.hasSelectableNonFixedChild then
			break
		end
	end

	-- fill and create table cells
	local curtableheight = widgetSystem.drawTableCells(frameElement, tableID, tableElement, tableElement.numFixedRows + 1, numRows, firstSelectableRow, true)
	tableElement.topBottomRow = tableElement.bottomRow

	-- set the tableheight to the current height, so the height of the table is not being changed after initial setup
	-- note: this handles the case where we have a scrollable table with rows of different sizes, so we do not vary the scrollbar height while we scroll up/down, but rather keep the
	-- table height maxed at the initial value
	tableElement.height = math.max(curtableheight, mintableheight)
	tableElement.nonFixedSectionHeight = tableElement.height - fixedRowHeight

	widgetSystem.addHelpOverlay(frameElement, tableID, globalx, globaly, tableElement.width, tableElement.height)

	if scrollBar then
		widgetSystem.setUpVerticalScrollBar(tableElement.scrollBar, globalx + tablewidth + config.table.bordersize, globaly - fixedRowHeight, tableElement.nonFixedSectionHeight, tableElement.nonFixedSectionHeight, requiredRowHeight)
	end

	-- mouse pick element
	tableElement.mousePick.state = {
		["mouseOver"]  = {
			["state"] = false,
			["original"] = nil,
			["row"] = nil
		}
	}
	goToSlide(tableElement.mousePick.element, "active")

	local mousepickwidth = tablewidth + (scrollBar and (config.texturesizes.table.scrollBar.width + config.table.bordersize) or 0)
	widgetSystem.setElementPosition(tableElement.mousePick.element, globalx + mousepickwidth / 2, globaly - tableElement.height / 2)
	widgetSystem.setElementScale(tableElement.mousePick.element, mousepickwidth / 100, tableElement.height / 100)

	local background = ffi.string(C.GetTableBackgroundID(tableID))
	if background ~= "" then
		local bgcolor = ffi.new("Color", { red = 255, green = 255, blue = 255, alpha = 100 })
		C.GetTableBackgroundColor(tableID, bgcolor)

		local mousePickTexture = getElement("table_mousepick.Material681.bgtexture", tableElement.mousePick.element)
		-- mouse pick element is already scaled, but we need to keep the rect containing the texture at the original 100 x 100 px (i.e. unity transformation)
		SetIcon(mousePickTexture, background, bgcolor.red, bgcolor.green, bgcolor.blue, false, 100, 100)
		-- additional scaling to slightly increase table backgrounds - not done as part of SetIcon() due to rounding
		local rawpadding = C.GetTableBackgroundPadding(tableID)
		local paddingX = rawpadding / mousepickwidth 
		local paddingY = rawpadding / tableElement.height
		widgetSystem.setElementScale(getElement("parent.parent", mousePickTexture), 1 + 2 * paddingX, 1 + 2 * paddingY )
		setAttribute(getElement("parent", mousePickTexture), "opacity", bgcolor.alpha)
	else
		widgetSystem.setElementScale(getElement("table_mousepick", tableElement.mousePick.element), 1, 1)
	end

	local mouseX, mouseY = GetLocalMousePosition()
	if mouseX and mouseY and (mouseX >= globalx) and (mouseX <= globalx + mousepickwidth) and (mouseY <= globaly) and (mouseY >= globaly - tableElement.height) then
		widgetSystem.setTableMousePickState(tableID, tableElement, "mouseOver", true)
	end

	widgetSystem.setHighlightColor(tableElement)

	-- must be done before altering the top/selected row (functions access the element via the association list)
	widgetSystem.addToAssociationList(tableID, tableElement, nil, parentx, parenty, parentwidth)

	-- #StefanLow - this could be combined with the code above, so we spare us resetting the table after initially drawing it
	-- apply initial values
	local initialSelectionInfo = C.GetTableInitialSelectionInfo(tableID)
	if initialSelectionInfo.selectedrow == 0 then
		initialSelectionInfo.selectedrow = firstSelectableRow
	end
	local newMultiselectedRows = {}
	local n = C.GetNumTableInitialMultiselectedRows(tableID)
	local buf = ffi.new("uint32_t[?]", n)
	n = C.GetTableInitialMultiselectedRows(buf, n, tableID)
	for i = 0, n-1 do
		table.insert(newMultiselectedRows, buf[i])
	end

	if initialSelectionInfo.toprow > 0 then
		local _, _, error = widgetSystem.setTopRow(tableID, initialSelectionInfo.toprow)
		if error ~= nil then
			DebugError("Widget system error. Failed to set initial top row. Top-row will not be changed. Error: "..tostring(error))
		end
	end
	if not tableElement.multiSelect then
		if initialSelectionInfo.selectedrow > 0 then
			local _, _, error = widgetSystem.selectRow(tableID, initialSelectionInfo.selectedrow)
			if error ~= nil then
				DebugError("Widget system error. Failed to set initial selected row. Selected-row will not be changed. Error: "..tostring(error))
			end
		end
	else
		if (initialSelectionInfo.selectedrow > 0) or (#newMultiselectedRows > 0) then
			local _, _, error = widgetSystem.setSelectedRows(tableID, newMultiselectedRows, initialSelectionInfo.selectedrow)
			if error ~= nil then
				DebugError("Widget system error. Failed to set initial selected rows. Selected-row will not be changed. Error: "..tostring(error))
			end
		end
	end
	if initialSelectionInfo.selectedcol > 0 then
		local _, _, error = widgetSystem.selectColumn(tableID, initialSelectionInfo.selectedcol)
		if error ~= nil then
			DebugError("Widget system error. Failed to set initial selected column. Selected-column will not be changed. Error: "..tostring(error))
		end
	end
	if tableElement.multiSelect then
		if initialSelectionInfo.shiftstart > 0 then
			tableElement.shiftStart = initialSelectionInfo.shiftstart
		end
		if initialSelectionInfo.shiftend > 0 then
			tableElement.shiftEnd = initialSelectionInfo.shiftend
		end
	end

	if tableElement.interactiveChild == nil then
		-- no interactive entry in the current table row, issue an event, once
		CallWidgetEventScripts(tableID, "onColumnChanged", nil)
	end
end

-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth  = width of the parent element (i.e. the anchor)
-- parentheight = height of the parent element (i.e. the anchor)
function widgetSystem.setUpShieldHullBar(shieldHullBarID, shieldHullBarElement, cellElement, parentx, parenty, parentwidth, parentheight)
	local x, y = GetOffset(shieldHullBarID)
	local width, height = GetSize(shieldHullBarID)
	if width == 0 then
		width = parentwidth
	end
	if height == 0 then
		height = parentheight
	end
	x = parentx + x -- shield/hull bar is left-aligned
	y = parenty - y

	-- activate the shield/hull bar first
	goToSlide(shieldHullBarElement, "top_bottom")

	widgetSystem.setElementPosition(shieldHullBarElement, x, y, false, (height % 2 ~= 0))
	widgetSystem.setElementScale(shieldHullBarElement, width / 100, 1)

	widgetSystem.addToAssociationList(shieldHullBarID, shieldHullBarElement, cellElement, parentx, parenty, parentwidth)
	widgetSystem.updateShieldHullBar(shieldHullBarElement, shieldHullBarID)
end

function widgetSystem.setUpStatusBar(statusBarID, statusBarElement, cellElement, parentx, parenty, parentwidth, parentheight, istitle)
	local x, y = GetOffset(statusBarID)
	statusBarElement.width, statusBarElement.height = GetSize(statusBarID)
	if statusBarElement.width == 0 then
		statusBarElement.width = parentwidth
	end
	if statusBarElement.height == 0 then
		statusBarElement.height = parentheight
	end
	x = parentx + x + statusBarElement.width / 2
	y = parenty - y - statusBarElement.height / 2

	if istitle then
		statusBarElement.height = math.floor(statusBarElement.height - 2 * config.table.titleLineHeight)
		y = y + 2 * config.table.titleLineHeight
	end

	widgetSystem.updateStatusBar(statusBarElement, statusBarID)

	widgetSystem.setElementPosition(statusBarElement.element, x, y, (statusBarElement.width % 2 ~= 0), (statusBarElement.height % 2 ~= 0))

	widgetSystem.addToAssociationList(statusBarID, statusBarElement, cellElement, parentx, parenty, parentwidth)
end

-- scrollBar           = the scrollbar to setup
-- posx                = x-position of the scrollbar's upper left corner
-- posy                = y-position of the scrollbar's upper left corner
-- scrollbarHeight     = the height the entire scrollbar can use
-- visibleParentHeight = the visible height of the parent element represented by the scrollbar slider (usually same as scrollbarHeight)
-- fullParentHeight    = the (virtual) full height of the parent element represented by the whole scrollbar (i.e. equals visibleParentHeight if fully visible)
function widgetSystem.setUpVerticalScrollBar(scrollBar, posx, posy, scrollbarHeight, visibleParentHeight, fullParentHeight)
	-- store relevant scrollbar infor
	scrollBar.height = scrollbarHeight

	-- set values for entire scrollbar
	local scrollBarElement = scrollBar.element
	goToSlide(scrollBarElement, "active")
	goToSlide(scrollBar.sliderElement, "normal")
	-- set x- and y-positions for the entire component - y-positions will be set relative to the center of the scrollbar
	widgetSystem.setElementPosition(scrollBarElement, posx + config.texturesizes.table.scrollBar.width / 2, posy - scrollbarHeight / 2)

	-- set background element
	local background  = getElement("background.center", scrollBarElement)
	local scalefactor = scrollbarHeight / 100
	widgetSystem.setElementScale(background, nil, scalefactor)

	local color = Color["scrollbar_background"]
	local material = getElement("Material568", background)
	SetDiffuseColor(material, color.r, color.g, color.b)
	setAttribute(material, "opacity", color.a)
	setAttribute(material, "glowfactor", color.glow)

	-- calculate slider height
	local sliderHeight = scrollbarHeight * visibleParentHeight / fullParentHeight
	sliderHeight = math.min(math.max(sliderHeight, config.table.minScrollBarHeight), scrollbarHeight)

	-- scale center slider element
	local centerSliderElement = getElement("center.scale", scrollBar.sliderElement)
	local centerElementHeight = sliderHeight
	-- the actual calculation is like this: centerElementHeight in AnarkPx (i.e. centerElementHeight/100) / AnarkElementResolution (which is textureSizeHeightOfBorderElement/100)
	-- this can be reduced to the following formula
	--scalefactor = centerElementHeight / 100 / (config.texturesizes.table.scrollBar.sliderCenterElementHeight / 100)
	scalefactor = centerElementHeight / config.texturesizes.table.scrollBar.sliderCenterElementHeight
	widgetSystem.setElementScale(centerSliderElement, nil, scalefactor)

	local color = Color["scrollbar_slider_normal"]
	local material = getElement("center.Material600", centerSliderElement)
	SetDiffuseColor(material, color.r, color.g, color.b)
	setAttribute(material, "opacity", color.a)
	setAttribute(material, "glowfactor", color.glow)

	local color = Color["scrollbar_slider_highlight"]
	local material = getElement("center_highlight.Material1144", centerSliderElement)
	SetDiffuseColor(material, color.r, color.g, color.b)
	setAttribute(material, "opacity", color.a)
	setAttribute(material, "glowfactor", color.glow)

	local color = Color["scrollbar_slider_click"]
	local material = getElement("center_click.Material670", centerSliderElement)
	SetDiffuseColor(material, color.r, color.g, color.b)
	setAttribute(material, "opacity", color.a)
	setAttribute(material, "glowfactor", color.glow)

	-- initialize scrollbar values
	scrollBar.active = true
	scrollBar.sliderHeight = sliderHeight
	scrollBar.valuePerPixel = fullParentHeight / visibleParentHeight

	-- move scrollbar to start position
	widgetSystem.updateVerticalScrollBar(scrollBar, 0)
end

-- scrollBar          = the scrollbar to setup
-- posx               = x-position of the scrollbar's upper left corner
-- posy               = y-position of the scrollbar's upper left corner
-- scrollbarWidth     = the width the entire scrollbar can use
-- visibleParentWidth = the visible width of the parent element represented by the scrollbar slider (usually same as scrollbarWidth)
-- fullParentWidth    = the (virtual) full width of the parent element represented by the whole scrollbar (i.e. equals visibleParentWidth if fully visible)
function widgetSystem.setUpHorizontalScrollBar(scrollBar, posx, posy, scrollbarWidth, visibleParentWidth, fullParentWidth)
	-- store relevant scrollbar infor
	scrollBar.width = scrollbarWidth

	-- set values for entire scrollbar
	local scrollBarElement = scrollBar.element
	goToSlide(scrollBarElement, "active")
	goToSlide(scrollBar.sliderElement, "normal")
	-- set x- and y-positions for the entire component - x-positions will be set relative to the center of the scrollbar
	widgetSystem.setElementPosition(scrollBarElement, posx + scrollbarWidth / 2, posy - config.texturesizes.table.scrollBar.width / 2)

	-- set background element
	local background  = getElement("background.center", scrollBarElement)
	local scalefactor = scrollbarWidth / 100
	widgetSystem.setElementScale(background, scalefactor, nil)

	-- calculate slider width
	local sliderWidth = scrollbarWidth * visibleParentWidth / fullParentWidth
	sliderWidth = math.min(math.max(sliderWidth, config.table.minScrollBarHeight), scrollbarWidth)

	-- scale center slider element
	local centerSliderElement = getElement("center.scale", scrollBar.sliderElement)
	local centerElementWidth = sliderWidth
	-- the actual calculation is like this: centerElementWidth in AnarkPx (i.e. centerElementWidth/100) / AnarkElementResolution (which is textureSizeWidthOfBorderElement/100)
	-- this can be reduced to the following formula
	--scalefactor = centerElementWidth / 100 / (config.texturesizes.table.scrollBar.sliderCenterElementHeight / 100)
	scalefactor = centerElementWidth / config.texturesizes.table.scrollBar.sliderCenterElementHeight
	widgetSystem.setElementScale(centerSliderElement, scalefactor, nil)

	-- initialize scrollbar values
	scrollBar.active = true
	scrollBar.sliderWidth = sliderWidth
	scrollBar.valuePerPixel = fullParentWidth / visibleParentWidth

	-- move scrollbar to start position
	widgetSystem.updateHorizontalScrollBar(scrollBar, 0)
end

function widgetSystem.startDropDownScrollBarDrag(dropdownID, dropdownElement)
	private.dropDownScrollBarDrag = dropdownElement
	local sliderPosY = widgetSystem.getScrollBarSliderPosition(dropdownElement.element.scrollBar.element) + dropdownElement.offsety
	local _, mouseY = GetLocalMousePosition()
	dropdownElement.element.scrollBar.dragOffset = mouseY - sliderPosY
	widgetSystem.updateDropDownScrollBarPos(dropdownID, dropdownElement)
end

function widgetSystem.startFlowchartScrollBarDrag(flowchartElement, scrollbar)
	private.flowchartScrollBarDrag = { element = flowchartElement, scrollbar = scrollbar }
	if scrollbar.type == "vertical" then
		local sliderPosY = widgetSystem.getScrollBarSliderPosition(scrollbar.element)
		local _, mouseY = GetLocalMousePosition()
		scrollbar.dragOffset = mouseY - sliderPosY
	else
		local sliderPosX = widgetSystem.getHorizontalScrollBarSliderPosition(scrollbar.element)
		local mouseX = GetLocalMousePosition()
		scrollbar.dragOffset = mouseX - sliderPosX
	end
	widgetSystem.updateFlowchartScrollBarPos(flowchartElement, scrollbar)
end

function widgetSystem.startScrollBarDrag(tableElement)
	private.scrollBarDrag = tableElement
	local sliderPosY = widgetSystem.getScrollBarSliderPosition(tableElement.scrollBar.element)
	local _, mouseY = GetLocalMousePosition()
	tableElement.scrollBar.dragOffset = mouseY - sliderPosY
	widgetSystem.updateScrollBarPos(tableElement)
end

function widgetSystem.startScrollLeft(scrollingElement)
	if private.scrolling ~= nil then
		return false -- skip call, if any scroll action is already active
	end

	private.nextTickTime     = getElapsedTime() + config.slider.interval.initialTickDelay
	private.scrolling        = "left"
	private.scrollingElement = scrollingElement
	private.curScrollingStep = scrollingElement.granularity
	widgetSystem.scrollLeft(scrollingElement, widgetSystem.getCurrentInterval())
	return true
end

function widgetSystem.startScrollRight(scrollingElement)
	if private.scrolling ~= nil then
		return false -- skip call, if any scroll action is already active
	end

	private.nextTickTime     = getElapsedTime() + config.slider.interval.initialTickDelay
	private.scrolling        = "right"
	private.scrollingElement = scrollingElement
	private.curScrollingStep = scrollingElement.granularity
	widgetSystem.scrollRight(scrollingElement, widgetSystem.getCurrentInterval())
	return true
end

function widgetSystem.stopScroll()
	private.nextStepIncreaseTime = nil
	private.nextTickTime         = nil
	private.scrolling            = nil
	private.scrollingElement     = nil
	private.numStepIncreases     = 0
	private.curScrollingStep     = nil
end

function widgetSystem.stopDropDownScrollBarDrag(dropdownID, dropdownElement)
	private.dropDownScrollBarDrag = nil
	dropdownElement.element.scrollBar.dragOffset = nil
	dropdownElement.element.scrollBar.previousMousePos = nil
end

function widgetSystem.stopFlowchartScrollBarDrag(flowchartElement, scrollbar)
	private.flowchartScrollBarDrag = nil
	scrollbar.dragOffset = nil
	scrollbar.previousMousePos = nil
end

function widgetSystem.stopScrollBarDrag(tableElement)
	private.scrollBarDrag                   = nil
	tableElement.scrollBar.dragOffset       = nil
	tableElement.scrollBar.previousMousePos = nil
end

function widgetSystem.startSliderCellScroll(slidercellElement, direction)
	if private.slidercellScrolling then
		-- a slidercell is already scrolling, skip
		return false
	end

	private.slidercellScrolling = { 
		element = slidercellElement,
		nextTick = getElapsedTime() + config.slidercell.interval.initialTickDelay,
		direction = direction,
		curStepIdx = 1,
		nextStepIncrease = getElapsedTime() + config.slidercell.interval.initialStepDelay
	}

	widgetSystem.scrollSliderCell()

	return true
end

function widgetSystem.stopSliderCellScroll(slidercellElement)
	if private.slidercellScrolling and (private.slidercellScrolling.element == slidercellElement) then
		private.slidercellScrolling = nil
		return true
	end

	return false
end

function widgetSystem.scrollSliderCell()
	if not private.slidercellScrolling then
		-- no slidercell scrolling, skip
		return
	end

	if (private.slidercellScrolling.nextStepIncrease < getElapsedTime()) and (private.slidercellScrolling.curStepIdx < #config.slidercell.interval.steps) then
		private.slidercellScrolling.curStepIdx = private.slidercellScrolling.curStepIdx + 1
		local stepIncrease = math.min(config.slidercell.interval.initialStepDelay + (private.slidercellScrolling.curStepIdx - 1) * config.slidercell.interval.stepDelayIncrease, config.slidercell.interval.maxStepDelay)
		private.slidercellScrolling.nextStepIncrease = private.slidercellScrolling.nextStepIncrease + stepIncrease
	end

	local slidercellElement = private.slidercellScrolling.element
	local step = private.slidercellScrolling.direction * (slidercellElement.righttoleft and -1 or 1) * slidercellElement.step * config.slidercell.interval.steps[private.slidercellScrolling.curStepIdx]

	widgetSystem.setSliderCellCurValue(slidercellElement, slidercellElement.cur + step, false, true)
	widgetSystem.updateSliderCellValue(slidercellElement)
end

function widgetSystem.setSliderCellCurValue(slidercellElement, value, exceedmaxallowed, allowupdate, keepmaxfactor)
	local slidercellID = widgetSystem.getWidgetIDByElementEntry(slidercellElement)

	local oldvalue = slidercellElement.cur
	-- general limits
	value = math.min(math.max(value, config.slidercell.min), config.slidercell.max)

	-- user-set limits
	slidercellElement.cur = math.max(slidercellElement.minSelect, value)
	if not keepmaxfactor then
		if exceedmaxallowed and slidercellElement.exceedmax then
			while slidercellElement.cur >= (slidercellElement.maxfactor * slidercellElement.max) do
				slidercellElement.maxfactor = slidercellElement.maxfactor * 2
			end
		else
			slidercellElement.cur = math.min(slidercellElement.maxfactor * slidercellElement.maxSelect, slidercellElement.cur)
		end

		while (slidercellElement.maxfactor ~= 1) and (slidercellElement.cur < (slidercellElement.maxfactor * slidercellElement.max / 2)) do
			slidercellElement.maxfactor = slidercellElement.maxfactor / 2
		end
		if allowupdate then
			C.SetSliderCellMaxFactor(slidercellID, slidercellElement.maxfactor)
		end
	end

	if allowupdate and (slidercellElement.cur ~= oldvalue) then
		C.SetSliderCellValue(slidercellID, slidercellElement.cur)
		CallWidgetEventScripts(slidercellID, "onSliderCellChanged", slidercellElement.cur)
	end

	widgetSystem.updateSliderCellArrowSlide(slidercellElement, "left")
	widgetSystem.updateSliderCellArrowSlide(slidercellElement, "right")
	widgetSystem.updateSliderCellArrowSlide(slidercellElement, "skip_left")
	widgetSystem.updateSliderCellArrowSlide(slidercellElement, "skip_right")

	widgetSystem.updateSliderCellBackground(slidercellElement)
end

function widgetSystem.setSliderCellValue(slidercellID, value, newmaxselect)
	local slidercellentry = private.associationList[slidercellID]
	if slidercellentry == nil then
		return false, 1, "invalid slidercell element"
	end

	if newmaxselect then
		slidercellentry.element.maxSelect = newmaxselect
		C.SetSliderCellMaxSelectValue(slidercellID, newmaxselect)
	end
	slidercellentry.element.cur = math.max(slidercellentry.element.minSelect, math.min(slidercellentry.element.maxfactor * slidercellentry.element.maxSelect, value))
	C.SetSliderCellValue(slidercellID, slidercellentry.element.cur)
	widgetSystem.updateSliderCellValue(slidercellentry.element)
	widgetSystem.updateSliderCellArrowSlide(slidercellentry.element, "left")
	widgetSystem.updateSliderCellArrowSlide(slidercellentry.element, "right")
	widgetSystem.updateSliderCellArrowSlide(slidercellentry.element, "skip_left")
	widgetSystem.updateSliderCellArrowSlide(slidercellentry.element, "skip_right")

	widgetSystem.updateSliderCellBackground(slidercellentry.element)
end

function widgetSystem.updateSliderCellValue(slidercellElement)
	local curNumber = tonumber(slidercellElement.cur)
	local curMin = slidercellElement.min
	local curMax = slidercellElement.maxfactor * slidercellElement.max

	-- format current value
	local curText = ""
	local centerZeroText = false
	if curNumber then
		curNumber = math.floor(curNumber * math.pow(10, 6) + 0.5) / math.pow(10, 6)
		if slidercellElement.fromcenter and curNumber == 0 and not slidercellElement.inputActive then
			-- text area (and value click area) is in the center, do not show text at all
			centerZeroText = true
		else
			if slidercellElement.useTimeFormat and (not slidercellElement.inputActive) then
				curText = ConvertTimeString(curNumber * 60, L["%h h %M"])
			else
				local int, frac = math.modf(curNumber)
				-- do not shorten number when text input is active
				curText = ConvertIntegerString(int, true, ((not slidercellElement.inputActive) and (slidercellElement.accuracy < 0)) and slidercellElement.accuracy or 0, true, false)
				if slidercellElement.inputActive then
					if frac > 0 then
						frac = math.floor(frac * slidercellElement.powaccuracy + 0.5) / slidercellElement.powaccuracy
						curText = curText .. L["."] .. string.gsub(frac, "0+%.", "")
					elseif string.find(slidercellElement.cur, "%.$") then
						curText = curText .. L["."]
					end
				elseif slidercellElement.accuracy > 0 then
					frac = math.floor(frac * slidercellElement.powaccuracy + 0.5)
					curText = curText .. L["."] .. string.format("%0" .. slidercellElement.accuracy .. "d", frac)
				end
			end
		end
		if slidercellElement.useinfinitevalue then
			if (not slidercellElement.inputActive) and (slidercellElement.infinitevalue == curNumber) then
				curText = utf8.char(8734)
			end
		end
	else
		curText = slidercellElement.cur
		if slidercellElement.inputActive and tonumber(slidercellElement.oldcur) then
			-- input started but no text yet, use previous value
			curNumber = tonumber(slidercellElement.oldcur)
		else
			-- invalid input, use a valid number in selectable range, as close to 0 as possible
			curNumber = math.max(math.min(0, slidercellElement.maxfactor * slidercellElement.maxSelect), slidercellElement.minSelect)
		end
	end

	-- cursor
	local cursor = ""
	if slidercellElement.inputActive then
		if slidercellElement.cursor then
			cursor = config.slidercell.cursor
		else
			cursor = " "
		end
	end

	-- update text
	local text = ""
	if not centerZeroText then
		text = curText .. cursor
		if (not slidercellElement.fromcenter) and (not slidercellElement.exceedmax) and (not slidercellElement.hidemaxvalue) then
			-- format max value
			local int, frac = math.modf(slidercellElement.max)
			local maxText = ""
			if slidercellElement.useTimeFormat and (not slidercellElement.inputActive) then
				if slidercellElement.suffix ~= "" then
					maxText = " " .. slidercellElement.suffix
				end
				maxText = maxText .. " / " .. ConvertTimeString(int * 60, L["%h h %M"])
			else
				maxText = " / " .. ConvertIntegerString(int, true, slidercellElement.accuracy < 0 and slidercellElement.accuracy or 0, true, false)
				if slidercellElement.accuracy > 0 then
					frac = math.floor(frac * slidercellElement.powaccuracy + 0.5)
					maxText = maxText .. L["."] .. string.format("%0".. slidercellElement.accuracy .."d", frac)
				end
			end
			text = text .. maxText
		end
		if slidercellElement.suffix ~= "" then
			text = text .. " " .. slidercellElement.suffix
		end
	end
	local textelement = getElement("slider.text elements.value_right", slidercellElement.element.main)
	setAttribute(textelement, "textstring", text)

	local textrightpos = slidercellElement.width / 2 - 2 * config.slidercell.arrowDimensions.width - 2 * config.slidercell.spacing
	local textwidth = C.GetTextWidth(text, slidercellElement.fontname, slidercellElement.fontsize)

	-- update text position and alignment if required (only in fromcenter mode)
	if slidercellElement.fromcenter then
		-- don't change text position while input is active - use position of previous value
		local lastNumber = slidercellElement.inputActive and (tonumber(slidercellElement.oldcur) or 0)
		local isnegative = (lastNumber or curNumber) < 0
		if isnegative == slidercellElement.righttoleft then
			-- bar on right side, text right-aligned on left side
			setAttribute(textelement, "horzalign", widgetSystem.convertAlignment("right"))
			widgetSystem.setElementPosition(textelement, -config.slidercell.spacing, nil)
			textrightpos = -config.slidercell.spacing
		else
			-- bar on left side, text left-aligned on right side
			setAttribute(textelement, "horzalign", widgetSystem.convertAlignment("left"))
			widgetSystem.setElementPosition(textelement, config.slidercell.spacing, nil)
			textrightpos = config.slidercell.spacing + textwidth
		end
		if centerZeroText then
			-- special case: No text visible, small click area at the center
			textwidth = math.floor(2 * config.slidercell.spacing * private.uiscale + 0.5)
			textrightpos = textwidth / 2
		end
	else
		-- set default alignment in standard slider case
		setAttribute(textelement, "horzalign", widgetSystem.convertAlignment("right"))
	end

	-- update value click area
	local clickarea = getElement("slider.elements.Rectangle_values", slidercellElement.element.main)
	widgetSystem.setElementPosition(clickarea, textrightpos, nil)		-- pivot = 50%
	widgetSystem.setElementScale(clickarea, textwidth / 100, slidercellElement.height / 100)
	--[[ enable to debug click area
	local material = getElement("Material651", clickarea)
	SetDiffuseColor(material, 255, 0, 0)
	setAttribute(material, "opacity", 100)--]]

	-- set slider bar color (use either valuecolor or negativevaluecolor)
	local color = (curNumber < 0 and slidercellElement.negativevaluecolor) or slidercellElement.valuecolor
	if color then
		local material = getElement("slider.elements.Rectangle_background2.Material651", slidercellElement.element.main)
		SetDiffuseColor(material, color.r, color.g, color.b)
		setAttribute(material, "opacity", color.a)
		setAttribute(material, "glowfactor", color.glow)
		if slidercellElement.fromcenter then
			-- set center bar color (but do not touch opacity)
			local centermaterial = getElement("slider.elements.Rectangle_barcenter.Material651", slidercellElement.element.main)
			local centercolor = curNumber == 0 and slidercellElement.textcolor or color
			SetDiffuseColor(centermaterial, centercolor.r, centercolor.g, centercolor.b)
		end
	end

	-- update slider bar
	local xstart = widgetSystem.getSliderCellBaseXPosition(slidercellElement) - 0.5
	local xend = widgetSystem.getSliderCellXPositionFromValue(slidercellElement, curNumber) - 0.5
	local background2 = getElement("slider.elements.Rectangle_background2", slidercellElement.element.main)
	widgetSystem.setElementPosition(background2, (xstart + xend) / 2 * slidercellElement.width, 0, (slidercellElement.width % 2 ~= 0), 0)
	widgetSystem.setElementScale(background2, (xend - xstart) * slidercellElement.width / 100, slidercellElement.height / 100)
end

function widgetSystem.getSliderCellMousePosition(frameElement, slidercellID)
	local slidercellElement = private.associationList[slidercellID]
	if slidercellElement == nil then
		return nil, nil, 1, "invalid slidercell element"
	end

	-- NOTE: This should work more reliably than GetLocalMousePosition(), but only for mouse positions inside the slider rectangle, so it's not good enough at the moment
	--local backgroundElement = getElement("slider.elements.Rectangle_background", slidercellElement.element.element.main)
	--local posX, posY = GetRelativeMousePosition(backgroundElement, false)
	--return posX, posY

	local posX, posY = GetLocalMousePosition()
	if posX == nil then
		return nil -- currently not over the presentation at all - valid call, but no mouse position
	end

	local x, y = GetOffset(slidercellID)
	local offsetx = x + slidercellElement.parentx
	local offsety = slidercellElement.parenty - y

	-- transform space into slidercell space (upper left corner is 0/0)
	local centerX = offsetx
	local centerY = offsety
	local slidercellPosX = posX - centerX
	local slidercellPosY = centerY - posY

	if (slidercellPosX <= 0) or (slidercellPosX > slidercellElement.element.width) or (slidercellPosY <= 0) or (slidercellPosY > slidercellElement.element.height) then
		-- do not early out here to allow dragging the slidercell value even outside the element
		--return nil -- inside the correct presentation but not over the slidercell - valid call, but no mouse position
	end

	return slidercellPosX / slidercellElement.element.width, slidercellPosY / slidercellElement.element.height
end

function widgetSystem.getEditBoxMousePosition(frameElement, editboxID)
	local editboxElement = private.associationList[editboxID]
	if editboxElement == nil then
		return nil, nil, 1, "invalid editbox element"
	end

	-- NOTE: This should work more reliably than GetLocalMousePosition(), but only for mouse positions inside the slider rectangle, so it's not good enough at the moment
	--local backgroundElement = getElement("slider.elements.Rectangle_background", slidercellElement.element.element.main)
	--local posX, posY = GetRelativeMousePosition(backgroundElement, false)
	--return posX, posY

	local posX, posY = GetLocalMousePosition()
	if posX == nil then
		return nil -- currently not over the presentation at all - valid call, but no mouse position
	end

	local x, y = GetOffset(editboxID)
	local offsetx = x + editboxElement.parentx - editboxElement.element.width / 2
	local offsety = editboxElement.parenty - y

	-- transform space into slidercell space (upper left corner is 0/0)
	local centerX = offsetx
	local centerY = offsety
	local editboxPosX = posX - centerX
	local editboxPosY = centerY - posY

	if (editboxPosX <= 0) or (editboxPosX > editboxElement.element.width) or (editboxPosY <= 0) or (editboxPosY > editboxElement.element.height) then
		-- do not early out here to allow dragging the editbox highlight even outside the element
		--return nil -- inside the correct presentation but not over the editbox - valid call, but no mouse position
	end

	return editboxPosX, editboxPosY
end

function widgetSystem.getSliderCellValueFromXPosition(slidercellElement, x)
	if slidercellElement.righttoleft then
		x = (1 - x)
	end
	local minvalue = slidercellElement.min
	local maxvalue = slidercellElement.maxfactor * slidercellElement.max
	if slidercellElement.fromcenter then
		-- Zero is in the center, bar extends from there (with different step widths on positive and negative side)
		-- Adjust x range and value range accordingly
		if x < 0.5 then
			maxvalue = 0
			x = x * 2      -- [0 .. 0.5] -> [0 .. 1]
		else
			minvalue = 0
			x = x * 2 - 1  -- [0.5 .. 1] -> [0 .. 1]
		end
	end
	-- Bar extends from left side
	local value = minvalue + (math.floor(x * (maxvalue - minvalue) / slidercellElement.step + 0.5) * slidercellElement.step)
	return math.min(math.max(value, slidercellElement.minSelect), slidercellElement.maxfactor * slidercellElement.maxSelect)
end

function widgetSystem.getSliderCellXPositionFromValue(slidercellElement, value)
	local minvalue = slidercellElement.min
	local maxvalue = slidercellElement.maxfactor * slidercellElement.max
	-- NOTE: Do not check value == min or max here since there can be different values in fromcenter case
	local x = 0.5
	if value < minvalue then
		x = 0
	elseif value > maxvalue then
		x = 1
	elseif slidercellElement.fromcenter then
		-- Zero is in the center, bar extends from there (with different step widths on positive and negative side)
		-- 0.5 is the center x position
		if value < 0 then
			x = 0.5 * (1 - value / minvalue)
		elseif value > 0 then
			x = 0.5 * (1 + value / maxvalue)
		else
			x = 0.5
		end
	else
		-- Bar extends from left side
		x = (minvalue == maxvalue) and 0 or (value - minvalue) / (maxvalue - minvalue)
	end
	return slidercellElement.righttoleft and (1 - x) or x
end

function widgetSystem.getSliderCellBaseXPosition(slidercellElement)
	if slidercellElement.fromcenter then
		return 0.5
	end
	return slidercellElement.righttoleft and 1 or 0
end

function widgetSystem.getDropDownMousePosition(dropdownID)
	local dropdownElement = private.associationList[dropdownID]
	if dropdownElement == nil then
		return nil, nil, 1, "invalid dropdown element"
	end

	local posX, posY = GetLocalMousePosition()
	if posX == nil then
		return nil -- currently not over the presentation at all - valid call, but no mouse position
	end
	
	local x, y = GetOffset(dropdownID)
	local offsetx = x + dropdownElement.parentx
	local offsety = dropdownElement.parenty - y
	if dropdownElement.element.flipped then
		offsety = offsety + dropdownElement.element.fullHeight - dropdownElement.element.height
	end

	-- transform space into dropdown space (upper left corner is 0/0)
	local centerX = offsetx
	local centerY = offsety
	local dropdownPosX = posX - centerX
	local dropdownPosY = centerY - posY
	local width = math.max(dropdownElement.element.width, dropdownElement.element.optionwidth)

	if (dropdownPosX <= 0) or (dropdownPosX > width) or (dropdownPosY <= 0) or (dropdownPosY > dropdownElement.element.fullHeight) then
		return nil -- inside the correct presentation but not over the slidercell - valid call, but no mouse position
	end
	
	return dropdownPosX, dropdownPosY
end

function widgetSystem.summarize(array)
	local sum = 0
	for _, value in ipairs(array) do
		sum = sum + value
	end
	return sum
end

function widgetSystem.swapButtonIcon(buttonID, buttonElement)
	if buttonElement.swapIconID == nil then
		return -- no icon to swap
	end

	local newIcon = buttonElement.swapIconID
	buttonElement.swapIconID = buttonElement.iconID
	buttonElement.iconID = newIcon
	
	local material = getElement("Icon.Icon.Material423", buttonElement.element)
	if buttonElement.iconColor ~= nil then
		SetIcon(getElement("Icon", material), newIcon, buttonElement.iconColor.r, buttonElement.iconColor.g, buttonElement.iconColor.b, false, buttonElement.iconWidth, buttonElement.iconHeight)
		setAttribute(material, "opacity", buttonElement.iconColor.a)
	else
		SetIcon(getElement("Icon", material), newIcon, nil, nil, nil, false, buttonElement.iconWidth, buttonElement.iconHeight)
	end
end

function widgetSystem.swapButtonIcon2(buttonID, buttonElement)
	if buttonElement.swapIcon2ID == nil then
		return -- no icon to swap
	end

	local newIcon = buttonElement.swapIcon2ID
	buttonElement.swapIcon2ID = buttonElement.icon2ID
	buttonElement.icon2ID = newIcon
	
	local material = getElement("Icon2.Icon2.Imaterial_icon2", buttonElement.element)
	if buttonElement.icon2Color ~= nil then
		SetIcon(getElement("icon2", material), newIcon, buttonElement.icon2Color.r, buttonElement.icon2Color.g, buttonElement.icon2Color.b, false, buttonElement.icon2Width, buttonElement.icon2Height)
		setAttribute(material, "opacity", buttonElement.icon2Color.a)
	else
		SetIcon(getElement("icon2", material), newIcon, nil, nil, nil, false, buttonElement.icon2Width, buttonElement.icon2Height)
	end
end

function widgetSystem.swapInteractiveRegion(tableID, tableElement)
	if tableElement.firstSelectableFixedRow == 0 then
		return false -- no fixed rows at all or no selectable row in the fixed row section => nothing to swap
	end

	if tableElement.interactiveRegion == "fixed" then
		widgetSystem.selectRowInternal(tableID, tableElement, tableElement.normalSelectedRow)
	else -- tableElement.interactiveRegion == "normal"
		widgetSystem.selectRowInternal(tableID, tableElement, tableElement.firstSelectableFixedRow)
	end
	return true
end

-- childWidgetID     - the widgetID of the interactive child
-- childTableElement - the table entry of the element of the child
function widgetSystem.unsetInteractiveChildElement(tableElement, childWidgetID, childTableElement)
	if not IsValidWidgetElement(childWidgetID) then
		-- view might have already been changed
		return
	end
	if childTableElement ~= nil then
		-- note: other than for the setIntearctiveElement() we do not check whether the given child is in the current interactive table, since we are unsetting the
		-- element (and that does not cause any damage, if we do so for the non-interactive element)
		-- #StefanLow - revise this reasoning --- sounds not too convincing...
		if IsType(childWidgetID, "button") then
			widgetSystem.setButtonElementState(childWidgetID, childTableElement, "keyboard", false)
			if (tableElement.highlightMode == "off") or (tableElement.highlightMode == "offnormalscroll") then
				widgetSystem.setButtonElementState(childWidgetID, childTableElement, "mouseOver", false)
			end
		elseif IsType(childWidgetID, "checkbox") then
			widgetSystem.setCheckBoxElementState(childWidgetID, childTableElement, "keyboard", false)
			if (tableElement.highlightMode == "off") or (tableElement.highlightMode == "offnormalscroll") then
				widgetSystem.setCheckBoxElementState(childWidgetID, childTableElement, "mouseOver", false)
			end
		elseif IsType(childWidgetID, "dropdown") then
			widgetSystem.setDropDownElementState(childWidgetID, childTableElement, "keyboard", false)
			if (tableElement.highlightMode == "off") or (tableElement.highlightMode == "offnormalscroll") then
				widgetSystem.setDropDownElementState(childWidgetID, childTableElement, "mouseOver", false)
			end
		elseif IsType(childWidgetID, "editbox") then
			widgetSystem.updateEditBoxColor(childWidgetID, childTableElement, false)
		end
		-- for other interactive elements, there's nothing to do
	end

	if private.enableMouseOverText then
		if private.mouseOverText and (private.mouseOverText.posOverride ~= nil) then
			widgetSystem.hideMouseOverText(childWidgetID, true)
		end
	end
end

function widgetSystem.updateButton(buttonID, buttonElement)
	local text = GetButtonText(buttonID)
	setAttribute(getElement("Text", buttonElement.element), "textstring", text)

	local textinfo = ffi.new("TextInfo")
	local hastext2 = C.GetButtonText2Details(buttonID, textinfo)
	if hastext2 then
		setAttribute(getElement("Text2", buttonElement.element), "textstring", ffi.string(textinfo.text))
	else
		setAttribute(getElement("Text2", buttonElement.element), "textstring", "")
	end

	buttonElement.active = IsButtonActive(buttonID)
	if buttonElement.previouslyActive ~= buttonElement.active then
		-- update slide, update text/icon colors and fire events if necessary (also update buttonElement.previouslyActive)
		widgetSystem.updateButtonState(buttonID, buttonElement)
	else
		-- just update colors
		local colorMode = "normal"
		if not buttonElement.active then
			colorMode = "gray"
		end
		widgetSystem.updateButtonColor(buttonID, buttonElement, colorMode)
	end

	-- update button color
	if buttonElement.active then
		local r, g, b, a = GetButtonColor(buttonID)
		local glowfactor = C.GetButtonColorGlowFactor(buttonID)
		buttonElement.color = { r = r, g = g, b = b, a = a, glow = glowfactor }
	else
		buttonElement.color = Color["button_background_inactive"]
	end
	local material = getElement("background.Material753", buttonElement.element)
	SetDiffuseColor(material, buttonElement.color.r, buttonElement.color.g, buttonElement.color.b)
	setAttribute(material, "opacity", buttonElement.color.a)
	setAttribute(material, "glowfactor", buttonElement.color.glow or 0)
end

function widgetSystem.updateButtonColor(buttonID, buttonElement, colorMode)
	if buttonElement.iconID then
		-- icon button
		local iconID = GetButtonIcon(buttonID)
		if iconID ~= nil then
			buttonElement.iconID = iconID
		end
		local r, g, b, a = GetButtonIconColor(buttonID)
		local glowfactor = C.GetButtonIconGlowFactor(buttonID)
		if colorMode == "inverse" then
			r, g, b = widgetSystem.invertColor(r, g, b)
		elseif colorMode == "gray" then
			local color = Color["button_text_inactive"]
			r, g, b = color.r, color.g, color.b
			glowfactor = color.glow
		-- else, it's "normal" and uses the original color
		end
		local material = getElement("Icon.Icon.Material423", buttonElement.element)
		SetIcon(getElement("Icon", material), buttonElement.iconID, r, g, b, false, buttonElement.iconWidth, buttonElement.iconHeight)
		setAttribute(material, "opacity", a)
		setAttribute(material, "glowfactor", glowfactor)
	end
	if buttonElement.icon2ID then
		-- icon button
		local iconID = GetButtonIcon2(buttonID)
		if iconID ~= nil then
			buttonElement.icon2ID = iconID
		end
		local r, g, b, a = GetButtonIcon2Color(buttonID)
		local glowfactor = C.GetButtonIcon2GlowFactor(buttonID)
		if colorMode == "inverse" then
			r, g, b = widgetSystem.invertColor(r, g, b)
		elseif colorMode == "gray" then
			local color = Color["button_text_inactive"]
			r, g, b = color.r, color.g, color.b
			glowfactor = color.glow
		-- else, it's "normal" and uses the original color
		end
		local material = getElement("Icon2.Icon2.Imaterial_icon2", buttonElement.element)
		SetIcon(getElement("icon2", material), buttonElement.icon2ID, r, g, b, false, buttonElement.icon2Width, buttonElement.icon2Height)
		setAttribute(material, "opacity", a)
		setAttribute(material, "glowfactor", glowfactor)
	end

	local r, g, b, a = GetButtonTextColor(buttonID)
	local glowfactor = C.GetButtonTextGlowFactor(buttonID)
	if colorMode == "inverse" then
		r, g, b = widgetSystem.invertColor(r, g, b)
	elseif colorMode == "gray" then
		local color = Color["button_text_inactive"]
		r, g, b = color.r, color.g, color.b
		glowfactor = color.glow
	-- else, it's "normal" and uses the original color
	end
	local textelement = getElement("Text", buttonElement.element)
	setAttribute(textelement, "textcolor.r", r)
	setAttribute(textelement, "textcolor.g", g)
	setAttribute(textelement, "textcolor.b", b)
	setAttribute(textelement, "opacity", a)
	setAttribute(textelement, "glowfactor", glowfactor)

	local textinfo = ffi.new("TextInfo")
	local hastext2 = C.GetButtonText2Details(buttonID, textinfo)
	if hastext2 then
		local r, g, b, a = textinfo.color.red, textinfo.color.green, textinfo.color.blue, textinfo.color.alpha
		local glowfactor = textinfo.glowfactor
		if colorMode == "inverse" then
			r, g, b = widgetSystem.invertColor(r, g, b)
		elseif colorMode == "gray" then
			local color = Color["button_text_inactive"]
			r, g, b = color.r, color.g, color.b
			glowfactor = color.glow
		-- else, it's "normal" and uses the original color
		end
		local textelement = getElement("Text2", buttonElement.element)
		setAttribute(textelement, "textcolor.r", r)
		setAttribute(textelement, "textcolor.g", g)
		setAttribute(textelement, "textcolor.b", b)
		setAttribute(textelement, "opacity", a)
		setAttribute(textelement, "glowfactor", glowfactor)
	end

	buttonElement.highlightcolor = Color["button_highlight_default"]
	local color = ffi.new("Color")
	if C.GetButtonHighlightColor(buttonID, color) then
		buttonElement.highlightcolor = {
			["r"] = color.red,
			["g"] = color.green,
			["b"] = color.blue,
			["a"] = color.alpha,
			["glow"] = C.GetButtonHighlightColorGlowFactor(buttonID)
		}
	end
	local material = getElement("value.mat_value", buttonElement.element)
	SetDiffuseColor(material, buttonElement.highlightcolor.r, buttonElement.highlightcolor.g, buttonElement.highlightcolor.b)
	setAttribute(material, "opacity", buttonElement.highlightcolor.a)
	setAttribute(material, "glowfactor", buttonElement.highlightcolor.glow or 0)
end

function widgetSystem.updateButtonState(buttonID, buttonElement)
	local stateEntry = buttonElement.buttonState
	local targetSlide
	-- only activate the arrows, if the button is actually active
	if buttonElement.active then
		if stateEntry.mouseClick or stateEntry.keyboardPress then
			targetSlide = "click"
		elseif stateEntry.mouseOver or stateEntry.keyboard then
			targetSlide = "highlight"
			stateEntry.highlight = true
		else
			if stateEntry.highlight then
				targetSlide = "highlightfade"
			else
				targetSlide = "normal"
			end
			stateEntry.highlight = nil
		end
	else
		targetSlide = "unselect"
	end

	-- if active state changes, or on first activation, fire initial or finishing states to ensure consistent event order
	if buttonElement.previouslyActive ~= buttonElement.active then
		if buttonElement.previouslyActive then
			-- button has become inactive
			if stateEntry.mouseOver then
				CallWidgetEventScripts(buttonID, "onButtonMouseOut")
			end
			if targetSlide == "click" then
				CallWidgetEventScripts(buttonID, "onButtonUp")
			end
		else
			-- button has become active
			if stateEntry.mouseOver then
				CallWidgetEventScripts(buttonID, "onButtonMouseOver")
			end
			if stateEntry.keyboard then
				CallWidgetEventScripts(buttonID, "onButtonSelect")
			end
			if targetSlide == "click" then
				CallWidgetEventScripts(buttonID, "onButtonDown")
			end
		end
		buttonElement.previouslyActive = buttonElement.active
	end

	-- #StefanMed - store the button state, so we only need to change the slide, if the current one isn't up-to-date already
	-- Note: We must update the slide always, since we could schedule two slide-updates within a single frame. Example:
	-- highlight button first:
	--    curSlide reports "normal" ->
	--    goToSlide() schedules highlight change
	-- normal state change
	--    curSlide reports "normal" ->
	--    slide change would be missing
	-- This caused XT-2632
	goToSlide(buttonElement.element, targetSlide)

	local colorMode = "normal"
	if targetSlide == "unselect" then
		colorMode = "gray"
	elseif targetSlide == "click" then
		--colorMode = "inverse"
	end
	widgetSystem.updateButtonColor(buttonID, buttonElement, colorMode)
end

function widgetSystem.updateCheckBox(checkboxID, checkboxElement)
	-- update checkbox color for active checkbox (inactive checkboxes have a fixed color and therefore can never change their initially set up color)
	local color = ffi.new("Color")
	if C.GetCheckBoxColor(checkboxID, color) then
		checkboxElement.color = {
			["r"] = color.red,
			["g"] = color.green,
			["b"] = color.blue,
			["a"] = color.alpha,
			["glow"] = C.GetCheckBoxGlowFactor(checkboxID)
		}
	end
	checkboxElement.symbolglowfactor = C.GetCheckBoxSymbolGlowFactor(checkboxID)

	checkboxElement.checked = C.IsCheckBoxChecked(checkboxID)
	widgetSystem.updateCheckBoxState(checkbox, checkboxElement)
end

function widgetSystem.updateCheckBoxColor(checkbox, checkboxElement, colorMode)
	-- border color
	if checkboxElement.active then
		local color = checkboxElement.color
		if colorMode == "highlight" then
			color = Color["checkbox_highlight"]
		end
		local material = getElement("background.Material753", checkboxElement.element)
		SetDiffuseColor(material, color.r, color.g, color.b)
		setAttribute(material, "opacity", color.a)
		setAttribute(material, "glowfactor", color.glow)
	end
	-- inside box color
	local color = Color["checkbox_background"]
	if checkboxElement.active and (colorMode == "highlight") then
		color = Color["checkbox_background_highlight"]
	end
	local material = getElement("background_black.Material753", checkboxElement.element)
	SetDiffuseColor(material, color.r, color.g, color.b)
	setAttribute(material, "opacity", color.a)
	-- symbol
	local material
	if checkboxElement.symbol == "circle" then
		material = getElement("circle.lso_circle.Material", checkboxElement.element)
	elseif checkboxElement.symbol == "arrow" then
		material = getElement("arrow.arrow._material_", checkboxElement.element)
	end
	local color = Color["checkbox_symbol_active"]
	if not checkboxElement.active then
		color = Color["checkbox_symbol_inactive"]
	end
	SetDiffuseColor(material, color.r, color.g, color.b)
	setAttribute(material, "opacity", color.a)
	setAttribute(material, "glowfactor", checkboxElement.symbolglowfactor)
end

function widgetSystem.updateCheckBoxState(checkbox, checkboxElement)
	local stateEntry = checkboxElement.checkboxState
	local targetSlide
	local colorMode = "normal"
	-- only activate the arrows, if the button is actually active
	if checkboxElement.active then
		if stateEntry.mouseOver or stateEntry.keyboard then
			colorMode = "highlight"
		end
		if checkboxElement.checked then
			targetSlide = "check"
		else
			targetSlide = "uncheck"
		end
	else
		if checkboxElement.checked then
			targetSlide = "unselectcheck"
		else
			targetSlide = "unselect"
		end
	end

	-- if active state changes, or on first activation, fire initial or finishing states to ensure consistent event order
	if checkboxElement.previouslyActive ~= checkboxElement.active then
		if checkboxElement.previouslyActive then
			-- checkbox has become inactive
			if stateEntry.mouseOver then
				CallWidgetEventScripts(checkbox, "onCheckBoxMouseOut")
			end
		else
			-- checkbox has become active
			if stateEntry.mouseOver then
				CallWidgetEventScripts(checkbox, "onCheckBoxMouseOver")
			end
			if stateEntry.keyboard then
				CallWidgetEventScripts(checkbox, "onCheckBoxSelect")
			end
		end
		checkboxElement.previouslyActive = checkboxElement.active
	end

	-- #StefanMed - store the checkbox state, so we only need to change the slide, if the current one isn't up-to-date already
	-- Note: We must update the slide always, since we could schedule two slide-updates within a single frame. Example:
	-- highlight button first:
	--    curSlide reports "normal" ->
	--    goToSlide() schedules highlight change
	-- normal state change
	--    curSlide reports "normal" ->
	--    slide change would be missing
	-- This caused XT-2632
	goToSlide(checkboxElement.element, targetSlide)

	widgetSystem.updateCheckBoxColor(checkbox, checkboxElement, colorMode)
end

function widgetSystem.setSceneState(state, value)
	private.sceneState[state] = value
	widgetSystem.updateSceneState()
end

function widgetSystem.updateSceneState()
	local targetSlide
	if private.sceneState.widgetsystem and private.sceneState.shapes then
		targetSlide = "both"
	elseif private.sceneState.miniwidgetsystem and private.sceneState.shapes then
		widgetSystem.switchFromMiniWidgetSystem()
		private.sceneState.widgetsystem = true
		targetSlide = "both"
	elseif private.sceneState.miniwidgetsystem and private.sceneState.widgetsystem then
		widgetSystem.switchFromMiniWidgetSystem()
		targetSlide = "widgets"
	elseif private.sceneState.miniwidgetsystem then
		targetSlide = "miniwidgets"
	elseif private.sceneState.widgetsystem then
		targetSlide = "widgets"
	elseif private.sceneState.shapes then
		targetSlide = "shapes"
	else
		targetSlide = "inactive"
	end

	if (targetSlide ~= "inactive") and private.sceneState.starteffect then
		targetSlide = "start" .. targetSlide
	end

	goToSlide(private.scene, targetSlide)
end

function widgetSystem.switchFromMiniWidgetSystem()
	local frameID = private.element.miniWidgetSystem.frames[1].frame
	private.miniWidgetSystemUsed = false
	private.sceneState.miniwidgetsystem = false
	if frameID then
		-- we have to clean up here, so pending frame close events do not try to clean up frames in the deactivated mini-widgetsystem
		widgetSystem.removeFromAssociationList(private.element.miniWidgetSystem.frames[1])
		table.insert(private.pendingFrames, frameID)
	end
end

function widgetSystem.switchToMiniWidgetSystem()
	local frameIDs = {}
	for layer, frameElement in ipairs(private.frames) do
		if frameElement.frame then
			table.insert(frameIDs, frameElement.frame)
		end
	end
	if (#private.pendingFrames + #frameIDs) <= 1 then
		private.miniWidgetSystemUsed = true
		private.sceneState.widgetsystem = false
		if frameIDs[1] then
			table.insert(private.pendingFrames, frameIDs[1])
		end
	elseif (#private.pendingFrames == 1) and (#frameIDs == 1) then
		-- if we have an active frame and a pending frame, check whether they would replace each other (see widgetSystem.updateFrame())
		-- if so, allow miniwidgetsystem
		local frameLayer = GetFrameLayer(private.pendingFrames[1])
		local frameElement = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames[1] or private.frames[frameLayer]
		if frameElement and (frameElement.frame == frameIDs[1]) then
			private.miniWidgetSystemUsed = true
			private.sceneState.widgetsystem = false
		end
	end
end

function widgetSystem.toggleCheckBox(checkboxID, checkboxElement)
	checkboxElement.checked = not checkboxElement.checked
	C.SetCheckBoxChecked2(checkboxID, checkboxElement.checked, false)

	widgetSystem.updateCheckBoxState(checkboxID, checkboxElement)
end

function widgetSystem.updateBoxText(boxtextID, boxtextElement)
	-- textDetails
	local buf = ffi.new("TextInfo")
	if C.GetBoxTextInfo(boxtextID, buf) then
		boxtextElement.textDetails.text = ffi.string(buf.text)
		boxtextElement.textDetails.color = {}
		boxtextElement.textDetails.color.red = buf.color.red
		boxtextElement.textDetails.color.green = buf.color.green
		boxtextElement.textDetails.color.blue = buf.color.blue
		boxtextElement.textDetails.color.alpha = buf.color.alpha
		boxtextElement.textDetails.glowfactor = buf.glowfactor
	end

	local textwidth = GetSize(boxtextID)	
	local textelement = getElement("Text", boxtextElement.element.mainElement)
	setAttribute(textelement, "textstring", boxtextElement.textDetails.text)
	setAttribute(textelement, "textcolor.r", boxtextElement.textDetails.color.red)
	setAttribute(textelement, "textcolor.g", boxtextElement.textDetails.color.green)
	setAttribute(textelement, "textcolor.b", boxtextElement.textDetails.color.blue)
	setAttribute(textelement, "opacity", boxtextElement.textDetails.color.alpha)
	setAttribute(textelement, "glowfactor", boxtextElement.textDetails.glowfactor)
	setAttribute(textelement, "boxwidth", textwidth / config.nativePresentationWidth)

	-- box color
	local color = ffi.new("Color")
	if C.GetBoxTextBoxColor(boxtextID, color) then
		for _, element in ipairs(config.boxtext.borderElements) do
			local anarkElement = getElement(element, boxtextElement.element.mainElement)
			local material = getElement("Material753", anarkElement)
			local alpha = color.alpha
			if (element == "border_left") and boxtextElement.leftHidden then
				alpha = 0
			elseif (element == "border_right") and boxtextElement.rightHidden then
				alpha = 0
			end
			SetDiffuseColor(material, color.red, color.green, color.blue)
			setAttribute(anarkElement, "opacity", alpha)
		end
	end
end

function widgetSystem.updateDropDown(dropdownID, dropdownElement)
	local textelement = getElement("Text", dropdownElement.element.mainElement)
	local text = ""
	if dropdownElement.textActive then
		if dropdownElement.textDetails.textOverride ~= "" then
			text = dropdownElement.textDetails.textOverride
		else
			if dropdownElement.curOption.deleted then
				text = "---"
			else
				text = dropdownElement.curOption.text or "---"
			end
		end

		if dropdownElement.curOption.font and (dropdownElement.curOption.font ~= "") then
			setAttribute(textelement, "font", dropdownElement.curOption.font)
		else
			setAttribute(textelement, "font", dropdownElement.textDetails.fontname)
		end
	end

	local arrowwidth
	if dropdownElement.textDetails.alignment == "center" then
		-- TODO Florian: check for next project
		-- For X4 we accepted text overlapping the arrow in this case and would probably break many usecases if we enforce a width restriction now.
		-- Nevertheless we will stop text from extending outside the element
		arrowwidth = 0
	else
		arrowwidth = dropdownElement.arrowHeight
	end
	text = TruncateText(text, dropdownElement.textDetails.fontname, dropdownElement.textDetails.fontsize, dropdownElement.width - 2 * config.dropdown.optionSpacing - arrowwidth)

	setAttribute(textelement, "textstring", text)

	local text2element = getElement("Text2", dropdownElement.element.mainElement)
	local text2 = ""
	if dropdownElement.text2Active then
		if dropdownElement.text2Details.textOverride ~= "" then
			text2 = dropdownElement.text2Details.textOverride
		else
			if dropdownElement.curOption.deleted then
				text2 = "---"
			else
				text2 = dropdownElement.curOption.text2 or "---"
			end
		end

		if dropdownElement.curOption.font and (dropdownElement.curOption.font ~= "") then
			setAttribute(text2element, "font", dropdownElement.curOption.font)
		else
			setAttribute(text2element, "font", dropdownElement.text2Details.fontname)
		end
	end
	setAttribute(text2element, "textstring", text2)

	-- set icon
	if dropdownElement.iconActive then
		if next(dropdownElement.curOption) then
			local iconElement = getElement("Icon", dropdownElement.element.mainElement)
			if dropdownElement.curOption.icon ~= "" then
				goToSlide(iconElement, "active")
				local material = getElement("Icon.Icon.Material423", dropdownElement.element.mainElement)
				SetIcon(getElement("Icon", material), dropdownElement.curOption.icon, dropdownElement.iconDetails.color.red, dropdownElement.iconDetails.color.green, dropdownElement.iconDetails.color.blue, false, dropdownElement.iconDetails.width, dropdownElement.iconDetails.height)
				setAttribute(material, "opacity", dropdownElement.iconDetails.color.alpha)
				setAttribute(material, "glowfactor", dropdownElement.iconDetails.glowfactor)
			else
				goToSlide(iconElement, "inactive")
			end
		end
	end
end

function widgetSystem.updateDropDownColor(dropdownID, dropdownElement, colorMode)
	if dropdownElement.iconActive then
		if dropdownElement.curOption.icon ~= "" then
			-- icon button
			local r, g, b, a = dropdownElement.iconDetails.color.red, dropdownElement.iconDetails.color.green, dropdownElement.iconDetails.color.blue, dropdownElement.iconDetails.color.alpha
			if colorMode == "inverse" then
				r, g, b = widgetSystem.invertColor(r, g, b)
			elseif colorMode == "gray" then
				local color = Color["dropdown_text_inactive"]
				r, g, b = color.r, color.g, color.b
			-- else, it's "normal" and uses the original color
			end
			local material = getElement("Icon.Icon.Material423", dropdownElement.element.mainElement)
			SetDiffuseColor(material, r, g, b)
			setAttribute(material, "opacity", a)
			setAttribute(material, "glowfactor", dropdownElement.iconDetails.glowfactor)
		end
	end

	if dropdownElement.text2Active then
		local r, g, b, a = dropdownElement.text2Details.color.red, dropdownElement.text2Details.color.green, dropdownElement.text2Details.color.blue, dropdownElement.text2Details.color.alpha
		if colorMode == "inverse" then
			r, g, b = widgetSystem.invertColor(r, g, b)
		elseif colorMode == "gray" then
			local color = Color["dropdown_text_inactive"]
			r, g, b = color.r, color.g, color.b
		-- else, it's "normal" and uses the original color
		end
		local text2element = getElement("Text2", dropdownElement.element.mainElement)
		setAttribute(text2element, "textcolor.r", r)
		setAttribute(text2element, "textcolor.g", g)
		setAttribute(text2element, "textcolor.b", b)
		setAttribute(text2element, "opacity", a)
		setAttribute(text2element, "glowfactor", dropdownElement.text2Details.glowfactor)
	end
	
	local r, g, b, a = 255, 255, 255, 100
	if dropdownElement.textActive then
		r, g, b, a = dropdownElement.textDetails.color.red, dropdownElement.textDetails.color.green, dropdownElement.textDetails.color.blue, dropdownElement.textDetails.color.alpha
		if colorMode == "inverse" then
			r, g, b = widgetSystem.invertColor(r, g, b)
		elseif colorMode == "gray" then
			local color = Color["dropdown_text_inactive"]
			r, g, b = color.r, color.g, color.b
		-- else, it's "normal" and uses the original color
		end
		local textelement = getElement("Text", dropdownElement.element.mainElement)
		setAttribute(textelement, "textcolor.r", r)
		setAttribute(textelement, "textcolor.g", g)
		setAttribute(textelement, "textcolor.b", b)
		setAttribute(textelement, "opacity", a)
		setAttribute(textelement, "glowfactor", dropdownElement.textDetails.glowfactor)
	end

	if colorMode == "inverse" then
		r, g, b = widgetSystem.invertColor(r, g, b)
	elseif colorMode == "gray" then
		local color = Color["dropdown_text_inactive"]
		r, g, b = color.r, color.g, color.b
	-- else, it's "normal" and uses the original color
	end
	local material = getElement("Arrow.arrow.arrow", dropdownElement.element.mainElement)
	SetDiffuseColor(material, r, g, b)
	setAttribute(material, "opacity", a)
	setAttribute(material, "glowfactor", dropdownElement.textDetails.glowfactor)

	if IsValidWidgetElement(dropdownID) then
		local color = ffi.new("Color")
		if C.GetDropDownHighlightColor(dropdownID, color) then
			dropdownElement.highlightcolor = {
				["r"] = color.red,
				["g"] = color.green,
				["b"] = color.blue,
				["a"] = color.alpha,
				["glow"] = C.GetDropDownHighlightGlowFactor(dropdownID),
			}

			local material = getElement("value.Material753", dropdownElement.element.mainElement)
			SetDiffuseColor(material, dropdownElement.highlightcolor.r, dropdownElement.highlightcolor.g, dropdownElement.highlightcolor.b)
			setAttribute(material, "opacity", dropdownElement.highlightcolor.a)
			setAttribute(material, "glowfactor", dropdownElement.highlightcolor.glow)
		end

		-- border elements
		for _, element in ipairs(config.dropdown.borderElements) do
			local anarkElement = getElement(element, dropdownElement.element.mainElement)

			if dropdownElement.active then
				local color = dropdownElement.color
				if colorMode == "highlight" then
					color = dropdownElement.highlightcolor
				end
				local material = getElement("Material753", anarkElement)
				SetDiffuseColor(material, color.r, color.g, color.b)
				setAttribute(material, "glowfactor", color.glow)
			end
		end
	end
end

function widgetSystem.updateDropDownState(dropdownID, dropdownElement)
	local stateEntry = dropdownElement.dropdownState
	local targetSlide
	if dropdownElement.active then
		if stateEntry.mouseClick or stateEntry.keyboardPress then
			targetSlide = "click"
		elseif stateEntry.mouseOver or stateEntry.keyboard then
			targetSlide = "highlight"
		else
			targetSlide = "normal"
		end
	else
		targetSlide = "unselect"
	end

	-- if active state changes, or on first activation, fire initial or finishing states to ensure consistent event order
	if dropdownElement.previouslyActive ~= dropdownElement.active then
		if dropdownElement.previouslyActive then
			-- dropdown has become inactive
			if stateEntry.mouseOver then
				CallWidgetEventScripts(dropdownID, "onDropDownMouseOut")
			end
		else
			-- dropdown has become active
			if stateEntry.mouseOver then
				CallWidgetEventScripts(dropdownID, "onDropDownMouseOver")
			end
			if stateEntry.keyboard then
				CallWidgetEventScripts(dropdownID, "onDropDownSelect")
			end
		end
		dropdownElement.previouslyActive = dropdownElement.active
	end

	-- #StefanMed - store the button state, so we only need to change the slide, if the current one isn't up-to-date already
	-- Note: We must update the slide always, since we could schedule two slide-updates within a single frame. Example:
	-- highlight button first:
	--    curSlide reports "normal" ->
	--    goToSlide() schedules highlight change
	-- normal state change
	--    curSlide reports "normal" ->
	--    slide change would be missing
	-- This caused XT-2632
	goToSlide(dropdownElement.element.mainElement, targetSlide)

	local colorMode = "normal"
	if targetSlide == "unselect" then
		colorMode = "gray"
	elseif targetSlide == "click" then
		colorMode = "inverse"
	elseif targetSlide == "highlight" then
		colorMode = "highlight"
	end
	widgetSystem.updateDropDownColor(dropdownID, dropdownElement, colorMode)
end

function widgetSystem.truncateDropDownOptionText(dropdownElement, option)
	local removeoptionwidth = 0
	if option.displayRemoveOption then
		if dropdownElement.textDetails.alignment == "center" then
			removeoptionwidth = 2 * (config.dropdown.removeOptionSize + config.dropdown.optionSpacing)
		else
			removeoptionwidth = config.dropdown.removeOptionSize + config.dropdown.optionSpacing
		end
	end
	local arrowwidth = 0
	if dropdownElement.textDetails.alignment == "left" then
		-- arrowwidth offset is added to options, too, when left aligned
		arrowwidth = dropdownElement.arrowHeight
	end
	return TruncateText(option.text, (option.font ~= "") and option.font or dropdownElement.textDetails.fontname, dropdownElement.textDetails.fontsize, dropdownElement.actualWidth - 2 * config.dropdown.optionSpacing - arrowwidth - removeoptionwidth)
end

function widgetSystem.updateDropDownOptions(frameElement, dropdownID, dropdownElement, topOption, force)
	if not dropdownElement.optionsshown then
		return
	end
	
	topOption = math.max(1, math.min(topOption or 1, #dropdownElement.options - dropdownElement.noofVisibleOptions + 1))
	if (not force) and (topOption == dropdownElement.topOption) then
		return
	end
	dropdownElement.topOption = topOption

	if dropdownElement.scrollBar then
		widgetSystem.updateVerticalScrollBar(dropdownElement.element.scrollBar, (dropdownElement.topOption - 1) / (#dropdownElement.options - dropdownElement.noofVisibleOptions))
	end

	-- clear all stored elements to make sure they are up-to-date
	for i, option in ipairs(dropdownElement.options) do
		widgetSystem.removeHelpOverlayID(dropdownElement.optionOverlays[i].id)		
		option.element = nil
	end

	for i = dropdownElement.topOption, dropdownElement.noofVisibleOptions + dropdownElement.topOption - 1 do
		local option = dropdownElement.options[i]
		local optionElement = dropdownElement.element.optionElements[i - dropdownElement.topOption + 1]
		option.element = optionElement

		-- color
		local material = getElement("background.Material753", optionElement)
		if option.active then
			local color = Color["dropdown_option_background"]
			SetDiffuseColor(material, color.r, color.g, color.b)
			setAttribute(material, "opacity", color.a)
			setAttribute(material, "glowfactor", color.glow)
		else
			local color = Color["dropdown_option_background_inactive"]
			SetDiffuseColor(material, color.r, color.g, color.b)
			setAttribute(material, "opacity", color.a)
			setAttribute(material, "glowfactor", color.glow)
		end

		-- text
		local textelement = getElement("Text", optionElement)
		if dropdownElement.textActive then
			local text = widgetSystem.truncateDropDownOptionText(dropdownElement, option)
			option.truncatedtext = text

			local color = dropdownElement.textDetails.color
			if option.deleted then
				text = "---"
				local deletedcolor = Color["dropdown_option_deleted"]
				color = { red = deletedcolor.r, green = deletedcolor.g, blue = deletedcolor.b, alpha = deletedcolor.a }
			elseif not option.active then
				local inactivecolor = Color["dropdown_option_text_inactive"]
				color = { red = inactivecolor.r, green = inactivecolor.g, blue = inactivecolor.b, alpha = inactivecolor.a }
			elseif option.hasOverrideColor then
				color = option.overrideColor
			end
			setAttribute(textelement, "textstring", text)
			setAttribute(textelement, "textcolor.r", color.red)
			setAttribute(textelement, "textcolor.g", color.green)
			setAttribute(textelement, "textcolor.b", color.blue)
			setAttribute(textelement, "opacity",     color.alpha)
			setAttribute(textelement, "glowfactor", dropdownElement.textDetails.glowfactor)

			if option.font ~= "" then
				setAttribute(textelement, "font", option.font)
			else
				setAttribute(textelement, "font", dropdownElement.textDetails.fontname)
			end
		else
			setAttribute(textelement, "textstring", "")
		end

		-- text2
		local text2element = getElement("Text2", optionElement)
		if dropdownElement.text2Active then
			local text2 = option.text2
			local color = dropdownElement.text2Details.color
			if option.deleted then
				text2 = "---"
				local deletedcolor = Color["dropdown_option_deleted"]
				color = { red = deletedcolor.r, green = deletedcolor.g, blue = deletedcolor.b, alpha = deletedcolor.a }
			elseif not option.active then
				local inactivecolor = Color["dropdown_option_text_inactive"]
				color = { red = inactivecolor.r, green = inactivecolor.g, blue = inactivecolor.b, alpha = inactivecolor.a }
			elseif option.hasOverrideColor then
				color = option.overrideColor
			end
			setAttribute(text2element, "textstring", text2)
			setAttribute(text2element, "textcolor.r", color.red)
			setAttribute(text2element, "textcolor.g", color.green)
			setAttribute(text2element, "textcolor.b", color.blue)
			setAttribute(text2element, "opacity",     color.alpha)
			setAttribute(text2element, "glowfactor", dropdownElement.text2Details.glowfactor)

			if option.font ~= "" then
				setAttribute(text2element, "font", option.font)
		else
				setAttribute(text2element, "font", dropdownElement.text2Details.fontname)
			end
		else
			setAttribute(text2element, "textstring", "")
		end

		-- icon
		if dropdownElement.iconActive then
			local iconElement = getElement("Icon", optionElement)
			if option.icon ~= "" then
				widgetSystem.setElementPosition(iconElement, dropdownElement.iconDetails.x - (dropdownElement.scrollBar and (config.texturesizes.table.scrollBar.width / 2) or 0), dropdownElement.iconDetails.y)
				goToSlide(iconElement, "active")
				material = getElement("Icon.Material423", iconElement)
				local color = dropdownElement.iconDetails.color
				if option.hasOverrideColor then
					color = option.overrideColor
				end
				SetIcon(getElement("Icon", material), option.icon, color.red, color.green, color.blue, false, dropdownElement.iconDetails.width, dropdownElement.iconDetails.height)
				setAttribute(material, "opacity", dropdownElement.iconDetails.color.alpha)
				setAttribute(material, "glowfactor", dropdownElement.iconDetails.glowfactor)
			else
				goToSlide(iconElement, "inactive")
			end
		end

		-- removeOption
		local removeOptionElement = getElement("removeOption", optionElement)
		if option.displayRemoveOption and (not option.deleted) then
			widgetSystem.setElementPosition(removeOptionElement, dropdownElement.actualWidth / 2 - config.dropdown.removeOptionSize - config.dropdown.optionSpacing)
			goToSlide(removeOptionElement, "normal")
			widgetSystem.setDropDownRemoveOptionColor(dropdownElement, removeOptionElement, "normal")
		else
			goToSlide(removeOptionElement, "inactive")
		end
		
		local x = dropdownElement.offsetx + (dropdownElement.actualWidth - dropdownElement.width) / 2
		local y = dropdownElement.offsety + (dropdownElement.flipped and (dropdownElement.noofVisibleOptions - (i - dropdownElement.topOption)) or -(i - dropdownElement.topOption + 1)) * (dropdownElement.height + config.dropdown.optionSpacing)
		widgetSystem.addHelpOverlay(frameElement, dropdownID, x - dropdownElement.actualWidth / 2, y + dropdownElement.height / 2, dropdownElement.actualWidth, dropdownElement.height, false, false, dropdownElement.optionOverlays[i])
	end
end

function widgetSystem.showDropDownOptions(frameElement, dropdownID, dropdownElement)
	if dropdownElement.optionsshown then
		return
	end

	if #dropdownElement.options == 0 then
		return
	end

	if private.activeDropDown ~= nil then
		widgetSystem.hideDropDownOptions(private.activeDropDown.widgetID, private.activeDropDown.element)
	end

	local tableElement, tableID, row, col = widgetSystem.getTableElementByAnarkTableCellElement("dropdown", dropdownElement.element.mainElement)
	local wasHighlighted = false
	if row == tableElement.highlightedBorderRow then
		wasHighlighted = true
		widgetSystem.removeHighlightBorderTableRow(tableElement)
	end

	local arrowElement = getElement("Arrow", dropdownElement.element.mainElement)
	widgetSystem.setElementRotation(arrowElement, math.rad(0))

	dropdownElement.noofVisibleOptions = #dropdownElement.options
	dropdownElement.fullHeight = ((dropdownElement.noofVisibleOptions + 1) * (dropdownElement.height + config.dropdown.optionSpacing) - config.dropdown.optionSpacing)

	dropdownElement.scrollBar = false
	local actualwidth = dropdownElement.optionwidth
	local actualmaxheight = (dropdownElement.optionheight ~= 0) and math.min(private.height / 2 + dropdownElement.offsety, dropdownElement.optionheight) or (private.height / 2 + dropdownElement.offsety)
	dropdownElement.flipped = false
	if actualmaxheight < 3 * (dropdownElement.height + config.dropdown.optionSpacing) then
		dropdownElement.flipped = true
		actualmaxheight = (dropdownElement.optionheight ~= 0) and math.min(private.height / 2 - dropdownElement.offsety, dropdownElement.optionheight) or (private.height / 2 - dropdownElement.offsety)
	end
	if actualmaxheight < dropdownElement.fullHeight then
		dropdownElement.noofVisibleOptions = math.floor(actualmaxheight / (dropdownElement.height + config.dropdown.optionSpacing)) - 1
		dropdownElement.fullHeight = ((dropdownElement.noofVisibleOptions + 1) * (dropdownElement.height + config.dropdown.optionSpacing) - config.dropdown.optionSpacing)

		dropdownElement.scrollBar = true
		actualwidth = actualwidth - config.texturesizes.table.scrollBar.width - config.table.bordersize
	end
	dropdownElement.actualWidth = actualwidth
	if dropdownElement.noofVisibleOptions > config.dropdown.maxVisibleOptionsPerElement then
		dropdownElement.noofVisibleOptions = config.dropdown.maxVisibleOptionsPerElement
		dropdownElement.fullHeight = ((dropdownElement.noofVisibleOptions + 1) * (dropdownElement.height + config.dropdown.optionSpacing) - config.dropdown.optionSpacing)

		if not dropdownElement.scrollBar then
			actualwidth = actualwidth - config.texturesizes.table.scrollBar.width - config.table.bordersize
		end
		dropdownElement.scrollBar = true
	end
	dropdownElement.actualWidth = actualwidth

	-- mousepick
	local mousepickElement = getElement("mousepick", dropdownElement.element.mainElement)
	widgetSystem.setElementPosition(mousepickElement, (dropdownElement.optionwidth - dropdownElement.width) / 2, (dropdownElement.flipped and 1 or -1) * dropdownElement.noofVisibleOptions * (dropdownElement.height + config.dropdown.optionSpacing) / 2, (dropdownElement.width % 2 ~= 0), (dropdownElement.height % 2 ~= 0))
	widgetSystem.setElementScale(mousepickElement, math.max(dropdownElement.width, dropdownElement.optionwidth) / 100, dropdownElement.fullHeight / 100)
	setAttribute(mousepickElement, "position.z", -0.040)

	-- background
	local backgroundElement = getElement("options_bg", dropdownElement.element.mainElement)
	widgetSystem.setElementPosition(backgroundElement, (dropdownElement.optionwidth - dropdownElement.width) / 2, ((dropdownElement.flipped and 1 or -1) * (dropdownElement.noofVisibleOptions + 1) * (dropdownElement.height + config.dropdown.optionSpacing) + (dropdownElement.flipped and 0 or config.dropdown.optionSpacing)) / 2, (dropdownElement.width % 2 ~= 0), (dropdownElement.height % 2 ~= 0))
	widgetSystem.setElementScale(backgroundElement, math.max(dropdownElement.width, dropdownElement.optionwidth) / 100, (dropdownElement.fullHeight - dropdownElement.height) / 100)
	setAttribute(backgroundElement, "position.z", -0.035)
	setAttribute(backgroundElement, "opacity", dropdownElement.optioncolor and dropdownElement.optioncolor.a or 100)

	-- border elements
	local height = dropdownElement.fullHeight - dropdownElement.height + config.dropdown.borderSize
	local sideOffsetY = (dropdownElement.flipped and 1 or -1) * (dropdownElement.noofVisibleOptions +   1) * (dropdownElement.height + config.dropdown.optionSpacing) / 2 - (config.dropdown.borderSize - config.dropdown.optionSpacing) / 2
	local downOffsetY = (dropdownElement.flipped and 1 or -1) * (dropdownElement.noofVisibleOptions + 0.5) * (dropdownElement.height + config.dropdown.optionSpacing)     - (config.dropdown.borderSize - config.dropdown.optionSpacing) / 2

	-- left
	local leftBorderElement = getElement("border_left", dropdownElement.element.mainElement)
	widgetSystem.setElementPosition(leftBorderElement, -(dropdownElement.width - config.dropdown.borderSize) / 2, sideOffsetY, (dropdownElement.width % 2 ~= 0), (dropdownElement.height % 2 ~= 0))
	widgetSystem.setElementScale(leftBorderElement, config.dropdown.borderSize / 100, height / 100)
	setAttribute(leftBorderElement, "position.z", -0.05)
	setAttribute(leftBorderElement, "opacity", 100)

	-- right
	local rightBorderElement = getElement("border_right", dropdownElement.element.mainElement)
	widgetSystem.setElementPosition(rightBorderElement, (dropdownElement.width - config.dropdown.borderSize) / 2 + (dropdownElement.optionwidth - dropdownElement.width), sideOffsetY, (dropdownElement.width % 2 ~= 0), (dropdownElement.height % 2 ~= 0))
	widgetSystem.setElementScale(rightBorderElement, config.dropdown.borderSize / 100, height / 100)
	setAttribute(rightBorderElement, "position.z", -0.05)
	setAttribute(rightBorderElement, "opacity", 100)

	-- down
	local downBorderElement = getElement("border_down", dropdownElement.element.mainElement)
	widgetSystem.setElementPosition(downBorderElement, (dropdownElement.optionwidth - dropdownElement.width) / 2, downOffsetY, (dropdownElement.width % 2 ~= 0), (dropdownElement.height % 2 ~= 0))
	widgetSystem.setElementScale(downBorderElement, (math.max(dropdownElement.width, dropdownElement.optionwidth) - 2 * config.dropdown.borderSize) / 100, config.dropdown.borderSize / 100)
	setAttribute(downBorderElement, "position.z", -0.05)
	setAttribute(downBorderElement, "opacity", 100)

	local selected = 0
	for i, option in ipairs(dropdownElement.options) do
		if option.id == dropdownElement.curOption.id then
			selected = i
			break
		end
	end

	topOption = 1
	if selected >= dropdownElement.noofVisibleOptions then
		-- update topoption if selected is outside the visible options
		topOption = math.min(selected + 2 - dropdownElement.noofVisibleOptions, #dropdownElement.options - dropdownElement.noofVisibleOptions + 1)
	end
	dropdownElement.topOption = topOption

	if dropdownElement.scrollBar then
		local visibleOptionsHeight = dropdownElement.fullHeight - dropdownElement.height - 2 * config.dropdown.optionSpacing
		local fullOptionsHeight = #dropdownElement.options * (dropdownElement.height + config.dropdown.optionSpacing) - config.dropdown.optionSpacing
		widgetSystem.setUpVerticalScrollBar(dropdownElement.element.scrollBar, dropdownElement.optionwidth + (-dropdownElement.width + config.table.bordersize) / 2 - config.texturesizes.table.scrollBar.width - config.dropdown.borderSize, -dropdownElement.height / 2 - config.dropdown.optionSpacing, visibleOptionsHeight, visibleOptionsHeight, fullOptionsHeight)

		widgetSystem.updateVerticalScrollBar(dropdownElement.element.scrollBar, (dropdownElement.topOption - 1) / (#dropdownElement.options - dropdownElement.noofVisibleOptions))
	end

	for i = dropdownElement.topOption, dropdownElement.noofVisibleOptions + dropdownElement.topOption - 1 do
		local option = dropdownElement.options[i]
		local optionElement = dropdownElement.element.optionElements[i - dropdownElement.topOption + 1]
		option.element = optionElement
		goToSlide(optionElement, "normal")

		-- position
		local x = dropdownElement.offsetx + (actualwidth - dropdownElement.width) / 2
		local y = dropdownElement.offsety + (dropdownElement.flipped and (dropdownElement.noofVisibleOptions - (i - dropdownElement.topOption)) or -(i - dropdownElement.topOption + 1)) * (dropdownElement.height + config.dropdown.optionSpacing)
		widgetSystem.setElementPosition(optionElement, x, y, (dropdownElement.width % 2 ~= 0), (dropdownElement.height % 2 ~= 0))

		-- scale
		widgetSystem.setElementScale(getElement("background", optionElement), actualwidth / 100, dropdownElement.height / 100)
		widgetSystem.setElementScale(getElement("value", optionElement), actualwidth / 100, dropdownElement.height / 100)

		-- color
		local material = getElement("background.Material753", optionElement)
		if option.active then
			local color = Color["dropdown_option_background"]
			SetDiffuseColor(material, color.r, color.g, color.b)
			setAttribute(material, "opacity", color.a)
			setAttribute(material, "glowfactor", color.glow)
		else
			local color = Color["dropdown_option_background_inactive"]
			SetDiffuseColor(material, color.r, color.g, color.b)
			setAttribute(material, "opacity", color.a)
			setAttribute(material, "glowfactor", color.glow)
		end

		local material = getElement("value.Material377", optionElement)
		SetDiffuseColor(material, dropdownElement.highlightcolor.r, dropdownElement.highlightcolor.g, dropdownElement.highlightcolor.b)
		setAttribute(material, "opacity", dropdownElement.highlightcolor.a)
		setAttribute(material, "glowfactor", dropdownElement.highlightcolor.glow)

		-- text
		local textelement = getElement("Text", optionElement)
		if dropdownElement.textActive then
			-- calculate horizontal offset for proper alignment
			local textXOffset = dropdownElement.textDetails.x
			local textYOffset = dropdownElement.textDetails.y
			if dropdownElement.textDetails.alignment == "left" then
				textXOffset = textXOffset + (dropdownElement.width - actualwidth) / 2
			elseif dropdownElement.textDetails.alignment == "center" then
				-- nothing to do
			else -- right
				textXOffset = textXOffset - (dropdownElement.width - actualwidth) / 2
			end

			widgetSystem.setElementPosition(textelement, textXOffset, textYOffset)
			setAttribute(textelement, "horzalign", widgetSystem.convertAlignment(dropdownElement.textDetails.alignment))
			setAttribute(textelement, "size", dropdownElement.textDetails.fontsize)

			local color = dropdownElement.textDetails.color
			if not option.active then
				local inactivecolor = Color["dropdown_option_text_inactive"]
				color = { red = inactivecolor.r, green = inactivecolor.g, blue = inactivecolor.b, alpha = inactivecolor.a }
			elseif option.hasOverrideColor then
				color = option.overrideColor
			end
			setAttribute(textelement, "textcolor.r", color.red)
			setAttribute(textelement, "textcolor.g", color.green)
			setAttribute(textelement, "textcolor.b", color.blue)
			setAttribute(textelement, "opacity", color.alpha)
			setAttribute(textelement, "glowfactor", dropdownElement.textDetails.glowfactor)

			if option.font ~= "" then
				setAttribute(textelement, "font", option.font)
			else
				setAttribute(textelement, "font", dropdownElement.textDetails.fontname)
			end

			local text = widgetSystem.truncateDropDownOptionText(dropdownElement, option)
			option.truncatedtext = text
			setAttribute(textelement, "textstring", text)
		else
			setAttribute(textelement, "textstring", "")
		end

		-- text2
		local text2element = getElement("Text2", optionElement)
		if dropdownElement.text2Active then
			-- calculate horizontal offset for proper alignment
			local textXOffset = dropdownElement.text2Details.x
			local textYOffset = dropdownElement.text2Details.y
			if dropdownElement.text2Details.alignment == "left" then
				textXOffset = textXOffset + (dropdownElement.width - actualwidth) / 2
			elseif dropdownElement.text2Details.alignment == "center" then
				-- nothing to do
			else -- right
				textXOffset = textXOffset - (dropdownElement.width - actualwidth) / 2
			end

			widgetSystem.setElementPosition(text2element, textXOffset, textYOffset)
			setAttribute(text2element, "horzalign", widgetSystem.convertAlignment(dropdownElement.text2Details.alignment))
			setAttribute(text2element, "size", dropdownElement.text2Details.fontsize)

			local color = dropdownElement.text2Details.color
			if not option.active then
				local inactivecolor = Color["dropdown_option_text_inactive"]
				color = { red = inactivecolor.r, green = inactivecolor.g, blue = inactivecolor.b, alpha = inactivecolor.a }
			elseif option.hasOverrideColor then
				color = option.overrideColor
			end
			setAttribute(text2element, "textcolor.r", color.red)
			setAttribute(text2element, "textcolor.g", color.green)
			setAttribute(text2element, "textcolor.b", color.blue)
			setAttribute(text2element, "opacity", color.alpha)
			setAttribute(text2element, "glowfactor", dropdownElement.text2Details.glowfactor)

			if option.font ~= "" then
				setAttribute(text2element, "font", option.font)
			else
				setAttribute(text2element, "font", dropdownElement.text2Details.fontname)
			end

			setAttribute(text2element, "textstring", option.text2)
		else
			setAttribute(text2element, "textstring", "")
		end

		-- icon
		if dropdownElement.iconActive then
			if option.icon ~= "" then
				local iconElement = getElement("Icon", optionElement)
				widgetSystem.setElementPosition(iconElement, dropdownElement.iconDetails.x - (dropdownElement.scrollBar and (config.texturesizes.table.scrollBar.width / 2) or 0), dropdownElement.iconDetails.y)
				goToSlide(iconElement, "active")
				material = getElement("Icon.Material423", iconElement)
				local color = dropdownElement.iconDetails.color
				if option.hasOverrideColor then
					color = option.overrideColor
				end
				SetIcon(getElement("Icon", material), option.icon, color.red, color.green, color.blue, false, dropdownElement.iconDetails.width, dropdownElement.iconDetails.height)
				setAttribute(material, "opacity", color.alpha)
				setAttribute(material, "glowfactor", dropdownElement.iconDetails.glowfactor)
			end
		end

		-- removeOption
		if option.displayRemoveOption then
			local removeOptionElement = getElement("removeOption", optionElement)
			widgetSystem.setElementPosition(removeOptionElement, actualwidth / 2 - config.dropdown.removeOptionSize - config.dropdown.optionSpacing)
			goToSlide(removeOptionElement, "normal")
			widgetSystem.setDropDownRemoveOptionColor(dropdownElement, removeOptionElement, "normal")
		end

		widgetSystem.addHelpOverlay(frameElement, dropdownID, x - actualwidth / 2, y + dropdownElement.height / 2, actualwidth, dropdownElement.height, false, false, dropdownElement.optionOverlays[i])
	end
	
	private.activeDropDown = {
		["widgetID"] = dropdownID,
		["element"] = dropdownElement,
		["selected"] = selected or 1,
		["highlighted"] = (selected or 1) - (dropdownElement.topOption or 1) + 1,
		["tableinfo"] = {
			["tableElement"] = tableElement,
			["tableID"] = tableID,
			["row"] = row,
			["col"] = col,
			["wasHighlighted"] = wasHighlighted,
		}
	}
	dropdownElement.optionsshown = true
	widgetSystem.updateDropDownOptionState(dropdownElement, 0)

	C.ActivateDirectKeyInput()

	CallWidgetEventScripts(dropdownID, "onDropDownActivated")
end

function widgetSystem.hideDropDownOptions(dropdownID, dropdownElement)
	if not dropdownElement.optionsshown then
		return
	end

	C.DeactivateDirectKeyInput()

	if private.activeDropDown then
		local tableinfo = private.activeDropDown.tableinfo
		if tableinfo.wasHighlighted then
			widgetSystem.highlightBorderTableRow(tableinfo.tableID, tableinfo.tableElement, tableinfo.row, tableinfo.col)
		end
	end

	local arrowElement = getElement("Arrow", dropdownElement.element.mainElement)
	widgetSystem.setElementRotation(arrowElement, math.rad(180))

	dropdownElement.flipped = nil
	dropdownElement.lastMousePos = nil
	dropdownElement.fullHeight = dropdownElement.height

	if dropdownID then
		widgetSystem.setMouseOverOverride(dropdownID)
	end

	-- mousepick
	local mousepickElement = getElement("mousepick", dropdownElement.element.mainElement)
	widgetSystem.setElementPosition(mousepickElement, 0, 0, (dropdownElement.width % 2 ~= 0), (dropdownElement.height % 2 ~= 0))
	widgetSystem.setElementScale(mousepickElement, dropdownElement.width / 100, dropdownElement.height / 100)
	setAttribute(mousepickElement, "position.z", -0.004)

	-- background
	local backgroundElement = getElement("options_bg", dropdownElement.element.mainElement)
	widgetSystem.setElementPosition(backgroundElement, 0, 0, (dropdownElement.width % 2 ~= 0), (dropdownElement.height % 2 ~= 0))
	widgetSystem.setElementScale(backgroundElement, dropdownElement.width / 100, dropdownElement.height / 100)
	setAttribute(backgroundElement, "position.z", 0.006)
	setAttribute(backgroundElement, "opacity", 0)

	-- border elements
	for _, element in ipairs(config.dropdown.borderElements) do
		local anarkElement = getElement(element, dropdownElement.element.mainElement)
		widgetSystem.setElementScale(anarkElement, config.dropdown.borderSize / 100, config.dropdown.borderSize / 100)	
		setAttribute(backgroundElement, "position.z", 0.006)
		setAttribute(anarkElement, "opacity", 0)
	end

	widgetSystem.hideVerticalScrollBar(dropdownElement.element.scrollBar)

	for i, optionElement in ipairs(dropdownElement.element.optionElements) do
		local removeOptionElement = getElement("removeOption", optionElement)
		goToSlide(getElement("Icon", optionElement), "inactive")
		goToSlide(removeOptionElement, "inactive")
		goToSlide(optionElement, "inactive")
		for _, entry in ipairs(dropdownElement.element.removeOptionState) do
			if entry.element == removeOptionElement then
				entry["mouseClick"] = false
				entry["mouseOver"]  = false
				entry["curColorMode"]   = "inactive"
			end
		end
	end

	for i = #dropdownElement.options, 1, -1 do
		dropdownElement.options[i].element = nil
		if dropdownElement.options[i].deleted then
			table.remove(dropdownElement.options, i)
		end

		widgetSystem.removeHelpOverlayID(dropdownElement.optionOverlays[i].id)
	end

	widgetSystem.stopDropDownScrollBarDrag(dropdownID, dropdownElement)
	private.activeDropDown = nil
	dropdownElement.topOption = nil
	dropdownElement.optionsshown = false
end

function widgetSystem.updateDropDownOption(dropdownElement)
	local dropdownID = widgetSystem.getWidgetIDByElementEntry(dropdownElement)
	if not IsValidWidgetElement(dropdownID) then
		return -- view might have already been changed
	end

	local x, y = widgetSystem.getDropDownMousePosition(dropdownID)

	if x == nil then
		return
	end

	-- check last mouse position
	local mindiff = 2
	if dropdownElement.lastMousePos and
	   (dropdownElement.lastMousePos.x > (x - mindiff)) and (dropdownElement.lastMousePos.x < (x + mindiff)) and
	   (dropdownElement.lastMousePos.y > (y - mindiff)) and (dropdownElement.lastMousePos.y < (y + mindiff))
	then
		return
	end
	dropdownElement.lastMousePos = { x = x, y = y }

	-- dismiss mouse position if using gamepad and mouse emulation is not active
	if (GetControllerInfo() == "gamepad") and (not C.IsMouseEmulationActive()) then
		return
	end

	local highlighted, remainder = math.modf(y / (dropdownElement.height + config.dropdown.optionSpacing))
	if dropdownElement.flipped then
		highlighted = highlighted + 1
		if highlighted > dropdownElement.noofVisibleOptions then
			highlighted = 0
		end
	else
		if remainder > (1 - config.dropdown.optionSpacing / (dropdownElement.height + config.dropdown.optionSpacing)) then
			highlighted = 0
		end
	end
	highlighted = math.max(0, math.min(#dropdownElement.options, highlighted))

	local oldhighlighted = private.activeDropDown.highlighted
	private.activeDropDown.highlighted = highlighted
	widgetSystem.updateDropDownOptionState(dropdownElement, oldhighlighted)

	local data
	if highlighted ~= 0 then
		data = widgetSystem.getDropDownOptionByOptionAnarkElement(dropdownElement, dropdownElement.element.optionElements[highlighted])
	end
	if data then
		local mouseovertext = ""
		if data[2] then
			mouseovertext = data[2]
		end
		if data[1] ~= "" then
			if mouseovertext ~= "" then
				mouseovertext = mouseovertext .. "\n\n"
			end
			mouseovertext = mouseovertext .. data[1]
		end

		widgetSystem.setMouseOverOverride(dropdownID, (mouseovertext ~= "") and mouseovertext or nil)
	else
		widgetSystem.setMouseOverOverride(dropdownID)
	end

	if (private.activeDropDown.highlighted > 0) and private.activeDropDown.highlighted ~= private.activeDropDown.selected then
		private.activeDropDown.selected = private.activeDropDown.highlighted + (dropdownElement.topOption or 1) - 1
	end
end

function widgetSystem.updateDropDownOptionState(dropdownElement, oldhighlighted)
	if private.activeDropDown.highlighted ~= oldhighlighted then
		if private.activeDropDown.highlighted ~= 0 then
			local highlightedoption = private.activeDropDown.highlighted + (dropdownElement.topOption or 1) - 1
			if dropdownElement.options[highlightedoption].active then
				goToSlide(dropdownElement.element.optionElements[private.activeDropDown.highlighted], "highlight")
			end
		end
		if oldhighlighted ~= 0 then
			local oldhighlightedoption = oldhighlighted + (dropdownElement.topOption or 1) - 1
			if dropdownElement.options[oldhighlightedoption].active then
				goToSlide(dropdownElement.element.optionElements[oldhighlighted], "normal")
			end
		end
	end
end

function widgetSystem.updateDropDownScrollBarPos(dropdownID, dropdownElement)
	local _, y = GetLocalMousePosition()
	if y == nil then
		return -- outside the widget frame
	end

	-- check whether the mouse cursor was moved by a relevant factor
	if dropdownElement.element.scrollBar.previousMousePos ~= nil and math.abs(dropdownElement.element.scrollBar.previousMousePos - y) < config.mouseScrollBarThreshold then
		return -- mouse hasn't been moved between previous and current call - no mouse change => nothing to do
	end
	
	-- Note: we must take into account whether the mouse was moved up or down here, since we actually do not perform pixel-exact scrolling of the slider.
	-- That means: The slider position always represents the current position of the table and we scroll the table already as if we'd have dragged the slider half way to the previous/next row.
	-- At that point the slider would jump and the drag position might be above/below the current mouse position. If we'd just compare the difference of the drag position the next time the mouse is moved up/down
	-- we could end up with incorrectly determining that we'd moved the bar down/up -> results in inversed scrollbar movement (was cause of XT-3967)
	local moveDown = dropdownElement.element.scrollBar.previousMousePos ~= nil and dropdownElement.element.scrollBar.previousMousePos > y

	dropdownElement.element.scrollBar.previousMousePos = y

	local newSliderPos = y - dropdownElement.element.scrollBar.dragOffset
	local curSliderPos = widgetSystem.getScrollBarSliderPosition(dropdownElement.element.scrollBar.element) + dropdownElement.offsety
	local valueDiff = newSliderPos - curSliderPos
	local pixelsInTableToScroll = dropdownElement.element.scrollBar.valuePerPixel * valueDiff

	local stepsToScroll = math.floor(pixelsInTableToScroll / (dropdownElement.height + config.dropdown.optionSpacing))

	if stepsToScroll > 0 then
		if not moveDown then
			widgetSystem.scrollUpDropDown(dropdownID, dropdownElement, stepsToScroll)
		end
	elseif stepsToScroll < 0 then
		if moveDown then
			widgetSystem.scrollDownDropDown(dropdownID, dropdownElement, -stepsToScroll)
		end
	end
end

function widgetSystem.moveDropDownSelection(dropdownID, dropdownElement, step)
	local oldselected = private.activeDropDown.selected

	local direction = (step >= 0) and 1 or -1
	local limit = (step >= 0) and #dropdownElement.options or 1
	local start = math.max(1, math.min(private.activeDropDown.selected + step, #dropdownElement.options))
	for newindex = start, limit, direction do
		if dropdownElement.options[newindex].active then
			private.activeDropDown.selected = newindex
			break
		end
	end
	private.activeDropDown.selected = math.max(1, math.min(#dropdownElement.options, private.activeDropDown.selected))
	if private.activeDropDown.selected == oldselected then
		-- nothing to do
		return
	end

	local _, _, frameElement = widgetSystem.getTableElementByAnarkTableCellElement("dropdown", dropdownElement.element.main)
	if (oldselected ~= #dropdownElement.options) and (private.activeDropDown.selected >= dropdownElement.topOption + dropdownElement.noofVisibleOptions - 1) then
		-- update topoption if new selected is outside the visible options
		widgetSystem.updateDropDownOptions(frameElement, dropdownID, dropdownElement, private.activeDropDown.selected + 2 - dropdownElement.noofVisibleOptions)
	elseif (oldselected ~= 1) and (oldselected ~= 2) and (private.activeDropDown.selected <= dropdownElement.topOption) then
		-- update topoption if new selected is outside the visible options
		widgetSystem.updateDropDownOptions(frameElement, dropdownID, dropdownElement, private.activeDropDown.selected - 1)
	end
	if private.activeDropDown.selected ~= private.activeDropDown.highlighted then
		local oldhighlighted = private.activeDropDown.highlighted
		private.activeDropDown.highlighted = private.activeDropDown.selected - (dropdownElement.topOption or 1) + 1
		widgetSystem.updateDropDownOptionState(dropdownElement, oldhighlighted)
	end

	if GetControllerInfo() == "gamepad" then
		C.DeactivateMouseEmulation()

		local offsetx = getAttribute(dropdownElement.element.optionElements[private.activeDropDown.selected - (dropdownElement.topOption or 1) + 1], "position.x")
		local offsety = getAttribute(dropdownElement.element.optionElements[private.activeDropDown.selected - (dropdownElement.topOption or 1) + 1], "position.y")

		C.SetMouseCursorPosition(offsetx, -offsety)
	end
end

function widgetSystem.activateEditBox(editboxID, cursorpos, shiftstartpos)
	local editboxentry = private.associationList[editboxID]
	if editboxentry == nil then
		return false, 1, "invalid editbox element"
	end

	local tableElement, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("editbox", editboxentry.element.element)
	local frameElement = widgetSystem.getFrameElementByTableElement(tableElement)

	widgetSystem.activateEditBoxInternal(frameElement, editboxID, editboxentry.element, cursorpos, shiftstartpos)
end

function widgetSystem.activateSliderCellInput(slidercellID)
	local slidercellentry = private.associationList[slidercellID]
	if slidercellentry == nil then
		return false, 1, "invalid slidercell element"
	end

	widgetSystem.activateSliderCellInputInternal(slidercellID, slidercellentry.element)

	local tableElement, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", slidercellentry.element.element.main)
	local frameElement = widgetSystem.getFrameElementByTableElement(tableElement)
	widgetSystem.setActiveFrame(frameElement)
	widgetSystem.setInteractiveElement(widgetID)
	widgetSystem.selectRow(widgetID, row, nil, nil, "user")
end

function widgetSystem.showMouseOverText(widgetID, ignorecount, posOverride)
	if (widgetID == nil) or (not IsValidWidgetElement(widgetID)) then
		return -- no widget, skip call
	end

	local text = ""
	local additionaltext = ffi.string(C.GetMouseOverTextAdditional(widgetID));
	if additionaltext ~= "" then
		text = additionaltext .. "\n" .. ffi.string(C.GetMouseOverText(widgetID))
	else
		text = ffi.string(C.GetMouseOverText(widgetID))
	end

	text = private.mouseOverOverrideText or text

	local count = 1
	if (private.mouseOverText ~= nil) and (private.mouseOverText.widgetID == widgetID) and (private.mouseOverText.text == text) then
		if not ignorecount then
			-- increase the counter
			private.mouseOverText.count = private.mouseOverText.count + 1
		end
		private.mouseOverText.posOverride = posOverride
		-- if text did not change, nothing to do
		if private.mouseOverText.overrideText == private.mouseOverOverrideText then
			return
		else
			count = private.mouseOverText.count
		end
	end

	if text == "" then
		if (private.mouseOverText ~= nil) then
			private.mouseOverText.count = private.mouseOverText.count - 1
		end
		return -- nothing to display
	end

	-- elements
	local mouseOverElement = getElement("popupmenu", private.widgetsystem)
	local bgElement = getElement("Rectangle", mouseOverElement)
	local textElement = getElement("Text", mouseOverElement)

	-- properties
	local fontname, fontsize = widgetSystem.getCurrentMouseOverFont()
	local maxWidth = widgetSystem.getCurrentMouseOverWidth()
	
	local numlines, textwidth = GetTextNumLines(text, fontname, fontsize, maxWidth)
	textwidth = math.ceil(textwidth or maxWidth)
	local width = textwidth + config.mouseOverText.borderSize.right + config.mouseOverText.borderSize.left
	local textheight = math.ceil(C.GetTextHeight(text, fontname, fontsize, textwidth))
	local height = textheight + config.mouseOverText.borderSize.top + config.mouseOverText.borderSize.bottom

	private.mouseOverText = {
		widgetID = widgetID,
		count = count,
		width = width,
		height = height,
		cursorinfo = C.GetCurrentCursorInfo(),
		text = text,
		overrideText = private.mouseOverOverrideText,
		posOverride = posOverride,
	}

	-- activate slide
	goToSlide(mouseOverElement, "active")

	-- scaling
	widgetSystem.setElementScale(bgElement, width / 100, height / 100)

	local color = Color["frame_background_notification"]
	local material = getElement("Material1946", bgElement)
	SetDiffuseColor(material, color.r, color.g, color.b)
	setAttribute(material, "opacity", color.a)

	-- position
	widgetSystem.setElementPosition(textElement, -textwidth / 2, textheight / 2 + config.mouseOverText.borderSize.top)
	widgetSystem.setMouseOverPosition()

	-- text
	setAttribute(textElement, "size", fontsize)
	setAttribute(textElement, "boxwidth", textwidth / config.nativePresentationWidth)
	setAttribute(textElement, "textstring", text)

	local textcolor = Color["text_normal"]
	setAttribute(textElement, "textcolor.r", textcolor.r)
	setAttribute(textElement, "textcolor.g", textcolor.g)
	setAttribute(textElement, "textcolor.b", textcolor.b)
	setAttribute(textElement, "opacity", textcolor.a)
	setAttribute(textElement, "glowfactor", textcolor.glow)
end

function widgetSystem.hideMouseOverText(widgetID, ignorecount)
	if private.mouseOverText == nil then
		return -- nothing to do
	end

	if private.mouseOverText.widgetID == widgetID then
		-- decrease counter
		private.mouseOverText.count = private.mouseOverText.count - 1
		if (not ignorecount) and (private.mouseOverText.count > 0) then
			return
		end
	end

	goToSlide(getElement("popupmenu", private.widgetsystem), "inactive")
	private.mouseOverText = nil
end

function widgetSystem.updateMouseOverText(widgetID)
	if private.mouseOverText and (private.mouseOverText.widgetID == widgetID) then
		local text = private.mouseOverOverrideText or ffi.string(C.GetMouseOverText(widgetID))
		if text == "" then
			widgetSystem.hideMouseOverText(widgetID, true)
		else
			widgetSystem.showMouseOverText(widgetID, true)
		end
	end
end

function widgetSystem.setMouseOverPosition()
	if private.mouseOverText == nil then
		return -- nothing to do
	end
	
	local posX, posY = GetLocalMousePosition()
	if private.mouseOverText.posOverride then
		posX = private.mouseOverText.posOverride.x
		posY = private.mouseOverText.posOverride.y
	elseif posX == nil then
		widgetSystem.hideMouseOverText(private.mouseOverText.widgetID)
		return
	end

	local width = private.mouseOverText.width
	local height = private.mouseOverText.height

	local offsetx = posX + config.mouseOverText.offsetX + width / 2
	if not private.mouseOverText.posOverride then
		offsetx = offsetx + private.mouseOverText.cursorinfo.width - private.mouseOverText.cursorinfo.xHotspot
	end
	local offsety = posY
	if not private.mouseOverText.posOverride then
		offsety = offsety - height / 2
	end
	if private.width / 2 - offsetx < width / 2 then
		offsetx = posX - private.mouseOverText.cursorinfo.xHotspot - config.mouseOverText.offsetX - width / 2
	end
	if private.height / 2 + offsety < height / 2 then
		offsety = -private.height / 2 + height / 2
	end
	widgetSystem.setElementPosition(getElement("popupmenu", private.widgetsystem), offsetx, offsety)
end

function widgetSystem.showMinimizedMenuName(frameElement, text)
	if text == "" then
		-- Nothing to do
		return
	end

	-- Check if tghe minimize standardButton is shown for this menu
	if not frameElement["minimizeButtonShown"] then
		-- Nothing to do
		return
	end

	local textElement = getElement("text", frameElement.standardButtons)
	local textElementText = getElement("Text", textElement)
	setAttribute(textElementText, "size", config.frame.standardButtonTextSize)
	setAttribute(textElementText, "textstring", text)
	setAttribute(textElementText, "glowfactor", config.glowfactors.standardButtons)
	goToSlide(textElement, "active")
end

function widgetSystem.hideMinimizedMenuName(frameElement)
	local textElement = getElement("text", frameElement.standardButtons)
	goToSlide(textElement, "inactive")
end

function widgetSystem.updateView()
	private.viewDisplayed = true

	-- hide old items (support for frame updates replacing a previous frame)
	widgetSystem.hideAllElements()
end

function widgetSystem.updateFrame(frameID)
	if not IsValidWidgetElement(frameID) then
		return -- can happen if a view is closed before this callback is processed
	end

	local frameLayer = GetFrameLayer(frameID)
	local frameElement = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames[1] or private.frames[frameLayer]

	if frameElement.frame then
		if private.oldInteractiveElement then
			if private.oldInteractiveElement.frameID == frameElement.frame then
				private.oldInteractiveElement.frameID = frameID
			end
		end
		widgetSystem.hideFrame(frameElement)
	end

	frameElement.offsetx, frameElement.offsety = GetFramePosition(frameID)
	if frameElement.offsetx == nil then
		-- frame doesn't exist, skip further code
		-- There should be an error from GetFramePosition() and why did GetFrameLayer() work?
		return
	end
	frameElement.offsetx = frameElement.offsetx - private.offsetx
	frameElement.offsety = private.offsety - frameElement.offsety
	frameElement.width, frameElement.height    = GetSize(frameID)
	frameElement.frame   = frameID

	widgetSystem.addHelpOverlay(frameElement, frameID, frameElement.offsetx, frameElement.offsety, frameElement.width, frameElement.height)

	-- set background/overlay
	-- private.offset is the coordinates in Anark space (aka: -view.width/2 / view.height/2) so that offset.x/offset.y represents the upper left corner of the view
	-- hence the proper position calculation for the background images (which are aligned in the texture's center) is:
	-- A + B + C
	-- A = offset (the upper left corner of the frame)
	-- B = (frame.width - view.width) / 2 (calculate the center position of the frame background - x = 400 => frame center = 200 - and calculate the offset relative to the Anark presentation's center -
	--     x-AnarkWidth/2 => 200-615 => -415 => the coordinate in the Anark presentation where the frame would have to be positioned
	-- C = view.width/2 - this is to compensate for the fact that private.offset (i.e. frame position) already contains -AnarkWidth/2 so that 0/0 corresponds to -AnarkWidth/2 // AnarkHeight/2
	-- offset + (frame.width - view.width)/2 + view.width/2
	-- => offset + frame.width/2

	local backgroundOffsetx = frameElement.offsetx + frameElement.width / 2
	local backgroundOffsety = frameElement.offsety - frameElement.height / 2

	for _, type in ipairs(config.frame.backgroundElements) do
		local info = { iconid = "" }
		if type == "backgroundTexture" then
			info = C.GetFrameBackgroundInfo(frameID)
		elseif type == "background2Texture" then
			info = C.GetFrameBackground2Info(frameID)
		elseif type == "overlayTexture" then
			info = C.GetFrameOverlayInfo(frameID)
		else
			DebugError("Widget system error. Unknown background element type '" .. tostring(type) .. "'.")
		end
		local iconid = ffi.string(info.iconid)

		if iconid ~= "" then
			local data = frameElement[type .. "Data"]
			data.active = true
			goToSlide(frameElement[type], "active")

			local width = (info.width > 0) and info.width or frameElement.width
			local height = (info.height > 0) and info.height or frameElement.height

			data.origScale = { x = width / 100, y = height / 100 }

			SetIcon(frameElement[type .. "Icon"], iconid, info.color.red, info.color.green, info.color.blue, false, width, height)
			setAttribute(getElement("parent", frameElement[type .. "Icon"]), "opacity", info.color.alpha)
			widgetSystem.setElementPosition(frameElement[type], backgroundOffsetx, backgroundOffsety)
			setAttribute(getElement("parent", frameElement[type .. "Icon"]), "glowfactor", info.glowfactor)

			if info.rotationrate ~= 0 then
				data.rotationRate = info.rotationrate
				data.rotationStart = info.rotstart
				data.rotationDuration = info.rotduration
				data.rotationInterval = info.rotinterval

				if data.rotationDuration > 0 then
					data.rotationEnd = (data.rotationRate * data.rotationDuration + data.rotationStart) % 360
				end

				setAttribute(frameElement[type .. "Icon"], "rotationuv", data.rotationStart)
			else
				data.rotationRate = 0
				setAttribute(frameElement[type .. "Icon"], "rotationuv", info.rotstart)
			end
			if info.initscale ~= 1 then
				data.initScale = info.initscale
				data.scaleDuration = info.scaleduration

				-- Curve: y = ax² + bx + c
				-- Conditions:
				--		x = 0, y = initScale -> c = initScale
				--		x = duration, y = 1
				-- a and b still have one degree of freedom, we choose an a arbitrarily
				-- -> b = (1 - a*duration² - initScale) / duration
				data.quadraticFactor = 8
				data.linearFactor = (1 - data.quadraticFactor * data.scaleDuration * data.scaleDuration - data.initScale) / data.scaleDuration

				setAttribute(getElement(type, frameElement[type]), "scale.x", data.initScale * data.origScale.x)
				setAttribute(getElement(type, frameElement[type]), "scale.y", data.initScale * data.origScale.y)
			else
				data.initScale = 1
			end
		else
			frameElement[type .. "Data"].active = nil
			goToSlide(frameElement[type], "inactive")
		end
	end

	if C.HasFrameBrackets(frameID) then
		goToSlide(frameElement.bracketsElement, "active")

		local unevenWidthCorrection = (frameElement.width % 2 ~= 0) and -1 or 0
		local unevenHeightCorrection = (frameElement.height % 2 ~= 0) and -1 or 0
		widgetSystem.setElementPosition(getElement("bracket_top_left", frameElement.bracketsElement),   frameElement.offsetx + unevenWidthCorrection,                      frameElement.offsety + unevenHeightCorrection)
		widgetSystem.setElementPosition(getElement("bracket_top_right", frameElement.bracketsElement),  frameElement.offsetx + unevenWidthCorrection + frameElement.width, frameElement.offsety + unevenHeightCorrection)
		widgetSystem.setElementPosition(getElement("bracket_down_left", frameElement.bracketsElement),  frameElement.offsetx + unevenWidthCorrection,                      frameElement.offsety + unevenHeightCorrection - frameElement.height)
		widgetSystem.setElementPosition(getElement("bracket_down_right", frameElement.bracketsElement), frameElement.offsetx + unevenWidthCorrection + frameElement.width, frameElement.offsety + unevenHeightCorrection - frameElement.height)
	else
		goToSlide(frameElement.bracketsElement, "inactive")
	end

	-- #StefanMed - check how we could enable the following syntax with Anark/Widgets
	-- local content = { frame:GetChildren() }
	local content = { GetChildren(frameID) }
	for _, child in ipairs(content) do
		if IsType(child, "table") then
			local tableElement = widgetSystem.getElement("table")
			if tableElement ~= nil then
				table.insert(frameElement.tables, tableElement)
				widgetSystem.setUpTable(frameElement, child, tableElement)
				widgetSystem.moveTableElementFrameLayer(frameElement, tableElement, 1)
			else
				if private.miniWidgetSystemUsed then
					DebugError("Widget system error. Already displaying "..config.miniWidgetsystem.maxTables.." tables. Cannot display more. Table in frame ".. frameID .." will be skipped.")
				else
					DebugError("Widget system error. Already displaying "..config.table.maxTables.." tables. Cannot display more. Table in frame ".. frameID .." will be skipped.")
				end
			end
		elseif IsType(child, "rendertarget") then
			local renderTargetElement = private.element.renderTarget
			if renderTargetElement ~= nil then
				private.element.renderTarget = nil
				table.insert(frameElement.rendertargets, renderTargetElement)
				widgetSystem.moveAnarkElementFrameLayer(frameElement, renderTargetElement.element, 1)
				widgetSystem.setUpRenderTarget(frameElement, child, renderTargetElement)
			else
				if private.miniWidgetSystemUsed then
					DebugError("Widget system error. No icons available in minimal widget system. Rendertarget in frame ".. frameID .." will be skipped.")
				else
					DebugError("Widget system error. Already displaying a rendertarget. Cannot display more rendertargets in frame ".. frameID .." will be skipped.")
				end
			end
		elseif IsType(child, "flowchart") then
			local flowchartElement = widgetSystem.getElement("flowchart")
			if flowchartElement ~= nil then
				table.insert(frameElement.flowcharts, flowchartElement)
				widgetSystem.setUpFlowchart(frameElement, child, flowchartElement)
				widgetSystem.moveFlowchartElementFrameLayer(frameElement, flowchartElement, 1)
			else
				if private.miniWidgetSystemUsed then
					DebugError("Widget system error. Flowcharts not supported in mini widgetsystem. Flowchart in frame ".. frameID .." will be skipped.")
				else
					DebugError("Widget system error. Already displaying "..config.flowchart.maxFlowcharts.." flowchart(s). Cannot display more. Flowchart in frame ".. frameID .." will be skipped.")
				end
			end
		else
			DebugError("Widget system error. Specified object type is unsupported.")
		end
	end

	widgetSystem.setUpStandardButtons(frameID, frameElement)

	if private.activeframe == frameID then
		local interactiveWidgetID = GetInteractiveObject(frameID)
		if interactiveWidgetID ~= nil then
			-- can be nil, if frame has no interactive object at all
			widgetSystem.setInteractiveElement(frameID, interactiveWidgetID)
		end
	end

	widgetSystem.addToAssociationList(frameID, frameElement, nil, private.offsetx, private.offsety, private.width)
end

function widgetSystem.moveAnarkElementFrameLayer(frameElement, anarkElement, direction)
	setAttribute(anarkElement, "position.z", getAttribute(anarkElement, "position.z") + direction * (frameElement.layer - 1) * config.frame.layerOffset)
end

function widgetSystem.moveAnarkElementBetweenFrameLayers(anarkElement, fromLayer, toLayer)
	if fromLayer ~= toLayer then
		setAttribute(anarkElement, "position.z", getAttribute(anarkElement, "position.z") + (toLayer - fromLayer) * config.frame.layerOffset)
	end
end

function widgetSystem.moveTableElementFrameLayer(frameElement, tableElement, direction)
	widgetSystem.moveAnarkElementFrameLayer(frameElement, tableElement.header, direction)
	widgetSystem.moveAnarkElementFrameLayer(frameElement, tableElement.scrollBar.element, direction)
	widgetSystem.moveAnarkElementFrameLayer(frameElement, tableElement.mousePick.element, direction)
	widgetSystem.moveAnarkElementFrameLayer(frameElement, tableElement.borderElements.highlightElement, direction)
end

function widgetSystem.moveDropDownElementFrameLayer(frameElement, dropdownElement, direction)
	widgetSystem.moveAnarkElementFrameLayer(frameElement, dropdownElement.mainElement, direction)
	for _, optionElement in ipairs(dropdownElement.optionElements) do
		widgetSystem.moveAnarkElementFrameLayer(frameElement, optionElement, direction)
	end
end

function widgetSystem.moveGraphElementFrameLayer(frameElement, graphElement, direction)
	widgetSystem.moveAnarkElementFrameLayer(frameElement, graphElement.mainElement, direction)
	for i = 1, config.graph.maxTicksPerElement do
		tickElement = graphElement.tickElements[i]
		widgetSystem.moveAnarkElementFrameLayer(frameElement, tickElement, direction)
	end
end

function widgetSystem.moveFlowchartElementFrameLayer(frameElement, flowchartElement, direction)
	widgetSystem.moveAnarkElementFrameLayer(frameElement, flowchartElement.mousePick.element, direction)
	widgetSystem.moveAnarkElementFrameLayer(frameElement, flowchartElement.headerBackground, direction)
	widgetSystem.moveAnarkElementFrameLayer(frameElement, flowchartElement.footerBackground, direction)
	for _, columnBackground in ipairs(flowchartElement.columnBackgrounds) do
		widgetSystem.moveAnarkElementFrameLayer(frameElement, columnBackground, direction)
	end
	for scrolltype, scrollbar in pairs(flowchartElement.scrollBars) do
		widgetSystem.moveAnarkElementFrameLayer(frameElement, scrollbar.element, direction)
	end
end

function widgetSystem.moveFlowchartNodeBetweenFrameLayers(flowchartNodeElement, fromLayer, toLayer)
	widgetSystem.moveAnarkElementBetweenFrameLayers(flowchartNodeElement.main, fromLayer, toLayer)
end

function widgetSystem.deactivateDirectInputElements()
	if private.activeEditBox ~= nil then
		-- we decided to use a consistent editbox behavior --- whenever an editbox is closed, it keeps the current input (i.e. no cancel support)
		-- #StefanMed --- rethink the behavior ---- maybe better go with a per editbox-parameter to define whether a box is to keep its input on close (without ENTER) or revert it to the old text
		widgetSystem.confirmEditBoxInputInternal(private.activeEditBox.editboxID, private.activeEditBox.editboxElement, false)
	end
	if private.activeSliderCell ~= nil then
		-- we decided to use a consistent slidercell behavior --- whenever a slidercell is closed implicitly, it keeps the current input
		widgetSystem.confirmSliderCellInputInternal(private.activeSliderCell.widgetID, private.activeSliderCell.element)
	end
end

function widgetSystem.activateEditBoxInternal(frameElement, editboxID, editboxElement, cursorpos, shiftstartpos)
	if not editboxElement.widgetActive then
		return
	end

	private.activeEditBox = {
		["frameElement"]   = frameElement,
		["editboxID"]      = editboxID,
		["editboxElement"] = editboxElement
	}

	local tableElement, tableID, row, col = widgetSystem.getTableElementByAnarkTableCellElement("editbox", editboxElement.element)
	widgetSystem.setActiveFrame(frameElement)
	widgetSystem.setInteractiveElement(frameElement.frame, tableID)
	if private.interactiveElement ~= nil then
		private.oldInteractiveElement = private.interactiveElement
		if private.interactiveElement.element and (private.interactiveElement.element.interactiveChild ~= nil) then
			local interactiveChildEntry = private.associationList[private.interactiveElement.element.interactiveChild.widgetID]
			if interactiveChildEntry then
				widgetSystem.unsetInteractiveChildElement(private.interactiveElement.element, private.interactiveElement.element.interactiveChild.widgetID, interactiveChildEntry.element)
			end
		end
	end

	widgetSystem.setInteractiveChildElement(tableID, tableElement, row, col, editboxID, editboxElement)

	if editboxElement.hotkeyIconActive then
		-- no unnecessary goToSlide()-call if the hotkey icon is inactive anyway
		local hotkeyElement = getElement("Hotkey", editboxElement.element)
		goToSlide(hotkeyElement, "inactive")
	end

	local cursorelement = getElement("Cursor", editboxElement.element)
	goToSlide(cursorelement, "active")

	editboxElement.shiftStartPos = editboxElement.selectTextOnActivation and 0 or nil

	widgetSystem.updateEditBoxColor(editboxID, editboxElement, true)

	editboxElement.active = true
	widgetSystem.setEditBoxText(editboxElement, editboxElement.text)

	if cursorpos then
		editboxElement.cursorPos = cursorpos
	end
	if shiftstartpos then
		editboxElement.shiftStartPos = shiftstartpos
	end

	widgetSystem.updateEditBoxTextDisplay(editboxElement)
	CallWidgetEventScripts(editboxID, "onCursorChanged", editboxElement.cursorPos, editboxElement.shiftStartPos)
	editboxElement.oldtext = editboxElement.text
	editboxElement.cursor = false
	editboxElement.lastcursorupdatetime = getElapsedTime() - config.editbox.cursorBlinkInterval - 1

	if editboxElement.text == "" then
		local textelement = getElement("Text", editboxElement.element)
		setAttribute(textelement, "textcolor.r", editboxElement.textColor.r)
		setAttribute(textelement, "textcolor.g", editboxElement.textColor.g)
		setAttribute(textelement, "textcolor.b", editboxElement.textColor.b)
		setAttribute(textelement, "opacity", editboxElement.textColor.a)
	end

	if editboxElement.encrypted then
		C.EnableEncryptedDirectInputMode()
	end
	if (GetControllerInfo() ~= "gamepad") or (not C.ShowGamepadTextInput(editboxElement.description, editboxElement.maxChars, editboxElement.textHidden and "" or editboxElement.text, false, editboxElement.textHidden)) then
		C.ActivateDirectInput()
	end

	CallWidgetEventScripts(editboxID, "onEditBoxActivated", editboxElement.oldtext)
end

function widgetSystem.deactivateEditBox(editboxID, editboxElement, isconfirmed, wastableclick)
	-- need to do this first, because the addon listing to "onEditBoxDeactivated" could invalidate the oldInteractiveElement data
	widgetSystem.updateEditBoxColor(editboxID, editboxElement, not editboxElement.restoreInteractiveElement)
	if editboxElement.restoreInteractiveElement and (private.oldInteractiveElement ~= nil) then
		local frameentry = private.associationList[private.oldInteractiveElement.frameID]
		if frameentry and IsValidWidgetElement(private.oldInteractiveElement.frameID) then
			widgetSystem.setActiveFrame(frameentry.element)
			widgetSystem.setInteractiveElement(private.oldInteractiveElement.frameID, private.oldInteractiveElement.widgetID)
			if private.oldInteractiveElement.element and (private.oldInteractiveElement.element.interactiveChild ~= nil) then
				local entry = private.associationList[private.oldInteractiveElement.element.interactiveChild.widgetID]
				if entry and IsValidWidgetElement(private.oldInteractiveElement.element.interactiveChild.widgetID) then
					widgetSystem.setInteractiveChildElement(private.oldInteractiveElement.widgetID, private.oldInteractiveElement.element, private.oldInteractiveElement.element.interactiveChild.row, private.oldInteractiveElement.element.interactiveChild.col, private.oldInteractiveElement.element.interactiveChild.widgetID, entry.element)
				end
			end
		end
	end
	private.oldInteractiveElement = nil

	if editboxID then
		if editboxElement.text ~= editboxElement.oldtext then
			C.SetEditBoxText(editboxID, editboxElement.text)
		end
		CallWidgetEventScripts(editboxID, "onEditBoxDeactivated", editboxElement.text, editboxElement.text ~= editboxElement.oldtext, isconfirmed, wastableclick)
	end

	C.DeactivateDirectInput()
	if editboxElement.encrypted then
		C.DisableEncryptedDirectInputMode()
	end

	editboxElement.active = false
	editboxElement.oldtext = ""
	editboxElement.cursor = false
	widgetSystem.setEditBoxText(editboxElement, editboxElement.text)

	editboxElement.shiftStartPos = nil
	widgetSystem.updateEditBoxTextHighlight(editboxElement)

	local cursorelement = getElement("Cursor", editboxElement.element)
	goToSlide(cursorelement, "inactive")

	if editboxElement.hotkeyIconActive then
		local hotkeyElement = getElement("Hotkey", editboxElement.element)
		goToSlide(hotkeyElement, "active")
	end
	private.activeEditBox = nil
end

function widgetSystem.confirmEditBoxInputInternal(editboxID, editboxElement, isconfirmed, wastableclick)
	widgetSystem.deactivateEditBox(editboxID, editboxElement, isconfirmed, wastableclick)
end

function widgetSystem.confirmEditBoxInput(editboxID)
	local editboxentry = private.associationList[editboxID]
	if editboxentry == nil then
		return false, 1, "invalid editbox element"
	end
	local editboxElement = editboxentry.element

	if not editboxElement.active then
		return false, 2, "editbox is not active"
	end

	widgetSystem.confirmEditBoxInputInternal(editboxID, editboxElement, true)

	return true
end

function widgetSystem.updateEditBoxColor(editboxID, editboxElement, highlighted)
	local material = getElement("background.Material689", editboxElement.element)
	local color = editboxElement.color
	if highlighted then
		color = Color["editbox_border"]
	end
	SetDiffuseColor(material, color.r, color.g, color.b)
	setAttribute(material, "opacity", color.a)
	setAttribute(material, "glowfactor", color.glow)
end

function widgetSystem.closeDropDownOptions(dropdownID)
	local dropdownentry = private.associationList[dropdownID]
	if dropdownentry == nil then
		return false, 1, "invalid dropdown element"
	end
	local dropdownElement = dropdownentry.element

	if not dropdownElement.active then
		return false, 2, "dropdown is not active"
	end

	widgetSystem.hideDropDownOptions(dropdownID, dropdownElement)
end

function widgetSystem.cancelEditBoxInputInternal(editboxID, editboxElement)
	if editboxElement.text ~= editboxElement.oldtext then
		widgetSystem.setEditBoxText(editboxElement, editboxElement.oldtext)
		editboxElement.cursor = false
	end
	widgetSystem.deactivateEditBox(editboxID, editboxElement, false)
end

function widgetSystem.cancelEditBoxInput(editboxID)
	local editboxentry = private.associationList[editboxID]
	if editboxentry == nil then
		return false, 1, "invalid editbox element"
	end
	local editboxElement = editboxentry.element

	if not editboxElement.active then
		return false, 2, "editbox is not active"
	end

	 widgetSystem.cancelEditBoxInputInternal(editboxID, editboxElement)

	return true
end

function widgetSystem.updateEditBoxCursor(editboxElement, curTime, scrolling)
	if scrolling then
		editboxElement.cursor = true

		widgetSystem.updateEditBoxCursorPosition(editboxElement)
		setAttribute(getElement("Cursor.cursor.Material1320", editboxElement.element), "opacity", editboxElement.cursor and editboxElement.textColor.a or 0)
	elseif editboxElement.lastcursorupdatetime + config.editbox.cursorBlinkInterval < curTime then
		editboxElement.lastcursorupdatetime = curTime
		editboxElement.cursor = not editboxElement.cursor

		widgetSystem.updateEditBoxCursorPosition(editboxElement)
		setAttribute(getElement("Cursor.cursor.Material1320", editboxElement.element), "opacity", editboxElement.cursor and editboxElement.textColor.a or 0)
	end
end

function widgetSystem.updateEditBoxCursorPosition(editboxElement)
	editboxElement.cursorPos = math.max(0, math.min(utf8.len(editboxElement.text), editboxElement.cursorPos))

	local text = widgetSystem.hideText(editboxElement.text, editboxElement.textHidden)
	local fullwidth = C.GetTextWidth(utf8.sub(text, editboxElement.textDisplayStart and (editboxElement.textDisplayStart + 1) or 1, editboxElement.textDisplayEnd and editboxElement.textDisplayEnd or utf8.len(text)),	editboxElement.font, editboxElement.fontsize)
	local textwidth = C.GetTextWidth(utf8.sub(text, editboxElement.textDisplayStart and (editboxElement.textDisplayStart + 1) or 1, editboxElement.cursorPos),															editboxElement.font, editboxElement.fontsize)

	local offsetx = editboxElement.textOffsetX + config.editbox.cursorOffsetX + textwidth
	if editboxElement.textAlignment == "center" then
		offsetx = offsetx - fullwidth / 2
	elseif editboxElement.textAlignment == "right" then
		offsetx = offsetx - fullwidth
	end

	widgetSystem.setElementPosition(getElement("Cursor", editboxElement.element), offsetx)
end

function widgetSystem.removeNextEditBoxChar(editboxID, editboxElement)
	if (utf8.len(editboxElement.text) > editboxElement.cursorPos) or (editboxElement.shiftStartPos and (editboxElement.shiftStartPos ~= editboxElement.cursorPos)) then
		if editboxElement.shiftStartPos and (editboxElement.shiftStartPos ~= editboxElement.cursorPos) then
			if editboxElement.cursorPos > editboxElement.shiftStartPos then
				editboxElement.text = utf8.sub(editboxElement.text, 1, math.max(0, editboxElement.shiftStartPos)) .. utf8.sub(editboxElement.text, editboxElement.cursorPos + 1, -1)
				editboxElement.cursorPos = editboxElement.cursorPos - (editboxElement.cursorPos - editboxElement.shiftStartPos)
			else
				editboxElement.text = utf8.sub(editboxElement.text, 1, math.max(0, editboxElement.cursorPos)) .. utf8.sub(editboxElement.text, editboxElement.shiftStartPos + 1, -1)
			end
		else
			editboxElement.text = utf8.sub(editboxElement.text, 1, math.max(0, editboxElement.cursorPos)) .. utf8.sub(editboxElement.text, editboxElement.cursorPos + 2, -1)
		end
		CallWidgetEventScripts(editboxID, "onTextChanged", editboxElement.text)

		setAttribute(getElement("Text", editboxElement.element), "textstring", widgetSystem.hideText(editboxElement.text, editboxElement.textHidden))
		editboxElement.shiftStartPos = nil
		widgetSystem.updateEditBoxTextDisplay(editboxElement)
		widgetSystem.updateEditBoxCursorPosition(editboxElement)
		widgetSystem.updateEditBoxTextHighlight(editboxElement)
		CallWidgetEventScripts(editboxID, "onCursorChanged", editboxElement.cursorPos, editboxElement.shiftStartPos)
	end
end

function widgetSystem.updateEditBoxTextHighlight(editboxElement)
	if editboxElement.shiftStartPos then
		local text = widgetSystem.hideText(editboxElement.text, editboxElement.textHidden)
		local fullwidth			= C.GetTextWidth(utf8.sub(text, editboxElement.textDisplayStart and (editboxElement.textDisplayStart + 1) or 1, editboxElement.textDisplayEnd and editboxElement.textDisplayEnd or utf8.len(text)),															editboxElement.font, editboxElement.fontsize)
		local starttextwidth	= C.GetTextWidth(utf8.sub(text, editboxElement.textDisplayStart and (editboxElement.textDisplayStart + 1) or 1, math.min(editboxElement.textDisplayEnd or utf8.len(text), math.max(editboxElement.shiftStartPos, editboxElement.textDisplayStart or 0))),	editboxElement.font, editboxElement.fontsize)
		local curtextwidth		= C.GetTextWidth(utf8.sub(text, editboxElement.textDisplayStart and (editboxElement.textDisplayStart + 1) or 1, editboxElement.cursorPos),																													editboxElement.font, editboxElement.fontsize)
		local startoffsetx = editboxElement.textOffsetX + config.editbox.cursorOffsetX + starttextwidth
		local curoffsetx = editboxElement.textOffsetX + config.editbox.cursorOffsetX + curtextwidth
		if editboxElement.textAlignment == "center" then
			startoffsetx = startoffsetx - fullwidth / 2
			curoffsetx = curoffsetx - fullwidth / 2
		elseif editboxElement.textAlignment == "right" then
			startoffsetx = startoffsetx - fullwidth
			curoffsetx = curoffsetx - fullwidth
		end
		local offsetx, width
		if startoffsetx < curoffsetx then
			offsetx = startoffsetx
			width = curoffsetx - startoffsetx
		else
			offsetx = curoffsetx
			width = startoffsetx - curoffsetx
		end

		local highlightelement = getElement("highlight", editboxElement.element)
		widgetSystem.setElementPosition(highlightelement, offsetx + width / 2)
		widgetSystem.setElementScale(highlightelement, width / 100)
		setAttribute(getElement("highlight.Material689", editboxElement.element), "opacity", Color["editbox_border"].a)
	else
		setAttribute(getElement("highlight.Material689", editboxElement.element), "opacity", 0)
	end
end

function widgetSystem.updateEditBoxTextDisplay(editboxElement)
	editboxElement.cursorPos = math.max(0, math.min(utf8.len(editboxElement.text), editboxElement.cursorPos))

	local newtext = widgetSystem.hideText(editboxElement.text, editboxElement.textHidden)
	local fulllength = utf8.len(newtext)
	if C.GetTextWidth(newtext, editboxElement.font, editboxElement.fontsize) > (editboxElement.width - 2 * (editboxElement.rawTextOffsetX + config.texturesizes.editbox.borderSize)) then
		local availablewidth = editboxElement.width - 2 * (editboxElement.rawTextOffsetX + config.texturesizes.editbox.borderSize)
		if (editboxElement.cursorPos == fulllength) or (editboxElement.cursorPos >= editboxElement.textDisplayEnd) then
			-- cursor not visible, keep it in sight
			newtext = utf8.sub(newtext, 1, editboxElement.cursorPos)
			while (newtext ~= "") and C.GetTextWidth(newtext, editboxElement.font, editboxElement.fontsize) > availablewidth do
				newtext = utf8.sub(newtext, 2, -1)
			end
			editboxElement.textDisplayStart = editboxElement.cursorPos - utf8.len(newtext)
			editboxElement.textDisplayEnd = editboxElement.cursorPos
		elseif editboxElement.cursorPos <= editboxElement.textDisplayStart then
			-- cursor not visible, keep it in sight
			newtext = utf8.sub(newtext, editboxElement.cursorPos + 1, -1)
			while (newtext ~= "") and C.GetTextWidth(newtext, editboxElement.font, editboxElement.fontsize) > availablewidth do
				newtext = utf8.sub(newtext, 1, -2)
			end
			editboxElement.textDisplayStart = editboxElement.cursorPos
			editboxElement.textDisplayEnd = editboxElement.cursorPos + utf8.len(newtext)
		elseif editboxElement.textDisplayEnd >= fulllength then
			-- text ends before display, move it to the end
			while (newtext ~= "") and C.GetTextWidth(newtext, editboxElement.font, editboxElement.fontsize) > availablewidth do
				newtext = utf8.sub(newtext, 2, -1)
			end
			editboxElement.textDisplayStart = fulllength - utf8.len(newtext)
			editboxElement.textDisplayEnd = fulllength
		elseif editboxElement.textDisplayStart then
			-- text does not fit, adjust from current start + 1
			newtext = utf8.sub(newtext, editboxElement.textDisplayStart + 1, -1)
			while (newtext ~= "") and C.GetTextWidth(newtext, editboxElement.font, editboxElement.fontsize) > availablewidth do
				newtext = utf8.sub(newtext, 1, -2)
			end
			editboxElement.textDisplayStart = editboxElement.textDisplayStart
			editboxElement.textDisplayEnd = editboxElement.textDisplayStart + utf8.len(newtext)
		else
			-- should not happen, let it display everything, will look broken
			DebugError("widgetSystem.updateEditBoxTextDisplay(): uncaught case - cursor:" .. tostring(editboxElement.cursorPos) .. ", text length: " .. tostring(fulllength) .. ", display start:" .. tostring(editboxElement.textDisplayStart) .. ", display end:" .. tostring(editboxElement.textDisplayEnd))
			editboxElement.textDisplayStart = 0
			editboxElement.textDisplayEnd = fulllength
		end
	else
		-- text fits, nothing to do
		editboxElement.textDisplayStart = 0
		editboxElement.textDisplayEnd = fulllength
	end
	editboxElement.textDisplayStart	= math.max(0,			editboxElement.textDisplayStart)
	editboxElement.textDisplayEnd	= math.min(fulllength,	editboxElement.textDisplayEnd)
	setAttribute(getElement("Text", editboxElement.element), "textstring", newtext)
end

function widgetSystem.getEditBoxCursorPosFromMouse(frameElement, editboxID, editboxElement)
	local x = widgetSystem.getEditBoxMousePosition(frameElement, editboxID)
	if x then
		local text = widgetSystem.hideText(editboxElement.text, editboxElement.textHidden)
		local startPos = editboxElement.textDisplayStart and (editboxElement.textDisplayStart + 1) or 1
		local endPos = editboxElement.textDisplayEnd and editboxElement.textDisplayEnd or utf8.len(text)
		local fulltextwidth = C.GetTextWidth(utf8.sub(text, startPos, endPos), editboxElement.font, editboxElement.fontsize)
		local textx = editboxElement.textOffsetX + editboxElement.width / 2
		if editboxElement.textAlignment == "center" then
			textx = textx - fulltextwidth / 2
		elseif editboxElement.textAlignment == "right" then
			textx = textx - fulltextwidth
		end

		local offsetx = x - textx
		local bestFit = 0
		local lastWidth = 0
		for i = startPos - 1, endPos do
			local textwidth = C.GetTextWidth(utf8.sub(text, startPos, i), editboxElement.font, editboxElement.fontsize)
			if textwidth < offsetx then
				-- not there yet keep going
				lastWidth = textwidth
				bestFit = i
			elseif offsetx - lastWidth > textwidth - offsetx then
				-- after the char is closer than before, take that
				bestFit = i
				break
			else
				break
			end
		end
		return bestFit, x
	end
end

function widgetSystem.findEditBoxWordAtPos(editboxElement, curpos)
	local infiniteloopcounter = 0

	local wordidx = 1
	while wordidx ~= nil do
		local first, second = utf8.find(editboxElement.text, "[^%s%p]+", wordidx)
		wordidx = nil
		if second then
			local wordend, nextwordstart = utf8.find(editboxElement.text, "[%s%p]+", second)
			wordidx = nextwordstart
		end
		second = second or utf8.len(editboxElement.text)
		if first and ((wordidx and (wordidx - 1) or second) >= curpos) then
			return first - 1, second, wordidx
		end

		infiniteloopcounter = infiniteloopcounter + 1
		if infiniteloopcounter > 10000 then
			break
		end
	end
end

function widgetSystem.activateSliderCellInputInternal(slidercellID, slidercellElement)
	private.activeSliderCell = {
		["widgetID"] = slidercellID,
		["element"] = slidercellElement
	}
	if private.interactiveElement ~= nil then
		private.oldInteractiveElement = private.interactiveElement
		if (private.interactiveElement.element.interactiveChild ~= nil) and private.associationList[private.interactiveElement.element.interactiveChild.widgetID] then
			widgetSystem.unsetInteractiveChildElement(private.interactiveElement.element, private.interactiveElement.element.interactiveChild.widgetID, private.associationList[private.interactiveElement.element.interactiveChild.widgetID].element)
		end
		private.interactiveElement = nil
	end

	local tableElement, tableID, row, col = widgetSystem.getTableElementByAnarkTableCellElement("slidercell", slidercellElement.element.main)
	widgetSystem.setInteractiveChildElement(tableID, tableElement, row, col, slidercellID, slidercellElement)

	slidercellElement.inputActive = true
	slidercellElement.oldcur = slidercellElement.cur
	slidercellElement.cur = ""
	C.SetSliderCellValue(slidercellID, slidercellElement.minSelect)
	CallWidgetEventScripts(slidercellID, "onSliderCellChanged", slidercellElement.minSelect)
	slidercellElement.cursor = false
	slidercellElement.lastcursorupdatetime = getElapsedTime() - config.slidercell.cursorBlinkInterval - 1

	if (GetControllerInfo() ~= "gamepad") or (not C.ShowGamepadTextInput("", 20, slidercellElement.cur, false, false)) then
		C.ActivateDirectInput()
	end

	CallWidgetEventScripts(slidercellID, "onSliderCellActivated")
end

function widgetSystem.deactivateSliderCellInput(slidercellElement)
	C.DeactivateDirectInput()
	
	-- need to do this first, because the addon listing to "onSliderCellDeactivated", etc. could invalidate the oldInteractiveElement data
	if private.oldInteractiveElement ~= nil then
		local frameentry = private.associationList[private.oldInteractiveElement.frameID]
		if frameentry and IsValidWidgetElement(private.oldInteractiveElement.frameID) then
			widgetSystem.setActiveFrame(frameentry.element)
			widgetSystem.setInteractiveElement(private.oldInteractiveElement.frameID, private.oldInteractiveElement.widgetID)
			if private.oldInteractiveElement.element.interactiveChild ~= nil then
				local entry = private.associationList[private.oldInteractiveElement.element.interactiveChild.widgetID]
				if entry then
					widgetSystem.setInteractiveChildElement(private.oldInteractiveElement.widgetID, private.oldInteractiveElement.element, private.oldInteractiveElement.element.interactiveChild.row, private.oldInteractiveElement.element.interactiveChild.col, private.oldInteractiveElement.element.interactiveChild.widgetID, entry.element)
				end
			end
		end
	end
	private.oldInteractiveElement = nil

	slidercellElement.inputActive = false
	slidercellElement.oldcur = nil
	slidercellElement.cursor = false
	widgetSystem.updateSliderCellValue(slidercellElement)
	private.activeSliderCell = nil
end

function widgetSystem.confirmSliderCellInputInternal(slidercellID, slidercellElement)
	if not tonumber(slidercellElement.cur) then
		widgetSystem.setSliderCellCurValue(slidercellElement, slidercellElement.oldcur, false, true)
	else
		-- TODO Florian - Make optional if we want to allow finer controls via keyboard input
		widgetSystem.setSliderCellCurValue(slidercellElement, math.floor(slidercellElement.cur / slidercellElement.step + 0.5) * slidercellElement.step, true, true)
	end
	
	CallWidgetEventScripts(slidercellID, "onSliderCellDeactivated", slidercellElement.cur, slidercellElement.cur ~= slidercellElement.oldcur)
	widgetSystem.deactivateSliderCellInput(slidercellElement)

	CallWidgetEventScripts(slidercellID, "onSliderCellConfirm", slidercellElement.cur, slidercellElement.cur ~= slidercellElement.oldcur)
end

function widgetSystem.cancelSliderCellInputInternal(slidercellID, slidercellElement)
	if slidercellElement.oldcur ~= slidercellElement.cur then
		widgetSystem.setSliderCellCurValue(slidercellElement, slidercellElement.oldcur, false, true)
		widgetSystem.updateSliderCellValue(slidercellElement)
	end

	CallWidgetEventScripts(slidercellID, "onSliderCellDeactivated", slidercellElement.cur, slidercellElement.cur ~= slidercellElement.oldcur)
	widgetSystem.deactivateSliderCellInput(slidercellElement)

	CallWidgetEventScripts(slidercellID, "onSliderCellConfirm", slidercellElement.cur, slidercellElement.cur ~= slidercellElement.oldcur)
end

function widgetSystem.updateSliderCellCursor(slidercellElement, curTime)
	if slidercellElement.lastcursorupdatetime + config.slidercell.cursorBlinkInterval < curTime then
		slidercellElement.lastcursorupdatetime = curTime
		slidercellElement.cursor = not slidercellElement.cursor
		widgetSystem.updateSliderCellValue(slidercellElement)
	end
end

function widgetSystem.updateFontString(fontstringID, textcomponent, textelement, activeSlide, inactiveSlide, curSlide)
	local text						= GetText(fontstringID)
	local font, size				= GetFont(fontstringID)
	local fontheight				= widgetSystem.getFontHeight(font, size)
	local title						= C.IsTitleFontString(fontstringID)
	local textwidth					= GetSize(fontstringID)
	local red, green, blue, alpha	= GetColor(fontstringID)
	local wordwrap					= GetWordWrap(fontstringID)

	if text == "" then
		if curSlide ~= inactiveSlide then
			goToSlide(textcomponent, inactiveSlide)
			local textentry = private.associationList[fontstringID]
			textentry.curSlide = inactiveSlide
		end
		return fontheight, text -- no need to set anything here, if no text is displayed
	end

	if curSlide ~= activeSlide then
		goToSlide(textcomponent, activeSlide)
		local textentry = private.associationList[fontstringID]
		textentry.curSlide = activeSlide
	end

	local glowfactor              = C.GetFontStringGlowFactor(fontstringID)

	setAttribute(textelement, "textstring", text)
	setAttribute(textelement, "font", font)
	setAttribute(textelement, "size", size)
	setAttribute(textelement, "textcolor.r", red)
	setAttribute(textelement, "textcolor.g", green)
	setAttribute(textelement, "textcolor.b", blue)
	setAttribute(textelement, "opacity", alpha)
	setAttribute(textelement, "boxwidth", textwidth / config.nativePresentationWidth)
	setAttribute(textelement, "glowfactor", glowfactor)

	if title then
		local color = ffi.new("Color")
		if C.GetFontStringTitleColor(fontstringID, color) then
			local material = getElement("titleline.material", textcomponent)
			SetDiffuseColor(material, color.red, color.green, color.blue)
			setAttribute(material, "opacity", color.alpha)
			setAttribute(material, "glowfactor", C.GetFontStringTitleGlowFactor(fontstringID))
		end
	end
	
	if not wordwrap then
		local truncatedtext = TruncateText(text, font, size, textwidth)
		if text ~= truncatedtext then
			local untruncatedText = text:gsub("^%s*", "") -- delete leading whitespaces
			C.SetMouseOverTextAdditional(fontstringID, untruncatedText)
		end
	end

	return fontheight, text
end

function widgetSystem.updateIcon(iconID, iconelement, parentx, parenty, parentwidth)
	local x, y = GetOffset(iconID)
	local width, height = GetSize(iconID)
	-- an icon is positioned relative to the icon's center --- hence we've to substract half the icon's extents to properly position it according to the icon's upper left corner
	x = x + width/2
	y = -y

	local textinfo = ffi.new("TextInfo")
	local hastext = C.GetIconTextDetails(iconID, textinfo)
	local textinfo2 = ffi.new("TextInfo")
	local hastext2 = C.GetIconText2Details(iconID, textinfo2)

	if hastext or hastext2 then
		if hastext then
			local alignment = ffi.string(textinfo.alignment)
			-- calculate horizontal offset for proper alignment
			local textXOffset = textinfo.x
			local textYOffset = height / 2 - textinfo.y
			if alignment == "left" then
				textXOffset = textXOffset
			elseif alignment == "center" then
				-- nothing to do
			else -- right
				textXOffset = parentwidth - textXOffset
			end

			local textelement = getElement("Text", iconelement)

			widgetSystem.setElementPosition(textelement, textXOffset, textYOffset)
			setAttribute(textelement, "horzalign", widgetSystem.convertAlignment(alignment))
			-- text font
			setAttribute(textelement, "font", ffi.string(textinfo.font.name))
			setAttribute(textelement, "size", textinfo.font.size)
			setAttribute(textelement, "textstring", ffi.string(textinfo.text))

			setAttribute(textelement, "textcolor.r", textinfo.color.red)
			setAttribute(textelement, "textcolor.g", textinfo.color.green)
			setAttribute(textelement, "textcolor.b", textinfo.color.blue)
			setAttribute(textelement, "opacity", textinfo.color.alpha)
			setAttribute(textelement, "glowfactor", textinfo.glowfactor)
		else
			local textelement = getElement("Text", iconelement)
			setAttribute(textelement, "textstring", "")
		end

		if hastext2 then
			local alignment = ffi.string(textinfo2.alignment)
			-- calculate horizontal offset for proper alignment
			local textXOffset = textinfo2.x
			local textYOffset = height / 2 - textinfo2.y
			if alignment == "left" then
				textXOffset = textXOffset
			elseif alignment == "center" then
				-- nothing to do
			else -- right
				textXOffset = parentwidth - textXOffset
			end

			local textelement = getElement("Text2", iconelement)

			widgetSystem.setElementPosition(textelement, textXOffset, textYOffset)
			setAttribute(textelement, "horzalign", widgetSystem.convertAlignment(alignment))
			-- text font
			setAttribute(textelement, "font", ffi.string(textinfo2.font.name))
			setAttribute(textelement, "size", textinfo2.font.size)
			setAttribute(textelement, "textstring", ffi.string(textinfo2.text))

			setAttribute(textelement, "textcolor.r", textinfo2.color.red)
			setAttribute(textelement, "textcolor.g", textinfo2.color.green)
			setAttribute(textelement, "textcolor.b", textinfo2.color.blue)
			setAttribute(textelement, "opacity", textinfo2.color.alpha)
			setAttribute(textelement, "glowfactor", textinfo2.glowfactor)
		else
			local textelement = getElement("Text2", iconelement)
			setAttribute(textelement, "textstring", "")
		end
	end

	local iconsubelement = getElement("icon", iconelement)
	widgetSystem.setElementPosition(iconsubelement, x, y, width % 2 ~= 0, height % 2 ~= 0)

	local texturename, red, green, blue, alpha = GetIconDetails(iconID)
	local glowfactor = C.GetIconGlowFactor(iconID)

	if parentwidth < width then
		DebugError("Widget system error. The given icon width for icon '"..tostring(texturename).."' exceeds the maximum available width ("..tostring(width)..") of the parent ("..tostring(parentwidth).."). The icon will overlap the parent.")
	end

	local material = getElement("icon.icon", iconelement)
	SetIcon(getElement("icon", material), texturename, red, green, blue, false, width, height)
	-- #StefanLow --- better add support to SetIcon() to set the alpha too
	setAttribute(material, "opacity", alpha)
	setAttribute(material, "glowfactor", glowfactor)
end

-- moves the scrollbar to the new center pos (which is the current mouse position minus the drag start offset pos)
-- #StefanLow - might actually be a good idea to combine with slider-scrolling behavior (see XT-2184)
function widgetSystem.updateScrollBarPos(tableElement)
	local _, y = GetLocalMousePosition()
	if y == nil then
		return -- outside the widget frame
	end

	-- check whether the mouse cursor was moved by a relevant factor
	if tableElement.scrollBar.previousMousePos ~= nil and math.abs(tableElement.scrollBar.previousMousePos - y) < config.mouseScrollBarThreshold then
		return -- mouse hasn't been moved between previous and current call - no mouse change => nothing to do
	end
	
	-- Note: we must take into account whether the mouse was moved up or down here, since we actually do not perform pixel-exact scrolling of the slider.
	-- That means: The slider position always represents the current position of the table and we scroll the table already as if we'd have dragged the slider half way to the previous/next row.
	-- At that point the slider would jump and the drag position might be above/below the current mouse position. If we'd just compare the difference of the drag position the next time the mouse is moved up/down
	-- we could end up with incorrectly determining that we'd moved the bar down/up -> results in inversed scrollbar movement (was cause of XT-3967)
	local moveDown = tableElement.scrollBar.previousMousePos ~= nil and tableElement.scrollBar.previousMousePos > y

	tableElement.scrollBar.previousMousePos = y

	local newSliderPos = y - tableElement.scrollBar.dragOffset
	local curSliderPos = widgetSystem.getScrollBarSliderPosition(tableElement.scrollBar.element)
	local valueDiff = newSliderPos - curSliderPos
	local pixelsInTableToScroll = tableElement.scrollBar.valuePerPixel * valueDiff

	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)
	local stepsToScroll = widgetSystem.calculateRowsToMoveByPixelDiff(tableID, tableElement, pixelsInTableToScroll)

	if stepsToScroll > 0 then
		if valueDiff > 0 then
			if not moveDown then
				widgetSystem.scrollUp(tableID, tableElement, stepsToScroll)
			end
		elseif valueDiff < 0 then
			if moveDown then
				widgetSystem.scrollDown(tableID, tableElement, stepsToScroll)
			end
		end
	end
end

function widgetSystem.updateShieldHullBar(shieldHullBarElement, shieldHullBarID)
	local shieldPercent = math.min(math.max(C.GetShieldHullBarShieldPercent(shieldHullBarID), 0), 100)
	local shieldBar = getElement("top", shieldHullBarElement)
	widgetSystem.setElementScale(shieldBar, shieldPercent / 100, nil)

	local hullPercent = math.min(math.max(C.GetShieldHullBarHullPercent(shieldHullBarID), 0), 100)
	local hullBar = getElement("bottom", shieldHullBarElement)
	widgetSystem.setElementScale(hullBar, hullPercent / 100, nil)

	local glowfactor = C.GetShieldHullBarGlowFactor(shieldHullBarID)
	local material = getElement("top.material", shieldHullBarElement)
	setAttribute(material, "glowfactor", glowfactor)
	local material = getElement("bottom.material", shieldHullBarElement)
	setAttribute(material, "glowfactor", glowfactor)
end

function widgetSystem.updateStatusBar(statusBarElement, statusBarID)
	local current = C.GetStatusBarCurrentValue(statusBarID)
	local start = C.GetStatusBarStartValue(statusBarID)
	local max = C.GetStatusBarMaxValue(statusBarID)

	local slide = "normal"
	local isNegative = true
	if current >= start then
		isNegative = false
		if current == start then
			slide = "nochange"
		end
	end

	goToSlide(statusBarElement.element, slide)

	-- marker
	local minMarkerPosition = (-statusBarElement.width + config.statusbar.markerWidth) / 2
	local maxMarkerPosition = ( statusBarElement.width - config.statusbar.markerWidth) / 2

	local markerposition = (statusBarElement.width - config.statusbar.markerWidth) / 2
	local neededMax = math.max(current, start)
	if neededMax >= max then
		if neededMax > 0 then
			markerposition = math.max(minMarkerPosition, math.min(maxMarkerPosition, math.floor(statusBarElement.width * (max / neededMax - 0.5))))
			max = neededMax
		else
			markerposition = minMarkerPosition
			max = 1
		end
	end

	local marker = getElement("marker", statusBarElement.element)
	widgetSystem.setElementScale(marker, config.statusbar.markerWidth / 100, statusBarElement.height / 100)
	widgetSystem.setElementPosition(marker, markerposition, nil, (statusBarElement.width % 2 ~= 0), (statusBarElement.height % 2 ~= 0))

	-- value
	local valueWidth
	if isNegative then
		valueWidth =  current / max
	else
		valueWidth = start / max
	end
	valueWidth = valueWidth * statusBarElement.width

	local valueBar = getElement("value", statusBarElement.element)
	widgetSystem.setElementScale(valueBar, valueWidth / 100, statusBarElement.height / 100)
	widgetSystem.setElementPosition(valueBar, (valueWidth - statusBarElement.width) / 2, nil, (statusBarElement.width % 2 ~= 0), (statusBarElement.height % 2 ~= 0))

	-- change
	local changeWidth
	if isNegative then
		changeWidth = (start - current) / max
	else
		changeWidth = (current - start) / max
	end
	changeWidth = changeWidth * statusBarElement.width

	local changeBar = getElement("change", statusBarElement.element)
	widgetSystem.setElementScale(changeBar, changeWidth / 100, statusBarElement.height / 100)
	widgetSystem.setElementPosition(changeBar, (changeWidth - statusBarElement.width) / 2 + valueWidth, nil, (statusBarElement.width % 2 ~= 0), (statusBarElement.height % 2 ~= 0))

	-- colors
	local color = ffi.new("Color")
	if C.GetStatusBarValueColor(statusBarID, color) then
		local material = getElement("value.Material1097", statusBarElement.element)
		SetDiffuseColor(material, color.red, color.green, color.blue)
		setAttribute(material, "opacity", color.alpha)
		setAttribute(material, "glowfactor", C.GetStatusBarValueGlowFactor(statusBarID))
	end

	local color = ffi.new("Color")
	if C.GetStatusBarMarkerColor(statusBarID, color) then
		local material = getElement("marker.Material1109", statusBarElement.element)
		SetDiffuseColor(material, color.red, color.green, color.blue)
		setAttribute(material, "opacity", color.alpha)
		setAttribute(material, "glowfactor", C.GetStatusBarMarkerGlowFactor(statusBarID))
	end

	if isNegative then
		local color = ffi.new("Color")
		if C.GetStatusBarNegChangeColor(statusBarID, color) then
			local material = getElement("change.Material1103", statusBarElement.element)
			SetDiffuseColor(material, color.red, color.green, color.blue)
			setAttribute(material, "opacity", color.alpha)
			setAttribute(material, "glowfactor", C.GetStatusBarNegChangeGlowFactor(statusBarID))
		end
	else
		local color = ffi.new("Color")
		if C.GetStatusBarPosChangeColor(statusBarID, color) then
			local material = getElement("change.Material1103", statusBarElement.element)
			SetDiffuseColor(material, color.red, color.green, color.blue)
			setAttribute(material, "opacity", color.alpha)
			setAttribute(material, "glowfactor", C.GetStatusBarPosChangeGlowFactor(statusBarID))
		end
	end
end

-- #StefanMed combine with generic button-state-handling?
function widgetSystem.updateStandardButtonState(frameElement, button)
	local stateEntry = frameElement.standardButtonState[button]
	local buttonActive = frameElement[button .. "ButtonShown"]
	local element = frameElement[button .. "Element"]

	local targetSlide = "inactive"
	if buttonActive then
		-- only activate the button, if the button is actually active
		if stateEntry.mouseClick then
			targetSlide = "click"
		elseif stateEntry.mouseOver then
			targetSlide = "highlight"
		else
			targetSlide = "normal"
		end
	end

	if stateEntry.curSlide ~= targetSlide then
		goToSlide(element, targetSlide)
		stateEntry.curSlide = targetSlide

		if targetSlide == "normal" then
			local color = Color["button_content_default"]
			local bgcolor = Color["button_background_inactive"]

			local bgElement = getElement("background.Material397", element)
			SetDiffuseColor(bgElement, bgcolor.r, bgcolor.g, bgcolor.b)
			setAttribute(bgElement, "opacity", bgcolor.a)
			
			for _, materialref in ipairs(frameElement[button .. "Materials"]) do
				local material = getElement(materialref, element)
				SetDiffuseColor(material, color.r, color.g, color.b)
				setAttribute(material, "opacity", color.a)
				setAttribute(material, "glowfactor", color.glow)
			end
		end
	end
end

function widgetSystem.updateTable(tableID, tableElement, shiftRows, newRow, modified)
	if not IsValidWidgetElement(tableID) then
		return -- can happen if a table/view is closed before this is processed
	end

	if shiftRows ~= 0 then
		-- redraw shifted table
		local frameElement = widgetSystem.getFrameElementByTableElement(tableElement)
		widgetSystem.drawTableCells(frameElement, tableID, tableElement, tableElement.topRow + shiftRows, tableElement.numRows, newRow, false, modified)

		-- #StefanLow --- move the scrollbar according to table row height, not table row number
		local range   = tableElement.numRows - tableElement.topBottomRow
		local percent = (tableElement.bottomRow - tableElement.topBottomRow) / range
		percent = math.max(0, percent)
		widgetSystem.updateVerticalScrollBar(tableElement.scrollBar, percent)
	else
		-- we do not need to redraw the entire table, but we still need to update the selected row
		widgetSystem.selectRowInternal(tableID, tableElement, newRow, modified, nil, "user")
	end
end

-- scrollBar   = the scrollbar element
-- relativePos = relative position of the represented element (0..1)
function widgetSystem.updateVerticalScrollBar(scrollBar, relativePos)
	if not scrollBar.active then
		return	-- scrollbar inactive, nothing to update
	end

	-- calculate the range we can move the scrollbar (which is scrollbar height minus height of the scroll bar itself)
	local range = scrollBar.height - scrollBar.sliderHeight
	-- relative pos specifies a value between 0 and 1, defining the position relative to the start, where the scrollbar is to be positioned
	local scrollBarPos = range * relativePos

	-- position slider element
	widgetSystem.setElementPosition(scrollBar.sliderElement, nil, -scrollBarPos - scrollBar.sliderHeight / 2 + scrollBar.height / 2)
end

-- scrollBar   = the scrollbar element
-- relativePos = relative position of the represented element (0..1)
function widgetSystem.updateHorizontalScrollBar(scrollBar, relativePos)
	if not scrollBar.active then
		return	-- scrollbar inactive, nothing to update
	end

	-- calculate the range we can move the scrollbar (which is scrollbar width minus width of the scroll bar itself)
	local range = scrollBar.width - scrollBar.sliderWidth
	-- relative pos specifies a value between 0 and 1, defining the position relative to the start, where the scrollbar is to be positioned
	local scrollBarPos = range * relativePos

	-- position slider element
	widgetSystem.setElementPosition(scrollBar.sliderElement, scrollBarPos + scrollBar.sliderWidth / 2 - scrollBar.width / 2, nil)
end

function widgetSystem.queueShapeDraw(type, ...)
	if not private.shapesActivated then
		widgetSystem.setSceneState("shapes", true)
		private.shapesActivated = true
	end

	local id, anarkElement
	if type == "circle" then
		id, anarkElement = widgetSystem.getShapeElement("circle")
		if anarkElement == nil then
			DebugError("Widget system error. Already displaying "..config.shapes.circle.maxElements.." circle elements. Cannot display more. Circle will be skipped.")
			return
		end
		private.drawnShapes.circles[id] = anarkElement
	elseif type == "rectangle" then
		id, anarkElement = widgetSystem.getShapeElement("rectangle")
		if anarkElement == nil then
			DebugError("Widget system error. Already displaying "..config.shapes.rectangle.maxElements.." rectangle elements. Cannot display more. Rectangle will be skipped.")
			return
		end
		private.drawnShapes.rectangles[id] = anarkElement
	elseif type == "triangle" then
		id, anarkElement = widgetSystem.getShapeElement("triangle")
		if anarkElement == nil then
			DebugError("Widget system error. Already displaying "..config.shapes.triangle.maxElements.." triangle elements. Cannot display more. Triangle will be skipped.")
			return
		end
		private.drawnShapes.triangles[id] = anarkElement
	else
		DebugError("Widget system error. Unknown shape type, shape will be skipped.")
		return
	end
	table.insert(private.queuedShapes, { type = type, id = id, params = table.pack(...) })

	return id
end

function widgetSystem.updateShapes()
	for _, queuedShape in ipairs(private.queuedShapes) do
		if queuedShape.type == "circle" then
			widgetSystem.drawCircle(queuedShape.id, table.unpack(queuedShape.params))
		elseif queuedShape.type == "rectangle" then
			widgetSystem.drawRect(queuedShape.id, table.unpack(queuedShape.params))
		elseif queuedShape.type == "triangle" then
			widgetSystem.drawTriangle(queuedShape.id, table.unpack(queuedShape.params))
		end
	end
	private.queuedShapes = {}

	if not next(private.drawnShapes.circles) and not next(private.drawnShapes.rectangles) and not next(private.drawnShapes.triangles) then
		if private.shapesActivated then
			widgetSystem.setSceneState("shapes", false)
			private.shapesActivated = false
		end
	end
end

function widgetSystem.drawCircle(id, radiusx, radiusy, centerx, centery, z, color)
	local anarkElement = private.drawnShapes.circles[id]

	-- position, scale and rotation
	widgetSystem.setElementPosition(anarkElement, centerx, centery)
	setAttribute(anarkElement, "position.z", z)
	-- scale is cross-section, so we get an additional factor 2
	widgetSystem.setElementScale(anarkElement, radiusx / 50, radiusy / 50)

	-- color
	local element = getElement("Cylinder.Material425", anarkElement)
	SetDiffuseColor(element, color.r, color.g, color.b)
	setAttribute(element, "opacity", color.a)

	-- display
	goToSlide(anarkElement, "active")
end

function widgetSystem.drawRect(id, width, height, offsetx, offsety, angle, z, color)
	local anarkElement = private.drawnShapes.rectangles[id]

	offsetx = offsetx + width / 2
	offsety = offsety - height / 2

	-- position, scale and rotation
	widgetSystem.setElementPosition(anarkElement, offsetx, offsety)
	setAttribute(anarkElement, "position.z", z)
	widgetSystem.setElementScale(anarkElement, width / 100, height / 100)
	widgetSystem.setElementRotation(anarkElement, angle)

	-- color
	local element = getElement("Rectangle.Material1946", anarkElement)
	SetDiffuseColor(element, color.r, color.g, color.b)
	setAttribute(element, "opacity", color.a)

	-- display
	goToSlide(anarkElement, "active")
end

function widgetSystem.drawTriangle(id, width, height, offsetx, offsety, angle, z, color)
	local anarkElement = private.drawnShapes.triangles[id]

	offsetx = offsetx + width / 2
	offsety = offsety - height

	-- position, scale and rotation
	widgetSystem.setElementPosition(anarkElement, offsetx, offsety)
	setAttribute(anarkElement, "position.z", z)
	widgetSystem.setElementScale(anarkElement, width / 100, height / 100)
	widgetSystem.setElementRotation(anarkElement, angle)

	-- color
	local element = getElement("Cone.Material481", anarkElement)
	SetDiffuseColor(element, color.r, color.g, color.b)
	setAttribute(element, "opacity", color.a)

	-- display
	goToSlide(anarkElement, "active")
end

function widgetSystem.hideCircle(id)
	local element = private.drawnShapes.circles[id]
	if element ~= nil then
		goToSlide(element, "inactive")
		table.insert(private.element.shapes.circle, {id, element})
		private.drawnShapes.circles[id] = nil
	else
		DebugError("Widget system error. Cannot find circle with id " .. id)
	end
end

function widgetSystem.hideRect(id)
	local element = private.drawnShapes.rectangles[id]
	if element ~= nil then
		goToSlide(element, "inactive")
		table.insert(private.element.shapes.rectangle, {id, element})
		private.drawnShapes.rectangles[id] = nil
	else
		DebugError("Widget system error. Cannot find rectangle with id " .. id)
	end
end

function widgetSystem.hideTriangle(id)
	local element = private.drawnShapes.triangles[id]
	if element ~= nil then
		goToSlide(element, "inactive")
		table.insert(private.element.shapes.triangle, {id, element})
		private.drawnShapes.triangles[id] = nil
	else
		DebugError("Widget system error. Cannot find triangle with id " .. id)
	end
end

function widgetSystem.hideAllShapes()
	if private.shapesActivated then
		widgetSystem.hideCircles()
		widgetSystem.hideRects()
		widgetSystem.hideTriangles()
	
		widgetSystem.setSceneState("shapes", false)
		private.shapesActivated = false
	end
end

function widgetSystem.hideCircles()
	for id, element in pairs(private.drawnShapes.circles) do
		goToSlide(element, "inactive")
		table.insert(private.element.shapes.circle, {id, element})
	end
	
	private.drawnShapes.circles = {}
end

function widgetSystem.hideRects()
	for id, element in pairs(private.drawnShapes.rectangles) do
		goToSlide(element, "inactive")
		table.insert(private.element.shapes.rectangle, {id, element})
	end
	
	private.drawnShapes.rectangles = {}
end

function widgetSystem.hideTriangles()
	for id, element in pairs(private.drawnShapes.triangles) do
		goToSlide(element, "inactive")
		table.insert(private.element.shapes.triangle, {id, element})
	end
	
	private.drawnShapes.triangles = {}
end

function widgetSystem.getWidgetSystemSize()
	return private.width, private.height
end

private.overlayAssociation = {}

function widgetSystem.addHelpOverlay(frameElement, widgetID, x, y, width, height, standardbutton, backgroundcolspanwidth, overrideinfo)
	local overlayinfo = {}
	local ffioverlayinfo
	if overrideinfo then
		ffioverlayinfo = overrideinfo
	elseif standardbutton then
		ffioverlayinfo = C.GetStandardButtonHelpOverlayInfo2(widgetID, standardbutton)
	else
		ffioverlayinfo = C.GetHelpOverlayInfo2(widgetID)
	end
	overlayinfo.id = ffi.string(ffioverlayinfo.id)
	if overlayinfo.id ~= "" then
		private.overlayAssociation[overlayinfo.id] = frameElement
		overlayinfo.text	= ffi.string(ffioverlayinfo.text)
		if overlayinfo.text ~= "" then
			overlayinfo.usebackgroundspan = ffioverlayinfo.usebackgroundspan
			overlayinfo.x		= ffioverlayinfo.x ~= 0 and (ffioverlayinfo.x - private.width / 2) or x
			overlayinfo.y		= ffioverlayinfo.y ~= 0 and (private.height / 2 - ffioverlayinfo.y) or y
			local overlaywidth = width
			if backgroundcolspanwidth and overlayinfo.usebackgroundspan then
				overlaywidth = backgroundcolspanwidth + 2 * config.table.bordersize
			end
			overlayinfo.width	= ffioverlayinfo.width ~= 0 and ffioverlayinfo.width or overlaywidth
			overlayinfo.height	= ffioverlayinfo.height ~= 0 and ffioverlayinfo.height or height
			overlayinfo.highlightonly = ffioverlayinfo.highlightonly
			private.helpOverlays[overlayinfo.id] = { widgetID = widgetID, overlayinfo = overlayinfo }

			if private.displayedHelpOverlays[overlayinfo.id] then
				widgetSystem.updateHelpOverlay(private.displayedHelpOverlays[overlayinfo.id].element, overlayinfo)
			elseif (private.helpOverlayDisplayed and (not overlayinfo.highlightonly)) or private.signalledHelpOverlays[overlayinfo.id] then
				widgetSystem.showHelpOverlayID(overlayinfo.id, (not private.helpOverlayDisplayed) and private.signalledHelpOverlays[overlayinfo.id].borderonly)
			end
		else
			private.helpOverlays[overlayinfo.id] = nil
			if private.displayedHelpOverlays[overlayinfo.id] then
				widgetSystem.hideHelpOverlayID(overlayinfo.id)
			end
		end
	end
end

function widgetSystem.removeHelpOverlayID(overlayID)
	private.helpOverlays[overlayID] = nil
	if private.displayedHelpOverlays[overlayID] then
		widgetSystem.hideHelpOverlayID(overlayID)
	end
	private.overlayAssociation[overlayID] = nil
end

function widgetSystem.clearHelpOverlays(frameElement)
	if frameElement then
		for overlayID, element in pairs(private.overlayAssociation) do
			if element == frameElement then
				widgetSystem.removeHelpOverlayID(overlayID)
			end
		end
		if not next(private.helpOverlays) then
			widgetSystem.setHelpOverlayDisplayed(false)
		end
	else
		private.helpOverlays = {}
		widgetSystem.setHelpOverlayDisplayed(false)
		private.overlayAssociation = {}
	end
end

function widgetSystem.toggleHelpOverlay()
	if private.helpOverlayDisplayed then
		widgetSystem.hideHelpOverlay()
	else
		widgetSystem.showHelpOverlay()
	end
end

function widgetSystem.showHelpOverlay()
	if next(private.helpOverlays) then
		widgetSystem.setHelpOverlayDisplayed(true)
	end

	for id, entry in pairs(private.helpOverlays) do
		if not entry.overlayinfo.highlightonly then
			widgetSystem.showHelpOverlayID(id)
		end
	end

	AddUITriggeredEvent("helpoverlay", "shown")
end

function widgetSystem.showHelpOverlayID(id, borderonly)
	if not private.helpOverlays[id] then
		-- not available, nothing to do
		return
	end
	if private.displayedHelpOverlays[id] and ((private.displayedHelpOverlays[id].borderonly == borderonly) or private.helpOverlayDisplayed) then
		-- already displayed, nothing to do
		return
	end
	local helpOverlayElement
	if private.displayedHelpOverlays[id] then
		helpOverlayElement = private.displayedHelpOverlays[id].element
	else
		helpOverlayElement = widgetSystem.getElement("helpoverlay")
	end
	if helpOverlayElement ~= nil then
		if borderonly then
			goToSlide(helpOverlayElement, "reduced")
		else
			goToSlide(helpOverlayElement, "normal")
		end

		local overlayinfo = private.helpOverlays[id].overlayinfo

		widgetSystem.updateHelpOverlay(helpOverlayElement, overlayinfo)

		local iconsize = config.helpoverlay.iconsize * private.uiscale
		if not borderonly then
			local iconx, icony = 0, 0
			if (3 * iconsize > overlayinfo.width) or (3 * iconsize > overlayinfo.height) then
				iconsize = iconsize / 2
				iconx = (-overlayinfo.width + config.helpoverlay.iconToSizeRatio * iconsize / math.sqrt(2)) / 2
				icony = (overlayinfo.height - config.helpoverlay.iconToSizeRatio * iconsize / math.sqrt(2)) / 2
			end

			local icon = getElement("icon", helpOverlayElement)
			widgetSystem.setElementPosition(icon, iconx, icony, (iconx % 2 ~= 0), (icony % 2 ~= 0))
		end

		widgetSystem.updateHelpOverlayColor(helpOverlayElement, private.helpOverlayStates[id], iconsize, borderonly, getElapsedTime())

		private.displayedHelpOverlays[id] = { element = helpOverlayElement, mouseOver = private.helpOverlayStates[id], iconsize = iconsize, borderonly = borderonly }
	else
		if private.miniWidgetSystemUsed then
			DebugError("Widget system error. Help overlay is not supported in mini widgetsystem. Helper overlay ".. id .." will be skipped.")
		else
			DebugError("Widget system error. Already displaying "..config.helpoverlay.maxElements.." help overlay(s). Cannot display more. Help overlay ".. id .." will be skipped.")
		end
	end
end

function widgetSystem.hideHelpOverlay(keepsignals)
	widgetSystem.setHelpOverlayDisplayed(false)
	if next(private.displayedHelpOverlays) then
		AddUITriggeredEvent("helpoverlay", "hidden")
	end

	for id, entry in pairs(private.displayedHelpOverlays) do
		goToSlide(entry.element, "inactive")
		if entry.mouseOver then
			private.mouseOverOverrideText = nil
		end
		table.insert(private.element.helpoverlay, entry.element)
	end
	private.displayedHelpOverlays = {}
	if not keepsignals then
		private.signalledHelpOverlays = {}
	end
end

function widgetSystem.hideHelpOverlayID(id)
	if not private.displayedHelpOverlays[id] then
		-- nothing to do
		return
	end
	local entry = private.displayedHelpOverlays[id]
	goToSlide(entry.element, "inactive")
	if entry.mouseOver then
		private.mouseOverOverrideText = nil
	end
	table.insert(private.element.helpoverlay, entry.element)
	private.displayedHelpOverlays[id] = nil

	AddUITriggeredEvent("helpoverlay", id)
end

function widgetSystem.updateHelpOverlay(helpOverlayElement, overlayinfo)
	local x			= overlayinfo.x
	local y			= overlayinfo.y
	local width		= overlayinfo.width
	local height	= overlayinfo.height
	local color		= Color["helpoverlay_border"]
	-- position
	widgetSystem.setElementPosition(helpOverlayElement, x + width / 2, y - height / 2, (x % 2 ~= 0), (y % 2 ~= 0))
	-- frame
	for _, element in ipairs(config.helpoverlay.borderElements) do
		local anarkElement = getElement(element, helpOverlayElement)
		if element == "border_left" then
			widgetSystem.setElementPosition(anarkElement, -width / 2 + config.helpoverlay.borderSize, 0, (width % 2 ~= 0), (height % 2 ~= 0))
			widgetSystem.setElementScale(anarkElement, config.helpoverlay.borderSize / 100, (height - 2 * config.helpoverlay.borderSize) / 100)
		elseif element == "border_right" then
			widgetSystem.setElementPosition(anarkElement, width / 2, 0, (width % 2 ~= 0), (height % 2 ~= 0))
			widgetSystem.setElementScale(anarkElement, config.helpoverlay.borderSize / 100, (height - 2 * config.helpoverlay.borderSize) / 100)
		elseif element == "border_bottom" then
			widgetSystem.setElementPosition(anarkElement, config.helpoverlay.borderSize / 2, (height - config.helpoverlay.borderSize) / 2, (width % 2 ~= 0), ((height - config.helpoverlay.borderSize) % 2 ~= 0))
			widgetSystem.setElementScale(anarkElement, width / 100, config.helpoverlay.borderSize / 100)
		elseif element == "border_top" then
			widgetSystem.setElementPosition(anarkElement, config.helpoverlay.borderSize / 2, -(height - config.helpoverlay.borderSize) / 2, (width % 2 ~= 0), ((height - config.helpoverlay.borderSize) % 2 ~= 0))
			widgetSystem.setElementScale(anarkElement, width / 100, config.helpoverlay.borderSize / 100)
		end
	end
	-- background
	local bgElement = getElement("background", helpOverlayElement)
	color = Color["helpoverlay_background"]
	widgetSystem.setElementScale(bgElement, width / 100, height / 100)
	SetDiffuseColor(bgElement, color.r, color.g, color.b)
	setAttribute(bgElement, "opacity", color.a)
end

function widgetSystem.updateHelpOverlayColor(helpOverlayElement, highlight, iconsize, borderonly, curtime)
	local alphafactor = 1
	if borderonly then
		alphafactor = (math.sin(curtime * config.helpoverlay.animationFrequency) + 1) * (config.helpoverlay.animationMaxValue - config.helpoverlay.animationMinValue) / 2 + config.helpoverlay.animationMinValue
	end

	local icon = "tut_info"
	local color = Color["helpoverlay_border"]
	if highlight then
		icon = "tut_info_highlight"
		color = Color["helpoverlay_highlight"]
	end
	color = { r = color.r, g = color.g, b = color.b, a = color.a, glow = color.glow }
	color.a = color.a * alphafactor

	local material = getElement("icon.icon", helpOverlayElement)
	SetIcon(getElement("icon", material), icon, color.r, color.g, color.b, false, iconsize, iconsize)
	setAttribute(material, "opacity", color.a)
	setAttribute(material, "glowfactor", color.glow)

	for _, element in ipairs(config.helpoverlay.borderElements) do
		widgetSystem.setElementColorAlpha(getElement(element .. ".Material1119", helpOverlayElement), color)
	end
end

function widgetSystem.setHelpOverlayDisplayed(displayed)
	if private.helpOverlayDisplayed ~= displayed then
		private.helpOverlayDisplayed = displayed
		widgetSystem.updateHelpStandardButton()
	end
end

function widgetSystem.updateHelpStandardButton()
	local color = private.helpOverlayDisplayed and Color["button_content_default_inverse"] or Color["button_content_default"]
	local bgcolor = private.helpOverlayDisplayed and Color["helpoverlay_border"] or Color["button_background_inactive"]

	local frameElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.frames or private.frames
	for frameidx = 0, #frameElements do
		local frameElement = frameElements[frameidx]
		if frameElement and frameElement["helpButtonShown"] then
			local bgElement = getElement("background.Material397", frameElement["helpElement"])
			SetDiffuseColor(bgElement, bgcolor.r, bgcolor.g, bgcolor.b)
			setAttribute(bgElement, "opacity", bgcolor.a)
			
			for _, materialref in ipairs(frameElement["helpMaterials"]) do
				local material = getElement(materialref, frameElement["helpElement"])
				SetDiffuseColor(material, color.r, color.g, color.b)
				setAttribute(material, "opacity", color.a)
				setAttribute(material, "glowfactor", color.glow)
			end
		end
	end
end

-- global access
AddGlobalAccess("GetTopRow",							widgetSystem.getTopRow)
AddGlobalAccess("SelectColumn",							widgetSystem.selectColumn)
AddGlobalAccess("SelectRow",							widgetSystem.selectRowExternal)
AddGlobalAccess("GetSelectedRows",						widgetSystem.getSelectedRows)
AddGlobalAccess("SetSelectedRows",						widgetSystem.setSelectedRows)
AddGlobalAccess("SetTopRow",							widgetSystem.setTopRow)
AddGlobalAccess("GetRenderTargetTexture",				widgetSystem.getRenderTargetTexture)
AddGlobalAccess("GetRenderTargetMousePosition",			widgetSystem.getRenderTargetMousePosition)
AddGlobalAccess("GetUsableTableWidth",					widgetSystem.getUsableTableWidth)
AddGlobalAccess("ConfirmEditBoxInput",					widgetSystem.confirmEditBoxInput)
AddGlobalAccess("CancelEditBoxInput",					widgetSystem.cancelEditBoxInput)
AddGlobalAccess("ActivateEditBox",						widgetSystem.activateEditBox)
AddGlobalAccess("DrawRect",								function (...) return widgetSystem.queueShapeDraw("rectangle", ...) end)
AddGlobalAccess("HideRect",								widgetSystem.hideRect)
AddGlobalAccess("HideAllRects",							widgetSystem.hideRects)
AddGlobalAccess("DrawCircle",							function (...) return widgetSystem.queueShapeDraw("circle", ...) end)
AddGlobalAccess("HideCircle",							widgetSystem.hideCircle)
AddGlobalAccess("HideAllCircles",						widgetSystem.hideCircles)
AddGlobalAccess("DrawTriangle",							function (...) return widgetSystem.queueShapeDraw("triangle", ...) end)
AddGlobalAccess("HideTriangle",							widgetSystem.hideTriangle)
AddGlobalAccess("HideAllTriangles",						widgetSystem.hideTriangles)
AddGlobalAccess("HideAllShapes",						widgetSystem.hideAllShapes)
AddGlobalAccess("IsFullscreenWidgetSystem",				widgetSystem.isFullscreenMode)
AddGlobalAccess("SetMouseCursorOverride",				widgetSystem.setMouseCursorOverride)
AddGlobalAccess("SetMouseOverOverride",					widgetSystem.setMouseOverOverride)
AddGlobalAccess("CloseDropDownOptions",					widgetSystem.closeDropDownOptions)
AddGlobalAccess("GetWidgetSystemSize",					widgetSystem.getWidgetSystemSize)
AddGlobalAccess("SetSliderCellValue",					widgetSystem.setSliderCellValue)
AddGlobalAccess("GetShiftStartEndRow",					widgetSystem.getShiftStartEndRow)
AddGlobalAccess("GetFlowchartNodeExpandedFrameData",	widgetSystem.getFlowchartNodeExpandedFrameData)
AddGlobalAccess("GetFlowchartFirstVisibleCell",			widgetSystem.getFlowchartFirstVisibleCell)
AddGlobalAccess("GetFlowchartSelectedCell",				widgetSystem.getFlowchartSelectedCell)
AddGlobalAccess("ActivateSliderCellInput",				widgetSystem.activateSliderCellInput)
AddGlobalAccess("SelectGraphDataPoint",					widgetSystem.selectGraphDataPoint)
AddGlobalAccess("ShowHighlightOverlay",					widgetSystem.showHighlightOverlay)
AddGlobalAccess("RemoveHighlightOverlay",				widgetSystem.removeHelpOverlay)
AddGlobalAccess("SetRenderTargetNoise",					widgetSystem.setRenderTargetNoise)
AddGlobalAccess("GetCurrentMouseOverWidth",				widgetSystem.getCurrentMouseOverWidth)
AddGlobalAccess("GetCurrentMouseOverFont",				widgetSystem.getCurrentMouseOverFont)

------------------------------------
-- Addon-System related functions --
------------------------------------
-- global function definitions
-- SetScript([widget, ]handleType, function)
function SetScript(widget, handle, scriptFunction)
	-- shift parameter one element to the right, if we are working with two argument (i.e. SetScript(handle, scriptFunction))
	if scriptFunction == nil then
		scriptFunction = handle
		handle = widget
		widget = nil
	end

	if type(scriptFunction) ~= "function" then
		DebugError("Invalid call to SetScript(). Given script function must be a function but is '"..type(scriptFunction).."'")
		return
	end

	if type(handle) ~= "string" then
		DebugError("Invalid call to SetScript(). Given handle must be a string but is '"..type(handle).."'")
		return
	end

	if handle == "onUpdate" then
		if not addonSystem.insertUpdateScript(scriptFunction) then
			DebugError("Invalid call to SetScript(). Given onUpdate-function already registered.")
		end
		return
	elseif handle == "onHotkey" then
		if not addonSystem.insertHotkeyScript(scriptFunction) then
			DebugError("Invalid call to SetScript(). Given onHotkey-function already registered.")
		end
		return
	elseif handle == "onTabScroll" then
		if not addonSystem.insertTabScrollScript(scriptFunction) then
			DebugError("Invalid call to SetScript(). Given onTabScroll-function already registered.")
		end
		return
	elseif widget ~= nil then
		addonSystem.setWidgetScript(widget, handle, scriptFunction)
		return
	end

	DebugError("Invalid call to SetScript(). Invalid specified handle '"..tostring(handle).."'.")
end
MakeGlobalAvailable("SetScript")

-- RemoveScript([widget, ]handleType, function)
function RemoveScript(widget, handle, scriptFunction)
	-- shift parameter one element to the right, if we are working with two argument (i.e. RemoveScript(handle, scriptFunction))
	if scriptFunction == nil then
		scriptFunction = handle
		handle = widget
		widget = nil
	end

	if type(scriptFunction) ~= "function" then
		DebugError("Invalid call to RemoveScript(). Given script function must be a function but is '"..type(scriptFunction).."'")
		return
	end

	if type(handle) ~= "string" then
		DebugError("Invalid call to RemoveScript(). Given handle must be a string but is '"..type(handle).."'")
		return
	end

	if handle == "onUpdate" then
		if not addonSystem.removeUpdateScript(scriptFunction) then
			DebugError("Invalid call to RemoveScript(). Given onUpdate-function is not registered.")
		end
		return
	elseif handle == "onHotkey" then
		if not addonSystem.removeHotkeyScript(scriptFunction) then
			DebugError("Invalid call to RemoveScript(). Given onHotkey-function is not registered.")
		end
		return
	elseif handle == "onTabScroll" then
		if not addonSystem.removeTabScrollScript(scriptFunction) then
			DebugError("Invalid call to RemoveScript(). Given onTabScroll-function is not registered.")
		end
		return
	elseif widget ~= nil then
		addonSystem.removeWidgetScript(widget, handle, scriptFunction)
		return
	end
	-- intended to future support (for instance onInitialize, onEvent?, onMouseButtonClick?, etc.)

	DebugError("Invalid call to RemoveScript(). Invalid specified handle '"..tostring(handle).."'.")
end
MakeGlobalAvailable("RemoveScript")

-- RegisterEvent(eventName, function)
function RegisterEvent(eventName, scriptFunction)
	if type(scriptFunction) ~= "function" then
		DebugError("Invalid call to RegisterEvent(). Given script function must be a function but is '"..type(scriptFunction).."'")
		return
	end

	if type(eventName) ~= "string" then
		DebugError("Invalid call to RegisterEvent(). Given event name must be a string but is '"..type(eventName).."'")
		return
	end

	if not addonSystem.insertEventScript(eventName, scriptFunction) then
		DebugError("Invalid call to RegisterEvent(). Given function already registered for the event: '"..eventName.."'")
	end
end
MakeGlobalAvailable("RegisterEvent")

-- UnregisterEvent(eventName, function)
function UnregisterEvent(eventName, scriptFunction)
	if type(scriptFunction) ~= "function" then
		DebugError("Invalid call to UnregisterEvent(). Given script function must be a function but is '"..type(scriptFunction).."'")
		return
	end

	if type(eventName) ~= "string" then
		DebugError("Invalid call to UnregisterEvent(). Given event name must be a string but is '"..type(eventName).."'")
		return
	end

	if not addonSystem.removeEventScript(eventName, scriptFunction) then
		DebugError("Invalid call to UnregisterEvent(). Given function not registered for event: '"..eventName.."'")
	end
end
MakeGlobalAvailable("UnregisterEvent")

-- function hooks
-- functions meant to be used internally (private functions)
function CallEventScripts(eventName, argument1)
	local scriptTable = private.eventScripts[eventName]
	if scriptTable == nil then
		return -- no registered scripts, nothing to do
	end

	local success, errorMessage
	for _, curFunction in ipairs(scriptTable) do
		success, errorMessage = pcall(curFunction, eventName, argument1)
		if not success then
			DebugError("Error while executing onEvent script for event: "..eventName..".\nErrormessage: "..tostring(errorMessage))
		end
	end
end
MakeGlobalAvailable("CallEventScripts")

function CallHotkeyScripts(action)
	local success, errorMessage
	for _, curFunction in ipairs(private.hotkeyScripts) do
		success, errorMessage = pcall(curFunction, action)
		if not success then
			DebugError("Error while executing onHotkey script for action: '"..tostring(action).."'.\nErrormessage: "..tostring(errorMessage))
		end
	end
end
MakeGlobalAvailable("CallHotkeyScripts")

function CallTabScrollScripts(action)
	local success, errorMessage
	for _, curFunction in ipairs(private.tabscrollScripts) do
		success, errorMessage = pcall(curFunction, action)
		if not success then
			DebugError("Error while executing onTabScroll script for action: '"..tostring(action).."'.\nErrormessage: "..tostring(errorMessage))
		end
	end
end
MakeGlobalAvailable("CallTabScrollScripts")

function CallUpdateScripts()
	local success, errorMessage
	for _, curFunction in ipairs(private.updateScripts) do
		success, errorMessage = pcall(curFunction)
		if not success then
			DebugError("Error while executing onUpdate script.\nErrormessage: "..tostring(errorMessage))
		end
	end
end
MakeGlobalAvailable("CallUpdateScripts")

function CallWidgetEventScripts(widget, eventName, ...)
	local widgetScriptTable = private.widgetEventScripts[widget]
	if widgetScriptTable == nil then
		return -- no registered scripts, nothing to do
	end

	local scriptTable = widgetScriptTable[eventName]
	if scriptTable == nil then
		return -- no registered scripts, nothing to do
	end

	local success, errorMessage
	for _, curFunction in ipairs(scriptTable) do
		success, errorMessage = pcall(curFunction, widget, ...)
		if not success then
			DebugError("Error while executing onEvent script for event: "..eventName..".\nErrormessage: "..tostring(errorMessage))
		end
	end
end
MakeGlobalAvailable("CallWidgetEventScripts")

-- addonSystem function definitions
function addonSystem.isValidWidgetScriptHandle(handle)
	for _, entry in ipairs(config.validScriptHandles) do
		if entry == handle then
			return true
		end
	end

	return false
end

function addonSystem.insertEventScript(eventName, scriptFunction)
	if private.eventScripts[eventName] == nil then
		private.eventScripts[eventName] = {}
	end

	local scriptTable = private.eventScripts[eventName]
	-- search for duplicates
	for key, curFunction in ipairs(scriptTable) do
		if curFunction == scriptFunction then
			return false -- entry already exists
		end
	end

	table.insert(scriptTable, scriptFunction)

	return true
end

function addonSystem.insertHotkeyScript(scriptFunction)
	-- search for duplicates
	for key, curFunction in ipairs(private.hotkeyScripts) do
		if curFunction == scriptFunction then
			return false -- entry already exists
		end
	end

	table.insert(private.hotkeyScripts, scriptFunction)

	return true
end

function addonSystem.insertTabScrollScript(scriptFunction)
	-- search for duplicates
	for key, curFunction in ipairs(private.tabscrollScripts) do
		if curFunction == scriptFunction then
			return false -- entry already exists
		end
	end

	table.insert(private.tabscrollScripts, scriptFunction)

	return true
end

function addonSystem.insertUpdateScript(scriptFunction)
	-- search for duplicates
	for key, curFunction in ipairs(private.updateScripts) do
		if curFunction == scriptFunction then
			return false -- entry already exists
		end
	end

	table.insert(private.updateScripts, scriptFunction)

	return true
end

function addonSystem.insertWidgetEventScript(widget, eventName, scriptFunction)
	if private.widgetEventScripts[widget] == nil then
		private.widgetEventScripts[widget] = {}
	end

	local widgetScriptTable = private.widgetEventScripts[widget]
	if widgetScriptTable[eventName] == nil then
		widgetScriptTable[eventName] = {}
	end

	local scriptTable = widgetScriptTable[eventName]
	-- search for duplicates
	for key, curFunction in ipairs(scriptTable) do
		if curFunction == scriptFunction then
			return false -- entry already exists
		end
	end

	table.insert(scriptTable, scriptFunction)

	return true
end

function addonSystem.removeEventScript(eventName, scriptFunction)
	if private.eventScripts[eventName] == nil then
		return false -- no scripts registered for specified name at all
	end

	local scriptTable = private.eventScripts[eventName]
	-- search for duplicates
	for key, curFunction in ipairs(scriptTable) do
		if curFunction == scriptFunction then
			table.remove(scriptTable, key)
			if #scriptTable == 0 then
				private.eventScripts[eventName] = nil -- clear the entire table, if last entry was removed
			end
			return true
		end
	end

	return false
end

function addonSystem.removeHotkeyScript(scriptFunction)
	-- search the entry
	for key, curFunction in ipairs(private.hotkeyScripts) do
		if curFunction == scriptFunction then
			table.remove(private.hotkeyScripts, key)
			return true
		end
	end

	return false
end

function addonSystem.removeTabScrollScript(scriptFunction)
	-- search the entry
	for key, curFunction in ipairs(private.tabscrollScripts) do
		if curFunction == scriptFunction then
			table.remove(private.tabscrollScripts, key)
			return true
		end
	end

	return false
end

function addonSystem.removeUpdateScript(scriptFunction)
	-- search the entry
	for key, curFunction in ipairs(private.updateScripts) do
		if curFunction == scriptFunction then
			table.remove(private.updateScripts, key)
			return true
		end
	end

	return false
end

function addonSystem.removeWidgetEventScript(widget, eventName, scriptFunction)
	if private.widgetEventScripts[widget] == nil then
		return true -- no scripts registered for specified widget at all, considered already removed
	end

	local widgetScriptTable = private.widgetEventScripts[widget]

	if widgetScriptTable[eventName] == nil then
		return true -- no scripts registered for specified name at all, considered already removed
	end

	local scriptTable = widgetScriptTable[eventName]
	-- search for duplicates
	for key, curFunction in ipairs(scriptTable) do
		if curFunction == scriptFunction then
			table.remove(scriptTable, key)
			if #scriptTable == 0 then
				widgetScriptTable[eventName] = nil -- clear the entire script table, if last entry was removed
				if next(widgetScriptTable) == nil then
					private.widgetEventScripts[widget] = nil -- clear the entire widget table, if last entry was removed
				end
			end
			return true
		end
	end

	return true -- was not found in the list, so considered already removed
end

function addonSystem.removeWidgetScript(widget, handle, scriptFunction)
	if type(widget) ~= "number" then
		DebugError("Invalid call to RemoveScript(). Given handle '"..tostring(handle).."' is not recognized or given widget '"..tostring(widget).."' is invalid.")
		return
	end

	if not addonSystem.isValidWidgetScriptHandle(handle) then
		DebugError("Invalid call to RemoveScript(). Invalid specified handle '"..tostring(handle).."'.")
		return
	end

	if not addonSystem.removeWidgetEventScript(widget, handle, scriptFunction) then
		DebugError("Failure to remove '"..tostring(handle).."' for widget '"..tostring(widget).."' .")
	end
end

function addonSystem.setWidgetScript(widget, handle, scriptFunction)
	if type(widget) ~= "number" or not IsValidWidgetElement(widget) then
		DebugError("Invalid call to SetScript(). Given handle '"..tostring(handle).."' is not recognized or given widget '"..tostring(widget).."' is invalid.")
		return
	end

	if not addonSystem.isValidWidgetScriptHandle(handle) then
		DebugError("Invalid call to SetScript(). Invalid specified handle '"..tostring(handle).."'.")
		return
	end

	if not addonSystem.insertWidgetEventScript(widget, handle, scriptFunction) then
		DebugError("Invalid call to SetScript(). Given function for event '"..tostring(handle).."' already registered on widget '"..tostring(widget).."' .")
	end
end
