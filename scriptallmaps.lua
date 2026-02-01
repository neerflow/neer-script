local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

--// [1] TEMA & PENGATURAN
local Theme = {
	Main = Color3.fromRGB(20, 25, 35),
	Sidebar = Color3.fromRGB(22, 26, 38),
	ActiveTab = Color3.fromRGB(45, 55, 75),
	Accent = Color3.fromRGB(137, 207, 240), -- Baby Blue
	Text = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(160, 180, 190),
	Separator = Color3.fromRGB(50, 60, 80),
	Transp = 0.15,
	Red = Color3.fromRGB(255, 80, 80),
	Green = Color3.fromRGB(85, 255, 127),
	Pressed = Color3.fromRGB(10, 10, 12), -- Dark Neon Effect
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

--// [3] SESSION MANAGER
--// [3] SESSION MANAGER
-- Menambahkan 'Gravity' ke tabel penyimpanan default
local DefaultStats = { WalkSpeed = 16, JumpPower = 50, Gravity = 196.2 } 

local function SaveDefaultStats()
	local char = LocalPlayer.Character
	-- [PENTING] Simpan Gravitasi Map saat ini sebagai default
	DefaultStats.Gravity = Workspace.Gravity 
	
	if char and char:FindFirstChild("Humanoid") then
		DefaultStats.WalkSpeed = char.Humanoid.WalkSpeed
		DefaultStats.JumpPower = char.Humanoid.JumpPower
	end
end
LocalPlayer.CharacterAdded:Connect(function(char) char:WaitForChild("Humanoid", 5); SaveDefaultStats() end)
-- Jalankan sekali di awal untuk menangkap status map
SaveDefaultStats()
local Session = { StopFly = function() end, StopWalk = function() end, StopJump = function() end, StopGravity = function() end, StopNoclip = function() end, StopInfJump = function() end, ResetAll = function() end }

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

--// [5] UI HELPERS
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
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)
	local S = Instance.new("UIStroke"); S.Parent = Card; S.Color = Theme.Accent; S.Transparency = 0.8; S.Thickness = 1
	return Card
end

local function CreateExpandableSection(parent, title)
	local SectionContainer = Instance.new("Frame"); SectionContainer.Parent = parent; SectionContainer.BackgroundTransparency = 1; SectionContainer.Size = UDim2.new(1, 0, 0, 30); SectionContainer.ClipsDescendants = true
	local HeaderBtn = Instance.new("TextButton"); HeaderBtn.Parent = SectionContainer; HeaderBtn.BackgroundColor3 = Theme.ActiveTab; HeaderBtn.Size = UDim2.new(1, 0, 0, 30); HeaderBtn.AutoButtonColor = true; HeaderBtn.Text = ""; Instance.new("UICorner", HeaderBtn).CornerRadius = UDim.new(0, 6)
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

local function CreateSwitchCard(targetParent, text, callback)
	local Card = Instance.new("Frame"); Card.Parent = targetParent; Card.BackgroundColor3 = Theme.ActiveTab; Card.BackgroundTransparency = 0.5; Card.Size = UDim2.new(1, 0, 0, 30); Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
	local TitleLbl = Instance.new("TextLabel"); TitleLbl.Parent = Card; TitleLbl.BackgroundTransparency = 1; TitleLbl.Position = UDim2.new(0, 10, 0, 0); TitleLbl.Size = UDim2.new(0, 150, 1, 0); TitleLbl.Font = Theme.FontMain; TitleLbl.Text = text; TitleLbl.TextColor3 = Theme.TextDim; TitleLbl.TextSize = 12; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	local SwitchBtn = Instance.new("TextButton"); SwitchBtn.Parent = Card; SwitchBtn.BackgroundTransparency = 1; SwitchBtn.Position = UDim2.new(1, -45, 0.5, -10); SwitchBtn.Size = UDim2.new(0, 40, 0, 20); SwitchBtn.Text = ""
	local Sw = Instance.new("Frame"); Sw.Parent = SwitchBtn; Sw.BackgroundColor3 = Color3.fromRGB(20, 25, 35); Sw.Position = UDim2.new(0, 0, 0.5, -8); Sw.Size = UDim2.new(0, 36, 0, 16); Instance.new("UICorner", Sw).CornerRadius = UDim.new(1,0)
	local K = Instance.new("Frame"); K.Parent = Sw; K.BackgroundColor3 = Theme.TextDim; K.Position = UDim2.new(0, 2, 0.5, -6); K.Size = UDim2.new(0, 12, 0, 12); Instance.new("UICorner", K).CornerRadius = UDim.new(1,0)
	local toggled = false
	local function SetState(state)
		toggled = state
		if toggled then TweenService:Create(K, TweenInfo.new(0.2), {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Theme.Main}):Play(); TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play(); TitleLbl.TextColor3 = Theme.Text
		else TweenService:Create(K, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Theme.TextDim}):Play(); TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 25, 35)}):Play(); TitleLbl.TextColor3 = Theme.TextDim end
		if callback then callback(toggled) end
	end
	SwitchBtn.MouseButton1Click:Connect(function() SetState(not toggled) end)
	return { SetState = SetState, Card = Card }
end

local function CreateMainSwitch(targetParent, text, callback)
	local Obj = CreateSwitchCard(targetParent, text, callback)
	Obj.Card.BackgroundTransparency = 0.2
	local Stroke = Instance.new("UIStroke"); Stroke.Parent = Obj.Card; Stroke.Color = Theme.Accent; Stroke.Transparency = 0.8; Stroke.Thickness = 1
	local Title = Obj.Card:FindFirstChildOfClass("TextLabel"); if Title then Title.Position = UDim2.new(0, 15, 0, 0); Title.Font = Theme.FontBold; Title.TextColor3 = Theme.Text; Title.TextSize = 14 end
	local Btn = Obj.Card:FindFirstChildOfClass("TextButton"); if Btn then Btn.Position = UDim2.new(1, -55, 0.5, -10) end
	return Obj
end

local function CreateButtonCard(targetParent, text, btnText, callback)
	local Card = Instance.new("Frame"); Card.Parent = targetParent; Card.BackgroundColor3 = Theme.ActiveTab; Card.BackgroundTransparency = 0.5; Card.Size = UDim2.new(1, 0, 0, 30); Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
	local TitleLbl = Instance.new("TextLabel"); TitleLbl.Parent = Card; TitleLbl.BackgroundTransparency = 1; TitleLbl.Position = UDim2.new(0, 10, 0, 0); TitleLbl.Size = UDim2.new(0, 150, 1, 0); TitleLbl.Font = Theme.FontMain; TitleLbl.Text = text; TitleLbl.TextColor3 = Theme.TextDim; TitleLbl.TextSize = 12; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	local ActBtn = Instance.new("TextButton"); ActBtn.Parent = Card; ActBtn.BackgroundColor3 = Theme.Main; ActBtn.Position = UDim2.new(1, -75, 0.5, -10); ActBtn.Size = UDim2.new(0, 70, 0, 20); ActBtn.Font = Theme.FontBold; ActBtn.Text = btnText; ActBtn.TextColor3 = Theme.Accent; ActBtn.TextSize = 10; Instance.new("UICorner", ActBtn).CornerRadius = UDim.new(0, 4); local AS = Instance.new("UIStroke"); AS.Parent = ActBtn; AS.Color = Theme.Accent; AS.Transparency = 0.5; AS.Thickness = 1; AS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ActBtn.MouseButton1Click:Connect(function() ActBtn.Text = "WAIT..."; callback(); task.wait(0.5); ActBtn.Text = "DONE"; task.wait(1); ActBtn.Text = btnText end)
	return { Card = Card }
end

