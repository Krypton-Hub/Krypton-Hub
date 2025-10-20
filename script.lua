-- Krypton Hub - Made By agent_duke13 - Enhanced Version

local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character, hrp, humanoid

-- Safe character reference system
local function updateCharacterReferences()
    character = player.Character
    if character then
        hrp = character:FindFirstChild("HumanoidRootPart")
        humanoid = character:FindFirstChildOfClass("Humanoid")
    else
        hrp = nil
        humanoid = nil
    end
end

updateCharacterReferences()

player.CharacterAdded:Connect(function(c)
    character = c
    hrp = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
end)

player.CharacterRemoving:Connect(function()
    character = nil
    hrp = nil
    humanoid = nil
end)

-- Enhanced GUI Design
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "KryptonToggle"
toggleGui.ResetOnSpawn = false
toggleGui.Parent = player:WaitForChild("PlayerGui")

local toggleButton = Instance.new("ImageButton")
toggleButton.Size = UDim2.new(0, 65, 0, 65)
toggleButton.Position = UDim2.new(0, 20, 0.5, -32.5)
toggleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
toggleButton.BackgroundTransparency = 0.2
toggleButton.Image = "rbxassetid://95131705390407"
toggleButton.ImageColor3 = Color3.fromRGB(0, 170, 255)
toggleButton.Active = true
toggleButton.Draggable = true
toggleButton.Parent = toggleGui

local toggleGlow = Instance.new("UIStroke")
toggleGlow.Color = Color3.fromRGB(0, 170, 255)
toggleGlow.Thickness = 2
toggleGlow.Parent = toggleButton

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = toggleButton

-- Enhanced Main GUI
local gui = Instance.new("ScreenGui")
gui.Name = "KryptonHubGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
gui.Enabled = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 450)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local mainGlow = Instance.new("UIStroke")
mainGlow.Color = Color3.fromRGB(0, 170, 255)
mainGlow.Thickness = 2
mainGlow.Parent = mainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = "KRYPTON HUB v2.0"
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.BackgroundTransparency = 0.1
title.TextColor3 = Color3.fromRGB(0, 170, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.ZIndex = 2
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

local subtitle = Instance.new("TextLabel")
subtitle.Text = "by agent_duke13"
subtitle.Size = UDim2.new(1, 0, 0, 15)
subtitle.Position = UDim2.new(0, 0, 0, 35)
subtitle.BackgroundTransparency = 1
subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.Parent = mainFrame

-- Enhanced Tab buttons
local tabs = {"Main", "Steal", "Visuals", "Combat"}
local currentTab = "Main"

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 35)
tabContainer.Position = UDim2.new(0, 10, 0, 55)
tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
tabContainer.BackgroundTransparency = 0.1
tabContainer.Parent = mainFrame

local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 8)
tabCorner.Parent = tabContainer

local tabButtons = {}
for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Text = tabName
    tabButton.Size = UDim2.new(1/#tabs, -5, 0.8, 0)
    tabButton.Position = UDim2.new((i-1)/#tabs, 2.5, 0.1, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.Font = Enum.Font.GothamBold
    tabButton.TextSize = 11
    tabButton.ZIndex = 2
    tabButton.Parent = tabContainer
    
    local tabBtnCorner = Instance.new("UICorner")
    tabBtnCorner.CornerRadius = UDim.new(0, 6)
    tabBtnCorner.Parent = tabButton
    
    local tabStroke = Instance.new("UIStroke")
    tabStroke.Color = Color3.fromRGB(60, 60, 60)
    tabStroke.Thickness = 1
    tabStroke.Parent = tabButton
    
    tabButtons[tabName] = tabButton
end

-- Content frame
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -110)
contentFrame.Position = UDim2.new(0, 10, 0, 95)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Enhanced Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Status: Ready"
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 1, -30)
statusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
statusLabel.BackgroundTransparency = 0.1
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusLabel

