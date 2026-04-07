--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                SHENZHEN UI v2.3 - PREMIUM DEMO (NO EMOJIS)                   ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
--]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/ShenzhenUI_v23.lua"))()

--════════════════════════════════════════════════════════════════════════════════
-- CREATE WINDOW
--════════════════════════════════════════════════════════════════════════════════

local Window = Library:CreateWindow({
    Title = "SHENZHEN UI v2.3",
    SubTitle = "Premium Edition",
    Logo = "S",
    Key = Enum.KeyCode.RightControl,
    TogglePosition = UDim2.new(0, 25, 0.85, 0) -- Floating button position
})

--════════════════════════════════════════════════════════════════════════════════
-- MAIN TAB
--════════════════════════════════════════════════════════════════════════════════

local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "M"  -- Single letter instead of emoji
})

MainTab:Section({Text = "QUICK ACTIONS"})

MainTab:Button({
    Text = "Execute Script",
    Icon = ">",  -- Arrow symbol
    Callback = function()
        Window:Notify({
            Title = "Success",
            Message = "Script executed successfully",
            Type = "Success"
        })
    end
})

MainTab:Button({
    Text = "Refresh Data",
    Icon = "R",
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
    Icon = "!",
    Callback = function()
        Window:Notify({
            Title = "Warning",
            Message = "This is a warning notification",
            Type = "Warning"
        })
    end
})

MainTab:Section({Text = "FEATURE TOGGLES"})

local GodModeToggle = MainTab:Toggle({
    Text = "God Mode",
    Default = false,
    Callback = function(Value)
        print("God Mode:", Value)
        if Value then
            Window:Notify({
                Title = "God Mode",
                Message = "You are now invincible",
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
    Icon = "P"
})

PlayerTab:Section({Text = "MOVEMENT"})

PlayerTab:Slider({
    Text = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Suffix = " studs",
    Callback = function(Value)
        local Character = game.Players.LocalPlayer.Character
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.WalkSpeed = Value
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
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.JumpPower = Value
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
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid.Health = Value
        end
    end
})

PlayerTab:Section({Text = "CAMERA"})

PlayerTab:Slider({
    Text = "Field of View",
    Min = 30,
    Max = 120,
    Default = 70,
    Suffix = " deg",
    Callback = function(Value)
        game.Workspace.CurrentCamera.FieldOfView = Value
    end
})

--════════════════════════════════════════════════════════════════════════════════
-- VISUALS TAB
--════════════════════════════════════════════════════════════════════════════════

local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "V"
})

VisualsTab:Section({Text = "ESP SETTINGS"})

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

VisualsTab:Section({Text = "WORLD"})

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
    Icon = "S"
})

SettingsTab:Section({Text = "CONFIGURATION"})

SettingsTab:Dropdown({
    Text = "UI Theme",
    Options = {"Glass", "Dark", "Midnight"},
    Default = "Glass",
    Callback = function(Selected)
        Window:SetTheme(Selected)
    end
})

SettingsTab:Dropdown({
    Text = "FPS Cap",
    Options = {"30", "60", "120", "144", "240", "Unlimited"},
    Default = "60",
    Callback = function(Selected)
        print("FPS Cap:", Selected)
    end
})

SettingsTab:Section({Text = "INPUT"})

SettingsTab:TextBox({
    Text = "Custom Message",
    Placeholder = "Enter your message...",
    Default = "Hello World",
    Callback = function(Text)
        Window:Notify({
            Title = "Message Set",
            Message = "Your message: " .. Text,
            Type = "Info"
        })
    end
})

SettingsTab:TextBox({
    Text = "Target Player",
    Placeholder = "Enter username...",
    Default = "",
    Callback = function(Text)
        print("Target:", Text)
    end
})

SettingsTab:Section({Text = "DANGER ZONE"})

SettingsTab:Button({
    Text = "Reset All Settings",
    Icon = "X",
    Callback = function()
        GodModeToggle:Set(false)
        SpeedToggle:Set(false)
        ESP_Toggle:Set(false)
        
        Window:Notify({
            Title = "Reset Complete",
            Message = "All settings have been reset",
            Type = "Warning"
        })
    end
})

SettingsTab:Button({
    Text = "Close UI",
    Icon = "X",
    Callback = function()
        Window:Notify({
            Title = "Goodbye",
            Message = "Closing UI...",
            Type = "Info"
        })
        task.wait(1)
    end
})

--════════════════════════════════════════════════════════════════════════════════
-- ADVANCED TAB
--════════════════════════════════════════════════════════════════════════════════

local AdvancedTab = Window:CreateTab({
    Name = "Advanced",
    Icon = "A"
})

AdvancedTab:Section({Text = "PERFORMANCE"})

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

AdvancedTab:Section({TEXT = "NOTIFICATION TEST"})

AdvancedTab:Button({
    Text = "Test Info",
    Icon = "i",
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
    Text = "Test Success",
    Icon = "v",
    Callback = function()
        Window:Notify({
            Title = "Success",
            Message = "Operation completed successfully",
            Type = "Success",
            Duration = 4
        })
    end
})

AdvancedTab:Button({
    Text = "Test Warning",
    Icon = "!",
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
    Text = "Test Error",
    Icon = "x",
    Callback = function()
        Window:Notify({
            Title = "Error",
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
    Icon = "?"
})

AboutTab:Label({
    Text = "SHENZHEN UI v2.3",
    Style = "Title"
})

AboutTab:Label({
    Text = "Premium Edition - Rayfield Level",
    Style = "Subtitle"
})

AboutTab:Section({Text = "FEATURES"})

AboutTab:Label({Text = "- Glassmorphism design", Style = "Normal"})
AboutTab:Label({Text = "- Spring-based animations", Style = "Normal"})
AboutTab:Label({Text = "- Multi-layered shadows", Style = "Normal"})
AboutTab:Label({Text = "- Snow particle effects", Style = "Normal"})
AboutTab:Label({Text = "- Floating toggle button", Style = "Normal"})
AboutTab:Label({Text = "- Full mobile support", Style = "Normal"})

AboutTab:Section({Text = "CREDITS"})

AboutTab:Label({
    Text = "Made for the Roblox community",
    Style = "Normal"
})

--════════════════════════════════════════════════════════════════════════════════
-- PROGRAMMATIC CONTROL EXAMPLES
--════════════════════════════════════════════════════════════════════════════════

--[[
    -- Control elements programmatically:
    
    GodModeToggle:Set(true)      -- Enable toggle
    print(GodModeToggle:Get())   -- Get toggle state
    
    -- All elements return control interfaces:
    local MySlider = Tab:Slider({...})
    MySlider:Set(75)
    print(MySlider:Get())
    
    local MyDropdown = Tab:Dropdown({...})
    MyDropdown:Set("Option 2")
    MyDropdown:Refresh({"New", "Options"})
--]]

print("========================================")
print("  SHENZHEN UI v2.3 Loaded Successfully")
print("========================================")
print("  Press RightControl to toggle UI")
print("  Or click the floating S button")
print("========================================")
