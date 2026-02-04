local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

--// [1] THEME & SETTINGS
local Theme = {
	Main = Color3.fromRGB(20, 25, 35),
	Sidebar = Color3.fromRGB(22, 26, 38),
	ActiveTab = Color3.fromRGB(45, 55, 75),
	Accent = Color3.fromRGB(137, 207, 240),
	Text = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(160, 180, 190),
	Separator = Color3.fromRGB(50, 60, 80),
	Transp = 0.15,
	Red = Color3.fromRGB(255, 80, 80),
	Green = Color3.fromRGB(85, 255, 127),
	Pressed = Color3.fromRGB(10, 10, 12), 
	FontMain = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold
}

if CoreGui:FindFirstChild("NeeR_Unified") then CoreGui.NeeR_Unified:Destroy() end
if CoreGui:FindFirstChild("NeeR_Loader") then CoreGui.NeeR_Loader:Destroy() end

--// [2] LOADER SYSTEM
local Loader = {}
function Loader.Start()
	local LoadGui = Instance.new("ScreenGui"); LoadGui.Name = "NeeR_Loader"; LoadGui.Parent = CoreGui; LoadGui.IgnoreGuiInset = true
	local Blur = Instance.new("BlurEffect"); Blur.Size = 0; Blur.Parent = Lighting
	TweenService:Create(Blur, TweenInfo.new(1), {Size = 20}):Play()

	local MainBG = Instance.new("Frame"); MainBG.Parent = LoadGui
	MainBG.BackgroundColor3 = Color3.fromRGB(15, 20, 30); MainBG.BackgroundTransparency = 1; MainBG.Size = UDim2.new(1, 0, 1, 0)
	
	local Container = Instance.new("Frame"); Container.Parent = MainBG
	Container.AnchorPoint = Vector2.new(0.5, 0.5); Container.Position = UDim2.new(0.5, 0, 0.55, 0)
	Container.Size = UDim2.new(0, 300, 0, 150); Container.BackgroundTransparency = 1
	
	local Spinner = Instance.new("Frame"); Spinner.Parent = Container
	Spinner.AnchorPoint = Vector2.new(0.5, 0.5); Spinner.Position = UDim2.new(0.5, 0, 0.4, 0)
	Spinner.Size = UDim2.new(0, 60, 0, 60); Spinner.BackgroundTransparency = 1
	
	local SpinStroke = Instance.new("UIStroke"); SpinStroke.Parent = Spinner
	SpinStroke.Color = Theme.Accent; SpinStroke.Thickness = 3; SpinStroke.Transparency = 0.2
	Instance.new("UICorner", Spinner).CornerRadius = UDim.new(1, 0)
	
	local SpinGrad = Instance.new("UIGradient"); SpinGrad.Parent = Spinner
	SpinGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(0.5, Theme.Main), ColorSequenceKeypoint.new(1, Theme.Accent)})
	SpinGrad.Rotation = 45

	local Logo = Instance.new("TextLabel"); Logo.Parent = Container
	Logo.BackgroundTransparency = 1; Logo.Position = UDim2.new(0, 0, 0.4, -10)
	Logo.Size = UDim2.new(1, 0, 0, 20); Logo.Font = Enum.Font.GothamBold
	Logo.Text = "NF"; Logo.TextColor3 = Theme.Text; Logo.TextSize = 18
	
	local BarBG = Instance.new("Frame"); BarBG.Parent = Container
	BarBG.BackgroundColor3 = Color3.fromRGB(60, 70, 90); BarBG.Position = UDim2.new(0.1, 0, 0.75, 0)
	BarBG.Size = UDim2.new(0.8, 0, 0, 4); Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1,0)
	
	local BarFill = Instance.new("Frame"); BarFill.Parent = BarBG
	BarFill.BackgroundColor3 = Theme.Accent; BarFill.Size = UDim2.new(0, 0, 1, 0)
	Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1,0)
	
	local StatusTxt = Instance.new("TextLabel"); StatusTxt.Parent = Container
	StatusTxt.BackgroundTransparency = 1; StatusTxt.Position = UDim2.new(0, 0, 0.85, 0)
	StatusTxt.Size = UDim2.new(1, 0, 0, 15); StatusTxt.Font = Enum.Font.GothamMedium
	StatusTxt.Text = "Initializing..."; StatusTxt.TextColor3 = Theme.Accent
	StatusTxt.TextSize = 10; StatusTxt.TextTransparency = 0.5

	TweenService:Create(MainBG, TweenInfo.new(0.5), {BackgroundTransparency = 0.1}):Play()
	TweenService:Create(Container, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
	
	local SpinLoop = RunService.RenderStepped:Connect(function() SpinGrad.Rotation = SpinGrad.Rotation + 3 end)

	Loader.Gui = LoadGui; Loader.BarFill = BarFill; Loader.StatusTxt = StatusTxt
	Loader.Blur = Blur; Loader.SpinLoop = SpinLoop; Loader.MainBG = MainBG; Loader.Container = Container
end

function Loader.Update(text, percent)
	if not Loader.Gui then return end
	Loader.StatusTxt.Text = text
	TweenService:Create(Loader.BarFill, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
end

function Loader.Finish(onFinishCallback)
	if not Loader.Gui then if onFinishCallback then onFinishCallback() end return end
	Loader.Update("Welcome!", 1)
	task.wait(0.5)
	
	local exitInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	TweenService:Create(Loader.Container, exitInfo, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.6, 0)}):Play()
	TweenService:Create(Loader.Blur, TweenInfo.new(0.8), {Size = 0}):Play()
	local fade = TweenService:Create(Loader.MainBG, TweenInfo.new(0.8), {BackgroundTransparency = 1})
	fade:Play()
	
	task.delay(0.65, function() if onFinishCallback then onFinishCallback() end end)
	
	fade.Completed:Connect(function()
		if Loader.SpinLoop then Loader.SpinLoop:Disconnect() end
		Loader.Blur:Destroy(); Loader.Gui:Destroy()
	end)
end

local DefaultStats = { WalkSpeed = 16, JumpPower = 50, Gravity = 196.2 } 

local function SaveDefaultStats()
	local char = LocalPlayer.Character
	DefaultStats.Gravity = Workspace.Gravity 
	
	if char and char:FindFirstChild("Humanoid") then
		DefaultStats.WalkSpeed = char.Humanoid.WalkSpeed
		DefaultStats.JumpPower = char.Humanoid.JumpPower
	end
end
LocalPlayer.CharacterAdded:Connect(function(char) char:WaitForChild("Humanoid", 5); SaveDefaultStats() end)
SaveDefaultStats()

local Session = { 
	StopFly = function() end, 
	StopWalk = function() end, 
	StopJump = function() end, 
	StopGravity = function() end, 
	StopNoclip = function() end, 
	StopInfJump = function() end, 
	ResetAll = function() end,
	OverrideSpeed = false, 
	OverrideJump = false
}

--// [4] GUI SETUP
local ViewportSize = workspace.CurrentCamera.ViewportSize
local IsMobile = ViewportSize.X < 1080
local CurrentScale = IsMobile and 0.75 or 1
local FinalSize = UDim2.new(0, 580, 0, 380)

local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "NeeR_Unified"; ScreenGui.Parent = CoreGui; ScreenGui.IgnoreGuiInset = true; ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

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
	trigger.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			objectToMove.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- MAIN FRAME
local ToggleBtn = Instance.new("ImageButton"); ToggleBtn.Name = "ToggleUI"; ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Theme.Main; ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.AnchorPoint = Vector2.new(0.5, 0.5); ToggleBtn.Position = UDim2.new(0.50, 0, 0.15, 0)
ToggleBtn.Size = UDim2.new(0, 40, 0, 40); ToggleBtn.Image = "rbxassetid://7733960981"
ToggleBtn.ImageColor3 = Theme.Accent; ToggleBtn.ZIndex = 100
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local ToggleStroke = Instance.new("UIStroke"); ToggleStroke.Parent = ToggleBtn
ToggleStroke.Color = Theme.Accent; ToggleStroke.Thickness = 1.5; ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MakeDraggable(ToggleBtn, ToggleBtn)

local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Theme.Main; MainFrame.BackgroundTransparency = Theme.Transp
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = FinalSize; MainFrame.ClipsDescendants = true; MainFrame.Visible = false

local UIScale = Instance.new("UIScale"); UIScale.Parent = MainFrame; UIScale.Scale = CurrentScale
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 12); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Parent = MainFrame
MainStroke.Color = Theme.Accent; MainStroke.Thickness = 1; MainStroke.Transparency = 0.6

local Header = Instance.new("Frame"); Header.Parent = MainFrame; Header.Size = UDim2.new(1, 0, 0, 35); Header.BackgroundTransparency = 1
local Title = Instance.new("TextLabel"); Title.Parent = Header
Title.Text = "NeeR Flow <font color=\"rgb(137,207,240)\">| Script</font>"; Title.RichText = true
Title.Font = Theme.FontBold; Title.TextColor3 = Theme.Text; Title.TextSize = 14
Title.Position = UDim2.new(0, 15, 0, 0); Title.Size = UDim2.new(0, 0, 1, 0); Title.TextXAlignment = Enum.TextXAlignment.Left

local ControlFrame = Instance.new("Frame"); ControlFrame.Parent = Header
ControlFrame.BackgroundTransparency = 1; ControlFrame.Position = UDim2.new(1, -70, 0, 0); ControlFrame.Size = UDim2.new(0, 70, 1, 0)

local MinBtn = Instance.new("TextButton"); MinBtn.Parent = ControlFrame
MinBtn.BackgroundTransparency = 1; MinBtn.Position = UDim2.new(0, 0, 0, 0); MinBtn.Size = UDim2.new(0, 35, 1, 0)
MinBtn.Font = Theme.FontBold; MinBtn.Text = "—"; MinBtn.TextColor3 = Theme.Accent; MinBtn.TextSize = 14

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = ControlFrame
CloseBtn.BackgroundTransparency = 1; CloseBtn.Position = UDim2.new(0, 28, 0, 0); CloseBtn.Size = UDim2.new(0, 35, 1, 0)
CloseBtn.Font = Theme.FontBold; CloseBtn.Text = "X"; CloseBtn.TextColor3 = Theme.Accent; CloseBtn.TextSize = 14

local HeaderLine = Instance.new("Frame"); HeaderLine.Parent = Header
HeaderLine.BackgroundColor3 = Theme.TextDim; HeaderLine.BorderSizePixel = 0
HeaderLine.BackgroundTransparency = 0.5; HeaderLine.Position = UDim2.new(0, 0, 1, -1); HeaderLine.Size = UDim2.new(1, 0, 0, 1)
MakeDraggable(Header, MainFrame)

local Container = Instance.new("Frame"); Container.Parent = MainFrame
Container.BackgroundTransparency = 1; Container.Position = UDim2.new(0, 0, 0, 35); Container.Size = UDim2.new(1, 0, 1, -35)

local SidebarWidth = 130
local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Parent = Container
Sidebar.BackgroundColor3 = Theme.Sidebar; Sidebar.BackgroundTransparency = 0.5; Sidebar.BorderSizePixel = 0
Sidebar.Size = UDim2.new(0, SidebarWidth, 1, 0); Sidebar.ScrollBarThickness = 0; Sidebar.ZIndex = 2
local SidebarStroke = Instance.new("UIStroke"); SidebarStroke.Parent = Sidebar
SidebarStroke.Color = Theme.Separator; SidebarStroke.Thickness = 1; SidebarStroke.Transparency = 0.5; SidebarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local SideList = Instance.new("UIListLayout"); SideList.Parent = Sidebar; SideList.Padding = UDim.new(0, 2); SideList.SortOrder = Enum.SortOrder.LayoutOrder
local SidePadding = Instance.new("UIPadding"); SidePadding.Parent = Sidebar; SidePadding.PaddingTop = UDim.new(0, 8); SidePadding.PaddingLeft = UDim.new(0, 5); SidePadding.PaddingRight = UDim.new(0, 5)

local ContentArea = Instance.new("Frame"); ContentArea.Parent = Container
ContentArea.BackgroundTransparency = 1; ContentArea.Position = UDim2.new(0, SidebarWidth, 0, 0)
ContentArea.Size = UDim2.new(1, -SidebarWidth, 1, 0); ContentArea.ClipsDescendants = true

