-- Krypton Hub - Custom DrRay Clone (1:1 Similar)
-- Made by agent_duke13 | Standalone UI Library like DrRay

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character, hrp, humanoid

-- Custom DrRay-Like UI Library (1:1 API Match)
local DrRayLibrary = {}
local windows = {}

local function createNotification(text)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 50)
    frame.Position = UDim2.new(1, -260, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame

    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(1, -260, 0, 20)})
    tweenIn:Play()

    task.wait(3)
    local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(1, 0, 0, 20)})
    tweenOut:Play()
    tweenOut.Completed:Connect(function() screenGui:Destroy() end)
end

function DrRayLibrary.newWindow(title, icon)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DrRayWindow"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = tabContainer

    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, 0, 1, -80)
    contentContainer.Position = UDim2.new(0, 0, 0, 80)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = mainFrame

    local tabs = {}
    local currentTab = nil

    function tabs.newTab(name, iconId)
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 100, 1, 0)
        tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        tabButton.Text = name
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.TextSize = 14
        tabButton.Parent = tabContainer

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabButton

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 6
        tabContent.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
        tabContent.Visible = false
        tabContent.Parent = contentContainer

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 5)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = tabContent

        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
        end)

        tabButton.MouseButton1Click:Connect(function()
            if currentTab then currentTab.Visible = false end
            tabContent.Visible = true
            currentTab = tabContent
            for _, btn in pairs(tabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
            tabButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        function tabContent.newToggle(label, default, callback)
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, -20, 0, 30)
            toggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            toggleFrame.LayoutOrder = #tabContent:GetChildren()
            toggleFrame.Parent = tabContent

            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 6)
            toggleCorner.Parent = toggleFrame

            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Size = UDim2.new(1, -50, 1, 0)
            toggleLabel.Position = UDim2.new(0, 10, 0, 0)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Text = label .. ": OFF"
            toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggleLabel.Font = Enum.Font.GothamSemibold
            toggleLabel.TextSize = 12
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = toggleFrame

            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, 40, 0, 20)
            toggleButton.Position = UDim2.new(1, -50, 0.5, -10)
            toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            toggleButton.Text = ""
            toggleButton.Parent = toggleFrame

            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 10)
            buttonCorner.Parent = toggleButton

            local state = default
            local function updateState()
                state = not state
                toggleLabel.Text = label .. (state and ": ON" or ": OFF")
                toggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 100)
                callback(state)
            end

            toggleButton.MouseButton1Click:Connect(updateState)
            if default then updateState() end
        end

        function tabContent.newSlider(label, min, max, callback)
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, -20, 0, 50)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            sliderFrame.LayoutOrder = #tabContent:GetChildren()
            sliderFrame.Parent = tabContent

            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(0, 6)
            sliderCorner.Parent = sliderFrame

            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Size = UDim2.new(1, 0, 0, 20)
            sliderLabel.Position = UDim2.new(0, 10, 0, 5)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Text = label .. ": " .. min
            sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            sliderLabel.Font = Enum.Font.GothamSemibold
            sliderLabel.TextSize = 12
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Parent = sliderFrame

            local sliderBar = Instance.new("Frame")
            sliderBar.Size = UDim2.new(1, -20, 0, 8)
            sliderBar.Position = UDim2.new(0, 10, 0, 30)
            sliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
            sliderBar.Parent = sliderFrame

            local barCorner = Instance.new("UICorner")
            barCorner.CornerRadius = UDim.new(0, 4)
            barCorner.Parent = sliderBar

            local sliderButton = Instance.new("TextButton")
            sliderButton.Size = UDim2.new(0, 20, 1, 0)
            sliderButton.Position = UDim2.new(0, 0, 0, 0)
            sliderButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            sliderButton.Text = ""
            sliderButton.Parent = sliderBar

            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 4)
            buttonCorner.Parent = sliderButton

            local value = min
            local dragging = false

            sliderButton.MouseButton1Down:Connect(function()
                dragging = true
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            RunService.RenderStepped:Connect(function()
                if dragging then
                    local mouse = UserInputService:GetMouseLocation()
                    local relativeX = math.clamp((mouse.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (max - min) * relativeX)
                    sliderButton.Position = UDim2.new(relativeX, -10, 0, 0)
                    sliderLabel.Text = label .. ": " .. value
                    callback(value)
                end
            end)
        end

        function tabContent.newButton(label, desc, callback)
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -20, 0, 40)
            button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            button.Text = label
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Font = Enum.Font.GothamSemibold
            button.TextSize = 12
            button.LayoutOrder = #tabContent:GetChildren()
            button.Parent = tabContent

            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 6)
            buttonCorner.Parent = button

            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, 0, 0, 15)
            descLabel.Position = UDim2.new(0, 5, 1, -15)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = desc
            descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextSize = 10
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = button

            button.MouseButton1Click:Connect(callback)
        end

        function tabContent.newKeybind(label, key, callback)
            local keybindFrame = Instance.new("Frame")
            keybindFrame.Size = UDim2.new(1, -20, 0, 30)
            keybindFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            keybindFrame.LayoutOrder = #tabContent:GetChildren()
            keybindFrame.Parent = tabContent

            local keybindCorner = Instance.new("UICorner")
            keybindCorner.CornerRadius = UDim.new(0, 6)
            keybindCorner.Parent = keybindFrame

            local keybindLabel = Instance.new("TextLabel")
            keybindLabel.Size = UDim2.new(1, -60, 1, 0)
            keybindLabel.Position = UDim2.new(0, 10, 0, 0)
            keybindLabel.BackgroundTransparency = 1
            keybindLabel.Text = label .. ": [" .. key.Name .. "]"
            keybindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            keybindLabel.Font = Enum.Font.GothamSemibold
            keybindLabel.TextSize = 12
            keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
            keybindLabel.Parent = keybindFrame

            local keybindButton = Instance.new("TextButton")
            keybindButton.Size = UDim2.new(0, 50, 0, 20)
            keybindButton.Position = UDim2.new(1, -60, 0.5, -10)
            keybindButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            keybindButton.Text = key.Name
            keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            keybindButton.Font = Enum.Font.Gotham
            keybindButton.TextSize = 10
            keybindButton.Parent = keybindFrame

            local kbCorner = Instance.new("UICorner")
            kbCorner.CornerRadius = UDim.new(0, 4)
            kbCorner.Parent = keybindButton

            keybindButton.MouseButton1Click:Connect(function()
                keybindButton.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input)
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    local newKey = input.KeyCode
                    keybindButton.Text = newKey.Name
                    keybindLabel.Text = label .. ": [" .. newKey.Name .. "]"
                    callback(newKey)
                end
            end)
        end

        return tabContent
    end

    windows[title] = {tabs = tabs, content = contentContainer}
    return windows[title]
