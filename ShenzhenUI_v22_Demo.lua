--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                SHENZHEN UI v2.2 - COMPREHENSIVE DEMO                         ║
    ║          Shows all components, features, and best practices                  ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
--]]

-- Load the library (replace with your actual loadstring)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/ShenzhenUI_v22.lua"))()

--════════════════════════════════════════════════════════════════════════════════
-- CREATE WINDOW
--════════════════════════════════════════════════════════════════════════════════

local Window = Library:CreateWindow({
    Title = "Shenzhen UI v2.2",
    SubTitle = "Premium • Smooth • Modern",
    Logo = "S",
    Key = Enum.KeyCode.RightControl
})

--════════════════════════════════════════════════════════════════════════════════
-- MAIN TAB
--════════════════════════════════════════════════════════════════════════════════

local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "🏠"
})

-- Section header
MainTab:Section({Text = "Quick Actions"})

-- Buttons with different styles
MainTab:Button({
    Text = "Execute Script",
    Icon = "🚀",
    Callback = function()
        Window:Notify({
            Title = "Success!",
            Message = "Script executed successfully",
            Type = "Success"
        })
    end
})

MainTab:Button({
    Text = "Refresh Data",
    Icon = "🔄",
    Callback = function()
        Window:Notify({
            Title = "Refreshed",
            Message = "All data has been updated",
            Type = "Info"
        })
    end
})

MainTab:Button({
    Text = "Test Warning",
    Icon = "⚠️",
    Callback = function()
        Window:Notify({
            Title = "Warning",
            Message = "This is a warning notification",
            Type = "Warning"
        })
    end
})

-- Section divider
MainTab:Section({Text = "Feature Toggles"})

-- Toggles
local GodModeToggle = MainTab:Toggle({
    Text = "God Mode",
    Default = false,
    Callback = function(Value)
        print("God Mode:", Value)
        if Value then
            Window:Notify({
                Title = "God Mode",
                Message = "God mode enabled - you're invincible!",
                Type = "Success"
            })
        end
    end
})

local SpeedToggle = MainTab:Toggle({
    Text = "Speed Boost",
    Default = false,
    Callback = function(Value)
        print("Speed Boost:", Value)
    end
})

local ESP_Toggle = MainTab:Toggle({
    Text = "ESP Enabled",
    Default = false,
    Callback = function(Value)
        print("ESP:", Value)
    end
})

--════════════════════════════════════════════════════════════════════════════════
-- PLAYER TAB
--════════════════════════════════════════════════════════════════════════════════

local PlayerTab = Window:CreateTab({
    Name = "Player",
    Icon = "👤"
})

PlayerTab:Section({Text = "Movement Settings"})

-- Sliders
PlayerTab:Slider({
    Text = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Suffix = " studs",
    Callback = function(Value)
        local Character = game.Players.LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChild("Humanoid")
            if Humanoid then
                Humanoid.WalkSpeed = Value
            end
        end
    end
})

PlayerTab:Slider({
    Text = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Suffix = " power",
    Callback = function(Value)
        local Character = game.Players.LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChild("Humanoid")
            if Humanoid then
                Humanoid.JumpPower = Value
            end
        end
    end
})

PlayerTab:Slider({
    Text = "Health",
    Min = 0,
    Max = 100,
    Default = 100,
    Suffix = "%",
    Callback = function(Value)
        local Character = game.Players.LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChild("Humanoid")
            if Humanoid then
                Humanoid.Health = Value
            end
        end
    end
})

PlayerTab:Section({Text = "Field of View"})

PlayerTab:Slider({
    Text = "FOV",
    Min = 30,
    Max = 120,
    Default = 70,
    Suffix = "°",
    Callback = function(Value)
        game.Workspace.CurrentCamera.FieldOfView = Value
    end
})

--════════════════════════════════════════════════════════════════════════════════
-- VISUALS TAB
--════════════════════════════════════════════════════════════════════════════════

local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "👁"
})

VisualsTab:Section({Text = "ESP Settings"})

-- More toggles
VisualsTab:Toggle({
    Text = "Box ESP",
    Default = false,
    Callback = function(Value)
        print("Box ESP:", Value)
    end
})

VisualsTab:Toggle({
    Text = "Tracers",
    Default = false,
    Callback = function(Value)
        print("Tracers:", Value)
    end
})

VisualsTab:Toggle({
    Text = "Name ESP",
    Default = false,
    Callback = function(Value)
        print("Name ESP:", Value)
    end
})

VisualsTab:Toggle({
    Text = "Skeleton ESP",
    Default = false,
    Callback = function(Value)
        print("Skeleton ESP:", Value)
    end
})

VisualsTab:Section({Text = "World Settings"})

VisualsTab:Slider({
    Text = "Brightness",
    Min = 0,
    Max = 10,
    Default = 1,
    Suffix = "x",
    Callback = function(Value)
        game.Lighting.Brightness = Value
    end
})

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
-- SETTINGS TAB
--════════════════════════════════════════════════════════════════════════════════

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "⚙"
})

SettingsTab:Section({Text = "Configuration"})

-- Dropdown for theme
SettingsTab:Dropdown({
    Text = "UI Theme",
    Options = {"Glass", "Dark", "Midnight"},
    Default = "Glass",
    Callback = function(Selected)
        Window:SetTheme(Selected)
    end
})

-- Dropdown for FPS
SettingsTab:Dropdown({
    Text = "FPS Cap",
    Options = {"30", "60", "120", "144", "240", "Unlimited"},
    Default = "60",
    Callback = function(Selected)
        print("FPS Cap set to:", Selected)
    end
})

