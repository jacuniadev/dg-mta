--[[
	@project: dotGame
	@author: xkotori

	All rights reversed, rights also belongs to project and author.
--]]

local RESOURCE_GUI = exports["rp_gui"]
local RESOURCE_LOADING = exports["rp_loading"]

local LOGGED_STATE = localPlayer:getData("player:logged") or false
local SPAWNED_STATE = localPlayer:getData("character:spawned") or false

local screenW, screenH = guiGetScreenSize(  )
local scale = 1920 / screenW

renderer = inherit(Singleton)

function renderer:constructor()
	Camera:start()

	if RESOURCE_LOADING:state() then
		RESOURCE_LOADING:destroy()
	end

	self.SA_COMPONENTS = {"radar", "area_name", "vehicle_name"}

	for _, COMPONENT in pairs(self.SA_COMPONENTS) do
		local COMPONENT_ENABLED = isPlayerHudComponentVisible(COMPONENT)

		if COMPONENT_ENABLED then
			setPlayerHudComponentVisible(COMPONENT, false)
		end
	end

	local CHAT_VISIBLE, CURSOR_VISIBLE = isChatVisible(), isCursorShowing()

	showChat(not CHAT_VISIBLE)
	showCursor(not CURSOR_VISIBLE)

	self.RENDER = bind(self.render, self)
	addEventHandler("onClientRender", root, self.RENDER)

	Tabs:TabEnter("Intro")
end

function renderer:destructor()
	Camera:stop()

	for _, COMPONENT in pairs(self.SA_COMPONENTS) do
		local COMPONENT_ENABLED = isPlayerHudComponentVisible(COMPONENT)

		if not COMPONENT_ENABLED then
			setPlayerHudComponentVisible(COMPONENT, true)
		end
	end

	setCameraTarget(getLocalPlayer())
end

function renderer:render()
	if isChatVisible() then
		showChat(not isChatVisible())
	end

	RESOURCE_GUI:drawBlackWhiteRectangle(0, 0, screenW, screenH)

	Tabs:render()
end

local function RESOURCE_START()
	return renderer:constructor()
end
addEventHandler("onClientResourceStart", resourceRoot, RESOURCE_START)

local function RESOURCE_STOP()
	return renderer:destructor()
end
addEventHandler("onClientResourceStop",	resourceRoot, RESOURCE_STOP)