--[[
    Climb & Jump Tower Script with:
    - Rayfield UI
    - Auto Climb w/ Unlock Checks
    - Auto Hatch (Immortal & Secret)
    - Status HUD
    - Anti-Ban: Randomized delay
]]

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- Win requirements
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

local AutoClimb = false
local AutoHatch = false
local SelectedMap = "Eiffel Tower"

local function getWins()
    local stats = Player:FindFirstChild("leaderstats")
    return stats and stats:FindFirstChild("Wins") and stats.Wins.Value or 0
end

local function waitUntilGround()
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    while true do
        local result = Workspace:Raycast(HRP.Position, Vector3.new(0, -6, 0), params)
        if result then break end
        task.wait(0.1)
    end
end

local function climbToY(y)
    HRP.CFrame = CFrame.new(HRP.Position.X, y, HRP.Position.Z)
    task.wait(math.random(15, 35)/100)
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
    local humanoid = Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- UI
local Window = Rayfield:CreateWindow({Name = "Climb & Hatch Script", LoadingTitle = "Tower Autofarm", ConfigurationSaving = {Enabled = false}})

local MainTab = Window:CreateTab("Main")

MainTab:CreateToggle({
    Name = "Auto Climb",
    CurrentValue = false,
    Callback = function(v) AutoClimb = v end
})

MainTab:CreateToggle({
    Name = "Auto Hatch (Immortal & Secret)",
    CurrentValue = false,
    Callback = function(v) AutoHatch = v end
})

MainTab:CreateDropdown({
    Name = "Select Map",
    Options = table.pack(unpack((function()
        local t = {}
        for name in pairs(WorldRequirements) do
            table.insert(t, name)
        end
        return t
    end)())),
    CurrentOption = "Eiffel Tower",
    Callback = function(map)
        SelectedMap = map
    end
})

MainTab:CreateParagraph({Title = "Status", Content = "Wins: ...\nMap: ..."})

-- Main Loop
spawn(function()
    while task.wait(2) do
        if AutoClimb then
            local wins = getWins()
            local required = WorldRequirements[SelectedMap]
            if wins >= required then
                for _, y in ipairs(ClimbSteps[SelectedMap]) do
                    climbToY(y)
                end
                tryTouchTrophy()
                safeJump()
                waitUntilGround()
            end
        end
    end
end)

-- Auto Hatch (placeholder)
spawn(function()
    while task.wait(3) do
        if AutoHatch then
            print("[AutoHatch]: Simulating Immortal/Secret hatch...")
        end
    end
end)

-- UI status updater
spawn(function()
    while task.wait(1) do
        local p = MainTab:GetParagraph("Status")
        if p then
            p:Set({
                Title = "Status",
                Content = "Wins: " .. getWins() .. "\nMap: " .. SelectedMap
            })
        end
    end
end)
