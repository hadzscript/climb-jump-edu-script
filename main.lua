--[[
    Climb & Jump Tower Script (Educational)
    ✅ Rayfield UI
    ✅ Auto Climb + Trophy + Jump Loop
    ✅ World Unlock Checker w/ Colors
    ✅ Dynamic Map Detection + Display
    ✅ Full UI Status (Wins, Coins, Current Map)
    ✅ Real-Time Loading Screen
    ✅ Anti-Ban Logic
]]--

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Loading Screen
local loadingWindow = Rayfield:CreateWindow({
    Name = "🌀 Loading Climb & Jump...",
    LoadingTitle = "Initializing Script...",
    ConfigurationSaving = {Enabled = false}
})

Rayfield:Notify({Title="Loading", Content="Fetching your map, wins, coins...", Duration=4})

local wins = 0
local coins = 0
local currentMap = "Unknown"

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
    ["Himalayas"] = 50000000
}

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
    ["Himalayas"] = {2000, 4000, 6000, 8000, 10000}
}

local function getStats()
    local stats = Player:FindFirstChild("leaderstats")
    return {
        wins = stats and stats:FindFirstChild("Wins") and stats.Wins.Value or 0,
        coins = stats and stats:FindFirstChild("Coins") and stats.Coins.Value or 0
    }
end

local function detectCurrentMap()
    local closestMap = "Unknown"
    local closestDist = math.huge
    local x = HRP.Position.X

    for mapName, steps in pairs(ClimbSteps) do
        for _, y in ipairs(steps) do
            local pos = Vector3.new(x, y, HRP.Position.Z)
            local dist = (HRP.Position - pos).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestMap = mapName
            end
        end
    end
    return closestMap
end

local function waitUntilGround()
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    while true do
        local ray = Workspace:Raycast(HRP.Position, Vector3.new(0, -6, 0), rayParams)
        if ray then break end
        task.wait(0.1 + math.random()*0.2)
    end
end

local function climbToY(targetY)
    HRP.CFrame = CFrame.new(HRP.Position.X, targetY, HRP.Position.Z)
    task.wait(0.3 + math.random() * 0.4)
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

-- Main UI
local Window = Rayfield:CreateWindow({
    Name = "🏔 Climb & Jump Hub",
    LoadingTitle = "Climb & Jump Hub Ready!",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ClimbJumpScript",
        FileName = "AutoFarmConfig"
    }
})

local MainTab = Window:CreateTab("Main", 4483362458)

local SelectedMap = detectCurrentMap() or "Eiffel Tower"
local AutoClimb = false

local MapDropdown = MainTab:CreateDropdown({
    Name = "Select Map (🟢 = Unlocked | 🔴 = Locked)",
    Options = {},
    CurrentOption = "🟢 " .. SelectedMap,
    Flag = "SelectedMap",
    Callback = function(opt)
        SelectedMap = opt:gsub("🟢 ", ""):gsub("🔴 ", "")
    end
})

MainTab:CreateToggle({
    Name = "Enable Auto Climb",
    CurrentValue = false,
    Callback = function(state)
        AutoClimb = state
    end
})

local StatusUI = MainTab:CreateParagraph({
    Title = "Live Status",
    Content = "Wins: 0\nCoins: 0\nMap: Unknown",
    Flag = "StatusParagraph"
})

-- Live Updater
spawn(function()
    while task.wait(2) do
        local stats = getStats()
        wins, coins = stats.wins, stats.coins
        currentMap = detectCurrentMap()
        StatusUI:Set("Wins: "..wins.."\nCoins: "..coins.."\nMap: "..currentMap)

        local options = {}
        for name, req in pairs(WorldRequirements) do
            if wins >= req then
                table.insert(options, "🟢 "..name)
            else
                table.insert(options, "🔴 "..name)
            end
        end
        MapDropdown:Refresh(options, true)
        MapDropdown:Set((wins >= (WorldRequirements[currentMap] or math.huge)) and "🟢 "..currentMap or "🔴 "..currentMap)
        SelectedMap = currentMap
    end
end)

-- Auto Climb Loop
spawn(function()
    while task.wait(3 + math.random()) do
        if not AutoClimb then continue end
        if not ClimbSteps[SelectedMap] then continue end
        if wins < (WorldRequirements[SelectedMap] or 0) then continue end
        for _, y in ipairs(ClimbSteps[SelectedMap]) do
            climbToY(y)
        end
        tryTouchTrophy()
        safeJump()
        waitUntilGround()
    end
end)

Rayfield:Notify({Title="Ready", Content="Climb & Jump Loaded Successfully!", Duration=5})
