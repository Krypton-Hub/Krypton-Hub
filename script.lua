-- Krypton Hub
-- Made by agent_duke13

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character, hrp, humanoid

-- Global Godmode Protection
local function setupGodmode()
    local mt = getrawmetatable(game)
    local oldNC = mt.__namecall
    local oldNI = mt.__newindex
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local m = getnamecallmethod()
        if self == humanoid then
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
        
        if self == character and m == "BreakJoints" then
            return
        end
        
        return oldNC(self, ...)
    end)
    
    mt.__newindex = newcclosure(function(self, k, v)
        if self == humanoid then
            if k == "Health" and type(v) == "number" and v <= 0 then
                return
            end
            if k == "MaxHealth" and type(v) == "number" and v < humanoid.MaxHealth then
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

-- Safe character reference system
local function updateCharacterReferences()
    character = player.Character
    if character then
        hrp = character:FindFirstChild("HumanoidRootPart")
        humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            setupGodmode()
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
end)

-- Circle toggle button
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "KryptonToggle"
toggleGui.ResetOnSpawn = false
toggleGui.Parent = player:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 20, 0.5, -30)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
toggleButton.BackgroundTransparency = 0.3
toggleButton.Text = "Krypton"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 12
toggleButton.Active = true
toggleButton.Draggable = true
toggleButton.Parent = toggleGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = toggleButton

-- Main GUI
local gui = Instance.new("ScreenGui")
gui.Name = "KryptonHubGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
gui.Enabled = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 320)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.05, 0)
UICorner.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0.05, 0)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Text = "KRYPTON HUB"
title.Size = UDim2.new(1, 0, 1, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Text = "by agent_duke13"
subtitle.Size = UDim2.new(1, 0, 0, 15)
subtitle.Position = UDim2.new(0, 0, 1, -15)
subtitle.BackgroundTransparency = 1
subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.Parent = header

-- Tabs
local tabs = {"Main", "Player", "Visuals"}
local currentTab = "Main"

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 30)
tabContainer.Position = UDim2.new(0, 10, 0, 45)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local tabButtons = {}
for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Text = tabName
    tabButton.Size = UDim2.new(1/#tabs, -5, 1, 0)
    tabButton.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.Font = Enum.Font.GothamSemibold
    tabButton.TextSize = 12
    tabButton.Parent = tabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0.05, 0)
    tabCorner.Parent = tabButton
    
    tabButtons[tabName] = tabButton
end

-- Content Area
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -110)
contentFrame.Position = UDim2.new(0, 10, 0, 80)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local contentScrolling = Instance.new("ScrollingFrame")
contentScrolling.Size = UDim2.new(1, 0, 1, 0)
contentScrolling.Position = UDim2.new(0, 0, 0, 0)
contentScrolling.BackgroundTransparency = 1
contentScrolling.BorderSizePixel = 0
contentScrolling.ScrollBarThickness = 4
contentScrolling.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
contentScrolling.Parent = contentFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 6)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = contentScrolling

-- Status Bar
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, -20, 0, 25)
statusBar.Position = UDim2.new(0, 10, 1, -30)
statusBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
statusBar.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0.05, 0)
statusCorner.Parent = statusBar

local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Status: Ready"
statusLabel.Size = UDim2.new(1, -10, 1, 0)
statusLabel.Position = UDim2.new(0, 5, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusBar

-- Create Button Function
local function createButton(text, layoutOrder)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(1, 0, 0, 32)
    button.Position = UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 12
    button.AutoButtonColor = true
    button.LayoutOrder = layoutOrder
    button.Parent = contentScrolling
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.08, 0)
    buttonCorner.Parent = button
    
    return button
end

-- Create Toggle Function
local function createToggle(text, layoutOrder)
    local toggle = Instance.new("TextButton")
    toggle.Text = text
    toggle.Size = UDim2.new(1, 0, 0, 32)
    toggle.Position = UDim2.new(0, 0, 0, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.GothamSemibold
    toggle.TextSize = 12
    toggle.AutoButtonColor = true
    toggle.LayoutOrder = layoutOrder
    toggle.Parent = contentScrolling
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0.08, 0)
    toggleCorner.Parent = toggle
    
    return toggle
end

-- Tab Contents
local mainContent = {}
local playerContent = {}
local visualsContent = {}

