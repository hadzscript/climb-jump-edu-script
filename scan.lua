-- Persistent Movement Recorder with Discord UI
-- Credits: @hadzscript

_G.Settings = {
    UI = {
        Key = Enum.KeyCode.RightControl,
    }
}

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/SixZensED/Discord-Library/main/Library"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Player Setup
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Persistent Data
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

-- Create UI
local Window = Library:CreateWindow("Movement Recorder", "by @hadzscript")

-- Main Tab
local MainTab = Window:CreateTab("Recorder")
local StatusLabel = MainTab:AddLabel("Status: Idle")

-- Player Count Display
local playerCount = #Players:GetPlayers()
local PlayerLabel = MainTab:AddLabel("Players: "..playerCount)

-- Function to create slot controls
local function CreateSlotControls(slotName)
    local slotFrame = MainTab:AddFolder(slotName)
    
    -- Slot Info
    slotFrame:AddLabel("Frames: "..#recordedSlots[slotName].Movements)
    
    -- Record Button
    slotFrame:AddButton("Record", function()
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
    slotFrame:AddButton("Play", function()
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
    slotFrame:AddButton("Stop", function()
        recordedSlots[slotName].IsPlaying = false
        StatusLabel:Set("Status: Stopped "..slotName)
    end)
    
    -- Delete Button
    slotFrame:AddButton("Delete", function()
        recordedSlots[slotName] = { Movements = {}, IsPlaying = false }
        StatusLabel:Set("Status: Deleted "..slotName)
        SaveData()
        CreateSlotControls(slotName) -- Refresh UI
    end)
end

-- Update Player Count
Players.PlayerAdded:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set("Players: "..playerCount)
end)

Players.PlayerRemoving:Connect(function()
    playerCount = #Players:GetPlayers()
    PlayerLabel:Set("Players: "..playerCount)
end)

-- Auto-save every 30 seconds
task.spawn(function()
    while task.wait(30) do
        SaveData()
    end
end)

-- Initialize
LoadData()
CreateSlotControls("Slot1")
CreateSlotControls("Slot2")
CreateSlotControls("Slot3")

Library:Notify("Movement Recorder", "System initialized successfully!", 5)
