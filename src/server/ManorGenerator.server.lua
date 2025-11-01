--!strict
-- Manor Generator: Creates a large explorable manor with rooms, hallways, and doors

local CollectionService = game:GetService("CollectionService")

local ManorGenerator = {}

local ROOM_SIZE = 20
local HALLWAY_WIDTH = 6
local WALL_HEIGHT = 12
local DOOR_WIDTH = 5
local DOOR_HEIGHT = 8

-- Room types and their purposes
local ROOM_TYPES = {
	"LivingRoom", "Kitchen", "Bedroom", "Bathroom", "Study", 
	"DiningRoom", "Library", "GrannyBedroom", "Nursery", "Storage",
	"Hallway", "Entryway", "Attic", "Basement"
}

-- Manor layout: 3x3 grid of rooms with hallways
local MANOR_LAYOUT = {
	-- Floor 1
	{name = "Entryway", pos = Vector3.new(0, 0, 0), size = Vector3.new(15, 12, 15)},
	{name = "LivingRoom", pos = Vector3.new(25, 0, 0), size = Vector3.new(20, 12, 20)},
	{name = "Kitchen", pos = Vector3.new(50, 0, 0), size = Vector3.new(18, 12, 18)},
	{name = "DiningRoom", pos = Vector3.new(0, 0, 25), size = Vector3.new(20, 12, 18)},
	{name = "Library", pos = Vector3.new(25, 0, 25), size = Vector3.new(20, 12, 20)},
	{name = "Study", pos = Vector3.new(50, 0, 25), size = Vector3.new(18, 12, 18)},
	{name = "Storage", pos = Vector3.new(0, 0, 50), size = Vector3.new(15, 12, 15)},
	{name = "Bathroom", pos = Vector3.new(25, 0, 50), size = Vector3.new(12, 12, 12)},
	{name = "Nursery", pos = Vector3.new(45, 0, 50), size = Vector3.new(18, 12, 15)},
	
	-- Floor 2
	{name = "GrannyBedroom", pos = Vector3.new(0, 14, 0), size = Vector3.new(20, 12, 20)},
	{name = "Bedroom2", pos = Vector3.new(25, 14, 0), size = Vector3.new(18, 12, 18)},
	{name = "Bedroom3", pos = Vector3.new(50, 14, 0), size = Vector3.new(15, 12, 15)},
	{name = "Hallway2F", pos = Vector3.new(25, 14, 25), size = Vector3.new(40, 12, 8)},
	{name = "Bathroom2", pos = Vector3.new(10, 14, 35), size = Vector3.new(12, 12, 12)},
	{name = "GuestRoom", pos = Vector3.new(40, 14, 35), size = Vector3.new(18, 12, 18)},
}

-- Connections (doors) between rooms
local CONNECTIONS = {
	{from = "Entryway", to = "LivingRoom"},
	{from = "LivingRoom", to = "Kitchen"},
	{from = "LivingRoom", to = "DiningRoom"},
	{from = "LivingRoom", to = "Library"},
	{from = "Kitchen", to = "Study"},
	{from = "DiningRoom", to = "Library"},
	{from = "Library", to = "Study"},
	{from = "Library", to = "Bathroom"},
	{from = "Bathroom", to = "Nursery"},
	{from = "Storage", to = "DiningRoom"},
	
	-- Stairs
	{from = "Entryway", to = "GrannyBedroom", isStairs = true},
	{from = "GrannyBedroom", to = "Bedroom2"},
	{from = "Bedroom2", to = "Bedroom3"},
	{from = "Bedroom2", to = "Hallway2F"},
	{from = "Hallway2F", to = "Bathroom2"},
	{from = "Hallway2F", to = "GuestRoom"},
}

function ManorGenerator.generateManor()
	local manor = Instance.new("Model")
	manor.Name = "Manor"
	
	-- Generate all rooms
	local rooms = {}
	for _, roomData in ipairs(MANOR_LAYOUT) do
		local room = createRoom(roomData)
		room.Parent = manor
		rooms[roomData.name] = {model = room, data = roomData}
	end
	
	-- Create connections (doors/hallways)
	for _, connection in ipairs(CONNECTIONS) do
		if rooms[connection.from] and rooms[connection.to] then
			createConnection(
				rooms[connection.from].data,
				rooms[connection.to].data,
				connection.isStairs or false,
				manor
			)
		end
	end
	
	-- Add lighting
	addLighting(manor)
	
	-- Add spawn point
	local spawn = Instance.new("SpawnLocation")
	spawn.Position = Vector3.new(0, 1, 0)
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Anchored = true
	spawn.BrickColor = BrickColor.new("Bright green")
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Parent = manor
	
	manor.Parent = workspace
	
	return manor, rooms
