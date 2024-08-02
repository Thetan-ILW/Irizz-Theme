local PlayerProfileModel = require("thetan.playerProfile.models.PlayerProfileModel")
local dans = require("thetan.playerProfile.models.PlayerProfileModel.dans")

PlayerProfileModel.testing = true
local model = PlayerProfileModel()

local function test()
	local delta = false

	for i, v in ipairs(dans["4key"].regular) do
		if v.name == "Delta" then
			delta = delta or (v.hash == "6432f864b074264c230604cfe142edb0_4key")
		end
	end

	assert(delta)

	model:addScore("c9927b9b467c5958994ad215abb60609_7key", {
		mode = "7key",
		time = 0,
		osuAccuracy = 0.96,
		osuPP = 500,
	})

	assert(model.scores["c9927b9b467c5958994ad215abb60609_7key"].osuPP == 500)

	model:addScore("c9927b9b467c5958994ad215abb60609_7key", {
		mode = "7key",
		time = 0,
		osuAccuracy = 0.95,
		osuPP = 450,
	})

	assert(model.scores["c9927b9b467c5958994ad215abb60609_7key"].osuPP == 500)

	assert(model.pp == 500)

	model:addScore("2468732_7key", {
		mode = "4key",
		time = 0,
		osuAccuracy = 0.95,
		osuPP = 200,
	})

	assert(model.pp > 689)
end

test()
PlayerProfileModel.testing = false
