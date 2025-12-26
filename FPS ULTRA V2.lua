-- FPS Boost + UI Clássica + Controle de Iluminação + Minimizar + Mira Aprimorada

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- UI Principal
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "FPS_UI"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 250, 0, 200)
mainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "FPS Boost Menu"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local minimizeBtn = Instance.new("TextButton", title)
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -30, 0, 0)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.BackgroundTransparency = 1

local function makeButton(text, y)
    local btn = Instance.new("TextButton", contentFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Text = text
    return btn
end

-- Mira aprimorada (cruz central)
local mira = Instance.new("Frame", screenGui)
mira.Name = "MiraCentral"
mira.BackgroundTransparency = 1
mira.Size = UDim2.new(0, 20, 0, 20)
mira.Position = UDim2.new(0.5, -10, 0.5, -10)

local function criarLinha(x, y, w, h)
    local linha = Instance.new("Frame", mira)
    linha.Size = UDim2.new(0, w, 0, h)
    linha.Position = UDim2.new(0.5, x, 0.5, y)
    linha.BackgroundColor3 = Color3.new(1, 1, 1)
    linha.BorderSizePixel = 0
end

criarLinha(-10, -1, 8, 2) -- esquerda
criarLinha(2, -1, 8, 2)   -- direita
criarLinha(-1, -10, 2, 8) -- cima
criarLinha(-1, 2, 2, 8)   -- baixo

-- FPS Counter
local fpsLabel = Instance.new("TextLabel", screenGui)
fpsLabel.Size = UDim2.new(0, 100, 0, 25)
fpsLabel.Position = UDim2.new(0.01, 0, 0.01, 0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.new(1, 1, 1)
fpsLabel.TextStrokeTransparency = 0.5
fpsLabel.Text = "FPS: 0"

local lastUpdate = tick()
local frameCount = 0

RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = tick()
    if now - lastUpdate >= 1 then
        fpsLabel.Text = "FPS: " .. math.floor(frameCount / (now - lastUpdate))
        frameCount = 0
        lastUpdate = now
    end
end)

-- Funções
local function aplicarModoEscuro()
    Lighting.Ambient = Color3.new(0.1, 0.1, 0.1)
    Lighting.OutdoorAmbient = Color3.new(0.1, 0.1, 0.1)
    Lighting.Brightness = 0.3
    Lighting.ClockTime = 20
end

local function aplicarModoClaro()
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
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
end

-- Botões
local btnBoost = makeButton("Ativar FPS Boost", 10)
btnBoost.MouseButton1Click:Connect(boostFPS)

local btnMira = makeButton("Mira: ON", 50)
btnMira.MouseButton1Click:Connect(function()
    mira.Visible = not mira.Visible
    btnMira.Text = mira.Visible and "Mira: ON" or "Mira: OFF"
end)

local btnIluminacao = makeButton("Modo: Escuro", 90)
local modoEscuro = true
btnIluminacao.MouseButton1Click:Connect(function()
    modoEscuro = not modoEscuro
    if modoEscuro then
        aplicarModoEscuro()
        btnIluminacao.Text = "Modo: Escuro"
    else
        aplicarModoClaro()
        btnIluminacao.Text = "Modo: Claro"
    end
end)

-- Minimizar
local minimizado = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    contentFrame.Visible = not minimizado
    minimizeBtn.Text = minimizado and "+" or "-"
end)
