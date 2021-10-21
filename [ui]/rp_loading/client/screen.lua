--[[
	@project: dotGame
	@author: xkotori

	All rights reversed, rights also belongs to project and author.
--]]

-- Ekran (wysokość, szerokość) i skalowanie
local screenW, screenH = guiGetScreenSize(  )
local scale = 1920 / screenW

-- Zasoby wymagane
local RESOURCE_GUI = exports["rp_gui"]

-- Czy event handler jest nadany
local isEventHandlerAdded = function( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end

-- Zaokrąglony dxDrawRectangle
local dxDrawRoundedRectangle = function(x, y, w, h, bgColor, postGUI)
    if (x and y and w and h) then
        -- Background
        dxDrawRectangle(x, y, w, h, bgColor or tocolor(255, 255, 255, 255), postGUI)
        -- Border
        dxDrawRectangle(x + 2, y - 1, w - 4, 1, bgColor or tocolor(255, 255, 255, 255), postGUI)
		dxDrawRectangle(x + 2, y + h, w - 4, 1, bgColor or tocolor(255, 255, 255, 255), postGUI)
		dxDrawRectangle(x - 1, y + 2, 1, h - 4, bgColor or tocolor(255, 255, 255, 255), postGUI)
		dxDrawRectangle(x + w, y + 2, 1, h - 4, bgColor or tocolor(255, 255, 255, 255), postGUI)
    end
end

-- Inicjalizacja klasy
local screen = inherit(Singleton)

-- Początek klasy
function screen:constructor()
	-- Czcionki
	self.FONTS = {
		LOADING_TEXT = RESOURCE_GUI:getFont("bold_big")
	}

	-- Tekstury
	self.AVAILABLE_TEXTURES = {} -- Nie ruszać tej tablicy! Ta tablica jest odpowiedzialna za uzyskiwanie przetworzonych tekstur (images)!
	self.TEXTURES = {
		{NAME = "background", PATH = "assets/images/background.png"},
		{NAME = "loader", PATH = "assets/images/loader.png"},
		{NAME = "logo", PATH = "assets/images/logo.png"}
	}
	self:loadTextures()

	-- Widok
	self.SHOWING = false
	self.POSITIONS = {
		["logo"] = {
			x = 0,
			y = 0,
			width = 503/scale,
			height = 503/scale,
			type = "texture"
		},
		["background"] = {
			x = 0,
			y = 0,
			width = screenW,
			height = screenH,
			type = "texture"
		},
		["progress"] = {
			x = 0,
			y = 0,
			width = 520/scale,
			height = 24/scale
		}
	}

	-- Pozycjonowanie logo na środek
	self.POSITIONS["logo"].x = (screenW - self.POSITIONS["logo"].width) / 2
	self.POSITIONS["logo"].y = (screenH - self.POSITIONS["logo"].height) / 2 * 0.8

	-- Pozycjonowanie progress bar na środek
	self.POSITIONS["progress"].x = (screenW - self.POSITIONS["progress"].width) / 2
	self.POSITIONS["progress"].y = (screenH - self.POSITIONS["progress"].height) / 2 * 1.8

	-- Tekst
	self.TEXT = nil

	-- Animacja loadera
	self.LOADER = {
		DURATION = 400,
		SCALE_SIZE = 50,
		SIZE = 1.8,
		MAX = 2,
		LOADERS = {},
	}

	-- Animacja alpha
	self.GLOBAL_ALPHA = {
		DURATION = 250,
		CURRENT = 0,
		MIN = 0,
		MAX = 1,
		ANIMATION = false
	}

	-- Do rysowania progressbaru
	self.PROGRESS_BAR = {
		ENABLED = false,
		CURRENT = 0
	}
	
	-- Bindowanie eventów
	self.render = bind(self.draw, self)
end

function screen:destructor()
	self.SHOWING = false
	self.TEXT = nil
	self.GLOBAL_ALPHA.CURRENT = 0

	if not isChatVisible() then
		showChat(not isChatVisible())
	end

	if isCursorShowing() then
		showCursor(not isCursorShowing(), false)
	end

	self:destroyTextures()
	collectgarbage()
end

-- GLOBAL ALPHA
function screen:updateGlobalAlpha(from, to, onEndCallback)
	if not self.GLOBAL_ALPHA.ANIMATION then
		self.GLOBAL_ALPHA.ANIMATION = animations:create(from, to, "Linear", self.GLOBAL_ALPHA.DURATION,
			function(progress)
				self.GLOBAL_ALPHA.CURRENT = progress
			end,
			function()
				if self.GLOBAL_ALPHA.ANIMATION then
					self.GLOBAL_ALPHA.ANIMATION = false
				end

				if onEndCallback and type(onEndCallback) == "function" then
					onEndCallback()
				end
			end
		)
	end
end

-- SYSTEM TEKSTUR
function screen:loadTextures() -- wczytywanie tekstur
	for _, DATA in ipairs(self.TEXTURES) do
		if File.exists(DATA.PATH) and not self.AVAILABLE_TEXTURES[DATA.NAME] then
			local texture = DxTexture(DATA.PATH)

			if texture then
				self.AVAILABLE_TEXTURES[DATA.NAME] = texture
			end
		end
	end
end

function screen:destroyTextures() -- usuwanie tekstur
	for TEXTURE_NAME in pairs(self.AVAILABLE_TEXTURES) do
		if self.AVAILABLE_TEXTURES[TEXTURE_NAME] and isElement(self.AVAILABLE_TEXTURES[TEXTURE_NAME]) then
			if self.AVAILABLE_TEXTURES[TEXTURE_NAME]:destroy() then
				self.AVAILABLE_TEXTURES[TEXTURE_NAME] = nil
			end
		end
	end
end

-- RYSOWANIE
function screen:draw()
	if not self.SHOWING then return end

	-- anty-pokazywanie czatu podczas ukazywania ekranu
	if isChatVisible() then
		showChat(not isChatVisible())
	end

	-- rysowanie tekstur
	for POSITION_NAME, POSITION_DATA in pairs(self.POSITIONS) do
		if POSITION_DATA.type == "texture" then
			dxDrawImage(POSITION_DATA.x, POSITION_DATA.y, POSITION_DATA.width, POSITION_DATA.height, self.AVAILABLE_TEXTURES[POSITION_NAME], 0, 0, 0, tocolor(255, 255, 255, 255 * self.GLOBAL_ALPHA.CURRENT))
		end
	end

	-- rysowanie loadera
	for i = 1, self.LOADER.MAX do
		local progress = (getTickCount() - self.LOADER.LOADERS[i].TICK) / (self.LOADER.MAX * self.LOADER.DURATION)

		if progress >= 0 then
			self.LOADER.LOADERS[i].VALUE = interpolateBetween(0, 0, 0, 1, 0, 0, progress, "OutQuad")

			if progress >= 1 then
				self.LOADER.LOADERS[i].TICK = getTickCount()
				self.LOADER.LOADERS[i].VALUE = 0
			end

			local size = self.LOADER.SIZE * self.LOADER.LOADERS[i].VALUE
			local x, y = (self.POSITIONS.logo.x - (self.LOADER.SCALE_SIZE / scale * size) / 2), (self.POSITIONS.logo.y - (self.LOADER.SCALE_SIZE / scale * size) / 2) 

			dxDrawImage(
				x + 250/scale,
				y + 520/scale,
				self.LOADER.SCALE_SIZE / scale * size,
				self.LOADER.SCALE_SIZE / scale * size,
				self.AVAILABLE_TEXTURES.loader,
				0, 0, 0,
				tocolor(255, 255, 255, 255 * (1 - self.LOADER.LOADERS[i].VALUE) * self.GLOBAL_ALPHA.CURRENT)
			)
		end
	end

	-- rysowanie progressbara
	if self.PROGRESS_BAR.ENABLED then
		dxDrawRoundedRectangle(self.POSITIONS.progress.x, self.POSITIONS.progress.y, self.PROGRESS_BAR.CURRENT * (self.POSITIONS.progress.width / 100), self.POSITIONS.progress.height, tocolor(66, 84, 245, 255 * self.GLOBAL_ALPHA.CURRENT))
		dxDrawRoundedRectangle(self.POSITIONS.progress.x, self.POSITIONS.progress.y, self.POSITIONS.progress.width, self.POSITIONS.progress.height, tocolor(66, 84, 245, 155 * self.GLOBAL_ALPHA.CURRENT))
	end

	-- rysowanie tekstu
	dxDrawText(
		self.TEXT or "Tekst",
		0,
		screenH - 90,
		screenW,
		screenH,
		tocolor(255, 255, 255, 255 * self.GLOBAL_ALPHA.CURRENT),
		0.6 / scale,
		self.FONTS.LOADING_TEXT,
		"center",
		"center"
	)
end

-- PRZEŁĄCZANIE
function screen:setVisible()
	local chatShowing, cursorShowing = isChatVisible(), isCursorShowing()

	if self.GLOBAL_ALPHA.ANIMATION then return end

	if self.SHOWING then
		self:updateGlobalAlpha(self.GLOBAL_ALPHA.CURRENT, self.GLOBAL_ALPHA.MIN, function()
			if isEventHandlerAdded("onClientRender", root, self.render) then
				removeEventHandler("onClientRender", root, self.render)
			end

			if self.TEXT ~= nil then
				self.TEXT = nil
			end

			if self.PROGRESS_BAR.ENABLED then
				self.PROGRESS_BAR.ENABLED = false
				self.PROGRESS_BAR.CURRENT = 0
			end

			self.LOADER.LOADERS = {}
			self.SHOWING = not self.SHOWING

			if not chatShowing then
				showChat(not chatShowing)
			end

			if cursorShowing then
				showCursor(not cursorShowing, false)
			end
		end)
	else
		self:updateGlobalAlpha(self.GLOBAL_ALPHA.CURRENT, self.GLOBAL_ALPHA.MAX)
		
		showChat(not chatShowing)
		showCursor(not cursorShowing, true)

		if not isEventHandlerAdded("onClientRender", root, self.render) then
			addEventHandler("onClientRender", root, self.render)
		end

		for i = 1, self.LOADER.MAX do
			self.LOADER.LOADERS[i] = {
				VALUE = 0,
				TICK = getTickCount() - self.LOADER.DURATION * i
			}
		end
		self.SHOWING = not self.SHOWING
	end
end
-- Koniec klasy

--- FUNKCJA DO STARTOWANIA
local function RESOURCE_START()
	return screen:constructor()
end
addEventHandler("onClientResourceStart", resourceRoot, RESOURCE_START)

--- FUNKCJA DO ZATRZYMANIA
local function RESOURCE_STOP()
	return screen:destructor()
end
addEventHandler("onClientResourceStop", resourceRoot, RESOURCE_STOP)

--- FUNKCJE EKSPORTOWANE DO KLIENTA
function state()
	return screen.SHOWING
end

function show()
	if not screen.SHOWING then
		screen:setVisible()
	end
end

function destroy()
	if screen.SHOWING then
		screen:setVisible()
	end
end

function updateText(text)
	if screen.SHOWING then
		screen.TEXT = text
	end
end

function setProgressBarEnabled()
	screen.PROGRESS_BAR.ENABLED = not screen.PROGRESS_BAR.ENABLED
end

function updateProgressBar(progress)
	if screen.PROGRESS_BAR.ENABLED then
		screen.PROGRESS_BAR.CURRENT = progress
	end
end