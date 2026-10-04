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
		uint32_t colidx;
		uint32_t colspan;
		const char* text;
		Color textcolor;
		float textglowfactor;
		uint32_t fontsize;
		bool wordwrap;
		bool typewritereffect;
		const char* icon;
		Color iconcolor;
		float iconglowfactor;
		uint32_t iconwidth;
		uint32_t iconheight;
		int32_t offsetx;
		int32_t offsety;
		uint32_t cellheight;
		const char* halign;
		const char* valign;
		Color backgroundcolor;
		float backgroundglowfactor;
		double flashduration;
		double flashinterval;
		Color flashcolor;
		float flashglowfactor;
	} OverlayCellInfo3;
	typedef struct {
		uint32_t numrows;
		float fadein;
		float fadeout;
		float relwidth;
		float reloffsetx;
		float reloffsety;
		bool fromright;
		bool fromtop;
	} OverlayInfo;
	typedef struct {
		uint32_t numcols;
		float reloffsetx;
		float reloffsety;
		bool fromright;
		bool fromtop;
	} OverlayRowInfo;
	
	OverlayRowInfo GetNumOverlayCols(uint32_t rowidx);
	OverlayInfo GetOverlayDefinition(void);
	uint32_t GetOverlayCols3(OverlayCellInfo3* result, uint32_t resultlen, uint32_t rowidx);
	float GetTextHeight(const char*const text, const char*const fontname, const float fontsize, const float wordwrapwidth);
	float GetUIScale(const bool scalewithresolution);
	bool IsVRMode();
]]

local utf8 = require("utf8")

--- Wrapper ---

local origffistring = ffi.string
ffi.string = function(data) 
	if data ~= nil then
		return origffistring(data)
	else
		DebugError("Invalid parameter for ffi.string() in overlay. Check caller!")
		DebugError(TraceBack())
		return ""
	end
end

-- settings
local config = {
	scalingFactor = 0.0004, -- factor the presentation is scaled in-game (used to scale the ui_anchor value)
	numCells = 100,
	defaultCellHeight = 20,
	typewriterInterval = 0.05,
}

-- private member data
local private = {
	cellMaster = nil,		-- master cell element
	cells = {},
	activeCells = {},
	typewriterCells = {},
	flashingCells = {},
	deactivate = false,      -- indicates whether the overlay should deactivate itself
	width = nil,
	height = nil,
	uiScale = nil,
	fadeFactor = 1.0,
	lastTypewriterUpdate = 0.0,
}

-- local functions forward declarations
local activateOverlay
local deactivateOverlay
local hideOverlay
local initScale
local setCellOpacities
local showOverlay

---------------------------------
-- Gameface lifetime functions --
---------------------------------
function self:onInitialize()
	local scene           = getElement("Scene")
	local contract        = getElement("UIContract", scene)
	local uiAnchorElement = getElement("Layer.ui_anchor", scene)

	private.cellMaster = getElement("overlaycell", uiAnchorElement)

	private.uiScale = C.GetUIScale(false)
	
	private.width, private.height = getScreenInfo()
	initScale(uiAnchorElement)
	initCells()

	registerForEvent("showOverlay", contract, activateOverlay)
	registerForEvent("hideOverlay", contract, deactivateOverlay)

	-- overlay should appear "static" on screen and shouldn't be affected by the "wobbling" camera effect
	DisableCameraEffectSync()

	LockPresentation()
end

