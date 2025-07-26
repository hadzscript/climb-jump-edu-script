--[[
    Climb & Jump Tower Script with:
    - Full Map Auto Climb Loop
    - Smooth Multi-Point Movement
    - Raycast Ground Check
    - Everest Support
    - Rayfield UI
    - Anti-Ban Safety Features
    - Manual World Selector
    - Auto Hatch (Immortal & Secret Only)
    - Toggleable Climb & Hatch
    - Status UI (Wins + Current World)
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Rayfield UI Setup
loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Climb & Jump Tower [EDU]",
    LoadingTitle = "Educational Utility",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ClimbJump",
        FileName = "edu_config"
    }
})

local MainTab = Window:CreateTab("Main", 4483362458)
local ToggleClimb, ToggleHatch
local SelectedMap = nil

-- Leaderstats / Wins
local function getWins()
    local ls = Player:FindFirstChild("leaderstats")
    if ls then
        local wins = ls:FindFirstChild("Wins")
        return wins and wins.Value or 0
    end
    return 0
end

-- Maps and Wins Required
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

local MapList = {}
for name, _ in pairs(WorldRequirements) do table.insert(MapList, name) end

-- Climb heights for each map (multi-step)
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

-- Status
local CurrentStatus = MainTab:CreateParagraph({Title = "Current Status", Content = "Wins: 0\nWorld: None"})

-- UI Controls
ToggleClimb = MainTab:CreateToggle({
    Name = "Auto Climb",
    CurrentValue = true,
    Callback = function(Value) _G.DoClimb = Value end
})

ToggleHatch = MainTab:CreateToggle({
    Name = "Auto Hatch (Immortal/Secret)",
    CurrentValue = true,
    Callback = function(Value) _G.DoHatch = Value end
})

MainTab:CreateDropdown({
    Name = "Select World",
    Options = MapList,
    CurrentOption = nil,
    Callback = function(Value)
        SelectedMap = Value
    end
})

-- Wait until player touches ground
local function waitUntilGround()
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    while true do
        local result = Workspace:Raycast(HRP.Position, Vector3.new(0, -6, 0), params)
        if result then break end
        task.wait(0.2 + math.random())
    end
end

-- Climb To Y Position
local function climbToY(targetY)
    HRP.CFrame = HRP.CFrame.Position + Vector3.new(0, targetY - HRP.Position.Y, 0)
    task.wait(0.2 + math.random()*0.3)
end

-- Trophy
local function tryTouchTrophy()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") and v.Parent and v.Parent.Name:lower():find("trophy") then
            firetouchinterest(HRP, v.Parent, 0)
            task.wait(0.05)
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

-- Pet Hatching
local function autoHatch()
    local Eggs = Workspace:FindFirstChild("Eggs")
    if not Eggs then return end
    for _, egg in pairs(Eggs:GetChildren()) do
        local config = egg:FindFirstChild("Settings")
        if config and config:FindFirstChild("Rarities") then
            local rarities = config.Rarities:GetChildren()
            for _, r in pairs(rarities) do
                local name = r.Name:lower()
                if name:find("immortal") or name:find("secret") then
                    ReplicatedStorage:WaitForChild("RemoteFunction"):InvokeServer({["Type"] = "Buy", ["Egg"] = egg.Name, ["Amount"] = 1})
                end
            end
        end
    end
end

-- Main Loop
spawn(function()
    while task.wait(2 + math.random()) do
        local wins = getWins()
        CurrentStatus:Set({Content = "Wins: " .. wins .. "\nWorld: " .. (SelectedMap or "Auto")})

        -- Hatch
        if _G.DoHatch then autoHatch() end

        if _G.DoClimb then
            for mapName, requirement in pairs(WorldRequirements) do
                if SelectedMap and mapName ~= SelectedMap then continue end
                if wins >= requirement then
                    local steps = ClimbSteps[mapName]
                    if steps then
                        for _, h in ipairs(steps) do climbToY(h) end
                        tryTouchTrophy()
                        task.wait(0.5 + math.random())
                        safeJump()
                        waitUntilGround()
                    end
                end
            end
        end
    end
end)
