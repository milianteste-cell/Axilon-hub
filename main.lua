--[[
    ============================================================
    🎯 AIM TRAINER — Versão Corrigida
    ============================================================
    - Trava real na cabeça do jogador
    - Círculo configurável
    - Suavidade ajustável
    - Interface moderna
    - Somente ambiente de treinamento autorizado
    ============================================================
]]

--=============================================================
-- SERVIÇOS
--=============================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

--=============================================================
-- CONFIG
--=============================================================
local Config = {
    AimbotEnabled = false,
    CircleSize    = 150,
    Smoothing     = 0.25,    -- quanto MAIOR, mais lento/suave (0.05 a 0.6 é bom)
    MaxDistance   = 1000,
    TeamCheck     = true,
    VisibleCheck  = false,   -- true = só mira se estiver visível (pode reduzir performance)

    Colors = {
        Idle        = Color3.fromRGB(180, 180, 180),
        TargetLock  = Color3.fromRGB(0, 255, 140),
        PanelBg     = Color3.fromRGB(20, 22, 28),
        PanelStroke = Color3.fromRGB(60, 65, 80),
        Accent      = Color3.fromRGB(0, 170, 255),
        AccentOn    = Color3.fromRGB(0, 255, 140),
        Text        = Color3.fromRGB(235, 235, 240),
        TextDim     = Color3.fromRGB(150, 155, 170),
    },
}

--=============================================================
-- HELPERS
--=============================================================
local function create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    return inst
end

local function corner(r) return create("UICorner", { CornerRadius = UDim.new(0, r or 10) }) end

local function stroke(color, thickness, transparency)
    return create("UIStroke", {
        Color = color or Config.Colors.PanelStroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0.2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

--=============================================================
-- UI
--=============================================================
local UI = { Refs = {} }

function UI.Build()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    local gui = create("ScreenGui", {
        Name = "AimTrainerUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    gui.Parent = playerGui
    UI.Refs.Gui = gui

    local panel = create("Frame", {
        Name = "MainPanel",
        Size = UDim2.new(0, 320, 0, 280),
        Position = UDim2.new(0, 24, 0, 24),
        BackgroundColor3 = Config.Colors.PanelBg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
    }, {
        corner(14),
        stroke(Config.Colors.PanelStroke, 1, 0.3),
        create("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 30, 38)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 20, 26)),
            }),
        }),
    })
    panel.Parent = gui
    UI.Refs.Panel = panel

    local header = create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
    })
    header.Parent = panel

    create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "AIM TRAINER",
        TextSize = 16,
        TextColor3 = Config.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }).Parent = header

    create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -22, 0, 16),
        BackgroundColor3 = Config.Colors.Accent,
        BorderSizePixel = 0,
    }, { corner(6) }).Parent = header

    create("Frame", {
        Size = UDim2.new(1, -24, 0, 1),
        Position = UDim2.new(0, 12, 0, 44),
        BackgroundColor3 = Config.Colors.PanelStroke,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
    }).Parent = panel

    -- Botão Toggle
    local toggleBtn = create("TextButton", {
        Size = UDim2.new(1, -32, 0, 46),
        Position = UDim2.new(0, 16, 0, 60),
        BackgroundColor3 = Color3.fromRGB(30, 33, 42),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, { corner(10), stroke(Config.Colors.PanelStroke, 1, 0.4) })
    toggleBtn.Parent = panel

    create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = "Aimbot",
        TextSize = 15,
        TextColor3 = Config.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }).Parent = toggleBtn

    local statusPill = create("Frame", {
        Size = UDim2.new(0, 60, 0, 26),
        Position = UDim2.new(1, -72, 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(60, 20, 20),
        BorderSizePixel = 0,
    }, { corner(13) })
    statusPill.Parent = toggleBtn

    local statusText = create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "OFF",
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 120, 120),
    })
    statusText.Parent = statusPill

    UI.Refs.ToggleBtn  = toggleBtn
    UI.Refs.StatusPill = statusPill
    UI.Refs.StatusText = statusText

    -- Input: Tamanho
    create("TextLabel", {
        Size = UDim2.new(1, -32, 0, 20),
        Position = UDim2.new(0, 16, 0, 122),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "Tamanho do círculo (px)",
        TextSize = 12,
        TextColor3 = Config.Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
    }).Parent = panel

    local sizeBox = create("Frame", {
        Size = UDim2.new(1, -32, 0, 40),
        Position = UDim2.new(0, 16, 0, 146),
        BackgroundColor3 = Color3.fromRGB(28, 31, 40),
        BorderSizePixel = 0,
    }, { corner(8), stroke(Config.Colors.PanelStroke, 1, 0.5) })
    sizeBox.Parent = panel

    local sizeInput = create("TextBox", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = tostring(Config.CircleSize),
        TextSize = 14,
        TextColor3 = Config.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })
    sizeInput.Parent = sizeBox
    UI.Refs.SizeInput = sizeInput
    UI.Refs.SizeBox   = sizeBox

    -- Input: Suavidade
    create("TextLabel", {
        Size = UDim2.new(1, -32, 0, 20),
        Position = UDim2.new(0, 16, 0, 198),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "Suavidade (0.05 = rápido / 0.6 = suave)",
        TextSize = 12,
        TextColor3 = Config.Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
    }).Parent = panel

    local smoothBox = create("Frame", {
        Size = UDim2.new(1, -32, 0, 40),
        Position = UDim2.new(0, 16, 0, 222),
        BackgroundColor3 = Color3.fromRGB(28, 31, 40),
        BorderSizePixel = 0,
    }, { corner(8), stroke(Config.Colors.PanelStroke, 1, 0.5) })
    smoothBox.Parent = panel

    local smoothInput = create("TextBox", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = tostring(Config.Smoothing),
        TextSize = 14,
        TextColor3 = Config.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })
    smoothInput.Parent = smoothBox
    UI.Refs.SmoothInput = smoothInput
    UI.Refs.SmoothBox   = smoothBox

    return gui
