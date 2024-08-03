local PlayerProfileModel = require("thetan.skibidi.models.PlayerProfileModel")
local dans = require("thetan.skibidi.models.PlayerProfileModel.dans")

local function test_constructor()
	local model = PlayerProfileModel()

	local delta = false

	for i, v in ipairs(dans["4key"].regular) do
		if v.name == "Delta" then
			delta = delta or (v.hash == "6432f864b074264c230604cfe142edb0_4key")
		end
	end

	assert(delta)
	assert(model.danInfos["90492cfc1244bb1db82bba87eafe9cda_7key"].name == "Zenith")
end

local function test_scores()
	local model = PlayerProfileModel()

	local chartdiff = {
		osu_diff = 6,
		notes_count = 3000,
		inputmode = "7key",
		rate = 1,
	}

	local score_system = {
		judgements = {
			["osu!legacy OD9"] = {
				accuracy = 0.97,
				score = 870000,
			},
			["Etterna J4"] = {
				accuracy = 0.94,
			},
		},
	}

	model:addScore("sdfsdf_7key", nil, chartdiff, score_system)
	assert(math.floor(model.pp) == 323)

	score_system.judgements["osu!legacy OD9"].score = 850000
	model:addScore("sdfsdf_7key", nil, chartdiff, score_system)
	assert(math.floor(model.pp) == 323)

	score_system.judgements["osu!legacy OD9"].score = 999999
	model:addScore("sdfsdf_7key", nil, chartdiff, score_system)
	assert(math.floor(model.pp) > 360)

	model:addScore("qqqqq_7key", nil, chartdiff, score_system)
end

local function test_dans()
	local model = PlayerProfileModel()

	local chartdiff = {
		osu_diff = 6,
		notes_count = 3000,
		inputmode = "7key",
		rate = 1,
	}

	local score_system = {
		judgements = {
			["osu!legacy OD9"] = {
				accuracy = 0.97,
				score = 870000,
			},
			["Etterna J4"] = {
				accuracy = 0.94,
			},
			["osu!mania OD8"] = {
				accuracy = 0.96,
			},
			["osu!mania OD9"] = {
				accuracy = 0.975,
			},
		},
	}

	model:addScore("c9927b9b467c5958994ad215abb60609_7key", nil, chartdiff, score_system)
	local regular, ln = model:getDanClears("7key")
	assert(regular == "Azimuth")
	assert(ln == "-")

	score_system.judgements["osu!legacy OD9"].accuracy = 1

	model:addScore("22c436600e746a04e7ede85765f382c8_7key", nil, chartdiff, score_system)
	regular, ln = model:getDanClears("7key")
	assert(regular == "Azimuth")

	score_system.judgements["osu!legacy OD9"].accuracy = 0.95
	score_system.judgements["osu!legacy OD9"].score = 1000000

	model:addScore("c9927b9b467c5958994ad215abb60609_7key", nil, chartdiff, score_system)
	regular, ln = model:getDanClears("7key")
	assert(regular == "Azimuth")

	score_system.judgements["osu!legacy OD9"].accuracy = 0.97
	model:addScore("90492cfc1244bb1db82bba87eafe9cda_7key", nil, chartdiff, score_system)
	regular, ln = model:getDanClears("7key")
	assert(regular == "Zenith")

	model:addScore("09546ec514f9fa60549a4e08478582a6_7key", nil, chartdiff, score_system)
	regular, ln = model:getDanClears("7key")
	assert(ln == "9")

	score_system.judgements["osu!legacy OD9"].score = 800000
	chartdiff.inputmode = "4key_no_minacalc"
	model:addScore("90bba68a15429f745702dbf1d17664c2_4key", nil, chartdiff, score_system)
	regular, ln = model:getDanClears("4key")
	assert(ln == "-")

	score_system.judgements["osu!legacy OD9"].score = 780000
	score_system.judgements["osu!mania OD8"].accuracy = 0.971
	model:addScore("90bba68a15429f745702dbf1d17664c2_4key", nil, chartdiff, score_system)
	regular, ln = model:getDanClears("4key")
	assert(ln == "10")

	model:addScore("6bd4f93291d68ec74c009a7ff94c1d40_4key", nil, chartdiff, score_system)
	regular, ln = model:getDanClears("4key")
	assert(ln == "14")
end

PlayerProfileModel.testing = true
test_constructor()
test_scores()
test_dans()
PlayerProfileModel.testing = false
