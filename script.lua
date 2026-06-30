-- (Creator = Thanh Phuc)
-- 💟 Thanh Phuc - Loa Kép Mi 10S Dáng Khối To Đứng Thẳng + Màng Loa Ẩn Đập Bass Uy Lực 💟
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

-- Bộ phát âm thanh chuẩn
local LocalSound = Instance.new("Sound")
LocalSound.Name = "ThanhPhucLocalSound"
LocalSound.Parent = LocalPlayer:WaitForChild("PlayerWorkspace", 5) or workspace
LocalSound.Volume = 3.0 -- Tăng nhẹ Volume để kích bass tốt hơn
LocalSound.Looped = true

-- QUẢN LÝ LOA ĐỨNG VÀ MÀNG LOA TRÒN ẨN
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
    
    -- [THAY ĐỔI THEO ẢNH 1000056629.jpg]: Tạo khối loa to, cao và dày dặn
    local part = Instance.new("Part")
    part.Name = "ThanhPhucChromaBoombox"
    part.Material = Enum.Material.Neon
    part.CanCollide = false
    part.Massless = true
    part.Parent = character
    FakeBoombox = part
    
    -- Kích thước to, cao chuẩn dáng khối đứng trong ảnh mới của bạn
    local baseSize = Vector3.new(2.0, 2.2, 0.9) 
    part.Size = baseSize
    
    -- [FIX THẲNG ĐỨNG]: Đeo loa ngay ngắn, thẳng hoàn toàn, không xoay chéo nữa!
    local weld = Instance.new("Weld")
    weld.Part0 = torso
    weld.Part1 = part
    -- Xoay đúng 180 độ để quay mặt loa ra sau, góc Z và X bằng 0 để loa đứng thẳng tắp
    weld.C0 = CFrame.new(0, 0, 0.85) * CFrame.Angles(0, math.rad(180), 0)
    weld.Parent = part
    
    -- TẠO 2 MÀNG LOA KÉP TRÒN ẨN GỌN GÀNG BÊN TRONG THÂN LOA
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
        
        -- Căn vị trí 2 màng loa đối xứng trên dưới
        local yOffset = (i == 1) and 0.55 or -0.55
        
        -- [TỐI ƯU ẨN BÊN TRONG]: Đẩy vị trí Z vào sâu bên trong thân loa một chút (0.43 -> 0.40) 
        -- giúp màng loa không bị lồi ra ngoài mà nằm ẩn tinh tế bên trong bề mặt
        ringWeld.C0 = CFrame.new(0, yOffset, 0.40) * CFrame.Angles(0, math.rad(90), 0)
        ringWeld.Parent = ring
        
        table.insert(SpeakerRings, {Part = ring, Weld = ringWeld, Direction = i})
    end
    
    -- HIỆU ỨNG CẦU VỒNG + ĐẬP BASS RÕ RÀNG, MẠNH MẼ
    local hue = 0
    loopConnection = RunService.RenderStepped:Connect(function()
        if not part or not part.Parent or not part:IsDescendantOf(workspace) then
            if loopConnection then loopConnection:Disconnect() end
            return
        end
        
        -- Thuật toán nhận bass nhạy và rõ ràng hơn
        local loudness = LocalSound.PlaybackLoudness
        local normLoudness = math.clamp(loudness / 240, 0, 1) -- Hạ ngưỡng xuống 240 để lực đập nảy rõ ràng hơn
        
        -- Chạy màu cầu vồng toàn diện
        hue = (hue + 1 + (normLoudness * 2)) % 360
        local mainColor = Color3.fromHSV(hue / 360, 1, 1)
        part.Color = mainColor
        
        -- [ĐỘ ĐẬP RÕ RÀNG]: Thân loa to đập nảy mạnh mẽ, dứt khoát theo nhịp bass (Scale lên đến 0.22)
        local bodyScale = 1 + (normLoudness * 0.22)
        part.Size = Vector3.new(baseSize.X * bodyScale, baseSize.Y * (1 + normLoudness * 0.15), baseSize.Z * bodyScale)
        
        -- Xử lý màng loa ẩn bên trong co giãn nhịp nhàng cùng thân loa
        for _, item in pairs(SpeakerRings) do
            if item.Part and item.Part.Parent then
                -- Nhịp đập màng loa bên trong
                local wave = math.sin(tick() * 20 + item.Direction * math.pi) * 0.05
                local currentRadius = math.clamp(0.7 + (normLoudness * 0.35) + wave, 0.5, 1.2)
                
                -- Độ dày cực mỏng để ép sát nằm chìm bên trong khối hộp
                local ringThickness = 0.02
                item.Part.Size = Vector3.new(ringThickness, currentRadius, currentRadius)
                
                -- Giữ màng loa ẩn luôn bám theo chuẩn vị trí khi khối loa đập to nhỏ
                local currentZOffset = (part.Size.Z / 2) - 0.02 -- Nằm lùi vào trong bề mặt loa
                local currentYOffset = ((item.Direction == 1) and 0.55 or -0.55) * bodyScale
                item.Weld.C0 = CFrame.new(0, currentYOffset, currentZOffset) * CFrame.Angles(0, math.rad(90), 0)
                
                -- Màu màng loa lệch nhịp cầu vồng tạo hiệu ứng dải loa kép Mi 10S cực đẹp
                local ringHue = (hue + (item.Direction * 25)) % 360
                item.Part.Color = Color3.fromHSV(ringHue / 360, 1, 0.85)
            end
        end
    end)
end

-- TỰ ĐỘNG ĐEO LẠI KHI DIE
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5) 
    CreateFakeBoombox() 
end)

-- GIAO DIỆN GUI (Giữ nguyên cấu trúc gốc của bạn)
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
        print("Thanh Phuc đã kích hoạt loa đứng Mi 10S thành công, Bass đập cực chất!")
    else
        InputBox.Text = ""
        InputBox.PlaceholderText = "ID không hợp lệ!"
    end
end)
