-- no need for special unlock-handling
-- the target system is kept active for as long as we are in an active game mode (firstPerson or space mode at the time of writing this)
-- when starting a new game the UI is reloaded atm which retriggers the initialization flow - if this ever changes, we need to add unlock-handling

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
		const char* name;
		float hull;
		float shield;
		int speed;
		bool hasShield;
	} ComponentDetails;
	typedef struct {
		uint32_t messageID;
		bool obstructed;
	} CrosshairMessage;
	typedef struct {
		const char* factionID;
		const char* factionName;
		const char* factionIcon;
		Color factionColor;
		float glowfactor;
	} FactionDetails2;
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
	typedef struct {
		const char* POIName;
		const char* POIType;
	} POIDetails;
	typedef struct {
		float x;
		float y;
	} Position2D;
	typedef struct {
		float x;
		float y;
		float z;
		float yaw;
		float pitch;
		float roll;
	} PosRot;
	typedef struct {
		int relationStatus;
		int relationValue;
		int relationLEDValue;
		bool isBoostedValue;
		const char* owningFactionID;
	} RelationDetails2;
	typedef struct {
		float yaw;
		float pitch;
		float roll;
	} Rotation;
	typedef struct {
		bool factionNPC;
		bool missionActor;
		bool shadyGuy;
	} SpecialNPCSet;
	typedef struct {
		float speed;
		float screenx;
		float screeny;
		bool onscreen;
	} VelocityInfo;
	typedef struct {
		const char* icon;
		uint32_t damageState;
		bool active;
		bool usesAmmo;
		uint32_t ammo;
		uint32_t mode;
		float reloadPercent;
		uint32_t heatState;
		float heatPercent;
		float lockPercent;
		uint64_t counterMeasureTarget;
	} WeaponDetails;
	bool CanBeCollectedBy(UniverseID objectid, UniverseID containerid);
	void EnterInteractMenu();
	uint32_t GetAllColorMapEntries(ColorMapEntry* result, uint32_t resultlen);
	Rotation GetCameraRotation();
	ComponentDetails GetComponentDetails(const UniverseID componentid, const char*const connectionname);
	int GetConfigSetting(const char*const setting);
	CrosshairMessage GetCurrentCrosshairMessage();
	const char* GetCurrentTargetMouseButtonMapping(int32_t mousebuttonid, const char* modifiers, bool onclick);
	const char* GetEntityActiveIcon(const UniverseID componentid);
	const char* GetEntityInactiveIcon(const UniverseID componentid);
	const char* GetEntitySelectedIcon(const UniverseID componentid);
	float GetHUDUIScale(const bool scalewithresolution);
	const char* GetLocalizedText(const uint32_t pageid, uint32_t textid, const char*const defaultvalue);
	MessageDetails3 GetMessageDetails3(const uint32_t messageid);
	uint32_t GetNumAllColorMapEntries(void);
	size_t GetNumPrimaryWeapons();
	size_t GetNumSecondaryWeapons();
	FactionDetails2 GetOwnerDetails2(UniverseID componentid);
	UniverseID GetPlayerOccupiedShipID(void);
	POIDetails GetPOIDetails(const uint64_t poiid);
	WeaponDetails GetPrimaryWeapon(size_t weaponnum);
	float GetRectangleTargetElementExtents(const int posid);
	RelationDetails2 GetRelationStatus4(const UniverseID componentid, const char*const connectionname);
	PosRot GetRelativeAimOffset(const UniverseID componentid);
	Position2D GetRelativeAimScreenPosition(const UniverseID componentid, const uint32_t iconsizeonscreen, const uint32_t iconsizeoffscreen);
	WeaponDetails GetSecondaryWeapon(size_t weaponnum);
	const char* GetShipOrLaserTowerSize(const UniverseID componentid);
	SpecialNPCSet GetSpecialNPCs(const UniverseID componentid);
	float GetTargetAngle(const uint32_t);
	PosRot GetTargetElementOffset(const int posid);
	float GetTextHeight(const char*const text, const char*const fontname, const float fontsize, const float wordwrapwidth);
	float GetTextWidth(const char*const text, const char*const fontname, const float fontsize);
	float GetUIScale(const bool scalewithresolution);
	bool GetVelocityIndicatorOption(void);
	VelocityInfo GetVelocityScreenPosition(const uint32_t iconsizeonscreen, const uint32_t iconsizeoffscreen);
	bool IsAdvancedSatellite(const UniverseID componentid);
	bool IsAsteroid(const UniverseID componentid);
	bool IsAutotargetingActive();
	bool IsBomb(const UniverseID componentid);
	bool IsBuildStorage(const UniverseID componentid);
	bool IsCollectable(const UniverseID componentid);
	bool IsCommander(const UniverseID componentid);
	bool IsComponentWrecked(const UniverseID componentid);
	bool IsCrate(const UniverseID componentid);
	bool IsCrystal(const UniverseID componentid);
	bool IsDataVault(const UniverseID componentid);
	bool IsDestructible2(const UniverseID componentid, const char*const connectionname);
	bool IsDetailUIElement(const UniverseID componentid, const char*const connectionname);
	bool IsEntity(const UniverseID componentid);
    bool IsExternalTargetMode();
	bool IsExternalViewActive();
	bool IsGate(const UniverseID componentid);
    bool IsHUDActive();
	bool IsLandmark(const UniverseID componentid);
	bool IsLaserTower(const UniverseID componentid);
	bool IsLockbox(const UniverseID componentid);
	bool IsMine(const UniverseID componentid);
	bool IsNavBeacon(const UniverseID componentid);
	bool IsObjectKnown(const UniverseID componentid);
	bool IsRecyclable(const UniverseID componentid);
	bool IsResourceProbe(const UniverseID componentid);
	bool IsSatellite(const UniverseID componentid);
	bool IsShip(const UniverseID componentid);
	bool IsSofttargetManagerActive();
	bool IsStation(const UniverseID componentid);
	bool IsStationary(const UniverseID componentid);
	bool IsSuperHighway(const UniverseID componentid);
	bool IsSurfaceElement(const UniverseID componentid);
	bool IsTargetable(const uint32_t messageid);
	bool IsTargetInPlayerWeaponRange(const UniverseID componentid);
	bool IsVentureShip(const UniverseID componentid);
	bool IsVRMode();
	bool IsZone(const UniverseID componentid);
	bool IsZoneHighway(const UniverseID componentid);
	bool MarkIndicatorShown(const UniverseID componentid);
	void NotifyMissionPosIDConnected(const int32_t posid);
	void NotifyMissionPosIDDisconnected(const int32_t posid);
	void RemoveFill(const UniverseID componentid, const char*const connectionname);
	void RemoveOutline(const UniverseID componentid, const char*const connectionname);
	void SetCrosshairMessage(const uint32_t messageid);
	void SetFill(const UniverseID componentid, const char*const connectionname, const uint8_t red, const uint8_t green, const uint8_t blue, const float alpha, const bool animated, const float minalpha, const float maxalpha, const float transitiontime);
	void SetMouseInputBlockedByAnarkElement(int32_t mousebuttonid, const char* modifiers, bool blocked);
	void SetOutline(const UniverseID componentid, const char*const connectionname, const uint8_t red, const uint8_t green, const uint8_t blue, const bool animated);
	bool ShouldShowShieldBar(const UniverseID destructibleid);

	typedef struct {
		const char* active;
		const char* inactive;
		const char* select;
	} IconSet;
	typedef struct {
		float x;
		float y;
		bool onScreen;
	} ScreenPos;
	const char* GetComponentHUDIcon(const UniverseID componentid);
	const char* GetComponentIcon(const UniverseID componentid);
	PosRot GetComponentOffset(const UniverseID componentid);
	ScreenPos GetComponentScreenPosition(const UniverseID componentid, const uint32_t iconsizeonscreen, const uint32_t iconsizeoffscreen);
	IconSet GetMissionOfferIcons(const UniverseID componentid);
	void ShowInteractMenu(const UniverseID componentid, const char*const connectionname, const uint32_t id);
]]

--- Wrapper ---

local origffistring = ffi.string
ffi.string = function(data)
	if data ~= nil then
		return origffistring(data)
	else
		DebugError("Invalid parameter for ffi.string() in targetsystem. Check caller!")
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

-- configuration
-- #coreUIMed - make config local and set values directly
if config == nil then
	config = {}
end

-- system settings
config.displayHostileTargetIndicator = true -- indicates whether we display the target indicator for hostile ships (true) as well, or only for mission targets (false) - remove once XT-4071 is in
config.defaultScaleResolution        = 1080 -- the resolution (screen height) which the unscaled target element system is set up for

-- debug settings
config.enableDebugOutlines = false -- indicates whether debug outlines for all target elements currently in any message sink should be displayed
config.debugValuesEnabled  = false -- indicates whether we display debug values instead of the real text values (i.e. posID, message display priority, distance, target cone ratio)

-- target system specific settings
-- #coreUILow - add sanity check to ensure that numFirstPersonTarget <= numTargetElements+numPOITargets+numFastMovingTargetElements (otherwise we will run out of POS-elements)
config.numFirstPersonTargets       = 16 -- max number of available target elements for first person cases
config.numTargetElements           =  7 -- max number of available target elements for static/slow moving targets
config.numFastMovingTargetElements =  8 -- max number of available target elements for fast moving targets
config.numMissionTargets           =  8 -- max number of available mission target elements
config.numPOITargets               =  5 -- max number of available poi target elements
config.numPlayerCapShips           =  6 -- max number of available player cap ship target elements

-- obstruction settings (mainly for quickly testing different obstruction behavior)
config.obstructedByOwnComponents = false -- indicates whether all target elements should be obstructed by own components
config.obstructionOpacity        = 25    -- the opacity value to be used for obstructed target elements

-- icon settings
config.useIconOverlayColor            = false -- indicates to use overlay color (in contrast to multiply color) for coloring the icon textures
-- #coreUILow - get these information by retrieving the orgscale from the Anark presentation so it doesn't have to be adjusted here AND in the presentation when it changes
-- IMPORTANT NOTE: when changing targetElementIconSize or targetElementIconSizeEdge, also change the settings used in TargetHelper::TargetContainerCrosshairAngleSorter
config.targetElementIconSize          = 32    -- size (in px) of the main target element
config.targetElementIconSizePlatform  = 48    -- size (in px) of target elements on the first person platform
config.targetElementIconSizeEdge      = 16    -- size (in px) of target elements on the edge of the cockpit window
config.rectangleIconSize              = 16    -- size (in px) of the small icon displayed in rectangle display mode
config.missionElementSizeFactor       =  1.75 -- factor the icon size is multiplied with to get a correctly sized mission target element
config.collectableElementSizeFactor   =  2    -- factor the icon size is multiplied with to get a correctly sized collectable element
config.collectableElementSizeFactorVR =  1    -- factor the icon size is multiplied with to get a correctly sized collectable element (in VR mode)
-- #coreUIMed - import this value from the main texture element scale value
config.iconReferenceSize              = 32    -- the reference icon size the Anark presentation is set up for

-- text settings
-- #coreUIMed - better read the data from the actual presentation instead of hardcoding it here
config.bottomTextFont               = "zekton outlined"
config.bottomTextFontSize           =  10
config.bottomTextOffsetY            = -44
config.bottomTextMaxOffsetY         = -10
config.sideTextFont                 = "zekton outlined"
config.sideTextFontSize             = 10
config.sideTextOffsetX              = 30
config.sideTextOffsetY              =  9
config.sideText2OffsetY             = -7
config.sideTextPositioningThreshold = 25

-- color settings
config.debugColor = Color["icon_normal"]
config.relationColor = {
	[1] = { -- hostile
		["element"] = { -- color value for the target element
			["normal"] = Color["targetsystem_relation_hostile"],
			["obstructed"] = Color["targetsystem_relation_hostile_obstructed"],
		},
		["text"] = { -- color value for associated text (f.e. distance/speed)
			["normal"] = Color["targetsystem_relation_hostile_text"],
			["obstructed"] = Color["targetsystem_relation_hostile_text_obstructed"],
		}
	},
	[2] = { -- enemy
		["element"] = { -- color value for the target element
			["normal"] = Color["targetsystem_relation_enemy"],
			["obstructed"] = Color["targetsystem_relation_enemy_obstructed"],
		},
		["text"] = { -- color value for associated text (f.e. distance/speed)
			["normal"] = Color["targetsystem_relation_enemy_text"],
			["obstructed"] = Color["targetsystem_relation_enemy_text_obstructed"],
		}
	},
	[3] = { -- neutral
		["element"] = { -- color value for the target element
			["normal"] = Color["targetsystem_relation_neutral"],
			["obstructed"] = Color["targetsystem_relation_neutral_obstructed"],
		},
		["text"] = { -- color value for associated text (f.e. distance/speed)
			["normal"] = Color["targetsystem_relation_neutral_text"],
			["obstructed"] = Color["targetsystem_relation_neutral_text_obstructed"],
		}
	},
	[4] = { -- friendly
		["element"] = { -- color value for the target element
			["normal"] = Color["targetsystem_relation_friendly"],
			["obstructed"] = Color["targetsystem_relation_friendly_obstructed"],
		},
		["text"] = { -- color value for associated text (f.e. distance/speed)
			["normal"] = Color["targetsystem_relation_friendly_text"],
			["obstructed"] = Color["targetsystem_relation_friendly_text_obstructed"],
		}
	},
	[5] = { -- member
		["element"] = { -- color value for the target element
			["normal"] = Color["targetsystem_relation_member"],
			["obstructed"] = Color["targetsystem_relation_member_obstructed"],
		},
		["text"] = { -- color value for associated text (f.e. distance/speed)
			["normal"] = Color["targetsystem_relation_member_text"],
			["obstructed"] = Color["targetsystem_relation_member_text"],
		}
	},
	[6] = { -- own property
		["element"] = { -- color value for the target element
			["normal"] = Color["targetsystem_relation_player"],
			["obstructed"] = Color["targetsystem_relation_player_obstructed"],
		},
		["text"] = { -- color value for associated text (f.e. distance/speed)
			["normal"] = Color["targetsystem_relation_player_text"],
			["obstructed"] = Color["targetsystem_relation_player_text"],
		}
	},
	[7] = { -- unknown (same as neutral)
		["element"] = { -- color value for the target element
			["normal"] = Color["targetsystem_relation_neutral"],
			["obstructed"] = Color["targetsystem_relation_neutral_obstructed"],
		},
		["text"] = { -- color value for associated text (f.e. distance/speed)
			["normal"] = Color["targetsystem_relation_neutral_text"],
			["obstructed"] = Color["targetsystem_relation_neutral_text_obstructed"],
		}
	}
}
config.collectibleColor = {
	["normal"] = Color["targetsystem_collectible"],
	["unavailable"] = Color["targetsystem_collectible_unavailable"],
}
config.missionColor = {
	["normal"] = Color["targetsystem_mission"],
	["obstructed"] = Color["targetsystem_mission_obstructed"],
}
config.wreckColor = {
	["normal"] = Color["targetsystem_wreck"],
	["obstructed"] = Color["targetsystem_wreck_obstructed"],
}
config.targetRectangleColor = { -- color for the "white" rectangle elements when the target element is the current target
	["normal"] = Color["targetsystem_normal"],
	["obstructed"] = Color["targetsystem_obstructed"],
}
config.hullBarColor = {
	["normal"] = Color["targetsystem_normal"],
	["obstructed"] = Color["targetsystem_obstructed"],
}
config.shieldBarColor = {
	["normal"] = Color["targetsystem_shield"],
	["obstructed"] = Color["targetsystem_shield_obstructed"],
}
config.fill = { -- the alpha values used for the fill effect
	["alpha"]          = 0.8, -- the start alpha value
	["minAlpha"]       = 0,   -- the minimum alpha value for the fill pulse effect
	["maxAlpha"]       = 0.2, -- the maximum alpha value for the fill pulse effect
	["transitionTime"] = 2    -- the time (in s) the alpha value will linearly transit to the animated alpha value before starting to pulse
}
config.missileLockColor = { -- the color values for the missile lock element
	["hostile"] = {         -- color values for the case the missile locks onto a hostile target
		["locking"] = Color["targetsystem_missile_hostile_locking"],     -- color, while locking onto the target (blue)
		["locked"] = Color["targetsystem_missile_hostile_locked"],       -- color, when locked onto the target (red)
	},
	["other"] = {           -- color values for the case the missile locks onto another target (i.e. neutral, friend, player owned)
		["locking"] = Color["targetsystem_normal"],     -- color, while locking onto the target (white)
		["locked"] = Color["targetsystem_normal"],      -- color, when locked onto the target (white)
	},
	["text"] = Color["targetsystem_missile_locked_text"],
}
config.aimColor = Color["targetsystem_aimahead"]

config.glowfactors = {
	text = 0.5,
}

-- poi settings
config.poiIcons = {
	["subordinate"]  = "subordinatetarget",
	["zonehighway"]  = "poi_zonehighway",
	["superhighway"] = "poi_superhighway",
	["gate"]         = "poi_gate"
}

-- settings for rectangle mode
config.minNormalRectangleScreenSize    =  15 -- min half-size (in px) for the rectangle mode in screenspace mode (for normal rectangles)
config.minSmallRectangleScreenSize     =  10 -- min half-size (in px) for the rectangle mode in screenspace mode (for small rectangles - like surface elements)
config.maxRectangleScreenSize          = 110 -- max half-size (in px) for the rectangle mode in screenspace mode (applies for both: small and normal rectangles)
config.minNormalRectangleWorldSize     =  23 -- min size for the rectangle mode in worldspace mode (for normal rectangles)
config.minSmallRectangleWorldSize      =  16 -- min size for the rectangle mode in worldspace mode (for small rectangles - like surface elements)
config.maxRectangleWorldSize           =  90 -- max size for the rectangle mode in worldspace mode (applies for both: small and normal rectangles)
config.rectangleEdgeSize               =  16 -- size (in px) of the rectangle's edge element
config.mousePickingBorder              =  47 -- size (in px) by which the mouse picking area will be extended (width and height)
config.rectangleSizeCorrection         =   0 -- size correction (in px) increasing the actual size of the rectangle (in relation to the used textures)
config.rectangleIconPositionCorrection =   2 -- positioning correction for the target element icon position over the rectangular element
                                             -- (correcting for the visible rectangular edge element not being centered in the texture)
config.rectangleElements = {
	["normal"] = {
		"normal.lower_left.Material1137",
		"normal.lower_right.Material1145",
		"normal.upper_left.Material1153",
		"normal.upper_right.Material1161",
	},
	["short"] = {
		"short.lower_left.Material1137",
		"short.lower_right.Material1145",
		"short.upper_left.Material1153",
		"short.upper_right.Material1161",
	},
	["target_normal"] = {
		"softtarget_normal.lower_left.Material1204",
		"softtarget_normal.lower_right.Material1211",
		"softtarget_normal.upper_left.Material1218",
		"softtarget_normal.upper_right.Material1225",
	},
	["target_short"] = {
		"softtarget_short.lower_left.Material1204",
		"softtarget_short.lower_right.Material1211",
		"softtarget_short.upper_left.Material1218",
		"softtarget_short.upper_right.Material1225",
	},
	["softtarget_normal"] = {
		"softtarget_normal.lower_left.Material1204",
		"softtarget_normal.lower_right.Material1211",
		"softtarget_normal.upper_left.Material1218",
		"softtarget_normal.upper_right.Material1225",
	},
	["softtarget_short"] = {
		"softtarget_short.lower_left.Material1204",
		"softtarget_short.lower_right.Material1211",
		"softtarget_short.upper_left.Material1218",
		"softtarget_short.upper_right.Material1225",
	},
	["mtarget_large"] = {
		"mtarget_large.lower_left.lower_left_mtarget_01.Material1137",
		"mtarget_large.lower_left.lower_left_mtarget_02.Material1137",
		"mtarget_large.lower_right.lower_left_mtarget_01.Material1137",
		"mtarget_large.lower_right.lower_left_mtarget_02.Material1137",
		"mtarget_large.upper_left.lower_left_mtarget_01.Material1137",
		"mtarget_large.upper_left.lower_left_mtarget_02.Material1137",
		"mtarget_large.upper_right.lower_left_mtarget_01.Material1137",
		"mtarget_large.upper_right.lower_left_mtarget_02.Material1137",
	},
	["pmtarget_large"] = {
		"pmtarget_large.lower_left.lower_left_mtarget_01.Material1137",
		"pmtarget_large.lower_left.lower_left_mtarget_02.Material1137",
		"pmtarget_large.lower_right.lower_left_mtarget_01.Material1137",
		"pmtarget_large.lower_right.lower_left_mtarget_02.Material1137",
		"pmtarget_large.upper_left.lower_left_mtarget_01.Material1137",
		"pmtarget_large.upper_left.lower_left_mtarget_02.Material1137",
		"pmtarget_large.upper_right.lower_left_mtarget_01.Material1137",
		"pmtarget_large.upper_right.lower_left_mtarget_02.Material1137",
	},
	["mtarget_small"] = {
		"mtarget_small.lower_left.lower_left_mtarget_01.Material1137",
		"mtarget_small.lower_left.lower_left_mtarget_02.Material1137",
		"mtarget_small.lower_right.lower_left_mtarget_01.Material1137",
		"mtarget_small.lower_right.lower_left_mtarget_02.Material1137",
		"mtarget_small.upper_left.lower_left_mtarget_01.Material1137",
		"mtarget_small.upper_left.lower_left_mtarget_02.Material1137",
		"mtarget_small.upper_right.lower_left_mtarget_01.Material1137",
		"mtarget_small.upper_right.lower_left_mtarget_02.Material1137",
	},
	["pmtarget_small"] = {
		"pmtarget_small.lower_left.lower_left_mtarget_01.Material1137",
		"pmtarget_small.lower_left.lower_left_mtarget_02.Material1137",
		"pmtarget_small.lower_right.lower_left_mtarget_01.Material1137",
		"pmtarget_small.lower_right.lower_left_mtarget_02.Material1137",
		"pmtarget_small.upper_left.lower_left_mtarget_01.Material1137",
		"pmtarget_small.upper_left.lower_left_mtarget_02.Material1137",
		"pmtarget_small.upper_right.lower_left_mtarget_01.Material1137",
		"pmtarget_small.upper_right.lower_left_mtarget_02.Material1137",
	},
}

-- settings for worldspace positioning
config.scalingFactor                       =    0.002 -- fixed factor with which the scaling factor in worldspace mode is multiplied with
config.textScalingFactor                   =    0.7   -- fixed scaling factor to compensate for the otherwise too large text elements, if we apply the scaling factor on the whole target element in worldspace mode
config.worldPositionReferencePlaneDistance = 1800     -- a conceptual distance for which the target element config values/designs are specified to in worldspace mode

-- pointer settings
config.targetPointerID  = "target"  -- default pointer ID used, if no action specific pointer ID is given
config.defaultPointerID = "default" -- identifier used to indicate to the system to use the "default" pointer ID

-- softtarget manager specific settings
-- softtarget configuration
config.enableSofttargetOutOfConeCheck = false -- set to true, to enable softtargets getting lost, if they are outside the target cone
                                             -- i.e. it didn't get replaced by another target element (with a higher priority) but got released, because it
											 -- went out of the target cone + cone threshold
											 -- set to false, to keep softtargets regardless of their positions on screen

