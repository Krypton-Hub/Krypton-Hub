-- Krypton Hub - DrRay Edition
-- Made by agent_duke13 | Uses DrRay UI Library
-- Loadstring: https://github.com/AZYsGithub/DrRay-UI-Library

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character, hrp, humanoid

-- Load DrRay Library
local DrRayLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/DrRay-UI-Library/main/DrRay.lua"))()

-- Godmode Protection
local function setupGodmode()
    local mt = getrawmetatable(game)
    local oldNC = mt.__namecall
    local oldNI = mt.__newindex
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local m = getnamecallmethod()
        if self == humanoid then
            if m == "ChangeState" and select(1, ...) == Enum.HumanoidStateType.Dead then return end
            if m == "SetStateEnabled" then
                local st, en = ...
                if st == Enum.HumanoidStateType.Dead and en == true then return end
            end
            if m == "Destroy" then return end
        end
        if self == character and m == "BreakJoints" then return end
        return oldNC(self, ...)
    end)
    
    mt.__newindex = newcclosure(function(self, k, v)
        if self == humanoid then
            if k == "Health" and type(v) == "number" and v <= 0 then return end
            if k == "MaxHealth" and type(v) == "number" and v < humanoid.MaxHealth then return end
            if k == "BreakJointsOnDeath" and v == true then return end
            if k == "Parent" and v == nil then return end
        end
        return oldNI(self, k, v)
    end)
    
    setreadonly(mt, true)
end

-- Safe Character References
local function updateCharacterReferences()
    character = player.Character
    if character then
        hrp = character:FindFirstChild("HumanoidRootPart")
        humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then setupGodmode() end
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
    setupGodmode()
end)

-- Create DrRay Window
local Window = DrRayLibrary.newWindow("Krypton Hub v5.0 by agent_duke13", "rbxassetid://4483345998")  -- Title & optional icon ID

-- Main Tab
local MainTab = Window.newTab("Main", "rbxassetid://4483345998")  -- Tab name & optional icon

-- Tween to Base Toggle
local tweenActive = false
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