SettingsTab:Section({Text = "Input"})

-- TextBox
SettingsTab:TextBox({
    Text = "Custom Message",
    Placeholder = "Enter your message...",
    Default = "Hello World!",
    Callback = function(Text)
        Window:Notify({
            Title = "Message Updated",
            Message = "Your message: " .. Text,
            Type = "Info"
        })
    end
})

-- TextBox for username
SettingsTab:TextBox({
    Text = "Target Username",
    Placeholder = "Enter username...",
    Default = "",
    Callback = function(Text)
        print("Target:", Text)
    end
})

SettingsTab:Section({Text = "Danger Zone"})

-- Reset button
SettingsTab:Button({
    Text = "Reset All Settings",
    Icon = "🗑️",
    Callback = function()
        -- Reset all toggles
        GodModeToggle:Set(false)
        SpeedToggle:Set(false)
        ESP_Toggle:Set(false)
        
        Window:Notify({
            Title = "Reset Complete",
            Message = "All settings have been reset to default",
            Type = "Warning"
        })
    end
})

-- Destroy UI button
SettingsTab:Button({
    Text = "Close UI",
    Icon = "❌",
    Callback = function()
        Window:Notify({
            Title = "Goodbye!",
            Message = "Closing UI in 1 second...",
            Type = "Info"
        })
        task.wait(1)
        -- UI closes automatically when destroyed
    end
})

--════════════════════════════════════════════════════════════════════════════════
-- ADVANCED TAB
--════════════════════════════════════════════════════════════════════════════════

local AdvancedTab = Window:CreateTab({
    Name = "Advanced",
    Icon = "🔧"
})

AdvancedTab:Section({Text = "Performance"})

-- Performance sliders
AdvancedTab:Slider({
    Text = "Render Distance",
    Min = 100,
    Max = 2000,
    Default = 1000,
    Suffix = " studs",
    Callback = function(Value)
        settings().Rendering.MeshPartDetailLevel = Value < 500 and 0 or Value < 1000 and 1 or 2
    end
})

AdvancedTab:Slider({
    Text = "Graphics Quality",
    Min = 1,
    Max = 10,
    Default = 7,
    Suffix = "",
    Callback = function(Value)
        settings().Rendering.QualityLevel = Value
    end
})

AdvancedTab:Section({Text = "Notifications Test"})

-- Test notification buttons
AdvancedTab:Button({
    Text = "Test Info Notification",
    Icon = "ℹ️",
    Callback = function()
        Window:Notify({
            Title = "Information",
            Message = "This is an informational notification",
            Type = "Info",
            Duration = 4
        })
    end
})

AdvancedTab:Button({
    Text = "Test Success Notification",
    Icon = "✅",
    Callback = function()
        Window:Notify({
            Title = "Success!",
            Message = "Operation completed successfully",
            Type = "Success",
            Duration = 4
        })
    end
})

AdvancedTab:Button({
    Text = "Test Warning Notification",
    Icon = "⚠️",
    Callback = function()
        Window:Notify({
            Title = "Warning",
            Message = "Please be careful with this action",
            Type = "Warning",
            Duration = 4
        })
    end
})

AdvancedTab:Button({
    Text = "Test Error Notification",
    Icon = "❌",
    Callback = function()
        Window:Notify({
            Title = "Error!",
            Message = "Something went wrong. Please try again.",
            Type = "Error",
            Duration = 4
        })
    end
})

--════════════════════════════════════════════════════════════════════════════════
-- ABOUT TAB
--════════════════════════════════════════════════════════════════════════════════

local AboutTab = Window:CreateTab({
    Name = "About",
    Icon = "ℹ"
})

AboutTab:Label({
    Text = "Shenzhen UI v2.2",
    Style = "Title"
})

AboutTab:Label({
    Text = "A premium, Rayfield-level UI library",
    Style = "Subtitle"
})

AboutTab:Section({Text = "Features"})

AboutTab:Label({
    Text = "• Glassmorphism design",
    Style = "Normal"
})

AboutTab:Label({
    Text = "• Spring-based animations",
    Style = "Normal"
})

AboutTab:Label({
    Text = "• Multi-layered shadows",
    Style = "Normal"
})

AboutTab:Label({
    Text = "• Ripple click effects",
    Style = "Normal"
})

AboutTab:Label({
    Text = "• Smooth tab switching",
    Style = "Normal"
})

AboutTab:Label({
    Text = "• Full mobile support",
    Style = "Normal"
})

AboutTab:Section({Text = "Credits"})

AboutTab:Label({
    Text = "Made with ❤️ for the Roblox community",
    Style = "Normal"
})

--════════════════════════════════════════════════════════════════════════════════
-- PROGRAMMATIC EXAMPLES
--════════════════════════════════════════════════════════════════════════════════

--[[
    -- Example: Programmatically control elements
    
    -- Toggle a switch
    GodModeToggle:Set(true)
    
    -- Get toggle state
    local isGodMode = GodModeToggle:Get()
    print("God Mode is:", isGodMode)
    
    -- Update dropdown options
    local ThemeDropdown = SettingsTab:Dropdown({...})
    ThemeDropdown:Refresh({"New", "Theme", "Options"})
    
    -- Get/set values
    ThemeDropdown:Set("Dark")
    local currentTheme = ThemeDropdown:Get()
--]]

-- Initial welcome
print("✅ Shenzhen UI v2.2 Demo loaded successfully!")
print("📋 Press RightControl to toggle the UI")
print("📋 Try all tabs and components!")
