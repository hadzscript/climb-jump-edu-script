-- Professional Movement Recorder
-- By @hadzscript (Credits)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Persistent Data
local DATA_KEY = "MovementRecorderData"
local recordedSlots = {
    Slot1 = {Movements = {}, IsPlaying = false},
    Slot2 = {Movements = {}, IsPlaying = false},
    Slot3 = {Movements = {}, IsPlaying = false}
}

-- Load saved data
local function LoadData()
    local saved = game:GetService("HttpService"):JSONDecode(
        Player:GetAttribute(DATA_KEY) or "{}"
    if saved then
        recordedSlots = saved
    end
end

-- Save data
local function SaveData()
    Player:SetAttribute(DATA_KEY, 
        game:GetService("HttpService"):JSONEncode(recordedSlots))
end

LoadData()

-- Player Count
local playerCount = #Players:GetPlayers()

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MovementRecorderUI"
ScreenGui.Parent = Player.PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "MOVEMENT RECORDER PRO"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Hide/Minimize Buttons
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Text = "_"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 20
MinimizeButton.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Text = "X"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = TitleBar

-- Status Bar
local StatusBar = Instance.new("Frame")
StatusBar.Name = "StatusBar"
StatusBar.Size = UDim2.new(1, -20, 0, 40)
StatusBar.Position = UDim2.new(0, 10, 0, 40)
StatusBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
StatusBar.BorderSizePixel = 0
StatusBar.Parent = MainFrame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 6)
UICorner2.Parent = StatusBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Text = "Status: Ready"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(0.5, -5, 1, 0)
StatusLabel.Position = UDim2.new(0, 10, 0, 0)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusBar

local PlayerLabel = Instance.new("TextLabel")
PlayerLabel.Name = "PlayerLabel"
PlayerLabel.Text = "Players: "..playerCount
PlayerLabel.Font = Enum.Font.Gotham
PlayerLabel.TextSize = 12
PlayerLabel.TextColor3 = Color3.new(1, 1, 1)
PlayerLabel.BackgroundTransparency = 1
PlayerLabel.Size = UDim2.new(0.5, -5, 1, 0)
PlayerLabel.Position = UDim2.new(0.5, 5, 0, 0)
PlayerLabel.TextXAlignment = Enum.TextXAlignment.Right
PlayerLabel.Parent = StatusBar

-- Tab System
local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Size = UDim2.new(1, -20, 0, 30)
TabButtons.Position = UDim2.new(0, 10, 0, 90)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = MainFrame

local RecordTabButton = Instance.new("TextButton")
RecordTabButton.Name = "RecordTabButton"
RecordTabButton.Text = "RECORD"
RecordTabButton.Size = UDim2.new(0.5, -5, 1, 0)
RecordTabButton.Position = UDim2.new(0, 0, 0, 0)
RecordTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
RecordTabButton.TextColor3 = Color3.new(1, 1, 1)
RecordTabButton.Font = Enum.Font.GothamBold
RecordTabButton.TextSize = 12
RecordTabButton.Parent = TabButtons

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 6)
UICorner3.Parent = RecordTabButton

local SlotsTabButton = Instance.new("TextButton")
SlotsTabButton.Name = "SlotsTabButton"
SlotsTabButton.Text = "SLOTS"
SlotsTabButton.Size = UDim2.new(0.5, -5, 1, 0)
SlotsTabButton.Position = UDim2.new(0.5, 5, 0, 0)
SlotsTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
SlotsTabButton.TextColor3 = Color3.new(1, 1, 1)
SlotsTabButton.Font = Enum.Font.GothamBold
SlotsTabButton.TextSize = 12
SlotsTabButton.Parent = TabButtons

local UICorner4 = Instance.new("UICorner")
UICorner4.CornerRadius = UDim.new(0, 6)
UICorner4.Parent = SlotsTabButton

-- Tab Content
local TabContent = Instance.new("Frame")
TabContent.Name = "TabContent"
TabContent.Size = UDim2.new(1, -20, 1, -140)
TabContent.Position = UDim2.new(0, 10, 0, 130)
TabContent.BackgroundTransparency = 1
TabContent.Parent = MainFrame

