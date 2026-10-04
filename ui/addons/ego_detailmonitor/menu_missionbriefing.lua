-- param == { 0, 0, missionID or offerID, isoffer = false }

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef uint64_t MissionID;
	typedef uint64_t UniverseID;
	typedef struct {
		const char* wareid;
		uint32_t amount;
	} UIWareAmount;

	typedef struct {
		const char* factionID;
		const char* factionName;
		const char* factionIcon;
	} FactionDetails;
	typedef struct {
		const char* text;
		const char* actiontext;
		const char* detailtext;
		int step;
		bool failed;
		bool completedoutofsequence;
	} MissionObjectiveStep3;
	typedef struct {
		const char* missionName;
		const char* missionDescription;
		int difficulty;
		int upkeepalertlevel;
		const char* threadType;
		const char* mainType;
		const char* subType;
		const char* subTypeName;
		const char* faction;
		int64_t reward;
		const char* rewardText;
		size_t numBriefingObjectives;
		int activeBriefingStep;
		const char* opposingFaction;
		const char* license;
		float timeLeft;
		double duration;
		bool abortable;
		bool hasObjective;
		UniverseID associatedComponent;
		UniverseID threadMissionID;
	} MissionDetails;
	typedef struct {
		const char* id;
		const char* name;
		bool isstory;
	} MissionGroupDetails2;
	typedef struct {
		UniverseID target;
		UIWareAmount* wares;
		uint32_t numwares;
	} MissionWareDeliveryInfo;
	typedef struct {
		const char* chapter;
		const char* onlineid;
	} OnlineMissionInfo;
	void AbortMission(MissionID missionid);
	void ClearRendertarget(const char* rendertarget);
	uint64_t GetActiveMissionID(void);
	FactionDetails GetFactionDetails(const char* factionid);
	const char* GetMissionBriefingButton(MissionID missionid);
	void GetMissionDeliveryWares(MissionWareDeliveryInfo* result, MissionID missionid);
	MissionDetails GetMissionIDDetails(uint64_t missionid);
	UniverseID GetMissionIDObjectiveTarget(uint64_t missionid, size_t targetIndex);
	MissionGroupDetails2 GetMissionGroupDetails2(MissionID missionid);
	MissionObjectiveStep3 GetMissionObjectiveStep3(uint64_t missionid, size_t objectiveIndex);
	OnlineMissionInfo GetMissionOnlineInfo(MissionID missionid);
	uint32_t GetNumMissionDeliveryWares(MissionID missionid);
	bool HasAcceptedOnlineMission(void);
	bool IsKnownToPlayer(UniverseID componentid);
	bool IsMissionLimitReached(bool includeupkeep, bool includeguidance, bool includeplot);
	bool IsNextStartAnimationSkipped(bool reset);
	void MissionBriefingInteractButtonClicked(MissionID missionid);
	bool SetActiveMission(MissionID missionid);
	void StartBriefing(MissionID missionid, const char* texturename, bool issubmission);
	void StopBriefing(MissionID missionid, bool issubmission);
]]

local menu = {
	name = "MissionBriefingMenu",
	selectedMissionDescription = {},
}

local config = {
	border = Helper.frameBorder,
	rendertargetRation = 1.3333,
	contextLayer = 2,
}

local function init()
	Menus = Menus or { }
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end
end

function menu.cleanup()
	if menu.isOffer then
		UnregisterEvent("missionofferremoved", menu.onMissionOfferRemoved)
	else
		UnregisterEvent("missionremoved", menu.onMissionRemoved)
	end

	menu.missionID = nil
	menu.isOffer = nil

	menu.missionData = {}
	menu.selectedMissionDescription = {}
	menu.submissionbriefing = nil

	menu.infoFrame = nil
	menu.objectiveTableDesc = nil
	menu.buttonTableDesc = nil

	menu.rendertarget = nil
	menu.rendertargetTexture = nil
	menu.buttontable = nil
	menu.activatecutscene = nil

	menu.contextFrame = nil
	menu.contextMenuMode = nil
	menu.contextMenuData = {}
end

function menu.buttonAccept()
	if (not menu.isOffer) and menu.selectedMissionDescription[1] then
		C.StopBriefing(ConvertStringTo64Bit(menu.selectedMissionDescription[1]), true)
	end
	C.StopBriefing(menu.missionID, false)

	if menu.missionData.onlinechapter ~= "" then
		if C.HasAcceptedOnlineMission() then
			local found = false
			local numMissions = GetNumMissions()
			for i = 1, numMissions do
				local missionid = GetMissionDetails(i)
				local onlineinfo = C.GetMissionOnlineInfo(ConvertIDTo64Bit(missionid))
				local onlinechapter, onlineid = ffi.string(onlineinfo.chapter), ffi.string(onlineinfo.onlineid)
				if onlinechapter ~= "" then
					found = true
					C.AbortMission(ConvertIDTo64Bit(missionid))
					break
				end
			end
			if not found then
				DebugError("menu.buttonAccept(): Could not find accepted online mission. Aborting.")
				return
			end
		end
	end
	SignalObject(menu.missionData.offeractor, "accept", ConvertStringToLuaID(tostring(menu.missionID)))

	Helper.closeMenu(menu, "back")
	menu.cleanup()
end

function menu.buttonDecline()
	SignalObject(menu.missionData.offeractor, "decline", ConvertStringToLuaID(tostring(menu.missionID)))
	menu.onCloseElement("back")
end

function menu.buttonActivate()
	if menu.missionData.active then
		C.SetActiveMission(0)
	else
		C.SetActiveMission(menu.missionID)
		PlaySound("ui_mission_set_active")
	end
	menu.getMissionData()
	menu.display()
end

function menu.buttonAbort(confirmed)
	if not confirmed then
		menu.contextMenuMode = "userquestion"
		local mode = "abortmission"
		if menu.missionData.missionGroup.id ~= "" then
			mode = "abortguildmission"
		end
		menu.contextMenuData = { mode = mode, xoffset = (Helper.viewWidth - Helper.scaleX(400)) / 2, yoffset = Helper.viewHeight / 2, missionid = menu.missionID, saveOption = false }

		if __CORE_DETAILMONITOR_USERQUESTION[menu.contextMenuData.mode] then
			-- continue immediately
			menu.buttonConfirmUserQuestion()
		else
			menu.createContextFrame(Helper.scaleX(400), menu.contextMenuData.xoffset, menu.contextMenuData.yoffset)
		end
	else
		C.AbortMission(menu.missionID)
		Helper.closeMenu(menu, "back")
		menu.cleanup()
	end
