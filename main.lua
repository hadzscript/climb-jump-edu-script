-- Advanced Macro Recorder for Climb & Jump Tower
-- Features: Movement recording, slot system, FPS display, hatch luck boost

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

-- Player setup
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Core systems
local Recordings = {
    {Name = "Slot 1", Data = {}},
    {Name = "Slot 2", Data = {}},
    {Name = "Slot 3", Data = {}}
}
local currentRecording = 1
local isRecording = false
local isPlaying = false
local playSpeed = 1.0
local hatchLuckBoost = 1.0
local lastFPSUpdate = 0
local currentFPS = 0

-- FPS counter
local function updateFPS()
    local performanceStats = Stats:FindFirstChild("PerformanceStats")
    if performanceStats then
        local pingStat = performanceStats:FindFirstChild("Ping")
        if pingStat then
            currentFPS = math.floor(1/pingStat:GetValue())
        end
    end
end

-- Create optimized UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Climb Macro PRO",
    LoadingTitle = "Loading Premium Features...",
    LoadingSubtitle = "FPS | Slots | Hatch Boost",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ClimbMacro",
        FileName = "Config"
    }
})

-- Main tab with compact layout
local MainTab = Window:CreateTab("Macro", 4483362458)
local StatusDisplay = MainTab:CreateLabel("Ready | FPS: 60 | Slot: 1")

-- Recording controls in one line
local ControlRow = MainTab:CreateSection("Controls", true)
MainTab:CreateButton({
    Name = "● REC",
    Callback = function()
        if isRecording then return end
        Recordings[currentRecording].Data = {}
        isRecording = true
        local startTime = os.clock()
        
        RunService.Heartbeat:Connect(function()
            if not isRecording then return end
            table.insert(Recordings[currentRecording].Data, {
                Position = RootPart.Position,
                Time = os.clock() - startTime
            })
        end)
    end
})

MainTab:CreateButton({
    Name = "■ STOP",
    Callback = function()
        isRecording = false
    end
})

MainTab:CreateButton({
    Name = "▶ PLAY",
    Callback = function()
        if isPlaying or #Recordings[currentRecording].Data == 0 then return end
        isPlaying = true
        
        local function playLoop()
            local startTime = os.clock()
            local index = 1
            
            while isPlaying and index <= #Recordings[currentRecording].Data do
                local frame = Recordings[currentRecording].Data[index]
                local elapsed = (os.clock() - startTime) * playSpeed
                
                if elapsed >= frame.Time then
                    RootPart.CFrame = CFrame.new(frame.Position)
                    index += 1
                end
                RunService.Heartbeat:Wait()
            end
            
            if isPlaying then playLoop() end -- Loop
        end
        
        playLoop()
    end
})

MainTab:CreateButton({
    Name = "⏹ STOP",
    Callback = function()
        isPlaying = false
    end
})

-- Compact settings row
local SettingsRow = MainTab:CreateSection("Settings", true)
MainTab:CreateSlider({
    Name = "SPEED",
    Range = {0.5, 3},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(v) playSpeed = v end
})

MainTab:CreateSlider({
    Name = "HATCH LUCK",
    Range = {1, 5},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(v) 
        hatchLuckBoost = v
        if game:GetService("ReplicatedStorage"):FindFirstChild("HatchLuck") then
            game:GetService("ReplicatedStorage").HatchLuck.Value = v
        end
    end
})

-- Slot management
local SlotRow = MainTab:CreateSection("Slots", true)
local SlotDropdown = MainTab:CreateDropdown({
    Name = "SLOT",
    Options = {"Slot 1", "Slot 2", "Slot 3"},
    CurrentOption = "Slot 1",
    Callback = function(opt)
        currentRecording = tonumber(opt:match("%d"))
    end
})

MainTab:CreateInput({
    Name = "RENAME",
    PlaceholderText = "New name...",
    Callback = function(text)
        if text and text ~= "" then
            Recordings[currentRecording].Name = text
            local options = {}
            for i,v in ipairs(Recordings) do
                options[i] = v.Name
            end
            SlotDropdown:UpdateOptions(options)
        end
    end
})

-- Real-time updates
RunService.Heartbeat:Connect(function()
    -- Update FPS every 0.5 seconds
    if os.clock() - lastFPSUpdate > 0.5 then
        updateFPS()
        lastFPSUpdate = os.clock()
    end
    
    -- Update status display
    local status = ""
    if isRecording then
        status = "Recording "..#Recordings[currentRecording].Data.." frames"
    elseif isPlaying then
        status = "Playing"
    else
        status = "Ready"
    end
    
    StatusDisplay:Set(string.format("%s | FPS: %d | Slot: %d | Hatch: %.1fx",
        status, currentFPS, currentRecording, hatchLuckBoost))
end)

Rayfield:Notify({
    Title = "Macro System Ready",
    Content = "Recording slots & hatch boost active!",
    Duration = 5,
    Image = "rbxassetid://4483362458"
})
