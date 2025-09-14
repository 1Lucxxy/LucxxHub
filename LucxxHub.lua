-- // Rayfield UI + ESP + Aimlock + WallCheck + POV Circle
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
    ConfigurationSaving = {
        Enabled = false
    }
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
PovCircle.Color = Color3.fromRGB(255,255,255)
PovCircle.Thickness = 1.5
PovCircle.NumSides = 64
PovCircle.Filled = false
PovCircle.Transparency = 1
PovCircle.Radius = getgenv().POV_Radius
PovCircle.Visible = false

-- ESP Container
local ESP_Objects = {}

-- Buat ESP
local function CreateESP(plr)
    if plr == LocalPlayer then return end

    ESP_Objects[plr] = {
        Line = Drawing.new("Line"),
        HB = Drawing.new("Square"),
        HBo = Drawing.new("Square")
    }

    -- Line
    ESP_Objects[plr].Line.Color = Color3.fromRGB(255,255,255)
    ESP_Objects[plr].Line.Thickness = 1
    ESP_Objects[plr].Line.Visible = false

    -- Healthbar Outline
    ESP_Objects[plr].HBo.Color = Color3.fromRGB(0,0,0)
    ESP_Objects[plr].HBo.Thickness = 1
    ESP_Objects[plr].HBo.Filled = false
    ESP_Objects[plr].HBo.Visible = false

    -- Healthbar
    ESP_Objects[plr].HB.Color = Color3.fromRGB(0,255,0)
    ESP_Objects[plr].HB.Thickness = 1
    ESP_Objects[plr].HB.Filled = true
    ESP_Objects[plr].HB.Visible = false
end

-- Remove ESP
local function RemoveESP(plr)
    if ESP_Objects[plr] then
        for _, obj in pairs(ESP_Objects[plr]) do
            obj:Remove()
        end
        ESP_Objects[plr] = nil
    end
end

-- WALL CHECK function
local function IsVisible(targetPart)
    if not getgenv().WallCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = (targetPart.Position - origin)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
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
                local mag = (Vector2.new(pos.X,pos.Y) - mouse).Magnitude
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
    -- hide all first (fix stuck bug)
    for _, objs in pairs(ESP_Objects) do
        objs.Line.Visible = false
        objs.HB.Visible = false
        objs.HBo.Visible = false
    end

    -- POV circle update
    PovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    PovCircle.Radius = getgenv().POV_Radius
    PovCircle.Visible = getgenv().Aimlock_Enabled

    -- ESP
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

    -- AIMLOCK
    if getgenv().Aimlock_Enabled then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- Player join/leave
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, plr in pairs(Players:GetPlayers()) do
    CreateESP(plr)
end

-- UI Tabs
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)

-- Visuals Toggles
VisualsTab:CreateToggle({
    Name = "ESP Master",
    CurrentValue = getgenv().ESP_Enabled,
    Callback = function(v) getgenv().ESP_Enabled = v end
})

VisualsTab:CreateToggle({
    Name = "Line ESP",
    CurrentValue = getgenv().ESP_Line,
    Callback = function(v) getgenv().ESP_Line = v end
})

VisualsTab:CreateToggle({
    Name = "Healthbar ESP",
    CurrentValue = getgenv().ESP_Healthbar,
    Callback = function(v) getgenv().ESP_Healthbar = v end
})

VisualsTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = getgenv().ESP_TeamCheck,
    Callback = function(v) getgenv().ESP_TeamCheck = v end
})

-- Combat Toggles
CombatTab:CreateToggle({
    Name = "Aimlock",
    CurrentValue = getgenv().Aimlock_Enabled,
    Callback = function(v) getgenv().Aimlock_Enabled = v end
})

CombatTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = getgenv().WallCheck,
    Callback = function(v) getgenv().WallCheck = v end
})

CombatTab:CreateSlider({
    Name = "POV Radius",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = getgenv().POV_Radius,
    Callback = function(v) getgenv().POV_Radius = v end
})
