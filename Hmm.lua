-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")
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
    if lib then
        lib:Notification("KRYPTON HUB", "Error: " .. message, 5)
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
    print("Loading screen completed")
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
print("Player loaded:", player)
print("Character loaded:", player.Character)
if not game:IsLoaded() then
    game.Loaded:Wait()
end
print("Game loaded")

-- Load UI Library and Config Manager
local success, result = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/Lib")
end)
if not success then
    logError("Failed to load UI library: " .. tostring(result))
    return
end
local lib = loadstring(result)()

success, result = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/ConfigManager")
end)
if not success then
    logError("Failed to load Config Manager: " .. tostring(result))
    return
end
local FlagsManager = loadstring(result)()

-- Service Wrapper
local GetService, cloneref = game.GetService, cloneref or function(r) return r end
local services = setmetatable({}, {
    __index = function(self, service)
        local r = cloneref(GetService(game, service))
        self[service] = r
        return r
    end
})

-- Role Checker
local LRM_UserNote = "Owner"
local function RoleChecker()
    if string.find(LRM_UserNote, "Ad Reward") then
        return "Free Version"
    elseif string.find(LRM_UserNote, "Premium") then
        return "Premium Version"
    elseif string.find(LRM_UserNote, "Owner") then
        return "Developer agent_duke13"
    else
        return "No Role Assigned"
    end
}

-- UI Setup
local gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
local main = lib:Load({
    Title = gameName .. " 〢 discord.gg/jXSyQFnQCY 〢 " .. RoleChecker(),
    ToggleButton = "rbxassetid://105059922903197",
    BindGui = Enum.KeyCode.RightControl,
})

local tabs = {
    Information = main:AddTab("Information"),
    General = main:AddTab("General"),
    Config = main:AddTab("Config"),
}
main:SelectTab()

local Sections = {
    Welcome = tabs.Information:AddSection({Default = true, Locked = true}),
    Discord = tabs.Information:AddSection({Default = true, Locked = true}),
    Main = tabs.General:AddSection({Title = "Main Features", Description = "", Default = false, Locked = false}),
    Teleport = tabs.General:AddSection({Title = "Teleport", Description = "", Default = false, Locked = false}),
    Character = tabs.General:AddSection({Title = "Character", Description = "", Default = false, Locked = false}),
    Shop = tabs.General:AddSection({Title = "Shop", Description = "", Default = false, Locked = false}),
    Visuals = tabs.General:AddSection({Title = "Visuals", Description = "", Default = false, Locked = false}),
}

getgenv().WelcomeParagraph = Sections.Welcome:AddParagraph({
    Title = "Loading...",
    Description = "Please wait.. If you've been stuck on this for a long time please join our discord and report it."
})
getgenv().WelcomeParagraph:SetTitle("Information")
getgenv().WelcomeParagraph:SetDesc([[
    Welcome to Krypton Hub! Thank you for choosing Krypton Hub.
    We're always working on improvements and features.
    If you experience issues or have feedback, don't hesitate to join our Discord server.
    Recent Updates:
    [+] Switched to new UI (thanks to x2zu)
    [+] Added Shop, Visuals, Character features
    Join the Discord for help, suggestions, and the latest updates.
]])

Sections.Discord:AddParagraph({
    Title = "Found a bug?",
    Description = "Please report by joining our Discord."
})
Sections.Discord:AddButton({
    Title = "Copy Discord Invite",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/jXSyQFnQCY")
            lib:Notification("KRYPTON HUB", "Copied Discord invite to clipboard!", 5)
        else
            lib:Notification("KRYPTON HUB", "Clipboard not supported on this device", 5)
        end
    end,
})

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

-- Update Character References
local function updateCharacterReferences()
    character = player.Character
    if character then
        hrp = character:FindFirstChild("HumanoidRootPart")
        humanoid = character:FindFirstChildOfClass("Humanoid")
        print("Character updated - HRP:", hrp, "Humanoid:", humanoid)
    else
        hrp = nil
        humanoid = nil
        print("No character found")
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
    print("Godmode setup completed")
end
if humanoid then
    local success, err = pcall(setupGlobalGodmode)
    if not success then
        logError("Godmode setup failed: " .. err)
    end
