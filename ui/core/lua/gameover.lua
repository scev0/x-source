-- no need for special unlock-handling
-- gameover-presentation is kept closed until it's being used
-- handling is done via calling ShowUI("gameover") after and prior to issue "showGameOver"-events

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	float GetUIScale(const bool scalewithresolution);
	bool IsDemoVersion();
	bool IsVRMode();
]]

--- Wrapper ---

local origffistring = ffi.string
ffi.string = function(data) 
	if data ~= nil then
		return origffistring(data)
	else
		DebugError("Invalid parameter for ffi.string() in gameover. Check caller!")
		DebugError(TraceBack())
		return ""
	end
end

-- settings
local config = {
	scalingFactor = 0.0003 -- factor the presentation is scaled in-game (used to scale the ui_anchor value)
}

-- private member data
local private = {
	gameOverElement = nil, -- the game over Anark element (component)
	autoHide        = nil, -- time at which to auto hide
	gameOverSlide   = nil  -- slidename for the gameover animation ("active" | "active2")
}

-- local functions forward declarations
local onShowGameOver
local showGameOver

---------------------------------
-- Gameface lifetime functions --
---------------------------------
function self:onInitialize()
	local scene           = getElement("Scene")
	local contract        = getElement("UIContract", scene)
	local uiAnchorElement = getElement("Layer.ui_anchor", scene)

	private.gameOverElement = getElement("gameover", uiAnchorElement)

	-- Note: For the VR version, we explicitly do not want that a change in resolution changes the relative size of UI elements (i.e. they should not become smaller on higher resolutions) but rather leave it completely up to the user to adjust the actual UI
	--       scale via the ui scale config setting.
	local uiScale = C.GetUIScale(not C.IsVRMode())
	setAttribute(uiAnchorElement, "scale.x", config.scalingFactor * uiScale)
	setAttribute(uiAnchorElement, "scale.y", config.scalingFactor * uiScale)

	if C.IsDemoVersion() then
		private.gameOverSlide = "active2" -- i.e. "Thanks for playing"
	else
		private.gameOverSlide = "active" -- i.e. "GAME OVER"
	end

	registerForEvent("showGameOver", contract, onShowGameOver)
end

function self:onUpdate()
	if private.autoHide ~= nil and getElapsedTime() >= private.autoHide then
		private.autoHide = nil
		LockPresentation()
		HidePresentation()
	end
end

-------------------------------------
-- Presentation specific callbacks --
-------------------------------------
function onShowGameOver(_, duration)
	showGameOver(duration)
end

------------------------------------
-- Presentation specific function --
------------------------------------
function showGameOver(duration)
	if duration > 0 then
		private.autoHide = getElapsedTime() + duration
	end
	goToSlide(private.gameOverElement, private.gameOverSlide)
end