local function CreateSmartSlider(targetParent, title, min, max, getStartVal, callback)
	local Card = Instance.new("Frame"); Card.Parent = targetParent; Card.BackgroundColor3 = Theme.ActiveTab; Card.BackgroundTransparency = 0.5; Card.Size = UDim2.new(1, 0, 0, 45); Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
	local startVal = getStartVal() or min; local safeMin, safeMax = math.min(min, max), math.max(min, max); startVal = math.clamp(startVal, safeMin, safeMax)
	local TitleLbl = Instance.new("TextLabel"); TitleLbl.Parent = Card; TitleLbl.BackgroundTransparency = 1; TitleLbl.Position = UDim2.new(0, 10, 0, 5); TitleLbl.Size = UDim2.new(1, -20, 0, 15); TitleLbl.Font = Theme.FontMain; TitleLbl.Text = title; TitleLbl.TextColor3 = Theme.TextDim; TitleLbl.TextSize = 12; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	local ValueLbl = Instance.new("TextLabel"); ValueLbl.Parent = Card; ValueLbl.BackgroundTransparency = 1; ValueLbl.Position = UDim2.new(0, 10, 0, 5); ValueLbl.Size = UDim2.new(1, -20, 0, 15); ValueLbl.Font = Theme.FontBold; ValueLbl.Text = string.format("%.1f", startVal); ValueLbl.TextColor3 = Theme.Accent; ValueLbl.TextSize = 12; ValueLbl.TextXAlignment = Enum.TextXAlignment.Right
	local SliderBG = Instance.new("TextButton"); SliderBG.Parent = Card; SliderBG.BackgroundColor3 = Color3.fromRGB(20, 25, 35); SliderBG.Position = UDim2.new(0, 10, 0, 28); SliderBG.Size = UDim2.new(1, -20, 0, 6); SliderBG.Text = ""; SliderBG.AutoButtonColor = false; Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)
	local SliderFill = Instance.new("Frame"); SliderFill.Parent = SliderBG; SliderFill.BackgroundColor3 = Theme.Accent; SliderFill.BorderSizePixel = 0; Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
	local Knob = Instance.new("Frame"); Knob.Parent = SliderBG; Knob.BackgroundColor3 = Theme.Text; Knob.Size = UDim2.new(0, 12, 0, 12); Knob.AnchorPoint = Vector2.new(0.5, 0.5); Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
	local defaultPercent = (startVal - min) / (max - min); local clampedPercent = math.clamp(defaultPercent, 0, 1)
	SliderFill.Size = UDim2.new(clampedPercent, 0, 1, 0); Knob.Position = UDim2.new(clampedPercent, 0, 0.5, 0)
	local dragging = false
	local function Update(input)
		local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1); SliderFill.Size = UDim2.new(pos, 0, 1, 0); Knob.Position = UDim2.new(pos, 0, 0.5, 0)
		local val = min + ((max - min) * pos)
		if math.abs(max - min) > 50 then val = math.floor(val); ValueLbl.Text = tostring(val) else ValueLbl.Text = string.format("%.1f", val) end
		if callback then callback(val) end
	end
	SliderBG.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; Update(i) end end)
	UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

local function CreateSliderCard(targetParent, text, min, max, default, callback) CreateSmartSlider(targetParent, text, min, max, function() return default end, callback) end

--// [6] TABS & FEATURES
local function BuildInfoTab(parentFrame)
	local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 14)
	local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)
	
	-- [PING CARD]
	local PingCard = CreateCard(parentFrame, UDim2.new(1, 0, 0,60), 1)
	local PingTitle = Instance.new("TextLabel"); PingTitle.Parent = PingCard; PingTitle.BackgroundTransparency = 1; PingTitle.Position = UDim2.new(0, 15, 0, 5); PingTitle.Size = UDim2.new(1, -30, 0, 20); PingTitle.Font = Theme.FontBold; PingTitle.Text = "Network Ping"; PingTitle.TextColor3 = Theme.TextDim; PingTitle.TextSize = 12; PingTitle.TextXAlignment = Enum.TextXAlignment.Left
	local PingValue = Instance.new("TextLabel"); PingValue.Parent = PingCard; PingValue.BackgroundTransparency = 1; PingValue.Position = UDim2.new(0, 15, 0, 5); PingValue.Size = UDim2.new(1, -30, 0, 20); PingValue.Font = Theme.FontBold; PingValue.Text = "0 ms"; PingValue.TextColor3 = Theme.Accent; PingValue.TextSize = 12; PingValue.TextXAlignment = Enum.TextXAlignment.Right
	local BarBg = Instance.new("Frame"); BarBg.Parent = PingCard; BarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40); BarBg.Position = UDim2.new(0, 15, 0, 35); BarBg.Size = UDim2.new(1, -30, 0, 10); Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)
	local BarFill = Instance.new("Frame"); BarFill.Parent = BarBg; BarFill.BackgroundColor3 = Theme.Accent; BarFill.Size = UDim2.new(0.5, 0, 1, 0); Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

	-- [GRID: FPS & MEMORY]
	local GridContainer = Instance.new("Frame"); GridContainer.Parent = parentFrame; GridContainer.BackgroundTransparency = 1; GridContainer.Size = UDim2.new(1,1, 0, 50); GridContainer.LayoutOrder = 2
	local GL = Instance.new("UIGridLayout"); GL.Parent = GridContainer; GL.CellPadding = UDim2.new(0, 5, 0, 0); GL.CellSize = UDim2.new(0.493, 0, 1, 0); GL.SortOrder = Enum.SortOrder.LayoutOrder; GL.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	local FPSCard = CreateCard(GridContainer, UDim2.new(0,0,0,0), 1)
	local FPSTitle = Instance.new("TextLabel"); FPSTitle.Parent = FPSCard; FPSTitle.BackgroundTransparency = 1; FPSTitle.Position = UDim2.new(0, 12, 0, 35); FPSTitle.Size = UDim2.new(1, -24, 0, 10); FPSTitle.Font = Theme.FontMain; FPSTitle.Text = "FPS Counter"; FPSTitle.TextColor3 = Theme.TextDim; FPSTitle.TextSize = 12; FPSTitle.TextXAlignment = Enum.TextXAlignment.Left
	local FPSNum = Instance.new("TextLabel"); FPSNum.Parent = FPSCard; FPSNum.BackgroundTransparency = 1; FPSNum.Position = UDim2.new(0, 12, 0, 12); FPSNum.Size = UDim2.new(1, -24, 0, 10); FPSNum.Font = Theme.FontBold; FPSNum.Text = "60"; FPSNum.TextColor3 = Theme.Text; FPSNum.TextSize = 28; FPSNum.TextXAlignment = Enum.TextXAlignment.Left
	
	local MemCard = CreateCard(GridContainer, UDim2.new(0,0,0,0), 2)
	local MemTitle = Instance.new("TextLabel"); MemTitle.Parent = MemCard; MemTitle.BackgroundTransparency = 1; MemTitle.Position = UDim2.new(0, 12, 0, 35); MemTitle.Size = UDim2.new(1, -24, 0, 10); MemTitle.Font = Theme.FontMain; MemTitle.Text = "Memory RAM"; MemTitle.TextColor3 = Theme.TextDim; MemTitle.TextSize = 12; MemTitle.TextXAlignment = Enum.TextXAlignment.Left
	local MemNum = Instance.new("TextLabel"); MemNum.Parent = MemCard; MemNum.BackgroundTransparency = 1; MemNum.Position = UDim2.new(0, 12, 0, 12); MemNum.Size = UDim2.new(1, -24, 0, 10); MemNum.Font = Theme.FontBold; MemNum.Text = "0"; MemNum.TextColor3 = Theme.Text; MemNum.TextSize = 24; MemNum.TextXAlignment = Enum.TextXAlignment.Left

	-- [TIME CARD]
	local TimeCard = CreateCard(parentFrame, UDim2.new(1, 0, 0, 55), 3)
	local TimeTitle = Instance.new("TextLabel"); TimeTitle.Parent = TimeCard; TimeTitle.BackgroundTransparency = 1; TimeTitle.Position = UDim2.new(0, 15, 0, 2); TimeTitle.Size = UDim2.new(1, -30, 0, 20); TimeTitle.Font = Theme.FontBold; TimeTitle.Text = "Time Server"; TimeTitle.TextColor3 = Theme.TextDim; TimeTitle.TextSize = 12; TimeTitle.TextXAlignment = Enum.TextXAlignment.Left
	local ClockLabel = Instance.new("TextLabel"); ClockLabel.Parent = TimeCard; ClockLabel.BackgroundTransparency = 1; ClockLabel.Position = UDim2.new(0, 15, 0, 0); ClockLabel.Size = UDim2.new(1, -30, 0, 35); ClockLabel.Font = Theme.FontBold; ClockLabel.Text = "00:00:00"; ClockLabel.TextColor3 = Theme.Text; ClockLabel.TextSize = 34; ClockLabel.TextXAlignment = Enum.TextXAlignment.Right
	local DateLabel = Instance.new("TextLabel"); DateLabel.Parent = TimeCard; DateLabel.BackgroundTransparency = 1; DateLabel.Position = UDim2.new(0, 15, 0, 30); DateLabel.Size = UDim2.new(1, -30, 0, 20); DateLabel.Font = Theme.FontMain; DateLabel.Text = "Monday, 1 Jan 2024"; DateLabel.TextColor3 = Theme.Accent; DateLabel.TextSize = 14; DateLabel.TextXAlignment = Enum.TextXAlignment.Right

	-- [SESSION CARD: REJOIN & SERVER HOP]
	local SessionCard = CreateCard(parentFrame, UDim2.new(1, 0, 0, 115), 4)
	local SessionTitle = Instance.new("TextLabel"); SessionTitle.Parent = SessionCard; SessionTitle.BackgroundTransparency = 1; SessionTitle.Position = UDim2.new(0, 15, 0, 8); SessionTitle.Size = UDim2.new(1, -30, 0, 10); SessionTitle.Font = Theme.FontBold; SessionTitle.Text = "Session Manager"; SessionTitle.TextColor3 = Theme.TextDim; SessionTitle.TextSize = 12; SessionTitle.TextXAlignment = Enum.TextXAlignment.Left
	
	-- Helper Button Style (Update: Passing 'Btn' ke callback)
	local function CreateSessionBtn(text, color, pos, callback)
		local Btn = Instance.new("TextButton"); Btn.Parent = SessionCard
		Btn.BackgroundColor3 = Theme.Sidebar
		Btn.Position = pos; Btn.Size = UDim2.new(1, -30, 0, 30)
		Btn.Font = Theme.FontBold; Btn.Text = text; Btn.TextColor3 = color; Btn.TextSize = 11
		Btn.AutoButtonColor = true
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
		local S = Instance.new("UIStroke"); S.Parent = Btn; S.Color = color; S.Thickness = 1; S.Transparency = 0.7; S.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		
		-- Saat diklik, panggil callback dengan membawa objek Btn agar teksnya bisa diubah
		Btn.MouseButton1Click:Connect(function()
			callback(Btn)
		end)
	end

	-- 1. REJOIN (Accent Blue) - Dengan Efek Teks
	CreateSessionBtn("REJOIN SERVER", Theme.Accent, UDim2.new(0, 15, 0, 30), function(btn)
		btn.Text = "REJOINING..." -- Ubah teks
		btn.AutoButtonColor = false -- Matikan efek klik agar terlihat statis
		
		local TS = game:GetService("TeleportService"); local LP = game:GetService("Players").LocalPlayer
		TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) 
	end)

	-- 2. SERVER HOP LOW (Green) - Dengan Efek Teks
	CreateSessionBtn("SERVER HOP (LOW/SEPI)", Theme.Green, UDim2.new(0, 15, 0, 70), function(btn)
		btn.Text = "SEARCHING LOW SERVER..." -- Ubah teks
		btn.AutoButtonColor = false
		
		local Http = game:GetService("HttpService"); local TS = game:GetService("TeleportService")
		-- sortOrder=Asc (Urutkan dari terkecil / sepi)
		local Servers = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
		
		local found = false
		for _, s in pairs(Servers.data) do
			if s.playing < s.maxPlayers and s.id ~= game.JobId then
				TS:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
				found = true
				break
			end
		end
		
		if not found then
			btn.Text = "NO SERVERS FOUND"
			task.wait(1)
			btn.Text = "SERVER HOP (LOW/SEPI)"
			btn.AutoButtonColor = true
		end
	end)

	-- LOOP INFO (Optimized Memory)
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
			
			TweenService:Create(BarFill, PingTween, {
				Size = UDim2.new(barSize, 0, 1, 0), 
				BackgroundColor3 = ping < 100 and Theme.Green or ping < 200 and Color3.fromRGB(255, 200, 0) or Theme.Red
			}):Play()
			
			MemNum.Text = tostring(math.floor(Stats:GetTotalMemoryUsageMb()))
			ClockLabel.Text = os.date("%H:%M:%S")
			DateLabel.Text = os.date("%A, %d %B %Y")
			
			task.wait(1)
		end
		if FPS_Connection then FPS_Connection:Disconnect() end
	end)
