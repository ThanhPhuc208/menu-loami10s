-- (Creator = Thanh Phuc)
-- 💟 Thanh Phuc - Harman Kardon Mi 10S Boombox (Dáng Lớn + 2 Màng Loa Tròn Co Giãn Cầu Vồng) 💟
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

-- Bộ phát âm thanh chuẩn chỉnh âm lượng vừa tai
local LocalSound = Instance.new("Sound")
LocalSound.Name = "ThanhPhucLocalSound"
LocalSound.Parent = LocalPlayer:WaitForChild("PlayerWorkspace", 5) or workspace
LocalSound.Volume = 2.5 
LocalSound.Looped = true

-- QUẢN LÝ BOOMBOX VÀ 2 MÀNG LOA TRÒN
local FakeBoombox = nil
local SpeakerRings = {}
local loopConnection = nil 

local function CreateFakeBoombox()
    -- Dọn dẹp triệt để tránh trùng luồng hiệu ứng
    if loopConnection then loopConnection:Disconnect(); loopConnection = nil end
    if FakeBoombox then FakeBoombox:Destroy(); FakeBoombox = nil end
    for _, ring in pairs(SpeakerRings) do if ring.Part then ring.Part:Destroy() end end
    SpeakerRings = {}
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not character then return end
    
    local torso = character:WaitForChild("UpperTorso", 5) or character:WaitForChild("Torso", 5)
    if not torso then return end
    
    -- [THAY ĐỔI THEO ẢNH 1000056597.jpg]: Tạo khối vuông lớn hơn, dày dặn và chắc chắn
    local part = Instance.new("Part")
    part.Name = "ThanhPhucChromaBoombox"
    part.Material = Enum.Material.Neon
    part.CanCollide = false
    part.Massless = true
    part.Parent = character
    FakeBoombox = part
    
    -- Kích thước to hơn, vuông vắn mô phỏng khối xanh trong ảnh của bạn
    local baseSize = Vector3.new(2.0, 1.8, 0.8) 
    part.Size = baseSize
    
    -- Gắn cân đối sau lưng nhân vật (Hơi xéo nhẹ balo quai chéo thẩm mỹ)
    local weld = Instance.new("Weld")
    weld.Part0 = torso
    weld.Part1 = part
    weld.C0 = CFrame.new(0, 0, 0.8) * CFrame.Angles(0, math.rad(180), math.rad(15))
    weld.Parent = part
    
    -- TẠO LOA KÉP: 2 Màng loa hình tròn (Cylinder) nằm dính trên bề mặt thùng loa
    -- Thiết kế màng loa không bao giờ biến mất, luôn xuất hiện cố định như loa thật
    for i = 1, 2 do
        local ring = Instance.new("Part")
        ring.Name = "SpeakerRing" .. i
        ring.Shape = Enum.PartType.Cylinder
        ring.Material = Enum.Material.Neon
        ring.CanCollide = false
        ring.Massless = true
        ring.Parent = character
        
        local ringWeld = Instance.new("Weld")
        ringWeld.Part0 = part
        ringWeld.Part1 = ring
        
        -- Định vị 2 lỗ loa: loa trên và loa dưới (Chuẩn thiết kế loa kép đối xứng Mi 10S)
        local yOffset = (i == 1) and 0.45 or -0.45
        -- Xoay Cylinder nằm ngang bám lên mặt sau của khối vuông
        ringWeld.C0 = CFrame.new(0, yOffset, 0.41) * CFrame.Angles(0, math.rad(90), 0)
        ringWeld.Parent = ring
        
        table.insert(SpeakerRings, {Part = ring, Weld = ringWeld, Direction = i})
    end
    
    -- HIỆU ỨNG CẦU VỒNG TOÀN DIỆN + ĐẬP BASS MƯỢT MÀ CHUẨN MI 10S
    local hue = 0
    loopConnection = RunService.RenderStepped:Connect(function()
        if not part or not part.Parent or not part:IsDescendantOf(workspace) then
            if loopConnection then loopConnection:Disconnect() end
            return
        end
        
        -- Lấy độ lớn âm thanh và chuẩn hóa mượt mà (Không bị giật lắc điên cuồng)
        local loudness = LocalSound.PlaybackLoudness
        local normLoudness = math.clamp(loudness / 280, 0, 1) 
        
        -- Chạy màu cầu vồng mượt mà
        hue = (hue + 1 + (normLoudness * 2)) % 360
        local mainColor = Color3.fromHSV(hue / 360, 1, 1)
        part.Color = mainColor
        
        -- Thân loa lớn đập nhẹ nhàng theo nhịp bass (Co giãn tinh tế, không rung lắc dị hợm)
        local bodyScale = 1 + (normLoudness * 0.12)
        part.Size = Vector3.new(baseSize.X * bodyScale, baseSize.Y * bodyScale, baseSize.Z * bodyScale)
        
        -- Xử lý hiệu ứng 2 màng loa kép co giãn (Đập nhịp) cực nghệ thuật
        for _, item in pairs(SpeakerRings) do
            if item.Part and item.Part.Parent then
                -- Tạo nhịp nhấp nhô nhẹ liên tục để màng loa luôn sống động kể cả lúc nhạc nhỏ
                local wave = math.sin(tick() * 18 + item.Direction * math.pi) * 0.04
                
                -- Kích thước vòng tròn loa mở rộng ra khi Bass đánh (Giới hạn vừa vặn bề mặt)
                local currentRadius = math.clamp(0.65 + (normLoudness * 0.3) + wave, 0.4, 1.1)
                -- Độ dày màng loa nhô ra nhẹ tạo chiều sâu 3D
                local ringThickness = 0.05 + (normLoudness * 0.05)
                
                -- Với Cylinder trong Roblox: Size.X là chiều dài trục, Size.Y và Z là đường kính vòng tròn
                item.Part.Size = Vector3.new(ringThickness, currentRadius, currentRadius)
                
                -- Giữ màng loa luôn dính sát vào mặt thùng loa khi thùng loa phình to thu nhỏ
                local currentZOffset = (part.Size.Z / 2) + (ringThickness / 2) - 0.01
                local currentYOffset = ((item.Direction == 1) and 0.45 or -0.45) * bodyScale
                item.Weld.C0 = CFrame.new(0, currentYOffset, currentZOffset) * CFrame.Angles(0, math.rad(90), 0)
                
                -- Màu màng loa lệch pha nhẹ với thân loa tạo điểm nhấn vòng tròn rõ nét
                local ringHue = (hue + (item.Direction * 30)) % 360
                item.Part.Color = Color3.fromHSV(ringHue / 360, 1, 0.9)
            end
        end
    end)
