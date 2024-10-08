local IViewConfig = require("thetan.skibidi.views.IViewConfig")

local gyatt = require("thetan.gyatt")
local flux = require("flux")
local math_util = require("math_util")
local consts = require("thetan.osu.views.SettingsView.Consts")
local Layout = require("thetan.osu.views.OsuLayout")

---@class osu.SettingsViewConfig : IViewConfig
---@operator call: osu.SettingsViewConfig
---@field focus boolean
---@field modalActive boolean
---@field hoverRectPosition number
---@field hoverRectTargetPosition number
---@field hoverRectTargetSize number
---@field hoverRectTween table?
---@field tabFocusAnimation number
---@field tabFocusTween table?
---@field tipAnimation number
---@field tipTween table?
---@field currentTip string?
local ViewConfig = IViewConfig + {}

local visibility = 0
local tip_hover = false

---@type table<string, love.Image>
local img
---@type table<string, love.Font>
local font

local tab_focus = 0

local gfx = love.graphics

---@param view osu.SettingsView
---@param assets osu.OsuAssets
function ViewConfig:new(view, assets)
	img = assets.images
	font = assets.localization.fontGroups.settings
	self.focus = false
	self.modalActive = false
	self.hoverRectPosition = 0
	self.hoverRectTargetPosition = 0
	self.hoverRectTargetSize = 0
	self.tabFocusAnimation = 1
	self.tipAnimation = 0
end

local tab_image_height = 64
local tab_image_spacing = 32
local tab_image_scale = 0.5
local tab_image_indent = 64 / 2 - (64 * tab_image_scale) / 2

---@param view osu.SettingsView
function ViewConfig:tabs(view)
	local w, h = Layout:move("base")

	gfx.setColor(0, 0, 0, visibility)
	gfx.rectangle("fill", 0, 0, 64, h)

	local tab_count = #view.containers

	local total_h = tab_count * (tab_image_height * tab_image_scale) + (tab_count - 1) * tab_image_spacing

	gfx.translate(tab_image_indent, h / 2 - total_h / 2)

	for i, c in ipairs(view.containers) do
		gfx.setColor(0.6, 0.6, 0.6, visibility)

		if gyatt.isOver(64, 64) then
			gfx.setColor(1, 1, 1, visibility)

			if gyatt.mousePressed(1) then
				view:jumpTo(i)
			end
		end

		gfx.draw(c.icon, 0, 0, 0, tab_image_scale, tab_image_scale)

		gfx.translate(0, (tab_image_height * tab_image_scale) + tab_image_spacing)
	end

	w, h = Layout:move("base")

	gfx.setColor(0.92, 0.46, 0.55, visibility)
	local i = self.tabFocusAnimation - 1
	gfx.translate(
		59,
		h / 2
			- total_h / 2
			+ (tab_image_height * tab_image_scale) * i
			+ (tab_image_spacing * i)
			- (tab_image_height * tab_image_scale / 2)
	)
	gfx.rectangle("fill", 0, 0, 6, tab_image_height)
end

function ViewConfig:tip()
	if self.tipAnimation == 0 then
		return
	end

	local text = self.currentTip

	if not text then
		return
	end

	local sw, sh = Layout:move("base")
	local mx, my = gfx.inverseTransformPoint(love.mouse.getPosition())

	local f = font.tip
	local w = f:getWidth(text) * gyatt.getTextScale() + 12
	local h = f:getHeight() * gyatt.getTextScale() + 4

	local x = math_util.clamp(mx - w / 2, 2, sw - 2)
	local y = my + img.cursor:getHeight() / 2

	local a = self.tipAnimation

	gfx.setColor(0, 0, 0, a)
	gfx.rectangle("fill", x, y, w, h, 4, 4)

	gfx.setColor(1, 1, 1, 0.5 * a)
	gfx.setLineWidth(1)
	gfx.rectangle("line", x, y, w, h, 4, 4)

	gfx.setColor(1, 1, 1, a)
	gfx.setFont(f)
	gyatt.frame(text, x, y, w, h, "center", "center")
end

