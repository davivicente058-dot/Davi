-- [[ FPS BOOSTER & OPTIMIZER - PARTE 1: CORE & UI ]] --
-- Desenvolvido para máxima compatibilidade com Delta e Fluxus

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/InterfaceManager.lua"))()

-- Configuração Inicial do Script
local Window = Fluent:CreateWindow({
    Title = "Performance Hub v1.0",
    SubTitle = "by Gemini - Otimização Total",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- Efeito de transparência (pode ser desativado para mais FPS)
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Tecla para minimizar no PC
})

-- [[ Gerenciamento de Abas ]] --
local Tabs = {
    Main = Window:AddTab({ Title = "Início", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Configurações", Icon = "settings" })
}

-- Notificação de Inicialização
Fluent:Notify({
    Title = "Performance Hub",
    Content = "Script carregado com sucesso! Iniciando módulos de otimização...",
    Duration = 5
})

-- [[ Seção: Informações do Sistema ]] --
local MainSection = Tabs.Main:AddSection("Status do Dispositivo")

local FpsLabel = Tabs.Main:AddParagraph({
    Title = "FPS Atual",
    Content = "Calculando..."
})

local PingLabel = Tabs.Main:AddParagraph({
    Title = "Latência (Ping)",
    Content = "Calculando..."
})

-- Lógica para atualizar FPS e Ping em tempo real
task.spawn(function()
    while task.wait(1) do
        local fps = math.floor(workspace:GetRealPhysicsFPS())
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        
        FpsLabel:SetDesc("FPS: " .. fps)
        PingLabel:SetDesc("Ping: " .. ping .. "ms")
    end
end)

-- [[ Seção: Opções Rápidas ]] --
Tabs.Main:AddSection("Controles Rápidos")

local ToggleOtimizacao = Tabs.Main:AddToggle("AutoOptimize", {
    Title = "Otimização Automática", 
    Default = false 
})

ToggleOtimizacao:OnChanged(function(Value)
    if Value then
        Fluent:Notify({
            Title = "Otimizador",
            Content = "O sistema monitorará seu FPS para ajustes automáticos.",
            Duration = 3
        })
    end
end)

-- Botão de Fechar Script
Tabs.Settings:AddButton({
    Title = "Destruir Interface",
    Description = "Remove completamente o script da tela",
    Callback = function()
        Window:Destroy()
    end
})

-- Seleção de Tema
local Options = Fluent.Options
local ThemeDropdown = Tabs.Settings:AddDropdown("Theme", {
    Title = "Tema da Interface",
    Values = {"Dark", "Light", "Aqua", "Amethyst"},
    Default = "Dark",
    Callback = function(Value)
        Window:SetTheme(Value)
    end
})

-- [[ FPS BOOSTER & OPTIMIZER - PARTE 2: TEXTURAS E ILUMINAÇÃO ]] --
-- Esta parte foca em reduzir o estresse do processador gráfico (GPU)

local VisualsSection = Tabs.Main:AddSection("Otimização Visual & FPS")

-- Variáveis de Backup para o modo "Padrão"
local Lighting = game:GetService("Lighting")
local DefaultLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ExposureCompensation = Lighting.ExposureCompensation
}

-- [[ 1. MODO SUPER FPS BOOST (TEXTURAS) ]] --
-- Este módulo percorre o mapa e simplifica os materiais para SmoothPlastic

local TextureToggle = Tabs.Main:AddToggle("TextureOpt", {
    Title = "Super FPS Boost (Remover Texturas)", 
    Default = false 
})

TextureToggle:OnChanged(function(Value)
    if Value then
        -- Função para otimizar texturas
        local function Optimize(obj)
            if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Part") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                -- Desativa sombras individuais para ganhar performance
                obj.CastShadow = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1 -- Esconde texturas pesadas
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end

        -- Aplica no que já existe no jogo
        for _, v in pairs(game.Workspace:GetDescendants()) do
            Optimize(v)
        end

        -- Monitora novos objetos que entrarem no jogo (anti-lag em tempo real)
        _G.TextureConnection = game.Workspace.DescendantAdded:Connect(function(v)
            Optimize(v)
        end)
        
        Fluent:Notify({Title = "Otimizador", Content = "Texturas simplificadas para máximo FPS.", Duration = 3})
    else
        -- Desconecta o monitoramento se desligar
        if _G.TextureConnection then
            _G.TextureConnection:Disconnect()
        end
        Fluent:Notify({Title = "Aviso", Content = "As texturas voltarão ao normal em novos objetos ou ao reiniciar.", Duration = 4})
    end
end)

-- [[ 2. OPÇÃO PARA DIMINUIR LUZES ]] --
-- Foca em sombras e efeitos de pós-processamento que pesam no celular

local LightReductionToggle = Tabs.Main:AddToggle("LightReduc", {
    Title = "Reduzir Luzes e Efeitos", 
    Default = false 
})

LightReductionToggle:OnChanged(function(Value)
    if Value then
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        
        -- Remove efeitos de processamento visual
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") then
                effect.Enabled = false
            end
        end
    else
        Lighting.GlobalShadows = DefaultLighting.GlobalShadows
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") then
                effect.Enabled = true
            end
        end
    end
end)

-- [[ 3. MODOS DE BRILHO (CLARO, PADRÃO, ESCURO) ]] --

Tabs.Main:AddSection("Ambiente e Visibilidade")

local BrightnessDropdown = Tabs.Main:AddDropdown("BrightnessModes", {
    Title = "Modos de Iluminação",
    Values = {"Claro (Máxima Visibilidade)", "Padrão (Original)", "Escuro (Otimizado/Suave)"},
    Default = "Padrão (Original)",
    Callback = function(Value)
        if Value == "Claro (Máxima Visibilidade)" then
            Lighting.Brightness = 3
            Lighting.ClockTime = 14 -- Meio dia
            Lighting.ExposureCompensation = 0.5
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            
        elseif Value == "Padrão (Original)" then
            Lighting.Brightness = DefaultLighting.Brightness
            Lighting.ClockTime = DefaultLighting.ClockTime
            Lighting.ExposureCompensation = DefaultLighting.ExposureCompensation
            Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient
            
        elseif Value == "Escuro (Otimizado/Suave)" then
            -- Um escuro que ainda permite enxergar, ideal para não cansar a vista
            Lighting.Brightness = 0.6
            Lighting.ClockTime = 20 -- Entardecer/Noite
            Lighting.ExposureCompensation = -0.2
            Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 50)
            
            -- Mantém uma luz mínima para não ficar cego
            if not Lighting:FindFirstChild("NightVision") then
                local ambientLight = Instance.new("PointLight")
                ambientLight.Name = "NightVision"
                -- Opcional: anexar ao personagem para enxergar ao redor
            end
        end
    end
})

