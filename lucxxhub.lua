-- ====================================================
-- SISTEM CLEANUP (MENCEGAH OVERLAP SAAT RE-EXECUTE)
-- ====================================================
if getgenv()._LucxxHubCleanup then
    pcall(getgenv()._LucxxHubCleanup)
end

local scriptConnections = {}

-- ====================================================
-- GLOBAL CONFIG & UTILITIES
-- ====================================================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local FILE_NAME = "AccessoryCustomConfigV4_2_WindUI.json"

local accessoryIds = {
    ["Black Valk"] = 124730194,
    ["Violet Valk"] = 1402432199,
    ["8-Bit Royal Crown"] = 10159600649,
    ["Frozen Horn"] = 74891470,
    ["Poisoned Horns"] = 1744060292,
    ["Bunny Fedora"] = 108147416,
    ["Fiery Horns"] = 215718515
}

local HEAD_IDS = {
    ["Death Walker"] = 99223542650102, 
    ["UGC Headless"] = 15093053680
}

local KORBLOX_MESH_ID = "rbxassetid://101851696"
local KORBLOX_TEXTURE_ID = "rbxassetid://101851254"

local spawnedAccessories = {}
local baseCFrames = {}
local currentConfig = { _HeadType = "Default" }
local selectedAccessory = "Black Valk" 
local targetPlayersRegistry = {} 

local tempInputs = {
    pos = {0,0,0},
    rot = {0,0,0},
    scale = 1
}

local function deepCopy(t)
    if type(t) ~= "table" then return t end
    local res = {}
    for k, v in pairs(t) do res[k] = deepCopy(v) end
    return res
end

local function initConfig(name)
    if not currentConfig[name] then
        currentConfig[name] = { pos = {0,0,0}, rot = {0,0,0}, scale = 1, enabled = true }
    end
end
for name, _ in pairs(accessoryIds) do initConfig(name) end

-- ====================================================
-- FUNGSI KEPALA & AKSESORIS
-- ====================================================
local function wearHeadModel(char, headType)
    local assetId = HEAD_IDS[headType]
    if not assetId then return end
    
    local success, result = pcall(function() return game:GetObjects("rbxassetid://" .. assetId)[1] end)
    if success and result then
        result.Archivable = true
        for _, v in ipairs(result:GetDescendants()) do
            v.Archivable = true
            if v:IsA("BasePart") then
                v.Anchored = false
                v.CanCollide = false
            end
        end

        local handle = result:IsA("BasePart") and result or result:FindFirstChild("Handle") or result:FindFirstChildOfClass("Part") or result:FindFirstChildOfClass("MeshPart")

        if handle then
            handle.Transparency = 0
            local targetPart = char:WaitForChild("Head", 3)
            if not targetPart then return end
            
            local attachment = handle:FindFirstChildOfClass("Attachment")
            local baseC0, baseC1 = CFrame.new(), CFrame.new()
            
            if attachment then
                local charAttachment = targetPart:FindFirstChild(attachment.Name, true)
                if charAttachment then baseC0, baseC1 = charAttachment.CFrame, attachment.CFrame end
            end
            
            if result:IsA("BasePart") then
                local wrapModel = Instance.new("Model")
                wrapModel.Name = "CustomHeadModel"
                result.Parent = wrapModel
                wrapModel.Parent = char
            else
                result.Name = "CustomHeadModel"
                result.Parent = char
            end
            
            local weld = Instance.new("Weld")
            weld.Name = "HeadWeld"
            weld.Part0, weld.Part1 = targetPart, handle
            weld.C0, weld.C1 = baseC0, baseC1
            weld.Parent = handle
        end
    end
end

local function applyHeadState(char, configTable)
    if not char then return end
    for _, v in ipairs(char:GetChildren()) do
        if v.Name == "CustomHeadModel" then v:Destroy() end
    end
    
    local head = char:FindFirstChild("Head")
    if not head then return end
    local headType = configTable._HeadType or "Default"
    
    if headType == "Default" then
        head.Transparency = 0
        local face = head:FindFirstChildOfClass("Decal")
        if face then face.Transparency = 0 end
        local mesh = head:FindFirstChildOfClass("SpecialMesh")
        if mesh then 
            mesh.Scale = (mesh.MeshType == Enum.MeshType.Head) and Vector3.new(1.25, 1.25, 1.25) or Vector3.new(1, 1, 1) 
        end
    else
        head.Transparency = 1
        local face = head:FindFirstChildOfClass("Decal")
        if face then face.Transparency = 1 end
        local mesh = head:FindFirstChildOfClass("SpecialMesh")
        if mesh then mesh.Scale = Vector3.new(0, 0, 0) end
        wearHeadModel(char, headType)
    end
