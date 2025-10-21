-- Krypton Hub - Made By agent_duke13 - Enhanced Version

local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

player.CharacterRemoving:Connect(function()
    character = nil
    hrp = nil
    humanoid = nil
end)

-- Clean modern toggle button
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "KryptonToggle"
toggleGui.ResetOnSpawn = false
toggleGui.Parent = player:WaitForChild("PlayerGui")

local toggleButton = Instance.new("ImageButton")
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 15, 0.5, -30)
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleButton.BackgroundTransparency = 0.1
toggleButton.Image = "rbxassetid://95709197010"
toggleButton.ImageColor3 = Color3.fromRGB(0, 170, 255)
toggleButton.Active = true
toggleButton.Draggable = true
toggleButton.Parent = toggleGui

local toggleGlow = Instance.new("UIStroke")
toggleGlow.Color = Color3.fromRGB(0, 170, 255)
toggleGlow.Thickness = 2
toggleGlow.Parent = toggleButton

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0.3, 0)
uiCorner.Parent = toggleButton

local toggleEnabled = false

-- Create main GUI with modern design
local gui = Instance.new("ScreenGui")
gui.Name = "KryptonHubGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
gui.Enabled = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 450)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
})
mainGradient.Rotation = 45
mainGradient.Parent = mainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.08, 0)
UICorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 80)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

-- Header with logo
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundTransparency = 1
header.Parent = mainFrame

local titleContainer = Instance.new("Frame")
titleContainer.Size = UDim2.new(1, -20, 1, 0)
titleContainer.Position = UDim2.new(0, 10, 0, 0)
titleContainer.BackgroundTransparency = 1
titleContainer.Parent = header

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0, 32, 0, 32)
logo.Position = UDim2.new(0, 0, 0.5, -16)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://95709197010"
logo.ImageColor3 = Color3.fromRGB(0, 170, 255)
logo.Parent = titleContainer

local title = Instance.new("TextLabel")
title.Text = "KRYPTON HUB"
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 40, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleContainer

local subtitle = Instance.new("TextLabel")
subtitle.Text = "v2.0 - By agent_duke13"
subtitle.Size = UDim2.new(1, -40, 0, 15)
subtitle.Position = UDim2.new(0, 40, 0, 20)
subtitle.BackgroundTransparency = 1
subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = titleContainer

-- Tab buttons
local tabs = {"Main", "Player", "Visuals", "Misc"}
local currentTab = "Main"

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 35)
tabContainer.Position = UDim2.new(0, 10, 0, 50)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local tabButtons = {}
for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Text = tabName
    tabButton.Size = UDim2.new(1/#tabs, -5, 1, 0)
    tabButton.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    tabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    tabButton.Font = Enum.Font.GothamSemibold
    tabButton.TextSize = 12
    tabButton.ZIndex = 2
    tabButton.Parent = tabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0.05, 0)
    tabCorner.Parent = tabButton
    
    local tabStroke = Instance.new("UIStroke")
    tabStroke.Color = Color3.fromRGB(50, 50, 60)
    tabStroke.Thickness = 1
    tabStroke.Parent = tabButton
    
    tabButtons[tabName] = tabButton
end

-- Content frame
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -120)
contentFrame.Position = UDim2.new(0, 10, 0, 90)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local contentScrolling = Instance.new("ScrollingFrame")
contentScrolling.Size = UDim2.new(1, 0, 1, 0)
contentScrolling.Position = UDim2.new(0, 0, 0, 0)
contentScrolling.BackgroundTransparency = 1
contentScrolling.BorderSizePixel = 0
contentScrolling.ScrollBarThickness = 3
contentScrolling.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
contentScrolling.Parent = contentFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 8)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = contentScrolling

-- Status bar
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, -20, 0, 25)
statusBar.Position = UDim2.new(0, 10, 1, -30)
statusBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
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

-- Function to create modern buttons
local function createButton(text, layoutOrder)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 35)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.LayoutOrder = layoutOrder
    buttonFrame.Parent = contentScrolling
    
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(1, 0, 1, 0)
    button.Position = UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 13
    button.AutoButtonColor = true
    button.Parent = buttonFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.08, 0)
    buttonCorner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(60, 60, 80)
    buttonStroke.Thickness = 1
    buttonStroke.Parent = button
    
    return button
end

-- Function to create toggle buttons
local function createToggle(text, layoutOrder)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 35)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.LayoutOrder = layoutOrder
    toggleFrame.Parent = contentScrolling
    
    local toggle = Instance.new("TextButton")
    toggle.Text = text
    toggle.Size = UDim2.new(1, 0, 1, 0)
    toggle.Position = UDim2.new(0, 0, 0, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.GothamSemibold
    toggle.TextSize = 13
    toggle.AutoButtonColor = true
    toggle.Parent = toggleFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0.08, 0)
    toggleCorner.Parent = toggle
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(60, 60, 80)
    toggleStroke.Thickness = 1
    toggleStroke.Parent = toggle
    
    return toggle
