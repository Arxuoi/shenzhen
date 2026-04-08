-- ============================================================
--  ███╗   ██╗███████╗██╗  ██╗██╗   ██╗██████╗  █████╗ ██╗     ██╗██████╗
--  ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔══██╗██╔══██╗██║     ██║██╔══██╗
--  ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║██████╔╝███████║██║     ██║██████╔╝
--  ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║██╔══██╗██╔══██║██║     ██║██╔══██╗
--  ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝██║  ██║██║  ██║███████╗██║██████╔╝
--  ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═════╝
--  Modern Glassmorphism UI Library for Roblox
--  Version: 2.0.0  |  Non-OOP Functional Architecture
--
--  BUGFIX v2:
--   [FIX 1] Layar putih  -> BlurEffect di Lighting dihapus total (penyebab utama!)
--   [FIX 2] GUI terlalu besar -> Size default diperkecil 680x460, clamped ke viewport
--   [FIX 3] Drag tidak bisa -> Drag pakai UserInputService.InputBegan global +
--                              hit-test manual apakah mouse ada di header
--   [FIX 4] Icon toggle hilang -> Row.AutomaticSize dimatikan, height fixed + konsisten
-- ============================================================

local Nexuralib = {}

-- ============================================================
-- SERVICES
-- ============================================================
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer      = Players.LocalPlayer

-- ============================================================
-- DESIGN TOKENS
-- ============================================================
local COLORS = {
    TextPrimary   = Color3.fromRGB(20,  20,  20),
    TextSecondary = Color3.fromRGB(100, 100, 100),
    TextMuted     = Color3.fromRGB(150, 150, 150),
    Accent        = Color3.fromRGB(0,   122, 255),
    AccentHover   = Color3.fromRGB(10,  132, 255),
    Success       = Color3.fromRGB(52,  199, 89),
    Warning       = Color3.fromRGB(255, 204, 0),
    Error         = Color3.fromRGB(255, 59,  48),
    Surface       = Color3.fromRGB(248, 248, 250),
    White         = Color3.fromRGB(255, 255, 255),
    Black         = Color3.fromRGB(0,   0,   0),
    GlassBorder   = Color3.fromRGB(200, 200, 210),
    SidebarBg     = Color3.fromRGB(242, 242, 247),
    RowBg         = Color3.fromRGB(255, 255, 255),
    TrackOff      = Color3.fromRGB(210, 210, 215),
}

local FONTS = {
    Display  = Enum.Font.GothamBlack,
    Title    = Enum.Font.GothamBold,
    Subtitle = Enum.Font.GothamMedium,
    Body     = Enum.Font.Gotham,
    Caption  = Enum.Font.Gotham,
    Code     = Enum.Font.RobotoMono,
}

local CORNERS = {
    XS   = 6,
    SM   = 10,
    MD   = 14,
    LG   = 18,
    XL   = 22,
    FULL = 999,
}

local SPACING = {
    XS  = 4,
    SM  = 8,
    MD  = 12,
    LG  = 16,
    XL  = 24,
    XXL = 32,
}

local DURATION = {
    Fast   = 0.12,
    Normal = 0.25,
    Slow   = 0.4,
}

-- [FIX 1] BG_TRANS naik sedikit agar frame tetap terlihat saat tidak ada blur
local BG_TRANS  = 0.06  -- lebih solid = lebih readable tanpa blur
local ROW_TRANS = 0.04

-- ============================================================
-- UTILITY
-- ============================================================
local function Tween(obj, props, duration, style, dir)
    local ok, err = pcall(function()
        local info = TweenInfo.new(
            duration or DURATION.Normal,
            style or Enum.EasingStyle.Quart,
            dir   or Enum.EasingDirection.Out
        )
        TweenService:Create(obj, info, props):Play()
    end)
end

local function SpringTween(obj, props, duration)
    pcall(function()
        local info = TweenInfo.new(
            duration or 0.35,
            Enum.EasingStyle.Elastic,
            Enum.EasingDirection.Out, 0, false, 0
        )
        TweenService:Create(obj, info, props):Play()
    end)
end

local function ApplyCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or CORNERS.MD)
    c.Parent = parent
    return c
end

local function ApplyStroke(parent, color, thickness, trans)
    -- Remove old stroke first to avoid duplicates
    for _, ch in ipairs(parent:GetChildren()) do
        if ch:IsA("UIStroke") then ch:Destroy() end
    end
    local s = Instance.new("UIStroke")
    s.Color             = color or COLORS.GlassBorder
    s.Thickness         = thickness or 1
    s.Transparency      = trans or 0.5
    s.ApplyStrokeMode   = Enum.ApplyStrokeMode.Border
    s.Parent            = parent
    return s
end

-- Lightweight shadow via dark semi-transparent ImageLabel
local function ApplyShadow(parent, offsetY, trans)
    local s = Instance.new("ImageLabel")
    s.Name                  = "_Shadow"
    s.AnchorPoint           = Vector2.new(0.5, 0.5)
    s.BackgroundTransparency = 1
    s.Position              = UDim2.new(0.5, 0, 0.5, offsetY or 3)
    s.Size                  = UDim2.new(1, 24, 1, 24)
    s.ZIndex                = math.max(1, (parent.ZIndex or 2) - 1)
    s.Image                 = "rbxassetid://6014261993"
    s.ImageColor3           = Color3.fromRGB(0, 0, 0)
    s.ImageTransparency     = trans or 0.78
    s.ScaleType             = Enum.ScaleType.Slice
    s.SliceCenter           = Rect.new(49, 49, 450, 450)
    s.Parent                = parent
    return s
end

local function MakeFrame(p)
    local f = Instance.new("Frame")
    f.Name                   = p.Name or "Frame"
    f.Size                   = p.Size or UDim2.new(1,0,0,40)
    f.Position               = p.Position or UDim2.new(0,0,0,0)
    f.AnchorPoint            = p.AnchorPoint or Vector2.new(0,0)
    f.BackgroundColor3       = p.Color or COLORS.White
    f.BackgroundTransparency = p.Trans or 0
    f.ZIndex                 = p.ZIndex or 1
    f.BorderSizePixel        = 0
    f.ClipsDescendants       = p.ClipsDescendants or false
    if p.Parent then f.Parent = p.Parent end
    return f
end

local function MakeLabel(p)
    local l = Instance.new("TextLabel")
    l.Name                   = p.Name or "Label"
    l.Text                   = p.Text or ""
    l.Font                   = p.Font or FONTS.Body
    l.TextSize               = p.Size or 14
    l.TextColor3             = p.Color or COLORS.TextPrimary
    l.TextXAlignment         = p.AlignX or Enum.TextXAlignment.Left
    l.TextYAlignment         = p.AlignY or Enum.TextYAlignment.Center
    l.BackgroundTransparency = 1
    l.Size                   = p.FrameSize or UDim2.new(1,0,1,0)
    l.Position               = p.Position or UDim2.new(0,0,0,0)
    l.ZIndex                 = p.ZIndex or 2
    l.TextTruncate           = Enum.TextTruncate.AtEnd
    l.RichText               = p.RichText or false
    if p.Parent then l.Parent = p.Parent end
    return l
end

local function MakeButton(p)
    local b = Instance.new("TextButton")
    b.Name                   = p.Name or "Button"
    b.Text                   = p.Text or ""
    b.Font                   = p.Font or FONTS.Body
    b.TextSize               = p.TextSize or 14
    b.TextColor3             = p.TextColor or COLORS.TextPrimary
    b.BackgroundColor3       = p.Color or COLORS.Surface
    b.BackgroundTransparency = p.Trans or 0
    b.Size                   = p.Size or UDim2.new(0,100,0,36)
    b.Position               = p.Position or UDim2.new(0,0,0,0)
    b.AutoButtonColor        = false
    b.BorderSizePixel        = 0
    b.ZIndex                 = p.ZIndex or 2
    if p.Parent then b.Parent = p.Parent end
    return b
end

local function MakeImage(p)
    local i = Instance.new("ImageLabel")
    i.Name                   = p.Name or "Image"
    i.Image                  = p.Image or ""
    i.ImageColor3            = p.Color or COLORS.TextSecondary
    i.BackgroundTransparency = 1
    i.Size                   = p.Size or UDim2.new(0,20,0,20)
    i.Position               = p.Position or UDim2.new(0,0,0.5,-10)
    i.ZIndex                 = p.ZIndex or 3
    i.ScaleType              = Enum.ScaleType.Fit
    if p.Parent then i.Parent = p.Parent end
    return i
end

local function MakeScroll(p)
    local sf = Instance.new("ScrollingFrame")
    sf.Name                      = p.Name or "Scroll"
    sf.Size                      = p.Size or UDim2.new(1,0,1,0)
    sf.Position                  = p.Position or UDim2.new(0,0,0,0)
    sf.BackgroundTransparency    = 1
    sf.BorderSizePixel           = 0
    sf.ScrollBarThickness        = p.BarSize or 3
    sf.ScrollBarImageColor3      = COLORS.Accent
    sf.ScrollBarImageTransparency = 0.5
    sf.CanvasSize                = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize       = Enum.AutomaticSize.Y
    sf.ZIndex                    = p.ZIndex or 2
    sf.ClipsDescendants          = true
    if p.Parent then sf.Parent = p.Parent end
    return sf
end

-- [FIX 4] BaseRow: AutomaticSize MATIKAN, pakai fixed height biar icon tidak hilang
local function BaseRow(parent, height, order, zIndex)
    local h   = height or 56
    local row = MakeFrame({
        Name   = "Row_" .. tostring(order),
        Size   = UDim2.new(1, 0, 0, h),
        Color  = COLORS.RowBg,
        Trans  = ROW_TRANS,
        ZIndex = zIndex or 4,
        Parent = parent,
    })
    row.LayoutOrder     = order
    -- AutomaticSize DIMATIKAN agar height tetap dan icon tidak shift/hilang
    row.AutomaticSize   = Enum.AutomaticSize.None
    ApplyCorner(row, CORNERS.MD)
    ApplyStroke(row, COLORS.GlassBorder, 1, 0.65)
    return row
end

local function Ripple(btn, x, y)
    pcall(function()
        local r = Instance.new("Frame")
        r.BackgroundColor3       = Color3.fromRGB(255,255,255)
        r.BackgroundTransparency = 0.65
        r.Size                   = UDim2.new(0,0,0,0)
        r.Position               = UDim2.new(0, x, 0, y)
        r.AnchorPoint            = Vector2.new(0.5,0.5)
        r.ZIndex                 = (btn.ZIndex or 2) + 4
        r.BorderSizePixel        = 0
        ApplyCorner(r, CORNERS.FULL)
        r.Parent = btn
        local max = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.2
        Tween(r, {Size=UDim2.new(0,max,0,max), BackgroundTransparency=1}, 0.45)
        game:GetService("Debris"):AddItem(r, 0.5)
    end)
end

-- ============================================================
-- CONFIG SYSTEM
-- ============================================================
local _ConfigCache = {}

