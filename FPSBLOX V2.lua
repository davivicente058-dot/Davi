--[[====================================================
 FPSBLOX / BLOXTRAP MOBILE
 Part 1 - Core System (Base)
======================================================]]

------------------------
-- SERVICES
------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

------------------------
-- GLOBAL TABLE
------------------------
_G.FPSBLOX = _G.FPSBLOX or {}

local Core = {
	Loaded = false,

	-- states
	UIOpen = true,
	Optimization = "OFF", -- OFF / LOW / BALANCED / ULTRA
	LightingMode = "PADRAO",
	Crosshair = false,

	-- runtime
	Connections = {},
	Cache = {}
}

_G.FPSBLOX.Core = Core

------------------------
-- SAFE CONNECT
------------------------
local function SafeConnect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(Core.Connections, c)
	return c
end

Core.SafeConnect = SafeConnect

------------------------
-- LIGHTING BACKUP
------------------------
local OriginalLighting = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	GlobalShadows = Lighting.GlobalShadows,
	FogEnd = Lighting.FogEnd
}

_G.FPSBLOX.OriginalLighting = OriginalLighting

------------------------
-- LIGHTING PROFILES
------------------------
local LightingProfiles = {

	CLARO = {
		Brightness = 1.6,
		ClockTime = 14,
		Ambient = Color3.fromRGB(125,125,125),
		OutdoorAmbient = Color3.fromRGB(130,130,130),
		GlobalShadows = true,
		FogEnd = 100000
	},

	PADRAO = {
		Brightness = 1.15,
		ClockTime = 16.5,
		Ambient = Color3.fromRGB(95,95,95),
		OutdoorAmbient = Color3.fromRGB(100,100,100),
		GlobalShadows = true,
		FogEnd = 100000
	},

	ESCURO = {
		Brightness = 0.95, -- escuro jogável
		ClockTime = 19,
		Ambient = Color3.fromRGB(75,75,75),
		OutdoorAmbient = Color3.fromRGB(80,80,80),
		GlobalShadows = false,
		FogEnd = 85000
	}
}

_G.FPSBLOX.LightingProfiles = LightingProfiles

------------------------
-- APPLY LIGHTING
------------------------
local function ApplyLighting(mode)
	local profile = LightingProfiles[mode]
	if not profile then return end

	Core.LightingMode = mode

	for prop,value in pairs(profile) do
		pcall(function()
			Lighting[prop] = value
		end)
	end
end

_G.FPSBLOX.ApplyLighting = ApplyLighting

------------------------
-- FPS COUNTER (CORE)
------------------------
local FPS = {
	Frames = 0,
	Value = 0,
	Last = tick()
}

SafeConnect(RunService.RenderStepped,function()
	FPS.Frames += 1
	local now = tick()
	if now - FPS.Last >= 1 then
		FPS.Value = FPS.Frames
		FPS.Frames = 0
		FPS.Last = now
	end
end)

_G.FPSBLOX.FPS = FPS

------------------------
-- OBJECT CACHE UTILS
------------------------
local function CacheProperty(obj, prop)
	Core.Cache[obj] = Core.Cache[obj] or {}
	if Core.Cache[obj][prop] == nil then
		Core.Cache[obj][prop] = obj[prop]
	end
end

Core.CacheProperty = CacheProperty

------------------------
-- RESTORE ALL
------------------------
local function RestoreOriginal()
	for obj,props in pairs(Core.Cache) do
		if obj and obj.Parent then
			for prop,value in pairs(props) do
				pcall(function()
					obj[prop] = value
				end)
			end
		end
	end

	for prop,value in pairs(OriginalLighting) do
		pcall(function()
			Lighting[prop] = value
		end)
	end
end

_G.FPSBLOX.Restore = RestoreOriginal

------------------------
-- READY
------------------------
ApplyLighting("PADRAO")
Core.Loaded = true

print("[FPSBLOX] Core Part 1 loaded")

--[[====================================================
 FPSBLOX / BLOXTRAP MOBILE
 Part 2 - UI System
======================================================]]

if not _G.FPSBLOX or not _G.FPSBLOX.Core then
	return warn("Core não carregado")
end

local Core = _G.FPSBLOX.Core
local FPS = _G.FPSBLOX.FPS
local ApplyLighting = _G.FPSBLOX.ApplyLighting

------------------------
-- UI SERVICE
------------------------
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

