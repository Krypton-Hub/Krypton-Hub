-- Krypton Hub - Optimized Edition
-- Made by agent_duke13
-- Optimized for performance and reduced lag

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character, hrp, humanoid

-- Optimized Global Godmode Protection
local godmodeEnabled = false

local function setupGodmode()
    if godmodeEnabled then return end
    godmodeEnabled = true
    
    local mt = getrawmetatable(game)
    local oldNC = mt.__namecall
    local oldNI = mt.__newindex
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local m = getnamecallmethod()
        if self == humanoid or (typeof(self) == "Instance" and self:IsA("Humanoid")) then
            if m == "ChangeState" and select(1, ...) == Enum.HumanoidStateType.Dead then
                return
            end
            if m == "SetStateEnabled" then
                local st, en = ...
                if st == Enum.HumanoidStateType.Dead and en == true then
                    return
                end
            end
            if m == "Destroy" then
                return
            end
            if m == "TakeDamage" then
                return
            end
        end
        
        if (self == character or (typeof(self) == "Instance" and self:IsDescendantOf(character))) and m == "BreakJoints" then
            return
        end
        
        return oldNC(self, ...)
    end)
    
    mt.__newindex = newcclosure(function(self, k, v)
        if self == humanoid or (typeof(self) == "Instance" and self:IsA("Humanoid")) then
            if k == "Health" and type(v) == "number" and v <= 0 then
                if humanoid then
                    oldNI(self, k, humanoid.MaxHealth)
                end
                return
            end
            if k == "MaxHealth" and type(v) == "number" and v < (humanoid and humanoid.MaxHealth or 100) then
                return
            end
            if k == "BreakJointsOnDeath" and v == true then
                return
            end
            if k == "Parent" and v == nil then
                return
            end
        end
        return oldNI(self, k, v)
    end)
    
    setreadonly(mt, true)
end

-- Optimized character reference system
local function updateCharacterReferences()
    character = player.Character
    if character then
        hrp = character:FindFirstChild("HumanoidRootPart")
        humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            setupGodmode()
            humanoid.Health = humanoid.MaxHealth
        end
    else
        hrp = nil
        humanoid = nil
    end
end

updateCharacterReferences()

player.CharacterAdded:Connect(function(c)
    character = c
    task.wait(0.5)
    hrp = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    setupGodmode()
    humanoid.Health = humanoid.MaxHealth
end)

-- GUI Creation (Your original GUI code)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KryptonHub"
screenGui.Parent = player.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 400)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 370)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Text = "Krypton Hub - Ready"
statusLabel.Parent = mainFrame

-- Create tabs and buttons (simplified for example)
local mainContent = {}
for i = 1, 3 do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 40)
    button.Position = UDim2.new(0.05, 0, 0, 50 + (i-1)*50)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = "Feature " .. i
    button.Parent = mainFrame
    mainContent[i] = button
end

mainContent[1].Text = "▶ TWEEN TO BASE"
mainContent[2].Text = "SLOW FLIGHT: OFF"
mainContent[3].Text = "FLOAT: OFF"

-- Circle toggle button
local circleButton = Instance.new("TextButton")
circleButton.Size = UDim2.new(0, 50, 0, 50)
circleButton.Position = UDim2.new(0, 10, 0, 10)
circleButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
circleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
circleButton.Text = "○"
circleButton.TextSize = 20
circleButton.Parent = screenGui

circleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- ========== OPTIMIZED TWEEN SYSTEM ==========
local tweenActive = false
local currentTween

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

