--!strict
-- Utilitaire RNG pour s?lections pond?r?es

local RNG = {}

function RNG.weightedChoice(items: { any }, weights: { number }): any?
	if #items == 0 or #items ~= #weights then
		return nil
	end

	local totalWeight = 0
	for _, weight in ipairs(weights) do
		totalWeight = totalWeight + weight
	end

	if totalWeight <= 0 then
		return nil
	end

	local roll = math.random() * totalWeight
	local cumulative = 0

	for i, weight in ipairs(weights) do
		cumulative = cumulative + weight
		if roll <= cumulative then
			return items[i]
		end
	end

	return items[#items]
end

function RNG.shuffle(list: { any }): { any }
	local result = table.clone(list)
	for i = #result, 2, -1 do
		local j = math.random(1, i)
		result[i], result[j] = result[j], result[i]
	end
	return result
end

return RNG
