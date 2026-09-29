-- ================================================
-- AXILON HUB - Rodograu 2.0 (Mobile)
-- ================================================

-- Carrega a biblioteca de interface (Orion Library)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Cria a Janela Principal do Axilon Hub
local Window = OrionLib:MakeWindow({
    Name = "Axilon Hub | Rodograu", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "AxilonHubConfig",
    IntroText = "Bem-vindo ao Axilon Hub!"
})

-- ABA 1: Teleportes (Praia, Brasilândia, Favela)
local TabTeleportes = Window:MakeTab({
    Name = "Teleportes",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TabTeleportes:AddSection({
    Name = "Locais do Mapa"
})

-- Função auxiliar para teleportar o personagem
local function Teleportar(caminho)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = caminho
    end
end

-- Botão: Teleportar para a Praia
TabTeleportes:AddButton({
    Name = "Teleportar para a Praia",
    Callback = function()
        -- Procura o local da praia no jogo ou usa coordenadas aproximadas
        local praia = workspace:FindFirstChild("Praia") or workspace:FindFirstChild("Beach")
        if praia then
            Teleportar(praia:GetPivot())
        else
            -- Coordenada de fallback caso o mapa não use o nome direto
            Teleportar(CFrame.new(0, 15, 500))
        end
    end    
})

-- Botão: Teleportar para a Brasilândia
TabTeleportes:AddButton({
    Name = "Teleportar para a Brasilândia",
    Callback = function()
        local brasilandia = workspace:FindFirstChild("Brasilândia") or workspace:FindFirstChild("Brasilandia")
        if brasilandia then
            Teleportar(brasilandia:GetPivot())
        else
            Teleportar(CFrame.new(-300, 15, -200))
        end
    end    
})

-- Botão: Teleportar para a Favela
TabTeleportes:AddButton({
    Name = "Teleportar para a Favela",
    Callback = function()
        local favela = workspace:FindFirstChild("Favela")
        if favela then
            Teleportar(favela:GetPivot())
        else
            Teleportar(CFrame.new(400, 30, -500))
        end
    end    
})

-- ABA 2: Voo & Fly Menu
local TabFly = Window:MakeTab({
    Name = "Voo (Fly)",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TabFly:AddSection({
    Name = "Controle de Voo"
})

-- Script Universal de Fly para Celular
TabFly:AddButton({
    Name = "Ativar Menu de Fly (Mobile GUI)",
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

TabPlayer:AddSection({
    Name = "Atributos do Jogador"
})

-- Modificador de Velocidade
TabPlayer:AddSlider({
    Name = "Velocidade de Andar (Speed)",
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

-- Modificador de Pulo
TabPlayer:AddSlider({
    Name = "Altura do Pulo (Jump)",
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

-- Pulo Infinito Toggle
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

-- ABA 4: Configurações Gerais
local TabGeral = Window:MakeTab({
    Name = "Geral",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TabGeral:AddButton({
    Name = "Resetar Padrão",
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

-- Inicializa o Axilon Hub
OrionLib:Init()
