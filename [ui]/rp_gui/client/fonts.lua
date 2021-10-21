--[[
	@project: dotGame
	@author: xkotori

	All rights reversed, rights also belongs to project and author.
--]]

-- Inicjalizacja klasy
local fonts = inherit(Singleton)

-- Początek klasy
function fonts:constructor()
	-- Zmienne
	self.AVAILABLE_FONTS = {} -- Nie ruszać tej tablicy! Ta tablica jest odpowiedzialna za uzyskiwanie czcionek!
	self.FONTS = {
		-- Light
		{NAME = "light_small", PATH = "assets/fonts/light.otf", SIZE = 12},
		{NAME = "light_normal", PATH = "assets/fonts/light.otf", SIZE = 16},
		{NAME = "light_big", PATH = "assets/fonts/light.otf", SIZE = 24},
		-- Regular
		{NAME = "regular_small", PATH = "assets/fonts/regular.ttf", SIZE = 12},
		{NAME = "regular_normal", PATH = "assets/fonts/regular.ttf", SIZE = 16},
		{NAME = "regular_big", PATH = "assets/fonts/regular.ttf", SIZE = 24},
		-- Semibold
		{NAME = "semibold_small", PATH = "assets/fonts/semibold.otf", SIZE = 12},
		{NAME = "semibold_normal", PATH = "assets/fonts/semibold.otf", SIZE = 16},
		{NAME = "semibold_big", PATH = "assets/fonts/semibold.otf", SIZE = 24},
		-- Bold
		{NAME = "bold_small", PATH = "assets/fonts/bold.otf", SIZE = 12},
		{NAME = "bold_normal", PATH = "assets/fonts/bold.otf", SIZE = 16},
		{NAME = "bold_big", PATH = "assets/fonts/bold.otf", SIZE = 24},
	}

	-- Inicjalizacja funkcji
	self:initialize()
end

function fonts:initialize() -- Inicjalizacja czcionek
	for _, DATA in ipairs(self.FONTS) do
		if File.exists(DATA.PATH) and not self.AVAILABLE_FONTS[DATA.NAME] then
			local font = DxFont(DATA.PATH, DATA.SIZE, false, "cleartype")

			if font then
				self.AVAILABLE_FONTS[DATA.NAME] = font
			end
		end
	end
end

function fonts:get(fontName) -- Uzyskiwanie czcionki
	return self.AVAILABLE_FONTS[fontName] or "default-bold"
end
-- Koniec klasy

--- FUNKCJA STARTOWA
local function RESOURCE_START()
	return fonts:constructor()
end
addEventHandler("onClientResourceStart", resourceRoot, RESOURCE_START)

--- FUNKCJE EKSPORTOWANE DO KLIENTA
function getFont(fontName)
	return fonts:get(fontName)
end