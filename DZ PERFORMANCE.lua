--[[
    DZ OPTIMIZER - PARTE 0: ENGINE & UI
    Criador: DAVIZZIN
    Foco: Performance, Leveza e Responsividade
]]

local Core = {
    Enabled = true,
    Settings = {},
    Modules = {}
}

-- Serviços principais
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- UI Base
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DZ_Optimizer"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = gethui and gethui() or LocalPlayer:WaitForChild("PlayerGui")

-- Função Auxiliar: Arrastar UI (Mobile/PC)
local function MakeDraggable(frame, parent)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = parent.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- 1. INTRO ANIMADA
local function PlayIntro()
    local IntroFrame = Instance.new("Frame")
    IntroFrame.Size = UDim2.new(1, 0, 1, 0)
    IntroFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    IntroFrame.BackgroundTransparency = 0
    IntroFrame.ZIndex = 10
    IntroFrame.Parent = ScreenGui

    local IntroText = Instance.new("TextLabel")
    IntroText.Size = UDim2.new(1, 0, 0, 50)
    IntroText.Position = UDim2.new(0, 0, 0.5, -25)
    IntroText.BackgroundTransparency = 1
    IntroText.Text = "by DAVIZZIN"
    IntroText.TextColor3 = Color3.fromRGB(255, 255, 255)
    IntroText.TextSize = 30
    IntroText.Font = Enum.Font.GothamBold
    IntroText.TextTransparency = 1
    IntroText.Parent = IntroFrame

    -- Animação de Surgimento
    TweenService:Create(IntroText, TweenInfo.new(1), {TextTransparency = 0}):Play()
    task.wait(1.5)
    TweenService:Create(IntroText, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
    TweenService:Create(IntroFrame, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
    task.wait(1)
    IntroFrame:Destroy()
end

-- 2. CRIAÇÃO DA UI PRINCIPAL (MINIMALISTA)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Barra de Título
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)
MakeDraggable(TitleBar, MainFrame)

local TitleText = Instance.new("TextLabel")
TitleText.Text = "DZ OPTIMIZER"
TitleText.Size = UDim2.new(1, -70, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.BackgroundTransparency = 1
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

-- Botão Minimizar (DZ)
local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0, 30, 0, 30)
MinButton.Position = UDim2.new(1, -65, 0.5, -15)
MinButton.Text = "-"
MinButton.Parent = TitleBar

-- Botão de Minimizado (O Quadradinho DZ)
local DZIcon = Instance.new("TextButton")
DZIcon.Name = "DZ_Icon"
DZIcon.Size = UDim2.new(0, 50, 0, 50)
DZIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
DZIcon.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
DZIcon.Text = "DZ"
DZIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
DZIcon.Font = Enum.Font.GothamBold
DZIcon.Visible = false
DZIcon.Parent = ScreenGui
Instance.new("UICorner", DZIcon).CornerRadius = UDim.new(0, 10)
MakeDraggable(DZIcon, DZIcon)

-- Lógica de Alternar UI
MinButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    DZIcon.Visible = true
end)

DZIcon.MouseButton1Click:Connect(function()
    DZIcon.Visible = false
    MainFrame.Visible = true
end)

-- Container de Funções (Scrolling)
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -45)
Container.Position = UDim2.new(0, 10, 0, 40)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 2, 0)
Container.ScrollBarThickness = 2
Container.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 5)
UIList.Parent = Container

-- Iniciar Script
task.spawn(PlayIntro)
task.wait(2)
MainFrame.Visible = true

print("DZ Optimizer: Parte 0 Carregada com Sucesso.")

--[[ 
    DZ OPTIMIZER - PARTE 1: GRAPHICS ENGINE
    Foco: Otimização de Renderização e Switches de UI
]]

-- Referências da Parte 0 (Assumindo que estão no mesmo ambiente)
local Lighting = game:GetService("Lighting")
local Terrain = workspace:WaitForChild("Terrain")

-- Tabela de Configurações para Reversão (Backup de Valores Originais)
local OriginalSettings = {
    Shadows = Lighting.GlobalShadows,
    Brightness = Lighting.Brightness,
    EnvironmentDiffuse = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecular = Lighting.EnvironmentSpecularScale,
    Decoration = Terrain.Decoration,
    Technology = settings().Rendering.QualityLevel
}

-- FUNÇÃO: Criador de Botões Estilizados (Switches)
local function CreateToggle(name, parent, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleFrame.Parent = parent
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Text = name
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 45, 0, 20)
    Button.Position = UDim2.new(1, -55, 0.5, -10)
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = ""
    Button.Parent = ToggleFrame
    local bCorner = Instance.new("UICorner", Button)
    bCorner.CornerRadius = UDim.new(1, 0)

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 16, 0, 16)
    Indicator.Position = UDim2.new(0, 2, 0.5, -8)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.Parent = Button
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local state = false
    Button.MouseButton1Click:Connect(function()
        state = not state
        local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local targetCol = state and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(50, 50, 50)
        
        TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = targetCol}):Play()
        
        callback(state)
    end)
end

-- ENGINE DE OTIMIZAÇÃO (O "CÉREBRO" DOS GRÁFICOS)
local GraphicsEngine = {}

function GraphicsEngine.ApplyCasual()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    Terrain.Decoration = false
end

function GraphicsEngine.ApplyCompetitive()
    GraphicsEngine.ApplyCasual()
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostProcessEffect") then
            effect.Enabled = false
        end
    end
    -- Reduz o delay visual limpando a atmosfera
    Lighting.Brightness = 2
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
end

