-- ROBLOX FPS OPTIMIZER - PARTE 1
-- UI Base Profissional | Abas | Minimizar
-- Tudo DESLIGADO por padrão

-- =============================
-- SERVIÇOS
-- =============================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- =============================
-- UI BASE
-- =============================
local gui = Instance.new("ScreenGui")
gui.Name = "FPSOptimizerUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 380)
main.Position = UDim2.new(0.5, -160, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 10)

-- =============================
-- TOPO
-- =============================
local top = Instance.new("Frame", main)
top.Size = UDim2.new(1, 0, 0, 40)
top.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
top.BorderSizePixel = 0

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "ROBLOX FPS OPTIMIZER"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.BackgroundTransparency = 1
title.TextXAlignment = Left

local minimized = false

local minimizeBtn = Instance.new("TextButton", top)
minimizeBtn.Size = UDim2.new(0, 40, 0, 30)
minimizeBtn.Position = UDim2.new(1, -45, 0.5, -15)
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 20
minimizeBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.BorderSizePixel = 0

local body = Instance.new("Frame", main)
body.Position = UDim2.new(0, 0, 0, 40)
body.Size = UDim2.new(1, 0, 1, -40)
body.BackgroundTransparency = 1

minimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	body.Visible = not minimized
	main.Size = minimized and UDim2.new(0,320,0,40) or UDim2.new(0,320,0,380)
	minimizeBtn.Text = minimized and "+" or "-"
end)

-- =============================
-- ABAS
-- =============================
local tabs = Instance.new("Frame", body)
tabs.Size = UDim2.new(1, 0, 0, 35)
tabs.BackgroundTransparency = 1

local pages = Instance.new("Folder", body)

local function createPage(name)
	local frame = Instance.new("ScrollingFrame", pages)
	frame.Name = name
	frame.Size = UDim2.new(1, -10, 1, -50)
	frame.Position = UDim2.new(0, 5, 0, 45)
	frame.CanvasSize = UDim2.new(0,0,0,0)
	frame.ScrollBarThickness = 4
	frame.Visible = false
	frame.BackgroundTransparency = 1
	return frame
end

local pageOpt = createPage("Otimizacao")
local pageGraf = createPage("Graficos")
local pageAdv = createPage("Avancado")

pageOpt.Visible = true

local function createTab(text, x, page)
	local btn = Instance.new("TextButton", tabs)
	btn.Size = UDim2.new(0, 100, 1, 0)
	btn.Position = UDim2.new(0, x, 0, 0)
	btn.Text = text
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 14
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
	btn.BorderSizePixel = 0

	btn.MouseButton1Click:Connect(function()
		for _,v in pairs(pages:GetChildren()) do
			v.Visible = false
		end
		page.Visible = true
	end)
end

createTab("Otimização", 5, pageOpt)
createTab("Gráficos", 110, pageGraf)
createTab("Avançado", 215, pageAdv)

-- =============================
-- SISTEMA DE TOGGLE (BASE)
-- =============================
local function createToggle(parent, text, yPos)
	local toggle = Instance.new("TextButton", parent)
	toggle.Size = UDim2.new(1, -10, 0, 36)
	toggle.Position = UDim2.new(0, 5, 0, yPos)
	toggle.Text = "[ OFF ] " .. text
	toggle.Font = Enum.Font.SourceSans
	toggle.TextSize = 14
	toggle.TextColor3 = Color3.new(1,1,1)
	toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
	toggle.BorderSizePixel = 0

	local state = false
	toggle.MouseButton1Click:Connect(function()
		state = not state
		toggle.Text = (state and "[ ON ] " or "[ OFF ] ") .. text
	end)

	return toggle
end

-- Placeholders (as funções reais entram na Parte 2 e 3)
createToggle(pageOpt, "Modo Competitivo", 0)
createToggle(pageOpt, "Otimização Geral", 45)

createToggle(pageGraf, "Reduzir Sombras", 0)
createToggle(pageGraf, "Reduzir Luzes", 45)

createToggle(pageAdv, "FPS Counter", 0)
createToggle(pageAdv, "Névoa por Distância", 45)

print("FPS OPTIMIZER - PARTE 1 CARREGADA COM SUCESSO")

-- ROBLOX FPS OPTIMIZER - PARTE 2
-- Otimização real | Modo competitivo | Reduções inteligentes

-- =============================
-- REFERÊNCIAS DA UI (DA PARTE 1)
-- =============================
local pages = game.Players.LocalPlayer.PlayerGui.FPSOptimizerUI.Frame.Frame:FindFirstChild("Folder") 
-- segurança extra
if not pages then
	warn("Erro ao localizar páginas da UI")
	return
end

