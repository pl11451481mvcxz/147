local MobileUI = {}
MobileUI.__index = MobileUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
MobileUI.Config = {
    WindowSize   = UDim2.fromOffset(360, 280),
    Corner       = UDim.new(0, 16),
    TitleSize    = 15,
    ButtonSize   = 32,
    FloatBtnSize = 56,
    Font         = Enum.Font.GothamMedium,
    FeatherColor = Color3.fromRGB(255, 255, 255),
    BgColor      = Color3.fromRGB(22, 22, 28),
}
local function createFeatheredStroke(parent, featherColor)
    featherColor = featherColor or MobileUI.Config.FeatherColor
    local layers = {
        { thickness = 8, transparency = 0.92 },
        { thickness = 6, transparency = 0.85 },
        { thickness = 4, transparency = 0.7  },
        { thickness = 2, transparency = 0.45 },
        { thickness = 1, transparency = 0.1  },
    }
    local strokes = {}
    for _, layer in ipairs(layers) do
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = layer.thickness
        stroke.Transparency = layer.transparency
        stroke.Color = featherColor
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.LineJoinMode = Enum.LineJoinMode.Round
        stroke.Parent = parent
        table.insert(strokes, stroke)
    end
    return strokes
end
function MobileUI:_ensureGui()
    if self._gui and self._gui.Parent then return self._gui end

    if PlayerGui:FindFirstChild("MobileUI") then
        PlayerGui.MobileUI:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MobileUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui

    self._gui = gui
    return gui
