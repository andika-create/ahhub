--[[
    ██████╗  ██████╗   ██████╗   ██╗
   ██╔════╝ ██╔═══██╗ ██╔═══██╗  ██║
   ██║      ██║   ██║ ██║   ██║  ██║
   ██║      ██║   ██║ ██║   ██║  ██║  (Ahok Hub - The Forge)
   ╚██████╗ ╚██████╔╝ ╚██████╔╝  ██║
    ╚═════╝  ╚═════╝   ╚═════╝   ╚═╝
    
    Branding: Ahok Hub
    Target Game: The Forge (PlaceID: 7671049560)
    Tujuan: Edukasi & Template Riset Game
--]]

-- ============================================
-- SECTION 1: KONFIGURASI
-- ============================================
local CONFIG = {
    HUB_NAME    = "Ahok Hub",
    VERSION     = "1.0.0",
    PLACE_ID    = 7671049560,  -- PlaceId The Forge
    CONFIG_FILE = "ahok_hub_config.json",
}

-- ============================================
-- SECTION 2: SERVICES
-- ============================================
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService    = game:GetService("HttpService")

-- ============================================
-- SECTION 3: PLAYER SHORTCUTS
-- ============================================
local LocalPlayer = Players.LocalPlayer
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end
local function getHRP()
    local char = getCharacter()
    return char:WaitForChild("HumanoidRootPart", 5)
end
local function getHumanoid()
    local char = getCharacter()
    return char:WaitForChild("Humanoid", 5)
end

-- ============================================
-- SECTION 4: LOGGER
-- ============================================
local Log = {
    info  = function(...) print("["..CONFIG.HUB_NAME.."]", ...) end,
    warn  = function(...) warn("["..CONFIG.HUB_NAME.."]", ...) end,
}

-- ============================================
-- SECTION 5: FLAGS (Pengaturan Fitur)
-- ============================================
local flags = {
    SpeedEnabled    = false,
    SpeedAmount     = 50,
    ESPEnabled      = false,
    ESPColor        = Color3.fromRGB(255, 0, 0),
    AutoFarmEnabled = false,
}

-- Simpan ke getgenv() agar bisa diakses lewat console jika perlu
getgenv().AhokHubFlags = flags

-- ============================================
-- SECTION 6: UTILITIES
-- ============================================

-- Tween smooth movement
local function tweenTo(targetCFrame, speed)
    local hrp = getHRP()
    if not hrp then return end
    
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local duration = distance / (speed or 50)
    
    local tween = TweenService:Create(hrp, 
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        { CFrame = targetCFrame }
    )
    tween:Play()
    return tween
end

-- ============================================
-- SECTION 7: FEATURES
-- ============================================

-- >> Speed Hack
local speedConnection
local function setSpeed(enabled)
    flags.SpeedEnabled = enabled
    if speedConnection then speedConnection:Disconnect() end
    
    if not enabled then
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = 16 end
        return
    end
    
    local function apply()
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = flags.SpeedAmount end
    end
    
    apply()
    speedConnection = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        apply()
    end)
end

-- >> ESP Highlight
local espFolder = Instance.new("Folder")
espFolder.Name = "AhokHub_ESP"
espFolder.Parent = game:GetService("CoreGui") -- Coba simpan di CoreGui agar tidak terganggu game

local function updateESP()
    espFolder:ClearAllChildren()
    if not flags.ESPEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = Instance.new("Highlight")
            highlight.Name = player.Name
            highlight.FillColor = flags.ESPColor
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.FillTransparency = 0.5
            highlight.Parent = player.Character
        end
    end
end

-- >> Auto Farm (Logic dasar)
local function runAutoFarm()
    while flags.AutoFarmEnabled do
        -- Template Riset: Kamu perlu mencari Remote di ReplicatedStorage
        -- dan menambahkannya di sini.
        -- Contoh: ReplicatedStorage.Events.Mine:FireServer()
        task.wait(1)
    end
end

-- ============================================
-- SECTION 8: GUI BUILDER
-- ============================================
local function buildGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = CONFIG.HUB_NAME
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"))

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 250, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 200)
    TitleBar.Parent = MainFrame
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = CONFIG.HUB_NAME .. " v" .. CONFIG.VERSION
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = TitleBar

    -- Toggle Buttons Helper
    local function createToggle(text, yPos, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 35)
        btn.Position = UDim2.new(0.05, 0, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        btn.Text = text .. ": OFF"
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = MainFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local active = false
        btn.MouseButton1Click:Connect(function()
            active = not active
            btn.Text = text .. ": " .. (active and "ON" or "OFF")
            btn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45)
            callback(active)
        end)
    end

    createToggle("Speed Hack", 55, setSpeed)
    createToggle("ESP Player", 100, function(v) flags.ESPEnabled = v updateESP() end)
    createToggle("Auto Farm", 145, function(v) flags.AutoFarmEnabled = v if v then task.spawn(runAutoFarm) end end)

    -- Draggable Logic
    local dragging, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ============================================
-- SECTION 9: INIT
-- ============================================
local function init()
    if game.PlaceId ~= CONFIG.PLACE_ID and CONFIG.PLACE_ID ~= 0 then
        Log.warn("PlaceID tidak cocok! Script mungkin tidak bekerja maksimal.")
    end
    
    Log.info("Loading Hub...")
    buildGUI()
    Log.info("Ready!")
end

pcall(init)
