-- DZ PERFORMANCE LITE - VERSÃO COMPLETA
-- UI própria, leve, minimizável, com modo casual / competitivo / batata
-- VFX dinâmico, player optimizer, anti stutter, game turbo, smart engine e FPS real

if _G.DZ_LITE_RUNNING then
	return
end
_G.DZ_LITE_RUNNING = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

do
	local old = playerGui:FindFirstChild("DZ_UI")
	if old then old:Destroy() end
	local oldHud = playerGui:FindFirstChild("DZ_FPS_HUD")
	if oldHud then oldHud:Destroy() end
end

local alive = true

local State = {
	Preset = "None",
	VFXDynamic = false,
	PlayerOpt = false,
	AntiStutter = false,
	GameTurbo = false,
	SmartEngine = false,
	ShowFPS = false
}

local switches = {}

local LightingBackup = {
	GlobalShadows = Lighting.GlobalShadows,
	Brightness = Lighting.Brightness,
	EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
	EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
	FogStart = Lighting.FogStart,
	FogEnd = Lighting.FogEnd,
	ExposureCompensation = Lighting.ExposureCompensation,
	Technology = Lighting.Technology
}

do
	local ok, ql = pcall(function()
		return settings().Rendering.QualityLevel
	end)
	LightingBackup.QualityLevel = ok and ql or nil
end

local function safe(fn)
	local ok, err = pcall(fn)
	if not ok then
		warn("[DZ]", err)
	end
end

local function restoreLighting()
	safe(function()
		Lighting.GlobalShadows = LightingBackup.GlobalShadows
		Lighting.Brightness = LightingBackup.Brightness
		Lighting.EnvironmentDiffuseScale = LightingBackup.EnvironmentDiffuseScale
		Lighting.EnvironmentSpecularScale = LightingBackup.EnvironmentSpecularScale
		Lighting.FogStart = LightingBackup.FogStart
		Lighting.FogEnd = LightingBackup.FogEnd
		Lighting.ExposureCompensation = LightingBackup.ExposureCompensation
		Lighting.Technology = LightingBackup.Technology
		if LightingBackup.QualityLevel then
			pcall(function()
				settings().Rendering.QualityLevel = LightingBackup.QualityLevel
			end)
		end
	end)
end

local function intro()
	local gui = Instance.new("ScreenGui")
	gui.Name = "DZ_INTRO"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.Parent = playerGui

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	bg.BorderSizePixel = 0
	bg.Parent = gui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 90)
	title.Position = UDim2.new(0, 0, 0.45, 0)
	title.BackgroundTransparency = 1
	title.Text = "by DAVIZZIN"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.Parent = bg

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, 0, 0, 24)
	sub.Position = UDim2.new(0, 0, 0.55, 0)
	sub.BackgroundTransparency = 1
	sub.Text = "Performance Edition"
	sub.TextColor3 = Color3.fromRGB(180, 180, 180)
	sub.TextTransparency = 1
	sub.Font = Enum.Font.Gotham
	sub.TextScaled = true
	sub.Parent = bg

	TweenService:Create(title, TweenInfo.new(0.55), { TextTransparency = 0 }):Play()
	TweenService:Create(sub, TweenInfo.new(0.55), { TextTransparency = 0.05 }):Play()

	task.wait(1.15)

	local out1 = TweenService:Create(bg, TweenInfo.new(0.55), { BackgroundTransparency = 1 })
	local out2 = TweenService:Create(title, TweenInfo.new(0.45), { TextTransparency = 1 })
	local out3 = TweenService:Create(sub, TweenInfo.new(0.45), { TextTransparency = 1 })
	out1:Play()
	out2:Play()
	out3:Play()

	task.wait(0.6)
	gui:Destroy()
end

intro()

local gui = Instance.new("ScreenGui")
gui.Name = "DZ_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 245, 0, 325)
main.Position = UDim2.new(0, 20, 0.32, 0)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 34)
top.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
top.BorderSizePixel = 0
top.Parent = main
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "DZ Performance Lite"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 22)
minBtn.Position = UDim2.new(1, -58, 0, 6)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBlack
minBtn.TextSize = 18
minBtn.Parent = top

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 22)
closeBtn.Position = UDim2.new(1, -28, 0, 6)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 14
closeBtn.Parent = top

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, 0, 1, -34)
content.Position = UDim2.new(0, 0, 0, 34)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Parent = main