end

function menu.buttonSubMissionAbort()
	if not menu.isOffer and (menu.missionData.threadtype == "parallel") then
		C.AbortMission(ConvertStringTo64Bit(menu.selectedMissionDescription[1]))
		menu.getMissionData()
		menu.display()
	end
end

function menu.buttonDeliverWares()
	SignalObject(ConvertStringTo64Bit(tostring(menu.missionData.deliveryWares.target)), "ware_mission_delivery", ConvertStringToLuaID(tostring(menu.missionID)))
end

function menu.buttonInteractionButton()
	C.MissionBriefingInteractButtonClicked(menu.missionID)
end

-- Menu member functions

function menu.onShowMenu()
	menu.isOffer = (menu.param[4] and menu.param[4] ~= 0)
	if menu.isOffer then
		menu.missionID = ConvertIDTo64Bit(menu.param[3])
		RegisterEvent("missionofferremoved", menu.onMissionOfferRemoved)
	else
		menu.missionID = ConvertIDTo64Bit(menu.param[3])
		RegisterEvent("missionremoved", menu.onMissionRemoved)
	end

	menu.rendertargetData = {
		width = 0.5 * Helper.viewWidth,
		x = 0.5 * Helper.viewWidth,
		y = config.border,
	}
	local maxHeight = Helper.viewHeight - 2 * Helper.scaleY(config.border) - 10 * (Helper.scaleY(Helper.standardTextHeight) + Helper.borderSize)
	menu.rendertargetData.height = math.min(maxHeight, menu.rendertargetData.width / config.rendertargetRation)
	menu.rendertargetData.width = menu.rendertargetData.height * config.rendertargetRation
	menu.rendertargetData.x = Helper.viewWidth - menu.rendertargetData.width - Helper.frameBorder

	menu.infoData = {
		width = menu.rendertargetData.x - Helper.frameBorder - Helper.borderSize,
		x = Helper.frameBorder,
		y = config.border,
	}

	menu.objectiveData = {
		width = menu.infoData.width,
		x = Helper.frameBorder,
		y = menu.rendertargetData.height + Helper.borderSize + config.border
	}

	menu.rewardData = {
		width = menu.rendertargetData.width,
		x = menu.rendertargetData.x,
		y = menu.rendertargetData.height + Helper.borderSize + config.border
	}

	menu.getMissionData()

	menu.display()
end

function menu.onShowMenuSound()
	if not C.IsNextStartAnimationSkipped(false) then
		PlaySound("ui_mission_open")
	else
		PlaySound("ui_menu_changed")
	end
end

function menu.display()
	-- remove old data
	Helper.clearDataForRefresh(menu, menu.infoFrameLayer)

	menu.infoFrame = Helper.createFrameHandle(menu, {
		width = Helper.viewWidth,
		height = Helper.viewHeight,
		x = 0,
		y = 0,
	})
	menu.infoFrame:setBackground("solid", { color = Color["frame_background_semitransparent"] })

	menu.createRenderTarget(menu.infoFrame)

	menu.createMissionInfoSection(menu.infoFrame)

	menu.createObjectivesSection(menu.infoFrame)

	menu.createRewardSection(menu.infoFrame)

	menu.objectiveTableDesc.properties.nextTable = menu.buttonTableDesc.index
	menu.buttonTableDesc.properties.prevTable = menu.objectiveTableDesc.index

	menu.infoFrame:display()
end

function menu.createRenderTarget(frame)
	frame:addRenderTarget({width = menu.rendertargetData.width, height = menu.rendertargetData.height, x = menu.rendertargetData.x, y = menu.rendertargetData.y, scaling = false, alpha = 100})
end

function menu.createMissionInfoSection(frame)
	local firstTableHeight = menu.rendertargetData.height
	if #menu.selectedMissionDescription > 0 then
		firstTableHeight = menu.rendertargetData.height / 2
	end
	local ftable = frame:addTable(2, { tabOrder = 3, width = menu.infoData.width, x = menu.infoData.x, y = menu.infoData.y, highlightMode = "off", maxVisibleHeight = firstTableHeight })
	ftable:setDefaultColSpan(1, 2)

	local totalheight = 0
	-- title
	local row = ftable:addRow(false, { fixed = true, bgColor = Color["row_background_blue"] })
	row[1]:createText(ReadText(1001, 3400), Helper.titleTextProperties)
	-- mission name
	local row = ftable:addRow(false, { fixed = true })
	row[1]:setColSpan(1):createText(ReadText(1001, 3414) .. ReadText(1001, 120))
	row[2]:createText(menu.missionData.name, { halign = "right" })
	-- mission type
	local row = ftable:addRow(false, { fixed = true })
	row[1]:setColSpan(1):createText(ReadText(1001, 3421) .. ReadText(1001, 120))
	row[2]:createText(menu.missionData.typeName, { halign = "right" })
	-- faction
	local row = ftable:addRow(false, { fixed = true })
	row[1]:setColSpan(1):createText(ReadText(1001, 3415) .. ReadText(1001, 120))
	row[2]:createText(menu.missionData.factionName, { halign = "right" })
	-- opposing faction
	if menu.missionData.oppFactionName then
		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(1):createText(ReadText(1001, 3411) .. ReadText(1001, 120))
		row[2]:createText(menu.missionData.oppFactionName, { halign = "right" })
	end
	-- difficulty
	if (menu.missionData.maintype ~= "upkeep") and (menu.missionData.maintype ~= "guidance") and (menu.missionData.difficulty ~= 0) then
		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(1):createText(ReadText(1001, 3403) .. ReadText(1001, 120))
		local difficulty, mouseovertext = ConvertMissionLevelString(menu.missionData.difficulty)
		row[2]:createText(difficulty, { halign = "right", mouseOverText = mouseovertext })
	end
	-- time left
	local row = ftable:addRow(false, { fixed = true })
	row[1]:setColSpan(1):createText(ReadText(1001, 3404) .. ReadText(1001, 120))
	row[2]:createText(menu.getMissionContextTime, { halign = "right" })

	-- description
	local row = ftable:addRow(false, { fixed = true, bgColor = Color["row_background_blue"] })
	row[1]:createText(ReadText(1001, 2404), Helper.headerRow1Properties)

	local width = menu.infoData.width - Helper.scaleX(2 * Helper.standardTextOffsetx)
	local description = GetTextLines(menu.missionData.rawdescription, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), width)
	if #description * (Helper.scaleY(Helper.standardTextHeight) + Helper.borderSize) > (firstTableHeight - ftable:getFullHeight()) then
		description = GetTextLines(menu.missionData.rawdescription, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), width - Helper.scrollbarWidth)
	end

	for _, line in ipairs(description) do
		local row = ftable:addRow(true, {  })
		row[1]:createText(line)
	end

	-- submission description
	if #menu.selectedMissionDescription > 0 then
		local ftable2 = frame:addTable(1, { tabOrder = 5, width = menu.infoData.width, x = menu.infoData.x, y = menu.infoData.y + menu.rendertargetData.height / 2 + Helper.borderSize, highlightMode = "off", maxVisibleHeight = menu.rendertargetData.height / 2 - Helper.borderSize })
		
		local row = ftable2:addRow(false, { fixed = true, bgColor = Color["row_background_blue"] })
		row[1]:createText("", { fontsize = 2, minRowHeight = 1 })

		local width = menu.infoData.width - Helper.scaleX(2 * Helper.standardTextOffsetx)
		local description = GetTextLines(menu.selectedMissionDescription[2] or "", Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), width)
		if #description * (Helper.scaleY(Helper.standardTextHeight) + Helper.borderSize) > (menu.rendertargetData.height / 2 - ftable2:getFullHeight()) then
			description = GetTextLines(menu.selectedMissionDescription[2], Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), width - Helper.scrollbarWidth)
		end

		for _, line in ipairs(description) do
			local row = ftable2:addRow(true, {  })
			row[1]:createText(line)
		end
	end
