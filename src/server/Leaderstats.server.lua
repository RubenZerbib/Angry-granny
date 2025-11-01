--!strict
-- Gestion des leaderstats (Coins)

local Players = game:GetService("Players")

local Leaderstats = {}

local coinData: { [Player]: NumberValue } = {}

function Leaderstats.init()
	Players.PlayerAdded:Connect(function(player)
		setupLeaderstats(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		coinData[player] = nil
	end)

	-- Configuration pour les joueurs d?j? pr?sents
	for _, player in ipairs(Players:GetPlayers()) do
		setupLeaderstats(player)
	end
end

function setupLeaderstats(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("NumberValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats

	coinData[player] = coins
end

function Leaderstats.addCoins(player: Player, amount: number): ()
	local coins = coinData[player]
	if coins then
		coins.Value = coins.Value + amount
	end
end

function Leaderstats.removeCoins(player: Player, amount: number): boolean
	local coins = coinData[player]
	if coins and coins.Value >= amount then
		coins.Value = coins.Value - amount
		return true
	end
	return false
end

function Leaderstats.getCoins(player: Player): number
	local coins = coinData[player]
	return if coins then coins.Value else 0
end

return Leaderstats
