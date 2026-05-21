-- ========================================
-- SHOP MANAGER - Dice Shop System
-- ========================================

local ShopManager = {}
local PlayerDataManager = require(game.ReplicatedStorage.Modules.PlayerDataManager)
local ItemDatabase = require(game.ReplicatedStorage.Modules.ItemDatabase)
local Config = require(game.ReplicatedStorage.Modules.Config)

-- ========== GET SHOP INVENTORY ==========
function ShopManager:GetShopInventory(playerId)
	local player = PlayerDataManager:GetPlayer(playerId)
	if not player then return {} end
	
	local rebirthCount = player.progression.rebirthCount
	local availableDice = {}
	
	-- Check unlock levels
	if rebirthCount >= 0 then
		availableDice.Basic = Config.DiceShop.Basic
	end
	
	if rebirthCount >= 1 then
		availableDice.Golden = Config.DiceShop.Golden
	end
	
	if rebirthCount >= 2 then
		availableDice.Diamond = Config.DiceShop.Diamond
	end
	
	if rebirthCount >= 3 then
		availableDice.NASpec = Config.DiceShop.NASpec
	end
	
	return availableDice
end

-- ========== BUY DICE ==========
function ShopManager:BuyDice(playerId, diceType)
	local diceConfig = Config.DiceShop[diceType]
	if not diceConfig then return false end
	
	local money = PlayerDataManager:GetMoney(playerId)
	if money < diceConfig.Price then
		return false
	end
	
	-- Deduct money
	PlayerDataManager:UpdateMoney(playerId, -diceConfig.Price)
	
	-- Add dice to inventory
	local dice = {
		id = "dice_" .. diceType .. "_" .. os.time(),
		type = "dice",
		diceType = diceType,
		unopenedLocked = true,
		acquiredAt = os.time(),
	}
	
	PlayerDataManager:AddToInventory(playerId, "item", dice)
	
	return true
end

-- ========== CAN AFFORD DICE ==========
function ShopManager:CanAffordDice(playerId, diceType)
	local diceConfig = Config.DiceShop[diceType]
	if not diceConfig then return false end
	
	local money = PlayerDataManager:GetMoney(playerId)
	return money >= diceConfig.Price
end

-- ========== GET DICE PRICE ==========
function ShopManager:GetDicePrice(diceType)
	local config = Config.DiceShop[diceType]
	return config and config.Price or nil
end

return ShopManager