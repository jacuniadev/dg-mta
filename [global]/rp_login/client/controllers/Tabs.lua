--[[
	@project: dotGame
	@author: xkotori

	All rights reversed, rights also belongs to project and author.
--]]

local screenW, screenH = guiGetScreenSize()
local scale = 1920 / screenW

local DEBUG = true

Tabs = inherit(Singleton)

function Tabs:constructor()
	self.TABS_WORKERS = {
		["Nothing"] = nil,
		["Intro"] = IntroTab,
		["Main"] = MainTab
	}

	self.TABS = {
		ALPHA = 0,
		ACTIVE = "Nothing",
		EASING_ANIMATION = "OutQuad",
		CHANGE_AFTER = 700
	}
end

function Tabs:TabEnter(tabName)
	if not self.TABS_WORKERS[tabName] then return end
	if self.TABS.ACTIVE == tabName then return end

	self.TABS.ACTIVE = tabName

	animations:create(self.TABS.ALPHA, 1, self.TABS.EASING_ANIMATION, self.TABS.CHANGE_AFTER, function(progress)
		self.TABS.ALPHA = progress
	end)
end

function Tabs:TabLeave(tabName, cb)
	if not self.TABS_WORKERS[tabName] then return end
	if self.TABS.ACTIVE ~= tabName then return end

	animations:create(self.TABS.ALPHA, 0, self.TABS.EASING_ANIMATION, self.TABS.CHANGE_AFTER,
		function(progress)
			self.TABS.ALPHA = progress
		end,
		function()
			return cb()
		end
	)
end

function Tabs:render()
	if DEBUG then
		dxDrawText(([[
			aktywny: %s
			typ animacji (easing): %s
			czas animacji (delay): %d
			alpha: %.3f
		]]):format(self.TABS.ACTIVE, self.TABS.EASING_ANIMATION, self.TABS.CHANGE_AFTER, self.TABS.ALPHA), 300, 400)
	end

	local TAB = self.TABS_WORKERS[self.TABS.ACTIVE]

	if TAB then
		return TAB:render(self.TABS.ALPHA)
	end
end

Tabs:constructor()