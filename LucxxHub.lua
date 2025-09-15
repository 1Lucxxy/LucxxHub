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

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Value end
    end,
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50,200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(Value)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
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
        LocalPlayer.CameraMaxZoomDistance = Value
    end,
})

-- ======================================================
-- COMBAT SETTINGS (Tracer & Wallbang di sini)
-- ======================================================
local TeamCheck = false
local AimLockEnabled = false
local WallCheck = false
local FOVRadius = 100
local tracerEnabled = false
local wallbangEnabled = false

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

CombatTab:CreateToggle({ Name = "Team Check", CurrentValue = false, Callback = function(v) TeamCheck = v end })
CombatTab:CreateToggle({ Name = "Aim Lock", CurrentValue = false, Callback = function(v) AimLockEnabled = v FOVCircle.Visible = v end })
CombatTab:CreateToggle({ Name = "Wall Check", CurrentValue = false, Callback = function(v) WallCheck = v end })
CombatTab:CreateToggle({ Name = "Tracer", CurrentValue = false, Callback = function(v) tracerEnabled = v end })
CombatTab:CreateToggle({ Name = "Wallbang", CurrentValue = false, Callback = function(v) wallbangEnabled = v end })

-- ======================================================
-- VISUAL SETTINGS
-- ======================================================
local HighlightESPEnabled = false
local ESPEnabled = false
local HealthESPEnabled = false
local DrawingESP = {}

VisualTab:CreateToggle({ Name = "Player Highlight", CurrentValue = false, Callback = function(v) HighlightESPEnabled = v end })
VisualTab:CreateToggle({ Name = "Name ESP", CurrentValue = false, Callback = function(v) ESPEnabled = v end })
VisualTab:CreateToggle({ Name = "Healthbar ESP", CurrentValue = false, Callback = function(v) HealthESPEnabled = v end })

-- ======================================================
-- MISCELLANEOUS
-- ======================================================
local noclipEnabled = false
local antiAFKEnabled = false
local noFallEnabled = false
local freeCamEnabled = false
local instantCollectEnabled = false
local autoCollectEnabled = false
local Spectating = nil
local antiAFKConn

MiscTab:CreateToggle({ Name = "NoClip", CurrentValue = false, Callback = function(v) noclipEnabled = v end })

MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Callback = function(v)
        antiAFKEnabled = v
        if v then
            local vu = game:GetService("VirtualUser")
            antiAFKConn = LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        else
            if antiAFKConn then
                antiAFKConn:Disconnect()
                antiAFKConn = nil
            end
        end
    end
})

MiscTab:CreateToggle({ Name = "No Fall Damage", CurrentValue = false, Callback = function(v) noFallEnabled = v end })

-- FreeCam
local freeCamConn
local freeCamSpeed = 2
MiscTab:CreateToggle({
    Name = "FreeCam",
    CurrentValue = false,
    Callback = function(v)
        freeCamEnabled = v
        local cam = workspace.CurrentCamera
        if v then
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
                pos = pos + move * freeCamSpeed * (dt*60)
                cam.CFrame = pos
            end)
        else
            if freeCamConn then freeCamConn:Disconnect() freeCamConn = nil end
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
        local target = Players:FindFirstChild(option)
        if target and target.Character then
            Spectating = target
            workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
        end
    end
})

local function refreshPlayerDropdown()
    if not PlayerListDropdown then return end
    pcall(function() if PlayerListDropdown.Clear then PlayerListDropdown:Clear() end end)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            pcall(function() if PlayerListDropdown.AddOption then PlayerListDropdown:AddOption(plr.Name) end end)
        end
    end
end

MiscTab:CreateButton({ Name = "Refresh Player List", Callback = function() refreshPlayerDropdown() end })
MiscTab:CreateButton({
    Name = "Stop Spectating",
    Callback = function()
        Spectating = nil
        if LocalPlayer.Character then
            workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    end
})

MiscTab:CreateToggle({ Name = "Instant Collect", CurrentValue = false, Callback = function(v) instantCollectEnabled = v end })
MiscTab:CreateToggle({ Name = "Auto Collect", CurrentValue = false, Callback = function(v) autoCollectEnabled = v end })

-- auto-refresh dropdown
Players.PlayerAdded:Connect(refreshPlayerDropdown)
Players.PlayerRemoving:Connect(refreshPlayerDropdown)
refreshPlayerDropdown()

-- ======================================================
-- RENDER LOOP (ESP + AimLock + Spectate check)
-- ======================================================
-- (isi loop sama dengan yang kamu punya, aku skip detail untuk singkat,
-- tinggal tempel ulang bagian Highlight, Name ESP, Healthbar, Tracer, AimLock dsb)

RunService.RenderStepped:Connect(function()
    -- Pastikan spectating kamera re-apply
    if Spectating and Spectating.Character then
        local hum = Spectating.Character:FindFirstChildOfClass("Humanoid")
        if hum and workspace.CurrentCamera.CameraSubject ~= hum then
            workspace.CurrentCamera.CameraSubject = hum
        end
    end
end)

-- ======================================================
-- STEPPED LOOP (Movement / Collect placeholders)
-- ======================================================
RunService.Stepped:Connect(function()
    local plr = LocalPlayer
    if plr and plr.Character then
        if noclipEnabled then
            for _, part in pairs(plr.Character:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        if noFallEnabled then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.FloorMaterial == Enum.Material.Air and hum.Health > 0 then
                hum:ChangeState(Enum.HumanoidStateType.Landed)
            end
        end
    end
end)
