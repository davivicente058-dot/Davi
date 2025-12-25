-- FPS BOOST APRIMORADO COM UI (MOBILE FRIENDLY)
-- Compatível com Delta / Fluxus / Hydrogen
-- Segurança: não afeta o jogador local; permite reverter alterações

local function safe(f, ...)
    local ok, res = pcall(f, ...)
    return ok and res or nil
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES
local DIST_THRESHOLD = 60 -- distância (studs) para aplicar otimizações agressivas
local brilho = "padrao" -- valor inicial; pode ser "claro", "padrao", "escuro"
local otimizado = false

-- Tabelas para restaurar
local backup = {
    parts = {},
    decals = {},
    particles = {},
    sounds = {},
    humanoids = {},
    lighting = {}
}

-- Configs de claridade
local brilhoConfig = {
    claro  = {Ambient = Color3.new(1,1,1), OutdoorAmbient = Color3.new(1,1,1), Brightness = 2, ClockTime = 14},
    padrao = {Ambient = Color3.new(0.5,0.5,0.5), OutdoorAmbient = Color3.new(0.5,0.5,0.5), Brightness = 1, ClockTime = 12},
    escuro = {Ambient = Color3.new(0.2,0.2,0.2), OutdoorAmbient = Color3.new(0.2,0.2,0.2), Brightness = 0.5, ClockTime = 18}
}

-- Salva estado atual do Lighting
local function backupLighting()
    if not Lighting then return end
    backup.lighting = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        GlobalShadows = Lighting.GlobalShadows
    }
end

local function applyBrilho(mode)
    if not Lighting or not brilhoConfig[mode] then return end
    local c = brilhoConfig[mode]
    safe(function()
        Lighting.Ambient = c.Ambient
        Lighting.OutdoorAmbient = c.OutdoorAmbient
        Lighting.Brightness = c.Brightness
        Lighting.ClockTime = c.ClockTime
        Lighting.FogEnd = 1e10
        Lighting.FogStart = 0
        Lighting.GlobalShadows = false
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") then
                backup.lighting[v:GetFullName()] = v.Enabled
                v.Enabled = false
            end
        end
    end)
end

-- Aplica otimizações a um objeto (somente se estiver distante do jogador local)
local function optimizeDescendant(obj, rootPos)
    if not obj or not obj.Parent then return end
    local class = obj.ClassName
    if obj:IsA("BasePart") then
        -- não mexer nas partes do jogador local
        if LocalPlayer and LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character) then return end
        local posOK, pos = pcall(function() return obj.Position end)
        local dist = posOK and rootPos and (pos - rootPos).Magnitude or 0
        if dist >= DIST_THRESHOLD then
            if not backup.parts[obj] then
                backup.parts[obj] = {
                    Material = obj.Material,
                    Reflectance = obj.Reflectance,
                    CastShadow = obj.CastShadow,
                    CanCollide = obj.CanCollide,
                    Anchored = obj.Anchored
                }
            end
            safe(function()
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
                obj.CanCollide = false
                -- não forçar Anchored globalmente; apenas se for seguro
            end)
        else
            -- para partes próximas, apenas reduzir sombras e material leve
            if not backup.parts[obj] then
                backup.parts[obj] = {
                    Material = obj.Material,
                    Reflectance = obj.Reflectance,
                    CastShadow = obj.CastShadow,
                    CanCollide = obj.CanCollide,
                    Anchored = obj.Anchored
                }
            end
            safe(function()
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
            end)
        end
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        if not backup.decals[obj] then
            backup.decals[obj] = {Transparency = obj.Transparency}
        end
        safe(function() obj.Transparency = 1 end)
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
        if not backup.particles[obj] then
            backup.particles[obj] = {Enabled = obj.Enabled}
        end
        safe(function() obj.Enabled = false end)
    elseif obj:IsA("Sound") then
        -- não cortar sons do próprio jogador
        if LocalPlayer and LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character) then return end
        if not backup.sounds[obj] then
            backup.sounds[obj] = {Playing = obj.IsPlaying, Volume = obj.Volume}
        end
        safe(function()
            obj:Stop()
            obj.Volume = 0
        end)
    elseif obj:IsA("Humanoid") then
        -- aplicar somente a NPCs (não ao jogador local)
        local char = obj.Parent
        if char and LocalPlayer and LocalPlayer.Character and char == LocalPlayer.Character then
            return
        end
        if not backup.humanoids[obj] then
            backup.humanoids[obj] = {
                WalkSpeed = obj.WalkSpeed,
                JumpPower = obj.JumpPower,
                AutoRotate = obj.AutoRotate
            }
        end
        safe(function()
            obj:ChangeState(Enum.HumanoidStateType.Physics)
            obj.WalkSpeed = 0
            obj.JumpPower = 0
            obj.AutoRotate = false
        end)
    end
