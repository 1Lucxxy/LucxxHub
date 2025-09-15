-- HUD Executor Lengkap (Tanpa Delete)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Helper
local function new(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do
        if k=="Parent" then obj.Parent=v else obj[k]=v end
    end
    return obj
end

-- GUI root
local gui = new("ScreenGui",{Parent=PlayerGui, ResetOnSpawn=false, Name="HUDExecutor"})
local mainFrame = new("Frame",{
    Parent=gui, BackgroundColor3=Color3.fromRGB(40,40,40),
    Size=UDim2.new(0,360,0,150), Position=UDim2.new(0.5,-180,0,50)
})
new("UICorner",{Parent=mainFrame, CornerRadius=UDim.new(0,8)})

-- Draggable
do
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
    end
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=input.Position; startPos=mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement then
            dragInput=input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input==dragInput then update(input) end
    end)
end

-- TextBox bawah
local mainTextBox = new("TextBox",{Parent=mainFrame, PlaceholderText="...", Size=UDim2.new(1,-20,0,22), Position=UDim2.new(0,10,0,120), BackgroundColor3=Color3.fromRGB(60,60,60), TextColor3=Color3.new(1,1,1), ClearTextOnFocus=false})
new("UICorner",{Parent=mainTextBox, CornerRadius=UDim.new(0,6)})

-- Tombol
local flyBtn = new("TextButton",{Parent=mainFrame,Text="Fly", Size=UDim2.new(0,60,0,25), Position=UDim2.new(0,10,0,10), BackgroundColor3=Color3.fromRGB(70,70,70), TextColor3=Color3.new(1,1,1)})
local noclipBtn = new("TextButton",{Parent=mainFrame,Text="Noclip", Size=UDim2.new(0,60,0,25), Position=UDim2.new(0,80,0,10), BackgroundColor3=Color3.fromRGB(90,90,90), TextColor3=Color3.new(1,1,1)})
local speedBtn = new("TextButton",{Parent=mainFrame,Text="SpeedWalk", Size=UDim2.new(0,80,0,25), Position=UDim2.new(0,150,0,10), BackgroundColor3=Color3.fromRGB(70,70,70), TextColor3=Color3.new(1,1,1)})
local coordBtn = new("TextButton",{Parent=mainFrame,Text="Coordinate", Size=UDim2.new(0,90,0,25), Position=UDim2.new(0,10,0,40), BackgroundColor3=Color3.fromRGB(70,70,70), TextColor3=Color3.new(1,1,1)})
local copyBtn = new("TextButton",{Parent=mainFrame,Text="Copy", Size=UDim2.new(0,60,0,25), Position=UDim2.new(0,110,0,40), BackgroundColor3=Color3.fromRGB(100,100,100), TextColor3=Color3.new(1,1,1)})

for _,v in pairs({flyBtn,noclipBtn,speedBtn,coordBtn,copyBtn}) do new("UICorner",{Parent=v,CornerRadius=UDim.new(0,6)}) end

-- SpeedWalk frame
local speedFrame = new("Frame",{Parent=gui,BackgroundColor3=Color3.fromRGB(35,35,35),Size=UDim2.new(0,200,0,50), Position=UDim2.new(0.5,-100,0.5,-25),Visible=false})
local speedSlider = new("TextBox",{Parent=speedFrame,Text="16",Size=UDim2.new(1,-20,0,30),Position=UDim2.new(0,10,0,10),BackgroundColor3=Color3.fromRGB(70,70,70),TextColor3=Color3.new(1,1,1),ClearTextOnFocus=false})
new("UICorner",{Parent=speedFrame,CornerRadius=UDim.new(0,6)})

-- ===== Fly =====
local flying=false
local flyBV,flyBG,hrp,char
local flySpeed=50
flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        flyBtn.Text="Flying..."
        char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        hrp = char:WaitForChild("HumanoidRootPart")
        flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce=Vector3.new(4000,4000,4000); flyBV.Parent=hrp
        flyBG = Instance.new("BodyGyro"); flyBG.P=9e4; flyBG.MaxTorque=Vector3.new(9e9,9e9,9e9); flyBG.CFrame=hrp.CFrame; flyBG.Parent=hrp
        local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand=true end

        RunService:BindToRenderStep("FlyExec",Enum.RenderPriority.Camera.Value,function()
            if not flying then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local moveDir = hum and hum.MoveDirection or Vector3.zero
            flyBV.Velocity = moveDir.Magnitude>0 and moveDir.Unit*flySpeed or Vector3.zero
            flyBG.CFrame = workspace.CurrentCamera.CFrame
        end)
    else
        flyBtn.Text="Fly"
        if flyBV then flyBV:Destroy() flyBV=nil end
        if flyBG then flyBG:Destroy() flyBG=nil end
        local hum = char and char:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand=false end
        RunService:UnbindFromRenderStep("FlyExec")
    end
end)

-- ===== Noclip =====
local noclipActive=false
noclipBtn.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    noclipBtn.Text = noclipActive and "Noclip ON" or "Noclip"
    RunService:BindToRenderStep("NoclipExec",Enum.RenderPriority.Character.Value,function()
        if not noclipActive then return end
        local c = LocalPlayer.Character
        if c then
            for _,part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = not noclipActive end
            end
        end
    end)
end)

-- ===== SpeedWalk =====
speedBtn.MouseButton1Click:Connect(function() speedFrame.Visible = not speedFrame.Visible end)
speedSlider.FocusLost:Connect(function()
    local val = tonumber(speedSlider.Text)
    if val and val>0 and val<=300 then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=val end
    else speedSlider.Text="16" end
end)

-- ===== Coordinate =====
local coordConn
coordBtn.MouseButton1Click:Connect(function()
    if coordConn then coordConn:Disconnect(); coordConn=nil; coordBtn.Text="Coordinate"
    else
        coordBtn.Text="Stop Coord"
        coordConn = RunService.RenderStepped:Connect(function()
            local c = LocalPlayer.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if r then mainTextBox.Text=string.format("X: %.1f | Y: %.1f | Z: %.1f", r.Position.X, r.Position.Y, r.Position.Z) end
        end)
    end
end)

-- ===== Copy =====
copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard(mainTextBox.Text) end
end)