-- Enhanced button styling function
local function createStyledButton(parent, text, position, customColor)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(0.9, 0, 0, 32)
    button.Position = position
    button.BackgroundColor3 = customColor or Color3.fromRGB(35, 35, 35)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.AutoButtonColor = false
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 1
    stroke.Parent = button
    
    local hoverEffect = Instance.new("Frame")
    hoverEffect.Size = UDim2.new(1, 0, 1, 0)
    hoverEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hoverEffect.BackgroundTransparency = 0.9
    hoverEffect.BorderSizePixel = 0
    hoverEffect.Parent = button
    hoverEffect.Visible = false
    
    local hoverCorner = Instance.new("UICorner")
    hoverCorner.CornerRadius = UDim.new(0, 8)
    hoverCorner.Parent = hoverEffect
    
    button.MouseEnter:Connect(function()
        hoverEffect.Visible = true
        stroke.Color = Color3.fromRGB(0, 170, 255)
    end)
    
    button.MouseLeave:Connect(function()
        hoverEffect.Visible = false
        stroke.Color = Color3.fromRGB(60, 60, 60)
    end)
    
    return button
end

-- Enhanced input field function
local function createInputField(parent, label, position, defaultValue)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.9, 0, 0, 30)
    container.Position = position
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = label
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.4, 0, 1, 0)
    input.Position = UDim2.new(0.6, 0, 0, 0)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Font = Enum.Font.Gotham
    input.TextSize = 11
    input.Text = tostring(defaultValue)
    input.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    input.Parent = container

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input

    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = Color3.fromRGB(60, 60, 60)
    inputStroke.Thickness = 1
    inputStroke.Parent = input

    return input
end

-- Main Tab Content
local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1, 0, 1, 0)
mainContent.BackgroundTransparency = 1
mainContent.Visible = true
mainContent.Parent = contentFrame

-- ========== ENHANCED TWEEN TO BASE SYSTEM ==========
local tweenButton = createStyledButton(mainContent, "▶ TWEEN TO BASE", UDim2.new(0.05, 0, 0.02, 0))

local active = false
local currentTween
local walkThread
local tweenSpeed = 24

local function applyAntiDeath(state)
    updateCharacterReferences()
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

local function getBasePosition()
    local plots = Workspace:FindFirstChild("Plots")
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

    updateCharacterReferences()
    if not hrp then
        statusLabel.Text = "Error: No character"
        return false
    end

    local startPos = hrp.Position
    local targetPos = Vector3.new(position.X, position.Y + Y_OFFSET, position.Z)
    local distance = (targetPos - startPos).Magnitude
    local speed = math.max(tweenSpeed, 16)
    local duration = distance / speed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)

    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    currentTween:Play()

    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end

    currentTween.Completed:Wait()
    currentTween = nil
    return true
end

local function isAtBase(basePos)
    if not basePos or not hrp then return false end
    local dist = (hrp.Position - Vector3.new(basePos.X, basePos.Y + Y_OFFSET, basePos.Z)).Magnitude
    return dist <= STOP_DISTANCE
end

local function walkToBase()
    updateCharacterReferences()
    if not hrp then
        statusLabel.Text = "Error: No character"
        return
    end

    local target = getBasePosition()
    if not target then
        statusLabel.Text = "Base Not Found"
        return
    end

    while active do
        updateCharacterReferences()
        if not hrp then
            statusLabel.Text = "Character died, stopping"
            stopTweenToBase()
            break
        end

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
            local tweenSuccess = pcall(tweenWalkTo, target)
            if not tweenSuccess then
                statusLabel.Text = "Tween failed"
                stopTweenToBase()
            end
            break
        end

        if path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            statusLabel.Text = "Following path (" .. #waypoints .. " points)"
            
            for i, waypoint in ipairs(waypoints) do
                if not active or not hrp or isAtBase(target) then 
                    return 
                end
                
                if not (i == 1 and (waypoint.Position - hrp.Position).Magnitude < 2) then
                    local tweenSuccess = pcall(tweenWalkTo, waypoint.Position)
                    if not tweenSuccess then
                        statusLabel.Text = "Path tween failed"
                        return
                    end
                end
            end
        else
            statusLabel.Text = "Direct path (no obstacles)"
            local tweenSuccess = pcall(tweenWalkTo, target)
            if not tweenSuccess then
                statusLabel.Text = "Direct tween failed"
                stopTweenToBase()
            end
        end

        task.wait(0.1)
    end
end

function startTweenToBase()
    if active then return end
    
    updateCharacterReferences()
    if not hrp then
        statusLabel.Text = "Error: No character"
        return
    end
    
    active = true
    applyAntiDeath(true)
    tweenButton.Text = "■ STOP TWEEN"
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
    
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    
    tweenButton.Text = "▶ TWEEN TO BASE"
    statusLabel.Text = "Ready"
end

