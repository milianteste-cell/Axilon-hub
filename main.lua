--[[
    ============================================================
    🎯 AIM TRAINER — Sistema de Treinamento de Mira
    ============================================================
    - Interface moderna com animações suaves
    - Círculo de mira configurável e centralizado
    - Detecção de alvos do ambiente de treinamento
    - Câmera com transição suave (sem movimentos bruscos)
    - Uso exclusivo em ambiente de treinamento/protótipo autorizado
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
-- 📁 MÓDULO: CONFIG
-- Centraliza estados e configurações do sistema
--=============================================================
local Config = {
    -- Estado geral
    AimbotEnabled = false,
    CircleSize    = 150,     -- Diâmetro em pixels
    Smoothing     = 0.15,    -- 0 = instantâneo, 0.99 = muito suave
    MaxDistance   = 500,     -- Distância máxima (studs)
    TeamCheck     = true,
    VisibleCheck  = true,

    -- Cores
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

    -- Alvos válidos do ambiente de treinamento
    ValidTargetNames = {
        "TrainingDummy",
        "Target",
        "Dummy",
        "Bot",
    },
}

--=============================================================
-- 📁 MÓDULO: HELPERS
-- Funções utilitárias de criação de UI
--=============================================================
local function create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    return inst
end

local function corner(radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius or 10) })
end

local function stroke(color, thickness, transparency)
    return create("UIStroke", {
        Color = color or Config.Colors.PanelStroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0.2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

--=============================================================
-- 📁 MÓDULO: UI
-- Interface moderna com animações e feedback visual
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

    -- ---------- Painel Principal ----------
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

    -- ---------- Header ----------
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

    -- ---------- Botão Aimbot (Toggle) ----------
    local toggleBtn = create("TextButton", {
        Name = "AimbotToggle",
        Size = UDim2.new(1, -32, 0, 46),
        Position = UDim2.new(0, 16, 0, 60),
        BackgroundColor3 = Color3.fromRGB(30, 33, 42),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, {
        corner(10),
        stroke(Config.Colors.PanelStroke, 1, 0.4),
    })
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

    -- ---------- Input: Tamanho do Círculo ----------
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
    }, {
        corner(8),
        stroke(Config.Colors.PanelStroke, 1, 0.5),
    })
    sizeBox.Parent = panel

    local sizeInput = create("TextBox", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = tostring(Config.CircleSize),
        PlaceholderText = "Ex: 150",
        TextSize = 14,
        TextColor3 = Config.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })
    sizeInput.Parent = sizeBox

    UI.Refs.SizeInput = sizeInput
    UI.Refs.SizeBox   = sizeBox

    -- ---------- Input: Suavidade ----------
    create("TextLabel", {
        Size = UDim2.new(1, -32, 0, 20),
        Position = UDim2.new(0, 16, 0, 198),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "Suavidade da câmera (0-0.99)",
        TextSize = 12,
        TextColor3 = Config.Colors.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
    }).Parent = panel

    local smoothBox = create("Frame", {
        Size = UDim2.new(1, -32, 0, 40),
        Position = UDim2.new(0, 16, 0, 222),
        BackgroundColor3 = Color3.fromRGB(28, 31, 40),
        BorderSizePixel = 0,
    }, {
        corner(8),
        stroke(Config.Colors.PanelStroke, 1, 0.5),
    })
    smoothBox.Parent = panel

    local smoothInput = create("TextBox", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = tostring(Config.Smoothing),
        PlaceholderText = "0.0 - 0.99",
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

-- ---------- Feedback visual ----------
local function flash(frame, color)
    local original = frame.BackgroundColor3
    local strokeInst = frame:FindFirstChildOfClass("UIStroke")
    if strokeInst then
        TweenService:Create(strokeInst, TweenInfo.new(0.15), {
            Color = color, Transparency = 0,
        }):Play()
    end
    TweenService:Create(frame, TweenInfo.new(0.15), {
        BackgroundColor3 = color:Lerp(original, 0.7),
    }):Play()
    task.delay(0.35, function()
        TweenService:Create(frame, TweenInfo.new(0.25), {
            BackgroundColor3 = original,
        }):Play()
        if strokeInst then
            TweenService:Create(strokeInst, TweenInfo.new(0.25), {
                Color = Config.Colors.PanelStroke,
            }):Play()
        end
    end)
end

function UI.FlashSize()    flash(UI.Refs.SizeBox, Config.Colors.Accent) end
function UI.FlashSmooth()  flash(UI.Refs.SmoothBox, Config.Colors.Accent) end
function UI.FlashError(f)  flash(f, Color3.fromRGB(255, 80, 80)) end

function UI.SetToggleState(enabled)
    local pillColor = enabled and Color3.fromRGB(20, 60, 35) or Color3.fromRGB(60, 20, 20)
    local textColor = enabled and Config.Colors.AccentOn or Color3.fromRGB(255, 120, 120)

    TweenService:Create(UI.Refs.StatusPill, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        BackgroundColor3 = pillColor,
    }):Play()
    TweenService:Create(UI.Refs.StatusText, TweenInfo.new(0.2), {
        TextColor3 = textColor,
    }):Play()
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
-- 📁 MÓDULO: AIM CIRCLE
-- Círculo de mira centralizado
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
        create("UIStroke", {
            Thickness = 1.5,
            Color = Config.Colors.Idle,
            Transparency = 0.2,
        }),
    })
    frame.Parent = parentGui

    AimCircle.Frame  = frame
    AimCircle.Stroke = frame:FindFirstChildOfClass("UIStroke")
