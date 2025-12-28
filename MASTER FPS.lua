-- [[ MASTER FPS ULTIMATE v7.0 - SUPREMACIA MOBILE ]] --
-- Engine: Rayfield (High Performance)
-- Otimização: Agressiva / Low-Level / Anti-Lag Profundo

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MASTER FPS ULTIMATE v7.0",
   LoadingTitle = "Injetando Módulos de Performance...",
   LoadingSubtitle = "Otimização Extrema de Engine",
   ConfigurationSaving = { Enabled = true, Folder = "MasterFPS_Pro" },
   KeySystem = false
})

-- [[ SERVIÇOS E VARIÁVEIS CORE ]] --
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Network = game:GetService("NetworkClient")
local Debris = game:GetService("Debris")
local UserInput = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- [[ ABAS ]] --
local Tab_Perf = Window:CreateTab("Performance", 4483362458)
local Tab_Graf = Window:CreateTab("Gráficos", 4483362458)
local Tab_Combat = Window:CreateTab("Combate & Mira", 4483362458)
local Tab_World = Window:CreateTab("Mundo/Chunks", 4483362458)

-- [[ 1. MONITOR DE PERFORMANCE PRO ]] --
local FPSLabel = Tab_Perf:CreateLabel("Monitorando Hardware...")
local FPSVisible = false

task.spawn(function()
    local TimeTable = {}
    while task.wait(0.5) do
        if FPSVisible then
            local now = tick()
            while #TimeTable > 0 and TimeTable[1] < now - 1 do table.remove(TimeTable, 1) end
            table.insert(TimeTable, now)
            local fps = #TimeTable
            local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            local memory = math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb())
            FPSLabel:Set("FPS: " .. fps .. " | Ping: " .. ping .. "ms | RAM: " .. memory .. "MB")
        end
    end
end)

Tab_Perf:CreateToggle({
   Name = "Ativar FPS Counter Inteligente",
   CurrentValue = false,
   Callback = function(Value) FPSVisible = Value end,
})

-- [[ 2. OTIMIZAÇÕES EM NÍVEIS (SISTEMA DE ESCALA) ]] --
Tab_Perf:CreateSection("Níveis de Performance Agressiva")

local function DeepClean(v)
    if v:IsA("BasePart") then
        v.Material = Enum.Material.SmoothPlastic
        v.CastShadow = false
        v.Reflectance = 0
        if v:IsA("MeshPart") then
            v.TextureID = ""
            v.MeshId = v.MeshId
        end
    elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("Trail") or v:IsA("ParticleEmitter") then
        v:Destroy()
    end
end

Tab_Perf:CreateDropdown({
   Name = "Nível de Otimização (Engine)",
   Options = {"Padrão", "Nível 1 (Leve)", "Nível 2 (Médio)", "Nível 3 (COMPETITIVO/SEM TEXTURA)"},
   CurrentOption = {"Padrão"},
   Callback = function(Option)
       if Option[1] == "Nível 1 (Leve)" then
           settings().Rendering.QualityLevel = 1
           Lighting.GlobalShadows = false
       elseif Option[1] == "Nível 2 (Médio)" then
           settings().Rendering.QualityLevel = 1
           for _, v in pairs(workspace:GetDescendants()) do
               if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
           end
       elseif Option[1] == "Nível 3 (COMPETITIVO/SEM TEXTURA)" then
           settings().Rendering.QualityLevel = 1
           for _, v in pairs(game:GetDescendants()) do pcall(DeepClean, v) end
           settings().Network.IncomingReplicationLag = -1000
       end
       Rayfield:Notify({Title = "Performance", Content = "Motor ajustado para: " .. Option[1], Duration = 3})
   end,
})

-- [[ 3. FPS BOOST & INPUT LAG (CORREÇÃO DE MOTOR) ]] --
Tab_Perf:CreateSection("Modos Especiais")

Tab_Perf:CreateToggle({
   Name = "Modo FPS BOOST (Gráficos Simplificados)",
   CurrentValue = false,
   Callback = function(Value)
       if Value then
           for _, v in pairs(workspace:GetDescendants()) do
               if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
           end
       end
   end,
})

