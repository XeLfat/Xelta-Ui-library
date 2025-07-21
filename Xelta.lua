-- Enhanced UI Library with Modular Structure and Chain Functions
-- Inspired by Rayfield UI Library

local Library = {}
Library.__index = Library

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Constants
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local COLORS = {
    Background = Color3.fromRGB(21, 21, 21),
    Secondary = Color3.fromRGB(32, 32, 32),
    Accent = Color3.fromRGB(60, 60, 60),
    Text = Color3.fromRGB(255, 255, 255),
    TabActive = Color3.fromRGB(48, 48, 48),
    TabInactive = Color3.fromRGB(35, 35, 35),
    ButtonHover = Color3.fromRGB(55, 55, 55)
}

-- Lucide Icons Module
local Icons = {}
do
    local success, response = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua")
    end)
    
    if success then
        local loadIconModule = loadstring(response)
        if loadIconModule then
            Icons = loadIconModule()
        end
    else
        -- Fallback icons if HTTP request fails
        Icons = {
            ["house"] = "rbxassetid://10723407389",
            ["settings"] = "rbxassetid://10734950309",
            ["zap"] = "rbxassetid://10723423786"
        }
    end
end

-- Utility Functions Module
local Utils = {}

function Utils.Create(class, properties)
    local instance = Instance.new(class)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

function Utils.Tween(instance, properties, tweenInfo)
    tweenInfo = tweenInfo or TWEEN_INFO
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utils.AddHoverEffect(button, hoverColor, normalColor)
    normalColor = normalColor or button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        Utils.Tween(button, {BackgroundColor3 = hoverColor})
    end)
    
    button.MouseLeave:Connect(function()
        Utils.Tween(button, {BackgroundColor3 = normalColor})
    end)
end

-- Window Class
local Window = {}
Window.__index = Window

function Window:new(library, config)
    local self = setmetatable({}, Window)
    
    self.Library = library
    self.Name = config.Name or "UI Library"
    self.Draggable = config.Draggable ~= false
    self.KeyBind = config.KeyBind
    self.Tabs = {}
    self.ActiveTab = nil
    self.Minimized = false
    self.Fullscreen = false
    
    -- Create GUI
    self:CreateGUI()
    
    -- Setup functionality
    self:SetupHeader()
    self:SetupToggle()
    
    return self
end

function Window:CreateGUI()
    -- Main ScreenGui
    self.GUI = Utils.Create("ScreenGui", {
        Name = "EnhancedUI",
        ResetOnSpawn = false,
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    })
    
    -- Main Window Frame
    self.MainFrame = Utils.Create("Frame", {
        Name = "MainWindow",
        BackgroundColor3 = COLORS.Background,
        Size = UDim2.new(0, 600, 0, 350),
        Position = UDim2.new(0.5, -300, 0.5, -175),
        Parent = self.GUI,
        Active = self.Draggable,
        Draggable = self.Draggable
    })
    
    -- Window Corner
    Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.MainFrame
    })
    
    -- Header
    self.Header = Utils.Create("Frame", {
        Name = "Header",
        BackgroundColor3 = COLORS.Background,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = self.MainFrame
    })
    
    -- Title
    self.Title = Utils.Create("TextLabel", {
        Name = "Title",
        Text = self.Name,
        TextColor3 = COLORS.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSansBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        Parent = self.Header
    })
    
    -- Header Separator
    Utils.Create("Frame", {
        Name = "Separator",
        BackgroundColor3 = COLORS.Accent,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BorderSizePixel = 0,
        Parent = self.Header
    })
    
    -- Control Buttons Container
    local controlsContainer = Utils.Create("Frame", {
        Name = "Controls",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, -85, 0, 0),
        Parent = self.Header
    })
    
    -- Minimize Button
    self.MinimizeButton = Utils.Create("ImageButton", {
        Name = "Minimize",
        Image = "rbxassetid://10734896206",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -10),
        Parent = controlsContainer
    })
    
    -- Fullscreen Button
    self.FullscreenButton = Utils.Create("ImageButton", {
        Name = "Fullscreen",
        Image = "rbxassetid://10747384394",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 30, 0.5, -10),
        Parent = controlsContainer
    })
    
    -- Close Button
    self.CloseButton = Utils.Create("ImageButton", {
        Name = "Close",
        Image = "rbxassetid://10734965702",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 60, 0.5, -10),
        Parent = controlsContainer
    })
    
    -- Sidebar
    self.Sidebar = Utils.Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = COLORS.Background,
        Size = UDim2.new(0, 120, 1, -47),
        Position = UDim2.new(0, 0, 0, 47),
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })
    
    -- Tab Container (ScrollingFrame)
    self.TabContainer = Utils.Create("ScrollingFrame", {
        Name = "TabContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = COLORS.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = self.Sidebar
    })
    
    -- Tab Layout
    Utils.Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.TabContainer
    })
    
    -- Content Area
    self.ContentArea = Utils.Create("Frame", {
        Name = "Content",
        BackgroundColor3 = COLORS.Secondary,
        Size = UDim2.new(1, -125, 1, -47),
        Position = UDim2.new(0, 120, 0, 47),
        BorderSizePixel = 0,
        Parent = self.MainFrame
    })
    
    Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = self.ContentArea
    })
