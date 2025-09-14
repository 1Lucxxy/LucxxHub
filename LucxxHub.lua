-- // Rayfield Hub | ESP + Aimlock + Player Settings
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Rayfield Loader
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Rayfield Hub | ESP & Aimlock",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by ChatGPT",
    ConfigurationSaving = { Enabled = false }
})

-- GLOBAL SETTINGS
getgenv().ESP_Enabled = false
getgenv().ESP_Line = false
getgenv().ESP_Healthbar = false
getgenv().ESP_TeamCheck = false

getgenv().Aimlock_Enabled = false
getgenv().WallCheck = false
getgenv().POV_Radius = 150

-- POV Circle
local PovCircle = Drawing.new("Circle")
PovCircle.Color = Color3.fromRGB(255, 255, 255)
PovCircle.Thickness = 1.5
PovCircle.NumSides = 64
PovCircle.Filled = false
PovCircle.Transparency = 1
PovCircle.Radius = getgenv().POV_Radius
PovCircle.Visible = false

-- ESP Container
local ESP_Objects = {}

local function CreateESP(plr)
    if plr == LocalPlayer then return end

    ESP_Objects[plr] = {
        Line = Drawing.new("Line"),
        HB = Drawing.new("Square"),
        HBo = Drawing.new("Square")
    }

    ESP_Objects[plr].Line.Color = Color3.fromRGB(255, 255, 255)
    ESP_Objects[plr].Line.Thickness = 1
    ESP_Objects[plr].Line.Visible = false

    ESP_Objects[plr].HBo.Color = Color3.fromRGB(0, 0, 0)
    ESP_Objects[plr].HBo.Thickness = 1
    ESP_Objects[plr].HBo.Filled = false
    ESP_Objects[plr].HBo.Visible = false

    ESP_Objects[plr].HB.Color = Color3.fromRGB(0, 255, 0)
    ESP_Objects[plr].HB.Thickness = 1
    ESP_Objects[plr].HB.Filled = true
    ESP_Objects[plr].HB.Visible = false
end

local function RemoveESP(plr)
    if ESP_Objects[plr] then
        for _, obj in pairs(ESP_Objects[plr]) do
            obj:Remove()
        end
        ESP_Objects[plr] = nil
    end
end

-- WALL CHECK
local function IsVisible(targetPart)
    if not getgenv().WallCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = (targetPart.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character, targetPart.Parent }
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(origin, dir, rayParams)
    return not result
end

-- Cari target terdekat dalam POV
local function GetClosestTarget()
    local closest, dist = nil, getgenv().POV_Radius
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            if getgenv().ESP_TeamCheck and plr.Team == LocalPlayer.Team then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
            if onScreen then
                local mouse = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local mag = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                if mag < dist and IsVisible(plr.Character.Head) then
                    closest, dist = plr, mag
                end
            end
        end
    end
    return closest
end

-- Update ESP & AIMLOCK
RunService.RenderStepped:Connect(function()
    for _, objs in pairs(ESP_Objects) do
        objs.Line.Visible = false
        objs.HB.Visible = false
        objs.HBo.Visible = false
    end

    PovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    PovCircle.Radius = getgenv().POV_Radius
    PovCircle.Visible = getgenv().Aimlock_Enabled -- hanya muncul saat Aimlock aktif

    if getgenv().ESP_Enabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and ESP_Objects[plr] then
                local char = plr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    if getgenv().ESP_TeamCheck and plr.Team == LocalPlayer.Team then continue end
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        if getgenv().ESP_Line then
                            ESP_Objects[plr].Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            ESP_Objects[plr].Line.To = Vector2.new(pos.X, pos.Y)
                            ESP_Objects[plr].Line.Visible = true
                        end
                        if getgenv().ESP_Healthbar then
                            local sizeY = 50
                            local hpPercent = hum.Health / hum.MaxHealth
                            local barX = pos.X - 40
                            local barY = pos.Y - (sizeY/2)

                            ESP_Objects[plr].HBo.Size = Vector2.new(4, sizeY)
                            ESP_Objects[plr].HBo.Position = Vector2.new(barX, barY)
                            ESP_Objects[plr].HBo.Visible = true

                            ESP_Objects[plr].HB.Size = Vector2.new(4, sizeY * hpPercent)
                            ESP_Objects[plr].HB.Position = Vector2.new(barX, barY + (sizeY * (1 - hpPercent)))
                            ESP_Objects[plr].HB.Color = Color3.fromRGB(255 - (hpPercent*255), hpPercent*255, 0)
                            ESP_Objects[plr].HB.Visible = true
                        end
                    end
                end
            end
        end
    end

    if getgenv().Aimlock_Enabled then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, plr in pairs(Players:GetPlayers()) do
    CreateESP(plr)
end

-- UI Tabs
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- Visuals
VisualsTab:CreateToggle({ Name = "ESP Master", CurrentValue = false, Callback = function(v) getgenv().ESP_Enabled = v end })
VisualsTab:CreateToggle({ Name = "Line ESP", CurrentValue = false, Callback = function(v) getgenv().ESP_Line = v end })
VisualsTab:CreateToggle({ Name = "Healthbar ESP", CurrentValue = false, Callback = function(v) getgenv().ESP_Healthbar = v end })
VisualsTab:CreateToggle({ Name = "Team Check", CurrentValue = false, Callback = function(v) getgenv().ESP_TeamCheck = v end })

-- Combat
CombatTab:CreateToggle({ Name = "Aimlock", CurrentValue = false, Callback = function(v) getgenv().Aimlock_Enabled = v end })
CombatTab:CreateToggle({ Name = "Wall Check", CurrentValue = false, Callback = function(v) getgenv().WallCheck = v end })
CombatTab:CreateSlider({
    Name = "POV Radius",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = getgenv().POV_Radius,
    Callback = function(v) getgenv().POV_Radius = v end
})

-- Player tab (WalkSpeed, JumpPower, Gravity, MaxZoom)
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 300},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v
        end
    end
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = v
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Gravity",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = workspace.Gravity,
    Callback = function(v) workspace.Gravity = v end
})

PlayerTab:CreateSlider({
    Name = "Max Camera Zoom",
    Range = {0, 1000},
    Increment = 10,
    CurrentValue = LocalPlayer.CameraMaxZoomDistance,
    Callback = function(v) LocalPlayer.CameraMaxZoomDistance = v end
})
