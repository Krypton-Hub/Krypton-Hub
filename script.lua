local floating = false
local floatPart
local originalPos

Button.MouseButton1Click:Connect(function()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HRP = Character:WaitForChild("HumanoidRootPart")
    if not floating then
        originalPos = HRP.Position
        floatPart = Instance.new("Part")
        floatPart.Anchored = true
        floatPart.CanCollide = false
        floatPart.Transparency = 1
        floatPart.Size = Vector3.new(6,1,6)
        floatPart.CFrame = HRP.CFrame * CFrame.new(0,-3,0)
        floatPart.Parent = workspace
        floating = true
        task.spawn(function()
            for i=1,80 do
                if not floating then break end
                floatPart.CFrame = floatPart.CFrame * CFrame.new(0,0.25,0)
                HRP.CFrame = CFrame.new(floatPart.Position + Vector3.new(0,3,0))
                task.wait(0.05)
            end
        end)
    else
        floating = false
        if floatPart then floatPart:Destroy() end
    end
end)
local tween = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1,true)
local tweenColor = tween:Create(UIStroke, tweenInfo, {Color = Color3.fromRGB(60,160,255)})
tweenColor:Play()

local dragging, dragInput, dragStart, startPos
Button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Button.Position
    end
end)
Button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
Button.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Button = Instance.new("TextButton")
Button.Parent = ScreenGui
Button.Size = UDim2.new(0,180,0,50)
Button.Position = UDim2.new(0.5,-90,0.8,0)
Button.Text = "Chat GPT Float"
Button.TextColor3 = Color3.new(1,1,1)
Button.Font = Enum.Font.Arcade
Button.TextScaled = true
Button.BackgroundColor3 = Color3.fromRGB(30,30,30)
Button.BorderSizePixel = 0
Button.AutoButtonColor = false

local UICorner = Instance.new("UICorner", Button)
UICorner.CornerRadius = UDim.new(0,20)

local UIStroke = Instance.new("UIStroke", Button)
UIStroke.Thickness = 3
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Color = Color3.fromRGB(160,60,255)
