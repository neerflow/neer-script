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
local selectedSeed   = "carrot"
local selectedAnimal = "chicken"
local selectedFish   = "nemo"
local isMinimized    = false
local eggJoined      = false

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
        if trees then for _, tree in ipairs(trees:GetChildren()) do table.insert(t, tree) end end
    end
    return t
end

local function cancelThread(key)
    if threads[key] then task.cancel(threads[key]) threads[key] = nil end
end

local function clearConns(key)
    for _, c in ipairs(conns[key]) do c:Disconnect() end
    conns[key] = {}
end

local function countInZone(folderName)
    local count = 0
    for _, zone in ipairs(Zones:GetChildren()) do
        local f = zone:FindFirstChild(folderName)
        if f then count = count + #f:GetChildren() end
    end
    return count
end

-- ========================
-- GUI
-- ========================
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder = 999
sg.Parent = game.CoreGui

local C = {
    bg      = Color3.fromRGB(15, 15, 22),
    sidebar = Color3.fromRGB(20, 20, 30),
    content = Color3.fromRGB(12, 12, 18),
    row     = Color3.fromRGB(22, 22, 34),
    rowOn   = Color3.fromRGB(28, 30, 55),
    accent  = Color3.fromRGB(99, 102, 241),
    on      = Color3.fromRGB(99, 102, 241),
    off     = Color3.fromRGB(45, 45, 60),
    text    = Color3.fromRGB(230, 230, 245),
    sub     = Color3.fromRGB(110, 110, 145),
    border  = Color3.fromRGB(35, 35, 52),
}

local FW, FH = 480, 340
local BALL_SIZE = 48

-- ========================
-- MINI BALL (saat minimize)
-- ========================
local ball = Instance.new("TextButton")
ball.Size = UDim2.new(0, BALL_SIZE, 0, BALL_SIZE)
ball.Position = UDim2.new(0, 16, 0.5, -BALL_SIZE/2)
ball.BackgroundColor3 = C.accent
ball.Text = "🍳"
ball.TextSize = 20
ball.Font = Enum.Font.Gotham
ball.BorderSizePixel = 0
ball.ZIndex = 10
ball.Visible = false
ball.Parent = sg
Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)
local ballStroke = Instance.new("UIStroke", ball)
ballStroke.Color = Color3.fromRGB(130, 133, 255)
ballStroke.Thickness = 2

-- ========================
-- MAIN FRAME
-- ========================
local main = Instance.new("Frame")
main.Size = UDim2.new(0, FW, 0, FH)
main.Position = UDim2.new(0, 16, 0.5, -FH/2)
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = sg
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", main).Color = C.border

-- Title Bar
local tbar = Instance.new("Frame")
tbar.Size = UDim2.new(1, 0, 0, 38)
tbar.BackgroundColor3 = C.sidebar
tbar.BorderSizePixel = 0
tbar.ZIndex = 2
tbar.Parent = main
Instance.new("UICorner", tbar).CornerRadius = UDim.new(0, 12)
local tbarFix = Instance.new("Frame")
tbarFix.Size = UDim2.new(1, 0, 0.5, 0)
tbarFix.Position = UDim2.new(0, 0, 0.5, 0)
tbarFix.BackgroundColor3 = C.sidebar
tbarFix.BorderSizePixel = 0
tbarFix.Parent = tbar

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 1.5)
accentLine.Position = UDim2.new(0, 0, 1, -1.5)
accentLine.BackgroundColor3 = C.accent
accentLine.BorderSizePixel = 0
accentLine.Parent = tbar

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1, -80, 1, 0)
titleLbl.Position = UDim2.new(0, 12, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "🍳  Cook a Recipe  |  Auto"
titleLbl.TextColor3 = C.text
titleLbl.TextSize = 12
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 3
titleLbl.Parent = tbar

local function makeTopBtn(xOff, txt, bg)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 26, 0, 26)
    b.Position = UDim2.new(1, xOff, 0.5, -13)
    b.BackgroundColor3 = bg
    b.Text = txt
    b.TextColor3 = C.text
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.ZIndex = 3
    b.Parent = tbar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local minBtn   = makeTopBtn(-60, "−", C.off)
