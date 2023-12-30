local sss = game:GetService("ServerScriptService")
local adminPanelServer = sss.FrameworkServer.AdminPanelServer

local utils = adminPanelServer.Utils
local timeScale = require(utils.TimeScale)


return function (self, mod, target, actionName, setting)
	local durationValue = setting.Duration
	local reasonValue = setting.Reason

	local durationDefault, reasonDefault = "No duration specified", "No reason specified"
	local cmdScale, timeLeft = "", "no time specified"
	
	local duration = durationValue or durationDefault
	local reason = reasonValue or "No reason specified."
	
	cmdScale = string.sub(duration, string.len(duration))

	if timeScale[cmdScale] then
		duration = string.sub(duration, 1, string.len(duration) - 1)
		duration = tonumber(duration)

		if duration then
			duration = duration * timeScale[cmdScale]
		end
	end
	
	local data = {
		actionName, -- Action Name (kick / ban)
		mod.UserId, -- Moderator

		tick(), -- Register time of action for future comparaison (seconds)
		durationValue and duration or durationDefault, -- Duration of action (seconds)
		durationValue and cmdScale or nil, -- Duration scale
		reasonValue and reason or reasonDefault, -- Reason of action

		serverId = tostring(game.JobId)
	}

	local key = target.UserId

	self._kickDTSUtil:UpdateDTS(key, function(oldData)
		local newData = {
			kickHistory = oldData and oldData.kickHistory or {}
		}

		newData.kickHistory[#newData.kickHistory + 1] = data

		return newData
	end)

	if durationValue then
		timeLeft = duration / tonumber(timeScale[cmdScale]) or 1
	end

	local msg = "You have been kicked by "..tostring(mod.Name).." for "..tostring(timeLeft)..tostring(cmdScale)..". \nReason: "..tostring(reason)
	target:Kick(msg)	
end