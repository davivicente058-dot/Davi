-- ===============================
-- RAYFIELD UI LIBRARY
-- ===============================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ===============================
-- FPSBLOX DEFINITIVO - PARTE 1
-- UI PRINCIPAL (RAYFIELD)
-- ===============================

_G.FPSBLOX = _G.FPSBLOX or {}
local FPSBLOX = _G.FPSBLOX

-- ===== JANELA PRINCIPAL =====
local Window = Rayfield:CreateWindow({
   Name = "FPSBLOX DEFINITIVO",
   LoadingTitle = "FPSBLOX",
   LoadingSubtitle = "Otimização Avançada",
   ConfigurationSaving = {
      Enabled = false -- você vai fazer save depois
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false
})

-- ===== ABAS =====
local TabFPS = Window:CreateTab("📊 FPS", 4483362458)
local TabOpt = Window:CreateTab("🚀 Otimização", 4483362458)
local TabGraf = Window:CreateTab("🎮 Gráficos", 4483362458)
local TabComp = Window:CreateTab("🏆 Competitivo", 4483362458)
local TabAdv = Window:CreateTab("⚙ Avançado", 4483362458)

-- ===== SEÇÃO FPS =====
TabFPS:CreateSection("Monitoramento")

TabFPS:CreateParagraph({
   Title = "FPSBLOX",
   Content = "Script de otimização avançada focado em celulares fracos e estabilidade real de FPS."
})

-- FPS Label será controlado por outra parte
FPSBLOX.FPSLabelEnabled = true

TabFPS:CreateToggle({
   Name = "Mostrar FPS",
   CurrentValue = true,
   Callback = function(v)
      FPSBLOX.FPSLabelEnabled = v
   end
})

-- ===== SEÇÃO OTIMIZAÇÃO =====
TabOpt:CreateSection("Otimização Geral")

TabOpt:CreateToggle({
   Name = "Otimização Geral",
   CurrentValue = false,
   Callback = function(v)
      if FPSBLOX.SetOptimization then
         FPSBLOX:SetOptimization(v)
      end
   end
})

TabOpt:CreateDropdown({
   Name = "Nível de Otimização",
   Options = {"Leve", "Equilibrado", "Agressivo"},
   CurrentOption = "Equilibrado",
   Callback = function(opt)
      FPSBLOX.OptimizationLevel = opt
   end
})

-- ===== SEÇÃO GRÁFICOS =====
TabGraf:CreateSection("Iluminação")

TabGraf:CreateDropdown({
   Name = "Modo de Iluminação",
   Options = {"Claro", "Padrão", "Escuro Suave"},
   CurrentOption = "Padrão",
   Callback = function(opt)
      if FPSBLOX.SetLightingMode then
         FPSBLOX:SetLightingMode(opt)
      end
   end
})

TabGraf:CreateToggle({
   Name = "Reduzir Sombras",
   CurrentValue = false,
   Callback = function(v)
      if FPSBLOX.SetShadows then
         FPSBLOX:SetShadows(v)
      end
   end
})

-- ===== SEÇÃO COMPETITIVO =====
TabComp:CreateSection("Modo Competitivo")

TabComp:CreateToggle({
   Name = "Modo Competitivo EXTREMO",
   CurrentValue = false,
   Callback = function(v)
      if FPSBLOX.SetCompetitiveMode then
         FPSBLOX:SetCompetitiveMode(v)
      end
   end
})

TabComp:CreateToggle({
   Name = "Desativar Mira (Competitivo)",
   CurrentValue = false,
   Callback = function(v)
      if FPSBLOX.SetCrosshair then
         FPSBLOX:SetCrosshair(not v)
      end
   end
})

-- ===== AVANÇADO =====
TabAdv:CreateSection("Sistema")

TabAdv:CreateToggle({
   Name = "Perfil Automático",
   CurrentValue = true,
   Callback = function(v)
      if FPSBLOX.SetAutoProfile then
         FPSBLOX:SetAutoProfile(v)
      end
   end
})

TabAdv:CreateToggle({
   Name = "Estabilidade Inteligente",
   CurrentValue = true,
   Callback = function(v)
      if FPSBLOX.SetStabilityLock then
         FPSBLOX:SetStabilityLock(v)
      end
   end
})

Rayfield:Notify({
   Title = "FPSBLOX",
   Content = "Interface carregada com sucesso",
   Duration = 4
})

-- ===== FIM DA PARTE 1 =====

--[[ 
=====================================================
 FPSBLOX DEFINITIVO - PARTE 2
 Interface Profissional (UI)
 Mobile / PC Friendly
=====================================================
]]

-- ===== REFERÊNCIAS =====
local FPSBLOX = _G.FPSBLOX
if not FPSBLOX then return end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ===== LIMPEZA DE UI ANTIGA =====
for _, v in ipairs(PlayerGui:GetChildren()) do
    if v.Name == "FPSBLOX_UI" then
        pcall(function() v:Destroy() end)
    end
end

-- ===== SCREEN GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FPSBLOX_UI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

FPSBLOX.UI = {}
FPSBLOX.UI.ScreenGui = ScreenGui

-- ===== FRAME PRINCIPAL =====
local Main = Instance.new("Frame")
Main.Size = UDim2.fromScale(0.32, 0.42)
Main.Position = UDim2.fromScale(0.04, 0.22)
Main.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Name = "Main"
Main.Parent = ScreenGui

Main:SetAttribute("Minimized", false)

-- ===== CANTOS =====
local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 14)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Thickness = 1
Stroke.Transparency = 0.6
Stroke.Color = Color3.fromRGB(60,60,60)

