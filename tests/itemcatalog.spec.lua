--!strict
-- Tests pour le catalogue d'items

return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local ItemCatalog = require(ReplicatedStorage.Shared.ItemCatalog)

	describe("ItemCatalog", function()
		it("should have exactly 30 items", function()
			expect(#ItemCatalog.Items).to.equal(30)
		end)

		it("should have all required fields for each item", function()
			for _, item in ipairs(ItemCatalog.Items) do
				expect(item.id).to.be.a("string")
				expect(item.name).to.be.a("string")
				expect(item.itemType).to.be.a("string")
				expect(item.effectId).to.be.a("string")
				expect(item.description).to.be.a("string")
			end
		end)

		it("should have valid item types", function()
			local validTypes = { pass = true, consumable = true, booster = true }
			for _, item in ipairs(ItemCatalog.Items) do
				expect(validTypes[item.itemType]).to.equal(true)
			end
		end)

		it("should have durations for consumables and boosters", function()
			for _, item in ipairs(ItemCatalog.Items) do
				if item.itemType == "consumable" or item.itemType == "booster" then
					-- Certains consumables n'ont pas de dur?e (instantan?s)
					-- mais les boosters doivent en avoir
					if item.itemType == "booster" then
						expect(item.durationSec).to.be.a("number")
						expect(item.durationSec).to.be.above(0)
					end
				end
			end
		end)

		it("should have prices (Coins or IAP)", function()
			for _, item in ipairs(ItemCatalog.Items) do
				local hasPrice = item.priceCoins ~= nil or item.devProductId ~= nil or item.gamePassId ~= nil
				expect(hasPrice).to.equal(true)
			end
		end)

		it("should find items by ID", function()
			local item = ItemCatalog.getById("silent_shoes")
			expect(item).to.be.ok()
			expect(item.name).to.equal("Chaussures silencieuses")
		end)

		it("should return nil for non-existent ID", function()
			local item = ItemCatalog.getById("nonexistent")
			expect(item).to.equal(nil)
		end)

		it("should find items by GamePass ID", function()
			local item = ItemCatalog.getByGamePassId(1234567890)
			expect(item).to.be.ok()
			expect(item.id).to.equal("silent_shoes")
		end)

		it("should find items by DevProduct ID", function()
			local item = ItemCatalog.getByDevProductId(9876543210)
			expect(item).to.be.ok()
			expect(item.id).to.equal("radio_lullaby")
		end)

		it("should have unique IDs", function()
			local seen = {}
			for _, item in ipairs(ItemCatalog.Items) do
				expect(seen[item.id]).to.equal(nil)
				seen[item.id] = true
			end
		end)

		it("should have reasonable coin prices", function()
			for _, item in ipairs(ItemCatalog.Items) do
				if item.priceCoins then
					expect(item.priceCoins).to.be.above(0)
					expect(item.priceCoins).to.be.atMost(1000)
				end
			end
		end)

		it("should have passes with gamePassId or high coin price", function()
			for _, item in ipairs(ItemCatalog.Items) do
				if item.itemType == "pass" then
					local hasGamePass = item.gamePassId ~= nil
					local hasHighPrice = item.priceCoins and item.priceCoins >= 400
					expect(hasGamePass or hasHighPrice).to.equal(true)
				end
			end
		end)
	end)
end
