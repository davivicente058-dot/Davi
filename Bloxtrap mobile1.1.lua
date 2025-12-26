--[[ 
    Bloxtrap Mobile – Final Optimized
    FPS Boost + Iluminação leve + Mira + UI
    Inspirado no Bloxstrap PC
    Seguro | Universal | Mobile-friendly
]]

-- ================= CONFIG =================
local AUTO_TOGGLE = true
local FPS_ON = 35
local FPS_OFF = 45
local CHECK_INTERVAL = 1

local PRESET = "BALANCED" 
-- "ULTRA_LOW" | "BALANCED"

local FONT = Enum.Font.Arcade
-- ==========================================

-- Serviços
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
if not player then return end

-- ================= SAFE STORE =================
local original = {
    Lighting = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        Diffuse = Lighting.EnvironmentDiffuseScale,
        Specular = Lighting.EnvironmentSpecularScale
    },
    Parts = {},
    Effects = {}
}

-- ================= UI =================
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "BloxtrapMobile"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,180)
frame.Position = UDim2.new(0.02,0,0.25,0)
frame.BackgroundColor3 = Color3.fromRGB(18,18,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,36)
title.BackgroundTransparency = 1
title.Text = "Bloxtrap Mobile"
title.TextColor3 = Color3.fromRGB(220,220,220)
title.Font = FONT
title.TextSize = 18

local function button(text,y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,-20,0,30)
    b.Position = UDim2.new(0,10,0,y)
    b.BackgroundColor3 = Color3.fromRGB(36,36,40)
    b.BorderSizePixel = 0
    b.Text = text
    b.Font = FONT
    b.TextSize = 15
    b.TextColor3 = Color3.fromRGB(230,230,230)
    return b
end

local btnBoost = button("FPS Boost: OFF",45)
local btnMira  = button("Mira: ON",85)
local btnReset = button("Restaurar",125)

-- ================= FPS COUNTER =================
local fpsLabel = Instance.new("TextLabel", gui)
fpsLabel.Size = UDim2.new(0,90,0,24)
fpsLabel.Position = UDim2.new(0.01,0,0.01,0)
fpsLabel.BackgroundColor3 = Color3.fromRGB(10,10,10)
fpsLabel.BackgroundTransparency = 0.4
fpsLabel.TextColor3 = Color3.new(1,1,1)
fpsLabel.Font = FONT
fpsLabel.TextSize = 14
fpsLabel.Text = "FPS: 0"

-- ================= CROSSHAIR =================
local mira = Instance.new("Frame", gui)
mira.Size = UDim2.new(0,24,0,24)
mira.AnchorPoint = Vector2.new(0.5,0.5)
mira.Position = UDim2.new(0.5,0,0.5,0)
mira.BackgroundTransparency = 1

local function line(x,y,w,h)
    local l = Instance.new("Frame", mira)
    l.Size = UDim2.new(0,w,0,h)
    l.Position = UDim2.new(0.5,x,0.5,y)
    l.AnchorPoint = Vector2.new(0.5,0.5)
    l.BackgroundColor3 = Color3.new(1,1,1)
    l.BorderSizePixel = 0
end

line(-6,0,6,2)
line(6,0,6,2)
line(0,-6,2,6)
line(0,6,2,6)

-- ================= OPTIMIZATION CORE =================
local optimized = false
local IGNORED = {
    Camera = true, Folder = true, Script = true,
    LocalScript = true, ModuleScript = true, Sound = true
}

local function applyLighting()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e6
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.Brightness = 1
    Lighting.Ambient = Color3.fromRGB(12,12,12)
end

local function processBatches(list, size, callback)
    task.spawn(function()
        for i=1,#list,size do
            for j=i,math.min(i+size-1,#list) do
                callback(list[j])
            end
            task.wait()
        end
    end)
end

local function optimize()
    applyLighting()
    local objs = Workspace:GetDescendants()

    processBatches(objs, 250, function(v)
        if IGNORED[v.ClassName] then return end

        if v:IsA("BasePart") then
            if not original.Parts[v] then
                original.Parts[v] = {
                    Material=v.Material,
                    Shadow=v.CastShadow
                }
            end
            v.Material = Enum.Material.SmoothPlastic
            v.CastShadow = false
            if v:IsA("MeshPart") then
                v.RenderFidelity = Enum.RenderFidelity.Performance
            end

        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false

        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        end
    end)
end

local function restore()
    for p,data in pairs(original.Parts) do
        if p and p.Parent then
            p.Material = data.Material
            p.CastShadow = data.Shadow
        end
    end
    for k,v in pairs(original.Lighting) do
        Lighting[k] = v
    end
end

-- ================= BUTTONS =================
btnBoost.MouseButton1Click:Connect(function()
    optimized = not optimized
    if optimized then
        optimize()
        btnBoost.Text = "FPS Boost: ON"
    else
        restore()
        btnBoost.Text = "FPS Boost: OFF"
    end
end)

btnMira.MouseButton1Click:Connect(function()
    mira.Visible = not mira.Visible
    btnMira.Text = mira.Visible and "Mira: ON" or "Mira: OFF"
end)

btnReset.MouseButton1Click:Connect(function()
    optimized = false
    restore()
    btnBoost.Text = "FPS Boost: OFF"
end)

-- ================= FPS LOOP =================
local frames,accum,fps = 0,0,0
RunService.RenderStepped:Connect(function(dt)
    frames += 1
    accum += dt
    if accum >= 1 then
        fps = math.floor(frames/accum)
        fpsLabel.Text = "FPS: "..fps
        frames = 0
        accum = 0
    end
end)

-- ================= AUTO TOGGLE =================
task.spawn(function()
    if not AUTO_TOGGLE then return end
    while gui.Parent do
        task.wait(CHECK_INTERVAL)
        if not optimized and fps < FPS_ON then
            optimized = true
            optimize()
            btnBoost.Text = "FPS Boost: ON"
        elseif optimized and fps >= FPS_OFF then
            optimized = false
            restore()
            btnBoost.Text = "FPS Boost: OFF"
        end
    end
end)

print("[Bloxtrap Mobile] Loaded successfully")
