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
	float GetUIScale(const bool scalewithresolution);
	bool IsPointingWithinAimingRange();
	bool IsVRPointerActive();
]]

--- Wrapper ---

local origffistring = ffi.string
ffi.string = function(data) 
	if data ~= nil then
		return origffistring(data)
	else
		DebugError("Invalid parameter for ffi.string() in vr_pointer. Check caller!")
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
	outsideWeaponAngleRange = getColor("vrpointer_outofrange"),
	insideWeaponAngleRange = getColor("vrpointer_inrange"),
}

-- private member data
local private = {
	pointerComponentElement = nil,  -- pointer component element
	pointerElement          = nil,  -- pointer (dot) element
	previousInRange         = nil,  -- indicates which mode the pointer was in before (aka: in or out of angle range)
	pointerActive           = false -- indicates whether this (UI) pointer is active
}

-- local functions forward declarations
local onVRPointerChanged

-------------------------------------
-- Presentation lifetime functions --
-------------------------------------
function self:onInitialize()
	local sceneElement = getElement("Scene")
	local contract = getElement("UIContract", sceneElement)

	private.pointerComponentElement = getElement("Layer.pointer", sceneElement)
	private.pointerElement          = getElement("vr_dot3", private.pointerComponentElement)

	if not C.IsVRPointerActive() then
		-- activate our pointer, if the in-game VR pointer is not active
		private.pointerActive = true
		goToSlide(private.pointerComponentElement, "active")
	end

	-- apply the UI scale to the vr pointer
	-- note: passing in false, since the VR pointer obviously is only used in VR mode (where we explicitly want the scale factor to be solely controlled by the user setting)
	local uiScale = C.GetUIScale(false)
	local defaultScale = getAttribute(private.pointerComponentElement, "scale.x")
	setAttribute(private.pointerComponentElement, "scale.x", defaultScale * uiScale)
	defaultScale = getAttribute(private.pointerComponentElement, "scale.y")
	setAttribute(private.pointerComponentElement, "scale.y", defaultScale * uiScale)

	registerForEvent("VRPointerChanged", contract, onVRPointerChanged)
end

function self:onUpdate()
	if not private.pointerActive then
		return -- nothing to do if the pointer is inactive
	end

	local inRange = C.IsPointingWithinAimingRange()
	if private.previousInRange ~= inRange then
		local color = config.insideWeaponAngleRange
		if not inRange then
			color = config.outsideWeaponAngleRange
		end
		-- note: we use the pointer element rather than the direct material, in case we redesign the presentation (and would end up with a nested pointer element to be colored or some variation of that
		SetDiffuseColor(private.pointerElement, color.r, color.g, color.b)
		private.previousInRange = inRange
	end
end

-------------------------------------
-- Presentation specific callbacks --
-------------------------------------
function onVRPointerChanged(_, enabled)
	-- the pointer (i.e. this UI pointer) is active, if the in-game VR pointer is inactive (see XR-1354)
	local pointerActive = not enabled

	if pointerActive == private.pointerActive then
		return -- nothing chagned, hence nothing to do
	end

	if pointerActive then
		goToSlide(private.pointerComponentElement, "active")
	else
		goToSlide(private.pointerComponentElement, "inactive")
	end

	private.pointerActive = pointerActive
end
