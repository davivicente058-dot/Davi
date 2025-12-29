--// PARTE 1 - BASE (RAYFIELD CORRETA)

-- Proteção básica
if _G.FPS_ULTRA_LOADED then return end
_G.FPS_ULTRA_LOADED = true

-- Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Janela
local Window = Rayfield:CreateWindow({
	Name = "FPS ULTRA • Mobile Edition",
	LoadingTitle = "FPS ULTRA",
	LoadingSubtitle = "Optimization Framework",
	ConfigurationSaving = {
		Enabled = false
	},
	KeySystem = false
})

-- Tabs
local TabMain = Window:CreateTab("⚡ Desempenho", 4483362458)
local TabVisual = Window:CreateTab("🎮 Gráficos", 4483362458)
local TabExtra = Window:CreateTab("🧠 Avançado", 4483362458)

-- Armazenar toggles globalmente (ISSO evita bugs)
_G.FPS_UI = {
	Toggles = {}
}

-- Toggles (todos DESATIVADOS)
_G.FPS_UI.Toggles.LowGraphics = TabVisual:CreateToggle({
	Name = "Gráficos Ultra Baixos",
	CurrentValue = false,
	Flag = "LowGraphics",
	Callback = function(_) end
})

_G.FPS_UI.Toggles.DisableShadows = TabVisual:CreateToggle({
	Name = "Desativar Sombras",
	CurrentValue = false,
	Flag = "DisableShadows",
	Callback = function(_) end
})

_G.FPS_UI.Toggles.ReduceParticles = TabExtra:CreateToggle({
	Name = "Reduzir Partículas",
	CurrentValue = false,
	Flag = "ReduceParticles",
	Callback = function(_) end
})

_G.FPS_UI.Toggles.ReduceAnimations = TabExtra:CreateToggle({
	Name = "Reduzir Animações",
	CurrentValue = false,
	Flag = "ReduceAnimations",
	Callback = function(_) end
})

_G.FPS_UI.Toggles.UltraMode = TabMain:CreateToggle({
	Name = "⚡ MODO ULTRA LEVE",
	CurrentValue = false,
	Flag = "UltraMode",
	Callback = function(_) end
})

Rayfield:Notify({
	Title = "FPS ULTRA",
	Content = "Base carregada com sucesso",
	Duration = 5
})

--// PARTE 2 - OTIMIZAÇÕES REAIS (RODANDO COM RAYFIELD)
--// Compatível com _G.FPS_UI.Toggles criado na Parte 1
--// Tudo começa desligado; alterações são aplicadas somente quando o jogador ativa

-- Segurança: existe a tabela global criada pela Parte 1?
if not _G.FPS_UI or not _G.FPS_UI.Toggles then
	warn("[FPS ULTRA] Parte 2: _G.FPS_UI.Toggles não encontrada. As toggles devem vir da Parte 1.")
	-- não retorna; vamos instalar fallback polling mesmo assim
end

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- BACKUP (para restaurar estados)
local BACKUP = {
	Parts = {},          -- store { part = {Material, Reflectance, CastShadow} }
	Particles = {},      -- store { emitter = Enabled }
	HumanoidTracks = {}, -- store track speeds for local player
	Lighting = {
		GlobalShadows = Lighting.GlobalShadows,
		Brightness = Lighting.Brightness,
		EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
		EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
		FogStart = Lighting.FogStart,
		FogEnd = Lighting.FogEnd,
		ExposureCompensation = Lighting.ExposureCompensation,
		Technology = Lighting.Technology
	},
	QualityLevel = pcall(function() return settings().Rendering.QualityLevel end) and settings().Rendering.QualityLevel or nil
}

-- UTIL: safe pcall wrapper
local function safe(fn)
	local ok, err = pcall(fn)
	if not ok then
		warn("[FPS ULTRA] erro:", err)
	end
end

-- UTIL: cache part properties once
local function cachePart(p)
	if not BACKUP.Parts[p] and p and p.Parent then
		BACKUP.Parts[p] = {
			Material = p.Material,
			Reflectance = p.Reflectance,
			CastShadow = p.CastShadow
		}
	end
end

-- FUNÇÃO: aplicar gráficos ultra baixos (aplica em partes seguras)
local function applyLowGraphics(enable)
	safe(function()
		if enable then
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("BasePart") then
					cachePart(obj)
					obj.Material = Enum.Material.SmoothPlastic
					obj.Reflectance = 0
					obj.CastShadow = false
				elseif obj:IsA("MeshPart") then
					cachePart(obj)
					obj.Material = Enum.Material.SmoothPlastic
				end
			end
			-- reduzir qualidade de render
			if BACKUP.QualityLevel then
				pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
			end
		else
			-- restaurar
			for part, props in pairs(BACKUP.Parts) do
				if part and part.Parent then
					pcall(function()
						part.Material = props.Material
						part.Reflectance = props.Reflectance
						part.CastShadow = props.CastShadow
					end)
				end
			end
			-- restaurar quality se backup existir
			if BACKUP.QualityLevel then
				pcall(function() settings().Rendering.QualityLevel = BACKUP.QualityLevel end)
			end
		end
	end)
