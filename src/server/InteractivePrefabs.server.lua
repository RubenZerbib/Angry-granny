--!strict
-- Interactive Prefabs: Creates actual interactive objects for events

local CollectionService = game:GetService("CollectionService")

local InteractivePrefabs = {}

-- Creates a window with shutters that can be closed
function InteractivePrefabs.createWindow(position: Vector3, roomModel: Model)
	local window = Instance.new("Model")
	window.Name = "InteractableWindow"
	
	-- Window frame
	local frame = Instance.new("Part")
	frame.Name = "Frame"
	frame.Size = Vector3.new(4, 6, 0.5)
	frame.Position = position
	frame.Anchored = true
	frame.Material = Enum.Material.Wood
	frame.Color = Color3.fromRGB(91, 60, 30)
	frame.Parent = window
	
	-- Glass
	local glass = Instance.new("Part")
	glass.Name = "Glass"
	glass.Size = Vector3.new(3.5, 5.5, 0.2)
	glass.Position = position
	glass.Anchored = true
	glass.Material = Enum.Material.Glass
	glass.Transparency = 0.3
	glass.Color = Color3.fromRGB(200, 200, 255)
	glass.Parent = window
	
	-- Open shutters (need to be closed)
	local shutterLeft = Instance.new("Part")
	shutterLeft.Name = "ShutterLeft"
	shutterLeft.Size = Vector3.new(1.8, 5.5, 0.3)
	shutterLeft.Position = position + Vector3.new(-3, 0, 0)
	shutterLeft.Anchored = true
	shutterLeft.Material = Enum.Material.Wood
	shutterLeft.Color = Color3.fromRGB(70, 40, 20)
	shutterLeft.Parent = window
	
	local shutterRight = Instance.new("Part")
	shutterRight.Name = "ShutterRight"
	shutterRight.Size = Vector3.new(1.8, 5.5, 0.3)
	shutterRight.Position = position + Vector3.new(3, 0, 0)
	shutterRight.Anchored = true
	shutterRight.Material = Enum.Material.Wood
	shutterRight.Color = Color3.fromRGB(70, 40, 20)
	shutterRight.Parent = window
	
	-- Add interaction prompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Close Shutters"
	prompt.ObjectText = "Window"
	prompt.HoldDuration = 2
	prompt.MaxActivationDistance = 8
	prompt.Parent = frame
	
	-- Tag for interaction system
	CollectionService:AddTag(window, "Interactable")
	window:SetAttribute("EventType", "window_shutters")
	window:SetAttribute("Completed", false)
	
	window.Parent = roomModel or workspace
	return window
end

