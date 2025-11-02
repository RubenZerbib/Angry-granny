--!strict
-- Manor Loader: Charge le manoir depuis le fichier XML et configure le gameplay

local CollectionService = game:GetService("CollectionService")
local InsertService = game:GetService("InsertService")

local ManorLoader = {}

local manor
local rooms = {}
local spawns = {}
local patrolPoints = {}
local hidingSpots = {}

function ManorLoader.loadManor()
	print("[ManorLoader] Checking for existing Manor model...")
	
	-- Check if Manor already exists in workspace
	manor = workspace:FindFirstChild("Manor")
	
	if manor then
		print("[ManorLoader] Manor found! Indexing rooms and spawns...")
		indexManorContent()
		addGameplayElements()
		return manor, rooms
	else
		warn("[ManorLoader] No Manor found in workspace! Please insert the manor model.")
		return createFallbackManor()
	end
end

function indexManorContent()
	-- Index all rooms
	for _, child in ipairs(manor:GetChildren()) do
		if child:IsA("Model") then
			local roomName = child.Name
			rooms[roomName] = {
				model = child,
				position = child:GetPivot().Position
			}
			print("[ManorLoader] Found room:", roomName)
			
			-- Add event anchor to room if it doesn't have one
			if not child:FindFirstChild("EventAnchor") then
				local anchor = Instance.new("Part")
				anchor.Name = "EventAnchor"
				anchor.Size = Vector3.new(2, 2, 2)
				anchor.Position = child:GetPivot().Position
				anchor.Anchored = true
				anchor.Transparency = 1
				anchor.CanCollide = false
				CollectionService:AddTag(anchor, "EventAnchor")
				anchor:SetAttribute("RoomType", roomName)
				anchor.Parent = child
			end
		elseif child:IsA("BasePart") then
			-- Index spawn points and markers
			if string.find(child.Name, "Spawn") then
				spawns[child.Name] = child
			elseif string.find(child.Name, "PatrolPoint") then
				table.insert(patrolPoints, child)
			elseif string.find(child.Name, "HidingSpot") then
				table.insert(hidingSpots, child)
			end
		end
	end
	
	print("[ManorLoader] Indexed", #patrolPoints, "patrol points")
	print("[ManorLoader] Indexed", #hidingSpots, "hiding spots")
end

function addGameplayElements()
	-- Add lighting to rooms
	for roomName, roomData in pairs(rooms) do
		if not roomData.model:FindFirstChild("Light") then
			local floor = roomData.model:FindFirstChild(roomName .. "_Floor")
			if floor and floor:IsA("BasePart") then
				local lightPart = Instance.new("Part")
				lightPart.Name = "Light"
				lightPart.Size = Vector3.new(1, 1, 1)
				lightPart.Position = floor.Position + Vector3.new(0, 8, 0)
				lightPart.Anchored = true
				lightPart.Transparency = 1
				lightPart.CanCollide = false
				
				local light = Instance.new("PointLight")
				light.Brightness = 0.5
				light.Color = Color3.fromRGB(255, 200, 150)
				light.Range = 30
				light.Shadows = true
				light.Parent = lightPart
				
				lightPart.Parent = roomData.model
			end
		end
	end
	
	-- Ensure Granny spawn has a bed
	local grannySpawn = spawns["GrannySpawn"]
	if grannySpawn and not manor:FindFirstChild("GrannyBed") then
		local bed = Instance.new("Part")
		bed.Name = "GrannyBed"
		bed.Size = Vector3.new(6, 2, 8)
		bed.Position = grannySpawn.Position + Vector3.new(0, 1, 0)
		bed.Anchored = true
		bed.Material = Enum.Material.Fabric
		bed.Color = Color3.fromRGB(124, 92, 70)
		CollectionService:AddTag(bed, "GrannyBed")
		bed.Parent = manor
	end
	
	-- Add SpawnLocation at PlayerSpawn
	local playerSpawn = spawns["PlayerSpawn"]
	if playerSpawn and not manor:FindFirstChild("SpawnLocation") then
		local spawn = Instance.new("SpawnLocation")
		spawn.Position = playerSpawn.Position
		spawn.Size = Vector3.new(6, 1, 6)
		spawn.Anchored = true
		spawn.BrickColor = BrickColor.new("Bright green")
		spawn.Transparency = 0.8
		spawn.CanCollide = false
		spawn.Parent = manor
	end
end

function createFallbackManor()
	-- Create minimal fallback if manor not found
	warn("[ManorLoader] Creating fallback manor...")
	
	manor = Instance.new("Model")
	manor.Name = "Manor"
	
	-- Simple room
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(50, 1, 50)
	floor.Position = Vector3.new(0, 0, 0)
	floor.Anchored = true
	floor.Material = Enum.Material.Wood
	floor.Color = Color3.fromRGB(101, 67, 33)
	floor.Parent = manor
	
	-- Spawn point
	local spawn = Instance.new("SpawnLocation")
	spawn.Position = Vector3.new(0, 2, 0)
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Anchored = true
	spawn.BrickColor = BrickColor.new("Bright green")
	spawn.Parent = manor
	
	-- Granny bed
	local bed = Instance.new("Part")
	bed.Name = "GrannyBed"
	bed.Size = Vector3.new(6, 2, 8)
	bed.Position = Vector3.new(20, 2, 20)
	bed.Anchored = true
	bed.Material = Enum.Material.Fabric
	bed.Color = Color3.fromRGB(124, 92, 70)
	CollectionService:AddTag(bed, "GrannyBed")
	bed.Parent = manor
	
	manor.Parent = workspace
	
	rooms["Hall"] = {model = manor, position = Vector3.new(0, 0, 0)}
	
	return manor, rooms
end

function ManorLoader.getManor()
	return manor
end

function ManorLoader.getRooms()
	return rooms
end

function ManorLoader.getSpawns()
	return spawns
end

function ManorLoader.getPatrolPoints()
	return patrolPoints
end

function ManorLoader.getHidingSpots()
	return hidingSpots
end

return ManorLoader
