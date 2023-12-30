local utils = script.Parent.Parent.Parent.Utils
local timeScale = require(utils.TimeScale)
local Players = game:GetService("Players")

local function CheckBan(key, player, actionName, dataUtil, data)
	if not data then return end 
	
	local currentBan = data.currentBan
		
	if currentBan then
		local modId = currentBan[2] 
		local startOfBan = currentBan[3] 
		local duration = tonumber(currentBan[4])
		local durationScale = currentBan[5]
		local reason = currentBan[6]
		local serverId = currentBan[7]

		local modName = Players:GetNameFromUserIdAsync(modId)

		if (modId and startOfBan and duration and durationScale) then
			local durationMult = timeScale[durationScale]
			
			if (tick() - startOfBan <= duration) then
				local durationLeft = tick() - startOfBan
				local timeLeft = duration / durationMult or 1

				local msg = "You have been banned by "..tostring(modName).." for "..tostring(timeLeft)..tostring(durationScale)..". \nReason: "..tostring(reason)
				player:Kick(msg)	

				return
			else
				-- time passed, pass to memory to clear it on dts when player leave / server goes down.
				local success, err = pcall(function()
					dataUtil:UpdateDTS(key, function(oldData)
						local overWritedata = {
							currentBan = nil,
							banHistory = oldData and oldData.banHistory or {}
						}
						
						overWritedata.banHistory[#overWritedata.banHistory + 1] = currentBan
						
						return overWritedata
					end)
				end)

				if err then warn(err) end
			end
		end
	end
end

return function(self, key, player, actionName, dataUtil)
	local dtsData = dataUtil:GetDTSAsync(key)
	
	CheckBan(key, player, actionName, dataUtil, dtsData)
end