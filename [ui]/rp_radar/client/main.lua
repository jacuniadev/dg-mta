--[[
	@project: dotGame
	@author: xkotori, WaRuS

	Special thanks to WaRuS, that he help with blips n' more stuff.
	All rights reversed, rights also belongs to project and author.
--]]

-- Ekran (wysokość, szerokość) i skalowanie
local screenW, screenH = guiGetScreenSize(  )
local scale = 1900 / screenW

-- Zasoby wymagane
local RESOURCE_GUI = exports["rp_gui"]

-- Inicjalizacja klasy
local main = inherit(Singleton)

-- Początek klasy
function main:constructor()
	-- Czcionki
	self.FONTS = {
		city_bold_big = RESOURCE_GUI:getFont("bold_big"),
		zone_regular_normal = RESOURCE_GUI:getFont("regular_normal")
	}

	-- Ścieżki
	self.PATHS = {
		blips = "assets/images/blips", -- Ścieżka do blipów
		shaders = "assets/shaders", -- Ścieżka do shaderów
		other = "assets/images" -- Ścieżka do pozostałości
	}
	
	-- Widok
	self.SHOWING = false

	-- Ustawienia radaru
	self.RADAR_ZONE_DATA = {
		zone = nil,
		zoneAlpha = 0,
		city = nil,
		cityAlpha = 0
	}
	self.RADAR_ANIMATIONS = {}
	self.RADAR_HUD_COMPONENTS = {"area_name", "vehicle_name", "radar"}
	self.RADAR_BLIP_SIZE = 23/scale
	self.RADAR_SIZE = 6000
	self.RADAR_POS = {
		x = screenW / 3 - 600/scale,
		y = screenH / 1 - 350/scale,
		width = 300/scale,
		height = 300/scale
	}
	self.RADAR_POS.left = self.RADAR_POS.x + self.RADAR_POS.width / 2
	self.RADAR_POS.top = self.RADAR_POS.y + self.RADAR_POS.height / 2

	-- Animacja alpha
	self.GLOBAL_ALPHA = {
		DURATION = 250,
		CURRENT = 0,
		MIN = 0,
		MAX = 1,
		ANIMATION = false
	}

	-- Tekstury
	self.AVAILABLE_TEXTURES = {} -- Nie ruszać tej tablicy! Ta tablica jest odpowiedzialna za uzyskiwanie przetworzonych tekstur!
	self.TEXTURES = {
		{NAME = "mask", PATH = self.PATHS.other .. "/mask.png"}, -- Maska
		{NAME = "background", PATH = self.PATHS.other .. "/background.png"}, -- Background
		{NAME = "background_zone", PATH = self.PATHS.other .. "/background_zone.png"}, -- Background 2
		{NAME = "map", PATH = self.PATHS.other .. "/map.png"}, -- Mapa
		{NAME = "arrow", PATH = self.PATHS.blips .. "/arrow.png"} -- Strzała (PogU)
	}
	self:loadTextures()
	self:loadBlipsTextures()

	-- Maskowanie
	self.RADAR_MASKED = DxShader(self.PATHS.shaders .. "/hud_mask.fx")
	self.RADAR_MASKED:setValue("sPicTexture", self.AVAILABLE_TEXTURES.map)
	self.RADAR_MASKED:setValue("sMaskTexture", self.AVAILABLE_TEXTURES.mask)
	self.RADAR_MASKED:setValue("gUVScale", 0.1, 0.1)

	-- Bindowanie eventów
	self.render = bind(self.draw, self)
end

function main:destructor()
	if self.SHOWING then
		self.SHOWING = false
		self.GLOBAL_ALPHA.CURRENT = 0

		self:setHudComponentsVisibility()
	end
	
	if self.RADAR_MASKED and isElement(self.RADAR_MASKED) then
		if self.RADAR_MASKED:destroy() then
			self.RADAR_MASKED = nil
		end
	end

	self:destroyAllTextures()

	collectgarbage()
end

-- GLOBAL ALPHA
function main:updateGlobalAlpha(from, to, onEndCallback)
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
function main:loadBlipsTextures()
	-- TODO: skanowanie folderu z blipami (własny moduł pod to)

	for i = 0, 65 do
		local BLIP_PATH = ("%s/%s"):format(self.PATHS.blips, i .. ".png")
		local BLIP_TEXTURE_NAME = ("blip_%d"):format(i)

		if File.exists(BLIP_PATH) and not self.AVAILABLE_TEXTURES[BLIP_TEXTURE_NAME] then
			local texture = DxTexture(BLIP_PATH)

			if texture then
				self.AVAILABLE_TEXTURES[BLIP_TEXTURE_NAME] = texture
			end
		end
	end
end

function main:loadTextures()
	for _, DATA in ipairs(self.TEXTURES) do
		if File.exists(DATA.PATH) and not self.AVAILABLE_TEXTURES[DATA.NAME] then
			local texture = DxTexture(DATA.PATH)

			if texture then
				self.AVAILABLE_TEXTURES[DATA.NAME] = texture
			end
		end
	end