end

local function applyConfigToSpecific(char, name, configTable)
    local acc = spawnedAccessories[char] and spawnedAccessories[char][name]
    local cfg = configTable[name]
    local base = baseCFrames[char] and baseCFrames[char][name]
    
    if not cfg or not acc or not base then return end
    
    local handle = acc:IsA("BasePart") and acc or acc:FindFirstChild("Handle") or acc:FindFirstChildOfClass("Part") or acc:FindFirstChildOfClass("MeshPart")
    if not handle then return end
    
    local weld = handle:FindFirstChild("ManualWeld")
    if weld then
        local offsetPos = CFrame.new(unpack(cfg.pos))
        local offsetRot = CFrame.Angles(math.rad(cfg.rot[1]), math.rad(cfg.rot[2]), math.rad(cfg.rot[3]))
        weld.C0 = base.C0 * offsetPos * offsetRot
        weld.C1 = base.C1
    end
    
    local mesh = handle:FindFirstChildOfClass("SpecialMesh")
    local s = cfg.scale
    if mesh then mesh.Scale = Vector3.new(s, s, s) else handle.Size = Vector3.new(s, s, s) end
end

local function wearAccessory(char, name, assetId, configTable)
    if not configTable[name].enabled then return end 
    
    if not spawnedAccessories[char] then spawnedAccessories[char] = {} end
    if not baseCFrames[char] then baseCFrames[char] = {} end
    if spawnedAccessories[char][name] then pcall(function() spawnedAccessories[char][name]:Destroy() end) end

    local success, result = pcall(function() return game:GetObjects("rbxassetid://" .. assetId)[1] end)
    if success and result then
        result.Archivable = true
        for _, v in ipairs(result:GetDescendants()) do
            v.Archivable = true
            if v:IsA("BasePart") then v.Anchored = false; v.CanCollide = false end
        end

        local handle = result:IsA("BasePart") and result or result:FindFirstChild("Handle") or result:FindFirstChildOfClass("Part") or result:FindFirstChildOfClass("MeshPart")

        if handle then
            handle.Transparency = 0
            local attachment = handle:FindFirstChildOfClass("Attachment")
            local targetPart = char:WaitForChild("Head", 3) or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            local baseC0, baseC1 = CFrame.new(), CFrame.new()
            
            if attachment then
                local charAttachment = char:FindFirstChild(attachment.Name, true)
                if charAttachment then 
                    targetPart = charAttachment.Parent 
                    baseC0, baseC1 = charAttachment.CFrame, attachment.CFrame
                end
            end
            
            baseCFrames[char][name] = {C0 = baseC0, C1 = baseC1}
            
            if result:IsA("BasePart") then
                local wrapModel = Instance.new("Model")
                wrapModel.Name = name .. "_Model"
                result.Parent = wrapModel
                wrapModel.Parent = char
                spawnedAccessories[char][name] = wrapModel
            else
                result.Parent = char
                spawnedAccessories[char][name] = result
            end
            
            local weld = Instance.new("Weld")
            weld.Name = "ManualWeld"
            weld.Part0, weld.Part1 = targetPart, handle
            weld.C0, weld.C1 = baseC0, baseC1
            weld.Archivable = true
            weld.Parent = handle
            
            applyConfigToSpecific(char, name, configTable)
        end
    end
end

