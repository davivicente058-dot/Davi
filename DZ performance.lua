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
