--[[ 
    Bloxtrap Mobile v2.0
    PC-Level Optimization for Roblox Mobile
    Stable FPS • Presets • Smart Lighting
]]

--==================== CONFIG ====================
local PRESET = "LOW" -- LOW / MEDIUM / HIGH
local FONT = Enum.Font.Arcade
--================================================

-- Services
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

--==================== SAVE ORIGINAL ====================
local Original = {
    Lighting = {},
    Parts = {},
    Lights = {}
}

for _,p in ipairs({
    "Brightness","Ambient","OutdoorAmbient",
    "ClockTime","GlobalShadows",
    "FogEnd","EnvironmentDiffuseScale","EnvironmentSpecularScale"
}) do
    Original.Lighting[p] = Lighting[p]
end

--==================== PRESETS ====================
local Presets = {
    LOW = {
        Brightness = 0.55,
        ClockTime = 21,
        Ambient = Color3.fromRGB(5,5,5),
        MaxLightRange = 14,
        MaxLightBrightness = 0.8,
        Particles = false,
        Shadows = false
    },
    MEDIUM = {
        Brightness = 0.85,
        ClockTime = 20,
        Ambient = Color3.fromRGB(15,15,15),
        MaxLightRange = 22,
        MaxLightBrightness = 1.3,
        Particles = false,
        Shadows = false
    },
    HIGH = {
        Brightness = Original.Lighting.Brightness,
        ClockTime = Original.Lighting.ClockTime,
        Ambient = Original.Lighting.Ambient,
        MaxLightRange = 999,
        MaxLightBrightness = 999,
        Particles = true,
        Shadows = true
    }
}

--==================== LIGHTING ====================
local function ApplyLighting()
    local P = Presets[PRESET]
    Lighting.GlobalShadows = P.Shadows
    Lighting.Brightness = P.Brightness
    Lighting.ClockTime = P.ClockTime
    Lighting.Ambient = P.Ambient
    Lighting.OutdoorAmbient = P.Ambient
    Lighting.FogEnd = 1e6
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
end

--==================== OPTIMIZATION CORE ====================
local function OptimizeObject(obj)
    local P = Presets[PRESET]

    if obj:IsA("BasePart") then
        if not Original.Parts[obj] then
            Original.Parts[obj] = {
                Material = obj.Material,
                Shadow = obj.CastShadow
            }
        end
        obj.Material = Enum.Material.SmoothPlastic
        obj.CastShadow = false
        if obj:IsA("MeshPart") then
            obj.RenderFidelity = Enum.RenderFidelity.Performance
        end

    elseif obj:IsA("Light") then
        if not Original.Lights[obj] then
            Original.Lights[obj] = {
                Brightness = obj.Brightness,
                Range = obj.Range
            }
        end
        obj.Brightness = math.min(obj.Brightness, P.MaxLightBrightness)
        obj.Range = math.min(obj.Range, P.MaxLightRange)

    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
        obj.Enabled = P.Particles
    end
end

--==================== APPLY ALL (ONCE) ====================
local function ApplyOptimization()
    ApplyLighting()
    for _,obj in ipairs(Workspace:GetDescendants()) do
        OptimizeObject(obj)
    end
end

--==================== ANTI SPIKE SYSTEM ====================
Workspace.DescendantAdded:Connect(function(obj)
    task.delay(0.25, function()
        if obj and obj.Parent then
            OptimizeObject(obj)
        end
    end)
end)

--==================== UI ====================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "BloxtrapMobile"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,240,0,180)
frame.Position = UDim2.new(0.03,0,0.25,0)
frame.BackgroundColor3 = Color3.fromRGB(16,16,18)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,32)
title.BackgroundColor3 = Color3.fromRGB(24,24,26)
title.Text = "Bloxtrap Mobile v2.0"
title.Font = FONT
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(220,220,220)

local function MakeBtn(text,y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,-20,0,30)
    b.Position = UDim2.new(0,10,0,y)
    b.BackgroundColor3 = Color3.fromRGB(34,34,38)
    b.Text = text
    b.Font = FONT
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(240,240,240)
    b.BorderSizePixel = 0
    return b
end

local btnPreset = MakeBtn("Preset: LOW", 50)

btnPreset.MouseButton1Click:Connect(function()
    PRESET = (PRESET=="LOW" and "MEDIUM") or (PRESET=="MEDIUM" and "HIGH") or "LOW"
    btnPreset.Text = "Preset: "..PRESET
    ApplyOptimization()
end)

ApplyOptimization()

print("[Bloxtrap Mobile v2.0] Loaded | Preset:", PRESET)