-- [POPUP EXIT]
local ExitFrame = Instance.new("Frame"); ExitFrame.Name = "ExitFrame"; ExitFrame.Parent = ScreenGui
ExitFrame.BackgroundColor3 = Theme.Main; ExitFrame.BackgroundTransparency = 0.1
ExitFrame.Size = UDim2.new(0, 0, 0, 0); ExitFrame.Position = UDim2.new(0.5, 0, 0.5, 0); ExitFrame.AnchorPoint = Vector2.new(0.5, 0.5); ExitFrame.Visible = false; ExitFrame.ClipsDescendants = true
Instance.new("UICorner", ExitFrame).CornerRadius = UDim.new(0, 10)
local ES = Instance.new("UIStroke"); ES.Parent = ExitFrame; ES.Color = Theme.Red; ES.Thickness = 1
local ExitTitle = Instance.new("TextLabel"); ExitTitle.Parent = ExitFrame; ExitTitle.Text = "EXIT SCRIPT?"; ExitTitle.Font = Theme.FontBold; ExitTitle.TextColor3 = Theme.Red; ExitTitle.Position = UDim2.new(0, 0, 0.15, 0); ExitTitle.Size = UDim2.new(1, 0, 0, 20); ExitTitle.BackgroundTransparency = 1
local ExitMsg = Instance.new("TextLabel"); ExitMsg.Parent = ExitFrame; ExitMsg.Text = "Are you sure you want to close?"; ExitMsg.Font = Theme.FontMain; ExitMsg.TextColor3 = Theme.TextDim; ExitMsg.Position = UDim2.new(0, 0, 0.35, 0); ExitMsg.Size = UDim2.new(1, 0, 0, 20); ExitMsg.BackgroundTransparency = 1; ExitMsg.TextSize = 12
local YesBtn = Instance.new("TextButton"); YesBtn.Parent = ExitFrame; YesBtn.BackgroundColor3 = Theme.Red; YesBtn.Text = "YES, CLOSE"; YesBtn.TextColor3 = Theme.Text; YesBtn.Font = Theme.FontBold; YesBtn.Position = UDim2.new(0.1, 0, 0.65, 0); YesBtn.Size = UDim2.new(0.35, 0, 0, 30); Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 6)
local NoBtn = Instance.new("TextButton"); NoBtn.Parent = ExitFrame; NoBtn.BackgroundColor3 = Theme.ActiveTab; NoBtn.Text = "NO, RETURN"; NoBtn.TextColor3 = Theme.Text; NoBtn.Font = Theme.FontBold; NoBtn.Position = UDim2.new(0.55, 0, 0.65, 0); NoBtn.Size = UDim2.new(0.35, 0, 0, 30); Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; ExitFrame.Visible = true; TweenService:Create(ExitFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 250, 0, 140)}):Play() end)
NoBtn.MouseButton1Click:Connect(function() local c = TweenService:Create(ExitFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}); c:Play(); c.Completed:Connect(function() ExitFrame.Visible = false; MainFrame.Visible = true end) end)
YesBtn.MouseButton1Click:Connect(function() local b = TweenService:Create(ExitFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}); b:Play(); b.Completed:Connect(function() Session.ResetAll(); ScreenGui:Destroy() end) end)

--// [5] UI HELPERS (OPTIMIZED GLOBAL SYSTEM)
local Tabs = {}
local function SwitchTab(tabName)
	for _, page in pairs(ContentArea:GetChildren()) do if page:IsA("ScrollingFrame") then page.Visible = false end end
	if Tabs[tabName] then Tabs[tabName].Visible = true end
end

local function CreateTabBtn(name, isActive)
	local Btn = Instance.new("TextButton"); Btn.Parent = Sidebar
	Btn.BackgroundColor3 = isActive and Theme.ActiveTab or Theme.Sidebar; Btn.BackgroundTransparency = isActive and 0 or 1; Btn.Size = UDim2.new(1, 0, 0, 28)
	Btn.AutoButtonColor = false; Btn.Font = Theme.FontMain; Btn.Text = name; Btn.TextColor3 = isActive and Theme.Accent or Theme.TextDim; Btn.TextSize = 12
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
	if isActive then local s = Instance.new("UIStroke"); s.Parent = Btn; s.Color = Theme.Accent; s.Thickness = 1; s.Transparency = 0.8 end
	
	local Page = Instance.new("ScrollingFrame"); Page.Name = name .. "Page"; Page.Parent = ContentArea
	Page.BackgroundTransparency = 1; Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = isActive; Page.ScrollBarThickness = 2
	local PL = Instance.new("UIListLayout"); PL.Parent = Page; PL.Padding = UDim.new(0, 5); PL.SortOrder = Enum.SortOrder.LayoutOrder
	local PP = Instance.new("UIPadding"); PP.Parent = Page; PP.PaddingTop = UDim.new(0, 10); PP.PaddingLeft = UDim.new(0, 10); PP.PaddingRight = UDim.new(0, 10)
	Tabs[name] = Page
	PL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, (PL.AbsoluteContentSize.Y / UIScale.Scale) + 20) end)
	
	Btn.MouseButton1Click:Connect(function()
		for _, child in pairs(Sidebar:GetChildren()) do if child:IsA("TextButton") then child.BackgroundColor3 = Theme.Sidebar; child.BackgroundTransparency = 1; child.TextColor3 = Theme.TextDim; if child:FindFirstChild("UIStroke") then child.UIStroke:Destroy() end end end
		Btn.BackgroundColor3 = Theme.ActiveTab; Btn.BackgroundTransparency = 0; Btn.TextColor3 = Theme.Accent
		local s = Instance.new("UIStroke"); s.Parent = Btn; s.Color = Theme.Accent; s.Thickness = 1; s.Transparency = 0.8
		SwitchTab(name)
	end)
	return Page
end

local function CreateCard(parent, size, layoutOrder)
	local Card = Instance.new("Frame"); Card.Parent = parent
	Card.BackgroundColor3 = Theme.ActiveTab; Card.BackgroundTransparency = 0.2; Card.Size = size; Card.LayoutOrder = layoutOrder or 0
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
	local S = Instance.new("UIStroke"); S.Parent = Card; S.Color = Theme.Accent; S.Transparency = 0.8; S.Thickness = 1
	return Card
end

local function CreateExpandableSection(parent, title)
	local SectionContainer = Instance.new("Frame"); SectionContainer.Parent = parent; SectionContainer.BackgroundTransparency = 1; SectionContainer.Size = UDim2.new(1, 0, 0, 30); SectionContainer.ClipsDescendants = true
	local HeaderBtn = Instance.new("TextButton"); HeaderBtn.Parent = SectionContainer; HeaderBtn.BackgroundColor3 = Theme.ActiveTab; HeaderBtn.BackgroundTransparency = 0.2; HeaderBtn.Size = UDim2.new(1, 0, 0, 30); HeaderBtn.AutoButtonColor = true; HeaderBtn.Text = ""; Instance.new("UICorner", HeaderBtn).CornerRadius = UDim.new(0, 6)
	local HS = Instance.new("UIStroke"); HS.Parent = HeaderBtn; HS.Color = Theme.Accent; HS.Transparency = 0.6; HS.Thickness = 1
	local TitleLbl = Instance.new("TextLabel"); TitleLbl.Parent = HeaderBtn; TitleLbl.BackgroundTransparency = 1; TitleLbl.Position = UDim2.new(0, 10, 0, 0); TitleLbl.Size = UDim2.new(1, -40, 1, 0); TitleLbl.Font = Theme.FontBold; TitleLbl.Text = title; TitleLbl.TextColor3 = Theme.Text; TitleLbl.TextSize = 13; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	local Arrow = Instance.new("TextLabel"); Arrow.Parent = HeaderBtn; Arrow.BackgroundTransparency = 1; Arrow.Position = UDim2.new(1, -30, 0, 0); Arrow.Size = UDim2.new(0, 30, 1, 0); Arrow.Font = Theme.FontBold; Arrow.Text = "+"; Arrow.TextColor3 = Theme.Accent; Arrow.TextSize = 18
	local ContentFrame = Instance.new("Frame"); ContentFrame.Parent = SectionContainer; ContentFrame.BackgroundColor3 = Color3.fromRGB(0,0,0); ContentFrame.BackgroundTransparency = 0.9; ContentFrame.Position = UDim2.new(0, 0, 0, 35); ContentFrame.Size = UDim2.new(1, 0, 0, 0); Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 6)
	local CL = Instance.new("UIListLayout"); CL.Parent = ContentFrame; CL.SortOrder = Enum.SortOrder.LayoutOrder; CL.Padding = UDim.new(0, 5)
	local CP = Instance.new("UIPadding"); CP.Parent = ContentFrame; CP.PaddingTop = UDim.new(0, 5); CP.PaddingBottom = UDim.new(0, 5); CP.PaddingLeft = UDim.new(0, 5); CP.PaddingRight = UDim.new(0, 5)
	local isOpen = false
	HeaderBtn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		if isOpen then Arrow.Text = "-"; Arrow.TextColor3 = Theme.Red; local currentScale = UIScale.Scale; local rawHeight = CL.AbsoluteContentSize.Y + 15; local scaledHeight = rawHeight / currentScale; TweenService:Create(SectionContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, (35/currentScale) + scaledHeight)}):Play(); TweenService:Create(ContentFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, scaledHeight)}):Play()
		else Arrow.Text = "+"; Arrow.TextColor3 = Theme.Accent; TweenService:Create(SectionContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 30)}):Play() end
	end)
	return ContentFrame
end

local function CreateFeatureCard(parent, title, height)
	local Card = Instance.new("Frame"); Card.Parent = parent
	Card.BackgroundColor3 = Theme.ActiveTab
	Card.BackgroundTransparency = 0.2
	Card.Size = UDim2.new(1, 0, 0, height or 32)
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
	local Stroke = Instance.new("UIStroke"); Stroke.Parent = Card; Stroke.Color = Theme.Accent; Stroke.Thickness = 1; Stroke.Transparency = 0.8
	local Lbl = Instance.new("TextLabel"); Lbl.Parent = Card
	Lbl.Text = title; Lbl.Font = Theme.FontBold; Lbl.TextColor3 = Theme.Text; Lbl.TextSize = 12
	Lbl.BackgroundTransparency = 1; Lbl.TextXAlignment = Enum.TextXAlignment.Left
	if (height or 32) > 40 then Lbl.Position = UDim2.new(0, 10, 0, 8); Lbl.Size = UDim2.new(0.6, 0, 0, 16); Lbl.TextYAlignment = Enum.TextYAlignment.Center
	else Lbl.Position = UDim2.new(0, 10, 0, 0); Lbl.Size = UDim2.new(0.6, 0, 1, 0); Lbl.TextYAlignment = Enum.TextYAlignment.Center end
	return Card, Lbl
end

local function AttachSwitch(parentCard, default, callback)
	local Sw = Instance.new("TextButton"); Sw.Parent = parentCard
	Sw.BackgroundColor3 = Theme.Sidebar; Sw.Size = UDim2.new(0, 30, 0, 16); Sw.Text = ""; Sw.AutoButtonColor = false
	Instance.new("UICorner", Sw).CornerRadius = UDim.new(1, 0)
	local Circ = Instance.new("Frame"); Circ.Parent = Sw
	Circ.BackgroundColor3 = Theme.TextDim; Circ.Size = UDim2.new(0, 12, 0, 12); Circ.Position = UDim2.new(0, 2, 0.5, -6)
	Instance.new("UICorner", Circ).CornerRadius = UDim.new(1, 0)
	if parentCard.Size.Y.Offset > 40 then Sw.AnchorPoint = Vector2.new(1, 0); Sw.Position = UDim2.new(1, -8, 0, 8) 
	else Sw.AnchorPoint = Vector2.new(1, 0.5); Sw.Position = UDim2.new(1, -8, 0.5, 0) end
	local active = default
	local function SetState(newState, skipCallback)
		active = newState
		if active then TweenService:Create(Circ, TweenInfo.new(0.15), {Position=UDim2.new(1,-14,0.5,-6), BackgroundColor3=Theme.Main}):Play(); TweenService:Create(Sw, TweenInfo.new(0.15), {BackgroundColor3=Theme.Accent}):Play()
		else TweenService:Create(Circ, TweenInfo.new(0.15), {Position=UDim2.new(0,2,0.5,-6), BackgroundColor3=Theme.TextDim}):Play(); TweenService:Create(Sw, TweenInfo.new(0.15), {BackgroundColor3=Theme.Sidebar}):Play() end
		if not skipCallback and callback then callback(active) end
	end
	Sw.MouseButton1Click:Connect(function() SetState(not active) end)
	if default then SetState(true) end
	return SetState
end

-- [GLOBAL SLIDER SYSTEM]
local ActiveSlider = nil 
local function UpdateSliderValue(input)
	if not ActiveSlider then return end
	local d = ActiveSlider 
	local mouseRel = input.Position.X - d.BG.AbsolutePosition.X
	local knobWidth = d.Knob.AbsoluteSize.X
	local barWidth = d.BG.AbsoluteSize.X
	local slideableWidth = barWidth - knobWidth
	local targetPos = mouseRel - (knobWidth / 2)
	local clampedPos = math.clamp(targetPos, 0, slideableWidth)
	local percent = clampedPos / slideableWidth
	d.Knob.Position = UDim2.new(0, clampedPos, 0.5, 0)
	d.Fill.Size = UDim2.new(0, clampedPos, 1, 0)
	local val = math.floor((d.Min + ((d.Max - d.Min) * percent)) * 10) / 10
	if math.abs(d.Max - d.Min) > 100 then val = math.floor(val) end
	d.Label.Text = tostring(val) .. (d.Suffix or "")
	d.Callback(val)
end
UserInputService.InputChanged:Connect(function(input) if ActiveSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateSliderValue(input) end end)
UserInputService.InputEnded:Connect(function(input) if ActiveSlider and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then ActiveSlider = nil end end)

