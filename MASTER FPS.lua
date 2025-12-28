-- [[ MASTER FPS ULTIMATE - MOBILE OPTIMIZED ]] --
-- UI: Rayfield (Melhor para Android)
-- Foco: Fluidez, FPS Boost Real e Baixa Latência.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MASTER FPS REMAKE v4.0",
   LoadingTitle = "Carregando Engine...",
   LoadingSubtitle = "by Gemini AI",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Performance", 4483362458) -- Ícone de Raio
local VisualTab = Window:CreateTab("Gráficos", 4483362458)

-- [[ FUNÇÃO: FPS BOOST (Redução de Gráficos) ]] --
MainTab:CreateButton({
   Name = "FPS BOOST (Reduzir Gráficos)",
   Callback = function()
       local settings = settings()
       settings.Rendering.QualityLevel = 1
       settings.Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level10
       
       for _, v in pairs(game:GetDescendants()) do
           if v:IsA("BasePart") then
               v.Material = Enum.Material.SmoothPlastic
           end
           if v:IsA("Decal") or v:IsA("Texture") then
               v.Transparency = 0.5 -- Reduz carga de textura sem sumir com tudo
           end
       end
       Rayfield:Notify({Title = "Sucesso", Content = "Gráficos reduzidos para ganho de FPS!", Duration = 3})
   end,
})

-- [[ FUNÇÃO: MODO COMPETITIVO (REFEITO) ]] --
MainTab:CreateToggle({
   Name = "Modo Competitivo (Latência Zero)",
   CurrentValue = false,
   Flag = "CompMode",
   Callback = function(Value)
       if Value then
           -- Desativa sombras e efeitos de pós-processamento que pesam no CPU
           game:GetService("Lighting").GlobalShadows = false
           game:GetService("Lighting").CastShadows = false -- Algumas engines usam esse
           
           for _, effect in pairs(game:GetService("Lighting"):GetChildren()) do
               if effect:IsA("PostProcessEffect") or effect:IsA("BlurEffect") or effect:IsA("BloomEffect") then
                   effect.Enabled = false
               end
           end
           
           -- Prioriza rede
           settings().Network.IncomingReplicationLag = -1000
           Rayfield:Notify({Title = "Comp Mode", Content = "Sombras e Efeitos desativados para fluidez.", Duration = 3})
       else
           game:GetService("Lighting").GlobalShadows = true
       end
   end,
})

-- [[ FUNÇÃO: ESTABILIZADOR DE 120HZ / FLUIDEZ ]] --
MainTab:CreateToggle({
   Name = "Fluidez Extrema (Simular 120Hz)",
   CurrentValue = false,
   Flag = "SmoothFluid",
   Callback = function(Value)
       _G.FluidActive = Value
       if Value then
           if setfpscap then setfpscap(120) end
           task.spawn(function()
               while _G.FluidActive do
                   -- Remove gargalo de física
                   settings().Physics.ThrottleAdjustTime = 0
                   task.wait(0.5)
               end
           end)
       else
           if setfpscap then setfpscap(60) end
       end
   end,
})

-- [[ SEÇÃO DE GRÁFICOS E LUZ (PEDIDO ANTERIOR) ]] --
VisualTab:CreateSection("Iluminação e Partículas")

VisualTab:CreateToggle({
   Name = "Remover Partículas (Anti-Lag)",
   CurrentValue = false,
   Flag = "NoParticles",
   Callback = function(Value)
       _G.NoParts = Value
       for _, v in pairs(game.Workspace:GetDescendants()) do
           if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = not Value end
       end
   end,
})

VisualTab:CreateDropdown({
   Name = "Modos de Brilho",
   Options = {"Padrão", "Escuro Otimizado", "Noite Total"},
   CurrentOption = {"Padrão"},
   MultipleOptions = false,
   Callback = function(Option)
       local L = game:GetService("Lighting")
       if Option[1] == "Escuro Otimizado" then
           L.Brightness = 0.6 L.OutdoorAmbient = Color3.fromRGB(40, 40, 40)
       elseif Option[1] == "Noite Total" then
           L.Brightness = 0.2 L.OutdoorAmbient = Color3.fromRGB(10, 10, 10) L.ClockTime = 0
       else
           L.Brightness = 1 L.OutdoorAmbient = Color3.fromRGB(127, 127, 127) L.ClockTime = 14
       end
   end,
})

-- [[ SISTEMA DE CHUNKS MOBILE ]] --
VisualTab:CreateSection("Otimização de Mapa")
local RenderRadius = 300

VisualTab:CreateSlider({
   Name = "Distância de Chunks",
   Min = 50, Max = 800, Default = 300, Increment = 50,
   ValueName = "Studs",
   Callback = function(Value) RenderRadius = Value end,
})

task.spawn(function()
   while task.wait(2) do
       local char = game.Players.LocalPlayer.Character
       local root = char and char:FindFirstChild("HumanoidRootPart")
       if root then
           for _, obj in pairs(game.Workspace:GetChildren()) do
               if obj:IsA("BasePart") or obj:IsA("Model") then
                   local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetModelCFrame().Position) or obj.Position
                   if pos then
                       local dist = (root.Position - pos).Magnitude
                       local hide = dist > RenderRadius
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
end)

-- [[ LIMPEZA DE RAM ]] --
MainTab:CreateButton({
   Name = "Limpar Memória RAM (Purge)",
   Callback = function()
       collectgarbage("collect")
       Rayfield:Notify({Title = "Sistema", Content = "RAM Purgada!", Duration = 2})
   end,
})

Rayfield:Notify({Title = "Script Carregado", Content = "Aproveite a fluidez no Android!", Duration = 5})
