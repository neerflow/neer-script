local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

local flying = false
local speed = 50

-- --- DESAIN UI ---
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleBtn = Instance.new("TextButton")
local SpeedInput = Instance.new("TextBox")

ScreenGui.Parent = game.CoreGui
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 130, 0, 100)
MainFrame.Active = true
MainFrame.Draggable = true

ToggleBtn.Parent = MainFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ToggleBtn.Size = UDim2.new(1, 0, 0.5, 0)
ToggleBtn.Text = "FLY 3D: OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextScaled = true

SpeedInput.Parent = MainFrame
SpeedInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SpeedInput.Position = UDim2.new(0, 0, 0.5, 0)
SpeedInput.Size = UDim2.new(1, 0, 0.5, 0)
SpeedInput.Text = "Speed: 50"
SpeedInput.TextColor3 = Color3.new(1, 1, 1)
SpeedInput.TextScaled = true

-- --- LOGIKA NOCLIP ---
local noclipConn
local function setNoclip(status)
    if status then
        noclipConn = RunService.Stepped:Connect(function()
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
    end
end

-- --- LOGIKA TERBANG 3D ---
local bv = Instance.new("BodyVelocity")
local bg = Instance.new("BodyGyro")

local function startFlying()
    bv.Parent = root
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bg.Parent = root
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    
    task.spawn(function()
        while flying do
            -- LOGIKA INTI:
            -- Kita ambil arah kamera, lalu kita kalikan dengan input analog.
            -- Jika analog didorong ke depan (Magnitude > 0), 
            -- karakter akan bergerak sesuai arah pandang kamera (termasuk naik/turun).
            
            if humanoid.MoveDirection.Magnitude > 0 then
                -- Menghitung arah terbang berdasarkan kemiringan kamera
                bv.Velocity = camera.CFrame.LookVector * speed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            
            -- Membuat tubuh karakter mengikuti kemiringan kamera (agar terlihat realistis)
            bg.CFrame = camera.CFrame
            RunService.RenderStepped:Wait()
        end
        bv.Parent = nil
        bg.Parent = nil
    end)
end

-- --- EVENT HANDLER ---
ToggleBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        ToggleBtn.Text = "FLY 3D: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        setNoclip(true)
        startFlying()
    else
        ToggleBtn.Text = "FLY 3D: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        setNoclip(false)
    end
end)

SpeedInput.FocusLost:Connect(function()
    local val = tonumber(SpeedInput.Text:match("%d+"))
    if val then speed = val end
    SpeedInput.Text = "Speed: "..speed
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    root = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
end)
