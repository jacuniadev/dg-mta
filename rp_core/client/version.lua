--[[
	@project: dotGame
	@author: xkotori

	All rights reversed, rights also belongs to project and author.
--]]

-- Wysokość i szerokość ekranu
local screenW, screenH = guiGetScreenSize(  )

-- Inicjalizacja klasy
local version = inherit(Singleton)

-- Początek klasy
function version:constructor()
	self.PROJECT_NAME = "dotGame Roleplay"
	self.VERSION = {
		MAJOR = 1,
		MINOR = 0,
		PATCH = 0
	}
	self.VERSION.BUILD = 1000
	self.VERSION.STRING = ("%s\nwersja deweloperska %s, build %.4d"):format(self.PROJECT_NAME, string.format("%d.%d.%d", self.VERSION.MAJOR, self.VERSION.MINOR, self.VERSION.PATCH), self.VERSION.BUILD)

	-- bindowanie eventu
	self.render = bind(self.draw, self)

	-- nadawanie eventu
	addEventHandler("onClientRender", root, self.render, true, "low-1")
end

function version:draw()
	dxDrawText(self.VERSION.STRING, 0, 0, screenW, screenH - 15, tocolor(200, 200, 200, 110), 1, "default", "right", "bottom")
end
-- Koniec klasy

--- FUNKCJA STARTOWA
local function RESOURCE_START()
	return version:constructor()
end
addEventHandler("onClientResourceStart", resourceRoot, RESOURCE_START)