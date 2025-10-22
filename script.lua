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
    task.wait(0.5)
    hrp = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
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

-- ========== SIMPLE FULL INVISIBLE SYSTEM ==========
local isInvisible = false
local undergroundConnection
local torsoBox

local function fullInvisibleFunction()
    if not isInvisible then
        -- ENABLE FULL INVISIBLE
        isInvisible = true
        playerContent[1].Text = "FULL INVISIBLE: ON"
        playerContent[1].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Full Invisible enabled - You're underground"
        
        updateCharacterReferences()
        if not hrp then return end
        
        -- Create visual torso box
        torsoBox = Instance.new("Part")
        torsoBox.Name = "TorsoIndicator"
        torsoBox.Size = Vector3.new(2, 3, 1)
        torsoBox.BrickColor = BrickColor.new("Bright blue")
        torsoBox.Material = Enum.Material.Neon
        torsoBox.Transparency = 0.7
        torsoBox.Anchored = false
        torsoBox.CanCollide = false
        torsoBox.Parent = Workspace
        
        -- Weld torso box to character
        local weld = Instance.new("Weld")
        weld.Part0 = hrp
        weld.Part1 = torsoBox
        weld.C0 = CFrame.new(0, 0, 0)
        weld.Parent = torsoBox
        
        -- Move character underground
        local undergroundPosition = hrp.Position - Vector3.new(0, 25, 0)
        hrp.CFrame = CFrame.new(undergroundPosition)
        
        -- Keep updating position as you walk (prevents lag back)
        undergroundConnection = RunService.Heartbeat:Connect(function()
            if isInvisible and hrp and humanoid then
                -- Get current movement direction
                local moveDirection = humanoid.MoveDirection
                if moveDirection.Magnitude > 0 then
                    -- Calculate new underground position based on movement
                    local currentPos = hrp.Position
                    local newUndergroundPos = Vector3.new(
                        currentPos.X + moveDirection.X,
                        currentPos.Y, -- Keep same Y (underground)
                        currentPos.Z + moveDirection.Z
                    )
                    hrp.CFrame = CFrame.new(newUndergroundPos)
                end
            end
        end)
        
    else
        -- DISABLE FULL INVISIBLE
        isInvisible = false
        playerContent[1].Text = "FULL INVISIBLE: OFF"
        playerContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Full Invisible disabled"
        
        -- Clean up connections
        if undergroundConnection then
            undergroundConnection:Disconnect()
            undergroundConnection = nil
        end
        
        -- Remove torso box
        if torsoBox then
            torsoBox:Destroy()
            torsoBox = nil
        end
        
        -- Move character back above ground to current position
        if hrp then
            local currentUndergroundPos = hrp.Position
            local aboveGroundPos = Vector3.new(
                currentUndergroundPos.X,
                currentUndergroundPos.Y + 25, -- Bring back above ground
                currentUndergroundPos.Z
            )
            hrp.CFrame = CFrame.new(aboveGroundPos)
        end
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

-- ========== OTHER FEATURES ==========

-- Tween to Base
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
                if not hrp then return end
                
                local targetPos = Vector3.new(basePos.X, basePos.Y + 3, basePos.Z)
                local distance = (targetPos - hrp.Position).Magnitude
                local duration = distance / 20
                
                currentTween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
                currentTween:Play()
                currentTween.Completed:Wait()
                
                tweenActive = false
                mainContent[1].Text = "▶ TWEEN TO BASE"
                mainContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                statusLabel.Text = "Reached base!"
            end)
        else
            statusLabel.Text = "Base not found!"
        end
    end
end)

-- Flight System
local flyActive = false
local flyConnection

mainContent[2].MouseButton1Click:Connect(function()
    flyActive = not flyActive
    
    if flyActive then
        mainContent[2].Text = "SLOW FLIGHT: ON"
        mainContent[2].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Slow Flight enabled"
        
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
    end
end)

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

-- Infinite Jump
local infJumpActive = false
local infJumpConnection

playerContent[2].MouseButton1Click:Connect(function()
    infJumpActive = not infJumpActive
    
    if infJumpActive then
        playerContent[2].Text = "INFINITE JUMP: ON"
        playerContent[2].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Infinite Jump enabled"
        
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if infJumpActive and humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
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

-- Speed Booster
local speedActive = false
local speedConn

playerContent[3].MouseButton1Click:Connect(function()
    speedActive = not speedActive
    
    if speedActive then
        playerContent[3].Text = "SPEED BOOSTER: ON"
        playerContent[3].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Speed Booster enabled"
        
        speedConn = RunService.Heartbeat:Connect(function()
            if speedActive and humanoid then
                humanoid.WalkSpeed = 50
            end
        end)
    else
        playerContent[3].Text = "SPEED BOOSTER: OFF"
        playerContent[3].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Speed Booster disabled"
        
        if speedConn then
            speedConn:Disconnect()
        end
        if humanoid then
            humanoid.WalkSpeed = 16
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
    
    -- Clean up full invisible
    if undergroundConnection then
        undergroundConnection:Disconnect()
        undergroundConnection = nil
    end
    if torsoBox then
        torsoBox:Destroy()
        torsoBox = nil
    end
    
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
print("Controls: F key to toggle full invisible, Circle button to open GUI")
print("Discord: https://discord.gg/YSwFZsGk9j")
