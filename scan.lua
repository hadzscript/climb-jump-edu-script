-- Advanced Movement Recorder for Climb & Jump Tower
-- Credits: @hadzscript
-- Uses Orion UI with persistent data saving

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Load Orion UI
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- Persistent Data Setup
local DATA_KEY = "MovementRecorderData"
local recordedSlots = {
    Slot1 = {Movements = {}, IsPlaying = false},
    Slot2 = {Movements = {}, IsPlaying = false},
    Slot3 = {Movements = {}, IsPlaying = false}
}

-- Load saved data
local function LoadData()
    local saved = OrionLib:GetSetting(DATA_KEY)
    if saved then
        recordedSlots = HttpService:JSONDecode(saved)
    end
end

-- Save data
local function SaveData()
    OrionLib:SetSetting(DATA_KEY, HttpService:JSONEncode(recordedSlots))
end

LoadData()

-- Player Count
local playerCount = #Players:GetPlayers()

-- Create UI
local Window = OrionLib:MakeWindow({
    Name = "Movement Recorder PRO",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MovementRecorder"
})

-- Status Tracking
local StatusLabel = Window:MakeLabel({
    Name = "Status: Idle",
    TextXAlignment = Enum.TextXAlignment.Left
})

local PlayerLabel = Window:MakeLabel({
    Name = "Players: "..playerCount,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Recording Controls
local RecordingTab = Window:MakeTab({
    Name = "Recording",
    Icon = "rbxassetid://4483362458"
})

RecordingTab:AddButton({
    Name = "Start Recording",
    Callback = function()
        if not OrionLib:GetInput("SelectedSlot") then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Please select a slot first!",
                Image = "rbxassetid://7733658504",
                Time = 3
            })
            return
        end

        local slot = "Slot"..OrionLib:GetInput("SelectedSlot")
        recordedSlots[slot].Movements = {}
        
        OrionLib:MakeNotification({
            Name = "Recording Started",
            Content = "Recording to "..slot,
            Image = "rbxassetid://7733658504",
            Time = 2
        })
        StatusLabel:Set("Status: Recording to "..slot)

        local startTime = os.clock()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            table.insert(recordedSlots[slot].Movements, {
                Position = RootPart.Position,
                Timestamp = os.clock() - startTime
            })
            
            if not OrionLib:GetInput("IsRecording") then
                connection:Disconnect()
                SaveData()
                StatusLabel:Set("Status: Saved to "..slot)
            end
        end)
    end
})

RecordingTab:AddToggle({
    Name = "Is Recording",
    Default = false,
    Callback = function(value)
        OrionLib:SetInput("IsRecording", value)
        if not value then
            OrionLib:MakeNotification({
                Name = "Recording Stopped",
                Content = "Movement data saved",
                Image = "rbxassetid://7733658504",
                Time = 2
            })
        end
    end
})

RecordingTab:AddDropdown({
    Name = "Select Slot",
    Default = "1",
    Options = {"1", "2", "3"},
    Callback = function(value)
        OrionLib:SetInput("SelectedSlot", value)
    end
})

-- Slot Management Tab
local SlotsTab = Window:MakeTab({
    Name = "Slots",
    Icon = "rbxassetid://7733960981"
})

for i = 1, 3 do
    local slotName = "Slot"..i
    
    SlotsTab:AddLabel({
        Name = "Slot "..i.." Controls"
    })
    
    SlotsTab:AddButton({
        Name = "Play Slot "..i,
        Callback = function()
            if #recordedSlots[slotName].Movements == 0 then
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Slot "..i.." is empty!",
                    Image = "rbxassetid://7733658504",
                    Time = 3
                })
                return
            end
            
            recordedSlots[slotName].IsPlaying = true
            StatusLabel:Set("Status: Playing Slot "..i)
            
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
        end
    })
    
    SlotsTab:AddButton({
        Name = "Stop Slot "..i,
        Callback = function()
            recordedSlots[slotName].IsPlaying = false
            StatusLabel:Set("Status: Stopped Slot "..i)
        end
    })
    
    SlotsTab:AddButton({
        Name = "Delete Slot "..i,
        Callback = function()
            recordedSlots[slotName].Movements = {}
            SaveData()
            OrionLib:MakeNotification({
                Name = "Success",
                Content = "Deleted Slot "..i,
                Image = "rbxassetid://7733658504",
                Time = 2
            })
        end
    })
end

-- Player Count Updater
Players.PlayerAdded:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set("Players: "..playerCount)
end)

Players.PlayerRemoving:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set("Players: "..playerCount)
end)

OrionLib:Init()
OrionLib:MakeNotification({
    Name = "System Ready",
    Content = "Movement Recorder loaded!",
    Image = "rbxassetid://7733658504",
    Time = 5
})
