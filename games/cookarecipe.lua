return function(parentFrame, API)
	local Theme = API.Theme
	local CreateFeatureCard = API.CreateFeatureCard
	local AttachSwitch = API.AttachSwitch
	local CreateExpandableSection = API.CreateExpandableSection

	local RS = game:GetService("ReplicatedStorage")
	local Remotes = RS:WaitForChild("Remotes")
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local Zones = workspace:WaitForChild("Zones")

	local R = {
		HarvestSeed    = Remotes:WaitForChild("HarvestSeedEvent"),
		PlantSeed      = Remotes:WaitForChild("PlantSeedEvent"),
		DecoHarvest    = Remotes:WaitForChild("DecorationHarvestEvent"),
		ApplePickup    = Remotes:WaitForChild("ApplePickupEvent"),
		HarvestAnimal  = Remotes:WaitForChild("HarvestAnimalEvent"),
		HarvestFish    = Remotes:WaitForChild("HarvestFishEvent"),
		SpawnAnimal    = Remotes:WaitForChild("SpawnAnimalEvent"),
		SpawnFish      = Remotes:WaitForChild("SpawnFishEvent"),
		GetAnimalSpace = Remotes:WaitForChild("GetAnimalSpace"),
		GetFishSpace   = Remotes:WaitForChild("GetFishSpace"),
		GetPlayerZone  = Remotes:WaitForChild("GetPlayerZone"),
	}

	local ANIMALS = {"chicken","piggy","lamb","cow","bull","icecube","unicorn","duck","goose","rabbit","goat","turkey","glimblob","mossling","spicedragon"}
	local FISH    = {"nemo","reeffish","quabble","bluequabble","flatfish","shark","blueshark","crab","pufferfish","hermitfish","bluetang","anglerfish","pearlspirit","abyssglider","reefgolem"}
	local SEEDS   = {"carrot","tomato","alien_plant","golden_plant","mythic_plant","brocolli_plant","cabbage_plant","leek_plant","couliflower_plant","paprika_plant","glowleaf_plant","sunmelon_plant","voidberry_plant"}

	local state   = {}
	local threads = {}
	local conns   = {shroom={}, tree={}, animal={}, fish={}}

	local selectedSeed   = SEEDS[1]
	local selectedAnimal = ANIMALS[1]
	local selectedFish   = FISH[1]
	local eggJoined      = false

	-- ========================
	-- ZONE DETECTION
	-- ========================
	local myZoneId   = nil
	local myZoneFolder = nil

	local function refreshMyZone()
		local ok, zoneId = pcall(function()
			return R.GetPlayerZone:InvokeServer()
		end)
		if ok and zoneId then
			myZoneId = tostring(zoneId)
			myZoneFolder = Zones:FindFirstChild("Zone_" .. myZoneId)
		end
	end

	-- Ambil zone saat init
	refreshMyZone()

	local function getMyZone()
		if not myZoneFolder or not myZoneFolder.Parent then
			refreshMyZone()
		end
		return myZoneFolder
	end

	-- ========================
	-- HELPERS
	-- ========================
	local function getMyPlots()
		local plots = {}
		local myId = tostring(player.UserId)
		for _, zone in ipairs(Zones:GetChildren()) do
			local cp = zone:FindFirstChild("Garden") and zone.Garden:FindFirstChild("CropPlots")
			if cp then
				for _, plot in ipairs(cp:GetChildren()) do
					if tostring(plot:GetAttribute("OwnerUserId")) == myId then
						table.insert(plots, plot)
					end
				end
			end
		end
		table.sort(plots, function(a,b)
			return (a:GetAttribute("PlotIndex") or 0) < (b:GetAttribute("PlotIndex") or 0)
		end)
		return plots
	end

	local function isReady(plot)
		if plot:GetAttribute("FullyGrown") then return true end
		local m = plot:FindFirstChildWhichIsA("Model")
		return m and m:GetAttribute("IsReady") == true
	end

	local function isEmpty(plot)
		return not plot:FindFirstChildWhichIsA("Model")
			and not plot:GetAttribute("PlantedSeedId")
	end

	local function getHRP()
		local c = player.Character
		return c and c:FindFirstChild("HumanoidRootPart")
	end

	local function getEggRoot()
		for _, v in ipairs(workspace:GetChildren()) do
			if v.Name:find("ShyEgg_") and v:IsA("Model") then
				local r = v:FindFirstChild("Root")
				if r then return r end
			end
		end
	end

	-- Hanya dari zone milik player
	local function getMyAnimals()
		local zone = getMyZone()
		if not zone then return {} end
		local t = {}
		local animals = zone:FindFirstChild("Animals")
		if animals then
			for _, a in ipairs(animals:GetChildren()) do
				table.insert(t, a)
			end
		end
		return t
	end

	local function getMyFish()
		local zone = getMyZone()
		if not zone then return {} end
		local t = {}
		local fish = zone:FindFirstChild("Fish")
		if fish then
			for _, f in ipairs(fish:GetChildren()) do
				table.insert(t, f)
			end
		end
		return t
	end

	local function getMyShrooms()
		local zone = getMyZone()
		if not zone then return {} end
		local t = {}
		local m = zone:FindFirstChild("Unlocks") and zone.Unlocks:FindFirstChild("Mushrooms")
		if m then
			for _, g in ipairs(m:GetChildren()) do
				for _, s in ipairs(g:GetChildren()) do
					table.insert(t, s)
				end
			end
		end
		return t
	end

	local function getMyTreeFolders()
		local zone = getMyZone()
		if not zone then return {} end
		local t = {}
		local trees = zone:FindFirstChild("Unlocks") and zone.Unlocks:FindFirstChild("Trees")
		if trees then
			for _, tree in ipairs(trees:GetChildren()) do
				table.insert(t, tree)
			end
		end
		return t
	end

	local function countInMyZone(folderName)
		local zone = getMyZone()
		if not zone then return 0 end
		local f = zone:FindFirstChild(folderName)
		return f and #f:GetChildren() or 0
	end

	local function cancelThread(key)
		if threads[key] then task.cancel(threads[key]); threads[key] = nil end
	end

	local function clearConns(key)
		for _, c in ipairs(conns[key]) do c:Disconnect() end
		conns[key] = {}
	end

	-- ========================
	-- DROPDOWN BUILDER
	-- sesuai style NeeR Flow
	-- ========================
	local function makeDropdown(parent, label, list, default, callback)
		local selected = default
		local isOpen   = false

		-- Row card
		local card = CreateFeatureCard(parent, label .. ": " .. selected, 32)

		-- Tombol dropdown
		local dBtn = Instance.new("TextButton")
		dBtn.Size = UDim2.new(0, 80, 0, 20)
		dBtn.Position = UDim2.new(1, -8, 0.5, 0)
		dBtn.AnchorPoint = Vector2.new(1, 0.5)
		dBtn.BackgroundColor3 = Theme.Main
		dBtn.Text = "▾ " .. selected
		dBtn.TextColor3 = Theme.Accent
		dBtn.TextSize = 9
		dBtn.Font = Theme.FontBold
		dBtn.BorderSizePixel = 0
		dBtn.ClipsDescendants = true
		dBtn.Parent = card
		Instance.new("UICorner", dBtn).CornerRadius = UDim.new(0, 4)
		local dStroke = Instance.new("UIStroke", dBtn)
		dStroke.Color = Theme.Accent
		dStroke.Thickness = 1.2
		dStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		-- Dropdown list overlay
		local sg = game.CoreGui:FindFirstChild("NeerFlowDropdowns")
		if not sg then
			sg = Instance.new("ScreenGui")
			sg.Name = "NeerFlowDropdowns"
			sg.ResetOnSpawn = false
			sg.DisplayOrder = 9999
			sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			sg.Parent = game.CoreGui
		end

		local dFrame = Instance.new("Frame")
		dFrame.Size = UDim2.new(0, 140, 0, 130)
		dFrame.BackgroundColor3 = Theme.Main or Color3.fromRGB(22,22,32)
		dFrame.BorderSizePixel = 0
		dFrame.Visible = false
		dFrame.ZIndex = 100
		dFrame.Parent = sg
		Instance.new("UICorner", dFrame).CornerRadius = UDim.new(0, 6)
		local fStroke = Instance.new("UIStroke", dFrame)
		fStroke.Color = Theme.Accent
		fStroke.Thickness = 1.5

		local dScroll = Instance.new("ScrollingFrame")
		dScroll.Size = UDim2.new(1,-6,1,-6)
		dScroll.Position = UDim2.new(0,3,0,3)
		dScroll.BackgroundTransparency = 1
		dScroll.BorderSizePixel = 0
		dScroll.ScrollBarThickness = 2
		dScroll.ScrollBarImageColor3 = Theme.Accent
		dScroll.CanvasSize = UDim2.new(0,0,0,0)
		dScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		dScroll.ZIndex = 100
		dScroll.Parent = dFrame
		Instance.new("UIListLayout", dScroll).Padding = UDim.new(0, 2)

		for _, item in ipairs(list) do
			local it = Instance.new("TextButton")
			it.Size = UDim2.new(1,-4,0,22)
			it.BackgroundColor3 = item == selected
				and (Theme.Accent or Color3.fromRGB(99,102,241))
				or (Theme.Secondary or Color3.fromRGB(30,30,45))
			it.Text = item
			it.TextColor3 = Color3.fromRGB(230,230,245)
			it.TextSize = 9
			it.Font = Theme.Font or Enum.Font.Gotham
			it.BorderSizePixel = 0
			it.ZIndex = 101
			it.TextXAlignment = Enum.TextXAlignment.Left
			it.Parent = dScroll
			Instance.new("UICorner", it).CornerRadius = UDim.new(0, 4)
			Instance.new("UIPadding", it).PaddingLeft = UDim.new(0, 7)

			it.MouseButton1Click:Connect(function()
				selected = item
				dBtn.Text = "▾ " .. item
				isOpen = false
				dFrame.Visible = false
				-- Update highlight
				for _, c in ipairs(dScroll:GetChildren()) do
					if c:IsA("TextButton") then
						c.BackgroundColor3 = c.Text == selected
							and (Theme.Accent or Color3.fromRGB(99,102,241))
							or (Theme.Secondary or Color3.fromRGB(30,30,45))
					end
				end
				callback(item)
			end)
		end

		dBtn.MouseButton1Click:Connect(function()
			isOpen = not isOpen
			if isOpen then
				local abs = dBtn.AbsolutePosition
				local sz  = dBtn.AbsoluteSize
				dFrame.Position = UDim2.new(0, abs.X, 0, abs.Y + sz.Y + 2)
				dFrame.Visible = true
				dBtn.Text = "▴ " .. selected
			else
				dFrame.Visible = false
				dBtn.Text = "▾ " .. selected
			end
		end)

		return card
	end

	-- ========================
	-- SECTION 1: FARM
	-- ========================
	local FarmSec = CreateExpandableSection(parentFrame, "🌾 Farm")

	makeDropdown(FarmSec, "Seed", SEEDS, selectedSeed, function(v)
		selectedSeed = v
	end)

	local HarvestCard = CreateFeatureCard(FarmSec, "Auto Harvest Tanaman", 32)
	AttachSwitch(HarvestCard, false, function(active)
		state.harvest = active
		if active then
			threads.harvest = task.spawn(function()
				while state.harvest do
					local plots = getMyPlots()
					local count = 0
					for _, plot in ipairs(plots) do
						if not state.harvest then break end
						if isReady(plot) then
							pcall(function() R.HarvestSeed:FireServer(plot) end)
							count = count + 1
							task.wait(0.5)
						end
					end
					if count == 0 then
						local shortest = math.huge
						for _, plot in ipairs(plots) do
							local gt = plot:GetAttribute("GrowthTime")
							local pa = plot:GetAttribute("PlantedAt")
							if gt and pa then
								local r = (pa+gt) - os.time()
								if r > 0 and r < shortest then shortest = r end
							end
						end
						shortest = math.max(shortest == math.huge and 10 or shortest, 3)
						for _ = 1, shortest do
							if not state.harvest then break end
							task.wait(1)
						end
					else
						task.wait(2)
					end
				end
			end)
		else
			cancelThread("harvest")
		end
	end)

	local PlantCard = CreateFeatureCard(FarmSec, "Auto Plant Tanaman", 32)
	AttachSwitch(PlantCard, false, function(active)
		state.plant = active
		if active then
			threads.plant = task.spawn(function()
				while state.plant do
					for _, plot in ipairs(getMyPlots()) do
						if not state.plant then break end
						if isEmpty(plot) then
							pcall(function() R.PlantSeed:FireServer(selectedSeed, 1) end)
							task.wait(0.5)
						end
					end
					task.wait(5)
				end
			end)
		else
			cancelThread("plant")
		end
	end)

	-- ========================
	-- SECTION 2: HEWAN
	-- ========================
	local AnimalSec = CreateExpandableSection(parentFrame, "🐄 Hewan")

	makeDropdown(AnimalSec, "Hewan", ANIMALS, selectedAnimal, function(v)
		selectedAnimal = v
	end)

	local HarvestAnimalCard = CreateFeatureCard(AnimalSec, "Auto Panen Hewan", 32)
	AttachSwitch(HarvestAnimalCard, false, function(active)
		state.animal = active
		if active then
			clearConns("animal")
			-- Hanya dari zone milik player
			local animals = getMyAnimals()
			for _, animal in ipairs(animals) do
				if animal:GetAttribute("IsReady") == true then
					pcall(function() R.HarvestAnimal:FireServer(animal) end)
					task.wait(0.5)
				end
				local c = animal:GetAttributeChangedSignal("IsReady"):Connect(function()
					if not state.animal then return end
					if animal:GetAttribute("IsReady") == true then
						pcall(function() R.HarvestAnimal:FireServer(animal) end)
					end
				end)
				table.insert(conns.animal, c)
			end
		else
			clearConns("animal")
		end
	end)

	local SpawnAnimalCard = CreateFeatureCard(AnimalSec, "Auto Spawn Hewan", 32)
	AttachSwitch(SpawnAnimalCard, false, function(active)
		state.spawnAnimal = active
		if active then
			threads.spawnAnimal = task.spawn(function()
				while state.spawnAnimal do
					local ok, maxSpace = pcall(function()
						return R.GetAnimalSpace:InvokeServer("1")
					end)
					if ok and maxSpace then
						local current = countInMyZone("Animals")
						local avail = maxSpace - current
						if avail > 0 then
							pcall(function()
								R.SpawnAnimal:FireServer(selectedAnimal, avail)
							end)
						end
					end
					task.wait(10)
				end
			end)
		else
			cancelThread("spawnAnimal")
		end
	end)

	-- ========================
	-- SECTION 3: IKAN
	-- ========================
	local FishSec = CreateExpandableSection(parentFrame, "🐟 Ikan")

	makeDropdown(FishSec, "Ikan", FISH, selectedFish, function(v)
		selectedFish = v
	end)

	local HarvestFishCard = CreateFeatureCard(FishSec, "Auto Panen Ikan", 32)
	AttachSwitch(HarvestFishCard, false, function(active)
		state.fish = active
		if active then
			clearConns("fish")
			-- Hanya dari zone milik player
			local fishList = getMyFish()
			for _, fish in ipairs(fishList) do
				if fish:GetAttribute("IsReady") == true then
					pcall(function() R.HarvestFish:FireServer(fish) end)
					task.wait(0.5)
				end
				local c = fish:GetAttributeChangedSignal("IsReady"):Connect(function()
					if not state.fish then return end
					if fish:GetAttribute("IsReady") == true then
						pcall(function() R.HarvestFish:FireServer(fish) end)
					end
				end)
				table.insert(conns.fish, c)
			end
		else
			clearConns("fish")
		end
	end)

	local SpawnFishCard = CreateFeatureCard(FishSec, "Auto Spawn Ikan", 32)
	AttachSwitch(SpawnFishCard, false, function(active)
		state.spawnFish = active
		if active then
			threads.spawnFish = task.spawn(function()
				while state.spawnFish do
					local ok, maxSpace = pcall(function()
						return R.GetFishSpace:InvokeServer("1")
					end)
					if ok and maxSpace then
						local current = countInMyZone("Fish")
						local avail = maxSpace - current
						if avail > 0 then
							pcall(function()
								R.SpawnFish:FireServer(selectedFish, avail)
							end)
						end
					end
					task.wait(10)
				end
			end)
		else
			cancelThread("spawnFish")
		end
	end)

	-- ========================
	-- SECTION 4: ALAM
	-- ========================
	local AlamSec = CreateExpandableSection(parentFrame, "🍄 Alam")

	local ShroomCard = CreateFeatureCard(AlamSec, "Auto Harvest Jamur", 32)
	AttachSwitch(ShroomCard, false, function(active)
		state.shroom = active
		if active then
			clearConns("shroom")
			-- Hanya shroom di zone milik player
			for _, shroom in ipairs(getMyShrooms()) do
				if shroom:GetAttribute("HarvestActive") == true then
					local part = shroom:FindFirstChild("Part")
					if part then
						pcall(function() R.DecoHarvest:FireServer(part) end)
						task.wait(0.5)
					end
				end
				local c = shroom:GetAttributeChangedSignal("HarvestActive"):Connect(function()
					if not state.shroom then return end
					if shroom:GetAttribute("HarvestActive") == true then
						local part = shroom:FindFirstChild("Part")
						if part then pcall(function() R.DecoHarvest:FireServer(part) end) end
					end
				end)
				table.insert(conns.shroom, c)
			end
		else
			clearConns("shroom")
		end
	end)

	local TreeCard = CreateFeatureCard(AlamSec, "Auto Harvest Pohon", 32)
	AttachSwitch(TreeCard, false, function(active)
		state.tree = active
		if active then
			clearConns("tree")
			-- Hanya pohon di zone milik player
			for _, tree in ipairs(getMyTreeFolders()) do
				for _, child in ipairs(tree:GetChildren()) do
					if child.Name:find("DroppedApple_") then
						local part = child:FindFirstChild("Part")
						if part then
							pcall(function() R.ApplePickup:FireServer(child) end)
							task.wait(0.1)
							pcall(function() R.DecoHarvest:FireServer(part) end)
							task.wait(0.4)
						end
					end
					if child:GetAttribute("HarvestActive") == true then
						local part = child:FindFirstChild("Part")
						if part then
							pcall(function() R.DecoHarvest:FireServer(part) end)
							task.wait(0.4)
						end
					end
				end

				local c1 = tree.ChildAdded:Connect(function(child)
					if not state.tree then return end
					if child.Name:find("DroppedApple_") then
						task.wait(0.3)
						local part = child:FindFirstChild("Part")
						if part then
							pcall(function() R.ApplePickup:FireServer(child) end)
							task.wait(0.1)
							pcall(function() R.DecoHarvest:FireServer(part) end)
						end
					end
				end)
				table.insert(conns.tree, c1)

				for _, child in ipairs(tree:GetChildren()) do
					if child:GetAttribute("HarvestActive") ~= nil then
						local c2 = child:GetAttributeChangedSignal("HarvestActive"):Connect(function()
							if not state.tree then return end
							if child:GetAttribute("HarvestActive") == true then
								local part = child:FindFirstChild("Part")
								if part then pcall(function() R.DecoHarvest:FireServer(part) end) end
							end
						end)
						table.insert(conns.tree, c2)
					end
				end
			end
		else
			clearConns("tree")
		end
	end)

	-- ========================
	-- SECTION 5: EVENT
	-- ========================
	local EventSec = CreateExpandableSection(parentFrame, "🥚 Shy Egg Event")

	local EggCard = CreateFeatureCard(EventSec, "Auto Hit Shy Egg", 32)
	AttachSwitch(EggCard, false, function(active)
		state.egg = active
		if not active then
			cancelThread("egg")
			eggJoined = false
		end
	end)

	-- Egg polling — join di main thread
	task.spawn(function()
		while true do
			task.wait(1)
			local egg = getEggRoot()

			if egg and state.egg and not eggJoined then
				game:GetService("ReplicatedStorage")
					:WaitForChild("Remotes")
					:WaitForChild("ShyEggJoinEvent")
					:FireServer()
				task.wait(0.8)
				game:GetService("ReplicatedStorage")
					:WaitForChild("Remotes")
					:WaitForChild("ShyEggJoinEvent")
					:FireServer()
				eggJoined = true

				cancelThread("egg")
				threads.egg = task.spawn(function()
					while state.egg do
						local hrp = getHRP()
						local root = getEggRoot()
						if hrp and root and root.Position.Y >= 0 then
							hrp.CFrame = CFrame.new(root.Position + Vector3.new(3,0,0))
							task.wait(0.05)
							game:GetService("ReplicatedStorage")
								:WaitForChild("Remotes")
								:WaitForChild("EggHitEvent")
								:FireServer()
							task.wait(0.2)
						else
							task.wait(0.5)
						end
					end
				end)

			elseif not egg and eggJoined then
				eggJoined = false
				cancelThread("egg")
			end
		end
	end)

	-- ========================
	-- CLEANUP
	-- ========================
	API.Session.StopCookARecipe = function()
		for k in pairs(state) do state[k] = false end
		for k in pairs(threads) do cancelThread(k) end
		for k in pairs(conns) do clearConns(k) end
		eggJoined = false
	end
end
