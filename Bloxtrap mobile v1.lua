-- Bloxtrap Mobile
-- FPS Boost + UI personalizada + Mira aprimorada + Fonte leve (fallback) + Auto-toggle otimização com hysteresis
-- Pronto para colar no GitHub como "FPS ULTRA V3 - Bloxtrap Mobile.lua"

-- CONFIGURAÇÕES (edite conforme necessário)
local ATLAS_ASSET_ID = nil -- Ex: "rbxassetid://123456789" (opcional: se tiver atlas bitmap para fonte)
local DEFAULT_FONT_FALLBACK = Enum.Font.Arcade -- fonte leve e bonita como fallback
local AUTO_TOGGLE_ENABLED = true
local FPS_THRESHOLD_ON = 35   -- abaixo disso ativa otimizações
local FPS_THRESHOLD_OFF = 45  -- acima disso restaura (hysteresis)
local CHECK_INTERVAL = 1      -- segundos entre checagens do auto-toggle
local OPTIMIZATION_MODE = "equilibrado" -- "agressivo" ou "equilibrado"

-- Serviços
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- Guarda estados originais para restaurar
local originalSettings = {
    Lighting = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        GlobalShadows = Lighting.GlobalShadows,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
    },
    WorkspaceParts = {}, -- armazenará propriedades alteradas por peça (opcional)
    PostEffects = {}, -- efeitos de pós-processamento
}

-- Função utilitária para clonar configurações de Lighting
local function saveLightingDefaults()
    originalSettings.Lighting.Ambient = Lighting.Ambient
    originalSettings.Lighting.OutdoorAmbient = Lighting.OutdoorAmbient
    originalSettings.Lighting.Brightness = Lighting.Brightness
    originalSettings.Lighting.GlobalShadows = Lighting.GlobalShadows
    originalSettings.Lighting.ClockTime = Lighting.ClockTime
    originalSettings.Lighting.FogEnd = Lighting.FogEnd
end

saveLightingDefaults()

-- UI: criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BloxtrapMobileUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Estilo principal (janela personalizada e bonita)
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 180)
mainFrame.Position = UDim2.new(0.02, 0, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(0,0)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.ZIndex = 2
mainFrame.BackgroundTransparency = 0

-- Sombra sutil (Frame extra para profundidade)
local shadow = Instance.new("Frame", screenGui)
shadow.Name = "Shadow"
shadow.Size = UDim2.new(0, 266, 0, 186)
shadow.Position = mainFrame.Position + UDim2.new(0, 4, 0, 6)
shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
shadow.BackgroundTransparency = 0.7
shadow.BorderSizePixel = 0
shadow.ZIndex = 1

-- Cabeçalho
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 36)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
header.BorderSizePixel = 0

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Bloxtrap Mobile"
title.TextColor3 = Color3.fromRGB(220,220,220)
title.Font = DEFAULT_FONT_FALLBACK
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3

-- Botão minimizar compacto (ocupa pouco espaço)
local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
minimizeBtn.Position = UDim2.new(1, -36, 0, 4)
minimizeBtn.Text = "▢"
minimizeBtn.Font = DEFAULT_FONT_FALLBACK
minimizeBtn.TextSize = 18
minimizeBtn.TextColor3 = Color3.fromRGB(200,200,200)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40,40,44)
minimizeBtn.BorderSizePixel = 0
minimizeBtn.ZIndex = 3

-- Botão fechar (pequeno)
local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -70, 0, 4)
closeBtn.Text = "✕"
closeBtn.Font = DEFAULT_FONT_FALLBACK
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.fromRGB(200,80,80)
closeBtn.BackgroundColor3 = Color3.fromRGB(40,40,44)
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 3

-- Conteúdo
local content = Instance.new("Frame", mainFrame)
content.Size = UDim2.new(1, -12, 1, -46)
content.Position = UDim2.new(0, 6, 0, 40)
content.BackgroundTransparency = 1
content.ZIndex = 3

-- Função utilitária para criar botões estilizados
local function makeButton(text, y)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(36,36,40)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(230,230,230)
    btn.Font = DEFAULT_FONT_FALLBACK
    btn.TextSize = 15
    btn.Text = text
    btn.AutoButtonColor = true
    return btn
end

