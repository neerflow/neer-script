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
    Green       = Color3.fromRGB(85, 255, 127),
    
    FontMain    = Enum.Font.GothamMedium,
    FontBold    = Enum.Font.GothamBold
}

if CoreGui:FindFirstChild("NeeR_Unified") then
    CoreGui.NeeR_Unified:Destroy()
end

--// [BAGIAN 2] SESSION MANAGER
local DefaultStats = { WalkSpeed = 16, JumpPower = 50 }
local function SaveDefaultStats()
    local char = Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        DefaultStats.WalkSpeed = char.Humanoid.WalkSpeed
        DefaultStats.JumpPower = char.Humanoid.JumpPower
    end
end
SaveDefaultStats()

local Session = {
    StopFly = function() end, StopWalk = function() end, StopJump = function() end,
    StopNoclip = function() end, StopInfJump = function() end, ResetAll = function() end 
}

--// [BAGIAN 3] LOGIKA RESPONSIF
local ViewportSize = workspace.CurrentCamera.ViewportSize
local IsMobile = ViewportSize.X < 1080 
local CurrentScale = IsMobile and 0.75 or 1 
local FinalSize  = IsMobile and UDim2.new(0, 580, 0, 380) or UDim2.new(0, 580, 0, 380)

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
ToggleBtn.Name = "ToggleUI"; ToggleBtn.Parent = ScreenGui; ToggleBtn.BackgroundColor3 = Theme.Main; ToggleBtn.BackgroundTransparency = 0.2; ToggleBtn.AnchorPoint = Vector2.new(0.5, 0.5); ToggleBtn.Position = UDim2.new(0.50, 0, 0.15, 0); ToggleBtn.Size = UDim2.new(0, 40, 0, 40); ToggleBtn.Image = "rbxassetid://7733960981"; ToggleBtn.ImageColor3 = Theme.Accent; ToggleBtn.ZIndex = 100
local ToggleCorner = Instance.new("UICorner"); ToggleCorner.CornerRadius = UDim.new(1, 0); ToggleCorner.Parent = ToggleBtn
local ToggleStroke = Instance.new("UIStroke"); ToggleStroke.Parent = ToggleBtn; ToggleStroke.Color = Theme.Accent; ToggleStroke.Thickness = 1.5; ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MakeDraggable(ToggleBtn, ToggleBtn)

--// [BAGIAN 6] KERANGKA UTAMA
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"; MainFrame.Parent = ScreenGui; MainFrame.BackgroundColor3 = Theme.Main; MainFrame.BackgroundTransparency = Theme.Transp; MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.Size = FinalSize; MainFrame.ClipsDescendants = true

local UIScale = Instance.new("UIScale"); UIScale.Parent = MainFrame; UIScale.Scale = CurrentScale
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 12); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Parent = MainFrame; MainStroke.Color = Theme.Accent; MainStroke.Thickness = 1; MainStroke.Transparency = 0.6

local Header = Instance.new("Frame"); Header.Parent = MainFrame; Header.Size = UDim2.new(1, 0, 0, 35); Header.BackgroundTransparency = 1
local Title = Instance.new("TextLabel"); Title.Parent = Header; Title.Text = "NeeR Flow <font color=\"rgb(137,207,240)\">| Script</font>"; Title.RichText = true; Title.Font = Theme.FontBold; Title.TextColor3 = Theme.Text; Title.TextSize = 14; Title.Position = UDim2.new(0, 15, 0, 0); Title.Size = UDim2.new(0, 0, 1, 0); Title.TextXAlignment = Enum.TextXAlignment.Left
local ControlFrame = Instance.new("Frame"); ControlFrame.Parent = Header; ControlFrame.BackgroundTransparency = 1; ControlFrame.Position = UDim2.new(1, -70, 0, 0); ControlFrame.Size = UDim2.new(0, 70, 1, 0)
local MinBtn = Instance.new("TextButton"); MinBtn.Parent = ControlFrame; MinBtn.BackgroundTransparency = 1; MinBtn.Position = UDim2.new(0, 0, 0, 0); MinBtn.Size = UDim2.new(0, 35, 1, 0); MinBtn.Font = Theme.FontBold; MinBtn.Text = "—"; MinBtn.TextColor3 = Theme.Accent; MinBtn.TextSize = 14
local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = ControlFrame; CloseBtn.BackgroundTransparency = 1; CloseBtn.Position = UDim2.new(0, 28, 0, 0); CloseBtn.Size = UDim2.new(0, 35, 1, 0); CloseBtn.Font = Theme.FontBold; CloseBtn.Text = "X"; CloseBtn.TextColor3 = Theme.Accent; CloseBtn.TextSize = 14
local HeaderLine = Instance.new("Frame"); HeaderLine.Parent = Header; HeaderLine.BackgroundColor3 = Theme.TextDim; HeaderLine.BorderSizePixel = 0; HeaderLine.BackgroundTransparency = 0.5; HeaderLine.Position = UDim2.new(0, 0, 1, -1); HeaderLine.Size = UDim2.new(1, 0, 0, 1)
MakeDraggable(Header, MainFrame)

local Container = Instance.new("Frame"); Container.Parent = MainFrame; Container.BackgroundTransparency = 1; Container.Position = UDim2.new(0, 0, 0, 35); Container.Size = UDim2.new(1, 0, 1, -35)
local SidebarWidth = 130
local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Parent = Container; Sidebar.BackgroundColor3 = Theme.Sidebar; Sidebar.BackgroundTransparency = 0.5; Sidebar.BorderSizePixel = 0; Sidebar.Size = UDim2.new(0, SidebarWidth, 1, 0); Sidebar.ScrollBarThickness = 0; Sidebar.ZIndex = 2
local SidebarStroke = Instance.new("UIStroke"); SidebarStroke.Parent = Sidebar; SidebarStroke.Color = Theme.Separator; SidebarStroke.Thickness = 1; SidebarStroke.Transparency = 0.5; SidebarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local SideList = Instance.new("UIListLayout"); SideList.Parent = Sidebar; SideList.Padding = UDim.new(0, 2); SideList.SortOrder = Enum.SortOrder.LayoutOrder
local SidePadding = Instance.new("UIPadding"); SidePadding.Parent = Sidebar; SidePadding.PaddingTop = UDim.new(0, 8); SidePadding.PaddingLeft = UDim.new(0, 5); SidePadding.PaddingRight = UDim.new(0, 5)
local ContentArea = Instance.new("Frame"); ContentArea.Parent = Container; ContentArea.BackgroundTransparency = 1; ContentArea.Position = UDim2.new(0, SidebarWidth, 0, 0); ContentArea.Size = UDim2.new(1, -SidebarWidth, 1, 0); ContentArea.ClipsDescendants = true

--// [BAGIAN 7] GLOBAL HELPER FUNCTIONS (LIBRARY)
local Tabs = {}

local function SwitchTab(tabName)
    for _, page in pairs(ContentArea:GetChildren()) do if page:IsA("ScrollingFrame") then page.Visible = false end end
    if Tabs[tabName] then Tabs[tabName].Visible = true end
