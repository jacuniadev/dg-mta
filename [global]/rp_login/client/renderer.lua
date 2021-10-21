--[[
	@project: dotGame
	@author: xkotori

	All rights reversed, rights also belongs to project and author.
--]]

-- Wymagane zasoby
local RESOURCE_GUI = exports["rp_gui"]
local RESOURCE_LOADING = exports["rp_loading"]

-- Sprawdzanie czy gracz jest zalogowany oraz czy postać jest zespawnowana
local LOGGED_STATE = localPlayer:getData("player:logged") or false
local SPAWNED_STATE = localPlayer:getData("character:spawned") or false

-- Wysokość, szerokość ekranu i skalowanie
local screenW, screenH = guiGetScreenSize(  )
local scale = 1920 / screenW

-- Inicjalizacja klasy
renderer = inherit(Singleton)

-- Początek klasy
function renderer:constructor()
	Camera:start()

	-- Ekran wczytywania
	if RESOURCE_LOADING:state() then
		RESOURCE_LOADING:destroy()
	end

	-- Elementy GTA:SA do wyłączenia
	self.SA_COMPONENTS = {"radar", "area_name", "vehicle_name"}
	self:switchMTAStuff()

	-- Bindowanie eventów
	self.RENDER = bind(self.render, self)

	addEventHandler("onClientRender", root, self.RENDER)
end

function renderer:switchMTAStuff()
	local CHAT_VISIBLE, CURSOR_VISIBLE = isChatVisible(), isCursorShowing()

	showChat(not CHAT_VISIBLE)
	showCursor(not CURSOR_VISIBLE)

	for _, COMPONENT in pairs(self.SA_COMPONENTS) do
		local COMPONENT_ENABLED = isPlayerHudComponentVisible(COMPONENT)

		if COMPONENT_ENABLED then
			setPlayerHudComponentVisible(COMPONENT, not COMPONENT_ENABLED)
		end
	end
end

function renderer:destructor()
	Camera:stop()
end

function renderer:render()
	if isChatVisible() then
		showChat(false)
	end

	Tabs:render()
end
-- Koniec klasy

--- FUNKCJA STARTOWA
local function RESOURCE_START()
	return renderer:constructor()
end
addEventHandler("onClientResourceStart", resourceRoot, RESOURCE_START)

--- FUNKCJA STOPOWANIA
local function RESOURCE_STOP()
	return renderer:destructor()
end
addEventHandler("onClientResourceStop",	resourceRoot, RESOURCE_STOP)