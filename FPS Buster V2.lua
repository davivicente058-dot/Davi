-- FPS Buster v1 (Corrigido e Instrumentado para Mobile executors como Delta)
-- Use: loadstring(game:HttpGet("https://raw.githubusercontent.com/davivicente058-dot/Davi/refs/heads/main/FPS%20Buster%20v1.lua"))()

-- UTILITÁRIOS
local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok, res
end

local function notify(title, text, dur)
    dur = dur or 3
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = title, Text = text, Duration = dur})
    end)
end

local function log(...)
    local args = {...}
    for i=1,#args do
        args[i] = tostring(args[i])
    end
    print("[FPS Buster] " .. table.concat(args, " "))
end

-- CHECAGEM E DOWNLOAD SEGURO DO RAW (caso queira reusar outro RAW)
local function fetchRaw(url)
    if not url or url == "" then
        return false, "URL vazia"
    end
    local content
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if ok and type(res) == "string" and #res > 0 then
        content = res
    else
        return false, ("Falha HttpGet: %s"):format(tostring(res))
    end
    return true, content
end

-- FUNÇÃO PARA COMPILAR E EXECUTAR TEXTO LUA COM FALBACKS
local function compileAndRun(code)
    if not code or type(code) ~= "string" then
        return false, "Código inválido"
    end
    local fn, err
    if loadstring then
        fn, err = loadstring(code)
    else
        fn, err = load(code)
    end
    if not fn then
        return false, ("Erro ao compilar: %s"):format(tostring(err))
    end
    local ok, runErr = pcall(fn)
    if not ok then
        return false, ("Erro em runtime: %s"):format(tostring(runErr))
    end
    return true, "Executado com sucesso"
end

-- FUNÇÃO PRINCIPAL: inicializa com segurança e cria UI mínima se necessário
local function main()
    -- Timeout para esperar PlayerGui/Character
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        notify("FPS Buster", "LocalPlayer não encontrado", 4)
        log("LocalPlayer nil")
        return
    end

    -- Espera PlayerGui com timeout
    local playerGui = nil
    local ok, res = pcall(function() return LocalPlayer:WaitForChild("PlayerGui", 6) end)
    if ok and res then
        playerGui = res
    else
        -- fallback: tentar pegar PlayerGui diretamente
        playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    end

    if not playerGui then
        notify("FPS Buster", "PlayerGui não disponível (timeout)", 4)
        log("PlayerGui não encontrado")
        -- Ainda assim continuamos, mas sem UI
    end

    -- Função para criar uma UI simples de diagnóstico (se PlayerGui existir)
    local function createDiagnosticUI()
        if not playerGui then return end
        -- evita múltiplas GUIs
        local existing = playerGui:FindFirstChild("FPSBusterDiag")
        if existing then existing:Destroy() end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "FPSBusterDiag"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = playerGui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.28,0,0.12,0)
        frame.Position = UDim2.new(0.02,0,0.02,0)
        frame.BackgroundTransparency = 0.3
        frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
        frame.BorderSizePixel = 0
        frame.Parent = screenGui

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1,0,0.35,0)
        title.Position = UDim2.new(0,0,0,0)
        title.BackgroundTransparency = 1
        title.Text = "FPS Buster (Diag)"
        title.TextColor3 = Color3.new(1,1,1)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 16
        title.Parent = frame

        local status = Instance.new("TextLabel")
        status.Name = "Status"
        status.Size = UDim2.new(1,0,0.65,0)
        status.Position = UDim2.new(0,0,0.35,0)
        status.BackgroundTransparency = 1
        status.Text = "Pronto"
        status.TextColor3 = Color3.new(1,1,1)
        status.Font = Enum.Font.SourceSans
        status.TextSize = 12
        status.TextWrapped = true
        status.Parent = frame

        return status
    end

    local statusLabel = createDiagnosticUI()

    -- Teste rápido: tentar executar o próprio RAW atual (útil se você estiver chamando este script como wrapper)
    -- Se quiser que o script baixe outro RAW e execute, descomente e ajuste a URL abaixo:
    -- local otherUrl = "https://raw.githubusercontent.com/usuario/repo/branch/outro.lua"
    -- local okFetch, contentOrErr = fetchRaw(otherUrl)
    -- if not okFetch then
    --     notify("FPS Buster", "Falha ao baixar RAW: "..tostring(contentOrErr), 4)
    --     if statusLabel then statusLabel.Text = "Erro download: "..tostring(contentOrErr) end
    --     return
    -- end
    -- local okRun, runMsg = compileAndRun(contentOrErr)
    -- if not okRun then
    --     notify("FPS Buster", "Erro ao executar RAW: "..tostring(runMsg), 4)
    --     if statusLabel then statusLabel.Text = "Erro runtime: "..tostring(runMsg) end
    --     return
    -- end

    -- Se chegou até aqui, o wrapper está pronto. Agora vamos garantir que o script principal rode:
    -- Se você quer que este arquivo contenha todo o código do FPS (UI, otimizações etc.), cole-o abaixo.
    -- Para fins de diagnóstico, vamos exibir que o wrapper carregou.
    notify("FPS Buster", "Wrapper carregado com sucesso", 3)
    if statusLabel then statusLabel.Text = "Wrapper carregado. Pronto para executar o script principal." end
    log("Wrapper carregado com sucesso")

    -- Exemplo: inserir aqui uma rotina simples para testar se o executor está executando código:
    spawn(function()
        -- pequeno teste de execução contínua para confirmar que o script está ativo
        for i=1,5 do
            log("Teste ativo:", i)
            if statusLabel then statusLabel.Text = "Teste ativo: "..tostring(i) end
            wait(0.6)
        end
        if statusLabel then statusLabel.Text = "Teste concluído. Se nada mais aconteceu, cole o script principal aqui." end
        notify("FPS Buster", "Teste concluído", 2)
    end)
end

-- EXECUTA main de forma segura
local okMain, errMain = pcall(main)
if not okMain then
    notify("FPS Buster", "Erro ao iniciar: "..tostring(errMain), 6)
    log("Erro main:", errMain)
end

-- FIM DO WRAPPER