local function SaveConfig(name, data)
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then
        _ConfigCache[name] = data
        pcall(function()
            if not isfolder("Nexuralib") then makefolder("Nexuralib") end
            writefile("Nexuralib/" .. name .. ".json", encoded)
        end)
    end
end

local function LoadConfig(name)
    if _ConfigCache[name] then return _ConfigCache[name] end
    local ok, result = pcall(function()
        if isfile("Nexuralib/" .. name .. ".json") then
            local d = HttpService:JSONDecode(readfile("Nexuralib/" .. name .. ".json"))
            _ConfigCache[name] = d
            return d
        end
    end)
    return ok and result or nil
end

Nexuralib.SaveConfig = SaveConfig
Nexuralib.LoadConfig = LoadConfig
Nexuralib.Flags      = {}

-- ============================================================
-- NOTIFY SYSTEM
-- ============================================================
local _NotifyGui       = nil
local _NotifyContainer = nil

local function _EnsureNotify()
    if _NotifyGui and _NotifyGui.Parent then return end
    _NotifyGui = Instance.new("ScreenGui")
    _NotifyGui.Name           = "NexuralibNotify"
    _NotifyGui.ResetOnSpawn   = false
    _NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _NotifyGui.DisplayOrder   = 200
    pcall(function() _NotifyGui.Parent = CoreGui end)
    if not _NotifyGui.Parent then
        _NotifyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    _NotifyContainer = MakeFrame({
        Name   = "Container",
        Size   = UDim2.new(0, 320, 1, 0),
        Position = UDim2.new(1, -336, 0, 0),
        Color  = COLORS.Black, Trans = 1,
        ZIndex = 200,
        Parent = _NotifyGui,
    })

    local ul = Instance.new("UIListLayout")
    ul.SortOrder          = Enum.SortOrder.LayoutOrder
    ul.VerticalAlignment  = Enum.VerticalAlignment.Bottom
    ul.Padding            = UDim.new(0, SPACING.SM)
    ul.Parent             = _NotifyContainer

    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0, SPACING.LG)
    pad.Parent        = _NotifyContainer
end

