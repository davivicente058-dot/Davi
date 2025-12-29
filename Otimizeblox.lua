--[[ 
 ROBLOX FPS OPTIMIZER
 PARTE 1 - BASE + UI MANUAL PROFISSIONAL
 Tudo inicia DESLIGADO
 Compatível Mobile e PC
]]

-- Serviços
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- ===============================
-- LIMPAR UI ANTIGA
-- ===============================
if PlayerGui:FindFirstChild("FPSOptimizerUI") then
	PlayerGui.FPSOptimizerUI:Destroy()
end

-- ===============================
-- ESTADOS GLOBAIS
-- ===============================
_G.FPS_OPT = {
	Graphics = false,
	LightingMode = "Padrao",
	FPSCounter = false,
	Crosshair = false,
	ReduceParticles = false,
	ReduceAnimations = false,
	ExtremeMode = false
}

-- ===============================
-- UI BASE
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "FPSOptimizerUI"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.4, 0.55)
main.Position = UDim2.fromScale(0.3, 0.2)
main.BackgroundColor3 = Color3.fromRGB(18,18,22)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 12)

-- ===============================
-- HEADER
-- ===============================
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,40)
header.BackgroundColor3 = Color3.fromRGB(28,28,34)
header.BorderSizePixel = 0

Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", header)
title.Text = "FPS OPTIMIZER"
title.Size = UDim2.new(1,-90,1,0)
title.Position = UDim2.new(0,15,0,0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(235,235,235)
title.TextXAlignment = Left
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local minimize = Instance.new("TextButton", header)
minimize.Text = "-"
minimize.Size = UDim2.new(0,30,0,30)
minimize.Position = UDim2.new(1,-40,0,5)
minimize.BackgroundColor3 = Color3.fromRGB(45,45,55)
minimize.TextColor3 = Color3.fromRGB(255,255,255)
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 18
Instance.new("UICorner", minimize)

-- ===============================
-- CONTAINER
-- ===============================
local container = Instance.new("Frame", main)
container.Size = UDim2.new(1,-20,1,-60)
container.Position = UDim2.new(0,10,0,50)
container.BackgroundTransparency = 1

-- ===============================
-- FUNÇÃO BOTÃO PADRÃO
-- ===============================
local function createButton(text, yPos)
	local btn = Instance.new("TextButton", container)
	btn.Size = UDim2.new(1,0,0,40)
	btn.Position = UDim2.new(0,0,0,yPos)
	btn.BackgroundColor3 = Color3.fromRGB(35,35,42)
	btn.TextColor3 = Color3.fromRGB(220,220,220)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.Text = text
	btn.AutoButtonColor = true
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
	return btn
end

-- ===============================
-- BOTÕES BASE (AINDA SEM FUNÇÃO)
-- ===============================
local btnGraphics = createButton("Otimização Gráfica: OFF", 0)
local btnLighting = createButton("Iluminação: PADRÃO", 50)
local btnFPS = createButton("Mostrar FPS: OFF", 100)
local btnCross = createButton("Mira Central: OFF", 150)
local btnAdvanced = createButton("Reduções Avançadas: OFF", 200)
local btnExtreme = createButton("Modo EXTREMO: OFF", 250)

-- ===============================
-- MINIMIZAR
-- ===============================
local minimized = false
minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	container.Visible = not minimized
	main.Size = minimized and UDim2.fromScale(0.4,0.08) or UDim2.fromScale(0.4,0.55)
end)

print("FPS OPTIMIZER - PARTE 1 CARREGADA COM SUCESSO")

--[[ 
 FPS OPTIMIZER
 PARTE 2 - GRÁFICOS + ILUMINAÇÃO
]]

-- ===============================
-- OTIMIZAÇÃO GRÁFICA
-- ===============================
local function applyGraphicsOptimization(state)
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CastShadow = not state
			if state then
				v.Material = Enum.Material.Plastic
				v.Reflectance = 0
			end
		elseif v:IsA("Decal") or v:IsA("Texture") then
			if state then
				v.Transparency = 0.2
			end
		end
	end
end

-- ===============================
-- ILUMINAÇÃO MODOS
-- ===============================
local lightingPresets = {
	Padrao = function()
		Lighting.GlobalShadows = true
		Lighting.Brightness = 2
		Lighting.EnvironmentDiffuseScale = 1
		Lighting.EnvironmentSpecularScale = 1
		Lighting.FogEnd = 100000
	end,

	Claro = function()
		Lighting.GlobalShadows = false
		Lighting.Brightness = 3
		Lighting.EnvironmentDiffuseScale = 0.5
		Lighting.EnvironmentSpecularScale = 0
		Lighting.FogEnd = 100000
	end,

	Escuro = function()
		Lighting.GlobalShadows = false
		Lighting.Brightness = 1
		Lighting.EnvironmentDiffuseScale = 0.3
		Lighting.EnvironmentSpecularScale = 0
		Lighting.FogEnd = 800
	end
}

-- ===============================
-- CONECTAR BOTÕES (PARTE 1)
-- ===============================
btnGraphics.MouseButton1Click:Connect(function()
	_G.FPS_OPT.Graphics = not _G.FPS_OPT.Graphics
	applyGraphicsOptimization(_G.FPS_OPT.Graphics)

	btnGraphics.Text = _G.FPS_OPT.Graphics
		and "Otimização Gráfica: ON"
		or "Otimização Gráfica: OFF"
end)

btnLighting.MouseButton1Click:Connect(function()
	if _G.FPS_OPT.LightingMode == "Padrao" then
		_G.FPS_OPT.LightingMode = "Claro"
	elseif _G.FPS_OPT.LightingMode == "Claro" then
		_G.FPS_OPT.LightingMode = "Escuro"
	else
		_G.FPS_OPT.LightingMode = "Padrao"
	end

	lightingPresets[_G.FPS_OPT.LightingMode]()

	btnLighting.Text = "Iluminação: " .. string.upper(_G.FPS_OPT.LightingMode)
end)

print("FPS OPTIMIZER - PARTE 2 CARREGADA COM SUCESSO")