end

function menu.buttonEncyclopediaLink(briefingobjective)
	if (not menu.isOffer) and menu.selectedMissionDescription[1] then
		C.StopBriefing(ConvertStringTo64Bit(menu.selectedMissionDescription[1]), true)
	end
	C.StopBriefing(menu.missionID, false)

	Helper.closeMenuAndOpenNewMenu(menu, "EncyclopediaMenu", { 0, 0, briefingobjective.encyclopedia.mode, briefingobjective.encyclopedia.library, briefingobjective.encyclopedia.id, briefingobjective.encyclopedia.object })
	menu.cleanup()
end

function menu.createObjectivesSection(frame)
	local ftable = frame:addTable(3, { tabOrder = 1, width = menu.objectiveData.width, x = menu.objectiveData.x, y = menu.objectiveData.y })
	menu.objectiveTableDesc = ftable
	ftable:setColWidthPercent(2, 10)
	ftable:setColWidth(3, Helper.standardTextHeight)
	ftable:setDefaultColSpan(1, 3)
	ftable:setDefaultBackgroundColSpan(1, 3)

	if menu.missionData.threadtype ~= "" then
		-- title
		local row = ftable:addRow(false, { fixed = true, bgColor = Color["row_background_blue"] })
		row[1]:createText(ReadText(1001, 3419), Helper.headerRow1Properties)

		if menu.isOffer then
			if #menu.missionData.briefingmissions > 0 then
				for i, details in ipairs(menu.missionData.briefingmissions) do
					local row = ftable:addRow({ i, details.description, nil, {details.rewardmoney, details.rewardtext} }, { bgColor = Color["row_background_blue"] })
					row[1]:setColSpan(1):createText(((menu.missionData.threadtype == "sequential") and (i .. ReadText(1001, 120)) or "·") .. " " .. details.name)
					local timeouttext = ((details.duration and (details.duration > 0)) and ConvertTimeString(details.duration, (details.duration >= 3600) and "%h:%M:%S" or "%M:%S") or "")
					row[2]:setColSpan(2):createText(timeouttext .. "  \27[missiontype_" .. details.type .. "]", { halign = "right" })

					if #details.objectives > 0 then
						for i, briefingobjective in ipairs(details.objectives) do
							local infotext = ""
							local textProperties = {}
							if i < details.activeobjective then
								infotext = " - " .. (briefingobjective.failed and ReadText(1001, 3422) or ReadText(1001, 3416))
								textProperties.color = Color["text_inactive"]
							elseif i == details.activeobjective then
								-- nothing to do
							else
								if briefingobjective.completedoutofsequence then
									infotext = " - " .. ReadText(1001, 3416)
									textProperties.color = Color["text_inactive"]
								end
							end
							local row = ftable:addRow({ i, details.description, nil, {details.rewardmoney, details.rewardtext} }, { bgColor = Color["row_background_blue"] })
							row[1]:setColSpan(briefingobjective.encyclopedia and 2 or 3):createText("   " .. briefingobjective.step .. ReadText(1001, 120) .. " " .. briefingobjective.text .. infotext, textProperties)
							if briefingobjective.encyclopedia then
								row[3]:createButton({ active = briefingobjective.encyclopedia.known, height = Helper.standardTextHeight, width = Helper.standardTextHeight, mouseOverText = briefingobjective.encyclopedia.known and ReadText(1001, 2416) or ReadText(1026, 3259) }):setIcon("mm_externallink")
								row[3].handlers.onClick = function () return menu.buttonEncyclopediaLink(briefingobjective) end
							end
						end
					end
				end
			else
				local row = ftable:addRow(true, {  })
				row[1]:createText("--- " .. ReadText(1001, 3410) .. " ---")
			end
		else
			if #menu.missionData.subMissions > 0 then
				for i, submissionEntry in ipairs(menu.missionData.subMissions) do
					local textProperties = {}
					if submissionEntry.active then
						textProperties.color = Color["text_mission"]
					end
					local row = ftable:addRow({ submissionEntry.ID, submissionEntry.rawdescription, submissionEntry.abortable, {submissionEntry.rewardmoney, submissionEntry.rewardtext} }, { bgColor = Color["row_background_blue"] })
					row[1]:setColSpan(1):createText(((menu.missionData.threadtype == "sequential") and (i .. ReadText(1001, 120)) or "·") .. " " .. submissionEntry.name, textProperties)
					row[2]:setColSpan(2):createText(function () return menu.submissionTimer(submissionEntry) end, { halign = "right" })
					
					if #submissionEntry.briefingobjectives > 0 then
						for i, briefingobjective in ipairs(submissionEntry.briefingobjectives) do
							local infotext = ""
							local textProperties = {}
							if i < submissionEntry.activebriefingstep then
								infotext = " - " .. (briefingobjective.failed and ReadText(1001, 3422) or ReadText(1001, 3416))
								textProperties.color = Color["text_inactive"]
							elseif i == submissionEntry.activebriefingstep then
								if submissionEntry.active then
									textProperties.color = Color["text_mission"]
								end
							else
								if briefingobjective.completedoutofsequence then
									infotext = " - " .. ReadText(1001, 3416)
									textProperties.color = Color["text_inactive"]
								end
							end
							local row = ftable:addRow({ submissionEntry.ID, submissionEntry.rawdescription, submissionEntry.abortable, {submissionEntry.rewardmoney, submissionEntry.rewardtext} }, { bgColor = Color["row_background_blue"] })
							row[1]:setColSpan(briefingobjective.encyclopedia and 2 or 3):createText("   " .. briefingobjective.step .. ReadText(1001, 120) .. " " .. briefingobjective.text .. infotext, textProperties)
							if briefingobjective.encyclopedia then
								row[3]:createButton({ active = briefingobjective.encyclopedia.known, height = Helper.standardTextHeight, width = Helper.standardTextHeight, mouseOverText = briefingobjective.encyclopedia.known and ReadText(1001, 2416) or ReadText(1026, 3259) }):setIcon("mm_externallink")
								row[3].handlers.onClick = function () return menu.buttonEncyclopediaLink(briefingobjective) end
							end
						end
					end
				end
			else
				local row = ftable:addRow(true, {  })
				row[1]:createText("--- " .. ReadText(1001, 3410) .. " ---")
			end
		end
	else
		local row = ftable:addRow(false, { fixed = true, bgColor = Color["row_background_blue"] })
		row[1]:createText(ReadText(1001, 3402), Helper.headerRow1Properties)

		if #menu.missionData.briefingobjectives > 0 then
			for i, briefingobjective in ipairs(menu.missionData.briefingobjectives) do
				local infotext = ""
				local textProperties = {}
				if i < menu.missionData.activebriefingstep then
					infotext = " - " .. (briefingobjective.failed and ReadText(1001, 3422) or ReadText(1001, 3416))
					textProperties.color = Color["text_inactive"]
				elseif i == menu.missionData.activebriefingstep then
					if (not menu.isOffer) and (menu.missionID == C.GetActiveMissionID()) then
						textProperties.color = Color["text_mission"]
					end
				else
					if briefingobjective.completedoutofsequence then
						infotext = " - " .. ReadText(1001, 3416)
						textProperties.color = Color["text_inactive"]
					end
				end
				local row = ftable:addRow(true, { bgColor = Color["row_background_blue"] })
				row[1]:setColSpan(briefingobjective.encyclopedia and 2 or 3):createText(briefingobjective.step .. ReadText(1001, 120) .. " " .. briefingobjective.text .. infotext, textProperties)
				if briefingobjective.encyclopedia then
					row[3]:createButton({ active = briefingobjective.encyclopedia.known, height = Helper.standardTextHeight, width = Helper.standardTextHeight, mouseOverText = briefingobjective.encyclopedia.known and ReadText(1001, 2416) or ReadText(1026, 3259) }):setIcon("mm_externallink")
					row[3].handlers.onClick = function () return menu.buttonEncyclopediaLink(briefingobjective) end
				end
			end
		else
			local row = ftable:addRow(true, { bgColor = Color["row_background_blue"] })
			row[1]:createText("--- " .. ReadText(1001, 3410) .. " ---")
		end
	end

	ftable:setTopRow(menu.toprow)
	ftable:setSelectedRow(menu.setrow)
	menu.setrow = nil
