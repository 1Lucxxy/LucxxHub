--// Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Buat Window
local Window = Rayfield:CreateWindow({
   Name = "Lucxx Hub",
   LoadingTitle = "Lucxx UI",
   LoadingSubtitle = "by Lucxxy",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "LucxxConfig"
   },
   KeySystem = false
})

------------------------------------------------------
--// Tab Player
local PlayerTab = Window:CreateTab("Player", 4483362458)
local PlayerSection = PlayerTab:CreateSection("Movement")

-- Variabel Movement
local SelectedSpeed = 16
local SelectedJump = 50
local SelectedGravity = 196.2
local Running = true

-- WalkSpeed
PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      SelectedSpeed = Value
      local plr = game.Players.LocalPlayer
      local char = plr.Character or plr.CharacterAdded:Wait()
      local hum = char:FindFirstChildOfClass("Humanoid")
      if hum then hum.WalkSpeed = SelectedSpeed end
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
      local plr = game.Players.LocalPlayer
      local char = plr.Character or plr.CharacterAdded:Wait()
      local hum = char:FindFirstChildOfClass("Humanoid")
      if hum then
         hum.UseJumpPower = true
         hum.JumpPower = SelectedJump
      end
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
      workspace.Gravity = SelectedGravity
   end,
})

-- Button Fly
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
   end
end)

------------------------------------------------------
--// Tab Visual
local VisualTab = Window:CreateTab("Visual", 4483362458)
local VisualSection = VisualTab:CreateSection("ESP & Camera")

-- Variabel ESP
local ESPEnabled = false
local BoxColor = Color3.fromRGB(0, 255, 0)
local Drawings = {}

-- Hapus ESP
local function removeESP(plr)
    if Drawings[plr] then
        for _, obj in pairs(Drawings[plr]) do
            if obj.Remove then obj:Remove() end
        end
        Drawings[plr] = nil
    end
end

-- Tambah ESP
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
        if ESPEnabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")

            if humanoid and head then
                local pos, vis = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                if vis then
                    local scale = 1 / (pos.Z * 0.003) * 100
                    local width, height = 30 * scale, 50 * scale

                    -- Box ESP
                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                    box.Color = BoxColor
                    box.Visible = true

                    -- Healthbar vertikal kiri box
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

                    -- Nama di atas kepala
                    local headPos, vis2 = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
                    if vis2 then
                        nameText.Position = Vector2.new(headPos.X, headPos.Y - 15)
                        nameText.Visible = true
                    else
                        nameText.Visible = false
                    end
                else
                    box.Visible = false
                    healthBar.Visible = false
                    nameText.Visible = false
                end
            else
                box.Visible = false
                healthBar.Visible = false
                nameText.Visible = false
            end
        else
            box.Visible = false
            healthBar.Visible = false
            nameText.Visible = false
        end
    end)
end

-- Toggle ESP
VisualTab:CreateToggle({
    Name = "ESP (Box + Name + Health)",
    CurrentValue = false,
    Callback = function(Value)
        ESPEnabled = Value
        if ESPEnabled then
            for _, plr in pairs(game.Players:GetPlayers()) do
                if not Drawings[plr] then
                    addESP(plr)
                end
            end
            game.Players.PlayerAdded:Connect(function(plr)
                addESP(plr)
            end)
            game.Players.PlayerRemoving:Connect(function(plr)
                removeESP(plr)
            end)
        else
            for _, plr in pairs(game.Players:GetPlayers()) do
                removeESP(plr)
            end
        end
    end,
})

-- Color Picker ESP Box
VisualTab:CreateColorPicker({
    Name = "Box Color",
    Color = Color3.fromRGB(0,255,0),
    Callback = function(Value)
        BoxColor = Value
    end
})

-- Max Zoom
VisualTab:CreateSlider({
   Name = "Max Zoom",
   Range = {0, 1000},
   Increment = 1,
   CurrentValue = 128,
   Callback = function(Value)
      game.Players.LocalPlayer.CameraMaxZoomDistance = Value
   end,
})
