local class = require("class")
local just = require("just")
local imgui = require("imgui")
local gfx_util = require("gfx_util")

local Layout = require("thetan.iris.views.SelectView.CollectionsLayout")

local Theme = require("thetan.iris.views.Theme")
local Color = Theme.colors
local Text = Theme.textCollections
local Font

local CollectionListView = require("thetan.iris.views.SelectView.CollectionListView")
local OsuDirectListView = require("thetan.iris.views.SelectView.OsuDirectListView")
local OsuDirectChartsListView = require("thetan.iris.views.SelectView.OsuDirectChartsListView")
local OsuDirectQueueListView = require("thetan.iris.views.SelectView.OsuDirectQueueListView")

local ViewConfig = class()

function ViewConfig:new(game)
	self.collectionListView = CollectionListView(game)
	self.collectionListView.scrollSound = love.audio.newSource("iris/sounds/hitsound_retro3.wav", "static")
	self.osuDirectListView = OsuDirectListView(game)
	self.osuDirectListView.scrollSound = love.audio.newSource("iris/sounds/hitsound_retro3.wav", "static")
	self.osuDirectChartsListView = OsuDirectChartsListView(game)
	self.osuDirectChartsListView.scrollSound = love.audio.newSource("iris/sounds/hitsound_retro5.wav", "static")
	self.osuDirectQueueListView = OsuDirectQueueListView(game)
	self.osuDirectQueueListView.scrollSound = love.audio.newSource("iris/sounds/hitsound_retro5.wav", "static")
	Font = Theme:getFonts("collectionsViewConfig")
end

local function frame(w, h)
	love.graphics.setColor(Color.panel)
	love.graphics.rectangle("fill", 0, 0, w, h)

end

local function border(w, h)
	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(4)
	love.graphics.setColor(Color.border)
	love.graphics.rectangle("line", -2, -2, w+3, h+3)
end

function ViewConfig:cacheStatus(view)
	local cacheModel = view.game.cacheModel
	local shared = cacheModel.shared
	local state = shared.state

	local text = ""
	if state == 1 then
		text = (Text.searching):format(shared.noteChartCount)
	elseif state == 2 then
		text = (Text.creatingCache):format(shared.cachePercent)
	elseif state == 3 then
		text = Text.complete
	else
		text = Text.idle
	end

	local w, h = Layout:move("status")
	love.graphics.setFont(Font.status)
	love.graphics.setColor(Color.text)
	gfx_util.printBaseline(text, 0, h/2, w, 1, "center")
end

function ViewConfig:osuDirectDownloadQueue(view)
	local w, h = Layout:move("queue")
	frame(w, h)
	self.osuDirectQueueListView:draw(w, h)
	border(w, h)
end

function ViewConfig:osuDirectCharts(view)
	local w, h = Layout:move("charts")
	frame(w, h)
	self.osuDirectChartsListView:draw(w, h)
	border(w, h)
end

function ViewConfig:buttons(view)
	local w, h = Layout:move("buttons")
	frame(w, h)

	love.graphics.setColor(Color.text)
	love.graphics.setFont(Font.buttons)

	w, h = Layout:move("button1")
	if view.collectionsMode == "Collections" then
		if imgui.TextOnlyButton("cache", Text.cache, w, h) then
			view.game.selectController:updateCacheCollection(
				view.game.selectModel.collectionItem.path,
				love.keyboard.isDown("lshift")
			)
		end
	else
		local set = view.game.osudirectModel.beatmap
		if set then
			local buttonText = set.downloaded and Text.redownload or Text.download
	
			if imgui.TextOnlyButton("download", buttonText, w, h) then
				view.game.osudirectModel:downloadBeatmapSet(set)
			end
		end
	end

	w, h = Layout:move("button2")
	if view.collectionsMode == "Collections" then
		if imgui.TextOnlyButton("osuDirect", Text.osuDirect, w, h) then
			view:switchToOsudirect()
			self.osuDirectChartsListView.noItemsText = Text.noCharts
		end
	else
		if imgui.TextOnlyButton("collections", Text.collections, w, h) then
			view:switchToCollections()
			self.osuDirectChartsListView.noItemsText = Text.notInOsuDirect
		end
	end

	w, h = Layout:move("button3")
	if imgui.TextOnlyButton("mounts", Text.mounts, w, h) then
		view.gameView:setModal(require("sphere.views.MountsView"))
	end
	
	love.graphics.setColor(Color.mutedBorder)
	w, h = Layout:move("line1")
	love.graphics.rectangle("fill", w/2 - w/4, h - 5, w/2, 4)
	w, h = Layout:move("line2")
	love.graphics.rectangle("fill", w/2 - w/4, h - 5, w/2, 4)

	w, h = Layout:move("buttons")
	border(w, h)
end

function ViewConfig:collectionsList(view)
	if view.collectionsMode ~= "Collections" then
		return
	end

	local w, h = Layout:move("list")
	frame(w, h)
	self.collectionListView:draw(w, h)
	border(w, h)
end

function ViewConfig:osuDirectList(view)
	if view.collectionsMode ~= "osu!direct" then
		return
	end

	local w, h = Layout:move("list")
	frame(w, h)
	self.osuDirectListView:draw(w, h)
	border(w, h)
end

function ViewConfig:footer(view)
	local w, h = Layout:move("name")
	love.graphics.setFont(Font.titleAndMode)
	love.graphics.setColor(Color.text)

	if view.collectionsMode == "Collections" then
		local name = self.collectionListView:getItem().name
		just.text(name, w)
	end

	w, h = Layout:move("mode")
	just.text(view.collectionsMode, w, true)
end

function ViewConfig:update(view)
	if view.collectionsMode == "Collections" then
		self.collectionListView:update()
	else
		self.osuDirectListView:update()
	end
end

function ViewConfig:draw(view)
	self:cacheStatus(view)
	self:osuDirectDownloadQueue(view)
	self:collectionsList(view)
	self:osuDirectList(view)
	self:buttons(view)
	self:osuDirectCharts(view)
	self:footer(view)
end

return ViewConfig