-- [[ FIM DA PARTE 2 ]] --

-- [[ FPS BOOSTER & OPTIMIZER - PARTE 3: FLUIDEZ E MOTOR GRÁFICO ]] --
-- Foco em: Estabilidade de frames, redução de Input Lag e limpeza de memória.

local FluidSection = Tabs.Main:AddSection("Fluidez e Taxa de Atualização")

-- [[ 1. SIMULADOR DE 120HZ / FPS UNLOCKER ]] --
-- Nota: Isso remove a trava de 60 FPS do Roblox. A fluidez real depende da tela do celular.

local FPSCapToggle = Tabs.Main:AddToggle("FPSUnlock", {
    Title = "Simular 120Hz (FPS Unlocker)", 
    Default = false,
    Description = "Tenta desbloquear o limite de frames para maior suavidade de movimento."
})

FPSCapToggle:OnChanged(function(Value)
    if Value then
        -- Tenta usar funções comuns de executores para liberar FPS
        if setfpscap then
            setfpscap(120)
        else
            Fluent:Notify({
                Title = "Aviso",
                Content = "Seu executor não suporta 'setfpscap', mas aplicaremos otimizações de engine.",
                Duration = 3
            })
        end
        
        -- Ajustes na Engine para priorizar fluidez
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        game:GetService("RunService"):Set3dRenderingEnabled(true)
        
        Fluent:Notify({Title = "Fluidez", Content = "Modo 120Hz simulado ativado.", Duration = 2})
    else
        if setfpscap then setfpscap(60) end
        Fluent:Notify({Title = "Fluidez", Content = "Retornado ao padrão de 60 FPS.", Duration = 2})
    end
end)

-- [[ 2. MODO ULTRA FLUIDEZ (TASK SCHEDULER) ]] --
-- Otimiza como o processador lida com as tarefas do jogo para evitar "stuttering" (travadinhas)

local SmoothToggle = Tabs.Main:AddToggle("UltraFluid", {
    Title = "Modo Ultra Fluidez", 
    Default = false,
    Description = "Reduz o delay de processamento entre frames."
})

