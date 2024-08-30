---@param sound audio.Source
return function(sound)
	if sound:getPosition() > 0.01 then
		sound:stop()
	end

	sound:play()
end
