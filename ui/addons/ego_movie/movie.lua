-- Ingame Movie Display

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	const char* GetDetailmonitorCutsceneKey(uint32_t cutsceneid);
	void OpenMovieMenu(const char* key);
	uint32_t PlayDetailmonitorCutscene(uint32_t cutsceneid, const char* rendertarget);
	void StopDetailmonitorCutscene(uint32_t cutsceneid);
]]

local menu = {
	name = "MovieMenu",
}

local config = {
	layer = 3,
}

local function init()
	Menus = Menus or { }
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end

	RegisterEvent("showDetailmonitorCutscene", menu.onShowCutscene)
	registerForEvent("cutsceneStopped", getElement("Scene.UIContract"), menu.onCutsceneStopped)
end

function menu.cleanup()
	menu.rendertarget = nil

	C.StopDetailmonitorCutscene(menu.detailmonitorCutsceneID)
	menu.detailmonitorCutsceneID = nil
	menu.cutsceneID = nil
end

function menu.onShowCutscene(_, detailmonitorCutsceneID)
	if menu.detailmonitorCutsceneID then
		C.StopDetailmonitorCutscene(menu.detailmonitorCutsceneID)
		menu.detailmonitorCutsceneID = nil
		menu.cutsceneID = nil
	end
	menu.detailmonitorCutsceneID = detailmonitorCutsceneID

	if not menu.cutsceneStoppedNotification then
		menu.cutsceneStoppedNotification = true
		NotifyOnCutsceneStopped(getElement("Scene.UIContract"))
	end

	local key = ffi.string(C.GetDetailmonitorCutsceneKey(menu.detailmonitorCutsceneID))
	C.OpenMovieMenu(key)
end

function menu.onCutsceneStopped(_, cutsceneID)
	if cutsceneID == menu.cutsceneID then
		menu.onCloseElement()
	end
end

function menu.onShowMenu()
	local frame = Helper.createFrameHandle(menu, {
		x = 0,
		y = 0,
		width = Helper.viewWidth,
		height = Helper.viewHeight,
		layer = config.layer,
		standardButtons = { close = true },
	})

	fFrame:addTable(1, { tabOrder = 1 })
	
	frame:addRenderTarget({ width = Helper.viewWidth, height = Helper.viewHeight, x = 0, y = 0, alpha = 100 })

	frame:display()
end

function menu.viewCreated(layer, ...)
	if layer == config.layer then
		menu.rendertarget = ...
	end
end

function menu.onUpdate()
	if not menu.cutsceneID then
		menu.cutsceneID = C.PlayDetailmonitorCutscene(menu.detailmonitorCutsceneID, GetRenderTargetTexture(menu.rendertarget))
	end
end

function menu.onCloseElement(dueToClose)
	Helper.closeMenuAndCancel(menu, false)
	menu.cleanup()
end

init()
