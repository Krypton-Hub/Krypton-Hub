-- Load DrRay UI Library with error handling
local success, DrRayLibrary= pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/DrRay-UI-Library/main/DrRay.lua"))()
end)
if not success then
    warn("Failed to load DrRay UI Library: " .. tostring(DrRayLibrary))
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Error",
        Text = "Failed to load DrRay UI Library. Check your network or script URL.",
        Duration = 5
    })
    return
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Create GUI window
local window = DrRayLibrary:Load("Trident Survival Hacks", "Default")

-- Create tabs (no icons since valid IDs weren’t provided)
local combatTab = DrRayLibrary.newTab("⚔️ Combat ⚔️", "")
local visualsTab = DrRayLibrary.newTab("👀 Visuals 👀", "")

-- Configuration
local CONFIG = {
    SilentAimMaxDistance = 100, -- Max distance for Silent Aim (studs)
    ESPMaxDistance = 1000 -- Max distance for ESP (studs)
}

-- Silent Aim Toggle
local silentAimEnabled = false
combatTab.newToggle("Silent Aim", "Redirects aim to nearest player's head", false, function(toggleState)
    silentAimEnabled = toggleState
    DrRayLibrary.notify(toggleState and "Silent Aim Enabled" or "Silent Aim Disabled")
end)

-- Silent Aim Distance Slider
combatTab.newSlider("Silent Aim Distance", "Max distance for Silent Aim (studs)", 100, 50, 500, false, function(value)
    CONFIG.SilentAimMaxDistance = value
    DrRayLibrary.notify("Silent Aim Distance set to " .. value .. " studs")
end)

-- ESP Toggle
local espEnabled = false
visualsTab.newToggle("Player ESP", "Highlights all players with boxes", false, function(toggleState)
    espEnabled = toggleState
    DrRayLibrary.notify(toggleState and "ESP Enabled" or "ESP Disabled")
    updateESP() -- Update ESP immediately on toggle
end)

-- ESP Distance Slider
visualsTab.newSlider("ESP Distance", "Max distance for ESP (studs)", 1000, 100, 2000, false, function(value)
    CONFIG.ESPMaxDistance = value
    DrRayLibrary.notify("ESP Distance set to " .. value .. " studs")
    updateESP() -- Update ESP to apply new distance
end)

-- ESP Setup
local espBillboards = {}
local connections = {}

-- Create ESP for a player
local function createESP(player)
    if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    local success, result = pcall(function()
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP"
        billboard.Adornee = player.Character.HumanoidRootPart
        billboard.Size = UDim2.new(0, 50, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = CONFIG.ESPMaxDistance

        local frame = Instance.new("Frame", billboard)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 0.5
        frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
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
    end)
    if not success then
        warn("Failed to create ESP for " .. player.Name .. ": " .. tostring(result))
    end
end

-- Remove ESP for a player
local function removeESP(player)
    if espBillboards[player] then
        pcall(function()
            espBillboards[player]:Destroy()
            espBillboards[player] = nil
        end)
    end
end

-- Update ESP
local function updateESP()
    if espEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not espBillboards[player] then
                    createESP(player)
                else
                    espBillboards[player].MaxDistance = CONFIG.ESPMaxDistance
                end
            else
                removeESP(player)
            end
        end
    else
        for player, _ in pairs(espBillboards) do
            removeESP(player)
        end
    end
end

-- Handle player join/leave
connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
    if espEnabled then
        connections["CharacterAdded_" .. player.Name] = player.CharacterAdded:Connect(function()
            createESP(player)
        end)
        if player.Character then
            createESP(player)
        end
    end
end)

connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
    if connections["CharacterAdded_" .. player.Name] then
        connections["CharacterAdded_" .. player.Name]:Disconnect()
        connections["CharacterAdded_" .. player.Name] = nil
    end
end)

-- Run ESP updates
connections.RenderStepped = RunService.RenderStepped:Connect(function()
    updateESP()
end)

-- Silent Aim: Find closest player
local function getClosestPlayer()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    local closestPlayer = nil
    local closestDistance = CONFIG.SilentAimMaxDistance
    local localPos = LocalPlayer.Character.HumanoidRootPart.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local targetPos = player.Character.Head.Position
            local distance = (localPos - targetPos).Magnitude
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
local success, result = pcall(function()
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        if silentAimEnabled and self == LocalPlayer:GetMouse() and getnamecallmethod() == "Hit" then
            local targetPlayer = getClosestPlayer()
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
                args[1] = targetPlayer.Character.Head.Position
            end
        end
        return oldNamecall(self, unpack(args))
    end)
end)
if not success then
    DrRayLibrary.notify("Silent Aim hook failed: " .. tostring(result))
end

-- Cleanup function
local function cleanup()
    for player, _ in pairs(espBillboards) do
        removeESP(player)
    end
    for _, connection in pairs(connections) do
        connection:Disconnect()
    end
    connections = {}
end

-- Connect cleanup on script termination
game:BindToClose(cleanup)

-- Notify user that the script is loaded
DrRayLibrary.notify("Silent Aim + ESP GUI Loaded for Trident Survival")
