local Http = game:GetService("HttpService")
local TPS = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

while not Players.LocalPlayer do task.wait() end
local player = Players.LocalPlayer
local ALLOWED_PLACE_ID = 109983668079237
local RETRY_DELAY = 0.1
local SETTINGS_FILE = "ServerHopperSettings.json"
local GUI_STATE_FILE = "ServerHopperGUIState.json"
local API_STATE_FILE = "ServerHopperAPIState.json"

local settings = {
    minGeneration = 1000000,
    targetNames = {"Noobini Pizzanini"}, -- Default pet name
    blacklistNames = {},
    targetRarity = "",
    targetMutation = "",
    minPlayers = 2,
    sortOrder = "Desc",
    autoStart = true,
    customSoundId = "rbxassetid://9167433166",
    hopCount = 0,
    recentVisited = {},
    notificationDuration = 5
}

local guiState = {
    position = { XScale = 0.25, XOffset = 0, YScale = 0.2, YOffset = 0 }
}

local apiState = {
    mainApiUses = 0,
    cachedServers = {},
    lastCacheUpdate = 0,
    useCachedServers = false
}

local isRunning = false
local currentConnection = nil
local foundPodiumsData = {}
local monitoringConnection = nil
local setCoreSupported = false

local function testSetCore()
    local success, _ = pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Test", Text = "Testing SetCore", Duration = 1 })
    end)
    return success
end

local function createNotificationGui(title, text, duration)
    local success, err = pcall(function()
        local notificationGui = Instance.new("ScreenGui")
        notificationGui.Name = "TempNotification"
        notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        notificationGui.IgnoreGuiInset = true
        notificationGui.Parent = player.PlayerGui
        print("Notification GUI created and parented to PlayerGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.4, 0, 0.2, 0)
        frame.Position = UDim2.new(0.3, 0, 0.05, 0)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        frame.BorderSizePixel = 0
        frame.Parent = notificationGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = frame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -10, 0, 25)
        titleLabel.Position = UDim2.new(0, 5, 0, 5)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextSize = 18
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = frame

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -10, 0, 50)
        textLabel.Position = UDim2.new(0, 5, 0, 30)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
        textLabel.TextSize = 16
        textLabel.Font = Enum.Font.Gotham
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextWrapped = true
        textLabel.Parent = frame

        task.spawn(function()
            task.wait(duration)
            notificationGui:Destroy()
            print("Notification GUI destroyed")
        end)
    end)
    if not success then print("Failed to create notification GUI:", err) end
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
    createNotificationGui(title, text, duration)
end

local function checkAPIAvailability()
    local mainAPI = "https://games.roblox.com/v1/games/" .. ALLOWED_PLACE_ID .. "/servers/Public?sortOrder=" .. settings.sortOrder .. "&limit=10&excludeFullGames=true"
    local success, response = pcall(function() return game:HttpGet(mainAPI) end)
    return success and response ~= ""
end

local function saveSettings()
    local success, error = pcall(function()
        writefile(SETTINGS_FILE, Http:JSONEncode(settings))
    end)
    if not success then print("Failed to save settings:", error) end
end

local function loadSettings()
    local success, data = pcall(function() return readfile(SETTINGS_FILE) end)
    if success then
        local loadedSettings = Http:JSONDecode(data)
        for key, value in pairs(loadedSettings) do
            if settings[key] ~= nil then settings[key] = value end
        end
    end
end

local function saveGUIState()
    local success, error = pcall(function()
        writefile(GUI_STATE_FILE, Http:JSONEncode(guiState))
    end)
    if not success then print("Failed to save GUI state:", error) end
end

local function loadGUIState()
    local success, data = pcall(function() return readfile(GUI_STATE_FILE) end)
    if success then
        local loadedState = Http:JSONDecode(data)
        for key, value in pairs(loadedState) do
            if guiState[key] ~= nil then guiState[key] = value end
        end
    end
end

local function saveAPIState()
    local success, error = pcall(function()
        writefile(API_STATE_FILE, Http:JSONEncode(apiState))
    end)
    if not success then print("Failed to save API state:", error) end
end

