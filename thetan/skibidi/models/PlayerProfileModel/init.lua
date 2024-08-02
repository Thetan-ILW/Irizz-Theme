local class = require("class")

local json = require("json")

local dans = require("thetan.skibidi.models.PlayerProfileModel.dans")

---@class thetan.PlayerProfileModel
---@operator call: thetan.PlayerProfileModel
---@field scores table<string, thetan.ProfileScore>
---@field pp number
---@field accuracy number
---@field ssr table<string, number>
---@field liveSsr table<string, number>
---@field danClears table<string, table<string, string[]>>
local PlayerProfileModel = class()

---@class thetan.ProfileScore
---@field mode string
---@field time number
---@field osuAccuracy number
---@field osuPP number

local db_path = "userdata/player_profile"

function PlayerProfileModel:new()
	self.scores = {}

	self.pp = 0
	self.accuracy = 0

	self.ssr = {
		overall = 0,
		stream = 0,
		jumpstream = 0,
		handstream = 0,
		stamina = 0,
		jackspeed = 0,
		chordjack = 0,
		technical = 0,
	}

	self.liveSsr = {
		overall = 0,
		stream = 0,
		jumpstream = 0,
		handstream = 0,
		stamina = 0,
		jackspeed = 0,
		chordjack = 0,
		technical = 0,
	}

	self.danClears = {}

	for input_mode_name, input_mode in pairs(dans) do
		self.danClears[input_mode_name] = {}

		for category_name, category in pairs(input_mode) do
			self.danClears[input_mode_name][category_name] = {}

			for i, item in ipairs(category) do
				item.hash = ("%s_%s"):format(item.hash, input_mode_name)
			end
		end
	end

	self:loadScores()
	self:findDanClears()
end

---@param key string
---@param score thetan.ProfileScore
function PlayerProfileModel:addScore(key, score)
	if score.osuAccuracy < 0.85 then
		print("This score is too bad, go back to friday night funkin")
		return
	end

	local old_score = self.scores[key]

	if old_score then
		if score.osuPP <= old_score.osuPP then
			print("Previous score was better")
			return
		end
	end

	self.scores[key] = score

	self:writeScores()

	self:calculateOsuStats()
	self:calculateMsdStats()
	self:findDanClears()
end

function PlayerProfileModel:calculateOsuStats()
	self.pp = 0

	local pp_sorted = {}
	local accuracy = 0
	local num_scores = 0

	for _, v in pairs(self.scores) do
		table.insert(pp_sorted, v.osuPP)

		accuracy = accuracy + v.osuAccuracy
		num_scores = num_scores + 1
	end

	table.sort(pp_sorted, function(a, b)
		return a > b
	end)

	for i, pp in pairs(pp_sorted) do
		self.pp = self.pp + (pp * math.pow(0.95, (i - 1)))
	end

	self.accuracy = accuracy / num_scores
end

function PlayerProfileModel:findDanClears()
	for input_mode_name, input_mode in pairs(dans) do
		for category_name, category in pairs(input_mode) do
			for i, item in ipairs(category) do
				local score = self.scores[item.hash]
				if score and score.osuAccuracy >= 0.96 then
					table.insert(self.danClears[input_mode_name][category_name], item.name)
				end
			end
		end
	end
end

---@param score_time number
function PlayerProfileModel:getLiveRatingWeight(score_time)
	local current_time = os.time()
	local max_decay_time = 30 * 24 * 60 * 60 -- 30 days
	local time_difference = current_time - score_time

	if time_difference <= 0 then
		return 1
	end

	if time_difference >= max_decay_time then
		return 0.2
	end

	local decay_rate = 2 / max_decay_time
	local weight = math.exp(-decay_rate * time_difference)

	weight = 0.2 + (weight * 0.8)

	return weight
end

---@param ssr table<string, number>[]
---@return table<string, number>
local function ssrAverage(ssr)
	local avg_count = 20

	local overall_sum = 0
	local stream_sum = 0
	local jumpstream_sum = 0
	local handstream_sum = 0
	local stamina_sum = 0
	local jackspeed_sum = 0
	local chordjack_sum = 0
	local technical_sum = 0

	for i, v in ipairs(ssr) do
		if i > avg_count then
			break
		end

		overall_sum = overall_sum + v.overall
		stream_sum = stream_sum + v.stream
		jumpstream_sum = jumpstream_sum + v.jumpstream
		handstream_sum = handstream_sum + v.handstream
		stamina_sum = stamina_sum + v.stamina
		jackspeed_sum = jackspeed_sum + v.jackspeed
		chordjack_sum = chordjack_sum + v.chordjack
		technical_sum = technical_sum + v.technical
	end

	return {
		overall = overall_sum / avg_count,
		stream = stream_sum / avg_count,
		jumpstream = jumpstream_sum / avg_count,
		handstream = handstream_sum / avg_count,
		stamina = stamina_sum / avg_count,
		jackspeed = jackspeed_sum / avg_count,
		chordjack = chordjack_sum / avg_count,
		technical = technical_sum / avg_count,
	}
end

function PlayerProfileModel:calculateMsdStats()
	local ssr_sorted = {}
	local live_ssr_sorted = {}

	for _, v in pairs(self.scores) do
		if v.overall then
			table.insert(ssr_sorted, {
				overall = v.overall,
				stream = v.stream,
				jumpstream = v.jumpstream,
				handstream = v.handstream,
				stamina = v.stamina,
				jackspeed = v.jackspeed,
				chordjack = v.chordjack,
				technical = v.technical,
			})

			local weight = self:getLiveRatingWeight(v.time)

			table.insert(live_ssr_sorted, {
				overall = v.overall * weight,
				stream = v.stream * weight,
				jumpstream = v.jumpstream * weight,
				handstream = v.handstream * weight,
				stamina = v.stamina * weight,
				jackspeed = v.jackspeed * weight,
				chordjack = v.chordjack * weight,
				technical = v.technical * weight,
			})
		end
	end

	table.sort(ssr_sorted, function(a, b)
		return a.overall > b.overall
	end)

	table.sort(live_ssr_sorted, function(a, b)
		return a.overall > b.overall
	end)

	self.ssr = ssrAverage(ssr_sorted)
	self.liveSsr = ssrAverage(live_ssr_sorted)
end

---@param text string
local function cipher(text)
	local key = "go away"
	local result = {}
	for i = 1, #text do
		local char = string.byte(text, i)
		local key_char = string.byte(key, (i - 1) % #key + 1)
		result[i] = string.char(bit.bxor(char, key_char))
	end
	return table.concat(result)
end

function PlayerProfileModel:loadScores()
	if PlayerProfileModel.testing then
		return
	end

	if not love.filesystem.getInfo(db_path) then
		local file = love.filesystem.newFile(db_path, "w")
		file:open("w")
		file:write(cipher("{}"))
		file:close()
		return
	end

	local file = love.filesystem.newFile(db_path)
	local ok, err = file:open("r")

	if not ok then
		error("Can't load scores " .. (err or ""))
	end

	---@type thetan.ProfileScore[]
	self.scores = json.decode(cipher(file:read()))

	file:close()

	self:calculateOsuStats()
	self:calculateMsdStats()
end

function PlayerProfileModel:writeScores()
	if PlayerProfileModel.testing then
		return
	end

	local file = love.filesystem.newFile(db_path)
	local ok, err = file:open("w")

	if not ok then
		error("Can't write scores. " .. (err or ""))
	end

	local encoded = json.encode(self.scores)
	file:write(cipher(encoded))
	file:close()
end

return PlayerProfileModel
