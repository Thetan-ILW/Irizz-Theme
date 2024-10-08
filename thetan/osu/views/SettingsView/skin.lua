local GroupContainer = require("thetan.osu.views.SettingsView.GroupContainer")
local Elements = require("thetan.osu.views.SettingsView.Elements")
local Label = require("thetan.osu.ui.Label")
local consts = require("thetan.osu.views.SettingsView.Consts")
local utf8validate = require("utf8validate")
local Format = require("sphere.views.Format")

---@param assets osu.OsuAssets
---@param view osu.SettingsView
---@param skin_preview osu.ui.SkinPreview
---@return osu.SettingsView.GroupContainer?
return function(assets, view, skin_preview)
	local text, font = assets.localization:get("settings")
	assert(text and font)

	local configs = view.game.configModel.configs
	local settings = configs.settings
	---@type osu.OsuConfig
	local osu = configs.osu_ui
	local g = settings.gameplay
	local graphics = settings.graphics
	local p = graphics.perspective

	local c = GroupContainer("SKIN", assets, font, assets.images.skinTab)

	Elements.assets = assets
	Elements.currentContainer = c
	local combo = Elements.combo
	local checkbox = Elements.checkbox
	local slider = Elements.slider
	local button = Elements.button

	c:createGroup("skin", text.skin)
	Elements.currentGroup = "skin"

	if Elements.canAdd("skin") then
		c:add("skin", skin_preview)
	end

	local input_mode = ""

	combo(text.currentSkin, "Default", nil, function()
		input_mode = tostring(view.game.selectController.state.inputMode)
		local selected_note_skin = view.game.noteSkinModel:getNoteSkin(input_mode)
		local skins = view.game.noteSkinModel:getSkinInfos(input_mode)
		return selected_note_skin, skins
	end, function(v)
		view.game.noteSkinModel:setDefaultNoteSkin(input_mode, v:getPath())
		local skin_preview_img = view.game.assetModel:loadSkinPreview(v.dir)
		skin_preview:setImage(skin_preview_img)
	end, function(v)
		---@type string
		local k = Format.inputMode(input_mode)
		local name = ("[%s] %s"):format(k, v.name)
		if not name then
			return "??"
		end
		local len = name:len()
		if len > 38 then
			return utf8validate(name:sub(1, 38), ".") .. ".."
		end

		return name
	end)

	local prev_color = Elements.buttonColor
	Elements.buttonColor = { 0.84, 0.38, 0.47, 1 }
	button(text.previewGameplay, function()
		if not view.game.selectModel:notechartExists() then
			return
		end

		view.game.rhythmModel:setAutoplay(true)
		view.game.gameView.view:changeScreen("gameplayView")
	end)
	Elements.buttonColor = prev_color

	button(text.openSkinSettings, function()
		view.game.gameView.view:openModal("thetan.irizz.views.modals.NoteSkinModal")
	end)

	button(text.openCurrentSkinFolder, function()
		love.system.openURL(love.filesystem.getSource() .. "/userdata/skins/" .. osu.skin)
	end)

	local ln_shortening = { min = -300, max = 0, increment = 10 }
	slider(text.lnShortening, 0, nil, function()
		return g.longNoteShortening * 1000, ln_shortening
	end, function(v)
		g.longNoteShortening = v / 1000
	end, function(v)
		return ("%ims"):format(v)
	end)

	c:createGroup("result", text.resultScreen)
	Elements.currentGroup = "result"
	checkbox(text.showHitGraph, false, nil, function()
		return osu.result.hitGraph
	end, function()
		osu.result.hitGraph = not osu.result.hitGraph
	end)

	checkbox(text.showPP, false, nil, function()
		return osu.result.pp
	end, function()
		osu.result.pp = not osu.result.pp
	end)

	c:createGroup("camera", text.camera)
	Elements.currentGroup = "camera"

	if Elements.canAdd("camera") then
		c:add(
			"camera",
			Label(assets, {
				text = text.cameraControls,
				font = font.labels,
				pixelWidth = consts.labelWidth - 24 - 28,
				pixelHeight = 128,
				align = "left",
			})
		)
	end

	checkbox(text.enableCamera, false, nil, function()
		return p.camera
	end, function()
		p.camera = not p.camera
	end)

	checkbox(text.cameraX, false, nil, function()
		return p.rx
	end, function()
		p.rx = not p.rx
	end)

	checkbox(text.cameraY, false, nil, function()
		return p.ry
	end, function()
		p.ry = not p.ry
	end)

	c:removeEmptyGroups()

	if c.isEmpty then
		return nil
	end

	return c
end