end

-- Fungsi Buat Tombol Tab Samping (FIXED SCROLLING)
local function CreateTabBtn(name, isActive)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Sidebar; Btn.BackgroundColor3 = isActive and Theme.ActiveTab or Theme.Sidebar; Btn.BackgroundTransparency = isActive and 0 or 1; Btn.Size = UDim2.new(1, 0, 0, 28); Btn.AutoButtonColor = false; Btn.Font = Theme.FontMain; Btn.Text = name; Btn.TextColor3 = isActive and Theme.Accent or Theme.TextDim; Btn.TextSize = 12
    local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 4); Corner.Parent = Btn
    if isActive then local s = Instance.new("UIStroke"); s.Parent = Btn; s.Color = Theme.Accent; s.Thickness = 1; s.Transparency = 0.8 end

    local Page = Instance.new("ScrollingFrame"); Page.Name = name .. "Page"; Page.Parent = ContentArea; Page.BackgroundTransparency = 1; Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = isActive; Page.ScrollBarThickness = 2
    local PL = Instance.new("UIListLayout"); PL.Parent = Page; PL.Padding = UDim.new(0, 5); PL.SortOrder = Enum.SortOrder.LayoutOrder
    local PP = Instance.new("UIPadding"); PP.Parent = Page; PP.PaddingTop = UDim.new(0, 10); PP.PaddingLeft = UDim.new(0, 10); PP.PaddingRight = UDim.new(0, 10)
    Tabs[name] = Page

    -- [AUTO RESIZE LOGIC] Update CanvasSize saat isi berubah
    PL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local currentScale = UIScale.Scale
        -- Tambahkan buffer sedikit (+20) agar tidak ngepas banget di bawah
        Page.CanvasSize = UDim2.new(0, 0, 0, (PL.AbsoluteContentSize.Y / currentScale) + 20)
    end)

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
    local Card = Instance.new("Frame"); Card.Parent = parent; Card.BackgroundColor3 = Theme.ActiveTab; Card.BackgroundTransparency = 0.2; Card.Size = size; Card.LayoutOrder = layoutOrder or 0
    local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 10); C.Parent = Card
    local S = Instance.new("UIStroke"); S.Parent = Card; S.Color = Theme.Accent; S.Transparency = 0.8; S.Thickness = 1
    return Card
end

-- [HELPER] Expandable Section (FIXED DPI)
local function CreateExpandableSection(parent, title)
    local SectionContainer = Instance.new("Frame"); SectionContainer.Name = "Section_" .. title; SectionContainer.Parent = parent; SectionContainer.BackgroundTransparency = 1; SectionContainer.Size = UDim2.new(1, 0, 0, 30); SectionContainer.ClipsDescendants = true
    
    local HeaderBtn = Instance.new("TextButton"); HeaderBtn.Parent = SectionContainer; HeaderBtn.BackgroundColor3 = Theme.ActiveTab; HeaderBtn.Size = UDim2.new(1, 0, 0, 30); HeaderBtn.AutoButtonColor = true; HeaderBtn.Text = ""
    local HC = Instance.new("UICorner"); HC.CornerRadius = UDim.new(0, 6); HC.Parent = HeaderBtn
    local HS = Instance.new("UIStroke"); HS.Parent = HeaderBtn; HS.Color = Theme.Accent; HS.Transparency = 0.6; HS.Thickness = 1
    
    local TitleLbl = Instance.new("TextLabel"); TitleLbl.Parent = HeaderBtn; TitleLbl.BackgroundTransparency = 1; TitleLbl.Position = UDim2.new(0, 10, 0, 0); TitleLbl.Size = UDim2.new(1, -40, 1, 0); TitleLbl.Font = Theme.FontBold; TitleLbl.Text = title; TitleLbl.TextColor3 = Theme.Text; TitleLbl.TextSize = 13; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    local Arrow = Instance.new("TextLabel"); Arrow.Parent = HeaderBtn; Arrow.BackgroundTransparency = 1; Arrow.Position = UDim2.new(1, -30, 0, 0); Arrow.Size = UDim2.new(0, 30, 1, 0); Arrow.Font = Theme.FontBold; Arrow.Text = "+"; Arrow.TextColor3 = Theme.Accent; Arrow.TextSize = 18

    local ContentFrame = Instance.new("Frame"); ContentFrame.Name = "Content"; ContentFrame.Parent = SectionContainer; ContentFrame.BackgroundColor3 = Color3.fromRGB(0,0,0); ContentFrame.BackgroundTransparency = 0.9; ContentFrame.Position = UDim2.new(0, 0, 0, 35); ContentFrame.Size = UDim2.new(1, 0, 0, 0)
    local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 6); CC.Parent = ContentFrame
    local CL = Instance.new("UIListLayout"); CL.Parent = ContentFrame; CL.SortOrder = Enum.SortOrder.LayoutOrder; CL.Padding = UDim.new(0, 5)
    local CP = Instance.new("UIPadding"); CP.Parent = ContentFrame; CP.PaddingTop = UDim.new(0, 5); CP.PaddingBottom = UDim.new(0, 5); CP.PaddingLeft = UDim.new(0, 5); CP.PaddingRight = UDim.new(0, 5)

    local isOpen = false
    HeaderBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            Arrow.Text = "-"; Arrow.TextColor3 = Theme.Red
            
            -- [FIX DPI] Bagi dengan Scale agar ukurannya akurat
            local currentScale = UIScale.Scale 
            local rawHeight = CL.AbsoluteContentSize.Y + 15
            local scaledHeight = rawHeight / currentScale -- Rumus Anti-Potong
            
            TweenService:Create(SectionContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, (35/currentScale) + scaledHeight)}):Play()
            TweenService:Create(ContentFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, scaledHeight)}):Play()
        else
            Arrow.Text = "+"; Arrow.TextColor3 = Theme.Accent
            -- [FIX DPI] Kembalikan ke tinggi header (30) yang disesuaikan scale
            TweenService:Create(SectionContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 30)}):Play()
        end
    end)
    return ContentFrame
end

