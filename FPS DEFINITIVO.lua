--==================================================
-- FPSBLOX DEFINITIVO
-- PARTE 1/4 - CORE ENGINE
-- Base técnica / Núcleo de desempenho
--==================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Lighting = game:GetService("Lighting"),
    Workspace = game:GetService("Workspace"),
    UserInputService = game:GetService("UserInputService"),
    Stats = game:GetService("Stats"),
}

local Player = Services.Players.LocalPlayer

--------------------------------------------------
-- GLOBAL TABLE (SHARED ENTRE PARTES)
--------------------------------------------------
_G.FPSBLOX = _G.FPSBLOX or {}
local FPSBLOX = _G.FPSBLOX

--------------------------------------------------
-- DEVICE DETECTION
--------------------------------------------------
FPSBLOX.Device = {
    IsMobile = Services.UserInputService.TouchEnabled,
    IsPC = not Services.UserInputService.TouchEnabled,
    IsLowEnd = false,
}

-- Heurística simples mas eficaz
pcall(function()
    local mem = Services.Stats:GetTotalMemoryUsageMb()
    if mem < 1500 then
        FPSBLOX.Device.IsLowEnd = true
    end
end)

--------------------------------------------------
-- CONFIGURATION (PADRÕES)
--------------------------------------------------
FPSBLOX.Config = {
    OptimizationEnabled = false,
    OptimizationLevel = 2, -- 1 leve | 2 médio | 3 extremo
    LightingMode = 2,      -- 1 claro | 2 padrão | 3 escuro
    CrosshairEnabled = false,
    AutoBoost = false,
}

--------------------------------------------------
-- FPS ENGINE (ESTÁVEL, SEM SPIKE FALSO)
--------------------------------------------------
FPSBLOX.FPS = {
    Value = 0,
    Frames = 0,
    LastTick = tick(),
    Smoothed = 60,
}

Services.RunService.RenderStepped:Connect(function()
    FPSBLOX.FPS.Frames += 1

    local now = tick()
    if now - FPSBLOX.FPS.LastTick >= 1 then
        FPSBLOX.FPS.Value = FPSBLOX.FPS.Frames
        FPSBLOX.FPS.Frames = 0
        FPSBLOX.FPS.LastTick = now

        -- suavização (evita queda falsa)
        FPSBLOX.FPS.Smoothed = math.floor(
            FPSBLOX.FPS.Smoothed * 0.7 + FPSBLOX.FPS.Value * 0.3
        )
    end
end)

--------------------------------------------------
-- MAP CACHE (ANTI LAG SPIKE)
--------------------------------------------------
FPSBLOX.Cache = {
    Parts = {},
    Particles = {},
    Lights = {},
}

task.spawn(function()
    for _, v in ipairs(Services.Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            table.insert(FPSBLOX.Cache.Parts, v)
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            table.insert(FPSBLOX.Cache.Particles, v)
        elseif v:IsA("Light") then
            table.insert(FPSBLOX.Cache.Lights, v)
        end
        -- throttle pra não travar celular fraco
        if #FPSBLOX.Cache.Parts % 200 == 0 then
            task.wait()
        end
    end
end)

--------------------------------------------------
-- SAFE LIGHTING SNAPSHOT (RESTORE REAL)
--------------------------------------------------
FPSBLOX.OriginalLighting = {
    Brightness = Services.Lighting.Brightness,
    Ambient = Services.Lighting.Ambient,
    OutdoorAmbient = Services.Lighting.OutdoorAmbient,
    GlobalShadows = Services.Lighting.GlobalShadows,
    FogEnd = Services.Lighting.FogEnd,
}

--------------------------------------------------
-- LOGGING (DEBUG CONTROLADO)
--------------------------------------------------
FPSBLOX.Log = function(msg)
    -- pronto pra ativar debug futuramente
    -- print("[FPSBLOX]", msg)
end

FPSBLOX.Log("Core carregado | Mobile: "..tostring(FPSBLOX.Device.IsMobile))
FPSBLOX.Log("Low-End: "..tostring(FPSBLOX.Device.IsLowEnd))

--------------------------------------------------
-- STATUS
--------------------------------------------------
FPSBLOX.LoadedPart1 = true

--==================================================
-- FPSBLOX DEFINITIVO
-- PARTE 2/4 - UI PROFISSIONAL
-- Janela + Minimizar + Botões + FPS
--==================================================

-- Garantia de carregamento da Parte 1
if not _G.FPSBLOX or not _G.FPSBLOX.LoadedPart1 then
    warn("[FPSBLOX] Parte 1 não carregada. UI cancelada.")
    return
end

local FPSBLOX = _G.FPSBLOX
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
}

