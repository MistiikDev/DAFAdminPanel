local ServerActions = {}

for i, v in pairs(script:GetChildren()) do 
	ServerActions[string.lower(v.Name)] = require(v)
end

return function(self, mod, target, actionName, setting)
	if self:isPlayerMod(mod.UserId) then
		if ServerActions[string.lower(actionName)] then 
			ServerActions[string.lower(actionName)](self, mod, target, actionName, setting)
		end
	end
end