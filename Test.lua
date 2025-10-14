 

local screenGui = Instance.new("ScreenGui")

screenGui.Name = "CustomUI"

screenGui.ResetOnSpawn = false

screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

 

local toggleButton = Instance.new("TextButton")

toggleButton.Size = UDim2.new(0, 60, 0, 60)

toggleButton.Position = UDim2.new(0, 20, 0.5, -30)

toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

toggleButton.BackgroundTransparency = 0.3

toggleButton.Text = "test"

toggleButton.Font = Enum.Font.Arcade

toggleButton.TextSize = 16

toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)

toggleButton.Active = true

toggleButton.Draggable = true

toggleButton.Parent = screenGui

 

local uiCorner = Instance.new("UICorner")

uiCorner.CornerRadius = UDim.new(1, 0)

uiCorner.Parent = toggleButton

 

 

local mainFrame = Instance.new("Frame")

mainFrame.Size = UDim2.new(0, 160, 0, 200)

mainFrame.Position = UDim2.new(0.5, -80, 0.5, -100)

mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

mainFrame.BackgroundTransparency = 0.3

mainFrame.BorderSizePixel = 0

mainFrame.Active = true

mainFrame.Draggable = true

mainFrame.Visible = false

mainFrame.Parent = screenGui

 

local frameCorner = Instance.new("UICorner")

frameCorner.CornerRadius = UDim.new(0, 12)

frameCorner.Parent = mainFrame

 

local titleLabel = Instance.new("TextLabel")

titleLabel.Size = UDim2.new(1, 0, 0, 25)

titleLabel.BackgroundTransparency = 1

titleLabel.Text = "Steal Tools! (BETA)"

titleLabel.Font = Enum.Font.Arcade

titleLabel.TextSize = 16

titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

titleLabel.Parent = mainFrame

 



local layout = Instance.new("UIListLayout")

layout.Padding = UDim.new(0, 5)

layout.FillDirection = Enum.FillDirection.Vertical

layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

layout.VerticalAlignment = Enum.VerticalAlignment.Top

layout.SortOrder = Enum.SortOrder.LayoutOrder

layout.Parent = mainFrame

 

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()

mainFrame.Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, layout.AbsoluteContentSize.Y + 15)

end)

 

 

local function createButton(name)

local button = Instance.new("TextButton")

button.Size = UDim2.new(0, 140, 0, 28)

button.Text = name

button.Font = Enum.Font.Arcade

button.TextSize = 16

button.TextColor3 = Color3.fromRGB(255, 255, 255)

button.BackgroundColor3 = Color3.fromRGB(220, 20, 60)

button.AutoButtonColor = false

local corner = Instance.new("UICorner")

corner.CornerRadius = UDim.new(0, 8)

corner.Parent = button

button.Parent = mainFrame

return button

end

 


local fpsButton = createButton("Slow Flight")

local speedButton = createButton("Speed Booster")

local floorButton = createButton("3rd Floor Steal")

local extraButton = createButton("Desync (Anti Hit)")

 



 

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local desyncActive = false

 



local function enableMobileDesync()

local success, error = pcall(function()

local backpack = LocalPlayer:WaitForChild("Backpack")

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local humanoid = character:WaitForChild("Humanoid")

 

local packages = ReplicatedStorage:WaitForChild("Packages", 5)

if not packages then warn("idk") return false end

 

local netFolder = packages:WaitForChild("Net", 5)

if not netFolder then warn("idk") return false end

 

local useItemRemote = netFolder:WaitForChild("RE/UseItem", 5)

local teleportRemote = netFolder:WaitForChild("RE/QuantumCloner/OnTeleport", 5)

if not useItemRemote or not teleportRemote then warn("idk") return false end

 



local toolNames = {"Quantum Cloner", "whatever", "whatever"}

local tool

for _, toolName in ipairs(toolNames) do

tool = backpack:FindFirstChild(toolName) or character:FindFirstChild(toolName)

if tool then break end

end

if not tool then

for _, item in ipairs(backpack:GetChildren()) do

if item:IsA("Tool") then tool=item break end

end

end

 

if tool and tool.Parent==backpack then

humanoid:EquipTool(tool)

task.wait(0.5)

end

 

if setfflag then setfflag("WorldStepMax", "-9999999999") end

task.wait(0.2)

useItemRemote:FireServer()

task.wait(1)

teleportRemote:FireServer()

task.wait(2)

if setfflag then setfflag("WorldStepMax", "-1") end

print("idk")

return true

end)

if not success then

warn("idk")

return false

end

return success

end

 

local function disableMobileDesync()

pcall(function()

if setfflag then setfflag("WorldStepMax", "-1") end

print("idk")

end)

end

 



extraButton.MouseButton1Click:Connect(function()

desyncActive = not desyncActive

if desyncActive then

local success = enableMobileDesync()

if success then

extraButton.BackgroundColor3 = Color3.fromRGB(200, 200, 0) -- amarelo

else

desyncActive=false

extraButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)

end

else

disableMobileDesync()

extraButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)

end

end)

 



LocalPlayer.CharacterAdded:Connect(function()

desyncActive=false

extraButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)

end)

 


 



local discordBtn = Instance.new("TextButton")

discordBtn.Size = UDim2.new(0, 120, 0, 22)

discordBtn.Text = "Discord"

discordBtn.Font = Enum.Font.Arcade

discordBtn.TextSize = 14

discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)

discordBtn.AutoButtonColor = false

local corner = Instance.new("UICorner")

corner.CornerRadius = UDim.new(0, 6)

corner.Parent = discordBtn

discordBtn.Parent = mainFrame

 

discordBtn.MouseButton1Click:Connect(function()

if setclipboard then setclipboard("https://discord.gg/urdiscord")

elseif toclipboard then toclipboard("https://discord.gg/urdiscord") end

local originalText = discordBtn.Text

discordBtn.Text = "Link Copied"

task.wait(3)

discordBtn.Text = originalText

end)

 


local uiVisible = false

toggleButton.MouseButton1Click:Connect(function()

uiVisible = not uiVisible

mainFrame.Visible = uiVisible

end)

 


do

local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local speedConn

local baseSpeed = 27

local active = false

 

local function GetCharacter()

local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

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

 

local function startSpeedControl()

if speedConn then return end

speedConn = RunService.Heartbeat:Connect(function()

local Char, HRP, Hum = GetCharacter()

if not Char or not HRP or not Hum then return end

local inputDirection = getMovementInput()

if inputDirection.Magnitude > 0 then

HRP.AssemblyLinearVelocity = Vector3.new(

inputDirection.X*baseSpeed,

HRP.AssemblyLinearVelocity.Y,

inputDirection.Z*baseSpeed

)

else

HRP.AssemblyLinearVelocity = Vector3.new(0, HRP.AssemblyLinearVelocity.Y, 0)

end

end)

end

 

local function stopSpeedControl()

if speedConn then speedConn:Disconnect() speedConn = nil end

local Char, HRP = GetCharacter()

if HRP then HRP.AssemblyLinearVelocity = Vector3.new(0, HRP.AssemblyLinearVelocity.Y, 0) end

end

 

speedButton.MouseButton1Click:Connect(function()

active = not active

if active then

startSpeedControl()

speedButton.BackgroundColor3 = Color3.fromRGB(0,170,0)

else

stopSpeedControl()

speedButton.BackgroundColor3 = Color3.fromRGB(220,20,60)

end

end)

end

 



local function setTransparencySpecific(part, transparency)

if part and part:IsA("BasePart") then

if not part:GetAttribute("OriginalTransparency") then

part:SetAttribute("OriginalTransparency", part.Transparency)

end

if not part:GetAttribute("OriginalCanCollide") then

part:SetAttribute("OriginalCanCollide", part.CanCollide)

end

part.Transparency = transparency

part.CanCollide = false

end

end

 

local function processAnimalPodium(podium, podiumNumber, plotName)

local claim = podium:FindFirstChild("Claim")

if claim then

local hitbox = claim:FindFirstChild("Hitbox")

if hitbox then

pcall(function()

if not hitbox:GetAttribute("OriginalTransparency") then

hitbox:SetAttribute("OriginalTransparency", hitbox.Transparency)

hitbox:SetAttribute("OriginalCanCollide", hitbox.CanCollide)

end

hitbox.Transparency = 0.5

hitbox.CanCollide = false

if hitbox:FindFirstChild("SelectionBox") then hitbox.SelectionBox:Destroy() end

if hitbox:FindFirstChild("SurfaceGui") then hitbox.SurfaceGui.Enabled=false end

if hitbox:FindFirstChild("BillboardGui") then hitbox.BillboardGui.Enabled=false end

for _, script in pairs(hitbox:GetChildren()) do

if script:IsA("LocalScript") or script:IsA("Script") then

script.Disabled=true

end

end

end)

end

end

local base = podium:FindFirstChild("Base")

if base then

local spawn = base:FindFirstChild("Spawn")

setTransparencySpecific(spawn,0.5)

local decorations = base:FindFirstChild("Decorations")

if decorations then

local decoration = decorations:FindFirstChild("Decoration")

setTransparencySpecific(decoration,0.5)

local part = decorations:FindFirstChild("Part")

setTransparencySpecific(part,0.5)

for _, child in pairs(decorations:GetChildren()) do

if child:IsA("BasePart") and child.Name~="Decoration" and child.Name~="Part" then

setTransparencySpecific(child,0.5)

end

end

end

end

end

 



do

local player = game.Players.LocalPlayer

local runService = game:GetService("RunService")

local platform, connection

local active, isRising = false, false

local RISE_SPEED = 15

 

local function destroyPlatform()

if platform then platform:Destroy() platform=nil end

active=false isRising=false

if connection then connection:Disconnect() connection=nil end

floorButton.BackgroundColor3 = Color3.fromRGB(220,20,60)

end

 

local function canRise()

if not platform then return false end

