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

-- Global states
local active = false
local floatEnabled = false
local autoLazerEnabled = false
local floorOn = false
local autoStealEnabled = false
local isInvisible = false

-- Connections storage
local connections = {
    Float = {},
    AutoFloor = {},
    AutoLazer = {},
    AutoSteal = {},
    SemiInvisible = {},
    Tween = {}
}

player.CharacterAdded:Connect(function(c)
    character = c
    hrp = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    
    -- Re-enable features if they were active
    if active then
        stopTweenToBase()
        startTweenToBase()
    end
    if floatEnabled then
        toggleFloat()
        toggleFloat()
    end
    if autoStealEnabled then
        toggleAutoSteal()
        toggleAutoSteal()
    end
end)

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "RxyalsScriptsGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 180, 0, 340)
frame.Position = UDim2.new(0.5, -90, 0.5, -170)
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

-- Speed input
local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Text = "Speed:"
speedLabel.Size = UDim2.new(0.8, 0, 0, 16)
speedLabel.Position = UDim2.new(0.1, 0, 0.20, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 10
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedInput = Instance.new("TextBox", frame)
speedInput.Size = UDim2.new(0.3, 0, 0, 16)
speedInput.Position = UDim2.new(0.65, 0, 0.20, 0)
speedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.Gotham
speedInput.TextSize = 12
speedInput.Text = "35"
speedInput.PlaceholderText = "Speed"
Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 4)

-- Jump Power input
local jumpLabel = Instance.new("TextLabel", frame)
jumpLabel.Text = "Jump Power:"
jumpLabel.Size = UDim2.new(0.8, 0, 0, 16)
jumpLabel.Position = UDim2.new(0.1, 0, 0.28, 0)
jumpLabel.BackgroundTransparency = 1
jumpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextSize = 10
jumpLabel.TextXAlignment = Enum.TextXAlignment.Left

local jumpInput = Instance.new("TextBox", frame)
jumpInput.Size = UDim2.new(0.3, 0, 0, 16)
jumpInput.Position = UDim2.new(0.65, 0, 0.28, 0)
jumpInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
jumpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpInput.Font = Enum.Font.Gotham
jumpInput.TextSize = 12
jumpInput.Text = "50"
jumpInput.PlaceholderText = "Jump"
Instance.new("UICorner", jumpInput).CornerRadius = UDim.new(0, 4)

-- Float button
local floatButton = Instance.new("TextButton", frame)
floatButton.Text = "FLOAT: OFF"
floatButton.Size = UDim2.new(0.8, 0, 0, 25)
floatButton.Position = UDim2.new(0.1, 0, 0.38, 0)
floatButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
floatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
floatButton.Font = Enum.Font.GothamBold
floatButton.TextSize = 14
floatButton.ZIndex = 2
Instance.new("UICorner", floatButton).CornerRadius = UDim.new(0, 6)

-- Auto Floor button
local autoFloorButton = Instance.new("TextButton", frame)
autoFloorButton.Text = "AUTO FLOOR: OFF"
autoFloorButton.Size = UDim2.new(0.8, 0, 0, 25)
autoFloorButton.Position = UDim2.new(0.1, 0, 0.50, 0)
autoFloorButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
autoFloorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFloorButton.Font = Enum.Font.GothamBold
autoFloorButton.TextSize = 14
autoFloorButton.ZIndex = 2
Instance.new("UICorner", autoFloorButton).CornerRadius = UDim.new(0, 6)

-- Auto Lazer button
local autoLazerButton = Instance.new("TextButton", frame)
autoLazerButton.Text = "AUTO LAZER: OFF"
autoLazerButton.Size = UDim2.new(0.8, 0, 0, 25)
autoLazerButton.Position = UDim2.new(0.1, 0, 0.62, 0)
autoLazerButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
autoLazerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoLazerButton.Font = Enum.Font.GothamBold
autoLazerButton.TextSize = 14
autoLazerButton.ZIndex = 2
Instance.new("UICorner", autoLazerButton).CornerRadius = UDim.new(0, 6)

-- Auto Steal button
local autoStealButton = Instance.new("TextButton", frame)
autoStealButton.Text = "AUTO STEAL: OFF"
autoStealButton.Size = UDim2.new(0.8, 0, 0, 25)
autoStealButton.Position = UDim2.new(0.1, 0, 0.74, 0)
autoStealButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
autoStealButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoStealButton.Font = Enum.Font.GothamBold
autoStealButton.TextSize = 14
autoStealButton.ZIndex = 2
Instance.new("UICorner", autoStealButton).CornerRadius = UDim.new(0, 6)