end

function menu.createRewardSection(frame)
	-- buttons
	local buttontable = frame:addTable(4, { tabOrder = 2, width = menu.rewardData.width, x = menu.rewardData.x, borderEnabled = false })
	menu.buttonTableDesc = buttontable

	local hasinteractionbutton = menu.missionData.briefingbuttontext ~= ""
	local hasdeliverywares = menu.missionData.deliveryWares and (#menu.missionData.deliveryWares > 0)

	local row2
	if (menu.missionData.threadtype == "parallel") and ((hasinteractionbutton) or (hasdeliverywares)) or ((hasinteractionbutton) and (hasdeliverywares)) then
		row2 = buttontable:addRow(true, { fixed = true, bgColor = Color["row_background_blue"] })
	end

	local row = buttontable:addRow(true, { fixed = true, bgColor = Color["row_background_blue"] })
	if menu.isOffer then
		-- empty

		-- interaction button
		if hasinteractionbutton then
			row[2]:createButton({  }):setText(menu.missionData.briefingbuttontext, { halign = "center" })
			row[2].handlers.onClick = menu.buttonInteractionButton
		end
		-- accept
		local active = true
		local mouseovertext
		if C.IsMissionLimitReached(false, false, false) then
			active = false
			mouseovertext = ReadText(1026, 3242)
		elseif menu.missionData.onlinechapter ~= "" then
			if C.HasAcceptedOnlineMission() then
				mouseovertext = ColorText["text_negative"] .. ReadText(1026, 11301)
			end
		end
		row[3]:createButton({ active = active, mouseOverText = mouseovertext }):setText(ReadText(1001, 57), { halign = "center" })
		row[3].handlers.onClick = menu.buttonAccept
		-- decline
		row[4]:createButton({  }):setText(ReadText(1001, 58), { halign = "center" })
		row[4].handlers.onClick = menu.buttonDecline
	else
		if menu.missionData.threadtype == "parallel" then
			-- interaction button
			if hasinteractionbutton then
				row2[4]:createButton({  }):setText(menu.missionData.briefingbuttontext, { halign = "center" })
				row2[4].handlers.onClick = menu.buttonInteractionButton
			end
			-- deliver wares
			if hasdeliverywares then
				local col
				if hasinteractionbutton then
					col = row2[3]
				else
					col = row2[4]
				end
				col:createButton({ active = menu.checkDeliverWaresCargo, mouseOverText = function () return menu.checkDeliverWaresCargo() and "" or (ColorText["text_error"] .. ReadText(1026, 3406)) end }):setText(ReadText(1001, 3423), { halign = "center" })
				col.handlers.onClick = menu.buttonDeliverWares
			end
			if menu.missionData.maintype ~= "guidance" then
				-- set to active
				local activeMissionID = C.GetActiveMissionID()
				row[1]:createButton({  }):setText(menu.missionData.active and ReadText(1001, 3413) or ReadText(1001, 3406), { halign = "center" })
				row[1].handlers.onClick = menu.buttonActivate
			end
			-- abort submission
			row[2]:createButton({ active = menu.selectedMissionDescription[3] }):setText(ReadText(1001, 3420), { halign = "center" })
			row[2].handlers.onClick = menu.buttonSubMissionAbort
			-- abort
			row[3]:createButton({ active = menu.missionData.abortable }):setText(ReadText(1001, 3407), { halign = "center" })
			row[3].handlers.onClick = function () return menu.buttonAbort() end
			-- close
			row[4]:createButton({  }):setText(ReadText(1001, 3417), { halign = "center" })
			row[4].handlers.onClick = function () return menu.onCloseElement("back") end
		else
			-- interaction button
			if hasinteractionbutton then
				local col
				if hasdeliverywares then
					col = row2[4]
				else
					col = row[1]
				end
				col:createButton({  }):setText(menu.missionData.briefingbuttontext, { halign = "center" })
				col.handlers.onClick = menu.buttonInteractionButton
			end
			-- deliver wares
			if hasdeliverywares then
				local col
				if hasinteractionbutton then
					col = row2[3]
				else
					col = row[1]
				end
				col:createButton({ active = menu.checkDeliverWaresCargo, mouseOverText = function () return menu.checkDeliverWaresCargo() and "" or (ColorText["text_error"] .. ReadText(1026, 3406)) end }):setText(ReadText(1001, 3423), { halign = "center" })
				col.handlers.onClick = menu.buttonDeliverWares
			end
			if menu.missionData.maintype ~= "guidance" then
				-- set to active
				local activeMissionID = C.GetActiveMissionID()
				row[2]:createButton({  }):setText(menu.missionData.active and ReadText(1001, 3413) or ReadText(1001, 3406), { halign = "center" })
				row[2].handlers.onClick = menu.buttonActivate
			end
			-- abort
			row[3]:createButton({ active = menu.missionData.abortable }):setText(ReadText(1001, 3407), { halign = "center" })
			row[3].handlers.onClick = function () return menu.buttonAbort() end
			-- close
			row[4]:createButton({  }):setText(ReadText(1001, 3417), { halign = "center" })
			row[4].handlers.onClick = function () return menu.onCloseElement("back") end
		end
	end

	buttontable.properties.y = Helper.viewHeight - buttontable:getFullHeight() - Helper.frameBorder

	-- reward
	local ftable = frame:addTable(2, { tabOrder = 4, width = menu.rewardData.width, x = menu.rewardData.x, y = menu.rewardData.y, highlightMode = "off", maxVisibleHeight = Helper.viewHeight - menu.rewardData.y - buttontable.properties.y - Helper.borderSize })
	ftable:setDefaultColSpan(1, 2)

	-- rendertarget line (done here to save a whole table just for that)
	local objective = menu.missionData.briefingobjectives[menu.missionData.activebriefingstep]
	if objective then
		local row = ftable:addRow(false, { fixed = true })
		row[1]:createText(objective.step .. ReadText(1001, 120) .. " " .. objective.text, { halign = "center", font = Helper.standardFontOutlined })
		local objectivelineoffset = row:getHeight() + Helper.borderSize
		ftable.properties.y = ftable.properties.y - objectivelineoffset
		ftable.properties.maxVisibleHeight = ftable.properties.maxVisibleHeight + objectivelineoffset
	end

	local row = ftable:addRow(false, { fixed = true, bgColor = Color["row_background_blue"] })
	row[1]:createText(ReadText(1001, 3301), Helper.headerRow1Properties)

	local rewardtext
	if menu.missionData.rewardmoney ~= 0 then
		rewardtext = ConvertMoneyString(menu.missionData.rewardmoney, false, true, 0, true) .. " " .. ReadText(1001, 101)
		if menu.missionData.rewardtext ~= "" then
			rewardtext = rewardtext .. "\n" .. menu.missionData.rewardtext
		end
	else
		rewardtext = menu.missionData.rewardtext
	end

	if #menu.selectedMissionDescription > 0 then
		if rewardtext ~= "" then
			rewardtext = rewardtext .. "\n\n"
		end
		if menu.selectedMissionDescription[4][1] ~= 0 then
			rewardtext = rewardtext .. ConvertMoneyString(menu.selectedMissionDescription[4][1], false, true, 0, true) .. " " .. ReadText(1001, 101)
			if menu.selectedMissionDescription[4][2] ~= "" then
				rewardtext = rewardtext .. "\n" .. menu.selectedMissionDescription[4][2]
			end
		else
			rewardtext = rewardtext .. menu.selectedMissionDescription[4][2]
		end
	end

	local width = menu.rewardData.width - Helper.scaleX(2 * Helper.standardTextOffsetx)
	local description = GetTextLines(rewardtext, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), width)
	if #description * (Helper.scaleY(Helper.standardTextHeight) + Helper.borderSize) > (Helper.viewHeight - ftable.properties.y - ftable:getFullHeight()) then
		description = GetTextLines(rewardtext, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), width - Helper.scrollbarWidth)
	end

	for _, line in ipairs(description) do
		local row = ftable:addRow(true, {  })
		row[1]:createText(line)
	end