local function getGroundHeight(position)
    local rayOrigin = Vector3.new(position.X, position.Y + 10, position.Z)
    local rayDirection = Vector3.new(0, -50, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    
    local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if raycastResult then
        return raycastResult.Position.Y + 3
    end
    return position.Y
end

MainTab.newToggle("Tween to Base", false, function(state)
    if state then
        local basePos = getBasePosition()
        if basePos then
            tweenActive = true
            DrRayLibrary.notify("Tweening to base (slow for stability)...")
            spawn(function()
                updateCharacterReferences()
                if not hrp or not humanoid then 
                    DrRayLibrary.notify("No character found!")
                    tweenActive = false
                    return 
                end
                
                setupGodmode()
                
                local currentGroundY = getGroundHeight(hrp.Position)
                local baseGroundY = getGroundHeight(basePos)
                local targetY = math.min(currentGroundY, baseGroundY)
                
                local startPos = Vector3.new(hrp.Position.X, currentGroundY, hrp.Position.Z)
                local targetPos = Vector3.new(basePos.X, targetY, basePos.Z)
                
                local distance = (targetPos - startPos).Magnitude
                local duration = math.max(3, distance / 15)
                
                local startTime = tick()
                
                while tweenActive and tick() - startTime < duration do
                    if not hrp then break end
                    
                    local elapsed = tick() - startTime
                    local progress = elapsed / duration
                    local easedProgress = progress * progress * (3 - 2 * progress)
                    
                    local newPos = startPos + (targetPos - startPos) * easedProgress
                    local currentGround = getGroundHeight(newPos)
                    newPos = Vector3.new(newPos.X, currentGround, newPos.Z)
                    
                    hrp.CFrame = CFrame.new(newPos)
                    
                    if humanoid then
                        humanoid.Health = humanoid.MaxHealth
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                    
                    task.wait(0.05)
                end
                
                if tweenActive and hrp then
                    local finalGroundY = getGroundHeight(targetPos)
                    hrp.CFrame = CFrame.new(targetPos.X, finalGroundY, targetPos.Z)
                    DrRayLibrary.notify("Reached base safely!")
                end
                
                tweenActive = false
            end)
        else
            DrRayLibrary.notify("Base not found!")
        end
    else
        tweenActive = false
        DrRayLibrary.notify("Tween stopped")
    end
end)

-- Slow Flight Toggle + Slider
local flyActive = false
local flyConnection
local flySpeed = 25
MainTab.newSlider("Fly Speed", 10, 100, function(value)
    flySpeed = value
end)
MainTab.newToggle("Slow Flight", false, function(state)
    flyActive = state
    if state then
        DrRayLibrary.notify("Slow Flight enabled - Use camera direction")
        flyConnection = RunService.RenderStepped:Connect(function()
            updateCharacterReferences()
            if flyActive and hrp then
                hrp.Velocity = workspace.CurrentCamera.CFrame.LookVector * flySpeed
            end
        end)
    else
        DrRayLibrary.notify("Slow Flight disabled")
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

-- Float Toggle
local floatActive = false
local floatBodyVelocity
MainTab.newToggle("Float", false, function(state)
    floatActive = state
    if state then
        DrRayLibrary.notify("Float enabled")
        updateCharacterReferences()
        if hrp then
            setupGodmode()
            floatBodyVelocity = Instance.new("BodyVelocity")
            floatBodyVelocity.Velocity = Vector3.new(0, 25, 0)
            floatBodyVelocity.MaxForce = Vector3.new(0, 50000, 0)
            floatBodyVelocity.Parent = hrp
        end
    else
        DrRayLibrary.notify("Float disabled")
        if floatBodyVelocity then
            floatBodyVelocity:Destroy()
        end
    end
end)

-- Player Tab
local PlayerTab = Window.newTab("Player", "rbxassetid://4483345998")

-- Semi-Invisible Function (Full from Original)
local connections = {SemiInvisible = {}}
local isInvisible = false
local clone, oldRoot, hip, animTrack, connection, characterConnection

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
        table.insert(connections.SemiInvisible, childAddedConn)  
    end  

    local function doClone()  
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
            table.insert(connections.SemiInvisible, animStoppedConn)  

            task.delay(0, function()  
                animTrack.TimePosition = 0.7  
                task.delay(1, function()  
                    animTrack:AdjustSpeed(math.huge)  
                end)  
            end)  
        end  
    end  

    local function enableInvisibility()  
        if not character or humanoid.Health <= 0 then  
            return false
        end  

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
        setupGodmode()  
        if enableInvisibility() then
            isInvisible = true
            DrRayLibrary.notify("Semi-Invisible enabled (F key to toggle)")
        else
            DrRayLibrary.notify("Failed to enable Semi-Invisible")
        end
    else
        disableInvisibility()
        isInvisible = false
        DrRayLibrary.notify("Semi-Invisible disabled")
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

PlayerTab.newToggle("Semi Invisible", false, semiInvisibleFunction)
PlayerTab.newKeybind("Semi Invisible Bind", Enum.KeyCode.F, semiInvisibleFunction)

-- Infinite Jump Toggle
local infJumpActive = false
local infJumpConnection
PlayerTab.newToggle("Infinite Jump", false, function(state)
    infJumpActive = state
    if state then
        DrRayLibrary.notify("Infinite Jump enabled")
        infJumpConnection = UserInputService.JumpRequest:Connect(function()
            if infJumpActive and humanoid and humanoid.Health > 0 then
                setupGodmode()
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                if hrp then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
                end
            end
        end)
    else
        DrRayLibrary.notify("Infinite Jump disabled")
        if infJumpConnection then
            infJumpConnection:Disconnect()
        end
    end
end)

-- Speed Booster Toggle + Slider
local speedActive = false
local speedConn
local baseSpeed = 27
PlayerTab.newSlider("Speed Value", 16, 100, function(value)
    baseSpeed = value
end)
PlayerTab.newToggle("Speed Booster", false, function(state)
    speedActive = state
    if state then
        DrRayLibrary.notify("Speed Booster enabled")
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
        DrRayLibrary.notify("Speed Booster disabled")
        if speedConn then 
            speedConn:Disconnect() 
            speedConn = nil 
        end
        updateCharacterReferences()
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
        end
    end
end)

-- Visuals Tab
local VisualsTab = Window.newTab("Visuals", "rbxassetid://4483345998")

-- ESP Toggle
local espActive = false
local espFolders = {}
VisualsTab.newToggle("Player ESP", false, function(state)
    espActive = state
    if state then
        DrRayLibrary.notify("ESP enabled")
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
        DrRayLibrary.notify("ESP disabled")
        for _, folder in pairs(espFolders) do
            if folder then
                folder:Destroy()
            end
        end
        espFolders = {}
    end
end)

-- Fullbright Toggle
local fullbrightActive = false
local originalBrightness
local originalClockTime
VisualsTab.newToggle("Fullbright", false, function(state)
    fullbrightActive = state
    if state then
        DrRayLibrary.notify("Fullbright enabled")
        originalBrightness = Lighting.Brightness
        originalClockTime = Lighting.ClockTime
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        DrRayLibrary.notify("Fullbright disabled")
        if originalBrightness then
            Lighting.Brightness = originalBrightness
        end
        if originalClockTime then
            Lighting.ClockTime = originalClockTime
        end
        Lighting.GlobalShadows = true
    end
end)

-- Discord Button
VisualsTab.newButton("Copy Discord Invite", "Copy to clipboard", function()
    if setclipboard then
        setclipboard("https://discord.gg/YSwFZsGk9j")
        DrRayLibrary.notify("Discord link copied!")
    else
        DrRayLibrary.notify("Clipboard not supported")
    end
end)

-- Auto-cleanup on Character Respawn
player.CharacterAdded:Connect(function()
    tweenActive = false
    flyActive = false
    floatActive = false
    isInvisible = false
    infJumpActive = false
    speedActive = false
    espActive = false
    fullbrightActive = false
    
    if flyConnection then flyConnection:Disconnect() end
    if floatBodyVelocity then floatBodyVelocity:Destroy() end
    if infJumpConnection then infJumpConnection:Disconnect() end
    if speedConn then speedConn:Disconnect() end
    
    for _, conn in ipairs(connections.SemiInvisible) do
        if conn then conn:Disconnect() end
    end
    connections.SemiInvisible = {}
    
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
    
    DrRayLibrary.notify("Character respawned - All features reset")
end)

print("Krypton Hub DrRay Edition Loaded! Drag to move, X to close.")
print("Features: Tween to Base, Slow Flight, Float, Semi-Invisible (F key), Infinite Jump, Speed Booster, ESP, Fullbright, Discord Invite")
print("Discord: https://discord.gg/YSwFZsGk9j")