-- Semi Invisible button
local semiInvisibleButton = Instance.new("TextButton", frame)
semiInvisibleButton.Text = "SEMI INVISIBLE: OFF"
semiInvisibleButton.Size = UDim2.new(0.8, 0, 0, 25)
semiInvisibleButton.Position = UDim2.new(0.1, 0, 0.86, 0)
semiInvisibleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
semiInvisibleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
semiInvisibleButton.Font = Enum.Font.GothamBold
semiInvisibleButton.TextSize = 14
semiInvisibleButton.ZIndex = 2
Instance.new("UICorner", semiInvisibleButton).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Text = "Status: Idle"
statusLabel.Size = UDim2.new(1, 0, 0, 16)
statusLabel.Position = UDim2.new(0, 0, 0.96, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.ZIndex = 2

-- Speed Changer Function
local function setSpeed(value)
    if humanoid and humanoid.Parent then
        humanoid.WalkSpeed = value
    end
end

-- Jump Power Function
local function setJumpPower(value)
    if humanoid and humanoid.Parent then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = value
    end
end

-- Float Feature
local floatBodyVelocity

local function toggleFloat()
    floatEnabled = not floatEnabled
    
    -- Clean up existing connections
    for _, conn in pairs(connections.Float) do
        if conn then
            conn:Disconnect()
        end
    end
    connections.Float = {}
    
    if floatEnabled then
        floatButton.Text = "FLOAT: ON"
        floatButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        -- Create BodyVelocity for floating
        floatBodyVelocity = Instance.new("BodyVelocity")
        floatBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        floatBodyVelocity.MaxForce = Vector3.new(0, 0, 0)
        
        -- Float connection
        local floatConnection = RunService.Heartbeat:Connect(function()
            if not floatEnabled or not character or not hrp or not humanoid or humanoid.Health <= 0 then
                return
            end
            
            -- Check if player is in the air with raycast
            local rayOrigin = hrp.Position
            local rayDirection = Vector3.new(0, -5, 0)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            
            local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
            
            if not raycastResult then
                -- In air, apply upward force
                floatBodyVelocity.Velocity = Vector3.new(0, 20, 0)
                floatBodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
            else
                -- On ground, no force
                floatBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                floatBodyVelocity.MaxForce = Vector3.new(0, 0, 0)
            end
            
            -- Make sure BodyVelocity is parented to HRP safely
            if floatBodyVelocity and hrp and hrp.Parent then
                if floatBodyVelocity.Parent ~= hrp then
                    floatBodyVelocity.Parent = hrp
                end
            end
        end)
        
        table.insert(connections.Float, floatConnection)
        
    else
        floatButton.Text = "FLOAT: OFF"
        floatButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        
        -- Remove BodyVelocity
        if floatBodyVelocity then
            floatBodyVelocity:Destroy()
            floatBodyVelocity = nil
        end
    end
end

-- Auto Lazer Feature
local autoLazerThread

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

local function isValidTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or targetPlayer == player then return false end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not targetHRP or not targetHumanoid then return false end
    if targetHumanoid.Health <= 0 then return false end
    return true
end

local function findNearestAllowed()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = player.Character.HumanoidRootPart.Position
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
        autoLazerButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        if autoLazerThread then
            task.cancel(autoLazerThread)
        end
        autoLazerThread = task.spawn(autoLazerWorker)
    else
        autoLazerButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        if autoLazerThread then
            task.cancel(autoLazerThread)
            autoLazerThread = nil
        end
    end
end

-- Auto Floor Feature
local floorPartAF, floorConnAF
local floorRiseSpeed = 2.0
local autoFloorSize = Vector3.new(6, 1, 6)

local function toggleAutoFloor()
    floorOn = not floorOn
    
    -- Clean up existing connections
    if floorConnAF then
        floorConnAF:Disconnect()
        floorConnAF = nil
    end
    
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
        floorConnAF = RunService.Heartbeat:Connect(function(delta)
            if hrp and floorPartAF and hrp.Parent then
                local currentPos = floorPartAF.Position
                local targetY = hrp.Position.Y - hrp.Size.Y/2 - floorPartAF.Size.Y/2
                
                if targetY > currentPos.Y then
                    local newY = currentPos.Y + (targetY - currentPos.Y) * floorRiseSpeed * delta
                    floorPartAF.CFrame = CFrame.new(hrp.Position.X, newY, hrp.Position.Z)
                else
                    floorPartAF.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z)
                end
            end
        end)
        
        table.insert(connections.AutoFloor, floorConnAF)
    else
        autoFloorButton.Text = "AUTO FLOOR: OFF"
        autoFloorButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end

