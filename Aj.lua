--// Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

--// Variables
local player = Players.LocalPlayer
while not player do task.wait() player = Players.LocalPlayer end
local ALLOWED_PLACE_ID = 109983668079237
local RETRY_DELAY = 0.5
local SETTINGS_FILE = "PetSearchSettings.json"
local hopping = false
local settings = {
    autoStart = false, -- Controlled by GUI toggle
    minGeneration = 1000000, -- Default 1M/s
    targetNames = {}, -- Empty (no Huge Dragon)
    targetRarity = "",
    minPlayers = 2,
    sortOrder = "Desc",
    customSoundId = "rbxassetid://9167433166",
    hopCount = 0,
    recentVisited = {},
    notificationDuration = 5
}
local foundPodiumsData = {}
local monitoringConnection = nil
local bestPetESP = nil
local setCoreSupported = false

--// Functions
local function testSetCore()
    local success, _ = pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Test", Text = "Testing SetCore", Duration = 1 })
    end)
    return success
end

local function showNotification(title, text)
    local duration = settings.notificationDuration or 5
    print(string.format("Notification: %s - %s (Duration: %d)", title, text, duration))
    if setCoreSupported then
        local success, err = pcall(function()
            StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = duration })
        end)
        if success then return end
        print("SetCore failed:", err)
    end
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "TempNotification"
    notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notificationGui.IgnoreGuiInset = true
    notificationGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 80)
    frame.Position = UDim2.new(0.5, -100, 0.05, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = notificationGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 20)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 0, 40)
    textLabel.Position = UDim2.new(0, 5, 0, 25)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    textLabel.Parent = frame

    task.spawn(function()
        task.wait(duration)
        notificationGui:Destroy()
    end)
end

local function saveSettings()
    local success, error = pcall(function()
        writefile(SETTINGS_FILE, HttpService:JSONEncode(settings))
    end)
    if not success then print("Failed to save settings:", error) end
end

local function loadSettings()
    local success, data = pcall(function() return readfile(SETTINGS_FILE) end)
    if success then
        local loadedSettings = HttpService:JSONDecode(data)
        for key, value in pairs(loadedSettings) do
            if settings[key] ~= nil then settings[key] = value end
        end
    end
end

local function playFoundSound()
    local success, err = pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = settings.customSoundId
        sound.Volume = 1
        sound.PlayOnRemove = true
        sound.Parent = Workspace
        sound:Destroy()
    end)
    if not success then print("Failed to play sound:", err) end
end

local function parseGenerationInput(input)
    input = input:lower():gsub("[^0-9kmb/s]", "")
    local number = input:match("(%d+%.?%d*)")
    local multiplier = 1
    if input:find("k") then multiplier = 1000
    elseif input:find("m") then multiplier = 1000000
    elseif input:find("b") then multiplier = 1000000000
    end
    return tonumber(number) and (tonumber(number) * multiplier) or settings.minGeneration
end

local function formatGeneration(genValue)
    if genValue >= 1000000000 then
        return string.format("%.1fB/s", genValue / 1000000000)
    elseif genValue >= 1000000 then
        return string.format("%.1fM/s", genValue / 1000000)
    elseif genValue >= 1000 then
        return string.format("%.1fK/s", genValue / 1000)
    else
        return tostring(genValue) .. "/s"
    end
end

local function extractNumber(str)
    if not str then return 0 end
    local numberStr = str:match("%$(.-)/s")
    if not numberStr then return 0 end
    numberStr = numberStr:gsub("%s", "")
    local multiplier = 1
    if numberStr:lower():find("k") then
        multiplier = 1000
        numberStr = numberStr:gsub("[kK]", "")
    elseif numberStr:lower():find("m") then
        multiplier = 1000000
        numberStr = numberStr:gsub("[mM]", "")
    elseif numberStr:lower():find("b") then
        multiplier = 1000000000
        numberStr = numberStr:gsub("[bB]", "")
    end
    return (tonumber(numberStr) or 0) * multiplier
end

local function getAllPodiums()
    local plots = Workspace:FindFirstChild("Plots")
    local podiums = {}
    if not plots then return podiums end

    for _, plot in pairs(plots:GetChildren()) do
        if not plot:FindFirstChild("PlotSign") or not plot.PlotSign:FindFirstChild("YourBase") or not plot.PlotSign.YourBase.Enabled then
            local animalPods = plot:FindFirstChild("AnimalPodiums")
            if animalPods then
                for _, pod in pairs(animalPods:GetChildren()) do
                    local base = pod:FindFirstChild("Base")
                    if base and base:FindFirstChild("Spawn") and base.Spawn:FindFirstChild("Attachment") and base.Spawn.Attachment:FindFirstChild("AnimalOverhead") then
                        table.insert(podiums, { 
                            overhead = base.Spawn.Attachment.AnimalOverhead, 
                            base = base,
                            pod = pod,
                            plot = plot
                        })
                    end
                end
            end
        end
    end
    return podiums