end

function menu.checkDeliverWaresCargo()
	local hascargo = true
	local cargo = GetComponentData(ConvertStringTo64Bit(tostring(menu.missionData.deliveryWares.target)), "cargo") or {}
	for _, entry in ipairs(menu.missionData.deliveryWares) do
		if (cargo[entry.ware] or 0) == 0 then
			hascargo = false
			break
		end
	end
	return hascargo
end

function menu.viewCreated(layer, ...)
	if #menu.selectedMissionDescription > 0 then
		menu.rendertarget, _, _, menu.objectivetable, menu.buttontable = ...
	else
		menu.rendertarget, _, menu.objectivetable, menu.buttontable = ...
	end

	if menu.activatecutscene == nil then
		menu.activatecutscene = true
	end
end

function menu.createContextFrame(width, x, y)
	PlaySound("ui_positive_click")

	menu.contextMenuData = menu.contextMenuData or {}
	if width then
		menu.contextMenuData.width = width
	end
	if height then
		menu.contextMenuData.height = height
	end
	if xoffset then
		menu.contextMenuData.xoffset = xoffset
	end
	if yoffset then
		menu.contextMenuData.yoffset = yoffset
	end

	menu.contextFrame = Helper.createFrameHandle(menu, {
		x = menu.contextMenuData.xoffset,
		y = menu.contextMenuData.yoffset,
		width = menu.contextMenuData.width,
		layer = config.contextLayer,
		standardButtons = { close = true },
	})
	menu.contextFrame:setBackground("solid", { color = Color["frame_background_semitransparent"] })

	if menu.contextMenuMode == "userquestion" then
		menu.createUserQuestionContext(menu.contextFrame)
	end

	menu.contextFrame.properties.height = math.min(Helper.viewHeight - menu.contextFrame.properties.y, menu.contextFrame:getUsedHeight() + Helper.borderSize)
	menu.contextFrame:display()
