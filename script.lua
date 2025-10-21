-- Krypton Hub - Fixed Version
-- Made by agent_duke13

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local PathfindingService = game:GetService("PathfindingService")

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

-- Old style toggle button
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "KryptonToggle"
toggleGui.ResetOnSpawn = false
toggleGui.Parent = player:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 80, 0, 35)
toggleButton.Position = UDim2.new(0, 10, 0.5, -17)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
toggleButton.Text = "Krypton"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Active = true
toggleButton.Draggable = true
toggleButton.Parent = toggleGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0.2, 0)
uiCorner.Parent = toggleButton

-- Main GUI (Shorter)
local gui = Instance.new("ScreenGui")
gui.Name = "KryptonHubGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
gui.Enabled = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 320)  -- Shorter height
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

-- Content Area (Shorter)
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -110)  -- Adjusted for shorter GUI
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
contentLayout.Padding = UDim.new(0, 6)  -- Less padding for shorter GUI
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
    button.Size = UDim2.new(1, 0, 0, 32)  -- Smaller buttons
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
    toggle.Size = UDim2.new(1, 0, 0, 32)  -- Smaller toggles
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

-- Tab Contents (Removed Noclip)
local mainContent = {}
local playerContent = {}
local visualsContent = {}

-- MAIN TAB (Only 3 features now)
table.insert(mainContent, createToggle("▶ TWEEN TO BASE", 1))
table.insert(mainContent, createToggle("FLIGHT: OFF", 2))
table.insert(mainContent, createToggle("FLOAT: OFF", 3))

-- PLAYER TAB
table.insert(playerContent, createToggle("SEMI INVISIBLE: OFF", 1))
table.insert(playerContent, createToggle("INFINITE JUMP: OFF", 2))
table.insert(playerContent, createToggle("SPEED BOOST: OFF", 3))

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

-- ========== FIXED FEATURE IMPLEMENTATIONS ==========

-- Improved Tween to Base (Less Glitchy)
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
            statusLabel.Text = "Finding path to base..."
            
            spawn(function()
                updateCharacterReferences()
                if not hrp or not humanoid then 
                    statusLabel.Text = "No character found"
                    tweenActive = false
                    mainContent[1].Text = "▶ TWEEN TO BASE"
                    mainContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                    return 
                end
                
                local targetPos = Vector3.new(basePos.X, basePos.Y + 3, basePos.Z)
                
                -- Use pathfinding for better path
                local path = PathfindingService:CreatePath({
                    AgentRadius = 2,
                    AgentHeight = 5,
                    AgentCanJump = true
                })
                
                local success, error = pcall(function()
                    path:ComputeAsync(hrp.Position, targetPos)
                end)
                
                if success and path.Status == Enum.PathStatus.Success then
                    local waypoints = path:GetWaypoints()
                    statusLabel.Text = "Following path (" .. #waypoints .. " points)"
                    
                    for i, waypoint in ipairs(waypoints) do
                        if not tweenActive or not hrp then break end
                        
                        if i > 1 then -- Skip first waypoint (current position)
                            local waypointPos = waypoint.Position
                            local distance = (waypointPos - hrp.Position).Magnitude
                            
                            if distance > 5 then
                                local duration = distance / 20 -- Slower speed for less glitching
                                
                                currentTween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                                    CFrame = CFrame.new(waypointPos)
                                })
                                
                                humanoid:ChangeState(Enum.HumanoidStateType.Running)
                                currentTween:Play()
                                currentTween.Completed:Wait()
                            end
                        end
                        
                        -- Check if we're close enough to base
                        local baseDistance = (targetPos - hrp.Position).Magnitude
                        if baseDistance <= 15 then
                            statusLabel.Text = "Reached base!"
                            break
                        end
                        
                        task.wait(0.1)
                    end
                else
                    -- Fallback to direct tween if pathfinding fails
                    statusLabel.Text = "Direct tween to base"
                    local distance = (targetPos - hrp.Position).Magnitude
                    local duration = distance / 25
                    
                    currentTween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
                        CFrame = CFrame.new(targetPos)
                    })
                    
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    currentTween:Play()
                    currentTween.Completed:Wait()
                end
                
                statusLabel.Text = "Reached base!"
                tweenActive = false
                mainContent[1].Text = "▶ TWEEN TO BASE"
                mainContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
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
        mainContent[2].Text = "FLIGHT: ON"
        mainContent[2].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Flight enabled - Use WASD"
        
        flyConnection = RunService.Heartbeat:Connect(function()
            updateCharacterReferences()
            if hrp and flyActive then
                local cam = Workspace.CurrentCamera
                local moveDirection = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - cam.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - cam.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + cam.CFrame.RightVector
                end
                
                if moveDirection.Magnitude > 0 then
                    hrp.Velocity = moveDirection.Unit * 50
                else
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                end
            end
        end)
    else
        mainContent[2].Text = "FLIGHT: OFF"
        mainContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Flight disabled"
        
        if flyConnection then
            flyConnection:Disconnect()
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
            floatBodyVelocity.Velocity = Vector3.new(0, 25, 0)  -- Slower float
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

