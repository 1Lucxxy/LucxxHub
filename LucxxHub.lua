--// Macro: Dua Tombol Kanan Atas
local Player = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")

local Gui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
Gui.ResetOnSpawn = false

-- === TOMBOL 1: Hotbar 1 -> F ===
local Button1 = Instance.new("TextButton")
Button1.Parent = Gui
Button1.Text = "GUN"
Button1.TextScaled = false
Button1.TextSize = 14
Button1.Size = UDim2.new(0, 70, 0, 70)
Button1.AnchorPoint = Vector2.new(1, 0)
Button1.Position = UDim2.new(0.98, 0, 0.02, 0) -- pojok kanan atas
Button1.BackgroundTransparency = 1
Button1.TextColor3 = Color3.fromRGB(255, 255, 255)
Button1.Font = Enum.Font.SourceSans
Button1.ZIndex = 9999

local stroke1 = Instance.new("UIStroke", Button1)
stroke1.Color = Color3.fromRGB(255, 255, 255)
stroke1.Thickness = 1.2
stroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local corner1 = Instance.new("UICorner", Button1)
corner1.CornerRadius = UDim.new(1, 0)

-- Fungsi tombol 1
local function runMacro1()
    vim:SendKeyEvent(true, Enum.KeyCode.One, false, game)
    vim:SendKeyEvent(false, Enum.KeyCode.One, false, game)
    task.wait(1) -- jeda 1 detik
    vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

Button1.MouseButton1Click:Connect(runMacro1)

-- === TOMBOL 2: R -> F ===
local Button2 = Instance.new("TextButton")
Button2.Parent = Gui
Button2.Text = "RELOAD"
Button2.TextScaled = false
Button2.TextSize = 14
Button2.Size = UDim2.new(0, 70, 0, 70)
Button2.AnchorPoint = Vector2.new(1, 0)
Button2.Position = UDim2.new(0.85, 0, 0.02, 0) -- di samping kiri tombol 1
Button2.BackgroundTransparency = 1
Button2.TextColor3 = Color3.fromRGB(255, 255, 255)
Button2.Font = Enum.Font.SourceSans
Button2.ZIndex = 9999

local stroke2 = Instance.new("UIStroke", Button2)
stroke2.Color = Color3.fromRGB(255, 255, 255)
stroke2.Thickness = 1.2
stroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local corner2 = Instance.new("UICorner", Button2)
corner2.CornerRadius = UDim.new(1, 0)

-- Fungsi tombol 2
local function runMacro2()
    vim:SendKeyEvent(true, Enum.KeyCode.R, false, game)
    vim:SendKeyEvent(false, Enum.KeyCode.R, false, game)
    task.wait(2) -- jeda 2 detik
    vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

Button2.MouseButton1Click:Connect(runMacro2)
