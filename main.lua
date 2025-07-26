--[[
    Climb & Jump Tower Script with UI
    ✅ Auto Climb (Multi-Step)
    ✅ Auto Hatch (Immortal & Secret Only)
    ✅ Map Lock Detection (Wins Based)
    ✅ Rayfield UI with Toggle Controls
    ✅ Status Display (Wins, Map)
    ✅ Randomized Anti-Ban Delays
]]

--// Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

--// Dependencies (Rayfield)
loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

--// World Requirements
local WorldRequirements = {
    ["Eiffel Tower"] = 0,
    ["Statue of Liberty"] = 10,
    ["Leaning Tower of Pisa"] = 17500,
    ["Pyramids"] = 50000,
    ["Burj Khalifa"] = 80000,
    ["Empire State Building"] = 100000,
    ["World Trade Center"] = 400000,
    ["Big Ben"] = 1000000,
    ["Oriental Pearl Tower"] = 2000000,
    ["Tokyo Tower"] = 2000000,
    ["Petronas Towers"] = 10000000,
    ["Himalayas"] = 50000000,
}

--// Climb Steps Per Map
local ClimbSteps = {
    ["Eiffel Tower"] = {200, 400, 600, 800},
    ["Statue of Liberty"] = {300, 600, 900},
    ["Leaning Tower of Pisa"] = {300, 600, 900, 1200},
    ["Pyramids"] = {300, 700, 1100, 1600},
    ["Burj Khalifa"] = {500, 1000, 1500, 2000},
    ["Empire State Building"] = {400, 800, 1200, 1600},
    ["World Trade Center"] = {700, 1200, 1800, 2400},
    ["Big Ben"] = {800, 1300, 1800},
    ["Oriental Pearl Tower"] = {900, 1500, 2200},
    ["Tokyo Tower"] = {1000, 1600, 2200},
    ["Petronas Towers"] = {1200, 2000, 2800, 3600},
    ["Himalayas"] = {2000, 4000, 6000, 8000, 10000},
}

--// Auto Flags
local autoClimb = false
local autoHatch = false
local selectedMap = "Eiffel Tower"

--// Functions
local function getWins()
    local stats = Player:FindFirstChild("leaderstats")
    local wins = stats and stats:FindFirstChild("Wins")
    return wins and wins.Value or 0
end

local function waitUntilGround()
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    while true do
        local hit = Workspace:Raycast(HRP.Position, Vector3.new(0, -6, 0), rayParams)
        if hit then break end
        task.wait(0.1)
    end
end

local function safeClimb(height)
    local pos = HRP.Position
    local dest = Vector3.new(pos.X, height, pos.Z)
    HRP.CFrame = CFrame.new(dest)
    task.wait(math.random(20,40)/100) -- random delay for anti-ban
end

local function tryTouchTrophy()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") and v.Parent and v.Parent.Name:lower():find("trophy") then
            firetouchinterest(HRP, v.Parent, 0)
            firetouchinterest(HRP, v.Parent, 1)
        end
    end
end

local function safeJump()
    local hum = Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end

local function climbLoop()
    while task.wait(2) do
        if autoClimb then
            local wins = getWins()
            local req = WorldRequirements[selectedMap]
            if wins >= req then
                local steps = ClimbSteps[selectedMap]
                for _, h in ipairs(steps) do
                    safeClimb(h)
                end
                tryTouchTrophy()
                safeJump()
                waitUntilGround()
            end
        end
    end
end

local function autoHatchPets()
    while task.wait(3) do
        if autoHatch then
            local hatchRemote = ReplicatedStorage:FindFirstChild("Hatch")
            if hatchRemote then
                hatchRemote:InvokeServer("OpenEgg", {
                    Amount = 1,
                    Auto = false,
                    Rarities = {"Immortal", "Secret"}
                })
            end
        end
    end
end

--// Rayfield UI
local Window = Rayfield:CreateWindow({
    Name = "Climb Jump EDU", ConfigurationSaving = {Enabled = false}, IntroEnabled = false
})

Rayfield:CreateLabel({Name = "Status: Wins/Map", ContentText = function()
    return "Wins: "..getWins().." | Map: "..selectedMap
end, Parent = Window})

Rayfield:CreateDropdown({
    Name = "Select Map",
    Options = table.keys(WorldRequirements),
    CurrentOption = selectedMap,
    Callback = function(opt)
        selectedMap = opt
    end,
    Parent = Window
})

Rayfield:CreateToggle({
    Name = "Auto Climb",
    CurrentValue = false,
    Callback = function(val) autoClimb = val end,
    Parent = Window
})

Rayfield:CreateToggle({
    Name = "Auto Hatch (Immortal/Secret)",
    CurrentValue = false,
    Callback = function(val) autoHatch = val end,
    Parent = Window
})

--// Start Threads
spawn(climbLoop)
spawn(autoHatchPets)
