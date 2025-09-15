-- // Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local LocalPlayer = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")

-- // Window
local Window = Rayfield:CreateWindow({
    Name = "Lucxx Hub V3",
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
local MiscTab   = Window:CreateTab("Miscellaneous", 4483362458)

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
-- COMBAT TAB (FOV, AimLock, Wallbang, Tracer)
-- ======================================================
local TeamCheck = false
local AimLockEnabled = false
local WallCheck = false
local TracerEnabled = false
local FOVRadius = 100

local camera = workspace.CurrentCamera
local screenCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

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
    Callback = function(Value) WallCheck = Value end
})

CombatTab:CreateToggle({
    Name = "Tracer",
    CurrentValue = false,
    Callback = function(Value) TracerEnabled = Value end
})

-- ======================================================
-- VISUAL TAB (Highlight, Name ESP, Health ESP)
-- ======================================================
local HighlightESPEnabled = false
local ESPEnabled = false
local HealthESPEnabled = false
local DrawingESP = {}

VisualTab:CreateToggle({
    Name = "Player Highlight",
    CurrentValue = false,
    Callback = function(Value) HighlightESPEnabled = Value end,
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

-- ======================================================
-- MISC TAB
-- ======================================================
-- Macro Buttons
local macroGui = nil

MiscTab:CreateToggle({
    Name = "Macro Buttons",
    CurrentValue = false,
    Callback = function(state)
        if state then
            -- Buat GUI
            macroGui = Instance.new("ScreenGui")
            macroGui.Name = "MacroButtonsGui"
            macroGui.ResetOnSpawn = false
            macroGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

            -- Tombol 1: Hotbar 1 -> F
            local Button1 = Instance.new("TextButton")
            Button1.Parent = macroGui
            Button1.Text = "GUN"
            Button1.TextSize = 14
            Button1.Size = UDim2.new(0, 70, 0, 70)
            Button1.AnchorPoint = Vector2.new(1, 0)
            Button1.Position = UDim2.new(0.98, 0, 0.02, 0)
            Button1.BackgroundTransparency = 1
            Button1.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button1.Font = Enum.Font.SourceSans
            Button1.ZIndex = 9999

            local stroke1 = Instance.new("UIStroke", Button1)
            stroke1.Color = Color3.fromRGB(255, 255, 255)
            stroke1.Thickness = 1.2

            local corner1 = Instance.new("UICorner", Button1)
            corner1.CornerRadius = UDim.new(1, 0)

            Button1.MouseButton1Click:Connect(function()
                vim:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                task.wait(1)
                vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end)

            -- Tombol 2: R -> F
            local Button2 = Instance.new("TextButton")
            Button2.Parent = macroGui
            Button2.Text = "RELOAD"
            Button2.TextSize = 14
            Button2.Size = UDim2.new(0, 70, 0, 70)
            Button2.AnchorPoint = Vector2.new(1, 0)
            Button2.Position = UDim2.new(0.85, 0, 0.02, 0)
            Button2.BackgroundTransparency = 1
            Button2.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button2.Font = Enum.Font.SourceSans
            Button2.ZIndex = 9999

            local stroke2 = Instance.new("UIStroke", Button2)
            stroke2.Color = Color3.fromRGB(255, 255, 255)
            stroke2.Thickness = 1.2

            local corner2 = Instance.new("UICorner", Button2)
            corner2.CornerRadius = UDim.new(1, 0)

            Button2.MouseButton1Click:Connect(function()
                vim:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                task.wait(2)
                vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end)

        else
            if macroGui then
                macroGui:Destroy()
                macroGui = nil
            end
        end
    end
})

-- ======================================================
-- MAIN LOOP
-- ======================================================
game:GetService("RunService").RenderStepped:Connect(function()
    screenCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    FOVCircle.Position = screenCenter

    -- Highlight ESP
    if HighlightESPEnabled then
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hl = plr.Character:FindFirstChild("Highlight")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local showHighlight = true
                if TeamCheck and plr.Team == LocalPlayer.Team then
                    showHighlight = false
                end
                if showHighlight and hum and hum.Health > 0 then
                    if not hl then
                        hl = Instance.new("Highlight", plr.Character)
                        hl.FillTransparency = 1
                        hl.OutlineColor = Color3.fromRGB(0,255,0)
                    else
                        hl.OutlineColor = Color3.fromRGB(0,255,0)
                    end
                else
                    if hl then hl:Destroy() end
                end
            end
        end
    else
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr.Character then
                local hl = plr.Character:FindFirstChild("Highlight")
                if hl then hl:Destroy() end
            end
        end
    end

    -- ESP Loop (Name + Healthbar)
    for _,plr in pairs(game.Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")
            if not DrawingESP[plr] then DrawingESP[plr] = {} end
            local data = DrawingESP[plr]

            if not head or not hum or hum.Health <= 1 then
                if data.Name then data.Name.Visible = false end
                if data.Health then data.Health.Visible = false end
                if data.HealthBG then data.HealthBG.Visible = false end
                continue
            end

            local showESP = true
            if TeamCheck and plr.Team == LocalPlayer.Team then
                showESP = false
            end

            if showESP then
                if ESPEnabled and head then
                    if not data.Name then
                        data.Name = Drawing.new("Text")
                        data.Name.Size = 16
                        data.Name.Center = true
                        data.Name.Outline = true
                        data.Name.Color = Color3.fromRGB(255,255,255)
                    end
                    local pos, vis = camera:WorldToViewportPoint(head.Position+Vector3.new(0,2,0))
                    data.Name.Visible = vis
                    if vis then
                        data.Name.Text = plr.Name
                        data.Name.Position = Vector2.new(pos.X, pos.Y)
                    end
                elseif data.Name then
                    data.Name.Visible = false
                end

                if HealthESPEnabled and hum and head then
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
                    local headPos, vis = camera:WorldToViewportPoint(head.Position+Vector3.new(0,2.5,0))
                    if vis then
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
                        data.HealthBG.Visible = false
                        data.Health.Visible = false
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

    -- Combat: Aim Lock + WallCheck + Tracer
    if AimLockEnabled then
        local nearestPlayer
        local nearestDistance = math.huge

        for _,plr in pairs(game.Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 1 then
                    if not TeamCheck or (TeamCheck and plr.Team ~= LocalPlayer.Team) then
                        local headPos, onScreen = camera:WorldToViewportPoint(plr.Character.Head.Position)
                        if onScreen then
                            local dist = (Vector2.new(headPos.X, headPos.Y) - screenCenter).Magnitude
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

            if WallCheck then
                local origin = camera.CFrame.Position
                local direction = (headPos - origin)
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, nearestPlayer.Character}
                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

                local rayResult = workspace:Raycast(origin, direction, raycastParams)
                if rayResult then
                    canSee = false
                end
            end

            if canSee then
                camera.CFrame = CFrame.new(camera.CFrame.Position, headPos)
            end
        end
    end

    -- Tracer (simple line from screen center)
    if TracerEnabled then
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local head = plr.Character.Head
                if hum and hum.Health > 1 then
                    if not DrawingESP[plr].Tracer then
                        DrawingESP[plr].Tracer = Drawing.new("Line")
                        DrawingESP[plr].Tracer.Thickness = 1.5
                        DrawingESP[plr].Tracer.Color = Color3.fromRGB(0,255,255)
                    end
                    local pos, vis = camera:WorldToViewportPoint(head.Position)
                    if vis then
                        DrawingESP[plr].Tracer.From = screenCenter
                        DrawingESP[plr].Tracer.To = Vector2.new(pos.X, pos.Y)
                        DrawingESP[plr].Tracer.Visible = true
                    else
                        DrawingESP[plr].Tracer.Visible = false
                    end
                end
            else
                if DrawingESP[plr] and DrawingESP[plr].Tracer then
                    DrawingESP[plr].Tracer.Visible = false
                end
            end
        end
    else
        for _, plr in pairs(DrawingESP) do
            if plr.Tracer then plr.Tracer.Visible = false end
        end
    end
end)