-- ===== TOPO =====
local Top = Instance.new("Frame", Main)
Top.Size = UDim2.fromScale(1, 0.14)
Top.BackgroundColor3 = Color3.fromRGB(26, 28, 34)
Top.BorderSizePixel = 0
Top.Parent = Main

local TopCorner = Instance.new("UICorner", Top)
TopCorner.CornerRadius = UDim.new(0,14)

-- ===== TÍTULO =====
local Title = Instance.new("TextLabel", Top)
Title.Size = UDim2.fromScale(1,1)
Title.BackgroundTransparency = 1
Title.Text = "FPSBLOX DEFINITIVO"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(230,230,230)

-- ===== BOTÃO MINIMIZAR =====
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.fromScale(0.12,0.8)
MinBtn.Position = UDim2.fromScale(0.86,0.1)
MinBtn.BackgroundColor3 = Color3.fromRGB(40,40,48)
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.TextColor3 = Color3.fromRGB(220,220,220)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = Top

local BtnCorner = Instance.new("UICorner", MinBtn)
BtnCorner.CornerRadius = UDim.new(0,10)

-- ===== CONTEÚDO =====
local Content = Instance.new("Frame")
Content.Size = UDim2.fromScale(1,0.86)
Content.Position = UDim2.fromScale(0,0.14)
Content.BackgroundTransparency = 1
Content.Parent = Main

FPSBLOX.UI.Content = Content

-- ===== SISTEMA DE ABAS (BASE) =====
FPSBLOX.UI.Tabs = {}
FPSBLOX.UI.ActiveTab = nil

function FPSBLOX.UI:CreateTab(name)
    local Tab = Instance.new("Frame")
    Tab.Size = UDim2.fromScale(1,1)
    Tab.BackgroundTransparency = 1
    Tab.Visible = false
    Tab.Name = name
    Tab.Parent = Content

    FPSBLOX.UI.Tabs[name] = Tab
    if not FPSBLOX.UI.ActiveTab then
        FPSBLOX.UI.ActiveTab = Tab
        Tab.Visible = true
    end
    return Tab
end

function FPSBLOX.UI:ShowTab(name)
    for _, t in pairs(FPSBLOX.UI.Tabs) do
        t.Visible = false
    end
    if FPSBLOX.UI.Tabs[name] then
        FPSBLOX.UI.Tabs[name].Visible = true
        FPSBLOX.UI.ActiveTab = FPSBLOX.UI.Tabs[name]
    end
end

-- ===== BOTÃO MINIMIZAR FUNCIONAL =====
local SavedSize = Main.Size

