local FrostUI = require(game.ReplicatedStorage.FrostUI)
        local Window = FrostUI:CreateWindow({ Title = "我的脚本", Icon = FrostUI.Icons.Home })
        local Tab = Window:Tab("主页")
        Tab:Button("按钮", function() end, "Info")
        Tab:Toggle("开关", false, function(state) end, "AutoRun")
        Tab:Slider("滑块", 0, 100, 50, function(v) end, "Speed")
        Tab:Textbox("输入框", "", function(t) end, "Name")
        Tab:Dropdown("下拉", {"A","B"}, function(s) end, "Mode")
        Tab:Keybind("快捷键", Enum.KeyCode.F, function() end)
        Tab:ColorPicker("颜色", Color3.new(1,1,1), function(c) end)
        local Group = Tab:Collapsible("分组", true, "Folder")
        Group:Button("分组按钮", function() end, "Star")
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================
-- 主题配置
-- ============================================
local Theme = {
    WindowSize       = UDim2.new(0, 500, 0, 300),
    WindowMinSize    = UDim2.new(0, 500, 0, 40),
    WindowBG         = Color3.fromRGB(22, 22, 26),
    WindowBGTrans    = 0.05,
    WindowCorner     = UDim.new(0, 12),

    StrokeColor      = Color3.fromRGB(255, 255, 255),
    StrokeThickness  = 2,
    StrokeTrans      = 0.55,

    TitleBarHeight   = 40,
    TitleBarBG       = Color3.fromRGB(30, 30, 36),
    TitleTextColor   = Color3.fromRGB(240, 240, 240),
    TitleTextSize    = 16,

    ControlBG        = Color3.fromRGB(35, 35, 42),
    ControlBG2       = Color3.fromRGB(45, 45, 54),
    ControlCorner    = UDim.new(0, 8),
    TextColor        = Color3.fromRGB(235, 235, 235),
    SubTextColor     = Color3.fromRGB(160, 160, 170),

    Accent           = Color3.fromRGB(120, 90, 220),
    Accent2          = Color3.fromRGB(90, 160, 255),
    ToggleOn         = Color3.fromRGB(80, 200, 120),
    ToggleOff        = Color3.fromRGB(70, 70, 80),

    CloseColor       = Color3.fromRGB(220, 70, 70),
    MinColor         = Color3.fromRGB(250, 180, 60),

    Font             = Enum.Font.Gotham,
    FontBold         = Enum.Font.GothamBold,

    OpenTime         = 0.32,
    CloseTime        = 0.22,
    MinTime          = 0.22,
    HoverTime        = 0.12,

    RowHeight        = 36,
    RowPadding       = 6,
    SectionHeight    = 28,
}

local FrostUI = {}
FrostUI.__index = FrostUI
FrostUI.Theme = Theme

-- ============================================
-- 图标库
-- ============================================
FrostUI.Icons = {
    Home        = "rbxassetid://7733710098",
    Settings    = "rbxassetid://7733770599",
    Search      = "rbxassetid://7734053495",
    Close       = "rbxassetid://7733710142",
    Minimize    = "rbxassetid://7734068321",
    Info        = "rbxassetid://7733710336",
    Warning     = "rbxassetid://7733674337",
    Check       = "rbxassetid://7733710081",
    Star        = "rbxassetid://7733968163",
    Heart       = "rbxassetid://7733981389",

    Player      = "rbxassetid://7733968163",
    Sword       = "rbxassetid://7734068321",
    Shield      = "rbxassetid://7733770599",
    Speed       = "rbxassetid://7734053495",
    Fly         = "rbxassetid://7733710336",
    Teleport    = "rbxassetid://7733710098",
    Eye         = "rbxassetid://7733981389",
    Lock        = "rbxassetid://7733710142",
    Key         = "rbxassetid://7733968163",
    Money       = "rbxassetid://7733674337",
    Gift        = "rbxassetid://7733710081",
    Trash       = "rbxassetid://7733710142",
    Plus        = "rbxassetid://7733710081",
    Minus       = "rbxassetid://7733710142",
    Arrow       = "rbxassetid://7734053495",
    Menu        = "rbxassetid://7734068321",
    Folder      = "rbxassetid://7733710098",
    File        = "rbxassetid://7733710336",
    Code        = "rbxassetid://7733770599",
    Bug         = "rbxassetid://7733674337",

    Success     = "rbxassetid://7733710081",
    Error       = "rbxassetid://7733710142",
    Loading     = "rbxassetid://7734068321",
    Refresh     = "rbxassetid://7734053495",
    Save        = "rbxassetid://7733710098",
    Upload      = "rbxassetid://7733710336",
    Download    = "rbxassetid://7733981389",
    Copy        = "rbxassetid://7733710081",
    Paste       = "rbxassetid://7733710142",
    Edit        = "rbxassetid://7733770599",
    Delete      = "rbxassetid://7733710142",
    Add         = "rbxassetid://7733710081",
    Remove      = "rbxassetid://7733710142",
}

function FrostUI:GetIcon(name)
    return self.Icons[name] or self.Icons.Info
end

-- ============================================
-- 配置保存
-- ============================================
FrostUI.Config = {
    _data = {},
    _path = "FrostUI_Config.json",
    _loaded = false,
}

local function safeWriteFile(name, content)
    if writefile then pcall(writefile, name, content) end
end

local function safeReadFile(name)
    if readfile and isfile and isfile(name) then
        local ok, data = pcall(readfile, name)
        if ok then return data end
    end
    return nil
end

function FrostUI.Config:Load()
    if self._loaded then return self._data end
    local raw = safeReadFile(self._path)
    if raw then
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if ok and type(decoded) == "table" then
            self._data = decoded
        end
    end
    self._loaded = true
    return self._data
end

function FrostUI.Config:Save()
    local encoded = HttpService:JSONEncode(self._data)
    safeWriteFile(self._path, encoded)
end

function FrostUI.Config:Set(key, value)
    self._data[key] = value
    self:Save()
end

function FrostUI.Config:Get(key, default)
    if self._data[key] == nil then return default end
    return self._data[key]
end

FrostUI.Config:Load()

-- ============================================
-- 主题预设
-- ============================================
FrostUI.Themes = {
    Dark = {
        WindowBG = Color3.fromRGB(22, 22, 26),
        TitleBarBG = Color3.fromRGB(30, 30, 36),
        ControlBG = Color3.fromRGB(35, 35, 42),
        ControlBG2 = Color3.fromRGB(45, 45, 54),
        TextColor = Color3.fromRGB(235, 235, 235),
        SubTextColor = Color3.fromRGB(160, 160, 170),
        Accent = Color3.fromRGB(120, 90, 220),
        Accent2 = Color3.fromRGB(90, 160, 255),
        ToggleOn = Color3.fromRGB(80, 200, 120),
        ToggleOff = Color3.fromRGB(70, 70, 80),
    },
    Light = {
        WindowBG = Color3.fromRGB(245, 245, 250),
        TitleBarBG = Color3.fromRGB(230, 230, 240),
        ControlBG = Color3.fromRGB(255, 255, 255),
        ControlBG2 = Color3.fromRGB(240, 240, 248),
        TextColor = Color3.fromRGB(30, 30, 40),
        SubTextColor = Color3.fromRGB(110, 110, 120),
        Accent = Color3.fromRGB(100, 80, 220),
        Accent2 = Color3.fromRGB(70, 140, 240),
        ToggleOn = Color3.fromRGB(60, 180, 100),
        ToggleOff = Color3.fromRGB(200, 200, 210),
    },
    Purple = {
        WindowBG = Color3.fromRGB(28, 20, 45),
        TitleBarBG = Color3.fromRGB(38, 26, 60),
        ControlBG = Color3.fromRGB(45, 30, 70),
        ControlBG2 = Color3.fromRGB(60, 40, 90),
        TextColor = Color3.fromRGB(240, 230, 255),
        SubTextColor = Color3.fromRGB(180, 160, 210),
        Accent = Color3.fromRGB(160, 90, 255),
        Accent2 = Color3.fromRGB(200, 130, 255),
        ToggleOn = Color3.fromRGB(120, 220, 160),
        ToggleOff = Color3.fromRGB(90, 70, 120),
    },
}

