-- Krypton Hub - Made By agent_duke13 - Complete Version

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

-- Create toggle button first
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "KryptonToggle"
toggleGui.ResetOnSpawn = false
toggleGui.Parent = player:WaitForChild("PlayerGui")

local toggleButton = Instance.new("ImageButton")
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 20, 0.5, -30)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.BackgroundTransparency = 0.3
toggleButton.Image = "rbxassetid://95131705390407" -- Your image ID
toggleButton.Active = true
toggleButton.Draggable = true
toggleButton.Parent = toggleGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = toggleButton

-- Create main GUI
local gui = Instance.new("ScreenGui")
gui.Name = "KryptonHubGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
gui.Enabled = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 400)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = "Krypton Hub"
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.ZIndex = 2
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- Tab buttons
local tabs = {"Main", "Steal", "Visuals", "Combat"}
local currentTab = "Main"

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 30)
tabContainer.Position = UDim2.new(0, 0, 0, 25)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local tabButtons = {}
for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Text = tabName
    tabButton.Size = UDim2.new(1/#tabs, 0, 1, 0)
    tabButton.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 11
    tabButton.ZIndex = 2
    tabButton.Parent = tabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 4)
    tabCorner.Parent = tabButton
    
    tabButtons[tabName] = tabButton
end

-- Content frame
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -75)
contentFrame.Position = UDim2.new(0, 0, 0, 55)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Status: Ready"
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 1, -20)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.Parent = mainFrame

-- Main Tab Content
local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1, 0, 1, 0)
mainContent.BackgroundTransparency = 1
mainContent.Visible = true
mainContent.Parent = contentFrame

-- ========== TWEEN TO BASE SYSTEM ==========
local tweenButton = Instance.new("TextButton")
tweenButton.Text = "▶ TWEEN TO BASE"
tweenButton.Size = UDim2.new(0.9, 0, 0, 25)
tweenButton.Position = UDim2.new(0.05, 0, 0.05, 0)
tweenButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tweenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tweenButton.Font = Enum.Font.GothamBold
tweenButton.TextSize = 12
tweenButton.Parent = mainContent

local tweenCorner = Instance.new("UICorner")
tweenCorner.CornerRadius = UDim.new(0, 6)
tweenCorner.Parent = tweenButton

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
    
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    
    tweenButton.Text = "▶ TWEEN TO BASE"
    tweenButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    statusLabel.Text = "Ready"
end

-- Speed
local speedContainer = Instance.new("Frame")
speedContainer.Size = UDim2.new(0.9, 0, 0, 25)
speedContainer.Position = UDim2.new(0.05, 0, 0.15, 0)
speedContainer.BackgroundTransparency = 1
speedContainer.Parent = mainContent

local speedLabel = Instance.new("TextLabel")
speedLabel.Text = "Speed:"
speedLabel.Size = UDim2.new(0.5, 0, 1, 0)
speedLabel.Position = UDim2.new(0, 0, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 11
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedContainer

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.4, 0, 1, 0)
speedInput.Position = UDim2.new(0.6, 0, 0, 0)
speedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.Gotham
speedInput.TextSize = 11
speedInput.Text = "24"
speedInput.Parent = speedContainer

local speedInputCorner = Instance.new("UICorner")
speedInputCorner.CornerRadius = UDim.new(0, 4)
speedInputCorner.Parent = speedInput

-- Jump Power
local jumpContainer = Instance.new("Frame")
jumpContainer.Size = UDim2.new(0.9, 0, 0, 25)
jumpContainer.Position = UDim2.new(0.05, 0, 0.25, 0)
jumpContainer.BackgroundTransparency = 1
jumpContainer.Parent = mainContent

local jumpLabel = Instance.new("TextLabel")
jumpLabel.Text = "Jump Power:"
jumpLabel.Size = UDim2.new(0.5, 0, 1, 0)
jumpLabel.Position = UDim2.new(0, 0, 0, 0)
jumpLabel.BackgroundTransparency = 1
jumpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextSize = 11
jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpLabel.Parent = jumpContainer

