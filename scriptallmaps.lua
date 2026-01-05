local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

--// THEME SETTINGS (Baby Blue & Dark Palette)
local Theme = {
    Main        = Color3.fromRGB(20, 25, 35), 
    Sidebar     = Color3.fromRGB(22, 26, 38),
    ActiveTab   = Color3.fromRGB(45, 55, 75),
    Accent      = Color3.fromRGB(137, 207, 240), -- Baby Blue
    Text        = Color3.fromRGB(255, 255, 255),
    TextDim     = Color3.fromRGB(160, 180, 190),
    Separator   = Color3.fromRGB(50, 60, 80),
    Transp      = 0.15 
}

--// CLEANUP
if CoreGui:FindFirstChild("NeeR_Unified") then
    CoreGui.NeeR_Unified:Destroy()
end

--// 1. SETUP SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeeR_Unified"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

--// VARIABLES & RESPONSIVE LOGIC
local IsOpen = true
local AnimationSpeed = 0.4
local CurrentScale = 1 

-- --> [LOGIKA UKURAN OTOMATIS PC VS MOBILE] <--
-- Mengecek lebar layar. Jika di bawah 800 pixel, dianggap Mobile/Tablet kecil.
local ViewportSize = workspace.CurrentCamera.ViewportSize
local IsMobile = ViewportSize.X < 8000

-- --> [UBAH UKURAN DEFAULT DISINI] <--
-- PCSize: Menggunakan Offset (Pixel) agar di monitor lebar tidak jadi "gepeng" panjang.
-- MobileSize: Menggunakan Scale (Persen) agar menyesuaikan layar HP.
local PCSize     = UDim2.new(0, 580, 0, 380)      -- (Lebar 580px, Tinggi 380px)
local MobileSize = UDim2.new(0.4, 0, 0.5, 0)    -- (Lebar 85%, Tinggi 65%)

local FinalSize  = IsMobile and MobileSize or PCSize

--// 2. FUNGSI DRAG (GLOBAL FIXED)
local function MakeDraggable(trigger, objectToMove)
    local dragging, dragInput, dragStart, startPos
    
    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = objectToMove.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    trigger.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            objectToMove.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--// 3. ICON TOGGLE
local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name = "ToggleUI"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Theme.Main
ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleBtn.Position = UDim2.new(0.08, 0, 0.15, 0)
ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
ToggleBtn.Image = "rbxassetid://7733960981"
ToggleBtn.ImageColor3 = Theme.Accent
ToggleBtn.ZIndex = 100

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Parent = ToggleBtn
ToggleStroke.Color = Theme.Accent
ToggleStroke.Thickness = 1.5
ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

MakeDraggable(ToggleBtn, ToggleBtn)

--// 4. MAIN FRAME CANVAS
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Theme.Main
MainFrame.BackgroundTransparency = Theme.Transp
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = FinalSize -- Menggunakan ukuran hasil logika responsif di atas
MainFrame.ClipsDescendants = true

local UIScale = Instance.new("UIScale")
UIScale.Parent = MainFrame
UIScale.Scale = CurrentScale

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1
MainStroke.Transparency = 0.6

--// HEADER
local HeaderHeight = 35
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, HeaderHeight)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Text = "NeeR Flow <font color=\"rgb(137,207,240)\">| Script</font>"
Title.RichText = true
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Theme.Text
Title.TextSize = 14
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0, 0, 1, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- CONTROL BUTTONS
local ControlFrame = Instance.new("Frame")
ControlFrame.Parent = Header
ControlFrame.BackgroundTransparency = 1
ControlFrame.Position = UDim2.new(1, -70, 0, 0)
ControlFrame.Size = UDim2.new(0, 70, 1, 0)

local MinBtn = Instance.new("TextButton")
MinBtn.Parent = ControlFrame
MinBtn.BackgroundTransparency = 1
MinBtn.Position = UDim2.new(0, 0, 0, 0)
MinBtn.Size = UDim2.new(0, 35, 1, 0)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.Accent
MinBtn.TextSize = 14

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = ControlFrame
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(0, 28, 0, 0)
CloseBtn.Size = UDim2.new(0, 35, 1, 0)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.Accent
CloseBtn.TextSize = 14

local HeaderLine = Instance.new("Frame")
HeaderLine.Parent = Header
HeaderLine.BackgroundColor3 = Theme.TextDim
HeaderLine.BorderSizePixel = 0
HeaderLine.BackgroundTransparency = 0.5
HeaderLine.Position = UDim2.new(0, 0, 1, -1)
HeaderLine.Size = UDim2.new(1, 0, 0, 1)

