-- --- SETTINGS & VARIABLES ---
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local flying = false
local flySpeed = 1
local bodyVelocity, bodyGyro

-- --- UI CONSTRUCTION ---
local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local onof = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local plus = Instance.new("TextButton")
local speedDisplay = Instance.new("TextLabel")
local mine = Instance.new("TextButton")
local closebutton = Instance.new("TextButton")

main.Name = "FlyGuiV3_Fixed"
main.Parent = game:GetService("CoreGui")
main.ResetOnSpawn = false

Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
Frame.Position = UDim2.new(0.1, 0, 0.4, 0)
Frame.Size = UDim2.new(0, 190, 0, 60)
Frame.Active = true
Frame.Draggable = true

TextLabel.Parent = Frame
TextLabel.Size = UDim2.new(1, 0, 0.45, 0)
TextLabel.Text = "FLY 3D FULL ANALOG"
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.BackgroundTransparency = 1
TextLabel.TextScaled = true

onof.Name = "onof"
onof.Parent = Frame
onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
onof.Position = UDim2.new(0.65, 0, 0.5, 0)
onof.Size = UDim2.new(0, 60, 0, 25)
onof.Text = "fly: OFF"

plus.Parent = Frame
plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
plus.Position = UDim2.new(0.05, 0, 0.5, 0)
plus.Size = UDim2.new(0, 30, 0, 25)
plus.Text = "+"

speedDisplay.Parent = Frame
speedDisplay.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
speedDisplay.Position = UDim2.new(0.22, 0, 0.5, 0)
speedDisplay.Size = UDim2.new(0, 40, 0, 25)
speedDisplay.Text = tostring(flySpeed)

mine.Parent = Frame
mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
mine.Position = UDim2.new(0.45, 0, 0.5, 0)
mine.Size = UDim2.new(0, 30, 0, 25)
mine.Text = "-"

closebutton.Parent = Frame
closebutton.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
closebutton.Size = UDim2.new(0, 25, 0, 25)
closebutton.Position = UDim2.new(1, -25, 0, 0)
closebutton.Text = "X"

-- --- LOGIKA TERBANG (FIXED DIRECTIONAL) ---
local function toggleFly()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not root or not hum then return end

    if flying then
        onof.Text = "fly: ON"
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
                -- PERBAIKAN LOGIKA DI SINI:
                -- Kita menggunakan CFrame kamera sebagai basis arah, 
                -- lalu memutar arah tersebut berdasarkan MoveDirection analog.
                
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    -- Mengambil arah relatif dari kamera
                    local cameraCFrame = camera.CFrame
                    local direction = cameraCFrame:VectorToWorldSpace(Vector3.new(
                        (hum.MoveDirection * cameraCFrame.RightVector).Magnitude * (moveDir:Dot(cameraCFrame.RightVector) > 0 and 1 or -1),
                        (hum.MoveDirection * cameraCFrame.UpVector).Magnitude, -- Memungkinkan naik turun
                        (hum.MoveDirection * cameraCFrame.LookVector).Magnitude * (moveDir:Dot(cameraCFrame.LookVector) > 0 and 1 or -1)
                    ))
                    
                    -- Cara yang lebih simpel dan efektif untuk Analog 3D:
                    -- Gunakan LookVector untuk sumbu vertical, dan MoveDirection untuk sumbu Horizontal
                    local flyDir = moveDir + (cameraCFrame.LookVector * moveDir.Z)
                    
                    -- Final Velocity (Logic paling efisien untuk terbang 3D Analog)
                    bodyVelocity.Velocity = cameraCFrame:VectorToWorldSpace(cameraCFrame:VectorToObjectSpace(moveDir)) * (flySpeed * 50)
                else
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
                
                bodyGyro.CFrame = camera.CFrame
                RunService.RenderStepped:Wait()
            end
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            if hum then hum.PlatformStand = false end
        end)
    else
        onof.Text = "fly: OFF"
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
