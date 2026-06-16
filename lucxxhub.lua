-- ====================================================
-- SISTEM CLEANUP (MENCEGAH OVERLAP SAAT RE-EXECUTE)
-- ====================================================
if getgenv()._LucxxHubCleanup then
    pcall(getgenv()._LucxxHubCleanup)
end

local scriptConnections = {} -- Tabel untuk menyimpan semua koneksi event

-- ====================================================
-- GLOBAL CONFIG & UTILITIES
-- ====================================================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local FILE_NAME = "AccessoryCustomConfigV4_2.json"

-- Menentukan tempat GUI yang aman (Support executor PC & Mobile)
local GUI_PARENT
if gethui then
    GUI_PARENT = gethui()
else
    local success, cg = pcall(function() return game:GetService("CoreGui") end)
    if success and cg then
        GUI_PARENT = cg
    else
        GUI_PARENT = localPlayer:WaitForChild("PlayerGui")
    end
end

-- Daftar Aksesoris Default
local accessoryIds = {
    ["Black Valk"] = 124730194,
    ["Violet Valk"] = 1402432199,
    ["8-Bit Royal Crown"] = 10159600649,
    ["Frozen Horn"] = 74891470,
    ["Poisoned Horns"] = 1744060292,
    ["Bunny Fedora"] = 108147416,
    ["Fiery Horns"] = 215718515
}

-- ID Khusus Model Kepala
local HEAD_IDS = {
    ["Death Walker"] = 99223542650102,
    ["UGC Headless"] = 15093053680
}

local KORBLOX_MESH_ID = "rbxassetid://101851696"
local KORBLOX_TEXTURE_ID = "rbxassetid://101851254"

-- Struktur Data
local spawnedAccessories = {}
local baseCFrames = {}
local currentConfig = { _HeadType = "Default", _Favorites = {} }
local selectedAccessory = nil
local targetPlayersRegistry = {} 

local function deepCopy(t)
    if type(t) ~= "table" then return t end
    local res = {}
    for k, v in pairs(t) do res[k] = deepCopy(v) end
    return res
end

-- Menyimpan AssetId ke Config
local function initConfig(name, id)
    if not currentConfig[name] then
        currentConfig[name] = { pos = {0,0,0}, rot = {0,0,0}, scale = 1, enabled = true, assetId = id }
    elseif id and not currentConfig[name].assetId then
        currentConfig[name].assetId = id
    end
end
for name, id in pairs(accessoryIds) do initConfig(name, id) end

-- ====================================================
-- FUNGSI KEPALA (HEAD)
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

        local handle
        if result:IsA("BasePart") then
            handle = result
        else
            handle = result:FindFirstChild("Handle") or result:FindFirstChildOfClass("Part") or result:FindFirstChildOfClass("MeshPart")
        end

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

-- ====================================================
-- FUNGSI AKSESORIS UMUM & KORBLOX
-- ====================================================
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
            if v:IsA("BasePart") then
                v.Anchored = false
                v.CanCollide = false
            end
        end

        local handle
        if result:IsA("BasePart") then
            handle = result
        else
            handle = result:FindFirstChild("Handle") or result:FindFirstChildOfClass("Part") or result:FindFirstChildOfClass("MeshPart")
        end

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
            rUpper.Transparency = 1
            rLower.Transparency = 1
            rFoot.Transparency = 1
            
            local oldFake = char:FindFirstChild("FakeKorbloxLeg")
            if oldFake then oldFake:Destroy() end
            
            local fakeLeg = Instance.new("Part")
            fakeLeg.Name = "FakeKorbloxLeg"
            fakeLeg.Size = Vector3.new(1, 2, 1)
            fakeLeg.Anchored = false
            fakeLeg.CanCollide = false
            fakeLeg.Transparency = 0
            fakeLeg.Archivable = true
            
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
        for k, v in pairs(spawnedAccessories[char]) do
            if v and v.Parent then v:Destroy() end
        end
        spawnedAccessories[char] = {}
    end
    
    for name, id in pairs(accessoryIds) do
        if cfg[name] and cfg[name].enabled then wearAccessory(char, name, id, cfg) end
    end
    
    applyKorblox(char)
    applyHeadState(char, cfg)
end