end

function DrRayLibrary.notify(text)
    createNotification(text)
end

-- Godmode Protection
local function setupGodmode()
    local mt = getrawmetatable(game)
    local oldNC = mt.__namecall
    local oldNI = mt.__newindex
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local m = getnamecallmethod()
        if self == humanoid then
            if m == "ChangeState" and select(1, ...) == Enum.HumanoidStateType.Dead then return end
            if m == "SetStateEnabled" then
                local st, en = ...
                if st == Enum.HumanoidStateType.Dead and en == true then return end
            end
            if m == "Destroy" then return end
        end
        if self == character and m == "BreakJoints" then return end
        return oldNC(self, ...)
    end)
    
    mt.__newindex = newcclosure(function(self, k, v)
        if self == humanoid then
            if k == "Health" and type(v) == "number" and v <= 0 then return end
            if k == "MaxHealth" and type(v) == "number" and v < humanoid.MaxHealth then return end
            if k == "BreakJointsOnDeath" and v == true then return end
            if k == "Parent" and v == nil then return end
        end
        return oldNI(self, k, v)
    end)
    
    setreadonly(mt, true)
end

-- Safe Character References
local function updateCharacterReferences()
    character = player.Character
    if character then
        hrp = character:FindFirstChild("HumanoidRootPart")
        humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then setupGodmode() end
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

