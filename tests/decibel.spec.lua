--!strict
-- Tests pour le syst?me de d?cibels

return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Decibel = require(ReplicatedStorage.Shared.Decibel)

	describe("Decibel", function()
		it("should initialize with zero decibels", function()
			local state = Decibel.new()
			expect(state.currentDb).to.equal(0)
			expect(state.trend).to.equal(0)
			expect(#state.hotspots).to.equal(0)
		end)

		it("should add decibels correctly", function()
			local state = Decibel.new()
			Decibel.add(state, "test", 50, { clamp = true })
			expect(state.currentDb).to.equal(50)
		end)

		it("should clamp decibels at 100", function()
			local state = Decibel.new()
			Decibel.add(state, "test", 150, { clamp = true })
			expect(state.currentDb).to.equal(100)
		end)

		it("should decay over time", function()
			local state = Decibel.new()
			Decibel.add(state, "test", 50, { clamp = true })
			Decibel.tick(state, 1, 5)
			expect(state.currentDb).to.equal(45)
		end)

		it("should not go below zero", function()
			local state = Decibel.new()
			Decibel.add(state, "test", 10, { clamp = true })
			Decibel.tick(state, 10, 5)
			expect(state.currentDb).to.equal(0)
		end)

		it("should accumulate pulses", function()
			local state = Decibel.new()
			Decibel.add(state, "test1", 20, { clamp = true })
			Decibel.add(state, "test2", 30, { clamp = true })
			expect(state.currentDb).to.equal(50)
		end)

		it("should record hotspots with positions", function()
			local state = Decibel.new()
			local position = Vector3.new(10, 0, 10)
			Decibel.add(state, "test", 50, { clamp = true, position = position })
			expect(#state.hotspots).to.equal(1)
			expect(state.hotspots[1].position).to.equal(position)
		end)

		it("should return top hotspots", function()
			local state = Decibel.new()
			Decibel.add(state, "test1", 10, { clamp = true, position = Vector3.new(0, 0, 0) })
			Decibel.add(state, "test2", 30, { clamp = true, position = Vector3.new(10, 0, 0) })
			Decibel.add(state, "test3", 20, { clamp = true, position = Vector3.new(20, 0, 0) })

			local top = Decibel.getTopHotspots(state, 2)
			expect(#top).to.equal(2)
			expect(top[1].weight).to.equal(30)
			expect(top[2].weight).to.equal(20)
		end)

		it("should calculate trend correctly", function()
			local state = Decibel.new()
			Decibel.add(state, "test", 50, { clamp = true })
			local oldDb = state.currentDb
			Decibel.tick(state, 1, 5)
			expect(state.trend).to.be.near(state.currentDb - oldDb, 0.1)
		end)
	end)
end
