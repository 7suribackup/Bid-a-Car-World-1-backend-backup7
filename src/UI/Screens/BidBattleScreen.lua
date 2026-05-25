-- ========================================
-- BID BATTLE SCREEN - Live Bidding UI
-- ========================================

local BidBattleScreen = {}
local Theme = require(game.ReplicatedStorage.Modules.UI.Theme)
local UIHelper = require(game.ReplicatedStorage.Modules.UI.Utilities.UIHelper)
local AnimationController = require(game.ReplicatedStorage.Modules.UI.Utilities.AnimationController)
local ButtonFactory = require(game.ReplicatedStorage.Modules.UI.Utilities.ButtonFactory)

-- ========== CREATE BID BATTLE SCREEN ==========
function BidBattleScreen:Create(tierName, bidData, onRaiseBid, onPass, onComplete)
	local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Screen GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BidBattleScreen"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndex = 70
	screenGui.Parent = playerGui
	
	-- Background
	local background = UIHelper:CreateRoundedFrame(screenGui, {
		BackgroundColor3 = Theme.Colors.Background,
		BackgroundTransparency = 0,
		Size = UDim2.new(1, 0, 1, 0),
	})
	AnimationController:CreateGradient(background, Theme.Gradients.CyanToPurple)
	
	-- ===== TOP: TIER & COUNTDOWN =====
	local topBar = UIHelper:CreateRoundedFrame(background, {
		BackgroundColor3 = Theme.Colors.BackgroundTertiary,
		BackgroundTransparency = 0.2,
		Size = UDim2.new(1, 0, 0, 100),
		Position = UDim2.new(0, 0, 0, 0),
	})
	UIHelper:AddStroke(topBar, Theme.Colors.Primary, 1, 0.5)
	
	-- Tier info
	local tierText = UIHelper:CreateTextLabel(topBar, {
		Text = "🎯 " .. tierName .. " BID BATTLE",
		TextColor3 = Theme.Colors.Primary,
		Font = Theme.Fonts.Heading.Font,
		TextSize = 24,
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0, 20, 0, 0),
	})
	tierText.TextScaled = true
	
	-- Countdown timer (right side)
	local countdownLabel = UIHelper:CreateTextLabel(topBar, {
		Text = "⏱️ 120s",
		TextColor3 = Theme.Colors.Accent,
		Font = Theme.Fonts.Title.Font,
		TextSize = 32,
		Size = UDim2.new(0.25, 0, 1, 0),
		Position = UDim2.new(0.75, 0, 0, 0),
	})
	countdownLabel.TextScaled = true
	
	-- ===== MIDDLE: CURRENT BID =====
	local centerContainer = Instance.new("Frame")
	centerContainer.BackgroundTransparency = 1
	centerContainer.Size = UDim2.new(1, 0, 0.5, 0)
	centerContainer.Position = UDim2.new(0, 0, 0.15, 0)
	centerContainer.Parent = background
	
	UIHelper:CreateListLayout(centerContainer, {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 20),
	})
	
	local bidLabelText = UIHelper:CreateTextLabel(centerContainer, {
		Text = "CURRENT BID",
		TextColor3 = Theme.Colors.TextSecondary,
		Font = Theme.Fonts.Body.Font,
		TextSize = 18,
		Size = UDim2.new(0.6, 0, 0, 30),
	})
	bidLabelText.TextScaled = true
	
	-- Current bid amount (HUGE)
	local currentBidAmount = UIHelper:CreateTextLabel(centerContainer, {
		Text = "$" .. (bidData.currentBid or 0),
		TextColor3 = Theme.Colors.Primary,
		Font = Theme.Fonts.Title.Font,
		TextSize = 60,
		Size = UDim2.new(0.8, 0, 0, 80),
	})
	currentBidAmount.TextScaled = true
	
	-- Current bidder
	local bidderLabel = UIHelper:CreateTextLabel(centerContainer, {
		Text = "by " .. (bidData.currentBidder or "Nobody"),
		TextColor3 = Theme.Colors.TextSecondary,
		Font = Theme.Fonts.Body.Font,
		TextSize = 16,
		Size = UDim2.new(0.6, 0, 0, 30),
	})
	bidderLabel.TextScaled = true
	
	-- ===== BID HISTORY =====
	local historyLabel = UIHelper:CreateTextLabel(background, {
		Text = "📋 BID HISTORY",
		TextColor3 = Theme.Colors.Secondary,
		Font = Theme.Fonts.Subheading.Font,
		TextSize = 16,
		Size = UDim2.new(0.25, 0, 0, 30),
		Position = UDim2.new(0.02, 0, 0.68, 0),
	})
	
	local historyContainer = UIHelper:CreateRoundedFrame(background, {
		BackgroundColor3 = Theme.Colors.BackgroundTertiary,
		BackgroundTransparency = 0.1,
		Size = UDim2.new(0.25, 0, 0.25, 0),
		Position = UDim2.new(0.02, 0, 0.72, 0),
		CornerRadius = UDim.new(0, 12),
	})
	
	UIHelper:CreateListLayout(historyContainer, {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 5),
	})
	
	-- Dummy bid history
	for i = 1, 3 do
		local bidEntry = UIHelper:CreateTextLabel(historyContainer, {
			Text = "Player" .. i .. ": $" .. (1000 + i * 100),
			TextColor3 = Theme.Colors.TextSecondary,
			Font = Theme.Fonts.BodySmall.Font,
			TextSize = 11,
			Size = UDim2.new(1, 0, 0, 25),
		})
	end
	
	-- ===== BOTTOM: ACTION BUTTONS =====
	local bottomBar = Instance.new("Frame")
	bottomBar.BackgroundTransparency = 1
	bottomBar.Size = UDim2.new(1, 0, 0, 120)
	bottomBar.Position = UDim2.new(0, 0, 1, -120)
	bottomBar.Parent = background
	
	UIHelper:CreateListLayout(bottomBar, {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 20),
	})
	
	-- RAISE BID button
	local raiseBidBtn = ButtonFactory:CreatePrimaryButton(bottomBar, {
		Text = "✋ RAISE BID",
		Size = UDim2.new(0, 200, 0, 80),
		OnClick = function()
			if onRaiseBid then onRaiseBid() end
		end,
	})
	raiseBidBtn.LayoutOrder = 1
	
	-- PASS button
	local passBtn = ButtonFactory:CreateOutlineButton(bottomBar, {
		Text = "��️ PASS",
		Size = UDim2.new(0, 200, 0, 80),
		OnClick = function()
			if onPass then onPass() end
		end,
	})
	passBtn.LayoutOrder = 2
	
	-- Countdown animation
	local countdownTime = 120
	local countdownCoroutine = coroutine.create(function()
		while countdownTime > 0 and screenGui.Parent do
			wait(1)
			countdownTime = countdownTime - 1
			
			if countdownTime <= 10 then
				AnimationController:ColorTransition(countdownLabel, Theme.Colors.Error, Theme.Animations.VeryFast)
			end
			
			local minutes = math.floor(countdownTime / 60)
			local seconds = countdownTime % 60
			countdownLabel.Text = string.format("⏱️ %02d:%02d", minutes, seconds)
		end
		
		-- Time's up!
		countdownLabel.Text = "⏱️ TIME'S UP!"
		if onComplete then onComplete() end
	end)
	coroutine.resume(countdownCoroutine)
	
	return screenGui
end

return BidBattleScreen