end

local function isStolenPodium(overhead)
    local stolenLabel = overhead:FindFirstChild("Stolen")
    return stolenLabel and stolenLabel:IsA("TextLabel") and string.upper(stolenLabel.Text) == "FUSING"
end

local function createESP(podium, name, genValue)
    if bestPetESP then bestPetESP:Destroy() end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PetESP"
    billboard.Adornee = podium.base
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = podium.pod

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = billboard

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name .. " (" .. formatGeneration(genValue) .. ")"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextWrapped = true
    textLabel.Parent = frame

    bestPetESP = billboard
end

local function getAvailableServers()
    local servers = {}
    local mainAPI = "https://games.roblox.com/v1/games/" .. ALLOWED_PLACE_ID .. "/servers/Public?sortOrder=" .. settings.sortOrder .. "&limit=10&excludeFullGames=true"
    local success, response = pcall(function() return game:HttpGet(mainAPI) end)
    if not success then
        print("HTTP request failed:", response)
        return servers
    end
    local body = HttpService:JSONDecode(response)
    if body.data then
        for _, v in pairs(body.data) do
            if v.playing and v.maxPlayers and v.playing >= settings.minPlayers and v.playing < v.maxPlayers and v.id ~= game.JobId and not table.find(settings.recentVisited, v.id) then
                table.insert(servers, v.id)
            end
        end
    end
    return servers
end

local function matchesFilters(labels, overhead)
    if isStolenPodium(overhead) then return false end
    local genValue = extractNumber(labels.Generation)
    if genValue < settings.minGeneration then return false end
    if #settings.targetNames > 0 then
        local hasTargetName = false
        for _, name in pairs(settings.targetNames) do
            if name ~= "" and string.find(string.lower(labels.DisplayName), string.lower(name)) then
                hasTargetName = true
                break
            end
        end
        if not hasTargetName then return false end
    end
    if settings.targetRarity ~= "" and string.lower(labels.Rarity) ~= string.lower(settings.targetRarity) then
        return false
    end
    return true, genValue
end

local function checkPodiums()
    if game.PlaceId ~= ALLOWED_PLACE_ID then return false, {} end
    local podiums = getAllPodiums()
    local filteredPodiums = {}
    for _, podium in pairs(podiums) do
        local displayNameLabel = podium.overhead:FindFirstChild("DisplayName")
        local genLabel = podium.overhead:FindFirstChild("Generation")
        local rarityLabel = podium.overhead:FindFirstChild("Rarity")
        if displayNameLabel and genLabel and rarityLabel then
            local labels = {
                DisplayName = displayNameLabel.Text,
                Generation = genLabel.Text,
                Rarity = rarityLabel.Text
            }
            local matches, genValue = matchesFilters(labels, podium.overhead)
            if matches then
                table.insert(filteredPodiums, { 
                    base = podium.base, 
                    labels = labels, 
                    pod = podium.pod, 
                    plot = podium.plot,
                    genValue = genValue
                })
            end
        end
    end
    return #filteredPodiums > 0, filteredPodiums
end

