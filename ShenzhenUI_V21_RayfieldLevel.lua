--// SHENZHEN UI LIBRARY V21 - RAYFIELD LEVEL
--// Clean • Smooth • Advanced UX • Professional
--// Features: Spring Animations, Glassmorphism, Full Component Set, Notifications

local Library = {}
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

--// UTILITY FUNCTIONS
local function Tween(obj, props, info)
    local tweenInfo = info or TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(obj, tweenInfo, props):Play()
end

local function SpringTween(obj, props, damping, frequency)
    local springInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(obj, springInfo, props):Play()
end

local function Ripple(button, x, y)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y)
    ripple.Parent = button
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Tween(ripple, {Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1}, 
        TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
    
    task.delay(0.6, function()
        ripple:Destroy()
    end)
end

local function CreateShadow(parent, intensity)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 1 - (intensity or 0.4)
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

local function CreateGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    })
    gradient.Rotation = rotation or 45
    gradient.Parent = parent
    return gradient
end

--// THEMES
local Themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 30),
        Secondary = Color3.fromRGB(35, 35, 42),
        Tertiary = Color3.fromRGB(45, 45, 55),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentLight = Color3.fromRGB(120, 140, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(255, 180, 80),
        Error = Color3.fromRGB(255, 100, 100),
        Transparency = 0.05
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 250),
        Secondary = Color3.fromRGB(235, 235, 240),
        Tertiary = Color3.fromRGB(225, 225, 230),
        Accent = Color3.fromRGB(0, 120, 255),
        AccentLight = Color3.fromRGB(60, 160, 255),
        Text = Color3.fromRGB(30, 30, 35),
        TextDark = Color3.fromRGB(100, 100, 110),
        Success = Color3.fromRGB(60, 180, 100),
        Warning = Color3.fromRGB(240, 160, 60),
        Error = Color3.fromRGB(220, 80, 80),
        Transparency = 0.1
    },
    Midnight = {
        Background = Color3.fromRGB(15, 15, 25),
        Secondary = Color3.fromRGB(25, 25, 40),
        Tertiary = Color3.fromRGB(35, 35, 55),
        Accent = Color3.fromRGB(140, 100, 255),
        AccentLight = Color3.fromRGB(170, 140, 255),
        Text = Color3.fromRGB(240, 240, 255),
        TextDark = Color3.fromRGB(160, 160, 180),
        Success = Color3.fromRGB(100, 220, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 120, 120),
        Transparency = 0.03
    },
    Ocean = {
        Background = Color3.fromRGB(20, 30, 40),
        Secondary = Color3.fromRGB(30, 45, 60),
        Tertiary = Color3.fromRGB(40, 60, 80),
        Accent = Color3.fromRGB(0, 200, 200),
        AccentLight = Color3.fromRGB(50, 230, 230),
        Text = Color3.fromRGB(230, 245, 255),
        TextDark = Color3.fromRGB(150, 170, 190),
        Success = Color3.fromRGB(80, 220, 160),
        Warning = Color3.fromRGB(255, 190, 90),
        Error = Color3.fromRGB(255, 100, 100),
        Transparency = 0.05
    }
}

--// NOTIFICATION SYSTEM
local NotificationQueue = {}
local NotificationActive = false

local function ShowNotification(title, message, notifType, duration)
    local theme = Themes.Dark
    duration = duration or 3
    notifType = notifType or "Info"
    
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "ShenzhenNotification"
    notifGui.Parent = CoreGui
    notifGui.DisplayOrder = 999999
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 320, 0, 80)
    container.Position = UDim2.new(1, 20, 0.85, 0)
    container.BackgroundColor3 = theme.Secondary
    container.BackgroundTransparency = theme.Transparency
    container.BorderSizePixel = 0
    container.Parent = notifGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = container
    
    CreateShadow(container, 0.5)
    
    -- Icon
    local iconColors = {
        Info = theme.Accent,
        Success = theme.Success,
        Warning = theme.Warning,
        Error = theme.Error
    }
    
    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 50, 1, 0)
    iconFrame.BackgroundColor3 = iconColors[notifType] or theme.Accent
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = container
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 12)
    iconCorner.Parent = iconFrame
    
    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.new(1, 0, 1, 0)
    iconText.BackgroundTransparency = 1
    iconText.Text = notifType == "Success" and "✓" or notifType == "Error" and "✕" or notifType == "Warning" and "!" or "i"
    iconText.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconText.Font = Enum.Font.GothamBold
    iconText.TextSize = 28
    iconText.Parent = iconFrame
    
    -- Content
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -70, 0, 25)
    titleLabel.Position = UDim2.new(0, 60, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = container
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -70, 0, 40)
    messageLabel.Position = UDim2.new(0, 60, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = theme.TextDark
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 13
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.Parent = container
    
    -- Progress bar
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, -3)
    progressBar.BackgroundColor3 = iconColors[notifType] or theme.Accent
    progressBar.BorderSizePixel = 0
    progressBar.Parent = container
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 2)
    progressCorner.Parent = progressBar
    
    -- Animation in
    Tween(container, {Position = UDim2.new(1, -340, 0.85, 0)}, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
    Tween(progressBar, {Size = UDim2.new(0, 0, 0, 3)}, TweenInfo.new(duration, Enum.EasingStyle.Linear))
    
    task.delay(duration, function()
        Tween(container, {Position = UDim2.new(1, 20, 0.85, 0)}, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In))
        task.delay(0.4, function()
            notifGui:Destroy()
        end)
    end)
end

