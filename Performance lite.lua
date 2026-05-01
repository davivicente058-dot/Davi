-- DZ PERFORMANCE LITE
-- foco em FPS, fluidez e estabilidade
-- UI compacta, quadrado DZ, toggles em alavanca

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

do
	local old = playerGui:FindFirstChild("DZ_UI")
	if old then old:Destroy() end
	local oldHud = playerGui:FindFirstChild("DZ_FPS_HUD")
	if oldHud then oldHud:Destroy() end
end

local State = {
	Casual = false,
	Competitive = false,
	Batata = false,
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

local function safe(fn)
	local ok, err = pcall(fn)
	if not ok then
		warn("[DZ] ", err)
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
		pcall(function()
			if LightingBackup.QualityLevel then
				settings().Rendering.QualityLevel = LightingBackup.QualityLevel
			end
		end)
	end)
end

do
	local ok, ql = pcall(function()
		return settings().Rendering.QualityLevel
	end)
	LightingBackup.QualityLevel = ok and ql or nil
end

local function basePower()
	if State.Batata then return 3 end
	if State.Competitive then return 2 end
	if State.Casual then return 1 end
	return 0
end

local smartPower = 0
local vfxPower = 0
local lastCombat = os.clock()
local fpsValue = 60

Workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Explosion") or obj:IsA("Highlight") then
		lastCombat = os.clock()
	end
end)

local WorldBackup = setmetatable({}, { __mode = "k" })
local CharBackup = setmetatable({}, { __mode = "k" })

local function backupWorld(obj)
	local b = WorldBackup[obj]
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
	elseif obj:IsA("Fire") or obj:IsA("Smoke") then
		b.Enabled = obj.Enabled
		b.Size = obj.Size
		b.Heat = obj.Heat
	elseif obj:IsA("BlurEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") then
		b.Enabled = obj.Enabled
	elseif obj:IsA("Highlight") then
		b.Enabled = obj.Enabled
	end

	WorldBackup[obj] = b
	return b
end

local function backupChar(obj)
	local b = CharBackup[obj]
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
	elseif obj:IsA("Shirt") then
		b.Template = obj.ShirtTemplate
	elseif obj:IsA("Pants") then
		b.Template = obj.PantsTemplate
	elseif obj:IsA("ShirtGraphic") then
		b.Graphic = obj.Graphic
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

	CharBackup[obj] = b
	return b
end

local function restoreWorld()
	for obj, b in pairs(WorldBackup) do
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
				elseif obj:IsA("Fire") or obj:IsA("Smoke") then
					obj.Enabled = b.Enabled
					obj.Size = b.Size
					obj.Heat = b.Heat
				elseif obj:IsA("BlurEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") then
					obj.Enabled = b.Enabled
				elseif obj:IsA("Highlight") then
					obj.Enabled = b.Enabled
				end
			end)
		end
	end
	table.clear(WorldBackup)
	restoreLighting()
end

local function restoreChar()
	for obj, b in pairs(CharBackup) do
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
				elseif obj:IsA("Shirt") then
					obj.ShirtTemplate = b.Template or ""
				elseif obj:IsA("Pants") then
					obj.PantsTemplate = b.Template or ""
				elseif obj:IsA("ShirtGraphic") then
					obj.Graphic = b.Graphic or ""
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
	table.clear(CharBackup)
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
			Lighting.EnvironmentDiffuseScale = 0.55
			Lighting.EnvironmentSpecularScale = 0.18
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

local function optimizeWorld(obj, power)
	if not obj or not obj.Parent then return end

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
		if power == 1 then
			local target = math.max(4, math.floor(obj.Rate * 0.55))
			if obj.Rate > target then obj.Rate = target end
		elseif power == 2 then
			local target = math.max(2, math.floor(obj.Rate * 0.3))
			if obj.Rate > target then obj.Rate = target end
			obj.Lifetime = NumberRange.new(0.15, 0.35)
		else
			obj.Enabled = false
		end

	elseif obj:IsA("Trail") then
		backupWorld(obj)
		if power == 1 then
			if obj.Lifetime > 0.08 then obj.Lifetime = 0.08 end
		elseif power == 2 then
			if obj.Lifetime > 0.05 then obj.Lifetime = 0.05 end
		else
			obj.Enabled = false
		end

	elseif obj:IsA("Beam") then
		backupWorld(obj)
		if power == 1 then
			if obj.Width0 > 0.15 then obj.Width0 = 0.15 end
			if obj.Width1 > 0.15 then obj.Width1 = 0.15 end
		elseif power == 2 then
			if obj.Width0 > 0.08 then obj.Width0 = 0.08 end
			if obj.Width1 > 0.08 then obj.Width1 = 0.08 end
		else
			obj.Enabled = false
		end

	elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
		backupWorld(obj)
		if power == 1 then
			if obj.Brightness > 0.7 then obj.Brightness = 0.7 end
			if obj.Range > 8 then obj.Range = 8 end
		elseif power == 2 then
			if obj.Brightness > 0.35 then obj.Brightness = 0.35 end
			if obj.Range > 5 then obj.Range = 5 end
		else
			obj.Enabled = false
		end

	elseif obj:IsA("BlurEffect") or obj:IsA("BloomEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") then
		backupWorld(obj)
		if obj.Enabled then obj.Enabled = false end

	elseif obj:IsA("Highlight") then
		backupWorld(obj)
		if obj.Enabled then obj.Enabled = false end

	elseif obj:IsA("Fire") or obj:IsA("Smoke") then
		backupWorld(obj)
		if power == 1 then
			if obj.Size > 0.7 then obj.Size = 0.7 end
		elseif power == 2 then
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
				if handle.LocalTransparencyModifier < 0.35 then handle.LocalTransparencyModifier = 0.35 end
			elseif power == 2 then
				if handle.LocalTransparencyModifier < 0.7 then handle.LocalTransparencyModifier = 0.7 end
			else
				if handle.LocalTransparencyModifier < 1 then handle.LocalTransparencyModifier = 1 end
			end
			if handle.CastShadow then handle.CastShadow = false end
			if power >= 2 and handle.Material ~= Enum.Material.SmoothPlastic then
				handle.Material = Enum.Material.SmoothPlastic
			end
		end

	elseif obj:IsA("Shirt") then
		backupChar(obj)
		if power >= 2 and obj.ShirtTemplate ~= "" then
			obj.ShirtTemplate = ""
		end

	elseif obj:IsA("Pants") then
		backupChar(obj)
		if power >= 2 and obj.PantsTemplate ~= "" then
			obj.PantsTemplate = ""
		end

	elseif obj:IsA("ShirtGraphic") then
		backupChar(obj)
		if power >= 2 and obj.Graphic ~= "" then
			obj.Graphic = ""
		end

	elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or obj:IsA("Highlight") then
		backupChar(obj)
		if power >= 2 and obj.Enabled then
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