end

function createRoom(roomData)
	local room = Instance.new("Model")
	room.Name = roomData.name
	
	local pos = roomData.pos
	local size = roomData.size
	
	-- Floor
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(size.X, 1, size.Z)
	floor.Position = pos + Vector3.new(size.X/2, 0.5, size.Z/2)
	floor.Anchored = true
	floor.Material = Enum.Material.Wood
	floor.Color = Color3.fromRGB(101, 67, 33)
	floor.Parent = room
	
	-- Ceiling
	local ceiling = Instance.new("Part")
	ceiling.Name = "Ceiling"
	ceiling.Size = Vector3.new(size.X, 1, size.Z)
	ceiling.Position = pos + Vector3.new(size.X/2, size.Y - 0.5, size.Z/2)
	ceiling.Anchored = true
	ceiling.Material = Enum.Material.Wood
	ceiling.Color = Color3.fromRGB(91, 60, 30)
	ceiling.Parent = room
	
	-- Walls
	createWalls(room, pos, size)
	
	-- Special room decorations
	decorateRoom(room, roomData)
	
	-- Event anchor
	local anchor = Instance.new("Part")
	anchor.Name = roomData.name .. "Anchor"
	anchor.Size = Vector3.new(2, 2, 2)
	anchor.Position = pos + Vector3.new(size.X/2, 2, size.Z/2)
	anchor.Anchored = true
	anchor.Transparency = 1
	anchor.CanCollide = false
	CollectionService:AddTag(anchor, "EventAnchor")
	anchor:SetAttribute("RoomType", roomData.name)
	anchor.Parent = room
	
	return room
end

function createWalls(room, pos, size)
	local wallThickness = 1
	local wallHeight = size.Y
	
	-- North wall
	local north = Instance.new("Part")
	north.Name = "WallNorth"
	north.Size = Vector3.new(size.X, wallHeight, wallThickness)
	north.Position = pos + Vector3.new(size.X/2, wallHeight/2, 0)
	north.Anchored = true
	north.Material = Enum.Material.Brick
	north.Color = Color3.fromRGB(107, 50, 124)
	north.Parent = room
	
	-- South wall
	local south = Instance.new("Part")
	south.Name = "WallSouth"
	south.Size = Vector3.new(size.X, wallHeight, wallThickness)
	south.Position = pos + Vector3.new(size.X/2, wallHeight/2, size.Z)
	south.Anchored = true
	south.Material = Enum.Material.Brick
	south.Color = Color3.fromRGB(107, 50, 124)
	south.Parent = room
	
	-- West wall
	local west = Instance.new("Part")
	west.Name = "WallWest"
	west.Size = Vector3.new(wallThickness, wallHeight, size.Z)
	west.Position = pos + Vector3.new(0, wallHeight/2, size.Z/2)
	west.Anchored = true
	west.Material = Enum.Material.Brick
	west.Color = Color3.fromRGB(107, 50, 124)
	west.Parent = room
	
	-- East wall
	local east = Instance.new("Part")
	east.Name = "WallEast"
	east.Size = Vector3.new(wallThickness, wallHeight, size.Z)
	east.Position = pos + Vector3.new(size.X, wallHeight/2, size.Z/2)
	east.Anchored = true
	east.Material = Enum.Material.Brick
	east.Color = Color3.fromRGB(107, 50, 124)
	east.Parent = room
end