-- Auto Steal Feature
local autoStealThread

-- Trait/Mutation multipliers
local multiplierMap = {
    ["Gold"] = 2,
    ["Diamond"] = 3,
    ["Rainbow"] = 5,
    ["Galaxy"] = 10,
}

-- Fallback rarity priority
local rarityPriority = {
    ["Common"] = 1,
    ["Uncommon"] = 2,
    ["Rare"] = 3,
    ["Epic"] = 4,
    ["Legendary"] = 5,
    ["Mythical"] = 6,
    ["Brainrot God"] = 7,
    ["Secret"] = 8,
    ["OG"] = 9
}

local function getIncome(brainrot)
    local baseIncome = brainrot:FindFirstChild("Income")
    if baseIncome and baseIncome:IsA("NumberValue") then
        local income = baseIncome.Value
        for _, trait in pairs(brainrot:GetChildren()) do
            if trait:IsA("StringValue") and multiplierMap[trait.Value] then
                income = income * multiplierMap[trait.Value]
            end
        end
        return income
    end
    local rarity = brainrot:FindFirstChild("Rarity")
    if rarity and rarity:IsA("StringValue") then
        return rarityPriority[rarity.Value] or 0
    end
    return 0
end

local function stealBrainrot(targetBrainrot)
    if targetBrainrot and targetBrainrot.Parent and hrp and hrp.Parent then
        local targetPos = targetBrainrot.Position
        local tweenTo = TweenService:Create(hrp, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0))})
        tweenTo:Play()
        tweenTo.Completed:Wait()
        
        if hrp and hrp.Parent then
            firetouchinterest(hrp, targetBrainrot, 0)
            wait(0.1)
            firetouchinterest(hrp, targetBrainrot, 1)
            
            local basePosition = getBasePosition() or hrp.Position
            local tweenBack = TweenService:Create(hrp, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = CFrame.new(basePosition)})
            tweenBack:Play()
            
            local effectiveIncome = getIncome(targetBrainrot)
            statusLabel.Text = "Stole: $" .. effectiveIncome .. "k/sec"
        end
    end
end

local function scanAndStealBest()
    local bestBrainrot = nil
    local highestIncome = 0

    local bases = workspace:FindFirstChild("Bases")
    if not bases then
        statusLabel.Text = "No bases found"
        return
    end

    for _, base in pairs(bases:GetChildren()) do
        local unlockTime = base:FindFirstChild("UnlockTime")
        if unlockTime and unlockTime.Value <= 0 then
            for _, potential in pairs(base:GetDescendants()) do
                if potential:IsA("Model") and (potential:FindFirstChild("Income") or potential:FindFirstChild("Rarity")) then
                    local income = getIncome(potential)
                    if income > highestIncome then
                        highestIncome = income
                        bestBrainrot = potential.PrimaryPart or potential:FindFirstChildWhichIsA("BasePart")
                    end
                end
            end
        end
    end

    if bestBrainrot then
        stealBrainrot(bestBrainrot)
    else
        statusLabel.Text = "No stealable Brainrots"
    end
end

local function autoStealWorker()
    while autoStealEnabled do
        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            scanAndStealBest()
        end
        wait(4)
    end
end

local function toggleAutoSteal()
    autoStealEnabled = not autoStealEnabled
    autoStealButton.Text = autoStealEnabled and "AUTO STEAL: ON" or "AUTO STEAL: OFF"
    
    if autoStealEnabled then
        autoStealButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        statusLabel.Text = "Auto Steal: Scanning"
        
        if autoStealThread then
            task.cancel(autoStealThread)
        end
        autoStealThread = task.spawn(autoStealWorker)
    else
        autoStealButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        statusLabel.Text = "Status: Idle"
        
        if autoStealThread then
            task.cancel(autoStealThread)
            autoStealThread = nil
        end
    end