-- Enhanced Speed and Jump inputs
local speedInput = createInputField(mainContent, "Speed:", UDim2.new(0.05, 0, 0.12, 0), 24)
local jumpInput = createInputField(mainContent, "Jump Power:", UDim2.new(0.05, 0, 0.20, 0), 50)

-- ========== ENHANCED FLIGHT SYSTEM ==========
local flyButton = createStyledButton(mainContent, "SLOW FLIGHT: OFF", UDim2.new(0.05, 0, 0.28, 0))

local guidedOn = false
local guidedConn

local function toggleFlight()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    guidedOn = not guidedOn
    flyButton.Text = guidedOn and "SLOW FLIGHT: ON" or "SLOW FLIGHT: OFF"
    
    if guidedOn then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            guidedConn = RunService.RenderStepped:Connect(function()
                if guidedOn and hrp then
                    hrp.Velocity = Workspace.CurrentCamera.CFrame.LookVector * 25
                end
            end)
        end
    else
        if guidedConn then 
            guidedConn:Disconnect() 
            guidedConn = nil 
        end
        if hum then 
            hum:ChangeState(Enum.HumanoidStateType.GettingUp) 
        end
    end
end

-- ========== ENHANCED FLOAT SYSTEM ==========
local floatButton = createStyledButton(mainContent, "FLOAT: OFF", UDim2.new(0.05, 0, 0.36, 0))

local floatEnabled = false
local floatBodyVelocity
local floatConnection

local function toggleFloat()
    floatEnabled = not floatEnabled
    
    if floatEnabled then
        floatButton.Text = "FLOAT: ON"
        statusLabel.Text = "Float enabled"
        
        floatBodyVelocity = Instance.new("BodyVelocity")
        floatBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        floatBodyVelocity.MaxForce = Vector3.new(0, 0, 0)
        
        if floatConnection then
            floatConnection:Disconnect()
        end
        
        floatConnection = RunService.Heartbeat:Connect(function()
            updateCharacterReferences()
            if not floatEnabled or not character or not hrp then
                return
            end
            
            local rayOrigin = hrp.Position
            local rayDirection = Vector3.new(0, -10, 0)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            
            local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
            
            if not raycastResult then
                floatBodyVelocity.Velocity = Vector3.new(0, 30, 0)
                floatBodyVelocity.MaxForce = Vector3.new(0, 50000, 0)
            else
                floatBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                floatBodyVelocity.MaxForce = Vector3.new(0, 0, 0)
            end
            
            if floatBodyVelocity and floatBodyVelocity.Parent ~= hrp then
                floatBodyVelocity.Parent = hrp
            end
        end)
        
    else
        floatButton.Text = "FLOAT: OFF"
        statusLabel.Text = "Float disabled"
        
        if floatConnection then
            floatConnection:Disconnect()
            floatConnection = nil
        end
        if floatBodyVelocity then
            floatBodyVelocity:Destroy()
            floatBodyVelocity = nil
        end
    end
end

-- ========== ENHANCED AUTO FLOOR SYSTEM ==========
local autoFloorButton = createStyledButton(mainContent, "AUTO FLOOR: OFF", UDim2.new(0.05, 0, 0.44, 0))

local floorOn = false
local floorPart
local floorConnection
local floorRiseSpeed = 5.0
local autoFloorSize = Vector3.new(8, 1, 8)

local function toggleAutoFloor()
    floorOn = not floorOn
    
    if floorOn then
        autoFloorButton.Text = "AUTO FLOOR: ON"
        statusLabel.Text = "Auto floor enabled (Rising)"
        
        floorPart = Instance.new("Part")
        floorPart.Size = autoFloorSize
        floorPart.Anchored = true
        floorPart.CanCollide = true
        floorPart.Material = Enum.Material.Neon
        floorPart.Color = Color3.fromRGB(80, 170, 255)
        floorPart.Transparency = 0.3
        floorPart.Name = "KryptonAutoFloor"
        floorPart.Parent = Workspace
        
        local pointLight = Instance.new("PointLight")
        pointLight.Brightness = 0.5
        pointLight.Range = 12
        pointLight.Color = Color3.fromRGB(80, 170, 255)
        pointLight.Parent = floorPart
        
        if floorConnection then
            floorConnection:Disconnect()
        end
        
        floorConnection = RunService.RenderStepped:Connect(function()
            if not floorOn or not floorPart then
                return
            end
            
            updateCharacterReferences()
            
            if not hrp then
                return
            end
            
            local currentPos = floorPart.Position
            local targetY = hrp.Position.Y - (hrp.Size.Y/2) - (floorPart.Size.Y/2)
            
            if targetY > currentPos.Y then
                local newY = currentPos.Y + (targetY - currentPos.Y) * floorRiseSpeed * (1/60)
                floorPart.CFrame = CFrame.new(hrp.Position.X, newY, hrp.Position.Z)
            else
                floorPart.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z)
            end
        end)
        
    else
        autoFloorButton.Text = "AUTO FLOOR: OFF"
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

