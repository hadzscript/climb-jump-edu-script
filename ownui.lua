-- Persistent Movement Recorder for Climb & Jump Tower
-- Credits: @hadzscript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Persistent Data Setup
local DATA_KEY = "MovementRecorderData"
local recordedSlots = {
    Slot1 = { Movements = {}, IsPlaying = false },
    Slot2 = { Movements = {}, IsPlaying = false },
    Slot3 = { Movements = {}, IsPlaying = false }
}

-- Load saved data
local function LoadData()
    local saved = Player:GetAttribute(DATA_KEY)
    if saved then
        recordedSlots = HttpService:JSONDecode(saved)
    end
end

-- Save data
local function SaveData()
    Player:SetAttribute(DATA_KEY, HttpService:JSONEncode(recordedSlots))
end

-- Player Count
local playerCount = #Players:GetPlayers()

-- Create UI
local Window = Rayfield:CreateWindow({
    Name = "Movement Recorder PRO",
    LoadingTitle = "Loading Recorder...",
    LoadingSubtitle = "By @hadzscript",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MovementRecorder",
        FileName = "Settings"
    }
})

local MainTab = Window:CreateTab("Recorder", 4483362458)
local StatusLabel = MainTab:CreateLabel("Status: Idle")
local PlayerLabel = MainTab:CreateLabel("Players: " .. playerCount)

-- Function to update slot buttons
local function UpdateSlotDisplays()
    for _, slotFrame in pairs(MainTab:GetChildren()) do
        if slotFrame:IsA("Frame") then
            slotFrame:Destroy()
        end
    end

    for slotName, slotData in pairs(recordedSlots) do
        local slotFrame = Instance.new("Frame")
        slotFrame.Size = UDim2.new(1, 0, 0, 120)
        slotFrame.BackgroundTransparency = 1
        slotFrame.LayoutOrder = tonumber(string.sub(slotName, 5))
        slotFrame.Parent = MainTab

        local slotLabel = Instance.new("TextLabel")
        slotLabel.Text = slotName .. " ("..#slotData.Movements.." frames)"
        slotLabel.Size = UDim2.new(1, 0, 0, 20)
        slotLabel.Font = Enum.Font.GothamBold
        slotLabel.TextColor3 = Color3.new(1, 1, 1)
        slotLabel.BackgroundTransparency = 1
        slotLabel.Parent = slotFrame

        -- Record Button
        local recordBtn = Instance.new("TextButton")
        recordBtn.Text = "Record"
        recordBtn.Size = UDim2.new(1, -10, 0, 30)
        recordBtn.Position = UDim2.new(0, 5, 0, 25)
        recordBtn.Parent = slotFrame
        recordBtn.MouseButton1Click:Connect(function()
            if recordedSlots[slotName].IsPlaying then return end
            recordedSlots[slotName].Movements = {}
            StatusLabel:Set("Status: Recording "..slotName)
            
            local startTime = os.clock()
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if recordedSlots[slotName].IsPlaying then
                    connection:Disconnect()
                    return
                end
                table.insert(recordedSlots[slotName].Movements, {
                    Position = RootPart.Position,
                    Timestamp = os.clock() - startTime
                })
            end)
        end)

        -- Play Button
        local playBtn = Instance.new("TextButton")
        playBtn.Text = "Play"
        playBtn.Size = UDim2.new(0.48, -5, 0, 30)
        playBtn.Position = UDim2.new(0, 5, 0, 60)
        playBtn.Parent = slotFrame
        playBtn.MouseButton1Click:Connect(function()
            if #recordedSlots[slotName].Movements == 0 then return end
            recordedSlots[slotName].IsPlaying = true
            StatusLabel:Set("Status: Playing "..slotName)
            
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

        -- Stop Button
        local stopBtn = Instance.new("TextButton")
        stopBtn.Text = "Stop"
        stopBtn.Size = UDim2.new(0.48, -5, 0, 30)
        stopBtn.Position = UDim2.new(0.52, 5, 0, 60)
        stopBtn.Parent = slotFrame
        stopBtn.MouseButton1Click:Connect(function()
            recordedSlots[slotName].IsPlaying = false
            StatusLabel:Set("Status: Stopped "..slotName)
        end)

        -- Delete Button
        local deleteBtn = Instance.new("TextButton")
        deleteBtn.Text = "Delete"
        deleteBtn.Size = UDim2.new(1, -10, 0, 30)
        deleteBtn.Position = UDim2.new(0, 5, 0, 95)
        deleteBtn.Parent = slotFrame
        deleteBtn.MouseButton1Click:Connect(function()
            recordedSlots[slotName] = { Movements = {}, IsPlaying = false }
            StatusLabel:Set("Status: Deleted "..slotName)
            UpdateSlotDisplays()
        end)
    end
end

-- Update Player Count
Players.PlayerAdded:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set("Players: " .. playerCount)
end)

Players.PlayerRemoving:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set("Players: " .. playerCount)
end)

-- Auto-save every 30 seconds
task.spawn(function()
    while task.wait(30) do
        SaveData()
    end
end)

-- Initialize
LoadData()
UpdateSlotDisplays()
Rayfield:Notify({
    Title = "Movement Recorder Ready",
    Content = "Recordings persist across sessions!",
    Duration = 5,
    Image = "rbxassetid://4483362458"
})
