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

--// ===============================================
--// PARTE 1 - CORE & TOGGLES (ROBUSTO, RAYFIELD-FRIENDLY)
--// - Cria CORE global de controle
--// - Detecta device (mobile/pc)
--// - Registra toggles principais (sem aplicar efeitos pesados)
--// - Fornece API: CORE:OnChange(flag, handler) e CORE:SetFlag/GetFlag
--// - Fallbacks seguros caso _G.Tabs não exista
--// ===============================================

-- Segurança: não carregar duas vezes
if rawget(_G, "FPS_ULTRA_CORE_LOADED") then
    return
end
_G.FPS_ULTRA_CORE_LOADED = true

-- Serviços
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ====== UTIL SCRIPTS ======
local function safe_pcall(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok, res
end

-- ====== CORE GLOBAL ======
_G.FPS_CORE = _G.FPS_CORE or {}
local CORE = _G.FPS_CORE

-- Inicializar se necessário
CORE.Flags = CORE.Flags or {}            -- flags booleanas / estados
CORE.Handlers = CORE.Handlers or {}      -- handlers por flag
CORE._poller = CORE._poller or {}        -- internals
CORE.Device = CORE.Device or nil
CORE.Toggles = CORE.Toggles or {}        -- referências às toggles Rayfield (se houver)
CORE.WindowRef = CORE.WindowRef or nil   -- opcional storage da window

-- ====== DETECÇÃO DE DISPOSITIVO ======
do
    local platform = UserInputService:GetPlatform()
    if platform == Enum.Platform.Android or platform == Enum.Platform.IOS then
        CORE.Device = "Mobile"
    else
        CORE.Device = "PC"
    end
end

-- ====== FUNÇÕES DO CORE ======
function CORE:SetFlag(name, value)
    self.Flags[name] = value
    -- chama handlers registrados (se houver)
    if self.Handlers[name] then
        for _, h in ipairs(self.Handlers[name]) do
            safe_pcall(h, value)
        end
    end
end

function CORE:GetFlag(name)
    return self.Flags[name] == true
end

-- Registrar um handler para uma flag (múltiplos handlers permitidos)
function CORE:OnChange(name, handler)
    if type(handler) ~= "function" then return end
    self.Handlers[name] = self.Handlers[name] or {}
    table.insert(self.Handlers[name], handler)
end

-- Registra referência de toggle criada por Rayfield (opcional)
function CORE:RegisterToggle(name, toggleObj)
    if not name or toggleObj == nil then return end
    self.Toggles[name] = toggleObj
end

-- Tenta obter CurrentValue/Value de uma toggle Rayfield de forma segura
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

-- ====== SAFE CREATE TOGGLE HELPER (wrap Rayfield creation or create fallback) ======
-- Options: { Tab = _G.Tabs.X, Name = "My Toggle", Flag = "MyFlag", Default = false }
local function createToggle(options)
    options = options or {}
    local tab = options.Tab
    local name = options.Name or "Toggle"
    local flag = options.Flag or name:gsub("%s+","")
    local default = options.Default or false
    local createdObj = nil

    -- if Rayfield tab exists and has CreateToggle (or CreateToggle alias), try that
    if tab and type(tab) == "table" then
        local ok, res = pcall(function()
            -- Rayfield CreateToggle signature returns an object/table we can store
            if type(tab.CreateToggle) == "function" then
                return tab:CreateToggle({
                    Name = name,
                    CurrentValue = default,
                    Flag = flag,
                    Callback = function(val)
                        CORE:SetFlag(flag, val)
                    end
                })
            elseif type(tab.Create) == "function" then
                -- some libs have different API
                return tab:Create({ Name = name, Default = default })
            end
        end)
        if ok and res then
            createdObj = res
            CORE:RegisterToggle(flag, createdObj)
            -- ensure CORE flag default
            CORE:SetFlag(flag, default)
            return createdObj
        end
    end

    -- fallback: create a simple placeholder table (no UI) so poller can read/write
    createdObj = { CurrentValue = default, Value = default }
    CORE:RegisterToggle(flag, createdObj)
    CORE:SetFlag(flag, default)
    return createdObj
end

-- ====== ENSURE _G.Tabs AVAILABILITY (fallback safe) ======
local Tabs = rawget(_G, "Tabs")
if not Tabs then
    -- try to find Rayfield window stored globally (common patterns)
    local maybeTabs = rawget(_G, "Tabs") or rawget(_G, "FPS_UI_TABS") or nil
    if maybeTabs and type(maybeTabs) == "table" then
        Tabs = maybeTabs
    else
        -- final fallback: create a minimal fake tabs table so createToggle works w/out error
        Tabs = {
            Performance = {},
            Graphics = {},
            Visual = {},
            Advanced = {}
        }
    end
end

-- Attach a convenience for callers
CORE.Tabs = Tabs

-- ====== CREATE THE MAIN TOGGLES (NO EFFECTS APPLIED HERE) ======
-- These toggles serve as the points of integration for future parts.
local togglesToCreate = {
    { Tab = Tabs.Performance, Name = "Modo Ultra (Extremo)", Flag = "UltraMode", Default = false },
    { Tab = Tabs.Performance, Name = "Otimização Geral", Flag = "GeneralOptimize", Default = false },
    { Tab = Tabs.Graphics,     Name = "Gráficos Ultra Baixos", Flag = "LowGraphics", Default = false },
    { Tab = Tabs.Graphics,     Name = "Desativar Sombras", Flag = "DisableShadows", Default = false },
    { Tab = Tabs.Graphics,     Name = "Modo Iluminação", Flag = "LightingMode_Padrao", Default = false }, -- placeholder; actual will be dropdown
    { Tab = Tabs.Visual,       Name = "Remover Partículas", Flag = "ReduceParticles", Default = false },
    { Tab = Tabs.Visual,       Name = "Reduzir Animações", Flag = "ReduceAnimations", Default = false },
    { Tab = Tabs.Performance,  Name = "Fluidez Avançada", Flag = "AdvancedFluid", Default = false },
    { Tab = Tabs.Advanced,     Name = "Mostrar FPS", Flag = "ShowFPS", Default = false },
    { Tab = Tabs.Advanced,     Name = "Mira Central", Flag = "Crosshair", Default = false }
}

for _, t in ipairs(togglesToCreate) do
    createToggle({ Tab = t.Tab, Name = t.Name, Flag = t.Flag, Default = t.Default })
end

-- ====== Lighting mode dropdown (Create a selection control if tab supports it) ======
-- We attempt to create a dropdown on Graphics tab to choose between Padrao/Claro/Escuro
local function tryCreateDropdown(tab)
    if not tab or type(tab) ~= "table" then return nil end
    local ok, res = pcall(function()
        if type(tab.CreateDropdown) == "function" then
            return tab:CreateDropdown({
                Name = "Iluminação",
                Options = { "Padrao", "Claro", "Escuro" },
                CurrentOption = "Padrao",
                Flag = "LightingPreset",
                Callback = function(option)
                    -- store in CORE as string
                    CORE:SetFlag("LightingPreset", option)
                end
            })
        elseif type(tab.Create) == "function" and type(tab.CreateDropdown) ~= "function" and type(tab.CreateToggle) ~= "function" then
            -- unknown API: skip
            return nil
        end
    end)
    if ok and res then
        return res
    end
    return nil
end

-- try to create dropdown (safe)
local _drop = tryCreateDropdown(Tabs.Graphics)
if not _drop then
    -- fallback: set default flag
    CORE:SetFlag("LightingPreset", "Padrao")
end

-- ====== POLLER (FALLBACK LEVE) ======
-- Caso Rayfield toggles don't expose callbacks as we expected, poll CurrentValue a cada 0.40s
CORE._poller.active = CORE._poller.active or true
task.spawn(function()
    while CORE._poller.active do
        task.wait(0.4)
        for flagName, toggleObj in pairs(CORE.Toggles) do
            local ok, val = pcall(readToggleValue, toggleObj)
            if ok then
                local prev = CORE.Flags[flagName]
                if val ~= prev then
                    CORE:SetFlag(flagName, val)
                end
            end
        end
    end
end)

-- ====== HELPER: expose registration API for future parts ======
-- Usage in future parts:
-- CORE:OnChange("ReduceParticles", function(state) ... end)
-- CORE:RegisterToggle("ReduceParticles", toggleReference) -- if want to override stored object

-- Provide a lightweight notify to confirm Part 1 loaded
local successMsg = "[FPS ULTRA] PARTE 1 (CORE) CARREGADA - DEVICE: " .. tostring(CORE.Device)
print(successMsg)
if rawget(_G, "Rayfield") == nil then
    -- don't assume Rayfield global — but if Window exists, try notify via Window
    if type(_G.Tabs) == "table" and type(_G.Tabs.Performance) == "table" then
        pcall(function()
            if _G.Tabs.Performance.Notify then
                _G.Tabs.Performance:Notify({ Title = "FPS ULTRA", Content = "Core carregado", Duration = 2 })
            end
        end)
    end
end

-- END PARTE 1