-- ============================================
-- 工具函数
-- ============================================
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or Theme.ControlCorner
    c.Parent = parent
    return c
end

local function featheredStroke(parent, thickness, transparency, color)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.StrokeColor
    stroke.Thickness = thickness or Theme.StrokeThickness
    stroke.Transparency = transparency or Theme.StrokeTrans
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = parent

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.6),
        NumberSequenceKeypoint.new(0.5, 0.0),
        NumberSequenceKeypoint.new(1.0, 0.6),
    })
    grad.Parent = stroke

    return stroke
end

local function makeDraggable(dragTarget, moveTarget)
    local dragging = false
    local dragStart, startPos
    local conn

    dragTarget.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = moveTarget.Position

            if conn then conn:Disconnect() end
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            moveTarget.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function tween(obj, time, props)
    local t = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- ============================================
-- 创建窗口
-- ============================================
function FrostUI:CreateWindow(config)
    config = config or {}
    local title = config.Title or "FrostUI"
    local subtitle = config.Subtitle or ""

    local self = setmetatable({}, FrostUI)

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "FrostUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.Parent = PlayerGui

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.BackgroundColor3 = Theme.WindowBG
    Main.BackgroundTransparency = Theme.WindowBGTrans
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = self.ScreenGui
    self.Main = Main

    corner(Main, Theme.WindowCorner)
    self.MainStroke = featheredStroke(Main, Theme.StrokeThickness, Theme.StrokeTrans, Theme.StrokeColor)

    -- 标题栏
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, Theme.TitleBarHeight)
    TitleBar.BackgroundColor3 = Theme.TitleBarBG
    TitleBar.BackgroundTransparency = 0.1
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Main
    corner(TitleBar, Theme.WindowCorner)

    local TitleMask = Instance.new("Frame")
    TitleMask.AnchorPoint = Vector2.new(0, 1)
    TitleMask.Position = UDim2.new(0, 0, 1, 0)
    TitleMask.Size = UDim2.new(1, 0, 0, 12)
    TitleMask.BackgroundColor3 = Theme.TitleBarBG
    TitleMask.BackgroundTransparency = 0.1
    TitleMask.BorderSizePixel = 0
    TitleMask.Parent = TitleBar

    -- 标题图标
    local TitleIcon = Instance.new("ImageLabel")
    TitleIcon.Name = "TitleIcon"
    TitleIcon.AnchorPoint = Vector2.new(0, 0.5)
    TitleIcon.Position = UDim2.new(0, 12, 0.5, 0)
    TitleIcon.Size = UDim2.new(0, 22, 0, 22)
    TitleIcon.BackgroundTransparency = 1
    TitleIcon.Image = config.Icon or FrostUI.Icons.Info
    TitleIcon.Parent = TitleBar
    self.TitleIcon = TitleIcon

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -140, 1, 0)
    TitleLabel.Position = UDim2.new(0, 42, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Theme.TitleTextColor
    TitleLabel.TextSize = Theme.TitleTextSize
    TitleLabel.Font = Theme.FontBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    self.TitleLabel = TitleLabel

    if subtitle ~= "" then
        local Sub = Instance.new("TextLabel")
        Sub.Size = UDim2.new(1, -140, 1, 0)
        Sub.Position = UDim2.new(0, 42, 0, 0)
        Sub.BackgroundTransparency = 1
        Sub.Text = subtitle
        Sub.TextColor3 = Theme.SubTextColor
        Sub.TextSize = 11
        Sub.Font = Theme.Font
        Sub.TextXAlignment = Enum.TextXAlignment.Right
        Sub.Parent = TitleBar
    end

    -- 关闭按钮
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.AnchorPoint = Vector2.new(1, 0.5)
    CloseBtn.Position = UDim2.new(1, -10, 0.5, 0)
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.BackgroundColor3 = Theme.CloseColor
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.TextSize = 18
    CloseBtn.Font = Theme.FontBold
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = TitleBar
    corner(CloseBtn, UDim.new(1, 0))

    -- 最小化按钮
    local MinBtn = Instance.new("TextButton")
    MinBtn.AnchorPoint = Vector2.new(1, 0.5)
    MinBtn.Position = UDim2.new(1, -42, 0.5, 0)
    MinBtn.Size = UDim2.new(0, 26, 0, 26)
    MinBtn.BackgroundColor3 = Theme.MinColor
    MinBtn.BorderSizePixel = 0
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Color3.new(1, 1, 1)
    MinBtn.TextSize = 16
    MinBtn.Font = Theme.FontBold
    MinBtn.AutoButtonColor = false
    MinBtn.Parent = TitleBar
    corner(MinBtn, UDim.new(1, 0))

    -- 内容
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Position = UDim2.new(0, 0, 0, Theme.TitleBarHeight)
    Content.Size = UDim2.new(1, 0, 1, -Theme.TitleBarHeight)
    Content.BackgroundTransparency = 1
    Content.Parent = Main
    self.Content = Content

    -- 侧边栏（ScrollingFrame）
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 120, 1, 0)
    Sidebar.BackgroundColor3 = Theme.ControlBG
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 3
    Sidebar.ScrollBarImageColor3 = Theme.Accent
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    Sidebar.Parent = Content
    self.Sidebar = Sidebar

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Padding = UDim.new(0, 4)
    SidebarLayout.Parent = Sidebar

    local SidebarPad = Instance.new("UIPadding")
    SidebarPad.PaddingTop = UDim.new(0, 8)
    SidebarPad.PaddingLeft = UDim.new(0, 6)
    SidebarPad.PaddingRight = UDim.new(0, 6)
    SidebarPad.PaddingBottom = UDim.new(0, 8)
    SidebarPad.Parent = Sidebar

    -- 页面容器
    local Pages = Instance.new("Frame")
    Pages.Name = "Pages"
    Pages.Position = UDim2.new(0, 120, 0, 0)
    Pages.Size = UDim2.new(1, -120, 1, 0)
    Pages.BackgroundTransparency = 1
    Pages.Parent = Content
    self.Pages = Pages

    makeDraggable(TitleBar, Main)

    self.Tabs = {}
    self.CurrentTab = nil
    self.IsMinimized = false
    self.Config = config
    self._notifies = {}

    Main.Size = UDim2.new(0, 0, 0, 0)
    tween(Main, Theme.OpenTime, { Size = Theme.WindowSize })

    CloseBtn.MouseButton1Click:Connect(function() self:Close() end)
    MinBtn.MouseButton1Click:Connect(function() self:Minimize() end)

    self:_createPill(title)

    return self
end

