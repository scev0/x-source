-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef struct {
		double fps;
		double moveTime;
		double renderTime;
		double gpuTime;
	} FPSDetails;
	typedef struct {
		int major;
		int minor;
	} GameVersion;
	bool AreAssertsEnabled();
	bool AreMandatoryAssertsEnabled();
	bool AreOptionalAssertEnabled();
	void ClearErrorLog();
	bool CopyToClipboard(const char*const text);
	void DisableAsserts();
	void DisableOptionalAsserts();
	void EnableAsserts();
	void EnableOptionalAsserts();
	int GetConfigSetting(const char*const setting);
	FPSDetails GetFPS();
	GameVersion GetGameVersion();
	bool IsErrorLogActive();
	bool IsFPSEnabled();
	bool IsVRMode();
	void NotifyErrorLogDispatching();
	void NotifyErrorLogDispatchingDone();
	void ReenableErrorLog();
	void SetConfigSetting(const char*const setting, const bool value);
	void SetFPSOverlayInMaster(bool value);
]]

local config = {
	errorLogLimit  = 1000, -- max number of messages the log will keep a record of
	currentVersion = 4,    -- the current data version
	layer = 0              -- the frame layer
}

-- __CORE_DEBUGLOG_LOG.data = {
--    [x] = {
--       gamestart = number,    -- the gamestart this message/error occurred in
--       timestamp = timestamp, -- the timestamp the message/error occurred
--       message   = message    -- the actual message
--    }
-- }
-- note: we set the lastClear version to 0.0, so that we simply clear the log initially and do not have to bother with keeping that version number updated separately
__CORE_DEBUGLOG_LOG = __CORE_DEBUGLOG_LOG or { version = config.currentVersion, lastClear = { major = 0, minor = 0 }, data = {} }

local private = {
	log = nil,                     -- all logged debug messages
	fpsFrameDescriptor = nil,      -- the fps counter frame descriptor
	debugLogFrameDescriptor = nil, -- the frame descriptor
	fpsTableDescriptor = nil,      -- the fps counter table descriptor
	table1Descriptor = nil,        -- the upper table descriptor
	table2Descriptor = nil,        -- the lower table descriptor
	contentDescriptor = nil,       -- the debug message (fontstring) to be displayed
	firstButtonDescriptor = nil,   -- the first button descriptor
	lastButtonDescriptor = nil,    -- the last button descriptor
	prevButtonDescriptor = nil,    -- the previous button descriptor
	nextButtonDescriptor = nil,    -- the next button descriptor
	reenableButton = nil,          -- the reenable button
	debugLogFrame = nil,           -- the displayed debug log frame
	fpsFrame = nil,                -- the displayed fps frame
	debugMessageTable = nil,       -- the debug message table
	fpsDebugLogText = nil,         -- the FPS text line in the debuglog (nil, if not present atm)
	fpsCounterText = nil,          -- the FPS text line in the fps counter (nil, if not present atm)
	optionalAssertEnabled = false, -- indicates whether optional assertions are enabled atm
	assertEnabled = false,         -- indicates whether assertions are enabled atm
	popUpOnError = true,           -- indicates whether the debug log pops-up on errors
	popUpOnOptionalAssert = true,  -- indicates whether the debug log pops-up on optional assertions
	popUpOnAssert = true,          -- indicates whether the debug log pops-up on assertions
	enableAssertSettings = false,  -- indicates whether assertion control settings are enabled
	showFPS = false,               -- indicates whether the FPS frame is displayed atm
	fpsCounterHidden = false,      -- indicates whether the FPS counter is hidden atm
	fpsRow = nil,                  -- the table row in which the FPS counter is displayed
	curMessage = 0,                -- the number of the currently displayed message
	fpsCounterEnabled = false,     -- indicates whether the UI FPS counter is enabled
	fpsButtonWarning = nil,        -- the warning test (if any) associated with the fps button
	newMessageStartIndex = 0,      -- the index in the log, where new messages start (in contrast to old ones)
	curGameStartCount = 1          -- current gamestart count
}

local addDebugMessage
local clearDataOnVersionChange
local createDescriptors
local getDebugMessage
local hideDebugLog
local hideFPSCounter
local init
local initDebugLogData
local isDebugLogActive
local onClear
local onCopy
local onDebugLog
local onDebugLogViewCreated
local onFirstButton
local onFrameCounterViewCreated
local onHideDebugLog
local onHideFPS
local onHideFPSCounter
local onHotkey
local onLastButton
local onNextButton
local onPrevButton
local onReenable
local onToggleAssert
local onToggleAssertPopUp
local onToggleErrorPopUp
local onToggleOptionalAssertPopUp
local onToggleOptionalAssert
local onToggleShowFPSButton
local showDebugLog
local showFPSCounter
local sortDebugLog
local toggleDebugLog
local updateButtons
local updateDebugMessage
local updateFPS
local updateReenableButton
local upgradeData

-- insertionPos specifies position in the log where the message will be added to (shifting any message at pos+1 ahead)
-- if the insertion exceeds config.errorLogLimit number of messages (i.e. 1000), the oldest message will be dropped
-- if allowTimestampModification is true, a call to addDebugMessage() is allowed to change the timestamp of an existing entry (after private.newMessageStartIndex) - in this case
-- the caller is required to do a resorting of messages afterwards to ensure a proper timestamp-based sorting in the DebugLog
function addDebugMessage(id, insertionPos, allowTimestampModification)
	-- #coreUIMed - enable once adding assume()-support
	--assume(insertionPos > 0 and insertionPos <= #private.log + 1)
	--assume(insertionPos >= private.newMessageStartIndex)

	local timestamp, message = getDebugMessage(id)
	-- only compare to the current errors (not the old ones)
	for index = private.newMessageStartIndex + 1, #private.log do
		if private.log[index].message == message then
			-- message already exists in the log - if we allow to modify the timestamp of the message, update (and predate it)
			-- note that this requires then resorting the entries based on timestamps to ensure correctly sorted entries)
			if allowTimestampModification then
				if private.log[index].timestamp >= timestamp then
					private.log[index].timestamp = timestamp
					return true
				end
			end
			return false -- message was not inserted (i.e. is already in the log for the current gamestart - prevent duplicated entries)
		end
	end

	table.insert(private.log, insertionPos, {gamestart = private.curGameStartCount, timestamp = timestamp, message = message})
	while #private.log > config.errorLogLimit do
		table.remove(private.log, 1)
		if private.curMessage > 1 then
			-- we removed a message, make sure the curmessage pointer still points to the current one wich was moved
			private.curMessage = private.curMessage - 1
		end
		if private.newMessageStartIndex > 0 then
			-- also move the new message start index one down, so it still points to the same message
			private.newMessageStartIndex = private.newMessageStartIndex - 1
		end
	end

	return true
