-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Configuration
local config = {
    walkSpeed = 50,
    flySpeed = 25,
    floatVelocity = 25,
    floatMaxForce = 50000,
    animationId = "http://www.roblox.com/asset/?id=18537363391",
    characterLoadTimeout = 30 -- seconds
}

-- Error Logging
local function logError(message)
    warn("[Krypton Hub Error]: " .. message)
    if statusLabel then
        statusLabel.Text = "Error: " .. message
    end
end

-- Loading Screen
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "KryptonLoader"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundTransparency = 1

local bg = Instance.new("Frame", frame)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
bg.BackgroundTransparency = 1
bg.ZIndex = 0
TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()

local word = "KRYPTON"
local letters = {}

local function tweenOutAndDestroy()
    for _, label in ipairs(letters) do
        TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1, TextSize = 20}):Play()
    end
    TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()
    task.wait(0.6)
    screenGui:Destroy()
    blur:Destroy()
end

for i = 1, #word do
    local char = word:sub(i, i)
    local label = Instance.new("TextLabel")
    label.Text = char
    label.Font = Enum.Font.GothamBlack
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 1
    label.TextTransparency = 1
    label.TextScaled = false
    label.TextSize = 30
    label.Size = UDim2.new(0, 60, 0, 60)
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.Position = UDim2.new(0.5, (i - (#word / 2 + 0.5)) * 65, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 170, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 160))
    })
    gradient.Rotation = 90
    gradient.Parent = label

    local tweenIn = TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 0, TextSize = 60})
    tweenIn:Play()
    table.insert(letters, label)
    task.wait(0.25)
end
task.wait(2)
tweenOutAndDestroy()

-- Wait for game and player to load
local startTime = tick()
repeat
    task.wait()
    if tick() - startTime > config.characterLoadTimeout then
        logError("Timeout waiting for player or character to load")
        break
    end
until player and player.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Global Variables
local character, hrp, humanoid
local connections = {
    ProximityPrompts = {},
    SemiInvisible = {},
    GodModeToggle = {},
    Fly = nil,
    Float = nil,
    Jump = nil,
    Speed = nil,
    ESP = nil,
    Fullbright = nil
}
local espFolders = {}
local tweenActive = false
local flyActive = false
local floatActive = false
local isInvisible = false
local infJumpActive = false
local speedActive = false
local espActive = false
local fullbrightActive = false
local godModeToggle = false
local ipp = false
local pp = {} -- Proximity prompts
local originalBrightness, originalClockTime
local statusLabel -- Will be set later

-- Update Character References
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
    updateCharacterReferences()
end)

-- Global Godmode Protection
local function setupGlobalGodmode()
    local mt = getrawmetatable(game)
    if not mt then
        logError("Failed to get game metatable")
        return
    end
    local oldNC = mt.__namecall
    local oldNI = mt.__newindex
    
    if not oldNC or not oldNI then
        logError("Metatable methods not found")
        return
    end

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
if humanoid then
    setupGlobalGodmode()
end
player.CharacterAdded:Connect(function()
    updateCharacterReferences()
    if humanoid then
        setupGlobalGodmode()
    end
end)

-- Toggle Button
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "KryptonToggle"
toggleGui.ResetOnSpawn = false
toggleGui.Parent = player:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 20, 0.5, -30)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
toggleButton.BackgroundTransparency = 0.3
toggleButton.Text = ""
toggleButton.Image = "rbxassetid://95131705390407" -- Updated logo
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
local tabs = {"Main", "Player", "Shop", "Visuals"}
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

statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Status: Ready"
statusLabel.Size = UDim2.new(1, -10, 1, 0)
statusLabel.Position = UDim2.new(0, 5, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusBar

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

-- Tab Contents
local mainContent = {}
local playerContent = {}
local shopContent = {}
local visualsContent = {}

-- MAIN TAB
table.insert(mainContent, createToggle("▶ TWEEN TO BASE", 1))
table.insert(mainContent, createToggle("SLOW FLIGHT: OFF", 2))
table.insert(mainContent, createToggle("FLOAT: OFF", 3))
table.insert(mainContent, createToggle("INSTANT PROXIMITY: OFF", 4))

-- PLAYER TAB
table.insert(playerContent, createToggle("SEMI INVISIBLE: OFF", 1))
table.insert(playerContent, createToggle("INFINITE JUMP: OFF", 2))
table.insert(playerContent, createToggle("SPEED BOOSTER: OFF", 3))
table.insert(playerContent, createToggle("GOD MODE: OFF", 4))
table.insert(playerContent, createToggle("WALKSPEED (50): OFF", 5))

-- SHOP TAB
table.insert(shopContent, createButton("SHOP DROPDOWN", 1))

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
for _, button in ipairs(shopContent) do
    button.Visible = false
end
for _, button in ipairs(visualsContent) do
    button.Visible = false
end

-- Tab System
local function switchTab(tabName)
    currentTab = tabName
    
    for _, button in ipairs(mainContent) do
        button.Visible = false
    end
    for _, button in ipairs(playerContent) do
        button.Visible = false
    end
    for _, button in ipairs(shopContent) do
        button.Visible = false
    end
    for _, button in ipairs(visualsContent) do
        button.Visible = false
    end
    
    if tabName == "Main" then
        for _, button in ipairs(mainContent) do
            button.Visible = true
        end
    elseif tabName == "Player" then
        for _, button in ipairs(playerContent) do
            button.Visible = true
        end
    elseif tabName == "Shop" then
        for _, button in ipairs(shopContent) do
            button.Visible = true
        end
    elseif tabName == "Visuals" then
        for _, button in ipairs(visualsContent) do
            button.Visible = true
        end
    end
    
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

-- Toggle GUI
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

-- Proximity Prompts
local function cleanupProximityConnections()
    for _, connection in pairs(connections.ProximityPrompts) do
        connection:Disconnect()
    end
    connections.ProximityPrompts = {}
end

local function dop(p)
    if p and p:FindFirstChild("Base") and p.Base:FindFirstChild("Spawn") and p.Base.Spawn:FindFirstChild("PromptAttachment") then
        local promptAttachment = p.Base.Spawn.PromptAttachment
        if promptAttachment:FindFirstChild("ProximityPrompt") then
            local c = promptAttachment.ProximityPrompt
            table.insert(pp, c)
            if ipp then
                c.HoldDuration = 0
                table.insert(connections.ProximityPrompts, c:GetPropertyChangedSignal("HoldDuration"):Connect(function()
                    if c.HoldDuration ~= 0 and ipp then
                        c.HoldDuration = 0
                    end
                end))
            end
        end
        table.insert(connections.ProximityPrompts, promptAttachment.ChildAdded:Connect(function(c)
            if c:IsA("ProximityPrompt") then
                table.insert(pp, c)
                if ipp then
                    c.HoldDuration = 0
                end
                table.insert(connections.ProximityPrompts, c:GetPropertyChangedSignal("HoldDuration"):Connect(function()
                    if c.HoldDuration ~= 0 and ipp then
                        c.HoldDuration = 0
                    end
                end))
            end
        end))
    end
end

for _, plot in pairs(Workspace:WaitForChild("Plots"):GetChildren()) do
    if plot:FindFirstChild("AnimalPodiums") then
        for _, podium in pairs(plot.AnimalPodiums:GetChildren()) do
            dop(podium)
        end
        table.insert(connections.ProximityPrompts, plot.AnimalPodiums.ChildAdded:Connect(dop))
    end
end

mainContent[4].MouseButton1Click:Connect(function()
    ipp = not ipp
    mainContent[4].Text = ipp and "INSTANT PROXIMITY: ON" or "INSTANT PROXIMITY: OFF"
    mainContent[4].BackgroundColor3 = ipp and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 70)
    statusLabel.Text = ipp and "Instant Proximity enabled" or "Instant Proximity disabled"
    if ipp then
        for _, v in pairs(pp) do
            v.HoldDuration = 0
        end
    end
end)

