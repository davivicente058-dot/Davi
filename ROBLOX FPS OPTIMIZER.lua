-- ROBLOX FPS OPTIMIZER - REMAKE FINAL
-- Focado em celulares fracos
-- Tudo começa DESATIVADO
-- UI leve, limpa e funcional

-- =============================
-- SERVIÇOS
-- =============================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- =============================
-- ESTADO DAS FUNÇÕES
-- =============================
local STATE = {
    optimize = false,
    competitive = false,
    shadows = false,
    lights = false,
    particles = false,
    fog = false,
    fpsCounter = false
}

-- =============================
-- FUNÇÕES DE OTIMIZAÇÃO
-- =============================

local function OptimizeGraphics()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
            v.CastShadow = not STATE.shadows
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = not STATE.particles
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 0.4
        end
    end
end

local function ReduceLights()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
            v.Enabled = not STATE.lights
        end
    end
end

local function ApplyFog()
    if STATE.fog then
        Lighting.FogEnd = 250
        Lighting.FogStart = 0
    else
        Lighting.FogEnd = 100000
    end
end

local function CompetitiveMode()
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.Brightness = 2

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CastShadow = false
            v.Material = Enum.Material.Plastic
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
end

-- =============================
-- FPS COUNTER
-- =============================
local fpsGui, fpsLabel
local frames = 0
local last = tick()

local function EnableFPSCounter()
    if fpsGui then return end

    fpsGui = Instance.new("ScreenGui")
    fpsGui.ResetOnSpawn = false
    fpsGui.Parent = player.PlayerGui

    fpsLabel = Instance.new("TextLabel", fpsGui)
    fpsLabel.Size = UDim2.new(0,120,0,30)
    fpsLabel.Position = UDim2.new(0,10,1,-40)
    fpsLabel.BackgroundTransparency = 0.4
    fpsLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
    fpsLabel.TextColor3 = Color3.fromRGB(0,255,0)
    fpsLabel.Font = Enum.Font.SourceSansBold
    fpsLabel.TextSize = 18
    fpsLabel.Text = "FPS: --"
    fpsLabel.TextXAlignment = Left

    RunService.RenderStepped:Connect(function()
        frames += 1
        if tick() - last >= 1 then
            fpsLabel.Text = "FPS: "..frames
            frames = 0
            last = tick()
        end
    end)
end

-- =============================
-- UI
-- =============================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,260,0,350)
main.Position = UDim2.new(0.5,-130,0.5,-175)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "ROBLOX FPS OPTIMIZER"
title.TextColor3 = Color3.fromRGB(0,255,120)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.BackgroundTransparency = 1

local function CreateToggle(text, y, callback)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1,-20,0,35)
    btn.Position = UDim2.new(0,10,0,y)
    btn.Text = "[ OFF ] "..text
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BorderSizePixel = 0

    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = (on and "[ ON ] " or "[ OFF ] ")..text
        callback(on)
    end)
end

CreateToggle("Otimização Geral", 50, function(v)
    STATE.optimize = v
    if v then OptimizeGraphics() end
end)

CreateToggle("Modo Competitivo (EXTREMO)", 90, function(v)
    STATE.competitive = v
    if v then CompetitiveMode() end
end)

CreateToggle("Reduzir Sombras", 130, function(v)
    STATE.shadows = v
    OptimizeGraphics()
end)

CreateToggle("Reduzir Luzes", 170, function(v)
    STATE.lights = v
    ReduceLights()
end)

CreateToggle("Remover Partículas", 210, function(v)
    STATE.particles = v
    OptimizeGraphics()
end)

CreateToggle("Névoa por Distância", 250, function(v)
    STATE.fog = v
    ApplyFog()
end)

CreateToggle("FPS Counter", 290, function(v)
    STATE.fpsCounter = v
    if v then EnableFPSCounter() end
end)

print("ROBLOX FPS OPTIMIZER CARREGADO COM SUCESSO")
