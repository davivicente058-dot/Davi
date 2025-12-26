-- FPS v5 ULTRA COMPLETA
-- Compatível com executores móveis (Delta / Fluxus / Hydrogen)
-- Recursos: UI minimizável, Claro/Padrão/Escuro, Toggle otimização, Restaurar,
-- Contador FPS real (toggle), Ping, Auto-scale, Fonte estilo Minecraft (fallback),
-- Backup/restauração segura, código organizado.

-- =========================
-- Utilitários e variáveis
-- =========================
local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok and res or nil
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

-- Configuráveis
local DIST_THRESHOLD = 60
local SMALL_PART_VOLUME = 1000
local MIN_PART_SIZE = 0.5
local brilho = "padrao"
local otimizado = false

-- Backups
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

-- Brilho
local brilhoConfig = {
    claro  = {Ambient = Color3.new(1,1,1), OutdoorAmbient = Color3.new(1,1,1), Brightness = 2, ClockTime = 14},
    padrao = {Ambient = Color3.new(0.5,0.5,0.5), OutdoorAmbient = Color3.new(0.5,0.5,0.5), Brightness = 1, ClockTime = 12},
    escuro = {Ambient = Color3.new(0.2,0.2,0.2), OutdoorAmbient = Color3.new(0.2,0.2,0.2), Brightness = 0.5, ClockTime = 18}
}

-- =========================
-- Heurísticas seguras
-- =========================
local function isPlayerDescendant(obj)
    return LocalPlayer and LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character)
end

local function isLikelyGameplayPart(part)
    if not part or not part:IsA("BasePart") then return false end
    local name = (part.Name or ""):lower()
    if name:match("floor") or name:match("ground") or name:match("terrain") or name:match("wall") or name:match("platform") or name:match("base") then
        return true
    end
    local size = part.Size
    local volume = size.X * size.Y * size.Z
    if volume > SMALL_PART_VOLUME then return true end
    if part.Anchored and volume > (SMALL_PART_VOLUME / 2) then return true end
    return false
end

local function isDecorativePart(part)
    if not part or not part:IsA("BasePart") then return false end
    if isPlayerDescendant(part) then return false end
    if isLikelyGameplayPart(part) then return false end
    local size = part.Size
    if size.X < MIN_PART_SIZE and size.Y < MIN_PART_SIZE and size.Z < MIN_PART_SIZE then return false end
    return true
end

-- =========================
-- Backup e restauração
-- =========================
local function backupPart(part)
    if not part or backup.parts[part] then return end
    backup.parts[part] = {
        Material = part.Material,
        Reflectance = part.Reflectance,
        CastShadow = part.CastShadow,
        CanCollide = part.CanCollide,
        Anchored = part.Anchored
    }
end

local function restorePart(part, data)
    if not part or not data then return end
    safe(function()
        if part.Parent then
            part.Material = data.Material
            part.Reflectance = data.Reflectance
            part.CastShadow = data.CastShadow
            part.CanCollide = data.CanCollide
            part.Anchored = data.Anchored
        end
    end)
end

-- =========================
-- Brilho
-- =========================
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

-- =========================
-- Otimizações equilibradas
-- =========================
local function optimizePart(part, rootPos)
    if not part or not part:IsA("BasePart") then return end
    if isPlayerDescendant(part) then return end
    local posOK, pos = pcall(function() return part.Position end)
    local dist = (posOK and rootPos) and (pos - rootPos).Magnitude or 0

    if isDecorativePart(part) and dist >= DIST_THRESHOLD then
        backupPart(part)
        safe(function()
            part.Material = Enum.Material.SmoothPlastic
            part.Reflectance = 0
            part.CastShadow = false
            if part.Size.X * part.Size.Y * part.Size.Z < SMALL_PART_VOLUME then
                part.CanCollide = false
            end
        end)
    else
        backupPart(part)
        safe(function()
            part.Material = Enum.Material.SmoothPlastic
            part.Reflectance = 0
            part.CastShadow = false
        end)
    end
end

