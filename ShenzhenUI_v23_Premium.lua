--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                     SHENZHEN UI v2.3 - ULTIMATE PREMIUM                      ║
    ║           Glassmorphism • Snow Effects • Floating Toggle • Rayfield+         ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
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
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

--════════════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
--════════════════════════════════════════════════════════════════════════════════

function Utilities.Tween(Object, Properties, Duration, EasingStyle, EasingDirection)
    local Style = EasingStyle or Enum.EasingStyle.Quart
    local Direction = EasingDirection or Enum.EasingDirection.Out
    local Info = TweenInfo.new(Duration or 0.3, Style, Direction)
    local Tween = TweenService:Create(Object, Info, Properties)
    Tween:Play()
    return Tween
end

function Utilities.Spring(Object, Properties, Duration)
    return Utilities.Tween(Object, Properties, Duration or 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

function Utilities.Smooth(Object, Properties, Duration)
    return Utilities.Tween(Object, Properties, Duration or 0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
end

-- Create layered shadow
function Utilities.CreateShadow(Parent, Intensity)
    Intensity = Intensity or 0.5
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 60, 1, 60)
    Shadow.Position = UDim2.new(0, -30, 0, -30)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6015897843"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 1 - Intensity
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.ZIndex = Parent.ZIndex - 1
    Shadow.Parent = Parent
    
    return Shadow
end

-- Create gradient
function Utilities.CreateGradient(Parent, Color1, Color2, Rotation)
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new(Color1, Color2 or Color1)
    Gradient.Rotation = Rotation or 90
    Gradient.Parent = Parent
    return Gradient
end

-- Create ripple effect
function Utilities.CreateRipple(Parent, X, Y)
    local Ripple = Instance.new("Frame")
    Ripple.Name = "Ripple"
    Ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Ripple.BackgroundTransparency = 0.7
    Ripple.BorderSizePixel = 0
    Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    Ripple.Size = UDim2.new(0, 0, 0, 0)
    Ripple.Position = UDim2.new(0, X - Parent.AbsolutePosition.X, 0, Y - Parent.AbsolutePosition.Y)
    Ripple.ZIndex = Parent.ZIndex + 10
    Ripple.Parent = Parent
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Ripple
    
    local MaxSize = math.max(Parent.AbsoluteSize.X, Parent.AbsoluteSize.Y) * 2
    
    Utilities.Tween(Ripple, {
        Size = UDim2.new(0, MaxSize, 0, MaxSize),
        BackgroundTransparency = 1
    }, 0.6, Enum.EasingStyle.Quart)
    
    task.delay(0.6, function()
        Ripple:Destroy()
    end)
end

-- Create glow effect
function Utilities.CreateGlow(Parent, Color, Size)
    local Glow = Instance.new("ImageLabel")
    Glow.Name = "Glow"
    Glow.Size = UDim2.new(1, Size or 30, 1, Size or 30)
    Glow.Position = UDim2.new(0, -(Size or 30)/2, 0, -(Size or 30)/2)
    Glow.BackgroundTransparency = 1
    Glow.Image = "rbxassetid://5028857084"
    Glow.ImageColor3 = Color or Color3.fromRGB(88, 101, 242)
    Glow.ImageTransparency = 0.8
    Glow.ZIndex = Parent.ZIndex - 1
    Glow.Parent = Parent
    return Glow
end

--════════════════════════════════════════════════════════════════════════════════
-- SNOW EFFECT SYSTEM
--════════════════════════════════════════════════════════════════════════════════

Library.SnowSystem = {}

function Library.SnowSystem:Init(Parent)
    local SnowContainer = Instance.new("Frame")
    SnowContainer.Name = "SnowContainer"
    SnowContainer.Size = UDim2.new(1, 0, 1, 0)
    SnowContainer.BackgroundTransparency = 1
    SnowContainer.ZIndex = 1000
    SnowContainer.Parent = Parent
    
    local Snowflakes = {}
    local MaxSnowflakes = 30
    
    local function CreateSnowflake()
        local Snowflake = Instance.new("Frame")
        Snowflake.Name = "Snowflake"
        Snowflake.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
        Snowflake.Position = UDim2.new(math.random(), 0, -0.05, 0)
        Snowflake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Snowflake.BackgroundTransparency = math.random(30, 70) / 100
        Snowflake.BorderSizePixel = 0
        Snowflake.ZIndex = 1000
        Snowflake.Parent = SnowContainer
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(1, 0)
        Corner.Parent = Snowflake
        
        -- Falling animation
        local FallDuration = math.random(3, 8)
        local SwayAmount = math.random(-30, 30)
        
        local Tween = Utilities.Tween(Snowflake, {
            Position = UDim2.new(Snowflake.Position.X.Scale + (swayAmount/1000), swayAmount, 1.1, 0)
        }, FallDuration, Enum.EasingStyle.Linear)
        
        Tween.Completed:Connect(function()
            Snowflake:Destroy()
        end)
        
        return Snowflake
    end
    
    -- Spawn snowflakes periodically
    task.spawn(function()
        while SnowContainer.Parent do
            if #SnowContainer:GetChildren() < MaxSnowflakes then
                CreateSnowflake()
            end
            task.wait(math.random(10, 30) / 10)
        end
    end)
    
    return SnowContainer
end

--════════════════════════════════════════════════════════════════════════════════
-- THEME SYSTEM
--════════════════════════════════════════════════════════════════════════════════

Library.Themes = {
    Glass = {
        Background = Color3.fromRGB(255, 255, 255),
        BackgroundSecondary = Color3.fromRGB(248, 249, 250),
        BackgroundTertiary = Color3.fromRGB(240, 242, 245),
        
        Transparency = 0.92,
        TransparencySecondary = 0.88,
        TransparencyTertiary = 0.82,
        
        Accent = Color3.fromRGB(88, 101, 242),
        AccentLight = Color3.fromRGB(120, 140, 255),
        AccentDark = Color3.fromRGB(60, 80, 220),
        
        TextPrimary = Color3.fromRGB(30, 30, 40),
        TextSecondary = Color3.fromRGB(90, 95, 110),
        TextTertiary = Color3.fromRGB(140, 145, 160),
        
        Success = Color3.fromRGB(75, 195, 115),
        Warning = Color3.fromRGB(245, 175, 75),
        Error = Color3.fromRGB(235, 95, 95),
        Info = Color3.fromRGB(75, 155, 245),
        
        Border = Color3.fromRGB(225, 228, 232),
        BorderLight = Color3.fromRGB(235, 238, 242),
        
        GradientStart = Color3.fromRGB(88, 101, 242),
        GradientEnd = Color3.fromRGB(140, 100, 255)
    },
    
    Dark = {
        Background = Color3.fromRGB(22, 24, 28),
        BackgroundSecondary = Color3.fromRGB(30, 33, 38),
        BackgroundTertiary = Color3.fromRGB(40, 44, 52),
        
        Transparency = 0.15,
        TransparencySecondary = 0.1,
        TransparencyTertiary = 0.05,
        
        Accent = Color3.fromRGB(88, 101, 242),
        AccentLight = Color3.fromRGB(120, 140, 255),
        AccentDark = Color3.fromRGB(60, 80, 220),
        
        TextPrimary = Color3.fromRGB(245, 247, 250),
        TextSecondary = Color3.fromRGB(175, 180, 195),
        TextTertiary = Color3.fromRGB(120, 125, 140),
        
        Success = Color3.fromRGB(75, 195, 115),
        Warning = Color3.fromRGB(245, 175, 75),
        Error = Color3.fromRGB(235, 95, 95),
        Info = Color3.fromRGB(75, 155, 245),
        
        Border = Color3.fromRGB(50, 55, 65),
        BorderLight = Color3.fromRGB(60, 65, 75),
        
        GradientStart = Color3.fromRGB(88, 101, 242),
        GradientEnd = Color3.fromRGB(140, 100, 255)
    },
    
    Midnight = {
        Background = Color3.fromRGB(15, 17, 26),
        BackgroundSecondary = Color3.fromRGB(25, 27, 40),
        BackgroundTertiary = Color3.fromRGB(35, 38, 55),
        
        Transparency = 0.08,
        TransparencySecondary = 0.05,
        TransparencyTertiary = 0.02,
        
        Accent = Color3.fromRGB(140, 100, 255),
        AccentLight = Color3.fromRGB(170, 140, 255),
        AccentDark = Color3.fromRGB(110, 70, 220),
        
        TextPrimary = Color3.fromRGB(245, 245, 255),
        TextSecondary = Color3.fromRGB(180, 180, 200),
        TextTertiary = Color3.fromRGB(130, 130, 155),
        
        Success = Color3.fromRGB(95, 215, 145),
        Warning = Color3.fromRGB(255, 195, 95),
        Error = Color3.fromRGB(255, 115, 115),
        Info = Color3.fromRGB(115, 175, 255),
        
        Border = Color3.fromRGB(45, 48, 65),
        BorderLight = Color3.fromRGB(55, 58, 75),
        
        GradientStart = Color3.fromRGB(140, 100, 255),
        GradientEnd = Color3.fromRGB(200, 120, 255)
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
    
    local TypeColors = {
        Info = Theme.Accent,
        Success = Theme.Success,
        Warning = Theme.Warning,
        Error = Theme.Error
    }
    
    local TypeIcons = {
        Info = "i",
        Success = "v",
        Warning = "!",
        Error = "x"
    }
    
    local NotifGui = Instance.new("ScreenGui")
    NotifGui.Name = "Notification"
    NotifGui.Parent = CoreGui
    NotifGui.DisplayOrder = 9999
    NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 340, 0, 85)
    Container.Position = UDim2.new(1, 30, 0.85, 0)
    Container.BackgroundColor3 = Theme.Background
    Container.BackgroundTransparency = Theme.Transparency
    Container.BorderSizePixel = 0
    Container.Parent = NotifGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 14)
    Corner.Parent = Container
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Border
    Stroke.Transparency = 0.4
    Stroke.Thickness = 1
    Stroke.Parent = Container
    
    Utilities.CreateShadow(Container, 0.35)
    
    -- Icon
    local IconBg = Instance.new("Frame")
    IconBg.Size = UDim2.new(0, 50, 1, 0)
    IconBg.BackgroundColor3 = TypeColors[Type]
    IconBg.BorderSizePixel = 0
    IconBg.Parent = Container
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 14)
    IconCorner.Parent = IconBg
    
    local IconMask = Instance.new("Frame")
    IconMask.Size = UDim2.new(0, 15, 1, 0)
    IconMask.Position = UDim2.new(1, -7, 0, 0)
    IconMask.BackgroundColor3 = TypeColors[Type]
    IconMask.BorderSizePixel = 0
    IconMask.Parent = IconBg
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(1, 0, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = TypeIcons[Type]
    Icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 22
    Icon.Parent = IconBg
    
    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -75, 0, 24)
    TitleLabel.Position = UDim2.new(0, 60, 0, 14)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Theme.TextPrimary
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Container
    
    -- Message
    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Size = UDim2.new(1, -75, 0, 42)
    MessageLabel.Position = UDim2.new(0, 60, 0, 36)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = Message
    MessageLabel.TextColor3 = Theme.TextSecondary
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextSize = 13
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextWrapped = true
    MessageLabel.Parent = Container
    
    -- Progress bar
    local Progress = Instance.new("Frame")
    Progress.Size = UDim2.new(1, 0, 0, 3)
    Progress.Position = UDim2.new(0, 0, 1, -3)
    Progress.BackgroundColor3 = TypeColors[Type]
    Progress.BorderSizePixel = 0
    Progress.Parent = Container
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(0, 2)
    ProgressCorner.Parent = Progress
    
    -- Animate in
    Utilities.Spring(Container, {Position = UDim2.new(1, -360, 0.85, 0)})
    Utilities.Tween(Progress, {Size = UDim2.new(0, 0, 0, 3)}, Duration, Enum.EasingStyle.Linear)
    
    task.delay(Duration, function()
        Utilities.Tween(Container, {Position = UDim2.new(1, 30, 0.85, 0)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(0.4, function()
            NotifGui:Destroy()
        end)
    end)
end

--════════════════════════════════════════════════════════════════════════════════
-- COMPONENTS
--════════════════════════════════════════════════════════════════════════════════

Components.Button = {}

function Components.Button:Create(Parent, Config)
    local Theme = Library.CurrentTheme
    Config = Config or {}
    
    local Text = Config.Text or Config.Name or "Button"
    local Callback = Config.Callback or function() end
    local HasIcon = Config.Icon ~= nil
    
    local Container = Instance.new("Frame")
    Container.Name = "Button_" .. Text
    Container.Size = UDim2.new(1, 0, 0, 46)
    Container.BackgroundTransparency = 1
    Container.ClipsDescendants = true
    Container.Parent = Parent
    
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
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Button
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Border
    Stroke.Transparency = 0.6
    Stroke.Thickness = 1
    Stroke.Parent = Button
    
    -- Gradient overlay
    local GradientFrame = Instance.new("Frame")
    GradientFrame.Size = UDim2.new(1, 0, 1, 0)
    GradientFrame.BackgroundTransparency = 1
    GradientFrame.ZIndex = 2
    GradientFrame.Parent = Button
    
    local Gradient = Utilities.CreateGradient(GradientFrame, Theme.GradientStart, Theme.GradientEnd, 135)
    Gradient.Transparency = NumberSequence.new(1)
    
    -- Icon
    if HasIcon then
        local Icon = Instance.new("TextLabel")
        Icon.Name = "Icon"
        Icon.Size = UDim2.new(0, 26, 0, 26)
        Icon.Position = UDim2.new(0, 14, 0.5, -13)
        Icon.BackgroundTransparency = 1
        Icon.Text = Config.Icon
        Icon.TextColor3 = Theme.TextSecondary
        Icon.Font = Enum.Font.GothamBold
        Icon.TextSize = 14
        Icon.ZIndex = 3
        Icon.Parent = Button
    end
    
    -- Text
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, HasIcon and -100 or -70, 1, 0)
    Label.Position = UDim2.new(0, HasIcon and 48 or 18, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Theme.TextPrimary
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 3
    Label.Parent = Button
    
    -- Arrow
    local Arrow = Instance.new("ImageLabel")
    Arrow.Name = "Arrow"
    Arrow.Size = UDim2.new(0, 18, 0, 18)
    Arrow.Position = UDim2.new(1, -34, 0.5, -9)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "rbxassetid://7072706796"
    Arrow.ImageColor3 = Theme.TextTertiary
    Arrow.ImageTransparency = 0.4
    Arrow.ZIndex = 3
    Arrow.Parent = Button
    
    -- Hover effects
    Button.MouseEnter:Connect(function()
        Utilities.Tween(Button, {BackgroundTransparency = 0.5}, 0.2)
        Utilities.Tween(Gradient, {Transparency = NumberSequence.new(0.85)}, 0.2)
        Utilities.Tween(Label, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        Utilities.Tween(Arrow, {ImageColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -28, 0.5, -9)}, 0.2)
        Utilities.Tween(Stroke, {Color = Theme.Accent, Transparency = 0.3}, 0.2)
    end)
    
    Button.MouseLeave:Connect(function()
        Utilities.Tween(Button, {BackgroundTransparency = Theme.TransparencyTertiary}, 0.2)
        Utilities.Tween(Gradient, {Transparency = NumberSequence.new(1)}, 0.2)
        Utilities.Tween(Label, {TextColor3 = Theme.TextPrimary}, 0.2)
        Utilities.Tween(Arrow, {ImageColor3 = Theme.TextTertiary, Position = UDim2.new(1, -34, 0.5, -9)}, 0.2)
        Utilities.Tween(Stroke, {Color = Theme.Border, Transparency = 0.6}, 0.2)
    end)
    
    Button.MouseButton1Down:Connect(function()
        Utilities.Spring(Button, {Size = UDim2.new(0.97, 0, 0.92, 0)}, 0.15)
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

-- Toggle Component
Components.Toggle = {}

function Components.Toggle:Create(Parent, Config)
    local Theme = Library.CurrentTheme
    Config = Config or {}
    
    local Text = Config.Text or Config.Name or "Toggle"
    local Default = Config.Default or false
    local Callback = Config.Callback or function() end
    
    local State = Default
    
    local Container = Instance.new("Frame")
    Container.Name = "Toggle_" .. Text
    Container.Size = UDim2.new(1, 0, 0, 46)
    Container.BackgroundTransparency = 1
    Container.Parent = Parent
    
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Theme.BackgroundTertiary
    Background.BackgroundTransparency = Theme.TransparencyTertiary
    Background.BorderSizePixel = 0
    Background.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Background
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Border
    Stroke.Transparency = 0.6
    Stroke.Thickness = 1
    Stroke.Parent = Background
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, -100, 1, 0)
    Label.Position = UDim2.new(0, 18, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Theme.TextPrimary
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Background
    
    -- Switch
    local Switch = Instance.new("Frame")
    Switch.Name = "Switch"
    Switch.Size = UDim2.new(0, 54, 0, 30)
    Switch.Position = UDim2.new(1, -68, 0.5, -15)
    Switch.BackgroundColor3 = Theme.BackgroundSecondary
    Switch.BorderSizePixel = 0
    Switch.Parent = Background
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch
    
    -- Knob
    local Knob = Instance.new("Frame")
    Knob.Name = "Knob"
    Knob.Size = UDim2.new(0, 24, 0, 24)
    Knob.Position = State and UDim2.new(0, 27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Switch
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob
    
    Utilities.CreateShadow(Knob, 0.25)
    
    -- Status dot
    local Dot = Instance.new("Frame")
    Dot.Name = "Dot"
    Dot.Size = UDim2.new(0, 6, 0, 6)
    Dot.Position = State and UDim2.new(0, 38, 0.5, -3) or UDim2.new(0, 9, 0.5, -3)
    Dot.BackgroundColor3 = State and Theme.Success or Theme.TextTertiary
    Dot.BorderSizePixel = 0
    Dot.Parent = Switch
    
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot
    
    local function Update()
        if State then
            Utilities.Tween(Switch, {BackgroundColor3 = Theme.Accent}, 0.25)
            Utilities.Tween(Knob, {Position = UDim2.new(0, 27, 0.5, -12)}, 0.25)
            Utilities.Tween(Dot, {Position = UDim2.new(0, 38, 0.5, -3), BackgroundColor3 = Theme.Success}, 0.25)
            Utilities.Tween(Stroke, {Color = Theme.Accent, Transparency = 0.35}, 0.2)
        else
            Utilities.Tween(Switch, {BackgroundColor3 = Theme.BackgroundSecondary}, 0.25)
            Utilities.Tween(Knob, {Position = UDim2.new(0, 3, 0.5, -12)}, 0.25)
            Utilities.Tween(Dot, {Position = UDim2.new(0, 9, 0.5, -3), BackgroundColor3 = Theme.TextTertiary}, 0.25)
            Utilities.Tween(Stroke, {Color = Theme.Border, Transparency = 0.6}, 0.2)
        end
        Callback(State)
    end
    
    if State then
        Switch.BackgroundColor3 = Theme.Accent
        Dot.Position = UDim2.new(0, 38, 0.5, -3)
        Dot.BackgroundColor3 = Theme.Success
    end
    
    local ClickArea = Instance.new("TextButton")
    ClickArea.Name = "ClickArea"
    ClickArea.Size = UDim2.new(1, 0, 1, 0)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""
    ClickArea.Parent = Background
    
    ClickArea.MouseEnter:Connect(function()
        if not State then
            Utilities.Tween(Background, {BackgroundTransparency = 0.6}, 0.15)
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

-- Slider Component
Components.Slider = {}

function Components.Slider:Create(Parent, Config)
    local Theme = Library.CurrentTheme
    Config = Config or {}
    
    local Text = Config.Text or Config.Name or "Slider"
    local Min = Config.Min or 0
    local Max = Config.Max or 100
    local Default = math.clamp(Config.Default or Min, Min, Max)
    local Suffix = Config.Suffix or ""
    local Callback = Config.Callback or function() end
    
    local CurrentValue = Default
    
    local Container = Instance.new("Frame")
    Container.Name = "Slider_" .. Text
    Container.Size = UDim2.new(1, 0, 0, 68)
    Container.BackgroundTransparency = 1
    Container.Parent = Parent
    
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Theme.BackgroundTertiary
    Background.BackgroundTransparency = Theme.TransparencyTertiary
    Background.BorderSizePixel = 0
    Background.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Background
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Border
    Stroke.Transparency = 0.6
    Stroke.Thickness = 1
    Stroke.Parent = Background
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0.5, 0, 0, 26)
    Title.Position = UDim2.new(0, 18, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = Text
    Title.TextColor3 = Theme.TextPrimary
    Title.Font = Enum.Font.GothamSemibold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Background
    
    local ValueBox = Instance.new("TextLabel")
    ValueBox.Name = "Value"
    ValueBox.Size = UDim2.new(0, 65, 0, 26)
    ValueBox.Position = UDim2.new(1, -77, 0, 10)
    ValueBox.BackgroundColor3 = Theme.BackgroundSecondary
    ValueBox.BackgroundTransparency = 0.4
    ValueBox.Text = tostring(CurrentValue) .. Suffix
    ValueBox.TextColor3 = Theme.Accent
    ValueBox.Font = Enum.Font.GothamBold
    ValueBox.TextSize = 12
    ValueBox.Parent = Background
    
    local ValueCorner = Instance.new("UICorner")
    ValueCorner.CornerRadius = UDim.new(0, 8)
    ValueCorner.Parent = ValueBox
    
    -- Track
    local Track = Instance.new("Frame")
    Track.Name = "Track"
    Track.Size = UDim2.new(1, -36, 0, 10)
    Track.Position = UDim2.new(0, 18, 0, 44)
    Track.BackgroundColor3 = Theme.BackgroundSecondary
    Track.BorderSizePixel = 0
    Track.Parent = Background
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track
    
    -- Fill
    local Percent = (CurrentValue - Min) / (Max - Min)
    local Fill = Instance.new("Frame")
    Fill.Name = "Fill"
    Fill.Size = UDim2.new(Percent, 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill
    
    Utilities.CreateGradient(Fill, Theme.GradientStart, Theme.GradientEnd, 0)
    
    -- Knob
    local Knob = Instance.new("Frame")
    Knob.Name = "Knob"
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.Position = UDim2.new(Percent, -10, 0.5, -10)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob
    
    Utilities.CreateShadow(Knob, 0.35)
    Utilities.CreateGlow(Knob, Theme.Accent, 15)
    
    local Dragging = false
    
    local function Update(Input)
        local TrackPos = Track.AbsolutePosition.X
        local TrackSize = Track.AbsoluteSize.X
        local MouseX = Input.Position.X
        
        local NewPercent = math.clamp((MouseX - TrackPos) / TrackSize, 0, 1)
        local NewValue = math.floor(Min + (Max - Min) * NewPercent)
        
        if NewValue ~= CurrentValue then
            CurrentValue = NewValue
            ValueBox.Text = tostring(NewValue) .. Suffix
            
            Utilities.Tween(Fill, {Size = UDim2.new(NewPercent, 0, 1, 0)}, 0.05)
            Utilities.Tween(Knob, {Position = UDim2.new(NewPercent, -10, 0.5, -10)}, 0.05)
            
            Callback(NewValue)
        end
    end
    
    Track.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            Update(Input)
        end
    end)
    
    Knob.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            Utilities.Tween(Knob, {Size = UDim2.new(0, 24, 0, 24)}, 0.1)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            if Dragging then
                Dragging = false
                Utilities.Tween(Knob, {Size = UDim2.new(0, 20, 0, 20)}, 0.1)
            end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            Update(Input)
        end
    end)
    
    Track.MouseEnter:Connect(function()
        Utilities.Tween(Stroke, {Color = Theme.Accent, Transparency = 0.4}, 0.2)
    end)
    
    Track.MouseLeave:Connect(function()
        if not Dragging then
            Utilities.Tween(Stroke, {Color = Theme.Border, Transparency = 0.6}, 0.2)
        end
    end)
    
    return {
        Set = function(Value)
            CurrentValue = math.clamp(Value, Min, Max)
            local NewPercent = (CurrentValue - Min) / (Max - Min)
            ValueBox.Text = tostring(CurrentValue) .. Suffix
            Utilities.Tween(Fill, {Size = UDim2.new(NewPercent, 0, 1, 0)}, 0.2)
            Utilities.Tween(Knob, {Position = UDim2.new(NewPercent, -10, 0.5, -10)}, 0.2)
            Callback(CurrentValue)
        end,
        Get = function()
            return CurrentValue
        end
    }
end

-- Dropdown Component
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
    
    local Container = Instance.new("Frame")
    Container.Name = "Dropdown_" .. Text
    Container.Size = UDim2.new(1, 0, 0, 48)
    Container.BackgroundTransparency = 1
    Container.ClipsDescendants = true
    Container.Parent = Parent
    
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 0, 48)
    Background.BackgroundColor3 = Theme.BackgroundTertiary
    Background.BackgroundTransparency = Theme.TransparencyTertiary
    Background.BorderSizePixel = 0
    Background.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Background
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Border
    Stroke.Transparency = 0.6
    Stroke.Thickness = 1
    Stroke.Parent = Background
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(0.4, 0, 0, 48)
    Label.Position = UDim2.new(0, 18, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Theme.TextPrimary
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Background
    
    local ValueDisplay = Instance.new("TextLabel")
    ValueDisplay.Name = "Value"
    ValueDisplay.Size = UDim2.new(0, 110, 0, 30)
    ValueDisplay.Position = UDim2.new(1, -130, 0.5, -15)
    ValueDisplay.BackgroundColor3 = Theme.BackgroundSecondary
    ValueDisplay.BackgroundTransparency = 0.4
    ValueDisplay.Text = Selected
    ValueDisplay.TextColor3 = Theme.TextSecondary
    ValueDisplay.Font = Enum.Font.Gotham
    ValueDisplay.TextSize = 12
    ValueDisplay.Parent = Background
    
    local ValueCorner = Instance.new("UICorner")
    ValueCorner.CornerRadius = UDim.new(0, 8)
    ValueCorner.Parent = ValueDisplay
    
    local Arrow = Instance.new("ImageLabel")
    Arrow.Name = "Arrow"
    Arrow.Size = UDim2.new(0, 16, 0, 16)
    Arrow.Position = UDim2.new(1, -26, 0.5, -8)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "rbxassetid://7072706663"
    Arrow.ImageColor3 = Theme.TextTertiary
    Arrow.ImageTransparency = 0.4
    Arrow.Parent = Background
    
    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Name = "Options"
    OptionsFrame.Size = UDim2.new(1, -20, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 10, 0, 54)
    OptionsFrame.BackgroundColor3 = Theme.BackgroundSecondary
    OptionsFrame.BackgroundTransparency = 0.3
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.Visible = false
    OptionsFrame.Parent = Background
    
    local OptionsCorner = Instance.new("UICorner")
    OptionsCorner.CornerRadius = UDim.new(0, 10)
    OptionsCorner.Parent = OptionsFrame
    
    local OptionsList = Instance.new("UIListLayout")
    OptionsList.Padding = UDim.new(0, 5)
    OptionsList.Parent = OptionsFrame
    
    local function CreateOption(OptionText)
        local OptionBtn = Instance.new("TextButton")
        OptionBtn.Name = OptionText
        OptionBtn.Size = UDim2.new(1, 0, 0, 34)
        OptionBtn.BackgroundColor3 = Theme.BackgroundTertiary
        OptionBtn.BackgroundTransparency = 0.5
        OptionBtn.Text = OptionText
        OptionBtn.TextColor3 = Theme.TextPrimary
        OptionBtn.Font = Enum.Font.Gotham
        OptionBtn.TextSize = 13
        OptionBtn.Parent = OptionsFrame
        
        local OptionCorner = Instance.new("UICorner")
        OptionCorner.CornerRadius = UDim.new(0, 8)
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
            
            Expanded = false
            Utilities.Tween(Arrow, {Rotation = 0}, 0.2)
            Utilities.Tween(Container, {Size = UDim2.new(1, 0, 0, 48)}, 0.3)
            task.delay(0.3, function()
                OptionsFrame.Visible = false
            end)
        end)
    end
    
    for _, Option in ipairs(Options) do
        CreateOption(Option)
    end
    
    local ClickArea = Instance.new("TextButton")
    ClickArea.Name = "ClickArea"
    ClickArea.Size = UDim2.new(1, 0, 0, 48)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""
    ClickArea.Parent = Background
    
    ClickArea.MouseEnter:Connect(function()
        Utilities.Tween(Stroke, {Color = Theme.Accent, Transparency = 0.4}, 0.2)
    end)
    
    ClickArea.MouseLeave:Connect(function()
        if not Expanded then
            Utilities.Tween(Stroke, {Color = Theme.Border, Transparency = 0.6}, 0.2)
        end
    end)
    
    ClickArea.MouseButton1Click:Connect(function()
        Expanded = not Expanded
        
        if Expanded then
            OptionsFrame.Visible = true
            local TotalHeight = #Options * 39 + 12
            Utilities.Tween(Container, {Size = UDim2.new(1, 0, 0, 56 + TotalHeight)}, 0.3)
            Utilities.Tween(Arrow, {Rotation = 180}, 0.2)
        else
            Utilities.Tween(Arrow, {Rotation = 0}, 0.2)
            Utilities.Tween(Container, {Size = UDim2.new(1, 0, 0, 48)}, 0.3)
            task.delay(0.3, function()
                OptionsFrame.Visible = false
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
            for _, Child in ipairs(OptionsFrame:GetChildren()) do
                if Child:IsA("TextButton") then
                    Child:Destroy()
                end
            end
            for _, Option in ipairs(NewOptions) do
                CreateOption(Option)
            end
        end
    }
end

-- TextBox Component
Components.TextBox = {}

function Components.TextBox:Create(Parent, Config)
    local Theme = Library.CurrentTheme
    Config = Config or {}
    
    local Text = Config.Text or Config.Name or "TextBox"
    local Placeholder = Config.Placeholder or "Enter text..."
    local Default = Config.Default or ""
    local Callback = Config.Callback or function() end
    
    local Container = Instance.new("Frame")
    Container.Name = "TextBox_" .. Text
    Container.Size = UDim2.new(1, 0, 0, 78)
    Container.BackgroundTransparency = 1
    Container.Parent = Parent
    
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Theme.BackgroundTertiary
    Background.BackgroundTransparency = Theme.TransparencyTertiary
    Background.BorderSizePixel = 0
    Background.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Background
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Border
    Stroke.Transparency = 0.6
    Stroke.Thickness = 1
    Stroke.Parent = Background
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, -20, 0, 24)
    Label.Position = UDim2.new(0, 16, 0, 10)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Theme.TextPrimary
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Background
    
    local InputFrame = Instance.new("Frame")
    InputFrame.Name = "InputFrame"
    InputFrame.Size = UDim2.new(1, -24, 0, 34)
    InputFrame.Position = UDim2.new(0, 12, 0, 36)
    InputFrame.BackgroundColor3 = Theme.BackgroundSecondary
    InputFrame.BackgroundTransparency = 0.4
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = Background
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 10)
    InputCorner.Parent = InputFrame
    
    local FocusLine = Instance.new("Frame")
    FocusLine.Name = "FocusLine"
    FocusLine.Size = UDim2.new(0, 0, 0, 2)
    FocusLine.Position = UDim2.new(0.5, 0, 1, -2)
    FocusLine.BackgroundColor3 = Theme.Accent
    FocusLine.BorderSizePixel = 0
    FocusLine.Parent = InputFrame
    
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
    
    TextBox.Focused:Connect(function()
        Utilities.Tween(FocusLine, {Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2)}, 0.25)
        Utilities.Tween(Stroke, {Color = Theme.Accent, Transparency = 0.4}, 0.2)
    end)
    
    TextBox.FocusLost:Connect(function()
        Utilities.Tween(FocusLine, {Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.5, 0, 1, -2)}, 0.25)
        Utilities.Tween(Stroke, {Color = Theme.Border, Transparency = 0.6}, 0.2)
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

-- Label Component
Components.Label = {}

function Components.Label:Create(Parent, Config)
    local Theme = Library.CurrentTheme
    Config = Config or {}
    
    local Text = Config.Text or "Label"
    local Style = Config.Style or "Normal"
    
    local Container = Instance.new("Frame")
    Container.Name = "Label_" .. Text
    Container.Size = UDim2.new(1, 0, 0, Style == "Title" and 34 or 26)
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

-- Section Component
Components.Section = {}

function Components.Section:Create(Parent, Config)
    local Theme = Library.CurrentTheme
    Config = Config or {}
    
    local Text = Config.Text or Config.Name or "Section"
    
    local Container = Instance.new("Frame")
    Container.Name = "Section_" .. Text
    Container.Size = UDim2.new(1, 0, 0, 38)
    Container.BackgroundTransparency = 1
    Container.Parent = Parent
    
    local LeftLine = Instance.new("Frame")
    LeftLine.Name = "LeftLine"
    LeftLine.Size = UDim2.new(0.28, 0, 0, 1)
    LeftLine.Position = UDim2.new(0, 0, 0.5, 0)
    LeftLine.BackgroundColor3 = Theme.Border
    LeftLine.BorderSizePixel = 0
    LeftLine.Parent = Container
    
    local RightLine = Instance.new("Frame")
    RightLine.Name = "RightLine"
    RightLine.Size = UDim2.new(0.28, 0, 0, 1)
    RightLine.Position = UDim2.new(0.72, 0, 0.5, 0)
    RightLine.BackgroundColor3 = Theme.Border
    RightLine.BorderSizePixel = 0
    RightLine.Parent = Container
    
    local Label = Instance.new("TextLabel")
    Label.Name = "Text"
    Label.Size = UDim2.new(0.44, 0, 1, 0)
    Label.Position = UDim2.new(0.28, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = Theme.TextSecondary
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.Parent = Container
    
    return Container
end

--════════════════════════════════════════════════════════════════════════════════
-- FLOATING TOGGLE BUTTON
--════════════════════════════════════════════════════════════════════════════════

Library.FloatingToggle = {}

function Library.FloatingToggle:Create(Window, Config)
    Config = Config or {}
    local Theme = Library.CurrentTheme
    
    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "FloatingToggle"
    ToggleGui.Parent = CoreGui
    ToggleGui.DisplayOrder = 9998
    ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local Button = Instance.new("TextButton")
    Button.Name = "ToggleButton"
    Button.Size = UDim2.new(0, 55, 0, 55)
    Button.Position = Config.Position or UDim2.new(0, 25, 0.5, -27)
    Button.BackgroundColor3 = Theme.Accent
    Button.Text = "S"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 22
    Button.AutoButtonColor = false
    Button.Parent = ToggleGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Button
    
    Utilities.CreateGradient(Button, Theme.GradientStart, Theme.GradientEnd, 135)
    Utilities.CreateShadow(Button, 0.5)
    
    -- Glow ring
    local GlowRing = Instance.new("Frame")
    GlowRing.Name = "GlowRing"
    GlowRing.Size = UDim2.new(1, 15, 1, 15)
    GlowRing.Position = UDim2.new(0, -7.5, 0, -7.5)
    GlowRing.BackgroundTransparency = 1
    GlowRing.BorderSizePixel = 0
    GlowRing.ZIndex = Button.ZIndex - 1
    GlowRing.Parent = Button
    
    local RingCorner = Instance.new("UICorner")
    RingCorner.CornerRadius = UDim.new(1, 0)
    RingCorner.Parent = GlowRing
    
    local RingStroke = Instance.new("UIStroke")
    RingStroke.Color = Theme.Accent
    RingStroke.Thickness = 2
    RingStroke.Transparency = 0.6
    RingStroke.Parent = GlowRing
    
    -- Pulse animation
    task.spawn(function()
        while Button.Parent do
            Utilities.Tween(RingStroke, {Transparency = 0.3}, 1)
            Utilities.Tween(GlowRing, {Size = UDim2.new(1, 25, 1, 25), Position = UDim2.new(0, -12.5, 0, -12.5)}, 1)
            task.wait(1)
            Utilities.Tween(RingStroke, {Transparency = 0.6}, 1)
            Utilities.Tween(GlowRing, {Size = UDim2.new(1, 15, 1, 15), Position = UDim2.new(0, -7.5, 0, -7.5)}, 1)
            task.wait(1)
        end
    end)
    
    -- Hover
    Button.MouseEnter:Connect(function()
        Utilities.Spring(Button, {Size = UDim2.new(0, 62, 0, 62)}, 0.3)
    end)
    
    Button.MouseLeave:Connect(function()
        Utilities.Spring(Button, {Size = UDim2.new(0, 55, 0, 55)}, 0.3)
    end)
    
    Button.MouseButton1Down:Connect(function()
        Utilities.Spring(Button, {Size = UDim2.new(0, 48, 0, 48)}, 0.15)
    end)
    
    Button.MouseButton1Up:Connect(function()
        Utilities.Spring(Button, {Size = UDim2.new(0, 55, 0, 55)}, 0.2)
    end)
    
    return ToggleGui, Button
end

--════════════════════════════════════════════════════════════════════════════════
-- MAIN WINDOW
--════════════════════════════════════════════════════════════════════════════════

function Library:CreateWindow(Config)
    Config = Config or {}
    local Theme = Library.CurrentTheme
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Minimized = false
    Window.Visible = true
    Window.ToggleKey = Config.Key or Config.ToggleKey or Enum.KeyCode.RightControl
    
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ShenzhenUI_v23"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 100
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 680, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -340, 0.5, -240)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BackgroundTransparency = Theme.Transparency
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    MainFrame.Active = false
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 20)
    MainCorner.Parent = MainFrame
    
    -- Border stroke
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Border
    MainStroke.Transparency = 0.5
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame
    
    Utilities.CreateShadow(MainFrame, 0.4)
    
    -- Snow effect
    Library.SnowSystem:Init(MainFrame)
    
    --═══════════════════════════════════════════════════════════════════════════
    -- HEADER (ZIndex: 100)
    --═══════════════════════════════════════════════════════════════════════════
    
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 65)
    Header.BackgroundColor3 = Theme.BackgroundSecondary
    Header.BackgroundTransparency = Theme.TransparencySecondary
    Header.BorderSizePixel = 0
    Header.ZIndex = 100
    Header.Parent = MainFrame
    Header.Active = true
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 20)
    HeaderCorner.Parent = Header
    
    local HeaderFill = Instance.new("Frame")
    HeaderFill.Name = "Fill"
    HeaderFill.Size = UDim2.new(1, 0, 0, 25)
    HeaderFill.Position = UDim2.new(0, 0, 1, -25)
    HeaderFill.BackgroundColor3 = Theme.BackgroundSecondary
    HeaderFill.BackgroundTransparency = Theme.TransparencySecondary
    HeaderFill.BorderSizePixel = 0
    HeaderFill.ZIndex = 100
    HeaderFill.Parent = Header
    
    -- Logo
    local Logo = Instance.new("Frame")
    Logo.Name = "Logo"
    Logo.Size = UDim2.new(0, 44, 0, 44)
    Logo.Position = UDim2.new(0, 18, 0, 10)
    Logo.BackgroundColor3 = Theme.Accent
    Logo.BorderSizePixel = 0
    Logo.ZIndex = 101
    Logo.Parent = Header
    
    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 12)
    LogoCorner.Parent = Logo
    
    Utilities.CreateGradient(Logo, Theme.GradientStart, Theme.GradientEnd, 135)
    
    local LogoText = Instance.new("TextLabel")
    LogoText.Name = "Text"
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = Config.Logo or "S"
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.Font = Enum.Font.GothamBold
    LogoText.TextSize = 20
    LogoText.ZIndex = 102
    LogoText.Parent = Logo
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 220, 0, 28)
    Title.Position = UDim2.new(0, 72, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = Config.Title or "Shenzhen UI"
    Title.TextColor3 = Theme.TextPrimary
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 101
    Title.Parent = Header
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(0, 220, 0, 20)
    Subtitle.Position = UDim2.new(0, 72, 0, 34)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = Config.SubTitle or Config.Subtitle or "Premium UI Library"
    Subtitle.TextColor3 = Theme.TextSecondary
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 12
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.ZIndex = 101
    Subtitle.Parent = Header
    
    -- Controls
    local Controls = Instance.new("Frame")
    Controls.Name = "Controls"
    Controls.Size = UDim2.new(0, 85, 0, 34)
    Controls.Position = UDim2.new(1, -95, 0, 15)
    Controls.BackgroundTransparency = 1
    Controls.ZIndex = 101
    Controls.Parent = Header
    
    local function CreateControl(Name, Text, Color, Callback)
        local Btn = Instance.new("TextButton")
        Btn.Name = Name
        Btn.Size = UDim2.new(0, 34, 0, 34)
        Btn.BackgroundColor3 = Color
        Btn.Text = Text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 16
        Btn.AutoButtonColor = false
        Btn.ZIndex = 102
        Btn.Parent = Controls
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 10)
        Corner.Parent = Btn
        
        Btn.MouseEnter:Connect(function()
            Utilities.Tween(Btn, {BackgroundColor3 = Color:Lerp(Color3.fromRGB(255, 255, 255), 0.12)}, 0.15)
        end)
        
        Btn.MouseLeave:Connect(function()
            Utilities.Tween(Btn, {BackgroundColor3 = Color}, 0.15)
        end)
        
        Btn.MouseButton1Down:Connect(function()
            Utilities.Spring(Btn, {Size = UDim2.new(0, 28, 0, 28)}, 0.1)
        end)
        
        Btn.MouseButton1Up:Connect(function()
            Utilities.Spring(Btn, {Size = UDim2.new(0, 34, 0, 34)}, 0.15)
        end)
        
        Btn.MouseButton1Click:Connect(Callback)
        
        return Btn
    end
    
    CreateControl("Minimize", "−", Color3.fromRGB(75, 185, 110), function()
        Window.Minimized = not Window.Minimized
        local TargetSize = Window.Minimized and UDim2.new(0, 680, 0, 65) or UDim2.new(0, 680, 0, 480)
        Utilities.Tween(MainFrame, {Size = TargetSize}, 0.4, Enum.EasingStyle.Quart)
    end)
    
    CreateControl("Close", "×", Color3.fromRGB(225, 85, 85), function()
        Utilities.Tween(MainFrame, {Size = UDim2.new(0, 680, 0, 0)}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(0.35, function()
            ScreenGui:Destroy()
        end)
    end).Position = UDim2.new(0, 51, 0, 0)
    
    --═══════════════════════════════════════════════════════════════════════════
    -- CONTENT AREA
    --═══════════════════════════════════════════════════════════════════════════
    
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Position = UDim2.new(0, 15, 0, 75)
    ContentArea.Size = UDim2.new(1, -30, 1, -85)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ZIndex = 10
    ContentArea.Parent = MainFrame
    
    -- Sidebar (Tabs) - ZIndex: 50
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 175, 1, 0)
    Sidebar.BackgroundColor3 = Theme.BackgroundSecondary
    Sidebar.BackgroundTransparency = Theme.TransparencySecondary
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 50
    Sidebar.Parent = ContentArea
    Sidebar.ClipsDescendants = true
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 16)
    SidebarCorner.Parent = Sidebar
    
    -- Tab List - ZIndex: 55
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabList"
    TabList.Size = UDim2.new(1, -14, 1, -14)
    TabList.Position = UDim2.new(0, 7, 0, 7)
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 3
    TabList.ScrollBarImageColor3 = Theme.Accent
    TabList.ScrollBarImageTransparency = 0.6
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.ZIndex = 55
    TabList.Parent = Sidebar
    TabList.ClipsDescendants = true
    TabList.Active = true
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 8)
    TabListLayout.Parent = TabList
    
    -- Pages Container - ZIndex: 40
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Name = "Pages"
    PagesContainer.Position = UDim2.new(0, 187, 0, 0)
    PagesContainer.Size = UDim2.new(1, -187, 1, 0)
    PagesContainer.BackgroundColor3 = Theme.BackgroundSecondary
    PagesContainer.BackgroundTransparency = Theme.TransparencySecondary
    PagesContainer.BorderSizePixel = 0
    PagesContainer.ZIndex = 40
    PagesContainer.ClipsDescendants = true
    PagesContainer.Parent = ContentArea
    
    local PagesCorner = Instance.new("UICorner")
    PagesCorner.CornerRadius = UDim.new(0, 16)
    PagesCorner.Parent = PagesContainer
    
    --═══════════════════════════════════════════════════════════════════════════
    -- DRAGGING
    --═══════════════════════════════════════════════════════════════════════════
    
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
    
    --═══════════════════════════════════════════════════════════════════════════
    -- FLOATING TOGGLE BUTTON
    --═══════════════════════════════════════════════════════════════════════════
    
    local ToggleGui, ToggleButton = Library.FloatingToggle:Create(Window, {
        Position = Config.TogglePosition or UDim2.new(0, 25, 0.5, -27)
    })
    
    ToggleButton.MouseButton1Click:Connect(function()
        Window.Visible = not Window.Visible
        if Window.Visible then
            MainFrame.Visible = true
            Utilities.Spring(MainFrame, {Size = Window.Minimized and UDim2.new(0, 680, 0, 65) or UDim2.new(0, 680, 0, 480)}, 0.4)
        else
            Utilities.Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            task.delay(0.35, function()
                MainFrame.Visible = false
            end)
        end
    end)
    
    --═══════════════════════════════════════════════════════════════════════════
    -- TAB CREATION
    --═══════════════════════════════════════════════════════════════════════════
    
    function Window:CreateTab(TabConfig)
        TabConfig = TabConfig or {}
        local Tab = {}
        Tab.Name = TabConfig.Name or "Tab"
        Tab.Icon = TabConfig.Icon or ""
        
        -- Tab Button - ZIndex: 60 (higher than TabList)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = Tab.Name .. "_Tab"
        TabButton.Size = UDim2.new(1, 0, 0, 44)
        TabButton.BackgroundColor3 = Theme.BackgroundTertiary
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.ZIndex = 60
        TabButton.Parent = TabList
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 12)
        TabCorner.Parent = TabButton
        
        -- Active indicator
        local Indicator = Instance.new("Frame")
        Indicator.Name = "Indicator"
        Indicator.Size = UDim2.new(0, 4, 0, 0)
        Indicator.Position = UDim2.new(0, 0, 0.5, 0)
        Indicator.BackgroundColor3 = Theme.Accent
        Indicator.BorderSizePixel = 0
        Indicator.ZIndex = 62
        Indicator.Parent = TabButton
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 2)
        IndicatorCorner.Parent = Indicator
        
        -- Icon
        local IconLabel = Instance.new("TextLabel")
        IconLabel.Name = "Icon"
        IconLabel.Size = UDim2.new(0, 28, 0, 28)
        IconLabel.Position = UDim2.new(0, 12, 0.5, -14)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Text = Tab.Icon
        IconLabel.TextColor3 = Theme.TextSecondary
        IconLabel.Font = Enum.Font.GothamBold
        IconLabel.TextSize = 14
        IconLabel.ZIndex = 61
        IconLabel.Parent = TabButton
        
        -- Text
        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "Text"
        TextLabel.Size = UDim2.new(1, -48, 1, 0)
        TextLabel.Position = UDim2.new(0, 46, 0, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Text = Tab.Name
        TextLabel.TextColor3 = Theme.TextSecondary
        TextLabel.Font = Enum.Font.GothamSemibold
        TextLabel.TextSize = 14
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.ZIndex = 61
        TextLabel.Parent = TabButton
        
        -- Page - ZIndex: 45
        local Page = Instance.new("ScrollingFrame")
        Page.Name = Tab.Name .. "_Page"
        Page.Size = UDim2.new(1, -18, 1, -18)
        Page.Position = UDim2.new(0, 9, 0, 9)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.ScrollBarImageTransparency = 0.5
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Visible = false
        Page.ZIndex = 45
        Page.Parent = PagesContainer
        Page.ClipsDescendants = true
        Page.Active = true
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 12)
        PageLayout.Parent = Page
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Tab selection
        local function SelectTab()
            if Window.CurrentTab == Tab then return end
            
            -- Deselect previous
            if Window.CurrentTab then
                local Prev = Window.CurrentTab
                Utilities.Tween(Prev.Button.Indicator, {Size = UDim2.new(0, 4, 0, 0)}, 0.2)
                Utilities.Tween(Prev.Button.Indicator, {Position = UDim2.new(0, 0, 0.5, 0)}, 0.2)
                Utilities.Tween(Prev.Button, {BackgroundTransparency = 1}, 0.2)
                Utilities.Tween(Prev.Button.Icon, {TextColor3 = Theme.TextSecondary}, 0.2)
                Utilities.Tween(Prev.Button.Text, {TextColor3 = Theme.TextSecondary}, 0.2)
                
                Prev.Page.Visible = false
            end
            
            -- Select new
            Window.CurrentTab = Tab
            Page.Visible = true
            
            Utilities.Spring(Indicator, {Size = UDim2.new(0, 4, 0, 28)}, 0.35)
            Utilities.Tween(Indicator, {Position = UDim2.new(0, 0, 0.5, -14)}, 0.35)
            Utilities.Tween(TabButton, {BackgroundTransparency = 0.65}, 0.2)
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
                Utilities.Tween(TabButton, {BackgroundTransparency = 0.8}, 0.15)
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
        
        if #Window.Tabs == 1 then
            task.delay(0.25, function()
                SelectTab()
            end)
        end
        
        TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabList.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 14)
        end)
        
        -- Elements
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
    
    -- Window methods
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
    
    -- Key toggle
    UserInputService.InputBegan:Connect(function(Input, GameProcessed)
        if not GameProcessed and Input.KeyCode == Window.ToggleKey then
            ToggleButton.MouseButton1Click:Fire()
        end
    end)
    
    -- Intro animation
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    task.spawn(function()
        task.wait(0.1)
        Utilities.Spring(MainFrame, {Size = UDim2.new(0, 680, 0, 480)}, 0.55)
    end)
    
    -- Welcome notification
    task.delay(0.7, function()
        Window:Notify({
            Title = "Welcome",
            Message = (Config.Title or "Shenzhen UI") .. " loaded successfully",
            Type = "Success",
            Duration = 3
        })
    end)
    
    return Window
end

-- Global notify
function Library:Notify(Config)
    Library.Notifications:Show(
        Config.Title or "Notification",
        Config.Message or "",
        Config.Type or "Info",
        Config.Duration or 3
    )
end

return Library
