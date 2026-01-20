-- FPS Booster Mobile | Otimização Avançada para Dispositivos Fracos
-- Compatível com Delta, Fluxus e outros executores

local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local workspace = game:GetService("Workspace")

-- Variáveis de Controle
local fpsCounterEnabled = false
local graphicsReduced = false
local particlesReduced = false
local animationsReduced = false
local competitiveModeEnabled = false
local extremeFluidity = false
local physicsOptimized = false
local aimEnabled = false

-- Backup de Configurações Originais
local originalSettings = {
    graphics = {},
    lighting = {},
    particles = {}
}

-- Guardar configurações originais
local function backupOriginalSettings()
    originalSettings.graphics.QualityLevel = settings():GetService("RenderSettings").QualityLevel
    originalSettings.lighting.GlobalShadows = lighting.GlobalShadows
    originalSettings.lighting.Brightness = lighting.Brightness
    originalSettings.lighting.Technology = lighting.Technology
end

backupOriginalSettings()

-- ============================================
-- FPS COUNTER
-- ============================================
local fpsLabel
local function createFPSCounter()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FPSCounter"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0, 120, 0, 40)
    fpsLabel.Position = UDim2.new(0, 10, 1, -120)
    fpsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    fpsLabel.BackgroundTransparency = 0.3
    fpsLabel.BorderSizePixel = 0
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 18
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    fpsLabel.Text = "FPS: 60"
    fpsLabel.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = fpsLabel
    
    screenGui.Parent = player.PlayerGui
end

local lastUpdate = tick()
local frameCount = 0
local currentFPS = 60

local function updateFPSCounter()
    if not fpsCounterEnabled then return end
    
    frameCount = frameCount + 1
    local now = tick()
    
    if now - lastUpdate >= 0.5 then
        currentFPS = math.floor(frameCount / (now - lastUpdate))
        if fpsLabel then
            fpsLabel.Text = "FPS: " .. currentFPS
            
            if currentFPS >= 55 then
                fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            elseif currentFPS >= 30 then
                fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            else
                fpsLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        end
        frameCount = 0
        lastUpdate = now
    end
end

