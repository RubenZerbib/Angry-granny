--!strict
-- Effets visuels : vignette et flash selon les d?cibels

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local DecibelUpdate = ReplicatedStorage.Remotes.DecibelUpdate

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Cr?er l'interface
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VFX"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local vignetteFrame = Instance.new("Frame")
vignetteFrame.Name = "Vignette"
vignetteFrame.Size = UDim2.new(1, 0, 1, 0)
vignetteFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
vignetteFrame.BackgroundTransparency = 1
vignetteFrame.BorderSizePixel = 0
vignetteFrame.ZIndex = 10
vignetteFrame.Parent = screenGui

local uiGradient = Instance.new("UIGradient")
uiGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.7, 1),
	NumberSequenceKeypoint.new(1, 0.5),
})
uiGradient.Parent = vignetteFrame

-- ?tat
local currentDb = 0
local currentThreshold = 70

DecibelUpdate.OnClientEvent:Connect(function(db, threshold, trend)
	currentDb = db
	currentThreshold = threshold
	updateVignette()
end)

function updateVignette()
	-- Calculer l'intensit?
	local ratio = math.clamp(currentDb / currentThreshold, 0, 1)

	if ratio > 0.8 then
		-- Vignette visible
		local transparency = 1 - (ratio - 0.8) * 2 -- 0.8 -> 1.0 = 0% -> 40%
		vignetteFrame.BackgroundTransparency = transparency

		-- Flash si on fr?le le seuil
		if ratio > 0.95 then
			flashWarning()
		end
	else
		vignetteFrame.BackgroundTransparency = 1
	end
end

function flashWarning()
	local tween = TweenService:Create(vignetteFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		BackgroundTransparency = 0.3,
	})
	tween:Play()
	tween.Completed:Connect(function()
		local tween2 = TweenService:Create(vignetteFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 0.7,
		})
		tween2:Play()
	end)
end