MinBtn.MouseButton1Click:Connect(function()
    if not Main:GetAttribute("Minimized") then
        Main:SetAttribute("Minimized", true)
        SavedSize = Main.Size
        TweenService:Create(Main, TweenInfo.new(0.25), {
            Size = UDim2.fromScale(0.18, 0.1)
        }):Play()
        Content.Visible = false
        Title.Text = "FPSBLOX"
    else
        Main:SetAttribute("Minimized", false)
        TweenService:Create(Main, TweenInfo.new(0.25), {
            Size = SavedSize
        }):Play()
        Content.Visible = true
        Title.Text = "FPSBLOX DEFINITIVO"
    end
end)

-- ===== LOG =====
print("[FPSBLOX] UI carregada com sucesso.")

-- FIM DA PARTE 2

--[[ 
=====================================================
 FPSBLOX DEFINITIVO - PARTE 3
 Engine de FPS REAL + Suavização
 FPS no canto inferior esquerdo (Mobile)
=====================================================
]]

-- ===== REFERÊNCIA GLOBAL =====
local FPSBLOX = _G.FPSBLOX
if not FPSBLOX then return end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ===== CONFIGURAÇÕES FPS =====
FPSBLOX.FPS = {
    Current = 0,
    Smoothed = 0,
    Lowest = math.huge,
    Highest = 0,
    Enabled = true
}

-- ===== UI FPS =====
local FPSGui = Instance.new("ScreenGui")
FPSGui.Name = "FPSBLOX_FPS"
FPSGui.ResetOnSpawn = false
FPSGui.IgnoreGuiInset = true
FPSGui.Parent = PlayerGui

local FPSFrame = Instance.new("Frame", FPSGui)
FPSFrame.Size = UDim2.fromOffset(120, 36)
FPSFrame.Position = UDim2.new(0, 12, 1, -48) -- canto inferior esquerdo
FPSFrame.BackgroundColor3 = Color3.fromRGB(18,18,22)
FPSFrame.BackgroundTransparency = 0.15
FPSFrame.BorderSizePixel = 0

local Corner = Instance.new("UICorner", FPSFrame)
Corner.CornerRadius = UDim.new(0,10)

local Stroke = Instance.new("UIStroke", FPSFrame)
Stroke.Color = Color3.fromRGB(60,60,60)
Stroke.Transparency = 0.6
Stroke.Thickness = 1

local FPSText = Instance.new("TextLabel", FPSFrame)
FPSText.Size = UDim2.fromScale(1,1)
FPSText.BackgroundTransparency = 1
FPSText.Text = "FPS: 0"
FPSText.Font = Enum.Font.GothamBold
FPSText.TextSize = 15
FPSText.TextColor3 = Color3.fromRGB(240,240,240)
FPSText.TextStrokeTransparency = 0.6

FPSBLOX.FPS.UI = FPSFrame

-- ===== ENGINE FPS REAL =====
local frames = 0
local lastTime = tick()
local smoothFPS = 60 -- valor inicial estável

-- fator de suavização (quanto menor, mais suave)
local SMOOTH_FACTOR = 0.15

RunService.RenderStepped:Connect(function()
    frames += 1
    local now = tick()

    if now - lastTime >= 1 then
        local rawFPS = frames / (now - lastTime)
        frames = 0
        lastTime = now

        -- Suavização exponencial (EMA)
        smoothFPS = (smoothFPS * (1 - SMOOTH_FACTOR)) + (rawFPS * SMOOTH_FACTOR)

        local displayFPS = math.floor(smoothFPS + 0.5)

        FPSBLOX.FPS.Current = rawFPS
        FPSBLOX.FPS.Smoothed = displayFPS

        FPSBLOX.FPS.Lowest = math.min(FPSBLOX.FPS.Lowest, displayFPS)
        FPSBLOX.FPS.Highest = math.max(FPSBLOX.FPS.Highest, displayFPS)

        FPSText.Text = "FPS: " .. displayFPS

        -- feedback visual leve
        if displayFPS < 30 then
            FPSText.TextColor3 = Color3.fromRGB(255,120,120)
        elseif displayFPS < 45 then
            FPSText.TextColor3 = Color3.fromRGB(255,200,120)
        else
            FPSText.TextColor3 = Color3.fromRGB(170,255,170)
        end
    end
end)