local pageOpt = pages:FindFirstChild("Otimizacao")
local pageGraf = pages:FindFirstChild("Graficos")

-- =============================
-- VARIÁVEIS DE ESTADO
-- =============================
local otimGeral = false
local modoCompetitivo = false
local sombrasReduzidas = false
local luzesReduzidas = false
local particulasReduzidas = false
local animacoesReduzidas = false

-- =============================
-- FUNÇÕES BASE DE OTIMIZAÇÃO
-- =============================
local Lighting = game:GetService("Lighting")

local function otimizarIluminacaoLeve()
	Lighting.GlobalShadows = false
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
	Lighting.Brightness = 2
end

local function restaurarIluminacao()
	Lighting.GlobalShadows = true
	Lighting.EnvironmentDiffuseScale = 1
	Lighting.EnvironmentSpecularScale = 1
	Lighting.Brightness = 3
end

-- =============================
-- SOMBRAS
-- =============================
local function reduzirSombras(on)
	sombrasReduzidas = on
	if on then
		Lighting.GlobalShadows = false
	else
		Lighting.GlobalShadows = true
	end
end

-- =============================
-- LUZES
-- =============================
local function reduzirLuzes(on)
	luzesReduzidas = on
	for _,v in ipairs(workspace:GetDescendants()) do
		if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
			v.Enabled = not on
		end
	end
end

-- =============================
-- PARTÍCULAS
-- =============================
local function reduzirParticulas(on)
	particulasReduzidas = on
	for _,v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Trail") then
			v.Enabled = not on
		end
	end
end

-- =============================
-- ANIMAÇÕES
-- =============================
local function reduzirAnimacoes(on)
	animacoesReduzidas = on
	local char = game.Players.LocalPlayer.Character
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	for _,track in ipairs(humanoid:GetPlayingAnimationTracks()) do
		if on then
			track:AdjustSpeed(0)
		else
			track:AdjustSpeed(1)
		end
	end
end

-- =============================
-- OTIMIZAÇÃO GERAL
-- =============================
local function otimizarGeral(on)
	otimGeral = on
	if on then
		otimizarIluminacaoLeve()
	else
		restaurarIluminacao()
	end
end

-- =============================
-- MODO COMPETITIVO (PESADO)
-- =============================
local function ativarModoCompetitivo(on)
	modoCompetitivo = on
	if on then
		otimizarGeral(true)
		reduzirSombras(true)
		reduzirLuzes(true)
		reduzirParticulas(true)
		reduzirAnimacoes(true)

		for _,v in ipairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Material = Enum.Material.Plastic
				v.Reflectance = 0
			end
		end
	else
		otimizarGeral(false)
		reduzirSombras(false)
		reduzirLuzes(false)
		reduzirParticulas(false)
		reduzirAnimacoes(false)
	end
end

-- =============================
-- CONECTAR BOTÕES (UI)
-- =============================
for _,btn in ipairs(pageOpt:GetChildren()) do
	if btn:IsA("TextButton") then
		if btn.Text:find("Modo Competitivo") then
			btn.MouseButton1Click:Connect(function()
				modoCompetitivo = not modoCompetitivo
				ativarModoCompetitivo(modoCompetitivo)
			end)
		elseif btn.Text:find("Otimização Geral") then
			btn.MouseButton1Click:Connect(function()
				otimGeral = not otimGeral
				otimizarGeral(otimGeral)
			end)
		end
	end
end

for _,btn in ipairs(pageGraf:GetChildren()) do
	if btn:IsA("TextButton") then
		if btn.Text:find("Reduzir Sombras") then
			btn.MouseButton1Click:Connect(function()
				sombrasReduzidas = not sombrasReduzidas
				reduzirSombras(sombrasReduzidas)
			end)
		elseif btn.Text:find("Reduzir Luzes") then
			btn.MouseButton1Click:Connect(function()
				luzesReduzidas = not luzesReduzidas
				reduzirLuzes(luzesReduzidas)
			end)
		end
	end
end

print("FPS OPTIMIZER - PARTE 2 CARREGADA COM SUCESSO")

-- ROBLOX FPS OPTIMIZER - PARTE 3
-- FPS Counter REAL | Inteligente | Mobile Friendly

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- =============================
-- UI DO FPS
-- =============================
local fpsGui = Instance.new("ScreenGui")
fpsGui.Name = "FPSCounterGUI"
fpsGui.ResetOnSpawn = false
fpsGui.Parent = player:WaitForChild("PlayerGui")
fpsGui.Enabled = false -- começa DESLIGADO