end

local function flash(frame, color)
    local original = frame.BackgroundColor3
    local strokeInst = frame:FindFirstChildOfClass("UIStroke")
    if strokeInst then
        TweenService:Create(strokeInst, TweenInfo.new(0.15), { Color = color, Transparency = 0 }):Play()
    end
    TweenService:Create(frame, TweenInfo.new(0.15), { BackgroundColor3 = color:Lerp(original, 0.7) }):Play()
    task.delay(0.35, function()
        TweenService:Create(frame, TweenInfo.new(0.25), { BackgroundColor3 = original }):Play()
        if strokeInst then
            TweenService:Create(strokeInst, TweenInfo.new(0.25), { Color = Config.Colors.PanelStroke }):Play()
        end
    end)
end

function UI.FlashSize()    flash(UI.Refs.SizeBox, Config.Colors.Accent) end
function UI.FlashSmooth()  flash(UI.Refs.SmoothBox, Config.Colors.Accent) end
function UI.FlashError(f)  flash(f, Color3.fromRGB(255, 80, 80)) end

function UI.SetToggleState(enabled)
    local pillColor = enabled and Color3.fromRGB(20, 60, 35) or Color3.fromRGB(60, 20, 20)
    local textColor = enabled and Config.Colors.AccentOn or Color3.fromRGB(255, 120, 120)
    TweenService:Create(UI.Refs.StatusPill, TweenInfo.new(0.25), { BackgroundColor3 = pillColor }):Play()
    TweenService:Create(UI.Refs.StatusText, TweenInfo.new(0.2), { TextColor3 = textColor }):Play()
    UI.Refs.StatusText.Text = enabled and "ON" or "OFF"
    local strokeInst = UI.Refs.ToggleBtn:FindFirstChildOfClass("UIStroke")
    if strokeInst then
        TweenService:Create(strokeInst, TweenInfo.new(0.25), {
            Color = enabled and Config.Colors.AccentOn or Config.Colors.PanelStroke,
            Transparency = enabled and 0.1 or 0.4,
        }):Play()
    end
end

