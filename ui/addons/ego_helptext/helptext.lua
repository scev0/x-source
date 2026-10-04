-- Ingame Help Text Display

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	float GetTextHeight(const char*const text, const char*const fontname, const float fontsize, const float wordwrapwidth);
	bool IsFullscreenMenuDisplayed(bool anymenu, const char* menuname);
	bool IsGamePaused(void);
	bool IsPlayerValid(void);
	bool IsVRMode(void);
]]

local menu = {
	name = "HelpTextMenu",
}

local config = {
	layer = 1,
	height = 400,
	width = 230,
	tableoffsetx = C.IsVRMode() and 25 or 5,
	tableoffsety = C.IsVRMode() and 225 or 5,
	textoffsetx = 5,
	textoffsety = 2,
	font = "Zekton",
	fontsize = 12,
	buttonHeight = 22,
	borderWidth = 2,
	queueversion = 2,

	blacklist = {
		"OptionsMenu",
	}
}

local function init()
	__CORE_HELPTEXT_DISPLAYEDHINTS = __CORE_HELPTEXT_DISPLAYEDHINTS or {}
	__CORE_HELPTEXT_QUEUE = __CORE_HELPTEXT_QUEUE or {
		version = config.queueversion,
	}
	menu.lastupdate = 0

	menu.uiScale = C.GetUIScale(C.IsVRMode())

	SetScript("onHotkey", menu.hotkey)

	menu.registered = true
	RegisterEvent("helptext", menu.onShowHelp)
	RegisterEvent("multihelptext", menu.onShowHelpMulti)
	RegisterEvent("clearhelptext", menu.onClearHelp)
	registerForEvent("gameplanchange", getElement("Scene.UIContract"), menu.onGamePlanChange)
end

function menu.onGamePlanChange(_, mode)
	if (mode == "cockpit") or (mode == "external") or (mode == "firstperson") or (mode == "externalfirstperson") then
		-- wait for these game plan changes to check stored data, otherwise it may not be available yet
		if (__CORE_HELPTEXT_QUEUE.version == nil) or (__CORE_HELPTEXT_QUEUE.version < config.queueversion) then
			menu.upgradeQueueVersion()
		end
		if not menu.duration then
			if __CORE_HELPTEXT_QUEUE[1] then
				menu.displayHelp()
			end
		end
	elseif (mode == "extro") or (mode == "stop") then
		if menu.registered then
			menu.registered = nil
			UnregisterEvent("helptext", menu.onShowHelp)
			UnregisterEvent("multihelptext", menu.onShowHelpMulti)
			menu.cleanup()
		end
	end
end

function menu.upgradeQueueVersion()
	local oldversion = __CORE_HELPTEXT_QUEUE.version

	if oldversion < 2 then
		for _, entry in ipairs(__CORE_HELPTEXT_QUEUE) do
			entry.whitelist = {}
		end
	end

	__CORE_HELPTEXT_QUEUE.version = config.queueversion
end

function menu.cleanup()
	if menu.hashotkey then
		menu.hashotkey = nil
		UnregisterAddonBindings("ego_helptext", "helptext")
	end
	if menu.hasmultihotkey then
		menu.hasmultihotkey = nil
		UnregisterAddonBindings("ego_helptext", "helptext_multi")
	end
	if menu.frame then
		View.unregisterMenu("helptext")
	end
	menu.table = nil
	menu.frame = nil
	menu.duration = nil
	menu.allowpause = nil
	menu.multiIdx = nil
end

