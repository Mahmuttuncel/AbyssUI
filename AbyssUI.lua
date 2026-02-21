--[[
    ABYSS UI LIBRARY
    Açık kaynak, modüler GUI kütüphanesi
    Kullanım: local AbyssUI = loadstring(...)()
]]

local AbyssUI = {}
AbyssUI.__index = AbyssUI

-- Varsayılan tema ayarları
AbyssUI.DefaultConfig = {
    Colors = {
        Background = Color3.fromRGB(25, 25, 35),
        BackgroundSecondary = Color3.fromRGB(35, 35, 45),
        Accent = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200),
        Success = Color3.fromRGB(0, 255, 100),
        Error = Color3.fromRGB(255, 50, 50),
        Warning = Color3.fromRGB(255, 170, 0),
        TabActive = Color3.fromRGB(70, 130, 180),
        TabInactive = Color3.fromRGB(45, 45, 55)
    },
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    AnimationSpeed = 0.3,
    CornerRadius = 12,
    ToggleKey = Enum.KeyCode.RightShift
}

-- Yeni GUI oluşturma
function AbyssUI.new(title, config)
    local self = setmetatable({}, AbyssUI)
    
    -- Config birleştirme
    self.Config = {}
    for k, v in pairs(AbyssUI.DefaultConfig) do
        self.Config[k] = config and config[k] or v
    end
    
    -- Parent belirleme (Executor uyumluluğu)
    local success, result = pcall(function()
        return game:GetService("CoreGui")
    end)
    self.Parent = success and result or game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Ana ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "AbyssUI_" .. (title or "Menu")
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = self.Parent
    
    -- Toggle Butonu
    self.ToggleBtn = self:CreateToggleButton()
    
    -- Ana Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 500, 0, 350)
    self.MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    self.MainFrame.BackgroundColor3 = self.Config.Colors.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Visible = false
    self.MainFrame.Parent = self.ScreenGui
    
    -- Yuvarlatılmış köşeler
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.Config.CornerRadius)
    corner.Parent = self.MainFrame
    
    -- Gölge
    self:CreateShadow(self.MainFrame)
    
    -- Üst Bar
    self.TopBar = self:CreateTopBar(title or "Abyss UI")
    
    -- İçerik Container
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "Content"
    self.ContentContainer.Size = UDim2.new(1, 0, 1, -40)
    self.ContentContainer.Position = UDim2.new(0, 0, 0, 40)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.Parent = self.MainFrame
    
    -- Yan Menü
    self.SideMenu = Instance.new("Frame")
    self.SideMenu.Name = "SideMenu"
    self.SideMenu.Size = UDim2.new(0, 120, 1, 0)
    self.SideMenu.BackgroundColor3 = self.Config.Colors.BackgroundSecondary
    self.SideMenu.BorderSizePixel = 0
    self.SideMenu.Parent = self.ContentContainer
    
    local sideCorner = Instance.new("UICorner")
    sideCorner.CornerRadius = UDim.new(0, 0)
    sideCorner.Parent = self.SideMenu
    
    -- Sayfa Alanı
    self.PageArea = Instance.new("Frame")
    self.PageArea.Name = "PageArea"
    self.PageArea.Size = UDim2.new(1, -120, 1, 0)
    self.PageArea.Position = UDim2.new(0, 120, 0, 0)
    self.PageArea.BackgroundTransparency = 1
    self.PageArea.Parent = self.ContentContainer
    
    -- Sekme yönetimi
    self.Tabs = {}
    self.CurrentTab = nil
    self.IsOpen = false
    
    -- Sürükleme özelliği
    self:MakeDraggable(self.TopBar, self.MainFrame)
    
    -- Toggle butonu sürükleme
    self:MakeDraggable(self.ToggleBtn, self.ToggleBtn)
    
    -- Toggle fonksiyonu
    self.ToggleBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Kapatma butonu
    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    return self
end

-- Toggle Butonu Oluşturma
function AbyssUI:CreateToggleButton()
    local btn = Instance.new("TextButton")
    btn.Name = "ToggleButton"
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(0, 20, 1, -70)
    btn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    btn.Text = ""
    btn.Parent = self.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "☰"
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.TextSize = 24
    icon.Font = self.Config.Font
    icon.Parent = btn
    
    -- Gölge
    self:CreateShadow(btn, 20)
    
    return btn
end

-- Gölge Efekti
function AbyssUI:CreateShadow(parent, size)
    size = size or 40
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, size, 1, size)
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Parent = parent
    return shadow
