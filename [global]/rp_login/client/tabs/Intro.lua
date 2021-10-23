--[[
	@project: dotGame
	@author: xkotori

	All rights reversed, rights also belongs to project and author.
--]]

local screenW, screenH = guiGetScreenSize()
local scale = 1920 / screenW

IntroTab = inherit(Singleton)

function IntroTab:constructor()
	self.TAB_NAME = "Intro"
	self.TAB_CHANGING = false

	self.TEXTURES = {
		logo = Textures:getTexture("logo")
	}
	
	self.LOGO_SIZE = 423/scale
	self.SCALE = 1.3
end

function IntroTab:destructor()
	if self.TAB_CHANGING then
		self.TAB_CHANGING = not self.TAB_CHANGING

		self.SCALE = 1.2
	end
end

function IntroTab:render(alpha)
	if self.SCALE < 1.05 and not self.TAB_CHANGING then
		self.TAB_CHANGING = not self.TAB_CHANGING

		Tabs:TabLeave(self.TAB_NAME, function()
			Tabs:TabEnter("Main")

			self:destructor()
		end)
	end

	self.SCALE = self.SCALE - 0.00042

	local x, y, w, h = (screenW - self.LOGO_SIZE * self.SCALE) / 2, (screenH - self.LOGO_SIZE * self.SCALE) / 2, self.LOGO_SIZE * self.SCALE, self.LOGO_SIZE * self.SCALE

	dxDrawImage(
		x, y,
		w, h,
		self.TEXTURES.logo,
		0, 0, 0,
		tocolor(255, 255, 255, 255 * alpha)
	)
end

IntroTab:constructor()