local jumpInput = Instance.new("TextBox")
jumpInput.Size = UDim2.new(0.4, 0, 1, 0)
jumpInput.Position = UDim2.new(0.6, 0, 0, 0)
jumpInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
jumpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpInput.Font = Enum.Font.Gotham
jumpInput.TextSize = 11
jumpInput.Text = "50"
jumpInput.Parent = jumpContainer

local jumpInputCorner = Instance.new("UICorner")
jumpInputCorner.CornerRadius = UDim.new(0, 4)
jumpInputCorner.Parent = jumpInput

-- ========== NEW FLIGHT SYSTEM ==========
local flyButton = Instance.new("TextButton")
flyButton.Text = "SLOW FLIGHT: OFF"
flyButton.Size = UDim2.new(0.9, 0, 0, 25)
flyButton.Position = UDim2.new(0.05, 0, 0.35, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Font = Enum.Font.GothamBold
flyButton.TextSize = 12
flyButton.Parent = mainContent

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 6)
flyCorner.Parent = flyButton

local guidedOn = false
local guidedConn

local function toggleFlight()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    guidedOn = not guidedOn
    flyButton.Text = guidedOn and "SLOW FLIGHT: ON" or "SLOW FLIGHT: OFF"
    flyButton.BackgroundColor3 = guidedOn and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
    
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

-- ========== FLOAT SYSTEM ==========
local floatButton = Instance.new("TextButton")
floatButton.Text = "FLOAT: OFF"
floatButton.Size = UDim2.new(0.9, 0, 0, 25)
floatButton.Position = UDim2.new(0.05, 0, 0.45, 0)
floatButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
floatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
floatButton.Font = Enum.Font.GothamBold
floatButton.TextSize = 12
floatButton.Parent = mainContent

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(0, 6)
floatCorner.Parent = floatButton

local floatEnabled = false
local floatBodyVelocity
local floatConnection

local function toggleFloat()
    floatEnabled = not floatEnabled
    
    if floatEnabled then
        floatButton.Text = "FLOAT: ON"
        floatButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
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
        floatButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
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

-- ========== AUTO FLOOR SYSTEM ==========
local autoFloorButton = Instance.new("TextButton")
autoFloorButton.Text = "AUTO FLOOR: OFF"
autoFloorButton.Size = UDim2.new(0.9, 0, 0, 25)
autoFloorButton.Position = UDim2.new(0.05, 0, 0.55, 0)
autoFloorButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoFloorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFloorButton.Font = Enum.Font.GothamBold
autoFloorButton.TextSize = 12
autoFloorButton.Parent = mainContent

local autoFloorCorner = Instance.new("UICorner")
autoFloorCorner.CornerRadius = UDim.new(0, 6)
autoFloorCorner.Parent = autoFloorButton

local floorOn = false
local floorPart
local floorConnection
local floorRiseSpeed = 5.0
local autoFloorSize = Vector3.new(8, 1, 8)

local function toggleAutoFloor()
    floorOn = not floorOn
    
    if floorOn then
        autoFloorButton.Text = "AUTO FLOOR: ON"
        autoFloorButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
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

-- ========== SEMI INVISIBLE SYSTEM ==========
local semiInvisButton = Instance.new("TextButton")
semiInvisButton.Text = "SEMI INVISIBLE: OFF"
semiInvisButton.Size = UDim2.new(0.9, 0, 0, 25)
semiInvisButton.Position = UDim2.new(0.05, 0, 0.65, 0)
semiInvisButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
semiInvisButton.TextColor3 = Color3.fromRGB(255, 255, 255)
semiInvisButton.Font = Enum.Font.GothamBold
semiInvisButton.TextSize = 12
semiInvisButton.Parent = mainContent

local semiInvisCorner = Instance.new("UICorner")
semiInvisCorner.CornerRadius = UDim.new(0, 6)
semiInvisCorner.Parent = semiInvisButton