local function AttachSlider(parentCard, min, max, default, callback, valueSuffix)
	local BG = Instance.new("TextButton"); BG.Parent = parentCard
	BG.BackgroundColor3 = Theme.Sidebar; BG.Size = UDim2.new(1, -24, 0, 6); BG.Position = UDim2.new(0, 12, 0, 38)
	BG.Text = ""; BG.AutoButtonColor = false; Instance.new("UICorner", BG).CornerRadius = UDim.new(1, 0)
	local Fill = Instance.new("Frame"); Fill.Parent = BG
	Fill.BackgroundColor3 = Theme.Accent; Fill.Size = UDim2.new(0, 0, 1, 0); Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
	local Knob = Instance.new("Frame"); Knob.Parent = BG
	Knob.BackgroundColor3 = Theme.Main; Knob.Size = UDim2.new(0, 34, 0, 16); Knob.AnchorPoint = Vector2.new(0, 0.5); Knob.Position = UDim2.new(0, 0, 0.5, 0); Instance.new("UICorner", Knob).CornerRadius = UDim.new(0, 4)
	local KS = Instance.new("UIStroke"); KS.Parent = Knob; KS.Color = Theme.Accent; KS.Thickness = 1.5; KS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local ValLbl = Instance.new("TextLabel"); ValLbl.Parent = Knob
	ValLbl.BackgroundTransparency = 1; ValLbl.Size = UDim2.new(1, 0, 1, 0); ValLbl.Font = Theme.FontBold; ValLbl.TextColor3 = Theme.Accent; ValLbl.TextSize = 9; ValLbl.TextXAlignment = Enum.TextXAlignment.Center; ValLbl.TextYAlignment = Enum.TextYAlignment.Center
	local startPercent = math.clamp((default - min) / (max - min), 0, 1)
	Fill.Size = UDim2.new(startPercent, 0, 1, 0); Knob.Position = UDim2.new(startPercent * 0.9, 0, 0.5, 0); ValLbl.Text = tostring(default) .. (valueSuffix or "")
	BG.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then ActiveSlider = {BG = BG, Knob = Knob, Fill = Fill, Label = ValLbl, Min = min, Max = max, Callback = callback, Suffix = valueSuffix}; UpdateSliderValue(input) end end)
end

local function CreateStepperCard(parent, title, defaultVal, min, max, step, onToggle, onValChange)
	local Card, Lbl = CreateFeatureCard(parent, title, 36)
	local SetToggle = AttachSwitch(Card, false, function(active) onToggle(active) end)
	local Ctrl = Instance.new("Frame"); Ctrl.Parent = Card; Ctrl.BackgroundTransparency = 1; Ctrl.Position = UDim2.new(1, -155, 0, 0); Ctrl.Size = UDim2.new(0, 110, 1, 0)
	local MinBtn = Instance.new("TextButton"); MinBtn.Parent = Ctrl; MinBtn.BackgroundColor3 = Theme.Sidebar; MinBtn.Position = UDim2.new(0, 0, 0.5, -10); MinBtn.Size = UDim2.new(0, 20, 0, 20); MinBtn.Font = Theme.FontBold; MinBtn.Text = "-"; MinBtn.TextColor3 = Theme.Red; Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)
	local ValLbl = Instance.new("TextLabel"); ValLbl.Parent = Ctrl; ValLbl.BackgroundTransparency = 1; ValLbl.Position = UDim2.new(0, 22, 0, 0); ValLbl.Size = UDim2.new(0, 36, 1, 0); ValLbl.Font = Theme.FontBold; ValLbl.Text = tostring(defaultVal); ValLbl.TextColor3 = Theme.Text; ValLbl.TextSize = 11
	local PlsBtn = Instance.new("TextButton"); PlsBtn.Parent = Ctrl; PlsBtn.BackgroundColor3 = Theme.Sidebar; PlsBtn.Position = UDim2.new(0, 60, 0.5, -10); PlsBtn.Size = UDim2.new(0, 20, 0, 20); PlsBtn.Font = Theme.FontBold; PlsBtn.Text = "+"; PlsBtn.TextColor3 = Theme.Green; Instance.new("UICorner", PlsBtn).CornerRadius = UDim.new(0, 4)
	local currentVal = defaultVal
	MinBtn.MouseButton1Click:Connect(function() currentVal = math.max(min, currentVal - step); if step < 1 then ValLbl.Text = string.format("%.1f", currentVal) else ValLbl.Text = tostring(currentVal) end; onValChange(currentVal) end)
	PlsBtn.MouseButton1Click:Connect(function() currentVal = math.min(max, currentVal + step); if step < 1 then ValLbl.Text = string.format("%.1f", currentVal) else ValLbl.Text = tostring(currentVal) end; onValChange(currentVal) end)
	return { Reset = function() currentVal = defaultVal; ValLbl.Text = tostring(defaultVal); SetToggle(false); onValChange(defaultVal) end, Card = Card }
end

local function CreateHybridCard(parentSection, title, switchCallback, min, max, defaultVal, sliderCallback, valueSuffix)
	local Card = CreateFeatureCard(parentSection, title, 55)
	local SetToggle = AttachSwitch(Card, false, switchCallback)
	AttachSlider(Card, min, max, defaultVal, sliderCallback, valueSuffix)
	return { Card = Card, SetToggle = SetToggle }
end

local function CreateActionCard(parent, title, btnText, btnColor, callback)
	local Card, Lbl = CreateFeatureCard(parent, title, 32)
	local Btn = Instance.new("TextButton"); Btn.Parent = Card; Btn.BackgroundColor3 = Theme.Main; Btn.AnchorPoint = Vector2.new(1, 0.5); Btn.Position = UDim2.new(1, -8, 0.5, 0); Btn.Size = UDim2.new(0, 60, 0, 20); Btn.Text = btnText; Btn.Font = Theme.FontBold; Btn.TextColor3 = btnColor or Theme.Accent; Btn.TextSize = 9; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
	local Stroke = Instance.new("UIStroke"); Stroke.Parent = Btn; Stroke.Color = btnColor or Theme.Accent; Stroke.Thickness = 1.2; Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local isRunning = false
	Btn.MouseButton1Click:Connect(function() if isRunning then return end; isRunning = true; local originalText = Btn.Text; Btn.Text = "WAIT..."; Btn.TextColor3 = Theme.TextDim; Stroke.Color = Theme.TextDim; task.wait(0.1); callback(); Btn.Text = "DONE"; Btn.TextColor3 = btnColor or Theme.Accent; Stroke.Color = btnColor or Theme.Accent; task.wait(0.8); Btn.Text = originalText; isRunning = false end)
	return Btn
end

local function CreateSwitchCard(targetParent, text, callback) local C = CreateFeatureCard(targetParent, text, 32); local SetState = AttachSwitch(C, false, callback); return { Card = C, SetState = SetState } end
local function CreateMainSwitch(targetParent, text, callback) return CreateSwitchCard(targetParent, text, callback) end

-- [GLOBAL TAB HELPERS]
local function CreateSessionBtn(parent, text, color, pos, callback)
	local Btn = Instance.new("TextButton"); Btn.Parent = parent; Btn.BackgroundColor3 = Theme.Sidebar; Btn.Position = pos; Btn.Size = UDim2.new(1, -30, 0, 30); Btn.Font = Theme.FontBold; Btn.Text = text; Btn.TextColor3 = color; Btn.TextSize = 11; Btn.AutoButtonColor = true; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6); local S = Instance.new("UIStroke"); S.Parent = Btn; S.Color = color; S.Thickness = 1; S.Transparency = 0.7; S.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Btn.MouseButton1Click:Connect(function() callback(Btn) end)
	return Btn
end

local function CreateNeonBtn(parent, name, pos, size)
	local Btn = Instance.new("TextButton"); Btn.Parent = parent; Btn.BackgroundColor3 = Theme.Main; Btn.Position = pos; Btn.Size = size; Btn.Font = Theme.FontBold; Btn.Text = name; Btn.TextColor3 = Theme.Accent; Btn.TextSize = 10; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6); local S = Instance.new("UIStroke"); S.Parent = Btn; S.Color = Theme.Accent; S.Thickness = 1; S.Transparency = 0.4; S.ApplyStrokeMode = Enum.ApplyStrokeMode.Border 
	return Btn, S
end

local function SetButtonStyle(Btn, Stroke, IsActive, ActiveText, DefaultText)
	if IsActive then Btn.BackgroundColor3 = Theme.Accent; Btn.TextColor3 = Theme.Main; Btn.Text = ActiveText or DefaultText; Stroke.Transparency = 1
	else Btn.BackgroundColor3 = Theme.Main; Btn.TextColor3 = Theme.Accent; Btn.Text = DefaultText; Stroke.Transparency = 0.4 end
end

local function CreatePerfectMiniSlider(parent, name, cb)
	local Box = Instance.new("Frame"); Box.Parent = parent; Box.BackgroundColor3 = Theme.Main; Box.BackgroundTransparency = 0.6; Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
	local T = Instance.new("TextLabel"); T.Parent = Box; T.Text = name; T.Position = UDim2.new(0, 8, 0, 6); T.Size = UDim2.new(1, -16, 0, 15); T.BackgroundTransparency = 1; T.TextColor3 = Theme.TextDim; T.Font = Theme.FontMain; T.TextSize = 10; T.TextXAlignment = Enum.TextXAlignment.Center
	local BG = Instance.new("TextButton"); BG.Parent = Box; BG.BackgroundColor3 = Theme.Sidebar; BG.Size = UDim2.new(1, -16, 0, 6); BG.Position = UDim2.new(0, 8, 0, 32); BG.Text = ""; BG.AutoButtonColor = false; Instance.new("UICorner", BG).CornerRadius = UDim.new(1, 0)
	local Fill = Instance.new("Frame"); Fill.Parent = BG; Fill.BackgroundColor3 = Theme.Accent; Fill.Size = UDim2.new(0.5, 0, 1, 0); Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
	local Knob = Instance.new("Frame"); Knob.Parent = BG; Knob.BackgroundColor3 = Theme.Main; Knob.Size = UDim2.new(0, 30, 0, 14); Knob.AnchorPoint = Vector2.new(0, 0.5); Knob.Position = UDim2.new(0.5, 0, 0.5, 0); Instance.new("UICorner", Knob).CornerRadius = UDim.new(0, 4); local KS = Instance.new("UIStroke"); KS.Parent = Knob; KS.Color = Theme.Accent; KS.Thickness = 1.5
	local V = Instance.new("TextLabel"); V.Parent = Knob; V.Text = "0"; V.Size = UDim2.new(1, 0, 1, 0); V.BackgroundTransparency = 1; V.TextColor3 = Theme.Accent; V.Font = Theme.FontBold; V.TextSize = 9
	-- [UNIFIED GLOBAL LOGIC]
	BG.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then ActiveSlider = {BG = BG, Knob = Knob, Fill = Fill, Label = V, Min = -4, Max = 4, Callback = cb, Suffix = ""}; UpdateSliderValue(input) end end)
end

