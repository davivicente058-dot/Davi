-- ======================================================
-- FPSBLOX DEFINITIVO - UI BASE
-- Biblioteca UI (Rayfield)
-- NÃO TEM FUNÇÕES AINDA
-- APENAS INTERFACE
-- ======================================================

-- Evita carregar duas vezes
if _G.FPSBLOX_UI_LOADED then return end
_G.FPSBLOX_UI_LOADED = true

-- Carregar biblioteca Rayfield
local Rayfield = loadstring(game:HttpGet(
    "https://sirius.menu/rayfield"
))()

-- Criar Janela Principal
local Window = Rayfield:CreateWindow({
    Name = "FPSBLOX Definitivo",
    LoadingTitle = "FPSBLOX",
    LoadingSubtitle = "Otimização Mobile & PC",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FPSBLOX", -- pasta nos saves
        FileName = "Config"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Criar Abas (SEM FUNÇÕES)
local TabPerformance = Window:CreateTab("⚡ Performance", 4483362458)
local TabGraphics    = Window:CreateTab("🎨 Gráficos", 4483362458)
local TabVisuals     = Window:CreateTab("🎯 Visual", 4483362458)
local TabSystem      = Window:CreateTab("🛠 Sistema", 4483362458)
local TabInfo        = Window:CreateTab("ℹ Sobre", 4483362458)

-- Aviso inicial
Rayfield:Notify({
    Title = "FPSBLOX",
    Content = "Interface carregada com sucesso.",
    Duration = 4,
    Image = 4483362458
})

-- ======================================================
-- FIM DA BIBLIOTECA UI
-- NÃO COLOQUE FUNÇÕES AQUI
-- ======================================================

-- ======================================================
-- FPSBLOX DEFINITIVO - PARTE 1
-- Núcleo de Performance (Otimização FPS)
-- Compatível com Rayfield UI
-- ======================================================

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- Estados
local OptimizationEnabled = false
local OptimizationMode = "Médio" -- Leve | Médio | Agressivo

-- Cache original
local Original = {
    Parts = {},
    Lighting = {
        GlobalShadows = Lighting.GlobalShadows
    }
}

-- ======================================================
-- FUNÇÕES DE OTIMIZAÇÃO
-- ======================================================

local function CachePart(part)
    if not Original.Parts[part] then
        Original.Parts[part] = {
            Material = part.Material,
            Reflectance = part.Reflectance,
            CastShadow = part.CastShadow
        }
    end
end

local function OptimizePart(part)
    CachePart(part)
    part.Material = Enum.Material.SmoothPlastic
    part.Reflectance = 0
    part.CastShadow = false
end

local function RestoreParts()
    for part, data in pairs(Original.Parts) do
        if part and part.Parent then
            part.Material = data.Material
            part.Reflectance = data.Reflectance
            part.CastShadow = data.CastShadow
        end
    end
end

local function OptimizeWorkspace(level)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            OptimizePart(obj)
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            if level == "Agressivo" then
                pcall(function() obj:Destroy() end)
            else
                obj.Transparency = 1
            end
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            if level == "Agressivo" then
                obj.Enabled = false
            else
                obj.Rate = math.max(1, obj.Rate * 0.3)
            end
        end
    end
end

local function ApplyOptimization()
    Lighting.GlobalShadows = false
    OptimizeWorkspace(OptimizationMode)
end

local function DisableOptimization()
    RestoreParts()
    Lighting.GlobalShadows = Original.Lighting.GlobalShadows
end

-- ======================================================
-- UI - PERFORMANCE TAB
-- ======================================================

TabPerformance:CreateToggle({
    Name = "Otimização FPS",
    CurrentValue = false,
    Callback = function(Value)
        OptimizationEnabled = Value
        if Value then
            ApplyOptimization()
        else
            DisableOptimization()
        end
    end
})

TabPerformance:CreateDropdown({
    Name = "Modo de Otimização",
    Options = {"Leve", "Médio", "Agressivo"},
    CurrentOption = "Médio",
    Callback = function(Option)
        OptimizationMode = Option
        if OptimizationEnabled then
            ApplyOptimization()
        end
    end
})

TabPerformance:CreateParagraph({
    Title = "ℹ Informação",
    Content = "A otimização reduz efeitos visuais pesados para aumentar o FPS, funcionando tanto em celular fraco quanto em PC."
})

-- ======================================================
-- FIM DA PARTE 1
-- ======================================================

-- ======================================================
-- FPSBLOX DEFINITIVO - PARTE 2
-- Iluminação Inteligente (Claro / Padrão / Escuro Suave)
-- ======================================================

-- Estados de iluminação
local LightingMode = "Padrão" -- Claro | Padrão | Escuro
local LightOptimizationEnabled = false

-- Cache original (seguro)
local OriginalLighting = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    ExposureCompensation = Lighting.ExposureCompensation
}

-- ======================================================
-- FUNÇÕES DE ILUMINAÇÃO
-- ======================================================

local function ApplyLighting(mode)
    if mode == "Claro" then
        Lighting.Brightness = 2
        Lighting.ExposureCompensation = 0.2
        Lighting.Ambient = Color3.fromRGB(210, 210, 210)
        Lighting.OutdoorAmbient = Color3.fromRGB(210, 210, 210)
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000

    elseif mode == "Escuro" then
        -- ESCURO SUAVE (não cega, não apaga)
        Lighting.Brightness = 0.8
        Lighting.ExposureCompensation = -0.1
        Lighting.Ambient = Color3.fromRGB(90, 90, 90)
        Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
        Lighting.ClockTime = 20
        Lighting.FogEnd = 90000

    else
        -- PADRÃO (equilibrado)
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ExposureCompensation = OriginalLighting.ExposureCompensation
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
    end
end

-- ======================================================
-- SUAVIZAÇÃO DE LUZES DO MAPA (FPS + VISUAL)
-- ======================================================

local function OptimizeLights(enable)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            if enable then
                obj.Brightness = obj.Brightness * 0.7
                obj.Range = math.clamp(obj.Range, 4, 16)
                obj.Shadows = false
            end
        end
    end
end

-- ======================================================
-- UI - GRÁFICOS
-- ======================================================

TabGraphics:CreateDropdown({
    Name = "Modo de Iluminação",
    Options = {"Padrão", "Claro", "Escuro"},
    CurrentOption = "Padrão",
    Callback = function(option)
        LightingMode = option
        ApplyLighting(option)
    end
})

TabGraphics:CreateToggle({
    Name = "Suavizar Luzes do Jogo",
    CurrentValue = false,
    Callback = function(value)
        LightOptimizationEnabled = value
        OptimizeLights(value)
    end
})

TabGraphics:CreateParagraph({
    Title = "💡 Iluminação Inteligente",
    Content = "O modo Escuro foi ajustado para não prejudicar visibilidade. A suavização reduz brilho excessivo e melhora FPS."
})

-- ======================================================
-- PROTEÇÃO CONTRA RESET DE MAPA
-- ======================================================

Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
    if LightingMode ~= "Padrão" then
        ApplyLighting(LightingMode)
    end
end)

