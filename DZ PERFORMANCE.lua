--[[
    DZ OPTIMIZER - FULL VERSION (V1.0)
    Integrado: Core, Graphics, Smart VFX, Game Turbo & Anti-Stutter
    Criador: DAVIZZIN
]]

-- ==========================================
-- 1. CONFIGURAÇÕES E SERVIÇOS
-- ==========================================
local Lighting = game:GetService("Lighting")
local Terrain = workspace:WaitForChild("Terrain")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local OriginalSettings = {
    Shadows = Lighting.GlobalShadows,
    Brightness = Lighting.Brightness,
    Decoration = Terrain.Decoration
}

local VFX_Cache = {}
local SmartEngineEnabled = false
local AdaptiveVFXEnabled = false

-- ==========================================
-- 2. CORE ENGINE (FUNÇÕES DE UI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DZ_Optimizer"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = gethui and gethui() or LocalPlayer:WaitForChild("PlayerGui")

local function MakeDraggable(frame, parent)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = parent.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- Criador de Switch (Alavanca)
local function CreateToggle(name, parent, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleFrame.Parent = parent
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Text = name; Label.Size = UDim2.new(1, -60, 1, 0); Label.Position = UDim2.new(0, 10, 0, 0)
    Label.TextColor3 = Color3.fromRGB(200, 200, 200); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.Gotham; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = ToggleFrame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 40, 0, 20); Button.Position = UDim2.new(1, -50, 0.5, -10); Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Button.Text = ""; Button.Parent = ToggleFrame
    Instance.new("UICorner", Button).CornerRadius = UDim.new(1, 0)

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 16, 0, 16); Indicator.Position = UDim2.new(0, 2, 0.5, -8); Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Indicator.Parent = Button
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local state = false
    Button.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(50, 50, 50)}):Play()
        callback(state)
    end)
end

-- ==========================================
-- 3. OTIMIZAÇÕES (A LÓGICA)
-- ==========================================
local function OptimizeVFX(vfx, factor)
    if not VFX_Cache[vfx] then
        VFX_Cache[vfx] = {Rate = vfx:IsA("ParticleEmitter") and vfx.Rate or 1, Enabled = vfx.Enabled}
    end
    if vfx:IsA("ParticleEmitter") then
        vfx.Rate = VFX_Cache[vfx].Rate * factor
    else
        vfx.Enabled = factor > 0.3
    end
end

-- ==========================================
-- 4. CONSTRUÇÃO DA UI
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35); TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar)
MakeDraggable(TitleBar, MainFrame)

local TitleText = Instance.new("TextLabel")
TitleText.Text = " DZ OPTIMIZER"; TitleText.Size = UDim2.new(1, 0, 1, 0); TitleText.TextColor3 = Color3.fromRGB(255, 255, 255); TitleText.Font = Enum.Font.GothamBold; TitleText.BackgroundTransparency = 1; TitleText.TextXAlignment = Enum.TextXAlignment.Left; TitleText.Parent = TitleBar

local DZIcon = Instance.new("TextButton")
DZIcon.Size = UDim2.new(0, 50, 0, 50); DZIcon.Position = UDim2.new(0, 10, 0, 10); DZIcon.BackgroundColor3 = Color3.fromRGB(0, 0, 0); DZIcon.Text = "DZ"; DZIcon.TextColor3 = Color3.fromRGB(255,255,255); DZIcon.Visible = false; DZIcon.Parent = ScreenGui
Instance.new("UICorner", DZIcon)
MakeDraggable(DZIcon, DZIcon)

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -50); Container.Position = UDim2.new(0, 10, 0, 45); Container.BackgroundTransparency = 1; Container.ScrollBarThickness = 2; Container.Parent = MainFrame
Instance.new("UIListLayout", Container).Padding = UDim.new(0, 5)

-- ==========================================
-- 5. REGISTRO DOS BOTÕES (PARTES 1, 2 E 3)
-- ==========================================

CreateToggle("Modo Casual", Container, function(s)
    Lighting.GlobalShadows = not s
    Terrain.Decoration = not s
end)

CreateToggle("Modo Batata (Extremo)", Container, function(s)
    if s then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic
            elseif obj:IsA("Texture") or obj:IsA("Decal") then obj.Transparency = 1 end
        end
    end
end)

CreateToggle("VFX Adaptativo", Container, function(s) AdaptiveVFXEnabled = s end)

CreateToggle("Game Turbo", Container, function(s)
    if s then settings().Physics.AllowSleep = true end
end)

CreateToggle("Otimizar Players", Container, function(s)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, acc in pairs(p.Character:GetChildren()) do
                if acc:IsA("Accessory") then acc.Handle.Transparency = s and 1 or 0 end
            end
        end
    end
end)

-- ==========================================
-- 6. LOOPS DE SISTEMA (FPS & SMART)
-- ==========================================
local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0, 100, 0, 20); FPSLabel.Position = UDim2.new(0, 10, 1, -25); FPSLabel.BackgroundTransparency = 1; FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 0); FPSLabel.Parent = ScreenGui

RunService.RenderStepped:Connect(function(dt)
    local fps = math.floor(1/dt)
    FPSLabel.Text = "FPS: " .. fps
    if AdaptiveVFXEnabled and fps < 40 then
        for _, v in pairs(workspace:GetDescendants()) do 
            if v:IsA("ParticleEmitter") then OptimizeVFX(v, 0.5) end 
        end
    end
end)

-- Botões de fechar/minimizar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 2.5); CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; DZIcon.Visible = true end)
DZIcon.MouseButton1Click:Connect(function() MainFrame.Visible = true; DZIcon.Visible = false end)

-- ==========================================
-- 7. EXECUÇÃO FINAL
-- ==========================================
local function Intro()
    local f = Instance.new("Frame", ScreenGui)
    f.Size = UDim2.new(1,0,1,0); f.BackgroundColor3 = Color3.new(0,0,0)
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1,0,1,0); t.Text = "by DAVIZZIN"; t.TextColor3 = Color3.new(1,1,1); t.BackgroundTransparency = 1
    task.wait(2)
    f:Destroy()
    MainFrame.Visible = true
end

task.spawn(Intro)
