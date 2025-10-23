local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local savedPosition = nil
local godModeEnabled = false
local godModeConnections = {}

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GGHubSpeed"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 190) -- Increased height for God Mode toggle
frame.Position = UDim2.fromScale(0.5, 0.2) - UDim2.fromOffset(110, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Rounded Corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.15, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🧠 GG HUB - Steal Mode"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- Notification Label
local notificationLabel = Instance.new("TextLabel")
notificationLabel.Size = UDim2.new(1, -20, 0, 30)
notificationLabel.Position = UDim2.new(0, 10, 0.85, 0)
notificationLabel.BackgroundTransparency = 1
notificationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
notificationLabel.Font = Enum.Font.Gotham
notificationLabel.TextSize = 14
notificationLabel.Text = ""
notificationLabel.Parent = frame

-- Notification Function
local function notify(message, color)
    notificationLabel.Text = message
    notificationLabel.TextColor3 = color
    spawn(function()
        wait(2)
        notificationLabel.Text = ""
    end)
end

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.Gotham
closeButton.TextSize = 14
closeButton.Parent = frame
local closeCorner = Instance.new("UICorner", closeButton)
closeCorner.CornerRadius = UDim.new(0, 5)
closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

-- Helper function for toggle knob button
local function createToggle(name, posY, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 30)
    container.Position = UDim2.new(0, 10, 0, posY)
    container.BackgroundTransparency = 1
    container.Name = name
    container.Parent = frame

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(0.7, 0, 1, 0)
    text.Position = UDim2.new(0, 0, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = name
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Font = Enum.Font.Gotham
    text.TextSize = 14
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = container

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.25, 0, 0.6, 0)
    toggleBtn.Position = UDim2.new(0.75, 0, 0.2, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = container

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0.4, 0, 1, 0)
    knob.Position = UDim2.new(0, 0, 0, 0)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Parent = toggleBtn

    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(1, 0)

    local btnCorner = Instance.new("UICorner", toggleBtn)
    btnCorner.CornerRadius = UDim.new(1, 0)

    local on = false
    toggleBtn.MouseButton1Click:Connect(function()
        on = not on
        local tween = TweenService:Create(knob, TweenInfo.new(0.2), { Position = on and UDim2.new(0.6, 0, 0, 0) or UDim2.new(0, 0, 0, 0) })
        tween:Play()
        callback(on)
    end)
end

-- Helper function for single-action button
local function createButton(name, posY, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 30)
    container.Position = UDim2.new(0, 10, 0, posY)
    container.BackgroundTransparency = 1
    container.Name = name
    container.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    button.Text = name
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = container

    local btnCorner = Instance.new("UICorner", button)
    btnCorner.CornerRadius = UDim.new(0, 5)

    button.MouseButton1Click:Connect(callback)
end

-- God Mode toggle
createToggle("God Mode", 35, function(enabled)
    godModeEnabled = enabled
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then
        notify("Error: Humanoid not found!", Color3.fromRGB(255, 0, 0))
        return
    end

    if enabled then
        hum.MaxHealth = 1000000
        hum.Health = 1000000
        local healthConnection = hum.HealthChanged:Connect(function(health)
            if health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end)
        local stateConnection = hum.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.Dead then
                hum.Health = hum.MaxHealth
            end
        end)
        table.insert(godModeConnections, healthConnection)
        table.insert(godModeConnections, stateConnection)
        hum.AncestryChanged:Connect(function()
            if not hum.Parent then
                for _, conn in ipairs(godModeConnections) do
                    conn:Disconnect()
                end
                godModeConnections = {}
            end
        end)
        notify("God Mode enabled!", Color3.fromRGB(0, 255, 0))
    else
        hum.MaxHealth = 100
        hum.Health = 100
        for _, conn in ipairs(godModeConnections) do
            conn:Disconnect()
        end
        godModeConnections = {}
        notify("God Mode disabled!", Color3.fromRGB(255, 0, 0))
    end
end)

-- Reapply God Mode on respawn
player.CharacterAdded:Connect(function(newChar)
    local hum = newChar:WaitForChild("Humanoid", 5)
    if hum and godModeEnabled then
        hum.MaxHealth = 1000000
        hum.Health = 1000000
        local healthConnection = hum.HealthChanged:Connect(function(health)
            if health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end)
        local stateConnection = hum.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.Dead then
                hum.Health = hum.MaxHealth
            end
        end)
        table.insert(godModeConnections, healthConnection)
        table.insert(godModeConnections, stateConnection)
    end
end)

-- Speed Boost toggle
createToggle("Speed Boost", 70, function(enabled)
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = enabled and 38 or 16
        notify("Speed Boost " .. (enabled and "enabled!" or "disabled!"), Color3.fromRGB(0, 255, 0))
    else
        notify("Error: Humanoid not found!", Color3.fromRGB(255, 0, 0))
    end
end)

-- Save Position button
createButton("Save Position", 105, function()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        savedPosition = hrp.Position
        notify("Position saved: " .. tostring(savedPosition), Color3.fromRGB(0, 255, 0))
    else
        notify("Error: HumanoidRootPart not found!", Color3.fromRGB(255, 0, 0))
    end
end)

-- Steal button
createToggle("Steal", 140, function()
    if not savedPosition then
        notify("No saved position set!", Color3.fromRGB(255, 0, 0))
        return
    end
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then
        notify("Error: Character parts not found!", Color3.fromRGB(255, 0, 0))
        return
    end

    -- Disable collisions to prevent getting stuck
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    -- Float up 15 studs and anchor
    hrp.Anchored = true
    local floatPos = hrp.Position + Vector3.new(0, 15, 0)
    hrp.CFrame = CFrame.new(floatPos)
    wait(0.6)

    -- Move to saved position
    local flySpeed = 25
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local dir = (savedPosition - hrp.Position)
        if dir.Magnitude < 2 then
            connection:Disconnect()
            wait(0.2)
            -- Restore collisions and unanchor
            hrp.Anchored = false
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
            -- Ensure player doesn't fall through map
            if hum and godModeEnabled then
                hum.Health = hum.MaxHealth
            end
            notify("Steal complete!", Color3.fromRGB(0, 255, 0))
        else
            hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(savedPosition), 0.02)
        end
    end)
end)
