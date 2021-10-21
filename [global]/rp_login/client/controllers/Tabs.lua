--[[
	@project: dotGame
	@author: xkotori

	All rights reversed, rights also belongs to project and author.
--]]

local screenW, screenH = guiGetScreenSize()
local scale = 1920 / screenW

Tabs = inherit(Singleton)

function Tabs:constructor()
	self.TABS_WORKERS = {
		["Intro"] = IntroTab
	}

	self.TABS = {
		ALPHA = 1,
		ACTIVE = "Intro",
		EASING_ANIMATION = "OutQuad",
		CHANGE_AFTER = 500
	}
end

function Tabs:onTabEnter(tabName)
	if not self.TABS.AVAILABLE[tabName] then return end
	if self.TABS.ACTIVE ~= tabName then return end

	self:onTabLeave(self.TABS.ACTIVE, function()
		animations:create(0, 1, "InOutQuad", 250, function(progress)
			self.TABS.ALPHA = progress
		end)
	end)
end

function Tabs:onTabLeave(tabName, cb)
	if not self.TABS.AVAILABLE[tabName] then return end
	if self.TABS.ACTIVE ~= tabName then return end

	animations:create(1, 0, "InOutQuad", 250,
		function(progress)
			self.TABS.ALPHA = progress
		end,
		function()
			return cb()
		end
	)
end

function Tabs:render()
	local TAB = self.TABS_WORKERS[self.TABS.ACTIVE]

	if TAB then
		return TAB:render(self.TABS.ALPHA)
	end
end

Tabs:constructor()