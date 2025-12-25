-- FPS BOOST AVANÇADO UNIVERSAL PARA ROBLOX
-- Compatível com executores móveis e PC (Delta, Fluxus, Hydrogen, etc.)

-- Proteção contra erros
local function safe(p, ...)
    local s, r = pcall(p, ...)
    return s and r or nil
end

-- Otimiza iluminação
local Lighting = safe(game.GetService, game, "Lighting")
if Lighting then
    safe(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e10
        Lighting.Brightness = 1
        Lighting.ClockTime = 14
        Lighting.FogStart = 0
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Ambient = Color3.new(1, 1, 1)
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") then
                v.Enabled = false
            end
        end
    end)
end

-- Remove partículas, efeitos e decalques
for _, obj in pairs(workspace:GetDescendants()) do
    safe(function()
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
            obj.Enabled = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = false
        elseif obj:IsA("Explosion") then
            obj:Destroy()
        end
    end)
end

-- Otimiza o terreno
local Terrain = safe(function() return workspace:FindFirstChildOfClass("Terrain") end)
if Terrain then
    safe(function()
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end)
end

-- Remove sons desnecessários
for _, s in pairs(workspace:GetDescendants()) do
    safe(function()
        if s:IsA("Sound") and not s:IsDescendantOf(game.Players.LocalPlayer.Character) then
            s:Stop()
            s.Volume = 0
        end
    end)
end

-- Desativa animações de NPCs
for _, h in pairs(workspace:GetDescendants()) do
    safe(function()
        if h:IsA("Humanoid") and not h:IsDescendantOf(game.Players.LocalPlayer) then
            h:ChangeState(11) -- Physics
        end
    end)
end

-- Reduz distância de renderização
local cam = safe(function() return workspace.CurrentCamera end)
if cam then
    safe(function()
        cam.FieldOfView = 70
        cam.FarPlane = 1000
    end)
end

-- Remove acessórios e roupas de NPCs
for _, p in pairs(game:GetService("Players"):GetPlayers()) do
    if p ~= game.Players.LocalPlayer then
        local char = safe(function() return p.Character end)
        if char then
            for _, item in pairs(char:GetDescendants()) do
                safe(function()
                    if item:IsA("Accessory") or item:IsA("Clothing") then
                        item:Destroy()
                    end
                end)
            end
        end
    end
end

-- Notificação
safe(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "FPS Boost Ativado",
        Text = "Desempenho máximo aplicado!",
        Duration = 6
    })
end)

print("FPS Boost Avançado executado com sucesso.")