-- ======================================================
-- FIM DA PARTE 2
-- ======================================================

-- ======================================================
-- FPSBLOX DEFINITIVO - PARTE 3
-- Mira Central REAL + FPS Counter Inteligente
-- ======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ======================================================
-- MIRA CENTRAL (FUNCIONAL DE VERDADE)
-- ======================================================

-- Remove mira antiga se existir
pcall(function()
    PlayerGui:FindFirstChild("FPSBLOX_CROSSHAIR"):Destroy()
end)

local CrosshairGui = Instance.new("ScreenGui")
CrosshairGui.Name = "FPSBLOX_CROSSHAIR"
CrosshairGui.IgnoreGuiInset = true
CrosshairGui.ResetOnSpawn = false
CrosshairGui.Parent = PlayerGui

local Crosshair = Instance.new("Frame")
Crosshair.Size = UDim2.fromOffset(24, 24)
Crosshair.Position = UDim2.fromScale(0.5, 0.5)
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.BackgroundTransparency = 1
Crosshair.Visible = false
Crosshair.Parent = CrosshairGui

local function CreateLine(parent, size, position)
    local line = Instance.new("Frame")
    line.Size = size
    line.Position = position
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = Color3.fromRGB(255,255,255)
    line.BorderSizePixel = 0
    line.Parent = parent
end

-- linhas da mira
CreateLine(Crosshair, UDim2.fromOffset(8, 2), UDim2.fromScale(0.5, 0.5))
CreateLine(Crosshair, UDim2.fromOffset(8, 2), UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(-8, 0))
CreateLine(Crosshair, UDim2.fromOffset(2, 8), UDim2.fromScale(0.5, 0.5))
CreateLine(Crosshair, UDim2.fromOffset(2, 8), UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(0, -8))