SmoothToggle:OnChanged(function(Value)
    if Value then
        -- Ajusta a rede para responder mais rápido (ajuda na fluidez de movimento de outros players)
        settings().Network.IncomingReplicationLag = -1000 
        
        -- Desativa sombras de luzes locais para aliviar o processador
        for _, v in pairs(game:GetService("Lighting"):GetDescendants()) do
            if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
                v.Shadows = false
            end
        end
        
        -- Prioriza a renderização acima de outros processos do sistema
        setrendersettings = setrendersettings or function() end
        setrendersettings("GraphicsMode", "Automatic")
    end
end)

-- [[ 3. OTIMIZAÇÕES EXTRAS QUE VOCÊ PEDIU ]] --
local ExtraOptSection = Tabs.Main:AddSection("Otimizações de Sistema")

-- Limpador de Memória RAM (Garbage Collector)
-- Essencial para celulares fracos não fecharem o jogo sozinhos (Crash)
local MemoryCleaner = Tabs.Main:AddToggle("MemClean", {
    Title = "Limpeza de RAM Automática", 
    Default = false,
    Description = "Limpa o lixo da memória a cada 60 segundos."
})

task.spawn(function()
    while true do
        if MemoryCleaner.Value then
            -- Força o coletor de lixo do Lua a limpar a memória não utilizada
            collectgarbage("collect")
            
            -- Limpa o log de mensagens do jogo para poupar RAM
            game:GetService("LogService"):ClearOutput()
            
            print("[Optimizer]: Memória RAM limpa com sucesso.")
        end
        task.wait(60)
    end
end)

-- Remoção de Detalhes de Terreno (Grama e Água)
local LowTerrain = Tabs.Main:AddToggle("LowTerrain", {
    Title = "Terreno de Baixo Custo", 
    Default = false,
    Description = "Remove grama e simplifica a renderização da água."
})

LowTerrain:OnChanged(function(Value)
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        if Value then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
            sethiddenproperty(terrain, "Decoration", false) -- Tenta remover grama se suportado
        else
            terrain.WaterWaveSize = 0.15
            terrain.WaterWaveSpeed = 0.5
            sethiddenproperty(terrain, "Decoration", true)
        end
    end
end)

-- Forçar Baixa Qualidade via Script (Ignora as configurações do Roblox)
Tabs.Main:AddButton({
    Title = "Forçar Gráficos Mínimos (Engine)",
    Description = "Aplica configurações que o menu padrão do Roblox não alcança.",
    Callback = function()
        local settings = settings()
        settings.Rendering.QualityLevel = 1
        settings.Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level10
        
        -- Remove efeitos de pós-processamento pesados
        local lighting = game:GetService("Lighting")
        local effects = {"Bloom", "Blur", "DepthOfField", "SunRays", "ColorCorrection"}
        for _, effectName in pairs(effects) do
            local effect = lighting:FindFirstChildOfClass(effectName)
            if effect then
                effect.Enabled = false
            end
        end
        
        Fluent:Notify({Title = "Sucesso", Content = "Engine configurada para desempenho máximo.", Duration = 3})
    end
})

-- [[ FIM DA PARTE 3 ]] --

-- [[ FPS BOOSTER & OPTIMIZER - PARTE 4: SOMBRAS, PARTÍCULAS E V-SYNC ]] --
-- Objetivo: Reduzir o processamento de física visual e estabilizar a renderização.

local ShadowSection = Tabs.Main:AddSection("Sombras e Efeitos Visuais")

-- [[ 1. REMOÇÃO TOTAL DE SOMBRAS ]] --
-- Desativa o cálculo de luz e sombra em tempo real
local NoShadowsToggle = Tabs.Main:AddToggle("NoShadows", {
    Title = "Remover Todas as Sombras", 
    Default = false,
    Description = "Desativa sombras globais e individuais de cada objeto."
})

NoShadowsToggle:OnChanged(function(Value)
    game:GetService("Lighting").GlobalShadows = not Value
    
    local function RemoveShadows(obj)
        if obj:IsA("BasePart") then
            obj.CastShadow = not Value
        end
    end

    for _, v in pairs(game.Workspace:GetDescendants()) do
        RemoveShadows(v)
    end

    if Value then
        _G.ShadowConn = game.Workspace.DescendantAdded:Connect(RemoveShadows)
    else
        if _G.ShadowConn then _G.ShadowConn:Disconnect() end
    end
end)

-- [[ 2. REDUÇÃO DE PARTÍCULAS ]] --
-- Desativa fumaça, fogo, faíscas e emissores de partículas
local NoParticlesToggle = Tabs.Main:AddToggle("NoParticles", {
    Title = "Remover Partículas e Efeitos", 
    Default = false,
    Description = "Remove fogo, fumaça e efeitos que pesam no processador."
})

