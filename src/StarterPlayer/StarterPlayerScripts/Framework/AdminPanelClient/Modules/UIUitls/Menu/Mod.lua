local ModerationMenu = {}
ModerationMenu.__index = ModerationMenu

local RS = game:GetService("ReplicatedStorage")
local SPC = game:GetService("StarterPlayer").StarterPlayerScripts

local AdminPanel = RS.AdminPanel
local AdminPanelClient = SPC.Framework.AdminPanelClient

local Classes = AdminPanelClient.Classes
local Modules = AdminPanelClient.Modules
local Templates = AdminPanelClient.Templates 

local Menu = require(Modules.UIUitls.Menu)

function ModerationMenu.new(scrollMenu, actionName)
	local self = {
		menu = Menu.new(scrollMenu, Templates.ModerationAction, actionName),

		playerList = nil,
		takeAction = nil,

		currentTarget = nil,
		connections = {
			takeActionTrigger = nil,
		},

		fieldParent = nil
	}

	return setmetatable(self, ModerationMenu)
end

function ModerationMenu:Init()
	self.menu:Init(self.menu.scrollMenu.panelMenu.ModActionsBG.ModActions)

	self.playerList = self.menu.panel:FindFirstChild("PlayerListBG")
	self.takeAction = self.menu.panel:FindFirstChild("TakeActionBG")

	self.menu.uiCache.moderationHistory = {}
	self.menu.uiCache.playerTiles = {}

	self.menu:SetFields(self.takeAction.TakeAction.Fields)

	self.menu.open:Connect(function()
		self:RefreshPlayerList()
	end)

	self.takeAction.Visible = false
end

function ModerationMenu:RefreshPlayerList()
	for i,v in pairs(self.menu.uiCache.playerTiles) do 
		v:Destroy()
	end

	local currentPlayers = self.menu.scrollMenu.adminPanel.playerUtil.players

	for playerId, playerData in pairs(currentPlayers) do 
		--if playerData.player == self.menu.scrollMenu.adminPanel.mod then continue end 

		self:GeneratePlayerTile(playerId, playerData)
	end

	if self.connections[self.menu.actionName.."takeAction"] then 
		self.connections[self.menu.actionName.."takeAction"]:Disconnect()
	end

	self.connections[self.menu.actionName.."takeAction"] = self.takeAction.TakeAction.Button.MouseButton1Click:Connect(function()
		if self.currentTarget then
			self.takeAction.Visible = false
			self.menu.scrollMenu.adminPanel:TakeActionOnPlayer(self, self.currentTarget)

			self:UnloadData()
		end
	end)	
end

function ModerationMenu:GeneratePlayerTile(playerUserId, playerData)
	local _playerPanel = Templates.PlayerTemplate:Clone()

	_playerPanel.Name = tostring(playerUserId).."_Panel"
	_playerPanel.NameButton.Text = playerData.player.Name
	_playerPanel.PlayerHead.Image = playerData.thumbnail
	_playerPanel.Parent = self.playerList.PlayerList

	self.takeAction.Visible = false

	self.menu.uiCache.playerTiles[#self.menu.uiCache.playerTiles+ 1] = _playerPanel

	self.connections[tostring(playerUserId).."_click"] = _playerPanel.NameButton.MouseButton1Click:Connect(function()
		self.takeAction.Visible = not self.takeAction.Visible

		self:LoadPlayerData(playerUserId, playerData)
	end)
end

function ModerationMenu:GenerateModHistoryTile(playerUserId, actionHistory)
	local moderatorId, duration, durationScale, reason = actionHistory[2], actionHistory[4], actionHistory[5], actionHistory[6]		

	local mod = self.menu.scrollMenu.adminPanel.playerUtil.players[moderatorId].player
	local thumbnail = self.menu.scrollMenu.adminPanel.playerUtil.players[moderatorId].thumbnail

	local historyTile = Templates.HistoryTemplate:Clone()
	historyTile.Duration.Text = (duration and durationScale) and (tostring(duration)..tostring(durationScale)) or "/"
	historyTile.ModName.Text = mod.Name
	historyTile.PlayerHead.Image = thumbnail
	historyTile.Reason.Text = reason or "No reason specified."
		
	historyTile.Parent = self.takeAction.PlayerHistory

	return historyTile
end

function ModerationMenu:LoadPlayerData(playerUserId, playerData)
	self.takeAction.PlayerAge.Text = tostring(playerData.player.AccountAge).." days"
	self.takeAction.PlayerName.Text = tostring(playerData.player.Name)
	self.takeAction.PlayerHead.Image = playerData.thumbnail

	self:LoadPlayerHistory(playerUserId, playerData)

	self.currentTarget = playerData.player
end

function ModerationMenu:LoadPlayerHistory(playerUserId, playerData)		
	local allPlayerHistory = self.menu.scrollMenu.adminPanel.playerUtil.players[playerUserId].historyCache

	for i,v in pairs(self.menu.uiCache.moderationHistory) do 
		v:Destroy()
	end

	if allPlayerHistory and allPlayerHistory ~= {} then
		local currentActionHistory = allPlayerHistory[self.menu.actionName]
				
		if currentActionHistory then
			for index, action in pairs(currentActionHistory) do 			
				self.menu.uiCache.moderationHistory[#self.menu.uiCache.moderationHistory + 1] = self:GenerateModHistoryTile(playerUserId, action)
			end
		end
	end
end

function ModerationMenu:UnloadData()
	self.takeAction.Visible = false

	self.takeAction.PlayerAge.Text = ""
	self.takeAction.PlayerName.Text = ""
	self.takeAction.PlayerHead.Image = ""

	for i,v in pairs(self.menu.uiCache.moderationHistory) do 
		v:Destroy()
	end

	self.currentTarget = nil
end


return ModerationMenu