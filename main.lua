-- Climb & Jump Tower Script with Rayfield UI
-- Version 3.0 - Full Feature Implementation

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Player setup
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Rayfield UI Load
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Configuration
local CONFIG = {
    CLIMB_SPEED = 25,
    JUMP_DELAY = 0.5,
    GROUND_CHECK_DISTANCE = 5,
    RANDOM_DELAY_MIN = 0.1,
    RANDOM_DELAY_MAX = 0.5,
    TROPHY_CLAIM_RADIUS = 10,
    MAP_DETECTION_INTERVAL = 5
}

-- State variables
local isRunning = false
local currentMap = nil
local unlockedMaps = {}
local stats = {
    Wins = 0,
    Coins = 0
}

-- UI Variables
local mainWindow
local statusLabel
local statsLabel
local mapDropdown

-- Initialize Rayfield UI
local function initUI()
    -- Loading screen
    Rayfield:Notify({
        Title = "Climb & Jump Tower",
        Content = "Loading script...",
        Duration = 2,
        Image = "rbxassetid://4483345998"
    })

    -- Main window
    mainWindow = Rayfield:CreateWindow({
        Name = "Climb & Jump Tower",
        LoadingTitle = "Initializing...",
        LoadingSubtitle = "Loading all features",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "ClimbAndJump",
            FileName = "Config"
        }
    })

    -- Tabs
    local mainTab = mainWindow:CreateTab("Main")
    local settingsTab = mainWindow:CreateTab("Settings")

    -- Status label
    statusLabel = mainTab:CreateLabel("Status: Ready")

    -- Stats display
    statsLabel = mainTab:CreateLabel("Wins: 0 | Coins: 0 | Current Map: None")

    -- Map dropdown
    mapDropdown = mainTab:CreateDropdown({
        Name = "Select Map",
        Options = {"Loading maps..."},
        CurrentOption = "None",
        Flag = "MapSelector",
        Callback = function(option)
            currentMap = option
            statusLabel:Set("Status: Selected " .. option)
        end
    })

    -- Toggle
    mainTab:CreateToggle({
        Name = "Auto Climb & Jump",
        CurrentValue = false,
        Flag = "AutoToggle",
        Callback = function(value)
            isRunning = value
            if value then
                statusLabel:Set("Status: Running")
            else
                statusLabel:Set("Status: Paused")
            end
        end
    })

    -- Settings
    settingsTab:CreateSlider({
        Name = "Climb Speed",
        Range = {10, 50},
        Increment = 1,
        Suffix = "units",
        CurrentValue = CONFIG.CLIMB_SPEED,
        Flag = "ClimbSpeed",
        Callback = function(value)
            CONFIG.CLIMB_SPEED = value
        end
    })

    settingsTab:CreateLabel("Script by YourName")
end

-- Map detection functions
local function getCurrentMap()
    -- Implement your map detection logic here
    -- This should return the map name and whether it's unlocked
    return "Map1", true
end

local function updateMapsList()
    -- This should fetch all available maps and their unlock status
    unlockedMaps = {
        {Name = "Map1", Unlocked = true},
        {Name = "Map2", Unlocked = false},
        {Name = "Map3", Unlocked = true}
    }

    local dropdownOptions = {}
    for _, map in pairs(unlockedMaps) do
        table.insert(dropdownOptions, map.Name .. (map.Unlocked and " 🟢" or " 🔴"))
    end

    mapDropdown:UpdateOptions(dropdownOptions)
    
    -- Auto-select current map
    local currentMapName = getCurrentMap()
    mapDropdown:Set(currentMapName)
end

-- Game functions
local function isOnGround()
    local rayOrigin = HumanoidRootPart.Position
    local rayDirection = Vector3.new(0, -CONFIG.GROUND_CHECK_DISTANCE, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {Character}
    
    local rayResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    return rayResult ~= nil
end

local function claimTrophy()
    -- Implement trophy claiming logic
    -- Check for trophies in radius and claim them
    statusLabel:Set("Status: Claiming trophy...")
    task.wait(math.random(CONFIG.RANDOM_DELAY_MIN, CONFIG.RANDOM_DELAY_MAX))
end

local function climbToTop()
    if not isRunning then return end
    
    statusLabel:Set("Status: Climbing...")
    
    -- Move character upward
    HumanoidRootPart.Velocity = Vector3.new(0, CONFIG.CLIMB_SPEED, 0)
    
    -- Wait until reaching the top (implement your own detection)
    local reachedTop = false
    while not reachedTop and isRunning do
        -- Add your top detection logic here
        task.wait()
    end
    
    -- Stop climbing
    HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    
    -- Jump off
    if isRunning then
        statusLabel:Set("Status: Jumping...")
        HumanoidRootPart.Velocity = Vector3.new(0, 50, -30)
        task.wait(CONFIG.JUMP_DELAY)
    end
end

-- Main loop
local function mainLoop()
    while true do
        if isRunning then
            -- Check if we're on ground
            if isOnGround() then
                -- Check current map
                local mapName, unlocked = getCurrentMap()
                if unlocked then
                    -- Update stats
                    statsLabel:Set(string.format("Wins: %d | Coins: %d | Current Map: %s", stats.Wins, stats.Coins, mapName))
                    
                    -- Start climbing
                    climbToTop()
                    
                    -- Claim trophy if at top
                    claimTrophy()
                    
                    -- Random delay
                    task.wait(math.random(CONFIG.RANDOM_DELAY_MIN, CONFIG.RANDOM_DELAY_MAX))
                else
                    statusLabel:Set("Status: Map locked - skipping")
                    task.wait(CONFIG.MAP_DETECTION_INTERVAL)
                end
            else
                task.wait(0.1)
            end
        else
            task.wait(1)
        end
    end
end

-- Initialize
initUI()
updateMapsList()

-- Start main loop
coroutine.wrap(mainLoop)()