-- Recording Tab
local RecordTab = Instance.new("Frame")
RecordTab.Name = "RecordTab"
RecordTab.Size = UDim2.new(1, 0, 1, 0)
RecordTab.BackgroundTransparency = 1
RecordTab.Visible = true
RecordTab.Parent = TabContent

local SlotSelector = Instance.new("TextLabel")
SlotSelector.Name = "SlotSelector"
SlotSelector.Text = "SELECT SLOT:"
SlotSelector.Font = Enum.Font.GothamBold
SlotSelector.TextSize = 12
SlotSelector.TextColor3 = Color3.new(1, 1, 1)
SlotSelector.BackgroundTransparency = 1
SlotSelector.Size = UDim2.new(1, 0, 0, 20)
SlotSelector.Position = UDim2.new(0, 0, 0, 0)
SlotSelector.TextXAlignment = Enum.TextXAlignment.Left
SlotSelector.Parent = RecordTab

local SlotDropdown = Instance.new("Frame")
SlotDropdown.Name = "SlotDropdown"
SlotDropdown.Size = UDim2.new(1, 0, 0, 30)
SlotDropdown.Position = UDim2.new(0, 0, 0, 25)
SlotDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
SlotDropdown.Parent = RecordTab

local UICorner5 = Instance.new("UICorner")
UICorner5.CornerRadius = UDim.new(0, 6)
UICorner5.Parent = SlotDropdown

local Slot1Button = Instance.new("TextButton")
Slot1Button.Name = "Slot1Button"
Slot1Button.Text = "SLOT 1"
Slot1Button.Size = UDim2.new(0.333, -4, 1, 0)
Slot1Button.Position = UDim2.new(0, 0, 0, 0)
Slot1Button.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
Slot1Button.TextColor3 = Color3.new(1, 1, 1)
Slot1Button.Font = Enum.Font.Gotham
Slot1Button.TextSize = 12
Slot1Button.Parent = SlotDropdown

local Slot2Button = Instance.new("TextButton")
Slot2Button.Name = "Slot2Button"
Slot2Button.Text = "SLOT 2"
Slot2Button.Size = UDim2.new(0.333, -4, 1, 0)
Slot2Button.Position = UDim2.new(0.333, 2, 0, 0)
Slot2Button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
Slot2Button.TextColor3 = Color3.new(1, 1, 1)
Slot2Button.Font = Enum.Font.Gotham
Slot2Button.TextSize = 12
Slot2Button.Parent = SlotDropdown

local Slot3Button = Instance.new("TextButton")
Slot3Button.Name = "Slot3Button"
Slot3Button.Text = "SLOT 3"
Slot3Button.Size = UDim2.new(0.333, -4, 1, 0)
Slot3Button.Position = UDim2.new(0.666, 4, 0, 0)
Slot3Button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
Slot3Button.TextColor3 = Color3.new(1, 1, 1)
Slot3Button.Font = Enum.Font.Gotham
Slot3Button.TextSize = 12
Slot3Button.Parent = SlotDropdown

local StartRecordingButton = Instance.new("TextButton")
StartRecordingButton.Name = "StartRecordingButton"
StartRecordingButton.Text = "START RECORDING"
StartRecordingButton.Size = UDim2.new(1, 0, 0, 40)
StartRecordingButton.Position = UDim2.new(0, 0, 0, 70)
StartRecordingButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
StartRecordingButton.TextColor3 = Color3.new(1, 1, 1)
StartRecordingButton.Font = Enum.Font.GothamBold
StartRecordingButton.TextSize = 14
StartRecordingButton.Parent = RecordTab

local UICorner6 = Instance.new("UICorner")
UICorner6.CornerRadius = UDim.new(0, 6)
UICorner6.Parent = StartRecordingButton