function decorateRoom(room, roomData)
	local pos = roomData.pos
	local size = roomData.size
	
	if roomData.name == "GrannyBedroom" then
		-- Granny's bed
		local bed = Instance.new("Part")
		bed.Name = "GrannyBed"
		bed.Size = Vector3.new(6, 2, 8)
		bed.Position = pos + Vector3.new(size.X * 0.3, 2, size.Z * 0.3)
		bed.Anchored = true
		bed.Material = Enum.Material.Fabric
		bed.Color = Color3.fromRGB(124, 92, 70)
		CollectionService:AddTag(bed, "GrannyBed")
		bed.Parent = room
		
	elseif roomData.name == "Nursery" then
		-- Baby crib
		local crib = Instance.new("Part")
		crib.Name = "BabyCrib"
		crib.Size = Vector3.new(4, 3, 4)
		crib.Position = pos + Vector3.new(size.X/2, 2.5, size.Z/2)
		crib.Anchored = true
		crib.Material = Enum.Material.Wood
		crib.Color = Color3.fromRGB(163, 162, 165)
		crib.Parent = room
		
	elseif roomData.name == "Kitchen" then
		-- Counter
		local counter = Instance.new("Part")
		counter.Name = "Counter"
		counter.Size = Vector3.new(10, 3, 2)
		counter.Position = pos + Vector3.new(size.X * 0.7, 2.5, size.Z * 0.3)
		counter.Anchored = true
		counter.Material = Enum.Material.Marble
		counter.Color = Color3.fromRGB(229, 228, 223)
		counter.Parent = room
		
	elseif roomData.name == "Library" then
		-- Bookshelf
		local shelf = Instance.new("Part")
		shelf.Name = "Bookshelf"
		shelf.Size = Vector3.new(12, 8, 2)
		shelf.Position = pos + Vector3.new(size.X * 0.2, 5, size.Z * 0.8)
		shelf.Anchored = true
		shelf.Material = Enum.Material.Wood
		shelf.Color = Color3.fromRGB(91, 60, 30)
		shelf.Parent = room
	end
end

function createConnection(room1Data, room2Data, isStairs, parent)
	-- Calculate midpoint between rooms
	local pos1 = room1Data.pos + room1Data.size/2
	local pos2 = room2Data.pos + room2Data.size/2
	local midpoint = (pos1 + pos2) / 2
	
	if isStairs then
		-- Create stairs
		createStairs(pos1, pos2, parent)
	else
		-- Create doorway
		createDoorway(midpoint, pos1, pos2, parent)
	end
end

function createDoorway(pos, room1Pos, room2Pos, parent)
	local doorway = Instance.new("Part")
	doorway.Name = "Doorway"
	doorway.Size = Vector3.new(DOOR_WIDTH, DOOR_HEIGHT, 1)
	doorway.Position = pos
	doorway.Anchored = true
	doorway.Transparency = 0.5
	doorway.Material = Enum.Material.Glass
	doorway.Color = Color3.fromRGB(163, 75, 75)
	doorway.CanCollide = false
	CollectionService:AddTag(doorway, "Door")
	doorway.Parent = parent
end

function createStairs(pos1, pos2, parent)
	local stairCount = 12
	local stairHeight = math.abs(pos2.Y - pos1.Y) / stairCount
	local direction = (pos2 - pos1).Unit
	local distance = (pos2 - pos1).Magnitude
	local stepDistance = distance / stairCount
	
	for i = 1, stairCount do
		local stair = Instance.new("Part")
		stair.Name = "Stair"
		stair.Size = Vector3.new(6, 1, 3)
		local yOffset = stairHeight * (i - 1)
		local posOffset = direction * (stepDistance * (i - 1))
		stair.Position = pos1 + posOffset + Vector3.new(0, yOffset, 0)
		stair.Anchored = true
		stair.Material = Enum.Material.Wood
		stair.Color = Color3.fromRGB(91, 60, 30)
		stair.Parent = parent
	end
end

function addLighting(manor)
	-- Add ambient lighting to all rooms
	for _, room in ipairs(manor:GetChildren()) do
		if room:IsA("Model") then
			local light = Instance.new("PointLight")
			light.Brightness = 0.5
			light.Color = Color3.fromRGB(255, 200, 150)
			light.Range = 30
			light.Shadows = true
			
			local floor = room:FindFirstChild("Floor")
			if floor then
				local lightPart = Instance.new("Part")
				lightPart.Name = "Light"
				lightPart.Size = Vector3.new(1, 1, 1)
				lightPart.Position = floor.Position + Vector3.new(0, 8, 0)
				lightPart.Anchored = true
				lightPart.Transparency = 1
				lightPart.CanCollide = false
				light.Parent = lightPart
				lightPart.Parent = room
			end
		end
	end
	
	-- Dark ambient lighting
	game.Lighting.Ambient = Color3.fromRGB(20, 20, 30)
	game.Lighting.OutdoorAmbient = Color3.fromRGB(20, 20, 30)
	game.Lighting.Brightness = 0.5
	game.Lighting.ClockTime = 0 -- Midnight
end

return ManorGenerator
