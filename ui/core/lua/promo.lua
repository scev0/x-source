-- no need for special unlock-handling
-- debug line is kept closed until it's being used --- it closes automatically upon UI mode changes
-- handling is done via calling ShowUI("promo") prior to issue "showPromo"-event

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
		const char* id;
		const char* icon;
		const char* text;
		const char* link;
		bool islinkappid;
	} NewsInfo;

	bool CanOpenWebBrowser(void);
	bool GetColorMapEntry(const char* id, ColorMapEntry* result);
	NewsInfo GetNextNewsItem(void);
	float GetUIScale(const bool scalewithresolution);
	bool IsVRMode();
	void OpenWebBrowser(const char* url);
	bool QuickMenuAccess(const char* menu);
]]

--- Wrapper ---

local origffistring = ffi.string
ffi.string = function(data) 
	if data ~= nil then
		return origffistring(data)
	else
		DebugError("Invalid parameter for ffi.string() in promo. Check caller!")
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
		"ui\\core\\presentations\\promo\\promo_recovered\\gradient_02_diff",
		"ui\\core\\presentations\\promo\\promo_recovered\\ad_gradient_01",
		"ui\\core\\presentations\\promo\\promo_recovered\\ad_npcbackground_01",
		"ui\\core\\presentations\\promo\\promo_recovered\\save_game_opacity_01",
	},
	meshes = {
		"ui\\core\\presentations\\promo\\promo#ak10-lod0",
	},
	scaleElements = {
		"white outline",
		"black bar",
		"transparent background",
	},
	extraScalingFactor = 1.1,	-- extra factor to scale the background elements beyond the screen

	nativePresentationWidth = 1280,
	iconOffset = 200,
	textOffset = 100,
	relYOffset = 0.9,

	fontSize = 13,
	textOffset1 = 11,
	textOffset2 = 21,

	updateInterval = 10,

	textColorNormal = getColor("text_normal"),
	textColorHighlight = getColor("promo_text_highlight"),

	iconColor = getColor("icon_normal"),
	iconBackgroundColor = getColor("icon_normal"),

	whiteLineColor = getColor("promo_white_line"),
	textBackgroundColor = getColor("promo_text_background"),
	transparentBackgroundColor = getColor("promo_background"),
}

-- private member data
local private = {
	textElement = nil,			-- Text element
	promoElement = nil,			-- Promo element
	iconElement = nil,			-- Icon element
	text = nil,					-- displayed text
	icon = nil,					-- displayed icon
	islinkappid = nil,			-- displayed appid
	link = nil,					-- displayed link
	promoActive = false,		-- indicates whether the promo is displayed
	promoShown = false,			-- indicates whether the promo is shown (or hidden)
	lastUpdateTime = 0,			-- last time the promo was updated
}

-- local functions forward declarations
local onHidePromo
local onShowPromo
local activatePromo
local deactivatePromo
local hidePromo
local initScale
local showPromo

---------------------------------
-- Gameface lifetime functions --
---------------------------------
function self:onInitialize()
	local scene           = getElement("Scene")
	local contract        = getElement("UIContract", scene)
	local uiAnchorElement = getElement("Layer.ui_anchor", scene)

	private.promoElement   = getElement("InfoBar", uiAnchorElement)
	private.textElement = getElement("Text", private.promoElement)
	private.iconElement = getElement("Icon", private.promoElement)

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

	registerForEvent("showPromo", contract, onShowPromo)
	registerForEvent("hidePromo", contract, onHidePromo)

	-- subchannel bar should appear "static" on screen and shouldn't be affected by the "wobbling" camera effect
	DisableCameraEffectSync()
	
	local textbackground				= getElement("black bar", private.promoElement)
	local textbackgroundMaterial		= getElement("Material129", textbackground)
	local iconbackground				= getElement("background", private.iconElement)
	local iconbackgroundMaterial		= getElement("Material129", iconbackground)

	local whitelineMaterial				= getElement("white outline.Material129", private.promoElement)
	local transparentbackgroundMaterial = getElement("transparent background.Material129", private.promoElement)
	local iconMaterial					= getElement("icon.Material129", private.iconElement)

	setColorHelper(whitelineMaterial, config.whiteLineColor)
	setColorHelper(textbackgroundMaterial, config.textBackgroundColor)
	setColorHelper(transparentbackgroundMaterial, config.transparentBackgroundColor)

	setColorHelper(iconMaterial, config.iconColor)
	setColorHelper(iconbackgroundMaterial, config.iconBackgroundColor)

	registerForEvent("onMouseClick", textbackground, onMouseClick)
	registerForEvent("onGroupedMouseOver", textbackground, onMouseOver)
	registerForEvent("onGroupedMouseOut",  textbackground, onMouseOut)
	registerForEvent("onMouseClick", iconbackground, onMouseClick)
	registerForEvent("onGroupedMouseOver", iconbackground, onMouseOver)
	registerForEvent("onGroupedMouseOut",  iconbackground, onMouseOut)

	RegisterMouseInteractions(textbackground)
	RegisterMouseInteractions(iconbackground)

	LockPresentation()
end

function self:onUpdate()
	if not private.promoActive then
		return
	end

	local curtime = getElapsedTime()
	if private.lastUpdateTime + config.updateInterval < curtime then
		private.lastUpdateTime = curtime

		local news = C.GetNextNewsItem()
		if ffi.string(news.id) ~= "" then
			private.text = ffi.string(news.text)
			private.icon = ffi.string(news.icon)
			private.islinkappid = news.islinkappid
			private.link = ffi.string(news.link)

			activatePromo()
		end
	end
