--[[
	@project: dotGame
	@author: xkotori

	All rights reversed, rights also belongs to project and author.
--]]

Textures = inherit(Singleton)

function Textures:constructor()
	self.AVAILABLE_TEXTURES = {}
	self.TEXTURES = {
		{NAME = "logo", PATH = "assets/images/logo.png"},
		{NAME = "background", PATH = "assets/images/background.png"}
	}

	self:createAllTextures()
end

function Textures:destructor()
	return self:destroyAllTextures()
end

function Textures:createAllTextures()
	for _, TEXTURE_DATA in ipairs(self.TEXTURES) do
		if not self.AVAILABLE_TEXTURES[TEXTURE_DATA.NAME] then
			if File.exists(TEXTURE_DATA.PATH) then
				local TEXTURE = DxTexture(TEXTURE_DATA.PATH)

				if TEXTURE and isElement(TEXTURE) then
					self.AVAILABLE_TEXTURES[TEXTURE_DATA.NAME] = TEXTURE
				end
			end
		end
	end
end

function Textures:destroyAllTextures()
	for TEXTURE_NAME in pairs(self.AVAILABLE_TEXTURES) do
		if self.AVAILABLE_TEXTURES[TEXTURE_NAME] and isElement(self.AVAILABLE_TEXTURES[TEXTURE_NAME]) then
			if self.AVAILABLE_TEXTURES[TEXTURE_NAME]:destroy() then
				self.AVAILABLE_TEXTURES[TEXTURE_NAME] = nil
			end
		end
	end
end

function Textures:getTexture(textureName)
	return self.AVAILABLE_TEXTURES[textureName] or nil
end

Textures:constructor()

local function RESOURCE_STOP()
	return Textures:destructor()
end
addEventHandler("onClientResourceStop",	resourceRoot, RESOURCE_STOP)