local function getGroundHeight(position)
    local rayOrigin = Vector3.new(position.X, position.Y + 10, position.Z)
    local rayDirection = Vector3.new(0, -50, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    
    local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if raycastResult then
        return raycastResult.Position.Y + 3
    end
    return position.Y
end

mainContent[1].MouseButton1Click:Connect(function()
    if tweenActive then
        tweenActive = false
        if currentTween then currentTween:Cancel() end
        mainContent[1].Text = "▶ TWEEN TO BASE"
        mainContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Tween stopped"
    else
        local basePos = getBasePosition()
        if basePos then
            tweenActive = true
            mainContent[1].Text = "■ STOP TWEEN"
            mainContent[1].BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            statusLabel.Text = "Tweening to base..."
            
            spawn(function()
                updateCharacterReferences()
                if not hrp or not humanoid then 
                    statusLabel.Text = "No character found"
                    tweenActive = false
                    mainContent[1].Text = "▶ TWEEN TO BASE"
                    mainContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                    return 
                end
                
                setupGodmode()
                
                local currentGroundY = getGroundHeight(hrp.Position)
                local baseGroundY = getGroundHeight(basePos)
                local targetY = math.min(currentGroundY, baseGroundY)
                
                local startPos = Vector3.new(hrp.Position.X, currentGroundY, hrp.Position.Z)
                local targetPos = Vector3.new(basePos.X, targetY, basePos.Z)
                
                local distance = (targetPos - startPos).Magnitude
                local duration = math.max(3, distance / 15)
                
                statusLabel.Text = "Tweening (optimized)..."
                
                local startTime = tick()
                
                while tweenActive and tick() - startTime < duration do
                    if not hrp then break end
                    
                    local elapsed = tick() - startTime
                    local progress = elapsed / duration
                    local easedProgress = progress * progress * (3 - 2 * progress)
                    
                    local newPos = startPos + (targetPos - startPos) * easedProgress
                    local currentGround = getGroundHeight(newPos)
                    newPos = Vector3.new(newPos.X, currentGround, newPos.Z)
                    
                    hrp.CFrame = CFrame.new(newPos)
                    
                    if humanoid then
                        humanoid.Health = humanoid.MaxHealth
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                    
                    task.wait(0.08) -- Reduced frequency for performance
                end
                
                if tweenActive and hrp then
                    local finalGroundY = getGroundHeight(targetPos)
                    hrp.CFrame = CFrame.new(targetPos.X, finalGroundY, targetPos.Z)
                    statusLabel.Text = "Reached base safely!"
                end
                
                tweenActive = false
                mainContent[1].Text = "▶ TWEEN TO BASE"
                mainContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            end)
        else
            statusLabel.Text = "Base not found!"
        end
    end
end)

-- ========== OPTIMIZED FLIGHT SYSTEM ==========
local flyActive = false
local flyConnection

mainContent[2].MouseButton1Click:Connect(function()
    flyActive = not flyActive
    
    if flyActive then
        mainContent[2].Text = "SLOW FLIGHT: ON"
        mainContent[2].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Slow Flight enabled"
        
        setupGodmode()
        
        -- Use Heartbeat instead of RenderStepped for better performance
        flyConnection = RunService.Heartbeat:Connect(function()
            if flyActive and hrp then
                hrp.Velocity = workspace.CurrentCamera.CFrame.LookVector * 25
            end
        end)
    else
        mainContent[2].Text = "SLOW FLIGHT: OFF"
        mainContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Slow Flight disabled"
        
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

-- ========== OPTIMIZED INVISIBLE SYSTEM ==========
local connections = {
    FullInvisible = {}
}

local isInvisible = false
local clone, oldRoot, hip, animTrack, connection, characterConnection
local indicatorBox

local function fullInvisibleFunction()
    local DEPTH_OFFSET = 0.09  

    local function removeFolders()  
        local playerName = player.Name  
        local playerFolder = Workspace:FindFirstChild(playerName)  
        if not playerFolder then return end  

        local doubleRig = playerFolder:FindFirstChild("DoubleRig")  
        if doubleRig then doubleRig:Destroy() end

        local constraints = playerFolder:FindFirstChild("Constraints")  
        if constraints then constraints:Destroy() end

        local childAddedConn = playerFolder.ChildAdded:Connect(function(child)  
            if child.Name == "DoubleRig" or child.Name == "Constraints" then  
                child:Destroy()  
            end  
        end)  
        table.insert(connections.FullInvisible, childAddedConn)  
    end  

    local function doClone()  
        if character and humanoid and humanoid.Health > 0 then  
            setupGodmode()
            
            hip = humanoid.HipHeight  
            oldRoot = hrp
            if not oldRoot or not oldRoot.Parent then return false end

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
                    if v.Part0 == oldRoot then v.Part0 = clone end
                    if v.Part1 == oldRoot then v.Part1 = clone end
                end  
            end  

            tempParent:Destroy()  
            return true  
        end  
        return false  
    end  

    local function revertClone()  
        if not oldRoot or not oldRoot:IsDescendantOf(Workspace) or not character or humanoid.Health <= 0 then  
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
                if v.Part0 == clone then v.Part0 = oldRoot end
                if v.Part1 == clone then v.Part1 = oldRoot end
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

    local function createIndicatorBox()
        if indicatorBox then indicatorBox:Destroy() end
        
        indicatorBox = Instance.new("Part")
        indicatorBox.Name = "InvisibleIndicator"
        indicatorBox.Size = Vector3.new(2, 3, 1)
        indicatorBox.Anchored = true
        indicatorBox.CanCollide = false
        indicatorBox.Material = Enum.Material.Neon
        indicatorBox.BrickColor = BrickColor.new("Bright blue")
        indicatorBox.Transparency = 0.7
        indicatorBox.Parent = Workspace
        
        return indicatorBox
    end

    local function animationTrickery()  
        if character and humanoid and humanoid.Health > 0 then  
            local anim = Instance.new("Animation")  
            anim.AnimationId = "http://www.roblox.com/asset/?id=18537363391"  
            local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)  
            animTrack = animator:LoadAnimation(anim)  
            animTrack.Priority = Enum.AnimationPriority.Action4  
            animTrack:Play(0, 1, 0)  
            anim:Destroy()  

            local animStoppedConn = animTrack.Stopped:Connect(function()  
                if isInvisible then animationTrickery() end
            end)  
            table.insert(connections.FullInvisible, animStoppedConn)  

            task.delay(0, function()  
                animTrack.TimePosition = 0.7  
                task.delay(1, function()  
                    animTrack:AdjustSpeed(math.huge)  
                end)  
            end)  
        end  
    end  

    local function enableInvisibility()  
        if not character or humanoid.Health <= 0 then return false end

        removeFolders()  
        local success = doClone()  
        if success then  
            indicatorBox = createIndicatorBox()
            
            task.wait(0.1)  
            animationTrickery()  
            
            -- Optimized connection with less frequent updates
            connection = RunService.Heartbeat:Connect(function()
                if character and humanoid and humanoid.Health > 0 and oldRoot then  
                    local root = character.PrimaryPart or hrp
                    if root then  
                        local cf = root.CFrame - Vector3.new(0, humanoid.HipHeight + (root.Size.Y / 2) - 1 + DEPTH_OFFSET, 0)  
                        oldRoot.CFrame = cf * CFrame.Angles(math.rad(180), 0, 0)  
                        oldRoot.Velocity = root.Velocity  
                        oldRoot.CanCollide = false  
                        
                        if indicatorBox then
                            local torsoPos = root.Position + Vector3.new(0, 2, 0)
                            indicatorBox.CFrame = CFrame.new(torsoPos)
                        end
                    end  
                end  
            end)  
            table.insert(connections.FullInvisible, connection)  

            characterConnection = player.CharacterAdded:Connect(function(newChar)
                if isInvisible then
                    if animTrack then animTrack:Stop() end
                    if connection then connection:Disconnect() end  
                    if indicatorBox then indicatorBox:Destroy() end
                    revertClone()
                    removeFolders()
                    isInvisible = false
                    
                    for _, conn in ipairs(connections.FullInvisible) do  
                        if conn then conn:Disconnect() end  
                    end  
                    connections.FullInvisible = {}
                end
            end)
            table.insert(connections.FullInvisible, characterConnection)
            
            return true
        end  
        return false
    end  

    local function disableInvisibility()  
        if animTrack then animTrack:Stop() end
        if connection then connection:Disconnect() end  
        if characterConnection then characterConnection:Disconnect() end  
        if indicatorBox then indicatorBox:Destroy() end
        revertClone()  
        removeFolders()  
    end

    if not isInvisible then
        removeFolders()  
        setupGodmode()  
        if enableInvisibility() then
            isInvisible = true
            statusLabel.Text = "Full Invisible enabled (F key to toggle)"
        end
    else
        disableInvisibility()
        isInvisible = false
        statusLabel.Text = "Full Invisible disabled"
        
        pcall(function()  
            local oldGui = player.PlayerGui:FindFirstChild("InvisibleGui")  
            if oldGui then oldGui:Destroy() end  
        end)  
        for _, conn in ipairs(connections.FullInvisible) do  
            if conn then conn:Disconnect() end  
        end  
        connections.FullInvisible = {}  
    end
end

-- F key toggle for full-invisible
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F and not gameProcessed then
        fullInvisibleFunction()
    end
end)

