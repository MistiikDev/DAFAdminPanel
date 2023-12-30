return function(self, mod, target, actionName)
	if not self:isPlayerMod(mod.UserId) then 
		warn("Player : ", mod.Name, "[", tostring(mod.UserId), "], tried accessing DTS without permissions.")
		return nil
	end
	
	local key = tostring(target.UserId)
	
	if (string.lower(actionName) == "kick") then
		if self._kickDTSUtil._cache[key] then
			return self._kickDTSUtil._cache[key].kickHistory
		end
	elseif (string.lower(actionName) == "ban") then
		if self._banDTSUtil._cache[key] then
			return self._banDTSUtil._cache[key].banHistory
		end
	end
end