-- ===== CONTROLE DE VISIBILIDADE (OUTRAS PARTES USARÃO) =====
function FPSBLOX.FPS:SetVisible(state)
    FPSFrame.Visible = state
end

-- ===== LOG =====
print("[FPSBLOX] Engine de FPS carregada.")

-- FIM DA PARTE 3

--[[
=====================================================
 FPSBLOX DEFINITIVO - PARTE 4
 Otimização Inteligente de Mapa
 (Materiais, Partículas, Sombras, Detalhes)
=====================================================
]]

local FPSBLOX = _G.FPSBLOX
if not FPSBLOX then return end

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- ===== CONFIG =====
FPSBLOX.WorldOptimizer = {
    Enabled = false,
    Level = "OFF", -- OFF | LOW | MEDIUM | ULTRA
}

-- ===== BACKUP ORIGINAL =====
local OriginalLighting = {
    GlobalShadows = Lighting.GlobalShadows,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    Technology = Lighting.Technology
}

-- ===== FUNÇÕES INTERNAS =====
local function optimizeParts(material)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = material
            obj.Reflectance = 0
        end
    end
end

local function disableParticles()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter")
        or v:IsA("Trail")
        or v:IsA("Fire")
        or v:IsA("Smoke")
        or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
end

local function simplifyDecals()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        end
    end
end

local function optimizeSounds()
    for _, s in ipairs(Workspace:GetDescendants()) do
        if s:IsA("Sound") then
            s.RollOffMaxDistance = 40
            s.PlaybackSpeed = 1
        end
    end
end

-- ===== MODOS =====
local function applyLow()
    Lighting.GlobalShadows = false
    Lighting.Technology = Enum.Technology.Compatibility
    Lighting.FogEnd = 500
    optimizeParts(Enum.Material.Plastic)
end

local function applyMedium()
    Lighting.GlobalShadows = false
    Lighting.Technology = Enum.Technology.Compatibility
    Lighting.FogEnd = 350
    optimizeParts(Enum.Material.SmoothPlastic)
    disableParticles()
end

local function applyUltra()
    Lighting.GlobalShadows = false
    Lighting.Technology = Enum.Technology.Compatibility
    Lighting.FogEnd = 200
    Lighting.Brightness = 1

    optimizeParts(Enum.Material.Plastic)
    disableParticles()
    simplifyDecals()
    optimizeSounds()
end

local function restore()
    for k,v in pairs(OriginalLighting) do
        Lighting[k] = v
    end
end

-- ===== API PRINCIPAL =====
function FPSBLOX:SetWorldOptimization(level)
    FPSBLOX.WorldOptimizer.Level = level

    if level == "OFF" then
        FPSBLOX.WorldOptimizer.Enabled = false
        restore()
        print("[FPSBLOX] Otimização desativada.")
        return
    end

    FPSBLOX.WorldOptimizer.Enabled = true

    if level == "LOW" then
        applyLow()
    elseif level == "MEDIUM" then
        applyMedium()
    elseif level == "ULTRA" then
        applyUltra()
    end

    print("[FPSBLOX] Otimização aplicada:", level)
end

-- ===== AUTO ADAPTATIVO (INTELIGENTE) =====
RunService.Heartbeat:Connect(function()
    if not FPSBLOX.WorldOptimizer.Enabled then return end
    if not FPSBLOX.FPS or not FPSBLOX.FPS.Smoothed then return end

    local fps = FPSBLOX.FPS.Smoothed

    if fps < 25 and FPSBLOX.WorldOptimizer.Level ~= "ULTRA" then
        FPSBLOX:SetWorldOptimization("ULTRA")
    elseif fps < 40 and FPSBLOX.WorldOptimizer.Level == "LOW" then
        FPSBLOX:SetWorldOptimization("MEDIUM")
    end
end)

print("[FPSBLOX] World Optimizer carregado.")

-- FIM DA PARTE 4

--[[
=====================================================
 FPSBLOX DEFINITIVO - PARTE 5
 MODO COMPETITIVO EXTREMO
 Foco: INPUT LAG | FLUIDEZ | FPS ESTÁVEL
=====================================================
]]

