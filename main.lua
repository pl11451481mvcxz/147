-- ============================================
--  RayField 风格 UI 库 (Mobile 小尺寸版)
--  Tab 横排 + 全局缩放 0.65
-- ============================================

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Camera = workspace.CurrentCamera
while not Camera do
    task.wait()
    Camera = workspace.CurrentCamera
end

local Theme = {
    Background     = Color3.fromRGB(20, 20, 20),
    BackgroundAlt  = Color3.fromRGB(28, 28, 28),
    Element        = Color3.fromRGB(35, 35, 35),
    Text           = Color3.fromRGB(240, 240, 240),
    TextDim        = Color3.fromRGB(160, 160, 160),
    Accent         = Color3.fromRGB(255, 255, 255),
    Stroke         = Color3.fromRGB(255, 255, 255),
    Font           = Enum.Font.GothamMedium,
    FontBold       = Enum.Font.GothamBold,
}

-- 全局缩放（觉得大改小，觉得小改大）
local UI_SCALE = 0.65

local function Create(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        pcall(function() inst[k] = v end)
    end
    return inst
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = radius or UDim.new(0, 10),
        Parent = parent,
    })
end

local function AddFeatherStroke(parent, thickness, transparency)
    thickness = thickness or 1.5
    transparency = transparency or 0.3
    Create("UIStroke", {
        Color = Theme.Stroke,
        Thickness = thickness * 2,
        Transparency = 0.85,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
    Create("UIStroke", {
        Color = Theme.Stroke,
        Thickness = thickness,
        Transparency = transparency,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end
local function MakeDraggable(frame, dragArea)
    dragArea = dragArea or frame
    local dragging, dragStart, startPos
    local DRAG_THRESHOLD = 6  -- 移动超过 6 像素才算拖动，避免误触

    local function isInteractive(gui)
        -- 判断触摸点是否落在按钮/输入框/滑块等交互元素上
        local interactiveTypes = {
            TextButton = true,
            ImageButton = true,
            TextBox = true,
            ScrollingFrame = true,
        }
        local current = gui
        while current and current ~= frame do
            if interactiveTypes[current.ClassName] then
                return true
            end
            current = current.Parent
        end
        return false
    end

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            -- 如果点在交互元素上，不拖动
            local target = PlayerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
            for _, obj in ipairs(target) do
                if isInteractive(obj) then
                    return
                end
            end

            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    dragArea.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > DRAG_THRESHOLD or math.abs(delta.Y) > DRAG_THRESHOLD then
                frame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end
-- ============================================
--  UI 类
-- ============================================
local UI = {}
UI.__index = UI

function UI.new(title)
    title = title or "Mobile UI"
    local self = setmetatable({}, UI)
    self.Tabs = {}
    self.ActiveTab = nil

    local gui = Create("ScreenGui", {
        Name = "MobileRayfieldUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = PlayerGui,
    })
    self.Gui = gui

    -- 主容器（小尺寸）
    local main = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 360, 0, 460),
        Position = UDim2.new(0.5, -160, 0.5, -230),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Parent = gui,
    })
    AddCorner(main, UDim.new(0, 14))
    AddFeatherStroke(main, 1.5, 0.15)
    self.Main = main

    -- 全局缩放
    local uiScale = Create("UIScale", {
        Scale = UI_SCALE,
        Parent = main,
    })
    self.UIScale = uiScale

    -- 标题栏
    local topBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 38),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.BackgroundAlt,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = main,
    })
    AddCorner(topBar, UDim.new(0, 14))
    AddFeatherStroke(topBar, 1, 0.4)

    Create("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar,
    })

    local closeBtn = Create("TextButton", {
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -34, 0.5, -13),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        Text = "X",
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 13,
        Parent = topBar,
    })
    AddCorner(closeBtn, UDim.new(0, 8))
    closeBtn.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)

    MakeDraggable(main, topBar)

    -- Tab 栏（顶部横排）
    local tabBar = Create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, -16, 0, 36),
        Position = UDim2.new(0, 8, 0, 44),
        BackgroundColor3 = Theme.BackgroundAlt,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = main,
    })
    AddCorner(tabBar, UDim.new(0, 10))
    AddFeatherStroke(tabBar, 1, 0.4)
    self.TabBar = tabBar

    local tabLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabBar,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        Parent = tabBar,
    })

    -- 内容区
    local content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -16, 1, -92),
        Position = UDim2.new(0, 8, 0, 86),
        BackgroundColor3 = Theme.BackgroundAlt,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = main,
    })
    AddCorner(content, UDim.new(0, 10))
    AddFeatherStroke(content, 1, 0.4)
    self.Content = content

    local scroll = Create("ScrollingFrame", {
        Name = "Scroll",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = content,
    })
    local scrollLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = scroll,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = scroll,
    })
    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 16)
    end)
    self.Scroll = scroll

    return self
