-- Chat Command Item Duper
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local dupeEnabled = false
local dupeConnection

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "ChatDupeGUI"
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Text = "CHAT DUPER"
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local dupeButton = Instance.new("TextButton")
dupeButton.Text = "START DUPING"
dupeButton.Size = UDim2.new(0.8, 0, 0, 35)
dupeButton.Position = UDim2.new(0.1, 0, 0.25, 0)
dupeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dupeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dupeButton.Font = Enum.Font.GothamBold
dupeButton.TextSize = 12
dupeButton.Parent = frame
Instance.new("UICorner", dupeButton).CornerRadius = UDim.new(0, 6)

local speedLabel = Instance.new("TextLabel")
speedLabel.Text = "Speed: Medium"
speedLabel.Size = UDim2.new(0.8, 0, 0, 20)
speedLabel.Position = UDim2.new(0.1, 0, 0.55, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 10
speedLabel.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Status: Ready - Hold items to dupe"
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0.8, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.Parent = frame

-- Dupe settings
local dupeSpeed = 1 -- 1 = medium, 2 = fast, 0.5 = slow
local commandsToTry = {"/drop", "/d", "!drop", ".drop", "/give", "/dupe"}

-- Send chat message
local function sendChatMessage(message)
    -- Method 1: New TextChatService
    if TextChatService then
        local chatChannel = TextChatService:FindFirstChild("TextChannels"):FindFirstChild("RBXGeneral")
        if chatChannel then
            chatChannel:SendAsync(message)
            return true
        end
    end
    
    -- Method 2: Legacy Chat (works in most games)
    local success = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(message, "All")
    end)
    
    if success then return true end
    
    -- Method 3: Direct replication
    local success2 = pcall(function()
        local event = ReplicatedStorage:FindFirstChild("SayMessageRequest", true)
        if event then
            event:FireServer(message, "All")
            return true
        end
    end)
    
    return success or success2
end

-- Get player's tools/items
local function getPlayerItems()
    local items = {}
    
    -- Check backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") or tool:IsA("HopperBin") then
                table.insert(items, tool.Name)
            end
        end
    end
    
    -- Check character
    local character = player.Character
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") or tool:IsA("HopperBin") then
                table.insert(items, tool.Name)
            end
        end
    end
    
    -- If no tools found, try to dupe anyway (some games don't use Tool objects)
    if #items == 0 then
        table.insert(items, "") -- Empty string for general dupe
    end
    
    return items
end

-- Try different dupe commands
local function tryDupeCommands()
    local items = getPlayerItems()
    
    for _, command in pairs(commandsToTry) do
        for _, itemName in pairs(items) do
            if not dupeEnabled then break end
            
            local fullCommand = itemName ~= "" and command .. " " .. itemName or command
            
            -- Try the command
            local success = sendChatMessage(fullCommand)
            
            if success then
                statusLabel.Text = "Status: Sent: " .. fullCommand
            else
                statusLabel.Text = "Status: Failed to send command"
            end
            
            wait(dupeSpeed) -- Adjustable delay
        end
    end
end

-- Start duping process
local function startDuping()
    statusLabel.Text = "Status: Starting dupe..."
    
    dupeConnection = RunService.Heartbeat:Connect(function()
        if not dupeEnabled then return end
        
        tryDupeCommands()
    end)
end

-- Toggle dupe
local function toggleDupe()
    dupeEnabled = not dupeEnabled
    
    if dupeEnabled then
        dupeButton.Text = "STOP DUPING"
        dupeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        startDuping()
    else
        dupeButton.Text = "START DUPING"
        dupeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        statusLabel.Text = "Status: Stopped"
        
        if dupeConnection then
            dupeConnection:Disconnect()
            dupeConnection = nil
        end
    end
end

-- Speed toggle
local speedIndex = 2
local speeds = {0.5, 1, 2} -- slow, medium, fast

local function cycleSpeed()
    speedIndex = (speedIndex % #speeds) + 1
    dupeSpeed = speeds[speedIndex]
    
    local speedNames = {"Slow", "Medium", "Fast"}
    speedLabel.Text = "Speed: " .. speedNames[speedIndex]
end

-- Button clicks
dupeButton.MouseButton1Click:Connect(toggleDupe)
speedLabel.MouseButton1Click:Connect(cycleSpeed)

-- Auto-detect and add more commands
local function autoDetectCommands()
    -- Listen for chat messages to detect commands
    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvents then
        local onMessage = chatEvents:FindFirstChild("OnMessageDoneFiltering")
        if onMessage then
            onMessage.OnClientEvent:Connect(function(messageData)
                local message = messageData.Message
                if message:sub(1, 1) == "/" or message:sub(1, 1) == "!" or message:sub(1, 1) == "." then
                    -- Extract command (first word)
                    local command = message:match("^([^%s]+)")
                    if command and not table.find(commandsToTry, command) then
                        table.insert(commandsToTry, command)
                        statusLabel.Text = "Status: Detected new command: " .. command
                    end
                end
            end)
        end
    end
end

-- Start auto-detection
autoDetectCommands()

-- Cleanup
gui.Destroying:Connect(function()
    if dupeConnection then
        dupeConnection:Disconnect()
    end
end)

-- Drag GUI
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

statusLabel.Text = "Status: Ready - Click Speed to change"
