local gyatt = require("thetan.gyatt")
local flux = require("flux")
local math_util = require("math_util")
local gfx_util = require("gfx_util")
local ScreenView = require("sphere.views.ScreenView")

local Theme = require("thetan.irizz.views.Theme")
local Layout = require("thetan.irizz.views.SelectView.Layout")
local HeaderView = require("thetan.irizz.views.HeaderView")

local SettingsViewConfig = require("thetan.irizz.views.SelectView.Settings")
local SongSelectViewConfig = require("thetan.irizz.views.SelectView.SongSelect")
local CollectionViewConfig = require("thetan.irizz.views.SelectView.Collections")

local GaussianBlurView = require("sphere.views.GaussianBlurView")
local BackgroundView = require("sphere.views.BackgroundView")
local InputMap = require("thetan.irizz.views.SelectView.InputMap")

---@class irizz.SelectView: sphere.ScreenView
---@operator call: irizz.SelectView
local SelectView = ScreenView + {}

SelectView.modalActive = false
SelectView.screenX = 0
SelectView.screenXTarget = 0

SelectView.chartFilterLine = ""
SelectView.scoreFilterLine = ""
SelectView.frequencies = nil
SelectView.shaders = nil

local playSound = nil
function SelectView:load()
	self.game.selectController:load()
	self.headerView = HeaderView("select")
	self.settingsViewConfig = SettingsViewConfig(self.game)
	self.songSelectViewConfig = SongSelectViewConfig(self.game)
	self.collectionsViewConfig = CollectionViewConfig(self.game)
	self.selectModel = self.game.selectModel

	BackgroundView.game = self.game
	playSound = Theme:getStartSound(self.game)

	local actionModel = self.game.actionModel
	self.inputMap = InputMap(self, actionModel:getGroup("songSelect"))

	self.shaders = require("irizz.shaders.init")
	self:updateFilterLines()
end

function SelectView:beginUnload()
	self.game.selectController:beginUnload()
end

function SelectView:unload()
	self.game.selectController:unload()
	self.collectionsViewConfig = nil
end

---@param where number
---@param exact? boolean
function SelectView:moveScreen(where, exact)
	if self.game.gameView.modal then
		return
	end

	self.screenXTarget = self.screenXTarget - where

	if exact then
		self.screenXTarget = -where
	end

	self.screenXTarget = math_util.clamp(-1, self.screenXTarget, 1)
	self.tween = flux.to(self, 0.32, { screenX = self.screenXTarget }):ease("quadout")

	if self.screenXTarget == 0 then
		self:switchToSongSelect()
	end

	Theme:playSound("songSelectScreenChanged")
end

function SelectView:openModal(modalName)
	local modal = require(modalName)(self.game)
	self.game.gameView:setModal(modal)
end

---@param dt number
function SelectView:updateSettings(dt)
	playSound = Theme:getStartSound(self.game)
end

function SelectView:switchToSongSelect()
	self.game.selectModel:noDebouncePullNoteChartSet()
end

---@param dt number
function SelectView:update(dt)
	self.game.selectController:update()

	if self.screenX == 1 then
		self:updateSettings(dt)
	end

	local audio = self.game.previewModel.audio

	if audio and audio.getData then
		self.frequencies = audio:getData()
	end
end

function SelectView:play()
	if not self.game.selectModel:notechartExists() then
		return
	end

	if playSound ~= nil then
		playSound:play()
	end

	local multiplayerModel = self.game.multiplayerModel
	if multiplayerModel.room and not multiplayerModel.isPlaying then
		multiplayerModel:pushNotechart()
		self:changeScreen("multiplayerView")
		return
	end

	self:changeScreen("gameplayView")
end

function SelectView:result()
	if self.game.selectModel:isPlayed() then
		self:changeScreen("resultView")
	end
end

function SelectView:updateFilterLines()
	local filters = self.game.configModel.configs.filters.notechart
	local filterModel = self.game.selectModel.filterModel
	local select = self.game.configModel.configs.select
	local output = {}

	for _, group in ipairs(filters) do
		local activeValues = {}

		for _, filter in ipairs(group) do
			if filterModel:isActive(group.name, filter.name) then
				table.insert(activeValues, filter.name)
			end
		end

		if #activeValues ~= 0 then
			local groupValues = Theme.formatFilter(group.name) .. ": " .. table.concat(activeValues, ", ")
			table.insert(output, groupValues)
		end
	end

	self.chartFilterLine = table.concat(output, "   ")

	local mode = select.scoreFilterName
	local source = select.scoreSourceName

	mode = mode == "No filter" and "" or mode
	source = source == "local" and "" or "Online"

	self.scoreFilterLine = ("%s   %s"):format(source, mode)
end

function SelectView:changeTimeRate(delta)
	if self.modalActive then
		return
	end

	local configs = self.game.configModel.configs
	local g = configs.settings.gameplay

	local timeRateModel = self.game.timeRateModel
	local range = timeRateModel.range[g.rate_type]

	local newRate = timeRateModel:get() + range[3] * delta

	if newRate ~= timeRateModel:get() then
		self.game.modifierSelectModel:change()
		timeRateModel:set(newRate)
	end
end

function SelectView:updateSearch(text)
	local config = self.game.configModel.configs.select
	local selectModel = self.game.selectModel
	config.filterString = text
	selectModel:debouncePullNoteChartSet()
end

function SelectView:songSelectInputs()
	if self.inputMap:call("selectModals") then
		return
	end

	if self.modalActive then
		return false
	end

	self.inputMap:call("select")