-- ========== ENHANCED SEMI INVISIBLE SYSTEM ==========
local semiInvisButton = createStyledButton(mainContent, "SEMI INVISIBLE: OFF", UDim2.new(0.05, 0, 0.52, 0))

local connections = {
    SemiInvisible = {}
}

local isInvisible = false
local clone, oldRoot, hip, animTrack, connection, characterConnection

local function semiInvisibleFunction()
    local DEPTH_OFFSET = 0.15

    local function removeFolders()  
        local playerName = player.Name  
        local playerFolder = Workspace:FindFirstChild(playerName)  
        if not playerFolder then  
            return  
        end  

        local doubleRig = playerFolder:FindFirstChild("DoubleRig")  
        if doubleRig then  
            doubleRig:Destroy()  
        end  

        local constraints = playerFolder:FindFirstChild("Constraints")  
        if constraints then  
            constraints:Destroy()  
        end  

        local childAddedConn = playerFolder.ChildAdded:Connect(function(child)  
            if child.Name == "DoubleRig" or child.Name == "Constraints" then  
                child:Destroy()  
            end  
        end)  
        table.insert(connections.SemiInvisible, childAddedConn)  
    end  

    local function doClone()  
        updateCharacterReferences()
        if not character or not humanoid or humanoid.Health <= 0 then  
            statusLabel.Text = "Cannot enable: No character or dead"
            return false  
        end
        
        hip = humanoid.HipHeight  
        oldRoot = character:FindFirstChild("HumanoidRootPart")  
        if not oldRoot or not oldRoot.Parent then  
            statusLabel.Text = "Error: No HumanoidRootPart"
            return false  
        end  

        local tempParent = Instance.new("Model")  
        tempParent.Parent = game  
        character.Parent = tempParent  

        clone = oldRoot:Clone()  
        clone.Parent = character  
        oldRoot.Parent = Workspace.CurrentCamera  
        clone.CFrame = oldRoot.CFrame  

        character.PrimaryPart = clone  
        character.Parent = Workspace  

        for _, v in pairs(character:GetDescendants()) do  
            if v:IsA("Weld") or v:IsA("Motor6D") then  
                if v.Part0 == oldRoot then  
                    v.Part0 = clone  
                end  
                if v.Part1 == oldRoot then  
                    v.Part1 = clone  
                end  
            end  
        end  

        tempParent:Destroy()  
        return true  
    end  

    local function revertClone()  
        if not oldRoot or not oldRoot:IsDescendantOf(Workspace) or not character then  
            return false  
        end
        
        updateCharacterReferences()
        if humanoid and humanoid.Health <= 0 then
            return false
        end

        local tempParent = Instance.new("Model")  
        tempParent.Parent = game  
        character.Parent = tempParent  

        oldRoot.Parent = character  
        character.PrimaryPart = oldRoot  
        character.Parent = Workspace  
        oldRoot.CanCollide = true  

        for _, v in pairs(character:GetDescendants()) do  
            if v:IsA("Weld") or v:IsA("Motor6D") then  
                if v.Part0 == clone then  
                    v.Part0 = oldRoot  
                end  
                if v.Part1 == clone then  
                    v.Part1 = oldRoot  
                end  
            end  
        end  

        if clone then  
            local oldPos = clone.CFrame  
            clone:Destroy()  
            clone = nil  
            oldRoot.CFrame = oldPos  
        end  

        oldRoot = nil  
        if character and humanoid then  
            humanoid.HipHeight = hip  
        end  
    end  

    local function animationTrickery()  
        updateCharacterReferences()
        if not character or not humanoid or humanoid.Health <= 0 then 
            return 
        end
            
        local anim = Instance.new("Animation")  
        anim.AnimationId = "rbxassetid://18537363391"
        local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)  
        animTrack = animator:LoadAnimation(anim)  
        animTrack.Priority = Enum.AnimationPriority.Action4  
        animTrack:Play(0, 1, 0)  
        anim:Destroy()  

        local animStoppedConn = animTrack.Stopped:Connect(function()  
            if isInvisible then  
                animationTrickery()  
            end  
        end)  
        table.insert(connections.SemiInvisible, animStoppedConn)  

        task.delay(0, function()  
            animTrack.TimePosition = 0.7  
            task.delay(1, function()  
                animTrack:AdjustSpeed(math.huge)  
            end)  
        end)  
    end  

    local function enableInvisibility()  
        updateCharacterReferences()
        if not character or not humanoid or humanoid.Health <= 0 then  
            statusLabel.Text = "Cannot enable: No character or dead"
            return false
        end  

        removeFolders()  
        local success = doClone()  
        if success then  
            task.wait(0.1)  
            animationTrickery()  
            connection = RunService.PreSimulation:Connect(function(dt)  
                updateCharacterReferences()
                if character and humanoid and humanoid.Health > 0 and oldRoot then  
                    local root = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")  
                    if root then  
                        local cf = root.CFrame - Vector3.new(0, humanoid.HipHeight + (root.Size.Y / 2) - 1.5 + DEPTH_OFFSET, 0)  
                        oldRoot.CFrame = cf * CFrame.Angles(math.rad(180), math.rad(45), 0)
                        oldRoot.Velocity = root.Velocity  
                        oldRoot.CanCollide = false  
                        oldRoot.Transparency = 0.8
                    end  
                end  
            end)  
            table.insert(connections.SemiInvisible, connection)  

            characterConnection = player.CharacterAdded:Connect(function(newChar)
                if isInvisible then
                    if animTrack then  
                        animTrack:Stop()  
                        animTrack:Destroy()  
                        animTrack = nil  
                    end  
                    if connection then connection:Disconnect() end  
                    revertClone()
                    removeFolders()
                    isInvisible = false
                    semiInvisButton.Text = "SEMI INVISIBLE: OFF"
                    
                    for _, conn in ipairs(connections.SemiInvisible) do  
                        if conn then conn:Disconnect() end  
                    end  
                    connections.SemiInvisible = {}
                end
            end)
            table.insert(connections.SemiInvisible, characterConnection)
            
            return true
        end  
        return false
    end  

    local function disableInvisibility()  
        if animTrack then  
            animTrack:Stop()  
            animTrack:Destroy()  
            animTrack = nil  
        end  
        if connection then connection:Disconnect() end  
        if characterConnection then characterConnection:Disconnect() end  
        revertClone()  
        removeFolders()  
    end

    if not isInvisible then
        removeFolders()  
        if enableInvisibility() then
            isInvisible = true
            semiInvisButton.Text = "SEMI INVISIBLE: ON"
            statusLabel.Text = "Semi Invisible enabled"
        else
            statusLabel.Text = "Failed to enable Semi Invisible"
        end
    else
        disableInvisibility()
        isInvisible = false
        semiInvisButton.Text = "SEMI INVISIBLE: OFF"
        statusLabel.Text = "Semi Invisible disabled"
        
        for _, conn in ipairs(connections.SemiInvisible) do  
            if conn then conn:Disconnect() end  
        end  
        connections.SemiInvisible = {}  
    end
