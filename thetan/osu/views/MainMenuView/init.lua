local ScreenView = require("thetan.skibidi.views.ScreenView")

local flux = require("flux")
local gyatt = require("thetan.gyatt")
local ViewConfig = require("thetan.osu.views.MainMenuView.ViewConfig")
local InputMap = require("thetan.osu.views.MainMenuView.InputMap")

local get_assets = require("thetan.osu.views.assets_loader")

---@class osu.MainMenuView : skibidi.ScreenView
---@operator call: osu.MainMenuView
---@field state "intro" | "normal" | "fade_out" | "fade_in" | "afk" | "outro"
---@field tween table?
---@field outroTween table?
local MainMenuView = ScreenView + {}

local window_height = 0

function MainMenuView:load()
	self.game.selectController:load(self)

	self.assets = get_assets(self.game)
	self.viewConfig = ViewConfig(self.game, self.assets)
	self.inputMap = InputMap(self, self.actionModel)
	self.actionModel.enable()

	window_height = love.graphics.getHeight()
	love.mouse.setVisible(false)

	self.mouseMoveTime = love.timer.getTime()
	self.afkPercent = 1
	self.outroPercent = 0
	self.state = "normal"
end

function MainMenuView:beginUnload()
	self.game.selectController:beginUnload()
end

function MainMenuView:unload()
	self.game.selectController:unload()
end

---@param event string?
function MainMenuView:processState(event)
	local state = self.state

	if state == "normal" then
		if love.timer.getTime() > self.mouseMoveTime + 2 then
			self.state = "fade_out"
			if self.tween then
				self.tween:stop()
			end
			self.tween = flux.to(self, 1, { afkPercent = 0 }):ease("quadout")
		end
	elseif state == "fade_out" or state == "afk" then
		if event == "mousemoved" then
			self.state = "fade_in"
			if self.tween then
				self.tween:stop()
			end
			self.tween = flux.to(self, 0.4, { afkPercent = 1 }):ease("quadout")
		end
		if self.afkPercent == 0 then
			self.state = "afk"
		end
	elseif state == "fade_in" then
		if self.afkPercent == 1 then
			self.state = "normal"
		end
	elseif state == "intro" then
		self.viewConfig.hasFocus = false
	elseif state == "outro" then
		if self.outroPercent == 1 then
			love.event.quit()
		end

		local audio = self.game.previewModel.audio

		if audio then
			local configs = self.game.configModel.configs
			local settings = configs.settings
			local a = settings.audio
			local v = a.volume

			audio:setVolume(v.master * v.music * (1 - self.outroPercent))
		end

		self.viewConfig.hasFocus = false
	end
end

---@param dt number
function MainMenuView:update(dt)
	ScreenView.update(self, dt)
	self.game.selectController:update()

	self.viewConfig.hasFocus = self.modal == nil
	self:processState()
end

function MainMenuView:edit()
	if not self.game.selectModel:notechartExists() then
		return
	end

	self:changeScreen("editorView")
end

function MainMenuView:closeGame()
	if self.tween then
		self.tween:stop()
	end

	self.state = "outro"
	self.outroTween = flux.to(self, 1.2, { outroPercent = 1 }):ease("quadout")
	self.tween = flux.to(self, 0.4, { afkPercent = 0 }):ease("quadout")
end

function MainMenuView:notechartChanged()
	self.viewConfig:updateInfo(self)
end

function MainMenuView:resolutionUpdated()
	window_height = self.assets.localization:updateScale()

	self.viewConfig:resolutionUpdated()

	if self.modal then
		self.modal.viewConfig:resolutionUpdated()
	end
end

function MainMenuView:receive(event)
	if event.name == "mousemoved" then
		self.mouseMoveTime = love.timer.getTime()
		self:processState(event.name)
	end

	if event.name == "keypressed" then
		if self.inputMap:call("view") then
			return
		end
	end
end

local gfx = love.graphics

function MainMenuView:drawCursor()
	gfx.origin()
	gfx.setColor(1, 1, 1)

	local x, y = love.mouse.getPosition()

	local cursor = self.assets.images.cursor
	local iw, ih = cursor:getDimensions()
	gfx.draw(cursor, x - iw / 2, y - ih / 2)
end

function MainMenuView:draw()
	gyatt.setTextScale(768 / window_height)
	self.viewConfig:draw(self)
	self:drawModal()
	self.notificationView:draw()
	self:drawCursor()
	gyatt.setTextScale(1)

	if self.state == "outro" then
		gfx.origin()
		gfx.setColor(0, 0, 0, self.outroPercent)
		gfx.rectangle("fill", 0, 0, gfx.getWidth(), gfx.getHeight())
	end
end

return MainMenuView