Tab_Perf:CreateToggle({
   Name = "Redução de Input Lag (Resposta Ultra)",
   CurrentValue = false,
   Callback = function(Value)
       if Value then
           settings().Physics.ThrottleAdjustTime = 0
           RunService:SetRobustPhysicsHz(60)
       end
   end,
})

Tab_Perf:CreateButton({
   Name = "Desbloquear 120Hz (Se Suportado)",
   Callback = function()
       if setfpscap then setfpscap(120) 
       Rayfield:Notify({Title = "Hardware", Content = "Tentativa de 120Hz aplicada.", Duration = 3})
       end
   end,
})

-- [[ 4. ILUMINAÇÃO PROFISSIONAL ]] --
Tab_Graf:CreateSection("Brilho e Sombras")

Tab_Graf:CreateDropdown({
   Name = "Modos de Brilho",
   Options = {"Claro", "Padrão", "Escuro (Suave)", "Noite Total"},
   CurrentOption = {"Padrão"},
   Callback = function(Option)
       if Option[1] == "Claro" then
           Lighting.Brightness = 3 Lighting.OutdoorAmbient = Color3.new(1,1,1)
       elseif Option[1] == "Escuro (Suave)" then
           Lighting.Brightness = 0.7 Lighting.OutdoorAmbient = Color3.fromRGB(60,60,60)
       elseif Option[1] == "Noite Total" then
           Lighting.Brightness = 0.2 Lighting.OutdoorAmbient = Color3.fromRGB(10,10,10) Lighting.ClockTime = 0
       else
           Lighting.Brightness = 1 Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127)
       end
   end,
})

Tab_Graf:CreateToggle({
   Name = "Suavizar Luzes (Bloom Off)",
   CurrentValue = false,
   Callback = function(Value)
       Lighting.EnvironmentDiffuseScale = Value and 0 or 1
       local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
       if bloom then bloom.Enabled = not Value end
   end,
})

-- [[ 5. COMBATE & MIRA ]] --
Tab_Combat:CreateSection("Mira Fixa Customizável")

local Crosshair = Instance.new("Frame")
Crosshair.Name = "Crosshair"
Crosshair.Parent = game:GetService("CoreGui")
Crosshair.BackgroundColor3 = Color3.new(1, 0, 0)
Crosshair.Visible = false
Crosshair.ZIndex = 999

Tab_Combat:CreateToggle({
   Name = "Ativar Mira Fixa",
   CurrentValue = false,
   Callback = function(Value) Crosshair.Visible = Value end,
})

Tab_Combat:CreateDropdown({
   Name = "Tipo de Mira",
   Options = {"Ponto", "Cross Pequena", "Cross Larga"},
   CurrentOption = {"Ponto"},
   Callback = function(Option)
       Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
       Crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
       if Option[1] == "Ponto" then Crosshair.Size = UDim2.new(0, 4, 0, 4)
       elseif Option[1] == "Cross Pequena" then Crosshair.Size = UDim2.new(0, 12, 0, 2)
       elseif Option[1] == "Cross Larga" then Crosshair.Size = UDim2.new(0, 25, 0, 2) end
   end,
})

-- [[ 6. SISTEMA DE CHUNKS & MAPA ]] --
local RenderRadius = 300
local ChunkActive = false

Tab_World:CreateToggle({
   Name = "Ativar Chunks (Minecraft Style)",
   CurrentValue = false,
   Callback = function(Value) ChunkActive = Value end,
})

Tab_World:CreateSlider({
   Name = "Distância de Renderização",
   Min = 50, Max = 1000, Default = 300, Increment = 50,
   Callback = function(Value) RenderRadius = Value end,
})

task.spawn(function()
    while task.wait(2) do
        if ChunkActive then
            local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
                        if pos then
                            local hide = (root.Position - pos).Magnitude > RenderRadius
                            if obj:IsA("BasePart") then obj.LocalTransparencyModifier = hide and 1 or 0
                            else for _, p in pairs(obj:GetDescendants()) do if p:IsA("BasePart") then p.LocalTransparencyModifier = hide and 1 or 0 end end end
                        end
                    end
                end
            end
        end
    end
end)