function Nexuralib:Notify(config)
    local cfg      = config or {}
    local title    = cfg.Title or "Notification"
    local content  = cfg.Content or ""
    local ntype    = cfg.Type or "info"
    local duration = cfg.Duration or 4
    local icon     = cfg.Icon or ""
    local actions  = cfg.Actions or {}

    _EnsureNotify()

    local typeColor = COLORS.Accent
    local typeIcon  = "rbxassetid://7733960981"
    if ntype == "success" then typeColor = COLORS.Success; typeIcon = "rbxassetid://7733715400"
    elseif ntype == "warning" then typeColor = COLORS.Warning; typeIcon = "rbxassetid://7733658504"
    elseif ntype == "error"   then typeColor = COLORS.Error;   typeIcon = "rbxassetid://7734014475"
    end
    if icon ~= "" then typeIcon = icon end

    local cardH = 72 + (content ~= "" and 18 or 0) + (#actions > 0 and 38 or 0)

    local card = MakeFrame({
        Size   = UDim2.new(1, 0, 0, cardH),
        Color  = COLORS.White,
        Trans  = BG_TRANS,
        ZIndex = 201,
        Parent = _NotifyContainer,
    })
    ApplyCorner(card, CORNERS.LG)
    ApplyStroke(card, COLORS.GlassBorder, 1, 0.45)
    ApplyShadow(card, 4, 0.74)

    -- Left accent bar
    local bar = MakeFrame({
        Size     = UDim2.new(0, 3, 1, -12),
        Position = UDim2.new(0, 0, 0, 6),
        Color    = typeColor, Trans = 0,
        ZIndex   = 202, Parent = card,
    })
    ApplyCorner(bar, CORNERS.FULL)

    MakeImage({
        Image    = typeIcon,
        Color    = typeColor,
        Size     = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 14, 0, 13),
        ZIndex   = 202, Parent = card,
    })
    MakeLabel({
        Text      = title,
        Font      = FONTS.Title, Size = 13,
        Color     = COLORS.TextPrimary,
        FrameSize = UDim2.new(1, -80, 0, 18),
        Position  = UDim2.new(0, 40, 0, 11),
        ZIndex    = 202, Parent = card,
    })
    if content ~= "" then
        MakeLabel({
            Text      = content,
            Font      = FONTS.Body, Size = 12,
            Color     = COLORS.TextSecondary,
            FrameSize = UDim2.new(1, -80, 0, 16),
            Position  = UDim2.new(0, 40, 0, 31),
            ZIndex    = 202, Parent = card,
        })
    end

    local closeBtn = MakeButton({
        Text = "✕", TextSize = 10,
        TextColor = COLORS.TextMuted,
        Color = COLORS.Black, Trans = 1,
        Size = UDim2.new(0,24,0,24),
        Position = UDim2.new(1,-28,0,6),
        ZIndex = 203, Parent = card,
    })

    if #actions > 0 then
        local af = MakeFrame({
            Size     = UDim2.new(1,-52,0,30),
            Position = UDim2.new(0,40,1,-38),
            Color    = COLORS.Black, Trans = 1,
            ZIndex   = 202, Parent = card,
        })
        local al = Instance.new("UIListLayout")
        al.FillDirection = Enum.FillDirection.Horizontal
        al.Padding       = UDim.new(0, SPACING.SM)
        al.Parent        = af
        for _, act in ipairs(actions) do
            local ab = MakeButton({
                Text = act.Text or "", TextSize = 12,
                TextColor = typeColor, Font = FONTS.Subtitle,
                Color = typeColor, Trans = 0.88,
                Size = UDim2.new(0,72,1,0),
                ZIndex = 203, Parent = af,
            })
            ApplyCorner(ab, CORNERS.SM)
            ab.MouseButton1Click:Connect(function()
                if act.Callback then act.Callback() end
            end)
        end
    end

    -- Animate in
    card.Position              = UDim2.new(1, 16, 0, 0)
    card.BackgroundTransparency = 1
    Tween(card, {
        Position              = UDim2.new(0,0,0,0),
        BackgroundTransparency = BG_TRANS,
    }, DURATION.Normal, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        Tween(card, {
            Position              = UDim2.new(1, 16, 0, 0),
            BackgroundTransparency = 1,
        }, DURATION.Normal, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(DURATION.Normal, function()
            pcall(function() card:Destroy() end)
        end)
    end

    closeBtn.MouseButton1Click:Connect(dismiss)
    task.delay(duration, dismiss)
    return { Dismiss = dismiss }
end

-- ============================================================
-- MODAL SYSTEM
-- ============================================================
local _ModalGui = nil
local function _EnsureModal()
    if _ModalGui and _ModalGui.Parent then return end
    _ModalGui = Instance.new("ScreenGui")
    _ModalGui.Name           = "NexuralibModal"
    _ModalGui.ResetOnSpawn   = false
    _ModalGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _ModalGui.DisplayOrder   = 150
    pcall(function() _ModalGui.Parent = CoreGui end)
    if not _ModalGui.Parent then _ModalGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
end

function Nexuralib:ShowModal(config)
    local cfg       = config or {}
    local mtype     = cfg.Type or "info"
    local title     = cfg.Title or "Modal"
    local content   = cfg.Content or ""
    local icon      = cfg.Icon or ""
    local primary   = cfg.PrimaryAction or {Text = "OK"}
    local secondary = cfg.SecondaryAction or nil
    local inputCfg  = cfg.Input or nil

    _EnsureModal()

    local typeColor = COLORS.Accent
    if mtype == "success" then typeColor = COLORS.Success
    elseif mtype == "warning" then typeColor = COLORS.Warning
    elseif mtype == "error" or mtype == "danger" then typeColor = COLORS.Error end

    local backdrop = MakeFrame({
        Size = UDim2.new(1,0,1,0), Color = COLORS.Black,
        Trans = 1, ZIndex = 149, Parent = _ModalGui,
    })
    Tween(backdrop, {BackgroundTransparency = 0.55}, DURATION.Normal)

    local mW = 400
    local mH = 240 + (content ~= "" and 36 or 0) + (inputCfg and 52 or 0)

    local modal = MakeFrame({
        Size     = UDim2.new(0, mW*0.82, 0, mH*0.82),
        Position = UDim2.new(0.5, -(mW*0.82)/2, 0.5, -(mH*0.82)/2),
        Color    = COLORS.White, Trans = 1,
        ZIndex   = 151, Parent = _ModalGui,
    })
    ApplyCorner(modal, CORNERS.LG)
    ApplyStroke(modal, COLORS.GlassBorder, 1, 0.4)
    ApplyShadow(modal, 6, 0.62)

    Tween(modal, {
        Size     = UDim2.new(0, mW, 0, mH),
        Position = UDim2.new(0.5, -mW/2, 0.5, -mH/2),
        BackgroundTransparency = BG_TRANS,
    }, DURATION.Normal, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Icon circle
    local iconCircle = MakeFrame({
        Size     = UDim2.new(0,52,0,52),
        Position = UDim2.new(0.5,-26,0,24),
        Color    = typeColor, Trans = 0.84,
        ZIndex   = 152, Parent = modal,
    })
    ApplyCorner(iconCircle, CORNERS.FULL)
    ApplyStroke(iconCircle, typeColor, 1.5, 0.5)
    if icon ~= "" then
        MakeImage({
            Image = icon, Color = typeColor,
            Size  = UDim2.new(0,22,0,22),
            Position = UDim2.new(0.5,-11,0.5,-11),
            ZIndex = 153, Parent = iconCircle,
        })
    end

    MakeLabel({
        Text = title, Font = FONTS.Title, Size = 17,
        Color = COLORS.TextPrimary,
        FrameSize = UDim2.new(1,-32,0,22),
        Position  = UDim2.new(0,16,0,88),
        AlignX    = Enum.TextXAlignment.Center,
        ZIndex = 152, Parent = modal,
    })

    if content ~= "" then
        MakeLabel({
            Text = content, Font = FONTS.Body, Size = 13,
            Color = COLORS.TextSecondary,
            FrameSize = UDim2.new(1,-40,0,36),
            Position  = UDim2.new(0,20,0,118),
            AlignX    = Enum.TextXAlignment.Center,
            AlignY    = Enum.TextYAlignment.Top,
            ZIndex = 152, Parent = modal,
        })
    end

    local inputResult = ""
    if inputCfg then
        local iy = content ~= "" and 162 or 122
        local ibg = MakeFrame({
            Size = UDim2.new(1,-40,0,38),
            Position = UDim2.new(0,20,0,iy),
            Color = COLORS.Surface, Trans = 0.25,
            ZIndex = 152, Parent = modal,
        })
        ApplyCorner(ibg, CORNERS.SM)
        ApplyStroke(ibg, COLORS.GlassBorder, 1, 0.5)
        local ib = Instance.new("TextBox")
        ib.PlaceholderText      = inputCfg.Placeholder or "Type here..."
        ib.Text                 = inputCfg.Default or ""
        ib.Font                 = FONTS.Body
        ib.TextSize             = 13
        ib.TextColor3           = COLORS.TextPrimary
        ib.PlaceholderColor3    = COLORS.TextMuted
        ib.BackgroundTransparency = 1
        ib.Size                 = UDim2.new(1,-12,1,0)
        ib.Position             = UDim2.new(0,6,0,0)
        ib.ZIndex               = 153
        ib.ClearTextOnFocus     = false
        ib.Parent               = ibg
        ib.FocusLost:Connect(function() inputResult = ib.Text end)
    end

    local btnY   = mH - 60
    local hasSec = secondary ~= nil
    local btnW   = hasSec and (mW-48)/2 or mW-40

    local function closeModal()
        Tween(backdrop, {BackgroundTransparency = 1}, DURATION.Fast)
        Tween(modal, {BackgroundTransparency = 1, Size = UDim2.new(0,mW*0.82,0,mH*0.82)}, DURATION.Fast)
        task.delay(DURATION.Fast, function()
            pcall(function() backdrop:Destroy() modal:Destroy() end)
        end)
    end

    if hasSec then
        local sb = MakeButton({
            Text = secondary.Text or "Cancel",
            Font = FONTS.Subtitle, TextSize = 13,
            TextColor = COLORS.TextSecondary,
            Color = COLORS.Surface, Trans = 0.25,
            Size = UDim2.new(0,btnW,0,38),
            Position = UDim2.new(0,20,0,btnY),
            ZIndex = 152, Parent = modal,
        })
        ApplyCorner(sb, CORNERS.SM)
        sb.MouseButton1Click:Connect(function()
            if secondary.Callback then secondary.Callback(inputResult) end
            closeModal()
        end)
    end

    local pbX = hasSec and (20+btnW+8) or 20
    local pb  = MakeButton({
        Text = primary.Text or "OK",
        Font = FONTS.Title, TextSize = 13,
        TextColor = COLORS.White,
        Color = typeColor, Trans = 0,
        Size = UDim2.new(0,btnW,0,38),
        Position = UDim2.new(0,pbX,0,btnY),
        ZIndex = 152, Parent = modal,
    })
    ApplyCorner(pb, CORNERS.SM)
    pb.MouseEnter:Connect(function() Tween(pb,{BackgroundTransparency=0.12},DURATION.Fast) end)
    pb.MouseLeave:Connect(function() Tween(pb,{BackgroundTransparency=0},DURATION.Fast) end)
    pb.MouseButton1Click:Connect(function()
        if primary.Callback then primary.Callback(inputResult) end
        closeModal()
    end)

    backdrop.MouseButton1Click:Connect(closeModal)
    return { Close = closeModal }
end

-- ============================================================
-- WINDOW
-- ============================================================
function Nexuralib:CreateWindow(config)
    local cfg         = config or {}
    local winTitle    = cfg.Title or "Nexuralib"
    local winSub      = cfg.Subtitle or ""
    local showAvatar  = cfg.ShowUserAvatar ~= false
    local avatarSide  = cfg.AvatarPosition or "left"
    local draggable   = cfg.Draggable ~= false
    local animateOpen = cfg.AnimateOpen ~= false

    -- [FIX 2] Ukuran default lebih kecil + clamp ke viewport
    local vp         = workspace.CurrentCamera.ViewportSize
    local defW       = math.min(cfg.Size and cfg.Size.X or 680, vp.X - 40)
    local defH       = math.min(cfg.Size and cfg.Size.Y or 460, vp.Y - 40)
    local defPosX    = cfg.Position and cfg.Position.X or math.floor((vp.X - defW) / 2)
    local defPosY    = cfg.Position and cfg.Position.Y or math.floor((vp.Y - defH) / 2)

    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name           = "NexuralibUI"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 100
    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- [FIX 1] TIDAK ada BlurEffect di Lighting — itu penyebab layar putih!
    -- Efek glass didapat dari BackgroundTransparency + warna putih saja.

    -- Container utama
    local Container = MakeFrame({
        Name     = "NexuralibWindow",
        Size     = UDim2.new(0, defW, 0, defH),
        Position = UDim2.new(0, defPosX, 0, defPosY),
        Color    = COLORS.White,
        Trans    = BG_TRANS,
        ZIndex   = 2,
        Parent   = sg,
    })
    ApplyCorner(Container, CORNERS.XL)
    ApplyStroke(Container, COLORS.GlassBorder, 1.5, 0.42)
    ApplyShadow(Container, 6, 0.62)

    if animateOpen then
        local origSize = Container.Size
        local origPos  = Container.Position
        Container.Size              = UDim2.new(0, defW*0.88, 0, defH*0.88)
        Container.Position          = UDim2.new(0, defPosX + defW*0.06, 0, defPosY + defH*0.06)
        Container.BackgroundTransparency = 1
        Tween(Container, {
            Size     = origSize,
            Position = origPos,
            BackgroundTransparency = BG_TRANS,
        }, DURATION.Slow, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end

    -- ===== HEADER =====
    local HEADER_H = 64
    local Header = MakeFrame({
        Name   = "Header",
        Size   = UDim2.new(1,0,0,HEADER_H),
        Color  = COLORS.White, Trans = 0.6,
        ZIndex = 3, Parent = Container,
    })
    -- header bottom divider
    MakeFrame({
        Size     = UDim2.new(1,0,0,1),
        Position = UDim2.new(0,0,1,-1),
        Color    = COLORS.GlassBorder, Trans = 0.55,
        ZIndex   = 4, Parent = Header,
    })

    -- Avatar
    if showAvatar then
        local avSz = 40
        local avX  = avatarSide == "right"
            and UDim2.new(1,-(avSz+14),0.5,-avSz/2)
            or  UDim2.new(0,14,0.5,-avSz/2)

        local avFrame = MakeFrame({
            Size = UDim2.new(0,avSz,0,avSz),
            Position = avX,
            Color = COLORS.White, Trans = 0.05,
            ZIndex = 4, Parent = Header,
        })
        ApplyCorner(avFrame, CORNERS.FULL)
        ApplyStroke(avFrame, COLORS.White, 2.5, 0.1)

        local uid = LocalPlayer.UserId
        local avImg = MakeImage({
            Image    = "rbxthumb://type=AvatarHeadShot&id=" .. uid .. "&w=150&h=150",
            Color    = COLORS.White,
            Size     = UDim2.new(1,0,1,0),
            Position = UDim2.new(0,0,0,0),
            ZIndex   = 5, Parent = avFrame,
        })
        ApplyCorner(avImg, CORNERS.FULL)

        -- Status dot
        local dot = MakeFrame({
            Size     = UDim2.new(0,11,0,11),
            Position = UDim2.new(1,-11,1,-11),
            Color    = COLORS.Success, Trans = 0,
            ZIndex   = 6, Parent = avFrame,
        })
        ApplyCorner(dot, CORNERS.FULL)
        ApplyStroke(dot, COLORS.White, 2, 0)
    end

    local titleOffX = showAvatar and (avatarSide ~= "right" and 66 or 14) or 14
    MakeLabel({
        Text      = winTitle,
        Font      = FONTS.Display, Size = 18,
        Color     = COLORS.TextPrimary,
        FrameSize = UDim2.new(1,-130,0,22),
        Position  = UDim2.new(0,titleOffX,0, winSub~="" and 10 or 21),
        ZIndex    = 4, Parent = Header,
    })
    if winSub ~= "" then
        MakeLabel({
            Text      = winSub,
            Font      = FONTS.Body, Size = 11,
            Color     = COLORS.TextSecondary,
            FrameSize = UDim2.new(1,-130,0,14),
            Position  = UDim2.new(0,titleOffX,0,34),
            ZIndex    = 4, Parent = Header,
        })
    end

    -- Close button
    local closeBtn = MakeButton({
        Text = "✕", TextSize = 13,
        TextColor = COLORS.TextMuted,
        Color = COLORS.Surface, Trans = 0.25,
        Size = UDim2.new(0,30,0,30),
        Position = UDim2.new(1,-44,0.5,-15),
        ZIndex = 5, Parent = Header,
    })
    ApplyCorner(closeBtn, CORNERS.FULL)
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn,{BackgroundColor3=COLORS.Error,TextColor3=COLORS.White,BackgroundTransparency=0},DURATION.Fast)
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn,{BackgroundColor3=COLORS.Surface,TextColor3=COLORS.TextMuted,BackgroundTransparency=0.25},DURATION.Fast)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Tween(Container,{BackgroundTransparency=1,Size=UDim2.new(0,defW*0.88,0,defH*0.88)},DURATION.Normal)
        task.delay(DURATION.Normal, function()
            pcall(function() sg:Destroy() end)
        end)
    end)

    -- ===== SIDEBAR =====
    local SIDEBAR_W = 185
    local Sidebar = MakeFrame({
        Name     = "Sidebar",
        Size     = UDim2.new(0,SIDEBAR_W,1,-HEADER_H),
        Position = UDim2.new(0,0,0,HEADER_H),
        Color    = COLORS.SidebarBg, Trans = 0.35,
        ZIndex   = 3, Parent = Container,
    })
    MakeFrame({  -- divider kanan sidebar
        Size = UDim2.new(0,1,1,0), Position = UDim2.new(1,-1,0,0),
        Color = COLORS.GlassBorder, Trans = 0.55,
        ZIndex = 4, Parent = Sidebar,
    })

    local SidebarScroll = MakeScroll({
        Size = UDim2.new(1,0,1,-8), Position = UDim2.new(0,0,0,4),
        BarSize = 2, ZIndex = 4, Parent = Sidebar,
    })
    local sideList = Instance.new("UIListLayout")
    sideList.SortOrder = Enum.SortOrder.LayoutOrder
    sideList.Padding   = UDim.new(0,3)
    sideList.Parent    = SidebarScroll
    local sidePad = Instance.new("UIPadding")
    sidePad.PaddingLeft  = UDim.new(0,SPACING.SM)
    sidePad.PaddingRight = UDim.new(0,SPACING.SM)
    sidePad.PaddingTop   = UDim.new(0,SPACING.XS)
    sidePad.Parent       = SidebarScroll

    -- ===== CONTENT =====
    local ContentArea = MakeFrame({
        Name     = "ContentArea",
        Size     = UDim2.new(1,-SIDEBAR_W,1,-HEADER_H),
        Position = UDim2.new(0,SIDEBAR_W,0,HEADER_H),
        Color    = COLORS.White, Trans = BG_TRANS + 0.25,
        ZIndex   = 3, Parent = Container,
    })
    local ContentScroll = MakeScroll({
        Size = UDim2.new(1,0,1,0),
        BarSize = 3, ZIndex = 4, Parent = ContentArea,
    })
    local contentList = Instance.new("UIListLayout")
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    contentList.Padding   = UDim.new(0,SPACING.SM)
    contentList.Parent    = ContentScroll
    local contentPad = Instance.new("UIPadding")
    contentPad.PaddingTop    = UDim.new(0,SPACING.MD)
    contentPad.PaddingBottom = UDim.new(0,SPACING.MD)
    contentPad.PaddingLeft   = UDim.new(0,SPACING.MD)
    contentPad.PaddingRight  = UDim.new(0,SPACING.MD)
    contentPad.Parent        = ContentScroll

    -- ===== [FIX 3] DRAG SYSTEM =====
    -- Menggunakan UserInputService global, bukan InputBegan di Frame
    -- Karena Frame.InputBegan tidak reliable untuk drag di Roblox
    if draggable then
        local dragging   = false
        local dragStart  = Vector2.new(0,0)
        local winStart   = Vector2.new(0,0)

        local function isInHeader(mousePos)
            local abs = Header.AbsolutePosition
            local sz  = Header.AbsoluteSize
            return mousePos.X >= abs.X and mousePos.X <= abs.X + sz.X
               and mousePos.Y >= abs.Y and mousePos.Y <= abs.Y + sz.Y
        end

        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            local mp = UserInputService:GetMouseLocation()
            if isInHeader(mp) then
                dragging  = true
                dragStart = mp
                local cp  = Container.Position
                winStart  = Vector2.new(cp.X.Offset, cp.Y.Offset)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local mp    = UserInputService:GetMouseLocation()
            local delta = mp - dragStart
            -- Clamp agar tidak keluar layar
            local newX  = math.clamp(winStart.X + delta.X, 0, vp.X - defW)
            local newY  = math.clamp(winStart.Y + delta.Y, 0, vp.Y - defH)
            Container.Position = UDim2.new(0, newX, 0, newY)
        end)
    end

    -- ===== TAB SYSTEM =====
    local tabs      = {}
    local activeTab = nil

    local function setActive(name)
        for n, td in pairs(tabs) do
            local on = n == name
            Tween(td.Btn, {
                BackgroundColor3     = on and COLORS.Accent or COLORS.SidebarBg,
                BackgroundTransparency = on and 0.82 or 1,
            }, DURATION.Fast)
            Tween(td.Lbl, {TextColor3 = on and COLORS.Accent or COLORS.TextSecondary}, DURATION.Fast)
            if td.Ico then
                Tween(td.Ico, {ImageColor3 = on and COLORS.Accent or COLORS.TextSecondary}, DURATION.Fast)
            end
            td.Content.Visible = on
        end
        activeTab = name
    end

    -- ===== WINDOW API =====
    local WindowAPI = {}

    function WindowAPI:CreateTab(config)
        local cfg      = config or {}
        local tabName  = cfg.Name or "Tab"
        local tabIcon  = cfg.Icon or ""
        local tabOrder = cfg.Order or (function()
            local n = 0
            for _ in pairs(tabs) do n = n + 1 end
            return (n+1)*10
        end)()
        local tabBadge = cfg.Badge or nil

        -- Tab button (sidebar)
        local tabBtn = MakeButton({
            Name  = tabName.."_Btn",
            Text  = "",
            Color = COLORS.SidebarBg, Trans = 1,
            Size  = UDim2.new(1,0,0,38),
            ZIndex = 5, Parent = SidebarScroll,
        })
        tabBtn.LayoutOrder = tabOrder
        ApplyCorner(tabBtn, CORNERS.SM)

        local tabIco = nil
        if tabIcon ~= "" then
            tabIco = MakeImage({
                Image    = tabIcon,
                Color    = COLORS.TextSecondary,
                Size     = UDim2.new(0,16,0,16),
                Position = UDim2.new(0,10,0.5,-8),
                ZIndex   = 6, Parent = tabBtn,
            })
        end

        local tabLbl = MakeLabel({
            Text      = tabName,
            Font      = FONTS.Subtitle, Size = 13,
            Color     = COLORS.TextSecondary,
            FrameSize = UDim2.new(1, tabIcon~=""and-36 or-10, 1, 0),
            Position  = UDim2.new(0, tabIcon~=""and 32 or 10, 0, 0),
            ZIndex    = 6, Parent = tabBtn,
        })

        if tabBadge then
            local bdg = MakeFrame({
                Size = UDim2.new(0,18,0,16),
                Position = UDim2.new(1,-22,0.5,-8),
                Color = COLORS.Error, Trans = 0,
                ZIndex = 7, Parent = tabBtn,
            })
            ApplyCorner(bdg, CORNERS.FULL)
            MakeLabel({
                Text = tostring(tabBadge), Font = FONTS.Caption, Size = 10,
                Color = COLORS.White,
                FrameSize = UDim2.new(1,0,1,0),
                AlignX = Enum.TextXAlignment.Center,
                ZIndex = 8, Parent = bdg,
            })
        end

        -- Content frame for this tab
        local tabContent = MakeFrame({
            Name  = tabName.."_Content",
            Size  = UDim2.new(1,0,0,0),
            Color = COLORS.Black, Trans = 1,
            ZIndex = 4, Parent = ContentScroll,
        })
        tabContent.AutomaticSize = Enum.AutomaticSize.Y
        tabContent.Visible       = false
        tabContent.LayoutOrder   = tabOrder

        local tcList = Instance.new("UIListLayout")
        tcList.SortOrder = Enum.SortOrder.LayoutOrder
        tcList.Padding   = UDim.new(0, SPACING.SM)
        tcList.Parent    = tabContent

        tabs[tabName] = {Btn=tabBtn, Lbl=tabLbl, Ico=tabIco, Content=tabContent}

        if activeTab == nil then setActive(tabName) end

        tabBtn.MouseEnter:Connect(function()
            if activeTab ~= tabName then
                Tween(tabBtn,{BackgroundTransparency=0.92},DURATION.Fast)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTab ~= tabName then
                Tween(tabBtn,{BackgroundTransparency=1},DURATION.Fast)
            end
        end)
        tabBtn.MouseButton1Click:Connect(function() setActive(tabName) end)

        -- ===== TAB API =====
        local TabAPI   = {}
        local _order   = 0
        local function O() _order = _order + 10; return _order end

        -- ---- TOGGLE ----
        function TabAPI:CreateToggle(c)
            local c       = c or {}
            local name    = c.Name or "Toggle"
            local desc    = c.Description or ""
            local icon    = c.Icon or ""
            local def     = c.Default == true
            local flag    = c.Flag
            local cb      = c.Callback or function() end
            local o       = O()

            -- [FIX 4] Fixed height, no AutomaticSize
            local rowH    = desc ~= "" and 62 or 48
            local row     = BaseRow(tabContent, rowH, o, 4)

            -- ICON — posisi Y absolut di tengah row
            local iconImg = nil
            if icon ~= "" then
                iconImg = MakeImage({
                    Image    = icon,
                    Color    = def and COLORS.Accent or COLORS.TextSecondary,
                    Size     = UDim2.new(0,18,0,18),
                    Position = UDim2.new(0, SPACING.LG, 0, math.floor(rowH/2)-9),
                    ZIndex   = 5, Parent = row,
                })
            end

            local tx = icon ~= "" and (SPACING.LG + 26) or SPACING.LG
            local ty = desc ~= "" and 9 or math.floor(rowH/2)-9

            MakeLabel({
                Text      = name,
                Font      = FONTS.Subtitle, Size = 13,
                Color     = COLORS.TextPrimary,
                FrameSize = UDim2.new(1,-124,0,18),
                Position  = UDim2.new(0,tx,0,ty),
                ZIndex    = 5, Parent = row,
            })
            if desc ~= "" then
                MakeLabel({
                    Text      = desc,
                    Font      = FONTS.Caption, Size = 11,
                    Color     = COLORS.TextMuted,
                    FrameSize = UDim2.new(1,-124,0,14),
                    Position  = UDim2.new(0,tx,0,ty+20),
                    ZIndex    = 5, Parent = row,
                })
            end

            -- Switch track
            local trackY = math.floor(rowH/2) - 13
            local track  = MakeFrame({
                Size     = UDim2.new(0,46,0,26),
                Position = UDim2.new(1,-62,0,trackY),
                Color    = def and COLORS.Accent or COLORS.TrackOff,
                Trans    = 0, ZIndex = 5, Parent = row,
            })
            ApplyCorner(track, CORNERS.FULL)

            local thumbX   = def and 22 or 3
            local thumb    = MakeFrame({
                Size     = UDim2.new(0,20,0,20),
                Position = UDim2.new(0,thumbX,0.5,-10),
                Color    = COLORS.White, Trans = 0,
                ZIndex   = 6, Parent = track,
            })
            ApplyCorner(thumb, CORNERS.FULL)
            ApplyShadow(thumb, 2, 0.6)

            local toggled = def
            if flag then Nexuralib.Flags[flag] = toggled end

            local function setToggle(val, silent)
                toggled = val
                if flag then Nexuralib.Flags[flag] = val end
                SpringTween(thumb,{Position=UDim2.new(0, val and 22 or 3, 0.5,-10)},0.3)
                Tween(track,{BackgroundColor3= val and COLORS.Accent or COLORS.TrackOff},DURATION.Normal)
                if iconImg then
                    Tween(iconImg,{ImageColor3= val and COLORS.Accent or COLORS.TextSecondary},DURATION.Fast)
                end
                if not silent then cb(val) end
            end

            track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    setToggle(not toggled)
                end
            end)

            return {
                SetValue = function(v) setToggle(v, true) end,
                GetValue = function() return toggled end,
            }
        end

        -- ---- BUTTON ----
        function TabAPI:CreateButton(c)
            local c       = c or {}
            local name    = c.Name or "Button"
            local desc    = c.Description or ""
            local icon    = c.Icon or ""
            local variant = c.Variant or "primary"
            local fw      = c.FullWidth or false
            local cb      = c.Callback or function() end
            local o       = O()

            local rowH    = 56
            local row     = BaseRow(tabContent, rowH, o, 4)

            -- variant colors
            local bgCol, fgCol, bgTr
            if variant == "primary"   then bgCol=COLORS.Accent;   fgCol=COLORS.White;         bgTr=0
            elseif variant=="secondary" then bgCol=COLORS.Surface; fgCol=COLORS.Accent;        bgTr=0.2
            elseif variant=="ghost"   then bgCol=COLORS.Black;    fgCol=COLORS.Accent;         bgTr=1
            elseif variant=="danger"  then bgCol=COLORS.Error;    fgCol=COLORS.White;          bgTr=0
            else                           bgCol=COLORS.Accent;   fgCol=COLORS.White;          bgTr=0
            end

            if desc ~= "" then
                MakeLabel({
                    Text = desc, Font = FONTS.Caption, Size = 11,
                    Color = COLORS.TextMuted,
                    FrameSize = UDim2.new(0.5,-SPACING.MD,0,14),
                    Position  = UDim2.new(0,SPACING.LG,0.5,-7),
                    ZIndex = 5, Parent = row,
                })
            end

            local btnW = fw and -(SPACING.XXL) or 150
            local btn  = MakeButton({
                Text = "", Color = bgCol, Trans = bgTr,
                Size = fw
                    and UDim2.new(1,-(SPACING.XXL),0,36)
                    or  UDim2.new(0,150,0,36),
                Position = fw
                    and UDim2.new(0,SPACING.MD,0.5,-18)
                    or  UDim2.new(1,-(150+SPACING.MD),0.5,-18),
                ZIndex = 5, Parent = row,
            })
            ApplyCorner(btn, CORNERS.SM)
            if variant=="secondary" or variant=="ghost" then
                ApplyStroke(btn, COLORS.Accent, 1.5, 0.35)
            end

            if icon ~= "" then
                MakeImage({
                    Image = icon, Color = fgCol,
                    Size = UDim2.new(0,14,0,14),
                    Position = UDim2.new(0,SPACING.MD,0.5,-7),
                    ZIndex = 6, Parent = btn,
                })
            end
            MakeLabel({
                Text = name, Font = FONTS.Title, Size = 13,
                Color = fgCol,
                FrameSize = UDim2.new(1, icon~=""and-38 or-SPACING.MD, 1, 0),
                Position  = UDim2.new(0, icon~=""and 34 or SPACING.SM, 0, 0),
                AlignX    = Enum.TextXAlignment.Center,
                ZIndex = 6, Parent = btn,
            })

            btn.MouseEnter:Connect(function()
                Tween(btn,{BackgroundTransparency=math.max(0,bgTr-0.1)},DURATION.Fast)
                Tween(btn,{Position=UDim2.new(btn.Position.X.Scale,btn.Position.X.Offset,0,btn.Position.Y.Offset-2)},DURATION.Fast)
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn,{BackgroundTransparency=bgTr},DURATION.Fast)
                Tween(btn,{Position=UDim2.new(btn.Position.X.Scale,btn.Position.X.Offset,0,btn.Position.Y.Offset+2)},DURATION.Fast)
            end)
            btn.MouseButton1Click:Connect(function()
                local mp = UserInputService:GetMouseLocation()
                local rp = mp - Vector2.new(btn.AbsolutePosition.X, btn.AbsolutePosition.Y)
                Ripple(btn, rp.X, rp.Y)
                cb()
            end)

            return {}
        end

        -- ---- SLIDER ----
        function TabAPI:CreateSlider(c)
            local c    = c or {}
            local name = c.Name or "Slider"
            local desc = c.Description or ""
            local icon = c.Icon or ""
            local minV = c.Min or 0
            local maxV = c.Max or 100
            local def  = c.Default or minV
            local inc  = c.Increment or 1
            local fmt  = c.ValueFormat or "%d"
            local showV= c.ShowValue ~= false
            local flag = c.Flag
            local cb   = c.Callback or function() end
            local o    = O()

            local rowH = desc ~= "" and 76 or 60
            local row  = BaseRow(tabContent, rowH, o, 4)

            if icon ~= "" then
                MakeImage({
                    Image = icon, Color = COLORS.TextSecondary,
                    Size = UDim2.new(0,18,0,18),
                    Position = UDim2.new(0,SPACING.LG,0,10),
                    ZIndex = 5, Parent = row,
                })
            end
            local tx = icon ~= "" and (SPACING.LG+26) or SPACING.LG
            MakeLabel({
                Text = name, Font = FONTS.Subtitle, Size = 13,
                Color = COLORS.TextPrimary,
                FrameSize = UDim2.new(1,-80,0,18),
                Position  = UDim2.new(0,tx,0,9),
                ZIndex = 5, Parent = row,
            })
            if desc ~= "" then
                MakeLabel({
                    Text = desc, Font = FONTS.Caption, Size = 11,
                    Color = COLORS.TextMuted,
                    FrameSize = UDim2.new(1,-80,0,14),
                    Position  = UDim2.new(0,tx,0,29),
                    ZIndex = 5, Parent = row,
                })
            end

            local valLbl = nil
            if showV then
                valLbl = MakeLabel({
                    Text = string.format(fmt, def),
                    Font = FONTS.Code, Size = 12,
                    Color = COLORS.Accent,
                    FrameSize = UDim2.new(0,54,0,18),
                    Position  = UDim2.new(1,-62,0,9),
                    AlignX    = Enum.TextXAlignment.Right,
                    ZIndex = 5, Parent = row,
                })
            end

            local trkY = desc ~= "" and 54 or 40
            local trkW = showV and -SPACING.XXL or -(SPACING.LG*2)
            local trk  = MakeFrame({
                Size     = UDim2.new(1, -(SPACING.LG*2 + (showV and 60 or 0)), 0, 6),
                Position = UDim2.new(0,SPACING.LG,0,trkY),
                Color    = Color3.fromRGB(218,218,223), Trans = 0.1,
                ZIndex   = 5, Parent = row,
            })
            ApplyCorner(trk, CORNERS.FULL)

            local fill = MakeFrame({
                Size  = UDim2.new(0,0,1,0),
                Color = COLORS.Accent, Trans = 0,
                ZIndex = 6, Parent = trk,
            })
            ApplyCorner(fill, CORNERS.FULL)

            local thumb = MakeFrame({
                Size     = UDim2.new(0,18,0,18),
                Position = UDim2.new(0,-9,0.5,-9),
                Color    = COLORS.White, Trans = 0,
                ZIndex   = 7, Parent = fill,
            })
            ApplyCorner(thumb, CORNERS.FULL)
            ApplyStroke(thumb, COLORS.Accent, 2, 0)
            ApplyShadow(thumb, 2, 0.55)

            local cur = def
            if flag then Nexuralib.Flags[flag] = cur end

            local function snap(v)
                return math.clamp(math.round((v-minV)/inc)*inc+minV, minV, maxV)
            end
            local function setSlider(v, silent)
                cur = snap(v)
                if flag then Nexuralib.Flags[flag] = cur end
                local pct = (cur-minV)/(maxV-minV)
                Tween(fill,{Size=UDim2.new(pct,0,1,0)},DURATION.Fast)
                if valLbl then valLbl.Text = string.format(fmt,cur) end
                if not silent then cb(cur) end
            end
            setSlider(def, true)

            local dragging = false
            trk.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    Tween(thumb,{Size=UDim2.new(0,22,0,22),Position=UDim2.new(0,-11,0.5,-11)},DURATION.Fast)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                    dragging = false
                    Tween(thumb,{Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,-9,0.5,-9)},DURATION.Fast)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if not dragging then return end
                if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                local ap  = trk.AbsolutePosition
                local aw  = trk.AbsoluteSize.X
                local rel = math.clamp(inp.Position.X - ap.X, 0, aw)
                setSlider(minV + (rel/aw)*(maxV-minV))
            end)

            return {
                SetValue = function(v) setSlider(v,true) end,
                GetValue = function() return cur end,
            }
        end

        -- ---- DROPDOWN ----
        function TabAPI:CreateDropdown(c)
            local c       = c or {}
            local name    = c.Name or "Dropdown"
            local desc    = c.Description or ""
            local icon    = c.Icon or ""
            local opts    = c.Options or {}
            local def     = c.Default
            local multi   = c.MultiSelect or false
            local search  = c.Searchable or false
            local flag    = c.Flag
            local cb      = c.Callback or function() end
            local o       = O()

            local rowH    = desc~=""and 62 or 50
            local row     = BaseRow(tabContent, rowH, o, 4)

            if icon ~= "" then
                MakeImage({
                    Image = icon, Color = COLORS.TextSecondary,
                    Size = UDim2.new(0,18,0,18),
                    Position = UDim2.new(0,SPACING.LG,0.5,-9),
                    ZIndex = 5, Parent = row,
                })
            end
            local tx = icon~=""and(SPACING.LG+26)or SPACING.LG
            MakeLabel({
                Text = name, Font = FONTS.Subtitle, Size = 13,
                Color = COLORS.TextPrimary,
                FrameSize = UDim2.new(1,-140,0,18),
                Position  = UDim2.new(0,tx,0,desc~=""and 7 or(rowH/2-9)),
                ZIndex = 5, Parent = row,
            })
            if desc ~= "" then
                MakeLabel({
                    Text = desc, Font = FONTS.Caption, Size = 11,
                    Color = COLORS.TextMuted,
                    FrameSize = UDim2.new(1,-140,0,14),
                    Position  = UDim2.new(0,tx,0,27),
                    ZIndex = 5, Parent = row,
                })
            end

            local sel     = multi and {} or def
            if flag then Nexuralib.Flags[flag] = sel end

            local selBtn  = MakeButton({
                Text = def or "Select...",
                Font = FONTS.Body, TextSize = 12,
                TextColor = def and COLORS.TextPrimary or COLORS.TextMuted,
                Color = COLORS.Surface, Trans = 0.2,
                Size = UDim2.new(0,130,0,30),
                Position = UDim2.new(1,-(130+SPACING.MD),0.5,-15),
                ZIndex = 5, Parent = row,
            })
            ApplyCorner(selBtn, CORNERS.SM)
            ApplyStroke(selBtn, COLORS.GlassBorder, 1, 0.5)

            MakeLabel({
                Text = "▾", Font = FONTS.Body, Size = 11,
                Color = COLORS.TextMuted,
                FrameSize = UDim2.new(0,14,1,0),
                Position  = UDim2.new(1,-16,0,0),
                AlignX    = Enum.TextXAlignment.Center,
                ZIndex = 6, Parent = selBtn,
            })

            local menu = nil
            local function closeMenu()
                if menu then
                    Tween(menu,{BackgroundTransparency=1,Size=UDim2.new(menu.Size.X.Scale,menu.Size.X.Offset,0,0)},DURATION.Fast)
                    task.delay(DURATION.Fast,function() pcall(function() menu:Destroy() menu=nil end) end)
                end
            end

            selBtn.MouseButton1Click:Connect(function()
                if menu then closeMenu() return end

                local mH = math.min(#opts*32+(search and 36 or 6)+6, 180)
                menu = MakeFrame({
                    Size = UDim2.new(0,170,0,0),
                    Position = UDim2.new(1,-(170+SPACING.MD),0,rowH+2),
                    Color = COLORS.White, Trans = BG_TRANS,
                    ZIndex = 20, Parent = row,
                })
                menu.ClipsDescendants = true
                ApplyCorner(menu, CORNERS.MD)
                ApplyStroke(menu, COLORS.GlassBorder, 1, 0.4)
                ApplyShadow(menu, 4, 0.65)
                Tween(menu,{Size=UDim2.new(0,170,0,mH)},DURATION.Normal,Enum.EasingStyle.Back,Enum.EasingDirection.Out)

                local ms = MakeScroll({Size=UDim2.new(1,0,1,0),BarSize=2,ZIndex=21,Parent=menu})
                local ml = Instance.new("UIListLayout")
                ml.SortOrder=Enum.SortOrder.LayoutOrder; ml.Padding=UDim.new(0,2); ml.Parent=ms
                local mp = Instance.new("UIPadding")
                mp.PaddingAll=UDim.new(0,3); mp.Parent=ms

                local function buildOpts(filter)
                    for _,ch in ipairs(ms:GetChildren()) do
                        if ch.Name:sub(1,4)=="Opt_" then ch:Destroy() end
                    end
                    for i,opt in ipairs(opts) do
                        if filter=="" or opt:lower():find(filter:lower(),1,true) then
                            local isSel = multi
                                and (function() for _,v in ipairs(sel) do if v==opt then return true end end return false end)()
                                or sel==opt
                            local ob = MakeButton({
                                Name="Opt_"..opt, Text="",
                                Color = isSel and COLORS.Accent or COLORS.Black,
                                Trans = isSel and 0.85 or 1,
                                Size = UDim2.new(1,0,0,30),
                                ZIndex=22, Parent=ms,
                            })
                            ob.LayoutOrder=i
                            ApplyCorner(ob,CORNERS.SM)
                            MakeLabel({
                                Text=opt,Font=FONTS.Body,Size=12,
                                Color=isSel and COLORS.Accent or COLORS.TextPrimary,
                                FrameSize=UDim2.new(1,-28,1,0),
                                Position=UDim2.new(0,8,0,0),
                                ZIndex=23,Parent=ob,
                            })
                            if isSel then
                                MakeLabel({Text="✓",Font=FONTS.Title,Size=12,Color=COLORS.Accent,
                                    FrameSize=UDim2.new(0,18,1,0),
                                    Position=UDim2.new(1,-20,0,0),
                                    AlignX=Enum.TextXAlignment.Center,
                                    ZIndex=23,Parent=ob})
                            end
                            ob.MouseEnter:Connect(function()
                                if not isSel then Tween(ob,{BackgroundTransparency=0.94},DURATION.Fast) end
                            end)
                            ob.MouseLeave:Connect(function()
                                if not isSel then Tween(ob,{BackgroundTransparency=1},DURATION.Fast) end
                            end)
                            ob.MouseButton1Click:Connect(function()
                                if multi then
                                    local found=false
                                    for i2,v in ipairs(sel) do
                                        if v==opt then table.remove(sel,i2);found=true;break end
                                    end
                                    if not found then table.insert(sel,opt) end
                                    selBtn.Text = #sel>0 and table.concat(sel,", ") or "Select..."
                                    selBtn.TextColor3 = #sel>0 and COLORS.TextPrimary or COLORS.TextMuted
                                    if flag then Nexuralib.Flags[flag]=sel end
                                    cb(sel); buildOpts(filter)
                                else
                                    sel=opt
                                    selBtn.Text=opt; selBtn.TextColor3=COLORS.TextPrimary
                                    if flag then Nexuralib.Flags[flag]=sel end
                                    cb(sel); closeMenu()
                                end
                            end)
                        end
                    end
                end
                buildOpts("")
            end)

            return {
                SetValue = function(v)
                    sel=v; selBtn.Text=type(v)=="table"and(#v>0 and table.concat(v,", ")or"Select...")or(v or"Select...")
                    selBtn.TextColor3=v and COLORS.TextPrimary or COLORS.TextMuted
                    if flag then Nexuralib.Flags[flag]=v end
                end,
                GetValue = function() return sel end,
            }
        end

        -- ---- INPUT ----
        function TabAPI:CreateInput(c)
            local c      = c or {}
            local name   = c.Name or "Input"
            local desc   = c.Description or ""
            local icon   = c.Icon or ""
            local ph     = c.Placeholder or "Enter value..."
            local def    = c.Default or ""
            local clrBtn = c.ClearButton ~= false
            local valid  = c.Validation
            local flag   = c.Flag
            local cb     = c.Callback or function() end
            local o      = O()

            local rowH   = desc~=""and 76 or 62
            local row    = BaseRow(tabContent, rowH, o, 4)

            if icon ~= "" then
                MakeImage({
                    Image=icon,Color=COLORS.TextSecondary,
                    Size=UDim2.new(0,18,0,18),
                    Position=UDim2.new(0,SPACING.LG,0,9),
                    ZIndex=5,Parent=row,
                })
            end
            local tx = icon~=""and(SPACING.LG+26)or SPACING.LG
            MakeLabel({
                Text=name,Font=FONTS.Subtitle,Size=13,
                Color=COLORS.TextPrimary,
                FrameSize=UDim2.new(1,-80,0,16),
                Position=UDim2.new(0,tx,0,7),
                ZIndex=5,Parent=row,
            })
            if desc ~= "" then
                MakeLabel({
                    Text=desc,Font=FONTS.Caption,Size=11,
                    Color=COLORS.TextMuted,
                    FrameSize=UDim2.new(1,-80,0,13),
                    Position=UDim2.new(0,tx,0,25),
                    ZIndex=5,Parent=row,
                })
            end

            local ibY   = desc~=""and 44 or 32
            local ibg   = MakeFrame({
                Size=UDim2.new(1,-(SPACING.LG*2),0,28),
                Position=UDim2.new(0,SPACING.LG,0,ibY),
                Color=COLORS.Surface,Trans=0.2,
                ZIndex=5,Parent=row,
            })
            ApplyCorner(ibg, CORNERS.SM)
            local ibStroke = ApplyStroke(ibg, COLORS.GlassBorder, 1, 0.5)

            local box = Instance.new("TextBox")
            box.PlaceholderText    = ph
            box.Text               = def
            box.Font               = FONTS.Body
            box.TextSize           = 13
            box.TextColor3         = COLORS.TextPrimary
            box.PlaceholderColor3  = COLORS.TextMuted
            box.BackgroundTransparency = 1
            box.Size               = UDim2.new(1,clrBtn and-32 or-8,1,0)
            box.Position           = UDim2.new(0,6,0,0)
            box.ZIndex             = 6
            box.ClearTextOnFocus   = false
            box.Parent             = ibg

            if clrBtn then
                local cb2 = MakeButton({
                    Text="✕",TextSize=10,TextColor=COLORS.TextMuted,
                    Color=COLORS.Black,Trans=1,
                    Size=UDim2.new(0,24,0,24),
                    Position=UDim2.new(1,-26,0.5,-12),
                    ZIndex=7,Parent=ibg,
                })
                cb2.MouseButton1Click:Connect(function()
                    box.Text=""
                    if flag then Nexuralib.Flags[flag]="" end
                    cb("")
                end)
            end

            box.Focused:Connect(function()
                Tween(ibg,{BackgroundTransparency=0.05},DURATION.Fast)
                ibStroke.Color=COLORS.Accent; ibStroke.Transparency=0.2
            end)
            box.FocusLost:Connect(function()
                Tween(ibg,{BackgroundTransparency=0.2},DURATION.Fast)
                ibStroke.Color=COLORS.GlassBorder; ibStroke.Transparency=0.5
                local val=box.Text
                if flag then Nexuralib.Flags[flag]=val end
                cb(val)
            end)

            return {
                SetValue=function(v) box.Text=v end,
                GetValue=function() return box.Text end,
            }
        end

        -- ---- KEYBIND ----
        function TabAPI:CreateKeybind(c)
            local c    = c or {}
            local name = c.Name or "Keybind"
            local desc = c.Description or ""
            local icon = c.Icon or ""
            local def  = c.Default or Enum.KeyCode.Unknown
            local hold = c.Hold or false
            local bl   = c.Blacklist or {}
            local flag = c.Flag
            local cb   = c.Callback or function() end
            local o    = O()

            local rowH = desc~=""and 62 or 48
            local row  = BaseRow(tabContent, rowH, o, 4)

            if icon ~= "" then
                MakeImage({
                    Image=icon,Color=COLORS.TextSecondary,
                    Size=UDim2.new(0,18,0,18),
                    Position=UDim2.new(0,SPACING.LG,0.5,-9),
                    ZIndex=5,Parent=row,
                })
            end
            local tx = icon~=""and(SPACING.LG+26)or SPACING.LG
            MakeLabel({
                Text=name,Font=FONTS.Subtitle,Size=13,
                Color=COLORS.TextPrimary,
                FrameSize=UDim2.new(1,-120,0,18),
                Position=UDim2.new(0,tx,0,desc~=""and 7 or(rowH/2-9)),
                ZIndex=5,Parent=row,
            })
            if desc ~= "" then
                MakeLabel({
                    Text=desc,Font=FONTS.Caption,Size=11,
                    Color=COLORS.TextMuted,
                    FrameSize=UDim2.new(1,-120,0,14),
                    Position=UDim2.new(0,tx,0,27),
                    ZIndex=5,Parent=row,
                })
            end

            local curKey = def
            if flag then Nexuralib.Flags[flag]=curKey end

            local pill = MakeButton({
                Text = curKey==Enum.KeyCode.Unknown and "None" or curKey.Name,
                Font=FONTS.Code,TextSize=11,
                TextColor=COLORS.Accent,
                Color=COLORS.Accent,Trans=0.88,
                Size=UDim2.new(0,84,0,26),
                Position=UDim2.new(1,-(84+SPACING.MD),0.5,-13),
                ZIndex=5,Parent=row,
            })
            ApplyCorner(pill,CORNERS.FULL)
            ApplyStroke(pill,COLORS.Accent,1,0.55)

            local recording=false
            pill.MouseButton1Click:Connect(function()
                if recording then return end
                recording=true; pill.Text="..."
                Tween(pill,{BackgroundTransparency=0.7},DURATION.Fast)
                local conn
                conn=UserInputService.InputBegan:Connect(function(inp,gp)
                    if gp then return end
                    local bad=false
                    for _,k in ipairs(bl) do if inp.KeyCode==k then bad=true;break end end
                    if not bad and inp.UserInputType==Enum.UserInputType.Keyboard then
                        curKey=inp.KeyCode
                        pill.Text=curKey.Name
                        if flag then Nexuralib.Flags[flag]=curKey end
                        recording=false
                        Tween(pill,{BackgroundTransparency=0.88},DURATION.Fast)
                        conn:Disconnect()
                    end
                end)
            end)

            UserInputService.InputBegan:Connect(function(inp,gp)
                if gp then return end
                if inp.KeyCode==curKey and curKey~=Enum.KeyCode.Unknown then
                    if not hold then cb(true) end
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.KeyCode==curKey and hold then cb(false) end
            end)

            return {
                SetKey=function(k) curKey=k; pill.Text=k==Enum.KeyCode.Unknown and"None"or k.Name end,
                GetKey=function() return curKey end,
            }
        end

        -- ---- COLOR PICKER ----
        function TabAPI:CreateColorPicker(c)
            local c      = c or {}
            local name   = c.Name or "Color"
            local desc   = c.Description or ""
            local icon   = c.Icon or ""
            local def    = c.Default or Color3.fromRGB(0,122,255)
            local pres   = c.Presets or {
                Color3.fromRGB(255,59,48),Color3.fromRGB(255,149,0),
                Color3.fromRGB(255,204,0),Color3.fromRGB(52,199,89),
                Color3.fromRGB(0,122,255),Color3.fromRGB(175,82,222),
            }
            local showHex= c.ShowHex ~= false
            local flag   = c.Flag
            local cb     = c.Callback or function() end
            local o      = O()

            local rowH   = desc~=""and 60 or 48
            local row    = BaseRow(tabContent, rowH, o, 4)

            if icon ~= "" then
                MakeImage({
                    Image=icon,Color=COLORS.TextSecondary,
                    Size=UDim2.new(0,18,0,18),
                    Position=UDim2.new(0,SPACING.LG,0.5,-9),
                    ZIndex=5,Parent=row,
                })
            end
            local tx = icon~=""and(SPACING.LG+26)or SPACING.LG
            MakeLabel({
                Text=name,Font=FONTS.Subtitle,Size=13,
                Color=COLORS.TextPrimary,
                FrameSize=UDim2.new(1,-110,0,18),
                Position=UDim2.new(0,tx,0,desc~=""and 7 or(rowH/2-9)),
                ZIndex=5,Parent=row,
            })
            if desc ~= "" then
                MakeLabel({
                    Text=desc,Font=FONTS.Caption,Size=11,
                    Color=COLORS.TextMuted,
                    FrameSize=UDim2.new(1,-110,0,14),
                    Position=UDim2.new(0,tx,0,27),
                    ZIndex=5,Parent=row,
                })
            end

            local curCol = def
            if flag then Nexuralib.Flags[flag]=curCol end

            local swatch = MakeButton({
                Text="",Color=curCol,Trans=0,
                Size=UDim2.new(0,36,0,24),
                Position=UDim2.new(1,-(36+SPACING.MD),0.5,-12),
                ZIndex=5,Parent=row,
            })
            ApplyCorner(swatch,CORNERS.SM)
            ApplyStroke(swatch,COLORS.GlassBorder,1.5,0.3)

            local function hexStr(c2)
                return string.format("#%02X%02X%02X",
                    math.floor(c2.R*255),math.floor(c2.G*255),math.floor(c2.B*255))
            end

            local hexLbl = MakeLabel({
                Text=hexStr(curCol),Font=FONTS.Code,Size=11,
                Color=COLORS.TextSecondary,
                FrameSize=UDim2.new(0,62,0,16),
                Position=UDim2.new(1,-(36+SPACING.MD+68),0.5,-8),
                AlignX=Enum.TextXAlignment.Right,
                ZIndex=5,Parent=row,
            })

            local function updateColor(c2,silent)
                curCol=c2; swatch.BackgroundColor3=c2
                hexLbl.Text=hexStr(c2)
                if flag then Nexuralib.Flags[flag]=c2 end
                if not silent then cb(c2) end
            end

            local picker = nil
            swatch.MouseButton1Click:Connect(function()
                if picker then
                    Tween(picker,{BackgroundTransparency=1,Size=UDim2.new(1,-SPACING.XXL,0,0)},DURATION.Fast)
                    task.delay(DURATION.Fast,function() pcall(function() picker:Destroy();picker=nil end) end)
                    return
                end

                local pH = 190 + (#pres>0 and 36 or 0) + (showHex and 36 or 0)
                picker = MakeFrame({
                    Size=UDim2.new(1,-SPACING.XXL,0,0),
                    Position=UDim2.new(0,SPACING.MD,0,rowH+4),
                    Color=COLORS.White,Trans=BG_TRANS,
                    ZIndex=15,Parent=row,
                })
                picker.ClipsDescendants=true
                ApplyCorner(picker,CORNERS.MD)
                ApplyStroke(picker,COLORS.GlassBorder,1,0.4)
                ApplyShadow(picker,4,0.65)
                Tween(picker,{Size=UDim2.new(1,-SPACING.XXL,0,pH)},DURATION.Normal,Enum.EasingStyle.Back,Enum.EasingDirection.Out)

                -- Hue bar
                local hueBar = MakeFrame({
                    Size=UDim2.new(1,-SPACING.XXL,0,14),
                    Position=UDim2.new(0,SPACING.MD,0,SPACING.MD),
                    Color=COLORS.White,Trans=0,
                    ZIndex=16,Parent=picker,
                })
                ApplyCorner(hueBar,CORNERS.FULL)
                local hg = Instance.new("UIGradient")
                hg.Color=ColorSequence.new({
                    ColorSequenceKeypoint.new(0/6,Color3.fromRGB(255,0,0)),
                    ColorSequenceKeypoint.new(1/6,Color3.fromRGB(255,255,0)),
                    ColorSequenceKeypoint.new(2/6,Color3.fromRGB(0,255,0)),
                    ColorSequenceKeypoint.new(3/6,Color3.fromRGB(0,255,255)),
                    ColorSequenceKeypoint.new(4/6,Color3.fromRGB(0,0,255)),
                    ColorSequenceKeypoint.new(5/6,Color3.fromRGB(255,0,255)),
                    ColorSequenceKeypoint.new(1,  Color3.fromRGB(255,0,0)),
                })
                hg.Parent=hueBar

                local hThumb = MakeFrame({
                    Size=UDim2.new(0,14,1,4),
                    Position=UDim2.new(0,-7,0,-2),
                    Color=COLORS.White,Trans=0,
                    ZIndex=17,Parent=hueBar,
                })
                ApplyCorner(hThumb,CORNERS.SM)
                ApplyShadow(hThumb,3,0.55)

                -- Saturation/brightness box
                local hueColor = curCol
                local sbBox = MakeFrame({
                    Size=UDim2.new(1,-SPACING.XXL,0,110),
                    Position=UDim2.new(0,SPACING.MD,0,36),
                    Color=hueColor,Trans=0,
                    ZIndex=16,Parent=picker,
                })
                ApplyCorner(sbBox,CORNERS.SM)

                local sgW = Instance.new("UIGradient")
                sgW.Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(1,1,1))
                sgW.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
                sgW.Parent=sbBox

                local cross = MakeFrame({
                    Size=UDim2.new(0,10,0,10),
                    Position=UDim2.new(0,-5,0,-5),
                    Color=COLORS.White,Trans=0,
                    ZIndex=17,Parent=sbBox,
                })
                ApplyCorner(cross,CORNERS.FULL)
                ApplyStroke(cross,COLORS.White,2,0)

                -- Presets
                if #pres>0 then
                    local pRow = MakeFrame({
                        Size=UDim2.new(1,-SPACING.XXL,0,26),
                        Position=UDim2.new(0,SPACING.MD,0,154),
                        Color=COLORS.Black,Trans=1,
                        ZIndex=16,Parent=picker,
                    })
                    local pl = Instance.new("UIListLayout")
                    pl.FillDirection=Enum.FillDirection.Horizontal
                    pl.Padding=UDim.new(0,SPACING.SM)
                    pl.Parent=pRow
                    for _,pc in ipairs(pres) do
                        local pb=MakeButton({
                            Text="",Color=pc,Trans=0,
                            Size=UDim2.new(0,22,0,22),
                            ZIndex=17,Parent=pRow,
                        })
                        ApplyCorner(pb,CORNERS.FULL)
                        ApplyStroke(pb,COLORS.GlassBorder,1.5,0.3)
                        pb.MouseButton1Click:Connect(function() updateColor(pc) end)
                    end
                end

                -- Hex input
                if showHex then
                    local hexY = 154 + (#pres>0 and 36 or 0)
                    local hbg = MakeFrame({
                        Size=UDim2.new(1,-SPACING.XXL,0,28),
                        Position=UDim2.new(0,SPACING.MD,0,hexY),
                        Color=COLORS.Surface,Trans=0.25,
                        ZIndex=16,Parent=picker,
                    })
                    ApplyCorner(hbg,CORNERS.SM)
                    local hbox=Instance.new("TextBox")
                    hbox.PlaceholderText="#RRGGBB"
                    hbox.Text=hexStr(curCol)
                    hbox.Font=FONTS.Code; hbox.TextSize=12
                    hbox.TextColor3=COLORS.TextPrimary
                    hbox.PlaceholderColor3=COLORS.TextMuted
                    hbox.BackgroundTransparency=1
                    hbox.Size=UDim2.new(1,-8,1,0)
                    hbox.Position=UDim2.new(0,4,0,0)
                    hbox.ZIndex=17; hbox.ClearTextOnFocus=false
                    hbox.Parent=hbg
                    hbox.FocusLost:Connect(function()
                        local h=hbox.Text:gsub("#","")
                        if #h==6 then
                            local r2=tonumber(h:sub(1,2),16)or 0
                            local g2=tonumber(h:sub(3,4),16)or 0
                            local b2=tonumber(h:sub(5,6),16)or 0
                            updateColor(Color3.fromRGB(r2,g2,b2))
                        end
                    end)
                end

                -- Hue drag
                local hueDrag=false
                hueBar.InputBegan:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=true end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=false end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if not hueDrag then return end
                    if inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
                    local ap=hueBar.AbsolutePosition; local aw=hueBar.AbsoluteSize.X
                    local pct=math.clamp((inp.Position.X-ap.X)/aw,0,1)
                    Tween(hThumb,{Position=UDim2.new(pct,math.floor(-7+pct*aw*0),0,-2)},0.05)
                    -- approximate hue -> color
                    local h=pct*360
                    local c2=Color3.fromHSV(h/360,1,1)
                    hueColor=c2
                    sbBox.BackgroundColor3=c2
                    updateColor(c2)
                end)
            end)

            updateColor(def,true)
            return {
                SetValue=function(v) updateColor(v,true) end,
                GetValue=function() return curCol end,
            }
        end

        -- ---- PROGRESS ----
        function TabAPI:CreateProgress(c)
            local c      = c or {}
            local name   = c.Name or "Progress"
            local prog   = c.Progress or 0
            local indet  = c.Indeterminate or false
            local showPct= c.ShowPercentage ~= false
            local col    = c.Color or COLORS.Accent
            local o      = O()

            local rowH   = 54
            local row    = BaseRow(tabContent, rowH, o, 4)

            MakeLabel({
                Text=name,Font=FONTS.Subtitle,Size=13,
                Color=COLORS.TextPrimary,
                FrameSize=UDim2.new(1,-70,0,18),
                Position=UDim2.new(0,SPACING.LG,0,8),
                ZIndex=5,Parent=row,
            })
            local pctLbl=nil
            if showPct then
                pctLbl=MakeLabel({
                    Text=math.floor(prog*100).."%",
                    Font=FONTS.Code,Size=12,
                    Color=COLORS.Accent,
                    FrameSize=UDim2.new(0,46,0,18),
                    Position=UDim2.new(1,-(46+SPACING.MD),0,8),
                    AlignX=Enum.TextXAlignment.Right,
                    ZIndex=5,Parent=row,
                })
            end

            local trk=MakeFrame({
                Size=UDim2.new(1,-(SPACING.LG*2),0,7),
                Position=UDim2.new(0,SPACING.LG,0,34),
                Color=Color3.fromRGB(218,218,223),Trans=0.1,
                ZIndex=5,Parent=row,
            })
            ApplyCorner(trk,CORNERS.FULL)
            local fill=MakeFrame({
                Size=UDim2.new(prog,0,1,0),
                Color=col,Trans=0,
                ZIndex=6,Parent=trk,
            })
            ApplyCorner(fill,CORNERS.FULL)
            local fg=Instance.new("UIGradient")
            fg.Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,col),
                ColorSequenceKeypoint.new(1,Color3.new(math.min(1,col.R+0.18),math.min(1,col.G+0.18),math.min(1,col.B+0.28))),
            })
            fg.Parent=fill

            local indConn=nil
            if indet then
                local t=0
                indConn=RunService.Heartbeat:Connect(function(dt)
                    t=t+dt
                    local p=(math.sin(t*2)+1)/2
                    fill.Size=UDim2.new(0.38,0,1,0)
                    fill.Position=UDim2.new(p*0.62,0,0,0)
                end)
            end

            local function setP(v)
                prog=math.clamp(v,0,1)
                Tween(fill,{Size=UDim2.new(prog,0,1,0)},DURATION.Normal)
                if pctLbl then pctLbl.Text=math.floor(prog*100).."%" end
            end

            return {
                SetProgress=setP,
                GetProgress=function() return prog end,
                Destroy=function()
                    if indConn then indConn:Disconnect() end
                    pcall(function() row:Destroy() end)
                end,
            }
        end

        -- ---- CARD ----
        function TabAPI:CreateCard(c)
            local c       = c or {}
            local title   = c.Title or ""
            local desc    = c.Description or ""
            local icon    = c.Icon or ""
            local coll    = c.Collapsible or false
            local expd    = c.DefaultExpanded ~= false
            local pad     = c.Padding or SPACING.MD
            local o       = O()

            local card = MakeFrame({
                Name  = "Card_"..title,
                Size  = UDim2.new(1,0,0,0),
                Color = COLORS.White, Trans = ROW_TRANS,
                ZIndex = 4, Parent = tabContent,
            })
            card.AutomaticSize = Enum.AutomaticSize.Y
            card.LayoutOrder   = o
            ApplyCorner(card,CORNERS.MD)
            ApplyStroke(card,COLORS.GlassBorder,1,0.55)

            local hdrH = (title~=""or icon~="") and 40 or 0
            if hdrH>0 then
                local hdr=MakeFrame({
                    Size=UDim2.new(1,0,0,hdrH),
                    Color=COLORS.SidebarBg,Trans=0.35,
                    ZIndex=5,Parent=card,
                })
                ApplyCorner(hdr,CORNERS.MD)
                if icon~="" then
                    MakeImage({Image=icon,Color=COLORS.Accent,Size=UDim2.new(0,16,0,16),
                        Position=UDim2.new(0,SPACING.MD,0.5,-8),ZIndex=6,Parent=hdr})
                end
                local hx=icon~=""and(SPACING.MD+22)or SPACING.MD
                MakeLabel({
                    Text=title,Font=FONTS.Title,Size=13,
                    Color=COLORS.TextPrimary,
                    FrameSize=UDim2.new(1,-60,0,18),
                    Position=UDim2.new(0,hx,0,desc~=""and 4 or(hdrH/2-9)),
                    ZIndex=6,Parent=hdr,
                })
                if desc~="" then
                    MakeLabel({Text=desc,Font=FONTS.Caption,Size=11,Color=COLORS.TextMuted,
                        FrameSize=UDim2.new(1,-60,0,13),Position=UDim2.new(0,hx,0,22),
                        ZIndex=6,Parent=hdr})
                end
                if coll then
                    local chv=MakeButton({
                        Text=expd and"▴"or"▾",TextSize=11,TextColor=COLORS.TextMuted,
                        Color=COLORS.Black,Trans=1,
                        Size=UDim2.new(0,28,1,0),
                        Position=UDim2.new(1,-32,0,0),
                        ZIndex=7,Parent=hdr,
                    })
                    chv.MouseButton1Click:Connect(function()
                        expd=not expd; chv.Text=expd and"▴"or"▾"
                    end)
                end
            end

            local body=MakeFrame({
                Size=UDim2.new(1,0,0,0),
                Position=UDim2.new(0,0,0,hdrH),
                Color=COLORS.Black,Trans=1,
                ZIndex=5,Parent=card,
            })
            body.AutomaticSize=Enum.AutomaticSize.Y
            body.Visible=expd

            local bl=Instance.new("UIListLayout")
            bl.SortOrder=Enum.SortOrder.LayoutOrder
            bl.Padding=UDim.new(0,SPACING.SM)
            bl.Parent=body
            local bp=Instance.new("UIPadding")
            bp.PaddingAll=UDim.new(0,pad)
            bp.Parent=body

            local CardAPI={}
            local _co=0
            function CardAPI:AddLabel(text,size,color,font)
                _co=_co+10
                local l=MakeLabel({
                    Text=text or "",Font=font or FONTS.Body,Size=size or 13,
                    Color=color or COLORS.TextPrimary,
                    FrameSize=UDim2.new(1,0,0,20),
                    ZIndex=6,Parent=body,
                })
                l.LayoutOrder=_co
                return l
            end
            function CardAPI:GetBody() return body end
            return CardAPI
        end

        -- ---- AVATAR ----
        function TabAPI:CreateAvatar(c)
            local c      = c or {}
            local uid    = c.UserId or LocalPlayer.UserId
            local avSz   = c.Size or 72
            local showSt = c.ShowStatus or false
            local stCol  = c.StatusColor or COLORS.Success
            local click  = c.Clickable ~= false
            local o      = O()

            local rowH   = avSz + SPACING.XXL
            local row    = BaseRow(tabContent, rowH, o, 4)
            row.AutomaticSize = Enum.AutomaticSize.None

            local avF = MakeFrame({
                Size=UDim2.new(0,avSz,0,avSz),
                Position=UDim2.new(0.5,-avSz/2,0.5,-avSz/2),
                Color=COLORS.White,Trans=0.05,
                ZIndex=5,Parent=row,
            })
            ApplyCorner(avF,CORNERS.FULL)
            ApplyStroke(avF,COLORS.White,2.5,0.1)
            ApplyShadow(avF,4,0.65)

            local ai=MakeImage({
                Image="rbxthumb://type=AvatarHeadShot&id="..uid.."&w=150&h=150",
                Color=COLORS.White,
                Size=UDim2.new(1,0,1,0),
                Position=UDim2.new(0,0,0,0),
                ZIndex=6,Parent=avF,
            })
            ApplyCorner(ai,CORNERS.FULL)

            if showSt then
                local dot=MakeFrame({
                    Size=UDim2.new(0,12,0,12),
                    Position=UDim2.new(1,-12,1,-12),
                    Color=stCol,Trans=0,ZIndex=7,Parent=avF,
                })
                ApplyCorner(dot,CORNERS.FULL)
                ApplyStroke(dot,COLORS.White,2,0)
            end

            if click then
                local cz=MakeButton({
                    Text="",Color=COLORS.Black,Trans=1,
                    Size=UDim2.new(1,0,1,0),ZIndex=8,Parent=avF,
                })
                cz.MouseButton1Click:Connect(function()
                    Nexuralib:ShowModal({
                        Title="Avatar",
                        PrimaryAction={Text="Close"},
                    })
                end)
            end

            return {
                SetUserId=function(id)
                    ai.Image="rbxthumb://type=AvatarHeadShot&id="..id.."&w=150&h=150"
                end,
            }
        end

        -- ---- SEPARATOR ----
        function TabAPI:AddSeparator(label)
            local o=O()
            if label then
                local sep=MakeFrame({
                    Name="Sep",Size=UDim2.new(1,0,0,24),
                    Color=COLORS.Black,Trans=1,
                    ZIndex=4,Parent=tabContent,
                })
                sep.LayoutOrder=o
                MakeLabel({
                    Text=label,Font=FONTS.Caption,Size=11,
                    Color=COLORS.TextMuted,
                    FrameSize=UDim2.new(1,0,1,0),
                    AlignX=Enum.TextXAlignment.Center,
                    ZIndex=5,Parent=sep,
                })
                for _,xoff in ipairs({0, 0.55}) do
                    MakeFrame({
                        Size=UDim2.new(0.42,0,0,1),
                        Position=UDim2.new(xoff,0,0.5,0),
                        Color=COLORS.GlassBorder,Trans=0.6,
                        ZIndex=4,Parent=sep,
                    })
                end
            else
                local sep=MakeFrame({
                    Name="Sep",Size=UDim2.new(1,-(SPACING.XXL),0,1),
                    Position=UDim2.new(0,SPACING.MD,0,0),
                    Color=COLORS.GlassBorder,Trans=0.6,
                    ZIndex=4,Parent=tabContent,
                })
                sep.LayoutOrder=o
            end
        end

        return TabAPI
    end

    -- WindowAPI helpers
    function WindowAPI:Notify(c)   return Nexuralib:Notify(c) end
    function WindowAPI:ShowModal(c) return Nexuralib:ShowModal(c) end
    function WindowAPI:Destroy()
        Tween(Container,{BackgroundTransparency=1},DURATION.Normal)
        task.delay(DURATION.Normal,function() pcall(function() sg:Destroy() end) end)
    end
    function WindowAPI:SetTitle(t)
        for _,ch in ipairs(Header:GetChildren()) do
            if ch:IsA("TextLabel") and ch.Font==FONTS.Display then ch.Text=t end
        end
    end

    return WindowAPI