function menu.onShowHelp(event, params)
	local textid, force, writelog, silent, allowpause, duration, position, widthfactor, allowclose, rawhalign, rawwhitelist, text = string.match(params, "(%d+);(%d+);(%d+);(%d+);(%d+);([0-9%-.]+);(%d+);([0-9.]+);(%d+);(%a+);([%a ]*);(.+)")
	textid = tonumber(textid)
	force = tonumber(force) == 1
	writelog = tonumber(writelog) == 1
	silent = tonumber(silent) == 1
	allowpause = tonumber(allowpause) == 1
	duration = tonumber(duration)
	position = tonumber(position)
	allowclose = tonumber(allowclose) == 1

	if force or not __CORE_HELPTEXT_DISPLAYEDHINTS[textid] then
		if textid ~= 0 then
			__CORE_HELPTEXT_DISPLAYEDHINTS[textid] = true
		end

		local width = menu.scaleX(config.width - config.tableoffsetx) * (C.IsVRMode() and 2 or 1)
		width = math.min(Helper.viewWidth - 3 * Helper.borderSize, width * widthfactor)

		local lines = GetTextLines(text, config.font, menu.scaleFont(config.font, config.fontsize), width - 2 * menu.scaleX(config.textoffsetx))
		local maxwidth = 0
		for _, line in ipairs(lines) do
			maxwidth = math.max(maxwidth, C.GetTextWidth(line, config.font, menu.scaleFont(config.font, config.fontsize)))
		end
		if maxwidth == 0 then
			DebugError("The calculated width of the requested hint '" .. textid .. "' is 0. Received text: '" .. text .. "'")
		end
		maxwidth = maxwidth + 2 * menu.scaleX(config.textoffsetx)

		local halign = "left"
		if rawhalign == "center" then
			halign = "center"
		elseif rawhalign == "right" then
			halign = "right"
		end

		local whitelist = {}
		for menu in string.gmatch(rawwhitelist, "%a+") do
			whitelist[menu] = true
		end

		table.insert(__CORE_HELPTEXT_QUEUE, { text = text, textid = textid, duration = duration, position = position, silent = silent, allowpause = allowpause, widthfactor = widthfactor, allowclose = allowclose, width = maxwidth, halign = halign, whitelist = whitelist })
		if not menu.duration then
			menu.displayHelp()
		end
		if writelog then
			AddLogbookEntry("tips", text, nil, nil, ReadText(1001, 5713))
		end
	end
end

function menu.onShowHelpMulti(event, params)
	local rawtextids, force, writelogs, silent, position, widthfactor, allowclose, rawhalign, rawwhitelist, rawtexts = string.match(params, "{(.+)};(%d+);{(.+)};(%d+);(%d+);([0-9.]+);(%d+);(%a+);([%a ]*);{(.+)}")
	force = tonumber(force) == 1
	silent = tonumber(silent) == 1
	position = tonumber(position)
	allowclose = tonumber(allowclose) == 1

	local textids = {}
	for id in string.gmatch(rawtextids, "([^;]+)") do
		table.insert(textids, id)
	end
	local texts = {}
	for text in string.gmatch(rawtexts, "([^;]+)") do
		text = string.gsub(text, "\\x7D", "}")
		text = string.gsub(text, "\\x3B", ";")
		text = string.gsub(text, "\\\\", "\\")
		table.insert(texts, text)
	end
	local logs = {}
	for writelog in string.gmatch(writelogs, "([^;]+)") do
		table.insert(logs, tonumber(writelog) == 1)
	end
	
	local width = menu.scaleX(config.width - config.tableoffsetx) * (C.IsVRMode() and 2 or 1)
	width = math.min(Helper.viewWidth - 3 * Helper.borderSize, width * widthfactor)

	local maxwidth = 0
	for _, text in ipairs(texts) do
		local lines = GetTextLines(text, config.font, menu.scaleFont(config.font, config.fontsize), width - 2 * menu.scaleX(config.textoffsetx))
		for _, line in ipairs(lines) do
			maxwidth = math.max(maxwidth, C.GetTextWidth(line, config.font, menu.scaleFont(config.font, config.fontsize)))
		end
	end
	if maxwidth == 0 then
		DebugError("The calculated width of the requested multi hint '" .. textids[1] .. "' is 0.")
	end
	maxwidth = math.max(maxwidth, 3 * (menu.scaleY(config.buttonHeight) + Helper.borderSize)) + 2 * menu.scaleX(config.textoffsetx)

	local firstID = textids[1]
	if force or (not __CORE_HELPTEXT_DISPLAYEDHINTS[firstID]) then
		__CORE_HELPTEXT_DISPLAYEDHINTS[firstID] = true

		local halign = "left"
		if rawhalign == "center" then
			halign = "center"
		elseif rawhalign == "right" then
			halign = "right"
		end

		local whitelist = {}
		for menu in string.gmatch(rawwhitelist, "%a+") do
			whitelist[menu] = true
		end

		table.insert(__CORE_HELPTEXT_QUEUE, { texts = texts, textids = textids, position = position, silent = silent, widthfactor = widthfactor, allowclose = allowclose, width = maxwidth, halign = halign, whitelist = whitelist })
		if not menu.duration then
			menu.displayHelp()
		end
		local logtext = ""
		for i, text in ipairs(texts) do
			if logs[i] then
				logtext = logtext .. ((logtext ~= "") and "\n" or "") .. text
			end
		end
		if logtext ~= "" then
			AddLogbookEntry("tips", logtext, nil, nil, ReadText(1001, 5713))
		end
	end
