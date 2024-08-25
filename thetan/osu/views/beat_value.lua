---@type number[]
local smoothed = {}
---@type number[]
local peaks = {}
local beat_value = 0

for i = 1, 10 do
	smoothed[i] = 0
	peaks[i] = 0
end

local SMOOTH_FACTOR = 0.15
local BEAT_DECAY = 0.7
local BEAT_THRESHOLD = 1.1 -- Threshold for detecting a beat

---@param frequencies ffi.cdata*
return function(frequencies)
	if not frequencies then
		return 0
	end

	for i = 1, 10 do
		smoothed[i] = smoothed[i] + (frequencies[i - 1] - smoothed[i]) * SMOOTH_FACTOR
	end

	-- Detect peaks and calculate beat value
	local totalEnergy = 0
	for i = 1, 10 do
		if smoothed[i] > peaks[i] then
			peaks[i] = smoothed[i]
		else
			peaks[i] = peaks[i] * BEAT_DECAY
		end

		if smoothed[i] > peaks[i] * BEAT_THRESHOLD then
			totalEnergy = totalEnergy + (smoothed[i] - peaks[i] * BEAT_THRESHOLD)
		end
	end

	beat_value = math.min(beat_value + totalEnergy * 0.08, 1)
	beat_value = beat_value * BEAT_DECAY

	return beat_value
end
