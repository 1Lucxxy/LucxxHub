--// Rayfield Loader
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Window
local Window = Rayfield:CreateWindow({
    Name = "Custom Hub",
    LoadingTitle = "Custom Hub Loader",
    LoadingSubtitle = "by Lucxy",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "CustomHub",
        FileName = "Config"
    }
})

--// Tabs
local CombatTab = Window:CreateTab("Combat", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local MiscTab = Window:CreateTab("Miscaeluss", 4483362458)

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// Global Vars
getgenv().Aimlock_Enabled = false
getgenv().POV_Radius = 120
getgenv().WallCheck = true

--// Drawing Circle (POV)
local PovCircle = Drawing.new("Circle")
PovCircle.Color = Color3.fromRGB(255, 255, 255)
PovCircle.Thickness = 2
PovCircle.NumSides = 100
PovCircle.Filled = false
PovCircle.Transparency = 1
PovCircle.Radius = getgenv().POV_Radius
PovCircle.Visible = false

--// Wall Check Function
local function IsVisible(targetPart)
    if not targetPart then return false end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local ray = Ray.new(origin, direction)
    local hitPart = workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
    return hitPart and hitPart:IsDescendantOf(targetPart.Parent)
end

--// Get Closest Player
local function GetClosest()
    local closest, distance = nil, getgenv().POV_Radius
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if mag < distance then
                    if not getgenv().WallCheck or IsVisible(plr.Character.Head) then
                        closest = plr
                        distance = mag
                    end
                end
            end
        end
    end
    return closest
end

--// Aimlock Toggle
CombatTab:CreateToggle({
    Name = "Aimlock",
    CurrentValue = false,
    Flag = "Aimlock",
    Callback = function(Value)
        getgenv().Aimlock_Enabled = Value
        PovCircle.Visible = Value
    end
})

--// POV Radius Slider
CombatTab:CreateSlider({
    Name = "POV Radius",
    Range = {50, 500},
    Increment = 5,
    Suffix = "px",
    CurrentValue = getgenv().POV_Radius,
    Flag = "POVRadius",
    Callback = function(Value)
        getgenv().POV_Radius = Value
        PovCircle.Radius = Value
    end
})

--// Wall Check Toggle
CombatTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = true,
    Flag = "WallCheck",
    Callback = function(Value)
        getgenv().WallCheck = Value
    end
})

--// POV Circle Update
RunService.RenderStepped:Connect(function()
    PovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    PovCircle.Radius = getgenv().POV_Radius
    PovCircle.Visible = getgenv().Aimlock_Enabled
end)

--// Aimlock Logic
RunService.RenderStepped:Connect(function()
    if getgenv().Aimlock_Enabled then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

--// === PLAYER TAB ===
-- WalkSpeed
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 300},
    Increment = 1,
    Suffix = " speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

-- JumpPower
PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 1,
    Suffix = " power",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end
})

-- Gravity
PlayerTab:CreateSlider({
    Name = "Gravity",
    Range = {0, 100},
    Increment = 1,
    Suffix = " g",
    CurrentValue = workspace.Gravity,
    Flag = "Gravity",
    Callback = function(Value)
        workspace.Gravity = Value
    end
})

-- Max Zoom Distance
PlayerTab:CreateSlider({
    Name = "Max Zoom",
    Range = {50, 1000},
    Increment = 10,
    Suffix = " studs",
    CurrentValue = LocalPlayer.CameraMaxZoomDistance,
    Flag = "Zoom",
    Callback = function(Value)
        LocalPlayer.CameraMaxZoomDistance = Value
    end
})