end

function menu.createUserQuestionContext(frame)
	local useSaveOption = false
	if (menu.contextMenuData.mode == "abortmission") or (menu.contextMenuData.mode == "abortguildmission") then
		useSaveOption = true
	end
	local numCols = useSaveOption and 6 or 5
	local ftable = frame:addTable(numCols, { tabOrder = 5, reserveScrollBar = false, highlightMode = "off" })
	if useSaveOption then
		ftable:setColWidth(1, Helper.scaleY(Helper.standardButtonHeight), false)
		ftable:setColWidthPercent(5, 25, false)
		ftable:setColWidthPercent(6, 25, false)
	end
	
	if menu.contextMenuData.mode == "abortmission" then
		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 3407), Helper.headerRowCenteredProperties)

		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 3426), { wordwrap = true })
	elseif menu.contextMenuData.mode == "abortguildmission" then
		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 3427), Helper.headerRowCenteredProperties)

		local row = ftable:addRow(false, { fixed = true })
		row[1]:setColSpan(numCols):createText(ReadText(1001, 3428), { wordwrap = true })
	end

	local row = ftable:addRow(false, { fixed = true })
	row[1]:setColSpan(numCols):createText("")

	if useSaveOption then
		local row = ftable:addRow(true, { fixed = true })
		row[1]:createCheckBox(function () return menu.contextMenuData.saveOption end, { height = Helper.standardButtonHeight })
		row[1].handlers.onClick = function () menu.contextMenuData.saveOption = not menu.contextMenuData.saveOption end
		row[2]:setColSpan(3):createButton({ bgColor = Color["button_background_hidden"] }):setText(ReadText(1001, 9709))
		row[2].handlers.onClick = function () menu.contextMenuData.saveOption = not menu.contextMenuData.saveOption end
		row[5]:createButton({ helpOverlayID = "custom_" .. menu.contextMenuData.mode .. "_confirm", helpOverlayText = " ", helpOverlayHighlightOnly = true }):setText(ReadText(1001, 2821), { halign = "center" })
		row[5].handlers.onClick = menu.buttonConfirmUserQuestion
		row[6]:createButton({ helpOverlayID = "custom_" .. menu.contextMenuData.mode .. "_cancel", helpOverlayText = " ", helpOverlayHighlightOnly = true }):setText(ReadText(1001, 64), { halign = "center" })
		row[6].handlers.onClick = menu.closeContextMenu
		ftable:setSelectedCol(6)
	else
		local row = ftable:addRow(true, { fixed = true })
		row[2]:createButton():setText(ReadText(1001, 2617), { halign = "center" })
		--row[2].handlers.onClick = function () return  end
		row[4]:createButton():setText(ReadText(1001, 2618), { halign = "center" })
		row[4].handlers.onClick = menu.closeContextMenu
		ftable:setSelectedCol(4)
	end
end

function menu.buttonConfirmUserQuestion()
	if menu.contextMenuData.saveOption then
		__CORE_DETAILMONITOR_USERQUESTION[menu.contextMenuData.mode] = true
	end

	if (menu.contextMenuData.mode == "abortmission") or (menu.contextMenuData.mode == "abortguildmission") then
		menu.buttonAbort(true)
	end
end

function menu.closeContextMenu()
	Helper.clearFrame(menu, config.contextLayer)
	menu.contextFrame = nil
	menu.contextMenuMode = nil
	menu.contextMenuData = {}
end

menu.updateInterval = 0.1

function menu.onUpdate()
	if menu.activatecutscene then
		menu.rendertargetTexture = GetRenderTargetTexture(menu.rendertarget)
		if menu.rendertargetTexture then
			C.ClearRendertarget(menu.rendertargetTexture)
			C.StartBriefing(menu.missionID, menu.rendertargetTexture, false)
			menu.activatecutscene = false
		end
	end

	if not menu.isOffer then
		if menu.submissionbriefing then
			if menu.activatecutscene == false then
				if menu.submissionbriefing[1] then
					C.StopBriefing(ConvertStringTo64Bit(menu.submissionbriefing[1]), true)
				end
				C.ClearRendertarget(menu.rendertargetTexture)
				C.StartBriefing(ConvertStringTo64Bit(menu.submissionbriefing[2]), menu.rendertargetTexture, true)
				menu.submissionbriefing = nil
			end
		end
	end

	menu.infoFrame:update()
	if menu.contextFrame then
		menu.contextFrame:update()
	end

	if menu.scheduleUpdate then	
		menu.scheduleUpdate = nil
		menu.display()
	end
