-- Climb & Jump Tower Autoplayer
-- Supports all landmarks: Eiffel Tower, Burj Khalifa, Himalayas, etc.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Landmark progression system
local LANDMARKS = {
    {Name = "Eiffel Tower", RequiredWins = 0},
    {Name = "Statue of Liberty", RequiredWins = 10},
    {Name = "Leaning Tower of Pisa", RequiredWins = 17500},
    {Name = "Pyramids", RequiredWins = 50000},
    {Name = "Burj Khalifa", RequiredWins = 80000},
    {Name = "Empire State Building", RequiredWins = 100000},
    {Name = "World Trade Center", RequiredWins = 400000},
    {Name = "Big Ben", RequiredWins = 1000000},
    {Name = "Oriental Pearl Tower", RequiredWins = 2000000},
    {Name = "Tokyo Tower", RequiredWins = 2000000},
    {Name = "Petronas Towers", RequiredWins = 10000000},
    {Name = "Himalayas", RequiredWins = 50000000}
}

-- Configuration
local CONFIG = {
    ClimbSpeed = 30,
    JumpPower = 50,
    WinCheckInterval = 1,
    AntiBanDelay = math.random(2, 5)
}

-- State variables
local currentWins = 0
local currentLandmark = nil
local isClimbing = false
local isRunning = false

-- UI Library (using Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Climb & Jump Tower",
    LoadingTitle = "Loading Autoplayer...",
    LoadingSubtitle = "By YourName",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ClimbAndJump",
        FileName = "Config"
    }
})

-- Main Tab
local MainTab = Window:CreateTab("Main")
local StatusLabel = MainTab:CreateLabel("Status: Ready")
local WinsLabel = MainTab:CreateLabel("Wins: 0")
local LandmarkLabel = MainTab:CreateLabel("Current Landmark: None")

-- Auto Climb Toggle
MainTab:CreateToggle({
    Name = "Auto Climb",
    CurrentValue = false,
    Callback = function(Value)
        isRunning = Value
        StatusLabel:Set("Status: " .. (Value and "Running" or "Stopped"))
    end
})

-- Landmark Progression Display
local LandmarkDropdown = MainTab:CreateDropdown({
    Name = "Landmarks",
    Options = {"Loading..."},
    CurrentOption = "None",
    Callback = function(Option)
        -- Optional: Add manual landmark selection logic
    end
})

-- Update landmark dropdown
local function updateLandmarks()
    local options = {}
    for _, landmark in pairs(LANDMARKS) do
        local status = currentWins >= landmark.RequiredWins and "🟢" or "🔴"
        table.insert(options, string.format("%s %s (%d Wins)", status, landmark.Name, landmark.RequiredWins))
    end
    LandmarkDropdown:UpdateOptions(options)
end

-- Core climbing function
local function autoClimb()
    if not isRunning then return end
    
    -- Find the highest available landmark
    local targetLandmark = nil
    for i = #LANDMARKS, 1, -1 do
        if currentWins >= LANDMARKS[i].RequiredWins then
            targetLandmark = LANDMARKS[i]
            break
        end
    end
    
    -- Update current landmark
    if targetLandmark and (not currentLandmark or targetLandmark.Name ~= currentLandmark.Name) then
        currentLandmark = targetLandmark
        LandmarkLabel:Set("Current Landmark: " .. currentLandmark.Name)
        StatusLabel:Set("Status: Climbing " .. currentLandmark.Name)
    end
    
    -- Climbing logic
    isClimbing = true
    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    RootPart.Velocity = Vector3.new(0, CONFIG.ClimbSpeed, 0)
    
    -- Simulate climb time based on landmark height
    local climbTime = math.random(8, 15) -- Varies per landmark
    task.wait(climbTime)
    
    -- Win detection (replace with your game's actual win detection)
    currentWins = currentWins + 1
    WinsLabel:Set("Wins: " .. currentWins)
    
    -- Jump off and reset
    RootPart.Velocity = Vector3.new(0, CONFIG.JumpPower, -CONFIG.JumpPower)
    task.wait(2)
    isClimbing = false
    
    -- Anti-ban delay
    task.wait(CONFIG.AntiBanDelay)
    
    -- Repeat if still running
    if isRunning then
        autoClimb()
    end
end

-- Win tracking (replace with your game's actual win detection)
local function trackWins()
    while task.wait(CONFIG.WinCheckInterval) do
        -- This should be replaced with your game's win detection method
        -- Example: Check leaderstats or game events
    end
end

-- Initialize
updateLandmarks()
coroutine.wrap(trackWins)()
coroutine.wrap(autoClimb)()

Rayfield:Notify({
    Title = "Climb & Jump Tower",
    Content = "Script loaded successfully!",
    Duration = 3,
    Image = "rbxassetid://4483345998"
})
