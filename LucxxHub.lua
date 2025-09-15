-- // Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- // Window
local Window = Rayfield:CreateWindow({
    Name = "Lucxx Hub",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by Lucxxy",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "LucxxHub",
        FileName = "Config"
    },
    KeySystem = false
})

-- // Tabs
local PlayerTab = Window:CreateTab("Player", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local MiscTab = Window:CreateTab("Miscellaneous", 4483362458)

-- ======================================================
-- PLAYER SETTINGS
-- ======================================================
PlayerTab:CreateButton({
    Name = "Fly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end,
})

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16,300},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Value end
    end,
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50,200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(Value)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = Value end
    end,
})

PlayerTab:CreateSlider({
    Name = "Gravity",
    Range = {0,500},
    Increment = 1,
    CurrentValue = workspace.Gravity,
    Callback = function(Value)
        workspace.Gravity = Value
    end,
})

PlayerTab:CreateSlider({
    Name = "Max Camera Zoom",
    Range = {0,1000},
    Increment = 10,
    CurrentValue = 128,
    Callback = function(Value)
        game.Players.LocalPlayer.CameraMaxZoomDistance = Value
    end,
})

-- ======================================================
-- COMBAT SETTINGS
-- ======================================================
local TeamCheck = false
local AimLockEnabled = false
local WallCheck = false
local FOVRadius = 100

local camera = workspace.CurrentCamera

-- POV circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = FOVRadius
FOVCircle.NumSides = 64
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(0,255,0)
FOVCircle.Visible = false

CombatTab:CreateSlider({
    Name = "FOV Circle Radius",
    Range = {100,300},
    Increment = 1,
    CurrentValue = 100,
    Callback = function(Value)
        FOVRadius = Value
        FOVCircle.Radius = Value
    end,
})

CombatTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Callback = function(Value)
        TeamCheck = Value
    end
})

CombatTab:CreateToggle({
    Name = "Aim Lock",
    CurrentValue = false,
    Callback = function(Value)
        AimLockEnabled = Value
        FOVCircle.Visible = Value
    end
})

CombatTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Callback = function(Value)
        WallCheck = Value
    end
})

-- ======================================================
-- VISUAL SETTINGS
-- ======================================================
local HighlightESPEnabled = false
local ESPEnabled = false
local HealthESPEnabled = false
local LineESPEnabled = false
local DrawingESP = {}

VisualTab:CreateToggle({
    Name = "Player Highlight",
    CurrentValue = false,
    Callback = function(Value)
        HighlightESPEnabled = Value
    end,
})

VisualTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = false,
    Callback = function(Value) ESPEnabled = Value end,
})

VisualTab:CreateToggle({
    Name = "Healthbar ESP",
    CurrentValue = false,
    Callback = function(Value) HealthESPEnabled = Value end,
})

VisualTab:CreateToggle({
    Name = "Line ESP",
    CurrentValue = false,
    Callback = function(Value) LineESPEnabled = Value end,
})

-- ======================================================
-- MISCELLANEOUS SETTINGS
-- ======================================================
local noclipEnabled = false
local antiAFKEnabled = false
local noFallEnabled = false
local freeCamEnabled = false
local instantCollectEnabled = false
local autoCollectEnabled = false
local tracerEnabled = false
local wallbangEnabled = false
local Spectating = nil

-- Movement
MiscTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(Value) noclipEnabled = Value end
})

MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Callback = function(Value)
        antiAFKEnabled = Value
        if Value then
            local plr = game.Players.LocalPlayer
            local vu = game:GetService("VirtualUser")
            plr.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            end)
        end
    end
})

MiscTab:CreateToggle({
    Name = "No Fall Damage",
    CurrentValue = false,
    Callback = function(Value) noFallEnabled = Value end
})

-- FreeCam FIXED
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local freeCamConn
local freeCamSpeed = 2

MiscTab:CreateToggle({
    Name = "FreeCam",
    CurrentValue = false,
    Callback = function(Value)
        freeCamEnabled = Value
        local cam = workspace.CurrentCamera

        if Value then
            cam.CameraType = Enum.CameraType.Scriptable
            local pos = cam.CFrame

            freeCamConn = RunService.RenderStepped:Connect(function(dt)
                local move = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += cam.CFrame.UpVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= cam.CFrame.UpVector end

                pos = pos + move * freeCamSpeed
                cam.CFrame = pos
            end)

        else
            if freeCamConn then freeCamConn:Disconnect() end
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    end
})

-- Spectate
local PlayerListDropdown = MiscTab:CreateDropdown({
    Name = "Spectate Player",
    Options = {},
    CurrentOption = nil,
    MultiSelect = false,
    Callback = function(option)
        local target = game.Players:FindFirstChild(option)
        if target and target.Character then
            Spectating = target
            workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
        end
    end
})

MiscTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        local names = {}
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer then
                table.insert(names, plr.Name)
            end
        end
        PlayerListDropdown:SetOptions(names) -- FIXED
    end
})

MiscTab:CreateButton({
    Name = "Stop Spectating",
    Callback = function()
        Spectating = nil
        local lp = game.Players.LocalPlayer
        if lp.Character then
            workspace.CurrentCamera.CameraSubject = lp.Character:FindFirstChildOfClass("Humanoid")
        end
    end
})

-- Misc
MiscTab:CreateToggle({Name = "Instant Collect", CurrentValue = false, Callback = function(Value) instantCollectEnabled = Value end})
MiscTab:CreateToggle({Name = "Auto Collect", CurrentValue = false, Callback = function(Value) autoCollectEnabled = Value end})
MiscTab:CreateToggle({Name = "Tracer", CurrentValue = false, Callback = function(Value) tracerEnabled = Value end})
MiscTab:CreateToggle({Name = "Wallbang", CurrentValue = false, Callback = function(Value) wallbangEnabled = Value end})

-- ======================================================
-- (loop combat + visual + misc tetap sama seperti versi sebelumnya)
-- ======================================================
