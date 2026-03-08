--[[
    GRAVITY.LUA - Professional Roblox Cheat Core (V8)
    Final Integrated Version for GitHub Repository
    Includes: UI Loader, ESP Suite, Aimbot, Player Troll System
]]

local UserInputService = game:GetService("UserInputService")
local LogService = game:GetService("LogService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ MASTER SETTINGS ]]
local Settings = {
    aim_enable = false, aim_smooth = 5, aim_fov = 200, aim_part = "Head",
    esp_enable = true, esp_boxes = true, esp_corner = false, esp_outline = true,
    esp_fill = false, esp_names = true, esp_health = true, esp_armor = false,
    esp_snap = false, esp_skel = false, esp_weapon = false
}

-- [[ UI CONSTRUCTOR ]]
local function BuildUI()
    local url = "https://raw.githubusercontent.com/wexicek1/GRAVITY/main/gravity_v8.html"
    -- Attempt to fetch the HTML content
    local success, html = pcall(function() return game:HttpGet(url) end)
    if not success then
        -- Fallback to local file for testing if requested
        html = [[ <!-- HTML CONTENT WILL BE INJECTED HERE VIA LOADSTRING --> ]]
    end
    
    -- In a real scenario, the executor's WebView/Drawing API would render this.
    -- For now, we assume the user is using an executor that supports HTMLLoading or 
    -- we just log the initialization.
    print("GRAVITY UI: Initializing Interface...")
end

-- [[ TROLL FUNCTIONS ]]
local function TrollPlayer(targetName, action)
    local target = Players:FindFirstChild(targetName)
    if not target or not target.Character then return end
    
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
    
    if action == "Teleport" and hrp and targetHrp then
        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 3, 0)
    elseif action == "Spectate" then
        Camera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
    elseif action == "Unspectate" then
        Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    elseif action == "Fling" and hrp and targetHrp then
        local oldV = hrp.Velocity
        hrp.Velocity = Vector3.new(0, 1000, 0)
        task.wait(0.1)
        hrp.CFrame = targetHrp.CFrame
        hrp.Velocity = Vector3.new(10000, 10000, 10000)
        task.wait(0.1)
        hrp.Velocity = oldV
    end
end

-- [[ SYNC FROM UI ]]
LogService.MessageOut:Connect(function(msg, type)
    if msg:find("GRAVITY_SYNC:") then
        local dataStr = msg:split("GRAVITY_SYNC:")[2]
        local success, data = pcall(function() return HttpService:JSONDecode(dataStr) end)
        if success then
            for k, v in pairs(data) do Settings[k] = v end
        end
    elseif msg:find("GRAVITY_TROLL:") then
        local parts = msg:split(":")
        TrollPlayer(parts[2], parts[3])
    end
end)

-- [[ PLAYER LIST SYNC ]]
task.spawn(function()
    while task.wait(5) do
        local names = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(names, p.Name) end
        end
        print("GRAVITY_PLAYERS:" .. HttpService:JSONEncode(names))
    end
end)

-- [[ DRAWING LIBS ]]
local function NewDrawing(type, props)
    local obj = Drawing.new(type)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local FOVCircle = NewDrawing("Circle", { Thickness = 1.5, NumSides = 100, Radius = Settings.aim_fov, Visible = false, Color = Color3.new(1,1,1) })
local Cache = {}

local function CreatePlayerESP(player)
    Cache[player] = {
        Box = NewDrawing("Square", { Thickness = 1, Filled = false }),
        Outline = NewDrawing("Square", { Thickness = 2, Transparency = 0.5, Color = Color3.new(0,0,0) }),
        Tracer = NewDrawing("Line", { Thickness = 1 }),
        Name = NewDrawing("Text", { Size = 13, Center = true, Outline = true, Color = Color3.new(1,1,1) }),
        HealthBar = NewDrawing("Line", { Thickness = 2, Color = Color3.new(0,1,0) }),
        Corners = {}
    }
    for i=1,8 do table.insert(Cache[player].Corners, NewDrawing("Line", {Thickness = 1.5})) end
end

local function RemovePlayerESP(player)
    if Cache[player] then
        for _, obj in pairs(Cache[player]) do
            if type(obj) == "table" then for _, l in pairs(obj) do l:Remove() end else obj:Remove() end
        end
        Cache[player] = nil
    end
end

