-- // Lucxx Hub V2 Full
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")

-- // Window
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Lucxx Hub V2 Full",
    LoadingTitle = "Lucxx Hub",
    LoadingSubtitle = "by Lucxxy",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "LucxxHub",
        FileName = "Config"
    },
    Discord = { Enabled = false }
})

-- // Tabs
local PlayerTab = Window:CreateTab("Player", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- ======================================================
-- PLAYER TAB
-- ======================================================
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

PlayerTab:CreateButton({
    Name = "Fly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end,
})

-- ======================================================
-- COMBAT TAB
-- ======================================================
local TeamCheck = false
local AimLockEnabled = false
local WallCheckEnabled = false
local TracerEnabled = false
local FOVRadius = 100
local AimlockRange = 200

local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- POV Circle
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
    Callback = function(Value) TeamCheck = Value end
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
    Callback = function(Value) WallCheckEnabled = Value end
})

CombatTab:CreateToggle({
    Name = "Tracer",
    CurrentValue = false,
    Callback = function(Value) TracerEnabled = Value end
})

CombatTab:CreateSlider({
    Name = "Aimlock Range",
    Range = {50,1000},
    Increment = 10,
    Suffix = "Studs",
    CurrentValue = AimlockRange,
    Callback = function(Value)
        AimlockRange = Value
    end
})

-- ======================================================
-- VISUAL TAB
-- ======================================================
local PlayerESPEnabled = false
local HealthESPEnabled = false
local DrawingESP = {}

VisualTab:CreateToggle({ Name = "Player ESP", CurrentValue = false, Callback = function(state) PlayerESPEnabled = state end })
VisualTab:CreateToggle({ Name = "Healthbar ESP", CurrentValue = false, Callback = function(state) HealthESPEnabled = state end })
VisualTab:CreateToggle({ Name = "Wall Check", CurrentValue = false, Callback = function(state) WallCheckEnabled = state end })
VisualTab:CreateToggle({ Name = "Team Check", CurrentValue = false, Callback = function(state) TeamCheck = state end })

-- ======================================================
-- MISC TAB
-- ======================================================
local freecamEnabled = false
local spectating = false
local spectateTarget = nil

MiscTab:CreateToggle({
    Name = "Freecam",
    CurrentValue = false,
    Callback = function(state)
        freecamEnabled = state
        if not state then
            Camera.CameraType = Enum.CameraType.Custom
        end
    end
})

-- Spectate Dropdown
local PlayerListDropdown
local function refreshPlayerDropdown()
    if not PlayerListDropdown then return end
    pcall(function() if PlayerListDropdown.Clear then PlayerListDropdown:Clear() end end)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            pcall(function() if PlayerListDropdown.AddOption then PlayerListDropdown:AddOption(plr.Name) end end)
        end
    end
end

PlayerListDropdown = MiscTab:CreateDropdown({
    Name = "Spectate Player",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Callback = function(option)
        local plr = Players:FindFirstChild(option)
        if plr and plr.Character then
            spectating = true
            spectateTarget = plr
        else
            spectating = false
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
        end
    end
})

MiscTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function() refreshPlayerDropdown() end
})

-- Macro Buttons
local Gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
Gui.ResetOnSpawn = false
Gui.Enabled = false

local function createButton(name,pos,callback)
    local btn = Instance.new("TextButton")
    btn.Parent = Gui
    btn.Text = name
    btn.TextSize = 14
    btn.Size = UDim2.new(0,70,0,70)
    btn.AnchorPoint = Vector2.new(1,0)
    btn.Position = pos
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSans
    btn.ZIndex = 9999
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(255,255,255)
    stroke.Thickness = 1.2
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(1,0)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createButton("GUN", UDim2.new(0.98,0,0.02,0), function()
    vim:SendKeyEvent(true,Enum.KeyCode.One,false,game)
    vim:SendKeyEvent(false,Enum.KeyCode.One,false,game)
    task.wait(1)
    vim:SendKeyEvent(true,Enum.KeyCode.F,false,game)
    vim:SendKeyEvent(false,Enum.KeyCode.F,false,game)
end)

createButton("RELOAD", UDim2.new(0.85,0,0.02,0), function()
    vim:SendKeyEvent(true,Enum.KeyCode.R,false,game)
    vim:SendKeyEvent(false,Enum.KeyCode.R,false,game)
    task.wait(2)
    vim:SendKeyEvent(true,Enum.KeyCode.F,false,game)
    vim:SendKeyEvent(false,Enum.KeyCode.F,false,game)
end)

MiscTab:CreateToggle({ Name = "Macro Buttons", CurrentValue = false, Callback = function(state) Gui.Enabled = state end })

