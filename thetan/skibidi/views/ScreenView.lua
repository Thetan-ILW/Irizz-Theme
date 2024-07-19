local class = require("class")

---@class skibidi.ScreenView
---@operator call: skibidi.ScreenView
---@field gameView sphere.GameView
---@field prevView skibidi.ScreenView
---@field modal irizz.Modal?
---@field notificationView irizz.NotificationView
---@field actionModel irizz.ActionModel
local ScreenView = class()

---@param game sphere.GameController
function ScreenView:new(game)
	self.game = game
end

---@param screenName string
function ScreenView:changeScreen(screenName)
	if self.modal then
		self.modal.shouldClose = true
	end

	self:beginUnload()
	self.gameView:setView(self.game[screenName])
end

---@param modal irizz.Modal
function ScreenView:setModal(modal)
	local openedModal = self.modal
	if not openedModal then
		self.modal = modal
		self.modal.mainView = self
		self.modal.alpha = 0
		self.modal:show()
		return
	end

	if openedModal.name == modal.name then
		self.modal.shouldClose = true
	end
end

function ScreenView:closeModal()
	if self.modal then
		self.modal.shouldClose = true
	end

	self.view.modalActive = false
end

function ScreenView:openModal(modalName)
	---@type irizz.Modal
	local modal = require(modalName)(self.game)
	self:setModal(modal)
end

function ScreenView:load() end
function ScreenView:beginUnload() end
function ScreenView:unload() end
function ScreenView:quit() end

---@param event table
function ScreenView:receive(event) end

---@param dt number
function ScreenView:update(dt)
	if self.modal and self.modal.alpha < 0 then
		self.modal = nil
	end
end

function ScreenView:drawModal()
	if self.modal then
		love.graphics.origin()
		love.graphics.setColor({ 0, 0, 0, self.modal.alpha * 0.75 })
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		self.modal:draw(self)
	end
end

function ScreenView:sendQuitSignal()
	if self.game.cacheModel.isProcessing then
		return
	end

	if self.modal then
		self.modal:quit()
		return
	end

	self:quit()
end

function ScreenView:draw() end

return ScreenView
