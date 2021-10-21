--[[
	@project: dotGame
	@author: xkotori <github.com/xkotori>

	All rights reversed, rights also belongs to project and author.
--]]

Music = inherit(Singleton)

function Music:constructor()
	self.MUSIC_PATH = "assets/sounds/intro.mp3" -- v.h.s porter master.wav
	self.MUSIC_VOLUME = 1

	self.MUSIC_LOOP = true
	self.MUSIC_TRANSITION = false
	self.MUSIC = false

	self:play()
end

function Music:play()
	if not self.MUSIC then
		self.MUSIC = File.exists(self.MUSIC_PATH) and Sound(self.MUSIC_PATH) or false

		if self.MUSIC and isElement(self.MUSIC) then
			self.MUSIC:setVolume(self.MUSIC_VOLUME)
			self.MUSIC:setLooped(self.MUSIC_LOOP)
		end
	end
end

function Music:switch()
	if self.MUSIC and isElement(self.MUSIC) then
		self.MUSIC_TRANSITION = animations:create(self.MUSIC_VOLUME, 0, "Linear", 5 * 1000,
			function(progress)
				self.MUSIC_VOLUME = progress

				self.MUSIC:setVolume(self.MUSIC_VOLUME)
			end,
			function()
				if self.MUSIC_TRANSITION then
					self.MUSIC_TRANSITION = false

					if self.MUSIC:stop() then
						self.MUSIC = false
						self.MUSIC_VOLUME = 1
					end
				end
			end
		)
	else
		return self:play()
	end
end

function Music:getInstance()
	return self.MUSIC
end

Music:constructor()