end

-- FUNÇÃO: desativar/ativar sombras globais
local function setShadows(enabled)
	safe(function()
		if enabled then
			Lighting.GlobalShadows = false
		else
			-- restaurar original
			Lighting.GlobalShadows = BACKUP.Lighting.GlobalShadows
		end
	end)
end

-- FUNÇÃO: reduzir/reativar partículas (e trails)
local function setParticles(reduce)
	safe(function()
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
				if reduce then
					if BACKUP.Particles[obj] == nil then BACKUP.Particles[obj] = obj.Enabled end
					obj.Enabled = false
				else
					if BACKUP.Particles[obj] ~= nil then
						local prev = BACKUP.Particles[obj]
						obj.Enabled = prev
						BACKUP.Particles[obj] = nil
					else
						obj.Enabled = true
					end
				end
			end
		end
	end)
end

-- FUNÇÃO: reduzir/restaurar animações (pausar animações desnecessárias)
local function setAnimations(reduce)
	safe(function()
		local char = player.Character or player.CharacterAdded:Wait()
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end

		if reduce then
			-- pausa tracks and save speed
			for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
				-- salva velocidade antes de mudar
				if not BACKUP.HumanoidTracks[track] then
					local ok, s = pcall(function() return track.Speed end)
					BACKUP.HumanoidTracks[track] = ok and s or 1
				end
				pcall(function() track:AdjustSpeed(0.01) end)
			end
			-- opcional: reduzir walk/run animation speeds globalmente (não break anim)
			pcall(function() humanoid.WalkSpeed = humanoid.WalkSpeed end)
		else
			-- restaurar
			for track, speed in pairs(BACKUP.HumanoidTracks) do
				if track and track.IsPlaying and track.IsPlaying(track) then
					pcall(function() track:AdjustSpeed(speed) end)
				end
			end
			BACKUP.HumanoidTracks = {}
		end
	end)
end

-- FUNÇÃO: modo ultra (combina tudo para máximo ganho)
local function setUltraMode(enable)
	safe(function()
		if enable then
			-- lighting aggressive
			Lighting.GlobalShadows = false
			Lighting.EnvironmentDiffuseScale = 0
			Lighting.EnvironmentSpecularScale = 0
			Lighting.Brightness = math.clamp(Lighting.Brightness * 0.9, 0.3, 5)
			Lighting.FogEnd = 300

			-- apply collection
			applyLowGraphics(true)
			setParticles(true)
			setAnimations(true)
		else
			-- restore lighting backup
			for k, v in pairs(BACKUP.Lighting) do
				pcall(function() Lighting[k] = v end)
			end
			-- restore others
			applyLowGraphics(false)
			setParticles(false)
			setAnimations(false)
		end
	end)
end

-- HELPER: apply lighting preset by name (Padrao / Claro / Escuro)
local function setLightingPreset(name)
	safe(function()
		if name == "Padrao" then
			Lighting.GlobalShadows = BACKUP.Lighting.GlobalShadows
			Lighting.Brightness = BACKUP.Lighting.Brightness
			Lighting.EnvironmentDiffuseScale = BACKUP.Lighting.EnvironmentDiffuseScale
			Lighting.EnvironmentSpecularScale = BACKUP.Lighting.EnvironmentSpecularScale
			Lighting.FogStart = BACKUP.Lighting.FogStart
			Lighting.FogEnd = BACKUP.Lighting.FogEnd
			Lighting.ExposureCompensation = BACKUP.Lighting.ExposureCompensation
			Lighting.Technology = BACKUP.Lighting.Technology
		elseif name == "Claro" then
			Lighting.GlobalShadows = false
			Lighting.Brightness = math.max(1.5, BACKUP.Lighting.Brightness)
			Lighting.EnvironmentDiffuseScale = 0.6
			Lighting.EnvironmentSpecularScale = 0.2
			Lighting.FogEnd = BACKUP.Lighting.FogEnd
		elseif name == "Escuro" then
			Lighting.GlobalShadows = false
			Lighting.Brightness = math.max(0.6, BACKUP.Lighting.Brightness * 0.6)
			Lighting.EnvironmentDiffuseScale = 0.35
			Lighting.EnvironmentSpecularScale = 0.1
			Lighting.FogEnd = math.min(800, BACKUP.Lighting.FogEnd)
		end
	end)