local origin = platform.Position + Vector3.new(0, platform.Size.Y/2,0)

local direction = Vector3.new(0,2,0)

local rayParams = RaycastParams.new()

rayParams.FilterDescendantsInstances = {platform, player.Character}

rayParams.FilterType = Enum.RaycastFilterType.Blacklist

return not workspace:Raycast(origin,direction,rayParams)

end

 

local function setup3rdFloor(character)

local root = character:WaitForChild("HumanoidRootPart")

floorButton.MouseButton1Click:Connect(function()

active = not active

if active then

platform = Instance.new("Part")

platform.Size = Vector3.new(6,0.5,6)

platform.Anchored=true

platform.CanCollide=true

platform.Transparency=0

platform.Material=Enum.Material.Plastic

platform.Color=Color3.fromRGB(255,200,0)

platform.Position=root.Position-Vector3.new(0, root.Size.Y/2 + platform.Size.Y/2, 0)

platform.Parent = workspace

 



local plots = workspace:FindFirstChild("Plots")

if plots then

for _, plot in pairs(plots:GetChildren()) do

for _, part in pairs(plot:GetDescendants()) do

if part:IsA("BasePart") and (part.Name:lower():find("base plot") or part.Name:lower():find("base") or part.Name:lower():find("plot")) then

part.Transparency = 0.5

end

end

local animalPodiums = plot:FindFirstChild("AnimalPodiums")

if animalPodiums then

for _, podium in pairs(animalPodiums:GetChildren()) do

if podium:IsA("Model") or podium:IsA("Folder") then

processAnimalPodium(podium, podium.Name, plot.Name)

end

end

end

end

end

 

isRising=true

connection = runService.Heartbeat:Connect(function(dt)

if platform and active then

local cur = platform.Position

local newXZ = Vector3.new(root.Position.X, cur.Y, root.Position.Z)

if isRising and canRise() then

platform.Position = newXZ + Vector3.new(0, dt*RISE_SPEED,0)

else

isRising=false

platform.Position=newXZ

end

end

end)

floorButton.BackgroundColor3=Color3.fromRGB(0,170,0)

else

destroyPlatform()

end

end)

character:WaitForChild("Humanoid").Died:Connect(destroyPlatform)

end

 

if player.Character then setup3rdFloor(player.Character) end

player.CharacterAdded:Connect(setup3rdFloor)

end

 



do

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local RunService = game:GetService("RunService")

local guidedOn=false

local guidedConn

 

fpsButton.MouseButton1Click:Connect(function()

local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local hum = char:FindFirstChildOfClass("Humanoid")

guidedOn = not guidedOn

fpsButton.BackgroundColor3 = guidedOn and Color3.fromRGB(0,200,0) or Color3.fromRGB(220,20,60)

if guidedOn then

local hrp = char:FindFirstChild("HumanoidRootPart")

if hrp then

guidedConn = RunService.RenderStepped:Connect(function()

if guidedOn and hrp then

hrp.Velocity = workspace.CurrentCamera.CFrame.LookVector*25

end

end)

end

else

if guidedConn then guidedConn:Disconnect() guidedConn=nil end

if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end

end

end)

end

 



do

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local BOX_COLOR=Color3.fromRGB(0,0,0)

local BOX_TRANSPARENCY=0.7

 

local function createESP(character, player)

if character:FindFirstChild("HumanoidRootPart") then

local hrp = character.HumanoidRootPart

local box = Instance.new("BoxHandleAdornment")

box.Size=character:GetExtentsSize()

box.Adornee=character

box.Color3=BOX_COLOR

box.Transparency=BOX_TRANSPARENCY

box.AlwaysOnTop=true

box.ZIndex=5

box.Parent=hrp

 

local nameBillboard = Instance.new("BillboardGui")

nameBillboard.Adornee=hrp

nameBillboard.Size=UDim2.new(0,80,0,15)

nameBillboard.StudsOffset=Vector3.new(0,3,0)

nameBillboard.AlwaysOnTop=true

nameBillboard.Parent=hrp

 

local nameLabel = Instance.new("TextLabel")

nameLabel.Size=UDim2.new(1,0,1,0)

nameLabel.BackgroundTransparency=0.4

nameLabel.BackgroundColor3=Color3.fromRGB(0,0,0)

nameLabel.Text=player.Name

nameLabel.Font=Enum.Font.Arcade

nameLabel.TextSize=10

nameLabel.TextColor3=Color3.fromRGB(255,255,255)

nameLabel.TextStrokeTransparency=0.2

nameLabel.Parent=nameBillboard

end

end

 

local function onCharacterAdded(character, player)

task.wait(1)

createESP(character, player)

end

 

local function onPlayerAdded(player)

if player~=LocalPlayer then

if player.Character then onCharacterAdded(player.Character, player) end

player.CharacterAdded:Connect(function(char)

onCharacterAdded(char, player)

end)

end

end

 

for _, p in ipairs(Players:GetPlayers()) do onPlayerAdded(p) end

Players.PlayerAdded:Connect(onPlayerAdded)

end
