-- no need for special unlock-handling
-- presentation is recreated upon use

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	const char* GetLocalizedText(const uint32_t pageid, uint32_t textid, const char*const defaultvalue);
]]

--- Wrapper ---

local origffistring = ffi.string
ffi.string = function(data) 
	if data ~= nil then
		return origffistring(data)
	else
		DebugError("Invalid parameter for ffi.string() in extro. Check caller!")
		DebugError(TraceBack())
		return ""
	end
end

-- text array containing localized text
local L = {
	["ExtroText1"] = ffi.string(C.GetLocalizedText(1098, 101, "DummyText1")),
	["ExtroText2"] = ffi.string(C.GetLocalizedText(1098, 102, "DummyText2"))
}

-- settings
local config = {
	maxScreens = 2, -- maximum number of extro screenshots
	-- note: timings not adjusted based on the display time, but rather set fixed as per Peter's overruling call
	-- note: changing the timings here also requires updating the corresponding shutdown delay in GameClient::Move() (XR-1106)
	screenDelay = { -- time (in s) for each extro screen to be displayed
		15,
		15
	}
}

-- private member data
local private = {
	screenshotTextureElement = nil, -- the screenshot texture element
	textElement = nil,              -- the text element
	nextScreen = nil,               -- time at which the next screenshot will be displayed
	curScreen = nil                 -- current displayed screenshot
}

-- local functions forward declarations
local precacheScreenshots
local switchScreenshot
local updateScreenshots

---------------------------------
-- Gameface lifetime functions --
---------------------------------
function self:onInitialize()
	local layer = getElement("Scene.Layer")
	private.screenshotTextureElement = getElement("screenshots.material.screenshots", layer)
	private.textElement = getElement("Text", layer)
	
	-- clear text element
	setAttribute(private.textElement, "textstring", "")

	precacheScreenshots()
	switchScreenshot(1)
end

function self:onUpdate()
	updateScreenshots()
end

-------------------------------------
-- Presentation specific functions --
-------------------------------------
function precacheScreenshots()
	for i = 1, config.maxScreens do
		PrepareIcon("exitscreen_0"..i)
	end
end

function switchScreenshot(newScreen)
	private.curScreen = newScreen

	if newScreen == config.maxScreens then
		-- switching to last screenshot, no more updates required
		private.nextScreen = nil
	else
		private.nextScreen = getElapsedTime() + config.screenDelay[newScreen]
	end

	-- update screenshot
	SetIcon(private.screenshotTextureElement, "exitscreen_0"..tostring(private.curScreen), nil, nil, nil, false)

	-- update screenshot text
	setAttribute(private.textElement, "textstring", L["ExtroText"..tostring(newScreen)])
end

function updateScreenshots()
	if private.nextScreen == nil then
		return -- screenshots done -> nothing to do
	end

	if getElapsedTime() < private.nextScreen then
		return -- screenshot not timed out yet
	end

	-- switch to next screen
	switchScreenshot(private.curScreen + 1)
end
