-- // Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")

-- // Window
local Window = Rayfield:CreateWindow({
    Name = "Lucxx Hub V2",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by Lucxxy",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "LucxxHub",
        FileName = "Config"
    },
    Discord = {
        Enabled = false
    }
})

-- // Tabs
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local MiscTab = Window:CreateTab("Miscellaneous", 4483362458)

-- // ===== COMBAT TAB =====
-- Tracer
local tracerEnabled = false
local tracers = {}

local function createTracer(plr)
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.fromRGB(0, 255, 0)
    line.Thickness = 1.5
    tracers[plr] = line
end

local function removeTracer(plr)
    if tracers[plr] then
        tracers[plr]:Remove()
        tracers[plr] = nil
    end
end

RunService.RenderStepped:Connect(function()
    if tracerEnabled then
        for plr, line in pairs(tracers) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local root = plr.Character.HumanoidRootPart
                local pos, vis = Camera:WorldToViewportPoint(root.Position)
                if vis then
                    line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    else
        for _, line in pairs(tracers) do
            line.Visible = false
        end
    end
end)

CombatTab:CreateToggle({
    Name = "Tracer",
    CurrentValue = false,
    Callback = function(state)
        tracerEnabled = state
        if state then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    createTracer(plr)
                end
            end
            Players.PlayerAdded:Connect(function(plr)
                if plr ~= LocalPlayer then
                    createTracer(plr)
                end
            end)
            Players.PlayerRemoving:Connect(function(plr)
                removeTracer(plr)
            end)
        else
            for _, plr in ipairs(Players:GetPlayers()) do
                removeTracer(plr)
            end
        end
    end
})

-- Wallbang (dummy toggle)
CombatTab:CreateToggle({
    Name = "Wallbang",
    CurrentValue = false,
    Callback = function(state)
        -- Placeholder
    end
})

-- // ===== VISUAL TAB =====
-- Item ESP
local itemESPEnabled = false
local itemESPConnections = {}
local function clearItemESP()
    for _, conn in ipairs(itemESPConnections) do
        conn:Disconnect()
    end
    itemESPConnections = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Highlight") and v.Name == "ItemESP" then
            v:Destroy()
        elseif v:IsA("BillboardGui") and v.Name == "ItemESP_Name" then
            v:Destroy()
        end
    end
end

local function applyItemESP(obj)
    if not itemESPEnabled then return end
    if obj:IsA("Tool") or (obj:IsA("Part") and obj.Parent == workspace) then
        if not obj:FindFirstChild("ItemESP") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ItemESP"
            highlight.Adornee = obj:IsA("Tool") and obj:FindFirstChildWhichIsA("Part") or obj
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.Parent = obj
        end
        if not obj:FindFirstChild("ItemESP_Name") then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ItemESP_Name"
            billboard.Size = UDim2.new(0, 100, 0, 20)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = obj

            local text = Instance.new("TextLabel")
            text.BackgroundTransparency = 1
            text.Size = UDim2.new(1, 0, 1, 0)
            text.Text = obj.Name
            text.TextColor3 = Color3.fromRGB(0, 255, 0)
            text.TextStrokeTransparency = 0
            text.TextScaled = true
            text.Font = Enum.Font.SourceSansBold
            text.Parent = billboard
        end
    end
end

local function toggleItemESP(state)
    itemESPEnabled = state
    clearItemESP()
    if state then
        for _, obj in ipairs(workspace:GetDescendants()) do
            applyItemESP(obj)
        end
        table.insert(itemESPConnections, workspace.DescendantAdded:Connect(function(obj)
            task.wait(0.2)
            applyItemESP(obj)
        end))
        table.insert(itemESPConnections, workspace.DescendantRemoving:Connect(function(obj)
            if obj:IsA("Tool") or obj:IsA("Part") then
                if obj:FindFirstChild("ItemESP") then obj.ItemESP:Destroy() end
                if obj:FindFirstChild("ItemESP_Name") then obj.ItemESP_Name:Destroy() end
            end
        end))
    end
end

VisualTab:CreateToggle({
    Name = "Item ESP",
    CurrentValue = false,
    Callback = toggleItemESP
})

-- // ===== PLAYER TAB =====
-- WalkSpeed Slider
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 300},
    Increment = 1,
    Suffix = "WS",
    CurrentValue = 16,
    Callback = function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
})

-- JumpPower Slider
PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 200},
    Increment = 1,
    Suffix = "JP",
    CurrentValue = 50,
    Callback = function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end
})

-- Gravity Slider
PlayerTab:CreateSlider({
    Name = "Gravity",
    Range = {0, 300},
    Increment = 1,
    Suffix = "G",
    CurrentValue = workspace.Gravity,
    Callback = function(value)
        workspace.Gravity = value
    end
})

