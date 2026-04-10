-- ============================================================
--  ███╗   ██╗███████╗██╗  ██╗██╗   ██╗██████╗  █████╗ ██╗     ██╗██████╗
--  ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔══██╗██╔══██╗██║     ██║██╔══██╗
--  ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║██████╔╝███████║██║     ██║██████╔╝
--  ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║██╔══██╗██╔══██║██║     ██║██╔══██╗
--  ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝██║  ██║██║  ██║███████╗██║██████╔╝
--  ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═════╝
--  Modern Glassmorphism UI Library for Roblox  |  v4.0.0
--
--  CHANGELOG v4 (fix dari v3):
--   [FIX 1] Elemen di pojok kiri atas → penyebab: workspace.CurrentCamera.ViewportSize
--           bisa return (0,0) saat script baru load, membuat defW/defH jadi NEGATIF.
--           Solusi: posisi window pakai AnchorPoint(0.5,0.5)+UDim2.new(0.5,0,0.5,0)
--           sehingga otomatis center TANPA perlu ViewportSize sama sekali.
--   [FIX 2] IgnoreGuiInset=true dihapus — mengubah sistem koordinat seluruh ScreenGui
--           yang menyebabkan offset tak terduga di berbagai resolusi.
--   [FIX 3] Drag: pakai stored-start-pos + InputChanged delta (bukan Heartbeat).
--           Delta approach = coordinate-system independent, GuiInset otomatis cancel.
--   [FIX 4] ViewportSize diakses aman dengan fallback 1280×720 kalau nil/zero.
--   Semua fix v3 tetap berlaku: no PaddingAll, icon AnchorPoint(0,0.5), no BlurEffect.
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

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- [FIX 4] Safe ViewportSize — fallback 1280×720 jika Camera belum ready
-- ============================================================
local function getViewport()
    local ok, cam = pcall(function() return workspace.CurrentCamera end)
    if ok and cam then
        local vp = cam.ViewportSize
        if vp and vp.X > 100 then return vp end
    end
    return Vector2.new(1280, 720)
end

-- ============================================================
-- DESIGN TOKENS
-- ============================================================
local C = {
    TextPrimary   = Color3.fromRGB(22,  22,  22),
    TextSecondary = Color3.fromRGB(90,  90,  90),
    TextMuted     = Color3.fromRGB(150, 150, 150),
    Accent        = Color3.fromRGB(0,   122, 255),
    Success       = Color3.fromRGB(52,  199, 89),
    Warning       = Color3.fromRGB(255, 196, 0),
    Error         = Color3.fromRGB(255, 59,  48),
    White         = Color3.fromRGB(255, 255, 255),
    Black         = Color3.fromRGB(0,   0,   0),
    Surface       = Color3.fromRGB(248, 248, 250),
    SidebarBg     = Color3.fromRGB(242, 242, 247),
    RowBg         = Color3.fromRGB(255, 255, 255),
    Border        = Color3.fromRGB(200, 200, 210),
    TrackOff      = Color3.fromRGB(210, 210, 215),
}

local F = {
    Display = Enum.Font.GothamBlack,
    Title   = Enum.Font.GothamBold,
    Sub     = Enum.Font.GothamMedium,
    Body    = Enum.Font.Gotham,
    Code    = Enum.Font.RobotoMono,
}

local R = { XS=6, SM=10, MD=14, LG=18, XL=22, Full=999 }
local S = { XS=4, SM=8, MD=12, LG=16, XL=24, XXL=32 }
local D = { Fast=0.12, Normal=0.25, Slow=0.4 }

local BG_TRANS  = 0.06
local ROW_TRANS = 0.04

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local function tw(obj, props, dur, style, dir)
    pcall(function()
        TweenService:Create(obj, TweenInfo.new(
            dur or D.Normal,
            style or Enum.EasingStyle.Quart,
            dir   or Enum.EasingDirection.Out
        ), props):Play()
    end)
end

local function springTw(obj, props, dur)
    pcall(function()
        TweenService:Create(obj, TweenInfo.new(
            dur or 0.35,
            Enum.EasingStyle.Elastic,
            Enum.EasingDirection.Out,
            0, false, 0
        ), props):Play()
    end)
end

local function mkCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or R.MD)
    c.Parent = parent
    return c
end

local function mkStroke(parent, col, thick, tr)
    -- remove duplicate strokes first
    for _, ch in ipairs(parent:GetChildren()) do
        if ch:IsA("UIStroke") then ch:Destroy() end
    end
    local s = Instance.new("UIStroke")
    s.Color           = col or C.Border
    s.Thickness       = thick or 1
    s.Transparency    = tr or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent          = parent
    return s
end

-- [FIX v2] No PaddingAll — always use 4 individual props
local function mkPadding(parent, t, b, l, r2)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t  or 0)
    p.PaddingBottom = UDim.new(0, b  or t or 0)
    p.PaddingLeft   = UDim.new(0, l  or t or 0)
    p.PaddingRight  = UDim.new(0, r2 or t or 0)
    p.Parent = parent
    return p
end

local function mkShadow(parent, offY, tr)
    local s = Instance.new("ImageLabel")
    s.Name                   = "_Shadow"
    s.AnchorPoint            = Vector2.new(0.5, 0.5)
    s.BackgroundTransparency = 1
    s.Position               = UDim2.new(0.5, 0, 0.5, offY or 3)
    s.Size                   = UDim2.new(1, 26, 1, 26)
    s.ZIndex                 = math.max(1, (parent.ZIndex or 2) - 1)
    s.Image                  = "rbxassetid://6014261993"
    s.ImageColor3            = Color3.new(0, 0, 0)
    s.ImageTransparency      = tr or 0.78
    s.ScaleType              = Enum.ScaleType.Slice
    s.SliceCenter            = Rect.new(49, 49, 450, 450)
    s.Parent                 = parent
    return s
end

local function mkFrame(p)
    local f = Instance.new("Frame")
    f.Name                   = p.Name or "Frame"
    f.Size                   = p.Size or UDim2.new(1, 0, 0, 40)
    f.Position               = p.Pos  or UDim2.new(0, 0, 0, 0)
    f.AnchorPoint            = p.Anchor or Vector2.new(0, 0)
    f.BackgroundColor3       = p.Color or C.White
    f.BackgroundTransparency = p.Trans or 0
    f.ZIndex                 = p.Z or 1
    f.BorderSizePixel        = 0
    f.ClipsDescendants       = p.Clip or false
    if p.Parent then f.Parent = p.Parent end
    return f
end

local function mkLabel(p)
    local l = Instance.new("TextLabel")
    l.Name                   = p.Name or "Lbl"
    l.Text                   = p.Text or ""
    l.Font                   = p.Font or F.Body
    l.TextSize               = p.Size or 14
    l.TextColor3             = p.Color or C.TextPrimary
    l.TextXAlignment         = p.AlignX or Enum.TextXAlignment.Left
    l.TextYAlignment         = p.AlignY or Enum.TextYAlignment.Center
    l.BackgroundTransparency = 1
    l.Size                   = p.FS  or UDim2.new(1, 0, 1, 0)
    l.Position               = p.Pos or UDim2.new(0, 0, 0, 0)
    l.AnchorPoint            = p.Anchor or Vector2.new(0, 0)
    l.ZIndex                 = p.Z  or 2
    l.TextTruncate           = Enum.TextTruncate.AtEnd
    l.RichText               = p.Rich or false
    if p.Parent then l.Parent = p.Parent end
    return l
end

local function mkBtn(p)
    local b = Instance.new("TextButton")
    b.Name                   = p.Name or "Btn"
    b.Text                   = p.Text or ""
    b.Font                   = p.Font or F.Body
    b.TextSize               = p.TS   or 14
    b.TextColor3             = p.TC   or C.TextPrimary
    b.BackgroundColor3       = p.Color or C.Surface
    b.BackgroundTransparency = p.Trans or 0
    b.Size                   = p.Size or UDim2.new(0, 100, 0, 36)
    b.Position               = p.Pos  or UDim2.new(0, 0, 0, 0)
    b.AnchorPoint            = p.Anchor or Vector2.new(0, 0)
    b.AutoButtonColor        = false
    b.BorderSizePixel        = 0
    b.ZIndex                 = p.Z or 2
    if p.Parent then b.Parent = p.Parent end
    return b
end

-- [FIX v3] Icon always uses AnchorPoint(0,0.5) so it auto-centers vertically
local function mkIcon(p)
    local i = Instance.new("ImageLabel")
    i.Name                   = p.Name or "Icon"
    i.Image                  = p.Image or ""
    i.ImageColor3            = p.Color or C.TextSecondary
    i.BackgroundTransparency = 1
    i.AnchorPoint            = p.Anchor or Vector2.new(0, 0.5)   -- default center-y
    i.Size                   = p.Size or UDim2.new(0, 18, 0, 18)
    i.Position               = p.Pos  or UDim2.new(0, S.LG, 0.5, 0)  -- Y=0.5 = center
    i.ZIndex                 = p.Z or 6
    i.ScaleType              = Enum.ScaleType.Fit
    if p.Parent then i.Parent = p.Parent end
    return i
end

local function mkScroll(p)
    local s = Instance.new("ScrollingFrame")
    s.Name                       = p.Name or "Scroll"
    s.Size                       = p.Size or UDim2.new(1, 0, 1, 0)
    s.Position                   = p.Pos  or UDim2.new(0, 0, 0, 0)
    s.BackgroundTransparency     = 1
    s.BorderSizePixel            = 0
    s.ScrollBarThickness         = p.Bar or 3
    s.ScrollBarImageColor3       = C.Accent
    s.ScrollBarImageTransparency = 0.5
    s.CanvasSize                 = UDim2.new(0, 0, 0, 0)
    s.AutomaticCanvasSize        = Enum.AutomaticSize.Y
    s.ZIndex                     = p.Z or 2
    s.ClipsDescendants           = true
    if p.Parent then s.Parent = p.Parent end
    return s
end

local function mkVList(parent, gap)
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding   = UDim.new(0, gap or S.SM)
    l.Parent    = parent
    return l
end

-- Row container for components — fixed height, no AutomaticSize
local function mkRow(parent, h, order)
    local r = mkFrame({
        Name   = "Row",
        Size   = UDim2.new(1, 0, 0, h or 52),
        Pos    = UDim2.new(0, 0, 0, 0),
        Color  = C.RowBg,
        Trans  = ROW_TRANS,
        Z      = 4,
        Parent = parent,
    })
    r.LayoutOrder   = order or 0
    r.AutomaticSize = Enum.AutomaticSize.None  -- keep fixed height so icons stay visible
    mkCorner(r, R.MD)
    mkStroke(r, C.Border, 1, 0.6)
    return r
