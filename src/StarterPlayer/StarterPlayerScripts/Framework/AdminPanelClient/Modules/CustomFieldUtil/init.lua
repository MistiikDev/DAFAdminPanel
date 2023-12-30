local CFUtil = {}
CFUtil.__index = CFUtil

local typeToInstance = {
	["boolean"] = "BoolValue",
	["number"] = "IntValue",
	["string"] = "StringValue",
}

local defaultBehavior = require(script.ValueChangeBehavior)

function CFUtil.new(fields, fieldType)
	local self = {
		fieldsFolder = fields,
		
		fields = {},
		connections = {},
		
		ui = nil
	}
	
	return setmetatable(self, CFUtil)
end

function CFUtil:AddField(settingName, settingType, defaultValue, parent)
	self.fields[settingName] = {
		ui = nil,
		settingType = settingType,
		defaultValue = defaultValue,
		
		valueTracker = nil,
	}
	
	self:FindFieldForSetting(settingName, parent)
	self:TrackValueForField(settingName)
	
	if self.fields[settingName].ui:FindFirstChild("SettingName") then
		self.fields[settingName].ui.SettingName.Text = settingName
	end
end

function CFUtil:RemoveField(settingName)
	if not self.fields[settingName] then return end 
	
	self.fields[settingName].ui:Destroy()
end

function CFUtil:FindFieldForSetting(settingName, parent)	
	if not self.fields[settingName] then return end 
		
	for i, field in pairs(self.fieldsFolder:GetChildren()) do
		if string.lower(field.Name) == string.lower(self.fields[settingName].settingType).."field" then
			self.fields[settingName].ui = field:Clone()
			self.fields[settingName].ui.Parent = parent
			
			break
		end
	end
end

function CFUtil:TrackValueForField(settingName)
	if not self.fields[settingName] then return end 
	
	self.fields[settingName].valueTracker = Instance.new(typeToInstance[self.fields[settingName].settingType])
	self.fields[settingName].valueTracker.Name = settingName.."_Value"
	self.fields[settingName].valueTracker.Parent = self.fields[settingName].ui
	
	self.connections[settingName.."valueChange"] = self.fields[settingName].valueTracker.Changed:Connect(function()
		defaultBehavior[string.lower(self.fields[settingName].settingType)](self.fields[settingName].ui, self.fields[settingName].valueTracker.Value)
	end)
	
	if self.fields[settingName].defaultValue then
		self.fields[settingName].valueTracker.Value = self.fields[settingName].defaultValue
	end
	
	if string.lower(self.fields[settingName].settingType) == "boolean" then
		self.connections[settingName.."click"] = self.fields[settingName].ui.MouseButton1Click:Connect(function()
			self.fields[settingName].valueTracker.Value = not self.fields[settingName].valueTracker.Value
		end)
	elseif string.lower(self.fields[settingName].settingType) == "string" then 
		self.fields[settingName].ui.PlaceholderText = settingName
		
		self.connections[settingName.."focus"] = self.fields[settingName].ui.FocusLost:Connect(function(enterPressed)
			self.fields[settingName].valueTracker.Value = self.fields[settingName].ui.ContentText
		end)
	end
end

function CFUtil:GetValueForField(settingName)
	if not self.fields[settingName] then return end 
	
	return self.fields[settingName].valueTracker.Value
end

return CFUtil