end

local function BuildMovementTab(parentFrame)
	local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 10)
	local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)

	-- [HELPER: CONTROL CARD]
	local function CreateControlCard(title, defaultVal, onToggle, onValChange, onUpdate)
		local Card = CreateCard(parentFrame, UDim2.new(1, 0, 0, 40), 0)
		local TitleLbl = Instance.new("TextLabel"); TitleLbl.Parent = Card; TitleLbl.BackgroundTransparency = 1; TitleLbl.Position = UDim2.new(0, 15, 0, 0); TitleLbl.Size = UDim2.new(0, 70, 1, 0); TitleLbl.Font = Theme.FontBold; TitleLbl.Text = title; TitleLbl.TextColor3 = Theme.Text; TitleLbl.TextSize = 14; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
		
		local Controls = Instance.new("Frame"); Controls.Parent = Card; Controls.BackgroundTransparency = 1; Controls.Position = UDim2.new(1, -170, 0, 0); Controls.Size = UDim2.new(0, 160, 1, 0)
		local MinusBtn = Instance.new("TextButton"); MinusBtn.Parent = Controls; MinusBtn.BackgroundColor3 = Theme.Sidebar; MinusBtn.Position = UDim2.new(0, 0, 0.5, -12); MinusBtn.Size = UDim2.new(0, 24, 0, 24); MinusBtn.Font = Theme.FontBold; MinusBtn.Text = "-"; MinusBtn.TextColor3 = Theme.Accent; Instance.new("UICorner", MinusBtn).CornerRadius = UDim.new(0, 6)
		local ValTxt = Instance.new("TextLabel"); ValTxt.Parent = Controls; ValTxt.BackgroundTransparency = 1; ValTxt.Position = UDim2.new(0, 28, 0.5, -12); ValTxt.Size = UDim2.new(0, 30, 0, 24); ValTxt.Font = Theme.FontBold; ValTxt.Text = tostring(defaultVal); ValTxt.TextColor3 = Theme.Text; ValTxt.TextSize = 14
		local PlusBtn = Instance.new("TextButton"); PlusBtn.Parent = Controls; PlusBtn.BackgroundColor3 = Theme.Sidebar; PlusBtn.Position = UDim2.new(0, 62, 0.5, -12); PlusBtn.Size = UDim2.new(0, 24, 0, 24); PlusBtn.Font = Theme.FontBold; PlusBtn.Text = "+"; PlusBtn.TextColor3 = Theme.Accent; Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 6)
		local Toggle = Instance.new("TextButton"); Toggle.Parent = Controls; Toggle.BackgroundColor3 = Theme.Sidebar; Toggle.Position = UDim2.new(1, -55, 0.5, -12); Toggle.Size = UDim2.new(0, 50, 0, 24); Toggle.Font = Theme.FontBold; Toggle.Text = "OFF"; Toggle.TextColor3 = Theme.TextDim; Toggle.TextSize = 11; local FT_Corner = Instance.new("UICorner"); FT_Corner.CornerRadius = UDim.new(0, 6); FT_Corner.Parent = Toggle; local FT_Stroke = Instance.new("UIStroke"); FT_Stroke.Parent = Toggle; FT_Stroke.Color = Theme.TextDim; FT_Stroke.Transparency = 0.8; FT_Stroke.Thickness = 1
		
		local isActive = false; local currentVal = defaultVal
		local function UpdateValue() ValTxt.Text = tostring(currentVal); if isActive and onUpdate then onUpdate(currentVal) end end
		MinusBtn.MouseButton1Click:Connect(function() currentVal = onValChange(currentVal, -1); UpdateValue() end)
		PlusBtn.MouseButton1Click:Connect(function() currentVal = onValChange(currentVal, 1); UpdateValue() end)
		local function SetToggleState(state)
			isActive = state
			if isActive then Toggle.Text = "ON"; Toggle.TextColor3 = Theme.Main; Toggle.BackgroundColor3 = Theme.Accent; FT_Stroke.Color = Theme.Accent; FT_Stroke.Transparency = 0 else Toggle.Text = "OFF"; Toggle.TextColor3 = Theme.TextDim; Toggle.BackgroundColor3 = Theme.Sidebar; FT_Stroke.Color = Theme.TextDim; FT_Stroke.Transparency = 0.8 end
			onToggle(isActive, currentVal)
		end
		Toggle.MouseButton1Click:Connect(function() SetToggleState(not isActive) end)
		-- Penting: Return Card Object & Reset Function
		return { 
			SetState = SetToggleState, 
			Reset = function() currentVal = defaultVal; ValTxt.Text = tostring(currentVal); SetToggleState(false) end,
			Card = Card 
		}
	end

	--// 1. FLY MODE
	local flying = false; local flySpeed = 1; local bv = nil; local bg = nil; local flyLoop = nil
	Session.StopFly = function()
		flying = false; if bv then bv:Destroy(); bv = nil end; if bg then bg:Destroy(); bg = nil end; if flyLoop then flyLoop:Disconnect(); flyLoop = nil end
		local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false; char.Humanoid:ChangeState(Enum.HumanoidStateType.Landed) end
	end
	local FlyCtrl = CreateControlCard("Fly Mode", 1, function(active, speed)
		flying = active; flySpeed = speed
		if not active then Session.StopFly() else
			Session.StopWalk(); Session.StopJump()
			local char = LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid"); local cam = workspace.CurrentCamera
			if not root or not hum then return end
			if bv then bv:Destroy() end; if bg then bg:Destroy() end
			bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge); bv.Velocity = Vector3.new(0,0,0); bv.Parent = root
			bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bg.P = 10000; bg.D = 100; bg.CFrame = root.CFrame; bg.Parent = root
			hum.PlatformStand = true
			flyLoop = RunService.Heartbeat:Connect(function()
				if not flying or not char or not root.Parent then Session.StopFly() return end
				local moveDir = hum.MoveDirection; local camCF = cam.CFrame
				if moveDir.Magnitude > 0 then
					local relDir = camCF:VectorToObjectSpace(moveDir); local rawDir = (camCF.LookVector * -relDir.Z) + (camCF.RightVector * relDir.X)
					if rawDir.Magnitude > 0.01 then rawDir = rawDir.Unit end
					bv.Velocity = bv.Velocity:Lerp(rawDir * (flySpeed * 50), 0.2)
				else bv.Velocity = Vector3.new(0,0,0) end; bg.CFrame = cam.CFrame
			end)
		end
	end, function(old, change) return math.max(1, old + change) end, function(newSpeed) flySpeed = newSpeed end)

	--// 2. SPEED WALK
	local walkLoop; local currentWalkMultiplier = 1
	local SpeedCtrl = CreateControlCard("Speed Walk", 1, function(active, mul)
		if walkLoop then walkLoop:Disconnect() end; currentWalkMultiplier = mul
		if active then Session.StopFly(); walkLoop = RunService.Heartbeat:Connect(function() local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then local targetSpeed = DefaultStats.WalkSpeed * currentWalkMultiplier; if char.Humanoid.WalkSpeed ~= targetSpeed then char.Humanoid.WalkSpeed = targetSpeed end end end) else Session.StopWalk() end
	end, function(old, change) return math.max(1, old + change) end, function(newMul) currentWalkMultiplier = newMul end)
	Session.StopWalk = function() if walkLoop then walkLoop:Disconnect() end; local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = DefaultStats.WalkSpeed end end

	--// 3. HIGH JUMP
	local jumpLoop; local currentJumpMultiplier = 1
	local JumpCtrl = CreateControlCard("High Jump", 1, function(active, mul)
		if jumpLoop then jumpLoop:Disconnect() end; currentJumpMultiplier = mul
		if active then Session.StopFly(); jumpLoop = RunService.Heartbeat:Connect(function() local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then local targetJump = DefaultStats.JumpPower * currentJumpMultiplier; if not char.Humanoid.UseJumpPower then char.Humanoid.UseJumpPower = true end; if char.Humanoid.JumpPower ~= targetJump then char.Humanoid.JumpPower = targetJump end end end) else Session.StopJump() end
	end, function(old, change) return math.max(1, old + change) end, function(newMul) currentJumpMultiplier = newMul end)
	Session.StopJump = function() if jumpLoop then jumpLoop:Disconnect() end; local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid.JumpPower = DefaultStats.JumpPower end end

	--// 4. LOW GRAVITY (Anti-Gravity) - [FITUR BARU]
	local gravLoop; local currentGravLevel = 1
	
	-- Fungsi Reset Internal
	Session.StopGravity = function()
		if gravLoop then gravLoop:Disconnect(); gravLoop = nil end
		Workspace.Gravity = DefaultStats.Gravity -- Kembali ke default map
	end

	local GravCtrl = CreateControlCard("Low Gravity (Divisor)", 1, function(active, level)
		if gravLoop then gravLoop:Disconnect() end; currentGravLevel = level
		if active then
			-- Loop Gravitasi agar tidak di-overwrite game
			gravLoop = RunService.Heartbeat:Connect(function()
				-- Rumus: Gravitasi Default / Level (Makin besar level, makin ringan)
				Workspace.Gravity = DefaultStats.Gravity / currentGravLevel
			end)
		else
			Session.StopGravity()
		end
	end, function(old, change) 
		-- Logic: Minimal 1 (Normal), Naik/Turun 1
		return math.max(1, old + change) 
	end, function(newVal) currentGravLevel = newVal end)

	--// 5. NOCLIP (OLD MODEL)
	local noclipLoop
	local NoclipCtrl = CreateMainSwitch(parentFrame, "No Clip Mode", function(active)
		if active then noclipLoop = RunService.Stepped:Connect(function() local char = LocalPlayer.Character; if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end end end) else Session.StopNoclip() end
	end)
	Session.StopNoclip = function() if noclipLoop then noclipLoop:Disconnect() end; local char = LocalPlayer.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid"); if char and root and hum then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then if part.Name == "HumanoidRootPart" then part.CanCollide = true; part.Transparency = 1 else part.CanCollide = false end end end; local originalHip = hum.HipHeight; hum.HipHeight = 0; task.wait(); hum.HipHeight = originalHip; hum:ChangeState(Enum.HumanoidStateType.GettingUp) end end

	--// 6. INF JUMP
	local InfJumpConn
	local InfJumpCtrl = CreateMainSwitch(parentFrame, "Infinity Jump", function(active)
		if active then InfJumpConn = UserInputService.JumpRequest:Connect(function() local char = LocalPlayer.Character; if char and char:FindFirstChild("Humanoid") then char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end) else Session.StopInfJump() end
	end)
	Session.StopInfJump = function() if InfJumpConn then InfJumpConn:Disconnect() end end

	--// RESET BUTTON
	local ResetBtn = Instance.new("TextButton"); ResetBtn.Parent = parentFrame; ResetBtn.BackgroundColor3 = Theme.Red; ResetBtn.BackgroundTransparency = 0.2; ResetBtn.Size = UDim2.new(1, 0, 0, 35); ResetBtn.Font = Theme.FontBold; ResetBtn.Text = "RESET DEFAULT"; ResetBtn.TextColor3 = Theme.Text; ResetBtn.TextSize = 12; Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 8); local RS = Instance.new("UIStroke"); RS.Parent = ResetBtn; RS.Color = Theme.Red; RS.Thickness = 1; RS.Transparency = 0.5
	
	Session.ResetAll = function() 
		-- Reset Controllers (UI)
		FlyCtrl.Reset(); SpeedCtrl.Reset(); JumpCtrl.Reset(); GravCtrl.Reset()
		NoclipCtrl.SetState(false); InfJumpCtrl.SetState(false)
		
		-- Stop Logic
		Session.StopFly(); Session.StopWalk(); Session.StopJump(); Session.StopGravity()
		Session.StopNoclip(); Session.StopInfJump() 
	end
	ResetBtn.MouseButton1Click:Connect(Session.ResetAll)