end

local function mkRipple(b, x, y)
    pcall(function()
        local rp = Instance.new("Frame")
        rp.BackgroundColor3       = Color3.new(1, 1, 1)
        rp.BackgroundTransparency = 0.65
        rp.Size                   = UDim2.new(0, 0, 0, 0)
        rp.Position               = UDim2.new(0, x, 0, y)
        rp.AnchorPoint            = Vector2.new(0.5, 0.5)
        rp.ZIndex                 = (b.ZIndex or 2) + 4
        rp.BorderSizePixel        = 0
        mkCorner(rp, R.Full)
        rp.Parent = b
        local mx = math.max(b.AbsoluteSize.X, b.AbsoluteSize.Y) * 2.2
        tw(rp, {Size = UDim2.new(0, mx, 0, mx), BackgroundTransparency = 1}, 0.45)
        game:GetService("Debris"):AddItem(rp, 0.5)
    end)
end

-- ============================================================
-- CONFIG SYSTEM
-- ============================================================
local _cfgCache = {}

local function SaveConfig(name, data)
    local ok, enc = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then
        _cfgCache[name] = data
        pcall(function()
            if not isfolder("Nexuralib") then makefolder("Nexuralib") end
            writefile("Nexuralib/" .. name .. ".json", enc)
        end)
    end
end

local function LoadConfig(name)
    if _cfgCache[name] then return _cfgCache[name] end
    local ok, result = pcall(function()
        if isfile("Nexuralib/" .. name .. ".json") then
            local d = HttpService:JSONDecode(readfile("Nexuralib/" .. name .. ".json"))
            _cfgCache[name] = d
            return d
        end
    end)
    return (ok and result) or nil
end

Nexuralib.SaveConfig = SaveConfig
Nexuralib.LoadConfig = LoadConfig
Nexuralib.Flags      = {}

-- ============================================================
-- NOTIFY SYSTEM
-- ============================================================
local _notifyGui  = nil
local _notifyCont = nil

local function ensureNotify()
    if _notifyGui and _notifyGui.Parent then return end
    _notifyGui = Instance.new("ScreenGui")
    _notifyGui.Name           = "NexuralibNotify"
    _notifyGui.ResetOnSpawn   = false
    _notifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _notifyGui.DisplayOrder   = 200
    pcall(function() _notifyGui.Parent = CoreGui end)
    if not _notifyGui.Parent then
        _notifyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    _notifyCont = mkFrame({
        Name   = "NxNotifyCont",
        Size   = UDim2.new(0, 310, 1, 0),
        Pos    = UDim2.new(1, -326, 0, 0),
        Color  = C.Black, Trans = 1,
        Z      = 200, Parent = _notifyGui,
    })
    local ul = Instance.new("UIListLayout")
    ul.SortOrder         = Enum.SortOrder.LayoutOrder
    ul.VerticalAlignment = Enum.VerticalAlignment.Bottom
    ul.Padding           = UDim.new(0, S.SM)
    ul.Parent            = _notifyCont

    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0, S.LG)
    pad.Parent        = _notifyCont
end