local function applyKorblox(char)
    local rightLeg = char:FindFirstChild("Right Leg")
    if rightLeg then
        for _, v in ipairs(rightLeg:GetChildren()) do
            if v:IsA("SpecialMesh") or v:IsA("CharacterMesh") then v:Destroy() end
        end
        local mesh = Instance.new("SpecialMesh")
        mesh.Name = "LucxxKorbloxMesh"
        mesh.MeshType, mesh.MeshId, mesh.TextureId = Enum.MeshType.FileMesh, KORBLOX_MESH_ID, KORBLOX_TEXTURE_ID
        mesh.Scale = Vector3.new(1, 1, 1)
        mesh.Archivable = true
        mesh.Parent = rightLeg
    else
        local rUpper = char:FindFirstChild("RightUpperLeg")
        local rLower = char:FindFirstChild("RightLowerLeg")
        local rFoot = char:FindFirstChild("RightFoot")
        
        if rUpper and rLower and rFoot then
            rUpper.Transparency = 1; rLower.Transparency = 1; rFoot.Transparency = 1
            local oldFake = char:FindFirstChild("FakeKorbloxLeg")
            if oldFake then oldFake:Destroy() end
            
            local fakeLeg = Instance.new("Part")
            fakeLeg.Name = "FakeKorbloxLeg"
            fakeLeg.Size = Vector3.new(1, 2, 1)
            fakeLeg.Anchored = false; fakeLeg.CanCollide = false; fakeLeg.Transparency = 0; fakeLeg.Archivable = true
            
            local mesh = Instance.new("SpecialMesh")
            mesh.MeshType, mesh.MeshId, mesh.TextureId = Enum.MeshType.FileMesh, KORBLOX_MESH_ID, KORBLOX_TEXTURE_ID
            mesh.Scale = Vector3.new(1, 1, 1)
            mesh.Archivable = true
            mesh.Parent = fakeLeg
            fakeLeg.Parent = char
            
            local weld = Instance.new("Weld")
            weld.Name = "KorbloxWeld"
            weld.Part0 = rUpper
            weld.Part1 = fakeLeg
            weld.C0 = CFrame.new(0, -0.4, 0)
            weld.Archivable = true
            weld.Parent = fakeLeg
        end
    end
end

local function refreshCharacter(char, configTable)
    if not char then return end
    local cfg = configTable or currentConfig
    
    if spawnedAccessories[char] then
        for k, v in pairs(spawnedAccessories[char]) do if v and v.Parent then v:Destroy() end end
        spawnedAccessories[char] = {}
    end
    
    for name, id in pairs(accessoryIds) do
        if cfg[name] and cfg[name].enabled then wearAccessory(char, name, id, cfg) end
    end
    applyKorblox(char)
    applyHeadState(char, cfg)
end

-- ====================================================
-- SISTEM DETEKSI CLONE & RUNSERVICE
-- ====================================================
local function getTargetPlayer(nameStr)
    nameStr = nameStr:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #nameStr) == nameStr or p.DisplayName:lower():sub(1, #nameStr) == nameStr then return p end
    end
    return nil
end

local function monitorPlayer(p)
    table.insert(scriptConnections, p.CharacterAdded:Connect(function(char)
        task.wait(1)
        if targetPlayersRegistry[p.UserId] then refreshCharacter(char, targetPlayersRegistry[p.UserId]) end
    end))
end

for _, p in ipairs(Players:GetPlayers()) do monitorPlayer(p) end
table.insert(scriptConnections, Players.PlayerAdded:Connect(monitorPlayer))
table.insert(scriptConnections, Players.PlayerRemoving:Connect(function(p) targetPlayersRegistry[p.UserId] = nil end))

table.insert(scriptConnections, workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
        task.wait(0.2)
        local isLocalClone = false
        if obj.Name == localPlayer.Name and obj ~= localPlayer.Character then
            isLocalClone = true
        else
            local myShirt = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Shirt")
            local cloneShirt = obj:FindFirstChildOfClass("Shirt")
            if myShirt and cloneShirt and myShirt.ShirtTemplate == cloneShirt.ShirtTemplate then isLocalClone = true end
        end

        if isLocalClone then
            refreshCharacter(obj, currentConfig)
        else
            local tPlayer = getTargetPlayer(obj.Name)
            if tPlayer and tPlayer.Name == obj.Name and obj ~= tPlayer.Character then
                if targetPlayersRegistry[tPlayer.UserId] then refreshCharacter(obj, targetPlayersRegistry[tPlayer.UserId]) end
            end
        end
    end
end))

