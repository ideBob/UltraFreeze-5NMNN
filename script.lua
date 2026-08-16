--[[
    Ultra Freeze / Lag Switch UI
    Advanced Full Version - Heavy setfflag Edition
    Modified by request
    
    Features:
    - Status: "5NMNN" (Purple)
    - Fully changeable Keybind in Settings
    - Click the Keybind button → press any key or mouse button
    - Lock UI only prevents dragging
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Cleanup old UI
for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui.Name == "UltraFreezeUI" then
        gui:Destroy()
    end
end

-- Config
local Config = {
    Scale = 1,
    RGBSpeed = 1.3,
    Position = UDim2.new(0.72, 0, 0.18, 0),
    SettingsPosition = UDim2.new(0.72, 0, 0.32, 0),
    FlagEnabled = true,
    Cooldown = 4,
    Locked = false,
    FreezeStrength = 1000,

    -- Keybind
    KeybindType = "Mouse",
    KeybindValue = Enum.UserInputType.MouseButton3, -- Default MMB
}

local OnCooldown = false
local RGBConnection = nil
local ListeningForKeybind = false
local KeybindConnection = nil

-- Purple theme color (replaces rainbow)
local Purple = Color3.fromRGB(170, 0, 255)

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraFreezeUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main Panel
local Panel = Instance.new("Frame")
Panel.Name = "MainPanel"
Panel.Size = UDim2.new(0, 290, 0, 115)
Panel.Position = Config.Position
Panel.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Parent = ScreenGui

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 12)
PanelCorner.Parent = Panel

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Thickness = 2.2
PanelStroke.Color = Purple
PanelStroke.Parent = Panel

local UIScale = Instance.new("UIScale")
UIScale.Scale = Config.Scale
UIScale.Parent = Panel

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -55, 0, 34)
Title.Position = UDim2.new(0, 14, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "FREEZE NOW"
Title.TextColor3 = Purple
Title.Font = Enum.Font.GothamBold
Title.TextSize = 21
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

-- Status (Purple - was Rainbow)
local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Size = UDim2.new(1, -20, 0, 22)
Status.Position = UDim2.new(0, 14, 0, 42)
Status.BackgroundTransparency = 1
Status.Text = "5NMNN"
Status.TextColor3 = Purple
Status.Font = Enum.Font.Code
Status.TextSize = 13
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Panel

-- Keybind Indicator (Main UI)
local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Name = "KeybindLabel"
KeybindLabel.Size = UDim2.new(1, -20, 0, 20)
KeybindLabel.Position = UDim2.new(0, 14, 0, 68)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.Text = "Keybind: MMB"
KeybindLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
KeybindLabel.Font = Enum.Font.Code
KeybindLabel.TextSize = 12
KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
KeybindLabel.Parent = Panel

-- Invisible click area
local ClickArea = Instance.new("TextButton")
ClickArea.Name = "ClickArea"
ClickArea.Size = UDim2.new(1, 0, 1, 0)
ClickArea.BackgroundTransparency = 1
ClickArea.Text = ""
ClickArea.ZIndex = 2
ClickArea.Parent = Panel

-- Gear Button
local Gear = Instance.new("TextButton")
Gear.Name = "Gear"
Gear.Size = UDim2.new(0, 34, 0, 34)
Gear.Position = UDim2.new(1, -42, 0, 8)
Gear.BackgroundColor3 = Color3.fromRGB(22, 25, 38)
Gear.Text = "⚙️"
Gear.TextSize = 17
Gear.Font = Enum.Font.GothamBold
Gear.ZIndex = 3
Gear.Parent = Panel

local GearCorner = Instance.new("UICorner")
GearCorner.CornerRadius = UDim.new(0, 8)
GearCorner.Parent = Gear

-- Settings Panel
local Settings = Instance.new("Frame")
Settings.Name = "Settings"
Settings.Size = UDim2.new(0, 230, 0, 295)
Settings.Position = Config.SettingsPosition
Settings.BackgroundColor3 = Color3.fromRGB(12, 14, 24)
Settings.Visible = false
Settings.Active = true
Settings.Parent = ScreenGui

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 12)
SettingsCorner.Parent = Settings