local closeBtn = makeTopBtn(-30, "✕", Color3.fromRGB(200, 55, 55))

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 110, 1, -38)
sidebar.Position = UDim2.new(0, 0, 0, 38)
sidebar.BackgroundColor3 = C.sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = main
local sideStroke = Instance.new("UIStroke", sidebar)
sideStroke.Color = C.border
sideStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local sideList = Instance.new("UIListLayout")
sideList.Padding = UDim.new(0, 3)
sideList.Parent = sidebar
Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0, 6)

-- Content
local contentBg = Instance.new("Frame")
contentBg.Size = UDim2.new(1, -110, 1, -38)
contentBg.Position = UDim2.new(0, 110, 0, 38)
contentBg.BackgroundColor3 = C.content
contentBg.BorderSizePixel = 0
contentBg.Parent = main

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -8, 1, -8)
scroll.Position = UDim2.new(0, 4, 0, 4)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = C.accent
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = contentBg

local scrollList = Instance.new("UIListLayout")
scrollList.Padding = UDim.new(0, 3)
scrollList.Parent = scroll
Instance.new("UIPadding", scroll).PaddingTop = UDim.new(0, 4)

-- ========================
-- SECTION LABEL
-- ========================
local function makeSection(parent, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -6, 0, 18)
    f.BackgroundTransparency = 1
    f.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.accent
    lbl.TextSize = 8
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
end

-- ========================
-- TOGGLE ROW
-- ========================
local function makeToggle(parent, label, key, onEnable, onDisable)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 38)
    row.BackgroundColor3 = C.row
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -56, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C.text
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local toggleBg = Instance.new("TextButton")
    toggleBg.Size = UDim2.new(0, 38, 0, 20)
    toggleBg.Position = UDim2.new(1, -46, 0.5, -10)
    toggleBg.BackgroundColor3 = C.off
    toggleBg.Text = ""
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = row
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggleBg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local isOn = false
    state[key] = false

    toggleBg.MouseButton1Click:Connect(function()
        isOn = not isOn
        state[key] = isOn
        if isOn then
            toggleBg.BackgroundColor3 = C.on
            knob.Position = UDim2.new(1, -17, 0.5, -7)
            row.BackgroundColor3 = C.rowOn
            if onEnable then onEnable() end
        else
            toggleBg.BackgroundColor3 = C.off
            knob.Position = UDim2.new(0, 3, 0.5, -7)
            row.BackgroundColor3 = C.row
            if onDisable then onDisable() end
        end
    end)
end