-- ============================================
-- 最小化胶囊
-- ============================================
function FrostUI:_createPill(title)
    local Pill = Instance.new("TextButton")
    Pill.Name = "Pill"
    Pill.AnchorPoint = Vector2.new(0.5, 0.5)
    Pill.Position = UDim2.new(0.5, 0, 0.5, 0)
    Pill.Size = UDim2.new(0, 0, 0, 0)
    Pill.BackgroundColor3 = Theme.WindowBG
    Pill.BackgroundTransparency = 0.1
    Pill.BorderSizePixel = 0
    Pill.Text = ""
    Pill.AutoButtonColor = false
    Pill.Visible = false
    Pill.Parent = self.ScreenGui
    corner(Pill, UDim.new(1, 0))
    featheredStroke(Pill, 2, 0.5, Theme.StrokeColor)

    local Drag = Instance.new("TextLabel")
    Drag.AnchorPoint = Vector2.new(0, 0.5)
    Drag.Position = UDim2.new(0, 12, 0.5, 0)
    Drag.Size = UDim2.new(0, 24, 0, 24)
    Drag.BackgroundTransparency = 1
    Drag.Text = "✥"
    Drag.TextColor3 = Color3.fromRGB(180, 180, 190)
    Drag.TextSize = 18
    Drag.Font = Theme.FontBold
    Drag.Parent = Pill

    local PillTitle = Instance.new("TextLabel")
    PillTitle.AnchorPoint = Vector2.new(0, 0.5)
    PillTitle.Position = UDim2.new(0, 44, 0.5, 0)
    PillTitle.Size = UDim2.new(1, -56, 1, 0)
    PillTitle.BackgroundTransparency = 1
    PillTitle.Text = title
    PillTitle.TextColor3 = Theme.TextColor
    PillTitle.TextSize = 15
    PillTitle.Font = Theme.FontBold
    PillTitle.TextXAlignment = Enum.TextXAlignment.Left
    PillTitle.TextTruncate = Enum.TextTruncate.AtEnd
    PillTitle.Parent = Pill

    makeDraggable(Pill, Pill)

    Pill.MouseButton1Click:Connect(function()
        if self.IsMinimized then self:Minimize() end
    end)

    self.Pill = Pill
    self.PillTitle = PillTitle
end

-- ============================================
-- 窗口方法
-- ============================================
function FrostUI:SetTitle(text)
    self.TitleLabel.Text = text
    self.PillTitle.Text = text
end

function FrostUI:Close()
    local ti = TweenInfo.new(Theme.CloseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(self.Main, ti, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    }):Play()

    task.delay(Theme.CloseTime, function()
        self.ScreenGui:Destroy()
    end)
end

function FrostUI:Minimize()
    if not self.IsMinimized then
        self.IsMinimized = true
        self.Pill.Position = self.Main.Position
        self.Pill.Size = UDim2.new(0, 0, 0, 0)
        self.Pill.BackgroundTransparency = 1
        self.Pill.Visible = true

        tween(self.Pill, Theme.MinTime, {
            Size = UDim2.new(0, 240, 0, 48),
            BackgroundTransparency = 0.1,
        })
        tween(self.PillTitle, Theme.MinTime, { TextTransparency = 0 })
        tween(self.Main, Theme.MinTime, { Size = UDim2.new(0, 0, 0, 0) })

        task.delay(Theme.MinTime, function()
            self.Main.Visible = false
        end)
    else
        self.IsMinimized = false
        self.Main.Visible = true
        self.Main.Position = self.Pill.Position
        self.Main.Size = UDim2.new(0, 0, 0, 0)
        self.Main.BackgroundTransparency = 1

        tween(self.Main, Theme.MinTime, {
            Size = Theme.WindowSize,
            BackgroundTransparency = Theme.WindowBGTrans,
        })
        tween(self.Pill, Theme.MinTime, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
        })

        task.delay(Theme.MinTime, function()
            self.Pill.Visible = false
        end)
    end
end

