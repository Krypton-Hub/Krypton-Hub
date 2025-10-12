-- Universal Item Duper
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local dupeEnabled = false
local dupeConnection

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "ItemDupeGUI"
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Text = "ITEM DUPER"
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
dupeButton.Position = UDim2.new(0.1, 0, 0.3, 0)
dupeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dupeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dupeButton.Font = Enum.Font.GothamBold
dupeButton.TextSize = 12
dupeButton.Parent = frame
Instance.new("UICorner", dupeButton).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Status: Ready"
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0.8, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 10
statusLabel.Parent = frame

-- Find drop/use remotes
local function findDropRemote()
    local remotes = {
        "DropItem",
        "Drop",
        "RemoveItem",
        "UseItem",
        "EquipItem",
        "RE/Drop",
        "RE/DropItem",
        "RemoteEvent"
    }
    
    for _, remoteName in pairs(remotes) do
        -- Check ReplicatedStorage
        local remote = ReplicatedStorage:FindFirstChild(remoteName)
        if remote and remote:IsA("RemoteEvent") then
            return remote
        end
        
        -- Check Packages/Knit
        if ReplicatedStorage:FindFirstChild("Packages") then
            remote = ReplicatedStorage.Packages:FindFirstChild(remoteName)
            if remote and remote:IsA("RemoteEvent") then
                return remote
            end
        end
        
        -- Check through folders
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (obj.Name:lower():find("drop") or obj.Name:lower():find("item")) then
                return obj
            end
        end
    end
    return nil
end

-- Get player's tools/items
local function getPlayerItems()
    local items = {}
    
    -- Check backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(items, tool)
            end
        end
    end
    
    -- Check character
    local character = player.Character
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(items, tool)
            end
        end
    end
    
    return items
end

-- Dupe items
local function startDuping()
    local dropRemote = findDropRemote()
    
    if not dropRemote then
        statusLabel.Text = "Status: No drop remote found"
        return
    end
    
    statusLabel.Text = "Status: Duping..."
    
    dupeConnection = RunService.Heartbeat:Connect(function()
        if not dupeEnabled then return end
        
        local items = getPlayerItems()
        
        for _, item in pairs(items) do
            if dupeEnabled then
                -- Try different argument formats
                local success = pcall(function()
                    dropRemote:FireServer(item)
                end)
                
                if not success then
                    pcall(function()
                        dropRemote:FireServer(item.Name)
                    end)
                end
                
                if not success then
                    pcall(function()
                        dropRemote:FireServer()
                    end)
                end
                
                wait(0.2) -- Delay between dupes
            end
        end
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

-- Auto-find and dupe (alternative method)
local function autoDupe()
    statusLabel.Text = "Status: Auto-searching..."
    
    -- Look for all RemoteEvents and try them
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and dupeEnabled then
            pcall(function()
                for i = 1, 10 do -- Try multiple times
                    if dupeEnabled then
                        remote:FireServer()
                        wait(0.1)
                    end
                end
            end)
        end
    end
end

-- Button click
dupeButton.MouseButton1Click:Connect(toggleDupe)

-- Auto-execute if wanted (remove if you want manual control)
-- toggleDupe()

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