end

-- ========== STEAL TAB CONTENT ==========
local stealContent = Instance.new("Frame")
stealContent.Size = UDim2.new(1, 0, 1, 0)
stealContent.BackgroundTransparency = 1
stealContent.Visible = false
stealContent.Parent = contentFrame

-- 2nd Floor Steal
local secondFloorButton = createStyledButton(stealContent, "2ND FLOOR STEAL", UDim2.new(0.05, 0, 0.05, 0), Color3.fromRGB(220, 20, 60))

-- 3rd Floor Steal
local thirdFloorButton = createStyledButton(stealContent, "3RD FLOOR STEAL", UDim2.new(0.05, 0, 0.15, 0), Color3.fromRGB(220, 20, 60))

-- Desync Anti-Hit
local desyncButton = createStyledButton(stealContent, "DESYNC (ANTI HIT): OFF", UDim2.new(0.05, 0, 0.25, 0), Color3.fromRGB(220, 20, 60))

-- ========== DESYNC SYSTEM ==========
local desyncActive = false

local function enableMobileDesync()
    local success, error = pcall(function()
        local backpack = player:WaitForChild("Backpack")
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
        local packages = ReplicatedStorage:WaitForChild("Packages", 5)
        if not packages then warn("Packages not found") return false end
        
        local netFolder = packages:WaitForChild("Net", 5)
        if not netFolder then warn("Net folder not found") return false end
        
        local useItemRemote = netFolder:WaitForChild("RE/UseItem", 5)
        local teleportRemote = netFolder:WaitForChild("RE/QuantumCloner/OnTeleport", 5)
        if not useItemRemote or not teleportRemote then warn("Remotes not found") return false end
        
        local toolNames = {"Quantum Cloner", "whatever", "whatever"}
        local tool
        for _, toolName in ipairs(toolNames) do
            tool = backpack:FindFirstChild(toolName) or character:FindFirstChild(toolName)
            if tool then break end
        end
        if not tool then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then tool=item break end
            end
        end
        
        if tool and tool.Parent==backpack then
            humanoid:EquipTool(tool)
            task.wait(0.5)
        end
        
        if setfflag then setfflag("WorldStepMax", "-9999999999") end
        task.wait(0.2)
        useItemRemote:FireServer()
        task.wait(1)
        teleportRemote:FireServer()
        task.wait(2)
        if setfflag then setfflag("WorldStepMax", "-1") end
        print("Desync activated")
        return true
    end)
    if not success then
        warn("Desync error: " .. tostring(error))
        return false
    end
    return success