-- MAIN TAB
table.insert(mainContent, createToggle("▶ TWEEN TO BASE", 1))
table.insert(mainContent, createToggle("SLOW FLIGHT: OFF", 2))
table.insert(mainContent, createToggle("FLOAT: OFF", 3))

-- PLAYER TAB
table.insert(playerContent, createToggle("FULL INVISIBLE: OFF", 1))
table.insert(playerContent, createToggle("INFINITE JUMP: OFF", 2))
table.insert(playerContent, createToggle("SPEED BOOSTER: OFF", 3))

-- VISUALS TAB
table.insert(visualsContent, createToggle("PLAYER ESP: OFF", 1))
table.insert(visualsContent, createToggle("FULLBRIGHT: OFF", 2))
table.insert(visualsContent, createButton("DISCORD INVITE", 3))

-- Hide all content initially
for _, button in ipairs(mainContent) do
    button.Visible = false
end
for _, button in ipairs(playerContent) do
    button.Visible = false
end
for _, button in ipairs(visualsContent) do
    button.Visible = false
end

-- Tab System
local function switchTab(tabName)
    currentTab = tabName
    
    -- Hide all content
    for _, button in ipairs(mainContent) do
        button.Visible = false
    end
    for _, button in ipairs(playerContent) do
        button.Visible = false
    end
    for _, button in ipairs(visualsContent) do
        button.Visible = false
    end
    
    -- Show current tab content
    if tabName == "Main" then
        for _, button in ipairs(mainContent) do
            button.Visible = true
        end
    elseif tabName == "Player" then
        for _, button in ipairs(playerContent) do
            button.Visible = true
        end
    elseif tabName == "Visuals" then
        for _, button in ipairs(visualsContent) do
            button.Visible = true
        end
    end
    
    -- Update tab buttons
    for name, button in pairs(tabButtons) do
        if name == tabName then
            button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end

-- Connect tab buttons
for tabName, button in pairs(tabButtons) do
    button.MouseButton1Click:Connect(function()
        switchTab(tabName)
    end)
end

-- Initialize first tab
switchTab("Main")

-- Update scrolling frame size
contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentScrolling.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
end)

