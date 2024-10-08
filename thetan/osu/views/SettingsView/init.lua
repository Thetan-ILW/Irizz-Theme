local class = require("class")
local gyatt = require("thetan.gyatt")
local flux = require("flux")
local math_util = require("math_util")

local ViewConfig = require("thetan.osu.views.SettingsView.ViewConfig")
local Label = require("thetan.osu.ui.Label")
local Spacing = require("thetan.osu.ui.Spacing")
local BackButton = require("thetan.osu.ui.BackButton")
local SkinPreview = require("thetan.osu.ui.SkinPreview")
local consts = require("thetan.osu.views.SettingsView.Consts")

local Elements = require("thetan.osu.views.SettingsView.Elements")
local general = require("thetan.osu.views.SettingsView.general")
local graphics = require("thetan.osu.views.SettingsView.graphics")
local gameplay = require("thetan.osu.views.SettingsView.gameplay")
local audio = require("thetan.osu.views.SettingsView.audio")
local skin = require("thetan.osu.views.SettingsView.skin")
local input = require("thetan.osu.views.SettingsView.input")
local maintenance = require("thetan.osu.views.SettingsView.maintenance")

---@class osu.SettingsView
---@operator call: osu.SettingsView
---@field assets osu.OsuAssets
---@field game sphere.GameController
---@field state "hidden" | "fade_in" | "visible" | "fade_out"
---@field visibility number
---@field visibilityTween table?
---@field scrollPosition number
---@field scrollTargetPosition number
---@field scrollTween table?
---@field hoverTime number
---@field hoverPosition number
---@field hoverSize number
---@field containers osu.SettingsView.GroupContainer[]
---@field totalHeight number
---@field topSpacing osu.ui.Spacing
---@field headerSpacing osu.ui.Spacing
---@field bottomSpacing osu.ui.Spacing
---@field optionsLabel osu.ui.Label
---@field gameBehaviorLabel osu.ui.Label
---@field searchLabel osu.ui.Label
---@field searchText string
---@field osuSkins string[]
---@field modalActive boolean
---@field backButton osu.ui.BackButton
---@field skinPreview osu.ui.SkinPreview
local SettingsView = class()

---@type table<string, string>
local text
---@type table<string, love.Font>
local font

---@param assets osu.OsuAssets
---@param game sphere.GameController
function SettingsView:new(assets, game)
	self.assets = assets
	self.game = game
	self.viewConfig = ViewConfig(self, assets)
	self.visibility = 0
	self.state = "hidden"
	self.scrollPosition = 0
	self.scrollTargetPosition = 0
	self.containers = {}
	self.totalHeight = 0
	self.searchText = ""
	self.hoverTime = 0
	self.osuSkins = game.assetModel:getOsuSkins()
	self.modalActive = true
	self.skinPreview = SkinPreview(assets, consts.settingsWidth - consts.tabIndentIndent - consts.tabIndent)

	local input_mode = tostring(game.selectController.state.inputMode)
	local selected_note_skin = game.noteSkinModel:getNoteSkin(input_mode)
	local skin_preview_img = game.assetModel:loadSkinPreview(selected_note_skin.directoryPath)
	self.skinPreview:setImage(skin_preview_img)

	text, font = assets.localization:get("settings")
	assert(font)

	self:build()
end

