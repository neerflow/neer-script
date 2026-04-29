local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:WaitForChild("Remotes")
local HarvestSeed = Remotes:WaitForChild("HarvestSeedEvent")
local PlantSeed = Remotes:WaitForChild("PlantSeedEvent")
local EggHit = Remotes:WaitForChild("EggHitEvent")
local EggJoin = Remotes:WaitForChild("ShyEggJoinEvent")
local DecoHarvest = Remotes:WaitForChild("DecorationHarvestEvent")
local ApplePickup = Remotes:WaitForChild("ApplePickupEvent")
local player = game.Players.LocalPlayer
local Zones = workspace:WaitForChild("Zones")

-- State
local isHarvestOn, isPlantOn, isEggOn, isShroomOn, isTreeOn = false, false, false, false, false
local harvestThread, plantThread, eggThread = nil, nil, nil
local shroomConnections, treeConnections = {}, {}
local selectedSeed = "carrot"
local isMinimized = false

local seeds = {
    "carrot","tomato","alien_plant","golden_plant","mythic_plant",
    "brocolli_plant","cabbage_plant","leek_plant","couliflower_plant",
    "paprika_plant","glowleaf_plant","sunmelon_plant","voidberry_plant"
}

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

local function isPlotReady(plot)
    if plot:GetAttribute("FullyGrown") then return true end
    local p = plot:FindFirstChildWhichIsA("Model")
    return p and p:GetAttribute("IsReady") == true
end

local function isPlotEmpty(plot)
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

-- ========================
-- GUI — LANDSCAPE MOBILE
-- ========================
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = game.CoreGui

local FULL_W = 580
local FULL_H = 200
local MINI_H = 36

local fr = Instance.new("Frame")
fr.Size = UDim2.new(0, FULL_W, 0, FULL_H)
fr.Position = UDim2.new(0.5, -(FULL_W/2), 0, 10)
fr.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
fr.BorderSizePixel = 0
fr.Active = true
fr.Draggable = true
fr.Parent = sg
Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 10)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = fr
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -80, 1, 0)
titleLbl.Position = UDim2.new(0, 10, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "🍳 Cook a Recipe Auto"
titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLbl.TextSize = 13
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = titleBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -62, 0.5, -14)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(255,255,255)
minBtn.TextSize = 13
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -30, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.TextSize = 13
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Content
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -16, 1, -44)
content.Position = UDim2.new(0, 8, 0, 40)
content.BackgroundTransparency = 1
content.Parent = fr

-- Grid layout (2 baris)
local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0, 130, 0, 70)
grid.CellPadding = UDim2.new(0, 6, 0, 6)
grid.FillDirection = Enum.FillDirection.Horizontal
grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
grid.VerticalAlignment = Enum.VerticalAlignment.Top
grid.Parent = content

-- ========================
-- Helper buat card
-- ========================
local function makeCard(title, color)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
    card.BorderSizePixel = 0
    card.Parent = content
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 0, 26)
    lbl.Position = UDim2.new(0, 4, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = color
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.TextWrapped = true
    lbl.Parent = card

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 28)
    btn.Position = UDim2.new(0.5, -35, 1, -32)
    btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = card
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    return btn
end

local function setBtn(btn, state)
    if state then
        btn.Text = "ON"
        btn.BackgroundColor3 = Color3.fromRGB(50, 170, 80)
    else
        btn.Text = "OFF"
        btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
end

-- ========================
-- CARD: Auto Harvest
-- ========================
local harvestBtn = makeCard("🌾 Auto\nHarvest", Color3.fromRGB(100, 220, 100))

-- ========================
-- CARD: Auto Plant + Dropdown
-- ========================
local plantCard = Instance.new("Frame")
plantCard.BackgroundColor3 = Color3.fromRGB(30, 30, 48)
plantCard.BorderSizePixel = 0
plantCard.Parent = content
Instance.new("UICorner", plantCard).CornerRadius = UDim.new(0, 8)