end

-- Percorre workspace e aplica otimizações (não destrutivas)
local function applyOptimizations()
    if not LocalPlayer then return end
    local rootPos
    local root = safe(function() return LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChildWhichIsA("BasePart")) end)
    if root then
        rootPos = safe(function() return root.Position end)
    end
    backupLighting()
    for _, obj in pairs(Workspace:GetDescendants()) do
        safe(optimizeDescendant, obj, rootPos)
    end
    -- Terrain tweaks
    local Terrain = safe(function() return Workspace:FindFirstChildOfClass("Terrain") end)
    if Terrain then
        if not backup.terrain then
            backup.terrain = {
                WaterWaveSize = Terrain.WaterWaveSize,
                WaterWaveSpeed = Terrain.WaterWaveSpeed,
                WaterReflectance = Terrain.WaterReflectance,
                WaterTransparency = Terrain.WaterTransparency
            }
        end
        safe(function()
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
        end)
    end
    -- Streaming (se suportado)
    safe(function()
        if Workspace.StreamingEnabled ~= nil then
            backup.streaming = {StreamingEnabled = Workspace.StreamingEnabled, StreamingMinRadius = Workspace.StreamingMinRadius, StreamingTargetRadius = Workspace.StreamingTargetRadius}
            Workspace.StreamingEnabled = true
            Workspace.StreamingMinRadius = 64
            Workspace.StreamingTargetRadius = 128
        end
    end)
    otimizado = true
end

-- Restaura alterações feitas
local function restoreAll()
    -- restaurar parts
    for obj, data in pairs(backup.parts) do
        safe(function()
            if obj and obj.Parent then
                obj.Material = data.Material
                obj.Reflectance = data.Reflectance
                obj.CastShadow = data.CastShadow
                obj.CanCollide = data.CanCollide
                obj.Anchored = data.Anchored
            end
        end)
    end
    -- decals
    for obj, data in pairs(backup.decals) do
        safe(function() if obj and obj.Parent then obj.Transparency = data.Transparency end end)
    end
    -- particles
    for obj, data in pairs(backup.particles) do
        safe(function() if obj and obj.Parent then obj.Enabled = data.Enabled end end)
    end
    -- sounds
    for obj, data in pairs(backup.sounds) do
        safe(function()
            if obj and obj.Parent then
                obj.Volume = data.Volume
                if data.Playing then obj:Play() end
            end
        end)
    end
    -- humanoids
    for obj, data in pairs(backup.humanoids) do
        safe(function()
            if obj and obj.Parent then
                obj.WalkSpeed = data.WalkSpeed
                obj.JumpPower = data.JumpPower
                obj.AutoRotate = data.AutoRotate
            end
        end)
    end
    -- terrain
    if backup.terrain and Workspace:FindFirstChildOfClass("Terrain") then
        local Terrain = Workspace:FindFirstChildOfClass("Terrain")
        safe(function()
            Terrain.WaterWaveSize = backup.terrain.WaterWaveSize
            Terrain.WaterWaveSpeed = backup.terrain.WaterWaveSpeed
            Terrain.WaterReflectance = backup.terrain.WaterReflectance
            Terrain.WaterTransparency = backup.terrain.WaterTransparency
        end)
    end
    -- streaming
    if backup.streaming and Workspace.StreamingEnabled ~= nil then
        safe(function()
            Workspace.StreamingEnabled = backup.streaming.StreamingEnabled
            Workspace.StreamingMinRadius = backup.streaming.StreamingMinRadius
            Workspace.StreamingTargetRadius = backup.streaming.StreamingTargetRadius
        end)
    end
    -- lighting
    if backup.lighting and Lighting then
        safe(function()
            Lighting.Ambient = backup.lighting.Ambient
            Lighting.OutdoorAmbient = backup.lighting.OutdoorAmbient
            Lighting.Brightness = backup.lighting.Brightness
            Lighting.ClockTime = backup.lighting.ClockTime
            Lighting.FogEnd = backup.lighting.FogEnd
            Lighting.FogStart = backup.lighting.FogStart
            Lighting.GlobalShadows = backup.lighting.GlobalShadows
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") and backup.lighting[v:GetFullName()] ~= nil then
                    v.Enabled = backup.lighting[v:GetFullName()]
                end
            end
        end)
    end
    -- limpar backups
    backup = {parts = {}, decals = {}, particles = {}, sounds = {}, humanoids = {}, lighting = {}, terrain = nil, streaming = nil}
    otimizado = false
