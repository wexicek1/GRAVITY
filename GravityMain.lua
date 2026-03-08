--[[
    GRAVITY.LUA - Professional Roblox Cheat Core (V9)
    NATIVE UI ENGINE: Re-implemented CSS/JS visuals as native Roblox Objects
	Features: Bind Overlay, High-Quality Animations, ESP/Aimbot/Trolls
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ MASTER SETTINGS ]]
local Settings = {
    aim_enable = false, aim_smooth = 5, aim_fov = 200, aim_part = "Head",
    esp_enable = true, esp_boxes = true, esp_corner = false, esp_outline = true,
    esp_names = true, esp_health = true,
    theme_color = Color3.fromRGB(45, 100, 255),
    menu_key = Enum.KeyCode.RightControl,
    configured = false
}

-- [[ UI CONSTRUCTOR ]]
local GravityUI = {}

function GravityUI:Init()
    local Screen = Instance.new("ScreenGui")
    Screen.Name = "GravityV9"
    Screen.ResetOnSpawn = false
    Screen.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main Container
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 320, 0, 520)
    Main.Position = UDim2.new(1, -340, 0, 40)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    Main.BorderSizePixel = 0
    Main.Visible = false
    Main.Parent = Screen
    
    -- Banner
    local Banner = Instance.new("Frame")
    Banner.Size = UDim2.new(1, 0, 0, 70)
    Banner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Banner.BorderSizePixel = 0
    Banner.Parent = Main
    
    local Title = Instance.new("TextLabel")
    Title.Text = "GRAVITY.LUA"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.InterBold
    Title.TextSize = 24
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = Banner
    
    -- Tab Bar
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, 0, 0, 35)
    TabBar.Position = UDim2.new(0, 0, 0, 70)
    TabBar.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
    TabBar.BorderSizePixel = 0
    TabBar.Parent = Main
    
    local TabList = {"AIM", "VISUALS", "PLAYER", "OTHER"}
    local TabButtons = {}
    for i, name in pairs(TabList) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.25, 0, 1, 0)
        btn.Position = UDim2.new((i-1)*0.25, 0, 0, 0)
        btn.Text = name
        btn.BackgroundTransparency = 1
        btn.TextColor3 = i == 1 and Color3.new(1,1,1) or Color3.fromRGB(160, 160, 160)
        btn.Font = Enum.Font.InterBold
        btn.TextSize = 10
        btn.Parent = TabBar
        TabButtons[name] = btn
    end
    
    -- Items Area
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, 0, 1, -105)
    Content.Position = UDim2.new(0, 0, 0, 105)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 0
    Content.Parent = Main
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 5)
    UIList.Parent = Content
    
    -- Setup Overlay
    local Setup = Instance.new("Frame")
    Setup.Size = UDim2.new(1, 0, 1, 0)
    Setup.BackgroundColor3 = Color3.new(0,0,0)
    Setup.BackgroundTransparency = 0.4
    Setup.Visible = true
    Setup.Parent = Screen
    
    local SetupBox = Instance.new("Frame")
    SetupBox.Size = UDim2.new(0, 300, 0, 150)
    SetupBox.Position = UDim2.new(0.5, -150, 0.5, -75)
    SetupBox.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    SetupBox.Parent = Setup
    
    local SetupText = Instance.new("TextLabel")
    SetupText.Size = UDim2.new(1, 0, 1, 0)
    SetupText.Text = "PRESS ANY KEY TO BIND MENU"
    SetupText.TextColor3 = Color3.new(1,1,1)
    SetupText.Font = Enum.Font.InterBold
    SetupText.BackgroundTransparency = 1
    SetupText.Parent = SetupBox

    -- Bind Logic
    local function BindKey()
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Settings.menu_key = input.KeyCode
                Settings.configured = true
                Setup.Visible = false
                Main.Visible = true
                print("GRAVITY: Keybound to " .. tostring(input.KeyCode))
                connection:Disconnect()
            end
        end)
    end
    
    BindKey()
    
    -- Toggle Logic
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Settings.menu_key and Settings.configured then
            Main.Visible = not Main.Visible
        end
    end)
    
    -- Tabs Functionality
    local function PopulateTab(tabName)
        for _, child in pairs(Content:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
        
        if tabName == "AIM" then
            self:CreateToggle("Enable Aimbot", Settings.aim_enable, function(v) Settings.aim_enable = v end, Content)
            self:CreateSlider("Smoothing", 1, 20, Settings.aim_smooth, function(v) Settings.aim_smooth = v end, Content)
            self:CreateSlider("FOV", 10, 800, Settings.aim_fov, function(v) Settings.aim_fov = v end, Content)
        elseif tabName == "VISUALS" then
            self:CreateToggle("Enable ESP", Settings.esp_enable, function(v) Settings.esp_enable = v end, Content)
            self:CreateToggle("Show Boxes", Settings.esp_boxes, function(v) Settings.esp_boxes = v end, Content)
            self:CreateToggle("Show Names", Settings.esp_names, function(v) Settings.esp_names = v end, Content)
        elseif tabName == "PLAYER" then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    self:CreatePlayerRow(p, Content)
                end
            end
        end
    end
    
    for name, btn in pairs(TabButtons) do
        btn.MouseButton1Click:Connect(function()
            for n, b in pairs(TabButtons) do b.TextColor3 = Color3.fromRGB(160, 160, 160) end
            btn.TextColor3 = Color3.new(1,1,1)
            PopulateTab(name)
        end)
    end
end

function GravityUI:CreateToggle(name, val, callback, parent)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 40)
    f.BackgroundTransparency = 1
    f.Parent = parent
    
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -50, 1, 0)
    t.Text = name
    t.TextColor3 = Color3.new(1,1,1)
    t.Font = Enum.Font.Inter
    t.TextSize = 12
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Position = UDim2.new(0, 10, 0, 0)
    t.BackgroundTransparency = 1
    t.Parent = f
    
    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 30, 0, 15)
    box.Position = UDim2.new(1, -40, 0.5, -7)
    box.BackgroundColor3 = val and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(20, 20, 20)
    box.Text = ""
    box.BorderSizePixel = 0
    box.Parent = f
    
    box.MouseButton1Click:Connect(function()
        val = not val
        box.BackgroundColor3 = val and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(20, 20, 20)
        callback(val)
    end)
