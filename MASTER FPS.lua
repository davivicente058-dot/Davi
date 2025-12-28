-- [[ MASTER FPS ULTIMATE - VERSÃO COMPLETA & OTIMIZADA ]] --
-- Compatível com Delta, Fluxus e outros executores Mobile.

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/InterfaceManager.lua"))()

-- [ CONFIGURAÇÃO DA JANELA ] --
local Window = Fluent:CreateWindow({
    Title = "MASTER FPS ULTIMATE",
    SubTitle = "Performance & Fluidez",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, 
    Theme = "Darker", -- Tema configurado para ser mais escuro
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- [ ORGANIZAÇÃO DAS ABAS ] --
local Tabs = {
    Main = Window:AddTab({ Title = "Performance", Icon = "zap" }),
    Graphics = Window:AddTab({ Title = "Gráficos", Icon = "image" }),
    World = Window:AddTab({ Title = "Mundo/Chunks", Icon = "map" }),
    Settings = Window:AddTab({ Title = "Config", Icon = "settings" })
}

-- [ MONITOR DE STATUS ] --
local FpsLabel = Tabs.Main:AddParagraph({
    Title = "Status do Sistema",
    Content = "A calcular..."
})

task.spawn(function()
    while task.wait(1) do
        local fps = math.floor(workspace:GetRealPhysicsFPS())
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        FpsLabel:SetDesc("FPS: " .. fps .. " | Ping: " .. ping .. "ms")
    end
end)

-- [[ SEÇÃO 1: OTIMIZAÇÃO DE PERFORMANCE (FPS & DELAY) ]] --
local PerfSection = Tabs.Main:AddSection("Ajustes de Motor")

Tabs.Main:AddToggle("CompMode", {
    Title = "Modo Competitivo (Máximo FPS)",
    Default = false,
    Description = "Remove texturas e sombras para o máximo de performance.",
    Callback = function(Value)
        if Value then
            settings().Rendering.QualityLevel = 1
            for _, v in pairs(game.Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.CastShadow = false
                end
            end
        end
    end
})

Tabs.Main:AddToggle("ZeroDelay", {
    Title = "Reduzir Delay (Input Lag)",
    Default = false,
    Callback = function(Value)
        if Value then
            settings().Network.IncomingReplicationLag = -1000
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Enabled
        end
    end
})

Tabs.Main:AddToggle("FPSUnlock", {
    Title = "Simular 120Hz (Unlocker)",
    Default = false,
    Callback = function(Value)
        if setfpscap then setfpscap(Value and 120 or 60) end
    end
})

-- [[ SEÇÃO 2: GRÁFICOS E ILUMINAÇÃO (REMOVER PARTÍCULAS) ]] --
local GraphSection = Tabs.Graphics:AddSection("Visual & Partículas")

Tabs.Graphics:AddToggle("NoParticles", {
    Title = "Remover Todas as Partículas",
    Default = false,
    Callback = function(Value)
        _G.NoParticles = Value
        local function Clear(v)
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                v.Enabled = not _G.NoParticles
            end
        end
        for _, v in pairs(game.Workspace:GetDescendants()) do Clear(v) end
    end
})

Tabs.Graphics:AddDropdown("LightMode", {
    Title = "Modos de Iluminação (Brilho)",
    Values = {"Muito Claro", "Padrão", "Escuro Suave", "Modo Noite (Mais Escuro)"},
    Default = "Padrão",
    Callback = function(V)
        local L = game:GetService("Lighting")
        if V == "Muito Claro" then
            L.Brightness = 4 L.OutdoorAmbient = Color3.new(1,1,1) L.ClockTime = 14
        elseif V == "Modo Noite (Mais Escuro)" then
            L.Brightness = 0.4 L.OutdoorAmbient = Color3.fromRGB(20, 20, 20) L.ClockTime = 0
        elseif V == "Escuro Suave" then
            L.Brightness = 0.7 L.OutdoorAmbient = Color3.fromRGB(60, 60, 60) L.ClockTime = 18
        else
            L.Brightness = 1 L.OutdoorAmbient = Color3.fromRGB(127, 127, 127) L.ClockTime = 14
        end
    end
})

-- [[ SEÇÃO 3: SISTEMA DE CHUNKS & SMART RENDER ]] --
local WorldSection = Tabs.World:AddSection("Renderização Inteligente")
local RenderRadius = 300

Tabs.World:AddToggle("ChunkSystem", {
    Title = "Ativar Sistema de Chunks",
    Default = false,
    Callback = function(Value) _G.Chunks = Value end
})

Tabs.World:AddSlider("ChunkDist", {
    Title = "Distância de Renderização",
    Min = 50, Max = 1000, Default = 300, Rounding = 0,
    Callback = function(V) RenderRadius = V end
})

-- Loop de Chunks e Smart Render (Otimizado)
task.spawn(function()
    while task.wait(1.5) do
        if _G.Chunks then
            local p = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if p then
                for _, obj in pairs(game.Workspace:GetChildren()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
                        if pos then
                            local hide = (p.Position - pos).Magnitude > RenderRadius
                            if obj:IsA("BasePart") then
                                obj.LocalTransparencyModifier = hide and 1 or 0
                            else
                                for _, child in pairs(obj:GetDescendants()) do
                                    if child:IsA("BasePart") then child.LocalTransparencyModifier = hide and 1 or 0 end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- [[ SEÇÃO 4: MANUTENÇÃO DE SISTEMA ]] --
Tabs.Main:AddSection("Manutenção")
Tabs.Main:AddButton({
    Title = "Limpar Memória RAM (Purge)",
    Callback = function()
        collectgarbage("collect")
        game:GetService("LogService"):ClearOutput()
        Fluent:Notify({Title = "Sistema", Content = "Cache limpo e RAM otimizada!", Duration = 3})
    end
})

-- [ FINALIZAÇÃO ] --
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({
    Title = "MASTER FPS ULTIMATE",
    Content = "Tudo pronto! Otimizações aplicadas.",
    Duration = 5
})

-- [[ FPS BOOSTER & OPTIMIZER - PARTE 11: FLUIDEZ & LUZ DINÂMICA ]] --

local FluidLightSection = Tabs.Main:AddSection("Fluidez Avançada & Iluminação")

-- [[ 1. ESTABILIZADOR DE FRAME (SMOOTH FRAME TIMING) ]] --
-- Evita os picos de lag (stutters) suavizando a carga da CPU entre frames
local SmoothFrameToggle = Tabs.Main:AddToggle("SmoothFrame", {
    Title = "Estabilizador de Fluidez", 
    Default = false,
    Description = "Suaviza a transição entre quadros para evitar travadinhas."
})

local RunService = game:GetService("RunService")
SmoothFrameToggle:OnChanged(function(Value)
    if Value then
        _G.SmoothConn = RunService.Heartbeat:Connect(function(deltaTime)
            -- Se o frame demorar muito, o script tenta limpar tarefas leves da fila
            if deltaTime > 1/30 then 
                settings().Physics.ThrottleAdjustTime = 0
            end
        end)
        Fluent:Notify({Title = "Fluidez", Content = "Estabilizador de Frames Ativo.", Duration = 3})
    else
        if _G.SmoothConn then _G.SmoothConn:Disconnect() end
    end
end)

-- [[ 2. REMOVER LUZES DINÂMICAS (ANTI-HEAT) ]] --
-- Desativa PointLights e SpotLights (lâmpadas, tochas, lanternas) que pesam na GPU
local NoDynamicLights = Tabs.Main:AddToggle("NoDynLights", {
    Title = "Desativar Luzes de Objetos", 
    Default = false,
    Description = "Remove luzes de lâmpadas e poderes (Ótimo para economizar bateria)."
})

NoDynamicLights:OnChanged(function(Value)
    local function ToggleLights(obj)
        if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj.Enabled = not Value
        end
    end

    for _, v in pairs(game.Workspace:GetDescendants()) do
        ToggleLights(v)
    end

    if Value then
        _G.LightConn = game.Workspace.DescendantAdded:Connect(ToggleLights)
    else
        if _G.LightConn then _G.LightConn:Disconnect() end
    end
end)

-- [[ 3. MODO "SOMBRA ZERO" (ENGINE LEVEL) ]] --
-- Desativa propriedades da Engine que calculam reflexos de luz no chão e paredes
Tabs.Main:AddButton({
    Title = "Modo Sombra Zero (Ultra Low)",
    Description = "Força a Engine a não calcular nenhum reflexo ou sombra.",
    Callback = function()
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.ShadowSoftness = 0
        lighting.EnvironmentDiffuseScale = 0
        lighting.EnvironmentSpecularScale = 0
        lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
        
        -- Remove o brilho de materiais como Neon e Metal
        for _, v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Material == Enum.Material.Neon or v.Material == Enum.Material.Metal) then
                v.Material = Enum.Material.SmoothPlastic
            end
        end
        
        Fluent:Notify({Title = "Iluminação", Content = "Reflexos e Sombras totalmente removidos.", Duration = 3})
    end
})

-- [[ 4. OTIMIZADOR DE FOG (NEBLINA) ]] --
-- Remove a neblina que esconde o mapa para ganhar performance de renderização
Tabs.Main:AddToggle("NoFog", {
    Title = "Remover Neblina (Clear View)",
    Default = false,
    Callback = function(Value)
        if Value then
            game:GetService("Lighting").FogEnd = 100000
            game:GetService("Lighting").FogStart = 100000
        else
            game:GetService("Lighting").FogEnd = 1000
        end
    end
})
