--// SHENZHEN UI LIBRARY V21 - DEMO SCRIPT
--// Contoh penggunaan lengkap semua fitur

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/ShenzhenUI_V21.lua"))()

--// CREATE WINDOW
local Window = Library:CreateWindow({
    Title = "SHENZHEN V21",
    SubTitle = "Rayfield-Level UI Library",
    Theme = "Dark", -- Dark, Light, Midnight, Ocean
    Key = Enum.KeyCode.RightControl
})

--// NOTIFICATION EXAMPLES
Library:Notify({
    Title = "Welcome!",
    Message = "Shenzhen V21 loaded successfully!",
    Type = "Success", -- Info, Success, Warning, Error
    Duration = 3
})

--// CREATE TABS
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "🏠"
})

local PlayerTab = Window:CreateTab({
    Name = "Player",
    Icon = "👤"
})

local VisualTab = Window:CreateTab({
    Name = "Visual",
    Icon = "👁"
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "⚙"
})

--// MAIN TAB ELEMENTS
MainTab:CreateParagraph({
    Title = "Welcome to Shenzhen V21",
    Content = "This is a Rayfield-level UI library with smooth animations, modern design, and full component support."
})

MainTab:CreateDivider({Text = "Quick Actions"})

MainTab:CreateButton({
    Name = "🚀 Execute Script",
    Callback = function()
        Library:Notify({
            Title = "Success!",
            Message = "Script executed successfully!",
            Type = "Success"
        })
    end
})

MainTab:CreateButton({
    Name = "🔄 Refresh Data",
    Callback = function()
        Library:Notify({
            Title = "Refreshed",
            Message = "All data has been refreshed!",
            Type = "Info"
        })
    end
})

MainTab:CreateDivider()

--// PLAYER TAB ELEMENTS
PlayerTab:CreateParagraph({
    Title = "Player Settings",
    Content = "Customize your player settings below."
})

-- Toggle Example
local GodModeToggle = PlayerTab:CreateToggle({
    Name = "✨ God Mode",
    Default = false,
    Callback = function(Value)
        print("God Mode:", Value)
        if Value then
            Library:Notify({
                Title = "God Mode",
                Message = "God Mode enabled!",
                Type = "Success"
            })
        end
    end
})

-- Speed Toggle
local SpeedToggle = PlayerTab:CreateToggle({
    Name = "⚡ Speed Boost",
    Default = false,
    Callback = function(Value)
        print("Speed Boost:", Value)
    end
})

-- Slider Example
PlayerTab:CreateSlider({
    Name = "🏃 Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Suffix = " studs",
    Callback = function(Value)
        if game.Players.LocalPlayer.Character then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end
    end
})

-- Jump Power Slider
PlayerTab:CreateSlider({
    Name = "🦘 Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Suffix = " power",
    Callback = function(Value)
        if game.Players.LocalPlayer.Character then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = Value
            end
        end
    end
})

PlayerTab:CreateDivider()

-- Health Slider
PlayerTab:CreateSlider({
    Name = "❤️ Health",
    Min = 0,
    Max = 100,
    Default = 100,
    Suffix = "%",
    Callback = function(Value)
        if game.Players.LocalPlayer.Character then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Health = Value
            end
        end
    end
})

--// VISUAL TAB ELEMENTS
VisualTab:CreateParagraph({
    Title = "Visual Settings",
    Content = "Customize visual effects and ESP settings."
})

-- ESP Toggle
VisualTab:CreateToggle({
    Name = "👁️ ESP Enabled",
    Default = false,
    Callback = function(Value)
        print("ESP:", Value)
    end
})

-- Tracers Toggle
VisualTab:CreateToggle({
    Name = "📍 Tracers",
    Default = false,
    Callback = function(Value)
        print("Tracers:", Value)
    end
})

-- Box ESP Toggle
VisualTab:CreateToggle({
    Name = "📦 Box ESP",
    Default = false,
    Callback = function(Value)
        print("Box ESP:", Value)
    end
})

VisualTab:CreateDivider({Text = "ESP Settings"})

-- ESP Color Picker
VisualTab:CreateColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 100, 100),
    Callback = function(Color)
        print("ESP Color:", Color)
    end
})

-- Tracer Color Picker
VisualTab:CreateColorPicker({
    Name = "Tracer Color",
    Default = Color3.fromRGB(100, 255, 100),
    Callback = function(Color)
        print("Tracer Color:", Color)
    end
})

--// SETTINGS TAB ELEMENTS
SettingsTab:CreateParagraph({
    Title = "Settings",
    Content = "Configure your UI preferences."
})

-- TextBox Example
SettingsTab:CreateTextBox({
    Name = "💬 Custom Message",
    Placeholder = "Enter your message...",
    Default = "Hello World!",
    Callback = function(Text)
        Library:Notify({
            Title = "Message Set",
            Message = "Your message: " .. Text,
            Type = "Info"
        })
    end
})

-- Dropdown Example
SettingsTab:CreateDropdown({
    Name = "🎨 Select Theme",
    Options = {"Dark", "Light", "Midnight", "Ocean"},
    Default = "Dark",
    Callback = function(Selected)
        Window:SetTheme(Selected)
        Library:Notify({
            Title = "Theme Changed",
            Message = "Theme set to " .. Selected,
            Type = "Success"
        })
    end
})

-- Keybind Example
SettingsTab:CreateKeybind({
    Name = "🔑 Toggle UI Key",
    Default = Enum.KeyCode.RightControl,
    Callback = function(KeyCode)
        print("New toggle key:", KeyCode.Name)
    end
})

SettingsTab:CreateDivider()

-- FPS Cap Dropdown
SettingsTab:CreateDropdown({
    Name = "🎯 FPS Cap",
    Options = {"30", "60", "120", "144", "240", "Unlimited"},
    Default = "60",
    Callback = function(Selected)
        print("FPS Cap:", Selected)
    end
})

-- Graphics Quality Slider
SettingsTab:CreateSlider({
    Name = "🖼️ Graphics Quality",
    Min = 1,
    Max = 10,
    Default = 7,
    Suffix = "",
    Callback = function(Value)
        settings().Rendering.QualityLevel = Value
    end
})

SettingsTab:CreateDivider({Text = "Danger Zone"})

-- Reset Button
SettingsTab:CreateButton({
    Name = "🗑️ Reset All Settings",
    Callback = function()
        Library:Notify({
            Title = "Reset",
            Message = "All settings have been reset!",
            Type = "Warning"
        })
    end
})

-- Destroy UI Button
SettingsTab:CreateButton({
    Name = "❌ Close UI",
    Callback = function()
        Library:Notify({
            Title = "Goodbye!",
            Message = "Closing UI...",
            Type = "Info"
        })
        task.wait(1)
        -- UI will close automatically
    end
})

--// ADDITIONAL FEATURES DEMO

-- Example of programmatically controlling elements
-- GodModeToggle:Set(true) -- Enable toggle programmatically
-- print(GodModeToggle:Get()) -- Get toggle state

-- Example notification types
--[[
Library:Notify({Title = "Info", Message = "This is an info notification", Type = "Info"})
Library:Notify({Title = "Success", Message = "This is a success notification", Type = "Success"})
Library:Notify({Title = "Warning", Message = "This is a warning notification", Type = "Warning"})
Library:Notify({Title = "Error", Message = "This is an error notification", Type = "Error"})
--]]

print("✅ Shenzhen V21 Demo loaded successfully!")
