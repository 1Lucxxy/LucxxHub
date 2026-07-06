-- [[ INTERNAL CONFIG & SERVICES ]] --
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- Fungsi untuk memunculkan notifikasi bawaan Roblox
local function showNotification(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5
    })
end

-- [[ MEMBUAT UI INTERFACE ]] --
-- Menggunakan CoreGui agar tidak hilang saat player mati (ResetOnSpawn = false)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomExecutorGUI"
ScreenGui.ResetOnSpawn = false
-- Mencoba masuk ke CoreGui, jika gagal (karena tingkat executor) masuk ke PlayerGui
local successGui, errGui = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not successGui then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame (Background GUI)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -90) -- Di tengah layar
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true -- Wajib true untuk fitur drag/moveable
MainFrame.Parent = ScreenGui

-- Mengaluskan sudut GUI (UI Corner)
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Judul GUI
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "SCRIPT HUB / EXECUTOR"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- [[ FITUR DRAGGABLE / MOVEABLE (PC & MOBILE) ]] --
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
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

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- [[ TOMBOL EKSEKUSI (BUTTONS) ]] --

-- Fungsi template untuk membuat tombol dengan cepat
local function createScriptButton(name, position, scriptFunction)
    local Button = Instance.new("TextButton")
    Button.Name = name .. "Btn"
    Button.Size = UDim2.new(0, 210, 0, 40)
    Button.Position = position
    Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.SourceSansSemibold
    Button.Parent = MainFrame

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button

    -- Logika Klik & Deteksi Error (pcall)
    Button.MouseButton1Click:Connect(function()
        -- pcall akan menjalankan fungsi secara aman tanpa menghentikan seluruh script jika ada error
        local success, errorMessage = pcall(scriptFunction)

        if success then
            showNotification("Berhasil!", name .. " sukses dieksekusi!", 4)
            ScreenGui:Destroy() -- Otomatis menghapus/kill GUI jika sukses
        else
            -- Jika gagal, GUI tidak dihapus dan memunculkan errornya di notifikasi
            local cleanError = errorMessage and tostring(errorMessage):match("[^:]+:[^:]+:%s*(.+)") or tostring(errorMessage)
            showNotification("Gagal!", name .. " gagal karena: " .. cleanError, 6)
        end
    end)
end

-- ==========================================
-- SCRIPT KAMU DI SINI (TEMPAT MENARUH SCRIPT)
-- ==========================================

-- 1. Script untuk Button A
local function ScriptA()
    loadstring(game:HttpGet("https://pastefy.app/zfWvyFav/raw"))()
end
    -- Ganti isi di dalam sini dengan script Button A milikmu
    print("Lucxx Accesories Berhasil Di Jalankan...")
    
    -- Contoh simulasi: memunculkan part di workspace (pasti berhasil)
    local part = Instance.new("Part")
    part.Position = LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
    part.Parent = workspace
end

-- 2. Script untuk Button B (Contoh simulasi script yang ERROR/GAGAL)
local function ScriptB()
    -- Ganti isi di dalam sini dengan script Button B milikmu
    print("Script B mencoba berjalan...")
    
    -- Sengaja dibuat error untuk tes fitur "Gagal dieksekusi"
    error("Variabel atau fungsi tidak ditemukan!") 
end


-- [[ MENAMPILKAN TOMBOL DI SCREEN ]] --
-- Format: createScriptButton("Nama Tombol", UDim2.new(X_Scale, X_Offset, Y_Scale, Y_Offset), NamaFungsiScript)
createScriptButton("Execute Script A", UDim2.new(0, 20, 0, 60), ScriptA)
createScriptButton("Execute Script B (Test Error)", UDim2.new(0, 20, 0, 110), ScriptB)
