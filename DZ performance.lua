-- =========================================
-- DZ PERFORMANCE - UI BASE V2 (DRAG + MINI)
-- =========================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "DZ_UI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- =========================
-- MAIN
-- =========================

local main = Instance.new("Frame")
main.Size = UDim2.new(0,220,0,260)
main.Position = UDim2.new(0.05,0,0.3,0)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0,8)

-- =========================
-- TITLE
-- =========================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "DZ Performance"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = main

-- =========================
-- BOTÕES
-- =========================

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0,30,0,30)
minimize.Position = UDim2.new(1,-60,0,0)
minimize.Text = "-"
minimize.BackgroundTransparency = 1
minimize.TextColor3 = Color3.new(1,1,1)
minimize.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-30,0,0)
close.Text = "X"
close.BackgroundTransparency = 1
close.TextColor3 = Color3.new(1,1,1)
close.Parent = main

-- =========================
-- CONTAINER
-- =========================

local container = Instance.new("Frame")
container.Size = UDim2.new(1,0,1,-30)
container.Position = UDim2.new(0,0,0,30)
container.BackgroundTransparency = 1
container.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,6)
layout.Parent = container

-- =========================
-- MINI QUADRADO DZ (DRAG)
-- =========================

local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0,50,0,50)
mini.Position = main.Position
mini.BackgroundColor3 = Color3.fromRGB(0,0,0)
mini.Text = "DZ"
mini.TextColor3 = Color3.new(1,1,1)
mini.Font = Enum.Font.GothamBlack
mini.TextSize = 18
mini.Visible = false
mini.Parent = gui

Instance.new("UICorner", mini).CornerRadius = UDim.new(0,8)

-- =========================
-- DRAG SYSTEM (MAIN + MINI)
-- =========================

local function makeDraggable(frame)

	local dragging = false
	local dragInput, startPos, startFramePos

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 
		or input.UserInputType == Enum.UserInputType.Touch then
			
			dragging = true
			startPos = input.Position
			startFramePos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement 
		or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - startPos
			frame.Position = UDim2.new(
				startFramePos.X.Scale,
				startFramePos.X.Offset + delta.X,
				startFramePos.Y.Scale,
				startFramePos.Y.Offset + delta.Y
			)
		end
	end)
end

makeDraggable(main)
makeDraggable(mini)

-- =========================
-- TOGGLE SYSTEM (SWITCH)
-- =========================

local function createToggle(name, callback)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,-10,0,35)
	frame.BackgroundTransparency = 1
	frame.Parent = container

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0,40,0,20)
	button.Position = UDim2.new(1,-45,0.5,-10)
	button.BackgroundColor3 = Color3.fromRGB(50,50,50)
	button.Text = ""
	button.Parent = frame

	Instance.new("UICorner", button).CornerRadius = UDim.new(1,0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0,18,0,18)
	knob.Position = UDim2.new(0,1,0.5,-9)
	knob.BackgroundColor3 = Color3.new(1,1,1)
	knob.Parent = button

	Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

	local state = false

	button.MouseButton1Click:Connect(function()
		state = not state

		if state then
			button.BackgroundColor3 = Color3.fromRGB(0,170,255)
			knob.Position = UDim2.new(1,-19,0.5,-9)
		else
			button.BackgroundColor3 = Color3.fromRGB(50,50,50)
			knob.Position = UDim2.new(0,1,0.5,-9)
		end

		if callback then
			callback(state)
		end
	end)
end

-- =========================
-- CONTROLES
-- =========================

minimize.MouseButton1Click:Connect(function()
	main.Visible = false
	mini.Visible = true
end)

mini.MouseButton1Click:Connect(function()
	main.Visible = true
	mini.Visible = false
end)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- =========================
-- EXPORT
-- =========================

_G.DZ = {}
_G.DZ.CreateToggle = createToggle

-- =========================================
-- DZ PERFORMANCE - MODO CASUAL (OTIMIZADO)
-- =========================================

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Active = false
local Running = false