local function loadAPIState()
    local success, data = pcall(function() return readfile(API_STATE_FILE) end)
    if success then
        local loadedState = Http:JSONDecode(data)
        for key, value in pairs(loadedState) do
            if apiState[key] ~= nil then apiState[key] = value end
        end
    end
end

local function playFoundSound()
    local success, err = pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = settings.customSoundId
        sound.Volume = 1
        sound.PlayOnRemove = true
        sound.Parent = workspace
        sound:Destroy()
    end)
    if not success then print("Failed to play sound:", err) end
end

local function parseGenerationInput(input)
    input = input:lower():gsub("[^0-9kmb/s]", "")
    local number = input:match("(%d+%.?%d*)")
    local multiplier = 1
    if input:find("k") then
        multiplier = 1000
    elseif input:find("m") then
        multiplier = 1000000
    elseif input:find("b") then
        multiplier = 1000000000
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

local function getMutationTextAndColor(mutation)
    local mutationColors = {
        Gold = Color3.fromRGB(255, 215, 0),
        Diamond = Color3.fromRGB(0, 255, 255),
        Lava = Color3.fromRGB(255, 100, 0),
        Bloodrot = Color3.fromRGB(255, 0, 0),
        Candy = Color3.fromRGB(255, 182, 193),
        Normal = Color3.fromRGB(255, 255, 255),
        Default = Color3.fromRGB(255, 255, 255)
    }
    if not mutation or mutation.Visible == false then
        return "Normal", Color3.fromRGB(255, 255, 255), false
    end
    local name = mutation.Text
    if name == "" then return "Normal", Color3.fromRGB(255, 255, 255), false end
    if name == "Rainbow" then return "Rainbow", Color3.new(1, 1, 1), true end
    return name, mutationColors[name] or Color3.fromRGB(255, 255, 255), false
end

local function isPlayerBase(plot)
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yourBase = sign:FindFirstChild("YourBase")
        if yourBase and yourBase.Enabled then return true end
    end
    return false
end

local function getAllPodiums()
    local cachedPlots = Workspace:FindFirstChild("Plots")
    local cachedPodiums = nil
    local lastPodiumCheck = 0
    local PODIUM_CACHE_DURATION = 1

    if cachedPodiums and tick() - lastPodiumCheck < PODIUM_CACHE_DURATION then
        return cachedPodiums
    end
    
    local podiums = {}
    if not cachedPlots then
        lastPodiumCheck = tick()
        cachedPodiums = podiums
        return podiums 
    end
    
    local plotChildren = cachedPlots:GetChildren()
    for i = 1, #plotChildren do
        local plot = plotChildren[i]
        if not isPlayerBase(plot) then
            local animalPods = plot:FindFirstChild("AnimalPodiums")
            if animalPods then
                local podChildren = animalPods:GetChildren()
                for j = 1, #podChildren do
                    local pod = podChildren[j]
                    local base = pod:FindFirstChild("Base")
                    if base then
                        local spawn = base:FindFirstChild("Spawn")
                        if spawn then
                            local attach = spawn:FindFirstChild("Attachment")
                            if attach then
                                local animalOverhead = attach:FindFirstChild("AnimalOverhead")
                                if animalOverhead and (base:IsA("BasePart") or base:IsA("Model")) then
                                    table.insert(podiums, { 
                                        overhead = animalOverhead, 
                                        base = base,
                                        pod = pod,
                                        plot = plot
                                    })
                                end
                            end
                        end
                    end
                end
            end
            if plot:IsA("Model") then
                for _, model in pairs(plot:GetChildren()) do
                    if model:IsA("Model") then
                        for _, obj in pairs(model:GetDescendants()) do
                            if obj:IsA("Attachment") and obj.Name == "OVERHEAD_ATTACHMENT" then
                                local overhead = obj:FindFirstChild("AnimalOverhead")
                                if overhead then
                                    local base = model:FindFirstChild("Base") or model
                                    if base and (base:IsA("BasePart") or base:IsA("Model")) then
                                        table.insert(podiums, { 
                                            overhead = overhead, 
                                            base = base,
                                            pod = model,
                                            plot = plot
                                        })
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    lastPodiumCheck = tick()
    cachedPodiums = podiums
    return podiums
