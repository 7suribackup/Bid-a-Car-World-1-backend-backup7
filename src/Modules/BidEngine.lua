-- ========================================
-- BID ENGINE - Bid Battle System
-- ========================================

local BidEngine = {}
local activeBids = {}
local Config = require(game.ReplicatedStorage.Modules.Config)
local PlayerDataManager = require(game.ReplicatedStorage.Modules.PlayerDataManager)

local BidStates = {
	WAITING = "WAITING",
	BIDDING = "BIDDING",
	SETTLING = "SETTLING",
	COMPLETED = "COMPLETED",
}

-- ========== CREATE NEW BID SESSION ==========
function BidEngine:CreateBidSession(playerId, tierType, garage)
	local tierConfig = Config.BidTiers[tierType]
	if not tierConfig then return nil end
	
	local bidSession = {
		id = playerId .. "_" .. os.time(),
		playerId = playerId,
		tierType = tierType,
		tierPrice = tierConfig.Price,
		garage = garage,
		
		bids = {},
		currentHighestBid = 0,
		currentHighestBidder = nil,
		
		state = BidStates.WAITING,
		startTime = os.time(),
		totalSpent = tierConfig.Price,
		hasPlayerBid = false,
	}
	
	activeBids[bidSession.id] = bidSession
	return bidSession
end

-- ========== PLACE BID ==========
function BidEngine:PlaceBid(bidSessionId, bidderId, bidAmount)
	local session = activeBids[bidSessionId]
	if not session then return false end
	
	-- Validate bid amount
	if bidAmount <= session.currentHighestBid then
		return false
	end
	
	-- Check if player has enough money
	local playerMoney = PlayerDataManager:GetMoney(bidderId)
	if playerMoney < bidAmount then
		return false
	end
	
	-- Record bid
	table.insert(session.bids, {
		bidderId = bidderId,
		amount = bidAmount,
		timestamp = os.time(),
	})
	
	session.currentHighestBid = bidAmount
	session.currentHighestBidder = bidderId
	
	if bidderId == session.playerId then
		session.hasPlayerBid = true
	end
	
	return true
end

-- ========== GET TOTAL BID COST ==========
function BidEngine:CalculateTotalCost(bidSessionId)
	local session = activeBids[bidSessionId]
	if not session then return 0 end
	
	local totalCost = session.tierPrice
	
	for _, bid in ipairs(session.bids) do
		-- Each bid increment is the difference
		if _ == 1 then
			totalCost = totalCost + bid.amount
		else
			local prevBid = session.bids[_ - 1].amount
			totalCost = totalCost + (bid.amount - prevBid)
		end
	end
	
	return totalCost
end

-- ========== SETTLE WIN ==========
function BidEngine:SettleWin(bidSessionId, playerId)
	local session = activeBids[bidSessionId]
	if not session or session.currentHighestBidder ~= playerId then
		return false
	end
	
	local totalCost = self:CalculateTotalCost(bidSessionId)
	
	-- Deduct money
	PlayerDataManager:UpdateMoney(playerId, -totalCost)
	
	-- Update stats
	PlayerDataManager:UpdateStats(playerId, "totalBidsWon", 1)
	PlayerDataManager:UpdateStats(playerId, "totalMoneySpent", totalCost)
	
	session.state = BidStates.COMPLETED
	return true
end

-- ========== SETTLE LOSS ==========
function BidEngine:SettleLoss(bidSessionId, playerId)
	local session = activeBids[bidSessionId]
	if not session then return false end
	
	-- If player bid, lose all money
	if session.hasPlayerBid and playerId == session.playerId then
		local totalCost = self:CalculateTotalCost(bidSessionId)
		PlayerDataManager:UpdateMoney(playerId, -totalCost)
		PlayerDataManager:UpdateStats(playerId, "totalBidsLost", 1)
		PlayerDataManager:UpdateStats(playerId, "totalMoneySpent", totalCost)
	elseif not session.hasPlayerBid and playerId == session.playerId then
		-- Refund entry fee
		PlayerDataManager:UpdateMoney(playerId, session.tierPrice)
	end
	
	session.state = BidStates.COMPLETED
	return true
end

-- ========== GET BID SESSION ==========
function BidEngine:GetBidSession(bidSessionId)
	return activeBids[bidSessionId]
end

-- ========== CLEANUP BID ==========
function BidEngine:CleanupBid(bidSessionId)
	activeB ids[bidSessionId] = nil
end

return BidEngine