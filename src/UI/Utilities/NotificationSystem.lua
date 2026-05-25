-- ========================================
-- NOTIFICATION SYSTEM - Toast Notifications
-- Modern Bid Battles Theme
-- ========================================

local NotificationSystem = {}
local Theme = require(game.ReplicatedStorage.Modules.UI.Theme)
local UIHelper = require(game.ReplicatedStorage.Modules.UI.Utilities.UIHelper)
local AnimationController = require(game.ReplicatedStorage.Modules.UI.Utilities.AnimationController)

-- Active notifications queue
local activeNotifications = {}
local notificationQueue = {}

-- ========== CREATE NOTIFICATION ==========
function NotificationSystem:Show(message, notificationType, duration)
	notificationType = notificationType or "info" -- info, success, error, warning
	duration = duration or 3
	
	local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Determine colors based on type
	local typeConfig = {
		info = {icon = "ℹ️", color = Theme.Colors.Info, bgColor = Theme.Colors.BackgroundTertiary},
		success = {icon = "✅", color = Theme.Colors.Success, bgColor = Theme.Colors.BackgroundTertiary},
		error = {icon = "❌", color = Theme.Colors.Error, bgColor = Theme.Colors.BackgroundTertiary},
		warning = {icon = "⚠️", color = Theme.Colors.Warning, bgColor = Theme.Colors.BackgroundTertiary},
		money = {icon = "💰", color = Theme.Colors.Success, bgColor = Theme.Colors.BackgroundTertiary},
		bid = {icon = "🎯", color = Theme.Colors.Accent, bgColor = Theme.Colors.BackgroundTertiary},
		item = {icon = "📦", color = Theme.Colors.Secondary, bgColor = Theme.Colors.BackgroundTertiary},
	}
	
	local config = typeConfig[notificationType] or typeConfig.info
	
	-- Screen GUI for notifications
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NotificationGui_" .. tick()
	screenGui.ResetOnSpawn = false
	screenGui.ZIndex = 200
	screenGui.Parent = playerGui
	
	-- Calculate position based on active notifications
	local yOffset = 20 + (#activeNotifications * 120)
	
	-- Notification container
	local notifContainer = UIHelper:CreateRoundedFrame(screenGui, {
		BackgroundColor3 = config.bgColor,
		BackgroundTransparency = 0.1,
		Size = UDim2.new(0, 350, 0, 100),
		Position = UDim2.new(1, -370, 0, yOffset),
		CornerRadius = UDim.new(0, 12),
	})
	UIHelper:AddStroke(notifContainer, config.color, 2, 0.3)
	
	-- Slide-in animation
	local slideInTween = game:GetService("TweenService"):Create(
		notifContainer,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Position = UDim2.new(1, -370, 0, yOffset)}
	)
	
	notifContainer.Position = UDim2.new(1, 20, 0, yOffset)
	slideInTween:Play()
	
	-- Content layout
	local contentLayout = Instance.new("Frame")
	contentLayout.BackgroundTransparency = 1
	contentLayout.Size = UDim2.new(1, 0, 1, 0)
	contentLayout.Parent = notifContainer
	
	UIHelper:CreateListLayout(contentLayout, {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 15),
	})
	
	-- Icon
	local iconLabel = UIHelper:CreateTextLabel(contentLayout, {
		Text = config.icon,
		TextColor3 = config.color,
		Font = Theme.Fonts.Heading.Font,
		TextSize = 24,
		Size = UDim2.new(0, 50, 1, 0),
	})
	iconLabel.TextScaled = true
	
	-- Message text
	local messageLabel = UIHelper:CreateTextLabel(contentLayout, {
		Text = message,
		TextColor3 = Theme.Colors.TextPrimary,
		Font = Theme.Fonts.Body.Font,
		TextSize = 14,
		Size = UDim2.new(1, -100, 1, 0),
	})
	messageLabel.TextWrapped = true
	messageLabel.TextScaled = false
	
	-- Progress bar
	local progressBar = UIHelper:CreateRoundedFrame(notifContainer, {
		BackgroundColor3 = config.color,
		BackgroundTransparency = 0.3,
		Size = UDim2.new(1, 0, 0, 3),
		Position = UDim2.new(0, 0, 1, -3),
		CornerRadius = UDim.new(0, 2),
	})
	
	-- Progress animation
	local progressTween = game:GetService("TweenService"):Create(
		progressBar,
		TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
		{Size = UDim2.new(0, 0, 0, 3)}
	)
	progressTween:Play()
	
	-- Add to active notifications
	table.insert(activeNotifications, {gui = screenGui, container = notifContainer})
	
	-- Auto-remove after duration
	task.wait(duration + 0.4)
	
	-- Slide-out animation
	local slideOutTween = game:GetService("TweenService"):Create(
		notifContainer,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{Position = UDim2.new(1, 20, 0, yOffset)}
	)
	slideOutTween:Play()
	slideOutTween.Completed:Connect(function()
		screenGui:Destroy()
		
		-- Remove from active
		for i, notif in ipairs(activeNotifications) do
			if notif.gui == screenGui then
				table.remove(activeNotifications, i)
				break
			end
		end
		
		-- Reposition remaining notifications
		for i, notif in ipairs(activeNotifications) do
			local newY = 20 + ((i - 1) * 120)
			local reposTween = game:GetService("TweenService"):Create(
				notif.container,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Position = UDim2.new(1, -370, 0, newY)}
			)
			reposTween:Play()
		end
	end)
end

-- ========== HELPER FUNCTIONS ==========

function NotificationSystem:ShowSuccess(message, duration)
	self:Show(message, "success", duration or 2.5)
end

function NotificationSystem:ShowError(message, duration)
	self:Show(message, "error", duration or 3)
end

function NotificationSystem:ShowWarning(message, duration)
	self:Show(message, "warning", duration or 3)
end

function NotificationSystem:ShowInfo(message, duration)
	self:Show(message, "info", duration or 2.5)
end

function NotificationSystem:ShowMoney(amount, isDelta, duration)
	local message = isDelta and ("💰 +" .. string.format("%d", amount)) or ("💰 $" .. string.format("%d", amount))
	self:Show(message, "money", duration or 2)
end

function NotificationSystem:ShowBid(bidder, amount, duration)
	local message = bidder .. " bid $" .. string.format("%d", amount)
	self:Show(message, "bid", duration or 1.5)
end

function NotificationSystem:ShowItem(itemName, action, duration)
	local message = action .. " " .. itemName
	self:Show(message, "item", duration or 2)
end

function NotificationSystem:ClearAll()
	for _, notif in ipairs(activeNotifications) do
		notif.gui:Destroy()
	end
	activeNotifications = {}
end

return NotificationSystem