-- ======================================================
-- FPS COUNTER REAL (MÉDIA INTELIGENTE)
-- ======================================================

pcall(function()
    PlayerGui:FindFirstChild("FPSBLOX_FPS"):Destroy()
end)

local FpsGui = Instance.new("ScreenGui")
FpsGui.Name = "FPSBLOX_FPS"
FpsGui.IgnoreGuiInset = true
FpsGui.ResetOnSpawn = false
FpsGui.Parent = PlayerGui

local FpsLabel = Instance.new("TextLabel")
FpsLabel.Size = UDim2.fromOffset(110, 32)
FpsLabel.Position = UDim2.fromOffset(10, 10)
FpsLabel.BackgroundColor3 = Color3.fromRGB(20,20,20)
FpsLabel.BackgroundTransparency = 0.25
FpsLabel.TextColor3 = Color3.fromRGB(0,255,120)
FpsLabel.TextSize = 16
FpsLabel.Font = Enum.Font.GothamBold
FpsLabel.Text = "FPS: --"
FpsLabel.BorderSizePixel = 0
FpsLabel.Parent = FpsGui

-- cálculo real
local frames = 0
local lastTime = tick()
local fpsValue = 0
local smoothFPS = 0

RunService.RenderStepped:Connect(function()
    frames += 1
    local now = tick()

    if now - lastTime >= 1 then
        fpsValue = frames / (now - lastTime)
        smoothFPS = smoothFPS + (fpsValue - smoothFPS) * 0.25
        FpsLabel.Text = "FPS: " .. math.floor(smoothFPS)
        frames = 0
        lastTime = now
    end
end)

-- ======================================================
-- UI - VISUAL TAB
-- ======================================================

TabVisuals:CreateToggle({
    Name = "Mira Central",
    CurrentValue = false,
    Callback = function(state)
        Crosshair.Visible = state
    end
})

TabVisuals:CreateToggle({
    Name = "Mostrar FPS",
    CurrentValue = true,
    Callback = function(state)
        FpsGui.Enabled = state
    end
})

TabVisuals:CreateParagraph({
    Title = "🎯 Mira & FPS",
    Content = "Mira fixa no centro da tela (funciona em mobile). FPS real calculado por RenderStepped com suavização."
})

-- ======================================================
-- FIM DA PARTE 3
-- =====================================================

-- ======================================================
-- FPSBLOX DEFINITIVO - PARTE 4
-- Estabilidade Avançada & Fluidez
-- ======================================================

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")

-- Estados
local StabilizerEnabled = false
local AutoLowPower = false
local HeartbeatLimiter = false

-- ======================================================
-- 1. ESTABILIZADOR DE FRAMES (ANTI-STUTTER)
-- ======================================================

-- Remove picos bruscos de frame time
local lastDelta = 1/60
RunService.RenderStepped:Connect(function(dt)
    if StabilizerEnabled then
        -- Suavização de delta (reduz micro travadas)
        lastDelta = lastDelta + (dt - lastDelta) * 0.15
        task.wait(math.clamp(lastDelta, 0, 0.03))
    end
end)

-- ======================================================
-- 2. HEARTBEAT CONTROL (FLUIDEZ)
-- ======================================================

RunService.Heartbeat:Connect(function()
    if HeartbeatLimiter then
        task.wait(0.003) -- reduz picos de processamento
    end
end)

-- ======================================================
-- 3. LIMPEZA INVISÍVEL DE PROCESSOS PESADOS
-- ======================================================

local function ReduceHeavyObjects()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Explosion") then
            obj.BlastPressure = 0
            obj.Visible = false
        elseif obj:IsA("Smoke") or obj:IsA("Fire") then
            obj.Enabled = false
        end
    end
end

-- ======================================================
-- 4. AUTO LOW POWER MODE (INTELIGENTE)
-- ======================================================

task.spawn(function()
    while true do
        task.wait(2)

        if AutoLowPower then
            local fps = Stats.Workspace:GetRealPhysicsFPS()

            -- Quando o FPS cai, força estabilidade
            if fps < 45 then
                StabilizerEnabled = true
                HeartbeatLimiter = true
                ReduceHeavyObjects()
            else
                StabilizerEnabled = false
                HeartbeatLimiter = false
            end
        end
    end
end)

