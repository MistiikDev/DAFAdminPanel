local Menu = {}
Menu.__index = Menu

local RS = game:GetService("ReplicatedStorage")
local SPC = game:GetService("StarterPlayer").StarterPlayerScripts

local AdminPanel = RS.AdminPanel
local AdminPanelClient = SPC.Framework.AdminPanelClient

local Classes = AdminPanelClient.Classes
local Modules = AdminPanelClient.Modules
local Templates = AdminPanelClient.Templates 

local RS_Modules = AdminPanel.Modules

local MiscActionTemplate = Templates.MiscAction
local MiscActionButtonTemplate = Templates.ActionButtonTemplate
local playerTemplate = Templates.PlayerTemplate
local Fields = Templates.Fields

local CFUtil = require(Modules.CustomFieldUtil)
local Signal = require(Classes.Signal)

function Menu.new(scrollMenu, template, actionName)
	local self = {
		accessButton = Templates.ActionButtonTemplate,
		
		scrollMenu = scrollMenu,		
		actionName = actionName,
		panel = nil,

		connections = {
			open = nil,
			exit = nil,
		},

		fields = CFUtil.new(Fields),
		
		open = Signal.new(),
		close = Signal.new(),
		
		uiCache = {

		},
		
		template = template,

		visible = false
	}

	return setmetatable(self, Menu)
end

function Menu:Init(actionCategoryParent)
	local panel = self.template:Clone()
	panel.Name = self.actionName.."ActionPanel"
	panel.Visible = false
	panel.Parent = self.scrollMenu.panelUI
	panel.Action1Name.Text = self.actionName
	panel.Action1Name.Name = self.actionName
	
	--
	local accessButton = self.accessButton:Clone()
	accessButton.Name = self.actionName.."Button"
	accessButton.Parent = actionCategoryParent
	accessButton.Button.Text = self.actionName
	--
	
	self.panel = panel
	
	self.connections.open = accessButton.Button.MouseButton1Click:Connect(function()
		self.scrollMenu:ToggleMenu(false)
		self:Toggle(true)
		
		self.open:Fire()
	end)

	self.connections.exit = panel.Exit.MouseButton1Click:Connect(function()
		self.scrollMenu:ToggleMenu(true)
		self:Toggle(false)
		
		self.close:Fire()
	end)
end

function Menu:SetFields(parent)
	for settingName, settingData in pairs(self.scrollMenu.adminPanel.actionSettings[self.actionName]) do 
		if settingData then
			local _, settingType, defaultValue = unpack(settingData)

			self.fields:AddField(settingName, settingType, defaultValue, parent)
		end
	end

end

function Menu:Toggle(forceState)
	if forceState ~= nil then
		self.visible = forceState
	else 
		self.visible = not self.visible
	end

	self.panel.Visible = self.visible
end

return Menu