end

function Window:SetupHeader()
    -- Minimize functionality
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    -- Fullscreen functionality
    self.FullscreenButton.MouseButton1Click:Connect(function()
        self:ToggleFullscreen()
    end)
    
    -- Close functionality (hide, not destroy)
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    -- Add hover effects
    Utils.AddHoverEffect(self.MinimizeButton, Color3.fromRGB(80, 80, 80), Color3.new(1, 1, 1))
    Utils.AddHoverEffect(self.FullscreenButton, Color3.fromRGB(80, 80, 80), Color3.new(1, 1, 1))
    Utils.AddHoverEffect(self.CloseButton, Color3.fromRGB(255, 80, 80), Color3.new(1, 1, 1))
end

function Window:SetupToggle()
    if self.KeyBind then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == Enum.KeyCode[self.KeyBind:upper()] then
                self:Toggle()
            end
        end)
    end
end

function Window:ToggleMinimize()
    self.Minimized = not self.Minimized
    
    if self.Minimized then
        -- Minimize to header only
        self.OriginalSize = self.MainFrame.Size
        Utils.Tween(self.MainFrame, {
            Size = UDim2.new(0, 300, 0, 40)
        })
        self.Sidebar.Visible = false
        self.ContentArea.Visible = false
    else
        -- Restore
        Utils.Tween(self.MainFrame, {
            Size = self.OriginalSize or UDim2.new(0, 600, 0, 350)
        })
        task.wait(0.2)
        self.Sidebar.Visible = true
        self.ContentArea.Visible = true
    end
end

function Window:ToggleFullscreen()
    self.Fullscreen = not self.Fullscreen
    
    if self.Fullscreen then
        self.OriginalSize = self.MainFrame.Size
        self.OriginalPosition = self.MainFrame.Position
        
        local viewport = workspace.CurrentCamera.ViewportSize
        Utils.Tween(self.MainFrame, {
            Size = UDim2.new(0, viewport.X - 40, 0, viewport.Y - 40),
            Position = UDim2.new(0, 20, 0, 20)
        })
    else
        Utils.Tween(self.MainFrame, {
            Size = self.OriginalSize or UDim2.new(0, 600, 0, 350),
            Position = self.OriginalPosition or UDim2.new(0.5, -300, 0.5, -175)
        })
    end
end

function Window:Close()
    Utils.Tween(self.MainFrame, {
        Size = UDim2.new(0, self.MainFrame.Size.X.Offset, 0, 0)
    })
    task.wait(0.3)
    self.GUI.Enabled = false
end

function Window:Toggle()
    self.GUI.Enabled = not self.GUI.Enabled
    if self.GUI.Enabled then
        self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
        Utils.Tween(self.MainFrame, {
            Size = self.OriginalSize or UDim2.new(0, 600, 0, 350)
        })
    end
end

function Window:Tab(config)
    local tab = Tab:new(self, config)
    table.insert(self.Tabs, tab)
    
    -- Set first tab as active
    if #self.Tabs == 1 then
        tab:Activate()
    end
    
    return tab
end

-- Tab Class
local Tab = {}
Tab.__index = Tab

function Tab:new(window, config)
    local self = setmetatable({}, Tab)
    
    self.Window = window
    self.Name = config.Name or "Tab"
    self.Icon = config.Icon
    self.Elements = {}
    
    self:CreateGUI()
    
    return self
end

