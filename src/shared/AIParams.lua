--!strict
-- Param?tres IA de Granny

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local AIParams = {}

export type GrannyParams = {
	speed: number,
	visionConeAngle: number,
	visionRange: number,
	hearingRadius: number,
	searchDuration: number,
	chaseDuration: number,
	cooldownDuration: number,
	hitRange: number,
}

function AIParams.getForNight(night: number): GrannyParams
	return {
		speed = Config.Curves.GrannySpeed(night),
		visionConeAngle = 60, -- degr?s
		visionRange = 50, -- studs
		hearingRadius = 30, -- studs (rayon de base, modul? par hotspot)
		searchDuration = 15, -- secondes
		chaseDuration = 30, -- secondes
		cooldownDuration = 10, -- secondes
		hitRange = 5, -- studs
	}
end

return AIParams
