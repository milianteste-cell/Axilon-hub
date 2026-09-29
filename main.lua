-- ================================================
-- AXILON HUB | Rodograu 2.0 (Mobile / Delta)
-- ================================================

-- Carrega a biblioteca de interface (Link Direto / Espelho)
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()

-- Cria a Janela Principal do Axilon Hub
local Window = OrionLib:MakeWindow({
    Name = "Axilon Hub | Rodograu", 
    HidePremium = false, 
    SaveConfig = false, 
    IntroText = "Bem-vindo ao Axilon Hub!"
})

-- ABA 1: Teleportes
local TabTeleportes = Window:MakeTab({
    Name = "Teleportes",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TabTeleportes:AddSection({
    Name = "Locais do Mapa"
})

local function Teleportar(cf)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cf
    end
end

TabTeleportes:AddButton({
    Name = "Teleportar para a Praia",
    Callback = function()
        Teleportar(CFrame.new(0, 15, 500))
    end    
})

TabTeleportes:AddButton({
    Name = "Teleportar para a Brasilândia",
    Callback = function()
        Teleportar(CFrame.new(-300, 15, -200))
    end    
})

TabTeleportes:AddButton({
    Name = "Teleportar para a Favela",
    Callback = function()
        Teleportar(CFrame.new(400, 30, -500))
    end    
})

-- ABA 2: Voo (Fly)
local TabFly = Window:MakeTab({
    Name = "Voo (Fly)",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TabFly:AddButton({
    Name = "Ativar Fly Mobile",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/x2125/Mobile-Fly-GUI/main/MobileFly.lua"))()
    end    
})

-- ABA 3: Modificadores do Personagem
local TabPlayer = Window:MakeTab({
    Name = "Personagem",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TabPlayer:AddSlider({
    Name = "Velocidade (WalkSpeed)",
    Min = 16,
    Max = 200,
    Default = 16,
    Color = Color3.fromRGB(0, 255, 150),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end    
})

TabPlayer:AddSlider({
    Name = "Altura do Pulo (JumpPower)",
    Min = 50,
    Max = 300,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 150),
    Increment = 5,
    ValueName = "Jump",
    Callback = function(Value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end    
})

TabPlayer:AddToggle({
    Name = "Pulo Infinito",
    Default = false,
    Callback = function(Value)
        _G.InfJump = Value
        game:GetService("UserInputService").JumpRequest:Connect(function()
            if _G.InfJump and game.Players.LocalPlayer.Character then
                game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
            end
        end)
    end    
})

-- ABA 4: Geral
local TabGeral = Window:MakeTab({
    Name = "Geral",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TabGeral:AddButton({
    Name = "Resetar Velocidade e Pulo",
    Callback = function()
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
        end
    end    
})

TabGeral:AddButton({
    Name = "Reentrar no Servidor",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end    
})

OrionLib:Init()