end

local function BuildTeleportTab(parentFrame)
	local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 10)
	local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)
	
	local ColorSuccess = Theme.Green; local ColorError = Theme.Red
	local ColorPressed = Theme.Pressed -- Mengambil dari Tema (Dark Neon)
	
	local selectedPlayer = nil; local isDropdownOpen = false; local statusTimer = nil; 
	local ActiveConnections = {} -- [JANITOR SYSTEM]
	
	local function ClearConnections()
		for _, conn in pairs(ActiveConnections) do if conn then conn:Disconnect() end end
		table.clear(ActiveConnections)
	end

	local TpCard = CreateCard(parentFrame, UDim2.new(1, 0, 0, 165))
	TpCard.ClipsDescendants = false; TpCard.LayoutOrder = 1; TpCard.ZIndex = 10 

	local Title = Instance.new("TextLabel"); Title.Parent = TpCard; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 15, 0, 10); Title.Size = UDim2.new(1, -30, 0, 15); Title.Font = Theme.FontBold; Title.Text = "Player Teleport & Follow"; Title.TextColor3 = Theme.Text; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left
	local StatusLbl = Instance.new("TextLabel"); StatusLbl.Parent = TpCard; StatusLbl.BackgroundTransparency = 1; StatusLbl.Position = UDim2.new(0, 15, 1, -22); StatusLbl.Size = UDim2.new(1, -30, 0, 15); StatusLbl.Font = Theme.FontMain; StatusLbl.Text = ""; StatusLbl.TextColor3 = ColorError; StatusLbl.TextSize = 11; StatusLbl.TextXAlignment = Enum.TextXAlignment.Center
	local function ShowStatus(text, color) StatusLbl.Text = text; StatusLbl.TextColor3 = color or Theme.Text; if statusTimer then task.cancel(statusTimer) end; statusTimer = task.delay(3, function() if StatusLbl then StatusLbl.Text = "" end statusTimer = nil end) end

	local DropContainer = Instance.new("Frame"); DropContainer.Parent = TpCard; DropContainer.BackgroundTransparency = 1; DropContainer.Position = UDim2.new(0, 15, 0, 35); DropContainer.Size = UDim2.new(1, -30, 0, 30); DropContainer.ZIndex = 20
	local DropBtn = Instance.new("TextButton"); DropBtn.Parent = DropContainer; DropBtn.BackgroundColor3 = Theme.Sidebar; DropBtn.Size = UDim2.new(1, -75, 1, 0); DropBtn.Font = Theme.FontMain; DropBtn.Text = "  Select Player..."; DropBtn.TextColor3 = Theme.TextDim; DropBtn.TextSize = 12; DropBtn.TextXAlignment = Enum.TextXAlignment.Left; DropBtn.AutoButtonColor = false; DropBtn.ZIndex = 20; Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 6); local DS = Instance.new("UIStroke"); DS.Parent = DropBtn; DS.Color = Theme.Separator; DS.Thickness = 1
	local RefreshBtn = Instance.new("TextButton"); RefreshBtn.Parent = DropContainer; RefreshBtn.BackgroundColor3 = Theme.Green; RefreshBtn.Position = UDim2.new(1, -70, 0, 0); RefreshBtn.Size = UDim2.new(0, 70, 1, 0); RefreshBtn.ZIndex = 20; RefreshBtn.Font = Theme.FontBold; RefreshBtn.Text = "REFRESH"; RefreshBtn.TextColor3 = Theme.Main; RefreshBtn.TextSize = 11; Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 6)
	local ListFrame = Instance.new("ScrollingFrame"); ListFrame.Parent = TpCard; ListFrame.Visible = false; ListFrame.BackgroundColor3 = Theme.Sidebar; ListFrame.BorderSizePixel = 0; ListFrame.Position = UDim2.new(0, 15, 0, 68); ListFrame.Size = UDim2.new(0.90, -65, 0, 120); ListFrame.ZIndex = 30; ListFrame.ScrollBarThickness = 2; local LS = Instance.new("UIStroke"); LS.Parent = ListFrame; LS.Color = Theme.Accent; LS.Thickness = 1; local LL = Instance.new("UIListLayout"); LL.Parent = ListFrame; LL.SortOrder = Enum.SortOrder.LayoutOrder

	local function ToggleDropdown(forceClose)
		if forceClose then isDropdownOpen = false else isDropdownOpen = not isDropdownOpen end; ListFrame.Visible = isDropdownOpen; if ActiveConnections["Dropdown"] then ActiveConnections["Dropdown"]:Disconnect() end
		if isDropdownOpen then ActiveConnections["Dropdown"] = UserInputService.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local mPos = Vector2.new(input.Position.X, input.Position.Y); local function isInRect(obj) local pos, size = obj.AbsolutePosition, obj.AbsoluteSize; return mPos.X >= pos.X and mPos.X <= pos.X + size.X and mPos.Y >= pos.Y and mPos.Y <= pos.Y + size.Y end; if not isInRect(ListFrame) and not isInRect(DropBtn) then ToggleDropdown(true) end end end) end
	end
	
	local function RefreshList()
		for _, v in pairs(ListFrame:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				local PBtn = Instance.new("TextButton"); PBtn.Parent = ListFrame; PBtn.BackgroundColor3 = Theme.Main; PBtn.Size = UDim2.new(1, 0, 0, 25); PBtn.Font = Theme.FontMain; PBtn.TextSize = 12; PBtn.TextXAlignment = Enum.TextXAlignment.Left; PBtn.AutoButtonColor = true; PBtn.ZIndex = 31; local labelText = "  " .. p.DisplayName .. " (@" .. p.Name .. ")"; PBtn.Text = labelText; PBtn.TextColor3 = Theme.TextDim
				PBtn.MouseButton1Click:Connect(function() selectedPlayer = p; DropBtn.Text = labelText; DropBtn.TextColor3 = Theme.Text; ToggleDropdown(true) end)
			end
		end
		ListFrame.CanvasSize = UDim2.new(0, 0, 0, LL.AbsoluteContentSize.Y)
	end
	DropBtn.MouseButton1Click:Connect(function() ToggleDropdown() end); RefreshBtn.MouseButton1Click:Connect(function() RefreshList(); ShowStatus("List Refreshed!", ColorSuccess) end)

	local BtnContainer = Instance.new("Frame"); BtnContainer.Parent = TpCard; BtnContainer.BackgroundTransparency = 1; BtnContainer.Position = UDim2.new(0, 15, 0, 75); BtnContainer.Size = UDim2.new(1, -30, 0, 60)
	
	local function CreateStyledButton(name, pos, size)
		local Btn = Instance.new("TextButton"); Btn.Parent = BtnContainer
		Btn.BackgroundColor3 = Theme.Sidebar; Btn.Position = pos; Btn.Size = size
		Btn.Font = Theme.FontBold; Btn.Text = name; Btn.TextColor3 = Theme.TextDim; Btn.TextSize = 10
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
		local S = Instance.new("UIStroke"); S.Parent = Btn; S.Color = Theme.Separator; S.Thickness = 1; S.Transparency = 0.8; S.ApplyStrokeMode = Enum.ApplyStrokeMode.Border 
		return Btn, S
	end

	local function SetButtonStyle(Btn, Stroke, IsActive, ActiveText, DefaultText)
		if IsActive then
			Btn.BackgroundColor3 = ColorPressed; Btn.TextColor3 = Theme.Accent; Btn.Text = ActiveText or DefaultText; Stroke.Color = Theme.Accent; Stroke.Transparency = 0.6; Stroke.Thickness = 1
		else
			Btn.BackgroundColor3 = Theme.Sidebar; Btn.TextColor3 = Theme.TextDim; Btn.Text = DefaultText; Stroke.Color = Theme.Separator; Stroke.Transparency = 0.8; Stroke.Thickness = 1
		end
	end

	local SpectateBtn, SS = CreateStyledButton("SPECTATE", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 0, 28))
	local TeleportBtn, TS = CreateStyledButton("TELEPORT", UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 0, 28))
	local FollowBtn, FS = CreateStyledButton("SMART FOLLOW (WALK)", UDim2.new(0, 0, 0, 35), UDim2.new(1, 0, 0, 28))

	local function StopAllModes()
		ClearConnections()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid end
		SetButtonStyle(SpectateBtn, SS, false, nil, "SPECTATE") 
		SetButtonStyle(FollowBtn, FS, false, nil, "SMART FOLLOW (WALK)") 
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then char.Humanoid:MoveTo(char.HumanoidRootPart.Position) end
	end

	SpectateBtn.MouseButton1Click:Connect(function()
		if ActiveConnections["Spectate"] then StopAllModes() else
			StopAllModes() 
			if not selectedPlayer then ShowStatus("Select Player First!", ColorError); return end
			local target = Players:FindFirstChild(selectedPlayer.Name)
			if target then
				SetButtonStyle(SpectateBtn, SS, true, "STOP VIEW", "SPECTATE") 
				ShowStatus("Spectating...", ColorSuccess)
				ActiveConnections["Spectate"] = RunService.RenderStepped:Connect(function() 
					if not target or not target.Parent then StopAllModes(); ShowStatus("Target Left", ColorError); return end
					if target.Character and target.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = target.Character.Humanoid end 
				end)
			else ShowStatus("Player Unavailable", ColorError) end
		end
	end)

	TeleportBtn.MouseButton1Click:Connect(function()
		if not selectedPlayer then ShowStatus("Select a player!", ColorError); return end
		local target = Players:FindFirstChild(selectedPlayer.Name); if not target then ShowStatus("Player Left.", ColorError); return end
		local tChar = target.Character; local lChar = LocalPlayer.Character
		SetButtonStyle(TeleportBtn, TS, true, "TELEPORTED!", "TELEPORT")
		task.delay(0.3, function() SetButtonStyle(TeleportBtn, TS, false, nil, "TELEPORT") end)
		if tChar and tChar:FindFirstChild("HumanoidRootPart") and lChar and lChar:FindFirstChild("HumanoidRootPart") then 
			lChar.HumanoidRootPart.CFrame = tChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
			ShowStatus("Teleported!", ColorSuccess) 
		else ShowStatus("Target Unreachable", ColorError) end
	end)

	FollowBtn.MouseButton1Click:Connect(function()
		if ActiveConnections["Follow"] then StopAllModes() else
			StopAllModes()
			if not selectedPlayer then ShowStatus("Select Player First!", ColorError); return end
			SetButtonStyle(FollowBtn, FS, true, "STOP FOLLOWING", "SMART FOLLOW (WALK)")
			ShowStatus("Following Target...", ColorSuccess)
			ActiveConnections["Follow"] = RunService.Heartbeat:Connect(function(deltaTime)
				local target = Players:FindFirstChild(selectedPlayer.Name); local myChar = LocalPlayer.Character
				if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then StopAllModes(); ShowStatus("Target Lost", ColorError); return end
				if not myChar or not myChar:FindFirstChild("HumanoidRootPart") or not myChar:FindFirstChild("Humanoid") then return end
				local myRoot = myChar.HumanoidRootPart; local targetRoot = target.Character.HumanoidRootPart; local hum = myChar.Humanoid; local tHum = target.Character:FindFirstChild("Humanoid")
				local dist = (myRoot.Position - targetRoot.Position).Magnitude
				if dist > 150 then myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 2, 3); return end
				if dist > 8 then 
					local predictedPos = targetRoot.Position + (targetRoot.AssemblyLinearVelocity * 0.1)
					hum:MoveTo(predictedPos)
					if (targetRoot.Position.Y > myRoot.Position.Y + 3) and dist < 15 then hum.Jump = true end
					if tHum and tHum.Jump then hum.Jump = true end
				elseif dist < 5 then hum:MoveTo(myRoot.Position) end
			end)
		end
	end)

	local TapSwitch = CreateMainSwitch(parentFrame, "Teleport Tap (Click / Touch)", function(active)
		if active then ActiveConnections["TapTP"] = UserInputService.InputBegan:Connect(function(input, gameProcessed) if gameProcessed then return end; if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local mouse = LocalPlayer:GetMouse(); local targetPos = mouse.Hit; local char = LocalPlayer.Character; if char and char:FindFirstChild("HumanoidRootPart") and targetPos then char.HumanoidRootPart.CFrame = CFrame.new(targetPos.X, targetPos.Y + 3, targetPos.Z) end end end)
		else if ActiveConnections["TapTP"] then ActiveConnections["TapTP"]:Disconnect() end end
	end)
	if TapSwitch.Card then TapSwitch.Card.LayoutOrder = 2; TapSwitch.Card.ZIndex = 1 end
	RefreshList()
