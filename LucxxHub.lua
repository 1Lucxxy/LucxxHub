--// Load Rayfield
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
local Section = PlayerTab:CreateSection("Movement")

-- Variables
local SelectedSpeed = 16
local SelectedJump = 50
local SelectedGravity = 196.2
local SelectedZoom = 128
local Running = true

-- WalkSpeed Slider
PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 300},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
      SelectedSpeed = Value
      local plr = game.Players.LocalPlayer
      local char = plr.Character or plr.CharacterAdded:Wait()
      local hum = char:FindFirstChildOfClass("Humanoid")
      if hum then hum.WalkSpeed = SelectedSpeed end
   end,
})

-- JumpPower Slider
PlayerTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 200},
   Increment = 1,
   Suffix = "Jump",
   CurrentValue = 50,
   Flag = "JumpPowerSlider",
   Callback = function(Value)
      SelectedJump = Value
      local plr = game.Players.LocalPlayer
      local char = plr.Character or plr.CharacterAdded:Wait()
      local hum = char:FindFirstChildOfClass("Humanoid")
      if hum then
         hum.UseJumpPower = true
         hum.JumpPower = SelectedJump
      end
   end,
})

-- Gravity Slider
PlayerTab:CreateSlider({
   Name = "Gravity",
   Range = {0, 500},
   Increment = 1,
   Suffix = "G",
   CurrentValue = 196,
   Flag = "GravitySlider",
   Callback = function(Value)
      SelectedGravity = Value
      workspace.Gravity = SelectedGravity
   end,
})

-- Max Zoom
PlayerTab:CreateSlider({
   Name = "Max Zoom",
   Range = {0, 1000},
   Increment = 10,
   Suffix = "Zoom",
   CurrentValue = 128,
   Flag = "ZoomSlider",
   Callback = function(Value)
      SelectedZoom = Value
      game.Players.LocalPlayer.CameraMaxZoomDistance = SelectedZoom
   end,
})

-- Fly Button
PlayerTab:CreateButton({
   Name = "Fly",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
   end,
})

-- Anti reset loop
task.spawn(function()
   while Running do
      task.wait(0.2)
      local plr = game.Players.LocalPlayer
      if plr and plr.Character then
         local hum = plr.Character:FindFirstChildOfClass("Humanoid")
         if hum then
            if hum.WalkSpeed ~= SelectedSpeed then hum.WalkSpeed = SelectedSpeed end
            if hum.JumpPower ~= SelectedJump then
               hum.UseJumpPower = true
               hum.JumpPower = SelectedJump
            end
         end
      end
      if workspace.Gravity ~= SelectedGravity then
         workspace.Gravity = SelectedGravity
      end
      if plr.CameraMaxZoomDistance ~= SelectedZoom then
         plr.CameraMaxZoomDistance = SelectedZoom
      end
   end
end)

------------------------------------------------
--// VISUAL TAB (ESP)
------------------------------------------------
local VisualTab = Window:CreateTab("Visual", 4483362458)

-- ESP Variables
local BoxESPEnabled = false
local HealthESPEnabled = false
local NameESPEnabled = false
local BoxColor = Color3.fromRGB(0,255,0)
local Drawings = {}

-- Remove ESP
local function removeESP(plr)
    if Drawings[plr] then
        for _, obj in pairs(Drawings[plr]) do
            if obj.Remove then obj:Remove() end
        end
        Drawings[plr] = nil
    end
end

-- Add ESP
local function addESP(plr)
    if plr == game.Players.LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = BoxColor
    box.Filled = false
    box.Visible = false

    local healthBar = Drawing.new("Square")
    healthBar.Thickness = 1
    healthBar.Filled = true
    healthBar.Visible = false

    local nameText = Drawing.new("Text")
    nameText.Size = 15
    nameText.Center = true
    nameText.Outline = true
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Visible = false
    nameText.Text = plr.Name

    Drawings[plr] = {box, healthBar, nameText}

    game:GetService("RunService").RenderStepped:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")

            if humanoid and head then
                local pos, vis = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                if vis then
                    local scale = 1 / (pos.Z * 0.003) * 100
                    local width, height = 30 * scale, 50 * scale

                    -- Box ESP
                    if BoxESPEnabled then
                        box.Size = Vector2.new(width, height)
                        box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                        box.Color = BoxColor
                        box.Visible = true
                    else
                        box.Visible = false
                    end

                    -- Healthbar (kiri box)
                    if HealthESPEnabled then
                        local hpPercent = humanoid.Health / humanoid.MaxHealth
                        local hbHeight = height * hpPercent
                        local hbWidth = 4
                        local hbX = pos.X - width / 2 - hbWidth - 2
                        local hbY = pos.Y + height / 2 - hbHeight

                        healthBar.Size = Vector2.new(hbWidth, hbHeight)
                        healthBar.Position = Vector2.new(hbX, hbY)

                        if hpPercent > 0.5 then
                            healthBar.Color = Color3.fromRGB(0, 255, 0)
                        elseif hpPercent > 0.2 then
                            healthBar.Color = Color3.fromRGB(255, 255, 0)
                        else
                            healthBar.Color = Color3.fromRGB(255, 0, 0)
                        end

                        healthBar.Visible = true
                    else
                        healthBar.Visible = false
                    end

                    -- Name di atas kepala
                    if NameESPEnabled then
                        local headPos, vis2 = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
                        if vis2 then
                            nameText.Position = Vector2.new(headPos.X, headPos.Y - 15)
                            nameText.Visible = true
                        else
                            nameText.Visible = false
                        end
                    else
                        nameText.Visible = false
                    end
                else
                    box.Visible = false
                    healthBar.Visible = false
                    nameText.Visible = false
                end
            end
        else
            box.Visible = false
            healthBar.Visible = false
            nameText.Visible = false
        end
    end)
end

-- Auto Apply ESP
for _, plr in pairs(game.Players:GetPlayers()) do
    addESP(plr)
end
game.Players.PlayerAdded:Connect(addESP)
game.Players.PlayerRemoving:Connect(removeESP)

-- UI Toggles
VisualTab:CreateToggle({
    Name = "ESP Box",
    CurrentValue = false,
    Callback = function(Value)
        BoxESPEnabled = Value
    end,
})

VisualTab:CreateColorPicker({
    Name = "Box Color",
    Color = Color3.fromRGB(0,255,0),
    Callback = function(Value)
        BoxColor = Value
    end
})

VisualTab:CreateToggle({
    Name = "ESP Healthbar",
    CurrentValue = false,
    Callback = function(Value)
        HealthESPEnabled = Value
    end,
})

VisualTab:CreateToggle({
    Name = "ESP Name",
    CurrentValue = false,
    Callback = function(Value)
        NameESPEnabled = Value
    end,
})
