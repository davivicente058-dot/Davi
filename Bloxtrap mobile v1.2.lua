--[[ 
    Bloxtrap Mobile – Advanced Edition
    FPS Boost • UI Avançada • Brilho Controlado • Mobile Focus
    Inspirado no Bloxstrap PC
]]

-- ================= CONFIG =================
local AUTO_TOGGLE = true
local FPS_ON = 35
local FPS_OFF = 45
local CHECK_INTERVAL = 1

local FONT = Enum.Font.Arcade
-- ==========================================

-- Serviços
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
if not player then return end

-- ================= SAVE ORIGINAL =================
local original = {
    Lighting = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        Diffuse = Lighting.EnvironmentDiffuseScale,
        Specular = Lighting.EnvironmentSpecularScale
    },
    Parts = {},
    Effects = {}
}

-- ================= UI =================
local gui = Instance.new("ScreenGui")
gui.Name = "BloxtrapMobile"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local shadow = Instance.new("Frame", gui)
shadow.Size = UDim2.new(0,270,0,210)
shadow.Position = UDim2.new(0.02,4,0.25,6)
shadow.BackgroundColor3 = Color3.new(0,0,0)
shadow.BackgroundTransparency = 0.7
shadow.BorderSizePixel = 0

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,200)
frame.Position = UDim2.new(0.02,0,0.25,0)
frame.BackgroundColor3 = Color3.fromRGB(18,18,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1,0,0,36)
header.BackgroundColor3 = Color3.fromRGB(26,26,28)
header.BorderSizePixel = 0

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-70,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "Bloxtrap Mobile"
title.Font = FONT
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(220,220,220)
title.TextXAlignment = Enum.TextXAlignment.Left

local btnMin = Instance.new("TextButton", header)
btnMin.Size = UDim2.new(0,28,0,28)
btnMin.Position = UDim2.new(1,-36,0,4)
btnMin.Text = "—"
btnMin.Font = FONT
btnMin.TextSize = 18
btnMin.BackgroundColor3 = Color3.fromRGB(40,40,44)
btnMin.BorderSizePixel = 0
btnMin.TextColor3 = Color3.fromRGB(220,220,220)

local content = Instance.new("Frame", frame)
content.Size = UDim2.new(1,-12,1,-46)
content.Position = UDim2.new(0,6,0,40)
content.BackgroundTransparency = 1

local function button(text,y)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.new(1,0,0,32)
    b.Position = UDim2.new(0,0,0,y)
    b.BackgroundColor3 = Color3.fromRGB(36,36,40)
    b.BorderSizePixel = 0
    b.Text = text
    b.Font = FONT
    b.TextSize = 15
    b.TextColor3 = Color3.fromRGB(230,230,230)
    return b
end

local btnFPS   = button("FPS Boost: OFF", 0)
local btnLight = button("Brilho: Escuro", 40)
local btnMira  = button("Mira: ON", 80)
local btnReset = button("Restaurar Tudo", 120)

-- ================= FPS LABEL =================
local fpsLabel = Instance.new("TextLabel", gui)
fpsLabel.Size = UDim2.new(0,90,0,24)
fpsLabel.Position = UDim2.new(0.01,0,0.01,0)
fpsLabel.BackgroundColor3 = Color3.fromRGB(10,10,10)
fpsLabel.BackgroundTransparency = 0.4
fpsLabel.BorderSizePixel = 0
fpsLabel.Font = FONT
fpsLabel.TextSize = 14
fpsLabel.TextColor3 = Color3.new(1,1,1)
fpsLabel.Text = "FPS: 0"

-- ================= MIRA =================
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
line(-6,0,6,2) line(6,0,6,2) line(0,-6,2,6) line(0,6,2,6)

-- ================= OPTIMIZATION =================
local optimized = false
local lightMode = "DARK"

local IGNORE = {
    Camera=true, Folder=true, Script=true,
    LocalScript=true, ModuleScript=true, Sound=true
}

local function applyLightingProfile()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e6
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
end

local function setLight(mode)
    if mode == "DARK" then
        Lighting.Brightness = 0.9
        Lighting.ClockTime = 20
        Lighting.Ambient = Color3.fromRGB(12,12,12)
        Lighting.OutdoorAmbient = Lighting.Ambient
    elseif mode == "LIGHT" then
        Lighting.Brightness = 1.8
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(200,200,200)
        Lighting.OutdoorAmbient = Lighting.Ambient
    else
        for k,v in pairs(original.Lighting) do
            Lighting[k] = v
        end
    end
end

local function batch(list,size,callback)
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
    applyLightingProfile()
    setLight(lightMode)

    batch(Workspace:GetDescendants(),250,function(v)
        if IGNORE[v.ClassName] then return end

        if v:IsA("BasePart") then
            if not original.Parts[v] then
                original.Parts[v]={Material=v.Material,Shadow=v.CastShadow}
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
    for p,d in pairs(original.Parts) do
        if p and p.Parent then
            p.Material = d.Material
            p.CastShadow = d.Shadow
        end
    end
    for k,v in pairs(original.Lighting) do
        Lighting[k] = v
    end
end

-- ================= CONTROLS =================
btnFPS.MouseButton1Click:Connect(function()
    optimized = not optimized
    if optimized then
        optimize()
        btnFPS.Text = "FPS Boost: ON"
    else
        restore()
        btnFPS.Text = "FPS Boost: OFF"
    end
end)

btnLight.MouseButton1Click:Connect(function()
    if lightMode == "DARK" then
        lightMode = "LIGHT"
        btnLight.Text = "Brilho: Claro"
    elseif lightMode == "LIGHT" then
        lightMode = "DEFAULT"
        btnLight.Text = "Brilho: Padrão"
    else
        lightMode = "DARK"
        btnLight.Text = "Brilho: Escuro"
    end
    setLight(lightMode)
end)

btnMira.MouseButton1Click:Connect(function()
    mira.Visible = not mira.Visible
    btnMira.Text = mira.Visible and "Mira: ON" or "Mira: OFF"
end)

btnReset.MouseButton1Click:Connect(function()
    optimized = false
    restore()
    btnFPS.Text = "FPS Boost: OFF"
end)

local minimized=false
btnMin.MouseButton1Click:Connect(function()
    minimized=not minimized
    content.Visible = not minimized
    frame.Size = minimized and UDim2.new(0,180,0,36) or UDim2.new(0,260,0,200)
    shadow.Size = minimized and UDim2.new(0,186,0,42) or UDim2.new(0,270,0,210)
end)

-- ================= FPS LOOP =================
local frames,accum,fps=0,0,0
RunService.RenderStepped:Connect(function(dt)
    frames+=1 accum+=dt
    if accum>=1 then
        fps=math.floor(frames/accum)
        fpsLabel.Text="FPS: "..fps
        frames=0 accum=0
    end
end)

-- ================= AUTO TOGGLE =================
task.spawn(function()
    if not AUTO_TOGGLE then return end
    while gui.Parent do
        task.wait(CHECK_INTERVAL)
        if not optimized and fps<FPS_ON then
            optimized=true optimize()
            btnFPS.Text="FPS Boost: ON"
        elseif optimized and fps>=FPS_OFF then
            optimized=false restore()
            btnFPS.Text="FPS Boost: OFF"
        end
    end
end)

print("[Bloxtrap Mobile] Advanced version loaded")