--// MAIN WINDOW CREATION
function Library:CreateWindow(config)
    config = config or {}
    local Lib = {}
    Lib.Theme = Themes[config.Theme or "Dark"]
    Lib.Key = config.Key or Enum.KeyCode.RightControl
    Lib.Toggled = true
    Lib.Minimized = false
    Lib.Tabs = {}
    Lib.CurrentTab = nil
    
    local theme = Lib.Theme
    
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ShenzhenV21"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 600, 0, 420)
    Main.Position = UDim2.new(0.5, -300, 0.5, -210)
    Main.BackgroundColor3 = theme.Background
    Main.BackgroundTransparency = theme.Transparency
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = Main
    
    CreateShadow(Main, 0.6)
    
    -- Glassmorphism overlay
    local GlassOverlay = Instance.new("Frame")
    GlassOverlay.Name = "GlassOverlay"
    GlassOverlay.Size = UDim2.new(1, 0, 1, 0)
    GlassOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GlassOverlay.BackgroundTransparency = 0.95
    GlassOverlay.BorderSizePixel = 0
    GlassOverlay.ZIndex = 0
    GlassOverlay.Parent = Main
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 55)
    Header.BackgroundColor3 = theme.Secondary
    Header.BackgroundTransparency = 0.3
    Header.BorderSizePixel = 0
    Header.Parent = Main
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 16)
    HeaderCorner.Parent = Header
    
    local HeaderBottom = Instance.new("Frame")
    HeaderBottom.Size = UDim2.new(1, 0, 0, 20)
    HeaderBottom.Position = UDim2.new(0, 0, 1, -20)
    HeaderBottom.BackgroundColor3 = theme.Secondary
    HeaderBottom.BackgroundTransparency = 0.3
    HeaderBottom.BorderSizePixel = 0
    HeaderBottom.Parent = Header
    
    -- Logo/Title
    local LogoContainer = Instance.new("Frame")
    LogoContainer.Size = UDim2.new(0, 40, 0, 40)
    LogoContainer.Position = UDim2.new(0, 12, 0, 7)
    LogoContainer.BackgroundColor3 = theme.Accent
    LogoContainer.BorderSizePixel = 0
    LogoContainer.Parent = Header
    
    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 10)
    LogoCorner.Parent = LogoContainer
    
    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = "S"
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextSize = 20
    LogoText.Parent = LogoContainer
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 200, 0, 30)
    Title.Position = UDim2.new(0, 62, 0, 12)
    Title.BackgroundTransparency = 1
    Title.Text = config.Title or "SHENZHEN V21"
    Title.TextColor3 = theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(0, 200, 0, 18)
    Subtitle.Position = UDim2.new(0, 62, 0, 32)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = config.SubTitle or "Premium UI Library"
    Subtitle.TextColor3 = theme.TextDark
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 12
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = Header
    
    -- Window Controls
    local Controls = Instance.new("Frame")
    Controls.Size = UDim2.new(0, 90, 0, 30)
    Controls.Position = UDim2.new(1, -100, 0, 12)
    Controls.BackgroundTransparency = 1
    Controls.Parent = Header
    
    local function CreateControlButton(text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 26, 0, 26)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = Controls
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = color:Lerp(Color3.fromRGB(255,255,255), 0.2)}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = color}, 0.15)
        end)
        
        btn.MouseButton1Click:Connect(function()
            SpringTween(btn, {Size = UDim2.new(0, 22, 0, 22)}, 0.5, 8)
            task.delay(0.1, function()
                Tween(btn, {Size = UDim2.new(0, 26, 0, 26)}, 0.2)
            end)
            if callback then callback() end
        end)
        
        return btn
    end
    
    local MinimizeBtn = CreateControlButton("−", Color3.fromRGB(80, 180, 120), function()
        Lib.Minimized = not Lib.Minimized
        local targetSize = Lib.Minimized and UDim2.new(0, 600, 0, 55) or UDim2.new(0, 600, 0, 420)
        Tween(Main, {Size = targetSize}, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
    end)
    MinimizeBtn.Position = UDim2.new(0, 0, 0, 2)
    
    local CloseBtn = CreateControlButton("×", Color3.fromRGB(220, 80, 80), function()
        Tween(Main, {Size = UDim2.new(0, 600, 0, 0)}, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In))
        task.delay(0.3, function()
            ScreenGui:Destroy()
        end)
    end)
    CloseBtn.Position = UDim2.new(0, 60, 0, 2)
    
    -- Container
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Position = UDim2.new(0, 10, 0, 60)
    Container.Size = UDim2.new(1, -20, 1, -65)
    Container.BackgroundTransparency = 1
    Container.Parent = Main
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = theme.Secondary
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Container
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 12)
    SidebarCorner.Parent = Sidebar
    
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabList"
    TabList.Size = UDim2.new(1, -10, 1, -10)
    TabList.Position = UDim2.new(0, 5, 0, 5)
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 2
    TabList.ScrollBarImageColor3 = theme.Accent
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.Parent = Sidebar
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.Parent = TabList
    
    -- Content Area
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Position = UDim2.new(0, 160, 0, 0)
    Content.Size = UDim2.new(1, -160, 1, 0)
    Content.BackgroundColor3 = theme.Secondary
    Content.BackgroundTransparency = 0.5
    Content.BorderSizePixel = 0
    Content.ClipsDescendants = true
    Content.Parent = Container
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 12)
    ContentCorner.Parent = Content
    
    -- Drag System (Smooth)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragConnection = nil
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragConnection = input
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if input == dragConnection and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
            Main.Position = newPos
        end
    end)
    
    -- Intro Animation
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.Visible = false
    
    task.spawn(function()
        task.wait(0.1)
        Main.Visible = true
        SpringTween(Main, {Size = UDim2.new(0, 600, 0, 420)})
    end)
    
    -- TAB CREATION
    function Lib:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local Tab = {}
        Tab.Name = tabConfig.Name or "Tab"
        Tab.Icon = tabConfig.Icon or ""
        
        -- Tab Button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = Tab.Name .. "Tab"
        TabBtn.Size = UDim2.new(1, 0, 0, 38)
        TabBtn.BackgroundColor3 = theme.Tertiary
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabList
        
        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 8)
        TabBtnCorner.Parent = TabBtn
        
        local TabIndicator = Instance.new("Frame")
        TabIndicator.Size = UDim2.new(0, 3, 0, 20)
        TabIndicator.Position = UDim2.new(0, 0, 0.5, -10)
        TabIndicator.BackgroundColor3 = theme.Accent
        TabIndicator.BorderSizePixel = 0
        TabIndicator.Visible = false
        TabIndicator.Parent = TabBtn
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 2)
        IndicatorCorner.Parent = TabIndicator
        
        local TabIcon = Instance.new("TextLabel")
        TabIcon.Size = UDim2.new(0, 24, 0, 24)
        TabIcon.Position = UDim2.new(0, 10, 0.5, -12)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Text = Tab.Icon
        TabIcon.TextColor3 = theme.TextDark
        TabIcon.Font = Enum.Font.Gotham
        TabIcon.TextSize = 14
        TabIcon.Parent = TabBtn
        
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -44, 1, 0)
        TabLabel.Position = UDim2.new(0, 38, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = Tab.Name
        TabLabel.TextColor3 = theme.TextDark
        TabLabel.Font = Enum.Font.GothamSemibold
        TabLabel.TextSize = 13
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabBtn
        
        -- Tab Page
        local Page = Instance.new("ScrollingFrame")
        Page.Name = Tab.Name .. "Page"
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = theme.Accent
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Visible = false
        Page.Parent = Content
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.Parent = Page
        
        -- Tab Selection Logic
        TabBtn.MouseButton1Click:Connect(function()
            Ripple(TabBtn, UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)
            
            for _, t in pairs(Lib.Tabs) do
                t.Page.Visible = false
                Tween(t.Button, {BackgroundTransparency = 1}, 0.2)
                Tween(t.Indicator, {BackgroundTransparency = 1}, 0.2)
                Tween(t.Icon, {TextColor3 = theme.TextDark}, 0.2)
                Tween(t.Label, {TextColor3 = theme.TextDark}, 0.2)
                t.Indicator.Visible = false
            end
            
            Page.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.7}, 0.2)
            TabIndicator.Visible = true
            Tween(TabIndicator, {BackgroundTransparency = 0}, 0.2)
            Tween(TabIcon, {TextColor3 = theme.Accent}, 0.2)
            Tween(TabLabel, {TextColor3 = theme.Text}, 0.2)
            
            Lib.CurrentTab = Tab
        end)
        
        TabBtn.MouseEnter:Connect(function()
            if Lib.CurrentTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 0.85}, 0.15)
            end
        end)
        
        TabBtn.MouseLeave:Connect(function()
            if Lib.CurrentTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 1}, 0.15)
            end
        end)
        
        Tab.Button = TabBtn
        Tab.Indicator = TabIndicator
        Tab.Icon = TabIcon
        Tab.Label = TabLabel
        Tab.Page = Page
        table.insert(Lib.Tabs, Tab)
        
        -- Auto-select first tab
        if #Lib.Tabs == 1 then
            task.delay(0.3, function()
                TabBtn.MouseButton1Click:Fire()
            end)
        end
        
        -- Update canvas size
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)
        
        TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabList.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- ELEMENTS
        local Elements = {}
        
        -- BUTTON
        function Elements:CreateButton(config)
            config = config or {}
            local text = config.Name or config.Text or "Button"
            local callback = config.Callback or function() end
            
            local BtnFrame = Instance.new("Frame")
            BtnFrame.Size = UDim2.new(1, 0, 0, 42)
            BtnFrame.BackgroundTransparency = 1
            BtnFrame.Parent = Page
            
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundColor3 = theme.Tertiary
            Btn.Text = ""
            Btn.AutoButtonColor = false
            Btn.Parent = BtnFrame
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 10)
            BtnCorner.Parent = Btn
            
            local BtnText = Instance.new("TextLabel")
            BtnText.Size = UDim2.new(1, -20, 1, 0)
            BtnText.Position = UDim2.new(0, 15, 0, 0)
            BtnText.BackgroundTransparency = 1
            BtnText.Text = text
            BtnText.TextColor3 = theme.Text
            BtnText.Font = Enum.Font.GothamSemibold
            BtnText.TextSize = 14
            BtnText.TextXAlignment = Enum.TextXAlignment.Left
            BtnText.Parent = Btn
            
            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 30, 1, 0)
            Arrow.Position = UDim2.new(1, -35, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "→"
            Arrow.TextColor3 = theme.TextDark
            Arrow.Font = Enum.Font.Gotham
            Arrow.TextSize = 16
            Arrow.Parent = Btn
            
            Btn.MouseEnter:Connect(function()
                Tween(Btn, {BackgroundColor3 = theme.Accent}, 0.2)
                Tween(BtnText, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
                Tween(Arrow, {TextColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -30, 0, 0)}, 0.2)
            end)
            
            Btn.MouseLeave:Connect(function()
                Tween(Btn, {BackgroundColor3 = theme.Tertiary}, 0.2)
                Tween(BtnText, {TextColor3 = theme.Text}, 0.2)
                Tween(Arrow, {TextColor3 = theme.TextDark, Position = UDim2.new(1, -35, 0, 0)}, 0.2)
            end)
            
            Btn.MouseButton1Down:Connect(function()
                SpringTween(Btn, {Size = UDim2.new(0.98, 0, 0.95, 0)})
            end)
            
            Btn.MouseButton1Up:Connect(function()
                SpringTween(Btn, {Size = UDim2.new(1, 0, 1, 0)})
            end)
            
            Btn.MouseButton1Click:Connect(function()
                Ripple(Btn, UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)
                callback()
            end)
            
            return Btn
        end
        
        -- TOGGLE
        function Elements:CreateToggle(config)
            config = config or {}
            local text = config.Name or config.Text or "Toggle"
            local default = config.Default or false
            local callback = config.Callback or function() end
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 42)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.Parent = Page
            
            local ToggleBg = Instance.new("Frame")
            ToggleBg.Size = UDim2.new(1, 0, 1, 0)
            ToggleBg.BackgroundColor3 = theme.Tertiary
            ToggleBg.Parent = ToggleFrame
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 10)
            ToggleCorner.Parent = ToggleBg
            
            local ToggleText = Instance.new("TextLabel")
            ToggleText.Size = UDim2.new(1, -80, 1, 0)
            ToggleText.Position = UDim2.new(0, 15, 0, 0)
            ToggleText.BackgroundTransparency = 1
            ToggleText.Text = text
            ToggleText.TextColor3 = theme.Text
            ToggleText.Font = Enum.Font.GothamSemibold
            ToggleText.TextSize = 14
            ToggleText.TextXAlignment = Enum.TextXAlignment.Left
            ToggleText.Parent = ToggleBg
            
            -- Toggle Switch
            local SwitchFrame = Instance.new("Frame")
            SwitchFrame.Size = UDim2.new(0, 50, 0, 26)
            SwitchFrame.Position = UDim2.new(1, -62, 0.5, -13)
            SwitchFrame.BackgroundColor3 = theme.Secondary
            SwitchFrame.Parent = ToggleBg
            
            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = SwitchFrame
            
            local SwitchKnob = Instance.new("Frame")
            SwitchKnob.Size = UDim2.new(0, 20, 0, 20)
            SwitchKnob.Position = UDim2.new(0, 3, 0.5, -10)
            SwitchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SwitchKnob.Parent = SwitchFrame
            
            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = SwitchKnob
            
            local State = default
            
            local function UpdateToggle()
                if State then
                    Tween(SwitchFrame, {BackgroundColor3 = theme.Accent}, 0.25)
                    Tween(SwitchKnob, {Position = UDim2.new(0, 27, 0.5, -10)}, 0.25)
                else
                    Tween(SwitchFrame, {BackgroundColor3 = theme.Secondary}, 0.25)
                    Tween(SwitchKnob, {Position = UDim2.new(0, 3, 0.5, -10)}, 0.25)
                end
                callback(State)
            end
            
            if State then
                SwitchFrame.BackgroundColor3 = theme.Accent
                SwitchKnob.Position = UDim2.new(0, 27, 0.5, -10)
            end
            
            local ClickArea = Instance.new("TextButton")
            ClickArea.Size = UDim2.new(1, 0, 1, 0)
            ClickArea.BackgroundTransparency = 1
            ClickArea.Text = ""
            ClickArea.Parent = ToggleBg
            
            ClickArea.MouseButton1Click:Connect(function()
                State = not State
                UpdateToggle()
            end)
            
            ClickArea.MouseEnter:Connect(function()
                Tween(ToggleBg, {BackgroundColor3 = theme.Accent:Lerp(theme.Tertiary, 0.8)}, 0.15)
            end)
            
            ClickArea.MouseLeave:Connect(function()
                Tween(ToggleBg, {BackgroundColor3 = theme.Tertiary}, 0.15)
            end)
            
            return {
                Set = function(value)
                    State = value
                    UpdateToggle()
                end,
                Get = function()
                    return State
                end
            }
        end
        
        -- SLIDER
        function Elements:CreateSlider(config)
            config = config or {}
            local text = config.Name or config.Text or "Slider"
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or min
            local suffix = config.Suffix or ""
            local callback = config.Callback or function() end
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 60)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.Parent = Page
            
            local SliderBg = Instance.new("Frame")
            SliderBg.Size = UDim2.new(1, 0, 1, 0)
            SliderBg.BackgroundColor3 = theme.Tertiary
            SliderBg.Parent = SliderFrame
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 10)
            SliderCorner.Parent = SliderBg
            
            local SliderText = Instance.new("TextLabel")
            SliderText.Size = UDim2.new(0.5, 0, 0, 25)
            SliderText.Position = UDim2.new(0, 15, 0, 8)
            SliderText.BackgroundTransparency = 1
            SliderText.Text = text
            SliderText.TextColor3 = theme.Text
            SliderText.Font = Enum.Font.GothamSemibold
            SliderText.TextSize = 14
            SliderText.TextXAlignment = Enum.TextXAlignment.Left
            SliderText.Parent = SliderBg
            
            local ValueText = Instance.new("TextLabel")
            ValueText.Size = UDim2.new(0, 60, 0, 25)
            ValueText.Position = UDim2.new(1, -70, 0, 8)
            ValueText.BackgroundColor3 = theme.Secondary
            ValueText.Text = tostring(default) .. suffix
            ValueText.TextColor3 = theme.Accent
            ValueText.Font = Enum.Font.GothamBold
            ValueText.TextSize = 13
            ValueText.Parent = SliderBg
            
            local ValueCorner = Instance.new("UICorner")
            ValueCorner.CornerRadius = UDim.new(0, 6)
            ValueCorner.Parent = ValueText
            
            -- Slider Bar
            local BarFrame = Instance.new("Frame")
            BarFrame.Size = UDim2.new(1, -30, 0, 8)
            BarFrame.Position = UDim2.new(0, 15, 0, 38)
            BarFrame.BackgroundColor3 = theme.Secondary
            BarFrame.BorderSizePixel = 0
            BarFrame.Parent = SliderBg
            
            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(1, 0)
            BarCorner.Parent = BarFrame
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = theme.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = BarFrame
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill
            
            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 18, 0, 18)
            Knob.Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.Parent = BarFrame
            
            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = Knob
            
            local KnobShadow = CreateShadow(Knob, 0.3)
            
            local dragging = false
            
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - BarFrame.AbsolutePosition.X) / BarFrame.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * pos)
                
                Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.05)
                Tween(Knob, {Position = UDim2.new(pos, -9, 0.5, -9)}, 0.05)
                ValueText.Text = tostring(value) .. suffix
                callback(value)
            end
            
            BarFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateSlider(input)
                end
            end)
            
            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UIS.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
            
            Knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)
            
            return {
                Set = function(value)
                    local pos = (value - min) / (max - min)
                    Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.2)
                    Tween(Knob, {Position = UDim2.new(pos, -9, 0.5, -9)}, 0.2)
                    ValueText.Text = tostring(value) .. suffix
                    callback(value)
                end,
                Get = function()
                    return tonumber(ValueText.Text:gsub(suffix, ""))
                end
            }
        end
        
        -- TEXTBOX
        function Elements:CreateTextBox(config)
            config = config or {}
            local text = config.Name or config.Text or "TextBox"
            local placeholder = config.Placeholder or "Enter text..."
            local default = config.Default or ""
            local callback = config.Callback or function() end
            
            local BoxFrame = Instance.new("Frame")
            BoxFrame.Size = UDim2.new(1, 0, 0, 75)
            BoxFrame.BackgroundTransparency = 1
            BoxFrame.Parent = Page
            
            local BoxBg = Instance.new("Frame")
            BoxBg.Size = UDim2.new(1, 0, 1, 0)
            BoxBg.BackgroundColor3 = theme.Tertiary
            BoxBg.Parent = BoxFrame
            
            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 10)
            BoxCorner.Parent = BoxBg
            
            local BoxText = Instance.new("TextLabel")
            BoxText.Size = UDim2.new(1, -20, 0, 25)
            BoxText.Position = UDim2.new(0, 15, 0, 8)
            BoxText.BackgroundTransparency = 1
            BoxText.Text = text
            BoxText.TextColor3 = theme.Text
            BoxText.Font = Enum.Font.GothamSemibold
            BoxText.TextSize = 14
            BoxText.TextXAlignment = Enum.TextXAlignment.Left
            BoxText.Parent = BoxBg
            
            local InputFrame = Instance.new("Frame")
            InputFrame.Size = UDim2.new(1, -20, 0, 32)
            InputFrame.Position = UDim2.new(0, 10, 0, 35)
            InputFrame.BackgroundColor3 = theme.Secondary
            InputFrame.BorderSizePixel = 0
            InputFrame.Parent = BoxBg
            
            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 8)
            InputCorner.Parent = InputFrame
            
            local InputBox = Instance.new("TextBox")
            InputBox.Size = UDim2.new(1, -16, 1, 0)
            InputBox.Position = UDim2.new(0, 8, 0, 0)
            InputBox.BackgroundTransparency = 1
            InputBox.Text = default
            InputBox.PlaceholderText = placeholder
            InputBox.TextColor3 = theme.Text
            InputBox.PlaceholderColor3 = theme.TextDark
            InputBox.Font = Enum.Font.Gotham
            InputBox.TextSize = 13
            InputBox.ClearTextOnFocus = false
            InputBox.Parent = InputFrame
            
            local FocusLine = Instance.new("Frame")
            FocusLine.Size = UDim2.new(0, 0, 0, 2)
            FocusLine.Position = UDim2.new(0.5, 0, 1, -2)
            FocusLine.BackgroundColor3 = theme.Accent
            FocusLine.BorderSizePixel = 0
            FocusLine.Parent = InputFrame
            
            InputBox.Focused:Connect(function()
                Tween(FocusLine, {Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2)}, 0.25)
            end)
            
            InputBox.FocusLost:Connect(function()
                Tween(FocusLine, {Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.5, 0, 1, -2)}, 0.25)
                callback(InputBox.Text)
            end)
            
            return {
                Set = function(value)
                    InputBox.Text = value
                    callback(value)
                end,
                Get = function()
                    return InputBox.Text
                end
            }
        end
        
        -- DROPDOWN
        function Elements:CreateDropdown(config)
            config = config or {}
            local text = config.Name or config.Text or "Dropdown"
            local options = config.Options or {}
            local default = config.Default or options[1] or "Select..."
            local callback = config.Callback or function() end
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1, 0, 0, 42)
            DropdownFrame.BackgroundTransparency = 1
            DropdownFrame.ClipsDescendants = true
            DropdownFrame.Parent = Page
            
            local DropdownBg = Instance.new("Frame")
            DropdownBg.Size = UDim2.new(1, 0, 0, 42)
            DropdownBg.BackgroundColor3 = theme.Tertiary
            DropdownBg.Parent = DropdownFrame
            
            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 10)
            DropdownCorner.Parent = DropdownBg
            
            local DropdownText = Instance.new("TextLabel")
            DropdownText.Size = UDim2.new(1, -120, 1, 0)
            DropdownText.Position = UDim2.new(0, 15, 0, 0)
            DropdownText.BackgroundTransparency = 1
            DropdownText.Text = text
            DropdownText.TextColor3 = theme.Text
            DropdownText.Font = Enum.Font.GothamSemibold
            DropdownText.TextSize = 14
            DropdownText.TextXAlignment = Enum.TextXAlignment.Left
            DropdownText.Parent = DropdownBg
            
            local SelectedText = Instance.new("TextLabel")
            SelectedText.Size = UDim2.new(0, 100, 0, 26)
            SelectedText.Position = UDim2.new(1, -115, 0.5, -13)
            SelectedText.BackgroundColor3 = theme.Secondary
            SelectedText.Text = default
            SelectedText.TextColor3 = theme.TextDark
            SelectedText.Font = Enum.Font.Gotham
            SelectedText.TextSize = 12
            SelectedText.Parent = DropdownBg
            
            local SelectedCorner = Instance.new("UICorner")
            SelectedCorner.CornerRadius = UDim.new(0, 6)
            SelectedCorner.Parent = SelectedText
            
            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 20, 0, 20)
            Arrow.Position = UDim2.new(1, -25, 0.5, -10)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.TextColor3 = theme.TextDark
            Arrow.Font = Enum.Font.Gotham
            Arrow.TextSize = 12
            Arrow.Parent = DropdownBg
            
            local OptionsFrame = Instance.new("Frame")
            OptionsFrame.Size = UDim2.new(1, -20, 0, 0)
            OptionsFrame.Position = UDim2.new(0, 10, 0, 48)
            OptionsFrame.BackgroundColor3 = theme.Secondary
            OptionsFrame.BorderSizePixel = 0
            OptionsFrame.ClipsDescendants = true
            OptionsFrame.Visible = false
            OptionsFrame.Parent = DropdownBg
            
            local OptionsCorner = Instance.new("UICorner")
            OptionsCorner.CornerRadius = UDim.new(0, 8)
            OptionsCorner.Parent = OptionsFrame
            
            local OptionsList = Instance.new("UIListLayout")
            OptionsList.Padding = UDim.new(0, 4)
            OptionsList.Parent = OptionsFrame
            
            local expanded = false
            
            local function CreateOption(optionText)
                local OptionBtn = Instance.new("TextButton")
                OptionBtn.Size = UDim2.new(1, 0, 0, 30)
                OptionBtn.BackgroundColor3 = theme.Tertiary
                OptionBtn.Text = optionText
                OptionBtn.TextColor3 = theme.Text
                OptionBtn.Font = Enum.Font.Gotham
                OptionBtn.TextSize = 13
                OptionBtn.Parent = OptionsFrame
                
                local OptionCorner = Instance.new("UICorner")
                OptionCorner.CornerRadius = UDim.new(0, 6)
                OptionCorner.Parent = OptionBtn
                
                OptionBtn.MouseEnter:Connect(function()
                    Tween(OptionBtn, {BackgroundColor3 = theme.Accent}, 0.15)
                end)
                
                OptionBtn.MouseLeave:Connect(function()
                    Tween(OptionBtn, {BackgroundColor3 = theme.Tertiary}, 0.15)
                end)
                
                OptionBtn.MouseButton1Click:Connect(function()
                    SelectedText.Text = optionText
                    callback(optionText)
                    
                    expanded = false
                    Tween(Arrow, {Rotation = 0}, 0.2)
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 42)}, 0.3)
                    OptionsFrame.Visible = false
                end)
            end
            
            for _, opt in ipairs(options) do
                CreateOption(opt)
            end
            
            local ClickArea = Instance.new("TextButton")
            ClickArea.Size = UDim2.new(1, 0, 0, 42)
            ClickArea.BackgroundTransparency = 1
            ClickArea.Text = ""
            ClickArea.Parent = DropdownBg
            
            ClickArea.MouseButton1Click:Connect(function()
                expanded = not expanded
                
                if expanded then
                    OptionsFrame.Visible = true
                    local totalHeight = #options * 34 + 10
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 48 + totalHeight)}, 0.3)
                    Tween(Arrow, {Rotation = 180}, 0.2)
                else
                    Tween(Arrow, {Rotation = 0}, 0.2)
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 42)}, 0.3)
                    task.delay(0.3, function()
                        OptionsFrame.Visible = false
                    end)
                end
            end)
            
            return {
                Set = function(value)
                    SelectedText.Text = value
                    callback(value)
                end,
                Get = function()
                    return SelectedText.Text
                end,
                Refresh = function(newOptions)
                    for _, child in ipairs(OptionsFrame:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    for _, opt in ipairs(newOptions) do
                        CreateOption(opt)
                    end
                end
            }
        end
        
        -- KEYBIND
        function Elements:CreateKeybind(config)
            config = config or {}
            local text = config.Name or config.Text or "Keybind"
            local default = config.Default or Enum.KeyCode.Unknown
            local callback = config.Callback or function() end
            
            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Size = UDim2.new(1, 0, 0, 42)
            KeybindFrame.BackgroundTransparency = 1
            KeybindFrame.Parent = Page
            
            local KeybindBg = Instance.new("Frame")
            KeybindBg.Size = UDim2.new(1, 0, 1, 0)
            KeybindBg.BackgroundColor3 = theme.Tertiary
            KeybindBg.Parent = KeybindFrame
            
            local KeybindCorner = Instance.new("UICorner")
            KeybindCorner.CornerRadius = UDim.new(0, 10)
            KeybindCorner.Parent = KeybindBg
            
            local KeybindText = Instance.new("TextLabel")
            KeybindText.Size = UDim2.new(1, -100, 1, 0)
            KeybindText.Position = UDim2.new(0, 15, 0, 0)
            KeybindText.BackgroundTransparency = 1
            KeybindText.Text = text
            KeybindText.TextColor3 = theme.Text
            KeybindText.Font = Enum.Font.GothamSemibold
            KeybindText.TextSize = 14
            KeybindText.TextXAlignment = Enum.TextXAlignment.Left
            KeybindText.Parent = KeybindBg
            
            local KeyButton = Instance.new("TextButton")
            KeyButton.Size = UDim2.new(0, 70, 0, 28)
            KeyButton.Position = UDim2.new(1, -82, 0.5, -14)
            KeyButton.BackgroundColor3 = theme.Secondary
            KeyButton.Text = default ~= Enum.KeyCode.Unknown and default.Name or "None"
            KeyButton.TextColor3 = theme.Accent
            KeyButton.Font = Enum.Font.GothamBold
            KeyButton.TextSize = 12
            KeyButton.Parent = KeybindBg
            
            local KeyCorner = Instance.new("UICorner")
            KeyCorner.CornerRadius = UDim.new(0, 6)
            KeyCorner.Parent = KeyButton
            
            local listening = false
            
            KeyButton.MouseButton1Click:Connect(function()
                listening = not listening
                if listening then
                    KeyButton.Text = "..."
                    Tween(KeyButton, {BackgroundColor3 = theme.Accent, TextColor3 = Color3.fromRGB(255,255,255)}, 0.2)
                end
            end)
            
            UIS.InputBegan:Connect(function(input, gameProcessed)
                if listening and not gameProcessed then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        KeyButton.Text = input.KeyCode.Name
                        Tween(KeyButton, {BackgroundColor3 = theme.Secondary, TextColor3 = theme.Accent}, 0.2)
                        callback(input.KeyCode)
                        listening = false
                    end
                elseif input.KeyCode == default and not gameProcessed then
                    callback(default)
                end
            end)
            
            return {
                Set = function(keyCode)
                    default = keyCode
                    KeyButton.Text = keyCode ~= Enum.KeyCode.Unknown and keyCode.Name or "None"
                end,
                Get = function()
                    return default
                end
            }
        end
        
        -- LABEL
        function Elements:CreateLabel(config)
            config = config or {}
            local text = config.Name or config.Text or "Label"
            
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Size = UDim2.new(1, 0, 0, 30)
            LabelFrame.BackgroundTransparency = 1
            LabelFrame.Parent = Page
            
            local LabelText = Instance.new("TextLabel")
            LabelText.Size = UDim2.new(1, -20, 1, 0)
            LabelText.Position = UDim2.new(0, 10, 0, 0)
            LabelText.BackgroundTransparency = 1
            LabelText.Text = text
            LabelText.TextColor3 = theme.TextDark
            LabelText.Font = Enum.Font.Gotham
            LabelText.TextSize = 13
            LabelText.TextXAlignment = Enum.TextXAlignment.Left
            LabelText.Parent = LabelFrame
            
            return {
                Set = function(newText)
                    LabelText.Text = newText
                end
            }
        end
        
        -- PARAGRAPH
        function Elements:CreateParagraph(config)
            config = config or {}
            local title = config.Title or "Title"
            local content = config.Content or "Content here..."
            
            local ParaFrame = Instance.new("Frame")
            ParaFrame.Size = UDim2.new(1, 0, 0, 80)
            ParaFrame.BackgroundTransparency = 1
            ParaFrame.Parent = Page
            
            local ParaBg = Instance.new("Frame")
            ParaBg.Size = UDim2.new(1, 0, 1, 0)
            ParaBg.BackgroundColor3 = theme.Tertiary
            ParaBg.Parent = ParaFrame
            
            local ParaCorner = Instance.new("UICorner")
            ParaCorner.CornerRadius = UDim.new(0, 10)
            ParaCorner.Parent = ParaBg
            
            local TitleText = Instance.new("TextLabel")
            TitleText.Size = UDim2.new(1, -20, 0, 25)
            TitleText.Position = UDim2.new(0, 15, 0, 8)
            TitleText.BackgroundTransparency = 1
            TitleText.Text = title
            TitleText.TextColor3 = theme.Text
            TitleText.Font = Enum.Font.GothamBold
            TitleText.TextSize = 15
            TitleText.TextXAlignment = Enum.TextXAlignment.Left
            TitleText.Parent = ParaBg
            
            local ContentText = Instance.new("TextLabel")
            ContentText.Size = UDim2.new(1, -30, 0, 40)
            ContentText.Position = UDim2.new(0, 15, 0, 35)
            ContentText.BackgroundTransparency = 1
            ContentText.Text = content
            ContentText.TextColor3 = theme.TextDark
            ContentText.Font = Enum.Font.Gotham
            ContentText.TextSize = 12
            ContentText.TextXAlignment = Enum.TextXAlignment.Left
            ContentText.TextWrapped = true
            ContentText.Parent = ParaBg
            
            return {
                SetTitle = function(newTitle)
                    TitleText.Text = newTitle
                end,
                SetContent = function(newContent)
                    ContentText.Text = newContent
                end
            }
        end
        
        -- COLOR PICKER
        function Elements:CreateColorPicker(config)
            config = config or {}
            local text = config.Name or config.Text or "Color Picker"
            local default = config.Default or Color3.fromRGB(88, 101, 242)
            local callback = config.Callback or function() end
            
            local ColorFrame = Instance.new("Frame")
            ColorFrame.Size = UDim2.new(1, 0, 0, 42)
            ColorFrame.BackgroundTransparency = 1
            ColorFrame.ClipsDescendants = true
            ColorFrame.Parent = Page
            
            local ColorBg = Instance.new("Frame")
            ColorBg.Size = UDim2.new(1, 0, 0, 42)
            ColorBg.BackgroundColor3 = theme.Tertiary
            ColorBg.Parent = ColorFrame
            
            local ColorCorner = Instance.new("UICorner")
            ColorCorner.CornerRadius = UDim.new(0, 10)
            ColorCorner.Parent = ColorBg
            
            local ColorText = Instance.new("TextLabel")
            ColorText.Size = UDim2.new(1, -70, 1, 0)
            ColorText.Position = UDim2.new(0, 15, 0, 0)
            ColorText.BackgroundTransparency = 1
            ColorText.Text = text
            ColorText.TextColor3 = theme.Text
            ColorText.Font = Enum.Font.GothamSemibold
            ColorText.TextSize = 14
            ColorText.TextXAlignment = Enum.TextXAlignment.Left
            ColorText.Parent = ColorBg
            
            local ColorPreview = Instance.new("TextButton")
            ColorPreview.Size = UDim2.new(0, 40, 0, 28)
            ColorPreview.Position = UDim2.new(1, -52, 0.5, -14)
            ColorPreview.BackgroundColor3 = default
            ColorPreview.Text = ""
            ColorPreview.Parent = ColorBg
            
            local PreviewCorner = Instance.new("UICorner")
            PreviewCorner.CornerRadius = UDim.new(0, 6)
            PreviewCorner.Parent = ColorPreview
            
            CreateShadow(ColorPreview, 0.3)
            
            -- Color Picker UI
            local PickerFrame = Instance.new("Frame")
            PickerFrame.Size = UDim2.new(1, -20, 0, 0)
            PickerFrame.Position = UDim2.new(0, 10, 0, 48)
            PickerFrame.BackgroundColor3 = theme.Secondary
            PickerFrame.BorderSizePixel = 0
            PickerFrame.ClipsDescendants = true
            PickerFrame.Visible = false
            PickerFrame.Parent = ColorBg
            
            local PickerCorner = Instance.new("UICorner")
            PickerCorner.CornerRadius = UDim.new(0, 8)
            PickerCorner.Parent = PickerFrame
            
            -- Simplified color picker with preset colors
            local colors = {
                Color3.fromRGB(255, 100, 100),
                Color3.fromRGB(255, 150, 100),
                Color3.fromRGB(255, 220, 100),
                Color3.fromRGB(150, 255, 100),
                Color3.fromRGB(100, 255, 200),
                Color3.fromRGB(100, 200, 255),
                Color3.fromRGB(100, 100, 255),
                Color3.fromRGB(200, 100, 255),
                Color3.fromRGB(255, 100, 200),
                Color3.fromRGB(255, 255, 255),
                Color3.fromRGB(150, 150, 150),
                Color3.fromRGB(50, 50, 50)
            }
            
            local grid = Instance.new("UIGridLayout")
            grid.CellSize = UDim2.new(0, 30, 0, 30)
            grid.CellPadding = UDim2.new(0, 8, 0, 8)
            grid.Parent = PickerFrame
            
            for _, color in ipairs(colors) do
                local colorBtn = Instance.new("TextButton")
                colorBtn.Size = UDim2.new(0, 30, 0, 30)
                colorBtn.BackgroundColor3 = color
                colorBtn.Text = ""
                colorBtn.Parent = PickerFrame
                
                local c = Instance.new("UICorner")
                c.CornerRadius = UDim.new(0, 6)
                c.Parent = colorBtn
                
                colorBtn.MouseButton1Click:Connect(function()
                    ColorPreview.BackgroundColor3 = color
                    callback(color)
                end)
            end
            
            local expanded = false
            
            ColorPreview.MouseButton1Click:Connect(function()
                expanded = not expanded
                
                if expanded then
                    PickerFrame.Visible = true
                    Tween(ColorFrame, {Size = UDim2.new(1, 0, 0, 180)}, 0.3)
                else
                    Tween(ColorFrame, {Size = UDim2.new(1, 0, 0, 42)}, 0.3)
                    task.delay(0.3, function()
                        PickerFrame.Visible = false
                    end)
                end
            end)
            
            return {
                Set = function(color)
                    ColorPreview.BackgroundColor3 = color
                    callback(color)
                end,
                Get = function()
                    return ColorPreview.BackgroundColor3
                end
            }
        end
        
        -- DIVIDER
        function Elements:CreateDivider(config)
            config = config or {}
            local text = config.Text
            
            local DivFrame = Instance.new("Frame")
            DivFrame.Size = UDim2.new(1, 0, 0, text and 35 or 15)
            DivFrame.BackgroundTransparency = 1
            DivFrame.Parent = Page
            
            if text then
                local LeftLine = Instance.new("Frame")
                LeftLine.Size = UDim2.new(0.3, 0, 0, 1)
                LeftLine.Position = UDim2.new(0, 0, 0.5, 0)
                LeftLine.BackgroundColor3 = theme.Secondary
                LeftLine.BorderSizePixel = 0
                LeftLine.Parent = DivFrame
                
                local RightLine = Instance.new("Frame")
                RightLine.Size = UDim2.new(0.3, 0, 0, 1)
                RightLine.Position = UDim2.new(0.7, 0, 0.5, 0)
                RightLine.BackgroundColor3 = theme.Secondary
                RightLine.BorderSizePixel = 0
                RightLine.Parent = DivFrame
                
                local DivText = Instance.new("TextLabel")
                DivText.Size = UDim2.new(0.4, 0, 1, 0)
                DivText.Position = UDim2.new(0.3, 0, 0, 0)
                DivText.BackgroundTransparency = 1
                DivText.Text = text
                DivText.TextColor3 = theme.TextDark
                DivText.Font = Enum.Font.Gotham
                DivText.TextSize = 12
                DivText.Parent = DivFrame
            else
                local Line = Instance.new("Frame")
                Line.Size = UDim2.new(1, 0, 0, 1)
                Line.Position = UDim2.new(0, 0, 0.5, 0)
                Line.BackgroundColor3 = theme.Secondary
                Line.BorderSizePixel = 0
                Line.Parent = DivFrame
            end
        end
        
        return Elements
    end
    
    -- NOTIFICATION METHOD
    function Lib:Notify(config)
        ShowNotification(config.Title or "Notification", config.Message or "", config.Type or "Info", config.Duration or 3)
    end
    
    -- THEME METHOD
    function Lib:SetTheme(themeName)
        if Themes[themeName] then
            Lib.Theme = Themes[themeName]
            ShowNotification("Theme Changed", "Switched to " .. themeName .. " theme", "Success", 2)
        end
    end
    
    -- TOGGLE KEY
    UIS.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Lib.Key then
            Lib.Toggled = not Lib.Toggled
            if Lib.Toggled then
                Main.Visible = true
                SpringTween(Main, {Size = UDim2.new(0, 600, 0, 420)})
            else
                Tween(Main, {Size = UDim2.new(0, 600, 0, 0)}, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In))
                task.delay(0.3, function()
                    Main.Visible = false
                end)
            end
        end
    end)
    
    return Lib
end

--// GLOBAL NOTIFICATION
function Library:Notify(config)
    ShowNotification(config.Title or "Notification", config.Message or "", config.Type or "Info", config.Duration or 3)
end

return Library