function Tab:CreateGUI()
    -- Tab Button
    self.Button = Utils.Create("TextButton", {
        Name = "TabButton",
        Text = "",
        BackgroundColor3 = COLORS.TabInactive,
        Size = UDim2.new(1, 0, 0, 35),
        BorderSizePixel = 0,
        Parent = self.Window.TabContainer
    })
    
    Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = self.Button
    })
    
    -- Tab Content Container
    local buttonContent = Utils.Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        Parent = self.Button
    })
    
    -- Icon (if provided)
    if self.Icon and Icons[self.Icon] then
        self.IconLabel = Utils.Create("ImageLabel", {
            Name = "Icon",
            Image = Icons[self.Icon],
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 0, 0.5, -10),
            Parent = buttonContent
        })
    end
    
    -- Tab Name
    self.NameLabel = Utils.Create("TextLabel", {
        Name = "TabName",
        Text = self.Name,
        TextColor3 = COLORS.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        TextXAlignment = self.Icon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
        BackgroundTransparency = 1,
        Size = self.Icon and UDim2.new(1, -30, 1, 0) or UDim2.new(1, 0, 1, 0),
        Position = self.Icon and UDim2.new(0, 30, 0, 0) or UDim2.new(0, 0, 0, 0),
        Parent = buttonContent
    })
    
    -- Tab Content Frame
    self.Content = Utils.Create("ScrollingFrame", {
        Name = "TabContent",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = COLORS.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.Window.ContentArea
    })
    
    Utils.Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Content
    })
    
    Utils.Create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        Parent = self.Content
    })
    
    -- Tab Click Handler
    self.Button.MouseButton1Click:Connect(function()
        self:Activate()
    end)
    
    -- Hover Effect
    Utils.AddHoverEffect(self.Button, COLORS.ButtonHover, COLORS.TabInactive)
end

function Tab:Activate()
    -- Deactivate all tabs
    for _, tab in pairs(self.Window.Tabs) do
        tab.Content.Visible = false
        Utils.Tween(tab.Button, {BackgroundColor3 = COLORS.TabInactive})
    end
    
    -- Activate this tab
    self.Content.Visible = true
    self.Window.ActiveTab = self
    
    -- Smooth transition with click effect
    Utils.Tween(self.Button, {BackgroundColor3 = COLORS.TabActive})
    
    -- Click animation
    local clickEffect = Utils.Create("Frame", {
        Name = "ClickEffect",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = self.Button
    })
    
    Utils.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = clickEffect
    })
    
    -- Animate click effect
    Utils.Tween(clickEffect, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1
    }, TweenInfo.new(0.4, Enum.EasingStyle.Quart))
    
    task.wait(0.4)
    clickEffect:Destroy()
end

-- Element Creation Methods
function Tab:Button(config)
    local button = {}
    
    -- Button Frame
    button.Frame = Utils.Create("Frame", {
        Name = "Button",
        BackgroundColor3 = COLORS.TabActive,
        Size = UDim2.new(1, 0, 0, 40),
        BorderSizePixel = 0,
        Parent = self.Content
    })
    
    Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = button.Frame
    })
    
    -- Button
    button.Button = Utils.Create("TextButton", {
        Name = "ClickArea",
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = button.Frame
    })
    
    -- Button Text
    button.Text = Utils.Create("TextLabel", {
        Name = "ButtonText",
        Text = config.Name or "Button",
        TextColor3 = COLORS.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = button.Frame
    })
    
    -- Callback
    if config.Callback then
        button.Button.MouseButton1Click:Connect(function()
            -- Click animation
            Utils.Tween(button.Frame, {BackgroundColor3 = COLORS.ButtonHover})
            task.wait(0.1)
            Utils.Tween(button.Frame, {BackgroundColor3 = COLORS.TabActive})
            
            config.Callback()
        end)
    end
    
    -- Hover effect
    Utils.AddHoverEffect(button.Frame, COLORS.ButtonHover, COLORS.TabActive)
    
    return button
end

function Tab:Toggle(config)
    local toggle = {}
    toggle.State = config.Default or false
    
    -- Toggle Frame
    toggle.Frame = Utils.Create("Frame", {
        Name = "Toggle",
        BackgroundColor3 = COLORS.TabActive,
        Size = UDim2.new(1, 0, 0, 40),
        BorderSizePixel = 0,
        Parent = self.Content
    })
    
    Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = toggle.Frame
    })
    
    -- Toggle Text
    toggle.Text = Utils.Create("TextLabel", {
        Name = "ToggleText",
        Text = config.Name or "Toggle",
        TextColor3 = COLORS.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggle.Frame
    })
    
    -- Toggle Switch Background
    toggle.SwitchBG = Utils.Create("Frame", {
        Name = "SwitchBG",
        BackgroundColor3 = toggle.State and Color3.fromRGB(100, 200, 100) or COLORS.Accent,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        BorderSizePixel = 0,
        Parent = toggle.Frame
    })
    
    Utils.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggle.SwitchBG
    })
    
    -- Toggle Switch
    toggle.Switch = Utils.Create("Frame", {
        Name = "Switch",
        BackgroundColor3 = COLORS.Text,
        Size = UDim2.new(0, 16, 0, 16),
        Position = toggle.State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BorderSizePixel = 0,
        Parent = toggle.SwitchBG
    })
    
    Utils.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggle.Switch
    })
    
    -- Toggle Button
    toggle.Button = Utils.Create("TextButton", {
        Name = "ToggleButton",
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = toggle.Frame
    })
    
    -- Toggle function
    local function toggleState()
        toggle.State = not toggle.State
        
        Utils.Tween(toggle.Switch, {
            Position = toggle.State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        })
        
        Utils.Tween(toggle.SwitchBG, {
            BackgroundColor3 = toggle.State and Color3.fromRGB(100, 200, 100) or COLORS.Accent
        })
        
        if config.Callback then
            config.Callback(toggle.State)
        end
    end
    
    toggle.Button.MouseButton1Click:Connect(toggleState)
    
    -- Methods
    function toggle:Set(state)
        if toggle.State ~= state then
            toggleState()
        end
    end
    
    return toggle