---@param view osu.SettingsView
function ViewConfig:panel(view)
	local w, h = Layout:move("base")
	local scale = gfx.getHeight() / 768

	gfx.setColor(0, 0, 0, 0.7 * visibility)
	self.focus = gyatt.isOver(64 + 438 * visibility, h) and self.modalActive

	gfx.translate(64, 0)
	gfx.rectangle("fill", 0, 0, 438 * visibility, h)

	local prev_canvas = gfx.getCanvas()
	local canvas = gyatt.getCanvas("settings_containers")

	gfx.setCanvas(canvas)

	gfx.clear()
	gfx.setBlendMode("alpha", "alphamultiply")

	if view.hoverPosition ~= self.hoverRectPosition and self.focus then
		if self.hoverRectTween then
			self.hoverRectTween:stop()
		end
		self.hoverRectPosition = view.hoverPosition
		self.hoverRectTween =
			flux.to(self, 0.6, { hoverRectTargetPosition = view.hoverPosition, hoverRectTargetSize = view.hoverSize })
				:ease("elasticout")
	end

	gfx.translate(0, view.scrollPosition)

	local search_pos = view.topSpacing:getHeight() + view.optionsLabel:getHeight() + view.gameBehaviorLabel:getHeight()
	local floating_search = -view.scrollPosition > search_pos

	view.topSpacing:draw()
	view.optionsLabel:update()
	view.optionsLabel:draw()
	view.gameBehaviorLabel:update()
	view.gameBehaviorLabel:draw()

	gfx.push()
	if not floating_search then
		view.searchLabel:draw()
	end
	gfx.pop()

	view.headerSpacing:draw()

	gfx.setColor(0, 0, 0, 0.6 * (1 - math_util.clamp(love.timer.getTime() - view.hoverTime, 0, 0.5) * 2))
	gfx.rectangle("fill", 0, self.hoverRectTargetPosition, 438, self.hoverRectTargetSize)

	---@type osu.ui.Combo[]
	local open_combos = {}
	---@type string?
	local tip = nil

	for _, c in ipairs(view.containers) do
		if -view.scrollPosition + 768 > c.position and -view.scrollPosition < c.position + c.height then
			c:draw(self.focus)
			tip = tip or c.tip

			if #c.openCombos ~= 0 then
				for _, combo in ipairs(c.openCombos) do
					table.insert(open_combos, combo)
				end
			end
		else
			gfx.translate(0, c.height)
		end
	end

	view.bottomSpacing:draw()

	if #open_combos ~= 0 then
		for i = #open_combos, 1, -1 do
			gfx.pop()
			open_combos[i]:drawBody()
		end
	end

	if floating_search then
		w, h = Layout:move("base")
		local a = math_util.clamp(-view.scrollPosition - search_pos, 0, 100) / 100
		gfx.setColor(0, 0, 0, 0.6 * a)
		gfx.translate(64, -24 * a)
		gfx.rectangle("fill", 0, 0, consts.settingsWidth, 80)
		view.searchLabel:draw()
	end

	gfx.setCanvas(prev_canvas)

	gfx.origin()
	gfx.setColor(1 * visibility, 1 * visibility, 1 * visibility, 1 * visibility)
	gfx.setScissor(64 * scale, 0, visibility * (438 * scale), h * scale)
	gfx.setBlendMode("alpha", "premultiplied")
	gfx.draw(canvas)
	gfx.setBlendMode("alpha")
	gfx.setScissor()

	if tip then
		if not tip_hover then
			if self.tipTween then
				self.tipTween:stop()
			end
			self.tipTween = flux.to(self, 0.2, { tipAnimation = 1 }):ease("quadout")
		end

		self.currentTip = tip

		tip_hover = true
	else
		if tip_hover then
			if self.tipTween then
				self.tipTween:stop()
			end
			self.tipTween = flux.to(self, 0.2, { tipAnimation = 0 }):ease("quadout")
		end

		tip_hover = false
	end

	self:tip()
end

---@param view osu.SettingsView
function ViewConfig:back(view)
	local btn = view.backButton
	local w, h = Layout:move("base")
	local ih = btn:getHeight()
	gfx.translate(0, h - 58)
	btn.alpha = visibility
	btn:update(self.focus)
	btn:draw()
end

---@param view osu.SettingsView
function ViewConfig:draw(view)
	Layout:draw()
	visibility = view.visibility

	local last_tab_focus = tab_focus

	for i, c in ipairs(view.containers) do
		if -view.scrollPosition + 768 / 2 > c.position then
			tab_focus = i
			gfx.setColor(1, 1, 1, visibility)
		end
	end

	if last_tab_focus ~= tab_focus then
		if self.tabFocusTween then
			self.tabFocusTween:stop()
		end
		self.tabFocusTween = flux.to(self, 0.2, { tabFocusAnimation = tab_focus }):ease("cubicout")
	end

	self:tabs(view)
	self:panel(view)
	self:back(view)
end

return ViewConfig