-- ======================================================
-- MAIN LOOP
-- ======================================================
RunService.RenderStepped:Connect(function()
    screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Position = screenCenter

    -- Player ESP + Healthbar
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Head") then
            local hum = plr.Character.Humanoid
            local head = plr.Character.Head
            if not DrawingESP[plr] then DrawingESP[plr] = {} end
            local data = DrawingESP[plr]

            local showESP = PlayerESPEnabled or HealthESPEnabled
            if TeamCheck and plr.Team == LocalPlayer.Team then showESP = false end

            local canSee = true
            if WallCheckEnabled then
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {LocalPlayer.Character, plr.Character}
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                local rayResult = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position), rayParams)
                if rayResult then canSee = false end
            end

            if showESP and canSee then
                -- Name ESP
                if PlayerESPEnabled then
                    if not data.Name then
                        data.Name = Drawing.new("Text")
                        data.Name.Size = 16
                        data.Name.Center = true
                        data.Name.Outline = true
                        data.Name.Color = Color3.fromRGB(255,255,255)
                    end
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,2,0))
                    data.Name.Visible = onScreen
                    if onScreen then
                        data.Name.Position = Vector2.new(pos.X,pos.Y)
                        data.Name.Text = plr.Name
                    end
                elseif data.Name then
                    data.Name.Visible = false
                end

                -- Healthbar ESP
                if HealthESPEnabled then
                    if not data.HealthBG then
                        data.HealthBG = Drawing.new("Quad")
                        data.HealthBG.Filled = true
                        data.HealthBG.Color = Color3.fromRGB(50,50,50)
                    end
                    if not data.Health then
                        data.Health = Drawing.new("Quad")
                        data.Health.Filled = true
                    end
                    local hp = hum.Health / hum.MaxHealth
                    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,2.5,0))
                    if onScreen then
                        local barW, barH = 70, 4
                        local x, y = headPos.X - barW/2, headPos.Y - 15
                        data.HealthBG.PointA = Vector2.new(x, y)
                        data.HealthBG.PointB = Vector2.new(x+barW, y)
                        data.HealthBG.PointC = Vector2.new(x+barW, y+barH)
                        data.HealthBG.PointD = Vector2.new(x, y+barH)
                        data.HealthBG.Visible = true

                        local hpW = barW * math.clamp(hp,0,1)
                        data.Health.PointA = Vector2.new(x, y)
                        data.Health.PointB = Vector2.new(x+hpW, y)
                        data.Health.PointC = Vector2.new(x+hpW, y+barH)
                        data.Health.PointD = Vector2.new(x, y+barH)
                        data.Health.Color = hp > 0.5 and Color3.fromRGB(0,255,0)
                                        or hp > 0.2 and Color3.fromRGB(255,255,0)
                                        or Color3.fromRGB(255,0,0)
                        data.Health.Visible = true
                    else
                        data.Health.Visible = false
                        data.HealthBG.Visible = false
                    end
                elseif data.Health then
                    data.Health.Visible = false
                    if data.HealthBG then data.HealthBG.Visible = false end
                end
            else
                if data.Name then data.Name.Visible = false end
                if data.Health then data.Health.Visible = false end
                if data.HealthBG then data.HealthBG.Visible = false end
            end
        end
    end

    -- Aimlock
    if AimLockEnabled then
        local nearestPlayer
        local nearestDistance = AimlockRange
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local hum = plr.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 1 then
                    if not TeamCheck or (TeamCheck and plr.Team ~= LocalPlayer.Team) then
                        local headPos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                        if onScreen then
                            local dist = (Vector2.new(headPos.X,headPos.Y) - screenCenter).Magnitude
                            if dist <= FOVRadius and dist < nearestDistance then
                                nearestDistance = dist
                                nearestPlayer = plr
                            end
                        end
                    end
                end
            end
        end

        if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("Head") then
            local headPos = nearestPlayer.Character.Head.Position
            local canSee = true
            if WallCheckEnabled then
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {LocalPlayer.Character, nearestPlayer.Character}
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                local rayResult = workspace:Raycast(Camera.CFrame.Position, (headPos - Camera.CFrame.Position), rayParams)
                if rayResult then canSee = false end
            end
            if canSee then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, headPos)
            end
        end
    end

    -- Tracer
    if TracerEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local head = plr.Character.Head
                if hum and hum.Health > 1 then
                    if not DrawingESP[plr].Tracer then
                        DrawingESP[plr].Tracer = Drawing.new("Line")
                        DrawingESP[plr].Tracer.Thickness = 1.5
                        DrawingESP[plr].Tracer.Color = Color3.fromRGB(0,255,255)
                    end
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        DrawingESP[plr].Tracer.From = screenCenter
                        DrawingESP[plr].Tracer.To = Vector2.new(pos.X,pos.Y)
                        DrawingESP[plr].Tracer.Visible = true
                    else
                        DrawingESP[plr].Tracer.Visible = false
                    end
                end
            elseif DrawingESP[plr].Tracer then
                DrawingESP[plr].Tracer.Visible = false
            end
        end
    else
        for _, plr in pairs(DrawingESP) do
            if plr.Tracer then plr.Tracer.Visible = false end
        end
    end
end)