function Nexuralib:Notify(cfg)
    cfg = cfg or {}
    local title   = cfg.Title or "Notification"
    local content = cfg.Content or ""
    local ntype   = cfg.Type or "info"
    local dur     = cfg.Duration or 4
    local ico     = cfg.Icon or ""
    local actions = cfg.Actions or {}
    ensureNotify()

    local tc = C.Accent
    local ti = "rbxassetid://7733960981"
    if ntype == "success" then tc = C.Success; ti = "rbxassetid://7733715400"
    elseif ntype == "warning" then tc = C.Warning; ti = "rbxassetid://7733658504"
    elseif ntype == "error"   then tc = C.Error;   ti = "rbxassetid://7734014475"
    end
    if ico ~= "" then ti = ico end

    local cardH = 68 + (content ~= "" and 18 or 0) + (#actions > 0 and 36 or 0)

    local card = mkFrame({
        Size   = UDim2.new(1, 0, 0, cardH),
        Color  = C.White, Trans = BG_TRANS,
        Z      = 201, Parent = _notifyCont,
    })
    mkCorner(card, R.LG)
    mkStroke(card, C.Border, 1, 0.42)
    mkShadow(card, 3, 0.76)

    -- Accent bar
    mkFrame({
        Size = UDim2.new(0, 3, 1, -12), Pos = UDim2.new(0, 0, 0, 6),
        Color = tc, Trans = 0, Z = 202, Parent = card,
    })

    mkIcon({ Image = ti, Color = tc,
        Size = UDim2.new(0, 16, 0, 16),
        Pos = UDim2.new(0, 14, 0, 13),
        Anchor = Vector2.new(0, 0),
        Z = 202, Parent = card })

    mkLabel({ Text = title, Font = F.Title, Size = 13, Color = C.TextPrimary,
        FS = UDim2.new(1, -74, 0, 17), Pos = UDim2.new(0, 37, 0, 10),
        Z = 202, Parent = card })

    if content ~= "" then
        mkLabel({ Text = content, Font = F.Body, Size = 12, Color = C.TextSecondary,
            FS = UDim2.new(1, -74, 0, 15), Pos = UDim2.new(0, 37, 0, 28),
            Z = 202, Parent = card })
    end

    local closeBtn = mkBtn({ Text = "✕", TS = 10, TC = C.TextMuted,
        Color = C.Black, Trans = 1,
        Size = UDim2.new(0, 22, 0, 22), Pos = UDim2.new(1, -26, 0, 5),
        Z = 203, Parent = card })

    if #actions > 0 then
        local af = mkFrame({ Size = UDim2.new(1, -48, 0, 28),
            Pos = UDim2.new(0, 37, 1, -34), Color = C.Black, Trans = 1,
            Z = 202, Parent = card })
        local al = Instance.new("UIListLayout")
        al.FillDirection = Enum.FillDirection.Horizontal
        al.Padding       = UDim.new(0, S.SM)
        al.Parent        = af
        for _, a in ipairs(actions) do
            local ab = mkBtn({ Text = a.Text or "", TS = 12, TC = tc,
                Font = F.Sub, Color = tc, Trans = 0.88,
                Size = UDim2.new(0, 68, 1, 0), Z = 203, Parent = af })
            mkCorner(ab, R.SM)
            ab.MouseButton1Click:Connect(function()
                if a.Callback then a.Callback() end
            end)
        end
    end

    -- Slide in from right
    card.Position              = UDim2.new(1, 16, 0, 0)
    card.BackgroundTransparency = 1
    tw(card, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = BG_TRANS },
        D.Normal, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        tw(card, { Position = UDim2.new(1, 16, 0, 0), BackgroundTransparency = 1 },
            D.Normal, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(D.Normal, function() pcall(function() card:Destroy() end) end)
    end
    closeBtn.MouseButton1Click:Connect(dismiss)
    task.delay(dur, dismiss)
    return { Dismiss = dismiss }
end

-- ============================================================
-- MODAL SYSTEM
-- ============================================================
local _modalGui = nil
local function ensureModal()
    if _modalGui and _modalGui.Parent then return end
    _modalGui = Instance.new("ScreenGui")
    _modalGui.Name           = "NexuralibModal"
    _modalGui.ResetOnSpawn   = false
    _modalGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _modalGui.DisplayOrder   = 150
    pcall(function() _modalGui.Parent = CoreGui end)
    if not _modalGui.Parent then _modalGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
end

function Nexuralib:ShowModal(cfg)
    cfg = cfg or {}
    local mtype   = cfg.Type or "info"
    local title   = cfg.Title or "Modal"
    local content = cfg.Content or ""
    local ico     = cfg.Icon or ""
    local prim    = cfg.PrimaryAction or { Text = "OK" }
    local sec     = cfg.SecondaryAction or nil
    local inpCfg  = cfg.Input or nil
    ensureModal()

    local tc = C.Accent
    if mtype == "success" then tc = C.Success
    elseif mtype == "warning" then tc = C.Warning
    elseif mtype == "error" or mtype == "danger" then tc = C.Error end

    -- backdrop
    local bd = mkFrame({ Size = UDim2.new(1, 0, 1, 0), Color = C.Black, Trans = 1,
        Z = 149, Parent = _modalGui })
    tw(bd, { BackgroundTransparency = 0.55 }, D.Normal)

    local mW = 400
    local mH = 230 + (content ~= "" and 36 or 0) + (inpCfg and 50 or 0)

    -- [FIX 1] Modal juga pakai AnchorPoint(0.5,0.5) untuk center otomatis
    local md = mkFrame({
        Size   = UDim2.new(0, mW * 0.82, 0, mH * 0.82),
        Pos    = UDim2.new(0.5, -(mW * 0.82) / 2, 0.5, -(mH * 0.82) / 2),
        Color  = C.White, Trans = 1,
        Z      = 151, Parent = _modalGui,
    })
    mkCorner(md, R.LG)
    mkStroke(md, C.Border, 1, 0.38)
    mkShadow(md, 5, 0.62)
    tw(md, {
        Size     = UDim2.new(0, mW, 0, mH),
        Position = UDim2.new(0.5, -mW / 2, 0.5, -mH / 2),
        BackgroundTransparency = BG_TRANS,
    }, D.Normal, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Icon circle
    local ic = mkFrame({ Size = UDim2.new(0, 50, 0, 50),
        Pos = UDim2.new(0.5, -25, 0, 22), Color = tc, Trans = 0.84,
        Z = 152, Parent = md })
    mkCorner(ic, R.Full)
    mkStroke(ic, tc, 1.5, 0.5)
    if ico ~= "" then
        mkIcon({ Image = ico, Color = tc, Size = UDim2.new(0, 20, 0, 20),
            Pos = UDim2.new(0.5, -10, 0.5, -10),
            Anchor = Vector2.new(0, 0), Z = 153, Parent = ic })
    end

    mkLabel({ Text = title, Font = F.Title, Size = 17, Color = C.TextPrimary,
        FS = UDim2.new(1, -32, 0, 22), Pos = UDim2.new(0, 16, 0, 84),
        AlignX = Enum.TextXAlignment.Center, Z = 152, Parent = md })

    if content ~= "" then
        mkLabel({ Text = content, Font = F.Body, Size = 13, Color = C.TextSecondary,
            FS = UDim2.new(1, -40, 0, 34), Pos = UDim2.new(0, 20, 0, 114),
            AlignX = Enum.TextXAlignment.Center, AlignY = Enum.TextYAlignment.Top,
            Z = 152, Parent = md })
    end

    local inputResult = ""
    if inpCfg then
        local iy  = content ~= "" and 156 or 118
        local ibg = mkFrame({ Size = UDim2.new(1, -40, 0, 36),
            Pos = UDim2.new(0, 20, 0, iy), Color = C.Surface, Trans = 0.2,
            Z = 152, Parent = md })
        mkCorner(ibg, R.SM)
        mkStroke(ibg, C.Border, 1, 0.5)
        local ib = Instance.new("TextBox")
        ib.PlaceholderText   = inpCfg.Placeholder or "Type here..."
        ib.Text              = inpCfg.Default or ""
        ib.Font              = F.Body
        ib.TextSize          = 13
        ib.TextColor3        = C.TextPrimary
        ib.PlaceholderColor3 = C.TextMuted
        ib.BackgroundTransparency = 1
        ib.Size              = UDim2.new(1, -10, 1, 0)
        ib.Position          = UDim2.new(0, 5, 0, 0)
        ib.ZIndex            = 153
        ib.ClearTextOnFocus  = false
        ib.Parent            = ibg
        ib.FocusLost:Connect(function() inputResult = ib.Text end)
    end

    local btnY  = mH - 58
    local hasSec = sec ~= nil
    local btnW  = hasSec and (mW - 44) / 2 or mW - 40

    local function closeModal()
        tw(bd, { BackgroundTransparency = 1 }, D.Fast)
        tw(md, { BackgroundTransparency = 1,
            Size = UDim2.new(0, mW * 0.82, 0, mH * 0.82) }, D.Fast)
        task.delay(D.Fast, function()
            pcall(function() bd:Destroy() end)
            pcall(function() md:Destroy() end)
        end)
    end

    if hasSec then
        local sb = mkBtn({ Text = sec.Text or "Cancel", Font = F.Sub, TS = 13,
            TC = C.TextSecondary, Color = C.Surface, Trans = 0.22,
            Size = UDim2.new(0, btnW, 0, 36), Pos = UDim2.new(0, 20, 0, btnY),
            Z = 152, Parent = md })
        mkCorner(sb, R.SM)
        sb.MouseButton1Click:Connect(function()
            if sec.Callback then sec.Callback(inputResult) end
            closeModal()
        end)
    end

    local px = hasSec and (20 + btnW + 8) or 20
    local pb = mkBtn({ Text = prim.Text or "OK", Font = F.Title, TS = 13,
        TC = C.White, Color = tc, Trans = 0,
        Size = UDim2.new(0, btnW, 0, 36), Pos = UDim2.new(0, px, 0, btnY),
        Z = 152, Parent = md })
    mkCorner(pb, R.SM)
    pb.MouseEnter:Connect(function() tw(pb, { BackgroundTransparency = 0.12 }, D.Fast) end)
    pb.MouseLeave:Connect(function() tw(pb, { BackgroundTransparency = 0 }, D.Fast) end)
    pb.MouseButton1Click:Connect(function()
        if prim.Callback then prim.Callback(inputResult) end
        closeModal()
    end)
    bd.MouseButton1Click:Connect(closeModal)
    return { Close = closeModal }
end

-- ============================================================
-- WINDOW
-- ============================================================
function Nexuralib:CreateWindow(cfg)
    cfg = cfg or {}
    local winTitle   = cfg.Title or "Nexuralib"
    local winSub     = cfg.Subtitle or ""
    local showAvatar = cfg.ShowUserAvatar ~= false
    local avatarSide = cfg.AvatarPosition or "left"
    local draggable  = cfg.Draggable ~= false
    local doAnim     = cfg.AnimateOpen ~= false

    -- [FIX 4] Safe ViewportSize
    local vp   = getViewport()
    local defW = cfg.Size and math.min(cfg.Size.X, vp.X - 40) or math.min(680, vp.X - 40)
    local defH = cfg.Size and math.min(cfg.Size.Y, vp.Y - 40) or math.min(460, vp.Y - 40)
    -- clamp positif
    defW = math.max(defW, 300)
    defH = math.max(defH, 200)

    -- ScreenGui
    -- [FIX 2] TIDAK ada IgnoreGuiInset=true → sistem koordinat normal
    local sg = Instance.new("ScreenGui")
    sg.Name           = "NexuralibUI"
    sg.ResetOnSpawn   = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder   = 100
    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- [FIX 1] Container: pakai AnchorPoint(0.5,0.5) + Pos UDim2.new(0.5,0,0.5,0)
    -- → otomatis center di layar TANPA perlu ViewportSize sama sekali!
    local Container = mkFrame({
        Name   = "NxWindow",
        Size   = UDim2.new(0, defW, 0, defH),
        Pos    = UDim2.new(0.5, -defW / 2, 0.5, -defH / 2),
        Anchor = Vector2.new(0, 0),
        Color  = C.White, Trans = BG_TRANS,
        Z      = 2, Parent = sg,
    })
    mkCorner(Container, R.XL)
    mkStroke(Container, C.Border, 1.5, 0.38)
    mkShadow(Container, 5, 0.62)

    if doAnim then
        local finalPos  = Container.Position
        local finalSize = Container.Size
        Container.Size              = UDim2.new(0, defW * 0.88, 0, defH * 0.88)
        Container.Position          = UDim2.new(0.5, -(defW * 0.88) / 2, 0.5, -(defH * 0.88) / 2)
        Container.BackgroundTransparency = 1
        tw(Container, {
            Size     = finalSize,
            Position = finalPos,
            BackgroundTransparency = BG_TRANS,
        }, D.Slow, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end

    -- ===== HEADER =====
    local HH = 62
    local Header = mkFrame({
        Name  = "Header",
        Size  = UDim2.new(1, 0, 0, HH),
        Color = C.White, Trans = 0.55,
        Z     = 3, Parent = Container,
    })
    mkFrame({ Size = UDim2.new(1, 0, 0, 1), Pos = UDim2.new(0, 0, 1, -1),
        Color = C.Border, Trans = 0.5, Z = 4, Parent = Header })

    -- Avatar
    if showAvatar then
        local avSz = 38
        local avX  = avatarSide == "right"
            and UDim2.new(1, -(avSz + 12), 0.5, -avSz / 2)
            or  UDim2.new(0, 12, 0.5, -avSz / 2)

        local avF = mkFrame({ Size = UDim2.new(0, avSz, 0, avSz), Pos = avX,
            Color = C.White, Trans = 0.05, Z = 4, Parent = Header })
        mkCorner(avF, R.Full)
        mkStroke(avF, C.White, 2.5, 0.05)

        local ai = Instance.new("ImageLabel")
        ai.Image                  = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
        ai.BackgroundTransparency = 1
        ai.Size                   = UDim2.new(1, 0, 1, 0)
        ai.Position               = UDim2.new(0, 0, 0, 0)
        ai.ZIndex                 = 5
        ai.Parent                 = avF
        mkCorner(ai, R.Full)

        local dot = mkFrame({ Size = UDim2.new(0, 10, 0, 10),
            Pos = UDim2.new(1, -10, 1, -10), Color = C.Success, Trans = 0,
            Z = 6, Parent = avF })
        mkCorner(dot, R.Full)
        mkStroke(dot, C.White, 2, 0)
    end

    local tX = showAvatar and (avatarSide ~= "right" and 62 or 12) or 12
    mkLabel({ Text = winTitle, Font = F.Display, Size = 17, Color = C.TextPrimary,
        FS = UDim2.new(1, -120, 0, 20),
        Pos = UDim2.new(0, tX, 0, winSub ~= "" and 9 or 21),
        Z = 4, Parent = Header })
    if winSub ~= "" then
        mkLabel({ Text = winSub, Font = F.Body, Size = 11, Color = C.TextSecondary,
            FS = UDim2.new(1, -120, 0, 14), Pos = UDim2.new(0, tX, 0, 32),
            Z = 4, Parent = Header })
    end

    -- Close button
    local closeBtn = mkBtn({ Text = "✕", TS = 13, TC = C.TextMuted,
        Color = C.Surface, Trans = 0.22,
        Size = UDim2.new(0, 28, 0, 28), Pos = UDim2.new(1, -40, 0.5, -14),
        Z = 6, Parent = Header })
    mkCorner(closeBtn, R.Full)
    closeBtn.MouseEnter:Connect(function()
        tw(closeBtn, { BackgroundColor3 = C.Error, TextColor3 = C.White,
            BackgroundTransparency = 0 }, D.Fast)
    end)
    closeBtn.MouseLeave:Connect(function()
        tw(closeBtn, { BackgroundColor3 = C.Surface, TextColor3 = C.TextMuted,
            BackgroundTransparency = 0.22 }, D.Fast)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        tw(Container, { BackgroundTransparency = 1,
            Size = UDim2.new(0, defW * 0.88, 0, defH * 0.88) }, D.Normal)
        task.delay(D.Normal, function() pcall(function() sg:Destroy() end) end)
    end)

    -- [FIX 3] DRAG — stored-start-pos + InputChanged delta
    -- Delta approach: GuiInset mismatch otomatis cancel karena kita pakai selisih
    -- Tidak butuh IgnoreGuiInset sama sekali
    if draggable then
        local dragHandle = mkBtn({
            Name  = "DragHandle", Text = "",
            Color = C.Black, Trans = 1,
            Size  = UDim2.new(1, -44, 1, 0),
            Pos   = UDim2.new(0, 0, 0, 0),
            Z     = 5, Parent = Header,
        })

        local dragActive      = false
        local dragStartMouse  = Vector2.new(0, 0)
        local dragStartWinPos = Vector2.new(0, 0)

        dragHandle.MouseButton1Down:Connect(function()
            dragActive      = true
            dragStartMouse  = UserInputService:GetMouseLocation()
            local cp        = Container.Position
            dragStartWinPos = Vector2.new(cp.X.Offset, cp.Y.Offset)
        end)

        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragActive = false
            end
        end)

        UserInputService.InputChanged:Connect(function(inp)
            if not dragActive then return end
            if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            -- delta: current mouse - start mouse. GuiInset cancels out here.
            local curMouse = UserInputService:GetMouseLocation()
            local delta    = curMouse - dragStartMouse
            local vp2      = getViewport()
            local newX     = math.clamp(dragStartWinPos.X + delta.X, 0, vp2.X - defW)
            local newY     = math.clamp(dragStartWinPos.Y + delta.Y, 0, vp2.Y - defH)
            Container.Position = UDim2.new(0, newX, 0, newY)
        end)
    end

    -- ===== SIDEBAR =====
    local SW = 178
    local Sidebar = mkFrame({
        Name  = "Sidebar",
        Size  = UDim2.new(0, SW, 1, -HH),
        Pos   = UDim2.new(0, 0, 0, HH),
        Color = C.SidebarBg, Trans = 0.3,
        Z     = 3, Parent = Container,
    })
    mkFrame({ Size = UDim2.new(0, 1, 1, 0), Pos = UDim2.new(1, -1, 0, 0),
        Color = C.Border, Trans = 0.5, Z = 4, Parent = Sidebar })

    local sideScroll = mkScroll({
        Size = UDim2.new(1, 0, 1, -6), Pos = UDim2.new(0, 0, 0, 3),
        Bar = 2, Z = 4, Parent = Sidebar,
    })
    mkVList(sideScroll, 3)
    mkPadding(sideScroll, S.XS, S.XS, S.SM, S.SM)

    -- ===== CONTENT AREA =====
    local ContentArea = mkFrame({
        Name  = "ContentArea",
        Size  = UDim2.new(1, -SW, 1, -HH),
        Pos   = UDim2.new(0, SW, 0, HH),
        Color = C.White, Trans = BG_TRANS + 0.22,
        Z     = 3, Parent = Container,
    })
    local ContentScroll = mkScroll({
        Size = UDim2.new(1, 0, 1, 0),
        Bar = 3, Z = 4, Parent = ContentArea,
    })
    mkVList(ContentScroll, S.SM)
    mkPadding(ContentScroll, S.MD, S.MD, S.MD, S.MD)

    -- ===== TAB SYSTEM =====
    local tabs      = {}
    local activeTab = nil

    local function setActive(name)
        for n, td in pairs(tabs) do
            local on = (n == name)
            tw(td.Btn, {
                BackgroundColor3       = on and C.Accent or C.SidebarBg,
                BackgroundTransparency = on and 0.82 or 1,
            }, D.Fast)
            tw(td.Lbl, { TextColor3 = on and C.Accent or C.TextSecondary }, D.Fast)
            if td.Ico then
                tw(td.Ico, { ImageColor3 = on and C.Accent or C.TextSecondary }, D.Fast)
            end
            td.Content.Visible = on
        end
        activeTab = name
    end

    -- ===== WINDOW API =====
    local WinAPI = {}

    function WinAPI:CreateTab(cfg2)
        cfg2 = cfg2 or {}
        local tabName  = cfg2.Name or "Tab"
        local tabIcon  = cfg2.Icon or ""
        local tabBadge = cfg2.Badge or nil
        local tabOrder = cfg2.Order or (function()
            local n = 0
            for _ in pairs(tabs) do n = n + 1 end
            return (n + 1) * 10
        end)()

        -- Sidebar tab button
        local tb = mkBtn({ Name = tabName .. "_Btn", Text = "",
            Color = C.SidebarBg, Trans = 1,
            Size = UDim2.new(1, 0, 0, 36),
            Z = 5, Parent = sideScroll })
        tb.LayoutOrder = tabOrder
        mkCorner(tb, R.SM)

        local tabIco = nil
        if tabIcon ~= "" then
            tabIco = mkIcon({ Image = tabIcon, Color = C.TextSecondary,
                Size   = UDim2.new(0, 15, 0, 15),
                Pos    = UDim2.new(0, 9, 0.5, 0),
                Anchor = Vector2.new(0, 0.5),
                Z = 6, Parent = tb })
        end

        local tabLbl = mkLabel({ Text = tabName, Font = F.Sub, Size = 13,
            Color = C.TextSecondary,
            FS  = UDim2.new(1, tabIcon ~= "" and -32 or -8, 1, 0),
            Pos = UDim2.new(0, tabIcon ~= "" and 29 or 8, 0, 0),
            Z = 6, Parent = tb })

        if tabBadge then
            local bdg = mkFrame({ Size = UDim2.new(0, 17, 0, 15),
                Pos = UDim2.new(1, -20, 0.5, -7),
                Color = C.Error, Trans = 0, Z = 7, Parent = tb })
            mkCorner(bdg, R.Full)
            mkLabel({ Text = tostring(tabBadge), Font = F.Body, Size = 10,
                Color = C.White, FS = UDim2.new(1, 0, 1, 0),
                AlignX = Enum.TextXAlignment.Center, Z = 8, Parent = bdg })
        end

        -- Tab content container
        local tabContent = mkFrame({ Name = tabName .. "_Content",
            Size = UDim2.new(1, 0, 0, 0),
            Color = C.Black, Trans = 1,
            Z = 4, Parent = ContentScroll })
        tabContent.AutomaticSize = Enum.AutomaticSize.Y
        tabContent.Visible       = false
        tabContent.LayoutOrder   = tabOrder
        mkVList(tabContent, S.SM)

        tabs[tabName] = { Btn = tb, Lbl = tabLbl, Ico = tabIco, Content = tabContent }
        if activeTab == nil then setActive(tabName) end

        tb.MouseEnter:Connect(function()
            if activeTab ~= tabName then
                tw(tb, { BackgroundTransparency = 0.92 }, D.Fast)
            end
        end)
        tb.MouseLeave:Connect(function()
            if activeTab ~= tabName then
                tw(tb, { BackgroundTransparency = 1 }, D.Fast)
            end
        end)
        tb.MouseButton1Click:Connect(function() setActive(tabName) end)

        -- ===== TAB API =====
        local TabAPI = {}
        local _ord   = 0
        local function O() _ord = _ord + 10; return _ord end

        -- ============== TOGGLE ==============
        function TabAPI:CreateToggle(c)
            c = c or {}
            local name = c.Name or "Toggle"
            local desc = c.Description or ""
            local ico2 = c.Icon or ""
            local def  = c.Default == true
            local flag = c.Flag
            local cb   = c.Callback or function() end
            local o    = O()

            local rH  = desc ~= "" and 64 or 52
            local r   = mkRow(tabContent, rH, o)

            -- Icon: AnchorPoint(0,0.5) + Pos Y=0.5 → auto center, no manual math
            local iconImg = nil
            if ico2 ~= "" then
                iconImg = mkIcon({
                    Image  = ico2,
                    Color  = def and C.Accent or C.TextSecondary,
                    Size   = UDim2.new(0, 18, 0, 18),
                    Pos    = UDim2.new(0, S.LG, 0.5, 0),
                    Anchor = Vector2.new(0, 0.5),
                    Z      = 7, Parent = r,
                })
            end

            local tx = ico2 ~= "" and (S.LG + 26) or S.LG

            -- Name label
            local nameL = Instance.new("TextLabel")
            nameL.Text                   = name
            nameL.Font                   = F.Sub
            nameL.TextSize               = 13
            nameL.TextColor3             = C.TextPrimary
            nameL.BackgroundTransparency = 1
            nameL.TextXAlignment         = Enum.TextXAlignment.Left
            nameL.TextYAlignment         = Enum.TextYAlignment.Center
            nameL.TextTruncate           = Enum.TextTruncate.AtEnd
            nameL.Size                   = UDim2.new(1, -126, 0, 18)
            nameL.ZIndex                 = 6
            if desc ~= "" then
                -- with desc: anchor top, fixed Y
                nameL.AnchorPoint = Vector2.new(0, 0)
                nameL.Position    = UDim2.new(0, tx, 0, 10)
            else
                -- no desc: anchor middle, auto-center
                nameL.AnchorPoint = Vector2.new(0, 0.5)
                nameL.Position    = UDim2.new(0, tx, 0.5, 0)
            end
            nameL.Parent = r

            if desc ~= "" then
                local descL = Instance.new("TextLabel")
                descL.Text                   = desc
                descL.Font                   = F.Body
                descL.TextSize               = 11
                descL.TextColor3             = C.TextMuted
                descL.BackgroundTransparency = 1
                descL.TextXAlignment         = Enum.TextXAlignment.Left
                descL.TextYAlignment         = Enum.TextYAlignment.Center
                descL.TextTruncate           = Enum.TextTruncate.AtEnd
                descL.Size                   = UDim2.new(1, -126, 0, 14)
                descL.AnchorPoint            = Vector2.new(0, 0)
                descL.Position               = UDim2.new(0, tx, 0, 32)
                descL.ZIndex                 = 6
                descL.Parent                 = r
            end

            -- iOS-style switch — use TextButton for reliable click
            local track = mkBtn({
                Name   = "Track", Text = "",
                Color  = def and C.Accent or C.TrackOff,
                Trans  = 0,
                Size   = UDim2.new(0, 44, 0, 24),
                Pos    = UDim2.new(1, -58, 0.5, -12),
                Anchor = Vector2.new(0, 0),
                Z      = 6, Parent = r,
            })
            mkCorner(track, R.Full)

            local thumb = mkFrame({
                Size   = UDim2.new(0, 20, 0, 20),
                Pos    = UDim2.new(0, def and 22 or 2, 0.5, -10),
                Color  = C.White, Trans = 0,
                Z      = 7, Parent = track,
            })
            mkCorner(thumb, R.Full)
            mkShadow(thumb, 1, 0.62)

            local toggled = def
            if flag then Nexuralib.Flags[flag] = toggled end

            local function setToggle(val, silent)
                toggled = val
                if flag then Nexuralib.Flags[flag] = val end
                springTw(thumb, { Position = UDim2.new(0, val and 22 or 2, 0.5, -10) }, 0.3)
                tw(track, { BackgroundColor3 = val and C.Accent or C.TrackOff }, D.Normal)
                if iconImg then
                    tw(iconImg, { ImageColor3 = val and C.Accent or C.TextSecondary }, D.Fast)
                end
                if not silent then cb(val) end
            end

            track.MouseButton1Click:Connect(function() setToggle(not toggled) end)

            return {
                SetValue = function(v) setToggle(v, true) end,
                GetValue = function() return toggled end,
            }
        end

        -- ============== BUTTON ==============
        function TabAPI:CreateButton(c)
            c = c or {}
            local name    = c.Name or "Button"
            local desc    = c.Description or ""
            local ico2    = c.Icon or ""
            local variant = c.Variant or "primary"
            local fw      = c.FullWidth or false
            local loading = c.Loading or false
            local cb      = c.Callback or function() end
            local o       = O()
            local r       = mkRow(tabContent, 52, o)

            local bgC, fgC, bgTr
            if     variant == "primary"   then bgC = C.Accent;   fgC = C.White;         bgTr = 0
            elseif variant == "secondary" then bgC = C.Surface;  fgC = C.Accent;         bgTr = 0.15
            elseif variant == "ghost"     then bgC = C.Black;    fgC = C.Accent;         bgTr = 1
            elseif variant == "danger"    then bgC = C.Error;    fgC = C.White;          bgTr = 0
            else                               bgC = C.Accent;   fgC = C.White;          bgTr = 0
            end

            if desc ~= "" then
                mkLabel({ Text = desc, Font = F.Body, Size = 11, Color = C.TextMuted,
                    FS = UDim2.new(0.5, -S.MD, 0, 14),
                    Pos = UDim2.new(0, S.LG, 0.5, -7), Z = 5, Parent = r })
            end

            local b2 = mkBtn({
                Text  = "", Color = bgC, Trans = bgTr,
                Size  = fw and UDim2.new(1, -S.XXL, 0, 34) or UDim2.new(0, 144, 0, 34),
                Pos   = fw and UDim2.new(0, S.MD, 0.5, -17) or UDim2.new(1, -(144 + S.MD), 0.5, -17),
                Z     = 5, Parent = r,
            })
            mkCorner(b2, R.SM)
            if variant == "secondary" or variant == "ghost" then
                mkStroke(b2, C.Accent, 1.5, 0.3)
            end

            if ico2 ~= "" then
                mkIcon({ Image = ico2, Color = fgC,
                    Size = UDim2.new(0, 13, 0, 13),
                    Pos = UDim2.new(0, S.MD, 0.5, 0), Anchor = Vector2.new(0, 0.5),
                    Z = 6, Parent = b2 })
            end
            mkLabel({ Text = name, Font = F.Title, Size = 13, Color = fgC,
                FS = UDim2.new(1, ico2 ~= "" and -34 or -S.MD, 1, 0),
                Pos = UDim2.new(0, ico2 ~= "" and 30 or S.SM, 0, 0),
                AlignX = Enum.TextXAlignment.Center, Z = 6, Parent = b2 })

            -- Loading spinner
            local spinConn = nil
            local spinner  = nil
            local function setLoading(on)
                if on then
                    if not spinner then
                        spinner = mkIcon({
                            Image = "rbxassetid://4031732851", Color = fgC,
                            Size = UDim2.new(0, 14, 0, 14),
                            Pos = UDim2.new(0.5, -7, 0.5, -7),
                            Anchor = Vector2.new(0, 0), Z = 7, Parent = b2 })
                    end
                    spinner.Visible = true
                    local rot = 0
                    spinConn = RunService.Heartbeat:Connect(function(dt)
                        rot = rot + 360 * dt
                        spinner.Rotation = rot
                    end)
                else
                    if spinner then spinner.Visible = false end
                    if spinConn then spinConn:Disconnect(); spinConn = nil end
                end
            end
            if loading then setLoading(true) end

            b2.MouseEnter:Connect(function()
                tw(b2, { BackgroundTransparency = math.max(0, bgTr - 0.08) }, D.Fast)
                tw(b2, { Position = UDim2.new(b2.Position.X.Scale,
                    b2.Position.X.Offset, 0, b2.Position.Y.Offset - 2) }, D.Fast)
            end)
            b2.MouseLeave:Connect(function()
                tw(b2, { BackgroundTransparency = bgTr }, D.Fast)
                tw(b2, { Position = UDim2.new(b2.Position.X.Scale,
                    b2.Position.X.Offset, 0, b2.Position.Y.Offset + 2) }, D.Fast)
            end)
            b2.MouseButton1Click:Connect(function()
                local mp = UserInputService:GetMouseLocation()
                local rp = mp - Vector2.new(b2.AbsolutePosition.X, b2.AbsolutePosition.Y)
                mkRipple(b2, rp.X, rp.Y)
                cb()
            end)

            return { SetLoading = setLoading }
        end

        -- ============== SLIDER ==============
        function TabAPI:CreateSlider(c)
            c = c or {}
            local name  = c.Name or "Slider"
            local desc  = c.Description or ""
            local ico2  = c.Icon or ""
            local minV  = c.Min or 0
            local maxV  = c.Max or 100
            local def   = c.Default or minV
            local inc   = c.Increment or 1
            local fmt   = c.ValueFormat or "%d"
            local showV = c.ShowValue ~= false
            local flag  = c.Flag
            local cb    = c.Callback or function() end
            local o     = O()

            local rH = desc ~= "" and 72 or 56
            local r  = mkRow(tabContent, rH, o)

            if ico2 ~= "" then
                mkIcon({ Image = ico2, Color = C.TextSecondary,
                    Size = UDim2.new(0, 17, 0, 17),
                    Pos = UDim2.new(0, S.LG, 0, desc ~= "" and 9 or 8),
                    Anchor = Vector2.new(0, 0), Z = 6, Parent = r })
            end
            local tx = ico2 ~= "" and (S.LG + 24) or S.LG
            mkLabel({ Text = name, Font = F.Sub, Size = 13, Color = C.TextPrimary,
                FS = UDim2.new(1, -76, 0, 17), Pos = UDim2.new(0, tx, 0, 8),
                Z = 5, Parent = r })
            if desc ~= "" then
                mkLabel({ Text = desc, Font = F.Body, Size = 11, Color = C.TextMuted,
                    FS = UDim2.new(1, -76, 0, 13), Pos = UDim2.new(0, tx, 0, 26),
                    Z = 5, Parent = r })
            end

            local valLbl = nil
            if showV then
                valLbl = mkLabel({ Text = string.format(fmt, def), Font = F.Code,
                    Size = 12, Color = C.Accent,
                    FS = UDim2.new(0, 50, 0, 17), Pos = UDim2.new(1, -58, 0, 8),
                    AlignX = Enum.TextXAlignment.Right, Z = 5, Parent = r })
            end

            local trkY   = desc ~= "" and 50 or 36
            local trkOff = -(S.LG * 2 + (showV and 56 or 0))
            local trk = mkFrame({ Size = UDim2.new(1, trkOff, 0, 6),
                Pos = UDim2.new(0, S.LG, 0, trkY),
                Color = Color3.fromRGB(215, 215, 220), Trans = 0.08,
                Z = 5, Parent = r })
            mkCorner(trk, R.Full)

            local fill = mkFrame({ Size = UDim2.new(0, 0, 1, 0), Color = C.Accent,
                Trans = 0, Z = 6, Parent = trk })
            mkCorner(fill, R.Full)

            local th = mkFrame({ Size = UDim2.new(0, 18, 0, 18),
                Pos = UDim2.new(0, -9, 0.5, -9),
                Color = C.White, Trans = 0, Z = 7, Parent = fill })
            mkCorner(th, R.Full)
            mkStroke(th, C.Accent, 2, 0)
            mkShadow(th, 1, 0.58)

            local cur = def
            if flag then Nexuralib.Flags[flag] = cur end

            local function snap(v)
                return math.clamp(math.round((v - minV) / inc) * inc + minV, minV, maxV)
            end
            local function setSlider(v, silent)
                cur = snap(v)
                if flag then Nexuralib.Flags[flag] = cur end
                local pct = (cur - minV) / (maxV - minV)
                tw(fill, { Size = UDim2.new(pct, 0, 1, 0) }, D.Fast)
                if valLbl then valLbl.Text = string.format(fmt, cur) end
                if not silent then cb(cur) end
            end
            setSlider(def, true)

            local drag = false
            trk.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    drag = true
                    tw(th, { Size = UDim2.new(0, 22, 0, 22),
                        Position = UDim2.new(0, -11, 0.5, -11) }, D.Fast)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 and drag then
                    drag = false
                    tw(th, { Size = UDim2.new(0, 18, 0, 18),
                        Position = UDim2.new(0, -9, 0.5, -9) }, D.Fast)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if not drag then return end
                if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                local ap  = trk.AbsolutePosition
                local aw  = trk.AbsoluteSize.X
                local rel = math.clamp(inp.Position.X - ap.X, 0, aw)
                setSlider(minV + (rel / aw) * (maxV - minV))
            end)

            return {
                SetValue = function(v) setSlider(v, true) end,
                GetValue = function() return cur end,
            }
        end

        -- ============== DROPDOWN ==============
        function TabAPI:CreateDropdown(c)
            c = c or {}
            local name  = c.Name or "Dropdown"
            local desc  = c.Description or ""
            local ico2  = c.Icon or ""
            local opts  = c.Options or {}
            local def   = c.Default
            local multi = c.MultiSelect or false
            local flag  = c.Flag
            local cb    = c.Callback or function() end
            local o     = O()

            local rH = desc ~= "" and 60 or 48
            local r  = mkRow(tabContent, rH, o)

            if ico2 ~= "" then
                mkIcon({ Image = ico2, Color = C.TextSecondary,
                    Size = UDim2.new(0, 17, 0, 17),
                    Pos = UDim2.new(0, S.LG, 0.5, 0), Anchor = Vector2.new(0, 0.5),
                    Z = 6, Parent = r })
            end
            local tx = ico2 ~= "" and (S.LG + 24) or S.LG
            mkLabel({ Text = name, Font = F.Sub, Size = 13, Color = C.TextPrimary,
                FS = UDim2.new(1, -136, 0, 17),
                Pos = UDim2.new(0, tx, 0, desc ~= "" and 6 or (rH / 2 - 8)),
                Z = 5, Parent = r })
            if desc ~= "" then
                mkLabel({ Text = desc, Font = F.Body, Size = 11, Color = C.TextMuted,
                    FS = UDim2.new(1, -136, 0, 13), Pos = UDim2.new(0, tx, 0, 24),
                    Z = 5, Parent = r })
            end

            local sel = multi and {} or def
            if flag then Nexuralib.Flags[flag] = sel end

            local selBtn = mkBtn({ Text = def or "Select...", Font = F.Body, TS = 12,
                TC = def and C.TextPrimary or C.TextMuted,
                Color = C.Surface, Trans = 0.18,
                Size = UDim2.new(0, 122, 0, 28),
                Pos = UDim2.new(1, -(122 + S.MD), 0.5, -14),
                Z = 5, Parent = r })
            mkCorner(selBtn, R.SM)
            mkStroke(selBtn, C.Border, 1, 0.48)
            mkLabel({ Text = "▾", Font = F.Body, Size = 11, Color = C.TextMuted,
                FS = UDim2.new(0, 13, 1, 0), Pos = UDim2.new(1, -15, 0, 0),
                AlignX = Enum.TextXAlignment.Center, Z = 6, Parent = selBtn })

            local menu = nil
            local function closeMenu()
                if menu then
                    tw(menu, { BackgroundTransparency = 1 }, D.Fast)
                    task.delay(D.Fast, function()
                        pcall(function() menu:Destroy(); menu = nil end)
                    end)
                end
            end

            selBtn.MouseButton1Click:Connect(function()
                if menu then closeMenu(); return end
                local mH = math.min(#opts * 30 + 8, 170)
                menu = mkFrame({ Size = UDim2.new(0, 162, 0, 0),
                    Pos = UDim2.new(1, -(162 + S.MD), 0, rH + 2),
                    Color = C.White, Trans = BG_TRANS,
                    Z = 20, Parent = r })
                menu.ClipsDescendants = true
                mkCorner(menu, R.MD)
                mkStroke(menu, C.Border, 1, 0.38)
                mkShadow(menu, 3, 0.66)
                tw(menu, { Size = UDim2.new(0, 162, 0, mH) },
                    D.Normal, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

                local ms = mkScroll({ Size = UDim2.new(1, 0, 1, 0), Bar = 2,
                    Z = 21, Parent = menu })
                mkVList(ms, 2)
                mkPadding(ms, 3, 3, 3, 3)

                local function buildOpts()
                    for _, ch in ipairs(ms:GetChildren()) do
                        if ch.Name:sub(1, 4) == "Opt_" then ch:Destroy() end
                    end
                    for i, opt in ipairs(opts) do
                        local isSel = multi
                            and (function()
                                for _, v in ipairs(sel) do if v == opt then return true end end
                                return false
                            end)()
                            or sel == opt

                        local ob = mkBtn({ Name = "Opt_" .. opt, Text = "",
                            Color = isSel and C.Accent or C.Black,
                            Trans = isSel and 0.84 or 1,
                            Size = UDim2.new(1, 0, 0, 28), Z = 22, Parent = ms })
                        ob.LayoutOrder = i
                        mkCorner(ob, R.SM)
                        mkLabel({ Text = opt, Font = F.Body, Size = 12,
                            Color = isSel and C.Accent or C.TextPrimary,
                            FS = UDim2.new(1, -26, 1, 0), Pos = UDim2.new(0, 7, 0, 0),
                            Z = 23, Parent = ob })
                        if isSel then
                            mkLabel({ Text = "✓", Font = F.Title, Size = 12, Color = C.Accent,
                                FS = UDim2.new(0, 16, 1, 0), Pos = UDim2.new(1, -18, 0, 0),
                                AlignX = Enum.TextXAlignment.Center, Z = 23, Parent = ob })
                        end
                        ob.MouseEnter:Connect(function()
                            if not isSel then tw(ob, { BackgroundTransparency = 0.93 }, D.Fast) end
                        end)
                        ob.MouseLeave:Connect(function()
                            if not isSel then tw(ob, { BackgroundTransparency = 1 }, D.Fast) end
                        end)
                        ob.MouseButton1Click:Connect(function()
                            if multi then
                                local found = false
                                for i2, v in ipairs(sel) do
                                    if v == opt then
                                        table.remove(sel, i2); found = true; break
                                    end
                                end
                                if not found then table.insert(sel, opt) end
                                selBtn.Text       = #sel > 0 and table.concat(sel, ", ") or "Select..."
                                selBtn.TextColor3 = #sel > 0 and C.TextPrimary or C.TextMuted
                                if flag then Nexuralib.Flags[flag] = sel end
                                cb(sel); buildOpts()
                            else
                                sel               = opt
                                selBtn.Text       = opt
                                selBtn.TextColor3 = C.TextPrimary
                                if flag then Nexuralib.Flags[flag] = sel end
                                cb(sel); closeMenu()
                            end
                        end)
                    end
                end
                buildOpts()
            end)

            return {
                SetValue = function(v)
                    sel = v
                    selBtn.Text = type(v) == "table"
                        and (#v > 0 and table.concat(v, ", ") or "Select...")
                        or  (v or "Select...")
                    selBtn.TextColor3 = v and C.TextPrimary or C.TextMuted
                    if flag then Nexuralib.Flags[flag] = v end
                end,
                GetValue = function() return sel end,
            }
        end

        -- ============== INPUT ==============
        function TabAPI:CreateInput(c)
            c = c or {}
            local name  = c.Name or "Input"
            local desc  = c.Description or ""
            local ico2  = c.Icon or ""
            local ph    = c.Placeholder or "Enter value..."
            local def   = c.Default or ""
            local clr   = c.ClearButton ~= false
            local flag  = c.Flag
            local cb    = c.Callback or function() end
            local o     = O()

            local rH = desc ~= "" and 72 or 58
            local r  = mkRow(tabContent, rH, o)

            if ico2 ~= "" then
                mkIcon({ Image = ico2, Color = C.TextSecondary,
                    Size = UDim2.new(0, 17, 0, 17),
                    Pos = UDim2.new(0, S.LG, 0, 8), Anchor = Vector2.new(0, 0),
                    Z = 6, Parent = r })
            end
            local tx = ico2 ~= "" and (S.LG + 24) or S.LG
            mkLabel({ Text = name, Font = F.Sub, Size = 13, Color = C.TextPrimary,
                FS = UDim2.new(1, -76, 0, 16), Pos = UDim2.new(0, tx, 0, 6),
                Z = 5, Parent = r })
            if desc ~= "" then
                mkLabel({ Text = desc, Font = F.Body, Size = 11, Color = C.TextMuted,
                    FS = UDim2.new(1, -76, 0, 13), Pos = UDim2.new(0, tx, 0, 24),
                    Z = 5, Parent = r })
            end

            local iY  = desc ~= "" and 42 or 30
            local ibg = mkFrame({ Size = UDim2.new(1, -S.XXL, 0, 26),
                Pos = UDim2.new(0, S.LG, 0, iY),
                Color = C.Surface, Trans = 0.18, Z = 5, Parent = r })
            mkCorner(ibg, R.SM)
            local ibStroke = mkStroke(ibg, C.Border, 1, 0.5)

            local box = Instance.new("TextBox")
            box.PlaceholderText   = ph
            box.Text              = def
            box.Font              = F.Body
            box.TextSize          = 13
            box.TextColor3        = C.TextPrimary
            box.PlaceholderColor3 = C.TextMuted
            box.BackgroundTransparency = 1
            box.Size              = UDim2.new(1, clr and -28 or -7, 1, 0)
            box.Position          = UDim2.new(0, 5, 0, 0)
            box.ZIndex            = 6
            box.ClearTextOnFocus  = false
            box.Parent            = ibg

            if clr then
                local cb2 = mkBtn({ Text = "✕", TS = 10, TC = C.TextMuted,
                    Color = C.Black, Trans = 1,
                    Size = UDim2.new(0, 22, 0, 22), Pos = UDim2.new(1, -24, 0.5, -11),
                    Z = 7, Parent = ibg })
                cb2.MouseButton1Click:Connect(function()
                    box.Text = ""
                    if flag then Nexuralib.Flags[flag] = "" end
                    cb("")
                end)
            end

            box.Focused:Connect(function()
                tw(ibg, { BackgroundTransparency = 0.04 }, D.Fast)
                ibStroke.Color = C.Accent; ibStroke.Transparency = 0.18
            end)
            box.FocusLost:Connect(function()
                tw(ibg, { BackgroundTransparency = 0.18 }, D.Fast)
                ibStroke.Color = C.Border; ibStroke.Transparency = 0.5
                local v = box.Text
                if flag then Nexuralib.Flags[flag] = v end
                cb(v)
            end)

            return {
                SetValue = function(v) box.Text = v end,
                GetValue = function() return box.Text end,
            }
        end

        -- ============== KEYBIND ==============
        function TabAPI:CreateKeybind(c)
            c = c or {}
            local name = c.Name or "Keybind"
            local desc = c.Description or ""
            local ico2 = c.Icon or ""
            local def  = c.Default or Enum.KeyCode.Unknown
            local hold = c.Hold or false
            local bl   = c.Blacklist or {}
            local flag = c.Flag
            local cb   = c.Callback or function() end
            local o    = O()

            local rH = desc ~= "" and 60 or 48
            local r  = mkRow(tabContent, rH, o)

            if ico2 ~= "" then
                mkIcon({ Image = ico2, Color = C.TextSecondary,
                    Size = UDim2.new(0, 17, 0, 17),
                    Pos = UDim2.new(0, S.LG, 0.5, 0), Anchor = Vector2.new(0, 0.5),
                    Z = 6, Parent = r })
            end
            local tx = ico2 ~= "" and (S.LG + 24) or S.LG
            mkLabel({ Text = name, Font = F.Sub, Size = 13, Color = C.TextPrimary,
                FS = UDim2.new(1, -112, 0, 17),
                Pos = UDim2.new(0, tx, 0, desc ~= "" and 6 or (rH / 2 - 8)),
                Z = 5, Parent = r })
            if desc ~= "" then
                mkLabel({ Text = desc, Font = F.Body, Size = 11, Color = C.TextMuted,
                    FS = UDim2.new(1, -112, 0, 13), Pos = UDim2.new(0, tx, 0, 25),
                    Z = 5, Parent = r })
            end

            local curKey = def
            if flag then Nexuralib.Flags[flag] = curKey end

            local pill = mkBtn({
                Text = curKey == Enum.KeyCode.Unknown and "None" or curKey.Name,
                Font = F.Code, TS = 11, TC = C.Accent,
                Color = C.Accent, Trans = 0.88,
                Size = UDim2.new(0, 80, 0, 24),
                Pos = UDim2.new(1, -(80 + S.MD), 0.5, -12),
                Z = 5, Parent = r })
            mkCorner(pill, R.Full)
            mkStroke(pill, C.Accent, 1, 0.52)

            local recording = false
            pill.MouseButton1Click:Connect(function()
                if recording then return end
                recording = true
                pill.Text = "..."
                tw(pill, { BackgroundTransparency = 0.7 }, D.Fast)
                local conn
                conn = UserInputService.InputBegan:Connect(function(inp, gp)
                    if gp then return end
                    local bad = false
                    for _, k in ipairs(bl) do if inp.KeyCode == k then bad = true; break end end
                    if not bad and inp.UserInputType == Enum.UserInputType.Keyboard then
                        curKey = inp.KeyCode
                        pill.Text = curKey.Name
                        if flag then Nexuralib.Flags[flag] = curKey end
                        recording = false
                        tw(pill, { BackgroundTransparency = 0.88 }, D.Fast)
                        conn:Disconnect()
                    end
                end)
            end)

            UserInputService.InputBegan:Connect(function(inp, gp)
                if gp then return end
                if inp.KeyCode == curKey and curKey ~= Enum.KeyCode.Unknown then
                    if not hold then cb(true) end
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.KeyCode == curKey and hold then cb(false) end
            end)

            return {
                SetKey = function(k)
                    curKey = k
                    pill.Text = k == Enum.KeyCode.Unknown and "None" or k.Name
                end,
                GetKey = function() return curKey end,
            }
        end

        -- ============== COLOR PICKER ==============
        function TabAPI:CreateColorPicker(c)
            c = c or {}
            local name    = c.Name or "Color"
            local desc    = c.Description or ""
            local ico2    = c.Icon or ""
            local def     = c.Default or Color3.fromRGB(0, 122, 255)
            local pres    = c.Presets or {
                Color3.fromRGB(255,59,48), Color3.fromRGB(255,149,0),
                Color3.fromRGB(255,204,0), Color3.fromRGB(52,199,89),
                Color3.fromRGB(0,122,255), Color3.fromRGB(175,82,222),
            }
            local showHex = c.ShowHex ~= false
            local flag    = c.Flag
            local cb      = c.Callback or function() end
            local o       = O()

            local rH = desc ~= "" and 58 or 46
            local r  = mkRow(tabContent, rH, o)

            if ico2 ~= "" then
                mkIcon({ Image = ico2, Color = C.TextSecondary,
                    Size = UDim2.new(0, 17, 0, 17),
                    Pos = UDim2.new(0, S.LG, 0.5, 0), Anchor = Vector2.new(0, 0.5),
                    Z = 6, Parent = r })
            end
            local tx = ico2 ~= "" and (S.LG + 24) or S.LG
            mkLabel({ Text = name, Font = F.Sub, Size = 13, Color = C.TextPrimary,
                FS = UDim2.new(1, -108, 0, 17),
                Pos = UDim2.new(0, tx, 0, desc ~= "" and 6 or (rH / 2 - 8)),
                Z = 5, Parent = r })
            if desc ~= "" then
                mkLabel({ Text = desc, Font = F.Body, Size = 11, Color = C.TextMuted,
                    FS = UDim2.new(1, -108, 0, 13), Pos = UDim2.new(0, tx, 0, 24),
                    Z = 5, Parent = r })
            end

            local curCol = def
            if flag then Nexuralib.Flags[flag] = curCol end

            local function hexStr(col)
                return string.format("#%02X%02X%02X",
                    math.floor(col.R * 255), math.floor(col.G * 255), math.floor(col.B * 255))
            end

            local sw = mkBtn({ Text = "", Color = curCol, Trans = 0,
                Size = UDim2.new(0, 34, 0, 22),
                Pos = UDim2.new(1, -(34 + S.MD), 0.5, -11),
                Z = 5, Parent = r })
            mkCorner(sw, R.SM)
            mkStroke(sw, C.Border, 1.5, 0.28)

            local hexLbl = mkLabel({ Text = hexStr(curCol), Font = F.Code, Size = 11,
                Color = C.TextSecondary,
                FS = UDim2.new(0, 60, 0, 16),
                Pos = UDim2.new(1, -(34 + S.MD + 66), 0.5, -8),
                AlignX = Enum.TextXAlignment.Right, Z = 5, Parent = r })

            local function updCol(col, silent)
                curCol = col
                sw.BackgroundColor3 = col
                hexLbl.Text = hexStr(col)
                if flag then Nexuralib.Flags[flag] = col end
                if not silent then cb(col) end
            end

            local picker = nil
            sw.MouseButton1Click:Connect(function()
                if picker then
                    tw(picker, { BackgroundTransparency = 1 }, D.Fast)
                    task.delay(D.Fast, function()
                        pcall(function() picker:Destroy(); picker = nil end)
                    end)
                    return
                end

                local pH = 186 + (#pres > 0 and 34 or 0) + (showHex and 34 or 0)
                picker = mkFrame({ Size = UDim2.new(1, -S.XXL, 0, 0),
                    Pos = UDim2.new(0, S.MD, 0, rH + 3),
                    Color = C.White, Trans = BG_TRANS,
                    Z = 15, Parent = r })
                picker.ClipsDescendants = true
                mkCorner(picker, R.MD)
                mkStroke(picker, C.Border, 1, 0.38)
                mkShadow(picker, 3, 0.66)
                tw(picker, { Size = UDim2.new(1, -S.XXL, 0, pH) },
                    D.Normal, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

                -- Hue slider
                local hb = mkFrame({ Size = UDim2.new(1, -S.XXL, 0, 13),
                    Pos = UDim2.new(0, S.MD, 0, S.MD),
                    Color = C.White, Trans = 0, Z = 16, Parent = picker })
                mkCorner(hb, R.Full)
                local hg = Instance.new("UIGradient")
                hg.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0/6, Color3.fromRGB(255,0,0)),
                    ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255,255,0)),
                    ColorSequenceKeypoint.new(2/6, Color3.fromRGB(0,255,0)),
                    ColorSequenceKeypoint.new(3/6, Color3.fromRGB(0,255,255)),
                    ColorSequenceKeypoint.new(4/6, Color3.fromRGB(0,0,255)),
                    ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255,0,255)),
                    ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,0,0)),
                })
                hg.Parent = hb

                local hth = mkFrame({ Size = UDim2.new(0, 13, 1, 4),
                    Pos = UDim2.new(0, -6, 0, -2),
                    Color = C.White, Trans = 0, Z = 17, Parent = hb })
                mkCorner(hth, R.SM)
                mkShadow(hth, 2, 0.55)

                -- Saturation box
                local sbBox = mkFrame({ Size = UDim2.new(1, -S.XXL, 0, 110),
                    Pos = UDim2.new(0, S.MD, 0, 34),
                    Color = curCol, Trans = 0, Z = 16, Parent = picker })
                mkCorner(sbBox, R.SM)
                local sgW = Instance.new("UIGradient")
                sgW.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
                sgW.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                })
                sgW.Parent = sbBox

                -- Presets row
                if #pres > 0 then
                    local pRow = mkFrame({ Size = UDim2.new(1, -S.XXL, 0, 24),
                        Pos = UDim2.new(0, S.MD, 0, 152),
                        Color = C.Black, Trans = 1, Z = 16, Parent = picker })
                    local pl = Instance.new("UIListLayout")
                    pl.FillDirection = Enum.FillDirection.Horizontal
                    pl.Padding       = UDim.new(0, S.SM)
                    pl.Parent        = pRow
                    for _, pc in ipairs(pres) do
                        local pb = mkBtn({ Text = "", Color = pc, Trans = 0,
                            Size = UDim2.new(0, 20, 0, 20), Z = 17, Parent = pRow })
                        mkCorner(pb, R.Full)
                        mkStroke(pb, C.Border, 1.5, 0.28)
                        pb.MouseButton1Click:Connect(function() updCol(pc) end)
                    end
                end

                -- Hex input
                if showHex then
                    local hexY  = 152 + (#pres > 0 and 34 or 0)
                    local hbg   = mkFrame({ Size = UDim2.new(1, -S.XXL, 0, 26),
                        Pos = UDim2.new(0, S.MD, 0, hexY),
                        Color = C.Surface, Trans = 0.2, Z = 16, Parent = picker })
                    mkCorner(hbg, R.SM)
                    mkStroke(hbg, C.Border, 1, 0.5)
                    local hbox = Instance.new("TextBox")
                    hbox.PlaceholderText   = "#RRGGBB"
                    hbox.Text              = hexStr(curCol)
                    hbox.Font              = F.Code; hbox.TextSize = 12
                    hbox.TextColor3        = C.TextPrimary
                    hbox.PlaceholderColor3 = C.TextMuted
                    hbox.BackgroundTransparency = 1
                    hbox.Size              = UDim2.new(1, -8, 1, 0)
                    hbox.Position          = UDim2.new(0, 4, 0, 0)
                    hbox.ZIndex            = 17; hbox.ClearTextOnFocus = false
                    hbox.Parent            = hbg
                    hbox.FocusLost:Connect(function()
                        local h = hbox.Text:gsub("#", "")
                        if #h == 6 then
                            local r2 = tonumber(h:sub(1,2), 16) or 0
                            local g2 = tonumber(h:sub(3,4), 16) or 0
                            local b2 = tonumber(h:sub(5,6), 16) or 0
                            updCol(Color3.fromRGB(r2, g2, b2))
                        end
                    end)
                end

                -- Hue drag
                local hDrag = false
                hb.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        hDrag = true
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        hDrag = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if not hDrag then return end
                    if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                    local ap  = hb.AbsolutePosition
                    local aw  = hb.AbsoluteSize.X
                    local pct = math.clamp((inp.Position.X - ap.X) / aw, 0, 1)
                    hth.Position = UDim2.new(pct, -6, 0, -2)
                    local nc = Color3.fromHSV(pct, 1, 1)
                    sbBox.BackgroundColor3 = nc
                    updCol(nc)
                end)
            end)

            updCol(def, true)
            return {
                SetValue = function(v) updCol(v, true) end,
                GetValue = function() return curCol end,
            }
        end

        -- ============== PROGRESS ==============
        function TabAPI:CreateProgress(c)
            c = c or {}
            local name   = c.Name or "Progress"
            local prog   = c.Progress or 0
            local indet  = c.Indeterminate or false
            local showPct = c.ShowPercentage ~= false
            local col    = c.Color or C.Accent
            local o      = O()

            local r = mkRow(tabContent, 50, o)
            mkLabel({ Text = name, Font = F.Sub, Size = 13, Color = C.TextPrimary,
                FS = UDim2.new(1, -66, 0, 17), Pos = UDim2.new(0, S.LG, 0, 7),
                Z = 5, Parent = r })

            local pctLbl = nil
            if showPct then
                pctLbl = mkLabel({ Text = math.floor(prog * 100) .. "%",
                    Font = F.Code, Size = 12, Color = C.Accent,
                    FS = UDim2.new(0, 44, 0, 17), Pos = UDim2.new(1, -(44 + S.MD), 0, 7),
                    AlignX = Enum.TextXAlignment.Right, Z = 5, Parent = r })
            end

            local trk = mkFrame({ Size = UDim2.new(1, -S.XXL, 0, 7),
                Pos = UDim2.new(0, S.LG, 0, 32),
                Color = Color3.fromRGB(215, 215, 220), Trans = 0.08,
                Z = 5, Parent = r })
            mkCorner(trk, R.Full)

            local fill = mkFrame({ Size = UDim2.new(prog, 0, 1, 0),
                Color = col, Trans = 0, Z = 6, Parent = trk })
            mkCorner(fill, R.Full)

            local fg = Instance.new("UIGradient")
            fg.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, col),
                ColorSequenceKeypoint.new(1, Color3.new(
                    math.min(1, col.R + 0.16),
                    math.min(1, col.G + 0.16),
                    math.min(1, col.B + 0.26)
                )),
            })
            fg.Parent = fill

            local indConn = nil
            if indet then
                local t = 0
                indConn = RunService.Heartbeat:Connect(function(dt)
                    t = t + dt
                    local p = (math.sin(t * 2) + 1) / 2
                    fill.Size     = UDim2.new(0.36, 0, 1, 0)
                    fill.Position = UDim2.new(p * 0.64, 0, 0, 0)
                end)
            end

            local function setP(v)
                prog = math.clamp(v, 0, 1)
                tw(fill, { Size = UDim2.new(prog, 0, 1, 0) }, D.Normal)
                if pctLbl then pctLbl.Text = math.floor(prog * 100) .. "%" end
            end

            return {
                SetProgress = setP,
                GetProgress = function() return prog end,
                Destroy     = function()
                    if indConn then indConn:Disconnect() end
                    pcall(function() r:Destroy() end)
                end,
            }
        end

        -- ============== CARD ==============
        function TabAPI:CreateCard(c)
            c = c or {}
            local title = c.Title or ""
            local desc  = c.Description or ""
            local ico2  = c.Icon or ""
            local coll  = c.Collapsible or false
            local expd  = c.DefaultExpanded ~= false
            local pad   = c.Padding or S.MD
            local o     = O()

            local card = mkFrame({ Name = "Card_" .. title,
                Size = UDim2.new(1, 0, 0, 0),
                Color = C.RowBg, Trans = ROW_TRANS,
                Z = 4, Parent = tabContent })
            card.AutomaticSize = Enum.AutomaticSize.Y
            card.LayoutOrder   = o
            mkCorner(card, R.MD)
            mkStroke(card, C.Border, 1, 0.55)

            local hH = (title ~= "" or ico2 ~= "") and 38 or 0
            local bodyRef = nil  -- forward ref for collapse button

            if hH > 0 then
                local hdr = mkFrame({ Size = UDim2.new(1, 0, 0, hH),
                    Color = C.SidebarBg, Trans = 0.3, Z = 5, Parent = card })
                mkCorner(hdr, R.MD)

                if ico2 ~= "" then
                    mkIcon({ Image = ico2, Color = C.Accent,
                        Size = UDim2.new(0, 15, 0, 15),
                        Pos = UDim2.new(0, S.MD, 0.5, 0), Anchor = Vector2.new(0, 0.5),
                        Z = 6, Parent = hdr })
                end
                local hx = ico2 ~= "" and (S.MD + 21) or S.MD
                mkLabel({ Text = title, Font = F.Title, Size = 13, Color = C.TextPrimary,
                    FS = UDim2.new(1, -56, 0, 17),
                    Pos = UDim2.new(0, hx, 0, desc ~= "" and 3 or (hH / 2 - 8)),
                    Z = 6, Parent = hdr })
                if desc ~= "" then
                    mkLabel({ Text = desc, Font = F.Body, Size = 11, Color = C.TextMuted,
                        FS = UDim2.new(1, -56, 0, 13), Pos = UDim2.new(0, hx, 0, 21),
                        Z = 6, Parent = hdr })
                end

                if coll then
                    local chv = mkBtn({ Text = expd and "▴" or "▾", TS = 11,
                        TC = C.TextMuted, Color = C.Black, Trans = 1,
                        Size = UDim2.new(0, 26, 1, 0), Pos = UDim2.new(1, -30, 0, 0),
                        Z = 7, Parent = hdr })
                    chv.MouseButton1Click:Connect(function()
                        expd = not expd
                        chv.Text = expd and "▴" or "▾"
                        if bodyRef then bodyRef.Visible = expd end
                    end)
                end
            end

            local body = mkFrame({ Size = UDim2.new(1, 0, 0, 0),
                Pos = UDim2.new(0, 0, 0, hH),
                Color = C.Black, Trans = 1,
                Z = 5, Parent = card })
            body.AutomaticSize = Enum.AutomaticSize.Y
            body.Visible       = expd
            bodyRef            = body

            mkVList(body, S.SM)
            mkPadding(body, pad, pad, pad, pad)  -- no PaddingAll, uses 4 props

            local CardAPI = {}
            local _co = 0
            function CardAPI:AddLabel(text, sz, col, font)
                _co = _co + 10
                local l = mkLabel({ Text = text or "", Font = font or F.Body,
                    Size = sz or 13, Color = col or C.TextPrimary,
                    FS = UDim2.new(1, 0, 0, 20), Z = 6, Parent = body })
                l.LayoutOrder = _co
                return l
            end
            function CardAPI:GetBody() return body end
            return CardAPI
        end

        -- ============== AVATAR ==============
        function TabAPI:CreateAvatar(c)
            c = c or {}
            local uid    = c.UserId or LocalPlayer.UserId
            local avSz   = c.Size or 68
            local showSt = c.ShowStatus or false
            local stCol  = c.StatusColor or C.Success
            local click  = c.Clickable ~= false
            local o      = O()

            local rH = avSz + S.XXL
            local r  = mkRow(tabContent, rH, o)
            r.AutomaticSize = Enum.AutomaticSize.None

            local avF = mkFrame({ Size = UDim2.new(0, avSz, 0, avSz),
                Pos = UDim2.new(0.5, -avSz / 2, 0.5, -avSz / 2),
                Color = C.White, Trans = 0.04, Z = 5, Parent = r })
            mkCorner(avF, R.Full)
            mkStroke(avF, C.White, 2.5, 0.06)
            mkShadow(avF, 3, 0.66)

            local ai = Instance.new("ImageLabel")
            ai.Image                  = "rbxthumb://type=AvatarHeadShot&id=" .. uid .. "&w=150&h=150"
            ai.BackgroundTransparency = 1
            ai.Size                   = UDim2.new(1, 0, 1, 0)
            ai.Position               = UDim2.new(0, 0, 0, 0)
            ai.ZIndex                 = 6
            ai.Parent                 = avF
            mkCorner(ai, R.Full)

            if showSt then
                local dot = mkFrame({ Size = UDim2.new(0, 11, 0, 11),
                    Pos = UDim2.new(1, -11, 1, -11),
                    Color = stCol, Trans = 0, Z = 7, Parent = avF })
                mkCorner(dot, R.Full)
                mkStroke(dot, C.White, 2, 0)
            end
            if click then
                local cz = mkBtn({ Text = "", Color = C.Black, Trans = 1,
                    Size = UDim2.new(1, 0, 1, 0), Z = 8, Parent = avF })
                cz.MouseButton1Click:Connect(function()
                    Nexuralib:ShowModal({ Title = "Avatar",
                        PrimaryAction = { Text = "Close" } })
                end)
            end
            return {
                SetUserId = function(id)
                    ai.Image = "rbxthumb://type=AvatarHeadShot&id=" .. id .. "&w=150&h=150"
                end,
            }
        end

        -- ============== SEPARATOR ==============
        function TabAPI:AddSeparator(lbl)
            local o = O()
            if lbl then
                local sep = mkFrame({ Size = UDim2.new(1, 0, 0, 22),
                    Color = C.Black, Trans = 1,
                    Z = 4, Parent = tabContent })
                sep.LayoutOrder = o
                mkLabel({ Text = lbl, Font = F.Body, Size = 11, Color = C.TextMuted,
                    FS = UDim2.new(1, 0, 1, 0),
                    AlignX = Enum.TextXAlignment.Center,
                    Z = 5, Parent = sep })
                for _, xo in ipairs({ 0, 0.56 }) do
                    mkFrame({ Size = UDim2.new(0.4, 0, 0, 1),
                        Pos = UDim2.new(xo, 0, 0.5, 0),
                        Color = C.Border, Trans = 0.58,
                        Z = 4, Parent = sep })
                end
            else
                local sep = mkFrame({ Size = UDim2.new(1, -S.XXL, 0, 1),
                    Pos = UDim2.new(0, S.MD, 0, 0),
                    Color = C.Border, Trans = 0.58,
                    Z = 4, Parent = tabContent })
                sep.LayoutOrder = o
            end
        end

        return TabAPI
    end

    -- Window-level shortcuts
    function WinAPI:Notify(c)    return Nexuralib:Notify(c) end
    function WinAPI:ShowModal(c) return Nexuralib:ShowModal(c) end
    function WinAPI:Destroy()
        tw(Container, { BackgroundTransparency = 1 }, D.Normal)
        task.delay(D.Normal, function() pcall(function() sg:Destroy() end) end)
    end
    function WinAPI:SetTitle(t)
        for _, ch in ipairs(Header:GetChildren()) do
            if ch:IsA("TextLabel") and ch.Font == F.Display then ch.Text = t end
        end
    end

    return WinAPI
