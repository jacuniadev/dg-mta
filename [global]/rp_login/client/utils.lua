--[[
	@project: dotGame
	@author: xkotori
	
	All rights reversed, rights also belongs to project and author.
--]]

-- Inicjalizacja klasy
utils = inherit(Singleton)

-- Początek klasy
function utils:isEventHandlerAdded(eventName, attachedTo, funct)
	if type(eventName) == "string" and isElement(attachedTo) and type(funct) == "function" then
		local attachedFunctions = getEventHandlers(eventName, attachedTo)

		if type(attachedFunctions) == "table" and #attachedFunctions > 0 then
			for _, attachedFunction in pairs(attachedFunctions) do
				if attachedFunction == funct then
					return true
				end
			end
		end
	end

	return false
end
-- Koniec klasy