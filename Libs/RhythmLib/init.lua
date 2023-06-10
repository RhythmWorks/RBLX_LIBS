local Rhythm_Library = {}

for _, obj in pairs(game:GetService("CoreGui"):GetChildren()) do
    if obj:GetAttribute("Rhythm_Lib") or obj:GetAttribute("Rhythm_Notification") then
        obj:Destroy()
    end
end

loadstring(game:HttpGet("https://api.irisapp.ca/Scripts/IrisInstanceProtect.lua"))()

local Collection = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local _toggling = false
local _busy = false

local notificationQueue = {}
local assertions = {
    "Invalid type for property \"name\"",
    "Missing argument",
    "Tried to duplicate tab name",
}

local function dragify(Frame)
    local dragToggle, dragStart, dragInput, startPos, Delta, Position
    
    local function updateInput(input)
        Delta = input.Position - dragStart
        Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
        local tween = game:GetService("TweenService"):Create(Frame, TweenInfo.new(.25), {Position = Position})
        if not _busy then
            tween:Play()
            tween.Completed:Wait()
        end
        getgenv().Rhythm_Library.OriginalPos = Frame.Position
    end
    
    Frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragToggle = true
            dragStart = input.Position
            startPos = Frame.Position
            input.Changed:Connect(function()
                if (input.UserInputState == Enum.UserInputState.End) then
                    dragToggle = false
                end
            end)
        end
    end)
    
    Frame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if (input == dragInput and dragToggle) then
            updateInput(input)
        end
    end)
end

local function updateCanvas(scrollingFrame, layout, scrollingDirection, padding, shouldTween)
    padding = padding or 0
	if scrollingDirection == Enum.ScrollingDirection.XY then
        if shouldTween then
            game:GetService("TweenService"):Create(scrollingFrame, TweenInfo.new(0.25), {
                CanvasSize = UDim2.fromOffset(layout.AbsoluteContentSize.X + padding, layout.AbsoluteContentSize.Y + padding)
            }):Play()
        end
		scrollingFrame.CanvasSize = UDim2.fromOffset(layout.AbsoluteContentSize.X + padding, layout.AbsoluteContentSize.Y + padding)
	elseif scrollingDirection == Enum.ScrollingDirection.X then
        if shouldTween then
            game:GetService("TweenService"):Create(scrollingFrame, TweenInfo.new(0.25), {
                CanvasSize = UDim2.fromOffset(layout.AbsoluteContentSize.X + padding, layout.AbsoluteContentSize.Y)
            }):Play()
        end
        scrollingFrame.CanvasSize = UDim2.fromOffset(layout.AbsoluteContentSize.X + padding, layout.AbsoluteContentSize.Y)
	elseif scrollingDirection == Enum.ScrollingDirection.Y then
        if shouldTween then
            game:GetService("TweenService"):Create(scrollingFrame, TweenInfo.new(0.25), {
                CanvasSize = UDim2.fromOffset(layout.AbsoluteContentSize.X, layout.AbsoluteContentSize.Y + padding)
            }):Play()
        end
        scrollingFrame.CanvasSize = UDim2.fromOffset(layout.AbsoluteContentSize.X, layout.AbsoluteContentSize.Y + padding)
	end
end

local function updateFrame(frame, label: TextLabel)
    local frameSizeX = frame.Size.X.Offset
    local labelBoundsX = label.TextBounds.X

    if labelBoundsX > 50 then
        local result = frameSizeX + (labelBoundsX - frameSizeX) + 35

        local Fixed = Instance.new("StringValue")
        Fixed.Name = "Fixed"
        Fixed.Value = result + 42
        Fixed.Parent = label

        local Fixed2 = Instance.new("StringValue")
        Fixed2.Name = "Fixed2"
        Fixed2.Value = result
        Fixed2.Parent = label

        frame.Size = UDim2.fromOffset(result, frame.Size.Y.Offset)
    end
end

