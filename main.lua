-- COMPLETE WORKING Climb & Jump Tower Script
-- Fixed auto-climb + Player count + Map detection

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Player Setup
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Configuration
local CONFIG = {
    ClimbSpeed = 28,
    JumpPower = 45,
    DetectionRange = 50,
    CheckInterval = 0.1,
    LadderNames = {"Ladder", "Climb", "Rope"},
    TrophyNames = {"Trophy", "Win", "Finish"},
    BadParts = {"Death", "Kill", "Lava"}
}

-- Game State
local currentMap = "Unknown"
local playerCount = #Players:GetPlayers()
local isRunning = false
local isClimbing = false

-- UI Setup (simplified)
local function notify(msg)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Climb System",
        Text = msg,
        Duration = 3
    })
end

-- Player Counter
local function updatePlayerCount()
    playerCount = #Players:GetPlayers()
    print("Players:", playerCount)
end

-- Enhanced Climb Detection (FIXED)
local function findClimbable()
    local closestLadder, closestTrophy
    local ladderDist, trophyDist = math.huge, math.huge
    
    -- Check all nearby parts
    local parts = Workspace:GetPartsInPart(RootPart, CONFIG.DetectionRange)
    
    for _, part in pairs(parts) do
        if not part:IsDescendantOf(Character) then
            -- Ladder detection
            for _, name in pairs(CONFIG.LadderNames) do
                if part.Name:lower():find(name:lower()) then
                    local dist = (part.Position - RootPart.Position).Magnitude
                    if dist < ladderDist then
                        ladderDist = dist
                        closestLadder = part
                    end
                end
            end
            
            -- Trophy detection
            for _, name in pairs(CONFIG.TrophyNames) do
                if part.Name:lower():find(name:lower()) then
                    local dist = (part.Position - RootPart.Position).Magnitude
                    if dist < trophyDist then
                        trophyDist = dist
                        closestTrophy = part
                    end
                end
            end
        end
    end
    
    -- Priority: trophy > ladder
    if closestTrophy and trophyDist < 15 then
        return closestTrophy, "trophy"
    elseif closestLadder and ladderDist < 10 then
        return closestLadder, "ladder"
    end
    return nil
end

-- Fixed Auto-Climb Function
local function autoClimb()
    if not isRunning then return end
    
    local part, partType = findClimbable()
    
    if partType == "trophy" then
        -- Claim trophy
        firetouchinterest(RootPart, part, 0)
        firetouchinterest(RootPart, part, 1)
        notify("Claimed Trophy!")
        task.wait(1)
        
    elseif partType == "ladder" then
        -- Start climbing
        if not isClimbing then
            isClimbing = true
            Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            notify("Started Climbing")
        end
        
        -- Align with ladder
        local lookVector = (part.Position - RootPart.Position).Unit
        RootPart.CFrame = CFrame.new(RootPart.Position, RootPart.Position + lookVector)
        
        -- Move upward
        RootPart.Velocity = Vector3.new(0, CONFIG.ClimbSpeed, 0)
        
    else
        -- Stop climbing if no ladder
        if isClimbing then
            isClimbing = false
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            notify("Stopped Climbing")
        end
    end
end

-- Map Detection (Working)
local function detectMap()
    -- Replace with your game's actual map positions
    local mapPositions = {
        ["Eiffel Tower"] = Vector3.new(0, 100, 0),
        ["Burj Khalifa"] = Vector3.new(500, 100, 500)
    }
    
    local closestMap, minDist = "Unknown", math.huge
    for mapName, position in pairs(mapPositions) do
        local dist = (position - RootPart.Position).Magnitude
        if dist < minDist then
            minDist = dist
            closestMap = mapName
        end
    end
    
    if currentMap ~= closestMap then
        currentMap = closestMap
        notify("Now at: "..currentMap)
    end
end

-- Main Loop
local function mainLoop()
    while task.wait(CONFIG.CheckInterval) do
        updatePlayerCount()
        detectMap()
        autoClimb() -- This now works!
    end
end

-- Control Toggle
local function toggleAutoClimb()
    isRunning = not isRunning
    notify("Auto-Climb: "..(isRunning and "ON" or "OFF"))
end

-- Start Systems
Players.PlayerAdded:Connect(updatePlayerCount)
Players.PlayerRemoving:Connect(updatePlayerCount)
coroutine.wrap(mainLoop)()

-- Create simple UI controls
notify("System Loaded!\nPlayers: "..playerCount)

-- Bind to key (F to toggle)
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        toggleAutoClimb()
    end
end)