-- ========================
-- DROPDOWN ROW
-- ========================
local function makeDropdown(parent, label, items, default, callback)
    local selected = default

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -6, 0, 38)
    row.BackgroundColor3 = C.row
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.42, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C.sub
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local dBtn = Instance.new("TextButton")
    dBtn.Size = UDim2.new(0.52, 0, 0, 24)
    dBtn.Position = UDim2.new(0.44, 0, 0.5, -12)
    dBtn.BackgroundColor3 = C.off
    dBtn.Text = "▾  " .. selected
    dBtn.TextColor3 = C.text
    dBtn.TextSize = 9
    dBtn.Font = Enum.Font.Gotham
    dBtn.BorderSizePixel = 0
    dBtn.TextXAlignment = Enum.TextXAlignment.Left
    dBtn.Parent = row
    Instance.new("UICorner", dBtn).CornerRadius = UDim.new(0, 5)
    Instance.new("UIPadding", dBtn).PaddingLeft = UDim.new(0, 7)

    local isOpen = false
    local dList = Instance.new("Frame")
    dList.Size = UDim2.new(0, 160, 0, 130)
    dList.BackgroundColor3 = C.sidebar
    dList.BorderSizePixel = 0
    dList.Visible = false
    dList.ZIndex = 50
    dList.Parent = sg
    Instance.new("UICorner", dList).CornerRadius = UDim.new(0, 8)
    local dStroke = Instance.new("UIStroke", dList)
    dStroke.Color = C.accent
    dStroke.Thickness = 1.5

    local dScroll = Instance.new("ScrollingFrame")
    dScroll.Size = UDim2.new(1,-6,1,-6)
    dScroll.Position = UDim2.new(0,3,0,3)
    dScroll.BackgroundTransparency = 1
    dScroll.BorderSizePixel = 0
    dScroll.ScrollBarThickness = 2
    dScroll.ScrollBarImageColor3 = C.accent
    dScroll.CanvasSize = UDim2.new(0,0,0,0)
    dScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    dScroll.ZIndex = 50
    dScroll.Parent = dList
    Instance.new("UIListLayout", dScroll).Padding = UDim.new(0, 2)

    for _, item in ipairs(items) do
        local it = Instance.new("TextButton")
        it.Size = UDim2.new(1,-4,0,22)
        it.BackgroundColor3 = item == selected and C.rowOn or Color3.fromRGB(28,28,42)
        it.Text = item
        it.TextColor3 = item == selected and C.text or C.sub
        it.TextSize = 9
        it.Font = Enum.Font.Gotham
        it.BorderSizePixel = 0
        it.ZIndex = 51
        it.TextXAlignment = Enum.TextXAlignment.Left
        it.Parent = dScroll
        Instance.new("UICorner", it).CornerRadius = UDim.new(0, 5)
        Instance.new("UIPadding", it).PaddingLeft = UDim.new(0, 8)

        it.MouseButton1Click:Connect(function()
            selected = item
            dBtn.Text = "▾  " .. item
            isOpen = false
            dList.Visible = false
            for _, c in ipairs(dScroll:GetChildren()) do
                if c:IsA("TextButton") then
                    c.BackgroundColor3 = c.Text == selected and C.rowOn or Color3.fromRGB(28,28,42)
                    c.TextColor3 = c.Text == selected and C.text or C.sub
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
            dList.Position = UDim2.new(0, abs.X, 0, abs.Y + sz.Y + 2)
            dList.Visible = true
            dBtn.Text = "▴  " .. selected
        else
            dList.Visible = false
            dBtn.Text = "▾  " .. selected
        end
    end)
end

-- ========================
-- TAB BUILDER
-- ========================
local tabPages = {}

local function makeTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 34)
    btn.BackgroundColor3 = C.bg
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    Instance.new("UIPadding", btn).PaddingLeft = UDim.new(0, 4)

    local iconL = Instance.new("TextLabel")
    iconL.Size = UDim2.new(0, 22, 1, 0)
    iconL.Position = UDim2.new(0, 6, 0, 0)
    iconL.BackgroundTransparency = 1
    iconL.Text = icon
    iconL.TextSize = 13
    iconL.Font = Enum.Font.Gotham
    iconL.Parent = btn

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1, -32, 1, 0)
    nameL.Position = UDim2.new(0, 30, 0, 0)
    nameL.BackgroundTransparency = 1
    nameL.Text = name
    nameL.TextColor3 = C.sub
    nameL.TextSize = 10
    nameL.Font = Enum.Font.GothamBold
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.Parent = btn

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -6, 0, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.Parent = scroll

    local pList = Instance.new("UIListLayout")
    pList.Padding = UDim.new(0, 3)
    pList.Parent = page

    tabPages[name] = {btn=btn, page=page, nameL=nameL}

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabPages) do
            t.page.Visible = false
            t.btn.BackgroundColor3 = C.bg
            t.nameL.TextColor3 = C.sub
        end
        page.Visible = true
        btn.BackgroundColor3 = C.rowOn
        nameL.TextColor3 = C.text
    end)

    return page
