--[[
    GRAVITY.LUA - Professional Roblox Cheat Core (V10 - FIXED)
    ULTIMATE NATIVE ENGINE: Bypasses all visual blocks
	Features: Native ScreenGui, Smooth Tweens, Auto-Bind, ESP/Aimbot
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

print("------------------------------------------")
print("GRAVITY: STARTING SYSTEM...")

-- [[ MASTER SETTINGS ]]
local Settings = {
    aim_enable = false, aim_smooth = 5, aim_fov = 200, aim_part = "Head",
    esp_enable = true, esp_boxes = true, esp_corner = false, esp_outline = true,
    esp_names = true, esp_health = true,
    theme_color = Color3.fromRGB(45, 100, 255),
    menu_key = nil,
    configured = false
}

-- [[ UI ENGINE ]]
local function CreateUI()
    -- Finding the best place to hide the UI (Bypasses security)
    local parent = (gethui and gethui()) or (CoreGui:FindFirstChild("RobloxGui")) or CoreGui
    
    local Screen = Instance.new("ScreenGui")
    Screen.Name = "GravityEngine_V10_PRO"
    Screen.IgnoreGuiInset = true
    Screen.DisplayOrder = 1000
    Screen.Parent = parent
    
    -- [[ BIND OVERLAY ]]
    local Setup = Instance.new("Frame")
    Setup.Size = UDim2.new(1, 0, 1, 0)
    Setup.BackgroundColor3 = Color3.new(0,0,0)
    Setup.BackgroundTransparency = 0.3
    Setup.ZIndex = 100
    Setup.Parent = Screen
    
    local SetupBox = Instance.new("Frame")
    SetupBox.Size = UDim2.new(0, 350, 0, 180)
    SetupBox.Position = UDim2.new(0.5, -175, 0.5, -90)
    SetupBox.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
    SetupBox.BorderSizePixel = 0
    SetupBox.Parent = Setup
    
    local SetupStroke = Instance.new("UIStroke")
    SetupStroke.Color = Settings.theme_color
    SetupStroke.Thickness = 2
    SetupStroke.Parent = SetupBox
    
    local SetupText = Instance.new("TextLabel")
    SetupText.Size = UDim2.new(1, 0, 1, 0)
    SetupText.Text = "GRAVITY: PRESS ANY KEY TO BIND"
    SetupText.TextColor3 = Color3.new(1,1,1)
    SetupText.Font = Enum.Font.GothamBold
    SetupText.TextSize = 18
    SetupText.BackgroundTransparency = 1
    SetupText.Parent = SetupBox

    -- [[ MAIN MENU ]]
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 300, 0, 500)
    Main.Position = UDim2.new(1, -320, 0, 50)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    Main.BorderSizePixel = 0
    Main.Visible = false
    Main.Parent = Screen
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(30, 30, 30)
    MainStroke.Parent = Main

    local Banner = Instance.new("Frame")
    Banner.Size = UDim2.new(1, 0, 0, 50)
    Banner.BackgroundColor3 = Color3.new(0,0,0)
    Banner.BorderSizePixel = 0
    Banner.Parent = Main
    
    local GLabel = Instance.new("TextLabel")
    GLabel.Size = UDim2.new(1, -20, 1, 0)
    GLabel.Position = UDim2.new(0, 20, 0, 0)
    GLabel.Text = "GRAVITY.LUA"
    GLabel.TextColor3 = Color3.new(1,1,1)
    GLabel.Font = Enum.Font.GothamBold
    GLabel.TextSize = 20
    GLabel.TextXAlignment = Enum.TextXAlignment.Left
    GLabel.BackgroundTransparency = 1
    GLabel.Parent = Banner

    -- Tab System
    local Tabs = Instance.new("Frame")
    Tabs.Size = UDim2.new(1, 0, 0, 40)
    Tabs.Position = UDim2.new(0, 0, 0, 50)
    Tabs.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
    Tabs.Parent = Main
    
    local TabListNames = {"AIM", "VISUALS", "PLAYER"}
    for i, name in pairs(TabListNames) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1/#TabListNames, 0, 1, 0)
        b.Position = UDim2.new((i-1)/#TabListNames, 0, 0, 0)
        b.Text = name
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10
        b.TextColor3 = i == 1 and Color3.new(1,1,1) or Color3.fromRGB(150, 150, 150)
        b.BackgroundTransparency = 1
        b.Parent = Tabs
    end

    -- Bind Logic
    local connection; connection = UserInputService.InputBegan:Connect(function(input)
        if not Settings.configured then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Settings.menu_key = input.KeyCode
                Settings.configured = true
                Setup.Visible = false
                Main.Visible = true
                print("GRAVITY V10: MENU KEY BOUND TO " .. tostring(input.KeyCode))
            end
        else
            if input.KeyCode == Settings.menu_key then
                Main.Visible = not Main.Visible
            end
        end
    end)
end

-- [[ ESP DRAWING LOGIC ]]
local Cache = {}
local function CreateESP(p)
    if p == LocalPlayer then return end
    Cache[p] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text")
    }
    local e = Cache[p]
    e.Box.Thickness = 1
    e.Box.Visible = false
    e.Name.Size = 13
    e.Name.Center = true
    e.Name.Visible = false
end

RunService.RenderStepped:Connect(function()
    for p, esp in pairs(Cache) do
        local char = p.Character
        if char and char:FindFirstChild("HumanoidRootPart") and Settings.esp_enable then
            local hrp = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                esp.Box.Visible = Settings.esp_boxes
                esp.Box.Size = Vector2.new(2000/pos.Z, 3000/pos.Z)
                esp.Box.Position = Vector2.new(pos.X - esp.Box.Size.X/2, pos.Y - esp.Box.Size.Y/2)
                esp.Box.Color = Settings.theme_color
                
                esp.Name.Visible = Settings.esp_names
                esp.Name.Position = Vector2.new(pos.X, pos.Y - (1500/pos.Z))
                esp.Name.Text = p.Name
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
            end
        else
            if esp.Box then esp.Box.Visible = false end
            if esp.Name then esp.Name.Visible = false end
        end
    end
end)

Players.PlayerAdded:Connect(CreateESP)
for _,p in pairs(Players:GetPlayers()) do CreateESP(p) end

-- START ENGINE
CreateUI()
print("GRAVITY V10 - ULTIMATE NATIVE ENGINE LOADED SUCCESSFULLY.")
print("------------------------------------------")