local FPSBLOX = _G.FPSBLOX
if not FPSBLOX then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- ===== CONFIG =====
FPSBLOX.Competitive = {
    Enabled = false
}

-- ===== BACKUP =====
local Backup = {
    RenderStepped = RunService.RenderStepped,
    Heartbeat = RunService.Heartbeat,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    Brightness = Lighting.Brightness,
}

-- ===== FUNÇÕES =====

-- Remove animações inúteis (visual, não quebra gameplay)
local function disableExtraAnimations(character)
    for _, track in ipairs(character:GetDescendants()) do
        if track:IsA("Animation") then
            pcall(function()
                track.AnimationId = ""
            end)
        end
    end
end

-- Reduz física invisível
local function optimizePhysics()
    settings().Physics.AllowSleep = true
    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
end

-- Reduz cálculos fora da tela
local function optimizeHiddenParts()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CastShadow = false
        end
    end
end

-- Suaviza frame pacing (sensação de jogo solto)
local last = tick()
local function framePacing()
    RunService.RenderStepped:Connect(function()
        local now = tick()
        local delta = now - last
        last = now

        if delta > 0.05 then
            task.wait(0.001)
        end
    end)
end

-- Redução extrema de render invisível
local function viewportOptimizer()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 180
    Lighting.Brightness = 1
end

-- ===== ATIVAR MODO =====
function FPSBLOX:EnableCompetitiveMode()
    if FPSBLOX.Competitive.Enabled then return end
    FPSBLOX.Competitive.Enabled = true

    optimizePhysics()
    optimizeHiddenParts()
    viewportOptimizer()
    framePacing()

    if LocalPlayer.Character then
        disableExtraAnimations(LocalPlayer.Character)
    end

    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        disableExtraAnimations(char)
    end)

    print("[FPSBLOX] MODO COMPETITIVO ATIVADO")
end

-- ===== DESATIVAR MODO =====
function FPSBLOX:DisableCompetitiveMode()
    if not FPSBLOX.Competitive.Enabled then return end
    FPSBLOX.Competitive.Enabled = false

    Lighting.GlobalShadows = Backup.GlobalShadows
    Lighting.FogEnd = Backup.FogEnd
    Lighting.Brightness = Backup.Brightness

    print("[FPSBLOX] MODO COMPETITIVO DESATIVADO")
end

-- ===== ALTERNAR =====
function FPSBLOX:ToggleCompetitiveMode()
    if FPSBLOX.Competitive.Enabled then
        FPSBLOX:DisableCompetitiveMode()
    else
        FPSBLOX:EnableCompetitiveMode()
    end
end

print("[FPSBLOX] Competitive Mode carregado.")

-- FIM DO MODO COMPETITIVO (PARTE 5)

--[[
=====================================================
 FPSBLOX DEFINITIVO - PARTE 6
 DETECÇÃO DE HZ + FRAME ADAPTATIVO
=====================================================
]]

local FPSBLOX = _G.FPSBLOX
if not FPSBLOX then return end

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

FPSBLOX.Display = {
    RefreshRate = 60,
    AdaptiveFrame = true
}

-- ===== DETECÇÃO REAL DE FPS MÉDIO =====
local frameCount = 0
local startTime = tick()
local detected = false

RunService.RenderStepped:Connect(function()
    if detected then return end
    frameCount += 1

    if tick() - startTime >= 2 then
        local avgFPS = frameCount / (tick() - startTime)

        if avgFPS >= 110 then
            FPSBLOX.Display.RefreshRate = 120
        elseif avgFPS >= 80 then
            FPSBLOX.Display.RefreshRate = 90
        else
            FPSBLOX.Display.RefreshRate = 60
        end

        detected = true
        print("[FPSBLOX] Refresh detectado:", FPSBLOX.Display.RefreshRate .. "Hz")
    end
end)

-- ===== FRAME ADAPTATIVO =====
local lastFrame = tick()

