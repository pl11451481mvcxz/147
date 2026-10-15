-- ============================================
--  FeatherUI - 轻量级 Roblox UI 库
--  圆角 / WindUI 尺寸 / 白色羽化边框
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ==================== 配置 ====================
local Config = {
    Width = 750,
    Height = 645,
    CornerRadius = 8,
    SidebarWidth = 180,
    TopBarHeight = 48,
    BottomBarHeight = 20,
    BackgroundColor = Color3.fromRGB(15, 15, 15),
    MainColor = Color3.fromRGB(25, 25, 25),
    AccentColor = Color3.fromRGB(125, 85, 255),
    FontColor = Color3.fromRGB(255, 255, 255),
    OutlineColor = Color3.fromRGB(40, 40, 40),
    FeatherColor = Color3.fromRGB(255, 255, 255), -- 羽化边框颜色（白色）
    Font = Enum.Font.Code,
    TextSize = 14,
}

-- ==================== 工具函数 ====================
local function Create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or Config.CornerRadius),
        Parent = parent,
    })
end

local function AddStroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or Config.OutlineColor,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

-- 白色羽化边框（多层 UIStroke 叠加实现模糊发光效果）
local function AddFeatherBorder(parent, radius)
    local holder = Create("Frame", {
        Name = "FeatherBorder",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        ZIndex = 0,
        Parent = parent,
    })

    -- 多层羽毛化（越大越透明）
    for i = 1, 4 do
        local stroke = Create("UIStroke", {
            Color = Config.FeatherColor,
            Thickness = 1 + i * 1.5,
            Transparency = 0.65 + i * 0.08,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent = holder,
        })
        AddCorner(holder, radius + i * 3)
    end

    -- 最内层白色清晰描边
    local innerStroke = Create("UIStroke", {
        Color = Config.FeatherColor,
        Thickness = 1,
        Transparency = 0.2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = holder,
    })

    AddCorner(holder, radius + 2)
    return holder
end

-- ==================== 主库 ====================
local FeatherUI = {}
FeatherUI.__index = FeatherUI
FeatherUI.Config = Config

-- 创建 ScreenGui
local ScreenGui = Create("ScreenGui", {
    Name = "FeatherUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = LocalPlayer:WaitForChild("PlayerGui"),
})

FeatherUI.ScreenGui = ScreenGui

-- ==================== 通知系统 ====================
local NotificationArea = Create("Frame", {
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -10, 0, 10),
    Size = UDim2.new(0, 300, 1, -20),
    Parent = ScreenGui,
})
Create("UIListLayout", {
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = NotificationArea,
})

function FeatherUI:Notify(data)
    local title = data.Title or "通知"
    local content = data.Content or ""
    local duration = data.Duration or 3

    local notifyFrame = Create("Frame", {
        BackgroundColor3 = Config.MainColor,
        BackgroundTransparency = 0.1,
        Size = UDim2.new(1, 0, 0, 60),
        Parent = NotificationArea,
    })
    AddCorner(notifyFrame)
    AddStroke(notifyFrame, Config.OutlineColor, 1, 0.3)
    AddFeatherBorder(notifyFrame)

    local titleLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Config.Font,
        Position = UDim2.new(0, 12, 0, 8),
        Size = UDim2.new(1, -24, 0, 18),
        Text = title,
        TextColor3 = Config.FontColor,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = notifyFrame,
    })

    local contentLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Config.Font,
        Position = UDim2.new(0, 12, 0, 28),
        Size = UDim2.new(1, -24, 0, 24),
        Text = content,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 2,
        Parent = notifyFrame,
    })

    task.delay(duration, function()
        if notifyFrame and notifyFrame.Parent then
            local tween = TweenService:Create(notifyFrame, TweenInfo.new(0.3), {
                BackgroundTransparency = 1,
            })
            tween:Play()
            tween.Completed:Wait()
            notifyFrame:Destroy()
        end
    end)
end

