--!strict
-- Tests pour le directeur de nuit

return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local NightDirector = require(ReplicatedStorage.Shared.NightDirector)

	describe("NightDirector", function()
		it("should return correct params for night 1", function()
			local params = NightDirector.getParams(1)
			expect(params.night).to.equal(1)
			expect(params.durationSec).to.equal(210)
			expect(params.thresholdDb).to.equal(70)
			expect(params.decayPerSecond).to.equal(4)
			expect(params.rewardCoins).to.equal(25)
		end)

		it("should have decreasing thresholds", function()
			local params1 = NightDirector.getParams(1)
			local params5 = NightDirector.getParams(5)
			expect(params5.thresholdDb).to.be.below(params1.thresholdDb)
		end)

		it("should have decreasing decay", function()
			local params1 = NightDirector.getParams(1)
			local params10 = NightDirector.getParams(10)
			expect(params10.decayPerSecond).to.be.below(params1.decayPerSecond)
		end)

		it("should have increasing Granny speed", function()
			local params1 = NightDirector.getParams(1)
			local params5 = NightDirector.getParams(5)
			expect(params5.grannySpeed).to.be.above(params1.grannySpeed)
		end)

		it("should respect threshold minimum", function()
			local params100 = NightDirector.getParams(100)
			expect(params100.thresholdDb).to.be.atLeast(48)
		end)

		it("should respect decay minimum", function()
			local params100 = NightDirector.getParams(100)
			expect(params100.decayPerSecond).to.be.atLeast(1.2)
		end)

		it("should have increasing rewards", function()
			local params1 = NightDirector.getParams(1)
			local params10 = NightDirector.getParams(10)
			expect(params10.rewardCoins).to.be.above(params1.rewardCoins)
		end)

		it("should increase max concurrent events", function()
			local params1 = NightDirector.getParams(1)
			local params10 = NightDirector.getParams(10)
			expect(params10.maxConcurrent).to.be.atLeast(params1.maxConcurrent)
		end)

		it("should cap duration at maximum", function()
			local params100 = NightDirector.getParams(100)
			expect(params100.durationSec).to.be.atMost(360)
		end)

		it("should cap max concurrent at 5", function()
			local params100 = NightDirector.getParams(100)
			expect(params100.maxConcurrent).to.be.atMost(5)
		end)
	end)
end