-- steering strength
config.steeringStrengthLimit        = 0.5 -- the strength value at which the softtarget will no longer be changed
config.unlockSofttargetDelay        = 3   -- delay (in s) after which a previously locked softtarget will be unlocked again (even if there's currently no other softtarget which would replace the previous one)
config.unlockSofttargetReplaceDelay = 1   -- delay (in s) after which a previously locked softtarget can be replaced with another softtarget

-- hull/shield bar settings
config.hullShieldBarYOffsetOnScreen           = -2 -- y-offset (in px) the hull/shield bar is to be shifted for porper positioning based on the upper left border of the element if the target element is on screen (note: we used the normal rectangle on 1920x1200 / UI scale 1.5 / closest appraoch to target to determine the value)
config.hullShieldBarYOffsetOffScreen          =  5 -- y-offset (in px) the hull/shield bar is to be shifted for proper positioning based on the upper left border of the element if the target element is off screen (note: we determined the value based on where the hull/shield bar is positioned at the upper screen border on 1920x1200 / UI scale 1.5)
config.hullShieldBarNoShieldYOffsetCorrection =  5 -- y-offset correction (in px) the bar is to be shifted by, if no shield value is displayed (note: value determined by taking a screenshot on 1920x1200 (UI scale: 1.0) with and without a shield bar displayed on a target in front of the ship and adjusting the value so the hull bar matches the position of the shield bar)
config.hullShieldBarWidthCorrection           =  0 -- additional width (in px) added to the calculated width for the hull/shield bar
config.hullShieldBarReservationHeight         = 16 -- additional height (in px) to be reserved for the hull/shield bar in the offscreen case
-- #coreUIMed --- provide per rectangle mode offset-calculation (width and height), since the bar can be positioned slightly larger/higher depending on the actual rectangle texture

-- softtarget/pending softtarget time delays
config.minSpaceDelay       = 0.5 -- minimal delay before a pending target is changed in space (in s) (if there is no other current target)
config.minFirstPersonDelay = 0   -- minimal delay before a pending target is changed in 1st-person-mode (in s) (if there is not other current target)
config.minReplaceDelay     = 0.5 -- minimal delay before a pending target replaces the current target (in s)
config.maxDelay            = 8   -- delay before the pending target is changed (in s)
config.crosshairMessageDelay = 0.1 -- delay before the crosshair message changes

-- center (aka: crosshair) targeting settings
config.maxCenterSquareDistance = 32^2 -- maximal distance from a target element to the center of the screen (aka crosshair - in px) where the target would still be selectable (using Shift+F) (actually the square distance)

-- target cone settings (used to calculate the target cone dependent parameter value)
-- some values use the square distance to speed up calculations a bit
config.targetMaxDistance   = 2000    -- max distance for the target cone (!!!NOTE!!! -- NOT the square distance)
config.targetMidDistance   = 400  ^2 -- distance for the target cone, where the parametervalue equals targetMidValue (actually the square distance)
config.targetMinDistance   = 100  ^2 -- min distance for the target cone (actually the square distance)
config.targetMidValue      = 0.12    -- parametervalue at targetMidDistance
config.targetMinArea       = 0.1     -- percentage of the screen width/height defining the cone area when the target is at max distance
config.targetMaxArea       = 0.7     -- percentage of the screen width/height defining the cone area when the target is at min distance
config.targetAreaThreshold = 0.1     -- percentage of the screen width/height used as the threshold to determine whether a target element left the cone area

-- missile related settings
config.maxMissileLocks = 16 -- number of maximum missile locks (should correspond to the maximum number of missile launchers for ships)

config.targetBracketElements = {
	{ element = "lower_left",	positionid = "lowerleft",	xDir = -1, yDir = -1 },
	{ element = "lower_right",	positionid = "lowerright",	xDir =  1, yDir = -1 },
	{ element = "upper_left",	positionid = "upperleft",	xDir = -1, yDir =  1 },
	{ element = "upper_right",	positionid = "upperright",	xDir =  1, yDir =  1 },
}

config.targetBracketAnimation = {
	duration = 7 / 15,
	baseScale = 16,
	scaleFactor = 2,
	offsetFactor = 0.5,
	mouseOverFactor = 1.2,
}

config.speedoflight = 299792458

config.defaultFontSize = 10

-- velocity indicator
config.velocityIndicator = {
	size = 40,
	size_offscreen = 40,
	color = Color["targetsystem_velocity_indicator"],
	color_offscreen = Color["targetsystem_velocity_indicator_offscreen"],
}

-- text array containing localized text
local L = {
	["km"]   = ffi.string(C.GetLocalizedText(1001, 108, "km")),
	["LOCK"] = ffi.string(C.GetLocalizedText(1001, 5105, "LOCK")),
	["m"]    = ffi.string(C.GetLocalizedText(1001, 107, "m")),

	-- P1 specific texts
	["m/s"] = ffi.string(C.GetLocalizedText(1001, 113, "m/s")),
	["s"] = ffi.string(C.GetLocalizedText(1001, 100, "s")),
	["c"] = ffi.string(C.GetLocalizedText(1001, 124, "c")),
}

-- private member data
local private = {
	-- softtarget manager settings
	aimElement                            = nil,        -- the aim-at target element
	aimTargetElementActive                = false,      -- indicates whether the aim-at target element is active
	aimTargetElementMode                  = "inactive", -- the current mode the aim target element is in (i.e. "inactive" | "weapon_out" | "weapon_in")
	aimTargetElementEnabled               = false,      -- indicates whether the aim-at target element is enabled in the current target system mode
	currentSofttarget                     = nil,        -- the current softtarget target element (if any)
	previousTriedPendingSofttargetMessage = nil,        -- the message of the target which tried to become the pending target the previous time (entry in targetElements)
	previousTriedPendingSofttargetTime    = 0,          -- time, when the last pending softtarget was selected
	pendingSofttarget                     = nil,        -- the current pending softtarget (entry in targetElements)
	pendingSofttargetTime                 = 0,          -- time, when the last softtarget was selected
	softtargetLockRequested               = false,      -- indicates whether the softtarget manager requested to lock the current softtarget
	lockTime                              = 0,          -- time, at which the softtarget was locked
	currentPriorityMissionTarget          = nil,        -- the current priority mission target (entry in targetElements)
	reservationSize                       = nil,        -- size (in px) to reserve for displaying a target element
	                                                    -- (note: we use the same size on- and off-screen since the texts we display for the offscreen case at the target element's right side actually require the same size we use for the
												        --        on-screen case --- using different sizes here would result in inconsistent visuals depending on which elements we'd display in the offscreen case (i.e. texts, hull/shield))
	sideTextMode                          = nil,        -- indicates which text is displayed for the side text element (nil, "name", or "distance")
	screenWidth                           = nil,        -- screen width (entire window screen, not the Anark presentation screen width)
	screenHeight                          = nil,        -- screen height (entire window height, not the Anark presentation screen height)
	autoTargetSelection                   = false,      -- indicates whether auto target selection is active atm
	autoCrosshairTargetSelection          = false,      -- indicates whether we autotarget the target underneath the crosshair
	cockpitAutoTargeting                  = false,      -- indicates whether we use auto target selection in space mode
	firstPersonAutoTargeting              = false,      -- indicates whether we use auto target selection in 1st-person mode
	softtargetManagerActive               = false,      -- indicates whether the softtargetmanager is active atm
	crosshairMessageID                    = 0,          -- the message ID of the target underneath the crosshair (if any)
	pendingCrosshairMessage               = {},			-- pending crosshairmessage and timestamp (if any)
	newTargetDelay                        = 0,          -- the delay, before a target will become the softtarget (if there is currently no target)
    HUDEnabled                            = true,       -- indicates whether the HUD is enabled (aka visible) atm
	targetSystemMode                      = nil,        -- the current target system mode (nil, "space", "firstPerson")
	performEnterInteractMenu              = false,      -- indicates whether we got an enter interact menu event which we need to process during the next update cycle
	pendingDebugOutlines                  = nil,        -- set to trigger a switch of debug outlines (nil = no change, true = enable debug outlines, false = disable debug outlines)
	pendingSofttargetManagerStateChange   = nil,        -- set to trigger a activate or deactivate the softtarget manager (nil = no change, true = activate softtarget manager, false = deactivate softtarget manager)
	pendingSofttargetMessageID            = nil,        -- messageID of a pending softtarget change event
	updateOutlines                        = false,      -- indicates whether all outlines need to be updated
	-- #coreUIMed - convert the note: "only tested in non-worldspace mode" to an assertion
	counteractCameraRoll                  = false,      -- indicates whether we need to counteract the camera roll rotation (only tested in non-worldspace mode - might glitch with look-at-controller)
	cameraRoll                            = 0,          -- current player camera roll value
	curSinkAssignedTargetElements         = 0,          -- number of target elements currently assigned to a specific sink
	uiScale                               = 1,          -- the UI scale factor (see GetUIScale())
	useWorldSpacePositions                = false,      -- indicates whether we are using worldspace positions (in contrast to screen space (aka: 2D) positions)
	mouseMode                             = true,       -- indicates whether we are in mouse-mode (i.e. double click required to open an interact menu in contrast to single clicks in joystick/touch-controller/gamepad modes)
	vrMode                                = false,      -- indicates whether we are running in VR mode
	missileLocksEnabled                   = false,      -- indicates whether missile lock visualization is enabled
	speedDisplayEnabled                   = false,      -- indicates whether speed display is enabled
	velocityIndicatorEnabled              = false,      -- indicates whether the velocity indicator is enabled
	velocityIndicator                     = {},         -- the velocity indicator elements
	mouseOverTargetElement                = nil,        -- the target element the mouse cursor is currently hovering over (nil, if atm not over a target element)
	mouseElements                         = {
		-- [anarkMouseElement] = elementID              -- mapping from anark elements which are registered for mouse-interactions to the corresponding target element ID
	},
	-- #coreUIMed combine with targetelements
	targetElements                         = {
		-- [x] = entry							        -- list of target element data (see constructTargetElementData() for list of members)
	},
	connectionList                         = {          -- list of connection/disconnection events from the last cycle
		-- [targetSystem] = {                            -- targetSystem which the connection/disconnection event applies to
			-- [type]      = "connect"|"disconnect"       -- type of connection event (either connecting or disconnecting)
			-- [posID]     = number                       -- ID of the posElement (only valid for connect-types)
			-- [messageID] = number                       -- ID of the message which is to be connected (only valid for connect-types)
		-- }
	},

	-- P1 specific data
	missileLock = {
		--[x] = {
			-- [lockElement]           = Anark element,
			-- [lockMaterialElement]   = Anark element,
			-- [targetElement]         = Anark element,
			-- [targetMaterialElement] = Anark element,
			-- [colorMode]             = ""|"hostile"|"other" ("" corresponding to uninitialized)
			-- [state]                 = "inactive"|"locking"|"locked"
		-- }
	},
	disconnectedMissionTargets = {},
	useConfidenceBasedAutoTargetting = nil,
	useFactionColor                       = 0,          -- whether to use faction colors instead of relation colors

	-- debug
	enableMousePickDebug = nil,
}

-- table for all callbacks related functions
-- Note: this was added due to exceeding 200 local definitions in this file
-- #coreUILow - better move all functions to a single table (like targetSystem)
local callbacks = {}
-- local functions forward declarations
local activateAimTargetElement
local activateCollectable
local activateCommanderElement
local activateDebugOutline
local activateFill
local activateHullShield
local activateIcon
local activateIconElements
local activateOutline
local activateRectangleElements
local activateTargetRectangle
local activateTargetIndicator
local calculateTargetPriority
local cameraDistanceSorter
local canMessageBeSofttarget
local changePendingSofttarget
local changePriorityMissionTarget
local changeState
local checkPendingSofttargetChange
local checkSofttargetChange
local connectTargetElement
local constructTargetElementData
local createSink
local createTargetElement
local createTargetSystemClones
local deactivateAimTargetElement
local deactivateBottomText
local deactivateCollectable
local deactivateCommanderElement
local deactivateDebugOutline
local deactivateFill
local deactivateHullShield
local deactivateIcon
local deactivateIconElements
local deactivateOutline
local deactivateRectangleElements
local deactivateSideText
local deactivateTargetRectangle
local deactivateTargetIndicator
local disconnectElement
local displayAimTargetElement
local getCameraDistanceBasedParameterValue
local getCurrentCrosshairMessage
local getDistanceText
local getIconSize
local getMinTargetDelay
local getPOIIcon
local getPointerID
local getRectanglePositions
local getScreenArea
local getShipOrLaserTowerSize
local getSquareDistanceToCenter
local getTargetConeRatio
local getTargetElementByMessageID
local getTargetElementByTargetSystem
local getTargetElementPosition
local getTargetElementScale
local getTargetIcon
local getTargetPriority
local getUIElementScreenPosition
local hasActions
local hasPossibleActions
local hasVisibleActions
local hideAimTargetElement
local hideDebugOutline
local initDynamicTargetElementData
local initIcon
local initMousePicking
local initTargetElement
local isCrosshairTarget
local isCurrentAimTargetElementActive
local isFirstPersonMode
local isInactiveTargetElementState
local isInTargetCone
local isInWeaponRange
local isObstructed
local isSmallShip
local isTargetable
local isTargetElementPendingDeletion
local lerpColorModeColor
local processConnectionList
local processEnterInteractMenuEvent
local processSofttargetChange
local removeAllPointerOverrides
local removeFill
local removeOutline
local removeSofttargetLockRequest
local requestSofttargetLock
local resetElement
local resetTargetSystem
local setAutoCrosshairTargetSelection
local setBottomText
local setColoredText
local setDisplayMode
local setExternalFirstPersonMode
local setFirstPersonAutoTargeting
local setFirstPersonMode
local setGamepadMode
local setIconPos
local setJoystickMode
local setMouseMode
local setPointerOverride
local setShipMode
local setSideText
local setSpaceMode
local setTargetElementColor
local setTextColor
local setTouchControllerMode
local showDebugOutline
local showFill
local showOutline
local startSofttargetInteraction
local unsetPointerOverride
local updateAimTargetElement
local updateAllPointerOverrides
local updateAllOutlines
local updateBottomText
local updateColor
local updateDebugOutlines
local updateElementPosition
local updateFactionColor
local updateHullShield
local updateIcon
local updateIconSize
local updateOutline
local updatePointerOverride
local updateRectangleElements
local updateRelation
local updateSideText
local updateSideTextPosition
local updateSofttargetLock
local updateSofttargetManager
local updateSofttargetManagerActivationState
local updateSofttargetTargetElement
local updateState
local updateTargetElement
local updateTargetElementData
local updateTargetElementPosition

-- P1-specific functions
local activateAdditionalIcon
local deactivateAdditionalIcon
local deactivateMissileLocks
local deactivateOffScreenBox
local deactivateSideText2
local getComponentIcon
local getComponentHUDIcon
local getCounterMeasurePosition
local handleMouseClick
local handleMouseDown
local isShipPOI
local makeTargetElementKnown
local performSelectSofttargetOnClick
local setMissileLockColor
local setMissileLockState
local setObstructionBasedColor
local setSideText2
local updateDynamicRectangleIcons
local updateMissileLock
local updateMissileLockColor
local updateMissileLocks
local updateOffScreenBox
local updateSideText2
local updateVelocityIndicator

-- prototype auto-target functions
local prototype = {}

---------------------------------
-- Gameface lifetime functions --
---------------------------------
function self:onInitialize()
	local sceneElement = getElement("Scene")
	local contract = getElement("UIContract", sceneElement)

	-- #coreUIMed - this is kind of an ugly design, but it works
	-- we dump all messages first so that any messages from a previous target system are removed
	-- that solves issues like objects on landing platforms still showing the target pointer when hovering over since the messages are still valid (do exist)
	-- a better solution would be to do this inside the ICom system and connecting the target system presentation directly with the ICom system or dump all messages
	-- in the waiting queue, which are still there when the target sink gets removed or somthing like this
	DumpAllMessages()

	-- get/initialize elements which are unique (aka: not part of the cloned target elements)
	local layerElement = getElement("Layer", sceneElement)
	private.aimElement = getElement("aim", layerElement)

	local color = config.aimColor
	SetDiffuseColor(private.aimElement, color.r, color.g, color.b)
	setAttribute(getElement("crosshair_aim.crosshair_in_range.Material452", private.aimElement), "glowfactor", color.glow)
	setAttribute(getElement("crosshair_aim.crosshair_out_of_range.Material452", private.aimElement), "glowfactor", color.glow)

	-- clone missile lock elements
	local masterMissileLockElement   = getElement("missilelock", layerElement)
	local masterMissileTargetElement = getElement("missiletarget", layerElement)

	-- initial static text elements
	setAttribute(getElement("Text", masterMissileTargetElement), "textstring", L["LOCK"])
	setTextColor(getElement("Text", masterMissileTargetElement), config.missileLockColor.text)

	private.missileLock[1] = {
		["lockElement"]           = masterMissileLockElement,
		["lockMaterialElement"]   = getElement("Plane013", masterMissileLockElement),
		["targetElement"]         = masterMissileTargetElement,
		["targetMaterialElement"] = getElement("Plane12", masterMissileTargetElement),
		["colorMode"]             = "",
		["state"]                 = "inactive"
	}
	for i = 1, config.maxMissileLocks - 1 do
		local lockElement   = clone(masterMissileLockElement, "missilelockclone"..i)
		local targetElement = clone(masterMissileTargetElement, "missiletargetclone"..i)
		private.missileLock[i+1] = {
			["lockElement"]           = lockElement,
			["lockMaterialElement"]   = getElement("Plane013", lockElement),
			["targetElement"]         = targetElement,
			["targetMaterialElement"] = getElement("Plane12", targetElement),
			["colorMode"]             = "",
			["state"]                 = "inactive"
		}
	end

	-- initialize render related settings
	private.vrMode = C.IsVRMode()
	-- #coreUILow - atm we apply the ui scale factor onto the entire target element rather than separating text elements from graphical elements and upscale the fontsize (which would give us the best visual results)
	--              it's expected however that the visible differences will be quite minor and hence we stick with the more simple approach at least for now and just upscale the entire target system
	if private.vrMode then
		SetFullScreenWorldSpace()
		-- note: must retrieve the screen info after setting to fullscreen mode, since this can change the resolution
		private.screenWidth, private.screenHeight = getScreenInfo()
		private.useWorldSpacePositions = true
		private.counteractCameraRoll   = true
		-- in VR mode we don't want the target elements to become bigger related to the current resolution
		private.uiScale                = C.GetUIScale(false)
	else
		SetFullScreenOneToOne()
		-- note: must retrieve the screen info after setting to fullscreen mode, since this can change the resolution
		private.screenWidth, private.screenHeight = getScreenInfo()
		private.useWorldSpacePositions = false
		private.counteractCameraRoll   = false
		-- by definition we want that on higher resolutions target elements (incl. texts) become larger for consistency with how menus behave - to achieve this in 1:1-mapping mode, we must not only apply the ui scale factor but
		-- rather also apply the resolution-based-factor on top of this
		-- note: effectively we could simply call C.GetUIScale(false) here which atm is implemented to practically do the same, but then we'd rely on the current implementation details, rather than relying on the semantics of the
		--       function --- hence, go with the semantically correct implementation here
		local resolutionFactor = private.screenHeight / config.defaultScaleResolution
		private.uiScale = C.GetUIScale(true) * resolutionFactor
	end

	private.hudUIScale = C.GetHUDUIScale(not private.vrMode)

	-- velocity indicator
	private.velocityIndicator.element = getElement("velocityindicator", layerElement)
	private.velocityIndicator.materialElement = getElement("velocityindicator.velocityindicator", private.velocityIndicator.element)
	private.velocityIndicator.textureElement = getElement("velocityindicator.velocityindicator.ui_gradient_outline_01", private.velocityIndicator.element)
	private.velocityIndicator.size = config.velocityIndicator.size * private.hudUIScale
	private.velocityIndicator.size_offscreen = config.velocityIndicator.size_offscreen * private.hudUIScale

	-- note: we cannot create the target system clones on demand, since we are actively using the master version
	--       if we were to create the clones on demand, we'd basically clone whatever the state of the master version is at the time of cloning it (which would
	--       lead to issues like P1DEV-562)
	createTargetSystemClones(getElement("Target System", layerElement))

	registerForEvent("autotargetStateChanged", contract, callbacks.onAutotargetStateChanged)
	registerForEvent("enableDebugMousePickRendering", contract, callbacks.onEnableDebugMousePickRendering)
	registerForEvent("enableConfidenceBasedAutoTargetting", contract, callbacks.onEnableConfidenceBasedAutoTargetting)
	registerForEvent("enableDebugOutlines", contract, callbacks.onEnableDebugOutlines)
	registerForEvent("enableSofttargetDebugValues", contract, callbacks.onEnableSofttargetDebugValue)
	registerForEvent("enterInteractMenu", contract, callbacks.onEnterInteractMenu)
	-- #coreUILow - change event to firstPerson, ship or something more specific
	registerForEvent("gameplanchange", contract, callbacks.onGamePlanChange)
    registerForEvent("hudRenderStateChanged", contract, callbacks.onHUDRenderStateChanged)
	registerForEvent("inputModeChanged", contract, callbacks.onInputModeChanged)
	registerForEvent("interactMenuHidden", contract, callbacks.onInteractMenuHidden)
	registerForEvent("interactMenuShown", contract, callbacks.onInteractMenuShown)
	registerForEvent("playerKilled", contract, callbacks.onPlayerKilled)
	-- #coreUILow - consider dropping this setting - it hasn't been used in the past years
	registerForEvent("setObstructedByChildComponents", contract, callbacks.onSetObstructedByOwnComponents)
	registerForEvent("softtargetChanged", contract, callbacks.onSofttargetChanged)
	registerForEvent("setTargetConeMinDistance", contract, callbacks.onSetTargetConeMinDistance)
	registerForEvent("setTargetConeMidDistance", contract, callbacks.onSetTargetConeMidDistance)
	registerForEvent("setTargetConeMaxDistance", contract, callbacks.onSetTargetConeMaxDistance)
	registerForEvent("setTargetConeMinArea", contract, callbacks.onSetTargetConeMinArea)
	registerForEvent("setTargetConeMidArea", contract, callbacks.onSetTargetConeMidArea)
	registerForEvent("setTargetConeMaxArea", contract, callbacks.onSetTargetConeMaxArea)
	registerForEvent("setTargetConeThreshold", contract, callbacks.onSetTargetConeThreshold)
	registerForEvent("softtargetManagerActive", contract, callbacks.onSofttargetManagerActive)
	registerForEvent("softtargetManagerInactive", contract, callbacks.onSofttargetManagerInactive)
	registerForEvent("setMousePickingBorder", contract, callbacks.onSetMousePickingBorder)
	registerForEvent("updateColorMap", contract, callbacks.onUpdateColorMap)
	registerForEvent("updateUseFactionColorTargetSystem", contract, callbacks.onUseFactionColorChanged)

	-- setup gamepad specific visuals (must be called before setting the monitor mode since that relies on certain values (like private.firstPersonAutoTargeting) already having been set)
	callbacks.onInputModeChanged(nil, GetControllerInfo())

	if IsFirstPerson() then
		if C.IsExternalViewActive() then
			setExternalFirstPersonMode()
		else
			setFirstPersonMode()
		end
	elseif C.GetPlayerOccupiedShipID() ~= 0 then
		-- no difference between external and normal view in "ship" mode
		setShipMode()
	elseif C.IsExternalViewActive() then
		setExternalFirstPersonMode()
	end

    private.HUDEnabled              = C.IsHUDActive()
	private.softtargetManagerActive = C.IsSofttargetManagerActive()
	private.useFactionColor         = C.GetConfigSetting("factioncolortargetsystem")
end

function self:onUpdate()
	-- #coreUIMed - this should skip certain things which are not required if:
	-- HUD rendering is displayed
	-- player doesn't have player controls (no softtarget recalculation)

	-- #coreUIMed - consider moving setting the crosshairMessageID to the softtargetManager update cycle (where it'd actually logically belong to)
	--              maybe even inline in checkSofttargetChange() (since not required/used outside)
	local curtime = getElapsedTime()
	if private.autoCrosshairTargetSelection then
		local newcrosshairmessage = getCurrentCrosshairMessage()
		if newcrosshairmessage ~= private.crosshairMessageID then
			if private.pendingCrosshairMessage.id == newcrosshairmessage then
				if private.pendingCrosshairMessage.time + config.crosshairMessageDelay < curtime then
					private.crosshairMessageID = newcrosshairmessage
					private.pendingCrosshairMessage = {}
				end
			else
				private.pendingCrosshairMessage = { id = newcrosshairmessage, time = curtime }
			end
		else
			private.pendingCrosshairMessage = {}
		end
	end

	-- update current camera roll rotation value (if specified so)
	if private.counteractCameraRoll then
		private.cameraRoll = C.GetCameraRotation().roll
	end

	-- process pending connection/disconnection events
	processConnectionList()
	-- process state changes which are depending on the connection list having been processed
	updateSofttargetManagerActivationState()
	updateDebugOutlines()
	updateAllOutlines()

	-- process pending softtarget change
	processSofttargetChange()

	-- update all missile locks
	updateMissileLocks()

	-- process any pending enter interact menu event (after we updated the softtarget)
	processEnterInteractMenuEvent()

	-- get the list of connected target elements
	-- #coreUILow - we actually could maintain the connected target element list separately, sparing us the connected-check here and the need to create the temp-list
	local targetElements = {}
	for _, targetElement in ipairs(private.targetElements) do
		if targetElement.connected then
			table.insert(targetElements, targetElement)
		end
	end

	-- pass one - update target element data for connected target elements
	updateTargetElementData(targetElements)

	-- pass two - update all target elements (position, state, etc.)
	for _, targetElement in ipairs(targetElements) do
		updateTargetElement(targetElement)
	end

	-- pass three - perform the softtarget manager update at the end, since this can cause disconnection/reconnection of target elements, if the softtarget is changed
	updateSofttargetManager(targetElements)

	-- #coreUILow - this has room for improvements --- we could actually update the set softtarget already here, so that the visuals are not delayed by another frame --- however, this only impacts the
	-- old/new softtarget so it's just a minor improvement

	for key, time in pairs(private.disconnectedMissionTargets) do
		if time + 1 < curtime then
			private.disconnectedMissionTargets[key] = nil
		end
	end

	updateVelocityIndicator()
end

--------------------------------------
-- Target system specific callbacks --
--------------------------------------
function callbacks.onAutotargetStateChanged()
	-- #coreUIMed - redesign so we do track the autotarget state independent from the current mode
	callbacks.onInputModeChanged(nil, GetControllerInfo())
end

function callbacks.onGamePlanChange(_, gameplan)
	-- note: direct call here is fine - not touching any target element (which might be on the pending processing list for deletion)
	if gameplan == "firstperson" then
		setFirstPersonMode()
	elseif gameplan == "externalfirstperson" then
		setExternalFirstPersonMode()
	elseif C.GetPlayerOccupiedShipID() ~= 0 then
		setShipMode()
	elseif C.IsExternalViewActive() then
		setExternalFirstPersonMode()
	else
		resetTargetSystem()
	end
end

function callbacks.onEnableDebugMousePickRendering(_, enabled)
	private.enableMousePickDebug = enabled
end

function callbacks.onEnableConfidenceBasedAutoTargetting(_, enabled)
   private.useConfidenceBasedAutoTargetting = enabled

   DebugError("using confidence " .. tostring(enabled))
end

function callbacks.onEnableDebugOutlines(_, enabled)
	-- note: must not apply directly, since we change the component states for components which might already be destroyed,
	--       if the target element is on the processing list for deletion
	private.pendingDebugOutlines = enabled
end

function callbacks.onEnableSofttargetDebugValue(_, enabled)
	config.debugValuesEnabled = enabled
end

function callbacks.onEnterInteractMenu()
	-- #coreUIMed - the handling here is still flawed - if we call EnterInteractMenu(), we'd get the 'enterInteractMenu'-event the next cycle -
	-- if the target element which the enter interact menu event was triggered for (f.e. via a double click) changed in this frame, we'd then
	-- perform the open-handling for the wrong target element... (solution maybe: pass in the messageID the 'enterInteractMenu'-event was triggered for?)

	-- we cannot directly initiate the interact menu action here, since this could have been done as part of an instant interaction request (i.e. softtarget and enter interact menu events
	-- being issued at the same time). Since the softtarget change event is evaluated during the update-cycle, we'd try to execute the enter interact menu event on the wrong object (or skip it, if we didn't
	-- have a target before) - hence, just schedule it here and process it during the update cycle (related to XR-1322)
	private.performEnterInteractMenu = true
end

function callbacks.onHUDRenderStateChanged(_, state)
    private.HUDEnabled = state

	-- note: Must update all outlines, when we change the HUD render state. Cannot do this immediately though, since we might have pending deletions on the
	--       processing list and updateAllOutlines()-call changes the state of the components
	private.updateOutlines = true
end

function callbacks.onInputModeChanged(_, mode)
	-- note: direct call here is fine - not touching any target element (which might be on the pending processing list for deletion)
	if mode == "mouseSteering" or mode == "mouseCursor" then
		setMouseMode()
	elseif mode == "gamepad" then
		-- #coreUIMed - review whether we'd rather handle the IsAutotargetingActive() state completely independent from the input mode system and also have it active in mouse mode
		-- in 1st-person non-VR then the coreUI engine consistently (i.e. tangle it directly to IComManager::AutoTargetingActive)
		setGamepadMode(C.IsAutotargetingActive())
	elseif mode == "touch" then
		setTouchControllerMode()
	elseif mode == "joystick" then
		setJoystickMode(C.IsAutotargetingActive())
	else
		DebugError("Target System error. Input mode changed event retrieved for unsupported mode: "..tostring(mode))
	end
end

function callbacks.onInteractMenuHidden(_, messageID)
	-- direct call is safe here - we just update the target element state - if pending deletion, that would be reset afterwards when processing the pending
	-- connection/disconnection list
	local targetElement = getTargetElementByMessageID(messageID)
	if targetElement == nil then
		-- can happen, if the target element got disconnected in the current frame already
		return -- nothing to do in this case
	end

	-- note: must be set before updating the pointerID, since that uses the interactMenuOpen state
	targetElement.interactMenuOpen = false
end

function callbacks.onInteractMenuShown(_, messageID)
	-- direct call is safe here - we just update the target element state - if pending deletion, that would be reset afterwards when processing the pending
	-- connection/disconnection list
	local targetElement = getTargetElementByMessageID(messageID)
	if targetElement == nil then
		-- can happen, if the target element got disconnected in the current frame already
		return -- nothing to do in this case
	end

	-- note: must be set before updating the pointerID, since that uses the interactMenuOpen state
	targetElement.interactMenuOpen = true
end

function callbacks.onSetObstructedByOwnComponents(_, enabled)
	config.obstructedByOwnComponents = enabled
end

---------------------------------------
-- Target Element specific callbacks --
---------------------------------------
function callbacks.onMouseDown(element, delayed, modifiers)				handleMouseDown(element, delayed, 1, modifiers) end			-- LMB down
function callbacks.onMouseClick(element, delayed, modifiers)			handleMouseClick(element, delayed, 1, modifiers) end		-- LMB click
function callbacks.onMouseDblClick(element, delayed, modifiers)			handleMouseClick(element, delayed, 2, modifiers) end		-- LMB double-click

function callbacks.onRightMouseDown(element, delayed, modifiers)		handleMouseDown(element, delayed, 3, modifiers) end			-- RMB down
function callbacks.onRightMouseClick(element, delayed, modifiers)		handleMouseClick(element, delayed, 3, modifiers) end		-- RMB click
function callbacks.onRightMouseDblClick(element, delayed, modifiers)	handleMouseClick(element, delayed, 4, modifiers) end		-- RMB double-click

function callbacks.onMiddleMouseDown(element, delayed, modifiers)		handleMouseDown(element, delayed, 5, modifiers) end			-- MMB down
function callbacks.onMiddleMouseClick(element, delayed, modifiers)		handleMouseClick(element, delayed, 5, modifiers) end		-- MMB click
function callbacks.onMiddleMouseDblClick(element, delayed, modifiers)	handleMouseClick(element, delayed, 6, modifiers) end		-- MMB double-click

function callbacks.onSide1MouseDown(element, delayed, modifiers)		handleMouseDown(element, delayed, 7, modifiers) end			-- Side Mouse Button 1 down
function callbacks.onSide1MouseClick(element, delayed, modifiers)		handleMouseClick(element, delayed, 7, modifiers) end		-- Side Mouse Button 1 click
function callbacks.onSide1MouseDblClick(element, delayed, modifiers)	handleMouseClick(element, delayed, 8, modifiers) end		-- Side Mouse Button 1 double-click

function callbacks.onSide2MouseDown(element, delayed, modifiers)		handleMouseDown(element, delayed, 9, modifiers) end			-- Side Mouse Button 2 down
function callbacks.onSide2MouseClick(element, delayed, modifiers)		handleMouseClick(element, delayed, 9, modifiers) end		-- Side Mouse Button 2 click
function callbacks.onSide2MouseDblClick(element, delayed, modifiers)	handleMouseClick(element, delayed, 10, modifiers) end		-- Side Mouse Button 2 double-click

-- Handle mouse-down event
function handleMouseDown(element, delayed, mousebuttonid, modifiers)
	--print(string.format("handleMouseDown(element=%s, delayed=%s, mousebuttonid=%s modifiers=%s)", tostring(element), tostring(delayed), tostring(mousebuttonid), tostring(modifiers)))

	-- By default, LMB and RMB get blocked for default input mapping when the mouse cursor is over an Anark element.
	-- For Anark elements in the target system, allow standard input handling, i.e. unblock it (enabling custom input mappings for LMB and RMB).
	-- We can still decide in handleMouseClick() whether it should be blocked again for clicks on target elements.
	C.SetMouseInputBlockedByAnarkElement(mousebuttonid, modifiers, false)
end

-- Handle mouse-click event (i.e. mouse button was released on the same Anark element on which it was pressed)
function handleMouseClick(element, delayed, mousebuttonid, modifiers)
	if isFirstPersonMode() then
		return -- special case: mouse clicks in first person are always handled in engine
	end
	local inputstate = ffi.string(C.GetCurrentTargetMouseButtonMapping(mousebuttonid, modifiers, true))
	if inputstate ~= "" then
		--print(string.format("handleMouseClick(element=%s, delayed=%s, mousebuttonid=%s modifiers=%s), mapped as %s", tostring(element), tostring(delayed), tostring(mousebuttonid), tostring(modifiers), inputstate))

		-- The mouse click is mapped to a TARGETMOUSE state in the input system. Since we handle that here, we have to notify the input system that the mouse input is blocked,
		-- preventing the default target mouse handling (for clicks outside of an Anark element, e.g. on object geometry or in empty space).
		-- Normally we can only block input when the button is pressed, not on release (see handleMouseDown()) because we cannot change our mind once the input handling has started -
		-- however, for TARGETMOUSE states it is guaranteed that the input is only handled on button-up, not on button-down, so it is not too late.
		C.SetMouseInputBlockedByAnarkElement(mousebuttonid, modifiers, true)

		if inputstate == "INPUT_STATE_TARGETMOUSE_SELECT" then
			-- in touch controller/gamepad mode, INPUT_STATE_TARGETMOUSE_SELECT opens an interact menu on already selected target (unlike in mouse mode)
			performSelectSofttargetOnClick(element, delayed, false, (not private.mouseMode))
		elseif inputstate == "INPUT_STATE_TARGETMOUSE_INTERACTION_MENU" then
			performSelectSofttargetOnClick(element, delayed, true, true)
		elseif inputstate == "INPUT_STATE_TARGETMOUSE_SELECT_AND_INTERACT" then
			performSelectSofttargetOnClick(element, delayed, false, true)
		else
			DebugError("Target System error. Unhandled target mouse button mapping: " .. inputstate)
		end
	end
end