end

-- Function to create slider
local function createSlider(text, min, max, default, layoutOrder)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 50)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.LayoutOrder = layoutOrder
    sliderFrame.Parent = contentScrolling
    
    local label = Instance.new("TextLabel")
    label.Text = text .. ": " .. default
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(1, 0, 0, 25)
    sliderContainer.Position = UDim2.new(0, 0, 0, 20)
    sliderContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    sliderContainer.Parent = sliderFrame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0.2, 0)
    sliderCorner.Parent = sliderContainer
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    sliderFill.Parent = sliderContainer
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0.2, 0)
    fillCorner.Parent = sliderFill
    
    local value = default
    
    local function updateSlider(input)
        local relativeX = (input.Position.X - sliderContainer.AbsolutePosition.X) / sliderContainer.AbsoluteSize.X
        local newValue = math.floor(min + (max - min) * math.clamp(relativeX, 0, 1))
        value = newValue
        label.Text = text .. ": " .. value
        sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        return value
    end
    
    sliderContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input)
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                else
                    updateSlider(input)
                end
            end)
        end
    end)
    
    return {Frame = sliderFrame, Value = function() return value end}
end

-- ========== MAIN TAB ==========
local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1, 0, 0, 0)
mainContent.BackgroundTransparency = 1
mainContent.Visible = true
mainContent.Parent = contentScrolling

-- Player Stats
local walkSpeedSlider = createSlider("Walk Speed", 16, 200, 24, 1)
walkSpeedSlider.Frame.Parent = mainContent

local jumpPowerSlider = createSlider("Jump Power", 50, 500, 50, 2)
jumpPowerSlider.Frame.Parent = mainContent

-- Main Features
local tweenBaseToggle = createToggle("▶ TWEEN TO BASE", 3)
tweenBaseToggle.Parent = mainContent

local flyToggle = createToggle("SLOW FLIGHT: OFF", 4)
flyToggle.Parent = mainContent

local noclipToggle = createToggle("NOCLIP: OFF", 5)
noclipToggle.Parent = mainContent

local floatToggle = createToggle("FLOAT: OFF", 6)
floatToggle.Parent = mainContent

-- ========== PLAYER TAB ==========
local playerContent = Instance.new("Frame")
playerContent.Size = UDim2.new(1, 0, 0, 0)
playerContent.BackgroundTransparency = 1
playerContent.Visible = false
playerContent.Parent = contentScrolling

local antiDeathToggle = createToggle("ANTI-DEATH: OFF", 1)
antiDeathToggle.Parent = playerContent

local semiInvisToggle = createToggle("SEMI INVISIBLE: OFF", 2)
semiInvisToggle.Parent = playerContent

local infJumpToggle = createToggle("INFINITE JUMP: OFF", 3)
infJumpToggle.Parent = playerContent

-- ========== VISUALS TAB ==========
local visualsContent = Instance.new("Frame")
visualsContent.Size = UDim2.new(1, 0, 0, 0)
visualsContent.BackgroundTransparency = 1
visualsContent.Visible = false
visualsContent.Parent = contentScrolling

local espToggle = createToggle("PLAYER ESP: OFF", 1)
espToggle.Parent = visualsContent

local fullbrightToggle = createToggle("FULLBRIGHT: OFF", 2)
fullbrightToggle.Parent = visualsContent

local xrayToggle = createToggle("X-RAY: OFF", 3)
xrayToggle.Parent = visualsContent

-- ========== MISC TAB ==========
local miscContent = Instance.new("Frame")
miscContent.Size = UDim2.new(1, 0, 0, 0)
miscContent.BackgroundTransparency = 1
miscContent.Visible = false
miscContent.Parent = contentScrolling

local autoLazerToggle = createToggle("AUTO LAZER: OFF", 1)
autoLazerToggle.Parent = miscContent

local desyncToggle = createToggle("DESYNC (ANTI-HIT): OFF", 2)
desyncToggle.Parent = miscContent

local discordButton = createButton("📱 DISCORD INVITE", 3)
discordButton.Parent = miscContent

-- ========== WORKING FEATURES IMPLEMENTATION ==========

-- Walk Speed and Jump Power
local function updateStats()
    updateCharacterReferences()
    if humanoid then
        humanoid.WalkSpeed = walkSpeedSlider.Value()
        humanoid.JumpPower = jumpPowerSlider.Value()
    end
end

RunService.Heartbeat:Connect(updateStats)

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