local SettingsStroke = Instance.new("UIStroke")
SettingsStroke.Thickness = 1.6
SettingsStroke.Color = Purple
SettingsStroke.Parent = Settings

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, -20, 0, 28)
SettingsTitle.Position = UDim2.new(0, 10, 0, 6)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "SETTINGS • setfflag"
SettingsTitle.TextColor3 = Purple
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.TextSize = 14
SettingsTitle.Parent = Settings

-- FFlag Toggle
local FFlagBtn = Instance.new("TextButton")
FFlagBtn.Name = "FFlagBtn"
FFlagBtn.Size = UDim2.new(1, -20, 0, 32)
FFlagBtn.Position = UDim2.new(0, 10, 0, 40)
FFlagBtn.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
FFlagBtn.Text = Config.FlagEnabled and "FFlag: ON" or "FFlag: OFF"
FFlagBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FFlagBtn.Font = Enum.Font.Gotham
FFlagBtn.TextSize = 14
FFlagBtn.Parent = Settings

local FFlagCorner = Instance.new("UICorner")
FFlagCorner.CornerRadius = UDim.new(0, 8)
FFlagCorner.Parent = FFlagBtn

-- Cooldown
local CooldownLabel = Instance.new("TextLabel")
CooldownLabel.Size = UDim2.new(1, -20, 0, 20)
CooldownLabel.Position = UDim2.new(0, 10, 0, 82)
CooldownLabel.BackgroundTransparency = 1
CooldownLabel.Text = "Cooldown: " .. Config.Cooldown .. "s"
CooldownLabel.TextColor3 = Color3.fromRGB(170, 220, 255)
CooldownLabel.Font = Enum.Font.Code
CooldownLabel.TextSize = 13
CooldownLabel.TextXAlignment = Enum.TextXAlignment.Left
CooldownLabel.Parent = Settings

local CooldownMinus = Instance.new("TextButton")
CooldownMinus.Size = UDim2.new(0, 42, 0, 26)
CooldownMinus.Position = UDim2.new(0, 10, 0, 105)
CooldownMinus.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
CooldownMinus.Text = "-"
CooldownMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
CooldownMinus.Font = Enum.Font.GothamBold
CooldownMinus.TextSize = 18
CooldownMinus.Parent = Settings

local CooldownPlus = Instance.new("TextButton")
CooldownPlus.Size = UDim2.new(0, 42, 0, 26)
CooldownPlus.Position = UDim2.new(0, 58, 0, 105)
CooldownPlus.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
CooldownPlus.Text = "+"
CooldownPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
CooldownPlus.Font = Enum.Font.GothamBold
CooldownPlus.TextSize = 18
CooldownPlus.Parent = Settings

local CooldownCorner1 = Instance.new("UICorner")
CooldownCorner1.CornerRadius = UDim.new(0, 6)
CooldownCorner1.Parent = CooldownMinus

local CooldownCorner2 = Instance.new("UICorner")
CooldownCorner2.CornerRadius = UDim.new(0, 6)
CooldownCorner2.Parent = CooldownPlus

-- Strength
local StrengthLabel = Instance.new("TextLabel")
StrengthLabel.Size = UDim2.new(1, -20, 0, 20)
StrengthLabel.Position = UDim2.new(0, 10, 0, 140)
StrengthLabel.BackgroundTransparency = 1
StrengthLabel.Text = "Freeze Strength: " .. Config.FreezeStrength
StrengthLabel.TextColor3 = Color3.fromRGB(170, 220, 255)
StrengthLabel.Font = Enum.Font.Code
StrengthLabel.TextSize = 13
StrengthLabel.TextXAlignment = Enum.TextXAlignment.Left
StrengthLabel.Parent = Settings

