-- ========================================
-- REBIRTH MANAGER - Progression System
-- ========================================

local RebirthManager = {}
local PlayerDataManager = require(game.ReplicatedStorage.Modules.PlayerDataManager)
local PlotManager = require(game.ReplicatedStorage.Modules.PlotManager)
local Config = require(game.ReplicatedStorage.Modules.Config)

-- ========== CAN REBIRTH ==========
function RebirthManager:CanRebirth(playerId, rebirthLevel)
	local player = PlayerDataManager:GetPlayer(playerId)
	if not player then return false end
	
	local rebirthConfig = Config.Rebirths[rebirthLevel]
	if not rebirthConfig then return false end
	
	local money = PlayerDataManager:GetMoney(playerId)
	return money >= rebirthConfig.Cost
end

-- ========== EXECUTE REBIRTH ==========
function RebirthManager:ExecuteRebirth(playerId, rebirthLevel)
	if not self:CanRebirth(playerId, rebirthLevel) then
		return false
	end
	
	local player = PlayerDataManager:GetPlayer(playerId)
	local rebirthConfig = Config.Rebirths[rebirthLevel]
	
	-- Reset money to 0
	PlayerDataManager:UpdateMoney(playerId, -PlayerDataManager:GetMoney(playerId))
	
	-- Increment rebirth count
	PlayerDataManager:IncrementRebirth(playerId)
	
	-- Unlock features
	for _, feature in ipairs(rebirthConfig.Unlocks) do
		self:UnlockFeature(playerId, feature)
	end
	
	return true
end

-- ========== UNLOCK FEATURE ==========
function RebirthManager:UnlockFeature(playerId, feature)
	if feature == "ExtraConveyor" then
		PlotManager:UnlockConveyor(playerId)
	elseif feature == "TradeSystem" then
		-- Enable trade UI flag
		local player = PlayerDataManager:GetPlayer(playerId)
		if player then
			player.features = player.features or {}
			player.features.tradeUnlocked = true
		end
	elseif feature == "World2Access" then
		local player = PlayerDataManager:GetPlayer(playerId)
		if player then
			player.features = player.features or {}
			player.features.world2Access = true
		end
	end
	
	return true
end

-- ========== GET REBIRTH STATUS ==========
function RebirthManager:GetRebirthStatus(playerId)
	local player = PlayerDataManager:GetPlayer(playerId)
	if not player then return nil end
	
	local currentLevel = player.progression.rebirthCount + 1
	local nextRebirthConfig = Config.Rebirths[currentLevel]
	
	return {
		currentRebirth = player.progression.rebirthCount,
		nextRebirthLevel = currentLevel,
		nextRebirthCost = nextRebirthConfig and nextRebirthConfig.Cost or nil,
		canRebirth = self:CanRebirth(playerId, currentLevel),
		features = player.features or {},
	}
end

-- ========== GET NEXT REBIRTH COST ==========
function RebirthManager:GetNextRebirthCost(playerId)
	local player = PlayerDataManager:GetPlayer(playerId)
	if not player then return nil end
	
	local nextLevel = player.progression.rebirthCount + 1
	local config = Config.Rebirths[nextLevel]
	
	return config and config.Cost or nil
end

return RebirthManager