local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Item Highlight",
    LoadingTitle = "ESP Loader",
    LoadingSubtitle = "by ChatGPT"
})

local MainTab = Window:CreateTab("ESP", 4483362458)

local ItemESP = false
local Highlights = {}

local function CreateHighlight(item)
    if Highlights[item] then return end

    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(255, 255, 0)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = item

    Highlights[item] = hl
end

local function RemoveHighlights()
    for _, hl in pairs(Highlights) do
        if hl then
            hl:Destroy()
        end
    end
    table.clear(Highlights)
end

local function ScanItems()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Tool") then
            CreateHighlight(v)
        end
    end
end

MainTab:CreateToggle({
    Name = "Item Highlight",
    CurrentValue = false,
    Flag = "ItemESP",
    Callback = function(Value)
        ItemESP = Value

        if Value then
            ScanItems()

            task.spawn(function()
                while ItemESP do
                    ScanItems()
                    task.wait(2)
                end
            end)
        else
            RemoveHighlights()
        end
    end,
})

workspace.DescendantAdded:Connect(function(obj)
    if ItemESP and obj:IsA("Tool") then
        task.wait(0.1)
        CreateHighlight(obj)
    end
end)
