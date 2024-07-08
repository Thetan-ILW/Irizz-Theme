local class = require("class")
local gfx_util = require("gfx_util")
local SequenceView = require("sphere.views.SequenceView")
local ChartPreviewRhythmView = require("sphere.views.SelectView.ChartPreviewRhythmView")

---@class sphere.ChartPreviewView
---@operator call: sphere.ChartPreviewView
local ChartPreviewView = class()

---@param game sphere.GameController
function ChartPreviewView:new(game)
	self.game = game
	self.sequenceView = SequenceView()
	self.sequenceView:setSequenceConfig({})
end

local transform

function ChartPreviewView:load()
	local noteSkin = self.game.chartPreviewModel.noteSkin
	if not noteSkin then
		return
	end

	local playfield = self.game.chartPreviewModel.playField
	transform = playfield:newNoteskinTransform()

	local sequenceView = self.sequenceView
	sequenceView.game = self.game
	sequenceView.subscreen = "preview"
	-- sequenceView:setSequenceConfig(playfield)

	sequenceView:setSequenceConfig({
		ChartPreviewRhythmView({
			transform = transform,
			subscreen = "preview",
		}),
	})
	sequenceView:load()

	self.loaded = true
end

---@param dt number
function ChartPreviewView:update(dt)
	if not self.loaded then
		self:load()
	end
	self.sequenceView:update(dt)
end

---@param event table
function ChartPreviewView:receive(event)
	self.sequenceView:receive(event)
end

function ChartPreviewView:draw()
	if not self.loaded then
		return
	end

	local w = 0

	local noteSkin = self.game.chartPreviewModel.noteSkin
	local columns = noteSkin.columns
	local column_width = noteSkin.width

	for i, v in ipairs(column_width) do
		w = w + v
	end

	local h = love.graphics.getHeight()
	love.graphics.replaceTransform(gfx_util.transform(transform))
	love.graphics.setColor({ 0, 0, 0, 0.4 })
	love.graphics.rectangle("fill", columns[1] - 10, 0, w / 2 + 20, h)

	self.sequenceView:draw()
end

function ChartPreviewView:unload()
	self.sequenceView:unload()
end

return ChartPreviewView