---@param tab string?
function SettingsView:build(tab)
	gyatt.setTextScale(768 / love.graphics.getHeight())

	local prev_containers = self.containers or {}
	self.topSpacing = Spacing(64)
	self.headerSpacing = Spacing(100)
	self.bottomSpacing = Spacing(256)

	self.optionsLabel = Label(self.assets, {
		text = "Options",
		pixelWidth = consts.labelWidth,
		font = font.optionsLabel,
	})

	self.gameBehaviorLabel = Label(self.assets, {
		text = "Change the way soundsphere behaves",
		pixelWidth = consts.labelWidth,
		font = font.gameBehaviorLabel,
		color = { 0.83, 0.38, 0.47, 1 },
	})

	local assets = self.assets

	Elements.searchText = self.searchText

	if not tab then
		self.containers = {}
		table.insert(self.containers, general(assets, self))
		table.insert(self.containers, graphics(assets, self))
		table.insert(self.containers, gameplay(assets, self))
		table.insert(self.containers, audio(assets, self))
		table.insert(self.containers, skin(assets, self, self.skinPreview))
		table.insert(self.containers, input(assets, self))
		table.insert(self.containers, maintenance(assets, self))
	else
		if tab == "gameplay" then
			table.remove(self.containers, 3)
			table.insert(self.containers, 3, gameplay(assets, self))
		else
			error("you forgor")
		end
	end

	if #self.containers == 0 then
		self.containers = prev_containers
		self.searchText = self.searchText:sub(1, -2)
	end

	local search = self.searchText == "" and "Type to search!" or self.searchText

	self.searchLabel = Label(self.assets, {
		text = search,
		pixelWidth = consts.labelWidth,
		pixelHeight = 100,
		font = font.search,
	})

	------------- Setting positions and heights
	local pos = self.optionsLabel:getHeight()
	pos = pos + self.gameBehaviorLabel:getHeight()
	pos = pos + self.topSpacing:getHeight()
	pos = pos + self.headerSpacing:getHeight()

	for _, c in ipairs(self.containers) do
		c:updateHeight()
		c.position = pos
		pos = pos + c.height
	end

	------------- Scroll limit
	pos = self.optionsLabel:getHeight()
	pos = pos + self.gameBehaviorLabel:getHeight()
	pos = pos + self.topSpacing:getHeight()
	pos = pos + self.headerSpacing:getHeight()
	pos = pos + self.bottomSpacing:getHeight()

	for _, c in ipairs(self.containers) do
		pos = pos + c.height
	end

	self.totalHeight = pos

	self.backButton = BackButton(assets, { w = 64, h = 200 }, function()
		self:processState("hide")
	end)
end

---@private
function SettingsView:open()
	if self.visibilityTween then
		self.visibilityTween:stop()
	end
	self.visibilityTween = flux.to(self, 0.5, { visibility = 1 }):ease("quadout")
	self.state = "fade_in"
end

---@private
function SettingsView:close()
	if self.visibilityTween then
		self.visibilityTween:stop()
	end
	self.visibilityTween = flux.to(self, 0.5, { visibility = 0 }):ease("quadout")
	self.state = "fade_out"
end

---@param event? "toggle" | "hide"
function SettingsView:processState(event)
	local state = self.state
	local toggle = event == "toggle"

	if state == "hidden" then
		if toggle then
			self:open()
		end
	elseif state == "fade_in" then
		if self.visibility == 1 then
			self.state = "visible"
			return
		end
		if toggle or event == "hide" then
			self:close()
		end
	elseif state == "fade_out" then
		if self.visibility == 0 then
			self.state = "hidden"
			return
		end
		if toggle then
			self:open()
		end
	elseif state == "visible" then
		if toggle or event == "hide" then
			self:close()
		end
	end
end

function SettingsView:isFocused()
	if self.state == "hidden" then
		return false
	end

	return self.viewConfig.focus
end

function SettingsView:update(dt)
	self:processState()
	self.viewConfig.modalActive = self.modalActive

	local additional_pos = 0

	for i, c in ipairs(self.containers) do
		if c.hoverPosition ~= 0 then
			self.hoverTime = love.timer.getTime()
			self.hoverPosition = c.hoverPosition + additional_pos
			self.hoverSize = c.hoverSize
		end

		additional_pos = additional_pos + c.height
	end

	if self.state == "hidden" then
		return
	end

	local changed = false
	local prev = self.searchText
	changed, self.searchText = gyatt.textInput(self.searchText)

	if changed and prev ~= self.searchText then
		self.scrollPosition = 0
		self.scrollTargetPosition = 0
		self:build()
	end
end

---@param container_index integer
function SettingsView:jumpTo(container_index)
	self.scrollTargetPosition = self.containers[container_index].position

	if self.scrollTween then
		self.scrollTween:stop()
	end

	self.scrollTween = flux.to(self, 0.4, { scrollPosition = -self.scrollTargetPosition + 64 }):ease("cubicout")
end

function SettingsView:resolutionUpdated()
	self:build()
end

---@param event table
function SettingsView:receive(event)
	if event.name == "wheelmoved" and self.state ~= "hidden" and self.viewConfig.focus then
		---@type number
		local delta = -event[2]
		local max = math_util.clamp(self.totalHeight - 768, 0, self.totalHeight - 768)
		self.scrollTargetPosition = math_util.clamp(self.scrollTargetPosition + (delta * 90), 0, max)

		if self.scrollTween then
			self.scrollTween:stop()
		end

		self.scrollTween = flux.to(self, 0.2, { scrollPosition = -self.scrollTargetPosition }):ease("quadout")
	end
end

function SettingsView:draw()
	if self.state == "hidden" then
		return
	end

	self.viewConfig:draw(self)
end

return SettingsView