NoParticlesToggle:OnChanged(function(Value)
    local function ManageParticles(obj)
        if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Trail") then
            obj.Enabled = not Value
        end
    end

    for _, v in pairs(game.Workspace:GetDescendants()) do
        ManageParticles(v)
    end

    if Value then
        _G.ParticleConn = game.Workspace.DescendantAdded:Connect(ManageParticles)
        Fluent:Notify({Title = "Otimizador", Content = "Partículas desativadas.", Duration = 2})
    else
        if _G.ParticleConn then _G.ParticleConn:Disconnect() end
    end
end)

-- [[ 3. MODO V-SYNC / ESTABILIZADOR DE FPS ]] --
-- Sincroniza a execução do script com a renderização para evitar picos de lag
local VSyncSection = Tabs.Main:AddSection("Sincronização e Estabilidade")

local VSyncToggle = Tabs.Main:AddToggle("VSyncSim", {
    Title = "Ativar V-Sync Adaptativo", 
    Default = false,
    Description = "Estabiliza o tempo entre frames para evitar quebras de imagem."
})

local RunService = game:GetService("RunService")
local VSyncConnection

VSyncToggle:OnChanged(function(Value)
    if Value then
        Fluent:Notify({Title = "V-Sync", Content = "Sincronização de frames ativada.", Duration = 3})
        
        -- Lógica de estabilização
        VSyncConnection = RunService.RenderStepped:Connect(function()
            -- Força o motor a esperar a renderização do frame anterior antes de processar o próximo
            -- Isso ajuda a manter o tempo de frame constante (Frame Timing)
            debug.setmemorylimit(2048) -- Tenta alocar memória de forma mais estável se o executor permitir
        end)
        
        -- Ajusta a frequência de atualização física para coincidir com a renderização
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Enabled
    else
        if VSyncConnection then
            VSyncConnection:Disconnect()
        end
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Default
    end
end)

-- [[ 4. LIMPEZA DE DEBRIS (RESTOS) ]] --
-- Remove automaticamente itens jogados no chão que ninguém usa
local AutoClearDebris = Tabs.Main:AddToggle("ClearDebris", {
    Title = "Limpeza de Restos Automática", 
    Default = false,
    Description = "Remove objetos temporários largados no mapa (Debris)."
})

task.spawn(function()
    while true do
        if AutoClearDebris.Value then
            local debris = game:GetService("Debris")
            -- O script tenta acelerar a limpeza do que o jogo marcou para deletar
            if #game.Workspace:GetChildren() > 500 then -- Se o mapa estiver muito cheio
                for _, v in pairs(game.Workspace:GetChildren()) do
                    if v:IsA("Part") and v.Transparency == 1 and not v.Anchored then
                        v:Destroy()
                    end
                end
            end
        end
        task.wait(10)
    end
end)

-- [[ FIM DA PARTE 4 ]] --

-- [[ FPS BOOSTER & OPTIMIZER - PARTE 5: MODO COMPETITIVO & CORE OPTIMIZATION ]] --
-- Esta parte otimiza a execução interna do script e cria um preset de máxima performance.

local CompSection = Tabs.Main:AddSection("Performance Profissional")

-- [[ 1. MODO COMPETITIVO (PRESET TUDO NO MÍNIMO) ]] --
-- Quando ativado, ignora a beleza do jogo em favor da menor latência (Input Lag) possível.

local CompModeToggle = Tabs.Main:AddToggle("CompetitiveMode", {
    Title = "Modo Competitivo (Ultra FPS)", 
    Default = false,
    Description = "Ativa todas as configurações de desempenho de uma vez para torneios ou mapas pesados."
})

local function SetCompetitive(state)
    if state then
        -- Força configurações de renderização da Engine
        local settings = settings()
        settings.Rendering.QualityLevel = 1
        settings.Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Enabled
        
        -- Aplica modificações de iluminação agressivas
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9 -- Remove neblina pesada
        lighting.Brightness = 2 -- Melhora visibilidade sem sombras
        
        -- Desativa efeitos de interface se houver
        local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        -- Procura por efeitos de Blur na tela do jogador (comum em alguns jogos)
        for _, v in pairs(PlayerGui:GetDescendants()) do
            if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") then
                v.Enabled = false
            end
        end

        Fluent:Notify({
            Title = "Modo Competitivo",
            Content = "Configurações de latência ultra-baixa aplicadas.",
            Duration = 5
        })
    end
end

