-- ========================================
-- INVENTORY MANAGER - Item Management
-- ========================================

local InventoryManager = {}
local PlayerDataManager = require(game.ReplicatedStorage.Modules.PlayerDataManager)

-- ========== GET INVENTORY ==========
function InventoryManager:GetInventory(playerId)
	local player = PlayerDataManager:GetPlayer(playerId)
	return player and player.inventory or nil
end

-- ========== ADD ITEM ==========
function InventoryManager:AddItem(playerId, itemType, item)
	local inventory = self:GetInventory(playerId)
	if not inventory then return false end
	
	if itemType == "items" then
		table.insert(inventory.items, item)
	elseif itemType == "cars" then
		table.insert(inventory.cars, item)
	elseif itemType == "lockers" then
		table.insert(inventory.lockers, item)
	else
		return false
	end
	
	return true
end

-- ========== REMOVE ITEM ==========
function InventoryManager:RemoveItem(playerId, itemType, itemId)
	return PlayerDataManager:RemoveFromInventory(playerId, itemType, itemId)
end

-- ========== GET ITEMS ==========
function InventoryManager:GetItems(playerId, category)
	local inventory = self:GetInventory(playerId)
	if not inventory then return {} end
	
	if category == "decorations" then
		local decos = {}
		for _, item in ipairs(inventory.items) do
			if item.type == "decoration" then
				table.insert(decos, item)
			end
		end
		return decos
		
	elseif category == "potions" then
		local potions = {}
		for _, item in ipairs(inventory.items) do
			if item.type == "potion" then
				table.insert(potions, item)
			end
		end
		return potions
		
	elseif category == "dice" then
		local dice = {}
		for _, item in ipairs(inventory.items) do
			if item.type == "dice" then
				table.insert(dice, item)
			end
		end
		return dice
	else
		return inventory.items
	end
end

-- ========== GET CARS ==========
function InventoryManager:GetCars(playerId, ownedOnly)
	return PlayerDataManager:GetCars(playerId, ownedOnly)
end

-- ========== GET LOCKERS ==========
function InventoryManager:GetLockers(playerId)
	return PlayerDataManager:GetLockers(playerId)
end

-- ========== OPEN LOCKER ==========
function InventoryManager:OpenLocker(playerId, lockerId)
	local lockers = self:GetLockers(playerId)
	
	for _, locker in ipairs(lockers) do
		if locker.id == lockerId and locker.unopenedLocked then
			locker.unopenedLocked = false
			locker.openedAt = os.time()
			return true
		end
	end
	
	return false
end

-- ========== USE POTION ==========
function InventoryManager:UsePotion(playerId, potionId)
	local potions = self:GetItems(playerId, "potions")
	
	for i, potion in ipairs(potions) do
		if potion.id == potionId then
			local player = PlayerDataManager:GetPlayer(playerId)
			if player then
				table.insert(player.luckBoosts.active, {
					id = potion.id,
					type = potion.rarity,
					expiresAt = os.time() + potion.duration,
				})
			end
			self:RemoveItem(playerId, "items", potionId)
			return true
		end
	end
	
	return false
end

-- ========== LIST ALL ITEMS ==========
function InventoryManager:ListAllItems(playerId)
	local inventory = self:GetInventory(playerId)
	if not inventory then return nil end
	
	return {
		items = inventory.items,
		cars = inventory.cars,
		lockers = inventory.lockers,
	}
end

-- ========== GET INVENTORY COUNTS ==========
function InventoryManager:GetInventoryCounts(playerId)
	local inventory = self:GetInventory(playerId)
	if not inventory then return nil end
	
	return {
		items = #inventory.items,
		cars = #inventory.cars,
		lockers = #inventory.lockers,
	}
end

return InventoryManager