table.insert(scriptConnections, RunService.Stepped:Connect(function()
    local function enforceTransparency(char, config)
        if not char then return end
        local fakeLeg = char:FindFirstChild("FakeKorbloxLeg")
        local rUpper = char:FindFirstChild("RightUpperLeg")
        if fakeLeg and rUpper and rUpper.Transparency ~= 1 then
            rUpper.Transparency = 1
            local rLower = char:FindFirstChild("RightLowerLeg")
            if rLower then rLower.Transparency = 1 end
            local rFoot = char:FindFirstChild("RightFoot")
            if rFoot then rFoot.Transparency = 1 end
        end
        if config and config._HeadType ~= "Default" then
            local head = char:FindFirstChild("Head")
            local customHead = char:FindFirstChild("CustomHeadModel")
            if head and customHead and head.Transparency ~= 1 then
                head.Transparency = 1
                local face = head:FindFirstChildOfClass("Decal")
                if face then face.Transparency = 1 end
            end
        end
    end
    enforceTransparency(localPlayer.Character, currentConfig)
    for userId, config in pairs(targetPlayersRegistry) do
        local p = Players:GetPlayerByUserId(userId)
        if p and p.Character then enforceTransparency(p.Character, config) end
    end
end))

-- ====================================================
-- IMPLEMENTASI WINDUI DENGAN LINK YANG SUDAH DIPERBAIKI
-- ====================================================
-- Menggunakan link raw ke dist main WindUI dari sumber resmi GitHub
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "LucxxHub",
    Icon = "lucide-gamepad-2",
    Author = "Fayyxie",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 160,
    HasOutline = false
})

getgenv()._LucxxWindUIWindow = Window

local Tabs = {
    Player = Window:Tab({ Title = "Player", Icon = "lucide-user" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "lucide-settings" })
}

local function parseVector(str)
    local parts = string.split(str, ",")
    return tonumber(parts[1]) or 0, tonumber(parts[2]) or 0, tonumber(parts[3]) or 0
end

local function getAccessoryNames()
    local list = {}
    for k, _ in pairs(accessoryIds) do table.insert(list, k) end
    return list
end

-- ====================================================
-- TAB 1: PLAYER (Gabungan Aksesoris, Head, dan Target)
-- ====================================================

local AccDropdown = Tabs.Player:Dropdown({
    Title = "Select Accessory",
    Values = getAccessoryNames(),
    Value = selectedAccessory,
    Callback = function(Value)
        selectedAccessory = Value
        WindUI:Notify({ Title = "Selected", Content = "Editing: " .. Value, Duration = 2 })
    end
})

Tabs.Player:Toggle({
    Title = "Enable/Disable Accessory",
    Value = true,
    Callback = function(State)
        if not selectedAccessory then return end
        currentConfig[selectedAccessory].enabled = State
        
        if localPlayer.Character then
            if State then wearAccessory(localPlayer.Character, selectedAccessory, accessoryIds[selectedAccessory], currentConfig)
            else
                if spawnedAccessories[localPlayer.Character] and spawnedAccessories[localPlayer.Character][selectedAccessory] then
                    spawnedAccessories[localPlayer.Character][selectedAccessory]:Destroy()
                    spawnedAccessories[localPlayer.Character][selectedAccessory] = nil
                end
            end
        end

        for userId, config in pairs(targetPlayersRegistry) do
            local p = Players:GetPlayerByUserId(userId)
            if p and p.Character then
                config[selectedAccessory].enabled = State
                if State then wearAccessory(p.Character, selectedAccessory, accessoryIds[selectedAccessory], config)
                else
                    if spawnedAccessories[p.Character] and spawnedAccessories[p.Character][selectedAccessory] then
                        spawnedAccessories[p.Character][selectedAccessory]:Destroy()
                        spawnedAccessories[p.Character][selectedAccessory] = nil
                    end
                end
            end
        end
    end
})

Tabs.Player:Input({
    Title = "Position (X, Y, Z)",
    PlaceholderText = "Format: 0, 0, 0",
    Callback = function(Text)
        local x, y, z = parseVector(Text)
        tempInputs.pos = {x, y, z}
    end
})

