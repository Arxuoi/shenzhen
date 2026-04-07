--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║           SHENZHEN UI v2.2 - QUICK REFERENCE CARD                            ║
    ║              Copy-paste snippets for common use cases                        ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
--]]

--════════════════════════════════════════════════════════════════════════════════
-- BASIC SETUP
--════════════════════════════════════════════════════════════════════════════════

local Library = loadstring(game:HttpGet("URL_HERE"))()

local Window = Library:CreateWindow({
    Title = "Script Name",
    SubTitle = "v1.0",
    Logo = "S",
    Key = Enum.KeyCode.RightControl
})

--════════════════════════════════════════════════════════════════════════════════
-- TABS
--════════════════════════════════════════════════════════════════════════════════

local MainTab = Window:CreateTab({Name = "Main", Icon = "🏠"})
local PlayerTab = Window:CreateTab({Name = "Player", Icon = "👤"})
local VisualsTab = Window:CreateTab({Name = "Visuals", Icon = "👁"})
local SettingsTab = Window:CreateTab({Name = "Settings", Icon = "⚙"})

--════════════════════════════════════════════════════════════════════════════════
-- BUTTON
--════════════════════════════════════════════════════════════════════════════════

MainTab:Button({
    Text = "Button Text",
    Icon = "🚀",
    Callback = function()
        -- Code here
    end
})

--════════════════════════════════════════════════════════════════════════════════
-- TOGGLE (with save reference)
--════════════════════════════════════════════════════════════════════════════════

local MyToggle = MainTab:Toggle({
    Text = "Feature Name",
    Default = false,
    Callback = function(Value)
        print(Value)
    end
})

-- Control later:
-- MyToggle:Set(true)
-- MyToggle:Get()

--════════════════════════════════════════════════════════════════════════════════
-- SLIDER (with save reference)
--════════════════════════════════════════════════════════════════════════════════

local MySlider = MainTab:Slider({
    Text = "Setting Name",
    Min = 0,
    Max = 100,
    Default = 50,
    Suffix = "%",
    Callback = function(Value)
        print(Value)
    end
})

-- Control later:
-- MySlider:Set(75)
-- MySlider:Get()

--════════════════════════════════════════════════════════════════════════════════
-- DROPDOWN (with save reference)
--════════════════════════════════════════════════════════════════════════════════

local MyDropdown = MainTab:Dropdown({
    Text = "Select Option",
    Options = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Callback = function(Selected)
        print(Selected)
    end
})

-- Control later:
-- MyDropdown:Set("Option 2")
-- MyDropdown:Get()
-- MyDropdown:Refresh({"New", "Options"})

--════════════════════════════════════════════════════════════════════════════════
-- TEXTBOX (with save reference)
--════════════════════════════════════════════════════════════════════════════════

local MyTextBox = MainTab:TextBox({
    Text = "Input Label",
    Placeholder = "Type here...",
    Default = "",
    Callback = function(Text)
        print(Text)
    end
})

-- Control later:
-- MyTextBox:Set("New Text")
-- MyTextBox:Get()

--════════════════════════════════════════════════════════════════════════════════
-- LABEL
--════════════════════════════════════════════════════════════════════════════════

MainTab:Label({Text = "Normal Text", Style = "Normal"})
MainTab:Label({Text = "Subtitle Text", Style = "Subtitle"})
MainTab:Label({Text = "Title Text", Style = "Title"})

--════════════════════════════════════════════════════════════════════════════════
-- SECTION (divider)
--════════════════════════════════════════════════════════════════════════════════

MainTab:Section({Text = "Category Name"})

--════════════════════════════════════════════════════════════════════════════════
-- NOTIFICATIONS
--════════════════════════════════════════════════════════════════════════════════

Window:Notify({
    Title = "Title",
    Message = "Message content",
    Type = "Info", -- Info, Success, Warning, Error
    Duration = 3
})

-- Quick notifications:
-- Window:Notify({Title="Info", Message="...", Type="Info"})
-- Window:Notify({Title="Success", Message="...", Type="Success"})
-- Window:Notify({Title="Warning", Message="...", Type="Warning"})
-- Window:Notify({Title="Error", Message="...", Type="Error"})

--════════════════════════════════════════════════════════════════════════════════
-- THEMES
--════════════════════════════════════════════════════════════════════════════════