local function CreateSwitchCard(targetParent, text, callback)
    local Card = Instance.new("Frame"); Card.Parent = targetParent; Card.BackgroundColor3 = Theme.ActiveTab; Card.BackgroundTransparency = 0.5; Card.Size = UDim2.new(1, 0, 0, 30)
    local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 6); C.Parent = Card
    local TitleLbl = Instance.new("TextLabel"); TitleLbl.Parent = Card; TitleLbl.BackgroundTransparency = 1; TitleLbl.Position = UDim2.new(0, 10, 0, 0); TitleLbl.Size = UDim2.new(0, 150, 1, 0); TitleLbl.Font = Theme.FontMain; TitleLbl.Text = text; TitleLbl.TextColor3 = Theme.TextDim; TitleLbl.TextSize = 12; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    local SwitchBtn = Instance.new("TextButton"); SwitchBtn.Parent = Card; SwitchBtn.BackgroundTransparency = 1; SwitchBtn.Position = UDim2.new(1, -45, 0.5, -10); SwitchBtn.Size = UDim2.new(0, 40, 0, 20); SwitchBtn.Text = ""
    local Sw = Instance.new("Frame"); Sw.Parent = SwitchBtn; Sw.BackgroundColor3 = Color3.fromRGB(20, 25, 35); Sw.Position = UDim2.new(0, 0, 0.5, -8); Sw.Size = UDim2.new(0, 36, 0, 16); local SC = Instance.new("UICorner"); SC.CornerRadius = UDim.new(1,0); SC.Parent = Sw
    local K = Instance.new("Frame"); K.Parent = Sw; K.BackgroundColor3 = Theme.TextDim; K.Position = UDim2.new(0, 2, 0.5, -6); K.Size = UDim2.new(0, 12, 0, 12); local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1,0); KC.Parent = K
    local toggled = false
    local function SetState(state)
        toggled = state
        if toggled then TweenService:Create(K, TweenInfo.new(0.2), {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Theme.Main}):Play(); TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play(); TitleLbl.TextColor3 = Theme.Text
        else TweenService:Create(K, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Theme.TextDim}):Play(); TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 25, 35)}):Play(); TitleLbl.TextColor3 = Theme.TextDim end
        if callback then callback(toggled) end
    end
    SwitchBtn.MouseButton1Click:Connect(function() SetState(not toggled) end)
    return { SetState = SetState }
end

local function CreateButtonCard(targetParent, text, btnText, callback)
    local Card = Instance.new("Frame"); Card.Parent = targetParent; Card.BackgroundColor3 = Theme.ActiveTab; Card.BackgroundTransparency = 0.5; Card.Size = UDim2.new(1, 0, 0, 30)
    local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 6); C.Parent = Card
    local TitleLbl = Instance.new("TextLabel"); TitleLbl.Parent = Card; TitleLbl.BackgroundTransparency = 1; TitleLbl.Position = UDim2.new(0, 10, 0, 0); TitleLbl.Size = UDim2.new(0, 150, 1, 0); TitleLbl.Font = Theme.FontMain; TitleLbl.Text = text; TitleLbl.TextColor3 = Theme.TextDim; TitleLbl.TextSize = 12; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    local ActBtn = Instance.new("TextButton"); ActBtn.Parent = Card; ActBtn.BackgroundColor3 = Theme.Main; ActBtn.Position = UDim2.new(1, -75, 0.5, -10); ActBtn.Size = UDim2.new(0, 70, 0, 20); ActBtn.Font = Theme.FontBold; ActBtn.Text = btnText; ActBtn.TextColor3 = Theme.Accent; ActBtn.TextSize = 10; local AC = Instance.new("UICorner"); AC.CornerRadius = UDim.new(0, 4); AC.Parent = ActBtn; local AS = Instance.new("UIStroke"); AS.Parent = ActBtn; AS.Color = Theme.Accent; AS.Transparency = 0.5; AS.Thickness = 1; AS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ActBtn.MouseButton1Click:Connect(function() ActBtn.Text = "WAIT..."; callback(); task.wait(0.5); ActBtn.Text = "DONE"; task.wait(1); ActBtn.Text = btnText end)
end

