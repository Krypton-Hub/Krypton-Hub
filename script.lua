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
speedInput.Text = "25"
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

-- Fixed Float Feature
local floatEnabled = false
local floatBodyVelocity
local floatConnection

local function toggleFloat()
    floatEnabled = not floatEnabled
    
    if floatEnabled then
        floatButton.Text = "FLOAT: ON"
        floatButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        statusLabel.Text = "Float enabled"
        
        -- Create BodyVelocity for floating
        floatBodyVelocity = Instance.new("BodyVelocity")
        floatBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        floatBodyVelocity.MaxForce = Vector3.new(0, 0, 0)
        
        if floatConnection then
            floatConnection:Disconnect()
        end
        
        floatConnection = RunService.Heartbeat:Connect(function()
            if not floatEnabled or not character or not hrp then
                return
            end
            
            -- Simple ground check
            local rayOrigin = hrp.Position
            local rayDirection = Vector3.new(0, -10, 0)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            
            local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
            
            if not raycastResult then
                -- In air, apply upward force
                floatBodyVelocity.Velocity = Vector3.new(0, 30, 0)
                floatBodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
            else
                -- On ground, no force
                floatBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                floatBodyVelocity.MaxForce = Vector3.new(0, 0, 0)
            end
            
            -- Make sure BodyVelocity is parented to HRP
            if floatBodyVelocity and floatBodyVelocity.Parent ~= hrp then
                floatBodyVelocity.Parent = hrp
            end
        end)
        
    else
        floatButton.Text = "FLOAT: OFF"
        floatButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        statusLabel.Text = "Float disabled"
        
        -- Remove BodyVelocity and connection
        if floatConnection then
            floatConnection:Disconnect()
            floatConnection = nil
        end
        if floatBodyVelocity then
            floatBodyVelocity:Destroy()
            floatBodyVelocity = nil
        end
    end
end

-- Fixed Auto Floor Feature
local floorOn = false
local floorPart
local floorConnection

local function toggleAutoFloor()
    floorOn = not floorOn
    
    if floorOn then
        autoFloorButton.Text = "AUTO FLOOR: ON"
        autoFloorButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        statusLabel.Text = "Auto floor enabled"
        
        -- Create floor part
        floorPart = Instance.new("Part")
        floorPart.Size = Vector3.new(10, 1, 10)
        floorPart.Anchored = true
        floorPart.CanCollide = true
        floorPart.Material = Enum.Material.Neon
        floorPart.Color = Color3.fromRGB(80, 170, 255)
        floorPart.Transparency = 0.3
        floorPart.Parent = workspace
        
        if floorConnection then
            floorConnection:Disconnect()
        end
        
        floorConnection = RunService.Heartbeat:Connect(function()
            if hrp and floorPart then
                local targetY = hrp.Position.Y - 5 -- Keep floor below player
                floorPart.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z)
            end
        end)
        
    else
        autoFloorButton.Text = "AUTO FLOOR: OFF"
        autoFloorButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        statusLabel.Text = "Auto floor disabled"
        
        if floorConnection then
            floorConnection:Disconnect()
            floorConnection = nil
        end
        if floorPart then
            floorPart:Destroy()
            floorPart = nil
        end
    end
end

-- Safe Tween to Base (No Death)
local active = false
local currentTween
local walkThread
local tweenSpeed = 25

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

local function safeTweenToPosition(position)
    if currentTween then 
        currentTween:Cancel() 
        currentTween = nil
    end

    local startPos = hrp.Position
    -- Use base height + small offset to avoid dying
    local targetPos = Vector3.new(position.X, position.Y + 5, position.Z)
    
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
    return dist <= 15
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
    statusLabel.Text = "Safe tweening to base..."
    
    walkThread = task.spawn(function()
        while active do
            if isAtBase(target) then
                statusLabel.Text = "Reached base safely"
                stopTweenToBase()
                break
            end
            
            local tween = safeTweenToPosition(target)
            local success = pcall(function()
                tween.Completed:Wait()
            end)
            
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
        statusLabel.Text = "ESP enabled"
        -- Create ESP for all players
        for _, plr in ipairs(Players:GetPlayers()) do
            createESP(plr)
        end
        -- Create ESP for new players
        Players.PlayerAdded:Connect(createESP)
    else
        statusLabel.Text = "ESP disabled"
        -- Remove all ESP
        for plr, folder in pairs(espFolders) do
            folder:Destroy()
        end
        espFolders = {}
    end
end

-- Auto Lazer Feature
local autoLazerEnabled = false
local autoLazerThread = nil

local function getLazerRemote()
    local remote = nil
    pcall(function()
        if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net") then
            remote = ReplicatedStorage.Packages.Net:FindFirstChild("RE/UseItem") or ReplicatedStorage.Packages.Net:FindFirstChild("RE"):FindFirstChild("UseItem")
        end
        if not remote then
            remote = ReplicatedStorage:FindFirstChild("RE/UseItem") or ReplicatedStorage:FindFirstChild("UseItem")
        end
    end)
    return remote
end

local function isValidTarget(player)
    if not player or not player.Character or player == Players.LocalPlayer then return false end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return false end
    if humanoid.Health <= 0 then return false end
    return true
end

local function findNearestAllowed()
    if not Players.LocalPlayer.Character or not Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = Players.LocalPlayer.Character.HumanoidRootPart.Position
    local nearest = nil
    local nearestDist = math.huge
    for _, pl in ipairs(Players:GetPlayers()) do
        if isValidTarget(pl) then
            local targetHRP = pl.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local d = (Vector3.new(targetHRP.Position.X, 0, targetHRP.Position.Z) - Vector3.new(myPos.X, 0, myPos.Z)).Magnitude
                if d < nearestDist then
                    nearestDist = d
                    nearest = pl
                end
            end
        end
    end
    return nearest
end

local function safeFire(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    local remote = getLazerRemote()
    local args = {
        [1] = targetHRP.Position,
        [2] = targetHRP
    }
    if remote and remote.FireServer then
        pcall(function()
            remote:FireServer(unpack(args))
        end)
    end
end

local function autoLazerWorker()
    while autoLazerEnabled do
        local target = findNearestAllowed()
        if target then
            safeFire(target)
        end
        local t0 = tick()
        while tick() - t0 < 0.6 do
            if not autoLazerEnabled then break end
            RunService.Heartbeat:Wait()
        end
    end
end

local function toggleAutoLazer()
    autoLazerEnabled = not autoLazerEnabled
    autoLazerButton.Text = autoLazerEnabled and "AUTO LAZER: ON" or "AUTO LAZER: OFF"
    autoLazerButton.BackgroundColor3 = autoLazerEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
    statusLabel.Text = autoLazerEnabled and "Auto lazer enabled" or "Auto lazer disabled"
    
    if autoLazerEnabled then
        if autoLazerThread then
            task.cancel(autoLazerThread)
        end
        autoLazerThread = task.spawn(autoLazerWorker)
    else
        if autoLazerThread then
            task.cancel(autoLazerThread)
            autoLazerThread = nil
        end
    end
end

-- Button connections
tweenButton.MouseButton1Click:Connect(function()
    if active then
        stopTweenToBase()
    else
        startTweenToBase()
    end
end)

floatButton.MouseButton1Click:Connect(toggleFloat)
autoFloorButton.MouseButton1Click:Connect(toggleAutoFloor)
espButton.MouseButton1Click:Connect(toggleESP)
autoLazerButton.MouseButton1Click:Connect(toggleAutoLazer)

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
    local newSpeed = tonumber(speedInput.Text) or 25
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
setSpeed(25)