local plantLbl = Instance.new("TextLabel")
plantLbl.Size = UDim2.new(1, -4, 0, 20)
plantLbl.Position = UDim2.new(0, 2, 0, 3)
plantLbl.BackgroundTransparency = 1
plantLbl.Text = "🌱 Auto Plant"
plantLbl.TextColor3 = Color3.fromRGB(100, 180, 255)
plantLbl.TextSize = 11
plantLbl.Font = Enum.Font.GothamBold
plantLbl.TextXAlignment = Enum.TextXAlignment.Center
plantLbl.Parent = plantCard

-- Dropdown seed di dalam card
local dropBtn = Instance.new("TextButton")
dropBtn.Size = UDim2.new(1, -8, 0, 20)
dropBtn.Position = UDim2.new(0, 4, 0, 24)
dropBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
dropBtn.Text = "▼ " .. selectedSeed
dropBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
dropBtn.TextSize = 9
dropBtn.Font = Enum.Font.Gotham
dropBtn.BorderSizePixel = 0
dropBtn.TextXAlignment = Enum.TextXAlignment.Left
dropBtn.Parent = plantCard
Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 4)
Instance.new("UIPadding", dropBtn).PaddingLeft = UDim.new(0, 4)

local plantBtn = Instance.new("TextButton")
plantBtn.Size = UDim2.new(0, 70, 0, 22)
plantBtn.Position = UDim2.new(0.5, -35, 1, -26)
plantBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
plantBtn.Text = "OFF"
plantBtn.TextColor3 = Color3.fromRGB(255,255,255)
plantBtn.TextSize = 12
plantBtn.Font = Enum.Font.GothamBold
plantBtn.BorderSizePixel = 0
plantBtn.Parent = plantCard
Instance.new("UICorner", plantBtn).CornerRadius = UDim.new(0, 6)

-- Dropdown list (ZIndex tinggi, overlay)
local dropList = Instance.new("Frame")
dropList.Size = UDim2.new(0, 130, 0, 120)
dropList.Position = UDim2.new(0, 8, 0, 108)
dropList.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
dropList.BorderSizePixel = 0
dropList.ClipsDescendants = true
dropList.Visible = false
dropList.ZIndex = 20
dropList.Parent = fr
Instance.new("UICorner", dropList).CornerRadius = UDim.new(0, 6)

local dropScroll = Instance.new("ScrollingFrame")
dropScroll.Size = UDim2.new(1, 0, 1, 0)
dropScroll.BackgroundTransparency = 1
dropScroll.BorderSizePixel = 0
dropScroll.ScrollBarThickness = 3
dropScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
dropScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
dropScroll.ZIndex = 20
dropScroll.Parent = dropList
Instance.new("UIListLayout", dropScroll).Padding = UDim.new(0, 2)

local dropOpen = false
for _, seed in ipairs(seeds) do
    local item = Instance.new("TextButton")
    item.Size = UDim2.new(1, -4, 0, 22)
    item.BackgroundColor3 = seed == selectedSeed and Color3.fromRGB(50,120,50) or Color3.fromRGB(40,40,65)
    item.Text = seed
    item.TextColor3 = Color3.fromRGB(200,200,200)
    item.TextSize = 9
    item.Font = Enum.Font.Gotham
    item.BorderSizePixel = 0
    item.ZIndex = 21
    item.Parent = dropScroll
    Instance.new("UICorner", item).CornerRadius = UDim.new(0, 4)

    item.MouseButton1Click:Connect(function()
        selectedSeed = seed
        dropBtn.Text = "▼ " .. seed
        dropOpen = false
        dropList.Visible = false
        for _, c in ipairs(dropScroll:GetChildren()) do
            if c:IsA("TextButton") then
                c.BackgroundColor3 = Color3.fromRGB(40,40,65)
            end
        end
        item.BackgroundColor3 = Color3.fromRGB(50,120,50)
    end)
end

dropBtn.MouseButton1Click:Connect(function()
    dropOpen = not dropOpen
    dropList.Visible = dropOpen
    dropBtn.Text = (dropOpen and "▲ " or "▼ ") .. selectedSeed
end)

-- ========================
-- CARD: Jamur, Pohon, Egg
-- ========================
local shroomBtn = makeCard("🍄 Auto\nJamur", Color3.fromRGB(200, 150, 255))
local treeBtn = makeCard("🍎 Auto\nPohon", Color3.fromRGB(150, 220, 150))
local eggBtn = makeCard("🥚 Auto\nShy Egg", Color3.fromRGB(255, 180, 100))