-- ============================================
-- REDUÇÃO GRÁFICA INTELIGENTE
-- ============================================
local function reduceGraphics(enable)
    local renderSettings = settings():GetService("RenderSettings")
    
    if enable then
        renderSettings.QualityLevel = Enum.QualityLevel.Level01
        lighting.GlobalShadows = false
        lighting.Brightness = 2
        
        for _, v in pairs(lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or 
               v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or
               v:IsA("DepthOfFieldEffect") then
                v.Enabled = false
            end
        end
        
        lighting.EnvironmentDiffuseScale = 0
        lighting.EnvironmentSpecularScale = 0
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 0.9
            elseif obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            end
        end
    else
        renderSettings.QualityLevel = originalSettings.graphics.QualityLevel
        lighting.GlobalShadows = originalSettings.lighting.GlobalShadows
        lighting.Brightness = originalSettings.lighting.Brightness
    end
    
    graphicsReduced = enable
end

-- ============================================
-- REDUÇÃO DE PARTÍCULAS
-- ============================================
local particleBackup = {}

local function reduceParticles(enable)
    if enable then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or 
               obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                if not particleBackup[obj] then
                    particleBackup[obj] = obj.Enabled
                end
                obj.Enabled = false
            end
        end
    else
        for obj, wasEnabled in pairs(particleBackup) do
            if obj and obj.Parent then
                obj.Enabled = wasEnabled
            end
        end
        particleBackup = {}
    end
    
    particlesReduced = enable
end

-- ============================================
-- REDUÇÃO DE ANIMAÇÕES
-- ============================================
local function reduceAnimations(enable)
    if enable then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                        if not track.Name:match("Walk") and 
                           not track.Name:match("Run") and
                           not track.Name:match("Idle") then
                            track:Stop()
                        end
                    end
                end
            end
        end
    end
    
    animationsReduced = enable
end

-- ============================================
-- MODO COMPETITIVO
-- ============================================
local function toggleCompetitiveMode(enable, withAim)
    if enable then
        reduceGraphics(true)
        reduceParticles(true)
        reduceAnimations(true)
        
        local renderSettings = settings():GetService("RenderSettings")
        renderSettings.QualityLevel = Enum.QualityLevel.Level01
        
        workspace.StreamingEnabled = false
        
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CastShadow = false
            elseif v:IsA("Beam") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
        
        if withAim and player.Character then
            local camera = workspace.CurrentCamera
            camera.FieldOfView = 70
        end
        
    else
        reduceGraphics(false)
        reduceParticles(false)
        reduceAnimations(false)
    end
    
    competitiveModeEnabled = enable
    aimEnabled = withAim
end

-- ============================================
-- MODO FLUIDEZ EXTREMA
-- ============================================
local fluidityConnection

local function toggleExtremeFluidity(enable)
    if enable then
        if fluidityConnection then fluidityConnection:Disconnect() end
        
        fluidityConnection = runService.Heartbeat:Connect(function()
            runService:Set3dRenderingEnabled(true)
        end)
        
        settings():GetService("RenderSettings").EditQualityLevel = Enum.QualityLevel.Level01
        
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("MeshPart") or v:IsA("UnionOperation") then
                v.RenderFidelity = Enum.RenderFidelity.Performance
            end
        end
        
    else
        if fluidityConnection then
            fluidityConnection:Disconnect()
            fluidityConnection = nil
        end
    end
    
    extremeFluidity = enable
end

-- ============================================
-- OTIMIZAÇÃO DE FÍSICA
-- ============================================
local function optimizePhysics(enable)
    if enable then
        workspace.StreamingEnabled = true
        workspace.StreamingMinRadius = 32
        workspace.StreamingTargetRadius = 128
        
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                if not v:FindFirstAncestorOfClass("Model") or 
                   v:FindFirstAncestorOfClass("Model") ~= player.Character then
                    v.CanCollide = false
                end
            end
        end
        
        settings():GetService("RenderSettings").EditQualityLevel = Enum.QualityLevel.Level01
        
    end
    
    physicsOptimized = enable
end

-- ============================================
-- RAYFIELD UI
-- ============================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "FPS Booster Mobile 📱",
    LoadingTitle = "Otimização Avançada",
    LoadingSubtitle = "by Community",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- ============================================
-- ABA PRINCIPAL
-- ============================================
local MainTab = Window:CreateTab("🏠 Principal", nil)
local MainSection = MainTab:CreateSection("Funções Principais")

local FPSToggle = MainTab:CreateToggle({
    Name = "📊 Contador de FPS",
    CurrentValue = false,
    Flag = "FPSCounter",
    Callback = function(Value)
        fpsCounterEnabled = Value
        if Value then
            if not fpsLabel then
                createFPSCounter()
            end
            fpsLabel.Visible = true
        else
            if fpsLabel then
                fpsLabel.Visible = false
            end
        end
    end
})

MainTab:CreateToggle({
    Name = "🎨 Redução Gráfica",
    CurrentValue = false,
    Flag = "GraphicsReduction",
    Callback = function(Value)
        reduceGraphics(Value)
    end
})

MainTab:CreateToggle({
    Name = "✨ Redução de Partículas",
    CurrentValue = false,
    Flag = "ParticlesReduction",
    Callback = function(Value)
        reduceParticles(Value)
    end
})

MainTab:CreateToggle({
    Name = "🎭 Redução de Animações",
    CurrentValue = false,
    Flag = "AnimationsReduction",
    Callback = function(Value)
        reduceAnimations(Value)
    end
})

-- ============================================
-- ABA COMPETITIVO
-- ============================================
local CompTab = Window:CreateTab("⚔️ Competitivo", nil)
local CompSection = CompTab:CreateSection("Modo Performance Máxima")

CompTab:CreateToggle({
    Name = "🎯 Modo Competitivo (COM Mira)",
    CurrentValue = false,
    Flag = "CompetitiveWithAim",
    Callback = function(Value)
        toggleCompetitiveMode(Value, true)
    end
})

CompTab:CreateToggle({
    Name = "⚡ Modo Competitivo (SEM Mira)",
    CurrentValue = false,
    Flag = "CompetitiveNoAim",
    Callback = function(Value)
        toggleCompetitiveMode(Value, false)
    end
})

CompTab:CreateParagraph({
    Title = "ℹ️ Informação",
    Content = "Modo competitivo ativa TODAS as otimizações simultaneamente para máxima performance."
})

-- ============================================
-- ABA AVANÇADO
-- ============================================
local AdvTab = Window:CreateTab("🔧 Avançado", nil)
local AdvSection = AdvTab:CreateSection("Otimizações Extras")

AdvTab:CreateToggle({
    Name = "💨 Fluidez Extrema",
    CurrentValue = false,
    Flag = "ExtremeFluidity",
    Callback = function(Value)
        toggleExtremeFluidity(Value)
    end
})

AdvTab:CreateToggle({
    Name = "⚙️ Otimizar Física",
    CurrentValue = false,
    Flag = "PhysicsOptimization",
    Callback = function(Value)
        optimizePhysics(Value)
    end
})

AdvTab:CreateParagraph({
    Title = "⚠️ Atenção",
    Content = "Essas funções são mais agressivas e podem causar bugs visuais em alguns jogos."
})

-- ============================================
-- ABA INFO
-- ============================================
local InfoTab = Window:CreateTab("ℹ️ Informações", nil)

InfoTab:CreateParagraph({
    Title = "📱 FPS Booster Mobile",
    Content = "Script de otimização desenvolvido para dispositivos fracos. Todas as funções começam DESLIGADAS. Configure conforme sua necessidade!"
})

InfoTab:CreateParagraph({
    Title = "💡 Dicas de Uso",
    Content = "1. Ative o Contador FPS primeiro\n2. Teste cada função individualmente\n3. Para máxima performance, use Modo Competitivo\n4. Funções podem ser combinadas"
})

InfoTab:CreateButton({
    Name = "🔄 Resetar Todas Configurações",
    Callback = function()
        reduceGraphics(false)
        reduceParticles(false)
        reduceAnimations(false)
        toggleCompetitiveMode(false, false)
        toggleExtremeFluidity(false)
        optimizePhysics(false)
        
        Rayfield:Notify({
            Title = "✅ Sucesso",
            Content = "Todas as configurações foram resetadas!",
            Duration = 3,
            Image = nil
        })
    end
})

-- ============================================
-- LOOP PRINCIPAL
-- ============================================
runService.RenderStepped:Connect(function()
    updateFPSCounter()
end)

-- ============================================
-- NOTIFICAÇÃO INICIAL
-- ============================================
Rayfield:Notify({
    Title = "✅ FPS Booster Carregado",
    Content = "Script pronto para uso! Configure nas abas.",
    Duration = 5,
    Image = nil
})

print("FPS Booster Mobile carregado com sucesso!")
print("Desenvolvido para a comunidade mobile")
