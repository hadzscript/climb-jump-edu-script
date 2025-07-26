-- Ultimate Climb & Jump Tower Autoplayer
-- Complete with trophy detection, map progression, and mobile-friendly UI

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Load Rayfield UI (mobile optimized)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Player setup
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Game Configuration
local CONFIG = {
    ClimbSpeed = 28,
    JumpPower = 45,
    TrophyCheckInterval = 0.5,
    MapCheckInterval = 3,
    AntiBanDelay = {1, 3}, -- min/max random delay
    LadderTags = {"Ladder", "Climbable"},
    TrophyNames = {"Trophy", "WinPart", "Finish"}
}

-- Game State
local currentMap = "Unknown"
local unlockedMaps = {}
local stats = {
    Wins = 0,
    Coins = 0,
    Trophies = 0
}
local isRunning = false
local isClimbing = false

-- Mobile Control Buttons
local mobileControls = {
    Climb = false,
    Jump = false
}

-- Initialize Rayfield UI
local Window = Rayfield:CreateWindow({
    Name = "Climb & Jump Tower",
    LoadingTitle = "Loading Premium Autoplayer",
    LoadingSubtitle = "Mobile & PC Optimized",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ClimbJumpPro",
        FileName = "Settings"
    },
    KeySystem = false -- Set to true if you want key auth
})

-- Main Tab
local MainTab = Window:CreateTab("Main", 4483362458) -- Climb icon
local StatusLabel = MainTab:CreateLabel("Status: Ready")
local StatsLabel = MainTab:CreateLabel("Wins: 0 | Coins: 0 | Trophies: 0")

-- Map Selection
local MapDropdown = MainTab:CreateDropdown({
    Name = "Map Selection",
    Options = {"Loading maps..."},
    CurrentOption = "None",
    Flag = "MapSelector",
    Callback = function(Option)
        currentMap = Option
    end
})

-- Auto-Climb Toggle
MainTab:CreateToggle({
    Name = "Auto Climb & Trophy",
    CurrentValue = false,
    Flag = "AutoToggle",
    Callback = function(Value)
        isRunning = Value
        StatusLabel:Set("Status: "..(Value and "Running" or "Stopped"))
    end
})

-- Mobile Controls (only visible on mobile)
if UIS.TouchEnabled then
    local ControlsTab = Window:CreateTab("Mobile Controls", 4733963921) -- Mobile icon
    
    ControlsTab:CreateButton({
        Name = "Climb (Hold)",
        Callback = function()
            mobileControls.Climb = true
            startClimbing()
        end
    }):CreateBind({
        EndedCallback = function()
            mobileControls.Climb = false
            stopClimbing(false)
        end
    })
    
    ControlsTab:CreateButton({
        Name = "Jump Off",
        Callback = function()
            if isClimbing then
                stopClimbing(true)
            else
                Humanoid.Jump = true
            end
        end
    })
end

-- Settings Tab
local SettingsTab = Window:CreateTab("Settings", 6031280882) -- Gear icon
SettingsTab:CreateSlider({
    Name = "Climb Speed",
    Range = {10, 50},
    Increment = 1,
    CurrentValue = CONFIG.ClimbSpeed,
    Flag = "ClimbSpeed",
    Callback = function(Value)
        CONFIG.ClimbSpeed = Value
    end
})

-- Trophy Detection
local function findNearestTrophy()
    local closest
    local minDist = math.huge
    
    for _, trophyName in pairs(CONFIG.TrophyNames) do
        for _, part in pairs(Workspace:GetDescendants()) do
            if part.Name:lower():find(trophyName:lower()) and part:IsA("BasePart") then
                local dist = (part.Position - RootPart.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = part
                end
            end
        end
    end
    
    return closest, minDist
end

-- Ladder Detection (improved)
local function findBestLadder()
    local bestLadder
    local bestScore = 0
    
    for _, tag in pairs(CONFIG.LadderTags) do
        for _, part in pairs(Workspace:GetDescendants()) do
            if (part:FindFirstChild(tag) or part:GetAttribute("Climbable")) and part:IsA("BasePart") then
                -- Score based on proximity and alignment
                local toPart = (part.Position - RootPart.Position)
                local distScore = 1 / (toPart.Magnitude + 0.01)
                local alignScore = math.abs(RootPart.CFrame.LookVector:Dot(toPart.Unit))
                local totalScore = distScore * alignScore
                
                if totalScore > bestScore then
                    bestScore = totalScore
                    bestLadder = part
                end
            end
        end
    end
    
    return bestLadder
end

-- Core Climbing System
local function startClimbing()
    if isClimbing then return end
    
    local ladder = findBestLadder()
    if not ladder then return end
    
    isClimbing = true
    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    Humanoid.AutoRotate = false
    
    -- Position character on ladder
    local ladderCF = ladder.CFrame
    local offset = ladderCF.LookVector * 2
    RootPart.CFrame = CFrame.new(RootPart.Position + offset, RootPart.Position + ladderCF.LookVector)
end

local function stopClimbing(shouldJump)
    if not isClimbing then return end
    
    isClimbing = false
    Humanoid.AutoRotate = true
    Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    
    if shouldJump then
        RootPart.Velocity = Vector3.new(0, CONFIG.JumpPower, 0)
    end
end

-- Main Game Loop
local function gameLoop()
    while task.wait() do
        if isRunning then
            -- Check for trophies
            local trophy, trophyDist = findNearestTrophy()
            if trophy and trophyDist < 10 then
                StatusLabel:Set("Status: Claiming Trophy")
                firetouchinterest(RootPart, trophy, 0) -- Simulate touch
                firetouchinterest(RootPart, trophy, 1)
                stats.Trophies += 1
                StatsLabel:Set(string.format("Wins: %d | Coins: %d | Trophies: %d", 
                    stats.Wins, stats.Coins, stats.Trophies))
                task.wait(math.random(unpack(CONFIG.AntiBanDelay)))
            end
            
            -- Auto-climb logic
            if not isClimbing then
                startClimbing()
            else
                -- Move upward while climbing
                RootPart.Velocity = Vector3.new(0, CONFIG.ClimbSpeed, 0)
            end
        end
    end
end

-- Initialize
coroutine.wrap(gameLoop)()
Rayfield:Notify({
    Title = "System Ready",
    Content = "Auto-climber initialized successfully!",
    Duration = 3,
    Image = "rbxassetid://4483362458"
})
