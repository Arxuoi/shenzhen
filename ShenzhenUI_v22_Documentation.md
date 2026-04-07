# 🎨 Shenzhen UI Library v2.2 - Documentation

## Rayfield-Level Premium UI Library for Roblox

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Installation](#installation)
4. [Quick Start](#quick-start)
5. [Window API](#window-api)
6. [Components](#components)
7. [Themes](#themes)
8. [Utilities](#utilities)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

---

## 🌟 Overview

Shenzhen UI v2.2 is a premium, Rayfield-level UI library designed for Roblox. It features:

- **Glassmorphism Design** - Modern, semi-transparent aesthetic
- **Spring Animations** - Physics-based smooth transitions
- **Perfect ZIndex Layering** - No interaction bugs
- **Full Mobile Support** - Touch-friendly interface
- **Modular Architecture** - Clean, scalable code

---

## ✨ Features

### Visual Design
- ✅ Glassmorphism with layered transparency
- ✅ Multi-layered soft shadows
- ✅ Gradient accents
- ✅ Ripple click effects
- ✅ Glow effects on active elements
- ✅ Smooth corner rounding (8-16px)

### Animations
- ✅ Spring physics (Back easing)
- ✅ Smooth exponential transitions
- ✅ Micro-interactions on hover/click
- ✅ Tab switching with fade + slide
- ✅ Notification progress bars

### Components
- ✅ Button (with icon, arrow, ripple)
- ✅ Toggle (modern switch style)
- ✅ Slider (smooth drag, value display)
- ✅ Dropdown (animated expand/collapse)
- ✅ TextBox (focus animation)
- ✅ Label (3 styles: Normal, Subtitle, Title)
- ✅ Section (divider with text)

### Window Features
- ✅ Smooth draggable (no jitter)
- ✅ Minimize/expand animation
- ✅ Toggle keybind
- ✅ Logo/icon support
- ✅ Notification system

---

## 📥 Installation

```lua
-- Load the library
local Library = loadstring(game:HttpGet("YOUR_URL_HERE"))()

-- Create window
local Window = Library:CreateWindow({
    Title = "My Script",
    SubTitle = "By YourName",
    Logo = "S",
    Key = Enum.KeyCode.RightControl
})
```

---

## 🚀 Quick Start

```lua
local Library = loadstring(game:HttpGet("URL"))()

-- Create window
local Window = Library:CreateWindow({
    Title = "My Script",
    SubTitle = "v1.0",
    Key = Enum.KeyCode.Insert
})

-- Create tab
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "🏠"
})

-- Add button
MainTab:Button({
    Text = "Click Me",
    Icon = "👆",
    Callback = function()
        print("Button clicked!")
    end
})

-- Add toggle
MainTab:Toggle({
    Text = "Enable Feature",
    Default = false,
    Callback = function(Value)
        print("Feature:", Value)
    end
})

-- Add slider
MainTab:Slider({
    Text = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Suffix = "%",
    Callback = function(Value)
        print("Speed:", Value)
    end
})

-- Show notification
Window:Notify({
    Title = "Welcome!",
    Message = "Script loaded successfully",
    Type = "Success"
})
```

---

## 🪟 Window API

### CreateWindow(Config)

Creates the main UI window.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Title` | string | "Shenzhen UI" | Window title |
| `SubTitle` | string | "Premium UI Library" | Subtitle text |
| `Logo` | string | "S" | Single character logo |
| `Key` | Enum.KeyCode | RightControl | Toggle key |

```lua
local Window = Library:CreateWindow({
    Title = "My Script",
    SubTitle = "v2.0 - Premium",
    Logo = "M",
    Key = Enum.KeyCode.Insert
})
```

### Window Methods

#### CreateTab(Config)

Creates a new tab in the sidebar.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Name` | string | "Tab" | Tab name |
| `Icon` | string | "" | Emoji or text icon |

```lua
local Tab = Window:CreateTab({
    Name = "Settings",
    Icon = "⚙"
})
```

#### Notify(Config)

Shows a notification popup.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Title` | string | "Notification" | Notification title |
| `Message` | string | "" | Message content |
| `Type` | string | "Info" | Info/Success/Warning/Error |
| `Duration` | number | 3 | Seconds to show |

```lua
Window:Notify({
    Title = "Success!",
    Message = "Operation completed",
    Type = "Success",
    Duration = 4
})
```

#### SetTheme(ThemeName)

Changes the UI theme.

```lua
Window:SetTheme("Dark")
Window:SetTheme("Glass")
Window:SetTheme("Midnight")
```

---

## 🧩 Components

### Button

```lua
Tab:Button({
    Text = "Button Text",
    Icon = "🚀", -- Optional
    Callback = function()
        -- Your code here
    end
})
```

**Features:**
- Hover color shift
- Arrow indicator (slides on hover)
- Ripple click effect
- Spring press animation

---

### Toggle

```lua
local MyToggle = Tab:Toggle({
    Text = "Enable Feature",
    Default = false,
    Callback = function(Value)
        print("State:", Value)
    end
})

-- Control programmatically
MyToggle:Set(true)   -- Enable
MyToggle:Set(false)  -- Disable
print(MyToggle:Get()) -- Get current state
```

**Features:**
- Modern switch design
- Smooth sliding knob
- Status indicator dot
- Color change on active

---

### Slider

```lua
local MySlider = Tab:Slider({
    Text = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Suffix = " studs", -- Optional
    Callback = function(Value)
        print("Value:", Value)
    end
})

-- Control programmatically
MySlider:Set(100)     -- Set value
print(MySlider:Get()) -- Get current value
```

**Features:**
- Smooth drag with touch support
- Gradient fill bar
- Value display box
- Knob glow effect
- Click anywhere on track

---

### Dropdown

```lua
local MyDropdown = Tab:Dropdown({
    Text = "Select Theme",
    Options = {"Dark", "Light", "Glass"},
    Default = "Glass",
    Callback = function(Selected)
        print("Selected:", Selected)
    end
})

-- Control programmatically
MyDropdown:Set("Dark")           -- Set selection
print(MyDropdown:Get())          -- Get current selection
MyDropdown:Refresh({"A", "B"})   -- Update options
```

**Features:**
- Animated expand/collapse
- Smooth arrow rotation
- Hover highlight on options
- Clips to parent

---

### TextBox

```lua
local MyTextBox = Tab:TextBox({
    Text = "Username",
    Placeholder = "Enter username...",
    Default = "",
    Callback = function(Text)
        print("Input:", Text)
    end
})

-- Control programmatically
MyTextBox:Set("NewText")
print(MyTextBox:Get())
```

**Features:**
- Focus line animation
- Placeholder text
- Callback on focus lost

---

### Label

```lua
-- Normal label
Tab:Label({
    Text = "Regular text",
    Style = "Normal"
})

-- Subtitle
Tab:Label({
    Text = "Section description",
    Style = "Subtitle"
})

-- Title
Tab:Label({
    Text = "Big Header",
    Style = "Title"
})
```

---

### Section

```lua
Tab:Section({
    Text = "Category Name"
})
```

Creates a divider with centered text and gradient lines.

---

## 🎨 Themes

### Built-in Themes

| Theme | Description |
|-------|-------------|
| `Glass` | White-based glassmorphism (default) |
| `Dark` | Dark mode with blue accent |
| `Midnight` | Deep purple theme |

### Theme Structure

```lua
Theme = {
    -- Backgrounds
    Background = Color3,
    BackgroundSecondary = Color3,
    BackgroundTertiary = Color3,
    
    -- Transparency
    Transparency = number,
    TransparencySecondary = number,
    TransparencyTertiary = number,
    
    -- Accents
    Accent = Color3,
    AccentLight = Color3,
    AccentDark = Color3,
    
    -- Text
    TextPrimary = Color3,
    TextSecondary = Color3,
    TextTertiary = Color3,
    
    -- Status
    Success = Color3,
    Warning = Color3,
    Error = Color3,
    Info = Color3,
    
    -- Border
    Border = Color3,
    BorderLight = Color3
}
```

### Custom Theme

```lua
Library.Themes.Custom = {
    Background = Color3.fromRGB(30, 30, 35),
    BackgroundSecondary = Color3.fromRGB(40, 40, 48),
    BackgroundTertiary = Color3.fromRGB(50, 50, 60),
    
    Transparency = 0.05,
    TransparencySecondary = 0.1,
    TransparencyTertiary = 0.15,
    
    Accent = Color3.fromRGB(255, 100, 100),
    AccentLight = Color3.fromRGB(255, 150, 150),
    AccentDark = Color3.fromRGB(200, 80, 80),
    
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 190),
    TextTertiary = Color3.fromRGB(130, 130, 140),
    
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(255, 180, 80),
    Error = Color3.fromRGB(255, 100, 100),
    Info = Color3.fromRGB(80, 160, 255),
    
    Border = Color3.fromRGB(60, 60, 70),
    BorderLight = Color3.fromRGB(70, 70, 80)
}

-- Apply custom theme
Library.CurrentTheme = Library.Themes.Custom
```

---

## 🛠️ Utilities

### Tween

```lua
Utilities.Tween(Object, Properties, Duration, EasingStyle, EasingDirection, Delay)
```

### Spring

```lua
Utilities.Spring(Object, Properties, Duration)
-- Uses Back easing for bounce effect
```

### Smooth

```lua
Utilities.Smooth(Object, Properties, Duration)
-- Uses Exponential easing
```

### CreateShadow

```lua
Utilities.CreateShadow(Parent, Intensity)
-- Intensity: 0-1
```

### CreateGradient

```lua
Utilities.CreateGradient(Parent, Color1, Color2, Rotation, Transparency)
```

### CreateRipple

```lua
Utilities.CreateRipple(Parent, X, Y, Color)
```

---

## ✅ Best Practices

### 1. Organize with Sections

```lua
Tab:Section({Text = "Movement"})
-- Movement controls here

Tab:Section({Text = "Visuals"})
-- Visual controls here
```

### 2. Use Icons

```lua
Window:CreateTab({Name = "Main", Icon = "🏠"})
Window:CreateTab({Name = "Settings", Icon = "⚙"})
```

### 3. Provide Feedback

```lua
Tab:Button({
    Text = "Execute",
    Callback = function()
        -- Do something
        Window:Notify({
            Title = "Success!",
            Message = "Script executed",
            Type = "Success"
        })
    end
})
```

### 4. Save References

```lua
local SpeedToggle = Tab:Toggle({...})
local SpeedSlider = Tab:Slider({...})

-- Later...
SpeedToggle:Set(true)
SpeedSlider:Set(100)
```

### 5. Use Appropriate Defaults

```lua
Tab:Toggle({
    Text = "God Mode",
    Default = false, -- Don't enable by default
    Callback = function() end
})

Tab:Slider({
    Text = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16, -- Default game value
    Callback = function() end
})
```

---

## 🔧 Troubleshooting

### Tabs Not Clickable

**Problem:** Tabs don't respond to clicks

**Solution:** 
- Ensure `ZIndex` is properly set (handled automatically in v2.2)
- Check that no invisible frames are blocking
- Verify `Active` property is set correctly

### UI Not Showing

**Problem:** UI doesn't appear

**Solution:**
- Check that the loadstring URL is correct
- Verify `CoreGui` is accessible
- Try pressing the toggle key (default: RightControl)

### Animations Laggy

**Problem:** Animations are choppy

**Solution:**
- Reduce number of simultaneous tweens
- Use shorter durations (0.2-0.3s)
- Check for memory leaks in callbacks

### Mobile Issues

**Problem:** UI doesn't work on mobile

**Solution:**
- v2.2 has full touch support
- Ensure touch events are being processed
- Check `UserInputType.Touch` handling

---

## 📊 Performance Tips

1. **Limit Notifications** - Don't spam notifications
2. **Reuse Components** - Save references instead of recreating
3. **Clean Up** - Destroy unused UI elements
4. **Optimize Callbacks** - Keep callbacks lightweight
5. **Use Local Variables** - Cache frequently accessed values

---

## 📝 Changelog

### v2.2
- ✅ Complete rewrite with modular architecture
- ✅ Fixed all ZIndex and interaction bugs
- ✅ Added spring-based animations
- ✅ Added glassmorphism design
- ✅ Added multi-layered shadows
- ✅ Added ripple effects
- ✅ Added glow effects
- ✅ Added notification system
- ✅ Full mobile/touch support
- ✅ Clean, scalable code structure

---

## 📄 License

Free to use and modify. Credit appreciated but not required.

---

**Made with ❤️ for the Roblox community**
