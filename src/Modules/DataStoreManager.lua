-- ========================================
-- DATASTORE MANAGER - Save/Load System
-- ========================================

local DataStoreService = game:GetService("DataStoreService")
local playerDS = DataStoreService:GetDataStore("PlayerData_v1")
local Config = require(game.ReplicatedStorage.Modules.Config)

local DataStoreManager = {}
local autosaveConnections = {}

-- ========== PLAYER DATA TEMPLATE ==========
local function CreateNewPlayerData(playerId)
	return {
		playerId = playerId,
		timestamp = os.time(),
		gameVersion = "1.0.0",
		
		account = {
			username = "",
			joinDate = os.time(),
			lastLogin = os.time(),
			totalPlaytime = 0,
		},
		
		wallet = {
			money = Config.Game.StartingMoney,
			lastUpdated = os.time(),
		},
		
		progression = {
			rebirthCount = 0,
			rebirthTimestamps = {},
			currentWorld = 1,
			tutorialCompleted = false,
		},
		
		inventory = {
			items = {},
			cars = {},
			lockers = {},
		},
		
		plot = {
			totalConveyors = Config.Game.StartingConveyors,
			unlockedCount = Config.Game.StartingConveyors,
			conveyors = {},
		},
		
		luckBoosts = {
			active = {},
			expired = {},
		},
		
		stats = {
			totalBidsParticipated = 0,
			totalBidsWon = 0,
			totalBidsLost = 0,
			totalMoneySpent = 0,
			totalMoneyEarned = 0,
			totalIncomeCollected = 0,
			longestWinStreak = 0,
		},
	}
end

-- ========== INITIALIZE CONVEYORS ==========
local function InitializeConveyors(playerData)
	for i = 1, playerData.plot.unlockedCount do
		table.insert(playerData.plot.conveyors, {
			id = "conveyor_" .. i,
			carId = nil,
			npcId = nil,
			incomeAccumulated = 0,
			lastCollected = os.time(),
		})
	 end
end

-- ========== SAVE FUNCTION ==========
function DataStoreManager:Save(playerId, playerData)
	local success, err = pcall(function()
		playerData.timestamp = os.time()
		playerDS:SetAsync("Player_" .. playerId, playerData)
	end)
	
	if not success then
		warn("[DataStore] Error saving player " .. playerId .. ": " .. tostring(err))
		return false
	end
	
	return true
end

-- ========== LOAD FUNCTION ==========
function DataStoreManager:Load(playerId)
	local success, playerData = pcall(function()
		return playerDS:GetAsync("Player_" .. playerId)
	end)
	
	if not success then
		warn("[DataStore] Error loading player " .. playerId)
		return CreateNewPlayerData(playerId)
	end
	
	if playerData == nil then
		return CreateNewPlayerData(playerId)
	end
	
	return playerData
end

-- ========== START AUTOSAVE ==========
function DataStoreManager:StartAutosave(playerId, getPlayerDataFunc)
	if autosaveConnections[playerId] then
		autosaveConnections[playerId]:Disconnect()
	end
	
	local autosaveConnection
	autosaveConnection = game:GetService("RunService").Heartbeat:Connect(function()
		local playerData = getPlayerDataFunc()
		if playerData then
			self:Save(playerId, playerData)
		end
	end)
	
	autosaveConnections[playerId] = autosaveConnection
end

-- ========== STOP AUTOSAVE ==========
function DataStoreManager:StopAutosave(playerId)
	if autosaveConnections[playerId] then
		autosaveConnections[playerId]:Disconnect()
		autosaveConnections[playerId] = nil
	end
end

-- ========== CREATE NEW PLAYER ==========
function DataStoreManager:CreateNewPlayer(playerId, username)
	local playerData = CreateNewPlayerData(playerId)
	playerData.account.username = username
	InitializeConveyors(playerData)
	return playerData
end

return DataStoreManager