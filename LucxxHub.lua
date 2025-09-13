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
--// VISUAL TAB (Highlight ESP)
------------------------------------------------
local VisualTab = Window:CreateTab("Visual", 4483362458)

-- ESP Variables
local HighlightESPEnabled = false
local HealthESPEnabled = false
local NameESPEnabled = false
local HighlightColor = Color3.fromRGB(0,255,0)
local ESPData = {}

-- Buat Highlight untuk player
local function createHighlight(plr)
    if ESPData[plr] then return end
    local hl = Instance.new("Highlight")
    hl.FillColor = HighlightColor
    hl.FillTransparency = 0.5
    hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.OutlineTransparency = 0
    hl.Enabled = false
    if plr.Character then
        hl.Parent = plr.Character
    end
    ESPData[plr] = {Highlight = hl, Health = nil, Name = nil}
end

-- Update ESP tiap frame
game:GetService("RunService").RenderStepped:Connect(function()
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer then
            if not ESPData[plr] then createHi
