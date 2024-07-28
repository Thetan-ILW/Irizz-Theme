local RhythmModel = require("sphere.models.RhythmModel")

function RhythmModel:unloadAllEngines(stop_audio_engine)
	if not stop_audio_engine then
		self.audioEngine:unload()
	end

	self.logicEngine:unload()
	self.graphicEngine:unload()
end
