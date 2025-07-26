-- Premium Movement Recorder for Climb & Jump Tower
-- UI: Venux (Better than Rayfield)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Load Venux UI (Better alternative to Rayfield)
local Venux = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Venux/main/venux.lua"))()

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

-- Create Venux UI
local Window = Venux:CreateWindow({
    Title = "Movement Recorder PRO",
    SubTitle = "By @hadzscript",
    ToggleKey = Enum.KeyCode.RightShift,
    LoadCallback = function() end
})

-- Main Tab
local MainTab = Window:AddTab("Recorder", "rbxassetid://4483362458")

-- Status Label
local StatusLabel = MainTab:AddLabel("Status: Idle")

-- Player Count Label
local PlayerLabel = MainTab:AddLabel("Players: " .. playerCount)

-- Slot Selection Dropdown
local SlotDropdown = MainTab:AddDropdown("Select Slot", {"Slot 1", "Slot 2", "Slot 3"}, function(Option)
    currentSlot = tonumber(string.match(Option, "%d+"))
    StatusLabel:Set("Status: Selected " .. Option)
end)

-- Start Recording Button
MainTab:AddButton("Start Recording", function()
    if isRecording then return end
    recordedSlots[currentSlot] = {}
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
end)

-- Stop Recording Button
MainTab:AddButton("Stop Recording", function()
    isRecording = false
    StatusLabel:Set("Status: Saved to Slot " .. currentSlot)
end)

-- Play Recording Button
MainTab:AddButton("Play Recording", function()
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
end)

-- Stop Playback Button
MainTab:AddButton("Stop Playback", function()
    isPlaying = false
    StatusLabel:Set("Status: Stopped")
end)

-- Delete Slot Button
MainTab:AddButton("Delete Slot", function()
    if recordedSlots[currentSlot] then
        recordedSlots[currentSlot] = nil
        StatusLabel:Set("Status: Deleted Slot " .. currentSlot)
    else
        StatusLabel:Set("Status: Slot " .. currentSlot .. " is empty")
    end
end)

-- Update Player Count
Players.PlayerAdded:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set("Players: " .. playerCount)
end)

Players.PlayerRemoving:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set("Players: " .. playerCount)
end)

Venux:Notify("Movement Recorder", "Ready to record & replay!", 5)
