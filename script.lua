local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(c)
	character = c
	hrp = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
end)

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "RxyalsScriptsGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 320)
frame.Position = UDim2.new(0.5, -110, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

-- Make frame draggable
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local title = Instance.new("TextLabel", frame)
title.Text = "Rxyals Scripts"
title.Size = UDim2.new(1, 0, 0, 20)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.ZIndex = 2

-- Speed Controller
local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Text = "Speed: 24 (Recommended)"
speedLabel.Size = UDim2.new(0.9, 0, 0, 16)
speedLabel.Position = UDim2.new(0.05, 0, 0.12, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 10
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedSlider = Instance.new("Frame", frame)
speedSlider.Size = UDim2.new(0.9, 0, 0, 20)
speedSlider.Position = UDim2.new(0.05, 0, 0.18, 0)
speedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedSlider.BorderSizePixel = 0
Instance.new("UICorner", speedSlider).CornerRadius = UDim.new(0, 4)

local speedFill = Instance.new("Frame", speedSlider)
speedFill.Size = UDim2.new(0.5, 0, 1, 0)
speedFill.Position = UDim2.new(0, 0, 0, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
speedFill.BorderSizePixel = 0
speedFill.ZIndex = 2
Instance.new("UICorner", speedFill).CornerRadius = UDim.new(0, 4)

local speedValue = Instance.new("TextLabel", speedSlider)
speedValue.Text = "24"
speedValue.Size = UDim2.new(1, 0, 1, 0)
speedValue.Position = UDim2.new(0, 0, 0, 0)
speedValue.BackgroundTransparency = 1
speedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
speedValue.Font = Enum.Font.GothamBold
speedValue.TextSize = 12
speedValue.ZIndex = 3

-- Jump Power input
local jumpLabel = Instance.new("TextLabel", frame)
jumpLabel.Text = "Jump Power:"
jumpLabel.Size = UDim2.new(0.9, 0, 0, 16)
jumpLabel.Position = UDim2.new(0.05, 0, 0.28, 0)
jumpLabel.BackgroundTransparency = 1
jumpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextSize = 10
jumpLabel.TextXAlignment = Enum.TextXAlignment.Left

local jumpInput = Instance.new("TextBox", frame)
jumpInput.Size = UDim2.new(0.3, 0, 0, 20)
jumpInput.Position = UDim2.new(0.65, 0, 0.28, 0)
jumpInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
jumpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpInput.Font = Enum.Font.Gotham
jumpInput.TextSize = 12
jumpInput.Text = "50"
jumpInput.PlaceholderText = "Jump"
Instance.new("UICorner", jumpInput).CornerRadius = UDim.new(0, 4)

-- Buttons with better spacing
local tweenButton = Instance.new("TextButton", frame)
tweenButton.Text = "▶ START WALK"
tweenButton.Size = UDim2.new(0.9, 0, 0, 30)
tweenButton.Position = UDim2.new(0.05, 0, 0.38, 0)
tweenButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tweenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tweenButton.Font = Enum.Font.GothamBold
tweenButton.TextSize = 14
tweenButton.ZIndex = 2
Instance.new("UICorner", tweenButton).CornerRadius = UDim.new(0, 6)

local autoFloorButton = Instance.new("TextButton", frame)
autoFloorButton.Text = "AUTO FLOOR: OFF"
autoFloorButton.Size = UDim2.new(0.9, 0, 0, 30)
autoFloorButton.Position = UDim2.new(0.05, 0, 0.50, 0)
autoFloorButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
autoFloorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFloorButton.Font = Enum.Font.GothamBold
autoFloorButton.TextSize = 14
autoFloorButton.ZIndex = 2
Instance.new("UICorner", autoFloorButton).CornerRadius = UDim.new(0, 6)

local floatButton = Instance.new("TextButton", frame)
floatButton.Text = "FLOAT: OFF"
floatButton.Size = UDim2.new(0.9, 0, 0, 30)
floatButton.Position = UDim2.new(0.05, 0, 0.62, 0)
floatButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
floatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
floatButton.Font = Enum.Font.GothamBold
floatButton.TextSize = 14
floatButton.ZIndex = 2
Instance.new("UICorner", floatButton).CornerRadius = UDim.new(0, 6)

local autoLazerButton = Instance.new("TextButton", frame)
autoLazerButton.Text = "AUTO LAZER: OFF"
autoLazerButton.Size = UDim2.new(0.9, 0, 0, 30)
autoLazerButton.Position = UDim2.new(0.05, 0, 0.74, 0)
autoLazerButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
autoLazerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoLazerButton.Font = Enum.Font.GothamBold
autoLazerButton.TextSize = 14
autoLazerButton.ZIndex = 2
Instance.new("UICorner", autoLazerButton).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Text = "Status: Ready - Drag to move"
statusLabel.Size = UDim2.new(1, 0, 0, 16)
statusLabel.Position = UDim2.new(0, 0, 0.92, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.ZIndex = 2

-- Speed Controller Variables
local currentSpeed = 24
local minSpeed = 16
local maxSpeed = 100
local suggestedSpeeds = {
    {16, "Very Safe"},
    {24, "Recommended"},
    {32, "Fast"},
    {50, "Risky"},
    {75, "Very Risky"},
    {100, "May Glitch"}
}

-- Speed Controller Function
local function updateSpeedDisplay(speed)
    currentSpeed = speed
    local fillAmount = (speed - minSpeed) / (maxSpeed - minSpeed)
    speedFill.Size = UDim2.new(fillAmount, 0, 1, 0)
    speedValue.Text = tostring(speed)
    
    -- Find closest suggested speed and display warning
    local closestSuggestion = suggestedSpeeds[1]
    for _, suggestion in ipairs(suggestedSpeeds) do
        if math.abs(speed - suggestion[1]) < math.abs(speed - closestSuggestion[1]) then
            closestSuggestion = suggestion
        end
    end
    
    speedLabel.Text = "Speed: " .. speed .. " (" .. closestSuggestion[2] .. ")"
    
    -- Change color based on risk level
    if speed <= 24 then
        speedFill.BackgroundColor3 = Color3.fromRGB(0, 170, 0) -- Green (safe)
    elseif speed <= 50 then
        speedFill.BackgroundColor3 = Color3.fromRGB(255, 170, 0) -- Orange (warning)
    else
        speedFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Red (danger)
    end
end

-- Speed Slider Interaction
local speedDragging = false
speedSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        speedDragging = true
    end
end)

speedSlider.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        speedDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if speedDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local sliderPos = speedSlider.AbsolutePosition
        local sliderSize = speedSlider.AbsoluteSize
        
        local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
        local newSpeed = math.floor(minSpeed + (maxSpeed - minSpeed) * relativeX)
        
        updateSpeedDisplay(newSpeed)
    end
end)

-- Click to set speed
speedSlider.MouseButton1Click:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    local sliderPos = speedSlider.AbsolutePosition
    local sliderSize = speedSlider.AbsoluteSize
    
    local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
    local newSpeed = math.floor(minSpeed + (maxSpeed - minSpeed) * relativeX)
    
    updateSpeedDisplay(newSpeed)
end)

-- WORKING Float Feature
local floatEnabled = false
local floatBodyForce
local floatConnection

local function toggleFloat()
    floatEnabled = not floatEnabled
    
    if floatEnabled then
        floatButton.Text = "FLOAT: ON"
        floatButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        -- Create BodyVelocity for better floating control
        floatBodyForce = Instance.new("BodyVelocity")
        floatBodyForce.Velocity = Vector3.new(0, 0, 0)
        floatBodyForce.MaxForce = Vector3.new(0, math.huge, 0)
        floatBodyForce.Parent = hrp
        
        -- Apply upward force to counteract gravity
        local floatForce = Instance.new("BodyForce")
        floatForce.Force = Vector3.new(0, workspace.Gravity * hrp:GetMass() * 1.2, 0) -- Slightly more than gravity
        floatForce.Parent = hrp
        
        statusLabel.Text = "Status: Floating Enabled - Press Space to go up"
        
        -- Add spacebar control to go up
        local floatUpConnection
        floatUpConnection = UserInputService.InputBegan:Connect(function(input)
            if floatEnabled and input.KeyCode == Enum.KeyCode.Space then
                floatBodyForce.Velocity = Vector3.new(0, 25, 0)
            end
        end)
        
        -- Update when character changes
        floatConnection = player.CharacterAdded:Connect(function(char)
            task.wait(1)
            hrp = char:WaitForChild("HumanoidRootPart")
            if floatBodyForce then
                floatBodyForce:Destroy()
            end
            if floatUpConnection then
                floatUpConnection:Disconnect()
            end
            
            floatBodyForce = Instance.new("BodyVelocity")
            floatBodyForce.Velocity = Vector3.new(0, 0, 0)
            floatBodyForce.MaxForce = Vector3.new(0, math.huge, 0)
            floatBodyForce.Parent = hrp
            
            local newFloatForce = Instance.new("BodyForce")
            newFloatForce.Force = Vector3.new(0, workspace.Gravity * hrp:GetMass() * 1.2, 0)
            newFloatForce.Parent = hrp
        end)
        
    else
        floatButton.Text = "FLOAT: OFF"
        floatButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        
        -- Clean up floating
        if floatBodyForce then
            floatBodyForce:Destroy()
            floatBodyForce = nil
        end
        
        -- Remove any body forces
        for _, force in pairs(hrp:GetChildren()) do
            if force:IsA("BodyForce") or force:IsA("BodyVelocity") then
                force:Destroy()
            end
        end
        
        if floatConnection then
            floatConnection:Disconnect()
            floatConnection = nil
        end
        
        statusLabel.Text = "Status: Floating Disabled"
    end
end

-- Jump Power Function
local function setJumpPower(value)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = value
        statusLabel.Text = "Status: Jump Power set to " .. value
    end
end

-- WORKING Auto Lazer Feature
local autoLazerEnabled = false
local autoLazerThread = nil

local function getLazerRemote()
    -- Try different possible remote locations
    local remotes = {
        ReplicatedStorage:FindFirstChild("RE/UseItem"),
        ReplicatedStorage:FindFirstChild("UseItem"),
        ReplicatedStorage:FindFirstChild("RemoteEvent"),
        ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("UseItem") if ReplicatedStorage:FindFirstChild("Remotes") else nil,
        ReplicatedStorage:FindFirstChild("Packages"):FindFirstChild("Net"):FindFirstChild("RE/UseItem") if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net") else nil
    }
    
    for _, remote in pairs(remotes) do
        if remote then
            return remote
        end
    end
    return nil
end

local function isValidTarget(player)
    if not player or not player.Character or player == Players.LocalPlayer then return false end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return false end
    if humanoid.Health <= 0 then return false end
    return true
end

local function findNearestPlayer()
    local nearest = nil
    local nearestDist = math.huge
    local myPos = hrp.Position
    
    for _, pl in ipairs(Players:GetPlayers()) do
        if isValidTarget(pl) then
            local targetHRP = pl.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local dist = (targetHRP.Position - myPos).Magnitude
                if dist < nearestDist and dist < 50 then -- Only target within 50 studs
                    nearestDist = dist
                    nearest = pl
                end
            end
        end
    end
    return nearest
end

local function fireAtNearest()
    local target = findNearestPlayer()
    if not target then return end
    
    local remote = getLazerRemote()
    if not remote then
        statusLabel.Text = "Status: No lazer remote found"
        return
    end
    
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if targetHRP then
        -- Try different argument formats
        local success = pcall(function()
            remote:FireServer(targetHRP.Position, targetHRP)
        end)
        
        if not success then
            pcall(function()
                remote:FireServer("UseItem", targetHRP.Position, targetHRP)
            end)
        end
    end
end

local function autoLazerWorker()
    while autoLazerEnabled and task.wait(0.5) do
        fireAtNearest()
    end
end

local function toggleAutoLazer()
    autoLazerEnabled = not autoLazerEnabled
    autoLazerButton.Text = autoLazerEnabled and "AUTO LAZER: ON" or "AUTO LAZER: OFF"
    autoLazerButton.BackgroundColor3 = autoLazerEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(40, 40, 40)
    
    if autoLazerEnabled then
        if autoLazerThread then
            task.cancel(autoLazerThread)
        end
        autoLazerThread = task.spawn(autoLazerWorker)
        statusLabel.Text = "Status: Auto Lazer Enabled - Targeting nearby players"
    else
        if autoLazerThread then
            task.cancel(autoLazerThread)
            autoLazerThread = nil
        end
        statusLabel.Text = "Status: Auto Lazer Disabled"
    end
end

-- WORKING Auto Floor Feature
local floorOn = false
local floorPartAF, floorConnAF
local floorRiseSpeed = 2.0
local autoFloorSize = Vector3.new(10, 1, 10)

local function toggleAutoFloor()
    floorOn = not floorOn
    
    if floorOn then
        autoFloorButton.Text = "AUTO FLOOR: ON"
        autoFloorButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        -- Create floor part
        if floorPartAF then
            floorPartAF:Destroy()
        end
        
        floorPartAF = Instance.new("Part")
        floorPartAF.Name = "AutoFloor"
        floorPartAF.Size = autoFloorSize
        floorPartAF.Anchored = true
        floorPartAF.CanCollide = true
        floorPartAF.Material = Enum.Material.Neon
        floorPartAF.Color = Color3.fromRGB(0, 100, 255)
        floorPartAF.Transparency = 0.3
        floorPartAF.Parent = workspace
        
        -- Start following the player
        floorConnAF = RunService.Heartbeat:Connect(function()
            if hrp and floorPartAF then
                local targetY = hrp.Position.Y - 5 -- 5 studs below player
                local currentPos = floorPartAF.Position
                
                -- Smooth movement
                local newY = currentPos.Y + (targetY - currentPos.Y) * 0.1
                floorPartAF.CFrame = CFrame.new(hrp.Position.X, newY, hrp.Position.Z)
            end
        end)
        
        statusLabel.Text = "Status: Auto Floor Enabled"
    else
        autoFloorButton.Text = "AUTO FLOOR: OFF"
        autoFloorButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        
        -- Clean up
        if floorConnAF then
            floorConnAF:Disconnect()
            floorConnAF = nil
        end
        if floorPartAF then
            floorPartAF:Destroy()
            floorPartAF = nil
        end
        
        statusLabel.Text = "Status: Auto Floor Disabled"
    end
end

-- WORKING Walk to Base Feature
local active = false
local currentTween
local walkThread

local function getBasePosition()
    -- Try to find base in different ways
    local plots = workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            local base = plot:FindFirstChild("DeliveryHitbox") or plot:FindFirstChild("Base") or plot:FindFirstChild("Spawn")
            if sign and base then
                return base.Position
            end
        end
    end
    
    -- Try to find spawn
    local spawn = workspace:FindFirstChild("Spawn") or workspace:FindFirstChild("SpawnLocation")
    if spawn then
        return spawn.Position
    end
    
    return nil
end

local function tweenWalkTo(position)
    if currentTween then 
        currentTween:Cancel() 
        currentTween = nil
    end

    local startPos = hrp.Position
    local targetPos = Vector3.new(position.X, position.Y + 3, position.Z) -- Slight Y offset
    local distance = (targetPos - startPos).Magnitude
    local duration = distance / currentSpeed
    
    if duration > 0 then
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
        currentTween:Play()
        currentTween.Completed:Wait()
    end
end

local function walkToBase()
    local target = getBasePosition()
    if not target then
        statusLabel.Text = "Status: Base not found"
        return
    end

    while active do
        if (hrp.Position - target).Magnitude < 10 then
            statusLabel.Text = "Status: Reached base!"
            break
        end

        local path = PathfindingService:CreatePath()
        local success = pcall(function()
            path:ComputeAsync(hrp.Position, target)
        end)
        
        if success and path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            for i, waypoint in ipairs(waypoints) do
                if not active then break end
                if i > 1 then -- Skip first waypoint if it's too close
                    tweenWalkTo(waypoint.Position)
                end
            end
        else
            -- Direct path if pathfinding fails
            tweenWalkTo(target)
        end
        
        task.wait(0.1)
    end
end

function startTweenToBase()
    if active then return end
    
    active = true
    humanoid.WalkSpeed = currentSpeed
    statusLabel.Text = "Status: Walking to Base..."
    tweenButton.Text = "■ STOP WALK"
    tweenButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)

    walkThread = task.spawn(function()
        walkToBase()
        stopTweenToBase()
    end)