end
player.CharacterAdded:Connect(function()
    updateCharacterReferences()
    if humanoid then
        local success, err = pcall(setupGlobalGodmode)
        if not success then
            logError("Godmode setup failed: " .. err)
        end
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
        print("PromptAttachment found for", p.Name)
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
    else
        print("No PromptAttachment for", p and p.Name or "nil")
    end
end

local plots = Workspace:FindFirstChild("Plots")
if plots then
    for _, plot in pairs(plots:GetChildren()) do
        print("Checking plot:", plot.Name)
        if plot:FindFirstChild("AnimalPodiums") then
            for _, podium in pairs(plot.AnimalPodiums:GetChildren()) do
                dop(podium)
            end
            table.insert(connections.ProximityPrompts, plot.AnimalPodiums.ChildAdded:Connect(dop))
        end
    end
else
    logError("Plots not found in Workspace")
end

Sections.Main:AddToggle("InstantProximityPrompt", {
    Title = "Instant Proximity Prompts",
    Default = false,
    Callback = function(state)
        print("Instant Proximity toggled")
        ipp = state
        if ipp then
            for _, v in pairs(pp) do
                v.HoldDuration = 0
            end
            lib:Notification("KRYPTON HUB", "Instant Proximity enabled", 3)
        else
            for _, v in pairs(pp) do
                v.HoldDuration = 0.5
            end
            lib:Notification("KRYPTON HUB", "Instant Proximity disabled", 3)
        end
    end
})

-- Teleport Features
Sections.Teleport:AddToggle("TweenToBase", {
    Title = "Tween to Base",
    Description = "Smoothly teleports to your base",
    Default = false,
    Callback = function(state)
        print("Tween to Base toggled")
        if not state then
            tweenActive = false
            lib:Notification("KRYPTON HUB", "Tween stopped", 3)
            return
        end
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
            lib:Notification("KRYPTON HUB", "Tweening to base...", 3)
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
                lib:Notification("KRYPTON HUB", "Reached base", 3)
            end)
        else
            logError("Base or character components not found")
        end
    end
})

-- Slow Flight
Sections.Main:AddToggle("SlowFlight", {
    Title = "Slow Flight",
    Description = "Fly using camera direction",
    Default = false,
    Callback = function(state)
        print("Slow Flight toggled")
        flyActive = state
        if flyActive then
            lib:Notification("KRYPTON HUB", "Slow Flight enabled - Use camera direction", 3)
            connections.Fly = RunService.Stepped:Connect(function()
                updateCharacterReferences()
                if flyActive and hrp then
                    hrp.Velocity = Workspace.CurrentCamera.CFrame.LookVector * config.flySpeed
                end
            end)
        else
            lib:Notification("KRYPTON HUB", "Slow Flight disabled", 3)
            if connections.Fly then
                connections.Fly:Disconnect()
                connections.Fly = nil
            end
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end
})

-- Float
Sections.Main:AddToggle("Float", {
    Title = "Float",
    Description = "Float in the air",
    Default = false,
    Callback = function(state)
        print("Float toggled")
        floatActive = state
        if floatActive then
            lib:Notification("KRYPTON HUB", "Float enabled", 3)
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
            lib:Notification("KRYPTON HUB", "Float disabled", 3)
            if connections.Float then
                connections.Float:Destroy()
                connections.Float = nil
            end
        end
    end
})

-- Semi-Invisible
local function semiInvisibleFunction()
    print("Semi-Invisible toggled")
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
            lib:Notification("KRYPTON HUB", "Semi-Invisible enabled (F key to toggle)", 3)
        end
    else
        disableInvisibility()
        isInvisible = false
        lib:Notification("KRYPTON HUB", "Semi-Invisible disabled", 3)
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

Sections.Character:AddToggle("SemiInvisible", {
    Title = "Semi Invisible",
    Description = "Makes you partially invisible (F key to toggle)",
    Default = false,
    Callback = function(state)
        print("Semi-Invisible button clicked")
        semiInvisibleFunction()
    end
})
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F and not gameProcessed then
        print("F key pressed for Semi-Invisible")
        semiInvisibleFunction()
    end
end)

-- Infinite Jump
Sections.Character:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(state)
        print("Infinite Jump toggled")
        infJumpActive = state
        if infJumpActive then
            lib:Notification("KRYPTON HUB", "Infinite Jump enabled", 3)
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
            lib:Notification("KRYPTON HUB", "Infinite Jump disabled", 3)
            if connections.Jump then
                connections.Jump:Disconnect()
                connections.Jump = nil
            end
        end
    end
})

-- Speed Booster
Sections.Character:AddToggle("SpeedBooster", {
    Title = "Speed Booster",
    Description = "Increases movement speed",
    Default = false,
    Callback = function(state)
        print("Speed Booster toggled")
        speedActive = state
        if speedActive then
            lib:Notification("KRYPTON HUB", "Speed Booster enabled", 3)
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
                        inputDirection.X * config.walkSpeed,
                        HRP.AssemblyLinearVelocity.Y,
                        inputDirection.Z * config.walkSpeed
                    )
                else
                    HRP.AssemblyLinearVelocity = Vector3.new(0, HRP.AssemblyLinearVelocity.Y, 0)
                end
            end)
        else
            lib:Notification("KRYPTON HUB", "Speed Booster disabled", 3)
            if connections.Speed then
                connections.Speed:Disconnect()
                connections.Speed = nil
            end
            updateCharacterReferences()
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end
    end
})