local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0, 54, 0, 54)
mini.Position = main.Position
mini.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mini.BorderSizePixel = 0
mini.Text = "DZ"
mini.TextColor3 = Color3.fromRGB(255, 255, 255)
mini.Font = Enum.Font.GothamBlack
mini.TextSize = 18
mini.Visible = false
mini.Parent = gui
Instance.new("UICorner", mini).CornerRadius = UDim.new(0, 8)

local function makeDraggable(frame)
	local dragging = false
	local dragInput
	local dragStart
	local startPos

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

makeDraggable(main)
makeDraggable(mini)

local minimized = false
local function setMinimized(state)
	minimized = state
	main.Visible = not state
	mini.Visible = state
	if state then
		mini.Position = main.Position
	end
end

minBtn.MouseButton1Click:Connect(function()
	setMinimized(true)
end)

mini.MouseButton1Click:Connect(function()
	setMinimized(false)
end)

local function shutdown()
	if not alive then return end
	alive = false
	_G.DZ_LITE_RUNNING = false

	safe(function()
		restoreWorld()
		restoreChar()
		restoreLighting()
	end)

	if gui then
		gui:Destroy()
	end
	if playerGui:FindFirstChild("DZ_FPS_HUD") then
		playerGui.DZ_FPS_HUD:Destroy()
	end
end

closeBtn.MouseButton1Click:Connect(function()
	shutdown()
end)

local y = 8
local function addSection(text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -16, 0, 18)
	label.Position = UDim2.new(0, 8, 0, y)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(160, 160, 160)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = content
	y += 20
end

local function addToggle(text, callback, default)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -14, 0, 32)
	row.Position = UDim2.new(0, 7, 0, y)
	row.BackgroundTransparency = 1
	row.Parent = content

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.72, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(240, 240, 240)
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 40, 0, 20)
	button.Position = UDim2.new(1, -42, 0.5, -10)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.BorderSizePixel = 0
	button.Text = ""
	button.Parent = row
	Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.Position = UDim2.new(0, 1, 0.5, -9)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = button
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local state = false

	local function render()
		if state then
			button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			knob.Position = UDim2.new(1, -19, 0.5, -9)
		else
			button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			knob.Position = UDim2.new(0, 1, 0.5, -9)
		end
	end

	local function set(v, silent)
		v = not not v
		if state == v then return end
		state = v
		render()
		if not silent and callback then
			task.spawn(callback, state)
		end
	end

	button.MouseButton1Click:Connect(function()
		set(not state, false)
	end)

	render()
	set(default == true, true)

	y += 36
	return {
		Set = set,
		Get = function()
			return state
		end
	}
end

addSection("PRESETS")
switches.Casual = addToggle("Modo Casual", function(v)
	if v then
		State.Preset = "Casual"
		if switches.Competitive then switches.Competitive.Set(false, true) end
		if switches.Batata then switches.Batata.Set(false, true) end
	else
		if State.Preset == "Casual" then
			State.Preset = "None"
		end
	end
end, false)

switches.Competitive = addToggle("Modo Competitivo", function(v)
	if v then
		State.Preset = "Competitive"
		if switches.Casual then switches.Casual.Set(false, true) end
		if switches.Batata then switches.Batata.Set(false, true) end
	else
		if State.Preset == "Competitive" then
			State.Preset = "None"
		end
	end
end, false)

switches.Batata = addToggle("Modo Batata", function(v)
	if v then
		State.Preset = "Batata"
		if switches.Casual then switches.Casual.Set(false, true) end
		if switches.Competitive then switches.Competitive.Set(false, true) end
	else
		if State.Preset == "Batata" then
			State.Preset = "None"
		end
	end
end, false)

addSection("EXTRAS")
switches.VFXDynamic = addToggle("VFX Dinâmico", function(v)
	State.VFXDynamic = v
end, false)

switches.PlayerOpt = addToggle("Player Optimizer", function(v)
	State.PlayerOpt = v
end, false)

switches.AntiStutter = addToggle("Anti Stutter", function(v)
	State.AntiStutter = v
end, false)

addSection("AUTO")
switches.GameTurbo = addToggle("Game Turbo", function(v)
	State.GameTurbo = v
end, false)

switches.SmartEngine = addToggle("Smart Engine", function(v)
	State.SmartEngine = v
end, false)

