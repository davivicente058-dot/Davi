-- =====================================
-- FPS SCRIPT - PART 0 (UI BASE ONLY)
-- Rayfield UI | Stable Base
-- =====================================

-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Create Main Window
local Window = Rayfield:CreateWindow({
	Name = "FPS ULTRA | Base",
	LoadingTitle = "FPS ULTRA",
	LoadingSubtitle = "UI carregando...",
	ConfigurationSaving = {
		Enabled = false
	},
	KeySystem = false
})

-- Create Tabs (EMPTY)
_G.Tabs = {}

_G.Tabs.Performance = Window:CreateTab("Performance", 4483362458)
_G.Tabs.Graphics    = Window:CreateTab("Graphics", 4483362458)
_G.Tabs.Visual      = Window:CreateTab("Visual", 4483362458)
_G.Tabs.Advanced    = Window:CreateTab("Advanced", 4483362458)

-- Simple Notify (debug visual)
Rayfield:Notify({
	Title = "FPS ULTRA",
	Content = "Parte 0 carregada com sucesso",
	Duration = 3
})

--// =========================================
--// PARTE 1 - CORE REFEITA (APENAS LÓGICA, SEM UI)
--// - NÃO altera UI (usa abas criadas na Parte 0)
--// - Fornece API robusta para as próximas partes
--// =========================================

-- proteção contra carregamento duplo
if rawget(_G, "FPS_CORE_LOADED_V2") then
    return
end
rawset(_G, "FPS_CORE_LOADED_V2", true)

-- Serviços
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- CORE global
_G.FPS_CORE = _G.FPS_CORE or {}
local CORE = _G.FPS_CORE

-- init fields
CORE.Flags      = CORE.Flags or {}        -- booleans por nome
CORE.Handlers   = CORE.Handlers or {}     -- handlers por flag
CORE.Toggles    = CORE.Toggles or {}      -- referencia à toggle UI (se criada)
CORE.Poller     = CORE.Poller or {active = true, rate = 0.45}
CORE.Device     = CORE.Device or nil
CORE.WindowRef  = CORE.WindowRef or nil

-- util seguro
local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    if not ok then
        warn("[FPS_CORE] erro em safe():", res)
    end
    return ok, res
end

-- detector de device simples e robusto
do
    local platform = UserInputService:GetPlatform()
    if platform == Enum.Platform.IOS or platform == Enum.Platform.Android then
        CORE.Device = "Mobile"
    else
        CORE.Device = "PC"
    end
end

-- lê valor de toggle de forma defensiva
local function readToggleValue(t)
    if not t then return false end
    if type(t) == "table" then
        if t.CurrentValue ~= nil then return t.CurrentValue end
        if t.Value ~= nil then return t.Value end
        if t.GetState and type(t.GetState) == "function" then
            local ok, v = pcall(function() return t:GetState() end)
            if ok then return v end
        end
    end
    return false
end

-- Set / Get flag (dispara handlers)
function CORE:SetFlag(name, value)
    local prior = self.Flags[name]
    self.Flags[name] = value and true or false
    if prior ~= self.Flags[name] and self.Handlers[name] then
        for _, h in ipairs(self.Handlers[name]) do
            safe(h, self.Flags[name])
        end
    end
end

function CORE:GetFlag(name)
    return self.Flags[name] == true
end

-- Registra um handler: CORE:OnChange("FlagName", function(state) ... end)
function CORE:OnChange(name, handler)
    if type(handler) ~= "function" then return end
    self.Handlers[name] = self.Handlers[name] or {}
    table.insert(self.Handlers[name], handler)
end

-- Registra referência de toggle (quando a Parte 0 / Rayfield criar a toggle)
function CORE:RegisterToggle(name, toggleObj)
    if not name then return end
    self.Toggles[name] = toggleObj
    -- sincroniza estado inicial do toggle para CORE.Flags
    local ok, v = pcall(readToggleValue, toggleObj)
    if ok then
        self.Flags[name] = v and true or false
    end
end

