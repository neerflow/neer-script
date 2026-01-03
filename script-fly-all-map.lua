-- Referensi Service
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Variabel Status
local flying = false
local flySpeed = 1
local speeds = 1 -- Variabel display untuk UI

-- --- BAGIAN UI ---
local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local up = Instance.new("TextButton") -- Tombol UP (Opsional, logika utama di Analog)
local down = Instance.new("TextButton") -- Tombol DOWN (Opsional)
local onof = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local plus = Instance.new("TextButton")
local speedLabel = Instance.new("TextLabel") -- Renamed to avoid conflict
local mine = Instance.new("TextButton")
local closebutton = Instance.new("TextButton")
local mini = Instance.new("TextButton")
local mini2 = Instance.new("TextButton")

main.Name = "FlyGuiV3_Fixed"
main.Parent = player:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
Frame.Position = UDim2.new(0.1, 0, 0.38, 0)
Frame.Size = UDim2.new(0, 190, 0, 57)
Frame.Active = true
Frame.Draggable = true

up.Name = "up"
up.Parent = Frame
up.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
up.Size = UDim2.new(0, 44, 0, 28)
up.Font = Enum.Font.SourceSans
up.Text = "UP"
up.TextColor3 = Color3.fromRGB(0, 0, 0)
up.TextSize = 14.000

down.Name = "down"
down.Parent = Frame
down.BackgroundColor3 = Color3.fromRGB(215, 255, 121)
down.Position = UDim2.new(0, 0, 0.49, 0)
down.Size = UDim2.new(0, 44, 0, 28)
down.Font = Enum.Font.SourceSans
down.Text = "DOWN"
down.TextColor3 = Color3.fromRGB(0, 0, 0)
down.TextSize = 14.000

onof.Name = "onof"
onof.Parent = Frame
onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
onof.Position = UDim2.new(0.7, 0, 0.49, 0)
onof.Size = UDim2.new(0, 56, 0, 28)
onof.Font = Enum.Font.SourceSans
onof.Text = "FLY"
onof.TextColor3 = Color3.fromRGB(0, 0, 0)
onof.TextSize = 14.000

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
TextLabel.Position = UDim2.new(0.47, 0, 0, 0)
TextLabel.Size = UDim2.new(0, 100, 0, 28)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "FLY GUI V3 FIXED"
TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000

plus.Name = "plus"
plus.Parent = Frame
plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
plus.Position = UDim2.new(0.23, 0, 0, 0)
plus.Size = UDim2.new(0, 45, 0, 28)
plus.Font = Enum.Font.SourceSans
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(0, 0, 0)
plus.TextScaled = true

speedLabel.Name = "speed"
speedLabel.Parent = Frame
speedLabel.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
speedLabel.Position = UDim2.new(0.47, 0, 0.49, 0)
speedLabel.Size = UDim2.new(0, 44, 0, 28)
speedLabel.Font = Enum.Font.SourceSans
speedLabel.Text = "1"
speedLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
speedLabel.TextScaled = true

mine.Name = "mine"
mine.Parent = Frame
mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
mine.Position = UDim2.new(0.23, 0, 0.49, 0)
mine.Size = UDim2.new(0, 45, 0, 29)
mine.Font = Enum.Font.SourceSans
mine.Text = "-"
mine.TextColor3 = Color3.fromRGB(0, 0, 0)
mine.TextScaled = true

closebutton.Name = "Close"
closebutton.Parent = Frame
closebutton.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
closebutton.Font = Enum.Font.SourceSans
closebutton.Size = UDim2.new(0, 45, 0, 28)
closebutton.Text = "X"
closebutton.TextSize = 20
closebutton.Position = UDim2.new(0, 0, -1, 27)

mini.Name = "minimize"
mini.Parent = Frame
mini.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
mini.Font = Enum.Font.SourceSans
mini.Size = UDim2.new(0, 45, 0, 28)
mini.Text = "-"
mini.TextSize = 30
mini.Position = UDim2.new(0, 44, -1, 27)

mini2.Name = "minimize2"
mini2.Parent = Frame
mini2.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
mini2.Font = Enum.Font.SourceSans
mini2.Size = UDim2.new(0, 45, 0, 28)
mini2.Text = "+"
mini2.TextSize = 30
mini2.Position = UDim2.new(0, 44, -1, 57)
mini2.Visible = false

-- --- LOGIKA UTAMA (PHYSICS & CONTROL) ---
local bv, bg
local noclipConnection