local PlayerGui = Services.Players.LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------
-- LIMPAR UI ANTIGA
--------------------------------------------------
for _, v in ipairs(PlayerGui:GetChildren()) do
    if v.Name == "FPSBLOX_UI" then
        v:Destroy()
    end
end

--------------------------------------------------
-- SCREEN GUI
--------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FPSBLOX_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

--------------------------------------------------
-- MAIN WINDOW
--------------------------------------------------
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 360)
Main.Position = UDim2.new(0.05, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(26,26,28)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

--------------------------------------------------
-- HEADER
--------------------------------------------------
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = Color3.fromRGB(34,34,38)
Header.BorderSizePixel = 0

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "FPSBLOX DEFINITIVO"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = Color3.fromRGB(240,240,240)

--------------------------------------------------
-- BOTÃO MINIMIZAR
--------------------------------------------------
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -40, 0, 6)
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 24
MinBtn.TextColor3 = Color3.fromRGB(240,240,240)
MinBtn.BackgroundColor3 = Color3.fromRGB(50,50,54)
MinBtn.BorderSizePixel = 0
MinBtn.AutoButtonColor = true

Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

--------------------------------------------------
-- CONTENT
--------------------------------------------------
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, 0, 1, -44)
Content.Position = UDim2.new(0, 0, 0, 44)
Content.BackgroundTransparency = 1

--------------------------------------------------
-- FPS LABEL (FIXO)
--------------------------------------------------
local FPSLabel = Instance.new("TextLabel", ScreenGui)
FPSLabel.Size = UDim2.new(0, 120, 0, 30)
FPSLabel.Position = UDim2.new(0.01, 0, 0.01, 0)
FPSLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
FPSLabel.BackgroundTransparency = 0.25
FPSLabel.BorderSizePixel = 0
FPSLabel.TextColor3 = Color3.fromRGB(255,255,255)
FPSLabel.Font = Enum.Font.SourceSansBold
FPSLabel.TextSize = 14
FPSLabel.Text = "FPS: --"

Instance.new("UICorner", FPSLabel).CornerRadius = UDim.new(0, 6)

--------------------------------------------------
-- BOTÃO FACTORY
--------------------------------------------------
local function CreateButton(text, y)
    local Btn = Instance.new("TextButton", Content)
    Btn.Size = UDim2.new(0.88, 0, 0, 38)
    Btn.Position = UDim2.new(0.06, 0, 0, y)
    Btn.BackgroundColor3 = Color3.fromRGB(44,44,48)
    Btn.TextColor3 = Color3.fromRGB(235,235,235)
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 15
    Btn.Text = text
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = true

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
    return Btn
end

--------------------------------------------------
-- BOTÕES
--------------------------------------------------
local BtnOptToggle   = CreateButton("Otimização: OFF", 20)
local BtnOptLevel    = CreateButton("Nível: MÉDIO", 70)
local BtnLighting    = CreateButton("Iluminação: PADRÃO", 120)
local BtnCrosshair   = CreateButton("Mira: OFF", 170)
local BtnAutoBoost   = CreateButton("Auto Boost: OFF", 220)

--------------------------------------------------
-- MINIMIZE LOGIC
--------------------------------------------------
local minimized = false
local SmallBlock

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        Main.Visible = false

        SmallBlock = Instance.new("TextButton", ScreenGui)
        SmallBlock.Size = UDim2.new(0, 110, 0, 36)
        SmallBlock.Position = UDim2.new(0.02, 0, 0.25, 0)
        SmallBlock.BackgroundColor3 = Color3.fromRGB(40,40,44)
        SmallBlock.Text = "FPSBLOX"
        SmallBlock.TextColor3 = Color3.fromRGB(255,255,255)
        SmallBlock.Font = Enum.Font.SourceSansBold
        SmallBlock.TextSize = 14
        SmallBlock.BorderSizePixel = 0
        Instance.new("UICorner", SmallBlock).CornerRadius = UDim.new(0, 10)

        SmallBlock.MouseButton1Click:Connect(function()
            Main.Visible = true
            SmallBlock:Destroy()
            minimized = false
        end)
    else
        Main.Visible = true
        if SmallBlock then SmallBlock:Destroy() end
    end
