-- Fixed Auto Floor Feature (Goes Up)
local floorOn = false
local floorPart
local floorConnection

local function toggleAutoFloor()
    floorOn = not floorOn
    
    if floorOn then
        autoFloorButton.Text = "AUTO FLOOR: ON"
        autoFloorButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        statusLabel.Text = "Auto floor enabled"
        
        -- Create floor part
        floorPart = Instance.new("Part")
        floorPart.Size = Vector3.new(10, 1, 10)
        floorPart.Anchored = true
        floorPart.CanCollide = true
        floorPart.Material = Enum.Material.Neon
        floorPart.Color = Color3.fromRGB(80, 170, 255)
        floorPart.Transparency = 0.3
        floorPart.Parent = workspace
        
        if floorConnection then
            floorConnection:Disconnect()
        end
        
        floorConnection = RunService.Heartbeat:Connect(function()
            if hrp and floorPart then
                -- Position floor just below player's feet
                local targetY = hrp.Position.Y - (hrp.Size.Y/2) - (floorPart.Size.Y/2)
                floorPart.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z)
            end
        end)
        
    else
        autoFloorButton.Text = "AUTO FLOOR: OFF"
        autoFloorButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        statusLabel.Text = "Auto floor disabled"
        
        if floorConnection then
            floorConnection:Disconnect()
            floorConnection = nil
        end
        if floorPart then
            floorPart:Destroy()
            floorPart = nil
        end
    end
end

-- Original Tween System (No Death)
local active = false
local currentTween
local walkThread
local tweenSpeed = 24

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

local function tweenWalkTo(position)
    if currentTween then 
        currentTween:Cancel() 
        currentTween = nil
    end

    local startPos = hrp.Position
    local targetPos = Vector3.new(position.X, position.Y + Y_OFFSET, position.Z)
    local distance = (targetPos - startPos).Magnitude
    local speed = math.max(tweenSpeed, 16)
    local duration = distance / speed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)

    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    currentTween:Play()

    humanoid:ChangeState(Enum.HumanoidStateType.Running)

    currentTween.Completed:Wait()
    currentTween = nil
end

local function isAtBase(basePos)
    if not basePos or not hrp then return false end
    local dist = (hrp.Position - Vector3.new(basePos.X, basePos.Y + Y_OFFSET, basePos.Z)).Magnitude
    return dist <= STOP_DISTANCE
end

local function walkToBase()
    local target = getBasePosition()
    if not target then
        statusLabel.Text = "Base Not Found"
        return
    end

    while active do
        if not target then
            statusLabel.Text = "Base Not Found"
            task.wait(1)
            break
        end

        if isAtBase(target) then
            statusLabel.Text = "Reached Base"
            stopTweenToBase()
            break
        end

        local path = PathfindingService:CreatePath()
        local success, err = pcall(function()
            path:ComputeAsync(hrp.Position, target)
        end)
        
        if not success then
            statusLabel.Text = "Direct path to base"
            tweenWalkTo(target)
            break
        end

        if path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            statusLabel.Text = "Following path (" .. #waypoints .. " points)"
            
            for i, waypoint in ipairs(waypoints) do
                if not active or isAtBase(target) then 
                    return 
                end
                
                -- Skip first waypoint if it's too close
                if not (i == 1 and (waypoint.Position - hrp.Position).Magnitude < 2) then
                    tweenWalkTo(waypoint.Position)
                end
            end
        else
            statusLabel.Text = "Direct path (no obstacles)"
            tweenWalkTo(target)
        end

        task.wait(0.1)
    end
end

function startTweenToBase()
    if active then return end
    
    active = true
    tweenButton.Text = "■ STOP TWEEN"
    tweenButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    statusLabel.Text = "Walking to Base..."

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
    tweenButton.Text = "▶ TWEEN TO BASE"
    tweenButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    statusLabel.Text = "Ready"
    
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end
