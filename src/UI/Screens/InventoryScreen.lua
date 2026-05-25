-- ========================================
-- INVENTORY SCREEN - Complete Inventory UI
-- Modern Bid Battles Theme
-- ========================================

local InventoryScreen = {}
local Theme = require(game.ReplicatedStorage.Modules.UI.Theme)
local UIHelper = require(game.ReplicatedStorage.Modules.UI.Utilities.UIHelper)
local AnimationController = require(game.ReplicatedStorage.Modules.UI.Utilities.AnimationController)
local ButtonFactory = require(game.ReplicatedStorage.Modules.UI.Utilities.ButtonFactory)
local PlayerDataManager = require(game.ReplicatedStorage.Modules.PlayerDataManager)

-- ========== CREATE INVENTORY SCREEN ==========
function InventoryScreen:Create(onClose)
	local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	local playerId = game.Players.LocalPlayer.UserId
	
	-- Screen GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "InventoryScreen"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndex = 50
	screenGui.Parent = playerGui
	
	-- Background overlay
	local overlay = Instance.new("Frame")
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.4
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.Parent = screenGui
	overlay.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
			AnimationController:FadeOut(mainContainer, Theme.Animations.Normal)
			wait(Theme.Animations.Normal)
			screenGui:Destroy()
			if onClose then onClose() end
		end
	end)
	
	-- Main container
	local mainContainer = UIHelper:CreateRoundedFrame(screenGui, {
		BackgroundColor3 = Theme.Colors.Background,
		BackgroundTransparency = 0,
		Size = UDim2.new(0.95, 0, 0.9, 0),
		Position = UDim2.new(0.025, 0, 0.05, 0),
		CornerRadius = UDim.new(0, 20),
	})
	UIHelper:AddStroke(mainContainer, Theme.Colors.Primary, 2, 0.3)
	AnimationController:CreateGradient(mainContainer, Theme.Gradients.CyanToPurple)
	
	-- ===== HEADER =====
	local header = UIHelper:CreateRoundedFrame(mainContainer, {
		BackgroundColor3 = Theme.Colors.BackgroundSecondary,
		BackgroundTransparency = 0.2,
		Size = UDim2.new(1, 0, 0, 80),
		Position = UDim2.new(0, 0, 0, 0),
	})
	UIHelper:AddStroke(header, Theme.Colors.Primary, 1, 0.3)
	
	-- Header title
	local headerTitle = UIHelper:CreateTextLabel(header, {
		Text = "📦 INVENTORY",
		TextColor3 = Theme.Colors.Primary,
		Font = Theme.Fonts.Heading.Font,
		TextSize = 28,
		Size = UDim2.new(0.7, 0, 1, 0),
		Position = UDim2.new(0, 20, 0, 0),
	})
	headerTitle.TextScaled = true
	
	-- Close button
	local closeBtn = ButtonFactory:CreateOutlineButton(header, {
		Text = "✕",
		Size = UDim2.new(0, 50, 0, 50),
		Position = UDim2.new(1, -70, 0.5, -25),
		OnClick = function()
			AnimationController:FadeOut(mainContainer, Theme.Animations.Normal)
			wait(Theme.Animations.Normal)
			screenGui:Destroy()
			if onClose then onClose() end
		end,
	})
	
	-- ===== TAB CONTAINER =====
	local tabContainer = UIHelper:CreateRoundedFrame(mainContainer, {
		BackgroundColor3 = Theme.Colors.BackgroundSecondary,
		BackgroundTransparency = 0.3,
		Size = UDim2.new(1, 0, 0, 60),
		Position = UDim2.new(0, 0, 0, 80),
	})
	
	UIHelper:CreateListLayout(tabContainer, {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 10),
	})
	
	-- Tab definitions
	local tabs = {
		{name = "Items", icon = "⭐", id = "items", color = Theme.Colors.Secondary},
		{name = "Cars", icon = "🚗", id = "cars", color = Theme.Colors.Primary},
		{name = "Lockers", icon = "🔒", id = "lockers", color = Theme.Colors.Accent},
		{name = "Index", icon = "📋", id = "index", color = Theme.Colors.Info},
	}
	
	local tabButtons = {}
	local contentFrames = {}
	
	for idx, tab in ipairs(tabs) do
		local tabBtn = ButtonFactory:CreatePrimaryButton(tabContainer, {
			Text = tab.icon .. " " .. tab.name,
			BackgroundColor3 = tab.color,
			Size = UDim2.new(0, 150, 0, 45),
		})
		tabBtn.Name = tab.id .. "TabBtn"
		tabBtn.LayoutOrder = idx
		tabButtons[tab.id] = {btn = tabBtn, color = tab.color}
		
		-- Tab content frame
		local contentFrame = Instance.new("Frame")
		contentFrame.Name = tab.id .. "Content"
		contentFrame.BackgroundTransparency = 1
		contentFrame.Size = UDim2.new(1, -40, 1, -150)
		contentFrame.Position = UDim2.new(0, 20, 0, 140)
		contentFrame.ClipsDescendants = true
		contentFrame.Visible = (idx == 1)
		contentFrame.Parent = mainContainer
		contentFrames[tab.id] = contentFrame
	end
	
	-- ===== ITEMS TAB CONTENT =====
	local itemsFrame = contentFrames.items
	local itemsScroll = Instance.new("ScrollingFrame")
	itemsScroll.BackgroundTransparency = 1
	itemsScroll.Size = UDim2.new(1, 0, 1, 0)
	itemsScroll.ScrollBarThickness = 8
	itemsScroll.TopImage = ""
	itemsScroll.BottomImage = ""
	itemsScroll.MidImage = ""
	itemsScroll.Parent = itemsFrame
	
	UIHelper:CreateListLayout(itemsScroll, {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 20),
	})
	
	-- Items sections
	local itemSections = {
		{title = "💎 DECORATIONS", key = "decorations", color = Theme.Colors.Secondary},
		{title = "⚗️ POTIONS", key = "potions", color = Theme.Colors.Accent},
		{title = "🎲 DICE", key = "dice", color = Theme.Colors.Success},
	}
	
	for _, section in ipairs(itemSections) do
		local sectionHeader = UIHelper:CreateTextLabel(itemsScroll, {
			Text = section.title,
			TextColor3 = section.color,
			Font = Theme.Fonts.Subheading.Font,
			TextSize = 18,
			Size = UDim2.new(0.95, 0, 0, 35),
		})
		
		local itemGrid = Instance.new("Frame")
		itemGrid.Name = section.key .. "Grid"
		itemGrid.BackgroundTransparency = 1
		itemGrid.Size = UDim2.new(0.95, 0, 0, 140)
		itemGrid.Parent = itemsScroll
		
		local gridLayout = Instance.new("UIGridLayout")
		gridLayout.CellSize = UDim2.new(0, 110, 0, 110)
		gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		gridLayout.FillDirection = Enum.FillDirection.Horizontal
		gridLayout.Padding = UDim.new(0, 12)
		gridLayout.Parent = itemGrid
		
		-- Dummy items (replace with real data later)
		local itemCounts = {decorations = 4, potions = 2, dice = 3}
		local count = itemCounts[section.key] or 0
		
		for i = 1, count do
			local itemCard = UIHelper:CreateRoundedFrame(itemGrid, {
				BackgroundColor3 = Theme.Colors.BackgroundTertiary,
				BackgroundTransparency = 0.1,
				Size = UDim2.new(0, 110, 0, 110),
				CornerRadius = UDim.new(0, 12),
			})
			UIHelper:AddStroke(itemCard, section.color, 1, 0.4)
			
			local itemLabel = UIHelper:CreateTextLabel(itemCard, {
				Text = section.key:sub(1, 1):upper() .. " Item",
				TextColor3 = Theme.Colors.TextSecondary,
				Font = Theme.Fonts.BodySmall.Font,
				TextSize = 12,
				Size = UDim2.new(1, 0, 0.6, 0),
				Position = UDim2.new(0, 0, 0.2, 0),
			})
			itemLabel.TextScaled = true
			
			local quantityLabel = UIHelper:CreateTextLabel(itemCard, {
				Text = "x" .. i,
				TextColor3 = section.color,
				Font = Theme.Fonts.Body.Font,
				TextSize = 14,
				Size = UDim2.new(1, 0, 0.4, 0),
				Position = UDim2.new(0, 0, 0.5, 0),
			})
			quantityLabel.TextScaled = true
		end
	end
	
	-- ===== CARS TAB CONTENT =====
	local carsFrame = contentFrames.cars
	local carsScroll = Instance.new("ScrollingFrame")
	carsScroll.BackgroundTransparency = 1
	carsScroll.Size = UDim2.new(1, 0, 1, 0)
	carsScroll.ScrollBarThickness = 8
	carsScroll.TopImage = ""
	carsScroll.BottomImage = ""
	carsScroll.MidImage = ""
	carsScroll.Parent = carsFrame
	
	UIHelper:CreateListLayout(carsScroll, {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 20),
	})
	
	local rarities = {
		{name = "COMMON", color = Theme.Colors.Common},
		{name = "UNCOMMON", color = Theme.Colors.Uncommon},
		{name = "RARE", color = Theme.Colors.Rare},
		{name = "EPIC", color = Theme.Colors.Epic},
		{name = "LEGENDARY", color = Theme.Colors.Legendary},
		{name = "SPEC", color = Theme.Colors.SPEC},
	}
	
	for _, rarity in ipairs(rarities) do
		local rarityHeader = UIHelper:CreateTextLabel(carsScroll, {
			Text = "⭐ " .. rarity.name .. " CARS",
			TextColor3 = rarity.color,
			Font = Theme.Fonts.Subheading.Font,
			TextSize = 18,
			Size = UDim2.new(0.95, 0, 0, 35),
		})
		
		local carGrid = Instance.new("Frame")
		carGrid.Name = rarity.name .. "Grid"
		carGrid.BackgroundTransparency = 1
		carGrid.Size = UDim2.new(0.95, 0, 0, 160)
		carGrid.Parent = carsScroll
		
		local gridLayout = Instance.new("UIGridLayout")
		gridLayout.CellSize = UDim2.new(0, 130, 0, 130)
		gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		gridLayout.FillDirection = Enum.FillDirection.Horizontal
		gridLayout.Padding = UDim.new(0, 15)
		gridLayout.Parent = carGrid
		
		-- Dummy cars per rarity
		for i = 1, 4 do
			local isOwned = (i <= 2)
			
			local carCard = UIHelper:CreateRoundedFrame(carGrid, {
				BackgroundColor3 = isOwned and Color3.fromHex("2d3561") or Theme.Colors.BackgroundTertiary,
				BackgroundTransparency = isOwned and 0 or 0.4,
				Size = UDim2.new(0, 130, 0, 130),
				CornerRadius = UDim.new(0, 12),
			})
			UIHelper:AddStroke(carCard, rarity.color, 2, isOwned and 0.3 or 0.5)
			
			-- Car name
			local carName = UIHelper:CreateTextLabel(carCard, {
				Text = rarity.name:sub(1, 3) .. " Car " .. i,
				TextColor3 = isOwned and Theme.Colors.TextPrimary or Theme.Colors.TextDisabled,
				Font = Theme.Fonts.BodySmall.Font,
				TextSize = 12,
				Size = UDim2.new(1, 0, 0, 35),
				Position = UDim2.new(0, 0, 0.35, 0),
			})
			carName.TextScaled = true
			
			-- Income
			local incomeLabel = UIHelper:CreateTextLabel(carCard, {
				Text = isOwned and "$150/min" or "???",
				TextColor3 = isOwned and Theme.Colors.Success or Theme.Colors.TextDisabled,
				Font = Theme.Fonts.BodySmall.Font,
				TextSize = 11,
				Size = UDim2.new(1, 0, 0, 30),
				Position = UDim2.new(0, 0, 0.7, 0),
			})
			incomeLabel.TextScaled = true
			
			-- Lock icon
			if not isOwned then
				local lockIcon = UIHelper:CreateTextLabel(carCard, {
					Text = "🔒",
					TextColor3 = Theme.Colors.TextDisabled,
					Font = Theme.Fonts.Heading.Font,
					TextSize = 28,
					Size = UDim2.new(1, 0, 0.5, 0),
				})
				lockIcon.TextScaled = true
			end
		end
	end
	
	-- ===== LOCKERS TAB CONTENT =====
	local lockersFrame = contentFrames.lockers
	local lockersScroll = Instance.new("ScrollingFrame")
	lockersScroll.BackgroundTransparency = 1
	lockersScroll.Size = UDim2.new(1, 0, 1, 0)
	lockersScroll.ScrollBarThickness = 8
	lockersScroll.TopImage = ""
	lockersScroll.BottomImage = ""
	lockersScroll.MidImage = ""
	lockersScroll.Parent = lockersFrame
	
	UIHelper:CreateListLayout(lockersScroll, {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 15),
	})
	
	local lockerTypes = {
		{name = "SILVER LOCKERS", color = Theme.Colors.Info, time = "1h", icon = "🟦"},
		{name = "GOLD LOCKERS", color = Theme.Colors.Legendary, time = "4h", icon = "🟨"},
		{name = "BLACK LOCKERS", color = Theme.Colors.TextDisabled, time = "8h", icon = "⬛"},
	}
	
	for _, lockerType in ipairs(lockerTypes) do
		local lockerHeader = UIHelper:CreateTextLabel(lockersScroll, {
			Text = lockerType.icon .. " " .. lockerType.name .. " (" .. lockerType.time .. ")",
			TextColor3 = lockerType.color,
			Font = Theme.Fonts.Subheading.Font,
			TextSize = 16,
			Size = UDim2.new(0.95, 0, 0, 35),
		})
		
		-- Dummy lockers
		for i = 1, 2 do
			local lockerCard = UIHelper:CreateRoundedFrame(lockersScroll, {
				BackgroundColor3 = Theme.Colors.BackgroundTertiary,
				BackgroundTransparency = 0.1,
				Size = UDim2.new(0.95, 0, 0, 90),
				CornerRadius = UDim.new(0, 12),
			})
			UIHelper:AddStroke(lockerCard, lockerType.color, 1, 0.3)
			
			local lockerLabel = UIHelper:CreateTextLabel(lockerCard, {
				Text = lockerType.icon .. " " .. lockerType.name .. " #" .. i,
				TextColor3 = Theme.Colors.TextSecondary,
				Font = Theme.Fonts.Body.Font,
				TextSize = 14,
				Size = UDim2.new(0.6, 0, 0.5, 0),
				Position = UDim2.new(0, 15, 0, 15),
			})
			
			local isReady = (i == 2)
			local timerLabel = UIHelper:CreateTextLabel(lockerCard, {
				Text = isReady and "✅ READY" or "⏱️ 0h 45m 30s",
				TextColor3 = isReady and Theme.Colors.Success or Theme.Colors.Warning,
				Font = Theme.Fonts.BodySmall.Font,
				TextSize = 12,
				Size = UDim2.new(0.6, 0, 0.5, 0),
				Position = UDim2.new(0, 15, 0.5, 0),
			})
			
			local openBtn = ButtonFactory:CreatePrimaryButton(lockerCard, {
				Text = isReady and "OPEN" or "LOCKED",
				BackgroundColor3 = isReady and Theme.Colors.Success or Theme.Colors.TextDisabled,
				Size = UDim2.new(0.3, -10, 0.8, -10),
				Position = UDim2.new(0.65, 0, 0.1, 0),
			})
		end
	end
	
	-- ===== INDEX TAB CONTENT =====
	local indexFrame = contentFrames.index
	local indexScroll = Instance.new("ScrollingFrame")
	indexScroll.BackgroundTransparency = 1
	indexScroll.Size = UDim2.new(1, 0, 1, 0)
	indexScroll.ScrollBarThickness = 8
	indexScroll.TopImage = ""
	indexScroll.BottomImage = ""
	indexScroll.MidImage = ""
	indexScroll.Parent = indexFrame
	
	UIHelper:CreateListLayout(indexScroll, {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 20),
	})
	
	for _, rarity in ipairs(rarities) do
		local rarityHeader = UIHelper:CreateTextLabel(indexScroll, {
			Text = "📑 " .. rarity.name .. " CARS (VIEW ONLY)",
			TextColor3 = rarity.color,
			Font = Theme.Fonts.Subheading.Font,
			TextSize = 18,
			Size = UDim2.new(0.95, 0, 0, 35),
		})
		
		local indexGrid = Instance.new("Frame")
		indexGrid.Name = rarity.name .. "IndexGrid"
		indexGrid.BackgroundTransparency = 1
		indexGrid.Size = UDim2.new(0.95, 0, 0, 160)
		indexGrid.Parent = indexScroll
		
		local gridLayout = Instance.new("UIGridLayout")
		gridLayout.CellSize = UDim2.new(0, 130, 0, 130)
		gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		gridLayout.FillDirection = Enum.FillDirection.Horizontal
		gridLayout.Padding = UDim.new(0, 15)
		gridLayout.Parent = indexGrid
		
		for i = 1, 4 do
			local isOwned = (i <= 2)
			
			local indexCard = UIHelper:CreateRoundedFrame(indexGrid, {
				BackgroundColor3 = isOwned and Color3.fromHex("2d3561") or Theme.Colors.BackgroundTertiary,
				BackgroundTransparency = isOwned and 0 or 0.4,
				Size = UDim2.new(0, 130, 0, 130),
				CornerRadius = UDim.new(0, 12),
			})
			UIHelper:AddStroke(indexCard, rarity.color, 2, isOwned and 0.3 or 0.5)
			
			local carName = UIHelper:CreateTextLabel(indexCard, {
				Text = rarity.name:sub(1, 3) .. " Car " .. i,
				TextColor3 = isOwned and Theme.Colors.TextPrimary or Theme.Colors.TextDisabled,
				Font = Theme.Fonts.BodySmall.Font,
				TextSize = 12,
				Size = UDim2.new(1, 0, 0, 35),
				Position = UDim2.new(0, 0, 0.35, 0),
			})
			carName.TextScaled = true
			
			local incomeLabel = UIHelper:CreateTextLabel(indexCard, {
				Text = isOwned and "$150/min" or "???",
				TextColor3 = isOwned and Theme.Colors.Success or Theme.Colors.TextDisabled,
				Font = Theme.Fonts.BodySmall.Font,
				TextSize = 11,
				Size = UDim2.new(1, 0, 0, 30),
				Position = UDim2.new(0, 0, 0.7, 0),
			})
			incomeLabel.TextScaled = true
			
			if not isOwned then
				local lockIcon = UIHelper:CreateTextLabel(indexCard, {
					Text = "🔒",
					TextColor3 = Theme.Colors.TextDisabled,
					Font = Theme.Fonts.Heading.Font,
					TextSize = 28,
					Size = UDim2.new(1, 0, 0.5, 0),
				})
				lockIcon.TextScaled = true
			end
		end
	end
	
	-- ===== TAB SWITCHING LOGIC =====
	for tabId, tabData in pairs(tabButtons) do
		tabData.btn.MouseButton1Click:Connect(function()
			-- Hide all tabs
			for id, frame in pairs(contentFrames) do
				frame.Visible = false
			end
			
			-- Update all tab buttons
			for id, data in pairs(tabButtons) do
				data.btn.BackgroundTransparency = 0.5
			end
			
			-- Show selected tab and highlight button
			contentFrames[tabId].Visible = true
			tabData.btn.BackgroundTransparency = 0
		end)
	end
	
	-- Set initial state
	tabButtons.items.btn.BackgroundTransparency = 0
	
	AnimationController:FadeIn(mainContainer, Theme.Animations.Normal)
	
	return screenGui
end

return InventoryScreen
