local function BuildToolsTab(parentFrame)
	local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 10)
	local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)

	-- [1] AMBIL DATA AWAL
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	
	-- Variabel Konfigurasi
	local ToolsConfig = {
		Speed = { Active = false, Value = hum.WalkSpeed }, 
		TPWalk = { Active = false, Value = 0.5 }, 
		Jump = { Active = false, Value = hum.JumpPower }, 
		StateForce = { Active = false } 
	}

	-- [2] ENGINE UTAMA (UPDATED FOR MOBILE)
	local ToolLoop, JumpRequestConn, MobileJumpConn

	local function StartToolEngine()
		if ToolLoop then return end
		
		-- A. LOOP FRAME (RenderStepped)
		ToolLoop = RunService.RenderStepped:Connect(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChild("Humanoid")
			local root = char and char:FindFirstChild("HumanoidRootPart")

			if hum and root then
				-- Force Jump Values
				if ToolsConfig.Jump.Active then
					if hum.JumpPower ~= ToolsConfig.Jump.Value then hum.JumpPower = ToolsConfig.Jump.Value end
					if not hum.UseJumpPower then hum.UseJumpPower = true end
				end

				-- Force Speed
				if ToolsConfig.Speed.Active and not ToolsConfig.TPWalk.Active then
					if hum.WalkSpeed ~= ToolsConfig.Speed.Value then hum.WalkSpeed = ToolsConfig.Speed.Value end
				end

				-- TP Walk
				if ToolsConfig.TPWalk.Active then
					if hum.MoveDirection.Magnitude > 0 then
						root.CFrame = root.CFrame + (hum.MoveDirection * (ToolsConfig.TPWalk.Value * 0.2))
					end
				end
				
				-- Force Saklar
				if ToolsConfig.StateForce.Active then
					hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
				end
			end
		end)

		-- B. JUMP TRIGGER 1: PC (SPASI)
		JumpRequestConn = UserInputService.JumpRequest:Connect(function()
			if ToolsConfig.Jump.Active then
				local char = LocalPlayer.Character; local hum = char and char:FindFirstChild("Humanoid")
				if hum and hum.FloorMaterial ~= Enum.Material.Air then
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end
		end)
		
		-- C. JUMP TRIGGER 2: MOBILE (TOMBOL LAYAR) - [FIX]
		-- Kita memantau properti .Jump pada Humanoid.
		-- Saat tombol layar ditekan, .Jump menjadi true. Kita tangkap momen itu.
		local function SetupMobileJump(character)
			local h = character:WaitForChild("Humanoid", 10)
			if h then
				if MobileJumpConn then MobileJumpConn:Disconnect() end
				MobileJumpConn = h:GetPropertyChangedSignal("Jump"):Connect(function()
					if h.Jump and ToolsConfig.Jump.Active then
						-- Cek tanah agar tidak infinity jump
						if h.FloorMaterial ~= Enum.Material.Air then
							h:ChangeState(Enum.HumanoidStateType.Jumping)
						end
					end
				end)
			end
		end
		
		-- Setup awal & saat respawn
		if LocalPlayer.Character then SetupMobileJump(LocalPlayer.Character) end
		LocalPlayer.CharacterAdded:Connect(SetupMobileJump)
	end
	StartToolEngine()


	-- [3] UI BUILDER (SAMA SEPERTI SEBELUMNYA)
	local ForceSection = CreateExpandableSection(parentFrame, "Force Movement Control")
	local MainCard = CreateCard(ForceSection, UDim2.new(1, 0, 0, 0), 0); MainCard.AutomaticSize = Enum.AutomaticSize.Y
	local CardLayout = Instance.new("UIListLayout"); CardLayout.Parent = MainCard; CardLayout.SortOrder = Enum.SortOrder.LayoutOrder; CardLayout.Padding = UDim.new(0, 8); CardLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local CardPad = Instance.new("UIPadding"); CardPad.Parent = MainCard; CardPad.PaddingTop = UDim.new(0, 10); CardPad.PaddingBottom = UDim.new(0, 10); CardPad.PaddingLeft = UDim.new(0, 10); CardPad.PaddingRight = UDim.new(0, 10)

	-- Info Dashboard
	local InfoRow = Instance.new("Frame"); InfoRow.Parent = MainCard; InfoRow.BackgroundTransparency = 1; InfoRow.Size = UDim2.new(1, 0, 0, 40); InfoRow.LayoutOrder = 1
	local InfoLayout = Instance.new("UIListLayout"); InfoLayout.Parent = InfoRow; InfoLayout.FillDirection = Enum.FillDirection.Horizontal; InfoLayout.Padding = UDim.new(0, 5)
	local function CreateInfoBox(title, defaultText)
		local Box = Instance.new("Frame"); Box.Parent = InfoRow; Box.BackgroundColor3 = Theme.Main; Box.BackgroundTransparency = 0.3; Box.Size = UDim2.new(0.32, 0, 1, 0); Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
		local T = Instance.new("TextLabel"); T.Parent = Box; T.Text = title; T.Size = UDim2.new(1,0,0.4,0); T.BackgroundTransparency = 1; T.TextColor3 = Theme.TextDim; T.Font = Theme.FontMain; T.TextSize = 9
		local V = Instance.new("TextLabel"); V.Parent = Box; V.Text = defaultText; V.Size = UDim2.new(1,0,0.6,0); V.Position = UDim2.new(0,0,0.4,0); V.BackgroundTransparency = 1; V.TextColor3 = Theme.Accent; V.Font = Theme.FontBold; V.TextSize = 11
		return V
	end
	local SpeedInfo = CreateInfoBox("REAL SPEED", tostring(hum.WalkSpeed))
	local JumpInfo = CreateInfoBox("REAL JUMP", tostring(hum.JumpPower))
	local StateInfo = CreateInfoBox("JUMP SAKLAR", "Checking...")

	-- Control Helper
	local function CreateRow(title, defaultNum, step, min, max, onToggle, onValChange)
		local Row = Instance.new("Frame"); Row.Parent = MainCard; Row.BackgroundColor3 = Theme.Sidebar; Row.BackgroundTransparency = 0.5; Row.Size = UDim2.new(1, 0, 0, 35); Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6); Row.LayoutOrder = 2
		local Lbl = Instance.new("TextLabel"); Lbl.Parent = Row; Lbl.Text = title; Lbl.Position = UDim2.new(0, 10, 0, 0); Lbl.Size = UDim2.new(0.35, 0, 1, 0); Lbl.Font = Theme.FontBold; Lbl.TextColor3 = Theme.Text; Lbl.TextSize = 10; Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Left
		local Ctrl = Instance.new("Frame"); Ctrl.Parent = Row; Ctrl.Position = UDim2.new(0.4, 0, 0.15, 0); Ctrl.Size = UDim2.new(0.35, 0, 0.7, 0); Ctrl.BackgroundTransparency = 1
		local MinBtn = Instance.new("TextButton"); MinBtn.Parent = Ctrl; MinBtn.Text = "-"; MinBtn.Size = UDim2.new(0, 20, 1, 0); MinBtn.BackgroundColor3 = Theme.Main; MinBtn.TextColor3 = Theme.Red; MinBtn.Font = Theme.FontBold; Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)
		local PlusBtn = Instance.new("TextButton"); PlusBtn.Parent = Ctrl; PlusBtn.Text = "+"; PlusBtn.Position = UDim2.new(1, -20, 0, 0); PlusBtn.Size = UDim2.new(0, 20, 1, 0); PlusBtn.BackgroundColor3 = Theme.Main; PlusBtn.TextColor3 = Theme.Green; PlusBtn.Font = Theme.FontBold; Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 4)
		local ValLbl = Instance.new("TextLabel"); ValLbl.Parent = Ctrl; ValLbl.Text = tostring(defaultNum); ValLbl.Size = UDim2.new(1, -40, 1, 0); ValLbl.Position = UDim2.new(0, 20, 0, 0); ValLbl.BackgroundTransparency = 1; ValLbl.TextColor3 = Theme.Text; ValLbl.Font = Theme.FontBold; ValLbl.TextSize = 11
		local currentVal = defaultNum; if step < 1 then ValLbl.Text = string.format("%.1f", currentVal) end
		MinBtn.MouseButton1Click:Connect(function() currentVal = math.max(min, currentVal - step); if step < 1 then ValLbl.Text = string.format("%.1f", currentVal) else ValLbl.Text = tostring(currentVal) end; onValChange(currentVal) end)
		PlusBtn.MouseButton1Click:Connect(function() currentVal = math.min(max, currentVal + step); if step < 1 then ValLbl.Text = string.format("%.1f", currentVal) else ValLbl.Text = tostring(currentVal) end; onValChange(currentVal) end)
		local Tog = Instance.new("TextButton"); Tog.Parent = Row; Tog.Position = UDim2.new(0.8, 0, 0.15, 0); Tog.Size = UDim2.new(0.18, 0, 0.7, 0); Tog.BackgroundColor3 = Theme.Main; Tog.Text = "OFF"; Tog.TextColor3 = Theme.TextDim; Tog.Font = Theme.FontBold; Tog.TextSize = 10; Instance.new("UICorner", Tog).CornerRadius = UDim.new(0, 4)
		local active = false
		local function SetState(state) active = state; if active then Tog.BackgroundColor3 = Theme.Accent; Tog.Text = "ON"; Tog.TextColor3 = Theme.Main else Tog.BackgroundColor3 = Theme.Main; Tog.Text = "OFF"; Tog.TextColor3 = Theme.TextDim end; onToggle(active) end
		Tog.MouseButton1Click:Connect(function() SetState(not active) end)
		return { SetState = SetState }
	end

	local ForceSpeedCtrl, TPWalkCtrl
	ForceSpeedCtrl = CreateRow("Force Speed", ToolsConfig.Speed.Value, 5, 1, 500, function(active) ToolsConfig.Speed.Active = active; if active and TPWalkCtrl then TPWalkCtrl.SetState(false) end end, function(val) ToolsConfig.Speed.Value = val end)
	TPWalkCtrl = CreateRow("TP Walk (Bypass)", 0.5, 0.1, 0.1, 5.0, function(active) ToolsConfig.TPWalk.Active = active; if active and ForceSpeedCtrl then ForceSpeedCtrl.SetState(false) end end, function(val) ToolsConfig.TPWalk.Value = val end)
	CreateRow("Force Jump", ToolsConfig.Jump.Value, 10, 0, 500, function(active) ToolsConfig.Jump.Active = active end, function(val) ToolsConfig.Jump.Value = val end)

	local FixBtn = Instance.new("TextButton"); FixBtn.Parent = MainCard; FixBtn.LayoutOrder = 5; FixBtn.Size = UDim2.new(1, 0, 0, 30); FixBtn.BackgroundColor3 = Theme.Red; FixBtn.Font = Enum.Font.GothamBold; FixBtn.Text = "⚠️ SAKLAR LOMPAT MATI - KLIK UNTUK AKTIFKAN! ⚠️"; FixBtn.TextColor3 = Color3.new(1,1,1); FixBtn.TextSize = 10; FixBtn.Visible = false; Instance.new("UICorner", FixBtn).CornerRadius = UDim.new(0, 6)
	local AnimStroke = Instance.new("UIStroke"); AnimStroke.Parent = FixBtn; AnimStroke.Color = Color3.new(1,1,1); AnimStroke.Thickness = 1; AnimStroke.Transparency = 0.5
	task.spawn(function() while parentFrame.Parent do if FixBtn.Visible then TweenService:Create(AnimStroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0}):Play() end; task.wait(1) end end)
	FixBtn.MouseButton1Click:Connect(function() ToolsConfig.StateForce.Active = true; local char = LocalPlayer.Character; local hum = char and char:FindFirstChild("Humanoid"); if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end; FixBtn.Text = "MEMPERBAIKI..."; task.wait(0.5) end)

	task.spawn(function()
		while parentFrame.Parent do
			local char = LocalPlayer.Character; local hum = char and char:FindFirstChild("Humanoid")
			if hum then
				SpeedInfo.Text = tostring(math.floor(hum.WalkSpeed)); JumpInfo.Text = tostring(math.floor(hum.JumpPower))
				if hum:GetStateEnabled(Enum.HumanoidStateType.Jumping) then StateInfo.Text = "ACTIVE"; StateInfo.TextColor3 = Theme.Green; FixBtn.Visible = false
				else StateInfo.Text = "DISABLED"; StateInfo.TextColor3 = Theme.Red; FixBtn.Visible = true end
			end
			task.wait(0.2)
		end
	end)
end
