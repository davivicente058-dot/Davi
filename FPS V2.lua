-- FPS BOOST EXTREMO COM CONTROLE DE CLARIDADE
-- Compatível com executores móveis (Delta, Fluxus, Hydrogen)

local safe = function(f, ...) local s, r = pcall(f, ...) return s and r or nil end

-- ESCOLHA DE CLARIDADE: "claro", "padrao", "escuro"
local brilho = "padrao"

local brilhoConfig = {
    claro = {Ambient = Color3.new(1,1,1), OutdoorAmbient = Color3.new(1,1,1), Brightness = 2, ClockTime = 14},
    padrao = {Ambient = Color3.new(0.5,0.5,0.5), OutdoorAmbient = Color3.new(0.5,0.5,0.5), Brightness = 1, ClockTime = 12},
    escuro = {Ambient = Color3.new(0.2,0.2,0.2), OutdoorAmbient = Color3.new(0.2,0.2,0.2), Brightness = 0.5, ClockTime = 18}
}

local Lighting = safe(game.GetService, game, "Lighting")
if Lighting and brilhoConfig[brilho] then
    local b = brilhoConfig[brilho]
    safe(function()
        Lighting.Ambient = b.Ambient
        Lighting.OutdoorAmbient = b.OutdoorAmbient
        Lighting.Brightness = b.Brightness
        Lighting.ClockTime = b.ClockTime
        Lighting.FogEnd = 1e10
        Lighting.FogStart = 0
        Lighting.GlobalShadows = false
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") then v.Enabled = false end
        end
    end)
end

-- OTIMIZAÇÃO EXTREMA
for _, obj in pairs(workspace:GetDescendants()) do
    safe(function()
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = false
            obj.Anchored = true
            obj.CanCollide = false
            if obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
                obj.TextureID = ""
            end
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("Beam") or obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") or obj:IsA("SelectionBox") then
            obj:Destroy()
        elseif obj:IsA("ForceField") or obj:IsA("Explosion") then
            obj:Destroy()
        elseif obj:IsA("Sound") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            obj:Stop()
            obj.Volume = 0
        end
    end)
end

-- TERRENO
local Terrain = safe(function() return workspace:FindFirstChildOfClass("Terrain") end)
if Terrain then
    safe(function()
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end)
end

-- NPCs
for _, h in pairs(workspace:GetDescendants()) do
    safe(function()
        if h:IsA("Humanoid") and not h:IsDescendantOf(game.Players.LocalPlayer) then
            h:ChangeState(11)
            h.WalkSpeed = 0
            h.JumpPower = 0
            h.AutoRotate = false
        end
    end)
end

-- AVATARES
for _, p in pairs(game:GetService("Players"):GetPlayers()) do
    if p ~= game.Players.LocalPlayer then
        local char = safe(function() return p.Character end)
        if char then
            for _, item in pairs(char:GetDescendants()) do
                safe(function()
                    if item:IsA("Accessory") or item:IsA("Clothing") or item:IsA("ShirtGraphic") then
                        item:Destroy()
                    end
                end)
            end
        end
    end
end

-- STREAMING ENABLED (se suportado)
local ws = safe(game.GetService, game, "Workspace")
if ws then
    safe(function()
        ws.StreamingEnabled = true
        ws.StreamingMinRadius = 64
        ws.StreamingTargetRadius = 128
    end)
end

-- NOTIFICAÇÃO
safe(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "FPS Boost Ativado",
        Text = "Modo de claridade: " .. brilho,
        Duration = 6
    })
end)

print("FPS Boost EXTREMO ativado com claridade: " .. brilho)