-- [[ CORE ESP HANDLER ]]
local function HandleESP()
    for player, esp in pairs(Cache) do
        local char = player.Character
        if Settings.esp_enable and char and char:FindFirstChild("HumanoidRootPart") and player.Team ~= LocalPlayer.Team then
            local hrp = char.HumanoidRootPart
            local hum = char:FindFirstChild("Humanoid")
            if not hum then continue end

            local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local head = char:FindFirstChild("Head")
                if not head then continue end
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 1.5
                local x, y = hrpPos.X - width/2, hrpPos.Y - height/2
                local color = Color3.fromRGB(45, 100, 255)

                -- Boxes
                esp.Box.Visible = Settings.esp_boxes and not Settings.esp_corner
                if esp.Box.Visible then
                    esp.Box.Size, esp.Box.Position, esp.Box.Color = Vector2.new(width, height), Vector2.new(x, y), color
                    esp.Outline.Visible = Settings.esp_outline
                    esp.Outline.Size, esp.Outline.Position = esp.Box.Size, esp.Box.Position
                else esp.Outline.Visible = false end

                -- Corners
                if Settings.esp_corner then
                    local l = width/4
                    for i=1,8 do esp.Corners[i].Visible, esp.Corners[i].Color = true, color end
                    esp.Corners[1].From, esp.Corners[1].To = Vector2.new(x, y), Vector2.new(x+l, y)
                    esp.Corners[2].From, esp.Corners[2].To = Vector2.new(x, y), Vector2.new(x, y+l)
                    esp.Corners[3].From, esp.Corners[3].To = Vector2.new(x+width, y), Vector2.new(x+width-l, y)
                    esp.Corners[4].From, esp.Corners[4].To = Vector2.new(x+width, y), Vector2.new(x+width, y+l)
                    esp.Corners[5].From, esp.Corners[5].To = Vector2.new(x, y+height), Vector2.new(x+l, y+height)
                    esp.Corners[6].From, esp.Corners[6].To = Vector2.new(x, y+height), Vector2.new(x, y+height-l)
                    esp.Corners[7].From, esp.Corners[7].To = Vector2.new(x+width, y+height), Vector2.new(x+width-l, y+height)
                    esp.Corners[8].From, esp.Corners[8].To = Vector2.new(x+width, y+height), Vector2.new(x+width, y+height-l)
                else for i=1,8 do esp.Corners[i].Visible = false end end

                -- Health Bar
                if Settings.esp_health then
                    local pct = hum.Health / hum.MaxHealth
                    esp.HealthBar.Visible = true
                    esp.HealthBar.From, esp.HealthBar.To = Vector2.new(x-5, y+height), Vector2.new(x-5, y+height-(height*pct))
                    esp.HealthBar.Color = Color3.new(1-pct, pct, 0)
                else esp.HealthBar.Visible = false end

                -- Names
                if Settings.esp_names then
                    esp.Name.Visible, esp.Name.Position, esp.Name.Text = true, Vector2.new(hrpPos.X, y-15), player.Name
                else esp.Name.Visible = false end
            else
                for _, obj in pairs(esp) do if type(obj) == "table" then for _, l in pairs(obj) do l.Visible = false end else obj.Visible = false end end
            end
        else
            for _, obj in pairs(esp) do if type(obj) == "table" then for _, l in pairs(obj) do l.Visible = false end else obj.Visible = false end end
        end
    end
end

-- [[ AIMBOT HANDLER ]]
local function GetClosest()
    local target, dist = nil, Settings.aim_fov
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Settings.aim_part) and p.Team ~= LocalPlayer.Team then
            local pos, s = Camera:WorldToViewportPoint(p.Character[Settings.aim_part].Position)
            if s then
                local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if mag < dist then dist = mag target = p end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position, FOVCircle.Radius, FOVCircle.Visible = UserInputService:GetMouseLocation(), Settings.aim_fov, Settings.aim_enable
    HandleESP()
    if Settings.aim_enable then
        local t = GetClosest()
        if t then
            local pos = Camera:WorldToViewportPoint(t.Character[Settings.aim_part].Position)
            local mouse = UserInputService:GetMouseLocation()
            mousemoverel((pos.X - mouse.X)/Settings.aim_smooth, (pos.Y - mouse.Y)/Settings.aim_smooth)
        end
    end
end)

Players.PlayerAdded:Connect(CreatePlayerESP)
Players.PlayerRemoving:Connect(RemovePlayerESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreatePlayerESP(p) end end

BuildUI()
print("GRAVITY V8 - REPOSITORY VERSION LOADED SUCCESSFULLY.")
