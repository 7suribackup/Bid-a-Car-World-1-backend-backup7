-- ========================================
-- TRADE MANAGER - Player Trading System
-- ========================================

local TradeManager = {}
local PlayerDataManager = require(game.ReplicatedStorage.Modules.PlayerDataManager)

local activeTrades = {}

-- ========== INITIATE TRADE ==========
function TradeManager:InitiateTrade(playerAId, playerBId)
	local tradeId = playerAId .. "_" .. playerBId .. "_" .. os.time()
	
	activeT rades[tradeId] = {
		id = tradeId,
		playerA = playerAId,
		playerB = playerBId,
		playerAOffer = {},
		playerBOffer = {},
		playerAAccepted = false,
		playerBAccepted = false,
		createdAt = os.time(),
	}
	
	return tradeId
end

-- ========== ADD TO TRADE ==========
function TradeManager:AddToTrade(playerId, tradeId, itemType, itemId)
	local trade = activeTrades[tradeId]
	if not trade then return false end
	
	local isPlayerA = playerId == trade.playerA
	local offerTable = isPlayerA and trade.playerAOffer or trade.playerBOffer
	
	table.insert(offerTable, { type = itemType, id = itemId })
	
	return true
end

-- ========== REMOVE FROM TRADE ==========
function TradeManager:RemoveFromTrade(playerId, tradeId, itemType, itemId)
	local trade = activeTrades[tradeId]
	if not trade then return false end
	
	local isPlayerA = playerId == trade.playerA
	local offerTable = isPlayerA and trade.playerAOffer or trade.playerBOffer
	
	for i, item in ipairs(offerTable) do
		if item.type == itemType and item.id == itemId then
			table.remove(offerTable, i)
			return true
		end
	end
	
	return false
end

-- ========== ACCEPT TRADE ==========
function TradeManager:AcceptTrade(playerId, tradeId)
	local trade = activeTrades[tradeId]
	if not trade then return false end
	
	if playerId == trade.playerA then
		trade.playerAAccepted = true
	elseif playerId == trade.playerB then
		trade.playerBAccepted = true
	else
		return false
	end
	
	-- If both accepted, complete trade
	if trade.playerAAccepted and trade.playerBAccepted then
		return self:CompleteTrade(tradeId)
	end
	
	return true
end

-- ========== DECLINE TRADE ==========
function TradeManager:DeclineTrade(playerId, tradeId)
	local trade = activeTrades[tradeId]
	if not trade then return false end
	
	activeT rades[tradeId] = nil
	return true
end

-- ========== COMPLETE TRADE ==========
function TradeManager:CompleteTrade(tradeId)
	local trade = activeTrades[tradeId]
	if not trade then return false end
	
	-- Swap items
	for _, item in ipairs(trade.playerAOffer) do
		PlayerDataManager:RemoveFromInventory(trade.playerA, item.type, item.id)
		PlayerDataManager:AddToInventory(trade.playerB, item.type, { id = item.id })
	end
	
	for _, item in ipairs(trade.playerBOffer) do
		PlayerDataManager:RemoveFromInventory(trade.playerB, item.type, item.id)
		PlayerDataManager:AddToInventory(trade.playerA, item.type, { id = item.id })
	end
	
	activeT rades[tradeId] = nil
	return true
end

-- ========== GET TRADE ==========
function TradeManager:GetTrade(tradeId)
	return activeTrades[tradeId]
end

-- ========== GET PENDING TRADES ==========
function TradeManager:GetPendingTrades(playerId)
	local pending = {}
	
	for _, trade in pairs(activeTrades) do
		if (trade.playerA == playerId or trade.playerB == playerId) and
		   not (trade.playerAAccepted and trade.playerBAccepted) then
			table.insert(pending, trade)
		end
	end
	
	return pending
end

return TradeManager