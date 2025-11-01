--!strict
-- Utilitaires g?n?raux

local Util = {}

function Util.deepCopy(original: any): any
	if type(original) ~= "table" then
		return original
	end

	local copy = {}
	for k, v in pairs(original) do
		copy[k] = Util.deepCopy(v)
	end
	return copy
end

function Util.formatTime(seconds: number): string
	local minutes = math.floor(seconds / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%d:%02d", minutes, secs)
end

function Util.distanceTo(a: Vector3, b: Vector3): number
	return (a - b).Magnitude
end

function Util.lineOfSight(from: Vector3, to: Vector3, ignoreList: { Instance }?): boolean
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = ignoreList or {}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local direction = to - from
	local result = workspace:Raycast(from, direction, raycastParams)

	return result == nil
end

return Util
