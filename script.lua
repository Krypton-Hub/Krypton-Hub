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

-- Semi Invisible Feature
local connections = {
    SemiInvisible = {}
}

local isInvisible = false
local clone, oldRoot, hip, animTrack, connection, characterConnection

local function semiInvisibleFunction()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer

    local DEPTH_OFFSET = 0.10  -- Changed from 0.09 to 0.10

    local function removeFolders()  
        local playerName = LocalPlayer.Name  
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
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then  
            hip = LocalPlayer.Character.Humanoid.HipHeight  
            oldRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")  
            if not oldRoot or not oldRoot.Parent then  
                return false  
            end  

            local tempParent = Instance.new("Model")  
            tempParent.Parent = game  
            LocalPlayer.Character.Parent = tempParent  

            clone = oldRoot:Clone()  
            clone.Parent = LocalPlayer.Character  
            oldRoot.Parent = game.Workspace.CurrentCamera  
            clone.CFrame = oldRoot.CFrame  

            LocalPlayer.Character.PrimaryPart = clone  
            LocalPlayer.Character.Parent = game.Workspace  

            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do  
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
        if not oldRoot or not oldRoot:IsDescendantOf(game.Workspace) or not LocalPlayer.Character or LocalPlayer.Character.Humanoid.Health <= 0 then  
            return false  
        end  

        local tempParent = Instance.new("Model")  
        tempParent.Parent = game  
        LocalPlayer.Character.Parent = tempParent  

        oldRoot.Parent = LocalPlayer.Character  
        LocalPlayer.Character.PrimaryPart = oldRoot  
        LocalPlayer.Character.Parent = game.Workspace  
        oldRoot.CanCollide = true  

        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do  
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
        if LocalPlayer.Character and LocalPlayer.Character.Humanoid then  
            LocalPlayer.Character.Humanoid.HipHeight = hip  
        end  
    end  

    local function animationTrickery()  
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then  
            local anim = Instance.new("Animation")  
            anim.AnimationId = "http://www.roblox.com/asset/?id=18537363391"  
            local humanoid = LocalPlayer.Character.Humanoid  
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
        if not LocalPlayer.Character or LocalPlayer.Character.Humanoid.Health <= 0 then  
            return false
        end  

        removeFolders()  
        local success = doClone()  
        if success then  
            task.wait(0.1)  
            animationTrickery()  
            connection = RunService.PreSimulation:Connect(function(dt)  
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 and oldRoot then  
                    local root = LocalPlayer.Character.PrimaryPart or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")  
                    if root then  
                        local cf = root.CFrame - Vector3.new(0, LocalPlayer.Character.Humanoid.HipHeight + (root.Size.Y / 2) - 1 + DEPTH_OFFSET, 0)  
                        oldRoot.CFrame = cf * CFrame.Angles(math.rad(180), 0, 0)  
                        oldRoot.Velocity = root.Velocity  
                        oldRoot.CanCollide = false  
                    end  
                end  
            end)  
            table.insert(connections.SemiInvisible, connection)  

            characterConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
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

    local function setupGodmode()  
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()  
        local hum = char:WaitForChild("Humanoid")  
        local mt = getrawmetatable(game)  
        local oldNC = mt.__namecall  
        local oldNI = mt.__newindex  

        setreadonly(mt, false)  

        mt.__namecall = newcclosure(function(self, ...)  
            local m = getnamecallmethod()  
            if self == hum then  
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
            end

            if self == char and m == "BreakJoints" then  
                return  
            end  

            return oldNC(self, ...)  
        end)  

        mt.__newindex = newcclosure(function(self, k, v)  
            if self == hum then  
                if k == "Health" and type(v) == "number" and v <= 0 then  
                    return  
                end  
                if k == "MaxHealth" and type(v) == "number" and v < hum.MaxHealth then  
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

    if not isInvisible then
        removeFolders()  
        setupGodmode()  
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
        
        pcall(function()  
            local oldGui = LocalPlayer.PlayerGui:FindFirstChild("InvisibleGui")  
            if oldGui then oldGui:Destroy() end  
        end)  
        for _, conn in ipairs(connections.SemiInvisible) do  
            if conn then conn:Disconnect() end  
        end  
        connections.SemiInvisible = {}  
    end
end

-- Semi Invisible Button Connection
semiInvisibleButton.MouseButton1Click:Connect(function()
    semiInvisibleFunction()
end)

-- [Rest of your existing code for other features...]
-- Auto Steal Feature, Speed Changer, Float Feature, etc. remain the same
-- (Include all the other features from your previous script here)

-- Button connections for other features
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

-- [Include all the rest of your existing code...]