-- ====================================================
-- SISTEM LOCK & DETEKSI CUTSCENE / CLONE (UPDATED)
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

-- Deteksi Workspace
table.insert(scriptConnections, workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
        task.wait(0.5) -- Delay Cutscene Clone
        local isLocalClone = false
        
        if obj.Name == localPlayer.Name and obj ~= localPlayer.Character then
            isLocalClone = true
        else
            local myShirt = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Shirt")
            local cloneShirt = obj:FindFirstChildOfClass("Shirt")
            if myShirt and cloneShirt and myShirt.ShirtTemplate == cloneShirt.ShirtTemplate then
                isLocalClone = true
            end
        end

        if isLocalClone then
            refreshCharacter(obj, currentConfig)
        else
            local tPlayer = getTargetPlayer(obj.Name)
            if tPlayer and tPlayer.Name == obj.Name and obj ~= tPlayer.Character then
                if targetPlayersRegistry[tPlayer.UserId] then
                    refreshCharacter(obj, targetPlayersRegistry[tPlayer.UserId])
                end
            end
        end
    end
end))

-- Deteksi Cutscene by Kamera
local camera = workspace.CurrentCamera
local function onCameraSubjectChanged()
    if camera and camera.CameraSubject then
        local subject = camera.CameraSubject
        if subject:IsA("Humanoid") then
            local model = subject.Parent
            if model and model:IsA("Model") and model ~= localPlayer.Character then
                task.wait(0.3)
                refreshCharacter(model, currentConfig)
            end
        end
    end
end

if camera then
    table.insert(scriptConnections, camera:GetPropertyChangedSignal("CameraSubject"):Connect(onCameraSubjectChanged))
    task.spawn(onCameraSubjectChanged)
end

