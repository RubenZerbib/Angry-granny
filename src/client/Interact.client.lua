--!strict
-- Syst?me d'interaction : raycast + touche E

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerAction = ReplicatedStorage.Remotes.PlayerAction

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local currentTarget: Instance? = nil
local lastInteractionTime = 0
local interactionCooldown = 0.25 -- secondes

-- UI d'interaction
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InteractUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local promptLabel = Instance.new("TextLabel")
promptLabel.Name = "Prompt"
promptLabel.Size = UDim2.new(0, 300, 0, 50)
promptLabel.Position = UDim2.new(0.5, -150, 0.7, 0)
promptLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
promptLabel.BackgroundTransparency = 0.3
promptLabel.BorderSizePixel = 2
promptLabel.BorderColor3 = Color3.fromRGB(255, 255, 255)
promptLabel.Text = "[E] Interagir"
promptLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
promptLabel.TextScaled = true
promptLabel.Font = Enum.Font.GothamBold
promptLabel.Visible = false
promptLabel.Parent = screenGui

-- Raycast en continu
task.spawn(function()
	while true do
		task.wait(0.1)

		local character = player.Character
		if not character then
			continue
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart or not humanoidRootPart:IsA("BasePart") then
			continue
		end

		local origin = humanoidRootPart.Position
		local direction = humanoidRootPart.CFrame.LookVector * 16

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { character }
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		local result = workspace:Raycast(origin, direction, raycastParams)

		if result and result.Instance:HasTag("Interactable") then
			currentTarget = result.Instance
			promptLabel.Visible = true
		else
			currentTarget = nil
			promptLabel.Visible = false
		end
	end
end)

-- ?couter la touche E
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.E then
		if currentTarget and (tick() - lastInteractionTime) > interactionCooldown then
			lastInteractionTime = tick()
			interact(currentTarget)
		end
	end
end)

function interact(target: Instance)
	-- R?cup?rer l'eventId
	local eventId = target:GetAttribute("EventId")
	if not eventId then
		warn("[Interact] Pas d'EventId sur le target")
		return
	end

	-- Envoyer au serveur
	PlayerAction:FireServer("Interact", {
		eventId = eventId,
	})
end
