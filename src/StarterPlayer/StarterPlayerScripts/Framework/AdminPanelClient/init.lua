local AP = {}
AP.__index = AP

local RS = game:GetService("ReplicatedStorage")

local AdminPanel = RS.AdminPanel

local ActionList = require(AdminPanel.Modules.Actions.AllActions)
local ActionSettings = require(AdminPanel.Modules.Actions.ActionSettings)

local playerUtilModule = require(script.Modules.PlayerUtils)
local uiUtilModules = require(script.Modules.UIUitls)

function AP.new(mod : Player, panelUI)
	local self = {
		mod = mod,
		connections = {},
		actionSettings = {},
		
		currentTarget = nil,
		visible = false,
	}
	
	self.playerUtil = playerUtilModule.new(mod)
	self.ui = uiUtilModules.new(mod, self.playerUtil, panelUI)
	
	return setmetatable(self, AP)
end

function AP:Init()	
	for ActionName, ActionSettings in pairs(ActionSettings) do 
		self.actionSettings[ActionName] = ActionSettings["SETTINGS"]
	end

	self.playerUtil:Init(self)
	self.ui:Init(self)
end

function AP:TakeActionOnPlayer(subMenu, target)
	local fieldSettings = {}
	
	for fieldName, fieldData in pairs(subMenu.menu.fields.fields) do
		fieldSettings[fieldName] = subMenu.menu.fields:GetValueForField(fieldName)
	end
	
	print(fieldSettings)
	
	RS.AdminPanel.Remotes.TakeAction:FireServer(target, subMenu.menu.actionName, fieldSettings)
end

return AP