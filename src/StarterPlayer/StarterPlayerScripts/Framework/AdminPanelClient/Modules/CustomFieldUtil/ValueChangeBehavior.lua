return {
	["boolean"] = function(ui, newValue)
		ui.BackgroundColor3 = newValue and Color3.new(0, 0.623529, 0.0196078) or Color3.new(0.615686, 0, 0)
	end,
	
	["string"] = function(ui, newValue)
		ui.Text = tostring(newValue)
	end,
}