-- Cria toggle na tab Rayfield (se possível). options = { Tab = _G.Tabs.X, Name = "X", Flag = "FlagName", Default = false }
function CORE:CreateToggle(options)
    options = options or {}
    local tab = options.Tab
    local name = options.Name or "Toggle"
    local flag = options.Flag or name:gsub("%s+","")
    local default = options.Default or false

    -- tenta criar no Rayfield (API padrão: tab:CreateToggle)
    if tab and type(tab) == "table" and type(tab.CreateToggle) == "function" then
        local ok, toggleObj = pcall(function()
            return tab:CreateToggle({
                Name = name,
                CurrentValue = default,
                Flag = flag,
                Callback = function(val)
                    -- quando o usuário usa a UI, atualizamos o CORE
                    CORE:SetFlag(flag, val)
                end
            })
        end)
        if ok and toggleObj then
            CORE:RegisterToggle(flag, toggleObj)
            CORE.Flags[flag] = default and true or false
            return toggleObj
        end
    end

    -- fallback leve: cria placeholder table (não há UI)
    local placeholder = { CurrentValue = default, Value = default }
    CORE:RegisterToggle(flag, placeholder)
    CORE.Flags[flag] = default and true or false
    return placeholder
end

-- safe connect: tenta ligar eventos/callbacks expostos pela toggle
local function safeConnectToggle(toggleObj, callback)
    if not toggleObj then return end
    safe(function()
        if toggleObj.Changed and type(toggleObj.Changed.Connect) == "function" then
            toggleObj.Changed:Connect(function()
                local v = readToggleValue(toggleObj)
                callback(v)
            end)
            return
        end
        if toggleObj.OnChanged and type(toggleObj.OnChanged.Connect) == "function" then
            toggleObj.OnChanged:Connect(callback)
            return
        end
        if type(toggleObj.Callback) == "function" then
            -- Rayfield sometimes stores callback in the object; override is ok
            toggleObj.Callback = callback
            return
        end
    end)
end

-- Poller: verifica periodicamente valores das toggles (fallback robusto)
task.spawn(function()
    while CORE.Poller.active do
        task.wait(CORE.Poller.rate or 0.45)
        for flagName, tObj in pairs(CORE.Toggles) do
            local ok, val = pcall(readToggleValue, tObj)
            if ok then
                val = val and true or false
                if CORE.Flags[flagName] ~= val then
                    CORE:SetFlag(flagName, val)
                end
            end
        end
    end
end)

-- Helper util para registrar toggle e conectar handler em um único passo:
-- CORE:BindToggle({ Tab = _G.Tabs.Performance, Name="Nome", Flag="FlagName", Default=false }, function(state) ... end)
function CORE:BindToggle(createOptions, handler)
    if type(createOptions) ~= "table" then return end
    local flag = createOptions.Flag or (createOptions.Name and createOptions.Name:gsub("%s+","")) or "Flag"
    local tObj = createOptions.UseExisting and CORE.Toggles[flag] or nil
    if not tObj then
        tObj = CORE:CreateToggle({ Tab = createOptions.Tab, Name = createOptions.Name, Flag = flag, Default = createOptions.Default })
    end
    -- connect safe
    safeConnectToggle(tObj, function(v) CORE:SetFlag(flag, v) end)
    -- register handler
    if type(handler) == "function" then
        CORE:OnChange(flag, handler)
    end
    return tObj
end

-- === Cria duas toggles-placeholder principais (NÃO executam efeitos aqui) ===
-- Use CORE:OnChange("GeneralOptimize", handler) nas próximas partes para aplicar lógica real.
local Tabs = rawget(_G, "Tabs") or rawget(_G, "_TABS") or _G.Tabs
-- tentativa segura de localizar abas caso Parte0 guardou em outro nome
local tabPerf = (Tabs and Tabs.Performance) or (Tabs and Tabs.PerformanceTab) or nil
local tabGraphics = (Tabs and Tabs.Graphics) or nil

