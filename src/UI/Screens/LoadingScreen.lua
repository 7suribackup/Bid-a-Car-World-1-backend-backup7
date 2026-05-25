-- ========================================
-- LOADING SCREEN - Game Startup
-- ========================================

local LoadingScreen = {}
local Theme = require(game.ReplicatedStorage.Modules.UI.Theme)
local UIHelper = require(game.ReplicatedStorage.Modules.UI.Utilities.UIHelper)
local AnimationController = require(game.ReplicatedStorage.Modules.UI.Utilities.AnimationController)

-- ========== CREATE LOADING SCREEN ==========
function LoadingScreen:Create(callback)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LoadingScreen"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndex = 100
	screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Background
	local background = UIHelper:CreateRoundedFrame(screenGui, {
		BackgroundColor3 = Theme.Colors.Background,
		BackgroundTransparency = 0,
		Size = UDim2.new(1, 0, 1, 0),
	})
	
	-- Container
	local container = UIHelper:CreateRoundedFrame(background, {
		BackgroundColor3 = Theme.Colors.BackgroundTertiary,
		BackgroundTransparency = 0.1,
		Size = UDim2.new(0, 600, 0, 400),
		Position = UDim2.new(0.5, -300, 0.5, -200),
		CornerRadius = UDim.new(0, 20),
		Padding = UDim.new(0, 20),
	})
	
	UIHelper:AddStroke(container, Theme.Colors.Primary, 2, 0.3)
	
	-- Logo/Title placeholder
	local logoText = UIHelper:CreateTextLabel(container, {
		Text = "BID A CAR WORLD 1",
		TextColor3 = Theme.Colors.Primary,
		Font = Theme.Fonts.Title.Font,
		TextSize = 36,
		Size = UDim2.new(1, 0, 0, 80),
		Position = UDim2.new(0, 0, 0, 20),
	})
	logoText.TextScaled = true
	logoText.Parent = container
	
	-- Progress bar background
	local progressBarBg = UIHelper:CreateRoundedFrame(container, {
		BackgroundColor3 = Theme.Colors.BackgroundSecondary,
		BackgroundTransparency = 0,
		Size = UDim2.new(0.8, 0, 0, 20),
		Position = UDim2.new(0.1, 0, 0, 150),
		CornerRadius = UDim.new(0, 10),
	})
	progressBarBg.Parent = container
	
	-- Progress bar fill
	local progressBar = UIHelper:CreateRoundedFrame(progressBarBg, {
		BackgroundColor3 = Theme.Colors.Primary,
		BackgroundTransparency = 0,
		Size = UDim2.new(0, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		CornerRadius = UDim.new(0, 10),
	})
	
	-- Progress text
	local progressText = UIHelper:CreateTextLabel(container, {
		Text = "0%",
		TextColor3 = Theme.Colors.TextSecondary,
		Font = Theme.Fonts.Body.Font,
		TextSize = 14,
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.new(0, 0, 0, 180),
	})
	progressText.Parent = container
	
	-- Status text
	local statusText = UIHelper:CreateTextLabel(container, {
		Text = "Loading game...",
		TextColor3 = Theme.Colors.TextSecondary,
		Font = Theme.Fonts.BodySmall.Font,
		TextSize = 12,
		Size = UDim2.new(1, 0, 0, 50),
		Position = UDim2.new(0, 0, 0, 220),
	})
	statusText.TextWrapped = true
	statusText.Parent = container
	
	-- Animate progress bar
	local progress = 0
	local updateProgress = function(newProgress, message)
		progress = math.min(newProgress, 100)
		progressBar.Size = UDim2.new(progress / 100, 0, 1, 0)
		progressText.Text = progress .. "%"
		if message then
			statusText.Text = message
		end
	end
	
	-- Simulate loading (replace with actual asset loading)
	local loadingCoroutine = coroutine.create(function()
		for i = 1, 100 do
			updateProgress(i, "Loading assets... " .. i .. "%")
			wait(0.02)
		end
		
		wait(0.5)
		
		-- Fade out
		AnimationController:FadeOut(background, Theme.Animations.Normal)
		
		wait(Theme.Animations.Normal)
		screenGui:Destroy()
		
		if callback then
			callback()
		end
	end)
	
	coroutine.resume(loadingCoroutine)
	
	return screenGui
end

return LoadingScreen