-- ========================================
-- PLAYER DATA MANAGER - In-Memory State
-- ========================================

local PlayerDataManager = {}
local playersData = {}

-- ========== GET PLAYER DATA ==========
function PlayerDataManager:GetPlayer(playerId)
	return playersData[playerId]
end

-- ========== SET PLAYER DATA ==========
function PlayerDataManager:SetPlayer(playerId, playerData)
	playersData[playerId] = playerData
end

-- ========== UPDATE MONEY ==========
function PlayerDataManager:UpdateMoney(playerId, amount)
	local player = self:GetPlayer(playerId)
	if not player then return false end
	
	local newMoney = player.wallet.money + amount
	if newMoney < 0 then return false end
	
	player.wallet.money = newMoney
	player.wallet.lastUpdated = os.time()
	return true
end

-- ========== GET MONEY ==========
function PlayerDataManager:GetMoney(playerId)
	local player = self:GetPlayer(playerId)
	return player and player.wallet.money or 0
end

-- ========== ADD TO INVENTORY ==========
function PlayerDataManager:AddToInventory(playerId, itemType, item)
	local player = self:GetPlayer(playerId)
	if not player then return false end
	
	if itemType == "item" then
		table.insert(player.inventory.items, item)
	elseif itemType == "car" then
		table.insert(player.inventory.cars, item)
	elseif itemType == "locker" then
		table.insert(player.inventory.lockers, item)
	else
		return false
	end
	
	return true
end

-- ========== REMOVE FROM INVENTORY ==========
function PlayerDataManager:RemoveFromInventory(playerId, itemType, itemId)
	local player = self:GetPlayer(playerId)
	if not player then return false end
	
	local inventory = player.inventory[itemType .. "s"] or player.inventory[itemType]
	if not inventory then return false end
	
	for i, item in ipairs(inventory) do
		if item.id == itemId then
			table.remove(inventory, i)
			return true
		end
	end
	
	return false
end

-- ========== GET INVENTORY ITEMS ==========
function PlayerDataManager:GetInventoryItems(playerId, itemType)
	local player = self:GetPlayer(playerId)
	if not player then return {} end
	
	local key = itemType .. "s"
	return player.inventory[key] or {}
end

-- ========== GET CARS ==========
function PlayerDataManager:GetCars(playerId, ownedOnly)
	local player = self:GetPlayer(playerId)
	if not player then return {} end
	
	if ownedOnly then
		local ownedCars = {}
		for _, car in ipairs(player.inventory.cars) do
			if car.owned then
				table.insert(ownedCars, car)
			end
		end
		return ownedCars
	end
	
	return player.inventory.cars
end

-- ========== GET LOCKERS ==========
function PlayerDataManager:GetLockers(playerId)
	local player = self:GetPlayer(playerId)
	return player and player.inventory.lockers or {}
end

-- ========== UPDATE STATS ==========
function PlayerDataManager:UpdateStats(playerId, statName, value)
	local player = self:GetPlayer(playerId)
	if not player then return false end
	
	if player.stats[statName] then
		player.stats[statName] = player.stats[statName] + value
		return true
	end
	
	return false
end

-- ========== GET REBIRTH COUNT ==========
function PlayerDataManager:GetRebirthCount(playerId)
	local player = self:GetPlayer(playerId)
	return player and player.progression.rebirthCount or 0
end

-- ========== INCREMENT REBIRTH ==========
function PlayerDataManager:IncrementRebirth(playerId)
	local player = self:GetPlayer(playerId)
	if not player then return false end
	
	player.progression.rebirthCount = player.progression.rebirthCount + 1
	table.insert(player.progression.rebirthTimestamps, os.time())
	return true
end

-- ========== GET PLOT ==========
function PlayerDataManager:GetPlot(playerId)
	local player = self:GetPlayer(playerId)
	return player and player.plot or nil
end

-- ========== GET CONVEYOR ==========
function PlayerDataManager:GetConveyor(playerId, conveyorId)
	local plot = self:GetPlot(playerId)
	if not plot then return nil end
	
	for _, conveyor in ipairs(plot.conveyors) do
		if conveyor.id == conveyorId then
			return conveyor
		end
	end
	
	return nil
end

-- ========== SET CONVEYOR CAR ==========
function PlayerDataManager:SetConveyorCar(playerId, conveyorId, carId)
	local conveyor = self:GetConveyor(playerId, conveyorId)
	if not conveyor then return false end
	
	conveyor.carId = carId
	return true
end

-- ========== SET CONVEYOR NPC ==========
function PlayerDataManager:SetConveyorNPC(playerId, conveyorId, npcId)
	local conveyor = self:GetConveyor(playerId, conveyorId)
	if not conveyor then return false end
	
	conveyor.npcId = npcId
	return true
end

-- ========== GET ALL PLAYERS ==========
function PlayerDataManager:GetAllPlayers()
	return playersData
end

return PlayerDataManager