local connections = {
    SemiInvisible = {}
}

local isInvisible = false
local clone, oldRoot, hip, animTrack, connection, characterConnection

local function semiInvisibleFunction()
    local DEPTH_OFFSET = 0.10  

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
                        local cf = root.CFrame - Vector3.new(0, humanoid.HipHeight + (root.Size.Y / 2) - 1 + DEPTH_OFFSET, 0)  
                        oldRoot.CFrame = cf * CFrame.Angles(math.rad(180), 0, 0)  
                        oldRoot.Velocity = root.Velocity  
                        oldRoot.CanCollide = false  
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
                    semiInvisButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    
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
            semiInvisButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            statusLabel.Text = "Semi Invisible enabled"
        else
            statusLabel.Text = "Failed to enable Semi Invisible"
        end
    else
        disableInvisibility()
        isInvisible = false
        semiInvisButton.Text = "SEMI INVISIBLE: OFF"
        semiInvisButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
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
local secondFloorButton = Instance.new("TextButton")
secondFloorButton.Text = "2ND FLOOR STEAL"
secondFloorButton.Size = UDim2.new(0.9, 0, 0, 30)
secondFloorButton.Position = UDim2.new(0.05, 0, 0.05, 0)
secondFloorButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
secondFloorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
secondFloorButton.Font = Enum.Font.GothamBold
secondFloorButton.TextSize = 12
secondFloorButton.Parent = stealContent

local secondFloorCorner = Instance.new("UICorner")
secondFloorCorner.CornerRadius = UDim.new(0, 6)
secondFloorCorner.Parent = secondFloorButton

-- 3rd Floor Steal
local thirdFloorButton = Instance.new("TextButton")
thirdFloorButton.Text = "3RD FLOOR STEAL"
thirdFloorButton.Size = UDim2.new(0.9, 0, 0, 30)
thirdFloorButton.Position = UDim2.new(0.05, 0, 0.15, 0)
thirdFloorButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
thirdFloorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
thirdFloorButton.Font = Enum.Font.GothamBold
thirdFloorButton.TextSize = 12
thirdFloorButton.Parent = stealContent

local thirdFloorCorner = Instance.new("UICorner")
thirdFloorCorner.CornerRadius = UDim.new(0, 6)
thirdFloorCorner.Parent = thirdFloorButton

-- Desync Anti-Hit
local desyncButton = Instance.new("TextButton")
desyncButton.Text = "DESYNC (ANTI HIT): OFF"
desyncButton.Size = UDim2.new(0.9, 0, 0, 30)
desyncButton.Position = UDim2.new(0.05, 0, 0.25, 0)
desyncButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
desyncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
desyncButton.Font = Enum.Font.GothamBold
desyncButton.TextSize = 12
desyncButton.Parent = stealContent

local desyncCorner = Instance.new("UICorner")
desyncCorner.CornerRadius = UDim.new(0, 6)
desyncCorner.Parent = desyncButton

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
            desyncButton.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
            desyncButton.Text = "DESYNC (ANTI HIT): ON"
        else
            desyncActive=false
            desyncButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
            desyncButton.Text = "DESYNC (ANTI HIT): OFF"
        end
    else
        disableMobileDesync()
        desyncButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
        desyncButton.Text = "DESYNC (ANTI HIT): OFF"
    end
end)

player.CharacterAdded:Connect(function()
    desyncActive=false
    desyncButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
    desyncButton.Text = "DESYNC (ANTI HIT): OFF"
end)

-- ========== 3RD FLOOR STEAL SYSTEM ==========
local floorOn = false
local floorPart
local floorConnection

local function setTransparencySpecific(part, transparency)
    if part and part:IsA("BasePart") then
        if not part:GetAttribute("OriginalTransparency") then
            part:SetAttribute("OriginalTransparency", part.Transparency)
        end
        if not part:GetAttribute("OriginalCanCollide") then
            part:SetAttribute("OriginalCanCollide", part.CanCollide)
        end
        part.Transparency = transparency
        part.CanCollide = false
    end
