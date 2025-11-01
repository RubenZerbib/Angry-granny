--!strict
-- Client interaction system using ProximityPrompts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local PlayerActionRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerAction")

-- Handle all ProximityPrompt interactions
ProximityPromptService.PromptTriggered:Connect(function(prompt, playerWhoTriggered)
	if playerWhoTriggered ~= player then return end
	
	local object = prompt.Parent
	if not object then return end
	
	-- Find the model or part that has the event data
	local interactable = findInteractable(object)
	if not interactable then return end
	
	local eventId = interactable:GetAttribute("EventId")
	local eventType = interactable:GetAttribute("EventType")
	local isCompleted = interactable:GetAttribute("Completed")
	
	if isCompleted then
		-- Already completed
		return
	end
	
	-- Send interaction to server
	PlayerActionRemote:FireServer({
		action = "interact",
		eventId = eventId,
		eventType = eventType,
		object = interactable,
		position = player.Character and player.Character:GetPivot().Position or Vector3.zero
	})
	
	print("[Interact] Sent interaction:", eventType or eventId)
end)

function findInteractable(object: Instance): Model?
	-- Check if object itself is interactable
	if object:IsA("Model") or object:IsA("BasePart") then
		if object:GetAttribute("EventId") or object:GetAttribute("EventType") then
			return object
		end
	end
	
	-- Check parent
	local parent = object.Parent
	if parent and (parent:IsA("Model") or parent:IsA("BasePart")) then
		if parent:GetAttribute("EventId") or parent:GetAttribute("EventType") then
			return parent
		end
	end
	
	return nil
end

-- Visual feedback for ProximityPrompts
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
	-- Could add visual effects here
	local object = prompt.Parent
	if object and object:IsA("BasePart") then
		object.BrickColor = BrickColor.new("Bright yellow")
	end
end)

ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt)
	local object = prompt.Parent
	if object and object:IsA("BasePart") then
		-- Reset color
		task.wait(0.1)
		if object.Parent then
			object.BrickColor = BrickColor.new("Medium stone grey")
		end
	end
end)

print("[Interact] Client interaction system loaded")
