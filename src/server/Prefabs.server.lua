--!strict
-- Prefabs: Integrates ManorGenerator and InteractivePrefabs

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")

local ManorGenerator = require(script.Parent.ManorGenerator)
local InteractivePrefabs = require(script.Parent.InteractivePrefabs)
local EventRegistry = require(ReplicatedStorage.Shared.EventRegistry)

local Prefabs = {}

local manorModel
local rooms = {}
local anchors: { [string]: BasePart } = {}

function Prefabs.init()
	print("[Prefabs] Generating manor...")
	manorModel, rooms = ManorGenerator.generateManor()
	
	-- Index all event anchors
	for roomName, roomData in pairs(rooms) do
		local anchor = roomData.model:FindFirstChild(roomName .. "Anchor")
		if anchor then
			anchors[roomName] = anchor
		end
	end
	
	print("[Prefabs] Manor generated with", #workspace.Manor:GetChildren(), "rooms")
end

function Prefabs.spawnGrannyBed()
	-- Granny's bed is already in GrannyBedroom from ManorGenerator
	local grannyRoom = rooms["GrannyBedroom"]
	if grannyRoom then
		local bed = grannyRoom.model:FindFirstChild("GrannyBed")
		if bed then
			return bed
		end
	end
	
	-- Fallback: create bed
	local bed = Instance.new("Part")
	bed.Name = "GrannyBed"
	bed.Size = Vector3.new(6, 2, 8)
	bed.Position = Vector3.new(10, 16, 10)
	bed.Anchored = true
	bed.Material = Enum.Material.Fabric
	bed.Color = Color3.fromRGB(124, 92, 70)
	CollectionService:AddTag(bed, "GrannyBed")
	bed.Parent = workspace
	return bed
end

function Prefabs.spawnGranny()
	local bed = Prefabs.spawnGrannyBed()
	
	-- Create Granny model
	local model = Instance.new("Model")
	model.Name = "Granny"
	
	-- HumanoidRootPart
	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"
	hrp.Size = Vector3.new(2, 2, 1)
	hrp.Position = bed.Position + Vector3.new(0, 2, 0)
	hrp.Anchored = false
	hrp.CanCollide = true
	hrp.Material = Enum.Material.Plastic
	hrp.Color = Color3.fromRGB(200, 180, 160)
	hrp.Parent = model
	
	-- Head
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.5, 1.5, 1.5)
	head.Position = hrp.Position + Vector3.new(0, 2, 0)
	head.Shape = Enum.PartType.Ball
	head.Material = Enum.Material.Plastic
	head.Color = Color3.fromRGB(220, 190, 170)
	
	local neckWeld = Instance.new("Weld")
	neckWeld.Part0 = hrp
	neckWeld.Part1 = head
	neckWeld.C0 = CFrame.new(0, 1.5, 0)
	neckWeld.Parent = head
	head.Parent = model
	
	-- Torso
	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(2, 2, 1)
	torso.Position = hrp.Position
	torso.Material = Enum.Material.Fabric
	torso.Color = Color3.fromRGB(100, 50, 100)
	
	local torsoWeld = Instance.new("Weld")
	torsoWeld.Part0 = hrp
	torsoWeld.Part1 = torso
	torsoWeld.C0 = CFrame.new(0, 0, 0)
	torsoWeld.Parent = torso
	torso.Parent = model
	
	-- Humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayName = "Granny"
	humanoid.Health = 999999
	humanoid.MaxHealth = 999999
	humanoid.WalkSpeed = 0
	humanoid.Parent = model
	
	model.PrimaryPart = hrp
	CollectionService:AddTag(model, "Granny")
	
	-- Animation
	local animator = Instance.new("Animator")
	animator.Parent = humanoid
	
	model.Parent = workspace
	
	return model
end

