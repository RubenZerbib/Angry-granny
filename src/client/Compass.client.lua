--!strict
-- Boussole pointant vers l'?v?nement le plus critique

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EventSpawn = ReplicatedStorage.Remotes.EventSpawn

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Cr?er l'interface
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Compass"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local compassFrame = Instance.new("Frame")
compassFrame.Name = "CompassFrame"
compassFrame.Size = UDim2.new(0, 100, 0, 100)
compassFrame.Position = UDim2.new(0.5, -50, 0.9, -50)
compassFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
compassFrame.BackgroundTransparency = 0.5
compassFrame.BorderSizePixel = 2
compassFrame.BorderColor3 = Color3.fromRGB(200, 200, 200)
compassFrame.Parent = screenGui

local arrow = Instance.new("ImageLabel")
arrow.Name = "Arrow"
arrow.Size = UDim2.new(0.6, 0, 0.6, 0)
arrow.Position = UDim2.new(0.2, 0, 0.2, 0)
arrow.BackgroundTransparency = 1
arrow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png" -- Placeholder
arrow.Parent = compassFrame

-- ?tat
local targetPosition: Vector3? = nil

EventSpawn.OnClientEvent:Connect(function(data)
	targetPosition = data.position
end)

-- Mise ? jour de la rotation de la fl?che
RunService.RenderStepped:Connect(function()
	if not targetPosition then
		arrow.Visible = false
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart or not humanoidRootPart:IsA("BasePart") then
		return
	end

	arrow.Visible = true

	-- Calculer l'angle
	local playerPos = humanoidRootPart.Position
	local direction = (targetPosition - playerPos) * Vector3.new(1, 0, 1)
	local forward = humanoidRootPart.CFrame.LookVector * Vector3.new(1, 0, 1)

	local angle = math.atan2(direction.Z, direction.X) - math.atan2(forward.Z, forward.X)
	arrow.Rotation = math.deg(angle)
end)