function self:onUpdate()
	local curtime = getElapsedTime()

	if private.deactivate then
		-- abort fadein
		private.fadeInDuration = nil

		if private.fadeOutDuration then
			if not private.fadeOutStart then
				private.fadeOutStart = curtime
			end

			private.fadeFactor = 1.0 - math.max(0.0, math.min(1.0, (curtime - private.fadeOutStart) / private.fadeOutDuration))
			setCellOpacities()

			if private.fadeOutStart + private.fadeOutDuration < curtime then
				private.fadeOutDuration = nil
			end
		else
			hideOverlay()
			private.deactivate = false
		end
	end
	if private.fadeInDuration then
		private.fadeFactor = math.max(0.0, math.min(1.0, (curtime - private.fadeInStart) / private.fadeInDuration))
		setCellOpacities()

		if private.fadeInStart + private.fadeInDuration < curtime then
			private.fadeInDuration = nil
		end
	end

	if private.lastTypewriterUpdate + config.typewriterInterval < curtime then
		for i = #private.typewriterCells, 1, -1 do
			local entry = private.typewriterCells[i]
			local cell = private.cells[entry.idx]
			local text = entry.text
			entry.textindex = entry.textindex + 1

			local textelement = getElement("Text", cell)
			setAttribute(textelement, "textstring", utf8.sub(text, 1, entry.textindex))

			if entry.textindex >= utf8.len(text) then
				table.remove(private.typewriterCells, i)
			end
		end
		private.lastTypewriterUpdate = curtime
	end

	if #private.flashingCells > 0 then
		for i = #private.flashingCells, 1, -1 do
			local entry = private.flashingCells[i]
			local cell = private.cells[entry.idx]
			local celldata = entry.celldata
			local t = (math.sin((1 / celldata.flashinterval) * math.pi * (curtime - entry.starttime)) + 1) / 2

			local textcolor, iconcolor
			if (curtime > entry.starttime + celldata.flashduration) and (t < 0.01) then
				table.remove(private.flashingCells, i)
			else
				if celldata.text ~= "" then
					textcolor = {
						r = t * celldata.flashcolor.r + (1 - t) * celldata.textcolor.r,
						g = t * celldata.flashcolor.g + (1 - t) * celldata.textcolor.g,
						b = t * celldata.flashcolor.b + (1 - t) * celldata.textcolor.b,
						a = t * celldata.flashcolor.a + (1 - t) * celldata.textcolor.a,
						glow = t * celldata.flashcolor.glow + (1 - t) * celldata.textcolor.glow,
					}
				end
				if celldata.icon ~= "" then
					iconcolor = {
						r = t * celldata.flashcolor.r + (1 - t) * celldata.iconcolor.r,
						g = t * celldata.flashcolor.g + (1 - t) * celldata.iconcolor.g,
						b = t * celldata.flashcolor.b + (1 - t) * celldata.iconcolor.b,
						a = t * celldata.flashcolor.a + (1 - t) * celldata.iconcolor.a,
						glow = t * celldata.flashcolor.glow + (1 - t) * celldata.iconcolor.glow,
					}
				end
			end

			if celldata.text ~= "" then
				local textelement = getElement("Text", cell)
				setAttribute(textelement, "textcolor.r", textcolor and textcolor.r or celldata.textcolor.r)
				setAttribute(textelement, "textcolor.g", textcolor and textcolor.g or celldata.textcolor.g)
				setAttribute(textelement, "textcolor.b", textcolor and textcolor.b or celldata.textcolor.b)
				setAttribute(textelement, "opacity", (textcolor and textcolor.a or celldata.textcolor.a) * private.fadeFactor)
				setAttribute(textelement, "glowfactor", textcolor and textcolor.glow or celldata.textcolor.glow)
			end
			if celldata.icon ~= "" then
				local iconmaterial = getElement("Icon.Icon", cell)
				SetDiffuseColor(iconmaterial, iconcolor and iconcolor.r or celldata.iconcolor.r, iconcolor and iconcolor.g or celldata.iconcolor.g, iconcolor and iconcolor.b or celldata.iconcolor.b)
				setAttribute(iconmaterial, "opacity", (iconcolor and iconcolor.a or celldata.iconcolor.a) * private.fadeFactor)
				setAttribute(iconmaterial, "glowfactor", iconcolor and iconcolor.glow or celldata.iconcolor.glow)
			end
		end
	end
end

-------------------------------------
-- Presentation specific callbacks --
-------------------------------------
function activateOverlay()
	private.deactivate = false
	showOverlay()
end

function deactivateOverlay(_, force)
	if force then
		private.fadeOutDuration = nil
	end
	private.deactivate = true
end


-------------------------------------
-- Presentation specific functions --
-------------------------------------

function initScale(anchorElement)
	-- No sure about the 0.907 factor here, but it was consistently off in all resolution, uiscale and aspect ratio combinations. We have the same factor in the widgetsystem actually
	local factor = 1080 / private.height * 0.907
	setAttribute(anchorElement, "scale.x", config.scalingFactor * factor)
	setAttribute(anchorElement, "scale.y", config.scalingFactor * factor)
	setAttribute(anchorElement, "scale.z", config.scalingFactor * factor)
end

function initCells()
	for i = 1, config.numCells do
		private.cells[i] = clone(private.cellMaster, "cell"..i)
	end
