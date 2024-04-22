local class = require("class")
local thread = require("thread")

local Theme = require("thetan.irizz.views.Theme")
local Text = Theme.textOsuApi

local OsuApi = class()

local accessToken = nil

function OsuApi:new(game)
	self.game = game
end

local function getTokenAsync(client_id, client_secret)
	local json = require("json")
	local ltn12 = require("ltn12")
	local https = require("ssl.https")

	local data = {
		["client_id"] = client_id,
		["client_secret"] = client_secret,
		["grant_type"] = "client_credentials",
		["scope"] = "public",
	}

	local request_body = json.encode(data)

	local headers = {
		["Accept"] = "application/json",
		["Content-Type"] = "application/json",
		["Content-Length"] = string.len(request_body),
	}

	local response = {}

	print("osu API: sending request for the token")
	local _, code, _, _ = https.request({
		url = "https://osu.ppy.sh/oauth/token",
		method = "POST",
		headers = headers,
		source = ltn12.source.string(request_body),
		sink = ltn12.sink.table(response),
	})

	if code ~= 200 then
		print("osu API: Cannot get the token.")
		print(require("inspect")(response))
		return nil
	end

	print("osu API: got the token")
	return json.decode(response[1]).access_token
end

OsuApi.getToken = thread.async(getTokenAsync)

local function getScoresAsync(access_token, beatmap_id)
	local https = require("ssl.https")
	local ltn12 = require("ltn12")
	local json = require("json")

	local url = ("https://osu.ppy.sh/api/v2/beatmaps/%i/scores"):format(beatmap_id)

	local headers = {
		["Content-Type"] = "application/json",
		["Accept"] = "application/json",
		["Authorization"] = ("Bearer %s"):format(access_token),
	}

	local data = {
		["legacy_only"] = 0,
		["mode"] = "mania",
	}

	local response = {}

	local _, c, _, _ = https.request({
		url = url,
		method = "GET",
		headers = headers,
		source = ltn12.source.string(json.encode(data)),
		sink = ltn12.sink.table(response),
	})

	if c ~= 200 then
		print("osu API: cannot get scores.")
		print(require("inspect")(response))
		return nil
	end

	local success, result = pcall(json.decode, table.concat(response))

	if not success then
		return nil
	end

	return result.scores
end

local getScores = thread.async(getScoresAsync)

local score_cache = {}
local next_get_time = 0
local loading_score = false

function OsuApi:load()
	local config = self.game.configModel.configs.osu_api

	if config.client_secret == "" then
		print("osu API: secret is not defined.")
		return
	end

	local co = coroutine.create(function()
		accessToken = OsuApi.getToken(config.client_id, config.client_secret)
	end)

	coroutine.resume(co)
end

---@param beatmap_id number
---@return string
---@return table?
function OsuApi:getScores(beatmap_id)
	if not beatmap_id then
		return Text.noId, nil
	end

	local cached = score_cache[beatmap_id]

	if cached then
		local status = cached.isEmpty and Text.noScores or Text.loading
		return status, cached
	end

	if not accessToken then
		return Text.noToken, nil
	end

	local current_time = love.timer.getTime()

	if current_time < next_get_time or loading_score then
		return Text.wait, nil
	end

	next_get_time = current_time + 1.05
	loading_score = true

	score_cache[beatmap_id] = {
		isEmpty = false,
	}

	local co = coroutine.create(function()
		local scores = getScores(accessToken, beatmap_id)

		local t = score_cache[beatmap_id]

		if not scores then
			print("osu API: No scores")
			t.isEmpty = true
			loading_score = false
			return score_cache[beatmap_id]
		end

		for _, score in ipairs(scores) do
			if score.score == 0 or not score.passed then
				goto continue
			end

			local time_rate = 1
			for _, mod in ipairs(score.mods) do
				if mod == "DT" then
					time_rate = 1.5
					break
				end

				if mod == "HT" then
					time_rate = 0.75
					break
				end
			end

			table.insert(t, {
				username = score.user.username,
				accuracy = score.accuracy,
				timestamp = score.created_at,
				time_rate = time_rate,
			})

			::continue::
		end

		if #t == 0 then
			t.isEmpty = true
		end

		loading_score = false
	end)

	coroutine.resume(co)

	return Text.loading, nil
end

return OsuApi
