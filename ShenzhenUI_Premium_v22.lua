--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                     SHENZHEN UI LIBRARY v2.2 - PREMIUM                       ║
    ║           Rayfield-Level • Glassmorphism • Smooth • Modern                   ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
    
    Features:
    - Glassmorphism design with layered shadows
    - Spring-based animations
    - Modular component system
    - Perfect ZIndex layering
    - Full interaction polish
--]]

local Library = {}
local Utilities = {}
local Components = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--════════════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
--════════════════════════════════════════════════════════════════════════════════

-- Enhanced Tween with multiple easing styles
function Utilities.Tween(Object, Properties, Duration, EasingStyle, EasingDirection, Delay)
    local Style = EasingStyle or Enum.EasingStyle.Quart
    local Direction = EasingDirection or Enum.EasingDirection.Out
    local Info = TweenInfo.new(Duration or 0.3, Style, Direction, 0, false, Delay or 0)
    local Tween = TweenService:Create(Object, Info, Properties)
    Tween:Play()
    return Tween
end

-- Spring animation for bouncy effects
function Utilities.Spring(Object, Properties, Duration)
    return Utilities.Tween(Object, Properties, Duration or 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

-- Smooth exponential easing
function Utilities.Smooth(Object, Properties, Duration)
    return Utilities.Tween(Object, Properties, Duration or 0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
end

-- Create multi-layered shadow
function Utilities.CreateShadow(Parent, Intensity)
    Intensity = Intensity or 0.5
    
    local ShadowContainer = Instance.new("Frame")
    ShadowContainer.Name = "ShadowContainer"
    ShadowContainer.Size = UDim2.new(1, 0, 1, 0)
    ShadowContainer.BackgroundTransparency = 1
    ShadowContainer.ZIndex = Parent.ZIndex - 1
    ShadowContainer.Parent = Parent
    
    -- Layer 1: Outer soft shadow
    local Shadow1 = Instance.new("ImageLabel")
    Shadow1.Name = "Shadow1"
    Shadow1.Size = UDim2.new(1, 40, 1, 40)
    Shadow1.Position = UDim2.new(0, -20, 0, -20)
    Shadow1.BackgroundTransparency = 1
    Shadow1.Image = "rbxassetid://5554236805"
    Shadow1.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow1.ImageTransparency = 1 - (Intensity * 0.3)
    Shadow1.ScaleType = Enum.ScaleType.Slice
    Shadow1.SliceCenter = Rect.new(20, 20, 280, 280)
    Shadow1.Parent = ShadowContainer
    
    -- Layer 2: Inner tighter shadow
    local Shadow2 = Instance.new("ImageLabel")
    Shadow2.Name = "Shadow2"
    Shadow2.Size = UDim2.new(1, 20, 1, 20)
    Shadow2.Position = UDim2.new(0, -10, 0, -10)
    Shadow2.BackgroundTransparency = 1
    Shadow2.Image = "rbxassetid://5554236805"
    Shadow2.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow2.ImageTransparency = 1 - (Intensity * 0.5)
    Shadow2.ScaleType = Enum.ScaleType.Slice
    Shadow2.SliceCenter = Rect.new(20, 20, 280, 280)
    Shadow2.Parent = ShadowContainer
    
    return ShadowContainer
end

-- Create gradient accent
function Utilities.CreateGradient(Parent, Color1, Color2, Rotation, Transparency)
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color1),
        ColorSequenceKeypoint.new(1, Color2 or Color1)
    })
    Gradient.Rotation = Rotation or 135
    if Transparency then
        Gradient.Transparency = NumberSequence.new(Transparency)
    end
    Gradient.Parent = Parent
    return Gradient
end