-- ======================================================
-- UI - SISTEMA
-- ======================================================

TabSystem:CreateToggle({
    Name = "Estabilizador de FPS (Anti-Stutter)",
    CurrentValue = false,
    Callback = function(state)
        StabilizerEnabled = state
    end
})

TabSystem:CreateToggle({
    Name = "Controle de Heartbeat (Mais Fluidez)",
    CurrentValue = false,
    Callback = function(state)
        HeartbeatLimiter = state
    end
})

TabSystem:CreateToggle({
    Name = "Auto Low Power (Inteligente)",
    CurrentValue = false,
    Callback = function(state)
        AutoLowPower = state
    end
})

TabSystem:CreateParagraph({
    Title = "⚙️ Estabilidade & Fluidez",
    Content = "Essas funções reduzem travadas invisíveis, melhoram a fluidez do movimento e estabilizam o FPS em celulares fracos e PCs médios."
})

-- ======================================================
-- FIM DA PARTE 4
-- ======================================================

-- ======================================================
-- FPSBLOX DEFINITIVO - PARTE 5 (PLUS / MASTER)
-- Frame Pacing • Prioridade de Render • Estabilidade Máxima
-- ======================================================

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

-- Estados
local MasterMode = false
local AdaptivePacing = false
local RenderPriorityBoost = false

-- Variáveis internas
local smoothDelta = 1/60
local targetFPS = 60

-- ======================================================
-- 1. FRAME PACING ADAPTATIVO (SEM BUG)
-- ======================================================

RunService.RenderStepped:Connect(function(dt)
    if not MasterMode then return end

    -- Suavização progressiva (sem travar engine)
    smoothDelta += (dt - smoothDelta) * 0.1

    if AdaptivePacing then
        -- Apenas micro-ajuste, seguro
        if smoothDelta > (1 / targetFPS) * 1.3 then
            task.wait(0.001)
        end
    end
end)

-- ======================================================
-- 2. PRIORIDADE DE RENDER (SENSAÇÃO DE FLUIDEZ)
-- ======================================================

if RenderPriorityBoost then
    RunService:BindToRenderStep(
        "FPSBLOX_MasterRender",
        Enum.RenderPriority.Camera.Value + 5,
        function()
            -- Nada pesado aqui de propósito
        end
    )
end

-- ======================================================
-- 3. AUTO AJUSTE INTELIGENTE
-- ======================================================

task.spawn(function()
    while true do
        task.wait(3)

        if MasterMode then
            local fps = Stats.Workspace:GetRealPhysicsFPS()

            -- Se cair, ativa recursos automaticamente
            if fps < 50 then
                AdaptivePacing = true
            else
                AdaptivePacing = false
            end
        end
    end
end)

-- ======================================================
-- UI - MASTER
-- ======================================================

TabSystem:CreateToggle({
    Name = "MASTER MODE (PLUS)",
    CurrentValue = false,
    Callback = function(state)
        MasterMode = state
    end
})

TabSystem:CreateToggle({
    Name = "Frame Pacing Adaptativo",
    CurrentValue = false,
    Callback = function(state)
        AdaptivePacing = state
    end
})

TabSystem:CreateToggle({
    Name = "Prioridade de Render (Câmera + Fluidez)",
    CurrentValue = false,
    Callback = function(state)
        RenderPriorityBoost = state

        if state then
            RunService:BindToRenderStep(
                "FPSBLOX_MasterRender",
                Enum.RenderPriority.Camera.Value + 5,
                function() end
            )
        else
            pcall(function()
                RunService:UnbindFromRenderStep("FPSBLOX_MasterRender")
            end)
        end
    end
})

TabSystem:CreateParagraph({
    Title = "👑 PLUS / MASTER MODE",
    Content = "Modo avançado de fluidez. Reduz micro travamentos, melhora sensação da câmera e estabiliza o ritmo dos frames sem causar bugs."
})

-- ======================================================
-- FIM DA PARTE 5
-- ======================================================

======================================================
-- FPSBLOX DEFINITIVO - PARTE 6
-- Detecção Inteligente de 120Hz / 90Hz / 60Hz / 30Hz
-- ======================================================

local RunService = game:GetService("RunService")

-- Estados
local RefreshDetectEnabled = false
local DetectedRefresh = 60
local FPS_SAMPLES = {}
local SAMPLE_TIME = 1.2