local function optimizeDescendant(obj, rootPos)
    if not obj then return end
    safe(function()
        if obj:IsA("BasePart") then
            optimizePart(obj, rootPos)
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            if not backup.decals[obj] then backup.decals[obj] = {Transparency = obj.Transparency} end
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            if not backup.particles[obj] then backup.particles[obj] = {Enabled = obj.Enabled} end
            obj.Enabled = false
        elseif obj:IsA("Sound") then
            if not isPlayerDescendant(obj) then
                if not backup.sounds[obj] then backup.sounds[obj] = {Playing = obj.IsPlaying, Volume = obj.Volume} end
                obj:Stop()
                obj.Volume = 0
            end
        elseif obj:IsA("Humanoid") then
            local char = obj.Parent
            if char and LocalPlayer and LocalPlayer.Character and char == LocalPlayer.Character then return end
            if not backup.humanoids[obj] then
                backup.humanoids[obj] = {WalkSpeed = obj.WalkSpeed, JumpPower = obj.JumpPower, AutoRotate = obj.AutoRotate}
            end
            obj.WalkSpeed = 0
            obj.JumpPower = 0
            obj.AutoRotate = false
        end
    end)
end

local function applyOptimizations()
    if not LocalPlayer then return end
    local rootPart = safe(function()
        return LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChildWhichIsA("BasePart"))
    end)
    local rootPos = rootPart and safe(function() return rootPart.Position end) or nil

    backupLighting()
    for _, obj in pairs(Workspace:GetDescendants()) do
        optimizeDescendant(obj, rootPos)
    end

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

    safe(function()
        if Workspace.StreamingEnabled ~= nil then
            if not backup.streaming then
                backup.streaming = {StreamingEnabled = Workspace.StreamingEnabled, StreamingMinRadius = Workspace.StreamingMinRadius, StreamingTargetRadius = Workspace.StreamingTargetRadius}
            end
            Workspace.StreamingEnabled = true
            Workspace.StreamingMinRadius = 64
            Workspace.StreamingTargetRadius = 128
        end
    end)

    otimizado = true
end

-- =========================
-- Restauração completa
-- =========================
local function restoreAll()
    for part, data in pairs(backup.parts) do restorePart(part, data) end
    for obj, data in pairs(backup.decals) do safe(function() if obj and obj.Parent then obj.Transparency = data.Transparency end end) end
    for obj, data in pairs(backup.particles) do safe(function() if obj and obj.Parent then obj.Enabled = data.Enabled end end) end
    for obj, data in pairs(backup.sounds) do
        safe(function()
            if obj and obj.Parent then
                obj.Volume = data.Volume
                if data.Playing then obj:Play() end
            end
        end)
    end
    for obj, data in pairs(backup.humanoids) do
        safe(function()
            if obj and obj.Parent then
                obj.WalkSpeed = data.WalkSpeed
                obj.JumpPower = data.JumpPower
                obj.AutoRotate = data.AutoRotate
            end
        end)
    end
    if backup.terrain and Workspace:FindFirstChildOfClass("Terrain") then
        local Terrain = Workspace:FindFirstChildOfClass("Terrain")
        safe(function()
            Terrain.WaterWaveSize = backup.terrain.WaterWaveSize
            Terrain.WaterWaveSpeed = backup.terrain.WaterWaveSpeed
            Terrain.WaterReflectance = backup.terrain.WaterReflectance
            Terrain.WaterTransparency = backup.terrain.WaterTransparency
        end)
    end
    if backup.streaming and Workspace.StreamingEnabled ~= nil then
        safe(function()
            Workspace.StreamingEnabled = backup.streaming.StreamingEnabled
            Workspace.StreamingMinRadius = backup.streaming.StreamingMinRadius
            Workspace.StreamingTargetRadius = backup.streaming.StreamingTargetRadius
        end)
    end
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

    backup = {parts = {}, decals = {}, particles = {}, sounds = {}, humanoids = {}, lighting = {}, terrain = nil, streaming = nil}
    otimizado = false
end

-- =========================
-- CONTADOR DE FPS REAL E PING
-- =========================
local fpsEnabled = true
local fpsConnection = nil
local fpsLabel = nil
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
        local fps = 0
        if sum > 0 then fps = #frameTimes / sum end
        if fpsLabel and fpsLabel.Parent then fpsLabel.Text = string.format("FPS: %d", math.floor(fps + 0.5)) end
    end)
end

local function stopFPSCounter()
    if fpsConnection then fpsConnection:Disconnect(); fpsConnection = nil end
    if fpsLabel and fpsLabel.Parent then fpsLabel.Text = "FPS: --" end
end

