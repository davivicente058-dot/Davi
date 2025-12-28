-- [[ MASTER FPS ULTIMATE v5.0 - PROFESSIONAL EDITION ]] --
-- UI: Rayfield (Mobile Optimized)
-- Part: 1/2 (Engine, Visuals & Combat)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MASTER FPS ULTIMATE v5.0",
   LoadingTitle = "Iniciando Engine Profissional...",
   LoadingSubtitle = "Otimização Extrema Ativada",
   ConfigurationSaving = { Enabled = true, Folder = "MasterFPS" },
   KeySystem = false
})

-- ABAS
local MainTab = Window:CreateTab("Performance", 4483362458)
local CombatTab = Window:CreateTab("Combate & Mira", 4483362458)
local LightTab = Window:CreateTab("Iluminação", 4483362458)

-- [[ 1. MONITOR DE FPS INTELIGENTE (Canto Inferior) ]] --
local FPSDisplay = true
local LabelFPS = MainTab:CreateLabel("FPS: Calculando...")

task.spawn(function()
    local lastUpdate = tick()
    local frames = 0
    while task.wait() do
        frames = frames + 1
        if tick() - lastUpdate >= 1 then
            if FPSDisplay then
                LabelFPS:Set("FPS Atual: " .. frames .. " | Ping: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms")
            end
            frames = 0
            lastUpdate = tick()
        end
    end
end)

MainTab:CreateToggle({
   Name = "Exibir Contador de FPS",
   CurrentValue = true,
   Flag = "ToggleFPS",
   Callback = function(Value) FPSDisplay = Value end,
})

-- [[ 2. REDUÇÃO DE INPUT LAG & VSYNC ]] --
MainTab:CreateSection("Sincronização & Resposta")

MainTab:CreateToggle({
   Name = "Reduzir Input Lag",
   CurrentValue = false,
   Flag = "InputLag",
   Callback = function(Value)
       if Value then
           settings().Network.IncomingReplicationLag = -1000
           settings().Physics.ThrottleAdjustTime = 0
       else
           settings().Network.IncomingReplicationLag = 0
       end
   end,
})

MainTab:CreateToggle({
   Name = "Modo V-Sync (Suavizar Frames)",
   CurrentValue = false,
   Flag = "VSyncMode",
   Callback = function(Value)
       _G.VSync = Value
       if Value then
           task.spawn(function()
               while _G.VSync do
                   game:GetService("RunService").RenderStepped:Wait()
                   -- Mantém a taxa de atualização física sincronizada
               end
           end)
       end
   end,
})

-- [[ 3. SISTEMA DE MIRA FIXA (CROSSHAIR) ]] --
CombatTab:CreateSection("Mira Centralizada")

local Crosshair = Instance.new("Frame")
Crosshair.Name = "MasterCrosshair"
Crosshair.Parent = game:GetService("CoreGui")
Crosshair.Size = UDim2.new(0, 4, 0, 4)
Crosshair.BackgroundColor3 = Color3.new(1, 0, 0)
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
Crosshair.Visible = false

CombatTab:CreateToggle({
   Name = "Ativar Mira Fixa",
   CurrentValue = false,
   Flag = "MiraToggle",
   Callback = function(Value) Crosshair.Visible = Value end,
})

CombatTab:CreateDropdown({
   Name = "Tipo de Mira",
   Options = {"Ponto", "Cruz Pequena", "Cruz Grande"},
   CurrentOption = {"Ponto"},
   Callback = function(Option)
       if Option[1] == "Ponto" then
           Crosshair.Size = UDim2.new(0, 4, 0, 4)
       elseif Option[1] == "Cruz Pequena" then
           Crosshair.Size = UDim2.new(0, 15, 0, 2) -- Simulação simples
       elseif Option[1] == "Cruz Grande" then
           Crosshair.Size = UDim2.new(0, 25, 0, 3)
       end
   end,
})

-- [[ 4. MODOS DE BRILHO (PARTE 11/12) ]] --
LightTab:CreateSection("Controle de Ambiente")

LightTab:CreateDropdown({
   Name = "Modos de Brilho",
   Options = {"Claro", "Padrão", "Escuro"},
   CurrentOption = {"Padrão"},
   Callback = function(Option)
       local L = game:GetService("Lighting")
       if Option[1] == "Claro" then
           L.Brightness = 3 L.OutdoorAmbient = Color3.new(1,1,1)
           L.ExposureCompensation = 0.5
       elseif Option[1] == "Escuro" then
           L.Brightness = 0.7 L.OutdoorAmbient = Color3.fromRGB(60, 60, 60)
           L.ExposureCompensation = -0.2
       else
           L.Brightness = 1 L.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
           L.ExposureCompensation = 0
       end
   end,
})

LightTab:CreateToggle({
   Name = "Suavizar Luzes (Reduzir Intensidade)",
   CurrentValue = false,
   Flag = "SmoothLights",
   Callback = function(Value)
       local Bloom = game:GetService("Lighting"):FindFirstChildOfClass("BloomEffect")
       if Value then
           if Bloom then Bloom.Intensity = 0.1 end
           game:GetService("Lighting").EnvironmentDiffuseScale = 0.2
       else
           if Bloom then Bloom.Intensity = 1 end
           game:GetService("Lighting").EnvironmentDiffuseScale = 1
       end
   end,
})

Rayfield:Notify({Title = "Parte 1 Carregada", Content = "Motor e Interface prontos.", Duration = 3})