function Prefabs.createForEvent(spec: EventRegistry.EventSpec): Instance?
	-- Find appropriate room for this event type
	local roomName = getAppropriateRoom(spec.id)
	local roomData = rooms[roomName]
	
	if not roomData then
		warn("[Prefabs] No appropriate room found for event:", spec.id)
		return nil
	end
	
	local anchor = anchors[roomName]
	if not anchor then
		warn("[Prefabs] No anchor found in room:", roomName)
		return nil
	end
	
	-- Create specific prefab based on event type
	local prefab = createInteractivePrefab(spec, anchor.Position, roomData.model)
	
	if prefab then
		prefab:SetAttribute("EventId", spec.id)
		if spec.interactTag then
			CollectionService:AddTag(prefab, spec.interactTag)
		end
	end
	
	return prefab
end

function getAppropriateRoom(eventId: string): string
	-- Map event types to appropriate rooms
	if string.find(eventId, "baby") or string.find(eventId, "crib") then
		return "Nursery"
	elseif string.find(eventId, "window") or string.find(eventId, "shutter") then
		local windowRooms = {"LivingRoom", "Bedroom2", "Bedroom3", "Study"}
		return windowRooms[math.random(1, #windowRooms)]
	elseif string.find(eventId, "clock") then
		return math.random() > 0.5 and "Library" or "LivingRoom"
	elseif string.find(eventId, "phone") then
		local phoneRooms = {"Study", "LivingRoom", "Entryway"}
		return phoneRooms[math.random(1, #phoneRooms)]
	elseif string.find(eventId, "radio") then
		return "LivingRoom"
	elseif string.find(eventId, "door") then
		local doorRooms = {"Hallway2F", "Storage", "Bathroom"}
		return doorRooms[math.random(1, #doorRooms)]
	else
		-- Random room
		local allRooms = {"LivingRoom", "Kitchen", "Library", "Study", "DiningRoom"}
		return allRooms[math.random(1, #allRooms)]
	end
end

function createInteractivePrefab(spec: EventRegistry.EventSpec, position: Vector3, roomModel: Model): Model?
	local eventId = spec.id
	
	-- Adjust position to be inside room (not exactly at center)
	local offset = Vector3.new(
		math.random(-5, 5),
		1,
		math.random(-5, 5)
	)
	local prefabPos = position + offset
	
	if string.find(eventId, "window") or string.find(eventId, "shutter") then
		return InteractivePrefabs.createWindow(prefabPos, roomModel)
	elseif string.find(eventId, "clock") then
		local clockType = string.find(eventId, "grandfather") and "grandfather" or "wall"
		return InteractivePrefabs.createClock(prefabPos, roomModel, clockType)
	elseif string.find(eventId, "baby") or string.find(eventId, "crib") then
		return InteractivePrefabs.createBabyCrib(prefabPos, roomModel)
	elseif string.find(eventId, "phone") then
		return InteractivePrefabs.createPhone(prefabPos, roomModel)
	elseif string.find(eventId, "radio") then
		return InteractivePrefabs.createRadio(prefabPos, roomModel)
	elseif string.find(eventId, "door") then
		return InteractivePrefabs.createSqueakyDoor(prefabPos, roomModel)
	else
		-- Generic prefab
		local part = Instance.new("Part")
		part.Name = "GenericInteractable"
		part.Size = Vector3.new(2, 2, 2)
		part.Position = prefabPos
		part.Anchored = true
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(255, 100, 100)
		
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Interact"
		prompt.ObjectText = spec.name
		prompt.HoldDuration = 2
		prompt.MaxActivationDistance = 6
		prompt.Parent = part
		
		CollectionService:AddTag(part, "Interactable")
		part:SetAttribute("EventType", spec.id)
		part:SetAttribute("Completed", false)
		
		part.Parent = roomModel
		return part
	end
end

function Prefabs.getManor()
	return manorModel
end

function Prefabs.getRooms()
	return rooms
end

function Prefabs.getAnchors()
	return anchors
end

return Prefabs
