-- ========================================
-- INCOME GENERATOR - Passive Money System
-- ========================================

local IncomeGenerator = {}
local PlayerDataManager = require(game.ReplicatedStorage.Modules.PlayerDataManager)
local PlotManager = require(game.ReplicatedStorage.Modules.PlotManager)
local Config = require(game.ReplicatedStorage.Modules.Config)

-- ========== CALCULATE ACCUMULATED INCOME ==========
function IncomeGenerator:CalculateAccumulatedIncome(conveyorData, carData, npcData)
	if not conveyorData or not carData then return 0 end
	
	local timeSinceLastCollect = os.time() - conveyorData.lastCollected
	local maxOfflineTime = Config.Game.OfflineIncomeMax
	local actualTime = math.min(timeSinceLastCollect, maxOfflineTime)
	
	local baseIncomePerMin = carData.income or 50
	local baseIncomePerSec = baseIncomePerMin / 60
	
	-- Apply NPC boost if exists
	local boostPercent = 0
	if npcData then
		boostPercent = npcData.boostPercent or 0
	end
	
	local totalIncomePerSec = baseIncomePerSec * (1 + boostPercent / 100)
	local accumulated = totalIncomePerSec * actualTime
	
	return math.floor(accumulated)
end

-- ========== ADD ACCUMULATED INCOME ==========
function IncomeGenerator:AddAccumulatedIncome(playerId, conveyorId, amount)
	local conveyor = PlayerDataManager:GetConveyor(playerId, conveyorId)
	if not conveyor then return false end
	
	conveyor.incomeAccumulated = conveyor.incomeAccumulated + amount
	return true
end

-- ========== COLLECT ALL INCOME ==========
function IncomeGenerator:CollectAll(playerId)
	local plot = PlayerDataManager:GetPlot(playerId)
	if not plot then return 0 end
	
	local totalCollected = 0
	
	for _, conveyor in ipairs(plot.conveyors) do
		if conveyor.carId then
			local collected = PlotManager:CollectIncome(playerId, conveyor.id)
			totalCollected = totalCollected + collected
		end
	end
	
	return totalCollected
end

-- ========== UPDATE OFFLINE INCOME ON LOGIN ==========
function IncomeGenerator:ProcessOfflineIncome(playerId)
	local plot = PlayerDataManager:GetPlot(playerId)
	if not plot then return false end
	
	for _, conveyor in ipairs(plot.conveyors) do
		if conveyor.carId then
			local offlineIncome = PlotManager:CalculateOfflineIncome(playerId, conveyor.id)
			self:AddAccumulatedIncome(playerId, conveyor.id, offlineIncome)
		end
	end
	
	return true
end

return IncomeGenerator