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

-- GUI Setup with tabs
local gui = Instance.new("ScreenGui")
gui.Name = "RxyalsScriptsGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 200, 0, 250)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", mainFrame)
title.Text = "Rxyals Scripts"
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.ZIndex = 2
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

-- Tab buttons
local tabs = {"Main", "Visuals", "Combat"}
local currentTab = "Main"

local tabContainer = Instance.new("Frame", mainFrame)
tabContainer.Size = UDim2.new(1, 0, 0, 30)
tabContainer.Position = UDim2.new(0, 0, 0, 25)
tabContainer.BackgroundTransparency = 1

local tabButtons = {}
for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton", tabContainer)
    tabButton.Text = tabName
    tabButton.Size = UDim2.new(1/#tabs, 0, 1, 0)
    tabButton.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 11
    tabButton.ZIndex = 2
    Instance.new("UICorner", tabButton).CornerRadius = UDim.new(0, 4)
    tabButtons[tabName] = tabButton
end

-- Content frame
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -55)
contentFrame.Position = UDim2.new(0, 0, 0, 55)
contentFrame.BackgroundTransparency = 1

-- Status label
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Text = "Status: Ready"
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 1, -20)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10

-- Main Tab Content
local mainContent = Instance.new("Frame", contentFrame)
mainContent.Size = UDim2.new(1, 0, 1, 0)
mainContent.BackgroundTransparency = 1
mainContent.Visible = true

-- Tween to Base
local tweenButton = Instance.new("TextButton", mainContent)
tweenButton.Text = "▶ TWEEN TO BASE"
tweenButton.Size = UDim2.new(0.9, 0, 0, 30)
tweenButton.Position = UDim2.new(0.05, 0, 0.05, 0)
tweenButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tweenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tweenButton.Font = Enum.Font.GothamBold
tweenButton.TextSize = 12
Instance.new("UICorner", tweenButton).CornerRadius = UDim.new(0, 6)

-- Speed
local speedContainer = Instance.new("Frame", mainContent)
speedContainer.Size = UDim2.new(0.9, 0, 0, 25)
speedContainer.Position = UDim2.new(0.05, 0, 0.20, 0)
speedContainer.BackgroundTransparency = 1

local speedLabel = Instance.new("TextLabel", speedContainer)
speedLabel.Text = "Speed:"
speedLabel.Size = UDim2.new(0.5, 0, 1, 0)
speedLabel.Position = UDim2.new(0, 0, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 11
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedInput = Instance.new("TextBox", speedContainer)
speedInput.Size = UDim2.new(0.4, 0, 1, 0)
speedInput.Position = UDim2.new(0.6, 0, 0, 0)
speedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.Gotham
speedInput.TextSize = 11
speedInput.Text = "35"
Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 4)

-- Jump Power
local jumpContainer = Instance.new("Frame", mainContent)
jumpContainer.Size = UDim2.new(0.9, 0, 0, 25)
jumpContainer.Position = UDim2.new(0.05, 0, 0.30, 0)
jumpContainer.BackgroundTransparency = 1

local jumpLabel = Instance.new("TextLabel", jumpContainer)
jumpLabel.Text = "Jump Power:"
jumpLabel.Size = UDim2.new(0.5, 0, 1, 0)
jumpLabel.Position = UDim2.new(0, 0, 0, 0)
jumpLabel.BackgroundTransparency = 1
jumpLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextSize = 11
jumpLabel.TextXAlignment = Enum.TextXAlignment.Left

local jumpInput = Instance.new("TextBox", jumpContainer)
jumpInput.Size = UDim2.new(0.4, 0, 1, 0)
jumpInput.Position = UDim2.new(0.6, 0, 0, 0)
jumpInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
jumpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpInput.Font = Enum.Font.Gotham
jumpInput.TextSize = 11
jumpInput.Text = "50"
Instance.new("UICorner", jumpInput).CornerRadius = UDim.new(0, 4)

-- Float
local floatButton = Instance.new("TextButton", mainContent)
floatButton.Text = "FLOAT: OFF"
floatButton.Size = UDim2.new(0.9, 0, 0, 25)
floatButton.Position = UDim2.new(0.05, 0, 0.45, 0)
floatButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
floatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
floatButton.Font = Enum.Font.GothamBold
floatButton.TextSize = 12
Instance.new("UICorner", floatButton).CornerRadius = UDim.new(0, 6)