--// [6] TABS & FEATURES
local function BuildInfoTab(parentFrame)
	local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 14)
	local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)
	
	local PingCard = CreateCard(parentFrame, UDim2.new(1, 0, 0,60), 1)
	local PingTitle = Instance.new("TextLabel"); PingTitle.Parent = PingCard; PingTitle.BackgroundTransparency = 1; PingTitle.Position = UDim2.new(0, 15, 0, 5); PingTitle.Size = UDim2.new(1, -30, 0, 20); PingTitle.Font = Theme.FontBold; PingTitle.Text = "Network Ping"; PingTitle.TextColor3 = Theme.TextDim; PingTitle.TextSize = 12; PingTitle.TextXAlignment = Enum.TextXAlignment.Left
	local PingValue = Instance.new("TextLabel"); PingValue.Parent = PingCard; PingValue.BackgroundTransparency = 1; PingValue.Position = UDim2.new(0, 15, 0, 5); PingValue.Size = UDim2.new(1, -30, 0, 20); PingValue.Font = Theme.FontBold; PingValue.Text = "0 ms"; PingValue.TextColor3 = Theme.Accent; PingValue.TextSize = 12; PingValue.TextXAlignment = Enum.TextXAlignment.Right
	local BarBg = Instance.new("Frame"); BarBg.Parent = PingCard; BarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40); BarBg.Position = UDim2.new(0, 15, 0, 35); BarBg.Size = UDim2.new(1, -30, 0, 10); Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)
	local BarFill = Instance.new("Frame"); BarFill.Parent = BarBg; BarFill.BackgroundColor3 = Theme.Accent; BarFill.Size = UDim2.new(0.5, 0, 1, 0); Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

	local GridContainer = Instance.new("Frame"); GridContainer.Parent = parentFrame; GridContainer.BackgroundTransparency = 1; GridContainer.Size = UDim2.new(1,1, 0, 50); GridContainer.LayoutOrder = 2
	local GL = Instance.new("UIGridLayout"); GL.Parent = GridContainer; GL.CellPadding = UDim2.new(0, 5, 0, 0); GL.CellSize = UDim2.new(0.493, 0, 1, 0); GL.SortOrder = Enum.SortOrder.LayoutOrder; GL.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local FPSCard = CreateCard(GridContainer, UDim2.new(0,0,0,0), 1)
	local FPSTitle = Instance.new("TextLabel"); FPSTitle.Parent = FPSCard; FPSTitle.BackgroundTransparency = 1; FPSTitle.Position = UDim2.new(0, 12, 0, 35); FPSTitle.Size = UDim2.new(1, -24, 0, 10); FPSTitle.Font = Theme.FontMain; FPSTitle.Text = "FPS Counter"; FPSTitle.TextColor3 = Theme.TextDim; FPSTitle.TextSize = 12; FPSTitle.TextXAlignment = Enum.TextXAlignment.Left
	local FPSNum = Instance.new("TextLabel"); FPSNum.Parent = FPSCard; FPSNum.BackgroundTransparency = 1; FPSNum.Position = UDim2.new(0, 12, 0, 12); FPSNum.Size = UDim2.new(1, -24, 0, 10); FPSNum.Font = Theme.FontBold; FPSNum.Text = "60"; FPSNum.TextColor3 = Theme.Text; FPSNum.TextSize = 28; FPSNum.TextXAlignment = Enum.TextXAlignment.Left
	local MemCard = CreateCard(GridContainer, UDim2.new(0,0,0,0), 2)
	local MemTitle = Instance.new("TextLabel"); MemTitle.Parent = MemCard; MemTitle.BackgroundTransparency = 1; MemTitle.Position = UDim2.new(0, 12, 0, 35); MemTitle.Size = UDim2.new(1, -24, 0, 10); MemTitle.Font = Theme.FontMain; MemTitle.Text = "Memory RAM"; MemTitle.TextColor3 = Theme.TextDim; MemTitle.TextSize = 12; MemTitle.TextXAlignment = Enum.TextXAlignment.Left
	local MemNum = Instance.new("TextLabel"); MemNum.Parent = MemCard; MemNum.BackgroundTransparency = 1; MemNum.Position = UDim2.new(0, 12, 0, 12); MemNum.Size = UDim2.new(1, -24, 0, 10); MemNum.Font = Theme.FontBold; MemNum.Text = "0"; MemNum.TextColor3 = Theme.Text; MemNum.TextSize = 24; MemNum.TextXAlignment = Enum.TextXAlignment.Left

	local TimeCard = CreateCard(parentFrame, UDim2.new(1, 0, 0, 55), 3)
	local TimeTitle = Instance.new("TextLabel"); TimeTitle.Parent = TimeCard; TimeTitle.BackgroundTransparency = 1; TimeTitle.Position = UDim2.new(0, 15, 0, 2); TimeTitle.Size = UDim2.new(1, -30, 0, 20); TimeTitle.Font = Theme.FontBold; TimeTitle.Text = "Time Server"; TimeTitle.TextColor3 = Theme.TextDim; TimeTitle.TextSize = 12; TimeTitle.TextXAlignment = Enum.TextXAlignment.Left
	local ClockLabel = Instance.new("TextLabel"); ClockLabel.Parent = TimeCard; ClockLabel.BackgroundTransparency = 1; ClockLabel.Position = UDim2.new(0, 15, 0, 0); ClockLabel.Size = UDim2.new(1, -30, 0, 35); ClockLabel.Font = Theme.FontBold; ClockLabel.Text = "00:00:00"; ClockLabel.TextColor3 = Theme.Text; ClockLabel.TextSize = 34; ClockLabel.TextXAlignment = Enum.TextXAlignment.Right
	local DateLabel = Instance.new("TextLabel"); DateLabel.Parent = TimeCard; DateLabel.BackgroundTransparency = 1; DateLabel.Position = UDim2.new(0, 15, 0, 30); DateLabel.Size = UDim2.new(1, -30, 0, 20); DateLabel.Font = Theme.FontMain; DateLabel.Text = "Monday, 1 Jan 2024"; DateLabel.TextColor3 = Theme.Accent; DateLabel.TextSize = 14; DateLabel.TextXAlignment = Enum.TextXAlignment.Right

	local SessionCard = CreateCard(parentFrame, UDim2.new(1, 0, 0, 115), 4)
	local SessionTitle = Instance.new("TextLabel"); SessionTitle.Parent = SessionCard; SessionTitle.BackgroundTransparency = 1; SessionTitle.Position = UDim2.new(0, 15, 0, 8); SessionTitle.Size = UDim2.new(1, -30, 0, 10); SessionTitle.Font = Theme.FontBold; SessionTitle.Text = "Session Manager"; SessionTitle.TextColor3 = Theme.TextDim; SessionTitle.TextSize = 12; SessionTitle.TextXAlignment = Enum.TextXAlignment.Left
	
	CreateSessionBtn(SessionCard, "REJOIN SERVER", Theme.Accent, UDim2.new(0, 15, 0, 30), function(btn)
		btn.Text = "REJOINING..." 
		btn.AutoButtonColor = false
		local TS = game:GetService("TeleportService"); local LP = game:GetService("Players").LocalPlayer
		TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) 
	end)

	CreateSessionBtn(SessionCard, "SERVER HOP (LOW/SEPI)", Theme.Green, UDim2.new(0, 15, 0, 70), function(btn)
		btn.Text = "SEARCHING LOW SERVER..."
		btn.AutoButtonColor = false
		local Http = game:GetService("HttpService"); local TS = game:GetService("TeleportService")
		local Servers = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
		local found = false
		for _, s in pairs(Servers.data) do
			if s.playing < s.maxPlayers and s.id ~= game.JobId then
				TS:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
				found = true; break
			end
		end
		if not found then btn.Text = "NO SERVERS FOUND"; task.wait(1); btn.Text = "SERVER HOP (LOW/SEPI)"; btn.AutoButtonColor = true end
	end)

	task.spawn(function()
		local LastFPSTime = tick(); local FrameCount = 0; local FPS_Connection
		FPS_Connection = RunService.RenderStepped:Connect(function()
			if not parentFrame.Parent then FPS_Connection:Disconnect(); return end
			FrameCount = FrameCount + 1
			if tick() - LastFPSTime >= 0.5 then local fps = math.floor(FrameCount / (tick() - LastFPSTime)); FPSNum.Text = tostring(fps); FrameCount = 0; LastFPSTime = tick() end
		end)
		local PingTween = TweenInfo.new(0.5, Enum.EasingStyle.Sine)
		while parentFrame.Parent do
			local rawPing = LocalPlayer:GetNetworkPing(); local ping = math.round(rawPing * 1000)
			PingValue.Text = ping .. " ms"
			local barSize = math.clamp(ping / 300, 0.05, 1)
			TweenService:Create(BarFill, PingTween, {Size = UDim2.new(barSize, 0, 1, 0), BackgroundColor3 = ping < 100 and Theme.Green or ping < 200 and Color3.fromRGB(255, 200, 0) or Theme.Red}):Play()
			MemNum.Text = tostring(math.floor(Stats:GetTotalMemoryUsageMb())); ClockLabel.Text = os.date("%H:%M:%S"); DateLabel.Text = os.date("%A, %d %B %Y")
			task.wait(1)
		end
		if FPS_Connection then FPS_Connection:Disconnect() end
	end)
end

local function BuildMovementTab(parentFrame)
	local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 10)
	local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)

	local flying, flySpeed = false, 1
	local flyAttachment, flyLV, flyAO, flyLoop = nil, nil, nil, nil

	Session.StopFly = function()
		flying = false
		if flyLoop then flyLoop:Disconnect(); flyLoop = nil end
		if flyLV then flyLV:Destroy(); flyLV = nil end
		if flyAO then flyAO:Destroy(); flyAO = nil end
		if flyAttachment then flyAttachment:Destroy(); flyAttachment = nil end
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false; char.Humanoid:ChangeState(Enum.HumanoidStateType.Landed) end
	end
	
	local FlyCtrl = CreateStepperCard(parentFrame, "Fly Mode (Speed)", 1, 1, 500, 1, function(active)
		flying = active
		if not active then Session.StopFly() 
		else
			Session.StopWalk(); Session.StopJump()
			local char = LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid"); local cam = workspace.CurrentCamera
			if not root or not hum then return end
			flyAttachment = Instance.new("Attachment"); flyAttachment.Name = "NeeR_FlyAtt"; flyAttachment.Parent = root
			flyLV = Instance.new("LinearVelocity"); flyLV.Name = "NeeR_FlyLV"; flyLV.Attachment0 = flyAttachment; flyLV.MaxForce = math.huge; flyLV.VectorVelocity = Vector3.zero; flyLV.RelativeTo = Enum.ActuatorRelativeTo.World; flyLV.Parent = root
			flyAO = Instance.new("AlignOrientation"); flyAO.Name = "NeeR_FlyAO"; flyAO.Attachment0 = flyAttachment; flyAO.Mode = Enum.OrientationAlignmentMode.OneAttachment; flyAO.MaxTorque = math.huge; flyAO.Responsiveness = 200; flyAO.CFrame = root.CFrame; flyAO.Parent = root
			hum.PlatformStand = true
			flyLoop = RunService.Heartbeat:Connect(function()
				if not flying or not char or not root.Parent then Session.StopFly() return end
				local moveDir = hum.MoveDirection; local camCF = cam.CFrame
				flyAO.CFrame = camCF
				if moveDir.Magnitude > 0 then
					local relDir = camCF:VectorToObjectSpace(moveDir); local rawDir = (camCF.LookVector * -relDir.Z) + (camCF.RightVector * relDir.X)
					if rawDir.Magnitude > 0.01 then rawDir = rawDir.Unit end
					flyLV.VectorVelocity = rawDir * (flySpeed * 50)
				else flyLV.VectorVelocity = Vector3.zero end
			end)
		end
	end, function(val) flySpeed = val end)

	local walkLoop; local currentWalkMultiplier = 1
	local SpeedCtrl = CreateStepperCard(parentFrame, "Speed Walk (Mult)", 1, 1, 500, 1, function(active)
		if walkLoop then walkLoop:Disconnect(); walkLoop = nil end
		if active then walkLoop = RunService.Heartbeat:Connect(function() if Session.OverrideSpeed then return end; local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then local targetSpeed = DefaultStats.WalkSpeed * currentWalkMultiplier; if char.Humanoid.WalkSpeed ~= targetSpeed then char.Humanoid.WalkSpeed = targetSpeed end end end) 
		else Session.StopWalk() end
	end, function(val) currentWalkMultiplier = val end)
	
	Session.StopWalk = function() if walkLoop then walkLoop:Disconnect(); walkLoop = nil end; if not Session.OverrideSpeed then local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = DefaultStats.WalkSpeed end end end

	local jumpLoop; local currentJumpMultiplier = 1
	local JumpCtrl = CreateStepperCard(parentFrame, "High Jump (Mult)", 1, 1, 500, 1, function(active)
		if jumpLoop then jumpLoop:Disconnect(); jumpLoop = nil end
		if active then jumpLoop = RunService.Heartbeat:Connect(function() if Session.OverrideJump then return end; local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then local targetJump = DefaultStats.JumpPower * currentJumpMultiplier; if not char.Humanoid.UseJumpPower then char.Humanoid.UseJumpPower = true end; if char.Humanoid.JumpPower ~= targetJump then char.Humanoid.JumpPower = targetJump end end end) 
		else Session.StopJump() end
	end, function(val) currentJumpMultiplier = val end)
	
	Session.StopJump = function() if jumpLoop then jumpLoop:Disconnect(); jumpLoop = nil end; if not Session.OverrideJump then local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid.JumpPower = DefaultStats.JumpPower end end end

	local gravLoop; local currentGravLevel = 1
	Session.StopGravity = function() if gravLoop then gravLoop:Disconnect(); gravLoop = nil end; Workspace.Gravity = DefaultStats.Gravity end
	local GravCtrl = CreateStepperCard(parentFrame, "Low Gravity (Div)", 1, 1, 20, 1, function(active)
		if gravLoop then gravLoop:Disconnect(); gravLoop = nil end
		if active then gravLoop = RunService.Heartbeat:Connect(function() Workspace.Gravity = DefaultStats.Gravity / currentGravLevel end) 
		else Session.StopGravity() end
	end, function(val) currentGravLevel = val end)

	local NoclipC = CreateFeatureCard(parentFrame, "No Clip Mode", 32)
	local noclipLoop
	local SetNoclip = AttachSwitch(NoclipC, false, function(active)
		if active then noclipLoop = RunService.Stepped:Connect(function() local char = LocalPlayer.Character; if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end end end) else Session.StopNoclip() end
	end)
	Session.StopNoclip = function() if noclipLoop then noclipLoop:Disconnect() end; local char = LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid"); if char and root and hum then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then if part.Name == "HumanoidRootPart" then part.CanCollide = true; part.Transparency = 1 else part.CanCollide = false end end end; local originalHip = hum.HipHeight; hum.HipHeight = 0; task.wait(); hum.HipHeight = originalHip; hum:ChangeState(Enum.HumanoidStateType.GettingUp) end end

	local InfJumpC = CreateFeatureCard(parentFrame, "Infinity Jump", 32)
	local InfJumpConn
	local SetInfJump = AttachSwitch(InfJumpC, false, function(active)
		if active then InfJumpConn = UserInputService.JumpRequest:Connect(function() local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end) else Session.StopInfJump() end
	end)
	Session.StopInfJump = function() if InfJumpConn then InfJumpConn:Disconnect() end end

	local ResetBtn = Instance.new("TextButton"); ResetBtn.Parent = parentFrame
	ResetBtn.BackgroundColor3 = Theme.Red; ResetBtn.BackgroundTransparency = 0.2
	ResetBtn.Size = UDim2.new(1, 0, 0, 35); ResetBtn.Font = Theme.FontBold
	ResetBtn.Text = "RESET DEFAULT"; ResetBtn.TextColor3 = Theme.Text; ResetBtn.TextSize = 12
	Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 8)
	local RS = Instance.new("UIStroke"); RS.Parent = ResetBtn; RS.Color = Theme.Red; RS.Thickness = 1; RS.Transparency = 0.5
	
	Session.ResetAll = function()
		FlyCtrl.Reset(); SpeedCtrl.Reset(); JumpCtrl.Reset(); GravCtrl.Reset()
		SetNoclip(false); SetInfJump(false)
		Session.StopFly(); Session.StopWalk(); Session.StopJump(); Session.StopGravity()
		Session.StopNoclip(); Session.StopInfJump()
	end
	ResetBtn.MouseButton1Click:Connect(Session.ResetAll)