local function CreateSliderCard(targetParent, text, min, max, default, callback)
    local Card = Instance.new("Frame"); Card.Parent = targetParent; Card.BackgroundColor3 = Theme.ActiveTab; Card.BackgroundTransparency = 0.5; Card.Size = UDim2.new(1, 0, 0, 45)
    local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 6); C.Parent = Card
    local TitleLbl = Instance.new("TextLabel"); TitleLbl.Parent = Card; TitleLbl.BackgroundTransparency = 1; TitleLbl.Position = UDim2.new(0, 10, 0, 5); TitleLbl.Size = UDim2.new(1, -20, 0, 15); TitleLbl.Font = Theme.FontMain; TitleLbl.Text = text; TitleLbl.TextColor3 = Theme.TextDim; TitleLbl.TextSize = 12; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    local ValueLbl = Instance.new("TextLabel"); ValueLbl.Parent = Card; ValueLbl.BackgroundTransparency = 1; ValueLbl.Position = UDim2.new(0, 10, 0, 5); ValueLbl.Size = UDim2.new(1, -20, 0, 15); ValueLbl.Font = Theme.FontBold; ValueLbl.Text = tostring(default); ValueLbl.TextColor3 = Theme.Accent; ValueLbl.TextSize = 12; ValueLbl.TextXAlignment = Enum.TextXAlignment.Right
    local SliderBG = Instance.new("TextButton"); SliderBG.Parent = Card; SliderBG.BackgroundColor3 = Color3.fromRGB(20, 25, 35); SliderBG.Position = UDim2.new(0, 10, 0, 28); SliderBG.Size = UDim2.new(1, -20, 0, 6); SliderBG.Text = ""; SliderBG.AutoButtonColor = false; local SBC = Instance.new("UICorner"); SBC.CornerRadius = UDim.new(1, 0); SBC.Parent = SliderBG
    local SliderFill = Instance.new("Frame"); SliderFill.Parent = SliderBG; SliderFill.BackgroundColor3 = Theme.Accent; SliderFill.Size = UDim2.new(0, 0, 1, 0); SliderFill.BorderSizePixel = 0; local SFC = Instance.new("UICorner"); SFC.CornerRadius = UDim.new(1, 0); SFC.Parent = SliderFill
    local Knob = Instance.new("Frame"); Knob.Parent = SliderFill; Knob.BackgroundColor3 = Theme.Text; Knob.Position = UDim2.new(1, -4, 0.5, -6); Knob.Size = UDim2.new(0, 12, 0, 12); local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1,0); KC.Parent = Knob
    local dragging = false
    local function Update(input)
        local pos = UDim2.new(math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1), 0, 1, 0)
        SliderFill.Size = pos; local val = math.floor(min + ((max - min) * pos.X.Scale)); ValueLbl.Text = tostring(val); if callback then callback(val) end
    end
    SliderBG.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; Update(input) end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    local defaultPercent = (default - min) / (max - min); SliderFill.Size = UDim2.new(defaultPercent, 0, 1, 0)
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

    -- Stats
    local GridContainer = Instance.new("Frame"); GridContainer.Parent = parentFrame; GridContainer.BackgroundTransparency = 1; GridContainer.Size = UDim2.new(1,1, 0, 50); GridContainer.LayoutOrder = 2
    local GL = Instance.new("UIGridLayout"); GL.Parent = GridContainer; GL.CellPadding = UDim2.new(0, 5, 0, 0); GL.CellSize = UDim2.new(0.493, 0, 1, 0); GL.SortOrder = Enum.SortOrder.LayoutOrder; GL.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local FPSCard = CreateCard(GridContainer, UDim2.new(0,0,0,0), 1)
    local FPSTitle = Instance.new("TextLabel"); FPSTitle.Parent = FPSCard; FPSTitle.BackgroundTransparency = 1; FPSTitle.Position = UDim2.new(0, 12, 0, 35); FPSTitle.Size = UDim2.new(1, -24, 0, 10); FPSTitle.Font = Theme.FontMain; FPSTitle.Text = "FPS Counter"; FPSTitle.TextColor3 = Theme.TextDim; FPSTitle.TextSize = 12; FPSTitle.TextXAlignment = Enum.TextXAlignment.Left
    local FPSNum = Instance.new("TextLabel"); FPSNum.Parent = FPSCard; FPSNum.BackgroundTransparency = 1; FPSNum.Position = UDim2.new(0, 12, 0, 12); FPSNum.Size = UDim2.new(1, -24, 0, 10); FPSNum.Font = Theme.FontBold; FPSNum.Text = "60"; FPSNum.TextColor3 = Theme.Text; FPSNum.TextSize = 28; FPSNum.TextXAlignment = Enum.TextXAlignment.Left
    local MemCard = CreateCard(GridContainer, UDim2.new(0,0,0,0), 2)
    local MemTitle = Instance.new("TextLabel"); MemTitle.Parent = MemCard; MemTitle.BackgroundTransparency = 1; MemTitle.Position = UDim2.new(0, 12, 0, 35); MemTitle.Size = UDim2.new(1, -24, 0, 10); MemTitle.Font = Theme.FontMain; MemTitle.Text = "Memory RAM"; MemTitle.TextColor3 = Theme.TextDim; MemTitle.TextSize = 12; MemTitle.TextXAlignment = Enum.TextXAlignment.Left
    local MemNum = Instance.new("TextLabel"); MemNum.Parent = MemCard; MemNum.BackgroundTransparency = 1; MemNum.Position = UDim2.new(0, 12, 0, 12); MemNum.Size = UDim2.new(1, -24, 0, 10); MemNum.Font = Theme.FontBold; MemNum.Text = "0"; MemNum.TextColor3 = Theme.Text; MemNum.TextSize = 24; MemNum.TextXAlignment = Enum.TextXAlignment.Left

    -- [RESTORED] Time Card
    local TimeCard = CreateCard(parentFrame, UDim2.new(1, 0, 0, 55), 3) 
    local TimeTitle = Instance.new("TextLabel"); TimeTitle.Parent = TimeCard; TimeTitle.BackgroundTransparency = 1; TimeTitle.Position = UDim2.new(0, 15, 0, 2); TimeTitle.Size = UDim2.new(1, -30, 0, 20); TimeTitle.Font = Theme.FontBold; TimeTitle.Text = "Time Server"; TimeTitle.TextColor3 = Theme.TextDim; TimeTitle.TextSize = 12; TimeTitle.TextXAlignment = Enum.TextXAlignment.Left
    local ClockLabel = Instance.new("TextLabel"); ClockLabel.Parent = TimeCard; ClockLabel.BackgroundTransparency = 1; ClockLabel.Position = UDim2.new(0, 15, 0, 0); ClockLabel.Size = UDim2.new(1, -30, 0, 35); ClockLabel.Font = Theme.FontBold; ClockLabel.Text = "00:00:00"; ClockLabel.TextColor3 = Theme.Text; ClockLabel.TextSize = 34; ClockLabel.TextXAlignment = Enum.TextXAlignment.Right
    local DateLabel = Instance.new("TextLabel"); DateLabel.Parent = TimeCard; DateLabel.BackgroundTransparency = 1; DateLabel.Position = UDim2.new(0, 15, 0, 30); DateLabel.Size = UDim2.new(1, -30, 0, 20); DateLabel.Font = Theme.FontMain; DateLabel.Text = "Monday, 1 Jan 2024"; DateLabel.TextColor3 = Theme.Accent; DateLabel.TextSize = 14; DateLabel.TextXAlignment = Enum.TextXAlignment.Right

    -- [RESTORED] Rejoin Card
    local RejoinCard = CreateCard(parentFrame, UDim2.new(1, 0, 0, 75), 4) 
    local RejoinTitle = Instance.new("TextLabel"); RejoinTitle.Parent = RejoinCard; RejoinTitle.BackgroundTransparency = 1; RejoinTitle.Position = UDim2.new(0, 15, 0, 8); RejoinTitle.Size = UDim2.new(1, -30, 0, 10); RejoinTitle.Font = Theme.FontBold; RejoinTitle.Text = "Session Control"; RejoinTitle.TextColor3 = Theme.TextDim; RejoinTitle.TextSize = 12; RejoinTitle.TextXAlignment = Enum.TextXAlignment.Left
    local RjBtn = Instance.new("TextButton"); RjBtn.Parent = RejoinCard; RjBtn.BackgroundColor3 = Theme.Sidebar; RjBtn.Position = UDim2.new(0, 15, 0, 30); RjBtn.Size = UDim2.new(1, -30, 0, 35); RjBtn.Font = Theme.FontBold; RjBtn.Text = "Rejoin Server"; RjBtn.TextColor3 = Theme.Accent; RjBtn.TextSize = 14; RjBtn.AutoButtonColor = true; local RjCorner = Instance.new("UICorner"); RjCorner.CornerRadius = UDim.new(0, 8); RjCorner.Parent = RjBtn; local RjStroke = Instance.new("UIStroke"); RjStroke.Parent = RjBtn; RjStroke.Color = Theme.Accent; RjStroke.Thickness = 1; RjStroke.Transparency = 0.7; RjStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    RjBtn.MouseButton1Click:Connect(function() local TS = game:GetService("TeleportService"); local LP = game:GetService("Players").LocalPlayer; RjBtn.Text = "Rejoining..."; RjBtn.BackgroundTransparency = 0.5; TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)

    -- Loop Logic
    task.spawn(function()
        local LocalPlayer = Players.LocalPlayer
        local LastFPSTime = tick(); local FrameCount = 0; local FPS_Connection
        FPS_Connection = RunService.RenderStepped:Connect(function()
            if not parentFrame.Parent then FPS_Connection:Disconnect(); return end
            FrameCount = FrameCount + 1
            if tick() - LastFPSTime >= 0.5 then local fps = math.floor(FrameCount / (tick() - LastFPSTime)); FPSNum.Text = tostring(fps); FrameCount = 0; LastFPSTime = tick() end
        end)
        while parentFrame.Parent do
            local rawPing = LocalPlayer:GetNetworkPing(); local ping = math.round(rawPing * 1000) 
            PingValue.Text = ping .. " ms"
            local barSize = math.clamp(ping / 300, 0.05, 1) 
            TweenService:Create(BarFill, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Size = UDim2.new(barSize, 0, 1, 0), BackgroundColor3 = ping < 100 and Theme.Green or ping < 200 and Color3.fromRGB(255, 200, 0) or Theme.Red}):Play()
            MemNum.Text = tostring(math.floor(Stats:GetTotalMemoryUsageMb()))
            ClockLabel.Text = os.date("%H:%M:%S"); DateLabel.Text = os.date("%A, %d %B %Y")
            task.wait(1)
        end
        if FPS_Connection then FPS_Connection:Disconnect() end
    end)
end