end

local function BuildVisualsTab(parentFrame)
	local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 10)
	local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame; Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)

	local function ToggleFeature(isActive, storageTable, onAdd, onRemove)
		if isActive then
			local function SetupPlayer(player) if player == LocalPlayer then return end; if player.Character then onAdd(player.Character, player) end; local conn = player.CharacterAdded:Connect(function(char) char:WaitForChild("HumanoidRootPart", 5); onAdd(char, player) end); table.insert(storageTable, conn) end
			for _, p in pairs(Players:GetPlayers()) do SetupPlayer(p) end; local pAdded = Players.PlayerAdded:Connect(SetupPlayer); table.insert(storageTable, pAdded)
		else for _, conn in pairs(storageTable) do conn:Disconnect() end; table.clear(storageTable); for _, p in pairs(Players:GetPlayers()) do if p.Character then onRemove(p.Character) end end end
	end
	
	local ESP_Container = CreateExpandableSection(parentFrame, "ESP Features")
	local HL_Conn = {}
	CreateSwitchCard(ESP_Container, "ESP Player (Highlight)", function(active) ToggleFeature(active, HL_Conn, function(char) if char:FindFirstChild("NeeR_Highlight") then char.NeeR_Highlight:Destroy() end; local hl = Instance.new("Highlight"); hl.Name="NeeR_Highlight"; hl.Parent=char; hl.Adornee=char; hl.FillColor=Theme.Red; hl.FillTransparency=0.5; hl.OutlineColor=Color3.new(1,1,1); hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop end, function(char) if char:FindFirstChild("NeeR_Highlight") then char.NeeR_Highlight:Destroy() end end) end)
	local Name_Conn = {}
	CreateSwitchCard(ESP_Container, "Player Names", function(active) ToggleFeature(active, Name_Conn, function(char, plr) if not char:FindFirstChild("Head") then return end; if char:FindFirstChild("NeeR_Name") then char.NeeR_Name:Destroy() end; local bb = Instance.new("BillboardGui"); bb.Name="NeeR_Name"; bb.Parent=char; bb.Adornee=char.Head; bb.Size=UDim2.new(0,100,0,20); bb.StudsOffset=Vector3.new(0,3.5,0); bb.AlwaysOnTop=true; local tx = Instance.new("TextLabel"); tx.Parent=bb; tx.Size=UDim2.new(1,0,1,0); tx.BackgroundTransparency=1; tx.Text=plr.DisplayName; tx.TextColor3=Color3.new(1,1,1); tx.Font=Theme.FontBold; tx.TextSize=12; tx.TextStrokeTransparency=0 end, function(char) if char:FindFirstChild("NeeR_Name") then char.NeeR_Name:Destroy() end end) end)
	local HP_Conn = {}
	CreateSwitchCard(ESP_Container, "Health Bar", function(active) ToggleFeature(active, HP_Conn, function(char) if not char:FindFirstChild("Head") then return end; if char:FindFirstChild("NeeR_HP") then char.NeeR_HP:Destroy() end; local bb = Instance.new("BillboardGui"); bb.Name="NeeR_HP"; bb.Parent=char; bb.Adornee=char.Head; bb.Size=UDim2.new(0,40,0,4); bb.StudsOffset=Vector3.new(0,2.5,0); bb.AlwaysOnTop=true; local bg = Instance.new("Frame"); bg.Parent=bb; bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.new(0,0,0); bg.BorderSizePixel=0; local fill = Instance.new("Frame"); fill.Parent=bg; fill.Size=UDim2.new(1,0,1,0); fill.BackgroundColor3=Theme.Green; fill.BorderSizePixel=0; local hum = char:FindFirstChild("Humanoid"); if hum then local function Upd() local p = math.clamp(hum.Health/hum.MaxHealth, 0, 1); TweenService:Create(fill, TweenInfo.new(0.2), {Size=UDim2.new(p,0,1,0)}):Play(); fill.BackgroundColor3 = p < 0.3 and Theme.Red or Theme.Green end; Upd(); hum.HealthChanged:Connect(Upd) end end, function(char) if char:FindFirstChild("NeeR_HP") then char.NeeR_HP:Destroy() end end) end)

	local XRay_Container = CreateExpandableSection(parentFrame, "Wall X-Ray (Smart)")
	local XRay_Cache = {}; local XRay_Opacity = 0.5; local XRay_Active = false
	local function ApplyXRay() if not XRay_Active then return end; for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and not v:IsA("Terrain") then local isCharacter = v.Parent:FindFirstChild("Humanoid") or v.Parent.Parent:FindFirstChild("Humanoid"); local isHidden = v.Transparency > 0.9; if not isCharacter and not isHidden then if not XRay_Cache[v] then XRay_Cache[v] = v.Transparency end; v.Transparency = XRay_Opacity end end end end
	local function RemoveXRay() for part, oldTransparency in pairs(XRay_Cache) do if part and part.Parent then part.Transparency = oldTransparency end end; table.clear(XRay_Cache) end
	CreateSmartSlider(XRay_Container, "Opacity", 0.1, 0.9, function() return 0.5 end, function(val) XRay_Opacity = val; if XRay_Active then for part, _ in pairs(XRay_Cache) do if part and part.Parent then part.Transparency = XRay_Opacity end end end end)
	CreateSwitchCard(XRay_Container, "Enable X-Ray", function(active) XRay_Active = active; if active then ApplyXRay() else RemoveXRay() end end)
	CreateButtonCard(XRay_Container, "Refresh", "REFRESH", function() if XRay_Active then ApplyXRay() end end)

	local World_Container = CreateExpandableSection(parentFrame, "World & Lighting")
	local fb_loop; local LightingBackup = {}
	CreateSwitchCard(World_Container, "Full Brightness", function(active)
		if active then LightingBackup = { Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows, OutdoorAmbient = Lighting.OutdoorAmbient }; fb_loop = RunService.RenderStepped:Connect(function() Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000; Lighting.GlobalShadows = false; Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128) end)
		else if fb_loop then fb_loop:Disconnect(); fb_loop = nil end; if LightingBackup.Brightness then Lighting.Brightness = LightingBackup.Brightness; Lighting.ClockTime = LightingBackup.ClockTime; Lighting.FogEnd = LightingBackup.FogEnd; Lighting.GlobalShadows = LightingBackup.GlobalShadows; Lighting.OutdoorAmbient = LightingBackup.OutdoorAmbient end end
	end)
	CreateSmartSlider(World_Container, "Fog Density (Ketebalan)", 2500, 10, function() return Lighting.FogEnd end, function(val) Lighting.FogStart = 0; Lighting.FogEnd = val end)
	CreateSmartSlider(World_Container, "Time of Day (Smooth)", 0, 24, function() return Lighting.ClockTime end, function(val) if not fb_loop then Lighting.ClockTime = val end end)

	local Cine_Container = CreateExpandableSection(parentFrame, "Cinematic Camera")
	local function CreateSuperCamCard(parent)
		local Card = CreateCard(parent, UDim2.new(1, 0, 0, 120)); local startY = 15
		local SL_Label = Instance.new("TextLabel"); SL_Label.Parent = Card; SL_Label.BackgroundTransparency=1; SL_Label.Position=UDim2.new(0,15,0,startY); SL_Label.Size=UDim2.new(0,100,0,20); SL_Label.Font=Theme.FontMain; SL_Label.Text="Force Shift Lock"; SL_Label.TextColor3=Theme.TextDim; SL_Label.TextSize=12; SL_Label.TextXAlignment=Enum.TextXAlignment.Left
		local SL_Btn = Instance.new("TextButton"); SL_Btn.Parent = Card; SL_Btn.BackgroundTransparency=1; SL_Btn.Position=UDim2.new(1,-60,0,startY); SL_Btn.Size=UDim2.new(0,45,0,20); SL_Btn.Text=""
		local SL_Sw = Instance.new("Frame"); SL_Sw.Parent=SL_Btn; SL_Sw.BackgroundColor3=Color3.fromRGB(20,25,35); SL_Sw.Position=UDim2.new(0,0,0.5,-8); SL_Sw.Size=UDim2.new(0,36,0,16); Instance.new("UICorner", SL_Sw).CornerRadius=UDim.new(1,0)
		local SL_K = Instance.new("Frame"); SL_K.Parent=SL_Sw; SL_K.BackgroundColor3=Theme.TextDim; SL_K.Position=UDim2.new(0,2,0.5,-6); SL_K.Size=UDim2.new(0,12,0,12); Instance.new("UICorner", SL_K).CornerRadius=UDim.new(1,0)
		local sl_conn, sl_active = nil, false
		SL_Btn.MouseButton1Click:Connect(function()
			sl_active = not sl_active
			if sl_active then TweenService:Create(SL_K, TweenInfo.new(0.2), {Position=UDim2.new(1,-14,0.5,-6), BackgroundColor3=Theme.Main}):Play(); TweenService:Create(SL_Sw, TweenInfo.new(0.2), {BackgroundColor3=Theme.Accent}):Play(); SL_Label.TextColor3 = Theme.Text; sl_conn = RunService.RenderStepped:Connect(function() UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter; local char = LocalPlayer.Character; if char and char:FindFirstChild("HumanoidRootPart") then local root = char.HumanoidRootPart; local camCF = workspace.CurrentCamera.CFrame; root.CFrame = CFrame.new(root.Position, root.Position + Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)) end end)
			else TweenService:Create(SL_K, TweenInfo.new(0.2), {Position=UDim2.new(0,2,0.5,-6), BackgroundColor3=Theme.TextDim}):Play(); TweenService:Create(SL_Sw, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(20,25,35)}):Play(); SL_Label.TextColor3 = Theme.TextDim; if sl_conn then sl_conn:Disconnect() end; UserInputService.MouseBehavior = Enum.MouseBehavior.Default end
		end)
		local camOffX, camOffY = 0, 0
		local function UpdateOffset() local c = LocalPlayer.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.CameraOffset = Vector3.new(camOffX, camOffY, 0) end end
		LocalPlayer.CharacterAdded:Connect(function() task.wait(1); UpdateOffset() end)
		local function AddKnobSlider(yPos, text, min, max, callback)
			local Lbl = Instance.new("TextLabel"); Lbl.Parent=Card; Lbl.BackgroundTransparency=1; Lbl.Position=UDim2.new(0,15,0,yPos); Lbl.Size=UDim2.new(0,100,0,15); Lbl.Font=Theme.FontMain; Lbl.Text=text; Lbl.TextColor3=Theme.TextDim; Lbl.TextSize=11; Lbl.TextXAlignment=Enum.TextXAlignment.Left; local Val = Instance.new("TextLabel"); Val.Parent=Card; Val.BackgroundTransparency=1; Val.Position=UDim2.new(1,-45,0,yPos); Val.Size=UDim2.new(0,30,0,15); Val.Font=Theme.FontBold; Val.Text="0"; Val.TextColor3=Theme.Accent; Val.TextSize=11; Val.TextXAlignment=Enum.TextXAlignment.Right; local SBG = Instance.new("TextButton"); SBG.Parent=Card; SBG.BackgroundColor3=Color3.fromRGB(20,25,35); SBG.Position=UDim2.new(0,15,0,yPos+18); SBG.Size=UDim2.new(1,-30,0,4); SBG.Text=""; SBG.AutoButtonColor=false; Instance.new("UICorner", SBG).CornerRadius=UDim.new(1,0); local SF = Instance.new("Frame"); SF.Parent=SBG; SF.BackgroundColor3=Theme.Accent; SF.Size=UDim2.new(0.5,0,1,0); SF.BorderSizePixel=0; Instance.new("UICorner", SF).CornerRadius=UDim.new(1,0); local Knob = Instance.new("Frame"); Knob.Parent=SBG; Knob.BackgroundColor3=Theme.Text; Knob.Size=UDim2.new(0,12,0,12); Knob.AnchorPoint=Vector2.new(0.5, 0.5); Knob.Position=UDim2.new(0.5, 0, 0.5, 0); Instance.new("UICorner", Knob).CornerRadius=UDim.new(1,0)
			local dragging = false
			local function Upd(input) local pos = math.clamp((input.Position.X - SBG.AbsolutePosition.X)/SBG.AbsoluteSize.X, 0, 1); SF.Size = UDim2.new(pos,0,1,0); Knob.Position = UDim2.new(pos, 0, 0.5, 0); local value = math.floor((min + ((max-min)*pos)) * 10) / 10; Val.Text = tostring(value); callback(value) end
			SBG.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; Upd(i) end end)
			UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then Upd(i) end end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
		end
		AddKnobSlider(startY+30, "Offset X (Side)", -4, 4, function(v) camOffX=v; UpdateOffset() end)
		AddKnobSlider(startY+65, "Offset Y (Height)", -4, 4, function(v) camOffY=v; UpdateOffset() end)
	end
	CreateSuperCamCard(Cine_Container)

	local Cam_Container = CreateExpandableSection(parentFrame, "Camera Options")
	CreateSliderCard(Cam_Container, "Field of View (FOV)", 70, 120, 70, function(val) workspace.CurrentCamera.FieldOfView = val end)
	CreateSwitchCard(Cam_Container, "Unlock Max Zoom", function(active) LocalPlayer.CameraMaxZoomDistance = active and 100000 or 128 end)
	CreateSwitchCard(Cam_Container, "Camera Noclip", function(active) LocalPlayer.DevCameraOcclusionMode = active and Enum.DevCameraOcclusionMode.Invisicam or Enum.DevCameraOcclusionMode.Zoom end)

	local FPS_Container = CreateExpandableSection(parentFrame, "Performance / FPS")
	CreateSwitchCard(FPS_Container, "Remove Shadows & Effects", function(active) Lighting.GlobalShadows = not active; for _,v in pairs(Lighting:GetChildren()) do if v:IsA("PostEffect") then v.Enabled = not active end end end)
	CreateButtonCard(FPS_Container, "Potato Mode (Low Poly)", "EXECUTE", function() for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0 end; if v:IsA("MeshPart") then v.TextureID = "" end end end)
	CreateButtonCard(FPS_Container, "Clear All Textures", "CLEAR", function() for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end end end)
