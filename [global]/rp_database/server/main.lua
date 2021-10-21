--[[
	@project: dotGame
	@author: xkotori

	All rights reversed, rights also belongs to project and author.
--]]

-- Wymagane zasoby
local data = exports["G_DATA"]

-- Inicjalizacja klasy
local main = inherit(Singleton)

-- Początek klasy
function main:constructor()
	self.CONNECTION = false
	self.CONNECTED = false

	self.SETTINGS = data:get("mysql")
	
	self:connect()
end

function main:connect()
	if not self.CONNECTION and not self.CONNECTED then
		if self.SETTINGS then
			self.CONNECTION = Connection("mysql", ("host=%s;port=%d;dbname=%s;charset=utf8;share=1"):format(
				self.SETTINGS.host or "localhost",
				self.SETTINGS.port or 3306,
				self.SETTINGS.database or "database"
			), self.SETTINGS.username or "root", self.SETTINGS.password or "")
		end

		if self.CONNECTION then
			self.CONNECTED = true

			print("connect: Połączono")

			self:queryFree("SET NAMES utf8;")
		else
			self.CONNECTED = false

			print("connect: Nie udało się połączyć")

			if not self.CONNECTION then
				stopResource(getThisResource())
			end
		end
	end

	return self.CONNECTED
end

function main:query(...)
	if self.CONNECTED then
		if not isElement(self.CONNECTION) and not self:connect() then return end

		local string = self.CONNECTION:prepareString(...)

		if string then
			local query = self.CONNECTION:query(string)
			local result, rows, lastInsert = query:poll(-1)

			if not result then
				print(("query: Błąd w zapytaniu %s"):format(select(1, ...)))

				return false
			end

			print(("query: Zapytanie wykonane pomyślnie (%s)"):format(select(1, ...)))

			return result, lastInsert, rows
		else
			return false
		end
	else
		return false
	end
end

function main:queryFree(...)
	if self.CONNECTED then
		if not isElement(self.CONNECTION) and not self:connect() then return end

		local string = self.CONNECTION:prepareString(...)

		if string then
			local query = self.CONNECTION:exec(string)

			if not query then
				print(("queryFree: Błąd w zapytaniu %s"):format(select(1, ...)))

				return false
			end

			print(("queryFree: Zapytanie wykonane pomyślnie (%s)"):format(select(1, ...)))

			return query
		else
			return false
		end
	else
		return false
	end
end

function main:queryAsync(trigger, arguments, ...)
	if self.CONNECTED then
		if not isElement(self.CONNECTION) and not self:connect() then return end

		local string = self.CONNECTION:prepareString(...)

		if string then
			local function callback(query, ...)
				local args = {...}
				local triggerName = args[1]

				table.remove(args, 1) -- usuwanie nazwy eventu

				local result = query:poll(0)

				if not result then
					print(("queryAsync: Błąd w zapytaniu %s"):format(select(1, ...)))

					return false
				end

				triggerEvent(triggerName, root, result, unpack(args))
			end

			print(("queryAsync: Zapytanie wykonane pomyślnie (%s)"):format(select(1, ...)))

			self.CONNECTION:query(callback, {trigger, unpack(arguments)}, self.CONNECTION, string)
			return true
		else
			return false
		end
	else
		return false
	end
end

function main:getSingleRow(...)
	if self.CONNECTED then
		if not isElement(self.CONNECTION) and not self:connect() then return end

		local string = self.CONNECTION:prepareString(...)

		if string then
			local query = self.CONNECTION:query(string)
			local rows, result = query:poll(-1)

			if not rows[1] then
				print(("getSingleRow: Błąd w zapytaniu %s"):format(select(1, ...)))

				return false
			end

			print(("getSingleRow: Zapytanie wykonane pomyślnie (%s)"):format(select(1, ...)))

			return rows[1]
		else
			return false
		end
	else
		return false
	end
end

function main:getRows(...)
	if self.CONNECTED then
		if not isElement(self.CONNECTION) and not self:connect() then return end

		local string = self.CONNECTION:prepareString(...)

		if string then
			local query = self.CONNECTION:query(string)
			local rows, result = query:poll(-1)

			if not rows then
				print(("getRows: Błąd w zapytaniu %s"):format(select(1, ...)))

				return false
			end

			print(("getRows: Zapytanie wykonane pomyślnie (%s)"):format(select(1, ...)))

			return rows
		else
			return false
		end
	else
		return false
	end
end
-- Koniec klasy

--- FUNKCJA STARTOWA
local function RESOURCE_START()
	return main:constructor()
end
addEventHandler("onResourceStart", resourceRoot, RESOURCE_START)

--- FUNKCJE EKSPORTOWANE
function query(...)
	return main:query(...)
end

function queryFree(...)
	return main:queryFree(...)
end

function queryAsync(...)
	return main:queryAsync(...)
end

function getSingleRow(...)
	return main:getSingleRow(...)
end

function getRows(...)
	return main:getRows(...)
end