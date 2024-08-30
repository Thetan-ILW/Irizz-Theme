local GroupContainer = require("thetan.osu.views.SettingsView.GroupContainer")
local Elements = require("thetan.osu.views.SettingsView.Elements")
local utf8validate = require("utf8validate")
local Format = require("sphere.views.Format")

---@param assets osu.OsuAssets
---@param view osu.SettingsView
---@return osu.SettingsView.GroupContainer?
return function(assets, view)
	local font = assets.localization.fontGroups.settings

	local configs = view.game.configModel.configs
	local settings = configs.settings
	---@type osu.OsuConfig
	local osu = configs.osu_ui
	local g = settings.gameplay
	local graphics = settings.graphics
	local p = graphics.perspective

	local c = GroupContainer("SKIN", assets, font, assets.images.maintenanceTab)

	Elements.assets = assets
	Elements.currentContainer = c
	local combo = Elements.combo
	local checkbox = Elements.checkbox
	local slider = Elements.slider
	local button = Elements.button

	c:createGroup("skin", "SKIN")
	Elements.currentGroup = "skin"

	local input_mode = ""

	combo("Current skin:", "Default", nil, function()
		input_mode = tostring(view.game.selectController.state.inputMode)
		local selected_note_skin = view.game.noteSkinModel:getNoteSkin(input_mode)
		local skins = view.game.noteSkinModel:getSkinInfos(input_mode)
		return selected_note_skin, skins
	end, function(v)
		view.game.noteSkinModel:setDefaultNoteSkin(input_mode, v:getPath())
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
	button("Preview gameplay", function()
		if not view.game.selectModel:notechartExists() then
			return
		end

		view.game.rhythmModel:setAutoplay(true)
		view.game.gameView.view:changeScreen("gameplayView")
	end)
	Elements.buttonColor = prev_color

	button("Open skin settings", function()
		view.game.gameView.view:openModal("thetan.irizz.views.modals.NoteSkinModal")
	end)

	button("Open current skin folder", function()
		love.system.openURL(love.filesystem.getSource() .. "/userdata/skins/" .. osu.skin)
	end)

	local ln_shortening = { min = -300, max = 0, increment = 10 }
	slider("LN shortening", 0, nil, function()
		return g.longNoteShortening * 1000, ln_shortening
	end, function(v)
		g.longNoteShortening = v / 1000
	end)

	c:createGroup("result", "RESULT SCREEN")
	Elements.currentGroup = "result"
	checkbox("Show hit graph", false, nil, function()
		return osu.resultHitGraph
	end, function()
		osu.resultHitGraph = not osu.resultHitGraph
	end)

	checkbox("Show PP", false, nil, function()
		return osu.resultPP
	end, function()
		osu.resultPP = not osu.resultPP
	end)

	c:createGroup("camera", "3D CAMERA")
	Elements.currentGroup = "camera"

	checkbox("Enable 3D camera", false, nil, function()
		return p.camera
	end, function()
		p.camera = not p.camera
	end)

	checkbox("Allow rotation of X coordinate", false, nil, function()
		return p.rx
	end, function()
		p.rx = not p.rx
	end)

	checkbox("Allow rotation of Y coordinate", false, nil, function()
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