end

-- ===============================
-- Conector Robusto com Rayfield Toggles (Vários fallbacks)
-- ===============================
local function safeConnectToggle(toggleObj, handler)
	-- try common Rayfield API names / patterns
	local ok, err = pcall(function()
		-- If toggleObj has a Connect method or OnChanged event
		if toggleObj and type(toggleObj) == "table" then
			-- attempt common property names
			if toggleObj.SetValue then
				-- keep initial false
				toggleObj:SetValue(false)
			end

			-- attempt to set Callback field (works if Rayfield stores it)
			if toggleObj.Callback ~= nil then
				toggleObj.Callback = handler
			end

			-- try connecting to an event named OnChanged / Changed / ValueChanged
			if toggleObj.OnChanged and type(toggleObj.OnChanged.Connect) == "function" then
				toggleObj.OnChanged:Connect(handler)
			elseif toggleObj.Changed and type(toggleObj.Changed.Connect) == "function" then
				toggleObj.Changed:Connect(handler)
			elseif toggleObj.ValueChanged and type(toggleObj.ValueChanged.Connect) == "function" then
				toggleObj.ValueChanged:Connect(handler)
			elseif toggleObj.Toggle and type(toggleObj.Toggle.Connect) == "function" then
				toggleObj.Toggle:Connect(handler)
			end
		end
	end)
	if not ok then
		-- fallback: do nothing — the global poller (below) will detect changes
		-- warn("[FPS ULTRA] safeConnectToggle fallback:", err)
	end
end

-- TRY TO HOOK ALL KNOWN TOGGLES (if present)
local toggles = (_G.FPS_UI and _G.FPS_UI.Toggles) or {}

-- low graphics
if toggles.LowGraphics then
	safeConnectToggle(toggles.LowGraphics, function(v)
		-- Rayfield usually passes boolean; if not, try to read CurrentValue
		local state = v
		-- if v is table or event with no param, try read property
		if type(state) ~= "boolean" then
			state = toggles.LowGraphics.CurrentValue or toggles.LowGraphics.Value or false
		end
		applyLowGraphics(state)
	end)
end

-- disable shadows
if toggles.DisableShadows then
	safeConnectToggle(toggles.DisableShadows, function(v)
		local state = v
		if type(state) ~= "boolean" then
			state = toggles.DisableShadows.CurrentValue or toggles.DisableShadows.Value or false
		end
		setShadows(state)
	end)
end

-- reduce particles
if toggles.ReduceParticles then
	safeConnectToggle(toggles.ReduceParticles, function(v)
		local state = v
		if type(state) ~= "boolean" then
			state = toggles.ReduceParticles.CurrentValue or toggles.ReduceParticles.Value or false
		end
		setParticles(state)
	end)
end

-- reduce animations
if toggles.ReduceAnimations then
	safeConnectToggle(toggles.ReduceAnimations, function(v)
		local state = v
		if type(state) ~= "boolean" then
			state = toggles.ReduceAnimations.CurrentValue or toggles.ReduceAnimations.Value or false
		end
		setAnimations(state)
	end)
end

-- ultra mode
if toggles.UltraMode then
	safeConnectToggle(toggles.UltraMode, function(v)
		local state = v
		if type(state) ~= "boolean" then
			state = toggles.UltraMode.CurrentValue or toggles.UltraMode.Value or false
		end
		setUltraMode(state)
	end)
end

-- ===============================
-- POLLER (FALLBACK) - verifica o estado das toggles a cada 0.35s
-- captura CurrentValue / Value / Flag propriedades comuns e aplica funções
-- ===============================
local prev = {}

task.spawn(function()
	while true do
		task.wait(0.35)
		-- LowGraphics
		local t = toggles.LowGraphics
		local val = false
		if t then
			val = (t.CurrentValue ~= nil and t.CurrentValue) or (t.Value ~= nil and t.Value) or (t.Flags and t.Flags.CurrentValue) or false
		end
		if prev.LowGraphics ~= val then
			prev.LowGraphics = val
			applyLowGraphics(val)
		end

		-- DisableShadows
		t = toggles.DisableShadows
		val = false
		if t then
			val = (t.CurrentValue ~= nil and t.CurrentValue) or (t.Value ~= nil and t.Value) or false
		end
		if prev.DisableShadows ~= val then
			prev.DisableShadows = val
			setShadows(val)
		end

		-- ReduceParticles
		t = toggles.ReduceParticles
		val = false
		if t then
			val = (t.CurrentValue ~= nil and t.CurrentValue) or (t.Value ~= nil and t.Value) or false
		end
		if prev.ReduceParticles ~= val then
			prev.ReduceParticles = val
			setParticles(val)
		end

		-- ReduceAnimations
		t = toggles.ReduceAnimations
		val = false
		if t then
			val = (t.CurrentValue ~= nil and t.CurrentValue) or (t.Value ~= nil and t.Value) or false
		end
		if prev.ReduceAnimations ~= val then
			prev.ReduceAnimations = val
			setAnimations(val)
		end

		-- UltraMode
		t = toggles.UltraMode
		val = false
		if t then
			val = (t.CurrentValue ~= nil and t.CurrentValue) or (t.Value ~= nil and t.Value) or false
		end
		if prev.UltraMode ~= val then
			prev.UltraMode = val
			setUltraMode(val)
		end
	end
end)

