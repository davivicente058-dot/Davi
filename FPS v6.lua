-- FPS v6 - Ultra Polido e Estabilizado
-- Desenvolvido para executores móveis (Delta, Fluxus, Hydrogen)
-- Recursos: UI completa, otimização segura, estabilizador de FPS, contador real, ping, fonte Minecraft

-- Utilitários
local function safe(fn, ...)
    local ok, result = pcall(fn, ...)
    return ok and result or nil
end

local function notify(title, text, dur)
    dur = dur or 3
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = dur
        })
    end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

-- Variáveis de controle
local otimizado = false
local brilho = "padrao"
local backup = {
    parts = {},
    decals = {},
    particles = {},
    sounds = {},
    humanoids = {},
    lighting = {},
    terrain = nil,
    streaming = nil
}

-- Configurações de brilho
local brilhoConfig = {
    claro = {
        Ambient = Color3.new(1, 1, 1),
        OutdoorAmbient = Color3.new(1, 1, 1),
        Brightness = 2,
        ClockTime = 14
    },
    padrao = {
        Ambient = Color3.new(0.5, 0.5, 0.5),
        OutdoorAmbient = Color3.new(0.5, 0.5, 0.5),
        Brightness = 1,
        ClockTime = 12
    },
    escuro = {
        Ambient = Color3.new(0.2, 0.2, 0.2),
        OutdoorAmbient = Color3.new(0.2, 0.2, 0.2),
        Brightness = 0.5,
        ClockTime = 18
    }
}

-- Heurísticas
local function isPlayerDescendant(obj)
    return LocalPlayer and LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character)
end

local function isLikelyGameplayPart(part)
    if not part:IsA("BasePart") then return false end
    local name = (part.Name or ""):lower()
    if name:match("floor") or name:match("ground") or name:match("terrain") or name:match("wall") or name:match("platform") or name:match("base") then
        return true
    end
    local size = part.Size
    local volume = size.X * size.Y * size.Z
    return volume > 1000 or (part.Anchored and volume > 500)
end

local function isDecorativePart(part)
    if not part:IsA("BasePart") then return false end
    if isPlayerDescendant(part) then return false end
    if isLikelyGameplayPart(part) then return false end
    local size = part.Size
    return size.X > 0.5 or size.Y > 0.5 or size.Z > 0.5
end

