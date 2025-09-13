--// Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Buat Window
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

--// Tab Movement
local MovementTab = Window:CreateTab("Player", 4483362458)
local MovementSection = MovementTab:CreateSection("Movement")

-- Variabel Movement
local SelectedSpeed = 16
local SelectedJump = 50
local SelectedGravity = 196.2
local SelectedZoom = 128
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

-- Slider Max Zoom
MovementTab:CreateSlider({
   Name = "Max Zoom",
   Range = {0, 1000},
   Increment = 1,
   CurrentValue = 128,
   Callback = function(Value)
      SelectedZoom = Value
      game.Players.LocalPlayer.CameraMaxZoomDistance = SelectedZoom
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
         if Player.CameraMaxZoomDistance ~= SelectedZoom then
            Player.CameraMaxZoomDistance = SelectedZoom
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
local VisualSection = VisualTab:CreateSection("ESP")

-- Variabel Highlight
local HighlightEnabled = false

-- Fungsi pasang Highlight
local function addHighlight(plr)
   if plr ~= game.Players.LocalPlayer and plr.Character then
      if not plr.Character:FindFirstChild("Highlight") then
         local hl = Instance.new("Highlight")
         hl.Name = "Highlight"
         hl.FillColor = Color3.fromRGB(255, 0, 0)
         hl.OutlineColor = Color3.fromRGB(255, 255, 255)
         hl.Adornee = plr.Character
         hl.Parent = plr.Character
      end
   end
end

-- Fungsi hapus Highlight
local function removeHighlight(plr)
   if plr.Character and plr.Character:FindFirstChild("Highlight") then
      plr.Character.Highlight:Destroy()
   end
end

-- Toggle Player Highlight
VisualTab:CreateToggle({
   Name = "Player Highlight",
   CurrentValue = false,
   Flag = "PlayerHighlightToggle",
   Callback = function(Value)
      HighlightEnabled = Value
      if HighlightEnabled then
         -- Tambahin highlight ke semua player
         for _, plr in pairs(game.Players:GetPlayers()) do
            addHighlight(plr)
         end
         -- Kalau ada player baru join
         game.Players.PlayerAdded:Connect(function(plr)
            plr.CharacterAdded:Connect(function()
               if HighlightEnabled then
                  task.wait(1)
                  addHighlight(plr)
               end
            end)
         end)
      else
         -- Hapus highlight dari semua player
         for _, plr in pairs(game.Players:GetPlayers()) do
            removeHighlight(plr)
         end
      end
   end,
})
