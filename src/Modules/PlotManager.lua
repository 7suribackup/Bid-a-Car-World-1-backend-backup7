-- ========================================
-- PLOT MANAGER - Conveyor System
-- ========================================

local PlotManager = {}
local PlayerDataManager = require(game.ReplicatedStorage.Modules.PlayerDataManager)
local Config = require(game.ReplicatedStorage.Modules.Config)

-- ========== PLACE CAR ON CONVEYOR ==========
function PlotManager:PlaceCar(playerId, carId, conveyorId)
	local conveyor = PlayerDataManager:GetConveyor(playerId, conveyorId)
	if not conveyor then return false end
	
	conveyor.carId = carId
	return true
end

-- ========== REMOVE CAR FROM CONVEYOR ==========
function PlotManager:RemoveCar(playerId, conveyorId)
	local conveyor = PlayerDataManager:GetConveyor(playerId, conveyorId)
	if not conveyor then return false end
	
	conveyor.carId = nil
	return true
end

-- ========== PLACE NPC ON CONVEYOR ==========
function PlotManager:PlaceNPC(playerId, npcId, conveyorId)
	local conveyor = PlayerDataManager:GetConveyor(playerId, conveyorId)
	if not conveyor then return false end
	
	conveyor.npcId = npcId
	return true
end

-- ========== REMOVE NPC FROM CONVEYOR ==========
function PlotManager:RemoveNPC(playerId, conveyorId)
	local conveyor = PlayerDataManager:GetConveyor(playerId, conveyorId)
	if not conveyor then return false end
	
	conveyor.npcId = nil
	return true
end

-- ========== COLLECT INCOME ==========
function PlotManager:CollectIncome(playerId, conveyorId)
	local conveyor = PlayerDataManager:GetConveyor(playerId, conveyorId)
	if not conveyor or not conveyor.carId then return 0 end
	
	local accumulated = conveyor.incomeAccumulated
	conveyor.incomeAccumulated = 0
	conveyor.lastCollected = os.time()
	
	PlayerDataManager:UpdateMoney(playerId, accumulated)
	PlayerDataManager:UpdateStats(playerId, "totalIncomeCollected", accumulated)
	
	return accumulated
end

-- ========== CALCULATE OFFLINE INCOME ==========
function PlotManager:CalculateOfflineIncome(playerId, conveyorId)
	local conveyor = PlayerDataManager:GetConveyor(playerId, conveyorId)
	if not conveyor or not conveyor.carId then return 0 end
	
	local timeSinceLastCollect = os.time() - conveyor.lastCollected
	local maxOfflineTime = Config.Game.OfflineIncomeMax
	local actualTime = math.min(timeSinceLastCollect, maxOfflineTime)
	
	-- Base income per second
	local baseIncomePerMin = 50 -- Default, should get from car data
	local baseIncomePerSec = baseIncomePerMin / 60
	
	-- NPC boost (if exists)
	local boostPercent = 0
	if conveyor.npcId then
		boostPercent = 50 -- Default, should get from NPC data
	end
	
	local totalIncomePerSec = baseIncomePerSec * (1 + boostPercent / 100)
	local accumulated = totalIncomePerSec * actualTime
	
	return math.floor(accumulated)
end

-- ========== UNLOCK CONVEYOR ==========
function PlotManager:UnlockConveyor(playerId)
	local plot = PlayerDataManager:GetPlot(playerId)
	if not plot then return false end
	
	if plot.unlockedCount >= Config.Game.MaxConveyors then
		return false
	end
	
	plot.unlockedCount = plot.unlockedCount + 1
	table.insert(plot.conveyors, {
		id = "conveyor_" .. plot.unlockedCount,
		carId = nil,
		npcId = nil,
		incomeAccumulated = 0,
		lastCollected = os.time(),
	})
	
	return true
end

-- ========== GET PLOT STATUS ==========
function PlotManager:GetPlotStatus(playerId)
	local plot = PlayerDataManager:GetPlot(playerId)
	if not plot then return nil end
	
	local conveyorStatus = {}
	for _, conveyor in ipairs(plot.conveyors) do
		table.insert(conveyorStatus, {
			id = conveyor.id,
			carId = conveyor.carId,
			npcId = conveyor.npcId,
			incomeAccumulated = conveyor.incomeAccumulated,
		})
	end
	
	return {
		totalConveyors = plot.totalConveyors,
		unlockedCount = plot.unlockedCount,
		conveyors = conveyorStatus,
	}
end

return PlotManager