--[[
	@project: dotGame
	@author: xkotori

	All rights reversed, rights also belongs to project and author.
--]]

local data = exports["G_DATA"]

local screenW, screenH = guiGetScreenSize()

Camera = inherit(Singleton)

function Camera:constructor()
	self.CAMERA = {
		CHANGING = false,
		SELECTED = 1,
		TICK = 0,
		ALPHA = 0
	}

	self.CAMERAS = data:get("login_cameras")
	
	self.CAMERA.ELEMENT = getCamera()
	self.CAMERA.RENDER = bind(self.render, self)
end

function Camera:start()
	self.CAMERA.TICK = getTickCount()
	self.CAMERA.SELECTED = math.random(1, #self.CAMERAS)
	self.CAMERA.ALPHA = 0

	if not utils:isEventHandlerAdded("onClientPreRender", root, self.CAMERA.RENDER) then
		addEventHandler("onClientPreRender", root, self.CAMERA.RENDER)
	end

	setFarClipDistance(2000)
end

function Camera:stop()
	if utils:isEventHandlerAdded("onClientPreRender", root, self.CAMERA.RENDER) then
		removeEventHandler("onClientPreRender", root, self.CAMERA.RENDER)
	end

	resetFarClipDistance()
end

function Camera:change()
	if self.CAMERA.CHANGING then return end

	self.CAMERA.CHANGING = not self.CAMERA.CHANGING

	animations:create(0, 1, "InOutQuad", 3000, function(progress)
		self.CAMERA.ALPHA = progress
	end)

	setTimer(function()
		self.CAMERA.CHANGING = not self.CAMERA.CHANGING

		self.CAMERA.TICK = getTickCount()
		self.CAMERA.SELECTED = self.CAMERA.SELECTED + 1

		if self.CAMERA.SELECTED > #self.CAMERAS then
			self.CAMERA.SELECTED = 1
		end

		animations:create(1, 0, "InOutQuad", 3000, function(progress)
			self.CAMERA.ALPHA = progress
		end)
	end, 3000, 1)
end

function Camera:render()
	dxDrawRectangle(0, 0, screenW, screenH, tocolor(0, 0, 0, 255 * self.CAMERA.ALPHA))

	local now = getTickCount()

	if self.CAMERA.ELEMENT and isElement(self.CAMERA.ELEMENT) then
		local selectedCameraData = self.CAMERAS[self.CAMERA.SELECTED]
		local progress = math.min(1, (now - self.CAMERA.TICK) / selectedCameraData.time)

		local x, y, z = interpolateBetween(selectedCameraData.start.position.x, selectedCameraData.start.position.y, selectedCameraData.start.position.z, selectedCameraData.finish.position.x, selectedCameraData.finish.position.y, selectedCameraData.finish.position.z, progress, selectedCameraData.easing)
		local rx, ry, rz = interpolateBetween(selectedCameraData.start.rotation.x, selectedCameraData.start.rotation.y, selectedCameraData.start.rotation.z, selectedCameraData.finish.rotation.x, selectedCameraData.finish.rotation.y, selectedCameraData.finish.rotation.z, progress, selectedCameraData.easing)

		setElementPosition(self.CAMERA.ELEMENT, x, y, z)
		setElementRotation(self.CAMERA.ELEMENT, rx, ry, rz)

		if progress > 0.85 then
			self:change()
		end
	end
end

Camera:constructor()