-- ==================== 窗口 ====================
function FeatherUI:CreateWindow(info)
    info = info or {}
    local title = info.Title or "FeatherUI"
    local icon = info.Icon
    local author = info.Author or ""

    -- 主框架
    local mainFrame = Create("Frame", {
        BackgroundColor3 = Config.BackgroundColor,
        Position = UDim2.new(0.5, -Config.Width / 2, 0.5, -Config.Height / 2),
        Size = UDim2.fromOffset(Config.Width, Config.Height),
        Active = true,
        Draggable = true,
        Parent = ScreenGui,
        Visible = true,
    })
    AddCorner(mainFrame, Config.CornerRadius)
    AddStroke(mainFrame, Config.OutlineColor, 1, 0)
    AddFeatherBorder(mainFrame, Config.CornerRadius)

    -- 顶部标题栏
    local topBar = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, Config.TopBarHeight),
        Parent = mainFrame,
    })

    -- 标题
    local titleLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Font = Config.Font,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 300, 1, 0),
        Text = title,
        TextColor3 = Config.FontColor,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar,
    })

    -- 作者
    if author ~= "" then
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Config.Font,
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -12, 0, 0),
            Size = UDim2.new(0, 200, 1, 0),
            Text = "by " .. author,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = topBar,
        })
    end

    -- 分割线
    Create("Frame", {
        BackgroundColor3 = Config.OutlineColor,
        Position = UDim2.new(0, 0, 0, Config.TopBarHeight),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = mainFrame,
    })

    -- 侧边栏
    local sidebar = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, Config.TopBarHeight + 1),
        Size = UDim2.new(0, Config.SidebarWidth, 1, -(Config.TopBarHeight + Config.BottomBarHeight + 2)),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        Parent = mainFrame,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sidebar,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = sidebar,
    })

    -- 侧边栏分割线
    Create("Frame", {
        BackgroundColor3 = Config.OutlineColor,
        Position = UDim2.new(0, Config.SidebarWidth, 0, Config.TopBarHeight),
        Size = UDim2.new(0, 1, 1, -Config.TopBarHeight - Config.BottomBarHeight),
        Parent = mainFrame,
    })

    -- 内容区
    local contentArea = Create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Config.SidebarWidth + 1, 0, Config.TopBarHeight + 1),
        Size = UDim2.new(1, -Config.SidebarWidth - 1, 1, -(Config.TopBarHeight + Config.BottomBarHeight + 2)),
        Parent = mainFrame,
    })

    -- 底部栏
    local bottomBar = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Position = UDim2.new(0, 0, 1, -Config.BottomBarHeight),
        Size = UDim2.new(1, 0, 0, Config.BottomBarHeight),
        Parent = mainFrame,
    })
    AddCorner(bottomBar, Config.CornerRadius - 1)

    -- 窗口对象
    local Window = {
        MainFrame = mainFrame,
        ContentArea = contentArea,
        Sidebar = sidebar,
        TopBar = topBar,
        Tabs = {},
        ActiveTab = nil,
        ToggleKey = info.ToggleKey or Enum.KeyCode.RightControl,
        Visible = true,
    }

    -- 标签页容器
    local tabContainers = {}

    -- 隐藏/显示窗口
    function Window:Toggle()
        self.Visible = not self.Visible
        mainFrame.Visible = self.Visible
    end

    -- 快捷键
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.ToggleKey then
            self:Toggle()
        end
    end)

    -- 创建标签页
    function Window:Tab(tabInfo)
        tabInfo = tabInfo or {}
        local tabName = tabInfo.Title or "Tab"
        local tabIcon = tabInfo.Icon

        -- 标签按钮
        local tabButton = Create("TextButton", {
            BackgroundColor3 = Config.MainColor,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            Text = "",
            AutoButtonColor = false,
            Parent = sidebar,
        })
        AddCorner(tabButton, 6)

        local tabLabel = Create("TextLabel", {
            BackgroundTransparency = 1,
            Font = Config.Font,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -12, 1, 0),
            Text = tabName,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabButton,
        })

        -- 内容容器
        local container = Create("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Config.OutlineColor,
            Visible = false,
            Parent = contentArea,
        })
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = container,
        })
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            Parent = container,
        })

        tabContainers[tabName] = container

        -- 切换显示
        local function Show()
            if Window.ActiveTab then
                Window.ActiveTab:SetActive(false)
            end
            container.Visible = true
            tabLabel.TextColor3 = Config.FontColor
            tabButton.BackgroundTransparency = 0
            Window.ActiveTab = { SetActive = function(self, active)
                container.Visible = active
                tabLabel.TextColor3 = active and Config.FontColor or Color3.fromRGB(150, 150, 150)
                tabButton.BackgroundTransparency = active and 0 or 1
            end }
        end

        Window.ActiveTab = { SetActive = function(self, active)
            container.Visible = active
            tabLabel.TextColor3 = active and Config.FontColor or Color3.fromRGB(150, 150, 150)
            tabButton.BackgroundTransparency = active and 0 or 1
        end }

        -- 第一个标签默认显示
        if not Window.FirstTabShown then
            Window.FirstTabShown = true
            container.Visible = true
            tabLabel.TextColor3 = Config.FontColor
            tabButton.BackgroundTransparency = 0
        end

        tabButton.MouseButton1Click:Connect(function()
            for name, c in pairs(tabContainers) do
                c.Visible = false
            end
            for _, child in ipairs(sidebar:GetChildren()) do
                if child:IsA("TextButton") then
                    local lbl = child:FindFirstChildOfClass("TextLabel")
                    if lbl then
                        lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
                        child.BackgroundTransparency = 1
                    end
                end
            end
            container.Visible = true
            tabLabel.TextColor3 = Config.FontColor
            tabButton.BackgroundTransparency = 0
        end)

        -- ============ 控件创建方法 ============
        local Tab = {}

        -- 分区标题
        function Tab:Section(sectionInfo)
            local sectionTitle = sectionInfo and sectionInfo.Title or "Section"
            local label = Create("TextLabel", {
                BackgroundTransparency = 1,
                Font = Config.Font,
                Size = UDim2.new(1, 0, 0, 24),
                Text = sectionTitle,
                TextColor3 = Config.AccentColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = container,
            })
            return { Label = label }
        end

        -- 按钮
        function Tab:Button(btnInfo)
            local btnTitle = btnInfo.Title or "Button"
            local btnDesc = btnInfo.Desc or ""
            local callback = btnInfo.Callback or function() end

            local button = Create("TextButton", {
                BackgroundColor3 = Config.MainColor,
                Size = UDim2.new(1, 0, 0, btnDesc ~= "" and 46 or 32),
                Text = "",
                AutoButtonColor = false,
                Parent = container,
            })
            AddCorner(button, 6)
            AddStroke(button, Config.OutlineColor, 1, 0)

            Create("TextLabel", {
                BackgroundTransparency = 1,
                Font = Config.Font,
                Position = UDim2.new(0, 12, 0, btnDesc ~= "" and 6 or 0),
                Size = UDim2.new(1, -24, 0, 18),
                Text = btnTitle,
                TextColor3 = Config.FontColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = button,
            })

            if btnDesc ~= "" then
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Font = Config.Font,
                    Position = UDim2.new(0, 12, 0, 24),
                    Size = UDim2.new(1, -24, 0, 16),
                    Text = btnDesc,
                    TextColor3 = Color3.fromRGB(150, 150, 150),
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = button,
                })
            end

            button.MouseEnter:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                }):Play()
            end)
            button.MouseLeave:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.15), {
                    BackgroundColor3 = Config.MainColor,
                }):Play()
            end)

            button.MouseButton1Click:Connect(function()
                pcall(callback)
            end)
        end

        -- 开关
        function Tab:Toggle(togInfo)
            local togTitle = togInfo.Title or "Toggle"
            local togDesc = togInfo.Desc or ""
            local defaultValue = togInfo.Value or false
            local callback = togInfo.Callback or function() end

            local state = defaultValue

            local holder = Create("Frame", {
                BackgroundColor3 = Config.MainColor,
                Size = UDim2.new(1, 0, 0, togDesc ~= "" and 46 or 32),
                Parent = container,
            })
            AddCorner(holder, 6)
            AddStroke(holder, Config.OutlineColor, 1, 0)

            Create("TextLabel", {
                BackgroundTransparency = 1,
                Font = Config.Font,
                Position = UDim2.new(0, 12, 0, togDesc ~= "" and 6 or 0),
                Size = UDim2.new(1, -60, 0, 18),
                Text = togTitle,
                TextColor3 = Config.FontColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = holder,
            })

            if togDesc ~= "" then
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Font = Config.Font,
                    Position = UDim2.new(0, 12, 0, 24),
                    Size = UDim2.new(1, -60, 0, 16),
                    Text = togDesc,
                    TextColor3 = Color3.fromRGB(150, 150, 150),
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = holder,
                })
            end

            -- 开关按钮
            local switch = Create("TextButton", {
                BackgroundColor3 = state and Config.AccentColor or Color3.fromRGB(60, 60, 60),
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.fromOffset(40, 20),
                Text = "",
                AutoButtonColor = false,
                Parent = holder,
            })
            AddCorner(switch, 10)

            local ball = Create("Frame", {
                BackgroundColor3 = Config.FontColor,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                Size = UDim2.fromOffset(16, 16),
                Parent = switch,
            })
            AddCorner(ball, 8)

            switch.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(switch, TweenInfo.new(0.15), {
                    BackgroundColor3 = state and Config.AccentColor or Color3.fromRGB(60, 60, 60),
                }):Play()
                TweenService:Create(ball, TweenInfo.new(0.15), {
                    Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                }):Play()
                pcall(callback, state)
            end)
        end

        -- 滑块
        function Tab:Slider(sliderInfo)
            local sliderTitle = sliderInfo.Title or "Slider"
            local minVal = sliderInfo.Min or 0
            local maxVal = sliderInfo.Max or 100
            local defaultValue = sliderInfo.Value or minVal
            local callback = sliderInfo.Callback or function() end

            local currentValue = defaultValue

            local holder = Create("Frame", {
                BackgroundColor3 = Config.MainColor,
                Size = UDim2.new(1, 0, 0, 50),
                Parent = container,
            })
            AddCorner(holder, 6)
            AddStroke(holder, Config.OutlineColor, 1, 0)

            local titleLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                Font = Config.Font,
                Position = UDim2.new(0, 12, 0, 6),
                Size = UDim2.new(1, -24, 0, 18),
                Text = sliderTitle,
                TextColor3 = Config.FontColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = holder,
            })

            local valueLabel = Create("TextLabel", {
                BackgroundTransparency = 1,
                Font = Config.Font,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -12, 0, 6),
                Size = UDim2.new(0, 60, 0, 18),
                Text = tostring(currentValue),
                TextColor3 = Config.AccentColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = holder,
            })

            -- 滑块轨道
            local track = Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                Position = UDim2.new(0, 12, 1, -16),
                Size = UDim2.new(1, -24, 0, 6),
                Parent = holder,
            })
            AddCorner(track, 3)

            -- 填充
            local fill = Create("Frame", {
                BackgroundColor3 = Config.AccentColor,
                Size = UDim2.new((currentValue - minVal) / (maxVal - minVal), 0, 1, 0),
                Parent = track,
            })
            AddCorner(fill, 3)

            -- 拖动把手
            local knob = Create("Frame", {
                BackgroundColor3 = Config.FontColor,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new((currentValue - minVal) / (maxVal - minVal), 0, 0.5, 0),
                Size = UDim2.fromOffset(14, 14),
                ZIndex = 2,
                Parent = track,
            })
            AddCorner(knob, 7)

            -- 拖动逻辑
            local dragging = false
            local trackButton = Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 12),
                Position = UDim2.new(0, 0, 0, -3),
                Text = "",
                Parent = track,
            })

            local function updateFromMouse(x)
                local relX = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local val = math.floor(minVal + (maxVal - minVal) * relX)
                currentValue = val
                fill.Size = UDim2.new(relX, 0, 1, 0)
                knob.Position = UDim2.new(relX, 0, 0.5, 0)
                valueLabel.Text = tostring(val)
                pcall(callback, val)
            end

            trackButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateFromMouse(input.Position.X)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateFromMouse(input.Position.X)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end

        -- 输入框
        function Tab:Input(inputInfo)
            local inputTitle = inputInfo.Title or "Input"
            local defaultValue = inputInfo.Value or ""
            local placeholder = inputInfo.Placeholder or ""
            local callback = inputInfo.Callback or function() end

            local holder = Create("Frame", {
                BackgroundColor3 = Config.MainColor,
                Size = UDim2.new(1, 0, 0, 50),
                Parent = container,
            })
            AddCorner(holder, 6)
            AddStroke(holder, Config.OutlineColor, 1, 0)

            Create("TextLabel", {
                BackgroundTransparency = 1,
                Font = Config.Font,
                Position = UDim2.new(0, 12, 0, 6),
                Size = UDim2.new(1, -24, 0, 16),
                Text = inputTitle,
                TextColor3 = Config.FontColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = holder,
            })

            local box = Create("TextBox", {
                BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                Font = Config.Font,
                Position = UDim2.new(0, 12, 0, 24),
                Size = UDim2.new(1, -24, 0, 22),
                Text = defaultValue,
                PlaceholderText = placeholder,
                TextColor3 = Config.FontColor,
                PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = holder,
            })
            AddCorner(box, 4)
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = box,
            })

            box.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    pcall(callback, box.Text)
                end
            end)
        end

        -- 下拉框
        function Tab:Dropdown(dropInfo)
            local dropTitle = dropInfo.Title or "Dropdown"
            local values = dropInfo.Values or {}
            local defaultValue = dropInfo.Value
            local callback = dropInfo.Callback or function() end

            local isOpen = false
            local currentValue = defaultValue

            local holder = Create("Frame", {
                BackgroundColor3 = Config.MainColor,
                Size = UDim2.new(1, 0, 0, 54),
                ClipsDescendants = false,
                ZIndex = 2,
                Parent = container,
            })
            AddCorner(holder, 6)
            AddStroke(holder, Config.OutlineColor, 1, 0)

            Create("TextLabel", {
                BackgroundTransparency = 1,
                Font = Config.Font,
                Position = UDim2.new(0, 12, 0, 6),
                Size = UDim2.new(1, -24, 0, 16),
                Text = dropTitle,
                TextColor3 = Config.FontColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 3,
                Parent = holder,
            })

            local display = Create("TextButton", {
                BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                Font = Config.Font,
                Position = UDim2.new(0, 12, 0, 26),
                Size = UDim2.new(1, -24, 0, 22),
                Text = tostring(currentValue or "请选择"),
                TextColor3 = Config.FontColor,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                ZIndex = 3,
                Parent = holder,
            })
            AddCorner(display, 4)
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                Parent = display,
            })

            -- 下拉列表
            local listFrame = Create("ScrollingFrame", {
                BackgroundColor3 = Config.MainColor,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 12, 0, 50),
                Size = UDim2.new(1, -24, 0, math.min(#values * 24, 150)),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2,
                Visible = false,
                ZIndex = 10,
                Parent = holder,
            })
            AddCorner(listFrame, 4)
            AddStroke(listFrame, Config.FeatherColor, 1, 0.5)
            Create("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = listFrame,
            })
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 4),
                PaddingRight = UDim.new(0, 4),
                Parent = listFrame,
            })

            for _, val in ipairs(values) do
                local optionBtn = Create("TextButton", {
                    BackgroundColor3 = Config.MainColor,
                    BackgroundTransparency = 0.3,
                    Font = Config.Font,
                    Size = UDim2.new(1, 0, 0, 22),
                    Text = tostring(val),
                    TextColor3 = Config.FontColor,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    ZIndex = 11,
                    Parent = listFrame,
                })
                AddCorner(optionBtn, 3)
                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 8),
                    Parent = optionBtn,
                })

                optionBtn.MouseEnter:Connect(function()
                    TweenService:Create(optionBtn, TweenInfo.new(0.1), {
                        BackgroundTransparency = 0,
                    }):Play()
                end)
                optionBtn.MouseLeave:Connect(function()
                    TweenService:Create(optionBtn, TweenInfo.new(0.1), {
                        BackgroundTransparency = 0.3,
                    }):Play()
                end)

                optionBtn.MouseButton1Click:Connect(function()
                    currentValue = val
                    display.Text = tostring(val)
                    listFrame.Visible = false
                    isOpen = false
                    pcall(callback, val)
                end)
            end

            display.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                listFrame.Visible = isOpen
            end)
        end

        -- 标签
        function Tab:Label(text)
            Create("TextLabel", {
                BackgroundTransparency = 1,
                Font = Config.Font,
                Size = UDim2.new(1, 0, 0, 20),
                Text = text,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = container,
            })
        end

        return Tab
    end

    return Window
end

-- 返回库
return FeatherUI
