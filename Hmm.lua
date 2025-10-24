-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

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
repeat task.wait() until player and player.Character
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Load UI Library and Config Manager
local success, result = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/Lib")
end)
if not success then
    warn("Failed to load UI library: " .. tostring(result))
    return
end
local lib = loadstring(result)()

success, result = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/ConfigManager")
end)
if not success then
    warn("Failed to load Config Manager: " .. tostring(result))
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
        return "Developer x2zu"
    else
        return "No Role Assigned"
    end
end

-- UI Setup
local main = lib:Load({
    Title = game:GetService("MarketplaceService"):GetProductInfo(109983668079237).Name .. ' 〢 discord.gg/jXSyQFnQCY 〢 ' .. RoleChecker(),
    ToggleButton = "rbxassetid://95131705390407",
    BindGui = Enum.KeyCode.RightControl,
})

local tabs = {
    Information = main:AddTab("Information"),
    General = main:AddTab("General"),
    Movement = main:AddTab("Movement"),
    Visuals = main:AddTab("Visuals"),
    Config = main:AddTab("Config"),
}
main:SelectTab()

local Sections = {
    Welcome = tabs.Information:AddSection({Default = true, Locked = true}),
    Discord = tabs.Information:AddSection({Default = true, Locked = true}),
    Main = tabs.General:AddSection({Title = "Instant Proximity", Description = "", Default = false, Locked = false}),
    Teleport = tabs.General:AddSection({Title = "Teleport", Description = "", Default = false, Locked = false}),
    MiscTabs = tabs.General:AddSection({Title = "Character", Description = "", Default = false, Locked = false}),
    Shop = tabs.General:AddSection({Title = "Shop", Description = "", Default = false, Locked = false}),
    MovementMain = tabs.Movement:AddSection({Title = "Movement Features", Description = "", Default = false, Locked = false}),
    Flight = tabs.Movement:AddSection({Title = "Flight", Description = "", Default = false, Locked = false}),
    VisualTabs = tabs.Visuals:AddSection({Title = "ESP", Description = "", Default = false, Locked = false}),
    Effects = tabs.Visuals:AddSection({Title = "Visual Effects", Description = "", Default = false, Locked = false}),
}

Sections.Discord:AddParagraph({
    Title = "Found a bug?",
    Description = "Please report by joining our Discord."
})
Sections.Discord:AddButton({
    Title = "Copy Discord Invite",
    Callback = function()
        setclipboard("https://discord.gg/jXSyQFnQCY")
        lib:Notification("Discord", "Copied invite to clipboard, just paste it.", 5)
    end,
})

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
    [+] Added Semi-Invisible, Flight, Float, Speed Booster
    [+] Enhanced movement features
    Join the Discord for help, suggestions, and the latest updates.
]])

-- ========== ENHANCED GODMODE PROTECTION ==========
local character, hrp, humanoid

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

-- ========== ENHANCED TWEEN TO BASE (HEIGHT-PRESERVING) ==========
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