end

local function BuildTeleportTab(parentFrame)
	local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 10)
	local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)
	
	local ColorSuccess = Theme.Green; local ColorError = Theme.Red
	local selectedPlayer = nil; local isDropdownOpen = false; local statusTimer = nil; 
	local ActiveConnections = {} 
	
	local function ClearConnections()
		for _, conn in pairs(ActiveConnections) do if conn then conn:Disconnect() end end
		table.clear(ActiveConnections)
	end

	local TpCard = CreateCard(parentFrame, UDim2.new(1, 0, 0, 150)) 
	TpCard.ClipsDescendants = false; TpCard.LayoutOrder = 1; TpCard.ZIndex = 10 

	local Title = Instance.new("TextLabel"); Title.Parent = TpCard; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 15, 0, 10); Title.Size = UDim2.new(0.6, 0, 0, 15); Title.Font = Theme.FontBold; Title.Text = "Player Teleport & Follow"; Title.TextColor3 = Theme.Text; Title.TextSize = 12; Title.TextXAlignment = Enum.TextXAlignment.Left
	local StatusLbl = Instance.new("TextLabel"); StatusLbl.Parent = TpCard; StatusLbl.BackgroundTransparency = 1; StatusLbl.AnchorPoint = Vector2.new(0, 0); StatusLbl.Position = UDim2.new(1, -95, 0, 10); StatusLbl.Size = UDim2.new(0, 80, 0, 15); StatusLbl.Font = Theme.FontBold; StatusLbl.Text = ""; StatusLbl.TextColor3 = Theme.TextDim; StatusLbl.TextSize = 10; StatusLbl.TextXAlignment = Enum.TextXAlignment.Left 
	local function ShowStatus(text, color) StatusLbl.Text = "(!) " .. text; StatusLbl.TextColor3 = color or Theme.Text; if statusTimer then task.cancel(statusTimer) end; statusTimer = task.delay(3, function() if StatusLbl then StatusLbl.Text = ""; StatusLbl.TextColor3 = Theme.TextDim end statusTimer = nil end) end

	local DropContainer = Instance.new("Frame"); DropContainer.Parent = TpCard; DropContainer.BackgroundTransparency = 1; DropContainer.Position = UDim2.new(0, 15, 0, 35); DropContainer.Size = UDim2.new(1, -30, 0, 30); DropContainer.ZIndex = 20
	
	local DropBtn = Instance.new("TextButton"); DropBtn.Parent = DropContainer; DropBtn.BackgroundColor3 = Theme.Main; DropBtn.Size = UDim2.new(1, -85, 1, 0); DropBtn.Font = Theme.FontMain; DropBtn.Text = "  Select Player..."; DropBtn.TextColor3 = Theme.TextDim; DropBtn.TextSize = 11; DropBtn.TextXAlignment = Enum.TextXAlignment.Left; DropBtn.AutoButtonColor = false; DropBtn.BorderSizePixel = 0; DropBtn.ZIndex = 20; Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 6)
	local RefreshBtn = Instance.new("TextButton"); RefreshBtn.Parent = DropContainer; RefreshBtn.BackgroundColor3 = Theme.Main; RefreshBtn.Position = UDim2.new(1, -80, 0, 0); RefreshBtn.Size = UDim2.new(0, 80, 1, 0); RefreshBtn.ZIndex = 20; RefreshBtn.Font = Theme.FontBold; RefreshBtn.Text = "REFRESH"; RefreshBtn.TextColor3 = Theme.Green; RefreshBtn.TextSize = 10; Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 6)
	local RS = Instance.new("UIStroke"); RS.Parent = RefreshBtn; RS.Color = Theme.Green; RS.Thickness = 1; RS.Transparency = 0.3; RS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local ListFrame = Instance.new("ScrollingFrame"); ListFrame.Parent = TpCard; ListFrame.Visible = false; ListFrame.BackgroundColor3 = Theme.Sidebar; ListFrame.BorderSizePixel = 0; ListFrame.Position = UDim2.new(0, 15, 0, 68); ListFrame.Size = UDim2.new(0.90, -65, 0, 120); ListFrame.ZIndex = 30; ListFrame.ScrollBarThickness = 2; local LS = Instance.new("UIStroke"); LS.Parent = ListFrame; LS.Color = Theme.Accent; LS.Thickness = 1; local LL = Instance.new("UIListLayout"); LL.Parent = ListFrame; LL.SortOrder = Enum.SortOrder.LayoutOrder

	local function ToggleDropdown(forceClose)
		if forceClose then isDropdownOpen = false else isDropdownOpen = not isDropdownOpen end; ListFrame.Visible = isDropdownOpen; if ActiveConnections["Dropdown"] then ActiveConnections["Dropdown"]:Disconnect() end
		if isDropdownOpen then ActiveConnections["Dropdown"] = UserInputService.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local mPos = Vector2.new(input.Position.X, input.Position.Y); local function isInRect(obj) local pos, size = obj.AbsolutePosition, obj.AbsoluteSize; return mPos.X >= pos.X and mPos.X <= pos.X + size.X and mPos.Y >= pos.Y and mPos.Y <= pos.Y + size.Y end; if not isInRect(ListFrame) and not isInRect(DropBtn) then ToggleDropdown(true) end end end) end
	end
	
	local function RefreshList()
		for _, v in pairs(ListFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				local PBtn = Instance.new("TextButton"); PBtn.Parent = ListFrame; PBtn.BackgroundColor3 = Theme.Main; PBtn.Size = UDim2.new(1, 0, 0, 25); PBtn.Font = Theme.FontMain; PBtn.TextSize = 11; PBtn.TextXAlignment = Enum.TextXAlignment.Left; PBtn.AutoButtonColor = false; PBtn.ZIndex = 31
				local labelText = "  " .. p.DisplayName .. " (@" .. p.Name .. ")"; PBtn.Text = labelText; PBtn.TextColor3 = Theme.TextDim
				PBtn.MouseButton1Click:Connect(function() selectedPlayer = p; DropBtn.Text = labelText; DropBtn.TextColor3 = Theme.Text; ToggleDropdown(true) end)
			end
		end
		ListFrame.CanvasSize = UDim2.new(0, 0, 0, LL.AbsoluteContentSize.Y)
	end
	
	DropBtn.MouseButton1Click:Connect(function() ToggleDropdown() end)
	RefreshBtn.MouseButton1Click:Connect(function() RefreshBtn.Text = "WAIT..."; RefreshList(); task.wait(0.2); ShowStatus("Refreshed", ColorSuccess); RefreshBtn.Text = "DONE"; task.wait(0.5); RefreshBtn.Text = "REFRESH" end)

	local BtnContainer = Instance.new("Frame"); BtnContainer.Parent = TpCard; BtnContainer.BackgroundTransparency = 1; BtnContainer.Position = UDim2.new(0, 15, 0, 75); BtnContainer.Size = UDim2.new(1, -30, 0, 60)
	local SpectateBtn, SS = CreateNeonBtn(BtnContainer, "SPECTATE", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 0, 28))
	local TeleportBtn, TS = CreateNeonBtn(BtnContainer, "TELEPORT", UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 0, 28))
	local FollowBtn, FS = CreateNeonBtn(BtnContainer, "SMART FOLLOW (WALK)", UDim2.new(0, 0, 0, 35), UDim2.new(1, 0, 0, 28))

	local function StopAllModes()
		ClearConnections()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid end
		SetButtonStyle(SpectateBtn, SS, false, nil, "SPECTATE"); SetButtonStyle(FollowBtn, FS, false, nil, "SMART FOLLOW (WALK)") 
		local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then char.Humanoid:MoveTo(char.HumanoidRootPart.Position) end
	end

	SpectateBtn.MouseButton1Click:Connect(function()
		if ActiveConnections["Spectate"] then StopAllModes() else
			StopAllModes(); if not selectedPlayer then ShowStatus("Select Player", ColorError); return end
			local target = Players:FindFirstChild(selectedPlayer.Name)
			if target then
				SetButtonStyle(SpectateBtn, SS, true, "STOP VIEW", "SPECTATE"); ShowStatus("Spectating", ColorSuccess)
				ActiveConnections["Spectate"] = RunService.RenderStepped:Connect(function() if not target or not target.Parent then StopAllModes(); ShowStatus("Player Left", ColorError); return end; if target.Character and target.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = target.Character.Humanoid end end)
			else ShowStatus("Player Left", ColorError) end
		end
	end)

	TeleportBtn.MouseButton1Click:Connect(function()
		if not selectedPlayer then ShowStatus("Select Player", ColorError); return end
		local target = Players:FindFirstChild(selectedPlayer.Name); if not target then ShowStatus("Player Left", ColorError); return end
		local tChar = target.Character; local lChar = LocalPlayer.Character
		TeleportBtn.Text = "TP..."; task.wait(0.1)
		if tChar and tChar:FindFirstChild("HumanoidRootPart") and lChar and lChar:FindFirstChild("HumanoidRootPart") then lChar.HumanoidRootPart.CFrame = tChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3); ShowStatus("Teleported", ColorSuccess); TeleportBtn.Text = "DONE" else ShowStatus("Unreachable", ColorError); TeleportBtn.Text = "FAIL" end
		task.delay(0.5, function() TeleportBtn.Text = "TELEPORT" end)
	end)

	FollowBtn.MouseButton1Click:Connect(function()
		if ActiveConnections["Follow"] then StopAllModes() else
			StopAllModes(); if not selectedPlayer then ShowStatus("Select Player", ColorError); return end
			SetButtonStyle(FollowBtn, FS, true, "STOP FOLLOWING", "SMART FOLLOW (WALK)"); ShowStatus("Following", ColorSuccess)
			ActiveConnections["Follow"] = RunService.Heartbeat:Connect(function(deltaTime)
				local target = Players:FindFirstChild(selectedPlayer.Name); local myChar = LocalPlayer.Character
				if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then StopAllModes(); ShowStatus("Player Left", ColorError); return end
				if not myChar or not myChar:FindFirstChild("HumanoidRootPart") or not myChar:FindFirstChild("Humanoid") then return end
				local myRoot = myChar.HumanoidRootPart; local targetRoot = target.Character.HumanoidRootPart; local hum = myChar.Humanoid; local tHum = target.Character:FindFirstChild("Humanoid")
				local dist = (myRoot.Position - targetRoot.Position).Magnitude
				if dist > 150 then myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 2, 3); return end
				if dist > 8 then local predictedPos = targetRoot.Position + (targetRoot.AssemblyLinearVelocity * 0.1); hum:MoveTo(predictedPos); if (targetRoot.Position.Y > myRoot.Position.Y + 3) and dist < 15 then hum.Jump = true end; if tHum and tHum.Jump then hum.Jump = true end elseif dist < 5 then hum:MoveTo(myRoot.Position) end
			end)
		end
	end)

	local ToolInstance = nil
	local ToolRespawnConn = nil 
	
	-- Tool Card
	local ToolCard = CreateFeatureCard(parentFrame, "Teleport Tool (Equip to Click)", 32)
	if ToolCard.LayoutOrder then ToolCard.LayoutOrder = 2 end 
	
	local ToolBtn = Instance.new("TextButton"); ToolBtn.Parent = ToolCard
	ToolBtn.BackgroundColor3 = Theme.Main
	
	-- [ALIGNMENT FIXED] -15px from Right Edge
	ToolBtn.AnchorPoint = Vector2.new(1, 0.5)
	ToolBtn.Position = UDim2.new(1, -15, 0.5, 0) 
	ToolBtn.Size = UDim2.new(0, 80, 0, 20)
	
	ToolBtn.Font = Theme.FontBold; ToolBtn.TextSize = 9
	Instance.new("UICorner", ToolBtn).CornerRadius = UDim.new(0, 4)
	local TS = Instance.new("UIStroke"); TS.Parent = ToolBtn; TS.Thickness = 1.2; TS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	
	local function UpdateToolVisuals()
		local char = LocalPlayer.Character; local backpack = LocalPlayer.Backpack
		local found = (char and char:FindFirstChild("Teleport [CLICK]")) or (backpack and backpack:FindFirstChild("Teleport [CLICK]"))
		
		if found then
			ToolBtn.Text = "REMOVE TOOL"; ToolBtn.TextColor3 = Theme.Red; TS.Color = Theme.Red
		else
			ToolBtn.Text = "GIVE TOOL"; ToolBtn.TextColor3 = Theme.Accent; TS.Color = Theme.Accent
			ToolInstance = nil 
		end
	end
	
	ToolBtn.MouseButton1Click:Connect(function()
		local char = LocalPlayer.Character; local backpack = LocalPlayer.Backpack
		local existing = (char and char:FindFirstChild("Teleport [CLICK]")) or (backpack and backpack:FindFirstChild("Teleport [CLICK]"))
		
		if existing then
			existing:Destroy()
			if ToolInstance then ToolInstance:Destroy(); ToolInstance = nil end
			ShowStatus("Unequipped", ColorError)
		else
			ToolInstance = Instance.new("Tool"); ToolInstance.Name = "Teleport [CLICK]"
			ToolInstance.RequiresHandle = false
			ToolInstance.TextureId = "rbxassetid://7368482438"
			ToolInstance.Parent = LocalPlayer.Backpack
			
			ToolInstance.Activated:Connect(function()
				local mouse = LocalPlayer:GetMouse(); local targetPos = mouse.Hit; local c = LocalPlayer.Character
				if c and c:FindFirstChild("HumanoidRootPart") and targetPos then
					c.HumanoidRootPart.CFrame = CFrame.new(targetPos.X, targetPos.Y + 3, targetPos.Z)
					local marker = Instance.new("Part"); marker.Anchored = true; marker.CanCollide = false; marker.Transparency = 0.5
					marker.Color = Theme.Accent; marker.Material = Enum.Material.Neon; marker.Size = Vector3.new(1, 50, 1)
					marker.Position = targetPos.Position; marker.Parent = workspace
					game:GetService("Debris"):AddItem(marker, 0.5)
				end
			end)
			
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
				LocalPlayer.Character.Humanoid:EquipTool(ToolInstance) 
			end
			ShowStatus("Tool Ready", ColorSuccess)
		end
		UpdateToolVisuals()
	end)

	LocalPlayer.CharacterRemoving:Connect(function()
		ToolInstance = nil
		task.delay(1, UpdateToolVisuals) 
	end)
	
	UpdateToolVisuals()
	RefreshList()