function performSelectSofttargetOnClick(element, delayed, instantinteract, interactwithselectedtarget)
	--print(string.format("  performSelectSofttargetOnClick(instantinteract=%s, interactwithselectedtarget=%s)", instantinteract, interactwithselectedtarget))

	local targetElement = private.targetElements[private.mouseElements[element]]
	if isTargetElementPendingDeletion(targetElement) then
		-- do not evaluate the click action onto the target element which is about to be deleted - otherwise SetSofttarget() call below could produce an
		-- error, if the component was destroyed already, and/or we'd get an enterInteractMenu-event the next frame for a target element which was already destroyed
		-- (performing the interaction event on the wrong target then)
		if not instantinteract then
			-- mouse click to select a target (which is outside of any open menu) closes menus
			CloseMenusUponMouseClick()
		end
		return
	end

	if targetElement.softtarget then
		-- a delayed click on the target does not open the interact menu (i.e. it will issue a different click action on the element which was not delayed)
		if (instantinteract or interactwithselectedtarget or targetElement.isDetailElement) and (not delayed) then
			C.EnterInteractMenu()
		elseif not instantinteract then
			-- mouse click to select a target (which is outside of any open menu) closes menus
			CloseMenusUponMouseClick()
		end
	else
		if not instantinteract then
			-- mouse click to select a target (which is outside of any open menu) closes menus
			CloseMenusUponMouseClick()
		end
		-- note: we cannot use the private.softtargetManagerActive state here, since that one is set/updated as a result of dispatched events
		-- since the mouse-click event could have been fired before the softtargetmanager update event, the state might not be updated yet
		-- (hence directly check the current state)
		if not C.IsSofttargetManagerActive() then
			-- softtarget manager inactive atm
			-- most likely we retrieved a mouse-click-event which was issued on a target element which was still rendered (and hence the mouse-click event was scheduled before the Anark element was hidden)
			-- valid call, but nothing to do
			return
		end
		if delayed then
			-- in case of a click on a delayed target (i.e. a target that has moved away from the mouse cursor in the previous frame), we do NOT perform an instant interaction
			-- (to prevent issues with opening the target element on a fast-moving object).
			instantinteract = false
		end
		if targetElement.currentState ~= "inactive" and C.IsTargetable(targetElement.messageID) then
			-- i.e. not the current softtarget and not an inactive target -> make it the softtarget
			-- note: we must still check the current IsTargetable() state here, since the callback is issued before we reevaluate the target element (hence the current "inactive" state could be outdated and is just about to be changed
			--       in which case we don't want to set the target to the untargetable object)
			-- In first-person mode we instantly interact with the target even if instantinteract is false (when handling INPUT_STATE_TARGETMOUSE_SELECT*).
			-- Note that 1st-person mode here means the mode the target system is put in (in contrast to the game 1st-person mode).
			-- Since in external 1st-person view mode the target system is actually not in 1st-person we do not (incorrectly) issue a click as an instant interact click and all is fine with the sole isFirstPersonMode()
			-- check here.
			local success = SetSofttarget(targetElement.messageID, instantinteract or isFirstPersonMode(), true)
			if not success then
				DebugError("Target System warning. Mouse-click on target element failed to select softtarget.")
			end
		end
	end
end

function callbacks.onMouseOver(element)
	-- #coreUILow - design flaw --- the mouse-over might be on a target element which is pending deletion - we would then set the mouseOver to
	-- that disconnectiong element which is wrong at least for one frame then (until we get the mouse-out-event)
	-- we however cannot easily disregard the call here, since if we reconnect said element, the game engine would not recognize this as a change of the
	-- element this is pointed at, if the position of the new element is the same as the old one (therefore not sending another mouse-over event for us)
	-- proper handling would be to evaluate the pending connection/disconnection list and update the mouseOverTargetElement there as follows:
	-- reset to nil, if the target element was only disconnected (but not reconnected to a different element); noop, if a reconnection event occurred
	private.mouseOverTargetElement = private.targetElements[private.mouseElements[element]]
end

function callbacks.onMouseOut()
	private.mouseOverTargetElement = nil
end

------------------------------------------
-- SofttargetManager specific callbacks --
------------------------------------------
function callbacks.onConnectElement(targetSystem, messageID, posID)
	private.connectionList[targetSystem] = {
		type = "connect",
		messageID = messageID,
		posID = posID
	}
end

function callbacks.onDisconnectElement(targetSystem)
	private.connectionList[targetSystem] = {
		type = "disconnect",
		-- #coreUIMed - review - actually redundant, no? (just use the index)
		targetSystem = targetSystem
	}
end

function callbacks.onPlayerKilled()
	-- direct call fine here - if this is triggered before or after the incoming connection/disconnection events doesn't have an effect - so we can just
	-- call this in the sequence the events arrive
	resetTargetSystem()
end

function callbacks.onSetTargetConeMinDistance(_, value)
	config.targetMinDistance = value^2
end

function callbacks.onSetTargetConeMidDistance(_, value)
	config.targetMidDistance = value^2
end

function callbacks.onSetTargetConeMaxDistance(_, value)
	config.targetMaxDistance = value
end

function callbacks.onSetTargetConeMinArea(_, value)
	config.targetMinArea = value/100
end

function callbacks.onSetTargetConeMidArea(_, value)
	config.targetMidValue = value/100
end

function callbacks.onSetTargetConeMaxArea(_, value)
	config.targetMaxArea = value/100
end

function callbacks.onSetTargetConeThreshold(_, value)
	config.targetAreaThreshold = value/100
end

function callbacks.onSetMousePickingBorder(_, value)
	config.mousePickingBorder = value
end

function callbacks.onSofttargetManagerActive()
	if private.pendingSofttargetManagerStateChange ~= nil or not private.softtargetManagerActive then
		if not private.softtargetManagerActive then
			private.pendingSofttargetManagerStateChange = true
		else
			-- no state change required, if the softtarget manager is already active
			private.pendingSofttargetManagerStateChange = nil
		end
	end
end

function callbacks.onSofttargetManagerInactive()
	if private.pendingSofttargetManagerStateChange ~= nil or private.softtargetManagerActive then
		if private.softtargetManagerActive then
			private.pendingSofttargetManagerStateChange = false
		else
			-- no state change required, if the softtarget manager is already inactive
			private.pendingSofttargetManagerStateChange = nil
		end
	end
end

function callbacks.onSofttargetChanged(_, newSofttargetMessageID)
	if newSofttargetMessageID == nil then
		private.pendingSofttargetMessageID = ""
	else
		private.pendingSofttargetMessageID = newSofttargetMessageID
	end
end

function callbacks.onUpdateColorMap()
	getColors()
end

function callbacks.onUseFactionColorChanged()
	private.useFactionColor = C.GetConfigSetting("factioncolortargetsystem")
end

-------------------------------------
-- Target system related functions --
-------------------------------------
function connectTargetElement(targetElement, messageID, posID)
	local _, _, numActions, instantAction, displayState, _, numDisplayedActions, actionPointer, selectedActionIcon, activeActionIcon, inactiveActionIcon = GetActionInfo(messageID)
	numActions = numActions or 0
	numDisplayedActions = numDisplayedActions or 0

	resetElement(targetElement)

	-- #coreUILow - move this to connectElement()?

	local messageDetails = C.GetMessageDetails3(messageID)
	targetElement.isMissionTarget           = messageDetails.isMissionTarget
	targetElement.priorityMissionTarget     = messageDetails.isPriorityMissionTarget
	targetElement.componentID               = messageDetails.componentID
	targetElement.connectionName            = ffi.string(messageDetails.connectionName)
	targetElement.isZoneLocation            = C.IsZone(targetElement.componentID)
	targetElement.hasMissionTargetAdditionalOffset = messageDetails.isMissionTarget and messageDetails.hasAdditionalOffset
	targetElement.isKnown                   = C.IsObjectKnown(targetElement.componentID) or targetElement.isZoneLocation -- hacky, but we need to handle zone locations alike and the zone the user set the point to might not "technically" be known just yet
	targetElement.ignoreActionsOnTargeting  = messageDetails.isAssociative
	-- #coreUIMed - this should actually just prevent repings of target elements - atm it can also prevent initial pings, if an initial message indicated showIndicator and then was replaced with a
	-- message indicating no showIndicator - if only the second message makes it into the system, no initial ping will be displayed - see XR-734
	targetElement.indicatorElementActivated = not messageDetails.showIndicator
	targetElement.instantAction             = instantAction
	targetElement.posID                     = posID
	-- #coreUILow - review storage of messageID --- remove, once proper Softtarget-system is implemented in C and we no longer need to store the messageID here
	targetElement.messageID                 = messageID
	targetElement.numActions                = numActions
	-- #coreUILow - check if we shouldn't remove setting this here --- the numDisplayedActions value is updated each update cycle anyway so it shouldn't be needed here, should it?
	targetElement.numDisplayedActions       = numDisplayedActions
	targetElement.connected                 = true
	targetElement.actionPointer             = actionPointer
	targetElement.onScreen					= nil

	-- initialize the remaining target element data (i.e. dynamic one, which is dependent whether the object is known or unknown)
	initDynamicTargetElementData(targetElement, messageDetails)

	-- initialize the target element's visual elements
	initTargetElement(targetElement, displayState, selectedActionIcon, activeActionIcon, inactiveActionIcon)

	-- false => newly connected targets are never the softtarget initially
	updatePointerOverride(targetElement, actionPointer, false, instantAction)

	if config.enableDebugOutlines then
		showDebugOutline(targetElement)
	end

	-- #coreUILow - API-wise suboptimal - if we'd get two priority mission targets, the later would overwrite
	--              the former / practically the engine prevents this happening atm, but it would be better to
	--              ensure this through a clean API in the first place
	if targetElement.priorityMissionTarget then
		changePriorityMissionTarget(targetElement)
	end

	if targetElement.isMissionTarget then
		-- keep track of all missiontarget posIDs
		C.NotifyMissionPosIDConnected(targetElement.posID)
	end

	-- set the initial/default rectangular target element size (used for cases like hull/shield bar width determination even in non-rectangular modes)
	-- note: will be replaced in activateRectangularElements() if the the rectangle mode is activated
	if private.useWorldSpacePositions then
		targetElement.minRectangleSize = config.minNormalRectangleWorldSize
	else
		targetElement.minRectangleSize = config.minNormalRectangleScreenSize
	end
end

-- constructs a new data-entry for the given element ID
function constructTargetElementData()
	return {
		targetSystem                 = nil,         -- the target system element
		bottomElement                = nil,         -- the bottom element containing the bottom text element
		bottomTextElement            = nil,         -- the bottom text element (POI text)
		sideElement                  = nil,         -- the side element
		sideTextElement              = nil,         -- the side text element
		sideElement2                 = nil,         -- the 2nd side element
		sideTextElement2             = nil,         -- the 2nd side text element
		commanderElement             = nil,         -- the commander element
		commanderIconElement         = nil,         -- the commander icon's element
		commanderMaterialElement     = nil,         -- the commander icon's material element
		collectableTextureElement    = nil,         -- the collectable texture element
		missionTargetElement         = nil,         -- the mission target element (overlay for mission target)
		mainTextureElement           = nil,         -- the main texture element containing the target element icon
		mainTextureTextureElement    = nil,         -- the texture element of the main texture element containing the target element icon
		mainTextureMaterialElement   = nil,         -- the material element of the main texture element containing the target element icon
		priorityMissionTargetElement = nil,         -- the priority mission target element (overlay for priority mission target)
		additionalIcons              = {            -- list of additional icons (and their associated data/elements)
			-- [x]                   = { -- the additional icon (1..4)
				-- ["element"]         -- the icon element
				-- ["materialElement"] -- the icon element's texture element
				-- ["modelElement"]    -- the icon element's model element
				-- ["textureElement"]  -- the icon element's texture element
				-- ["active"]          -- indicates whether the icon is active
				-- ["textures"] = {
					-- ["active"]   -- icon in the active state
					-- ["inactive"] -- icon in the inactive state
					-- ["select"]   -- icon in the selected state
				-- }
			--}
		},
		offScreenBoxElement          = nil,         -- the off-screen box element
		coloredRectangleElements     = nil,         -- list of rectangle elements which need to be colored
		-- {
			-- element1,
			-- element2,
			-- [...]
		-- }
		hullShieldElement            = nil,         -- the hull/shield Anark element
		hullElement                  = nil,         -- the hull element
		rectangleAnarkElement        = nil,         -- the rectangle Anark element (main rectangle component)
		rectangleNormalElement       = nil,         -- the current active rectangle element (if any is active atm)
		rectangleMissionElement      = nil,         -- the rectangle mission element (if one is active for the target element)
		rectangleSofttargetElement   = nil,         -- the rectangle softtarget element (note: doesn't mean the element is active atm - just defines the element representing the rectangular softtarget element)
		rectangleTargetElement       = nil,         -- the rectangle target element (note: doesn't mean the element is active atm - just defines the element representing the rectangular softtarget element)
		shieldElement                = nil,         -- the shield element
		componentID                  = nil,         -- the componentid associated with the displayed ui element
		connectionName               = "",          -- the connection name assoicated with the displayed ui element
		messageID                    = nil,         -- the message ID associated with the displayed ui element
		messageType                  = nil,         -- the message type associated with the displayed ui element
		softtarget                   = false,       -- indicates whether the element is the softtarget
		icon                         = nil,		 -- the icon which is to be used (in all relevant states)
			-- ["active"]    -- icon in the active state
			-- ["inactive"]  -- icon in the inactive state
			-- ["select"]    -- icon in the selected state
		posID                        = nil,         -- ID of the associated ui element
		currentState                 = "undefined", -- the current state of the element ("undefined"|"inactive"|"active"|"selected")
		numActions                   = 0,			 -- number of actions (including currently impossible ones)
		numDisplayedActions          = 0,           -- number of displayed actions
		curObstructed                = nil,         -- storage of current obstruction state
		inWeaponRange                = nil,         -- storage of the current in weapon range state
		targetable                   = nil,         -- storage of current targetable state
		aimPos                       = {},          -- storage of current aim indicator pos
		colorMode                    = "",          -- the current color mode (i.e. eihter "" (uninitialized), "obstructed", or "normal")
		curScreenPos                 = {},          -- storage of current screen pos information
		curRelation                  = 6,           -- indicates the target element's current relation (0 -> hostile, 1 -> enemy, 2 -> neutral, 3 -> friendly, 4 -> player owned, 5 -> unknown/uninitialized)
		curOwningFactionID           = "",          -- storage of ID of the faction currently owning this object
		centerPointCameraDistance    = nil,         -- the current distance of the target element to the camera (note: this is the distance of the object's center point to the camera)
		cameraDistance               = nil,         -- the current distance of the target element to the camera (note: this is the distance based on the object's bounding box and/or its parts (in case of a detailed element like a pilot chair))
		distance                     = nil,         -- current target element distance
		filled                       = false,       -- indicates whether or not we use a fill effect to display the target element
		sideText                     = "",          -- displayed side text (usually distance or NPC name)
		sideText2                    = "",          -- displayed 2nd side text (usually speed)
		sideTextPosition             = "right",     -- the "position" of the side text (i.e. whether it's displayed on the "right" or "left" side of the element)
		indicatorElementActivated    = false,       -- indicates whether the target indicator was activated for the target element since its last deactivation
		obstructedByOwnComponent     = false,       -- indicates whether the target element can be obstructed by the attached component's geometry or its children
		previousDistance             = 0,           -- distance used, if real distance returns garbage --- temporarily while disconnection logic is not in
		isAdvancedSatellite          = false,       -- indicates whether this is an advanced satellite
		isBomb                       = false,       -- indicates whether this is a bomb
		isCollectable                = false,       -- indicates whether this is a collectable
		isKnown                      = false,       -- indicates whether the target is known (i.e. all details displayed instead of it being displayed as an unknown object)
		isDetailElement              = false,       -- indicates whether this is a detail element (i.e. pilot chair)
		isGate                       = false,       -- indicates whether this is a gate
		isZoneHighway                = false,       -- indicates whether this is a zone highway
		isSuperHighway               = false,       -- indicates whether this is a super highway
		isLockbox                    = false,       -- indicates whether this is a lockbox
		isMine                       = false,       -- indicates whether this is a mine
		isMissionTarget              = false,       -- indicates whether the target element represents a mission target
		isNavBeacon                  = false,       -- indicates whether this is a nav beacon
		isResourceProbe              = false,       -- indicates whether this is a resource probe
		isSatellite                  = false,       -- indicates whether this is a satellite
		isRecyclable                 = false,       -- indicates whether this is a recyclable
		isZoneLocation               = false,       -- indicates whether this is a zone location
		hasMissionTargetAdditionalOffset = false,	-- indicated whether this target has an additional offset
		isDataVault                  = false,       -- indicates whether this is a data vault
		isLandmark                   = false,       -- indicates whether this is a landmark
		hullShieldActive             = false,       -- indicates whether hull/shield elements are active
		outlined                     = false,       -- indicates whether or not we use outlines to display the target element
		connected                    = false,       -- indicates whether the target element is connected
		offScreenBoxMode             = "inactive",  -- the current offscreen box mode (i.e. "inactive", "target", "mtarget", or "mtarget_select")
		collectableActive            = false,       -- indicates whether the collectable icon is active
		activeOutline                = nil,         -- the outline color details, if the target element is set to have one
        -- {
            -- color = {
                -- r = red
                -- g = green
                -- b = blue
            -- }
        -- }
		activeFill                   = nil,         -- the fill color details, if the target element is set to have one
        -- {
           -- color = {
              -- r     = red
              -- g     = green
              -- b     = blue
              -- alpha = alpha
           -- }
           -- animated       = boolean
           -- minAlpha       = min alpha value
           -- maxAlpha       = max alpha value
           -- transitionTime = time (in s) for the animated transition
        -- }
		iconActive                   = false,       -- indicates whether the target element uses an icon representation (can be main element or just a subelement (like the collectable ring))
		iconElementsActive           = false,       -- indicates whether the target element icon elements (mission target elements) are active
		bottomText                   = "",          -- bottom text which is currently displayed
		displayedBottomText          = "",          -- bottom text which is used, if displayed
		distanceZ                    = nil,         -- the distance-based z-position for the target element (used, unless for the softtarget or the interact menu target)
		targetElementColor           = nil,         -- the current color of the target element (except for the icon and outline color)
		iconColor                    = nil,         -- the current color of the icon part of the target element
		outlineColor                 = nil,         -- the current color of the target element in outline mode
		textColor                    = nil,         -- the current color of the target element's text elements
		curHullValue                 = nil,         -- the current hull value displayed on the target element
		curShieldValue               = nil,         -- the current shield value displayed on the target element
		instantAction                = false,       -- indicates whether the connected message is an instant action
		indicatorElementActived      = false,       -- indicates whether the indicator element has been activated since its last deactivation
		actionPointer                = nil,         -- the associated action pointer (if any)
		interactMenuOpen             = false,       -- indicates whether the interact menu is open for this target element
		showInWeaponRangeState       = false,       -- indicates whether the target element will display whether it is in or out of weapon range
		surfaceElement               = false,       -- indicates whether we are a surface element
		ignoreActionsOnTargeting     = false,       -- indicates whether the target element ignores the state of its actions, to determine whether it's active or inactive (aka: always active)
		displayedNotified            = false,       -- indicates whether the message was already notified of being displayed
		iconSize                     = 0,           -- the actual size of the icon (0 indicating unset size)
		poiType                      = "",          -- the POI type associated with the target element (nil indicating not a POI)
		displayMode                  = nil,         -- the display mode for the target element (valid modes are: nil, "icon", "outline", or "rectangle")
		onScreen                     = nil,         -- whether the targetElement is on screen
		onScreenDisplayMode          = nil,         -- the display mode for the target element when it's on-screen (valid modes are: nil, "icon", "outline", or "rectangle")
		rectangleType                = "normal",    -- in rectangle display mode indicates what kind of rectangle mode we use (valid modes are: "normal" and "short")
		shipOrLaserTowerSize         = nil,         -- represents the ship size (access via getShipOrLaserTowerSize())
		minRectangleSize             = nil,         -- the minimum size for this target element's rectangular elements
		isShip                       = false,       -- indicates whether the target element represents a ship
		isDestructible               = false,       -- indicates whether the target element represents a destructible object
		isStationary                 = false,       -- indicates whether the target element represents a stationary object
		priorityMissionTarget        = false,       -- indicates whether the target element is the priority mission target
		rectanglePos                 = nil,         -- positions of the rectangle elements
		-- {
			--[upperleft] = {
				-- [x] = x-poisition
				-- [y] = y-poisition
			-- },
			--[upperright] = {
				-- [x] = x-poisition
				-- [y] = y-poisition
			-- },
			--[lowerleft] = {
				-- [x] = x-poisition
				-- [y] = y-poisition
			-- },
			--[lowerright] = {
				-- [x] = x-poisition
				-- [y] = y-poisition
			-- },
		-- }
		targetsystemPickElements     = {             -- list of elements which will be handled as the main target element (aka: clicking => action/interact menu, hovering => target pointer)
			-- [x] = element
		},
		isRectangleShown = nil,
		isSofttargetRectangleShown = nil,
		isTargetSystemSlideActive = nil,
	}
end

function createSink(sinkname, numElements)
	local availableTargetElements = #private.targetElements - private.curSinkAssignedTargetElements
	-- #coreUIMed - activate to make self-documenting
	--assume(availableTargetElements >= numElements)

	local startIndex = #private.targetElements - availableTargetElements
	private.curSinkAssignedTargetElements = startIndex + numElements

	if numElements == 0 then
		return -- nothing to do (simply skip the call) --- support added for easier debugability to change/disable entire sinks via config settings
	elseif numElements == 1 then
		-- explicittarget sink is a special case only used to show a single element (current target) --- hence it's fine for this sink to be constructed with a single element
		if sinkname ~= "explicittarget" then
			DebugError("Target System warning. Sink "..tostring(sinkname).." set up to contains a single element. This element will be reserved for mouse-picking - resulting in no element being visible. Increase to 2 (at least) to get visible elements.")
		end
	end

	local poselements = {}
	-- one element reserved for the "forced element" - aka the one used for left mouse button click
	for i = 1, numElements - 1 do
		poselements[i] = private.targetElements[startIndex + i].targetSystem
	end

	CreateSink(sinkname, poselements, private.targetElements[startIndex + numElements].targetSystem)
end

function resetTargetSystem()
	DumpAllMessageSources()
	DumpAllMessageSinks()
	private.curSinkAssignedTargetElements = 0

	-- reset connection list, in case we got a connection/disconnection event right before the target system was reset
	private.connectionList = {}

	-- reset pending softtarget change
	private.pendingSofttargetMessageID = nil

	-- reset the mouseOver target element
	private.mouseOverTargetElement = nil

	-- see comment in onInitialize for the reason
	-- #coreUIMed - redesign --- atm we rely on this call being done after DumpAllMessageSinks() since that puts messages back onto the waiting queue which are then to be removed via DumpAllMessages()
	DumpAllMessages()

	-- reset all elements (none are considered connected anymore, after we dumped everything)
	for _, targetElement in ipairs(private.targetElements) do
		resetElement(targetElement)
		-- note: we explicitly deactivate the main element here (even if it was already deactivated before) to solve the problem of not having retrieved (or skipped by clearing the connectionList) a disconnection event
		-- if we wouldn't, we could end-up with disconnected target elements, still being rendered
		-- #coreUIMed: combine with disconnectElement() / resetElement()
		goToSlide(targetElement.targetSystem, "inactive")
		targetElement.isTargetSystemSlideActive = false
	end

	-- and the same goes for the softtarget system ones
	changePriorityMissionTarget(nil)
	-- remove tracked mission targetelements
	C.NotifyMissionPosIDConnected(-1)
	RemoveSofttarget()
	changePendingSofttarget(nil)

	-- note: special case - it's not sufficient to call RemoveSofttarget() here, since that just schedules the softtarget-change-event - that would be processed the next frame only, while we
	-- already reset the actual element (and hence invalidated the data) -> private.currentSofttarget could still reference an already reset element
	updateSofttargetTargetElement(nil)
	private.targetSystemMode = nil
end

function setExternalFirstPersonMode()
	-- target element settings specific to external 1st-person mode
	private.missileLocksEnabled     = false
	private.aimTargetElementEnabled = false
	private.velocityIndicatorEnabled = false

	-- make sure the elements are deactivated
	-- (note: should be, since we do not trigger a direct mode switch from ship mode <-> external first person mode atm, but in case we ever will, this would prevent issues)
	deactivateAimTargetElement()
	deactivateMissileLocks()

	-- in external 1st-person mode, the target system is in space mode
	setSpaceMode()
end

function setFirstPersonAutoTargeting(enable)
	private.firstPersonAutoTargeting = enable

	if isFirstPersonMode() then
		-- in 1st-person mode we must propagate the change correctly to private.autoCrosshairTargetSelection (\see setFirstPersonMode())
		setAutoCrosshairTargetSelection(private.firstPersonAutoTargeting)
	end
end

function setFirstPersonMode()
	if isFirstPersonMode() then
		return -- already in first person mode
	end

	resetTargetSystem()

	-- target system settings
	CreateSource("basicfirstperson")
	CreateSource("explicittarget")
	CreateSource("firstpersondetails")
	CreateSource("missionobjective")
	CreateSource("npc")
	createSink("explicittarget", 1)
	createSink("firstperson", config.numFirstPersonTargets)
	createSink("firstpersonmissionobjective", config.numMissionTargets)

	-- target element size settings
	private.reservationSize = math.ceil(config.targetElementIconSizePlatform * private.uiScale)
	-- we only support equal (i.e. not odd) sizes for icons (due to subpixel positioning issues in 1:1-mapping)
	-- hence reduce the size by 1 again, if it's an odd number (note: reducing rather than increasing since we ceiled the value already above --- hence
	-- reducing the value would be closer to the actual calculated (i.e. scaled) value)
	private.reservationSize = private.reservationSize - (private.reservationSize % 2)

	-- softtarget manager settings
	private.newTargetDelay = config.minFirstPersonDelay

	-- target element settings
	private.sideTextMode            = "name"
	private.autoTargetSelection     = private.firstPersonAutoTargeting
	private.speedDisplayEnabled     = false
	-- note: no need to reset the aim-at target indicator - that's done implicitly via the resetTargetSystem() call
	private.aimTargetElementEnabled = false
	setAutoCrosshairTargetSelection(private.firstPersonAutoTargeting)
	deactivateMissileLocks()

	private.targetSystemMode = "firstPerson"
end

function setGamepadMode(autotargetingModeActive)
	private.autoTargetSelection  = autotargetingModeActive or isFirstPersonMode()
	-- in VR mode, we do not center the interact menu (it should only be fixed at its position)
	private.cockpitAutoTargeting = true
	private.mouseMode            = false

	setFirstPersonAutoTargeting(true)
end

function setJoystickMode(autotargetingModeActive)
	private.autoTargetSelection  = autotargetingModeActive or isFirstPersonMode()
	private.cockpitAutoTargeting = autotargetingModeActive
	private.mouseMode            = false

	setFirstPersonAutoTargeting(true)
end

function setMouseMode()
	private.autoTargetSelection  = isFirstPersonMode() and not private.vrMode
	private.cockpitAutoTargeting = false
	private.mouseMode            = true

	setFirstPersonAutoTargeting(not private.vrMode)
end

function setShipMode()
	-- target element settings specific to ship mode
	private.missileLocksEnabled     = true
	private.aimTargetElementEnabled = true
	private.velocityIndicatorEnabled = true

	setSpaceMode()
end

function setSpaceMode()
	if private.targetSystemMode == "space" then
		return -- already in space mode
	end

	resetTargetSystem()

	-- target system settings
	CreateSource("basic")
	CreateSource("explicittarget")
	CreateSource("fastobject")
	CreateSource("missionobjective")
	CreateSource("missionoffer")
	CreateSource("playercapship")
	CreateSource("poi")
	createSink("explicittarget", 1)
	createSink("fastobject", config.numFastMovingTargetElements)
	createSink("multievent", config.numTargetElements)
	createSink("spacemissionobjective", config.numMissionTargets)
	createSink("poi", config.numPOITargets)
	createSink("playercapship", config.numPlayerCapShips)

	-- target element size settings
	private.reservationSize = math.ceil((config.targetElementIconSize + config.hullShieldBarReservationHeight) * private.uiScale)
	-- we only support equal (i.e. not odd) sizes for icons (due to subpixel positioning issues in 1:1-mapping)
	-- hence reduce the size by 1 again, if it's an odd number (note: reducing rather than increasing since we ceiled the value already above --- hence
	-- reducing the value would be closer to the actual calculated (i.e. scaled) value)
	private.reservationSize = private.reservationSize - (private.reservationSize % 2)

	-- softtarget manager settings
	private.newTargetDelay = config.minSpaceDelay

	-- target element settings
	private.sideTextMode            = "distance"
	private.autoTargetSelection     = private.cockpitAutoTargeting
	private.speedDisplayEnabled     = true
	setAutoCrosshairTargetSelection(false)

	private.targetSystemMode = "space"
end

function setTouchControllerMode()
	private.autoTargetSelection  = false
	private.cockpitAutoTargeting = false
	private.mouseMode            = false

	setFirstPersonAutoTargeting(false)
end

function updateSofttargetTargetElement(messageID)
	if private.currentSofttarget ~= nil and private.currentSofttarget.messageID == messageID then
		return -- nothing to do - current softtarget is already the requested one
	end

	if private.currentSofttarget ~= nil then
		-- we intentionally do not check targetElement.connected in this case, so that resetting the softtarget state works at least (even if the element was already disconnected)
		-- got a different softtarget, unselect the current one
		deactivateAimTargetElement()
		deactivateTargetRectangle(private.currentSofttarget)

		private.currentSofttarget.softtarget = false
		private.currentSofttarget = nil
	end

	if messageID == nil then
		return -- done -- we just had to unset the current softtarget
	end

	-- #coreUIMed - refactor so we directly work with the element with the correct messageID (runtime O(n) -> O(1))
	for _, targetElement in ipairs(private.targetElements) do
		if targetElement.messageID == messageID then
			-- #coreUIMed - the following check is only required atm, since messageID is not reset upon disconnecting the element directly
			-- this was used to be required for the disconnecting-element effect/animation and might actually now be deprecated and could be removed/simplified
			-- currrently this check prevents the condition that two target elements are flagged as the softtarget (one which is currently connected to the messageID and one which was connected
			-- to the messageID before)
			if targetElement.connected then
				-- only set as softtarget, when we are connected

				targetElement.softtarget = true
				targetElement.softtargetAnimationStart = getElapsedTime()
				private.currentSofttarget = targetElement

				-- we just became the softtarget
				if not isFirstPersonMode() then
					-- sound effects on softtarget change are only triggered in space mode
					PlaySound("ui_soft_select_hud_core")
					PlaySound("ui_soft_select_tech_core")
				end

				if private.aimTargetElementEnabled and targetElement.showInWeaponRangeState then
					activateAimTargetElement()
				end

				if not hasActions(targetElement) then
					-- if we became the softtarget which isn't interactive, set the pointer ID to the "default" (i.e. either arrow- or fly-to-pointer)
					setPointerOverride(targetElement, config.defaultPointerID)
				end

				if targetElement.rectangleNormalElement ~= nil or targetElement.rectangleMissionElement ~= nil then
					activateTargetRectangle(targetElement)
				end
			end
		end
	end
end

------------------------------------------
-- Softtargetmanager specific functions --
------------------------------------------
function calculateTargetPriority(x2d, y2d, cameraDistance)
	-- calculation goes like this:
	-- distance between 2d-position and center of screen (crosshair) is:
	--	d = sqrt(x^2 + y^2)
	-- cosine of the distance is cos(d / (pixelsAt90Degree) * pi/4 (90 degree))
	-- pixelsAt90Degree = screenWidth / 2 in our case, since the camera settings are set to ensure a 1:1-mapping
	local cosine = math.cos(math.sqrt(x2d*x2d + y2d*y2d)/(private.screenWidth/2) * math.pi / 4)
	-- cap the cosine at 0 (no negative priorities)
	cosine = math.max(cosine, 0)
	return 300000 * cosine - cameraDistance
end

function cameraDistanceSorter(a, b)
	if a.size == b.size then
		if a.cameraDistance == nil then
			return false
		end

		if b.cameraDistance == nil then
			return true
		end

		return a.cameraDistance < b.cameraDistance
	end
	return a.size < b.size
end

function canMessageBeSofttarget(targetElement)
	-- targets in their inactive state cannot be softtargeted
	-- all other targets can always become the softtarget
	return not isInactiveTargetElementState(targetElement)
end

function changePendingSofttarget(newSofttarget)
	private.pendingSofttarget = newSofttarget
	if newSofttarget and private.pendingSofttarget.messageID == nil then
		private.pendingSofttarget.messageID = newSofttarget.targetElement.messageID
	end
	private.previousTriedPendingSofttargetMessage = nil
	private.pendingSofttargetTime = getElapsedTime()
end

function changePriorityMissionTarget(newPriorityMissionTarget)
	if private.currentPriorityMissionTarget == newPriorityMissionTarget then
		return -- already the current priority mission target
	end

	private.currentPriorityMissionTarget = newPriorityMissionTarget

	if private.currentPriorityMissionTarget then
		SetPriorityMissionTargetMessage(private.currentPriorityMissionTarget.posID, private.currentPriorityMissionTarget.messageID)
	else
		SetPriorityMissionTargetMessage(nil, nil)
	end
end

-- checks whether the pending softtarget is to be changed
-- newSofttarget = {
--	messageID | targetElement = [messageID]|[targetElement]
-- }
function checkPendingSofttargetChange(newSofttarget, previousSofttarget)
	local newSofttargetMessage
	if newSofttarget ~= nil then
		if newSofttarget.targetElement then
			newSofttargetMessage = newSofttarget.targetElement.messageID
		else
			newSofttargetMessage = newSofttarget.messageID
		end
	end

	if private.currentSofttarget and newSofttargetMessage == private.currentSofttarget.messageID then
		-- it's the current softtarget, so remove the pending softtarget
		changePendingSofttarget(nil)
		return
	end

	-- #coreUIHigh use the isInTargetCone() function and unselect the pending softtarget only, if it was out of the cone for a specific timeframe
	-- #coreUIMed --- verify this is correct --- resetting pending softtarget if new softtarget is out of view? shouldn't we stick with the pending softtarget in that case? and/or
	--                ensure the pending softtarget is still in view?
	local x2d, y2d, cameraDistance
	-- #coreUILow --- check whether newSofttarget-check is actually still required --- can't we assume that at this point newsofttarget is always non-nil?
	if newSofttarget then
		local onScreen
		_, onScreen, x2d, y2d, cameraDistance = getSquareDistanceToCenter(newSofttarget)
		if not onScreen then
			-- oov, reset the pending softtarget
			changePendingSofttarget(nil)
			return
		end
	end

	-- special case: if the softtarget just changed (because it went out of the softtarget cone), it immediately becomes the new pending softtarget without any delay
	-- #coreUIMed - review --- this sounds weird here --- shouldn't we reset the pending softtarget to nil then and just keep the current softtarget?
	if previousSofttarget and newSofttargetMessage == previousSofttarget.messageID then
		changePendingSofttarget(newSofttarget)
	end

	if private.pendingSofttarget == nil then
		-- we got the first pending softtarget, there's no need to apply a try-pending-softtarget time here, since we are not going to replace a pending softtarget
		-- so we can directly set the pending softtarget
		changePendingSofttarget(newSofttarget)
		return
	end

	if private.previousTriedPendingSofttargetMessage ~= newSofttargetMessage then
		-- we've got a new target element wanting to become the pending softtarget than the one in the last check, reset the timer
		private.previousTriedPendingSofttargetMessage = newSofttargetMessage
		private.previousTriedPendingSofttargetTime    = getElapsedTime()
		return
	end

	if private.pendingSofttarget.messageID == newSofttargetMessage then
		return -- already current pending softtarget
	end

	-- check if the new target was the pending target for the required time and make it the new pending target if so
	local calculatedDelay = getMinTargetDelay(private.currentSofttarget ~= nil)
	if newSofttarget then
		local delayparameter = getTargetConeRatio(x2d, y2d, cameraDistance)
		local calculatedDelay = config.maxDelay * delayparameter
		calculatedDelay = math.max(getMinTargetDelay(private.currentSofttarget ~= nil), calculatedDelay)
	end

	if calculatedDelay + private.previousTriedPendingSofttargetTime < getElapsedTime() then
		changePendingSofttarget(newSofttarget)
	end
end

-- #coreUIMed - revise the design of this and checkPendingSofttargetChange() - it'd be possible to simplify the design quite a bit
function checkSofttargetChange(forceTarget, newTargetMessageID)
	-- #coreUIHigh - reduce code redundancy (especially with check right below about crosshairMessageID
	if forceTarget then
		if private.currentSofttarget and private.currentSofttarget.messageID == newTargetMessageID then
			return -- target already current target -> nothing to do
		end

		-- if we get a target we must immediately switch to, we ignore any timing constrains
		changePendingSofttarget(nil)
		if private.currentSofttarget then
			-- always make sure the target has been reset (so that in case we can't set the target to the newly one, we end up with no target at all)
			RemoveSofttarget()
		end

		if newTargetMessageID ~= 0 then
			local targetElement = getTargetElementByMessageID(newTargetMessageID)
			if targetElement == nil then
				-- can happen, if the target element got disconnected in the current frame already
				return -- nothing to do in this case
			end
			if canMessageBeSofttarget(targetElement) and C.IsTargetable(newTargetMessageID) then
				local success, wasalreadyset = SetSofttarget(newTargetMessageID, false, false)
				if not success then
					DebugError("Target System warning. Failed to set target to object under the crosshair.")
				end
				if wasalreadyset then
					DebugError("Target System warning. We set the target to the existing target. This indicates we lacked to process a softtarget-update event.")
				end
			end
		end
		return
	end

	-- unselect softtarget, if it's no longer near the center or can no longer be the softtarget
	if private.currentSofttarget then
		-- we must use the correct position (either the one for the aim-at-indicator or the actual object) to determine whether the object left the target cone
		local x2d, y2d
		if private.useConfidenceBasedAutoTargetting then
			_, x2d, y2d = prototype.confidence.calculate(private.currentSofttarget)
		else
			_, x2d, y2d = getTargetPriority(private.currentSofttarget)
		end
		if (config.enableSofttargetOutOfConeCheck and not isInTargetCone(x2d, y2d, private.currentSofttarget.cameraDistance, true, private.currentSofttarget.messageID)) or not canMessageBeSofttarget(private.currentSofttarget) then
			-- #coreUIMed - update the target system state directly since this also directly changes the softtargetmanager state - then think about doing that first thing (prior to processing/updating the target system)
			RemoveSofttarget()
		end
	elseif private.pendingSofttarget == nil then
		-- no pending softtarget and no current target --- on auto targeting, just take the current softtarget, if we have one
		if private.crosshairMessageID ~= 0 then
			local targetElement = getTargetElementByMessageID(newTargetMessageID)
			if targetElement == nil then
				-- can happen, if the target element got disconnected in the current frame already
				return -- nothing to do in this case
			end
			if canMessageBeSofttarget(targetElement) and C.IsTargetable(private.crosshairMessageID) then
				local success, wasalreadyset = SetSofttarget(private.crosshairMessageID, false, false)
				if not success then
					DebugError("Target System warning. Failed to set target to object under the crosshair.")
				end
				if wasalreadyset then
					DebugError("Target System warning. We set the target to the existing target. This indicates we lacked to process a softtarget-update event.")
				end
			end
		end
		return
	end

	if not private.pendingSofttarget or (private.currentSofttarget and private.pendingSofttarget.messageID == private.currentSofttarget.messageID) or not C.IsTargetable(private.pendingSofttarget.messageID) then
		return -- no pending softtarget, pending target already current softtarget, or not pending softtarget is not targetable
	end

	-- check if the new pending target was the pending target for the required time and make it the new softtarget if so
	local calculatedDelay = 0
	-- calculate the delay parameter, if we want to switch (in contrast to select) the current softtarget -- ioW: if no current softtarget, no delay
	local x2d, y2d, cameraDistance
	if private.pendingSofttarget.targetElement then
		-- #coreUIMed - don't we have to call getTargetElementPosition() here (i.e. incorrect values, if rectangular target element goes offscreen!?) - note also review other cases!
		x2d, y2d = getUIElementScreenPosition(private.pendingSofttarget.targetElement)
		cameraDistance = private.pendingSofttarget.targetElement.cameraDistance
	else
		x2d, y2d, _, cameraDistance = GetMessageScreenPosition(private.pendingSofttarget.messageID)
		if x2d == nil then
			changePendingSofttarget(nil)
			return -- pending softtarget was removed in-between
		end
	end
	if private.currentSofttarget then
		local delayparameter = getTargetConeRatio(x2d, y2d, cameraDistance)
		calculatedDelay = config.maxDelay * delayparameter
		calculatedDelay = math.max(getMinTargetDelay(private.currentSofttarget ~= nil), calculatedDelay)
	end

	-- select new softtarget, if it entered the target cone
	-- no need to handle the aim-at-indicator case here --- if we ended up here, we want to replace the current target with a new one (which doesn't have an aim-at-indiactor yet)
	if isInTargetCone(x2d, y2d, cameraDistance, false, private.pendingSofttarget.messageID) then
		if private.pendingSofttargetTime + calculatedDelay < getElapsedTime() then
			local success, wasalreadyset = SetSofttarget(private.pendingSofttarget.messageID, false, false)
			if not success then
				DebugError("Target System warning. Failed to set new target.")
			end
			if wasalreadyset then
				DebugError("Target System warning. We set the target to the existing target. This indicates we lacked to process a softtarget-update event.")
			end
			changePendingSofttarget(nil)
		end
	end
end

function getCurrentCrosshairMessage()
	-- cursor over a target element, the target element takes precedense
	if private.mouseOverTargetElement then
		-- #coreUIMed - activate to make self-documenting
		--assume(private.mouseOverTargetElement.messageID ~= nil)
		return private.mouseOverTargetElement.messageID
	end

	-- note: we intentionally ignore the obstruction flag here so that in cases like an interact menu opening at the crosshair position (which is usually the case when selecting a docked ship with a mouse click)
	-- we still get the crosshair message for the ship and don't end up with no target at all (which would result in a deselection of the current target and ultimately close the interact menu immediately)
	return C.GetCurrentCrosshairMessage().messageID
end

function getCameraDistanceBasedParameterValue(cameraDistance, minvalue)
	-- get the settings
	local maxdistance = config.targetMaxDistance
	local middistance = config.targetMidDistance
	local mindistance = config.targetMinDistance
	local midvalue    = config.targetMidValue

	-- crop at maxdistance, so we safe us having to calculate the value for all target elements which are far away
	if cameraDistance >= maxdistance then
		return minvalue
	end

	-- we use the square values in order to smooth the curve's gradient a bit
	cameraDistance = cameraDistance ^ 2

	local c = minvalue
	local b = (mindistance * (1 - minvalue) - middistance * (midvalue - minvalue)) / (minvalue - 1)
	local a = (mindistance + b) * (1 - minvalue)

	-- a * (1 / (cameraDistance + b)) + c
	parametervalue = a / (cameraDistance + b) + c

	-- crop the value between minvalue and 1
	parametervalue = math.min(parametervalue, 1)
	parametervalue = math.max(parametervalue, minvalue)

	return parametervalue
end

function getSquareDistanceToCenter(targetElement)
	local x2d, y2d, onScreen, cameraDistance
	if targetElement.targetElement then
		x2d, y2d, onScreen = getUIElementScreenPosition(targetElement.targetElement)
		cameraDistance = targetElement.targetElement.cameraDistance
	else
		x2d, y2d, onScreen, cameraDistance = GetMessageScreenPosition(targetElement.messageID)
		if x2d == nil then
			return -- can happen when the component was already removed
		end
	end

	-- we simply return the square-sum (instead of the square-root of the sum) since that's sufficient to compare distances between target elements
	return x2d * x2d + y2d * y2d, onScreen, x2d, y2d, cameraDistance
end

-- returns a value between [0, 1] if the target is within the target cone with 0 in the cone's center and 1 at the cone's border
-- values > 1 indicating the target being outside the cone (the larger the value, the further away the target is from the cone)
function getTargetConeRatio(x2d, y2d, cameraDistance, addThreshold)
	-- get the settings
	local targetMinArea       = config.targetMinArea
	local targetMaxArea       = config.targetMaxArea
	local targetAreaThreshold = config.targetAreaThreshold

	-- calculate the target elements cameraDistance to the cone and decide whether the height or width is to be used
	local screenWidth  = private.screenWidth
	local screenHeight = private.screenHeight
	local x2dCentered  = math.abs(x2d)
	local y2dCentered  = math.abs(y2d)
	-- to be correct, we would have to devide by screenWidth/2 - but since we are only interested in the factor between xratio and yratio it won't make a difference
	-- hence we spare us the additional division
	local xratio = x2dCentered / screenWidth
	local yratio = y2dCentered / screenHeight
	local value
	local width
	if xratio > yratio then
		value = x2dCentered
		width = screenWidth / 2
	else
		value = y2dCentered
		width = screenHeight / 2
	end

	-- calculate the parametervalue based on the object's cameraDistance to the player
	local parametervalue = getCameraDistanceBasedParameterValue(cameraDistance, 0)

	-- calculate the screen percentage
	local screenPercentage = (targetMaxArea - targetMinArea) * parametervalue + targetMinArea
	screenPercentage       = math.min(screenPercentage, targetMaxArea)

	if addThreshold then
		screenPercentage = screenPercentage + targetAreaThreshold
		-- never exceed screen width/height
		screenPercentage = math.min(screenPercentage, 1)
	end

	-- calculate the maximum allowed cameraDistance
	local maxAllowedCameraDistance = width * screenPercentage

	-- return the ratio
	return value / maxAllowedCameraDistance
end

function getTargetElementByTargetSystem(targetSystem)
	for _, targetElement in ipairs(private.targetElements) do
		if targetElement.targetSystem == targetSystem then
			return targetElement
		end
	end

	DebugError("Target System error. Could not find corresponding target element in getTargetElementByTargetSystem().")
end

function getTargetElementByMessageID(messageID)
	if messageID == nil then
		return -- no entry for nil ids
	end

	for _, targetElement in ipairs(private.targetElements) do
		if targetElement.messageID == messageID and targetElement.connected then
			return targetElement
		end
	end
end

function isInactiveTargetElementState(targetElement)
	if not isTargetable(targetElement) then
		return true -- target element is not targetable atm
	end

	if isFirstPersonMode() then
		return not hasVisibleActions(targetElement)
	end

	if C.IsComponentWrecked(targetElement.componentID) and (not hasVisibleActions(targetElement)) then
		-- wrecks should only be selectable if you can interact with them
		return true
	end

	if targetElement.ignoreActionsOnTargeting then
		-- everything which is targetable regardless of the state of the actions, uses the active target element state at all times
		return false
	end

	-- in space mode, we consider all elements targetable (aka: clickable), hence just check for those, that have actions, but aren't displayed yet
	return hasActions(targetElement) and not hasVisibleActions(targetElement)
end

function isInTargetCone(x, y, cameraDistance, addThreshold, message)
	if message ~= nil and private.crosshairMessageID == message then
		-- cone is over message association geometry - hence it's valid
		return true
	end

	-- getTargetConeRatio() returns the depth of the component within the target cone
	-- the value becomes larger, the farther away the location is from the cone's center
	-- if the value is 1, the component is located at the edge of the cone
	-- if the value is >1, the component is outside the cone
	return getTargetConeRatio(x, y, cameraDistance, addThreshold) <= 1
end

function requestSofttargetLock()
	if private.softtargetLockRequested then
		return -- already requested, nothing to do
	end

	-- #coreUIMed - we don't correctly handle cases where the request got reset (i.e. lock was released)
	-- maybe add a check to determine whether the lock is still active, if we requested it?
	if RequestSofttargetLock("softtargetManager") then
		private.softtargetLockRequested = true
	end
end

function removeSofttargetLockRequest()
	if not private.softtargetLockRequested then
		return -- not requested, nothing to do
	end

	if RemoveSofttargetLockRequest("softtargetManager") then
		private.softtargetLockRequested = false
	end
end

function updateSofttargetLock(currentTargetIsHighestPriority)
	if not private.currentSofttarget then
		return -- no softtarget atm, nothing to do
	end

	local targetElement = private.currentSofttarget
	local componentID = targetElement.componentID

	-- we only lock small ships (in space mode)
	-- #coreUIMed - the condition check here is incomplete - shouldLock should only be true when steering the ship (i.e. space mode, non-external target view mode, non 1st-person external view mode)
	--              but then this isn't too noticable atm
	local shouldLock = not isFirstPersonMode() and isSmallShip(targetElement)
	if not shouldLock then
		return -- no locking for current message
	end

	local curTime = getElapsedTime()
	if GetPlayerSteeringStrength() > config.steeringStrengthLimit then
		private.lockTime = curTime
		requestSofttargetLock()
	elseif private.softtargetLockRequested then
		if curTime > private.lockTime + config.unlockSofttargetDelay then
			private.lockTime = 0
			removeSofttargetLockRequest()
		elseif not currentTargetIsHighestPriority and curTime > private.lockTime + config.unlockSofttargetReplaceDelay then
			private.lockTime = 0
			removeSofttargetLockRequest()
		end
	end
end

function updateSofttargetManager(targetElements)
	-- #coreUIMed - consider disabling (or resetting?) the whole softtarget update calculations, if controls are disabled in gamepad (and touch?) mode - and/or whether the private.softtargetManagerActive check below
	-- should be done here and disable the entire softtargetmanager?

	-- #coreUIMed - move this to private and set in mode setters (i.e. setShipMode/setFirstPersonMode)?
	local usePriorityBasedAutoTargeting = not isFirstPersonMode()

	-- find the item with the highest priority
	local newSofttarget         = nil
	local newCrosshairTarget    = 0
	local closestCenterDistance = nil
	local highestpriority       = nil
	local curCenterDistance     = nil
	for _, targetElement in ipairs(targetElements) do
		if usePriorityBasedAutoTargeting then
			local priority, x2d, y2d
			if private.useConfidenceBasedAutoTargetting then
				priority, x2d, y2d = prototype.confidence.calculate(targetElement)
			else
				priority, x2d, y2d = getTargetPriority(targetElement)
			end
			if highestpriority == nil or priority > highestpriority then
				if canMessageBeSofttarget(targetElement) then
					-- depending on which priority is used (either the aim-at target position for the current target, if that has a higher priority, or the target priority itself)
					-- we must use the correct position for the cone-check - otherwise a lower prioritized target could be calculated to be higher prioritized
					if private.useConfidenceBasedAutoTargetting or isInTargetCone(x2d, y2d, targetElement.cameraDistance, false, targetElement.messageID) then
						highestpriority	= priority
						newSofttarget	= { targetElement = targetElement }
					end
				end
			end
			if isCrosshairTarget(targetElement) then
				curCenterDistance = getSquareDistanceToCenter(targetElement)
				if ((closestCenterDistance == nil) or (closestCenterDistance > curCenterDistance)) and (curCenterDistance <= config.maxCenterSquareDistance) then
					closestCenterDistance = curCenterDistance
					newCrosshairTarget    = targetElement.messageID
				end
			end
		elseif targetElement.messageID == private.crosshairMessageID then
			-- make sure newSofttarget/newCrosshairTarget are set correctly when not using priority based auto targeting
			newCrosshairTarget = targetElement.messageID
			newSofttarget      = { targetElement = targetElement }
		end
	end

	updateSofttargetLock((newSofttarget ~= nil) and (private.currentSofttarget == newSofttarget.targetElement))

	-- #coreUILow - could be optimized - no need to call this every frame, if it didn't change, right?
	-- update the crosshair target element
	C.SetCrosshairMessage(newCrosshairTarget)

	if not private.autoTargetSelection or not private.softtargetManagerActive or IsSofttargetLocked() then
		return -- current softtarget must not change
	end

	if usePriorityBasedAutoTargeting then
		-- #coreUIMed - this is flawed --- if the highest priority target is not targetable, we end up in a situation where we don't determine the highest targetable object here (ultimately
		-- failing to target the proper object)

		-- #coreUILow --- make it configurable in the message configuration graph which messagetypes are considered for target priority handling here (no hardcoding)
		-- check other basic messages
		local list1 = GetTopTargetPriorityMessages("basic", config.numTargetElements)
		for _, entry in ipairs(list1) do
			local priority = entry.targetPriority
			if highestpriority ~= nil and highestpriority >= priority then
				break -- we are processing entries <= the priority of a message which is already on the list, no need to process further messages (all will be < previous priorirty)
			end
			-- no need to consider aim-at-target-priority here --- these objects are not displayed atm and hence do not have an aim-at-indicator
			if highestpriority == nil or priority > highestpriority then
				local targetElement = getTargetElementByMessageID(entry.messageID)
				if targetElement and canMessageBeSofttarget(targetElement) then
					if isInTargetCone(entry.x, entry.y, entry.cameraDistance, false, entry.messageID) then
						highestpriority	= priority
						newSofttarget	= { messageID = entry.messageID }
						break -- we only need to check the highest prioritized message, any further one cannot have a higher prioririty than the current
					end
				end
			end
		end

		-- check other fast object messages
		local list2 = GetTopTargetPriorityMessages("fastobject", config.numFastMovingTargetElements)
		for _, entry in ipairs(list2) do
			local priority = entry.targetPriority
			if highestpriority ~= nil and highestpriority >= priority then
				break -- we are processing entries <= the priority of a message which is already on the list, no need to process further messages (all will be < previous priorirty)
			end
			-- no need to consider aim-at-target-priority here --- these objects are not displayed atm and hence do not have an aim-at-indicator
			if highestpriority == nil or priority > highestpriority then
				local targetElement = getTargetElementByMessageID(entry.messageID)
				if targetElement and canMessageBeSofttarget(targetElement) then
					if isInTargetCone(entry.x, entry.y, entry.cameraDistance, false, entry.messageID) then
						highestpriority	= priority
						newSofttarget	= { messageID = entry.messageID }
						break -- we only need to check the highest prioritized message, any further one cannot have a higher prioririty than the current
					end
				end
			end
		end

		-- note: no need to check firstperson-messages, mission objective messages, playercapship, or poi messages here, since:
		--    1) the highest prioritized mission objective messages are displayed (the 8 most important ones)
		--    2) on the first person platform all important objects are basically displayed, too
		--    3) POI messages are meant to be displayed for objects at long distances - if objects get nearby and hence would be
		--       targetable with the gamepad, they are normal messages again -> no need to check for these
		--    4) playercapship are already covered by basic-messages and are just there for the purpose of being displayed
		--       (hence, they are not relevant if not displayed)
	elseif newSofttarget == nil then
		-- in ray cast mode (i.e. non priority based auto targeting mode) we use the current crosshair message, if no particular other target was picked before
		-- #coreUIMed - enable once assume()-handling was added
		-- assume(newSofttarget == nil or newSofttarget.targetElement.messageID == private.crosshairMessageID)
		newSofttarget = { messageID = private.crosshairMessageID }
	end

	local previousSofttarget = private.currentSofttarget
	if usePriorityBasedAutoTargeting then
		checkSofttargetChange(false, nil)
	else
		local newSofttargetMessageID = 0
		if newSofttarget ~= nil then
			-- handle variable newSofttarget struct (i.e. either messageID or targetElement stored)
			newSofttargetMessageID = newSofttarget.messageID or newSofttarget.targetElement.messageID
		end
		checkSofttargetChange(true, newSofttargetMessageID)
	end
	checkPendingSofttargetChange(newSofttarget, previousSofttarget)
end

function updateSofttargetManagerActivationState()
	if private.pendingSofttargetManagerStateChange == nil then
		return -- nothing to do
	end

	private.softtargetManagerActive = private.pendingSofttargetManagerStateChange
	-- note: we cannot call updateAllPointerOverrides() instantly upon receiving the event, since we might have pending disconnection events for target
	--       elements - since updateAllPointerOverrides() needs to call GetActionInfo() to determine the proper override icon, this would cause issues
	--       if the message was disconnected because it was destroyed already (see P1DEV-472)
	if private.softtargetManagerActive then
		updateAllPointerOverrides()
	else
		removeAllPointerOverrides()
	end

	private.pendingSofttargetManagerStateChange = nil
end

function updateVelocityIndicator()
	local active = (private.targetSystemMode == "space") and private.velocityIndicatorEnabled and C.GetVelocityIndicatorOption() and (not C.IsExternalTargetMode())

	local result = C.GetVelocityScreenPosition(private.velocityIndicator.size, private.velocityIndicator.size_offscreen * 1.5)
	if active and (result.speed > 1) then
		if not private.velocityIndicator.active then
			goToSlide(private.velocityIndicator.element, "active")
			private.velocityIndicator.active = true
		end

		local x = math.floor(result.screenx + 0.5)
		local y = math.floor(result.screeny + 0.5)

		setAttribute(private.velocityIndicator.element, "position.x", x)
		setAttribute(private.velocityIndicator.element, "position.y", y)

		if result.onscreen ~= private.velocityIndicator.onscreen then
			private.velocityIndicator.onscreen = result.onscreen
			if result.onscreen then
				SetIcon(private.velocityIndicator.textureElement, "hud_flightvector", config.velocityIndicator.color.r, config.velocityIndicator.color.g, config.velocityIndicator.color.b, config.useIconOverlayColor, private.velocityIndicator.size, private.velocityIndicator.size)
				setAttribute(private.velocityIndicator.materialElement, "opacity", config.velocityIndicator.color.a)
				setAttribute(private.velocityIndicator.materialElement, "glowfactor", config.velocityIndicator.color.glow)

				setAttribute(private.velocityIndicator.element, "rotation.z", 0)
			else
				SetIcon(private.velocityIndicator.textureElement, "hud_flightvector_offscreen", config.velocityIndicator.color_offscreen.r, config.velocityIndicator.color_offscreen.g, config.velocityIndicator.color_offscreen.b, config.useIconOverlayColor, private.velocityIndicator.size_offscreen, private.velocityIndicator.size_offscreen)
				setAttribute(private.velocityIndicator.materialElement, "opacity", config.velocityIndicator.color_offscreen.a)
				setAttribute(private.velocityIndicator.materialElement, "glowfactor", config.velocityIndicator.color_offscreen.glow)
			end
		end
		if not result.onscreen then
			local angle = math.atan2(x, -y)
			setAttribute(private.velocityIndicator.element, "rotation.z", angle + math.pi)
		end
	else
		if private.velocityIndicator.active then
			goToSlide(private.velocityIndicator.element, "inactive")
			private.velocityIndicator.active = false
		end
	end
end

--------------------------------------
-- Target System specific functions --
--------------------------------------
function activateAimTargetElement()
	private.aimTargetElementActive = true
end

function activateCollectable(targetElement, mode)
	goToSlide(targetElement.collectableTextureElement, mode)

	-- #coreUILow - review this - Actually checking whether the color was already set when activating the collectable element is suboptimal. A better solution might be
	--              to separate the activation of the collectable element from the activation of the icon itself and do this after the icon color was set (i.e. the same way
	--              we go with the activation of other icon elements in activateIconElements()).
	if targetElement.iconColor ~= nil then
		SetDiffuseColor(targetElement.collectableTextureElement, targetElement.iconColor.r, targetElement.iconColor.g, targetElement.iconColor.b)
		setAttribute(getElement("normal.material", targetElement.collectableTextureElement), "glowfactor", targetElement.iconColor.glow)
		setAttribute(getElement("select.material", targetElement.collectableTextureElement), "glowfactor", targetElement.iconColor.glow)
	end

	targetElement.collectableActive = true
end

function activateCommanderElement(targetElement)
	-- #coreUIMed - add state checking to prevent unnecessary reactivation
	goToSlide(targetElement.commanderElement, "active")
end

function activateDebugOutline(targetElement)
	-- #coreUIMed - wrong usage of config for enableDebugOutlines - should be in private
	if config.enableDebugOutlines then
		return -- already active, nothing to do
	end

	-- can be nil, iff outlines are activated and target element is disconnected atm
	if targetElement.componentID then
		showDebugOutline(targetElement)
	end

	config.enableDebugOutlines = true
end

function activateFill(targetElement)
	if targetElement.filled then
		return false -- already active
	end

	targetElement.filled = true
	updateOutline(targetElement)
	return true
end

function activateHullShield(targetElement)
	if targetElement.hullShieldActive then
		return -- already inactive, nothing to do
	end

	goToSlide(targetElement.hullElement, "active")
	goToSlide(targetElement.shieldElement, "active")

	targetElement.hullShieldActive = true
end

function activateIcon(targetElement)
	if targetElement.iconActive then
		return -- already active, nothing to do
	end

	if targetElement.isCollectable then
		if targetElement.currentState == "select" then
			activateCollectable(targetElement, "selected")
		else
			activateCollectable(targetElement, "normal")
		end
	end

	if targetElement.icon ~= nil then
		-- icon with main icon element is activated -> display the icon
		setAttribute(targetElement.mainTextureMaterialElement, "opacity", 100)
	end

	targetElement.iconActive = true
end

function activateIconElements(targetElement)
	if targetElement.iconElementsActive then
		return -- icon elements already active, nothing to do
	end

	if targetElement.isMissionTarget then
		goToSlide(targetElement.missionTargetElement, "active")

		if targetElement.priorityMissionTarget then
			goToSlide(targetElement.priorityMissionTargetElement, "active")
		end
	end

	targetElement.iconElementsActive = true
end

function activateOutline(targetElement)
	if targetElement.outlined then
		return -- already active
	end

	targetElement.outlined = true
	updateOutline(targetElement)
end

function activateRectangleElements(targetElement, normalMode, showRelationBrackets)
	-- ensure we don't end up with an invisible rectangle element
	-- #coreUIMed - activate to make self-documenting
	--assume(showRelationBrackets or targetElement.isMissionTarget)

	if showRelationBrackets then
		targetElement.rectangleNormalElement = getElement(targetElement.rectangleType, targetElement.rectangleAnarkElement)
		-- #coreUIMed - could be improved - we don't need to actually perform the goToSlide()-call here directly but rather could do this solely in updateRectangleElements()
		--              since this is swapping between the short (out of weapon range) and normal (in weapon range) styles
		goToSlide(targetElement.rectangleNormalElement, "active")
	end

	-- #coreUILow - reconsider how we handle setting the rectangleSofttargetElement - either set it only upon usage, or just when we change the rectangleType (i.e. also in resetElement())
	targetElement.isRectangleShown = true
	targetElement.rectangleSofttargetElement = getElement("softtarget_"..targetElement.rectangleType, targetElement.rectangleAnarkElement)
	targetElement.rectangleTargetElement = getElement("target_"..targetElement.rectangleType, targetElement.rectangleAnarkElement)
	goToSlide(getElement("mousepicking", targetElement.rectangleAnarkElement), "active")
	if targetElement.softtarget then
		activateTargetRectangle(targetElement)
	end

	-- set the correct minimum rectangle size based on the mode we use
	if private.useWorldSpacePositions then
		if normalMode then
			targetElement.minRectangleSize = config.minNormalRectangleWorldSize
		else
			targetElement.minRectangleSize = config.minSmallRectangleWorldSize
		end
	else
		if normalMode then
			targetElement.minRectangleSize = config.minNormalRectangleScreenSize
		else
			targetElement.minRectangleSize = config.minSmallRectangleScreenSize
		end
	end

	if targetElement.isMissionTarget then
		local suffix = "large"
		if not normalMode then
			suffix = "small"
		end
		local rectangleType = "mtarget_"
		if targetElement.priorityMissionTarget then
			rectangleType = "pmtarget_"
		end
		targetElement.rectangleMissionElement = getElement(rectangleType..suffix, targetElement.rectangleAnarkElement)
		goToSlide(targetElement.rectangleMissionElement, "active")
	end

	-- if the ship is a commander, display the commander element (crown)
	if C.IsCommander(targetElement.componentID) then
		activateCommanderElement(targetElement)
	end
end

function activateTargetRectangle(targetElement)
	local showsofttarget = private.autoTargetSelection and (not IsSofttargetLocked())
	if (targetElement.isSofttargetRectangleShown == nil) or (showsofttarget ~= targetElement.isSofttargetRectangleShown) then
		if showsofttarget then
			goToSlide(targetElement.rectangleTargetElement, "inactive")
			goToSlide(targetElement.rectangleSofttargetElement, "active")
			targetElement.isSofttargetRectangleShown = true
		else
			goToSlide(targetElement.rectangleSofttargetElement, "inactive")
			goToSlide(targetElement.rectangleTargetElement, "active")
			targetElement.isSofttargetRectangleShown = false
		end
	end
end

function activateTargetIndicator(targetElement, color)
	-- target pointer is displayed at most once per connected object
	if not targetElement.indicatorElementActivated then
		goToSlide(targetElement.indicatorElement, "active")
		SetDiffuseColor(targetElement.indicatorElement, color.r, color.g, color.b)
		setAttribute(getElement("missionindicator.Material2254", targetElement.indicatorElement), "glowfactor", color.glow)
		targetElement.indicatorElementActivated = true
	end
end

function changeState(targetElement, state, force)
	local stateChanged = (state ~= targetElement.currentState)

	if not force and not stateChanged then
		return -- state is already the requested one (and we don't force a reset of the current state)
	end

	-- update collectable
	if targetElement.isCollectable then
		if state == "select" then
			activateCollectable(targetElement, "selected")
		else -- inactive or active state, use the "normal" case, so both show some UI element
			activateCollectable(targetElement, "normal")
		end
	end

	-- play the icon change sound, if we switched from the inactive state to another one for an icon
	if stateChanged and targetElement.currentState == "inactive" and (targetElement.iconActive or targetElement.iconElementsActive) then
		PlaySound("ui_icon_change_hud_core")
	end

	-- update pointer override to and from the inactive state, so that hovering-over inactive elements doesn't show a target pointer
	local needsPointerUpdate = (state == "inactive" or targetElement.currentState == "inactive")

	targetElement.currentState = state

	-- note: no need to check for targetElement.filled here, since only the outlined state can change the visual effect upon a state-change (i.e. the fill effect is
	--       independent from the actual target element state)
	if targetElement.outlined then
		updateOutline(targetElement)
	end

	if targetElement.iconActive and targetElement.icon ~= nil then
		local iconname = targetElement.icon[state]
		SetIcon(targetElement.mainTextureTextureElement, iconname, targetElement.iconColor.r, targetElement.iconColor.g, targetElement.iconColor.b, config.useIconOverlayColor, targetElement.iconSize, targetElement.iconSize)
	end

	-- additional icons
	for i = 1, 4 do
		if targetElement.additionalIcons[i].active then
			local iconname = targetElement.additionalIcons[i].textures[state]
			SetIcon(targetElement.additionalIcons[i].textureElement, iconname, targetElement.iconColor.r, targetElement.iconColor.g, targetElement.iconColor.b, config.useIconOverlayColor, targetElement.iconSize, targetElement.iconSize)
			setAttribute(targetElement.additionalIcons[i].materialElement, "glowfactor", targetElement.iconColor.glow)
		end
	end

	if needsPointerUpdate then
		updatePointerOverride(targetElement, targetElement.actionPointer, state == "select", targetElement.instantAction)
	end
end

-- constructs new target element using the given anarkElement (targetSystem component) and elementID
function createTargetElement(anarkElement, elementID)
	local targetElement = constructTargetElementData()

	-- get presentation elements
	targetElement.targetSystem								= anarkElement
	targetElement.indicatorElement							= getElement("indicator", anarkElement)
	targetElement.missionTargetElement						= getElement("mission target", anarkElement)
	targetElement.missionTargetMaterialElement				= getElement("mission_target_overlay.Material446", targetElement.missionTargetElement)
	targetElement.priorityMissionTargetElement				= getElement("mission target2", anarkElement)
	targetElement.priorityMissionTargetMaterialElement		= getElement("mission_target_overlay_selected.Material454", targetElement.priorityMissionTargetElement)
	targetElement.offScreenBoxElement						= getElement("offscreen_box", anarkElement)
	targetElement.collectableTextureElement					= getElement("collectable.texture", anarkElement)
	targetElement.commanderElement							= getElement("commander", anarkElement)
	targetElement.commanderIconElement						= getElement("ship_squadleader_01", targetElement.commanderElement)
	targetElement.commanderMaterialElement					= getElement("Material444", targetElement.commanderIconElement)
	targetElement.hullShieldElement							= getElement("shield hull", anarkElement)
	targetElement.hullElement								= getElement("hull", targetElement.hullShieldElement)
	targetElement.hullMaterialElement						= getElement("hull.Material570", targetElement.hullElement)
	targetElement.shieldElement								= getElement("shield", targetElement.hullShieldElement)
	targetElement.shieldMaterialElement						= getElement("shield.Material570", targetElement.shieldElement)
	targetElement.bottomElement								= getElement("text bottom", anarkElement)
	targetElement.bottomTextElement							= getElement("Text", targetElement.bottomElement)
	targetElement.sideElement								= getElement("distance", anarkElement)
	targetElement.sideTextElement							= getElement("Text", targetElement.sideElement)
	targetElement.sideElement2								= getElement("speed", anarkElement)
	targetElement.sideTextElement2							= getElement("Text", targetElement.sideElement2)
	targetElement.mainTextureElement						= getElement("texture", anarkElement)
	targetElement.mainTextureMaterialElement				= getElement("material", targetElement.mainTextureElement)
	targetElement.mainTextureTextureElement					= getElement("texture", targetElement.mainTextureMaterialElement)
	targetElement.rectangleAnarkElement						= getElement("rectangle", anarkElement)

	targetElement.rectangleTargetNormalAnarkElement			= getElement("target_normal", targetElement.rectangleAnarkElement)
	targetElement.rectangleTargetShortAnarkElement			= getElement("target_short", targetElement.rectangleAnarkElement)
	targetElement.rectangleSoftTargetNormalAnarkElement		= getElement("softtarget_normal", targetElement.rectangleAnarkElement)
	targetElement.rectangleSoftTargetShortAnarkElement		= getElement("softtarget_short", targetElement.rectangleAnarkElement)
	targetElement.rectangleMissionLargeAnarkElement			= getElement("mtarget_large", targetElement.rectangleAnarkElement)
	targetElement.rectanglePriorityMissionLargeAnarkElement	= getElement("pmtarget_large", targetElement.rectangleAnarkElement)
	targetElement.rectangleMissionSmallAnarkElement			= getElement("mtarget_small", targetElement.rectangleAnarkElement)
	targetElement.rectanglePriorityMissionSmallAnarkElement	= getElement("pmtarget_small", targetElement.rectangleAnarkElement)

	targetElement.rectangleElements = {}
	for key, elements in pairs(config.rectangleElements) do
		targetElement.rectangleElements[key] = {}
		for i, material in ipairs(elements) do
			targetElement.rectangleElements[key][i] = getElement(material, targetElement.rectangleAnarkElement)
		end
	end

	-- get the 4 additional icon elements
	for i = 1, 4 do
		local iconElement     = getElement("icon"..(i+1), anarkElement)
		local modelElement    = getElement("icon"..(i+1), iconElement)
		local materialElement = getElement("Material459", modelElement)
		local textureElement  = getElement("icon"..(i+1), materialElement)

		targetElement.additionalIcons[i] = {
			["element"]         = iconElement,
			["materialElement"] = materialElement,
			["modelElement"]    = modelElement,
			["textureElement"]  = textureElement
		}
	end

	targetElement.coloredRectangleElements = {
		{ "normal",		getElement("normal", targetElement.rectangleAnarkElement) },
		{ "short",		getElement("short", targetElement.rectangleAnarkElement)  },
	}

	-- colorize mission related element (which is not colorized based on the obstruction state)
	-- note: while this approach has a slight performance overhead, it's more consistent to do the coloring through the script here (preferred approach by artists)
	local color = config.collectibleColor["normal"]
	SetDiffuseColor(getElement("icon_target_bracket", targetElement.offScreenBoxElement), color.r, color.g, color.b)
	setAttribute(getElement("icon_target_bracket.Plane08.ui_gradient_05", targetElement.offScreenBoxElement), "glowfactor", color.glow)
	local color = config.missionColor["normal"]
	SetDiffuseColor(getElement("offscreen_missiontarget", targetElement.offScreenBoxElement), color.r, color.g, color.b)
	setAttribute(getElement("offscreen_missiontarget.offscreen_mi.ui_gradient_", targetElement.offScreenBoxElement), "glowfactor", color.glow)

	-- set up elements eligable for mouse-picking
	initMousePicking(targetElement, elementID)

	-- set proper color modes for collectable and commander elements
	SetTextureColorMode(getElement("normal.material.coltex", targetElement.collectableTextureElement), true)
	SetTextureColorMode(getElement("select.material.colseltex", targetElement.collectableTextureElement), true)
	SetTextureColorMode(getElement("ship_squadleader_01", targetElement.commanderMaterialElement), config.useIconOverlayColor)

	-- register for connection/disconnection events
	registerForEvent("connectElement", anarkElement, callbacks.onConnectElement)
	registerForEvent("disconnectElement", anarkElement, callbacks.onDisconnectElement)

	-- counteract the scale factor in worldspace mode for text elements (bottom/right text element)
	if private.useWorldSpacePositions then
		setAttribute(targetElement.bottomElement, "scale.x", config.textScalingFactor)
		setAttribute(targetElement.bottomElement, "scale.y", config.textScalingFactor)
		setAttribute(targetElement.sideElement,   "scale.x", config.textScalingFactor)
		setAttribute(targetElement.sideElement,   "scale.y", config.textScalingFactor)
		setAttribute(targetElement.sideElement2,  "scale.x", config.textScalingFactor)
		setAttribute(targetElement.sideElement2,  "scale.y", config.textScalingFactor)
	end

	setAttribute(targetElement.bottomTextElement, "size", config.defaultFontSize)
	setAttribute(targetElement.sideTextElement,   "size", config.defaultFontSize)
	setAttribute(targetElement.sideTextElement2,  "size", config.defaultFontSize)

	-- explicitly set the main texture's opacity to 0, so to ensure the initial state on record (iconActive = false) is properly reflected by the elements actual state
	setAttribute(targetElement.mainTextureMaterialElement, "opacity", 0)

	return targetElement
end

function createTargetSystemClones(master)
	-- always insert the master element (otherwise we'd end up with an uninitialized target system and have stuck text on-screen)
	private.targetElements[1] = createTargetElement(master, 1)

	-- note: we need to ensure to create the maximum number of required clones of any setup we use (at the time of writing this the two setups are the 1st-person and the space-mode with
	--       the larger number being required by the space-mode)
	local numRequiredTargetElements = 1 + config.numFastMovingTargetElements + config.numTargetElements + config.numMissionTargets + config.numPOITargets + config.numPlayerCapShips

	-- note: iterating from 1..x since numRequiredTargetElements is (for clarity) the real number of target systems we need and we actually need to take the existing (master) target system
	--       into account
	for i = 1, numRequiredTargetElements do
		table.insert(private.targetElements, createTargetElement(clone(private.targetElements[1].targetSystem, "targetelementclone"..i), i+1))
	end
end

function deactivateAimTargetElement()
	if not private.aimTargetElementActive  then
		return -- already inactive
	end

	hideAimTargetElement()
	private.aimTargetElementActive = false
end

function deactivateBottomText(targetElement)
	setBottomText(targetElement, "")
end

function deactivateCollectable(targetElement)
	if not targetElement.collectableActive then
		return -- already inactive, nothing to do
	end

	goToSlide(targetElement.collectableTextureElement, "inactive")

	targetElement.collectableActive = false
end

function deactivateCommanderElement(targetElement)
	-- #coreUIMed - add state checking to prevent unnecessary re-deactivation
	goToSlide(targetElement.commanderElement, "inactive")
end

function deactivateDebugOutline(targetElement)
	if not config.enableDebugOutlines then
		return -- already inactive, nothing to do
	end

	-- can be nil, iff target element is currently not connected
	if targetElement.componentID then
		hideDebugOutline(targetElement)
	end

	config.enableDebugOutlines = false
end

function deactivateFill(targetElement)
	if not targetElement.filled then
		return false -- already inactive, nothing to do
	end

	targetElement.filled = false
	updateOutline(targetElement)
	return true
end

function deactivateHullShield(targetElement)
	if not targetElement.hullShieldActive then
		return -- already inactive, nothing to do
	end

	goToSlide(targetElement.hullElement, "inactive")
	goToSlide(targetElement.shieldElement, "inactive")

	targetElement.hullShieldActive = false
end

function deactivateIcon(targetElement)
	if not targetElement.iconActive then
		return -- already inactive, nothing to do
	end

	deactivateCollectable(targetElement)
	if targetElement.icon ~= nil then
		-- icon with main icon element is deactivated -> hide the icon
		setAttribute(targetElement.mainTextureMaterialElement, "opacity", 0)
	end

	targetElement.iconActive = false
end

function deactivateIconElements(targetElement)
	if not targetElement.iconElementsActive then
		return -- already inactive, nothing to do
	end

	if targetElement.isMissionTarget then
		goToSlide(targetElement.missionTargetElement, "inactive")

		if targetElement.priorityMissionTarget then
			goToSlide(targetElement.priorityMissionTargetElement, "inactive")
		end
	end

	targetElement.iconElementsActive = false
end

function deactivateOffScreenBox(targetElement)
	if not targetElement.offScreenBoxMode == "inactive" then
		return -- offscreen box already inactive, nothing to do
	end

	goToSlide(targetElement.offScreenBoxElement, "inactive")

	targetElement.offScreenBoxMode = "inactive"
end

function deactivateOutline(targetElement)
	if not targetElement.outlined or config.enableDebugOutlines then
		return -- already inactive or we use debug outlines, nothing to do
	end

	targetElement.outlined = false
	updateOutline(targetElement)
end

function deactivateRectangleElements(targetElement)
	if targetElement.rectangleNormalElement ~= nil then
		goToSlide(targetElement.rectangleNormalElement, "inactive")
		targetElement.rectangleNormalElement = nil
	end

	goToSlide(getElement("mousepicking", targetElement.rectangleAnarkElement), "inactive")
	deactivateTargetRectangle(targetElement)
	targetElement.isRectangleShown = false

	-- deactivate the additional icon elements
	for i = 1, 4 do
		deactivateAdditionalIcon(targetElement.additionalIcons[i])
	end

	if targetElement.rectangleMissionElement ~= nil then
		goToSlide(targetElement.rectangleMissionElement, "inactive")
		targetElement.rectangleMissionElement = nil
	end

	deactivateCommanderElement(targetElement)

	setIconPos(targetElement.mainTextureElement, 0, 0)
	setIconPos(targetElement.commanderIconElement, 0, targetElement.iconSize/2)

	-- also need to reset the minimum rectangle size back to the default value
	if private.useWorldSpacePositions then
		targetElement.minRectangleSize = config.minNormalRectangleWorldSize
	else
		targetElement.minRectangleSize = config.minNormalRectangleScreenSize
	end
end

function deactivateSideText(targetElement)
	setSideText(targetElement, "")
end

function deactivateTargetRectangle(targetElement)
	-- note: rectangleTargetElement and rectangleSofttargetElement can be nil, if it was never initialized
	-- #coreUILow - see related todo marker in activateRectangleElements()
	if targetElement.rectangleTargetElement ~= nil then
		goToSlide(targetElement.rectangleTargetElement, "inactive")
	end
	if targetElement.rectangleSofttargetElement ~= nil then
		goToSlide(targetElement.rectangleSofttargetElement, "inactive")
	end
	targetElement.isSofttargetRectangleShown = nil
end

function deactivateTargetIndicator(targetElement)
	-- #coreUIMed --- might be improved by taking the time the activate-animation takes, to check whether we really have to interrupt the animation (or whether it's already inactive)
	if targetElement.indicatorElementActivated then
		-- no need to deactivate/interrupt the target indicator if it was never activated
		goToSlide(targetElement.indicatorElement, "inactive")
		targetElement.indicatorElementActivated = false
	end
end

function disconnectElement(targetElement)
	if not targetElement.connected then
		return -- element is not connected so we've got nothing to do
	end

	if targetElement.isMissionTarget then
		private.disconnectedMissionTargets[tostring(targetElement.componentID)] = getElapsedTime()
	end

	-- #coreUIMed - improve this - should not rely on call order...
	-- note: must be done before changing the softtarget, since otherwise the interact menu elements wouldn't be reset
	-- we also must reset the pointer here, otherwise it'd always reference the message (ultimatley resulting in a crash)
	unsetPointerOverride(targetElement)

	-- check if the pending target was just disconnected
	if private.pendingSofttarget and targetElement.messageID == private.pendingSofttarget.messageID then
		changePendingSofttarget(nil)
	end

	-- check if the softtarget itself was just disconnected
	if private.currentSofttarget and targetElement == private.currentSofttarget then
		-- only reset the softtarget instead of triggering a callback via RemoveSofttarget()
		-- if we got the disconnection event, the softtarget manager was already updated - resetting the message here would effectively unset the softtarget,
		-- if another one was already set
		updateSofttargetTargetElement(nil)
	end

	-- check if the priority mission target itself was just disconnected
	if targetElement == private.currentPriorityMissionTarget then
		changePriorityMissionTarget(nil)
	end

	if targetElement.isMissionTarget then
		-- remove from tracked mission target list
		C.NotifyMissionPosIDDisconnected(targetElement.posID)
	end

	if targetElement == private.mouseOverTargetElement then
		private.mouseOverTargetElement = nil
	end

	-- #coreUILow - review --- actually we might require the display mode to remain as before --- if so, handle the problem that
	-- in rectangle display mode a successive call to onPriorityMissionTarget() on a disconnected element would reactivate the rectangle differently
	setDisplayMode(targetElement, nil, false)
	setIconPos(targetElement.mainTextureElement, 0, 0)
	setIconPos(targetElement.commanderIconElement, 0, targetElement.iconSize/2)
	deactivateFill(targetElement)
	deactivateOutline(targetElement)
	deactivateHullShield(targetElement)
	deactivateTargetIndicator(targetElement)
	deactivateBottomText(targetElement)
	deactivateSideText(targetElement)
	deactivateSideText2(targetElement)
	if isCurrentAimTargetElementActive(targetElement) then
		deactivateAimTargetElement()
	end
	deactivateIcon(targetElement)
	deactivateIconElements(targetElement)
	-- #coreUIMed review --- more or less redundant in deactivateIcon() now
	deactivateCollectable(targetElement)
	deactivateCommanderElement(targetElement)
	deactivateOffScreenBox(targetElement)
	hideDebugOutline(targetElement)
	-- #coreUIMed - check whether calling resetElement() here might not be the better way to go

	targetElement.connected = false
end

function displayAimTargetElement(targetElement)
	local mode = "weapon_out" -- i.e. out of weapon range
	if isInWeaponRange(targetElement) then
		mode = "weapon_in" -- i.e. inside weapon range
	end

	if private.aimTargetElementMode == mode then
		return -- already in the correct mode
	end

	if private.HUDEnabled then
		PlaySound("ui_"..mode.."_range")
	end
	goToSlide(private.aimElement, mode)
	private.aimTargetElementMode = mode
end

function getAimAtTargetIndicatorPosition(targetElement)
	if targetElement.aimPos.x ~= nil then
		return targetElement.aimPos.x, targetElement.aimPos.y, targetElement.aimPos.z, targetElement.aimPos.yaw, targetElement.aimPos.pitch, targetElement.aimPos.roll, targetElement.aimPos.x2d, targetElement.aimPos.y2d
	end

	-- #coreUIMed - rethink this --- we actually require the 2d-positions in one caller while we require only the real positions in the other
	--              maybe better split to two separate functions?

	-- if we haven't requested the pos yet, do it now
	local x2d, y2d, x, y, z, yaw, pitch, roll

	local pos = C.GetRelativeAimScreenPosition(targetElement.componentID, private.reservationSize, private.reservationSize)
	x2d = pos.x
	y2d = pos.y

	if private.useWorldSpacePositions then
		pos   = C.GetRelativeAimOffset(targetElement.componentID)
		x     = pos.x
		y     = pos.y
		z     = pos.z
		yaw   = pos.yaw
		pitch = pos.pitch
		roll  = pos.roll
	else
		x     = pos.x
		y     = pos.y
		z     = -0.001 -- in 2D mode, we have to sort overlapping elements (and here the aim at target element is set to -0.001 so it's "behind" the actual target element, if rendered at the same position)
		yaw   = 0
		pitch = 0
		roll  = private.cameraRoll -- counteract the head rotation, so it looks as if the element is always aligned according to the object it's "attached" to
	end

	-- store the data
	targetElement.aimPos = {
		["x2d"]   = x2d,
		["y2d"]   = y2d,
		["x"]     = x,
		["y"]     = y,
		["z"]     = z,
		["yaw"]   = yaw,
		["pitch"] = pitch,
		["roll"]  = roll
	}

	-- and return the current value
	return x, y, z, yaw, pitch, roll, x2d, y2d
end

-- returns the distance as it is to be displayed for target elements
-- i.e. rounds the value and returns "x.x km" or "x m"
function getDistanceText(distance)
	if distance > 1000 then
		-- #coreUILow - actually we should use the localized decimal separator here
		-- round to x.x km
		local distance = math.floor((distance + 50) / 100) / 10
		if math.fmod(distance, 1) == 0 then
			distance = tostring(distance)..".0"
		end
		return distance.." "..L["km"]
	else
		-- round to m
		return math.floor(distance + 0.5).." "..L["m"]
	end
end

function getIconSize(onScreen, useRectangleElementSize, ismouseover)
	local size
	if isFirstPersonMode() then
		-- first person case always uses the platform size
		return config.targetElementIconSizePlatform
	elseif useRectangleElementSize then
		return config.rectangleIconSize
	elseif onScreen then
		size = config.targetElementIconSize
	else
		size = config.targetElementIconSizeEdge
	end
	if ismouseover then
		size = size * config.targetBracketAnimation.mouseOverFactor
	end
	return size
end

function getMinTargetDelay(hasCurrentTarget)
	if hasCurrentTarget then
		return config.minReplaceDelay
	end
	return private.newTargetDelay
end

function getPOIIcon(targetElement, poiType)
	-- default to subordinate POI
	local iconPrefix = config.poiIcons["subordinate"]

	if isShipPOI(targetElement) or targetElement.isDataVault or targetElement.isLandmark then
		local iconname = getComponentIcon(targetElement)
		return iconname, iconname, iconname
	end

	if config.poiIcons[poiType] ~= nil then
		iconPrefix = config.poiIcons[poiType]
	end

	return iconPrefix.."_inactive", iconPrefix.."_active", iconPrefix.."_select"
end

function getPointerID(actionPointer, isSofttarget, hasVisibleAction, isInstantAction, isInactiveState, interactMenuOpen)
	-- note: This must be kept in-sync with the softtarget pointer ID code which determines the pointer override for hovering over the object geometry.

	if interactMenuOpen then
		-- with an open interact menu, mousing over the target element always uses the default pointer
		return config.defaultPointerID
	end

	-- SOFTTARGET CASE --
	-- in case of being the softtarget, we only show specific pointer, if we have a possible action
	if isSofttarget then
		if not hasVisibleAction then
			-- if no action is visible atm, we do not show any interaction related target pointer
			return config.defaultPointerID
		end
		if isInstantAction then
			-- for an instant action we display the action pointer (defaulting to target pointer, if no explicit action pointer is specified)
			return actionPointer or config.targetPointerID
		end
		-- otherwise we display the target pointer (indicating a click opens the interact menu)
		return config.targetPointerID
	end

	-- NON-SOFTTARGET CASE --
	if isInactiveState then
		return config.defaultPointerID	-- in the inactive state, the icon is non-clickable
	end

	-- in case of not being the softtarget, we always show pointer with the action pointer being displayed for instant (possible) actions
	if hasVisibleAction and isInstantAction then
		return actionPointer or config.targetPointerID
	end
	-- in case of not being the softtarget and having no (possible) instant action or the instant action not being possible, display the target pointer (indicating a click targets the object)
	return config.targetPointerID
end

function getTargetElementPosition(targetElement)
	if private.useWorldSpacePositions then
		-- Note: also for the rectangle target elements we use the plain target element offset (i.e. there's no need for special treatment of the
		--       corresponding GetUIElementRectangleScreenPosition() function which is used in 2D-mode)
		local offset = C.GetTargetElementOffset(targetElement.posID)

		-- true, since when using world space positions, we handle all target elements in their on-screen states (even the ones which are off-screen atm)
		return offset.x, offset.y, offset.z, true, offset.yaw, offset.pitch, offset.roll
	end

	local x, y, z, onScreen
	if targetElement.rectangleNormalElement ~= nil or targetElement.rectangleMissionElement ~= nil then
		-- first get the coordinates for the rectangle case, so we correctly determine whether in rectangle mode the target element is off-screen
		x, y, _, onScreen = GetUIElementRectangleScreenPosition(targetElement.posID, targetElement.minRectangleSize, config.maxRectangleScreenSize)
	end

	-- note: the "not onScreen" check here covers two cases:
	--       a) If we are not in rectangular mode, the position is calculated based on getUIElementScreenPosition() (i.e. icon positioning logic).
	--       b) If GetUIElementRectangleScreenPosition() returned an offscreen position, that position is wrong (#coreUIMed - see XR-1582) and will suggest an onscreen
	--          position as in 180 degrees opposed to the actual position rather than determine the proper position where to display the element on the screen borders.
	--          To circumvent this, we simply call the "working" getUIElementScreenPosition() function which covers/handles this case properly.
	if not onScreen then
		-- if in rectangle mode the target is not on-screen (and hence we are in icon-display mode) or if we are in icon-display mode overall, get the icon-position
		-- also use the icon position in outline mode (i.e. to position the "pickable" transparent icon elment used for auto target selection)
		x, y, onScreen = getUIElementScreenPosition(targetElement)
	end

	if targetElement.softtarget then
		z = 0.9
	else
		z = targetElement.distanceZ
	end

	-- #coreUIMed - review this --- in effect we'd use worldspace positioning for 2D as well (see XR-1278 for details)
	-- #coreUILow - add assertion that private.useCameraRoll is set (otherwise cameraRoll will not be set)
	-- returning private.cameraRoll counteracts the head rotation, so it looks as if the target element is always aligned according to the object it's "attached" to
	return x, y, z, onScreen, 0, 0, private.cameraRoll
end

function getTargetElementScale(targetElement)
	if not private.useWorldSpacePositions then
		return private.uiScale
	end

	-- scale the target elements dynamically based on their distances to the camera
	-- #coreUI - consider clamping the targetElement-camera distance here to 0.1 (see getRectanglePositions()) so we are working with a consistent camera distance
	-- i.e. atm we divert here from our calculations in getRectnaglePositions() with our calculation for distances < 0.1
	return private.uiScale * targetElement.centerPointCameraDistance * config.scalingFactor
end

function getTargetIcon(targetElement)
	local componentID = targetElement.componentID
	if not targetElement.isKnown then
		-- #coreUIMed - P1DEV-321
		return "si_unknown", "si_unknown", "si_unknown"
	elseif targetElement.isShip or targetElement.isRecyclable or targetElement.isBuildStorage or targetElement.isDataVault or targetElement.isSatellite or targetElement.isMine then
		local iconname = getComponentIcon(targetElement)
		return iconname, iconname, iconname
	elseif targetElement.isStation then
		local iconname = getComponentHUDIcon(targetElement)
		return iconname, iconname, iconname
	elseif targetElement.isLaserTower then
		local laserTowerSize = getShipOrLaserTowerSize(targetElement)
		local iconname = "mapob_lasertower_"..laserTowerSize
		return iconname, iconname, iconname
	elseif C.IsAsteroid(componentID) then
		return "asteroidtarget_inactive", "asteroidtarget_active", "asteroidtarget_select"
	elseif targetElement.isEntity then
		local inactive = ffi.string(C.GetEntityInactiveIcon(componentID))
		local active   = ffi.string(C.GetEntityActiveIcon(componentID))
		local selected = ffi.string(C.GetEntitySelectedIcon(componentID))
		if inactive == "" or active == "" or selected == "" then
			-- make sure we have either all valid icons or none (but don't have to support error cases where only part of the state icons are available)
			DebugError("Target System error. Failed to retrieve NPC icon info (see error log for further details). No icon will be displayed for this NPC.")
			return -- return nil
		end
		return inactive, active, selected
	elseif targetElement.isBomb then
		return "detachbombtarget_inactive", "detachbombtarget_active", "detachbombtarget_select"
	elseif targetElement.isNavBeacon then
		return "si_poi", "si_poi", "si_poi"
	elseif targetElement.isResourceProbe then
		return "mapob_resourceprobe", "mapob_resourceprobe", "mapob_resourceprobe"
	elseif targetElement.isLockbox then
		return "mapob_lockbox", "mapob_lockbox", "mapob_lockbox"
	elseif targetElement.isGate then
		-- delegate icon resolution to the 'real' POI gate icon
		return getPOIIcon(targetElement, "gate")
	elseif targetElement.isZoneHighway then
		-- delegate icon resolution to the 'real' POI zone highway icon
		return getPOIIcon(targetElement, "zonehighway")
	elseif targetElement.isSuperHighway then
		-- delegate icon resolution to the 'real' POI super highway icon
		return getPOIIcon(targetElement, "superhighway")
	else
		return "normaltarget_inactive", "normaltarget_active", "normaltarget_select"
	end
end

-- #coreUIMed - improve by storing the real targetPriority here, so that repetitive calls to getTargetPriority() do not unnecessarily recalculate the already calculated target priority
-- returns the target priority and the position used to determine it
function getTargetPriority(targetElement)
	local x2d, y2d = getUIElementScreenPosition(targetElement)

	if targetElement.targetPriority == nil then
		targetElement.targetPriority = calculateTargetPriority(x2d, y2d, targetElement.cameraDistance)
	end

	if not isCurrentAimTargetElementActive(targetElement) then
		-- for target elements without an aim target indicator, the targetElement's target priority defines the whole target priority
		return targetElement.targetPriority, x2d, y2d
	end

	-- for softtargets the maximum of the target priority and the aim-at-indicator-target-priority defines the whole target priority
	-- Note: we must calculate the priority for the aim-ahead indicator even in case it's not displayed atm (since the player could aim at the spot to actually try to hit the target)
	-- hence it would be incorrect to skip that priority just because the indicator is not visible
	local _, _, _, _, _, _, x2daim, y2daim = getAimAtTargetIndicatorPosition(targetElement)
	local aimTargetPriority = calculateTargetPriority(x2daim, y2daim, targetElement.cameraDistance)

	if targetElement.targetPriority > aimTargetPriority then
		-- if target priority is the higher one, take that
		return targetElement.targetPriority, x2d, y2d
	end

	-- otherwise take the aim at target element priority / position
	return aimTargetPriority, x2daim, y2daim
end

prototype.confidence = {}

prototype.confidence.settings =
   {
      --[[
	 Settings for various confidence calculations
      --]]
      maxdistance = 500000,

      --[[
	 Multiplication factors for confidence calculation
	 - This represents the "importance" of a given calculation in the final confidence that
	 a target element is the soft target
      --]]
      distancefactor      = 20000,
      anglefactor         = 10000,
      currenttargetfactor = 10000,
}

--[[
   Confidence calculations
   - These each return a value [0..1] such that, as far as each of these criteria care
   1.0 is the most important a target could be, and 0.0 is one that it doesn't care about
--]]
function prototype.confidence.calculateDistance(targetElement)
       local normaldistance = targetElement.cameraDistance / prototype.confidence.settings.maxdistance
       if normaldistance == 0 then
	  return 0
       end
       return 1 / math.min(normaldistance, 1.0)
end

function prototype.confidence.calculateCurrentTarget(targetElement)
       if private.aimElement == targetElement then
	  return 1
       end
       return 0
end

function prototype.confidence.calculateAngle(targetElement)
   local angle = C.GetTargetAngle(targetElement.messageID)
   if angle < 0 or angle ~= angle then
      return 0
   end
   return (angle / math.pi)
end

--[[
   confidence.calculate

   Calculate the confidence of a given target element.
--]]
function prototype.confidence.calculate(targetElement)
   local x2d, y2d = getUIElementScreenPosition(targetElement)
   if targetElement.targetPriority == nil then

      if targetElement.isStationary or targetElement.surfaceElement or (not targetElement.isKnown) then
	 return 0,x2d, y2d
      end

      -- todo: If this is to stay in lua, then make it so the calculations and their associated multipliers, can be iterated over, rather than manually calling them
      -- here.
      targetElement.targetPriority = 0.0;
      targetElement.targetPriority = targetElement.targetPriority + prototype.confidence.settings.distancefactor * prototype.confidence.calculateDistance(targetElement)
      targetElement.targetPriority = targetElement.targetPriority + prototype.confidence.settings.anglefactor * prototype.confidence.calculateAngle(targetElement)
      targetElement.targetPriority = targetElement.targetPriority + prototype.confidence.settings.currenttargetfactor * prototype.confidence.calculateCurrentTarget(targetElement)
   end

   local _, _, _, _, _, _, x2daim, y2daim = getAimAtTargetIndicatorPosition(targetElement)
   return targetElement.targetPriority, x2d, y2d
end

function getUIElementScreenPosition(targetElement)
   if targetElement == nil then
      DebugError("Null Target Element")
      DebugError(TraceBack())
   end

	if targetElement.curScreenPos.x2d ~= nil then
		return targetElement.curScreenPos.x2d, targetElement.curScreenPos.y2d, targetElement.curScreenPos.onScreen
	end

	-- if we haven't requested the screen pos yet, do it now
	local x2d, y2d, _, onScreen = GetUIElementScreenPosition(targetElement.posID, private.reservationSize, private.reservationSize)

	-- store the data
	targetElement.curScreenPos = {
		x2d = x2d,
		y2d = y2d,
		onScreen = onScreen
	}

	-- and return the current value
	return x2d, y2d, onScreen
end

function hasActions(targetElement)
	return targetElement.numActions > 0
end

function hasPossibleActions(targetElement)
	if not hasActions(targetElement) then
		return false
	end

	local _, isPossible = GetActionInfo(targetElement.messageID)
	return isPossible
end

function hasVisibleActions(targetElement)
	return targetElement.numDisplayedActions > 0
end

function hideAimTargetElement()
	if private.aimTargetElementMode == "inactive" then
		return -- already inactive
	end

	goToSlide(private.aimElement, "inactive")
	private.aimTargetElementMode = "inactive"
end

function hideDebugOutline(targetElement)
	removeFill(targetElement)
	removeOutline(targetElement)
end

-- this function initializes data which is dependent on the known state of the object (and therefore can change, if an unknown object becomes known)
function initDynamicTargetElementData(targetElement, messageDetails)
	-- #coreUIMed - consider optimizing this --- if targetElement.isKnown is false, we can shortcut things here and set everything to false

	-- reset memoizing types which rely on the known state
	targetElement.shipOrLaserTowerSize = nil

	-- #coreUIMed - consider dropping usage/access to messageType altogether
	targetElement.messageType              = ffi.string(messageDetails.messageType)
	targetElement.isCollectable            = C.IsCollectable(targetElement.componentID)
	-- #coreUIMed - add not targetElement.isCollectable for the type checks below?
	targetElement.isDetailElement          = C.IsDetailUIElement(targetElement.componentID, targetElement.connectionName)
	-- #coreUIMed - actually we need to change the interface for all IsXXXX() functions as they require to exclude detail elements themselves...
	targetElement.isShip                   = false
	targetElement.isLaserTower             = false
	targetElement.isBomb                   = false
	targetElement.isMine                   = false
	targetElement.isGate                   = false
	targetElement.isZoneHighway            = false
	targetElement.isSuperHighway           = false
	targetElement.isLockbox                = false
	targetElement.isNavBeacon              = false
	targetElement.isResourceProbe          = false
	targetElement.isSatellite              = false
	targetElement.isAdvancedSatellite      = false
	targetElement.isRecyclable             = false
	targetElement.isDataVault              = false
	targetElement.isLandmark               = false
	targetElement.isEntity                 = false
	targetElement.isBuildStorage           = false
	if not targetElement.isDetailElement then
		if C.IsShip(targetElement.componentID) then
			targetElement.isShip = true
		elseif C.IsLaserTower(targetElement.componentID) then
			targetElement.isLaserTower = true
		elseif C.IsBomb(targetElement.componentID) then
			targetElement.isBomb = true
		elseif C.IsMine(targetElement.componentID) then
			targetElement.isMine = true
		elseif C.IsGate(targetElement.componentID) then
			targetElement.isGate = true
		elseif C.IsZoneHighway(targetElement.componentID) then
			targetElement.isZoneHighway = true
		elseif C.IsSuperHighway(targetElement.componentID) then
			targetElement.isSuperHighway = true
		elseif C.IsLockbox(targetElement.componentID) then
			targetElement.isLockbox = true
		elseif C.IsNavBeacon(targetElement.componentID) then
			targetElement.isNavBeacon = true
		elseif C.IsResourceProbe(targetElement.componentID) then
			targetElement.isResourceProbe = true
		elseif C.IsSatellite(targetElement.componentID) then
			targetElement.isSatellite = true
			if C.IsAdvancedSatellite(targetElement.componentID) then
				targetElement.isAdvancedSatellite = true
			end
		elseif C.IsRecyclable(targetElement.componentID) then
			targetElement.isRecyclable = true
		elseif C.IsDataVault(targetElement.componentID) then
			targetElement.isDataVault = true
		elseif C.IsLandmark(targetElement.componentID) then
			targetElement.isLandmark = true
		elseif C.IsEntity(targetElement.componentID) then
			targetElement.isEntity = true
		elseif C.IsBuildStorage(targetElement.componentID) then
			targetElement.isBuildStorage = true
		end
	end

	-- note: the check for not isShip is just done to spare unnecessary calls to C.IsStation() for objects we already determined being ships
	targetElement.isStation                = not targetElement.isDetailElement and not targetElement.isShip and not targetElement.isLaserTower and not targetElement.isBomb and not targetElement.isMine and not targetElement.isGate and not targetElement.isLockbox and not targetElement.isNavBeacon and not targetElement.isResourceProbe and not targetElement.isSatellite and C.IsStation(targetElement.componentID)
	targetElement.surfaceElement           = C.IsSurfaceElement(targetElement.componentID)
	targetElement.isStationary             = C.IsStationary(targetElement.componentID)
	-- note: for cases which we know are destructible by definition (f.e. bombs, collectables, etc.) we do the cheap checks first so to skip an unnecessary IsDestructible2()-call in such cases
	targetElement.isDestructible           = targetElement.isBomb or targetElement.isMine or targetElement.surfaceElement or targetElement.isCollectable or targetElement.isNavBeacon or targetElement.isShip or targetElement.isLaserTower or targetElement.isLockbox or targetElement.isResourceProbe or targetElement.isSatellite or C.IsDestructible2(targetElement.componentID, targetElement.connectionName) --C.IsDestructible2(targetElement.componentID, targetElement.connectionName)
	targetElement.showInWeaponRangeState   = targetElement.surfaceElement or (not targetElement.isStationary and targetElement.isDestructible)
	targetElement.obstructedByOwnComponent = config.obstructedByOwnComponents or (targetElement.messageType == "missionoffer")

	-- #coreUIMed review this and change alongside with MessageAssociationInterface
	if messageDetails.poiID ~= 0 then
		local poiDetails = C.GetPOIDetails(messageDetails.poiID)
		targetElement.displayedBottomText = ffi.string(poiDetails.POIName)
		targetElement.poiType             = ffi.string(poiDetails.POIType)
	end

	-- determine and initialize the onScreenDisplayMode
	-- note: must be done in initDynamicTargetElementData() since these values rely heavily on whether the object is known or not
	local isMissionOffer = (targetElement.messageType == "missionoffer")
	local isFirstPerson = isFirstPersonMode()
	if not targetElement.isKnown then
		targetElement.onScreenDisplayMode = isFirstPerson and "outline" or "rectangle"
	elseif isMissionOffer then
		targetElement.onScreenDisplayMode = "icon"
	elseif isFirstPerson and targetElement.isEntity then
		targetElement.onScreenDisplayMode = "softtargetIcon"
	elseif targetElement.isStation or targetElement.isBuildStorage or targetElement.isGate or targetElement.isShip or targetElement.isLaserTower or targetElement.isBomb or targetElement.isMine or targetElement.isSatellite or targetElement.isNavBeacon or targetElement.isLockbox or targetElement.isResourceProbe or targetElement.isRecyclable or targetElement.isDataVault or targetElement.isLandmark then
		targetElement.onScreenDisplayMode = "rectangle"
	elseif targetElement.surfaceElement or targetElement.isDetailElement or targetElement.isZoneLocation or C.IsCrate(targetElement.componentID) or C.IsCrystal(targetElement.componentID) then
		if targetElement.isMissionTarget and (not isFirstPerson) then
			targetElement.onScreenDisplayMode = "outlineRect"
		elseif targetElement.surfaceElement then
			targetElement.onScreenDisplayMode = "outlineRectSoft"
		else
			targetElement.onScreenDisplayMode = "outline"
		end
	else
		targetElement.onScreenDisplayMode = "icon"
	end

	updateFactionColor(targetElement)
end

function initIcon(targetElement, displayState, selectedActionIcon, activeActionIcon, inactiveActionIcon)
	-- reset the target element icon (relevant f.e. for the case where an unknown collectable becomes known -> uses no main icon element while it used the ?-icon before)
	targetElement.icon = nil

	if displayState == "action" then
		if selectedActionIcon == nil or selectedActionIcon == "" or activeActionIcon == nil or activeActionIcon == "" or inactiveActionIcon == nil or inactiveActionIcon == "" then
			-- this can be a valid call, if for a certain action, we never display it as an icon target element (for instance buttons/crates are always represented as outlined objects)
			return
		else
			-- display state set to "action" and action icons are present - hence use these instead of the target related icons
			targetElement.icon = {
				["active"]   = activeActionIcon,
				["inactive"] = inactiveActionIcon,
				["select"]   = selectedActionIcon
			}
			return
		end
	end

	-- use the target related icons, if displayState is nil (aka: no action data) or "default" (aka: default display state)
	local inactiveIcon, activeIcon, selectedIcon

	if targetElement.isCollectable then
		return -- no main icon element for collectables - they are represented only with the animated ring-element
	elseif targetElement.poiType ~= "" then
		inactiveIcon, activeIcon, selectedIcon = getPOIIcon(targetElement, targetElement.poiType)
	else
		inactiveIcon, activeIcon, selectedIcon = getTargetIcon(targetElement)
	end

	if inactiveIcon ~= nil then
		-- i.e. either all icons are correctly set or none --- therefore only check for inactiveIcon
		targetElement.icon = {
			["active"]   = activeIcon,
			["inactive"] = inactiveIcon,
			["select"]   = selectedIcon
		}
	end
end

function initMousePicking(targetElement, elementID)
	-- get all main target element pickable parts
	targetElement.targetsystemPickElements = {
		-- target element icon
		targetElement.mainTextureElement,
		-- additional icon elements
		targetElement.additionalIcons[1].element,
		targetElement.additionalIcons[2].element,
		targetElement.additionalIcons[3].element,
		targetElement.additionalIcons[4].element,
		-- mission target elements
		targetElement.missionTargetElement,
		targetElement.priorityMissionTargetElement,
		-- collectable elements
		targetElement.collectableTextureElement,
		-- subordinate commander elements
		targetElement.commanderElement,
		-- rectangle elements
		targetElement.rectangleAnarkElement,
		-- offscreen box element
		targetElement.offScreenBoxElement
	}

	-- init the picking areas for the main target element
	for _, element in ipairs(targetElement.targetsystemPickElements) do
		-- #coreUILow - find a more suitable solution -- quick and dirty
		private.mouseElements[element] = elementID
		registerForEvent("onGroupedMouseOver", element, callbacks.onMouseOver)
		registerForEvent("onGroupedMouseOut", element, callbacks.onMouseOut)
		registerForEvent("onMouseDown", element, callbacks.onMouseDown)
		registerForEvent("onMouseClick", element, callbacks.onMouseClick)
		registerForEvent("onMouseDblClick", element, callbacks.onMouseDblClick)
		registerForEvent("onRightMouseDown", element, callbacks.onRightMouseDown)
		registerForEvent("onRightMouseClick", element, callbacks.onRightMouseClick)
		registerForEvent("onRightMouseDblClick", element, callbacks.onRightMouseDblClick)
		registerForEvent("onMiddleMouseDown", element, callbacks.onMiddleMouseDown)
		registerForEvent("onMiddleMouseClick", element, callbacks.onMiddleMouseClick)
		registerForEvent("onMiddleMouseDblClick", element, callbacks.onMiddleMouseDblClick)
		registerForEvent("onSide1MouseDown", element, callbacks.onSide1MouseDown)
		registerForEvent("onSide1MouseClick", element, callbacks.onSide1MouseClick)
		registerForEvent("onSide1MouseDblClick", element, callbacks.onSide1MouseDblClick)
		registerForEvent("onSide2MouseDown", element, callbacks.onSide2MouseDown)
		registerForEvent("onSide2MouseClick", element, callbacks.onSide2MouseClick)
		registerForEvent("onSide2MouseDblClick", element, callbacks.onSide2MouseDblClick)
		RegisterMouseInteractions(element)
	end
end

function initTargetElement(targetElement, displayState, selectedActionIcon, activeActionIcon, inactiveActionIcon)
	initIcon(targetElement, displayState, selectedActionIcon, activeActionIcon, inactiveActionIcon)

	local isTargetElement = (targetElement.isMissionTarget or targetElement.messageType == "basic" or targetElement.messageType == "fastobject" or targetElement.messageType == "playercapship" or isShipPOI(targetElement)) and targetElement.isDestructible and (not targetElement.hasMissionTargetAdditionalOffset)
	if isTargetElement then
		activateHullShield(targetElement)
	end

	-- note: this would not be required to be rechecked upon a known -> unknown state change, but then it doesn't hurt to do this either - hence keep this for simplicity as is
	--       Further note that while we don't display the effect in 1st-person if the mission target is represented in outline mode (f.e. a button), we still keep the
	--       pinged state in the MissionData (i.e. the state is pinged, just there's no actual visualiziation for this effect in the outline mode).
	if targetElement.isMissionTarget and ((not isFirstPersonMode()) or ((targetElement.onScreenDisplayMode ~= "outline") and (targetElement.onScreenDisplayMode ~= "outlineRectSoft"))) then
		-- note: if this part is modified, we need corresponding changes in the ping state handling - see: UI::ICom:::MissionData::Pinged
		-- note: the target indicator always uses the normal coloring (even for obstructed target elements)
		-- mission objectives get disconnected and connected on zone change. Do not ping them in that case for 1 second
		local disconnectTime = private.disconnectedMissionTargets[tostring(targetElement.componentID)]
		if disconnectTime == nil then
			activateTargetIndicator(targetElement, config.missionColor["normal"])
		end
	end
end

function isCrosshairTarget(targetElement)
	return targetElement.onScreenDisplayMode == "icon" and not isInactiveTargetElementState(targetElement)
end

function isCurrentAimTargetElementActive(targetElement)
	return private.aimTargetElementActive and targetElement.softtarget
end

function isFirstPersonMode()
	return private.targetSystemMode == "firstPerson"
end

function isInWeaponRange(targetElement)
	if targetElement.inWeaponRange == nil then
		targetElement.inWeaponRange = C.IsTargetInPlayerWeaponRange(targetElement.componentID)
	end

	return targetElement.inWeaponRange
end

function isObstructed(targetElement)
	if targetElement.curObstructed == nil then
		-- perform ray-cast for proper obstruction check, but store the result, so that any following call will reuse the result
		targetElement.curObstructed = IsObstructed(targetElement.posID, targetElement.obstructedByOwnComponent, not private.useWorldSpacePositions)
	end

	return targetElement.curObstructed
end

function isSmallShip(targetElement)
	if not targetElement.isShip then
		return false
	end

	local shipSize = getShipOrLaserTowerSize(targetElement)
	return shipSize == "xs" or shipSize == "s"
end

function isTargetable(targetElement)
	if targetElement.targetable == nil then
		targetElement.targetable = C.IsTargetable(targetElement.messageID)
	end

	return targetElement.targetable
end

function isTargetElementPendingDeletion(targetElement)
	local targetElementEntry
	for targetSystem, entry in pairs(private.connectionList) do
		if entry.type == "disconnect" then
			if targetElementEntry == nil then
				-- make sure to resolve this at most once (but also only if actually required)
				targetElementEntry = getTargetElementByTargetSystem(targetSystem)
			end
			if targetElement == targetElementEntry then
				return true
			end
		end
	end
end

function processConnectionList()
	-- note: we must process the entries separately, since we can run into situations where we schedule a connect event followed by a disconnect event followed by another connect event in the
	-- same frame, which ultimately will disconnect the last connection element since the disconnect-event triggers the removal of the UIElement from the list
	for targetSystem, entry in pairs(private.connectionList) do
		local targetElement = getTargetElementByTargetSystem(targetSystem)
		if entry.type == "connect" then
			connectTargetElement(targetElement, entry.messageID, entry.posID)
		else -- disconnect
			disconnectElement(targetElement)
		end
	end

	private.connectionList = {}
end

function processEnterInteractMenuEvent()
	if not private.performEnterInteractMenu then
		return -- nothing to do
	end

	-- #coreUILow - we'd better record the number of events and ensure that the enterInteractMenu event is performed on the correct target
	-- (i.e. if we'd get an enterInteractMenu first followed by a softtarget change we'd actually skip the enterInteractMenu call so it's
	-- not performed incorrectly on the new softtarget - or execute it before processSofttargetChange() was performed (aka: execute it on
	-- the previous softtarget))

	private.performEnterInteractMenu = false
	startSofttargetInteraction()
end

function processSofttargetChange()
	if private.pendingSofttargetMessageID == nil then
		return -- no pending softtarget message
	end

	local newSofttargetMessageID = private.pendingSofttargetMessageID
	if newSofttargetMessageID == "" then
		newSofttargetMessageID = nil
	end

	private.pendingSofttargetMessageID = nil

	-- remove any pending lock upon a softtarget change
	-- this can happen if the current softtarget got destroyed and hence the softtarget was removed implicitly (i.e. discarding any lock requests)
	removeSofttargetLockRequest()

	-- note: updateSofttargetTargetElement() takes care about closing the interact menu (in case it was open for the previous target)
	updateSofttargetTargetElement(newSofttargetMessageID)
end

function removeAllPointerOverrides()
	for _, targetElement in ipairs(private.targetElements) do
		if targetElement.connected then
			unsetPointerOverride(targetElement)
		end
	end
end

function removeFill(targetElement)
	if not targetElement.activeFill then
		return -- no active fill
	end
	targetElement.activeFill = nil
	C.RemoveFill(targetElement.componentID, targetElement.connectionName)
end

function removeOutline(targetElement)
	if not targetElement.activeOutline then
		return -- no active outline
	end
	targetElement.activeOutline = nil
	C.RemoveOutline(targetElement.componentID, targetElement.connectionName)
end

function resetElement(targetElement)
	-- #coreUIMed --- review this behavior here --- calling disconnectElement() can also reset the softtarget which could potentially deselect the element we are just about to connect (if
	-- it's the new softtarget) - sample case: add some untargetable pilot chair (for instance by reverting the pick-fix for mining ships) and then try to target the pilot chair of a mining ship
	-- perform a clean disconnection first for cases where we directly reconnect an element
	disconnectElement(targetElement)

	-- use the normal deactivation handling to keep recorded states (i.e. variable) and actual states (i.e. visible elements) in-sync
	deactivateIcon(targetElement) -- deactivates/resets: iconActive, collectableActive

	targetElement.actionPointer             = nil
	targetElement.targetElementColor        = nil
	targetElement.iconColor                 = nil
	targetElement.outlineColor              = nil
	targetElement.textColor                 = nil
	-- note: colorMode doesn't need to be reset - just keep the current state on record
	targetElement.componentID               = nil
	targetElement.connectionName            = ""
	targetElement.curHullValue              = nil
	targetElement.curScreenPos              = {} -- reset to array, so it's not garbage collected
	targetElement.aimPos                    = {} -- reset to array, so it's not garbage collected
	targetElement.curObstructed             = nil
	targetElement.inWeaponRange             = nil
	targetElement.targetable                = nil
	targetElement.currentState              = "undefined"
	targetElement.curRelation               = 6 -- initially unknown relation
	targetElement.curOwningFactionID        = ""
	targetElement.curShieldValue            = nil
	targetElement.cameraDistance            = nil
	targetElement.centerPointCameraDistance = nil
	targetElement.displayedBottomText       = ""
	targetElement.distance                  = nil
	targetElement.distanceZ                 = nil
	targetElement.sideText                  = ""
	targetElement.sideText2                 = ""
	targetElement.showInWeaponRangeState    = false
	targetElement.surfaceElement            = false
	targetElement.ignoreActionsOnTargeting  = false
	targetElement.icon                      = nil
	targetElement.iconSize                  = 0
	targetElement.instantAction             = false
	targetElement.interactMenuOpen          = false
	targetElement.isAdvancedSatellite       = false
	targetElement.isBomb                    = false
	targetElement.isBuildStorage            = false
	targetElement.isCollectable             = false
	targetElement.isDataVault               = false
	targetElement.isDetailElement           = false
	targetElement.isDestructible            = false
	targetElement.isEntity                  = false
	targetElement.isKnown                   = false
	targetElement.isLaserTower              = false
	targetElement.isMine                    = false
	targetElement.isMissionTarget           = false
	targetElement.isShip                    = false
	targetElement.isLandmark                = false
	targetElement.isLockbox                 = false
	targetElement.isNavBeacon               = false
	targetElement.isRecyclable              = false
	targetElement.isResourceProbe           = false
	targetElement.isSatellite               = false
	targetElement.isStation                 = false
	targetElement.isStationary              = false
	targetElement.isZoneLocation            = false
	targetElement.hasMissionTargetAdditionalOffset = false
	targetElement.messageID                 = nil
	targetElement.minRectangleSize          = nil
	targetElement.numActions                = 0
	targetElement.numDisplayedActions       = 0
	targetElement.priorityMissionTarget     = false
	targetElement.obstructedByOwnComponent  = false
	targetElement.onScreen                  = nil
	targetElement.onScreenDisplayMode       = nil
	targetElement.poiType                   = ""
	targetElement.posID                     = nil
	targetElement.previousDistance          = 0
	targetElement.targetPriority            = nil
	targetElement.rectanglePos              = nil
	targetElement.rectangleType             = "normal"
	targetElement.shipOrLaserTowerSize      = nil
	targetElement.softtarget                = false
	targetElement.softtargetAnimationStart  = nil
	targetElement.displayedNotified         = false

	for i = 1, 4 do
		targetElement.additionalIcons[i].textures = nil
	end
end

function setIconPos(element, x, y)
	setAttribute(element, "position.x", x)
	setAttribute(element, "position.y", y)
end

function setAutoCrosshairTargetSelection(enable)
	private.autoCrosshairTargetSelection = enable
	if not enable then
		-- reset the current crosshairMessageID, if the autoCrosshairTargetSelection is disabled
		private.crosshairMessageID = 0
	end
end

function setBottomText(targetElement, text)
	setColoredText(targetElement.bottomElement, targetElement.bottomTextElement, targetElement.bottomText, text, targetElement.textColor)
	targetElement.bottomText = text
end

-- #coreUIMed - check curColor vs. newColor, to skip updating text color calls?
function setColoredText(textComponent, textElement, curText, newText, color)
	if curText == newText then
		return -- text is already up-to-date
	end

	-- disable text, if it's empty
	if newText == "" then
		goToSlide(textComponent, "inactive")
		return
	end

	-- enable text, if it wasn't enabled before
	if curText == "" then
		goToSlide(textComponent, "active")
	end

	-- update displayed text
	setAttribute(textElement, "textstring", newText)

	-- update text color
	setTextColor(textElement, color)
end

function setDisplayMode(targetElement, mode, onScreen)
	local forceupdate = false

	local isfirstperson = isFirstPersonMode()
	if (targetElement.displayMode ~= mode) or ((mode == "outlineRectSoft") and (targetElement.isRectangleShown ~= targetElement.softtarget)) then
		if (mode == "rectangle") or (mode == "outlineRect") or ((mode == "outlineRectSoft") and targetElement.softtarget) then
			activateRectangleElements(targetElement, mode ~= "outline", (not targetElement.isZoneLocation) and (not targetElement.hasMissionTargetAdditionalOffset))
		elseif (mode == "icon") or (mode == "outline") or (mode == "outlineRectSoft") or (mode == "softtargetIcon") then
			deactivateRectangleElements(targetElement)
		else -- mode == nil
			deactivateRectangleElements(targetElement)
			-- deactivate the main texture element
			goToSlide(targetElement.targetSystem, "inactive")
			targetElement.isTargetSystemSlideActive = false
		end
		forceupdate = true
	end

	-- note: the fill effect is only used for mission targets in 1st-person (in space we use a rectangular target combined with only the "target" outline but no fill effect)
	if (mode == "outline") and targetElement.isMissionTarget and isfirstperson then
		if activateFill(targetElement) then
			forceupdate = true
		end
	else
		if deactivateFill(targetElement) then
			forceupdate = true
		end
	end

	-- in non-1st-person mode the main texture element is also used to increase the click area around objects (i.e. main texture element is "transparent")
	-- in 1st-person mode we however do not activate it, since it would be notable in VR that there's a hidden transparent object the cursor would hit when
	-- hovering it over the transparent icon element - since on 1st-person mode we do not require the texture to increase the hit-area, we simply keep the
	-- texture inactive in this case
	local showtargetsystem = (mode == "icon") or (mode == "rectangle") or (((mode == "outline") or (mode == "outlineRect") or (mode == "outlineRectSoft")) and (not isfirstperson)) or ((mode == "softtargetIcon") and (targetElement.softtarget or targetElement.isMissionTarget))
	if showtargetsystem ~= targetElement.isTargetSystemSlideActive then
		if showtargetsystem then
			goToSlide(targetElement.targetSystem, "active")
			targetElement.isTargetSystemSlideActive = true
		else
			goToSlide(targetElement.targetSystem, "inactive")
			targetElement.isTargetSystemSlideActive = false
		end
		forceupdate = true
	end

	targetElement.displayMode = mode

	-- changes must take effect immediately - otherwise we'd see blinking target elements and other issues
	if forceupdate then
		ForceAnarkUpdate()
	end
end

function setPointerOverride(targetElement, pointerID)
	if not private.softtargetManagerActive then
		return -- softtarget manager is inactive atm - hence we are not displaying target pointers at all
	end

	-- set pointer overrides for main target element
	for _, element in ipairs(targetElement.targetsystemPickElements) do
		SetPointerOverride(element, pointerID)
	end
end

function setSideText(targetElement, text)
	setColoredText(targetElement.sideElement, targetElement.sideTextElement, targetElement.sideText, text, targetElement.textColor)
	targetElement.sideText = text
end

function setTargetElementColor(targetElement, targetElementColor, iconColor, textColor, outlineColor)
	if targetElement.targetElementColor == targetElementColor and targetElement.iconColor == iconColor and targetElement.textColor == textColor and targetElement.outlineColor == outlineColor then
		return -- color already set, nothing to do
	end

	targetElement.iconColor          = iconColor
	targetElement.outlineColor       = outlineColor
	targetElement.targetElementColor = targetElementColor
	targetElement.textColor          = textColor

	if targetElement.outlined or targetElement.filled then
		updateOutline(targetElement)
	end

	if targetElement.iconActive and targetElement.icon ~= nil then
		SetDiffuseColor(targetElement.mainTextureMaterialElement, iconColor.r, iconColor.g, iconColor.b)
		setAttribute(targetElement.mainTextureMaterialElement, "glowfactor", iconColor.glow)
		SetDiffuseColor(targetElement.commanderMaterialElement, iconColor.r, iconColor.g, iconColor.b)
		setAttribute(targetElement.commanderMaterialElement, "glowfactor", iconColor.glow)
	end

	-- additional icons
	for i = 1, 4 do
		if targetElement.additionalIcons[i].active then
			SetDiffuseColor(targetElement.additionalIcons[i].materialElement, iconColor.r, iconColor.g, iconColor.b)
			setAttribute(targetElement.additionalIcons[i].materialElement, "glowfactor", iconColor.glow)
		end
	end

	if targetElement.collectableActive then
		SetDiffuseColor(targetElement.collectableTextureElement, iconColor.r, iconColor.g, iconColor.b)
		setAttribute(getElement("normal.material", targetElement.collectableTextureElement), "glowfactor", iconColor.glow)
		setAttribute(getElement("select.material", targetElement.collectableTextureElement), "glowfactor", iconColor.glow)
	end

	if targetElement.bottomText ~= "" then
		setTextColor(targetElement.bottomTextElement, textColor)
	end

	if targetElement.sideText ~= "" then
		setTextColor(targetElement.sideTextElement, textColor)
	end

	if targetElement.sideText2 ~= "" then
		setTextColor(targetElement.sideTextElement2, textColor)
	end

	-- color rectangle always
	for _, entry in ipairs(targetElement.coloredRectangleElements) do
		SetDiffuseColor(entry[2], targetElementColor.r, targetElementColor.g, targetElementColor.b)
		for _, material in ipairs(targetElement.rectangleElements[entry[1]]) do
			setAttribute(material, "glowfactor", targetElementColor.glow)
		end
	end
end

function setTextColor(textelement, color)
	setAttribute(textelement, "textcolor.r", color.r)
	setAttribute(textelement, "textcolor.g", color.g)
	setAttribute(textelement, "textcolor.b", color.b)
	setAttribute(textelement, "glowfactor", color.glow or config.glowfactors.text)
end

function showDebugOutline(targetElement)
	showOutline(targetElement, config.debugColor)
	showFill(targetElement, config.debugColor, false)
end

function showFill(targetElement, color, animated)
    targetElement.activeFill = {
        ["color"] = {
            ["r"]     = color.r,
            ["g"]     = color.g,
            ["b"]     = color.b,
            ["alpha"] = config.fill.alpha
        },
        ["animated"]       = animated,
        ["minAlpha"]       = config.fill.minAlpha,
        ["maxAlpha"]       = config.fill.maxAlpha,
        ["transitionTime"] = config.fill.transitionTime
    }
    if private.HUDEnabled then
	    C.SetFill(targetElement.componentID, targetElement.connectionName, color.r, color.g, color.b, config.fill.alpha, animated, config.fill.minAlpha, config.fill.maxAlpha, config.fill.transitionTime)
    end
end

function showOutline(targetElement, color)
	targetElement.activeOutline = {
        ["color"] = {
            ["r"] = color.r,
            ["g"] = color.g,
            ["b"] = color.b
        }
    }
    if private.HUDEnabled then
	    C.SetOutline(targetElement.componentID, targetElement.connectionName, color.r, color.g, color.b, false)
    end
end

function startSofttargetInteraction()
	local targetElement = private.currentSofttarget
	if targetElement == nil then
		return -- no softtarget atm -> nothing to interact with right now
	end

	if targetElement.instantAction then
		-- note: we must do a hasPossibleActions-check here, since startSofttargetInteraction() is also called by pressing the interact hotkey ("F").
		-- That does not perform a pre-check of whether the action is actually possible or not and could ultimately incorrectly call PerformAction() on an
		-- impossible action which then might result in errors. (fixes XT-141)
		if hasPossibleActions(targetElement) then
			PerformAction(targetElement.messageID, 1)
		end
		return -- done / instant actions are performed directly without displaying the menu at all
	end

	if targetElement.hasMissionTargetAdditionalOffset then
		return -- no interactions with these target elements
	end

	C.ShowInteractMenu(targetElement.componentID, targetElement.connectionName, targetElement.messageID)
end

function unsetPointerOverride(targetElement)
	for _, element in ipairs(targetElement.targetsystemPickElements) do
		UnsetPointerOverride(element)
	end
end

function updateAimTargetElement(targetElement, isOnScreen)
	if not private.aimTargetElementActive then
		return -- aim target element not active atm, so nothing to do
	end

	if isOnScreen and not C.IsExternalTargetMode() then
		displayAimTargetElement(targetElement)
	else
		hideAimTargetElement()
	end

	-- #coreUILow - consider changing "inactive" with nil here for slightly more performant checks
	if private.aimTargetElementMode ~= "inactive" then
		-- aim-at-target elements are only used in space, hence no need to check for firstperson/non-firstperson-case
		local scale = getTargetElementScale(targetElement)
		local x, y, z, yaw, pitch, roll = getAimAtTargetIndicatorPosition(targetElement)
		updateElementPosition(private.aimElement, x, y, z, yaw, pitch, roll, scale)
	end
end

function updateAllPointerOverrides()
	for _, targetElement in ipairs(private.targetElements) do
		if targetElement.connected then
			updatePointerOverride(targetElement, targetElement.actionPointer, targetElement.softtarget, targetElement.instantAction)
		end
	end
end

-- #coreUIMed - review this --- outline-handling appears unnecessary complicated...
function updateAllOutlines()
	if not private.updateOutlines then
		return -- nothing to do
	end

    for _, targetElement in ipairs(private.targetElements) do
        -- outline effect
        if targetElement.activeOutline ~= nil then
            if private.HUDEnabled then
        	    C.SetOutline(targetElement.componentID, targetElement.connectionName, targetElement.activeOutline.color.r, targetElement.activeOutline.color.g, targetElement.activeOutline.color.b, false)
            else
                C.RemoveOutline(targetElement.componentID, targetElement.connectionName)
            end
        end

        -- fill effect
        if targetElement.activeFill ~= nil then
            if private.HUDEnabled then
        	    C.SetFill(targetElement.componentID, targetElement.connectionName, targetElement.activeFill.color.r, targetElement.activeFill.color.g, targetElement.activeFill.color.b, targetElement.activeFill.color.alpha, targetElement.activeFill.animated, targetElement.activeFill.minAlpha, targetElement.activeFill.maxAlpha, targetElement.activeFill.transitionTime)
            else
                C.RemoveFill(targetElement.componentID, targetElement.connectionName)
            end
        end
    end

	-- reset the state
	private.updateOutlines = false
end

-- note: passing targetElementPosX/Y as parameters rather than retrieving from the targetElement, so to make it self-explanatory that we require the targetElement position having been set already here
function updateBottomText(targetElement, onScreen, bottomText, targetElementPosX, targetElementPosY)
	-- #coreUIMed - review this --- actually we'd run the positioning recalculation also if the text changes (i.e. setBottomText() is called)
	--              not an issue atm, since only called here

	if (not config.debugValuesEnabled and not onScreen) or bottomText == "" then
		-- do not display bottom text if nothing to display or target element is off screen (unless in debug display mode)
		deactivateBottomText(targetElement)
		return
	end

	-- #coreUIMed - checking for useWorldSpacePositions is actually hacky --- we'd rather introduce a new screenBorder-mode (which then would be disabled in vr mode explicitly and would also
	-- be used to control the border-handling for target elemnts in general)
	if private.useWorldSpacePositions then
		setBottomText(targetElement, bottomText)
		return -- note: we check for useWorldSpacePositions here rather than vrMode, since our simplified calculation below only works in normal screen-space and wouldn't work with world space positions
		       -- (this would be technically feasible to add, if ever required)
	end

	-- bottom clamping
	local textHeight  = C.GetTextHeight(bottomText, config.bottomTextFont, config.bottomTextFontSize, 0)
	local minTextPosY = targetElementPosY - textHeight + config.bottomTextOffsetY
	local posY = config.bottomTextOffsetY
	if minTextPosY < -private.screenHeight/2 then
		-- clamp at bottom of the screen
		posY = -(private.screenHeight/2 + targetElementPosY - textHeight)
		if posY > config.bottomTextMaxOffsetY then
			-- prevent overlapping bottom text overlapping with the target element by deactivating the bottom text completely
			deactivateBottomText(targetElement)
			return
		end
	end

	-- right/left side clamping
	local textWidth   = C.GetTextWidth(bottomText, config.bottomTextFont, config.bottomTextFontSize)
	local maxTextPosX = targetElementPosX + textWidth/2
	local minTextPosX = targetElementPosX - textWidth/2
	local posX = 0
	if maxTextPosX > private.screenWidth/2 then
		-- clamp at right side of the screen
		posX = private.screenWidth/2 - targetElementPosX - textWidth/2
	elseif minTextPosX < -private.screenWidth/2 then
		-- clamp at left side of the screen
		posX = -(private.screenWidth/2 + targetElementPosX - textWidth/2)
	end

	-- update the text element
	setAttribute(targetElement.bottomTextElement, "position.x", posX)
	setAttribute(targetElement.bottomTextElement, "position.y", posY)

	-- display the text
	setBottomText(targetElement, bottomText)
end

function lerpColorModeColor(colorEntry, colorMode, t)
	if colorMode == "normal" then
		return colorEntry["normal"]
	end
	if t == nil then
		return colorEntry[colorMode]
	end

	local color = {
		r = t * colorEntry["normal"].r + (1 - t) * colorEntry[colorMode].r,
		g = t * colorEntry["normal"].g + (1 - t) * colorEntry[colorMode].g,
		b = t * colorEntry["normal"].b + (1 - t) * colorEntry[colorMode].b,
		a = t * colorEntry["normal"].a + (1 - t) * colorEntry[colorMode].a,
		glow = t * colorEntry["normal"].glow + (1 - t) * colorEntry[colorMode].glow,
	}
	return color
end

function updateColor(targetElement, relation, onScreen)
	local colorMode = "normal"
	if onScreen and isObstructed(targetElement) then
		colorMode = "obstructed"
	end

	local t
	if targetElement.softtargetAnimationStart then
		local curtime = getElapsedTime()
		local duration = config.targetBracketAnimation.duration
		if targetElement.softtargetAnimationStart + duration > curtime then
			t = 1
		else
			t = (targetElement.softtargetAnimationStart + 2.6 * duration - curtime) / duration
			local orig_t = t
			if t > 0 then
				-- sawtooth with period T = 1
				t = t % 1
			else
				targetElement.softtargetAnimationStart = nil
				t = nil
			end
		end
	end

	-- determine the targetelement color (incl. the icon color)
	local targetElementColor
	if (private.useFactionColor == 1) and (targetElement.curOwningFactionID ~= "") then
		targetElementColor = targetElement.factionColor
	else
		targetElementColor = lerpColorModeColor(config.relationColor[relation + 1]["element"], colorMode, t)
	end

	-- determine the target element's text color (f.e. distance/speed text)
	local textColor = lerpColorModeColor(config.relationColor[relation + 1]["text"], colorMode, t)

	-- if target is wreck override colors
	local iswreck = C.IsComponentWrecked(targetElement.componentID)
	if iswreck then
		targetElementColor = lerpColorModeColor(config.wreckColor, colorMode, t)
		textColor = targetElementColor
	end

	-- if collectible and cannot be collected -> grey
	if targetElement.isCollectable and (not iswreck) then
		local playership = C.GetPlayerOccupiedShipID()
		if (playership ~= 0) and (not C.CanBeCollectedBy(targetElement.componentID, playership)) then
			targetElementColor = config.collectibleColor["unavailable"]
		end
	end

	-- determine the outline color (always using the "normal" color - even if the target is obstructed)
	local outlineColor = config.relationColor[relation + 1]["element"]["normal"]
	if targetElement.isMissionTarget then
		outlineColor = config.missionColor["normal"]
	end

	-- #coreUILow - consider refactoring here:
	-- a) we are passing in the same color for the target element color and the icon color in all cases
	-- b) in principle the outlineColor could also use the icon color (as in outline mode there is no icon to be colored and we could define the attribute that in outline mode
	--    the "icon" is the object itself (i.e. apply the icon color as the outline color))
	setTargetElementColor(targetElement, targetElementColor, targetElementColor, textColor, outlineColor)
	setObstructionBasedColor(targetElement, colorMode, t)

	-- update missile lock color
	if targetElement.softtarget then
		updateMissileLockColor(relation)
	end

	targetElement.colorMode = (t == nil) and colorMode or nil
end

function updateHullShield(targetElement, onScreen)
	if not targetElement.hullShieldActive then
		return
	end

	-- #coreUIMed - memoize the data retrieved by GetComponentDetails() so we are calling it at most once per target element and frame
	local componentDetails = C.GetComponentDetails(targetElement.componentID, targetElement.connectionName)

	-- shield bar is displayed for the target if the shield is < 100% or for the current softtarget
	local showShield = targetElement.softtarget or C.ShouldShowShieldBar(targetElement.componentID)
	local shieldtime
	if showShield then
		shieldtime = componentDetails.shield / 100
	else
		shieldtime = 0
	end

	-- hull value is displayed, if hull < 100%, if it's the softtarget or the object has a shield and the shield value is <= 5%
	local showHull = targetElement.softtarget or (componentDetails.hull < 100) or (componentDetails.hasShield and componentDetails.shield <= 5)
	local hulltime
	if showHull then
		hulltime = componentDetails.hull   / 100
	else
		hulltime = 0
	end

	if targetElement.curHullValue ~= hulltime then
		goToTime(targetElement.hullElement, hulltime)
		targetElement.curHullValue = hulltime
	end
	if targetElement.curShieldValue ~= shieldtime then
		goToTime(targetElement.shieldElement, shieldtime)
		targetElement.curShieldValue = shieldtime
	end

	-- update position and scale
	if showHull or showShield then
		local barOffset = config.rectangleSizeCorrection/2

		-- apply the additional on/offscreen y-offset correction
		if onScreen then
			barOffset = barOffset + config.hullShieldBarYOffsetOnScreen
		else
			barOffset = barOffset + config.hullShieldBarYOffsetOffScreen
		end

		-- correct the bar offset if no shield value is displayed, so that the hull bar is positioned where the shield bar would normally be
		if not componentDetails.hasShield then
			barOffset = barOffset + config.hullShieldBarNoShieldYOffsetCorrection
		end

		local posx = targetElement.rectanglePos["upperleft"].x
		local posy = targetElement.rectanglePos["upperleft"].y
		local width = math.abs(targetElement.rectanglePos["upperright"].x - targetElement.rectanglePos["upperleft"].x) + config.hullShieldBarWidthCorrection + config.rectangleSizeCorrection

		setAttribute(targetElement.hullShieldElement, "position.x", posx + width/2)
		setAttribute(targetElement.hullShieldElement, "position.y", posy + barOffset)
		setAttribute(targetElement.hullShieldElement, "scale.x", width/100)
	end
end

function updateIcon(targetElement)
	if not targetElement.isDataVault then
		-- nothing to do
		return
	end

	local inactiveIcon, activeIcon, selectedIcon

	if targetElement.isCollectable then
		return -- no main icon element for collectables - they are represented only with the animated ring-element
	elseif targetElement.poiType ~= "" then
		inactiveIcon, activeIcon, selectedIcon = getPOIIcon(targetElement, targetElement.poiType)
	else
		inactiveIcon, activeIcon, selectedIcon = getTargetIcon(targetElement)
	end

	local hadicon = targetElement.icon ~= nil
	if ((inactiveIcon ~= nil) ~= hadicon) or (inactiveIcon ~= targetElement.icon.inactive) then
		if inactiveIcon ~= nil then
			-- i.e. either all icons are correctly set or none --- therefore only check for inactiveIcon
			targetElement.icon = {
				["active"]   = activeIcon,
				["inactive"] = inactiveIcon,
				["select"]   = selectedIcon
			}
			if (not hadicon) and targetElement.iconActive then
				setAttribute(targetElement.mainTextureMaterialElement, "opacity", 100)
			end
		else
			targetElement.icon = nil
			setAttribute(targetElement.mainTextureMaterialElement, "opacity", 0)
		end
		if targetElement.icon ~= nil then
			local iconname = targetElement.icon[targetElement.currentState]
			SetIcon(targetElement.mainTextureTextureElement, iconname, targetElement.iconColor.r, targetElement.iconColor.g, targetElement.iconColor.b, config.useIconOverlayColor, targetElement.iconSize, targetElement.iconSize)
		end
	end
end

function updateIconSize(targetElement, onScreen)
	-- #coreUIMed - activate to make self-documenting
	--assume(targetElement.iconActive or targetElement.rectangleMissionElement ~= nil)

	-- note: we rely on the rectangleMissionElement being set also if currently not used (i.e. in the offscreen case) so that the logic here works correctly
	--       also for the offscreen box case (i.e. surface element as mission target)
	-- #coreUILow - review this - this condition is not obvious and should likely be handled differently
	local useRectangleElementSize = (targetElement.rectangleNormalElement ~= nil or targetElement.rectangleMissionElement ~= nil)
	local iconSize = getIconSize(onScreen, useRectangleElementSize, targetElement == private.mouseOverTargetElement)
	if iconSize == targetElement.iconSize then
		return -- icon size didn't change, nothing to do
	end

	if targetElement.icon ~= nil then
		local iconname = targetElement.icon[targetElement.currentState]
		SetIcon(targetElement.mainTextureTextureElement, iconname, targetElement.iconColor.r, targetElement.iconColor.g, targetElement.iconColor.b, config.useIconOverlayColor, iconSize, iconSize)
	end

	-- additional icons
	for i = 1, 4 do
		if targetElement.additionalIcons[i].active then
			local iconname = targetElement.additionalIcons[i].textures[targetElement.currentState]
			SetIcon(targetElement.additionalIcons[i].textureElement, iconname, targetElement.iconColor.r, targetElement.iconColor.g, targetElement.iconColor.b, config.useIconOverlayColor, iconSize, iconSize)
			setAttribute(targetElement.additionalIcons[i].materialElement, "glowfactor", targetElement.iconColor.glow)
		end
	end

	-- update the size of the collectable element
	local collectableScaleFactor = config.collectableElementSizeFactor
	if private.vrMode then
		-- #coreUIMed - revert - see XR-1324
		collectableScaleFactor = config.collectableElementSizeFactorVR
	end
	setAttribute(targetElement.collectableTextureElement, "scale.x", iconSize * collectableScaleFactor / 100)
	setAttribute(targetElement.collectableTextureElement, "scale.y", iconSize * collectableScaleFactor / 100)

	-- update commander icon size
	setAttribute(targetElement.commanderIconElement, "scale.x", iconSize / 100)
	setAttribute(targetElement.commanderIconElement, "scale.y", iconSize / 100)

	-- update the mission target element sizes
	local missionTargetElement         = getElement("mission_target_overlay", targetElement.missionTargetElement)
	local priorityMissionTargetElement = getElement("mission_target_overlay_selected", targetElement.priorityMissionTargetElement)
	setAttribute(missionTargetElement, "scale.x", iconSize * config.missionElementSizeFactor / 100)
	setAttribute(missionTargetElement, "scale.y", iconSize * config.missionElementSizeFactor / 100)
	setAttribute(priorityMissionTargetElement, "scale.x", iconSize * config.missionElementSizeFactor / 100)
	setAttribute(priorityMissionTargetElement, "scale.y", iconSize * config.missionElementSizeFactor / 100)

	-- update the off screeen box element size
	setAttribute(targetElement.offScreenBoxElement, "scale.x", iconSize / config.iconReferenceSize)
	setAttribute(targetElement.offScreenBoxElement, "scale.y", iconSize / config.iconReferenceSize)

	targetElement.iconSize = iconSize
end

function updateOffScreenBox(targetElement, onScreen)
	local mode = "inactive"
	if not onScreen and not isFirstPersonMode() then
		if targetElement.isMissionTarget and targetElement.softtarget then
			mode = "mtarget_select"
		elseif targetElement.isMissionTarget then
			mode = "mtarget"
		elseif targetElement.softtarget then
			mode = "target"
		end
	end

	if targetElement.offScreenBoxMode == mode then
		return -- offscreen box already in the correct mode
	end

	goToSlide(targetElement.offScreenBoxElement, mode)

	targetElement.offScreenBoxMode = mode
end

function updateOutline(targetElement)
	if config.enableDebugOutlines then
		return -- do not use outlines, if debug outlines are enabled
	end

	local color         = targetElement.outlineColor
	local enableFill    = targetElement.filled
	-- only show the outline, if explicitly enabled (and in the select-state) or if we show the fill effect
	local enableOutline = enableFill or (targetElement.outlined and (targetElement.currentState == "select"))

	if enableOutline then
		-- #coreUIMed - review this entire outline handling design --- it's unnecessarily complicated with the current behavior of reevaluating colors once per frame anyway
		if color ~= nil then
			-- if the color is not yet set/initialized, updateOutline() will be called alongside initializing the color value
			showOutline(targetElement, color)
		end
	else
		removeOutline(targetElement)
	end

	if enableFill then
		if color ~= nil then
			-- if the color is not yet set/initialized, updateOutline() will be called alongside initializing the color value
			showFill(targetElement, color, true)
		end
	else
		removeFill(targetElement)
	end
end

function updatePointerOverride(targetElement, actionPointer, isSofttarget, isInstantAction)
	local pointerID = getPointerID(actionPointer, isSofttarget, hasVisibleActions(targetElement), isInstantAction, isInactiveTargetElementState(targetElement), targetElement.interactMenuOpen)
	setPointerOverride(targetElement, pointerID)
end

function updateRectangleElements(targetElement)
	if targetElement.rectangleNormalElement == nil and targetElement.rectangleMissionElement == nil then
		return -- not in rectangular display mode atm (nothing to do)
	end

	local scalefactor = 1
	local basescale = config.targetBracketAnimation.baseScale
	if targetElement == private.mouseOverTargetElement then
		scalefactor = config.targetBracketAnimation.mouseOverFactor
		basescale = scalefactor * basescale
	end

	-- determine the proper type based on in- or out of weapon range
	local rectangleType = "normal"
	if targetElement.showInWeaponRangeState and not isInWeaponRange(targetElement) then
		rectangleType = "short"
	end

	-- switch to the proper rectangle type (if it changed)
	if targetElement.rectangleType ~= rectangleType then
		-- only switch the element, if we actually use an active one (f.e. not the case for zone location mission targets)
		if targetElement.rectangleNormalElement ~= nil then
			-- deactivate the old type
			goToSlide(targetElement.rectangleNormalElement, "inactive")

			-- activate the new type
			targetElement.rectangleNormalElement = getElement(rectangleType, targetElement.rectangleAnarkElement)
			goToSlide(targetElement.rectangleNormalElement, "active")
		end

		-- update the softtarget element
		if targetElement.softtarget then
			-- deactivate the old type
			deactivateTargetRectangle(targetElement)
		end

		-- update the softtarget element
		targetElement.rectangleSofttargetElement = getElement("softtarget_"..rectangleType, targetElement.rectangleAnarkElement)
		targetElement.rectangleTargetElement = getElement("target_"..rectangleType, targetElement.rectangleAnarkElement)

		targetElement.rectangleType = rectangleType
	end

	if targetElement.softtarget then
		activateTargetRectangle(targetElement)
	end

	local rectanglePos = targetElement.rectanglePos
	if targetElement.rectangleNormalElement ~= nil then
		for _, entry in ipairs(config.targetBracketElements) do
			local element = getElement(entry.element, targetElement.rectangleNormalElement)
			setAttribute(element, "position.x", rectanglePos[entry.positionid].x)
			setAttribute(element, "position.y", rectanglePos[entry.positionid].y)
			setAttribute(element, "scale.x", basescale / 100)
			setAttribute(element, "scale.y", basescale / 100)
		end
	end

	-- must also move the softtarget element ...
	if targetElement.softtarget then
		local element = targetElement.rectangleTargetElement
		if targetElement.isSofttargetRectangleShown then
			element = targetElement.rectangleSofttargetElement
		end

		local coordoffset = 0
		local scale = basescale
		local curtime = getElapsedTime()
		if targetElement.softtargetAnimationStart and (targetElement.softtargetAnimationStart + config.targetBracketAnimation.duration > curtime) then
			-- maps x = 0 -> 0 and x = 1 -> 1, smaller a -> higher curvature
			local function exp(x, a)
				return a * math.exp(math.log((1 + a) / a) * x) - a
			end

			local t = (targetElement.softtargetAnimationStart + config.targetBracketAnimation.duration - curtime) / config.targetBracketAnimation.duration
			if t > 0 then
				local exp_t = exp(t, 0.01)
				local maxoffset = config.targetBracketAnimation.offsetFactor * math.sqrt(rectanglePos["lowerleft"].x * rectanglePos["lowerleft"].x + rectanglePos["lowerleft"].y * rectanglePos["lowerleft"].y)
				local offset = exp_t * maxoffset
				coordoffset = math.sqrt(2) * offset

				local maxscale = config.targetBracketAnimation.scaleFactor * scale
				scale = exp_t * (maxscale - scale) + scale
			end
		end

		for _, entry in ipairs(config.targetBracketElements) do
			local softtargetelement = getElement(entry.element, element)
			setAttribute(softtargetelement, "position.x", rectanglePos[entry.positionid].x + entry.xDir * coordoffset)
			setAttribute(softtargetelement, "position.y", rectanglePos[entry.positionid].y + entry.yDir * coordoffset)
			setAttribute(softtargetelement, "scale.x", scale / 100)
			setAttribute(softtargetelement, "scale.y", scale / 100)
		end
	end

	-- ... and the mission target element
	if targetElement.rectangleMissionElement ~= nil then
		for _, entry in ipairs(config.targetBracketElements) do
			local missionelement = getElement(entry.element, targetElement.rectangleMissionElement)
			setAttribute(missionelement, "position.x", rectanglePos[entry.positionid].x)
			setAttribute(missionelement, "position.y", rectanglePos[entry.positionid].y)
			setAttribute(missionelement, "scale.x", scalefactor)
			setAttribute(missionelement, "scale.y", scalefactor)
		end
	end

	-- must also adjust the size of the mouse-picking area
	setAttribute(getElement("mousepicking", targetElement.rectangleAnarkElement), "scale.x", (rectanglePos["upperright"].x * 2 + config.mousePickingBorder) / 100)
	setAttribute(getElement("mousepicking", targetElement.rectangleAnarkElement), "scale.y", (rectanglePos["upperright"].y * 2 + config.mousePickingBorder) / 100)

	if private.enableMousePickDebug then
		local color
		local index = targetElement.componentID % 6
		if index == 0 then
			color = { r = 255, g = 0, b = 0 }
		elseif index == 1 then
			color = { r = 255, g = 255, b = 0 }
		elseif index == 2 then
			color = { r = 255, g = 0, b = 255 }
		elseif index == 3 then
			color = { r = 0, g = 255, b = 0 }
		elseif index == 4 then
			color = { r = 0, g = 255, b = 255 }
		elseif index == 5 then
			color = { r = 0, g = 0, b = 255 }
		end
		SetDiffuseColor(getElement("mousepicking.mousepicking.Material588", targetElement.rectangleAnarkElement), color.r, color.g, color.b)
		setAttribute(getElement("mousepicking.mousepicking.Material588", targetElement.rectangleAnarkElement), "opacity", 70)
	elseif private.enableMousePickDebug == false then
		setAttribute(getElement("mousepicking.mousepicking.Material588", targetElement.rectangleAnarkElement), "opacity", 0)
	end
end

function updateRelation(targetElement, newRelation, newOwningFactionID)
	-- check if the owner has changed to update colors. Needs to be on top over relation change check. Because bailing changes the owning faction without a relation value change
	if targetElement.curOwningFactionID ~= newOwningFactionID then
		targetElement.curOwningFactionID = newOwningFactionID
		updateFactionColor(targetElement)
	end

	if targetElement.curRelation == newRelation then
		return -- nothing to do, no relation change
	end

	if config.displayHostileTargetIndicator and newRelation == 0 and not targetElement.surfaceElement and not targetElement.isDetailElement and C.MarkIndicatorShown(targetElement.componentID) then
		-- display the target pointer, if the target is/became hostile (not for surface and detail elements)
		-- the target indicator always uses the normal color (never the obstructed color variant)
		activateTargetIndicator(targetElement, config.relationColor[1]["element"]["normal"])
	end

	targetElement.curRelation = newRelation
end

-- note: passing targetElementPosX as parameter rather than retrieving from the targetElement, so to make it self-explanatory that we require the targetElement position having been set already here
function updateSideText(targetElement, onScreen, distance)
	local textMode = private.sideTextMode
	if config.debugValuesEnabled then
		textMode = "debug"
	end

	if textMode == nil then
		deactivateSideText(targetElement)
		return
	end

	-- #coreUILow - quick and dirty --- name-text-updates shouldn't be done in update-calls then... - it's only changing on state-changes and when on/off-screen
	local text
	local showText
	if textMode == "name" then
		-- for inactive objects we do not display the name in order to have another visual feedback element for when an item becomes interactive
		-- furthermore in outline-mode we do not display names at all either (would look kind of weird, if there is a free floating name alongside some outlined object since there is no point of reference -
		-- which is only present for the icon-mode or the rectangle mode)
		-- also the name is only displayed if the target element is on screen
		showText = onScreen and (targetElement.currentState ~= "inactive") and (targetElement.onScreenDisplayMode ~= "outline") and (targetElement.onScreenDisplayMode ~= "outlineRect") and (targetElement.onScreenDisplayMode ~= "outlineRectSoft") and ((targetElement.onScreenDisplayMode ~= "softtargetIcon") or targetElement.softtarget)
		if showText then
			-- only set the text, if we are actually gonna use it in the end
			local componentDetails = C.GetComponentDetails(targetElement.componentID, targetElement.connectionName)
			text = ffi.string(componentDetails.name)
		end
	elseif textMode == "distance" then
		-- distance is only displayed for the softtarget
		showText = targetElement.softtarget
		if showText then
			text = getDistanceText(distance)
		end
	else -- textMode == "debug"
		text = distance
		showText = true
	end

	if showText then
		setSideText(targetElement, text)
	else
		deactivateSideText(targetElement)
	end
end

function updateSideTextPosition(targetElement, targetElementPosX, targetElementPosY)
	-- #coreUIMed - checking for useWorldSpacePositions is actually hacky --- we'd rather introduce a new screenBorder-mode (which then would be disabled in vr mode explicitly and would also
	-- be used to control the border-handling for target elemnts in general)
	if private.useWorldSpacePositions then
		return -- note: we check for useWorldSpacePositions here rather than vrMode, since our simplified calculation below only works in normal screen-space and wouldn't work with world space positions
		       -- (this would be technically feasible to add, if ever required)
	end

	if targetElement.sideText == "" and targetElement.sideText2 == "" then
		return -- skip positioning text elements, if no side text displayed at all atm
	end

	-- bottom/top clamping
	-- first, calculate the upper/lower most text positions
	local maxTextPosY
	local minTextPosY
	if targetElement.sideText ~= "" then
		local textHeight = C.GetTextHeight(targetElement.sideText, config.sideTextFont, config.sideTextFontSize, 0)
		maxTextPosY      = targetElementPosY + textHeight/2 + config.sideTextOffsetY
		minTextPosY      = targetElementPosY - textHeight/2 + config.sideTextOffsetY
	end
	if targetElement.sideText2 ~= "" then
		local textHeight   = C.GetTextHeight(targetElement.sideText2, config.sideTextFont, config.sideTextFontSize, 0)
		local maxTextPosY2 = targetElementPosY + textHeight/2 + config.sideText2OffsetY
		local minTextPosY2 = targetElementPosY - textHeight/2 + config.sideText2OffsetY
		if maxTextPosY == nil then
			maxTextPosY = maxTextPosY2
			minTextPosY = minTextPosY2
		else
			maxTextPosY = math.max(maxTextPosY, maxTextPosY2)
			minTextPosY = math.min(minTextPosY, minTextPosY2)
		end
	end
	local yShiftValue = 0
	if maxTextPosY > private.screenHeight/2 then
		-- text would go above the screen, clamp at top of the screen
		yShiftValue = -maxTextPosY + private.screenHeight/2
	elseif minTextPosY < -private.screenHeight/2 then
		-- text would go below the screen, clamp at bottom of the screen
		yShiftValue = -minTextPosY - private.screenHeight/2
	end

	-- move text y-positions
	setAttribute(targetElement.sideTextElement,  "position.y", config.sideTextOffsetY + yShiftValue)
	setAttribute(targetElement.sideTextElement2, "position.y", config.sideText2OffsetY + yShiftValue)

	-- determine the max screen position if we display the text on the right side (default)
	local textWidth = math.max(C.GetTextWidth(targetElement.sideText, config.sideTextFont, config.sideTextFontSize), C.GetTextWidth(targetElement.sideText2, config.sideTextFont, config.sideTextFontSize))
	local maxTextPos = targetElementPosX + textWidth + config.sideTextOffsetX

	local sidePosition = "right"
	if maxTextPos > (private.screenWidth/2) then
		-- not enough space to display the text on the right side, switch to display it at the left side
		sidePosition = "left"
	end

	if sidePosition == targetElement.sideTextPosition then
		return -- done, correct position already set
	end

	-- prevent flickering if a target element is just at the edge of switching back to the right side
	-- (i.e. leave the side text at the left side a bit longer until we have enough space left and don't risk of it swapping the position again in the next frame)
	if sidePosition == "right" then
		maxTextPos = maxTextPos + config.sideTextPositioningThreshold
		if maxTextPos > (private.screenWidth/2) then
			return -- stay on th left side for now
		end
	end

	local textAlignment = 0 -- left - the text element on the right side of the target element is left aligned
	local posx = config.sideTextOffsetX
	if sidePosition == "left" then
		textAlignment = 2 -- right
		posx = -config.sideTextOffsetX
	end

	-- update the text elements
	-- #coreUILow - we'd actually also swap the "LOCK" text (for missile lock elements) here as well --- however since practically we'll never remain with a missile locked target at the border of the screen,
	--              this is not really required right now
	setAttribute(targetElement.sideTextElement,  "horzalign",  textAlignment)
	setAttribute(targetElement.sideTextElement2, "horzalign",  textAlignment)
	setAttribute(targetElement.sideTextElement,  "position.x", posx)
	setAttribute(targetElement.sideTextElement2, "position.x", posx)

	targetElement.sideTextPosition = sidePosition
end

function getRectanglePositions(targetElement)
	local posID = targetElement.posID
	local width, height

	if private.useWorldSpacePositions then
		-- in worldspace mode, we calculate the rectangle based on the rectangle target element extents
		local extents = C.GetRectangleTargetElementExtents(posID)

		-- clamp centerPointCameraDistance at 0.1 (to prevent div/0 issues, if we are flying through (or being close) to the target element center)
		local camDistance = math.max(targetElement.centerPointCameraDistance, 0.1)

		-- calculate the factor based on the target element extents and the camera distance
		local extentsDistanceFactor = extents / camDistance

		-- next compensate for the camera distance based target element scale factor and apply a fixed upscale (i.e. reference distance (in m) we configure/design the target system for)
		local scale = getTargetElementScale(targetElement)
		width = extentsDistanceFactor / scale * config.worldPositionReferencePlaneDistance

		-- finally clamp the rectangular sizes, so they are not getting too small/large
		width = math.min(math.max(width, targetElement.minRectangleSize), (targetElement.connectionName == "") and targetElement.minRectangleSize or config.maxRectangleWorldSize)
		height = width
	else
		-- #coreUIMed - this should be optimized, no? (i.e. we should only require a single call to GetUIElementRectangleScreenPosition() per frame)
		_, _, _, _, width, height = GetUIElementRectangleScreenPosition(posID, targetElement.minRectangleSize, (targetElement.connectionName == "") and targetElement.minRectangleSize or config.maxRectangleScreenSize)
	end

	local rectanglePositions = {}
	for _, entry in ipairs(config.targetBracketElements) do
		rectanglePositions[entry.positionid] = {
			["x"] = entry.xDir * (width  + config.rectangleSizeCorrection) / 2,
			["y"] = entry.yDir * (height + config.rectangleSizeCorrection) / 2,
		}
	end
	return rectanglePositions
end

function getShipOrLaserTowerSize(targetElement)
	if targetElement.shipOrLaserTowerSize == nil then
		targetElement.shipOrLaserTowerSize = ffi.string(C.GetShipOrLaserTowerSize(targetElement.componentID))
	end
	 return targetElement.shipOrLaserTowerSize
end

function updateDebugOutlines()
	if private.pendingDebugOutlines == nil then
		return -- nothing to do
	end

	for _, targetElement in ipairs(private.targetElements) do
		if private.pendingDebugOutlines then
			activateDebugOutline(targetElement)
		else
			deactivateDebugOutline(targetElement)
		end
	end

	-- reset the state
	private.pendingDebugOutlines = nil
end

function updateElementPosition(element, x, y, z, yaw, pitch, roll, scale)
	setAttribute(element, "position.x", x)
	setAttribute(element, "position.y", y)
	setAttribute(element, "position.z", z)
	setAttribute(element, "rotation.x", -pitch)
	setAttribute(element, "rotation.y", yaw)
	setAttribute(element, "rotation.z", -roll)
	setAttribute(element, "scale.x", scale)
	setAttribute(element, "scale.y", scale)
end

function updateState(targetElement, force)
	local state
	if targetElement.softtarget then
		state = "select"
	elseif isInactiveTargetElementState(targetElement) then
		state = "inactive"
	else
		state = "active"
	end

	changeState(targetElement, state, force)
end

function updateTargetElement(targetElement)
	if targetElement.posID == nil then
		return -- no connection information retrieved yet, nothing to do
	end

	-- notify the system that the message is now being displayed
	-- note: we do this here rather than during the connect callback, since we might get a connect callback
	--       followed by an immediate disconnect callback and hence would then incorrectly notify the system
	--       that the message is being displayed, while it actually is not
	if not targetElement.displayedNotified then
		NotifyTargetElementShown(targetElement.messageID)
		targetElement.displayedNotified = true
	end

	-- first check if we switched from unknown -> known state
	local becameKnown = not targetElement.isKnown and C.IsObjectKnown(targetElement.componentID)
	if becameKnown then
		-- note: it's ensured by design that an known object never becomes unknown again -> no need to support this case therefore
		makeTargetElementKnown(targetElement)
	end

	-- update relation dependent values (relation can change each frame)
	local relationDetails = C.GetRelationStatus4(targetElement.componentID, targetElement.connectionName)
	if relationDetails.relationStatus == -1 then
		-- failure to retrieve relation
		DebugError("Target System error. Failed to retrieve relation status for component: "..tostring(targetElement.componentID))
		relationDetails.relationStatus = 6 -- fallback to unknown
	end

	-- #coreUIHigh - quick and dirty solution to get venture ship player names in - should be improved to only set this initially (or upon unknown -> known state) and/or check for resetting
	--               if ship becomes non-venture (i.e. boarded) --- also doesn't quite handle design wise the glitching with poiBottomTexts and breaks debug value display
	if targetElement.isShip and C.IsVentureShip(targetElement.componentID) then
		-- #coreUIMed - consider using/introducing GetVentureShipDetails()?
		local ownerDetails = C.GetOwnerDetails2(targetElement.componentID)
		targetElement.displayedBottomText = ffi.string(ownerDetails.factionName)
	end

	-- update relation should be done first cause on first run that initializes the color value (which is used when activating icons for example)
	-- relation can change every frame, hence we must update the color every frame
	local curRelation = relationDetails.relationStatus
	local curOwningFactionID = ffi.string(relationDetails.owningFactionID)
	updateRelation(targetElement, curRelation, curOwningFactionID)

	-- update the target element position
	-- #coreUIMed - review this --- we'd really not suggest having retrieved 2d-positions in vrMode (i.e. there's no screen position here) and also not in worldspace-mode since that works with real 3D positions
    --              also note the inconsistency this introduced for the debug values below (getTargetConeRatio() called with real x/y positions rather than the getUIElementScreenPosition() values used elsewhere)
    --              side note: we assume the call here is actually the correct one - need to do a design review eventually
	local onScreen, x2d, y2d = updateTargetElementPosition(targetElement)

	-- update display mode and positioning (display mode can change based on whether outlined targets are on-screen)
	if onScreen then
		setDisplayMode(targetElement, targetElement.onScreenDisplayMode, true)
	else
		setDisplayMode(targetElement, "icon", false) -- off-screen everything else is in icon-mode
	end
	targetElement.onScreen = onScreen

	-- rectanglePos is required for all targets, since it's also used for positioning the hull/shield bar
	-- #coreUIMed - this is only partially true --- it's not always required - for instance it's not required, if the hull/shield bar is inactive
	targetElement.rectanglePos = getRectanglePositions(targetElement)
	updateRectangleElements(targetElement)

	-- activate outline
	-- note: usually we'd deactivate the outline if the target element is offscreen
	--       however, the onScreen state is inaccurate for the outline dislay mode (i.e. it would indicate false already when the position an icon would be displayed for the object would be offscreen which usually being the
	--       center of the object and hence the outline/fill effect would disappear as soon as the target is half of screen)
	--       to circumvent this, we simply keep the outline/fill effects active even in the offline case (rather than "correcting" the onScreen state which would be more complicated)
	-- #coreUIMed - we'd actually correct the onScreen state...
	if (targetElement.softtarget or targetElement.isMissionTarget) and ((targetElement.displayMode == "outline") or (targetElement.displayMode == "outlineRect") or (targetElement.displayMode == "outlineRectSoft")) then
		activateOutline(targetElement)
	else
		deactivateOutline(targetElement)
	end

	-- activate center icon
	-- #coreUIMed --- the onScreen or not isFirstPersonMode()-check should be removed --- ultimately a visible-check
	-- should be added to the MCG instead
	local enableIconElements = false
	local isIconMode = ((targetElement.displayMode == "icon") or (targetElement.displayMode == "softtargetIcon"))
	if (targetElement.displayMode ~= "outline") and (targetElement.displayMode ~= "outlineRect") and (targetElement.displayMode ~= "outlineRectSoft") and (onScreen or (not isFirstPersonMode())) and (isIconMode or (not targetElement.hasMissionTargetAdditionalOffset)) then
		activateIcon(targetElement)
		if isIconMode and onScreen then
			-- icon elements (aka: mission target circles) are only used in icon mode in the on-screen case
			enableIconElements = true
		end
	else
		deactivateIcon(targetElement)
	end

	-- needs to be done after the icon was activated (otherwise the icon would not be colored)
	updateColor(targetElement, curRelation, onScreen)

	-- display additional icon elements, if applicable
	if enableIconElements then
		activateIconElements(targetElement)
	else
		deactivateIconElements(targetElement)
	end

	-- update the offscreen box state
	updateOffScreenBox(targetElement, onScreen)

	-- #coreUIMed -- would be better to do this in a single call during onUpdate() so it's only called once
	if targetElement.softtarget then
		updateAimTargetElement(targetElement, onScreen)
	end

	-- update the pointer override which could have changed, if an action became visible now
	if hasActions(targetElement) then
		updatePointerOverride(targetElement, targetElement.actionPointer, targetElement.softtarget, targetElement.instantAction)
	end

	-- if the target just became known, we must force a state update so to ensure that if the visual presentation changed, all elements are updated correctly (f.e. icon is set/switched to the proper one)
	updateState(targetElement, becameKnown)

	-- update the icon size only if necessary (i.e. either if we display an icon or if we use the offscreen box (which is sized based on an icon we could display inside the box))
	if targetElement.iconActive or targetElement.offScreenBoxMode ~= "inactive" then
		-- #coreUILow - review this - not so good to depend this based on the offScreenBoxMode
		updateIcon(targetElement)
		updateIconSize(targetElement, onScreen)
	end

	-- positioning the icon is only required if we actually display the icon (otherwise skip it - f.e. in the outline rectangle mode used for surface mission target elements)
	if targetElement.iconActive and (targetElement.rectangleNormalElement ~= nil) then
		-- set additional rectangular mode icons
		-- note that we need to update/check this every frame, since the mission offer and NPC displayed at the object can change any time
		-- intentionally called after updateState(), so upon initialization we only set the icon once with the correct state rather than twice (with the old state first and then with the new state)
		-- #coreUIMed - review this handling here --- the iconXTextures variables are set/updated only in rectangle mode and are not reset when the mode is switched atm (-> inconsistent)
		updateDynamicRectangleIcons(targetElement)

		-- in rectangle mode we also need to update the icon positions
		local iconXPos = targetElement.rectanglePos["upperleft"].x + config.rectangleIconPositionCorrection
		local iconYPos = targetElement.rectanglePos["upperleft"].y + targetElement.iconSize/2 + config.rectangleEdgeSize/2
		setIconPos(targetElement.mainTextureElement, iconXPos, iconYPos)

		-- P1DEV-299 - must be set in icon mode correctly (not used atm there -> deferrred for now)
		-- #coreUIMed - improve positioning logic for icon size here --- we'd actually shift it by + iconSize (due to half the size of the target element icon plus half the size of the crown icon)
		--              since the crown icon is however quite much padded vertical wise, we need to compesate for the "empty" space in its texture below the icon - P1DEV-299
		setIconPos(targetElement.commanderIconElement, iconXPos, iconYPos + targetElement.iconSize / 2)

		-- additional icons
		for i = 1, 4 do
			if targetElement.additionalIcons[i].active then
				setIconPos(targetElement.additionalIcons[i].modelElement, iconXPos + targetElement.iconSize * i, iconYPos)
			end
		end
	end

	updateHullShield(targetElement, onScreen)

	local sideText   = targetElement.distance
	local bottomText = targetElement.displayedBottomText
	if config.debugValuesEnabled then
		if private.useConfidenceBasedAutoTargetting then
			sideText   = "ConeRatio: " .. string.format("%.5f", prototype.confidence.calculateAngle(targetElement)) .. " - cameraDistance: " .. string.format("%.3f", targetElement.cameraDistance)
			bottomText = "message: " .. tostring(targetElement.messageID) .. " - pos: " .. tostring(targetElement.posID) .. " - conf: " .. string.format("%.2f", prototype.confidence.calculate(targetElement)) .. "\nelementptr: "..tostring(targetElement.targetSystem) .. " - obstructed: " .. tostring(isObstructed(targetElement))
		else
			sideText   = "ConeRatio: " .. string.format("%.5f", getTargetConeRatio(x2d, y2d, targetElement.cameraDistance, targetElement.softtarget)) .. " - cameraDistance: " .. string.format("%.3f", targetElement.cameraDistance)
			bottomText = "message: " .. tostring(targetElement.messageID) .. " - pos: " .. tostring(targetElement.posID) .. " - prio: " .. string.format("%.2f", getTargetPriority(targetElement)) .. "\nelementptr: "..tostring(targetElement.targetSystem) .. " - obstructed: " .. tostring(isObstructed(targetElement))
		end
	end

	updateSideText(targetElement, onScreen, sideText)
	-- #coreUIMed - consider passing text as parameter to updateSideText2() for consistency
	updateSideText2(targetElement)
	-- #coreUIMed - review --- actually this needs to happen when the text is changed AND when the target element changes its position --- so maybe better integrate this in setSideText2()?
	updateSideTextPosition(targetElement, x2d, y2d)
	updateBottomText(targetElement, onScreen, bottomText, x2d, y2d)
end

function updateFactionColor(targetElement)
	local ownerDetails = C.GetOwnerDetails2(targetElement.componentID)
	targetElement.factionColor = {
		r = ownerDetails.factionColor.red,
		g = ownerDetails.factionColor.green,
		b = ownerDetails.factionColor.blue,
		a = ownerDetails.factionColor.alpha,
		glow = ownerDetails.glowfactor,
	}
end

function updateTargetElementData(targetElements)
	-- generate the query for the target element info call parameter
	-- #coreUILow --- better pass along the targetElements directly and update their values also directly in the function?
	local targetElementQuery = {}
	for _, targetElement in ipairs(targetElements) do
		local entry = {
			targetElement.messageID,
			targetElement.posID
		}
		table.insert(targetElementQuery, entry)
	end

	-- get relevant updated values: UIElementDistance, numDisplayedActions
	local result = GetTargetElementInfo(targetElementQuery)

	-- record all cameraDistances of the target elements
	local cameraDistanceList = {}

	-- update the actual values
	for i, targetElement in ipairs(targetElements) do
		targetElement.cameraDistance            = result[i].cameraDistance
		targetElement.centerPointCameraDistance = result[i].centerPointCameraDistance
		targetElement.distance                  = result[i].distance
		targetElement.numDisplayedActions       = result[i].numDisplayedActions
		-- reset values to ensure they are recalculated upon next access
		targetElement.targetPriority            = nil
		targetElement.curObstructed             = nil
		targetElement.inWeaponRange             = nil
		targetElement.targetable                = nil
		targetElement.aimPos                    = {}
		targetElement.curScreenPos              = {}
		local size = targetElement.rectanglePos and (targetElement.rectanglePos["upperright"].x + targetElement.rectanglePos["upperright"].y) or 0
		-- bin sizes into 5px accuracy
		size = math.ceil(size / 5) * 5
		table.insert(cameraDistanceList, { ["cameraDistance"] = targetElement.cameraDistance, ["index"] = i, ["size"] = size })
	end

	-- sort the cameraDistance list and record the distance-based-z-coordinate
	-- we want to be able to pick smaller target elements overlapped by larger ones, so we sort by size first and then by distance
	-- note: we sort by camera distance rather than by object distance since we want to have the target element rendered on top of the others which are (from the camera) farther away (and not based on the
	--       distance of the object to the player(object) - i.e. using the cameraDistance is more consistent for the design to have any visual implications impacted/calculated by the "real" render distance
	table.sort(cameraDistanceList, cameraDistanceSorter)

	-- #coreUILow - use config settings for fixed distance values
	-- note on the set distances:
	-- value chosen so we have enough room for up to 999 target elements which in reality we will never reach
	-- 0.9 = current softtarget
	local curz = 0.901 -- startvalue for z-coordinate for closest element
	for _, element in pairs(cameraDistanceList) do
		targetElements[element.index].distanceZ = curz
		curz = curz + 0.001
	end
end

function updateTargetElementPosition(targetElement)
	local scale = getTargetElementScale(targetElement)
	local x, y, z, onScreen, yaw, pitch, roll = getTargetElementPosition(targetElement)
	updateElementPosition(targetElement.targetSystem, x, y, z, yaw, pitch, roll, scale)

	return onScreen, x, y
end


-- p1-specific functions

function activateAdditionalIcon(iconEntry)
	if iconEntry.active then
		return -- icon already active, nothing to do
	end

	goToSlide(iconEntry.element, "active")
	iconEntry.active = true
end

function deactivateAdditionalIcon(iconEntry)
	if not iconEntry.active then
		return -- icon already inactive, nothing to do
	end

	goToSlide(iconEntry.element, "inactive")
	iconEntry.active = false
end

function deactivateMissileLocks()
	if not private.missileLocksEnabled then
		return -- missile locks already disabled
	end

	for i = 1, config.maxMissileLocks do
		setMissileLockState(private.missileLock[i], "inactive")
	end

	private.missileLocksEnabled = false
end

function deactivateSideText2(targetElement)
	setSideText2(targetElement, "")
end

function getCounterMeasurePosition(counterMeasureElement)
	if private.useWorldSpacePositions then
		-- #coreUIMed - this needs tweaking for VR (P1DEV-346)
		local offset = C.GetComponentOffset(counteMeasureElement)
		-- true, since when using world space positions, we handle all target elements in their on-screen states (even the ones which are off-screen atm)
		return offset.x, offset.y, offset.z, true, offset.yaw, offset.pitch, offset.roll
	end

	-- if we haven't requested the screen pos yet, do it now
	-- #coreUIMed - we'd use the proper sizes for the missile lock element here rather than the target element sizes
	local screenPos = C.GetComponentScreenPosition(counterMeasureElement, private.reservationSize, private.reservationSize)

	-- #coreUIMed - review this --- in effect we'd use worldspace positioning for 2D as well (see XR-1278 for details)
	-- #coreUILow - add assertion that private.useCameraRoll is set (otherwise cameraRoll will not be set)
	-- returning private.cameraRoll counteracts the head rotation, so it looks as if the target element is always aligned according to the object it's "attached" to
	return screenPos.x, screenPos.y, 0.9, screenPos.onScreen, 0, 0, private.cameraRoll
end

function getComponentIcon(targetElement)
	local icon = ffi.string(C.GetComponentIcon(targetElement.componentID))
	if icon ~= "" then
		return icon
	elseif targetElement.isShip then
		local shipSize = getShipOrLaserTowerSize(targetElement)
		if shipSize == "" then
			DebugError("Ship size for component '" .. ffi.string(C.GetComponentDetails(targetElement.componentID, targetElement.connectionName).name) .. "' is empty. Defaulting to 's'. [Florian]")
			shipSize = "s"
		end
		return "ship_" .. shipSize .. "_auxiliary_01"
	else
		DebugError("The POI or landmark '" .. ffi.string(C.GetComponentDetails(targetElement.componentID, targetElement.connectionName).name) .. "' does not have an icon defined. Defaulting to 'mapob_poi'.")
		return "mapob_poi"
	end
end

function getComponentHUDIcon(targetElement)
	local icon = ffi.string(C.GetComponentHUDIcon(targetElement.componentID))
	if icon ~= "" then
		return icon
	else
		return "si_factory"
	end
end

function isShipPOI(targetElement)
	if (targetElement.messageType == "poi") or (targetElement.messageType == "missionobjective") then
		if (targetElement.poiType == "ship_s") or (targetElement.poiType == "ship_m") or (targetElement.poiType == "ship_l") or (targetElement.poiType == "ship_xl") then
			return true
		end
	end
	return false
end

function makeTargetElementKnown(targetElement)
	targetElement.isKnown = true

	-- reinit target element data which is changable based on the known state
	initDynamicTargetElementData(targetElement, C.GetMessageDetails3(targetElement.messageID))

	-- deactivate the icon, so it will be reactivated (if required) with the updated known state (incl. elements which would be missing previously like the collectable element)
	deactivateIcon(targetElement)

	-- re-initialize the target element's visual elements, since these most likely changed
	-- note: the actual update of the icon visuals is handled by retriggerring the changeState()-call (see updateTargetElement())
	local _, _, _, _, displayState, _, _, _, selectedActionIcon, activeActionIcon, inactiveActionIcon = GetActionInfo(targetElement.messageID)
	initTargetElement(targetElement, displayState, selectedActionIcon, activeActionIcon, inactiveActionIcon)

	-- check to activate the aim ahead indicator, if the targetelement is configured to show the weapon range state and if the aim ahead indicator is enabled in the current target
	-- system mode
	if private.aimTargetElementEnabled and targetElement.softtarget and targetElement.showInWeaponRangeState then
		activateAimTargetElement()
	end

	-- note: nothing else required to be updated - all relevant changes will be handled as part of the normal target element update process including:
	--       - switching on speed-display, if required (f.e. object is non-stationary now known object)
	--       - displayMode (f.e. switching from single rectangle mode to another rectangle mode)
	--       - activating the outline (f.e. when a surface element became known and switched from rectangle to outline display mode)
	--       - etc.
end

function setSideText2(targetElement, text)
	setColoredText(targetElement.sideElement2, targetElement.sideTextElement2, targetElement.sideText2, text, targetElement.textColor)
	targetElement.sideText2 = text
end

function setMissileLockColor(missileLockEntry, state, relation)
	if state == "inactive" then
		return -- no color update, if we are in the inactive state
	end

	local colorMode = "other"
	if relation == 0 then
		colorMode = "hostile"
	end

	if missileLockEntry.colorMode == colorMode and missileLockEntry.state == state then
		return -- color mode already set correctly
	end

	local color = config.missileLockColor[colorMode][state]
	SetDiffuseColor(missileLockEntry.lockMaterialElement, color.r, color.g, color.b)
	setAttribute(getElement("p1effects", missileLockEntry.lockMaterialElement), "glowfactor", color.glow)
	SetDiffuseColor(missileLockEntry.targetMaterialElement, color.r, color.g, color.b)
	setAttribute(getElement("p1effects", missileLockEntry.targetMaterialElement), "glowfactor", color.glow)

	missileLockEntry.colorMode = colorMode
end

function setMissileLockState(missileLockEntry, state, relation)
	if missileLockEntry.state == state then
		return -- already set to correct state, nothing to do
	end

	goToSlide(missileLockEntry.lockElement, state)
	goToSlide(missileLockEntry.targetElement, state)
	setMissileLockColor(missileLockEntry, state, relation)

	missileLockEntry.state = state
end

-- the function sets the color of elements of the target element, which only change their state based on whether the element is obstructed or not
-- (in contrast to setTargetElementColor() which also sets the colors of elements based on the relation of the element, for example)
function setObstructionBasedColor(targetElement, colorMode, t)
	-- #coreUIHigh: aim ahead indicator, missilelock element, missiletarget element (or not?)

	if (t == nil) and (targetElement.colorMode == colorMode) then
		return -- nothing to do, color mode already the correct one
	end

	local shieldcolor = lerpColorModeColor(config.shieldBarColor, colorMode, t)
	SetDiffuseColor(targetElement.shieldElement, shieldcolor.r, shieldcolor.g, shieldcolor.b)
	setAttribute(targetElement.shieldMaterialElement, "glowfactor", shieldcolor.glow)

	local hullcolor = lerpColorModeColor(config.hullBarColor, colorMode, t)
	SetDiffuseColor(targetElement.hullElement, hullcolor.r, hullcolor.g, hullcolor.b)
	setAttribute(targetElement.hullMaterialElement, "glowfactor", hullcolor.glow)

	local missioncolor = lerpColorModeColor(config.missionColor, colorMode, t)
	SetDiffuseColor(targetElement.missionTargetElement, missioncolor.r, missioncolor.g, missioncolor.b)
	setAttribute(targetElement.missionTargetMaterialElement, "glowfactor", missioncolor.glow)
	SetDiffuseColor(targetElement.priorityMissionTargetElement, missioncolor.r, missioncolor.g, missioncolor.b)
	setAttribute(targetElement.priorityMissionTargetMaterialElement, "glowfactor", missioncolor.glow)
	-- #coreUILow - suboptimal to also colorize the unused element (same for coloring the colored rectangular elements...

	local bracketcolor = lerpColorModeColor(config.targetRectangleColor, colorMode, t)
	SetDiffuseColor(targetElement.rectangleTargetNormalAnarkElement, bracketcolor.r, bracketcolor.g, bracketcolor.b)
	for _, material in ipairs(targetElement.rectangleElements["target_normal"]) do
		setAttribute(material, "glowfactor", bracketcolor.glow)
	end
	SetDiffuseColor(targetElement.rectangleTargetShortAnarkElement, bracketcolor.r, bracketcolor.g, bracketcolor.b)
	for _, material in ipairs(targetElement.rectangleElements["target_short"]) do
		setAttribute(material, "glowfactor", bracketcolor.glow)
	end
	SetDiffuseColor(targetElement.rectangleSoftTargetNormalAnarkElement, bracketcolor.r, bracketcolor.g, bracketcolor.b)
	for _, material in ipairs(targetElement.rectangleElements["softtarget_normal"]) do
		setAttribute(material, "glowfactor", bracketcolor.glow)
	end
	SetDiffuseColor(targetElement.rectangleSoftTargetShortAnarkElement, bracketcolor.r, bracketcolor.g, bracketcolor.b)
	for _, material in ipairs(targetElement.rectangleElements["softtarget_short"]) do
		setAttribute(material, "glowfactor", bracketcolor.glow)
	end

	-- rectangular mission target elements
	local missionElements = {
		{ "mtarget_large",		targetElement.rectangleMissionLargeAnarkElement  },
		{ "pmtarget_large",		targetElement.rectanglePriorityMissionLargeAnarkElement },
		{ "mtarget_small",		targetElement.rectangleMissionSmallAnarkElement  },
		{ "pmtarget_small",		targetElement.rectanglePriorityMissionSmallAnarkElement },
	}
	for _, entry in ipairs(missionElements) do
		SetDiffuseColor(entry[2], missioncolor.r, missioncolor.g, missioncolor.b)
		for _, material in ipairs(targetElement.rectangleElements[entry[1]]) do
			setAttribute(material, "glowfactor", missioncolor.glow)
		end
	end
end

function updateDynamicRectangleIcons(targetElement)
	-- retrieve the dynamic data for the additional cions
	local missionIcon       = C.GetMissionOfferIcons(targetElement.componentID)
	local activeMissionIcon = ffi.string(missionIcon.active)
	local specialNPCs       = C.GetSpecialNPCs(targetElement.componentID)

	local curIcon = 1

	if specialNPCs.factionNPC then
		targetElement.additionalIcons[curIcon].textures = {
			["active"]   = "npc_factionrep",
			["inactive"] = "npc_factionrep",
			["select"]   = "npc_factionrep"
		}
		curIcon = curIcon + 1
	end

	if specialNPCs.shadyGuy then
		targetElement.additionalIcons[curIcon].textures = {
			["active"]   = "npc_shadyguy",
			["inactive"] = "npc_shadyguy",
			["select"]   = "npc_shadyguy"
		}
		curIcon = curIcon + 1
	end

	if specialNPCs.missionActor then
		targetElement.additionalIcons[curIcon].textures = {
			["active"]   = "npc_missionactor",
			["inactive"] = "npc_missionactor",
			["select"]   = "npc_missionactor"
		}
		curIcon = curIcon + 1
	end

	if activeMissionIcon ~= "" then
		targetElement.additionalIcons[curIcon].textures = {
			["active"]   = activeMissionIcon,
			["inactive"] = ffi.string(missionIcon.inactive),
			["select"]   = ffi.string(missionIcon.select)
		}
		curIcon = curIcon + 1
	end

	-- clean up outdate textures
	for i = curIcon, 4 do
		targetElement.additionalIcons[curIcon].textures = nil
	end

	-- properly set the additional icons
	for i = 1, 4 do
		local textureSet = targetElement.additionalIcons[i].textures
		if textureSet ~= nil then
			activateAdditionalIcon(targetElement.additionalIcons[i])
			SetIcon(targetElement.additionalIcons[i].textureElement, textureSet[targetElement.currentState], targetElement.iconColor.r, targetElement.iconColor.g, targetElement.iconColor.b, config.useIconOverlayColor, targetElement.iconSize, targetElement.iconSize)
			setAttribute(targetElement.additionalIcons[i].materialElement, "glowfactor", targetElement.iconColor.glow)
		else
			deactivateAdditionalIcon(targetElement.additionalIcons[i])
		end
	end
end

function updateMissileLock(missileLockEntry, lockPercentage, counterMeasureTarget)
	-- note: we must check for currentSofttarget == nil, since we just might have lost the softtarget (as part of the update processing of the target system) while the missile lock system
	-- would still report the lock percentage for the previous target it still worked with
	-- note: it's intentional to deactivate the missile lock (if we lost the current softtarget) even if the missile is aiming at a countermeasure
	if lockPercentage == 0 or private.currentSofttarget == nil then
		setMissileLockState(missileLockEntry, "inactive", 0)
		return
	end

	local x, y, z, onScreen, yaw, pitch, roll
	if counterMeasureTarget ~= 0 then
		-- use countermeasure positions, if missile targets a counter measure atm
		x, y, z, onScreen, yaw, pitch, roll = getCounterMeasurePosition(counterMeasureTarget)
	else
		-- otherwise use target element position
		x, y, z, onScreen, yaw, pitch, roll = getTargetElementPosition(private.currentSofttarget)
	end

	if not onScreen then
		setMissileLockState(missileLockEntry, "inactive", private.currentSofttarget.curRelation) -- we don't display lock indicators, if the target is off screen
		return
	end

	local state = "locking"
	if lockPercentage == 100 then
		state = "locked"
	end
	setMissileLockState(missileLockEntry, state, private.currentSofttarget.curRelation)

	-- #coreUILow - scale value should use the countermeasure position, if we target the countermeasure element - P1DEV-346
	local scale = getTargetElementScale(private.currentSofttarget)
	updateElementPosition(missileLockEntry.targetElement, x, y, z, yaw, pitch, roll, scale)
	-- #coreUIMed - improve this handling to start from the actual crosshair position (i.e. x*lockPercentage -> ((xTarget - xCrosshair)*lockPercentage + xCrosshair)) - P1DEV-347
	updateElementPosition(missileLockEntry.lockElement, x*lockPercentage/100, y*lockPercentage/100, z, yaw, pitch, roll, scale)
end

function updateMissileLockColor(relation)
	if not private.missileLocksEnabled then
		return
	end

	for i = 1, config.maxMissileLocks do
		setMissileLockColor(private.missileLock[i], private.missileLock[i].state, relation)
	end
end

function updateMissileLocks()
	if not private.missileLocksEnabled then
		return
	end

	local numPrimaryWeapons   = tonumber(C.GetNumPrimaryWeapons())
	local numSecondaryWeapons = tonumber(C.GetNumSecondaryWeapons())
	local numWeapons          = numPrimaryWeapons + numSecondaryWeapons
	-- #coreUIMed - enable once assume support was added
	-- assume(numWeapons <= config.maxMissileLocks)
	for i = 1, numPrimaryWeapons do
		-- #coreUIMed - optimize --- no need to check unguided missiles
		local weaponDetails = C.GetPrimaryWeapon(i)
		updateMissileLock(private.missileLock[i], weaponDetails.lockPercent, weaponDetails.counterMeasureTarget)
	end

	for i = 1, numSecondaryWeapons do
		-- #coreUIMed - optimize --- no need to check unguided missiles
		local weaponDetails = C.GetSecondaryWeapon(i)
		updateMissileLock(private.missileLock[i+numPrimaryWeapons], weaponDetails.lockPercent, weaponDetails.counterMeasureTarget)
	end

	for i = numWeapons + 1, config.maxMissileLocks do
		-- ensure other missile locks are inactive
		-- #coreUIMed - this could be improved and only be done, if the number of secondary weapons changed
		setMissileLockState(private.missileLock[i], "inactive")
	end
end

function updateSideText2(targetElement)
	if (not targetElement.softtarget) or (not private.speedDisplayEnabled) or targetElement.isStationary or targetElement.surfaceElement or (not targetElement.isKnown) then
		-- side text is only displayed for the softtarget, only if it's enabled (f.e. disabled in 1st-person), and not for stationary objects (like gates, stations, highways, etc.)
		deactivateSideText2(targetElement)
		return
	end

	local componentDetails = C.GetComponentDetails(targetElement.componentID, targetElement.connectionName)
	local speed = componentDetails.speed

	if math.abs(speed) >= 0.01 * config.speedoflight then
		speed = math.floor(speed * 100 / config.speedoflight + 0.5) / 100
		text = speed .. L["c"]
	elseif math.abs(speed) >= 10000 then
		if math.abs(speed) >= 100000 then
			speed = math.floor(speed / 1000 + 0.5)
		else
			speed = math.floor(speed / 100 + 0.5) / 10
		end
		text = speed .. " " .. L["km"] .. "/" .. L["s"]
	else
		text = speed .. " " .. L["m/s"]
	end

	setSideText2(targetElement, text)
end
