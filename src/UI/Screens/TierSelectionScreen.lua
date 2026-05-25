-- ========================================
-- TIER SELECTION SCREEN - Choose Bid Tier
-- ========================================

local TierSelectionScreen = {}
local Theme = require(game.ReplicatedStorage.Modules.UI.Theme)
local UIHelper = require(game.ReplicatedStorage.Modules.UI.Utilities.UIHelper)
local AnimationController = require(game.ReplicatedStorage.Modules.UI.Utilities.AnimationController)
local ButtonFactory = require(game.ReplicatedStorage.Modules.UI.Utilities.ButtonFactory)
local Config = require(game.ReplicatedStorage.Modules.Config)
local PlayerDataManager = require(game.ReplicatedStorage.Modules.PlayerDataManager)

-- ========== CREATE TIER SELECTION ==========
function TierSelectionScreen:Create(onTierSelected, onCancel)
	local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	local playerId = game.Players.LocalPlayer.UserId
	
	-- Screen GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TierSelectionScreen"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndex = 60
	screenGui.Parent = playerGui
	
	-- Overlay
	local overlay = Instance.new("Frame")
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.3
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.Parent = screenGui
	
	overlay.MouseButton1Click:Connect(function()
		if onCancel then onCancel() end
	end)
	
	-- Main container
	local container = UIHelper:CreateRoundedFrame(screenGui, {
		BackgroundColor3 = Theme.Colors.Background,
		BackgroundTransparency = 0,
		Size = UDim2.new(0.8, 0, 0.9, 0),
		Position = UDim2.new(0.1, 0, 0.05, 0),
		CornerRadius = UDim.new(0, 20),
		Padding = UDim.new(0, 30),
	})
	UIHelper:AddStroke(container, Theme.Colors.Primary, 2, 0.3)
	AnimationController:CreateGradient(container, Theme.Gradients.CyanToPurple)
	
	-- Header
	local header = UIHelper:CreateTextLabel(container, {
		Text = "🎯 SELECT YOUR BID TIER",
		TextColor3 = Theme.Colors.Primary,
		Font = Theme.Fonts.Title.Font,
		TextSize = 32,
		Size = UDim2.new(1, 0, 0, 60),
		Position = UDim2.new(0, 0, 0, 0),
	})
	header.TextScaled = true
	
	-- Tiers container (scrollable)
	local tiersContainer = Instance.new("Frame")
	tiersContainer.Name = "TiersContainer"
	tiersContainer.BackgroundTransparency = 1
	tiersContainer.Size = UDim2.new(1, 0, 1, -150)
	tiersContainer.Position = UDim2.new(0, 0, 0, 70)
	tiersContainer.ClipsDescendants = true
	tiersContainer.Parent = container
	
	UIHelper:CreateListLayout(tiersContainer, {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 15),
	})
	
	-- Tier data
	local tiers = {
		{name = "BEGINNER", price = 200, decos = "4-7", lancer = "1/10", rarity = "Common/Rare", color = Theme.Colors.Primary},
		{name = "ADVANCED", price = 500, decos = "7-13", lancer = "1/4", rarity = "Uncommon/Epic", color = Theme.Colors.Secondary},
		{name = "EXPERT", price = 1200, decos = "13-21", lancer = "1/2", rarity = "Rare/Legendary", color = Theme.Colors.Accent},
		{name = "CHOSEN", price = 2500, decos = "21-50", lancer = "1/1", rarity = "Rare/Legendary (10% SPEC)", color = Theme.Colors.Success},
	}
	
	local money = PlayerDataManager:GetMoney(playerId) or 700
	
	for idx, tier in ipairs(tiers) do
		-- Tier card
		local tierCard = UIHelper:CreateRoundedFrame(tiersContainer, {
			BackgroundColor3 = Theme.Colors.BackgroundTertiary,
			BackgroundTransparency = 0.2,
			Size = UDim2.new(0.9, 0, 0, 120),
			CornerRadius = UDim.new(0, 15),
		})
		tierCard.Name = tier.name .. "Tier"
		UIHelper:AddStroke(tierCard, tier.color, 2, 0.3)
		
		-- Tier info container
		local infoContainer = Instance.new("Frame")
		infoContainer.BackgroundTransparency = 1
		infoContainer.Size = UDim2.new(0.65, 0, 1, 0)
		infoContainer.Position = UDim2.new(0, 10, 0, 0)
		infoContainer.Parent = tierCard
		
		UIHelper:CreateListLayout(infoContainer, {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 15),
		})
		
		-- Tier name
		local tierName = UIHelper:CreateTextLabel(infoContainer, {
			Text = tier.name,
			TextColor3 = tier.color,
			Font = Theme.Fonts.Heading.Font,
			TextSize = 22,
			Size = UDim2.new(0.2, 0, 0.5, 0),
		})
		tierName.TextScaled = true
		
		-- Tier details
		local detailsText = UIHelper:CreateTextLabel(infoContainer, {
			Text = "Entry: $" .. tier.price .. " | Decos: " .. tier.decos .. " | Locker: " .. tier.lancer .. " | Rarity: " .. tier.rarity,
			TextColor3 = Theme.Colors.TextSecondary,
			Font = Theme.Fonts.BodySmall.Font,
			TextSize = 12,
			Size = UDim2.new(0.8, 0, 0.5, 0),
		})
		detailsText.TextWrapped = true
		
		-- Select button
		local selectBtn = nil
		if money >= tier.price then
			selectBtn = ButtonFactory:CreatePrimaryButton(tierCard, {
				Text = "SELECT",
				BackgroundColor3 = tier.color,
				Size = UDim2.new(0.25, -10, 0.8, 0),
				Position = UDim2.new(0.7, 5, 0.1, 0),
				OnClick = function()
					AnimationController:FadeOut(container, Theme.Animations.Normal)
					wait(Theme.Animations.Normal)
					screenGui:Destroy()
					if onTierSelected then
						onTierSelected(tier.name)
					end
				end,
			})
		else
			-- Disabled button
			selectBtn = ButtonFactory:CreateDisabledButton(tierCard, {
				Text = "$" .. (tier.price - money) .. " SHORT",
				Size = UDim2.new(0.25, -10, 0.8, 0),
				Position = UDim2.new(0.7, 5, 0.1, 0),
			end)
		end
		
		tierCard.LayoutOrder = idx
	end
	
	-- Bottom: Cancel button
	local cancelBtn = ButtonFactory:CreateOutlineButton(container, {
		Text = "CANCEL",
		Size = UDim2.new(0.25, 0, 0, 50),
		Position = UDim2.new(0.375, 0, 1, -70),
		OnClick = function()
			AnimationController:FadeOut(container, Theme.Animations.Normal)
			wait(Theme.Animations.Normal)
			screenGui:Destroy()
			if onCancel then onCancel() end
		end,
	})
	
	return screenGui
end

return TierSelectionScreen