-- ===============================
-- FIM PARTE 2
-- Mensagem final
-- ===============================
print("[FPS ULTRA] Parte 2 carregada — otimizações reais prontas (listener/poller ativo).")

--// PARTE 3 - FPS INTELIGENTE + MIRA (ROBUSTO, RAYFIELD-FRIENDLY)
--// Requisitos: _G.FPS_UI.Toggles idealmente existente (Parte 1)
--// Se as toggles não existirem, a parte usa poller/fallback e cria controles locais mínimos

-- Segurança mínima
if not _G.FPS_ULTRA_LOADED then
	warn("[FPS ULTRA] Aviso: Parte 3 carregada antes da Parte 1/2. Recomenda-se colar em ordem.")
end

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Acesso a toggles (Rayfield)
local toggles = (_G.FPS_UI and _G.FPS_UI.Toggles) or {}

-- ====== HUD (FPS) ======
local function createFPSGui()
	-- cria GUI mas não ativa por padrão
	local gui = Instance.new("ScreenGui")
	gui.Name = "FPSUltra_HUD"
	gui.ResetOnSpawn = false
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	gui.Enabled = false

	local label = Instance.new("TextLabel", gui)
	label.Name = "FPSUltra_Label"
	label.AnchorPoint = Vector2.new(0, 0)
	label.Position = UDim2.new(0, 12, 1, -78) -- padrão bottom-left com margem
	label.Size = UDim2.new(0, 140, 0, 30)
	label.BackgroundTransparency = 0.22
	label.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
	label.BorderSizePixel = 0
	label.Text = "FPS: --"
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.TextColor3 = Color3.fromRGB(0, 255, 160)
	label.TextStrokeTransparency = 0.8
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center

	local corner = Instance.new("UICorner", label)
	corner.CornerRadius = UDim.new(0, 8)

	return gui, label
end

-- Create crosshair GUI (center) - minimal, low cost
local function createCrosshairGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "FPSUltra_Crosshair"
	gui.ResetOnSpawn = false
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	gui.Enabled = false

	-- container to center easily
	local container = Instance.new("Frame", gui)
	container.Size = UDim2.new(0, 0, 0, 0)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.new(0.5, 0.5, 0, 0)
	container.BackgroundTransparency = 1

	-- crosshair lines
	local thickness = 2
	local length = 10
	local color = Color3.fromRGB(255,255,255)
	local gap = 6

	local up = Instance.new("Frame", container)
	up.Size = UDim2.new(0, thickness, 0, length)
	up.Position = UDim2.new(0.5, 0, 0.5, -(length + gap))
	up.AnchorPoint = Vector2.new(0.5, 0.5)
	up.BackgroundColor3 = color
	up.BorderSizePixel = 0

	local down = Instance.new("Frame", container)
	down.Size = UDim2.new(0, thickness, 0, length)
	down.Position = UDim2.new(0.5, 0, 0.5, (length + gap))
	down.AnchorPoint = Vector2.new(0.5, 0.5)
	down.BackgroundColor3 = color
	down.BorderSizePixel = 0

	local left = Instance.new("Frame", container)
	left.Size = UDim2.new(0, length, 0, thickness)
	left.Position = UDim2.new(0.5, 0, 0.5, 0)
	left.AnchorPoint = Vector2.new(0.5, 0.5)
	left.BackgroundColor3 = color
	left.BorderSizePixel = 0
	left.Position = UDim2.new(0.5, -(length + gap), 0.5, 0)

	local right = Instance.new("Frame", container)
	right.Size = UDim2.new(0, length, 0, thickness)
	right.AnchorPoint = Vector2.new(0.5, 0.5)
	right.BackgroundColor3 = color
	right.BorderSizePixel = 0
	right.Position = UDim2.new(0.5, (length + gap), 0.5, 0)

	return gui
end

-- create HUD and crosshair once
local HUDGui, HUDLabel = createFPSGui()
local CrosshairGui = createCrosshairGui()

-- State
local HUDEnabled = false
local CrossEnabled = false