--// [BAGIAN 9] KONTEN TAB: MOVEMENT
local function BuildMovementTab(parentFrame)
    local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 10)
    local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)

    local function CreateControlCard(title, defaultVal, onToggle, onValChange, onUpdate)
        local Card = CreateCard(parentFrame, UDim2.new(1, 0, 0, 50), 0)
        local TitleLbl = Instance.new("TextLabel"); TitleLbl.Parent = Card; TitleLbl.BackgroundTransparency = 1; TitleLbl.Position = UDim2.new(0, 15, 0, 0); TitleLbl.Size = UDim2.new(0, 70, 1, 0); TitleLbl.Font = Theme.FontBold; TitleLbl.Text = title; TitleLbl.TextColor3 = Theme.Text; TitleLbl.TextSize = 14; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        local Controls = Instance.new("Frame"); Controls.Parent = Card; Controls.BackgroundTransparency = 1; Controls.Position = UDim2.new(1, -170, 0, 0); Controls.Size = UDim2.new(0, 160, 1, 0)
        local MinusBtn = Instance.new("TextButton"); MinusBtn.Parent = Controls; MinusBtn.BackgroundColor3 = Theme.Sidebar; MinusBtn.Position = UDim2.new(0, 0, 0.5, -12); MinusBtn.Size = UDim2.new(0, 24, 0, 24); MinusBtn.Font = Theme.FontBold; MinusBtn.Text = "-"; MinusBtn.TextColor3 = Theme.Accent; local M_Corner = Instance.new("UICorner"); M_Corner.CornerRadius = UDim.new(0, 6); M_Corner.Parent = MinusBtn
        local ValTxt = Instance.new("TextLabel"); ValTxt.Parent = Controls; ValTxt.BackgroundTransparency = 1; ValTxt.Position = UDim2.new(0, 28, 0.5, -12); ValTxt.Size = UDim2.new(0, 30, 0, 24); ValTxt.Font = Theme.FontBold; ValTxt.Text = tostring(defaultVal); ValTxt.TextColor3 = Theme.Text; ValTxt.TextSize = 14
        local PlusBtn = Instance.new("TextButton"); PlusBtn.Parent = Controls; PlusBtn.BackgroundColor3 = Theme.Sidebar; PlusBtn.Position = UDim2.new(0, 62, 0.5, -12); PlusBtn.Size = UDim2.new(0, 24, 0, 24); PlusBtn.Font = Theme.FontBold; PlusBtn.Text = "+"; PlusBtn.TextColor3 = Theme.Accent; local P_Corner = Instance.new("UICorner"); P_Corner.CornerRadius = UDim.new(0, 6); P_Corner.Parent = PlusBtn
        local Toggle = Instance.new("TextButton"); Toggle.Parent = Controls; Toggle.BackgroundColor3 = Theme.Sidebar; Toggle.Position = UDim2.new(1, -55, 0.5, -12); Toggle.Size = UDim2.new(0, 50, 0, 24); Toggle.Font = Theme.FontBold; Toggle.Text = "OFF"; Toggle.TextColor3 = Theme.TextDim; Toggle.TextSize = 11; local FT_Corner = Instance.new("UICorner"); FT_Corner.CornerRadius = UDim.new(0, 6); FT_Corner.Parent = Toggle; local FT_Stroke = Instance.new("UIStroke"); FT_Stroke.Parent = Toggle; FT_Stroke.Color = Theme.TextDim; FT_Stroke.Transparency = 0.8; FT_Stroke.Thickness = 1
        local isActive = false; local currentVal = defaultVal
        local function UpdateValue() ValTxt.Text = tostring(currentVal); if isActive and onUpdate then onUpdate(currentVal) end end
        MinusBtn.MouseButton1Click:Connect(function() currentVal = onValChange(currentVal, -1); UpdateValue() end)
        PlusBtn.MouseButton1Click:Connect(function() currentVal = onValChange(currentVal, 1); UpdateValue() end)
        local function SetToggleState(state)
            isActive = state
            if isActive then Toggle.Text = "ON"; Toggle.TextColor3 = Theme.Main; Toggle.BackgroundColor3 = Theme.Accent; FT_Stroke.Color = Theme.Accent; FT_Stroke.Transparency = 0
            else Toggle.Text = "OFF"; Toggle.TextColor3 = Theme.TextDim; Toggle.BackgroundColor3 = Theme.Sidebar; FT_Stroke.Color = Theme.TextDim; FT_Stroke.Transparency = 0.8 end
            onToggle(isActive, currentVal)
        end
        Toggle.MouseButton1Click:Connect(function() SetToggleState(not isActive) end)
        return { SetState = SetToggleState, Reset = function() currentVal = defaultVal; ValTxt.Text = tostring(currentVal); SetToggleState(false) end }
    end

    local flying, flySpeed, bv, bg, flyLoop = false, 1, nil, nil, nil
    local FlyCtrl = CreateControlCard("Fly Mode", 1, function(active, speed)
        flying = active; flySpeed = speed
        if not active then Session.StopFly() else
            local char = Players.LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid"); local cam = workspace.CurrentCamera
            if not root or not hum then return end
            bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.new(0,0,0); bv.Parent = root
            bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bg.P = 10000; bg.D = 100; bg.CFrame = root.CFrame; bg.Parent = root
            hum.PlatformStand = true
            flyLoop = RunService.Heartbeat:Connect(function()
                if not flying or not char or not root.Parent then Session.StopFly() return end
                local moveDir = hum.MoveDirection; local camCF = cam.CFrame
                if moveDir.Magnitude > 0 then
                    local relDir = camCF:VectorToObjectSpace(moveDir); local forwardVec = camCF.LookVector * -relDir.Z; local rightVec = camCF.RightVector * relDir.X; local targetVel = (forwardVec + rightVec) * (flySpeed * 50)
                    bv.Velocity = bv.Velocity:Lerp(targetVel, 0.2)
                else bv.Velocity = Vector3.new(0,0,0) end
                bg.CFrame = cam.CFrame
            end)
        end
    end, function(old, change) return math.max(1, old + change) end, function(newSpeed) flySpeed = newSpeed end)
    Session.StopFly = function() flying = false; if bv then bv:Destroy() end; if bg then bg:Destroy() end; if flyLoop then flyLoop:Disconnect() end; local char = Players.LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end end

    local walkLoop; local currentWalkMultiplier = 1
    local SpeedCtrl = CreateControlCard("Speed Walk", 1, function(active, mul)
        if walkLoop then walkLoop:Disconnect() end; currentWalkMultiplier = mul
        if active then walkLoop = RunService.RenderStepped:Connect(function() local char = Players.LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = DefaultStats.WalkSpeed * currentWalkMultiplier end end) else Session.StopWalk() end
    end, function(old, change) return math.max(1, old + change) end, function(newMul) currentWalkMultiplier = newMul end)
    Session.StopWalk = function() if walkLoop then walkLoop:Disconnect() end; local char = Players.LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = DefaultStats.WalkSpeed end end

    local jumpLoop; local currentJumpMultiplier = 1
    local JumpCtrl = CreateControlCard("High Jump", 1, function(active, mul)
        if jumpLoop then jumpLoop:Disconnect() end; currentJumpMultiplier = mul
        if active then jumpLoop = RunService.RenderStepped:Connect(function() local char = Players.LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid.UseJumpPower = true; char.Humanoid.JumpPower = DefaultStats.JumpPower * currentJumpMultiplier end end) else Session.StopJump() end
    end, function(old, change) return math.max(1, old + change) end, function(newMul) currentJumpMultiplier = newMul end)
    Session.StopJump = function() if jumpLoop then jumpLoop:Disconnect() end; local char = Players.LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid.JumpPower = DefaultStats.JumpPower end end

    local noclipLoop
    local NoclipCtrl = CreateSwitchCard(parentFrame, "No Clip Mode", function(active)
        if active then noclipLoop = RunService.Stepped:Connect(function() local char = Players.LocalPlayer.Character; if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end end end) else Session.StopNoclip() end
    end)
    Session.StopNoclip = function()
        if noclipLoop then noclipLoop:Disconnect() end
        local char = Players.LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid")
        if char and root and hum then
            for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then if part.Name == "HumanoidRootPart" then part.CanCollide = true; part.Transparency = 1 else part.CanCollide = false end end end
            local originalHip = hum.HipHeight; hum.HipHeight = 0; task.wait(); hum.HipHeight = originalHip; hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end

    local InfJumpConn
    local InfJumpCtrl = CreateSwitchCard(parentFrame, "Infinity Jump", function(active)
        if active then InfJumpConn = UserInputService.JumpRequest:Connect(function() local char = Players.LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end) else Session.StopInfJump() end
    end)
    Session.StopInfJump = function() if InfJumpConn then InfJumpConn:Disconnect() end end

    local ResetBtn = Instance.new("TextButton"); ResetBtn.Parent = parentFrame; ResetBtn.BackgroundColor3 = Theme.Red; ResetBtn.BackgroundTransparency = 0.2; ResetBtn.Size = UDim2.new(1, 0, 0, 35); ResetBtn.Font = Theme.FontBold; ResetBtn.Text = "RESET DEFAULT"; ResetBtn.TextColor3 = Theme.Text; ResetBtn.TextSize = 12; local RC = Instance.new("UICorner"); RC.CornerRadius = UDim.new(0, 8); RC.Parent = ResetBtn; local RS = Instance.new("UIStroke"); RS.Parent = ResetBtn; RS.Color = Theme.Red; RS.Thickness = 1; RS.Transparency = 0.5
    Session.ResetAll = function() FlyCtrl.Reset(); SpeedCtrl.Reset(); JumpCtrl.Reset(); NoclipCtrl.SetState(false); InfJumpCtrl.SetState(false); Session.StopFly(); Session.StopWalk(); Session.StopJump(); Session.StopNoclip(); Session.StopInfJump() end
    ResetBtn.MouseButton1Click:Connect(Session.ResetAll)
