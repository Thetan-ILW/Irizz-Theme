local class = require("class")
local gyatt = require("thetan.gyatt")
local gfx_util = require("gfx_util")

local ui = require("thetan.irizz.ui")
local colors = require("thetan.irizz.ui.colors")
---@type table<string, string>
local text
---@type table<string, love.Font>
local font

local Layout = require("thetan.irizz.views.LayersLayout")
local GaussianBlurView = require("sphere.views.GaussianBlurView")
local BackgroundView = require("sphere.views.BackgroundView")

---@class irizz.LayersView
---@operator call: irizz.LayersView
local LayersView = class()

local audioSourceName = "preview"
local audioSource = nil
local chromaticAberration = 0
local distortion = 0
local spectrumType = "inverted"
local frequencies = nil
local shaders = {}

local screen = "select"
local uiAlpha = 1
local dim = 0
local backgroundBlur = 0
local panelBlur = 0

local showSpectrum = false
local applyShaders = false
local modalActive = false
local uiLock = false

local gfx = love.graphics

function LayersView:new(game, assets, mainMenuView, screenName, sourceName)
	self.game = game
	self.mainMenuView = mainMenuView

	text, font = assets.localization:get("layersView")
	assert(text and font)

	screen = screenName
	audioSourceName = sourceName
	shaders = require("irizz.shaders")

	BackgroundView.game = game

	if sourceName == "gameplay" then
		local container = self.game.rhythmModel.audioEngine.backgroundContainer
		for k in pairs(container.sources) do
			audioSource = k
			return
		end
	end
end

---@param canvas love.Canvas
function LayersView:applyShaders(canvas)
	if not applyShaders then
		return canvas
	end

	if not frequencies then
		return canvas
	end

	if dim == 1 then
		return canvas
	end

	local previousShader = gfx.getShader()
	local previousCanvas = gfx.getCanvas()

	local freqs = {}

	for i = 0, 32, 1 do
		freqs[i * 32 + 1] = frequencies[i]
	end

	local ca = shaders.ca
	ca:send("ch_ab_intensity", chromaticAberration)
	ca:send("distortion_intensity", distortion)
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
function LayersView:spectrum(canvas, w, h, invertColor)
	if not frequencies then
		return
	end

	if not invertColor then
		gfx.setColor(colors.ui.accent)
		gyatt.spectrum(frequencies, 127, w, h)
		return
	end

	local function spectrumStencil()
		gyatt.spectrum(frequencies, 127, w, h)
	end

	local previousShader = gfx.getShader()

	gfx.stencil(spectrumStencil, "replace", 1)
	gfx.setStencilTest("equal", 1)
	gfx.setShader(shaders.invert)
	gfx.draw(canvas)
	gfx.setStencilTest()

	gfx.setShader(previousShader)
end

function LayersView:drawBackground()
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

	local background = self:applyShaders(backgroundBase)

	--- Fade canvas + Background canvas + Spectrum
	gfx.setBlendMode("alpha", "premultiplied")
	gfx.draw(background)

	if showSpectrum then
		self:spectrum(background, gfx.getWidth(), gfx.getHeight(), spectrumType == "inverted") -- Does not work with w and h
	end

	gfx.setBlendMode("alpha")

	return background
end

function LayersView:drawPanelBlur(background, panelsStencil)
	local previousCanvas = gfx.getCanvas()

	gfx.setCanvas({ previousCanvas, stencil = true })
	gfx.stencil(panelsStencil, "replace", 1)
	gfx.setStencilTest("equal", 1)

	gfx.origin()
	gfx.setColor({ uiAlpha, uiAlpha, uiAlpha, uiAlpha })
	gfx.setBlendMode("alpha", "premultiplied")
	GaussianBlurView:draw(panelBlur)
	gfx.draw(background)
	GaussianBlurView:draw(panelBlur)
	gfx.setBlendMode("alpha")

	gfx.setStencilTest()
	gfx.setCanvas(previousCanvas)
end

---@param layer function
function LayersView:drawUI(layer)
	local previousCanvas = gfx.getCanvas()
	local uiLayer = gfx_util.getCanvas("selectUi")
	gfx.setCanvas({ uiLayer, stencil = true })
	gfx.clear()
	gfx.setBlendMode("alpha", "alphamultiply")

	layer()

	gfx.setCanvas({ previousCanvas, stencil = true })

	gfx.origin()
	gfx.setColor(uiAlpha, uiAlpha, uiAlpha, uiAlpha)
	gfx.setBlendMode("alpha", "premultiplied")
	gfx.draw(uiLayer)
	gfx.setBlendMode("alpha")
end

function LayersView:uiLock()
	local cacheModel = self.game.cacheModel
	local locationManager = self.game.cacheModel.locationManager
	local selected_loc = locationManager.selected_loc
	local path = selected_loc.path

	local count = cacheModel.shared.chartfiles_count
	local current = cacheModel.shared.chartfiles_current

	local w, h = Layout:move("background")
	gfx.setColor(0, 0, 0, 0.75)
	gfx.rectangle("fill", 0, 0, w, h)

	local w, h = Layout:move("uiLockTitle")
	gfx.setColor(colors.ui.text)
	gfx.setFont(font.uiLockTitle)
	gfx_util.printFrame(text.processingCharts, 0, 0, w, h, "center", "center")

	w, h = Layout:move("background")
	gfx.setFont(font.uiLockStatus)
	local label = ("%s: %s\n%s: %s/%s\n%s: %0.02f%%"):format(
		text.path,
		path,
		text.chartsFound,
		current,
		count,
		text.chartsCached,
		current / count * 100
	)
	gyatt.frame(label, 0, 0, w, h, "center", "center")
end

function LayersView:update()
	local configs = self.game.configModel.configs
	local graphics = configs.settings.graphics
	local irizz = configs.irizz

	if screen == "select" then
		dim = graphics.dim.select
		backgroundBlur = graphics.blur.select
	elseif screen == "result" then
		dim = graphics.dim.result
		backgroundBlur = graphics.blur.result
	end

	panelBlur = irizz.panelBlur
	chromaticAberration = irizz.chromatic_aberration
	distortion = irizz.distortion

	applyShaders = irizz.backgroundEffects
	showSpectrum = irizz.showSpectrum
	spectrumType = irizz.spectrum

	local audio = audioSource

	if audioSourceName == "preview" then
		audio = self.game.previewModel.audio
	end

	if audio and audio.getData then
		frequencies = audio:getData()
	end

	modalActive = self.game.gameView.modal ~= nil
	uiAlpha = 1

	if self.mainMenuView then
		uiAlpha = uiAlpha - self.mainMenuView:getAlpha()
	end

	if modalActive then
		uiAlpha = uiAlpha - self.game.gameView.modal.alpha
	end

	uiLock = self.game.cacheModel.isProcessing
end

function LayersView:draw(panelsStencil, ui_layer)
	Layout:draw()
	ui:setLines()

	local background = self:drawBackground()

	if uiLock then
		self:uiLock()
		return
	end

	if uiAlpha == 0 then
		return
	end

	self:drawPanelBlur(background, panelsStencil)
	self:drawUI(ui_layer)
end

return LayersView