-- bind placeholders (these will create UI toggles if tab exists, otherwise placeholders)
CORE:BindToggle({ Tab = tabPerf, Name = "Otimização Geral", Flag = "GeneralOptimize", Default = false }, nil)
CORE:BindToggle({ Tab = tabPerf, Name = "Modo Ultra (Extremo)", Flag = "UltraMode", Default = false }, nil)

-- expose CORE to global shortname for convenience
rawset(_G, "CORE_FPS", CORE)

print("[FPS_CORE] PARTE 1 REFEITA - CORE PRONTO (Device:", CORE.Device, ")")

-- =========================================
-- PARTE 2 - GRAFICOS BAIXOS + DESATIVAR SOMBRAS
-- =========================================

local CORE = _G.FPS_CORE
if not CORE then return end

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- BACKUP (para evitar bug quando desligar)
local Backup = {
	Brightness = Lighting.Brightness,
	GlobalShadows = Lighting.GlobalShadows,
	Technology = Lighting.Technology
}

-- ================================
-- FUNÇÃO 1: GRÁFICOS BAIXOS REAIS
-- ================================
local function LowGraphics(state)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			if state then
				obj.Material = Enum.Material.Plastic
				obj.Reflectance = 0
			end
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			if state then
				obj.Transparency = 1
			end
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
			obj.Enabled = not state
		end
	end

	if state then
		Lighting.Brightness = 1
	else
		Lighting.Brightness = Backup.Brightness
	end
end

-- ================================
-- FUNÇÃO 2: DESATIVAR SOMBRAS
-- ================================
local function DisableShadows(state)
	Lighting.GlobalShadows = not state

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.CastShadow = not state
		end
	end
end

-- ================================
-- CONEXÃO COM CORE (REAL)
-- ================================

CORE:OnChange("LowGraphics", function(state)
	task.spawn(function()
		LowGraphics(state)
	end)
end)

CORE:OnChange("DisableShadows", function(state)
	task.spawn(function()
		DisableShadows(state)
	end)
end)

-- ================================
-- TOGGLES NA UI (RAYFIELD)
-- ================================

CORE:CreateToggle({
	Tab = _G.Tabs.Graphics,
	Name = "Gráficos Baixos",
	Flag = "LowGraphics",
	Default = false
})

CORE:CreateToggle({
	Tab = _G.Tabs.Graphics,
	Name = "Desativar Sombras",
	Flag = "DisableShadows",
	Default = false
})

print("[FPS SCRIPT] Parte 2 carregada com sucesso")

-- =========================================
-- PARTE 3 - REDUZIR PARTÍCULAS (INTELIGENTE) + REDUZIR ANIMAÇÕES (INTELIGENTE)
-- Requisitos: _G.FPS_CORE (Parte 1) e UI (Parte 0/1)
-- =========================================

local CORE = _G.FPS_CORE
if not CORE then
    warn("[FPS ULTRA] Parte 3: CORE não encontrado. Cole a Parte 1 antes desta.")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- safe wrapper
local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    if not ok then warn("[FPS ULTRA][Parte3] erro:", res) end
    return ok, res
end

-- BACKUPS
local BACKUP = {
    Particles = {}, -- emitter -> { Enabled, Rate }
    Trails = {},    -- trail -> { Enabled }
    AnimTracks = {} -- track -> originalSpeed
}

-- CONFIG (tweak leve para comportamento)
local CONFIG = {
    ParticleDistanceThreshold = 80, -- studs: distant emitters are fully disabled
    ParticleNearRateScale = 0.25,   -- near emitters rate scale (0.25 = 25% of original)
    PollInterval = 1.25,            -- seconds between checks (leve)
    AnimationDistanceThreshold = 60,-- reduce animations for characters farther than this
    AnimationSpeedScale = 0.45      -- reduce distant animation speed to this fraction
}

-- HELPERS
local function isDescendantOfLocalCharacter(obj)
    local char = LocalPlayer.Character
    if not char then return false end
    return char == obj or (obj:IsDescendantOf(char))
end