Sections.Teleport:AddToggle("EnhancedTweenToBase", {
    Title = "Enhanced Tween To Base",
    Description = "Tween to base at your current height (no rubberband)",
    Default = false,
    Callback = function(value)
        if not value then 
            tweenActive = false
            if currentTween then currentTween:Cancel() end
            return 
        end
        
        local basePos = getBasePosition()
        if basePos then
            tweenActive = true
            lib:Notification("KRYPTON-HUB", "Tweening to base at current height...", 3)
            
            spawn(function()
                updateCharacterReferences()
                if not hrp or not humanoid then 
                    lib:Notification("KRYPTON-HUB", "No character found", 3)
                    tweenActive = false
                    return 
                end
                
                -- Get your current Y height and base XZ position
                local currentHeight = hrp.Position.Y
                local targetPos = Vector3.new(basePos.X, currentHeight, basePos.Z)
                local startPos = hrp.Position
                
                local distance = (targetPos - startPos).Magnitude
                local duration = math.max(2, distance / 25) -- Faster but still smooth
                
                local startTime = tick()
                
                while tweenActive and tick() - startTime < duration do
                    if not hrp then break end
                    
                    local elapsed = tick() - startTime
                    local progress = elapsed / duration
                    
                    -- Use cubic easing for smoother movement
                    local easedProgress = progress * progress * (3 - 2 * progress)
                    
                    -- Calculate new position maintaining Y height
                    local newPos = startPos + (targetPos - startPos) * easedProgress
                    newPos = Vector3.new(newPos.X, currentHeight, newPos.Z)
                    
                    -- Use CFrame to preserve rotation and avoid velocity issues
                    hrp.CFrame = CFrame.new(newPos)
                    
                    -- Keep character in running state to prevent ragdoll
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                    
                    task.wait(0.033) -- ~30 FPS for smooth movement
                end
                
                if tweenActive and hrp then
                    -- Final position with exact height preservation
                    hrp.CFrame = CFrame.new(targetPos.X, currentHeight, targetPos.Z)
                    lib:Notification("KRYPTON-HUB", "Arrived at base!", 3)
                end
                
                tweenActive = false
            end)
        else
            lib:Notification("KRYPTON-HUB", "Base not found!", 3)
        end
    end
})

-- ========== SEMI-INVISIBLE SYSTEM ==========
local isInvisible = false
local semiInvisibleConnections = {}
local clone, oldRoot, hip, animTrack

local function semiInvisibleFunction()
    local DEPTH_OFFSET = 0.15  

    local function removeFolders()  
        local playerName = player.Name  
        local playerFolder = Workspace:FindFirstChild(playerName)  
        if not playerFolder then  
            return  
        end  

        local doubleRig = playerFolder:FindFirstChild("DoubleRig")  
        if doubleRig then  
            doubleRig:Destroy()  
        end  

        local constraints = playerFolder:FindFirstChild("Constraints")  
        if constraints then  
            constraints:Destroy()  
        end  

        local childAddedConn = playerFolder.ChildAdded:Connect(function(child)  
            if child.Name == "DoubleRig" or child.Name == "Constraints" then  
                child:Destroy()  
            end  
        end)  
        table.insert(semiInvisibleConnections, childAddedConn)  
    end  

    local function doClone()  
        updateCharacterReferences()
        if character and humanoid and humanoid.Health > 0 then  
            hip = humanoid.HipHeight  
            oldRoot = hrp
            if not oldRoot or not oldRoot.Parent then  
                return false  
            end  

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
                    if v.Part0 == oldRoot then  
                        v.Part0 = clone  
                    end  
                    if v.Part1 == oldRoot then  
                        v.Part1 = clone  
                    end  
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
                if v.Part0 == clone then  
                    v.Part0 = oldRoot  
                end  
                if v.Part1 == clone then  
                    v.Part1 = oldRoot  
                end  
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
            anim.AnimationId = "http://www.roblox.com/asset/?id=18537363391"  
            local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)  
            animTrack = animator:LoadAnimation(anim)  
            animTrack.Priority = Enum.AnimationPriority.Action4  
            animTrack:Play(0, 1, 0)  
            anim:Destroy()  

            local animStoppedConn = animTrack.Stopped:Connect(function()  
                if isInvisible then  
                    animationTrickery()  
                end  
            end)  
            table.insert(semiInvisibleConnections, animStoppedConn)  

            task.delay(0, function()  
                animTrack.TimePosition = 0.7  
                task.delay(1, function()  
                    animTrack:AdjustSpeed(math.huge)  
                end)  
            end)  
        end  
    end  

    local function enableInvisibility()  
        updateCharacterReferences()
        if not character or humanoid.Health <= 0 then  
            return false
        end  

        removeFolders()  
        local success = doClone()  
        if success then  
            task.wait(0.1)  
            animationTrickery()  
            local connection = RunService.PreSimulation:Connect(function(dt)  
                updateCharacterReferences()
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
            table.insert(semiInvisibleConnections, connection)  

            local characterConnection = player.CharacterAdded:Connect(function(newChar)
                if isInvisible then
                    if animTrack then  
                        animTrack:Stop()  
                        animTrack:Destroy()  
                        animTrack = nil  
                    end  
                    revertClone()
                    removeFolders()
                    isInvisible = false
                    
                    for _, conn in ipairs(semiInvisibleConnections) do  
                        if conn then conn:Disconnect() end  
                    end  
                    semiInvisibleConnections = {}
                    
                    -- Reset toggle
                    if semiInvisibleToggle then
                        semiInvisibleToggle:SetValue(false)
                    end
                end
            end)
            table.insert(semiInvisibleConnections, characterConnection)
            
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
        revertClone()  
        removeFolders()  
        
        for _, conn in ipairs(semiInvisibleConnections) do  
            if conn then conn:Disconnect() end  
        end  
        semiInvisibleConnections = {}  
    end

    if not isInvisible then
        removeFolders()  
        if enableInvisibility() then
            isInvisible = true
            lib:Notification("KRYPTON-HUB", "Semi-Invisible enabled (F key to toggle)", 3)
        end
    else
        disableInvisibility()
        isInvisible = false
        lib:Notification("KRYPTON-HUB", "Semi-Invisible disabled", 3)
    end
end

-- Semi-Invisible Toggle
local semiInvisibleToggle = Sections.MiscTabs:AddToggle("SemiInvisible", {
    Title = "Semi Invisible",
    Description = "F key to toggle",
    Default = false,
    Callback = function(value)
        if value then
            semiInvisibleFunction()
        else
            if isInvisible then
                semiInvisibleFunction()
            end
        end
    end
})

-- F key toggle for semi-invisible
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F and not gameProcessed then
        semiInvisibleFunction()
        -- Update toggle state
        if semiInvisibleToggle then
            semiInvisibleToggle:SetValue(isInvisible)
        end
    end
end)

