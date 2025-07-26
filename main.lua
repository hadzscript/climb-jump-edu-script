-- Advanced Movement Recorder & Looper
-- With Slot System & Clean UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Movement Recording
local recordings = {} -- Stores all saved recordings
local currentRecording = {}
local isRecording = false
local isPlaying = false
local playSpeed = 1 -- Default speed
local selectedSlot = 1 -- Currently selected slot

-- Player Count
local playerCount = #Players:GetPlayers()

-- Create UI
local Window = Rayfield:CreateWindow({
    Name = "Movement Recorder PRO",
    LoadingTitle = "Loading Recorder...",
    LoadingSubtitle = "By YourName",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MovementRecorder",
        FileName = "Settings"
    }
})

local MainTab = Window:CreateTab("Recorder", 4483362458)
local StatusLabel = MainTab:CreateLabel("Status: Idle")
local PlayerLabel = MainTab:CreateLabel("Players: " .. playerCount)

-- Recording Controls (Single Row)
local ControlRow = MainTab:CreateSection("Controls", true)

ControlRow:CreateButton({
    Name = "▶️ Record",
    Callback = function()
        if isRecording then return end
        currentRecording = {}
        isRecording = true
        StatusLabel:Set("Status: Recording...")
        
        local startTime = os.clock()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not isRecording then
                connection:Disconnect()
                return
            end
            table.insert(currentRecording, {
                Position = RootPart.Position,
                Timestamp = os.clock() - startTime
            })
        end)
    end
})

ControlRow:CreateButton({
    Name = "⏹ Stop",
    Callback = function()
        if not isRecording then return end
        isRecording = false
        StatusLabel:Set("Status: Recorded (" .. #currentRecording .. " frames)")
    end
})

ControlRow:CreateButton({
    Name = "💾 Save to Slot",
    Callback = function()
        if #currentRecording == 0 then
            Rayfield:Notify({
                Title = "Error",
                Content = "No recording to save!",
                Duration = 3
            })
            return
        end
        recordings[selectedSlot] = currentRecording
        Rayfield:Notify({
            Title = "Saved",
            Content = "Recording saved to Slot " .. selectedSlot,
            Duration = 3
        })
    end
})

-- Playback Controls
local PlaybackRow = MainTab:CreateSection("Playback", true)

PlaybackRow:CreateButton({
    Name = "🔁 Play (Loop)",
    Callback = function()
        if not recordings[selectedSlot] then
            Rayfield:Notify({
                Title = "Error",
                Content = "No recording in Slot " .. selectedSlot,
                Duration = 3
            })
            return
        end
        
        if isPlaying then return end
        isPlaying = true
        StatusLabel:Set("Status: Playing Slot " .. selectedSlot)
        
        local function playLoop()
            local startTime = os.clock()
            local index = 1
            local recording = recordings[selectedSlot]
            
            while isPlaying and index <= #recording do
                local movement = recording[index]
                local currentTime = (os.clock() - startTime) * playSpeed
                
                if currentTime >= movement.Timestamp then
                    RootPart.CFrame = CFrame.new(movement.Position)
                    index += 1
                end
                RunService.Heartbeat:Wait()
            end
            
            if isPlaying then -- Loop
                playLoop()
            end
        end
        
        playLoop()
    end
})

PlaybackRow:CreateButton({
    Name = "⏹ Stop Playback",
    Callback = function()
        isPlaying = false
        StatusLabel:Set("Status: Stopped")
    end
})

-- Slot Management
local SlotRow = MainTab:CreateSection("Slots", true)

for i = 1, 3 do -- 3 slots by default (expandable)
    SlotRow:CreateButton({
        Name = "Slot " .. i,
        Callback = function()
            selectedSlot = i
            StatusLabel:Set("Status: Selected Slot " .. i)
        end
    })
end

SlotRow:CreateButton({
    Name = "🗑 Delete Slot",
    Callback = function()
        if not recordings[selectedSlot] then return end
        recordings[selectedSlot] = nil
        Rayfield:Notify({
            Title = "Deleted",
            Content = "Slot " .. selectedSlot .. " cleared!",
            Duration = 3
        })
    end
})

-- Playback Speed
MainTab:CreateSlider({
    Name = "Playback Speed",
    Range = {0.5, 3}, -- 0.5x to 3x
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(value)
        playSpeed = value
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
    Title = "Recorder Ready",
    Content = "Record, save & loop movements!",
    Duration = 5,
    Image = "rbxassetid://4483362458"
})