-- God Mode
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

Sections.Character:AddToggle("GodMode", {
    Title = "God Mode",
    Default = false,
    Callback = function(state)
        print("God Mode toggled")
        godModeToggle = state
        if godModeToggle then
            lib:Notification("KRYPTON HUB", "God Mode enabled", 3)
            enableGodMode()
        else
            lib:Notification("KRYPTON HUB", "God Mode disabled", 3)
            disableGodMode()
        end
    end
})

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

Sections.Character:AddToggle("WalkSpeed", {
    Title = "WalkSpeed (50)",
    Default = false,
    Callback = function(state)
        print("WalkSpeed toggled")
        walkSpeedToggle = state
        if walkSpeedToggle then
            lib:Notification("KRYPTON HUB", "WalkSpeed enabled", 3)
            setWalkSpeed(config.walkSpeed)
        else
            lib:Notification("KRYPTON HUB", "WalkSpeed disabled", 3)
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
    end
})

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

    Sections.Shop:AddDropdown("ShopItemDropdown", {
        Title = "Select Item to Purchase",
        Description = "Pick an item from the shop list.",
        Options = dropdownOptions,
        Default = "",
        PlaceHolder = "Search Item...",
        Multiple = false,
        Callback = function(selected)
            print("Shop option selected:", selected)
            for _, item in pairs(allItems) do
                if selected == item.Name then
                    local success, err = pcall(function()
                        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/CoinsShopService/RequestBuy")
                        if remote then
                            remote:InvokeServer(item.ID)
                        else
                            error("Shop remote not found")
                        end
                    end)
                    lib:Notification(
                        "KRYPTON HUB",
                        success and ("Tried to buy: " .. item.Name) or ("Error: " .. tostring(err)),
                        3
                    )
                    break
                end
            end
        end
    })
end

-- ESP
Sections.Visuals:AddToggle("ESP", {
    Title = "Player ESP",
    Default = false,
    Callback = function(state)
        print("Player ESP toggled")
        espActive = state
        if espActive then
            lib:Notification("KRYPTON HUB", "ESP enabled", 3)
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
            lib:Notification("KRYPTON HUB", "ESP disabled", 3)
            for _, folder in pairs(espFolders) do
                if folder then folder:Destroy() end
            end
            espFolders = {}
        end
    end
})

Players.PlayerRemoving:Connect(function(otherPlayer)
    if espFolders[otherPlayer] then
        espFolders[otherPlayer]:Destroy()
        espFolders[otherPlayer] = nil
        print("ESP folder removed for", otherPlayer.Name)
    end
end)

-- Fullbright
Sections.Visuals:AddToggle("Fullbright", {
    Title = "Fullbright",
    Default = false,
    Callback = function(state)
        print("Fullbright toggled")
        fullbrightActive = state
        if fullbrightActive then
            lib:Notification("KRYPTON HUB", "Fullbright enabled", 3)
            originalBrightness = Lighting.Brightness
            originalClockTime = Lighting.ClockTime
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            lib:Notification("KRYPTON HUB", "Fullbright disabled", 3)
            if originalBrightness then
                Lighting.Brightness = originalBrightness
            end
            if originalClockTime then
                Lighting.ClockTime = originalClockTime
            end
            Lighting.GlobalShadows = true
        end
    end
})

-- Config Setup
FlagsManager:SetLibrary(lib)
FlagsManager:SetIgnoreIndexes({})
FlagsManager:SetFolder("Config/KryptonHub")
FlagsManager:InitSaveSystem(tabs.Config)

-- Auto-cleanup on character death
player.CharacterAdded:Connect(function()
    print("Character respawned")
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
    lib:Notification("KRYPTON HUB", "Character respawned - Ready", 3)
end)

-- Cleanup on Script End
game:BindToClose(function()
    print("Cleaning up on script end")
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

lib:Notification("KRYPTON HUB", "Krypton Hub Loaded! Press RightControl to toggle GUI.", 5)
print("Krypton Hub - Complete Edition Loaded!")
print("Features: Tween to Base, Slow Flight, Float, Semi-Invisible, Infinite Jump, Speed Booster, God Mode, WalkSpeed, ESP, Fullbright, Instant Proximity, Shop")
print("Controls: RightControl to toggle GUI, F key to toggle semi-invisible")
print("Discord: https://discord.gg/jXSyQFnQCY")
