local RS = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local p = players.LocalPlayer

local panel = require(script.AdminPanelClient).new(p, p.PlayerGui:WaitForChild("AdminPanel"))
panel:Init()