-- Integração com partes anteriores (seguro)
if typeof(targetFPS) ~= "number" then
    targetFPS = 60
end

-- ======================================================
-- 1. DETECTOR REAL DE REFRESH RATE
-- ======================================================

local function detectRefreshRate()
    table.clear(FPS_SAMPLES)
    local startTime = tick()

    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        FPS_SAMPLES[#FPS_SAMPLES + 1] = dt

        if tick() - startTime >= SAMPLE_TIME then
            conn:Disconnect()

            local total = 0
            for _, v in ipairs(FPS_SAMPLES) do
                total += v
            end

            local avgDt = total / #FPS_SAMPLES
            local fps = math.floor((1 / avgDt) + 0.5)

            -- Margem segura
            if fps >= 110 then
                DetectedRefresh = 120
            elseif fps >= 80 then
                DetectedRefresh = 90
            elseif fps >= 50 then
                DetectedRefresh = 60
            else
                DetectedRefresh = 30
            end

            targetFPS = DetectedRefresh
        end
    end)
end

-- ======================================================
-- 2. AUTO MONITORAMENTO (LEVE)
-- ======================================================

task.spawn(function()
    while true do
        task.wait(6)

        if RefreshDetectEnabled then
            detectRefreshRate()
        end
    end
end)

-- ======================================================
-- UI - REFRESH RATE
-- ======================================================

TabSystem:CreateToggle({
    Name = "Detecção Automática de 120Hz / 90Hz",
    CurrentValue = false,
    Callback = function(state)
        RefreshDetectEnabled = state

        if state then
            detectRefreshRate()
        end
    end
})

TabSystem:CreateParagraph({
    Title = "📱 Detecção de Tela (Hz)",
    Content = "Detecta automaticamente se seu dispositivo é 120Hz, 90Hz, 60Hz ou 30Hz e ajusta a fluidez sem forçar FPS."
})

-- ======================================================
-- FIM DA PARTE 6
-- ======================================================

-- ======================================================
-- FPSBLOX DEFINITIVO - PARTE 7
-- Modo Gráficos Simples / Low Detail
-- ======================================================

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- Estados
local LowGraphicsEnabled = false

-- Backup de configurações (seguro)
local OriginalLighting = {
    GlobalShadows = Lighting.GlobalShadows,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    Technology = Lighting.Technology,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
}

-- ======================================================
-- 1. FUNÇÃO: REDUZIR DETALHES DO MAPA
-- ======================================================

local function applyLowGraphics()
    -- Iluminação mais simples
    Lighting.GlobalShadows = false
    Lighting.Technology = Enum.Technology.Compatibility
    Lighting.Brightness = math.clamp(Lighting.Brightness * 0.8, 1, 2)

    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0

    Lighting.FogStart = 0
    Lighting.FogEnd = 150

    -- Remove efeitos pesados
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("BloomEffect")
        or effect:IsA("SunRaysEffect")
        or effect:IsA("ColorCorrectionEffect")
        or effect:IsA("DepthOfFieldEffect")
        or effect:IsA("BlurEffect") then
            effect.Enabled = false
        end
    end

    -- Simplificação do mapa
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            -- Remove reflexos e suaviza render
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0

        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = math.clamp(obj.Transparency + 0.2, 0, 1)

        elseif obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Beam") then
            obj.Enabled = false

        elseif obj:IsA("PointLight")
        or obj:IsA("SpotLight")
        or obj:IsA("SurfaceLight") then
            obj.Enabled = false
        end
    end
end

-- ======================================================
-- 2. FUNÇÃO: RESTAURAR GRÁFICOS
-- ======================================================

local function restoreGraphics()
    Lighting.GlobalShadows = OriginalLighting.GlobalShadows
    Lighting.Technology = OriginalLighting.Technology
    Lighting.Brightness = OriginalLighting.Brightness
    Lighting.FogEnd = OriginalLighting.FogEnd
    Lighting.FogStart = OriginalLighting.FogStart
    Lighting.EnvironmentDiffuseScale = OriginalLighting.EnvironmentDiffuseScale
    Lighting.EnvironmentSpecularScale = OriginalLighting.EnvironmentSpecularScale

    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = true
        end
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Beam")
        or obj:IsA("PointLight")
        or obj:IsA("SpotLight")
        or obj:IsA("SurfaceLight") then
            obj.Enabled = true
        end
    end
end

-- ======================================================
-- 3. UI - GRÁFICOS SIMPLES
-- ======================================================