end

-- ========================
-- BUILD TABS
-- ========================
local farmPage   = makeTab("Farm",       "🌾")
local ternakPage = makeTab("Ternak",     "🐄")
local alamPage   = makeTab("Alam",       "🍄")
local eventPage  = makeTab("Event",      "🥚")

-- Default
tabPages["Farm"].page.Visible = true
tabPages["Farm"].btn.BackgroundColor3 = C.rowOn
tabPages["Farm"].nameL.TextColor3 = C.text

-- ========================
-- FARM PAGE
-- ========================
makeSection(farmPage, "TANAMAN")

makeToggle(farmPage, "Auto Harvest", "harvest",
    function()
        cancelThread("harvest")
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
    end,
    function() cancelThread("harvest") end
)

makeToggle(farmPage, "Auto Plant", "plant",
    function()
        cancelThread("plant")
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
    end,
    function() cancelThread("plant") end
)

makeDropdown(farmPage, "🌱 Seed", SEEDS, selectedSeed, function(v) selectedSeed = v end)

-- ========================
-- TERNAK PAGE
-- ========================
makeSection(ternakPage, "HEWAN")

makeToggle(ternakPage, "Auto Panen Hewan", "animal",
    function()
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
    end,
    function() clearConns("animal") end
)

makeToggle(ternakPage, "Auto Spawn Hewan", "spawnAnimal",
    function()
        cancelThread("spawnAnimal")
        threads.spawnAnimal = task.spawn(function()
            while state.spawnAnimal do
                local ok, maxSpace = pcall(function()
                    return R.GetAnimalSpace:InvokeServer()
                end)
                if ok and maxSpace then
                    local current = countInZone("Animals")
                    local avail = maxSpace - current
                    for _ = 1, math.max(avail, 0) do
                        if not state.spawnAnimal then break end
                        pcall(function() R.SpawnAnimal:FireServer(selectedAnimal) end)
                        task.wait(0.5)
                    end
                end
                task.wait(10)
            end
        end)
    end,
    function() cancelThread("spawnAnimal") end
)

makeDropdown(ternakPage, "🐄 Hewan", ANIMALS, selectedAnimal, function(v) selectedAnimal = v end)

makeSection(ternakPage, "IKAN")

makeToggle(ternakPage, "Auto Panen Ikan", "fish",
    function()
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
    end,
    function() clearConns("fish") end
)

makeToggle(ternakPage, "Auto Spawn Ikan", "spawnFish",
    function()
        cancelThread("spawnFish")
        threads.spawnFish = task.spawn(function()
            while state.spawnFish do
                local ok, maxSpace = pcall(function()
                    return R.GetFishSpace:InvokeServer()
                end)
                if ok and maxSpace then
                    local current = countInZone("Fish")
                    local avail = maxSpace - current
                    for _ = 1, math.max(avail, 0) do
                        if not state.spawnFish then break end
                        pcall(function() R.SpawnFish:FireServer(selectedFish) end)
                        task.wait(0.5)
                    end
                end
                task.wait(10)
            end
        end)
    end,
    function() cancelThread("spawnFish") end
)

makeDropdown(ternakPage, "🐟 Ikan", FISH, selectedFish, function(v) selectedFish = v end)

-- ========================
-- ALAM PAGE
-- ========================
makeSection(alamPage, "JAMUR")

makeToggle(alamPage, "Auto Harvest Jamur", "shroom",
    function()
        clearConns("shroom")
        for _, shroom in ipairs(getAllShrooms()) do
            if shroom:GetAttribute("HarvestActive") == true then
                local part = shroom:FindFirstChild("Part")
                if part then pcall(function() R.DecoHarvest:FireServer(part) end) task.wait(0.5) end
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
    end,
    function() clearConns("shroom") end
)