-- ========== FIXED SEMI INVISIBLE (No Lag Back) ==========
local semiInvisActive = false
local semiInvisConnections = {}

local function cleanupSemiInvisible()
    for _, conn in ipairs(semiInvisConnections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    semiInvisConnections = {}
end

playerContent[1].MouseButton1Click:Connect(function()
    semiInvisActive = not semiInvisActive
    
    if semiInvisActive then
        -- Enable Semi-Invisible with Anti-Death
        playerContent[1].Text = "SEMI INVISIBLE: ON"
        playerContent[1].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Semi-Invisible & Anti-Death enabled"
        
        updateCharacterReferences()
        if not character or not humanoid or humanoid.Health <= 0 then
            statusLabel.Text = "Cannot enable: No character or dead"
            return
        end
        
        -- Clean up first
        cleanupSemiInvisible()
        
        -- Store current position to prevent lag back
        local currentPosition = hrp.Position
        
        -- Setup Anti-Death protection
        local antiDeathConnection = humanoid.HealthChanged:Connect(function()
            if humanoid and humanoid.Health <= 0 then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
        table.insert(semiInvisConnections, antiDeathConnection)
        
        -- Make character transparent
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.8
            end
        end
        
        -- Prevent lag back by updating position continuously
        local positionConn = RunService.Heartbeat:Connect(function()
            if hrp and semiInvisActive then
                -- Keep updating the actual position to prevent lag back
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end)
        table.insert(semiInvisConnections, positionConn)

        -- Character added connection
        local charConn = player.CharacterAdded:Connect(function(newChar)
            if semiInvisActive then
                cleanupSemiInvisible()
                semiInvisActive = false
                playerContent[1].Text = "SEMI INVISIBLE: OFF"
                playerContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                statusLabel.Text = "Semi-Invisible reset (new character)"
            end
        end)
        table.insert(semiInvisConnections, charConn)
        
    else
        -- Disable Semi-Invisible and Anti-Death
        playerContent[1].Text = "SEMI INVISIBLE: OFF"
        playerContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Semi-Invisible & Anti-Death disabled"
        
        cleanupSemiInvisible()
        
        -- Restore visibility
        updateCharacterReferences()
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
        end
    end
end)

-- ========== FIXED INFINITE JUMP (No Death) ==========
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
                -- Safe jump without causing death
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                
                -- Add gentle upward force instead of instant teleport
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

-- Speed Boost
local speedBoostActive = false
local originalWalkSpeed = 16

playerContent[3].MouseButton1Click:Connect(function()
    speedBoostActive = not speedBoostActive
    
    if speedBoostActive then
        playerContent[3].Text = "SPEED BOOST: ON"
        playerContent[3].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Speed Boost enabled"
        
        updateCharacterReferences()
        if humanoid then
            originalWalkSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = 50
        end
    else
        playerContent[3].Text = "SPEED BOOST: OFF"
        playerContent[3].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Speed Boost disabled"
        
        if humanoid then
            humanoid.WalkSpeed = originalWalkSpeed
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

-- Toggle Button (Old Style)
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

-- Mobile support
toggleButton.TouchTap:Connect(function()
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
    semiInvisActive = false
    infJumpActive = false
    speedBoostActive = false
    espActive = false
    fullbrightActive = false
    
    -- Reset buttons
    mainContent[1].Text = "▶ TWEEN TO BASE"
    mainContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    mainContent[2].Text = "FLIGHT: OFF"
    mainContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    mainContent[3].Text = "FLOAT: OFF"
    mainContent[3].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    playerContent[1].Text = "SEMI INVISIBLE: OFF"
    playerContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    playerContent[2].Text = "INFINITE JUMP: OFF"
    playerContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    playerContent[3].Text = "SPEED BOOST: OFF"
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
    
    -- Clean up semi-invisible
    cleanupSemiInvisible()
    
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

print("Krypton Hub v2.1 - Fixed Version Loaded!")
print("Fixed: Removed Noclip, Fixed Infinite Jump death, Fixed Semi-Invisible lag back, Better toggle button, Less glitchy tween")
print("Discord: https://discord.gg/YSwFZsGk9j")
