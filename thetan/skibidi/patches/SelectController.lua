local SelectController = require("sphere.controllers.SelectController")

local base_load = SelectController.load

function SelectController:load(view)
	base_load(self)
	self.view = view
end

function SelectController:update()
	self.previewModel:update()

	self.windowModel:setVsyncOnSelect(true)

	local selectModel = self.selectModel
	if selectModel:isChanged() then
		local cv = selectModel.chartview

		if cv then
			self.backgroundModel:setBackgroundPath(cv.location_dir, cv.background_path or "", cv.format) -- <<<
		else
			self.backgroundModel:setBackgroundPath()
		end

		self.previewModel:setAudioPathPreview(selectModel:getAudioPathPreview())
		self.previewModel:onLoad(function()
			self.chartPreviewModel:setChartview(selectModel.chartview)
		end)
		self:applyModifierMeta()
		self.view:notechartChanged() -- <<<
	end

	local osudirectModel = self.osudirectModel
	if osudirectModel:isChanged() then
		local backgroundUrl = osudirectModel:getBackgroundUrl()
		local previewUrl = osudirectModel:getPreviewUrl()
		self.backgroundModel:setBackgroundPath(nil, backgroundUrl, "http")
		self.previewModel:setAudioPathPreview(previewUrl)
	end

	if self.modifierSelectModel:isChanged() then
		self.multiplayerModel:pushPlayContext()
		self:applyModifierMeta()
	end

	if #self.configModel.configs.online.token == 0 then
		return
	end
end
