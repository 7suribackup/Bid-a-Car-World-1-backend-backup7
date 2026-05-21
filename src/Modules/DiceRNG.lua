-- ========================================
-- DICE RNG - NPC Generation System
-- ========================================

local DiceRNG = {}
local Config = require(game.ReplicatedStorage.Modules.Config)

-- ========== GENERATE UUID ==========
local function GenerateUUID()
	return game:GetService("HttpService"):GenerateGUID(false)
end

-- ========== ROLL NPC FROM DICE ==========
function DiceRNG:RollNPC(diceType)
	local diceConfig = Config.DiceShop[diceType]
	if not diceConfig then return nil end
	
	local boostPercent = math.random(diceConfig.BoostMin, diceConfig.BoostMax)
	
	return {
		id = "npc_" .. diceType .. "_" .. GenerateUUID(),
		name = "NPC_" .. math.random(1000, 9999),
		type = diceType,
		boostPercent = boostPercent,
		rarity = diceConfig.NPCRarity,
		createdAt = os.time(),
	}
end

-- ========== GET NPC STATS ==========
function DiceRNG:GetNPCStats(npcData)
	if not npcData then return nil end
	
	return {
		id = npcData.id,
		name = npcData.name,
		type = npcData.type,
		boostPercent = npcData.boostPercent,
		rarity = npcData.rarity,
	}
end

-- ========== GENERATE BOOST PERCENT ==========
function DiceRNG:GenerateBoostPercent(diceType)
	local config = Config.DiceShop[diceType]
	if not config then return 0 end
	
	return math.random(config.BoostMin, config.BoostMax)
end

return DiceRNG