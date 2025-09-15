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
-- COMBAT SETTINGS (moved Tracer & Wallbang here)
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

-- Tracer moved here
CombatTab:CreateToggle({
    Name = "Tracer",
    CurrentValue = false,
    Callback = function(Value)
        tracerEnabled = Value
    end
})

-- Wallbang toggle (moved here, behavior intentionally not implemented)
CombatTab:CreateToggle({
    Name = "Wallbang",
    CurrentValue = false,
    Callback = function(Value)
        wallbangEnabled = Value
        -- Note: wallbang behavior not implemented (avoid bypass/evade logic)
    end
})

-- ======================================================
-- VISUAL SETTINGS (Line ESP removed here)
-- ======================================================
local HighlightESPEnabled = false
local ESPEnabled = false
local HealthESPEnabled = false
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

-- ======================================================
-- MISCELLANEOUS SETTINGS (removed tracer & wallbang from here)
-- ======================================================
local noclipEnabled = false
local antiAFKEnabled = false
local noFallEnabled = false
local freeCamEnabled = false
local instantCollectEnabled = false
local autoCollectEnabled = false
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

-- FreeCam (kecepatan bisa diubah di variable freeCamSpeed)
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
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + cam.CFrame.UpVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - cam.CFrame.UpVector end

                pos = pos + move * freeCamSpeed * (dt * 60)
                cam.CFrame = pos
            end)

        else
            if freeCamConn then freeCamConn:Disconnect() freeCamConn = nil end
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    end
})

-- Spectate dropdown + safe refresh helper
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

local function safeSetDropdownOptions(dropdown, names)
    if not dropdown then return end
    -- try SetOptions, fallback to Set({Options = ...}) and ignore errors
    local ok = pcall(function() if type(dropdown.SetOptions) == 'function' then dropdown:SetOptions(names) end end)
    if not ok then
        pcall(function() if type(dropdown.Set) == 'function' then dropdown:Set({Options = names, CurrentOption = nil}) end end)
    end
end

local function refreshPlayerDropdown()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    safeSetDropdownOptions(PlayerListDropdown, names)
end

MiscTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        refreshPlayerDropdown()
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

-- Misc collect toggles (placeholders)
MiscTab:CreateToggle({Name = "Instant Collect", CurrentValue = false, Callback = function(Value) instantCollectEnabled = Value end})
MiscTab:CreateToggle({Name = "Auto Collect", CurrentValue = false, Callback = function(Value) autoCollectEnabled = Value end})

-- ======================================================
-- CLEANUP SYSTEM
-- ======================================================
Players.PlayerRemoving:Connect(function(plr)
    if DrawingESP[plr] then
        for _, obj in pairs(DrawingESP[plr]) do
            if obj and obj.Remove then
                pcall(function() obj:Remove() end)
            end
        end
        DrawingESP[plr] = nil
    end
    -- refresh dropdown when someone leaves
    refreshPlayerDropdown()
end)

Players.PlayerAdded:Connect(function()
    -- refresh dropdown when someone joins
    refreshPlayerDropdown()
end)

-- helper to create drawing objects safely
local function createLineIfMissing(tbl, key, thickness, color)
    if not tbl[key] or tbl[key] == nil then
        local line = Drawing.new("Line")
        line.Thickness = thickness or 2
        line.Color = color or Color3.fromRGB(255,255,255)
        line.Visible = false
        tbl[key] = line
    end
end

-- ensure initial dropdown population
refreshPlayerDropdown()

-- ======================================================
-- MAIN LOOP (RenderStepped)
-- ======================================================
RunService.RenderStepped:Connect(function()
    if not camera then camera = workspace.CurrentCamera end
    local screenCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    FOVCircle.Position = screenCenter
    FOVCircle.Radius = FOVRadius

    -- Highlight ESP
    if HighlightESPEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
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
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                local hl = plr.Character:FindFirstChild("Highlight")
                if hl then hl:Destroy() end
            end
        end
    end

    -- ESP Loop (Name, Health, Tracer)
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")

            if not DrawingESP[plr] then DrawingESP[plr] = {} end
            local data = DrawingESP[plr]

            if not head or not hum or hum.Health <= 1 then
                if data.Name then data.Name.Visible = false end
                if data.Health then data.Health.Visible = false end
                if data.HealthBG then data.HealthBG.Visible = false end
                if data.Tracer then data.Tracer.Visible = false end
            else
                local showESP = true
                if TeamCheck and plr.Team == LocalPlayer.Team then
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

                    -- Tracer (separate object)
                    if tracerEnabled and head then
                        createLineIfMissing(data, "Tracer", 1, Color3.fromRGB(255,0,255))
                        local pos, vis = camera:WorldToViewportPoint(head.Position)
                        if vis then
                            data.Tracer.From = Vector2.new(screenCenter.X, camera.ViewportSize.Y) -- from bottom of screen
                            data.Tracer.To = Vector2.new(pos.X, pos.Y)
                            data.Tracer.Visible = true
                        else
                            data.Tracer.Visible = false
                        end
                    elseif data.Tracer then
                        data.Tracer.Visible = false
                    end
                else
                    if data.Name then data.Name.Visible = false end
                    if data.Health then data.Health.Visible = false end
                    if data.HealthBG then data.HealthBG.Visible = false end
                    if data.Tracer then data.Tracer.Visible = false end
                end
            end
        end
    end

    -- Aim Lock + WallCheck
    if AimLockEnabled then
        local nearestPlayer
        local nearestDistance = math.huge

        for _,plr in pairs(Players:GetPlayers()) do
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
end)

-- ======================================================
-- MISC LOOP (Stepped) - Movement / Collect placeholders
-- ======================================================
RunService.Stepped:Connect(function()
    local plr = LocalPlayer
    if plr and plr.Character then
        if noclipEnabled then
            for _, part in pairs(plr.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end

        if noFallEnabled then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.FloorMaterial == Enum.Material.Air and hum.Health > 0 then
                hum:ChangeState(Enum.HumanoidStateType.Landed)
            end
        end

        if autoCollectEnabled then
            -- placeholder: implement per-game
        end
        if instantCollectEnabled then
            -- placeholder: implement per-game
        end
    end
end)