end

-- Semi Invisible Feature
local clone, oldRoot, hip, animTrack

local function semiInvisibleFunction()
    local DEPTH_OFFSET = 0.10

    local function removeFolders()  
        local playerName = player.Name  
        local playerFolder = workspace:FindFirstChild(playerName)  
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
        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then  
            hip = player.Character.Humanoid.HipHeight  
            oldRoot = player.Character:FindFirstChild("HumanoidRootPart")  
            if not oldRoot or not oldRoot.Parent then  
                return false  
            end  

            local tempParent = Instance.new("Model")  
            tempParent.Parent = game  
            player.Character.Parent = tempParent  

            clone = oldRoot:Clone()  
            clone.Parent = player.Character  
            oldRoot.Parent = game.Workspace.CurrentCamera  
            clone.CFrame = oldRoot.CFrame  

            player.Character.PrimaryPart = clone  
            player.Character.Parent = game.Workspace  

            for _, v in pairs(player.Character:GetDescendants()) do  
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
        return false  
    end  

    local function revertClone()  
        if not oldRoot or not oldRoot:IsDescendantOf(game.Workspace) or not player.Character or player.Character.Humanoid.Health <= 0 then  
            return false  
        end  

        local tempParent = Instance.new("Model")  
        tempParent.Parent = game  
        player.Character.Parent = tempParent  

        oldRoot.Parent = player.Character  
        player.Character.PrimaryPart = oldRoot  
        player.Character.Parent = game.Workspace  
        oldRoot.CanCollide = true  

        for _, v in pairs(player.Character:GetDescendants()) do  
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
        if player.Character and player.Character.Humanoid then  
            player.Character.Humanoid.HipHeight = hip  
        end  
    end  

    local function animationTrickery()  
        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then  
            local anim = Instance.new("Animation")  
            anim.AnimationId = "http://www.roblox.com/asset/?id=18537363391"  
            local humanoid = player.Character.Humanoid  
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
    end  

    local function enableInvisibility()  
        if not player.Character or player.Character.Humanoid.Health <= 0 then  
            return false
        end  

        removeFolders()  
        local success = doClone()  
        if success then  
            task.wait(0.1)  
            animationTrickery()  
            local connection = RunService.PreSimulation:Connect(function(dt)  
                if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and oldRoot then  
                    local root = player.Character.PrimaryPart or player.Character:FindFirstChild("HumanoidRootPart")  
                    if root then  
                        local cf = root.CFrame - Vector3.new(0, player.Character.Humanoid.HipHeight + (root.Size.Y / 2) - 1 + DEPTH_OFFSET, 0)  
                        oldRoot.CFrame = cf * CFrame.Angles(math.rad(180), 0, 0)  
                        oldRoot.Velocity = root.Velocity  
                        oldRoot.CanCollide = false  
                    end  
                end  
            end)  
            table.insert(connections.SemiInvisible, connection)  

            local characterConnection = player.CharacterAdded:Connect(function(newChar)
                if isInvisible then
                    if animTrack then  
                        animTrack:Stop()  
                        animTrack:Destroy()  
                        animTrack = nil  
                    end  
                    revertClone()
                    removeFolders()
                    isInvisible = false
                    semiInvisibleButton.Text = "SEMI INVISIBLE: OFF"
                    semiInvisibleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    
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
        revertClone()  
        removeFolders()  
    end

    if not isInvisible then
        removeFolders()  
        if enableInvisibility() then
            isInvisible = true
            semiInvisibleButton.Text = "SEMI INVISIBLE: ON"
            semiInvisibleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            statusLabel.Text = "Status: Semi Invisible Enabled"
        end
    else
        disableInvisibility()
        isInvisible = false
        semiInvisibleButton.Text = "SEMI INVISIBLE: OFF"
        semiInvisibleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        statusLabel.Text = "Status: Idle"
        
        for _, conn in ipairs(connections.SemiInvisible) do  
            if conn then conn:Disconnect() end  
        end  
        connections.SemiInvisible = {}  
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
	if humanoid and humanoid.Parent then
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
			local healthConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
				if humanoid.Health <= 0 then
					humanoid.Health = humanoid.MaxHealth
				end
			end)
			table.insert(connections.Tween, healthConnection)
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

local STOP_DISTANCE = 8
local tweenSpeed = 35

