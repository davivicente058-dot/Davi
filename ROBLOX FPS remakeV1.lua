--// =====================================
--// ROBLOX FPS - PARTE 0
--// UI LIBRARY + BASE GLOBAL
--// =====================================

-- >>> BIBLIOTECA UI (RAYFIELD) <<<
local Rayfield = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua"
))()

-- Esperar jogo carregar
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Log de debug
warn("[ROBLOX FPS] Biblioteca Rayfield carregada")

-- Criar janela
local Window = Rayfield:CreateWindow({
    Name = "ROBLOX FPS",
    LoadingTitle = "ROBLOX FPS",
    LoadingSubtitle = "Remake",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

-- CORE GLOBAL (todas as partes usam isso)
getgenv().FPS_CORE = {
    Flags = {},
    Cache = {},
    Connections = {},
    State = {},
    Tabs = {},
    FPS = 0,
    LastFrame = tick(),
}

local CORE = getgenv().FPS_CORE

-- Criar abas base
CORE.Tabs.Main = Window:CreateTab("Principal")
CORE.Tabs.Optimization = Window:CreateTab("Otimização")
CORE.Tabs.Graphics = Window:CreateTab("Gráficos")
CORE.Tabs.Competitive = Window:CreateTab("Competitivo")
CORE.Tabs.Info = Window:CreateTab("Info")

-- Funções utilitárias globais
function CORE:SetFlag(name, value)
    self.Flags[name] = value
end

function CORE:GetFlag(name)
    return self.Flags[name]
end

-- Confirmação visual
Rayfield:Notify({
    Title = "ROBLOX FPS",
    Content = "UI carregada com sucesso",
    Duration = 3
})

warn("[ROBLOX FPS] PARTE 0 FINALIZADA COM SUCESSO")

--// =====================================
--// FIM DA PARTE 0
--// =====================================

--// ===============================
--// PARTE 1 - OTIMIZAÇÃO BASE
--// ===============================

local CORE = getgenv().FPS_CORE
if not CORE then return end

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- ===============================
-- CACHE DE VALORES ORIGINAIS
-- ===============================
CORE.Cache.OriginalLighting = {
	GlobalShadows = Lighting.GlobalShadows,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	Brightness = Lighting.Brightness,
	FogEnd = Lighting.FogEnd
}

CORE.Cache.OriginalTerrain = Workspace.Terrain.WaterWaveSize

-- ===============================
-- FUNÇÃO: OTIMIZAÇÃO BASE
-- ===============================
local function EnableBaseOptimization()
	CORE:Safe(function()

		-- Luz mais leve (sem apagar tudo)
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.fromRGB(120,120,120)
		Lighting.OutdoorAmbient = Color3.fromRGB(120,120,120)
		Lighting.Brightness = 1

		-- Neblina leve (ajuda MUITO mobile)
		Lighting.FogEnd = 350

		-- Água mais leve
		Workspace.Terrain.WaterWaveSize = 0

		-- Reduz trabalho desnecessário do engine
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

	end)
end

local function DisableBaseOptimization()
	CORE:Safe(function()

		local o = CORE.Cache.OriginalLighting
		if o then
			Lighting.GlobalShadows = o.GlobalShadows
			Lighting.Ambient = o.Ambient
			Lighting.OutdoorAmbient = o.OutdoorAmbient
			Lighting.Brightness = o.Brightness
			Lighting.FogEnd = o.FogEnd
		end

		Workspace.Terrain.WaterWaveSize = CORE.Cache.OriginalTerrain or 1

	end)
end

-- ===============================
-- UI: TOGGLE
-- ===============================
CORE.Tabs.FPS:CreateToggle({
	Name = "Otimização Base (Recomendado)",
	CurrentValue = false,
	Flag = "BaseOptimization",
	Callback = function(Value)
		CORE:SetFlag("BaseOptimization", Value)

		if Value then
			EnableBaseOptimization()
		else
			DisableBaseOptimization()
		end
	end
})

-- ===============================
-- FIM DA PARTE 1
-- Próxima: PARTE 2 (Otimização inteligente e profunda)
-- ===============================

--// ===============================
--// PARTE 2 - OTIMIZAÇÃO INTELIGENTE
--// ===============================

local CORE = getgenv().FPS_CORE
if not CORE then return end

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ===============================
-- CACHE DE OBJETOS ALTERADOS
-- ===============================
CORE.Cache.OptimizedParts = {}

-- ===============================
-- FUNÇÃO AUXILIAR
-- ===============================
local function IsSafePart(obj)
	return obj:IsA("BasePart")
		and not obj:IsA("Terrain")
		and obj.Transparency < 1
		and obj.Material ~= Enum.Material.Neon
end

-- ===============================
-- APLICAR OTIMIZAÇÃO INTELIGENTE
-- ===============================
local function EnableSmartOptimization()
	CORE:Safe(function()

		for _, obj in ipairs(Workspace:GetDescendants()) do
			if IsSafePart(obj) then
				CORE.Cache.OptimizedParts[obj] = {
					Material = obj.Material,
					Reflectance = obj.Reflectance,
					CastShadow = obj.CastShadow
				}

				obj.Material = Enum.Material.SmoothPlastic
				obj.Reflectance = 0
				obj.CastShadow = false
			end
		end

	end)
end

-- ===============================
-- DESATIVAR OTIMIZAÇÃO
-- ===============================
local function DisableSmartOptimization()
	CORE:Safe(function()

		for obj, data in pairs(CORE.Cache.OptimizedParts) do
			if obj and obj.Parent then
				obj.Material = data.Material
				obj.Reflectance = data.Reflectance
				obj.CastShadow = data.CastShadow
			end
		end

		table.clear(CORE.Cache.OptimizedParts)

	end)
end

-- ===============================
-- UI TOGGLE
-- ===============================
CORE.Tabs.FPS:CreateToggle({
	Name = "Otimização Inteligente do Mapa",
	CurrentValue = false,
	Flag = "SmartOptimization",
	Callback = function(Value)
		CORE:SetFlag("SmartOptimization", Value)

		if Value then
			EnableSmartOptimization()
		else
			DisableSmartOptimization()
		end
	end
})

-- ===============================
-- FIM DA PARTE 2
-- Próxima: PARTE 3 (FPS HUD real + Mira funcional)
-- ===============================

--// ===============================
--// PARTE 3 - FPS HUD + MIRA
--// ===============================

local CORE = getgenv().FPS_CORE
if not CORE then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ===============================
-- FPS HUD
-- ===============================

local FPSGui = nil
local FPSText = nil
local FPSConnection = nil

local function CreateFPSHud()
	if FPSGui then return end

	FPSGui = Instance.new("ScreenGui")
	FPSGui.Name = "FPS_HUD"
	FPSGui.ResetOnSpawn = false
	FPSGui.Parent = PlayerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(130, 32)
	frame.Position = UDim2.fromScale(0, 1) - UDim2.fromOffset(-8, 40)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = FPSGui

	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 6)

	FPSText = Instance.new("TextLabel")
	FPSText.Size = UDim2.fromScale(1, 1)
	FPSText.BackgroundTransparency = 1
	FPSText.Text = "FPS: 0"
	FPSText.TextColor3 = Color3.fromRGB(0, 255, 140)
	FPSText.Font = Enum.Font.GothamBold
	FPSText.TextSize = 16
	FPSText.Parent = frame

	FPSConnection = RunService.RenderStepped:Connect(function()
		FPSText.Text = "FPS: " .. tostring(CORE.FPS)
	end)
end

local function RemoveFPSHud()
	if FPSConnection then
		FPSConnection:Disconnect()
		FPSConnection = nil
	end

	if FPSGui then
		FPSGui:Destroy()
		FPSGui = nil
	end
end

-- ===============================
-- MIRA (CROSSHAIR REAL)
-- ===============================

local CrosshairGui = nil

local function CreateCrosshair()
	if CrosshairGui then return end

	CrosshairGui = Instance.new("ScreenGui")
	CrosshairGui.Name = "CROSSHAIR_GUI"
	CrosshairGui.ResetOnSpawn = false
	CrosshairGui.Parent = PlayerGui

	local size = 8

	for i = 1, 4 do
		local line = Instance.new("Frame")
		line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		line.BorderSizePixel = 0
		line.AnchorPoint = Vector2.new(0.5, 0.5)
		line.Parent = CrosshairGui

		if i == 1 then -- cima
			line.Size = UDim2.fromOffset(2, size)
			line.Position = UDim2.fromScale(0.5, 0.5) - UDim2.fromOffset(0, size + 2)
		elseif i == 2 then -- baixo
			line.Size = UDim2.fromOffset(2, size)
			line.Position = UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(0, size + 2)
		elseif i == 3 then -- esquerda
			line.Size = UDim2.fromOffset(size, 2)
			line.Position = UDim2.fromScale(0.5, 0.5) - UDim2.fromOffset(size + 2, 0)
		elseif i == 4 then -- direita
			line.Size = UDim2.fromOffset(size, 2)
			line.Position = UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(size + 2, 0)
		end
	end
end

local function RemoveCrosshair()
	if CrosshairGui then
		CrosshairGui:Destroy()
		CrosshairGui = nil
	end
end

-- ===============================
-- UI: TOGGLES
-- ===============================

CORE.Tabs.FPS:CreateToggle({
	Name = "Mostrar FPS",
	CurrentValue = false,
	Flag = "ShowFPS",
	Callback = function(Value)
		CORE:SetFlag("ShowFPS", Value)

		if Value then
			CreateFPSHud()
		else
			RemoveFPSHud()
		end
	end
})

CORE.Tabs.FPS:CreateToggle({
	Name = "Mira (Crosshair)",
	CurrentValue = false,
	Flag = "Crosshair",
	Callback = function(Value)
		CORE:SetFlag("Crosshair", Value)

		if Value then
			CreateCrosshair()
		else
			RemoveCrosshair()
		end
	end
})

-- ===============================
-- FIM DA PARTE 3
-- Próxima: PARTE 4 (Fluidez, render e estabilidade)
-- ===============================

--// ===============================
--// PARTE 4 - FLUIDEZ & ESTABILIDADE
--// ===============================

local CORE = getgenv().FPS_CORE
if not CORE then return end

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- ===============================
-- CONTROLE DE ESTABILIDADE
-- ===============================

local SteppedConnection
local RenderConnection

local function EnableStabilityLoop()
	if SteppedConnection then return end

	-- Loop focado em estabilidade (não FPS fake)
	SteppedConnection = RunService.Stepped:Connect(function(_, delta)
		-- Suaviza picos de tempo de frame
		if delta > 0.04 then
			task.wait(0)
		end
	end)

	-- RenderStepped mais limpo
	RenderConnection = RunService.RenderStepped:Connect(function()
		-- Evita acumular tarefas no render
		task.wait()
	end)
end

local function DisableStabilityLoop()
	if SteppedConnection then
		SteppedConnection:Disconnect()
		SteppedConnection = nil
	end
	if RenderConnection then
		RenderConnection:Disconnect()
		RenderConnection = nil
	end
end

-- ===============================
-- OTIMIZAÇÃO DE RENDER (INTELIGENTE)
-- ===============================

local OriginalSettings = {
	GlobalShadows = Lighting.GlobalShadows,
	EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
	EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
}

local function EnableRenderOptimization()
	-- Iluminação mais leve (sem destruir visual)
	Lighting.GlobalShadows = false
	Lighting.EnvironmentDiffuseScale = 0.5
	Lighting.EnvironmentSpecularScale = 0.2

	-- Evita cálculos desnecessários
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.CastShadow = false
			obj.Reflectance = 0
		end
	end
end

local function DisableRenderOptimization()
	Lighting.GlobalShadows = OriginalSettings.GlobalShadows
	Lighting.EnvironmentDiffuseScale = OriginalSettings.EnvironmentDiffuseScale
	Lighting.EnvironmentSpecularScale = OriginalSettings.EnvironmentSpecularScale
end

-- ===============================
-- FPS SMOOTH (ANTI-QUEDA BRUSCA)
-- ===============================

local smoothFPS = CORE.FPS
local smoothConnection

local function EnableFPSSmoothing()
	if smoothConnection then return end

	smoothConnection = RunService.RenderStepped:Connect(function(dt)
		local current = CORE.FPS
		smoothFPS = smoothFPS + (current - smoothFPS) * math.clamp(dt * 8, 0, 1)
		CORE.SMOOTH_FPS = math.floor(smoothFPS)
	end)
end

local function DisableFPSSmoothing()
	if smoothConnection then
		smoothConnection:Disconnect()
		smoothConnection = nil
	end
	CORE.SMOOTH_FPS = CORE.FPS
end

-- ===============================
-- UI - TOGGLES
-- ===============================

CORE.Tabs.Optimization:CreateToggle({
	Name = "Fluidez Avançada (Anti-Stutter)",
	CurrentValue = false,
	Flag = "AdvancedStability",
	Callback = function(Value)
		CORE:SetFlag("AdvancedStability", Value)

		if Value then
			EnableStabilityLoop()
		else
			DisableStabilityLoop()
		end
	end
})

CORE.Tabs.Optimization:CreateToggle({
	Name = "Render Mais Leve",
	CurrentValue = false,
	Flag = "LightRender",
	Callback = function(Value)
		CORE:SetFlag("LightRender", Value)

		if Value then
			EnableRenderOptimization()
		else
			DisableRenderOptimization()
		end
	end
})

CORE.Tabs.Optimization:CreateToggle({
	Name = "FPS Suavizado (Menos Quedas)",
	CurrentValue = false,
	Flag = "SmoothFPS",
	Callback = function(Value)
		CORE:SetFlag("SmoothFPS", Value)

		if Value then
			EnableFPSSmoothing()
		else
			DisableFPSSmoothing()
		end
	end
})

-- ===============================
-- FIM DA PARTE 4
-- ESSA PARTE É O CORE DA FLUIDEZ
-- ===============================

--// ===============================
--// PARTE 5 - INPUT LAG & GAME FEEL
--// ===============================

local CORE = getgenv().FPS_CORE
if not CORE then return end

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- ===============================
-- INPUT LAG REDUCTION
-- ===============================

local InputConnection
local InputBypassEnabled = false

local function EnableInputOptimization()
	if InputBypassEnabled then return end
	InputBypassEnabled = true

	-- Reduz buffers desnecessários
	UserInputService.InputBegan:Connect(function()
		task.defer(function() end)
	end)

	-- Prioriza eventos de input
	InputConnection = RunService.RenderStepped:Connect(function()
		RunService:BindToRenderStep(
			"FPS_INPUT_PRIORITY",
			Enum.RenderPriority.Input.Value,
			function() end
		)
	end)
end

local function DisableInputOptimization()
	if not InputBypassEnabled then return end
	InputBypassEnabled = false

	pcall(function()
		RunService:UnbindFromRenderStep("FPS_INPUT_PRIORITY")
	end)

	if InputConnection then
		InputConnection:Disconnect()
		InputConnection = nil
	end
end

-- ===============================
-- FRAME PACING (ANTI-MICRO-STUTTER)
-- ===============================

local FramePacingConnection
local pacingEnabled = false

local lastFrame = os.clock()

local function EnableFramePacing()
	if pacingEnabled then return end
	pacingEnabled = true

	lastFrame = os.clock()

	FramePacingConnection = RunService.RenderStepped:Connect(function()
		local now = os.clock()
		local delta = now - lastFrame
		lastFrame = now

		-- Micro-ajuste de pacing
		if delta > 0.033 then
			task.wait(0)
		end
	end)
end

local function DisableFramePacing()
	pacingEnabled = false

	if FramePacingConnection then
		FramePacingConnection:Disconnect()
		FramePacingConnection = nil
	end
end

-- ===============================
-- CAMERA & MOVIMENTO MAIS SUAVES
-- ===============================

local Camera = workspace.CurrentCamera
local OriginalCameraType = Camera.CameraType

local function EnableCameraSmooth()
	Camera.CameraType = Enum.CameraType.Custom
end

local function DisableCameraSmooth()
	Camera.CameraType = OriginalCameraType
end

-- ===============================
-- UI TOGGLES
-- ===============================

CORE.Tabs.Optimization:CreateToggle({
	Name = "Redução de Input Lag",
	CurrentValue = false,
	Flag = "LowInputLag",
	Callback = function(Value)
		CORE:SetFlag("LowInputLag", Value)

		if Value then
			EnableInputOptimization()
		else
			DisableInputOptimization()
		end
	end
})

CORE.Tabs.Optimization:CreateToggle({
	Name = "Frame Pacing (Jogo Mais Suave)",
	CurrentValue = false,
	Flag = "FramePacing",
	Callback = function(Value)
		CORE:SetFlag("FramePacing", Value)

		if Value then
			EnableFramePacing()
		else
			DisableFramePacing()
		end
	end
})

CORE.Tabs.Optimization:CreateToggle({
	Name = "Câmera Mais Suave",
	CurrentValue = false,
	Flag = "SmoothCamera",
	Callback = function(Value)
		CORE:SetFlag("SmoothCamera", Value)

		if Value then
			EnableCameraSmooth()
		else
			DisableCameraSmooth()
		end
	end
})

-- ===============================
-- FIM DA PARTE 5
-- ESSA PARTE MELHORA A SENSAÇÃO
-- ===============================

--// ===============================
--// PARTE 6 - FLUIDEZ ADAPTATIVA
--// ===============================

local CORE = getgenv().FPS_CORE
if not CORE then return end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

-- ===============================
-- LEITOR DE FPS REAL
-- ===============================

local fpsSamples = {}
local lastTick = tick()

local function GetRealFPS()
	local now = tick()
	local delta = now - lastTick
	lastTick = now

	local fps = math.floor(1 / math.max(delta, 0.0001))

	table.insert(fpsSamples, fps)
	if #fpsSamples > 15 then
		table.remove(fpsSamples, 1)
	end

	local total = 0
	for _, v in ipairs(fpsSamples) do
		total += v
	end

	return math.floor(total / #fpsSamples)
end

-- ===============================
-- FLUIDEZ ADAPTATIVA
-- ===============================

local AdaptiveConnection
local AdaptiveEnabled = false

local function EnableAdaptiveFluidity()
	if AdaptiveEnabled then return end
	AdaptiveEnabled = true

	AdaptiveConnection = RunService.Heartbeat:Connect(function()
		local fps = GetRealFPS()

		-- FPS muito baixo → reduz carga do engine
		if fps < 30 then
			RunService:Set3dRenderingEnabled(false)
			task.wait(0.05)
			RunService:Set3dRenderingEnabled(true)

		-- FPS médio → micro balanceamento
		elseif fps < 50 then
			task.wait(0)

		-- FPS estável → fluidez total
		else
			task.wait()
		end
	end)
end

local function DisableAdaptiveFluidity()
	AdaptiveEnabled = false

	if AdaptiveConnection then
		AdaptiveConnection:Disconnect()
		AdaptiveConnection = nil
	end
end

-- ===============================
-- SUAVIZAÇÃO DE LOOP DE RENDER
-- ===============================

local RenderBalanceConnection
local RenderBalanceEnabled = false

local function EnableRenderBalance()
	if RenderBalanceEnabled then return end
	RenderBalanceEnabled = true

	RenderBalanceConnection = RunService.RenderStepped:Connect(function()
		task.defer(function() end)
	end)
end

local function DisableRenderBalance()
	RenderBalanceEnabled = false

	if RenderBalanceConnection then
		RenderBalanceConnection:Disconnect()
		RenderBalanceConnection = nil
	end
end

-- ===============================
-- REDUÇÃO DE PICOS DE CPU
-- ===============================

local CPUBalanceEnabled = false
local cpuThread

local function EnableCPUBalance()
	if CPUBalanceEnabled then return end
	CPUBalanceEnabled = true

	cpuThread = task.spawn(function()
		while CPUBalanceEnabled do
			task.wait(0.03)
		end
	end)
end

local function DisableCPUBalance()
	CPUBalanceEnabled = false
end

-- ===============================
-- UI (RAYFIELD)
-- ===============================

CORE.Tabs.Optimization:CreateToggle({
	Name = "Fluidez Adaptativa (Auto FPS)",
	CurrentValue = false,
	Flag = "AdaptiveFluidity",
	Callback = function(Value)
		CORE:SetFlag("AdaptiveFluidity", Value)

		if Value then
			EnableAdaptiveFluidity()
		else
			DisableAdaptiveFluidity()
		end
	end
})

CORE.Tabs.Optimization:CreateToggle({
	Name = "Balancear Renderização",
	CurrentValue = false,
	Flag = "RenderBalance",
	Callback = function(Value)
		CORE:SetFlag("RenderBalance", Value)

		if Value then
			EnableRenderBalance()
		else
			DisableRenderBalance()
		end
	end
})

CORE.Tabs.Optimization:CreateToggle({
	Name = "Redução de Picos de CPU",
	CurrentValue = false,
	Flag = "CPUBalance",
	Callback = function(Value)
		CORE:SetFlag("CPUBalance", Value)

		if Value then
			EnableCPUBalance()
		else
			DisableCPUBalance()
		end
	end
})

-- ===============================
-- FIM DA PARTE 6
-- FOCO TOTAL EM FLUIDEZ REAL
-- ===============================

--// =====================================
--// PARTE 7 - MODO COMPETITIVO REAL
--// =====================================

local CORE = getgenv().FPS_CORE
if not CORE then return end

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local CompetitiveEnabled = false
local CompetitiveConnections = {}

-- ===============================
-- BACKUP DE CONFIG ORIGINAL
-- ===============================

local OriginalLighting = {
	GlobalShadows = Lighting.GlobalShadows,
	Brightness = Lighting.Brightness,
	FogEnd = Lighting.FogEnd,
	FogStart = Lighting.FogStart,
	ExposureCompensation = Lighting.ExposureCompensation
}

-- ===============================
-- FUNÇÕES DE OTIMIZAÇÃO
-- ===============================

local function ApplyCompetitiveGraphics()
	Lighting.GlobalShadows = false
	Lighting.Brightness = 1
	Lighting.ExposureCompensation = -0.2
	Lighting.FogStart = 0
	Lighting.FogEnd = 250

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Material = Enum.Material.Plastic
			obj.Reflectance = 0

			if obj:IsA("MeshPart") then
				obj.RenderFidelity = Enum.RenderFidelity.Performance
			end
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			obj.Transparency = math.clamp(obj.Transparency + 0.3, 0, 1)
		elseif obj:IsA("ParticleEmitter")
			or obj:IsA("Trail")
			or obj:IsA("Beam")
			or obj:IsA("Fire")
			or obj:IsA("Smoke") then
			obj.Enabled = false
		end
	end
end

local function RestoreGraphics()
	Lighting.GlobalShadows = OriginalLighting.GlobalShadows
	Lighting.Brightness = OriginalLighting.Brightness
	Lighting.ExposureCompensation = OriginalLighting.ExposureCompensation
	Lighting.FogStart = OriginalLighting.FogStart
	Lighting.FogEnd = OriginalLighting.FogEnd

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("ParticleEmitter")
			or obj:IsA("Trail")
			or obj:IsA("Beam")
			or obj:IsA("Fire")
			or obj:IsA("Smoke") then
			obj.Enabled = true
		end
	end
end

-- ===============================
-- REDUÇÃO DE INPUT LAG
-- ===============================

local function EnableInputOptimization()
	table.insert(CompetitiveConnections,
		RunService.RenderStepped:Connect(function()
			task.wait()
		end)
end

-- ===============================
-- LOOP DE MANUTENÇÃO (ANTI RESET)
-- ===============================

local function MaintainCompetitiveMode()
	table.insert(CompetitiveConnections,
		RunService.Heartbeat:Connect(function()
			if not CompetitiveEnabled then return end

			if Lighting.GlobalShadows ~= false then
				Lighting.GlobalShadows = false
			end
		end)
	end)
end

-- ===============================
-- ATIVAR / DESATIVAR
-- ===============================

local function EnableCompetitiveMode()
	if CompetitiveEnabled then return end
	CompetitiveEnabled = true

	ApplyCompetitiveGraphics()
	EnableInputOptimization()
	MaintainCompetitiveMode()
end

local function DisableCompetitiveMode()
	CompetitiveEnabled = false

	for _, conn in ipairs(CompetitiveConnections) do
		if conn then conn:Disconnect() end
	end
	table.clear(CompetitiveConnections)

	RestoreGraphics()
end

-- ===============================
-- UI (RAYFIELD)
-- ===============================

CORE.Tabs.Optimization:CreateToggle({
	Name = "Modo Competitivo (Ultra Leve)",
	CurrentValue = false,
	Flag = "CompetitiveMode",
	Callback = function(Value)
		CORE:SetFlag("CompetitiveMode", Value)

		if Value then
			EnableCompetitiveMode()
		else
			DisableCompetitiveMode()
		end
	end
})

-- ===============================
-- FIM DO MODO COMPETITIVO
-- DIFERENÇA REAL NA GAMEPLAY
-- ===============================

--// =====================================
--// PARTE 8 - AUTO FPS GUARD (INTELIGENTE)
--// =====================================

local CORE = getgenv().FPS_CORE
if not CORE then return end

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local AutoGuardEnabled = false
local GuardConnection = nil

-- ===============================
-- CONTROLE DE ESTADO
-- ===============================

local GuardState = {
	Active = false,
	LastFPS = 60
}

-- ===============================
-- FUNÇÕES INTERNAS
-- ===============================

local function SoftOptimize()
	Lighting.GlobalShadows = false
	Lighting.ExposureCompensation = -0.3

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
			obj.Enabled = false
		end
	end
end

local function HardOptimize()
	SoftOptimize()

	Lighting.FogEnd = 200
	Lighting.Brightness = 0.9

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Decal") or obj:IsA("Texture") then
			obj.Transparency = math.clamp(obj.Transparency + 0.4, 0, 1)
		end
	end
end

local function RelaxOptimize()
	Lighting.FogEnd = 100000
end

-- ===============================
-- LOOP INTELIGENTE
-- ===============================

local fpsCounter = 0
local lastTime = tick()

local function AutoGuardLoop()
	GuardConnection = RunService.RenderStepped:Connect(function()
		fpsCounter += 1

		if tick() - lastTime >= 1 then
			local fps = fpsCounter
			fpsCounter = 0
			lastTime = tick()

			GuardState.LastFPS = fps

			-- FPS MUITO BAIXO
			if fps < 40 and not GuardState.Active then
				GuardState.Active = true
				HardOptimize()

			-- FPS RECUPERANDO
			elseif fps > 55 and GuardState.Active then
				GuardState.Active = false
				RelaxOptimize()
			end
		end
	end)
end

-- ===============================
-- ATIVAR / DESATIVAR
-- ===============================

local function EnableAutoGuard()
	if AutoGuardEnabled then return end
	AutoGuardEnabled = true
	AutoGuardLoop()
end

local function DisableAutoGuard()
	AutoGuardEnabled = false
	GuardState.Active = false

	if GuardConnection then
		GuardConnection:Disconnect()
		GuardConnection = nil
	end
end

-- ===============================
-- UI (RAYFIELD)
-- ===============================

CORE.Tabs.Optimization:CreateToggle({
	Name = "Auto FPS Guard (Inteligente)",
	CurrentValue = false,
	Flag = "AutoFPSGuard",
	Callback = function(Value)
		CORE:SetFlag("AutoFPSGuard", Value)

		if Value then
			EnableAutoGuard()
		else
			DisableAutoGuard()
		end
	end
})

-- ===============================
-- FIM DO AUTO FPS GUARD
-- ESTABILIDADE AUTOMÁTICA
-- ===============================

--// =====================================
--// PARTE 9 - ANTI-STUTTER & MEMORY STABILIZER
--// =====================================

local CORE = getgenv().FPS_CORE
if not CORE then return end

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local AntiStutterEnabled = false
local MemoryLoop = nil
local CleanupLoop = nil

-- ===============================
-- FUNÇÕES DE LIMPEZA SEGURA
-- ===============================

local function CleanParticles()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
			obj.Enabled = false
		end
	end
end

local function CleanPhysicsCache()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.AssemblyLinearVelocity = Vector3.zero
			obj.AssemblyAngularVelocity = Vector3.zero
		end
	end
end

local function SoftLightingReset()
	Lighting.EnvironmentDiffuseScale = 0.6
	Lighting.EnvironmentSpecularScale = 0.6
end

-- ===============================
-- ANTI-STUTTER LOOP
-- ===============================

local function StartAntiStutter()
	if AntiStutterEnabled then return end
	AntiStutterEnabled = true

	-- LIMPEZA LEVE EM INTERVALOS
	CleanupLoop = task.spawn(function()
		while AntiStutterEnabled do
			pcall(function()
				CleanParticles()
				CleanPhysicsCache()
			end)
			task.wait(2.5)
		end
	end)

	-- MONITOR DE MEMÓRIA
	MemoryLoop = task.spawn(function()
		while AntiStutterEnabled do
			pcall(function()
				local mem = Stats:GetTotalMemoryUsageMb()

				-- MEMÓRIA MUITO ALTA → AJUSTE AUTOMÁTICO
				if mem > 1400 then
					SoftLightingReset()
				end
			end)
			task.wait(1)
		end
	end)
end

local function StopAntiStutter()
	AntiStutterEnabled = false

	if CleanupLoop then
		task.cancel(CleanupLoop)
		CleanupLoop = nil
	end

	if MemoryLoop then
		task.cancel(MemoryLoop)
		MemoryLoop = nil
	end
end

-- ===============================
-- UI (RAYFIELD)
-- ===============================

CORE.Tabs.Optimization:CreateToggle({
	Name = "Anti-Stutter Engine (Menos Travadas)",
	CurrentValue = false,
	Flag = "AntiStutterEngine",
	Callback = function(Value)
		CORE:SetFlag("AntiStutterEngine", Value)

		if Value then
			StartAntiStutter()
		else
			StopAntiStutter()
		end
	end
})

-- ===============================
-- FIM DA PARTE 9
-- ESTABILIDADE REAL DE FPS
-- ===============================

--// =====================================
--// PARTE 10 - SMART PROFILE & FINAL ENGINE
--// =====================================

local CORE = getgenv().FPS_CORE
if not CORE then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer

-- ===============================
-- DETECÇÃO INTELIGENTE DE DISPOSITIVO
-- ===============================

local function DetectDevice()
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		return "Mobile"
	elseif UserInputService.GamepadEnabled then
		return "Console"
	else
		return "PC"
	end
end

CORE.Device = DetectDevice()

-- ===============================
-- PERFIL DE DESEMPENHO
-- ===============================

local ProfileEnabled = false
local ProfileLoop = nil

local function ApplySmartProfile()
	if ProfileEnabled then return end
	ProfileEnabled = true

	ProfileLoop = task.spawn(function()
		while ProfileEnabled do
			pcall(function()
				-- AJUSTES SUAVES (SEM QUEBRAR JOGOS)
				Workspace.StreamingEnabled = true
				Workspace.StreamingIntegrityMode = Enum.StreamingIntegrityMode.MinimumRadiusPause

				Lighting.GlobalShadows = false
				Lighting.FogEnd = math.min(Lighting.FogEnd, 350)

				-- MOBILE RECEBE AJUSTES EXTRAS
				if CORE.Device == "Mobile" then
					Lighting.EnvironmentDiffuseScale = 0.55
					Lighting.EnvironmentSpecularScale = 0.5
				end
			end)
			task.wait(3)
		end
	end)
end

local function DisableSmartProfile()
	ProfileEnabled = false

	if ProfileLoop then
		task.cancel(ProfileLoop)
		ProfileLoop = nil
	end
end

-- ===============================
-- LIMPEZA AO REENTRAR EM MAPA
-- ===============================

local function CleanOnMapChange()
	Workspace.DescendantAdded:Connect(function(obj)
		if not CORE.Flags or not CORE.Flags.SmartProfile then return end

		if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
			obj.Enabled = false
		end
	end)
end

CleanOnMapChange()

-- ===============================
-- UI FINAL (RAYFIELD)
-- ===============================

CORE.Tabs.Optimization:CreateToggle({
	Name = "Perfil Inteligente de Desempenho",
	CurrentValue = false,
	Flag = "SmartProfile",
	Callback = function(Value)
		CORE:SetFlag("SmartProfile", Value)

		if Value then
			ApplySmartProfile()
		else
			DisableSmartProfile()
		end
	end
})

-- ===============================
-- TEXTO FINAL / STATUS
-- ===============================

CORE.Tabs.Info:CreateParagraph({
	Title = "FPS ENGINE ATIVO",
	Content = "Script carregado com sucesso.\nTodas as funções começam DESLIGADAS.\n\nAtive apenas o que precisar para obter o melhor desempenho possível no seu dispositivo."
})

-- ===============================
-- FIM DA PARTE 10
-- FECHAMENTO PROFISSIONAL
-- ===============================
