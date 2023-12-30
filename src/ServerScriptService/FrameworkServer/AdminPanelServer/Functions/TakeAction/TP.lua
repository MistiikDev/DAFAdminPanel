local sss = game:GetService("ServerScriptService")
local adminPanelServer = sss.FrameworkServer.AdminPanelServer

local utils = adminPanelServer.Utils
local timeScale = require(utils.TimeScale)

return function (self, mod, target, actionName, setting)
	local modCharacter = mod.Character
	local targetCharacter = target.Character
		
	if modCharacter and targetCharacter then
		local endPosition = targetCharacter.PrimaryPart.CFrame

		modCharacter:PivotTo(endPosition)
	end
end