end

local function BuildToolsTab(parentFrame)
	local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 10)
	local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)

	-- [1] CONFIG & VARS
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local ToolsConfig = { Speed = { Active = false, Value = hum.WalkSpeed }, TPWalk = { Active = false, Value = 0.5 }, Jump = { Active = false, Value = 50, Mode = "Mobile" }, StateForce = { Active = false } }

	-- [2] HANDLER JUMP (Logic Tetap)
	local JumpButtonGUI, PCJumpConn, IsHoldingJump = nil, nil, false
	local function SetNativeJumpVisible(visible) pcall(function() LocalPlayer.PlayerGui.TouchGui.TouchControlFrame.JumpButton.Visible = visible end) end
	local function SetMobileMode(active)
		if active then
			if JumpButtonGUI then JumpButtonGUI:Destroy() end
			JumpButtonGUI = Instance.new("ImageButton"); JumpButtonGUI.Name = "NeeR_JumpReplica"; JumpButtonGUI.Parent = ScreenGui; JumpButtonGUI.BackgroundTransparency = 1; JumpButtonGUI.Size = UDim2.new(0, 70, 0, 70); JumpButtonGUI.ZIndex = 999; JumpButtonGUI.AnchorPoint = Vector2.new(1, 1); JumpButtonGUI.Position = UDim2.new(1, -25, 1, -20); JumpButtonGUI.Image = "rbxasset://textures/ui/Input/TouchControlsSheetV2.png"; JumpButtonGUI.ImageRectOffset = Vector2.new(1, 146); JumpButtonGUI.ImageRectSize = Vector2.new(144, 144); JumpButtonGUI.ImageTransparency = 0.5
			JumpButtonGUI.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then IsHoldingJump = true; JumpButtonGUI.ImageRectOffset = Vector2.new(146, 146); JumpButtonGUI.ImageTransparency = 0.2; task.spawn(function() while IsHoldingJump and JumpButtonGUI do local c=LocalPlayer.Character; local r=c and c:FindFirstChild("HumanoidRootPart"); local h=c and c:FindFirstChild("Humanoid"); if r and h then local hit=workspace:Raycast(r.Position, Vector3.new(0,-3.5,0), RaycastParams.new{FilterDescendantsInstances={c}}); if hit then r.AssemblyLinearVelocity=Vector3.new(r.AssemblyLinearVelocity.X, ToolsConfig.Jump.Value, r.AssemblyLinearVelocity.Z); h:ChangeState(Enum.HumanoidStateType.Jumping) end end; RunService.Heartbeat:Wait() end end) end end)
			JumpButtonGUI.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then IsHoldingJump=false; JumpButtonGUI.ImageRectOffset=Vector2.new(1,146); JumpButtonGUI.ImageTransparency=0.5 end end)
		else if JumpButtonGUI then JumpButtonGUI:Destroy(); JumpButtonGUI=nil end; IsHoldingJump=false end
	end
	local function SetPCMode(active) if active then if PCJumpConn then PCJumpConn:Disconnect() end; PCJumpConn=UserInputService.InputBegan:Connect(function(i,g) if not g and i.KeyCode==Enum.KeyCode.Space then local c=LocalPlayer.Character; local r=c and c:FindFirstChild("HumanoidRootPart"); local h=c and c:FindFirstChild("Humanoid"); if r and h then local hit=workspace:Raycast(r.Position,Vector3.new(0,-3.5,0),RaycastParams.new{FilterDescendantsInstances={c}}); if hit then r.AssemblyLinearVelocity=Vector3.new(r.AssemblyLinearVelocity.X, ToolsConfig.Jump.Value, r.AssemblyLinearVelocity.Z); h:ChangeState(Enum.HumanoidStateType.Jumping) end end end end) else if PCJumpConn then PCJumpConn:Disconnect() end end end
	local function UpdateJumpState() SetMobileMode(false); SetPCMode(false); if ToolsConfig.Jump.Active then if ToolsConfig.Jump.Mode=="Mobile" then SetMobileMode(true) else SetPCMode(true) end else local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid"); if h then h.JumpPower=DefaultStats.JumpPower; h.UseJumpPower=true; if DefaultStats.JumpPower>0 then SetNativeJumpVisible(true) end end end end

	-- [3] UI BUILDER: FORCE MOVEMENT
	local ForceSection = CreateExpandableSection(parentFrame, "Force Movement (Anti-Kick)")
	
	-- [INFO LABEL - ADDED HERE]
	local InfoLbl = Instance.new("TextLabel"); InfoLbl.Parent = ForceSection
	InfoLbl.BackgroundTransparency = 1
	InfoLbl.Size = UDim2.new(1, 0, 0, 20)
	InfoLbl.Font = Theme.FontMain
	InfoLbl.Text = "*Note: Use this if the map restricts WalkSpeed or JumpPower."
	InfoLbl.TextColor3 = Color3.fromRGB(150, 150, 150) -- Sedikit lebih gelap dari text biasa
	InfoLbl.TextSize = 10
	InfoLbl.TextXAlignment = Enum.TextXAlignment.Left
	InfoLbl.TextWrapped = true

	-- DASHBOARD MONITOR
	local DashCard = CreateCard(ForceSection, UDim2.new(1, 0, 0, 50))
	local DashLayout = Instance.new("UIListLayout"); DashLayout.Parent = DashCard; DashLayout.FillDirection = Enum.FillDirection.Horizontal; DashLayout.Padding = UDim.new(0, 5); DashLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; DashLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	
	local function CreateStatBox(label, defaultVal)
		local Box = Instance.new("Frame"); Box.Parent = DashCard; Box.BackgroundColor3 = Theme.Sidebar; Box.BackgroundTransparency = 0; Box.Size = UDim2.new(0.3, 0, 0.8, 0); Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
		local T = Instance.new("TextLabel"); T.Parent = Box; T.Text = label; T.Size = UDim2.new(1, 0, 0.4, 0); T.BackgroundTransparency = 1; T.TextColor3 = Theme.TextDim; T.Font = Theme.FontMain; T.TextSize = 9
		local V = Instance.new("TextLabel"); V.Parent = Box; V.Text = defaultVal; V.Size = UDim2.new(1, 0, 0.6, 0); V.Position = UDim2.new(0, 0, 0.4, 0); V.BackgroundTransparency = 1; V.TextColor3 = Theme.Accent; V.Font = Theme.FontBold; V.TextSize = 12
		return V, Box
	end
	local SpeedVal, SpeedBox = CreateStatBox("REAL SPEED", "0")
	local JumpVal, JumpBox = CreateStatBox("REAL JUMP", "0")
	local StateBox = Instance.new("TextButton"); StateBox.Parent = DashCard; StateBox.BackgroundColor3 = Theme.Sidebar; StateBox.Size = UDim2.new(0.3, 0, 0.8, 0); StateBox.Text = ""; StateBox.AutoButtonColor = false
	Instance.new("UICorner", StateBox).CornerRadius = UDim.new(0, 6)
	local ST = Instance.new("TextLabel"); ST.Parent = StateBox; ST.Text = "JUMP STATE"; ST.Size = UDim2.new(1, 0, 0.4, 0); ST.BackgroundTransparency = 1; ST.TextColor3 = Theme.TextDim; ST.Font = Theme.FontMain; ST.TextSize = 9
	local SV = Instance.new("TextLabel"); SV.Parent = StateBox; SV.Text = "ACTIVE"; SV.Size = UDim2.new(1, 0, 0.6, 0); SV.Position = UDim2.new(0, 0, 0.4, 0); SV.BackgroundTransparency = 1; SV.TextColor3 = Theme.Green; SV.Font = Theme.FontBold; SV.TextSize = 12
	StateBox.MouseButton1Click:Connect(function() if SV.Text == "DISABLED (FIX)" then ToolsConfig.StateForce.Active = true; SV.Text = "FIXING..."; task.wait(0.5) end end)

	local ForceSpeedCtrl, TPWalkCtrl
	
	ForceSpeedCtrl = CreateStepperCard(ForceSection, "Force Speed", ToolsConfig.Speed.Value, 1, 500, 5, function(active)
		ToolsConfig.Speed.Active = active
		Session.OverrideSpeed = active 
		if active and TPWalkCtrl then TPWalkCtrl.Reset() end
		if not active then local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid"); if h then h.WalkSpeed = DefaultStats.WalkSpeed end end
	end, function(val) ToolsConfig.Speed.Value = val end)
	
	TPWalkCtrl = CreateStepperCard(ForceSection, "TP Walk (Bypass)", 0.5, 0.1, 5.0, 0.1, function(active)
		ToolsConfig.TPWalk.Active = active
		if active and ForceSpeedCtrl then ForceSpeedCtrl.Reset() end
	end, function(val) ToolsConfig.TPWalk.Value = val end)
	
	CreateStepperCard(ForceSection, "Force Jump", ToolsConfig.Jump.Value, 0, 500, 10, function(active)
		ToolsConfig.Jump.Active = active
		Session.OverrideJump = active
		UpdateJumpState()
	end, function(val) ToolsConfig.Jump.Value = val end)

	local ModeCard = CreateFeatureCard(ForceSection, "Jump Mode Selector", 32)
	local MobBtn = Instance.new("TextButton"); MobBtn.Parent = ModeCard; MobBtn.BackgroundColor3 = Theme.Accent; MobBtn.Position = UDim2.new(1, -155, 0.5, -9); MobBtn.Size = UDim2.new(0, 70, 0, 18); MobBtn.Text = "MOBILE"; MobBtn.Font = Theme.FontBold; MobBtn.TextColor3 = Theme.Main; MobBtn.TextSize = 8; Instance.new("UICorner", MobBtn).CornerRadius = UDim.new(0, 4)
	local PCBtn = Instance.new("TextButton"); PCBtn.Parent = ModeCard; PCBtn.BackgroundColor3 = Theme.Sidebar; PCBtn.Position = UDim2.new(1, -80, 0.5, -9); PCBtn.Size = UDim2.new(0, 70, 0, 18); PCBtn.Text = "PC/KEY"; PCBtn.Font = Theme.FontBold; PCBtn.TextColor3 = Theme.TextDim; PCBtn.TextSize = 8; Instance.new("UICorner", PCBtn).CornerRadius = UDim.new(0, 4)
	local function UpdateModeVisuals()
		if ToolsConfig.Jump.Mode == "Mobile" then MobBtn.BackgroundColor3 = Theme.Accent; MobBtn.TextColor3 = Theme.Main; PCBtn.BackgroundColor3 = Theme.Sidebar; PCBtn.TextColor3 = Theme.TextDim
		else MobBtn.BackgroundColor3 = Theme.Sidebar; MobBtn.TextColor3 = Theme.TextDim; PCBtn.BackgroundColor3 = Theme.Accent; PCBtn.TextColor3 = Theme.Main end
	end
	MobBtn.MouseButton1Click:Connect(function() ToolsConfig.Jump.Mode = "Mobile"; UpdateModeVisuals(); if ToolsConfig.Jump.Active then UpdateJumpState() end end)
	PCBtn.MouseButton1Click:Connect(function() ToolsConfig.Jump.Mode = "PC"; UpdateModeVisuals(); if ToolsConfig.Jump.Active then UpdateJumpState() end end)

	-- [4] UI BUILDER: ESP & X-RAY (VISUAL ASSIST)
	local ESP_Section = CreateExpandableSection(parentFrame, "Visual Assistance")
	local HL_Conn, Name_Conn, HP_Conn = {}, {}, {}

	local function ToggleESP(isActive, storageTable, onAdd, onRemove)
		if isActive then
			local function Setup(plr) if plr == LocalPlayer then return end; if plr.Character then onAdd(plr.Character, plr) end; local c = plr.CharacterAdded:Connect(function(ch) ch:WaitForChild("HumanoidRootPart", 5); onAdd(ch, plr) end); table.insert(storageTable, c) end
			for _, p in pairs(Players:GetPlayers()) do Setup(p) end; table.insert(storageTable, Players.PlayerAdded:Connect(Setup))
		else for _, c in pairs(storageTable) do c:Disconnect() end; table.clear(storageTable); for _, p in pairs(Players:GetPlayers()) do if p.Character then onRemove(p.Character) end end end
	end

	-- 1. CHAMS
	local C1 = CreateFeatureCard(ESP_Section, "Visual Chams (Highlight)", 32)
	AttachSwitch(C1, false, function(a) ToggleESP(a, HL_Conn, function(c) if c:FindFirstChild("NeeR_HL") then c.NeeR_HL:Destroy() end; local h=Instance.new("Highlight",c); h.Name="NeeR_HL"; h.FillColor=Theme.Red; h.OutlineColor=Color3.new(1,1,1); h.FillTransparency=0.5 end, function(c) if c:FindFirstChild("NeeR_HL") then c.NeeR_HL:Destroy() end end) end)
	
	-- 2. PLAYER NAMES (FIXED OFFSET)
	local C2 = CreateFeatureCard(ESP_Section, "Player Names", 32)
	AttachSwitch(C2, false, function(a) ToggleESP(a, Name_Conn, function(c,p) 
		if not c:FindFirstChild("Head") then return end
		if c:FindFirstChild("NeeR_Nm") then c.NeeR_Nm:Destroy() end
		local b=Instance.new("BillboardGui",c); b.Name="NeeR_Nm"; b.Adornee=c.Head
		b.Size=UDim2.new(0,100,0,20); b.AlwaysOnTop=true
		-- [FIX] Naikkan offset ke 6.0 agar tidak menimpa Healthbar
		b.StudsOffset=Vector3.new(0, 6.0, 0) 
		local t=Instance.new("TextLabel",b); t.Size=UDim2.new(1,0,1,0); t.BackgroundTransparency=1; t.Text=p.DisplayName; t.TextColor3=Color3.new(1,1,1); t.Font=Theme.FontBold; t.TextSize=12; t.TextStrokeTransparency=0 
	end, function(c) if c:FindFirstChild("NeeR_Nm") then c.NeeR_Nm:Destroy() end end) end)
	
	-- 3. HEALTH BAR
	local C3 = CreateFeatureCard(ESP_Section, "Health Bar", 32)
	AttachSwitch(C3, false, function(a) ToggleESP(a, HP_Conn, function(c) 
		if not c:FindFirstChild("Head") then return end
		if c:FindFirstChild("NeeR_HP") then c.NeeR_HP:Destroy() end
		local b=Instance.new("BillboardGui",c); b.Name="NeeR_HP"; b.Adornee=c.Head
		b.Size=UDim2.new(0,40,0,4); b.AlwaysOnTop=true
		-- Offset standar Healthbar
		b.StudsOffset=Vector3.new(0, 3.5, 0) 
		local f=Instance.new("Frame",b); f.Size=UDim2.new(1,0,1,0); f.BackgroundColor3=Color3.new(0,0,0); local fill=Instance.new("Frame",f); fill.Size=UDim2.new(1,0,1,0); fill.BackgroundColor3=Theme.Green; local h=c:FindFirstChild("Humanoid"); if h then local function U() local p=math.clamp(h.Health/h.MaxHealth,0,1); TweenService:Create(fill,TweenInfo.new(0.2),{Size=UDim2.new(p,0,1,0)}):Play(); fill.BackgroundColor3=p<0.3 and Theme.Red or Theme.Green end; U(); h.HealthChanged:Connect(U) end 
	end, function(c) if c:FindFirstChild("NeeR_HP") then c.NeeR_HP:Destroy() end end) end)

	-- 4. X-RAY
	local xr_op, xr_cache, xr_conn = 0.5, {}, nil
	local function DoXR(v) if v:IsA("BasePart") and not v:IsA("Terrain") then local h=v.Parent:FindFirstChild("Humanoid") or v.Parent.Parent:FindFirstChild("Humanoid"); if not h and v.Transparency<0.9 then if not xr_cache[v] then xr_cache[v]=v.Transparency end; v.Transparency=xr_op end end end
	
	CreateHybridCard(ESP_Section, "Wall X-Ray (Auto Detect)", function(active)
		if active then for _,v in pairs(workspace:GetDescendants()) do DoXR(v) end; xr_conn=workspace.DescendantAdded:Connect(DoXR)
		else if xr_conn then xr_conn:Disconnect() end; for p,t in pairs(xr_cache) do if p.Parent then p.Transparency=t end end; table.clear(xr_cache) end
	end, 0.1, 0.9, 0.5, function(v) xr_op=v; if next(xr_cache) then for p,_ in pairs(xr_cache) do if p.Parent then p.Transparency=xr_op end end end end, "")

	-- ENGINE MONITOR
	local ToolLoop
	local function StartToolEngine()
		if ToolLoop then return end
		
		local LastUIUpdate = 0 -- Timer untuk membatasi update teks
		
		ToolLoop = RunService.RenderStepped:Connect(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChild("Humanoid")
			local root = char and char:FindFirstChild("HumanoidRootPart")
			
			if hum and root then
				-- [A] LOGIKA FISIK (Wajib setiap frame agar kuat menahan override server)
				if ToolsConfig.Speed.Active and not ToolsConfig.TPWalk.Active and hum.WalkSpeed ~= ToolsConfig.Speed.Value then 
					hum.WalkSpeed = ToolsConfig.Speed.Value 
				end
				
				if ToolsConfig.TPWalk.Active and hum.MoveDirection.Magnitude > 0 then 
					root.CFrame = root.CFrame + (hum.MoveDirection * (ToolsConfig.TPWalk.Value * 0.2)) 
				end
				
				if ToolsConfig.Jump.Active then 
					if hum.JumpPower ~= ToolsConfig.Jump.Value then hum.JumpPower = ToolsConfig.Jump.Value end 
					if not hum.UseJumpPower then hum.UseJumpPower = true end 
					if ToolsConfig.Jump.Mode == "Mobile" then SetNativeJumpVisible(false) end
				end
				
				if ToolsConfig.StateForce.Active then 
					hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) 
				end

				-- [B] LOGIKA UI (Dibatasi/Throttled 0.1 detik)
				-- Hanya update teks jika sudah 0.1 detik berlalu
				if tick() - LastUIUpdate >= 0.1 then
					LastUIUpdate = tick()
					
					-- Update Angka
					SpeedVal.Text = tostring(math.floor(hum.WalkSpeed))
					JumpVal.Text = tostring(math.floor(hum.JumpPower))
					
					-- Update Status Jump
					local isJumpEnabled = hum:GetStateEnabled(Enum.HumanoidStateType.Jumping)
					if isJumpEnabled then 
						SV.Text = "ACTIVE"; SV.TextColor3 = Theme.Green
						StateBox.AutoButtonColor = false; ToolsConfig.StateForce.Active = false 
					else 
						SV.Text = "DISABLED (FIX)"; SV.TextColor3 = Theme.Red
						StateBox.AutoButtonColor = true 
					end
				end
			end
		end)
	end
	StartToolEngine()
