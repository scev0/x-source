-- param == { 0, 0, cluster }

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
		const char* text;
		const char* actiontext;
		const char* detailtext;
		int step;
		bool failed;
		bool completedoutofsequence;
	} MissionObjectiveStep3;
	typedef struct {
		uint32_t numbuildsinprogress;
		uint32_t numbuildsinqueue;
		uint32_t numcurrentdeliveries;
	} UITerraformingDroneInfo;
	typedef struct {
		MissionID missionid;
		bool missioncompleted;
	} UITerraformingMissionInfo;
	typedef struct {
		const char* id;
		const char* group;
		const char* name;
		const char* description;
		double duration;
		double repeatcooldown;
		uint32_t timescompleted;
		int32_t successchance;
		bool resilient;
		bool showalways;
		int64_t price;
		float payoutfactor;
		const char* requiredresearchid;
		const char* pricescale;
		const char* pricescaletext;
		bool anypredecessor;
		uint32_t numpredecessors;
		uint32_t numpredecessorgroups;
		uint32_t numblockingprojects;
		uint32_t numconditions;
		uint32_t numprimaryeffects;
		uint32_t numsideeffects;
		uint32_t numblockedprojects;
		uint32_t numblockedgroups;
		uint32_t numrebates;
		uint32_t numresources;
		uint32_t numremovedprojects;
	} UITerraformingProject2;
	typedef struct {
		const char* id;
		const char* name;
		const char* description;
		const char* inactivetext;
		const char* iconid;
		bool dynamic;
		uint64_t value;
		uint32_t state;
		bool useranges;
		uint32_t numranges;
	} UITerraformingStat;
	typedef struct {
		uint64_t endvalue;
		uint32_t state;
		Color color;
		const char* description;
	} UITerraformingStatRange;
	typedef struct {
		const char* name;
		bool ismoon;
	} UITerraformingWorldInfo;
	typedef struct {
		const char* ware;
		const char* macro;
		int amount;
	} UIWareInfo;

	void AbortActiveTerraformingProject(UniverseID clusterid);
	bool CanAbortActiveTerraformingProject(UniverseID clusterid);
	bool CanStartTerraformingProject(UniverseID clusterid, const char* projectid);
	UniverseID GetContextByClass(UniverseID componentid, const char* classname, bool includeself);
	double GetCurrentGameTime();
	MissionObjectiveStep3 GetMissionObjectiveStep3(uint64_t missionid, size_t objectiveIndex);
	uint32_t GetNumTerraformingCurrentStats(UniverseID clusterid);
	uint32_t GetNumTerraformingDynamicStats();
	uint32_t GetNumTerraformingProjectGroups();
	uint32_t GetNumTerraformingProjects(UniverseID clusterid, bool useevents);
	const char* GetTerraformingActiveProject(UniverseID clusterid);
	uint32_t GetTerraformingCurrentStats(UITerraformingStat* result, uint32_t resultlen, UniverseID clusterid);
	uint32_t GetTerraformingDynamicStats(UITerraformingStat* result, uint32_t resultlen);
	UITerraformingMissionInfo GetTerraformingMissionInfo(UniverseID clusterid);
	double GetTerraformingProjectAvailabilityTime(UniverseID clusterid, const char* projectid);
	float GetTerraformingProjectCompletionFraction(UniverseID clusterid, const char* projectid);
	double GetTerraformingProjectCompletionTime(UniverseID clusterid, const char* projectid);
	uint32_t GetTerraformingProjectDeliveredResources(UIWareInfo* result, uint32_t resultlen, UniverseID clusterid, const char* projectid);
	UITerraformingDroneInfo GetTerraformingProjectDroneStatus(UniverseID clusterid, const char* projectid);
	uint32_t GetTerraformingProjectGroups(UITerraformingProjectGroup* result, uint32_t resultlen);
	uint32_t GetTerraformingProjects2(UITerraformingProject2* result, uint32_t resultlen, UniverseID clusterid, bool useevents);
	UITerraformingStat GetTerraformingStat(const char* statid);
	uint32_t GetTerraformingStatRange(UITerraformingStatRange* result, uint32_t resultlen, UniverseID clusterid, const char* statid);
	UITerraformingWorldInfo GetTerraformingWorldName(UniverseID clusterid);
	bool HasResearched(const char* wareid);
	bool HasTerraformingProjectStarted(UniverseID clusterid, const char* projectid);
	void StartTerraformingProject(UniverseID clusterid, const char* projectid);
]]

-- menu variable - used by Helper and used for dynamic variables (e.g. inventory content, etc.)
local menu = {
	name = "TerraformingMenu",
	resourcesmissing = {},
	storagemissing = {},
}

-- config variable - put all static setup here
local config = {
	mainFrameLayer = 5,
	expandedMenuFrameLayer = 4,
	nodeoffsetx = 10,
	nodewidth = 280,
}

-- init menu and register with Helper
local function init()
	Menus = Menus or { }
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end
	RegisterEvent("terraformingActiveProjectCleared", menu.onActiveProjectCleared)
end

-- cleanup variables in menu, no need for the menu variable to keep all the data while the menu is not active
function menu.cleanup()
	unregisterForEvent("inputModeChanged", getElement("Scene.UIContract"), menu.onInputModeChanged)
	menu.topLevelOffsetY = nil

	menu.restoreNodeProject = nil
	menu.restoreNode = nil

	if menu.wareReservationRegistered then
		UnregisterEvent("newWareReservation", menu.newWareReservationCallback)
		menu.wareReservationRegistered = nil
	end

	menu.flowchartRows = nil
	menu.flowchartCols = nil

	menu.expandedNode = nil
	menu.expandedMenuFrame = nil
	menu.expandedMenuTable = nil

	menu.topRows = {}
	menu.firstCols = {}
	menu.selectedRows = {}
	menu.selectedRowData = {}
	menu.selectedCols = {}

	menu.frame = nil
end

function menu.onActiveProjectCleared()
	menu.refresh = getElapsedTime()
end

-- Menu member functions

function menu.onShowMenu(state)
	Helper.setTabScrollCallback(menu, menu.onTabScroll)
	registerForEvent("inputModeChanged", getElement("Scene.UIContract"), menu.onInputModeChanged)

	menu.topRows = {}
	menu.firstCols = {}
	menu.selectedRows = {}
	menu.selectedRowData = {}
	menu.selectedCols = {}

	-- trade rules
	Helper.updateTradeRules()

	menu.cluster = ConvertStringTo64Bit(tostring(menu.param[3]))
	menu.planetname = menu.param[4]
	if menu.planetname == nil then
		local worldinfo = C.GetTerraformingWorldName(menu.cluster)
		menu.planetname = (worldinfo.ismoon and "\27[ency_moon_01]" or "\27[ency_planet_01]") .. ffi.string(worldinfo.name)
	end

	local stationhqlist = {}
	Helper.ffiVLA(stationhqlist, "UniverseID", C.GetNumHQs, C.GetHQs, "player")
	menu.hq = stationhqlist[1] or 0

	menu.hqismissing = true
	if C.GetContextByClass(menu.hq, "cluster", false) == menu.cluster then
		menu.hqismissing = false
	end

	menu.projectgroups = {}
	menu.projectgroupsbyid = {}
	local n = C.GetNumTerraformingProjectGroups()
	local buf = ffi.new("UITerraformingProjectGroup[?]", n)
	n = C.GetTerraformingProjectGroups(buf, n)
	for i = 0, n - 1 do
		local id = ffi.string(buf[i].id)
		local entry = {
			id = id,
			name = ffi.string(buf[i].name),
			projects = { numrows = 0, numcols = 0 },
		}
		table.insert(menu.projectgroups, entry)
		menu.projectgroupsbyid[id] = entry
	end

	if state or menu.state then
		menu.onRestoreState(state or menu.state)
		menu.state = nil
	end

	menu.display()
end

function menu.onSaveState()
	local state = {}

	state.flowchartTopRow, state.flowchartFirstCol = GetFlowchartFirstVisibleCell(menu.flowchart.id)
	state.flowchartSelectedRow, state.flowchartSelectedCol = GetFlowchartSelectedCell(menu.flowchart.id)

	return state
end

function menu.onRestoreState(state)
	menu.topRows.flowchart, menu.firstCols.flowchart = state.flowchartTopRow, state.flowchartFirstCol
	menu.selectedRows.flowchart, menu.selectedCols.flowchart = state.flowchartSelectedRow, state.flowchartSelectedCol
end