local StrengthMinus = Instance.new("TextButton")
StrengthMinus.Size = UDim2.new(0, 42, 0, 26)
StrengthMinus.Position = UDim2.new(0, 10, 0, 163)
StrengthMinus.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
StrengthMinus.Text = "-"
StrengthMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
StrengthMinus.Font = Enum.Font.GothamBold
StrengthMinus.TextSize = 18
StrengthMinus.Parent = Settings

local StrengthPlus = Instance.new("TextButton")
StrengthPlus.Size = UDim2.new(0, 42, 0, 26)
StrengthPlus.Position = UDim2.new(0, 58, 0, 163)
StrengthPlus.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
StrengthPlus.Text = "+"
StrengthPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
StrengthPlus.Font = Enum.Font.GothamBold
StrengthPlus.TextSize = 18
StrengthPlus.Parent = Settings

local StrengthCorner1 = Instance.new("UICorner")
StrengthCorner1.CornerRadius = UDim.new(0, 6)
StrengthCorner1.Parent = StrengthMinus

local StrengthCorner2 = Instance.new("UICorner")
StrengthCorner2.CornerRadius = UDim.new(0, 6)
StrengthCorner2.Parent = StrengthPlus

-- Scale
local ScaleLabel = Instance.new("TextLabel")
ScaleLabel.Size = UDim2.new(1, -20, 0, 20)
ScaleLabel.Position = UDim2.new(0, 10, 0, 198)
ScaleLabel.BackgroundTransparency = 1
ScaleLabel.Text = "Scale: " .. string.format("%.1f", Config.Scale)
ScaleLabel.TextColor3 = Color3.fromRGB(170, 220, 255)
ScaleLabel.Font = Enum.Font.Code
ScaleLabel.TextSize = 13
ScaleLabel.TextXAlignment = Enum.TextXAlignment.Left
ScaleLabel.Parent = Settings

local ScaleMinus = Instance.new("TextButton")
ScaleMinus.Size = UDim2.new(0, 42, 0, 26)
ScaleMinus.Position = UDim2.new(0, 120, 0, 198)
ScaleMinus.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
ScaleMinus.Text = "-"
ScaleMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
ScaleMinus.Font = Enum.Font.GothamBold
ScaleMinus.TextSize = 18
ScaleMinus.Parent = Settings

local ScalePlus = Instance.new("TextButton")
ScalePlus.Size = UDim2.new(0, 42, 0, 26)
ScalePlus.Position = UDim2.new(0, 168, 0, 198)
ScalePlus.BackgroundColor3 = Color3.fromRGB(28, 32, 48)
ScalePlus.Text = "+"
ScalePlus.TextColor3 = Color3.fromRGB(255, 255, 255)
ScalePlus.Font = Enum.Font.GothamBold
ScalePlus.TextSize = 18
ScalePlus.Parent = Settings

local ScaleCorner1 = Instance.new("UICorner")
ScaleCorner1.CornerRadius = UDim.new(0, 6)
ScaleCorner1.Parent = ScaleMinus

local ScaleCorner2 = Instance.new("UICorner")
ScaleCorner2.CornerRadius = UDim.new(0, 6)
ScaleCorner2.Parent = ScalePlus

-- Lock Button
local LockBtn = Instance.new("TextButton")
LockBtn.Size = UDim2.new(0, 90, 0, 26)
LockBtn.Position = UDim2.new(1, -100, 0, 163)
LockBtn.BackgroundColor3 = Color3.fromRGB(42, 22, 28)
LockBtn.Text = "LOCK UI"
LockBtn.TextColor3 = Color3.fromRGB(255, 170, 170)
LockBtn.Font = Enum.Font.Gotham
LockBtn.TextSize = 12
LockBtn.Parent = Settings

local LockCorner = Instance.new("UICorner")
LockCorner.CornerRadius = UDim.new(0, 6)
LockCorner.Parent = LockBtn

-- ====================== KEYBIND BUTTON (IN SETTINGS) ======================
local KeybindBtn = Instance.new("TextButton")
KeybindBtn.Name = "KeybindBtn"
KeybindBtn.Size = UDim2.new(1, -20, 0, 34)
KeybindBtn.Position = UDim2.new(0, 10, 0, 240)
KeybindBtn.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
KeybindBtn.Text = "Keybind: MMB"
KeybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KeybindBtn.Font = Enum.Font.Gotham
KeybindBtn.TextSize = 14
KeybindBtn.Parent = Settings

