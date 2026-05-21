-- ========================================
-- NPC BID CONTROLLER - AI Bidding System
-- ========================================

local NPCBidController = {}
local Config = require(game.ReplicatedStorage.Modules.Config)
local BidEngine = require(game.ReplicatedStorage.Modules.BidEngine)

-- ========== CALCULATE GARAGE VALUE ==========
function NPCBidController:CalculateGarageValue(garage)
	local carValue = garage.car and garage.car.estimatedValue or 0
	local decoValue = #garage.decorations * Config.DecorationValue
	local lockerBonus = garage.locker and 500 or 0
	
	return carValue + decoValue + lockerBonus
end

-- ========== DETERMINE BID RANGE ==========
function NPCBidController:DetermineBidRange(garageValue)
	local minBid = garageValue * Config.BotBidRange.MinPercent
	local maxBid = garageValue * Config.BotBidRange.MaxPercent
	local randomStopPoint = math.random(minBid, maxBid)
	
	return minBid, maxBid, randomStopPoint
end

-- ========== GENERATE NEXT BOT BID ==========
function NPCBidController:GenerateNextBid(currentBid, maxBid, stopPoint)
	if currentBid >= stopPoint then
		return nil -- Bot stops
	end
	
	local bidIncrement = math.random(5, 20)
	local nextBid = currentBid + bidIncrement
	
	if nextBid > maxBid then
		nextBid = maxBid
	end
	
	return nextBid
end

-- ========== SHOULD CONTINUE BIDDING ==========
function NPCBidController:ShouldContinueBidding(currentBid, stopPoint)
	return currentBid < stopPoint
end

-- ========== START BOT BIDDING ==========
function NPCBidController:StartBotBidding(bidSessionId, numBots)
	local session = BidEngine:GetBidSession(bidSessionId)
	if not session then return false end
	
	local garageValue = self:CalculateGarageValue(session.garage)
	local minBid, maxBid, stopPoint = self:DetermineBidRange(garageValue)
	
	-- Simulate bot bidding
	local currentBid = 0
	
	while self:ShouldContinueBidding(currentBid, stopPoint) do
		wait(Config.Game.BotBidWindow)
		
		local nextBid = self:GenerateNextBid(currentBid, maxBid, stopPoint)
		if not nextBid then break end
		
		local success = BidEngine:PlaceBid(bidSessionId, "BOT_" .. math.random(1, numBots), nextBid)
		if success then
			currentBid = nextBid
		end
	end
	
	return true
end

return NPCBidController