MakeDraggable(Header, MainFrame)

--// CONTAINER
local Container = Instance.new("Frame")
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 0, 0, HeaderHeight)
Container.Size = UDim2.new(1, 0, 1, -HeaderHeight)

--// SIDEBAR
local SidebarWidth = 130
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Parent = Container
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BackgroundTransparency = 0.5
Sidebar.BorderSizePixel = 0
Sidebar.Size = UDim2.new(0, SidebarWidth, 1, 0)
Sidebar.ScrollBarThickness = 0
Sidebar.ZIndex = 2

local SidebarStroke = Instance.new("UIStroke")
SidebarStroke.Parent = Sidebar
SidebarStroke.Color = Theme.Separator
SidebarStroke.Thickness = 1
SidebarStroke.Transparency = 0.5
SidebarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local SideList = Instance.new("UIListLayout")
SideList.Parent = Sidebar; SideList.Padding = UDim.new(0, 2); SideList.SortOrder = Enum.SortOrder.LayoutOrder
local SidePadding = Instance.new("UIPadding")
SidePadding.Parent = Sidebar; SidePadding.PaddingTop = UDim.new(0, 8); SidePadding.PaddingLeft = UDim.new(0, 5); SidePadding.PaddingRight = UDim.new(0, 5)

--// CONTENT AREA
local ContentArea = Instance.new("Frame")
ContentArea.Parent = Container
ContentArea.BackgroundTransparency = 1
ContentArea.Position = UDim2.new(0, SidebarWidth, 0, 0)
ContentArea.Size = UDim2.new(1, -SidebarWidth, 1, 0)
ContentArea.ClipsDescendants = true

--// LOGIC TABS
local Tabs = {}
local function SwitchTab(tabName)
    for _, page in pairs(ContentArea:GetChildren()) do
        if page:IsA("ScrollingFrame") then page.Visible = false end
    end
    if Tabs[tabName] then Tabs[tabName].Visible = true end
end