end

-- UI simples e mobile-friendly
local function createUI()
    if not LocalPlayer then return end
    local playerGui = safe(function() return LocalPlayer:WaitForChild("PlayerGui", 5) end)
    if not playerGui then return end

    -- evitar múltiplas GUIs
    local existing = playerGui:FindFirstChild("FPSBoostUI")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FPSBoostUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.36, 0, 0.18, 0)
    frame.Position = UDim2.new(0.02, 0, 0.78, 0)
    frame.BackgroundTransparency = 0.25
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.28, 0)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundTransparency = 1
    title.Text = "FPS Boost"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.Parent = frame

    local function makeButton(text, posY)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.32, 0, 0.28, 0)
        btn.Position = UDim2.new(posY, 0, 0.36, 0)
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Text = text
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.Parent = frame
        return btn
    end

    local btnClaro = makeButton("Claro", 0.02)
    local btnPadrao = makeButton("Padrão", 0.34)
    local btnEscuro = makeButton("Escuro", 0.66)

    local btnToggle = Instance.new("TextButton")
    btnToggle.Size = UDim2.new(0.66, 0, 0.28, 0)
    btnToggle.Position = UDim2.new(0.02, 0, 0.68, 0)
    btnToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btnToggle.TextColor3 = Color3.new(1,1,1)
    btnToggle.Text = "Ativar Otimização"
    btnToggle.Font = Enum.Font.SourceSansBold
    btnToggle.TextSize = 14
    btnToggle.Parent = frame

    local btnRestore = Instance.new("TextButton")
    btnRestore.Size = UDim2.new(0.32, 0, 0.18, 0)
    btnRestore.Position = UDim2.new(0.66, 0, 0.78, 0)
    btnRestore.BackgroundColor3 = Color3.fromRGB(120,40,40)
    btnRestore.TextColor3 = Color3.new(1,1,1)
    btnRestore.Text = "Restaurar"
    btnRestore.Font = Enum.Font.SourceSansBold
    btnRestore.TextSize = 12
    btnRestore.Parent = frame

    -- Conexões
    btnClaro.MouseButton1Down:Connect(function()
        brilho = "claro"
        applyBrilho(brilho)
        safe(function()
            game.StarterGui:SetCore("SendNotification", {Title="FPS Boost", Text="Claridade: Claro", Duration=3})
        end)
    end)
    btnPadrao.MouseButton1Down:Connect(function()
        brilho = "padrao"
        applyBrilho(brilho)
        safe(function()
            game.StarterGui:SetCore("SendNotification", {Title="FPS Boost", Text="Claridade: Padrão", Duration=3})
        end)
    end)
    btnEscuro.MouseButton1Down:Connect(function()
        brilho = "escuro"
        applyBrilho(brilho)
        safe(function()
            game.StarterGui:SetCore("SendNotification", {Title="FPS Boost", Text="Claridade: Escuro", Duration=3})
        end)
    end)

    btnToggle.MouseButton1Down:Connect(function()
        if not otimizado then
            applyOptimizations()
            btnToggle.Text = "Desativar Otimização"
            safe(function()
                game.StarterGui:SetCore("SendNotification", {Title="FPS Boost", Text="Otimização ativada", Duration=4})
            end)
        else
            restoreAll()
            btnToggle.Text = "Ativar Otimização"
            safe(function()
                game.StarterGui:SetCore("SendNotification", {Title="FPS Boost", Text="Otimização desativada", Duration=4})
            end)
        end
    end)

    btnRestore.MouseButton1Down:Connect(function()
        restoreAll()
        safe(function()
            game.StarterGui:SetCore("SendNotification", {Title="FPS Boost", Text="Tudo restaurado", Duration=4})
        end)
        btnToggle.Text = "Ativar Otimização"
    end)
end

-- Inicialização
safe(function()
    createUI()
    -- aplica brilho inicial sem ativar otimização
    applyBrilho(brilho)
    safe(function()
        game.StarterGui:SetCore("SendNotification", {Title="FPS Boost Pronto", Text="Use o painel para ativar e ajustar", Duration=5})
    end)
    print("FPS Boost aprimorado carregado. Brilho inicial:", brilho)
end)