-- Indicador de FPS (mantido do jeito que você gostou)
local fpsLabel = Instance.new("TextLabel", screenGui)
fpsLabel.Name = "FPSLabel"
fpsLabel.Size = UDim2.new(0, 90, 0, 24)
fpsLabel.Position = UDim2.new(0.01, 0, 0.01, 0)
fpsLabel.BackgroundTransparency = 0.4
fpsLabel.BackgroundColor3 = Color3.fromRGB(10,10,10)
fpsLabel.BorderSizePixel = 0
fpsLabel.TextColor3 = Color3.fromRGB(255,255,255)
fpsLabel.Font = DEFAULT_FONT_FALLBACK
fpsLabel.TextSize = 14
fpsLabel.Text = "FPS: 0"
fpsLabel.ZIndex = 4
fpsLabel.TextStrokeTransparency = 0.7

-- Mira aprimorada (cruz fina e centralizada)
local mira = Instance.new("Frame", screenGui)
mira.Name = "MiraCentral"
mira.Size = UDim2.new(0, 28, 0, 28)
mira.AnchorPoint = Vector2.new(0.5, 0.5)
mira.Position = UDim2.new(0.5, 0, 0.5, 0)
mira.BackgroundTransparency = 1
mira.ZIndex = 4

local function criarLinha(parent, x, y, w, h, color)
    local linha = Instance.new("Frame", parent)
    linha.Size = UDim2.new(0, w, 0, h)
    linha.Position = UDim2.new(0.5, x, 0.5, y)
    linha.AnchorPoint = Vector2.new(0.5, 0.5)
    linha.BackgroundColor3 = color or Color3.new(1,1,1)
    linha.BorderSizePixel = 0
    linha.ZIndex = 5
    return linha
end

-- linhas finas para melhor visibilidade
criarLinha(mira, -8, 0, 6, 2, Color3.fromRGB(255,255,255)) -- esquerda
criarLinha(mira, 8, 0, 6, 2, Color3.fromRGB(255,255,255))  -- direita
criarLinha(mira, 0, -8, 2, 6, Color3.fromRGB(255,255,255)) -- cima
criarLinha(mira, 0, 8, 2, 6, Color3.fromRGB(255,255,255))  -- baixo
-- pequeno ponto central
local centerDot = Instance.new("Frame", mira)
centerDot.Size = UDim2.new(0,2,0,2)
centerDot.Position = UDim2.new(0.5,0,0.5,0)
centerDot.AnchorPoint = Vector2.new(0.5,0.5)
centerDot.BackgroundColor3 = Color3.fromRGB(255,255,255)
centerDot.BorderSizePixel = 0
centerDot.ZIndex = 6

-- Botões principais
local btnBoost = makeButton("FPS Boost: OFF", 0)
local btnMira = makeButton("Mira: ON", 40)
local btnIluminacao = makeButton("Modo: Escuro", 80)
local btnPadrao = makeButton("Restaurar Padrão", 120)

-- Estado de otimização
local otimizado = false

-- Funções de iluminação e otimização (com restore)
local function aplicarModoEscuro()
    Lighting.Ambient = Color3.fromRGB(12,12,12)
    Lighting.OutdoorAmbient = Color3.fromRGB(12,12,12)
    Lighting.Brightness = 0.12
    Lighting.ClockTime = 20
end

local function aplicarModoClaro()
    Lighting.Ambient = Color3.fromRGB(220,220,220)
    Lighting.OutdoorAmbient = Color3.fromRGB(220,220,220)
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
end

local function aplicarModoPadrao()
    Lighting.Ambient = originalSettings.Lighting.Ambient
    Lighting.OutdoorAmbient = originalSettings.Lighting.OutdoorAmbient
    Lighting.Brightness = originalSettings.Lighting.Brightness
    Lighting.ClockTime = originalSettings.Lighting.ClockTime
    Lighting.GlobalShadows = originalSettings.Lighting.GlobalShadows
    Lighting.FogEnd = originalSettings.Lighting.FogEnd
end

