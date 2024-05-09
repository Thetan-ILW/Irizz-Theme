local modulePatcher = require("ModulePatcher")

local module = "sphere.controllers.SelectController"

modulePatcher:insert(module, "load", function(self, view)
	local selectModel = self.selectModel
	local previewModel = self.previewModel

	self.view = view
	self.configModel:write()
	self.playContext:load(self.configModel.configs.play)
	self.modifierSelectModel:updateAdded()

	self.selectModel:setLock(false)

	selectModel:load()
	previewModel:load()

	self:applyModifierMeta()
end)

modulePatcher:insert(module, "update", function(self)
	self.previewModel:update()

	self.windowModel:setVsyncOnSelect(true)

	local selectModel = self.selectModel
	if selectModel:isChanged() then
		self.backgroundModel:setBackgroundPath(selectModel.chartview)
		self.previewModel:setAudioPathPreview(selectModel:getAudioPathPreview())
		self:applyModifierMeta()
		self.view:notechartChanged()
	end

	local osudirectModel = self.osudirectModel
	if osudirectModel:isChanged() then
		local backgroundUrl = osudirectModel:getBackgroundUrl()
		local previewUrl = osudirectModel:getPreviewUrl()
		self.backgroundModel:setBackgroundPath(backgroundUrl)
		self.previewModel:setAudioPathPreview(previewUrl)
	end

	if self.modifierSelectModel:isChanged() then
		self.multiplayerModel:pushPlayContext()
		self:applyModifierMeta()
	end

	if #self.configModel.configs.online.token == 0 then
		return
	end
end)