end

function SelectView:receive(event)
	self.game.selectController:receive(event)

	if event.name == "keypressed" then
		if self.inputMap:call("view") then
			return
		end

		if self.screenX == 0 then
			self:songSelectInputs()
		end
	end
end

local gfx = love.graphics

---@param canvas love.Canvas
---@param config table
function SelectView:applyShaders(canvas, config)
	if not config.backgroundEffects then
		return canvas
	end

	if not self.frequencies then
		return canvas
	end

	local previousShader = gfx.getShader()
	local previousCanvas = gfx.getCanvas()

	local freqs = {}

	for i = 0, 32, 1 do
		freqs[i * 32 + 1] = self.frequencies[i]
	end

	local ca = self.shaders.ca
	ca:send("ch_ab_intensity", config.chromatic_aberration)
	ca:send("distortion_intensity", config.distortion)
	ca:send("time", love.timer.getTime())
	ca:send("frequencies", unpack(freqs))

	local newCanvas = gfx_util.getCanvas("effectsCanvas")

	gfx.setCanvas({ newCanvas, stencil = true })
	gfx.setShader(ca)
	gfx.setColor({ 1, 1, 1, 1 })
	gfx.draw(canvas)

	gfx.setCanvas({ previousCanvas, stencil = true })
	gfx.setShader(previousShader)

	return newCanvas
end

---@param canvas love.Canvas
---@param w number
---@param h number
---@param invertColor boolean
function SelectView:spectrum(canvas, w, h, invertColor)
	if not self.frequencies then
		return
	end

	if not invertColor then
		gfx.setColor(Theme.colors.spectrum)
		gyatt.spectrum(self.frequencies, 127, w, h)
		return
	end

	local function spectrumStencil()
		gyatt.spectrum(self.frequencies, 127, w, h)
	end

	local previousShader = gfx.getShader()

	gfx.stencil(spectrumStencil, "replace", 1)
	gfx.setStencilTest("equal", 1)
	gfx.setShader(self.shaders.invert)
	gfx.draw(canvas)
	gfx.setStencilTest()

	gfx.setShader(previousShader)
end

function SelectView:draw()
	Layout:draw()
	Theme:setLines()

	local configs = self.game.configModel.configs
	local graphics = configs.settings.graphics
	local irizz = configs.irizz

	local dim = graphics.dim.select
	local panelBlur = irizz.panelBlur
	local backgroundBlur = graphics.blur.select

	local previousShader = gfx.getShader()
	local previousCanvas = gfx.getCanvas()

	local backgroundBase = gfx_util.getCanvas("selectBackground")
	local w, h = Layout:move("background")

	---- Background + blur layer
	gfx.setShader()
	gfx.setCanvas({ backgroundBase, stencil = true })

	gfx.clear()
	gfx.setColor({ 1, 1, 1, 1 })
	GaussianBlurView:draw(backgroundBlur)
	BackgroundView:draw(w, h, dim, 0.01)
	GaussianBlurView:draw(backgroundBlur)
	gfx.origin()

	gfx.setCanvas({ previousCanvas, stencil = true })
	gfx.setShader(previousShader)
	---

	local background = self:applyShaders(backgroundBase, irizz)

	--- Fade canvas + Background canvas + Spectrum
	gfx.setBlendMode("alpha", "premultiplied")
	gfx.draw(background)

	if irizz.showSpectrum then
		self:spectrum(background, gfx.getWidth(), gfx.getHeight(), irizz.spectrum == "inverted") -- Does not work with w and h
	end

	gfx.setBlendMode("alpha")

	---- Haha
	local position = self.screenX
	local settings = self.settingsViewConfig
	local songSelect = self.songSelectViewConfig
	local collections = self.collectionsViewConfig

	songSelect.layoutDraw(position)
	settings.layoutDraw(position - 1)
	collections.layoutDraw(position + 1)

	local alpha = 1

	if self.modalActive then
		alpha = 1 - self.game.gameView.modal.alpha

		if alpha == 0 then
			return
		end
	end

	---- Blur under panels
	local panelsStencil = function()
		if songSelect.canDraw(position) then
			songSelect.panels()
		end

		if settings.canDraw(position - 1) then
			settings.panels()
		end

		if collections.canDraw(position + 1) then
			collections.panels()
		end
	end

	gfx.setCanvas({ previousCanvas, stencil = true })
	gfx.stencil(panelsStencil, "replace", 1)
	gfx.setStencilTest("equal", 1)

	gfx.origin()
	gfx.setColor({ alpha, alpha, alpha, alpha })
	gfx.setBlendMode("alpha", "premultiplied")
	GaussianBlurView:draw(panelBlur)
	gfx.draw(background)
	GaussianBlurView:draw(panelBlur)
	gfx.setBlendMode("alpha")

	gfx.setStencilTest()
	gfx.setCanvas(previousCanvas)

	---- UI
	local uiLayer = gfx_util.getCanvas("selectUi")
	gfx.setCanvas({ uiLayer, stencil = true })
	gfx.clear()
	gfx.setBlendMode("alpha", "alphamultiply")
	self.headerView:draw(self)
	songSelect:draw(self, position)
	collections:draw(self, position + 1)
	settings:draw(self, position - 1)
	gfx.setCanvas(previousCanvas)

	gfx.origin()
	gfx.setColor(alpha, alpha, alpha, alpha)
	gfx.setBlendMode("alpha", "premultiplied")
	gfx.draw(uiLayer)
	gfx.setBlendMode("alpha")
end

return SelectView
