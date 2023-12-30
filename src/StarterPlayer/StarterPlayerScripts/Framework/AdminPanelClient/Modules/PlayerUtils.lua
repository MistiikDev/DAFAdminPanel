local PlayerUtils = {}
PlayerUtils.__index = PlayerUtils

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local AdminPanel = RS.AdminPanel
local ActionList = require(AdminPanel.Modules.Actions.AllActions)

function PlayerUtils.new(player)
	local self = {
		player = player,
		connections = {},
		players = {},
				
		adminPanel = nil
	}
	
	return setmetatable(self, PlayerUtils)
end

function PlayerUtils:Init(adminPanel)
	self.adminPanel = adminPanel
	
	for i, player in pairs(Players:GetPlayers()) do 
		if not self.players[player.UserId] then 
			self.players[player.UserId] = {
				player = player,
				thumbnail = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48),
				historyCache = 	{},
			}
		end
		
		self:CacheModerationHistory(player)
	end
	
	self.connections[#self.connections + 1] = Players.PlayerAdded:Connect(function(player)
		if not self.players[player.UserId] then 
			self.players[player.UserId] = {
				player = player,
				thumbnail = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48),
				historyCache = 	{},	
			}
			
			self:CacheModerationHistory(player)
		end
	end)
	
	self.connections[#self.connections + 1] = Players.PlayerRemoving:Connect(function(player)
		if self.players[player.UserId] then 
			self.players[player.UserId] = nil
		end
	end)
end

function PlayerUtils:CacheModerationHistory(player)
	if not self.players[player.UserId] then return end 

	for Index, ModAction in pairs(ActionList) do
		for ActionType, Actions in pairs(ActionList) do 
			if string.lower(ActionType) == "mod" then
				
				for index, actionName in pairs(Actions) do
					self.players[player.UserId].historyCache[actionName] = AdminPanel.Remotes.GetPlayerHistory:InvokeServer(player, actionName)
				end
				
			end
		end
	end
end

function PlayerUtils:GetPlayerList()
	return self.players
end



return PlayerUtils