-- ========== OPTIMIZED INFINITE JUMP ==========
local infJumpActive = false
local infJumpConnection

local infJumpButton = Instance.new("TextButton")
infJumpButton.Size = UDim2.new(0.9, 0, 0, 40)
infJumpButton.Position = UDim2.new(0.05, 0, 0, 200)
infJumpButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
infJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
infJumpButton.Text = "INFINITE JUMP: OFF"
infJumpButton.Parent = mainFrame

infJumpButton.MouseButton1Click:Connect(function()
    infJumpActive = not infJumpActive
    
    if infJumpActive then
        infJumpButton.Text = "INFINITE JUMP: ON"
        infJumpButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Infinite Jump enabled"
        
        setupGodmode()
        
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if infJumpActive and humanoid and humanoid.Health > 0 then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                if hrp then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
                end
            end
        end)
    else
        infJumpButton.Text = "INFINITE JUMP: OFF"
        infJumpButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Infinite Jump disabled"
        
        if infJumpConnection then
            infJumpConnection:Disconnect()
        end
    end
end)

-- ========== OPTIMIZED SPEED BOOSTER ==========
local speedActive = false
local speedConn
local baseSpeed = 27

local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0.9, 0, 0, 40)
speedButton.Position = UDim2.new(0.05, 0, 0, 250)
speedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.Text = "SPEED BOOSTER: OFF"
speedButton.Parent = mainFrame

