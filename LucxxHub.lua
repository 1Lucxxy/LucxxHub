--// Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Window
local Window = Rayfield:CreateWindow({
   Name = "Universal Hub",
   LoadingTitle = "Rayfield UI",
   LoadingSubtitle = "by kamu",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "UniversalConfig"
   },
   KeySystem = false
})

------------------------------------------------
--// PLAYER TAB
------------------------------------------------
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- Variables
local SelectedSpeed, SelectedJump, SelectedGravity, SelectedZoom = 16, 50, 196.2, 128
local Running = true

-- WalkSpeed
PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      SelectedSpeed = Value
      local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
      if hum then hum.WalkSpeed = Value end
   end,
})

-- JumpPower
PlayerTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 200},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(Value)
      SelectedJump = Value
      local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
      if hum then hum.UseJumpPower, hum.JumpPower = true, Value end
   end,
})

-- Gravity
PlayerTab:CreateSlider({
   Name = "Gravity",
   Range = {0, 500},
   Increment = 1,
   CurrentValue = 196,
   Callback = function(Value)
      SelectedGravity = Value
      workspace.Gravity = Value
   end,
})

-- Zoom
PlayerTab:CreateSlider({
   Name = "Max Zoom",
   Range = {0, 1000},
   Increment = 10,
   CurrentValue = 128,
   Callback = function(Value)
      SelectedZoom = Value
      game.Players.LocalPlayer.CameraMaxZoomDistance = Value
   end,
})

-- Fly
PlayerTab:CreateButton({
   Name = "Fly",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
   end,
})

-- Anti-reset loop
task.spawn(function()
   while Running do
      task.wait(0.2)
      local plr, hum = game.Players.LocalPlayer, nil
      if plr and plr.Character then
         hum = plr.Character:FindFirstChildOfClass("Humanoid")
      end
      if hum then
         hum.WalkSpeed, hum.JumpPower, hum.UseJumpPower = SelectedSpeed, SelectedJump, true
      end
      workspace.Gravity = SelectedGravity
      plr.CameraMaxZoomDistance = SelectedZoom
   end
end)

------------------------------------------------
--// VISUAL TAB (ESP)
------------------------------------------------
local VisualTab = Window:CreateTab("Visual", 4483362458)

-- ESP Variables
local HighlightESPEnabled, HealthESPEnabled, NameESPEnabled = false, false, false
local HighlightColor = Color3.fromRGB(0,255,0)
local ESPData = {}

-- Buat Highlight
local function createESP(plr)
    if ESPData[plr] then return end
    local hl = Instance.new("Highlight")
    hl.FillColor, hl.FillTransparency = HighlightColor, 0.5
    hl.OutlineColor, hl.OutlineTransparency = Color3.fromRGB(255,255,255), 0
    hl.Enabled = false
    if plr.Character then hl.Parent = plr.Character end
    ESPData[plr] = {Highlight = hl, Health = nil, Name = nil}
end

-- Update ESP
game:GetService("RunService").RenderStepped:Connect(function()
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer then
            if not ESPData[plr] then createESP(plr) end
            local data = ESPData[plr]
            if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then continue end
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")

            -- Highlight
            if data.Highlight then
                data.Highlight.Adornee = plr.Character
                data.Highlight.FillColor = HighlightColor
                data.Highlight.Enabled = HighlightESPEnabled
            end

            -- Nama Player
            if NameESPEnabled and head then
                if not data.Name then
                    data.Name = Drawing.new("Text")
                    data.Name.Size, data.Name.Center, data.Name.Outline = 15,true,true
                    data.Name.Color, data.Name.Text = Color3.fromRGB(255,255,255), plr.Name
                end
                local headPos, vis = workspace.CurrentCamera:WorldToViewportPoint(head.Position+Vector3.new(0,2,0))
                data.Name.Visible = vis
                if vis then data.Name.Position = Vector2.new(headPos.X, headPos.Y-20) end
            elseif data.Name then
                data.Name.Visible = false
            end

            -- Healthbar di atas kepala
            if HealthESPEnabled and hum and head then
                if not data.Health then
                    data.Health = Drawing.new("Square")
                    data.Health.Filled = true
                end
                local hp = hum.Health / hum.MaxHealth
                local headPos, vis = workspace.CurrentCamera:WorldToViewportPoint(head.Position+Vector3.new(0,2,0))
                if vis then
                    local barW, barH = 50, 5 -- panjang dan tebal healthbar
                    local x, y = headPos.X - barW/2, headPos.Y - 8
                    data.Health.Position = Vector2.new(x, y)
                    data.Health.Size = Vector2.new(barW * hp, barH)
                    data.Health.Color = hp > 0.5 and Color3.fromRGB(0,255,0) or hp > 0.2 and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,0,0)
                    data.Health.Visible = true
                else
                    data.Health.Visible = false
                end
            elseif data.Health then
                data.Health.Visible = false
            end
        end
    end
end)

-- Player baru
game.Players.PlayerAdded:Connect(createESP)

-- Toggles UI
VisualTab:CreateToggle({
    Name = "Highlight Players",
    CurrentValue = false,
    Callback = function(v) HighlightESPEnabled = v end,
})
VisualTab:CreateColorPicker({
    Name = "Highlight Color",
    Color = Color3.fromRGB(0,255,0),
    Callback = function(v) Hi
