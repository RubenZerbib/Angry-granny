--!strict
-- Manor Loader: Charge le manoir existant et ajoute les lumi?res

local CollectionService = game:GetService("CollectionService")

local ManorLoader = {}

local manor
local rooms = {}
local spawns = {}
local patrolPoints = {}
local hidingSpots = {}
local keySpawns = {}
local noiseZones = {}

function ManorLoader.loadManor()
	print("[ManorLoader] Looking for Manor in workspace...")
	
	-- Find existing Manor
	manor = workspace:FindFirstChild("Manor")
	
	if not manor then
		warn("[ManorLoader] ?? Manor not found! Please insert manor.rbxmx into Studio.")
		warn("[ManorLoader] Creating fallback minimal manor...")
		return createFallbackManor()
	end
	
	print("[ManorLoader] ? Manor found! Indexing...")
	indexManorContent()
	addPointLightsToLamps()
	setupGameplayElements()
	
	print(string.format("[ManorLoader] ? Loaded: %d rooms, %d patrol points, %d hiding spots", 
		getTableSize(rooms), #patrolPoints, #hidingSpots))
	
	return manor, rooms
end

function indexManorContent()
	-- Index all Models (rooms) and Parts (markers)
	for _, child in ipairs(manor:GetChildren()) do
		if child:IsA("Model") then
			local roomName = child.Name
			
			-- Find floor to get room position
			local floor = child:FindFirstChild(roomName .. "_Floor")
			local pos = floor and floor.Position or child:GetPivot().Position
			
			rooms[roomName] = {
				model = child,
				position = pos
			}
			
			-- Add event anchor to room
			if not child:FindFirstChild("EventAnchor") then
				local anchor = Instance.new("Part")
				anchor.Name = "EventAnchor"
				anchor.Size = Vector3.new(2, 2, 2)
				anchor.Position = pos + Vector3.new(0, 2, 0)
				anchor.Anchored = true
				anchor.Transparency = 1
				anchor.CanCollide = false
				CollectionService:AddTag(anchor, "EventAnchor")
				anchor:SetAttribute("RoomType", roomName)
				anchor.Parent = child
			end
			
		elseif child:IsA("BasePart") then
			-- Index special markers
			local name = child.Name
			
			if string.find(name, "Spawn") then
				spawns[name] = child
			elseif string.find(name, "PatrolPoint") then
				table.insert(patrolPoints, child)
			elseif string.find(name, "HidingSpot") then
				table.insert(hidingSpots, child)
			elseif string.find(name, "KeySpawn") then
				table.insert(keySpawns, child)
			elseif string.find(name, "NoiseZone") then
				table.insert(noiseZones, child)
			end
		end
	end
end

function addPointLightsToLamps()
	-- Add PointLights to existing lamp bulbs
	for _, room in pairs(rooms) do
		for _, lamp in ipairs(room.model:GetDescendants()) do
			if lamp.Name == "Bulb" and lamp:IsA("BasePart") then
				-- Check if light already exists
				if not lamp:FindFirstChildOfClass("PointLight") then
					local light = Instance.new("PointLight")
					light.Brightness = 1.0
					light.Color = Color3.fromRGB(255, 240, 200)
					light.Range = 35
					light.Shadows = true
					light.Parent = lamp
					print("[ManorLoader] Added light to", lamp:GetFullName())
				end
			end
		end
	end
end

function setupGameplayElements()
	-- Ensure Granny bed exists at GrannySpawn
	local grannySpawn = spawns["GrannySpawn"]
	if grannySpawn and not workspace:FindFirstChild("GrannyBed", true) then
		local bed = Instance.new("Part")
		bed.Name = "GrannyBed"
		bed.Size = Vector3.new(6, 2, 8)
		bed.Position = grannySpawn.Position + Vector3.new(0, 1, 0)
		bed.Anchored = true
		bed.Material = Enum.Material.Fabric
		bed.Color = Color3.fromRGB(124, 92, 70)
		CollectionService:AddTag(bed, "GrannyBed")
		bed.Parent = manor
		print("[ManorLoader] Created Granny bed in Basement")
	end
	
	-- Ensure SpawnLocation at PlayerSpawn
	local playerSpawn = spawns["PlayerSpawn"]
	if playerSpawn and not workspace:FindFirstChild("SpawnLocation", true) then
		local spawn = Instance.new("SpawnLocation")
		spawn.Position = playerSpawn.Position
		spawn.Size = Vector3.new(6, 1, 6)
		spawn.Anchored = true
		spawn.BrickColor = BrickColor.new("Bright green")
		spawn.Transparency = 0.8
		spawn.CanCollide = false
		spawn.Duration = 0
		spawn.Parent = manor
		print("[ManorLoader] Created spawn location in Hall")
	end
end

function createFallbackManor()
	warn("[ManorLoader] ?? IMPORTANT: Insert manor.rbxmx into Studio!")
	warn("[ManorLoader] Creating minimal fallback for testing...")
	
	manor = Instance.new("Model")
	manor.Name = "Manor"
	
	-- Simple floor
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(60, 1, 60)
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
	spawn.Transparency = 0.5
	spawn.Parent = manor
	
	-- Granny bed
	local bed = Instance.new("Part")
	bed.Name = "GrannyBed"
	bed.Size = Vector3.new(6, 2, 8)
	bed.Position = Vector3.new(0, -3, 0)
	bed.Anchored = true
	bed.Material = Enum.Material.Fabric
	bed.Color = Color3.fromRGB(124, 92, 70)
	CollectionService:AddTag(bed, "GrannyBed")
	bed.Parent = manor
	
	-- Walls
	local wallSize = 60
	local walls = {
		{pos = Vector3.new(0, 5, -30), size = Vector3.new(wallSize, 10, 1)},
		{pos = Vector3.new(0, 5, 30), size = Vector3.new(wallSize, 10, 1)},
		{pos = Vector3.new(-30, 5, 0), size = Vector3.new(1, 10, wallSize)},
		{pos = Vector3.new(30, 5, 0), size = Vector3.new(1, 10, wallSize)},
	}
	
	for i, wallData in ipairs(walls) do
		local wall = Instance.new("Part")
		wall.Name = "Wall" .. i
		wall.Size = wallData.size
		wall.Position = wallData.pos
		wall.Anchored = true
		wall.Material = Enum.Material.Brick
		wall.Color = Color3.fromRGB(107, 50, 124)
		wall.Parent = manor
	end
	
	manor.Parent = workspace
	
	rooms["Hall"] = {model = manor, position = Vector3.new(0, 0, 0)}
	spawns["PlayerSpawn"] = spawn
	spawns["GrannySpawn"] = bed
	
	return manor, rooms
end

function getTableSize(t)
	local count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
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

function ManorLoader.getKeySpawns()
	return keySpawns
end

function ManorLoader.getNoiseZones()
	return noiseZones
end

return ManorLoader
