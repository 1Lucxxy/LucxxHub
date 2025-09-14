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

-- ======================================================
-- PLAYER SETTINGS
-- ======================================================
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

PlayerTab:CreateButton({
    Name = "Fly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end,
})

-- ======================================================
-- COMBAT SETTINGS
-- ======================================================
local TeamCheck = false
local AimLockEnabled = false
local WallCheck = false
local WallbangEnabled = false
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

CombatTab:CreateToggle({
    Name = "Wallbang",
    CurrentValue = false,
    Callback = function(Value)
        WallbangEnabled = Value
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
-- CLEANUP SYSTEM
-- ======================================================
game.Players.PlayerRemoving:Connect(function(plr)
    if DrawingESP[plr] then
        for _, obj in pairs(DrawingESP[plr]) do
            if obj.Remove then obj:Remove() end
        end
        DrawingESP[plr] = nil
    end
end)

-- ======================================================
-- WALLBANG HOOK
-- ======================================================
local old; old = hookmetamethod(workspace, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if WallbangEnabled and method == "Raycast" then
        local origin, direction, params = args[1], args[2], args[3]
        if typeof(params) == "RaycastParams" then
            -- blacklist semua part di workspace agar raycast nembus
            params.FilterType = Enum.RaycastFilterType.Blacklist
            params.FilterDescendantsInstances = {workspace}
        end
        return old(self, origin, direction, params)
    end

    return old(self, ...)
end)

-- ======================================================
-- MAIN LOOP
-- ======================================================
game:GetService("RunService").RenderStepped:Connect(function()
    local screenCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

    -- update POV circle
    FOVCircle.Position = screenCenter
    FOVCircle.Radius = FOVRadius

    -- Highlight ESP
if HighlightESPEnabled then
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 1 then
                local hl = plr.Character:FindFirstChild("Highlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Parent = plr.Character
                    hl.Name = "LucxxHighlight"
                    hl.FillColor = Color3.fromRGB(0,255,0)
                    hl.FillTransparency = 0.7
                    hl.OutlineColor = Color3.fromRGB(0,255,0)
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                -- update warna kalau sudah ada
                hl.FillColor = Color3.fromRGB(0,255,0)
                hl.OutlineColor = Color3.fromRGB(0,255,0)
            end
        end
    end
else
    -- matikan semua highlight kalau toggle OFF
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr.Character then
            local hl = plr.Character:FindFirstChild("LucxxHighlight")
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

    -- ESP Loop (Name, Health, Line)
    for _,plr in pairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")

            if not DrawingESP[plr] then DrawingESP[plr] = {} end
            local data = DrawingESP[plr]

            -- sembunyikan jika mati / head hilang
            if not head or not hum or hum.Health <= 1 then
                if data.Name then data.Name.Visible = false end
                if data.Health then data.Health.Visible = false end
                if data.HealthBG then data.HealthBG.Visible = false end
                if data.Line then data.Line.Visible = false end
                continue
            end

            local showESP = true
            if TeamCheck and plr.Team == game.Players.LocalPlayer.Team then
                showESP = false
            end

            if showESP then
                -- Name ESP
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

                -- Healthbar ESP
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

                -- Line ESP
                if LineESPEnabled and head then
                    if not data.Line then
                        data.Line = Drawing.new("Line")
                        data.Line.Thickness = 2
                        data.Line.Color = Color3.fromRGB(0,255,255)
                    end
                    local pos, vis = camera:WorldToViewportPoint(head.Position)
                    if vis then
                        data.Line.From = screenCenter
                        data.Line.To = Vector2.new(pos.X, pos.Y)
                        data.Line.Visible = true
                    else
                        data.Line.Visible = false
                    end
                elseif data.Line then
                    data.Line.Visible = false
                end
            else
                if data.Name then data.Name.Visible = false end
                if data.Health then data.Health.Visible = false end
                if data.HealthBG then data.HealthBG.Visible = false end
                if data.Line then data.Line.Visible = false end
            end
        end
    end

    -- ======================================================
    -- Aim Lock + WallCheck
    -- ======================================================
    if AimLockEnabled then
        local nearestPlayer
        local nearestDistance = math.huge

        for _,plr in pairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 1 then
                    if not TeamCheck or (TeamCheck and plr.Team ~= game.Players.LocalPlayer.Team) then
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
                raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character, nearestPlayer.Character}
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
end)