local function adaptiveFrameController()
    RunService.RenderStepped:Connect(function()
        if not FPSBLOX.Display.AdaptiveFrame then return end

        local now = tick()
        local delta = now - lastFrame
        lastFrame = now

        -- Evita stutter em dispositivos fracos
        if FPSBLOX.Display.RefreshRate <= 60 then
            if delta > 0.045 then
                task.wait(0.002)
            end
        end

        -- Suavização extra em 90Hz
        if FPSBLOX.Display.RefreshRate == 90 then
            if delta > 0.03 then
                task.wait(0.001)
            end
        end

        -- Em 120Hz deixa o jogo solto
        if FPSBLOX.Display.RefreshRate >= 120 then
            -- não interfere, deixa fluir
        end
    end)
end

adaptiveFrameController()

-- ===== OPÇÕES =====
function FPSBLOX:SetAdaptiveFrame(state)
    FPSBLOX.Display.AdaptiveFrame = state
    print("[FPSBLOX] Adaptive Frame:", state and "ON" or "OFF")
end

print("[FPSBLOX] Parte 6 carregada: Frame Adaptativo ativo.")

-- FIM DA PARTE 6

--[[
=====================================================
 FPSBLOX DEFINITIVO - PARTE 7
 GRÁFICOS INTELIGENTES + MAPA LEVE
=====================================================
]]

local FPSBLOX = _G.FPSBLOX
if not FPSBLOX then return end

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

FPSBLOX.Graphics = {
    Enabled = false,
    DistanceLimit = 120,
    LowDetail = true,
    SoftFog = true
}

-- ===== BACKUP ORIGINAL =====
local originalLighting = {
    GlobalShadows = Lighting.GlobalShadows,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart
}

local storedParts = {}

-- ===== FUNÇÃO DE OTIMIZAÇÃO VISUAL =====
local function optimizeWorld(enable)
    FPSBLOX.Graphics.Enabled = enable

    if enable then
        -- 🌫️ Fog inteligente (estilo chunks)
        Lighting.FogStart = 60
        Lighting.FogEnd = FPSBLOX.Graphics.DistanceLimit
        Lighting.GlobalShadows = false
        Lighting.Brightness = Lighting.Brightness * 0.85

        -- 🔻 Redução inteligente de partes distantes
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Anchored == false then
                if not storedParts[obj] then
                    storedParts[obj] = {
                        Material = obj.Material,
                        Reflectance = obj.Reflectance,
                        CastShadow = obj.CastShadow
                    }
                end

                obj.CastShadow = false
                obj.Reflectance = 0
                obj.Material = Enum.Material.Plastic
            end
        end

    else
        -- 🔄 Restaurar
        Lighting.FogStart = originalLighting.FogStart
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.Brightness = originalLighting.Brightness

        for obj, data in pairs(storedParts) do
            if obj and obj.Parent then
                obj.Material = data.Material
                obj.Reflectance = data.Reflectance
                obj.CastShadow = data.CastShadow
            end
        end
    end
end

-- ===== ATUALIZAÇÃO DINÂMICA POR DISTÂNCIA =====
RunService.Heartbeat:Connect(function()
    if not FPSBLOX.Graphics.Enabled then return end
    local cam = Workspace.CurrentCamera
    if not cam then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local dist = (cam.CFrame.Position - obj.Position).Magnitude
            obj.LocalTransparencyModifier = dist > FPSBLOX.Graphics.DistanceLimit and 0.75 or 0
        end
    end
end)

-- ===== CONTROLE =====
function FPSBLOX:SetGraphicsBoost(state, distance)
    FPSBLOX.Graphics.DistanceLimit = distance or FPSBLOX.Graphics.DistanceLimit
    optimizeWorld(state)
    print("[FPSBLOX] Graphics Boost:", state and "ATIVO" or "DESATIVADO")
end

print("[FPSBLOX] Parte 7 carregada: Gráficos inteligentes prontos.")

-- FIM DA PARTE 7

--[[
=====================================================
 FPSBLOX DEFINITIVO - PARTE 8
 MODO COMPETITIVO EXTREMO
=====================================================
]]

local FPSBLOX = _G.FPSBLOX
if not FPSBLOX then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

FPSBLOX.Competitive = {
    Enabled = false
}