-- ============================================
-- 通知系统
-- ============================================
function FrostUI:Notify(config)
    config = config or {}
    local title = config.Title or "通知"
    local text = config.Text or ""
    local duration = config.Duration or 3
    local icon = config.Icon or nil

    local holder = Instance.new("Frame")
    holder.Name = "NotifyHolder"
    holder.AnchorPoint = Vector2.new(1, 0)
    holder.Position = UDim2.new(1, -16, 0, 16 + (#self._notifies) * 72)
    holder.Size = UDim2.new(0, 300, 0, 64)
    holder.BackgroundColor3 = Theme.WindowBG
    holder.BackgroundTransparency = 0.1
    holder.BorderSizePixel = 0
    holder.ClipsDescendants = true
    holder.Parent = self.ScreenGui
    corner(holder, UDim.new(0, 10))
    featheredStroke(holder, 2, 0.5, Theme.StrokeColor)

    if icon then
        local img = Instance.new("ImageLabel")
        img.AnchorPoint = Vector2.new(0, 0.5)
        img.Position = UDim2.new(0, 10, 0.5, 0)
        img.Size = UDim2.new(0, 40, 0, 40)
        img.BackgroundTransparency = 1
        img.Image = icon
        img.Parent = holder
        corner(img, UDim.new(0, 8))
    end

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Position = UDim2.new(0, icon and 58 or 14, 0, 8)
    titleLbl.Size = UDim2.new(1, icon and -70 or -24, 0, 20)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Theme.TextColor
    titleLbl.TextSize = 14
    titleLbl.Font = Theme.FontBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = holder

    local textLbl = Instance.new("TextLabel")
    textLbl.Position = UDim2.new(0, icon and 58 or 14, 0, 30)
    textLbl.Size = UDim2.new(1, icon and -70 or -24, 0, 26)
    textLbl.BackgroundTransparency = 1
    textLbl.Text = text
    textLbl.TextColor3 = Theme.SubTextColor
    textLbl.TextSize = 12
    textLbl.Font = Theme.Font
    textLbl.TextXAlignment = Enum.TextXAlignment.Left
    textLbl.TextWrapped = true
    textLbl.Parent = holder

    local bar = Instance.new("Frame")
    bar.AnchorPoint = Vector2.new(0, 1)
    bar.Position = UDim2.new(0, 0, 1, 0)
    bar.Size = UDim2.new(1, 0, 0, 3)
    bar.BackgroundColor3 = Theme.Accent
    bar.BorderSizePixel = 0
    bar.Parent = holder

    table.insert(self._notifies, holder)

    holder.Position = UDim2.new(1, 20, 0, 16 + (#self._notifies - 1) * 72)
    tween(holder, 0.3, {
        Position = UDim2.new(1, -16, 0, 16 + (#self._notifies - 1) * 72)
    })
    tween(bar, duration, { Size = UDim2.new(0, 0, 0, 3) })

    task.delay(duration, function()
        local ti = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(holder, ti, {
            Position = UDim2.new(1, 20, 0, holder.Position.Y.Offset),
            BackgroundTransparency = 1,
        }):Play()

        task.delay(0.3, function()
            holder:Destroy()
            for i, n in ipairs(self._notifies) do
                if n == holder then
                    table.remove(self._notifies, i)
                    break
                end
            end
            for i, n in ipairs(self._notifies) do
                tween(n, 0.2, {
                    Position = UDim2.new(1, -16, 0, 16 + (i - 1) * 72)
                })
            end
        end)
    end)

    return holder
end

-- ============================================
-- 主题切换
-- ============================================
function FrostUI:SetTheme(themeName)
    local preset = FrostUI.Themes[themeName]
    if not preset then return end

    for k, v in pairs(preset) do
        Theme[k] = v
    end

    if self.Main then self.Main.BackgroundColor3 = Theme.WindowBG end
    if self.TitleLabel then self.TitleLabel.TextColor3 = Theme.TextColor end
    if self.Pill then self.Pill.BackgroundColor3 = Theme.WindowBG end
    if self.PillTitle then self.PillTitle.TextColor3 = Theme.TextColor end

    self:Notify({
        Title = "主题切换",
        Text = "当前主题：" .. themeName,
        Duration = 2,
    })
end

-- ============================================
-- 搜索框
-- ============================================
function FrostUI:EnableSearch()
    if self._searchEnabled then return end
    self._searchEnabled = true

    local searchFrame = Instance.new("Frame")
    searchFrame.Name = "SearchFrame"
    searchFrame.Size = UDim2.new(1, -12, 0, 32)
    searchFrame.Position = UDim2.new(0, 6, 0, 6)
    searchFrame.BackgroundColor3 = Theme.ControlBG
    searchFrame.BackgroundTransparency = 0.2
    searchFrame.BorderSizePixel = 0
    searchFrame.Parent = self.Pages
    corner(searchFrame, Theme.ControlCorner)

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -20, 1, 0)
    searchBox.Position = UDim2.new(0, 10, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.Text = ""
    searchBox.PlaceholderText = "🔍 搜索功能..."
    searchBox.PlaceholderColor3 = Theme.SubTextColor
    searchBox.TextColor3 = Theme.TextColor
    searchBox.TextSize = 13
    searchBox.Font = Theme.Font
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = searchFrame

    for _, tab in ipairs(self.Tabs) do
        tab.Page.Position = UDim2.new(0, 6, 0, 44)
        tab.Page.Size = UDim2.new(1, -12, 1, -50)
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchBox.Text:lower()
        local currentPage = self.CurrentTab and self.CurrentTab.Page
        if not currentPage then return end

        for _, child in ipairs(currentPage:GetChildren()) do
            if child:IsA("GuiObject") and not child:IsA("UIListLayout")
                and not child:IsA("UIPadding") then
                local isMatch = false
                if child:IsA("TextButton") or child:IsA("TextLabel")
                    or child:IsA("TextBox") then
                    if child.Text:lower():find(query, 1, true) then isMatch = true end
                end
                if child:IsA("Frame") then
                    for _, sub in ipairs(child:GetDescendants()) do
                        if sub:IsA("TextLabel") or sub:IsA("TextButton")
                            or sub:IsA("TextBox") then
                            if sub.Text:lower():find(query, 1, true) then
                                isMatch = true
                                break
                            end
                        end
                    end
                end
                child.Visible = (query == "" or isMatch)
            end
        end
    end)

    self._searchBox = searchBox
end

-- ============================================
-- 多窗口
-- ============================================
FrostUI._windows = {}

function FrostUI:CreateFloatingWindow(config)
    local win = self:CreateWindow(config)
    table.insert(FrostUI._windows, win)
    return win
end

function FrostUI:CloseAll()
    for _, win in ipairs(FrostUI._windows) do
        pcall(function() win:Close() end)
    end
    table.clear(FrostUI._windows)
end

-- ============================================
-- 创建标签页
-- ============================================
function FrostUI:Tab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 34)
    tabBtn.BackgroundColor3 = Theme.ControlBG2
    tabBtn.BackgroundTransparency = 0.4
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = name
    tabBtn.TextColor3 = Theme.TextColor
    tabBtn.TextSize = 13
    tabBtn.Font = Theme.Font
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = self.Sidebar
    corner(tabBtn, Theme.ControlCorner)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -12, 1, -12)
    page.Position = UDim2.new(0, 6, 0, 6)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Theme.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = self.Pages

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = page

    local tabObj = {
        Button = tabBtn,
        Page = page,
        Layout = layout,
        Name = name,
        Window = self,
    }
    tabObj._window = self

    local function select()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            tween(t.Button, Theme.HoverTime, {
                BackgroundTransparency = 0.4,
                TextColor3 = Theme.TextColor,
            })
        end
        page.Visible = true
        tween(tabBtn, Theme.HoverTime, {
            BackgroundTransparency = 0,
            TextColor3 = Theme.Accent2,
        })
        self.CurrentTab = tabObj
    end

    tabBtn.MouseButton1Click:Connect(select)
    tabBtn.MouseEnter:Connect(function()
        if self.CurrentTab ~= tabObj then
            tween(tabBtn, Theme.HoverTime, { BackgroundTransparency = 0.2 })
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self.CurrentTab ~= tabObj then
            tween(tabBtn, Theme.HoverTime, { BackgroundTransparency = 0.4 })
        end
    end)

    table.insert(self.Tabs, tabObj)
    if #self.Tabs == 1 then select() end

    -- ===== Label =====
    function tabObj:Label(text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 22)
        lbl.BackgroundTransparency = 1
        lbl.Text = "  " .. text
        lbl.TextColor3 = Theme.SubTextColor
        lbl.TextSize = 13
        lbl.Font = Theme.Font
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = page
        return lbl
    end

    -- ===== Section =====
    function tabObj:Section(text)
        local sec = Instance.new("TextLabel")
        sec.Size = UDim2.new(1, 0, 0, Theme.SectionHeight)
        sec.BackgroundColor3 = Theme.ControlBG
        sec.BackgroundTransparency = 0.5
        sec.BorderSizePixel = 0
        sec.Text = "  " .. text
        sec.TextColor3 = Theme.Accent2
        sec.TextSize = 13
        sec.Font = Theme.FontBold
        sec.TextXAlignment = Enum.TextXAlignment.Left
        sec.Parent = page
        corner(sec, Theme.ControlCorner)
        return sec
    end

    -- ===== Button =====
    function tabObj:Button(text, callback, iconName)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
        btn.BackgroundColor3 = Theme.ControlBG
        btn.BackgroundTransparency = 0.2
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = page
        corner(btn, Theme.ControlCorner)

        local stroke = Instance.new("UIStroke")
        stroke.Color = Theme.StrokeColor
        stroke.Thickness = 1
        stroke.Transparency = 0.85
        stroke.Parent = btn

        local textX = 12
        if iconName then
            local icon = Instance.new("ImageLabel")
            icon.AnchorPoint = Vector2.new(0, 0.5)
            icon.Position = UDim2.new(0, 10, 0.5, 0)
            icon.Size = UDim2.new(0, 20, 0, 20)
            icon.BackgroundTransparency = 1
            icon.Image = FrostUI.Icons[iconName] or FrostUI.Icons.Info
            icon.Parent = btn
            textX = 38
        end

        local lbl = Instance.new("TextLabel")
        lbl.Position = UDim2.new(0, textX, 0, 0)
        lbl.Size = UDim2.new(1, -textX - 10, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Theme.TextColor
        lbl.TextSize = 14
        lbl.Font = Theme.Font
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = btn

        btn.MouseEnter:Connect(function()
            tween(btn, Theme.HoverTime, { BackgroundTransparency = 0, BackgroundColor3 = Theme.ControlBG2 })
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, Theme.HoverTime, { BackgroundTransparency = 0.2, BackgroundColor3 = Theme.ControlBG })
        end)
        btn.MouseButton1Click:Connect(function()
            tween(btn, 0.08, { BackgroundColor3 = Theme.Accent })
            task.delay(0.1, function()
                tween(btn, 0.12, { BackgroundColor3 = Theme.ControlBG2 })
            end)
            if callback then callback() end
        end)
        return btn
    end

    -- ===== Toggle =====
    function tabObj:Toggle(text, default, callback, flag)
        if flag then default = FrostUI.Config:Get(flag, default) end
        local state = default or false

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
        row.BackgroundColor3 = Theme.ControlBG
        row.BackgroundTransparency = 0.2
        row.BorderSizePixel = 0
        row.Parent = page
        corner(row, Theme.ControlCorner)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -70, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Theme.TextColor
        label.TextSize = 14
        label.Font = Theme.Font
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = row

        local switch = Instance.new("Frame")
        switch.AnchorPoint = Vector2.new(1, 0.5)
        switch.Position = UDim2.new(1, -10, 0.5, 0)
        switch.Size = UDim2.new(0, 44, 0, 22)
        switch.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
        switch.BorderSizePixel = 0
        switch.Parent = row
        corner(switch, UDim.new(1, 0))

        local knob = Instance.new("Frame")
        knob.AnchorPoint = Vector2.new(0, 0.5)
        knob.Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.BorderSizePixel = 0
        knob.Parent = switch
        corner(knob, UDim.new(1, 0))

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = row

        local function setState(v)
            state = v
            tween(switch, 0.15, { BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff })
            tween(knob, 0.15, {
                Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            })
            if flag then FrostUI.Config:Set(flag, state) end
            if callback then callback(state) end
        end

        btn.MouseButton1Click:Connect(function() setState(not state) end)
        return { Set = setState, Get = function() return state end, Frame = row }
    end

    -- ===== Slider =====
    function tabObj:Slider(text, min, max, default, callback, flag)
        if flag then default = FrostUI.Config:Get(flag, default) end
        min = min or 0
        max = max or 100
        default = default or min

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 46)
        row.BackgroundColor3 = Theme.ControlBG
        row.BackgroundTransparency = 0.2
        row.BorderSizePixel = 0
        row.Parent = page
        corner(row, Theme.ControlCorner)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 0, 20)
        label.Position = UDim2.new(0, 12, 0, 4)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Theme.TextColor
        label.TextSize = 13
        label.Font = Theme.Font
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = row

        local valueLabel = Instance.new("TextLabel")
        valueLabel.AnchorPoint = Vector2.new(1, 0)
        valueLabel.Position = UDim2.new(1, -10, 0, 4)
        valueLabel.Size = UDim2.new(0, 50, 0, 20)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default)
        valueLabel.TextColor3 = Theme.Accent2
        valueLabel.TextSize = 13
        valueLabel.Font = Theme.FontBold
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = row

        local barBg = Instance.new("Frame")
        barBg.AnchorPoint = Vector2.new(0, 1)
        barBg.Position = UDim2.new(0, 12, 1, -10)
        barBg.Size = UDim2.new(1, -24, 0, 8)
        barBg.BackgroundColor3 = Theme.ControlBG2
        barBg.BorderSizePixel = 0
        barBg.Parent = row
        corner(barBg, UDim.new(1, 0))

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = Theme.Accent
        fill.BorderSizePixel = 0
        fill.Parent = barBg
        corner(fill, UDim.new(1, 0))

        local knob = Instance.new("Frame")
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(0, 0, 0.5, 0)
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.BorderSizePixel = 0
        knob.Parent = barBg
        corner(knob, UDim.new(1, 0))

        local value = default
        local function updateFromX(x)
            local rel = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * rel
            value = math.floor(value * 100) / 100
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, 0, 0.5, 0)
            valueLabel.Text = tostring(value)
            if flag then FrostUI.Config:Set(flag, value) end
            if callback then callback(value) end
        end

        local dragging = false
        barBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateFromX(input.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                updateFromX(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        local initRel = (default - min) / (max - min)
        fill.Size = UDim2.new(initRel, 0, 1, 0)
        knob.Position = UDim2.new(initRel, 0, 0.5, 0)

        return {
            Set = function(v)
                value = math.clamp(v, min, max)
                local rel = (value - min) / (max - min)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                knob.Position = UDim2.new(rel, 0, 0.5, 0)
                valueLabel.Text = tostring(value)
                if flag then FrostUI.Config:Set(flag, value) end
                if callback then callback(value) end
            end,
            Get = function() return value end,
            Frame = row,
        }
    end

    -- ===== Textbox =====
    function tabObj:Textbox(placeholder, default, callback, flag)
        if flag then default = FrostUI.Config:Get(flag, default) end
        default = default or ""

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
        box.BackgroundColor3 = Theme.ControlBG
        box.BackgroundTransparency = 0.2
        box.BorderSizePixel = 0
        box.Text = default
        box.PlaceholderText = placeholder or "输入..."
        box.PlaceholderColor3 = Theme.SubTextColor
        box.TextColor3 = Theme.TextColor
        box.TextSize = 14
        box.Font = Theme.Font
        box.ClearTextOnFocus = false
        box.Parent = page
        corner(box, Theme.ControlCorner)

        local stroke = Instance.new("UIStroke")
        stroke.Color = Theme.StrokeColor
        stroke.Thickness = 1
        stroke.Transparency = 0.85
        stroke.Parent = box

        box.Focused:Connect(function()
            tween(stroke, 0.1, { Transparency = 0.3, Color = Theme.Accent2 })
        end)
        box.FocusLost:Connect(function()
            tween(stroke, 0.1, { Transparency = 0.85, Color = Theme.StrokeColor })
            if flag then FrostUI.Config:Set(flag, box.Text) end
            if callback then callback(box.Text) end
        end)
        return box
    end

    -- ===== Dropdown =====
    function tabObj:Dropdown(text, options, callback, flag)
        options = options or {}
        local selected = flag and FrostUI.Config:Get(flag, nil) or nil
        local expanded = false

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
        container.BackgroundTransparency = 1
        container.ClipsDescendants = true
        container.Parent = page

        local header = Instance.new("TextButton")
        header.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
        header.BackgroundColor3 = Theme.ControlBG
        header.BackgroundTransparency = 0.2
        header.BorderSizePixel = 0
        header.Text = "  " .. text .. (selected and (": " .. selected) or " ▼")
        header.TextColor3 = Theme.TextColor
        header.TextSize = 14
        header.Font = Theme.Font
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.AutoButtonColor = false
        header.Parent = container
        corner(header, Theme.ControlCorner)

        local list = Instance.new("Frame")
        list.Size = UDim2.new(1, 0, 0, 0)
        list.Position = UDim2.new(0, 0, 0, Theme.RowHeight + 4)
        list.BackgroundColor3 = Theme.ControlBG
        list.BackgroundTransparency = 0.1
        list.BorderSizePixel = 0
        list.Visible = false
        list.Parent = container
        corner(list, Theme.ControlCorner)

        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = list

        local listPad = Instance.new("UIPadding")
        listPad.PaddingTop = UDim.new(0, 4)
        listPad.PaddingBottom = UDim.new(0, 4)
        listPad.PaddingLeft = UDim.new(0, 4)
        listPad.PaddingRight = UDim.new(0, 4)
        listPad.Parent = list

        local function refresh()
            for _, child in ipairs(list:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            for _, opt in ipairs(options) do
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, 26)
                item.BackgroundColor3 = Theme.ControlBG2
                item.BackgroundTransparency = 0.4
                item.BorderSizePixel = 0
                item.Text = "  " .. opt
                item.TextColor3 = Theme.TextColor
                item.TextSize = 13
                item.Font = Theme.Font
                item.TextXAlignment = Enum.TextXAlignment.Left
                item.AutoButtonColor = false
                item.Parent = list
                corner(item, UDim.new(0, 6))

                item.MouseEnter:Connect(function()
                    tween(item, 0.1, { BackgroundTransparency = 0.1 })
                end)
                item.MouseLeave:Connect(function()
                    tween(item, 0.1, { BackgroundTransparency = 0.4 })
                end)
                item.MouseButton1Click:Connect(function()
                    selected = opt
                    header.Text = "  " .. text .. ": " .. opt
                    if flag then FrostUI.Config:Set(flag, opt) end
                    if callback then callback(opt) end
                    expanded = false
                    list.Visible = false
                    container.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
                    header.Text = header.Text:gsub(" ▲", " ▼")
                end)
            end
            list.Size = UDim2.new(1, 0, 0, #options * 28 + 8)
        end
        refresh()

        header.MouseButton1Click:Connect(function()
            expanded = not expanded
            list.Visible = expanded
            if expanded then
                container.Size = UDim2.new(1, 0, 0, Theme.RowHeight + list.Size.Y.Offset + 4)
                header.Text = header.Text:gsub(" ▼", " ▲")
            else
                container.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
                header.Text = header.Text:gsub(" ▲", " ▼")
            end
        end)

        return {
            SetOptions = function(newOptions)
                options = newOptions
                refresh()
            end,
            Get = function() return selected end,
            Frame = container,
        }
    end

    -- ===== Keybind =====
    function tabObj:Keybind(text, defaultKey, callback)
        defaultKey = defaultKey or Enum.KeyCode.F
        local currentKey = defaultKey
        local listening = false

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
        row.BackgroundColor3 = Theme.ControlBG
        row.BackgroundTransparency = 0.2
        row.BorderSizePixel = 0
        row.Parent = page
        corner(row, Theme.ControlCorner)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -100, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Theme.TextColor
        label.TextSize = 14
        label.Font = Theme.Font
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = row

        local keyBtn = Instance.new("TextButton")
        keyBtn.AnchorPoint = Vector2.new(1, 0.5)
        keyBtn.Position = UDim2.new(1, -10, 0.5, 0)
        keyBtn.Size = UDim2.new(0, 70, 0, 24)
        keyBtn.BackgroundColor3 = Theme.ControlBG2
        keyBtn.BorderSizePixel = 0
        keyBtn.Text = currentKey.Name
        keyBtn.TextColor3 = Theme.Accent2
        keyBtn.TextSize = 13
        keyBtn.Font = Theme.FontBold
        keyBtn.AutoButtonColor = false
        keyBtn.Parent = row
        corner(keyBtn, UDim.new(0, 6))

        keyBtn.MouseButton1Click:Connect(function()
            listening = true
            keyBtn.Text = "..."
            keyBtn.TextColor3 = Theme.Accent
        end)

        local inputConn
        inputConn = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    keyBtn.Text = currentKey.Name
                    keyBtn.TextColor3 = Theme.Accent2
                    listening = false
                end
            else
                if input.KeyCode == currentKey then
                    if callback then callback() end
                end
            end
        end)

        return {
            Set = function(key)
                currentKey = key
                keyBtn.Text = key.Name
            end,
            Get = function() return currentKey end,
            Frame = row,
            Destroy = function()
                if inputConn then inputConn:Disconnect() end
                row:Destroy()
            end,
        }
    end

    -- ===== ColorPicker =====
    function tabObj:ColorPicker(text, defaultColor, callback)
        defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
        local currentColor = defaultColor

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 44)
        row.BackgroundColor3 = Theme.ControlBG
        row.BackgroundTransparency = 0.2
        row.BorderSizePixel = 0
        row.Parent = page
        corner(row, Theme.ControlCorner)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -80, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Theme.TextColor
        label.TextSize = 14
        label.Font = Theme.Font
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = row

        local preview = Instance.new("Frame")
        preview.AnchorPoint = Vector2.new(1, 0.5)
        preview.Position = UDim2.new(1, -10, 0.5, 0)
        preview.Size = UDim2.new(0, 50, 0, 28)
        preview.BackgroundColor3 = currentColor
        preview.BorderSizePixel = 0
        preview.Parent = row
        corner(preview, UDim.new(0, 6))

        local previewStroke = Instance.new("UIStroke")
        previewStroke.Color = Color3.new(1, 1, 1)
        previewStroke.Thickness = 1
        previewStroke.Transparency = 0.6
        previewStroke.Parent = preview

        local popup = Instance.new("Frame")
        popup.Name = "ColorPopup"
        popup.AnchorPoint = Vector2.new(1, 0)
        popup.Size = UDim2.new(0, 220, 0, 180)
        popup.BackgroundColor3 = Theme.WindowBG
        popup.BackgroundTransparency = 0.05
        popup.BorderSizePixel = 0
        popup.Visible = false
        popup.ZIndex = 50
        popup.Parent = self._window.ScreenGui
        corner(popup, UDim.new(0, 10))
        featheredStroke(popup, 2, 0.4, Theme.StrokeColor)

        local satVal = Instance.new("Frame")
        satVal.Size = UDim2.new(1, -20, 0, 120)
        satVal.Position = UDim2.new(0, 10, 0, 10)
        satVal.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        satVal.BorderSizePixel = 0
        satVal.Parent = popup
        corner(satVal, UDim.new(0, 6))

        local whiteGrad = Instance.new("UIGradient")
        whiteGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        whiteGrad.Parent = satVal

        local blackOverlay = Instance.new("Frame")
        blackOverlay.Size = UDim2.new(1, 0, 1, 0)
        blackOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
        blackOverlay.BorderSizePixel = 0
        blackOverlay.Parent = satVal
        corner(blackOverlay, UDim.new(0, 6))

        local blackGrad = Instance.new("UIGradient")
        blackGrad.Rotation = 90
        blackGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        blackGrad.Parent = blackOverlay

        local hueBar = Instance.new("Frame")
        hueBar.Position = UDim2.new(0, 10, 0, 138)
        hueBar.Size = UDim2.new(1, -20, 0, 16)
        hueBar.BackgroundColor3 = Color3.new(1, 1, 1)
        hueBar.BorderSizePixel = 0
        hueBar.Parent = popup
        corner(hueBar, UDim.new(0, 6))

        local hueGrad = Instance.new("UIGradient")
        hueGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
        })
        hueGrad.Parent = hueBar

        local function updateHue()
            local h = select(1, currentColor:ToHSV())
            satVal.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        end

        local dragging = false
        satVal.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local relX = math.clamp((input.Position.X - satVal.AbsolutePosition.X) / satVal.AbsoluteSize.X, 0, 1)
                local relY = math.clamp((input.Position.Y - satVal.AbsolutePosition.Y) / satVal.AbsoluteSize.Y, 0, 1)
                local h = select(1, currentColor:ToHSV())
                currentColor = Color3.fromHSV(h, relX, 1 - relY)
                preview.BackgroundColor3 = currentColor
                if callback then callback(currentColor) end
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                local relX = math.clamp((input.Position.X - satVal.AbsolutePosition.X) / satVal.AbsoluteSize.X, 0, 1)
                local relY = math.clamp((input.Position.Y - satVal.AbsolutePosition.Y) / satVal.AbsoluteSize.Y, 0, 1)
                local h = select(1, currentColor:ToHSV())
                currentColor = Color3.fromHSV(h, relX, 1 - relY)
                preview.BackgroundColor3 = currentColor
                if callback then callback(currentColor) end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        local hDragging = false
        hueBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                hDragging = true
                local rel = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                local s, v = select(2, currentColor:ToHSV()), select(3, currentColor:ToHSV())
                currentColor = Color3.fromHSV(rel, s, v)
                preview.BackgroundColor3 = currentColor
                updateHue()
                if callback then callback(currentColor) end
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if hDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                local rel = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                local s, v = select(2, currentColor:ToHSV()), select(3, currentColor:ToHSV())
                currentColor = Color3.fromHSV(rel, s, v)
                preview.BackgroundColor3 = currentColor
                if callback then callback(currentColor) end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                hDragging = false
            end
        end)

        preview.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                popup.Visible = not popup.Visible
                if popup.Visible then
                    popup.Position = UDim2.new(
                        1, -10,
                        0, row.AbsolutePosition.Y - self._window.Main.AbsolutePosition.Y - popup.Size.Y.Offset - 4
                    )
                    updateHue()
                end
            end
        end)

        updateHue()

        return {
            Set = function(c)
                currentColor = c
                preview.BackgroundColor3 = c
                updateHue()
                if callback then callback(c) end
            end,
            Get = function() return currentColor end,
            Frame = row,
        }
    end

    -- ===== Collapsible =====
    function tabObj:Collapsible(name, defaultOpen, iconName)
        defaultOpen = defaultOpen ~= false

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, Theme.SectionHeight)
        container.BackgroundColor3 = Theme.ControlBG
        container.BackgroundTransparency = 0.3
        container.BorderSizePixel = 0
        container.ClipsDescendants = true
        container.Parent = page
        corner(container, Theme.ControlCorner)

        local header = Instance.new("TextButton")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, Theme.SectionHeight)
        header.BackgroundTransparency = 1
        header.Text = ""
        header.AutoButtonColor = false
        header.Parent = container

        local iconX = 10
        if iconName then
            local icon = Instance.new("ImageLabel")
            icon.AnchorPoint = Vector2.new(0, 0.5)
            icon.Position = UDim2.new(0, 10, 0.5, 0)
            icon.Size = UDim2.new(0, 18, 0, 18)
            icon.BackgroundTransparency = 1
            icon.Image = FrostUI.Icons[iconName] or FrostUI.Icons.Folder
            icon.Parent = header
            iconX = 34
        end

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Position = UDim2.new(0, iconX, 0, 0)
        titleLbl.Size = UDim2.new(1, -iconX - 30, 1, 0)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = name
        titleLbl.TextColor3 = Theme.Accent2
        titleLbl.TextSize = 13
        titleLbl.Font = Theme.FontBold
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Parent = header

        local arrow = Instance.new("TextLabel")
        arrow.AnchorPoint = Vector2.new(1, 0.5)
        arrow.Position = UDim2.new(1, -10, 0.5, 0)
        arrow.Size = UDim2.new(0, 20, 0, 20)
        arrow.BackgroundTransparency = 1
        arrow.Text = defaultOpen and "▼" or "▶"
        arrow.TextColor3 = Theme.Accent2
        arrow.TextSize = 12
        arrow.Font = Theme.FontBold
        arrow.Parent = header

        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Position = UDim2.new(0, 0, 0, Theme.SectionHeight)
        content.Size = UDim2.new(1, 0, 0, 0)
        content.BackgroundTransparency = 1
        content.ClipsDescendants = true
        content.Parent = container

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 6)
        contentLayout.Parent = content

        local contentPad = Instance.new("UIPadding")
        contentPad.PaddingTop = UDim.new(0, 6)
        contentPad.PaddingBottom = UDim.new(0, 6)
        contentPad.PaddingLeft = UDim.new(0, 4)
        contentPad.PaddingRight = UDim.new(0, 4)
        contentPad.Parent = content

        local isOpen = defaultOpen

        local function updateHeight()
            local contentH = contentLayout.AbsoluteContentSize.Y + 12
            content.Size = UDim2.new(1, 0, 0, isOpen and contentH or 0)
            container.Size = UDim2.new(1, 0, 0, Theme.SectionHeight + (isOpen and contentH or 0))
        end

        header.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            arrow.Text = isOpen and "▼" or "▶"
            updateHeight()
        end)

        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if isOpen then updateHeight() end
        end)

        task.defer(updateHeight)

        local group = {
            _container = container,
            _content = content,
            _page = page,
            _layout = contentLayout,
        }

        function group:Label(text)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 22)
            lbl.BackgroundTransparency = 1
            lbl.Text = "  " .. text
            lbl.TextColor3 = Theme.SubTextColor
            lbl.TextSize = 12
            lbl.Font = Theme.Font
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = content
            return lbl
        end

        function group:Button(text, callback, iconName2)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
            btn.BackgroundColor3 = Theme.ControlBG2
            btn.BackgroundTransparency = 0.2
            btn.BorderSizePixel = 0
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.Parent = content
            corner(btn, Theme.ControlCorner)

            local textX = 12
            if iconName2 then
                local icon = Instance.new("ImageLabel")
                icon.AnchorPoint = Vector2.new(0, 0.5)
                icon.Position = UDim2.new(0, 10, 0.5, 0)
                icon.Size = UDim2.new(0, 20, 0, 20)
                icon.BackgroundTransparency = 1
                icon.Image = FrostUI.Icons[iconName2] or FrostUI.Icons.Info
                icon.Parent = btn
                textX = 38
            end

            local lbl = Instance.new("TextLabel")
            lbl.Position = UDim2.new(0, textX, 0, 0)
            lbl.Size = UDim2.new(1, -textX - 10, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = Theme.TextColor
            lbl.TextSize = 13
            lbl.Font = Theme.Font
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = btn

            btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            return btn
        end

        function group:Toggle(text, default, callback, flag)
            if flag then default = FrostUI.Config:Get(flag, default) end
            local state = default or false

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
            row.BackgroundColor3 = Theme.ControlBG2
            row.BackgroundTransparency = 0.2
            row.BorderSizePixel = 0
            row.Parent = content
            corner(row, Theme.ControlCorner)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -70, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Theme.TextColor
            label.TextSize = 13
            label.Font = Theme.Font
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = row

            local switch = Instance.new("Frame")
            switch.AnchorPoint = Vector2.new(1, 0.5)
            switch.Position = UDim2.new(1, -10, 0.5, 0)
            switch.Size = UDim2.new(0, 44, 0, 22)
            switch.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
            switch.BorderSizePixel = 0
            switch.Parent = row
            corner(switch, UDim.new(1, 0))

            local knob = Instance.new("Frame")
            knob.AnchorPoint = Vector2.new(0, 0.5)
            knob.Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            knob.Size = UDim2.new(0, 18, 0, 18)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            knob.BorderSizePixel = 0
            knob.Parent = switch
            corner(knob, UDim.new(1, 0))

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.Parent = row

            local function setState(v)
                state = v
                tween(switch, 0.15, { BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff })
                tween(knob, 0.15, {
                    Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
                })
                if flag then FrostUI.Config:Set(flag, state) end
                if callback then callback(state) end
            end

            btn.MouseButton1Click:Connect(function() setState(not state) end)
            return { Set = setState, Get = function() return state end, Frame = row }
        end

        function group:Slider(text, min, max, default, callback, flag)
            if flag then default = FrostUI.Config:Get(flag, default) end
            min = min or 0
            max = max or 100
            default = default or min

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 46)
            row.BackgroundColor3 = Theme.ControlBG2
            row.BackgroundTransparency = 0.2
            row.BorderSizePixel = 0
            row.Parent = content
            corner(row, Theme.ControlCorner)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -60, 0, 20)
            label.Position = UDim2.new(0, 12, 0, 4)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Theme.TextColor
            label.TextSize = 13
            label.Font = Theme.Font
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = row

            local valueLabel = Instance.new("TextLabel")
            valueLabel.AnchorPoint = Vector2.new(1, 0)
            valueLabel.Position = UDim2.new(1, -10, 0, 4)
            valueLabel.Size = UDim2.new(0, 50, 0, 20)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(default)
            valueLabel.TextColor3 = Theme.Accent2
            valueLabel.TextSize = 13
            valueLabel.Font = Theme.FontBold
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = row

            local barBg = Instance.new("Frame")
            barBg.AnchorPoint = Vector2.new(0, 1)
            barBg.Position = UDim2.new(0, 12, 1, -10)
            barBg.Size = UDim2.new(1, -24, 0, 8)
            barBg.BackgroundColor3 = Theme.ControlBG
            barBg.BorderSizePixel = 0
            barBg.Parent = row
            corner(barBg, UDim.new(1, 0))

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = Theme.Accent
            fill.BorderSizePixel = 0
            fill.Parent = barBg
            corner(fill, UDim.new(1, 0))

            local knob = Instance.new("Frame")
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.new(0, 0, 0.5, 0)
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            knob.BorderSizePixel = 0
            knob.Parent = barBg
            corner(knob, UDim.new(1, 0))

            local value = default
            local function updateFromX(x)
                local rel = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                value = min + (max - min) * rel
                value = math.floor(value * 100) / 100
                fill.Size = UDim2.new(rel, 0, 1, 0)
                knob.Position = UDim2.new(rel, 0, 0.5, 0)
                valueLabel.Text = tostring(value)
                if flag then FrostUI.Config:Set(flag, value) end
                if callback then callback(value) end
            end

            local dragging = false
            barBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateFromX(input.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                    updateFromX(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            local initRel = (default - min) / (max - min)
            fill.Size = UDim2.new(initRel, 0, 1, 0)
            knob.Position = UDim2.new(initRel, 0, 0.5, 0)

            return {
                Set = function(v)
                    value = math.clamp(v, min, max)
                    local rel = (value - min) / (max - min)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    knob.Position = UDim2.new(rel, 0, 0.5, 0)
                    valueLabel.Text = tostring(value)
                    if flag then FrostUI.Config:Set(flag, value) end
                    if callback then callback(value) end
                end,
                Get = function() return value end,
                Frame = row,
            }
        end

        function group:Textbox(placeholder, default, callback, flag)
            if flag then default = FrostUI.Config:Get(flag, default) end
            default = default or ""

            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
            box.BackgroundColor3 = Theme.ControlBG2
            box.BackgroundTransparency = 0.2
            box.BorderSizePixel = 0
            box.Text = default
            box.PlaceholderText = placeholder or "输入..."
            box.PlaceholderColor3 = Theme.SubTextColor
            box.TextColor3 = Theme.TextColor
            box.TextSize = 13
            box.Font = Theme.Font
            box.ClearTextOnFocus = false
            box.Parent = content
            corner(box, Theme.ControlCorner)

            box.FocusLost:Connect(function()
                if flag then FrostUI.Config:Set(flag, box.Text) end
                if callback then callback(box.Text) end
            end)
            return box
        end

        function group:Dropdown(text, options, callback, flag)
            options = options or {}
            local selected = flag and FrostUI.Config:Get(flag, nil) or nil
            local expanded = false

            local container2 = Instance.new("Frame")
            container2.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
            container2.BackgroundTransparency = 1
            container2.ClipsDescendants = true
            container2.Parent = content

            local header2 = Instance.new("TextButton")
            header2.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
            header2.BackgroundColor3 = Theme.ControlBG2
            header2.BackgroundTransparency = 0.2
            header2.BorderSizePixel = 0
            header2.Text = "  " .. text .. (selected and (": " .. selected) or " ▼")
            header2.TextColor3 = Theme.TextColor
            header2.TextSize = 13
            header2.Font = Theme.Font
            header2.TextXAlignment = Enum.TextXAlignment.Left
            header2.AutoButtonColor = false
            header2.Parent = container2
            corner(header2, Theme.ControlCorner)

            local list2 = Instance.new("Frame")
            list2.Size = UDim2.new(1, 0, 0, 0)
            list2.Position = UDim2.new(0, 0, 0, Theme.RowHeight + 4)
            list2.BackgroundColor3 = Theme.ControlBG2
            list2.BackgroundTransparency = 0.1
            list2.BorderSizePixel = 0
            list2.Visible = false
            list2.Parent = container2
            corner(list2, Theme.ControlCorner)

            local listLayout2 = Instance.new("UIListLayout")
            listLayout2.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout2.Padding = UDim.new(0, 2)
            listLayout2.Parent = list2

            local listPad2 = Instance.new("UIPadding")
            listPad2.PaddingTop = UDim.new(0, 4)
            listPad2.PaddingBottom = UDim.new(0, 4)
            listPad2.PaddingLeft = UDim.new(0, 4)
            listPad2.PaddingRight = UDim.new(0, 4)
            listPad2.Parent = list2

            local function refresh2()
                for _, child in ipairs(list2:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for _, opt in ipairs(options) do
                    local item = Instance.new("TextButton")
                    item.Size = UDim2.new(1, 0, 0, 26)
                    item.BackgroundColor3 = Theme.ControlBG
                    item.BackgroundTransparency = 0.4
                    item.BorderSizePixel = 0
                    item.Text = "  " .. opt
                    item.TextColor3 = Theme.TextColor
                    item.TextSize = 12
                    item.Font = Theme.Font
                    item.TextXAlignment = Enum.TextXAlignment.Left
                    item.AutoButtonColor = false
                    item.Parent = list2
                    corner(item, UDim.new(0, 6))

                    item.MouseButton1Click:Connect(function()
                        selected = opt
                        header2.Text = "  " .. text .. ": " .. opt
                        if flag then FrostUI.Config:Set(flag, opt) end
                        if callback then callback(opt) end
                        expanded = false
                        list2.Visible = false
                        container2.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
                        header2.Text = header2.Text:gsub(" ▲", " ▼")
                    end)
                end
                list2.Size = UDim2.new(1, 0, 0, #options * 28 + 8)
            end
            refresh2()

            header2.MouseButton1Click:Connect(function()
                expanded = not expanded
                list2.Visible = expanded
                if expanded then
                    container2.Size = UDim2.new(1, 0, 0, Theme.RowHeight + list2.Size.Y.Offset + 4)
                    header2.Text = header2.Text:gsub(" ▼", " ▲")
                else
                    container2.Size = UDim2.new(1, 0, 0, Theme.RowHeight)
                    header2.Text = header2.Text:gsub(" ▲", " ▼")
                end
            end)

            return {
                SetOptions = function(newOpts)
                    options = newOpts
                    refresh2()
                end,
                Get = function() return selected end,
                Frame = container2,
            }
        end

        return group
    end

    return tabObj
end

-- ============================================
-- 初始化
-- ============================================
function FrostUI:Init()
    return self
end

return FrostUI