-- ========== FLIGHT SYSTEM ==========
local flyActive = false
local flyConnection

local flightToggle = Sections.Flight:AddToggle("Flight", {
    Title = "Slow Flight",
    Description = "Use camera direction to fly",
    Default = false,
    Callback = function(value)
        flyActive = value
        
        if flyActive then
            lib:Notification("KRYPTON-HUB", "Slow Flight enabled - Use camera direction", 3)
            
            flyConnection = RunService.RenderStepped:Connect(function()
                updateCharacterReferences()
                if flyActive and hrp then
                    hrp.Velocity = workspace.CurrentCamera.CFrame.LookVector * 25
                end
            end)
        else
            lib:Notification("KRYPTON-HUB", "Slow Flight disabled", 3)
            
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end
            
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end
})

-- ========== FLOAT SYSTEM ==========
local floatActive = false
local floatBodyVelocity

local floatToggle = Sections.MovementMain:AddToggle("Float", {
    Title = "Float",
    Description = "Float in the air",
    Default = false,
    Callback = function(value)
        floatActive = value
        
        if floatActive then
            lib:Notification("KRYPTON-HUB", "Float enabled", 3)
            
            updateCharacterReferences()
            if hrp then
                floatBodyVelocity = Instance.new("BodyVelocity")
                floatBodyVelocity.Velocity = Vector3.new(0, 25, 0)
                floatBodyVelocity.MaxForce = Vector3.new(0, 50000, 0)
                floatBodyVelocity.Parent = hrp
            end
        else
            lib:Notification("KRYPTON-HUB", "Float disabled", 3)
            
            if floatBodyVelocity then
                floatBodyVelocity:Destroy()
                floatBodyVelocity = nil
            end
        end
    end
})

-- ========== SPEED BOOSTER ==========
local speedActive = false
local speedConn
local baseSpeed = 27

