-- Bloxtrap Mobile v4.1
-- Complete | Stable | UI Control

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "BloxtrapUI"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.38, 0.42)
main.Position = UDim2.fromScale(0.31, 0.29)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0,12)

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0.12,0)
title.Text = "Bloxtrap Mobile v4.1"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- MINIMIZE
local minimize = Instance.new("TextButton", main)
minimize.Text = "–"
minimize.Size = UDim2.fromScale(0.12,0.12)
minimize.Position = UDim2.fromScale(0.86,0)
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 20
minimize.BackgroundTransparency = 1
minimize.TextColor3 = Color3.new(1,1,1)

local open = true
minimize.MouseButton1Click:Connect(function()
	open = not open
	for _,v in ipairs(main:GetChildren()) do
		if v ~= title and v ~= minimize and v:IsA("GuiObject") then
			v.Visible = open
		end
	end
end)

-- BUTTON CREATOR
local function button(txt, y)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.fromScale(0.8,0.1)
	b.Position = UDim2.fromScale(0.1,y)
	b.Text = txt
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b)
	return b
end

-- LIGHTING MODES
local function light(mode)
	if mode=="CLARO" then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.Ambient = Color3.fromRGB(120,120,120)
	elseif mode=="PADRAO" then
		Lighting.Brightness = 1
		Lighting.ClockTime = 18
		Lighting.Ambient = Color3.fromRGB(70,70,70)
	elseif mode=="ESCURO" then
		Lighting.Brightness = 0.6
		Lighting.ClockTime = 22
		Lighting.Ambient = Color3.fromRGB(35,35,35)
	end
end

-- OPTIMIZATION
local optimization = false
local function optimize(level)
	optimization = level > 0
	for _,v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Material = level==2 and Enum.Material.Plastic or v.Material
			v.CastShadow = level==0
		elseif v:IsA("ParticleEmitter") then
			v.Enabled = level<2
		end
	end
end

-- CROSSHAIR
local cross = Instance.new("Frame", gui)
cross.Size = UDim2.fromOffset(6,6)
cross.Position = UDim2.fromScale(0.5,0.5)
cross.AnchorPoint = Vector2.new(0.5,0.5)
cross.BackgroundColor3 = Color3.new(1,1,1)
cross.Visible = false

-- FPS
local fpsLabel = Instance.new("TextLabel", gui)
fpsLabel.Size = UDim2.fromOffset(120,30)
fpsLabel.Position = UDim2.fromOffset(10,10)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 14
fpsLabel.TextColor3 = Color3.new(1,1,1)

local frames, last = 0, tick()
RunService.RenderStepped:Connect(function()
	frames += 1
	if tick()-last >= 1 then
		fpsLabel.Text = "FPS: "..frames
		frames = 0
		last = tick()
	end
end)

-- BUTTONS
button("Modo Claro",0.15).MouseButton1Click:Connect(function() light("CLARO") end)
button("Modo Padrão",0.27).MouseButton1Click:Connect(function() light("PADRAO") end)
button("Modo Escuro",0.39).MouseButton1Click:Connect(function() light("ESCURO") end)

button("Otimização OFF",0.51).MouseButton1Click:Connect(function() optimize(0) end)
button("Otimização Média",0.63).MouseButton1Click:Connect(function() optimize(1) end)
button("Otimização Alta",0.75).MouseButton1Click:Connect(function() optimize(2) end)

button("Mira ON/OFF",0.87).MouseButton1Click:Connect(function()
	cross.Visible = not cross.Visible
end)

warn("Bloxtrap Mobile v4.1 carregado")
