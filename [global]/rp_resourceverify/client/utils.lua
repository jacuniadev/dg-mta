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

function utils:mathRound(num, decimal)
	local multipiler = 10 ^ (decimal or 0)

	return math.floor(num * multipiler + 0.5) / multipiler
end

function utils:humanFileSize(size)
	if size < 1024 then
		return ("%.2f B"):format(size)
	end

	local humanPilers = {"KB", "MB", "TB", "PB", "EB", "ZB", "YB"}
	local humanIndex = math.floor(math.log(size) / math.log(1024))
	local num = size / math.pow(1024, humanIndex)
	local round = self:mathRound(num, 2)

	num = round < 10 and self:mathRound(num, 2) or round < 100 and self:mathRound(num, 1) or round

	return ("%.2f %s"):format(num, humanPilers[humanIndex])
end
-- Koniec klasy