local function getDistanceFromLocal(obj)
    local cam = workspace.CurrentCamera
    local root = nil
    if obj:IsA("BasePart") then root = obj
    else
        root = obj:FindFirstChild("HumanoidRootPart") or obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart")
    end
    if not root then
        -- fallback try using camera
        if cam and cam.Focus and cam.Focus.Position then
            return (root and (root.Position - cam.Focus.Position).Magnitude) or math.huge
        end
        return math.huge
    end
    local camPos = cam and cam.CFrame and cam.CFrame.p or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position) or Vector3.new(0,0,0)
    return (root.Position - camPos).Magnitude
end

-- ========== PARTICLE REDUCTION ==========
local PART_REDUCE_ENABLED = false
local particleTask = nil

local function backupParticleState(emitter)
    if not emitter then return end
    if BACKUP.Particles[emitter] then return end
    BACKUP.Particles[emitter] = {
        Enabled = safe(function() return emitter.Enabled end) and emitter.Enabled or false,
        Rate = safe(function() return emitter.Rate end) and (emitter.Rate or nil) or nil
    }
end

local function restoreParticleState(emitter)
    if not emitter then return end
    local b = BACKUP.Particles[emitter]
    if not b then return end
    pcall(function()
        if b.Rate ~= nil and emitter.Rate ~= nil then emitter.Rate = b.Rate end
        emitter.Enabled = b.Enabled
    end)
    BACKUP.Particles[emitter] = nil
end

