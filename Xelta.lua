local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Constants
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local ICON_URL = "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua"

-- Lucide Icon Manager
local IconManager = {}
IconManager.Icons = {}

-- โหลด Icon จาก Rayfield
spawn(function()
    local success, result = pcall(function()
        return game:HttpGet(ICON_URL)
    end)
    if success then
        local iconData = loadstring(result)()
        IconManager.Icons = iconData
    end
end)

function IconManager:GetIcon(name)
    return self.Icons[name] or ""
end

-- Utility Functions
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

-- UI Library Main Object
local UILibrary = {}
UILibrary.__index = UILibrary

-- Window Class
local Window = {}
Window.__index = Window

-- Tab Class  
local Tab = {}
Tab.__index = Tab

-- Initialize Library
function UILibrary.new()
    local self = setmetatable({}, UILibrary)
    self.Windows = {}
    return self
end

-- Create Window (Chain Function)
function UILibrary:CreateWindow(config)
    config = config or {}
    
    local window = setmetatable({}, Window)
    window.Name = config.Name or "SimpleUI"
    window.LoadingTitle = config.LoadingTitle or window.Name
    window.ConfigurationSaving = config.ConfigurationSaving or {Enabled = false}
    window.Tabs = {}
    window.ActiveTab = nil
    
    -- สร้าง GUI Elements
    window.ScreenGui = CreateInstance("ScreenGui", {
        Name = window.Name,
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Main Window Frame
    window.MainWindow = CreateInstance("Frame", {
        Name = "MainWindow",
        Parent = window.ScreenGui,
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Position = UDim2.new(0.5, -300, 0.5, -175),
        Size = UDim2.new(0, 600, 0, 350),
        BorderSizePixel = 0
    })
    
    -- Add Corner Rounding
    CreateInstance("UICorner", {
        Parent = window.MainWindow,
        CornerRadius = UDim.new(0, 8)
    })
    
    -- Header
    window.Header = CreateInstance("Frame", {
        Name = "Header",
        Parent = window.MainWindow,
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Size = UDim2.new(1, 0, 0, 40),
        BorderSizePixel = 0
    })
    
    -- Title
    window.Title = CreateInstance("TextLabel", {
        Name = "Title",
        Parent = window.Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -120, 1, 0),
        Font = Enum.Font.SourceSansBold,
        Text = window.LoadingTitle,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Header Separator
    CreateInstance("Frame", {
        Parent = window.Header,
        BackgroundColor3 = Color3.fromRGB(59, 59, 59),
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        BorderSizePixel = 0,
        ZIndex = 10
    })
    
    -- Window Controls Container
    local controlsContainer = CreateInstance("Frame", {
        Parent = window.Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -90, 0, 0),
        Size = UDim2.new(0, 90, 1, 0)
    })
    
    -- Close Button
    window.CloseButton = CreateInstance("ImageButton", {
        Name = "Close",
        Parent = controlsContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0.5, -7.5),
        Size = UDim2.new(0, 15, 0, 15),
        Image = "rbxassetid://10734965702",
        ImageColor3 = Color3.fromRGB(255, 255, 255)
    })
    
    -- Fullscreen Button
    window.FullscreenButton = CreateInstance("ImageButton", {
        Name = "Fullscreen",
        Parent = controlsContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -50, 0.5, -7.5),
        Size = UDim2.new(0, 15, 0, 15),
        Image = "rbxassetid://10747384394",
        ImageColor3 = Color3.fromRGB(255, 255, 255)
    })
    
    -- Minimize Button
    window.MinimizeButton = CreateInstance("ImageButton", {
        Name = "Minimize",
        Parent = controlsContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -75, 0.5, -7.5),
        Size = UDim2.new(0, 15, 0, 15),
        Image = "rbxassetid://10734896206",
        ImageColor3 = Color3.fromRGB(255, 255, 255)
    })
    
    -- Sidebar
    window.Sidebar = CreateInstance("Frame", {
        Name = "Sidebar",
        Parent = window.MainWindow,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 120, 1, -40),
        BorderSizePixel = 0
    })
    
    -- Sidebar ScrollingFrame
    window.SidebarScroll = CreateInstance("ScrollingFrame", {
        Parent = window.Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 1, -20),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0
    })
    
    -- Tab List Layout
    window.TabListLayout = CreateInstance("UIListLayout", {
        Parent = window.SidebarScroll,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    -- Content Area
    window.Content = CreateInstance("Frame", {
        Name = "Content",
        Parent = window.MainWindow,
        BackgroundColor3 = Color3.fromRGB(31, 31, 31),
        Position = UDim2.new(0, 121, 0, 41),
        Size = UDim2.new(1, -122, 1, -42),
        BorderSizePixel = 0
    })
    
    CreateInstance("UICorner", {
        Parent = window.Content,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Content ScrollingFrame (จะถูกสร้างเมื่อมี Tab)
    
    -- Window State Variables
    window.Minimized = false
    window.Fullscreen = false
    window.OriginalSize = window.MainWindow.Size
    window.OriginalPosition = window.MainWindow.Position
    
    -- Setup Window Controls
    self:SetupWindowControls(window)
    
    -- Setup Mobile Drag
    self:SetupMobileDrag(window)
    
    -- Update Canvas Size เมื่อมีการเพิ่ม Tab
    window.TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        window.SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, window.TabListLayout.AbsoluteContentSize.Y)
    end)
    
    table.insert(self.Windows, window)
    return window
end

-- Setup Window Controls (Minimize, Fullscreen, Close)
function UILibrary:SetupWindowControls(window)
    -- Minimize
    window.MinimizeButton.MouseButton1Click:Connect(function()
        window.Minimized = not window.Minimized
        
        if window.Minimized then
            -- ย่อเหลือแค่ Header
            local tween = TweenService:Create(window.MainWindow, TWEEN_INFO, {
                Size = UDim2.new(window.MainWindow.Size.X.Scale, window.MainWindow.Size.X.Offset, 0, 40)
            })
            tween:Play()
            
            -- ซ่อน Content และ Sidebar
            window.Content.Visible = false
            window.Sidebar.Visible = false
        else
            -- คืนขนาดเดิม
            local tween = TweenService:Create(window.MainWindow, TWEEN_INFO, {
                Size = window.OriginalSize
            })
            tween:Play()
            
            -- แสดง Content และ Sidebar
            wait(0.1)
            window.Content.Visible = true
            window.Sidebar.Visible = true
        end
    end)
    
    -- Fullscreen
    window.FullscreenButton.MouseButton1Click:Connect(function()
        window.Fullscreen = not window.Fullscreen
        
        if window.Fullscreen then
            -- เต็มหน้าจอ
            window.OriginalSize = window.MainWindow.Size
            window.OriginalPosition = window.MainWindow.Position
            
            local tween = TweenService:Create(window.MainWindow, TWEEN_INFO, {
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0)
            })
            tween:Play()
        else
            -- คืนขนาดเดิม
            local tween = TweenService:Create(window.MainWindow, TWEEN_INFO, {
                Position = window.OriginalPosition,
                Size = window.OriginalSize
            })
            tween:Play()
        end
    end)
    
    -- Close (ไม่ทำลาย GUI แค่ซ่อน)
    window.CloseButton.MouseButton1Click:Connect(function()
        window.MainWindow.Visible = false
        -- เก็บ state ไว้สำหรับเปิดใหม่ภายหลัง
        window.Closed = true
    end)
end

-- Setup Mobile Drag (ลากได้เฉพาะขอบ)
function UILibrary:SetupMobileDrag(window)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local edgeSize = 10 -- ขนาดของขอบที่สามารถลากได้
    
    local function isOnEdge(input)
        local relativePos = input.Position - window.MainWindow.AbsolutePosition
        local size = window.MainWindow.AbsoluteSize
        
        -- ตรวจสอบว่าอยู่บนขอบหรือไม่
        return relativePos.X <= edgeSize or -- ขอบซ้าย
               relativePos.X >= size.X - edgeSize or -- ขอบขวา
               relativePos.Y <= edgeSize or -- ขอบบน
               relativePos.Y >= size.Y - edgeSize -- ขอบล่าง
    end
    
    window.MainWindow.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if isOnEdge(input) then
                dragging = true
                dragStart = input.Position
                startPos = window.MainWindow.Position
            end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            window.MainWindow.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Window Methods

-- Create Tab (Chain Function)
function Window:CreateTab(config)
    config = config or {}
    
    local tab = setmetatable({}, Tab)
    tab.Name = config.Name or "Tab"
    tab.Icon = config.Icon or "house"
    tab.Window = self
    tab.Elements = {}
    
    -- สร้าง Tab Button
    tab.Button = CreateInstance("TextButton", {
        Name = tab.Name,
        Parent = self.SidebarScroll,
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        Size = UDim2.new(1, -10, 0, 35),
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    
    CreateInstance("UICorner", {
        Parent = tab.Button,
        CornerRadius = UDim.new(0, 6)
    })
    
    -- Tab Icon
    tab.IconLabel = CreateInstance("ImageLabel", {
        Parent = tab.Button,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = IconManager:GetIcon(tab.Icon),
        ImageColor3 = Color3.fromRGB(200, 200, 200)
    })
    
    -- Tab Text
    tab.TextLabel = CreateInstance("TextLabel", {
        Parent = tab.Button,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 35, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = Enum.Font.SourceSans,
        Text = tab.Name,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- สร้าง Content Container สำหรับ Tab นี้
    tab.Container = CreateInstance("ScrollingFrame", {
        Parent = self.Content,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0,
        Visible = false
    })
    
    -- Content Layout
    tab.Layout = CreateInstance("UIListLayout", {
        Parent = tab.Container,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    CreateInstance("UIPadding", {
        Parent = tab.Container,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })
    
    -- Update Canvas Size
    tab.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.Container.CanvasSize = UDim2.new(0, 0, 0, tab.Layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Tab Click Event
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    -- เพิ่ม Tab เข้า Window
    table.insert(self.Tabs, tab)
    
    -- ถ้าเป็น Tab แรก ให้เลือกอัตโนมัติ
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

-- Select Tab
function Window:SelectTab(tab)
    -- ซ่อน Container เก่า
    if self.ActiveTab then
        self.ActiveTab.Container.Visible = false
        -- Reset สีของ Tab เก่า
        TweenService:Create(self.ActiveTab.Button, TWEEN_INFO, {
            BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        }):Play()
        TweenService:Create(self.ActiveTab.IconLabel, TWEEN_INFO, {
            ImageColor3 = Color3.fromRGB(200, 200, 200)
        }):Play()
        TweenService:Create(self.ActiveTab.TextLabel, TWEEN_INFO, {
            TextColor3 = Color3.fromRGB(200, 200, 200)
        }):Play()
    end
    
    -- แสดง Container ใหม่
    tab.Container.Visible = true
    self.ActiveTab = tab
    
    -- Highlight Tab ที่เลือก
    TweenService:Create(tab.Button, TWEEN_INFO, {
        BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    }):Play()
    TweenService:Create(tab.IconLabel, TWEEN_INFO, {
        ImageColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
    TweenService:Create(tab.TextLabel, TWEEN_INFO, {
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end

-- Update Window Title (Chain Function)
function Window:UpdateTitle(newTitle)
    self.Title.Text = newTitle
    return self
end

-- Show Window (ถ้าถูกปิดไป)
function Window:Show()
    self.MainWindow.Visible = true
    self.Closed = false
    return self
end

-- Hide Window
function Window:Hide()
    self.MainWindow.Visible = false
    return self
end

-- Tab Methods (Placeholder สำหรับ Part 2)

-- Add Toggle (จะ implement ใน Part 2)
function Tab:AddToggle(config)
    -- Placeholder for Part 2
    print("Toggle will be implemented in Part 2")
    return {}
end

-- Add Slider (จะ implement ใน Part 2)
function Tab:AddSlider(config)
    -- Placeholder for Part 2
    print("Slider will be implemented in Part 2")
    return {}
end

-- Add Dropdown (จะ implement ใน Part 2)
function Tab:AddDropdown(config)
    -- Placeholder for Part 2
    print("Dropdown will be implemented in Part 2")
    return {}
end

-- Add TextBox (จะ implement ใน Part 2)
function Tab:AddInput(config)
    -- Placeholder for Part 2
    print("TextBox will be implemented in Part 2")
    return {}
end

-- สร้าง Metatable สำหรับ extensibility
local LibraryMetatable = {
    __index = UILibrary,
    __newindex = function(self, key, value)
        -- อนุญาตให้เพิ่ม method ใหม่
        rawset(self, key, value)
    end
}

local WindowMetatable = {
    __index = Window,
    __newindex = function(self, key, value)
        rawset(self, key, value)
    end
}

local TabMetatable = {
    __index = Tab,
    __newindex = function(self, key, value)
        rawset(self, key, value)
    end
}

-- Apply Metatables
setmetatable(UILibrary, LibraryMetatable)
setmetatable(Window, WindowMetatable)
setmetatable(Tab, TabMetatable)

-- Return Library Instance
return UILibrary.new()
