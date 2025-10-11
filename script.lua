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

-- GUI Setup (Increased height for new features)
local gui = Instance.new("ScreenGui")
gui.Name = "RxyalsScriptsGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 280) -- Increased height
frame.Position = UDim2.new(0.5, -100, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", frame)
title.Text = "Rxyals Scripts"
title.Size = UDim2.new(1, 0, 0, 16)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.ZIndex = 2

local tweenButton = Instance.new("TextButton", frame)
tweenButton.Text = "▶ START"
tweenButton.Size = UDim2.new(0.8, 0, 0, 25)
tweenButton.Position = UDim2.new(0.1, 0, 0.08, 0)
tweenButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tweenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tweenButton.Font = Enum.Font.GothamBold
tweenButton.TextSize = 14
tweenButton.ZIndex = 2
Instance.new("UICorner", tweenButton).CornerRadius = UDim.new(0, 6)

-- Speed Controller
local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Text = "Speed: 24 (Suggested)"
speedLabel.Size = UDim2.new(0.8, 0, 0, 16)
speedLabel.Position = UDim2.new(0.1, 0, 0.20, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 10
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedSlider = Instance.new("Frame", frame)
speedSlider.Size = UDim2.new(0.8, 0, 0, 20)
speedSlider.Position = UDim2.new(0.1, 0, 0.26, 0)
speedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedSlider.BorderSizePixel = 0
Instance.new("UICorner", speedSlider).CornerRadius = UDim.new(0, 4)

local speedFill = Instance.new("Frame", speedSlider)
speedFill.Size = UDim2.new(0.5, 0, 1, 0) -- Start at 50% (24 speed)
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
jumpLabel.Size = UDim2.new(0.8, 0, 0, 16)
jumpLabel.Position = UDim2.new(0.1, 0, 0.36, 0)
jumpLabel.BackgroundTransparency = 1
jumpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextSize = 10
jumpLabel.TextXAlignment = Enum.TextXAlignment.Left

local jumpInput = Instance.new("TextBox", frame)
jumpInput.Size = UDim2.new(0.3, 0, 0, 16)
jumpInput.Position = UDim2.new(0.65, 0, 0.36, 0)
jumpInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
jumpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpInput.Font = Enum.Font.Gotham
jumpInput.TextSize = 12
jumpInput.Text = "50"
jumpInput.PlaceholderText = "Jump"
Instance.new("UICorner", jumpInput).CornerRadius = UDim.new(0, 4)

-- Buttons
local autoFloorButton = Instance.new("TextButton", frame)
autoFloorButton.Text = "AUTO FLOOR: OFF"
autoFloorButton.Size = UDim2.new(0.8, 0, 0, 25)
autoFloorButton.Position = UDim2.new(0.1, 0, 0.48, 0)
autoFloorButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
autoFloorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFloorButton.Font = Enum.Font.GothamBold
autoFloorButton.TextSize = 14
autoFloorButton.ZIndex = 2
Instance.new("UICorner", autoFloorButton).CornerRadius = UDim.new(0, 6)

local floatButton = Instance.new("TextButton", frame)
floatButton.Text = "FLOAT: OFF"
floatButton.Size = UDim2.new(0.8, 0, 0, 25)
floatButton.Position = UDim2.new(0.1, 0, 0.60, 0)
floatButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
floatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
floatButton.Font = Enum.Font.GothamBold
floatButton.TextSize = 14
floatButton.ZIndex = 2
Instance.new("UICorner", floatButton).CornerRadius = UDim.new(0, 6)

local autoLazerButton = Instance.new("TextButton", frame)
autoLazerButton.Text = "AUTO LAZER: OFF"
autoLazerButton.Size = UDim2.new(0.8, 0, 0, 25)
autoLazerButton.Position = UDim2.new(0.1, 0, 0.72, 0)
autoLazerButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
autoLazerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoLazerButton.Font = Enum.Font.GothamBold
autoLazerButton.TextSize = 14
autoLazerButton.ZIndex = 2
Instance.new("UICorner", autoLazerButton).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Text = "Status: Idle"
statusLabel.Size = UDim2.new(1, 0, 0, 16)
statusLabel.Position = UDim2.new(0, 0, 0.96, 0)
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

-- Float Feature
local floatEnabled = false
local floatBodyForce
local floatConnection

local function toggleFloat()
    floatEnabled = not floatEnabled
    
    if floatEnabled then
        floatButton.Text = "FLOAT: ON"
        floatButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        -- Create BodyForce for floating
        floatBodyForce = Instance.new("BodyForce")
        floatBodyForce.Force = Vector3.new(0, workspace.Gravity * hrp:GetMass(), 0)
        floatBodyForce.Parent = hrp
        
        -- Update force when character changes
        floatConnection = player.CharacterAdded:Connect(function(char)
            task.wait(1) -- Wait for character to load
            hrp = char:WaitForChild("HumanoidRootPart")
            if floatBodyForce then
                floatBodyForce:Destroy()
            end
            floatBodyForce = Instance.new("BodyForce")
            floatBodyForce.Force = Vector3.new(0, workspace.Gravity * hrp:GetMass(), 0)
            floatBodyForce.Parent = hrp
        end)
        
        statusLabel.Text = "Status: Floating Enabled"
    else
        floatButton.Text = "FLOAT: OFF"
        floatButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        
        -- Clean up floating
        if floatBodyForce then
            floatBodyForce:Destroy()
            floatBodyForce = nil
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
    end
end

-- Auto Lazer Feature
local autoLazerEnabled = false
local autoLazerThread = nil

local function getLazerRemote()
    local remote = nil
    pcall(function()
        if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net") then
            remote = ReplicatedStorage.Packages.Net:FindFirstChild("RE/UseItem") or ReplicatedStorage.Packages.Net:FindFirstChild("RE"):FindFirstChild("UseItem")
        end
        if not remote then
            remote = ReplicatedStorage:FindFirstChild("RE/UseItem") or ReplicatedStorage:FindFirstChild("UseItem")
        end
    end)
    return remote
end

local function isValidTarget(player)
    if not player or not player.Character or player == Players.LocalPlayer then return false end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return false end
    if humanoid.Health <= 0 then return false end
    return true
end

local function findNearestAllowed()
    if not Players.LocalPlayer.Character or not Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = Players.LocalPlayer.Character.HumanoidRootPart.Position
    local nearest = nil
    local nearestDist = math.huge
    for _, pl in ipairs(Players:GetPlayers()) do
        if isValidTarget(pl) then
            local targetHRP = pl.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local d = (Vector3.new(targetHRP.Position.X, 0, targetHRP.Position.Z) - Vector3.new(myPos.X, 0, myPos.Z)).Magnitude
                if d < nearestDist then
                    nearestDist = d
                    nearest = pl
                end
            end
        end
    end
    return nearest
end

local function safeFire(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    local remote = getLazerRemote()
    local args = {
        [1] = targetHRP.Position,
        [2] = targetHRP
    }
    if remote and remote.FireServer then
        pcall(function()
            remote:FireServer(unpack(args))
        end)
    end
end

local function autoLazerWorker()
    while autoLazerEnabled do
        local target = findNearestAllowed()
        if target then
            safeFire(target)
        end
        local t0 = tick()
        while tick() - t0 < 0.6 do
            if not autoLazerEnabled then break end
            RunService.Heartbeat:Wait()
        end
    end
end

local function toggleAutoLazer()
    autoLazerEnabled = not autoLazerEnabled
    autoLazerButton.Text = autoLazerEnabled and "AUTO LAZER: ON" or "AUTO LAZER: OFF"
    
    if autoLazerEnabled then
        if autoLazerThread then
            task.cancel(autoLazerThread)
        end
        autoLazerThread = task.spawn(autoLazerWorker)
    else
        if autoLazerThread then
            task.cancel(autoLazerThread)
            autoLazerThread = nil
        end
    end
end

-- Auto Floor Feature
local floorOn = false
local floorPartAF, floorConnAF
local floorRiseSpeed = 2.0
local autoFloorSize = Vector3.new(6, 1, 6)

local function toggleAutoFloor()
    floorOn = not floorOn
    
    if floorOn then
        autoFloorButton.Text = "AUTO FLOOR: ON"
        autoFloorButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        -- Create floor part if it doesn't exist
        if not floorPartAF then
            floorPartAF = Instance.new("Part")
            floorPartAF.Size = autoFloorSize
            floorPartAF.Anchored = true
            floorPartAF.CanCollide = true
            floorPartAF.Material = Enum.Material.Neon
            floorPartAF.Color = Color3.fromRGB(80, 170, 255)
            floorPartAF.Parent = Workspace
        end
        
        -- Start following the player
        floorConnAF = RunService.RenderStepped:Connect(function()
            if hrp and floorPartAF then
                local currentPos = floorPartAF.Position
                local targetY = hrp.Position.Y - hrp.Size.Y/2 - floorPartAF.Size.Y/2
                
                if targetY > currentPos.Y then
                    local newY = currentPos.Y + (targetY - currentPos.Y) * floorRiseSpeed * (5/60)
                    floorPartAF.CFrame = CFrame.new(hrp.Position.X, newY, hrp.Position.Z)
                else
                    floorPartAF.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z)
                end
            end
        end)
    else
        autoFloorButton.Text = "AUTO FLOOR: OFF"
        autoFloorButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        
        -- Stop following but keep the floor part in place
        if floorConnAF then
            floorConnAF:Disconnect()
            floorConnAF = nil
        end
    end
end

-- Teleport UI (same as before)
local teleportGui = Instance.new("ScreenGui")
teleportGui.Name = "TeleportGui"
teleportGui.ResetOnSpawn = false
teleportGui.Parent = player:WaitForChild("PlayerGui")
teleportGui.Enabled = false

local blackScreen = Instance.new("Frame", teleportGui)
blackScreen.Size = UDim2.new(2, 0, 2, 0)
blackScreen.Position = UDim2.new(-0.5, 0, -0.5, 0)
blackScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackScreen.BorderSizePixel = 0
blackScreen.ZIndex = 100

local teleportText = Instance.new("TextLabel", blackScreen)
teleportText.Text = "TELEPORTING..."
teleportText.Size = UDim2.new(0.5, 0, 0, 100)
teleportText.Position = UDim2.new(0.25, 0, 0.5, -50)
teleportText.AnchorPoint = Vector2.new(0.5, 0.5)
teleportText.Position = UDim2.new(0.5, 0, 0.5, 0)
teleportText.BackgroundTransparency = 1
teleportText.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportText.Font = Enum.Font.GothamBlack
teleportText.TextSize = 48
teleportText.TextStrokeTransparency = 0.8
teleportText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
teleportText.ZIndex = 101

local function pulseText()
    while blackScreen.Visible do
        for i = 1, 10 do
            if not blackScreen.Visible then break end
            teleportText.TextTransparency = i * 0.05
            task.wait(0.1)
        end
        for i = 10, 1, -1 do
            if not blackScreen.Visible then break end
            teleportText.TextTransparency = i * 0.05
            task.wait(0.1)
        end
    end
end

-- Drag GUI
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

-- Anti Death
local function applyAntiDeath(state)
	if humanoid then
		for _, s in pairs({
			Enum.HumanoidStateType.FallingDown,
			Enum.HumanoidStateType.Ragdoll,
			Enum.HumanoidStateType.PlatformStanding,
			Enum.HumanoidStateType.Seated
		}) do
			humanoid:SetStateEnabled(s, not state)
		end
		if state then
			humanoid.Health = humanoid.MaxHealth
			humanoid:GetPropertyChangedSignal("Health"):Connect(function()
				if humanoid.Health <= 0 then
					humanoid.Health = humanoid.MaxHealth
				end
			end)
		end
	end
end

-- Find base position
local function getBasePosition()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end
	for _, plot in ipairs(plots:GetChildren()) do
		local sign = plot:FindFirstChild("PlotSign")
		local base = plot:FindFirstChild("DeliveryHitbox")
		if sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled and base then
			return base.Position
		end
	end
	return nil
end

local Y_OFFSET = 3
local STOP_DISTANCE = 10

local currentTween
local function tweenWalkTo(position)
	if currentTween then 
		currentTween:Cancel() 
		currentTween = nil
	end

	local startPos = hrp.Position
	local targetPos = Vector3.new(position.X, position.Y + Y_OFFSET, position.Z)
	local distance = (targetPos - startPos).Magnitude
	local duration = distance / currentSpeed
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)

	currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
	currentTween:Play()

	humanoid:ChangeState(Enum.HumanoidStateType.Running)

	currentTween.Completed:Wait()
	currentTween = nil
end

local active = false
local walkThread

local function isAtBase(basePos)
	if not basePos or not hrp then return false end
	local dist = (hrp.Position - Vector3.new(basePos.X, basePos.Y + Y_OFFSET, basePos.Z)).Magnitude
	return dist <= STOP_DISTANCE
end

local function checkIfAtBase(basePos)
    while active and basePos do
        if isAtBase(basePos) then
            warn("Reached Base, stopping tween.")
            statusLabel.Text = "Status: Reached Base"
            stopTweenToBase()
            break
        end
        task.wait(0.1)
    end
end

local function walkToBase()
    teleportGui.Enabled = true
    blackScreen.Visible = true
    task.spawn(pulseText)
    
    local target = getBasePosition()
    if not target then
        warn("Base Not Found")
        statusLabel.Text = "Status: Base Not Found"
        teleportGui.Enabled = false
        blackScreen.Visible = false
        return
    end

    task.spawn(checkIfAtBase, target)
    
    while active do
        if not target then
            warn("Base Not Found")
            statusLabel.Text = "Status: Base Not Found"
            task.wait(1)
            break
        end

        if isAtBase(target) then
            warn("Reached Base, stopping tween.")
            statusLabel.Text = "Status: Reached Base"
            stopTweenToBase()
            break
        end

        local path = PathfindingService:CreatePath()
        local success, err = pcall(function()
            path:ComputeAsync(hrp.Position, target)
        end)
        
        if not success then
            warn("Pathfinding error: " .. tostring(err))
            tweenWalkTo(target)
            break
        end

        if path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            for i, waypoint in ipairs(waypoints) do
                if not active or isAtBase(target) then 
                    return 
                end
                
                if i == 1 and (waypoint.Position - hrp.Position).Magnitude < 2 then
                    continue
                end
                
                tweenWalkTo(waypoint.Position)
            end
        else
            tweenWalkTo(target)
        end

        task.wait(0.1)
    end
end

function startTweenToBase()
	if active then return end
	
	active = true
	applyAntiDeath(true)
	humanoid.WalkSpeed = currentSpeed
	statusLabel.Text = "Status: Walking to Base..."
	tweenButton.Text = "■ STOP"

	walkThread = task.spawn(function()
		while active do
			walkToBase()
			if not active then break end
			task.wait(0.5)
		end
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
	tweenButton.Text = "▶ START"
	
	teleportGui.Enabled = false
	blackScreen.Visible = false
	
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
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

-- Clean up on script termination
gui.Destroying:Connect(function()
	stopTweenToBase()
    if floorConnAF then
        floorConnAF:Disconnect()
        floorConnAF = nil
    end
    if autoLazerEnabled then
        toggleAutoLazer()
    end
    if floatEnabled then
        toggleFloat()
    end
end)

-- Set initial values
setJumpPower(50)
updateSpeedDisplay(24) -- Start with recommended speed
