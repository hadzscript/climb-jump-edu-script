-- Movement Recorder PRO
-- By @hadzscript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Settings
local recordings = {
    [1] = nil, -- Slot 1
    [2] = nil, -- Slot 2
    [3] = nil  -- Slot 3
}
local currentRecording = {}
local isRecording = false
local isPlaying = false
local playSpeed = 1
local selectedSlot = 1
local playerCount = #Players:GetPlayers()

-- Create UI
local Window = Rayfield:CreateWindow({
    Name = "Movement Recorder PRO",
    LoadingTitle = "By @hadzscript",
    LoadingSubtitle = "Loading...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MovementRecorder",
        FileName = "Config"
    }
})

-- Main Tab
local MainTab = Window:CreateTab("Main", 4483362458)
local StatusLabel = MainTab:CreateLabel("Status: Idle")
local PlayerLabel = MainTab:CreateLabel("Players: "..playerCount)

-- Recording Section
local RecordSection = MainTab:CreateSection("Recording")
RecordSection:CreateToggle({
    Name = "⏺ Record",
    CurrentValue = false,
    Callback = function(Value)
        isRecording = Value
        if Value then
            currentRecording = {}
            StatusLabel:Set("Status: Recording...")
            local startTime = os.clock()
            local conn
            conn = RunService.Heartbeat:Connect(function()
                if not isRecording then conn:Disconnect() return end
                table.insert(currentRecording, {
                    Position = RootPart.Position,
                    Timestamp = os.clock() - startTime
                })
            end)
        else
            StatusLabel:Set("Status: Recorded ("..#currentRecording.." frames)")
        end
    end
})

RecordSection:CreateButton({
    Name = "💾 Save to Slot "..selectedSlot,
    Callback = function()
        if #currentRecording == 0 then
            Rayfield:Notify({Title="Error", Content="No recording to save!", Duration=3})
            return
        end
        recordings[selectedSlot] = currentRecording
        Rayfield:Notify({Title="Saved", Content="Saved to Slot "..selectedSlot, Duration=3})
    end
})

-- Slot Management
local SlotSection = MainTab:CreateSection("Slots")
for i = 1, 3 do
    SlotSection:CreateButton({
        Name = "Slot "..i..(recordings[i] and " ✅" or " ❌"),
        Callback = function()
            selectedSlot = i
            StatusLabel:Set("Selected Slot "..i)
        end
    })
end

SlotSection:CreateButton({
    Name = "🗑 Delete Slot "..selectedSlot,
    Callback = function()
        recordings[selectedSlot] = nil
        Rayfield:Notify({Title="Deleted", Content="Slot "..selectedSlot.." cleared", Duration=3})
    end
})

-- Playback Section
local PlaySection = MainTab:CreateSection("Playback")
PlaySection:CreateToggle({
    Name = "▶ Play Loop",
    CurrentValue = false,
    Callback = function(Value)
        isPlaying = Value
        if Value then
            if not recordings[selectedSlot] then
                Rayfield:Notify({Title="Error", Content="Slot "..selectedSlot.." is empty!", Duration=3})
                isPlaying = false
                return
            end
            StatusLabel:Set("Playing Slot "..selectedSlot)
            local function play()
                local startTime = os.clock()
                local index = 1
                local recording = recordings[selectedSlot]
                while isPlaying and index <= #recording do
                    local move = recording[index]
                    if (os.clock()-startTime)*playSpeed >= move.Timestamp then
                        RootPart.CFrame = CFrame.new(move.Position)
                        index += 1
                    end
                    task.wait()
                end
                if isPlaying then play() end -- Loop
            end
            play()
        else
            StatusLabel:Set("Stopped")
        end
    end
})

PlaySection:CreateSlider({
    Name = "Playback Speed",
    Range = {0.5, 3},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(Value)
        playSpeed = Value
    end
})

-- Player Counter
Players.PlayerAdded:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set("Players: "..playerCount)
end)

Players.PlayerRemoving:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set("Players: "..playerCount)
end)

Rayfield:Notify({
    Title = "Ready",
    Content = "Movement Recorder by @hadzscript",
    Duration = 5,
    Image = "rbxassetid://4483362458"
})