-- Auto Floor
local autoFloorButton = Instance.new("TextButton", mainContent)
autoFloorButton.Text = "AUTO FLOOR: OFF"
autoFloorButton.Size = UDim2.new(0.9, 0, 0, 25)
autoFloorButton.Position = UDim2.new(0.05, 0, 0.60, 0)
autoFloorButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoFloorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFloorButton.Font = Enum.Font.GothamBold
autoFloorButton.TextSize = 12
Instance.new("UICorner", autoFloorButton).CornerRadius = UDim.new(0, 6)

-- Visuals Tab Content
local visualsContent = Instance.new("Frame", contentFrame)
visualsContent.Size = UDim2.new(1, 0, 1, 0)
visualsContent.BackgroundTransparency = 1
visualsContent.Visible = false

-- Player ESP
local espButton = Instance.new("TextButton", visualsContent)
espButton.Text = "PLAYER ESP: OFF"
espButton.Size = UDim2.new(0.9, 0, 0, 30)
espButton.Position = UDim2.new(0.05, 0, 0.05, 0)
espButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.Font = Enum.Font.GothamBold
espButton.TextSize = 12
Instance.new("UICorner", espButton).CornerRadius = UDim.new(0, 6)

-- Semi Invisible
local semiInvisibleButton = Instance.new("TextButton", visualsContent)
semiInvisibleButton.Text = "SEMI INVISIBLE: OFF"
semiInvisibleButton.Size = UDim2.new(0.9, 0, 0, 30)
semiInvisibleButton.Position = UDim2.new(0.05, 0, 0.20, 0)
semiInvisibleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
semiInvisibleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
semiInvisibleButton.Font = Enum.Font.GothamBold
semiInvisibleButton.TextSize = 12
Instance.new("UICorner", semiInvisibleButton).CornerRadius = UDim.new(0, 6)

-- Combat Tab Content
local combatContent = Instance.new("Frame", contentFrame)
combatContent.Size = UDim2.new(1, 0, 1, 0)
combatContent.BackgroundTransparency = 1
combatContent.Visible = false

-- Auto Lazer
local autoLazerButton = Instance.new("TextButton", combatContent)
autoLazerButton.Text = "AUTO LAZER: OFF"
autoLazerButton.Size = UDim2.new(0.9, 0, 0, 30)
autoLazerButton.Position = UDim2.new(0.05, 0, 0.05, 0)
autoLazerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoLazerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoLazerButton.Font = Enum.Font.GothamBold
autoLazerButton.TextSize = 12
Instance.new("UICorner", autoLazerButton).CornerRadius = UDim.new(0, 6)

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

-- Player ESP Feature
local espEnabled = false
local espFolders = {}

local function createESP(player)
    if player == Players.LocalPlayer then return end
    
    local folder = Instance.new("Folder")
    folder.Name = player.Name .. "_ESP"
    folder.Parent = workspace
    espFolders[player] = folder
    
    local function updateESP(character)
        if not character then return end
        
        local hrp = character:WaitForChild("HumanoidRootPart")
        local humanoid = character:WaitForChild("Humanoid")
        
        -- Box ESP
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "Box"
        box.Adornee = hrp
        box.AlwaysOnTop = true
        box.ZIndex = 1
        box.Size = Vector3.new(4, 6, 2)
        box.Color3 = humanoid.Health > 0 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        box.Transparency = 0.3
        box.Parent = folder
        
        -- Name tag
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "NameTag"
        billboard.Adornee = hrp
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        billboard.AlwaysOnTop = true
        
        local nameLabel = Instance.new("TextLabel", billboard)
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        
        local healthLabel = Instance.new("TextLabel", billboard)
        healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
        healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.Text = "HP: " .. math.floor(humanoid.Health)
        healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        healthLabel.TextStrokeTransparency = 0
        healthLabel.Font = Enum.Font.Gotham
        healthLabel.TextSize = 12
        
        billboard.Parent = folder
        
        -- Update health
        humanoid.HealthChanged:Connect(function()
            healthLabel.Text = "HP: " .. math.floor(humanoid.Health)
            box.Color3 = humanoid.Health > 0 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        end)
    end
    
    if player.Character then
        updateESP(player.Character)
    end
    
    player.CharacterAdded:Connect(updateESP)