end

function menu.onClearHelp(event, id)
	AddUITriggeredEvent("hintcleared", id)
	if __CORE_HELPTEXT_QUEUE[1] then
		if id == "current" then
			table.remove(__CORE_HELPTEXT_QUEUE, 1)
		elseif id == "all" then
			__CORE_HELPTEXT_QUEUE = {
				version = __CORE_HELPTEXT_QUEUE.version
			}
		else
			local textid = tonumber(id)
			if textid > 0 then
				local idx = 0
				for i, entry in ipairs(__CORE_HELPTEXT_QUEUE) do
					if entry.textid == textid then
						idx = i
						break
					end
				end
				if idx > 0 then
					table.remove(__CORE_HELPTEXT_QUEUE, idx)
				end
				if idx ~= 1 then
					return
				end
			end
		end
		RemoveScript("onUpdate", menu.onUpdate)
		if __CORE_HELPTEXT_QUEUE[1] then
			-- display next hint
			menu.duration = nil
			menu.displayHelp()
		else
			-- clean up
			menu.cleanup()
		end
	end
end

function menu.displayHelp()
	local realtime = GetCurRealTime()
	menu.lastupdate = realtime
	local width = menu.scaleX(config.width - config.tableoffsetx) * (C.IsVRMode() and 2 or 1)
	local colwidth = width
	local height = menu.scaleY(config.height - config.tableoffsety)
	local buttonheight = menu.scaleY(config.buttonHeight)

	menu.descriptors = {}
	
	local content = {}
	local hintheight = 0
	local fullHeight = 0
	local hintcontent = {}
	local hinttaborder = 0
	local hintcolumns = {}
	local hintselectedcolumn

	local currentqueueitem = __CORE_HELPTEXT_QUEUE[1]
	if currentqueueitem then
		local hasclosebutton = (currentqueueitem.text ~= nil) and currentqueueitem.allowclose

		width = currentqueueitem.width
		colwidth = width + 2 * Helper.standardButtons_Size
		local textoffsetx = Helper.standardButtons_Size
		local textoffsety = Helper.standardButtons_Size
		hintcolumns = { colwidth }

		-- hint found
		if (not currentqueueitem.silent) and (not menu.duration) then
			PlaySound("notification_hint")
		end

		if currentqueueitem.text then
			-- adding the text offset here for additional space at the lower end
			hintheight = math.ceil(C.GetTextHeight(currentqueueitem.text, config.font, menu.scaleFont(config.font, config.fontsize), width - menu.scaleX(config.textoffsetx))) + textoffsety
			local textdescriptor = {
				text = currentqueueitem.text,
				alignment = currentqueueitem.halign,
				color = Color["text_normal"],
				fontname = config.font,
				fontsize = menu.scaleFont(config.font, config.fontsize),
				wordwrap = true,
				offset = { x = textoffsetx, y = textoffsety },
				size = { width = width - menu.scaleX(config.textoffsetx), height = hintheight },
				glowfactor = Color["text_normal"].glow,
			}
			local hintstring = CreateFontString(textdescriptor)

			table.insert(menu.descriptors, hintstring)
			hintcontent = { [1] = { color = Color["frame_background_black"], selectable = false, cols = { [1] = { colspan = 1, content = hintstring } } } }
			menu.duration = menu.duration or ((currentqueueitem.duration > 0) and (realtime + currentqueueitem.duration) or -1)
			fullHeight = hintheight + textoffsety
		else
			if not menu.multiIdx then
				menu.multiIdx = 1
			end
			if menu.multiIdx == 1 then
				hintselectedcolumn = 4
			else
				hintselectedcolumn = menu.setcol
			end
			-- no additional space at the lower end required here (because of the buttons)
			hintheight = math.ceil(C.GetTextHeight(currentqueueitem.texts[menu.multiIdx], config.font, menu.scaleFont(config.font, config.fontsize), width - menu.scaleX(config.textoffsetx)))
			local textdescriptor = {
				text = currentqueueitem.texts[menu.multiIdx],
				alignment = currentqueueitem.halign,
				color = Color["text_normal"],
				fontname = config.font,
				fontsize = menu.scaleFont(config.font, config.fontsize),
				wordwrap = true,
				offset = { x = textoffsetx, y = textoffsety },
				size = { width = width - menu.scaleX(config.textoffsetx), height = hintheight },
				glowfactor = Color["text_normal"].glow,
			}
			local hintstring = CreateFontString(textdescriptor)

			table.insert(menu.descriptors, hintstring)
			local closebutton = CreateButton({ icon = { iconID = "widget_cross_01", color = Color["icon_normal"] }, color = Color["button_background_default"], size = { height = buttonheight, width = width } })
			table.insert(menu.descriptors, closebutton)
			if currentqueueitem.allowclose then
				menu.buttonScript1 = function () return menu.clearHelp((menu.multiIdx == #currentqueueitem.texts) and "finished" or "playerclosed") end
			end
			local prevbutton = CreateButton({ icon = { iconID = "widget_arrow_left_01", color = Color["icon_normal"], glowfactor = Color["icon_normal"].glow }, color = Color["button_background_default"], size = { height = buttonheight, width = width }, active = menu.multiIdx > 1, mouseovertext = Helper.getInputMouseOverText("INPUT_ACTION_ADDON_HELPTEXT_LEFT") })
			table.insert(menu.descriptors, prevbutton)
			menu.buttonScript2 = menu.prevHelp
			local nextbutton = CreateButton({ icon = { iconID = (menu.multiIdx < #currentqueueitem.texts) and "widget_arrow_right_01" or "widget_tick_01", color = Color["icon_normal"], glowfactor = Color["icon_normal"].glow }, color = Color["button_background_default"], size = { height = buttonheight, width = width }, mouseovertext = Helper.getInputMouseOverText("INPUT_ACTION_ADDON_HELPTEXT_RIGHT") })
			table.insert(menu.descriptors, nextbutton)
			if menu.multiIdx < #currentqueueitem.texts then
				menu.buttonScript3 = menu.nextHelp
			else
				menu.buttonScript3 = function () return menu.clearHelp("finished") end
			end
			local emptytextdescriptor = {
				text = "",
				alignment = "left",
				color = Color["text_normal"],
				fontname = config.font,
				fontsize = 1,
				wordwrap = false,
				offset = { x = 0, y = 0 },
				size = { width = 0, height = buttonheight },
			}
			local emptystring = CreateFontString(emptytextdescriptor)
			table.insert(menu.descriptors, emptystring)
			hintcontent = {
				[1] = { color = Color["frame_background_black"], selectable = false, borderbelow = false, cols = {
					[1] = { colspan = 4, content = hintstring },
					[2] = { colspan = 0 },
					[3] = { colspan = 0 },
					[4] = { colspan = 0 },
				}},
			}
			if currentqueueitem.allowclose then
				hintcontent[2] = { color = Color["frame_background_black"], selectable = true, cols = {
					[1] = { colspan = 1, bgcolspan = 4, content = emptystring },
					[2] = { colspan = 1, bgcolspan = 0, content = closebutton },
					[3] = { colspan = 1, bgcolspan = 0, content = prevbutton },
					[4] = { colspan = 1, bgcolspan = 0, content = nextbutton },
				}}
			else
				hintcontent[2] = { color = Color["frame_background_black"], selectable = true, cols = {
					[1] = { colspan = 2, bgcolspan = 4, content = emptystring },
					[2] = { colspan = 0, bgcolspan = 0 },
					[3] = { colspan = 1, bgcolspan = 0, content = prevbutton },
					[4] = { colspan = 1, bgcolspan = 0, content = nextbutton },
				}}
			end
			menu.duration = -1
			hinttaborder = 1
			hintcolumns = { colwidth - 3 * (buttonheight + Helper.borderSize), buttonheight, buttonheight, buttonheight }
			fullHeight = hintheight + textoffsety + buttonheight
		end
		menu.allowpause = currentqueueitem.allowpause
		menu.whitelist = currentqueueitem.whitelist
	end
	
	local frame1desc
	if menu.duration then
		-- get position data
		local position_x, position_y = GetHintPosition(currentqueueitem.position)
		local offsetx = math.min(math.max(0, position_x / 100 * Helper.viewWidth - colwidth / 2), Helper.viewWidth - colwidth) - config.borderWidth
		local offsety = position_y / 100 * Helper.viewHeight - fullHeight / 2 - config.borderWidth
		local desc = CreateTable("", hintcontent, hintcolumns, false, true, hinttaborder, false, false, #hintcontent, config.borderWidth, config.borderWidth, fullHeight, { selectedcol = hintselectedcolumn })
		frame1desc = CreateFrame2({
			offset = {
				x = offsetx,
				y = offsety,
			},
			size = {
				width = colwidth + 2 * config.borderWidth,
				height = fullHeight + 2 * config.borderWidth,
			},
			contentdescriptors = { desc },
			layer = config.layer,
			background = {
				icon = "tut_gradient_hint_01",
				color = Color["hint_background_orange"],
				rotation = {
					rate = 360,
					start = 135,
					duration = 1,
					interval = 10,
				},
				initScale = {
					factor = (currentqueueitem.text or (menu.multiIdx == 1)) and 3 or 1,
					duration = 0.5,
				},
			},
			background2 = {
				icon = "solid",
				color = Color["hint_background2_black"],
				size = {
					width = colwidth,
					height = fullHeight,
				},
				initScale = {
					factor = (currentqueueitem.text or (menu.multiIdx == 1)) and 3 or 1,
					duration = 0.5,
				},
			},
			standardButtons = { close = (currentqueueitem.text ~= nil) and currentqueueitem.allowclose },
			standardButtonOffset = { x = currentqueueitem.text and config.borderWidth or 3 * config.borderWidth, y = config.borderWidth },
		})
	end

	if C.IsPlayerValid() and menu.duration then
		local curtime = getElapsedTime()
		if (not menu.locked) or (menu.locked < curtime) then
			menu.locked = curtime
			View.registerMenu("helptext", "helptext", menu.viewCreated, menu.cleanup, {[config.layer] = frame1desc}, false, false, true, true, hinttaborder == 0, false, false)
			if currentqueueitem.allowclose then
				if not menu.hashotkey then
					menu.hashotkey = true
					RegisterAddonBindings("ego_helptext", "helptext")
				end
			else
				if menu.hashotkey then
					menu.hashotkey = nil
					UnregisterAddonBindings("ego_helptext", "helptext")
				end
			end
			if currentqueueitem.text then
				if menu.hasmultihotkey then
					menu.hasmultihotkey = nil
					UnregisterAddonBindings("ego_helptext", "helptext_multi")
				end
			else
				if not menu.hasmultihotkey then
					menu.hasmultihotkey = true
					RegisterAddonBindings("ego_helptext", "helptext_multi")
				end
			end
		else
			menu.processnext = true
		end
		SetScript("onUpdate", menu.onUpdate)
	else
		menu.cleanup()
	end
end

function menu.viewCreated(frames)
	if frames[1] then
		menu.frame = frames[1]
		menu.table = GetChildren(frames[1])

		-- scripts
		if __CORE_HELPTEXT_QUEUE[1].allowclose then
			Helper.setMenuScript(menu, config.layer, menu.frame, "onHide", menu.onCloseElement)
		end
		if menu.buttonScript1 then
			local cell = GetCellContent(menu.table, 2, 2)
			SetScript(cell, "onClick", menu.buttonScript1)
			menu.buttonScript1 = nil
		end
		if menu.buttonScript2 then
			local cell = GetCellContent(menu.table, 2, 3)
			SetScript(cell, "onClick", menu.buttonScript2)
			menu.buttonScript2 = nil
		end
		if menu.buttonScript3 then
			local cell = GetCellContent(menu.table, 2, 4)
			SetScript(cell, "onClick", menu.buttonScript3)
			menu.buttonScript3 = nil
		end
	end

	for _, descriptor in ipairs(menu.descriptors) do
		ReleaseDescriptor(descriptor)
	end
	menu.descriptors = {}
end

function menu.onUpdate()
	local isblacklisted = false
	for _, entry in ipairs(config.blacklist) do
		if not menu.whitelist[entry] then
			if C.IsFullscreenMenuDisplayed(false, entry) then
				isblacklisted = true
				break
			end
		end
	end

	if (not menu.forceOptions) and isblacklisted then
		if menu.duration then
			menu.resume = menu.duration
			menu.cleanup()
		end
	elseif menu.resume and (not isblacklisted) then
		menu.duration = menu.resume
		menu.resume = nil
		RemoveScript("onUpdate", menu.onUpdate)
		menu.displayHelp()
	elseif (not C.IsGamePaused()) or (not menu.allowpause) then
		local realtime = GetCurRealTime()
		-- only check every second
		if menu.lastupdate + 1 < realtime then
			menu.lastupdate = realtime
			if menu.duration and (menu.duration > 0) and (menu.duration < realtime) then
				-- hint displayed, but expired
				menu.clearHelp("timeout")
				return
			end
		end
	end

	if menu.locked and (menu.locked < getElapsedTime()) then
		menu.locked = nil
	end

	if (not menu.locked) and menu.processnext then
		if C.IsPlayerValid() and menu.duration and __CORE_HELPTEXT_QUEUE[1] then
			RemoveScript("onUpdate", menu.onUpdate)
			menu.displayHelp()
		end
		menu.processnext = nil
	end
end

function menu.onCloseElement(_, dueToClose)
	if __CORE_HELPTEXT_QUEUE[1] and (dueToClose ~= "auto") then
		local reason = "playerclosed"
		if __CORE_HELPTEXT_QUEUE[1].texts and (menu.multiIdx == #__CORE_HELPTEXT_QUEUE[1].texts) then
			reason = "finished"
		end
		menu.clearHelp(reason)
	end
end

function menu.hotkey(action)
	if (action == "INPUT_ACTION_ADDON_HELPTEXT_CLOSE") or (action == "INPUT_ACTION_ADDON_HELPTEXT_BACK") then
		local reason = "playerclosed"
		if __CORE_HELPTEXT_QUEUE[1].texts and (menu.multiIdx == #__CORE_HELPTEXT_QUEUE[1].texts) then
			reason = "finished"
		end
		menu.clearHelp(reason)
	elseif action == "INPUT_ACTION_ADDON_HELPTEXT_RIGHT" then
		if menu.multiIdx < #__CORE_HELPTEXT_QUEUE[1].texts then
			menu.nextHelp()
		else
			menu.clearHelp("finished")
		end
	elseif action == "INPUT_ACTION_ADDON_HELPTEXT_LEFT" then
		menu.prevHelp()
	end
end

function menu.clearHelp(reason)
	local currentqueueitem = __CORE_HELPTEXT_QUEUE[1]
	if currentqueueitem then
		AddUITriggeredEvent("hintclosed", currentqueueitem.textid and (currentqueueitem.textid > 0 and currentqueueitem.textid or "custom") or (currentqueueitem.textids and currentqueueitem.textids[1] or "custom"), reason)
		table.remove(__CORE_HELPTEXT_QUEUE, 1)
	end
	RemoveScript("onUpdate", menu.onUpdate)
	menu.multiIdx = nil
	if __CORE_HELPTEXT_QUEUE[1] then
		-- display next hint
		menu.duration = nil
		menu.displayHelp()
	else
		-- clean up
		menu.cleanup()
	end
end

function menu.nextHelp()
	menu.multiIdx = menu.multiIdx + 1
	menu.setcol = 4
	RemoveScript("onUpdate", menu.onUpdate)
	menu.displayHelp()
end

function menu.prevHelp()
	menu.multiIdx = math.max(1, menu.multiIdx - 1)
	menu.setcol = 3
	RemoveScript("onUpdate", menu.onUpdate)
	menu.displayHelp()
end

function menu.round(x, digits)
	local mult = 1
	if digits and digits > 0 then
		mult = 10^digits
	end
	return math.floor(x * mult + 0.5) / mult
end

function menu.scaleX(x)
	return Helper.round(x * Helper.uiScale)
end

function menu.scaleY(y)
	return Helper.round(y * Helper.uiScale)
end

function menu.scaleFont(fontname, fontsize)
	fontsize = menu.scaleY(fontsize)
	return math.floor(fontsize)
end

init()