-- Smart FPS sampling: moving average with low overhead
local samples = {}
local maxSamples = 40 -- mais amostras = mais suave
local updateInterval = 0.25 -- atualiza texto 4x por segundo
local lastUpdate = 0
local lastTick = tick()

-- adaptive smoothing factor by device
local isMobile = UserInputService.TouchEnabled
if isMobile == nil then isMobile = false end
if isMobile then
	-- celular pode usar mais suavização
	maxSamples = 50
	updateInterval = 0.28
end

-- render stepped connection (lightweight)
local renderConn
renderConn = RunService.RenderStepped:Connect(function(dt)
	-- apenas coletar quando HUD ativo
	if not HUDGui.Enabled then return end

	-- compute instantaneous fps
	local now = tick()
	local fps = 1 / math.max(dt, 1/240) -- evita grandes deltas
	table.insert(samples, fps)
	if #samples > maxSamples then table.remove(samples, 1) end

	if now - lastUpdate >= updateInterval then
		lastUpdate = now
		-- compute avg
		local s = 0
		for _,v in ipairs(samples) do s = s + v end
		local avg = math.floor(s / #samples + 0.5)

		-- update label text
		if HUDLabel and HUDLabel.Parent then
			HUDLabel.Text = "FPS: " .. tostring(avg)
			-- color feedback
			if avg >= 60 then
				HUDLabel.TextColor3 = Color3.fromRGB(0, 255, 160)
			elseif avg >= 40 then
				HUDLabel.TextColor3 = Color3.fromRGB(255, 200, 60)
			else
				HUDLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
			end
		end
	end
end)

-- Clean up function if needed
local function disableAllHUD()
	HUDGui.Enabled = false
	CrosshairGui.Enabled = false
	samples = {}
end

-- ====== Intelligent placement for mobile analogs ======
-- Try to guess safe offset if on mobile (common bottom-left joystick)
local function adaptHUDPosition()
	if not HUDLabel or not HUDLabel.Parent then return end
	local screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	-- default margins
	local baseX = 12
	local baseY = 78

	-- if mobile, shift a bit more up
	if isMobile then
		baseY = 92
		-- detect small screens and adjust
		if screenSize.Y <= 720 then
			baseY = 110
		end
	end

	HUDLabel.Position = UDim2.new(0, baseX, 1, -baseY)
end

-- call once and on resize
adaptHUDPosition()
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adaptHUDPosition)
end

-- ====== Robust connection to Rayfield toggles ======
-- tries to connect to toggles if they exist, otherwise poller will read .CurrentValue / .Value
local function safeConnectToggleObj(obj, onChanged)
	if not obj then return end
	-- try common connectors
	local ok, err = pcall(function()
		if obj.Changed and type(obj.Changed.Connect) == "function" then
			obj.Changed:Connect(function()
				local v = obj.CurrentValue or obj.Value or false
				onChanged(v)
			end)
		elseif obj.OnChanged and type(obj.OnChanged.Connect) == "function" then
			obj.OnChanged:Connect(onChanged)
		elseif obj.ValueChanged and type(obj.ValueChanged.Connect) == "function" then
			obj.ValueChanged:Connect(onChanged)
		elseif type(obj.Callback) == "function" then
			-- Rayfield often stores callback; replace safely
			obj.Callback = onChanged
		end
	end)
	if not ok then
		-- ignore, poller will handle it
	end
end

-- handler functions
local function handleFPSToggle(v)
	local state = v
	if type(state) ~= "boolean" then
		state = (toggles.FPSCounter and (toggles.FPSCounter.CurrentValue or toggles.FPSCounter.Value)) or false
	end
	HUDGui.Enabled = state
	HUDEnabled = state
	if not state then
		-- clear samples to avoid stale data
		samples = {}
	end
	adaptHUDPosition()
end

local function handleCrossToggle(v)
	local state = v
	if type(state) ~= "boolean" then
		state = (toggles.Crosshair and (toggles.Crosshair.CurrentValue or toggles.Crosshair.Value)) or false
	end
	CrosshairGui.Enabled = state
	CrossEnabled = state
end

-- connect if toggles exist
safeConnectToggleObj(toggles.FPSCounter, handleFPSToggle)
safeConnectToggleObj(toggles.Crosshair, handleCrossToggle)

