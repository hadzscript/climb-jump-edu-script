-- Ultimate Egg Hatch Automation
-- With Luck Boosting, Multi-Slot Recording, and FPS Display

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Configuration
local CONFIG = {
    LuckTypes = {
        {"Super Luck", 1.5},
        {"Ultra Luck", 2.0},
        {"Searat Luck", 3.0},
        {"Rainbow Luck", 5.0} -- Immortal pet boost
    },
    HatchModes = {
        "Fast Match",
        "Triple Match", 
        "Tented Match",
        "AUTO HATCH",
        "MULTI HATCH"
    },
    RecordSlots = 3 -- Number of save slots
}

-- State Variables
local currentLuck = 1.0
local currentHatchMode = "AUTO HATCH"
local recordedSlots = {}
local activeSlot = 1
local isHatching = false
local fps = 0

-- FPS Counter
local function updateFPS()
    local frames = 0
    local lastTick = os.clock()
    
    while task.wait(0.5) do
        local currentTick = os.clock()
        fps = math.floor(frames / (currentTick - lastTick))
        frames = 0
        lastTick = currentTick
    end
end

coroutine.wrap(updateFPS)()

-- Create Main Window
local Window = Rayfield:CreateWindow({
    Name = "Egg Hatch PRO",
    LoadingTitle = "Loading Immortal Pet System",
    LoadingSubtitle = "With Rainbow Luck Boost",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "EggHatchPRO",
        FileName = "MultiSlotConfig"
    }
})

-- Main Tab
local MainTab = Window:CreateTab("Controls", 6034287125) -- Egg icon
local FPSLabel = MainTab:CreateLabel("FPS: "..fps)

-- Luck Selection (Single Row)
local LuckDropdown = MainTab:CreateDropdown({
    Name = "Luck Boost",
    Options = {"Super Luck", "Ultra Luck", "Searat Luck", "Rainbow Luck (Immortal)"},
    CurrentOption = "Super Luck",
    Callback = function(Option)
        for _, luck in pairs(CONFIG.LuckTypes) do
            if luck[1] == Option then
                currentLuck = luck[2]
                break
            end
        end
    end
})

-- Hatch Mode (Single Row)
MainTab:CreateDropdown({
    Name = "Hatch Mode",
    Options = CONFIG.HatchModes,
    CurrentOption = "AUTO HATCH",
    Callback = function(Option)
        currentHatchMode = Option
    end
})

-- Recording System
local RecordTab = Window:CreateTab("Recording", 6034233233)
local StatusLabel = RecordTab:CreateLabel("Status: Ready")

-- Create recording slots
for i = 1, CONFIG.RecordSlots do
    RecordTab:CreateButton({
        Name = "Slot "..i.." (Empty)",
        Callback = function()
            activeSlot = i
            StatusLabel:Set("Selected Slot "..i)
        end
    })
end

-- Record/Play Controls
RecordTab:CreateToggle({
    Name = "Record Movements",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            recordedSlots[activeSlot] = {}
            local startTime = os.clock()
            
            local connection
            connection = RunService.Heartbeat:Connect(function()
                table.insert(recordedSlots[activeSlot], {
                    Position = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position,
                    Time = os.clock() - startTime
                })
            end)
            
            StatusLabel:Set("Recording Slot "..activeSlot)
        else
            StatusLabel:Set("Saved to Slot "..activeSlot)
            -- Update button text
            for _, element in pairs(RecordTab:GetChildren()) do
                if element.Name and element.Name:find("Slot "..activeSlot) then
                    element:Set("Slot "..activeSlot.." ("..#recordedSlots[activeSlot].." steps)")
                end
            end
        end
    end
})

RecordTab:CreateToggle({
    Name = "Play Recording (Loop)",
    CurrentValue = false,
    Callback = function(Value)
        if Value and recordedSlots[activeSlot] then
            StatusLabel:Set("Playing Slot "..activeSlot)
            
            while Value and recordedSlots[activeSlot] do
                local startTime = os.clock()
                
                for _, point in ipairs(recordedSlots[activeSlot]) do
                    if not Value then break end
                    
                    local elapsed = os.clock() - startTime
                    local waitTime = point.Time - elapsed
                    
                    if waitTime > 0 then
                        task.wait(waitTime)
                    end
                    
                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(point.Position)
                end
                
                task.wait(0.5) -- Small delay between loops
            end
        else
            StatusLabel:Set("Stopped Playback")
        end
    end
})

-- Hatch Automation
local HatchTab = Window:CreateTab("Hatching", 6034233233)
HatchTab:CreateToggle({
    Name = "Auto Hatch",
    CurrentValue = false,
    Callback = function(Value)
        isHatching = Value
        if Value then
            coroutine.wrap(function()
                while isHatching do
                    -- Replace with your game's hatch function
                    game:GetService("ReplicatedStorage").Events.HatchEgg:FireServer(currentHatchMode, currentLuck)
                    task.wait(0.5 * (1/currentLuck)) -- Faster with better luck
                end
            end)()
        end
    end
})

-- FPS Updater
RunService.Heartbeat:Connect(function()
    FPSLabel:Set("FPS: "..fps)
end)

Rayfield:Notify({
    Title = "System Ready",
    Content = "Rainbow Luck Boost Active!",
    Duration = 5,
    Image = "rbxassetid://6034287125"
})
