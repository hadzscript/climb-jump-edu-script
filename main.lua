-- Educational Roblox Script for Climb and Jump Tower
-- Features: Auto Climb, Auto Jump, Auto Trophy Collect, Auto Hatch Pets (Immortal/Secret only), Anti-Ban
-- For EDUCATIONAL PURPOSES ONLY. Do not use in public servers or violate Roblox's TOS.
-- Requires Rayfield UI Library

-- // Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
   Name = "Climb & Jump Auto UI",
   LoadingTitle = "Climb & Jump Tower",
   LoadingSubtitle = "by YourUsername",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "ClimbJumpSettings"
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false
})

-- Global flags
getgenv().autoClimb = false
getgenv().autoHatch = false

-- // Anti-ban: basic delay wrapper
function safeWait(seconds)
    task.wait(math.clamp(seconds, 0.5, 10)) -- No spammy calls
end

-- // Auto Climb Function
function startClimbing()
    while getgenv().autoClimb and task.wait(0.3) do
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            -- Simulate climb by moving upward
            char:PivotTo(char:GetPivot() * CFrame.new(0, 5, 0))
        end
    end
end

-- // Auto Trophy + Jump Loop
function trophyJumpLoop()
    while getgenv().autoClimb and task.wait(3) do
        -- Touch trophy part (if exists)
        local trophy = workspace:FindFirstChild("Trophy")
        if trophy and trophy:IsA("BasePart") then
            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, trophy, 0)
            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, trophy, 1)
        end

        -- Jump off
        local char = game.Players.LocalPlayer.Character
        if char then
            char:PivotTo(char:GetPivot() * CFrame.new(0, -1000, 0))
        end

        safeWait(2)
    end
end

-- // Auto Hatch Pets (Filtered)
function autoHatchPets()
    while getgenv().autoHatch and task.wait(1.5) do
        local hatchEvent = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents"):FindFirstChild("HatchPet")
        if hatchEvent then
            -- Simulate hatch request
            hatchEvent:FireServer("BasicEgg") -- egg name may vary

            -- Check backpack/pet inventory (pseudo)
            local pets = game:GetService("Players").LocalPlayer:WaitForChild("PetsFolder")
            for _, pet in ipairs(pets:GetChildren()) do
                if not (pet.Name:find("Immortal") or pet.Name:find("Secret")) then
                    pet:Destroy() -- delete weak pets
                end
            end
        end
    end
end

-- // MAIN UI

local mainTab = Window:CreateTab("🏔️ Main", 4483362458)

mainTab:CreateToggle({
   Name = "Auto Climb + Jump + Trophy",
   CurrentValue = false,
   Flag = "AutoClimb",
   Callback = function(Value)
       getgenv().autoClimb = Value
       if Value then
           task.spawn(startClimbing)
           task.spawn(trophyJumpLoop)
       end
   end,
})

-- // PET TAB

local petTab = Window:CreateTab("🐾 Pets", 4483362458)

petTab:CreateToggle({
   Name = "Auto Hatch Pets (Immortal/Secret Only)",
   CurrentValue = false,
   Flag = "AutoHatch",
   Callback = function(Value)
       getgenv().autoHatch = Value
       if Value then
           task.spawn(autoHatchPets)
       end
   end,
})

-- // INFO TAB

local infoTab = Window:CreateTab("ℹ️ Info", 4483362458)

infoTab:CreateParagraph({
   Title = "Notice",
   Content = "This script is for educational purposes only. Do not use on public servers. Violating game rules may result in bans."
})