Tabs.Player:Input({
    Title = "Rotation (X, Y, Z)",
    PlaceholderText = "Format: 0, 0, 0",
    Callback = function(Text)
        local x, y, z = parseVector(Text)
        tempInputs.rot = {x, y, z}
    end
})

Tabs.Player:Input({
    Title = "Scale",
    PlaceholderText = "1",
    Callback = function(Text) tempInputs.scale = tonumber(Text) or 1 end
})

Tabs.Player:Button({
    Title = "Apply Changes",
    Callback = function()
        if not selectedAccessory then return end
        currentConfig[selectedAccessory].pos = deepCopy(tempInputs.pos)
        currentConfig[selectedAccessory].rot = deepCopy(tempInputs.rot)
        currentConfig[selectedAccessory].scale = tempInputs.scale
        
        if localPlayer.Character then applyConfigToSpecific(localPlayer.Character, selectedAccessory, currentConfig) end

        for userId, config in pairs(targetPlayersRegistry) do
            local p = Players:GetPlayerByUserId(userId)
            if p and p.Character then
                config[selectedAccessory].pos = deepCopy(currentConfig[selectedAccessory].pos)
                config[selectedAccessory].rot = deepCopy(currentConfig[selectedAccessory].rot)
                config[selectedAccessory].scale = currentConfig[selectedAccessory].scale
                applyConfigToSpecific(p.Character, selectedAccessory, config)
            end
        end
        WindUI:Notify({ Title = "Success", Content = "Applied to " .. selectedAccessory, Duration = 2 })
    end
})

Tabs.Player:Button({
    Title = "Reset Values",
    Callback = function()
        if not selectedAccessory then return end
        currentConfig[selectedAccessory] = { pos = {0,0,0}, rot = {0,0,0}, scale = 1, enabled = true }
        if localPlayer.Character then applyConfigToSpecific(localPlayer.Character, selectedAccessory, currentConfig) end
        for userId, config in pairs(targetPlayersRegistry) do
            local p = Players:GetPlayerByUserId(userId)
            if p and p.Character then
                config[selectedAccessory] = deepCopy(currentConfig[selectedAccessory])
                applyConfigToSpecific(p.Character, selectedAccessory, config)
            end
        end
        WindUI:Notify({ Title = "Reset", Content = selectedAccessory .. " has been reset.", Duration = 2 })
    end
})

Tabs.Player:Dropdown({
    Title = "Head Type",
    Values = {"Default", "Death Walker", "UGC Headless"},
    Value = "Default",
    Callback = function(Value)
        currentConfig._HeadType = Value
        if localPlayer.Character then refreshCharacter(localPlayer.Character, currentConfig) end
        
        for userId, config in pairs(targetPlayersRegistry) do
            local p = Players:GetPlayerByUserId(userId)
            if p and p.Character then
                config._HeadType = Value
                refreshCharacter(p.Character, config)
            end
        end
    end
})

local targetPlayerTemp = ""
Tabs.Player:Input({
    Title = "Player Name",
    PlaceholderText = "Username or DisplayName...",
    Callback = function(Text) targetPlayerTemp = Text end
})

Tabs.Player:Button({
    Title = "Apply To Player",
    Callback = function()
        local p = getTargetPlayer(targetPlayerTemp)
        if p then
            targetPlayersRegistry[p.UserId] = deepCopy(currentConfig)
            if p.Character then refreshCharacter(p.Character, targetPlayersRegistry[p.UserId]) end
            WindUI:Notify({ Title = "Locked", Content = "Successfully locked onto " .. p.Name, Duration = 3 })
        else
            WindUI:Notify({ Title = "Error", Content = "Player not found!", Duration = 3 })
        end
    end
})

-- ====================================================
-- TAB 2: SETTINGS
-- ====================================================

local newCatalogId = nil
Tabs.Settings:Input({
    Title = "Custom Catalog ID",
    PlaceholderText = "Enter ID...",
    Callback = function(Text) newCatalogId = tonumber(Text) end
})

