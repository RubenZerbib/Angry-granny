--!strict
-- Syst?me audio : ambiance + tension selon dB et ?tat Granny

local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DecibelUpdate = ReplicatedStorage.Remotes.DecibelUpdate
local GrannyState = ReplicatedStorage.Remotes.GrannyState

-- Cr?er les sons de base
local ambientSound = Instance.new("Sound")
ambientSound.Name = "Ambient"
ambientSound.SoundId = "rbxassetid://1841647093" -- Placeholder ambient
ambientSound.Volume = 0.3
ambientSound.Looped = true
ambientSound.Parent = SoundService

local tensionSound = Instance.new("Sound")
tensionSound.Name = "Tension"
tensionSound.SoundId = "rbxassetid://1841647093" -- Placeholder tension
tensionSound.Volume = 0
tensionSound.Looped = true
tensionSound.Parent = SoundService

ambientSound:Play()
tensionSound:Play()

-- ?tat
local currentDb = 0
local currentThreshold = 70
local grannyStateValue = "Sleeping"

DecibelUpdate.OnClientEvent:Connect(function(db, threshold, trend)
	currentDb = db
	currentThreshold = threshold
	updateAudio()
end)

GrannyState.OnClientEvent:Connect(function(data)
	grannyStateValue = data.state
	updateAudio()
end)

function updateAudio()
	-- Tension selon le niveau de dB
	local ratio = math.clamp(currentDb / currentThreshold, 0, 1)
	tensionSound.Volume = ratio * 0.5

	-- Augmenter la tension si Granny chasse
	if grannyStateValue == "Chasing" then
		tensionSound.Volume = math.min(1, tensionSound.Volume + 0.3)
		tensionSound.PlaybackSpeed = 1.2
	elseif grannyStateValue == "Searching" then
		tensionSound.PlaybackSpeed = 1.1
	else
		tensionSound.PlaybackSpeed = 1.0
	end
end