-- Creates a clock that needs winding
function InteractivePrefabs.createClock(position: Vector3, roomModel: Model, clockType: string)
	local clock = Instance.new("Model")
	clock.Name = "InteractableClock"
	
	if clockType == "grandfather" then
		-- Grandfather clock (tall)
		local body = Instance.new("Part")
		body.Name = "Body"
		body.Size = Vector3.new(2, 8, 1.5)
		body.Position = position + Vector3.new(0, 4, 0)
		body.Anchored = true
		body.Material = Enum.Material.Wood
		body.Color = Color3.fromRGB(60, 30, 10)
		body.Parent = clock
		
		-- Clock face
		local face = Instance.new("Part")
		face.Name = "Face"
		face.Size = Vector3.new(1.5, 1.5, 0.2)
		face.Position = position + Vector3.new(0, 6, 0.8)
		face.Anchored = true
		face.Material = Enum.Material.Glass
		face.Color = Color3.fromRGB(240, 240, 220)
		face.Parent = clock
		
		-- Add pendulum
		local pendulum = Instance.new("Part")
		pendulum.Name = "Pendulum"
		pendulum.Size = Vector3.new(0.3, 3, 0.3)
		pendulum.Position = position + Vector3.new(0, 2, 0)
		pendulum.Anchored = false
		pendulum.Material = Enum.Material.Metal
		pendulum.Color = Color3.fromRGB(218, 133, 65)
		
		local attach = Instance.new("Attachment")
		attach.Parent = body
		attach.Position = Vector3.new(0, -2, 0)
		
		local pendAttach = Instance.new("Attachment")
		pendAttach.Parent = pendulum
		pendAttach.Position = Vector3.new(0, 1.5, 0)
		
		local rope = Instance.new("RopeConstraint")
		rope.Attachment0 = attach
		rope.Attachment1 = pendAttach
		rope.Length = 2
		rope.Parent = pendulum
		
		pendulum.Parent = clock
		
	else
		-- Wall clock (small)
		local body = Instance.new("Part")
		body.Name = "Body"
		body.Size = Vector3.new(1.5, 1.5, 0.5)
		body.Position = position
		body.Anchored = true
		body.Material = Enum.Material.Wood
		body.Color = Color3.fromRGB(60, 30, 10)
		body.Parent = clock
		
		-- Clock face
		local face = Instance.new("Part")
		face.Name = "Face"
		face.Size = Vector3.new(1.2, 1.2, 0.2)
		face.Position = position + Vector3.new(0, 0, 0.3)
		face.Anchored = true
		face.Material = Enum.Material.Glass
		face.Color = Color3.fromRGB(240, 240, 220)
		face.Parent = clock
	end
	
	-- Add interaction prompt
	local interactPart = clock:FindFirstChild("Body")
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Wind Clock"
	prompt.ObjectText = "Clock"
	prompt.HoldDuration = 3
	prompt.MaxActivationDistance = 6
	prompt.Parent = interactPart
	
	-- Tag for interaction system
	CollectionService:AddTag(clock, "Interactable")
	clock:SetAttribute("EventType", "clock_chime")
	clock:SetAttribute("Completed", false)
	
	clock.Parent = roomModel or workspace
	return clock
end

-- Creates a squeaky door
function InteractivePrefabs.createSqueakyDoor(position: Vector3, roomModel: Model)
	local doorModel = Instance.new("Model")
	doorModel.Name = "InteractableDoor"
	
	-- Door frame
	local frame = Instance.new("Part")
	frame.Name = "Frame"
	frame.Size = Vector3.new(5, 8, 1)
	frame.Position = position
	frame.Anchored = true
	frame.Material = Enum.Material.Wood
	frame.Color = Color3.fromRGB(91, 60, 30)
	frame.Parent = doorModel
	
	-- Door itself
	local door = Instance.new("Part")
	door.Name = "Door"
	door.Size = Vector3.new(4, 7.5, 0.5)
	door.Position = position + Vector3.new(-2, 0, 0)
	door.Anchored = true
	door.Material = Enum.Material.Wood
	door.Color = Color3.fromRGB(70, 40, 20)
	door.Parent = doorModel
	
	-- Doorknob
	local knob = Instance.new("Part")
	knob.Name = "Knob"
	knob.Size = Vector3.new(0.3, 0.3, 0.5)
	knob.Position = position + Vector3.new(-3.5, 0, 0.3)
	knob.Anchored = true
	knob.Shape = Enum.PartType.Ball
	knob.Material = Enum.Material.Metal
	knob.Color = Color3.fromRGB(218, 133, 65)
	knob.Parent = doorModel
	
	-- Add interaction prompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Oil Hinges"
	prompt.ObjectText = "Squeaky Door"
	prompt.HoldDuration = 2.5
	prompt.MaxActivationDistance = 6
	prompt.Parent = door
	
	-- Tag for interaction system
	CollectionService:AddTag(doorModel, "Interactable")
	doorModel:SetAttribute("EventType", "door_squeak")
	doorModel:SetAttribute("Completed", false)
	
	doorModel.Parent = roomModel or workspace
	return doorModel
end

