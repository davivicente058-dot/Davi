-- FPS Boost + Mira + UI (Delta Mobile)
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- UI
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "FPS_UI"

local function makeButton(text, x, y, size)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.3, 0, 0.05, 0)
	btn.Position = UDim2.new(x, 0, y, 0)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = text
	btn.Parent = screenGui
	return btn
end

-- Mira
local mira = Instance.new("Frame")
mira.Name = "MiraCentral"
mira.Size = UDim2.new(0, 4, 0, 4)
mira.Position = UDim2.new(0.5, -2, 0.5, -50)
mira.BackgroundColor3 = Color3.new(1, 1, 1)
mira.BorderSizePixel = 0
mira.Visible = true
mira.Parent = screenGui

-- FPS Counter
local fpsLabel = Instance.new("TextLabel", screenGui)
fpsLabel.Size = UDim2.new(0, 100, 0, 25)
fpsLabel.Position = UDim2.new(0.01, 0, 0.01, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.new(1, 1, 1)
fpsLabel.TextStrokeTransparency = 0.5
fpsLabel.Text = "FPS: 0"

-- FPS Calculation
local lastUpdate = tick()
local frameCount = 0
local fps = 0

RunService.RenderStepped:Connect(function()
	frameCount += 1
	local now = tick()
	if now - lastUpdate >= 1 then
		fps = math.floor(frameCount / (now - lastUpdate))
		fpsLabel.Text = "FPS: " .. fps
		frameCount = 0
		lastUpdate = now
	end
end)

-- Otimizações
local function aplicarModoEscuro()
	Lighting.Ambient = Color3.new(0.1, 0.1, 0.1)
	Lighting.OutdoorAmbient = Color3.new(0.1, 0.1, 0.1)
	Lighting.Brightness = 0.3
	Lighting.ClockTime = 20
end

local function boostFPS()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Material = Enum.Material.SmoothPlastic
			v.Reflectance = 0
			v.CastShadow = false
		elseif v:IsA("Decal") or v:IsA("Texture") then
			v:Destroy()
		end
	end
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 100000
	aplicarModoEscuro()
end

-- Botões
local btnBoost = makeButton("Ativar FPS Boost", 0.34, 0.6, 0.30)
btnBoost.MouseButton1Down:Connect(boostFPS)

local btnMira = makeButton("Mira: ON", 0.34, 0.68, 0.30)
btnMira.MouseButton1Down:Connect(function()
	mira.Visible = not mira.Visible
	btnMira.Text = mira.Visible and "Mira: ON" or "Mira: OFF"
end)
