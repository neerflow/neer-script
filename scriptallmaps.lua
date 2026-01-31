local function BuildTeleportTab(parentFrame)
	local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 10)
	local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)
	
	local ColorSuccess = Theme.Green; local ColorError = Theme.Red
	local selectedPlayer = nil; local isDropdownOpen = false; local statusTimer = nil; local spectateLoop = nil; local clickOutsideConn = nil

	-- Card Size
	local TpCard = CreateCard(parentFrame, UDim2.new(1, 0, 0, 165))
	TpCard.ClipsDescendants = false; TpCard.LayoutOrder = 1; TpCard.ZIndex = 10 

	local Title = Instance.new("TextLabel"); Title.Parent = TpCard; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 15, 0, 10); Title.Size = UDim2.new(1, -30, 0, 15); Title.Font = Theme.FontBold; Title.Text = "Player Teleport & Follow"; Title.TextColor3 = Theme.Text; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left
	
	-- Status Label
	local StatusLbl = Instance.new("TextLabel"); StatusLbl.Parent = TpCard; StatusLbl.BackgroundTransparency = 1; StatusLbl.Position = UDim2.new(0, 15, 1, -22); StatusLbl.Size = UDim2.new(1, -30, 0, 15); StatusLbl.Font = Theme.FontMain; StatusLbl.Text = ""; StatusLbl.TextColor3 = ColorError; StatusLbl.TextSize = 11; StatusLbl.TextXAlignment = Enum.TextXAlignment.Center
	local function ShowStatus(text, color) StatusLbl.Text = text; StatusLbl.TextColor3 = color or Theme.Text; if statusTimer then task.cancel(statusTimer) end; statusTimer = task.delay(3, function() if StatusLbl then StatusLbl.Text = "" end statusTimer = nil end) end

	-- Dropdown Container
	local DropContainer = Instance.new("Frame"); DropContainer.Parent = TpCard; DropContainer.BackgroundTransparency = 1; DropContainer.Position = UDim2.new(0, 15, 0, 35); DropContainer.Size = UDim2.new(1, -30, 0, 30); DropContainer.ZIndex = 20
	local DropBtn = Instance.new("TextButton"); DropBtn.Parent = DropContainer; DropBtn.BackgroundColor3 = Theme.Sidebar; DropBtn.Size = UDim2.new(1, -75, 1, 0); DropBtn.Font = Theme.FontMain; DropBtn.Text = "  Select Player..."; DropBtn.TextColor3 = Theme.TextDim; DropBtn.TextSize = 12; DropBtn.TextXAlignment = Enum.TextXAlignment.Left; DropBtn.AutoButtonColor = false; DropBtn.ZIndex = 20; Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 6); local DS = Instance.new("UIStroke"); DS.Parent = DropBtn; DS.Color = Theme.Separator; DS.Thickness = 1
	local RefreshBtn = Instance.new("TextButton"); RefreshBtn.Parent = DropContainer; RefreshBtn.BackgroundColor3 = Theme.Green; RefreshBtn.Position = UDim2.new(1, -70, 0, 0); RefreshBtn.Size = UDim2.new(0, 70, 1, 0); RefreshBtn.ZIndex = 20; RefreshBtn.Font = Theme.FontBold; RefreshBtn.Text = "REFRESH"; RefreshBtn.TextColor3 = Theme.Main; RefreshBtn.TextSize = 11; Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 6)
	
	-- Dropdown List
	local ListFrame = Instance.new("ScrollingFrame"); ListFrame.Parent = TpCard; ListFrame.Visible = false; ListFrame.BackgroundColor3 = Theme.Sidebar; ListFrame.BorderSizePixel = 0; ListFrame.Position = UDim2.new(0, 15, 0, 68); ListFrame.Size = UDim2.new(0.90, -65, 0, 120); ListFrame.ZIndex = 30; ListFrame.ScrollBarThickness = 2; local LS = Instance.new("UIStroke"); LS.Parent = ListFrame; LS.Color = Theme.Accent; LS.Thickness = 1; local LL = Instance.new("UIListLayout"); LL.Parent = ListFrame; LL.SortOrder = Enum.SortOrder.LayoutOrder

	local function ToggleDropdown(forceClose)
		if forceClose then isDropdownOpen = false else isDropdownOpen = not isDropdownOpen end; ListFrame.Visible = isDropdownOpen; if clickOutsideConn then clickOutsideConn:Disconnect(); clickOutsideConn = nil end
		if isDropdownOpen then clickOutsideConn = UserInputService.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local mPos = Vector2.new(input.Position.X, input.Position.Y); local function isInRect(obj) local pos, size = obj.AbsolutePosition, obj.AbsoluteSize; return mPos.X >= pos.X and mPos.X <= pos.X + size.X and mPos.Y >= pos.Y and mPos.Y <= pos.Y + size.Y end; if not isInRect(ListFrame) and not isInRect(DropBtn) then ToggleDropdown(true) end end end) end
	end
	
	local function RefreshList()
		for _, v in pairs(ListFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				local PBtn = Instance.new("TextButton"); PBtn.Parent = ListFrame; PBtn.BackgroundColor3 = Theme.Main; PBtn.Size = UDim2.new(1, 0, 0, 25); PBtn.Font = Theme.FontMain; PBtn.TextSize = 12; PBtn.TextXAlignment = Enum.TextXAlignment.Left; PBtn.AutoButtonColor = true; PBtn.ZIndex = 31; local labelText = "  " .. p.DisplayName .. " (@" .. p.Name .. ")"; PBtn.Text = labelText; PBtn.TextColor3 = Theme.TextDim
				PBtn.MouseButton1Click:Connect(function() selectedPlayer = p; DropBtn.Text = labelText; DropBtn.TextColor3 = Theme.Text; ToggleDropdown(true) end)
			end
		end
		ListFrame.CanvasSize = UDim2.new(0, 0, 0, LL.AbsoluteContentSize.Y)
	end
	DropBtn.MouseButton1Click:Connect(function() ToggleDropdown() end); RefreshBtn.MouseButton1Click:Connect(function() RefreshList(); ShowStatus("List Refreshed!", ColorSuccess) end)

	-- [ACTION BUTTONS]
	local BtnContainer = Instance.new("Frame"); BtnContainer.Parent = TpCard; BtnContainer.BackgroundTransparency = 1; BtnContainer.Position = UDim2.new(0, 15, 0, 75); BtnContainer.Size = UDim2.new(1, -30, 0, 60)
	
	-- Helper untuk membuat tombol seragam (Standard Style: Sidebar Color + Separator Stroke)
	local function CreateStandardButton(name, pos, size)
		local Btn = Instance.new("TextButton"); Btn.Parent = BtnContainer
		Btn.BackgroundColor3 = Theme.Sidebar -- Base Color (Sama semua)
		Btn.Position = pos; Btn.Size = size
		Btn.Font = Theme.FontBold; Btn.Text = name; Btn.TextColor3 = Theme.TextDim; Btn.TextSize = 10
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
		local S = Instance.new("UIStroke"); S.Parent = Btn; S.Color = Theme.Separator; S.Thickness = 1
		return Btn, S
	end

	-- Baris 1: Spectate & Teleport (SEKARANG KEMBAR)
	local SpectateBtn, SS = CreateStandardButton("SPECTATE", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 0, 28))
	local TeleportBtn, TS = CreateStandardButton("TELEPORT", UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 0, 28))
	
	-- Baris 2: Follow
	local FollowBtn, FS = CreateStandardButton("FOLLOW PLAYER (SIMPLE)", UDim2.new(0, 0, 0, 35), UDim2.new(1, 0, 0, 28))

	-- LOGIKA SPECTATE
	local function StopSpectate()
		if spectateLoop then spectateLoop:Disconnect(); spectateLoop = nil end
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid end
		-- Balik ke Style Standard
		SpectateBtn.BackgroundColor3 = Theme.Sidebar; SpectateBtn.TextColor3 = Theme.TextDim; SpectateBtn.Text = "SPECTATE"; SS.Color = Theme.Separator
	end
	SpectateBtn.MouseButton1Click:Connect(function()
		if spectateLoop then StopSpectate() else
			if not selectedPlayer then ShowStatus("Select Player First!", ColorError); return end
			local target = Players:FindFirstChild(selectedPlayer.Name)
			if target then
				-- Style AKTIF (Main + Accent)
				SpectateBtn.BackgroundColor3 = Theme.Main; SpectateBtn.TextColor3 = Theme.Accent; SpectateBtn.Text = "STOP VIEW"; SS.Color = Theme.Accent; ShowStatus("Viewing Target", ColorSuccess)
				spectateLoop = RunService.RenderStepped:Connect(function() if not target or not target.Parent then StopSpectate(); ShowStatus("Target Left", ColorError); return end; if target.Character and target.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = target.Character.Humanoid end end)
			else ShowStatus("Player Unavailable", ColorError) end
		end
	end)

	-- LOGIKA TELEPORT
	TeleportBtn.MouseButton1Click:Connect(function()
		if not selectedPlayer then ShowStatus("Select a player!", ColorError); return end
		local target = Players:FindFirstChild(selectedPlayer.Name); if not target then ShowStatus("Player Left.", ColorError); return end
		local tChar = target.Character; local lChar = LocalPlayer.Character
		
		-- Animasi Klik Sesaat
		TeleportBtn.BackgroundColor3 = Theme.Accent; TeleportBtn.TextColor3 = Theme.Main; TS.Color = Theme.Accent
		task.delay(0.15, function() 
			-- Balik ke Standard
			TeleportBtn.BackgroundColor3 = Theme.Sidebar; TeleportBtn.TextColor3 = Theme.TextDim; TS.Color = Theme.Separator 
		end)

		if tChar and tChar:FindFirstChild("HumanoidRootPart") and lChar and lChar:FindFirstChild("HumanoidRootPart") then 
			lChar.HumanoidRootPart.CFrame = tChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
			ShowStatus("Teleported!", ColorSuccess) 
		else ShowStatus("Target Unreachable", ColorError) end
	end)

	-- LOGIKA SIMPLE FOLLOW
	local followLoop = nil
	local function StopFollow()
		if followLoop then followLoop:Disconnect(); followLoop = nil end
		-- Balik ke Style Standard
		FollowBtn.BackgroundColor3 = Theme.Sidebar; FollowBtn.TextColor3 = Theme.TextDim; FollowBtn.Text = "FOLLOW PLAYER (SIMPLE)"; FS.Color = Theme.Separator
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then char.Humanoid:MoveTo(char.HumanoidRootPart.Position) end 
	end

	FollowBtn.MouseButton1Click:Connect(function()
		if followLoop then StopFollow() else
			if not selectedPlayer then ShowStatus("Select Player First!", ColorError); return end
			
			-- Style AKTIF (Main + Accent)
			FollowBtn.BackgroundColor3 = Theme.Main; FollowBtn.TextColor3 = Theme.Accent; FollowBtn.Text = "STOP FOLLOWING"; FS.Color = Theme.Accent
			ShowStatus("Following...", ColorSuccess)
			
			followLoop = RunService.Stepped:Connect(function()
				local target = Players:FindFirstChild(selectedPlayer.Name)
				local myChar = LocalPlayer.Character
				
				if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then StopFollow(); ShowStatus("Target Lost", ColorError); return end
				if not myChar or not myChar:FindFirstChild("HumanoidRootPart") or not myChar:FindFirstChild("Humanoid") then return end
				
				local myRoot = myChar.HumanoidRootPart; local targetRoot = target.Character.HumanoidRootPart; local hum = myChar.Humanoid
				local dist = (myRoot.Position - targetRoot.Position).Magnitude
				
				if dist > 6 then 
					hum:MoveTo(targetRoot.Position)
					if (targetRoot.Position.Y > myRoot.Position.Y + 3) and dist < 15 then hum.Jump = true end
				else hum:MoveTo(myRoot.Position) end
			end)
		end
	end)

	-- Tap Teleport Switch
	local tapConnection
	local TapSwitch = CreateMainSwitch(parentFrame, "Teleport Tap (Click / Touch)", function(active)
		if active then
			tapConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					local mouse = LocalPlayer:GetMouse(); local targetPos = mouse.Hit; local char = LocalPlayer.Character
					if char and char:FindFirstChild("HumanoidRootPart") and targetPos then char.HumanoidRootPart.CFrame = CFrame.new(targetPos.X, targetPos.Y + 3, targetPos.Z) end
				end
			end)
		else if tapConnection then tapConnection:Disconnect(); tapConnection = nil end end
	end)
	if TapSwitch.Card then TapSwitch.Card.LayoutOrder = 2; TapSwitch.Card.ZIndex = 1 end
	
	RefreshList()
end