local function getPingMs()
    local ok, ping = pcall(function()
        local net = Stats:FindFirstChild("Network")
        if net and net:FindFirstChild("ServerStatsItem") then
            local item = net.ServerStatsItem
            local v = item:GetValue("DataPing")
            return v
        end
        return nil
    end)
    if ok and type(ping) == "number" then return math.floor(ping) end
    return nil
end

-- =========================
-- Estabilizador / Auto-scale
-- =========================
local TARGET_FPS = 60
local stabilizerConnection = nil
local frameTimesStab = {}
local AUTO_SCALE_ENABLED = true
local heavyTasksPaused = false

local function pauseHeavyTasks(state)
    heavyTasksPaused = state and true or false
    -- Placeholder: desconectar loops pesados se existirem (adaptar conforme necessidade)
    -- Ex.: se você tiver conexões em RunService.Heartbeat, guarde e desconecte aqui.
end

local function tryApplyExecutorFpsCap(target)
    local ok = pcall(function()
        if setfpscap then
            setfpscap(target)
        end
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
        -- Auto-scale
        if AUTO_SCALE_ENABLED then
            if fps < (TARGET_FPS * 0.85) then
                pauseHeavyTasks(true)
                pcall(function()
                    if Workspace.StreamingEnabled ~= nil then
                        Workspace.StreamingTargetRadius = math.max(48, (Workspace.StreamingTargetRadius or 128) - 8)
                    end
                end)
            else
                pauseHeavyTasks(false)
            end
        end
    end)
end

local function stopStabilizer()
    if stabilizerConnection then stabilizerConnection:Disconnect(); stabilizerConnection = nil end
    frameTimesStab = {}
    pauseHeavyTasks(false)
end

-- =========================
-- Fonte estilo Minecraft (tenta Enum.Font.Minecraft, fallback)
-- =========================
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

-- =========================
-- UI (minimizável) com todos os controles
-- =========================
local function createUI()
    if not LocalPlayer then return end
    local playerGui = safe(function() return LocalPlayer:WaitForChild("PlayerGui", 5) end)
    if not playerGui then return end

    local existing = playerGui:FindFirstChild("FPSBoostUI")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FPSBoostUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
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
    title.Text = "FPS v5"
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

    -- FPS / Ping display + toggle
    fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0.40, 0, 0.18, 0)
    fpsLabel.Position = UDim2.new(0.02, 0, 0.02, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: --"
    fpsLabel.TextColor3 = Color3.new(1,1,1)
    fpsLabel.Font = Enum.Font.SourceSansBold
    fpsLabel.TextSize = 14
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Parent = frame

    local pingLabel = Instance.new("TextLabel")
    pingLabel.Size = UDim2.new(0.28, 0, 0.18, 0)
    pingLabel.Position = UDim2.new(0.44, 0, 0.02, 0)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "PING: --"
    pingLabel.TextColor3 = Color3.new(1,1,1)
    pingLabel.Font = Enum.Font.SourceSans
    pingLabel.TextSize = 12
    pingLabel.Parent = frame

    local btnFPS = Instance.new("TextButton")
    btnFPS.Size = UDim2.new(0.24, 0, 0.18, 0)
    btnFPS.Position = UDim2.new(0.72, 0, 0.02, 0)
    btnFPS.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btnFPS.TextColor3 = Color3.new(1,1,1)
    btnFPS.Text = "FPS: ON"
    btnFPS.Font = Enum.Font.SourceSans
    btnFPS.TextSize = 12
    btnFPS.Parent = frame

    -- Atualiza ping periodicamente
    spawn(function()
        while screenGui.Parent do
            local p = getPingMs()
            if p and pingLabel and pingLabel.Parent then pingLabel.Text = ("PING: %dms"):format(p) end
            wait(1)
        end
    end)

    -- Conexões
    btnClaro.MouseButton1Down:Connect(function()
        brilho = "claro"
        applyBrilho(brilho)
        safe(function() game.StarterGui:SetCore("SendNotification", {Title="FPS v5", Text="Claridade: Claro", Duration=2}) end)
    end)
    btnPadrao.MouseButton1Down:Connect(function()
        brilho = "padrao"
        applyBrilho(brilho)
        safe(function() game.StarterGui:SetCore("SendNotification", {Title="FPS v5", Text="Claridade: Padrão", Duration=2}) end)
    end)
    btnEscuro.MouseButton1Down:Connect(function()
        brilho = "escuro"
        applyBrilho(brilho)
        safe(function() game.StarterGui:SetCore(