function UI.AnimateOpen()
    local p = UI.Refs.Panel
    p.Size = UDim2.new(0, 320, 0, 0)
    p.BackgroundTransparency = 1
    TweenService:Create(p, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 320, 0, 280),
        BackgroundTransparency = 0.05,
    }):Play()
end

--=============================================================
-- AIM CIRCLE
--=============================================================
local AimCircle = { Frame = nil, Stroke = nil, _active = false }

function AimCircle.Create(parentGui)
    local frame = create("Frame", {
        Name = "AimCircle",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, Config.CircleSize, 0, Config.CircleSize),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 5,
    }, {
        create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        create("UIStroke", { Thickness = 1.5, Color = Config.Colors.Idle, Transparency = 0.2 }),
    })
    frame.Parent = parentGui
    AimCircle.Frame  = frame
    AimCircle.Stroke = frame:FindFirstChildOfClass("UIStroke")
end

function AimCircle.UpdateSize(sizePx)
    if not AimCircle.Frame then return end
    TweenService:Create(AimCircle.Frame, TweenInfo.new(0.2), {
        Size = UDim2.new(0, sizePx, 0, sizePx),
    }):Play()
end

function AimCircle.SetActive(active)
    if not AimCircle.Frame then return end
    AimCircle._active = active
    if active then
        AimCircle.Frame.Visible = true
        AimCircle.Frame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(AimCircle.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, Config.CircleSize, 0, Config.CircleSize),
        }):Play()
        TweenService:Create(AimCircle.Stroke, TweenInfo.new(0.25), {
            Transparency = 0.2, Color = Config.Colors.Idle,
        }):Play()
    else
        TweenService:Create(AimCircle.Frame, TweenInfo.new(0.25), {
            Size = UDim2.new(0, 0, 0, 0),
        }):Play()
        task.delay(0.25, function()
            if not AimCircle._active then AimCircle.Frame.Visible = false end
        end)
    end
end

function AimCircle.SetTargetState(hasTarget)
    if not AimCircle.Frame or not AimCircle.Frame.Visible then return end
    TweenService:Create(AimCircle.Stroke, TweenInfo.new(0.15), {
        Color = hasTarget and Config.Colors.TargetLock or Config.Colors.Idle,
        Transparency = hasTarget and 0 or 0.2,
        Thickness = hasTarget and 2.2 or 1.5,
    }):Play()
end

--=============================================================
-- TARGET DETECTOR (agora mirando JOGADORES reais)
--=============================================================
local TargetDetector = {}

-- Retorna a "parte cabeça" do jogador, se existir
local function getHeadOf(player)
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

-- Verifica se é um alvo válido (jogador, com time diferente se TeamCheck)
local function isValidPlayer(player)
    if player == LocalPlayer then return false end
    if not player.Character then return false end

    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end

    if Config.TeamCheck and player.Team and LocalPlayer.Team then
        if player.Team == LocalPlayer.Team then return false end
    end

    -- Checa se há um modelo nomeado do treino (opcional)
    -- Se quiser restringir SOMENTE a dummies específicas, descomente:
    -- if not player.Character.Name:lower():find("dummy") then return false end

    return true
end

-- Projeta posição 3D para 2D
local function worldToScreen(pos)
    local projected, onScreen = Camera:WorldToViewportPoint(pos)
    if not onScreen then return nil end
    return Vector2.new(projected.X, projected.Y), projected.Z
end

-- Encontra o melhor alvo dentro do círculo
function TargetDetector.findBestTarget(circleDiameterPx)
    local center = Camera.ViewportSize * 0.5
    local radius = circleDiameterPx * 0.5

    local best, bestDist, bestPoint = nil, math.huge, nil

    for _, player in ipairs(Players:GetPlayers()) do
        if isValidPlayer(player) then
            local head = getHeadOf(player)
            if head then
                local aimPoint = head.Position

                -- Distância do jogador local até o alvo
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local distToPlayer = (aimPoint - myRoot.Position).Magnitude
                    if distToPlayer <= Config.MaxDistance then

                        -- Checa visibilidade (opcional)
                        local visible = true
                        if Config.VisibleCheck then
                            local params = RaycastParams.new()
                            params.FilterType = Enum.RaycastFilterType.Exclude
                            params.FilterDescendantsInstances = { myChar, player.Character }
                            local result = Workspace:Raycast(Camera.CFrame.Position, (aimPoint - Camera.CFrame.Position), params)
                            visible = (result == nil)
                        end

                        if visible then
                            local screenPos, depth = worldToScreen(aimPoint)
                            if screenPos and depth and depth > 0 then
                                local offset = (screenPos - center).Magnitude
                                if offset <= radius and offset < bestDist then
                                    bestDist  = offset
                                    best      = head
                                    bestPoint = aimPoint
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return best, bestPoint
end

