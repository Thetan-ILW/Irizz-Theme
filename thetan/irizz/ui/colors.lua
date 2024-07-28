local Colors = {}

Colors.ui = {}
Colors.difficultyColors = {}
Colors.difficultyRanges = {}
Colors.hitColors = {}
Colors.missColor = {}

---@param difficulty number
---@param calculatorName string
---@return table
function Colors:getDifficultyColor(difficulty, calculatorName)
	local difficultyRanges = self.difficultyRanges
	local difficultyColors = self.difficultyColors

	local ranges = difficultyRanges[calculatorName]
	if not ranges then
		error("Invalid calculator name: " .. calculatorName)
	end

	local colorIndex = 1
	for i = #ranges, 1, -1 do
		local range = ranges[i]
		if difficulty >= range[1] then
			colorIndex = i
			break
		end
	end

	local lowerLimit, upperLimit
	if colorIndex == 1 then
		lowerLimit = 0
		upperLimit = ranges[1][2]
	elseif colorIndex == #difficultyColors then
		return difficultyColors[#difficultyColors]
	else
		lowerLimit, upperLimit = ranges[colorIndex][1], ranges[colorIndex][2]
	end

	local color1, color2 = difficultyColors[colorIndex], difficultyColors[colorIndex + 1]

	local mixingRatio = (difficulty - lowerLimit) / (upperLimit - lowerLimit)

	return {
		color1[1] * (1 - mixingRatio) + color2[1] * mixingRatio,
		color1[2] * (1 - mixingRatio) + color2[2] * mixingRatio,
		color1[3] * (1 - mixingRatio) + color2[3] * mixingRatio,
		1,
	}
end

return Colors