-- Tween to Base
mainContent[1].MouseButton1Click:Connect(function()
    if tweenActive then
        tweenActive = false
        mainContent[1].Text = "▶ TWEEN TO BASE"
        mainContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Tween stopped"
    else
        local base = nil
        for _, v in pairs(Workspace:WaitForChild("Plots"):GetChildren()) do
            local yourBase = v:FindFirstChild("YourBase", true)
            if yourBase and yourBase.Enabled then
                base = v:FindFirstChild("DeliveryHitbox", true)
                break
            end
        end
        if base and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            tweenActive = true
            mainContent[1].Text = "■ STOP TWEEN"
            mainContent[1].BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            statusLabel.Text = "Tweening to base..."
            
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid
            local plrpos = hrp.Position
            local tppos = Vector3.new(base.Position.X, plrpos.Y, base.Position.Z)
            local tweenInfo = TweenInfo.new(
                (tppos - plrpos).Magnitude / humanoid.WalkSpeed,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.Out
            )
            local tween = TweenService:Create(hrp, tweenInfo, {
                CFrame = CFrame.new(tppos) * (hrp.CFrame - plrpos),
                Velocity = Vector3.new(0, 0, 0)
            })
            tween:Play()
            tween.Completed:Connect(function()
                tweenActive = false
                mainContent[1].Text = "▶ TWEEN TO BASE"
                mainContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                statusLabel.Text = "Reached base"
            end)
        else
            logError("Base or character components not found")
        end
    end
end)

-- Slow Flight
mainContent[2].MouseButton1Click:Connect(function()
    flyActive = not flyActive
    if flyActive then
        mainContent[2].Text = "SLOW FLIGHT: ON"
        mainContent[2].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Slow Flight enabled - Use camera direction"
        connections.Fly = RunService.Stepped:Connect(function()
            updateCharacterReferences()
            if flyActive and hrp then
                hrp.Velocity = Workspace.CurrentCamera.CFrame.LookVector * config.flySpeed
            end
        end)
    else
        mainContent[2].Text = "SLOW FLIGHT: OFF"
        mainContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Slow Flight disabled"
        if connections.Fly then
            connections.Fly:Disconnect()
            connections.Fly = nil
        end
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

-- Float
mainContent[3].MouseButton1Click:Connect(function()
    floatActive = not floatActive
    if floatActive then
        mainContent[3].Text = "FLOAT: ON"
        mainContent[3].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Float enabled"
        updateCharacterReferences()
        if hrp then
            setupGlobalGodmode()
            connections.Float = Instance.new("BodyVelocity")
            connections.Float.Velocity = Vector3.new(0, config.floatVelocity, 0)
            connections.Float.MaxForce = Vector3.new(0, config.floatMaxForce, 0)
            connections.Float.Parent = hrp
        else
            logError("HumanoidRootPart not found for Float")
        end
    else
        mainContent[3].Text = "FLOAT: OFF"
        mainContent[3].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Float disabled"
        if connections.Float then
            connections.Float:Destroy()
            connections.Float = nil
        end
    end
end)

-- Semi-Invisible
local function semiInvisibleFunction()
    local DEPTH_OFFSET = 0.15
    local clone, oldRoot, hip, animTrack, connection, characterConnection

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
        table.insert(connections.SemiInvisible, childAddedConn)
    end

    local function doClone()
        if character and humanoid and humanoid.Health > 0 then
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

    local function animationTrickery()
        if character and humanoid and humanoid.Health > 0 then
            local anim = Instance.new("Animation")
            anim.AnimationId = config.animationId
            local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
            local success, loadedAnimTrack = pcall(function()
                return animator:LoadAnimation(anim)
            end)
            if success then
                animTrack = loadedAnimTrack
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
            else
                logError("Failed to load animation for semi-invisible")
            end
        end
    end

    local function enableInvisibility()
        if not character or humanoid.Health <= 0 then return false end
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
        setupGlobalGodmode()
        if enableInvisibility() then
            isInvisible = true
            playerContent[1].Text = "SEMI INVISIBLE: ON"
            playerContent[1].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            statusLabel.Text = "Semi-Invisible enabled (F key to toggle)"
        end
    else
        disableInvisibility()
        isInvisible = false
        playerContent[1].Text = "SEMI INVISIBLE: OFF"
        playerContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "Semi-Invisible disabled"
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

playerContent[1].MouseButton1Click:Connect(semiInvisibleFunction)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F and not gameProcessed then
        semiInvisibleFunction()
    end
end)

