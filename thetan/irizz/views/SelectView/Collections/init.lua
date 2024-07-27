local class = require("class")
local just = require("just")
local gyatt = require("thetan.gyatt")
local imgui = require("thetan.irizz.imgui")
local ui = require("thetan.irizz.ui")

local Layout = require("thetan.irizz.views.SelectView.Collections.CollectionsLayout")

local Theme = require("thetan.irizz.views.Theme")
local Color = Theme.colors
---@type table<string, string>
local text
---@type table<string, love.Font>
local font

local CollectionListView = require("thetan.irizz.views.SelectView.Collections.CollectionListView")
local OsuDirectListView = require("thetan.irizz.views.SelectView.Collections.OsuDirectListView")
local OsuDirectChartsListView = require("thetan.irizz.views.SelectView.Collections.OsuDirectChartsListView")
local OsuDirectQueueListView = require("thetan.irizz.views.SelectView.Collections.OsuDirectQueueListView")

local ViewConfig = class()

local canUpdate = false
local collectionsMode = "Collections"

local actionModel

---@param game sphere.GameController
---@param assets irizz.IrizzAssets
function ViewConfig:new(game, assets)
	actionModel = game.actionModel

	font = assets.localization.fontGroups.collections
	text = assets.localization.textGroups.collections

	self.collectionListView = CollectionListView(game, assets)
	self.osuDirectListView = OsuDirectListView(game, assets)
	self.osuDirectChartsListView = OsuDirectChartsListView(game, assets)
	self.osuDirectQueueListView = OsuDirectQueueListView(game, assets)
	self:updateLists()
end

local boxes = {
	"queue",
	"charts",
	"buttons",
	"list",
}

function ViewConfig.panels()
	for _, name in ipairs(boxes) do
		local w, h = Layout:move(name)
		Theme:panel(w, h)
	end
end

local function borders()
	for _, name in ipairs(boxes) do
		local w, h = Layout:move(name)
		Theme:border(w, h)
	end
end

function ViewConfig:updateLists()
	if collectionsMode == "Collections" then
		self.collectionListView:reloadItems()
	else
		self.osuDirectListView:reloadItems()
		self.osuDirectChartsListView:reloadItems()
		self.osuDirectQueueListView:reloadItems()
	end
end

function ViewConfig:osuDirectSearch(view)
	local w, h = Layout:move("searchField")
	love.graphics.setFont(font.searchField)

	local vimMotions = actionModel.isVimMode()

	if not vimMotions or actionModel.isInsertMode() then
		just.focus("osuDirectSearchField")
	end

	local filterString = view.game.osudirectModel.searchString
	--local changed, text =
	--TextInput("osuDirectSearchField", { filterString, text.osuDirectSearchPlaceholder }, nil, w, h)

	local delAll = actionModel.consumeAction("deleteLine")

	if changed == "text" then
		--view.game.osudirectModel:setSearchString(text)
	end

	if delAll then
		view.game.osudirectModel:setSearchString("")
	end

	w, h = Layout:move("searchField")

	if just.button("osuDirectFilterLineButton", just.is_over(w, h)) then
		view:openModal("thetan.irizz.views.modals.FiltersModal")
	end
end

function ViewConfig:osuDirectDownloadQueue(view)
	local w, h = Layout:move("queue")
	local list = self.osuDirectQueueListView
	list:draw(w, h, canUpdate)

	gyatt.scrollBar(list, w, h)
end

function ViewConfig:osuDirectCharts(view)
	local w, h = Layout:move("charts")
	self.osuDirectChartsListView:draw(w, h, canUpdate)
end