end

return Nexuralib

--[[
=============================================================
  NEXURALIB v2 - USAGE EXAMPLE
=============================================================

local Nexuralib = loadstring(game:HttpGet("URL"))()

local Window = Nexuralib:CreateWindow({
    Title          = "My Script",
    Subtitle       = "v2.0",
    ShowUserAvatar = true,
    Draggable      = true,
    AnimateOpen    = true,
})

local Main = Window:CreateTab({ Name="Main", Icon="rbxassetid://7733715400" })

Main:CreateToggle({
    Name="Auto Farm", Icon="rbxassetid://7733715400",
    Description="Enable auto farming",
    Default=false, Flag="AutoFarm",
    Callback=function(v) print("AutoFarm:", v) end
})
Main:CreateButton({
    Name="Teleport", Icon="rbxassetid://7733960981",
    Variant="primary",
    Callback=function() print("TP!") end
})
Main:CreateSlider({
    Name="Speed", Icon="rbxassetid://7733658504",
    Min=16, Max=100, Default=16, Increment=1,
    Flag="Speed",
    Callback=function(v)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed=v
    end
})
Main:CreateDropdown({
    Name="Mode", Icon="rbxassetid://7734014475",
    Options={"Safe","Fast","Stealth"},
    Default="Safe", Flag="Mode",
    Callback=function(v) print(v) end
})
Main:CreateInput({
    Name="Target", Icon="rbxassetid://7733715400",
    Placeholder="Player name...",
    Flag="Target",
    Callback=function(v) print(v) end
})
Main:CreateKeybind({
    Name="Toggle GUI", Icon="rbxassetid://7733960981",
    Default=Enum.KeyCode.RightShift, Flag="GuiKey",
    Callback=function(v) print(v) end
})

Nexuralib:Notify({
    Title="Loaded!", Content="Nexuralib v2 ready.",
    Type="success", Duration=4,
})

print(Nexuralib.Flags["AutoFarm"])
=============================================================
]]
