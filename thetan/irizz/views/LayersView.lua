local class = require("class")
local gyatt = require("thetan.gyatt")
local gfx_util = require("gfx_util")

local Theme = require("thetan.irizz.views.Theme")

local Layout = require("thetan.irizz.views.LayersLayout")
local GaussianBlurView = require("sphere.views.GaussianBlurView")
local BackgroundView = require("sphere.views.BackgroundView")

local LayersView = class()

LayersView.frequencies = nil

local chromaticAberration = 0
local distortion = 0
local spectrumType = "inverted"

local uiAlpha = 1
local dim = 0
local backgroundBlur = 0
local panelBlur = 0

local showSpectrum = false
local applyShaders = false

local gfx = love.graphics

function LayersView:new(game)
	self.game = game
	self.shaders = require("irizz.shaders.init")

	BackgroundView.game = game
end

---@param canvas love.Canvas
function LayersView:applyShaders(canvas)
	if not applyShaders then
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
	if not self.frequencies then
		return
	end

	if not invertColor then
		gfx.setColor(Theme.colors.accent)
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

---@param ui function
function LayersView:drawUI(ui)
	local previousCanvas = gfx.getCanvas()
	local uiLayer = gfx_util.getCanvas("selectUi")
	gfx.setCanvas({ uiLayer, stencil = true })
	gfx.clear()
	gfx.setBlendMode("alpha", "alphamultiply")

	ui()

	gfx.setCanvas(previousCanvas)

	gfx.origin()
	gfx.setColor(uiAlpha, uiAlpha, uiAlpha, uiAlpha)
	gfx.setBlendMode("alpha", "premultiplied")
	gfx.draw(uiLayer)
	gfx.setBlendMode("alpha")
end

function LayersView:update()
	local configs = self.game.configModel.configs
	local graphics = configs.settings.graphics
	local irizz = configs.irizz

	dim = graphics.dim.select
	panelBlur = irizz.panelBlur
	backgroundBlur = graphics.blur.select

	chromaticAberration = irizz.chromatic_aberration
	distortion = irizz.distortion

	applyShaders = irizz.backgroundEffects
	showSpectrum = irizz.showSpectrum
end

function LayersView:draw(panelsStencil, ui)
	Layout:draw()
	Theme:setLines()

	local background = self:drawBackground()

	if self.modalActive then
		uiAlpha = 1 - self.game.gameView.modal.alpha

		if uiAlpha == 0 then
			return
		end
	end

	self:drawPanelBlur(background, panelsStencil)
	self:drawUI(ui)
end

return LayersView