makeSection(alamPage, "POHON")

makeToggle(alamPage, "Auto Harvest Pohon", "tree",
    function()
        clearConns("tree")
        for _, tree in ipairs(getTreeFolders()) do
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
                    if part then pcall(function() R.DecoHarvest:FireServer(part) end) task.wait(0.4) end
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
    end,
    function() clearConns("tree") end
)

-- ========================
-- EVENT PAGE
-- ========================
makeSection(eventPage, "SHY EGG")

makeToggle(eventPage, "Auto Hit Shy Egg", "egg",
    function() end,
    function() cancelThread("egg") eggJoined = false end
)

local timerRow = Instance.new("Frame")
timerRow.Size = UDim2.new(1, -6, 0, 32)
timerRow.BackgroundColor3 = C.row
timerRow.BorderSizePixel = 0
timerRow.Parent = eventPage
Instance.new("UICorner", timerRow).CornerRadius = UDim.new(0, 7)

local eggTimerLbl = Instance.new("TextLabel")
eggTimerLbl.Size = UDim2.new(1, -10, 1, 0)
eggTimerLbl.Position = UDim2.new(0, 10, 0, 0)
eggTimerLbl.BackgroundTransparency = 1
eggTimerLbl.Text = "⏱  Aktifkan untuk pantau event"
eggTimerLbl.TextColor3 = C.sub
eggTimerLbl.TextSize = 10
eggTimerLbl.Font = Enum.Font.Gotham
eggTimerLbl.TextXAlignment = Enum.TextXAlignment.Left
eggTimerLbl.Parent = timerRow

-- ========================
-- MINIMIZE → BALL
-- ========================
minBtn.MouseButton1Click:Connect(function()
    isMinimized = true
    main.Visible = false
    ball.Visible = true
end)

ball.MouseButton1Click:Connect(function()
    isMinimized = false
    ball.Visible = false
    main.Visible = true
end)

closeBtn.MouseButton1Click:Connect(function()
    for k in pairs(state) do state[k] = false end
    for k in pairs(threads) do cancelThread(k) end
    for k in pairs(conns) do clearConns(k) end
    sg:Destroy()
end)