local function tryTeleportWithRetries()
    if not hopping then return end
    local attempts = 0
    local maxAttempts = 5
    while attempts < maxAttempts and hopping do
        local servers = getAvailableServers()
        if #servers == 0 then
            task.wait(RETRY_DELAY)
            attempts = attempts + 1
            continue
        end
        local randomServer = servers[math.random(1, #servers)]
        table.insert(settings.recentVisited, randomServer)
        if #settings.recentVisited > 50 then table.remove(settings.recentVisited, 1) end
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(ALLOWED_PLACE_ID, randomServer)
        end)
        if success then return end
        task.wait(RETRY_DELAY)
        attempts = attempts + 1
    end
    if hopping then
        hopping = false
        showNotification("Error", "Failed to teleport after retries.")
    end
end

local function monitorFoundPodiums(statusLabel)
    if monitoringConnection then monitoringConnection:Disconnect() end
    monitoringConnection = RunService.Heartbeat:Connect(function()
        if not hopping or #foundPodiumsData == 0 then return end
        local lostAny = false
        local lostPodiums = {}
        for i = #foundPodiumsData, 1, -1 do
            local data = foundPodiumsData[i]
            if data and data.overhead and data.overhead.Parent then
                local displayNameLabel = data.overhead:FindFirstChild("DisplayName")
                if displayNameLabel and displayNameLabel.Text then
                    local currentLabels = {
                        DisplayName = displayNameLabel.Text,
                        Generation = data.labels.Generation,
                        Rarity = data.labels.Rarity
                    }
                    local matches, _ = matchesFilters(currentLabels, data.overhead)
                    if not matches then
                        table.insert(lostPodiums, data.labels.DisplayName)
                        table.remove(foundPodiumsData, i)
                        lostAny = true
                    end
                else
                    table.insert(lostPodiums, data.labels.DisplayName)
                    table.remove(foundPodiumsData, i)
                    lostAny = true
                end
            else
                table.insert(lostPodiums, data.labels.DisplayName)
                table.remove(foundPodiumsData, i)
                lostAny = true
            end
        end
        if lostAny then
            local lostText = #lostPodiums > 0 and "Lost: " .. table.concat(lostPodiums, ", ") or "Lost podium(s)"
            showNotification("Not found", lostText)
            statusLabel.Text = "Status: Searching..."
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            if bestPetESP then bestPetESP:Destroy() bestPetESP = nil end
        end
    end)
end

local function startHopping(statusLabel)
    if hopping then
        showNotification("Warning", "Search is already running!")
        return
    end
    hopping = true
    statusLabel.Text = "Status: Searching..."
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    showNotification("Search started", "Looking for target pets...")
    task.spawn(function()
        while hopping do
            local success, foundPets, results = pcall(checkPodiums)
            if not success then
                showNotification("Error", "Failed to check podiums: " .. tostring(foundPets))
                task.wait(0.1)
                continue
            end
            if foundPets and #results > 0 then
                foundPodiumsData = results
                table.sort(results, function(a, b) return a.genValue > b.genValue end)
                local bestPet = results[1]
                statusLabel.Text = "Best Pet: " .. bestPet.labels.DisplayName .. " (" .. formatGeneration(bestPet.genValue) .. ")"
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                createESP(bestPet, bestPet.labels.DisplayName, bestPet.genValue)
                showNotification("Found", bestPet.labels.DisplayName .. " (" .. formatGeneration(bestPet.genValue) .. ")")
                playFoundSound()
                monitorFoundPodiums(statusLabel)
                break
            end
            settings.hopCount = settings.hopCount + 1
            saveSettings()
            tryTeleportWithRetries()
            task.wait(0.1)
        end
    end)
end

local function stopHopping(statusLabel)
    hopping = false
    foundPodiumsData = {}
    if monitoringConnection then
        monitoringConnection:Disconnect()
        monitoringConnection = nil
    end
    if bestPetESP then
        bestPetESP:Destroy()
        bestPetESP = nil
    end
    statusLabel.Text = "Status: Stopped"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    showNotification("Stopped", "Pet search stopped.")
end

local function createSettingsGUI()
    local success, err = pcall(function()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "PetSearchGUI"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = player.PlayerGui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 250, 0, 200) -- Compact like first version
        frame.Position = UDim2.new(0.5, -125, 0.5, -100)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BorderSizePixel = 0
        frame.Parent = screenGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame

        local title = Instance.new("TextLabel")
        title.Text = "Pet Search"
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 18
        title.Parent = frame

        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0, 30, 0, 30)
        closeButton.Position = UDim2.new(1, -40, 0, 5)
        closeButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        closeButton.BorderSizePixel = 0
        closeButton.Text = "X"
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.TextSize = 16
        closeButton.Font = Enum.Font.SourceSansBold
        closeButton.Parent = frame

        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 8)
        closeCorner.Parent = closeButton

        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1, -20, 1, -40)
        contentFrame.Position = UDim2.new(0, 10, 0, 40)
        contentFrame.BackgroundTransparency = 1
        contentFrame.Parent = frame

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10) -- Increased spacing
        layout.Parent = contentFrame

        local function createInputField(name, placeholder, defaultValue, layoutOrder, settingKey)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 40)
            container.BackgroundTransparency = 1
            container.LayoutOrder = layoutOrder
            container.Parent = contentFrame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 15)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 14
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container

            local inputFrame = Instance.new("Frame")
            inputFrame.Size = UDim2.new(1, 0, 0, 20)
            inputFrame.Position = UDim2.new(0, 0, 0, 15)
            inputFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            inputFrame.BorderSizePixel = 0
            inputFrame.Parent = container

            local inputCorner = Instance.new("UICorner")
            inputCorner.CornerRadius = UDim.new(0, 6)
            inputCorner.Parent = inputFrame

            local textBox = Instance.new("TextBox")
            textBox.Size = UDim2.new(1, -10, 1, 0)
            textBox.Position = UDim2.new(0, 5, 0, 0)
            textBox.BackgroundTransparency = 1
            textBox.Text = defaultValue or ""
            textBox.PlaceholderText = placeholder
            textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
            textBox.TextSize = 14
            textBox.Font = Enum.Font.SourceSans
            textBox.Parent = inputFrame

            textBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    if settingKey == "minGeneration" then
                        settings[settingKey] = parseGenerationInput(textBox.Text)
                        textBox.Text = formatGeneration(settings[settingKey])
                    elseif settingKey == "targetNames" then
                        local text = textBox.Text:gsub("^%s*(.-)%s*$", "%1")
                        settings[settingKey] = text ~= "" and {text} or {}
                    else
                        settings[settingKey] = textBox.Text:gsub("^%s*(.-)%s*$", "%1")
                    end
                    saveSettings()
                end
            end)
            return textBox
        end

        local function createToggle(name, defaultValue, layoutOrder, settingKey)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 30)
            container.BackgroundTransparency = 1
            container.LayoutOrder = layoutOrder
            container.Parent = contentFrame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.7, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 14
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container

            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, 50, 0, 20)
            toggleButton.Position = UDim2.new(0.8, 0, 0, 5)
            toggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 100, 100)
            toggleButton.BorderSizePixel = 0
            toggleButton.Text = defaultValue and "ON" or "OFF"
            toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggleButton.TextSize = 14
            toggleButton.Font = Enum.Font.SourceSans
            toggleButton.Parent = container

            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 6)
            toggleCorner.Parent = toggleButton

            toggleButton.MouseButton1Click:Connect(function()
                settings[settingKey] = not settings[settingKey]
                toggleButton.Text = settings[settingKey] and "ON" or "OFF"
                toggleButton.BackgroundColor3 = settings[settingKey] and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 100, 100)
                saveSettings()
            end)
            return toggleButton
        end

        local targetNameInput = createInputField("Target Pet Name", "Noobini Pizzanini, Sigma Boy", settings.targetNames[1] or "", 1, "targetNames")
        local minGenInput = createInputField("Min. Generation", "1K/s, 1M/s", formatGeneration(settings.minGeneration), 2, "minGeneration")
        local rarityInput = createInputField("Rarity", "Secret, Mythical", settings.targetRarity, 3, "targetRarity")
        local autoStartToggle = createToggle("Auto Start", settings.autoStart, 4, "autoStart")

        local statusLabel = Instance.new("TextLabel")
        statusLabel.Text = "Status: Stopped"
        statusLabel.Size = UDim2.new(1, 0, 0, 20)
        statusLabel.LayoutOrder = 5
        statusLabel.BackgroundTransparency = 1
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Font = Enum.Font.SourceSans
        statusLabel.TextSize = 14
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.Parent = contentFrame

        local buttonContainer = Instance.new("Frame")
        buttonContainer.Size = UDim2.new(1, 0, 0, 30)
        buttonContainer.LayoutOrder = 6
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = contentFrame

        local startBtn = Instance.new("TextButton")
        startBtn.Text = "Start"
        startBtn.Size = UDim2.new(0.48, -5, 0, 25)
        startBtn.Position = UDim2.new(0, 0, 0, 0)
        startBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        startBtn.Font = Enum.Font.SourceSansBold
        startBtn.TextSize = 14
        startBtn.Parent = buttonContainer

        local startCorner = Instance.new("UICorner")
        startCorner.CornerRadius = UDim.new(0, 6)
        startCorner.Parent = startBtn

        local stopBtn = Instance.new("TextButton")
        stopBtn.Text = "Stop"
        stopBtn.Size = UDim2.new(0.48, -5, 0, 25)
        stopBtn.Position = UDim2.new(0.52, 5, 0, 0)
        stopBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        stopBtn.Font = Enum.Font.SourceSansBold
        stopBtn.TextSize = 14
        stopBtn.Parent = buttonContainer

        local stopCorner = Instance.new("UICorner")
        stopCorner.CornerRadius = UDim.new(0, 6)
        stopCorner.Parent = stopBtn

        startBtn.MouseButton1Click:Connect(function()
            startHopping(statusLabel)
        end)

        stopBtn.MouseButton1Click:Connect(function()
            stopHopping(statusLabel)
        end)

        closeButton.MouseButton1Click:Connect(function()
            stopHopping(statusLabel)
            screenGui:Destroy()
        end)

        local dragging, dragStart, startPos
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        if settings.autoStart and game.PlaceId == ALLOWED_PLACE_ID then
            startHopping(statusLabel)
        end
    end)
    if not success then
        warn("Failed to create GUI:", err)
        showNotification("Error", "Failed to create GUI: " .. tostring(err))
    end
end

--// Initialize
setCoreSupported = testSetCore()
loadSettings()
local success, err = pcall(createSettingsGUI)
if not success then
    warn("Failed to create GUI:", err)
    showNotification("Error", "Failed to create GUI: " .. tostring(err))
else
    print("GUI created successfully")
end