local function generateId(length)
    length = length or 12

    local types = {
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
        "0123456789"
    }

    local id = ""

    for i = 1, length do
        local using = types[math.random(#types)]
        local rand = math.random(#using)
        id = id .. using:sub(rand, rand)
    end

    return id
end

local function newConnection()
    local num = 0
    for _, _ in pairs(getgenv().Rhythm_Library.Connections) do
        num = num + 1
    end
    return num + 1
end

function Rhythm_Library:Window(windowOptions)
    local windowName = windowOptions.name or windowOptions.Name or windowOptions[1] or windowOptions or "RHYTHMLIB"
    assert(typeof(windowName) == "string", string.format("%s %s", assertions[1] .. "; user tried to set name to:", windowName))

    local Rhythm_Lib = Instance.new("ScreenGui")
    local Container_Drag = Instance.new("Frame")
    local Container_Main = Instance.new("Frame")
    local Image_Main = Instance.new("ImageLabel")
    local Container_TopBar = Instance.new("Frame")
    local Stroke_TopBar = Instance.new("UIStroke")
    local Title = Instance.new("TextLabel")
    local Close = Instance.new("TextButton")
    local Container_Tabs = Instance.new("Frame")
    local Container_TabsScrolling = Instance.new("Frame")
    local Scrolling_Tabs = Instance.new("ScrollingFrame")
    local ListLayout_Tabs = Instance.new("UIListLayout")
    local Stroke_Tabs = Instance.new("UIStroke")
    local Container_TabView = Instance.new("Frame")
    local Stroke_Main = Instance.new("UIStroke")

    Rhythm_Lib.Name = generateId(16)
    Rhythm_Lib.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Rhythm_Lib:SetAttribute("Rhythm_Lib", true)
    ProtectInstance(Rhythm_Lib)
    Rhythm_Lib.Parent = CoreGui
    
    Container_Drag.Name = "Container_Drag"
    Container_Drag.AnchorPoint = Vector2.new(0.5, 0.5)
    Container_Drag.BackgroundColor3 = Color3.new(1, 1, 1)
    Container_Drag.BackgroundTransparency = 1
    Container_Drag.BorderSizePixel = 0
    Container_Drag.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container_Drag.Size = UDim2.new(0, 560, 0, 326)
    Container_Drag.Parent = Rhythm_Lib

    Container_Main.Name = "Container_Main"
    Container_Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Container_Main.BackgroundColor3 = Color3.new(0.0352941, 0.0352941, 0.0352941)
    Container_Main.BorderSizePixel = 0
    Container_Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container_Main.Size = UDim2.new(0.899999976, 0, 0.850000024, 0)
    Container_Main.Parent = Container_Drag

    Image_Main.Name = "Image_Main"
    Image_Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Image_Main.BackgroundColor3 = Color3.new(1, 1, 1)
    Image_Main.BackgroundTransparency = 1
    Image_Main.BorderSizePixel = 0
    Image_Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Image_Main.Size = UDim2.new(1, 0, 1.00000024, 0)
    Image_Main.ZIndex = 0
    Image_Main.Image = "rbxassetid://13024447759"
    Image_Main.ScaleType = Enum.ScaleType.Crop
    Image_Main.Parent = Container_Main

    Stroke_Main.Name = "Stroke_Main"
    Stroke_Main.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    Stroke_Main.Color = Color3.fromRGB(147, 0, 180)
    Stroke_Main.LineJoinMode = Enum.LineJoinMode.Miter
    Stroke_Main.Parent = Container_Main

    Container_TopBar.Name = "Container_TopBar"
    Container_TopBar.AnchorPoint = Vector2.new(0.5, 0.5)
    Container_TopBar.BackgroundColor3 = Color3.new(0, 0, 0)
    Container_TopBar.BackgroundTransparency = 0.3499999940395355
    Container_TopBar.BorderSizePixel = 0
    Container_TopBar.Position = UDim2.new(0.5, 0, 0.0394087471, 0)
    Container_TopBar.Size = UDim2.new(1, 0, 0.0788177326, 0)
    Container_TopBar.Parent = Container_Main

    Title.Name = "Title"
    Title.AnchorPoint = Vector2.new(0.5, 0.5)
    Title.BackgroundColor3 = Color3.new(1, 1, 1)
    Title.BackgroundTransparency = 1
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0.49, 0, 0.46, 0)
    Title.Size = UDim2.new(0.95, 0, 0.525, 0)
    Title.Font = Enum.Font.Roboto
    Title.Text = windowName
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextScaled = true
    Title.TextSize = 14
    Title.TextWrapped = true
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Container_TopBar

    Close.Name = "Close"
    Close.AnchorPoint = Vector2.new(0.5, 0.5)
    Close.BackgroundColor3 = Color3.new(1, 1, 1)
    Close.BackgroundTransparency = 1
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(0.98, 0, 0.483999997, 0)
    Close.Size = UDim2.new(0.0450000018, 0, 0.629000008, 0)
    Close.AutoButtonColor = false
    Close.Font = Enum.Font.Roboto
    Close.Text = "X"
    Close.TextColor3 = Color3.new(1, 1, 1)
    Close.TextScaled = true
    Close.TextSize = 14
    Close.TextWrapped = true
    Close.Parent = Container_TopBar

    Stroke_TopBar.Name = "Stroke_TopBar"
    Stroke_TopBar.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    Stroke_TopBar.Color = Color3.fromRGB(147, 0, 180)
    Stroke_TopBar.LineJoinMode = Enum.LineJoinMode.Miter
    Stroke_TopBar.Parent = Container_TopBar

    Container_Tabs.Name = "Container_Tabs"
    Container_Tabs.AnchorPoint = Vector2.new(0.5, 0.5)
    Container_Tabs.BackgroundColor3 = Color3.new(0, 0, 0)
    Container_Tabs.BackgroundTransparency = 0.3499999940395355
    Container_Tabs.BorderSizePixel = 0
    Container_Tabs.ClipsDescendants = true
    Container_Tabs.Position = UDim2.new(0.5, 0, 0.143746063, 0)
    Container_Tabs.Size = UDim2.new(1, 0, 0.129857048, 0)
    Container_Tabs.Parent = Container_Main

    Container_TabsScrolling.Name = "Container_TabsScrolling"
    Container_TabsScrolling.AnchorPoint = Vector2.new(0.5, 0.5)
    Container_TabsScrolling.BackgroundColor3 = Color3.new(1, 1, 1)
    Container_TabsScrolling.BackgroundTransparency = 1
    Container_TabsScrolling.BorderSizePixel = 0
    Container_TabsScrolling.ClipsDescendants = true
    Container_TabsScrolling.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container_TabsScrolling.Size = UDim2.new(0.975000024, 0, 0.850000024, 0)
    Container_TabsScrolling.Parent = Container_Tabs

    Scrolling_Tabs.Name = "Scrolling_Tabs"
    Scrolling_Tabs.Active = true
    Scrolling_Tabs.AnchorPoint = Vector2.new(0.5, 0.5)
    Scrolling_Tabs.BackgroundColor3 = Color3.new(1, 1, 1)
    Scrolling_Tabs.BackgroundTransparency = 1
    Scrolling_Tabs.BorderSizePixel = 0
    Scrolling_Tabs.ClipsDescendants = false
    Scrolling_Tabs.ElasticBehavior = Enum.ElasticBehavior.Never
    Scrolling_Tabs.Position = UDim2.new(0.5, 0, 0.48, 0)
    Scrolling_Tabs.Size = UDim2.new(0.985, 0, 0.8, 0)
    Scrolling_Tabs.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
    Scrolling_Tabs.ScrollBarThickness = 2
    Scrolling_Tabs.ScrollBarImageColor3 = Color3.fromRGB(160, 0, 166)
    Scrolling_Tabs.ScrollingDirection = Enum.ScrollingDirection.X
    Scrolling_Tabs.Parent = Container_TabsScrolling

    ListLayout_Tabs.Name = "ListLayout_Tabs"
    ListLayout_Tabs.FillDirection = Enum.FillDirection.Horizontal
    ListLayout_Tabs.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout_Tabs.Padding = UDim.new(0, 4)
    ListLayout_Tabs.Parent = Scrolling_Tabs

    Stroke_Tabs.Name = "Stroke_Tabs"
    Stroke_Tabs.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    Stroke_Tabs.Color = Color3.fromRGB(147, 0, 180)
    Stroke_Tabs.LineJoinMode = Enum.LineJoinMode.Miter
    Stroke_Tabs.Parent = Container_Tabs

    Container_TabView.Name = "Container_TabView"
    Container_TabView.AnchorPoint = Vector2.new(0.5, 0.5)
    Container_TabView.BackgroundColor3 = Color3.new(0, 0, 0)
    Container_TabView.BackgroundTransparency = 1
    Container_TabView.BorderSizePixel = 0
    Container_TabView.ClipsDescendants = true
    Container_TabView.Position = UDim2.new(0.5, 0, 0.602833867, 0)
    Container_TabView.Size = UDim2.new(1, 0, 0.788318515, 0)
    Container_TabView.Parent = Container_Main

    self.UI = Rhythm_Lib
    self.Drag = Container_Drag
    self.Close = Close
    self.Title = Title
    self.ScrollTabs = Scrolling_Tabs
    self.TabView = Container_TabView

    return self:_WindowCode()
end

function Rhythm_Library:_WindowCode()
    local lib = self

    dragify(self.Drag)
    updateCanvas(self.ScrollTabs, self.ScrollTabs.ListLayout_Tabs, Enum.ScrollingDirection.X)

    self.ScrollTabs.DescendantAdded:Connect(function()
        updateCanvas(self.ScrollTabs, self.ScrollTabs.ListLayout_Tabs, Enum.ScrollingDirection.X)
    end)

    self.Close.MouseButton1Click:Connect(function()
        self:DestroyWindow()
    end)

    local windowFuncs = {}

    function windowFuncs:DestroyWindow()
        lib:DestroyWindow()
    end

    function windowFuncs:Tab(tabOptions)
        local tabName = tabOptions.name or tabOptions.Name or tabOptions[1] or tabOptions or "New Tab"
        assert(typeof(tabName) == "string", string.format("%s %s", assertions[1] .. "; user tried to set name to:", tabName))
        assert(not lib.TabView:FindFirstChild(tabName), string.format("%s %s", assertions[3] .. "; user tried to set name to:", tabName))

        local Container_TabButton = Instance.new("Frame")
        local Corner_TabButton = Instance.new("UICorner")
        local Text_TabButton = Instance.new("TextLabel")
        local TextConstraint_TabButton = Instance.new("UITextSizeConstraint")
        local Image_TabButton = Instance.new("ImageLabel")
        local Button_TabButton = Instance.new("TextButton")
        local Stroke_TabButton = Instance.new("UIStroke")
        local Container_TabViewScrolling = Instance.new("Frame")
        local Scrolling_TabView = Instance.new("ScrollingFrame")
        local ListLayout_TabView = Instance.new("UIListLayout")
        
        Container_TabButton.Name = tabName
        Container_TabButton.AnchorPoint = Vector2.new(0.5, 0.5)
        Container_TabButton.BackgroundColor3 = Color3.new(0.298039, 0, 0.364706)
        Container_TabButton.BorderSizePixel = 0
        Container_TabButton.Size = UDim2.new(0, 83, 0, 19)
        Collection:AddTag(Container_TabButton, tabName)
        Container_TabButton.Parent = lib.ScrollTabs
        
        Corner_TabButton.Name = "Corner_TabButton"
        Corner_TabButton.CornerRadius = UDim.new(0.2, 0)
        Corner_TabButton.Parent = Container_TabButton
        
        Text_TabButton.Name = "Text_TabButton"
        Text_TabButton.AnchorPoint = Vector2.new(0.5, 0.5)
        Text_TabButton.BackgroundColor3 = Color3.new(1, 1, 1)
        Text_TabButton.BackgroundTransparency = 1
        Text_TabButton.BorderSizePixel = 0
        Text_TabButton.Position = UDim2.new(0.5, 0, 0.5, 0)
        Text_TabButton.Size = UDim2.new(0.95, 0, 0.95, 0)
        Text_TabButton.Font = Enum.Font.Oswald
        Text_TabButton.Text = tabName
        Text_TabButton.TextColor3 = Color3.new(1, 1, 1)
        Text_TabButton.TextScaled = true
        Text_TabButton.TextSize = 14
        Text_TabButton.TextWrapped = true
        Text_TabButton.Parent = Container_TabButton
        updateFrame(Container_TabButton, Text_TabButton)
        
        TextConstraint_TabButton.MaxTextSize = 18
        TextConstraint_TabButton.Parent = Text_TabButton
        
        Image_TabButton.Name = "Image_TabButton"
        Image_TabButton.AnchorPoint = Vector2.new(0.5, 0.5)
        Image_TabButton.ImageColor3 = Color3.fromRGB(162, 0, 255)
        Image_TabButton.BackgroundTransparency = 1
        Image_TabButton.ImageTransparency = 0.5
        Image_TabButton.BorderSizePixel = 0
        Image_TabButton.Position = UDim2.new(0.5, 0, 0.5, 0)
        Image_TabButton.Size = UDim2.new(1, 0, 1, 0)
        Image_TabButton.ZIndex = 0
        Image_TabButton.Image = "rbxassetid://13120553044"
        Image_TabButton.ScaleType = Enum.ScaleType.Crop
        Image_TabButton.Parent = Container_TabButton
        
        Button_TabButton.Name = "Button_TabButton"
        Button_TabButton.AnchorPoint = Vector2.new(0.5, 0.5)
        Button_TabButton.BackgroundColor3 = Color3.new(1, 1, 1)
        Button_TabButton.BackgroundTransparency = 1
        Button_TabButton.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
        Button_TabButton.Position = UDim2.new(0.5, 0, 0.5, 0)
        Button_TabButton.Size = UDim2.new(1, 0, 1, 0)
        Button_TabButton.Font = Enum.Font.SourceSans
        Button_TabButton.Text = ""
        Button_TabButton.TextColor3 = Color3.new(0, 0, 0)
        Button_TabButton.TextSize = 14
        Button_TabButton.TextTransparency = 1
        Button_TabButton.Parent = Container_TabButton

        Stroke_TabButton.Name = "Stroke_TabButton"
        Stroke_TabButton.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        Stroke_TabButton.Color = Color3.fromRGB(0, 0, 0)
        Stroke_TabButton.LineJoinMode = Enum.LineJoinMode.Round
        Stroke_TabButton.Parent = Container_TabButton

        Container_TabViewScrolling.Name = tabName
        Container_TabViewScrolling.AnchorPoint = Vector2.new(0.5, 0.5)
        Container_TabViewScrolling.BackgroundColor3 = Color3.new(1, 1, 1)
        Container_TabViewScrolling.BackgroundTransparency = 1
        Container_TabViewScrolling.BorderSizePixel = 0
        Container_TabViewScrolling.ClipsDescendants = true
        Container_TabViewScrolling.Position = UDim2.new(0.5, 0, 0.506659389, 0)
        Container_TabViewScrolling.Size = UDim2.new(0.975000024, 0, 0.903275609, 0)
        Container_TabViewScrolling.Visible = false
        Container_TabViewScrolling:SetAttribute("Toggled", false)
        Container_TabViewScrolling.Parent = lib.TabView
    
        Scrolling_TabView.Name = "Scrolling_TabView"
        Scrolling_TabView.Active = true
        Scrolling_TabView.AnchorPoint = Vector2.new(0.5, 0.5)
        Scrolling_TabView.BackgroundColor3 = Color3.new(1, 1, 1)
        Scrolling_TabView.BackgroundTransparency = 1
        Scrolling_TabView.BorderSizePixel = 0
        Scrolling_TabView.ClipsDescendants = false
        Scrolling_TabView.ElasticBehavior = Enum.ElasticBehavior.Never
        Scrolling_TabView.Position = UDim2.new(0.5, 0, 0.5, 0)
        Scrolling_TabView.Size = UDim2.new(0.975000024, 0, 0.97, 0)
        Scrolling_TabView.ScrollBarImageColor3 = Color3.fromRGB(160, 0, 166)
        Scrolling_TabView.ScrollBarThickness = 2
        Scrolling_TabView.Parent = Container_TabViewScrolling

        ListLayout_TabView.Name = "ListLayout_TabView"
        ListLayout_TabView.FillDirection = Enum.FillDirection.Vertical
        ListLayout_TabView.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout_TabView.Padding = UDim.new(0, 4)
        ListLayout_TabView.Parent = Scrolling_TabView

        self[tabName] = {}
        self[tabName].Button = Button_TabButton
        self[tabName].Container = Container_TabButton
        self[tabName].ContainerTabView = Container_TabViewScrolling
        self[tabName].ScrollTabView = Scrolling_TabView
        self[tabName].Label = Text_TabButton
        self[tabName].tabName = tabName

        return self:_TabCode(self[tabName])
    end

    function windowFuncs:_TabCode(data)
        updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)

        local tabs = lib.TabView:GetChildren()

        local fixed = data.Label:FindFirstChild("Fixed") or 125
        local fixed2 = data.Label:FindFirstChild("Fixed2") or 83

        if typeof(fixed) == "Instance" then
            fixed = fixed.Value
        end

        if typeof(fixed2) == "Instance" then
            fixed2 = fixed2.Value
        end

        if not tabs[2] then
            data.ContainerTabView.Visible = true
            data.Container:SetAttribute("Toggled", true)

            data.Container:TweenSize(
                UDim2.new(0, fixed, 0, 19),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quint,
                0.4,
                true,
                function()
                    updateCanvas(lib.ScrollTabs, lib.ScrollTabs.ListLayout_Tabs, Enum.ScrollingDirection.X, nil, true)
                end
            )
        end

        data.Button.MouseEnter:Connect(function()
            if data.Container:GetAttribute("Toggled") then return end

            data.Container:TweenSize(
                UDim2.new(0, fixed, 0, 19),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quint,
                0.4,
                true,
                function()
                    updateCanvas(lib.ScrollTabs, lib.ScrollTabs.ListLayout_Tabs, Enum.ScrollingDirection.X, nil, true)
                end
            )
        end)

        data.Button.MouseLeave:Connect(function()
            if data.Container:GetAttribute("Toggled") then return end
            
            data.Container:TweenSize(
                UDim2.new(0, fixed2, 0, 19),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quint,
                0.4,
                true,
                function()
                    updateCanvas(lib.ScrollTabs, lib.ScrollTabs.ListLayout_Tabs, Enum.ScrollingDirection.X, nil, true)
                end
            )
        end)

        data.Button.MouseButton1Click:Connect(function()
            if data.Container:GetAttribute("Toggled") then return end

            for _, tab in pairs(lib.TabView:GetChildren()) do
                if tab.Name == data.ContainerTabView.Name then
                    tab.Visible = true
                    data.Container:SetAttribute("Toggled", true)
                    data.Container:TweenSize(
                        UDim2.new(0, fixed, 0, 19),
                        Enum.EasingDirection.Out,
                        Enum.EasingStyle.Quint,
                        0.4,
                        true,
                        function()
                            updateCanvas(lib.ScrollTabs, lib.ScrollTabs.ListLayout_Tabs, Enum.ScrollingDirection.X, nil, true)
                        end
                    )
                else
                    tab.Visible = false

                    local tbView = Collection:GetTagged(tab.Name)[1]
                    local tbFixed2 = tbView["Text_TabButton"]:FindFirstChild("Fixed2") or 83

                    if typeof(tbFixed2) == "Instance" then
                        tbFixed2 = tbFixed2.Value
                    end

                    tbView:SetAttribute("Toggled", false)
                    tbView:TweenSize(
                        UDim2.new(0, tbFixed2, 0, 19),
                        Enum.EasingDirection.Out,
                        Enum.EasingStyle.Quint,
                        0.4,
                        true,
                        function()
                            updateCanvas(lib.ScrollTabs, lib.ScrollTabs.ListLayout_Tabs, Enum.ScrollingDirection.X, nil, true)
                        end
                    )
                end
            end
        end)

        local function newIndex()
            return #data.ScrollTabView:GetChildren() + 1
        end

        local function createSectionEnder()
            local Ender = Instance.new("Frame")
            local Image_Ender = Instance.new("ImageLabel")

            Ender.Name = newIndex()
            Ender.Parent = data.ScrollTabView
            Ender.BackgroundColor3 = Color3.new(0.345098, 0, 0.403922)
            Ender.BackgroundTransparency = 0.25
            Ender.BorderSizePixel = 0
            Ender.Position = UDim2.new(-0.00223214296, 0, 0.625, 0)
            Ender.Size = UDim2.new(0, 469, 0, 4)
            
            Image_Ender.Name = "Image_Ender"
            Image_Ender.Parent = Ender
            Image_Ender.AnchorPoint = Vector2.new(0.5, 0.5)
            Image_Ender.BackgroundColor3 = Color3.new(1, 1, 1)
            Image_Ender.BackgroundTransparency = 1
            Image_Ender.BorderSizePixel = 0
            Image_Ender.Position = UDim2.new(0.5, 0, 0.5, 0)
            Image_Ender.Size = UDim2.new(1, 0, 1, 0)
            Image_Ender.ZIndex = 0
            Image_Ender.Image = "rbxassetid://13120553044"
            Image_Ender.ImageColor3 = Color3.new(0.831373, 0, 1)
            Image_Ender.ImageTransparency = 0.75
            Image_Ender.ScaleType = Enum.ScaleType.Crop

            updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)
        end

        local function createSectionDivider()
            local Divider = Instance.new("Frame")

            Divider.Name = newIndex()
            Divider.Parent = data.ScrollTabView
            Divider.BackgroundColor3 = Color3.new(1, 1, 1)
            Divider.BackgroundTransparency = 1
            Divider.BorderSizePixel = 0
            Divider.Position = UDim2.new(-0.00223214296, 0, 0.625, 0)
            Divider.Size = UDim2.new(0, 469, 0, 9)

            updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)
        end

        local function createSectionStarter(sectionName)
            local Starter = Instance.new("Frame")
            local Corner_Starter = Instance.new("UICorner")
            local Label_Starter = Instance.new("TextLabel")
            local Constraint_Label = Instance.new("UITextSizeConstraint")
            local Image_Starter = Instance.new("ImageLabel")

            Starter.Name = newIndex()
            Starter.Parent = data.ScrollTabView
            Starter.BackgroundColor3 = Color3.fromRGB(88, 0, 103)
            Starter.BackgroundTransparency = 0.250
            Starter.BorderSizePixel = 0
            Starter.Position = UDim2.new(-0.00223214296, 0, 0.625, 0)
            Starter.Size = UDim2.new(0, 469, 0, 18)

            Corner_Starter.CornerRadius = UDim.new(0.25, 0)
            Corner_Starter.Name = "Corner_Starter"
            Corner_Starter.Parent = Starter

            Label_Starter.Name = "Label_Starter"
            Label_Starter.Parent = Starter
            Label_Starter.AnchorPoint = Vector2.new(0.5, 0.5)
            Label_Starter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Label_Starter.BackgroundTransparency = 1.000
            Label_Starter.BorderSizePixel = 0
            Label_Starter.Position = UDim2.new(0.5, 0, 0.5, 0)
            Label_Starter.Size = UDim2.new(1, 0, 0.9, 0)
            Label_Starter.Font = Enum.Font.SourceSans
            Label_Starter.Text = sectionName
            Label_Starter.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label_Starter.TextScaled = true
            Label_Starter.TextSize = 14.000
            Label_Starter.TextWrapped = true

            Constraint_Label.Name = "Constraint_Label"
            Constraint_Label.Parent = Label_Starter
            Constraint_Label.MaxTextSize = 16

            Image_Starter.Name = "Image_Starter"
            Image_Starter.Parent = Starter
            Image_Starter.AnchorPoint = Vector2.new(0.5, 0.5)
            Image_Starter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Image_Starter.BackgroundTransparency = 1.000
            Image_Starter.BorderSizePixel = 0
            Image_Starter.Position = UDim2.new(0.5, 0, 0.5, 0)
            Image_Starter.Size = UDim2.new(1, 0, 1, 0)
            Image_Starter.ZIndex = 0
            Image_Starter.Image = "rbxassetid://13120553044"
            Image_Starter.ImageColor3 = Color3.fromRGB(212, 0, 255)
            Image_Starter.ImageTransparency = 0.750
            Image_Starter.ScaleType = Enum.ScaleType.Crop

            updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)
        end

        local tabFuncs = {}

        function tabFuncs:Section(sectionOptions)
            local sectionName = sectionOptions.name or sectionOptions.Name or sectionOptions[1] or sectionOptions or "New Section"
            assert(typeof(sectionName) == "string", string.format("%s %s", assertions[1] .. "; user tried to set name to:", sectionName))

            local num = 0
            for _, obj in pairs(data.ScrollTabView:GetChildren()) do
                if obj:FindFirstChild("Label_Starter") then
                    num = num + 1
                end
            end

            if num > 0 then
                createSectionEnder()
                createSectionDivider()
            end
            createSectionStarter(sectionName)

            local sectionFuncs = {}

            function sectionFuncs:Label(labelOptions)
                local labelText = labelOptions.name or labelOptions.Name or labelOptions[1] or labelOptions or "New Label"
                assert(typeof(labelText) == "string", string.format("%s %s", assertions[1] .. "; user tried to set text to:", labelText))

                local Item_Label = Instance.new("TextLabel")
                local Corner_Label = Instance.new("UICorner")
                local Constraint_Label = Instance.new("UITextSizeConstraint")
                local Image_Label = Instance.new("ImageLabel")

                Item_Label.Name = newIndex()
                Item_Label.Parent = data.ScrollTabView
                Item_Label.AnchorPoint = Vector2.new(0.5, 0.5)
                Item_Label.BackgroundColor3 = Color3.new(0.109804, 0, 0.152941)
                Item_Label.Position = UDim2.new(-0.00886476971, 0, 0.254924744, 0)
                Item_Label.Size = UDim2.new(0, 470, 0, 22)
                Item_Label.Font = Enum.Font.SourceSans
                Item_Label.Text = labelText
                Item_Label.TextColor3 = Color3.new(0.796078, 0.796078, 0.796078)
                Item_Label.TextScaled = true
                Item_Label.TextSize = 14
                Item_Label.TextWrapped = true
                
                Corner_Label.Name = "Corner_Label"
                Corner_Label.Parent = Item_Label
                Corner_Label.CornerRadius = UDim.new(0.200000003, 0)
                
                Constraint_Label.Name = "Constraint_Label"
                Constraint_Label.Parent = Item_Label
                Constraint_Label.MaxTextSize = 14
                
                Image_Label.Name = "Image_Label"
                Image_Label.Parent = Item_Label
                Image_Label.AnchorPoint = Vector2.new(0.5, 0.5)
                Image_Label.BackgroundColor3 = Color3.new(1, 1, 1)
                Image_Label.BackgroundTransparency = 1
                Image_Label.BorderSizePixel = 0
                Image_Label.Position = UDim2.new(0.5, 0, 0.5, 0)
                Image_Label.Size = UDim2.new(1, 0, 1, 0)
                Image_Label.ZIndex = 0
                Image_Label.Image = "rbxassetid://13120553044"
                Image_Label.ImageColor3 = Color3.new(0.831373, 0, 1)
                Image_Label.ImageTransparency = 0.75
                Image_Label.ScaleType = Enum.ScaleType.Crop

                updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)

                local toReturn = {}

                function toReturn:SetName(val)
                    assert(typeof(val) == "string", string.format("%s %s", assertions[1] .. "; user tried to set text to:", val))
                    Item_Label.Text = val
                end

                return toReturn
            end

            function sectionFuncs:Button(buttonOptions, callback)
                local buttonText = buttonOptions.name or buttonOptions.Name or buttonOptions[1] or buttonOptions or "New Button"
                assert(typeof(buttonText) == "string", string.format("%s %s", assertions[1] .. "; user tried to set text to:", buttonText))

                local _callback = buttonOptions.callback or buttonOptions.Callback or buttonOptions[2] or callback
                assert(typeof(_callback) == "function", assertions[1] .. "; user tried to set callback to an unknown value.")

                local Item_Button = Instance.new("TextButton")
                local Corner_Button = Instance.new("UICorner")
                local Constraint_Button = Instance.new("UITextSizeConstraint")
                local Image_Click = Instance.new("ImageLabel")
                local Image_Button = Instance.new("ImageLabel")

                Item_Button.Name = newIndex()
                Item_Button.Parent = data.ScrollTabView
                Item_Button.AnchorPoint = Vector2.new(0.5, 0.5)
                Item_Button.BackgroundColor3 = Color3.new(0.109804, 0, 0.152941)
                Item_Button.BorderSizePixel = 0
                Item_Button.Position = UDim2.new(0.490487695, 0, 0.446806997, 0)
                Item_Button.Size = UDim2.new(0, 470, 0, 22)
                Item_Button.AutoButtonColor = false
                Item_Button.Font = Enum.Font.SourceSans
                Item_Button.Text = buttonText
                Item_Button.TextColor3 = Color3.new(0.796078, 0.796078, 0.796078)
                Item_Button.TextScaled = true
                Item_Button.TextSize = 14
                Item_Button.TextWrapped = true
                
                Corner_Button.Name = "Corner_Button"
                Corner_Button.Parent = Item_Button
                Corner_Button.CornerRadius = UDim.new(0.200000003, 0)
                
                Constraint_Button.Name = "Constraint_Button"
                Constraint_Button.Parent = Item_Button
                Constraint_Button.MaxTextSize = 14
                
                Image_Click.Name = "Image_Click"
                Image_Click.Parent = Item_Button
                Image_Click.AnchorPoint = Vector2.new(0.5, 0.5)
                Image_Click.BackgroundColor3 = Color3.new(1, 1, 1)
                Image_Click.BackgroundTransparency = 1
                Image_Click.BorderSizePixel = 0
                Image_Click.Position = UDim2.new(0.970000029, 0, 0.524999976, 0)
                Image_Click.Size = UDim2.new(0.0350000001, 0, 0.75, 0)
                Image_Click.Image = "rbxassetid://11255462876"
                
                Image_Button.Name = "Image_Button"
                Image_Button.Parent = Item_Button
                Image_Button.AnchorPoint = Vector2.new(0.5, 0.5)
                Image_Button.BackgroundColor3 = Color3.new(1, 1, 1)
                Image_Button.BackgroundTransparency = 1
                Image_Button.BorderSizePixel = 0
                Image_Button.Position = UDim2.new(0.5, 0, 0.5, 0)
                Image_Button.Size = UDim2.new(1, 0, 1, 0)
                Image_Button.ZIndex = 0
                Image_Button.Image = "rbxassetid://13120553044"
                Image_Button.ImageColor3 = Color3.new(0.831373, 0, 1)
                Image_Button.ImageTransparency = 0.75
                Image_Button.ScaleType = Enum.ScaleType.Crop

                Item_Button.MouseButton1Click:Connect(function()
                    pcall(_callback)
                end)

                updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)

                local toReturn = {}

                function toReturn:SetName(val)
                    assert(typeof(val) == "string", string.format("%s %s", assertions[1] .. "; user tried to set text to:", val))
                    Item_Button.Text = val
                end

                return toReturn
            end

            function sectionFuncs:Dropdown(dropdownOptions, items, callback)
                local buttonText = dropdownOptions.name or dropdownOptions.Name or dropdownOptions[1] or "New Dropdown"
                assert(typeof(buttonText) == "string", string.format("%s %s", assertions[1] .. "; user tried to set text to:", buttonText))

                local _items = dropdownOptions.items or dropdownOptions.Items or dropdownOptions[2] or items
                assert(typeof(_items) == "table", assertions[1] .. "; user tried to set items to an unknown value.")

                local _callback = dropdownOptions.callback or dropdownOptions.Callback or dropdownOptions[3] or callback
                assert(typeof(_callback) == "function", assertions[1] .. "; user tried to set callback to an unknown value.")

                local Item_Button = Instance.new("TextButton")
                local Corner_Button = Instance.new("UICorner")
                local Constraint_Button = Instance.new("UITextSizeConstraint")
                local Image_Click = Instance.new("ImageLabel")
                local Image_Button = Instance.new("ImageLabel")

                Item_Button.Name = newIndex()
                Item_Button.Parent = data.ScrollTabView
                Item_Button.AnchorPoint = Vector2.new(0.5, 0.5)
                Item_Button.BackgroundColor3 = Color3.fromRGB(28, 0, 39)
                Item_Button.BorderSizePixel = 0
                Item_Button.Position = UDim2.new(0.490487695, 0, 0.446806997, 0)
                Item_Button.Size = UDim2.new(0, 470, 0, 22)
                Item_Button.AutoButtonColor = false
                Item_Button.Font = Enum.Font.SourceSans
                Item_Button.Text = buttonText .. ": N/A"
                Item_Button.TextColor3 = Color3.fromRGB(203, 203, 203)
                Item_Button.TextScaled = true
                Item_Button.TextSize = 14.000
                Item_Button.TextWrapped = true
                
                Corner_Button.CornerRadius = UDim.new(0.200000003, 0)
                Corner_Button.Name = "Corner_Button"
                Corner_Button.Parent = Item_Button
                
                Constraint_Button.Name = "Constraint_Button"
                Constraint_Button.Parent = Item_Button
                Constraint_Button.MaxTextSize = 14
                
                Image_Click.Name = "Image_Click"
                Image_Click.Parent = Item_Button
                Image_Click.AnchorPoint = Vector2.new(0.5, 0.5)
                Image_Click.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Image_Click.BackgroundTransparency = 1.000
                Image_Click.BorderSizePixel = 0
                Image_Click.Position = UDim2.new(0.970000029, 0, 0.524999976, 0)
                Image_Click.Rotation = 180
                Image_Click.Size = UDim2.new(0.0350000001, 0, 0.75, 0)
                Image_Click.Image = "rbxassetid://278543076"
                
                Image_Button.Name = "Image_Button"
                Image_Button.Parent = Item_Button
                Image_Button.AnchorPoint = Vector2.new(0.5, 0.5)
                Image_Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Image_Button.BackgroundTransparency = 1.000
                Image_Button.BorderSizePixel = 0
                Image_Button.Position = UDim2.new(0.5, 0, 0.5, 0)
                Image_Button.Size = UDim2.new(1, 0, 1, 0)
                Image_Button.ZIndex = 0
                Image_Button.Image = "rbxassetid://13120553044"
                Image_Button.ImageColor3 = Color3.fromRGB(212, 0, 255)
                Image_Button.ImageTransparency = 0.750
                Image_Button.ScaleType = Enum.ScaleType.Crop

                updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)

                local Item_Drop = Instance.new("Frame")
                local ListLayout_Drop = Instance.new("UIListLayout")

                Item_Drop.Name = newIndex()
                Item_Drop.Visible = false
                Item_Drop.Parent = data.ScrollTabView
                Item_Drop.Active = true
                Item_Drop.AnchorPoint = Vector2.new(0.5, 0.5)
                Item_Drop.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Item_Drop.BackgroundTransparency = 1.000
                Item_Drop.BorderSizePixel = 0
                Item_Drop.ClipsDescendants = true
                Item_Drop.Position = UDim2.new(0.5, 0, 0.5, 0)
                Item_Drop.Size = UDim2.new(0, 470, 0, 0)
                
                ListLayout_Drop.Name = "ListLayout_Drop"
                ListLayout_Drop.Parent = Item_Drop
                ListLayout_Drop.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout_Drop.Padding = UDim.new(0, 4)
                ListLayout_Drop.HorizontalAlignment = Enum.HorizontalAlignment.Center

                local toggled = false
                local selected = nil

                local function hideDrop()
                    Item_Drop:TweenSize(
                        UDim2.fromOffset(470, 0),
                        Enum.EasingDirection.Out,
                        Enum.EasingStyle.Sine,
                        .2,
                        true,
                        function()
                            Item_Drop.Visible = false
                            updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)
                        end
                    )
                end

                local function showDrop()
                    Item_Drop.Visible = true

                    Item_Drop:TweenSize(
                        UDim2.fromOffset(470, ListLayout_Drop.AbsoluteContentSize.Y),
                        Enum.EasingDirection.Out,
                        Enum.EasingStyle.Sine,
                        .2,
                        true,
                        function()
                            updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)
                        end
                    )
                end
                
                local function toggleDrop()
                    toggled = not toggled

                    if toggled then
                        TweenService:Create(Image_Click, TweenInfo.new(.15), {
                            Rotation = 0
                        }):Play()
                        showDrop()
                    else
                        TweenService:Create(Image_Click, TweenInfo.new(.15), {
                            Rotation = 180
                        }):Play()
                        hideDrop()
                    end
                end

                local function showColor(_item)
                    for _, item in pairs(Item_Drop:GetChildren()) do
                        if item:IsA("TextButton") then
                            if item.Name == _item then
                                item.BackgroundColor3 = Color3.fromRGB(143, 0, 200)
                            else
                                item.BackgroundColor3 = Color3.fromRGB(75, 0, 104)
                            end
                        end
                    end
                end

                for _, item in pairs(_items) do
                    local DropItem_Button = Instance.new("TextButton")
                    local Corner_Button = Instance.new("UICorner")
                    local Image_Button = Instance.new("ImageLabel")
                    local Constraint_Button = Instance.new("UITextSizeConstraint")

                    DropItem_Button.Name = item
                    DropItem_Button.Parent = Item_Drop
                    DropItem_Button.BackgroundColor3 = Color3.fromRGB(75, 0, 104)
                    DropItem_Button.Size = UDim2.fromOffset(399, 21)
                    DropItem_Button.Font = Enum.Font.SourceSans
                    DropItem_Button.Text = item
                    DropItem_Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                    DropItem_Button.TextScaled = true
                    DropItem_Button.TextSize = 14.000
                    DropItem_Button.TextWrapped = true
                    
                    Corner_Button.CornerRadius = UDim.new(0.100000001, 0)
                    Corner_Button.Name = "Corner_Button"
                    Corner_Button.Parent = DropItem_Button
                    
                    Image_Button.Name = "Image_Button"
                    Image_Button.Parent = DropItem_Button
                    Image_Button.AnchorPoint = Vector2.new(0.5, 0.5)
                    Image_Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Image_Button.BackgroundTransparency = 1.000
                    Image_Button.BorderSizePixel = 0
                    Image_Button.Position = UDim2.new(0.5, 0, 0.5, 0)
                    Image_Button.Size = UDim2.new(1, 0, 1, 0)
                    Image_Button.ZIndex = 0
                    Image_Button.Image = "rbxassetid://13120553044"
                    Image_Button.ImageColor3 = Color3.fromRGB(212, 0, 255)
                    Image_Button.ImageTransparency = 0.750
                    Image_Button.ScaleType = Enum.ScaleType.Crop
                    
                    Constraint_Button.Name = "Constraint_Button"
                    Constraint_Button.Parent = DropItem_Button
                    Constraint_Button.MaxTextSize = 14

                    DropItem_Button.MouseButton1Click:Connect(function()
                        if selected == item then
                            Item_Button.Text = buttonText .. ": N/A"
                            selected = nil
                            showColor("")
                        else
                            Item_Button.Text = buttonText .. ": " .. item
                            selected = item
                            showColor(item)
                        end
                        
                        toggleDrop()
                        pcall(_callback, selected)
                    end)
                end

                updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)
                Item_Button.MouseButton1Click:Connect(toggleDrop)

                local toReturn = {}

                function toReturn:SetName(val)
                    assert(typeof(val) == "string", string.format("%s %s", assertions[1] .. "; user tried to set text to:", val))
                    Item_Button.Text = val
                end

                return toReturn
            end

            function sectionFuncs:MultiDropdown(dropdownOptions, items, callback)
                local buttonText = dropdownOptions.name or dropdownOptions.Name or dropdownOptions[1] or "New Dropdown"
                assert(typeof(buttonText) == "string", string.format("%s %s", assertions[1] .. "; user tried to set text to:", buttonText))

                local _items = dropdownOptions.items or dropdownOptions.Items or dropdownOptions[2] or items
                assert(typeof(_items) == "table", assertions[1] .. "; user tried to set items to an unknown value.")

                local _callback = dropdownOptions.callback or dropdownOptions.Callback or dropdownOptions[3] or callback
                assert(typeof(_callback) == "function", assertions[1] .. "; user tried to set callback to an unknown value.")

                local Item_Button = Instance.new("TextButton")
                local Corner_Button = Instance.new("UICorner")
                local Constraint_Button = Instance.new("UITextSizeConstraint")
                local Image_Click = Instance.new("ImageLabel")
                local Image_Button = Instance.new("ImageLabel")

                Item_Button.Name = newIndex()
                Item_Button.Parent = data.ScrollTabView
                Item_Button.AnchorPoint = Vector2.new(0.5, 0.5)
                Item_Button.BackgroundColor3 = Color3.fromRGB(28, 0, 39)
                Item_Button.BorderSizePixel = 0
                Item_Button.Position = UDim2.new(0.490487695, 0, 0.446806997, 0)
                Item_Button.Size = UDim2.new(0, 470, 0, 22)
                Item_Button.AutoButtonColor = false
                Item_Button.Font = Enum.Font.SourceSans
                Item_Button.Text = buttonText .. ": N/A"
                Item_Button.TextColor3 = Color3.fromRGB(203, 203, 203)
                Item_Button.TextScaled = true
                Item_Button.TextSize = 14.000
                Item_Button.TextWrapped = true
                
                Corner_Button.CornerRadius = UDim.new(0.200000003, 0)
                Corner_Button.Name = "Corner_Button"
                Corner_Button.Parent = Item_Button
                
                Constraint_Button.Name = "Constraint_Button"
                Constraint_Button.Parent = Item_Button
                Constraint_Button.MaxTextSize = 14
                
                Image_Click.Name = "Image_Click"
                Image_Click.Parent = Item_Button
                Image_Click.AnchorPoint = Vector2.new(0.5, 0.5)
                Image_Click.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Image_Click.BackgroundTransparency = 1.000
                Image_Click.BorderSizePixel = 0
                Image_Click.Position = UDim2.new(0.970000029, 0, 0.524999976, 0)
                Image_Click.Rotation = 180
                Image_Click.Size = UDim2.new(0.0350000001, 0, 0.75, 0)
                Image_Click.Image = "rbxassetid://278543076"
                
                Image_Button.Name = "Image_Button"
                Image_Button.Parent = Item_Button
                Image_Button.AnchorPoint = Vector2.new(0.5, 0.5)
                Image_Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Image_Button.BackgroundTransparency = 1.000
                Image_Button.BorderSizePixel = 0
                Image_Button.Position = UDim2.new(0.5, 0, 0.5, 0)
                Image_Button.Size = UDim2.new(1, 0, 1, 0)
                Image_Button.ZIndex = 0
                Image_Button.Image = "rbxassetid://13120553044"
                Image_Button.ImageColor3 = Color3.fromRGB(212, 0, 255)
                Image_Button.ImageTransparency = 0.750
                Image_Button.ScaleType = Enum.ScaleType.Crop

                updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)

                local Item_Drop = Instance.new("Frame")
                local ListLayout_Drop = Instance.new("UIListLayout")

                Item_Drop.Name = newIndex()
                Item_Drop.Visible = false
                Item_Drop.Parent = data.ScrollTabView
                Item_Drop.Active = true
                Item_Drop.AnchorPoint = Vector2.new(0.5, 0.5)
                Item_Drop.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Item_Drop.BackgroundTransparency = 1.000
                Item_Drop.BorderSizePixel = 0
                Item_Drop.ClipsDescendants = true
                Item_Drop.Position = UDim2.new(0.5, 0, 0.5, 0)
                Item_Drop.Size = UDim2.new(0, 470, 0, 0)
                
                ListLayout_Drop.Name = "ListLayout_Drop"
                ListLayout_Drop.Parent = Item_Drop
                ListLayout_Drop.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout_Drop.Padding = UDim.new(0, 4)
                ListLayout_Drop.HorizontalAlignment = Enum.HorizontalAlignment.Center

                local toggled = false
                local selected = {}

                local function hideDrop()
                    Item_Drop:TweenSize(
                        UDim2.fromOffset(470, 0),
                        Enum.EasingDirection.Out,
                        Enum.EasingStyle.Sine,
                        .2,
                        true,
                        function()
                            Item_Drop.Visible = false
                            updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)
                        end
                    )
                end

                local function showDrop()
                    Item_Drop.Visible = true
                    
                    Item_Drop:TweenSize(
                        UDim2.fromOffset(470, ListLayout_Drop.AbsoluteContentSize.Y),
                        Enum.EasingDirection.Out,
                        Enum.EasingStyle.Sine,
                        .2,
                        true,
                        function()
                            updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)
                        end
                    )
                end
                
                local function toggleDrop()
                    toggled = not toggled

                    if toggled then
                        TweenService:Create(Image_Click, TweenInfo.new(.15), {
                            Rotation = 0
                        }):Play()
                        showDrop()
                    else
                        TweenService:Create(Image_Click, TweenInfo.new(.15), {
                            Rotation = 180
                        }):Play()
                        hideDrop()
                    end
                end

                local function showColors()
                    for _, item in pairs(Item_Drop:GetChildren()) do
                        if item:IsA("TextButton") then
                            if table.find(selected, item.Name) then
                                item.BackgroundColor3 = Color3.fromRGB(143, 0, 200)
                            else
                                item.BackgroundColor3 = Color3.fromRGB(75, 0, 104)
                            end
                        end
                    end
                end

                local function workText()
                    if not selected[1] then
                        Item_Button.Text = buttonText .. ": N/A"
                    else
                        local str = buttonText .. ": " .. selected[1]
                        local clone = table.clone(selected)
                        clone[1] = nil

                        for _, item in pairs(clone) do
                            str = str .. ", " .. item
                        end
                        Item_Button.Text = str
                    end
                end

                for _, item in pairs(_items) do
                    local DropItem_Button = Instance.new("TextButton")
                    local Corner_Button = Instance.new("UICorner")
                    local Image_Button = Instance.new("ImageLabel")
                    local Constraint_Button = Instance.new("UITextSizeConstraint")

                    DropItem_Button.Name = item
                    DropItem_Button.Parent = Item_Drop
                    DropItem_Button.BackgroundColor3 = Color3.fromRGB(75, 0, 104)
                    DropItem_Button.Size = UDim2.fromOffset(399, 21)
                    DropItem_Button.Font = Enum.Font.SourceSans
                    DropItem_Button.Text = item
                    DropItem_Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                    DropItem_Button.TextScaled = true
                    DropItem_Button.TextSize = 14.000
                    DropItem_Button.TextWrapped = true
                    
                    Corner_Button.CornerRadius = UDim.new(0.100000001, 0)
                    Corner_Button.Name = "Corner_Button"
                    Corner_Button.Parent = DropItem_Button
                    
                    Image_Button.Name = "Image_Button"
                    Image_Button.Parent = DropItem_Button
                    Image_Button.AnchorPoint = Vector2.new(0.5, 0.5)
                    Image_Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Image_Button.BackgroundTransparency = 1.000
                    Image_Button.BorderSizePixel = 0
                    Image_Button.Position = UDim2.new(0.5, 0, 0.5, 0)
                    Image_Button.Size = UDim2.new(1, 0, 1, 0)
                    Image_Button.ZIndex = 0
                    Image_Button.Image = "rbxassetid://13120553044"
                    Image_Button.ImageColor3 = Color3.fromRGB(212, 0, 255)
                    Image_Button.ImageTransparency = 0.750
                    Image_Button.ScaleType = Enum.ScaleType.Crop
                    
                    Constraint_Button.Name = "Constraint_Button"
                    Constraint_Button.Parent = DropItem_Button
                    Constraint_Button.MaxTextSize = 14

                    DropItem_Button.MouseButton1Click:Connect(function()
                        if table.find(selected, item) then
                            table.remove(selected, table.find(selected, item))
                        else
                            table.insert(selected, item)
                        end
                        
                        workText()
                        showColors()
                        pcall(_callback, selected)
                    end)
                end

                updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)
                Item_Button.MouseButton1Click:Connect(toggleDrop)
                
                local toReturn = {}

                function toReturn:SetName(val)
                    assert(typeof(val) == "string", string.format("%s %s", assertions[1] .. "; user tried to set text to:", val))
                    Item_Button.Text = val
                end

                return toReturn
            end

            function sectionFuncs:Toggle(toggleOptions, callback, default)
                local toggleText = toggleOptions.name or toggleOptions.Name or toggleOptions[1] or toggleOptions or "New Toggle"
                assert(typeof(toggleText) == "string", string.format("%s %s", assertions[1] .. "; user tried to set name to:", toggleText))

                local _callback = toggleOptions.callback or toggleOptions.Callback or toggleOptions[2] or callback
                assert(typeof(_callback) == "function", assertions[1] .. "; user tried to set callback to an unknown value.")

                local _default = toggleOptions.default or toggleOptions.Default or toggleOptions[3] or default or false
                assert(typeof(_default) == "boolean", assertions[1] .. "; user tried to set callback to an unknown value.")

                local Item_Toggle = Instance.new("TextButton")
                local Corner_Toggle = Instance.new("UICorner")
                local Constraint_Toggle = Instance.new("UITextSizeConstraint")
                local Image_Toggle = Instance.new("ImageLabel")
                local Frame_Toggle = Instance.new("Frame")
                local UICorner = Instance.new("UICorner")
                local UIStroke = Instance.new("UIStroke")

                Item_Toggle.Name = newIndex()
                Item_Toggle.Parent = data.ScrollTabView
                Item_Toggle.AnchorPoint = Vector2.new(0.5, 0.5)
                Item_Toggle.BackgroundColor3 = Color3.fromRGB(28, 0, 39)
                Item_Toggle.BorderSizePixel = 0
                Item_Toggle.Position = UDim2.new(0.490487695, 0, 0.446806997, 0)
                Item_Toggle.Size = UDim2.new(0, 470, 0, 24)
                Item_Toggle.AutoButtonColor = false
                Item_Toggle.Font = Enum.Font.SourceSans
                Item_Toggle.Text = toggleText
                Item_Toggle.TextColor3 = Color3.fromRGB(203, 203, 203)
                Item_Toggle.TextScaled = true
                Item_Toggle.TextSize = 14.000
                Item_Toggle.TextWrapped = true

                Corner_Toggle.CornerRadius = UDim.new(0.200000003, 0)
                Corner_Toggle.Name = "Corner_Toggle"
                Corner_Toggle.Parent = Item_Toggle

                Constraint_Toggle.Name = "Constraint_Toggle"
                Constraint_Toggle.Parent = Item_Toggle
                Constraint_Toggle.MaxTextSize = 14

                Image_Toggle.Name = "Image_Toggle"
                Image_Toggle.Parent = Item_Toggle
                Image_Toggle.AnchorPoint = Vector2.new(0.5, 0.5)
                Image_Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Image_Toggle.BackgroundTransparency = 1.000
                Image_Toggle.BorderSizePixel = 0
                Image_Toggle.Position = UDim2.new(0.5, 0, 0.5, 0)
                Image_Toggle.Size = UDim2.new(1, 0, 1, 0)
                Image_Toggle.ZIndex = 0
                Image_Toggle.Image = "rbxassetid://13120553044"
                Image_Toggle.ImageColor3 = Color3.fromRGB(212, 0, 255)
                Image_Toggle.ImageTransparency = 0.750
                Image_Toggle.ScaleType = Enum.ScaleType.Crop

                Frame_Toggle.Name = "Frame_Toggle"
                Frame_Toggle.Parent = Item_Toggle
                Frame_Toggle.AnchorPoint = Vector2.new(0.5, 0.5)
                Frame_Toggle.BackgroundColor3 = Color3.fromRGB(22, 0, 32)
                Frame_Toggle.BackgroundTransparency = 0
                Frame_Toggle.BorderSizePixel = 0
                Frame_Toggle.Position = UDim2.new(0.962000012, 0, 0.5, 0)
                Frame_Toggle.Size = UDim2.new(0.0316222869, 0, 0.640722096, 0)

                UICorner.CornerRadius = UDim.new(0.200000003, 0)
                UICorner.Parent = Frame_Toggle

                UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
                UIStroke.Color = Color3.fromRGB(59, 8, 109)
                UIStroke.LineJoinMode = Enum.LineJoinMode.Round
                UIStroke.Thickness = 1.5
                UIStroke.Parent = Frame_Toggle

                local toggled = _default
                
                local function toggle()
                    if toggled then
                        TweenService:Create(Frame_Toggle, TweenInfo.new(.1), {
                            BackgroundColor3 = Color3.fromRGB(137, 19, 255)
                        }):Play()
                        TweenService:Create(UIStroke, TweenInfo.new(.1), {
                            Color = Color3.fromRGB(165, 39, 255)
                        }):Play()
                    else
                        TweenService:Create(Frame_Toggle, TweenInfo.new(.1), {
                            BackgroundColor3 = Color3.fromRGB(28, 0, 39)
                        }):Play()
                        TweenService:Create(UIStroke, TweenInfo.new(.1), {
                            Color = Color3.fromRGB(59, 8, 109)
                        }):Play()
                    end

                    pcall(_callback, toggled)
                end

                toggle()
                Item_Toggle.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    toggle()
                end)

                updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)

                local toReturn = {}

                function toReturn:SetName(val)
                    assert(typeof(val) == "string", string.format("%s %s", assertions[1] .. "; user tried to set text to:", val))
                    Item_Toggle.Text = val
                end

                function toReturn:SetValue(val)
                    assert(typeof(val) == "boolean", string.format("%s %s", assertions[1] .. "; user tried to set value to:", val))
                    toggled = val
                end

                return toReturn
            end

            function sectionFuncs:TextBox(textBoxOptions, callback)
                local boxText = textBoxOptions.name or textBoxOptions.Name or textBoxOptions[1] or textBoxOptions or "New Text Box"
                assert(typeof(boxText) == "string", string.format("%s %s", assertions[1] .. "; user tried to set name to:", boxText))

                local _callback = textBoxOptions.callback or textBoxOptions.Callback or textBoxOptions[2] or callback
                assert(typeof(_callback) == "function", assertions[1] .. "; user tried to set callback to an unknown value.")

                local Item_Box = Instance.new("TextLabel")
                local Corner_Box = Instance.new("UICorner")
                local Constraint_Box = Instance.new("UITextSizeConstraint")
                local Image_Box = Instance.new("ImageLabel")
                local Label_Box = Instance.new("TextBox")

                Item_Box.Name = newIndex()
                Item_Box.Parent = data.ScrollTabView
                Item_Box.AnchorPoint = Vector2.new(0.5, 0.5)
                Item_Box.BackgroundColor3 = Color3.fromRGB(28, 0, 39)
                Item_Box.Position = UDim2.new(-0.00886476971, 0, 0.254924744, 0)
                Item_Box.Size = UDim2.new(0, 470, 0, 24)
                Item_Box.Font = Enum.Font.SourceSans
                Item_Box.Text = boxText
                Item_Box.TextColor3 = Color3.fromRGB(203, 203, 203)
                Item_Box.TextScaled = true
                Item_Box.TextSize = 14.000
                Item_Box.TextWrapped = true
                
                Corner_Box.CornerRadius = UDim.new(0.200000003, 0)
                Corner_Box.Name = "Corner_Box"
                Corner_Box.Parent = Item_Box
                
                Constraint_Box.Name = "Constraint_Box"
                Constraint_Box.Parent = Item_Box
                Constraint_Box.MaxTextSize = 14
                
                Image_Box.Name = "Image_Box"
                Image_Box.Parent = Item_Box
                Image_Box.AnchorPoint = Vector2.new(0.5, 0.5)
                Image_Box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Image_Box.BackgroundTransparency = 1.000
                Image_Box.BorderSizePixel = 0
                Image_Box.Position = UDim2.new(0.5, 0, 0.5, 0)
                Image_Box.Size = UDim2.new(1, 0, 1, 0)
                Image_Box.ZIndex = 0
                Image_Box.Image = "rbxassetid://13120553044"
                Image_Box.ImageColor3 = Color3.fromRGB(212, 0, 255)
                Image_Box.ImageTransparency = 0.750
                Image_Box.ScaleType = Enum.ScaleType.Crop
                
                Label_Box.Name = "Label_Box"
                Label_Box.Parent = Item_Box
                Label_Box.AnchorPoint = Vector2.new(0.5, 0.5)
                Label_Box.BackgroundColor3 = Color3.fromRGB(56, 3, 67)
                Label_Box.BorderColor3 = Color3.fromRGB(147, 15, 255)
                Label_Box.Position = UDim2.new(0.891319096, 0, 0.500000536, 0)
                Label_Box.Size = UDim2.new(0.191, 0, 0.649999976, 0)
                Label_Box.Font = Enum.Font.Oswald
                Label_Box.PlaceholderColor3 = Color3.fromRGB(133, 0, 166)
                Label_Box.PlaceholderText = "[Input Here]"
                Label_Box.Text = ""
                Label_Box.TextColor3 = Color3.fromRGB(157, 0, 255)
                Label_Box.TextScaled = true
                Label_Box.TextSize = 14.000
                Label_Box.TextWrapped = true

                Label_Box.FocusLost:Connect(function(enterPressed)
                    if not enterPressed then
                        return
                    end

                    pcall(_callback, Label_Box.Text)
                end)

                updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)

                local toReturn = {}

                function toReturn:SetName(val)
                    assert(typeof(val) == "string", string.format("%s %s", assertions[1] .. "; user tried to set text to:", val))
                    Item_Box.Text = val
                end

                return toReturn
            end

            function sectionFuncs:Bind(bindOptions, callback, default)
                local boxText = bindOptions.name or bindOptions.Name or bindOptions[1] or bindOptions or "New Bind"
                assert(typeof(boxText) == "string", string.format("%s %s", assertions[1] .. "; user tried to set name to:", boxText))

                local _callback = bindOptions.callback or bindOptions.Callback or bindOptions[2] or callback
                assert(typeof(_callback) == "function", assertions[1] .. "; user tried to set callback to an unknown value.")

                local _default = bindOptions.default or bindOptions.Default or bindOptions[3] or default or "None"
                assert(typeof(_default) == "EnumItem" or _default == "None", assertions[1] .. "; user tried to set keybind to an unknown value.")

                local Item_Bind = Instance.new("TextLabel")
                local Corner_Box = Instance.new("UICorner")
                local Constraint_Box = Instance.new("UITextSizeConstraint")
                local Image_Box = Instance.new("ImageLabel")
                local Button_Box = Instance.new("TextButton")

                Item_Bind.Name = newIndex()
                Item_Bind.Parent = data.ScrollTabView
                Item_Bind.AnchorPoint = Vector2.new(0.5, 0.5)
                Item_Bind.BackgroundColor3 = Color3.fromRGB(28, 0, 39)
                Item_Bind.Position = UDim2.new(-0.00886476971, 0, 0.254924744, 0)
                Item_Bind.Size = UDim2.new(0, 470, 0, 24)
                Item_Bind.Font = Enum.Font.SourceSans
                Item_Bind.Text = boxText
                Item_Bind.TextColor3 = Color3.fromRGB(203, 203, 203)
                Item_Bind.TextScaled = true
                Item_Bind.TextSize = 14.000
                Item_Bind.TextWrapped = true
                
                Corner_Box.CornerRadius = UDim.new(0.200000003, 0)
                Corner_Box.Name = "Corner_Box"
                Corner_Box.Parent = Item_Bind
                
                Constraint_Box.Name = "Constraint_Box"
                Constraint_Box.Parent = Item_Bind
                Constraint_Box.MaxTextSize = 14
                
                Image_Box.Name = "Image_Box"
                Image_Box.Parent = Item_Bind
                Image_Box.AnchorPoint = Vector2.new(0.5, 0.5)
                Image_Box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Image_Box.BackgroundTransparency = 1.000
                Image_Box.BorderSizePixel = 0
                Image_Box.Position = UDim2.new(0.5, 0, 0.5, 0)
                Image_Box.Size = UDim2.new(1, 0, 1, 0)
                Image_Box.ZIndex = 0
                Image_Box.Image = "rbxassetid://13120553044"
                Image_Box.ImageColor3 = Color3.fromRGB(212, 0, 255)
                Image_Box.ImageTransparency = 0.750
                Image_Box.ScaleType = Enum.ScaleType.Crop
                
                Button_Box.Name = "Button_Box"
                Button_Box.Parent = Item_Bind
                Button_Box.AnchorPoint = Vector2.new(0.5, 0.5)
                Button_Box.AutoButtonColor = false
                Button_Box.BackgroundColor3 = Color3.fromRGB(56, 3, 67)
                Button_Box.BorderColor3 = Color3.fromRGB(147, 15, 255)
                Button_Box.Position = UDim2.new(0.891319096, 0, 0.500000536, 0)
                Button_Box.Size = UDim2.new(0.191, 0, 0.649999976, 0)
                Button_Box.Font = Enum.Font.Oswald
                Button_Box.TextColor3 = Color3.fromRGB(157, 0, 255)
                Button_Box.TextScaled = true
                Button_Box.TextSize = 14.000
                Button_Box.TextWrapped = true

                local binding
                local kb = _default or nil

                Button_Box.Text = "[" .. (kb and typeof(kb) == "EnumItem" and kb.Name or "...") .. "]"

                Button_Box.MouseButton1Click:Connect(function()
                    Button_Box.Text = "[...]"
                    binding = true

                    local inputReceived = game:GetService("UserInputService").InputBegan:Wait()

                    if inputReceived.KeyCode.Name ~= "Unknown" then
                        Button_Box.Text = "[" .. inputReceived.KeyCode.Name .. "]"
                        kb = inputReceived.KeyCode.Name
                    end
                    binding = false
                end)
                
                getgenv().Rhythm_Library.Connections[newConnection()] = UIS.InputBegan:Connect(function(input, GPE)
                    if GPE then
                        return
                    end

                    if input.KeyCode.Name == kb and not binding then
                        pcall(_callback)
                    end
                end)

                updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)

                local toReturn = {}

                function toReturn:SetName(val)
                    assert(typeof(val) == "string", string.format("%s %s", assertions[1] .. "; user tried to set text to:", val))
                    Item_Box.Text = val
                end

                function toReturn:SetValue(val)
                    assert(typeof(val) == "EnumItem" and Enum.KeyCode[val.Name], string.format("%s %s", assertions[1] .. "; user tried to set value to:", val))
                    kb = val
                end

                return toReturn
            end

            function sectionFuncs:Slider(sliderOptions, min, max, start, callback)
                local labelText = sliderOptions.name or sliderOptions.Name or sliderOptions[1] or sliderOptions or "New Slider"
                assert(typeof(labelText) == "string", string.format("%s %s", assertions[1] .. "; user tried to set name to:", labelText))

                local _min = sliderOptions.min or sliderOptions.Min or sliderOptions[2] or min or 0
                assert(typeof(_min) == "number", assertions[1] .. "; user tried to set callback to an unknown value.")

                local _max = sliderOptions.max or sliderOptions.Max or sliderOptions[3] or max
                assert(typeof(_max) == "number", assertions[1] .. "; user tried to set callback to an unknown value.")

                local _start = sliderOptions.start or sliderOptions.Start or sliderOptions[4] or start or _min
                assert(typeof(_min) == "number", assertions[1] .. "; user tried to set callback to an unknown value.")

                local _callback = sliderOptions.callback or sliderOptions.Callback or sliderOptions[5] or callback
                assert(typeof(_callback) == "function", assertions[1] .. "; user tried to set callback to an unknown value.")

                _min = tonumber(_min)
                _max = tonumber(_max)
                _start = tonumber(_start)

                local Item_Slider = Instance.new("TextLabel")
                local Corner_Slider = Instance.new("UICorner")
                local Constraint_Slider = Instance.new("UITextSizeConstraint")
                local Image_Slider = Instance.new("ImageLabel")
                local Label_Slider = Instance.new("TextLabel")
                local Constraint_Label = Instance.new("UITextSizeConstraint")
                local Number_Slider = Instance.new("TextButton")
                local Constraint_Label_2 = Instance.new("UITextSizeConstraint")
                local SlideFrame = Instance.new("Frame")
                local Corner_SliderValue = Instance.new("UICorner")
                local SliderContainer = Instance.new("Frame")
                local Corner_SliderValue_2 = Instance.new("UICorner")
                local CurrentValueFrame = Instance.new("Frame")
                local Corner_SliderValue_3 = Instance.new("UICorner")
                local SliderCircle = Instance.new("ImageLabel")

                Item_Slider.Name = "Item_Slider"
                Item_Slider.Parent = data.ScrollTabView
                Item_Slider.AnchorPoint = Vector2.new(0.5, 0.5)
                Item_Slider.BackgroundColor3 = Color3.fromRGB(28, 0, 39)
                Item_Slider.Position = UDim2.new(-0.00886476971, 0, 0.254924744, 0)
                Item_Slider.Size = UDim2.new(0, 470, 0, 36)
                Item_Slider.Font = Enum.Font.SourceSans
                Item_Slider.Text = ""
                Item_Slider.TextColor3 = Color3.fromRGB(203, 203, 203)
                Item_Slider.TextScaled = true
                Item_Slider.TextSize = 14.000
                Item_Slider.TextWrapped = true
                
                Corner_Slider.CornerRadius = UDim.new(0.200000003, 0)
                Corner_Slider.Name = "Corner_Slider"
                Corner_Slider.Parent = Item_Slider
                
                Constraint_Slider.Name = "Constraint_Slider"
                Constraint_Slider.Parent = Item_Slider
                Constraint_Slider.MaxTextSize = 14
                
                Image_Slider.Name = "Image_Slider"
                Image_Slider.Parent = Item_Slider
                Image_Slider.AnchorPoint = Vector2.new(0.5, 0.5)
                Image_Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Image_Slider.BackgroundTransparency = 1.000
                Image_Slider.BorderSizePixel = 0
                Image_Slider.Position = UDim2.new(0.5, 0, 0.5, 0)
                Image_Slider.Size = UDim2.new(1, 0, 1, 0)
                Image_Slider.ZIndex = 0
                Image_Slider.Image = "rbxassetid://13120553044"
                Image_Slider.ImageColor3 = Color3.fromRGB(212, 0, 255)
                Image_Slider.ImageTransparency = 0.750
                Image_Slider.ScaleType = Enum.ScaleType.Crop
                
                Label_Slider.Name = "Label_Slider"
                Label_Slider.Parent = Item_Slider
                Label_Slider.AnchorPoint = Vector2.new(0.5, 0.5)
                Label_Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Label_Slider.BackgroundTransparency = 1.000
                Label_Slider.Position = UDim2.new(0.270000011, 0, 0.319999993, 0)
                Label_Slider.Size = UDim2.new(0.506383002, 0, 0.416666657, 0)
                Label_Slider.Font = Enum.Font.SourceSans
                Label_Slider.Text = labelText
                Label_Slider.TextColor3 = Color3.fromRGB(179, 179, 179)
                Label_Slider.TextScaled = true
                Label_Slider.TextSize = 14.000
                Label_Slider.TextWrapped = true
                Label_Slider.TextXAlignment = Enum.TextXAlignment.Left
                
                Constraint_Label.Name = "Constraint_Label"
                Constraint_Label.Parent = Label_Slider
                Constraint_Label.MaxTextSize = 14
                
                Number_Slider.Name = "Number_Slider"
                Number_Slider.Parent = Item_Slider
                Number_Slider.AnchorPoint = Vector2.new(0.5, 0.5)
                Number_Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Number_Slider.BackgroundTransparency = 1.000
                Number_Slider.Position = UDim2.new(0.759000003, 0, 0.277999997, 0)
                Number_Slider.Size = UDim2.new(0.455000013, 0, 0.416999996, 0)
                Number_Slider.AutoButtonColor = false
                Number_Slider.Font = Enum.Font.SourceSans
                Number_Slider.Text = _start
                Number_Slider.TextColor3 = Color3.fromRGB(255, 255, 255)
                Number_Slider.TextScaled = true
                Number_Slider.TextSize = 14.000
                Number_Slider.TextWrapped = true
                Number_Slider.TextXAlignment = Enum.TextXAlignment.Right
                
                Constraint_Label_2.Name = "Constraint_Label"
                Constraint_Label_2.Parent = Number_Slider
                Constraint_Label_2.MaxTextSize = 14
                
                Corner_SliderValue.CornerRadius = UDim.new(0.5, 0)
                Corner_SliderValue.Name = "Corner_SliderValue"
                Corner_SliderValue.Parent = SlideFrame
                
                SliderContainer.Name = "SliderContainer"
                SliderContainer.Parent = Item_Slider
                SliderContainer.AnchorPoint = Vector2.new(0.5, 0.5)
                SliderContainer.BackgroundColor3 = Color3.fromRGB(11, 0, 17)
                SliderContainer.BackgroundTransparency = 1.000
                SliderContainer.BorderSizePixel = 0
                SliderContainer.Position = UDim2.new(0.5, 0, 0.75, 0)
                SliderContainer.Size = UDim2.new(0.939999998, 0, -0.0799999982, 0)
                
                Corner_SliderValue_2.CornerRadius = UDim.new(0.5, 0)
                Corner_SliderValue_2.Name = "Corner_SliderValue"
                Corner_SliderValue_2.Parent = SliderContainer

                SlideFrame.Name = "SlideFrame"
                SlideFrame.Parent = SliderContainer
                SlideFrame.BackgroundColor3 = Color3.fromRGB(50, 0, 79)
                SlideFrame.BorderSizePixel = 0
                SlideFrame.Position = UDim2.new(0, 0, 0.5, 0)
                SlideFrame.Size = UDim2.new(1, 0, 1, 0)
                
                CurrentValueFrame.Name = "CurrentValueFrame"
                CurrentValueFrame.Parent = SliderContainer
                CurrentValueFrame.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
                CurrentValueFrame.BorderSizePixel = 0
                CurrentValueFrame.Size = UDim2.new(_start / _max, 0, 1, 0)
                CurrentValueFrame.ZIndex = 2
                
                Corner_SliderValue_3.CornerRadius = UDim.new(0.5, 0)
                Corner_SliderValue_3.Name = "Corner_SliderValue"
                Corner_SliderValue_3.Parent = CurrentValueFrame
                
                SliderCircle.Name = "SliderCircle"
                SliderCircle.Parent = CurrentValueFrame
                SliderCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderCircle.BackgroundTransparency = 1.000
                SliderCircle.BorderSizePixel = 0
                SliderCircle.Position = UDim2.new(.98, 0, -1.70000005, 0)
                SliderCircle.Size = UDim2.new(0, 12, 0, 12)
                SliderCircle.Image = "rbxassetid://3570695787"
                SliderCircle.ImageColor3 = Color3.fromRGB(100, 0, 150)

                local dragging = false

                local function move(input)
                    local pos, pos1 = UDim2.new(
                        math.clamp((input.Position.X - SlideFrame.AbsolutePosition.X) / SlideFrame.AbsoluteSize.X, 0, 1),
                        0,
                        -1.7,
                        0
                    ), UDim2.new(
                        math.clamp((input.Position.X - SlideFrame.AbsolutePosition.X) / SlideFrame.AbsoluteSize.X, 0, 1),
                        0,
                        1,
                        0
                    )
                    CurrentValueFrame:TweenSize(pos1, "Out", "Sine", 0.1, true)
                    
                    local value = math.floor(((pos.X.Scale * _max) / _max) * (_max - _min) + _min)
                    Number_Slider.Text = tostring(value)
                    pcall(_callback, value)
                end

                getgenv().Rhythm_Library.Connections[newConnection()] = SliderCircle.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        _busy = true
                    end
                end)

                getgenv().Rhythm_Library.Connections[newConnection()] = SliderCircle.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        _busy = false
                    end
                end)

                getgenv().Rhythm_Library.Connections[newConnection()] = UIS.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        move(input)
                    end
                end)

                updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)

                local toReturn = {}

                function toReturn:SetName(val)
                    assert(typeof(val) == "string", string.format("%s %s", assertions[1] .. "; user tried to set text to:", val))
                    Label_Slider.Text = val
                end

                return toReturn
            end

            return sectionFuncs
        end

        return tabFuncs
    end
    
    return windowFuncs
