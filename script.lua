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
local function createStyledButton(parent, text, position)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(0.9, 0, 0, 32)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
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

-- Main Tab Content
local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1, 0, 1, 0)
mainContent.BackgroundTransparency = 1
mainContent.Visible = true
mainContent.Parent = contentFrame

-- Enhanced TWEEN TO BASE SYSTEM
local tweenButton = createStyledButton(mainContent, "▶ TWEEN TO BASE", UDim2.new(0.05, 0, 0.02, 0))

-- Keep existing tween system variables and functions...
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

-- [Keep all your existing tween system functions exactly as they are...]
-- getBasePosition, tweenWalkTo, isAtBase, walkToBase, startTweenToBase, stopTweenToBase

-- Enhanced Speed and Jump inputs
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

local speedInput = createInputField(mainContent, "Speed:", UDim2.new(0.05, 0, 0.12, 0), 24)
local jumpInput = createInputField(mainContent, "Jump Power:", UDim2.new(0.05, 0, 0.20, 0), 50)

-- Enhanced FLIGHT SYSTEM
local flyButton = createStyledButton(mainContent, "SLOW FLIGHT: OFF", UDim2.new(0.05, 0, 0.28, 0))

-- Enhanced FLOAT SYSTEM
local floatButton = createStyledButton(mainContent, "FLOAT: OFF", UDim2.new(0.05, 0, 0.36, 0))

-- Enhanced AUTO FLOOR SYSTEM
local autoFloorButton = createStyledButton(mainContent, "AUTO FLOOR: OFF", UDim2.new(0.05, 0, 0.44, 0))

-- ========== ENHANCED SEMI INVISIBLE SYSTEM WITH GOD MODE ==========
local semiInvisButton = createStyledButton(mainContent, "SEMI INVISIBLE: OFF", UDim2.new(0.05, 0, 0.52, 0))

local connections = {
    SemiInvisible = {}
}

local isInvisible = false
local clone, oldRoot, hip, animTrack, connection, characterConnection

-- Enhanced God Mode function
local function enableGodMode()
    updateCharacterReferences()
    if not humanoid then return end
    
    -- Prevent death
    humanoid.Health = humanoid.MaxHealth
    humanoid:SetAttribute("GodMode", true)
    
    -- Store original states
    if not humanoid:GetAttribute("OriginalMaxHealth") then
        humanoid:SetAttribute("OriginalMaxHealth", humanoid.MaxHealth)
    end
    
    -- Health protection
    local healthConnection = humanoid.HealthChanged:Connect(function()
        if humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
    
    table.insert(connections.SemiInvisible, healthConnection)
    
    -- Disable harmful states
    for _, state in pairs({
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.Dead
    }) do
        humanoid:SetStateEnabled(state, false)
    end
end

local function disableGodMode()
    updateCharacterReferences()
    if not humanoid then return end
    
    humanoid:SetAttribute("GodMode", false)
    
    -- Re-enable states
    for _, state in pairs({
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.Dead
    }) do
        humanoid:SetStateEnabled(state, true)
    end
end

local function semiInvisibleFunction()
    local DEPTH_OFFSET = 0.15  -- Increased offset for better hiding

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
        
        -- Enable god mode when semi-invisible starts
        enableGodMode()
        
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
        
        -- Disable god mode when semi-invisible ends
        disableGodMode()

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
                        -- Enhanced hiding: further offset and rotation
                        local cf = root.CFrame - Vector3.new(0, humanoid.HipHeight + (root.Size.Y / 2) - 1.5 + DEPTH_OFFSET, 0)  
                        oldRoot.CFrame = cf * CFrame.Angles(math.rad(180), math.rad(45), 0)  -- Added rotation
                        oldRoot.Velocity = root.Velocity  
                        oldRoot.CanCollide = false  
                        oldRoot.Transparency = 0.8  -- Make more transparent
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
            statusLabel.Text = "Semi Invisible + God Mode enabled"
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

-- [Keep all your existing tab systems, steal content, visuals, combat, etc...]
-- Just replace the button creation with createStyledButton for consistency

-- Enhanced DISCORD BUTTON
local discordBtn = createStyledButton(contentFrame, "📱 DISCORD", UDim2.new(0.05, 0, 0.85, 0))
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)

-- [Keep all your existing tab switching, button connections, and other systems...]
-- Just update the visual styling as shown above

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

-- Update your existing button connections to use the new styling:
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

-- [Rest of your existing code for other tabs and systems...]

print("Enhanced Krypton Hub loaded successfully!")
print("Discord: https://discord.gg/YSwFZsGk9j")