local function CreateTabBtn(name, isActive)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Sidebar
    Btn.BackgroundColor3 = isActive and Theme.ActiveTab or Theme.Sidebar
    Btn.BackgroundTransparency = isActive and 0 or 1
    Btn.Size = UDim2.new(1, 0, 0, 28)
    Btn.AutoButtonColor = false
    Btn.Font = Enum.Font.GothamMedium
    Btn.Text = name
    Btn.TextColor3 = isActive and Theme.Accent or Theme.TextDim
    Btn.TextSize = 12
    
    local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 4); Corner.Parent = Btn
    
    if isActive then
        local s = Instance.new("UIStroke"); s.Parent = Btn; s.Color = Theme.Accent; s.Thickness = 1; s.Transparency = 0.8
    end

    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Parent = ContentArea
    Page.BackgroundTransparency = 1
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Visible = isActive
    Page.ScrollBarThickness = 0
    
    local PL = Instance.new("UIListLayout"); PL.Parent = Page; PL.Padding = UDim.new(0, 5); PL.SortOrder = Enum.SortOrder.LayoutOrder
    local PP = Instance.new("UIPadding"); PP.Parent = Page; PP.PaddingTop = UDim.new(0, 10); PP.PaddingLeft = UDim.new(0, 10); PP.PaddingRight = UDim.new(0, 10)

    Tabs[name] = Page

    Btn.MouseButton1Click:Connect(function()
        for _, child in pairs(Sidebar:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Theme.Sidebar; child.BackgroundTransparency = 1; child.TextColor3 = Theme.TextDim
                if child:FindFirstChild("UIStroke") then child.UIStroke:Destroy() end
            end
        end
        Btn.BackgroundColor3 = Theme.ActiveTab; Btn.BackgroundTransparency = 0; Btn.TextColor3 = Theme.Accent
        local s = Instance.new("UIStroke"); s.Parent = Btn; s.Color = Theme.Accent; s.Thickness = 1; s.Transparency = 0.8
        SwitchTab(name)
    end)
    return Page
end

--// FUNGSI: MEMBUAT DASHBOARD INFO (DIPERBARUI)
local function BuildInfoTab(parentFrame)
    
    -- --> [UBAH JARAK ANTAR KARTU DISINI] <--
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = parentFrame
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 14) -- Ubah angka 14 untuk memperbesar/perkecil jarak antar bagian
    
    local Padding = Instance.new("UIPadding")
    Padding.Parent = parentFrame
    Padding.PaddingTop = UDim.new(0, 15)
    Padding.PaddingLeft = UDim.new(0, 15)
    Padding.PaddingRight = UDim.new(0, 15)

    -- Helper CreateCard
    local function CreateCard(size, layoutOrder)
        local Card = Instance.new("Frame")
        Card.Parent = parentFrame
        Card.BackgroundColor3 = Theme.ActiveTab
        Card.BackgroundTransparency = 0.2
        Card.Size = size
        Card.LayoutOrder = layoutOrder
        
		-- pinggiran tumpul tab info
        local C = Instance.new("UICorner")
        C.CornerRadius = UDim.new(0, 10)
        C.Parent = Card
        
		--tebal border
        local S = Instance.new("UIStroke")
        S.Parent = Card
        S.Color = Theme.Accent
        S.Transparency = 0.8
        S.Thickness = 1
        return Card
    end

    --// 1. PING SECTION (Top Bar)
    -- --> [UBAH TINGGI KARTU PING DISINI] <--
    local PingCard = CreateCard(UDim2.new(1, 0, 0,60), 1) 
    
	-- text network ping
    local PingTitle = Instance.new("TextLabel")
    PingTitle.Parent = PingCard
    PingTitle.BackgroundTransparency = 1
    PingTitle.Position = UDim2.new(0, 15, 0, 5)
    PingTitle.Size = UDim2.new(1, -30, 0, 20)
    PingTitle.Font = Enum.Font.GothamBold
    PingTitle.Text = "Network Ping"
    PingTitle.TextColor3 = Theme.TextDim
    PingTitle.TextSize = 12
    PingTitle.TextXAlignment = Enum.TextXAlignment.Left

	-- text ms
    local PingValue = Instance.new("TextLabel")
    PingValue.Parent = PingCard
    PingValue.BackgroundTransparency = 1
    PingValue.Position = UDim2.new(0, 15, 0, 5)
    PingValue.Size = UDim2.new(1, -30, 0, 20)
    PingValue.Font = Enum.Font.GothamBold
    PingValue.Text = "0 ms"
    PingValue.TextColor3 = Theme.Accent
    PingValue.TextSize = 12
    PingValue.TextXAlignment = Enum.TextXAlignment.Right

    -- Bar fill
    local BarBg = Instance.new("Frame")
    BarBg.Parent = PingCard
    BarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    BarBg.Position = UDim2.new(0, 15, 0, 35)
    BarBg.Size = UDim2.new(1, -30, 0, 10) -- Sedikit lebih tipis biar elegan
    local BarBgC = Instance.new("UICorner"); BarBgC.CornerRadius = UDim.new(1, 0); BarBgC.Parent = BarBg

	-- animasi barfill spawn
    local BarFill = Instance.new("Frame")
    BarFill.Parent = BarBg
    BarFill.BackgroundColor3 = Theme.Accent
    BarFill.Size = UDim2.new(0.5, 0, 1, 0)
    local BarFillC = Instance.new("UICorner"); BarFillC.CornerRadius = UDim.new(1, 0); BarFillC.Parent = BarFill

    --// 2. STATS GRID (FPS & MEMORY)
    -- --> [UBAH TINGGI KOTAK FPS/MEM DISINI] <--
    local GridHeight = 50 
    local GridContainer = Instance.new("Frame")
    GridContainer.Parent = parentFrame
    GridContainer.BackgroundTransparency = 1
    GridContainer.Size = UDim2.new(1,1, 0, GridHeight)
    GridContainer.LayoutOrder = 2

    local GL = Instance.new("UIGridLayout")
    GL.Parent = GridContainer
    GL.CellPadding = UDim2.new(0, 10, 0, 0) -- Jarak horizontal antar kotak
    GL.CellSize = UDim2.new(0.485, 0, 1, 0)  -- Otomatis bagi 2 (sekitar 48% lebar masing-masing)
    GL.SortOrder = Enum.SortOrder.LayoutOrder
    GL.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- FPS Box
    local FPSCard = CreateCard(UDim2.new(0,0,0,0), 1)
    FPSCard.Parent = GridContainer
    
    local FPSTitle = Instance.new("TextLabel")
    FPSTitle.Parent = FPSCard; FPSTitle.BackgroundTransparency = 1; 
    FPSTitle.Position = UDim2.new(0, 12, 0, 35); FPSTitle.Size = UDim2.new(1, -24, 0, 10)
    FPSTitle.Font = Enum.Font.GothamMedium; FPSTitle.Text = "FPS Counter"; 
    FPSTitle.TextColor3 = Theme.TextDim; FPSTitle.TextSize = 12; FPSTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local FPSNum = Instance.new("TextLabel")
    FPSNum.Parent = FPSCard; FPSNum.BackgroundTransparency = 1; 
    FPSNum.Position = UDim2.new(0, 12, 0, 12); FPSNum.Size = UDim2.new(1, -24, 0, 10)
    FPSNum.Font = Enum.Font.GothamBold; FPSNum.Text = "60"; 
    FPSNum.TextColor3 = Theme.Text; FPSNum.TextSize = 28; FPSNum.TextXAlignment = Enum.TextXAlignment.Left

    -- Memory Box
    local MemCard = CreateCard(UDim2.new(0,0,0,0), 2)
    MemCard.Parent = GridContainer
    
    local MemTitle = Instance.new("TextLabel")
    MemTitle.Parent = MemCard; MemTitle.BackgroundTransparency = 1; 
    MemTitle.Position = UDim2.new(0, 12, 0, 35); MemTitle.Size = UDim2.new(1, -24, 0, 10)
    MemTitle.Font = Enum.Font.GothamMedium; MemTitle.Text = "Memory RAM Used"; 
    MemTitle.TextColor3 = Theme.TextDim; MemTitle.TextSize = 12; MemTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local MemNum = Instance.new("TextLabel")
    MemNum.Parent = MemCard; MemNum.BackgroundTransparency = 1; 
    MemNum.Position = UDim2.new(0, 12, 0, 12); MemNum.Size = UDim2.new(1, -24, 0, 10)
    MemNum.Font = Enum.Font.GothamBold; MemNum.Text = "0"; 
    MemNum.TextColor3 = Theme.Text; MemNum.TextSize = 24; MemNum.TextXAlignment = Enum.TextXAlignment.Left

    --// 3. TIME SECTION (Bottom - Diperlebar & Ditambah Title)
    -- --> [UBAH TINGGI KARTU WAKTU DISINI] <--
    local TimeCard = CreateCard(UDim2.new(1, 0, 0, 55), 3) -- Saya tambah tingginya jadi 85 biar muat Title
    
    -- TITLE WAKTU (BARU)
    local TimeTitle = Instance.new("TextLabel")
    TimeTitle.Parent = TimeCard
    TimeTitle.BackgroundTransparency = 1
    TimeTitle.Position = UDim2.new(0, 15, 0, 2) -- Posisi paling atas
    TimeTitle.Size = UDim2.new(1, -30, 0, 20)
    TimeTitle.Font = Enum.Font.GothamBold
    TimeTitle.Text = "Time Server" -- Judul Baru
    TimeTitle.TextColor3 = Theme.TextDim
    TimeTitle.TextSize = 15
    TimeTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- JAM (Posisi diturunkan sedikit)
    local ClockLabel = Instance.new("TextLabel")
    ClockLabel.Parent = TimeCard
    ClockLabel.BackgroundTransparency = 1
    ClockLabel.Position = UDim2.new(0, 15, 0, 0) -- Turun ke bawah title
    ClockLabel.Size = UDim2.new(1, -30, 0, 35)
    ClockLabel.Font = Enum.Font.GothamBold
    ClockLabel.Text = "00:00:00"
    ClockLabel.TextColor3 = Theme.Text
    ClockLabel.TextSize = 34 -- Ukuran font sedikit diperbesar
    ClockLabel.TextXAlignment = Enum.TextXAlignment.Right

    -- TANGGAL
    local DateLabel = Instance.new("TextLabel")
    DateLabel.Parent = TimeCard
    DateLabel.BackgroundTransparency = 1
    DateLabel.Position = UDim2.new(0, 15, 0, 30)
    DateLabel.Size = UDim2.new(1, -30, 0, 20)
    DateLabel.Font = Enum.Font.GothamMedium
    DateLabel.Text = "Monday, 1 Jan 2024"
    DateLabel.TextColor3 = Theme.Accent
    DateLabel.TextSize = 14
    DateLabel.TextXAlignment = Enum.TextXAlignment.Right
    
   --// 4. REJOIN SERVER SECTION (ADDON)
    -- --> [UBAH TINGGI KARTU REJOIN DISINI] <--
    local RejoinCard = CreateCard(UDim2.new(1, 0, 0, 80), 4) -- LayoutOrder 4 (Setelah Time)

    -- Title Rejoin
    local RejoinTitle = Instance.new("TextLabel")
    RejoinTitle.Parent = RejoinCard
    RejoinTitle.BackgroundTransparency = 1
    RejoinTitle.Position = UDim2.new(0, 15, 0, 8)
    RejoinTitle.Size = UDim2.new(1, -30, 0, 20)
    RejoinTitle.Font = Enum.Font.GothamBold
    RejoinTitle.Text = "Session Control"
    RejoinTitle.TextColor3 = Theme.TextDim
    RejoinTitle.TextSize = 12
    RejoinTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Tombol Rejoin
    local RjBtn = Instance.new("TextButton")
    RjBtn.Parent = RejoinCard
    RjBtn.BackgroundColor3 = Theme.Sidebar -- Warna lebih gelap dikit
    RjBtn.Position = UDim2.new(0, 15, 0, 35)
    RjBtn.Size = UDim2.new(1, -30, 0, 35)
    RjBtn.Font = Enum.Font.GothamBold
    RjBtn.Text = "Rejoin Server"
    RjBtn.TextColor3 = Theme.Accent -- Teks warna Baby Blue
    RjBtn.TextSize = 14
    RjBtn.AutoButtonColor = true

    -- Styling Tombol
    local RjCorner = Instance.new("UICorner")
    RjCorner.CornerRadius = UDim.new(0, 8)
    RjCorner.Parent = RjBtn

    local RjStroke = Instance.new("UIStroke")
    RjStroke.Parent = RjBtn
    RjStroke.Color = Theme.Accent
    RjStroke.Thickness = 1
    RjStroke.Transparency = 0.7
    RjStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Logika Rejoin
    RjBtn.MouseButton1Click:Connect(function()
        local TS = game:GetService("TeleportService")
        local LP = game:GetService("Players").LocalPlayer
        
        -- Efek Visual saat diklik
        RjBtn.Text = "Rejoining..."
        RjBtn.BackgroundTransparency = 0.5
        
        -- Eksekusi Rejoin (Mencoba masuk ke JobId yang sama)
        TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end)

    --// 4. LOGIC UPDATE
    task.spawn(function()
        local LocalPlayer = Players.LocalPlayer
        while parentFrame.Parent do
            local rawPing = LocalPlayer:GetNetworkPing()
            local ping = math.round(rawPing * 1000) 
            
            PingValue.Text = ping .. " ms"
            local barSize = math.clamp(ping / 300, 0.05, 1) 
            
            TweenService:Create(BarFill, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
                Size = UDim2.new(barSize, 0, 1, 0),
                BackgroundColor3 = ping < 100 and Color3.fromRGB(100, 255, 100)
                                or ping < 200 and Color3.fromRGB(255, 200, 0)
                                or Color3.fromRGB(255, 80, 80)
            }):Play()
            
            local fps = math.floor(workspace:GetRealPhysicsFPS())
            FPSNum.Text = tostring(fps)
            
            local mem = math.floor(Stats:GetTotalMemoryUsageMb())
            MemNum.Text = tostring(mem)
            
            ClockLabel.Text = os.date("%H:%M:%S")
            DateLabel.Text = os.date("%A, %d %B %Y")
            
            task.wait(0.5)

			
        end
    end)
