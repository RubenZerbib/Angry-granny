--!strict
-- Gestion des achats IAP (GamePass & DevProducts)

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ItemCatalog = require(ReplicatedStorage.Shared.ItemCatalog)
local Economy = require(ServerScriptService.Server.Economy)
local Leaderstats = require(ServerScriptService.Server.Leaderstats)

local Purchase = ReplicatedStorage.Remotes.Purchase

local Purchases = {}

-- Historique des achats (pour ?viter les duplicatas)
local purchaseHistory: { [number]: boolean } = {}

function Purchases.init()
	-- ?couter les achats de GamePass
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
		if wasPurchased then
			handleGamePassPurchase(player, gamePassId)
		end
	end)

	-- ProcessReceipt pour les DevProducts
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		return handleDevProductPurchase(receiptInfo)
	end

	-- Remote pour les achats Coins
	Purchase.OnServerEvent:Connect(function(player, itemId)
		handleCoinsPurchase(player, itemId)
	end)
end

function handleGamePassPurchase(player: Player, gamePassId: number)
	local item = ItemCatalog.getByGamePassId(gamePassId)
	if not item then
		warn("[Purchases] GamePass inconnu : " .. tostring(gamePassId))
		return
	end

	-- Activer l'effet permanent
	Economy.activateItem(player, item.id)

	-- Notifier le joueur
	local Reward = ReplicatedStorage.Remotes.Reward
	Reward:FireClient(player, {
		type = "item_purchased",
		itemId = item.id,
		itemName = item.name,
	})
end

function handleDevProductPurchase(receiptInfo: any): Enum.ProductPurchaseDecision
	local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- V?rifier duplicata
	if purchaseHistory[receiptInfo.PurchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local item = ItemCatalog.getByDevProductId(receiptInfo.ProductId)
	if not item then
		warn("[Purchases] DevProduct inconnu : " .. tostring(receiptInfo.ProductId))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Activer l'effet
	local success = Economy.activateItem(player, item.id)
	if not success then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Marquer comme trait?
	purchaseHistory[receiptInfo.PurchaseId] = true

	-- Notifier le joueur
	local Reward = ReplicatedStorage.Remotes.Reward
	Reward:FireClient(player, {
		type = "item_purchased",
		itemId = item.id,
		itemName = item.name,
	})

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function handleCoinsPurchase(player: Player, itemId: string)
	local item = ItemCatalog.getById(itemId)
	if not item then
		warn("[Purchases] Item inconnu : " .. itemId)
		return
	end

	-- V?rifier si achat avec Coins
	if not item.priceCoins then
		warn("[Purchases] Item n'a pas de prix Coins : " .. itemId)
		return
	end

	-- V?rifier fonds
	local coins = Leaderstats.getCoins(player)
	if coins < item.priceCoins then
		-- Pas assez de Coins
		local Reward = ReplicatedStorage.Remotes.Reward
		Reward:FireClient(player, {
			type = "purchase_failed",
			reason = "insufficient_coins",
		})
		return
	end

	-- Retirer les Coins
	local success = Leaderstats.removeCoins(player, item.priceCoins)
	if not success then
		return
	end

	-- Activer l'effet
	Economy.activateItem(player, item.id)

	-- Notifier le joueur
	local Reward = ReplicatedStorage.Remotes.Reward
	Reward:FireClient(player, {
		type = "item_purchased",
		itemId = item.id,
		itemName = item.name,
	})
end

function Purchases.promptGamePass(player: Player, gamePassId: number)
	MarketplaceService:PromptGamePassPurchase(player, gamePassId)
end

function Purchases.promptDevProduct(player: Player, devProductId: number)
	MarketplaceService:PromptProductPurchase(player, devProductId)
end

function Purchases.ownsGamePass(player: Player, gamePassId: number): boolean
	local success, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
	end)
	return success and owns
end

return Purchases