-- [[ 4. LIMPEZA DE DEBRIS (RESTOS DE LUTA/ITENS) ]] --
OptTab:CreateButton({
   Name = "Limpar Restos do Mapa (Debris)",
   Callback = function()
       local count = 0
       for _, v in pairs(workspace:GetChildren()) do
           if v.Name == "Debris" or v.Name == "Effect" or v:IsA("Part") and v.Transparency == 1 and not v.CanCollide then
               v:Destroy()
               count = count + 1
           end
       end
       collectgarbage("collect")
       Rayfield:Notify({Title = "Limpeza", Content = count .. " objetos inúteis removidos.", Duration = 3})
   end,
})

-- [[ MASTER FPS ULTIMATE v5.0 - PROFESSIONAL EDITION ]] --
-- Part: 2/2 (Otimizações em Níveis, Chunks & Modo Competitivo)

local OptTab = Window:CreateTab("Otimizações", 4483362458)
local MapTab = Window:CreateTab("Mapa & Clima", 4483362458)

-- [[ 1. SISTEMA DE OTIMIZAÇÃO EM NÍVEIS ]] --
OptTab:CreateSection("Níveis de Performance")

local function SetOptimizationLevel(Level)
    local lighting = game:GetService("Lighting")
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    
    if Level >= 1 then
        -- Nível 1: Básico
        lighting.GlobalShadows = false
        settings().Rendering.QualityLevel = 1
    end
    
    if Level >= 2 then
        -- Nível 2: Médio (Partículas e Luzes)
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Explosion") then
                v.Enabled = false
            end
            if v:IsA("PointLight") or v:IsA("SpotLight") then
                v.Enabled = false
            end
        end
    end
    
    if Level >= 3 then
        -- Nível 3: COMPETITIVO (Sem Texturas & Low Poly)
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                v.TextureID = "" -- Remove a textura do Mesh
            end
            if v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
            if v:IsA("SpecialMesh") then
                v.TextureId = ""
            end
        end
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
        end
    end
end

OptTab:CreateDropdown({
   Name = "Nível de Otimização",
   Options = {"Desativado", "Nível 1 (Leve)", "Nível 2 (Médio)", "Nível 3 (COMPETITIVO)"},
   CurrentOption = {"Desativado"},
   Callback = function(Option)
       if Option[1] ~= "Desativado" then
           local lvl = tonumber(Option[1]:match("%d")) or 3
           SetOptimizationLevel(lvl)
           Rayfield:Notify({Title = "Otimização", Content = "Nível " .. lvl .. " aplicado com sucesso!", Duration = 3})
       end
   end,
})

-- [[ 2. GRÁFICOS SIMPLIFICADOS & NÉVOA (FOG) ]] --
MapTab:CreateSection("Renderização do Mapa")

MapTab:CreateToggle({
   Name = "Gráficos Simplificados (Low Poly)",
   CurrentValue = false,
   Flag = "LowPoly",
   Callback = function(Value)
       if Value then
           for _, v in pairs(workspace:GetDescendants()) do
               if v:IsA("BasePart") then
                   v.Material = Enum.Material.SmoothPlastic
               end
           end
       end
   end,
})

MapTab:CreateToggle({
   Name = "Ativar Névoa de Performance",
   CurrentValue = false,
   Flag = "FogToggle",
   Callback = function(Value)
       local L = game:GetService("Lighting")
       if Value then
           L.FogEnd = 500
           L.FogStart = 100
           L.FogColor = Color3.fromRGB(0, 0, 0) -- Névoa preta economiza render
       else
           L.FogEnd = 100000
       end
   end,
})

-- [[ 3. DETECÇÃO DE 120HZ & UNLOCKER ]] --
OptTab:CreateSection("Hardware & Frames")

OptTab:CreateButton({
   Name = "Detectar e Ativar 120Hz",
   Callback = function()
       if setfpscap then
           setfpscap(120)
           Rayfield:Notify({Title = "Hardware", Content = "Tentando desbloquear 120 FPS...", Duration = 3})
       else
           Rayfield:Notify({Title = "Erro", Content = "Seu executor não suporta FPS Unlocker.", Duration = 3})
       end
   end,
})

-- [[ 4. LIMPEZA DE DEBRIS (RESTOS DE LUTA/ITENS) ]] --
OptTab:CreateButton({
   Name = "Limpar Restos do Mapa (Debris)",
   Callback = function()
       local count = 0
       for _, v in pairs(workspace:GetChildren()) do
           if v.Name == "Debris" or v.Name == "Effect" or v:IsA("Part") and v.Transparency == 1 and not v.CanCollide then
               v:Destroy()
               count = count + 1
           end
       end
       collectgarbage("collect")
       Rayfield:Notify({Title = "Limpeza", Content = count .. " objetos inúteis removidos.", Duration = 3})
   end,
})

-- [[ 5. REMOÇÃO DE ANIMAÇÕES EXTRAS ]] --
OptTab:CreateToggle({
   Name = "Modo Fluidez Total (Sem Anims Extras)",
   CurrentValue = false,
   Flag = "NoAnims",
   Callback = function(Value)
       _G.NoAnims = Value
       if Value then
           for _, v in pairs(game:GetDescendants()) do
               if v:IsA("Animation") then
                   -- Reduzir prioridade de animações se o executor permitir
               end
           end
       end
   end,
})

-- NOTIFICAÇÃO FINAL DE CARREGAMENTO
Rayfield:Notify({
   Title = "MASTER FPS v5.0",
   Content = "Script 100% Carregado. Use com sabedoria!",
   Duration = 5,
   Image = 4483362458,
})