local StopRecordingButton = Instance.new("TextButton")
StopRecordingButton.Name = "StopRecordingButton"
StopRecordingButton.Text = "STOP RECORDING"
StopRecordingButton.Size = UDim2.new(1, 0, 0, 40)
StopRecordingButton.Position = UDim2.new(0, 0, 0, 120)
StopRecordingButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
StopRecordingButton.TextColor3 = Color3.new(1, 1, 1)
StopRecordingButton.Font = Enum.Font.GothamBold
StopRecordingButton.TextSize = 14
StopRecordingButton.Parent = RecordTab

local UICorner7 = Instance.new("UICorner")
UICorner7.CornerRadius = UDim.new(0, 6)
UICorner7.Parent = StopRecordingButton

-- Slots Tab
local SlotsTab = Instance.new("Frame")
SlotsTab.Name = "SlotsTab"
SlotsTab.Size = UDim2.new(1, 0, 1, 0)
SlotsTab.BackgroundTransparency = 1
SlotsTab.Visible = false
SlotsTab.Parent = TabContent

-- Create slot controls for each slot
for i = 1, 3 do
    local slotFrame = Instance.new("Frame")
    slotFrame.Name = "Slot"..i.."Frame"
    slotFrame.Size = UDim2.new(1, 0, 0, 100)
    slotFrame.Position = UDim2.new(0, 0, 0, (i-1)*110)
    slotFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    slotFrame.Parent = SlotsTab

    local UICornerSlot = Instance.new("UICorner")
    UICornerSlot.CornerRadius = UDim.new(0, 6)
    UICornerSlot.Parent = slotFrame

    local slotLabel = Instance.new("TextLabel")
    slotLabel.Name = "Slot"..i.."Label"
    slotLabel.Text = "SLOT "..i
    slotLabel.Font = Enum.Font.GothamBold
    slotLabel.TextSize = 14
    slotLabel.TextColor3 = Color3.new(1, 1, 1)
    slotLabel.BackgroundTransparency = 1
    slotLabel.Size = UDim2.new(1, -20, 0, 30)
    slotLabel.Position = UDim2.new(0, 10, 0, 5)
    slotLabel.TextXAlignment = Enum.TextXAlignment.Left
    slotLabel.Parent = slotFrame

    local playButton = Instance.new("TextButton")
    playButton.Name = "PlayButton"
    playButton.Text = "PLAY"
    playButton.Size = UDim2.new(0.5, -15, 0, 30)
    playButton.Position = UDim2.new(0, 10, 0, 40)
    playButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    playButton.TextColor3 = Color3.new(1, 1, 1)
    playButton.Font = Enum.Font.GothamBold
    playButton.TextSize = 12
    playButton.Parent = slotFrame

    local UICornerPlay = Instance.new("UICorner")
    UICornerPlay.CornerRadius = UDim.new(0, 6)
    UICornerPlay.Parent = playButton

    local stopButton = Instance.new("TextButton")
    stopButton.Name = "StopButton"
    stopButton.Text = "STOP"
    stopButton.Size = UDim2.new(0.5, -15, 0, 30)
    stopButton.Position = UDim2.new(0.5, 5, 0, 40)
    stopButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    stopButton.TextColor3 = Color3.new(1, 1, 1)
    stopButton.Font = Enum.Font.GothamBold
    stopButton.TextSize = 12
    stopButton.Parent = slotFrame

    local UICornerStop = Instance.new("UICorner")
    UICornerStop.CornerRadius = UDim.new(0, 6)
    UICornerStop.Parent = stopButton

    local deleteButton = Instance.new("TextButton")
    deleteButton.Name = "DeleteButton"
    deleteButton.Text = "DELETE"
    deleteButton.Size = UDim2.new(1, -20, 0, 30)
    deleteButton.Position = UDim2.new(0, 10, 0, 75)
    deleteButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    deleteButton.TextColor3 = Color3.new(1, 1, 1)
    deleteButton.Font = Enum.Font.GothamBold
    deleteButton.TextSize = 12
    deleteButton.Parent = slotFrame

    local UICornerDelete = Instance.new("UICorner")
    UICornerDelete.CornerRadius = UDim.new(0, 6)
    UICornerDelete.Parent = deleteButton