-- Countdown egg (kecil di bawah tombol egg)
-- tidak ada status label, cukup countdown
local eggCountCard = eggBtn.Parent
local eggCountLbl = Instance.new("TextLabel")
eggCountLbl.Size = UDim2.new(1, -4, 0, 14)
eggCountLbl.Position = UDim2.new(0, 2, 0, 52)
eggCountLbl.BackgroundTransparency = 1
eggCountLbl.Text = ""
eggCountLbl.TextColor3 = Color3.fromRGB(100, 180, 255)
eggCountLbl.TextSize = 8
eggCountLbl.Font = Enum.Font.Gotham
eggCountLbl.TextXAlignment = Enum.TextXAlignment.Center
eggCountLbl.Parent = eggCountCard

-- ========================
-- MINIMIZE / CLOSE
-- ========================
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    content.Visible = not isMinimized
    fr.Size = isMinimized
        and UDim2.new(0, FULL_W, 0, MINI_H)
        or UDim2.new(0, FULL_W, 0, FULL_H)
    minBtn.Text = isMinimized and "□" or "—"
end)

closeBtn.MouseButton1Click:Connect(function()
    isHarvestOn=false isPlantOn=false isEggOn=false isShroomOn=false isTreeOn=false
    if harvestThread then task.cancel(harvestThread) end
    if plantThread then task.cancel(plantThread) end
    if eggThread then task.cancel(eggThread) end
    for _,c in ipairs(shroomConnections) do c:Disconnect() end
    for _,c in ipairs(treeConnections) do c:Disconnect() end
    sg:Destroy()
end)

-- ========================
-- AUTO HARVEST TANAMAN
-- ========================
harvestBtn.MouseButton1Click:Connect(function()
    isHarvestOn = not isHarvestOn
    setBtn(harvestBtn, isHarvestOn)
    if isHarvestOn then
        harvestThread = task.spawn(function()
            while isHarvestOn do
                local plots = getMyPlots()
                local harvested = 0
                for _, plot in ipairs(plots) do
                    if not isHarvestOn then break end
                    if isPlotReady(plot) then
                        pcall(function() HarvestSeed:FireServer(plot) end)
                        harvested = harvested + 1
                        task.wait(0.5)
                    end
                end
                if harvested == 0 then
                    local shortest = math.huge
                    for _, plot in ipairs(plots) do
                        local gt = plot:GetAttribute("GrowthTime")
                        local pa = plot:GetAttribute("PlantedAt")
                        if gt and pa then
                            local r = (pa + gt) - os.time()
                            if r > 0 and r < shortest then shortest = r end
                        end
                    end
                    shortest = math.max(shortest == math.huge and 10 or shortest, 3)
                    for t = shortest, 1, -1 do
                        if not isHarvestOn then break end
                        task.wait(1)
                    end
                else
                    task.wait(2)
                end
            end
        end)
    else
        if harvestThread then task.cancel(harvestThread) harvestThread = nil end
    end
end)

-- ========================
-- AUTO PLANT
-- ========================
plantBtn.MouseButton1Click:Connect(function()
    isPlantOn = not isPlantOn
    setBtn(plantBtn, isPlantOn)
    if isPlantOn then
        plantThread = task.spawn(function()
            while isPlantOn do
                local plots = getMyPlots()
                for _, plot in ipairs(plots) do
                    if not isPlantOn then break end
                    if isPlotEmpty(plot) then
                        pcall(function() PlantSeed:FireServer(selectedSeed, 1) end)
                        task.wait(0.5)
                    end
                end
                task.wait(5)
            end
        end)
    else
        if plantThread then task.cancel(plantThread) plantThread = nil end
    end
end)