end

-- Tab（横排，固定宽度）
function UI:Tab(name)
    local btn = Create("TextButton", {
        Size = UDim2.new(0, 68, 1, 0),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 12,
        Parent = self.TabBar,
    })
    AddCorner(btn, UDim.new(0, 8))

    local tabObj = { Name = name, Button = btn, Elements = {} }

    btn.MouseButton1Click:Connect(function()
        self:SelectTab(tabObj)
    end)

    table.insert(self.Tabs, tabObj)
    if not self.ActiveTab then self:SelectTab(tabObj) end
    return tabObj
end

function UI:SelectTab(tab)
    self.ActiveTab = tab
    for _, t in ipairs(self.Tabs) do
        if t == tab then
            t.Button.BackgroundTransparency = 0.1
            t.Button.TextColor3 = Theme.Text
        else
            t.Button.BackgroundTransparency = 0.5
            t.Button.TextColor3 = Theme.TextDim
        end
    end
    for _, child in ipairs(self.Scroll:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
    for _, el in ipairs(tab.Elements) do
        el.Parent = self.Scroll
    end
end

-- 按钮
function UI:Button(tab, text, callback)
    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = 13,
        AutoButtonColor = false,
    })
    AddCorner(btn, UDim.new(0, 8))
    AddFeatherStroke(btn, 1, 0.5)

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        }):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Theme.Element
        }):Play()
        if callback then pcall(callback) end
    end)

    table.insert(tab.Elements, btn)
    if self.ActiveTab == tab then btn.Parent = self.Scroll end
    return btn
end

-- 开关
function UI:Toggle(tab, text, default, callback)
    default = default or false
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
    })
    AddCorner(container, UDim.new(0, 8))
    AddFeatherStroke(container, 1, 0.5)

    Create("TextLabel", {
        Size = UDim2.new(1, -58, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })

    local switchBg = Create("Frame", {
        Size = UDim2.new(0, 38, 0, 20),
        Position = UDim2.new(1, -48, 0.5, -10),
        BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0,
        Parent = container,
    })
    AddCorner(switchBg, UDim.new(0, 10))
    AddFeatherStroke(switchBg, 1, 0.4)

    local knob = Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = default and Theme.Background or Color3.fromRGB(200, 200, 200),
        BorderSizePixel = 0,
        Parent = switchBg,
    })
    AddCorner(knob, UDim.new(1, 0))

    local state = default
    local clickArea = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = container,
    })

    local function update()
        local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(switchBg, info, {
            BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(60, 60, 60)
        }):Play()
        TweenService:Create(knob, info, {
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = state and Theme.Background or Color3.fromRGB(200, 200, 200)
        }):Play()
    end

    clickArea.MouseButton1Click:Connect(function()
        state = not state
        update()
        if callback then pcall(callback, state) end
    end)

    table.insert(tab.Elements, container)
    if self.ActiveTab == tab then container.Parent = self.Scroll end
    return container
end

-- 滑块
function UI:Slider(tab, text, min, max, default, callback)
    min = min or 0
    max = max or 100
    default = default or min

    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
    })
    AddCorner(container, UDim.new(0, 8))
    AddFeatherStroke(container, 1, 0.5)

    Create("TextLabel", {
        Size = UDim2.new(1, -76, 0, 16),
        Position = UDim2.new(0, 12, 0, 4),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })

    local valueLabel = Create("TextLabel", {
        Size = UDim2.new(0, 60, 0, 16),
        Position = UDim2.new(1, -72, 0, 4),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = Theme.Accent,
        Font = Theme.FontBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = container,
    })

    local track = Create("Frame", {
        Size = UDim2.new(1, -24, 0, 5),
        Position = UDim2.new(0, 12, 0, 30),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0,
        Parent = container,
    })
    AddCorner(track, UDim.new(1, 0))

    local fill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = track,
    })
    AddCorner(fill, UDim.new(1, 0))

    local dot = Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, -7, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = track,
    })
    AddCorner(dot, UDim.new(1, 0))
    AddFeatherStroke(dot, 1.5, 0.2)

    local value = math.clamp(default, min, max)

    local function updateVisual()
        local alpha = (value - min) / (max - min)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        dot.Position = UDim2.new(alpha, -7, 0.5, -7)
        valueLabel.Text = tostring(math.floor(value * 100) / 100)
    end
    updateVisual()

    local dragging = false

    local function setFromX(x)
        if not track.AbsoluteSize.X or track.AbsoluteSize.X == 0 then return end
        local rel = (x - track.AbsolutePosition.X) / track.AbsoluteSize.X
        rel = math.clamp(rel, 0, 1)
        value = min + (max - min) * rel
        updateVisual()
        if callback then pcall(callback, value) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)
    track.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    table.insert(tab.Elements, container)
    if self.ActiveTab == tab then container.Parent = self.Scroll end
    return container
