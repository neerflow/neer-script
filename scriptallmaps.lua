local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")

--// [BAGIAN 1] TEMA & PENGATURAN AWAL
local Theme = {
    Main        = Color3.fromRGB(20, 25, 35), 
    Sidebar     = Color3.fromRGB(22, 26, 38),
    ActiveTab   = Color3.fromRGB(45, 55, 75),
    Accent      = Color3.fromRGB(137, 207, 240), -- Baby Blue
    Text        = Color3.fromRGB(255, 255, 255),
    TextDim     = Color3.fromRGB(160, 180, 190),
    Separator   = Color3.fromRGB(50, 60, 80),
    Transp      = 0.15,
    Red         = Color3.fromRGB(255, 80, 80),
    
    FontMain    = Enum.Font.GothamMedium,
    FontBold    = Enum.Font.GothamBold
}

if CoreGui:FindFirstChild("NeeR_Unified") then
    CoreGui.NeeR_Unified:Destroy()
end

--// [BAGIAN 2] SESSION MANAGER
local Session = {
    StopFly = function() end,
    StopWalk = function() end,
    StopJump = function() end,
    StopNoclip = function() end,
    StopInfJump = function() end,
    ResetAll = function() end 
}

--// [BAGIAN 3] LOGIKA RESPONSIF
local ViewportSize = workspace.CurrentCamera.ViewportSize
local IsMobile = ViewportSize.X < 1080 
local CurrentScale = IsMobile and 0.75 or 1 
local PCSize     = UDim2.new(0, 580, 0, 380)      
local MobileSize = UDim2.new(0, 580, 0, 380)    
local FinalSize  = IsMobile and MobileSize or PCSize

--// [BAGIAN 4] SETUP GUI DASAR
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeeR_Unified"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local IsOpen = true
local AnimationSpeed = 0.4

local function MakeDraggable(trigger, objectToMove)
    local dragging, dragInput, dragStart, startPos
    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = objectToMove.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    trigger.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            objectToMove.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--// [BAGIAN 5] TOMBOL TOGGLE
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
local ToggleCorner = Instance.new("UICorner"); ToggleCorner.CornerRadius = UDim.new(1, 0); ToggleCorner.Parent = ToggleBtn
local ToggleStroke = Instance.new("UIStroke"); ToggleStroke.Parent = ToggleBtn; ToggleStroke.Color = Theme.Accent; ToggleStroke.Thickness = 1.5; ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MakeDraggable(ToggleBtn, ToggleBtn)

--// [BAGIAN 6] KERANGKA UTAMA
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Theme.Main
MainFrame.BackgroundTransparency = Theme.Transp
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = FinalSize
MainFrame.ClipsDescendants = true

local UIScale = Instance.new("UIScale"); UIScale.Parent = MainFrame; UIScale.Scale = CurrentScale
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 12); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Parent = MainFrame; MainStroke.Color = Theme.Accent; MainStroke.Thickness = 1; MainStroke.Transparency = 0.6

local HeaderHeight = 35
local Header = Instance.new("Frame"); Header.Parent = MainFrame; Header.Size = UDim2.new(1, 0, 0, HeaderHeight); Header.BackgroundTransparency = 1
local Title = Instance.new("TextLabel"); Title.Parent = Header; Title.Text = "NeeR Flow <font color=\"rgb(137,207,240)\">| Script</font>"; Title.RichText = true; Title.Font = Theme.FontBold; Title.TextColor3 = Theme.Text; Title.TextSize = 14; Title.Position = UDim2.new(0, 15, 0, 0); Title.Size = UDim2.new(0, 0, 1, 0); Title.TextXAlignment = Enum.TextXAlignment.Left

local ControlFrame = Instance.new("Frame"); ControlFrame.Parent = Header; ControlFrame.BackgroundTransparency = 1; ControlFrame.Position = UDim2.new(1, -70, 0, 0); ControlFrame.Size = UDim2.new(0, 70, 1, 0)
local MinBtn = Instance.new("TextButton"); MinBtn.Parent = ControlFrame; MinBtn.BackgroundTransparency = 1; MinBtn.Position = UDim2.new(0, 0, 0, 0); MinBtn.Size = UDim2.new(0, 35, 1, 0); MinBtn.Font = Theme.FontBold; MinBtn.Text = "—"; MinBtn.TextColor3 = Theme.Accent; MinBtn.TextSize = 14
local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = ControlFrame; CloseBtn.BackgroundTransparency = 1; CloseBtn.Position = UDim2.new(0, 28, 0, 0); CloseBtn.Size = UDim2.new(0, 35, 1, 0); CloseBtn.Font = Theme.FontBold; CloseBtn.Text = "X"; CloseBtn.TextColor3 = Theme.Accent; CloseBtn.TextSize = 14
local HeaderLine = Instance.new("Frame"); HeaderLine.Parent = Header; HeaderLine.BackgroundColor3 = Theme.TextDim; HeaderLine.BorderSizePixel = 0; HeaderLine.BackgroundTransparency = 0.5; HeaderLine.Position = UDim2.new(0, 0, 1, -1); HeaderLine.Size = UDim2.new(1, 0, 0, 1)
MakeDraggable(Header, MainFrame)

