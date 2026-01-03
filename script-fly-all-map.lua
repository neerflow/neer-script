-- --- SETTINGS & VARIABLES ---
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local flying = false
local flySpeed = 1
local bodyVelocity, bodyGyro

-- --- UI CONSTRUCTION (Sesuai Layout Lama yang Dirapikan) ---
local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local onof = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local plus = Instance.new("TextButton")
local speedDisplay = Instance.new("TextLabel")
local mine = Instance.new("TextButton")
local closebutton = Instance.new("TextButton")

main.Name = "FlyGuiV3_Refined"
main.Parent = game:GetService("CoreGui") -- Lebih aman di CoreGui
main.ResetOnSpawn = false

Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
Frame.Position = UDim2.new(0.1, 0, 0.4, 0)
Frame.Size = UDim2.new(0, 190, 0, 60)
Frame.Active = true
Frame.Draggable = true

TextLabel.Parent = Frame
TextLabel.Size = UDim2.new(1, 0, 0.45, 0)
TextLabel.Text = "FLY 3D ANALOG"
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.BackgroundTransparency = 1
TextLabel.TextScaled = true

-- Tombol On/Off
onof.Name = "onof"
onof.Parent = Frame
onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
onof.Position = UDim2.new(0.65, 0, 0.5, 0)
onof.Size = UDim2.new(0, 60, 0, 25)
onof.Text = "OFF"
onof.TextSize = 14

-- Tombol Plus
plus.Parent = Frame
plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
plus.Position = UDim2.new(0.05, 0, 0.5, 0)
plus.Size = UDim2.new(0, 30, 0, 25)
plus.Text = "+"
plus.TextScaled = true

-- Display Speed
speedDisplay.Parent = Frame
speedDisplay.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
speedDisplay.Position = UDim2.new(0.22, 0, 0.5, 0)
speedDisplay.Size = UDim2.new(0, 40, 0, 25)
speedDisplay.Text = tostring(flySpeed)
speedDisplay.TextScaled = true

-- Tombol Minus
mine.Parent = Frame
mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
mine.Position = UDim2.new(0.45, 0, 0.5, 0)
mine.Size = UDim2.new(0, 30, 0, 25)
mine.Text = "-"
mine.TextScaled = true

closebutton.Parent = Frame
closebutton.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
closebutton.Size = UDim2.new(0, 25, 0, 25)
closebutton.Position = UDim2.new(1, -25, 0, 0)
closebutton.Text = "X"

-- --- LOGIKA TERBANG 3D (EFISIEN) ---
local function toggleFly()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not root or not hum then return end

    if flying then
        -- START FLYING
        onof.Text = "ON"
        onof.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Parent = root
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.Parent = root
        
        hum.PlatformStand = true
        
        task.spawn(function()
            while flying and root.Parent do
                -- Logika 3D: Arah kamera * Speed * Input Analog
                if hum.MoveDirection.Magnitude > 0 then
                    bodyVelocity.Velocity = camera.CFrame.LookVector * (flySpeed * 50)
                else
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
                
                bodyGyro.CFrame = camera.CFrame
                RunService.RenderStepped:Wait()
            end
            -- CLEANUP
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            if hum then hum.PlatformStand = false end
        end)
    else
        -- STOP FLYING
        onof.Text = "OFF"
        onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
    end
end

-- --- EVENT HANDLERS ---
onof.MouseButton1Click:Connect(function()
    flying = not flying
    toggleFly()
end)

plus.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 1
    speedDisplay.Text = tostring(flySpeed)
end)

mine.MouseButton1Click:Connect(function()
    if flySpeed > 1 then
        flySpeed = flySpeed - 1
        speedDisplay.Text = tostring(flySpeed)
    end
end)

closebutton.MouseButton1Click:Connect(function()
    flying = false
    main:Destroy()
end)

-- Notifikasi Awal
game:GetService("StarterGui"):SetCore("SendNotification", { 
    Title = "FLY 3D ANALOG";
    Text = "Versi Sempurna Berhasil Dimuat!";
    Duration = 3;
})
