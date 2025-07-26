-- Advanced Movement Recorder with Persistent Slots
-- Credits: @hadzscript
-- UI Library: Luna

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

-- Persistent data storage
local DATA_KEY = "MovementRecorderData"
local recordedSlots = {}
local currentSlot = 1
local isRecording = false
local isPlaying = false
local playerCount = #Players:GetPlayers()

-- Load saved data
local function LoadData()
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(DATA_KEY))
    end)
    if success and type(data) == "table" then
        recordedSlots = data
    else
        recordedSlots = {
            [1] = {},
            [2] = {},
            [3] = {}
        }
    end
end

-- Save data
local function SaveData()
    writefile(DATA_KEY, HttpService:JSONEncode(recordedSlots))
end

-- Initialize data
if not isfile(DATA_KEY) then
    SaveData()
else
    LoadData()
end

-- Create Luna UI
local Window = Luna:CreateWindow({
    Name = "Movement Recorder PRO",
    LoadingTitle = "Loading Recorder...",
    LoadingSubtitle = "By @hadzscript",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MovementRecorder",
        FileName = "Settings"
    }
})

local MainTab = Window:CreateTab("Recorder")
local StatusLabel = MainTab:AddLabel("Status: Idle")
local PlayerLabel = MainTab:AddLabel("Players: " .. playerCount)

-- Slot Management Tab
local SlotsTab = Window:CreateTab("Slots")

-- Create slot frames
local slotFrames = {}
local playButtons = {}
local deleteButtons = {}

for i = 1, 3 do
    local slotFrame = SlotsTab:AddFolder("Slot " .. i)
    slotFrames[i] = slotFrame
    
    -- Play button for each slot
    playButtons[i] = slotFrame:AddButton({
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
                
                if isPlaying then -- Loop if still active
                    playMovement()
                end
            end
            
            playMovement()
        end
    })
    
    -- Delete button for each slot
    deleteButtons[i] = slotFrame:AddButton({
        Text = "Delete Slot " .. i,
        Callback = function()
            recordedSlots[i] = {}
            SaveData()
            StatusLabel:Set("Status: Deleted Slot " .. i)
        end
    })
end

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
                SaveData() -- Save when recording stops
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

-- Slot selection dropdown
MainTab:AddDropdown({
    Text = "Select Slot",
    List = {"Slot 1", "Slot 2", "Slot 3"},
    Callback = function(option)
        currentSlot = tonumber(string.match(option, "%d+"))
        StatusLabel:Set("Status: Selected " .. option)
    end
})

-- Player count updater
Players.PlayerAdded:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set("Players: " .. playerCount)
end)

Players.PlayerRemoving:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set("Players: " .. playerCount)
end)

-- Auto-save on game close
game:BindToClose(function()
    if isfile(DATA_KEY) then
        SaveData()
    end
end)

Luna:Notify({
    Title = "Movement Recorder Ready",
    Content = "Recordings persist between games!",
    Duration = 5
})
