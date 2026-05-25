-- ========================================
-- SHOP UI - Dice Shop Interface
-- Modern Bid Battles Theme
-- ========================================

local ShopUI = {}
local Theme = require(game.ReplicatedStorage.Modules.UI.Theme)
local UIHelper = require(game.ReplicatedStorage.Modules.UI.Utilities.UIHelper)
local AnimationController = require(game.ReplicatedStorage.Modules.UI.Utilities.AnimationController)
local ButtonFactory = require(game.ReplicatedStorage.Modules.UI.Utilities.ButtonFactory)
local PlayerDataManager = require(game.ReplicatedStorage.Modules.PlayerDataManager)

-- ========== CREATE SHOP UI ==========
function ShopUI:Create(playerMoney, rebirthLevel, onBuyDice, onClose)
	local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	local playerId = game.Players.LocalPlayer.UserId
	
	-- Screen GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ShopUI"
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
		Size = UDim2.new(0.85, 0, 0.88, 0),
		Position = UDim2.new(0.075, 0, 0.06, 0),
		CornerRadius = UDim.new(0, 20),
	})
	UIHelper:AddStroke(mainContainer, Theme.Colors.Primary, 2, 0.3)
	AnimationController:CreateGradient(mainContainer, Theme.Gradients.CyanToPurple)
	
	-- ===== HEADER =====
	local header = UIHelper:CreateRoundedFrame(mainContainer, {
		BackgroundColor3 = Theme.Colors.BackgroundSecondary,
		BackgroundTransparency = 0.2,
		Size = UDim2.new(1, 0, 0, 90),
		Position = UDim2.new(0, 0, 0, 0),
	})
	UIHelper:AddStroke(header, Theme.Colors.Primary, 1, 0.3)
	
	-- Header layout
	local headerLayout = Instance.new("Frame")
	headerLayout.BackgroundTransparency = 1
	headerLayout.Size = UDim2.new(1, 0, 1, 0)
	headerLayout.Parent = header
	
	UIHelper:CreateListLayout(headerLayout, {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 20),
	})
	
	-- Shop title
	local shopTitle = UIHelper:CreateTextLabel(headerLayout, {
		Text = "🎲 DICE SHOP",
		TextColor3 = Theme.Colors.Primary,
		Font = Theme.Fonts.Heading.Font,
		TextSize = 28,
		Size = UDim2.new(0.5, 0, 1, 0),
	})
	shopTitle.TextScaled = true
	
	-- Money display (right side)
	local moneyFrame = UIHelper:CreateRoundedFrame(headerLayout, {
		BackgroundColor3 = Theme.Colors.BackgroundTertiary,
		BackgroundTransparency = 0.2,
		Size = UDim2.new(0, 200, 0, 60),
		CornerRadius = UDim.new(0, 12),
	})
	UIHelper:AddStroke(moneyFrame, Theme.Colors.Success, 2, 0.4)
	
	UIHelper:CreateListLayout(moneyFrame, {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 3),
	})
	
	local balanceLabel = UIHelper:CreateTextLabel(moneyFrame, {
		Text = "💰 BALANCE",
		TextColor3 = Theme.Colors.TextSecondary,
		Font = Theme.Fonts.BodySmall.Font,
		TextSize = 11,
		Size = UDim2.new(1, 0, 0, 18),
	})
	
	local moneyLabel = UIHelper:CreateTextLabel(moneyFrame, {
		Text = "$" .. string.format("%d", playerMoney),
		TextColor3 = Theme.Colors.Success,
		Font = Theme.Fonts.Heading.Font,
		TextSize = 24,
		Size = UDim2.new(1, 0, 0, 35),
	})
	moneyLabel.TextScaled = true
	
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
	
	-- ===== CONTENT SCROLL =====
	local contentFrame = Instance.new("Frame")
	contentFrame.BackgroundTransparency = 1
	contentFrame.Size = UDim2.new(1, -40, 1, -130)
	contentFrame.Position = UDim2.new(0, 20, 0, 110)
	contentFrame.ClipsDescendants = true
	contentFrame.Parent = mainContainer
	
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.TopImage = ""
	scrollFrame.BottomImage = ""
	scrollFrame.MidImage = ""
	scrollFrame.Parent = contentFrame
	
	UIHelper:CreateListLayout(scrollFrame, {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 25),
	})
	
	-- ===== DICE PRODUCTS =====
	local diceProducts = {
		{
			id = "basic",
			name = "BASIC DICE",
			icon = "🎲",
			price = 150,
			color = Theme.Colors.Common,
			npcRarity = "Common",
			boostRange = "10-30%",
			minRebirth = 0,
			description = "Roll for common NPCs",
		},
		{
			id = "golden",
			name = "GOLDEN DICE",
			icon = "✨",
			price = 300,
			color = Theme.Colors.Legendary,
			npcRarity = "Uncommon",
			boostRange = "30-50%",
			minRebirth = 1,
			description = "Roll for uncommon NPCs",
		},
		{
			id = "diamond",
			name = "DIAMOND DICE",
			icon = "💎",
			price = 1100,
			color = Theme.Colors.Rare,
			npcRarity = "Rare",
			boostRange = "50-80%",
			minRebirth = 2,
			description = "Roll for rare NPCs",
		},
		{
			id = "naspec",
			name = "NA-SPEC DICE",
			icon = "🌟",
			price = 2500,
			color = Theme.Colors.SPEC,
			npcRarity = "SPEC",
			boostRange = "80-120%",
			minRebirth = 3,
			description = "Roll for legendary SPEC NPCs",
		},
	}
	
	-- Create dice cards
	for idx, dice in ipairs(diceProducts) do
		local isAvailable = rebirthLevel >= dice.minRebirth
		local canAfford = playerMoney >= dice.price
		
		-- Dice card container
		local diceCard = UIHelper:CreateRoundedFrame(scrollFrame, {
			BackgroundColor3 = Theme.Colors.BackgroundTertiary,
			BackgroundTransparency = isAvailable and 0.1 or 0.4,
			Size = UDim2.new(0.95, 0, 0, 160),
			CornerRadius = UDim.new(0, 16),
		})
		UIHelper:AddStroke(diceCard, dice.color, 2, isAvailable and 0.4 or 0.2)
		
		-- Content layout
		local cardLayout = Instance.new("Frame")
		cardLayout.BackgroundTransparency = 1
		cardLayout.Size = UDim2.new(1, 0, 1, 0)
		cardLayout.Parent = diceCard
		
		UIHelper:CreateListLayout(cardLayout, {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 20),
		})
		
		-- Left section: Icon & name
		local leftSection = Instance.new("Frame")
		leftSection.BackgroundTransparency = 1
		leftSection.Size = UDim2.new(0, 120, 1, 0)
		leftSection.Parent = cardLayout
		
		UIHelper:CreateListLayout(leftSection, {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 5),
		})
		
		local diceIcon = UIHelper:CreateTextLabel(leftSection, {
			Text = dice.icon,
			TextColor3 = dice.color,
			Font = Theme.Fonts.Title.Font,
			TextSize = 48,
			Size = UDim2.new(1, 0, 0, 60),
		})
		
		local diceName = UIHelper:CreateTextLabel(leftSection, {
			Text = dice.name,
			TextColor3 = isAvailable and dice.color or Theme.Colors.TextDisabled,
			Font = Theme.Fonts.Subheading.Font,
			TextSize = 14,
			Size = UDim2.new(1, 0, 0, 30),
		})
		diceName.TextScaled = true
		
		-- Middle section: Details
		local middleSection = Instance.new("Frame")
		middleSection.BackgroundTransparency = 1
		middleSection.Size = UDim2.new(0.35, 0, 1, 0)
		middleSection.Parent = cardLayout
		
		UIHelper:CreateListLayout(middleSection, {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 5),
		})
		
		local descLabel = UIHelper:CreateTextLabel(middleSection, {
			Text = dice.description,
			TextColor3 = Theme.Colors.TextSecondary,
			Font = Theme.Fonts.Body.Font,
			TextSize = 12,
			Size = UDim2.new(1, 0, 0, 30),
		})
		descLabel.TextWrapped = true
		
		local rarityLabel = UIHelper:CreateTextLabel(middleSection, {
			Text = "NPC: " .. dice.npcRarity,
			TextColor3 = dice.color,
			Font = Theme.Fonts.BodySmall.Font,
			TextSize = 11,
			Size = UDim2.new(1, 0, 0, 22),
		})
		
		local boostLabel = UIHelper:CreateTextLabel(middleSection, {
			Text = "Boost: " .. dice.boostRange,
			TextColor3 = Theme.Colors.Info,
			Font = Theme.Fonts.BodySmall.Font,
			TextSize = 11,
			Size = UDim2.new(1, 0, 0, 22),
		})
		
		-- Right section: Price & Button
		local rightSection = Instance.new("Frame")
		rightSection.BackgroundTransparency = 1
		rightSection.Size = UDim2.new(0, 160, 1, 0)
		rightSection.Parent = cardLayout
		
		UIHelper:CreateListLayout(rightSection, {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 10),
		})
		
		-- Price display
		local priceLabel = UIHelper:CreateTextLabel(rightSection, {
			Text = "$" .. dice.price,
			TextColor3 = canAfford and Theme.Colors.Success or Theme.Colors.Error,
			Font = Theme.Fonts.Heading.Font,
			TextSize = 24,
			Size = UDim2.new(1, 0, 0, 40),
		})
		priceLabel.TextScaled = true
		
		-- Buy button
		local buyBtn
		if not isAvailable then
			-- Locked button
			buyBtn = ButtonFactory:CreateDisabledButton(rightSection, {
				Text = "🔒 LOCKED",
				Size = UDim2.new(1, 0, 0, 45),
			})
		elseif canAfford then
			-- Available button
			buyBtn = ButtonFactory:CreatePrimaryButton(rightSection, {
				Text = "🛒 BUY",
				BackgroundColor3 = dice.color,
				Size = UDim2.new(1, 0, 0, 45),
				OnClick = function()
					-- Visual feedback
					AnimationController:ColorTransition(buyBtn, Theme.Colors.Success, Theme.Animations.VeryFast)
					wait(0.2)
					
					-- Deduct money and add dice
					if onBuyDice then
						onBuyDice(dice.id, dice.price)
					end
					
					-- Update balance display
					playerMoney = playerMoney - dice.price
					moneyLabel.Text = "$" .. string.format("%d", playerMoney)
					
					-- Reset button color
					AnimationController:ColorTransition(buyBtn, dice.color, Theme.Animations.VeryFast)
				end,
			})
		else
			-- Can't afford button
			local shortage = dice.price - playerMoney
			buyBtn = ButtonFactory:CreateDisabledButton(rightSection, {
				Text = "$" .. shortage .. " SHORT",
				Size = UDim2.new(1, 0, 0, 45),
			})
		end
		
		buyBtn.LayoutOrder = 1
	end
	
	-- ===== INFO SECTION =====
	local infoLabel = UIHelper:CreateTextLabel(scrollFrame, {
		Text = "ℹ️ Buy dice to unlock random NPCs for your conveyors. NPCs boost car income!",
		TextColor3 = Theme.Colors.Info,
		Font = Theme.Fonts.BodySmall.Font,
		TextSize = 12,
		Size = UDim2.new(0.95, 0, 0, 50),
	})
	infoLabel.TextWrapped = true
	
	-- Entrance animation
	AnimationController:FadeIn(mainContainer, Theme.Animations.Normal)
	
	return screenGui
end

return ShopUI