------------------------
-- SCREEN GUI
------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FPSBLOX_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

------------------------
-- MAIN WINDOW
------------------------
local Main = Instance.new("Frame")
Main.Size = UDim2.fromScale(0.75,0.7)
Main.Position = UDim2.fromScale(0.5,0.5)
Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.BackgroundColor3 = Color3.fromRGB(245,245,245)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Main.Visible = true
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner",Main)
Corner.CornerRadius = UDim.new(0,18)

------------------------
-- TOP BAR
------------------------
local Top = Instance.new("Frame",Main)
Top.Size = UDim2.fromScale(1,0.1)
Top.BackgroundTransparency = 1

local Title = Instance.new("TextLabel",Top)
Title.Size = UDim2.fromScale(0.7,1)
Title.Position = UDim2.fromScale(0.05,0)
Title.BackgroundTransparency = 1
Title.Text = "FPSBLOX  •  Definitive"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(30,30,30)
Title.TextXAlignment = Left

------------------------
-- MINIMIZE BUTTON
------------------------
local MinBtn = Instance.new("TextButton",Top)
MinBtn.Size = UDim2.fromScale(0.12,0.6)
MinBtn.Position = UDim2.fromScale(0.83,0.2)
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.BackgroundColor3 = Color3.fromRGB(220,220,220)
MinBtn.TextColor3 = Color3.fromRGB(40,40,40)

local MinCorner = Instance.new("UICorner",MinBtn)
MinCorner.CornerRadius = UDim.new(1,0)

------------------------
-- CONTENT
------------------------
local Content = Instance.new("Frame",Main)
Content.Size = UDim2.fromScale(1,0.9)
Content.Position = UDim2.fromScale(0,0.1)
Content.BackgroundTransparency = 1

------------------------
-- FPS LABEL
------------------------
local FPSLabel = Instance.new("TextLabel",Content)
FPSLabel.Size = UDim2.fromScale(0.4,0.08)
FPSLabel.Position = UDim2.fromScale(0.05,0.05)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Font = Enum.Font.Gotham
FPSLabel.TextSize = 16
FPSLabel.TextColor3 = Color3.fromRGB(60,60,60)
FPSLabel.TextXAlignment = Left

------------------------
-- BUTTON FACTORY
------------------------
local function CreateButton(text, y)
	local b = Instance.new("TextButton",Content)
	b.Size = UDim2.fromScale(0.9,0.1)
	b.Position = UDim2.fromScale(0.05,y)
	b.Text = text
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 16
	b.BackgroundColor3 = Color3.fromRGB(230,230,230)
	b.TextColor3 = Color3.fromRGB(35,35,35)
	b.AutoButtonColor = true

	local c = Instance.new("UICorner",b)
	c.CornerRadius = UDim.new(0,14)

	return b
end

------------------------
-- BUTTONS
------------------------
local LightBtn = CreateButton("🌤 Modo Claro",0.18)
local DarkBtn  = CreateButton("🌙 Modo Escuro",0.30)
local OptBtn   = CreateButton("⚙ Otimização: OFF",0.42)
local AimBtn   = CreateButton("🎯 Mira: OFF",0.54)

------------------------
-- MINI BUTTON (FLOAT)
------------------------
local Mini = Instance.new("TextButton",ScreenGui)
Mini.Size = UDim2.fromScale(0.12,0.08)
Mini.Position = UDim2.fromScale(0.05,0.6)
Mini.Text = "FPS"
Mini.Font = Enum.Font.GothamBold
Mini.TextSize = 16
Mini.Visible = false
Mini.BackgroundColor3 = Color3.fromRGB(40,40,40)
Mini.TextColor3 = Color3.fromRGB(240,240,240)
Mini.Draggable = true
Mini.Active = true

local MiniCorner = Instance.new("UICorner",Mini)
MiniCorner.CornerRadius = UDim.new(1,0)

------------------------
-- FUNCTIONS
------------------------
MinBtn.MouseButton1Click:Connect(function()
	Main.Visible = false
	Mini.Visible = true
end)

Mini.MouseButton1Click:Connect(function()
	Main.Visible = true
	Mini.Visible = false
end)

LightBtn.MouseButton1Click:Connect(function()
	ApplyLighting("CLARO")
	Main.BackgroundColor3 = Color3.fromRGB(245,245,245)
	Title.TextColor3 = Color3.fromRGB(30,30,30)
end)

