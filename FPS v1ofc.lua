-- FPS Stabilizer + Ping Monitor + Minecraft-like Font (safe)
-- Integre após seu FPS v4; usa pcall para funções específicas de executores

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Stats = game:GetService("Stats")

-- CONFIGS
local TARGET_FPS = 60
local FPS_WINDOW = 30
local AUTO_SCALE_ENABLED = true -- reduz carga automaticamente se FPS cair
local MIN_QUALITY_LEVEL = 1     -- valor baixo para qualidade (se aplicável)
local MAX_QUALITY_LEVEL = 10    -- valor alto (se aplicável)

-- ESTADO
local frameTimes = {}
local fpsLabel = nil
local pingLabel = nil
local stabilizerConnection = nil
local fpsCapApplied = false

-- UTIL safe pcall
local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok and res or nil
end

-- Tenta aplicar cap via função do executor (setfpscap) se existir
local function tryApplyExecutorFpsCap(target)
    local ok = pcall(function()
        if setfpscap then
            setfpscap(target) -- executores como alguns mobile clients expõem isso
            fpsCapApplied = true
        elseif setfpscap then
            setfpscap(target)
            fpsCapApplied = true
        end
    end)
    return ok and fpsCapApplied
end

-- Função que reduz trabalho pesado: desliga updates não essenciais por frame
local heavyTasksPaused = false
local function pauseHeavyTasks(state)
    heavyTasksPaused = state and true or false
    -- Exemplo: desconectar listeners pesados (você pode adaptar para seu código)
    -- Aqui apenas um placeholder: se você tiver loops em RenderStepped, guarde as conexões e desconecte
end

-- Calcula FPS média móvel
local function updateFps(dt)
    table.insert(frameTimes, dt)
    if #frameTimes > FPS_WINDOW then table.remove(frameTimes, 1) end
    local sum = 0
    for _, t in ipairs(frameTimes) do sum = sum + t end
    if sum == 0 then return 0 end
    return #frameTimes / sum
end

-- Pega ping (round-trip) via Stats service (may vary by platform)
local function getPingMs()
    local success, ping = pcall(function()
        local rtt = Stats.Network.ServerStatsItem and Stats.Network.ServerStatsItem:GetValue("DataPing") -- fallback
        return rtt
    end)
    if success and type(ping) == "number" then
        return math.floor(ping)
    end
    -- fallback: usar Stats:GetTotalMemory or other not accurate; return nil
    return nil
end

-- UI simples para FPS e Ping (integre ao seu PlayerGui)
local function createFpsPingUI(parentGui)
    if not parentGui then return end
    if parentGui:FindFirstChild("PerfOverlay") then parentGui.PerfOverlay:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PerfOverlay"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = parentGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.18,0,0.06,0)
    frame.Position = UDim2.new(0.02,0,0.02,0)
    frame.BackgroundTransparency = 0.35
    frame.BackgroundColor3 = Color3.fromRGB(10,10,10)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0.6,0,1,0)
    fpsLabel.Position = UDim2.new(0,0,0,0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextColor3 = Color3.new(1,1,1)
    fpsLabel.Font = Enum.Font.SourceSansBold
    fpsLabel.TextSize = 14
    fpsLabel.Text = "FPS: --"
    fpsLabel.Parent = frame

    pingLabel = Instance.new("TextLabel")
    pingLabel.Size = UDim2.new(0.4,0,1,0)
    pingLabel.Position = UDim2.new(0.6,0,0,0)
    pingLabel.BackgroundTransparency = 1
    pingLabel.TextColor3 = Color3.new(1,1,1)
    pingLabel.Font = Enum.Font.SourceSans
    pingLabel.TextSize = 12
    pingLabel.Text = "PING: --"
    pingLabel.Parent = frame

    return screenGui
end

-- Inicia estabilizador: tenta cap + auto-scale
local function startStabilizer()
    if stabilizerConnection then return end

    -- tenta aplicar cap via executor (se disponível)
    tryApplyExecutorFpsCap(TARGET_FPS)

    stabilizerConnection = RunService.RenderStepped:Connect(function(dt)
        local fps = updateFps(dt)
        if fpsLabel then fpsLabel.Text = ("FPS: %d"):format(math.floor(fps + 0.5)) end

        -- ping update (menos frequente)
        if tick() % 1 < dt then
            local ping = getPingMs()
            if ping and pingLabel then pingLabel.Text = ("PING: %dms"):format(ping) end
        end

        -- Auto-scale: se FPS cair muito, reduzir carga
        if AUTO_SCALE_ENABLED then
            if fps < (TARGET_FPS * 0.85) then
                -- reduzir efeitos não essenciais
                pauseHeavyTasks(true)
                -- opcional: reduzir streaming radius para carregar menos
                pcall(function()
                    if workspace.StreamingEnabled ~= nil then
                        workspace.StreamingTargetRadius = math.max(64, (workspace.StreamingTargetRadius or 128) - 16)
                    end
                end)
            else
                pauseHeavyTasks(false)
            end
        end
    end)
end

local function stopStabilizer()
    if stabilizerConnection then
        stabilizerConnection:Disconnect()
        stabilizerConnection = nil
    end
    frameTimes = {}
    if fpsLabel then fpsLabel.Text = "FPS: --" end
    if pingLabel then pingLabel.Text = "PING: --" end
end

-- Tenta aplicar fonte estilo Minecraft em todas as GUIs (com fallback)
local function applyMinecraftFont(root)
    local function trySetFont(guiObj)
        safe(function()
            if guiObj:IsA("TextLabel") or guiObj:IsA("TextButton") or guiObj:IsA("TextBox") then
                -- tenta Enum.Font.Minecraft se existir, senão usa SourceSansBold
                local ok = pcall(function() guiObj.Font = Enum.Font.Minecraft end)
                if not ok then guiObj.Font = Enum.Font.SourceSansBold end
            end
        end)
    end
    for _, obj in pairs(root:GetDescendants()) do
        trySetFont(obj)
    end
end

-- Public API: toggle functions (integre aos botões do seu UI)
local function enablePerfOverlay()
    local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if pg then createFpsPingUI(pg) end
    startStabilizer()
end

local function disablePerfOverlay()
    stopStabilizer()
    local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if pg and pg:FindFirstChild("PerfOverlay") then pg.PerfOverlay:Destroy() end
end

-- Inicialização segura: cria overlay e aplica fonte se desejado
safe(function()
    local pg = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui", 5)
    if pg then
        createFpsPingUI(pg)
        startStabilizer()
        -- aplica fonte Minecraft nas GUIs do jogador (opcional)
        applyMinecraftFont(pg)
    end
end)

-- Expor toggles para integração com seu UI principal
_G.FPSStabilizer = {
    Enable = enablePerfOverlay,
    Disable = disablePerfOverlay,
    ApplyMinecraftFont = function() local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui"); if pg then applyMinecraftFont(pg) end end
}