local function tweenToPosition(position)
    if currentTween then currentTween:Cancel() end
    
    updateCharacterReferences()
    if not hrp then return false end
    
    local targetPos = Vector3.new(position.X, position.Y + 3, position.Z)
    local distance = (targetPos - hrp.Position).Magnitude
    local duration = distance / 25
    
    currentTween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(targetPos)
    })
    currentTween:Play()
    
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    
    return true
end

tweenBaseToggle.MouseButton1Click:Connect(function()
    if tweenActive then
        tweenActive = false
        if currentTween then currentTween:Cancel() end
        tweenBaseToggle.Text = "▶ TWEEN TO BASE"
        tweenBaseToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        statusLabel.Text = "Tween stopped"
    else
        local basePos = getBasePosition()
        if basePos then
            tweenActive = true
            tweenBaseToggle.Text = "■ STOP TWEEN"
            tweenBaseToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            statusLabel.Text = "Tweening to base..."
            
            spawn(function()
                while tweenActive do
                    if not tweenToPosition(basePos) then
                        break
                    end
                    task.wait(1)
                end
            end)
        else
            statusLabel.Text = "Base not found!"
        end
    end
end)

-- Flight System
local flyActive = false
local flyConnection

flyToggle.MouseButton1Click:Connect(function()
    flyActive = not flyActive
    
    if flyActive then
        flyToggle.Text = "SLOW FLIGHT: ON"
        flyToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Flight enabled - Use WASD"
        
        flyConnection = RunService.Heartbeat:Connect(function()
            updateCharacterReferences()
            if hrp then
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
                    hrp.Velocity = moveDirection.Unit * 25
                else
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                end
            end
        end)
    else
        flyToggle.Text = "SLOW FLIGHT: OFF"
        flyToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        statusLabel.Text = "Flight disabled"
        
        if flyConnection then
            flyConnection:Disconnect()
        end
    end
end)

-- Noclip System
local noclipActive = false
local noclipConnection

noclipToggle.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    
    if noclipActive then
        noclipToggle.Text = "NOCLIP: ON"
        noclipToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Noclip enabled"
        
        noclipConnection = RunService.Stepped:Connect(function()
            updateCharacterReferences()
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        noclipToggle.Text = "NOCLIP: OFF"
        noclipToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        statusLabel.Text = "Noclip disabled"
        
        if noclipConnection then
            noclipConnection:Disconnect()
        end
    end
end)

-- Float System
local floatActive = false
local floatBodyVelocity

floatToggle.MouseButton1Click:Connect(function()
    floatActive = not floatActive
    
    if floatActive then
        floatToggle.Text = "FLOAT: ON"
        floatToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Float enabled"
        
        updateCharacterReferences()
        if hrp then
            floatBodyVelocity = Instance.new("BodyVelocity")
            floatBodyVelocity.Velocity = Vector3.new(0, 30, 0)
            floatBodyVelocity.MaxForce = Vector3.new(0, 50000, 0)
            floatBodyVelocity.Parent = hrp
        end
    else
        floatToggle.Text = "FLOAT: OFF"
        floatToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        statusLabel.Text = "Float disabled"
        
        if floatBodyVelocity then
            floatBodyVelocity:Destroy()
        end
    end
end)

-- Anti-Death System
local antiDeathActive = false
local antiDeathConnection

antiDeathToggle.MouseButton1Click:Connect(function()
    antiDeathActive = not antiDeathActive
    
    if antiDeathActive then
        antiDeathToggle.Text = "ANTI-DEATH: ON"
        antiDeathToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Anti-Death enabled"
        
        updateCharacterReferences()
        if humanoid then
            antiDeathConnection = humanoid.HealthChanged:Connect(function()
                if humanoid.Health <= 0 then
                    humanoid.Health = humanoid.MaxHealth
                end
            end)
        end
    else
        antiDeathToggle.Text = "ANTI-DEATH: OFF"
        antiDeathToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        statusLabel.Text = "Anti-Death disabled"
        
        if antiDeathConnection then
            antiDeathConnection:Disconnect()
        end
    end
end)

-- Infinite Jump
local infJumpActive = false