end

local function disableMobileDesync()
    pcall(function()
        if setfflag then setfflag("WorldStepMax", "-1") end
        print("Desync deactivated")
    end)
end

desyncButton.MouseButton1Click:Connect(function()
    desyncActive = not desyncActive
    if desyncActive then
        local success = enableMobileDesync()
        if success then
            desyncButton.Text = "DESYNC (ANTI HIT): ON"
        else
            desyncActive=false
            desyncButton.Text = "DESYNC (ANTI HIT): OFF"
        end
    else
        disableMobileDesync()
        desyncButton.Text = "DESYNC (ANTI HIT): OFF"
    end
end)

player.CharacterAdded:Connect(function()
    desyncActive=false
    desyncButton.Text = "DESYNC (ANTI HIT): OFF"
end)

-- ========== VISUALS TAB CONTENT ==========
local visualsContent = Instance.new("Frame")
visualsContent.Size = UDim2.new(1, 0, 1, 0)
visualsContent.BackgroundTransparency = 1
visualsContent.Visible = false
visualsContent.Parent = contentFrame

-- Player ESP
local espButton = createStyledButton(visualsContent, "PLAYER ESP: OFF", UDim2.new(0.05, 0, 0.05, 0))

local espEnabled = false
local espFolders = {}
local espConnections = {}

local function createESP(player)
    if player == Players.LocalPlayer then return end
    
    local folder = Instance.new("Folder")
    folder.Name = player.Name .. "_ESP"
    folder.Parent = Workspace
    espFolders[player] = folder
    
    local function updateESP(character)
        if not character or not folder then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end
        
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "Box"
        box.Adornee = hrp
        box.AlwaysOnTop = true
        box.ZIndex = 1
        box.Size = Vector3.new(4, 6, 2)
        box.Color3 = humanoid.Health > 0 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        box.Transparency = 0.3
        box.Parent = folder
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "NameTag"
        billboard.Adornee = hrp
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        billboard.AlwaysOnTop = true
        
        local nameLabel = Instance.new("TextLabel", billboard)
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        
        local healthLabel = Instance.new("TextLabel", billboard)
        healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
        healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.Text = "HP: " .. math.floor(humanoid.Health)
        healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        healthLabel.TextStrokeTransparency = 0
        healthLabel.Font = Enum.Font.Gotham
        healthLabel.TextSize = 12
        
        billboard.Parent = folder
        
        local healthConnection = humanoid.HealthChanged:Connect(function()
            if folder and healthLabel then
                healthLabel.Text = "HP: " .. math.floor(humanoid.Health)
                if box then
                    box.Color3 = humanoid.Health > 0 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                end
            end
        end)
        
        table.insert(espConnections, healthConnection)
    end
    
    if player.Character then
        updateESP(player.Character)
    end
    
    local charConnection = player.CharacterAdded:Connect(updateESP)
    table.insert(espConnections, charConnection)