end

-- 文本框
function UI:Textbox(tab, text, placeholder, callback)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
    })
    AddCorner(container, UDim.new(0, 8))
    AddFeatherStroke(container, 1, 0.5)

    Create("TextLabel", {
        Size = UDim2.new(1, -24, 0, 14),
        Position = UDim2.new(0, 12, 0, 4),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })

    local box = Create("TextBox", {
        Size = UDim2.new(1, -24, 0, 24),
        Position = UDim2.new(0, 12, 0, 20),
        BackgroundColor3 = Theme.BackgroundAlt,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = placeholder or "输入...",
        PlaceholderColor3 = Theme.TextDim,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = container,
    })
    AddCorner(box, UDim.new(0, 6))
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = box,
    })

    box.FocusLost:Connect(function(enterPressed)
        if callback then pcall(callback, box.Text, enterPressed) end
    end)

    table.insert(tab.Elements, container)
    if self.ActiveTab == tab then container.Parent = self.Scroll end
    return container
end

-- 下拉框
function UI:Dropdown(tab, text, options, callback)
    options = options or {}
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    AddCorner(container, UDim.new(0, 8))
    AddFeatherStroke(container, 1, 0.5)

    local header = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = "",
        Parent = container,
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })

    local selectedLabel = Create("TextLabel", {
        Size = UDim2.new(0, 56, 1, 0),
        Position = UDim2.new(1, -72, 0, 0),
        BackgroundTransparency = 1,
        Text = "选择...",
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = header,
    })

    local arrow = Create("TextLabel", {
        Size = UDim2.new(0, 14, 1, 0),
        Position = UDim2.new(1, -18, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 10,
        Parent = header,
    })

    local optionHolder = Create("Frame", {
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.new(0, 8, 0, 34),
        BackgroundTransparency = 1,
        Parent = container,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = optionHolder,
    })

    local expanded = false

    for _, opt in ipairs(options) do
        local ob = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = Theme.BackgroundAlt,
            BorderSizePixel = 0,
            Text = tostring(opt),
            TextColor3 = Theme.Text,
            Font = Theme.Font,
            TextSize = 11,
            Parent = optionHolder,
        })
        AddCorner(ob, UDim.new(0, 6))
        ob.MouseButton1Click:Connect(function()
            selectedLabel.Text = tostring(opt)
            selectedLabel.TextColor3 = Theme.Text
            expanded = false
            TweenService:Create(container, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, 32)
            }):Play()
            arrow.Text = "▼"
            if callback then pcall(callback, opt) end
        end)
    end

    header.MouseButton1Click:Connect(function()
        expanded = not expanded
        if expanded then
            local h = 34 + #options * 27 + 6
            TweenService:Create(container, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, h)
            }):Play()
            arrow.Text = "▲"
        else
            TweenService:Create(container, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 0, 32)
            }):Play()
            arrow.Text = "▼"
        end
    end)

    table.insert(tab.Elements, container)
    if self.ActiveTab == tab then container.Parent = self.Scroll end
    return container
end

-- 标签
function UI:Label(tab, text)
    local label = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Scroll,
    })
    table.insert(tab.Elements, label)
    if self.ActiveTab == tab then label.Parent = self.Scroll end
    return label
end

-- 分割线
function UI:Section(tab, text)
    local container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
    })
    Create("TextLabel", {
        Size = UDim2.new(0, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 4),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container,
    })
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundColor3 = Theme.Stroke,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Parent = container,
    })
    table.insert(tab.Elements, container)
    if self.ActiveTab == tab then container.Parent = self.Scroll end
    return container
end

-- 通知
function UI:Notify(title, text, duration)
    duration = duration or 3
    local note = Create("Frame", {
        Size = UDim2.new(0, 200, 0, 52),
        Position = UDim2.new(1, 220, 0, 14),
        BackgroundColor3 = Theme.BackgroundAlt,
        BorderSizePixel = 0,
        Parent = self.Gui,
    })
    AddCorner(note, UDim.new(0, 10))
    AddFeatherStroke(note, 1.5, 0.15)

    Create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 18),
        Position = UDim2.new(0, 10, 0, 6),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = note,
    })
    Create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 22),
        Position = UDim2.new(0, 10, 0, 24),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = note,
    })

    TweenService:Create(note, TweenInfo.new(0.3), {
        Position = UDim2.new(1, -216, 0, 14)
    }):Play()

    task.delay(duration, function()
        local t = TweenService:Create(note, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 220, 0, 14)
        })
        t:Play()
        t.Completed:Connect(function() note:Destroy() end)
    end)
end

-- 显示/隐藏
function UI:ToggleUI()
    self.Gui.Enabled = not self.Gui.Enabled
end

return UI