-- ===== BACKUPS =====
local backup = {
    Lighting = {
        GlobalShadows = Lighting.GlobalShadows,
        Technology = Lighting.Technology,
        ExposureCompensation = Lighting.ExposureCompensation
    },
    Camera = {
        FieldOfView = Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView
    }
}

-- ===== FUNÇÃO PRINCIPAL =====
local function enableCompetitiveMode(state)
    FPSBLOX.Competitive.Enabled = state

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if state then
        -- 🔥 CAMERA MAIS RESPONSIVA
        if Workspace.CurrentCamera then
            Workspace.CurrentCamera.FieldOfView = 75
        end

        -- 🌑 ILUMINAÇÃO ULTRA LEVE
        Lighting.GlobalShadows = false
        Lighting.Technology = Enum.Technology.Compatibility
        Lighting.ExposureCompensation = -0.15

        -- 🧍‍♂️ ANIMAÇÕES REDUZIDAS (menos custo)
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end

        -- ⛔ DESABILITA EFEITOS PESADOS
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter")
            or v:IsA("Trail")
            or v:IsA("Explosion")
            or v:IsA("Fire")
            or v:IsA("Smoke") then
                v.Enabled = false
            end
        end

        -- ⚡ PRIORIDADE DE FRAME
        RunService:BindToRenderStep(
            "FPSBLOX_Competitive",
            Enum.RenderPriority.Camera.Value + 5,
            function() end
        )

    else
        -- 🔄 RESTAURA
        Lighting.GlobalShadows = backup.Lighting.GlobalShadows
        Lighting.Technology = backup.Lighting.Technology
        Lighting.ExposureCompensation = backup.Lighting.ExposureCompensation

        if Workspace.CurrentCamera and backup.Camera.FieldOfView then
            Workspace.CurrentCamera.FieldOfView = backup.Camera.FieldOfView
        end

        RunService:UnbindFromRenderStep("FPSBLOX_Competitive")
    end

    print("[FPSBLOX] Modo Competitivo:", state and "ATIVADO" or "DESATIVADO")
end

-- ===== CONTROLE =====
function FPSBLOX:SetCompetitiveMode(state)
    enableCompetitiveMode(state)
end

print("[FPSBLOX] Parte 8 carregada: Modo Competitivo Extremo pronto.")

-- FIM DA PARTE 8

--[[
=====================================================
 FPSBLOX DEFINITIVO - PARTE 9
 STREAMING INTELIGENTE DO MAPA
=====================================================
]]

local FPSBLOX = _G.FPSBLOX
if not FPSBLOX then return end

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Camera = Workspace.CurrentCamera

FPSBLOX.Streaming = {
    Enabled = false,
    MaxDistance = 180,
    UpdateRate = 0.5
}

local cachedObjects = {}
local lastUpdate = 0

-- ===== SALVAR ESTADO ORIGINAL =====
local function cacheObject(obj)
    if not cachedObjects[obj] then
        cachedObjects[obj] = {
            Transparency = obj.Transparency,
            CanCollide = obj.CanCollide,
            CastShadow = obj.CastShadow
        }
    end
end

-- ===== STREAMING BASEADO NA CÂMERA =====
local function streamingUpdate()
    if not FPSBLOX.Streaming.Enabled then return end
    if not Camera then return end

    local now = tick()
    if now - lastUpdate < FPSBLOX.Streaming.UpdateRate then return end
    lastUpdate = now

    local camPos = Camera.CFrame.Position

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            cacheObject(obj)

            local dist = (obj.Position - camPos).Magnitude

            if dist > FPSBLOX.Streaming.MaxDistance then
                -- fora da área importante
                obj.Transparency = math.clamp(obj.Transparency + 0.6, 0, 1)
                obj.CanCollide = false
                obj.CastShadow = false
            else
                -- dentro da área jogável
                local data = cachedObjects[obj]
                if data then
                    obj.Transparency = data.Transparency
                    obj.CanCollide = data.CanCollide
                    obj.CastShadow = data.CastShadow
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(streamingUpdate)

-- ===== CONTROLE =====
function FPSBLOX:SetStreamingMode(state, distance)
    FPSBLOX.Streaming.Enabled = state
    if distance then
        FPSBLOX.Streaming.MaxDistance = distance
    end
    print("[FPSBLOX] Streaming Inteligente:", state and "ATIVADO" or "DESATIVADO")