local function processParticlesOnce()
    -- iterate emitters and trails (safe)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        -- ParticleEmitter
        if obj:IsA("ParticleEmitter") then
            safe(function()
                -- ignore emitters that are part of local player's character (we keep local experience)
                if isDescendantOfLocalCharacter(obj) then
                    -- ensure restored if previously modified
                    if BACKUP.Particles[obj] then restoreParticleState(obj) end
                    return
                end

                local dist = getDistanceFromLocal(obj)
                -- backup original state first time
                backupParticleState(obj)

                -- if far away -> disable completely
                if dist >= CONFIG.ParticleDistanceThreshold then
                    if obj.Enabled then obj.Enabled = false end
                else
                    -- near: reduce Rate if available (scale down)
                    if obj.Rate ~= nil then
                        local b = BACKUP.Particles[obj] and BACKUP.Particles[obj].Rate or obj.Rate
                        if b and b > 0 then
                            local newRate = math.max(1, math.floor(b * CONFIG.ParticleNearRateScale))
                            obj.Rate = newRate
                            obj.Enabled = true
                        end
                    else
                        -- if no Rate property (rare), just ensure enabled true (don't break)
                        obj.Enabled = true
                    end
                end
            end)
        end

        -- Trail
        if obj:IsA("Trail") then
            safe(function()
                if isDescendantOfLocalCharacter(obj) then
                    if BACKUP.Trails[obj] then restoreParticleState(obj) end
                    return
                end
                -- backup
                if not BACKUP.Trails[obj] then
                    BACKUP.Trails[obj] = { Enabled = obj.Enabled }
                end
                local dist = getDistanceFromLocal(obj)
                if dist >= CONFIG.ParticleDistanceThreshold then
                    obj.Enabled = false
                else
                    obj.Enabled = true
                end
            end)
        end
    end
end

local function restoreAllParticles()
    for emitter, _ in pairs(BACKUP.Particles) do
        pcall(function() restoreParticleState(emitter) end)
    end
    for trail, _ in pairs(BACKUP.Trails) do
        pcall(function()
            if trail and trail.Parent then
                trail.Enabled = BACKUP.Trails[trail].Enabled
            end
        end)
    end
    BACKUP.Particles = {}
    BACKUP.Trails = {}
end

local function startParticleReduction()
    if PART_REDUCE_ENABLED then return end
    PART_REDUCE_ENABLED = true
    -- initial pass
    processParticlesOnce()
    particleTask = task.spawn(function()
        while PART_REDUCE_ENABLED do
            task.wait(CONFIG.PollInterval)
            processParticlesOnce()
        end
    end)
end

local function stopParticleReduction()
    if not PART_REDUCE_ENABLED then return end
    PART_REDUCE_ENABLED = false
    if particleTask then
        pcall(function() task.cancel(particleTask) end)
        particleTask = nil
    end
    -- restore original states
    restoreAllParticles()
end

-- ========== ANIMATION REDUCTION ==========
local ANIM_REDUCE_ENABLED = false
local animTask = nil

local function backupTrack(track)
    if not track then return end
    if BACKUP.AnimTracks[track] ~= nil then return end
    local ok, s = pcall(function() return track.Speed end)
    BACKUP.AnimTracks[track] = ok and s or 1
end

local function restoreTrack(track)
    if not track then return end
    local orig = BACKUP.AnimTracks[track]
    if orig ~= nil then
        pcall(function() track:AdjustSpeed(orig) end)
        BACKUP.AnimTracks[track] = nil
    end
end

local function processAnimationsOnce()
    -- find humanoids in workspace
    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.RootPart then
                -- skip local player's own character to avoid affecting player's own controls/feel
                if LocalPlayer.Character and model == LocalPlayer.Character then
                    -- ensure any previous modifications to local player's tracks are restored
                    for track, _ in pairs(BACKUP.AnimTracks) do
                        if track and track.Instance and track:IsA and track:IsA("AnimationTrack") and track.Parent and track.Parent:IsDescendantOf(LocalPlayer.Character) then
                            restoreTrack(track)
                        end
                    end
                    goto continue_model
                end

                local dist = (humanoid.RootPart.Position - (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or humanoid.RootPart.Position)).Magnitude
                if dist >= CONFIG.AnimationDistanceThreshold then
                    -- for distant humanoids, reduce playing track speeds
                    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                        safe(function()
                            backupTrack(track)
                            -- reduce speed only if not already very low
                            local current = 1
                            pcall(function() current = track.Speed end)
                            if current > CONFIG.AnimationSpeedScale + 0.05 then
                                track:AdjustSpeed(CONFIG.AnimationSpeedScale)
                            end
                        end)
                    end
                else
                    -- if close, restore tracks for that humanoid if we had modified them before
                    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                        safe(function()
                            if BACKUP.AnimTracks[track] then
                                restoreTrack(track)
                            end
                        end)
                    end
                end
            end
        end
        ::continue_model::
    end
end

local function restoreAllAnimTracks()
    for track, _ in pairs(BACKUP.AnimTracks) do
        pcall(function() restoreTrack(track) end)
    end
    BACKUP.AnimTracks = {}
end

local function startAnimationReduction()
    if ANIM_REDUCE_ENABLED then return end
    ANIM_REDUCE_ENABLED = true
    processAnimationsOnce()
    animTask = task.spawn(function()
        while ANIM_REDUCE_ENABLED do
            task.wait(CONFIG.PollInterval)
            processAnimationsOnce()
        end
    end)
end

local function stopAnimationReduction()
    if not ANIM_REDUCE_ENABLED then return end
    ANIM_REDUCE_ENABLED = false
    if animTask then
        pcall(function() task.cancel(animTask) end)
        animTask = nil
    end
    restoreAllAnimTracks()
end

-- ========== CORE HANDLERS + TOGGLES ==========
CORE:OnChange("ReduceParticles", function(state)
    if state then startParticleReduction() else stopParticleReduction() end
end)

CORE:OnChange("ReduceAnimations", function(state)
    if state then startAnimationReduction() else stopAnimationReduction() end
end)

-- Create toggles in UI (if CORE.Tabs available this will attempt to add them)
CORE:CreateToggle({ Tab = CORE.Tabs and CORE.Tabs.Visual or nil, Name = "Remover Partículas (Inteligente)", Flag = "ReduceParticles", Default = false })
CORE:CreateToggle({ Tab = CORE.Tabs and CORE.Tabs.Visual or nil, Name = "Reduzir Animações (Inteligente)", Flag = "ReduceAnimations", Default = false })

print("[FPS ULTRA] PARTE 3 carregada — Partículas e Animações inteligentes prontas.")