local function startFlying()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not root or not hum then return end

    -- Setup BodyVelocity (Penggerak)
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = root
    
    -- Setup BodyGyro (Penstabil Arah)
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 10000
    bg.D = 100 -- Damping agar tidak getar
    bg.CFrame = root.CFrame
    bg.Parent = root
    
    hum.PlatformStand = true -- Mematikan physics kaki agar melayang mulus
    
    -- Loop Noclip (Tembus Tembok)
    noclipConnection = RunService.Stepped:Connect(function()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
    
    -- Loop Pergerakan (Heartbeat)
    task.spawn(function()
        while flying and char and root.Parent do
            local delta = RunService.Heartbeat:Wait()
            local moveDir = hum.MoveDirection -- Input dari Analog Stick (World Space)
            
            if moveDir.Magnitude > 0 then
                -- LOGIKA PENTING: Menerjemahkan Analog ke Arah Kamera
                
                -- 1. Dapatkan CFrame Kamera
                local camCF = camera.CFrame
                
                -- 2. Ubah MoveDirection menjadi "Object Space" relatif terhadap kamera
                -- Ini memisahkan input menjadi "Maju/Mundur" (Z) dan "Kiri/Kanan" (X)
                local relDir = camCF:VectorToObjectSpace(moveDir)
                
                -- relDir.Z < 0 artinya Analog Maju
                -- relDir.Z > 0 artinya Analog Mundur
                -- relDir.X < 0 artinya Analog Kiri
                -- relDir.X > 0 artinya Analog Kanan
                
                -- 3. Kalkulasi Vektor Baru
                -- Komponen Maju/Mundur: Ikuti LookVector Kamera (Termasuk Atas/Bawah)
                local forwardVec = camCF.LookVector * -relDir.Z 
                
                -- Komponen Kiri/Kanan: Ikuti RightVector Kamera (Selalu Horizontal Relatif Kamera)
                local rightVec = camCF.RightVector * relDir.X
                
                -- 4. Gabungkan
                local targetVel = (forwardVec + rightVec) * (flySpeed * 50)
                
                bv.Velocity = targetVel
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            
            -- Rotasi Karakter mengikuti Kamera
            bg.CFrame = camera.CFrame
        end
        
        -- Cleanup saat berhenti terbang
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        if noclipConnection then noclipConnection:Disconnect() end
        if hum then hum.PlatformStand = false end
    end)
end

local function stopFlying()
    flying = false
    onof.Text = "FLY"
    onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    if noclipConnection then noclipConnection:Disconnect() end
    
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.PlatformStand = false
    end
end

-- --- EVENT LISTENER TOMBOL UI ---

onof.MouseButton1Down:Connect(function()
    flying = not flying
    if flying then
        onof.Text = "ON"
        onof.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        flySpeed = speeds -- Set speed awal
        startFlying()
    else
        stopFlying()
    end
end)

plus.MouseButton1Down:Connect(function()
    speeds = speeds + 1
    flySpeed = speeds
    speedLabel.Text = speeds
end)

mine.MouseButton1Down:Connect(function()
    if speeds > 1 then
        speeds = speeds - 1
        flySpeed = speeds
        speedLabel.Text = speeds
    end
end)

closebutton.MouseButton1Click:Connect(function()
    stopFlying()
    main:Destroy()
end)

mini.MouseButton1Click:Connect(function()
    up.Visible = false
    down.Visible = false
    onof.Visible = false
    plus.Visible = false
    speedLabel.Visible = false
    mine.Visible = false
    mini.Visible = false
    mini2.Visible = true
    Frame.BackgroundTransparency = 1
    closebutton.Position = UDim2.new(0, 0, -1, 57)
end)

mini2.MouseButton1Click:Connect(function()
    up.Visible = true
    down.Visible = true
    onof.Visible = true
    plus.Visible = true
    speedLabel.Visible = true
    mine.Visible = true
    mini.Visible = true
    mini2.Visible = false
    Frame.BackgroundTransparency = 0 
    closebutton.Position = UDim2.new(0, 0, -1, 27)
end)

-- Tombol UP/DOWN Manual (Opsional, tambahan jika mau naik tegak lurus)
up.MouseButton1Down:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
    end
end)

down.MouseButton1Down:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, -5, 0)
    end
end)

-- Notifikasi
game:GetService("StarterGui"):SetCore("SendNotification", { 
    Title = "FLY GUI V3 FIXED";
    Text = "Logic Analog 3D Terpasang!";
    Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150";
    Duration = 5;
})

