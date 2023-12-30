local UI = {}
UI.__index = UI

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local AdminPanel = RS.AdminPanel
local AdminPanel = RS.AdminPanel

local ActionList = require(AdminPanel.Modules.Actions.AllActions)
local ModList = require(AdminPanel.Modules.ModsList)
local Templates = script.Parent.Parent.Templates

local ModActionTemplate = Templates.ModerationAction
local ModActionButtonTemplate = Templates.ActionButtonTemplate
local playerTemplate = Templates.PlayerTemplate

local Menus = script.Menu

function UI.new(player, playerUtil, panelUI)
	local self = {
		adminPanel = nil,

		player = player,
		playerUtil = playerUtil,

		panelUI = panelUI,
		panelMenu = panelUI.MenuBG,
		
		menus = {},		
		connections = {},
		registeredActionTypes = {},
		
		visible = false
	}

	return setmetatable(self, UI)
end

function UI:Init(adminPanel)	
	self.adminPanel = adminPanel
	self.connections[#self.connections + 1] = self.panelUI.AdminPanelOpen.MouseButton1Click:Connect(function() self:ToggleMenu() end)
	
	for ActionType, Actions in pairs(ActionList) do 
		local menuType = nil
		
		for index, menu in pairs(Menus:GetChildren()) do 
			if string.lower(menu.Name) == string.lower(ActionType) then
				menuType = menu
				
				break
			end
		end
		
		if menuType then			
			for index, actionName in pairs(Actions) do 				
				print(actionName)

				self.menus[actionName] = require(menuType).new(self, actionName)
				self.menus[actionName]:Init()
			end
		end
	end
	
end

--
function UI:ToggleMenu(forceState)	
	if forceState ~= nil then
		self.visible = forceState
	else 
		self.visible = not self.visible
	end

	self.panelMenu.Visible = self.visible
end
--

return UI