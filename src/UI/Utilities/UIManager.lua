-- ========================================
-- UI MANAGER - Central UI Orchestrator
-- Manages all UI screens and transitions
-- ========================================

local UIManager = {}
local Theme = require(game.ReplicatedStorage.Modules.UI.Theme)
local AnimationController = require(game.ReplicatedStorage.Modules.UI.Utilities.AnimationController)
local NotificationSystem = require(game.ReplicatedStorage.Modules.UI.Utilities.NotificationSystem)

-- UI Screens
local MainLobbyUI = require(game.ReplicatedStorage.Modules.UI.Screens.MainLobbyUI)
local TierSelectionScreen = require(game.ReplicatedStorage.Modules.UI.Screens.TierSelectionScreen)
local BidBattleScreen = require(game.ReplicatedStorage.Modules.UI.Screens.BidBattleScreen)
local InventoryScreen = require(game.ReplicatedStorage.Modules.UI.Screens.InventoryScreen)
local ShopUI = require(game.ReplicatedStorage.Modules.UI.Screens.ShopUI)
local RebirthUI = require(game.ReplicatedStorage.Modules.UI.Screens.RebirthUI)

-- Managers
local PlayerDataManager = require(game.ReplicatedStorage.Modules.PlayerDataManager)
local BidEngine = require(game.ReplicatedStorage.Modules.BidEngine)
local ShopManager = require(game.ReplicatedStorage.Modules.ShopManager)
local RebirthManager = require(game.ReplicatedStorage.Modules.RebirthManager)

-- State
local activeScreens = {}
local playerId = game.Players.LocalPlayer.UserId

-- ========== SCREEN MANAGEMENT ==========

function UIManager:ShowMainLobby()
	self:HideAllScreens()
	
	local screenGui = MainLobbyUI:Create(function(data)
		-- When buttons are clicked
		print("[UIManager] Main Lobby action: " .. tostring(data))
	end)
	
	table.insert(activeScreens, {name = "MainLobby", gui = screenGui})
	return screenGui
end

function UIManager:ShowTierSelection()
	self:HideAllScreens()
	
	local screenGui = TierSelectionScreen:Create(
		function(tierName)
			-- On tier selected
			NotificationSystem:ShowInfo("Selected " .. tierName .. " tier!")
			self:ShowBidBattle(tierName)
		end,
		function()
			-- On cancel
			self:ShowMainLobby()
		end
	)
	
	table.insert(activeScreens, {name = "TierSelection", gui = screenGui})
	return screenGui
end

function UIManager:ShowBidBattle(tierName)
	self:HideAllScreens()
	
	-- Dummy bid data - replace with real data from BidEngine
	local bidData = {
		currentBid = 500,
		currentBidder = "Player1",
	}
	
	local screenGui = BidBattleScreen:Create(
		tierName,
		bidData,
		function()
			-- On raise bid
			print("[UIManager] Player raised bid")
			NotificationSystem:ShowBid("You", 600, 1)
		end,
		function()
			-- On pass
			print("[UIManager] Player passed")
			NotificationSystem:ShowWarning("You passed the bid")
		end,
		function()
			-- On complete
			print("[UIManager] Bid completed")
			self:ShowMainLobby()
		end
	)
	
	table.insert(activeScreens, {name = "BidBattle", gui = screenGui})
	return screenGui
end

function UIManager:ShowInventory()
	local playerData = PlayerDataManager:GetPlayer(playerId) or {}
	local screenGui = InventoryScreen:Create(
		function()
			-- On close
			print("[UIManager] Inventory closed")
		end
	)
	
	table.insert(activeScreens, {name = "Inventory", gui = screenGui})
	return screenGui
end

function UIManager:ShowShop()
	local playerMoney = PlayerDataManager:GetMoney(playerId) or 700
	local rebirthLevel = PlayerDataManager:GetRebirthCount(playerId) or 0
	
	local screenGui = ShopUI:Create(
		playerMoney,
		rebirthLevel,
		function(diceId, price)
			-- On buy dice
			print("[UIManager] Bought " .. diceId .. " for $" .. price)
			
			-- Deduct money
			PlayerDataManager:UpdateMoney(playerId, -price)
			
			-- Add dice to inventory
			ShopManager:BuyDice(playerId, diceId)
			
			-- Show notification
			NotificationSystem:ShowSuccess("Bought " .. diceId .. " Dice!")
		end,
		function()
			-- On close
			print("[UIManager] Shop closed")
		end
	)
	
	table.insert(activeScreens, {name = "Shop", gui = screenGui})
	return screenGui
end

function UIManager:ShowRebirth(rebirthLevel)
	local playerMoney = PlayerDataManager:GetMoney(playerId) or 0
	
	local screenGui = RebirthUI:Create(
		rebirthLevel,
		playerMoney,
		function()
			-- On confirm rebirth
			print("[UIManager] Rebirth confirmed")
			RebirthManager:ExecuteRebirth(playerId, rebirthLevel)
			NotificationSystem:ShowSuccess("Rebirth successful! 🎉")
			self:ShowMainLobby()
		end,
		function()
			-- On cancel
			print("[UIManager] Rebirth cancelled")
			self:ShowMainLobby()
		end
	)
	
	table.insert(activeScreens, {name = "Rebirth", gui = screenGui})
	return screenGui
end

-- ========== SCREEN CONTROL ==========

function UIManager:HideAllScreens()
	for _, screen in ipairs(activeScreens) do
		if screen.gui and screen.gui.Parent then
			AnimationController:FadeOut(screen.gui, Theme.Animations.Fast)
			task.wait(Theme.Animations.Fast)
			screen.gui:Destroy()
		end
	end
	activeScreens = {}
end

function UIManager:HideScreen(screenName)
	for i, screen in ipairs(activeScreens) do
		if screen.name == screenName and screen.gui then
			screen.gui:Destroy()
			table.remove(activeScreens, i)
			return true
		end
	end
	return false
end

function UIManager:IsScreenActive(screenName)
	for _, screen in ipairs(activeScreens) do
		if screen.name == screenName then
			return true
		end
	end
	return false
end

-- ========== INITIALIZATION ==========

function UIManager:Initialize()
	print("[UIManager] Initializing UI Manager...")
	
	-- Show main lobby
	self:ShowMainLobby()
	
	-- Connect global events if needed
	local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Listen for inventory toggle (example: press 'I' key)
	local UserInputService = game:GetService("UserInputService")
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == Enum.KeyCode.I then
			if self:IsScreenActive("Inventory") then
				self:HideScreen("Inventory")
			else
				self:ShowInventory()
			end
		elseif input.KeyCode == Enum.KeyCode.M then
			-- Toggle shop
			if self:IsScreenActive("Shop") then
				self:HideScreen("Shop")
			else
				self:ShowShop()
			end
		end
	end)
	
	print("[UIManager] UI Manager initialized!")
end

return UIManager
