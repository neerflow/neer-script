-- File: Games/CookRecipe.lua (Di GitHub)
return function(parentFrame, API)
	-- ========================
	-- [1] BONGKAR KOPER API NEER FLOW
	-- ========================
	local Theme = API.Theme
	local CreateFeatureCard = API.CreateFeatureCard
	local AttachSwitch = API.AttachSwitch
	local CreateExpandableSection = API.CreateExpandableSection
	local CreateActionCard = API.CreateActionCard

	-- ========================
	-- [2] SERVICES & VARIABLES
	-- ========================
	local RS = game:GetService("ReplicatedStorage")
	local Remotes = RS:WaitForChild("Remotes")
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local Zones = workspace:WaitForChild("Zones")

	local R = {
		HarvestSeed   = Remotes:WaitForChild("HarvestSeedEvent"),
		PlantSeed     = Remotes:WaitForChild("PlantSeedEvent"),
		DecoHarvest   = Remotes:WaitForChild("DecorationHarvestEvent"),
		ApplePickup   = Remotes:WaitForChild("ApplePickupEvent"),
		HarvestAnimal = Remotes:WaitForChild("HarvestAnimalEvent"),
		HarvestFish   = Remotes:WaitForChild("HarvestFishEvent"),
		SpawnAnimal   = Remotes:WaitForChild("SpawnAnimalEvent"),
		SpawnFish     = Remotes:WaitForChild("SpawnFishEvent"),
		GetAnimalSpace= Remotes:WaitForChild("GetAnimalSpace"),
		GetFishSpace  = Remotes:WaitForChild("GetFishSpace"),
	}

	local ANIMALS = {"chicken","piggy","lamb","cow","bull","icecube","unicorn","duck","goose","rabbit","goat","turkey","glimblob","mossling","spicedragon"}
	local FISH    = {"nemo","reeffish","quabble","bluequabble","flatfish","shark","blueshark","crab","pufferfish","hermitfish","bluetang","anglerfish","pearlspirit","abyssglider","reefgolem"}
	local SEEDS   = {"carrot","tomato","alien_plant","golden_plant","mythic_plant","brocolli_plant","cabbage_plant","leek_plant","couliflower_plant","paprika_plant","glowleaf_plant","sunmelon_plant","voidberry_plant"}

	local state = {}
	local threads = {}
	local conns = {shroom={},tree={},animal={},fish={}}
	
	local selectedSeedIndex = 1
	local selectedSeed = SEEDS[selectedSeedIndex]
	
	local selectedAnimalIndex = 1
	local selectedAnimal = ANIMALS[selectedAnimalIndex]

	-- ========================
	-- [3] HELPERS LOGIC
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
		table.sort(plots, function(a,b) return (a:GetAttribute("PlotIndex") or 0) < (b:GetAttribute("PlotIndex") or 0) end)
		return plots
	end

	local function isReady(plot)
		if plot:GetAttribute("FullyGrown") then return true end
		local m = plot:FindFirstChildWhichIsA("Model")
		return m and m:GetAttribute("IsReady") == true
	end

	local function isEmpty(plot)
		return not plot:FindFirstChildWhichIsA("Model") and not plot:GetAttribute("PlantedSeedId")
	end

	local function cancelThread(key)
		if threads[key] then task.cancel(threads[key]); threads[key] = nil end
	end

	-- ========================
	-- [4] UI BUILDER (NEER FLOW STYLE)
	-- ========================
	
	-- --- SUB TAB 1: FARM ---
	local FarmSec = CreateExpandableSection(parentFrame, "🌾 Farm Automation")

	-- Pemilih Benih (Custom Dropdown/Cycler Button untuk NeeR Flow)
	local SeedCard, SeedLbl = CreateFeatureCard(FarmSec, "Selected Seed: " .. selectedSeed, 32)
	local SeedBtn = Instance.new("TextButton", SeedCard)
	SeedBtn.BackgroundColor3 = Theme.Main; SeedBtn.Size = UDim2.new(0, 70, 0, 20); SeedBtn.Position = UDim2.new(1, -8, 0.5, 0); SeedBtn.AnchorPoint = Vector2.new(1, 0.5)
	SeedBtn.Font = Theme.FontBold; SeedBtn.Text = "NEXT SEED"; SeedBtn.TextColor3 = Theme.Accent; SeedBtn.TextSize = 9
	Instance.new("UICorner", SeedBtn).CornerRadius = UDim.new(0, 4)
	local SS = Instance.new("UIStroke", SeedBtn); SS.Color = Theme.Accent; SS.Thickness = 1.2; SS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	
	SeedBtn.MouseButton1Click:Connect(function()
		selectedSeedIndex = (selectedSeedIndex % #SEEDS) + 1
		selectedSeed = SEEDS[selectedSeedIndex]
		SeedLbl.Text = "Selected Seed: " .. selectedSeed
	end)

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


	-- --- SUB TAB 2: TERNAK ---
	local TernakSec = CreateExpandableSection(parentFrame, "🐄 Ternak Automation")
	
	local AnimalCard, AnimalLbl = CreateFeatureCard(TernakSec, "Selected Animal: " .. selectedAnimal, 32)
	local AnimBtn = Instance.new("TextButton", AnimalCard)
	AnimBtn.BackgroundColor3 = Theme.Main; AnimBtn.Size = UDim2.new(0, 70, 0, 20); AnimBtn.Position = UDim2.new(1, -8, 0.5, 0); AnimBtn.AnchorPoint = Vector2.new(1, 0.5)
	AnimBtn.Font = Theme.FontBold; AnimBtn.Text = "NEXT ANIMAL"; AnimBtn.TextColor3 = Theme.Accent; AnimBtn.TextSize = 9
	Instance.new("UICorner", AnimBtn).CornerRadius = UDim.new(0, 4)
	local AS = Instance.new("UIStroke", AnimBtn); AS.Color = Theme.Accent; AS.Thickness = 1.2; AS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	
	AnimBtn.MouseButton1Click:Connect(function()
		selectedAnimalIndex = (selectedAnimalIndex % #ANIMALS) + 1
		selectedAnimal = ANIMALS[selectedAnimalIndex]
		AnimalLbl.Text = "Selected Animal: " .. selectedAnimal
	end)

	local AutoSpawnAnimCard = CreateFeatureCard(TernakSec, "Auto Spawn Animal", 32)
	AttachSwitch(AutoSpawnAnimCard, false, function(active)
		-- Masukkan logika Auto Spawn Animal Anda di sini
	end)


	-- --- SUB TAB 3: ALAM & EVENTS ---
	local AlamSec = CreateExpandableSection(parentFrame, "🍄 Alam & Events")
	
	local AutoAppleCard = CreateFeatureCard(AlamSec, "Auto Apple Pickup", 32)
	AttachSwitch(AutoAppleCard, false, function(active)
		-- Masukkan logika Auto Apple Anda di sini
	end)

	-- ========================
	-- [5] CLEANUP SAAT TAB DITUTUP / SCRIPT EXIT
	-- ========================
	-- Pastikan untuk mematikan semua loop jika pemain menekan tombol Force Close di script utama
	API.Session.StopCookARecipe = function()
		state.harvest = false
		state.plant = false
		cancelThread("harvest")
		cancelThread("plant")
	end
end