-- =========================
-- OTIMIZAÇÃO LEVE
-- =========================

local function optimizeBatch(objects, startIndex, batchSize)
	for i = startIndex, math.min(startIndex + batchSize - 1, #objects) do
		local obj = objects[i]

		if obj and obj:IsA("BasePart") then
			
			-- REMOVE SOMBRA PESADA
			if obj.CastShadow then
				obj.CastShadow = false
			end

			-- SIMPLIFICA MATERIAL (SEM QUEBRAR TUDO)
			if obj.Material ~= Enum.Material.Plastic then
				obj.Material = Enum.Material.SmoothPlastic
			end

			-- MICRO AJUSTE VISUAL (leve)
			if obj.Reflectance > 0 then
				obj.Reflectance = 0
			end

		end
	end
end

-- =========================
-- LOOP INTELIGENTE
-- =========================

local function start()
	if Running then return end
	Running = true

	task.spawn(function()
		while Active do

			local objects = Workspace:GetDescendants()
			local batchSize = 120

			for i = 1, #objects, batchSize do
				if not Active then break end

				optimizeBatch(objects, i, batchSize)

				task.wait() -- ESSENCIAL (anti travamento)
			end

			task.wait(2) -- intervalo leve (sem spam)
		end

		Running = false
	end)
end

local function stop()
	-- não precisa resetar (evita lag)
end

-- =========================
-- TOGGLE UI
-- =========================

_G.DZ.CreateToggle("Modo Casual (FPS + Fluidez)", function(state)
	Active = state

	if state then
		start()
	else
		stop()
	end
end)

-- =========================================
-- DZ PERFORMANCE - MODO COMPETITIVO (PRO)
-- =========================================

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Active = false
local Running = false
local Connection = nil

-- =========================
-- OTIMIZAÇÃO INSTANTÂNEA
-- =========================

local function optimizeObject(obj)

	-- PARTES
	if obj:IsA("BasePart") then
		obj.CastShadow = false
		obj.Material = Enum.Material.SmoothPlastic
		obj.Reflectance = 0
	end

	-- VFX (redução inteligente)
	if obj:IsA("ParticleEmitter") then
		obj.Rate = math.min(obj.Rate, 6)
	end

	if obj:IsA("Trail") then
		obj.Lifetime = 0.08
	end

	if obj:IsA("Beam") then
		obj.Width0 = 0.1
		obj.Width1 = 0.1
	end

	-- LUZES
	if obj:IsA("PointLight") or obj:IsA("SpotLight") then
		obj.Brightness = 0.5
	end
end

-- =========================
-- PROCESSO EM LOTE (ANTI LAG)
-- =========================

local function processBatch()

	local objects = Workspace:GetDescendants()
	local batchSize = 150

	for i = 1, #objects, batchSize do
		if not Active then break end

		for j = i, math.min(i + batchSize - 1, #objects) do
			local obj = objects[j]
			if obj then
				optimizeObject(obj)
			end
		end

		task.wait()
	end
end

-- =========================
-- NOVOS OBJETOS (IMPORTANTE)
-- =========================

local function hookNewObjects()

	if Connection then return end

	Connection = Workspace.DescendantAdded:Connect(function(obj)
		if Active then
			task.defer(function()
				optimizeObject(obj)
			end)
		end
	end)
end

local function unhook()
	if Connection then
		Connection:Disconnect()
		Connection = nil
	end
end

-- =========================
-- LOOP ESTÁVEL (ANTI DROP)
-- =========================

local function start()

	if Running then return end
	Running = true

	hookNewObjects()

	task.spawn(function()
		while Active do
			
			processBatch()

			task.wait(2) -- evita spam
		end

		unhook()
		Running = false
	end)

	-- micro estabilidade
	RunService.Heartbeat:Connect(function()
		if Active then
			RunService:Set3dRenderingEnabled(true)
		end
	end)
end

local function stop()
	unhook()
end

-- =========================
-- TOGGLE
-- =========================

_G.DZ.CreateToggle("Modo Competitivo (FPS + Estabilidade)", function(state)
	Active = state

	if state then
		start()
	else
		stop()
	end
end)

-- =========================================
-- DZ PERFORMANCE - MODO BATATA (EXTREMO)
-- =========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Active = false
local Running = false
local Connection = nil

-- =========================
-- OTIMIZAÇÃO EXTREMA
-- =========================

local function optimize(obj)

	-- PARTES (mínimo possível)
	if obj:IsA("BasePart") then
		obj.CastShadow = false
		obj.Material = Enum.Material.Plastic
		obj.Reflectance = 0
	end

	-- VFX QUASE ZERO
	if obj:IsA("ParticleEmitter") then
		obj.Rate = 1
	end

	if obj:IsA("Trail") then
		obj.Enabled = false
	end

	if obj:IsA("Beam") then
		obj.Enabled = false
	end

	-- LUZES
	if obj:IsA("PointLight") or obj:IsA("SpotLight") then
		obj.Brightness = 0
	end
end

-- =========================
-- LIMPAR PLAYERS (ROUPAS)
-- =========================

local function cleanCharacter(char)

	for _, v in ipairs(char:GetDescendants()) do
		
		-- remove roupas
		if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
			v:Destroy()
		end

		-- remove acessórios
		if v:IsA("Accessory") then
			v:Destroy()
		end

	end
end

-- =========================
-- PROCESSO EM LOTE
-- =========================

local function process()

	if Running then return end
	Running = true

	task.spawn(function()
		while Active do
			
			local objects = Workspace:GetDescendants()
			local batch = 200

			for i = 1, #objects, batch do
				if not Active then break end

				for j = i, math.min(i + batch - 1, #objects) do
					local obj = objects[j]
					if obj then
						optimize(obj)
					end
				end

				task.wait()
			end

			task.wait(2)
		end

		Running = false
	end)
end

-- =========================
-- NOVOS OBJETOS
-- =========================

local function hook()

	if Connection then return end

	Connection = Workspace.DescendantAdded:Connect(function(obj)
		if Active then
			task.defer(function()
				optimize(obj)
			end)
		end
	end)
end

local function unhook()
	if Connection then
		Connection:Disconnect()
		Connection = nil
	end
end

-- =========================
-- PLAYERS
-- =========================

local function setupPlayers()

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then
			cleanCharacter(plr.Character)
		end

		plr.CharacterAdded:Connect(function(char)
			if Active then
				task.wait(1)
				cleanCharacter(char)
			end
		end)
	end
end

-- =========================
-- TOGGLE
-- =========================

_G.DZ.CreateToggle("Modo Batata (Ultra FPS)", function(state)
	Active = state

	if state then
		setupPlayers()
		process()
		hook()
	else
		unhook()
	end
end)

-- =========================================
-- DZ PERFORMANCE - FPS REAL (PRECISO)
-- =========================================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("DZ_UI")

local Active = false

-- =========================
-- UI FPS
-- =========================

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0,120,0,30)
fpsLabel.Position = UDim2.new(0,10,1,-40)
fpsLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
fpsLabel.BackgroundTransparency = 0.3
fpsLabel.TextColor3 = Color3.new(1,1,1)
fpsLabel.Text = "FPS: 0"
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 14
fpsLabel.Visible = false
fpsLabel.Parent = gui

Instance.new("UICorner", fpsLabel).CornerRadius = UDim.new(0,6)

-- =========================
-- SISTEMA FPS REAL
-- =========================

local frames = 0
local lastTime = tick()
local fps = 0

RunService.RenderStepped:Connect(function()
	if Active then
		frames += 1
	end
end)

task.spawn(function()
	while true do
		task.wait(1)

		if Active then
			local now = tick()
			local delta = now - lastTime

			fps = math.floor(frames / delta)

			frames = 0
			lastTime = now

			fpsLabel.Text = "FPS: " .. fps
		end
	end
end)

-- =========================
-- TOGGLE
-- =========================

_G.DZ.CreateToggle("Mostrar FPS (Real)", function(state)
	Active = state
	fpsLabel.Visible = state
end)

-- =========================================
-- DZ PERFORMANCE - PLAYER OPTIMIZER (REAL)
-- =========================================

local Players = game:GetService("Players")

local Active = false

-- =========================
-- OTIMIZA PLAYER
-- =========================

local function optimizeCharacter(char)

	for _, v in ipairs(char:GetDescendants()) do
		
		-- acessórios pesados
		if v:IsA("Accessory") then
			v:Destroy()
		end

		-- roupas (opcional leve)
		if v:IsA("ShirtGraphic") then
			v:Destroy()
		end

		-- animação pesada
		if v:IsA("AnimationController") or v:IsA("Animator") then
			v:Destroy()
		end

		-- partículas do player
		if v:IsA("ParticleEmitter") then
			v.Rate = 2
		end
	end

end

-- =========================
-- APLICAR EM TODOS
-- =========================

local function setup()

	for _, plr in ipairs(Players:GetPlayers()) do
		
		if plr.Character then
			optimizeCharacter(plr.Character)
		end

		plr.CharacterAdded:Connect(function(char)
			if Active then
				task.wait(1)
				optimizeCharacter(char)
			end
		end)
	end
end

-- =========================
-- TOGGLE
-- =========================

_G.DZ.CreateToggle("Player Optimizer (PvP Boost)", function(state)
	Active = state

	if state then
		setup()
	end
end)

-- =========================================
-- DZ PERFORMANCE - VFX DINÂMICO INTELIGENTE
-- =========================================

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Active = false
local Running = false

-- =========================
-- FPS REAL
-- =========================

local frames = 0
local last = tick()
local fps = 60

RunService.RenderStepped:Connect(function()
	if Active then
		frames += 1
	end
end)

local function updateFPS()
	if tick() - last >= 1 then
		fps = frames
		frames = 0
		last = tick()
	end
end

-- =========================
-- NÍVEL DE OTIMIZAÇÃO
-- =========================

local function getLevel()
	if fps > 50 then
		return 1 -- leve
	elseif fps > 35 then
		return 2 -- médio
	else
		return 3 -- agressivo
	end
end

-- =========================
-- APLICAR VFX
-- =========================

local function optimize(obj, level)

	if obj:IsA("ParticleEmitter") then
		
		if level == 1 then
			obj.Rate = math.min(obj.Rate, 15)

		elseif level == 2 then
			obj.Rate = math.min(obj.Rate, 6)
			obj.Lifetime = NumberRange.new(0.2, 0.4)

		elseif level == 3 then
			obj.Rate = 2
			obj.Lifetime = NumberRange.new(0.1, 0.2)
		end
	end

	if obj:IsA("Trail") then
		obj.Lifetime = level == 3 and 0.05 or 0.1
	end

	if obj:IsA("Beam") then
		if level >= 2 then
			obj.Width0 = 0.1
			obj.Width1 = 0.1
		end
	end

	if obj:IsA("PointLight") or obj:IsA("SpotLight") then
		if level == 3 then
			obj.Brightness = 0.3
		end
	end
end

-- =========================
-- LOOP INTELIGENTE
-- =========================

local function start()
	if Running then return end
	Running = true

	task.spawn(function()
		while Active do

			updateFPS()
			local level = getLevel()

			local objects = Workspace:GetDescendants()
			local batch = 180

			for i = 1, #objects, batch do
				if not Active then break end

				for j = i, math.min(i + batch - 1, #objects) do
					local obj = objects[j]
					if obj then
						optimize(obj, level)
					end
				end

				task.wait()
			end

			task.wait(1)
		end

		Running = false
	end)
end

-- =========================
-- TOGGLE
-- =========================

_G.DZ.CreateToggle("VFX Dinâmico (Auto FPS)", function(state)
	Active = state

	if state then
		start()
	end
end)
