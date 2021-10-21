--[[
	@project: dotGame
	@author: xkotori

	All rights reversed, rights also belongs to project and author.
--]]

-- Zasoby wymagane
local RESOURCE_LOADING = exports["rp_loading"]

-- Inicjalizacja klasy
local main = inherit(Singleton)

-- Początek klasy
function main:constructor()
	self.TIMER = {
		TIME = 1.5 * 1000,
		INSTANCE = false
	}

	self.TEXT = {
		VERIFYING = "Weryfikacja pobranych zasobów..",
		DOWNLOADING = "Pobieranie zasobów (%s z %s)"
	}

	self.onProgressUpdating = bind(self.onProgressUpdate, self)
	self.checkDownload = bind(self.checker, self)

	-- Ekran wczytywania
	local LOADING_STATE = RESOURCE_LOADING:state()

	if not LOADING_STATE then
		RESOURCE_LOADING:show()
		RESOURCE_LOADING:updateText(self.TEXT.VERIFYING)
	end

	if not self.TIMER.INSTANCE then
		self.TIMER.INSTANCE = Timer(self.checkDownload, self.TIMER.TIME, 0)
	end

	setTransferBoxVisible(false)
end

function main:onProgressUpdate(downloaded, total)
	local LOADING_STATE = RESOURCE_LOADING:state()

	if not GuiElement.isTransferBoxActive() then
		if LOADING_STATE then
			RESOURCE_LOADING:destroy()
		end

		return
	end

	local TOTAL_DOWNLOADED = utils:humanFileSize(downloaded)
	local TOTAL_SIZE = utils:humanFileSize(total)
	local TOTAL_PERCENT = math.min((downloaded / total) * 100, 100)

	if not LOADING_STATE then return end

	RESOURCE_LOADING:updateProgressBar(TOTAL_PERCENT)
	RESOURCE_LOADING:updateText(self.TEXT.DOWNLOADING:format(TOTAL_DOWNLOADED, TOTAL_SIZE))
end

function main:checker()
	if GuiElement.isTransferBoxActive() then
		local LOADING_STATE = RESOURCE_LOADING:state()

		if not utils:isEventHandlerAdded("onClientTransferBoxProgressChange", root, self.onProgressUpdating) then
			addEventHandler("onClientTransferBoxProgressChange", root, self.onProgressUpdating)

			if LOADING_STATE then
				RESOURCE_LOADING:setProgressBarEnabled()
			end
		end
	else
		if self.TIMER.INSTANCE then
			if self.TIMER.INSTANCE:destroy() then
				if utils:isEventHandlerAdded("onClientTransferBoxProgressChange", root, self.onProgressUpdating) then
					removeEventHandler("onClientTransferBoxProgressChange", root, self.onProgressUpdating)
				end

				self.TIMER.INSTANCE = false
			end
		end

		local LOADING_STATE = RESOURCE_LOADING:state()

		if LOADING_STATE then
			RESOURCE_LOADING:destroy()
		end
	end

	print(GuiElement.isTransferBoxActive() and "downloading" or "loading")
end
-- Koniec klasy

--- FUNKCJA DO STARTOWANIA
local function RESOURCE_START()
	return main:constructor()
end
addEventHandler("onClientResourceStart", resourceRoot, RESOURCE_START)