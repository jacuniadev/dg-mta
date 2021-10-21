--[[
	@project: dotGame
	@author: xkotori

	All rights reversed, rights also belongs to project and author.
--]]

-- Czy event handler jest dodany
local isEventHandlerAdded = function( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end

-- Inicjalizacja klasy
animations = inherit(Singleton)

-- Początek klasy
function animations:constructor()
	self.render = bind(self.draw, self)

	self.animations = {}
	self.animationId = 0
end

function animations:create(from, to, easing, duration, onChange, onEnd)
	if #self.animations == 0 and not isEventHandlerAdded("onClientRender", root, self.render) then
		addEventHandler("onClientRender", root, self.render)
	end

	assert(type(from) == "number", "Bad argument @ 'createAnimation' [expected number at argument 1, got "..type(from).."]")
	assert(type(to) == "number", "Bad argument @ 'createAnimation' [expected number at argument 2, got "..type(to).."]")
	assert(type(easing) == "string", "Bad argument @ 'createAnimation' [Invalid easing at argument 3]")
	assert(type(duration) == "number", "Bad argument @ 'createAnimation' [expected number at argument 4, got "..type(duration).."]")
	assert(type(onChange) == "function", "Bad argument @ 'createAnimation' [expected function at argument 5, got "..type(onChange).."]")

	self.animationId = self.animationId + 1

	table.insert(self.animations, {
		id = self.animationId,
		from = from,
		to = to,
		easing = easing,
		duration = duration,
		start = getTickCount(),
		onChange = onChange,
		onEnd = onEnd
	})

	return self.animationId
end

function animations:finish(animationId)
	for _, animation in ipairs(self.animations) do
		if animation.id == animationId then
			animation.start = 0
			animation.onChange(animation.to)

			if animation.onEnd and type(animation.onEnd) == "function" then
				animation.onEnd()
			end

			return true
		end
	end

	return false
end

function animations:delete(animationId) 
	for index, animation in ipairs(self.animations) do
		if animation.id == animationId then
			table.remove(self.animations, index)
			break
		end
	end
end

function animations:draw()
	local now = getTickCount()

	for index, animation in ipairs(self.animations) do
		animation.onChange(interpolateBetween(animation.from, 0, 0, animation.to, 0, 0, (now - animation.start) / animation.duration, animation.easing))

		if now >= animation.start + animation.duration then
			table.remove(self.animations, index)

			if type(animation.onEnd) == "function" then
				animation.onEnd()
			end

			if #self.animations == 0 and isEventHandlerAdded("onClientRender", root, self.render) then
				removeEventHandler("onClientRender", root, self.render)
			end
		end
	end
end
-- Koniec klasy

animations:constructor()