local currentTween
local function tweenWalkTo(position, maintainHeight)
    if currentTween then 
        currentTween:Cancel() 
        currentTween = nil
    end

    if not hrp or not hrp.Parent then return end

    local startPos = hrp.Position
    local targetPos
    
    if maintainHeight then
        targetPos = Vector3.new(position.X, startPos.Y, position.Z)
    else
        targetPos = Vector3.new(position.X, position.Y + 3, position.Z)
    end
    
    local distance = (targetPos - startPos).Magnitude
    local speed = math.max(tweenSpeed, 16)
    local duration = distance / speed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)

    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    currentTween:Play()

    if humanoid and humanoid.Parent then
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end

    currentTween.Completed:Wait()
    currentTween = nil
end

local walkThread

local function isAtBase(basePos)
	if not basePos or not hrp or not hrp.Parent then return false end
	local dist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(basePos.X, 0, basePos.Z)).Magnitude
	return dist <= STOP_DISTANCE
end

local function walkToBase()
    local target = getBasePosition()
    if not target then
        statusLabel.Text = "Status: Base Not Found"
        return
    end

    statusLabel.Text = "Status: Finding path to base..."
    
    while active do
        if not target or not hrp or not hrp.Parent then
            statusLabel.Text = "Status: Base Not Found"
            task.wait(1)
            break
        end

        if isAtBase(target) then
            statusLabel.Text = "Status: Reached Base"
            stopTweenToBase()
            break
        end

        local path = PathfindingService:CreatePath()
        local success, err = pcall(function()
            path:ComputeAsync(hrp.Position, target)
        end)
        
        if not success then
            statusLabel.Text = "Status: Direct path to base"
            tweenWalkTo(target, true)
            break
        end

        if path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            statusLabel.Text = "Status: Following path (" .. #waypoints .. " points)"
            
            for i, waypoint in ipairs(waypoints) do
                if not active or isAtBase(target) or not hrp or not hrp.Parent then 
                    return 
                end
                
                -- Fixed: Replace 'continue' with proper condition
                if not (i == 1 and (waypoint.Position - hrp.Position).Magnitude < 2) then
                    tweenWalkTo(waypoint.Position, true)
                end
            end
        else
            statusLabel.Text = "Status: Direct path (no obstacles)"
            tweenWalkTo(target, true)
        end

        task.wait(0.1)
    end
end

function startTweenToBase()
	if active then return end
	
	active = true
	applyAntiDeath(true)
	if humanoid and humanoid.Parent then
		humanoid.WalkSpeed = tweenSpeed
	end
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
	if humanoid and humanoid.Parent then
		humanoid.WalkSpeed = 16
	end
	statusLabel.Text = "Status: Stopped"
	tweenButton.Text = "▶ START"
	
	if humanoid and humanoid.Parent then
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

floatButton.MouseButton1Click:Connect(function()
    toggleFloat()
end)

autoFloorButton.MouseButton1Click:Connect(function()
    toggleAutoFloor()
end)

autoLazerButton.MouseButton1Click:Connect(function()
    toggleAutoLazer()
end)

autoStealButton.MouseButton1Click:Connect(function()
    toggleAutoSteal()
end)

semiInvisibleButton.MouseButton1Click:Connect(function()
    semiInvisibleFunction()
end)

-- Speed input
speedInput.FocusLost:Connect(function()
	local newSpeed = tonumber(speedInput.Text)
	if newSpeed then
		if newSpeed < 0 then
			speedInput.Text = "0"
			setSpeed(0)
		elseif newSpeed > 200 then
			speedInput.Text = "200"
			setSpeed(200)
		else
			setSpeed(newSpeed)
			tweenSpeed = newSpeed
		end
	else
		speedInput.Text = "35"
		setSpeed(35)
		tweenSpeed = 35
	end
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
    
    -- Clean up all connections
    for feature, connList in pairs(connections) do
        for _, conn in pairs(connList) do
            if conn then
                conn:Disconnect()
            end
        end
    end
    
    -- Clean up objects
    if floorPartAF then
        floorPartAF:Destroy()
    end
    if floatBodyVelocity then
        floatBodyVelocity:Destroy()
    end
    
    -- Stop threads
    if autoLazerThread then
        task.cancel(autoLazerThread)
    end
    if autoStealThread then
        task.cancel(autoStealThread)
    end
end)

-- Set initial values
setJumpPower(50)
setSpeed(35)
