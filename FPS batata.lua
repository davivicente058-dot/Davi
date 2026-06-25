--[[
    ═══════════════════════════════════════════════════════════════
    ║                      DZ FPS ONE                             ║
    ║        Otimizador Universal de Alta Performance             ║
    ║                Desenvolvido por DAVIZZIN                    ║
    ═══════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Gerenciamento de Estado Global
local ScriptEnabled = false
local OriginalProperties = {}
local DescendantConnection = nil

-- Criar a interface base protegida contra ResetOnSpawn
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DZ_FPS_ONE"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- ═══════════════════════════════════════════════════════════════
-- FUNÇÕES AUXILIARES DE ARRRASTAR (MOBILE & PC)
-- ═══════════════════════════════════════════════════════════════
local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- CONTADOR DE FPS REAL
-- ═══════════════════════════════════════════════════════════════
local FpsLabel = Instance.new("TextLabel")
FpsLabel.Name = "FPS_Counter"
FpsLabel.Size = UDim2.new(0, 100, 0, 25)
FpsLabel.Position = UDim2.new(0.5, -50, 0, 10)
FpsLabel.BackgroundTransparency = 1
FpsLabel.Font = Enum.Font.GothamBold
FpsLabel.TextSize = 16
FpsLabel.TextStrokeTransparency = 0.5
FpsLabel.Text = "FPS: --"
FpsLabel.TextColor3 = Color3.fromRGB(0, 230, 118)
FpsLabel.Parent = ScreenGui

local lastUpdate = os.clock()
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = os.clock()
    if now - lastUpdate >= 0.5 then
        local fps = math.floor(frameCount / (now - lastUpdate))
        FpsLabel.Text = "FPS: " .. fps
        if fps >= 50 then
            FpsLabel.TextColor3 = Color3.fromRGB(0, 230, 118) -- Verde (Alto)
        elseif fps >= 30 then
            FpsLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Amarelo (Médio)
        else
            FpsLabel.TextColor3 = Color3.fromRGB(255, 45, 85) -- Vermelho (Baixo)
        end
        frameCount = 0
        lastUpdate = now
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- INTERFACE GRÁFICA PRINCIPAL (UI)
-- ═══════════════════════════════════════════════════════════════

-- Painel Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 170)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -85)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(45, 45, 45)
MainStroke.Parent = MainFrame

-- Barra de Título / Handle de Arrasto
local TitleBar = Instance.new("TextLabel")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundTransparency = 1
TitleBar.Font = Enum.Font.GothamBold
TitleBar.Text = "DZ FPS ONE"
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.TextSize = 14
TitleBar.Active = true
TitleBar.Parent = MainFrame
MakeDraggable(MainFrame, TitleBar)

-- Botão Minimizar
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -65, 0, 2)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = MainFrame

-- Botão Fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 75, 75)
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame

-- Botão de Ativação Único (ON/OFF)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 210, 0, 50)
ToggleBtn.Position = UDim2.new(0.5, -105, 0.5, -10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "OTIMIZAÇÃO: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ToggleBtn.TextSize = 14
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 1
ToggleStroke.Color = Color3.fromRGB(60, 60, 60)
ToggleStroke.Parent = ToggleBtn

-- Subtitle Credits
local CreditsLabel = Instance.new("TextLabel")
CreditsLabel.Size = UDim2.new(1, 0, 0, 20)
CreditsLabel.Position = UDim2.new(0, 0, 1, -25)
CreditsLabel.BackgroundTransparency = 1
CreditsLabel.Font = Enum.Font.Gotham
CreditsLabel.Text = "Focado em Desempenho Real"
CreditsLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
CreditsLabel.TextSize = 10
CreditsLabel.Parent = MainFrame

-- Ícone Minimizado (Quadrado Compacto)
local MiniFrame = Instance.new("TextButton")
MiniFrame.Name = "MiniFrame"
MiniFrame.Size = UDim2.new(0, 45, 0, 45)
MiniFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MiniFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MiniFrame.Font = Enum.Font.GothamBold
MiniFrame.Text = "DZ"
MiniFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniFrame.TextSize = 14
MiniFrame.BorderSizePixel = 0
MiniFrame.Visible = false
MiniFrame.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 10)
MiniCorner.Parent = MiniFrame

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Thickness = 1.5
MiniStroke.Color = Color3.fromRGB(0, 200, 255)
MiniStroke.Parent = MiniFrame
MakeDraggable(MiniFrame, MiniFrame)

-- ═══════════════════════════════════════════════════════════════
-- NÚCLEO DE ENGINE DE OTIMIZAÇÃO (FPS BOOST)
-- ═══════════════════════════════════════════════════════════════

local function SafeCacheAndSet(object, prop, newValue)
    if not OriginalProperties[object] then
        OriginalProperties[object] = {}
    end
    if OriginalProperties[object][prop] == nil then
        local success, currentVal = pcall(function() return object[prop] end)
        if success then
            OriginalProperties[object][prop] = currentVal
        end
    end
    pcall(function() object[prop] = newValue end)
end