end

function main:destroyAllTextures()
	for TEXTURE_NAME in pairs(self.AVAILABLE_TEXTURES) do
		if self.AVAILABLE_TEXTURES[TEXTURE_NAME] and isElement(self.AVAILABLE_TEXTURES) then
			if self.AVAILABLE_TEXTURES[TEXTURE_NAME]:destroy() then
				self.AVAILABLE_TEXTURES[TEXTURE_NAME] = nil
			end
		end
	end
end

-- RYSOWANIE
function main:drawBlips(playerPosition, playerRotation, cameraRotation, cameraMatrix)
	if not self.SHOWING then return end

	local north = utils:findRotation(cameraMatrix[1], cameraMatrix[2], cameraMatrix[4], cameraMatrix[5])
	local blipNorth = 180 - north

	for _, blip in ipairs(getElementsByType("blip")) do
		local blipIcon = blip.icon
		local blipPosition = Vector3(blip.position)
		local blipDistance, blipMaxDistance = getDistanceBetweenPoints2D(playerPosition.x, playerPosition.y, blipPosition.x, blipPosition.y), blip.visibleDistance

		if blipDistance < blipMaxDistance then
			if blipDistance > self.RADAR_POS.width then
				blipDistance = self.RADAR_POS.width
			end

			local blipAngle = blipNorth + utils:findRotation(playerPosition.x, playerPosition.y, blipPosition.x, blipPosition.y)
			local blipX, blipY = utils:getPointFromDistanceRotation(0, 0, self.RADAR_POS.height * (blipDistance / self.RADAR_POS.width) / 2, blipAngle)

			local blipX = self.RADAR_POS.left + blipX - (self.RADAR_BLIP_SIZE / 2)
			local blipY = self.RADAR_POS.top + blipY - (self.RADAR_BLIP_SIZE / 2)

			dxDrawImage(blipX, blipY, self.RADAR_BLIP_SIZE, self.RADAR_BLIP_SIZE, self.AVAILABLE_TEXTURES[("blip_%d"):format(blipIcon)], north - cameraRotation.z, 0, 0, tocolor(255, 255, 255, 255 * self.GLOBAL_ALPHA.CURRENT))
		end
	end

	dxDrawImage(
		(self.RADAR_POS.x + (self.RADAR_POS.width / 2)) - 11.2,
		(self.RADAR_POS.y + (self.RADAR_POS.height / 2)) - 10,
		30/scale, 30/scale,
		self.AVAILABLE_TEXTURES["arrow"],
		cameraRotation.z - playerRotation.z,
		0, 0,
		tocolor(255, 255, 255, 255 * self.GLOBAL_ALPHA.CURRENT)
	)
end

function main:drawZone(playerPosition)
	if not self.SHOWING then return end

	local city = getZoneName(playerPosition.x, playerPosition.y, playerPosition.z, true)
	local zone = getZoneName(playerPosition.x, playerPosition.y, playerPosition.z)

	if self.RADAR_ZONE_DATA.zone ~= zone and not self.RADAR_ANIMATIONS.zoneAnim then
		self.RADAR_ANIMATIONS.zoneAnim = animations:create(self.RADAR_ZONE_DATA.zoneAlpha, 1, "Linear", 200,
			function(progress)
				self.RADAR_ZONE_DATA.zoneAlpha = progress
			end,
			function()
				self.RADAR_ZONE_DATA.zone = zone

				if self.RADAR_ANIMATIONS.zoneAnim then
					self.RADAR_ANIMATIONS.zoneAnim = animations:create(self.RADAR_ZONE_DATA.zoneAlpha, 0, "Linear", 200, 
						function(progress)
							self.RADAR_ZONE_DATA.zoneAlpha = progress
						end,
						function()
							self.RADAR_ANIMATIONS.zoneAnim = false
						end
					)
				end
			end
		)
	end

	if self.RADAR_ZONE_DATA.city ~= city and not self.RADAR_ANIMATIONS.cityAnim then
		self.RADAR_ANIMATIONS.cityAnim = animations:create(self.RADAR_ZONE_DATA.cityAlpha, 1, "Linear", 200,
			function(progress)
				self.RADAR_ZONE_DATA.cityAlpha = progress
			end,
			function()
				self.RADAR_ZONE_DATA.city = city

				if self.RADAR_ANIMATIONS.cityAnim then
					self.RADAR_ANIMATIONS.cityAnim = animations:create(self.RADAR_ZONE_DATA.cityAlpha, 0, "Linear", 200, 
						function(progress)
							self.RADAR_ZONE_DATA.cityAlpha = progress
						end,
						function()
							self.RADAR_ANIMATIONS.cityAnim = false
						end
					)
				end
			end
		)
	end

	dxDrawImage(
		self.RADAR_POS.x, self.RADAR_POS.y,
		self.RADAR_POS.width, self.RADAR_POS.height,
		self.AVAILABLE_TEXTURES["background_zone"],
		0, 0, 0,
		tocolor(255, 255, 255, 255 * self.GLOBAL_ALPHA.CURRENT)
	)
	dxDrawText(
		self.RADAR_ZONE_DATA.zone or "Wczytuje",
		self.RADAR_POS.x + 35/scale,
		self.RADAR_POS.y + (self.RADAR_POS.height / 1.30),
		self.RADAR_POS.width, self.RADAR_POS.height,
		tocolor(200, 200, 200, 255 * (1 - self.RADAR_ZONE_DATA.zoneAlpha) * self.GLOBAL_ALPHA.CURRENT),
		0.67/scale, self.FONTS.zone_regular_normal,
		"center", "top"
	)
	dxDrawText(
		self.RADAR_ZONE_DATA.city or "Wczytuje",
		self.RADAR_POS.x + 35/scale,
		self.RADAR_POS.y + (self.RADAR_POS.height / 1.20),
		self.RADAR_POS.width, self.RADAR_POS.height,
		tocolor(200, 200, 200, 255 * (1 - self.RADAR_ZONE_DATA.cityAlpha) * self.GLOBAL_ALPHA.CURRENT),
		0.56/scale, self.FONTS.city_bold_big,
		"center", "top"
	)
