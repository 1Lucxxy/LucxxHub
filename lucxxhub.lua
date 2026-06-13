local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Window = Rayfield:CreateWindow({
    Name = "Testing ESP",
    LoadingTitle = "ESP System",
    LoadingSubtitle = "Studio Testing"
})

local Main = Window:CreateTab("ESP", 4483362458)

local PlayerESPEnabled = false
local InteractESPEnabled = false

local PlayerHighlights = {}
local InteractHighlights = {}

-- PLAYER ESP

local function AddPlayerESP(Character)
    if not PlayerESPEnabled then
        return
    end

    if PlayerHighlights[Character] then
        return
    end

    local Highlight = Instance.new("Highlight")
    Highlight.Name = "PlayerESP"
    Highlight.FillTransparency = 0.5
    Highlight.OutlineTransparency = 0
    Highlight.Parent = Character

    PlayerHighlights[Character] = Highlight
end

local function ScanPlayers()
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player.Character then
            AddPlayerESP(Player.Character)
        end
    end
end

local function RemovePlayerESP()
    for Character, Highlight in pairs(PlayerHighlights) do
        if Highlight then
            Highlight:Destroy()
        end
    end

    table.clear(PlayerHighlights)
end

-- INTERACT ESP

local function AddInteractESP(Object)
    if InteractHighlights[Object] then
        return
    end

    local Target = Object:FindFirstAncestorOfClass("Model") or Object.Parent

    if not Target then
        return
    end

    local Highlight = Instance.new("Highlight")
    Highlight.Name = "InteractESP"
    Highlight.FillColor = Color3.fromRGB(255, 255, 0)
    Highlight.FillTransparency = 0.6
    Highlight.OutlineTransparency = 0
    Highlight.Parent = Target

    InteractHighlights[Object] = Highlight
end

local function ScanInteractables()
    for _, Object in ipairs(Workspace:GetDescendants()) do
        if Object:IsA("ProximityPrompt") then
            AddInteractESP(Object)
        end
    end
end

local function RemoveInteractESP()
    for _, Highlight in pairs(InteractHighlights) do
        if Highlight then
            Highlight:Destroy()
        end
    end

    table.clear(InteractHighlights)
end

-- TOGGLES

Main:CreateToggle({
    Name = "Player Highlight",
    CurrentValue = false,
    Callback = function(Value)
        PlayerESPEnabled = Value

        if Value then
            ScanPlayers()
        else
            RemovePlayerESP()
        end
    end
})

Main:CreateToggle({
    Name = "Interact Highlight",
    CurrentValue = false,
    Callback = function(Value)
        InteractESPEnabled = Value

        if Value then
            ScanInteractables()
        else
            RemoveInteractESP()
        end
    end
})

-- PLAYER JOIN

Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function(Character)
        task.wait(1)

        if PlayerESPEnabled then
            AddPlayerESP(Character)
        end
    end)
end)

-- EXISTING PLAYERS

for _, Player in ipairs(Players:GetPlayers()) do
    Player.CharacterAdded:Connect(function(Character)
        task.wait(1)

        if PlayerESPEnabled then
            AddPlayerESP(Character)
        end
    end)
end

-- NEW INTERACTABLES

Workspace.DescendantAdded:Connect(function(Object)
    if InteractESPEnabled and Object:IsA("ProximityPrompt") then
        task.wait(0.1)
        AddInteractESP(Object)
    end
end)