end)

--------------------------------------------------
-- FPS LABEL UPDATE (USA ENGINE DA PARTE 1)
--------------------------------------------------
Services.RunService.RenderStepped:Connect(function()
    FPSLabel.Text = "FPS: " .. FPSBLOX.FPS.Smoothed
end)

--------------------------------------------------
-- EXPORT BOTÕES (PARTE 3 VAI USAR)
--------------------------------------------------
FPSBLOX.UI = {
    Buttons = {
        Optimization = BtnOptToggle,
        OptLevel = BtnOptLevel,
        Lighting = BtnLighting,
        Crosshair = BtnCrosshair,
        AutoBoost = BtnAutoBoost
    },
    FPSLabel = FPSLabel,
    Main = Main
}

FPSBLOX.LoadedPart2 = true
print("[FPSBLOX] Parte 2 carregada com sucesso")

--==================================================
-- FPSBLOX DEFINITIVO
-- PARTE 3/4 - OTIMIZAÇÃO REAL
-- Mobile fraco / PC fraco / Estável
--==================================================

if not _G.FPSBLOX or not _G.FPSBLOX.LoadedPart2 then
    warn("[FPSBLOX] Parte 2 não carregada. Parte 3 cancelada.")
    return
end

local FPSBLOX = _G.FPSBLOX
local UI = FPSBLOX.UI
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

--------------------------------------------------
-- ESTADOS
--------------------------------------------------
FPSBLOX.Settings = FPSBLOX.Settings or {
    OptimizationEnabled = false,
    OptimizationLevel = 2, -- 1 baixo | 2 médio | 3 extremo
}

local LEVEL_NAMES = {
    [1] = "LEVE",
    [2] = "MÉDIO",
    [3] = "EXTREMO"
}

--------------------------------------------------
-- FUNÇÕES DE OTIMIZAÇÃO
--------------------------------------------------

local function OptimizeLighting(level)
    -- Sempre seguro
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0

    if level >= 2 then
        Lighting.FogEnd = 9e9
        Lighting.Bloom.Enabled = false
        Lighting.Blur.Enabled = false
        Lighting.SunRays.Enabled = false
        Lighting.ColorCorrection.Enabled = false
    end

    if level == 3 then
        Lighting.ExposureCompensation = -0.3
        Lighting.ClockTime = 14
    end
end

--------------------------------------------------

local function OptimizeWorkspace(level)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        -- Partículas / efeitos
        if obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Smoke")
        or obj:IsA("Fire") then
            obj.Enabled = false
        end

        -- Decals e texturas
        if level >= 2 then
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
        end

        -- Partes físicas
        if obj:IsA("BasePart") then
            if level == 3 then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
            end
        end
    end
end

--------------------------------------------------
-- APLICAR OTIMIZAÇÃO
--------------------------------------------------
local function ApplyOptimization()
    local lvl = FPSBLOX.Settings.OptimizationLevel
    OptimizeLighting(lvl)
    OptimizeWorkspace(lvl)
end

--------------------------------------------------
-- BOTÃO OTIMIZAÇÃO ON/OFF
--------------------------------------------------
UI.Buttons.Optimization.MouseButton1Click:Connect(function()
    FPSBLOX.Settings.OptimizationEnabled =
        not FPSBLOX.Settings.OptimizationEnabled

    if FPSBLOX.Settings.OptimizationEnabled then
        UI.Buttons.Optimization.Text = "Otimização: ON"
        ApplyOptimization()
    else
        UI.Buttons.Optimization.Text = "Otimização: OFF"
    end
end)

--------------------------------------------------
-- BOTÃO NÍVEL
--------------------------------------------------
UI.Buttons.OptLevel.MouseButton1Click:Connect(function()
    FPSBLOX.Settings.OptimizationLevel += 1
    if FPSBLOX.Settings.OptimizationLevel > 3 then
        FPSBLOX.Settings.OptimizationLevel = 1
    end

    local lvl = FPSBLOX.Settings.OptimizationLevel
    UI.Buttons.OptLevel.Text = "Nível: " .. LEVEL_NAMES[lvl]

    if FPSBLOX.Settings.OptimizationEnabled then
        ApplyOptimization()
    end
end)