-- Função que aplica otimizações (reversível)
local function applyOptimizations(mode)
    mode = mode or OPTIMIZATION_MODE
    -- salvar propriedades de partes alteradas (somente se ainda não salvo)
    -- percorre em batches para evitar travamentos
    local parts = Workspace:GetDescendants()
    for i = 1, #parts do
        local v = parts[i]
        if v:IsA("BasePart") then
            -- salva apenas se ainda não salvo
            if not originalSettings.WorkspaceParts[v] then
                originalSettings.WorkspaceParts[v] = {
                    Material = v.Material,
                    Reflectance = v.Reflectance,
                    CastShadow = v.CastShadow,
                }
            end
            -- aplicar otimizações leves/agressivas
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            -- destruir decal/textura pode ser agressivo; em modo equilibrado apenas desativar
            if mode == "agressivo" then
                pcall(function() v:Destroy() end)
            else
                -- tentar tornar invisível sem destruir (se possível)
                pcall(function() v.Transparency = 1 end)
            end
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            if mode == "agressivo" then
                pcall(function() v.Enabled = false end)
            else
                pcall(function() v.Rate = math.max(0, (v.Rate or 10) * 0.2) end)
            end
        end
    end

    -- Lighting tweaks
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    if mode == "agressivo" then
        Lighting.Ambient = Color3.fromRGB(8,8,8)
        Lighting.Brightness = 0.08
    else
        Lighting.Ambient = Color3.fromRGB(12,12,12)
        Lighting.Brightness = 0.12
    end

    -- Desativar efeitos de pós-processamento se existirem
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("BlurEffect") or child:IsA("BloomEffect") or child:IsA("ColorCorrectionEffect") or child:IsA("SunRaysEffect") then
            if not originalSettings.PostEffects[child] then
                originalSettings.PostEffects[child] = {
                    Enabled = child.Enabled
                }
            end
            child.Enabled = false
        end
    end
end

local function restoreOptimizations()
    -- restaurar partes
    for part, props in pairs(originalSettings.WorkspaceParts) do
        if part and part.Parent then
            pcall(function()
                part.Material = props.Material
                part.Reflectance = props.Reflectance
                part.CastShadow = props.CastShadow
            end)
        end
    end
    -- restaurar lighting
    aplicarModoPadrao()
    -- restaurar post effects
    for eff, props in pairs(originalSettings.PostEffects) do
        if eff and eff.Parent then
            pcall(function() eff.Enabled = props.Enabled end)
        end
    end
end

-- Toggle otimização manual
btnBoost.MouseButton1Click:Connect(function()
    otimizado = not otimizado
    if otimizado then
        applyOptimizations(OPTIMIZATION_MODE)
        btnBoost.Text = "FPS Boost: ON"
    else
        restoreOptimizations()
        btnBoost.Text = "FPS Boost: OFF"
    end
end)

-- Toggle mira
btnMira.MouseButton1Click:Connect(function()
    mira.Visible = not mira.Visible
    btnMira.Text = mira.Visible and "Mira: ON" or "Mira: OFF"
end)

-- Ciclo de modos de iluminação (escuro -> claro -> padrão)
local modoIluminacao = "escuro"
btnIluminacao.MouseButton1Click:Connect(function()
    if modoIluminacao == "escuro" then
        aplicarModoClaro()
        modoIluminacao = "claro"
        btnIluminacao.Text = "Modo: Claro"
    elseif modoIluminacao == "claro" then
        aplicarModoPadrao()
        modoIluminacao = "padrao"
        btnIluminacao.Text = "Modo: Padrão"
    else
        aplicarModoEscuro()
        modoIluminacao = "escuro"
        btnIluminacao.Text = "Modo: Escuro"
    end
end)

-- Restaurar padrão
btnPadrao.MouseButton1Click:Connect(function()
    restoreOptimizations()
    btnBoost.Text = "FPS Boost: OFF"
    otimizado = false
    aplicarModoPadrao()
end)

-- Minimizar/expandir (compacto)
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        -- reduzir para barra compacta
        mainFrame.Size = UDim2.new(0, 160, 0, 36)
        mainFrame.Position = mainFrame.Position -- mantém posição
        content.Visible = false
        header.Size = UDim2.new(1, 0, 0, 36)
        title.Text = "Bloxtrap Mobile (min)"
        shadow.Size = UDim2.new(0, 166, 0, 42)
    else
        mainFrame.Size = UDim2.new(0, 260, 0, 180)
        content.Visible = true
        header.Size = UDim2.new(1, 0, 0, 36)
        title.Text = "Bloxtrap Mobile"
        shadow.Size = UDim2.new(0, 266, 0, 186)
    end
end)

-- Fechar
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    pcall(function() shadow:Destroy() end)
end)

-- FPS contador (estável)
local lastUpdate = tick()
local frameCount = 0
local fps = 0

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastUpdate >= 1 then
        fps = math.floor(frameCount / (now - lastUpdate))
        fpsLabel.Text = "FPS: " .. fps
        frameCount = 0
        lastUpdate = now
    end
end)

