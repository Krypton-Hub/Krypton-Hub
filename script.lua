-- Krypton Hub - Complete GUI with ESP, Tween, Float, Auto Floor, Semi-Invisible, Fly
-- Save this as: KryptonHub.lua

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

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "KryptonHubGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 320) -- Increased height for new fly button
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = "Krypton Hub"
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.ZIndex = 2
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- Tab buttons
local tabs = {"Main", "Visuals", "Combat"}
local currentTab = "Main"

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 30)
tabContainer.Position = UDim2.new(0, 0, 0, 25)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local tabButtons = {}
for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Text = tabName
    tabButton.Size = UDim2.new(1/#tabs, 0, 1, 0)
    tabButton.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 11
    tabButton.ZIndex = 2
    tabButton.Parent = tabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 4)
    tabCorner.Parent = tabButton
    
    tabButtons[tabName] = tabButton
end

-- Content frame
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -55)
contentFrame.Position = UDim2.new(0, 0, 0, 55)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Status: Ready"
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 1, -20)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.Parent = mainFrame

-- Main Tab Content
local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1, 0, 1, 0)
mainContent.BackgroundTransparency = 1
mainContent.Visible = true
mainContent.Parent = contentFrame

-- Tween to Base
local tweenButton = Instance.new("TextButton")
tweenButton.Text = "▶ TWEEN TO BASE"
tweenButton.Size = UDim2.new(0.9, 0, 0, 25)
tweenButton.Position = UDim2.new(0.05, 0, 0.05, 0)
tweenButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tweenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tweenButton.Font = Enum.Font.GothamBold
tweenButton.TextSize = 12
tweenButton.Parent = mainContent

local tweenCorner = Instance.new("UICorner")
tweenCorner.CornerRadius = UDim.new(0, 6)
tweenCorner.Parent = tweenButton

-- Speed
local speedContainer = Instance.new("Frame")
speedContainer.Size = UDim2.new(0.9, 0, 0, 25)
speedContainer.Position = UDim2.new(0.05, 0, 0.15, 0)
speedContainer.BackgroundTransparency = 1
speedContainer.Parent = mainContent

local speedLabel = Instance.new("TextLabel")
speedLabel.Text = "Speed:"
speedLabel.Size = UDim2.new(0.5, 0, 1, 0)
speedLabel.Position = UDim2.new(0, 0, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 11
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedContainer

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.4, 0, 1, 0)
speedInput.Position = UDim2.new(0.6, 0, 0, 0)
speedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.Gotham
speedInput.TextSize = 11
speedInput.Text = "24"
speedInput.Parent = speedContainer

local speedInputCorner = Instance.new("UICorner")
speedInputCorner.CornerRadius = UDim.new(0, 4)
speedInputCorner.Parent = speedInput

-- Jump Power
local jumpContainer = Instance.new("Frame")
jumpContainer.Size = UDim2.new(0.9, 0, 0, 25)
jumpContainer.Position = UDim2.new(0.05, 0, 0.25, 0)
jumpContainer.BackgroundTransparency = 1
jumpContainer.Parent = mainContent

local jumpLabel = Instance.new("TextLabel")
jumpLabel.Text = "Jump Power:"
jumpLabel.Size = UDim2.new(0.5, 0, 1, 0)
jumpLabel.Position = UDim2.new(0, 0, 0, 0)
jumpLabel.BackgroundTransparency = 1
jumpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextSize = 11
jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpLabel.Parent = jumpContainer

local jumpInput = Instance.new("TextBox")
jumpInput.Size = UDim2.new(0.4, 0, 1, 0)
jumpInput.Position = UDim2.new(0.6, 0, 0, 0)
jumpInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
jumpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpInput.Font = Enum.Font.Gotham
jumpInput.TextSize = 11
jumpInput.Text = "50"
jumpInput.Parent = jumpContainer

local jumpInputCorner = Instance.new("UICorner")
jumpInputCorner.CornerRadius = UDim.new(0, 4)
jumpInputCorner.Parent = jumpInput