local speedToggle = Sections.MovementMain:AddToggle("SpeedBooster", {
    Title = "Speed Booster",
    Description = "Enhanced movement speed",
    Default = false,
    Callback = function(value)
        speedActive = value
        
        if speedActive then
            lib:Notification("KRYPTON-HUB", "Speed Booster enabled", 3)
            
            local function GetCharacter()
                local Char = player.Character or player.CharacterAdded:Wait()
                local HRP = Char:WaitForChild("HumanoidRootPart")
                local Hum = Char:FindFirstChildOfClass("Humanoid")
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
            
            speedConn = RunService.Heartbeat:Connect(function()
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
            lib:Notification("KRYPTON-HUB", "Speed Booster disabled", 3)
            
            if speedConn then 
                speedConn:Disconnect() 
                speedConn = nil 
            end
            
            -- Stop movement when disabled
            updateCharacterReferences()
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end
    end
})

-- ========== FULLBRIGHT ==========
local fullbrightActive = false
local originalBrightness
local originalClockTime

local fullbrightToggle = Sections.Effects:AddToggle("Fullbright", {
    Title = "Fullbright",
    Description = "Brighten up the world",
    Default = false,
    Callback = function(value)
        fullbrightActive = value
        
        if fullbrightActive then
            lib:Notification("KRYPTON-HUB", "Fullbright enabled", 3)
            
            originalBrightness = Lighting.Brightness
            originalClockTime = Lighting.ClockTime
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            lib:Notification("KRYPTON-HUB", "Fullbright disabled", 3)
            
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

-- ========== ENHANCED ESP ==========
local espActive = false
local espFolders = {}

local espToggle = Sections.VisualTabs:AddToggle("EnhancedESP", {
    Title = "Enhanced ESP",
    Description = "Highlight all players",
    Default = false,
    Callback = function(value)
        espActive = value
        
        if espActive then
            lib:Notification("KRYPTON-HUB", "ESP enabled", 3)
            
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
            lib:Notification("KRYPTON-HUB", "ESP disabled", 3)
            
            for _, folder in pairs(espFolders) do
                if folder then
                    folder:Destroy()
                end
            end
            espFolders = {}
        end
    end
})

-- ========== PROXIMITY PROMPTS (Original Feature) ==========
local ipp = false
local pp = {}
local tableofconnections = {}

local function cleanupConnections()
    for _, connection in pairs(tableofconnections) do
        connection:Disconnect()
    end
    tableofconnections = {}
end

local function dop(p)
    if p.Base.Spawn.PromptAttachment:FindFirstChild("ProximityPrompt") then
        local c = p.Base.Spawn.PromptAttachment.ProximityPrompt
        table.insert(pp, c)
        if ipp then
            c.HoldDuration = 0
            table.insert(tableofconnections, c:GetPropertyChangedSignal("HoldDuration"):Connect(function()
                if c.HoldDuration ~= 0 and ipp then
                    c.HoldDuration = 0
                end
            end))
        end
    end
    table.insert(tableofconnections, p.Base.Spawn.PromptAttachment.ChildAdded:Connect(function(c)
        if c:IsA("ProximityPrompt") then
            table.insert(pp, c)
            if ipp then
                c.HoldDuration = 0
            end
            table.insert(tableofconnections, c:GetPropertyChangedSignal("HoldDuration"):Connect(function()
                if c.HoldDuration ~= 0 and ipp then
                    c.HoldDuration = 0
                end
            end))
        end
    end))
end

for _, plot in pairs(workspace:WaitForChild("Plots"):GetChildren()) do
    if plot:FindFirstChild("AnimalPodiums") then
        for _, podium in pairs(plot.AnimalPodiums:GetChildren()) do
            dop(podium)
        end
        table.insert(tableofconnections, plot.AnimalPodiums.ChildAdded:Connect(dop))
    end
end

Sections.Main:AddToggle("InstantProximityPrompt", {
    Title = "Instant Proximity Prompts",
    Default = false,
    Callback = function(state)
        ipp = state
        if ipp then
            for _, v in pairs(pp) do
                v.HoldDuration = 0
            end
        end
    end
})

-- ========== ORIGINAL FEATURES ==========

-- WalkSpeed
local walkSpeedToggle = false
local HumanModCons = {}
local function setWalkSpeed(speed)
    if typeof(speed) == "number" then
        local Char = player.Character or workspace:FindFirstChild(player.Name)
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

Sections.MiscTabs:AddToggle("WalkSpeedToggle", {
    Title = "WalkSpeed (50)",
    Default = false,
    Callback = function(value)
        walkSpeedToggle = value
        if value then
            setWalkSpeed(50)
        else
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

-- Infinite Jump
local infiniteJumpToggle = false
local jumpConnection
Sections.MiscTabs:AddToggle("InfiniteJumpToggle", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(value)
        infiniteJumpToggle = value
        if value then
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                    player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                end
            end)
        else
            if jumpConnection then
                jumpConnection:Disconnect()
                jumpConnection = nil
            end
        end
    end
})

-- God Mode
local godModeToggle = false
local godConnections = {}
local godHeartbeat
local function enableGodMode()
    local function apply(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        humanoid.BreakJointsOnDeath = false
        humanoid.RequiresNeck = false
        for _, connection in ipairs(getconnections(humanoid.Died)) do
            connection:Disable()
            table.insert(godConnections, connection)
        end
        table.insert(godConnections, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end))
        godHeartbeat = RunService.Heartbeat:Connect(function()
            if humanoid and humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end
    apply(player.Character or player.CharacterAdded:Wait())
    table.insert(godConnections, player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        apply(character)
    end))
end

local function disableGodMode()
    for _, connection in ipairs(godConnections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    godConnections = {}
    if godHeartbeat then
        godHeartbeat:Disconnect()
        godHeartbeat = nil
    end
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.BreakJointsOnDeath = true
        humanoid.RequiresNeck = true
    end
end

Sections.MiscTabs:AddToggle("GodModeToggle", {
    Title = "God Mode",
    Default = false,
    Callback = function(value)
        godModeToggle = value
        if value then
            enableGodMode()
        else
            disableGodMode()
        end
    end
})

-- Shop Tab Dropdown
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
                        "KRYPTON-HUB",
                        success and ("Tried to buy: " .. item.Name) or ("Error: " .. tostring(err)),
                        3
                    )
                    break
                end
            end
        end
    })
end

-- Cleanup on character death
player.CharacterAdded:Connect(function()
    -- Reset all new features
    isInvisible = false
    flyActive = false
    floatActive = false
    speedActive = false
    tweenActive = false
    fullbrightActive = false
    espActive = false
    
    -- Clean up connections
    if flyConnection then flyConnection:Disconnect() end
    if floatBodyVelocity then floatBodyVelocity:Destroy() end
    if speedConn then speedConn:Disconnect() end
    if currentTween then currentTween:Cancel() end
    
    -- Clean up semi-invisible
    for _, conn in ipairs(semiInvisibleConnections) do
        if conn then conn:Disconnect() end
    end
    semiInvisibleConnections = {}
    
    -- Reset ESP
    for _, folder in pairs(espFolders) do
        if folder then folder:Destroy() end
    end
    espFolders = {}
    
    -- Reset lighting
    if originalBrightness then
        Lighting.Brightness = originalBrightness
    end
    if originalClockTime then
        Lighting.ClockTime = originalClockTime
    end
    Lighting.GlobalShadows = true
end)

-- Config Setup
FlagsManager:SetLibrary(lib)
FlagsManager:SetIgnoreIndexes({})
FlagsManager:SetFolder("Config/KryptonHub")
FlagsManager:InitSaveSystem(tabs.Config)

-- Cleanup on Script End
game:BindToClose(function()
    cleanupConnections()
end)

lib:Notification('KRYPTON-HUB', 'Enhanced features loaded! Use F key for Semi-Invisible', 5)
