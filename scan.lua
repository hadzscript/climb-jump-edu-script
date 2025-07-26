-- Movement Recorder for Climb & Jump Tower
-- Custom UI by @hadzscript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Movement Recording
local recordedSlots = {} -- {slot1 = {movements}, slot2 = {...}, ...}
local currentSlot = 1
local isRecording = false
local isPlaying = false

-- Player Count
local playerCount = #Players:GetPlayers()

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MovementRecorderUI"
ScreenGui.Parent = Player.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "Movement Recorder"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "Status: Idle"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 35)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

local PlayerLabel = Instance.new("TextLabel")
PlayerLabel.Text = "Players: " .. playerCount
PlayerLabel.Font = Enum.Font.Gotham
PlayerLabel.TextSize = 12
PlayerLabel.TextColor3 = Color3.new(1, 1, 1)
PlayerLabel.BackgroundTransparency = 1
PlayerLabel.Size = UDim2.new(1, 0, 0, 20)
PlayerLabel.Position = UDim2.new(0, 10, 0, 55)
PlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerLabel.Parent = MainFrame

-- Slot Selection Dropdown
local SlotDropdown = Instance.new("TextButton")
SlotDropdown.Text = "Slot 1 ▼"
SlotDropdown.Font = Enum.Font.Gotham
SlotDropdown.TextSize = 14
SlotDropdown.TextColor3 = Color3.new(1, 1, 1)
SlotDropdown.Size = UDim2.new(0.9, 0, 0, 30)
SlotDropdown.Position = UDim2.new(0.05, 0, 0, 80)
SlotDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SlotDropdown.AutoButtonColor = true
SlotDropdown.Parent = MainFrame

local SlotOptions = Instance.new("Frame")
SlotOptions.Name = "SlotOptions"
SlotOptions.Size = UDim2.new(0.9, 0, 0, 90)
SlotOptions.Position = UDim2.new(0.05, 0, 0, 115)
SlotOptions.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SlotOptions.Visible = false
SlotOptions.Parent = MainFrame

local Slot1 = Instance.new("TextButton")
Slot1.Text = "Slot 1"
Slot1.Font = Enum.Font.Gotham
Slot1.TextSize = 14
Slot1.TextColor3 = Color3.new(1, 1, 1)
Slot1.Size = UDim2.new(1, 0, 0, 30)
Slot1.Position = UDim2.new(0, 0, 0, 0)
Slot1.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Slot1.AutoButtonColor = true
Slot1.Parent = SlotOptions

local Slot2 = Instance.new("TextButton")
Slot2.Text = "Slot 2"
Slot2.Font = Enum.Font.Gotham
Slot2.TextSize = 14
Slot2.TextColor3 = Color3.new(1, 1, 1)
Slot2.Size = UDim2.new(1, 0, 0, 30)
Slot2.Position = UDim2.new(0, 0, 0, 30)
Slot2.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Slot2.AutoButtonColor = true
Slot2.Parent = SlotOptions

local Slot3 = Instance.new("TextButton")
Slot3.Text = "Slot 3"
Slot3.Font = Enum.Font.Gotham
Slot3.TextSize = 14
Slot3.TextColor3 = Color3.new(1, 1, 1)
Slot3.Size = UDim2.new(1, 0, 0, 30)
Slot3.Position = UDim2.new(0, 0, 0, 60)
Slot3.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Slot3.AutoButtonColor = true
Slot3.Parent = SlotOptions

-- Buttons
local StartRecord = Instance.new("TextButton")
StartRecord.Text = "Start Recording"
StartRecord.Font = Enum.Font.Gotham
StartRecord.TextSize = 14
StartRecord.TextColor3 = Color3.new(1, 1, 1)
StartRecord.Size = UDim2.new(0.9, 0, 0, 30)
StartRecord.Position = UDim2.new(0.05, 0, 0, 120)
StartRecord.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
StartRecord.AutoButtonColor = true
StartRecord.Parent = MainFrame

local StopRecord = Instance.new("TextButton")
StopRecord.Text = "Stop Recording"
StopRecord.Font = Enum.Font.Gotham
StopRecord.TextSize = 14
StopRecord.TextColor3 = Color3.new(1, 1, 1)
StopRecord.Size = UDim2.new(0.9, 0, 0, 30)
StopRecord.Position = UDim2.new(0.05, 0, 0, 155)
StopRecord.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
StopRecord.AutoButtonColor = true
StopRecord.Parent = MainFrame