Tabs.Settings:Button({
    Title = "Add Custom Accessory",
    Callback = function()
        if newCatalogId then
            local success, info = pcall(function() return MarketplaceService:GetProductInfo(newCatalogId) end)
            local newName = success and info.Name or ("Custom_" .. newCatalogId)
            accessoryIds[newName] = newCatalogId
            initConfig(newName)
            
            AccDropdown:Refresh(getAccessoryNames())
            WindUI:Notify({ Title = "Added", Content = "Accessory " .. newName .. " added!", Duration = 3 })
            
            if localPlayer.Character then wearAccessory(localPlayer.Character, newName, newCatalogId, currentConfig) end
        else
            WindUI:Notify({ Title = "Error", Content = "Invalid ID!", Duration = 2 })
        end
    end
})

Tabs.Settings:Button({
    Title = "Save Config",
    Callback = function()
        if writefile then
            local success, encoded = pcall(function() return HttpService:JSONEncode(currentConfig) end)
            if success then 
                writefile(FILE_NAME, encoded) 
                WindUI:Notify({ Title = "Saved", Content = "Configuration Saved!", Duration = 2 })
            end
        end
    end
})

Tabs.Settings:Button({
    Title = "Load Config",
    Callback = function()
        if readfile and isfile and isfile(FILE_NAME) then
            local suc, c = pcall(function() return readfile(FILE_NAME) end)
            if suc then
                local ds, dec = pcall(function() return HttpService:JSONDecode(c) end)
                if ds then 
                    for k, v in pairs(dec) do currentConfig[k] = v end 
                    for n, _ in pairs(accessoryIds) do initConfig(n) end
                    WindUI:Notify({ Title = "Loaded", Content = "Configuration Loaded!", Duration = 2 })
                end
            end
        end
        if localPlayer.Character then refreshCharacter(localPlayer.Character, currentConfig) end
    end
})

Tabs.Settings:Dropdown({
    Title = "Change UI Theme",
    Values = {"Dark", "Light", "Rose", "Aqua", "Amethyst", "Ruby"},
    Value = "Dark",
    Callback = function(Value)
        pcall(function()
            WindUI:SetTheme(Value)
        end)
        WindUI:Notify({ Title = "Theme Updated", Content = "UI Theme changed to " .. Value, Duration = 2 })
    end
})

-- Inisialisasi awal
if localPlayer.Character then refreshCharacter(localPlayer.Character, currentConfig) end
table.insert(scriptConnections, localPlayer.CharacterAdded:Connect(function(char) task.wait(1); refreshCharacter(char, currentConfig) end))

-- ====================================================
-- MODIFIKASI CLEANUP WINDUI
-- ====================================================
getgenv()._LucxxHubCleanup = function()
    for _, conn in ipairs(scriptConnections) do
        if conn.Connected then conn:Disconnect() end
    end
    table.clear(scriptConnections)

    if getgenv()._LucxxWindUIWindow then
        pcall(function() getgenv()._LucxxWindUIWindow:Destroy() end)
    end

    for char, accs in pairs(spawnedAccessories) do
        for _, acc in pairs(accs) do
            if acc and acc.Parent then acc:Destroy() end
        end
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local char = p.Character
            local customHead = char:FindFirstChild("CustomHeadModel")
            if customHead then customHead:Destroy() end
            
            local origHead = char:FindFirstChild("Head")
            if origHead then 
                origHead.Transparency = 0
                local face = origHead:FindFirstChildOfClass("Decal")
                if face then face.Transparency = 0 end
                local mesh = origHead:FindFirstChildOfClass("SpecialMesh")
                if mesh and mesh.MeshType == Enum.MeshType.Head then mesh.Scale = Vector3.new(1.25, 1.25, 1.25) end
            end
            
            local fakeLeg = char:FindFirstChild("FakeKorbloxLeg")
            if fakeLeg then fakeLeg:Destroy() end
            
            local rLeg = char:FindFirstChild("Right Leg")
            if rLeg then
                local kMesh = rLeg:FindFirstChild("LucxxKorbloxMesh")
                if kMesh then kMesh:Destroy() end
            end
            
            local rUpper = char:FindFirstChild("RightUpperLeg")
            local rLower = char:FindFirstChild("RightLowerLeg")
            local rFoot = char:FindFirstChild("RightFoot")
            if rUpper then rUpper.Transparency = 0 end
            if rLower then rLower.Transparency = 0 end
            if rFoot then rFoot.Transparency = 0 end
        end
    end
    
    getgenv()._LucxxHubCleanup = nil
end
