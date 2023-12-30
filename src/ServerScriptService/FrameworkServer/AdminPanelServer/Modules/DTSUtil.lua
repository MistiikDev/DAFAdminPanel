local DTSUtil = {}
DTSUtil.__index = DTSUtil

local DTS = game:GetService("DataStoreService")
local MSS = game:GetService("MemoryStoreService")

function DTSUtil.new(DTSkey, MSSKey)
	local self = {
		DTSKey = DTSkey,
		MSSKey = MSSKey,
		_DTS = nil,
		_memory = nil,
		_cache = {},
		_actionCache = {},
		}
	
	return setmetatable(self, DTSUtil)
end

function DTSUtil:Init()
	self._DTS = DTS:GetDataStore(self.DTSKey)
	self._memory = MSS:GetSortedMap(self.MSSKey)
end

-- MODERATION HISTORY CACHE HANDLERS
function DTSUtil:CacheModHistory(key)
	self._cache[key] = self:GetDTSAsync(key)
end

function DTSUtil:ClearModHistoryCache(key)
	self._cache[key] = nil
end

-- SAFE CALLS FOR :GetAsync ON MEMORY AND DATA-STORE
function DTSUtil:GetDTSAsync(key)
	local success, data = pcall(function()
		return self._DTS:GetAsync(key)
	end)
	
	if not (success) then error("Error while getting datastore of key: ", key) return end
	
	return data
end

function DTSUtil:UpdateDTS(key, callBack)
	local success, newData = pcall(function() 
		self._DTS:UpdateAsync(key, callBack)
	end)
		
	if success then
		return newData
	end
end

return DTSUtil