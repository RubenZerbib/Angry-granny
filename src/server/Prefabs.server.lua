--!strict
-- Cr?ation de prefabs et de la map placeholder

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local EventRegistry = require(ReplicatedStorage.Shared.EventRegistry)

local Prefabs = {}

-- Trouve ou cr?e des anchors dans le workspace
local anchors: { [string]: BasePart } = {}

local function ensureFolder(name, parent)
	local f = parent:FindFirstChild(name)
	if not f then f = Instance.new("Folder"); f.Name = name; f.Parent = parent end
	return f
end

function Prefabs.spawnGrannyBed()
	local anchorsFolder = ensureFolder("EventAnchors", workspace)
	local bed = anchorsFolder:FindFirstChild("GrannyBedAnchor")
	if bed then return bed end
	-- create simple bed anchor
	bed = Instance.new("Part")
	bed.Name = "GrannyBedAnchor"
	bed.Size = Vector3.new(4,1,8)
	bed.Anchored = true
	bed.Position = Vector3.new(0,1,0) + Vector3.new(0,0, -20) -- behind player start
	bed.Material = Enum.Material.Wood
	bed.Color = Color3.fromRGB(124, 92, 70)
	bed.Parent = anchorsFolder
	CollectionService:AddTag(bed, "GrannyBed")
	return bed
end

function Prefabs.spawnGranny()
	local bed = Prefabs.spawnGrannyBed()
	-- Create a simple Granny model if none provided
	local model = Instance.new("Model"); model.Name = "Granny"
	local hrp = Instance.new("Part"); hrp.Name="HumanoidRootPart"; hrp.Size=Vector3.new(2,2,1); hrp.Anchored=false; hrp.Position=bed.Position+Vector3.new(0,3,0); hrp.Parent=model
	local hum = Instance.new("Humanoid"); hum.Parent=model
	model.PrimaryPart = hrp
	model.Parent = workspace

	-- Animation placeholder (sleep)
	local anim = Instance.new("Animation")
	anim.Name = "SleepAnim"
	-- Placeholder asset; dev peut remplacer par un ID custom
	anim.AnimationId = "rbxassetid://507771019" -- idle lay-ish fallback (replace later)
	anim.Parent = model
	local track = hum:LoadAnimation(anim)
	track:Play()
	return model
end

function Prefabs.init()
	-- Cr?er une map placeholder si aucune map n'existe
	if not workspace:FindFirstChild("House") then
		createPlaceholderMap()
	end

	-- Indexer les anchors
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj:HasTag("EventAnchor") then
			anchors[obj.Name] = obj
		end
	end
end

function createPlaceholderMap()
	local house = Instance.new("Model")
	house.Name = "House"
	house.Parent = workspace

	-- Sol
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(100, 1, 100)
	floor.Position = Vector3.new(0, 0, 0)
	floor.Anchored = true
	floor.BrickColor = BrickColor.new("Dark stone grey")
	floor.Material = Enum.Material.Concrete
	floor.Parent = house

	-- Murs
	local wall1 = Instance.new("Part")
	wall1.Name = "Wall1"
	wall1.Size = Vector3.new(100, 10, 1)
	wall1.Position = Vector3.new(0, 5, -50)
	wall1.Anchored = true
	wall1.BrickColor = BrickColor.new("Light stone grey")
	wall1.Parent = house

	local wall2 = Instance.new("Part")
	wall2.Name = "Wall2"
	wall2.Size = Vector3.new(100, 10, 1)
	wall2.Position = Vector3.new(0, 5, 50)
	wall2.Anchored = true
	wall2.BrickColor = BrickColor.new("Light stone grey")
	wall2.Parent = house

	local wall3 = Instance.new("Part")
	wall3.Name = "Wall3"
	wall3.Size = Vector3.new(1, 10, 100)
	wall3.Position = Vector3.new(-50, 5, 0)
	wall3.Anchored = true
	wall3.BrickColor = BrickColor.new("Light stone grey")
	wall3.Parent = house

	local wall4 = Instance.new("Part")
	wall4.Name = "Wall4"
	wall4.Size = Vector3.new(1, 10, 100)
	wall4.Position = Vector3.new(50, 5, 0)
	wall4.Anchored = true
	wall4.BrickColor = BrickColor.new("Light stone grey")
	wall4.Parent = house

	-- Lit de Granny
	local bed = Instance.new("Part")
	bed.Name = "GrannyBed"
	bed.Size = Vector3.new(4, 1, 6)
	bed.Position = Vector3.new(-35, 1, -35)
	bed.Anchored = true
	bed.BrickColor = BrickColor.new("Maroon")
	bed:AddTag("GrannyBed")
	bed.Parent = house

	-- Cr?er quelques anchors
	local anchorPositions = {
		{ name = "LivingRoom", pos = Vector3.new(0, 1, 0) },
		{ name = "Kitchen", pos = Vector3.new(30, 1, 30) },
		{ name = "Hallway", pos = Vector3.new(-20, 1, 0) },
		{ name = "Bedroom", pos = Vector3.new(-35, 1, -30) },
		{ name = "Basement", pos = Vector3.new(0, -10, -40) },
	}

	for _, data in ipairs(anchorPositions) do
		local anchor = Instance.new("Part")
		anchor.Name = data.name
		anchor.Size = Vector3.new(2, 2, 2)
		anchor.Position = data.pos
		anchor.Anchored = true
		anchor.Transparency = 1
		anchor.CanCollide = false
		anchor:AddTag("EventAnchor")
		anchor.Parent = house
		anchors[data.name] = anchor
	end

	-- Point de spawn joueur
	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Position = Vector3.new(0, 2, 0)
	spawnLocation.Size = Vector3.new(6, 1, 6)
	spawnLocation.Anchored = true
	spawnLocation.BrickColor = BrickColor.new("Bright green")
	spawnLocation.Parent = house
end

function Prefabs.createForEvent(spec: EventRegistry.EventSpec): Instance?
	-- Trouver un anchor al?atoire
	local anchorList = {}
	for name, anchor in pairs(anchors) do
		table.insert(anchorList, anchor)
	end

	if #anchorList == 0 then
		warn("[Prefabs] Aucun anchor disponible")
		return nil
	end

	local anchor = anchorList[math.random(1, #anchorList)]

	-- Cr?er le prefab selon le type
	local prefab = createBasicPrefab(spec.prefabType, anchor.Position)
	if prefab then
		if spec.interactTag then
			prefab:AddTag(spec.interactTag)
		end
		prefab:AddTag("Interactable")
		prefab:SetAttribute("EventId", spec.id)
	end

	return prefab
end

function createBasicPrefab(prefabType: string, position: Vector3): BasePart?
	local part = Instance.new("Part")
	part.Name = prefabType
	part.Size = Vector3.new(3, 3, 3)
	part.Position = position + Vector3.new(0, 2, 0)
	part.Anchored = true
	part.BrickColor = BrickColor.new("Bright red")
	part.Material = Enum.Material.Neon
	part.Parent = workspace

	-- Ajouter un BillboardGui pour identifier
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.Adornee = part
	billboard.AlwaysOnTop = true
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 0.5
	label.BackgroundColor3 = Color3.new(1, 0, 0)
	label.Text = "!"
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

	return part
end

return Prefabs
