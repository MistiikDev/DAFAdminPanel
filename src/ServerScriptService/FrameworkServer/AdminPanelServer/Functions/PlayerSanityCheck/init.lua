local BanCheck = require(script.BanCheck)

return function(self, key, player)	
	local banDTS = self._banDTSUtil:GetDTSAsync(key)
	
	BanCheck(self, key, player, "ban", self._banDTSUtil)
	
	-- If nothing, then get player history
	self._banDTSUtil:CacheModHistory(key)
	self._kickDTSUtil:CacheModHistory(key)
end