-- Deteksi First Person Transparansi
table.insert(scriptConnections, RunService.Stepped:Connect(function()
    local function enforceTransparency(char, config)
        if not char then return end
        
        local head = char:FindFirstChild("Head")
        local ltm = head and head.LocalTransparencyModifier or 0
        
        if spawnedAccessories[char] then
            for _, acc in pairs(spawnedAccessories[char]) do
                for _, v in ipairs(acc:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.LocalTransparencyModifier = ltm
                    end
                end
            end
        end

        local customHead = char:FindFirstChild("CustomHeadModel")
        if customHead then
            for _, v in ipairs(customHead:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.LocalTransparencyModifier = ltm
                end
            end
        end
        
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
-- PEMBUATAN GUI EDITOR
-- ====================================================
if GUI_PARENT:FindFirstChild("AccessoryEditorUI") then GUI_PARENT.AccessoryEditorUI:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = "AccessoryEditorUI"
sg.ResetOnSpawn = false 
sg.Parent = GUI_PARENT

local minSquare = Instance.new("TextButton")
minSquare.Size, minSquare.Position = UDim2.new(0, 40, 0, 40), UDim2.new(0.5, -20, 0, 20)
minSquare.BackgroundColor3, minSquare.Text = Color3.fromRGB(40, 40, 40), "+"
minSquare.TextColor3, minSquare.Font, minSquare.TextSize = Color3.fromRGB(255, 255, 255), Enum.Font.SourceSansBold, 24
minSquare.BorderSizePixel, minSquare.Visible, minSquare.Draggable, minSquare.Active = 0, false, true, true
minSquare.Parent = sg

local main = Instance.new("Frame")
main.Size, main.Position = UDim2.new(0, 420, 0, 300), UDim2.new(0.5, -210, 0.5, -150)
main.BackgroundColor3, main.BorderSizePixel = Color3.fromRGB(25, 25, 25), 0
main.BackgroundTransparency = 0.2
main.Active, main.Draggable = true, true
main.Parent = sg

local title = Instance.new("TextLabel")
title.Size, title.BackgroundColor3 = UDim2.new(1, 0, 0, 25), Color3.fromRGB(40, 40, 40)
title.BackgroundTransparency = 0.2
title.Text, title.TextColor3 = "  Accessory Configurator PRO V4.2", Color3.fromRGB(255, 255, 255)
title.Font, title.TextSize, title.TextXAlignment = Enum.Font.SourceSansBold, 14, Enum.TextXAlignment.Left
title.Parent = main

local btnMin = Instance.new("TextButton")
btnMin.Size, btnMin.Position, btnMin.BackgroundColor3 = UDim2.new(0, 25, 0, 25), UDim2.new(1, -25, 0, 0), Color3.fromRGB(200, 50, 50)
btnMin.Text, btnMin.TextColor3, btnMin.BorderSizePixel = "-", Color3.fromRGB(255, 255, 255), 0
btnMin.Parent = title

btnMin.MouseButton1Click:Connect(function() main.Visible = false; minSquare.Visible = true end)
minSquare.MouseButton1Click:Connect(function() main.Visible = true; minSquare.Visible = false end)

local content = Instance.new("Frame")
content.Size, content.Position, content.BackgroundTransparency = UDim2.new(1, 0, 1, -25), UDim2.new(0, 0, 0, 25), 1
content.Parent = main

local listFrame = Instance.new("ScrollingFrame")
listFrame.Size, listFrame.Position, listFrame.BackgroundColor3 = UDim2.new(0, 130, 1, -10), UDim2.new(0, 5, 0, 5), Color3.fromRGB(20, 20, 20)
listFrame.BackgroundTransparency = 0.2
listFrame.BorderSizePixel, listFrame.ScrollBarThickness, listFrame.CanvasSize = UDim2.new(0, 0, 0, 400), 4, UDim2.new(0, 0, 0, 400)
listFrame.Parent = content

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 2)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder -- Menggunakan LayoutOrder agar posisi bisa diurutkan
listLayout.Parent = listFrame

local panel = Instance.new("Frame")
panel.Size, panel.Position, panel.BackgroundTransparency = UDim2.new(1, -145, 1, -10), UDim2.new(0, 140, 0, 5), 1
panel.Parent = content

local activeLabel = Instance.new("TextLabel")
activeLabel.Size, activeLabel.Text, activeLabel.TextColor3 = UDim2.new(1, 0, 0, 15), "Editing: None", Color3.fromRGB(255, 200, 0)
activeLabel.Font, activeLabel.TextSize, activeLabel.BackgroundTransparency = Enum.Font.SourceSansBold, 13, 1
activeLabel.TextXAlignment = Enum.TextXAlignment.Left
activeLabel.Parent = panel

local btnToggle = Instance.new("TextButton")
btnToggle.Size, btnToggle.Position, btnToggle.BackgroundColor3 = UDim2.new(0, 80, 0, 20), UDim2.new(1, -85, 0, 0), Color3.fromRGB(100, 100, 100)
btnToggle.Text, btnToggle.TextColor3 = "Status: -", Color3.fromRGB(255, 255, 255)
btnToggle.Font, btnToggle.TextSize = Enum.Font.SourceSansBold, 12
btnToggle.Parent = panel

local inputs = {pos = {}, rot = {}, scale = nil}
local function createXYZRow(labelName, yPos, key)
    local lbl = Instance.new("TextLabel")
    lbl.Size, lbl.Position, lbl.Text, lbl.TextColor3 = UDim2.new(0, 30, 0, 20), UDim2.new(0, 0, 0, yPos), labelName, Color3.fromRGB(200, 200, 200)
    lbl.Font, lbl.TextSize, lbl.BackgroundTransparency, lbl.TextXAlignment = Enum.Font.SourceSans, 12, 1, Enum.TextXAlignment.Left
    lbl.Parent = panel
    for i, axis in ipairs({"X", "Y", "Z"}) do
        local box = Instance.new("TextBox")
        box.Size, box.Position, box.BackgroundColor3 = UDim2.new(0, 50, 0, 20), UDim2.new(0, 35 + (i-1)*55, 0, yPos), Color3.fromRGB(40, 40, 40)
        box.TextColor3, box.Font, box.TextSize, box.Text = Color3.fromRGB(255, 255, 255), Enum.Font.Code, 11, "0"
        box.Parent = panel
        inputs[key][axis] = box
    end
end

createXYZRow("Pos:", 25, "pos")
createXYZRow("Rot:", 50, "rot")

local lblScale = Instance.new("TextLabel")
lblScale.Size, lblScale.Position, lblScale.Text, lblScale.TextColor3 = UDim2.new(0, 60, 0, 20), UDim2.new(0, 0, 0, 75), "Overall Scale:", Color3.fromRGB(200, 200, 200)
lblScale.Font, lblScale.TextSize, lblScale.BackgroundTransparency, lblScale.TextXAlignment = Enum.Font.SourceSans, 12, 1, Enum.TextXAlignment.Left
lblScale.Parent = panel
inputs.scale = Instance.new("TextBox")
inputs.scale.Size, inputs.scale.Position, inputs.scale.BackgroundColor3 = UDim2.new(0, 60, 0, 20), UDim2.new(0, 65, 0, 75), Color3.fromRGB(40, 40, 40)
inputs.scale.TextColor3, inputs.scale.Font, inputs.scale.TextSize, inputs.scale.Text = Color3.fromRGB(255, 255, 255), Enum.Font.Code, 11, "1"
inputs.scale.Parent = panel

local function createBtn(text, pos, color, parent)
    local b = Instance.new("TextButton")
    b.Size, b.Position, b.BackgroundColor3 = UDim2.new(0, 115, 0, 22), pos, color
    b.Text, b.TextColor3, b.Font, b.TextSize = text, Color3.fromRGB(255, 255, 255), Enum.Font.SourceSansBold, 12
    b.Parent = parent
    return b
end

local btnApply = createBtn("Apply Change", UDim2.new(0, 0, 0, 105), Color3.fromRGB(0, 120, 215), panel)
local btnReset = createBtn("Reset All", UDim2.new(0, 125, 0, 105), Color3.fromRGB(200, 100, 0), panel)
local btnSave = createBtn("Save Config", UDim2.new(0, 0, 0, 132), Color3.fromRGB(46, 125, 50), panel)
local btnLoad = createBtn("Load Config", UDim2.new(0, 125, 0, 132), Color3.fromRGB(198, 105, 0), panel)

local addIdBox = Instance.new("TextBox")
addIdBox.Size, addIdBox.Position, addIdBox.BackgroundColor3 = UDim2.new(0, 150, 0, 22), UDim2.new(0, 0, 0, 160), Color3.fromRGB(35, 35, 35)
addIdBox.TextColor3, addIdBox.PlaceholderText, addIdBox.Font, addIdBox.TextSize = Color3.fromRGB(255, 255, 255), "Catalog ID...", Enum.Font.SourceSans, 12
addIdBox.Parent = panel

local btnAddId = createBtn("Add", UDim2.new(0, 160, 0, 160), Color3.fromRGB(120, 0, 215), panel)
btnAddId.Size = UDim2.new(0, 80, 0, 22)

local targetBox = Instance.new("TextBox")
targetBox.Size, targetBox.Position, targetBox.BackgroundColor3 = UDim2.new(0, 150, 0, 22), UDim2.new(0, 0, 0, 190), Color3.fromRGB(35, 35, 35)
targetBox.TextColor3, targetBox.PlaceholderText, targetBox.Font, targetBox.TextSize = Color3.fromRGB(255, 255, 255), "Target Player Name...", Enum.Font.SourceSans, 12
targetBox.Parent = panel

local btnTarget = createBtn("Lock to Player", UDim2.new(0, 160, 0, 190), Color3.fromRGB(180, 20, 50), panel)
btnTarget.Size = UDim2.new(0, 80, 0, 22)

local lblHead = Instance.new("TextLabel")
lblHead.Size, lblHead.Position = UDim2.new(0, 60, 0, 20), UDim2.new(0, 0, 0, 220)
lblHead.Text, lblHead.TextColor3 = "Head:", Color3.fromRGB(200, 200, 200)
lblHead.Font, lblHead.TextSize, lblHead.BackgroundTransparency = Enum.Font.SourceSansBold, 12, 1
lblHead.TextXAlignment = Enum.TextXAlignment.Left
lblHead.Parent = panel

local btnHeadDefault = createBtn("Default", UDim2.new(0, 45, 0, 220), Color3.fromRGB(60, 60, 60), panel)
btnHeadDefault.Size = UDim2.new(0, 55, 0, 22)
local btnHeadDeath = createBtn("Death W.", UDim2.new(0, 105, 0, 220), Color3.fromRGB(150, 20, 20), panel)
btnHeadDeath.Size = UDim2.new(0, 65, 0, 22)
local btnHeadHeadless = createBtn("Headless", UDim2.new(0, 175, 0, 220), Color3.fromRGB(100, 20, 150), panel)
btnHeadHeadless.Size = UDim2.new(0, 65, 0, 22)

local function changeHead(typeStr)
    currentConfig._HeadType = typeStr
    if localPlayer.Character then refreshCharacter(localPlayer.Character, currentConfig) end
    
    for userId, config in pairs(targetPlayersRegistry) do
        local p = Players:GetPlayerByUserId(userId)
        if p and p.Character then
            config._HeadType = typeStr
            refreshCharacter(p.Character, config)
        end
    end
end
btnHeadDefault.MouseButton1Click:Connect(function() changeHead("Default") end)
btnHeadDeath.MouseButton1Click:Connect(function() changeHead("Death Walker") end)
btnHeadHeadless.MouseButton1Click:Connect(function() changeHead("UGC Headless") end)

btnTarget.MouseButton1Click:Connect(function()
    local p = getTargetPlayer(targetBox.Text)
    if p then
        targetPlayersRegistry[p.UserId] = deepCopy(currentConfig)
        if p.Character then refreshCharacter(p.Character, targetPlayersRegistry[p.UserId]) end
        
        targetBox.Text = "Locked: " .. p.Name
        task.delay(2, function() if targetBox.Text:find("Locked:") then targetBox.Text = "" end end)
    else
        targetBox.Text = "Player Not Found!"
        task.delay(2, function() if targetBox.Text == "Player Not Found!" then targetBox.Text = "" end end)
    end
end)

local function updateUIText()
    if not selectedAccessory then return end
    activeLabel.Text = "Editing: " .. selectedAccessory

    local cfg = currentConfig[selectedAccessory]
    if cfg then
        for i, axis in ipairs({"X", "Y", "Z"}) do
            inputs["pos"][axis].Text = tostring(cfg.pos[i])
            inputs["rot"][axis].Text = tostring(cfg.rot[i])
        end
        inputs.scale.Text = tostring(cfg.scale)
        
        if cfg.enabled then
            btnToggle.Text = "Status: ON"
            btnToggle.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
        else
            btnToggle.Text = "Status: OFF"
            btnToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    end
end

btnToggle.MouseButton1Click:Connect(function()
    if not selectedAccessory then return end
    currentConfig[selectedAccessory].enabled = not currentConfig[selectedAccessory].enabled
    updateUIText()
    
    if localPlayer.Character then
        if currentConfig[selectedAccessory].enabled then
            wearAccessory(localPlayer.Character, selectedAccessory, accessoryIds[selectedAccessory], currentConfig)
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
            config[selectedAccessory].enabled = currentConfig[selectedAccessory].enabled
            if config[selectedAccessory].enabled then
                wearAccessory(p.Character, selectedAccessory, accessoryIds[selectedAccessory], config)
            else
                if spawnedAccessories[p.Character] and spawnedAccessories[p.Character][selectedAccessory] then
                    spawnedAccessories[p.Character][selectedAccessory]:Destroy()
                    spawnedAccessories[p.Character][selectedAccessory] = nil
                end
            end
        end
    end
end)

btnApply.MouseButton1Click:Connect(function()
    if not selectedAccessory then return end
    currentConfig[selectedAccessory].pos = {tonumber(inputs.pos.X.Text) or 0, tonumber(inputs.pos.Y.Text) or 0, tonumber(inputs.pos.Z.Text) or 0}
    currentConfig[selectedAccessory].rot = {tonumber(inputs.rot.X.Text) or 0, tonumber(inputs.rot.Y.Text) or 0, tonumber(inputs.rot.Z.Text) or 0}
    currentConfig[selectedAccessory].scale = tonumber(inputs.scale.Text) or 1
    
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
end)

btnSave.MouseButton1Click:Connect(function()
    if writefile then
        local success, encoded = pcall(function() return HttpService:JSONEncode(currentConfig) end)
        if success then writefile(FILE_NAME, encoded) end
    end
end)

-- ====================================================
-- FUNGSI POPULATE LIST WITH FAVORITE SYSTEM
-- ====================================================
local function populateList()
    if not currentConfig._Favorites then currentConfig._Favorites = {} end
    
    for _, child in ipairs(listFrame:GetChildren()) do 
        if child:IsA("TextButton") then child:Destroy() end 
    end
    
    for name, _ in pairs(accessoryIds) do
        local isFavorite = currentConfig._Favorites[name] or false
        
        local btn = Instance.new("TextButton")
        btn.Size, btn.BackgroundColor3 = UDim2.new(1, 0, 0, 24), Color3.fromRGB(50, 50, 50)
        btn.BackgroundTransparency = 0.2
        btn.Text, btn.TextColor3 = "  " .. name, Color3.fromRGB(255, 255, 255)
        btn.Font, btn.TextSize, btn.BorderSizePixel = Enum.Font.SourceSans, 12, 0
        btn.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Mengatur urutan: Favorite mendapatkan LayoutOrder 1 (di atas), non-favorite mendapat 2
        btn.LayoutOrder = isFavorite and 1 or 2
        btn.Parent = listFrame
        
        btn.MouseButton1Click:Connect(function() selectedAccessory = name; updateUIText() end)
        
        -- Membuat tombol Favorite (Bintang)
        local favBtn = Instance.new("TextButton")
        favBtn.Size = UDim2.new(0, 24, 0, 24)
        favBtn.Position = UDim2.new(1, -24, 0, 0)
        favBtn.BackgroundTransparency = 1
        favBtn.Text = isFavorite and "⭐" or "☆"
        favBtn.TextColor3 = isFavorite and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(150, 150, 150)
        favBtn.Font = Enum.Font.SourceSansBold
        favBtn.TextSize = 14
        favBtn.BorderSizePixel = 0
        favBtn.Parent = btn
        
        favBtn.MouseButton1Click:Connect(function()
            currentConfig._Favorites[name] = not currentConfig._Favorites[name]
            populateList() -- Re-populate untuk langsung memperbarui urutan posisi ke paling atas
        end)
    end
end

-- Load Config Custom
btnLoad.MouseButton1Click:Connect(function()
    if readfile and isfile and isfile(FILE_NAME) then
        local suc, c = pcall(function() return readfile(FILE_NAME) end)
        if suc then
            local ds, dec = pcall(function() return HttpService:JSONDecode(c) end)
            if ds then 
                for k, v in pairs(dec) do 
                    currentConfig[k] = v 
                    if type(v) == "table" and v.assetId then
                        accessoryIds[k] = v.assetId
                    end
                end 
                if not currentConfig._Favorites then currentConfig._Favorites = {} end
                for n, id in pairs(accessoryIds) do initConfig(n, id) end
                populateList()
            end
        end
    end
    updateUIText()
    if localPlayer.Character then refreshCharacter(localPlayer.Character, currentConfig) end
end)

-- Menambah ID
btnAddId.MouseButton1Click:Connect(function()
    local id = tonumber(addIdBox.Text)
    if id then
        addIdBox.Text = "Loading..."
        local success, info = pcall(function() return MarketplaceService:GetProductInfo(id) end)
        local newName = success and info.Name or ("Custom_" .. id)
        accessoryIds[newName] = id
        initConfig(newName, id)
        populateList()
        addIdBox.Text = ""
        addIdBox.PlaceholderText = "Added: " .. newName
        if localPlayer.Character then wearAccessory(localPlayer.Character, newName, id, currentConfig) end
    end
end)

populateList()
if localPlayer.Character then refreshCharacter(localPlayer.Character, currentConfig) end
table.insert(scriptConnections, localPlayer.CharacterAdded:Connect(function(char) task.wait(1); refreshCharacter(char, currentConfig) end))
task.spawn(function() btnLoad.MouseButton1Click:Fire() end)

-- ====================================================
-- MENDAFTARKAN FUNGSI CLEANUP UNTUK EKSEKUSI BERIKUTNYA
-- ====================================================
getgenv()._LucxxHubCleanup = function()
    for _, conn in ipairs(scriptConnections) do
        if conn.Connected then conn:Disconnect() end
    end
    table.clear(scriptConnections)

    if GUI_PARENT:FindFirstChild("AccessoryEditorUI") then
        GUI_PARENT.AccessoryEditorUI:Destroy()
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