end

function Rhythm_Library:DestroyWindow()
    self.Drag:TweenSizeAndPosition(
        UDim2.new(0, 0, 0, 0),
        UDim2.new(self.Drag.Position.X, 0, -10, 0),
        nil,
        nil,
        .15
    )
    task.wait(.25)
    self.UI:Destroy()

    if getgenv().Rhythm_Library and getgenv().Rhythm_Library.Connections then
        for _, connection in pairs(getgenv().Rhythm_Library.Connections) do
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            else
                task.cancel(connection)
            end
            connection = nil
        end
    end
end

function Rhythm_Library:Toggle()
    if _toggling then return end
    _toggling = true

    if getgenv().Rhythm_Library.Toggled then
        self.Drag:TweenSizeAndPosition(
            UDim2.new(0, 0, 0, 0),
            UDim2.new(self.Drag.Position.X, 0, -10, 0),
            nil,
            nil,
            .15
        )
        task.wait(.15)
        self.Drag.Visible = false
    else
        self.Drag.Visible = true
        self.Drag:TweenSizeAndPosition(
            UDim2.new(0, 560, 0, 326),
            getgenv().Rhythm_Library.OriginalPos,
            nil,
            nil,
            .15
        )
    end

    getgenv().Rhythm_Library.Toggled = not getgenv().Rhythm_Library.Toggled
    _toggling = false