end

--// KUMPULAN TAB
local TabInfo = CreateTabBtn("Info", true) 
BuildInfoTab(TabInfo) 

local TabAuto = CreateTabBtn("Auto Farm", false)
CreateTabBtn("Teleports", false)
local TabSettings = CreateTabBtn("Settings", false)

--// ISI HALAMAN SETTINGS (DPI CONTROL)
local SettingsLabel = Instance.new("TextLabel")
SettingsLabel.Parent = TabSettings
SettingsLabel.BackgroundTransparency = 1
SettingsLabel.Size = UDim2.new(0, 0, 0, 20)
SettingsLabel.Font = Enum.Font.GothamBold
SettingsLabel.Text = "Interface Scale (DPI)"
SettingsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsLabel.TextSize = 14
SettingsLabel.TextXAlignment = Enum.TextXAlignment.Left

local DPIBtn = Instance.new("TextButton")
DPIBtn.Parent = TabSettings
DPIBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
DPIBtn.Size = UDim2.new(0.6, 0, 0, 40)
DPIBtn.Font = Enum.Font.GothamBold
DPIBtn.Text = "   Size: 100%"
DPIBtn.TextColor3 = Color3.fromRGB(160, 180, 190)
DPIBtn.TextSize = 12
DPIBtn.TextXAlignment = Enum.TextXAlignment.Left
local DPIB_C = Instance.new("UICorner"); DPIB_C.CornerRadius = UDim.new(0,8); DPIB_C.Parent = DPIBtn

