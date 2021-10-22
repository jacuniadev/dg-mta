--[[
	@project: dotGame
	@author: xkotori

	All rights reversed, rights also belongs to project and author.
--]]

local screenW, screenH = guiGetScreenSize()
local scale = 1920 / screenW

IntroTab = inherit(Singleton)

function IntroTab:constructor()
	self.TEXTURES = {
		logo = Textures:getTexture("logo")
	}
	self.SCALE = 50

	self.LOGO_SIZE = 423/scale
	self.LOGO_POS = Vector2((screenW - self.LOGO_SIZE) / 2, (screenH - self.LOGO_SIZE) / 2)
end

function IntroTab:render(alpha)
	dxDrawImage(self.LOGO_POS.x, self.LOGO_POS.y, self.LOGO_SIZE, self.LOGO_SIZE, self.TEXTURES.logo, 0, 0, 0, tocolor(255, 255, 255, 255 * alpha))
end

IntroTab:constructor()