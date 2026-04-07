# Shenzhen UI v2.3 - Changes & Fixes

## Major Fixes

### 1. Tab Clickability FIXED
**Problem:** Tabs couldn't be clicked due to ZIndex conflicts

**Solution:** 
- Header: ZIndex = 100
- Sidebar (Tabs container): ZIndex = 50
- TabList (ScrollingFrame): ZIndex = 55
- TabButton: ZIndex = 60
- Page: ZIndex = 45
- PagesContainer: ZIndex = 40

This ensures proper layering where tabs are always clickable.

### 2. Appearance Modernized
**Changes:**
- Better glassmorphism with 3 transparency levels
- Multi-layered shadows using rbxassetid://6015897843
- Gradient accents on buttons and sliders
- Rounded corners everywhere (10-20px)
- Clean borders with subtle strokes
- Better color hierarchy

### 3. Floating Toggle Button ADDED
```lua
local Window = Library:CreateWindow({
    TogglePosition = UDim2.new(0, 25, 0.85, 0)
})
```
Features:
- Pulsing glow ring animation
- Spring hover/click effects
- Opens/closes UI on click
- Works alongside keybind

### 4. Snow Effects ADDED
- 30 snowflakes max
- Random sizes (2-4px)
- Random fall speeds (3-8 seconds)
- Sway motion while falling
- Auto-spawning system

### 5. No Emojis - Premium Look
Using text symbols instead:
- Tab icons: Single letters (M, P, V, S, A, ?)
- Button icons: Symbols (>, R, !, X, i, v)
- Cleaner, more professional appearance

## Component Improvements

### Button
- Gradient overlay on hover
- Image arrow instead of text
- Better ripple effect
- Spring press animation

### Toggle
- Modern switch design
- Status indicator dot
- Smooth knob sliding
- Better shadows

### Slider
- Gradient fill bar
- Glow effect on knob
- Value display box
- Smooth drag with touch

### Dropdown
- Image arrow
- Smooth expand/collapse
- Better option styling

### TextBox
- Focus line animation
- Better placeholder styling

### Label
- 3 styles: Normal, Subtitle, Title

### Section
- Gradient lines
- Centered text

## Notification System
Types with icons:
- Info: "i"
- Success: "v"
- Warning: "!"
- Error: "x"

Features:
- Progress bar
- Slide in/out animation
- Colored icon background
- Shadow effect

## Themes

### Glass (Default)
- White-based glassmorphism
- Blue-purple gradient accent

### Dark
- Dark gray backgrounds
- Same accent colors

### Midnight
- Deep purple theme
- Purple-pink gradient

## Usage

```lua
local Library = loadstring(game:HttpGet("URL"))()

local Window = Library:CreateWindow({
    Title = "My Script",
    SubTitle = "v1.0",
    Logo = "S",
    Key = Enum.KeyCode.RightControl,
    TogglePosition = UDim2.new(0, 25, 0.85, 0)
})

local Tab = Window:CreateTab({
    Name = "Main",
    Icon = "M"  -- No emoji, just letter
})

Tab:Button({
    Text = "Click Me",
    Icon = ">",  -- Symbol, not emoji
    Callback = function()
        Window:Notify({
            Title = "Clicked!",
            Message = "Button pressed",
            Type = "Success"
        })
    end
})
```

## Key Features

1. **Clickable Tabs** - Fixed ZIndex hierarchy
2. **Floating Toggle** - Animated S button
3. **Snow Effects** - Falling particles
4. **No Emojis** - Clean symbols only
5. **Premium Design** - Glassmorphism + gradients
6. **Smooth Animations** - Spring physics
7. **Full Mobile** - Touch support
8. **Notifications** - 4 types with progress
