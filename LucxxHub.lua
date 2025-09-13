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
--// Tab Movement
local MovementTab = Window:CreateTab("Player", 4483362458)
local MovementSection = MovementTab:CreateSection("Movement")

-- Variabel Movement
local SelectedSpeed = 16
local SelectedJump = 50
local SelectedGravity = 196.2
local Running = true

-- Slider WalkSpeed
MovementTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      SelectedSpeed = Value
      local Player = game.Players.LocalPlayer
      local Character = Player.Character or Player.CharacterAdded:Wait()
      local Humanoid = Character:FindFirstChildOfClass("Humanoid")
      if Humanoid then Humanoid.WalkSpeed = SelectedSpeed end
   end,
})

-- Slider JumpPower
MovementTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 200},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(Value)
      SelectedJump = Value
      local Player = game.Players.LocalPlayer
      local Character = Player.Character or Player.CharacterAdded:Wait()
      local Humanoid = Character:FindFirstChildOfClass("Humanoid")
      if Humanoid then
         Humanoid.UseJumpPower = true
         Humanoid.JumpPower = SelectedJump
      end
   end,
})

-- Slider Gravity
MovementTab:CreateSlider({
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
MovementTab:CreateButton({
   Name = "Fly",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
   end,
})

-- Anti-reset loop
task.spawn(function()
   while Running do
      task.wait(0.2)
      local Player = game.Players.LocalPlayer
      if Player and Player.Character then
         local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
         if Humanoid then
            if Humanoid.WalkSpeed ~= SelectedSpeed then Humanoid.WalkSpeed = SelectedSpeed end
            if Humanoid.JumpPower ~= SelectedJump then
               Humanoid.UseJumpPower = true
               Humanoid.JumpPower = SelectedJump
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

-- Variabel Visual
local SelectedZoom = 128 -- default
local ESPEnabled = false
local BoxColor = Color3.fromRGB(0, 255, 0)

-- Slider Max Zoom
VisualTab:CreateSlider({
   Name = "Max Zoom",
   Range = {0, 1000},
   Increment = 1,
   CurrentValue = 128,
   Callback = function(Value)
      SelectedZoom = Value
      local Player = game.Players.LocalPlayer
      Player.CameraMaxZoomDistance = SelectedZoom
   end,
})

-- Fungsi bikin ESP Billboard
local function createESP(plr)
    if plr == game.Players.LocalPlayer then return end
    task.spawn(function()
        local char = plr.Character or plr.CharacterAdded:Wait()
        local head = char:WaitForChild("Head", 5)
        if head and not head:FindFirstChild("ESPBillboard") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESPBillboard"
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = head

            -- Background box
            local box = Instance.new("Frame")
            box.Size = UDim2.new(1, 0, 1, 0)
            box.BackgroundTransparency = 0.5
            box.BackgroundColor3 = BoxColor
            box.BorderSizePixel = 2
            box.Parent = billboard

            -- Nama Player
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = plr.Name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextStrokeTransparency = 0
            nameLabel.Font = Enum.Font.SourceSansBold
            nameLabel.TextScaled = true
            nameLabel.Parent = billboard

            -- Health Bar
            local healthBar = Instance.new("Frame")
            healthBar.Size = UDim2.new(1, 0, 0.2, 0)
            healthBar.Position = UDim2.new(0, 0, 0.8, 0)
            healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            healthBar.BorderSizePixel = 0
            healthBar.Parent = billboard

            -- Update darah realtime
            local humanoid = char:WaitForChild("Humanoid")
            humanoid.HealthChanged:Connect(function(hp)
                local maxHp = humanoid.MaxHealth
                healthBar.Size = UDim2.new(hp / maxHp, 0, 0.2, 0)
                if hp / maxHp > 0.5 then
                    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                elseif hp / maxHp > 0.2 then
                    healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                else
                    healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                end
            end)
        end
    end)
end

-- Toggle ESP
VisualTab:CreateToggle({
   Name = "ESP (Name + HP + Box)",
   CurrentValue = false,
   Callback = function(Value)
      ESPEnabled = Value
      if ESPEnabled then
         for _, plr in pairs(game.Players:GetPlayers()) do
            if plr.Character then
                createESP(plr)
            end
            plr.CharacterAdded:Connect(function()
                if ESPEnabled then
                    task.wait(1)
                    createESP(plr)
                end
            end)
         end
         game.Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
                if ESPEnabled then
                    task.wait(1)
                    createESP(plr)
                end
            end)
         end)
      else
         for _, plr in pairs(game.Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                if head:FindFirstChild("ESPBillboard") then
                    head.ESPBillboard:Destroy()
                end
            end
         end
      end
   end,
})

-- Color Picker untuk Box ESP
VisualTab:CreateColorPicker({
    Name = "Box Color",
    Color = Color3.fromRGB(0,255,0),
    Callback = function(Value)
        BoxColor = Value
        -- Update warna semua box aktif
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                if head:FindFirstChild("ESPBillboard") then
                    head.ESPBillboard.Frame.BackgroundColor3 = BoxColor
                end
            end
        end
    end
})

-- Anti-reset untuk Max Zoom
task.spawn(function()
   while true do
      task.wait(0.2)
      local Player = game.Players.LocalPlayer
      if Player.CameraMaxZoomDistance ~= SelectedZoom then
         Player.CameraMaxZoomDistance = SelectedZoom
      end
   end
end)
