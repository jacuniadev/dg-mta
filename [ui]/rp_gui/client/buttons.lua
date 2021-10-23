--[[
	@project: dotGame
	@author: xkotori

	All rights reversed, rights also belongs to project and author.
--]]

local buttons = inherit(Singleton)

function buttons:constructor()
	addEvent("GUIClickButton", true)
	addEvent("GUIHoverButton", true)

	self.BUTTON_ELEMENTDATA_NAME = "buttonData"
	self.BUTTON_CLICKED = false
	self.BUTTON_ACTIVE = false
	self.BUTTON_PREVIOUS_ACTIVE = false
	self.BUTTON_ID = 0
end

function buttons:create(x, y, width, height)
	assert(x and y and width and height, "Arguments leak")

	if x and y and width and height then
		self.BUTTON_ID = self.BUTTON_ID + 1
		
		local element = createElement("button", ("button_%d"):format(self.BUTTON_ID))

		if element then
			element:setData(self.BUTTON_ELEMENTDATA_NAME, {
				position = {
					x = x,
					y = y,
				},
				size = {
					width = width,
					height = height,
				},
				alignment = {
					horizon = "center",
					vertical = "center"
				},
				font = {
					font = "default-bold",
					scale = 1
				},
				isAvailable = true
			}, false)
		end

		return element and element or false
	end
end

function buttons:destroy(buttonElement)
	if buttonElement and isElement(buttonElement) then
		if buttonElement.type == "button" then
			return buttonElement:destroy()
		end

		return false
	end

	return false
end

function buttons:getData(buttonElement, data)
	if buttonElement and isElement(buttonElement) then
		if buttonElement.type == "button" then
			local buttonData = buttonElement:getData(self.BUTTON_ELEMENTDATA_NAME) or false

			if buttonData then
				if not data then
					return buttonData
				else
					return buttonData[data]
				end
			end

			return false
		end

		return false
	end

	return false
end

function buttons:setAvailable(buttonElement, bool)
	assert(type(bool) == "boolean", ("bool is not boolean (got %s)"):format(type(bool)))

	if buttonElement and isElement(buttonElement) then
		if buttonElement.type == "button" then
			local buttonData = buttonElement:getData(self.BUTTON_ELEMENTDATA_NAME) or false

			if buttonData then
				buttonData.isAvailable = bool

				buttonData:setData(self.BUTTON_ELEMENTDATA_NAME, buttonData, false)
			end

			return false
		end

		return false
	end

	return false
end