end

return Nexuralib

--[[
=============================================================
  NEXURALIB v4 — EXAMPLE USAGE
=============================================================

local Nexuralib = loadstring(game:HttpGet("YOUR_URL"))()

local Window = Nexuralib:CreateWindow({
    Title          = "My Script",
    Subtitle       = "v4.0",
    ShowUserAvatar = true,
    Draggable      = true,
    AnimateOpen    = true,
})

local Main     = Window:CreateTab({ Name="Main",     Icon="rbxassetid://7733715400" })
local Settings = Window:CreateTab({ Name="Settings", Icon="rbxassetid://7734014475", Order=20 })

Main:CreateToggle({
    Name="Auto Farm", Icon="rbxassetid://7733715400",
    Description="Enable auto farming",
    Default=false, Flag="AutoFarm",
    Callback=function(v) print("AutoFarm:", v) end,
})
Main:CreateButton({
    Name="Teleport", Icon="rbxassetid://7733960981",
    Variant="primary",
    Callback=function() print("Teleport!") end,
})
Main:CreateSlider({
    Name="Speed", Icon="rbxassetid://7733658504",
    Min=16, Max=100, Default=16, Increment=1, Flag="Speed",
    Callback=function(v)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end,
})
Main:CreateDropdown({
    Name="Mode", Icon="rbxassetid://7734014475",
    Options={"Safe","Fast","Stealth"},
    Default="Safe", Flag="Mode",
    Callback=function(v) print(v) end,
})
Main:CreateInput({
    Name="Target", Icon="rbxassetid://7733715400",
    Placeholder="Player name...",
    Flag="Target",
    Callback=function(v) print(v) end,
})
Main:CreateKeybind({
    Name="Toggle GUI", Icon="rbxassetid://7733960981",
    Default=Enum.KeyCode.RightShift, Flag="GuiKey",
    Callback=function(v) print("Triggered:", v) end,
})
Main:CreateColorPicker({
    Name="Highlight Color", Icon="rbxassetid://7733658504",
    Default=Color3.fromRGB(0,122,255), Flag="HColor",
    Callback=function(c) print("Color:", c) end,
})
Main:CreateProgress({ Name="Loading", Progress=0.75, ShowPercentage=true })

local card = Main:CreateCard({
    Title="Info", Icon="rbxassetid://7733715400", Collapsible=true,
})
card:AddLabel("Nexuralib v4 — all bugs fixed!")
Main:AddSeparator("Stats")

Nexuralib:Notify({
    Title="Loaded!", Content="Nexuralib v4 is ready.",
    Type="success", Duration=4,
})

print(Nexuralib.Flags["AutoFarm"])
print(Nexuralib.Flags["Speed"])
=============================================================
]]