-- ====== FALLBACK POLLER (se toggles não executarem callbacks) ======
task.spawn(function()
	local prevFPS = false
	local prevCross = false
	while true do
		task.wait(0.25)
		-- FPS toggle poll
		local fpsVal = false
		if toggles.FPSCounter then
			fpsVal = (toggles.FPSCounter.CurrentValue ~= nil and toggles.FPSCounter.CurrentValue)
				or (toggles.FPSCounter.Value ~= nil and toggles.FPSCounter.Value)
				or false
		end
		if prevFPS ~= fpsVal then
			prevFPS = fpsVal
			handleFPSToggle(fpsVal)
		end

		-- Crosshair toggle poll
		local crossVal = false
		if toggles.Crosshair then
			crossVal = (toggles.Crosshair.CurrentValue ~= nil and toggles.Crosshair.CurrentValue)
				or (toggles.Crosshair.Value ~= nil and toggles.Crosshair.Value)
				or false
		end
		if prevCross ~= crossVal then
			prevCross = crossVal
			handleCrossToggle(crossVal)
		end
	end
end)

-- ====== If toggles don't exist at all, create local Rayfield toggles if possible (best-effort) ======
-- This tries to create toggles into _G.FPS_UI.Toggles using Rayfield's CreateToggle if available in global scope
task.spawn(function()
	task.wait(0.6)
	-- if toggles table exists but missing keys, and Rayfield Window is available, attempt to create
	if _G.FPS_UI and _G.FPS_UI.Toggles then
		local t = _G.FPS_UI.Toggles
		-- try to find Rayfield window object
		local RayfieldWindow = rawget(_G, "FPS_RAYFIELD_WINDOW") or rawget(_G, "FPS_UI_WINDOW") or nil
		-- if not present, try to find any global Rayfield-like window reference previously stored
		-- best-effort: if toggles table is empty but has metatable with CreateToggle, skip (rare)
		if not t.FPSCounter and RayfieldWindow and type(RayfieldWindow.CreateToggle) == "function" then
			local ok, newToggle = pcall(function()
				return RayfieldWindow:CreateToggle({ Name = "FPS Counter", CurrentValue = false, Callback = function(v) end })
			end)
			if ok and newToggle then
				t.FPSCounter = newToggle
				safeConnectToggleObj(newToggle, handleFPSToggle)
			end
		end
		if not t.Crosshair and RayfieldWindow and type(RayfieldWindow.CreateToggle) == "function" then
			local ok, newToggle = pcall(function()
				return RayfieldWindow:CreateToggle({ Name = "Crosshair", CurrentValue = false, Callback = function(v) end })
			end)
			if ok and newToggle then
				t.Crosshair = newToggle
				safeConnectToggleObj(newToggle, handleCrossToggle)
			end
		end
	end
end)

-- ====== Final print ======
print("[FPS ULTRA] Parte 3 carregada — FPS HUD e Crosshair prontos (integração Rayfield/poller).")

--// PARTE 4 - FLUIDEZ AVANÇADA (ANTI-STUTTER) - RAYFIELD FRIENDLY
--// Foco: deixar o jogo realmente LISO, sem interferir em outras partes
--// Requisitos: Parte 1+2+3 já carregadas (usa _G.FPS_UI.Toggles quando disponível)
--// Tudo começa DESATIVADO. Não sobrescreve outras otimizações.

-- Segurança: evitar múltiplas cargas
if _G.FPS_ULTRA_FLUID_LOADED then
	print("[FPS ULTRA] Parte 4 já carregada")
	return
end
_G.FPS_ULTRA_FLUID_LOADED = true

-- Serviços
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Referência de toggles (Rayfield)
local toggles = (_G.FPS_UI and _G.FPS_UI.Toggles) or {}

-- Tabela global de controle/restauração (segura)
_G.FPS_ULTRA_FLUID = _G.FPS_ULTRA_FLUID or {
	_enabled = false,
	_connections = {},
	_backup = {
		PostEffects = {},
		Lighting = {
			GlobalShadows = Lighting.GlobalShadows,
			EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
			EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
			Technology = Lighting.Technology
		},
		QualityLevel = (pcall(function() return settings().Rendering.QualityLevel end) and settings().Rendering.QualityLevel) or nil
	}
}

local FLUID = _G.FPS_ULTRA_FLUID

-- UTIL: pcall seguro
local function safe(fn)
	local ok, err = pcall(fn)
	if not ok then
		warn("[FPS ULTRA][FLUID] erro:", err)
	end
end

-- ============================
-- 1) POST-EFFECTS: backup & disable
-- ============================
local function disablePostEffects()
	safe(function()
		for _, child in ipairs(Lighting:GetChildren()) do
			if child:IsA("BlurEffect")
				or child:IsA("BloomEffect")
				or child:IsA("ColorCorrectionEffect")
				or child:IsA("SunRaysEffect")
				or child:IsA("DepthOfFieldEffect")
				or child:IsA("SunRaysEffect") then

				if FLUID._backup.PostEffects[child] == nil then
					FLUID._backup.PostEffects[child] = child.Enabled
				end
				child.Enabled = false
			end
		end
	end)
