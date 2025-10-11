-- RxyalsScripts_Fixed.lua (continued) -- FLOAT Feature continued

floatUpConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed) if not gameProcessed and input.KeyCode == Enum.KeyCode.Space then if floatBodyVelocity then floatBodyVelocity.Velocity = Vector3.new(0, 50, 0) end end end)

if floatCharacterConnection then floatCharacterConnection:Disconnect() floatCharacterConnection = nil end floatCharacterConnection = UserInputService.InputEnded:Connect(function(input, gameProcessed) if not gameProcessed and input.KeyCode == Enum.KeyCode.Space then if floatBodyVelocity then floatBodyVelocity.Velocity = Vector3.new(0, 0, 0) end end end)

-- AUTO FLOOR Feature (placeholder toggle) local autoFloorEnabled = false autoFloorButton.MouseButton1Click:Connect(function() autoFloorEnabled = not autoFloorEnabled autoFloorButton.Text = "AUTO FLOOR: " .. (autoFloorEnabled and "ON" or "OFF") autoFloorButton.BackgroundColor3 = autoFloorEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(40, 40, 40) statusLabel.Text = autoFloorEnabled and "Status: Auto Floor ON" or "Status: Auto Floor OFF" end)

-- AUTO LAZER Feature (placeholder toggle) local autoLazerEnabled = false autoLazerButton.MouseButton1Click:Connect(function() autoLazerEnabled = not autoLazerEnabled autoLazerButton.Text = "AUTO LAZER: " .. (autoLazerEnabled and "ON" or "OFF") autoLazerButton.BackgroundColor3 = autoLazerEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(40, 40, 40) statusLabel.Text = autoLazerEnabled and "Status: Auto Lazer ON" or "Status: Auto Lazer OFF" end)

-- Tween Walk (simple path) local walking = false tweenButton.MouseButton1Click:Connect(function() walking = not walking tweenButton.Text = walking and "■ STOP WALK" or "▶ START WALK" tweenButton.BackgroundColor3 = walking and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(40, 40, 40)

if walking then
	statusLabel.Text = "Status: Tween Walking Enabled"
	local destination = hrp.Position + (hrp.CFrame.LookVector * 50)
	local tweenInfo = TweenInfo.new((destination - hrp.Position).Magnitude / currentSpeed, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(destination)})
	tween:Play()
	tween.Completed:Connect(function()
		if walking then
			statusLabel.Text = "Status: Arrived - Tween complete"
			tweenButton.Text = "▶ START WALK"
			tweenButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			walking = false
		end
	end)
else
	statusLabel.Text = "Status: Tween Walking Stopped"
end

end)

-- Jump Power input apply jumpInput.FocusLost:Connect(function(enterPressed) if enterPressed then local value = tonumber(jumpInput.Text) if value then humanoid.UseJumpPower = true humanoid.JumpPower = value statusLabel.Text = "Status: Jump Power set to " .. value else jumpInput.Text = tostring(humanoid.JumpPower) end end end)

-- Initial UI values updateSpeedDisplay(currentSpeed) humanoid.JumpPower = tonumber(jumpInput.Text) or 50

-- Cleanup on Character Reset player.CharacterRemoving:Connect(function() if floatUpConnection then floatUpConnection:Disconnect() end if floatCharacterConnection then floatCharacterConnection:Disconnect() end cleanFloatForHRP(hrp) end)

-- End of fixed Rxyals script