-- Backup e restauração de iluminação
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
    local config = brilhoConfig[mode]
    if not config then return end
    safe(function()
        Lighting.Ambient = config.Ambient
        Lighting.OutdoorAmbient = config.OutdoorAmbient
        Lighting.Brightness = config.Brightness
        Lighting.ClockTime = config.ClockTime
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

-- Otimização de objetos
local function optimizeDescendant(obj, rootPos)
    safe(function()
        if obj:IsA("BasePart") and not isPlayerDescendant(obj) then
            local dist = (obj.Position - rootPos).Magnitude
            if isDecorativePart(obj) and dist > 60 then
                backup.parts[obj] = {
                    Material = obj.Material,
                    Reflectance = obj.Reflectance,
                    CastShadow = obj.CastShadow
                }
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
            end
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            backup.decals[obj] = obj.Transparency
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            backup.particles[obj] = obj.Enabled
            obj.Enabled = false
        elseif obj:IsA("Sound") and not isPlayerDescendant(obj) then
            backup.sounds[obj] = {Playing = obj.IsPlaying, Volume = obj.Volume}
            obj:Stop()
            obj.Volume = 0
        end
    end)
end

local function applyOptimizations()
    if not LocalPlayer then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local rootPos = root.Position

    backupLighting()

    for _, obj in pairs(Workspace:GetDescendants()) do
        optimizeDescendant(obj, rootPos)
    end

    otimizado = true
    notify("FPS Buster", "Otimização ativada", 2)
end

local function restoreAll()
    for obj, data in pairs(backup.parts) do
        safe(function()
            obj.Material = data.Material
            obj.Reflectance = data.Reflectance
            obj.CastShadow = data.CastShadow
        end)
    end
    for obj, val in pairs(backup.decals) do
        safe(function() obj.Transparency = val end)
    end
    for obj, val in pairs(backup.particles) do
        safe(function() obj.Enabled = val end)
    end
    for obj, data in pairs(backup.sounds) do
        safe(function()
            obj.Volume = data.Volume
            if data.Playing then obj:Play() end
        end)
    end
    if backup.lighting then
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
    otimizado = false
    notify("FPS Buster", "Restauração concluída", 2)
end

-- FPS real
local fpsLabel
local fpsEnabled = true
local fpsConnection
local frameTimes = {}
local FPS_WINDOW = 30

local function startFPSCounter()
    if fpsConnection then return end
    frameTimes = {}
    fpsConnection = RunService.RenderStepped:Connect(function(dt)
        if not fpsEnabled then return end
        table.insert(frameTimes, dt)
        if #frameTimes > FPS_WINDOW then table.remove(frameTimes, 1) end
        local sum = 0
        for _, t in ipairs(frameTimes) do sum = sum + t end
        local fps = (sum > 0) and (#frameTimes / sum) or 0
        if fpsLabel and fpsLabel.Parent then
            fpsLabel.Text = string.format("FPS: %d", math.floor(fps + 0.5))
        end
    end)
end

local function stopFPSCounter()
    if fpsConnection then fpsConnection:Disconnect(); fpsConnection = nil end
    if fpsLabel and fpsLabel.Parent then fpsLabel.Text = "FPS: --" end
end

-- Estabilizador
local TARGET_FPS = 60
local stabilizerConnection
local frameTimesStab = {}
local AUTO_SCALE_ENABLED = true

local function tryApplyExecutorFpsCap(target)
    local ok = pcall(function()
        if setfpscap then setfpscap(target) end
    end)
    return ok
end

local function startStabilizer()
    if stabilizerConnection then return end
    tryApplyExecutorFpsCap(TARGET_FPS)
    frameTimesStab = {}
    stabilizerConnection = RunService.RenderStepped:Connect(function(dt)
        table.insert(frameTimesStab, dt)
        if #frameTimesStab > FPS_WINDOW then table.remove(frameTimesStab, 1) end
        local sum = 0
        for _, t in ipairs(frameTimesStab) do sum = sum + t end
        local fps = (sum > 0) and (#frameTimesStab / sum) or 0
        if AUTO_SCALE_ENABLED and fps < (TARGET_FPS * 0.85) then
            pcall(function()
                if Workspace.StreamingEnabled ~= nil then
                    Workspace.StreamingTargetRadius = math.max(48, (Workspace.StreamingTargetRadius or 128) - 8)
                end
            end)
        end
    end)
end

local function stopStabilizer()
    if stabilizerConnection then stabilizerConnection:Disconnect(); stabilizerConnection = nil end
    frameTimesStab = {}
end

-- Fonte estilo Minecraft
local function applyMinecraftFont(root)
    if not root then return end
    for _, obj in pairs(root:GetDescendants()) do
        safe(function()
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                local ok = pcall(function() obj.Font = Enum.Font.Minecraft end)
                if not ok then obj.Font = Enum.Font.SourceSansBold end
            end
        end)
    end
end

-- UI
local function createUI()
    local playerGui = safe(function() return LocalPlayer:WaitForChild("PlayerGui", 6) end)
    if not playerGui then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FPSv6UI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.38, 0, 0.20, 0)
    frame.Position = UDim2.new(0.02, 0, 0.74, 0)
    frame.BackgroundTransparency = 0.25
    frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.20, 0)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundTransparency = 1
    title.Text = "FPS v6"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.Parent = frame

    local function makeButton(text, posX, posY, sizeX)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(sizeX or 0.30, 0, 0.26, 0)
        btn.Position = UDim2.new(posX, 0, posY, 0)
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Text = text
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.Parent = frame
        return btn
    end

    local btnClaro = makeButton("Claro", 0.02, 0.26)
    local btnPadrao = makeButton("Padrão", 0.34, 0.26)
    local btnEscuro = makeButton("Escuro", 0.66, 0.26)

    local btnToggle = makeButton("Ativar Otimização", 0.02, 0.56, 0.66)
    btnToggle.Font = Enum.Font.SourceSansBold

    local btnRestore = makeButton("Restaurar", 0.66, 0.56, 0.32)
    btnRestore.BackgroundColor3 = Color3.fromRGB(120,40,40)
    btnRestore.TextSize = 12

    local btnMin = Instance.new("TextButton")
    btnMin.Size = UDim2.new(0.12, 0, 0.20, 0)
    btnMin.Position = UDim2.new(0.88, 0, 0, 0)
    btnMin.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btnMin.TextColor3 = Color3.new(1,1,1)
    btnMin.Text = "—"
    btnMin.Font = Enum.Font.SourceSansBold
    btnMin.TextSize = 18
    btnMin.Parent = frame

    local minimized = false
    local function setMinimized(state)
        minimized = state
        for _, child in pairs(frame:GetChildren()) do
            if child ~= title and child ~= btnMin then child.Visible = not state end
        end
        frame.Size = state and UDim2.new(0.12,0,0.06,0) or UDim2.new(0.38,0,0.20,0)
        btnMin.Text = state and "+" or "—"
    end

    btnMin.MouseButton1Down:Connect(function() setMinimized(not minimized) end)

    -- FPS display
    fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0.6, 0, 0.18, 0)
    fpsLabel.Position = UDim2.new(0.02, 0, 0.02, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: --"
    fpsLabel.TextColor3 = Color3.new(1,1,1)
    fpsLabel.Font = Enum.Font.SourceSansBold
    fpsLabel.TextSize = 14
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Parent = frame

    -- Botões
    btnClaro.MouseButton1Down:Connect(function()
        brilho = "claro"
        applyBrilho(brilho)
        notify("FPS Buster", "Claridade: Claro", 2)
    end)
    btnPadrao.MouseButton1Down:Connect(function()
        brilho = "padrao"
        applyBrilho(brilho)
        notify("FPS Buster", "Claridade: Padrão", 2)
    end)
    btnEscuro.MouseButton1Down:Connect(function()
        brilho = "escuro"
        applyBrilho(brilho)
        notify("FPS Buster", "Claridade: Escuro", 2)
    end)

    btnToggle.MouseButton1Down:Connect(function()
        if not otimizado then
            applyOptimizations()
            btnToggle.Text = "Desativar Otimização"
        else
            restoreAll()
            btnToggle.Text = "Ativar Otimização"
        end
    end)

    btnRestore.MouseButton1Down:Connect(function()
        restoreAll()
        btnToggle.Text = "Ativar Otimização"
    end)

    -- Aplica fonte
    applyMinecraftFont(screenGui)
end

-- Inicialização segura
safe(function()
    local tries = 0
    while not LocalPlayer and tries < 8 do
        wait(0.5)
        LocalPlayer = Players.LocalPlayer
        tries += 1
    end
    if not LocalPlayer then
        notify("FPS Buster", "Local
