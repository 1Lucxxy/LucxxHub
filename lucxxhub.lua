local scriptList = {
    {Nama = "Accesories", Url = "https://pastefy.app/X4zU7Ihd/raw"},
    {Nama = "Freecam", Url = "https://pastefy.app/E1OVTGoZ/raw"},
    {Nama = "Button Path", Url = "https://pastefy.app/27WsICh0/raw"},
    {Nama = "Find Path Button", Url = "https://pastefy.app/zfWvyFav/raw"},
    
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

local function showNotification(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5
    })
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScrollableExecutorGUI"
ScreenGui.ResetOnSpawn = false

local successGui, _ = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not successGui then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 220)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true 
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Fayxiee Script List Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Active = true
Title.Parent = MainFrame

local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, 0, 1, -50)
ScrollFrame.Position = UDim2.new(0, 0, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end)

local function createScriptButton(name, scriptUrl)
    local Button = Instance.new("TextButton")
    Button.Name = name .. "Btn"
    Button.Size = UDim2.new(0, 230, 0, 40) -- Lebar 230 agar pas dengan scrollbar
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.SourceSansSemibold
    Button.Parent = ScrollFrame

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        Button.Text = "Executeing..."
        
        local success, errorMessage = pcall(function()
            if not loadstring then
                error("Executor kamu tidak support loadstring!")
            end
            
            local rawScript = game:HttpGet(scriptUrl)
            if not rawScript or rawScript == "" then
                error("Gagal memuat link atau link kosong.")
            end
            
            local loadedFunction, syntaxError = loadstring(rawScript)
            if not loadedFunction then
                error("Syntax error: " .. tostring(syntaxError))
            end
            
            loadedFunction()
        end)

        if success then
            showNotification("Berhasil!", name .. " sukses dieksekusi!", 5)
            ScreenGui:Destroy() 
        else
            Button.Text = name 
            local cleanError = errorMessage and tostring(errorMessage):match("[^:]+:[^:]+:%s*(.+)") or tostring(errorMessage)
            showNotification("Gagal!", name .. " gagal karena: " .. cleanError, 8)
        end
    end)
end

for i, data in ipairs(scriptList) do
    createScriptButton(data.Nama, data.Url)
end