switches.ShowFPS = addToggle("Mostrar FPS Real", function(v)
	State.ShowFPS = v
	fpsLabel.Visible = v
end, false)

content.CanvasSize = UDim2.new(0, 0, 0, y + 10)

local fpsHud = Instance.new("ScreenGui")
fpsHud.Name = "DZ_FPS_HUD"
fpsHud.ResetOnSpawn = false
fpsHud.IgnoreGuiInset = true
fpsHud.Parent = playerGui

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 120, 0, 28)
fpsLabel.Position = UDim2.new(0, 10, 1, -70)
fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fpsLabel.BackgroundTransparency = 0.3
fpsLabel.BorderSizePixel = 0
fpsLabel.Visible = false
fpsLabel.Text = "FPS: 0"
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 14
fpsLabel.Parent = fpsHud
Instance.new("UICorner", fpsLabel).CornerRadius = UDim.new(0, 6)

local frameCount = 0
local elapsed = 0
local fpsValue = 60

RunService.RenderStepped:Connect(function(dt)
	if not alive then return end
	frameCount += 1
	elapsed += dt
	if elapsed >= 1 then
		fpsValue = math.floor(frameCount / elapsed + 0.5)
		frameCount = 0
		elapsed = 0

		if State.ShowFPS then
			fpsLabel.Text = "FPS: " .. fpsValue
			if fpsValue >= 50 then
				fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
			elseif fpsValue >= 35 then
				fpsLabel.TextColor3 = Color3.fromRGB(255, 190, 0)
			else
				fpsLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
			end
		end
	end
end)

local worldBackup = setmetatable({}, { __mode = "k" })
local charBackup = setmetatable({}, { __mode = "k" })

local lastCombat = os.clock()
local smartPower = 0
local vfxPower = 0
local applying = false

local function basePower()
	if State.Preset == "Casual" then
		return 1
	elseif State.Preset == "Competitive" then
		return 2
	elseif State.Preset == "Batata" then
		return 3
	end
	return 0
end

local function hasWorldFeature()
	return State.Preset ~= "None" or State.VFXDynamic or State.GameTurbo or State.SmartEngine or State.AntiStutter
end

local function hasCharFeature()
	return State.Preset ~= "None" or State.PlayerOpt or State.GameTurbo or State.SmartEngine
end

local function worldPower()
	local p = basePower()
	if State.GameTurbo then
		p += 1
	end
	if State.SmartEngine then
		p = math.max(p, smartPower)
	end
	return math.clamp(p, 0, 3)
end

local function visualPower()
	local p = worldPower()
	if State.VFXDynamic then
		p = math.max(p, vfxPower)
	end
	return math.clamp(p, 0, 3)
end

local function charPower()
	local p = basePower()
	if State.PlayerOpt then
		p += 1
	end
	if State.GameTurbo then
		p += 1
	end
	if State.SmartEngine then
		p = math.max(p, smartPower)
	end
	return math.clamp(p, 1, 3)
end

local function isCharacterObject(obj)
	local model = obj:FindFirstAncestorOfClass("Model")
	if not model then return false end
	return model:FindFirstChildOfClass("Humanoid") ~= nil
end

local function backupWorld(obj)
	local b = worldBackup[obj]
	if b then return b end

	b = {}
	if obj:IsA("BasePart") then
		b.CastShadow = obj.CastShadow
		b.Material = obj.Material
		b.Reflectance = obj.Reflectance
		b.LTM = obj.LocalTransparencyModifier
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		b.Transparency = obj.Transparency
	elseif obj:IsA("ParticleEmitter") then
		b.Enabled = obj.Enabled
		b.Rate = obj.Rate
		b.Lifetime = obj.Lifetime
	elseif obj:IsA("Trail") then
		b.Enabled = obj.Enabled
		b.Lifetime = obj.Lifetime
	elseif obj:IsA("Beam") then
		b.Enabled = obj.Enabled
		b.Width0 = obj.Width0
		b.Width1 = obj.Width1
	elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
		b.Enabled = obj.Enabled
		b.Brightness = obj.Brightness
		b.Range = obj.Range
	elseif obj:IsA("BlurEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") then
		b.Enabled = obj.Enabled
	elseif obj:IsA("Highlight") then
		b.Enabled = obj.Enabled
	elseif obj:IsA("Fire") or obj:IsA("Smoke") then
		b.Enabled = obj.Enabled
		b.Size = obj.Size
		b.Heat = obj.Heat
	end

	worldBackup[obj] = b
	return b