end

--// [BAGIAN 10] KONTEN TAB: TELEPORT (COLOR FIX)
local function BuildTeleportTab(parentFrame)
    local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 10)
    local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)

    -- [RESTORED] Variabel Warna Status
    local ColorSuccess = Theme.Green
    local ColorError   = Theme.Red

    local TpCard = CreateCard(parentFrame, UDim2.new(1, 0, 0, 110))
    TpCard.ClipsDescendants = false 
    local Title = Instance.new("TextLabel"); Title.Parent = TpCard; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 15, 0, 10); Title.Size = UDim2.new(1, -30, 0, 15); Title.Font = Theme.FontBold; Title.Text = "Teleport to Player"; Title.TextColor3 = Theme.Text; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left

    local DropContainer = Instance.new("Frame"); DropContainer.Parent = TpCard; DropContainer.BackgroundTransparency = 1; DropContainer.Position = UDim2.new(0, 15, 0, 35); DropContainer.Size = UDim2.new(1, -30, 0, 30); DropContainer.ZIndex = 5
    local DropBtn = Instance.new("TextButton"); DropBtn.Parent = DropContainer; DropBtn.BackgroundColor3 = Theme.Sidebar; DropBtn.Size = UDim2.new(1, -75, 1, 0); DropBtn.Font = Theme.FontMain; DropBtn.Text = "  Select Player..."; DropBtn.TextColor3 = Theme.TextDim; DropBtn.TextSize = 12; DropBtn.TextXAlignment = Enum.TextXAlignment.Left; DropBtn.AutoButtonColor = false; DropBtn.ZIndex = 5; local DC = Instance.new("UICorner"); DC.CornerRadius = UDim.new(0, 6); DC.Parent = DropBtn; local DS = Instance.new("UIStroke"); DS.Parent = DropBtn; DS.Color = Theme.Separator; DS.Thickness = 1
    local RefreshBtn = Instance.new("TextButton"); RefreshBtn.Parent = DropContainer; RefreshBtn.BackgroundColor3 = Theme.Green; RefreshBtn.Position = UDim2.new(1, -70, 0, 0); RefreshBtn.Size = UDim2.new(0, 70, 1, 0); RefreshBtn.ZIndex = 5; RefreshBtn.Font = Theme.FontBold; RefreshBtn.Text = "REFRESH"; RefreshBtn.TextColor3 = Theme.Main; RefreshBtn.TextSize = 11; local RC = Instance.new("UICorner"); RC.CornerRadius = UDim.new(0, 6); RC.Parent = RefreshBtn

    local StatusLbl = Instance.new("TextLabel"); StatusLbl.Parent = TpCard; StatusLbl.BackgroundTransparency = 1; StatusLbl.Position = UDim2.new(0, 15, 0, 68); StatusLbl.Size = UDim2.new(1, -100, 0, 15); StatusLbl.Font = Theme.FontMain; StatusLbl.Text = ""; StatusLbl.TextColor3 = ColorError; StatusLbl.TextSize = 13; StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
    local ExecBtn = Instance.new("TextButton"); ExecBtn.Parent = TpCard; ExecBtn.BackgroundColor3 = Theme.Accent; ExecBtn.Position = UDim2.new(1, -95, 0, 70); ExecBtn.Size = UDim2.new(0, 80, 0, 25); ExecBtn.Font = Theme.FontBold; ExecBtn.Text = "TELEPORT"; ExecBtn.TextColor3 = Theme.Main; ExecBtn.TextSize = 11; ExecBtn.ZIndex = 2; local EC = Instance.new("UICorner"); EC.CornerRadius = UDim.new(0, 6); EC.Parent = ExecBtn

    local ListFrame = Instance.new("ScrollingFrame"); ListFrame.Parent = TpCard; ListFrame.Visible = false; ListFrame.BackgroundColor3 = Theme.Sidebar; ListFrame.BorderSizePixel = 0; ListFrame.Position = UDim2.new(0, 15, 0, 68); ListFrame.Size = UDim2.new(0.90, -65, 0, 120); ListFrame.ZIndex = 20; ListFrame.ScrollBarThickness = 2; local LS = Instance.new("UIStroke"); LS.Parent = ListFrame; LS.Color = Theme.Accent; LS.Thickness = 1; local LL = Instance.new("UIListLayout"); LL.Parent = ListFrame; LL.SortOrder = Enum.SortOrder.LayoutOrder

    local selectedPlayer, isDropdownOpen, statusTimer, clickOutsideConnection = nil, false, nil, nil
    local function ShowStatus(text, color) StatusLbl.Text = text; StatusLbl.TextColor3 = color; if statusTimer then task.cancel(statusTimer) end; statusTimer = task.delay(2, function() StatusLbl.Text = ""; statusTimer = nil end) end

    local function ToggleDropdown(forceClose)
        if forceClose then isDropdownOpen = false else isDropdownOpen = not isDropdownOpen end
        ListFrame.Visible = isDropdownOpen
        if clickOutsideConnection then clickOutsideConnection:Disconnect(); clickOutsideConnection = nil end
        if isDropdownOpen then
            clickOutsideConnection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local mPos = Vector2.new(input.Position.X, input.Position.Y); local listPos, listSize = ListFrame.AbsolutePosition, ListFrame.AbsoluteSize; local btnPos, btnSize = DropBtn.AbsolutePosition, DropBtn.AbsoluteSize
                    if not (mPos.X >= listPos.X and mPos.X <= listPos.X + listSize.X and mPos.Y >= listPos.Y and mPos.Y <= listPos.Y + listSize.Y) and not (mPos.X >= btnPos.X and mPos.X <= btnPos.X + btnSize.X and mPos.Y >= btnPos.Y and mPos.Y <= btnPos.Y + btnSize.Y) then ToggleDropdown(true) end
                end
            end)
        end
    end

    local function RefreshList()
        for _, v in pairs(ListFrame:GetChildren()) do if v:IsA("TextButton") or v:IsA("TextLabel") then v:Destroy() end end
        local count = 0
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Players.LocalPlayer then
                count = count + 1
                local PBtn = Instance.new("TextButton"); PBtn.Parent = ListFrame; PBtn.BackgroundColor3 = Theme.Main; PBtn.Size = UDim2.new(1, 0, 0, 25); PBtn.Font = Theme.FontMain; PBtn.Text = "  " .. p.Name; PBtn.TextColor3 = Theme.TextDim; PBtn.TextSize = 12; PBtn.TextXAlignment = Enum.TextXAlignment.Left; PBtn.AutoButtonColor = true; PBtn.ZIndex = 21
                PBtn.MouseButton1Click:Connect(function() selectedPlayer = p; DropBtn.Text = "  " .. p.Name; DropBtn.TextColor3 = Theme.Text; ToggleDropdown(true) end)
            end
        end
        ListFrame.CanvasSize = UDim2.new(0, 0, 0, LL.AbsoluteContentSize.Y)
    end

    DropBtn.MouseButton1Click:Connect(function() ToggleDropdown() end)
    RefreshBtn.MouseButton1Click:Connect(function() RefreshList(); ShowStatus("List Refreshed!", ColorSuccess) end)
    ExecBtn.MouseButton1Click:Connect(function()
        if not selectedPlayer then ShowStatus("Select a player first!", ColorError) return end
        local target = Players:FindFirstChild(selectedPlayer.Name)
        if not target then ShowStatus("Player Left.", ColorError) return end
        local targetChar = target.Character; local localChar = Players.LocalPlayer.Character
        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") and localChar then
            localChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            ShowStatus("Teleported!", ColorSuccess)
        end
    end)
    RefreshList()
