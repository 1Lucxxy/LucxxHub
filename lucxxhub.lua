-- ====================================================
-- IMPLEMENTASI WINDUI DENGAN LINK YANG SUDAH DIPERBAIKI
-- ====================================================
-- Menggunakan link raw ke dist main WindUI dari sumber resmi GitHub
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "LucxxHub",
    Icon = "lucide-gamepad-2", -- Icon UI telah diubah
    Author = "Fayyxie",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 160,
    HasOutline = false
})

getgenv()._LucxxWindUIWindow = Window

-- HANYA 2 TAB SESUAI PERMINTAAN
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
Tabs.Player:Section({ Title = "Accessory Editor" })

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

Tabs.Player:Section({ Title = "Transform Settings" })

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

Tabs.Player:Section({ Title = "Head Customization" })

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

Tabs.Player:Section({ Title = "Target System" })

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
Tabs.Settings:Section({ Title = "Custom Accessories" })

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

Tabs.Settings:Section({ Title = "Save / Load Configuration" })

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

Tabs.Settings:Section({ Title = "UI Personalization" })

-- Menambahkan fitur ganti tema yang diminta
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