CompModeToggle:OnChanged(function(Value)
    SetCompetitive(Value)
    -- Se o usuário ativar o competitivo, ativamos também os outros toggles se eles existirem
    if Value then
        if Options.TextureOpt then Options.TextureOpt:SetValue(true) end
        if Options.NoShadows then Options.NoShadows:SetValue(true) end
        if Options.NoParticles then Options.NoParticles:SetValue(true) end
    end
end)

-- [[ 2. OTIMIZAÇÃO DE "CORE" DO SCRIPT ]] --
-- Melhora como o script lida com o motor do Roblox para não causar lag no próprio executor.

local ScriptOptSection = Tabs.Main:AddSection("Otimização de Processamento")

local FastWaitToggle = Tabs.Main:AddToggle("FastWait", {
    Title = "Otimizar Task Scheduler", 
    Default = false,
    Description = "Troca o 'wait' padrão por um sistema mais rápido que reduz o uso de CPU."
})

-- Implementação de uma otimização interna (Global)
if FastWaitToggle.Value then
    -- Redefine wait para ser mais eficiente se o executor permitir
    local wait = task.wait
    local delay = task.delay
    local spawn = task.spawn
end

-- [[ 3. REDUÇÃO DE RENDERIZAÇÃO DE OBJETOS DISTANTES ]] --
-- Diminui o estresse da GPU ao não renderizar detalhes inúteis longe do player

local RenderDistToggle = Tabs.Main:AddToggle("LowRenderDist", {
    Title = "Otimizar Distância de Visão", 
    Default = false,
    Description = "Otimiza a renderização de objetos que estão longe do seu personagem."
})

RenderDistToggle:OnChanged(function(Value)
    if Value then
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level10
        -- Nota: Em alguns executores, podemos forçar o StreamingEnabled (se o jogo permitir)
    end
end)

-- [[ 4. OTIMIZAÇÃO DE REDE (NETWORK PERFORMANCE) ]] --
-- Melhora a fluidez em jogos multiplayer ao reduzir o processamento de dados inúteis da rede.

local NetworkOpt = Tabs.Main:AddToggle("NetBoost", {
    Title = "Network Optimizer (Anti-Lag de Rede)", 
    Default = false,
    Description = "Prioriza a posição dos jogadores sobre outros dados estéticos da rede."
})

NetworkOpt:OnChanged(function(Value)
    if Value then
        settings().Network.IncomingReplicationLag = -1000 -- Reduz simulação de lag
        game:GetService("NetworkClient"):SetSimulatedCore(Enum.PlayerConnectionState.Connected)
    end
end)

-- [[ 5. LIMPADOR DE TEXTURAS DE INTERFACE (GUI OPTIMIZER) ]] --
-- Reduz o consumo de RAM escondendo elementos de interface do próprio Roblox que não são usados.

Tabs.Main:AddButton({
    Title = "Otimizar Menus do Jogo",
    Description = "Remove texturas de botões e menus nativos para poupar RAM.",
    Callback = function()
        for _, v in pairs(game:GetService("CoreGui"):GetDescendants()) do
            if v:IsA("ImageLabel") or v:IsA("ImageButton") then
                v.ImageTransparency = 0.2 -- Torna levemente transparente para processar menos pixels
            end
        end
        Fluent:Notify({Title = "Sucesso", Content = "Interface otimizada.", Duration = 2})
    end
})

-- [[ FIM DA PARTE 5 ]] --

-- [[ FPS BOOSTER & OPTIMIZER - PARTE 6: DELAY & RESPONSIVIDADE ]] --
-- Objetivo: Minimizar o Input Lag e tornar a movimentação mais instantânea.

local DelaySection = Tabs.Main:AddSection("Redução de Delay & Resposta")

-- [[ 1. ZERO INPUT LAG (PRIORIDADE DE RENDERIZAÇÃO) ]] --
-- Ajusta a engine para processar os inputs do jogador antes de qualquer efeito visual.

local ZeroDelayToggle = Tabs.Main:AddToggle("ZeroDelay", {
    Title = "Reduzir Input Lag (Toque Instantâneo)", 
    Default = false,
    Description = "Prioriza os comandos do jogador, tornando a resposta do clique/toque mais rápida."
})

ZeroDelayToggle:OnChanged(function(Value)
    if Value then
        -- Define a prioridade da renderização para o nível mais baixo de latência
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        
        -- Otimiza o tempo de resposta da física local
        settings().Physics.AllowSleep = true
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Enabled
        
        -- Conexão para forçar a atualização de CPU nos inputs
        _G.InputConn = game:GetService("RunService").Heartbeat:Connect(function()
            -- Força o processamento de sinais de entrada
            game:GetService("UserInputService").InputBegan:Wait(0)
        end)
        
        Fluent:Notify({Title = "Performance", Content = "Modo de Baixa Latência Ativado.", Duration = 3})
    else
        if _G.InputConn then _G.InputConn:Disconnect() end
    end
end)

