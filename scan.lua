-- Advanced Movement Recorder
-- Uses Luna UI with persistent slot system
-- Credits: @hadzscript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Load Luna UI
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- Player setup
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Data persistence
local DATA_KEY = "ClimbRecorderData"
local recordedSlots = {
    Slot1 = {Movements = {}, Name = "Slot 1"},
    Slot2 = {Movements = {}, Name = "Slot 2"}, 
    Slot3 = {Movements = {}, Name = "Slot 3"}
}

-- Load saved data
local function LoadData()
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(DATA_KEY))
    end)
    if success and data then
        for slotName, slotData in pairs(data) do
            if recordedSlots[slotName] then
                recordedSlots[slotName] = slotData
            end
        end
    end
end

-- Save data
local function SaveData()
    pcall(function()
        writefile(DATA_KEY, HttpService:JSONEncode(recordedSlots))
    end)
end

LoadData() -- Initialize data

-- Game state
local isRecording = false
local isPlaying = false
local currentRecordingSlot = nil

-- Player count tracking
local playerCount = #Players:GetPlayers()

-- Create Luna UI Window
local Window = Luna:CreateWindow({
    Name = "Movement Recorder",
    LoadingTitle = "Loading Recorder...",
    LoadingSubtitle = "Persistent Slot System",
    ConfigFolder = "ClimbRecorderSettings"
})

-- Main tab
local MainTab = Window:CreateTab({
    Name = "Recorder",
    Icon = "activity",
    ImageSource = "Lucide"
})

-- Status display
local StatusLabel = MainTab:CreateLabel({
    Text = "Status: Ready",
    Style = 1
})

local PlayerLabel = MainTab:CreateLabel({
    Text = "Players: " .. playerCount,
    Style = 1
})

-- Recording controls section
MainTab:CreateSection("Recording Controls")

local SlotDropdown = MainTab:CreateDropdown({
    Name = "Recording Slot",
    Options = {"Slot 1", "Slot 2", "Slot 3"},
    CurrentOption = "Slot 1",
    Callback = function(option)
        currentRecordingSlot = option
    end
})

MainTab:CreateButton({
    Name = "Start Recording",
    Callback = function()
        if isRecording then return end
        if not currentRecordingSlot then return end
        
        local slotKey = "Slot" .. string.match(currentRecordingSlot, "%d+")
        recordedSlots[slotKey].Movements = {}
        isRecording = true
        StatusLabel:Set({Text = "Status: Recording " .. currentRecordingSlot})
        
        local startTime = os.clock()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not isRecording then
                connection:Disconnect()
                SaveData()
                return
            end
            
            table.insert(recordedSlots[slotKey].Movements, {
                Position = RootPart.Position,
                Timestamp = os.clock() - startTime
            })
        end)
    end
})

MainTab:CreateButton({
    Name = "Stop Recording",
    Callback = function()
        isRecording = false
        StatusLabel:Set({Text = "Status: Saved to " .. currentRecordingSlot})
    end
})

-- Playback sections for each slot
for i = 1, 3 do
    local slotKey = "Slot" .. i
    local section = MainTab:CreateSection(slotKey)
    
    -- Play button
    section:CreateButton({
        Name = "Play",
        Callback = function()
            if isPlaying or #recordedSlots[slotKey].Movements == 0 then return end
            
            isPlaying = true
            StatusLabel:Set({Text = "Status: Playing " .. recordedSlots[slotKey].Name})
            
            local function playMovement()
                local startTime = os.clock()
                local index = 1
                
                while isPlaying and index <= #recordedSlots[slotKey].Movements do
                    local movement = recordedSlots[slotKey].Movements[index]
                    local currentTime = os.clock() - startTime
                    
                    if currentTime >= movement.Timestamp then
                        RootPart.CFrame = CFrame.new(movement.Position)
                        index += 1
                    end
                    
                    RunService.Heartbeat:Wait()
                end
                
                if isPlaying then
                    playMovement() -- Loop
                end
            end
            
            playMovement()
        end
    })
    
    -- Delete button
    section:CreateButton({
        Name = "Delete",
        Callback = function()
            recordedSlots[slotKey].Movements = {}
            SaveData()
            StatusLabel:Set({Text = "Status: Deleted " .. recordedSlots[slotKey].Name})
        end
    })
    
    -- Info label
    section:CreateLabel({
        Text = "Frames: " .. #recordedSlots[slotKey].Movements,
        Style = 1
    })
end

-- Global stop button
MainTab:CreateButton({
    Name = "STOP ALL PLAYBACK",
    Callback = function()
        isPlaying = false
        StatusLabel:Set({Text = "Status: Stopped all playback"})
    end
})

-- Player count updates
Players.PlayerAdded:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set({Text = "Players: " .. playerCount})
end)

Players.PlayerRemoving:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set({Text = "Players: " .. playerCount})
end)

-- Notification
Luna:Notification({
    Title = "Movement Recorder Ready",
    Content = "Recordings persist through rejoins!",
    Icon = "check-circle",
    ImageSource = "Lucide"
})

-- Load configurations
Luna:LoadAutoloadConfig()