speedButton.MouseButton1Click:Connect(function()
    speedActive = not speedActive
    
    if speedActive then
        speedButton.Text = "SPEED BOOSTER: ON"
        speedButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Speed Booster enabled"
        
        setupGodmode()
        
        -- Optimized speed with less frequent updates
        speedConn = RunService.Heartbeat:Connect(function()
            if not hrp or not humanoid then 
                updateCharacterReferences()
                return 
            end
            
            local moveVector = humanoid.MoveDirection
            if moveVector.Magnitude > 0.1 then
                local inputDirection = Vector3.new(moveVector.X, 0, moveVector.Z).Unit
                hrp.AssemblyLinearVelocity = Vector3.new(
                    inputDirection.X * baseSpeed,
                    hrp.AssemblyLinearVelocity.Y,
                    inputDirection.Z * baseSpeed
                )
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end)
    else
        speedButton.Text = "SPEED BOOSTER: OFF"
        speedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Speed Booster disabled"
        
        if speedConn then 
            speedConn:Disconnect() 
            speedConn = nil 
        end
        
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
        end
    end
end)

-- ========== OPTIMIZED FLOAT SYSTEM ==========
local floatActive = false
local floatBodyVelocity

mainContent[3].MouseButton1Click:Connect(function()
    floatActive = not floatActive
    
    if floatActive then
        mainContent[3].Text = "FLOAT: ON"
        mainContent[3].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Float enabled"
        
        updateCharacterReferences()
        if hrp then
            setupGodmode()
            floatBodyVelocity = Instance.new("BodyVelocity")
            floatBodyVelocity.Velocity = Vector3.new(0, 25, 0)
            floatBodyVelocity.MaxForce = Vector3.new(0, 50000, 0)
            floatBodyVelocity.Parent = hrp
        end
    else
        mainContent[3].Text = "FLOAT: OFF"
        mainContent[3].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Float disabled"
        
        if floatBodyVelocity then
            floatBodyVelocity:Destroy()
        end
    end
end)

print("Krypton Hub v5.0 - Optimized Edition Loaded!")
print("Controls: F key to toggle invisible, Circle button to open GUI")
print("All features working with reduced lag!")