end

local function BuildVisualsTab(parentFrame)
	local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 8)
	local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 10); Padding.PaddingLeft = UDim.new(0, 10); Padding.PaddingRight = UDim.new(0, 10)

	-- [GROUP 1] CAMERA ADJUSTMENTS
	local CamAdj_Sec = CreateExpandableSection(parentFrame, "View Customization")

	local CS2 = CreateFeatureCard(CamAdj_Sec, "Camera Offsets", 95)
	local Grid = Instance.new("Frame"); Grid.Parent = CS2; Grid.BackgroundTransparency = 1; Grid.Position = UDim2.new(0, 10, 0, 32); Grid.Size = UDim2.new(1, -20, 0, 50)
	local GL = Instance.new("UIGridLayout"); GL.Parent = Grid; GL.CellSize = UDim2.new(0.48, 0, 1, 0); GL.CellPadding = UDim2.new(0.04, 0, 0, 0); GL.SortOrder = Enum.SortOrder.LayoutOrder
	local cx, cy = 0, 0; local function UpdCam() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.CameraOffset = Vector3.new(cx, cy, 0) end end
	LocalPlayer.CharacterAdded:Connect(function() task.wait(1); UpdCam() end)
	
	-- Menggunakan Helper Global
	CreatePerfectMiniSlider(Grid, "Horizontal (X)", function(v) cx=v; UpdCam() end)
	CreatePerfectMiniSlider(Grid, "Vertical (Y)", function(v) cy=v; UpdCam() end)

	local CS3 = CreateFeatureCard(CamAdj_Sec, "Field of View (FOV)", 60)
	AttachSlider(CS3, 70, 120, 70, function(v) workspace.CurrentCamera.FieldOfView = v end, "")

	-- [GROUP 2] CAMERA UTILITIES
	local CamUtil_Sec = CreateExpandableSection(parentFrame, "Camera Mechanics")
	local CS1 = CreateFeatureCard(CamUtil_Sec, "Force Shift Lock", 32)
	local sl_conn = nil
	AttachSwitch(CS1, false, function(active)
		if active then sl_conn = RunService.RenderStepped:Connect(function() UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter; local c = LocalPlayer.Character; if c and c:FindFirstChild("HumanoidRootPart") then local r = c.HumanoidRootPart; local cam = workspace.CurrentCamera.CFrame; r.CFrame = CFrame.new(r.Position, r.Position + Vector3.new(cam.LookVector.X, 0, cam.LookVector.Z)) end end)
		else if sl_conn then sl_conn:Disconnect() end; UserInputService.MouseBehavior = Enum.MouseBehavior.Default end
	end)
	local CS4 = CreateFeatureCard(CamUtil_Sec, "Unlock Max Zoom", 32); AttachSwitch(CS4, false, function(a) LocalPlayer.CameraMaxZoomDistance = a and 100000 or 128 end)
	local CS5 = CreateFeatureCard(CamUtil_Sec, "Camera Noclip", 32); AttachSwitch(CS5, false, function(a) LocalPlayer.DevCameraOcclusionMode = a and Enum.DevCameraOcclusionMode.Invisicam or Enum.DevCameraOcclusionMode.Zoom end)

	-- [GROUP 3] ATMOSPHERE
	local Env_Sec = CreateExpandableSection(parentFrame, "Atmosphere & Lighting")
	local fVal, fLoop = 10000, nil
	CreateHybridCard(Env_Sec, "Custom Fog (Dual Engine)", function(active)
		if active then if not fLoop then fLoop = RunService.RenderStepped:Connect(function() game.Lighting.FogStart=0; game.Lighting.FogEnd=fVal; local r=math.clamp(fVal/10000,0,1); local d=(1-r)*0.55; for _,c in pairs(game.Lighting:GetChildren()) do if c:IsA("Atmosphere") then c.Density=d; c.Offset=0; c.Haze=0 end end end) end
		else if fLoop then fLoop:Disconnect(); fLoop=nil end end
	end, 100, 10000, 10000, function(v) fVal = v end, "")
	local WS4 = CreateFeatureCard(Env_Sec, "Time of Day", 60); local fb_loop; local LB = {}
	AttachSlider(WS4, 0, 24, 14, function(v) if not fb_loop then Lighting.ClockTime = v end end, "h")
	local WS1 = CreateFeatureCard(Env_Sec, "Full Brightness", 32)
	AttachSwitch(WS1, false, function(active)
		if active then LB = {B=Lighting.Brightness, C=Lighting.ClockTime, S=Lighting.GlobalShadows, O=Lighting.OutdoorAmbient}; fb_loop = RunService.RenderStepped:Connect(function() Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.GlobalShadows=false; Lighting.OutdoorAmbient=Color3.fromRGB(128,128,128) end)
		else if fb_loop then fb_loop:Disconnect() end; if LB.B then Lighting.Brightness=LB.B; Lighting.ClockTime=LB.C; Lighting.GlobalShadows=LB.S; Lighting.OutdoorAmbient=LB.O end end
	end)

	-- [GROUP 4] GRAPHICS
	local FPS_Section = CreateExpandableSection(parentFrame, "Graphics & FPS")
	local FS1 = CreateFeatureCard(FPS_Section, "No Shadows/Effects", 32)
	AttachSwitch(FS1, false, function(a) Lighting.GlobalShadows = not a; for _,v in pairs(Lighting:GetChildren()) do if v:IsA("PostEffect") then v.Enabled = not a end end end)
	CreateActionCard(FPS_Section, "Potato Mode", "RUN", Theme.Accent, function() for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0 end; if v:IsA("MeshPart") then v.TextureID = "" end end end)
	CreateActionCard(FPS_Section, "Clear Textures", "CLEAR", Theme.Accent, function() for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end end end)
end