end

local function getPrimaryPartPosition(obj)
    if not obj then return nil end
    if obj:IsA("Model") and obj.PrimaryPart then
        return obj.PrimaryPart.Position
    elseif obj:IsA("BasePart") then
        return obj.Position
    end
    return nil
end

local function getServersFromAPI(baseUrl, isMainAPI)
    local servers = {}
    local cursor = ""
    local maxPages = 3
    if isMainAPI then
        apiState.mainApiUses = apiState.mainApiUses + 1
        saveAPIState()
    end
    for page = 1, maxPages do
        local url = baseUrl
        if cursor ~= "" then url = url .. "&cursor=" .. cursor end
        local success, response = pcall(function() return game:HttpGet(url) end)
        if not success then
            print("HTTP request failed:", response)
            break
        end
        local body = Http:JSONDecode(response)
        if not body.data then break end
        for _, v in body.data do
            if v.playing and v.maxPlayers and v.playing >= settings.minPlayers and v.playing < v.maxPlayers and v.id ~= game.JobId and not table.find(settings.recentVisited, v.id) then
                table.insert(servers, v.id)
                if not table.find(apiState.cachedServers, v.id) then
                    table.insert(apiState.cachedServers, v.id)
                end
            end
        end
        cursor = body.nextPageCursor or ""
        if cursor == "" then break end
    end
    while #apiState.cachedServers > 300 do
        table.remove(apiState.cachedServers, 1)
    end
    apiState.lastCacheUpdate = tick()
    saveAPIState()
    return servers
end