-- Create Window
local Window = DrRayLibrary.newWindow("Krypton Hub v5.0 by agent_duke13")

-- Main Tab
local MainTab = Window.tabs.newTab("Main")

-- Tween to Base Toggle
local tweenActive = false
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

MainTab.newToggle("Tween to Base", false, function(state)
    if state then
        local basePos = getBasePosition()
        if basePos then
            tweenActive = true
            DrRayLibrary.notify("Tweening to base...")
            spawn(function()
                updateCharacterReferences()
                if not hrp or not humanoid then 
                    DrRayLibrary.notify("No character found!")
                    tweenActive = false
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
                    
                    task.wait(0.05)
                end
                
                if tweenActive and hrp then
                    local finalGroundY = getGroundHeight(targetPos)
                    hrp.CFrame = CFrame.new(targetPos.X, finalGroundY, targetPos.Z)
                    DrRayLibrary.notify("Reached base safely!")
                end
                
                tweenActive = false
            end)
        else
            DrRayLibrary.notify("Base not found!")
        end
    else
        tweenActive = false
        DrRayLibrary.notify("Tween stopped")
    end
end)

-- Slow Flight Toggle + Slider
local flyActive = false
local flyConnection
local flySpeed = 25
MainTab.newSlider("Fly Speed", 10, 100, function(value)
    flySpeed = value
end)
MainTab.newToggle("Slow Flight", false, function(state)
    flyActive = state
    if state then
        DrRayLibrary.notify("Slow Flight enabled - Use camera direction")
        flyConnection = RunService.RenderStepped:Connect(function()
            updateCharacterReferences()
            if flyActive and hrp then
                hrp.Velocity = workspace.CurrentCamera.CFrame.LookVector * flySpeed
            end
        end)
    else
        DrRayLibrary.notify("Slow Flight disabled")
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

-- Float Toggle
local floatActive = false
local floatBodyVelocity
MainTab.newToggle("Float", false, function(state)
    floatActive = state
    if state then
        DrRayLibrary.notify("Float enabled")
        updateCharacterReferences()
        if hrp then
            setupGodmode()
            floatBodyVelocity = Instance.new("BodyVelocity")
            floatBodyVelocity.Velocity = Vector3.new(0, 25, 0)
            floatBodyVelocity.MaxForce = Vector3.new(0, 50000, 0)
            floatBodyVelocity.Parent = hrp
        end
    else
        DrRayLibrary.notify("Float disabled")
        if floatBodyVelocity then
            floatBodyVelocity:Destroy()
        end
    end
end)

-- Player Tab
local PlayerTab = Window.tabs.newTab("Player")

-- Semi-Invisible Function (Full)
local connections = {SemiInvisible = {}}
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
        if not character or humanoid.Health <= 0 then  
            return false
        end  

        removeFolders()  
        local success = doClone()  
        if success then  
            task.wait(0.1)  
            animationTrickery()  
            connection = RunService.PreSimulation:Connect(function(dt)  
                if character and humanoid and humanoid.Health > 0 and oldRoot then  
                    local root = character.PrimaryPart or hrp
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
        setupGodmode()  
        if enableInvisibility() then
            isInvisible = true
            DrRayLibrary.notify("Semi-Invisible enabled (F key to toggle)")
        else
            DrRayLibrary.notify("Failed to enable Semi-Invisible")
        end
    else
        disableInvisibility()
        isInvisible = false
        DrRayLibrary.notify("Semi-Invisible disabled")
        pcall(function()  
            local oldGui = player.PlayerGui:FindFirstChild("InvisibleGui")  
            if oldGui then oldGui:Destroy() end  
        end)  
        for _, conn in ipairs(connections.SemiInvisible) do  
            if conn then conn:Disconnect() end  
        end  
        connections.SemiInvisible = {}  
    end
end

PlayerTab.newToggle("Semi Invisible", false, semiInvisibleFunction)
PlayerTab.newKeybind("Semi Invisible", Enum.KeyCode.F, semiInvisibleFunction)

-- Infinite Jump Toggle
local infJumpActive = false
local infJumpConnection
PlayerTab.newToggle("Infinite Jump", false, function(state)
    infJumpActive = state
    if state then
        DrRayLibrary.notify("Infinite Jump enabled")
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
        DrRayLibrary.notify("Infinite Jump disabled")
        if infJumpConnection then
            infJumpConnection:Disconnect()
        end
    end
end)

-- Speed Booster Toggle + Slider
local speedActive = false
local speedConn
local baseSpeed = 27
PlayerTab.newSlider("Speed Value", 16, 100, function(value)
    baseSpeed = value
end)
PlayerTab.newToggle("Speed Booster", false, function(state)
    speedActive = state
    if state then
        DrRayLibrary.notify("Speed Booster enabled")
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
        DrRayLibrary.notify("Speed Booster disabled")
        if speedConn then 
            speedConn:Disconnect() 
            speedConn = nil 
        end
        updateCharacterReferences()
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
        end
    end
end)

-- Visuals Tab
local VisualsTab = Window.tabs.newTab("Visuals")

-- ESP Toggle
local espActive = false
local espFolders = {}
VisualsTab.newToggle("Player ESP", false, function(state)
    espActive = state
    if state then
        DrRayLibrary.notify("ESP enabled")
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
        DrRayLibrary.notify("ESP disabled")
        for _, folder in pairs(espFolders) do
            if folder then
                folder:Destroy()
            end
        end
        espFolders = {}
    end
end)

-- Fullbright Toggle
local fullbrightActive = false
local originalBrightness
local originalClockTime
VisualsTab.newToggle("Fullbright", false, function(state)
    fullbrightActive = state
    if state then
        DrRayLibrary.notify("Fullbright enabled")
        originalBrightness = Lighting.Brightness
        originalClockTime = Lighting.ClockTime
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        DrRayLibrary.notify("Fullbright disabled")
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
VisualsTab.newButton("Copy Discord Invite", "Join for updates", function()
    if setclipboard then
        setclipboard("https://discord.gg/YSwFZsGk9j")
        DrRayLibrary.notify("Discord link copied!")
    else
        DrRayLibrary.notify("Clipboard not supported")
    end
end)

-- Auto-cleanup on Respawn
player.CharacterAdded:Connect(function()
    tweenActive = false
    flyActive = false
    floatActive = false
    isInvisible = false
    infJumpActive = false
    speedActive = false
    espActive = false
    fullbrightActive = false
    
    if flyConnection then flyConnection:Disconnect() end
    if floatBodyVelocity then floatBodyVelocity:Destroy() end
    if infJumpConnection then infJumpConnection:Disconnect() end
    if speedConn then speedConn:Disconnect() end
    
    for _, conn in ipairs(connections.SemiInvisible) do
        if conn then conn:Disconnect() end
    end
    connections.SemiInvisible = {}
    
    for _, folder in pairs(espFolders) do
        if folder then folder:Destroy() end
    end
    espFolders = {}
    
    if originalBrightness then
        Lighting.Brightness = originalBrightness
    end
    if originalClockTime then
        Lighting.ClockTime = originalClockTime
    end
    Lighting.GlobalShadows = true
    
    DrRayLibrary.notify("Respawned - Features reset")
end)

print("Krypton Hub DrRay Clone Loaded! GUI should appear now.")
