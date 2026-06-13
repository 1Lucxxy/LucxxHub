local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Universal ESP Script",
   LoadingTitle = "Memuat Hub...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "UniversalESPConfig",
      FileName = "ESP_Config"
   },
   KeySystem = false
})

-- Tab Utama untuk ESP
local ESPTab = Window:CreateTab("ESP Settings", 4483362458) -- ID ikon default

-- Fungsi Helper untuk membuat Highlight
local function applyHighlight(object, color)
    if not object:FindFirstChildOfClass("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Parent = object
        highlight.FillColor = color
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.Adornee = object
    end
end

-- Fungsi Helper untuk menghapus Highlight
local function removeHighlight(object)
    local highlight = object:FindFirstChildOfClass("Highlight")
    if highlight then
        highlight:Destroy()
    end
end

--- ==========================================
--- 1. PLAYER ESP
--- ==========================================
local playerESPConn
ESPTab:CreateToggle({
   Name = "Player ESP (Highlight)",
   CurrentValue = false,
   Flag = "PlayerToggle", 
   Callback = function(Value)
      if Value then
          playerESPConn = game:GetService("RunService").RenderStepped:Connect(function()
              for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
                  if plr ~= game:GetService("Players").LocalPlayer and plr.Character then
                      applyHighlight(plr.Character, Color3.fromRGB(255, 0, 0)) -- Merah untuk Player
                  end
              end
          end)
      else
          if playerESPConn then playerESPConn:Disconnect() end
          for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
              if plr.Character then removeHighlight(plr.Character) end
          end
      end
   end,
})

--- ==========================================
--- 2. ENTITY ESP (Monster/NPC)
--- ==========================================
-- CATATAN: Ubah game.Workspace.Entities sesuai dengan folder tempat monster di game targetmu.
local entityESPConn
ESPTab:CreateToggle({
   Name = "Entity / Monster ESP",
   CurrentValue = false,
   Flag = "EntityToggle",
   Callback = function(Value)
      local entityFolder = game.Workspace:FindFirstChild("Entities") or game.Workspace -- Sesuaikan ini
      
      if Value then
          entityESPConn = game:GetService("RunService").RenderStepped:Connect(function()
              for _, entity in pairs(entityFolder:GetChildren()) do
                  -- Contoh logika: Jika objek memiliki Humanoid dan bukan player
                  if entity:FindFirstChildOfClass("Humanoid") and not game:GetService("Players"):GetPlayerFromCharacter(entity) then
                      applyHighlight(entity, Color3.fromRGB(255, 165, 0)) -- Oranye untuk Entity
                  end
              end
          end)
      else
          if entityESPConn then entityESPConn:Disconnect() end
          for _, entity in pairs(entityFolder:GetChildren()) do
              removeHighlight(entity)
          end
      end
   end,
})

--- ==========================================
--- 3. ITEM ESP (Loot/Drop)
--- ==========================================
-- CATATAN: Ubah game.Workspace.Items sesuai dengan folder item di game targetmu.
local itemESPConn
ESPTab:CreateToggle({
   Name = "Item / Loot ESP",
   CurrentValue = false,
   Flag = "ItemToggle",
   Callback = function(Value)
      local itemFolder = game.Workspace:FindFirstChild("Items") or game.Workspace -- Sesuaikan ini
      
      if Value then
          itemESPConn = game:GetService("RunService").RenderStepped:Connect(function()
              for _, item in pairs(itemFolder:GetChildren()) do
                  -- Contoh logika: Jika objek adalah Tool atau memiliki ProximityPrompt khusus item
                  if item:IsA("Tool") or item:FindFirstChild("ItemTag") then 
                      applyHighlight(item, Color3.fromRGB(0, 0, 255)) -- Biru untuk Item
                  end
              end
          end)
      else
          if itemESPConn then itemESPConn:Disconnect() end
          for _, item in pairs(itemFolder:GetChildren()) do
              removeHighlight(item)
          end
      end
   end,
})

--- ==========================================
--- 4. INTERACTABLE ESP (Pintu, Tombol, dll)
--- ==========================================
local interactESPConn
ESPTab:CreateToggle({
   Name = "Interactable ESP (ProximityPrompt)",
   CurrentValue = false,
   Flag = "InteractToggle",
   Callback = function(Value)
      if Value then
          interactESPConn = game:GetService("RunService").RenderStepped:Connect(function()
              -- Mencari semua objek yang memiliki ProximityPrompt di Workspace
              for _, desc in pairs(game.Workspace:GetDescendants()) do
                  if desc:IsA("ProximityPrompt") then
                      local parentObj = desc.Parent
                      if parentObj and parentObj:IsA("Model") or parentObj:IsA("BasePart") then
                          applyHighlight(parentObj, Color3.fromRGB(0, 255, 0)) -- Hijau untuk Interactable
                      end
                  end
              end
          end)
      else
          if interactESPConn then interactESPConn:Disconnect() end
          for _, desc in pairs(game.Workspace:GetDescendants()) do
              if desc:IsA("ProximityPrompt") then
                  local parentObj = desc.Parent
                  if parentObj then removeHighlight(parentObj) end
              end
          end
      end
   end,
})

-- Notifikasi bahwa script berhasil dimuat
Rayfield:Notify({
   Title = "ESP Script",
   Content = "Berhasil memuat menu ESP!",
   Duration = 5,
   Image = 4483362458,
})
