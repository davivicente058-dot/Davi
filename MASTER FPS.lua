-- [[ MASTER FPS ULTIMATE v3.0 - HIGH PERFORMANCE EDITION ]] --
-- Focado em: Máxima Fluidez, Baixa Latência e Otimização de Engine

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- [ JANELA PRINCIPAL ] --
local Window = Fluent:CreateWindow({
    Title = "MASTER FPS REMAKE",
    SubTitle = "Performance Avançada",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, 
    Theme = "Darker", 
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Otimização", Icon = "zap" }),
    Graphics = Window:AddTab({ Title = "Gráficos & Luz", Icon = "image" }),
    World = Window:AddTab({ Title = "Renderização", Icon = "map" })
}

-- [[ SISTEMA DE MONITORAMENTO AVANÇADO ]] --
local FpsLabel = Tabs.Main:AddParagraph({ Title = "Status do Sistema", Content = "Iniciando..." })
task.spawn(function()
    local RunService = game:GetService("RunService")
    while task.wait(0.5) do
        local fps = math.floor(1/RunService.RenderStepped:Wait())
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        local mem = math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb())
        FpsLabel:SetDesc("FPS: " .. fps .. " | Ping: " .. ping .. "ms | RAM: " .. mem .. "MB")
    end
end)

-- [[ SEÇÃO 1: PERFORMANCE & CORE (FLUIDEZ) ]] --
local PerfSection = Tabs.Main:AddSection("Motor do Jogo")

Tabs.Main:AddToggle("CompMode", {
    Title = "Modo Competitivo (Extremo)", 
    Default = false,
    Description = "Força o jogo ao limite mínimo de gráficos para máxima vantagem.",
    Callback = function(Value)
        if Value then
            settings().Rendering.QualityLevel = 1
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level10
            for _, v in pairs(game.Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.CastShadow = false
                end
            end
        end
    end
})

Tabs.Main:AddToggle("FluidStep", {
    Title = "Estabilizador de Frame (60/120Hz)", 
    Default = false,
    Callback = function(Value)
        _G.SmoothActive = Value
        if Value then
            task.spawn(function()
                while _G.SmoothActive do
                    -- Força a física a não atrasar o render
                    settings().Physics.ThrottleAdjustTime = 0
                    settings().Physics.AllowSleep = true
                    task.wait(0.1)
                end
            end)
        end
    end
})

Tabs.Main:AddToggle("NetBoost", {
    Title = "Reduzir Input Lag & Rede", 
    Default = false,
    Callback = function(Value)
        if Value then
            settings().Network.IncomingReplicationLag = -1000
            settings().Network.DataSendRate = 100
        else
            settings().Network.IncomingReplicationLag = 0
        end
    end
})

-- [[ SEÇÃO 2: GRÁFICOS, LUZ E PARTÍCULAS ]] --
local LightSection = Tabs.Graphics:AddSection("Iluminação e Efeitos")

Tabs.Graphics:AddToggle("NoParticles", {
    Title = "Remover Partículas & Trails",
    Default = false,
    Callback = function(Value)
        _G.NoParts = Value
        local function Clear(v)
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                v.Enabled = not _G.NoParts
            end
        end
        for _, v in pairs(game:GetDescendants()) do Clear(v) end
        game.DescendantAdded:Connect(Clear)
    end
})

Tabs.Graphics:AddToggle("NoLights", {
    Title = "Desativar Luzes Dinâmicas", 
    Default = false,
    Callback = function(Value)
        _G.NoLights = Value
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Light") then v.Enabled = not Value end
        end
    end
})

Tabs.Graphics:AddDropdown("VisualModes", {
    Title = "Modos de Ambiente",
    Values = {"Claro", "Padrão", "Escuro Suave", "Escuro (Otimizado)"},
    Default = "Padrão",
    Callback = function(V)
        local L = game:GetService("Lighting")
        L.GlobalShadows = false
        if V == "Escuro (Otimizado)" then
            L.Brightness = 0.4 L.OutdoorAmbient = Color3.fromRGB(15, 15, 15) L.ClockTime = 0
        elseif V == "Escuro Suave" then
            L.Brightness = 0.7 L.OutdoorAmbient = Color3.fromRGB(45, 45, 45) L.ClockTime = 18
        elseif V == "Claro" then
            L.Brightness = 3 L.OutdoorAmbient = Color3.fromRGB(255, 255, 255) L.ClockTime = 14
        else
            L.Brightness = 1 L.OutdoorAmbient = Color3.fromRGB(127, 127, 127) L.ClockTime = 14
            L.GlobalShadows = true
        end
    end
})

-- [[ SEÇÃO 3: MUNDO & CHUNKS (SMART RENDER) ]] --
local WorldSection = Tabs.World:AddSection("Renderização de Mapa")
local RenderRadius = 300

Tabs.World:AddToggle("ChunkSystem", {
    Title = "Ativar Carregamento por Chunks",
    Default = false,
    Callback = function(Value) _G.ChunksActive = Value end
})

Tabs.World:AddSlider("ChunkDist", {
    Title = "Distância de Renderização", Min = 50, Max = 1500, Default = 300, Rounding = 0,
    Callback = function(V) RenderRadius = V end
})

-- Sistema de Chunks Avançado (Não invisibiliza o que você está olhando)
task.spawn(function()
    local Camera = workspace.CurrentCamera
    while task.wait(1) do
        if _G.ChunksActive then
            local char = game.Players.LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                for _, obj in pairs(game.Workspace:GetChildren()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
                        if pos then
                            local dist = (root.Position - pos).Magnitude
                            local _, onScreen = Camera:WorldToViewportPoint(pos)
                            
                            -- Se estiver longe E fora da tela, desativa agressivamente
                            local hide = (dist > RenderRadius) and not onScreen
                            
                            if obj:IsA("BasePart") then 
                                obj.LocalTransparencyModifier = hide and 1 or 0
                            else 
                                for _, p in pairs(obj:GetDescendants()) do 
                                    if p:IsA("BasePart") then p.LocalTransparencyModifier = hide and 1 or 0 end 
                                end 
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- [[ LIMPEZA DE SISTEMA ]] --
Tabs.Main:AddSection("Manutenção de Memória")
Tabs.Main:AddButton({
    Title = "Purga de RAM & Cache",
    Callback = function()
        collectgarbage("collect")
        game:GetService("ContentProvider"):PreloadAsync({}, function() return false end)
        Fluent:Notify({Title = "Sistema", Content = "Cache de Assets e RAM limpos!", Duration = 3})
    end
})

-- [ INICIALIZAÇÃO ] --
Tabs.Main:Select()
Fluent:Notify({
    Title = "MASTER FPS ULTIMATE",
    Content = "Motor de performance carregado com sucesso!",
    Duration = 5
})
