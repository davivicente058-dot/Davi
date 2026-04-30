-- =========================================
-- DZ PERFORMANCE - UI BASE (ULTRA LEVE)
-- =========================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")

gui.Name = "DZ_UI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- =========================
-- MAIN FRAME
-- =========================

local main = Instance.new("Frame")
main.Size = UDim2.new(0,220,0,260)
main.Position = UDim2.new(0.05,0,0.3,0)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0,8)

-- =========================
-- TITLE BAR
-- =========================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "DZ Performance"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = main

-- =========================
-- BOTÕES (MINIMIZAR / FECHAR)
-- =========================

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0,30,0,30)
minimize.Position = UDim2.new(1,-60,0,0)
minimize.Text = "-"
minimize.BackgroundTransparency = 1
minimize.TextColor3 = Color3.new(1,1,1)
minimize.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-30,0,0)
close.Text = "X"
close.BackgroundTransparency = 1
close.TextColor3 = Color3.new(1,1,1)
close.Parent = main

-- =========================
-- CONTAINER
-- =========================

local container = Instance.new("Frame")
container.Size = UDim2.new(1,0,1,-30)
container.Position = UDim2.new(0,0,0,30)
container.BackgroundTransparency = 1
container.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,6)
layout.Parent = container

-- =========================
-- MODO MINIMIZADO (DZ)
-- =========================

local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0,50,0,50)
mini.Position = main.Position
mini.BackgroundColor3 = Color3.fromRGB(0,0,0)
mini.Text = "DZ"
mini.TextColor3 = Color3.new(1,1,1)
mini.Visible = false
mini.Parent = gui

Instance.new("UICorner", mini).CornerRadius = UDim.new(1,0)

-- =========================
-- SISTEMA DE TOGGLE (SWITCH)
-- =========================

local Toggles = {}

local function createToggle(name, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,-10,0,35)
	frame.BackgroundTransparency = 1
	frame.Parent = container

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.new(1,1,1)
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0,40,0,20)
	button.Position = UDim2.new(1,-45,0.5,-10)
	button.BackgroundColor3 = Color3.fromRGB(50,50,50)
	button.Text = ""
	button.Parent = frame

	Instance.new("UICorner", button).CornerRadius = UDim.new(1,0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0,18,0,18)
	knob.Position = UDim2.new(0,1,0.5,-9)
	knob.BackgroundColor3 = Color3.new(1,1,1)
	knob.Parent = button

	Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

	local state = false

	button.MouseButton1Click:Connect(function()
		state = not state

		if state then
			button.BackgroundColor3 = Color3.fromRGB(0,170,255)
			knob.Position = UDim2.new(1,-19,0.5,-9)
		else
			button.BackgroundColor3 = Color3.fromRGB(50,50,50)
			knob.Position = UDim2.new(0,1,0.5,-9)
		end

		if callback then
			callback(state)
		end
	end)

	Toggles[name] = true
end

-- =========================
-- CONTROLES UI
-- =========================

minimize.MouseButton1Click:Connect(function()
	main.Visible = false
	mini.Visible = true
end)

mini.MouseButton1Click:Connect(function()
	main.Visible = true
	mini.Visible = false
end)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- =========================
-- EXPORT
-- =========================

_G.DZ = {}
_G.DZ.CreateToggle = createToggle
