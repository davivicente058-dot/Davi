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

-- =========================================
-- FPS ULTRA NEXT GEN - PARTE 3 (FIX)
-- Low Render otimizado e seguro
-- =========================================

local CORE = _G.FPS_CORE
if not CORE then return end

local Workspace = game:GetService("Workspace")

-- =========================
-- CONTROLE
-- =========================

local LowRenderActive = false
local Processing = false

-- =========================
-- FUNÇÃO OTIMIZADA
-- =========================

local function processBatch(list, startIndex, batchSize)
	for i = startIndex, math.min(startIndex + batchSize, #list) do
		local obj = list[i]

		if obj then
			-- PARTES
			if obj:IsA("BasePart") then
				obj.Material = Enum.Material.Plastic
				obj.Reflectance = 0
				obj.CastShadow = false
			end

			-- TEXTURAS
			if obj:IsA("Decal") or obj:IsA("Texture") then
				obj.Transparency = 1
			end
		end
	end
end

-- =========================
-- LOW RENDER INTELIGENTE
-- =========================

local function applyLowRender()
	if Processing then return end
	Processing = true

	local objects = Workspace:GetDescendants()
	local index = 1
	local batchSize = 200

	task.spawn(function()
		while index <= #objects and LowRenderActive do
			processBatch(objects, index, batchSize)
			index += batchSize
			task.wait()
		end

		Processing = false
	end)
end

-- =========================
-- TOGGLE 1: LOW RENDER
-- =========================

CORE:CreateToggle("Modo Gráfico PvP", "LowRender")

CORE:On("LowRender", function(state)
	LowRenderActive = state

	if state then
		applyLowRender()
	end
end)

-- =========================
-- TOGGLE 2: PART OPTIMIZE (LEVE)
-- =========================

CORE:CreateToggle("Reduzir Peso das Partes", "PartOptimize")

CORE:On("PartOptimize", function(state)
	if not state then return end

	task.spawn(function()
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				obj.CastShadow = false
			end
		end
	end)
end)

CORE:Log("Parte 3 FIX carregada")

-- =========================================
-- FPS ULTRA NEXT GEN - PARTE 4
-- Fluidez + Redução de Delay (Seguro)
-- =========================================

local CORE = _G.FPS_CORE
if not CORE then return end

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

-- =========================
-- CONTROLE
-- =========================

local FluidActive = false
local Connection = nil

-- =========================
-- FUNÇÃO: FLUID MODE
-- =========================

local function startFluid()
	if Connection then return end

	Connection = RunService.RenderStepped:Connect(function()
		if not FluidActive then return end
		
		-- micro otimização: evita picos de frame
		RunService:Set3dRenderingEnabled(true)
	end)
end

local function stopFluid()
	if Connection then
		Connection:Disconnect()
		Connection = nil
	end
end

-- =========================
-- TOGGLE 1: FLUID MODE
-- =========================

CORE:CreateToggle("Modo Fluidez", "FluidMode")

CORE:On("FluidMode", function(state)
	FluidActive = state

	if state then
		startFluid()
	else
		stopFluid()
	end
end)

-- =========================
-- TOGGLE 2: DELAY REDUCER
-- =========================

CORE:CreateToggle("Reduzir Delay", "DelayReduce")

CORE:On("DelayReduce", function(state)
	if not state then return end

	-- executa uma vez (leve)
	task.spawn(function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	end)
end)

CORE:Log("Parte 4 carregada")

-- =========================================
-- FPS ULTRA NEXT GEN - PARTE 5
-- VFX REDUCER PRO (INTELIGENTE)
-- =========================================

local CORE = _G.FPS_CORE
if not CORE then return end

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- =========================
-- CONFIG
-- =========================

local DISTANCE_LIMIT = 80

local Active = false
local Running = false

-- =========================
-- PEGAR POSIÇÃO DO PLAYER
-- =========================

local function getPlayerPos()
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		return char.HumanoidRootPart.Position
	end
	return nil
end

-- =========================
-- PROCESSAMENTO INTELIGENTE
-- =========================

local function processVFX()
	if Running then return end
	Running = true

	task.spawn(function()
		while Active do
			local playerPos = getPlayerPos()

			if playerPos then
				local objects = Workspace:GetDescendants()

				for i = 1, #objects, 150 do
					if not Active then break end

					for j = i, math.min(i + 149, #objects) do
						local obj = objects[j]

						if obj then
							local parent = obj.Parent

							-- distância
							local dist = math.huge
							if parent and parent:IsA("BasePart") then
								dist = (parent.Position - playerPos).Magnitude
							elseif parent and parent:FindFirstChild("HumanoidRootPart") then
								dist = (parent.HumanoidRootPart.Position - playerPos).Magnitude
							end

							-- PARTICLES
							if obj:IsA("ParticleEmitter") then
								if dist > DISTANCE_LIMIT then
									obj.Enabled = false
								else
									obj.Rate = math.min(obj.Rate, 5)
								end
							end

							-- TRAILS
							if obj:IsA("Trail") then
								obj.Enabled = dist < DISTANCE_LIMIT
							end

							-- BEAMS
							if obj:IsA("Beam") then
								obj.Enabled = false
							end

							-- EXPLOSIONS
							if obj:IsA("Explosion") then
								obj.BlastPressure = 0
								obj.BlastRadius = 0
							end
						end
					end

					task.wait()
				end
			end

			task.wait(1.5) -- intervalo inteligente (não pesa)
		end

		Running = false
	end)
end

-- =========================
-- TOGGLE PRINCIPAL
-- =========================

CORE:CreateToggle("VFX Reducer PRO", "VFXPro")

CORE:On("VFXPro", function(state)
	Active = state

	if state then
		processVFX()
	end
end)

CORE:Log("Parte 5 carregada (VFX PRO)")

-- =========================================
-- FPS ULTRA NEXT GEN - PARTE 6
-- VFX EXTREMO (MODO INSANO)
-- =========================================

local CORE = _G.FPS_CORE
if not CORE then return end

local Workspace = game:GetService("Workspace")

local Active = false
local Running = false

-- =========================
-- FUNÇÃO EXTREMA
-- =========================

local function processExtreme()
	if Running then return end
	Running = true

	task.spawn(function()
		while Active do
			local objects = Workspace:GetDescendants()

			for i = 1, #objects, 200 do
				if not Active then break end

				for j = i, math.min(i + 199, #objects) do
					local obj = objects[j]

					if obj then
						-- PARTICULAS
						if obj:IsA("ParticleEmitter") then
							obj.Enabled = false
						end

						-- TRAIL
						if obj:IsA("Trail") then
							obj.Enabled = false
						end

						-- BEAM
						if obj:IsA("Beam") then
							obj.Enabled = false
						end

						-- FOGO / FUMAÇA
						if obj:IsA("Fire") or obj:IsA("Smoke") then
							obj.Enabled = false
						end

						-- EXPLOSÕES
						if obj:IsA("Explosion") then
							obj.BlastPressure = 0
							obj.BlastRadius = 0
						end

						-- LUZES DINÂMICAS
						if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
							obj.Enabled = false
						end

						-- DECALS (efeitos visuais)
						if obj:IsA("Decal") then
							obj.Transparency = 1
						end
					end
				end

				task.wait()
			end

			task.wait(1) -- agressivo mas controlado
		end

		Running = false
	end)
end

-- =========================
-- TOGGLE EXTREMO
-- =========================

CORE:CreateToggle("VFX EXTREMO (FPS MAX)", "VFXExtreme")

CORE:On("VFXExtreme", function(state)
	Active = state

	if state then
		processExtreme()
	end
end)

CORE:Log("Parte 6 carregada (VFX EXTREMO)")

-- =========================================
-- FPS ULTRA NEXT GEN - PARTE 7
-- FPS STABILIZER PRO (ANTI DROP)
-- =========================================

local CORE = _G.FPS_CORE
if not CORE then return end

local RunService = game:GetService("RunService")

-- =========================
-- CONFIG
-- =========================

local TARGET_FPS = 50
local CHECK_INTERVAL = 0.5

local Active = false
local Running = false

local lastTime = tick()
local frameCount = 0
local currentFPS = 60

-- =========================
-- CALCULAR FPS REAL
-- =========================

RunService.RenderStepped:Connect(function()
	frameCount += 1
end)

local function updateFPS()
	local now = tick()
	local delta = now - lastTime

	if delta >= 1 then
		currentFPS = math.floor(frameCount / delta)
		frameCount = 0
		lastTime = now
	end
end

-- =========================
-- SISTEMA INTELIGENTE
-- =========================

local function startStabilizer()
	if Running then return end
	Running = true

	task.spawn(function()
		while Active do
			updateFPS()

			-- DETECTAR QUEDA
			if currentFPS < TARGET_FPS then
				
				-- ativa modo extremo automaticamente
				if not CORE:Get("VFXExtreme") then
					CORE:Set("VFXExtreme", true)
				end

				-- garante low render
				if not CORE:Get("LowRender") then
					CORE:Set("LowRender", true)
				end

			end

			task.wait(CHECK_INTERVAL)
		end

		Running = false
	end)
end

-- =========================
-- TOGGLE
-- =========================

CORE:CreateToggle("FPS Stabilizer (Anti Drop)", "FPSStabilizer")

CORE:On("FPSStabilizer", function(state)
	Active = state

	if state then
		startStabilizer()
	end
end)

CORE:Log("Parte 7 carregada (FPS STABILIZER)")

-- =========================================
-- FPS ULTRA NEXT GEN - PARTE FINAL
-- HUD + FPS REAL + REFINAMENTO
-- =========================================

local CORE = _G.FPS_CORE
if not CORE then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- =========================
-- GUI FPS
-- =========================

local gui = Instance.new("ScreenGui")
gui.Name = "FPS_HUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0,120,0,30)
fpsLabel.Position = UDim2.new(0,10,1,-40)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.new(1,1,1)
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.TextScaled = true
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.Text = "FPS: ..."
fpsLabel.Parent = gui

-- =========================
-- FPS REAL
-- =========================

local frames = 0
local last = tick()

RunService.RenderStepped:Connect(function()
	frames += 1

	if tick() - last >= 1 then
		local fps = frames
		frames = 0
		last = tick()

		fpsLabel.Text = "FPS: "..fps

		-- cor dinâmica
		if fps >= 50 then
			fpsLabel.TextColor3 = Color3.fromRGB(0,255,0)
		elseif fps >= 30 then
			fpsLabel.TextColor3 = Color3.fromRGB(255,170,0)
		else
			fpsLabel.TextColor3 = Color3.fromRGB(255,0,0)
		end
	end
end)

-- =========================
-- INDICADOR DE MODO
-- =========================

local modeLabel = Instance.new("TextLabel")
modeLabel.Size = UDim2.new(0,180,0,25)
modeLabel.Position = UDim2.new(0,10,1,-70)
modeLabel.BackgroundTransparency = 1
modeLabel.TextColor3 = Color3.new(1,1,1)
modeLabel.TextXAlignment = Enum.TextXAlignment.Left
modeLabel.TextScaled = true
modeLabel.Font = Enum.Font.SourceSans
modeLabel.Text = "Modo: Normal"
modeLabel.Parent = gui

-- =========================
-- ATUALIZA MODO
-- =========================

local function updateMode()
	if CORE:Get("VFXExtreme") then
		modeLabel.Text = "Modo: EXTREMO"
		modeLabel.TextColor3 = Color3.fromRGB(255,60,60)
	elseif CORE:Get("VFXPro") then
		modeLabel.Text = "Modo: VFX PRO"
		modeLabel.TextColor3 = Color3.fromRGB(255,200,0)
	else
		modeLabel.Text = "Modo: Normal"
		modeLabel.TextColor3 = Color3.fromRGB(200,200,200)
	end
end

-- conectar mudanças
CORE:On("VFXExtreme", updateMode)
CORE:On("VFXPro", updateMode)

updateMode()

-- =========================
-- BOTÃO EXTRA (OPCIONAL)
-- =========================

CORE:CreateButton("Ativar Modo Competitivo", function()
	CORE:Set("LowRender", true)
	CORE:Set("PartOptimize", true)
	CORE:Set("LightReduce", true)
	CORE:Set("VFXExtreme", true)
end)

CORE:Log("Script finalizado com sucesso")

-- =========================================
-- FPS ULTRA NEXT GEN - UI HIDE SYSTEM
-- Ocultar / Mostrar UI (PvP Friendly)
-- =========================================

local CORE = _G.FPS_CORE
local UI = _G.UI
if not CORE or not UI then return end

local UIS = game:GetService("UserInputService")

-- =========================
-- REFERÊNCIA DA UI
-- =========================

local MainUI = nil

-- tenta achar a frame principal
for _, v in pairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
	if v.Name == "FPS_UI" then
		MainUI = v
	end
end

if not MainUI then return end

local Visible = true

-- =========================
-- FUNÇÃO
-- =========================

local function toggleUI()
	Visible = not Visible
	MainUI.Enabled = Visible
end

-- =========================
-- BOTÃO NA UI
-- =========================

CORE:CreateButton("Mostrar / Esconder UI", function()
	toggleUI()
end)

-- =========================
-- ATALHO (PC)
-- =========================

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.RightControl then
		toggleUI()
	end
end)

-- =========================
-- BOTÃO FLUTUANTE (MOBILE)
-- =========================

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0,40,0,40)
btn.Position = UDim2.new(1,-50,0.5,-20)
btn.Text = "UI"
btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
btn.TextColor3 = Color3.new(1,1,1)
btn.Parent = MainUI

btn.MouseButton1Click:Connect(function()
	toggleUI()
end)

CORE:Log("Sistema de ocultar UI carregado")