local function getCachedServers()
    local availableServers = {}
    local recentCount = math.min(#settings.recentVisited, 5)
    local recentServers = {}
    for i = #settings.recentVisited - recentCount + 1, #settings.recentVisited do
        if settings.recentVisited[i] then
            table.insert(recentServers, settings.recentVisited[i])
        end
    end
    for _, serverId in ipairs(apiState.cachedServers) do
        if not table.find(recentServers, serverId) and serverId ~= game.JobId then
            table.insert(availableServers, serverId)
        end
    end
    return availableServers
end

local function findClosestModel(podiumBase, models)
    if not podiumBase then return nil end
    local podiumPos = getPrimaryPartPosition(podiumBase)
    if not podiumPos then return nil end
    local closestModel = nil
    local minDistance = math.huge
    for i = 1, #models do
        local model = models[i]
        local modelPos = getPrimaryPartPosition(model)
        if modelPos then
            local distance = (podiumPos - modelPos).Magnitude
            if distance < minDistance then
                minDistance = distance
                closestModel = model
            end
        end
    end
    return closestModel
end

local function isStolenPodium(overhead)
    if not overhead then return false end
    local stolenLabel = overhead:FindFirstChild("Stolen")
    if stolenLabel and stolenLabel:IsA("TextLabel") then
        return string.upper(stolenLabel.Text) == "FUSING"
    end
    return false
end

local function getAvailableServers()
    if apiState.mainApiUses >= 3 or apiState.useCachedServers then
        if not checkAPIAvailability() then
            apiState.useCachedServers = true
            saveAPIState()
            return getCachedServers()
        else
            apiState.useCachedServers = false
            apiState.mainApiUses = 0
            saveAPIState()
        end
    end
    local mainAPI = "https://games.roblox.com/v1/games/" .. ALLOWED_PLACE_ID .. "/servers/Public?sortOrder=" .. settings.sortOrder .. "&limit=10&excludeFullGames=true"
    local servers = getServersFromAPI(mainAPI, true)
    if #servers > 0 then return servers end
    apiState.useCachedServers = true
    saveAPIState()
    return getCachedServers()
end

local function matchesFilters(labels, overhead)
    if isStolenPodium(overhead) then
        print("Podium skipped: Stolen/Fusing")
        return false
    end
    local genValue = extractNumber(labels.Generation)
    print("Checking pet:", labels.DisplayName, "Generation:", genValue, "Mutation:", labels.Mutation, "Rarity:", labels.Rarity)
    local hasTargetName = false
    if #settings.targetNames > 0 then
        for i = 1, #settings.targetNames do
            local name = settings.targetNames[i]
            if name ~= "" and string.find(string.lower(labels.DisplayName), string.lower(name)) then
                print("Name match:", name)
                hasTargetName = true
                break
            end
        end
        if not hasTargetName then
            print("No name match for:", labels.DisplayName)
            return false
        end
    else
        print("No target names specified, checking other filters")
    end
    if settings.targetMutation ~= "" then
        if string.lower(labels.Mutation) ~= string.lower(settings.targetMutation) then
            print("Mutation mismatch:", labels.Mutation, "Expected:", settings.targetMutation)
            return false
        end
        return true
    end
    if hasTargetName then return true end
    if genValue < settings.minGeneration then
        print("Generation too low:", genValue, "Expected:", settings.minGeneration)
        return false
    end
    if #settings.blacklistNames > 0 then
        for i = 1, #settings.blacklistNames do
            local name = settings.blacklistNames[i]
            if name ~= "" and string.find(string.lower(labels.DisplayName), string.lower(name)) then
                print("Blacklisted name:", name)
                return false
            end
        end
    end
    if settings.targetRarity ~= "" then
        if string.lower(labels.Rarity) ~= string.lower(settings.targetRarity) then
            print("Rarity mismatch:", labels.Rarity, "Expected:", settings.targetRarity)
            return false
        end
    end
    print("Pet matches filters:", labels.DisplayName)
    return true
end

local function checkPodiumsForWebhooksAndFilters()
    if game.PlaceId ~= ALLOWED_PLACE_ID then
        print("Wrong Place ID for podium check:", game.PlaceId)
        return false, {}
    end
    local podiums = getAllPodiums()
    local filteredPodiums = {}
    local workspaceModels = {}
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") then table.insert(workspaceModels, child) end
    end
    for i = 1, #podiums do
        local podium = podiums[i]
        if isStolenPodium(podium.overhead) then continue end
        local displayNameLabel = podium.overhead:FindFirstChild("DisplayName")
        local genLabel = podium.overhead:FindFirstChild("Generation")
        local rarityLabel = podium.overhead:FindFirstChild("Rarity")
        if displayNameLabel and genLabel and rarityLabel then
            local mutation = podium.overhead:FindFirstChild("Mutation")
            local mutText, _, _ = getMutationTextAndColor(mutation)
            local modelText = string.format("%s Generation: %s Mutation: %s Rarity: %s", 
                displayNameLabel.Text, genLabel.Text, mutText, rarityLabel.Text)
            print("Checking podium:", modelText)
            local labels = {
                DisplayName = displayNameLabel.Text,
                Generation = genLabel.Text,
                Mutation = mutText,
                Rarity = rarityLabel.Text
            }
            if matchesFilters(labels, podium.overhead) then
                local closestModel = findClosestModel(podium.base, workspaceModels)
                table.insert(filteredPodiums, { 
                    base = podium.base, 
                    labels = labels, 
                    closestModel = closestModel, 
                    overhead = podium.overhead,
                    pod = podium.pod,
                    plot = podium.plot
                })
            end
        end
    end
    return #filteredPodiums > 0, filteredPodiums
end

local function tryTeleportWithRetries()
    if not isRunning then return end
    local attempts = 0
    local maxAttempts = 5
    while attempts < maxAttempts and isRunning do
        local servers = getAvailableServers()
        if #servers == 0 then
            print("No servers available, retrying...")
            task.wait(RETRY_DELAY)
            attempts = attempts + 1
            continue
        end
        local randomServer = servers[math.random(1, #servers)]
        local success, err = pcall(function()
            TPS:TeleportToPlaceInstance(ALLOWED_PLACE_ID, randomServer)
        end)
        if success then
            print("Teleport successful to server:", randomServer)
            return
        else
            print("Teleport failed:", err)
            if not isRunning then return end
            task.wait(RETRY_DELAY)
            attempts = attempts + 1
        end
    end
    if isRunning then
        isRunning = false
        showNotification("Error", "Failed to teleport after retries.")
    end
end

local function monitorFoundPodiums()
    if monitoringConnection then monitoringConnection:Disconnect() end
    monitoringConnection = RunService.Heartbeat:Connect(function()
        if not isRunning or #foundPodiumsData == 0 then return end
        local lostAny = false
        local lostPodiums = {}
        for i = #foundPodiumsData, 1, -1 do
            local data = foundPodiumsData[i]
            if data and data.overhead and data.overhead.Parent then
                local displayNameLabel = data.overhead:FindFirstChild("DisplayName")
                if displayNameLabel and displayNameLabel.Text then
                    local currentLabels = {
                        DisplayName = displayNameLabel.Text,
                        Generation = data.labels and data.labels.Generation or "Unknown",
                        Mutation = data.labels and data.labels.Mutation or "Normal",
                        Rarity = data.labels and data.labels.Rarity or "None"
                    }
                    if not matchesFilters(currentLabels, data.overhead) then
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
                if data then
                    table.insert(lostPodiums, data.labels.DisplayName)
                    table.remove(foundPodiumsData, i)
                    lostAny = true
                end
            end
        end
        if lostAny then
            local lostText = #lostPodiums > 0 and "Lost: " .. table.concat(lostPodiums, ", ") or "Lost podium(s)"
            showNotification("Not found", lostText)
        end
    end)
end

local function runServerCheck()
    if not isRunning then return end
    local success, foundPets, results = pcall(checkPodiumsForWebhooksAndFilters)
    if not success then
        print("Error in checkPodiumsForWebhooksAndFilters:", foundPets)
        showNotification("Error", "Failed to check podiums: " .. tostring(foundPets))
        return
    end
    if foundPets and #results > 0 then
        foundPodiumsData = results
        local displayResults = {}
        for _, entry in ipairs(results) do
            local genValue = extractNumber(entry.labels.Generation)
            table.insert(displayResults, {entry = entry, gen = genValue})
        end
        table.sort(displayResults, function(a, b) return a.gen > b.gen end)
        local foundText = ""
        local numToShow = math.min(3, #displayResults)
        for i = 1, numToShow do
            local entry = displayResults[i].entry
            local genFormatted = formatGeneration(entry.labels.Generation)
            foundText = foundText .. entry.labels.DisplayName .. " (" .. genFormatted .. ")"
            if i < numToShow then foundText = foundText .. ", " end
        end
        if #displayResults > 3 then
            local extra = #displayResults - 3
            foundText = foundText .. " and " .. extra .. " more..."
        end
        showNotification("Found", foundText)
        playFoundSound()
        monitorFoundPodiums()
        return
    end
    if not isRunning then return end
    settings.hopCount = settings.hopCount + 1
    saveSettings()
    tryTeleportWithRetries()
end

local function startHopping()
    print("Starting server hopping...")
    if isRunning then
        showNotification("Warning", "Search is already running!")
        return
    end
    local fileSuccess, _ = pcall(function()
        if not isfile("hopStarted.txt") then writefile("hopStarted.txt", "true") end
    end)
    if fileSuccess then
        showNotification("Search started", "Looking for target pets...")
    else
        print("File I/O failed, continuing without writing hopStarted.txt")
        showNotification("Search started", "Looking for target pets...")
    end
    isRunning = true
    task.spawn(function()
        while isRunning do
            local success, err = pcall(runServerCheck)
            if not success then
                print("Error in runServerCheck:", err)
                showNotification("Error", "Server check failed: " .. tostring(err))
            end
            if #foundPodiumsData > 0 then break end
            task.wait(0.1)
        end
    end)
end

local function stopHopping()
    print("Stop button tapped")
    isRunning = false
    foundPodiumsData = {}
    if currentConnection then
        currentConnection:Disconnect()
        currentConnection = nil
    end
    if monitoringConnection then
        monitoringConnection:Disconnect()
        monitoringConnection = nil
    end
    showNotification("Stopped", "Pet search stopped.")
end

local function createSettingsGUI()
    print("Attempting to create GUI...")
    local success, err = pcall(function()
        local playerGui = player:WaitForChild("PlayerGui", 5)
        if not playerGui then error("PlayerGui not found") end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ServerHopperGUI"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = playerGui
        print("ScreenGui created and parented to PlayerGui")
        
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0.5, 0, 0.6, 0)
        mainFrame.Position = UDim2.new(guiState.position.XScale, guiState.position.XOffset, guiState.position.YScale, guiState.position.YOffset)
        mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui
        
        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 12)
        mainCorner.Parent = mainFrame
        
        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 50)
        titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        titleBar.BorderSizePixel = 0
        titleBar.Parent = mainFrame
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -80, 1, 0)
        titleLabel.Position = UDim2.new(0, 10, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "Pet Search"
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextSize = 20
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = titleBar
        
        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0, 40, 0, 40)
        closeButton.Position = UDim2.new(1, -50, 0, 5)
        closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeButton.BorderSizePixel = 0
        closeButton.Text = "X"
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.TextSize = 18
        closeButton.Font = Enum.Font.GothamBold
        closeButton.Parent = titleBar
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 10)
        closeCorner.Parent = closeButton
        
        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1, 0, 1, -50)
        contentFrame.Position = UDim2.new(0, 0, 0, 50)
        contentFrame.BackgroundTransparency = 1
        contentFrame.Parent = mainFrame
        
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, -10, 1, -100)
        scrollFrame.Position = UDim2.new(0, 5, 0, 5)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.ScrollBarThickness = 8
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 130)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 180)
        scrollFrame.Parent = contentFrame
        
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)
        layout.Parent = scrollFrame
        
        local function createInputField(name, placeholder, defaultValue, layoutOrder, settingKey)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 60)
            container.BackgroundTransparency = 1
            container.LayoutOrder = layoutOrder
            container.Parent = scrollFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = Color3.fromRGB(220, 220, 230)
            label.TextSize = 18
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            local inputFrame = Instance.new("Frame")
            inputFrame.Size = UDim2.new(1, -10, 0, 35)
            inputFrame.Position = UDim2.new(0, 0, 0, 25)
            inputFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            inputFrame.BorderSizePixel = 0
            inputFrame.Parent = container
            
            local inputCorner = Instance.new("UICorner")
            inputCorner.CornerRadius = UDim.new(0, 8)
            inputCorner.Parent = inputFrame
            
            local textBox = Instance.new("TextBox")
            textBox.Size = UDim2.new(1, -10, 1, 0)
            textBox.Position = UDim2.new(0, 5, 0, 0)
            textBox.BackgroundTransparency = 1
            textBox.Text = defaultValue or ""
            textBox.PlaceholderText = placeholder
            textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            textBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 150)
            textBox.TextSize = 16
            textBox.Font = Enum.Font.Gotham
            textBox.Parent = inputFrame
            
            textBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    print("Input changed:", settingKey, textBox.Text)
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
                    print("Updated settings:", Http:JSONEncode(settings))
                end
            end)
            return textBox
        end
        
        local targetNameInput = createInputField("Target Pet Name", "Huge Dragon, Noobini Pizzanini", settings.targetNames[1] or "", 1, "targetNames")
        local minGenInput = createInputField("Min. Generation", "1K/s, 1M/s", formatGeneration(settings.minGeneration), 2, "minGeneration")
        local rarityInput = createInputField("Rarity", "Secret, Mythical", settings.targetRarity, 3, "targetRarity")
        
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Size = UDim2.new(1, -10, 0, 60)
        buttonContainer.Position = UDim2.new(0, 5, 1, -65)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = contentFrame
        
        local startButton = Instance.new("TextButton")
        startButton.Size = UDim2.new(0.48, -5, 0, 50)
        startButton.Position = UDim2.new(0, 0, 0, 5)
        startButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        startButton.BorderSizePixel = 0
        startButton.Text = "START"
        startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        startButton.TextSize = 18
        startButton.Font = Enum.Font.GothamBold
        startButton.Parent = buttonContainer
        
        local startCorner = Instance.new("UICorner")
        startCorner.CornerRadius = UDim.new(0, 10)
        startCorner.Parent = startButton
        
        local stopButton = Instance.new("TextButton")
        stopButton.Size = UDim2.new(0.48, -5, 0, 50)
        stopButton.Position = UDim2.new(0.52, 5, 0, 5)
        stopButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        stopButton.BorderSizePixel = 0
        stopButton.Text = "STOP"
        stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        stopButton.TextSize = 18
        stopButton.Font = Enum.Font.GothamBold
        stopButton.Parent = buttonContainer
        
        local stopCorner = Instance.new("UICorner")
        stopCorner.CornerRadius = UDim.new(0, 10)
        stopCorner.Parent = stopButton
        
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, -10, 0, 20)
        statusLabel.Position = UDim2.new(0, 5, 1, -85)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = isRunning and "Searching..." or "Ready to search..."
        statusLabel.TextColor3 = isRunning and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(150, 150, 160)
        statusLabel.TextSize = 16
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.Parent = contentFrame
        
        local function updateScrollCanvas()
            local contentHeight = layout.AbsoluteContentSize.Y + 20
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        end
        updateScrollCanvas()
        
        startButton.MouseButton1Click:Connect(function()
            print("Start button tapped")
            statusLabel.Text = "Searching..."
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            startHopping()
        end)
        
        stopButton.MouseButton1Click:Connect(function()
            stopHopping()
            statusLabel.Text = "Search stopped."
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end)
        
        closeButton.MouseButton1Click:Connect(function()
            print("Close button tapped")
            stopHopping()
            screenGui:Destroy()
            print("ScreenGui destroyed")
        end)
        
        local dragging = false
        local dragStart = nil
        local startPos = nil
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                print("Dragging started")
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                mainFrame.Position = newPos
                guiState.position = {
                    XScale = newPos.X.Scale,
                    XOffset = newPos.X.Offset,
                    YScale = newPos.Y.Scale,
                    YOffset = newPos.Y.Offset
                }
                saveGUIState()
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                print("Dragging ended")
                dragging = false
            end
        end)
    end)
    if not success then
        print("Failed to create GUI:", err)
        showNotification("Error", "Failed to create GUI: " .. tostring(err))
    end