-- Auto-toggle otimização com hysteresis
spawn(function()
    if not AUTO_TOGGLE_ENABLED then return end
    while screenGui.Parent do
        wait(CHECK_INTERVAL)
        local currentFPS = tonumber(string.match(fpsLabel.Text, "%d+")) or fps
        if not otimizado and currentFPS < FPS_THRESHOLD_ON then
            otimizado = true
            applyOptimizations(OPTIMIZATION_MODE)
            btnBoost.Text = "FPS Boost: ON"
        elseif otimizado and currentFPS >= FPS_THRESHOLD_OFF then
            otimizado = false
            restoreOptimizations()
            btnBoost.Text = "FPS Boost: OFF"
        end
    end
end)

-- Fonte leve fallback: aplica em labels existentes para reduzir custo visual
local function applyLightFontToGui(root)
    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            pcall(function()
                obj.Font = DEFAULT_FONT_FALLBACK
                -- reduzir efeitos pesados
                if obj.TextStrokeTransparency then obj.TextStrokeTransparency = math.max(0.6, obj.TextStrokeTransparency) end
                if obj.TextSize and obj.TextSize > 20 then
                    obj.TextSize = math.max(12, math.floor(obj.TextSize * 0.9))
                end
            end)
        end
    end
end

-- Aplica fonte leve ao UI do script e ao StarterGui (opcional)
applyLightFontToGui(screenGui)
pcall(function() applyLightFontToGui(StarterGui) end)

-- Bitmap font (opcional): se ATLAS_ASSET_ID fornecido, cria função simples para renderizar texto com atlas
local BitmapFont = {}
if ATLAS_ASSET_ID then
    -- configuração simples: atlas em grid 16x6 por padrão (ajuste se necessário)
    BitmapFont.ATLAS = ATLAS_ASSET_ID
    BitmapFont.COLUMNS = 16
    BitmapFont.ROWS = 6
    BitmapFont.CHAR_ORDER = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

    local pool = {}

    local function newCharImage(parent)
        local img = Instance.new("ImageLabel")
        img.BackgroundTransparency = 1
        img.BorderSizePixel = 0
        img.Image = BitmapFont.ATLAS
        img.Parent = parent
        img.ZIndex = 10
        return img
    end

    local function getPooledChar(parent)
        local img = table.remove(pool)
        if img then
            img.Parent = parent
            img.Visible = true
            return img
        end
        return newCharImage(parent)
    end

    local function recycleChar(img)
        if not img then return end
        img.Visible = false
        img.Parent = nil
        table.insert(pool, img)
    end

    function BitmapFont:RenderText(container, text, opts)
        opts = opts or {}
        local size = opts.size or 18
        local spacing = opts.spacing or 0
        local color = opts.color or Color3.new(1,1,1)
        -- limpar filhos antigos
        for _, c in ipairs(container:GetChildren()) do
            if c:IsA("ImageLabel") then
                recycleChar(c)
            end
        end
        if not text or text == "" then return end
        local charCount = #text
        local totalWidth = charCount * size + (charCount - 1) * spacing
        local startX = 0
        if opts.align == "center" then
            startX = (container.AbsoluteSize.X - totalWidth) / 2
        elseif opts.align == "right" then
            startX = container.AbsoluteSize.X - totalWidth
        else
            startX = 0
        end
        for i = 1, #text do
            local c = text:sub(i,i)
            local idx = string.find(BitmapFont.CHAR_ORDER, c, 1, true) or 1
            local zero = idx - 1
            local col = zero % BitmapFont.COLUMNS
            local row = math.floor(zero / BitmapFont.COLUMNS)
            local img = getPooledChar(container)
            img.Size = UDim2.new(0, size, 0, size)
            img.Position = UDim2.new(0, startX + (i-1)*(size + spacing), 0, 0)
            -- ImageRectOffset/Size assume atlas 1024px base; ajuste se necessário
            local atlasW = 1024
            local atlasH = 1024
            local cellW = atlasW / BitmapFont.COLUMNS
            local cellH = atlasH / BitmapFont.ROWS
            img.ImageRectOffset = Vector2.new(col * cellW, row * cellH)
            img.ImageRectSize = Vector2.new(cellW, cellH)
            img.ImageColor3 = color
            img.Parent = container
        end
    end
end

-- Mensagem de inicialização (console)
print("[Bloxtrap Mobile] carregado. Modo de otimização:", OPTIMIZATION_MODE)

-- Fim do script