-- Switch theme
Window:SetTheme("Dark")
Window:SetTheme("Glass")
Window:SetTheme("Midnight")

--════════════════════════════════════════════════════════════════════════════════
-- COMMON GAME INTEGRATIONS
--════════════════════════════════════════════════════════════════════════════════

-- Walk Speed
PlayerTab:Slider({
    Text = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Suffix = " studs",
    Callback = function(Value)
        local Char = game.Players.LocalPlayer.Character
        if Char and Char:FindFirstChild("Humanoid") then
            Char.Humanoid.WalkSpeed = Value
        end
    end
})

-- Jump Power
PlayerTab:Slider({
    Text = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Suffix = " power",
    Callback = function(Value)
        local Char = game.Players.LocalPlayer.Character
        if Char and Char:FindFirstChild("Humanoid") then
            Char.Humanoid.JumpPower = Value
        end
    end
})

-- FOV
VisualsTab:Slider({
    Text = "Field of View",
    Min = 30,
    Max = 120,
    Default = 70,
    Suffix = "°",
    Callback = function(Value)
        game.Workspace.CurrentCamera.FieldOfView = Value
    end
})

-- Graphics Quality
SettingsTab:Slider({
    Text = "Graphics Quality",
    Min = 1,
    Max = 10,
    Default = 7,
    Callback = function(Value)
        settings().Rendering.QualityLevel = Value
    end
})

-- Time of Day
VisualsTab:Slider({
    Text = "Time of Day",
    Min = 0,
    Max = 24,
    Default = 12,
    Suffix = ":00",
    Callback = function(Value)
        game.Lighting.ClockTime = Value
    end
})

--════════════════════════════════════════════════════════════════════════════════
-- COMPLETE EXAMPLE TAB
--════════════════════════════════════════════════════════════════════════════════

local ExampleTab = Window:CreateTab({Name = "Example", Icon = "📋"})

ExampleTab:Section({Text = "Actions"})

ExampleTab:Button({
    Text = "Print Hello",
    Icon = "👋",
    Callback = function()
        print("Hello World!")
        Window:Notify({
            Title = "Hello!",
            Message = "Check the console",
            Type = "Success"
        })
    end
})

ExampleTab:Section({Text = "Settings"})

local AutoFarmToggle = ExampleTab:Toggle({
    Text = "Auto Farm",
    Default = false,
    Callback = function(Value)
        _G.AutoFarm = Value
    end
})

local FarmSpeedSlider = ExampleTab:Slider({
    Text = "Farm Speed",
    Min = 1,
    Max = 10,
    Default = 5,
    Callback = function(Value)
        _G.FarmSpeed = Value
    end
})

ExampleTab:Section({Text = "Configuration"})

local ModeDropdown = ExampleTab:Dropdown({
    Text = "Farm Mode",
    Options = {"Safe", "Normal", "Aggressive"},
    Default = "Normal",
    Callback = function(Selected)
        _G.FarmMode = Selected
    end
})

local TargetTextBox = ExampleTab:TextBox({
    Text = "Target Player",
    Placeholder = "Enter username...",
    Callback = function(Text)
        _G.TargetPlayer = Text
    end
})

--════════════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS (if needed)
--════════════════════════════════════════════════════════════════════════════════

-- Utilities.Tween(Object, Properties, Duration, EasingStyle, EasingDirection)
-- Utilities.Spring(Object, Properties, Duration)
-- Utilities.Smooth(Object, Properties, Duration)
-- Utilities.CreateShadow(Parent, Intensity)
-- Utilities.CreateGradient(Parent, Color1, Color2, Rotation)
-- Utilities.CreateRipple(Parent, X, Y, Color)

--════════════════════════════════════════════════════════════════════════════════
-- TIPS
--════════════════════════════════════════════════════════════════════════════════

--[[
    1. Always save references to toggles/sliders/dropdowns if you need to
       control them programmatically later
    
    2. Use Sections to organize your UI into logical groups
    
    3. Add icons to tabs and buttons for better visual appeal
    
    4. Use notifications to give users feedback on their actions
    
    5. Set sensible defaults (don't enable dangerous features by default)
    
    6. Use appropriate Min/Max values for sliders
    
    7. Test on both PC and mobile if possible
    
    8. Keep callback functions lightweight for smooth performance
--]]

print("✅ Quick Reference loaded!")