-- Float
local floatButton = Instance.new("TextButton")
floatButton.Text = "FLOAT: OFF"
floatButton.Size = UDim2.new(0.9, 0, 0, 25)
floatButton.Position = UDim2.new(0.05, 0, 0.35, 0)
floatButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
floatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
floatButton.Font = Enum.Font.GothamBold
floatButton.TextSize = 12
floatButton.Parent = mainContent

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(0, 6)
floatCorner.Parent = floatButton

-- Fly
local flyButton = Instance.new("TextButton")
flyButton.Text = "FLY: OFF"
flyButton.Size = UDim2.new(0.9, 0, 0, 25)
flyButton.Position = UDim2.new(0.05, 0, 0.45, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Font = Enum.Font.GothamBold
flyButton.TextSize = 12
flyButton.Parent = mainContent

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 6)
flyCorner.Parent = flyButton

-- Auto Floor
local autoFloorButton = Instance.new("TextButton")
autoFloorButton.Text = "AUTO FLOOR: OFF"
autoFloorButton.Size = UDim2.new(0.9, 0, 0, 25)
autoFloorButton.Position = UDim2.new(0.05, 0, 0.55, 0)
autoFloorButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoFloorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFloorButton.Font = Enum.Font.GothamBold
autoFloorButton.TextSize = 12
autoFloorButton.Parent = mainContent

local autoFloorCorner = Instance.new("UICorner")
autoFloorCorner.CornerRadius = UDim.new(0, 6)
autoFloorCorner.Parent = autoFloorButton

-- Semi Invisible
local semiInvisButton = Instance.new("TextButton")
semiInvisButton.Text = "SEMI INVISIBLE: OFF"
semiInvisButton.Size = UDim2.new(0.9, 0, 0, 25)
semiInvisButton.Position = UDim2.new(0.05, 0, 0.65, 0)
semiInvisButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
semiInvisButton.TextColor3 = Color3.fromRGB(255, 255, 255)
semiInvisButton.Font = Enum.Font.GothamBold
semiInvisButton.TextSize = 12
semiInvisButton.Parent = mainContent

local semiInvisCorner = Instance.new("UICorner")
semiInvisCorner.CornerRadius = UDim.new(0, 6)
semiInvisCorner.Parent = semiInvisButton

-- Visuals Tab Content
local visualsContent = Instance.new("Frame")
visualsContent.Size = UDim2.new(1, 0, 1, 0)
visualsContent.BackgroundTransparency = 1
visualsContent.Visible = false
visualsContent.Parent = contentFrame

-- Player ESP
local espButton = Instance.new("TextButton")
espButton.Text = "PLAYER ESP: OFF"
espButton.Size = UDim2.new(0.9, 0, 0, 30)
espButton.Position = UDim2.new(0.05, 0, 0.05, 0)
espButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.Font = Enum.Font.GothamBold
espButton.TextSize = 12
espButton.Parent = visualsContent

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 6)
espCorner.Parent = espButton

-- Combat Tab Content
local combatContent = Instance.new("Frame")
combatContent.Size = UDim2.new(1, 0, 1, 0)
combatContent.BackgroundTransparency = 1
combatContent.Visible = false
combatContent.Parent = contentFrame

-- Auto Lazer
local autoLazerButton = Instance.new("TextButton")
autoLazerButton.Text = "AUTO LAZER: OFF"
autoLazerButton.Size = UDim2.new(0.9, 0, 0, 30)
autoLazerButton.Position = UDim2.new(0.05, 0, 0.05, 0)
autoLazerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoLazerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoLazerButton.Font = Enum.Font.GothamBold
autoLazerButton.TextSize = 12
autoLazerButton.Parent = combatContent

local autoLazerCorner = Instance.new("UICorner")
autoLazerCorner.CornerRadius = UDim.new(0, 6)
autoLazerCorner.Parent = autoLazerButton

