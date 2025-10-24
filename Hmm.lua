-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
        return "Developer agent_duke13"
    else
        return "No Role Assigned"
    end
end

-- UI Setup
local main = lib:Load({
    Title = game:GetService("MarketplaceService"):GetProductInfo(109983668079237).Name .. ' 〢 ' .. RoleChecker(),
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
    Main = tabs.General:AddSection({Title = "Instant Proximity", Description = "", Default = false, Locked = false}),
    Teleport = tabs.General:AddSection({Title = "Teleport", Description = "", Default = false, Locked = false}),
    MiscTabs = tabs.General:AddSection({Title = "Character", Description = "", Default = false, Locked = false}),
    Shop = tabs.General:AddSection({Title = "Shop", Description = "", Default = false, Locked = false}),
    VisualTabs = tabs.General:AddSection({Title = "Visual", Description = "", Default = false, Locked = false}),
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
    Welcome to StellarHub! Thank you for choosing StellarHub.
    We're always working on improvements and features.
    If you experience issues or have feedback, don't hesitate to join our Discord server.
    Recent Updates:
    [+] Switched to new UI (thanks to 3itx)
    [+] Added Shop, Visual, Character
    Join the Discord for help, suggestions, and the latest updates.
]])

-- Proximity Prompts
local ipp = false
local pp = {} -- proximity prompts
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

-- Teleport Features
local teleportConnection
Sections.Teleport:AddToggle("TPToBaseToggle", {
    Title = "Teleport to Base",
    Default = false,
    Callback = function(value)
        local tptb = value
        local base = nil
        for _, v in pairs(workspace:WaitForChild("Plots"):GetChildren()) do
            local yourBase = v:FindFirstChild("YourBase", true)
            if yourBase and yourBase.Enabled then
                base = v:FindFirstChild("DeliveryHitbox", true)
                break
            end
        end
        if teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end
        if tptb then
            teleportConnection = RunService.Heartbeat:Connect(function()
                if base and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    local plrpos = hrp.Position
                    local tppos = Vector3.new(base.Position.X, plrpos.Y, base.Position.Z)
                    hrp.CFrame = CFrame.new(tppos)
                end
            end)
        end
    end
})

Sections.Teleport:AddToggle("TweenToBaseBtn", {
    Title = "Tween To Base",
    Description = "Teleports smoothly to your base using Tween",
    Default = false,
    Callback = function(state)
        if not state then return end
        local base = nil
        for _, v in pairs(workspace:WaitForChild("Plots"):GetChildren()) do
            local yourBase = v:FindFirstChild("YourBase", true)
            if yourBase and yourBase.Enabled then
                base = v:FindFirstChild("DeliveryHitbox", true)
                break
            end
        end
        if base and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
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
                        "STELLARHUB",
                        success and ("Tried to buy: " .. item.Name) or ("Error: " .. tostring(err)),
                        3
                    )
                    break
                end
            end
        end
    })
end

-- Misc Tab
do
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

    -- Noclip
    local noclipToggle = false
    RunService.Stepped:Connect(function()
        if noclipToggle and player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)

    Sections.MiscTabs:AddToggle("NoclipToggle", {
        Title = "Noclip",
        Default = false,
        Callback = function(value)
            noclipToggle = value
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
end

-- Visuals Tab
do
    local ESPEnabled = false
    local espFolder = Instance.new("Folder", game:GetService("CoreGui"))
    espFolder.Name = "ESPFolder"

    local function createESPBox(p)
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESPBox"
        box.Adornee = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Size = Vector3.new(4, 6, 1)
        box.Color3 = Color3.new(1, 1, 1)
        box.Transparency = 0.5
        box.Parent = espFolder

        local nameTag = Instance.new("BillboardGui")
        nameTag.Adornee = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        nameTag.Size = UDim2.new(0, 100, 0, 40)
        nameTag.AlwaysOnTop = true
        nameTag.Parent = espFolder
        nameTag.Name = "ESPNameTag"

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 16
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0.5
        label.Text = p.DisplayName
        label.Parent = nameTag
        return box, nameTag
    end

    local function removeESP(p)
        for _, child in pairs(espFolder:GetChildren()) do
            if (child:IsA("BoxHandleAdornment") or child:IsA("BillboardGui")) and (child.Name == "ESPBox" or child.Name == "ESPNameTag") then
                if child.Adornee and child.Adornee.Parent == p.Character then
                    child:Destroy()
                end
            end
        end
    end

    local function updateESP()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local hasBox = false
                for _, child in pairs(espFolder:GetChildren()) do
                    if child:IsA("BoxHandleAdornment") and child.Adornee == p.Character.HumanoidRootPart then
                        hasBox = true
                    end
                end
                if not hasBox then
                    createESPBox(p)
                end
            else
                removeESP(p)
            end
        end
    end

    Sections.VisualTabs:AddToggle("ESPToggle", {
        Title = "ESP",
        Default = false,
        Callback = function(value)
            ESPEnabled = value
            if not ESPEnabled then
                for _, child in pairs(espFolder:GetChildren()) do
                    child:Destroy()
                end
            end
        end
    })

    RunService.Heartbeat:Connect(function()
        if ESPEnabled then
            updateESP()
        end
    end)
end

-- Config Setup
FlagsManager:SetLibrary(lib)
FlagsManager:SetIgnoreIndexes({})
FlagsManager:SetFolder("Config/StealABrainrot")
FlagsManager:InitSaveSystem(tabs.Config)

-- Cleanup on Script End
game:BindToClose(function()
    cleanupConnections()
end)

lib:Notification('KRYPTON-HUB', 'We appreciate you using krypton hub!', 3)
