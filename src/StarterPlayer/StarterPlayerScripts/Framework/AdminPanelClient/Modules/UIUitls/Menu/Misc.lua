local MiscMenu = {}
MiscMenu.__index = MiscMenu

local RS = game:GetService("ReplicatedStorage")
local SPC = game:GetService("StarterPlayer").StarterPlayerScripts

local AdminPanel = RS.AdminPanel
local AdminPanelClient = SPC.Framework.AdminPanelClient

local Classes = AdminPanelClient.Classes
local Modules = AdminPanelClient.Modules
local Templates = AdminPanelClient.Templates 

local Menu = require(Modules.UIUitls.Menu)

function MiscMenu.new(scrollMenu, actionName)
	local self = {
		menu = Menu.new(scrollMenu, Templates.MiscAction, actionName),
		activate = nil,

		currentTarget = nil,
		connections = {
			activateTrigger = nil,
		},
	}
	
	return setmetatable(self, MiscMenu)
end

function MiscMenu:Init()
	self.menu:Init(self.menu.scrollMenu.panelMenu.MiscActionsBG.MiscActions)
	
	self.activate = self.menu.panel:FindFirstChild("ActivateBG")
	
	self.menu:SetFields(self.activate.Activate.Fields)
	
	self.menu.open:Connect(function()
		local modId = self.menu.scrollMenu.adminPanel.mod.UserId
		local modData = self.menu.scrollMenu.adminPanel.playerUtil.players[modId]
		
		self:LoadPlayerData(modId, modData)
	end)
	
	self.menu.close:Connect(function()
		self:UnloadData()
	end)
end

function MiscMenu:LoadPlayerData(playerUserId, playerData)
	self.activate.PlayerAge.Text = tostring(playerData.player.AccountAge).." days"
	self.activate.PlayerName.Text = tostring(playerData.player.Name)
	self.activate.PlayerHead.Image = playerData.thumbnail
end

function MiscMenu:UnloadData()
	self.activate.PlayerAge.Text = ""
	self.activate.PlayerName.Text = ""
	self.activate.PlayerHead.Image = ""
end


return MiscMenu