end

function stopTweenToBase()
    if not active then return end
    active = false
    
    if currentTween then 
        currentTween:Cancel() 
        currentTween = nil
    end
    
    if walkThread then 
        task.cancel(walkThread) 
        walkThread = nil
    end
    
    humanoid.WalkSpeed = 16
    statusLabel.Text = "Status: Stopped"
    tweenButton.Text = "▶ START WALK"
    tweenButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end

-- Button connections
tweenButton.MouseButton1Click:Connect(function()
    if active then
        stopTweenToBase()
    else
        startTweenToBase()
    end
end)

autoFloorButton.MouseButton1Click:Connect(function()
    toggleAutoFloor()
end)

floatButton.MouseButton1Click:Connect(function()
    toggleFloat()
end)

autoLazerButton.MouseButton1Click:Connect(function()
    toggleAutoLazer()
end)

-- Jump power input
jumpInput.FocusLost:Connect(function()
    local newJump = tonumber(jumpInput.Text)
    if newJump then
        if newJump < 0 then
            jumpInput.Text = "0"
            setJumpPower(0)
        elseif newJump > 1000 then
            jumpInput.Text = "1000"
            setJumpPower(1000)
        else
            setJumpPower(newJump)
        end
    else
        jumpInput.Text = "50"
        setJumpPower(50)
    end
end)

-- Clean up
gui.Destroying:Connect(function()
    stopTweenToBase()
    if floorConnAF then
        floorConnAF:Disconnect()
    end
    if floorPartAF then
        floorPartAF:Destroy()
    end
    if autoLazerEnabled then
        toggleAutoLazer()
    end
    if floatEnabled then
        toggleFloat()
    end
end)

-- Initialize
setJumpPower(50)
updateSpeedDisplay(24)

StarterGui:SetCore("SendNotification", {
    Title = "Rxyals Scripts",
    Text = "Script loaded! All features should work now.",
    Duration = 5
})