end

function Tab:Slider(config)
    local slider = {}
    slider.Value = config.Default or config.Min or 0
    
    -- Slider Frame
    slider.Frame = Utils.Create("Frame", {
        Name = "Slider",
        BackgroundColor3 = COLORS.TabActive,
        Size = UDim2.new(1, 0, 0, 60),
        BorderSizePixel = 0,
        Parent = self.Content
    })
    
    Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = slider.Frame
    })
    
    -- Slider Text
    slider.Text = Utils.Create("TextLabel", {
        Name = "SliderText",
        Text = config.Name or "Slider",
        TextColor3 = COLORS.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, 0, 0, 30),
        Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = slider.Frame
    })
    
    -- Value Label
    slider.ValueLabel = Utils.Create("TextLabel", {
        Name = "ValueLabel",
        Text = tostring(slider.Value),
        TextColor3 = COLORS.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.3, -10, 0, 30),
        Position = UDim2.new(0.7, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = slider.Frame
    })
    
    -- Slider Background
    slider.SliderBG = Utils.Create("Frame", {
        Name = "SliderBG",
        BackgroundColor3 = COLORS.Secondary,
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0, 35),
        BorderSizePixel = 0,
        Parent = slider.Frame
    })
    
    Utils.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = slider.SliderBG
    })
    
    -- Slider Fill
    slider.Fill = Utils.Create("Frame", {
        Name = "Fill",
        BackgroundColor3 = Color3.fromRGB(100, 200, 100),
        Size = UDim2.new((slider.Value - config.Min) / (config.Max - config.Min), 0, 1, 0),
        BorderSizePixel = 0,
        Parent = slider.SliderBG
    })
    
    Utils.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = slider.Fill
    })
    
    -- Slider Knob
    slider.Knob = Utils.Create("Frame", {
        Name = "Knob",
        BackgroundColor3 = COLORS.Text,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new((slider.Value - config.Min) / (config.Max - config.Min), -6, 0.5, -6),
        BorderSizePixel = 0,
        Parent = slider.SliderBG
    })
    
    Utils.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = slider.Knob
    })
    
    -- Slider functionality
    local dragging = false
    
    local function updateSlider(input)
        local relativeX = math.clamp((input.Position.X - slider.SliderBG.AbsolutePosition.X) / slider.SliderBG.AbsoluteSize.X, 0, 1)
        local value = math.floor(config.Min + (config.Max - config.Min) * relativeX)
        
        if config.Increment then
            value = math.floor(value / config.Increment) * config.Increment
        end
        
        slider.Value = value
        slider.ValueLabel.Text = tostring(value)
        
        Utils.Tween(slider.Knob, {
            Position = UDim2.new(relativeX, -6, 0.5, -6)
        }, TweenInfo.new(0.1))
        
        Utils.Tween(slider.Fill, {
            Size = UDim2.new(relativeX, 0, 1, 0)
        }, TweenInfo.new(0.1))
        
        if config.Callback then
            config.Callback(value)
        end
    end
    
    slider.Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    slider.SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
            dragging = true
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Methods
    function slider:Set(value)
        value = math.clamp(value, config.Min, config.Max)
        slider.Value = value
        slider.ValueLabel.Text = tostring(value)
        
        local percent = (value - config.Min) / (config.Max - config.Min)
        slider.Knob.Position = UDim2.new(percent, -6, 0.5, -6)
        slider.Fill.Size = UDim2.new(percent, 0, 1, 0)
        
        if config.Callback then
            config.Callback(value)
        end
    end
    
    return slider
end

-- Main Library Functions
function Library:CreateWindow(config)
    local window = Window:new(self, config)
    self.Window = window
    return window
end

-- Library Extension Support (Metatable for adding new methods)
setmetatable(Library, {
    __index = function(self, key)
        return rawget(self, key)
    end,
    __newindex = function(self, key, value)
        rawset(self, key, value)
    end
})

-- Extension example: Add new element types
function Library:ExtendTab(elementName, elementFunction)
    Tab[elementName] = elementFunction
end

-- Initialize and return library
return Library
