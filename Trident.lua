-- Load DrRay UI Library
local success, DrRayLibrary = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/DrRay-UI-Library/main/DrRay.lua"))()
end)
if not success then
    warn("Failed to load DrRay UI Library: " .. DrRayLibrary)
    return
end

-- Create GUI window
local window = DrRayLibrary:Load("Aimbot Test GUI", "Default")

-- Create Combat tab
local combatTab = DrRayLibrary.newTab("⚔️ Combat ⚔️", "rbxassetid://1234567890") -- Replace with valid Roblox image ID

-- Aimbot Toggle
local aimbotEnabled = false
combatTab.newToggle("Aimbot", "Locks camera to nearest player's head", false, function(toggleState)
    aimbotEnabled = toggleState
    DrRayLibrary.notify(toggleState and "Aimbot Enabled" or "Aimbot Disabled")
end)

-- Aimbot Sensitivity Slider
local aimSensitivity = 0.5 -- Default sensitivity (0 to 1)
combatTab.newSlider("Aimbot Sensitivity", "Adjust aim snap speed", 0, 1, function(value)
    aimSensitivity = value
end)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Function to find the closest player
local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    local localPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not localPos then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local targetPos = player.Character.Head.Position
            local distance = (localPos.Position - targetPos).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

-- Aimbot Logic (runs every frame)
local aiming = false
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then -- Right-click to aim
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

RunService.RenderStepped:Connect(function(deltaTime)
    if aimbotEnabled and aiming and LocalPlayer.Character then
        local targetPlayer = getClosestPlayer()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            local head = targetPlayer.Character.Head
            local targetCFrame = CFrame.new(Camera.CFrame.Position, head.Position)
            -- Smoothly interpolate camera CFrame
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, aimSensitivity * deltaTime * 10)
        end
    end
end)

-- Notify user that the script is loaded
DrRayLibrary.notify("Aimbot Test GUI Loaded")