local Container = Instance.new("Frame"); Container.Parent = MainFrame; Container.BackgroundTransparency = 1; Container.Position = UDim2.new(0, 0, 0, HeaderHeight); Container.Size = UDim2.new(1, 0, 1, -HeaderHeight)
local SidebarWidth = 130
local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Parent = Container; Sidebar.BackgroundColor3 = Theme.Sidebar; Sidebar.BackgroundTransparency = 0.5; Sidebar.BorderSizePixel = 0; Sidebar.Size = UDim2.new(0, SidebarWidth, 1, 0); Sidebar.ScrollBarThickness = 0; Sidebar.ZIndex = 2
local SidebarStroke = Instance.new("UIStroke"); SidebarStroke.Parent = Sidebar; SidebarStroke.Color = Theme.Separator; SidebarStroke.Thickness = 1; SidebarStroke.Transparency = 0.5; SidebarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local SideList = Instance.new("UIListLayout"); SideList.Parent = Sidebar; SideList.Padding = UDim.new(0, 2); SideList.SortOrder = Enum.SortOrder.LayoutOrder
local SidePadding = Instance.new("UIPadding"); SidePadding.Parent = Sidebar; SidePadding.PaddingTop = UDim.new(0, 8); SidePadding.PaddingLeft = UDim.new(0, 5); SidePadding.PaddingRight = UDim.new(0, 5)

local ContentArea = Instance.new("Frame"); ContentArea.Parent = Container; ContentArea.BackgroundTransparency = 1; ContentArea.Position = UDim2.new(0, SidebarWidth, 0, 0); ContentArea.Size = UDim2.new(1, -SidebarWidth, 1, 0); ContentArea.ClipsDescendants = true

--// [BAGIAN 7] HELPER FUNCTION
local Tabs = {}
local function SwitchTab(tabName)
    for _, page in pairs(ContentArea:GetChildren()) do if page:IsA("ScrollingFrame") then page.Visible = false end end
    if Tabs[tabName] then Tabs[tabName].Visible = true end
end

local function CreateTabBtn(name, isActive)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Sidebar
    Btn.BackgroundColor3 = isActive and Theme.ActiveTab or Theme.Sidebar
    Btn.BackgroundTransparency = isActive and 0 or 1
    Btn.Size = UDim2.new(1, 0, 0, 28)
    Btn.AutoButtonColor = false
    Btn.Font = Theme.FontMain
    Btn.Text = name
    Btn.TextColor3 = isActive and Theme.Accent or Theme.TextDim
    Btn.TextSize = 12
    local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 4); Corner.Parent = Btn
    if isActive then local s = Instance.new("UIStroke"); s.Parent = Btn; s.Color = Theme.Accent; s.Thickness = 1; s.Transparency = 0.8 end

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

local function CreateCard(parent, size, layoutOrder)
    local Card = Instance.new("Frame"); Card.Parent = parent; Card.BackgroundColor3 = Theme.ActiveTab; Card.BackgroundTransparency = 0.2; Card.Size = size; Card.LayoutOrder = layoutOrder
    local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 10); C.Parent = Card
    local S = Instance.new("UIStroke"); S.Parent = Card; S.Color = Theme.Accent; S.Transparency = 0.8; S.Thickness = 1
    return Card
end