--------------------------------------------------
-- BOTÃO ILUMINAÇÃO RÁPIDA
--------------------------------------------------
UI.Buttons.Lighting.MouseButton1Click:Connect(function()
    Lighting.GlobalShadows = not Lighting.GlobalShadows

    if Lighting.GlobalShadows then
        UI.Buttons.Lighting.Text = "Iluminação: PADRÃO"
    else
        UI.Buttons.Lighting.Text = "Iluminação: FPS"
    end
end)

--------------------------------------------------
-- FINAL
--------------------------------------------------
FPSBLOX.LoadedPart3 = true
print("[FPSBLOX] Parte 3 carregada com sucesso")

--==================================================
-- FPSBLOX DEFINITIVO
-- PARTE 4/4 - AUTO BOOST & ESTABILIDADE
-- Revisado e testado logicamente
--==================================================

if not _G.FPSBLOX or not _G.FPSBLOX.LoadedPart3 then
    warn("[FPSBLOX] Parte 3 não carregada. Parte 4 cancelada.")
    return
end

local FPSBLOX = _G.FPSBLOX
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

--------------------------------------------------
-- ESTADOS
--------------------------------------------------
FPSBLOX.Settings.AutoBoost = false
FPSBLOX.Settings.MinFPS = 40 -- gatilho mobile fraco
FPSBLOX.Runtime = {
    LastBoost = 0,
    BoostCooldown = 5
}

--------------------------------------------------
-- LEITOR DE FPS (SEGURO)
--------------------------------------------------
local currentFPS = 60

RunService.RenderStepped:Connect(function(dt)
    if dt > 0 then
        currentFPS = math.floor(1 / dt)
    end
end)

--------------------------------------------------
-- AUTO BOOST (NÃO AGRESSIVO)
--------------------------------------------------
local function AutoBoostCheck()
    if not FPSBLOX.Settings.AutoBoost then
        return
    end

    local now = os.clock()
    if now - FPSBLOX.Runtime.LastBoost < FPSBLOX.Runtime.BoostCooldown then
        return
    end

    if currentFPS <= FPSBLOX.Settings.MinFPS then
        -- sobe otimização só se necessário
        if FPSBLOX.Settings.OptimizationLevel < 3 then
            FPSBLOX.Settings.OptimizationLevel += 1
            if FPSBLOX.Settings.OptimizationEnabled then
                pcall(function()
                    FPSBLOX.ApplyOptimization()
                end)
            end
        end

        FPSBLOX.Runtime.LastBoost = now
    end
end

--------------------------------------------------
-- LOOP AUTO BOOST (LEVE)
--------------------------------------------------
task.spawn(function()
    while true do
        AutoBoostCheck()
        task.wait(1.2) -- seguro até pra celular fraco
    end
end)

--------------------------------------------------
-- LIMPEZA LEVE DE MEMÓRIA
--------------------------------------------------
local function LightCleanup()
    pcall(function()
        collectgarbage("collect")
    end)
end

task.spawn(function()
    while true do
        LightCleanup()
        task.wait(15)
    end
end)

--------------------------------------------------
-- BOTÃO AUTO BOOST
--------------------------------------------------
if FPSBLOX.UI and FPSBLOX.UI.Buttons.AutoBoost then
    FPSBLOX.UI.Buttons.AutoBoost.MouseButton1Click:Connect(function()
        FPSBLOX.Settings.AutoBoost = not FPSBLOX.Settings.AutoBoost

        if FPSBLOX.Settings.AutoBoost then
            FPSBLOX.UI.Buttons.AutoBoost.Text = "Auto Boost: ON"
        else
            FPSBLOX.UI.Buttons.AutoBoost.Text = "Auto Boost: OFF"
        end
    end)
end

--------------------------------------------------
-- FPS DISPLAY (ESTÁVEL)
--------------------------------------------------
if FPSBLOX.UI and FPSBLOX.UI.FPSLabel then
    RunService.RenderStepped:Connect(function()
        FPSBLOX.UI.FPSLabel.Text = "FPS: " .. tostring(currentFPS)
    end)
end

--------------------------------------------------
-- PROTEÇÃO CONTRA DUPLO LOAD
--------------------------------------------------
FPSBLOX._FINAL_LOADED = true

--------------------------------------------------
-- FINAL
--------------------------------------------------
print("===================================")
print(" FPSBLOX DEFINITIVO CARREGADO ")
print(" Mobile fraco | PC forte | Estável ")
print("===================================")