-- Creates a baby crib
function InteractivePrefabs.createBabyCrib(position: Vector3, roomModel: Model)
	local crib = Instance.new("Model")
	crib.Name = "InteractableCrib"
	
	-- Crib base
	local base = Instance.new("Part")
	base.Name = "Base"
	base.Size = Vector3.new(4, 2, 5)
	base.Position = position + Vector3.new(0, 1, 0)
	base.Anchored = true
	base.Material = Enum.Material.Wood
	base.Color = Color3.fromRGB(163, 162, 165)
	base.Parent = crib
	
	-- Crib rails
	for i = -1, 1, 2 do
		local rail = Instance.new("Part")
		rail.Name = "Rail"
		rail.Size = Vector3.new(0.3, 1.5, 5)
		rail.Position = position + Vector3.new(i * 2, 2.5, 0)
		rail.Anchored = true
		rail.Material = Enum.Material.Wood
		rail.Color = Color3.fromRGB(163, 162, 165)
		rail.Parent = crib
	end
	
	-- Baby (simple representation)
	local baby = Instance.new("Part")
	baby.Name = "Baby"
	baby.Size = Vector3.new(1, 1, 1.5)
	baby.Position = position + Vector3.new(0, 2, 0)
	baby.Anchored = true
	baby.Material = Enum.Material.Fabric
	baby.Color = Color3.fromRGB(255, 220, 200)
	baby.Shape = Enum.PartType.Ball
	baby.Parent = crib
	
	-- Add interaction prompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Calm Baby"
	prompt.ObjectText = "Crying Baby"
	prompt.HoldDuration = 3
	prompt.MaxActivationDistance = 6
	prompt.Parent = base
	
	-- Tag for interaction system
	CollectionService:AddTag(crib, "Interactable")
	crib:SetAttribute("EventType", "baby_cry")
	crib:SetAttribute("Completed", false)
	
	crib.Parent = roomModel or workspace
	return crib
end

-- Creates a phone
function InteractivePrefabs.createPhone(position: Vector3, roomModel: Model)
	local phone = Instance.new("Model")
	phone.Name = "InteractablePhone"
	
	-- Phone base
	local base = Instance.new("Part")
	base.Name = "Base"
	base.Size = Vector3.new(0.8, 0.3, 1)
	base.Position = position
	base.Anchored = true
	base.Material = Enum.Material.Plastic
	base.Color = Color3.fromRGB(20, 20, 20)
	base.Parent = phone
	
	-- Handset
	local handset = Instance.new("Part")
	handset.Name = "Handset"
	handset.Size = Vector3.new(0.3, 0.5, 1.2)
	handset.Position = position + Vector3.new(0.3, 0.3, 0)
	handset.Anchored = true
	handset.Material = Enum.Material.Plastic
	handset.Color = Color3.fromRGB(20, 20, 20)
	handset.Parent = phone
	
	-- Add interaction prompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Answer Phone"
	prompt.ObjectText = "Ringing Phone"
	prompt.HoldDuration = 1
	prompt.MaxActivationDistance = 6
	prompt.Parent = base
	
	-- Tag for interaction system
	CollectionService:AddTag(phone, "Interactable")
	phone:SetAttribute("EventType", "phone_ring")
	phone:SetAttribute("Completed", false)
	
	phone.Parent = roomModel or workspace
	return phone
end

-- Creates a radio
function InteractivePrefabs.createRadio(position: Vector3, roomModel: Model)
	local radio = Instance.new("Model")
	radio.Name = "InteractableRadio"
	
	-- Radio body
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(1.5, 1, 2)
	body.Position = position
	body.Anchored = true
	body.Material = Enum.Material.Plastic
	body.Color = Color3.fromRGB(80, 60, 40)
	body.Parent = radio
	
	-- Antenna
	local antenna = Instance.new("Part")
	antenna.Name = "Antenna"
	antenna.Size = Vector3.new(0.1, 2, 0.1)
	antenna.Position = position + Vector3.new(0.5, 1.5, 0)
	antenna.Anchored = true
	antenna.Material = Enum.Material.Metal
	antenna.Color = Color3.fromRGB(150, 150, 150)
	antenna.Parent = radio
	
	-- Add interaction prompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Turn Off Radio"
	prompt.ObjectText = "Static Radio"
	prompt.HoldDuration = 1.5
	prompt.MaxActivationDistance = 6
	prompt.Parent = body
	
	-- Tag for interaction system
	CollectionService:AddTag(radio, "Interactable")
	radio:SetAttribute("EventType", "radio_static")
	radio:SetAttribute("Completed", false)
	
	radio.Parent = roomModel or workspace
	return radio
end

return InteractivePrefabs
