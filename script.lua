-- Krypton Hub - Fixed Complete Edition
-- Made by agent_duke13

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character, hrp, humanoid

-- Fix: Add missing newcclosure
if not newcclosure then
    newcclosure = function(f) return f end
end

-- Global Godmode Protection
local function setupGodmode()
    if not humanoid then return end
    
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
            if k == "MaxHealth" and type(v) == "number" and v < (humanoid.MaxHealth or 100) then
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

-- PLAYER TAB
table.insert(playerContent, createToggle("INFINITE JUMP: OFF", 1))
table.insert(playerContent, createToggle("SPEED BOOSTER: OFF", 2))
table.insert(playerContent, createToggle("AUTO STEAL: OFF", 3))

-- VISUALS TAB
table.insert(visualsContent, createToggle("FULLBRIGHT: OFF", 1))
table.insert(visualsContent, createButton("DISCORD INVITE", 2))

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

-- ========== FIXED TWEEN ==========
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

mainContent[1].MouseButton1Click:Connect(function()
    if tweenActive then
        tweenActive = false
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
                
                local targetPos = Vector3.new(basePos.X, basePos.Y + 3, basePos.Z)
                local distance = (targetPos - hrp.Position).Magnitude
                local duration = math.max(2, distance / 20)
                
                local startPos = hrp.Position
                local startTime = tick()
                
                while tweenActive and tick() - startTime < duration do
                    if not hrp then break end
                    
                    local elapsed = tick() - startTime
                    local progress = elapsed / duration
                    local easedProgress = progress * progress * (3 - 2 * progress)
                    
                    local newPos = startPos + (targetPos - startPos) * easedProgress
                    hrp.CFrame = CFrame.new(newPos)
                    
                    if humanoid then
                        humanoid.Health = humanoid.MaxHealth
                    end
                    
                    task.wait(0.03)
                end
                
                if tweenActive and hrp then
                    hrp.CFrame = CFrame.new(targetPos)
                    statusLabel.Text = "Reached base!"
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

-- ========== FIXED FLIGHT SYSTEM ==========
local flyActive = false
local flyConnection
local lastFlightUpdate = 0

mainContent[2].MouseButton1Click:Connect(function()
    flyActive = not flyActive
    
    if flyActive then
        mainContent[2].Text = "SLOW FLIGHT: ON"
        mainContent[2].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Slow Flight enabled"
        
        flyConnection = RunService.Heartbeat:Connect(function()
            local currentTime = tick()
            if currentTime - lastFlightUpdate < 0.033 then return end
            lastFlightUpdate = currentTime
            
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

-- ========== INFINITE JUMP ==========
local infJumpActive = false
local infJumpConnection

playerContent[1].MouseButton1Click:Connect(function()
    infJumpActive = not infJumpActive
    
    if infJumpActive then
        playerContent[1].Text = "INFINITE JUMP: ON"
        playerContent[1].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
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
        playerContent[1].Text = "INFINITE JUMP: OFF"
        playerContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
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

playerContent[2].MouseButton1Click:Connect(function()
    speedActive = not speedActive
    
    if speedActive then
        playerContent[2].Text = "SPEED BOOSTER: ON"
        playerContent[2].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Speed Booster enabled"
        
        speedConn = RunService.Heartbeat:Connect(function()
            updateCharacterReferences()
            if not hrp or not humanoid then return end
            
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
        playerContent[2].Text = "SPEED BOOSTER: OFF"
        playerContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
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

-- ========== AUTO STEAL ==========
local autoStealActive = false
local autoStealConnection

playerContent[3].MouseButton1Click:Connect(function()
    autoStealActive = not autoStealActive
    
    if autoStealActive then
        playerContent[3].Text = "AUTO STEAL: ON"
        playerContent[3].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Auto Steal enabled"
        
        autoStealConnection = RunService.Heartbeat:Connect(function()
            if not autoStealActive then return end
            updateCharacterReferences()
            if not character or not hrp then return end
            
            for _, item in pairs(Workspace:GetDescendants()) do
                if autoStealActive and item:IsA("Part") then
                    if item.Name:lower():find("brainrot") or item.Name:lower():find("item") then
                        local distance = (hrp.Position - item.Position).Magnitude
                        if distance <= 10 then
                            pcall(function()
                                if firetouchinterest then
                                    firetouchinterest(hrp, item, 0)
                                    task.wait(0.1)
                                    firetouchinterest(hrp, item, 1)
                                end
                            end)
                        end
                    end
                end
            end
        end)
    else
        playerContent[3].Text = "AUTO STEAL: OFF"
        playerContent[3].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Auto Steal disabled"
        
        if autoStealConnection then
            autoStealConnection:Disconnect()
        end
    end
end)

-- ========== FULLBRIGHT ==========
local fullbrightActive = false
local originalBrightness

visualsContent[1].MouseButton1Click:Connect(function()
    fullbrightActive = not fullbrightActive
    
    if fullbrightActive then
        visualsContent[1].Text = "FULLBRIGHT: ON"
        visualsContent[1].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Fullbright enabled"
        
        originalBrightness = Lighting.Brightness
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    else
        visualsContent[1].Text = "FULLBRIGHT: OFF"
        visualsContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Fullbright disabled"
        
        if originalBrightness then
            Lighting.Brightness = originalBrightness
        end
        Lighting.GlobalShadows = true
    end
end)

-- Discord Button
visualsContent[2].MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/YSwFZsGk9j")
        statusLabel.Text = "Discord link copied!"
        visualsContent[2].Text = "✓ COPIED!"
        task.wait(2)
        visualsContent[2].Text = "DISCORD INVITE"
    else
        statusLabel.Text = "Clipboard not supported"
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

-- Auto-cleanup
player.CharacterAdded:Connect(function()
    tweenActive = false
    flyActive = false
    infJumpActive = false
    speedActive = false
    autoStealActive = false
    fullbrightActive = false
    
    mainContent[1].Text = "▶ TWEEN TO BASE"
    mainContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    mainContent[2].Text = "SLOW FLIGHT: OFF"
    mainContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    playerContent[1].Text = "INFINITE JUMP: OFF"
    playerContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    playerContent[2].Text = "SPEED BOOSTER: OFF"
    playerContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    playerContent[3].Text = "AUTO STEAL: OFF"
    playerContent[3].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    visualsContent[1].Text = "FULLBRIGHT: OFF"
    visualsContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    visualsContent[2].Text = "DISCORD INVITE"
    visualsContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    if flyConnection then flyConnection:Disconnect() end
    if infJumpConnection then infJumpConnection:Disconnect() end
    if speedConn then speedConn:Disconnect() end
    if autoStealConnection then autoStealConnection:Disconnect() end
    
    if originalBrightness then
        Lighting.Brightness = originalBrightness
    end
    Lighting.GlobalShadows = true
    
    statusLabel.Text = "Character respawned - Ready"
end)

print("Krypton Hub - Fixed Version Loaded Successfully!")
