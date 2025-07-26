-- Advanced Movement Recorder for Climb & Jump Tower
-- Credits: @hadzscript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Movement Recording
local recordedSlots = {} -- Stores all recordings
local currentSlot = 1 -- Default slot
local isRecording = false
local isPlaying = false

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

-- Slot Selection Dropdown
local SlotDropdown = MainTab:CreateDropdown({
    Name = "Select Slot",
    Options = {"Slot 1", "Slot 2", "Slot 3"},
    CurrentOption = "Slot 1",
    Callback = function(Option)
        currentSlot = tonumber(string.match(Option, "%d+"))
        StatusLabel:Set("Status: Selected " .. Option)
    end
})

-- Start Recording
MainTab:CreateButton({
    Name = "Start Recording",
    Callback = function()
        if isRecording then return end
        recordedSlots[currentSlot] = {} -- Clear old recording
        isRecording = true
        StatusLabel:Set("Status: Recording Slot " .. currentSlot)
        
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
    end
})

-- Stop Recording
MainTab:CreateButton({
    Name = "Stop Recording",
    Callback = function()
        isRecording = false
        StatusLabel:Set("Status: Saved to Slot " .. currentSlot)
    end
})

-- Play Recording (Loop)
MainTab:CreateButton({
    Name = "Play Recording",
    Callback = function()
        if not recordedSlots[currentSlot] or #recordedSlots[currentSlot] == 0 then
            StatusLabel:Set("Status: No recording in Slot " .. currentSlot)
            return
        end
        
        if isPlaying then return end
        isPlaying = true
        StatusLabel:Set("Status: Playing Slot " .. currentSlot)
        
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
    end
})

-- Stop Playback
MainTab:CreateButton({
    Name = "Stop Playback",
    Callback = function()
        isPlaying = false
        StatusLabel:Set("Status: Stopped")
    end
})

-- Delete Current Slot
MainTab:CreateButton({
    Name = "Delete Slot",
    Callback = function()
        if recordedSlots[currentSlot] then
            recordedSlots[currentSlot] = nil
            StatusLabel:Set("Status: Deleted Slot " .. currentSlot)
        else
            StatusLabel:Set("Status: Slot " .. currentSlot .. " is empty")
        end
    end
})

-- Update Player Count
Players.PlayerAdded:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set("Players: " .. playerCount)
end)

Players.PlayerRemoving:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set("Players: " .. playerCount)
end)

Rayfield:Notify({
    Title = "Movement Recorder Ready",
    Content = "Record & replay your climbs!",
    Duration = 5,
    Image = "rbxassetid://4483362458"
})
