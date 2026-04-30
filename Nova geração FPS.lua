-- =========================================
-- FPS ULTRA NEXT GEN - UI LIB (LEVE)
-- =========================================

if _G.FPS_UI then return end

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "FPS_UI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- MAIN FRAME
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 260, 0, 300)
main.Position = UDim2.new(0, 20, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

-- TOP BAR
local top = Instance.new("Frame")
top.Size = UDim2.new(1,0,0,30)
top.BackgroundColor3 = Color3.fromRGB(35,35,35)
top.Parent = main

Instance.new("UICorner", top).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,10,0,0)
title.Text = "FPS NEXT GEN"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

-- MINIMIZE BUTTON
local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0,30,1,0)
minimize.Position = UDim2.new(1,-30,0,0)
minimize.Text = "-"
minimize.TextColor3 = Color3.new(1,1,1)
minimize.BackgroundTransparency = 1
minimize.Parent = top

-- CONTENT
local content = Instance.new("Frame")
content.Size = UDim2.new(1,0,1,-30)
content.Position = UDim2.new(0,0,0,30)
content.BackgroundTransparency = 1
content.Parent = main

-- SCROLL
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,0,1,0)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 3
scroll.BackgroundTransparency = 1
scroll.Parent = content

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,6)

-- MINIMIZE LOGIC
local minimized = false
minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	content.Visible = not minimized
	main.Size = minimized and UDim2.new(0,260,0,30) or UDim2.new(0,260,0,300)
end)

-- DRAG (LEVE)
local dragging, dragInput, dragStart, startPos

top.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

top.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-- =========================
-- CORE UI FUNCTIONS
-- =========================

local UI = {}
_G.UI = UI

-- ADD TOGGLE
function UI:Toggle(text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1,-10,0,30)
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.Text = text .. " [OFF]"
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Parent = scroll

	local state = false

	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = text .. (state and " [ON]" or " [OFF]")
		callback(state)
	end)
end

-- ADD BUTTON
function UI:Button(text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1,-10,0,30)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.Text = text
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Parent = scroll

	btn.MouseButton1Click:Connect(callback)
end

-- UPDATE CANVAS
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)

print("UI Next Gen carregada")

-- =========================================
-- FPS ULTRA NEXT GEN - PARTE 1 (CORE)
-- Sistema profissional e leve
-- =========================================

if _G.FPS_CORE then return end

local CORE = {}
_G.FPS_CORE = CORE

-- =========================
-- ESTADOS E CALLBACKS
-- =========================

CORE.Flags = {}
CORE.Callbacks = {}

-- =========================
-- SISTEMA DE FLAGS
-- =========================

function CORE:Set(flag, value)
	self.Flags[flag] = value

	if self.Callbacks[flag] then
		for _, callback in ipairs(self.Callbacks[flag]) do
			task.spawn(callback, value)
		end
	end
end

function CORE:Get(flag)
	return self.Flags[flag]
end

function CORE:On(flag, callback)
	if not self.Callbacks[flag] then
		self.Callbacks[flag] = {}
	end

	table.insert(self.Callbacks[flag], callback)
end

-- =========================
-- INTEGRAÇÃO COM UI
-- =========================

local UI = _G.UI
if not UI then
	warn("UI não encontrada (Parte 0 faltando)")
	return
end

CORE.UI = UI

-- =========================
-- FUNÇÕES DE CRIAÇÃO
-- =========================

function CORE:CreateToggle(name, flag)
	self.Flags[flag] = false

	UI:Toggle(name, function(state)
		CORE:Set(flag, state)
	end)
end

function CORE:CreateButton(name, callback)
	UI:Button(name, callback)
end

-- =========================
-- INFORMAÇÕES DO DISPOSITIVO
-- =========================

local UIS = game:GetService("UserInputService")

CORE.Device = UIS.TouchEnabled and "Mobile" or "PC"

-- =========================
-- DEBUG LEVE
-- =========================

function CORE:Log(msg)
	print("[FPS CORE]: "..msg)
end

CORE:Log("Sistema iniciado | Device: "..CORE.Device)

-- =========================================
-- FPS ULTRA NEXT GEN - PARTE 2
-- Otimização inicial leve e eficiente
-- =========================================

local CORE = _G.FPS_CORE
if not CORE then return end

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- =========================
-- BACKUP ORIGINAL
-- =========================

local Backup = {
	Brightness = Lighting.Brightness,
	GlobalShadows = Lighting.GlobalShadows,
	FogEnd = Lighting.FogEnd
}

-- =========================
-- OTIMIZAÇÃO 1: LIGHT REDUCE
-- =========================

CORE:CreateToggle("Reduzir Iluminação", "LightReduce")

CORE:On("LightReduce", function(state)
	if state then
		Lighting.Brightness = 1
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 1e6
	else
		Lighting.Brightness = Backup.Brightness
		Lighting.GlobalShadows = Backup.GlobalShadows
		Lighting.FogEnd = Backup.FogEnd
	end
end)

-- =========================
-- OTIMIZAÇÃO 2: CLEAN EFFECTS (LEVE)
-- =========================

CORE:CreateToggle("Limpeza Leve de Efeitos", "CleanEffects")

CORE:On("CleanEffects", function(state)
	if not state then return end

	-- roda UMA VEZ só (não fica em loop pesado)
	task.spawn(function()
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
				obj.Enabled = false
			end
		end
	end)
end)

CORE:Log("Parte 2 carregada")
