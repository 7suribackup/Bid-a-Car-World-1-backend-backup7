-- ========================================
-- REBIRTH UI - Rebirth Confirmation Modal
-- Modern Bid Battles Theme
-- ========================================

local RebirthUI = {}
local Theme = require(game.ReplicatedStorage.Modules.UI.Theme)
local UIHelper = require(game.ReplicatedStorage.Modules.UI.Utilities.UIHelper)
local AnimationController = require(game.ReplicatedStorage.Modules.UI.Utilities.AnimationController)
local ButtonFactory = require(game.ReplicatedStorage.Modules.UI.Utilities.ButtonFactory)
local PlayerDataManager = require(game.ReplicatedStorage.Modules.PlayerDataManager)

-- ========== CREATE REBIRTH UI ==========
function RebirthUI:Create(rebirthLevel, currentMoney, onConfirm, onCancel)
	local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	local playerId = game.Players.LocalPlayer.UserId
	
	-- Screen GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RebirthUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndex = 100
	screenGui.Parent = playerGui
	
	-- Dark overlay
	local overlay = Instance.new("Frame")
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.Parent = screenGui
	overlay.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
			-- Don't close on overlay click
		end
	end)
	
	-- Main modal container
	local mainContainer = UIHelper:CreateRoundedFrame(screenGui, {
		BackgroundColor3 = Theme.Colors.Background,
		BackgroundTransparency = 0,
		Size = UDim2.new(0.6, 0, 0.75, 0),
		Position = UDim2.new(0.2, 0, 0.125, 0),
		CornerRadius = UDim.new(0, 24),
	})
	UIHelper:AddStroke(mainContainer, Theme.Colors.Primary, 3, 0.2)
	AnimationController:CreateGradient(mainContainer, Theme.Gradients.CyanToPurple)
	
	-- ===== HEADER SECTION =====
	local headerContainer = UIHelper:CreateRoundedFrame(mainContainer, {
		BackgroundColor3 = Theme.Colors.BackgroundSecondary,
		BackgroundTransparency = 0.2,
		Size = UDim2.new(1, 0, 0, 100),
		Position = UDim2.new(0, 0, 0, 0),
		CornerRadius = UDim.new(0, 24),
	})
	UIHelper:AddStroke(headerContainer, Theme.Colors.Secondary, 2, 0.3)
	
	-- Rebirth icon
	local rebirthIcon = UIHelper:CreateTextLabel(headerContainer, {
		Text = "✨",
		TextColor3 = Theme.Colors.Secondary,
		Font = Theme.Fonts.Title.Font,
		TextSize = 48,
		Size = UDim2.new(0, 80, 0, 80),
		Position = UDim2.new(0, 20, 0.5, -40),
	})
	
	-- Header title
	local headerTitle = UIHelper:CreateTextLabel(headerContainer, {
		Text = "REBIRTH AVAILABLE",
		TextColor3 = Theme.Colors.Primary,
		Font = Theme.Fonts.Heading.Font,
		TextSize = 24,
		Size = UDim2.new(0.7, -100, 0.5, 0),
		Position = UDim2.new(0, 100, 0, 10),
	})
	headerTitle.TextScaled = true
	
	-- Rebirth level display
	local levelLabel = UIHelper:CreateTextLabel(headerContainer, {
		Text = "REBIRTH LEVEL " .. rebirthLevel,
		TextColor3 = Theme.Colors.Secondary,
		Font = Theme.Fonts.Body.Font,
		TextSize = 14,
		Size = UDim2.new(0.7, -100, 0.5, 0),
		Position = UDim2.new(0, 100, 0.5, 0),
	})
	levelLabel.TextScaled = true
	
	-- ===== CONTENT SECTION =====
	local contentContainer = Instance.new("Frame")
	contentContainer.BackgroundTransparency = 1
	contentContainer.Size = UDim2.new(1, -40, 1, -180)
	contentContainer.Position = UDim2.new(0, 20, 0, 120)
	contentContainer.Parent = mainContainer
	
	UIHelper:CreateListLayout(contentContainer, {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 15),
	})
	
	-- Warning message
	local warningLabel = UIHelper:CreateTextLabel(contentContainer, {
		Text = "⚠️ CONFIRM YOUR REBIRTH",
		TextColor3 = Theme.Colors.Accent,
		Font = Theme.Fonts.Heading.Font,
		TextSize = 18,
		Size = UDim2.new(1, 0, 0, 40),
	})
	warningLabel.TextScaled = true
	
	-- Description
	local descLabel = UIHelper:CreateTextLabel(contentContainer, {
		Text = "You will lose all your money but keep your items, cars, and NPCs!",
		TextColor3 = Theme.Colors.TextSecondary,
		Font = Theme.Fonts.Body.Font,
		TextSize = 14,
		Size = UDim2.new(1, 0, 0, 50),
	})
	descLabel.TextWrapped = true
	descLabel.TextScaled = true
	
	-- ===== STATISTICS SECTION =====
	local statsContainer = UIHelper:CreateRoundedFrame(contentContainer, {
		BackgroundColor3 = Theme.Colors.BackgroundTertiary,
		BackgroundTransparency = 0.2,
		Size = UDim2.new(1, 0, 0, 140),
		CornerRadius = UDim.new(0, 16),
	})
	UIHelper:AddStroke(statsContainer, Theme.Colors.Primary, 1, 0.3)
	
	UIHelper:CreateListLayout(statsContainer, {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 10),
	})
	
	-- Current money display
	local currentMoneyLabel = UIHelper:CreateTextLabel(statsContainer, {
		Text = "💰 CURRENT MONEY",
		TextColor3 = Theme.Colors.Secondary,
		Font = Theme.Fonts.Body.Font,
		TextSize = 12,
		Size = UDim2.new(1, 0, 0, 25),
	})
	currentMoneyLabel.TextScaled = true
	
	local moneyAmountLabel = UIHelper:CreateTextLabel(statsContainer, {
		Text = "$" .. string.format("%d", currentMoney),
		TextColor3 = Theme.Colors.Accent,
		Font = Theme.Fonts.Title.Font,
		TextSize = 32,
		Size = UDim2.new(1, 0, 0, 50),
	})
	moneyAmountLabel.TextScaled = true
	
	local loseMessageLabel = UIHelper:CreateTextLabel(statsContainer, {
		Text = "❌ This will be reset to $0",
		TextColor3 = Theme.Colors.Error,
		Font = Theme.Fonts.BodySmall.Font,
		TextSize = 11,
		Size = UDim2.new(1, 0, 0, 25),
	})
	loseMessageLabel.TextScaled = true
	
	-- ===== BENEFITS SECTION =====
	local benefitsLabel = UIHelper:CreateTextLabel(contentContainer, {
		Text = "📈 REBIRTH BENEFITS",
		TextColor3 = Theme.Colors.Success,
		Font = Theme.Fonts.Subheading.Font,
		TextSize = 16,
		Size = UDim2.new(1, 0, 0, 30),
	})
	benefitsLabel.TextScaled = true
	
	-- Benefits container
	local benefitsContainer = Instance.new("Frame")
	benefitsContainer.BackgroundTransparency = 1
	benefitsContainer.Size = UDim2.new(1, 0, 0, 100)
	benefitsContainer.Parent = contentContainer
	
	UIHelper:CreateListLayout(benefitsContainer, {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 8),
	})
	
	-- Define benefits per rebirth level
	local benefits = {}
	if rebirthLevel == 1 then
		benefits = {
			"✅ Unlock +1 Conveyor (4 total)",
			"✅ Gain +2 Luck Boosts",
		}
	elseif rebirthLevel == 2 then
		benefits = {
			"✅ Unlock Trade System (Player ↔ Player)",
			"✅ Enhanced progression speed",
		}
	elseif rebirthLevel == 3 then
		benefits = {
			"✅ Unlock +1 Conveyor (5 total)",
			"✅ Access World 2 Coming Soon!",
		}
	else
		benefits = {
			"✅ Progress to next milestone",
		}
	end
	
	for _, benefit in ipairs(benefits) do
		local benefitLabel = UIHelper:CreateTextLabel(benefitsContainer, {
			Text = benefit,
			TextColor3 = Theme.Colors.Success,
			Font = Theme.Fonts.Body.Font,
			TextSize = 13,
			Size = UDim2.new(1, 0, 0, 28),
		})
		benefitLabel.TextScaled = true
	end
	
	-- ===== BUTTON SECTION =====
	local buttonContainer = Instance.new("Frame")
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.Size = UDim2.new(1, -40, 0, 60)
	buttonContainer.Position = UDim2.new(0, 20, 1, -80)
	buttonContainer.Parent = mainContainer
	
	UIHelper:CreateListLayout(buttonContainer, {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 20),
	})
	
	-- Confirm button
	local confirmBtn = ButtonFactory:CreatePrimaryButton(buttonContainer, {
		Text = "✨ CONFIRM REBIRTH",
		BackgroundColor3 = Theme.Colors.Secondary,
		Size = UDim2.new(0, 200, 0, 60),
		OnClick = function()
			-- Confirmation animation
			AnimationController:ColorTransition(confirmBtn, Theme.Colors.Success, Theme.Animations.VeryFast)
			wait(0.2)
			
			AnimationController:FadeOut(mainContainer, Theme.Animations.Normal)
			wait(Theme.Animations.Normal)
			screenGui:Destroy()
			
			if onConfirm then onConfirm() end
		end,
	})
	confirmBtn.LayoutOrder = 1
	
	-- Cancel button
	local cancelBtn = ButtonFactory:CreateOutlineButton(buttonContainer, {
		Text = "❌ CANCEL",
		Size = UDim2.new(0, 150, 0, 60),
		OnClick = function()
			AnimationController:FadeOut(mainContainer, Theme.Animations.Normal)
			wait(Theme.Animations.Normal)
			screenGui:Destroy()
			
			if onCancel then onCancel() end
		end,
	})
	cancelBtn.LayoutOrder = 2
	
	-- ===== ENTRANCE ANIMATION =====
	mainContainer.Position = UDim2.new(0.2, 0, 0.125, 50)
	mainContainer.BackgroundTransparency = 0.3
	AnimationController:FadeIn(mainContainer, Theme.Animations.Normal)
	
	-- Subtle scale-up animation
	local tweenInfo = TweenInfo.new(
		Theme.Animations.Normal,
		Theme.Animations.EaseOutElastic,
		Theme.Animations.EaseOut
	)
	local tween = game:GetService("TweenService"):Create(mainContainer, tweenInfo, {
		Position = UDim2.new(0.2, 0, 0.125, 0),
		BackgroundTransparency = 0,
	})
	tween:Play()
	
	return screenGui
end

return RebirthUI