--=============================================================
-- CAMERA CONTROLLER (versão corrigida — gruda na cabeça)
--=============================================================
local CameraController = {
    _targetPart = nil,
    _conn       = nil,
}

-- Aplica rotação suave usando lookAt com lerp de direção
local function smoothLockTo(targetPos, dt)
    local camPos = Camera.CFrame.Position

    -- Direção atual e desejada
    local currentDir = Camera.CFrame.LookVector
    local desiredDir = (targetPos - camPos).Unit

    -- Interpolação exponencial (frame-rate independent)
    local t = 1 - math.exp(-dt / math.max(Config.Smoothing, 0.001))

    local newDir = currentDir:Lerp(desiredDir, t).Unit
    Camera.CFrame = CFrame.lookAt(camPos, camPos + newDir)
end

function CameraController.start()
    if CameraController._conn then return end

    CameraController._conn = RunService.RenderStepped:Connect(function(dt)
        -- Aplica somenta quando habilitado e houver alvo
        local target = CameraController._targetPart
        if Config.AimbotEnabled and target and target.Parent then
            smoothLockTo(target.Position, dt)
        end
    end)
end

function CameraController.setTarget(part)  CameraController._targetPart = part end
function CameraController.clearTarget()    CameraController._targetPart = nil end

--=============================================================
-- MAIN
--=============================================================
local function init()
    local gui = UI.Build()
    UI.AnimateOpen()
    AimCircle.Create(gui)
    CameraController.start()

    -- Inputs
    UI.Refs.SizeInput.FocusLost:Connect(function()
        local n = tonumber(UI.Refs.SizeInput.Text)
        if n and n >= 20 and n <= 800 then
            Config.CircleSize = n
            AimCircle.UpdateSize(n)
            UI.FlashSize()
        else
            UI.FlashError(UI.Refs.SizeBox)
            UI.Refs.SizeInput.Text = tostring(Config.CircleSize)
        end
    end)

    UI.Refs.SmoothInput.FocusLost:Connect(function()
        local n = tonumber(UI.Refs.SmoothInput.Text)
        if n and n >= 0.01 and n <= 1 then
            Config.Smoothing = n
            UI.FlashSmooth()
        else
            UI.FlashError(UI.Refs.SmoothBox)
            UI.Refs.SmoothInput.Text = tostring(Config.Smoothing)
        end
    end)

    -- Toggle
    local function toggleAimbot()
        Config.AimbotEnabled = not Config.AimbotEnabled
        UI.SetToggleState(Config.AimbotEnabled)
        AimCircle.SetActive(Config.AimbotEnabled)
        if not Config.AimbotEnabled then
            CameraController.clearTarget()
            AimCircle.SetTargetState(false)
        end
    end

    UI.Refs.ToggleBtn.MouseButton1Click:Connect(toggleAimbot)

    -- Hotkey RightShift
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            toggleAimbot()
        end
    end)

    -- Loop principal de detecção (roda todo frame)
    RunService.RenderStepped:Connect(function()
        if not Config.AimbotEnabled then return end

        local targetPart = TargetDetector.findBestTarget(Config.CircleSize)
        if targetPart then
            CameraController.setTarget(targetPart)
            AimCircle.SetTargetState(true)
        else
            CameraController.clearTarget()
            AimCircle.SetTargetState(false)
        end
    end)

    print("[AimTrainer] Sistema iniciado com sucesso.")
end

init()