-- Infinite Jump
playerContent[2].MouseButton1Click:Connect(function()
    infJumpActive = not infJumpActive
    if infJumpActive then
        playerContent[2].Text = "INFINITE JUMP: ON"
        playerContent[2].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Infinite Jump enabled"
        connections.Jump = UserInputService.JumpRequest:Connect(function()
            if infJumpActive and humanoid and humanoid.Health > 0 then
                setupGlobalGodmode()
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
        if connections.Jump then
            connections.Jump:Disconnect()
            connections.Jump = nil
        end
    end
end)

-- Speed Booster
local baseSpeed = config.walkSpeed
playerContent[3].MouseButton1Click:Connect(function()
    speedActive = not speedActive
    if speedActive then
        playerContent[3].Text = "SPEED BOOSTER: ON"
        playerContent[3].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Speed Booster enabled"
        local function GetCharacter()
            local Char = player.Character or player.CharacterAdded:Wait()
            local HRP = Char and Char:WaitForChild("HumanoidRootPart")
            local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
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
        connections.Speed = RunService.Stepped:Connect(function()
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
        if connections.Speed then
            connections.Speed:Disconnect()
            connections.Speed = nil
        end
        updateCharacterReferences()
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
        end
    end
end)

-- God Mode (Toggle)
local function enableGodMode()
    local function apply(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        humanoid.BreakJointsOnDeath = false
        humanoid.RequiresNeck = false
        for _, connection in ipairs(getconnections(humanoid.Died)) do
            connection:Disable()
            table.insert(connections.GodModeToggle, connection)
        end
        table.insert(connections.GodModeToggle, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end))
        connections.GodModeToggle.Heartbeat = RunService.Heartbeat:Connect(function()
            if humanoid and humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end
    apply(player.Character or player.CharacterAdded:Wait())
    table.insert(connections.GodModeToggle, player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        apply(character)
    end))
end

local function disableGodMode()
    for _, connection in ipairs(connections.GodModeToggle) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    connections.GodModeToggle = {}
    if connections.GodModeToggle.Heartbeat then
        connections.GodModeToggle.Heartbeat:Disconnect()
        connections.GodModeToggle.Heartbeat = nil
    end
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.BreakJointsOnDeath = true
        humanoid.RequiresNeck = true
    end
end

playerContent[4].MouseButton1Click:Connect(function()
    godModeToggle = not godModeToggle
    if godModeToggle then
        playerContent[4].Text = "GOD MODE: ON"
        playerContent[4].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "God Mode enabled"
        enableGodMode()
    else
        playerContent[4].Text = "GOD MODE: OFF"
        playerContent[4].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "God Mode disabled"
        disableGodMode()
    end
end)

-- WalkSpeed
local walkSpeedToggle = false
local HumanModCons = {}
local function setWalkSpeed(speed)
    if typeof(speed) == "number" then
        local Char = player.Character or Workspace:FindFirstChild(player.Name)
        local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
        local function WalkSpeedChange()
            if Char and Human then
                Human.WalkSpeed = speed
            end
        end
        WalkSpeedChange()
        if HumanModCons.wsLoop then
            HumanModCons.wsLoop:Disconnect()
        end
        if HumanModCons.wsCA then
            HumanModCons.wsCA:Disconnect()
        end
        if Human then
            HumanModCons.wsLoop = Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
        end
        HumanModCons.wsCA = player.CharacterAdded:Connect(function(nChar)
            Char, Human = nChar, nChar:WaitForChild("Humanoid")
            WalkSpeedChange()
            HumanModCons.wsLoop = Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
        end)
    end
end

playerContent[5].MouseButton1Click:Connect(function()
    walkSpeedToggle = not walkSpeedToggle
    if walkSpeedToggle then
        playerContent[5].Text = "WALKSPEED (50): ON"
        playerContent[5].BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "WalkSpeed enabled"
        setWalkSpeed(config.walkSpeed)
    else
        playerContent[5].Text = "WALKSPEED (50): OFF"
        playerContent[5].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        statusLabel.Text = "WalkSpeed disabled"
        setWalkSpeed(16)
        if HumanModCons.wsLoop then
            HumanModCons.wsLoop:Disconnect()
            HumanModCons.wsLoop = nil
        end
        if HumanModCons.wsCA then
            HumanModCons.wsCA:Disconnect()
            HumanModCons.wsCA = nil
        end
    end
end)

-- Shop Dropdown
do
    local allItems = {
        {Name = "Slap", ID = "Basic Slap"},
        {Name = "Iron Slap", ID = "Iron Slap"},
        {Name = "Gold Slap", ID = "Gold Slap"},
        {Name = "Diamond Slap", ID = "Diamond Slap"},
        {Name = "Emerald Slap", ID = "Emerald Slap"},
        {Name = "Ruby Slap", ID = "Ruby Slap"},
        {Name = "Dark Matter Slap", ID = "Dark Matter Slap"},
        {Name = "Flame Slap", ID = "Flame Slap"},
        {Name = "Nuclear Slap", ID = "Nuclear Slap"},
        {Name = "Galaxy Slap", ID = "Galaxy Slap"},
        {Name = "Trap", ID = "Trap"},
        {Name = "Bee Launcher", ID = "Bee Launcher"},
        {Name = "Rage Table", ID = "Rage Table"},
        {Name = "Grapple Hook", ID = "Grapple Hook"},
        {Name = "Taser Gun", ID = "Taser Gun"},
        {Name = "Boogie Bomb", ID = "Boogie Bomb"},
        {Name = "Medusa's Head", ID = "Medusa's Head"},
        {Name = "Web Slinger", ID = "Web Slinger"},
        {Name = "Quantum Cloner", ID = "Quantum Cloner"},
        {Name = "All Seeing Sentry", ID = "All Seeing Sentry"},
        {Name = "Laser Cape", ID = "Laser Cape"},
        {Name = "Speed Coil", ID = "Speed Coil"},
        {Name = "Gravity Coil", ID = "Gravity Coil"},
        {Name = "Coil Combo", ID = "Coil Combo"},
        {Name = "Invisibility Cloak", ID = "Invisibility Cloak"}
    }

    local dropdownOptions = {}
    for _, item in pairs(allItems) do
        table.insert(dropdownOptions, item.Name)
    end

    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, 0, 0, 32)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    dropdownFrame.LayoutOrder = 1
    dropdownFrame.Parent = contentScrolling

    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0.08, 0)
    dropdownCorner.Parent = dropdownFrame

    local dropdown = Instance.new("TextButton")
    dropdown.Text = "Select Item to Purchase"
    dropdown.Size = UDim2.new(1, -10, 1, 0)
    dropdown.Position = UDim2.new(0, 5, 0, 0)
    dropdown.BackgroundTransparency = 1
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.Font = Enum.Font.GothamSemibold
    dropdown.TextSize = 12
    dropdown.TextXAlignment = Enum.TextXAlignment.Left
    dropdown.Parent = dropdownFrame

    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(1, 0, 0, 100)
    dropdownList.Position = UDim2.new(0, 0, 1, 5)
    dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    dropdownList.Visible = false
    dropdownList.Parent = dropdownFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = dropdownList

    local dropdownOptionsButtons = {}
    for i, option in ipairs(dropdownOptions) do
        local optionButton = Instance.new("TextButton")
        optionButton.Text = option
        optionButton.Size = UDim2.new(1, 0, 0, 20)
        optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionButton.Font = Enum.Font.Gotham
        optionButton.TextSize = 12
        optionButton.LayoutOrder = i
        optionButton.Parent = dropdownList
        dropdownOptionsButtons[option] = optionButton
    end

    dropdown.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
    end)

    for _, option in ipairs(dropdownOptions) do
        dropdownOptionsButtons[option].MouseButton1Click:Connect(function()
            dropdown.Text = option
            dropdownList.Visible = false
            for _, item in pairs(allItems) do
                if option == item.Name then
                    local success, err = pcall(function()
                        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/CoinsShopService/RequestBuy")
                        if remote then
                            local result = remote:InvokeServer(item.ID)
                            return result
                        else
                            error("Shop remote not found")
                        end
                    end)
                    statusLabel.Text = success and ("Tried to buy: " .. item.Name .. " (Success)") or ("Error buying " .. item.Name .. ": " .. tostring(err))
                end
            end
        end)
    end

    shopContent[1].MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
    end)
