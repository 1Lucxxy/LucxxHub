-- // Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local vim = game:GetService("VirtualInputManager")

-- // Window
local Window = Rayfield:CreateWindow({
    Name = "Lucxx Hub V3",
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
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
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
    CurrentValue = Workspace.Gravity,
    Callback = function(Value) Workspace.Gravity = Value end,
})

PlayerTab:CreateSlider({
    Name = "Max Camera Zoom",
    Range = {0,1000},
    Increment = 10,
    CurrentValue = 128,
    Callback = function(Value) LocalPlayer.CameraMaxZoomDistance = Value end,
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
local AimDistance = 300 -- default max aim distance

local camera = Workspace.CurrentCamera
local screenCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

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
    Range = {50,300},
    Increment = 1,
    CurrentValue = FOVRadius,
    Callback = function(Value)
        FOVRadius = Value
        FOVCircle.Radius = Value
    end
})

CombatTab:CreateSlider({
    Name = "AimLock Distance",
    Range = {50,1000},
    Increment = 10,
    CurrentValue = AimDistance,
    Callback = function(Value) AimDistance = Value end
})

CombatTab:CreateToggle({Name="Team Check", CurrentValue=false, Callback=function(Value) TeamCheck = Value end})
CombatTab:CreateToggle({Name="Aim Lock", CurrentValue=false, Callback=function(Value) AimLockEnabled=Value; FOVCircle.Visible=Value end})
CombatTab:CreateToggle({Name="Wall Check", CurrentValue=false, Callback=function(Value) WallCheck=Value end})
CombatTab:CreateToggle({Name="Tracer", CurrentValue=false, Callback=function(Value) TracerEnabled=Value end})
CombatTab:CreateToggle({Name="Wallbang", CurrentValue=false, Callback=function(Value) WallbangEnabled=Value end})

-- ======================================================
-- VISUAL TAB
-- ======================================================
local HighlightESPEnabled = false
local ESPEnabled = false
local HealthESPEnabled = false
local ItemESPEnabled = false
local DrawingESP = {}

VisualTab:CreateToggle({Name="Player Highlight", CurrentValue=false, Callback=function(Value) HighlightESPEnabled=Value end})
VisualTab:CreateToggle({Name="Name ESP", CurrentValue=false, Callback=function(Value) ESPEnabled=Value end})
VisualTab:CreateToggle({Name="Healthbar ESP", CurrentValue=false, Callback=function(Value) HealthESPEnabled=Value end})
VisualTab:CreateToggle({Name="Item ESP", CurrentValue=false, Callback=function(Value) ItemESPEnabled=Value end})

-- ======================================================
-- MISC TAB
-- ======================================================
local noclipEnabled = false
local antiAFKEnabled = false
local noFallEnabled = false
local freeCamEnabled = false
local instantCollectEnabled = false
local autoCollectEnabled = false
local Spectating = nil
local macroGui = nil

-- NoClip
MiscTab:CreateToggle({Name="NoClip", CurrentValue=false, Callback=function(Value) noclipEnabled=Value end})

-- AntiAFK
MiscTab:CreateToggle({Name="Anti AFK", CurrentValue=false, Callback=function(Value)
    antiAFKEnabled = Value
    if Value then
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0),camera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0),camera.CFrame)
        end)
    end
end})

-- No Fall Damage
MiscTab:CreateToggle({Name="No Fall Damage", CurrentValue=false, Callback=function(Value) noFallEnabled=Value end})

-- FreeCam
local freeCamConn
local freeCamSpeed = 2
MiscTab:CreateToggle({Name="FreeCam", CurrentValue=false, Callback=function(Value)
    freeCamEnabled = Value
    local cam = Workspace.CurrentCamera
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
        if freeCamConn then freeCamConn:Disconnect() freeCamConn=nil end
        cam.CameraType = Enum.CameraType.Custom
        cam.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end
end})

-- Spectate Dropdown
local PlayerListDropdown = MiscTab:CreateDropdown({Name="Spectate Player", Options={}, CurrentOption=nil, MultiSelect=false, Callback=function(option)
    local target = Players:FindFirstChild(option)
    if target and target.Character then
        Spectating = target
        Workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
    end
end})

local function refreshPlayerDropdown()
    local names = {}
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LocalPlayer then table.insert(names, plr.Name) end
    end
    pcall(function()
        if PlayerListDropdown.SetOptions then PlayerListDropdown:SetOptions(names) end
    end)
end

MiscTab:CreateButton({Name="Refresh Player List", Callback=function() refreshPlayerDropdown() end})
MiscTab:CreateButton({Name="Stop Spectating", Callback=function()
    Spectating=nil
    if LocalPlayer.Character then Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid") end
end})

-- Macro Buttons
MiscTab:CreateToggle({Name="Macro Buttons", CurrentValue=false, Callback=function(state)
    if state then
        macroGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
        macroGui.ResetOnSpawn=false
        -- Tombol 1 & 2 setup omitted (reuse previous macro code)
    else
        if macroGui then macroGui:Destroy(); macroGui=nil end
    end
end})

-- ======================================================
-- MAIN LOOP
-- ======================================================
RunService.RenderStepped:Connect(function()
    screenCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    FOVCircle.Position = screenCenter

    -- Player Highlight
    for _,plr in pairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and plr.Character then
            local hl = plr.Character:FindFirstChild("Highlight")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local showHighlight = true
            if TeamCheck and plr.Team==LocalPlayer.Team then showHighlight=false end
            if HighlightESPEnabled and showHighlight and hum and hum.Health>0 then
                if not hl then hl = Instance.new("Highlight", plr.Character); hl.FillTransparency=1; hl.OutlineColor=Color3.fromRGB(0,255,0) else hl.OutlineColor=Color3.fromRGB(0,255,0) end
            elseif hl then hl:Destroy() end
        end
    end

    -- ESP Loop (Name, Health, Item ESP, Tracer)
    for _,plr in pairs(Players:GetPlayers()) do
        if plr~=LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local head = plr.Character:FindFirstChild("Head")
            if not DrawingESP[plr] then DrawingESP[plr]={} end
            local data = DrawingESP[plr]
            if not head or not hum or hum.Health<=1 then
                if data.Name then data.Name.Visible=false end
                if data.Health then data.Health.Visible=false end
                if data.HealthBG then data.HealthBG.Visible=false end
                if data.Tracer then data.Tracer.Visible=false end
                continue
            end
            local showESP=true
            if TeamCheck and plr.Team==LocalPlayer.Team
