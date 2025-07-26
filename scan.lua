-- Fully Fixed Movement Recorder with Luna UI
-- Credits: @hadzscript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")

-- Load Luna UI
local success, Luna = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()
end)

if not success then
    warn("Failed to load Luna UI")
    return
end

-- Player setup
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Persistent data storage
local DATA_KEY = "MovementRecorderData"
local recordedSlots = {
    [1] = {},
    [2] = {},
    [3] = {}
}
local currentSlot = 1
local isRecording = false
local isPlaying = false
local playerCount = #Players:GetPlayers()

-- Load saved data
local function LoadData()
    if not isfile(DATA_KEY) then return end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(DATA_KEY))
    end)
    
    if success and type(data) == "table" then
        for i = 1, 3 do
            if data[i] then
                recordedSlots[i] = data[i]
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

-- Initialize data
LoadData()

-- Create Luna UI
local Window = Luna:CreateWindow({
    Name = "Movement Recorder PRO",
    LoadingTitle = "Loading Recorder...",
    LoadingSubtitle = "By @hadzscript",
    ConfigFolder = "MovementRecorderSettings"
})

-- Main Tab
local MainTab = Window:AddTab("Recorder")
local StatusLabel = MainTab:AddLabel("Status: Idle")
local PlayerLabel = MainTab:AddLabel("Players: " .. playerCount)

-- Recording Controls
MainTab:AddButton({
    Text = "Start Recording",
    Callback = function()
        if isRecording then return end
        recordedSlots[currentSlot] = {}
        isRecording = true
        StatusLabel:Set("Status: Recording Slot " .. currentSlot)
        
        local startTime = os.clock()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not isRecording then
                connection:Disconnect()
                SaveData()
                return
            end
            table.insert(recordedSlots[currentSlot], {
                Position = RootPart.Position,
                Timestamp = os.clock() - startTime
            })
        end)
    end
})

MainTab:AddButton({
    Text = "Stop Recording",
    Callback = function()
        isRecording = false
        StatusLabel:Set("Status: Saved to Slot " .. currentSlot)
        SaveData()
    end
})

MainTab:AddButton({
    Text = "Stop Playback",
    Callback = function()
        isPlaying = false
        StatusLabel:Set("Status: Stopped")
    end
})

-- Slot Selection
MainTab:AddDropdown({
    Text = "Select Slot",
    List = {"Slot 1", "Slot 2", "Slot 3"},
    Callback = function(option)
        currentSlot = tonumber(string.match(option, "%d+"))
        StatusLabel:Set("Status: Selected " .. option)
    end
})

-- Slots Tab
local SlotsTab = Window:AddTab("Slot Management")

-- Create slot controls
for i = 1, 3 do
    local slotFolder = SlotsTab:AddFolder("Slot " .. i)
    
    slotFolder:AddButton({
        Text = "Play Slot " .. i,
        Callback = function()
            if isPlaying then return end
            if not recordedSlots[i] or #recordedSlots[i] == 0 then
                StatusLabel:Set("Status: No recording in Slot " .. i)
                return
            end
            
            isPlaying = true
            StatusLabel:Set("Status: Playing Slot " .. i)
            
            local function playMovement()
                local startTime = os.clock()
                local index = 1
                
                while isPlaying and index <= #recordedSlots[i] do
                    local movement = recordedSlots[i][index]
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
    
    slotFolder:AddButton({
        Text = "Delete Slot " .. i,
        Callback = function()
            recordedSlots[i] = {}
            SaveData()
            StatusLabel:Set("Status: Deleted Slot " .. i)
        end
    })
    
    slotFolder:AddLabel("Frames: " .. (#recordedSlots[i] or 0))
end

-- Player count updater
local function updatePlayerCount()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set("Players: " .. playerCount)
end

Players.PlayerAdded:Connect(updatePlayerCount)
Players.PlayerRemoving:Connect(updatePlayerCount)

-- Auto-save
game:BindToClose(SaveData)

-- Initial update
updatePlayerCount()

-- Display notification
Luna:Notify({
    Title = "System Ready",
    Content = "Recordings will persist between games!",
    Duration = 5
})