end

local function restorePostEffects()
	safe(function()
		for eff, val in pairs(FLUID._backup.PostEffects) do
			if eff and eff.Parent then
				pcall(function() eff.Enabled = val end)
			end
		end
		FLUID._backup.PostEffects = {}
	end)
end

-- ============================
-- 2) LIGHTING TWEAKS (leve)
-- ============================
local function applyLightingLightMode()
	safe(function()
		-- reduzir custo sem deixar escuro demais
		Lighting.GlobalShadows = false
		Lighting.EnvironmentDiffuseScale = math.clamp(FLUID._backup.Lighting.EnvironmentDiffuseScale * 0.6, 0, 1)
		Lighting.EnvironmentSpecularScale = math.clamp(FLUID._backup.Lighting.EnvironmentSpecularScale * 0.4, 0, 1)
		Lighting.Technology = Enum.Technology.Compatibility
	end)
end

local function restoreLightingBackup()
	safe(function()
		local b = FLUID._backup.Lighting
		if b then
			pcall(function()
				Lighting.GlobalShadows = b.GlobalShadows
				Lighting.EnvironmentDiffuseScale = b.EnvironmentDiffuseScale
				Lighting.EnvironmentSpecularScale = b.EnvironmentSpecularScale
				Lighting.Technology = b.Technology
			end)
		end
	end)
end

-- ============================
-- 3) FRAME SMOOTHING (leve, sem fake)
-- ============================
-- Objetivo: reduzir micro-stutter reunindo amostras e evitando executar trabalhos não críticos em picos
local sampleBuffer = {}
local sampleMax = 40
local lastUpdate = 0
local updateTextInterval = 0.4 -- usado apenas para debugging/consumo mínimo

local smoothingConnection

local function startFrameSmoothing()
	if smoothingConnection then return end

	smoothingConnection = RunService.RenderStepped:Connect(function(dt)
		-- se não ativo, não processa
		if not FLUID._enabled then return end

		-- coleta FPS instante
		local fps = 1 / math.max(dt, 1/240)
		table.insert(sampleBuffer, fps)
		if #sampleBuffer > sampleMax then table.remove(sampleBuffer, 1) end

		-- Se detecta pico muito alto no delta (micro-stutter), yield para o scheduler
		if dt > 0.045 then -- ~22 FPS threshold (pico)
			-- curto yield para permitir GC/IO do engine
			task.wait(0)
		end

		-- ocasionalmente balanceia tarefas de baixa prioridade
		if tick() - lastUpdate >= updateTextInterval then
			lastUpdate = tick()
			-- calcula média apenas por monitoramento (não usado pra manipular frames)
			local s = 0
			for _,v in ipairs(sampleBuffer) do s = s + v end
			local avg = math.floor(s / #sampleBuffer + 0.5)
			-- (opcional) poderia expor avg para UI, mas evitamos aqui para reduzir overhead
		end
	end)

	table.insert(FLUID._connections, smoothingConnection)
end

local function stopFrameSmoothing()
	if smoothingConnection then
		pcall(function() smoothingConnection:Disconnect() end)
		smoothingConnection = nil
	end
	sampleBuffer = {}
end

-- ============================
-- 4) ADAPTIVE QUALITY (fallback, muito leve)
-- ============================
-- Se FPS cair consistentemente, reduz QualityLevel temporariamente.
local adaptiveConnection
local function startAdaptiveQuality()
	if adaptiveConnection then return end

	local lowCounter = 0
	adaptiveConnection = RunService.Heartbeat:Connect(function(dt)
		if not FLUID._enabled then return end
		-- checar média rápida
		local nowFPS = 1 / math.max(dt, 1/240)
		if nowFPS < 32 then
			lowCounter = lowCounter + 1
		else
			lowCounter = 0
		end

		-- se em baixo por alguns ticks, reduzir quality (uma vez)
		if lowCounter >= 6 then -- ~6 frames consecutivos baixos
			-- set level low (só se backup existir)
			if FLUID._backup.QualityLevel then
				pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
			end
			lowCounter = 0
		end
	end)

	table.insert(FLUID._connections, adaptiveConnection)
end

local function stopAdaptiveQuality()
	if adaptiveConnection then
		pcall(function() adaptiveConnection:Disconnect() end)
		adaptiveConnection = nil
	end
	-- restaura quality original se existir
	if FLUID._backup.QualityLevel then
		pcall(function() settings().Rendering.QualityLevel = FLUID._backup.QualityLevel end)
	end
end