end

function AimCircle.UpdateSize(sizePx)
    if not AimCircle.Frame then return end
    TweenService:Create(AimCircle.Frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, sizePx, 0, sizePx),
    }):Play()
end

function AimCircle.SetActive(active)
    if not AimCircle.Frame then return end
    AimCircle._active = active

    if active then
        AimCircle.Frame.Visible = true
        AimCircle.Frame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(AimCircle.Frame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, Config.CircleSize, 0, Config.CircleSize),
        }):Play()
        TweenService:Create(AimCircle.Stroke, TweenInfo.new(0.25), {
            Transparency = 0.2, Color = Config.Colors.Idle,
        }):Play()
    else
        TweenService:Create(AimCircle.Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0),
        }):Play()
        task.delay(0.25, function()
            if not AimCircle._active then
                AimCircle.Frame.Visible = false
            end
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
-- 📁 MÓDULO: TARGET DETECTOR
-- Encontra alvos válidos dentro do círculo
--=============================================================
local TargetDetector = {}

local function isValidTarget(model)
    if not model or not model:IsA("Model") then return false end
    if not model.PrimaryPart and not model:FindFirstChild("HumanoidRootPart") then return false end

    local matchName = false
    for _, name in ipairs(Config.ValidTargetNames) do
        if model.Name:lower():find(name:lower(), 1, true) then
            matchName = true
            break
        end
    end
    if not matchName then return false end

    if model == LocalPlayer.Character then return false end
    return true
end

function TargetDetector.getAimPoint(model)
    local head = model:FindFirstChild("Head")
    if head then return head.Position end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp.Position + Vector3.new(0, 1.5, 0) end
    if model.PrimaryPart then return model.PrimaryPart.Position end
    return nil
end

function TargetDetector.worldToScreen(pos)
    local projected, onScreen = Camera:WorldToViewportPoint(pos)
    if not onScreen then return nil end
    return Vector2.new(projected.X, projected.Y), projected.Z
end

function TargetDetector.findBestTarget(circleRadiusPx)
    local character = LocalPlayer.Character
    if not character then return nil end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local myPos  = root.Position
    local center = Camera.ViewportSize * 0.5
    local radius = circleRadiusPx * 0.5

    local best, bestDist, bestPoint = nil, math.huge, nil

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isValidTarget(obj) then
            local aimPoint = TargetDetector.getAimPoint(obj)
            if aimPoint then
                local distToPlayer = (aimPoint - myPos).Magnitude
                if distToPlayer <= Config.MaxDistance then

                    local visible = true
                    if Config.VisibleCheck then
                        local params = RaycastParams.new()
                        params.FilterType = Enum.RaycastFilterType.Exclude
                        params.FilterDescendantsInstances = { character, obj }
                        local result = Workspace:Raycast(
                            Camera.CFrame.Position,
                            (aimPoint - Camera.CFrame.Position),
                            params
                        )
                        visible = (result == nil)
                    end

                    if visible then
                        local screenPos, depth = TargetDetector.worldToScreen(aimPoint)
                        if screenPos and depth and depth > 0 then
                            local offset = (screenPos - center).Magnitude
                            if offset <= radius and offset < bestDist then
                                bestDist  = offset
                                best      = obj
                                bestPoint = aimPoint
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
-- 📁 MÓDULO: CAMERA CONTROLLER
-- Suaviza a rotação da câmera
--=============================================================
local CameraController = {
    _target = nil,
    _conn   = nil,
}

local function smoothLookAt(targetPos, dt)
    local camPos  = Camera.CFrame.Position
    local desired = CFrame.new(camPos, targetPos)
    local alpha   = 1 - math.clamp(Config.Smoothing, 0, 0.99)
    local step    = math.clamp(alpha * (dt * 60), 0, 1)

    local newCFrame = Camera.CFrame:Lerp(desired, step)
    Camera.CFrame  = CFrame.new(Camera.CFrame.Position, newCFrame.LookVector * 10 + Camera.CFrame.Position)
end

function CameraController.start()
    if CameraController._conn then return end

    CameraController._conn = RunService.RenderStepped:Connect(function(dt)
        if not Config.AimbotEnabled then return end

        local t = CameraController._target
        if t and t.Parent then
            local aimPoint = TargetDetector.getAimPoint(t)
            if aimPoint then
                smoothLookAt(aimPoint, dt)
            end
        end
    end)
end

function CameraController.setTarget(t)  CameraController._target = t end
function CameraController.clearTarget() CameraController._target = nil end

--=============================================================
-- 📁 MAIN — Inicialização
--=============================================================
local function init()
    -- 1) Monta UI
    local gui = UI.Build()
    UI.AnimateOpen()

    -- 2) Cria círculo
    AimCircle.Create(gui)

    -- 3) Inicia controller da câmera
    CameraController.start()

    -- 4) Validação de inputs com feedback
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
        if n and n >= 0 and n <= 0.99 then
            Config.Smoothing = n
            UI.FlashSmooth()
        else
            UI.FlashError(UI.Refs.SmoothBox)
            UI.Refs.SmoothInput.Text = tostring(Config.Smoothing)
        end
    end)

    -- 5) Toggle do Aimbot
    UI.Refs.ToggleBtn.MouseButton1Click:Connect(function()
        Config.AimbotEnabled = not Config.AimbotEnabled
        UI.SetToggleState(Config.AimbotEnabled)
        AimCircle.SetActive(Config.AimbotEnabled)

        if not Config.AimbotEnabled then
            CameraController.clearTarget()
            AimCircle.SetTargetState(false)
        end
    end)

    -- 6) Loop principal de detecção
    RunService.RenderStepped:Connect(function()
        if not Config.AimbotEnabled then return end

        local target = TargetDetector.findBestTarget(Config.CircleSize)
        if target then
            CameraController.setTarget(target)
            AimCircle.SetTargetState(true)
        else
            CameraController.clearTarget()
            AimCircle.SetTargetState(false)
        end
    end)

    -- 7) Hotkey: RightShift liga/desliga
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            Config.AimbotEnabled = not Config.AimbotEnabled
            UI.SetToggleState(Config.AimbotEnabled)
            AimCircle.SetActive(Config.AimbotEnabled)
            if not Config.AimbotEnabled then
                CameraController.clearTarget()
                AimCircle.SetTargetState(false)
            end
        end
    end)

    print("[AimTrainer] Sistema iniciado com sucesso.")
end

init()