end

local function removeESP(player)
    if espFolders[player] then
        espFolders[player]:Destroy()
        espFolders[player] = nil
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    espButton.Text = espEnabled and "PLAYER ESP: ON" or "PLAYER ESP: OFF"
    espButton.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
    
    if espEnabled then
        -- Create ESP for all players
        for _, plr in ipairs(Players:GetPlayers()) do
            createESP(plr)
        end
        -- Create ESP for new players
        Players.PlayerAdded:Connect(createESP)
    else
        -- Remove all ESP
        for plr, folder in pairs(espFolders) do
            folder:Destroy()
        end
        espFolders = {}
    end
end

-- Improved Tween to Base
local active = false
local currentTween
local walkThread
local tweenSpeed = 35

local function getBasePosition()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then 
        -- Try alternative base locations
        local delivery = workspace:FindFirstChild("DeliveryHitbox")
        if delivery then return delivery.Position end
        
        local spawn = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChild("Spawn")
        if spawn then return spawn.Position end
        
        return nil
    end
    
    for _, plot in ipairs(plots:GetChildren()) do
        local sign = plot:FindFirstChild("PlotSign")
        local base = plot:FindFirstChild("DeliveryHitbox") or plot:FindFirstChild("Base") or plot:FindFirstChild("Spawn")
        if sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled and base then
            return base.Position
        end
    end
    return nil
end

local function tweenToPosition(position)
    if currentTween then 
        currentTween:Cancel() 
        currentTween = nil
    end

    local startPos = hrp.Position
    local targetPos = Vector3.new(position.X, startPos.Y, position.Z) -- Maintain current height
    
    local distance = (targetPos - startPos).Magnitude
    local speed = math.max(tweenSpeed, 16)
    local duration = distance / speed
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    currentTween:Play()

    return currentTween
end

local function isAtBase(basePos)
    if not basePos or not hrp then return false end
    local dist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(basePos.X, 0, basePos.Z)).Magnitude
    return dist <= 8
end

function startTweenToBase()
    if active then return end
    
    local target = getBasePosition()
    if not target then
        statusLabel.Text = "Base not found"
        return
    end
    
    active = true
    tweenButton.Text = "■ STOP TWEEN"
    tweenButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    statusLabel.Text = "Tweening to base..."
    
    walkThread = task.spawn(function()
        while active do
            if isAtBase(target) then
                statusLabel.Text = "Reached base"
                stopTweenToBase()
                break
            end
            
            local tween = tweenToPosition(target)
            tween.Completed:Wait()
            
            if not active then break end
            task.wait(0.1)
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
    tweenButton.Text = "▶ TWEEN TO BASE"
    tweenButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    statusLabel.Text = "Ready"
end

-- Button connections
tweenButton.MouseButton1Click:Connect(function()
    if active then
        stopTweenToBase()
    else
        startTweenToBase()
    end
end)

espButton.MouseButton1Click:Connect(toggleESP)

-- [Include your other feature functions here - Float, Auto Floor, Auto Lazer, Semi Invisible]
-- Make sure to connect their buttons and add status updates

-- Drag GUI
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Set initial values
local function setSpeed(value)
    if humanoid then
        humanoid.WalkSpeed = value
    end
end

local function setJumpPower(value)
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = value
    end
end

speedInput.FocusLost:Connect(function()
    local newSpeed = tonumber(speedInput.Text) or 35
    newSpeed = math.clamp(newSpeed, 0, 200)
    speedInput.Text = tostring(newSpeed)
    setSpeed(newSpeed)
    tweenSpeed = newSpeed
end)

jumpInput.FocusLost:Connect(function()
    local newJump = tonumber(jumpInput.Text) or 50
    newJump = math.clamp(newJump, 0, 1000)
    jumpInput.Text = tostring(newJump)
    setJumpPower(newJump)
end)

setJumpPower(50)
setSpeed(35)