end

local function backupChar(obj)
	local b = charBackup[obj]
	if b then return b end

	b = {}
	if obj:IsA("Accessory") then
		local h = obj:FindFirstChild("Handle")
		if h and h:IsA("BasePart") then
			b.Handle = {
				LTM = h.LocalTransparencyModifier,
				CastShadow = h.CastShadow,
				Material = h.Material,
				Reflectance = h.Reflectance
			}
		end
	elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or obj:IsA("Highlight") then
		b.Enabled = obj.Enabled
	elseif obj:IsA("ParticleEmitter") then
		b.Enabled = obj.Enabled
		b.Rate = obj.Rate
		b.Lifetime = obj.Lifetime
	elseif obj:IsA("Trail") then
		b.Enabled = obj.Enabled
		b.Lifetime = obj.Lifetime
	elseif obj:IsA("Beam") then
		b.Enabled = obj.Enabled
		b.Width0 = obj.Width0
		b.Width1 = obj.Width1
	end

	charBackup[obj] = b
	return b
end

local function restoreWorld()
	for obj, b in pairs(worldBackup) do
		if obj and obj.Parent and b then
			safe(function()
				if obj:IsA("BasePart") then
					obj.CastShadow = b.CastShadow
					obj.Material = b.Material
					obj.Reflectance = b.Reflectance
					obj.LocalTransparencyModifier = b.LTM or 0
				elseif obj:IsA("Decal") or obj:IsA("Texture") then
					obj.Transparency = b.Transparency
				elseif obj:IsA("ParticleEmitter") then
					obj.Enabled = b.Enabled
					obj.Rate = b.Rate
					obj.Lifetime = b.Lifetime
				elseif obj:IsA("Trail") then
					obj.Enabled = b.Enabled
					obj.Lifetime = b.Lifetime
				elseif obj:IsA("Beam") then
					obj.Enabled = b.Enabled
					obj.Width0 = b.Width0
					obj.Width1 = b.Width1
				elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
					obj.Enabled = b.Enabled
					obj.Brightness = b.Brightness
					obj.Range = b.Range
				elseif obj:IsA("BlurEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") then
					obj.Enabled = b.Enabled
				elseif obj:IsA("Highlight") then
					obj.Enabled = b.Enabled
				elseif obj:IsA("Fire") or obj:IsA("Smoke") then
					obj.Enabled = b.Enabled
					obj.Size = b.Size
					obj.Heat = b.Heat
				end
			end)
		end
	end
	table.clear(worldBackup)
	restoreLighting()
end

local function restoreChar()
	for obj, b in pairs(charBackup) do
		if obj and obj.Parent and b then
			safe(function()
				if obj:IsA("Accessory") then
					local h = obj:FindFirstChild("Handle")
					if h and h:IsA("BasePart") and b.Handle then
						h.LocalTransparencyModifier = b.Handle.LTM or 0
						h.CastShadow = b.Handle.CastShadow
						h.Material = b.Handle.Material
						h.Reflectance = b.Handle.Reflectance
					end
				elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or obj:IsA("Highlight") then
					obj.Enabled = b.Enabled
				elseif obj:IsA("ParticleEmitter") then
					obj.Enabled = b.Enabled
					obj.Rate = b.Rate
					obj.Lifetime = b.Lifetime
				elseif obj:IsA("Trail") then
					obj.Enabled = b.Enabled
					obj.Lifetime = b.Lifetime
				elseif obj:IsA("Beam") then
					obj.Enabled = b.Enabled
					obj.Width0 = b.Width0
					obj.Width1 = b.Width1
				end
			end)
		end
	end
	table.clear(charBackup)
end