-- Tab switching function
local function switchTab(tabName)
    currentTab = tabName
    mainContent.Visible = (tabName == "Main")
    visualsContent.Visible = (tabName == "Visuals")
    combatContent.Visible = (tabName == "Combat")
    
    for name, button in pairs(tabButtons) do
        if name == tabName then
            button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end

-- Initialize tabs
for tabName, button in pairs(tabButtons) do
    button.MouseButton1Click:Connect(function()
        switchTab(tabName)
    end)
end
switchTab("Main")

-- ========== FLY FEATURE ==========
local flyEnabled = false
local flyBodyVelocity
local flyConnection
local flySpeed = 20 -- Slow fly speed to avoid detection
local maxFlyHeight = 500 -- Safety limit to prevent flying too high

local function toggleFly()
    flyEnabled = not flyEnabled
    
    if flyEnabled then
        flyButton.Text = "FLY: ON"
        flyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        statusLabel.Text = "Fly enabled"
        
        -- Disable other movement features to prevent conflicts
        if floatEnabled then toggleFloat() end
        if floorOn then toggleAutoFloor() end
        
        -- Create BodyVelocity for flying
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = hrp
        
        if flyConnection then
            flyConnection:Disconnect()
        end
        
        flyConnection = RunService.Heartbeat:Connect(function()
            updateCharacterReferences()
            if not flyEnabled or not character or not hrp or not humanoid then
                return
            end
            
            -- Prevent flying too high
            if hrp.Position.Y > maxFlyHeight then
                hrp.Position = Vector3.new(hrp.Position.X, maxFlyHeight, hrp.Position.Z)
            end
            
            -- Get camera direction
            local camera = Workspace.CurrentCamera
            local moveDirection = Vector3.new(0, 0, 0)
            
            -- Input handling for movement
            local forward = UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
            local backward = UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or 0
            local left = UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0
            local right = UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
            local up = UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0
            local down = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and -1 or 0
            
            -- Calculate movement vector
            local camCFrame = camera.CFrame
            local moveVector = Vector3.new(left + right, up + down, forward + backward)
            
            if moveVector.Magnitude > 0 then
                moveVector = moveVector.Unit * flySpeed
                moveDirection = camCFrame:VectorToWorldSpace(moveVector)
            end
            
            -- Apply smooth velocity
            if flyBodyVelocity then
                flyBodyVelocity.Velocity = moveDirection
            end
            
            -- Disable gravity and maintain position when not moving
            humanoid.PlatformStand = true
        end)
        
    else
        flyButton.Text = "FLY: OFF"
        flyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        statusLabel.Text = "Fly disabled"
        
        -- Clean up
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if flyBodyVelocity then
            flyBodyVelocity:Destroy()
            flyBodyVelocity = nil
        end
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

-- [REST OF THE ORIGINAL CODE REMAINS UNCHANGED]
-- I'll include the key modified sections below for brevity

-- Update button connections to include fly
flyButton.MouseButton1Click:Connect(toggleFly)

-- Update cleanup in gui.Destroying
gui.Destroying:Connect(function()
    stopTweenToBase()
    
    -- Clean up auto floor
    if floorConnection then
        floorConnection:Disconnect()
    end
    if floorPart then
        floorPart:Destroy()
    end
    
    -- Clean up float
    if floatConnection then
        floatConnection:Disconnect()
    end
    if floatBodyVelocity then
        floatBodyVelocity:Destroy()
    end
    
    -- Clean up fly
    if flyEnabled then
        toggleFly()
    end
    
    -- Clean up semi invisible
    if isInvisible then
        semiInvisibleFunction()
    end
    
    -- Clean up auto lazer
    if autoLazerEnabled then
        toggleAutoLazer()
    end
    
    -- Clean up ESP
    if espEnabled then
        toggleESP()
    end
end)

print("Krypton Hub loaded successfully!")
print("Features: Tween to Base (Safe), Float, Fly (Slow), Auto Floor (Rising), Semi Invisible, Player ESP, Auto Lazer")
print("Press F to toggle Semi Invisible")