end
function MobileUI:MakeWindow(opts)
    opts = opts or {}
    local cfg = self.Config

    local gui = self:_ensureGui()

    local win = {}
    win._tabs = {}
    win._gui = gui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.fromOffset(0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = cfg.BgColor
    MainFrame.BackgroundTransparency = 1
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = gui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = cfg.Corner
    MainCorner.Parent = MainFrame

    local MainStrokes = createFeatheredStroke(MainFrame, cfg.FeatherColor)
    for _, s in ipairs(MainStrokes) do s.Transparency = 1 end

    
    TweenService:Create(MainFrame,
        TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Size = cfg.WindowSize, BackgroundTransparency = 0.08 }
    ):Play()

    task.spawn(function()
        local targets = {0.92, 0.85, 0.7, 0.45, 0.1}
        for i, s in ipairs(MainStrokes) do
            TweenService:Create(s,
                TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Transparency = targets[i] }
            ):Play()
            task.wait(0.05)
        end
    end)

    win._frame = MainFrame
    win._strokes = MainStrokes

    
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -110, 1, 0)
    TitleLabel.Position = UDim2.fromOffset(16, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = opts.Name or "Mobile UI"
    TitleLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
    TitleLabel.TextSize = cfg.TitleSize
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
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
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.fromOffset(cfg.ButtonSize, cfg.ButtonSize)
    MinimizeBtn.Position = UDim2.new(1, -(cfg.ButtonSize * 2 + 16), 0, 6)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    MinimizeBtn.BackgroundTransparency = 0.3
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.TextSize = 20
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.Parent = TitleBar

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 8)
    MinCorner.Parent = MinimizeBtn

    local MinStrokes = createFeatheredStroke(MinimizeBtn, cfg.FeatherColor)
    for _, s in ipairs(MinStrokes) do
        s.Transparency = math.min(s.Transparency + 0.15, 1)
    end

    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.fromOffset(cfg.ButtonSize, cfg.ButtonSize)
    CloseBtn.Position = UDim2.new(1, -cfg.ButtonSize - 12, 0, 6)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    CloseBtn.BackgroundTransparency = 0.3
    CloseBtn.Text = "Ⅹ"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = TitleBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseBtn

    local CloseStrokes = createFeatheredStroke(CloseBtn, cfg.FeatherColor)
    for _, s in ipairs(CloseStrokes) do
        s.Transparency = math.min(s.Transparency + 0.15, 1)
    end

    
    local Content = Instance.new("ScrollingFrame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -20, 1, -50)
    Content.Position = UDim2.fromOffset(10, 45)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 3
    Content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Content.Parent = MainFrame

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 6)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = Content

    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingTop = UDim.new(0, 4)
    ContentPadding.PaddingLeft = UDim.new(0, 4)
    ContentPadding.PaddingRight = UDim.new(0, 4)
    ContentPadding.PaddingBottom = UDim.new(0, 4)
    ContentPadding.Parent = Content

    win._content = Content
    win._contentLayout = ContentLayout

    
    local FloatingBtn = Instance.new("TextButton")
    FloatingBtn.Size = UDim2.fromOffset(cfg.FloatBtnSize, cfg.FloatBtnSize)
    FloatingBtn.Position = UDim2.fromOffset(20, 200)
    FloatingBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    FloatingBtn.BackgroundTransparency = 0.08
    FloatingBtn.Text = opts.FloatText or "UI"
    FloatingBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
    FloatingBtn.TextSize = 16
    FloatingBtn.Font = Enum.Font.GothamBold
    FloatingBtn.AutoButtonColor = false
    FloatingBtn.Visible = false
    FloatingBtn.Parent = gui

    local FloatCorner = Instance.new("UICorner")
    FloatCorner.CornerRadius = UDim.new(1, 0)
    FloatCorner.Parent = FloatingBtn

    local FloatStrokes = createFeatheredStroke(FloatingBtn, cfg.FeatherColor)

    
    local floatDragging, floatDragStart, floatStartPos, floatMoved
    FloatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            floatDragging = true
            floatMoved = false
            floatDragStart = input.Position
            floatStartPos = FloatingBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    floatDragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if floatDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - floatDragStart
            if math.abs(delta.X) > 8 or math.abs(delta.Y) > 8 then
                floatMoved = true
            end
            FloatingBtn.Position = UDim2.new(
                floatStartPos.X.Scale, floatStartPos.X.Offset + delta.X,
                floatStartPos.Y.Scale, floatStartPos.Y.Offset + delta.Y
            )
        end
    end)

    
    local function minimize()
        local tw = TweenService:Create(MainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            { Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1 }
        )
        for _, s in ipairs(MainStrokes) do
            TweenService:Create(s, TweenInfo.new(0.25), { Transparency = 1 }):Play()
        end
        tw:Play()
        tw.Completed:Wait()

        MainFrame.Visible = false
        FloatingBtn.Visible = true
        FloatingBtn.Size = UDim2.fromOffset(0, 0)
        TweenService:Create(FloatingBtn,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Size = UDim2.fromOffset(cfg.FloatBtnSize, cfg.FloatBtnSize) }
        ):Play()
    end

    local function restore()
        FloatingBtn.Visible = false
        MainFrame.Visible = true
        TweenService:Create(MainFrame,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Size = cfg.WindowSize, BackgroundTransparency = 0.08 }
        ):Play()
        local targets = {0.92, 0.85, 0.7, 0.45, 0.1}
        for i, s in ipairs(MainStrokes) do
            TweenService:Create(s, TweenInfo.new(0.4), { Transparency = targets[i] }):Play()
        end
    end

    MinimizeBtn.MouseButton1Click:Connect(minimize)
    FloatingBtn.MouseButton1Click:Connect(function()
        if not floatMoved then restore() end
    end)

    
    CloseBtn.MouseButton1Click:Connect(function()
        local tw = TweenService:Create(MainFrame,
            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1 }
        )
        for _, s in ipairs(MainStrokes) do
            TweenService:Create(s, TweenInfo.new(0.3), { Transparency = 1 }):Play()
        end
        tw:Play()
        tw.Completed:Wait()
        gui:Destroy()
    end)

    win._floatingBtn = FloatingBtn
    win._minStrokes = MinStrokes
    win._closeStrokes = CloseStrokes

    function win:Destroy()
        gui:Destroy()
    end

    function win:SetTitle(text)
        TitleLabel.Text = text
    end

    function win:MakeTab(opts2)
        opts2 = opts2 or {}
        local tab = {}
        tab._win = win
        tab._order = 0

        local Page = Instance.new("Frame")
        Page.Name = "Page_" .. (opts2.Name or "Tab")
        Page.Size = UDim2.new(1, 0, 0, 0)
        Page.AutomaticSize = Enum.AutomaticSize.Y
        Page.BackgroundTransparency = 1
        Page.Parent = Content

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0, 6)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = Page

        tab._page = Page

        local function nextOrder()
            tab._order = tab._order + 1
            return tab._order
        end

        function tab:AddToggle(o)
            o = o or {}
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, 0, 0, 34)
            holder.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
            holder.BackgroundTransparency = 0.25
            holder.BorderSizePixel = 0
            holder.LayoutOrder = nextOrder()
            holder.Parent = Page
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 8)
            c.Parent = holder

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -70, 1, 0)
            label.Position = UDim2.fromOffset(12, 0)
            label.BackgroundTransparency = 1
            label.Text = o.Name or "Toggle"
            label.TextColor3 = Color3.fromRGB(230, 230, 240)
            label.TextSize = 14
            label.Font = Enum.Font.GothamMedium
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = holder

            local switch = Instance.new("TextButton")
            switch.Size = UDim2.fromOffset(48, 22)
            switch.Position = UDim2.new(1, -60, 0.5, 0)
            switch.AnchorPoint = Vector2.new(0, 0.5)
            switch.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
            switch.Text = ""
            switch.AutoButtonColor = false
            switch.Parent = holder

            local sc = Instance.new("UICorner")
            sc.CornerRadius = UDim.new(1, 0)
            sc.Parent = switch

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(16, 16)
            knob.Position = UDim2.fromOffset(3, 3)
            knob.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
            knob.BorderSizePixel = 0
            knob.Parent = switch
            local kc = Instance.new("UICorner")
            kc.CornerRadius = UDim.new(1, 0)
            kc.Parent = knob

            local state = o.Default or false

            local function apply(v)
                state = v
                TweenService:Create(switch, TweenInfo.new(0.15), {
                    BackgroundColor3 = v and Color3.fromRGB(80, 130, 220) or Color3.fromRGB(60, 60, 75)
                }):Play()
                TweenService:Create(knob, TweenInfo.new(0.15), {
                    Position = v and UDim2.fromOffset(29, 3) or UDim2.fromOffset(3, 3)
                }):Play()
            end

            apply(state)

            switch.MouseButton1Click:Connect(function()
                apply(not state)
                if o.Callback then o.Callback(state) end
            end)

            return { Set = apply, Get = function() return state end }
        end

        function tab:AddButton(o)
            o = o or {}
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 34)
            btn.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
            btn.BackgroundTransparency = 0.25
            btn.Text = o.Name or "Button"
            btn.TextColor3 = Color3.fromRGB(230, 230, 240)
            btn.TextSize = 14
            btn.Font = Enum.Font.GothamMedium
            btn.AutoButtonColor = false
            btn.LayoutOrder = nextOrder()
            btn.Parent = Page

            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 8)
            c.Parent = btn

            btn.MouseButton1Click:Connect(function()
                if o.Callback then o.Callback() end
            end)

            return btn
        end

        function tab:AddSlider(o)
            o = o or {}
            local min = o.Min or 0
            local max = o.Max or 100
            local value = o.Default or min

            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, 0, 0, 50)
            holder.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
            holder.BackgroundTransparency = 0.25
            holder.BorderSizePixel = 0
            holder.LayoutOrder = nextOrder()
            holder.Parent = Page

            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 8)
            c.Parent = holder

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -20, 0, 20)
            label.Position = UDim2.fromOffset(12, 6)
            label.BackgroundTransparency = 1
            label.Text = (o.Name or "Slider") .. "：" .. tostring(value)
            label.TextColor3 = Color3.fromRGB(230, 230, 240)
            label.TextSize = 13
            label.Font = Enum.Font.GothamMedium
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = holder

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -24, 0, 6)
            track.Position = UDim2.new(0, 12, 1, -16)
            track.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
            track.BorderSizePixel = 0
            track.Parent = holder

            local tc = Instance.new("UICorner")
            tc.CornerRadius = UDim.new(1, 0)
            tc.Parent = track

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(80, 130, 220)
            fill.BorderSizePixel = 0
            fill.Parent = track

            local fc = Instance.new("UICorner")
            fc.CornerRadius = UDim.new(1, 0)
            fc.Parent = fill

            local dragging = false

            local function updateFromX(x)
                local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local v = min + (max - min) * rel
                v = math.floor(v * 10 + 0.5) / 10
                value = v
                fill.Size = UDim2.new(rel, 0, 1, 0)
                label.Text = (o.Name or "Slider") .. "：" .. tostring(v)
                if o.Callback then o.Callback(v) end
            end

            track.InputBegan:Connect(function(input)
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

            return { Set = function(v) updateFromX(track.AbsolutePosition.X + track.AbsoluteSize.X * ((v - min) / (max - min))) end }
        end

        function tab:AddLabel(o)
            o = o or {}
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 24)
            label.BackgroundTransparency = 1
            label.Text = o.Text or o.Name or "Label"
            label.TextColor3 = Color3.fromRGB(200, 200, 215)
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.LayoutOrder = nextOrder()
            label.Parent = Page
            return label
        end

        table.insert(win._tabs, tab)
        return tab
    end

    return win
end
return MobileUI