function menu.display()
	-- remove old data
	Helper.clearDataForRefresh(menu)

	-- Organize Visual Menu
	local width = Helper.viewWidth
	local height = Helper.viewHeight
	local xoffset = 0
	local yoffset = 0

	local numcategories = 0

	menu.frame = Helper.createFrameHandle(menu, { height = height, width = width, x = xoffset, y = yoffset, layer = config.mainFrameLayer })
	menu.frame:setBackground("solid", { color = Color["frame_background_semitransparent"] })

	menu.createTopLevel(menu.frame)

	menu.sidebarWidth = Helper.scaleX(Helper.sidebarWidth)
	menu.rightBarX = Helper.viewWidth - menu.sidebarWidth - Helper.frameBorder
	width = menu.rightBarX - Helper.frameBorder - Helper.borderSize
	xoffset = xoffset + Helper.frameBorder

	menu.missioninfo = C.GetTerraformingMissionInfo(menu.cluster)

	menu.stats = {}
	menu.dormantstats = {}
	menu.statsbyid = {}
	local n = C.GetNumTerraformingCurrentStats(menu.cluster)
	local buf = ffi.new("UITerraformingStat[?]", n)
	n = C.GetTerraformingCurrentStats(buf, n, menu.cluster)
	for i = 0, n - 1 do
		local id = ffi.string(buf[i].id)

		local ranges = {}
		local buf_ranges = ffi.new("UITerraformingStatRange[?]", buf[i].numranges)
		local numranges = C.GetTerraformingStatRange(buf_ranges, buf[i].numranges, menu.cluster, id)
		for j = 0, numranges - 1 do
			table.insert(ranges, {
				endvalue = buf_ranges[j].endvalue,
				state = buf_ranges[j].state,
				color = { r = buf_ranges[j].color.red, g = buf_ranges[j].color.green, b = buf_ranges[j].color.blue, a = buf_ranges[j].color.alpha },
				description = ffi.string(buf_ranges[j].description),
			})
		end

		local entry = {
			id = id,
			name = ffi.string(buf[i].name),
			description = ffi.string(buf[i].description),
			inactivetext = ffi.string(buf[i].inactivetext),
			iconid = ffi.string(buf[i].iconid),
			value = buf[i].value,
			state = buf[i].state,
			useranges = buf[i].useranges,
			ranges = ranges,
		}

		table.insert(menu.stats, entry)
		menu.statsbyid[id] = entry
	end

	local n = C.GetNumTerraformingDynamicStats()
	local buf = ffi.new("UITerraformingStat[?]", n)
	n = C.GetTerraformingDynamicStats(buf, n)
	for i = 0, n - 1 do
		local id = ffi.string(buf[i].id)

		if not menu.statsbyid[id] then
			local ranges = {}
			local buf_ranges = ffi.new("UITerraformingStatRange[?]", buf[i].numranges)
			local numranges = C.GetTerraformingStatRange(buf_ranges, buf[i].numranges, menu.cluster, id)
			for j = 0, numranges - 1 do
				table.insert(ranges, {
					endvalue = buf_ranges[j].endvalue,
					state = buf_ranges[j].state,
					color = { r = buf_ranges[j].color.red, g = buf_ranges[j].color.green, b = buf_ranges[j].color.blue, a = buf_ranges[j].color.alpha },
					description = ffi.string(buf_ranges[j].description),
				})
			end

			local entry = {
				id = id,
				name = ffi.string(buf[i].name),
				description = ffi.string(buf[i].description),
				inactivetext = ffi.string(buf[i].inactivetext),
				iconid = ffi.string(buf[i].iconid),
				value = buf[i].value,
				state = buf[i].state,
				useranges = buf[i].useranges,
				ranges = ranges,
				dynamic = buf[i].dynamic,
			}

			menu.dormantstats[id] = entry
		end
	end

	local numcols = math.max(8, #menu.stats)
	local usedcols = #menu.stats
	-- dormant stats col
	if next(menu.dormantstats) then
		usedcols = usedcols + 1
		if numcols < usedcols then
			numcols = numcols + 1
		end
	end
	-- mission col
	usedcols = usedcols + 1
	if numcols < usedcols then
		numcols = numcols + 1
	end
	local table_data = menu.frame:addTable(numcols, { tabOrder = 1, highlightMode = "column", width = width, x = xoffset, y = menu.topLevelOffsetY + Helper.borderSize } )

	local row = table_data:addRow(nil, { fixed = true, bgColor = Color["row_title_background"] })
	row[1]:setColSpan(numcols):createText(menu.planetname, Helper.titleTextProperties)

	local col = math.floor((numcols - usedcols) / 2) + 1

	local row = table_data:addRow(nil, { fixed = true })
	local statwidth = #menu.stats
	if next(menu.dormantstats) then
		statwidth = statwidth + 1
	end
	row[col]:setColSpan(statwidth):createText(ReadText(1001, 3825), Helper.headerRowCenteredProperties)

	local row1 = table_data:addRow(nil, { fixed = true, borderBelow = false })
	local emptyrow1 = table_data:addRow(nil, { fixed = true, borderBelow = false })
	local row2 = table_data:addRow(nil, { fixed = true, borderBelow = false })
	local emptyrow2 = table_data:addRow(nil, { fixed = true, borderBelow = false })
	local row3 = table_data:addRow(nil, { fixed = true, borderBelow = false })
	local emptyrow3 = table_data:addRow(nil, { fixed = true, borderBelow = false })

	for i, stat in ipairs(menu.stats) do
		row1[col]:createText(stat.name, Helper.subHeaderTextProperties)
		row1[col].properties.halign = "center"
		row1[col].properties.cellBGColor = Color["row_background_unselectable"]
		if stat.useranges then
			local statetext = "\27[" .. stat.iconid .. "] "
			for i = 1, tonumber(stat.ranges[#stat.ranges].endvalue) do
				local currange
				for _, range in ipairs(stat.ranges) do
					if range.endvalue >= i then
						currange = range
						break
					end
				end
				statetext = statetext .. ((i ~= 1) and " " or "") .. Helper.convertColorToText(currange and currange.color or Color["text_normal"])
				if i <= stat.value then
					statetext = statetext .. "\27[terraforming_block_full]"
				else
					statetext = statetext .. "\27[terraforming_block_empty]"
				end
			end
			row2[col]:createText(statetext, { fontsize = 7, halign = "center", cellBGColor = Color["row_background_unselectable"] })
		else
			row2[col]:createText("\27[" .. stat.iconid .. "] " .. ConvertIntegerString(tonumber(stat.value), true, 0, true), { halign = "center", cellBGColor = Color["row_background_unselectable"] })
		end
		row3[col]:createText(stat.description, { halign = "left", wordwrap = true, cellBGColor = Color["row_background_unselectable"] })

		emptyrow1[col]:createText("", { fontsize = 1, minRowHeight = Helper.standardTextHeight / 2, cellBGColor = Color["row_background_unselectable"] })
		emptyrow2[col]:createText("", { fontsize = 1, minRowHeight = Helper.standardTextHeight / 2, cellBGColor = Color["row_background_unselectable"] })
		emptyrow3[col]:createText("", { fontsize = 1, minRowHeight = Helper.standardTextHeight / 4, cellBGColor = Color["row_background_unselectable"] })

		col = col + 1
	end

	-- other stats
	if next(menu.dormantstats) then
		row1[col]:createText(ReadText(1001, 3840), Helper.subHeaderTextProperties)
		row1[col].properties.halign = "center"
		row1[col].properties.cellBGColor = Color["row_background_unselectable"]
		row2[col]:createText("", { halign = "center", wordwrap = true, cellBGColor = Color["row_background_unselectable"] })

		local otherstattext = ""
		for _, entry in Helper.orderedPairs(menu.dormantstats) do
			if otherstattext ~= "" then
				otherstattext = otherstattext .. "\n"
			end
			if entry.inactivetext ~= "" then
				otherstattext = otherstattext .. "· " .. entry.inactivetext
			end
		end
		row3[col]:createText(otherstattext, { cellBGColor = Color["row_background_unselectable"], wordwrap = true })

		emptyrow1[col]:createText("", { fontsize = 1, minRowHeight = Helper.standardTextHeight / 2, cellBGColor = Color["row_background_unselectable"] })
		emptyrow2[col]:createText("", { fontsize = 1, minRowHeight = Helper.standardTextHeight / 2, cellBGColor = Color["row_background_unselectable"] })
		emptyrow3[col]:createText("", { fontsize = 1, minRowHeight = Helper.standardTextHeight / 4, cellBGColor = Color["row_background_unselectable"] })

		col = col + 1
	end

	-- objective info
	row1[col]:createText(ReadText(1001, 3402), Helper.subHeaderTextProperties)
	row1[col].properties.halign = "center"
	row1[col].properties.cellBGColor = Color["row_background_unselectable"]
	row1[col].properties.color = Color["text_mission"]
	row1[col].properties.titleColor = Color["text_mission"]
	row2[col]:createText("", { halign = "center", wordwrap = true, cellBGColor = Color["row_background_unselectable"] })
	if menu.missioninfo.missionid ~= 0 then
		local missiondetails = C.GetMissionIDDetails(menu.missioninfo.missionid)

		local objectives = {}
		for i = 1, tonumber(missiondetails.numBriefingObjectives) do
			local objective = C.GetMissionObjectiveStep3(menu.missioninfo.missionid, i)
			local actiontext = ffi.string(objective.actiontext)
			local completed = (i < missiondetails.activeBriefingStep and not objective.failed) or (i > missiondetails.activeBriefingStep and objective.completedoutofsequence)
			local entry_idx
			for j, entry in ipairs(objectives) do
				if entry.text == actiontext then
					entry_idx = j
					break
				end
			end
			if entry_idx then
				table.insert(objectives[entry_idx], { detail = ffi.string(objective.detailtext), completed = completed })
			else
				table.insert(objectives, { text = actiontext, { detail = ffi.string(objective.detailtext), completed = completed } })
			end
		end

		local objectivetext = ""
		for _, details in ipairs(objectives) do
			if objectivetext ~= "" then
				objectivetext = objectivetext .. "\n"
			end
			objectivetext = objectivetext .. details.text .. ReadText(1001, 120)
			for _, detail in ipairs(details) do
				objectivetext = objectivetext .. "\n· " .. Helper.convertColorToText(detail.completed and Color["text_success"] or Color["text_failure"]) .. detail.detail .. " " .. (detail.completed and "\27[widget_tick_01]" or "\27[widget_cross_01]") .. "\27X"
			end
		end
		row3[col]:createText(objectivetext, { cellBGColor = Color["row_background_unselectable"], wordwrap = true })
	elseif menu.missioninfo.missioncompleted then
		row3[col]:createText(ReadText(1001, 3823), { halign = "center", wordwrap = true, cellBGColor = Color["row_background_unselectable"], color = Color["text_mission"] })
	else
		row3[col]:createText(ColorText["text_error"] .. ReadText(1001, 3824), { halign = "center", wordwrap = true, cellBGColor = Color["row_background_unselectable"] })
	end
	emptyrow1[col]:createText("", { fontsize = 1, minRowHeight = Helper.standardTextHeight / 2, cellBGColor = Color["row_background_unselectable"] })
	emptyrow2[col]:createText("", { fontsize = 1, minRowHeight = Helper.standardTextHeight / 2, cellBGColor = Color["row_background_unselectable"] })
	emptyrow3[col]:createText("", { fontsize = 1, minRowHeight = Helper.standardTextHeight / 4, cellBGColor = Color["row_background_unselectable"] })

	col = col + 1

	table_data:addEmptyRow()

	local row = table_data:addRow(nil, { fixed = true })
	row[1]:setColSpan(numcols):createText(ReadText(1001, 3847), Helper.headerRowCenteredProperties)
	if not menu.hqismissing then
		row[1].properties.titleColor = nil
	end

	-- hq info
	if menu.hqismissing then
		local row = table_data:addRow(nil, { fixed = true })
		row[1]:setColSpan(numcols):createText(ColorText["text_error"] .. "\27[maptr_illegal] " .. string.format(ReadText(1001, 3826), ffi.string(C.GetComponentName(menu.cluster))) .. "         " .. string.format(ReadText(1001, 3827), GetComponentData(ConvertStringTo64Bit(tostring(menu.hq)), "sector")), { halign = "center", wordwrap = true })
	end

	menu.activeproject = ffi.string(C.GetTerraformingActiveProject(menu.cluster))

	menu.projects = {}
	menu.projectsbygroup = {}
	local temp_projectsbygroup = {}
	local n = C.GetNumTerraformingProjects(menu.cluster, false)
	local buf = ffi.new("UITerraformingProject2[?]", n)
	n = C.GetTerraformingProjects2(buf, n, menu.cluster, false)
	for i = 0, n - 1 do
		local entry = Helper.getProjectEntry(menu.cluster, buf[i], false)

		menu.projects[entry.id] = entry
		if menu.projectsbygroup[entry.group] then
			table.insert(menu.projectsbygroup[entry.group], entry)
			table.insert(temp_projectsbygroup[entry.group], entry)
		else
			menu.projectsbygroup[entry.group] = { entry }
			temp_projectsbygroup[entry.group] = { entry }
		end
	end

	local n = C.GetNumTerraformingProjects(menu.cluster, true)
	local buf = ffi.new("UITerraformingProject2[?]", n)
	n = C.GetTerraformingProjects2(buf, n, menu.cluster, true)
	for i = 0, n - 1 do
		local entry = Helper.getProjectEntry(menu.cluster, buf[i], true)
		local areconditionsfullfilled = true
		if not entry.showalways then
			for _, condition in ipairs(entry.conditions) do
				if not condition.issatisfied then
					areconditionsfullfilled = false
					break
				end
			end
		end
		if areconditionsfullfilled then
			menu.projects[entry.id] = entry
			if menu.projectsbygroup[entry.group] then
				table.insert(menu.projectsbygroup[entry.group], entry)
				table.insert(temp_projectsbygroup[entry.group], entry)
			else
				menu.projectsbygroup[entry.group] = { entry }
				temp_projectsbygroup[entry.group] = { entry }
			end
		end
	end

	for _, groupentry in ipairs(menu.projectgroups) do
		--print("group: " .. groupentry.id)
		groupentry.projects = {}
		if temp_projectsbygroup[groupentry.id] then
			-- find entries without predecessors
			--print("  number of projects: " .. #projectsbygroup[groupentry.id])
			for i = #temp_projectsbygroup[groupentry.id], 1, -1 do
				local project = temp_projectsbygroup[groupentry.id][i]
				--print("    looking at project: " .. project.id .. ", has " .. #project.predecessors .. " predecessors, " .. tostring(next(project.predecessors)))

				local haspredecessors = true
				if not next(project.predecessors) then
					haspredecessors = false
				else
					local allinexternalgroup = true
					for _, predecessor in ipairs(project.predecessors) do
						local predecessorproject = menu.projects[predecessor]
						if predecessorproject and (predecessorproject.group == groupentry.id) then
							allinexternalgroup = false
							break
						end
					end
					if allinexternalgroup then
						haspredecessors = false
					end
				end

				if not haspredecessors then
					--print("  project without predecessor: " .. project.id)
					if groupentry.projects then
						--print("    added")
						table.insert(groupentry.projects, { project = project, predecessors = {} })
					else
						--print("    new entry")
						groupentry.projects = { [1] = { project = project, predecessors = {} } }
					end
					table.remove(temp_projectsbygroup[groupentry.id], i)
				end
			end
			-- assign entries based on predecessors
			local loopcounter = 0
			local idx = 1
			while #temp_projectsbygroup[groupentry.id] > 0 do
				local project = temp_projectsbygroup[groupentry.id][idx]
				--print("  looking at project: " .. project.id)

				-- try to find all predecessors in existing data
				local found = true
				local predecessors = {}
				for i, predecessor in ipairs(project.predecessors) do
					local predecessorproject = menu.projects[predecessor]
					if predecessorproject and (predecessorproject.group == groupentry.id) then
						local predecessorprojectnode = menu.findProject(groupentry.projects, predecessor)
						if predecessorprojectnode then
							predecessors[predecessorprojectnode] = 1
						else
							found = false
							break
						end
					end
				end
				--print("    " .. tostring(found))

				if found then
					-- add this project to the group and remove it from the list
					table.insert(groupentry.projects, { project = project, predecessors = predecessors })
					--print("    removed")
					table.remove(temp_projectsbygroup[groupentry.id], idx)
				end

				if idx >= #temp_projectsbygroup[groupentry.id] then
					loopcounter = loopcounter + 1
					idx = 1
				elseif not found then
					idx = idx + 1
				end
				--print("  new index: " .. idx)
				if loopcounter > 100 then
					DebugError("Infinite loop detected - aborting.")
					break
				end
			end
		end
		local hq64 = ConvertStringTo64Bit(tostring(menu.hq))
		for _, projectentry in ipairs(groupentry.projects) do
			if projectentry.project.id == menu.activeproject then
				local predecessors = {}
				for predecessornode in pairs(projectentry.predecessors) do
					predecessors[predecessornode] = true
				end
				for i, entry in ipairs(projectentry.project.resources) do
					local storagenode = Helper.createLSOStorageNode(menu, hq64, entry.ware, false, CheckSuitableTransportType(hq64, entry.ware), false)
					storagenode.name = storagenode.text
					table.insert(groupentry.projects, { project = storagenode, predecessors = {}, prevnodes = predecessors, exclusivetier = 1 })

					projectentry.predecessors[groupentry.projects[#groupentry.projects]] = 1
				end
				break
			end
		end
		table.sort(groupentry.projects, function (a, b) return a.project.name < b.project.name end)

		local numrows, numcols, junctions = Helper.setupDAGLayout(groupentry.projects)
		--[[
		print("result: " .. numrows .. ", " ..	numcols)
		for k, v in pairs(groupentry.projects) do
			if type(v) == "table" then
				print(k .. " - " .. tostring(v) .. ", " .. v.project.id)
				for k2, v2 in pairs(v) do
					if k2 == "predecessors" then
						print("   predecessors")
						for k3, v3 in pairs(v2) do
							print("      " .. tostring(k3) .. " - " .. k3.project.id)
						end
					else
						print("   " .. k2 .. ": " .. tostring(v2))
					end
				end
			end
		end--]]
		groupentry.projects.numrows = numrows
		groupentry.projects.numcols = numcols
		groupentry.projects.junctions = junctions
	end

	menu.flowchartRows = 0
	menu.flowchartCols = 0
	for i, groupentry in ipairs(menu.projectgroups) do
		menu.flowchartCols = menu.flowchartCols + groupentry.projects.numcols
		menu.flowchartRows = math.max(menu.flowchartRows, groupentry.projects.numrows)
	end

	menu.flowchart = menu.frame:addFlowchart(menu.flowchartRows, menu.flowchartCols, { borderHeight = 3, borderColor = Color["row_background_blue"], minRowHeight = 45, minColWidth = 80, x = Helper.frameBorder, y = table_data.properties.y + table_data:getFullHeight(), width = width })
	menu.flowchart:setDefaultNodeProperties({
		expandedFrameLayer = config.expandedMenuFrameLayer,
		expandedTableNumColumns = 2,
		x = config.nodeoffsetx,
		width = config.nodewidth,
		statusBgIconRotating = true,
	})
	-- backgrounds and header
	local groupCounter = 0
	local colCounter = 0
	for i, groupentry in ipairs(menu.projectgroups) do
		if #groupentry.projects > 0 then
			groupCounter = groupCounter + 1
		end
		for col = 1, groupentry.projects.numcols do
			colCounter = colCounter + 1
			if col == 1 then
				menu.flowchart:setColumnCaption(colCounter, groupentry.name)
			end
			if groupCounter % 2 == 0 then
				menu.flowchart:setColBackgroundColor(colCounter, Color["row_background_blue"])
			end
		end
	end

	menu.storagenodes = {}

	local colOffset = 0
	for i, groupentry in ipairs(menu.projectgroups) do
		for _, projectnode in ipairs(groupentry.projects) do
			if projectnode.project.ware then
				projectnode.node = menu.flowchart:addNode(projectnode.row, projectnode.col + colOffset, { nodedata = projectnode.project, moduledata = projectnode.project[1], expandHandler = projectnode.project[1].expandHandler }, projectnode.project[1].properties):setText(projectnode.project.text)
				projectnode.node.properties.expandedTableNumColumns = projectnode.project[1].expandedTableNumColumns
				projectnode.node.handlers.onExpanded = menu.onFlowchartNodeExpanded
				projectnode.node.handlers.onCollapsed = menu.onFlowchartNodeCollapsed
				projectnode.node.handlers.onSliderChanged = function (_, slideridx, value) return projectnode.project[1].sliderHandler(node, projectnode.project, slideridx, value) end
			else
				local color
				if projectnode.project.id ~= menu.activeproject then
					if ((projectnode.project.timescompleted == 0) or (projectnode.project.repeatcooldown > -1)) and (not projectnode.project.isevent) and (not C.CanStartTerraformingProject(menu.cluster, projectnode.project.id)) then
						color = Color["lso_node_inactive"]
					end
				end
				if (not projectnode.project.isevent) and menu.hqismissing then
					color = Color["lso_node_error"]
				end

				projectnode.node = menu.flowchart:addNode(projectnode.row, projectnode.col + colOffset, { data = { groupIdx = i, project = projectnode.project }, expandHandler = menu.expandNode }, { shape = "stadium", value = function () return menu.nodevalueProject(projectnode.project) end, max = 100 }):setText(projectnode.project.name, { color = color })
				projectnode.node.properties.outlineColor = color
				if projectnode.project.id ~= menu.activeproject then
					if projectnode.project.repeatcooldown > -1 then
						projectnode.node:setStatusIcon("menu_repeat", { color = color })
					end
				end

				projectnode.node.handlers.onExpanded = menu.onFlowchartNodeExpanded
				projectnode.node.handlers.onCollapsed = menu.onFlowchartNodeCollapsed

				if menu.restoreNodeProject and menu.restoreNodeProject == projectnode.project.id then
					menu.restoreNode = projectnode.node
					menu.restoreNodeProject = nil
				end
			end
		end

		for _, junctiondata in ipairs(groupentry.projects.junctions) do
			junctiondata.node = menu.flowchart:addJunction(junctiondata.row, junctiondata.col + colOffset)
		end

		colOffset = colOffset + groupentry.projects.numcols
	end

	local containerSlotColor = Color["lso_slot_container"]
	local liquidSlotColor = Color["lso_slot_liquid"]
	local solidSlotColor = Color["lso_slot_solid"]
	local containerProp = { sourceSlotColor = containerSlotColor, sourceSlotRank = 1, destSlotColor = containerSlotColor, destSlotRank = 1 }
	local liquidProp = { sourceSlotColor = liquidSlotColor, sourceSlotRank = 2, destSlotColor = liquidSlotColor, destSlotRank = 2 }
	local solidProp = { sourceSlotColor = solidSlotColor, sourceSlotRank = 3, destSlotColor = solidSlotColor, destSlotRank = 3 }

	-- add edges (needs to be a separate step to gurantee all nodes are already created)
	for i, groupentry in ipairs(menu.projectgroups) do
		for _, projectnode in ipairs(groupentry.projects) do
			if (not projectnode.project) or (not projectnode.project.ware) then
				for predecessornode in pairs(projectnode.predecessors) do
					local edgeproperties = nil
					if predecessornode.project and predecessornode.project.ware then
						edgeproperties = (predecessornode.project.type == "solid" and solidProp or (predecessornode.project.type == "liquid" and liquidProp or containerProp))
					end

					local edge = predecessornode.node:addEdgeTo(projectnode.node, edgeproperties)
					if predecessornode.project and (predecessornode.project.timescompleted == 0) then
						edge.properties.sourceSlotColor = Color["lso_node_inactive"]
						edge.properties.color = Color["lso_node_inactive"]
					end
					if predecessornode.project and (projectnode.project.id ~= menu.activeproject) then
						edge.properties.destSlotColor = color
					end
				end
			end
		end

		for _, junctiondata in ipairs(groupentry.projects.junctions) do
			if junctiondata.predecessors then
				for predecessor, slot in pairs(junctiondata.predecessors) do
					predecessor.node:addEdgeTo(junctiondata.node)
				end
			end
		end
	end

	menu.restoreFlowchartState("flowchart", menu.flowchart)

	Helper.createRightSideBar(menu.frame, ConvertStringTo64Bit(tostring(menu.hq)), not menu.hqismissing, "terraforming", menu.buttonRightBar)

	-- display view/frame
	menu.frame:display()
end

function menu.onFlowchartNodeExpanded(node, frame, ftable, ftable2)
	node.flowchart:collapseAllNodes()
	local data = node.customdata
	local expandHandler = data.expandHandler
	if expandHandler then
		menu.expandedMenuFrame = frame
		expandHandler(frame, ftable, ftable2, data.data or data.nodedata)
		menu.expandedNode = node
		menu.expandedMenuTable = ftable
	end
end

function menu.expandNode(_, ftable, _, data)
	AddUITriggeredEvent(menu.name, "terraforming_project_selected", data.project.id)

	ftable:setColWidthPercent(1, 66)
	ftable.properties.highlightMode = "grey"

	-- description
	if data.project.description ~= "" then
		local descriptiontext = GetTextLines(data.project.description, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), menu.expandedMenuFrame.properties.width - 2 * Helper.scaleX(Helper.standardTextOffsetx) - Helper.scrollbarWidth)
		for linenum, descline in ipairs(descriptiontext) do
			local row = ftable:addRow(true, {  })
			row[1]:setColSpan(2):createText(descline)
		end
	end

	-- required research
	if data.project.requiredresearch ~= "" then
		ftable:addEmptyRow(Helper.standardTextHeight / 2)

		local row = ftable:addRow(nil, {  })
		row[1]:setColSpan(2):createText(ReadText(1001, 3846) .. ReadText(1001, 120), { wordwrap = true })

		local hasresearched = C.HasResearched(data.project.requiredresearch)
		local row = ftable:addRow(true, {  })
		row[1]:setColSpan(2):createText("· " .. (hasresearched and ColorText["text_positive"] or ColorText["text_negative"]) .. GetWareData(data.project.requiredresearch, "name") .. " " .. (hasresearched and "\27[widget_tick_01]" or "\27[widget_cross_01]"), { wordwrap = true })
	end

	local haspredecessor = false
	for _, entry in ipairs(data.project.predecessorgroups) do
		if menu.projectsbygroup[entry.id] then
			haspredecessor = true
			break
		end
	end
	if not haspredecessor then
		for i, predecessor in ipairs(data.project.predecessors) do
			if menu.projects[predecessor] then
				haspredecessor = true
				break
			end
		end
	end

	-- predecessors and blockers
	if haspredecessor then
		if data.project.anypredecessor then
			ftable:addEmptyRow(Helper.standardTextHeight / 2)

			local row = ftable:addRow(nil, {  })
			row[1]:setColSpan(2):createText(ReadText(1001, 3843) .. ReadText(1001, 120), { wordwrap = true })
		else
			ftable:addEmptyRow(Helper.standardTextHeight / 2)

			local row = ftable:addRow(nil, {  })
			row[1]:setColSpan(2):createText(ReadText(1001, 3841) .. ReadText(1001, 120), { wordwrap = true })
		end
	end

	-- predecessor groups
	for _, entry in ipairs(data.project.predecessorgroups) do
		if menu.projectsbygroup[entry.id] then
			local isfullfilled = true
			for _, groupproject in ipairs(menu.projectsbygroup[entry.id]) do
				if groupproject.timescompleted > 0 then
					if entry.anyproject then
						isfullfilled = true
						break
					end
				else
					isfullfilled = false
				end
			end

			if entry.anyproject then
				local row = ftable:addRow(true, {  })
				row[1]:setColSpan(2):createText("· " .. (isfullfilled and ColorText["text_positive"] or ColorText["text_negative"]) .. string.format(ReadText(1001, 3808), menu.projectgroupsbyid[entry.id].name) .. " " .. (isfullfilled and "\27[widget_tick_01]" or "\27[widget_cross_01]"), { wordwrap = true })
			else
				local row = ftable:addRow(true, {  })
				row[1]:setColSpan(2):createText("· " .. (isfullfilled and ColorText["text_positive"] or ColorText["text_negative"]) .. string.format(ReadText(1001, 3807), menu.projectgroupsbyid[entry.id].name) .. " " .. (isfullfilled and "\27[widget_tick_01]" or "\27[widget_cross_01]"), { wordwrap = true })
			end
		end
	end

	-- predecessors
	for i, predecessor in ipairs(data.project.predecessors) do
		if menu.projects[predecessor] then
			local row = ftable:addRow(true, {  })
			row[1]:setColSpan(2):createText("· " .. ((menu.projects[predecessor].timescompleted > 0) and ColorText["text_positive"] or ColorText["text_negative"]) .. menu.projects[predecessor].name .. " " .. ((menu.projects[predecessor].timescompleted > 0) and "\27[widget_tick_01]" or "\27[widget_cross_01]"), { wordwrap = true })
		end
	end

	local hasblocker = false
	for _, blockingproject in ipairs(data.project.blockingprojects) do
		if menu.projects[blockingproject] then
			hasblocker = true
			break
		end
	end

	-- blocking projects
	if hasblocker and data.project.anypredecessor then
		ftable:addEmptyRow(Helper.standardTextHeight / 2)

		local row = ftable:addRow(nil, {  })
		row[1]:setColSpan(2):createText(ReadText(1001, 3841) .. ReadText(1001, 120), { wordwrap = true })
	end

	for _, blockingproject in ipairs(data.project.blockingprojects) do
		if menu.projects[blockingproject] then
			local row = ftable:addRow(true, {  })
			row[1]:setColSpan(2):createText("· " .. ((menu.projects[blockingproject].timescompleted > 0) and ColorText["text_positive"] or ColorText["text_negative"]) .. menu.projects[blockingproject].name .. " " .. ((menu.projects[blockingproject].timescompleted > 0) and "\27[widget_tick_01]" or "\27[widget_cross_01]"), { wordwrap = true })
		end
	end

	-- removed projects
	if #data.project.removedprojects > 0 then
		local hastitle = false
		for _, removedproject in ipairs(data.project.removedprojects) do
			if menu.projects[removedproject] then
				if not hastitle then
					ftable:addEmptyRow(Helper.standardTextHeight / 2)

					local row = ftable:addRow(nil, {  })
					row[1]:setColSpan(2):createText("\27[warning]" .. ReadText(1001, 3848) .. ReadText(1001, 120), { wordwrap = true, color = Color["text_warning"] })
					hastitle = true
				end
				local row = ftable:addRow(true, {  })
				row[1]:setColSpan(2):createText("· " .. menu.projects[removedproject].name, { wordwrap = true })
			end
		end
	end

	-- conditions
	if (data.project.repeatcooldown > -1) or (data.project.timescompleted == 0) then
		local hastitle = false
		for _, condition in ipairs(data.project.conditions) do
			local stat = menu.statsbyid[condition.stat]
			local dormantstat = menu.getDormantStat(condition.stat)

			if stat then
				hastitle = menu.displayCondition(ftable, condition, stat, hastitle)
			elseif dormantstat and dormantstat.dynamic then
				hastitle = menu.displayCondition(ftable, condition, dormantstat, hastitle)
			end
		end
	end

	-- effects
	local hastitle = false
	for _, effect in ipairs(data.project.primaryeffects) do
		hastitle = menu.displayEffect(ftable, effect, false, hastitle)
	end

	hastitle = false
	for _, effect in ipairs(data.project.sideeffects) do
		hastitle = menu.displayEffect(ftable, effect, true, hastitle)
	end

	-- rebates
	if (data.project.repeatcooldown > -1) or (data.project.timescompleted == 0) then
		local hastitle = false
		for _, rebate in ipairs(data.project.rebates) do
			if not hastitle then
				ftable:addEmptyRow(Helper.standardTextHeight / 2)

				local row = ftable:addRow(nil, {  })
				row[1]:setColSpan(2):createText(ReadText(1001, 3820) .. ReadText(1001, 120), { wordwrap = true, mouseOverText = ReadText(1026, 3802) })
				hastitle = true
			end
			local row = ftable:addRow(true, {  })
			row[1]:createText("· " .. ((rebate.ware ~= "") and GetWareData(rebate.ware, "name") or rebate.waregroupname))
			row[2]:createText(rebate.value .. " %", { halign = "right" })
		end
	end

	-- resilience
	if data.project.resilient then
		ftable:addEmptyRow(Helper.standardTextHeight / 2)
		local row = ftable:addRow(nil, {  })
		row[1]:setColSpan(2):createText(ReadText(1001, 11460), { wordwrap = true })
	end

	-- ships
	if data.project.id == menu.activeproject then
		ftable:addEmptyRow(Helper.standardTextHeight / 2)

		-- queue
		local row = ftable:addRow(nil, {  })
		row[1]:setColSpan(2):createText(ReadText(1001, 3804) .. ReadText(1001, 120))
		local row = ftable:addRow(nil, {  })
		row[1]:setColSpan(2):createText(function () menu.updateDroneInfo(data.project); return ConvertIntegerString(tonumber(menu.droneinfo.numbuildsinqueue), true, 0, true) end, { halign = "right" })
		-- progress
		local row = ftable:addRow(nil, {  })
		row[1]:setColSpan(2):createText(ReadText(1001, 3803) .. ReadText(1001, 120))
		local row = ftable:addRow(nil, {  })
		row[1]:setColSpan(2):createText(function () menu.updateDroneInfo(data.project); return ConvertIntegerString(tonumber(menu.droneinfo.numbuildsinprogress), true, 0, true) end, { halign = "right" })
		-- in-flight
		local row = ftable:addRow(nil, {  })
		row[1]:setColSpan(2):createText(ReadText(1001, 3805) .. ReadText(1001, 120))
		local row = ftable:addRow(nil, {  })
		row[1]:setColSpan(2):createText(function () menu.updateDroneInfo(data.project); return ConvertIntegerString(tonumber(menu.droneinfo.numcurrentdeliveries), true, 0, true) end, { halign = "right" })
	end

	if (data.project.repeatcooldown > -1) or (data.project.timescompleted == 0) then
		-- scale
		if data.project.pricescale == "population" then
			ftable:addEmptyRow(Helper.standardTextHeight / 2)
			local row = ftable:addRow(nil, {  })
			row[1]:setColSpan(2):createText(data.project.pricescaletext, { wordwrap = true })
		end

		-- resources
		if #data.project.resources > 0 then
			ftable:addEmptyRow(Helper.standardTextHeight / 2)
			if data.project.id == menu.activeproject then
				local row = ftable:addRow(nil, {  })
				row[1]:setColSpan(2):createText(ReadText(1001, 3850) .. ReadText(1001, 120), { wordwrap = true })
				for _, entry in ipairs(data.project.resources) do
					local row = ftable:addRow(true, {  })
					row[1]:createText(function () menu.updateDeliveredWares(data.project); local completed = (menu.deliveredwares[entry.ware] or 0) == entry.amount; return "· " .. (completed and ColorText["text_positive"] or "") .. GetWareData(entry.ware, "name") .. (completed and "\27[widget_tick_01]" or "") end)
					menu.updateDeliveredWares(data.project)
					row[2]:createText(function () menu.updateDeliveredWares(data.project); return ConvertIntegerString(menu.deliveredwares[entry.ware] or 0, true, 1, true) .. " / " .. ConvertIntegerString(entry.amount, true, 1, true) end, { halign = "right", mouseOverText = function () menu.updateDeliveredWares(data.project); return ConvertIntegerString(menu.deliveredwares[entry.ware] or 0, true, 0, true) .. " / " .. ConvertIntegerString(entry.amount, true, 0, true) end })
				end
			else
				local row = ftable:addRow(nil, {  })
				row[1]:setColSpan(2):createText(ReadText(1001, 7411) .. ReadText(1001, 120))
				for _, entry in ipairs(data.project.resources) do
					local row = ftable:addRow(true, {  })
					row[1]:createText("· " .. GetWareData(entry.ware, "name"))
					row[2]:createText(ConvertIntegerString(entry.amount, true, 0, true), { halign = "right" })
				end
			end
		elseif data.project.price > 0 then
			if data.project.id ~= menu.activeproject then
				ftable:addEmptyRow(Helper.standardTextHeight / 2)
				local row = ftable:addRow(nil, {  })
				row[1]:setColSpan(2):createText(ReadText(1001, 2808) .. ReadText(1001, 120), { wordwrap = true })
				local row = ftable:addRow(nil, {  })
				row[1]:setColSpan(2):createText(function () return ((GetPlayerMoney() < data.project.price) and (ColorText["text_negative"] .. "\27[widget_cross_01]") or (ColorText["text_positive"] .. "\27[widget_tick_01]")) .. ConvertMoneyString(tonumber(data.project.price), false, true, 0, true) .. " " .. ReadText(1001, 101) end, { halign = "right" })
			end
		end

		-- payout
		if data.project.payoutfactor > 0 then
			ftable:addEmptyRow(Helper.standardTextHeight / 2)
			local row = ftable:addRow(nil, {  })
			row[1]:setColSpan(2):createText(ReadText(1001, 3821) .. ReadText(1001, 120), { wordwrap = true })
			local row = ftable:addRow(nil, {  })
			row[1]:setColSpan(2):createText(ConvertMoneyString(data.project.payoutfactor * tonumber(data.project.price), false, true, 0, true) .. " " .. ReadText(1001, 101), { halign = "right" })
		end

		-- completion
		local hasspacing = false
		if data.project.timescompleted > 0 then
			if not hasspacing then
				ftable:addEmptyRow(Helper.standardTextHeight / 2)
				hasspacing = true
			end
			local row = ftable:addRow(nil, {  })
			row[1]:createText(ReadText(1001, 3815) .. ReadText(1001, 120))
			row[2]:createText(data.project.timescompleted, { halign = "right" })
		end
		-- chance
		if data.project.successchance < 100 then
			if not hasspacing then
				ftable:addEmptyRow(Helper.standardTextHeight / 2)
				hasspacing = true
			end
			local row = ftable:addRow(nil, {  })
			row[1]:createText(ReadText(1001, 8808) .. ReadText(1001, 120))
			row[2]:createText(data.project.successchance .. " %", { halign = "right" })
		end
		-- duration
		if data.project.duration > 0 then
			if not hasspacing then
				ftable:addEmptyRow(Helper.standardTextHeight / 2)
				hasspacing = true
			end
			local row = ftable:addRow(nil, {  })
			row[1]:createText(ReadText(1001, 3813) .. ReadText(1001, 120), { mouseOverText = ReadText(1026, 3800) })
			if data.project.isongoing then
				row[2]:createText(function () return ConvertTimeString(C.GetTerraformingProjectCompletionTime(menu.cluster, data.project.id) - C.GetCurrentGameTime(), "%h:%M:%S") end, { halign = "right", mouseOverText = ReadText(1026, 3800) })
			else
				row[2]:createText(ConvertTimeString(data.project.duration, "%h:%M:%S"), { halign = "right", mouseOverText = ReadText(1026, 3800) })
			end
		end
		-- cooldown
		if data.project.repeatcooldown > 0 then
			if not hasspacing then
				ftable:addEmptyRow(Helper.standardTextHeight / 2)
				hasspacing = true
			end
			local row = ftable:addRow(nil, {  })
			row[1]:createText(ReadText(1001, 3814) .. ReadText(1001, 120), { mouseOverText = ReadText(1026, 3801) })
			row[2]:createText(function () local availabilitytime = C.GetTerraformingProjectAvailabilityTime(menu.cluster, data.project.id); local curgametime = C.GetCurrentGameTime(); return ConvertTimeString((availabilitytime > curgametime) and (availabilitytime - curgametime) or data.project.repeatcooldown, "%h:%M:%S") end, { halign = "right", mouseOverText = ReadText(1026, 3801) })
		end

		-- start
		if not data.project.isevent then
			ftable:addEmptyRow()

			if data.project.id == menu.activeproject then
				local name, shiptrader = GetComponentData(ConvertStringTo64Bit(tostring(menu.hq)), "name", "shiptrader")
				if shiptrader then
					menu.updateDroneInfo(data.project)
					if (menu.droneinfo.numbuildsinprogress + menu.droneinfo.numcurrentdeliveries) == 0 then
						local row = ftable:addRow(nil, {  })
						row[1]:setColSpan(2):createText(function () menu.updateDroneInfo(data.project); return ((menu.droneinfo.numbuildsinprogress + menu.droneinfo.numcurrentdeliveries) == 0) and ReadText(1001, 3845) or "" end, { wordwrap = true, color = Color["text_error"] })
					end
				else
					local row = ftable:addRow(nil, {  })
					row[1]:setColSpan(2):createText(string.format(ReadText(1001, 11264), name), { wordwrap = true, color = Color["text_error"] })
				end

				local row = ftable:addRow(nil, {  })
				row[1]:setColSpan(2):createText(ReadText(1001, 3844), { wordwrap = true, color = Color["text_warning"] })
			end

			if data.project.id == menu.activeproject then
				local row = ftable:addRow(true, {  })
				row[1]:setColSpan(2):createButton({ active = function () return C.CanAbortActiveTerraformingProject(menu.cluster) end, mouseOverText = ReadText(1026, 3805) }):setText(ReadText(1001, 3849), { halign = "center" })
				row[1].handlers.onClick = menu.buttonAbortProject
			else
				local mouseovertext = ""
				if menu.activeproject ~= "" then
					mouseovertext = ReadText(1026, 3804)
				end
				local row = ftable:addRow(true, {  })
				row[1]:setColSpan(2):createButton({ active = function () return C.CanStartTerraformingProject(menu.cluster, data.project.id) end, mouseOverText = mouseovertext }):setText(ReadText(1001, 3801), { halign = "center" })
				row[1].handlers.onClick = function () return menu.buttonStartProject(data.project.id) end
			end
		end
	end

	menu.restoreTableState("nodeTable", ftable)
end

function menu.getDormantStat(stat)
	if stat == "" then
		return
	end
	menu.dormantstats = menu.dormantstats or {}
	if menu.dormantstats[stat] then
		return menu.dormantstats[stat]
	end
	local dormantstat = C.GetTerraformingStat(stat)

	local ranges = {}
	local buf_ranges = ffi.new("UITerraformingStatRange[?]", dormantstat.numranges)
	local numranges = C.GetTerraformingStatRange(buf_ranges, dormantstat.numranges, menu.cluster, stat)
	for i = 0, numranges - 1 do
		table.insert(ranges, {
			endvalue = buf_ranges[i].endvalue,
			state = buf_ranges[i].state,
			color = { r = buf_ranges[i].color.red, g = buf_ranges[i].color.green, b = buf_ranges[i].color.blue, a = buf_ranges[i].color.alpha },
			description = ffi.string(buf_ranges[i].description),
		})
	end

	menu.dormantstats[stat] = {
		id = ffi.string(dormantstat.id),
		name = ffi.string(dormantstat.name),
		description = ffi.string(dormantstat.description),
		dynamic = dormantstat.dynamic,
		value = dormantstat.value,
		state = dormantstat.state,
		useranges = dormantstat.useranges,
		ranges = ranges,
	}
	return menu.dormantstats[stat]
end

function menu.formatEffectValue(effect)
	local effecttext = ConvertIntegerString(tonumber(effect.value), true, 3, true)
	if effect.change ~= 0 then
		local effectcolor = effect.isbeneficial and ColorText["text_positive"] or ColorText["text_negative"]
		effecttext = ""
		if math.abs(effect.change) <= 3 then
			for i = 1, math.abs(effect.change) do
				effecttext = effecttext .. effectcolor .. ((effect.change < 0) and "\27[terraforming_arrow_down]" or "\27[terraforming_arrow_up]")
			end
		else
			effecttext = effectcolor .. ((effect.change < 0) and "\27[terraforming_arrow_down]" or "\27[terraforming_arrow_up]") .. ConvertIntegerString(math.abs(tonumber(effect.change)), true, 3, true)
		end
	end
	return effecttext
end

function menu.displayCondition(ftable, condition, stat, hastitle)
	if stat.useranges or (condition.minvalue > 0) then
		if not hastitle then
			ftable:addEmptyRow(Helper.standardTextHeight / 2)

			local row = ftable:addRow(nil, {  })
			row[1]:setColSpan(2):createText(ReadText(1001, 3810) .. ReadText(1001, 120))
			hastitle = true
		end
		local row = ftable:addRow(true, {  })
		row[1]:setColSpan(2):createText("· " .. (condition.issatisfied and ColorText["text_positive"] or ColorText["text_negative"]) .. stat.name .. " " .. (condition.issatisfied and "\27[widget_tick_01]" or "\27[widget_cross_01]"), { wordwrap = true })

		local row = ftable:addRow(nil, {  })
		if stat.useranges and next(stat.ranges) then
			local stattext = ""
			for i = 1, tonumber(stat.ranges[#stat.ranges].endvalue) do
				local currange
				for _, range in ipairs(stat.ranges) do
					if range.endvalue >= i then
						currange = range
						break
					end
				end
				if (i >= condition.minvalue) and (i <= condition.maxvalue) and (currange.state >= condition.min) and (currange.state <= condition.max) then
					stattext = stattext .. " " .. Helper.convertColorToText(currange and currange.color or Color["text_normal"]) .. "\27[terraforming_block_full]"
				end
			end
			row[1]:setColSpan(2):createText(stattext, { halign = "right" })
		else
			row[1]:setColSpan(2):createText((condition.issatisfied and ColorText["text_positive"] or ColorText["text_negative"]) .. ConvertIntegerString(tonumber(condition.minvalue), true, 0, true), { halign = "right" })
		end
	end

	return hastitle
end

function menu.displayEffect(ftable, effect, issideeffect, hastitle)
	local stat = menu.statsbyid[effect.stat]
	local dormantstat = menu.getDormantStat(effect.stat)

	local isstatrelevant = true
	if stat and effect.change ~= 0 then
		if effect.change > 0 then
			isstatrelevant = (stat.value >= effect.minvalue) and (stat.value < effect.maxvalue)
		else
			isstatrelevant = (stat.value > effect.minvalue) and (stat.value <= effect.maxvalue)
		end
	end
	local isdormantstatrelevant = true
	if dormantstat and effect.change ~= 0 then
		if effect.change > 0 then
			isdormantstatrelevant = (dormantstat.value >= effect.minvalue) and (dormantstat.value < effect.maxvalue)
		else
			isdormantstatrelevant = (dormantstat.value > effect.minvalue) and (dormantstat.value <= effect.maxvalue)
		end
	end

	if (effect.text ~= "") or (stat and isstatrelevant) or (dormantstat and dormantstat.dynamic and isdormantstatrelevant) then
		if not hastitle then
			ftable:addEmptyRow(Helper.standardTextHeight / 2)

			local row = ftable:addRow(nil, {  })
			row[1]:setColSpan(2):createText(issideeffect and ReadText(1001, 3812) or ReadText(1001, 3811) .. ReadText(1001, 120))
			hastitle = true
		end

		local failtext = ""
		if effect.onfail and (data.project.successchance < 100) then
			failtext = " (" .. ReadText(1001, 3816) .. ")"
		end

		local row = ftable:addRow(true, {  })
		if effect.text ~= "" then
			row[1]:setColSpan(issideeffect and 1 or 2):createText("· " .. effect.text .. failtext, { wordwrap = true })
		elseif stat then
			row[1]:createText("· " .. stat.name .. failtext, { wordwrap = true })
		elseif dormantstat then
			row[1]:createText("· " .. dormantstat.name .. failtext, { wordwrap = true })
		end
		if issideeffect then
			row[2]:createText((effect.isbeneficial and ColorText["text_positive"] or (ColorText["text_negative"] .. "\27[maptr_illegal] ")) .. effect.chance .. " %", { halign = "right" })
			if effect.setbackpercent > 0 then
				local mouseovertext = ReadText(1001, 3817) .. ReadText(1001, 120) .. " " .. effect.setbackpercent .. " %"
				row[1].properties.mouseOverText = mouseovertext
				row[2].properties.mouseOverText = mouseovertext
			end
		else
			if stat or dormantstat then
				row[2]:createText(menu.formatEffectValue(effect), { halign = "right" })
			end
		end
	end

	return hastitle
end

function menu.updateDeliveredWares(project)
	local curtime = getElapsedTime()
	if (not menu.lastDeliveryUpdateTime) or (curtime > menu.lastDeliveryUpdateTime) then
		menu.lastDeliveryUpdateTime = curtime
		menu.deliveredwares = {}
		local buf_deliveredwares = ffi.new("UIWareInfo[?]", #project.resources)
		local num_deliveredwares = C.GetTerraformingProjectDeliveredResources(buf_deliveredwares, #project.resources, menu.cluster, project.id)
		for i = 0, num_deliveredwares - 1 do
			menu.deliveredwares[ffi.string(buf_deliveredwares[i].ware)] = buf_deliveredwares[i].amount
		end
	end
end

function menu.updateDroneInfo(project)
	local curtime = getElapsedTime()
	if (not menu.lastDroneInfoUpdateTime) or (curtime > menu.lastDroneInfoUpdateTime) then
		menu.lastDroneInfoUpdateTime = curtime
		menu.droneinfo = C.GetTerraformingProjectDroneStatus(menu.cluster, project.id)
	end
end

function menu.onFlowchartNodeCollapsed(node, frame)
	if menu.expandedNode == node and menu.expandedMenuFrame == frame then
		local data = node.customdata
		local collapseHandler = data.collapseHandler
		if collapseHandler then
			collapseHandler(data)
		end
		Helper.clearFrame(menu, config.expandedMenuFrameLayer)
		menu.expandedMenuTable = nil
		menu.expandedMenuFrame = nil
		menu.expandedNode = nil
	end
end

function menu.createTopLevel(frame)
	menu.topLevelOffsetY = Helper.createTopLevelTab(menu, "terraforming", frame, ReadText(1001, 3800), nil, true)
end

function menu.onTabScroll(direction)
	if direction == "right" then
		Helper.scrollTopLevel(menu, "terraforming", 1)
	elseif direction == "left" then
		Helper.scrollTopLevel(menu, "terraforming", -1)
	end
end

function menu.onInputModeChanged(_, mode)
	menu.display()
end

-- widget scripts

function menu.buttonStartProject(projectid)
	C.StartTerraformingProject(menu.cluster, projectid)
	menu.activeproject = ffi.string(C.GetTerraformingActiveProject(menu.cluster))
	menu.updateExpandedNode()
	menu.refresh = getElapsedTime() + 1.0
end

function menu.buttonAbortProject()
	C.AbortActiveTerraformingProject(menu.cluster)
	menu.activeproject = ffi.string(C.GetTerraformingActiveProject(menu.cluster))
	menu.updateExpandedNode()
	menu.refresh = getElapsedTime() + 1.0
end

function menu.buttonRightBar(newmenu, params)
	menu.state = menu.onSaveState()
	Helper.closeMenuAndOpenNewMenu(menu, newmenu, params, true)
	menu.cleanup()
end

function menu.nodevalueProject(project)
	local value = 0
	local scale = (#project.resources > 0) and ((project.duration == 0) and 100 or 66) or 0
	if C.HasTerraformingProjectStarted(menu.cluster, project.id) then
		value = scale + C.GetTerraformingProjectCompletionFraction(menu.cluster, project.id) * (100 - scale)
	elseif project.id == menu.activeproject then
		menu.updateDeliveredWares(project)
		local sumdeliveries, sumresources = 0, 0
		for _, entry in ipairs(project.resources) do
			local volume = GetWareData(entry.ware, "volume")
			sumresources = sumresources + entry.amount * volume
			sumdeliveries = sumdeliveries + (menu.deliveredwares[entry.ware] or 0) * volume
		end
		value = (sumresources > 0) and sumdeliveries / sumresources * scale or 0
	elseif project.timescompleted > 0 then
		value = 100
	end
	return math.max(0, math.min(100, value))
end

menu.updateInterval = 0.1

-- hook to update the menu while it is being displayed
function menu.onUpdate()
	local curtime = getElapsedTime()
	local curgametime = C.GetCurrentGameTime()

	local oldactive = menu.activeproject
	menu.activeproject = ffi.string(C.GetTerraformingActiveProject(menu.cluster))
	if menu.activeproject ~= oldactive then
		menu.refresh = curtime + 1.0
	end

	for _, projects in pairs(menu.projectsbygroup) do
		for _, project in ipairs(projects) do
			if project.isongoing then
				if C.GetTerraformingProjectCompletionTime(menu.cluster, project.id) - curgametime < 0 then
					menu.refresh = curtime
					break
				end
			end
		end
	end

	local hq64 = ConvertStringTo64Bit(tostring(menu.hq))
	for _, node in pairs(menu.storagenodes) do
		Helper.updateLSOStorageNode(menu, node, hq64, node.customdata.nodedata.ware)
	end

	if menu.refresh and (menu.refresh <= curtime) then
		menu.refresh = nil
		menu.saveFlowchartState("flowchart", menu.flowchart)
		if menu.expandedNode then
			menu.restoreNodeProject = menu.expandedNode.customdata.data.project.id
			menu.expandedNode:collapse()
		end
		menu.display()
		return
	end

	if menu.restoreNode and menu.restoreNode.id then
		menu.restoreNode:expand()
		menu.restoreNode = nil
	end

	if menu.refreshnode and (menu.refreshnode < curtime) then
		menu.refreshnode = nil
		menu.updateExpandedNode()
	end

	-- 1 second updates are enough for frame content
	if (not menu.frameUpdateTimer) or (menu.frameUpdateTimer < curtime) then
		menu.frameUpdateTimer = curtime + 1
		menu.frame:update()
		if menu.expandedMenuFrame then
			menu.expandedMenuFrame:update()
		end
	end

	for i, groupentry in ipairs(menu.projectgroups) do
		for _, projectnode in ipairs(groupentry.projects) do
			if projectnode.project.id == menu.activeproject then
				menu.updateDroneInfo(projectnode.project)
				if (menu.droneinfo.numbuildsinprogress + menu.droneinfo.numcurrentdeliveries) > 0 then
					projectnode.node:updateStatus(nil, "lso_pie_00", "lso_progress", Color["flowchart_node_default"], ReadText(1001, 3800))
				else
					projectnode.node:updateStatus(nil, "lso_warning", nil, Color["icon_error"], ColorText["text_error"] .. menu.terraformingErrorText(projectnode))
				end
			end
		end
	end
end

function menu.onColChanged(row, col)
end

-- hook if the highlighted row is selected
function menu.onSelectElement(table, modified)
end

-- hook if the menu is being closed
function menu.onCloseElement(dueToClose, layer)
	if layer == config.expandedMenuFrameLayer then
		menu.expandedNode:collapse()
		return
	end

	if dueToClose == "back" then
		if Helper.checkDiscardStationEditorChanges(menu) then
			return
		end
	end

	menu.state = menu.onSaveState()
	Helper.closeMenu(menu, dueToClose)
	menu.cleanup()
end

function menu.findProject(ftable, project)
	for _, projectnode in ipairs(ftable) do
		if projectnode.project.id == project then
			return projectnode
		end
	end
end

function menu.updateExpandedNode()
	local node = menu.expandedNode
	node:collapse()
	node:expand()
end

-- helpers to maintain row/column states while frame is re-created
function menu.saveFlowchartState(name, flowchart)
	menu.topRows[name], menu.firstCols[name] = GetFlowchartFirstVisibleCell(flowchart.id)
	menu.selectedRows[name], menu.selectedCols[name] = GetFlowchartSelectedCell(flowchart.id)
end

function menu.restoreFlowchartState(name, flowchart)
	flowchart.properties.firstVisibleRow = menu.topRows[name] or 1
	flowchart.properties.firstVisibleCol = menu.firstCols[name] or 1
	menu.topRows[name] = nil
	menu.firstCols[name] = nil
	flowchart.properties.selectedRow = menu.selectedRows[name] or 1
	flowchart.properties.selectedCol = menu.selectedCols[name] or 1
	menu.selectedRows[name] = nil
	menu.selectedRowData[name] = nil
	menu.selectedCols[name] = nil
end

function menu.saveTableState(name, ftable, row, col)
	menu.topRows[name] = GetTopRow(ftable.id)
	menu.selectedRows[name] = row or Helper.currentTableRow[ftable.id]
	menu.selectedRowData[name] = menu.rowDataMap[ftable.id] and menu.rowDataMap[ftable.id][menu.selectedRows[name]]
	menu.selectedCols[name] = col or Helper.currentTableCol[ftable.id]
end

function menu.restoreTableState(name, ftable)
	ftable:setTopRow(menu.topRows[name])
	ftable:setSelectedRow(menu.selectedRows[name])
	ftable:setSelectedCol(menu.selectedCols[name] or 0)

	menu.topRows[name] = nil
	menu.selectedRows[name] = nil
	menu.selectedRowData[name] = nil
	menu.selectedCols[name] = nil
end

function menu.newWareReservationCallback(_, data)
	local containerid, ware, reserverid = string.match(data, "(.+);(.+);(.+)")
	local hq64 = ConvertStringTo64Bit(tostring(menu.hq))
	if hq64 == ConvertStringTo64Bit(containerid) then
		menu.updateExpandedNode()
	end
end

function menu.updateEdgeColorRecursively(edge, color)
	edge:updateColor(color)
	-- If edge source cell is a junction, update the junction's incoming edges as well, based on its outgoing edges
	local cell = edge.sourcecell
	if cell.type == "flowchartjunction" then
		local incomingcolor = menu.getPrimaryJunctionEdgeColor(cell.outgoingEdges)
		for _, incomingedge in ipairs(cell.incomingEdges) do
			menu.updateEdgeColorRecursively(incomingedge, incomingcolor)
		end
	end
end

function menu.terraformingErrorText(project)
	local hq64 = ConvertStringTo64Bit(tostring(menu.hq))
	local name, shiptrader = GetComponentData(hq64, "name", "shiptrader")
	if shiptrader then
		menu.updateDroneInfo(project.project)
		return ((menu.droneinfo.numbuildsinprogress + menu.droneinfo.numcurrentdeliveries) == 0) and ReadText(1001, 3845) or ""
	else
		return string.format(ReadText(1001, 11264), name)
	end
end

init()
