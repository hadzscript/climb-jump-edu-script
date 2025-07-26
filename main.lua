-- Advanced Movement Recorder & Looper
-- For Climb & Jump Tower

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
local recordedMovements = {}
local isRecording = false
local isPlaying = false
local playSpeed = 1 -- 1x speed by default

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

-- Start/Stop Recording
MainTab:CreateButton({
    Name = "Start Recording",
    Callback = function()
        if isRecording then return end
        recordedMovements = {} -- Clear old recording
        isRecording = true
        StatusLabel:Set("Status: Recording...")
        
        -- Record movements every frame
        local startTime = os.clock()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not isRecording then
                connection:Disconnect()
                return
            end
            table.insert(recordedMovements, {
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
        StatusLabel:Set("Status: Recorded (" .. #recordedMovements .. " frames)")
    end
})

-- Playback Controls
MainTab:CreateButton({
    Name = "Play Recording (Loop)",
    Callback = function()
        if #recordedMovements == 0 then
            StatusLabel:Set("Status: No recording!")
            return
        end
        
        if isPlaying then return end
        isPlaying = true
        StatusLabel:Set("Status: Playing (Looping)")
        
        local function playMovement()
            local startTime = os.clock()
            local index = 1
            
            while isPlaying and index <= #recordedMovements do
                local movement = recordedMovements[index]
                local currentTime = (os.clock() - startTime) * playSpeed
                
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

MainTab:CreateButton({
    Name = "Stop Playback",
    Callback = function()
        isPlaying = false
        StatusLabel:Set("Status: Stopped")
    end
})

-- Playback Speed Adjustment
MainTab:CreateSlider({
    Name = "Playback Speed",
    Range = {0.5, 3}, -- 0.5x to 3x speed
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
    Title = "Movement Recorder Ready",
    Content = "Record & loop your climbs!",
    Duration = 5,
    Image = "rbxassetid://4483362458"
})
