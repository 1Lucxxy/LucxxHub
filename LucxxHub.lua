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
    KeySystem = false
})

-- // Tabs
local PlayerTab = Window:CreateTab("Player", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)

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
-- VISUAL SETTINGS
-- ======================================================
local HighlightESPEnabled = false
local DrawingESP = {}
local ESPEnabled = false
local HealthESPEnabled = false
local LineESPEnabled = false

VisualTab:CreateToggle({
    Name = "Player Highlight",
    CurrentValue = false,
    Callback = function(Value)
        HighlightESPEnabled = Value
        for _,plr in pairs(game.Players:GetPlayers()) do
            if plr.Character then
                if Value and not plr.Character:FindFirstChild("Highlight") then
                    local hl = Instance.new("Highlight", plr.Character)
                    hl.FillTransparency = 1
                    hl.OutlineColor = Color3.fromRGB(0,255,0)
                elseif not Value and plr.Character:FindFirstChild("Highlight") then
                    plr.Character.Highlight:Destroy()
                end
            end
        end
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
-- ESP LOOP (Healthbar tumpul & tipis)
-- ======================================================
game:GetService("RunService").RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    local screenCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

    for _,plr in pairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")
            if not DrawingESP[plr] then DrawingESP[plr] = {} end
            local data = DrawingESP[plr]

            -- NAME ESP
            if ESPEnabled and head then
                if not data.Name then
                    data.Name = Drawing.new("Text")
                    data.Name.Size = 16
                    data.Name.Center = true
                    data.Name.Outline = true
                    data.Name.Color = Color3.fromRGB(255,255,255)
                end
                local pos, vis = camera:WorldToViewportPoint(head.Position+Vector3.new(0,2,0))
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

            -- HEALTHBAR ESP (tumpul & tipis)
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
                    local barW, barH = 70, 4 -- tipis
                    local x, y = headPos.X - barW/2, headPos.Y - 15
                    local radius = 2 -- ujung tumpul

                    local function makeRoundedQuad(obj, px, py, w, h, r)
                        obj.PointA = Vector2.new(px+r, py)
                        obj.PointB = Vector2.new(px+w-r, py)
                        obj.PointC = Vector2.new(px+w-r, py+h)
                        obj.PointD = Vector2.new(px+r, py+h)
                    end

                    makeRoundedQuad(data.HealthBG, x, y, barW, barH, radius)
                    data.HealthBG.Visible = true

                    local hpW = barW * math.clamp(hp,0,1)
                    makeRoundedQuad(data.Health, x, y, hpW, barH, radius)
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

            -- LINE ESP
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
        end
    end
end)