end

-- UI Functions
local selectedSlot = 1
local isRecording = false

-- Slot selection
Slot1Button.MouseButton1Click:Connect(function()
    selectedSlot = 1
    Slot1Button.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    Slot2Button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    Slot3Button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
end)

Slot2Button.MouseButton1Click:Connect(function()
    selectedSlot = 2
    Slot1Button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    Slot2Button.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    Slot3Button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
end)

Slot3Button.MouseButton1Click:Connect(function()
    selectedSlot = 3
    Slot1Button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    Slot2Button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    Slot3Button.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
end)

-- Tab switching
RecordTabButton.MouseButton1Click:Connect(function()
    RecordTab.Visible = true
    SlotsTab.Visible = false
    RecordTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    SlotsTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
end)

SlotsTabButton.MouseButton1Click:Connect(function()
    RecordTab.Visible = false
    SlotsTab.Visible = true
    RecordTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    SlotsTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
end)

-- Minimize/Close
local isMinimized = false
local originalSize = MainFrame.Size

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 350, 0, 30)
        TabContent.Visible = false
        StatusBar.Visible = false
        TabButtons.Visible = false
    else
        MainFrame.Size = originalSize
        TabContent.Visible = true
        StatusBar.Visible = true
        TabButtons.Visible = true
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Recording functionality
StartRecordingButton.MouseButton1Click:Connect(function()
    if isRecording then return end
    
    isRecording = true
    recordedSlots["Slot"..selectedSlot].Movements = {}
    StatusLabel.Text = "Status: Recording Slot "..selectedSlot
    
    local startTime = os.clock()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not isRecording then
            connection:Disconnect()
            SaveData()
            return
        end
        
        table.insert(recordedSlots["Slot"..selectedSlot].Movements, {
            Position = RootPart.Position,
            Timestamp = os.clock() - startTime
        })
    end)
end)

StopRecordingButton.MouseButton1Click:Connect(function()
    isRecording = false
    StatusLabel.Text = "Status: Saved to Slot "..selectedSlot
end)

-- Playback functionality
for i = 1, 3 do
    local slotName = "Slot"..i
    local playButton = SlotsTab:FindFirstChild(slotName.."Frame"):FindFirstChild("PlayButton")
    local stopButton = SlotsTab:FindFirstChild(slotName.."Frame"):FindFirstChild("StopButton")
    local deleteButton = SlotsTab:FindFirstChild(slotName.."Frame"):FindFirstChild("DeleteButton")
    
    playButton.MouseButton1Click:Connect(function()
        if #recordedSlots[slotName].Movements == 0 then return end
        
        recordedSlots[slotName].IsPlaying = true
        StatusLabel.Text = "Status: Playing Slot "..i
        
        local function playMovement()
            local startTime = os.clock()
            local index = 1
            
            while recordedSlots[slotName].IsPlaying and index <= #recordedSlots[slotName].Movements do
                local movement = recordedSlots[slotName].Movements[index]
                local currentTime = os.clock() - startTime
                
                if currentTime >= movement.Timestamp then
                    RootPart.CFrame = CFrame.new(movement.Position)
                    index += 1
                end
                
                RunService.Heartbeat:Wait()
            end
            
            if recordedSlots[slotName].IsPlaying then
                playMovement() -- Loop
            end
        end
        
        playMovement()
    end)
    
    stopButton.MouseButton1Click:Connect(function()
        recordedSlots[slotName].IsPlaying = false
        StatusLabel.Text = "Status: Stopped Slot "..i
    end)
    
    deleteButton.MouseButton1Click:Connect(function()
        recordedSlots[slotName].Movements = {}
        SaveData()
        StatusLabel.Text = "Status: Deleted Slot "..i
    end)
end

-- Player count updater
Players.PlayerAdded:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel.Text = "Players: "..playerCount
end)

Players.PlayerRemoving:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel.Text = "Players: "..playerCount
end)
