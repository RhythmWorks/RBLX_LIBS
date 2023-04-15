local Rhythm_Library = {}

for _, obj in pairs(game:GetService("CoreGui"):GetChildren()) do
    if obj:GetAttribute("Rhythm_Lib") then
        obj:Destroy()
    end
end

loadstring(game:HttpGet("https://api.irisapp.ca/Scripts/IrisInstanceProtect.lua"))()

getgenv().Rhythm_Library = {
    Toggled = true,
    Keybind = Enum.KeyCode.RightControl
}

local Collection = game:GetService("CollectionService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local _toggling = false
local assertions = {
    "Invalid type for property \"name\"",
    "Missing argument",
    "Tried to duplicate tab name"
}

local function dragify(Frame)
    local dragToggle, dragStart, dragInput, startPos, Delta, Position
    
    local function updateInput(input)
        Delta = input.Position - dragStart
        Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
        game:GetService("TweenService"):Create(Frame, TweenInfo.new(.25), {Position = Position}):Play()
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
            return
        end
		scrollingFrame.CanvasSize = UDim2.fromOffset(layout.AbsoluteContentSize.X + padding, layout.AbsoluteContentSize.Y + padding)
	elseif scrollingDirection == Enum.ScrollingDirection.X then
        if shouldTween then
            game:GetService("TweenService"):Create(scrollingFrame, TweenInfo.new(0.25), {
                CanvasSize = UDim2.fromOffset(layout.AbsoluteContentSize.X + padding, layout.AbsoluteContentSize.Y)
            }):Play()
            return
        end
        scrollingFrame.CanvasSize = UDim2.fromOffset(layout.AbsoluteContentSize.X + padding, layout.AbsoluteContentSize.Y)
	elseif scrollingDirection == Enum.ScrollingDirection.Y then
        if shouldTween then
            game:GetService("TweenService"):Create(scrollingFrame, TweenInfo.new(0.25), {
                CanvasSize = UDim2.fromOffset(layout.AbsoluteContentSize.X, layout.AbsoluteContentSize.Y + padding)
            }):Play()
            return
        end
        scrollingFrame.CanvasSize = UDim2.fromOffset(layout.AbsoluteContentSize.X, layout.AbsoluteContentSize.Y + padding)
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
    ListLayout_Tabs.Padding = UDim.new(0.01, 0)
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
        Scrolling_TabView.Position = UDim2.new(0.5, 0, 0.5, 0)
        Scrolling_TabView.Size = UDim2.new(0.975000024, 0, 0.925000012, 0)
        Scrolling_TabView.ScrollBarImageColor3 = Color3.fromRGB(160, 0, 166)
        Scrolling_TabView.ScrollBarThickness = 2
        Scrolling_TabView.Parent = Container_TabViewScrolling

        ListLayout_TabView.Name = "ListLayout_TabView"
        ListLayout_TabView.FillDirection = Enum.FillDirection.Vertical
        ListLayout_TabView.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout_TabView.Padding = UDim.new(0.15, 0)
        ListLayout_TabView.Parent = Scrolling_TabView

        self[tabName] = {}
        self[tabName].Button = Button_TabButton
        self[tabName].Container = Container_TabButton
        self[tabName].ContainerTabView = Container_TabViewScrolling
        self[tabName].ScrollTabView = Scrolling_TabView
        self[tabName].tabName = tabName

        return self:_TabCode(self[tabName])
    end

    function windowFuncs:_TabCode(data)
        updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.Y)

        data.ScrollTabView.DescendantAdded:Connect(function()
            updateCanvas(data.ScrollTabView, data.ScrollTabView.ListLayout_TabView, Enum.ScrollingDirection.X)
        end)

        local tabs = lib.TabView:GetChildren()

        if not tabs[2] then
            data.ContainerTabView.Visible = true
            data.Container:SetAttribute("Toggled", true)

            data.Container:TweenSize(
                UDim2.new(0, 125, 0, 19),
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
                UDim2.new(0, 125, 0, 19),
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
                UDim2.new(0, 83, 0, 19),
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
                        UDim2.new(0, 125, 0, 19),
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
                    tbView:SetAttribute("Toggled", false)
                    tbView:TweenSize(
                        UDim2.new(0, 83, 0, 19),
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

        local tabFuncs = {}

        function tabFuncs:Section(sectionOptions)

            local sectionFuncs = {}

            function sectionFuncs:Label(labelOptions)

            end

            function sectionFuncs:Button(buttonOptions)

            end

            function sectionFuncs:TextBox(textBoxOptions)

            end

            function sectionFuncs:Slider(sliderOptions)

            end

            function sectionFuncs:Dropdown(dropdownOptions)

            end

            function sectionFuncs:Toggle(toggleOptions)

            end

            function sectionFuncs:Keybind(keybindOptions)

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
            UDim2.new(0.5, 0, 0.5, 0),
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

UIS.InputEnded:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.KeyCode == getgenv().Rhythm_Library.Keybind then
        Rhythm_Library:Toggle()
    end
end)

-- Testing

local window = Rhythm_Library:Window("RHYTHMLIB | TESTING")

local tab1 = window:Tab("Auto Farm")
local tab2 = window:Tab("Auto Time Trial")
local tab3 = window:Tab("Auto Buy")
local tab4 = window:Tab("Webhook")
local tab5 = window:Tab("Misc")
local tab6 = window:Tab("Premium")

--return Rhythm_Library