end

local function processAnimalPodium(podium, podiumNumber, plotName)
    local claim = podium:FindFirstChild("Claim")
    if claim then
        local hitbox = claim:FindFirstChild("Hitbox")
        if hitbox then
            pcall(function()
                if not hitbox:GetAttribute("OriginalTransparency") then
                    hitbox:SetAttribute("OriginalTransparency", hitbox.Transparency)
                    hitbox:SetAttribute("OriginalCanCollide", hitbox.CanCollide)
                end
                hitbox.Transparency = 0.5
                hitbox.CanCollide = false
                if hitbox:FindFirstChild("SelectionBox") then hitbox.SelectionBox:Destroy() end
                if hitbox:FindFirstChild("SurfaceGui") then hitbox.SurfaceGui.Enabled=false end
                if hitbox:FindFirstChild("BillboardGui") then hitbox.BillboardGui.Enabled=false end
                for _, script in pairs(hitbox:GetChildren()) do
                    if script:IsA("LocalScript") or script:IsA("Script") then
                        script.Disabled=true
                    end
                end
            end)
        end
    end
    local base = podium:FindFirstChild("Base")
    if base then
        local spawn = base:FindFirstChild("Spawn")
        setTransparencySpecific(spawn,0.5)
        local decorations = base:FindFirstChild("Decorations")
        if decorations then
            local decoration = decorations:FindFirstChild("Decoration")
            setTransparencySpecific(decoration,0.5)
            local part = decorations:FindFirstChild("Part")
            setTransparencySpecific(part,0.5)
            for _, child in pairs(decorations:GetChildren()) do
                if child:IsA("BasePart") and child.Name~="Decoration" and child.Name~="Part" then
                    setTransparencySpecific(child,0.5)
                end
            end
        end
    end
end

local function destroyPlatform()
    if floorPart then floorPart:Destroy() floorPart=nil end
    floorOn=false
    if floorConnection then floorConnection:Disconnect() floorConnection=nil end
    thirdFloorButton.BackgroundColor3 = Color3.fromRGB(220,20,60)
    thirdFloorButton.Text = "3RD FLOOR STEAL"
end