end

--// [BAGIAN 11] KONTEN TAB: VISUALS
local function BuildVisualsTab(parentFrame)
    local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 10)
    local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)

    local function ToggleFeature(isActive, storageTable, onAdd, onRemove)
        if isActive then
            local function SetupPlayer(player)
                if player == Players.LocalPlayer then return end
                if player.Character then onAdd(player.Character, player) end
                local conn = player.CharacterAdded:Connect(function(char) char:WaitForChild("HumanoidRootPart", 5); onAdd(char, player) end)
                table.insert(storageTable, conn)
            end
            for _, p in pairs(Players:GetPlayers()) do SetupPlayer(p) end
            local pAdded = Players.PlayerAdded:Connect(SetupPlayer)
            table.insert(storageTable, pAdded)
        else
            for _, conn in pairs(storageTable) do conn:Disconnect() end; table.clear(storageTable)
            for _, p in pairs(Players:GetPlayers()) do if p.Character then onRemove(p.Character) end end
        end
    end

    -- SECTION 1
    local ESP_Container = CreateExpandableSection(parentFrame, "ESP Features")
    local HL_Conn = {}
    CreateSwitchCard(ESP_Container, "Chams (Highlight)", function(active)
        ToggleFeature(active, HL_Conn, function(char) if char:FindFirstChild("NeeR_Highlight") then char.NeeR_Highlight:Destroy() end; local hl = Instance.new("Highlight"); hl.Name="NeeR_Highlight"; hl.Parent=char; hl.Adornee=char; hl.FillColor=Theme.Red; hl.FillTransparency=0.5; hl.OutlineColor=Color3.new(1,1,1); hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop end, function(char) if char:FindFirstChild("NeeR_Highlight") then char.NeeR_Highlight:Destroy() end end)
    end)
    local Name_Conn = {}
    CreateSwitchCard(ESP_Container, "Player Names", function(active)
        ToggleFeature(active, Name_Conn, function(char, plr) if not char:FindFirstChild("Head") then return end; if char:FindFirstChild("NeeR_Name") then char.NeeR_Name:Destroy() end; local bb = Instance.new("BillboardGui"); bb.Name="NeeR_Name"; bb.Parent=char; bb.Adornee=char.Head; bb.Size=UDim2.new(0,100,0,20); bb.StudsOffset=Vector3.new(0,3.5,0); bb.AlwaysOnTop=true; local tx = Instance.new("TextLabel"); tx.Parent=bb; tx.Size=UDim2.new(1,0,1,0); tx.BackgroundTransparency=1; tx.Text=plr.DisplayName; tx.TextColor3=Color3.new(1,1,1); tx.Font=Theme.FontBold; tx.TextSize=12; tx.TextStrokeTransparency=0 end, function(char) if char:FindFirstChild("NeeR_Name") then char.NeeR_Name:Destroy() end end)
    end)
    local HP_Conn = {}
    CreateSwitchCard(ESP_Container, "Health Bar", function(active)
        ToggleFeature(active, HP_Conn, function(char) if not char:FindFirstChild("Head") then return end; if char:FindFirstChild("NeeR_HP") then char.NeeR_HP:Destroy() end; local bb = Instance.new("BillboardGui"); bb.Name="NeeR_HP"; bb.Parent=char; bb.Adornee=char.Head; bb.Size=UDim2.new(0,40,0,4); bb.StudsOffset=Vector3.new(0,2.5,0); bb.AlwaysOnTop=true; local bg = Instance.new("Frame"); bg.Parent=bb; bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.new(0,0,0); bg.BorderSizePixel=0; local fill = Instance.new("Frame"); fill.Parent=bg; fill.Size=UDim2.new(1,0,1,0); fill.BackgroundColor3=Theme.Green; fill.BorderSizePixel=0; local hum = char:FindFirstChild("Humanoid"); if hum then local function Upd() local p = math.clamp(hum.Health/hum.MaxHealth, 0, 1); TweenService:Create(fill, TweenInfo.new(0.2), {Size=UDim2.new(p,0,1,0)}):Play(); fill.BackgroundColor3 = p < 0.3 and Theme.Red or Theme.Green end; Upd(); hum.HealthChanged:Connect(Upd) end end, function(char) if char:FindFirstChild("NeeR_HP") then char.NeeR_HP:Destroy() end end)
    end)

    -- SECTION 2
    local Cam_Container = CreateExpandableSection(parentFrame, "Camera Options")
    CreateSliderCard(Cam_Container, "Field of View (FOV)", 70, 120, 70, function(val) workspace.CurrentCamera.FieldOfView = val end)

    -- SECTION 3
    local FPS_Container = CreateExpandableSection(parentFrame, "Performance / FPS")
    CreateSwitchCard(FPS_Container, "Remove Shadows & Effects", function(active) local L = game:GetService("Lighting"); L.GlobalShadows = not active; for _,v in pairs(L:GetChildren()) do if v:IsA("PostEffect") then v.Enabled = not active end end end)
    CreateButtonCard(FPS_Container, "Potato Mode (Low Poly)", "EXECUTE", function() for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0 end; if v:IsA("MeshPart") then v.TextureID = "" end end end)
    CreateButtonCard(FPS_Container, "Clear All Textures", "CLEAR", function() for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end end end)
