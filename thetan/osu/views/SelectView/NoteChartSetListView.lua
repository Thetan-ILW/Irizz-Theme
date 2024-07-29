local ListView = require("thetan.irizz.views.ListView")
local gyatt = require("thetan.gyatt")
local math_util = require("math_util")
local Format = require("sphere.views.Format")

local NoteChartSetListView = ListView + {}

NoteChartSetListView.rows = 7
NoteChartSetListView.centerItems = true
NoteChartSetListView.staticCursor = false
NoteChartSetListView.focus = false
NoteChartSetListView.mouseScrollEase = { "quartout", 0.45 }

NoteChartSetListView.assets = {}
NoteChartSetListView.activeTextColor = { 0, 0, 0, 1 }
NoteChartSetListView.inactiveTextColor = { 1, 1, 1, 1 }
NoteChartSetListView.previewIcon = false
---@type number[]
NoteChartSetListView.animations = {}

---@param game sphere.GameController
---@param assets osu.OsuAssets
function NoteChartSetListView:new(game, assets)
	ListView:new(game)
	self.game = game

	self.assets = assets
	self.font = assets.localization.fontGroups.chartSetList

	local active_str = self.assets.params.songSelectActiveText
	local inactive_str = self.assets.params.songSelectInactiveText

	---@cast active_str string
	---@cast inactive_str string

	if active_str then
		local colors = string.split(active_str, ",")
		self.activeTextColor = { tonumber(colors[1]) / 255, tonumber(colors[2]) / 255, tonumber(colors[3]) / 255, 1 }
	end

	if inactive_str then
		local colors = string.split(inactive_str, ",")
		self.inactiveTextColor = { tonumber(colors[1]) / 255, tonumber(colors[2]) / 255, tonumber(colors[3]) / 255, 1 }
	end

	self.scrollSound = assets.sounds.selectChart
end

function NoteChartSetListView:reloadItems()
	self.stateCounter = self.game.selectModel.noteChartSetStateCounter
	self.items = self.game.selectModel.noteChartSetLibrary.items
end

---@return number
function NoteChartSetListView:getItemIndex()
	return self.game.selectModel.chartview_set_index
end

---@param count number
function NoteChartSetListView:scroll(count)
	if not self.focus then
		return
	end

	self.game.selectModel:scrollNoteChartSet(count)
	if math.abs(count) ~= 1 then
		return
	end
	self.direction = count
	self:playSound()
end

function NoteChartSetListView:mouseClick(w, h, i)
	if not self.focus then
		return
	end

	if gyatt.isOver(w, h, 0, 0) then
		if gyatt.mousePressed(1) then
			if i == self.itemIndex + math.floor(self.rows / 2) then
				self.game.selectView:play()
			end

			if self.itemIndex - i == -7 then
				return
			end

			self.game.selectModel:scrollNoteChartSet(i - (self.itemIndex + math.floor(self.rows / 2)))
		end
	end
end

local gfx = love.graphics

function NoteChartSetListView:updateAnimations()
	for i, v in pairs(self.animations) do
		v = v - 0.009

		self.animations[i] = v

		if v < 0 then
			self.animations[i] = nil
		end
	end
end

function NoteChartSetListView:update(w, h)
	ListView.update(self, w, h)

	local irizz = self.game.configModel.configs.irizz
	self.previewIcon = irizz.osuSongSelectPreviewIcon
end

---@param i number
---@param w number
---@param h number
function NoteChartSetListView:drawItem(i, w, h)
	local img = self.assets.images
	local item = self.items[i]

	local distance = self.visualItemIndex - i
	local distance_abs = math.abs(distance)
	local d_clamped = math_util.clamp(distance_abs, 0, 1)
	local additional = 0

	if i ~= self.targetItemIndex then
		additional = 50 * d_clamped
	end

	local animation = self.animations[i] or 0

	gfx.translate((80 * distance_abs) * 0.4 - (animation * 10) + additional + 10, (-5 * distance) - 10)

	animation = animation * 0.5
	gfx.setColor({
		1 - (1 - 0.87 - animation) * d_clamped,
		1 - (1 - 0.28 - animation) * d_clamped,
		1 - (1 - 0.57 - animation) * d_clamped,
		1,
	})

	if gyatt.isOver(w, h, 0, 10) and self.focus then
		self.animations[i] = math_util.clamp((self.animations[i] or 0) + 0.03, 0, 0.55)
	end

	gfx.draw(img.listButtonBackground, 0, (103 - img.listButtonBackground:getHeight()) / 2)

	local mixed_color = {
		(1 - d_clamped) * self.activeTextColor[1] + d_clamped * self.inactiveTextColor[1],
		(1 - d_clamped) * self.activeTextColor[2] + d_clamped * self.inactiveTextColor[2],
		(1 - d_clamped) * self.activeTextColor[3] + d_clamped * self.inactiveTextColor[3],
		1,
	}

	gfx.setColor(mixed_color)

	if self.previewIcon then
		gfx.translate(110, 0)
	end

	gfx.push()
	gfx.translate(20, 12)
	gfx.draw(img.maniaSmallIconForCharts)

	gfx.translate(40, -4)
	gfx.setFont(self.font.title)
	gyatt.text(item.title or "Unknown title")

	gfx.translate(0, -3)
	gfx.setFont(self.font.secondRow)

	---@type string
	local second_row

	if item.format == "sm" then
		second_row = ("%s // %s"):format(item.artist, item.set_dir)
	else
		second_row = ("%s // %s"):format(item.artist, item.creator)
	end

	gyatt.text(second_row)

	gfx.translate(0, -2)
	gfx.setFont(self.font.thirdRow)
	gyatt.text(("%s (%s)"):format(item.name, Format.inputMode(item.inputmode)))
	gfx.pop()

	local iw, ih = img.star:getDimensions()

	gfx.translate(60, h - ih * 0.6 + 10)
	gfx.scale(0.6)

	for si = 1, 10, 1 do
		if si >= (item.osu_diff or 0) then
			gfx.setColor({ 1, 1, 1, 0.3 })
		end

		gfx.draw(img.star)
		gfx.translate(iw, 0)
		gfx.setColor(mixed_color)
	end

	gfx.scale(1)
end

return NoteChartSetListView