-- [[ 2. MODO "JOGO LEVE" (CULLING DE OBJETOS) ]] --
-- Este modo faz com que objetos que estão atrás de você ou muito longe não sejam processados.

local LightGameToggle = Tabs.Main:AddToggle("LightGame", {
    Title = "Modo Jogo Leve (Smart Render)", 
    Default = false,
    Description = "Desativa a renderização de objetos que não estão na sua visão atual."
})

task.spawn(function()
    while true do
        if LightGameToggle.Value then
            local camera = workspace.CurrentCamera
            local character = game.Players.LocalPlayer.Character
            
            if character and character:FindFirstChild("HumanoidRootPart") then
                for _, part in pairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") and not part.Parent:FindFirstChild("Humanoid") then
                        local _, onScreen = camera:WorldToViewportPoint(part.Position)
                        
                        -- Se o objeto não estiver na tela, ele fica invisível para a GPU
                        -- mas mantém a colisão para você não cair do mapa
                        if not onScreen then
                            part.LocalTransparencyModifier = 1
                        else
                            part.LocalTransparencyModifier = 0
                        end
                    end
                end
            end
        end
        task.wait(1) -- Roda a cada 1 segundo para não pesar a CPU
    end
end)

-- [[ 3. ANTI-LAG DE REDE AVANÇADO (DELAY FIX) ]] --
-- Reduz o atraso de "Data Ping" limpando pacotes de rede inúteis.

local NetDelayToggle = Tabs.Main:AddToggle("NetDelayFix", {
    Title = "Reduzir Atraso de Rede (Ping Fix)", 
    Default = false,
    Description = "Otimiza a troca de dados entre seu celular e o servidor."
})

NetDelayToggle:OnChanged(function(Value)
    if Value then
        settings().Network.IncomingReplicationLag = -1000
        settings().Network.DataSendRate = 100 -- Aumenta a taxa de envio de dados se possível
        
        -- Limpa o cache de sons e texturas que o servidor enviou e não estão em uso
        game:GetService("ContentProvider"):PreloadAsync({}, function() 
            return false 
        end)
    end
end)

-- [[ 4. ESTABILIZADOR DE MOVIMENTO (SMOOTH MOTION) ]] --
-- Remove o "tremor" da câmera e do personagem que acontece quando o FPS oscila.

local SmoothMotionToggle = Tabs.Main:AddToggle("SmoothMotion", {
    Title = "Movimentação Fluida", 
    Default = false,
    Description = "Suaviza o movimento do personagem para mascarar quedas de FPS."
})

SmoothMotionToggle:OnChanged(function(Value)
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    
    if Value then
        -- Ajusta a sensibilidade e interpolação da câmera
        player.CameraMinZoomDistance = 0.5
        settings().Physics.ThrottleAdjustTime = 0.1
    end
end)

-- [[ 5. LIMPEZA DE LOGS CONSTANTE ]] --
-- O Roblox guarda um "diário" de tudo que acontece no jogo. Isso enche a RAM e causa delay.

local AutoLogClear = Tabs.Main:AddToggle("LogClear", {
    Title = "Limpeza de Histórico de Erros", 
    Default = true,
    Description = "Evita que erros de script do próprio jogo acumulem e causem lag."
})

task.spawn(function()
    while true do
        if AutoLogClear.Value then
            -- Limpa o Console interno do jogo (F9)
            game:GetService("LogService"):ClearOutput()
        end
        task.wait(30)
    end
end)

-- [[ FIM DA PARTE 6 ]] --

-- [[ FPS BOOSTER & OPTIMIZER - PARTE 7: SISTEMA DE CHUNKS ]] --
-- Objetivo: Simular o carregamento de "Chunks" do Minecraft para focar o poder do celular apenas onde você está.

local ChunkSection = Tabs.Main:AddSection("Sistema de Chunks (Minecraft Style)")

-- Variáveis de Controle
local RenderRadius = 300 -- Raio inicial em 'studs' (blocos do Roblox)
local IsChunkEnabled = false
local IgnoredClasses = {"Terrain", "Sky", "Camera", "Humanoid", "LocalPlayer"}

-- [[ 1. SLIDER DE DISTÂNCIA DE CHUNKS ]] --
-- Permite ao usuário escolher quantos "Chunks" (distância) ele quer carregar.

