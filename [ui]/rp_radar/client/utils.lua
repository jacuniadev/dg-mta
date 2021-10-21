--[[
	@project: dotGame
	@author: xkotori, WaRuS

	Special thanks to WaRuS, that he help with blips n' more stuff.
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

function utils:findRotation(x1, y1, x2, y2)
    local t = -math.deg(math.atan2(x2 - x1, y2 - y1))

    return t < 0 and t + 360 or t
end

function utils:getPointFromDistanceRotation(x, y, distance, angle)
    local a = math.rad(90 - angle)
    local dx = math.cos(a) * distance
    local dy = math.sin(a) * distance

    return x + dx, y + dy
end
-- Koniec klasy