end

-- Üst Bar Oluşturma
function AbyssUI:CreateTopBar(title)
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = self.Config.Colors.BackgroundSecondary
    topBar.BorderSizePixel = 0
    topBar.Parent = self.MainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.Config.CornerRadius)
    corner.Parent = topBar
    
    -- Başlık
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = self.Config.Colors.Text
    titleLabel.TextSize = 16
    titleLabel.Font = self.Config.Font
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    -- Kapatma butonu
    self.CloseBtn = Instance.new("TextButton")
    self.CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    self.CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
    self.CloseBtn.BackgroundColor3 = self.Config.Colors.Error
    self.CloseBtn.Text = ""
    self.CloseBtn.Parent = topBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = self.CloseBtn
    
    local closeIcon = Instance.new("TextLabel")
    closeIcon.Size = UDim2.new(1, 0, 1, 0)
    closeIcon.BackgroundTransparency = 1
    closeIcon.Text = "✕"
    closeIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeIcon.TextSize = 18
    closeIcon.Font = self.Config.Font
    closeIcon.Parent = self.CloseBtn
    
    -- Hover efektleri
    self.CloseBtn.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(self.CloseBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        }):Play()
    end)
    
    self.CloseBtn.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(self.CloseBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Config.Colors.Error
        }):Play()
    end)
    
    return topBar
end

-- Sürüklenebilir Yapma
function AbyssUI:MakeDraggable(handle, object)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                        input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Aç/Kapa
function AbyssUI:Toggle()
    self.IsOpen = not self.IsOpen
    local TweenService = game:GetService("TweenService")
    
    if self.IsOpen then
        self.MainFrame.Visible = true
        TweenService:Create(self.MainFrame, TweenInfo.new(self.Config.AnimationSpeed, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 500, 0, 350),
            Position = UDim2.new(0.5, -250, 0.5, -175)
        }):Play()
        
        self.ToggleBtn:FindFirstChildOfClass("TextLabel").Text = "✕"
        self.ToggleBtn.BackgroundColor3 = self.Config.Colors.Error
    else
        TweenService:Create(self.MainFrame, TweenInfo.new(self.Config.AnimationSpeed, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        task.wait(self.Config.AnimationSpeed)
        self.MainFrame.Visible = false
        self.ToggleBtn:FindFirstChildOfClass("TextLabel").Text = "☰"
        self.ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    end
end

-- Yeni Sekme Ekleme
function AbyssUI:AddTab(name, icon)
    local tab = {}
    tab.Name = name
    tab.Icon = icon or "📄"
    
    -- Sekme butonu
    tab.Button = Instance.new("TextButton")
    tab.Button.Name = name .. "Tab"
    tab.Button.Size = UDim2.new(1, -10, 0, 35)
    tab.Button.Position = UDim2.new(0, 5, 0, 5 + (#self.Tabs * 40))
    tab.Button.BackgroundColor3 = self.Config.Colors.TabInactive
    tab.Button.Text = tab.Icon .. " " .. name
    tab.Button.TextColor3 = self.Config.Colors.TextSecondary
    tab.Button.TextSize = 12
    tab.Button.Font = self.Config.Font
    tab.Button.Parent = self.SideMenu
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = tab.Button
    
    -- Sayfa
    tab.Page = Instance.new("ScrollingFrame")
    tab.Page.Name = name .. "Page"
    tab.Page.Size = UDim2.new(1, -20, 1, -20)
    tab.Page.Position = UDim2.new(0, 10, 0, 10)
    tab.Page.BackgroundTransparency = 1
    tab.Page.ScrollBarThickness = 4
    tab.Page.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    tab.Page.Visible = false
    tab.Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab.Page.Parent = self.PageArea
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = tab.Page
    
    -- Otomatik canvas size güncelleme
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.Page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tıklama olayı
    tab.Button.MouseButton1Click:Connect(function()
        self:SwitchTab(name)
    end)
    
    -- Hover efektleri
    tab.Button.MouseEnter:Connect(function()
        if self.CurrentTab ~= name then
            game:GetService("TweenService"):Create(tab.Button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            }):Play()
        end
    end)
    
    tab.Button.MouseLeave:Connect(function()
        if self.CurrentTab ~= name then
            game:GetService("TweenService"):Create(tab.Button, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Config.Colors.TabInactive
            }):Play()
        end
    end)
    
    table.insert(self.Tabs, tab)
    
    -- İlk sekme ise otomatik aç
    if #self.Tabs == 1 then
        self:SwitchTab(name)
    end
    
    return tab
end

-- Sekme Değiştirme
function AbyssUI:SwitchTab(tabName)
    local TweenService = game:GetService("TweenService")
    
    for _, tab in ipairs(self.Tabs) do
        if tab.Name == tabName then
            self.CurrentTab = tabName
            tab.Page.Visible = true
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Config.Colors.TabActive,
                TextColor3 = self.Config.Colors.Text
            }):Play()
        else
            tab.Page.Visible = false
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {
                BackgroundColor3 = self.Config.Colors.TabInactive,
                TextColor3 = self.Config.Colors.TextSecondary
            }):Play()
        end
    end