end

function clearDataOnVersionChange()
	local version = C.GetGameVersion()

	-- we perform a simple version number mismatch check here (instead of a >= check), so for each version number change
	-- (be it up or down) we clear the data
	if version.major ~= __CORE_DEBUGLOG_LOG.lastClear.major or version.minor ~= __CORE_DEBUGLOG_LOG.lastClear.minor then
		-- clear the debug log after each game version update, so that old (outdated) data is removed
		__CORE_DEBUGLOG_LOG.lastClear.major = version.major
		__CORE_DEBUGLOG_LOG.lastClear.minor = version.minor
		__CORE_DEBUGLOG_LOG.data = {}
		private.log = __CORE_DEBUGLOG_LOG.data
	end
end

function createDescriptors()
	local firstButton = {
		["size"] = {
			["width"] = 60,
			["height"] = 23
		},
		["color"] = Color["debuglog_button_background"],
		["active"] = true,
		["hotkey"] = {
			["action"] = "INPUT_STATE_DEBUGLOG_FIRST",
			["displayIcon"] = false
		},
		["text"] = {
			["text"] = "FIRST",
			["fontsize"] = 9,
			["fontname"] = "Zekton",
			["color"]    = Color["text_normal"],
		}
	}

	local lastButton = {
		["size"] = {
			["width"] = 60,
			["height"] = 23
		},
		["color"] = Color["debuglog_button_background"],
		["active"] = true,
		["hotkey"] = {
			["action"] = "INPUT_STATE_DEBUGLOG_LAST",
			["displayIcon"] = false
		},
		["text"] = {
			["text"] = "LAST",
			["fontsize"] = 9,
			["fontname"] = "Zekton",
			["color"]	 = Color["text_normal"],
		}
	}

	local prevButton = {
		["size"] = {
			["width"] = 60,
			["height"] = 23
		},
		["color"] = Color["debuglog_button_background"],
		["active"] = true,
		["hotkey"] = {
			["action"] = "INPUT_STATE_DEBUGLOG_PREV",
			["x"] = 39,
			["y"] = 0,
			["displayIcon"] = true
		},
		["text"] = {
			["text"] = "PREV",
			["alignment"] = "left",
			["fontsize"] = 9,
			["fontname"] = "Zekton",
			["color"]    = Color["text_normal"],
		}
	}

	local nextButton = {
		["size"] = {
			["width"] = 60,
			["height"] = 23
		},
		["color"] = Color["debuglog_button_background"],
		["active"] = true,
		["hotkey"] = {
			["action"] = "INPUT_STATE_DEBUGLOG_NEXT",
			["x"] = 39,
			["y"] = 0,
			["displayIcon"] = true
		},
		["text"] = {
			["text"] = "NEXT",
			["fontsize"] = 9,
			["alignment"] = "left",
			["fontname"] = "Zekton",
			["color"]    = Color["text_normal"],
		}
	}

	local onOffButton = {
		["size"] = {
			["width"] = 30,
			["height"] = 20
		},
		["color"] = Color["debuglog_button_background"],
		["active"] = true,
		["text"] = {
			["text"] = "off",
			["fontsize"] = 9,
			["fontname"] = "Zekton",
			["color"]    = Color["text_normal"],
		}
	}

	local enableDisableButton = {
		["size"] = {
			["width"] = 80,
			["height"] = 20
		},
		["color"] = Color["debuglog_button_background"],
		["active"] = true,
		["text"] = {
			["text"] = "Log disabled",
			["fontsize"] = 9,
			["fontname"] = "Zekton",
			["color"]    = Color["text_normal"],
		}
	}

	local clearButton = {
		["size"] = {
			["width"] = 60,
			["height"] = 20
		},
		["color"] = Color["debuglog_button_background"],
		["active"] = true,
		["text"] = {
			["text"] = "Clear Log",
			["fontsize"] = 9,
			["fontname"] = "Zekton",
			["color"]    = Color["text_normal"],
		}
	}

	local copyButton = {
		["size"] = {
			["width"] = 150,
			["height"] = 20
		},
		["color"] = Color["debuglog_button_background"],
		["active"] = true,
		["hotkey"] = {
			["action"] = "INPUT_STATE_DEBUGLOG_COPY",
			["displayIcon"] = false
		},
		["text"] = {
			["text"] = "Copy to Clipboard",
			["fontsize"] = 9,
			["fontname"] = "Zekton",
			["color"]    = Color["text_normal"],
		}
	}

	local debugLogText = {
		text = "DebugLog Controls",
		alignment = "left",
		color = Color["text_normal"],
		fontname = "Zekton",
		fontsize = 9,
		wordwrap = false,
		offset = { x = 0, y = 0 },
		size = { width = 0, height = 16 },
	}
	local popUpText = {
		text = "Pop-Up Settings",
		alignment = "left",
		color = Color["text_normal"],
		fontname = "Zekton",
		fontsize = 9,
		wordwrap = false,
		offset = { x = 0, y = 0 },
		size = { width = 0, height = 16 },
	}
	local debugSettingsText = {
		text = "Debug Settings",
		alignment = "left",
		color = Color["text_normal"],
		fontname = "Zekton",
		fontsize = 9,
		wordwrap = false,
		offset = { x = 0, y = 0 },
		size = { width = 0, height = 16 },
	}
	local errorsText = {
		text = "Errors",
		alignment = "left",
		color = Color["text_normal"],
		fontname = "Zekton",
		fontsize = 9,
		wordwrap = false,
		offset = { x = 0, y = 0 },
		size = { width = 0, height = 16 },
	}
	local fpsText = {
		text = "FPS Display",
		alignment = "left",
		color = Color["text_normal"],
		fontname = "Zekton",
		fontsize = 9,
		wordwrap = false,
		offset = { x = 0, y = 0 },
		size = { width = 0, height = 16 },
	}
	local optionalText = {
		text = "Optional Asserts",
		alignment = "left",
		color = Color["text_normal"],
		fontname = "Zekton",
		fontsize = 9,
		wordwrap = false,
		offset = { x = 0, y = 0 },
		size = { width = 0, height = 16 },
	}
	local assertText = {
		text = "Assertions",
		alignment = "left",
		color = Color["text_normal"],
		fontname = "Zekton",
		fontsize = 9,
		wordwrap = false,
		offset = { x = 0, y = 0 },
		size = { width = 0, height = 16 },
	}
	local assertDebugText = {
		text = "Assertion Debug Settings",
		alignment = "left",
		color = Color["text_normal"],
		fontname = "Zekton",
		fontsize = 9,
		wordwrap = false,
		offset = { x = 0, y = 0 },
		size = { width = 0, height = 16 },
	}

	local textdescriptor = {
		text = "",
		alignment = "left",
		color = Color["text_normal"],
		fontname = "Zekton",
		fontsize = 9,
		wordwrap = false,
		offset = { x = 0, y = 0 },
		size = { width = 0, height = 0 },
	}
	local emptyCellDescriptor = CreateFontString(textdescriptor)

	private.firstButtonDescriptor = CreateButton(firstButton)
	private.lastButtonDescriptor  = CreateButton(lastButton)
	private.prevButtonDescriptor  = CreateButton(prevButton)
	private.nextButtonDescriptor  = CreateButton(nextButton)

	local textdescriptor = {
		text = "",
		alignment = "left",
		color = Color["text_normal"],
		fontname = "Zekton",
		fontsize = 10,
		wordwrap = true,
		offset = { x = 0, y = 0 },
		size = { width = 0, height = 160 },
	}
	private.contentDescriptor     = CreateFontString(textdescriptor)

	local table1content = {
		[1] = {
			["cols"] = {
				[1] = {
					["content"] = private.contentDescriptor
				}
			}
		}
	}

	-- #StefanMed - move to separate function
	-- BEGIN
	private.assertEnabled = C.AreMandatoryAssertsEnabled()
	private.optionalAssertEnabled = C.AreOptionalAssertEnabled()

	local errorPopUp          = C.GetConfigSetting("popUpOnError")
	local assertPopUp         = C.GetConfigSetting("popUpOnAssert")
	local optionalAssertPopUp = C.GetConfigSetting("popUpOnOptionalAssert")

	-- by default all pop-ups are active - hence checking for 0, since -1 and 1 then correspond to "enable it"
	if errorPopUp == 0 then
		private.popUpOnError = false
	elseif errorPopUp == -1 and not private.enableAssertSettings then
		private.popUpOnError = false -- in master-builds (identified via enableAssertSettings indirectly) or in case the game is started with /disableassertions, we do not display error-pop-ups unless the player enables them explicitly
	end
	if assertPopUp == 0 or not private.enableAssertSettings then
		-- in case the game is started with /disableassertions, never display the assertion popups (consistent with not showing the configuration settings in this case in the DebugLog frame)
		private.popUpOnAssert = false
	end
	if optionalAssertPopUp == 0 or not private.enableAssertSettings then
		-- in case the game is started with /disableassertions, never display the assertion popups (consistent with not showing the configuration settings in this case in the DebugLog frame)
		private.popUpOnOptionalAssert = false
	end
	-- END

	local table2content = {
		[1] = {
			["cols"] = {
				[1] = {
					["content"] = private.firstButtonDescriptor
				},
				[2] = {
					["content"] = private.prevButtonDescriptor
				},
				[3] = {
					["content"] = emptyCellDescriptor
				},
				[4] = {
					["content"] = private.nextButtonDescriptor
				},
				[5] = {
					["content"] = private.lastButtonDescriptor
				}
			}
		},
		[2] = {
			["selectable"] = false,
			["cols"] = {
				[1] = {
					["content"] = emptyCellDescriptor,
					["colspan"] = 5
				},
				[2] = {
					["colspan"] = 0
				},
				[3] = {
					["colspan"] = 0
				},
				[4] = {
					["colspan"] = 0
				},
				[5] = {
					["colspan"] = 0
				}
			}
		},
		[3] = {
			["selectable"] = false,
			["cols"] = {
				[1] = {
					["content"] = CreateFontString(debugLogText),
					["colspan"] = 5
				},
				[2] = {
					["colspan"] = 0
				},
				[3] = {
					["colspan"] = 0
				},
				[4] = {
					["colspan"] = 0
				},
				[5] = {
					["colspan"] = 0
				}
			}
		},
		[4] = {
			["cols"] = {
				[1] = {
					["content"] = CreateButton(clearButton),
					["colspan"] = 2
				},
				[2] = {
					["colspan"] = 0
				},
				[3] = {
					["content"] = CreateButton(copyButton),
				},
				[4] = {
					["content"] = CreateButton(enableDisableButton),
					["colspan"] = 2
				},
				[5] = {
					["colspan"] = 0
				}
			}
		},
		[5] = {
			["selectable"] = false,
			["cols"] = {
				[1] = {
					["content"] = emptyCellDescriptor,
					["colspan"] = 5
				},
				[2] = {
					["colspan"] = 0
				},
				[3] = {
					["colspan"] = 0
				},
				[4] = {
					["colspan"] = 0
				},
				[5] = {
					["colspan"] = 0
				}
			}
		},
		[6] = {
			["selectable"] = false,
			["cols"] = {
				[1] = {
					["content"] = CreateFontString(popUpText),
					["colspan"] = 2
				},
				[2] = {
					["colspan"] = 0
				},
				[3] = {
					["content"] = CreateFontString(debugSettingsText),
					["colspan"] = 3
				},
				[4] = {
					["colspan"] = 0
				},
				[5] = {
					["colspan"] = 0
				}
			}
		},
		[7] = {
			["cols"] = {
				[1] = {
					["content"] = CreateFontString(errorsText)
				},
				[2] = {
					["content"] = CreateButton(onOffButton)
				},
				[3] = {
					["content"] = CreateFontString(fpsText)
				},
				[4] = {
					["content"] = CreateButton(onOffButton),
					["colspan"] = 2
				},
				[5] = {
					["colspan"] = 0
				}
			}
		}
	}

	-- set the table row used to display the fps counter
	private.fpsRow = 8

	if private.enableAssertSettings then
		table2content[8] = {
			["cols"] = {
				[1] = {
					["content"] = CreateFontString(optionalText)
				},
				[2] = {
					["content"] = CreateButton(onOffButton),
					["colspan"] = 4
				},
				[3] = {
					["colspan"] = 0
				},
				[4] = {
					["colspan"] = 0
				},
				[5] = {
					["colspan"] = 0
				}
			}
		}
		table2content[9] = {
			["cols"] = {
				[1] = {
					["content"] = CreateFontString(assertText)
				},
				[2] = {
					["content"] = CreateButton(onOffButton),
					["colspan"] = 4
				},
				[3] = {
					["colspan"] = 0
				},
				[4] = {
					["colspan"] = 0
				},
				[5] = {
					["colspan"] = 0
				}
			}
		}
		table2content[10] = {
			["selectable"] = false,
			["cols"] = {
				[1] = {
					["content"] = emptyCellDescriptor,
					["colspan"] = 5
				},
				[2] = {
					["colspan"] = 0
				},
				[3] = {
					["colspan"] = 0
				},
				[4] = {
					["colspan"] = 0
				},
				[5] = {
					["colspan"] = 0
				}
			}
		}
		table2content[11] = {
			["selectable"] = false,
			["cols"] = {
				[1] = {
					["content"] = CreateFontString(assertDebugText),
					["colspan"] = 5
				},
				[2] = {
					["colspan"] = 0
				},
				[3] = {
					["colspan"] = 0
				},
				[4] = {
					["colspan"] = 0
				},
				[5] = {
					["colspan"] = 0
				}
			}
		}
		table2content[12] = {
			["cols"] = {
				[1] = {
					["content"] = CreateFontString(optionalText)
				},
				[2] = {
					["content"] = CreateButton(onOffButton),
					["colspan"] = 4
				},
				[3] = {
					["colspan"] = 0
				},
				[4] = {
					["colspan"] = 0
				},
				[5] = {
					["colspan"] = 0
				}
			}
		}
		table2content[13] = {
			["cols"] = {
				[1] = {
					["content"] = CreateFontString(assertText)
				},
				[2] = {
					["content"] = CreateButton(onOffButton),
					["colspan"] = 4
				},
				[3] = {
					["colspan"] = 0
				},
				[4] = {
					["colspan"] = 0
				},
				[5] = {
					["colspan"] = 0
				}
			}
		}
		private.fpsRow = 14
	end
	
	local textdescriptor = {
		text = "",
		alignment = "right",
		color = Color["text_normal"],
		fontname = "Zekton Outlined",
		fontsize = 10,
		wordwrap = false,
		offset = { x = 0, y = 0 },
		size = { width = 0, height = 16 },
	}

	-- add FPS display
	table2content[private.fpsRow] = {
		["cols"] = {
			[1] = {
				-- note: the text is updated in the onUpdate()-function, if the setting specifies to display the FPS counter - hence initialize to ""
				["content"] = CreateFontString(textdescriptor),
				["colspan"] = 5
			},
			[2] = {
				["colspan"] = 0
			},
			[3] = {
				["colspan"] = 0
			},
			[4] = {
				["colspan"] = 0
			},
			[5] = {
				["colspan"] = 0
			}
		}
	}

	-- descriptors for the normal debugLog
	private.table1Descriptor        = CreateTable("", table1content, 1, true, 2, false, false, 1, 0, 0, 170)
	private.table2Descriptor        = CreateTable("", table2content, { 20, 10, 35, 20, 15 }, true, false, 1, false, false, #table2content, 0, 175)
	private.debugLogFrameDescriptor = CreateFrame({private.table1Descriptor, private.table2Descriptor}, config.layer, "pda_bg", nil, "", nil, 500, 500, 200, 100, { close = true })

	-- descriptor for the FPS counter
	local fpsTableContent = {
		[1] = {
			["selectable"] = false,
			["cols"] = {
				[1] = {
					["content"] = CreateFontString(textdescriptor)
				}
			}
		}
	}
	private.fpsTableDescriptor = CreateTable("", fpsTableContent, 1, false, 0, false, false, 1)

	local posx, posy
	if C.IsVRMode() then
		-- in the VR version, the FPS display is positioned just above the target monitor
		posx = 350
		posy = 150
	else
		-- in non-VR versions, the FPS display is positioned in the lower right screen corner
		local width, height = getScreenInfo()
		posx = width - 300
		posy = height - 10
	end
	private.fpsFrameDescriptor = CreateFrame({private.fpsTableDescriptor}, config.layer, "", nil, "", nil, 300, 30, posx, posy)
end

function getDebugMessage(messageID)
	local severity = GetErrorSeverity(messageID)
	local prefix = "Info: "
	if severity == 2 then
		prefix = "Error: "
	elseif severity == 3 then
		prefix = "Optional Assertion: "
	elseif severity == 4 then
		prefix = "Assertion: "
	elseif severity == 5 then
		prefix = "PANIC: "
	-- else it's 1 (aka: master info) - note: 0 (aka: info) doesn't trigger the callback
	end

	return GetErrorTimestamp(messageID), prefix..GetError(messageID)
end

function hideDebugLog()
	if private.debugLogFrame == nil then
		return -- nothing to do
	end

	View.unregisterMenu("debuglog", false)

	private.debugLogFrame = nil
	private.debugMessageTable = nil
	private.curMessage = 0
	private.fpsDebugLogText = nil

	-- show fps counter, if we closed the debuglog (and have the FPS counter enabled)
	if private.showFPS then
		showFPSCounter()
	end
end

function hideFPSCounter()
	if private.fpsFrame == nil then
		return -- nothing to do
	end

	View.unregisterMenu("debuglog", false)

	private.fpsFrame = nil
	private.fpsCounterText = nil
end

function init()
	initDebugLogData()
	clearDataOnVersionChange()

	RegisterEvent("debugLog", onDebugLog)
	RegisterEvent("hideFPS", onHideFPS)

	SetScript("onHotkey", onHotkey)

	-- read config values
	private.enableAssertSettings = C.AreAssertsEnabled()
	private.showFPS = C.IsFPSEnabled()

	-- mode settings
	private.fpsCounterEnabled = C.IsVRMode()
	if private.fpsCounterEnabled then
		-- add the warning that the FPS counter will disable gametips / mission timers
		private.fpsButtonWarning = "WARNING - Enabling this setting will effectively disable gametips and mission timers."
	end

	-- #coreUIMed - review this --- shouldn't really register the onUpdate script before the frame would have been registered
	if private.showFPS and private.fpsCounterEnabled then
		-- we need to run the update-function only to update the FPS counter (hence register it selectively)
		SetScript("onUpdate", onUpdate)
	end

	createDescriptors()

	private.newMessageStartIndex = #private.log

	local numErrors            = GetNumErrors()
	local hasError             = false
	local hasAssertion         = false
	local hasOptionalAssertion = false

	-- determine the gamestart count
	if #private.log > 0 then
		-- #StefanLow -- could be improved so that we actually query the game engine for the current gamestart count
		-- atm not doing so results in a UI reload increasing the gamestart count, if there was an error recorded for the current gamestart
		-- ultimately resulting in a gamestart count mismatch
		-- however we just accept that issue atm, since it's expected not to hurt much
		private.curGameStartCount = private.log[#private.log].gamestart + 1
	end

	if numErrors > 0 then
		-- determine the message index, where the messages from the current gamestart begin
		local firstTimeStamp = GetErrorTimestamp(1)
		for i, entry in ipairs(private.log) do
			if entry.timestamp >= firstTimeStamp then
				private.newMessageStartIndex = i
				break
			end
		end

		-- next we have to determine the last message already in the private.log, so we won't duplicate it in the log
		local lastTimeStamp = 0
		if #private.log > 0 then
			lastTimeStamp = private.log[#private.log].timestamp
		end

		-- add all messages, skipping the ones already in the list
		-- also we do here reverse iteration through the errors, so in cases of processing > 1000 errors (i.e. config.errorLogLimit), we don't unnecessarily insert items just for them
		-- to be overwritten by newer ones again
		-- note: this handling also resolves cases where we incorrectly popup the DebugLog for assertions which were added during this loop but then got overwritten by error messages
		--       (see XRUIMOD-324 for details)
		local entryAdded = false
		for i = numErrors, 1, -1 do
			-- skip all errors, which we already have in the list (relying on the timestamp) to prevent entry duplication
			if GetErrorTimestamp(i) <= lastTimeStamp then
				break -- we can abort here --- effectively any previous entry will have a timestamp <= the previous one
			end

			local severity = GetErrorSeverity(i)
			-- skip plain info messages
			if severity > 0 then
				-- note: we must check whether the message was actually added (fixes XRUIMOD-295)
				-- in case of a reoccurring error, the debug log only records the very first of these errors (and hence also records only the timestamp of the first occurrance)
				-- as later reoccurrences of the same error will have a later timestamp, we'd still try to add these (with addDebugMessage() then skipping these)
				-- if we wouldn't do so, a UI reload would trigger an incorrect debug log popup, if the last recorded error was a reoccurring one
				if addDebugMessage(i, private.newMessageStartIndex + 1, true) then
					entryAdded = true
					if severity == 2 then hasError = true end
					if severity == 3 then hasOptionalAssertion = true end
					if severity == 4 then hasAssertion = true end

					if private.newMessageStartIndex == 0 and #private.log == config.errorLogLimit then
						break -- log completely filled -> no need to process further entires
					end
				end
			end
		end
	end

	if entryAdded then
		-- if we added an entry, we might have broken the timestamp based sorting (i.e. passing in true in the addDebugMessage() call above
		-- therfore, we must sort the log afterwards so that entries which changed their timestamp are properly rearranged in the right order
		-- since we always insert after private.newMessageStartIndex, only messages after that index need to be sorted
		sortDebugLog(private.newMessageStartIndex)
	end

	local popUpLog = false
	if hasError and private.popUpOnError then
		popUpLog = true
	elseif hasOptionalAssertion and private.popUpOnOptionalAssert then
		popUpLog = true
	elseif hasAssertion and private.popUpOnAssert then
		popUpLog = true
	end

	if popUpLog then
		showDebugLog()
	elseif private.showFPS then
		showFPSCounter()
	end
end

function initDebugLogData()
	if __CORE_DEBUGLOG_LOG ~= nil then
		if type(__CORE_DEBUGLOG_LOG) ~= "table" then
			DebugError("Invalid debugLog data. Data will be cleared.")
			__CORE_DEBUGLOG_LOG = nil
		elseif type(__CORE_DEBUGLOG_LOG.version) ~= "number" then
			DebugError("Invalid debugLog version information. Data will be cleared.")
			__CORE_DEBUGLOG_LOG = nil
		end
	end

	if __CORE_DEBUGLOG_LOG ~= nil then
		upgradeData()

		if type(__CORE_DEBUGLOG_LOG.data) ~= "table" then
			DebugError("Invalid debugLog data content. Data will be cleared.")
			__CORE_DEBUGLOG_LOG = nil
		elseif type(__CORE_DEBUGLOG_LOG.lastClear) ~= "table" then
			DebugError("Invalid debugLog lastClear data. Data will be cleared.")
			__CORE_DEBUGLOG_LOG = nil
		elseif type(__CORE_DEBUGLOG_LOG.lastClear.major) ~= "number" then
			DebugError("Invalid debugLog lastClear major version number data. Data will be cleared.")
			__CORE_DEBUGLOG_LOG = nil
		elseif type(__CORE_DEBUGLOG_LOG.lastClear.minor) ~= "number" then
			DebugError("Invalid debugLog lastClear minor version number data. Data will be cleared.")
			__CORE_DEBUGLOG_LOG = nil
		elseif __CORE_DEBUGLOG_LOG.version ~= config.currentVersion then
			DebugError("Invalid debugLog data version. Retrieved data version '"..tostring(__CORE_DEBUGLOG_LOG.version).."' but expected version "..tostring(config.currentVersion)..". Data will be cleared.")
			__CORE_DEBUGLOG_LOG = nil
		end
	end

	__CORE_DEBUGLOG_LOG = __CORE_DEBUGLOG_LOG or { version = config.currentVersion, lastClear = { major = 0, minor = 0 }, data = {} }

	private.log = __CORE_DEBUGLOG_LOG.data
end

function isDebugLogActive()
	-- note: we favor checking the validity of the widget element frame, so that in cases where we retrieve an onShowError()-event prior to an onHide-event
	-- we still do not cause errors, because we'd work with the already freed private.debugLogFrame element
	return private.debugLogFrame ~= nil and IsValidWidgetElement(private.debugLogFrame)
end

function onClear()
	C.ClearErrorLog()
	__CORE_DEBUGLOG_LOG.data = {}
	private.log = __CORE_DEBUGLOG_LOG.data
	private.newMessageStartIndex = 0
	updateDebugMessage(0)
end

function onCopy()
	if private.curMessage == 0 then
		return -- no message displayed atm - nothing to copy to the clipboard
	end

	local entry = private.log[private.curMessage]
	local success = C.CopyToClipboard("[gamestart: "..tostring(entry.gamestart).."] - ["..tostring(GetDate("!%c", entry.timestamp)).."]: "..tostring(entry.message))
	if not success then
		-- #StefanMed - better add that to some text-output on the DebugLog frame
		DebugError("Failed to copy message to clipbaoard.")
	end
end

function onDebugLog(_, errorMessageID)
	C.NotifyErrorLogDispatching()

	local severity = GetErrorSeverity(errorMessageID)
	if severity == 0 then
 		-- not logging info-messages
		C.NotifyErrorLogDispatchingDone()
		return
	end

	local popUpDebugLog = false
	if severity == 2 then
		popUpDebugLog = private.popUpOnError
	elseif severity == 3 then
		popUpDebugLog = private.popUpOnOptionalAssert
	elseif severity == 4 then
		popUpDebugLog = private.popUpOnAssert
	elseif severity == 5 then
		popUpDebugLog = true
	-- else it's 1 (aka: master info) or 0 (aka: info) which don't trigger an auto popup
	end

	local lastMessageDisplayed = (private.curMessage == #private.log)

	if addDebugMessage(errorMessageID, #private.log + 1, false) then
		if isDebugLogActive() then
			-- if the log is already displayed, just update it (switch to new message only if last message is displayed)
			if private.curMessage == 0 or lastMessageDisplayed then
				updateDebugMessage(#private.log)
			else
				-- we must update the log in all cases
				-- if we just added a message, the numMessage counter increased
				-- if we were at the first message and the log was full, that message was dropped from the log and so must we update the display
				-- if we were displaying any other message (not the first or last one) we still must update the display, since the cur message number decreased by 1
				updateDebugMessage(private.curMessage)
			end
		elseif popUpDebugLog then
			showDebugLog()
		end
	end

	C.NotifyErrorLogDispatchingDone()
end

function onDebugLogViewCreated(frames)
	private.debugLogFrame = frames[1]

	if private.debugLogFrame == nil then
		return -- abort - this can happen if an error occurs when the widget system has been reset (example: issue an error during a NewGame()-call)
	end

	SetScript(private.debugLogFrame, "onHide", onHideDebugLog)

	local debugMessageTable, buttonTable = GetChildren(private.debugLogFrame)
	local firstButton      = GetCellContent(buttonTable, 1, 1)
	local lastButton       = GetCellContent(buttonTable, 1, 5)
	local nextButton       = GetCellContent(buttonTable, 1, 4)
	local prevButton       = GetCellContent(buttonTable, 1, 2)
	local clearButton      = GetCellContent(buttonTable, 4, 1)
	local copyButton       = GetCellContent(buttonTable, 4, 3)
	local enableButton     = GetCellContent(buttonTable, 4, 4)
	local errorPopUpButton = GetCellContent(buttonTable, 7, 2)
	local showFPSButton    = GetCellContent(buttonTable, 7, 4)

	-- get the fps text cell (row number varies, based on the mode the DebugLog is in)
	private.fpsDebugLogText = GetCellContent(buttonTable, private.fpsRow, 1)

	private.reenableButton = enableButton
	updateReenableButton()

	SetScript(prevButton,       "onClick", onPrevButton)
	SetScript(nextButton,       "onClick", onNextButton)
	SetScript(firstButton,      "onClick", onFirstButton)
	SetScript(lastButton,       "onClick", onLastButton)
	SetScript(errorPopUpButton, "onClick", onToggleErrorPopUp)
	SetScript(showFPSButton,    "onClick", onToggleShowFPSButton)
	SetScript(enableButton,     "onClick", onReenable)
	SetScript(clearButton,      "onClick", onClear)
	SetScript(copyButton,       "onClick", onCopy)
	
	private.debugMessageTable = debugMessageTable

	-- assertion related settings
	local optionalAssertButton, assertButton, optionalAssertPopUpButton, assertPopUpButton
	if private.enableAssertSettings then
		optionalAssertPopUpButton = GetCellContent(buttonTable, 8, 2)
		assertPopUpButton         = GetCellContent(buttonTable, 9, 2)
		optionalAssertButton      = GetCellContent(buttonTable, 12, 2)
		assertButton              = GetCellContent(buttonTable, 13, 2)

		SetScript(optionalAssertButton,      "onClick", onToggleOptionalAssert)
		SetScript(assertButton,              "onClick", onToggleAssert)
		SetScript(assertPopUpButton,         "onClick", onToggleAssertPopUp)
		SetScript(optionalAssertPopUpButton, "onClick", onToggleOptionalAssertPopUp)
	end
	updateButtons(optionalAssertButton, assertButton, errorPopUpButton, optionalAssertPopUpButton, assertPopUpButton, showFPSButton)

	updateDebugMessage(#private.log)
end

function onFirstButton()
	if #private.log > 0 then -- do nothing, if we do not have any message at all
		updateDebugMessage(1)
	end
end

function onFrameCounterViewCreated(frames)
	private.fpsFrame = frames[1]

	if private.fpsFrame == nil then
		return -- abort - this can happen if an error occurs when the widget system has been reset (example: issue an error during a NewGame()-call)
	end

	SetScript(private.fpsFrame, "onHide", onHideFPSCounter)

	local fpsTable = GetChildren(private.fpsFrame)
	private.fpsCounterText = GetCellContent(fpsTable, 1, 1)

end

function onHideDebugLog()
	hideDebugLog()
end

function onHideFPS(_, hide)
	if private.fpsCounterHidden == hide then
		return -- nothing to do
	end

	private.fpsCounterHidden = hide

	if not isDebugLogActive() and private.showFPS then
		-- nothing to do, if we display the debug log (since then we display the FPS counter in the debuglog)
		-- or if we don't show the FPS counter at all (since then it was not and will not be displayed)
		if hide then
			hideFPSCounter()
		else -- hide == false
			showFPSCounter()
		end
	end
end

function onHideFPSCounter()
	hideFPSCounter()
end

function onHotkey(action)
	if action == "INPUT_ACTION_OPEN_DEBUG_LOG" then
		toggleDebugLog()
	end
end

function onLastButton()
	updateDebugMessage(#private.log)
end

function onNextButton()
	if private.curMessage == #private.log then
		return -- already at last message
	end

	updateDebugMessage(private.curMessage + 1)
end

function onPrevButton()
	if private.curMessage <= 1 then
		return -- already at first message (or no message at all)
	end

	updateDebugMessage(private.curMessage - 1)
end

function onReenable()
	C.ReenableErrorLog()
	updateReenableButton()
end

function onToggleAssert(button)
	private.assertEnabled = not private.assertEnabled
	if private.assertEnabled then
		C.EnableAsserts()
		SetButtonText(button, "on")
	else
		C.DisableAsserts()
		SetButtonText(button, "off")
	end
end

function onToggleOptionalAssert(button)
	private.optionalAssertEnabled = not private.optionalAssertEnabled
	if private.optionalAssertEnabled then
		C.EnableOptionalAsserts()
		SetButtonText(button, "on")
	else
		C.DisableOptionalAsserts()
		SetButtonText(button, "off")
	end
end

function onToggleAssertPopUp(button)
	private.popUpOnAssert = not private.popUpOnAssert
	C.SetConfigSetting("popUpOnAssert", private.popUpOnAssert)
	if private.popUpOnAssert then
		SetButtonText(button, "on")
	else
		SetButtonText(button, "off")
	end
end

function onToggleErrorPopUp(button)
	private.popUpOnError = not private.popUpOnError
	C.SetConfigSetting("popUpOnError", private.popUpOnError)
	if private.popUpOnError then
		SetButtonText(button, "on")
	else
		SetButtonText(button, "off")
	end
end

function onToggleOptionalAssertPopUp(button)
	private.popUpOnOptionalAssert = not private.popUpOnOptionalAssert
	C.SetConfigSetting("popUpOnOptionalAssert", private.popUpOnOptionalAssert)
	if private.popUpOnOptionalAssert then
		SetButtonText(button, "on")
	else
		SetButtonText(button, "off")
	end
end

function onToggleShowFPSButton(button)
	private.showFPS = not private.showFPS
	C.SetFPSOverlayInMaster(private.showFPS)
	if private.showFPS then
		SetButtonText(button, "on")
		if private.fpsCounterEnabled then
			SetScript("onUpdate", onUpdate)
		end
	else
		SetButtonText(button, "off")
		-- remove the FPS-display, if we just turned it off
		-- note: using SetText(foo, "") doesn't clear the text - workaround: set to " " to clear
		if private.fpsDebugLogText ~= nil then
			SetText(private.fpsDebugLogText, " ")
		end
		if private.fpsCounterText ~= nil then
			SetText(private.fpsCounterText, " ")
		end
		if private.fpsCounterEnabled then
			RemoveScript("onUpdate", onUpdate)
		end
	end
end

function onUpdate()
	updateFPS()
end

function showDebugLog()
	if isDebugLogActive() then
		return -- already displayed atm
	end

	-- make sure that the FPS counter frame is closed, prior to bringing up the debug log (since both are mutually exclusive)
	-- this is a workaround for an underlying bug - see P1DEV-242
	hideFPSCounter()

	local exclusiveInteractions = true
	local playerControls        = false

	if not IsFirstPerson() then
		exclusiveInteractions = false
		playerControls        = true
	end

	View.registerMenu("debuglog", "debuglog", onDebugLogViewCreated, onHideDebugLog, {[config.layer] = private.debugLogFrameDescriptor}, exclusiveInteractions, false, true, playerControls, false, false, false)
end

-- this function sorts the debug log starting with startIndex up to #private.log
function sortDebugLog(startIndex)
	local index = startIndex
	-- note: we only need to go to the second last entry (as the last remaining entry will be at the right position of course)
	while index < #private.log - 1 do
		if private.log[index].timestamp > private.log[index+1].timestamp then
			-- swap the two entries...
			local temp             = private.log[index]
			private.log[index]     = private.log[index + 1]
			private.log[index + 1] = temp

			-- #coreUIMed - lazy implementation (it's assumed to not happen too often, so a runtime of O(n!) might be acceptable for now)
			-- ... and restart the sorting
			index = startIndex
		else
			index = index + 1
		end
	end
end

function showFPSCounter()
	if private.fpsFrame then
		-- note: can't really happen, but for symmetry and safety, let's play nice here...
		return -- already displayed atm
	end

	-- also make sure that at the time of displaying the FPS counter, the debug log is not displayed (which should not happen -> debug output)
	if isDebugLogActive() then
		DebugError("DebugLog error. FPS counter was tried to be displayed wiht a still active debug log. This is unsupported. Call will be skipped.")
		return
	end

	if not private.fpsCounterHidden and private.fpsCounterEnabled then
		View.registerMenu("debuglog", "debuglog", onFrameCounterViewCreated, onHideFPSCounter, {[config.layer] = private.fpsFrameDescriptor}, false, false, false, true, true, false, false, false)
	end
end

function toggleDebugLog()
	if isDebugLogActive() then
		hideDebugLog()
	else
		showDebugLog()
	end
end

function updateButtons(optionalAssertButton, assertButton, errorPopUpButton, optionalAssertPopUpButton, assertPopUpButton, showFPSButton)
	if private.popUpOnError then
		SetButtonText(errorPopUpButton, "on")
	else
		SetButtonText(errorPopUpButton, "off")
	end

	if private.showFPS then
		SetButtonText(showFPSButton, "on")
	else
		SetButtonText(showFPSButton, "off")
	end

	if not private.enableAssertSettings then
		return -- assert settings not active
	end

	if private.popUpOnAssert then
		SetButtonText(assertPopUpButton, "on")
	else
		SetButtonText(assertPopUpButton, "off")
	end

	if private.popUpOnOptionalAssert then
		SetButtonText(optionalAssertPopUpButton, "on")
	else
		SetButtonText(optionalAssertPopUpButton, "off")
	end

	if private.assertEnabled then
		SetButtonText(assertButton, "on")
	else
		SetButtonText(assertButton, "off")
	end

	if private.optionalAssertEnabled then
		SetButtonText(optionalAssertButton, "on")
	else
		SetButtonText(optionalAssertButton, "off")
	end
end

function updateFPS()
	if not private.showFPS or not private.fpsCounterEnabled or (private.fpsCounterText == nil and private.fpsDebugLogText == nil) then
		-- no visible FPS counter atm
		return
	end

	local gpuColor    = ColorText["text_negative"] -- initially red
	local moveColor   = ColorText["text_neutral"] -- initially yellow
	local renderColor = ColorText["text_positive"] -- initially green

	local timings = C.GetFPS()
	if timings.moveTime == 0 and timings.renderTime == 0 and timings.gpuTime == 0 then
		-- no detailed values available, just display the FPS
		local fpsText = string.format("FPS: %.2f", timings.fps)
		if private.fpsCounterText ~= nil then
			SetText(private.fpsCounterText, fpsText)
		end
		if private.fpsDebugLogText ~= nil then
			SetText(private.fpsDebugLogText, fpsText)
		end
		return
	end

	-- determine the correct moveColor value first
	if timings.moveTime < timings.gpuTime and timings.moveTime < timings.renderTime then
		-- swap moveColor (yellow) and renderColor (green)
		local temp = moveColor
		moveColor = renderColor
		renderColor = moveColor
	else
		-- move is not the lowest value, is it the highest?
		if timings.moveTime > timings.gpuTime and timings.moveTime > timings.renderTime then
			-- swap moveColor (yellow) and gpuColor (red)
			local temp = moveColor
			moveColor = gpuColor
			gpuColor = temp
		end
		-- otherwise we are fine - move time is the middle one (yellow)
	end

	-- determine the correlation between renderColor (yellow or green) and gpuColor (yellow or red)
	-- note that a single value check suffices here, since renderColor <-> gpuColor already correlates to renderTime < gpuColor due to
	-- the previous color swapping above
	if timings.renderTime > timings.gpuTime then
		-- we need to swap the colors
		local temp = renderColor
		renderColor = gpuColor
		gpuColor = temp
	end

	local fpsText = string.format("FPS: %.2f (%sM %.1fms %sR %.1fms %sG %.1fms\027X)", timings.fps, moveColor, timings.moveTime, renderColor, timings.renderTime, gpuColor, timings.gpuTime)
	if private.fpsCounterText ~= nil then
		SetText(private.fpsCounterText, fpsText)
	end
	if private.fpsDebugLogText ~= nil then
		SetText(private.fpsDebugLogText, fpsText)
	end
end

function updateReenableButton()
	local color = Color["debuglog_disabled"]
	local text = "Log disabled"
	if C.IsErrorLogActive() then
		text = "Log enabled"
		color = Color["debuglog_enabled"]
	end
	SetButtonText(private.reenableButton, text)
	SetButtonColor(private.reenableButton, color.r, color.g, color.b, color.a)
end

function updateDebugMessage(messageNumber)
	local text = "No messages"
	if messageNumber > 0 then
		local entry = private.log[messageNumber]
		text = "Message: "..tostring(messageNumber - private.newMessageStartIndex - 1).." ["..tostring(messageNumber).."/"..tostring(#private.log).."]\n[gamestart: "..tostring(entry.gamestart).."] - ["..tostring(GetDate("!%c", entry.timestamp)).."]: "..tostring(entry.message)
	end

	local cell = GetCellText(private.debugMessageTable, 1, 1)
	SetText(cell, text)

	private.curMessage = messageNumber
end

function upgradeData()
	-- changes:
	--  version 2:
	--   - changed data storage from plain messages to table of timestamp and message
	--  version 3:
	--   - added auto-clearing log upon version updates (hence updated upgradeData() to simply clear the log for versions < 3)
	--  version 4:
	--   - added gamestart-entry to data-section (hence old data should be cleared)
	if __CORE_DEBUGLOG_LOG.version < config.currentVersion then
		__CORE_DEBUGLOG_LOG = { version = config.currentVersion, lastClear = { major = 0, minor = 0 }, data = {} }
	end
end

---------------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------------

init()