--// [BAGIAN 8] KONTEN TAB: INFO 
local function BuildInfoTab(parentFrame)
    local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 14)
    local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)

    -- Ping
    local PingCard = CreateCard(parentFrame, UDim2.new(1, 0, 0,60), 1) 
    local PingTitle = Instance.new("TextLabel"); PingTitle.Parent = PingCard; PingTitle.BackgroundTransparency = 1; PingTitle.Position = UDim2.new(0, 15, 0, 5); PingTitle.Size = UDim2.new(1, -30, 0, 20); PingTitle.Font = Theme.FontBold; PingTitle.Text = "Network Ping"; PingTitle.TextColor3 = Theme.TextDim; PingTitle.TextSize = 12; PingTitle.TextXAlignment = Enum.TextXAlignment.Left
    local PingValue = Instance.new("TextLabel"); PingValue.Parent = PingCard; PingValue.BackgroundTransparency = 1; PingValue.Position = UDim2.new(0, 15, 0, 5); PingValue.Size = UDim2.new(1, -30, 0, 20); PingValue.Font = Theme.FontBold; PingValue.Text = "0 ms"; PingValue.TextColor3 = Theme.Accent; PingValue.TextSize = 12; PingValue.TextXAlignment = Enum.TextXAlignment.Right
    local BarBg = Instance.new("Frame"); BarBg.Parent = PingCard; BarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40); BarBg.Position = UDim2.new(0, 15, 0, 35); BarBg.Size = UDim2.new(1, -30, 0, 10); local BarBgC = Instance.new("UICorner"); BarBgC.CornerRadius = UDim.new(1, 0); BarBgC.Parent = BarBg
    local BarFill = Instance.new("Frame"); BarFill.Parent = BarBg; BarFill.BackgroundColor3 = Theme.Accent; BarFill.Size = UDim2.new(0.5, 0, 1, 0); local BarFillC = Instance.new("UICorner"); BarFillC.CornerRadius = UDim.new(1, 0); BarFillC.Parent = BarFill

    -- Stats Grid
    local GridContainer = Instance.new("Frame"); GridContainer.Parent = parentFrame; GridContainer.BackgroundTransparency = 1; GridContainer.Size = UDim2.new(1,1, 0, 50); GridContainer.LayoutOrder = 2
    local GL = Instance.new("UIGridLayout"); GL.Parent = GridContainer; GL.CellPadding = UDim2.new(0, 5, 0, 0); GL.CellSize = UDim2.new(0.493, 0, 1, 0); GL.SortOrder = Enum.SortOrder.LayoutOrder; GL.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local FPSCard = CreateCard(GridContainer, UDim2.new(0,0,0,0), 1)
    local FPSTitle = Instance.new("TextLabel"); FPSTitle.Parent = FPSCard; FPSTitle.BackgroundTransparency = 1; FPSTitle.Position = UDim2.new(0, 12, 0, 35); FPSTitle.Size = UDim2.new(1, -24, 0, 10); FPSTitle.Font = Theme.FontMain; FPSTitle.Text = "FPS Counter"; FPSTitle.TextColor3 = Theme.TextDim; FPSTitle.TextSize = 12; FPSTitle.TextXAlignment = Enum.TextXAlignment.Left
    local FPSNum = Instance.new("TextLabel"); FPSNum.Parent = FPSCard; FPSNum.BackgroundTransparency = 1; FPSNum.Position = UDim2.new(0, 12, 0, 12); FPSNum.Size = UDim2.new(1, -24, 0, 10); FPSNum.Font = Theme.FontBold; FPSNum.Text = "60"; FPSNum.TextColor3 = Theme.Text; FPSNum.TextSize = 28; FPSNum.TextXAlignment = Enum.TextXAlignment.Left
    local MemCard = CreateCard(GridContainer, UDim2.new(0,0,0,0), 2)
    local MemTitle = Instance.new("TextLabel"); MemTitle.Parent = MemCard; MemTitle.BackgroundTransparency = 1; MemTitle.Position = UDim2.new(0, 12, 0, 35); MemTitle.Size = UDim2.new(1, -24, 0, 10); MemTitle.Font = Theme.FontMain; MemTitle.Text = "Memory RAM"; MemTitle.TextColor3 = Theme.TextDim; MemTitle.TextSize = 12; MemTitle.TextXAlignment = Enum.TextXAlignment.Left
    local MemNum = Instance.new("TextLabel"); MemNum.Parent = MemCard; MemNum.BackgroundTransparency = 1; MemNum.Position = UDim2.new(0, 12, 0, 12); MemNum.Size = UDim2.new(1, -24, 0, 10); MemNum.Font = Theme.FontBold; MemNum.Text = "0"; MemNum.TextColor3 = Theme.Text; MemNum.TextSize = 24; MemNum.TextXAlignment = Enum.TextXAlignment.Left

    -- Time
    local TimeCard = CreateCard(parentFrame, UDim2.new(1, 0, 0, 55), 3) 
    local TimeTitle = Instance.new("TextLabel"); TimeTitle.Parent = TimeCard; TimeTitle.BackgroundTransparency = 1; TimeTitle.Position = UDim2.new(0, 15, 0, 2); TimeTitle.Size = UDim2.new(1, -30, 0, 20); TimeTitle.Font = Theme.FontBold; TimeTitle.Text = "Time Server"; TimeTitle.TextColor3 = Theme.TextDim; TimeTitle.TextSize = 12; TimeTitle.TextXAlignment = Enum.TextXAlignment.Left
    local ClockLabel = Instance.new("TextLabel"); ClockLabel.Parent = TimeCard; ClockLabel.BackgroundTransparency = 1; ClockLabel.Position = UDim2.new(0, 15, 0, 0); ClockLabel.Size = UDim2.new(1, -30, 0, 35); ClockLabel.Font = Theme.FontBold; ClockLabel.Text = "00:00:00"; ClockLabel.TextColor3 = Theme.Text; ClockLabel.TextSize = 34; ClockLabel.TextXAlignment = Enum.TextXAlignment.Right
    local DateLabel = Instance.new("TextLabel"); DateLabel.Parent = TimeCard; DateLabel.BackgroundTransparency = 1; DateLabel.Position = UDim2.new(0, 15, 0, 30); DateLabel.Size = UDim2.new(1, -30, 0, 20); DateLabel.Font = Theme.FontMain; DateLabel.Text = "Monday, 1 Jan 2024"; DateLabel.TextColor3 = Theme.Accent; DateLabel.TextSize = 14; DateLabel.TextXAlignment = Enum.TextXAlignment.Right

    -- Rejoin
    local RejoinCard = CreateCard(parentFrame, UDim2.new(1, 0, 0, 75), 4) 
    local RejoinTitle = Instance.new("TextLabel"); RejoinTitle.Parent = RejoinCard; RejoinTitle.BackgroundTransparency = 1; RejoinTitle.Position = UDim2.new(0, 15, 0, 8); RejoinTitle.Size = UDim2.new(1, -30, 0, 10); RejoinTitle.Font = Theme.FontBold; RejoinTitle.Text = "Session Control"; RejoinTitle.TextColor3 = Theme.TextDim; RejoinTitle.TextSize = 12; RejoinTitle.TextXAlignment = Enum.TextXAlignment.Left
    local RjBtn = Instance.new("TextButton"); RjBtn.Parent = RejoinCard; RjBtn.BackgroundColor3 = Theme.Sidebar; RjBtn.Position = UDim2.new(0, 15, 0, 30); RjBtn.Size = UDim2.new(1, -30, 0, 35); RjBtn.Font = Theme.FontBold; RjBtn.Text = "Rejoin Server"; RjBtn.TextColor3 = Theme.Accent; RjBtn.TextSize = 14; RjBtn.AutoButtonColor = true
    local RjCorner = Instance.new("UICorner"); RjCorner.CornerRadius = UDim.new(0, 8); RjCorner.Parent = RjBtn
    local RjStroke = Instance.new("UIStroke"); RjStroke.Parent = RjBtn; RjStroke.Color = Theme.Accent; RjStroke.Thickness = 1; RjStroke.Transparency = 0.7; RjStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    RjBtn.MouseButton1Click:Connect(function()
        local TS = game:GetService("TeleportService"); local LP = game:GetService("Players").LocalPlayer
        RjBtn.Text = "Rejoining..."; RjBtn.BackgroundTransparency = 0.5
        TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end)

    task.spawn(function()
        local LocalPlayer = Players.LocalPlayer
        while parentFrame.Parent do
            local rawPing = LocalPlayer:GetNetworkPing(); local ping = math.round(rawPing * 1000) 
            PingValue.Text = ping .. " ms"
            local barSize = math.clamp(ping / 300, 0.05, 1) 
            TweenService:Create(BarFill, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Size = UDim2.new(barSize, 0, 1, 0), BackgroundColor3 = ping < 100 and Color3.fromRGB(100, 255, 100) or ping < 200 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 80, 80)}):Play()
            FPSNum.Text = tostring(math.floor(workspace:GetRealPhysicsFPS()))
            MemNum.Text = tostring(math.floor(Stats:GetTotalMemoryUsageMb()))
            ClockLabel.Text = os.date("%H:%M:%S"); DateLabel.Text = os.date("%A, %d %B %Y")
            task.wait(0.5)
        end
    end)
