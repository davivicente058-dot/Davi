-- [[ MASTER FPS REMAKE - VERSÃO UNIFICADA & BLINDADA ]] --

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- Criando a Janela (O "Cérebro" do Script)
local Window = Fluent:CreateWindow({
    Title = "MASTER FPS REMAKE",
    SubTitle = "by Gemini AI",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- Deixamos falso para dar mais FPS
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Criando as Abas
local Tabs = {
    Main = Window:AddTab({ Title = "Otimização", Icon = "zap" }),
    Visuals = Window:AddTab({ Title = "Gráficos", Icon = "image" }),
    System = Window:AddTab({ Title = "Sistema", Icon = "cpu" })
}

-- [[ PARTE 1 & 6: MONITOR E DELAY ]] --
local FpsLabel = Tabs.Main:AddParagraph({
    Title = "Status",
    Content = "Carregando informações..."
})

task.spawn(function()
    while task.wait(1) do
        local fps = math.floor(workspace:GetRealPhysicsFPS())
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        FpsLabel:SetDesc("FPS: " .. fps .. " | Ping: " .. ping .. "ms")
    end
end)

-- [[ PARTE 2, 4 & 5: COMPETITIVO E SOMBRAS ]] --
local OptSection = Tabs.Main:AddSection("Performance Máxima")

Tabs.Main:AddToggle("CompMode", {
    Title = "Modo Competitivo (Ultra FPS)", 
    Default = false,
    Callback = function(Value)
        if Value then
            settings().Rendering.QualityLevel = 1
            game:GetService("Lighting").GlobalShadows = false
            for _, v in pairs(game.Workspace:GetDescendants()) do
                if v:IsA("BasePart") then 
                    v.Material = Enum.Material.SmoothPlastic 
                    v.CastShadow = false 
                end
                if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
            end
        end
    end
})

-- [[ PARTE 3: FLUIDEZ / 120HZ ]] --
Tabs.Main:AddToggle("FPSUnlock", {
    Title = "Simular 120Hz (FPS Unlock)",
    Default = false,
    Callback = function(Value)
        if setfpscap then setfpscap(Value and 120 or 60) end
    end
})

-- [[ PARTE 7: CHUNKS (MINECRAFT STYLE) ]] --
local ChunkSection = Tabs.Visuals:AddSection("Renderização de Mapa")
local RenderRadius = 300

Tabs.Visuals:AddToggle("ChunkSystem", {
    Title = "Ativar Carregamento por Chunks",
    Default = false,
    Callback = function(Value)
        _G.Chunks = Value
    end
})

Tabs.Visuals:AddSlider("Distance", {
    Title = "Distância de Visão",
    Min = 100, Max = 1000, Default = 300, Rounding = 0,
    Callback = function(V) RenderRadius = V end
})

-- Loop dos Chunks
task.spawn(function()
    while task.wait(2) do
        if _G.Chunks then
            local char = game.Players.LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                for _, obj in pairs(game.Workspace:GetChildren()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position) or (obj:IsA("BasePart") and obj.Position)
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
    end
end)

-- [[ PARTE 2: MODOS DE LUZ ]] --
Tabs.Visuals:AddSection("Iluminação")
Tabs.Visuals:AddDropdown("LightMode", {
    Title = "Ajuste de Brilho",
    Values = {"Claro", "Padrão", "Escuro"},
    Default = "Padrão",
    Callback = function(V)
        local L = game:GetService("Lighting")
        if V == "Claro" then L.Brightness = 3 L.OutdoorAmbient = Color3.new(1,1,1)
        elseif V == "Escuro" then L.Brightness = 0.5 L.OutdoorAmbient = Color3.new(0.2,0.2,0.2)
        else L.Brightness = 1 L.OutdoorAmbient = Color3.new(0.5,0.5,0.5) end
    end
})

-- [[ PARTE 6: LIMPEZA DE MEMÓRIA ]] --
Tabs.System:AddButton({
    Title = "Limpar Cache de RAM agora",
    Callback = function()
        collectgarbage("collect")
        Fluent:Notify({Title = "Sistema", Content = "Memória RAM limpa!", Duration = 3})
    end
})

-- FINALIZAÇÃO OBRIGATÓRIA PARA APARECER
Tabs.Main:Select()
Fluent:Notify({
    Title = "MASTER FPS REMAKE",
    Content = "Script carregado! Use o menu para ativar as opções.",
    Duration = 5
})