infJumpToggle.MouseButton1Click:Connect(function()
    infJumpActive = not infJumpActive
    
    if infJumpActive then
        infJumpToggle.Text = "INFINITE JUMP: ON"
        infJumpToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Infinite Jump enabled"
        
        UserInputService.JumpRequest:Connect(function()
            if infJumpActive and humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        infJumpToggle.Text = "INFINITE JUMP: OFF"
        infJumpToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        statusLabel.Text = "Infinite Jump disabled"
    end
end)

-- ESP System
local espActive = false
local espFolders = {}

espToggle.MouseButton1Click:Connect(function()
    espActive = not espActive
    
    if espActive then
        espToggle.Text = "PLAYER ESP: ON"
        espToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "ESP enabled"
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                local espFolder = Instance.new("Folder")
                espFolder.Name = player.Name .. "_ESP"
                espFolder.Parent = Workspace
                espFolders[player] = espFolder
                
                if player.Character then
                    createESP(player.Character, espFolder)
                end
                
                player.CharacterAdded:Connect(function(char)
                    createESP(char, espFolder)
                end)
            end
        end
    else
        espToggle.Text = "PLAYER ESP: OFF"
        espToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        statusLabel.Text = "ESP disabled"
        
        for _, folder in pairs(espFolders) do
            folder:Destroy()
        end
        espFolders = {}
    end
end)

function createESP(character, folder)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = folder
end

-- Fullbright
local fullbrightActive = false
local originalBrightness

fullbrightToggle.MouseButton1Click:Connect(function()
    fullbrightActive = not fullbrightActive
    
    if fullbrightActive then
        fullbrightToggle.Text = "FULLBRIGHT: ON"
        fullbrightToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Fullbright enabled"
        
        originalBrightness = Lighting.Brightness
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    else
        fullbrightToggle.Text = "FULLBRIGHT: OFF"
        fullbrightToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        statusLabel.Text = "Fullbright disabled"
        
        if originalBrightness then
            Lighting.Brightness = originalBrightness
        end
        Lighting.GlobalShadows = true
    end
end)

-- Auto Lazer
local autoLazerActive = false
local autoLazerThread

autoLazerToggle.MouseButton1Click:Connect(function()
    autoLazerActive = not autoLazerActive
    
    if autoLazerActive then
        autoLazerToggle.Text = "AUTO LAZER: ON"
        autoLazerToggle.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusLabel.Text = "Auto Lazer enabled"
        
        autoLazerThread = task.spawn(function()
            while autoLazerActive do
                -- Add your lazer logic here
                task.wait(0.5)
            end
        end)
    else
        autoLazerToggle.Text = "AUTO LAZER: OFF"
        autoLazerToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        statusLabel.Text = "Auto Lazer disabled"
        
        if autoLazerThread then
            task.cancel(autoLazerThread)
        end
    end
end)

-- Discord Button
discordButton.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard("https://discord.gg/YSwFZsGk9j")
        statusLabel.Text = "Discord link copied!"
        discordButton.Text = "✓ COPIED!"
        task.wait(2)
        discordButton.Text = "📱 DISCORD INVITE"
    else
        statusLabel.Text = "Clipboard not supported"
    end
end)

-- ========== TAB SYSTEM ==========
local function switchTab(tabName)
    currentTab = tabName
    mainContent.Visible = (tabName == "Main")
    playerContent.Visible = (tabName == "Player")
    visualsContent.Visible = (tabName == "Visuals")
    miscContent.Visible = (tabName == "Misc")
    
    for name, button in pairs(tabButtons) do
        if name == tabName then
            button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            button.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
    end
end

for tabName, button in pairs(tabButtons) do
    button.MouseButton1Click:Connect(function()
        switchTab(tabName)
    end)
end
switchTab("Main")

-- ========== TOGGLE BUTTON ==========
toggleButton.MouseButton1Click:Connect(function()
    gui.Enabled = not gui.Enabled
    toggleEnabled = gui.Enabled
    
    if toggleEnabled then
        toggleButton.ImageColor3 = Color3.fromRGB(0, 255, 150)
        toggleGlow.Color = Color3.fromRGB(0, 255, 150)
        toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        statusLabel.Text = "GUI Opened"
    else
        toggleButton.ImageColor3 = Color3.fromRGB(0, 170, 255)
        toggleGlow.Color = Color3.fromRGB(0, 170, 255)
        toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        statusLabel.Text = "GUI Closed"
    end
end)

-- Mobile support
toggleButton.TouchTap:Connect(function()
    gui.Enabled = not gui.Enabled
    toggleEnabled = gui.Enabled
    
    if toggleEnabled then
        toggleButton.ImageColor3 = Color3.fromRGB(0, 255, 150)
        toggleGlow.Color = Color3.fromRGB(0, 255, 150)
        statusLabel.Text = "GUI Opened"
    else
        toggleButton.ImageColor3 = Color3.fromRGB(0, 170, 255)
        toggleGlow.Color = Color3.fromRGB(0, 170, 255)
        statusLabel.Text = "GUI Closed"
    end
end)

-- Update scrolling frame size
contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentScrolling.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
end)

print("Krypton Hub v2.0 loaded successfully!")
print("Discord: https://discord.gg/YSwFZsGk9j")