-- ========================
-- AUTO JAMUR (event-based)
-- ========================
local function connectShrooms()
    for _,c in ipairs(shroomConnections) do c:Disconnect() end
    shroomConnections = {}
    for _, shroom in ipairs(getAllShrooms()) do
        if shroom:GetAttribute("HarvestActive") == true then
            local part = shroom:FindFirstChild("Part")
            if part then
                pcall(function() DecoHarvest:FireServer(part) end)
                task.wait(0.5)
            end
        end
        local conn = shroom:GetAttributeChangedSignal("HarvestActive"):Connect(function()
            if not isShroomOn then return end
            if shroom:GetAttribute("HarvestActive") == true then
                local part = shroom:FindFirstChild("Part")
                if part then pcall(function() DecoHarvest:FireServer(part) end) end
            end
        end)
        table.insert(shroomConnections, conn)
    end
end

shroomBtn.MouseButton1Click:Connect(function()
    isShroomOn = not isShroomOn
    setBtn(shroomBtn, isShroomOn)
    if isShroomOn then
        connectShrooms()
    else
        for _,c in ipairs(shroomConnections) do c:Disconnect() end
        shroomConnections = {}
    end
end)

-- ========================
-- AUTO POHON (event-based)
-- ========================
local function connectTrees()
    for _,c in ipairs(treeConnections) do c:Disconnect() end
    treeConnections = {}
    for _, tree in ipairs(getTreeFolders()) do
        for _, child in ipairs(tree:GetChildren()) do
            if child.Name:find("DroppedApple_") then
                local part = child:FindFirstChild("Part")
                if part then
                    pcall(function() ApplePickup:FireServer(child) end)
                    task.wait(0.1)
                    pcall(function() DecoHarvest:FireServer(part) end)
                    task.wait(0.5)
                end
            end
            if child:GetAttribute("HarvestActive") == true then
                local part = child:FindFirstChild("Part")
                if part then
                    pcall(function() DecoHarvest:FireServer(part) end)
                    task.wait(0.5)
                end
            end
        end

        local c1 = tree.ChildAdded:Connect(function(child)
            if not isTreeOn then return end
            if child.Name:find("DroppedApple_") then
                task.wait(0.3)
                local part = child:FindFirstChild("Part")
                if part then
                    pcall(function() ApplePickup:FireServer(child) end)
                    task.wait(0.1)
                    pcall(function() DecoHarvest:FireServer(part) end)
                end
            end
        end)
        table.insert(treeConnections, c1)

        for _, child in ipairs(tree:GetChildren()) do
            if child:GetAttribute("HarvestActive") ~= nil then
                local c2 = child:GetAttributeChangedSignal("HarvestActive"):Connect(function()
                    if not isTreeOn then return end
                    if child:GetAttribute("HarvestActive") == true then
                        local part = child:FindFirstChild("Part")
                        if part then pcall(function() DecoHarvest:FireServer(part) end) end
                    end
                end)
                table.insert(treeConnections, c2)
            end
        end
    end
end

treeBtn.MouseButton1Click:Connect(function()
    isTreeOn = not isTreeOn
    setBtn(treeBtn, isTreeOn)
    if isTreeOn then
        connectTrees()
    else
        for _,c in ipairs(treeConnections) do c:Disconnect() end
        treeConnections = {}
    end
end)

-- ========================
-- AUTO EGG HIT
-- ========================
local function stopEggThread()
    if eggThread then task.cancel(eggThread) eggThread = nil end
end

local function startEggHit()
    stopEggThread()

    -- JOIN LANGSUNG di sini, bukan di dalam task.spawn
    EggJoin:FireServer()
    task.wait(1)
    EggJoin:FireServer()
    task.wait(0.5)

    eggThread = task.spawn(function()
        while isEggOn do
            local hrp = getHRP()
            local eggRoot = getEggRoot()
            if hrp and eggRoot then
                if eggRoot.Position.Y < 0 then
                    task.wait(1)
                else
                    hrp.CFrame = CFrame.new(eggRoot.Position + Vector3.new(3, 0, 0))
                    task.wait(0.05)
                    pcall(function() EggHit:FireServer() end)
                    task.wait(0.2)
                end
            else
                task.wait(1)
            end
        end
    end)
end

workspace.ChildAdded:Connect(function(child)
    if child.Name:find("ShyEgg_") and isEggOn then
        stopEggThread()
        task.wait(1)
        startEggHit()
    end
end)

workspace.ChildRemoved:Connect(function(child)
    if child.Name:find("ShyEgg_") then
        sto
