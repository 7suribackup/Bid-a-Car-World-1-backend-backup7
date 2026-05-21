-- ========================================
-- CONFIG.LUA - Global Game Configuration
-- ========================================

local Config = {}

-- ========== PATHS ==========
Config.Paths = {
	CarTemplates = game.ReplicatedStorage:WaitForChild("CarTemplates"),
	Decorations = game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Decorations"),
	NPCs = workspace:WaitForChild("NPCS"),
	Conveyors = workspace:WaitForChild("Conveyor Central"):WaitForChild("Conveyors"),
	Garages = workspace:WaitForChild("Garages"),
	Lockers = workspace:WaitForChild("Lockers"),
	Modules = game.ReplicatedStorage:WaitForChild("Modules"),
}

-- ========== BID TIERS ==========
Config.BidTiers = {
	BEGINNER = {
		Price = 200,
		DecoMin = 4,
		DecoMax = 7,
		LockerChance = 1/10,
		CarRarities = {"common", "rare"},
	},
	ADVANCED = {
		Price = 500,
		DecoMin = 7,
		DecoMax = 13,
		LockerChance = 1/4,
		CarRarities = {"uncommon", "epic"},
	},
	EXPERT = {
		Price = 1200,
		DecoMin = 13,
		DecoMax = 21,
		LockerChance = 1/2,
		CarRarities = {"rare", "legendary"},
		SpecChance = 0.0033, -- 0.33%
	},
	CHOSEN = {
		Price = 2500,
		DecoMin = 21,
		DecoMax = 50,
		LockerChance = 1,
		CarRarities = {"rare", "legendary"},
		SpecChance = 0.10, -- 10%
	},
}

-- ========== GAME SETTINGS ==========
Config.Game = {
	StartingMoney = 700,
	StartingConveyors = 3,
	MaxConveyors = 6,
	AutoSaveInterval = 120, -- 2 minutes
	OfflineIncomeMax = 8 * 60 * 60, -- 8 hours in seconds
	BidTimeoutSeconds = 120,
	PlayerBidWindow = 2,
	BotBidWindow = 1,
}

-- ========== REBIRTHS ==========
Config.Rebirths = {
	{
		Level = 1,
		Cost = 2000,
		Unlocks = {"ExtraConveyor", "LuckBoosts"},
	},
	{
		Level = 2,
		Cost = 5000,
		Unlocks = {"TradeSystem"},
	},
	{
		Level = 3,
		Cost = 10000,
		Unlocks = {"ExtraConveyor", "World2Access"},
	},
}

-- ========== DICE SHOP ==========
Config.DiceShop = {
	Basic = {
		Price = 150,
		NPCRarity = "common",
		BoostMin = 10,
		BoostMax = 30,
		UnlockedAtRebirth = 0,
	},
	Golden = {
		Price = 300,
		NPCRarity = "uncommon",
		BoostMin = 30,
		BoostMax = 50,
		UnlockedAtRebirth = 1,
	},
	Diamond = {
		Price = 1100,
		NPCRarity = "rare",
		BoostMin = 50,
		BoostMax = 80,
		UnlockedAtRebirth = 2,
	},
	NASpec = {
		Price = 2500,
		NPCRarity = "spec",
		BoostMin = 80,
		BoostMax = 120,
		UnlockedAtRebirth = 3,
	},
}

-- ========== LOCKERS ==========
Config.Lockers = {
	Silver = {
		OpenTime = 1 * 60 * 60, -- 1 hour
		DropChance = 0.33,
	},
	Gold = {
		OpenTime = 4 * 60 * 60, -- 4 hours
		DropChance = 0.33,
	},
	Black = {
		OpenTime = 8 * 60 * 60, -- 8 hours
		DropChance = 0.34,
	},
}

-- ========== DECORATION VALUE ==========
Config.DecorationValue = 20

-- ========== BOT BID RANGE ==========
Config.BotBidRange = {
	MinPercent = 0.35, -- 35%
	MaxPercent = 0.65, -- 65%
}

return Config