function GraphicsEngine.ApplyPotato()
    GraphicsEngine.ApplyCompetitive()
    -- Otimização Extrema de Texturas (Substituição Inteligente)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("MeshPart") then
            obj.Material = Enum.Material.SmoothPlastic
        elseif obj:IsA("Texture") or obj:IsA("Decal") then
            obj.Transparency = 1 -- Oculta texturas sem deletar para evitar bugs
        end
    end
end

-- ADICIONANDO À UI (Container criado na Parte 0)
CreateToggle("Modo Casual (Boost FPS)", Container, function(state)
    if state then GraphicsEngine.ApplyCasual() else 
        Lighting.GlobalShadows = OriginalSettings.Shadows
    end
end)

CreateToggle("Modo Competitivo (PvP)", Container, function(state)
    if state then GraphicsEngine.ApplyCompetitive() end
end)

CreateToggle("Modo Batata (Extremo)", Container, function(state)
    if state then GraphicsEngine.ApplyPotato() end
end)

--[[ 
    DZ OPTIMIZER - PARTE 2: SMART ENGINE & VFX
    Foco: Monitoramento de FPS e Redução Dinâmica de Efeitos
]]

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

-- Variáveis de Controle
local SmartEngineEnabled = false
local AdaptiveVFXEnabled = false
local LastFPS = 60

-- Tabela de Cache para VFX (Evita re-processar o que já foi otimizado)
local VFX_Cache = {}

-- 1. SISTEMA DE CONTROLE DE VFX (INTELIGENTE)
local function OptimizeVFX(vfx, factor)
    if not vfx:IsA("ParticleEmitter") and not vfx:IsA("Trail") and not vfx:IsA("Beam") then return end
    
    -- Salva valores originais se não existirem no cache
    if not VFX_Cache[vfx] then
        VFX_Cache[vfx] = {
            Rate = vfx:IsA("ParticleEmitter") and vfx.Rate or nil,
            Lifetime = vfx:IsA("ParticleEmitter") and vfx.Lifetime or nil,
            Enabled = vfx.Enabled
        }
    end

    -- Redução proporcional em vez de desligar tudo
    if vfx:IsA("ParticleEmitter") then
        vfx.Rate = VFX_Cache[vfx].Rate * factor
        -- Se o fator for muito baixo (FPS crítico), reduz o tempo de vida da partícula
        if factor < 0.5 then
            vfx.Lifetime = NumberRange.new(VFX_Cache[vfx].Lifetime.Min * factor, VFX_Cache[vfx].Lifetime.Max * factor)
        end
    elseif vfx:IsA("Trail") or vfx:IsA("Beam") then
        vfx.Enabled = factor > 0.3 -- Só desliga trilhas se o FPS estiver deplorável
    end
end

-- 2. SMART ENGINE (O CÉREBRO)
task.spawn(function()
    while task.wait(0.5) do -- Checagem a cada meio segundo para não pesar
        if not SmartEngineEnabled and not AdaptiveVFXEnabled then continue end
        
        -- Cálculo Real de FPS
        local currentFPS = math.floor(1 / RunService.RenderStepped:Wait())
        LastFPS = currentFPS
        
        -- Lógica de Adaptação
        if AdaptiveVFXEnabled then
            local reductionFactor = 1.0
            
            if currentFPS < 30 then
                reductionFactor = 0.2 -- Redução agressiva (80% menos efeitos)
            elseif currentFPS < 50 then
                reductionFactor = 0.6 -- Redução moderada (40% menos)
            end
            
            -- Varredura inteligente (apenas nas proximidades do player para performance)
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                for _, obj in pairs(workspace:GetDescendants()) do
                    -- Otimiza apenas efeitos (evita mexer em partes do mapa)
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                        OptimizeVFX(obj, reductionFactor)
                    end
                end
            end
        end
        
        -- Smart Engine: Garbage Collection Manual (Limpeza de memória)
        if SmartEngineEnabled and currentFPS < 25 then
            collectgarbage("step", 100) -- Força uma limpeza leve de RAM
        end
    end
end)

-- 3. INTEGRAÇÃO COM A UI (Adicionando ao Container da Parte 0)

CreateToggle("Smart Engine (Anti-Stutter)", Container, function(state)
    SmartEngineEnabled = state
    if state then
        -- Boost inicial: Reduz Delay de Renderização
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end
end)

CreateToggle("VFX Adaptativo (Dynamic)", Container, function(state)
    AdaptiveVFXEnabled = state
    -- Se desligar, restaura os efeitos originais
    if not state then
        for vfx, original in pairs(VFX_Cache) do
            if vfx and vfx.Parent then
                if vfx:IsA("ParticleEmitter") then
                    vfx.Rate = original.Rate
                    vfx.Lifetime = original.Lifetime
                end
                vfx.Enabled = original.Enabled
            end
        end
        VFX_Cache = {} -- Limpa cache
    end
end)

-- 4. FPS COUNTER (Requisito da UI)
local FPSLabel = Instance.new("TextLabel")
FPSLabel.Name = "FPSCounter"
FPSLabel.Size = UDim2.new(0, 100, 0, 20)
FPSLabel.Position = UDim2.new(0, 10, 1, -30) -- Canto inferior esquerdo
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
FPSLabel.TextSize = 14
FPSLabel.Font = Enum.Font.Code
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.Parent = ScreenGui

RunService.RenderStepped:Connect(function(dt)
    local fps = math.floor(1/dt)
    FPSLabel.Text = "FPS: " .. fps
    
    -- Muda cor baseado no estado
    if fps > 50 then
        FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 127) -- Verde
    elseif fps > 30 then
        FPSLabel.TextColor3 = Color3.fromRGB(255, 200, 0) -- Amarelo
    else
        FPSLabel.TextColor3 = Color3.fromRGB(255, 80, 80) -- Vermelho
    end
end)
