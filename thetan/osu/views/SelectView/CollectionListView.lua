local ListView = require("thetan.irizz.views.ListView")
local gyatt = require("thetan.gyatt")
local math_util = require("math_util")
local Format = require("sphere.views.Format")

local Theme = require("thetan.irizz.views.Theme")

local CollectionListView = ListView + {}

CollectionListView.rows = 7
CollectionListView.centerItems = true
CollectionListView.text = Theme.textChartSetsList
CollectionListView.staticCursor = false
CollectionListView.focus = false
CollectionListView.mouseScrollEase = { "quartout", 0.45 }

CollectionListView.assets = {}
CollectionListView.activeTextColor = { 0, 0, 0, 1 }
CollectionListView.inactiveTextColor = { 1, 1, 1, 1 }
---@type number[]
CollectionListView.animations = {}

---@param game sphere.GameController
---@param assets osu.OsuSelectAssets
function CollectionListView:new(game, assets)
	ListView:new(game)
	self.game = game

	self.assets = assets

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

	self:loadFonts()
end

function CollectionListView:reloadItems()
	self.stateCounter = 0
	self.items = self.game.selectModel.collectionLibrary.tree.items
end

---@return number
function CollectionListView:getItemIndex()
	local tree = self.game.selectModel.collectionLibrary.tree
	return tree.selected
end

---@return table
function CollectionListView:getItem()
	return self.items[self:getItemIndex()]
end

---@param count number
function CollectionListView:scroll(count)
	self.game.selectModel:scrollCollection(count)

	if math.abs(count) ~= 1 then
		return
	end
	self:playSound()
end

function CollectionListView:mouseClick(w, h, i)
	if not self.focus then
		return
	end

	if gyatt.isOver(w, h, 0, 0) then
		if gyatt.mousePressed(1) then
			if self.itemIndex - i == -7 then
				return
			end

			--self.game.selectModel:scrollNoteChartSet(i - (self.itemIndex + math.floor(self.rows / 2)))
		end
	end
end

local gfx = love.graphics

function CollectionListView:updateAnimations()
	for i, v in pairs(self.animations) do
		v = v - 0.009

		self.animations[i] = v

		if v < 0 then
			self.animations[i] = nil
		end
	end
end

function CollectionListView:loadFonts()
	local ww, wh = love.graphics.getDimensions()
	self.font = Theme:getFonts("osuChartSetList", wh / 768)
end

function CollectionListView:update(w, h)
	ListView.update(self, w, h)

	local irizz = self.game.configModel.configs.irizz
	self.previewIcon = irizz.osuSongSelectPreviewIcon
end

---@param i number
---@param w number
---@param h number
function CollectionListView:drawItem(i, w, h)
	local img = self.assets.images
	local tree = self.game.selectModel.collectionLibrary.tree
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

	---@type string
	local name = item.name

	if item.depth == tree.depth and item.depth ~= 0 then
		name = "."
	elseif item.depth == tree.depth - 1 then
		name = ".."
	end

	gfx.translate(40, 8)
	gfx.setFont(self.font.title)
	gyatt.text(name)

	gfx.translate(0, -3)
	gfx.setFont(self.font.secondRow)
	gyatt.text("Charts: " .. (item.count ~= 0 and item.count or "0"))
end

return CollectionListView