end

local function BuildSettingsTab(parentFrame)
	local Layout = Instance.new("UIListLayout"); Layout.Parent = parentFrame
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Padding = UDim.new(0, 10)

	local Padding = Instance.new("UIPadding"); Padding.Parent = parentFrame
	Padding.PaddingTop = UDim.new(0, 15); Padding.PaddingLeft = UDim.new(0, 15); Padding.PaddingRight = UDim.new(0, 15)
	
	-- =================================================================
	-- [GROUP 1: INTERFACE]
	-- =================================================================
	local DPICard = CreateCard(parentFrame, UDim2.new(1, 0, 0, 85))
	DPICard.LayoutOrder = 1; DPICard.ZIndex = 100; DPICard.ClipsDescendants = false

	local SettingsLabel = Instance.new("TextLabel"); SettingsLabel.Parent = DPICard
	SettingsLabel.BackgroundTransparency = 1; SettingsLabel.Position = UDim2.new(0, 15, 0, 10); SettingsLabel.Size = UDim2.new(1, -30, 0, 20)
	SettingsLabel.Font = Theme.FontBold; SettingsLabel.Text = "Interface Scale (DPI)"; SettingsLabel.TextColor3 = Theme.Text
	SettingsLabel.TextSize = 14; SettingsLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	local DPIBtn = Instance.new("TextButton"); DPIBtn.Parent = DPICard
	DPIBtn.BackgroundColor3 = Theme.Sidebar; DPIBtn.Position = UDim2.new(0, 15, 0, 35); DPIBtn.Size = UDim2.new(1, -30, 0, 35)
	DPIBtn.Font = Theme.FontBold; DPIBtn.Text = IsMobile and "  Size: 75% (Medium)" or "  Size: 100% (Default)"; DPIBtn.TextColor3 = Theme.TextDim
	DPIBtn.TextSize = 12; DPIBtn.TextXAlignment = Enum.TextXAlignment.Left; DPIBtn.AutoButtonColor = false; DPIBtn.ZIndex = 101
	Instance.new("UICorner", DPIBtn).CornerRadius = UDim.new(0, 6)
	local DPIB_S = Instance.new("UIStroke"); DPIB_S.Parent = DPIBtn; DPIB_S.Color = Theme.Separator; DPIB_S.Thickness = 1
	
	local DPIFrame = Instance.new("Frame"); DPIFrame.Parent = DPICard
	DPIFrame.BackgroundColor3 = Theme.Main; DPIFrame.Position = UDim2.new(0, 15, 0, 75); DPIFrame.Size = UDim2.new(1, -30, 0, 0)
	DPIFrame.ClipsDescendants = true; DPIFrame.Visible = false; DPIFrame.ZIndex = 105
	Instance.new("UICorner", DPIFrame).CornerRadius = UDim.new(0, 6)
	local DPIF_S = Instance.new("UIStroke"); DPIF_S.Parent = DPIFrame; DPIF_S.Color = Theme.Accent; DPIF_S.Transparency = 0.5; DPIF_S.Thickness = 1
	local DPIList = Instance.new("UIListLayout"); DPIList.Parent = DPIFrame; DPIList.SortOrder = Enum.SortOrder.LayoutOrder
	
	local dpiOpen, dpiConnection = false, nil
	local function ToggleDPI(forceClose) 
		if forceClose then dpiOpen = false else dpiOpen = not dpiOpen end
		if dpiConnection then dpiConnection:Disconnect(); dpiConnection = nil end
		if dpiOpen then 
			DPIFrame.Visible = true; TweenService:Create(DPIFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -30, 0, 105)}):Play()
			dpiConnection = UserInputService.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then local mPos = Vector2.new(input.Position.X, input.Position.Y); local btnPos, btnSize = DPIBtn.AbsolutePosition, DPIBtn.AbsoluteSize; local frmPos, frmSize = DPIFrame.AbsolutePosition, DPIFrame.AbsoluteSize; if not (mPos.X >= btnPos.X and mPos.X <= btnPos.X + btnSize.X and mPos.Y >= btnPos.Y and mPos.Y <= btnPos.Y + btnSize.Y) and not (mPos.X >= frmPos.X and mPos.X <= frmPos.X + frmSize.X and mPos.Y >= frmPos.Y and mPos.Y <= frmPos.Y + frmSize.Y) then ToggleDPI(true) end end end) 
		else TweenService:Create(DPIFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -30, 0, 0)}):Play(); task.wait(0.3); if not dpiOpen then DPIFrame.Visible = false end end 
	end
	DPIBtn.MouseButton1Click:Connect(function() ToggleDPI() end)
	local function AddDPIOption(txt, scaleVal) local Opt = Instance.new("TextButton"); Opt.Parent = DPIFrame; Opt.BackgroundColor3 = Theme.Main; Opt.Size = UDim2.new(1, 0, 0, 35); Opt.Font = Theme.FontMain; Opt.Text = txt; Opt.TextColor3 = Theme.TextDim; Opt.TextSize = 12; Opt.AutoButtonColor = true; Opt.ZIndex = 106; Opt.MouseButton1Click:Connect(function() TweenService:Create(UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Scale = scaleVal}):Play(); DPIBtn.Text = "  Size: " .. txt; ToggleDPI(true) end) end
	AddDPIOption("100% (Default)", 1); AddDPIOption("75% (Medium)", 0.75); AddDPIOption("50% (Small)", 0.5)

	-- =================================================================
	-- [GROUP 2: PERFORMANCE]
	-- =================================================================
	
	-- 1. UNLOCK FPS
	local FPSUnlock = CreateMainSwitch(parentFrame, "Unlock FPS (Limit 60 -> 999)", function(active)
		if setfpscap then setfpscap(active and 999 or 60) end
	end)
	if FPSUnlock.Card then FPSUnlock.Card.LayoutOrder = 2; FPSUnlock.Card.ZIndex = 90 end

	-- 2. LOW CPU / BLACK SCREEN
	local BlackScreenGUI = nil
	local LowCPU = CreateMainSwitch(parentFrame, "Low CPU (Black Screen)", function(active)
		-- Matikan Rendering 3D
		RunService:Set3dRenderingEnabled(not active)
		
		if active then
			if not BlackScreenGUI then
				BlackScreenGUI = Instance.new("ScreenGui")
				BlackScreenGUI.Name = "NeeR_BlackScreen"
				BlackScreenGUI.Parent = CoreGui
				BlackScreenGUI.IgnoreGuiInset = true
				
				-- [LOGIKA PENTING] 
				-- Pastikan layer BlackScreen selalu DI BAWAH layer Script Utama
				-- Script utama (parentFrame.Parent) biasanya punya DisplayOrder 0 atau default.
				-- Kita set script utama ke tinggi, dan black screen ke rendah.
				
				-- Ambil ScreenGui utama dari script ini
				local MainGui = parentFrame:FindFirstAncestorOfClass("ScreenGui")
				if MainGui then
					MainGui.DisplayOrder = 100 -- Pastikan Menu selalu di atas
					BlackScreenGUI.DisplayOrder = 90 -- Layar hitam di bawah Menu, tapi di atas Game
				end
				
				local BlackFrame = Instance.new("Frame")
				BlackFrame.Parent = BlackScreenGUI
				BlackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
				BlackFrame.Size = UDim2.new(1, 0, 1, 0)
				
				local Info = Instance.new("TextLabel")
				Info.Parent = BlackFrame; Info.BackgroundTransparency = 1
				Info.Position = UDim2.new(0, 0, 0.9, 0); Info.Size = UDim2.new(1, 0, 0, 20)
				Info.Font = Theme.FontMain; Info.Text = "Rendering Disabled (Battery Saver Active)"; Info.TextColor3 = Color3.fromRGB(100, 100, 100); Info.TextSize = 12
			end
		else
			if BlackScreenGUI then BlackScreenGUI:Destroy(); BlackScreenGUI = nil end
		end
	end)
	if LowCPU.Card then LowCPU.Card.LayoutOrder = 3; LowCPU.Card.ZIndex = 80 end

	-- =================================================================
	-- [GROUP 3: SYSTEM UTILITY]
	-- =================================================================
	local afkConnection = nil; local VirtualUser = game:GetService("VirtualUser")
	local AFKSwitch = CreateMainSwitch(parentFrame, "Anti-AFK (Prevent Kick)", function(active)
		if active then
			afkConnection = LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
		else if afkConnection then afkConnection:Disconnect(); afkConnection = nil end end
	end)
	if AFKSwitch.Card then AFKSwitch.Card.LayoutOrder = 4; AFKSwitch.Card.ZIndex = 70 end

	-- =================================================================
	-- [GROUP 4: DANGER ZONE]
	-- =================================================================
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
	Loader.Update("Loading Informations...", 0.3); local TabInfo = CreateTabBtn("Informations", true); BuildInfoTab(TabInfo); task.wait(0.5)
	Loader.Update("Loading Movement...", 0.5); local TabMovement = CreateTabBtn("Movement", false); BuildMovementTab(TabMovement); task.wait(0.5)
	Loader.Update("Loading Teleports...", 0.6); local TabTeleports = CreateTabBtn("Teleports", false); BuildTeleportTab(TabTeleports); task.wait(0.5)
	Loader.Update("Loading Visuals...", 0.8); local TabVisuals = CreateTabBtn("Visuals", false); BuildVisualsTab(TabVisuals); task.wait(0.5)
	Loader.Update("Loading Settings...", 0.9); local TabSettings = CreateTabBtn("Settings", false); BuildSettingsTab(TabSettings); task.wait(0.5)
	
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