end

--// [BAGIAN 12] KONTEN TAB: SETTINGS
local function BuildSettingsTab(parentFrame)
    local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 10)
    local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)

    local DPICard = CreateCard(parentFrame, UDim2.new(1, 0, 0, 85))
    DPICard.ClipsDescendants = false
    local SettingsLabel = Instance.new("TextLabel"); SettingsLabel.Parent = DPICard; SettingsLabel.BackgroundTransparency = 1; SettingsLabel.Position = UDim2.new(0, 15, 0, 10); SettingsLabel.Size = UDim2.new(1, -30, 0, 20); SettingsLabel.Font = Theme.FontBold; SettingsLabel.Text = "Interface Scale (DPI)"; SettingsLabel.TextColor3 = Theme.Text; SettingsLabel.TextSize = 14; SettingsLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local DPIBtn = Instance.new("TextButton"); DPIBtn.Parent = DPICard; DPIBtn.BackgroundColor3 = Theme.Sidebar; DPIBtn.Position = UDim2.new(0, 15, 0, 35); DPIBtn.Size = UDim2.new(1, -30, 0, 35); DPIBtn.Font = Theme.FontBold; DPIBtn.Text = IsMobile and "   Size: 75% (Medium)" or "   Size: 100% (Default)"; DPIBtn.TextColor3 = Theme.TextDim; DPIBtn.TextSize = 12; DPIBtn.TextXAlignment = Enum.TextXAlignment.Left; DPIBtn.AutoButtonColor = false; local DPIB_C = Instance.new("UICorner"); DPIB_C.CornerRadius = UDim.new(0, 6); DPIB_C.Parent = DPIBtn; local DPIB_S = Instance.new("UIStroke"); DPIB_S.Parent = DPIBtn; DPIB_S.Color = Theme.Separator; DPIB_S.Thickness = 1

    local DPIFrame = Instance.new("Frame"); DPIFrame.Parent = DPICard; DPIFrame.BackgroundColor3 = Theme.Main; DPIFrame.Position = UDim2.new(0, 15, 0, 75); DPIFrame.Size = UDim2.new(1, -30, 0, 0); DPIFrame.ClipsDescendants = true; DPIFrame.Visible = false; DPIFrame.ZIndex = 10; local DPIF_C = Instance.new("UICorner"); DPIF_C.CornerRadius = UDim.new(0, 6); DPIF_C.Parent = DPIFrame; local DPIF_S = Instance.new("UIStroke"); DPIF_S.Parent = DPIFrame; DPIF_S.Color = Theme.Accent; DPIF_S.Transparency = 0.5; DPIF_S.Thickness = 1; local DPIList = Instance.new("UIListLayout"); DPIList.Parent = DPIFrame; DPIList.SortOrder = Enum.SortOrder.LayoutOrder

    local dpiOpen, dpiConnection = false, nil
    local function ToggleDPI(forceClose)
        if forceClose then dpiOpen = false else dpiOpen = not dpiOpen end
        if dpiConnection then dpiConnection:Disconnect(); dpiConnection = nil end
        if dpiOpen then
            DPIFrame.Visible = true; TweenService:Create(DPIFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -30, 0, 105)}):Play()
            dpiConnection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local mPos = Vector2.new(input.Position.X, input.Position.Y); local btnPos, btnSize = DPIBtn.AbsolutePosition, DPIBtn.AbsoluteSize; local frmPos, frmSize = DPIFrame.AbsolutePosition, DPIFrame.AbsoluteSize
                    if not (mPos.X >= btnPos.X and mPos.X <= btnPos.X + btnSize.X and mPos.Y >= btnPos.Y and mPos.Y <= btnPos.Y + btnSize.Y) and not (mPos.X >= frmPos.X and mPos.X <= frmPos.X + frmSize.X and mPos.Y >= frmPos.Y and mPos.Y <= frmPos.Y + frmSize.Y) then ToggleDPI(true) end
                end
            end)
        else
            TweenService:Create(DPIFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -30, 0, 0)}):Play(); task.wait(0.3); if not dpiOpen then DPIFrame.Visible = false end
        end
    end
    DPIBtn.MouseButton1Click:Connect(function() ToggleDPI() end)

    local function AddDPIOption(txt, scaleVal)
        local Opt = Instance.new("TextButton"); Opt.Parent = DPIFrame; Opt.BackgroundColor3 = Theme.Main; Opt.Size = UDim2.new(1, 0, 0, 35); Opt.Font = Theme.FontMain; Opt.Text = txt; Opt.TextColor3 = Theme.TextDim; Opt.TextSize = 12; Opt.AutoButtonColor = true
        Opt.MouseButton1Click:Connect(function() TweenService:Create(UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Scale = scaleVal}):Play(); DPIBtn.Text = "   Size: " .. txt; ToggleDPI(true) end)
    end
    AddDPIOption("100% (Default)", 1); AddDPIOption("75% (Medium)", 0.75); AddDPIOption("50% (Small)", 0.5)
end

--// [BAGIAN 13] EKSEKUSI PEMBUATAN TAB
local TabInfo = CreateTabBtn("Information", true)
BuildInfoTab(TabInfo)

local TabMovement = CreateTabBtn("Movement", false)
BuildMovementTab(TabMovement)

local TabTeleports = CreateTabBtn("Teleports", false)
BuildTeleportTab(TabTeleports)

local TabVisuals = CreateTabBtn("Visuals", false)
BuildVisualsTab(TabVisuals)

local TabSettings = CreateTabBtn("Settings", false)
BuildSettingsTab(TabSettings)

--// [BAGIAN 14] LOGIKA ANIMASI & CLEANUP
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
    Session.ResetAll() 
    ScreenGui:Destroy()
end)