local KeybindBtnCorner = Instance.new("UICorner")
KeybindBtnCorner.CornerRadius = UDim.new(0, 8)
KeybindBtnCorner.Parent = KeybindBtn

-- ====================== HELPER ======================
local function GetKeybindName()
    if Config.KeybindType == "Mouse" then
        if Config.KeybindValue == Enum.UserInputType.MouseButton1 then
            return "LMB"
        elseif Config.KeybindValue == Enum.UserInputType.MouseButton2 then
            return "RMB"
        elseif Config.KeybindValue == Enum.UserInputType.MouseButton3 then
            return "MMB"
        else
            return "Mouse"
        end
    else
        return tostring(Config.KeybindValue):gsub("Enum.KeyCode.", "")
    end
end

local function UpdateKeybindDisplays()
    local name = GetKeybindName()
    KeybindLabel.Text = "Keybind: " .. name
    KeybindBtn.Text = "Keybind: " .. name
end

UpdateKeybindDisplays()

-- ====================== setfflag ======================
local function SafeSetFFlag(name, value)
    pcall(function()
        setfflag(name, tostring(value))
    end)
end

local function ApplyBaseFlag()
    if Config.FlagEnabled then
        SafeSetFFlag("MaxMissedWorldStepsRemembered", Config.FreezeStrength)
    else
        SafeSetFFlag("MaxMissedWorldStepsRemembered", 0)
    end
end

ApplyBaseFlag()

local function DoFreeze()
    SafeSetFFlag("MaxMissedWorldStepsRemembered", Config.FreezeStrength)
    SafeSetFFlag("WorldStepMax", 1)
    SafeSetFFlag("PhysicsSenderMaxBandwidthBps", 100)
    SafeSetFFlag("S2PhysicsSenderRate", 1)
    SafeSetFFlag("MaxDataPacketPerSend", 1)

    local start = os.clock()
    while os.clock() - start < 0.4 do
        SafeSetFFlag("MaxMissedWorldStepsRemembered", Config.FreezeStrength)
        for _ = 1, 180000 do end
    end

    task.wait(0.05)
    if Config.FlagEnabled then
        SafeSetFFlag("MaxMissedWorldStepsRemembered", Config.FreezeStrength)
    else
        SafeSetFFlag("MaxMissedWorldStepsRemembered", 0)
    end
end

-- ====================== PURPLE THEME (No Rainbow) ======================
-- Colors are set statically to Purple. No RGB loop needed.

-- ====================== DRAG ======================
local dragging = false
local dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    Panel.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

ClickArea.InputBegan:Connect(function(input)
    if Config.Locked then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateDrag(input)
    end
end)

local settingsDragging = false
local settingsDragStart, settingsStartPos