end

local function removeESP(player)
    if espFolders[player] then
        espFolders[player]:Destroy()
        espFolders[player] = nil
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    espButton.Text = espEnabled and "PLAYER ESP: ON" or "PLAYER ESP: OFF"
    
    if espEnabled then
        statusLabel.Text = "ESP enabled"
        for _, plr in ipairs(Players:GetPlayers()) do
            createESP(plr)
        end
        
        local playerAddedConnection = Players.PlayerAdded:Connect(createESP)
        table.insert(espConnections, playerAddedConnection)
        
        local playerRemovingConnection = Players.PlayerRemoving:Connect(function(plr)
            removeESP(plr)
        end)
        table.insert(espConnections, playerRemovingConnection)
        
    else
        statusLabel.Text = "ESP disabled"
        for plr, folder in pairs(espFolders) do
            if folder then
                folder:Destroy()
            end
        end
        espFolders = {}
        
        for _, connection in ipairs(espConnections) do
            if connection then
                connection:Disconnect()
            end
        end
        espConnections = {}
    end
end

-- ========== COMBAT TAB CONTENT ==========
local combatContent = Instance.new("Frame")
combatContent.Size = UDim2.new(1, 0, 1, 0)
combatContent.BackgroundTransparency = 1
combatContent.Visible = false
combatContent.Parent = contentFrame

-- Auto Lazer
local autoLazerButton = createStyledButton(combatContent, "AUTO LAZER: OFF", UDim2.new(0.05, 0, 0.05, 0))

local autoLazerEnabled = false
local autoLazerThread = nil

local function getLazerRemote()
    local remote = nil
    local possiblePaths = {
        "Packages.Net.RE/UseItem",
        "Packages.Net.RE.UseItem", 
        "RE/UseItem",
        "UseItem",
        "Packages.Knit.Services.WeaponService.RE.UseItem",
        "WeaponService.RE.UseItem"
    }
    
    for _, path in ipairs(possiblePaths) do
        local success, result = pcall(function()
            local current = ReplicatedStorage
            for part in path:gmatch("[^%.]+") do
                if part:find("/") then
                    local parts = {}
                    for p in part:gmatch("[^%/]+") do
                        table.insert(parts, p)
                    end
                    current = current:FindFirstChild(parts[1])
                    if current and #parts > 1 then
                        for i = 2, #parts do
                            current = current:FindFirstChild(parts[i])
                            if not current then break end
                        end
                    end
                else
                    current = current:FindFirstChild(part)
                end
                if not current then return nil end
            end
            return current
        end)
        
        if success and result then
            remote = result
            break
        end
    end
    
    return remote
end

local function isValidTarget(player)
    if not player or not player.Character or player == Players.LocalPlayer then return false end
    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not targetHRP or not targetHumanoid then return false end
    if targetHumanoid.Health <= 0 then return false end
    return true
end

local function findNearestAllowed()
    updateCharacterReferences()
    if not character or not hrp then return nil end
    
    local myPos = hrp.Position
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
    if not remote then
        statusLabel.Text = "Lazer remote not found"
        return
    end
    
    local args = {
        [1] = targetHRP.Position,
        [2] = targetHRP
    }
    
    local success, err = pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer(unpack(args))
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(unpack(args))
        end
    end)
    
    if not success then
        statusLabel.Text = "Failed to fire lazer: " .. tostring(err)
    end
end

local function autoLazerWorker()
    while autoLazerEnabled do
        local target = findNearestAllowed()
        if target then
            safeFire(target)
        else
            statusLabel.Text = "No valid targets found"
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
    statusLabel.Text = autoLazerEnabled and "Auto lazer enabled" or "Auto lazer disabled"
    
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

-- Enhanced DISCORD BUTTON
local discordBtn = createStyledButton(contentFrame, "📱 DISCORD", UDim2.new(0.05, 0, 0.85, 0), Color3.fromRGB(88, 101, 242))

discordBtn.MouseButton1Click:Connect(function()
    if setclipboard then 
        setclipboard("https://discord.gg/YSwFZsGk9j")
    elseif toclipboard then 
        toclipboard("https://discord.gg/YSwFZsGk9j") 
    end
    local originalText = discordBtn.Text
    discordBtn.Text = "Link Copied!"
    task.wait(2)
    discordBtn.Text = originalText
end)