-- [[ 7. LIMPEZA PROFUNDA ]] --
Tab_Perf:CreateSection("Manutenção de RAM")
Tab_Perf:CreateButton({
   Name = "Limpeza Agressiva (Purge RAM)",
   Callback = function()
       collectgarbage("collect")
       for _, v in pairs(workspace:GetChildren()) do
           if v.Name == "Debris" or v.Name == "Effect" then v:Destroy() end
       end
       Rayfield:Notify({Title = "Sistema", Content = "Memória e Cache limpos!", Duration = 2})
   end,
})

-- [[ SEÇÃO DE OTIMIZAÇÃO DE MOTOR - PRÉ-CARREGAMENTO ]] --
-- Esta parte garante que o motor do jogo responda mais rápido aos comandos de fluidez.

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- Função interna para limpar efeitos de renderização pesada
local function ClearHeavyEffects()
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false
        end
    end
end

-- Título visual na UI para separar as funções de motor
Tab_Engine:CreateSection("⚙️ Engine Pro & Estabilização")

-- [[ AGORA O SEU CÓDIGO CONTINUA COM: local Tab_Engine = ... ]] --

-- [[ INÍCIO DO MÓDULO DE MOTOR & FLUIDEZ ]] --
local Tab_Engine = Window:CreateTab("Motor & Fluidez", 4483362458)

Tab_Engine:CreateSection("Gerenciamento de Sombras")
Tab_Engine:CreateToggle({
   Name = "Desativar Todas as Sombras (Global)",
   CurrentValue = false,
   Callback = function(Value)
       game:GetService("Lighting").GlobalShadows = not Value
       for _, v in pairs(game.Workspace:GetDescendants()) do
           if v:IsA("BasePart") then v.CastShadow = not Value end
       end
   end,
})

Tab_Engine:CreateSection("Fluidez & Movimento")
Tab_Engine:CreateToggle({
   Name = "Reduzir Taxa de Animações",
   CurrentValue = false,
   Callback = function(Value)
       _G.ReduceAnims = Value
       task.spawn(function()
           while _G.ReduceAnims do
               for _, v in pairs(game.Players:GetPlayers()) do
                   if v.Character and v ~= game.Players.LocalPlayer then
                       local hum = v.Character:FindFirstChildOfClass("Humanoid")
                       if hum then hum.Animator.EvaluationMethod = Value and Enum.AnimatorEvaluationMethod.Throttled or Enum.AnimatorEvaluationMethod.Automatic end
                   end
               end
               task.wait(5)
           end
       end)
   end,
})

Tab_Engine:CreateSection("Efeitos de Luz")
Tab_Engine:CreateToggle({
   Name = "Remover Luzes Dinâmicas (Anti-Heat)",
   CurrentValue = false,
   Callback = function(Value)
       for _, v in pairs(workspace:GetDescendants()) do
           if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then v.Enabled = not Value end
       end
   end,
})

Tab_Engine:CreateSection("Limpeza de Pós-Processamento")
Tab_Engine:CreateToggle({
   Name = "Desativar Efeitos de Tela (Blur/Bloom)",
   CurrentValue = false,
   Callback = function(Value)
       for _, v in pairs(game:GetService("Lighting"):GetChildren()) do
           if v:IsA("PostProcessEffect") or v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("SunRaysEffect") then v.Enabled = not Value end
       end
   end,
})

Tab_Engine:CreateToggle({
   Name = "Priorizar Fluidez sobre Gráficos",
   CurrentValue = false,
   Callback = function(Value)
       if Value then
           settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level10
           settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Enabled
       else
           settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
       end
   end,
})

Tab_Engine:CreateButton({
   Name = "Otimizar Interface do Jogo",
   Callback = function()
       local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
       for _, v in pairs(PlayerGui:GetDescendants()) do
           if v:IsA("ImageLabel") or v:IsA("ImageButton") then v.ResampleMode = Enum.ResamplerMode.Pixelated end
       end
       Rayfield:Notify({Title = "UI", Content = "Interfaces otimizadas!", Duration = 3})
   end,
})
-- [[ FIM DO MÓDULO DE MOTOR & FLUIDEZ ]] --

Rayfield:LoadConfiguration()
