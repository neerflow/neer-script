return function(parentFrame, API)
	-- ========================
	-- [1] API & UI SETUP
	-- ========================
	local Theme = API.Theme
	local CreateFeatureCard = API.CreateFeatureCard
	local AttachSwitch = API.AttachSwitch
	local CreateExpandableSection = API.CreateExpandableSection
	local CreateTabBtn = API.CreateTabBtn
	
	local FarmTab  = CreateTabBtn("🌾 - Auto Farm", true)  -- true = auto open
    local EventTab = CreateTabBtn("🥚 - Event",     false)
	-- ========================
	-- [2] SERVICES & REMOTES
	-- ========================
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
		GetPlayerZone  = Remotes:WaitForChild("GetPlayerZone"),
		ShyEggJoin     = Remotes:WaitForChild("ShyEggJoinEvent"),
		EggHit         = Remotes:WaitForChild("EggHitEvent")
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
	local openDropdowns  = {}

	-- ========================
	-- [3] SMART LOCAL ZONE SCANNER
	-- ========================
	local function getMySafeZone()
		local myId = tostring(player.UserId)
		for _, zone in ipairs(Zones:GetChildren()) do
			local cp = zone:FindFirstChild("Garden") and zone.Garden:FindFirstChild("CropPlots")
			if cp then
				for _, plot in ipairs(cp:GetChildren()) do
					if tostring(plot:GetAttribute("OwnerUserId")) == myId then
						return zone
					end
				end
			end
		end
		return nil
	end

	-- ========================
	-- [4] HELPERS
	-- ========================
	local function getMyPlots()
		local plots = {}
		local zone = getMySafeZone()
		if zone then
			local cp = zone:FindFirstChild("Garden") and zone.Garden:FindFirstChild("CropPlots")
			if cp then
				local myId = tostring(player.UserId)
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

	local function getMyShrooms()
		local zone = getMySafeZone()
		local t = {}
		if zone then
			local m = zone:FindFirstChild("Unlocks") and zone.Unlocks:FindFirstChild("Mushrooms")
			if m then
				for _, g in ipairs(m:GetChildren()) do
					for _, s in ipairs(g:GetChildren()) do table.insert(t, s) end
				end
			end
		end
		return t
	end

	local function getMyTreeFolders()
		local zone = getMySafeZone()
		local t = {}
		if zone then
			local trees = zone:FindFirstChild("Unlocks") and zone.Unlocks:FindFirstChild("Trees")
			if trees then
				for _, tree in ipairs(trees:GetChildren()) do table.insert(t, tree) end
			end
		end
		return t
	end

	local function cancelThread(key)
		if threads[key] then task.cancel(threads[key]); threads[key] = nil end
	end

	local function clearConns(key)
		for _, c in ipairs(conns[key]) do c:Disconnect() end
		conns[key] = {}
	end

	local function closeAllDropdowns()
		for _, fn in ipairs(openDropdowns) do pcall(fn) end
		openDropdowns = {}
	end

	-- ========================
	-- [5] DROPDOWN BUILDER
	-- ========================
	local dropSg = game:GetService("CoreGui"):FindFirstChild("NeerFlowDropdowns")
	if not dropSg then
		dropSg = Instance.new("ScreenGui")
		dropSg.Name = "NeerFlowDropdowns"
		dropSg.ResetOnSpawn = false
		dropSg.DisplayOrder = 9999
		dropSg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		dropSg.Parent = game:GetService("CoreGui")
	end

	local overlay = Instance.new("TextButton")
	overlay.Size = UDim2.new(1, 0, 1, 0); overlay.BackgroundTransparency = 1; overlay.Text = ""; overlay.ZIndex = 98; overlay.Visible = false; overlay.Parent = dropSg
	overlay.MouseButton1Click:Connect(function() closeAllDropdowns(); overlay.Visible = false end)

	local function makeDropdown(parent, label, list, default, callback)
		local selected = default
		local isOpen   = false
		local dFrame   = nil

		local card = CreateFeatureCard(parent, label .. ": " .. selected, 32)
		local dBtn = Instance.new("TextButton")
		dBtn.Size = UDim2.new(0.55, 0, 0, 22); dBtn.Position = UDim2.new(0.44, 0, 0.5, -11); dBtn.BackgroundColor3 = Theme.Main or Color3.fromRGB(28,28,42)
		dBtn.Text = "▾ " .. selected; dBtn.TextColor3 = Theme.Accent; dBtn.TextSize = 9; dBtn.Font = Theme.FontBold or Enum.Font.GothamBold; dBtn.BorderSizePixel = 0; dBtn.Parent = card
		Instance.new("UICorner", dBtn).CornerRadius = UDim.new(0, 4)
		local dStroke = Instance.new("UIStroke", dBtn); dStroke.Color = Theme.Accent; dStroke.Thickness = 1.2; dStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		dFrame = Instance.new("Frame")
		dFrame.Size = UDim2.new(0, 220, 0, 140); dFrame.BackgroundColor3 = Theme.Main or Color3.fromRGB(22,22,32); dFrame.BorderSizePixel = 0; dFrame.Visible = false; dFrame.ZIndex = 100; dFrame.Parent = dropSg
		Instance.new("UICorner", dFrame).CornerRadius = UDim.new(0, 7)
		local fStroke = Instance.new("UIStroke", dFrame); fStroke.Color = Theme.Accent; fStroke.Thickness = 1.5

		local dScroll = Instance.new("ScrollingFrame")
		dScroll.Size = UDim2.new(1,-8,1,-8); dScroll.Position = UDim2.new(0,4,0,4); dScroll.BackgroundTransparency = 1; dScroll.BorderSizePixel = 0; dScroll.ScrollBarThickness = 3; dScroll.ScrollBarImageColor3 = Theme.Accent; dScroll.CanvasSize = UDim2.new(0,0,0,0); dScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; dScroll.ZIndex = 100; dScroll.Parent = dFrame
		Instance.new("UIListLayout", dScroll).Padding = UDim.new(0, 2)

		for _, item in ipairs(list) do
			local it = Instance.new("TextButton")
			it.Size = UDim2.new(1,-4,0,24); it.BackgroundColor3 = item == selected and (Theme.Accent or Color3.fromRGB(99,102,241)) or Color3.fromRGB(32,32,48)
			it.Text = item; it.TextColor3 = Color3.fromRGB(230,230,245); it.TextSize = 10; it.Font = Theme.FontMain or Enum.Font.Gotham; it.BorderSizePixel = 0; it.ZIndex = 101; it.TextXAlignment = Enum.TextXAlignment.Left; it.Parent = dScroll
			Instance.new("UICorner", it).CornerRadius = UDim.new(0, 5); Instance.new("UIPadding", it).PaddingLeft = UDim.new(0, 8)

			it.MouseButton1Click:Connect(function()
				selected = item; dBtn.Text = "▾ " .. item; isOpen = false; dFrame.Visible = false; overlay.Visible = false; openDropdowns = {}
				for _, c in ipairs(dScroll:GetChildren()) do
					if c:IsA("TextButton") then c.BackgroundColor3 = c.Text == selected and (Theme.Accent or Color3.fromRGB(99,102,241)) or Color3.fromRGB(32,32,48) end
				end
				callback(item)
			end)
		end

		local function closeThis() isOpen = false; dFrame.Visible = false; dBtn.Text = "▾ " .. selected end

		dBtn.MouseButton1Click:Connect(function()
			closeAllDropdowns(); isOpen = not isOpen
			if isOpen then
				local abs = dBtn.AbsolutePosition; local sz = dBtn.AbsoluteSize; local scrW = workspace.CurrentCamera.ViewportSize.X
				local posX = abs.X + sz.X - 220
				if posX < 4 then posX = 4 end
				if posX + 220 > scrW - 4 then posX = scrW - 224 end
				dFrame.Position = UDim2.new(0, posX, 0, abs.Y + sz.Y + 4); dFrame.Visible = true; dBtn.Text = "▴ " .. selected; overlay.Visible = true
				table.insert(openDropdowns, closeThis)
			else
				closeThis(); overlay.Visible = false
			end
		end)
	end


	-- ==========================================
	-- TAB 1: AUTO FARM (FarmTab)
	-- ==========================================

	-- [ TANAMAN ]
	local PlantSec = CreateExpandableSection(FarmTab, "🌱 Tanaman")
	makeDropdown(PlantSec, "Pilih Benih", SEEDS, selectedSeed, function(v) selectedSeed = v end)

	local PlantCard = CreateFeatureCard(PlantSec, "Auto Plant Tanaman", 32)
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
		else cancelThread("plant") end
	end)