end

function Rhythm_Library:ChangeTitle(title)
    assert(typeof(title) == "string", string.format("%s %s", assertions[1] .. "; user tried to set name to:", title))
    self.Title.Text = title
end

function Rhythm_Library:ChangeKeybind(kb)
    if typeof(kb) == "EnumItem" and Enum.KeyCode[kb.Name] then
        getgenv().Rhythm_Library.Keybind = kb
    elseif type(kb) == "string" and Enum.KeyCode[kb] then
        getgenv().Rhythm_Library.Keybind = Enum.KeyCode[kb]
    end
end

function Rhythm_Library:Notification(title, message)
    local tbl = {}
    tbl.Title = title.Title or title
    tbl.Message = title.Message or message

    table.insert(notificationQueue, tbl)
end

local notificationUI = Instance.new("ScreenGui")
notificationUI.Name = generateId(16)
notificationUI.ResetOnSpawn = false
notificationUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notificationUI:SetAttribute("Rhythm_Notification", true)
ProtectInstance(notificationUI)
notificationUI.Parent = CoreGui

if getgenv().Rhythm_Library and getgenv().Rhythm_Library.Connections then
    for _, connection in pairs(getgenv().Rhythm_Library.Connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        else
            task.cancel(connection)
        end
        connection = nil
    end
end

getgenv().Rhythm_Library = {
    Toggled = true,
    Keybind = Enum.KeyCode.LeftControl,
    OriginalPos = UDim2.new(0.5, 0, 0.5, 0),

    Connections = {
        _TOGGLE = UIS.InputEnded:Connect(function(input, gameProcessedEvent)
            if gameProcessedEvent then return end
        
            if input.KeyCode == getgenv().Rhythm_Library.Keybind then
                Rhythm_Library:Toggle()
            end
        end),

        _NOTIFICATION = task.spawn(function()
            while notificationUI and task.wait() do
                local nextMessage = notificationQueue[1]

                if nextMessage then
                    nextMessage = table.clone(nextMessage)
                    table.remove(notificationQueue, 1)

                    local Container_Notify = Instance.new("Frame")
                    local Image_Main = Instance.new("ImageLabel")
                    local Container_TopBar = Instance.new("Frame")
                    local Title = Instance.new("TextLabel")
                    local Close = Instance.new("TextButton")
                    local Container_Info = Instance.new("Frame")
                    local Message = Instance.new("TextLabel")
                    local Constraint_Label = Instance.new("UITextSizeConstraint")
                    local StrokeMain = Instance.new("UIStroke")
                    local StrokeTopBar = Instance.new("UIStroke")
    
                    Container_Notify.Name = "Container_Notify"
                    Container_Notify.Parent = notificationUI
                    Container_Notify.AnchorPoint = Vector2.new(0.5, 0.5)
                    Container_Notify.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
                    Container_Notify.BorderSizePixel = 0
                    Container_Notify.Position = UDim2.new(2, 0, 0.899999976, 0)
                    Container_Notify.Size = UDim2.new(0, 246, 0, 94)
                    
                    Image_Main.Name = "Image_Main"
                    Image_Main.Parent = Container_Notify
                    Image_Main.AnchorPoint = Vector2.new(0.5, 0.5)
                    Image_Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Image_Main.BackgroundTransparency = 1.000
                    Image_Main.BorderSizePixel = 0
                    Image_Main.Position = UDim2.new(0.5, 0, 0.5, 0)
                    Image_Main.Size = UDim2.new(1, 0, 1.00000024, 0)
                    Image_Main.ZIndex = 0
                    Image_Main.Image = "rbxassetid://13024447759"
                    Image_Main.ScaleType = Enum.ScaleType.Crop
                    
                    Container_TopBar.Name = "Container_TopBar"
                    Container_TopBar.Parent = Container_Notify
                    Container_TopBar.AnchorPoint = Vector2.new(0.5, 0.5)
                    Container_TopBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    Container_TopBar.BackgroundTransparency = 0.350
                    Container_TopBar.BorderSizePixel = 0
                    Container_TopBar.Position = UDim2.new(0.500000119, 0, 0.110695623, 0)
                    Container_TopBar.Size = UDim2.new(1.00000024, 0, 0.221389949, 0)
                    
                    Title.Name = "Title"
                    Title.Parent = Container_TopBar
                    Title.AnchorPoint = Vector2.new(0.5, 0.5)
                    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Title.BackgroundTransparency = 1.000
                    Title.BorderSizePixel = 0
                    Title.Position = UDim2.new(0.460000008, 0, 0.5, 0)
                    Title.Size = UDim2.new(0.875, 0, 0.5, 0)
                    Title.Font = Enum.Font.Unknown
                    Title.Text = nextMessage.Title
                    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Title.TextScaled = true
                    Title.TextSize = 14.000
                    Title.TextWrapped = true
                    Title.TextXAlignment = Enum.TextXAlignment.Left
                    
                    Close.Name = "Close"
                    Close.Parent = Container_TopBar
                    Close.AnchorPoint = Vector2.new(0.5, 0.5)
                    Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Close.BackgroundTransparency = 1.000
                    Close.BorderSizePixel = 0
                    Close.Position = UDim2.new(0.970000029, 0, 0.535000026, 0)
                    Close.Size = UDim2.new(0.0449999385, 0, 0.695276499, 0)
                    Close.AutoButtonColor = false
                    Close.Font = Enum.Font.Roboto
                    Close.Text = "X"
                    Close.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Close.TextScaled = true
                    Close.TextSize = 14.000
                    Close.TextWrapped = true
                    
                    Container_Info.Name = "Container_Info"
                    Container_Info.Parent = Container_Notify
                    Container_Info.AnchorPoint = Vector2.new(0.5, 0.5)
                    Container_Info.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    Container_Info.BackgroundTransparency = 1.000
                    Container_Info.BorderSizePixel = 0
                    Container_Info.ClipsDescendants = true
                    Container_Info.Position = UDim2.new(0.5, 0, 0.602833867, 0)
                    Container_Info.Size = UDim2.new(1, 0, 0.788318515, 0)
                    
                    Message.Name = "Message"
                    Message.Parent = Container_Info
                    Message.AnchorPoint = Vector2.new(0.5, 0.5)
                    Message.BackgroundColor3 = Color3.fromRGB(28, 0, 39)
                    Message.BackgroundTransparency = 1.000
                    Message.Position = UDim2.new(0.5, 0, 0.5, 0)
                    Message.Size = UDim2.new(0.964999974, 0, 0.949999988, 0)
                    Message.Font = Enum.Font.SourceSans
                    Message.Text = nextMessage.Message
                    Message.TextColor3 = Color3.fromRGB(203, 203, 203)
                    Message.TextScaled = true
                    Message.TextSize = 14.000
                    Message.TextWrapped = true

                    StrokeMain.Name = "Stroke_Main"
                    StrokeMain.Parent = Container_Notify
                    StrokeMain.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
                    StrokeMain.Color = Color3.fromRGB(147, 0, 180)

                    StrokeTopBar.Name = "Stroke_TopBar"
                    StrokeTopBar.Parent = Container_TopBar
                    StrokeTopBar.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
                    StrokeTopBar.Color = Color3.fromRGB(147, 0, 180)
                    
                    Constraint_Label.Name = "Constraint_Label"
                    Constraint_Label.Parent = Message
                    Constraint_Label.MaxTextSize = 18
                    
                    Container_Notify:TweenPosition(
                        UDim2.fromScale(0.92, 0.9),
                        Enum.EasingDirection.Out,
                        Enum.EasingStyle.Sine,
                        .35,
                        false
                    )
    
                    local stopped = false
    
                    Close.MouseButton1Click:Connect(function()
                        stopped = true
                    end)
    
                    task.delay(7, function()
                        stopped = true
                    end)
    
                    repeat task.wait() until stopped
    
                    Container_Notify:TweenPosition(
                        UDim2.fromScale(2, 0.9),
                        Enum.EasingDirection.Out,
                        Enum.EasingStyle.Sine,
                        .35,
                        true,
                        function()
                            Container_Notify:Destroy()
                        end
                    )
                end
            end
        end)
    }
}

--[[ Examples

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

Player.CharacterAdded:Connect(function(char)
    Character = char
end)

local window = Rhythm_Library:Window("RHYTHMLIB | TESTING")
Rhythm_Library:Notification("RHYTHMLIB | TESTING", "Successfully initialized!")

local tab1 = window:Tab("Auto Farm")
local s1_t1 = tab1:Section("Auto Equip")

s1_t1:Button("Jump!", function()
    Character:WaitForChild("Humanoid", 30):ChangeState(Enum.HumanoidStateType.Jumping)
    print("Jumped!")
end)

s1_t1:Dropdown({
    Name = "Some Dropdown",
    Items = {
        "eh",
        "idk",
        "another",
        "why not another",
        "even more",
        "nothing's stopping me",
        "i can keep going",
        "infinite",
        "endless possibilities",
        "suffering",
        "ok this is enough"
    },
    Callback = function(item)
        print("Selected:", item)
    end
})

s1_t1:MultiDropdown({
    Name = "a multi dropdown",
    Items = {
        "eh",
        "idk",
        "another",
        "why not another",
        "even more",
        "nothing's stopping me",
        "i can keep going",
        "infinite",
        "endless possibilities",
        "suffering",
        "ok this is enough"
    },
    Callback = function(selected)
        print("Selected:", table.unpack(selected))
    end
})

s1_t1:Toggle("Some toggle", function(val)
    print("Toggled to:", val)
end)

s1_t1:Bind("a bind idk why", function()
    print("This was pressed lol")
end)

s1_t1:Slider("Set WalkSpeed", 0, 255, Character.Humanoid.WalkSpeed, function(val)
    Character:WaitForChild("Humanoid", 30).WalkSpeed = val
end)

local tab2 = window:Tab("Auto Time Trial")
local tab3 = window:Tab("Auto Buy")
local tab4 = window:Tab("Webhook")
local tab5 = window:Tab("Misc")
local tab6 = window:Tab("Premium")
]]

return Rhythm_Library