local DPIFrame = Instance.new("Frame")
DPIFrame.Parent = TabSettings
DPIFrame.BackgroundColor3 = Color3.fromRGB(30, 34, 45)
DPIFrame.Size = UDim2.new(0.6, 0, 0, 0)
DPIFrame.ClipsDescendants = true
DPIFrame.Visible = false
local DPIF_C = Instance.new("UICorner"); DPIF_C.CornerRadius = UDim.new(0,8); DPIF_C.Parent = DPIFrame
local DPIList = Instance.new("UIListLayout"); DPIList.Parent = DPIFrame; DPIList.SortOrder = Enum.SortOrder.LayoutOrder

local dpiOpen = false
DPIBtn.MouseButton1Click:Connect(function()
    dpiOpen = not dpiOpen
    DPIFrame.Visible = true
    if dpiOpen then
        TweenService:Create(DPIFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.6, 0, 0, 135)}):Play()
    else
        TweenService:Create(DPIFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.6, 0, 0, 0)}):Play()
        task.wait(0.3)
        if not dpiOpen then DPIFrame.Visible = false end
    end
end)

local function AddDPIOption(txt, scaleVal)
    local Opt = Instance.new("TextButton")
    Opt.Parent = DPIFrame
    Opt.BackgroundColor3 = Color3.fromRGB(30, 34, 45)
    Opt.Size = UDim2.new(1, 0, 0, 45)
    Opt.Font = Enum.Font.GothamMedium
    Opt.Text = txt
    Opt.TextColor3 = Color3.fromRGB(200, 200, 200)
    Opt.TextSize = 14
    
    Opt.MouseButton1Click:Connect(function()
        TweenService:Create(UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Scale = scaleVal}):Play()
        DPIBtn.Text = "   Size: " .. txt
        dpiOpen = false
        TweenService:Create(DPIFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.6, 0, 0, 0)}):Play()
    end)
