-- ========================================
-- TUTORIAL SYSTEM - Interactive Tutorial
-- ========================================

local TutorialSystem = {}
local Theme = require(game.ReplicatedStorage.Modules.UI.Theme)
local UIHelper = require(game.ReplicatedStorage.Modules.UI.Utilities.UIHelper)
local AnimationController = require(game.ReplicatedStorage.Modules.UI.Utilities.AnimationController)

local tutorialActive = false
local tutorialStep = 1

-- ========== CREATE TUTORIAL ==========
function TutorialSystem:Start(mainLobbyGui)
	if tutorialActive then return end
	tutorialActive = true
	
	local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Tutorial overlay
	local overlay = Instance.new("Frame")
	overlay.Name = "TutorialOverlay"
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.ZIndex = 200
	overlay.Parent = playerGui
	
	-- Cursor guide (animated pointer)
	local cursorGuide = UIHelper:CreateRoundedFrame(overlay, {
		BackgroundColor3 = Theme.Colors.Primary,
		BackgroundTransparency = 0,
		Size = UDim2.new(0, 60, 0, 60),
		CornerRadius = UDim.new(0, 30),
	})
	cursorGuide.ZIndex = 201
	
	-- Glow effect on cursor
	local glow = Instance.new("UIStroke")
	glow.Color = Theme.Colors.Primary
	glow.Thickness = 3
	glow.Transparency = 0.3
	glow.Parent = cursorGuide
	
	-- Tutorial text
	local tutorialText = UIHelper:CreateTextLabel(overlay, {
		Text = "Click on the BID button!",
		TextColor3 = Theme.Colors.TextPrimary,
		Font = Theme.Fonts.Heading.Font,
		TextSize = 28,
		Size = UDim2.new(0.6, 0, 0, 100),
		Position = UDim2.new(0.2, 0, 0, 100),
	})
	tutorialText.TextWrapped = true
	tutorialText.ZIndex = 201
	
	-- Helper arrow
	local arrow = UIHelper:CreateTextLabel(overlay, {
		Text = "👇",
		Font = Theme.Fonts.Heading.Font,
		TextSize = 60,
		Size = UDim2.new(0, 80, 0, 80),
		Position = UDim2.new(0, 0, 0, 0),
	})
	arrow.ZIndex = 201
	
	local function moveCursorToBidButton()
		-- Find BID button in main lobby
		local mainLobby = playerGui:FindFirstChild("MainLobby")
		if not mainLobby then return end
		
		local bidButton = mainLobby:FindFirstChild("BidButton")
		if not bidButton then return end
		
		-- Animate cursor to BID button
		local targetPos = bidButton.AbsolutePosition + (bidButton.AbsoluteSize / 2) - (cursorGuide.AbsoluteSize / 2)
		tutorialText.Text = "Click on the BID button!"
		
		AnimationController:MoveTo(cursorGuide, UDim2.new(0, targetPos.X, 0, targetPos.Y), 1.5)
		AnimationController:MoveTo(arrow, UDim2.new(0, targetPos.X - 40, 0, targetPos.Y - 100), 1.5)
		
		-- Make button pulse
		local pulseLoop = coroutine.create(function()
			while tutorialActive and tutorialStep == 1 do
				AnimationController:Pulse(bidButton, Theme.Animations.Normal)
				wait(Theme.Animations.Normal + 0.2)
			end
		end)
		coroutine.resume(pulseLoop)
		
		-- Wait for click
		bidButton.MouseButton1Click:Connect(function()
			if tutorialStep == 1 then
				utorialStep = 2
				moveCursorToTierButton()
		end
		end)
	end
	
	local function moveCursorToTierButton()
		local mainLobby = playerGui:FindFirstChild("MainLobby")
		if not mainLobby then return end
		
		local tiersContainer = mainLobby:FindFirstChild("TiersContainer")
		if not tiersContainer then return end
		
		local beginnerTier = tiersContainer:FindFirstChild("BeginnerTier")
		if not beginnerTier then return end
		
		-- Animate cursor to Beginner tier
		local targetPos = beginnerTier.AbsolutePosition + (beginnerTier.AbsoluteSize / 2) - (cursorGuide.AbsoluteSize / 2)
		tutorialText.Text = "Now click on the BEGINNER tier ($200)!"
		
		AnimationController:MoveTo(cursorGuide, UDim2.new(0, targetPos.X, 0, targetPos.Y), 1.5)
		AnimationController:MoveTo(arrow, UDim2.new(0, targetPos.X - 40, 0, targetPos.Y - 100), 1.5)
		
		-- Make tier pulse
		local pulseLoop = coroutine.create(function()
			while tutorialActive and tutorialStep == 2 do
				AnimationController:Pulse(beginnerTier, Theme.Animations.Normal)
				wait(Theme.Animations.Normal + 0.2)
		end
		end)
		coroutine.resume(pulseLoop)
		
		-- Wait for click
		beginnerTier.MouseButton1Click:Connect(function()
			if tutorialStep == 2 then
				utorialActive = false
				self:End(overlay)
		end
		end)
	end
	
	-- Start tutorial
	wait(0.5)
	moveCursorToBidButton()
end

-- ========== END TUTORIAL ==========
function TutorialSystem:End(overlay)
	AnimationController:FadeOut(overlay, Theme.Animations.Normal)
	
	wait(Theme.Animations.Normal)
	overlay:Destroy()
	
	-- Unlock all buttons in main lobby
	local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	local mainLobby = playerGui:FindFirstChild("MainLobby")
	
	if mainLobby then
		local topButtons = mainLobby:FindFirstChild("TopButtons")
		local bottomButtons = mainLobby:FindFirstChild("BottomButtons")
		
		if topButtons then
			for _, button in ipairs(topButtons:GetChildren()) do
				if button:IsA("Frame") then
					button.Active = true
				end
			end
		end
		
		if bottomButtons then
			for _, button in ipairs(bottomButtons:GetChildren()) do
				if button:IsA("Frame") then
					button.Active = true
				end
			end
		end
	end
end

return TutorialSystem