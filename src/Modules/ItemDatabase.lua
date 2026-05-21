-- ========================================
-- ITEM DATABASE - All Item Definitions
-- ========================================

local ItemDatabase = {}

-- ========== CAR DEFINITIONS ==========
ItemDatabase.Cars = {
	Common = {
		x1 = { name = "X1", rarity = "common", income = 50 },
		x2 = { name = "X2", rarity = "common", income = 60 },
		x3 = { name = "X3", rarity = "common", income = 70 },
		x4 = { name = "X4", rarity = "common", income = 80 },
	},
	Uncommon = {
		x5 = { name = "X5", rarity = "uncommon", income = 100 },
		x6 = { name = "X6", rarity = "uncommon", income = 120 },
		x7 = { name = "X7", rarity = "uncommon", income = 140 },
		x8 = { name = "X8", rarity = "uncommon", income = 160 },
	},
	Rare = {
		-- Add rare cars here
	},
	Epic = {
		-- Add epic cars here
	},
	Legendary = {
		-- Add legendary cars here
	},
	SPEC = {
		-- Add spec cars here
	},
}

-- ========== DECORATION DEFINITIONS ==========
ItemDatabase.Decorations = {
	-- All decorations have same value
	base_value = 20,
	rarity = "common",
	-- Individual decoration names will be loaded from workspace/Assets/Decorations
}

-- ========== POTION DEFINITIONS ==========
ItemDatabase.Potions = {
	Silver = {
		name = "Luck Boost (Silver)",
		duration = 1 * 60 * 60, -- 1 hour
		type = "silver",
	},
	Gold = {
		name = "Luck Boost (Gold)",
		duration = 4 * 60 * 60, -- 4 hours
		type = "gold",
	},
	Black = {
		name = "Luck Boost (Black)",
		duration = 8 * 60 * 60, -- 8 hours
		type = "black",
	},
}

-- ========== DICE DEFINITIONS ==========
ItemDatabase.Dice = {
	Basic = {
		name = "Basic Dice",
		type = "basic",
		price = 150,
	},
	Golden = {
		name = "Golden Dice",
		type = "golden",
		price = 300,
	},
	Diamond = {
		name = "Diamond Dice",
		type = "diamond",
		price = 1100,
	},
	NASpec = {
		name = "NA-SPEC Dice",
		type = "na-spec",
		price = 2500,
	},
}

-- ========== LOCKER DEFINITIONS ==========
ItemDatabase.Lockers = {
	Silver = {
		name = "Silver Locker",
		rarity = "silver",
		openTime = 1 * 60 * 60,
	},
	Gold = {
		name = "Gold Locker",
		rarity = "gold",
		openTime = 4 * 60 * 60,
	},
	Black = {
		name = "Black Locker",
		rarity = "black",
		openTime = 8 * 60 * 60,
	},
}

-- ========== LOCKER CONTENTS ==========
ItemDatabase.LockerContents = {
	Silver = {
		-- 0-1 Silver Potion
		-- 0-1 Basic Dice
	},
	Gold = {
		-- 0-1 Gold Potion
		-- 0-1 Golden Dice OR 1-2 Basic Dice
	},
	Black = {
		-- 1-2 Black Potions
		-- 0-1 Diamond Dice OR 0-1 Golden Dice + 1-2 Basic Dice
	},
}

-- ========== NPC DEFINITIONS ==========
ItemDatabase.NPCs = {
	-- NPCs are generated from Dice via DiceRNG
	-- Structure: { id, name, type, boostPercent, rarity, createdAt }
}

-- ========== GET CAR BY NAME ==========
function ItemDatabase:GetCarByName(carName)
	for rarity, cars in pairs(self.Cars) do
		for modelName, carData in pairs(cars) do
			if modelName == carName then
				return carData, rarity
			end
		end
	end
	
	return nil
end

-- ========== GET CARS BY RARITY ==========
function ItemDatabase:GetCarsByRarity(rarity)
	return self.Cars[rarity] or {}
end

-- ========== GET POTION BY TYPE ==========
function ItemDatabase:GetPotionByType(potionType)
	return self.Potions[potionType] or nil
end

-- ========== GET DICE BY TYPE ==========
function ItemDatabase:GetDiceByType(diceType)
	return self.Dice[diceType] or nil
end

-- ========== GET LOCKER BY RARITY ==========
function ItemDatabase:GetLockerByRarity(lockerRarity)
	return self.Lockers[lockerRarity] or nil
end

return ItemDatabase