end

function main:draw()
	if not self.SHOWING then return end
	if not isElement(self.RADAR_MASKED) then return end

	local playerCamera = getCamera()
	local cameraMatrix = {getCameraMatrix()}

	local playerPosition, playerRotation = Vector3(localPlayer.position), Vector3(localPlayer.rotation)

	local cameraRotation = Vector3(playerCamera.rotation)
	self.RADAR_MASKED:setValue("gUVRotAngle", math.rad(-cameraRotation.z))

	local radarX, radarY = (playerPosition.x) / self.RADAR_SIZE, (playerPosition.y) / -self.RADAR_SIZE
	self.RADAR_MASKED:setValue("gUVPosition", radarX, radarY)

	dxDrawImage(
		self.RADAR_POS.x, self.RADAR_POS.y,
		self.RADAR_POS.width, self.RADAR_POS.height,
		self.AVAILABLE_TEXTURES["background"],
		0, 0, 0,
		tocolor(255, 255, 255, 225 * self.GLOBAL_ALPHA.CURRENT)
	)
	dxDrawImage(
		self.RADAR_POS.x, self.RADAR_POS.y,
		self.RADAR_POS.width, self.RADAR_POS.height,
		self.RADAR_MASKED,
		0, 0, 0,
		tocolor(255, 255, 255, 255 * self.GLOBAL_ALPHA.CURRENT)
	)

	self:drawBlips(playerPosition, playerRotation, cameraRotation, cameraMatrix)
	self:drawZone(playerPosition)
end

-- Ustawienie widoczności
function main:setHudComponentsVisibility()
	for _, COMPONENT in ipairs(self.RADAR_HUD_COMPONENTS) do
		local COMPONENT_ENABLED = isPlayerHudComponentVisible(COMPONENT)

		setPlayerHudComponentVisible(COMPONENT, not COMPONENT_ENABLED)
	end
end

function main:setVisible()
	if self.GLOBAL_ALPHA.ANIMATION then return end

	if self.SHOWING then
		self:updateGlobalAlpha(self.GLOBAL_ALPHA.CURRENT, self.GLOBAL_ALPHA.MIN, function()
			self:setHudComponentsVisibility()

			if utils:isEventHandlerAdded("onClientRender", root, self.render) then
				removeEventHandler("onClientRender", root, self.render)
			end
			
			self.SHOWING = not self.SHOWING
		end)
	else
		self:setHudComponentsVisibility()
		self:updateGlobalAlpha(self.GLOBAL_ALPHA.CURRENT, self.GLOBAL_ALPHA.MAX)

		if not utils:isEventHandlerAdded("onClientRender", root, self.render) then
			addEventHandler("onClientRender", root, self.render)
		end

		self.SHOWING = not self.SHOWING
	end
end

-- Koniec klasy

--- FUNKCJA DO STARTOWANIA
local function RESOURCE_START()
	return main:constructor()
end
addEventHandler("onClientResourceStart", resourceRoot, RESOURCE_START)

--- FUNKCJA DO ZATRZYMANIA
local function RESOURCE_STOP()
	return main:destructor()
end
addEventHandler("onClientResourceStop", resourceRoot, RESOURCE_STOP)

--- FUNKCJE EKSPORTOWANE DO KLIENTA
function state()
	return main.SHOWING
end

function show()
	if not main.SHOWING then
		main:setVisible()
	end
end

function destroy()
	if main.SHOWING then
		main:setVisible()
	end
end