end

--// [BAGIAN 9] KONTEN TAB: MOVEMENT
local function BuildMovementTab(parentFrame)
    local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 10)
    local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)

    -- Helper Create Card Controls (Fly, Speed, Jump)
    local function CreateControlCard(title, defaultVal, onToggle, onValChange, onUpdate)
        local Card = CreateCard(parentFrame, UDim2.new(1, 0, 0, 50), 0)
        local TitleLbl = Instance.new("TextLabel"); TitleLbl.Parent = Card; TitleLbl.BackgroundTransparency = 1; TitleLbl.Position = UDim2.new(0, 15, 0, 0); TitleLbl.Size = UDim2.new(0, 70, 1, 0); TitleLbl.Font = Theme.FontBold; TitleLbl.Text = title; TitleLbl.TextColor3 = Theme.Text; TitleLbl.TextSize = 14; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local Controls = Instance.new("Frame"); Controls.Parent = Card; Controls.BackgroundTransparency = 1; Controls.Position = UDim2.new(1, -170, 0, 0); Controls.Size = UDim2.new(0, 160, 1, 0)
        local MinusBtn = Instance.new("TextButton"); MinusBtn.Parent = Controls; MinusBtn.BackgroundColor3 = Theme.Sidebar; MinusBtn.Position = UDim2.new(0, 0, 0.5, -12); MinusBtn.Size = UDim2.new(0, 24, 0, 24); MinusBtn.Font = Theme.FontBold; MinusBtn.Text = "-"; MinusBtn.TextColor3 = Theme.Accent; MinusBtn.TextSize = 16; local M_Corner = Instance.new("UICorner"); M_Corner.CornerRadius = UDim.new(0, 6); M_Corner.Parent = MinusBtn
        local ValTxt = Instance.new("TextLabel"); ValTxt.Parent = Controls; ValTxt.BackgroundTransparency = 1; ValTxt.Position = UDim2.new(0, 28, 0.5, -12); ValTxt.Size = UDim2.new(0, 30, 0, 24); ValTxt.Font = Theme.FontBold; ValTxt.Text = tostring(defaultVal); ValTxt.TextColor3 = Theme.Text; ValTxt.TextSize = 14
        local PlusBtn = Instance.new("TextButton"); PlusBtn.Parent = Controls; PlusBtn.BackgroundColor3 = Theme.Sidebar; PlusBtn.Position = UDim2.new(0, 62, 0.5, -12); PlusBtn.Size = UDim2.new(0, 24, 0, 24); PlusBtn.Font = Theme.FontBold; PlusBtn.Text = "+"; PlusBtn.TextColor3 = Theme.Accent; PlusBtn.TextSize = 16; local P_Corner = Instance.new("UICorner"); P_Corner.CornerRadius = UDim.new(0, 6); P_Corner.Parent = PlusBtn
        local Toggle = Instance.new("TextButton"); Toggle.Parent = Controls; Toggle.BackgroundColor3 = Theme.Sidebar; Toggle.Position = UDim2.new(1, -55, 0.5, -12); Toggle.Size = UDim2.new(0, 50, 0, 24); Toggle.Font = Theme.FontBold; Toggle.Text = "OFF"; Toggle.TextColor3 = Theme.TextDim; Toggle.TextSize = 11; local FT_Corner = Instance.new("UICorner"); FT_Corner.CornerRadius = UDim.new(0, 6); FT_Corner.Parent = Toggle; local FT_Stroke = Instance.new("UIStroke"); FT_Stroke.Parent = Toggle; FT_Stroke.Color = Theme.TextDim; FT_Stroke.Transparency = 0.8; FT_Stroke.Thickness = 1

        local isActive = false
        local currentVal = defaultVal

        local function UpdateValue()
            ValTxt.Text = tostring(currentVal)
            -- JIKA AKTIF, LANGSUNG UPDATE (Live Update)
            if isActive and onUpdate then onUpdate(currentVal) end
        end

        MinusBtn.MouseButton1Click:Connect(function()
            currentVal = onValChange(currentVal, -1)
            UpdateValue()
        end)
        PlusBtn.MouseButton1Click:Connect(function()
            currentVal = onValChange(currentVal, 1)
            UpdateValue()
        end)

        local function SetToggleState(state)
            isActive = state
            if isActive then
                Toggle.Text = "ON"; Toggle.TextColor3 = Theme.Main; Toggle.BackgroundColor3 = Theme.Accent; FT_Stroke.Color = Theme.Accent; FT_Stroke.Transparency = 0
            else
                Toggle.Text = "OFF"; Toggle.TextColor3 = Theme.TextDim; Toggle.BackgroundColor3 = Theme.Sidebar; FT_Stroke.Color = Theme.TextDim; FT_Stroke.Transparency = 0.8
            end
            onToggle(isActive, currentVal)
        end

        Toggle.MouseButton1Click:Connect(function() SetToggleState(not isActive) end)

        return {
            SetState = SetToggleState,
            Reset = function() 
                currentVal = defaultVal; ValTxt.Text = tostring(currentVal); SetToggleState(false)
            end
        }
    end

    -- Helper Switch Card (Noclip & Inf Jump)
    local function AddSwitchCard(text, callback)
        local Btn = Instance.new("TextButton"); Btn.Parent = parentFrame; Btn.BackgroundColor3 = Color3.fromRGB(50, 60, 80); Btn.BackgroundTransparency = 0.3; Btn.Size = UDim2.new(1, 0, 0, 40); Btn.Font = Theme.FontMain; Btn.Text = "  " .. text; Btn.TextColor3 = Theme.Text; Btn.TextSize = 12; Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.AutoButtonColor = false
        local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 8); C.Parent = Btn
        local S = Instance.new("UIStroke"); S.Parent = Btn; S.Color = Theme.Accent; S.Transparency = 0.8; S.Thickness = 1
        local Sw = Instance.new("Frame"); Sw.Parent = Btn; Sw.BackgroundColor3 = Color3.fromRGB(20, 25, 35); Sw.Position = UDim2.new(1, -45, 0.5, -10); Sw.Size = UDim2.new(0, 36, 0, 20); local SC = Instance.new("UICorner"); SC.CornerRadius = UDim.new(1,0); SC.Parent = Sw
        local K = Instance.new("Frame"); K.Parent = Sw; K.BackgroundColor3 = Theme.TextDim; K.Position = UDim2.new(0, 2, 0.5, -8); K.Size = UDim2.new(0, 16, 0, 16); local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1,0); KC.Parent = K
        local toggled = false
        
        local function SetState(state)
            toggled = state
            if state then
                TweenService:Create(K, TweenInfo.new(0.2), {Position = UDim2.new(0, 18, 0.5, -8), BackgroundColor3 = Theme.Main}):Play()
                TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
                TweenService:Create(S, TweenInfo.new(0.2), {Transparency = 0.2}):Play()
            else
                TweenService:Create(K, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.TextDim}):Play()
                TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 25, 35)}):Play()
                TweenService:Create(S, TweenInfo.new(0.2), {Transparency = 0.8}):Play()
            end
            if callback then callback(toggled) end
        end

        Btn.MouseButton1Click:Connect(function() SetState(not toggled) end)
        return { SetState = SetState }
    end

    -- >>> 1. FITUR FLY <<<
    local flying, flySpeed, bv, bg, flyLoop = false, 1, nil, nil, nil
    local FlyCtrl = CreateControlCard("Fly Mode", 1, function(active, speed)
        flying = active
        flySpeed = speed
        if not active then
            Session.StopFly()
        else
            local char = Players.LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local cam = workspace.CurrentCamera
            if not root or not hum then return end
            bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.new(0,0,0); bv.Parent = root
            bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bg.P = 10000; bg.D = 100; bg.CFrame = root.CFrame; bg.Parent = root
            hum.PlatformStand = true
            flyLoop = RunService.Heartbeat:Connect(function()
                if not flying or not char or not root.Parent then Session.StopFly() return end
                local moveDir = hum.MoveDirection; local camCF = cam.CFrame
                if moveDir.Magnitude > 0 then
                    local relDir = camCF:VectorToObjectSpace(moveDir)
                    local forwardVec = camCF.LookVector * -relDir.Z 
                    local rightVec = camCF.RightVector * relDir.X
                    local targetVel = (forwardVec + rightVec) * (flySpeed * 50)
                    bv.Velocity = bv.Velocity:Lerp(targetVel, 0.2)
                else bv.Velocity = Vector3.new(0,0,0) end
                bg.CFrame = cam.CFrame
            end)
        end
    end, function(old, change) return math.max(1, old + change) end, 
    function(newSpeed) flySpeed = newSpeed end) -- Live Update Callback
    
    Session.StopFly = function()
        flying = false
        if bv then bv:Destroy() end; if bg then bg:Destroy() end; if flyLoop then flyLoop:Disconnect() end
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
    end

    -- >>> 2. FITUR SPEED WALK (Default 1 = Normal/16) <<<
    local walkLoop
    local currentWalkMultiplier = 1 
    
    local SpeedCtrl = CreateControlCard("Speed Walk", 1, function(active, mul)
        if walkLoop then walkLoop:Disconnect() end
        currentWalkMultiplier = mul
        if active then
            walkLoop = RunService.RenderStepped:Connect(function()
                local char = Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then 
                    char.Humanoid.WalkSpeed = 16 * currentWalkMultiplier -- Multiplier Logic
                end
            end)
        else
            Session.StopWalk()
        end
    end, function(old, change) return math.max(1, old + change) end, 
    function(newMul) currentWalkMultiplier = newMul end) 

    Session.StopWalk = function()
        if walkLoop then walkLoop:Disconnect() end
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = 16 end
    end

    -- >>> 3. FITUR HIGH JUMP (Default 1 = Normal/50) <<<
    local jumpLoop
    local currentJumpMultiplier = 1
    
    local JumpCtrl = CreateControlCard("High Jump", 1, function(active, mul)
        if jumpLoop then jumpLoop:Disconnect() end
        currentJumpMultiplier = mul
        if active then
            jumpLoop = RunService.RenderStepped:Connect(function()
                local char = Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then 
                    char.Humanoid.UseJumpPower = true
                    char.Humanoid.JumpPower = 50 * currentJumpMultiplier -- Multiplier Logic
                end
            end)
        else
            Session.StopJump()
        end
    end, function(old, change) return math.max(1, old + change) end,
    function(newMul) currentJumpMultiplier = newMul end) 

    Session.StopJump = function()
        if jumpLoop then jumpLoop:Disconnect() end
        local char = Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.JumpPower = 50 end
    end

    -- >>> 4. FITUR NO CLIP (DENGAN FORCE RESTORE & TELEPORT FIX) <<<
    local noclipLoop
    local NoclipCtrl = AddSwitchCard("No Clip Mode", function(active)
        if active then
            noclipLoop = RunService.Stepped:Connect(function()
                local char = Players.LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                    end
                end
            end)
        else
            Session.StopNoclip()
        end
    end)

    Session.StopNoclip = function()
        if noclipLoop then noclipLoop:Disconnect() end
        local char = Players.LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if char then
            -- 1. Restore Collision
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
            -- 2. FIX: Teleport slightly up to prevent sinking/stuck
            if root then
                root.CFrame = root.CFrame + Vector3.new(0, 2.3, 0)
            end
        end
    end

    -- >>> 5. FITUR INFINITY JUMP <<<
    local InfJumpConn
    local InfJumpCtrl = AddSwitchCard("Infinity Jump", function(active)
        if active then
            InfJumpConn = UserInputService.JumpRequest:Connect(function()
                local char = Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            Session.StopInfJump()
        end
    end)

    Session.StopInfJump = function()
        if InfJumpConn then InfJumpConn:Disconnect() end
    end

    -- >>> 6. RESET ALL BUTTON <<<
    local ResetBtn = Instance.new("TextButton"); ResetBtn.Parent = parentFrame; ResetBtn.BackgroundColor3 = Theme.Red; ResetBtn.BackgroundTransparency = 0.2; ResetBtn.Size = UDim2.new(1, 0, 0, 35); ResetBtn.Font = Theme.FontBold; ResetBtn.Text = "RESET DEFAULT"; ResetBtn.TextColor3 = Theme.Text; ResetBtn.TextSize = 12; ResetBtn.AutoButtonColor = true
    local RC = Instance.new("UICorner"); RC.CornerRadius = UDim.new(0, 8); RC.Parent = ResetBtn
    local RS = Instance.new("UIStroke"); RS.Parent = ResetBtn; RS.Color = Theme.Red; RS.Thickness = 1; RS.Transparency = 0.5
    
    Session.ResetAll = function()
        FlyCtrl.Reset()
        SpeedCtrl.Reset()
        JumpCtrl.Reset()
        NoclipCtrl.SetState(false)
        InfJumpCtrl.SetState(false)
        Session.StopFly()
        Session.StopWalk()
        Session.StopJump()
        Session.StopNoclip()
        Session.StopInfJump()
    end
    
    ResetBtn.MouseButton1Click:Connect(Session.ResetAll)
end

--// [BAGIAN 10] EKSEKUSI PEMBUATAN TAB
local TabInfo = CreateTabBtn("Info", true)
BuildInfoTab(TabInfo)

local TabMovement = CreateTabBtn("Movement", false)
BuildMovementTab(TabMovement)

local TabTeleports = CreateTabBtn("Teleports", false)

local TabSettings = CreateTabBtn("Settings", false)
local SettingsLabel = Instance.new("TextLabel"); SettingsLabel.Parent = TabSettings; SettingsLabel.BackgroundTransparency = 1; SettingsLabel.Size = UDim2.new(0, 0, 0, 20); SettingsLabel.Font = Theme.FontBold; SettingsLabel.Text = "Interface Scale (DPI)"; SettingsLabel.TextColor3 = Color3.fromRGB(255, 255, 255); SettingsLabel.TextSize = 14; SettingsLabel.TextXAlignment = Enum.TextXAlignment.Left
local DPIBtn = Instance.new("TextButton"); DPIBtn.Parent = TabSettings; DPIBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55); DPIBtn.Size = UDim2.new(1, 0, 0, 40); DPIBtn.Font = Theme.FontBold; DPIBtn.Text = IsMobile and "   Size: 75% (Medium)" or "   Size: 100% (Default)"; DPIBtn.TextColor3 = Color3.fromRGB(160, 180, 190); DPIBtn.TextSize = 12; DPIBtn.TextXAlignment = Enum.TextXAlignment.Left; local DPIB_C = Instance.new("UICorner"); DPIB_C.CornerRadius = UDim.new(0,8); DPIB_C.Parent = DPIBtn
local DPIFrame = Instance.new("Frame"); DPIFrame.Parent = TabSettings; DPIFrame.BackgroundColor3 = Color3.fromRGB(30, 34, 45); DPIFrame.Size = UDim2.new(1, 0, 0, 0); DPIFrame.ClipsDescendants = true; DPIFrame.Visible = false; local DPIF_C = Instance.new("UICorner"); DPIF_C.CornerRadius = UDim.new(0,8); DPIF_C.Parent = DPIFrame
local DPIList = Instance.new("UIListLayout"); DPIList.Parent = DPIFrame; DPIList.SortOrder = Enum.SortOrder.LayoutOrder
local dpiOpen = false
DPIBtn.MouseButton1Click:Connect(function()
    dpiOpen = not dpiOpen; DPIFrame.Visible = true
    if dpiOpen then TweenService:Create(DPIFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 135)}):Play()
    else TweenService:Create(DPIFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play(); task.wait(0.3); if not dpiOpen then DPIFrame.Visible = false end end
end)
local function AddDPIOption(txt, scaleVal)
    local Opt = Instance.new("TextButton"); Opt.Parent = DPIFrame; Opt.BackgroundColor3 = Color3.fromRGB(30, 34, 45); Opt.Size = UDim2.new(1, 0, 0, 45); Opt.Font = Theme.FontMain; Opt.Text = txt; Opt.TextColor3 = Color3.fromRGB(200, 200, 200); Opt.TextSize = 14
    Opt.MouseButton1Click:Connect(function()
        TweenService:Create(UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Scale = scaleVal}):Play()
        DPIBtn.Text = "   Size: " .. txt; dpiOpen = false; TweenService:Create(DPIFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.6, 0, 0, 0)}):Play()
    end)
end
AddDPIOption("100% (Default)", 1)
AddDPIOption("75% (Medium)", 0.75)
AddDPIOption("50% (Small)", 0.5)

--// [BAGIAN 11] LOGIKA ANIMASI & CLEANUP
local function ToggleAnimation()
    if IsOpen then
        IsOpen = false
        TweenService:Create(MainFrame, TweenInfo.new(AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), Position = ToggleBtn.Position, BackgroundTransparency = 1}):Play()
        for _, v in pairs(MainFrame:GetChildren()) do if v:IsA("GuiObject") and v ~= MainCorner and v ~= UIScale and v ~= MainStroke then v.Visible = false end end
    else
        IsOpen = true
        for _, v in pairs(MainFrame:GetChildren()) do if v:IsA("GuiObject") then v.Visible = true end end
        MainFrame.Position = ToggleBtn.Position; MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(AnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = FinalSize, Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = Theme.Transp}):Play()
    end
end

MinBtn.MouseButton1Click:Connect(ToggleAnimation)
ToggleBtn.MouseButton1Click:Connect(ToggleAnimation)

CloseBtn.MouseButton1Click:Connect(function()
    Session.ResetAll() -- Matikan semua fungsi sebelum destroy
    ScreenGui:Destroy()
end)