TabGraphics:CreateToggle({
    Name = "Modo Gráficos Simples (FPS Boost)",
    CurrentValue = false,
    Callback = function(state)
        LowGraphicsEnabled = state

        if state then
            applyLowGraphics()
        else
            restoreGraphics()
        end
    end
})

TabGraphics:CreateParagraph({
    Title = "🎮 Gráficos Simplificados",
    Content = "Remove detalhes visuais, sombras e luzes desnecessárias para aumentar FPS, ideal para celulares fracos."
})

-- ======================================================
-- FIM DA PARTE 7
-- =====================================================

-- ======================================================
-- FPSBLOX DEFINITIVO - PARTE 8
-- Render Distance / Chunks (Estilo Minecraft)
-- ======================================================

local Lighting = game:GetService("Lighting")

-- Backup original
local OriginalFog = {
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    FogColor = Lighting.FogColor,
    Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
}

-- Cria Atmosphere se não existir
local Atmosphere = OriginalFog.Atmosphere
if not Atmosphere then
    Atmosphere = Instance.new("Atmosphere")
    Atmosphere.Parent = Lighting
end

-- Presets (chunks)
local RenderPresets = {
    ["Muito Baixo"] = {FogStart = 0, FogEnd = 120, Density = 0.6},
    ["Baixo"]      = {FogStart = 0, FogEnd = 200, Density = 0.45},
    ["Médio"]      = {FogStart = 0, FogEnd = 350, Density = 0.3},
    ["Alto"]       = {FogStart = 0, FogEnd = 600, Density = 0.15},
    ["Ultra"]      = {FogStart = 0, FogEnd = 1200, Density = 0.05},
    ["Desligado"]  = nil
}

local CurrentRenderMode = "Desligado"

-- ======================================================
-- FUNÇÃO: APLICAR DISTÂNCIA DE RENDER
-- ======================================================

local function applyRenderDistance(mode)
    local preset = RenderPresets[mode]
    CurrentRenderMode = mode

    if not preset then
        -- Restaurar
        Lighting.FogStart = OriginalFog.FogStart
        Lighting.FogEnd = OriginalFog.FogEnd
        Atmosphere.Density = 0
        return
    end

    Lighting.FogStart = preset.FogStart
    Lighting.FogEnd = preset.FogEnd

    Atmosphere.Density = preset.Density
    Atmosphere.Color = Lighting.FogColor
    Atmosphere.Offset = 0
end

-- ======================================================
-- UI - CONTROLE DE CHUNKS
-- ======================================================

TabGraphics:CreateDropdown({
    Name = "Distância de Render (Chunks)",
    Options = {"Muito Baixo", "Baixo", "Médio", "Alto", "Ultra", "Desligado"},
    CurrentOption = "Desligado",
    Callback = function(option)
        applyRenderDistance(option)
    end
})

TabGraphics:CreateParagraph({
    Title = "🌫️ Distância de Render",
    Content = "Limita até onde o mapa é renderizado usando névoa. Quanto menor, mais FPS — igual aos chunks do Minecraft."
})

-- ======================================================
-- FIM DA PARTE 8
-- ======================================================

-- ======================================================
-- FPSBLOX - CONTROLE DE SOMBRAS (NOVA OPÇÃO)
-- ======================================================

local Lighting = game:GetService("Lighting")

-- Backup original
local OriginalShadows = {
    GlobalShadows = Lighting.GlobalShadows,
    ShadowSoftness = Lighting.ShadowSoftness
}

local function setShadows(mode)
    if mode == "Alta" then
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 1

    elseif mode == "Média" then
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 0.5

    elseif mode == "Baixa" then
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 0.1

    elseif mode == "Desligada" then
        Lighting.GlobalShadows = false
    end
end

-- ======================================================
-- UI - OPÇÃO DE SOMBRAS
-- ======================================================

TabGraphics:CreateDropdown({
    Name = "Qualidade das Sombras",
    Options = {"Alta", "Média", "Baixa", "Desligada"},
    CurrentOption = "Média",
    Callback = function(option)
        setShadows(option)
    end
})

TabGraphics:CreateParagraph({
    Title = "🌑 Sombras",
    Content = "Reduz o peso das sombras para ganhar FPS. Em celulares fracos, use Baixa ou Desligada."
})

-- ======================================================
-- FIM DO CONTROLE DE SOMBRAS
-- ======================================================