local HarvestCard = CreateFeatureCard(PlantSec, "Auto Harvest Tanaman", 32)
AttachSwitch(HarvestCard, false, function(active)
    state.harvest = active
    if active then
        threads.harvest = task.spawn(function()
            local harvestCooldown = {}
            while state.harvest do
                local plots = getMyPlots()
                local count = 0
                local shortest = math.huge

                for _, plot in ipairs(plots) do
                    if not state.harvest then break end

                    local plotId = plot:GetAttribute("PlotIndex") or plot.Name

                    if isReady(plot) then
                        -- Cooldown 3 detik per plot
                        if not harvestCooldown[plotId] or
                           os.clock() - harvestCooldown[plotId] >= 3 then
                            harvestCooldown[plotId] = os.clock()
                            pcall(function() R.HarvestSeed:FireServer(plot) end)
                            count = count + 1
                            task.wait(0.5)
                        end
                    else
                        -- Hitung waktu tunggu terpendek
                        local gt = plot:GetAttribute("GrowthTime")
                        local pa = plot:GetAttribute("PlantedAt")
                        if gt and pa then
                            local r = (pa + gt) - os.time()
                            if r > 0 and r < shortest then
                                shortest = r
                            end
                        end
                    end
                end

                if count == 0 then
                    -- Tidak ada yang dipanen, tunggu yang tercepat
                    shortest = math.max(
                        shortest == math.huge and 10 or shortest, 3
                    )
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
	-- [ HEWAN ]
	local AnimalSec = CreateExpandableSection(FarmTab, "🐄 Hewan")
	makeDropdown(AnimalSec, "Pilih Hewan", ANIMALS, selectedAnimal, function(v) selectedAnimal = v end)

	local SpawnAnimalCard = CreateFeatureCard(AnimalSec, "Auto Spawn Hewan", 32)
AttachSwitch(SpawnAnimalCard, false, function(active)
    state.spawnAnimal = active
    if active then
        threads.spawnAnimal = task.spawn(function()
            while state.spawnAnimal do
                local zone = getMySafeZone()
                if zone then
                    local folder = zone:FindFirstChild("Animals")
                    local current = folder and #folder:GetChildren() or 0
                    local MAX = 25

                    if current < MAX then
                        -- Spawn 1, tunggu konfirmasi masuk folder
                        local before = current
                        pcall(function()
                            R.SpawnAnimal:FireServer(selectedAnimal)
                        end)
                        -- Tunggu sampai count bertambah (max 3 detik)
                        local waited = 0
                        while waited < 3 do
                            task.wait(0.5)
                            waited = waited + 0.5
                            local newCount = folder and #folder:GetChildren() or 0
                            if newCount > before then break end
                        end
                    else
                        -- Kandang penuh, cek lagi tiap 10 detik
                        task.wait(10)
                    end
                else
                    task.wait(3)
                end
            end
        end)
    else
        cancelThread("spawnAnimal")
    end
end)

	local HarvestAnimalCard = CreateFeatureCard(AnimalSec, "Auto Panen Hewan", 32)
AttachSwitch(HarvestAnimalCard, false, function(active)
    state.animal = active
    if active then
        clearConns("animal")

        local zone = getMySafeZone()
        local folder = zone and zone:FindFirstChild("Animals")
        if not folder then return end

        -- Cooldown tracker per hewan
        -- Mencegah double harvest dari event + polling
        local harvestCooldown = {}

        local function panenHewan(animal)
            if not state.animal then return end
            if not animal or not animal.Parent then return end
            if animal:GetAttribute("IsReady") ~= true then return end

            local uuid = animal:GetAttribute("UUID") or animal.Name
            -- Skip kalau masih dalam cooldown 3 detik
            if harvestCooldown[uuid] and
               os.clock() - harvestCooldown[uuid] < 3 then
                return
            end

            harvestCooldown[uuid] = os.clock()
            pcall(function() R.HarvestAnimal:FireServer(animal) end)
        end

        local function pantauHewan(animal)
            if not animal:IsA("Model") then return end
            local c = animal:GetAttributeChangedSignal("IsReady"):Connect(function()
                panenHewan(animal)
            end)
            table.insert(conns.animal, c)
        end

        -- Pasang ke semua hewan yang ada
        for _, animal in ipairs(folder:GetChildren()) do
            panenHewan(animal) -- panen yg sudah siap
            pantauHewan(animal)
        end

        -- Radar hewan baru (dari spawn)
        local cAdded = folder.ChildAdded:Connect(function(child)
            if not state.animal then return end
            task.wait(0.5) -- tunggu attribute terisi
            panenHewan(child)
            pantauHewan(child)
        end)
        table.insert(conns.animal, cAdded)

        -- Polling ringan sebagai fallback (tiap 8 detik)
        -- Hanya untuk catch yang benar-benar missed
        threads.animalPoll = task.spawn(function()
            while state.animal do
                task.wait(8)
                if not state.animal then break end
                local z = getMySafeZone()
                local f = z and z:FindFirstChild("Animals")
                if f then
                    for _, animal in ipairs(f:GetChildren()) do
                        if not state.animal then break end
                        panenHewan(animal)
                        task.wait(0.3)
                    end
                end
            end
        end)

        -- Monitor zone change
        -- Kalau zone berubah, reconnect otomatis
        threads.animalZone = task.spawn(function()
            local lastZone = zone
            while state.animal do
                task.wait(5)
                local newZone = getMySafeZone()
                if newZone and newZone ~= lastZone then
                    lastZone = newZone
                    -- Reconnect ke zone baru
                    clearConns("animal")
                    cancelThread("animalPoll")
                    harvestCooldown = {}
                    local newFolder = newZone:FindFirstChild("Animals")
                    if newFolder then
                        for _, animal in ipairs(newFolder:GetChildren()) do
                            panenHewan(animal)
                            pantauHewan(animal)
                        end
                        local c2 = newFolder.ChildAdded:Connect(function(child)
                            if not state.animal then return end
                            task.wait(0.5)
                            panenHewan(child)
                            pantauHewan(child)
                        end)
                        table.insert(conns.animal, c2)
                    end
                end
            end
        end)

    else
        clearConns("animal")
        cancelThread("animalPoll")
        cancelThread("animalZone")
    end
end)

	-- [ IKAN ]
	local FishSec = CreateExpandableSection(FarmTab, "🐟 Ikan")
	makeDropdown(FishSec, "Pilih Ikan", FISH, selectedFish, function(v) selectedFish = v end)

	local SpawnFishCard = CreateFeatureCard(FishSec, "Auto Spawn Ikan", 32)
AttachSwitch(SpawnFishCard, false, function(active)
    state.spawnFish = active
    if active then
        threads.spawnFish = task.spawn(function()
            while state.spawnFish do
                local zone = getMySafeZone()
                if zone then
                    local folder = zone:FindFirstChild("Fish")
                    local current = folder and #folder:GetChildren() or 0
                    local MAX = 25

                    if current < MAX then
                        local before = current
                        pcall(function()
                            R.SpawnFish:FireServer(selectedFish)
                        end)
                        -- Tunggu konfirmasi
                        local waited = 0
                        while waited < 3 do
                            task.wait(0.5)
                            waited = waited + 0.5
                            local newCount = folder and #folder:GetChildren() or 0
                            if newCount > before then break end
                        end
                    else
                        task.wait(10)
                    end
                else
                    task.wait(3)
                end
            end
        end)
    else
        cancelThread("spawnFish")
    end
end)

    local HarvestFishCard = CreateFeatureCard(FishSec, "Auto Panen Ikan", 32)
AttachSwitch(HarvestFishCard, false, function(active)
    state.fish = active
    if active then
        clearConns("fish")

        local zone = getMySafeZone()
        local folder = zone and zone:FindFirstChild("Fish")
        if not folder then return end

        local harvestCooldown = {}

        local function panenIkan(fish)
            if not state.fish then return end
            if not fish or not fish.Parent then return end
            if fish:GetAttribute("IsReady") ~= true then return end

            local uuid = fish:GetAttribute("UUID") or fish.Name
            if harvestCooldown[uuid] and
               os.clock() - harvestCooldown[uuid] < 3 then
                return
            end

            harvestCooldown[uuid] = os.clock()
            pcall(function() R.HarvestFish:FireServer(fish) end)
        end

        local function pantauIkan(fish)
            if not fish:IsA("Model") then return end
            local c = fish:GetAttributeChangedSignal("IsReady"):Connect(function()
                panenIkan(fish)
            end)
            table.insert(conns.fish, c)
        end

        for _, fish in ipairs(folder:GetChildren()) do
            panenIkan(fish)
            pantauIkan(fish)
        end

        local cAdded = folder.ChildAdded:Connect(function(child)
            if not state.fish then return end
            task.wait(0.5)
            panenIkan(child)
            pantauIkan(child)
        end)
        table.insert(conns.fish, cAdded)

        threads.fishPoll = task.spawn(function()
            while state.fish do
                task.wait(8)
                if not state.fish then break end
                local z = getMySafeZone()
                local f = z and z:FindFirstChild("Fish")
                if f then
                    for _, fish in ipairs(f:GetChildren()) do
                        if not state.fish then break end
                        panenIkan(fish)
                        task.wait(0.3)
                    end
                end
            end
        end)

        threads.fishZone = task.spawn(function()
            local lastZone = zone
            while state.fish do
                task.wait(5)
                local newZone = getMySafeZone()
                if newZone and newZone ~= lastZone then
                    lastZone = newZone
                    clearConns("fish")
                    cancelThread("fishPoll")
                    harvestCooldown = {}
                    local newFolder = newZone:FindFirstChild("Fish")
                    if newFolder then
                        for _, fish in ipairs(newFolder:GetChildren()) do
                            panenIkan(fish)
                            pantauIkan(fish)
                        end
                        local c2 = newFolder.ChildAdded:Connect(function(child)
                            if not state.fish then return end
                            task.wait(0.5)
                            panenIkan(child)
                            pantauIkan(child)
                        end)
                        table.insert(conns.fish, c2)
                    end
                end
            end
        end)

    else
        clearConns("fish")
        cancelThread("fishPoll")
        cancelThread("fishZone")
    end
end)
	
	-- [ ALAM ]
	local AlamSec = CreateExpandableSection(FarmTab, "🍄 Alam")
	
	local ShroomCard = CreateFeatureCard(AlamSec, "Auto Harvest Jamur", 32)
AttachSwitch(ShroomCard, false, function(active)
    state.shroom = active
    if active then
        clearConns("shroom")

        local zone = getMySafeZone()
        local harvestCooldown = {}

        local function panenJamur(shroom)
            if not state.shroom then return end
            if not shroom or not shroom.Parent then return end
            if shroom:GetAttribute("HarvestActive") ~= true then return end

            local id = shroom.Name
            if harvestCooldown[id] and
               os.clock() - harvestCooldown[id] < 3 then
                return
            end

            local part = shroom:FindFirstChild("Part")
            if not part then return end

            harvestCooldown[id] = os.clock()
            pcall(function() R.DecoHarvest:FireServer(part) end)
        end

        local function pantauJamur(shroom)
            local c = shroom:GetAttributeChangedSignal("HarvestActive"):Connect(function()
                panenJamur(shroom)
            end)
            table.insert(conns.shroom, c)
        end

        local function connectShroomsInZone(z)
            local m = z:FindFirstChild("Unlocks") and z.Unlocks:FindFirstChild("Mushrooms")
            if not m then return end
            for _, g in ipairs(m:GetChildren()) do
                for _, shroom in ipairs(g:GetChildren()) do
                    panenJamur(shroom)
                    pantauJamur(shroom)
                end
            end
        end

        if zone then connectShroomsInZone(zone) end

        -- Polling fallback tiap 8 detik
        threads.shroomPoll = task.spawn(function()
            while state.shroom do
                task.wait(8)
                if not state.shroom then break end
                local z = getMySafeZone()
                if z then
                    local m = z:FindFirstChild("Unlocks") and z.Unlocks:FindFirstChild("Mushrooms")
                    if m then
                        for _, g in ipairs(m:GetChildren()) do
                            for _, shroom in ipairs(g:GetChildren()) do
                                if not state.shroom then break end
                                panenJamur(shroom)
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end
        end)

        -- Zone change monitor
        threads.shroomZone = task.spawn(function()
            local lastZone = zone
            while state.shroom do
                task.wait(5)
                local newZone = getMySafeZone()
                if newZone and newZone ~= lastZone then
                    lastZone = newZone
                    clearConns("shroom")
                    cancelThread("shroomPoll")
                    harvestCooldown = {}
                    connectShroomsInZone(newZone)
                end
            end
        end)

    else
        clearConns("shroom")
        cancelThread("shroomPoll")
        cancelThread("shroomZone")
    end
end)

	local TreeCard = CreateFeatureCard(AlamSec, "Auto Harvest Pohon", 32)
AttachSwitch(TreeCard, false, function(active)
    state.tree = active
    if active then
        clearConns("tree")

        local zone = getMySafeZone()
        local harvestCooldown = {}

        local function panenBuahJatuh(child)
            if not state.tree then return end
            if not child or not child.Parent then return end
            if not child.Name:find("DroppedApple_") then return end

            local id = child:GetAttribute("AppleId") or child.Name
            if harvestCooldown[id] and
               os.clock() - harvestCooldown[id] < 3 then
                return
            end

            local part = child:FindFirstChild("Part")
            if not part then return end

            harvestCooldown[id] = os.clock()
            pcall(function() R.ApplePickup:FireServer(child) end)
            task.wait(0.1)
            pcall(function() R.DecoHarvest:FireServer(part) end)
        end

        local function panenGummy(child)
            if not state.tree then return end
            if not child or not child.Parent then return end
            if child:GetAttribute("HarvestActive") ~= true then return end

            local id = child.Name
            if harvestCooldown[id] and
               os.clock() - harvestCooldown[id] < 3 then
                return
            end

            local part = child:FindFirstChild("Part")
            if not part then return end

            harvestCooldown[id] = os.clock()
            pcall(function() R.DecoHarvest:FireServer(part) end)
        end

        local function connectTreesInZone(z)
            local trees = z:FindFirstChild("Unlocks") and z.Unlocks:FindFirstChild("Trees")
            if not trees then return end

            for _, tree in ipairs(trees:GetChildren()) do
                -- Panen buah yang sudah jatuh
                for _, child in ipairs(tree:GetChildren()) do
                    if child.Name:find("DroppedApple_") then
                        task.spawn(function() panenBuahJatuh(child) end)
                    end
                    if child:GetAttribute("HarvestActive") == true then
                        task.spawn(function() panenGummy(child) end)
                    end
                end

                -- Listener buah baru jatuh
                local c1 = tree.ChildAdded:Connect(function(child)
                    if not state.tree then return end
                    task.wait(0.3)
                    panenBuahJatuh(child)
                end)
                table.insert(conns.tree, c1)

                -- Listener HarvestActive (Gummy)
                for _, child in ipairs(tree:GetChildren()) do
                    if child:GetAttribute("HarvestActive") ~= nil then
                        local c2 = child:GetAttributeChangedSignal("HarvestActive"):Connect(function()
                            panenGummy(child)
                        end)
                        table.insert(conns.tree, c2)
                    end
                end
            end
        end

        if zone then connectTreesInZone(zone) end

        -- Polling fallback buah jatuh tiap 8 detik
        threads.treePoll = task.spawn(function()
            while state.tree do
                task.wait(8)
                if not state.tree then break end
                local z = getMySafeZone()
                if z then
                    local trees = z:FindFirstChild("Unlocks") and z.Unlocks:FindFirstChild("Trees")
                    if trees then
                        for _, tree in ipairs(trees:GetChildren()) do
                            for _, child in ipairs(tree:GetChildren()) do
                                if not state.tree then break end
                                if child.Name:find("DroppedApple_") then
                                    panenBuahJatuh(child)
                                    task.wait(0.3)
                                end
                                if child:GetAttribute("HarvestActive") == true then
                                    panenGummy(child)
                                    task.wait(0.3)
                                end
                            end
                        end
                    end
                end
            end
        end)

        -- Zone change monitor
        threads.treeZone = task.spawn(function()
            local lastZone = zone
            while state.tree do
                task.wait(5)
                local newZone = getMySafeZone()
                if newZone and newZone ~= lastZone then
                    lastZone = newZone
                    clearConns("tree")
                    cancelThread("treePoll")
                    harvestCooldown = {}
                    connectTreesInZone(newZone)
                end
            end
        end)

    else
        clearConns("tree")
        cancelThread("treePoll")
        cancelThread("treeZone")
    end
end)

-- ========================
-- SECTION: SHY EGG EVENT
-- ========================
local EventSec = CreateExpandableSection(EventTab, "🥚 Shy Egg Event")

local ShyEggStatus  = Remotes:WaitForChild("ShyEggStatusEvent")
local ShyEggJoin    = Remotes:WaitForChild("ShyEggJoinEvent")
local ShyEggSpawned = Remotes:WaitForChild("ShyEggSpawnedEvent")
local ShyEggHitR    = Remotes:WaitForChild("EggHitEvent")
local EggLoot       = Remotes:WaitForChild("EggLootEvent")

local myEggName     = "ShyEgg_" .. tostring(player.UserId)
local eggJoined     = false
local eggAlive      = false
local eventActive   = false  -- status event terakhir diketahui

local eggSpawnConn  = nil
local eggLootConn   = nil
local statusConn    = nil

-- Cari egg MILIK PLAYER saja
local function getMyEgg()
    local egg = workspace:FindFirstChild(myEggName)
    if egg and egg:IsA("Model") then
        return egg
    end
end

local function getMyEggRoot()
    local egg = getMyEgg()
    return egg and egg:FindFirstChild("Root")
end

local function getHRP()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function doJoin()
    ShyEggJoin:FireServer()
    task.wait(0.8)
    ShyEggJoin:FireServer()
    eggJoined = true
end

local function startHitLoop()
    cancelThread("eggHit")
    threads.eggHit = task.spawn(function()
        while state.autoHit and eggAlive do
            local root = getMyEggRoot()
            local hrp  = getHRP()
            if root and hrp and root.Position.Y >= 0 then
                hrp.CFrame = CFrame.new(root.Position + Vector3.new(3, 0, 0))
                task.wait(0.05)
                pcall(function() ShyEggHitR:FireServer() end)
                task.wait(0.2)
            elseif not root then
                eggAlive = false
                break
            else
                task.wait(0.3)
            end
        end
    end)
end

-- ========================
-- FITUR 1: AUTO JOIN
-- ========================
local JoinCard = CreateFeatureCard(EventSec, "Auto Join Event", 32)
AttachSwitch(JoinCard, false, function(active)
    state.autoJoin = active

    if active then
        -- Cek apakah event sudah aktif saat toggle ON
        -- dengan cek egg milik player sudah ada atau tidak
        if getMyEgg() then
            -- Sudah join sebelumnya (egg sudah ada)
            eggJoined = true
            eggAlive  = true
        elseif eventActive and not eggJoined then
            -- Event aktif tapi belum join
            doJoin()
        end

        -- Listen status event
        -- (handle join saat event muncul berikutnya)
        if statusConn then statusConn:Disconnect() end
        statusConn = ShyEggStatus.OnClientEvent:Connect(function(isActive, duration, isJoined)
            eventActive = isActive
            if isActive then
                if state.autoJoin and not eggJoined then
                    doJoin()
                end
            else
                -- Event selesai
                eggJoined  = false
                eggAlive   = false
                eventActive = false
                cancelThread("eggHit")
            end
        end)

    else
        if statusConn then statusConn:Disconnect() statusConn = nil end
        eggJoined = false
    end
end)

-- ========================
-- FITUR 2: AUTO HIT
-- ========================
local HitCard = CreateFeatureCard(EventSec, "Auto Hit Egg", 32)
AttachSwitch(HitCard, false, function(active)
    state.autoHit = active

    if active then
        -- Disconnect listener lama
        if eggSpawnConn then eggSpawnConn:Disconnect() eggSpawnConn = nil end
        if eggLootConn  then eggLootConn:Disconnect()  eggLootConn  = nil end

        -- Kalau egg milik player sudah ada langsung hit
        if getMyEgg() then
            eggAlive = true
            startHitLoop()
        end

        -- Egg baru spawn (setelah kill)
        eggSpawnConn = ShyEggSpawned.OnClientEvent:Connect(function(level)
            if not state.autoHit then return end
            eggAlive = true
            -- Tunggu egg muncul di workspace
            task.wait(1)
            startHitLoop()
        end)

        -- Egg mati
        eggLootConn = EggLoot.OnClientEvent:Connect(function()
            if not state.autoHit then return end
            eggAlive = false
            cancelThread("eggHit")
            -- ShyEggSpawnedEvent akan handle egg berikutnya
        end)

    else
        cancelThread("eggHit")
        eggAlive = false
        if eggSpawnConn then eggSpawnConn:Disconnect() eggSpawnConn = nil end
        if eggLootConn  then eggLootConn:Disconnect()  eggLootConn  = nil end
    end
end)

-- Cleanup
if API.Session then
    local prev = API.Session.StopCookARecipe
    API.Session.StopCookARecipe = function()
        if prev then prev() end
        state.autoJoin = false
        state.autoHit  = false
        cancelThread("eggHit")
        eggJoined  = false
        eggAlive   = false
        eventActive = false
        if statusConn   then statusConn:Disconnect()   end
        if eggSpawnConn then eggSpawnConn:Disconnect() end
        if eggLootConn  then eggLootConn:Disconnect()  end
    end
	end


	-- ========================
	-- [6] CLEANUP
	-- ========================
	if API.Session then
		API.Session.StopCookARecipe = function()
    for k in pairs(state) do state[k] = false end
    for k in pairs(threads) do cancelThread(k) end
    for k in pairs(conns) do clearConns(k) end
    cancelThread("animalPoll") cancelThread("animalZone")
    cancelThread("fishPoll")   cancelThread("fishZone")
    cancelThread("shroomPoll") cancelThread("shroomZone")
    cancelThread("treePoll")   cancelThread("treeZone")
    eggJoined = false
		end
	end
end
