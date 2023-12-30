local APServer = {}
APServer.__index = APServer

local MSS = game:GetService("MemoryStoreService")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DTS = game:GetService("DataStoreService")

local AdminPanel = RS.AdminPanel
local BAN_DTS_KEY = "BANS"
local KICK_DTS_KEY = "KICKS"

local BAN_MSS_KEY = "BANS_MEMORY"
local KICK_MSS_KEY = "KICKS_MEMORY"

local ActionSettings = require(AdminPanel.Modules.Actions.ActionSettings)

local functions = script.Functions
local utils = script.Utils
local modules = script.Modules

local GetPlayerHistory = require(functions.GetPlayerHistory)
local TakeAction = require(functions.TakeAction)
local PlayerSanityCheck = require(functions.PlayerSanityCheck)
local timeScale = require(utils.TimeScale)

local dtsUtil = require(modules.DTSUtil)

function APServer.new()
	local self = {
		_banDTSUtil = dtsUtil.new(BAN_DTS_KEY, BAN_MSS_KEY),
		_kickDTSUtil = dtsUtil.new(KICK_DTS_KEY, KICK_MSS_KEY),

		_authorizedMods = require(AdminPanel.Modules.ModsList)
	}

	return setmetatable(self, APServer)
end

function APServer:Init()
	self._banDTSUtil:Init()
	self._kickDTSUtil:Init()
	
	-- Remotes
	AdminPanel.Remotes.GetPlayerHistory.OnServerInvoke = function(...) return GetPlayerHistory(self, ...) end
	AdminPanel.Remotes.TakeAction.OnServerEvent:Connect(function(...) TakeAction(self, ...) end)
	
	-- PlayerAdded : Does player has an offense ? / PlayerRemoved : Was an offensed registered in memory ?
	Players.PlayerAdded:Connect(function(...) self:OnPlayerAdded(...) end)
	Players.PlayerRemoving:Connect(function(...) self:OnPlayerRemoved(...) end)
	
	game:BindToClose(function()
		self:OnGameClosure()
	end)
end

-- Loop through all players,
function APServer:OnGameClosure()
	-- Clear all memory from everyone and write datastore
	for userId, data in pairs(self._banDTSUtil._actionCache) do 
		local key = tostring(userId)

		self._banDTSUtil:UpdateDTS(key, function(oldData)
			return data
		end)
		
		self._banDTSUtil:ClearModHistoryCache(key)
	end

	for userId, data in pairs(self._kickDTSUtil._actionCache) do 
		local key = tostring(userId)

		self._kickDTSUtil:UpdateDTS(key, function(oldData)
			return data
		end)
		
		self._kickDTSUtil:ClearModHistoryCache(key)
	end
end

-- Check if player has an offense (ban) going on
function APServer:OnPlayerAdded(player)
	local key = tostring(player.UserId)
	PlayerSanityCheck(self, key, player)
end

-- Clear player cache and write offense on datastore if any
function APServer:OnPlayerRemoved(player)
	local key = tostring(player.UserId)
	
	local banActionCache = self._banDTSUtil._actionCache[key]
	local kickActionCache = self._kickDTSUtil._actionCache[key]

	if kickActionCache then
		self._kickDTSUtil:UpdateDTS(key, function()
			return kickActionCache
		end)
	end

	if banActionCache then
		self._banDTSUtil:UpdateDTS(key, function()
			return banActionCache
		end)
	end

	self._kickDTSUtil:ClearModHistoryCache(key)
	self._banDTSUtil:ClearModHistoryCache(key)
end

-- Player Moderator check, will handle rank check aswell
function APServer:isPlayerMod(playerId)
	return table.find(self._authorizedMods, playerId) and true or false
end

return APServer