end

function convertHorizontalAlignment(alignment)
	if alignment == "left" then
		return 0
	elseif alignment == "center" then
		return 1
	elseif alignment == "right" then
		return 2
	end
	return 1 --unknown
end

--[[
function convertVerticalAlignment(alignment)
	if alignment == "top" then
		return 0
	elseif alignment == "center" then
		return 1
	elseif alignment == "bottom" then
		return 2
	end
	return 0 --unknown
end]]

function showCell(idx, x, y, width, height, celldata)
	local cell = private.cells[idx]
	table.insert(private.activeCells, { idx = idx, celldata = celldata })

	local slide = ""

	if celldata.text ~= "" then
		slide = "text"

		local fontsize = celldata.fontsize * private.uiScale

		local textelement = getElement("Text", cell)

		local offsetx = celldata.offsetx
		if celldata.halign == "left" then
			offsetx = offsetx - width / 2
		elseif celldata.halign == "right" then
			offsetx = -offsetx + width / 2
		end
		local offsety = celldata.offsety
		if celldata.valign == "top" then
			offsety = -offsety + height / 2
		elseif celldata.valign == "center" then
			offsety = -offsety + celldata.textheight / 2
		elseif celldata.valign == "bottom" then
			offsety = offsety - height / 2 + celldata.textheight
		end
		setAttribute(textelement, "position.x", offsetx)
		setAttribute(textelement, "position.y", offsety)
		setAttribute(textelement, "horzalign", convertHorizontalAlignment(celldata.halign))
		--setAttribute(textelement, "vertalign", convertVerticalAlignment(celldata.valign)) -- introduces some offset in the center case, same effect can be achieved with above offsety calculation
		setAttribute(textelement, "size", fontsize)
		setAttribute(textelement, "textcolor.r", celldata.textcolor.r)
		setAttribute(textelement, "textcolor.g", celldata.textcolor.g)
		setAttribute(textelement, "textcolor.b", celldata.textcolor.b)
		setAttribute(textelement, "glowfactor", celldata.textcolor.glow)
		setAttribute(textelement, "boxwidth", (width - 2 * celldata.offsetx) / 4)

		if celldata.typewritereffect then
			setAttribute(textelement, "textstring", utf8.sub(celldata.text, 1, 1))
			table.insert(private.typewriterCells, { idx = idx, text = celldata.text, textindex = 1 })
		else
			setAttribute(textelement, "textstring", celldata.text)
		end
	end

	if celldata.icon ~= "" then
		if slide ~= "" then
			slide = "both"
		else
			slide = "icon"
		end

		local iconwidth = width - 2 * celldata.offsetx
		if celldata.iconwidth > 0 then
			iconwidth = celldata.iconwidth
		end
		iconwidth = iconwidth * private.uiScale
		local iconheight = height - 2 * celldata.offsety
		if celldata.iconheight > 0 then
			iconheight = celldata.iconheight * private.uiScale
		end

		local iconelement = getElement("Icon", cell)
		local material = getElement("Icon", iconelement)
		SetIcon(getElement("icon", material), celldata.icon, celldata.iconcolor.r, celldata.iconcolor.g, celldata.iconcolor.b, false, iconwidth, iconheight)
		setAttribute(material, "glowfactor", celldata.iconcolor.glow)

		local offsetx = celldata.offsetx
		if celldata.halign == "left" then
			offsetx = offsetx - width / 2 + iconwidth / 2
		elseif celldata.halign == "right" then
			offsetx = -offsetx + width / 2 - iconwidth / 2
		end
		local offsety = celldata.offsety
		if celldata.valign == "top" then
			offsety = -offsety + height / 2 - iconheight / 2
		elseif celldata.valign == "center" then
			offsety = -offsety
		elseif celldata.valign == "bottom" then
			offsety = offsety - height / 2 + iconheight / 2
		end
		setAttribute(iconelement, "position.x", offsetx)
		setAttribute(iconelement, "position.y", offsety)
	end

	local background = getElement("Background", cell)
	setAttribute(background, "scale.x", width / 100)
	setAttribute(background, "scale.y", height / 100)
	local backgroundMaterial = getElement("Material127", background)
	SetDiffuseColor(backgroundMaterial, celldata.backgroundcolor.r, celldata.backgroundcolor.g, celldata.backgroundcolor.b)
	setAttribute(backgroundMaterial, "glowfactor", celldata.backgroundcolor.glow)

	if celldata.flashduration > 0 then
		if (celldata.text ~= "") or (celldata.icon ~= "") then
			table.insert(private.flashingCells, { idx = idx, celldata = celldata, starttime = getElapsedTime() })
		end
	end

	setCellOpacity(cell, celldata)

	setAttribute(cell, "position.x", x)
	setAttribute(cell, "position.y", y - height / 2)

	if slide == "" then
		return 0
	end

	goToSlide(cell, slide)
