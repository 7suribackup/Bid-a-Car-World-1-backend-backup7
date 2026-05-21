-- ========================================
-- RNG GARAGE GENERATOR - Garage Creation
-- ========================================

local RNGGarageGenerator = {}
local Config = require(game.ReplicatedStorage.Modules.Config)
local ItemDatabase = require(game.ReplicatedStorage.Modules.ItemDatabase)

-- ========== GENERATE GARAGE ==========
function RNGGarageGenerator:GenerateGarage(tierType)
	local tierConfig = Config.BidTiers[tierType]
	if not tierConfig then return nil end
	
	local garage = {
		tier = tierType,
		car = self:RollCar(tierType),
		decorationsCount = math.random(tierConfig.DecoMin, tierConfig.DecoMax),
		decorationsItems = {},
		locker = self:RollLocker(tierType),
	}
	
	-- Generate decorations
	for i = 1, garage.decorationsCount do
		table.insert(garage.decorationsItems, {
			id = "deco_" .. i,
			value = Config.DecorationValue,
		})
	end
	
	return garage
end

-- ========== ROLL CAR ==========
function RNGGarageGenerator:RollCar(tierType)
	local tierConfig = Config.BidTiers[tierType]
	local rarity = tierConfig.CarRarities[math.random(1, #tierConfig.CarRarities)]
	
	-- Check for SPEC tier
	if tierConfig.SpecChance and math.random() < tierConfig.SpecChance then
		rarity = "SPEC"
	end
	
	return self:SelectCarModel(rarity)
end

-- ========== SELECT CAR MODEL ==========
function RNGGarageGenerator:SelectCarModel(rarity)
	local cars = ItemDatabase:GetCarsByRarity(rarity)
	if not cars or next(cars) == nil then
		return nil
	end
	
	local carModels = {}
	for modelName, carData in pairs(cars) do
		table.insert(carModels, { name = modelName, data = carData })
	end
	
	local selectedCar = carModels[math.random(1, #carModels)]
	return selectedCar.data
end

-- ========== ROLL LOCKER ==========
function RNGGarageGenerator:RollLocker(tierType)
	local tierConfig = Config.BidTiers[tierType]
	
	if math.random() < tierConfig.LockerChance then
		return self:SelectLockerRarity()
	end
	
	return nil
end

-- ========== SELECT LOCKER RARITY ==========
function RNGGarageGenerator:SelectLockerRarity()
	local rarities = {"Silver", "Gold", "Black"}
	local selectedRarity = rarities[math.random(1, 3)]
	
	return {
		id = "locker_" .. selectedRarity .. "_" .. os.time(),
		rarity = selectedRarity,
		openedAt = 0,
		unopenedLocked = true,
	}
end

-- ========== POPULATE LOCKER CONTENTS ==========
function RNGGarageGenerator:PopulateLockerContents(lockerRarity)
	local contents = {}
	
	if lockerRarity == "Silver" then
		-- 0-1 Silver Potion
		if math.random() < 0.5 then
			table.insert(contents, { type = "potion", rarity = "Silver" })
		end
		-- 0-1 Basic Dice
		if math.random() < 0.5 then
			table.insert(contents, { type = "dice", diceType = "Basic" })
		end
		
	elseif lockerRarity == "Gold" then
		-- 0-1 Gold Potion
		if math.random() < 0.5 then
			table.insert(contents, { type = "potion", rarity = "Gold" })
		end
		-- 0-1 Golden Dice OR 1-2 Basic Dice
		if math.random() < 0.5 then
			table.insert(contents, { type = "dice", diceType = "Golden" })
		else
			local basicDiceCount = math.random(1, 2)
			for i = 1, basicDiceCount do
				table.insert(contents, { type = "dice", diceType = "Basic" })
			end
		end
		
	elseif lockerRarity == "Black" then
		-- 1-2 Black Potions
		local potionCount = math.random(1, 2)
		for i = 1, potionCount do
			table.insert(contents, { type = "potion", rarity = "Black" })
		end
		-- 0-1 Diamond Dice OR (0-1 Golden Dice + 1-2 Basic Dice)
		if math.random() < 0.5 then
			table.insert(contents, { type = "dice", diceType = "Diamond" })
		else
			if math.random() < 0.5 then
				table.insert(contents, { type = "dice", diceType = "Golden" })
			end
			local basicDiceCount = math.random(1, 2)
			for i = 1, basicDiceCount do
				table.insert(contents, { type = "dice", diceType = "Basic" })
			end
		end
	end
	
	return contents
end

return RNGGarageGenerator