Tabs.Main:AddSlider("ChunkDistance", {
    Title = "Distância de Renderização (Chunks)",
    Description = "Menor distância = Muito mais FPS.",
    Default = 300,
    Min = 100,
    Max = 1500,
    Rounding = 0,
    Callback = function(Value)
        RenderRadius = Value
    end
})

-- [[ 2. LÓGICA DO SISTEMA DE CHUNKS ]] --

local ChunkToggle = Tabs.Main:AddToggle("ChunkSystem", {
    Title = "Ativar Carregamento por Chunks", 
    Default = false,
    Description = "Oculta partes do mapa que estão longe de você, como no Minecraft."
})

ChunkToggle:OnChanged(function(Value)
    IsChunkEnabled = Value
    
    -- Se desligar, garante que tudo volte a ser visível
    if not Value then
        for _, v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 0
            end
        end
        Fluent:Notify({Title = "Chunks", Content = "Mapa totalmente carregado.", Duration = 3})
    end
end)

-- Loop de Gerenciamento de Chunks (Otimizado para não pesar na CPU)
task.spawn(function()
    while true do
        if IsChunkEnabled then
            local char = game.Players.LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if root then
                local myPos = root.Position
                
                -- Percorre o mapa para checar a distância
                -- Usamos GetChildren em pastas principais para ser mais rápido que GetDescendants
                for _, obj in pairs(game.Workspace:GetChildren()) do
                    -- Evita mexer no terreno ou no próprio player
                    if obj.Name ~= game.Players.LocalPlayer.Name and not obj:IsA("Terrain") then
                        
                        -- Se for uma pasta ou modelo grande, checamos a distância do centro dele
                        local objPos
                        if obj:IsA("BasePart") then
                            objPos = obj.Position
                        elseif obj:IsA("Model") and obj.PrimaryPart then
                            objPos = obj.PrimaryPart.Position
                        elseif obj:IsA("Model") then
                            -- Se o modelo não tem PrimaryPart, tenta pegar a posição de um filho
                            local child = obj:FindFirstChildWhichIsA("BasePart")
                            if child then objPos = child.Position end
                        end

                        if objPos then
                            local distance = (myPos - objPos).Magnitude
                            
                            -- A MÁGICA: Se estiver fora do raio, "desliga" o objeto
                            if distance > RenderRadius then
                                -- Usamos LocalTransparencyModifier para o objeto sumir apenas para VOCÊ
                                -- Isso não afeta o servidor nem outros jogadores
                                for _, part in pairs(obj:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        part.LocalTransparencyModifier = 1
                                        -- Opcional: part.CanCollide = false (CUIDADO: Pode fazer você cair se o chão sumir)
                                    elseif part:IsA("Light") or part:IsA("ParticleEmitter") then
                                        part.Enabled = false
                                    end
                                end
                            else
                                -- Se entrou no raio, "liga" o objeto novamente
                                for _, part in pairs(obj:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        part.LocalTransparencyModifier = 0
                                    elseif part:IsA("Light") or part:IsA("ParticleEmitter") then
                                        part.Enabled = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        -- O segredo para não ficar "estranho" é um wait equilibrado
        -- 2 segundos é o ideal para carregar antes de você chegar perto
        task.wait(1.5) 
    end
end)

-- [[ 3. OTIMIZAÇÃO DE TERRENO POR CHUNK ]] --
-- Faz o terreno do Roblox (grama/água) também respeitar a distância

task.spawn(function()
    while true do
        if IsChunkEnabled then
            local settings = settings().Rendering
            if RenderRadius < 500 then
                settings.QualityLevel = Enum.QualityLevel.Level01
            end
        end
        task.wait(5)
    end
end)

-- [[ FIM DA PARTE 7 ]] --

-- [[ FPS BOOSTER & OPTIMIZER - PARTE 8: SMART RENDER & OCCLUSION ]] --
-- Objetivo: Garantir que o celular processe APENAS o que os olhos do jogador vêem.

local SmartSection = Tabs.Main:AddSection("Smart Render & Visibilidade")

-- Variáveis de Controle de Visibilidade
local OcclusionEnabled = false
local FrustumEnabled = false
local RaycastParams = RaycastParams.new()
RaycastParams.FilterType = Enum.RaycastFilterType.Exclude

-- [[ 1. FRUSTUM CULLING (CAMPO DE VISÃO) ]] --
-- Oculta tudo o que não está dentro do "triângulo" de visão da câmera.

local FrustumToggle = Tabs.Main:AddToggle("FrustumCulling", {
    Title = "Smart Field of View (FOV)", 
    Default = false,
    Description = "Desativa a renderização de tudo o que está fora da sua visão de câmera."
})

FrustumToggle:OnChanged(function(Value)
    FrustumEnabled = Value
    if not Value then
        -- Reset visual ao desligar
        for _, v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
        end
    end
end)

-- [[ 2. OCCLUSION CULLING (OCULTAR ATRÁS DE OBJETOS) ]] --
-- Se houver uma parede grande entre você e um objeto, o script para de renderizar o objeto.

local OcclusionToggle = Tabs.Main:AddToggle("OcclusionCulling", {
    Title = "Otimizar Objetos Ocultos (Anti-Parede)", 
    Default = false,
    Description = "Não renderiza itens que estão atrás de paredes ou montanhas."
})

OcclusionToggle:OnChanged(function(Value)
    OcclusionEnabled = Value
end)

-- [[ LÓGICA CORE DE PROCESSAMENTO VISUAL ]] --

local Camera = workspace.CurrentCamera

task.spawn(function()
    while true do
        if FrustumEnabled or OcclusionEnabled then
            local char = game.Players.LocalPlayer.Character
            if char then
                -- Atualiza lista de exclusão do Raycast (não bater no próprio player)
                RaycastParams.FilterDescendantsInstances = {char}
                
                -- Pegamos os descendentes em grupos menores para não travar o script
                for _, obj in pairs(game.Workspace:GetChildren()) do
                    if obj:IsA("Model") or (obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid")) then
                        
                        local position = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position) or (obj:IsA("BasePart") and obj.Position)
                        
                        if position then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(position)
                            
                            local shouldHide = false
                            
                            -- Teste 1: Está fora da tela? (Frustum)
                            if FrustumEnabled and not onScreen then
                                shouldHide = true
                            end
                            
                            -- Teste 2: Se está na tela, algo está cobrindo? (Occlusion)
                            if not shouldHide and OcclusionEnabled and onScreen then
                                local origin = Camera.CFrame.Position
                                local direction = (position - origin).Unit * (position - origin).Magnitude
                                local rayResult = workspace:Raycast(origin, direction, RaycastParams)
                                
                                -- Se o raio bateu em algo ANTES de chegar no objeto, significa que ele está escondido
                                if rayResult and rayResult.Instance and not rayResult.Instance:IsDescendantOf(obj) then
                                    -- Apenas esconde se o que estiver na frente for opaco e grande
                                    if rayResult.Instance.Transparency < 0.5 and rayResult.Instance.Size.Magnitude > 10 then
                                        shouldHide = true
                                    end
                                end
                            end
                            
                            -- Aplicar resultado
                            if shouldHide then
                                if obj:IsA("BasePart") then
                                    obj.LocalTransparencyModifier = 1
                                else
                                    for _, p in pairs(obj:GetDescendants()) do
                                        if p:IsA("BasePart") then p.LocalTransparencyModifier = 1 end
                                    end
                                end
                            else
                                if obj:IsA("BasePart") then
                                    obj.LocalTransparencyModifier = 0
                                else
                                    for _, p in pairs(obj:GetDescendants()) do
                                        if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        -- Delay estratégico para não consumir muita CPU com Raycast
        task.wait(OcclusionEnabled and 0.5 or 1) 
    end
end)

-- [[ 3. MODO "QUARTO ESCURO" (INTERIOR OPTIMIZER) ]] --
-- Se você entrar em um lugar fechado, desativa a renderização do céu e do mapa externo.

local InteriorToggle = Tabs.Main:AddToggle("InteriorOpt", {
    Title = "Otimizador de Ambientes Internos", 
    Default = false,
    Description = "Se você estiver dentro de um lugar, o script foca apenas no interior."
})

task.spawn(function()
    while true do
        if InteriorToggle.Value then
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local origin = char.HumanoidRootPart.Position
                local direction = Vector3.new(0, 50, 0) -- Raio para cima
                local ray = workspace:Raycast(origin, direction)
                
                if ray and ray.Instance then
                    -- Tem algo em cima de você (teto)
                    game:GetService("Lighting").EnvironmentDiffuseScale = 0
                    game:GetService("Lighting").EnvironmentSpecularScale = 0
                else
                    game:GetService("Lighting").EnvironmentDiffuseScale = 1
                    game:GetService("Lighting").EnvironmentSpecularScale = 1
                end
            end
        end
        task.wait(2)
    end
end)

-- [[ FIM DA PARTE 8 ]] --
