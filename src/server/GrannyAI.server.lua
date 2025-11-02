--!strict
-- IA de Granny : r?veil ? recherche ? poursuite ? frappe

local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local AIParams = require(ReplicatedStorage.Shared.AIParams)
local DecibelServer = require(ServerScriptService.Server.DecibelServer)
local Prefabs = require(ServerScriptService.Server.Prefabs)
local ManorLoader = require(ServerScriptService.Server.ManorLoader)

local GrannyState = ReplicatedStorage.Remotes.GrannyState

local GrannyAI = {}

-- ?tats possibles
export type AIState = "Sleeping" | "Searching" | "Chasing" | "Cooldown"

-- ?tat global
local currentState: AIState = "Sleeping"
local grannyModel: Model?
local grannyHumanoid: Humanoid?
local params: AIParams.GrannyParams
local stateStartTime = 0
local targetPlayer: Player?
local lastHotspotPosition: Vector3?
local patrolPoints = {}
local currentPatrolIndex = 1

function GrannyAI.init()
	-- Check if Granny already exists
	if not grannyModel or not grannyModel.Parent then
		grannyModel = workspace:FindFirstChild("Granny") or Prefabs.spawnGranny()
	end
	
	grannyHumanoid = grannyModel:FindFirstChildOfClass("Humanoid")
	if not grannyHumanoid then
		warn("[GrannyAI] Granny model has no Humanoid!")
		return
	end

	-- Load patrol points from manor
	patrolPoints = ManorLoader.getPatrolPoints()
	print("[GrannyAI] Loaded", #patrolPoints, "patrol points")

	params = AIParams.getForNight(1)
	currentState = "Sleeping"
	stateStartTime = tick()
	notifyClients()

	-- Boucle d'IA
	RunService.Heartbeat:Connect(function()
		tick_AI()
	end)
end

function GrannyAI.reset(speed: number)
	currentState = "Sleeping"
	params.speed = speed
	stateStartTime = tick()
	targetPlayer = nil
	lastHotspotPosition = nil
	notifyClients()
end

function GrannyAI.wake()
	if currentState == "Sleeping" then
		currentState = "Searching"
		stateStartTime = tick()
		notifyClients()

		-- R?cup?rer le hotspot le plus r?cent
		local hotspots = DecibelServer.getTopHotspots(1)
		if #hotspots > 0 and hotspots[1].position then
			lastHotspotPosition = hotspots[1].position
		end
	end
end

function GrannyAI.getState(): AIState
	return currentState
end

function GrannyAI.GetModel()
	return grannyModel
end

function GrannyAI.GetState()
	return currentState
end

function tick_AI()
	if not grannyModel or not grannyHumanoid then
		return
	end

	local elapsed = tick() - stateStartTime

	if currentState == "Sleeping" then
		-- Ne rien faire
		grannyHumanoid.WalkSpeed = 0
	elseif currentState == "Searching" then
		grannyHumanoid.WalkSpeed = params.speed * 0.7

		-- Use hotspot if available, otherwise patrol
		if lastHotspotPosition then
			moveToPosition(lastHotspotPosition)
			-- Clear hotspot after some time
			if elapsed > 5 then
				lastHotspotPosition = nil
			end
		elseif #patrolPoints > 0 then
			-- Patrol between points
			local targetPoint = patrolPoints[currentPatrolIndex]
			if targetPoint then
				moveToPosition(targetPoint.Position)
				
				-- Check if reached point
				local distance = (grannyModel:GetPivot().Position - targetPoint.Position).Magnitude
				if distance < 5 then
					-- Move to next patrol point
					currentPatrolIndex = currentPatrolIndex + 1
					if currentPatrolIndex > #patrolPoints then
						currentPatrolIndex = 1
					end
				end
			end
		end

		-- Chercher un joueur visible
		local player = findVisiblePlayer()
		if player then
			targetPlayer = player
			currentState = "Chasing"
			stateStartTime = tick()
			notifyClients()
		elseif elapsed > params.searchDuration then
			currentState = "Cooldown"
			stateStartTime = tick()
			notifyClients()
		end
	elseif currentState == "Chasing" then
		grannyHumanoid.WalkSpeed = params.speed

		if targetPlayer and targetPlayer.Character then
			local targetPos = targetPlayer.Character:GetPivot().Position
			moveToPosition(targetPos)

			-- V?rifier distance de frappe
			local distance = (grannyModel:GetPivot().Position - targetPos).Magnitude
			if distance < params.hitRange then
				hitPlayer(targetPlayer)
			end
		else
			targetPlayer = nil
			currentState = "Searching"
			stateStartTime = tick()
			notifyClients()
		end

		if elapsed > params.chaseDuration then
			currentState = "Cooldown"
			stateStartTime = tick()
			notifyClients()
		end
	elseif currentState == "Cooldown" then
		grannyHumanoid.WalkSpeed = params.speed * 0.5

		-- Retourner au lit
		local bed = workspace:FindFirstChild("GrannyBed", true)
		if bed and bed:IsA("BasePart") then
			moveToPosition(bed.Position)
		end

		if elapsed > params.cooldownDuration then
			currentState = "Sleeping"
			stateStartTime = tick()
			notifyClients()
		end
	end
end

function moveToPosition(pos: Vector3)
	if not grannyHumanoid or not grannyModel then
		return
	end

	local humanoidRootPart = grannyModel:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart or not humanoidRootPart:IsA("BasePart") then
		return
	end

	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
	})

	local success, errorMessage = pcall(function()
		path:ComputeAsync(humanoidRootPart.Position, pos)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		if #waypoints > 1 then
			grannyHumanoid:MoveTo(waypoints[2].Position)
		end
	else
		-- Fallback: marcher directement
		grannyHumanoid:MoveTo(pos)
	end
end

function findVisiblePlayer(): Player?
	if not grannyModel then
		return nil
	end

	local humanoidRootPart = grannyModel:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart or not humanoidRootPart:IsA("BasePart") then
		return nil
	end

	local grannyPos = humanoidRootPart.Position

	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")

			if humanoid and humanoid.Health > 0 and playerRoot and playerRoot:IsA("BasePart") then
				local playerPos = playerRoot.Position
				local distance = (grannyPos - playerPos).Magnitude

				if distance < params.visionRange then
					-- V?rifier angle de vision
					local direction = (playerPos - grannyPos).Unit
					local forward = humanoidRootPart.CFrame.LookVector
					local angle = math.deg(math.acos(forward:Dot(direction)))

					if angle < params.visionConeAngle / 2 then
						-- V?rifier line of sight
						local raycastParams = RaycastParams.new()
						raycastParams.FilterDescendantsInstances = { grannyModel }
						raycastParams.FilterType = Enum.RaycastFilterType.Exclude

						local result = workspace:Raycast(grannyPos, playerPos - grannyPos, raycastParams)
						if not result or result.Instance:IsDescendantOf(player.Character) then
							return player
						end
					end
				end
			end
		end
	end

	return nil
end

function hitPlayer(player: Player)
	if not player.Character then
		return
	end

	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Health = 0

		-- Fin de nuit (d?faite)
		local NightServer = require(ServerScriptService.Server.NightServer)
		NightServer.endNight(false)
	end
end

function notifyClients()
	GrannyState:FireAllClients({
		state = currentState,
		position = if grannyModel then grannyModel:GetPivot().Position else Vector3.zero,
	})
end

return GrannyAI
