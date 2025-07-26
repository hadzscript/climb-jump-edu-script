--// Educational Auto Climb + Jump + Trophy Loop Script
--// Works per map, with Rayfield toggle UI integration
--// Safe anti-ban pacing & logic

-- CONFIG: Tower heights per map (can update manually as game grows)
local towerHeights = {
    ["Eiffel Tower"] = 500,
    ["Empire State Building"] = 1000,
    ["Oriental Pearl Tower"] = 2500,
    ["Big Ben"] = 4000,
    ["Obelisk"] = 6000,
    ["Leaning Tower"] = 8000,
    ["Pixel World"] = 10000,
    ["Tokyo Tower"] = 12000,
    ["Petronas Towers"] = 15000,
    ["Mount Everest"] = 18000 -- Newest map
}

-- Set this manually or create detection logic later
local currentMap = "Mount Everest"

-- Flags & services
getgenv().autoClimbLoop = false
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Safe climb loop per map
function startMapClimbLoop()
    while getgenv().autoClimbLoop and task.wait(0.2) do
        local char = player.Character
        if not (char and char:FindFirstChild("HumanoidRootPart")) then continue end

        local root = char.HumanoidRootPart
        local heightGoal = towerHeights[currentMap] or 1000
        local climbSpeed = 10 -- studs per climb tick

        -- Phase 1: Climb up
        while root.Position.Y < (heightGoal - 50) and getgenv().autoClimbLoop do
            root.CFrame = root.CFrame + Vector3.new(0, climbSpeed, 0)
            task.wait(0.1 + math.random() * 0.05) -- adds randomness for safety
        end

        -- Phase 2: Try to touch trophy
        local trophy = workspace:FindFirstChild("Trophy")
        if trophy and trophy:IsA("BasePart") then
            pcall(function()
                firetouchinterest(root, trophy, 0)
                task.wait(0.2)
                firetouchinterest(root, trophy, 1)
            end)
        end

        -- Phase 3: Drop down
        root.CFrame = root.CFrame * CFrame.new(0, -3000, 0)
        task.wait(5)
    end
end

-- Rayfield UI Hook
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
   Name = "Climb & Jump Auto Script",
   LoadingTitle = "Climb and Jump Tower",
   LoadingSubtitle = "by hadzscript",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ClimbJumpAuto",
      FileName = "Settings"
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateToggle({
   Name = "Auto Climb Loop (Current Map)",
   CurrentValue = false,
   Flag = "AutoClimbLoop",
   Callback = function(Value)
       getgenv().autoClimbLoop = Value
       if Value then
           task.spawn(startMapClimbLoop)
       end
   end,
})

MainTab:CreateDropdown({
    Name = "Select Current Map",
    Options = table.pack(unpack((function()
        local list = {}
        for k, _ in pairs(towerHeights) do table.insert(list, k) end
        return list
    end)())),
    CurrentOption = currentMap,
    Callback = function(Option)
        currentMap = Option
        Rayfield:Notify({
           Title = "Map Updated",
           Content = "Now climbing: " .. Option,
           Duration = 3
        })
    end
})
