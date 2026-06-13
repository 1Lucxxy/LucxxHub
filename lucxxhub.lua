local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Ground Item ESP",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by CtGPT"
})

local Tab = Window:CreateTab("ESP", 4483362458)

local Enabled = false
local ESPs = {}

local function IsGroundItem(tool)
    if not tool:IsA("Tool") then
        return false
    end

    local parent = tool.Parent

    -- Jangan highlight item yang dipegang pemain
    if parent and parent:FindFirstChild("Humanoid") then
        return false
    end

    return tool:IsDescendantOf(workspace)
end

local function AddESP(tool)
    if ESPs[tool] or not IsGroundItem(tool) then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.4
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = tool

    ESPs[tool] = highlight
end

local function RemoveAllESP()
    for _, esp in pairs(ESPs) do
        pcall(function()
            esp:Destroy()
        end)
    end

    table.clear(ESPs)
end

local function Scan()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            AddESP(obj)
        end
    end
end

Tab:CreateToggle({
    Name = "Ground Item ESP",
    CurrentValue = false,
    Flag = "GroundItemESP",
    Callback = function(Value)
        Enabled = Value

        if Value then
            Scan()
        else
            RemoveAllESP()
        end
    end
})

workspace.DescendantAdded:Connect(function(obj)
    if Enabled and obj:IsA("Tool") then
        task.wait(0.1)
        AddESP(obj)
    end
end)