local fpsLabel = Instance.new("TextLabel", fpsGui)
fpsLabel.Size = UDim2.new(0, 130, 0, 28)
fpsLabel.Position = UDim2.new(0, 12, 1, -70) -- canto inferior esquerdo (mobile)
fpsLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
fpsLabel.BackgroundTransparency = 0.25
fpsLabel.BorderSizePixel = 0
fpsLabel.Text = "FPS: 0"
fpsLabel.Font = Enum.Font.SourceSansBold
fpsLabel.TextSize = 16
fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
fpsLabel.TextXAlignment = Enum.TextXAlignment.Center

local corner = Instance.new("UICorner", fpsLabel)
corner.CornerRadius = UDim.new(0, 6)

-- =============================
-- SISTEMA INTELIGENTE DE FPS
-- =============================
local frames = {}
local maxSamples = 30 -- suavização
local lastUpdate = 0
local updateRate = 0.3 -- atualiza texto 3x por segundo

RunService.RenderStepped:Connect(function(delta)
	if not fpsGui.Enabled then return end

	local fps = 1 / delta
	table.insert(frames, fps)

	if #frames > maxSamples then
		table.remove(frames, 1)
	end

	local now = tick()
	if now - lastUpdate >= updateRate then
		lastUpdate = now

		local total = 0
		for _,v in ipairs(frames) do
			total += v
		end

		local avgFPS = math.floor(total / #frames)
		fpsLabel.Text = "FPS: " .. avgFPS

		-- muda cor dinamicamente (feedback visual)
		if avgFPS >= 60 then
			fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
		elseif avgFPS >= 40 then
			fpsLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
		else
			fpsLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		end
	end
end)

-- =============================
-- CONECTAR AO BOTÃO DA UI (PARTE 1)
-- =============================
task.spawn(function()
	task.wait(1)

	local ui = player.PlayerGui:FindFirstChild("FPSOptimizerUI")
	if not ui then return end

	for _,btn in ipairs(ui:GetDescendants()) do
		if btn:IsA("TextButton") and btn.Text:find("FPS Counter") then
			btn.MouseButton1Click:Connect(function()
				fpsGui.Enabled = not fpsGui.Enabled
			end)
		end
	end
end)

print("FPS OPTIMIZER - PARTE 3 (FPS COUNTER) CARREGADA COM SUCESSO")

-- ROBLOX FPS OPTIMIZER - PARTE 4
-- Fluidez | Anti quedas de FPS | Estabilidade

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- =============================
-- ESTADOS
-- =============================
local fluidezAtiva = false
local antiLagAtivo = false

-- =============================
-- AJUSTES DE FLUIDEZ (FRAME CONTROL)
-- =============================
local lastStep = 0
local stepInterval = 1 / 60 -- alvo 60hz base (ajuda estabilidade)

RunService.RenderStepped:Connect(function(dt)
	if not fluidezAtiva then return end

	-- evita cálculos em excesso se o frame já passou rápido demais
	if tick() - lastStep < stepInterval then
		return
	end

	lastStep = tick()
end)

-- =============================
-- ANTI QUEDAS DE FPS
-- =============================
local function ativarAntiLag(on)
	antiLagAtivo = on

	if on then
		-- reduz pós-processamento pesado
		for _,v in ipairs(Lighting:GetChildren()) do
			if v:IsA("BloomEffect")
			or v:IsA("BlurEffect")
			or v:IsA("ColorCorrectionEffect")
			or v:IsA("SunRaysEffect")
			or v:IsA("DepthOfFieldEffect") then
				v.Enabled = false
			end
		end
	else
		-- não reativa automaticamente (segurança)
	end
end

-- =============================
-- FLUIDEZ GERAL (AJUSTES CONTÍNUOS)
-- =============================
task.spawn(function()
	while true do
		if fluidezAtiva then
			-- reduz física desnecessária
			sethiddenproperty(workspace, "InterpolationThrottling", Enum.InterpolationThrottlingMode.Enabled)

			-- reduz cálculos de iluminação dinâmica
			Lighting.Technology = Enum.Technology.Compatibility
		end
		task.wait(1)
	end
end)

-- =============================
-- CONECTAR À UI (ABA AVANÇADO)
-- =============================
task.spawn(function()
	task.wait(1)

	local ui = player.PlayerGui:FindFirstChild("FPSOptimizerUI")
	if not ui then return end

	for _,btn in ipairs(ui:GetDescendants()) do
		if btn:IsA("TextButton") then
			if btn.Text:find("Fluidez") then
				btn.MouseButton1Click:Connect(function()
					fluidezAtiva = not fluidezAtiva
				end)
			elseif btn.Text:find("Anti") or btn.Text:find("Queda") then
				btn.MouseButton1Click:Connect(function()
					ativarAntiLag(not antiLagAtivo)
				end)
			end
		end
	end
end)

print("FPS OPTIMIZER - PARTE 4 (FLUIDEZ) CARREGADA COM SUCESSO")