local function canRise()
    if not floorPart then return false end
    local origin = floorPart.Position + Vector3.new(0, floorPart.Size.Y/2,0)
    local direction = Vector3.new(0,2,0)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {floorPart, player.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    return not Workspace:Raycast(origin,direction,rayParams)
end

local function setup3rdFloor()
    updateCharacterReferences()
    if not character then return end
    
    local root = character:WaitForChild("HumanoidRootPart")
    
    thirdFloorButton.MouseButton1Click:Connect(function()
        floorOn = not floorOn
        if floorOn then
            floorPart = Instance.new("Part")
            floorPart.Size = Vector3.new(6,0.5,6)
            floorPart.Anchored=true
            floorPart.CanCollide=true
            floorPart.Transparency=0
            floorPart.Material=Enum.Material.Plastic
            floorPart.Color=Color3.fromRGB(255,200,0)
            floorPart.Position=root.Position-Vector3.new(0, root.Size.Y/2 + floorPart.Size.Y/2, 0)
            floorPart.Parent = Workspace

            local plots = Workspace:FindFirstChild("Plots")
            if plots then
                for _, plot in pairs(plots:GetChildren()) do
                    for _, part in pairs(plot:GetDescendants()) do
                        if part:IsA("BasePart") and (part.Name:lower():find("base plot") or part.Name:lower():find("base") or part.Name:lower():find("plot")) then
                            part.Transparency = 0.5
                        end
                    end
                    local animalPodiums = plot:FindFirstChild("AnimalPodiums")
                    if animalPodiums then
                        for _, podium in pairs(animalPodiums:GetChildren()) do
                            if podium:IsA("Model") or podium:IsA("Folder") then
                                processAnimalPodium(podium, podium.Name, plot.Name)
                            end
                        end
                    end
                end
            end

            floorConnection = RunService.Heartbeat:Connect(function(dt)
                if floorPart and floorOn then
                    local cur = floorPart.Position
                    local newXZ = Vector3.new(root.Position.X, cur.Y, root.Position.Z)
                    if canRise() then
                        floorPart.Position = newXZ + Vector3.new(0, dt*15,0)
                    else
                        floorPart.Position=newXZ
                    end
                end
            end)
            thirdFloorButton.BackgroundColor3=Color3.fromRGB(0,170,0)
            thirdFloorButton.Text = "3RD FLOOR STEAL: ON"
        else
            destroyPlatform()
        end
    end)

    character:WaitForChild("Humanoid").Died:Connect(destroyPlatform)
end

if player.Character then setup3rdFloor() end
player.CharacterAdded:Connect(setup3rdFloor)

-- 2nd Floor Steal (placeholder - add your specific functionality)
secondFloorButton.MouseButton1Click:Connect(function()
    statusLabel.Text = "2nd Floor Steal activated"
    -- Add your 2nd floor steal logic here
end)

-- ========== VISUALS TAB CONTENT ==========
local visualsContent = Instance.new("Frame")
visualsContent.Size = UDim2.new(1, 0, 1, 0)
visualsContent.BackgroundTransparency = 1
visualsContent.Visible = false
visualsContent.Parent = contentFrame

-- Player ESP
local espButton = Instance.new("TextButton")
espButton.Text = "PLAYER ESP: OFF"
espButton.Size = UDim2.new(0.9, 0, 0, 30)
espButton.Position = UDim2.new(0.05, 0, 0.05, 0)
espButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.Font = Enum.Font.GothamBold
espButton.TextSize = 12
espButton.Parent = visualsContent

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 6)
espCorner.Parent = espButton

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
    espButton.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
    
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
local autoLazerButton = Instance.new("TextButton")
autoLazerButton.Text = "AUTO LAZER: OFF"
autoLazerButton.Size = UDim2.new(0.9, 0, 0, 30)
autoLazerButton.Position = UDim2.new(0.05, 0, 0.05, 0)
autoLazerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoLazerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoLazerButton.Font = Enum.Font.GothamBold
autoLazerButton.TextSize = 12
autoLazerButton.Parent = combatContent

local autoLazerCorner = Instance.new("UICorner")
autoLazerCorner.CornerRadius = UDim.new(0, 6)
autoLazerCorner.Parent = autoLazerButton

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
    autoLazerButton.BackgroundColor3 = autoLazerEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
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

-- ========== DISCORD BUTTON ==========
local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0.9, 0, 0, 25)
discordBtn.Position = UDim2.new(0.05, 0, 0.85, 0)
discordBtn.Text = "Discord"
discordBtn.Font = Enum.Font.GothamBold
discordBtn.TextSize = 12
discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBtn.AutoButtonColor = false
discordBtn.Parent = contentFrame

local discordCorner = Instance.new("UICorner")
discordCorner.CornerRadius = UDim.new(0, 6)
discordCorner.Parent = discordBtn

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

-- ========== BUTTON CONNECTIONS ==========
tweenButton.MouseButton1Click:Connect(function()
    if active then
        stopTweenToBase()
    else
        startTweenToBase()
    end
end)

flyButton.MouseButton1Click:Connect(toggleFlight)
floatButton.MouseButton1Click:Connect(toggleFloat)
autoFloorButton.MouseButton1Click:Connect(toggleAutoFloor)
semiInvisButton.MouseButton1Click:Connect(semiInvisibleFunction)
espButton.MouseButton1Click:Connect(toggleESP)
autoLazerButton.MouseButton1Click:Connect(toggleAutoLazer)

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

print("Krypton Hub loaded successfully!")
print("Discord: https://discord.gg/YSwFZsGk9j")