-- Create ripple effect (clipped to parent)
function Utilities.CreateRipple(Parent, X, Y, Color)
    local Ripple = Instance.new("Frame")
    Ripple.Name = "Ripple"
    Ripple.BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255)
    Ripple.BackgroundTransparency = 0.8
    Ripple.BorderSizePixel = 0
    Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local ParentAbs = Parent.AbsoluteSize
    local MaxSize = math.max(ParentAbs.X, ParentAbs.Y) * 1.5
    
    Ripple.Size = UDim2.new(0, 0, 0, 0)
    Ripple.Position = UDim2.new(0, X - Parent.AbsolutePosition.X, 0, Y - Parent.AbsolutePosition.Y)
    Ripple.ZIndex = Parent.ZIndex + 5
    Ripple.Parent = Parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Ripple
    
    -- Animate ripple
    Utilities.Tween(Ripple, {
        Size = UDim2.new(0, MaxSize, 0, MaxSize),
        BackgroundTransparency = 1
    }, 0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    task.delay(0.6, function()
        Ripple:Destroy()
    end)
end

-- Create glow effect
function Utilities.CreateGlow(Parent, Color, Size)
    local Glow = Instance.new("ImageLabel")
    Glow.Name = "Glow"
    Glow.Size = UDim2.new(1, Size or 20, 1, Size or 20)
    Glow.Position = UDim2.new(0, -(Size or 20) / 2, 0, -(Size or 20) / 2)
    Glow.BackgroundTransparency = 1
    Glow.Image = "rbxassetid://5028857084"
    Glow.ImageColor3 = Color or Color3.fromRGB(88, 101, 242)
    Glow.ImageTransparency = 0.7
    Glow.ZIndex = Parent.ZIndex - 1
    Glow.Parent = Parent
    return Glow
end

--════════════════════════════════════════════════════════════════════════════════
-- THEME SYSTEM
--════════════════════════════════════════════════════════════════════════════════

Library.Themes = {
    Glass = {
        -- Background colors (white-based glassmorphism)
        Background = Color3.fromRGB(255, 255, 255),
        BackgroundSecondary = Color3.fromRGB(250, 250, 252),
        BackgroundTertiary = Color3.fromRGB(245, 245, 248),
        
        -- Transparency levels
        Transparency = 0.08,
        TransparencySecondary = 0.12,
        TransparencyTertiary = 0.18,
        
        -- Accent colors (modern blue-purple gradient)
        Accent = Color3.fromRGB(88, 101, 242),
        AccentLight = Color3.fromRGB(120, 140, 255),
        AccentDark = Color3.fromRGB(60, 80, 220),
        
        -- Text colors
        TextPrimary = Color3.fromRGB(30, 30, 35),
        TextSecondary = Color3.fromRGB(100, 100, 110),
        TextTertiary = Color3.fromRGB(150, 150, 160),
        
        -- Status colors
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(255, 180, 80),
        Error = Color3.fromRGB(255, 100, 100),
        Info = Color3.fromRGB(80, 160, 255),
        
        -- Border
        Border = Color3.fromRGB(230, 230, 235),
        BorderLight = Color3.fromRGB(240, 240, 245),
    },
    
    Dark = {
        Background = Color3.fromRGB(25, 25, 30),
        BackgroundSecondary = Color3.fromRGB(35, 35, 42),
        BackgroundTertiary = Color3.fromRGB(45, 45, 55),
        
        Transparency = 0.05,
        TransparencySecondary = 0.1,
        TransparencyTertiary = 0.15,
        
        Accent = Color3.fromRGB(88, 101, 242),
        AccentLight = Color3.fromRGB(120, 140, 255),
        AccentDark = Color3.fromRGB(60, 80, 220),
        
        TextPrimary = Color3.fromRGB(245, 245, 250),
        TextSecondary = Color3.fromRGB(180, 180, 190),
        TextTertiary = Color3.fromRGB(130, 130, 140),
        
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(255, 180, 80),
        Error = Color3.fromRGB(255, 100, 100),
        Info = Color3.fromRGB(80, 160, 255),
        
        Border = Color3.fromRGB(50, 50, 60),
        BorderLight = Color3.fromRGB(60, 60, 70),
    },
    
    Midnight = {
        Background = Color3.fromRGB(18, 18, 28),
        BackgroundSecondary = Color3.fromRGB(28, 28, 42),
        BackgroundTertiary = Color3.fromRGB(38, 38, 55),
        
        Transparency = 0.03,
        TransparencySecondary = 0.08,
        TransparencyTertiary = 0.12,
        
        Accent = Color3.fromRGB(140, 100, 255),
        AccentLight = Color3.fromRGB(170, 140, 255),
        AccentDark = Color3.fromRGB(110, 70, 220),
        
        TextPrimary = Color3.fromRGB(240, 240, 255),
        TextSecondary = Color3.fromRGB(180, 180, 200),
        TextTertiary = Color3.fromRGB(130, 130, 150),
        
        Success = Color3.fromRGB(100, 220, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 120, 120),
        Info = Color3.fromRGB(120, 180, 255),
        
        Border = Color3.fromRGB(45, 45, 60),
        BorderLight = Color3.fromRGB(55, 55, 70),
    }
}

Library.CurrentTheme = Library.Themes.Glass

--════════════════════════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
--════════════════════════════════════════════════════════════════════════════════

Library.Notifications = {}

function Library.Notifications:Show(Title, Message, Type, Duration)
    local Theme = Library.CurrentTheme
    Duration = Duration or 3
    Type = Type or "Info"
    
    -- Colors for different types
    local TypeColors = {
        Info = Theme.Accent,
        Success = Theme.Success,
        Warning = Theme.Warning,
        Error = Theme.Error
    }
    
    local TypeIcons = {
        Info = "ℹ",
        Success = "✓",
        Warning = "!",
        Error = "✕"
    }
    
    -- Create notification GUI
    local NotifGui = Instance.new("ScreenGui")
    NotifGui.Name = "ShenzhenNotification"
    NotifGui.Parent = CoreGui
    NotifGui.DisplayOrder = 1000
    NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(0, 320, 0, 80)
    Container.Position = UDim2.new(1, 20, 0.85, 0)
    Container.BackgroundColor3 = Theme.Background
    Container.BackgroundTransparency = Theme.Transparency
    Container.BorderSizePixel = 0
    Container.Parent = NotifGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Container
    
    -- Border stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Border
    Stroke.Transparency = 0.5
    Stroke.Thickness = 1
    Stroke.Parent = Container
    
    Utilities.CreateShadow(Container, 0.4)
    
    -- Icon container
    local IconContainer = Instance.new("Frame")
    IconContainer.Size = UDim2.new(0, 50, 1, 0)
    IconContainer.BackgroundColor3 = TypeColors[Type]
    IconContainer.BorderSizePixel = 0
    IconContainer.Parent = Container
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 12)
    IconCorner.Parent = IconContainer
    
    -- Mask for left-only rounding
    local IconMask = Instance.new("Frame")
    IconMask.Size = UDim2.new(0, 10, 1, 0)
    IconMask.Position = UDim2.new(1, -5, 0, 0)
    IconMask.BackgroundColor3 = TypeColors[Type]
    IconMask.BorderSizePixel = 0
    IconMask.Parent = IconContainer
    
    -- Icon
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(1, 0, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = TypeIcons[Type]
    Icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 24
    Icon.Parent = IconContainer
    
    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -70, 0, 22)
    TitleLabel.Position = UDim2.new(0, 60, 0, 12)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Theme.TextPrimary
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Container
    
    -- Message
    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Name = "Message"
    MessageLabel.Size = UDim2.new(1, -70, 0, 40)
    MessageLabel.Position = UDim2.new(0, 60, 0, 34)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = Message
    MessageLabel.TextColor3 = Theme.TextSecondary
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextSize = 13
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextWrapped = true
    MessageLabel.Parent = Container
    
    -- Progress bar
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Name = "Progress"
    ProgressBar.Size = UDim2.new(1, 0, 0, 3)
    ProgressBar.Position = UDim2.new(0, 0, 1, -3)
    ProgressBar.BackgroundColor3 = TypeColors[Type]
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = Container
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(0, 2)
    ProgressCorner.Parent = ProgressBar
    
    -- Animate in
    Utilities.Spring(Container, {Position = UDim2.new(1, -340, 0.85, 0)})
    
    -- Progress animation
    Utilities.Tween(ProgressBar, {Size = UDim2.new(0, 0, 0, 3)}, Duration, Enum.EasingStyle.Linear)
    
    -- Auto dismiss
    task.delay(Duration, function()
        Utilities.Tween(Container, {Position = UDim2.new(1, 20, 0.85, 0)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(0.4, function()
            NotifGui:Destroy()
        end)
    end)
end

--════════════════════════════════════════════════════════════════════════════════
-- COMPONENT BUILDERS
--════════════════════════════════════════════════════════════════════════════════

Components.Button = {}

function Components.Button:Create(Parent, Config)
    local Theme = Library.CurrentTheme
    Config = Config or {}
    
    local Text = Config.Text or Config.Name or "Button"
    local Callback = Config.Callback or function() end
    local Icon = Config.Icon
    
    -- Container
    local Container = Instance.new("Frame")
    Container.Name = Text .. "_Button"
    Container.Size = UDim2.new(1, 0, 0, 44)
    Container.BackgroundTransparency = 1
    Container.ClipsDescendants = true
    Container.Parent = Parent
    
    -- Button background
    local Button = Instance.new("TextButton")
    Button.Name = "Button"
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundColor3 = Theme.BackgroundTertiary
    Button.BackgroundTransparency = Theme.TransparencyTertiary
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.ClipsDescendants = true
    Button.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Button
    
    -- Gradient overlay
    local Gradient = Utilities.CreateGradient(Button, Theme.Accent, Theme.AccentLight, 135, 1)
    
    -- Border
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Border
    Stroke.Transparency = 0.7
    Stroke.Thickness = 1
    Stroke.Parent = Button
    
    -- Icon (if provided)
    local IconLabel
    if Icon then
        IconLabel = Instance.new("TextLabel")
        IconLabel.Name = "Icon"
        IconLabel.Size = UDim2.new(0, 24, 0, 24)
        IconLabel.Position = UDim2.new(0, 14, 0.5, -12)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Text = Icon
        IconLabel.TextColor3 = Theme.TextSecondary
        IconLabel.Font = Enum.Font.Gotham
        IconLabel.TextSize = 14
        IconLabel.Parent = Button
    end
    
    -- Text
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Name = "Text"
    TextLabel.Size = UDim2.new(1, Icon and -100 or -80, 1, 0)
    TextLabel.Position = UDim2.new(0, Icon and 44 or 16, 0, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = Text
    TextLabel.TextColor3 = Theme.TextPrimary
    TextLabel.Font = Enum.Font.GothamSemibold
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = Button
    
    -- Arrow indicator
    local Arrow = Instance.new("TextLabel")
    Arrow.Name = "Arrow"
    Arrow.Size = UDim2.new(0, 24, 0, 24)
    Arrow.Position = UDim2.new(1, -36, 0.5, -12)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "→"
    Arrow.TextColor3 = Theme.TextTertiary
    Arrow.Font = Enum.Font.Gotham
    Arrow.TextSize = 14
    Arrow.Parent = Button
    
    -- Hover effects
    Button.MouseEnter:Connect(function()
        Utilities.Tween(Button, {BackgroundTransparency = 0.05}, 0.2)
        Utilities.Tween(TextLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        Utilities.Tween(Arrow, {TextColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -30, 0.5, -12)}, 0.2)
        Utilities.Tween(Gradient, {Transparency = NumberSequence.new(0.7)}, 0.2)
        Utilities.Tween(Stroke, {Color = Theme.Accent, Transparency = 0.3}, 0.2)
        if IconLabel then
            Utilities.Tween(IconLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        end
    end)
    
    Button.MouseLeave:Connect(function()
        Utilities.Tween(Button, {BackgroundTransparency = Theme.TransparencyTertiary}, 0.2)
        Utilities.Tween(TextLabel, {TextColor3 = Theme.TextPrimary}, 0.2)
        Utilities.Tween(Arrow, {TextColor3 = Theme.TextTertiary, Position = UDim2.new(1, -36, 0.5, -12)}, 0.2)
        Utilities.Tween(Gradient, {Transparency = NumberSequence.new(1)}, 0.2)
        Utilities.Tween(Stroke, {Color = Theme.Border, Transparency = 0.7}, 0.2)
        if IconLabel then
            Utilities.Tween(IconLabel, {TextColor3 = Theme.TextSecondary}, 0.2)
        end
    end)
    
    -- Click effects
    Button.MouseButton1Down:Connect(function()
        Utilities.Spring(Button, {Size = UDim2.new(0.98, 0, 0.95, 0)}, 0.15)
    end)
    
    Button.MouseButton1Up:Connect(function()
        Utilities.Spring(Button, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)
    end)
    
    Button.MouseButton1Click:Connect(function()
        local MousePos = UserInputService:GetMouseLocation()
        Utilities.CreateRipple(Button, MousePos.X, MousePos.Y)
        Callback()
    end)
    
    return Container
end

--════════════════════════════════════════════════════════════════════════════════
-- TOGGLE COMPONENT
--════════════════════════════════════════════════════════════════════════════════

Components.Toggle = {}

function Components.Toggle:Create(Parent, Config)
    local Theme = Library.CurrentTheme
    Config = Config or {}
    
    local Text = Config.Text or Config.Name or "Toggle"
    local Default = Config.Default or false
    local Callback = Config.Callback or function() end
    
    local State = Default
    
    -- Container
    local Container = Instance.new("Frame")
    Container.Name = Text .. "_Toggle"
    Container.Size = UDim2.new(1, 0, 0, 44)
    Container.BackgroundTransparency = 1
    Container.Parent = Parent
    
    -- Background
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Theme.BackgroundTertiary
    Background.BackgroundTransparency = Theme.TransparencyTertiary
    Background.BorderSizePixel = 0
    Background.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Background
    
    -- Border
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Border
    Stroke.Transparency = 0.7
    Stroke.Thickness = 1
    Stroke.Parent = Background
    
    -- Text
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Name = "Text"
    TextLabel.Size = UDim2.new(1, -100, 1, 0)
    TextLabel.Position = UDim2.new(0, 16, 0, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = Text
    TextLabel.TextColor3 = Theme.TextPrimary
    TextLabel.Font = Enum.Font.GothamSemibold
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = Background
    
    -- Toggle Switch Container
    local SwitchContainer = Instance.new("Frame")
    SwitchContainer.Name = "Switch"
    SwitchContainer.Size = UDim2.new(0, 52, 0, 28)
    SwitchContainer.Position = UDim2.new(1, -66, 0.5, -14)
    SwitchContainer.BackgroundColor3 = Theme.BackgroundSecondary
    SwitchContainer.BorderSizePixel = 0
    SwitchContainer.Parent = Background
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchContainer
    
    -- Toggle Knob
    local Knob = Instance.new("Frame")
    Knob.Name = "Knob"
    Knob.Size = UDim2.new(0, 22, 0, 22)
    Knob.Position = State and UDim2.new(0, 27, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = SwitchContainer
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob
    
    -- Knob shadow
    Utilities.CreateShadow(Knob, 0.3)
    
    -- Status indicator dot
    local StatusDot = Instance.new("Frame")
    StatusDot.Name = "Status"
    StatusDot.Size = UDim2.new(0, 6, 0, 6)
    StatusDot.Position = UDim2.new(0, 8, 0.5, -3)
    StatusDot.BackgroundColor3 = State and Theme.Success or Theme.TextTertiary
    StatusDot.BorderSizePixel = 0
    StatusDot.Parent = SwitchContainer
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(1, 0)
    StatusCorner.Parent = StatusDot
    
    -- Update function
    local function Update()
        if State then
            Utilities.Tween(SwitchContainer, {BackgroundColor3 = Theme.Accent}, 0.25)
            Utilities.Tween(Knob, {Position = UDim2.new(0, 27, 0.5, -11)}, 0.25)
            Utilities.Tween(StatusDot, {BackgroundColor3 = Theme.Success, Position = UDim2.new(0, 36, 0.5, -3)}, 0.25)
            Utilities.Tween(Stroke, {Color = Theme.Accent, Transparency = 0.4}, 0.2)
        else
            Utilities.Tween(SwitchContainer, {BackgroundColor3 = Theme.BackgroundSecondary}, 0.25)
            Utilities.Tween(Knob, {Position = UDim2.new(0, 3, 0.5, -11)}, 0.25)
            Utilities.Tween(StatusDot, {BackgroundColor3 = Theme.TextTertiary, Position = UDim2.new(0, 8, 0.5, -3)}, 0.25)
            Utilities.Tween(Stroke, {Color = Theme.Border, Transparency = 0.7}, 0.2)
        end
        Callback(State)
    end
    
    -- Set initial state
    if State then
        SwitchContainer.BackgroundColor3 = Theme.Accent
        StatusDot.Position = UDim2.new(0, 36, 0.5, -3)
        StatusDot.BackgroundColor3 = Theme.Success
    end
    
    -- Click area
    local ClickArea = Instance.new("TextButton")
    ClickArea.Name = "ClickArea"
    ClickArea.Size = UDim2.new(1, 0, 1, 0)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""
    ClickArea.Parent = Background
    
    ClickArea.MouseEnter:Connect(function()
        if not State then
            Utilities.Tween(Background, {BackgroundTransparency = 0.1}, 0.15)
        end
    end)
    
    ClickArea.MouseLeave:Connect(function()
        if not State then
            Utilities.Tween(Background, {BackgroundTransparency = Theme.TransparencyTertiary}, 0.15)
        end
    end)
    
    ClickArea.MouseButton1Click:Connect(function()
        State = not State
        Update()
    end)
    
    -- Return control interface
    return {
        Set = function(Value)
            State = Value
            Update()
        end,
        Get = function()
            return State
        end
    }
end

--════════════════════════════════════════════════════════════════════════════════
-- SLIDER COMPONENT
--════════════════════════════════════════════════════════════════════════════════

Components.Slider = {}

function Components.Slider:Create(Parent, Config)
    local Theme = Library.CurrentTheme
    Config = Config or {}
    
    local Text = Config.Text or Config.Name or "Slider"
    local Min = Config.Min or 0
    local Max = Config.Max or 100
    local Default = Config.Default or Min
    local Suffix = Config.Suffix or ""
    local Callback = Config.Callback or function() end
    
    local CurrentValue = math.clamp(Default, Min, Max)
    
    -- Container
    local Container = Instance.new("Frame")
    Container.Name = Text .. "_Slider"
    Container.Size = UDim2.new(1, 0, 0, 62)
    Container.BackgroundTransparency = 1
    Container.Parent = Parent
    
    -- Background
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Theme.BackgroundTertiary
    Background.BackgroundTransparency = Theme.TransparencyTertiary
    Background.BorderSizePixel = 0
    Background.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Background
    
    -- Border
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Border
    Stroke.Transparency = 0.7
    Stroke.Thickness = 1
    Stroke.Parent = Background
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0.5, 0, 0, 24)
    Title.Position = UDim2.new(0, 16, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = Text
    Title.TextColor3 = Theme.TextPrimary
    Title.Font = Enum.Font.GothamSemibold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Background
    
    -- Value display
    local ValueDisplay = Instance.new("TextLabel")
    ValueDisplay.Name = "Value"
    ValueDisplay.Size = UDim2.new(0, 60, 0, 24)
    ValueDisplay.Position = UDim2.new(1, -72, 0, 8)
    ValueDisplay.BackgroundColor3 = Theme.BackgroundSecondary
    ValueDisplay.BackgroundTransparency = 0.5
    ValueDisplay.Text = tostring(CurrentValue) .. Suffix
    ValueDisplay.TextColor3 = Theme.Accent
    ValueDisplay.Font = Enum.Font.GothamBold
    ValueDisplay.TextSize = 12
    ValueDisplay.Parent = Background
    
    local ValueCorner = Instance.new("UICorner")
    ValueCorner.CornerRadius = UDim.new(0, 6)
    ValueCorner.Parent = ValueDisplay
    
    -- Slider track
    local Track = Instance.new("Frame")
    Track.Name = "Track"
    Track.Size = UDim2.new(1, -32, 0, 8)
    Track.Position = UDim2.new(0, 16, 0, 38)
    Track.BackgroundColor3 = Theme.BackgroundSecondary
    Track.BorderSizePixel = 0
    Track.Parent = Background
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track
    
    -- Fill
    local FillPercent = (CurrentValue - Min) / (Max - Min)
    local Fill = Instance.new("Frame")
    Fill.Name = "Fill"
    Fill.Size = UDim2.new(FillPercent, 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill
    
    -- Gradient on fill
    Utilities.CreateGradient(Fill, Theme.Accent, Theme.AccentLight, 0)
    
    -- Knob
    local Knob = Instance.new("Frame")
    Knob.Name = "Knob"
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = UDim2.new(FillPercent, -9, 0.5, -9)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob
    
    -- Knob shadow
    Utilities.CreateShadow(Knob, 0.4)
    
    -- Glow effect on knob
    local Glow = Utilities.CreateGlow(Knob, Theme.Accent, 15)
    Glow.ImageTransparency = 0.8
    
    -- Dragging logic
    local Dragging = false
    
    local function UpdateSlider(Input)
        local TrackPos = Track.AbsolutePosition.X
        local TrackSize = Track.AbsoluteSize.X
        local MouseX = Input.Position.X
        
        local Percent = math.clamp((MouseX - TrackPos) / TrackSize, 0, 1)
        local Value = math.floor(Min + (Max - Min) * Percent)
        
        if Value ~= CurrentValue then
            CurrentValue = Value
            ValueDisplay.Text = tostring(Value) .. Suffix
            
            Utilities.Tween(Fill, {Size = UDim2.new(Percent, 0, 1, 0)}, 0.05)
            Utilities.Tween(Knob, {Position = UDim2.new(Percent, -9, 0.5, -9)}, 0.05)
            
            Callback(Value)
        end
    end
    
    Track.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            UpdateSlider(Input)
        end
    end)
    
    Knob.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            Utilities.Tween(Knob, {Size = UDim2.new(0, 22, 0, 22)}, 0.1)
            Utilities.Tween(Glow, {ImageTransparency = 0.5}, 0.1)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            if Dragging then
                Dragging = false
                Utilities.Tween(Knob, {Size = UDim2.new(0, 18, 0, 18)}, 0.1)
                Utilities.Tween(Glow, {ImageTransparency = 0.8}, 0.1)
            end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(Input)
        end
    end)
    
    -- Hover effects
    Track.MouseEnter:Connect(function()
        Utilities.Tween(Stroke, {Color = Theme.Accent, Transparency = 0.5}, 0.2)
    end)
    
    Track.MouseLeave:Connect(function()
        if not Dragging then
            Utilities.Tween(Stroke, {Color = Theme.Border, Transparency = 0.7}, 0.2)
        end
    end)
    
    return {
        Set = function(Value)
            CurrentValue = math.clamp(Value, Min, Max)
            local Percent = (CurrentValue - Min) / (Max - Min)
            ValueDisplay.Text = tostring(CurrentValue) .. Suffix
            Utilities.Tween(Fill, {Size = UDim2.new(Percent, 0, 1, 0)}, 0.2)
            Utilities.Tween(Knob, {Position = UDim2.new(Percent, -9, 0.5, -9)}, 0.2)
            Callback(CurrentValue)
        end,
        Get = function()
            return CurrentValue
        end
    }
end

--════════════════════════════════════════════════════════════════════════════════
-- DROPDOWN COMPONENT
--════════════════════════════════════════════════════════════════════════════════

Components.Dropdown = {}

function Components.Dropdown:Create(Parent, Config)
    local Theme = Library.CurrentTheme
    Config = Config or {}
    
    local Text = Config.Text or Config.Name or "Dropdown"
    local Options = Config.Options or {}
    local Default = Config.Default or Options[1] or "Select..."
    local Callback = Config.Callback or function() end
    
    local Selected = Default
    local Expanded = false
    local OptionButtons = {}
    
    -- Container (expands when opened)
    local Container = Instance.new("Frame")
    Container.Name = Text .. "_Dropdown"
    Container.Size = UDim2.new(1, 0, 0, 46)
    Container.BackgroundTransparency = 1
    Container.ClipsDescendants = true
    Container.Parent = Parent
    
    -- Main background
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 0, 46)
    Background.BackgroundColor3 = Theme.BackgroundTertiary
    Background.BackgroundTransparency = Theme.TransparencyTertiary
    Background.BorderSizePixel = 0
    Background.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Background
    
    -- Border
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Border
    Stroke.Transparency = 0.7
    Stroke.Thickness = 1
    Stroke.Parent = Background
    
    -- Label
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(0.4, 0, 0, 46)
    Label.Position = UDim2.new(0, 16, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Theme.TextPrimary
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Background
    
    -- Selected value display
    local ValueDisplay = Instance.new("TextLabel")
    ValueDisplay.Name = "Value"
    ValueDisplay.Size = UDim2.new(0, 100, 0, 28)
    ValueDisplay.Position = UDim2.new(1, -130, 0.5, -14)
    ValueDisplay.BackgroundColor3 = Theme.BackgroundSecondary
    ValueDisplay.BackgroundTransparency = 0.5
    ValueDisplay.Text = Selected
    ValueDisplay.TextColor3 = Theme.TextSecondary
    ValueDisplay.Font = Enum.Font.Gotham
    ValueDisplay.TextSize = 12
    ValueDisplay.Parent = Background
    
    local ValueCorner = Instance.new("UICorner")
    ValueCorner.CornerRadius = UDim.new(0, 6)
    ValueCorner.Parent = ValueDisplay
    
    -- Arrow
    local Arrow = Instance.new("TextLabel")
    Arrow.Name = "Arrow"
    Arrow.Size = UDim2.new(0, 20, 0, 20)
    Arrow.Position = UDim2.new(1, -26, 0.5, -10)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = Theme.TextTertiary
    Arrow.Font = Enum.Font.Gotham
    Arrow.TextSize = 10
    Arrow.Parent = Background
    
    -- Options container
    local OptionsContainer = Instance.new("Frame")
    OptionsContainer.Name = "Options"
    OptionsContainer.Size = UDim2.new(1, -20, 0, 0)
    OptionsContainer.Position = UDim2.new(0, 10, 0, 52)
    OptionsContainer.BackgroundColor3 = Theme.BackgroundSecondary
    OptionsContainer.BackgroundTransparency = 0.3
    OptionsContainer.BorderSizePixel = 0
    OptionsContainer.ClipsDescendants = true
    OptionsContainer.Visible = false
    OptionsContainer.Parent = Background
    
    local OptionsCorner = Instance.new("UICorner")
    OptionsCorner.CornerRadius = UDim.new(0, 8)
    OptionsCorner.Parent = OptionsContainer
    
    -- Options list
    local OptionsList = Instance.new("UIListLayout")
    OptionsList.Padding = UDim.new(0, 4)
    OptionsList.Parent = OptionsContainer
    
    -- Function to create option button
    local function CreateOption(OptionText)
        local OptionBtn = Instance.new("TextButton")
        OptionBtn.Name = OptionText
        OptionBtn.Size = UDim2.new(1, 0, 0, 32)
        OptionBtn.BackgroundColor3 = Theme.BackgroundTertiary
        OptionBtn.BackgroundTransparency = 0.5
        OptionBtn.Text = OptionText
        OptionBtn.TextColor3 = Theme.TextPrimary
        OptionBtn.Font = Enum.Font.Gotham
        OptionBtn.TextSize = 13
        OptionBtn.Parent = OptionsContainer
        
        local OptionCorner = Instance.new("UICorner")
        OptionCorner.CornerRadius = UDim.new(0, 6)
        OptionCorner.Parent = OptionBtn
        
        OptionBtn.MouseEnter:Connect(function()
            Utilities.Tween(OptionBtn, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.8}, 0.15)
            Utilities.Tween(OptionBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
        end)
        
        OptionBtn.MouseLeave:Connect(function()
            Utilities.Tween(OptionBtn, {BackgroundColor3 = Theme.BackgroundTertiary, BackgroundTransparency = 0.5}, 0.15)
            Utilities.Tween(OptionBtn, {TextColor3 = Theme.TextPrimary}, 0.15)
        end)
        
        OptionBtn.MouseButton1Click:Connect(function()
            Selected = OptionText
            ValueDisplay.Text = Selected
            Callback(Selected)
            
            -- Close dropdown
            Expanded = false
            Utilities.Tween(Arrow, {Rotation = 0}, 0.2)
            Utilities.Tween(Container, {Size = UDim2.new(1, 0, 0, 46)}, 0.3)
            task.delay(0.3, function()
                OptionsContainer.Visible = false
            end)
        end)
        
        table.insert(OptionButtons, OptionBtn)
    end
    
    -- Create initial options
    for _, Option in ipairs(Options) do
        CreateOption(Option)
    end
    
    -- Click area for main dropdown
    local ClickArea = Instance.new("TextButton")
    ClickArea.Name = "ClickArea"
    ClickArea.Size = UDim2.new(1, 0, 0, 46)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""
    ClickArea.Parent = Background
    
    ClickArea.MouseEnter:Connect(function()
        Utilities.Tween(Stroke, {Color = Theme.Accent, Transparency = 0.5}, 0.2)
    end)
    
    ClickArea.MouseLeave:Connect(function()
        if not Expanded then
            Utilities.Tween(Stroke, {Color = Theme.Border, Transparency = 0.7}, 0.2)
        end
    end)
    
    ClickArea.MouseButton1Click:Connect(function()
        Expanded = not Expanded
        
        if Expanded then
            OptionsContainer.Visible = true
            local TotalHeight = #Options * 36 + 10
            Utilities.Tween(Container, {Size = UDim2.new(1, 0, 0, 52 + TotalHeight)}, 0.3)
            Utilities.Tween(Arrow, {Rotation = 180}, 0.2)
        else
            Utilities.Tween(Arrow, {Rotation = 0}, 0.2)
            Utilities.Tween(Container, {Size = UDim2.new(1, 0, 0, 46)}, 0.3)
            task.delay(0.3, function()
                OptionsContainer.Visible = false
            end)
        end
    end)
    
    return {
        Set = function(Value)
            Selected = Value
            ValueDisplay.Text = Selected
            Callback(Selected)
        end,
        Get = function()
            return Selected
        end,
        Refresh = function(NewOptions)
            -- Clear existing
            for _, Btn in ipairs(OptionButtons) do
                Btn:Destroy()
            end
            OptionButtons = {}
            
            -- Create new
            for _, Option in ipairs(NewOptions) do
                CreateOption(Option)
            end
        end
    }
end

--════════════════════════════════════════════════════════════════════════════════
-- TEXTBOX COMPONENT
--════════════════════════════════════════════════════════════════════════════════

Components.TextBox = {}

function Components.TextBox:Create(Parent, Config)
    local Theme = Library.CurrentTheme
    Config = Config or {}
    
    local Text = Config.Text or Config.Name or "TextBox"
    local Placeholder = Config.Placeholder or "Enter text..."
    local Default = Config.Default or ""
    local Callback = Config.Callback or function() end
    
    -- Container
    local Container = Instance.new("Frame")
    Container.Name = Text .. "_TextBox"
    Container.Size = UDim2.new(1, 0, 0, 72)
    Container.BackgroundTransparency = 1
    Container.Parent = Parent
    
    -- Background
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Theme.BackgroundTertiary
    Background.BackgroundTransparency = Theme.TransparencyTertiary
    Background.BorderSizePixel = 0
    Background.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Background
    
    -- Border
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Border
    Stroke.Transparency = 0.7
    Stroke.Thickness = 1
    Stroke.Parent = Background
    
    -- Label
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, -20, 0, 22)
    Label.Position = UDim2.new(0, 14, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Theme.TextPrimary
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Background
    
    -- Input frame
    local InputFrame = Instance.new("Frame")
    InputFrame.Name = "InputFrame"
    InputFrame.Size = UDim2.new(1, -20, 0, 32)
    InputFrame.Position = UDim2.new(0, 10, 0, 34)
    InputFrame.BackgroundColor3 = Theme.BackgroundSecondary
    InputFrame.BackgroundTransparency = 0.4
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = Background
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = InputFrame
    
    -- Focus line
    local FocusLine = Instance.new("Frame")
    FocusLine.Name = "FocusLine"
    FocusLine.Size = UDim2.new(0, 0, 0, 2)
    FocusLine.Position = UDim2.new(0.5, 0, 1, -2)
    FocusLine.BackgroundColor3 = Theme.Accent
    FocusLine.BorderSizePixel = 0
    FocusLine.Parent = InputFrame
    
    -- TextBox
    local TextBox = Instance.new("TextBox")
    TextBox.Name = "TextBox"
    TextBox.Size = UDim2.new(1, -16, 1, 0)
    TextBox.Position = UDim2.new(0, 8, 0, 0)
    TextBox.BackgroundTransparency = 1
    TextBox.Text = Default
    TextBox.PlaceholderText = Placeholder
    TextBox.TextColor3 = Theme.TextPrimary
    TextBox.PlaceholderColor3 = Theme.TextTertiary
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 13
    TextBox.ClearTextOnFocus = false
    TextBox.Parent = InputFrame
    
    -- Focus effects
    TextBox.Focused:Connect(function()
        Utilities.Tween(FocusLine, {Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2)}, 0.25)
        Utilities.Tween(Stroke, {Color = Theme.Accent, Transparency = 0.4}, 0.2)
    end)
    
    TextBox.FocusLost:Connect(function()
        Utilities.Tween(FocusLine, {Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.5, 0, 1, -2)}, 0.25)
        Utilities.Tween(Stroke, {Color = Theme.Border, Transparency = 0.7}, 0.2)
        Callback(TextBox.Text)
    end)
    
    return {
        Set = function(Value)
            TextBox.Text = Value
            Callback(Value)
        end,
        Get = function()
            return TextBox.Text
        end
    }
end

--════════════════════════════════════════════════════════════════════════════════
-- LABEL COMPONENT
--════════════════════════════════════════════════════════════════════════════════

Components.Label = {}

function Components.Label:Create(Parent, Config)
    local Theme = Library.CurrentTheme
    Config = Config or {}
    
    local Text = Config.Text or "Label"
    local Style = Config.Style or "Normal" -- Normal, Title, Subtitle
    
    local Container = Instance.new("Frame")
    Container.Name = Text .. "_Label"
    Container.Size = UDim2.new(1, 0, 0, Style == "Title" and 32 or 24)
    Container.BackgroundTransparency = 1
    Container.Parent = Parent
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Text"
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.Font = Style == "Title" and Enum.Font.GothamBold or Style == "Subtitle" and Enum.Font.GothamSemibold or Enum.Font.Gotham
    Label.TextSize = Style == "Title" and 16 or Style == "Subtitle" and 14 or 13
    Label.TextColor3 = Style == "Title" and Theme.TextPrimary or Style == "Subtitle" and Theme.TextSecondary or Theme.TextTertiary
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container
    
    return {
        Set = function(NewText)
            Label.Text = NewText
        end
    }
end

--════════════════════════════════════════════════════════════════════════════════
-- SECTION COMPONENT
--════════════════════════════════════════════════════════════════════════════════

Components.Section = {}

function Components.Section:Create(Parent, Config)
    local Theme = Library.CurrentTheme
    Config = Config or {}
    
    local Text = Config.Text or Config.Name or "Section"
    
    local Container = Instance.new("Frame")
    Container.Name = Text .. "_Section"
    Container.Size = UDim2.new(1, 0, 0, 36)
    Container.BackgroundTransparency = 1
    Container.Parent = Parent
    
    -- Left line
    local LeftLine = Instance.new("Frame")
    LeftLine.Name = "LeftLine"
    LeftLine.Size = UDim2.new(0.25, 0, 0, 1)
    LeftLine.Position = UDim2.new(0, 0, 0.5, 0)
    LeftLine.BackgroundColor3 = Theme.Border
    LeftLine.BorderSizePixel = 0
    LeftLine.Parent = Container
    
    -- Gradient on line
    Utilities.CreateGradient(LeftLine, Theme.Border, Theme.BorderLight, 0)
    
    -- Right line
    local RightLine = Instance.new("Frame")
    RightLine.Name = "RightLine"
    RightLine.Size = UDim2.new(0.25, 0, 0, 1)
    RightLine.Position = UDim2.new(0.75, 0, 0.5, 0)
    RightLine.BackgroundColor3 = Theme.Border
    RightLine.BorderSizePixel = 0
    RightLine.Parent = Container
    
    Utilities.CreateGradient(RightLine, Theme.BorderLight, Theme.Border, 0)
    
    -- Text
    local Label = Instance.new("TextLabel")
    Label.Name = "Text"
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0.25, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Theme.TextSecondary
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.Parent = Container
    
    return Container
end

--════════════════════════════════════════════════════════════════════════════════
-- MAIN WINDOW CREATION
--════════════════════════════════════════════════════════════════════════════════

function Library:CreateWindow(Config)
    Config = Config or {}
    local Theme = Library.CurrentTheme
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Minimized = false
    Window.ToggleKey = Config.Key or Config.ToggleKey or Enum.KeyCode.RightControl
    
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ShenzhenUI_v22"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 100
    
    -- Main window frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 640, 0, 460)
    MainFrame.Position = UDim2.new(0.5, -320, 0.5, -230)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BackgroundTransparency = Theme.Transparency
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    MainFrame.Active = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = MainFrame
    
    -- Multi-layered shadow
    Utilities.CreateShadow(MainFrame, 0.5)
    
    --══════════════════════════════════════════════════════════════════════════════
    -- HEADER
    --══════════════════════════════════════════════════════════════════════════════
    
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 58)
    Header.BackgroundColor3 = Theme.BackgroundSecondary
    Header.BackgroundTransparency = Theme.TransparencySecondary
    Header.BorderSizePixel = 0
    Header.ZIndex = 10
    Header.Parent = MainFrame
    Header.Active = true
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 16)
    HeaderCorner.Parent = Header
    
    -- Bottom fill to hide corner
    local HeaderFill = Instance.new("Frame")
    HeaderFill.Name = "Fill"
    HeaderFill.Size = UDim2.new(1, 0, 0, 20)
    HeaderFill.Position = UDim2.new(0, 0, 1, -20)
    HeaderFill.BackgroundColor3 = Theme.BackgroundSecondary
    HeaderFill.BackgroundTransparency = Theme.TransparencySecondary
    HeaderFill.BorderSizePixel = 0
    HeaderFill.ZIndex = 10
    HeaderFill.Parent = Header
    
    -- Logo
    local Logo = Instance.new("Frame")
    Logo.Name = "Logo"
    Logo.Size = UDim2.new(0, 38, 0, 38)
    Logo.Position = UDim2.new(0, 14, 0, 10)
    Logo.BackgroundColor3 = Theme.Accent
    Logo.BorderSizePixel = 0
    Logo.ZIndex = 11
    Logo.Parent = Header
    
    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 10)
    LogoCorner.Parent = Logo
    
    -- Gradient on logo
    Utilities.CreateGradient(Logo, Theme.Accent, Theme.AccentLight, 135)
    
    local LogoText = Instance.new("TextLabel")
    LogoText.Name = "Text"
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = Config.Logo or "S"
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextSize = 18
    LogoText.ZIndex = 12
    LogoText.Parent = Logo
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 200, 0, 26)
    Title.Position = UDim2.new(0, 62, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = Config.Title or "Shenzhen UI"
    Title.TextColor3 = Theme.TextPrimary
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 17
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 11
    Title.Parent = Header
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(0, 200, 0, 18)
    Subtitle.Position = UDim2.new(0, 62, 0, 32)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = Config.SubTitle or Config.Subtitle or "Premium UI Library"
    Subtitle.TextColor3 = Theme.TextSecondary
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 12
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.ZIndex = 11
    Subtitle.Parent = Header
    
    -- Window controls
    local Controls = Instance.new("Frame")
    Controls.Name = "Controls"
    Controls.Size = UDim2.new(0, 80, 0, 30)
    Controls.Position = UDim2.new(1, -90, 0, 14)
    Controls.BackgroundTransparency = 1
    Controls.ZIndex = 11
    Controls.Parent = Header
    
    local function CreateControlButton(Name, Text, Color, Callback)
        local Btn = Instance.new("TextButton")
        Btn.Name = Name
        Btn.Size = UDim2.new(0, 28, 0, 28)
        Btn.BackgroundColor3 = Color
        Btn.Text = Text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 14
        Btn.AutoButtonColor = false
        Btn.ZIndex = 12
        Btn.Parent = Controls
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 8)
        BtnCorner.Parent = Btn
        
        Btn.MouseEnter:Connect(function()
            Utilities.Tween(Btn, {BackgroundColor3 = Color:Lerp(Color3.fromRGB(255, 255, 255), 0.15)}, 0.15)
        end)
        
        Btn.MouseLeave:Connect(function()
            Utilities.Tween(Btn, {BackgroundColor3 = Color}, 0.15)
        end)
        
        Btn.MouseButton1Down:Connect(function()
            Utilities.Spring(Btn, {Size = UDim2.new(0, 24, 0, 24)}, 0.1)
        end)
        
        Btn.MouseButton1Up:Connect(function()
            Utilities.Spring(Btn, {Size = UDim2.new(0, 28, 0, 28)}, 0.15)
        end)
        
        Btn.MouseButton1Click:Connect(function()
            Callback()
        end)
        
        return Btn
    end
    
    -- Minimize button
    local MinimizeBtn = CreateControlButton("Minimize", "−", Color3.fromRGB(80, 180, 120), function()
        Window.Minimized = not Window.Minimized
        local TargetSize = Window.Minimized and UDim2.new(0, 640, 0, 58) or UDim2.new(0, 640, 0, 460)
        Utilities.Tween(MainFrame, {Size = TargetSize}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    end)
    MinimizeBtn.Position = UDim2.new(0, 0, 0, 1)
    
    -- Close button
    local CloseBtn = CreateControlButton("Close", "×", Color3.fromRGB(220, 80, 80), function()
        Utilities.Tween(MainFrame, {Size = UDim2.new(0, 640, 0, 0)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(0.3, function()
            ScreenGui:Destroy()
        end)
    end)
    CloseBtn.Position = UDim2.new(0, 44, 0, 1)
    
    --══════════════════════════════════════════════════════════════════════════════
    -- CONTENT AREA
    --══════════════════════════════════════════════════════════════════════════════
    
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Position = UDim2.new(0, 12, 0, 66)
    ContentArea.Size = UDim2.new(1, -24, 1, -74)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ZIndex = 5
    ContentArea.Parent = MainFrame
    
    -- Sidebar (Tabs)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = Theme.BackgroundSecondary
    Sidebar.BackgroundTransparency = Theme.TransparencySecondary
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 6
    Sidebar.Parent = ContentArea
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 12)
    SidebarCorner.Parent = Sidebar
    
    -- Tab list (ScrollingFrame)
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabList"
    TabList.Size = UDim2.new(1, -12, 1, -12)
    TabList.Position = UDim2.new(0, 6, 0, 6)
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 3
    TabList.ScrollBarImageColor3 = Theme.Accent
    TabList.ScrollBarImageTransparency = 0.7
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.ZIndex = 7
    TabList.Parent = Sidebar
    TabList.ClipsDescendants = true
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 6)
    TabListLayout.Parent = TabList
    
    -- Content pages container
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Name = "Pages"
    PagesContainer.Position = UDim2.new(0, 172, 0, 0)
    PagesContainer.Size = UDim2.new(1, -172, 1, 0)
    PagesContainer.BackgroundColor3 = Theme.BackgroundSecondary
    PagesContainer.BackgroundTransparency = Theme.TransparencySecondary
    PagesContainer.BorderSizePixel = 0
    PagesContainer.ZIndex = 6
    PagesContainer.ClipsDescendants = true
    PagesContainer.Parent = ContentArea
    
    local PagesCorner = Instance.new("UICorner")
    PagesCorner.CornerRadius = UDim.new(0, 12)
    PagesCorner.Parent = PagesContainer
    
    --══════════════════════════════════════════════════════════════════════════════
    -- DRAGGING SYSTEM
    --══════════════════════════════════════════════════════════════════════════════
    
    local Dragging = false
    local DragStart = nil
    local StartPos = nil
    
    Header.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPos = MainFrame.Position
            
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = Input.Position - DragStart
            MainFrame.Position = UDim2.new(
                StartPos.X.Scale,
                StartPos.X.Offset + Delta.X,
                StartPos.Y.Scale,
                StartPos.Y.Offset + Delta.Y
            )
        end
    end)
    
    --══════════════════════════════════════════════════════════════════════════════
    -- TAB CREATION
    --══════════════════════════════════════════════════════════════════════════════
    
    function Window:CreateTab(TabConfig)
        TabConfig = TabConfig or {}
        local Tab = {}
        Tab.Name = TabConfig.Name or "Tab"
        Tab.Icon = TabConfig.Icon or ""
        
        -- Tab button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = Tab.Name .. "_Button"
        TabButton.Size = UDim2.new(1, 0, 0, 40)
        TabButton.BackgroundColor3 = Theme.BackgroundTertiary
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.ZIndex = 8
        TabButton.Parent = TabList
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 10)
        TabCorner.Parent = TabButton
        
        -- Active indicator (left bar)
        local Indicator = Instance.new("Frame")
        Indicator.Name = "Indicator"
        Indicator.Size = UDim2.new(0, 3, 0, 0)
        Indicator.Position = UDim2.new(0, 0, 0.5, 0)
        Indicator.BackgroundColor3 = Theme.Accent
        Indicator.BorderSizePixel = 0
        Indicator.ZIndex = 9
        Indicator.Parent = TabButton
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 2)
        IndicatorCorner.Parent = Indicator
        
        -- Glow behind indicator
        local IndicatorGlow = Utilities.CreateGlow(Indicator, Theme.Accent, 10)
        IndicatorGlow.ImageTransparency = 1
        
        -- Icon
        local IconLabel = Instance.new("TextLabel")
        IconLabel.Name = "Icon"
        IconLabel.Size = UDim2.new(0, 26, 0, 26)
        IconLabel.Position = UDim2.new(0, 10, 0.5, -13)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Text = Tab.Icon
        IconLabel.TextColor3 = Theme.TextSecondary
        IconLabel.Font = Enum.Font.Gotham
        IconLabel.TextSize = 14
        IconLabel.ZIndex = 9
        IconLabel.Parent = TabButton
        
        -- Text
        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "Text"
        TextLabel.Size = UDim2.new(1, -46, 1, 0)
        TextLabel.Position = UDim2.new(0, 42, 0, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Text = Tab.Name
        TextLabel.TextColor3 = Theme.TextSecondary
        TextLabel.Font = Enum.Font.GothamSemibold
        TextLabel.TextSize = 13
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.ZIndex = 9
        TextLabel.Parent = TabButton
        
        -- Content page
        local Page = Instance.new("ScrollingFrame")
        Page.Name = Tab.Name .. "_Page"
        Page.Size = UDim2.new(1, -16, 1, -16)
        Page.Position = UDim2.new(0, 8, 0, 8)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.ScrollBarImageTransparency = 0.7
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Visible = false
        Page.ZIndex = 7
        Page.Parent = PagesContainer
        Page.ClipsDescendants = true
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.Parent = Page
        
        -- Update canvas size
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 16)
        end)
        
        -- Tab selection logic
        local function SelectTab()
            if Window.CurrentTab == Tab then return end
            
            -- Deselect previous tab
            if Window.CurrentTab then
                local PrevTab = Window.CurrentTab
                Utilities.Tween(PrevTab.Button.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
                Utilities.Tween(PrevTab.Button.Indicator, {Position = UDim2.new(0, 0, 0.5, 0)}, 0.2)
                Utilities.Tween(PrevTab.Button, {BackgroundTransparency = 1}, 0.2)
                Utilities.Tween(PrevTab.Button.Icon, {TextColor3 = Theme.TextSecondary}, 0.2)
                Utilities.Tween(PrevTab.Button.Text, {TextColor3 = Theme.TextSecondary}, 0.2)
                
                -- Fade out page
                Utilities.Tween(PrevTab.Page, {ScrollBarImageTransparency = 1}, 0.15)
                task.delay(0.1, function()
                    PrevTab.Page.Visible = false
                end)
            end
            
            -- Select new tab
            Window.CurrentTab = Tab
            Page.Visible = true
            
            -- Animate indicator
            Utilities.Spring(Indicator, {Size = UDim2.new(0, 3, 0, 24)}, 0.3)
            Utilities.Tween(Indicator, {Position = UDim2.new(0, 0, 0.5, -12)}, 0.3)
            Utilities.Tween(IndicatorGlow, {ImageTransparency = 0.6}, 0.3)
            
            -- Highlight tab
            Utilities.Tween(TabButton, {BackgroundTransparency = 0.7}, 0.2)
            Utilities.Tween(IconLabel, {TextColor3 = Theme.Accent}, 0.2)
            Utilities.Tween(TextLabel, {TextColor3 = Theme.TextPrimary}, 0.2)
        end
        
        TabButton.MouseButton1Click:Connect(function()
            local MousePos = UserInputService:GetMouseLocation()
            Utilities.CreateRipple(TabButton, MousePos.X, MousePos.Y)
            SelectTab()
        end)
        
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Utilities.Tween(TabButton, {BackgroundTransparency = 0.85}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Utilities.Tween(TabButton, {BackgroundTransparency = 1}, 0.15)
            end
        end)
        
        Tab.Button = TabButton
        Tab.Page = Page
        table.insert(Window.Tabs, Tab)
        
        -- Auto-select first tab
        if #Window.Tabs == 1 then
            task.delay(0.2, function()
                SelectTab()
            end)
        end
        
        -- Update sidebar canvas
        TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabList.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 12)
        end)
        
        -- Element creation interface
        local Elements = {}
        
        function Elements:Button(Config)
            return Components.Button:Create(Page, Config)
        end
        
        function Elements:Toggle(Config)
            return Components.Toggle:Create(Page, Config)
        end
        
        function Elements:Slider(Config)
            return Components.Slider:Create(Page, Config)
        end
        
        function Elements:Dropdown(Config)
            return Components.Dropdown:Create(Page, Config)
        end
        
        function Elements:TextBox(Config)
            return Components.TextBox:Create(Page, Config)
        end
        
        function Elements:Label(Config)
            return Components.Label:Create(Page, Config)
        end
        
        function Elements:Section(Config)
            return Components.Section:Create(Page, Config)
        end
        
        return Elements
    end
    
    --══════════════════════════════════════════════════════════════════════════════
    -- WINDOW METHODS
    --══════════════════════════════════════════════════════════════════════════════
    
    function Window:Notify(NotifConfig)
        Library.Notifications:Show(
            NotifConfig.Title or "Notification",
            NotifConfig.Message or "",
            NotifConfig.Type or "Info",
            NotifConfig.Duration or 3
        )
    end
    
    function Window:SetTheme(ThemeName)
        if Library.Themes[ThemeName] then
            Library.CurrentTheme = Library.Themes[ThemeName]
            Window:Notify({
                Title = "Theme Changed",
                Message = "Switched to " .. ThemeName .. " theme",
                Type = "Success"
            })
        end
    end
    
    -- Toggle key
    UserInputService.InputBegan:Connect(function(Input, GameProcessed)
        if not GameProcessed and Input.KeyCode == Window.ToggleKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)
    
    -- Intro animation
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    task.spawn(function()
        task.wait(0.1)
        Utilities.Spring(MainFrame, {Size = UDim2.new(0, 640, 0, 460)}, 0.5)
    end)
    
    -- Welcome notification
    task.delay(0.6, function()
        Window:Notify({
            Title = "Welcome!",
            Message = Config.Title or "Shenzhen UI" .. " loaded successfully",
            Type = "Success",
            Duration = 3
        })
    end)
    
    return Window
end

-- Global notification
function Library:Notify(Config)
    Library.Notifications:Show(
        Config.Title or "Notification",
        Config.Message or "",
        Config.Type or "Info",
        Config.Duration or 3
    )
end

return Library