end

-------------------------------------
-- Presentation specific callbacks --
-------------------------------------
function onHidePromo()
	deactivatePromo()
	private.promoActive = false
end

function onShowPromo()
	private.promoActive = true
	private.lastUpdateTime = getElapsedTime()

	local news = C.GetNextNewsItem()
	if ffi.string(news.id) == "" then
		return
	end

	private.text = ffi.string(news.text)
	private.icon = ffi.string(news.icon)
	private.islinkappid = news.islinkappid
	private.link = ffi.string(news.link)

	activatePromo()
end

function onMouseClick()
	if private.islinkappid then
		if IsSteamworksEnabled() then
			OpenSteamOverlayStorePage(private.link)
		end
	else
		if string.find(private.link, "menu:", nil, true) == 1 then
			local keyword = string.sub(private.link, 6)
			C.QuickMenuAccess(keyword)
		else
			if C.CanOpenWebBrowser() then
				C.OpenWebBrowser(private.link)
			end
		end
	end
end

function onMouseOver()
	setElementTextColor(private.textElement, config.textColorHighlight)
end

function onMouseOut()
	setElementTextColor(private.textElement, config.textColorNormal)
end

-------------------------------------
-- Presentation specific functions --
-------------------------------------
function activatePromo()
	if private.text then
		local fontsize = config.fontSize * private.uiscale
		local posy = config.textOffset1

		local lines = GetTextLines(private.text, "Zekton", fontsize, private.textwidth)
		if #lines > 1 then
			posy = config.textOffset2

			lines = GetTextLines(private.text, "Zekton", fontsize, private.textwidth)
			private.text = lines[1] .. "\n" .. TruncateText(lines[2], "Zekton", fontsize, private.textwidth)
		end

		setAttribute(private.textElement, "textstring", private.text)
		setAttribute(private.textElement, "size", fontsize)
		setAttribute(private.textElement, "position.y", posy * private.uiscale)
	end
	if private.icon ~= "" then
		SetIcon(getElement("icon.Material129.boso_ta_01", private.iconElement), private.icon, 255, 255, 255, false, 120, 120)
	end
	showPromo()
end

function deactivatePromo()
	hidePromo()
end

function showPromo()
	private.promoShown = true
	goToSlide(private.promoElement, "active")
	if private.icon ~= "" then
		goToSlide(private.iconElement, "active")
	else
		goToSlide(private.iconElement, "inactive")
	end
end

function hidePromo()
	private.promoShown = false
	if private.icon ~= "" then
		goToSlide(private.iconElement, "inactive")
	end
	goToSlide(private.promoElement, "inactive")
	HidePresentation()
	LockPresentation()
end

function initScale(anchorElement)
	local width, height = getScreenInfo()

	-- apply the overall (normalizing) scale factor - compensates for world-space positioning and presentation setup scaling factor
	-- note: We interpret the scaling factor here the way that the overall presentation setup needs to be scaled so to fit into the worldspace correctly.
	--       Hence, because of that logic/definition we also scale the z-axis.
	-- No sure about the 0.907 factor here, but it was consistently off in all resolution, uiscale and aspect ratio combinations. We have the same factor in the widgetsystem actually
	local factor = 1080 / height * 0.907
	local aspectratio = width / height
	-- If the aspect ratio goes below 4/3 the visible rendered area of the game increases and we need to compensate our world-space positioned elements accordingly
	if aspectratio < 4 / 3 then
		factor = factor * (4 / 3) / aspectratio
	end
	setAttribute(anchorElement, "scale.x", config.scalingFactor * factor)
	setAttribute(anchorElement, "scale.y", config.scalingFactor * factor)
	setAttribute(anchorElement, "scale.z", config.scalingFactor * factor)

	-- texture scaling
	local scalingFactor = 0.0125 * config.extraScalingFactor

	private.uiscale = C.GetUIScale(C.IsVRMode())

	for _, element in ipairs(config.scaleElements) do
		local anarkelement = getElement(element, private.promoElement)
		setAttribute(anarkelement, "scale.x", scalingFactor * width)
		setAttribute(anarkelement, "scale.y", getAttribute(anarkelement, "scale.y") * private.uiscale)
	end

	setAttribute(private.promoElement, "position.y", (0.5 - config.relYOffset) * height)

	setAttribute(private.iconElement, "scale.x", private.uiscale)
	setAttribute(private.iconElement, "scale.y", private.uiscale)
	local iconoffsetx = -width / 2 + config.iconOffset * private.uiscale
	setAttribute(private.iconElement, "position.x", iconoffsetx)

	setAttribute(private.textElement, "position.x", iconoffsetx + config.textOffset * private.uiscale)
	private.textwidth = width - (config.iconOffset + config.textOffset) * private.uiscale
	setAttribute(private.textElement, "boxwidth", private.textwidth / config.nativePresentationWidth)
end

function setElementTextColor(anarkTextElement, color)
	setAttribute(anarkTextElement, "textcolor.r", color.r)
	setAttribute(anarkTextElement, "textcolor.g", color.g)
	setAttribute(anarkTextElement, "textcolor.b", color.b)
	setAttribute(anarkTextElement, "opacity", color.a)
	setAttribute(anarkTextElement, "glowfactor", color.glow)
end

function setColorHelper(element, color)
	SetDiffuseColor(element, color.r, color.g, color.b)
	setAttribute(element, "opacity", color.a)
	setAttribute(element, "glowfactor", color.glow)
end