end

function menu.onRowChanged(row, rowdata, uitable)
	if uitable == menu.objectivetable then
		if type(rowdata) == "table" then
			if menu.selectedMissionDescription[1] ~= rowdata[1] then
				if not menu.isOffer then
					if menu.activatecutscene == false then
						if menu.selectedMissionDescription[1] then
							C.StopBriefing(ConvertStringTo64Bit(menu.selectedMissionDescription[1]), true)
						end
						C.ClearRendertarget(menu.rendertargetTexture)
						C.StartBriefing(ConvertStringTo64Bit(rowdata[1]), menu.rendertargetTexture, true)
						menu.submissionbriefing = nil
					else
						menu.submissionbriefing = { menu.selectedMissionDescription[1], rowdata[1] }
					end
				end
				menu.selectedMissionDescription = rowdata
				menu.toprow = GetTopRow(menu.objectivetable)
				menu.setrow = row
				menu.scheduleUpdate = true
			end
		end
	end
end

function menu.onSelectElement()
end

function menu.onCloseElement(dueToClose, layer)
	if menu.contextMenuMode then
		menu.closeContextMenu()
		if (dueToClose == "back") or (layer == config.contextLayer) then
			return
		end
	end

	if (not menu.isOffer) and menu.selectedMissionDescription[1] then
		C.StopBriefing(ConvertStringTo64Bit(menu.selectedMissionDescription[1]), true)
	end
	C.StopBriefing(menu.missionID, false)
	Helper.closeMenu(menu, dueToClose)
	menu.cleanup()
end

function menu.getMissionData()
	if not menu.isOffer then
		menu.missionData = menu.getMissionIDInfoHelper(menu.missionID)
	else
		local name, description, difficulty, threadtype, maintype, subtype, subtypename, faction, rewardmoney, rewardtext, briefingobjectives, activebriefingstep, briefingmissions, oppfaction, licence, missiontime, duration, abortable, guidancedisabled, associatedcomponent, alertLevel, offeractor, offercomponent = GetMissionOfferDetails(ConvertStringToLuaID(tostring(menu.missionID)))
		local onlineinfo = C.GetMissionOnlineInfo(menu.missionID)
		local onlinechapter, onlineid = ffi.string(onlineinfo.chapter), ffi.string(onlineinfo.onlineid)
		menu.missionData = {
			name = name,
			rawdescription = description,
			difficulty = difficulty,
			rewardmoney = rewardmoney,
			rewardtext = rewardtext,
			briefingobjectives = briefingobjectives,
			activebriefingstep = activebriefingstep,
			briefingmissions = briefingmissions,
			timeout = duration or -1,
			offeractor = offeractor,
			subMissions = {},
			threadtype = threadtype,
			typeName = subtypename,
			maintype = maintype,
			onlinechapter = onlinechapter,
			onlineID = onlineid,
		}
		if faction then
			local factionDetails = C.GetFactionDetails(faction)
			local factionName = ffi.string(factionDetails.factionName)
			if factionName ~= "" then
				menu.missionData.factionName = factionName
			end
		end
		if oppfaction then
			local factionDetails = C.GetFactionDetails(oppfaction)
			local factionName = ffi.string(factionDetails.factionName)
			if factionName ~= "" then
				menu.missionData.oppFactionName = factionName
			end
		end
		menu.missionData.briefingbuttontext = ffi.string(C.GetMissionBriefingButton(menu.missionID))
	end
	if menu.missionData and menu.missionData.briefingobjectives then
		for i, entry in ipairs(menu.missionData.briefingobjectives) do
			local mode, object
			local library, item, item2 = GetMissionObjectiveEncyclopediaReference(menu.missionID, i)
			local known = true
			if library then
				if library == "Galaxy" then
					mode = library
					object = item
					known = C.IsKnownToPlayer(ConvertIDTo64Bit(object))
				elseif library == "Blueprints" then
					mode = library
					library = item
					item = item2

					local macro = GetWareData(item2, "component")
					local macrolibrary = GetMacroData(macro, "infolibrary")
					AddKnownItem(macrolibrary, macro)
				else
					AddKnownItem(library, item)
				end
				entry.encyclopedia = { mode = mode, library = library, id = item, object = object, known = known }
			end
		end
	end
	if menu.missionData and menu.missionData.briefingmissions then
		for i, briefingmission in ipairs(menu.missionData.briefingmissions) do
			for j, entry in ipairs(briefingmission.objectives) do
				local mode, object
				local library, item, item2 = GetMissionObjectiveEncyclopediaReference(menu.missionID, j, i)
				local known = true
				if library then
					if library == "Galaxy" then
						mode = library
						object = item
						known = C.IsKnownToPlayer(ConvertIDTo64Bit(object))
					elseif library == "Blueprints" then
						mode = library
						library = item
						item = item2

						local macro = GetWareData(item2, "component")
						local macrolibrary = GetMacroData(macro, "infolibrary")
						AddKnownItem(macrolibrary, macro)
					else
						AddKnownItem(library, item)
					end
					entry.encyclopedia = { mode = mode, library = library, id = item, object = object, known = known }
				end
			end
		end
	end
end