end

local function autoExecute()
    print("Checking for auto-execution...")
    if game.PlaceId == ALLOWED_PLACE_ID then
        print("Place ID matches, starting auto-execution...")
        task.wait(0.1)
        local success, err = pcall(startHopping)
        if not success then
            print("Auto-execution failed:", err)
            showNotification("Error", "Auto-execution failed: " .. tostring(err))
        end
    else
        print("Wrong Place ID:", game.PlaceId, "Expected:", ALLOWED_PLACE_ID)
        showNotification("Error", "This script only works in Place ID " .. ALLOWED_PLACE_ID)
    end
end

local function testExecutorCompatibility()
    local fileSuccess, fileResult = pcall(function()
        writefile("test.txt", "test")
        return isfile("test.txt") and readfile("test.txt") == "test"
    end)
    print("File I/O test:", fileSuccess and "Success" or "Failed: " .. tostring(fileResult))
    
    local httpSuccess, httpResult = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/109983668079237/servers/Public?limit=10")
    end)
    print("HTTP test:", httpSuccess and "Success" or "Failed: " .. tostring(httpResult))
    
    setCoreSupported = testSetCore()
    print("SetCore test:", setCoreSupported and "Success" or "Failed")
    
    local guiSuccess, guiResult = pcall(function()
        local testGui = Instance.new("ScreenGui")
        testGui.Name = "TestGUI"
        testGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        testGui.Parent = player.PlayerGui
        local testFrame = Instance.new("Frame")
        testFrame.Size = UDim2.new(0.2, 0, 0.2, 0)
        testFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
        testFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        testFrame.Parent = testGui
        print("Test GUI created and parented to PlayerGui")
        task.wait(2)
        testGui:Destroy()
        print("Test GUI destroyed")
        return true
    end)
    print("GUI creation test:", guiSuccess and "Success" or "Failed: " .. tostring(guiResult))
end

testExecutorCompatibility()
loadSettings()
loadGUIState()
loadAPIState()

print("Checking Place ID:", game.PlaceId, "Expected:", ALLOWED_PLACE_ID)
local success, err = pcall(createSettingsGUI)
if not success then
    print("Error creating GUI:", err)
    showNotification("Error", "Failed to create GUI: " .. tostring(err))
else
    print("GUI created successfully")
end
autoExecute()