end

print("[FPSBLOX] Parte 9 carregada: Streaming inteligente pronto.")

-- FIM DA PARTE 9

--[[
=====================================================
 FPSBLOX DEFINITIVO - PARTE 10
 PERFIL AUTOMÁTICO + ESTABILIDADE FINAL
=====================================================
]]

local FPSBLOX = _G.FPSBLOX
if not FPSBLOX then return end

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

FPSBLOX.System = {
    Profile = "Unknown",
    AutoMode = true,
    StabilityLock = true
}

-- ===== DETECÇÃO INTELIGENTE DE DISPOSITIVO =====
local function detectDeviceProfile()
    local fps = 0
    local frames = 0
    local start = tick()

    local connection
    connection = RunService.RenderStepped:Connect(function()
        frames += 1
        if tick() - start >= 1.5 then
            fps = frames / (tick() - start)
            connection:Disconnect()
        end
    end)

    task.wait(1.6)

    if UserInputService.TouchEnabled and fps < 45 then
        return "MobileLow"
    elseif UserInputService.TouchEnabled and fps < 70 then
        return "MobileMid"
    elseif fps >= 100 then
        return "HighEnd"
    else
        return "Balanced"
    end
end

-- ===== APLICADOR DE PERFIL =====
local function applyProfile(profile)
    FPSBLOX.System.Profile = profile

    if profile == "MobileLow" then
        FPSBLOX:SetGraphicsBoost(true, 90)
        FPSBLOX:SetStreamingMode(true, 140)
        FPSBLOX:SetCompetitiveMode(true)
        FPSBLOX:SetAdaptiveFrame(true)

    elseif profile == "MobileMid" then
        FPSBLOX:SetGraphicsBoost(true, 130)
        FPSBLOX:SetStreamingMode(true, 180)
        FPSBLOX:SetCompetitiveMode(true)
        FPSBLOX:SetAdaptiveFrame(true)

    elseif profile == "HighEnd" then
        FPSBLOX:SetGraphicsBoost(false)
        FPSBLOX:SetStreamingMode(false)
        FPSBLOX:SetCompetitiveMode(false)
        FPSBLOX:SetAdaptiveFrame(true)

    else -- Balanced
        FPSBLOX:SetGraphicsBoost(true, 160)
        FPSBLOX:SetStreamingMode(true, 200)
        FPSBLOX:SetCompetitiveMode(true)
        FPSBLOX:SetAdaptiveFrame(true)
    end

    print("[FPSBLOX] Perfil aplicado:", profile)
end

-- ===== ESTABILIZADOR DE FPS (ANTI-QUEDA BRUSCA) =====
local lastFPS = 60
local dropBuffer = 0

RunService.Heartbeat:Connect(function()
    if not FPSBLOX.System.StabilityLock then return end

    local currentFPS = workspace:GetRealPhysicsFPS()
    if currentFPS < lastFPS - 15 then
        dropBuffer += 1
    else
        dropBuffer = math.max(dropBuffer - 1, 0)
    end

    if dropBuffer >= 3 then
        FPSBLOX:SetGraphicsBoost(true, 110)
        FPSBLOX:SetStreamingMode(true, 150)
        dropBuffer = 0
        print("[FPSBLOX] Estabilidade ativada (queda detectada)")
    end

    lastFPS = currentFPS
end)

-- ===== INICIALIZAÇÃO FINAL =====
task.spawn(function()
    task.wait(1)
    if FPSBLOX.System.AutoMode then
        local profile = detectDeviceProfile()
        applyProfile(profile)
    end
end)

-- ===== CONTROLES =====
function FPSBLOX:SetAutoProfile(state)
    FPSBLOX.System.AutoMode = state
end

function FPSBLOX:SetStabilityLock(state)
    FPSBLOX.System.StabilityLock = state
end

print("[FPSBLOX] Parte 10 carregada: Sistema profissional ativo.")

-- ===== FIM DA PARTE 10 =====
-- FPSBLOX DEFINITIVO FINALIZADO
