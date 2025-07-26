-- ULTIMATE Climb & Jump Tower Script
-- Fixed detection + Player count + All features

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Player setup
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Game Configuration
local CONFIG = {
    ClimbSpeed = 30,
    JumpPower = 50,
    DetectionRange = 50,
    CheckInterval = 0.2,
    AntiBanDelay = {0.5, 2},
    LadderNames = {"Ladder", "Climb", "MetalLadder"},
    TrophyNames = {"Trophy", "Win", "Finish", "Reward"},
    BadParts = {"Death", "Kill", "Lava"}
}

-- Game State
local currentMap = "Unknown"
local unlockedMaps = {}
local playerCount = 0
local stats = {
    Wins = 0,
    Coins = 0,
    Trophies = 0
}
local isRunning = false
local isClimbing = false

-- Initialize UI
local Window = Rayfield:CreateWindow({
    Name = "Climb & Jump Tower PRO",
    LoadingTitle = "Loading Advanced Features",
    LoadingSubtitle = "Player Tracking | 100% Detection",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ClimbJumpPRO",
        FileName = "ConfigV2"
    }
})

-- Main Tab
local MainTab = Window:CreateTab("Main", 4483362458)
local StatusLabel = MainTab:CreateLabel("Status: Ready")
local StatsLabel = MainTab:CreateLabel("Wins: 0 | Coins: 0 | Players: 0")
local MapLabel = MainTab:CreateLabel("Current Map: Scanning...")

-- Player Counter
local function updatePlayerCount()
    playerCount = #Players:GetPlayers()
    StatsLabel:Set(string.format("Wins: %d | Coins: %d | Players: %d", 
        stats.Wins, stats.Coins, playerCount))
end

-- Enhanced Detection System
local function findClimbable()
    local bestPart, bestScore = nil, 0
    
    -- Check all parts in detection range
    local parts = Workspace:GetPartsInPart(RootPart, CONFIG.DetectionRange)
    
    for _, part in pairs(parts) do
        if not part:IsDescendantOf(Character) then
            -- Check for ladders
            for _, name in pairs(CONFIG.LadderNames) do
                if part.Name:lower():find(name:lower()) then
                    local score = 1 / ((part.Position - RootPart.Position).Magnitude + 0.1)
                    if score > bestScore then
                        bestScore = score
                        bestPart = part
                    end
                end
            end
            
            -- Check for trophies
            for _, name in pairs(CONFIG.TrophyNames) do
                if part.Name:lower():find(name:lower()) then
                    local dist = (part.Position - RootPart.Position).Magnitude
                    if dist < 15 then -- Trophy claim range
                        return part, "trophy"
                    end
                end
            end
            
            -- Avoid dangerous parts
            for _, name in pairs(CONFIG.BadParts) do
                if part.Name:lower():find(name:lower()) then
                    -- Move away from danger
                    local dir = (RootPart.Position - part.Position).Unit
                    RootPart.Velocity = dir * 25
                end
            end
        end
    end
    
    return bestPart, "ladder"
end

-- Smart Climbing System
local function smartClimb()
    if not isRunning then return end
    
    local part, partType = findClimbable()
    
    if partType == "trophy" then
        -- Claim trophy
        firetouchinterest(RootPart, part, 0)
        firetouchinterest(RootPart, part, 1)
        stats.Trophies += 1
        StatusLabel:Set("Status: Claimed Trophy")
        task.wait(math.random(unpack(CONFIG.AntiBanDelay)))
        
    elseif partType == "ladder" and part then
        -- Start climbing
        isClimbing = true
        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        
        -- Perfect alignment
        local ladderCF = part.CFrame
        local look = (ladderCF.Position - RootPart.Position).Unit
        RootPart.CFrame = CFrame.new(RootPart.Position, RootPart.Position + look)
        
        -- Smooth climbing
        local climbDir = Humanoid.MoveDirection.Y > 0 and 1 or -0.5
        RootPart.Velocity = Vector3.new(0, climbDir * CONFIG.ClimbSpeed, 0)
        
        StatusLabel:Set("Status: Climbing")
    else
        -- Not climbing
        if isClimbing then
            isClimbing = false
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

-- Map Detection
local function detectMap()
    -- This should be customized for your game
    local maps = {
        {Name = "Eiffel Tower", Position = Vector3.new(0, 0, 0)},
        {Name = "Burj Khalifa", Position = Vector3.new(100, 0, 100)}
    }
    
    local closestMap, minDist = "Unknown", math.huge
    for _, map in pairs(maps) do
        local dist = (map.Position - RootPart.Position).Magnitude
        if dist < minDist then
            minDist = dist
            closestMap = map.Name
        end
    end
    
    currentMap = closestMap
    MapLabel:Set("Current Map: "..currentMap)
end

-- Main Loop
local function mainLoop()
    while task.wait(CONFIG.CheckInterval) do
        updatePlayerCount()
        detectMap()
        
        if isRunning then
            smartClimb()
        end
    end
end

-- UI Controls
MainTab:CreateToggle({
    Name = "Auto Climb & Trophy",
    CurrentValue = false,
    Callback = function(Value)
        isRunning = Value
        StatusLabel:Set("Status: "..(Value and "Running" or "Stopped"))
    end
})

-- Start system
coroutine.wrap(mainLoop)()
Rayfield:Notify({
    Title = "System Active",
    Content = "All systems operational! Players: "..playerCount,
    Duration = 5,
    Image = "rbxassetid://4483362458"
})