DarkBtn.MouseButton1Click:Connect(function()
	ApplyLighting("ESCURO")
	Main.BackgroundColor3 = Color3.fromRGB(32,32,32)
	Title.TextColor3 = Color3.fromRGB(230,230,230)
end)

OptBtn.MouseButton1Click:Connect(function()
	Core.Optimization = (Core.Optimization == "OFF" and "LOW") or "OFF"
	OptBtn.Text = "⚙ Otimização: "..Core.Optimization
end)

AimBtn.MouseButton1Click:Connect(function()
	Core.Crosshair = not Core.Crosshair
	AimBtn.Text = "🎯 Mira: "..(Core.Crosshair and "ON" or "OFF")
end)

------------------------
-- FPS UPDATE
------------------------
game:GetService("RunService").RenderStepped:Connect(function()
	FPSLabel.Text = "FPS: "..tostring(FPS.Value)
end)

print("[FPSBLOX] UI Part 2 loaded")

--[[====================================================
 FPSBLOX / BLOXTRAP MOBILE
 Part 3 - Optimization Engine
======================================================]]

if not _G.FPSBLOX or not _G.FPSBLOX.Core then
	return warn("Core não encontrado")
end

local Core = _G.FPSBLOX.Core
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

------------------------------------------------
-- DEFAULT SETTINGS
------------------------------------------------
Core.Optimization = Core.Optimization or "OFF"
Core._LastOptimize = 0

------------------------------------------------
-- LIGHTING PRESETS (SUAVE)
------------------------------------------------
local LightingPresets = {

	CLARO = function()
		Lighting.Brightness = 2
		Lighting.ExposureCompensation = 0.15
		Lighting.GlobalShadows = true
		Lighting.EnvironmentDiffuseScale = 0.5
		Lighting.EnvironmentSpecularScale = 0.5
		Lighting.OutdoorAmbient = Color3.fromRGB(160,160,160)
	end,

	ESCURO = function()
		Lighting.Brightness = 1.3 -- escuro SUAVE
		Lighting.ExposureCompensation = -0.15
		Lighting.GlobalShadows = false
		Lighting.EnvironmentDiffuseScale = 0.35
		Lighting.EnvironmentSpecularScale = 0.35
		Lighting.OutdoorAmbient = Color3.fromRGB(110,110,110)
	end
}

------------------------------------------------
-- APPLY LIGHTING (override)
------------------------------------------------
_G.FPSBLOX.ApplyLighting = function(mode)
	if LightingPresets[mode] then
		LightingPresets[mode]()
	end
end

------------------------------------------------
-- OBJECT OPTIMIZATION
------------------------------------------------
local function OptimizeObject(obj, level)

	if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
		obj.Enabled = (level ~= "ULTRA")
	end

	if obj:IsA("Beam") then
		obj.Enabled = false
	end

	if obj:IsA("BloomEffect") or obj:IsA("SunRaysEffect") or obj:IsA("BlurEffect") then
		obj.Enabled = (level == "LOW")
	end

	if obj:IsA("BasePart") then
		obj.Material = Enum.Material.Plastic
		obj.Reflectance = 0

		if level == "ULTRA" then
			obj.CastShadow = false
		end
	end

	if obj:IsA("Decal") or obj:IsA("Texture") then
		if level ~= "LOW" then
			obj.Transparency = math.clamp(obj.Transparency + 0.2,0,1)
		end
	end
end

------------------------------------------------
-- FULL MAP OPTIMIZE
------------------------------------------------
local function OptimizeMap(level)
	for _,obj in ipairs(workspace:GetDescendants()) do
		task.spawn(OptimizeObject,obj,level)
	end
end