Settings.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        settingsDragging = true
        settingsDragStart = input.Position
        settingsStartPos = Settings.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                settingsDragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if settingsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - settingsDragStart
        Settings.Position = UDim2.new(
            settingsStartPos.X.Scale,
            settingsStartPos.X.Offset + delta.X,
            settingsStartPos.Y.Scale,
            settingsStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ====================== BUTTONS ======================
Gear.MouseButton1Click:Connect(function()
    Settings.Visible = not Settings.Visible
end)

FFlagBtn.MouseButton1Click:Connect(function()
    Config.FlagEnabled = not Config.FlagEnabled
    FFlagBtn.Text = Config.FlagEnabled and "FFlag: ON" or "FFlag: OFF"
    ApplyBaseFlag()
end)

CooldownMinus.MouseButton1Click:Connect(function()
    Config.Cooldown = math.max(1, Config.Cooldown - 1)
    CooldownLabel.Text = "Cooldown: " .. Config.Cooldown .. "s"
end)

CooldownPlus.MouseButton1Click:Connect(function()
    Config.Cooldown = math.min(12, Config.Cooldown + 1)
    CooldownLabel.Text = "Cooldown: " .. Config.Cooldown .. "s"
end)

StrengthMinus.MouseButton1Click:Connect(function()
    Config.FreezeStrength = math.max(200, Config.FreezeStrength - 200)
    StrengthLabel.Text = "Freeze Strength: " .. Config.FreezeStrength
    ApplyBaseFlag()
end)

StrengthPlus.MouseButton1Click:Connect(function()
    Config.FreezeStrength = math.min(3000, Config.FreezeStrength + 200)
    StrengthLabel.Text = "Freeze Strength: " .. Config.FreezeStrength
    ApplyBaseFlag()
end)

ScaleMinus.MouseButton1Click:Connect(function()
    Config.Scale = math.max(0.6, Config.Scale - 0.1)
    UIScale.Scale = Config.Scale
    ScaleLabel.Text = "Scale: " .. string.format("%.1f", Config.Scale)
end)

ScalePlus.MouseButton1Click:Connect(function()
    Config.Scale = math.min(1.8, Config.Scale + 0.1)
    UIScale.Scale = Config.Scale
    ScaleLabel.Text = "Scale: " .. string.format("%.1f", Config.Scale)
end)

LockBtn.MouseButton1Click:Connect(function()
    Config.Locked = not Config.Locked
    if Config.Locked then
        LockBtn.Text = "UNLOCK"
        LockBtn.BackgroundColor3 = Color3.fromRGB(22, 40, 28)
        LockBtn.TextColor3 = Color3.fromRGB(160, 255, 180)
    else
        LockBtn.Text = "LOCK UI"
        LockBtn.BackgroundColor3 = Color3.fromRGB(42, 22, 28)
        LockBtn.TextColor3 = Color3.fromRGB(255, 170, 170)
    end
end)

-- ====================== KEYBIND CHANGER (SETTINGS) ======================
KeybindBtn.MouseButton1Click:Connect(function()
    if ListeningForKeybind then return end

    ListeningForKeybind = true
    KeybindBtn.Text = "Press any key / mouse..."
    KeybindBtn.BackgroundColor3 = Color3.fromRGB(45, 30, 20)

    if KeybindConnection then
        KeybindConnection:Disconnect()
    end

    KeybindConnection = UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not ListeningForKeybind then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.MouseButton2
        or input.UserInputType == Enum.UserInputType.MouseButton3 then
            Config.KeybindType = "Mouse"
            Config.KeybindValue = input.UserInputType
        elseif input.UserInputType == Enum.UserInputType.Keyboard then
            Config.KeybindType = "Key"
            Config.KeybindValue = input.KeyCode
        else
            return
        end

        ListeningForKeybind = false
        KeybindBtn.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
        UpdateKeybindDisplays()

        if KeybindConnection then
            KeybindConnection:Disconnect()
            KeybindConnection = nil
        end
    end)
end)

-- ====================== FREEZE ======================
local function TriggerFreeze()
    if OnCooldown then
        Status.Text = "On Cooldown..."
        return
    end

    OnCooldown = true
    Status.Text = "FREEZING WITH setfflag..."
    Status.TextColor3 = Color3.fromRGB(255, 70, 70)

    DoFreeze()

    for i = Config.Cooldown, 1, -1 do
        Status.Text = "Cooldown: " .. i .. "s"
        Status.TextColor3 = Color3.fromRGB(255, 190, 60)
        task.wait(1)
    end

    Status.Text = "5NMNN"
    Status.TextColor3 = Purple
    OnCooldown = false
end

ClickArea.MouseButton1Click:Connect(TriggerFreeze)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if ListeningForKeybind then return end

    if Config.KeybindType == "Mouse" then
        if input.UserInputType == Config.KeybindValue then
            TriggerFreeze()
        end
    elseif Config.KeybindType == "Key" then
        if input.KeyCode == Config.KeybindValue then
            TriggerFreeze()
        end
    end
end)

print("[Ultra Freeze] Loaded | Changeable Keybind in Settings | 5NMNN")