-- ========================
-- EGG POLLING
-- ========================
task.spawn(function()
    while true do
        task.wait(1)
        local egg = getEggRoot()

        if state.egg then
            if egg then
                eggTimerLbl.Text = "🟢  Event berlangsung"
                eggTimerLbl.TextColor3 = C.on
            else
                local t = os.date("*t")
                local nxt = (t.min < 35 and (35-t.min) or (95-t.min)) * 60 - t.sec
                eggTimerLbl.Text = string.format("⏱  Event dalam  %d:%02d", math.floor(nxt/60), nxt%60)
                eggTimerLbl.TextColor3 = C.sub
            end
        else
            eggTimerLbl.Text = "⏱  Aktifkan untuk pantau event"
            eggTimerLbl.TextColor3 = C.sub
            if eggJoined then eggJoined = false cancelThread("egg") end
        end

        if egg and state.egg and not eggJoined then
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ShyEggJoinEvent"):FireServer()
            task.wait(0.8)
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ShyEggJoinEvent"):FireServer()
            eggJoined = true

            cancelThread("egg")
            threads.egg = task.spawn(function()
                while state.egg do
                    local hrp = getHRP()
                    local root = getEggRoot()
                    if hrp and root and root.Position.Y >= 0 then
                        hrp.CFrame = CFrame.new(root.Position + Vector3.new(3,0,0))
                        task.wait(0.05)
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EggHitEvent"):FireServer()
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
end)                    if isEmpty(plot) then
                        pcall(function() R.PlantSeed:FireServer(selectedSeed, 1) end)
                        task.wait(0.5)
                    end
                end
                task.wait(5)
            end
 .new("TextButton")
    dBtn.Size = UDim2.new(0.52, 0, 0, 24)
    dBtn.Position = UDim2.new(0.44, 0, 0.5, -12)
    dBtn.BackgroundColor3 = C.off
    dBtn.Text = "▾  " .. selected
    dBtn.TextColor3 = C.text
    dBtn.TextSize = 9
    dBtn.Font = Enum.Font.Gotham
    dBtn.BorderSizePixel = 0
    dBtn.TextXAlignment = Enum.TextXAlignment.Left
    dBtn.Parent = row
    Instance.new("UICorner", dBtn).CornerRadius = UDim.new(0, 5)
    Instance.new("UIPadding", dBtn).PaddingLeft = UDim.new(0, 7)

    local isOpen = false
    local dList = Instance.new("Frame")
    dList.Size = UDim2.new(0, 160, 0, 130)
    dList.BackgroundColor3 = C.sidebar
    dList.BorderSizePixel = 0
    dList.Visible = false
    dList.ZIndex = 50
    dList.Parent = sg
    Instance.new("UICorner", dList).CornerRadius = UDim.new(0, 8)
    local dStroke = Instance.new("UIStroke", dList)
    dStroke.Color = C.accent
    dStroke.Thickness = 1.5

    local dScroll = Instance.new("ScrollingFrame")
    dScroll.Size = UDim2.new(1,-6,1,-6)
    dScroll.Position = UDim2.new(0,3,0,3)
    dScroll.BackgroundTransparency = 1
    dScroll.BorderSizePixel = 0
    dScroll.ScrollBarThickness = 2
    dScroll.ScrollBarImageColor3 = C.accent
    dScroll.CanvasSize = UDim2.new(0,0,0,0)
    dScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    dScroll.ZIndex = 50
    dScroll.Parent = dList
    Instance.new("UIListLayout", dScroll).Padding = UDim.new(0, 2)

    for _, item in ipairs(items) do
        local it = Instance.new("TextButton")
        it.Size = UDim2.new(1,-4,0,22)
        it.BackgroundColor3 = item == selected and C.rowOn or Color3.fromRGB(28,28,42)
        it.Text = item
        it.TextColor3 = item == selected and C.text or C.sub
        it.TextSize = 9
        it.Font = Enum.Font.Gotham
        it.BorderSizePixel = 0
        it.ZIndex = 51
        it.TextXAlignment = Enum.TextXAlignment.Left
        it.Parent = dScroll
        Instance.new("UICorner", it).CornerRadius = UDim.new(0, 5)
        Instance.new("UIPadding", it).PaddingLeft = UDim.new(0, 8)

        it.MouseButton1Click:Connect(function()
            selected = item
            dBtn.Text = "▾  " .. item
            isOpen = false
            dList.Visible = false
            for _, c in ipairs(dScroll:GetChildren()) do
                if c:IsA("TextButton") then
                    c.BackgroundColor3 = c.Text == selected and C.rowOn or Color3.fromRGB(28,28,42)
                    c.TextColor3 = c.Text == selected and C.text or C.sub
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
            dList.Position = UDim2.new(0, abs.X, 0, abs.Y + sz.Y + 2)
            dList.Visible = true
            dBtn.Text = "▴  " .. selected
        else
            dList.Visible = false
            dBtn.Text = "▾  " .. selected
        end
    end)
end

-- ========================
-- TAB BUILDER
-- ========================
local tabPages = {}

local function makeTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 34)
    btn.BackgroundColor3 = C.bg
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    Instance.new("UIPadding", btn).PaddingLeft = UDim.new(0, 4)

    local iconL = Instance.new("TextLabel")
    iconL.Size = UDim2.new(0, 22, 1, 0)
    iconL.Position = UDim2.new(0, 6, 0, 0)
    iconL.BackgroundTransparency = 1
    iconL.Text = icon
    iconL.TextSize = 13
    iconL.Font = Enum.Font.Gotham
    iconL.Parent = btn

