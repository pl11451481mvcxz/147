local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local IS_MOBILE = true

local Device = {
    WindowSize   = UDim2.fromOffset(360, 280),   
    Corner       = UDim.new(0, 16),    
    TitleSize    = 15,
    ButtonSize   = 32,
    FloatBtnSize = 56,
    Font         = Enum.Font.GothamMedium,
}
if PlayerGui:FindFirstChild("MobileUI") then
    PlayerGui.MobileUI:Destroy()
end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui
local function createFeatheredStroke(parent, featherColor)
    featherColor = featherColor or Color3.fromRGB(255, 255, 255)
    
    
    local layers = {
        { thickness = 8,  transparency = 0.92 },
        { thickness = 6,  transparency = 0.85 },
        { thickness = 4,  transparency = 0.7  },
        { thickness = 2,  transparency = 0.45 },
        { thickness = 1,  transparency = 0.1  },
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
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = Device.WindowSize
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false   
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = Device.Corner
MainCorner.Parent = MainFrame
local MainStrokes = createFeatheredStroke(MainFrame, Color3.fromRGB(255, 255, 255))
MainFrame.Size = UDim2.fromOffset(0, 0)
MainFrame.BackgroundTransparency = 1
for _, s in ipairs(MainStrokes) do s.Transparency = 1 end

TweenService:Create(MainFrame,
    TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Size = Device.WindowSize, BackgroundTransparency = 0.08 }
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
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -110, 1, 0)
TitleLabel.Position = UDim2.fromOffset(16, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Mobile UI"
TitleLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
TitleLabel.TextSize = Device.TitleSize
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar
local dragging = false
local dragStart, startPos

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
MinimizeBtn.Size = UDim2.fromOffset(Device.ButtonSize, Device.ButtonSize)
MinimizeBtn.Position = UDim2.new(1, -(Device.ButtonSize * 2 + 16), 0, 6)
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

local MinStrokes = createFeatheredStroke(MinimizeBtn, Color3.fromRGB(255, 255, 255))
for i, s in ipairs(MinStrokes) do
    s.Transparency = math.min(s.Transparency + 0.15, 1)  
end
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(Device.ButtonSize, Device.ButtonSize)
CloseBtn.Position = UDim2.new(1, -Device.ButtonSize - 12, 0, 6)
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

local CloseStrokes = createFeatheredStroke(CloseBtn, Color3.fromRGB(255, 255, 255))
for i, s in ipairs(CloseStrokes) do
    s.Transparency = math.min(s.Transparency + 0.15, 1)
end
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Size = UDim2.fromOffset(Device.FloatBtnSize, Device.FloatBtnSize)
FloatingBtn.Position = UDim2.fromOffset(20, 200)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
FloatingBtn.BackgroundTransparency = 0.08
FloatingBtn.Text = "一个ui"
FloatingBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
FloatingBtn.TextSize = 16
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.AutoButtonColor = false
FloatingBtn.Visible = false
FloatingBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatingBtn

local FloatStrokes = createFeatheredStroke(FloatingBtn, Color3.fromRGB(255, 255, 255))

local floatDragging = false
local floatDragStart, floatStartPos
local floatMoved = false

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
        { Size = UDim2.fromOffset(Device.FloatBtnSize, Device.FloatBtnSize) }
    ):Play()
end

local function restore()
    FloatingBtn.Visible = false
    MainFrame.Visible = true
    
    TweenService:Create(MainFrame,
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Size = Device.WindowSize, BackgroundTransparency = 0.08 }
    ):Play()
    
    local targets = {0.92, 0.85, 0.7, 0.45, 0.1}
    for i, s in ipairs(MainStrokes) do
        TweenService:Create(s, TweenInfo.new(0.4), { Transparency = targets[i] }):Play()
    end
end

MinimizeBtn.MouseButton1Click:Connect(minimize)

FloatingBtn.MouseButton1Click:Connect(function()
    if not floatMoved then
        restore()
    end
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
    ScreenGui:Destroy()
end)