local function applyLighting(power)
	safe(function()
		if power <= 0 then
			restoreLighting()
			return
		end

		Lighting.GlobalShadows = false

		if power == 1 then
			Lighting.Brightness = math.max(1.2, LightingBackup.Brightness * 0.85)
			Lighting.EnvironmentDiffuseScale = 0.6
			Lighting.EnvironmentSpecularScale = 0.2
			Lighting.FogEnd = math.min(LightingBackup.FogEnd, 5000)
		elseif power == 2 then
			Lighting.Brightness = math.max(1.0, LightingBackup.Brightness * 0.75)
			Lighting.EnvironmentDiffuseScale = 0.35
			Lighting.EnvironmentSpecularScale = 0.08
			Lighting.FogEnd = math.min(LightingBackup.FogEnd, 1200)
			pcall(function()
				settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			end)
		else
			Lighting.Brightness = math.max(0.8, LightingBackup.Brightness * 0.65)
			Lighting.EnvironmentDiffuseScale = 0.08
			Lighting.EnvironmentSpecularScale = 0
			Lighting.FogEnd = math.min(LightingBackup.FogEnd, 300)
			pcall(function()
				settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			end)
		end
	end)
end

local function optimizeWorld(obj, power, vp)
	if not obj or not obj.Parent then return end
	if isCharacterObject(obj) then return end

	if obj:IsA("BasePart") then
		obj.CastShadow = b.CastShadow
					obj.Material = b.Material
					obj.Reflectance = b.Reflectance
					obj.LocalTransparencyModifier = b.LTM or 0
				elseif obj:IsA("Decal") or obj:IsA("Texture") then
					obj.Transparency = b.Transparency
				elseif obj:IsA("ParticleEmitter") then
					obj.Enabled = b.Enabled
					obj.Rate = b.Rate
					obj.Lifetime = b.Lifetime
				elseif obj:IsA("Trail") then
					obj.Enabled = b.Enabled
					obj.Lifetime = b.Lifetime
				elseif obj:IsA("Beam") then
					obj.Enabled = b.Enabled
					obj.Width0 = b.Width0
					obj.Width1 = b.Width1
				elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
					obj.Enabled = b.Enabled
					obj.Brightness = b.Brightness
					obj.Range = b.Range
				elseif obj:IsA("BlurEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") then
					obj.Enabled = b.Enabled
				elseif obj:IsA("Highlight") then
					obj.Enabled = b.Enabled
				elseif obj:IsA("Fire") or obj:IsA("Smoke") then
					obj.Enabled = b.Enabled
					obj.Size = b.Size
					obj.Heat = b.Heat
				end
			end)
		end
	end
	table.clear(worldBackup)
	restoreLighting()
end

local function restoreChar()
	for obj, b in pairs(charBackup) do
		if obj and obj.Parent and b then
			safe(function()
				if obj:IsA("Accessory") then
					local h = obj:FindFirstChild("Handle")
					if h and h:IsA("BasePart") and b.Handle then
						h.LocalTransparencyModifier = b.Handle.LTM or 0
						h.CastShadow = b.Handle.CastShadow
						h.Material = b.Handle.Material
						h.Reflectance = b.Handle.Reflectance
					end
				elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or obj:IsA("Highlight") then
					obj.Enabled = b.Enabled
				elseif obj:IsA("ParticleEmitter") then
					obj.Enabled = b.Enabled
					obj.Rate = b.Rate
					obj.Lifetime = b.Lifetime
				elseif obj:IsA("Trail") then
					obj.Enabled = b.Enabled
					obj.Lifetime = b.Lifetime
				elseif obj:IsA("Beam") then
					obj.Enabled = b.Enabled
					obj.Width0 = b.Width0
					obj.Width1 = b.Width1
				end
			end)
		end
	end
	table.clear(charBackup)
end

local function applyLighting(power)
	safe(function()
		if power <= 0 then
			restoreLighting()
			return
		end

		Lighting.GlobalShadows = false

		if power == 1 then
			Lighting.Brightness = math.max(1.2, LightingBackup.Brightness * 0.85)
			Lighting.EnvironmentDiffuseScale = 0.6
			Lighting.EnvironmentSpecularScale = 0.2
			Lighting.FogEnd = math.min(LightingBackup.FogEnd, 5000)
		elseif power == 2 then
			Lighting.Brightness = math.max(1.0, LightingBackup.Brightness * 0.75)
			Lighting.EnvironmentDiffuseScale = 0.35
			Lighting.EnvironmentSpecularScale = 0.08
			Lighting.FogEnd = math.min(LightingBackup.FogEnd, 1200)
			pcall(function()
				settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			end)
		else
			Lighting.Brightness = math.max(0.8, LightingBackup.Brightness * 0.65)
			Lighting.EnvironmentDiffuseScale = 0.08
			Lighting.EnvironmentSpecularScale = 0
			Lighting.FogEnd = math.min(LightingBackup.FogEnd, 300)
			pcall(function()
				settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			end)
		end
	end)