-- ========== FIXED TWEEN THAT STAYS ON GROUND ==========
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
    -- Raycast down to find ground height
    local rayOrigin = Vector3.new(position.X, position.Y + 10, position.Z)
    local rayDirection = Vector3.new(0, -50, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    
    local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if raycastResult then
        return raycastResult.Position.Y + 3 -- Stay slightly above ground
    end
    return position.Y -- Fallback to current Y
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
                
                -- Enable godmode during tween
                setupGodmode()
                
                -- Get current ground height and base ground height
                local currentGroundY = getGroundHeight(hrp.Position)
                local baseGroundY = getGroundHeight(basePos)
                
                -- Use the lower of the two heights to stay on ground
                local targetY = math.min(currentGroundY, baseGroundY)
                
                local startPos = Vector3.new(hrp.Position.X, currentGroundY, hrp.Position.Z)
                local targetPos = Vector3.new(basePos.X, targetY, basePos.Z)
                
                local distance = (targetPos - startPos).Magnitude
                local duration = math.max(3, distance / 15) -- Slow speed to avoid lag back
                
                statusLabel.Text = "Tweening (slow to avoid lag)..."
                
                local startTime = tick()
                
                while tweenActive and tick() - startTime < duration do
                    if not hrp then break end
                    
                    local elapsed = tick() - startTime
                    local progress = elapsed / duration
                    
                    -- Very smooth easing to prevent lag back
                    local easedProgress = progress * progress * (3 - 2 * progress) -- Smoothstep
                    
                    local newPos = startPos + (targetPos - startPos) * easedProgress
                    
                    -- Keep character at ground level during tween
                    local currentGround = getGroundHeight(newPos)
                    newPos = Vector3.new(newPos.X, currentGround, newPos.Z)
                    
                    hrp.CFrame = CFrame.new(newPos)
                    
                    -- Keep character alive and in running state
                    if humanoid then
                        humanoid.Health = humanoid.MaxHealth
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                    
                    task.wait(0.05) -- Even slower updates for stability
                end
                
                if tweenActive and hrp then
                    -- Final position adjustment to ground
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

-- ========== YOUR EXACT FLIGHT SYSTEM ==========
local flyActive = false
local flyConnection

mainContent[2].MouseButton1Click:Connect(function()
    flyActive = not flyActive
    
    if flyActive then
        mainContent[2].Text = "SLOW FLIGHT: ON"
        mainContent[2].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Slow Flight enabled - Use camera direction"
        
        flyConnection = RunService.RenderStepped:Connect(function()
            updateCharacterReferences()
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

-- ========== FIXED FULL INVISIBLE SYSTEM (SHALLOW UNDERGROUND + NO LAG BACK) ==========
local connections = {
    FullInvisible = {}
}

local isInvisible = false
local clone, oldRoot, hip, animTrack, connection, characterConnection, torsoBox

local function fullInvisibleFunction()
    local SHALLOW_DEPTH_OFFSET = 10  -- Only about 2 characters underground (was 50)

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
        table.insert(connections.FullInvisible, childAddedConn)  
    end  

    local function doClone()  
        if character and humanoid and humanoid.Health > 0 then  
            hip = humanoid.HipHeight  
            oldRoot = hrp
            if not oldRoot or not oldRoot.Parent then  
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
        return false  
    end  

    local function createTorsoBox()
        if not clone then return end
        
        torsoBox = Instance.new("Part")
        torsoBox.Name = "TorsoIndicator"
        torsoBox.Size = Vector3.new(2, 3, 1)
        torsoBox.BrickColor = BrickColor.new("Bright blue")
        torsoBox.Material = Enum.Material.Neon
        torsoBox.Transparency = 0.3
        torsoBox.Anchored = false
        torsoBox.CanCollide = false
        torsoBox.Parent = Workspace
        
        local weld = Instance.new("Weld")
        weld.Part0 = clone
        weld.Part1 = torsoBox
        weld.C0 = CFrame.new(0, 0, 0)
        weld.Parent = torsoBox
    end

    local function makeCharacterTransparent()
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1  -- Fully transparent
                end
            end
        end
    end

    local function revertCharacterTransparency()
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0  -- Back to normal
                end
            end
        end
    end

    local function revertClone()  
        if not oldRoot or not oldRoot:IsDescendantOf(Workspace) or not character or humanoid.Health <= 0 then  
            return false  
        end  

        -- FIRST: Move the real character to the clone's position (prevents lag back)
        local currentClonePosition = clone.Position
        local currentCloneCFrame = clone.CFrame
        
        local tempParent = Instance.new("Model")  
        tempParent.Parent = game  
        character.Parent = tempParent  

        oldRoot.Parent = character  
        character.PrimaryPart = oldRoot  
        character.Parent = Workspace  
        
        -- Set the real character to the clone's position to prevent lag back
        oldRoot.CFrame = currentCloneCFrame
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
            clone:Destroy()  
            clone = nil  
        end  

        oldRoot = nil  
        if character and humanoid then  
            humanoid.HipHeight = hip  
        end  

        tempParent:Destroy()  
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
                if isInvisible then  
                    animationTrickery()  
                end  
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
        if not character or humanoid.Health <= 0 then  
            return false
        end  

        removeFolders()  
        local success = doClone()  
        if success then  
            task.wait(0.1)  
            animationTrickery()  
            
            -- Make character transparent
            makeCharacterTransparent()
            
            -- Create torso box
            createTorsoBox()
            
            connection = RunService.PreSimulation:Connect(function(dt)  
                if character and humanoid and humanoid.Health > 0 and oldRoot then  
                    local root = character.PrimaryPart or hrp
                    if root then  
                        -- Move real character only 10 studs underground (shallow)
                        local cf = root.CFrame - Vector3.new(0, SHALLOW_DEPTH_OFFSET, 0)  
                        oldRoot.CFrame = cf * CFrame.Angles(math.rad(180), 0, 0)  
                        oldRoot.Velocity = root.Velocity  
                        oldRoot.CanCollide = false  
                    end  
                end  
            end)  
            table.insert(connections.FullInvisible, connection)  

            characterConnection = player.CharacterAdded:Connect(function(newChar)
                if isInvisible then
                    if animTrack then  
                        animTrack:Stop()  
                        animTrack:Destroy()  
                        animTrack = nil  
                    end  
                    if connection then connection:Disconnect() end  
                    if torsoBox then torsoBox:Destroy() end
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
        if animTrack then  
            animTrack:Stop()  
            animTrack:Destroy()  
            animTrack = nil  
        end  
        if connection then connection:Disconnect() end  
        if characterConnection then characterConnection:Disconnect() end  
        if torsoBox then torsoBox:Destroy() end
        
        -- Revert transparency BEFORE reverting clone
        revertCharacterTransparency()
        
        revertClone()  
        removeFolders()  
    end

    if not isInvisible then
        removeFolders()  
        setupGodmode()  
        if enableInvisibility() then
            isInvisible = true
            playerContent[1].Text = "FULL INVISIBLE: ON"
            playerContent[1].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            statusLabel.Text = "Full Invisible enabled - Shallow underground (F key to toggle)"
        end
    else
        disableInvisibility()
        isInvisible = false
        playerContent[1].Text = "FULL INVISIBLE: OFF"
        playerContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
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

-- Connect full-invisible to button
playerContent[1].MouseButton1Click:Connect(fullInvisibleFunction)

-- F key toggle for full-invisible
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F and not gameProcessed then
        fullInvisibleFunction()
    end
end)

-- ========== INFINITE JUMP ==========
local infJumpActive = false
local infJumpConnection

playerContent[2].MouseButton1Click:Connect(function()
    infJumpActive = not infJumpActive
    
    if infJumpActive then
        playerContent[2].Text = "INFINITE JUMP: ON"
        playerContent[2].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Infinite Jump enabled"
        
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if infJumpActive and humanoid and humanoid.Health > 0 then
                setupGodmode()
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                if hrp then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
                end
            end
        end)
    else
        playerContent[2].Text = "INFINITE JUMP: OFF"
        playerContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Infinite Jump disabled"
        
        if infJumpConnection then
            infJumpConnection:Disconnect()
        end
    end
end)

-- ========== SPEED BOOSTER ==========
local speedActive = false
local speedConn
local baseSpeed = 27

playerContent[3].MouseButton1Click:Connect(function()
    speedActive = not speedActive
    
    if speedActive then
        playerContent[3].Text = "SPEED BOOSTER: ON"
        playerContent[3].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Speed Booster enabled"
        
        local function GetCharacter()
            local Char = player.Character or player.CharacterAdded:Wait()
            local HRP = Char:WaitForChild("HumanoidRootPart")
            local Hum = Char:FindFirstChildOfClass("Humanoid")
            return Char, HRP, Hum
        end
        
        local function getMovementInput()
            local Char, HRP, Hum = GetCharacter()
            if not Char or not HRP or not Hum then return Vector3.new(0,0,0) end
            local moveVector = Hum.MoveDirection
            if moveVector.Magnitude > 0.1 then
                return Vector3.new(moveVector.X, 0, moveVector.Z).Unit
            end
            return Vector3.new(0,0,0)
        end
        
        speedConn = RunService.Heartbeat:Connect(function()
            local Char, HRP, Hum = GetCharacter()
            if not Char or not HRP or not Hum then return end
            local inputDirection = getMovementInput()
            if inputDirection.Magnitude > 0 then
                HRP.AssemblyLinearVelocity = Vector3.new(
                    inputDirection.X * baseSpeed,
                    HRP.AssemblyLinearVelocity.Y,
                    inputDirection.Z * baseSpeed
                )
            else
                HRP.AssemblyLinearVelocity = Vector3.new(0, HRP.AssemblyLinearVelocity.Y, 0)
            end
        end)
    else
        playerContent[3].Text = "SPEED BOOSTER: OFF"
        playerContent[3].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Speed Booster disabled"
        
        if speedConn then 
            speedConn:Disconnect() 
            speedConn = nil 
        end
        
        -- Stop movement when disabled
        updateCharacterReferences()
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
        end
    end
end)

-- ========== OTHER FEATURES ==========

-- Float System
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

-- ESP System
local espActive = false
local espFolders = {}

visualsContent[1].MouseButton1Click:Connect(function()
    espActive = not espActive
    
    if espActive then
        visualsContent[1].Text = "PLAYER ESP: ON"
        visualsContent[1].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "ESP enabled"
        
        local function createESP(character, folder)
            if character and folder then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = character
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = folder
            end
        end
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player then
                local espFolder = Instance.new("Folder")
                espFolder.Name = otherPlayer.Name .. "_ESP"
                espFolder.Parent = Workspace
                espFolders[otherPlayer] = espFolder
                
                if otherPlayer.Character then
                    createESP(otherPlayer.Character, espFolder)
                end
                
                otherPlayer.CharacterAdded:Connect(function(char)
                    createESP(char, espFolder)
                end)
            end
        end
    else
        visualsContent[1].Text = "PLAYER ESP: OFF"
        visualsContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "ESP disabled"
        
        for _, folder in pairs(espFolders) do
            if folder then
                folder:Destroy()
            end
        end
        espFolders = {}
    end
end)

-- Fullbright
local fullbrightActive = false
local originalBrightness
local originalClockTime

visualsContent[2].MouseButton1Click:Connect(function()
    fullbrightActive = not fullbrightActive
    
    if fullbrightActive then
        visualsContent[2].Text = "FULLBRIGHT: ON"
        visualsContent[2].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Fullbright enabled"
        
        originalBrightness = Lighting.Brightness
        originalClockTime = Lighting.ClockTime
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        visualsContent[2].Text = "FULLBRIGHT: OFF"
        visualsContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Fullbright disabled"
        
        if originalBrightness then
            Lighting.Brightness = originalBrightness
        end
        if originalClockTime then
            Lighting.ClockTime = originalClockTime
        end
        Lighting.GlobalShadows = true
    end
end)

-- Discord Button
visualsContent[3].MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/YSwFZsGk9j")
        statusLabel.Text = "Discord link copied to clipboard!"
        visualsContent[3].Text = "✓ COPIED!"
        task.wait(2)
        visualsContent[3].Text = "DISCORD INVITE"
    else
        statusLabel.Text = "Clipboard not supported on this device"
    end
end)

-- Simple Click Toggle Button
toggleButton.MouseButton1Click:Connect(function()
    gui.Enabled = not gui.Enabled
    if gui.Enabled then
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        statusLabel.Text = "GUI Opened"
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        statusLabel.Text = "GUI Closed"
    end
end)

-- Auto-cleanup on character death
player.CharacterAdded:Connect(function()
    -- Reset all states
    tweenActive = false
    flyActive = false
    floatActive = false
    isInvisible = false
    infJumpActive = false
    speedActive = false
    espActive = false
    fullbrightActive = false
    
    -- Reset buttons
    mainContent[1].Text = "▶ TWEEN TO BASE"
    mainContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    mainContent[2].Text = "SLOW FLIGHT: OFF"
    mainContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    mainContent[3].Text = "FLOAT: OFF"
    mainContent[3].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    playerContent[1].Text = "FULL INVISIBLE: OFF"
    playerContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    playerContent[2].Text = "INFINITE JUMP: OFF"
    playerContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    playerContent[3].Text = "SPEED BOOSTER: OFF"
    playerContent[3].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    visualsContent[1].Text = "PLAYER ESP: OFF"
    visualsContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    visualsContent[2].Text = "FULLBRIGHT: OFF"
    visualsContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    visualsContent[3].Text = "DISCORD INVITE"
    visualsContent[3].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    -- Clean up connections
    if currentTween then currentTween:Cancel() end
    if flyConnection then flyConnection:Disconnect() end
    if floatBodyVelocity then floatBodyVelocity:Destroy() end
    if infJumpConnection then infJumpConnection:Disconnect() end
    if speedConn then speedConn:Disconnect() end
    
    -- Clean up full-invisible
    for _, conn in ipairs(connections.FullInvisible) do
        if conn then conn:Disconnect() end
    end
    connections.FullInvisible = {}
    
    -- Reset ESP
    for _, folder in pairs(espFolders) do
        if folder then folder:Destroy() end
    end
    espFolders = {}
    
    -- Reset lighting
    if originalBrightness then
        Lighting.Brightness = originalBrightness
    end
    if originalClockTime then
        Lighting.ClockTime = originalClockTime
    end
    Lighting.GlobalShadows = true
    
    statusLabel.Text = "Character respawned - Ready"
end)

print("Krypton Hub v5.0 - Full Invisible Edition Loaded!")
print("Features: Full invisible (shallow underground + transparent + torso box + no lag back)")
print("Controls: F key to toggle full invisible, Circle button to open GUI")
print("Discord: https://discord.gg/YSwFZsGk9j")
