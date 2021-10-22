--[[
	@project: dotGame
	@author: xkotori

	All rights reversed, rights also belongs to project and author.
--]]

local screenW, screenH = guiGetScreenSize(  )

local blackwhite = inherit(Singleton)

function blackwhite:constructor()
	self.EFFECT_PATH = "assets/effects/blackwhite.fx"

	self.EFFECT = false
	self.SCREEN = false

	self:constructEffect()

	self.renderEffect = bind(self.render, self)

	if self.renderEffect then
		addEventHandler("onClientRender", root, self.renderEffect)
	end
end

function blackwhite:constructEffect()
	if not self.EFFECT then
		self.EFFECT = File.exists(self.EFFECT_PATH) and DxShader(self.EFFECT_PATH, 0, 0, false, "other") or false

		if self.EFFECT and not self.SCREEN then
			self.SCREEN = DxScreenSource(screenW, screenH)
		end
	end
end

function blackwhite:render()
	if not self.SCREEN or not self.EFFECT then return end

	self.SCREEN:update(true)
	self.EFFECT:setValue("screenSource", self.SCREEN)
end

function blackwhite:draw(x, y, w, h, color)
	if not self.SCREEN or not self.EFFECT then return end

	return dxDrawImageSection(x, y, w, h, x, y, w, h, self.EFFECT, 0, 0, 0, color or tocolor(255, 255, 255, 255), false)
end

-- start
local function RESOURCE_START()
	return blackwhite:constructor()
end
addEventHandler("onClientResourceStart", resourceRoot, RESOURCE_START)

-- Funkcje eksportowane
function drawBlackWhiteRectangle(...)
	return blackwhite:draw(...)
end