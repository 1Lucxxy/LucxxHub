-- // Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local LocalPlayer = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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
local MiscTab   = Window:CreateTab("Miscellaneous", 4483362458)

-- ======================================================
-- PLAYER TAB
-- ======================================================
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16,300},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Value end
    end,
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50,200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(Value)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
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
        LocalPlayer.CameraMaxZoomDistance = Value
    end,
})

PlayerTab:CreateButton({
    Name = "Fly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end,
})

-- ======================================================
-- COMBAT TAB
-- ======================================================
local TeamCheck = false
local AimLockEnabled = false
local WallCheck = false
local TracerEnabled = false
local WallbangEnabled = false
local FOVRadius = 100
local camera = workspace.CurrentCamera

-- POV Circle
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
    Callback = function(Value) TeamCheck = Value end
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
    Callback = function(Value) WallCheck = Value end
})

CombatTab:CreateToggle({
    Name = "Tracer",
    CurrentValue = false,
    Callback = function(Value) TracerEnabled = Value end
})

CombatTab:CreateToggle({
    Name = "Wallbang",
    CurrentValue = false,
    Callback = function(Value) WallbangEnabled = Value end
})

-- ======================================================
-- VISUAL TAB
-- ======================================================
local HighlightESPEnabled = false
local NameESPEnabled = false
local HealthESPEnabled = false
local DrawingESP = {}

VisualTab:CreateToggle({
    Name = "Player Highlight",
    CurrentValue = false,
    Callback = function(Value) HighlightESPEnabled = Value end
})

VisualTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = false,
    Callback = function(Value) NameESPEnabled = Value end
})

VisualTab:CreateToggle({
    Name = "Healthbar ESP",
    CurrentValue = false,
    Callback = function(Value) HealthESPEnabled = Value end
})

-- ======================================================
-- MISC TAB
-- ======================================================
local freeCamEnabled = false
local Spectating = nil
local macroGui = nil

-- FreeCam
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
            local freeCamConn
            freeCamConn = RunService.RenderStepped:Connect(function(dt)
                local move = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + cam.CFrame.UpVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - cam.CFrame.UpVector end
                pos = pos + move * freeCamSpeed * (dt*60)
                cam.CFrame = pos
            end)
            -- Simpan conn agar bisa disconnect
            MiscTab:CreateButton({Name="Stop FreeCam", Callback=function()
                freeCamConn:Disconnect()
                cam.CameraType = Enum.CameraType.Custom
                cam.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end})
        else
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    end
})

-- ======================================================
-- PLAYER ESP & Combat Loop
-- ======================================================
RunService.RenderStepped:Connect(function()
    local screenCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    FOVCircle.Position = screenCenter

    -- Highlight ESP
    if HighlightESPEnabled then
        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local hl = plr.Character:FindFirstChild("Highlight")
                local show = hum and hum.Health>0 and (not TeamCheck or plr.Team~=LocalPlayer.Team)
                if show then
                    if not hl then
                        hl = Instance.new("Highlight", plr.Character)
                        hl.FillTransparency = 1
                        hl.OutlineColor = Color3.fromRGB(0,255,0)
                    end
                else
                    if hl then hl:Destroy() end
                end
            end
        end
    end

    -- Name + Health ESP
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")
            if not DrawingESP[plr] then DrawingESP[plr] = {} end
            local data = DrawingESP[plr]

            if not head or not hum or hum.Health<=0 then
                if data.Name then data.Name.Visible=false end
                if data.Health then data.Health.Visible=false end
            else
                if NameESPEnabled then
                    if not data.Name then
                        data.Name = Drawing.new("Text")
                        data.Name.Size=16
                        data.Name.Center=true
                        data.Name.Outline=true
                        data.Name.Color=Color3.fromRGB(255,255,255)
                    end
                    local pos, vis = camera:WorldToViewportPoint(head.Position+Vector3.new(0,2,0))
                    data.Name.Visible=vis
                    if vis then data.Name.Text=plr.Name; data.Name.Position=Vector2.new(pos.X,pos.Y) end
                elseif data.Name then data.Name.Visible=false end

                if HealthESPEnabled then
                    if not data.Health then
                        data.Health = Drawing.new("Quad")
                        data.Health.Filled=true
                        data.Health.Color=Color3.fromRGB(0,255,0)
                    end
                    local hp = hum.Health/hum.MaxHealth
                    local pos, vis = camera:WorldToViewportPoint(head.Position+Vector3.new(0,2.5,0))
                    if vis then
                        local barW,barH = 70,4
                        local x,y = pos.X-barW/2,pos.Y-15
                        data.Health.PointA = Vector2.new(x,y)
                        data.Health.PointB = Vector2.new(x+barW*hp,y)
                        data.Health.PointC = Vector2.new(x+barW*hp,y+barH)
                        data.Health.PointD = Vector2.new(x,y+barH)
                        data.Health.Visible=true
                    else
                        data.Health.Visible=false
                    end
                elseif data.Health then data.Health.Visible=false end
            end
        end
    end
end)