-- Zoom Slider
PlayerTab:CreateSlider({
    Name = "Max Zoom",
    Range = {70, 1000},
    Increment = 5,
    Suffix = "Zoom",
    CurrentValue = LocalPlayer.CameraMaxZoomDistance,
    Callback = function(value)
        LocalPlayer.CameraMaxZoomDistance = value
    end
})

-- Spectate
local spectating = false
local currentTarget = nil
local PlayerListDropdown

local function refreshPlayerDropdown()
    if not PlayerListDropdown then return end
    pcall(function() if PlayerListDropdown.Clear then PlayerListDropdown:Clear() end end)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            pcall(function()
                if PlayerListDropdown.AddOption then
                    PlayerListDropdown:AddOption(plr.Name)
                end
            end)
        end
    end
end

PlayerListDropdown = PlayerTab:CreateDropdown({
    Name = "Spectate Player",
    Options = {},
    CurrentOption = "",
    Callback = function(option)
        local target = Players:FindFirstChild(option)
        if target and target.Character then
            currentTarget = target
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Spectate",
    CurrentValue = false,
    Callback = function(state)
        spectating = state
        if not state then
            Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        end
    end
})

RunService.RenderStepped:Connect(function()
    if spectating and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = currentTarget.Character.Humanoid
    end
end)

Players.PlayerAdded:Connect(refreshPlayerDropdown)
Players.PlayerRemoving:Connect(refreshPlayerDropdown)
task.defer(refreshPlayerDropdown)

-- Freecam
local freecamEnabled = false
local savedCFrame

local function toggleFreecam(state)
    freecamEnabled = state
    if state then
        savedCFrame = Camera.CFrame
        Camera.CameraType = Enum.CameraType.Scriptable
    else
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CFrame = savedCFrame or Camera.CFrame
    end
end

PlayerTab:CreateToggle({
    Name = "Freecam",
    CurrentValue = false,
    Callback = toggleFreecam
})

-- // ===== MISC TAB =====
-- Noclip
local noclipEnabled = false
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

MiscTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(state) noclipEnabled = state end
})

-- Anti AFK
MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Callback = function(state)
        if state then
            if not getconnections then return end
            for _, v in pairs(getconnections(LocalPlayer.Idled)) do
                v:Disable()
            end
        else
            for _, v in pairs(getconnections(LocalPlayer.Idled)) do
                v:Enable()
            end
        end
    end
})

-- No Fall (dummy)
MiscTab:CreateToggle({
    Name = "No Fall",
    CurrentValue = false,
    Callback = function(state)
        -- Placeholder
    end
})

-- Macro Buttons
local macroGui = nil
MiscTab:CreateToggle({
    Name = "Macro Buttons",
    CurrentValue = false,
    Callback = function(state)
        if state then
            macroGui = Instance.new("ScreenGui")
            macroGui.Name = "MacroButtonsGui"
            macroGui.ResetOnSpawn = false
            macroGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

            -- Tombol 1
            local Button1 = Instance.new("TextButton")
            Button1.Parent = macroGui
            Button1.Text = "GUN"
            Button1.Size = UDim2.new(0, 70, 0, 70)
            Button1.AnchorPoint = Vector2.new(1, 0)
            Button1.Position = UDim2.new(0.98, 0, 0.02, 0)
            Button1.BackgroundTransparency = 1
            Button1.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button1.Font = Enum.Font.SourceSans

            local stroke1 = Instance.new("UIStroke", Button1)
            stroke1.Color = Color3.fromRGB(255, 255, 255)
            stroke1.Thickness = 1.2

            local corner1 = Instance.new("UICorner", Button1)
            corner1.CornerRadius = UDim.new(1, 0)

            Button1.MouseButton1Click:Connect(function()
                vim:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                task.wait(1)
                vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end)

            -- Tombol 2
            local Button2 = Instance.new("TextButton")
            Button2.Parent = macroGui
            Button2.Text = "RELOAD"
            Button2.Size = UDim2.new(0, 70, 0, 70)
            Button2.AnchorPoint = Vector2.new(1, 0)
            Button2.Position = UDim2.new(0.85, 0, 0.02, 0)
            Button2.BackgroundTransparency = 1
            Button2.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button2.Font = Enum.Font.SourceSans

            local stroke2 = Instance.new("UIStroke", Button2)
            stroke2.Color = Color3.fromRGB(255, 255, 255)
            stroke2.Thickness = 1.2

            local corner2 = Instance.new("UICorner", Button2)
            corner2.CornerRadius = UDim.new(1, 0)

            Button2.MouseButton1Click:Connect(function()
                vim:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                task.wait(2)
                vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end)
        else
            if macroGui then
                macroGui:Destroy()
                macroGui = nil
            end
        end
    end
})