------------------------------------------------
-- CHARACTER OPTIMIZE
------------------------------------------------
local function OptimizeCharacter(char, level)
	for _,obj in ipairs(char:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Material = Enum.Material.Plastic
			obj.CastShadow = false
		end
		if obj:IsA("Decal") and level ~= "LOW" then
			obj.Transparency = 1
		end
	end
end

------------------------------------------------
-- AUTO CHARACTER APPLY
------------------------------------------------
local function OnCharacter(char)
	task.wait(1)
	if Core.Optimization ~= "OFF" then
		OptimizeCharacter(char, Core.Optimization)
	end
end

if Player.Character then
	OnCharacter(Player.Character)
end

Player.CharacterAdded:Connect(OnCharacter)

------------------------------------------------
-- OPTIMIZATION LOOP (ANTI FPS DROP)
------------------------------------------------
RunService.Heartbeat:Connect(function()
	if Core.Optimization == "OFF" then return end

	if tick() - Core._LastOptimize > 5 then
		Core._LastOptimize = tick()
		OptimizeMap(Core.Optimization)
	end
end)

------------------------------------------------
-- LEVEL HANDLER
------------------------------------------------
function Core:SetOptimization(level)
	if level == "OFF" then
		Core.Optimization = "OFF"
		return
	end

	if level ~= "LOW" and level ~= "BALANCED" and level ~= "ULTRA" then
		return
	end

	Core.Optimization = level
	OptimizeMap(level)

	if Player.Character then
		OptimizeCharacter(Player.Character,level)
	end
end

------------------------------------------------
-- SAFE DEFAULT
------------------------------------------------
task.delay(2,function()
	if Core.Optimization ~= "OFF" then
		OptimizeMap(Core.Optimization)
	end
end)

print("[FPSBLOX] Optimization Part 3 loaded")

--[[====================================================
 FPSBLOX / BLOXTRAP MOBILE
 Part 4 - Crosshair + Final Polish
======================================================]]

if not _G.FPSBLOX or not _G.FPSBLOX.Core then
	return warn("FPSBLOX Core ausente")
end

local Core = _G.FPSBLOX.Core
local RunService = game:GetService("RunService")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

------------------------------------------------
-- CROSSHAIR GUI
------------------------------------------------
local CrossGui = Instance.new("ScreenGui")
CrossGui.Name = "FPSBLOX_Crosshair"
CrossGui.ResetOnSpawn = false
CrossGui.IgnoreGuiInset = true
CrossGui.Parent = PlayerGui

local Cross = Instance.new("Frame", CrossGui)
Cross.Size = UDim2.fromOffset(16,16)
Cross.AnchorPoint = Vector2.new(0.5,0.5)
Cross.Position = UDim2.fromScale(0.5,0.5)
Cross.BackgroundTransparency = 1
Cross.Visible = false

------------------------------------------------
-- CROSS PARTS
------------------------------------------------
local function CreateLine(size, pos)
	local f = Instance.new("Frame", Cross)
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = Color3.fromRGB(230,230,230)
	f.BorderSizePixel = 0
	return f
end

-- horizontal
CreateLine(UDim2.fromOffset(16,2), UDim2.fromScale(0,0.5))
-- vertical
CreateLine(UDim2.fromOffset(2,16), UDim2.fromScale(0.5,0))

------------------------------------------------
-- CROSSHAIR UPDATE
------------------------------------------------
RunService.RenderStepped:Connect(function()
	if not Core.Crosshair then
		Cross.Visible = false
		return
	end

	Cross.Visible = true
	Cross.Position = UDim2.fromOffset(
		Camera.ViewportSize.X / 2,
		Camera.ViewportSize.Y / 2
	)
end)

------------------------------------------------
-- UI FONT POLISH
------------------------------------------------
for _,gui in ipairs(PlayerGui:GetDescendants()) do
	if gui:IsA("TextLabel") or gui:IsA("TextButton") then
		gui.Font = Enum.Font.Cartoon -- mais próximo do estilo blocado
	end
end

------------------------------------------------
-- UI CONTRAST FIX (ANTI ESCURO DEMAIS)
------------------------------------------------
task.delay(1,function()
	for _,obj in ipairs(PlayerGui:GetDescendants()) do
		if obj:IsA("Frame") and obj.BackgroundColor3.R < 0.15 then
			obj.BackgroundColor3 = Color3.fromRGB(40,40,40)
		end
	end
end)

------------------------------------------------
-- STABILITY WATCHDOG
------------------------------------------------
task.spawn(function()
	while task.wait(10) do
		if Core.Optimization ~= "OFF" then
			pcall(function()
				-- reaplica otimização leve (mantém FPS estável)
				Core:SetOptimization(Core.Optimization)
			end)
		end
	end
end)

------------------------------------------------
-- QUALITY SEAL
------------------------------------------------
print("===================================")
print(" FPSBLOX  •  Definitive Edition")
print(" Inspired by Bloxtrap PC")
print(" Optimized for Mobile & All Devices")
print("===================================")
