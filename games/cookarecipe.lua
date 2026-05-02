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
	}

	local ANIMALS = {"chicken","piggy","lamb","cow","bull","icecube","unicorn","duck","goose","rabbit","goat","turkey","glimblob","mossling","spicedragon"}
	local FISH    = {"nemo","reeffish","quabble","bluequabble","flatfish","shark","blueshark","crab","pufferfish","hermitfish","bluetang","anglerfish","pearlspirit","abyssglider","reefgolem"}
	local SEEDS   = {"carrot","tomato","alien_plant","golden_plant","mythic_plant","brocolli_plant","cabbage_plant","leek_plant","couliflower_plant","paprika_plant","glowleaf_plant","sunmelon_plant","voidberry_plant"}

	local state = {}
	local threads = {}
	local conns = {shroom={}, tree={}, animal={}, fish={}}

	local selectedSeedIndex   = 1
	local selectedAnimalIndex = 1
	local selectedFishIndex   = 1
	local selectedSeed   = SEEDS[selectedSeedIndex]
	local selectedAnimal = ANIMALS[selectedAnimalIndex]
	local selectedFish   = FISH[selectedFishIndex]

	local eggJoined = false

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

	local function getAllAnimals()
		local t = {}
		for _, zone in ipairs(Zones:GetChildren()) do
			local f = zone:FindFirstChild("Animals")
			if f then for _, a in ipairs(f:GetChildren()) do table.insert(t, a) end end
		end
		return t
	end

	local function getAllFish()
		local t = {}
		for _, zone in ipairs(Zones:GetChildren()) do
			local f = zone:FindFirstChild("Fish")
			if f then for _, fish in ipairs(f:GetChildren()) do table.insert(t, fish) end end
		end
		return t
	end

	local function getAllShrooms()
		local t = {}
		for _, zone in ipairs(Zones:GetChildren()) do
			local m = zone:FindFirstChild("Unlocks") and zone.Unlocks:FindFirstChild("Mushrooms")
			if m then
				for _, g in ipairs(m:GetChildren()) do
					for _, s in ipairs(g:GetChildren()) do table.insert(t, s) end
				end
			end
		end
		return t
	end

	local function getTreeFolders()
		local t = {}
		for _, zone in ipairs(Zones:GetChildren()) do
			local trees = zone:FindFirstChild("Unlocks") and zone.Unlocks:FindFirstChild("Trees")
			if trees then
				for _, tree in ipairs(trees:GetChildren()) do table.insert(t, tree) end
			end
		end
		return t
	end

	local function countInZone(folderName)
		local count = 0
		for _, zone in ipairs(Zones:GetChildren()) do
			local f = zone:FindFirstChild(folderName)
			if f then count = count + #f:GetChildren() end
		end
		return count
	end

	local function cancelThread(key)
		if threads[key] then task.cancel(threads[key]); threads[key] = nil end
	end

	local function clearConns(key)
		for _, c in ipairs(conns[key]) do c:Disconnect() end
		conns[key] = {}
	end

	-- ========================
	-- Helper buat Next Button
	-- ========================
	local function makeNextBtn(card, label, list, indexRef, callback)
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = Theme.Main
		btn.Size = UDim2.new(0, 75, 0, 20)
		btn.Position = UDim2.new(1, -8, 0.5, 0)
		btn.AnchorPoint = Vector2.new(1, 0.5)
		btn.Font = Theme.FontBold
		btn.Text = "▶ NEXT"
		btn.TextColor3 = Theme.Accent
		btn.TextSize = 9
		btn.BorderSizePixel = 0
		btn.Parent = card
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
		local stroke = Instance.new("UIStroke", btn)
		stroke.Color = Theme.Accent
		stroke.Thickness = 1.2
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		btn.MouseButton1Click:Connect(function()
			indexRef[1] = (indexRef[1] % #list) + 1
			local val = list[indexRef[1]]
			label.Text = label.Text:gsub(":.*", ": " .. val)
			callback(val)
		end)
	end

	-- ========================
	-- SECTION 1: FARM
	-- ========================
	local FarmSec = CreateExpandableSection(parentFrame, "🌾 Farm")

	-- Seed selector
	local SeedCard, SeedLbl = CreateFeatureCard(FarmSec, "Seed: " .. selectedSeed, 32)
	local seedIdxRef = {selectedSeedIndex}
	makeNextBtn(SeedCard, SeedLbl, SEEDS, seedIdxRef, function(v) selectedSeed = v end)

	-- Auto Harvest
	local HarvestCard = CreateFeatureCard(FarmSec, "Auto Harvest", 32)
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

	-- Auto Plant
	local PlantCard = CreateFeatureCard(FarmSec, "Auto Plant", 32)
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

	-- Animal selector
	local AnimalCard, AnimalLbl = CreateFeatureCard(AnimalSec, "Hewan: " .. selectedAnimal, 32)
	local animalIdxRef = {selectedAnimalIndex}
	makeNextBtn(AnimalCard, AnimalLbl, ANIMALS, animalIdxRef, function(v) selectedAnimal = v end)

	-- Auto Panen Hewan
	local HarvestAnimalCard = CreateFeatureCard(AnimalSec, "Auto Panen Hewan", 32)
	AttachSwitch(HarvestAnimalCard, false, function(active)
		state.animal = active
		if active then
			clearConns("animal")
			for _, animal in ipairs(getAllAnimals()) do
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

	-- Auto Spawn Hewan
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
						local current = countInZone("Animals")
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

	-- Fish selector
	local FishCard, FishLbl = CreateFeatureCard(FishSec, "Ikan: " .. selectedFish, 32)
	local fishIdxRef = {selectedFishIndex}
	makeNextBtn(FishCard, FishLbl, FISH, fishIdxRef, function(v) selectedFish = v end)

	-- Auto Panen Ikan
	local HarvestFishCard = CreateFeatureCard(FishSec, "Auto Panen Ikan", 32)
	AttachSwitch(HarvestFishCard, false, function(active)
		state.fish = active
		if active then
			clearConns("fish")
			for _, fish in ipairs(getAllFish()) do
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

	-- Auto Spawn Ikan
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
						local current = countInZone("Fish")
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

	-- Auto Harvest Jamur
	local ShroomCard = CreateFeatureCard(AlamSec, "Auto Harvest Jamur", 32)
	AttachSwitch(ShroomCard, false, function(active)
		state.shroom = active
		if active then
			clearConns("shroom")
			for _, shroom in ipairs(getAllShrooms()) do
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

	-- Auto Harvest Pohon
	local TreeCard = CreateFeatureCard(AlamSec, "Auto Harvest Pohon", 32)
	AttachSwitch(TreeCard, false, function(active)
		state.tree = active
		if active then
			clearConns("tree")
			for _, tree in ipairs(getTreeFolders()) do
				-- Panen yang sudah ada
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

				-- Listener buah baru jatuh
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

				-- Listener HarvestActive (Gummy)
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

	-- Auto Hit Shy Egg
	local EggCard = CreateFeatureCard(EventSec, "Auto Hit Shy Egg", 32)
	AttachSwitch(EggCard, false, function(active)
		state.egg = active
		if not active then
			cancelThread("egg")
			eggJoined = false
		end
	end)

	-- Egg polling loop — join di main thread
	task.spawn(function()
		while true do
			task.wait(1)
			local egg = getEggRoot()

			if egg and state.egg and not eggJoined then
				-- JOIN langsung di polling thread
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
