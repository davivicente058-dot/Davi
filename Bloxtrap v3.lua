--[[
====================================================
 Bloxtrap Mobile v4.0
 Mobile FPS & Graphics Optimizer for Roblox
 Improved | Stable | Lightweight
====================================================
]]

----------------------
-- SERVICES
----------------------
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

----------------------
-- SETTINGS
----------------------
local Settings = {
    Preset = "MEDIUM", -- LOW / MEDIUM / HIGH
    AutoOptimizeNew = true,
    SmartLighting = true
}

----------------------
-- SAVE ORIGINAL
----------------------
local Original = {
    Lighting = {},
    Parts = {},
    Effects = {}
}

for _, prop in ipairs({
    "Brightness","ClockTime","Ambient","OutdoorAmbient",
    "GlobalShadows","FogEnd",
    "EnvironmentDiffuseScale","EnvironmentSpecularScale"
}) do
    Original.Lighting[prop] = Lighting[prop]
end

----------------------
-- PRESETS
----------------------
local Presets = {
    LOW = {
        Brightness = 0.6,
        ClockTime = 21,
        Ambient = Color3.fromRGB(10,10,10),
        Shadows = false,
        Particles = false,
        MaxLightRange = 14
    },

    MEDIUM = {
        Brightness = 0.9,
        ClockTime = 20,
        Ambient = Color3.fromRGB(30,30,30),
        Shadows = false,
        Particles = false,
        MaxLightRange = 20
    },

    HIGH = {
        Brightness = Original.Lighting.Brightness,
        ClockTime = Original.Lighting.ClockTime,
        Ambient = Original.Lighting.Ambient,
        Shadows = true,
        Particles = true,
        MaxLightRange = 999
    }
}

----------------------
-- APPLY LIGHTING
----------------------
local function ApplyLighting()
    local P = Presets[Settings.Preset]

    Lighting.GlobalShadows = P.Shadows
    Lighting.Brightness = P.Brightness
    Lighting.ClockTime = P.ClockTime
    Lighting.Ambient = P.Ambient
    Lighting.OutdoorAmbient = P.Ambient

    -- Mobile optimization
    Lighting.FogEnd = 1e6
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
end

----------------------
-- OPTIMIZE OBJECT
----------------------
local function OptimizeObject(obj)
    local P = Presets[Settings.Preset]

    if obj:IsA("BasePart") then
        if not Original.Parts[obj] then
            Original.Parts[obj] = {
                Material = obj.Material,
                Shadow = obj.CastShadow
            }
        end

        obj.CastShadow = P.Shadows
        obj.Material = Enum.Material.SmoothPlastic

    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
        if Settings.Preset ~= "HIGH" then
            obj.Enabled = false
        end

    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        obj.Range = math.min(obj.Range, P.MaxLightRange)
    end
end

----------------------
-- INITIAL OPTIMIZATION
----------------------
task.spawn(function()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        OptimizeObject(obj)
    end
end)

----------------------
-- AUTO OPTIMIZE NEW OBJECTS
----------------------
if Settings.AutoOptimizeNew then
    Workspace.DescendantAdded:Connect(function(obj)
        task.wait()
        OptimizeObject(obj)
    end)
end

----------------------
-- APPLY EVERYTHING
----------------------
ApplyLighting()

----------------------
-- FPS STABILITY LOOP
----------------------
RunService.RenderStepped:Connect(function()
    if Settings.Preset ~= "HIGH" then
        Lighting.GlobalShadows = false
    end
end)

----------------------
-- FINISHED
----------------------
warn("[Bloxtrap Mobile v4.0] Loaded successfully!")
