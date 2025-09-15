-- LocalScript: HUD Persegi Panjang dengan Fly, WalkSpeed, Coordinate

-- === SERVICES ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- === UTILS ===
local function new(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k == "Parent" then
            obj.Parent = v
        else
            obj[k] = v
        end
    end
    return obj
end

-- === GUI ROOT ===
local gui = new("ScreenGui", {
    Name = "CustomHUD",
    Parent = PlayerGui,
    ResetOnSpawn = false
})

local mainFrame = new("Frame", {
    Parent = gui,
    BackgroundColor3 = Color3.fromRGB(40,40,40),
    Size = UDim2.new(0, 400, 0, 120),
    Position = UDim2.new(0.5, -200, 0, 50)
})
new("UICorner", {Parent = mainFrame, CornerRadius = UDim.new(0,8)})

-- === BUTTONS TOP ===
local flyBtn = new("TextButton", {
    Parent = mainFrame,
    Text = "Fly",
    Size = UDim2.new(0, 80, 0, 30),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Color3.fromRGB(70,70,70),
    TextColor3 = Color3.new(1,1,1)
})
new("UICorner", {Parent = flyBtn, CornerRadius = UDim.new(0,6)})

local wsBtn = new("TextButton", {
    Parent = mainFrame,
    Text = "WalkSpeed",
    Size = UDim2.new(0, 100, 0, 30),
    Position = UDim2.new(0, 100, 0, 10),
    BackgroundColor3 = Color3.fromRGB(70,70,70),
    TextColor3 = Color3.new(1,1,1)
})
new("UICorner", {Parent = wsBtn, CornerRadius = UDim.new(0,6)})

local coordBtn = new("TextButton", {
    Parent = mainFrame,
    Text = "Coordinate",
    Size = UDim2.new(0, 100, 0, 30),
    Position = UDim2.new(0, 210, 0, 10),
    BackgroundColor3 = Color3.fromRGB(70,70,70),
    TextColor3 = Color3.new(1,1,1)
})
new("UICorner", {Parent = coordBtn, CornerRadius = UDim.new(0,6)})

-- === COPY BUTTON (di bawah Fly) ===
local copyBtn = new("TextButton", {
    Parent = mainFrame,
    Text = "Copy",
    Size = UDim2.new(0, 80, 0, 25),
    Position = UDim2.new(0, 10, 0, 45),
    BackgroundColor3 = Color3.fromRGB(100,100,100),
    TextColor3 = Color3.new(1,1,1)
})
new("UICorner", {Parent = copyBtn, CornerRadius = UDim.new(0,6)})

-- === TEXTBOX BAWAH ===
local mainTextBox = new("TextBox", {
    Parent = mainFrame,
    PlaceholderText = "Ketik sesuatu...",
    Size = UDim2.new(1, -20, 0, 25),
    Position = UDim2.new(0, 10, 0, 85),
    BackgroundColor3 = Color3.fromRGB(60,60,60),
    TextColor3 = Color3.new(1,1,1),
    ClearTextOnFocus = false
})
new("UICorner", {Parent = mainTextBox, CornerRadius = UDim.new(0,6)})

-- === WALKSPEED GUI (Muncul setelah klik) ===
local wsFrame = new("Frame", {
    Parent = gui,
    BackgroundColor3 = Color3.fromRGB(35,35,35),
    Size = UDim2.new(0, 250, 0, 80),
    Position = UDim2.new(0.5, -125, 0.5, -40),
    Visible = false
})
new("UICorner", {Parent = wsFrame, CornerRadius = UDim.new(0,8)})

local wsSlider = new("TextBox", {
    Parent = wsFrame,
    Text = "16",
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 20),
    BackgroundColor3 = Color3.fromRGB(70,70,70),
    TextColor3 = Color3.new(1,1,1),
    ClearTextOnFocus = false
})
new("UICorner", {Parent = wsSlider, CornerRadius = UDim.new(0,6)})

-- === FEATURES ===
-- Fly toggle
local flying = false
local flyConn
flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        flyBtn.Text = "Flying..."
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        flyConn = RunService.RenderStepped:Connect(function()
            hrp.Velocity = Vector3.new(0,2,0) -- efek terbang sederhana
        end)
    else
        flyBtn.Text = "Fly"
        if flyConn then flyConn:Disconnect() end
    end
end)

-- WalkSpeed GUI toggle
wsBtn.MouseButton1Click:Connect(function()
    wsFrame.Visible = not wsFrame.Visible
end)
wsSlider.FocusLost:Connect(function()
    local val = tonumber(wsSlider.Text)
    if val and val > 0 and val <= 200 then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    else
        wsSlider.Text = "16"
    end
end)

-- Coordinate display
local coordConn
coordBtn.MouseButton1Click:Connect(function()
    if coordConn then
        coordConn:Disconnect()
        coordConn = nil
        coordBtn.Text = "Coordinate"
    else
        coordBtn.Text = "Stop Coord"
        coordConn = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                mainTextBox.Text = string.format("X: %.1f | Y: %.1f | Z: %.1f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
            end
        end)
    end
end)

-- Copy isi textbox
copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(mainTextBox.Text)
    end
end)