end

-- TỰ ĐỘNG ĐEO LẠI KHI NHÂN VẬT HỒI SINH
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5) 
    CreateFakeBoombox() 
end)

-- GIAO DIỆN GUI (Giữ nguyên cấu trúc)
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Draggable = true
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local HideBtn = Instance.new("TextButton", MainFrame)
HideBtn.Size = UDim2.new(0, 30, 0, 30)
HideBtn.Position = UDim2.new(0.85, 0, 0.05, 0)
HideBtn.Text = "-"
HideBtn.TextColor3 = Color3.new(1, 1, 1)
HideBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
Instance.new("UICorner", HideBtn)
HideBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.Text = "TP 🎵"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
OpenBtn.Draggable = true
OpenBtn.Active = true
Instance.new("UICorner", OpenBtn)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true end)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(0.8, 0, 0, 30)
Title.Position = UDim2.new(0.05, 0, 0.05, 0)
Title.Text = "🎵 THANH PHÚC MUSIC"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local InputBox = Instance.new("TextBox", MainFrame)
InputBox.Size = UDim2.new(0.9, 0, 0, 40)
InputBox.Position = UDim2.new(0.05, 0, 0.25, 0)
InputBox.PlaceholderText = "Nhập ID nhạc..."
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InputBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", InputBox)

local PlayBtn = Instance.new("TextButton", MainFrame)
PlayBtn.Size = UDim2.new(0.9, 0, 0, 40)
PlayBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
PlayBtn.Text = "PHÁT NHẠC"
PlayBtn.TextColor3 = Color3.new(1, 1, 1)
PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
Instance.new("UICorner", PlayBtn)

PlayBtn.MouseButton1Click:Connect(function()
    local cleanID = InputBox.Text:match("%d+")
    if cleanID then
        LocalSound.SoundId = "rbxassetid://" .. cleanID
        LocalSound:Play()
        CreateFakeBoombox()
        print("Thanh Phuc đã đổi bài thành công! Loa kép dạng tròn Mi 10S cực chất!")
    else
        InputBox.Text = ""
        InputBox.PlaceholderText = "ID không hợp lệ!"
    end
end)