end

function GravityUI:CreateSlider(name, min, max, val, callback, parent)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -10, 0, 40)
    f.BackgroundTransparency = 1
    f.Parent = parent
    
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -10, 0, 20)
    t.Text = name .. ": " .. tostring(val)
    t.TextColor3 = Color3.new(1,1,1)
    t.Font = Enum.Font.Inter
    t.TextSize = 12
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Position = UDim2.new(0, 10, 0, 0)
    t.BackgroundTransparency = 1
    t.Parent = f
    
    local slide = Instance.new("Frame")
    slide.Size = UDim2.new(1, -20, 0, 4)
    slide.Position = UDim2.new(0, 10, 0, 25)
    slide.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    slide.BorderSizePixel = 0
    slide.Parent = f
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.new(1,1,1)
    fill.BorderSizePixel = 0
    fill.Parent = slide
end

function GravityUI:CreatePlayerRow(p, parent)
    local f = Instance.new("TextButton")
    f.Size = UDim2.new(1, -10, 0, 40)
    f.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
    f.Text = p.Name
    f.TextColor3 = Color3.new(1,1,1)
    f.BorderSizePixel = 0
    f.Parent = parent
end

-- [[ ESP LOGIC ]]
local Cache = {}
local function CreatePlayerESP(player)
    Cache[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Line")
    }
    Cache[player].Box.Thickness = 1
    Cache[player].Name.Size = 13
    Cache[player].Name.Center = true
    Cache[player].Name.Outline = true
end

local function HandleESP()
    for player, esp in pairs(Cache) do
        local char = player.Character
        if Settings.esp_enable and char and char:FindFirstChild("HumanoidRootPart") and player.Team ~= LocalPlayer.Team then
            local hrp = char.HumanoidRootPart
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChild("Humanoid")
            if not hum or not head then continue end

            local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 1.5
                
                esp.Box.Visible = Settings.esp_boxes
                esp.Box.Size = Vector2.new(width, height)
                esp.Box.Position = Vector2.new(hrpPos.X - width/2, hrpPos.Y - height/2)
                esp.Box.Color = Settings.theme_color
                
                esp.Name.Visible = Settings.esp_names
                esp.Name.Position = Vector2.new(hrpPos.X, hrpPos.Y - height/2 - 15)
                esp.Name.Text = player.Name
                
                esp.Health.Visible = Settings.esp_health
                local h_pct = hum.Health / hum.MaxHealth
                esp.Health.From = Vector2.new(hrpPos.X - width/2 - 5, hrpPos.Y + height/2)
                esp.Health.To = Vector2.new(hrpPos.X - width/2 - 5, hrpPos.Y + height/2 - (height * h_pct))
                esp.Health.Color = Color3.new(1-h_pct, h_pct, 0)
            else
                for _,o in pairs(esp) do o.Visible = false end
            end
        else
            for _,o in pairs(esp) do o.Visible = false end
        end
    end
end

-- [[ CORE LOOP ]]
RunService.RenderStepped:Connect(function()
    HandleESP()
end)

Players.PlayerAdded:Connect(CreatePlayerESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreatePlayerESP(p) end end

GravityUI:Init()
print("GRAVITY V9 - NATIVE ENGINE LOADED.")
