--[[
    ██████╗  ██████╗   ██████╗   ██╗
   ██╔════╝ ██╔═══██╗ ██╔═══██╗  ██║
   ██║      ██║   ██║ ██║   ██║  ██║
   ██║      ██║   ██║ ██║   ██║  ██║  (Ahok Hub - Advanced Edition)
   ╚██████╗ ╚██████╔╝ ╚██████╔╝  ██║
    ╚═════╝  ╚═════╝   ╚═════╝   ╚═╝
    
    Refined based on "The Forge" working patterns.
    Features: Hookmetamethod Bypass, Anim-based Parry, Advanced Tweens.
--]]

-- ============================================
-- SECTION 1: KONFIGURASI
-- ============================================
local CONFIG = {
    HUB_NAME    = "Ahok Hub VIP",
    VERSION     = "1.1.0",
    PLACE_ID    = 7671049560,
    CONFIG_FILE = "ahok_hub_v11.json",
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
-- SECTION 3: CORE VARIABLES
-- ============================================
local LocalPlayer = Players.LocalPlayer
local flags = {
    WalkSpeed      = 90, -- Default ditingkatkan ke 90
    SpeedEnabled   = false,
    AutoParry      = false,
    AutoFarm       = false,
    ESP            = false,
    InfJump        = false,
    TeleportSpeed  = 50,
}
getgenv().AhokFlags = flags

-- ============================================
-- SECTION 4: HELPERS
-- ============================================
local function getChar() return LocalPlayer.Character end
local function getHum() return getChar() and getChar():FindFirstChildOfClass("Humanoid") end
local function getHRP() return getChar() and getChar():FindFirstChild("HumanoidRootPart") end

-- ============================================
-- SECTION 5: BYPASS (ANTI-ANTI CHEAT)
-- ============================================
local oldIndex
oldIndex = hookmetamethod(game, "__newindex", function(self, key, value)
    if not checkcaller() and flags.SpeedEnabled and self:IsA("Humanoid") and key == "WalkSpeed" then
        -- Mencegah game mereset WalkSpeed kita
        return oldIndex(self, key, flags.WalkSpeed)
    end
    return oldIndex(self, key, value)
end)

-- ============================================
-- SECTION 6: FEATURES LOGIC
-- ============================================

-- >> Advanced Speed
task.spawn(function()
    while task.wait(0.1) do
        if flags.SpeedEnabled then
            local hum = getHum()
            if hum then hum.WalkSpeed = flags.WalkSpeed end
        end
    end
end)

-- >> Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if flags.InfJump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- >> Animation-Based Parry (Pattern from example)
local function setupParry(character)
    local hum = character:WaitForChild("Humanoid", 10)
    if not hum then return end
    
    hum.AnimationPlayed:Connect(function(animTrack)
        if flags.AutoParry then
            -- Cari animasi serangan musuh
            -- Kamu perlu riset nama animasi spesifik di "The Forge"
            local animName = animTrack.Animation.Name:lower()
            if animName:find("attack") or animName:find("swing") then
                -- Trigger Remote Parry (Contoh dari mapping remotes)
                -- ReplicatedStorage.Events.Parry:FireServer()
                print("Detected attack:", animName)
            end
        end
    end)
end

-- ============================================
-- SECTION 7: GUI BUILDER (Rayfield-style simple)
-- ============================================
local function buildGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AhokHubUI"
    
    -- Coba masukkan ke CoreGui dulu (biar tidak dicolong GUI explorer)
    -- Jika gagal (biasanya executor mobile tertentu), fallback ke PlayerGui
    local success, _ = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 300, 0, 350)
    Main.Position = UDim2.new(0.5, -150, 0.5, -175)
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

    local Top = Instance.new("Frame")
    Top.Size = UDim2.new(1, 0, 0, 40)
    Top.BackgroundColor3 = Color3.fromRGB(45, 45, 200)
    Top.Parent = Main
    Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 8)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "AHOK HUB VIP v" .. CONFIG.VERSION
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.Parent = Top

    -- Toggle Creator
    local currentOffset = 50
    local function createToggle(name, flagKey, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 35)
        btn.Position = UDim2.new(0.05, 0, 0, currentOffset)
        btn.BackgroundColor3 = flags[flagKey] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 45)
        btn.Text = name .. ": [ " .. (flags[flagKey] and "ON" or "OFF") .. " ]"
        btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = Main
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

        btn.MouseButton1Click:Connect(function()
            flags[flagKey] = not flags[flagKey]
            btn.Text = name .. ": [ " .. (flags[flagKey] and "ON" or "OFF") .. " ]"
            btn.BackgroundColor3 = flags[flagKey] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 45)
            if callback then callback(flags[flagKey]) end
        end)
        currentOffset = currentOffset + 40
    end

    -- Menambahkan semua tombol secara berurutan
    createToggle("Speed Bypass", "SpeedEnabled")
    createToggle("Infinite Jump", "InfJump")
    createToggle("Auto Parry", "AutoParry")
    createToggle("ESP Highlight", "ESP", function(state)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if state then
                    local h = Instance.new("Highlight", p.Character)
                    h.Name = "AhokESP"
                else
                    if p.Character:FindFirstChild("AhokESP") then
                        p.Character.AhokESP:Destroy()
                    end
                end
            end
        end
    end)

    -- Space for Slider
    currentOffset = currentOffset + 10

    -- Slider Speed
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(0.9, 0, 0, 20)
    SpeedLabel.Position = UDim2.new(0.05, 0, 0, currentOffset)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Text = "Speed: " .. flags.WalkSpeed
    SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
    SpeedLabel.Font = Enum.Font.Gotham
    SpeedLabel.TextSize = 12
    SpeedLabel.Parent = Main

    local SpeedSlider = Instance.new("TextButton")
    SpeedSlider.Size = UDim2.new(0.9, 0, 0, 10)
    SpeedSlider.Position = UDim2.new(0.05, 0, 0, currentOffset + 25)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    SpeedSlider.Text = ""
    SpeedSlider.Parent = Main
    Instance.new("UICorner", SpeedSlider).CornerRadius = UDim.new(0, 5)

    local function updateSpeed(input)
        local pos = math.clamp((input.Position.X - SpeedSlider.AbsolutePosition.X) / SpeedSlider.AbsoluteSize.X, 0, 1)
        flags.WalkSpeed = math.floor(16 + (pos * 134)) -- Range 16 to 150
        SpeedLabel.Text = "Speed: " .. flags.WalkSpeed
    end

    SpeedSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSpeed(input)
            local move; move = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then updateSpeed(input) end
            end)
            local endCon; endCon = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    move:Disconnect()
                    endCon:Disconnect()
                end
            end)
        end
    end)
    
    -- Dragging logic
    local gui = Main
    local dragging, dragInput, dragStart, startPos
    Top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ============================================
-- SECTION 8: STARTUP
-- ============================================
local function init()
    print("--- [ Ahok Hub Debug ] ---")
    print("Checking PlaceID: " .. game.PlaceId)
    
    -- Kita buat lebih fleksibel (tapi tetap ada peringatan)
    if game.PlaceId ~= CONFIG.PLACE_ID then
        warn("Ahok Hub: PlaceID tidak cocok (The Forge id: " .. CONFIG.PLACE_ID .. ")")
        print("Script akan tetap berjalan untuk testing...")
    end

    local success, err = pcall(function()
        buildGUI()
    end)

    if success then
        print("Ahok Hub: GUI Created Successfully!")
    else
        warn("Ahok Hub: Error building GUI: " .. tostring(err))
    end
end

init()
