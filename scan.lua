-- Advanced Movement Recorder for Climb & Jump Tower
-- UI by Orion | Credits: @hadzscript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- Load Orion UI
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- Player setup
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Movement Recording
local recordedSlots = {
    [1] = nil,
    [2] = nil,
    [3] = nil
}
local currentSlot = 1
local isRecording = false
local isPlaying = false

-- Player Count
local playerCount = #Players:GetPlayers()

-- Create Orion UI Window
local Window = OrionLib:MakeWindow({
    Name = "Movement Recorder PRO",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MovementRecorderConfig"
})

-- Main Tab
local MainTab = Window:MakeTab({
    Name = "Recorder",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

-- Status Labels
MainTab:AddLabel("Status: Idle")
local statusLabel = MainTab:AddLabel("Slot: 1 | Players: "..playerCount)

-- Slot Selection Dropdown
MainTab:AddDropdown({
    Name = "Select Slot",
    Default = "Slot 1",
    Options = {"Slot 1", "Slot 2", "Slot 3"},
    Callback = function(Value)
        currentSlot = tonumber(string.match(Value, "%d+"))
        statusLabel:Set("Slot: "..currentSlot.." | Players: "..playerCount)
    end    
})

-- Start Recording Button
MainTab:AddButton({
    Name = "Start Recording",
    Callback = function()
        if isRecording then return end
        recordedSlots[currentSlot] = {}
        isRecording = true
        statusLabel:Set("Recording Slot "..currentSlot.." | Players: "..playerCount)
        
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

-- Stop Recording Button
MainTab:AddButton({
    Name = "Stop Recording",
    Callback = function()
        isRecording = false
        statusLabel:Set("Saved to Slot "..currentSlot.." | Players: "..playerCount)
    end
})

-- Play Recording Button
MainTab:AddButton({
    Name = "Play Recording (Loop)",
    Callback = function()
        if not recordedSlots[currentSlot] or #recordedSlots[currentSlot] == 0 then
            statusLabel:Set("No recording in Slot "..currentSlot)
            return
        end
        
        if isPlaying then return end
        isPlaying = true
        statusLabel:Set("Playing Slot "..currentSlot.." | Players: "..playerCount)
        
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
            
            if isPlaying then -- Loop
                playMovement()
            end
        end
        
        playMovement()
    end
})

-- Stop Playback Button
MainTab:AddButton({
    Name = "Stop Playback",
    Callback = function()
        isPlaying = false
        statusLabel:Set("Stopped | Players: "..playerCount)
    end
})

-- Delete Slot Button
MainTab:AddButton({
    Name = "Delete Current Slot",
    Callback = function()
        if recordedSlots[currentSlot] then
            recordedSlots[currentSlot] = nil
            statusLabel:Set("Deleted Slot "..currentSlot.." | Players: "..playerCount)
        else
            statusLabel:Set("Slot "..currentSlot.." empty | Players: "..playerCount)
        end
    end
})

-- Update Player Count
Players.PlayerAdded:Connect(function()
    playerCount = #Players:GetPlayers()
    statusLabel:Set("Slot: "..currentSlot.." | Players: "..playerCount)
end)

Players.PlayerRemoving:Connect(function()
    playerCount = #Players:GetPlayers()
    statusLabel:Set("Slot: "..currentSlot.." | Players: "..playerCount)
end)

-- Init UI
OrionLib:Init()
OrionLib:MakeNotification({
    Name = "System Ready",
    Content = "Movement Recorder loaded!",
    Image = "rbxassetid://4483362458",
    Time = 5
})