local function OptimizeObject(obj)
    -- Otimização Inteligente de Texturas/Decals sem clarear tudo
    if obj:IsA("Decal") or obj:IsA("Texture") then
        SafeCacheAndSet(obj, "Transparency", 0.6)
    
    -- Redução Estratégica de Partículas e Efeitos Visuais
    elseif obj:IsA("ParticleEmitter") then
        if not OriginalProperties[obj] or not OriginalProperties[obj]["Rate"] then
            SafeCacheAndSet(obj, "Rate", obj.Rate * 0.25)
        end
    elseif obj:IsA("Smoke") then
        SafeCacheAndSet(obj, "Size", obj.Size * 0.3)
    elseif obj:IsA("Fire") then
        SafeCacheAndSet(obj, "Size", obj.Size * 0.3)
    elseif obj:IsA("Beam") or obj:IsA("Trail") then
        SafeCacheAndSet(obj, "Transparency", 0.7)
    
    -- Remoção Completa de Pós-Processamento Pesado
    elseif obj:IsA("PostEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then
        SafeCacheAndSet(obj, "Enabled", false)
        
    -- Sombras de Luzes Dinâmicas
    elseif obj:IsA("Light") then
        SafeCacheAndSet(obj, "Shadows", false)
        
    -- Otimização Geométrica e de Materiais Pesados
    elseif obj:IsA("MeshPart") then
        SafeCacheAndSet(obj, "RenderFidelity", Enum.RenderFidelity.Performance)
    elseif obj:IsA("BasePart") and not obj:IsA("MeshPart") then
        if obj.Material == Enum.Material.Grass or obj.Material == Enum.Material.CorrodedMetal or obj.Material == Enum.Material.DiamondPlate then
            SafeCacheAndSet(obj, "Material", Enum.Material.Plastic)
        end
    end
end

local function ApplyOptimization()
    -- Iluminação Global
    SafeCacheAndSet(Lighting, "GlobalShadows", false)
    
    -- Varredura Inicial de Todo o Mapa
    for _, descendant in pairs(workspace:GetDescendants()) do
        OptimizeObject(descendant)
    end
    for _, asset in pairs(Lighting:GetDescendants()) do
        OptimizeObject(asset)
    end
    
    -- Detecção Automática e Dinâmica em tempo real
    DescendantConnection = workspace.DescendantAdded:Connect(function(descendant)
        task.wait(0.1) -- Delay seguro contra stuttering de instanciação
        if ScriptEnabled then
            OptimizeObject(descendant)
        end
    end)
end

local function RevertOptimization()
    if DescendantConnection then
        DescendantConnection:Disconnect()
        DescendantConnection = nil
    end
    
    -- Restaura exatamente as propriedades padrão guardadas em cache
    for object, props in pairs(OriginalProperties) do
        if object and object.Parent then
            for prop, val in pairs(props) do
                pcall(function() object[prop] = val end)
            end
        end
    end
    table.clear(OriginalProperties)
end

-- ═══════════════════════════════════════════════════════════════
-- COMPORTAMENTO DOS BOTÕES E INTERATIVIDADE
-- ═══════════════════════════════════════════════════════════════

ToggleBtn.MouseButton1Click:Connect(function()
    ScriptEnabled = not ScriptEnabled
    if ScriptEnabled then
        -- Estado Ativado (ON)
        TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 180, 100)}):Play()
        TweenService:Create(ToggleStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(0, 230, 118)}):Play()
        ToggleBtn.Text = "OTIMIZAÇÃO: ON"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        task.spawn(ApplyOptimization)
    else
        -- Estado Desativado (OFF)
        TweenService:Create(ToggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        TweenService:Create(ToggleStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(60, 60, 60)}):Play()
        ToggleBtn.Text = "OTIMIZAÇÃO: OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        task.spawn(RevertOptimization)
    end
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniFrame.Visible = true
end)

MiniFrame.MouseButton1Click:Connect(function()
    MiniFrame.Visible = false
    MainFrame.Visible = true
end)

CloseBtn.MouseButton1Click:Connect(function()
    RevertOptimization()
    ScreenGui:Destroy()
end)

-- ═══════════════════════════════════════════════════════════════
-- INTRO ELEGANTE E INICIALIZAÇÃO
-- ═══════════════════════════════════════════════════════════════
local IntroLabel = Instance.new("TextLabel")
IntroLabel.Size = UDim2.new(1, 0, 1, 0)
IntroLabel.BackgroundTransparency = 1
IntroLabel.Font = Enum.Font.GothamBold
IntroLabel.Text = "by DAVIZZIN"
IntroLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroLabel.TextSize = 28
IntroLabel.TextTransparency = 1
IntroLabel.Parent = ScreenGui

-- Animação Suave da Intro (Fade In -> Hold -> Fade Out)
task.spawn(function()
    TweenService:Create(IntroLabel, TweenInfo.new(1), {TextTransparency = 0}):Play()
    task.wait(1.5)
    TweenService:Create(IntroLabel, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
    task.wait(0.8)
    IntroLabel:Destroy()
    MainFrame.Visible = true
end)
