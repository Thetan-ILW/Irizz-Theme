local ScreenView = require("thetan.skibidi.views.ScreenView")

local flux = require("flux")
local gyatt = require("thetan.gyatt")
local ViewConfig = require("thetan.osu.views.MainMenuView.ViewConfig")
local InputMap = require("thetan.osu.views.MainMenuView.InputMap")

local SettingsView = require("thetan.osu.views.SettingsView")

local get_assets = require("thetan.osu.views.assets_loader")

---@class osu.MainMenuView : skibidi.ScreenView
---@operator call: osu.MainMenuView
---@field state "intro" | "normal" | "fade_out" | "fade_in" | "afk" | "outro"
---@field lastUserActionTime number
---@field tween table?
---@field introTween table?
---@field outroTween table?
local MainMenuView = ScreenView + {}

local window_height = 0
local show_intro = true

function MainMenuView:load()
	self.game.selectController:load(self)
	self.assets = get_assets(self.game)
	self.viewConfig = ViewConfig(self.game, self.assets)
	self.inputMap = InputMap(self, self.actionModel)
	self.actionModel.enable()
	self.game.previewModel.musicPlayerMode = true

	self.settingsView = SettingsView(self.assets, self.game)

	window_height = love.graphics.getHeight()
	love.mouse.setVisible(false)

	self.lastUserActionTime = love.timer.getTime()
	self.afkPercent = 1
	self.outroPercent = 0
	self.introPercent = 0
	self.state = show_intro and "intro" or "normal"

	if show_intro then
		local snd = self.assets.sounds
		snd.welcome:play()
		snd.welcomePiano:play()
	end

	show_intro = false

	self.introTween = flux.to(self, 2, { introPercent = 1 }):ease("linear")
end

function MainMenuView:beginUnload()
	self.game.selectController:beginUnload()
	self.game.previewModel.musicPlayerMode = false
end

function MainMenuView:unload()
	self.game.selectController:unload()
end

function MainMenuView:setMasterVolume(volume)
	local audio = self.game.previewModel.audio

	if not audio then
		return
	end

	local configs = self.game.configModel.configs
	local settings = configs.settings
	local a = settings.audio
	local v = a.volume

	audio:setVolume(v.master * v.music * (1 - volume))
end

---@param event string?
function MainMenuView:processState(event)
	local state = self.state

	if state == "normal" then
		if love.timer.getTime() > self.lastUserActionTime + 10 then
			self.state = "fade_out"
			if self.tween then
				self.tween:stop()
			end
			self.tween = flux.to(self, 1, { afkPercent = 0 }):ease("quadout")
			self.viewConfig:processLogoState(self, "hide")
			self.settingsView:processState("hide")
		end
	elseif state == "fade_out" or state == "afk" then
		if event == "user_returned" then
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
		if self.introPercent == 1 then
			self.state = "normal"
		end

		local animation = math.pow(self.introPercent, 16)
		self.afkPercent = animation
		self.viewConfig.hasFocus = false
	elseif state == "outro" then
		if self.outroPercent == 1 then
			love.event.quit()
		end

		self.viewConfig.hasFocus = false
		self:setMasterVolume(self.outroPercent)
	end
end

---@param dt number
function MainMenuView:update(dt)
	ScreenView.update(self, dt)
	gyatt.setTextScale(768 / window_height)

	self.settingsView.modalActive = self.modal == nil

	if self.changingScreen then
		self.settingsView:processState("hide")
	end

	self.settingsView:update()

	if self.state ~= "intro" then
		self.game.selectController:update()
	end

	self.viewConfig.hasFocus = (self.modal == nil) and not self.settingsView:isFocused() and not self.changingScreen
	self:processState()
end

function MainMenuView:edit()
	if not self.game.selectModel:notechartExists() then
		return
	end

	self:changeScreen("editorView")
end

function MainMenuView:toggleSettings()
	self.settingsView:processState("toggle")
end

function MainMenuView:closeGame()
	if self.tween then
		self.tween:stop()
	end

	self.state = "outro"
	self.outroTween = flux.to(self, 1.2, { outroPercent = 1 }):ease("quadout")
	self.tween = flux.to(self, 0.4, { afkPercent = 0 }):ease("quadout")
	self.assets.sounds.goodbye:play()
end

function MainMenuView:notechartChanged()
	self.viewConfig:updateInfo(self)
end

function MainMenuView:sendQuitSignal()
	if self.modal then
		self.modal:quit()
		return
	end
	self.settingsView:processState("hide")
end

function MainMenuView:resolutionUpdated()
	window_height = self.assets.localization:updateScale()

	self.viewConfig:resolutionUpdated()
	self.settingsView:resolutionUpdated()

	if self.modal then
		self.modal.viewConfig:resolutionUpdated()
	end
end

function MainMenuView:receive(event)
	if event.name == "mousemoved" then
		self.lastUserActionTime = love.timer.getTime()
		self:processState("user_returned")
	end

	if event.name == "keypressed" then
		self.lastUserActionTime = love.timer.getTime()
		self:processState("user_returned")
		if self.inputMap:call("view") then
			return
		end
	end

	if event.name == "mousepressed" then
		self.lastUserActionTime = love.timer.getTime()
		self:processState("user_returned")
	end

	self.settingsView:receive(event)
end

local gfx = love.graphics

function MainMenuView:drawCursor()
	gfx.origin()
	gfx.setColor(1, 1, 1, self.afkPercent)

	local x, y = love.mouse.getPosition()

	local cursor = self.assets.images.cursor
	local iw, ih = cursor:getDimensions()
	gfx.draw(cursor, x - iw / 2, y - ih / 2)
end

function MainMenuView:draw()
	self.viewConfig:draw(self)
	self.settingsView:draw()
	self:drawModal()
	self.notificationView:draw()
	self:drawCursor()

	if self.state == "outro" then
		gfx.origin()
		gfx.setColor(0, 0, 0, self.outroPercent)
		gfx.rectangle("fill", 0, 0, gfx.getWidth(), gfx.getHeight())
	end
end

return MainMenuView