local function BuildSettingsTab(parentFrame)
	local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 10)
	local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)
	
	local DPICard = CreateCard(parentFrame, UDim2.new(1, 0, 0, 0)); DPICard.AutomaticSize = Enum.AutomaticSize.Y
	DPICard.LayoutOrder = 1; DPICard.ZIndex = 100; DPICard.ClipsDescendants = false
	
	local DPI_InnerLayout = Instance.new("UIListLayout"); DPI_InnerLayout.Parent = DPICard; DPI_InnerLayout.SortOrder = Enum.SortOrder.LayoutOrder; DPI_InnerLayout.Padding = UDim.new(0, 5)
	local DPI_Pad = Instance.new("UIPadding"); DPI_Pad.Parent = DPICard; DPI_Pad.PaddingTop = UDim.new(0, 10); DPI_Pad.PaddingBottom = UDim.new(0, 10); DPI_Pad.PaddingLeft = UDim.new(0, 15); DPI_Pad.PaddingRight = UDim.new(0, 15)

	local SettingsLabel = Instance.new("TextLabel"); SettingsLabel.Parent = DPICard
	SettingsLabel.BackgroundTransparency = 1; SettingsLabel.Size = UDim2.new(1, 0, 0, 20)
	SettingsLabel.Font = Theme.FontBold; SettingsLabel.Text = "Interface Scale (DPI)"; SettingsLabel.TextColor3 = Theme.Text
	SettingsLabel.TextSize = 14; SettingsLabel.TextXAlignment = Enum.TextXAlignment.Left; SettingsLabel.LayoutOrder = 1
	
	local DPIBtn = Instance.new("TextButton"); DPIBtn.Parent = DPICard
	DPIBtn.BackgroundColor3 = Theme.Sidebar; DPIBtn.Size = UDim2.new(1, 0, 0, 35)
	DPIBtn.Font = Theme.FontBold; DPIBtn.Text = IsMobile and "  Size: 75% (Medium)" or "  Size: 100% (Default)"; DPIBtn.TextColor3 = Theme.TextDim
	DPIBtn.TextSize = 12; DPIBtn.TextXAlignment = Enum.TextXAlignment.Left; DPIBtn.AutoButtonColor = false; DPIBtn.ZIndex = 101; DPIBtn.LayoutOrder = 2
	Instance.new("UICorner", DPIBtn).CornerRadius = UDim.new(0, 6)
	local DPIB_S = Instance.new("UIStroke"); DPIB_S.Parent = DPIBtn; DPIB_S.Color = Theme.Separator; DPIB_S.Thickness = 1
	
	local DPIFrame = Instance.new("Frame"); DPIFrame.Parent = DPICard
	DPIFrame.BackgroundColor3 = Theme.Main; DPIFrame.Size = UDim2.new(1, 0, 0, 0)
	DPIFrame.ClipsDescendants = true; DPIFrame.Visible = false; DPIFrame.ZIndex = 105; DPIFrame.LayoutOrder = 3
	Instance.new("UICorner", DPIFrame).CornerRadius = UDim.new(0, 6)
	local DPIList = Instance.new("UIListLayout"); DPIList.Parent = DPIFrame; DPIList.SortOrder = Enum.SortOrder.LayoutOrder
	
	local dpiOpen = false
	DPIBtn.MouseButton1Click:Connect(function() 
		dpiOpen = not dpiOpen
		if dpiOpen then DPIFrame.Visible = true; TweenService:Create(DPIFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 105)}):Play()
		else TweenService:Create(DPIFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play(); task.wait(0.3); if not dpiOpen then DPIFrame.Visible = false end end
	end)
	local function AddDPIOption(txt, scaleVal) local Opt = Instance.new("TextButton"); Opt.Parent = DPIFrame; Opt.BackgroundColor3 = Theme.Main; Opt.Size = UDim2.new(1, 0, 0, 35); Opt.Font = Theme.FontMain; Opt.Text = txt; Opt.TextColor3 = Theme.TextDim; Opt.TextSize = 12; Opt.AutoButtonColor = true; Opt.ZIndex = 106; Opt.MouseButton1Click:Connect(function() TweenService:Create(UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Scale = scaleVal}):Play(); DPIBtn.Text = "  Size: " .. txt; dpiOpen = false; TweenService:Create(DPIFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play(); task.wait(0.3); DPIFrame.Visible = false end) end
	AddDPIOption("100% (Default)", 1); AddDPIOption("75% (Medium)", 0.75); AddDPIOption("50% (Small)", 0.5)

	local Bench_Sec = CreateExpandableSection(parentFrame, "FPS Benchmark Tool")
	Bench_Sec.Parent.LayoutOrder = 2 -- POSISI DI BAWAH DPI
	
	local BenchCard = CreateCard(Bench_Sec, UDim2.new(1, 0, 0, 95)) 
	local B_Layout = Instance.new("UIListLayout"); B_Layout.Parent = BenchCard; B_Layout.SortOrder = Enum.SortOrder.LayoutOrder; B_Layout.Padding = UDim.new(0, 8); B_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local B_Pad = Instance.new("UIPadding"); B_Pad.Parent = BenchCard; B_Pad.PaddingTop = UDim.new(0, 10); B_Pad.PaddingBottom = UDim.new(0, 10); B_Pad.PaddingLeft = UDim.new(0, 10); B_Pad.PaddingRight = UDim.new(0, 10)

	local GridFrame = Instance.new("Frame"); GridFrame.Parent = BenchCard; GridFrame.BackgroundTransparency = 1; GridFrame.Size = UDim2.new(1, 0, 0, 35)
	local Grid = Instance.new("UIListLayout"); Grid.Parent = GridFrame; Grid.FillDirection = Enum.FillDirection.Horizontal; Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center; Grid.Padding = UDim.new(0, 6)

	local function CreateStatBox(label, defaultColor)
		local Box = Instance.new("Frame"); Box.Parent = GridFrame; Box.BackgroundColor3 = Theme.Sidebar; Box.BackgroundTransparency = 0
		Box.Size = UDim2.new(0.23, 0, 1, 0); Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
		local T = Instance.new("TextLabel"); T.Parent = Box; T.Text = label; T.Size = UDim2.new(1, 0, 0.4, 0); T.Position = UDim2.new(0, 0, 0, 2); T.BackgroundTransparency = 1; T.TextColor3 = Theme.TextDim; T.Font = Theme.FontMain; T.TextSize = 8; T.TextXAlignment = Enum.TextXAlignment.Center
		local V = Instance.new("TextLabel"); V.Parent = Box; V.Text = "-"; V.Size = UDim2.new(1, 0, 0.6, 0); V.Position = UDim2.new(0, 0, 0.4, 0); V.BackgroundTransparency = 1; V.TextColor3 = defaultColor; V.Font = Theme.FontBold; V.TextSize = 12; V.TextXAlignment = Enum.TextXAlignment.Center
		return V
	end
	
	local LiveVal = CreateStatBox("LIVE", Theme.Text)
	local AvgVal = CreateStatBox("AVG", Theme.Accent)
	local HighVal = CreateStatBox("MAX", Theme.Green)
	local LowVal = CreateStatBox("MIN", Theme.Red)

	local StartBtn = Instance.new("TextButton"); StartBtn.Parent = BenchCard
	StartBtn.Text = "START TEST (30s)"; StartBtn.BackgroundColor3 = Theme.Accent; StartBtn.TextColor3 = Theme.Main; StartBtn.Font = Theme.FontBold; StartBtn.TextSize = 11
	StartBtn.Size = UDim2.new(1, 0, 0, 32); Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 6)

	local isRunning = false
	StartBtn.MouseButton1Click:Connect(function()
		if isRunning then return end
		isRunning = true
		StartBtn.BackgroundColor3 = Theme.Sidebar; StartBtn.TextColor3 = Theme.TextDim
		local min, max, total, count = 999, 0, 0, 0; local startTime = tick(); local connection
		LiveVal.Text = "..."; AvgVal.Text = "..."; HighVal.Text = "..."; LowVal.Text = "..."
		connection = RunService.RenderStepped:Connect(function(dt)
			local fps = 1 / dt; local elapsed = tick() - startTime; local remaining = 30 - math.floor(elapsed)
			StartBtn.Text = "TESTING... " .. tostring(remaining) .. "s"
			LiveVal.Text = string.format("%.0f", fps)
			if fps >= 55 then LiveVal.TextColor3 = Theme.Green elseif fps >= 30 then LiveVal.TextColor3 = Color3.fromRGB(255, 200, 0) else LiveVal.TextColor3 = Theme.Red end
			if elapsed > 1 then
				if fps < min then min = fps; LowVal.Text = string.format("%.0f", min) end
				if fps > max then max = fps; HighVal.Text = string.format("%.0f", max) end
				total = total + fps; count = count + 1; AvgVal.Text = string.format("%.0f", total / count)
			end
			if elapsed >= 30 then
				connection:Disconnect(); isRunning = false
				StartBtn.Text = "START TEST (RESET)"; StartBtn.BackgroundColor3 = Theme.Accent; StartBtn.TextColor3 = Theme.Main
			end
		end)
	end)

	local FpsCard = CreateFeatureCard(parentFrame, "Unlock FPS Limit (Bypass 60)", 32)
	FpsCard.LayoutOrder = 3 -- POSISI DI BAWAH BENCHMARK
	AttachSwitch(FpsCard, false, function(active)
		if setfpscap then setfpscap(active and 999 or 60) end
	end)

	local RjCard = CreateFeatureCard(parentFrame, "Auto Rejoin (Kick/DC)", 32)
	RjCard.LayoutOrder = 4
	local rj_conn
	AttachSwitch(RjCard, false, function(active)
		if active then
			local PromptGui = game:GetService("CoreGui"):WaitForChild("RobloxPromptGui", 2)
			if PromptGui and PromptGui:FindFirstChild("promptOverlay") then
				rj_conn = PromptGui.promptOverlay.ChildAdded:Connect(function(child)
					if child.Name == "ErrorPrompt" then
						game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
					end
				end)
			end
		else
			if rj_conn then rj_conn:Disconnect(); rj_conn = nil end
		end
	end)

	local CpuCard = CreateFeatureCard(parentFrame, "Low CPU (Black Screen)", 32)
	CpuCard.LayoutOrder = 5
	local BlackScreenGUI = nil
	AttachSwitch(CpuCard, false, function(active)
		RunService:Set3dRenderingEnabled(not active)
		if active then
			if not BlackScreenGUI then
				BlackScreenGUI = Instance.new("ScreenGui"); BlackScreenGUI.Name = "NeeR_BlackScreen"; BlackScreenGUI.Parent = CoreGui; BlackScreenGUI.IgnoreGuiInset = true
				local BlackFrame = Instance.new("Frame"); BlackFrame.Parent = BlackScreenGUI; BlackFrame.BackgroundColor3 = Color3.new(0, 0, 0); BlackFrame.Size = UDim2.new(1, 0, 1, 0)
				local Info = Instance.new("TextLabel"); Info.Parent = BlackFrame; Info.BackgroundTransparency = 1; Info.Position = UDim2.new(0, 0, 0.9, 0); Info.Size = UDim2.new(1, 0, 0, 20); Info.Font = Theme.FontMain; Info.Text = "Rendering Disabled (Battery Saver Active)"; Info.TextColor3 = Color3.fromRGB(100, 100, 100); Info.TextSize = 12
			end
		else
			if BlackScreenGUI then BlackScreenGUI:Destroy(); BlackScreenGUI = nil end
		end
	end)

	local ExitBtn = Instance.new("TextButton"); ExitBtn.Parent = parentFrame
	ExitBtn.LayoutOrder = 10; ExitBtn.ZIndex = 1
	ExitBtn.BackgroundColor3 = Theme.Red; ExitBtn.BackgroundTransparency = 0.2
	ExitBtn.Size = UDim2.new(1, 0, 0, 35)
	ExitBtn.Font = Theme.FontBold; ExitBtn.Text = "INSTANT EXIT (FORCE CLOSE)"; ExitBtn.TextColor3 = Theme.Text; ExitBtn.TextSize = 12
	Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 8)
	local RS = Instance.new("UIStroke"); RS.Parent = ExitBtn; RS.Color = Theme.Red; RS.Thickness = 1; RS.Transparency = 0.5
	
	ExitBtn.MouseButton1Click:Connect(function() game:Shutdown() end)
end

--// [7] EKSEKUSI
Loader.Start()

task.spawn(function()
	Loader.Update("Initializing Modules...", 0.1); task.wait(1)
	Loader.Update("Loading Informations...", 0.3); local TabInfo = CreateTabBtn("Informations", true); BuildInfoTab(TabInfo); task.wait(0.4)
	Loader.Update("Loading Movement...", 0.5); local TabMovement = CreateTabBtn("Movement", false); BuildMovementTab(TabMovement); task.wait(0.4)
	Loader.Update("Loading Teleports...", 0.6); local TabTeleports = CreateTabBtn("Teleports", false); BuildTeleportTab(TabTeleports); task.wait(0.3)
	Loader.Update("Loading Tools...", 0.7); local TabTools = CreateTabBtn("Tools", false); BuildToolsTab(TabTools); task.wait(0.4)
	Loader.Update("Loading Visuals...", 0.8); local TabVisuals = CreateTabBtn("Visuals", false); BuildVisualsTab(TabVisuals); task.wait(0.3)
	Loader.Update("Loading Settings...", 0.9); local TabSettings = CreateTabBtn("Settings", false); BuildSettingsTab(TabSettings); task.wait(0.3)
	
	Loader.Finish(function()
		MainFrame.Visible = true
		MainFrame.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = FinalSize,
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}):Play()
	end)
end)

local function ToggleAnimation()
	if IsOpen then
		IsOpen = false
		TweenService:Create(MainFrame, TweenInfo.new(AnimationSpeed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), Position = ToggleBtn.Position, BackgroundTransparency = 1}):Play()
		for _, v in pairs(MainFrame:GetChildren()) do if v:IsA("GuiObject") and v ~= MainCorner and v ~= UIScale and v ~= MainStroke then v.Visible = false end end
	else
		IsOpen = true
		for _, v in pairs(MainFrame:GetChildren()) do if v:IsA("GuiObject") then v.Visible = true end end
		MainFrame.Position = ToggleBtn.Position
		MainFrame.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(MainFrame, TweenInfo.new(AnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = FinalSize, Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = Theme.Transp}):Play()
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed) if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then ToggleAnimation() end end)
MinBtn.MouseButton1Click:Connect(ToggleAnimation); ToggleBtn.MouseButton1Click:Connect(ToggleAnimation)
