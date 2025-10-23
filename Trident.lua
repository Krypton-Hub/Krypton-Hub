-- Load DrRay UI Library
local success, DrRayLibrary = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/DrRay-UI-Library/main/DrRay.lua"))()
end)
if not success then
    warn("Failed to load DrRay UI Library: " .. DrRayLibrary)
    return
end

-- Create GUI window
local window = DrRayLibrary:Load("Trident Survival Hacks", "Default")

-- Create Combat tab
local combatTab = DrRayLibrary.newTab("⚔️ Combat ⚔️", "rbxassetid://1234567890") -- Replace with valid Roblox image ID

-- Create Visuals tab
local visualsTab = DrRayLibrary.newTab("👀 Visuals 👀", "rbxassetid://1234567890") -- Replace with valid Roblox image ID

-- Silent Aim Toggle
local silentAimEnabled = false
combatTab.newToggle("Silent Aim", "Redirects aim to nearest player's head", false, function(toggleState)
    silentAimEnabled = toggleState
    DrRayLibrary.notify(toggleState and "Silent Aim Enabled" or "Silent Aim Disabled")
end)

-- ESP Toggle
local espEnabled = false
visualsTab.newToggle("Player ESP", "Highlights all players with boxes", false, function(toggleState)
    espEnabled = toggleState
    DrRayLibrary.notify(toggleState and "ESP Enabled" or "ESP Disabled")
end)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ESP Setup
local espBillboards = {}

local function createESP(player)
    if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Adornee = player.Character.HumanoidRootPart
    billboard.Size = UDim2.new(0, 50, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1000

    local frame = Instance.new("Frame", billboard)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.5
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red box
    frame.BorderSizePixel = 2

    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, -0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true

    billboard.Parent = game.CoreGui
    espBillboards[player] = billboard
end

local function removeESP(player)
    if espBillboards[player] then
        espBillboards[player]:Destroy()
        espBillboards[player] = nil
    end
end

-- Update ESP
local function updateESP()
    if espEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not espBillboards[player] then
                    createESP(player)
                end
            else
                removeESP(player)
            end
        end
    else
        for player, billboard in pairs(espBillboards) do
            removeESP(player)
        end
    end
end

-- Handle player join/leave
Players.PlayerAdded:Connect(function(player)
    if espEnabled then
        player.CharacterAdded:Connect(function()
            createESP(player)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- Run ESP updates
RunService.RenderStepped:Connect(function()
    updateESP()
end)

-- Silent Aim: Find closest player
local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = 100 -- Max distance of 100 studs
    local localPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not localPos then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local targetPos = player.Character.Head.Position
            local distance = (localPos.Position - targetPos).Magnitude
            local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPos)
            if distance < closestDistance and onScreen then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

-- Silent Aim: Hook mouse hit
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if silentAimEnabled and self == LocalPlayer:GetMouse() and getnamecallmethod() == "Hit" then
        local targetPlayer = getClosestPlayer()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            args[1] = targetPlayer.Character.Head.Position -- Redirect mouse hit to head
        end
    end
    return oldNamecall(self, unpack(args))
end)

-- Notify user that the script is loaded
DrRayLibrary.notify("Silent Aim + ESP Test GUI Loaded for Trident Survival")