function ViewConfig:collectionsButtons(view)
	local w, h = Layout:move("buttons")

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.buttons)

	w, h = Layout:move("button1")

	local configs = view.game.configModel.configs
	local settings = configs.settings
	local ss = settings.select

	local label = ss.locations_in_collections and text.locations or text.directories

	if imgui.TextOnlyButton("locations", label, w, h) then
		ss.locations_in_collections = not ss.locations_in_collections
		view.game.selectModel.collectionLibrary:load(ss.locations_in_collections)
		Theme:playSound("tabButtonClick")
	end

	if imgui.TextOnlyButton("osuDirect", text.osuDirect, w, h) then
		self:setMode(view, "osu!direct")
		Theme:playSound("tabButtonClick")
	end

	w, h = Layout:move("button3")
	if imgui.TextOnlyButton("mounts", text.mounts, w, h) then
		view:openModal("thetan.irizz.views.modals.MountsModal")
		Theme:playSound("tabButtonClick")
	end

	w, h = Layout:move("buttons")
end

function ViewConfig:osuDirectButtons(view)
	local w, h = Layout:move("buttons")

	love.graphics.setColor(Color.text)
	love.graphics.setFont(font.buttons)

	w, h = Layout:move("button1")

	local set = view.game.osudirectModel.beatmap
	if set then
		local buttonText = set.downloaded and text.redownload or text.download

		if imgui.TextOnlyButton("download", buttonText, w, h) then
			view.game.osudirectModel:download(set)
		end
	else
		imgui.TextOnlyButton("wait", text.wait, w, h)
	end

	if imgui.TextOnlyButton("collections", text.collections, w, h) then
		self:setMode(view, "Collections")
	end

	if imgui.TextOnlyButton("mounts", text.mounts, w, h) then
		view:openModal("thetan.irizz.views.modals.MountsModal")
	end

	w, h = Layout:move("buttons")
end

function ViewConfig:collectionsList(view)
	if collectionsMode ~= "Collections" then
		return
	end

	local w, h = Layout:move("list")
	local list = self.collectionListView

	list:draw(w, h, canUpdate)
	gyatt.scrollBar(list, w, h)
end

function ViewConfig:osuDirectList(view)
	if collectionsMode ~= "osu!direct" then
		return
	end

	local w, h = Layout:move("list")
	local list = self.osuDirectListView

	list:draw(w, h, canUpdate)
	gyatt.scrollBar(list, w, h)
end

function ViewConfig:footer(view)
	local w, h = Layout:move("name")
	love.graphics.setFont(font.titleAndMode)
	love.graphics.setColor(Color.text)

	if collectionsMode == "Collections" and #self.collectionListView.items > 0 then
		local name = self.collectionListView:getItem().name
		ui:frameWithShadow(name, 0, 0, w, h, "left", "top")
	end

	w, h = Layout:move("mode")
	ui:frameWithShadow(collectionsMode, 0, 0, w, h, "right", "top")
end

function ViewConfig:getModeName()
	return collectionsMode
end

function ViewConfig:setMode(view, name)
	if name == "Collections" then
		collectionsMode = "Collections"
		view.game.selectModel:debouncePullNoteChartSet()
		self.osuDirectChartsListView.items = {}
	elseif name == "osu!direct" then
		collectionsMode = "osu!direct"
		view.game.osudirectModel:searchNoDebounce()
	else
		error(name .. " collection mode does not exists")
	end
end

function ViewConfig.layoutDraw(position)
	Layout:draw(position)
end

function ViewConfig.canDraw(position)
	return math.abs(position) < 1
end

function ViewConfig:draw(view, position)
	if not self.canDraw(position) then
		return
	end

	canUpdate = position == 0
	canUpdate = canUpdate and not view.modalActive

	if canUpdate then
		self:updateLists()
	end

	just.origin()
	Layout:draw(position)

	self.panels()
	self:osuDirectDownloadQueue(view)
	self:collectionsList(view)
	self:osuDirectList(view)

	if collectionsMode == "Collections" then
		self:collectionsButtons(view)
	else
		self:osuDirectButtons(view)
		self:osuDirectSearch(view)
	end

	self:osuDirectCharts(view)
	self:footer(view)
	borders()
end

return ViewConfig