function menu.getMissionIDInfoHelper(missionID)
	local missionGroup = C.GetMissionGroupDetails2(missionID)
	local groupID, groupName, isStoryGroup = ffi.string(missionGroup.id), ffi.string(missionGroup.name)
	local subMissions, buf = {}, {}
	local subactive = false
	Helper.ffiVLA(buf, "MissionID", C.GetNumMissionThreadSubMissions, C.GetMissionThreadSubMissions, missionID)
	for _, submission in ipairs(buf) do
		local submissionEntry = menu.getMissionIDInfoHelper(submission)
		table.insert(subMissions, submissionEntry)
		if submissionEntry.active then
			subactive = true
		end
	end
	local missiondetails = C.GetMissionIDDetails(missionID)
	local onlineinfo = C.GetMissionOnlineInfo(missionID)
	local onlinechapter, onlineid = ffi.string(onlineinfo.chapter), ffi.string(onlineinfo.onlineid)
	local entry = {
		["active"] = (missionID == C.GetActiveMissionID()) or subactive,
		["name"] = ffi.string(missiondetails.missionName),
		["rawdescription"] = ffi.string(missiondetails.missionDescription),
		["difficulty"] = missiondetails.difficulty,
		["missionGroup"] = { id = groupID, name = groupName, isstory = isStoryGroup },
		["threadtype"] = ffi.string(missiondetails.threadType),
		["maintype"] = ffi.string(missiondetails.mainType),
		["type"] = ffi.string(missiondetails.subType),
		["typeName"] = ffi.string(missiondetails.subTypeName),
		["faction"] = ffi.string(missiondetails.faction),
		["rewardmoney"] = tonumber(missiondetails.reward) / 100,
		["rewardtext"] = ffi.string(missiondetails.rewardText),
		["timeout"] = (missiondetails.timeLeft and missiondetails.timeLeft > -1) and missiondetails.timeLeft or (missiondetails.duration or -1),
		["ID"] = tostring(missionID),
		["associatedcomponent"] = missiondetails.associatedComponent,
		["abortable"] = missiondetails.abortable,
		["threadMissionID"] = missiondetails.threadMissionID,
		["subMissions"] = subMissions,
		["onlinechapter"] = onlinechapter,
		["onlineID"] = onlineid,
	}
	entry.briefingobjectives = {}
	for i = 1, tonumber(missiondetails.numBriefingObjectives) do
		local objective = C.GetMissionObjectiveStep3(missionID, i)
		table.insert(entry.briefingobjectives, { step = objective.step, text = ffi.string(objective.text), failed = objective.failed, completedoutofsequence = objective.completedoutofsequence })
	end
	entry.activebriefingstep = missiondetails.activeBriefingStep
	entry.briefingmissions = {}
	local faction = ffi.string(missiondetails.faction)
	if faction ~= "" then
		local factionDetails = C.GetFactionDetails(faction)
		local factionName = ffi.string(factionDetails.factionName)
		if factionName ~= "" then
			entry.factionName = factionName
		end
	end
	local oppfaction = ffi.string(missiondetails.opposingFaction)
	if oppfaction ~= "" then
		local factionDetails = C.GetFactionDetails(oppfaction)
		local factionName = ffi.string(factionDetails.factionName)
		if factionName ~= "" then
			entry.oppFactionName = factionName
		end
	end

	entry.briefingbuttontext = ffi.string(C.GetMissionBriefingButton(missionID))

	entry.deliveryWares = {}
	local n = C.GetNumMissionDeliveryWares(missionID)
	if n > 0 then
		local buf = ffi.new("MissionWareDeliveryInfo[1]")
		buf[0].numwares = n
		buf[0].wares = Helper.ffiNewHelper("UIWareAmount[?]", n)
		C.GetMissionDeliveryWares(buf, missionID)
		entry.deliveryWares.target = buf[0].target
		for i = 0, buf[0].numwares - 1 do
			table.insert(entry.deliveryWares, { ware = ffi.string(buf[0].wares[i].wareid), amount = buf[0].wares[i].amount })
		end
	end

	return entry
end

function menu.onMissionOfferRemoved(event, id)
	if id == menu.missionID then
		menu.missionData.expired = true

		local desc = Helper.createButton(Helper.createTextInfo("-", "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, false, 0, 0, 0, Helper.standardButtonHeight)
		Helper.setCellContent(menu, menu.buttontable, desc, 1, 3, nil, "button")
		local desc = Helper.createButton(Helper.createTextInfo(ReadText(1001, 6402), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, false, 0, 0, 0, Helper.standardButtonHeight)
		Helper.setCellContent(menu, menu.buttontable, desc, 1, 4, nil, "button")
	end
end

function menu.onMissionRemoved(event, id)
	if id == menu.missionID then
		menu.missionData.expired = true

		local desc = Helper.createButton(Helper.createTextInfo("-", "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, false, 0, 0, 0, Helper.standardButtonHeight)
		if menu.missionData.threadtype == "parallel" then
			Helper.setCellContent(menu, menu.buttontable, desc, 1, 1, true, "button")
		end
		Helper.setCellContent(menu, menu.buttontable, desc, 1, 2, true, "button")
		Helper.setCellContent(menu, menu.buttontable, desc, 1, 3, nil, "button")
		local desc = Helper.createButton(Helper.createTextInfo(ReadText(1001, 6403), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, false, 0, 0, 0, Helper.standardButtonHeight)
		Helper.setCellContent(menu, menu.buttontable, desc, 1, 4, nil, "button")
	end
end

function menu.getMissionContextTime()
	if not menu.missionData.expired then
		if (not menu.isOffer) and menu.missionID then
			local missiondetails = C.GetMissionIDDetails(menu.missionID)
			local timeout = (missiondetails.timeLeft and missiondetails.timeLeft > -1) and missiondetails.timeLeft or (missiondetails.duration or -1)

			return (timeout > 0 and ConvertTimeString(timeout, (timeout >= 3600) and "%h:%M:%S" or "%M:%S") or "-")
		else
			return (menu.missionData.timeout > 0 and ConvertTimeString(menu.missionData.timeout, (menu.missionData.timeout >= 3600) and "%h:%M:%S" or "%M:%S") or "-")
		end
	else
		return "-"
	end
end

function menu.submissionTimer(submissionentry)
	local text
	if not submissionentry.expired then
		if not menu.isOffer then
			local missiondetails = C.GetMissionIDDetails(ConvertStringTo64Bit(submissionentry.ID))
			local timeout = (missiondetails.timeLeft and missiondetails.timeLeft > -1) and missiondetails.timeLeft or (missiondetails.duration or -1)

			text = (timeout > 0 and ConvertTimeString(timeout, (timeout >= 3600) and "%h:%M:%S" or "%M:%S") or "")
		else
			text = (submissionentry.timeout > 0 and ConvertTimeString(submissionentry.timeout, (submissionentry.timeout >= 3600) and "%h:%M:%S" or "%M:%S") or "")
		end
	else
		text = ""
	end

	return text .. "  \27[missiontype_" .. submissionentry.type .. "]"
end

init()