end

local function optimizeWorld(obj, power, vp)
	if not obj or not obj.Parent then return end
	if isCharacterObject(obj) then return end

	if obj:IsA("BasePart") then
		backupWorld(obj)
		if obj.CastShadow then obj.CastShadow = false end
		if power >= 2 and obj.Material ~= Enum.Material.SmoothPlastic then
			obj.Material = Enum.Material.SmoothPlastic
		end
		if power >= 2 and obj.Reflectance ~= 0 then
			obj.Reflectance = 0
		end

	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		backupWorld(obj)
		local target = (power == 1 and 0.18) or (power == 2 and 0.45) or 1
		if obj.Transparency < target then
			obj.Transparency = target
		end

	elseif obj:IsA("ParticleEmitter") then
		backupWorld(obj)
		local use = math.max(power, vp)
		if use == 1 then
			local target = math.max(4, math.floor(obj.Rate * 0.55))
			if obj.Rate > target then obj.Rate = target end
		elseif use == 2 then
			local target = math.max(2, math.floor(obj.Rate * 0.3))
			if obj.Rate > target then obj.Rate = target end
			obj.Lifetime = NumberRange.new(0.15, 0.35)
		else
			obj.Enabled = false
		end

	elseif obj:IsA("Trail") then
		backupWorld(obj)
		local use = math.max(power, vp)
		if use == 1 then
			if obj.Lifetime > 0.08 then obj.Lifetime = 0.08 end
		elseif use == 2 then
			if obj.Lifetime > 0.05 then obj.Lifetime = 0.05 end
		else
			obj.Enabled = false
		end

	elseif obj:IsA("Beam") then
		backupWorld(obj)
		local use = math.max(power, vp)
		if use == 1 then
			if obj.Width0 > 0.15 then obj.Width0 = 0.15 end
			if obj.Width1 > 0.15 then obj.Width1 = 0.15 end
		elseif use == 2 then
			if obj.Width0 > 0.08 then obj.Width0 = 0.08 end
			if obj.Width1 > 0.08 then obj.Width1 = 0.08 end
		else
			obj.Enabled = false
		end

	elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
		backupWorld(obj)
		local use = math.max(power, vp)
		if use == 1 then
			if obj.Brightness > 0.7 then obj.Brightness = 0.7 end
			if obj.Range > 8 then obj.Range = 8 end
		elseif use == 2 then
			if obj.Brightness > 0.35 then obj.Brightness = 0.35 end
			if obj.Range > 5 then obj.Range = 5 end
		else
			obj.Enabled = false
		end

	elseif obj:IsA("BlurEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") then
		backupWorld(obj)
		obj.Enabled = false

	elseif obj:IsA("Highlight") then
		backupWorld(obj)
		obj.Enabled = false

	elseif obj:IsA("Fire") or obj:IsA("Smoke") then
		backupWorld(obj)
		local use = math.max(power, vp)
		if use == 1 then
			if obj.Size > 0.7 then obj.Size = 0.7 end
		elseif use == 2 then
			if obj.Size > 0.4 then obj.Size = 0.4 end
		else
			obj.Enabled = false
		end
	end
end