end

AddDPIOption("100% (Default)", 1)
AddDPIOption("75% (Medium)", 0.75)
AddDPIOption("50% (Small)", 0.5)

--// ITEMS
local function AddFeature(page, text)
    local Btn = Instance.new("TextButton")
    Btn.Parent = page
    Btn.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
    Btn.BackgroundTransparency = 0.3
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.Font = Enum.Font.GothamMedium
    Btn.Text = "  " .. text
    Btn.TextColor3 = Theme.Text
    Btn.TextSize = 12
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 6); C.Parent = Btn
    local S = Instance.new("UIStroke"); S.Parent = Btn; S.Color = Theme.Accent; S.Transparency = 0.8; S.Thickness = 1
    local Sw = Instance.new("Frame"); Sw.Parent = Btn; Sw.BackgroundColor3 = Color3.fromRGB(20, 25, 35); Sw.Position = UDim2.new(1, -40, 0.5, -9); Sw.Size = UDim2.new(0, 32, 0, 18); local SC = Instance.new("UICorner"); SC.CornerRadius = UDim.new(1,0); SC.Parent = Sw
    local K = Instance.new("Frame"); K.Parent = Sw; K.BackgroundColor3 = Theme.TextDim; K.Position = UDim2.new(0, 2, 0.5, -7); K.Size = UDim2.new(0, 14, 0, 14); local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1,0); KC.Parent = K
end
AddFeature(TabAuto, "Auto Fishing")

--// ANIMATION LOGIC
local function ToggleAnimation()
    if IsOpen then
        IsOpen = false
        TweenService:Create(MainFrame, TweenInfo.new(AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 0), Position = ToggleBtn.Position, BackgroundTransparency = 1
        }):Play()
        for _, v in pairs(MainFrame:GetChildren()) do
            if v:IsA("GuiObject") and v ~= MainCorner and v ~= UIScale and v ~= MainStroke then v.Visible = false end
        end
    else
        IsOpen = true
        for _, v in pairs(MainFrame:GetChildren()) do if v:IsA("GuiObject") then v.Visible = true end end
        MainFrame.Position = ToggleBtn.Position
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(AnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = FinalSize, Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = Theme.Transp
        }):Play()
    end
end

MinBtn.MouseButton1Click:Connect(ToggleAnimation)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
ToggleBtn.MouseButton1Click:Connect(ToggleAnimation)
