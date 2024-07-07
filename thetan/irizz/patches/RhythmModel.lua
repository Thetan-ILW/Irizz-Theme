local modulePatcher = require("ModulePatcher")

modulePatcher:insert("sphere.models.RhythmModel", "unloadAllEngines", function(_self, stopAudioEngine)
	if not stopAudioEngine then
		_self.audioEngine:unload()
	end

	_self.logicEngine:unload()
	_self.graphicEngine:unload()
end)