end

function setCellOpacities()
	for _, entry in ipairs(private.activeCells) do
		local cell = private.cells[entry.idx]
		local celldata = entry.celldata

		setCellOpacity(cell, celldata)
	end
end

function setCellOpacity(cell, celldata)
	if celldata.text ~= "" then
		local textelement = getElement("Text", cell)
		setAttribute(textelement, "opacity", celldata.textcolor.a * private.fadeFactor)
	end

	if celldata.icon ~= "" then
		local material = getElement("Icon.Icon", cell)
		setAttribute(material, "opacity", celldata.iconcolor.a * private.fadeFactor)
	end

	local backgroundMaterial = getElement("Background.Material127", cell)
	setAttribute(backgroundMaterial, "opacity", celldata.backgroundcolor.a * private.fadeFactor)
end

function getCellHeight(width, celldata)
	local height = config.defaultCellHeight
	if celldata.text ~= "" then
		local fontsize = celldata.fontsize * private.uiScale

		if not celldata.wordwrap then
			celldata.text = TruncateText(celldata.text, "zekton", fontsize, width - 2 * celldata.offsetx)
		end
		height = math.ceil(C.GetTextHeight(celldata.text, "zekton", fontsize, width - 2 * celldata.offsetx))
		celldata.textheight = height
	end

	if celldata.icon ~= "" then
		local iconheight = height
		if celldata.iconheight > 0 then
			iconheight = celldata.iconheight
		end
		iconheight = iconheight * private.uiScale
		height = math.max(height, iconheight)
	end

	return (celldata.cellheight ~= 0) and celldata.cellheight or height + 2 * celldata.offsety
end

function hideCells()
	for _, entry in ipairs(private.activeCells) do
		goToSlide(private.cells[entry.idx], "inactive")
	end
	private.activeCells = {}
	private.typewriterCells = {}
	private.flashingCells = {}
end

function getOverlayCellData()
	local numcols = 0
	local overlaydefinition = C.GetOverlayDefinition()
	local cells = {}
	cells.fadein = overlaydefinition.fadein
	cells.fadeout = overlaydefinition.fadeout
	cells.relwidth = overlaydefinition.relwidth
	cells.reloffsetx = overlaydefinition.reloffsetx
	cells.reloffsety = overlaydefinition.reloffsety
	cells.fromright = overlaydefinition.fromright;
	cells.fromtop = overlaydefinition.fromtop;

	if overlaydefinition.numrows > 0 then
		for i = 1, overlaydefinition.numrows do
			local rowinfo = C.GetNumOverlayCols(i)
			local n = rowinfo.numcols
			if n > 0 then
				cells[i] = {
					reloffsetx = rowinfo.reloffsetx,
					reloffsety = rowinfo.reloffsety,
					fromright = rowinfo.fromright,
					fromtop = rowinfo.fromtop,
				}
				local buf = ffi.new("OverlayCellInfo3[?]", n)
				n = C.GetOverlayCols3(buf, n, i)
				for j = 0, n - 1 do
					local colidx = buf[j].colidx
					local colspan = buf[j].colspan
					cells[i][colidx] = {
						colspan = colspan,
						text = ffi.string(buf[j].text),
						textcolor = {
							r = buf[j].textcolor.red,
							g = buf[j].textcolor.green,
							b = buf[j].textcolor.blue,
							a = buf[j].textcolor.alpha,
							glow = buf[j].textglowfactor,
						},
						fontsize = buf[j].fontsize,
						wordwrap = buf[j].wordwrap,
						typewritereffect = buf[j].typewritereffect,
						icon = ffi.string(buf[j].icon),
						iconcolor = {
							r = buf[j].iconcolor.red,
							g = buf[j].iconcolor.green,
							b = buf[j].iconcolor.blue,
							a = buf[j].iconcolor.alpha,
							glow = buf[j].iconglowfactor,
						},
						iconwidth = buf[j].iconwidth,
						iconheight = buf[j].iconheight,
						offsetx = buf[j].offsetx,
						offsety = buf[j].offsety,
						cellheight = buf[j].cellheight,
						halign = ffi.string(buf[j].halign),
						valign = ffi.string(buf[j].valign),
						backgroundcolor = {
							r = buf[j].backgroundcolor.red,
							g = buf[j].backgroundcolor.green,
							b = buf[j].backgroundcolor.blue,
							a = buf[j].backgroundcolor.alpha,
							glow = buf[j].backgroundglowfactor,
						},
						flashduration = buf[j].flashduration,
						flashinterval = buf[j].flashinterval,
						flashcolor = {
							r = buf[j].flashcolor.red,
							g = buf[j].flashcolor.green,
							b = buf[j].flashcolor.blue,
							a = buf[j].flashcolor.alpha,
							glow = buf[j].flashglowfactor,
						},
					}

					numcols = math.max(numcols, colidx + colspan - 1)
				end
			end
		end
	end

	return cells, overlaydefinition.numrows, numcols