-- ========== TAB SYSTEM ==========
local function switchTab(tabName)
    currentTab = tabName
    mainContent.Visible = (tabName == "Main")
    stealContent.Visible = (tabName == "Steal")
    visualsContent.Visible = (tabName == "Visuals")
    combatContent.Visible = (tabName == "Combat")
    
    for name, button in pairs(tabButtons) do
        if name == tabName then
            button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end

-- Initialize tabs
for tabName, button in pairs(tabButtons) do
    button.MouseButton1Click:Connect(function()
        switchTab(tabName)
    end)
end
switchTab("Main")

-- Toggle GUI visibility
toggleButton.MouseButton1Click:Connect(function()
    gui.Enabled = not gui.Enabled
end)

-- Enhanced button update function
local function updateButtonState(button, isActive, activeColor)
    if isActive then
        button.BackgroundColor3 = activeColor or Color3.fromRGB(0, 170, 0)
        local stroke = button:FindFirstChild("UIStroke")
        if stroke then
            stroke.Color = activeColor or Color3.fromRGB(0, 200, 0)
        end
    else
        button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        local stroke = button:FindFirstChild("UIStroke")
        if stroke then
            stroke.Color = Color3.fromRGB(60, 60, 60)
        end
    end
end

-- Button connections
tweenButton.MouseButton1Click:Connect(function()
    if active then
        stopTweenToBase()
        updateButtonState(tweenButton, false)
    else
        startTweenToBase()
        updateButtonState(tweenButton, true, Color3.fromRGB(200, 0, 0))
    end
end)

flyButton.MouseButton1Click:Connect(function()
    toggleFlight()
    updateButtonState(flyButton, guidedOn)
end)

floatButton.MouseButton1Click:Connect(function()
    toggleFloat()
    updateButtonState(floatButton, floatEnabled)
end)

autoFloorButton.MouseButton1Click:Connect(function()
    toggleAutoFloor()
    updateButtonState(autoFloorButton, floorOn)
end)

semiInvisButton.MouseButton1Click:Connect(function()
    semiInvisibleFunction()
    updateButtonState(semiInvisButton, isInvisible)
end)

espButton.MouseButton1Click:Connect(function()
    toggleESP()
    updateButtonState(espButton, espEnabled)
end)

autoLazerButton.MouseButton1Click:Connect(function()
    toggleAutoLazer()
    updateButtonState(autoLazerButton, autoLazerEnabled)
end)

-- 2nd Floor Steal placeholder
secondFloorButton.MouseButton1Click:Connect(function()
    statusLabel.Text = "2nd Floor Steal activated"
end)

-- 3rd Floor Steal placeholder
thirdFloorButton.MouseButton1Click:Connect(function()
    statusLabel.Text = "3rd Floor Steal activated"
end)

-- Drag GUI
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Set initial values
local function setSpeed(value)
    updateCharacterReferences()
    if humanoid then
        humanoid.WalkSpeed = value
    end
end

local function setJumpPower(value)
    updateCharacterReferences()
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = value
    end
end

speedInput.FocusLost:Connect(function()
    local newSpeed = tonumber(speedInput.Text) or 24
    newSpeed = math.clamp(newSpeed, 0, 200)
    speedInput.Text = tostring(newSpeed)
    setSpeed(newSpeed)
    tweenSpeed = newSpeed
end)

jumpInput.FocusLost:Connect(function()
    local newJump = tonumber(jumpInput.Text) or 50
    newJump = math.clamp(newJump, 0, 1000)
    jumpInput.Text = tostring(newJump)
    setJumpPower(newJump)
end)

-- Initialize default values
setJumpPower(50)
setSpeed(24)

-- Clean up everything when script ends
gui.Destroying:Connect(function()
    stopTweenToBase()
    
    if guidedConn then
        guidedConn:Disconnect()
    end
    
    if floatConnection then
        floatConnection:Disconnect()
    end
    if floatBodyVelocity then
        floatBodyVelocity:Destroy()
    end
    
    if floorConnection then
        floorConnection:Disconnect()
    end
    if floorPart then
        floorPart:Destroy()
    end
    
    if isInvisible then
        semiInvisibleFunction()
    end
    
    if autoLazerEnabled then
        toggleAutoLazer()
    end
    
    if espEnabled then
        toggleESP()
    end
end)

print("Enhanced Krypton Hub loaded successfully!")
print("Discord: https://discord.gg/YSwFZsGk9j")
