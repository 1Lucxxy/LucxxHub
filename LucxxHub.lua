-- // Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- // Window
local Window = Rayfield:CreateWindow({
    Name = "Universal Hub",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by ChatGPT",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UniversalHub",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false
})

-- // Tabs
local PlayerTab = Window:CreateTab("Player", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)

-- ======================================================
-- PLAYER SETTINGS
-- ======================================================

-- WalkSpeed
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16,300},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Callback = function(Value)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Value end
    end,
})

-- JumpPower
PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50,200},
    Increment = 1,
    Suffix = "JP",
    CurrentValue = 50,
    Callback = function(Value)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = Value end
    end,
})

-- Gravity
PlayerTab:CreateSlider({
    Name = "Gravity",
    Range = {0,500},
    Increment = 1,
    Suffix = "G",
    CurrentValue = workspace.Gravity,
    Callback = function(Value)
        workspace.Gravity = Value
    end,
})

-- Max Zoom
PlayerTab:CreateSlider({
    Name = "Max Camera Zoom",
    Range = {0,1000},
    Increment = 10,
    CurrentValue = 128,
    Callback = function(Value)
        game.Players.LocalPlayer.CameraMaxZoomDistance = Value
    end,
})

-- Fly Button
PlayerTab:CreateButton({
    Name = "Fly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end,
})

-- ======================================================
-- VISUAL SETTINGS
-- ======================================================

-- Toggle Highlight
local HighlightESPEnabled = false
VisualTab:CreateToggle({
    Name = "Player Highlight",
    CurrentValue = false,
    Callback = function(Value)
        HighlightESPEnabled = Value
        if not Value then
            for _,plr in pairs(game.Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("Highlight") then
                    plr.Character.Highlight:Destroy()
                end
            end
        else
            for _,plr in pairs(game.Players:GetPlayers()) do
                if plr ~= game.Players.LocalPlayer and plr.Character and not plr.Character:FindFirstChild("Highlight") then
                    local hl = Instance.new("Highlight", plr.Character)
                    hl.FillTransparency = 1
                    hl.OutlineColor = Color3.fromRGB(0,255,0)
                end
            end
        end
    end,
})

-- Name ESP + Healthbar ala Roblox
local DrawingESP = {}
local ESPEnabled = false
local HealthESPEnabled = false

VisualTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = false,
    Callback = function(Value) ESPEnabled = Value end,
})

VisualTab:CreateToggle({
    Name = "Healthbar ESP (Rounded Slim)",
    CurrentValue = false,
    Callback = function(Value) HealthESPEnabled = Value end,
})

-- Loop ESP
game:GetService("RunService").RenderStepped:Connect(function()
    for _,plr in pairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")

            if not DrawingESP[plr] then DrawingESP[plr] = {} end
            local data = DrawingESP[plr]

            -- Name ESP
            if ESPEnabled and head then
                if not data.Name then
                    data.Name = Drawing.new("Text")
                    data.Name.Size = 16
                    data.Name.Center = true
                    data.Name.Outline = true
                    data.Name.Color = Color3.fromRGB(255,255,255)
                end
                local pos, vis = workspace.CurrentCamera:WorldToViewportPoint(head.Position+Vector3.new(0,2,0))
                if vis then
                    data.Name.Text = plr.Name
                    data.Name.Position = Vector2.new(pos.X, pos.Y)
                    data.Name.Visible = true
                else
                    data.Name.Visible = false
                end
            elseif data.Name then
                data.Name.Visible = false
            end

            -- Healthbar rounded tipis
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
                local headPos, vis = workspace.CurrentCamera:WorldToViewportPoint(head.Position+Vector3.new(0,2.5,0))
                if vis then
                    local barW, barH = 70, 4 -- tipis
                    local x, y = headPos.X - barW/2, headPos.Y - 15

                    local function makeQuad(obj, px, py, w, h)
                        obj.PointA = Vector2.new(px, py)
                        obj.PointB = Vector2.new(px+w, py)
                        obj.PointC = Vector2.new(px+w, py+h)
                        obj.PointD = Vector2.new(px, py+h)
                    end

                    -- background
                    makeQuad(data.HealthBG, x, y, barW, barH)
                    data.HealthBG.Visible = true

                    -- isi HP
                    local hpW = barW * math.clamp(hp,0,1)
                    makeQuad(data.Health, x, y, hpW, barH)
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
        end
    end
end)