local worldRunning = false
local brainRunning = false
local antiConn = nil
local fpsConn = nil

local function worldPower()
	local p = basePower()

	if State.GameTurbo then
		p += 1
	end

	if State.VFXDynamic then
		p = math.max(p, vfxPower)
	end

	if State.SmartEngine then
		p = math.max(p, smartPower)
	end

	return math.clamp(p, 0, 3)
end

local function charPower()
	local p = basePower()

	if State.GameTurbo then
		p += 1
	end

	if State.SmartEngine then
		p = math.max(p, smartPower)
	end

	if State.PlayerOpt or p > 0 then
		p = math.max(p, 1)
	end

	return math.clamp(p, 1, 3)
end

local function hasWorldFeature()
	return basePower() > 0 or State.GameTurbo or State.VFXDynamic or State.SmartEngine
end

local function hasCharFeature()
	return State.PlayerOpt or State.Casual or State.Competitive or State.Batata or State.GameTurbo or State.SmartEngine
end

local function startBrain()
	if brainRunning then return end
	brainRunning = true

	task.spawn(function()
		while State.AntiStutter or hasWorldFeature() or hasCharFeature() do
			if State.SmartEngine then
				if os.clock() - lastCombat < 2.2 or fpsValue < 28 then
					smartPower = 3
				elseif fpsValue < 42 then
					smartPower = 2
				else
					smartPower = 1
				end
			else
				smartPower = 0
			end

			if State.VFXDynamic then
				if fpsValue > 55 then
					vfxPower = 1
				elseif fpsValue > 40 then
					vfxPower = 2
				else
					vfxPower = 3
				end
			else
				vfxPower = 0
			end

			if hasWorldFeature() then
				local power = worldPower()
				applyLighting(power)

				local list = Workspace:GetDescendants()
				local batch = State.GameTurbo and 100 or 140

				for i = 1, #list, batch do
					if not hasWorldFeature() and not hasCharFeature() and not State.AntiStutter then
						break
					end

					for j = i, math.min(i + batch - 1, #list) do
						local obj = list[j]
						if obj then
							optimizeWorld(obj, power)
						end
					end

					task.wait()
				end
			else
				if next(WorldBackup) ~= nil then
					restoreWorld()
				end
			end

			if hasCharFeature() then
				local power = charPower()
				local list = Players:GetPlayers()
				local batch = State.GameTurbo and 3 or 5

				for i = 1, #list, batch do
					for j = i, math.min(i + batch - 1, #list) do
						local plr = list[j]
						if plr and plr.Character then
							local char = plr.Character
							for _, obj in ipairs(char:GetDescendants()) do
								optimizeCharacterObject(obj, power)
							end
						end
					end
					task.wait()
				end
			else
				if next(CharBackup) ~= nil then
					restoreChar()
				end
			end

			if State.AntiStutter then
				collectgarbage("step", State.GameTurbo and 24 or 16)
			end

			task.wait(State.GameTurbo and 0.8 or 1.2)
		end

		brainRunning = false
	end)
end

local function refresh()
	safe(function()
		if not hasWorldFeature() then
			if next(WorldBackup) ~= nil then
				restoreWorld()
			end
		end

		if not hasCharFeature() then
			if next(CharBackup) ~= nil then
				restoreChar()
			end
		end
	end)

	if hasWorldFeature() or hasCharFeature() or State.AntiStutter then
		startBrain()
	end
end

local function setExclusive(name, value)
	if value then
		for _, key in ipairs({ "Casual", "Competitive", "Batata" }) do
			if key ~= name and switches[key] then
				switches[key].Set(false, true)
			end
			State[key] = (key == name)
		end
	else
		State[name] = false
	end
	refresh()
end

local function addSwitch(key, text, default, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -10, 0, 32)
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
	button.Position = UDim2.new(1, -45, 0.5, -10)
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
			callback(state)
		end
	end

	button.MouseButton1Click:Connect(function()
		set(not state, false)
	end)

	switches[key] = {
		Set = set,
		Get = function()
			return state
		end
	}

	set(default, true)
	return switches[key]
end

local gui = Instance.new("ScreenGui")
gui.Name = "DZ_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 230, 0, 300)
main.Position = UDim2.new(0, 20, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 30)
top.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
top.BorderSizePixel = 0
top.Parent = main
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "DZ Performance Lite"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 24)
minBtn.Position = UDim2.new(1, -58, 0, 3)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBlack
minBtn.TextSize = 18
minBtn.Parent = top

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 3)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
close