end

-- Buton Ekleme
function AbyssUI:AddButton(tab, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = self.Config.Colors.Accent
    btn.Text = text
    btn.TextColor3 = self.Config.Colors.Text
    btn.TextSize = 14
    btn.Font = self.Config.Font
    btn.Parent = tab.Page
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    -- Hover efektleri
    btn.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0, 140, 220)
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Config.Colors.Accent
        }):Play()
    end)
    
    btn.MouseButton1Click:Connect(callback)
    
    return btn
end

-- Toggle Ekleme
function AbyssUI:AddToggle(tab, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = self.Config.Colors.BackgroundSecondary
    frame.BorderSizePixel = 0
    frame.Parent = tab.Page
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.Config.Colors.Text
    label.Font = self.Config.Font
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 26)
    toggleBtn.Position = UDim2.new(1, -60, 0.5, -13)
    toggleBtn.BackgroundColor3 = default and self.Config.Colors.Success or self.Config.Colors.Error
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.TextColor3 = self.Config.Colors.Text
    toggleBtn.Font = self.Config.Font
    toggleBtn.TextSize = 12
    toggleBtn.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn
    
    local state = default
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and self.Config.Colors.Success or self.Config.Colors.Error
        toggleBtn.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end)
    
    return {
        Frame = frame,
        Button = toggleBtn,
        GetState = function() return state end,
        SetState = function(newState)
            state = newState
            toggleBtn.BackgroundColor3 = state and self.Config.Colors.Success or self.Config.Colors.Error
            toggleBtn.Text = state and "ON" or "OFF"
        end
    }
end

-- Slider Ekleme
function AbyssUI:AddSlider(tab, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = self.Config.Colors.BackgroundSecondary
    frame.BorderSizePixel = 0
    frame.Parent = tab.Page
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = self.Config.Colors.Text
    label.Font = self.Config.Font
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 8)
    sliderBg.Position = UDim2.new(0, 10, 0, 35)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = self.Config.Colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local dragging = false
    
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (pos * (max - min)))
        fill.Size = UDim2.new(pos, 0, 1, 0)
        label.Text = text .. ": " .. value
        if callback then callback(value) end
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    
    sliderBg.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return frame
end

-- Label Ekleme
function AbyssUI:AddLabel(tab, text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or self.Config.Colors.TextSecondary
    label.Font = self.Config.Font
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = tab.Page
    
    return label
end

-- Bildirim (Notification)
function AbyssUI:Notify(title, message, duration)
    duration = duration or 3
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 300, 0, 80)
    notif.Position = UDim2.new(1, 20, 1, -100)
    notif.BackgroundColor3 = self.Config.Colors.Background
    notif.BorderSizePixel = 0
    notif.Parent = self.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = notif
    
    self:CreateShadow(notif, 30)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = self.Config.Colors.Accent
    titleLabel.Font = self.Config.Font
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif
    
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -20, 0, 45)
    msgLabel.Position = UDim2.new(0, 10, 0, 30)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = self.Config.Colors.Text
    msgLabel.Font = self.Config.Font
    msgLabel.TextSize = 13
    msgLabel.TextWrapped = true
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Parent = notif
    
    -- Animasyon
    local TweenService = game:GetService("TweenService")
    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
        Position = UDim2.new(1, -320, 1, -100)
    }):Play()
    
    task.wait(duration)
    
    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
        Position = UDim2.new(1, 20, 1, -100)
    }):Play()
    
    task.wait(0.5)
    notif:Destroy()
end

-- Yıkıcı (Destructor)
function AbyssUI:Destroy()
    self.ScreenGui:Destroy()
    if self.espScreenGui then
        self.espScreenGui:Destroy()
    end
end

return AbyssUI