end

function showOverlay()
	hideCells()

	local cells, numrows, numcols = getOverlayCellData()

	if cells.fadein > 0 then
		private.fadeInStart = getElapsedTime()
		private.fadeInDuration = cells.fadein
		private.fadeFactor = 0.0
	else
		private.fadeFactor = 1.0
	end
	if cells.fadeout > 0 then
		private.fadeOutDuration = cells.fadeout
		private.fadeOutStart = nil
	end

	local availablewidth = cells.relwidth * private.width
	local globalOffsetX = -private.width / 2 + cells.reloffsetx * private.width
	if cells.fromright then
		globalOffsetX = -globalOffsetX - availablewidth
	end
	local globalOffsetY = -private.height / 2 + cells.reloffsety * private.height
	if cells.fromtop then
		globalOffsetY = -globalOffsetY
	end
	local cellwidth = math.floor(availablewidth / numcols)

	local fullheight = cells.fromtop and -1 or 0
	local fullheights = {}
	local sectionidx = 1
	for i, row in ipairs(cells) do
		if row.reloffsety >= 0 then
			if i > 1 then
				fullheights[sectionidx] = fullheight
				sectionidx = sectionidx + 1
			end
			fullheight = row.fromtop and -1 or 0
		end

		local maxheight = 0
		for col, cell in pairs(cells[i]) do
			if type(col) == "number" then
				local cellheight = getCellHeight(cell.colspan * cellwidth, cell)
				maxheight = math.max(maxheight, cellheight)
			end
		end
		row.rowheight = maxheight
		if fullheight >= 0 then
			fullheight = fullheight + maxheight
		end
	end
	fullheights[sectionidx] = fullheight

	local cellindex = 1
	local previousrowheight = 0
	local currentOffsetX = globalOffsetX
	local currentOffsetY = globalOffsetY
	local sectionidx = 1
	for i, row in ipairs(cells) do
		if row.reloffsetx >= 0 then
			currentOffsetX = -private.width / 2 + row.reloffsetx * private.width
			if row.fromright then
				currentOffsetX = -currentOffsetX - availablewidth
			end
		end
		if row.reloffsety >= 0 then
			currentOffsetY = -private.height / 2 + row.reloffsety * private.height
			if row.fromtop then
				currentOffsetY = -currentOffsetY
			end
			previousrowheight = 0
			if i > 1 then
				sectionidx = sectionidx + 1
			end
		end

		local colspan = 1
		for j = 1, numcols do
			if colspan == 1 then
				local cell = cells[i][j]
				if cell then
					colspan = cell.colspan
					local offsetx = currentOffsetX + (j + (cell.colspan - 2) / 2) * cellwidth
					local offsety = currentOffsetY
					if fullheights[sectionidx] > 0 then
						offsety = offsety + fullheights[sectionidx] - previousrowheight
					else
						offsety = offsety - previousrowheight
					end
					showCell(cellindex, offsetx, offsety, cell.colspan * cellwidth, row.rowheight, cell)
					cellindex = cellindex + 1
				end
			elseif colspan > 1 then
				colspan = colspan - 1
			end
		end
		previousrowheight = previousrowheight + row.rowheight
	end
end

function hideOverlay()
	hideCells()
	HidePresentation()
	LockPresentation()
end