-- ============================
-- 5) FUNCTIONS: enable / disable FLUID
-- ============================
local function enableFluid()
	if FLUID._enabled then return end
	FLUID._enabled = true

	-- disable post effects (backup feito on first disable)
	disablePostEffects()

	-- apply light lighting changes
	applyLightingLightMode()

	-- start smoothing & adaptive systems
	startFrameSmoothing()
	startAdaptiveQuality()

	-- safety print
	-- print("[FPS ULTRA] Fluidez ativada")
end

local function disableFluid()
	if not FLUID._enabled then return end
	FLUID._enabled = false

	-- restore everything
	restorePostEffects()
	restoreLightingBackup()
	stopFrameSmoothing()
	stopAdaptiveQuality()

	-- cleanup RBE connections stored in table
	for _,c in ipairs(FLUID._connections) do
		pcall(function() if c and c.Connected then c:Disconnect() end end)
	end
	FLUID._connections = {}

	-- restore quality (redundant safety)
	if FLUID._backup.QualityLevel then
		pcall(function() settings().Rendering.QualityLevel = FLUID._backup.QualityLevel end)
	end

	-- print("[FPS ULTRA] Fluidez desativada")
end

-- ============================
-- 6) Robust link to Rayfield toggles (tries many names)
-- ============================
local function safeConnectToggle(toggleObj, handler)
	if not toggleObj then return end
	pcall(function()
		-- common Rayfield toggle: has Changed or Callback or OnChanged
		if toggleObj.Changed and type(toggleObj.Changed.Connect) == "function" then
			toggleObj.Changed:Connect(function()
				local v = toggleObj.CurrentValue or toggleObj.Value or false
				handler(v)
			end)
			return
		end
		if toggleObj.OnChanged and type(toggleObj.OnChanged.Connect) == "function" then
			toggleObj.OnChanged:Connect(handler)
			return
		end
		if type(toggleObj.Callback) == "function" then
			toggleObj.Callback = handler
			return
		end
	end)
	-- fallback: poller will catch it
end

-- try to connect by common keys (the UI base should have created toggles earlier)
local possibleKeys = {"Fluidez", "AdvancedStability", "SmoothFPS", "AdaptiveFluidity", "Fluidity", "FluidMode"}
local connected = false
for _, key in ipairs(possibleKeys) do
	local t = toggles[key] or (toggles[key:gsub(" ","")] and toggles[key:gsub(" ","")])
	if t then
		safeConnectToggle(t, function(v)
			-- some Rayfield callbacks pass event object; ensure boolean
			local state = (type(v) == "boolean") and v or (t.CurrentValue or t.Value or false)
			if state then enableFluid() else disableFluid() end
		end)
		connected = true
		break
	end
end

-- If no direct connection, add a toggle into _G.FPS_UI.Toggles if Rayfield window available (best-effort)
task.spawn(function()
	task.wait(0.6)
	if not connected and _G.FPS_UI and _G.FPS_UI.Window and type(_G.FPS_UI.Window.CreateToggle) == "function" then
		local ok, newt = pcall(function()
			return _G.FPS_UI.Window:CreateToggle({ Name = "Fluidez Avançada", CurrentValue = false, Callback = function(v) end })
		end)
		if ok and newt then
			_G.FPS_UI.Toggles.Fluidez = newt
			safeConnectToggle(newt, function(v)
				local state = (type(v) == "boolean") and v or (newt.CurrentValue or newt.Value or false)
				if state then enableFluid() else disableFluid() end
			end)
			connected = true
		end
	end
end)

-- ============================
-- 7) Poller fallback: checks several possible toggles periodically
-- ============================
task.spawn(function()
	local prev = false
	while true do
		task.wait(0.35)
		-- try known toggles in toggles table
		local state = false
		-- check direct keys first
		for _,k in ipairs(possibleKeys) do
			local t = toggles[k] or toggles[k:gsub(" ","")]
			if t then
				state = (t.CurrentValue ~= nil and t.CurrentValue) or (t.Value ~= nil and t.Value) or state
			end
		end
		-- also check a generic key 'AdvancedStability' or 'AdaptiveFluidity'
		if toggles.AdvancedStability then
			local t = toggles.AdvancedStability
			state = (t.CurrentValue ~= nil and t.CurrentValue) or (t.Value ~= nil and t.Value) or state
		end

		-- if state changed, toggle fluid
		if state ~= prev then
			prev = state
			if state then enableFluid() else disableFluid() end
		end
	end
end)

-- ============================
-- 8) Safety: expose functions for other parts if needed
-- ============================
_G.FPS_ULTRA_FLUID.enable = enableFluid
_G.FPS_ULTRA_FLUID.disable = disableFluid
_G.FPS_ULTRA_FLUID.isEnabled = function() return FLUID._enabled end

print("[FPS ULTRA] Parte 4 carregada — Fluidez Avançada pronta (não invasiva).")
```0