local function optimizeCharacterObject(obj, power)
	if not obj or not obj.Parent then return end

	if obj:IsA("Accessory") then
		backupChar(obj)
		local handle = obj:FindFirstChild("Handle")
		if handle and handle:IsA("BasePart") then
			if power == 1 then
				handle.LocalTransparencyModifier = math.max(handle.LocalTransparencyModifier, 0.35)
			elseif power == 2 then
				handle.LocalTransparencyModifier = math.max(handle.LocalTransparencyModifier, 0.7)
			else
				handle.LocalTransparencyModifier = math.max(handle.LocalTransparencyModifier, 1)
			end
			handle.CastShadow = false
			if power >= 2 then
				handle.Material = Enum.Material.SmoothPlastic
				handle.Reflectance = 0
			end
		end

	elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or obj:IsA("Highlight") then
		backupChar(obj)
		if power >= 2 then
			obj.Enabled = false
		end

	elseif obj:IsA("ParticleEmitter") then
		backupChar(obj)
		if power == 1 then
			local target = math.max(3, math.floor(obj.Rate * 0.5))
			if obj.Rate > target then obj.Rate = target end
		elseif power == 2 then
			local target = math.max(1, math.floor(obj.Rate * 0.25))
			if obj.Rate > target then obj.Rate = target end
			obj.Lifetime = NumberRange.new(0.12, 0.25)
		else
			obj.Enabled = false
		end

	elseif obj:IsA("Trail") then
		backupChar(obj)
		if power == 1 then
			if obj.Lifetime > 0.08 then obj.Lifetime = 0.08 end
		elseif power == 2 then
			if obj.Lifetime > 0.05 then obj.Lifetime = 0.05 end
		else
			obj.Enabled = false
		end

	elseif obj:IsA("Beam") then
		backupChar(obj)
		if power == 1 then
			if obj.Width0 > 0.15 then obj.Width0 = 0.15 end
			if obj.Width1 > 0.15 then obj.Width1 = 0.15 end
		elseif power == 2 then
			if obj.Width0 > 0.08 then obj.Width0 = 0.08 end
			if obj.Width1 > 0.08 then obj.Width1 = 0.08 end
		else
			obj.Enabled = false
		end
	end
end

local function sweepWorld(power, vp)
	local list = Workspace:GetDescendants()
	local batch = State.GameTurbo and 100 or 140

	for i = 1, #list, batch do
		if not alive then return end
		for j = i, math.min(i + batch - 1, #list) do
			local obj = list[j]
			if obj then
				optimizeWorld(obj, power, vp)
			end
		end
		task.wait()
	end
end

local function sweepChars(power)
	local plist = Players:GetPlayers()
	local batch = State.GameTurbo and 2 or 4

	for i = 1, #plist, batch do
		if not alive then return end
		for j = i, math.min(i + batch - 1, #plist) do
			local plr = plist[j]
			if plr and plr.Character then
				local char = plr.Character
				for _, obj in ipairs(char:GetDescendants()) do
					optimizeCharacterObject(obj, power)
				end
			end
		end
		task.wait()
	end
end

Workspace.DescendantAdded:Connect(function(obj)
	if not alive then return end
	if not (hasWorldFeature() or hasCharFeature()) then return end

	if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Explosion") or obj:IsA("Highlight") or obj:IsA("Fire") or obj:IsA("Smoke") then
		lastCombat = os.clock()
	end

	local wp = worldPower()
	local vp = visualPower()
	local cp = charPower()

	if isCharacterObject(obj) then
		optimizeCharacterObject(obj, cp)
	elseif hasWorldFeature() then
		optimizeWorld(obj, wp, vp)
	end
end)

local function queueApply()
	if applying then return end
	applying = true

	task.spawn(function()
		local wp = worldPower()
		local vp = visualPower()
		local cp = charPower()

		if hasWorldFeature() then
			applyLighting(wp)
			sweepWorld(wp, vp)
		else
			if next(worldBackup) ~= nil then
				restoreWorld()
			else
				restoreLighting()
			end
		end

		if hasCharFeature() then
			sweepChars(cp)
		else
			if next(charBackup) ~= nil then
				restoreChar()
			end
		end

		applying = false
	end)
end

task.spawn(function()
	while alive do
		local active = hasWorldFeature() or hasCharFeature() or State.AntiStutter

		if State.SmartEngine then
			if os.clock() - lastCombat < 2.2 or fpsValue < 28 then
				smartPower = 3
			elseif fpsValue < 40 then
				smartPower = 2
			elseif fpsValue < 52 then
				smartPower = 1
			else
				smartPower = 0
			end
		else
			smartPower = 0
		end

		if State.VFXDynamic then
			if fpsValue < 30 then
				vfxPower = 3
			elseif fpsValue < 45 then
				vfxPower = 2
			else
				vfxPower = 1
			end
		else
			vfxPower = 0
		end

		if State.AntiStutter then
			collectgarbage("step", State.GameTurbo and 24 or 16)
		end

		if active then
			queueApply()
		else
			if next(worldBackup) ~= nil then
				restoreWorld()
			end
			if next(charBackup) ~= nil then
				restoreChar()
			end
		end

		task.wait(State.GameTurbo and 0.75 or 1.1)
	end
end)

local DZ = {
	State = State,
	Buttons = switches
}

_G.DZ = DZ

print("[DZ] Performance Lite carregado")