end

-- ESP
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
            if folder then folder:Destroy() end
        end
        espFolders = {}
    end
end)

Players.PlayerRemoving:Connect(function(otherPlayer)
    if espFolders[otherPlayer] then
        espFolders[otherPlayer]:Destroy()
        espFolders[otherPlayer] = nil
    end
end)

-- Fullbright
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
        setclipboard("https://discord.gg/jXSyQFnQCY")
        statusLabel.Text = "Discord link copied to clipboard!"
        visualsContent[3].Text = "✓ COPIED!"
        task.wait(2)
        visualsContent[3].Text = "DISCORD INVITE"
    else
        statusLabel.Text = "Clipboard not supported on this device"
    end
end)

-- Auto-cleanup on character death
player.CharacterAdded:Connect(function()
    tweenActive = false
    flyActive = false
    floatActive = false
    isInvisible = false
    infJumpActive = false
    speedActive = false
    espActive = false
    fullbrightActive = false
    godModeToggle = false
    ipp = false

    mainContent[1].Text = "▶ TWEEN TO BASE"
    mainContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    mainContent[2].Text = "SLOW FLIGHT: OFF"
    mainContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    mainContent[3].Text = "FLOAT: OFF"
    mainContent[3].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    mainContent[4].Text = "INSTANT PROXIMITY: OFF"
    mainContent[4].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    playerContent[1].Text = "SEMI INVISIBLE: OFF"
    playerContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    playerContent[2].Text = "INFINITE JUMP: OFF"
    playerContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    playerContent[3].Text = "SPEED BOOSTER: OFF"
    playerContent[3].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    playerContent[4].Text = "GOD MODE: OFF"
    playerContent[4].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    playerContent[5].Text = "WALKSPEED (50): OFF"
    playerContent[5].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    visualsContent[1].Text = "PLAYER ESP: OFF"
    visualsContent[1].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    visualsContent[2].Text = "FULLBRIGHT: OFF"
    visualsContent[2].BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    visualsContent[3].Text = "DISCORD INVITE"

    if connections.Fly then connections.Fly:Disconnect() end
    if connections.Float then connections.Float:Destroy() end
    if connections.Jump then connections.Jump:Disconnect() end
    if connections.Speed then connections.Speed:Disconnect() end
    for _, conn in ipairs(connections.SemiInvisible) do
        if conn then conn:Disconnect() end
    end
    connections.SemiInvisible = {}
    for _, conn in ipairs(connections.GodModeToggle) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    connections.GodModeToggle = {}
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
    for _, v in pairs(pp) do
        v.HoldDuration = 0.5
    end
    statusLabel.Text = "Character respawned - Ready"
end)

-- Cleanup on Script End
game:BindToClose(function()
    for key, connection in pairs(connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        elseif typeof(connection) == "Instance" then
            connection:Destroy()
        elseif type(connection) == "table" then
            for _, conn in ipairs(connection) do
                if typeof(conn) == "RBXScriptConnection" then
                    conn:Disconnect()
                end
            end
        end
    end
    connections = {
        ProximityPrompts = {},
        SemiInvisible = {},
        GodModeToggle = {},
        Fly = nil,
        Float = nil,
        Jump = nil,
        Speed = nil,
        ESP = nil,
        Fullbright = nil
    }
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
end)

print("Krypton Hub - Complete Edition Loaded!")
print("Features: Tween to Base, Slow Flight, Float, Semi-Invisible, Infinite Jump, Speed Booster, God Mode, WalkSpeed, ESP, Fullbright, Instant Proximity, Shop")
print("Controls: F key to toggle semi-invisible, Circle button to open GUI")
print("Discord: https://discord.gg/jXSyQFnQCY")