local PlayRecord = Instance.new("TextButton")
PlayRecord.Text = "Play Recording"
PlayRecord.Font = Enum.Font.Gotham
PlayRecord.TextSize = 14
PlayRecord.TextColor3 = Color3.new(1, 1, 1)
PlayRecord.Size = UDim2.new(0.9, 0, 0, 30)
PlayRecord.Position = UDim2.new(0.05, 0, 0, 190)
PlayRecord.BackgroundColor3 = Color3.fromRGB(0, 0, 170)
PlayRecord.AutoButtonColor = true
PlayRecord.Parent = MainFrame

local StopPlayback = Instance.new("TextButton")
StopPlayback.Text = "Stop Playback"
StopPlayback.Font = Enum.Font.Gotham
StopPlayback.TextSize = 14
StopPlayback.TextColor3 = Color3.new(1, 1, 1)
StopPlayback.Size = UDim2.new(0.9, 0, 0, 30)
StopPlayback.Position = UDim2.new(0.05, 0, 0, 225)
StopPlayback.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
StopPlayback.AutoButtonColor = true
StopPlayback.Parent = MainFrame

local DeleteSlot = Instance.new("TextButton")
DeleteSlot.Text = "Delete Slot"
DeleteSlot.Font = Enum.Font.Gotham
DeleteSlot.TextSize = 14
DeleteSlot.TextColor3 = Color3.new(1, 1, 1)
DeleteSlot.Size = UDim2.new(0.9, 0, 0, 30)
DeleteSlot.Position = UDim2.new(0.05, 0, 0, 260)
DeleteSlot.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
DeleteSlot.AutoButtonColor = true
DeleteSlot.Parent = MainFrame

-- UI Functions
SlotDropdown.MouseButton1Click:Connect(function()
    SlotOptions.Visible = not SlotOptions.Visible
end)

Slot1.MouseButton1Click:Connect(function()
    currentSlot = 1
    SlotDropdown.Text = "Slot 1 ▼"
    SlotOptions.Visible = false
    StatusLabel.Text = "Status: Selected Slot 1"
end)

Slot2.MouseButton1Click:Connect(function()
    currentSlot = 2
    SlotDropdown.Text = "Slot 2 ▼"
    SlotOptions.Visible = false
    StatusLabel.Text = "Status: Selected Slot 2"
end)

Slot3.MouseButton1Click:Connect(function()
    currentSlot = 3
    SlotDropdown.Text = "Slot 3 ▼"
    SlotOptions.Visible = false
    StatusLabel.Text = "Status: Selected Slot 3"
end)

-- Recording Logic
StartRecord.MouseButton1Click:Connect(function()
    if isRecording then return end
    recordedSlots[currentSlot] = {}
    isRecording = true
    StatusLabel.Text = "Status: Recording Slot " .. currentSlot
    
    local startTime = os.clock()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not isRecording then
            connection:Disconnect()
            return
        end
        table.insert(recordedSlots[currentSlot], {
            Position = RootPart.Position,
            Timestamp = os.clock() - startTime
        })
    end)
end)

StopRecord.MouseButton1Click:Connect(function()
    isRecording = false
    StatusLabel.Text = "Status: Saved to Slot " .. currentSlot
end)

PlayRecord.MouseButton1Click:Connect(function()
    if not recordedSlots[currentSlot] or #recordedSlots[currentSlot] == 0 then
        StatusLabel.Text = "Status: No recording in Slot " .. currentSlot
        return
    end
    
    if isPlaying then return end
    isPlaying = true
    StatusLabel.Text = "Status: Playing Slot " .. currentSlot
    
    local function playMovement()
        local startTime = os.clock()
        local index = 1
        
        while isPlaying and index <= #recordedSlots[currentSlot] do
            local movement = recordedSlots[currentSlot][index]
            local currentTime = os.clock() - startTime
            
            if currentTime >= movement.Timestamp then
                RootPart.CFrame = CFrame.new(movement.Position)
                index += 1
            end
            
            RunService.Heartbeat:Wait()
        end
        
        if isPlaying then -- Loop if still active
            playMovement()
        end
    end
    
    playMovement()
end)

StopPlayback.MouseButton1Click:Connect(function()
    isPlaying = false
    StatusLabel.Text = "Status: Stopped"
end)

DeleteSlot.MouseButton1Click:Connect(function()
    if recordedSlots[currentSlot] then
        recordedSlots[currentSlot] = nil
        StatusLabel.Text = "Status: Deleted Slot " .. currentSlot
    else
        StatusLabel.Text = "Status: Slot " .. currentSlot .. " is empty"
    end
end)

-- Player Count Updates
Players.PlayerAdded:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel.Text = "Players: " .. playerCount
end)

Players.PlayerRemoving:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel.Text = "Players: " .. playerCount
end)
