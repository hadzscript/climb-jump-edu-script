--// Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

--// Rayfield UI Init
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Climb & Jump Tower | Scanner UI",
    LoadingTitle = "Initializing Rayfield...",
    ConfigurationSaving = {
        Enabled = false
    }
})

local Tab = Window:CreateTab("Scan & Hook", 4483362458)

--// Result Tables
local ScanResults = {
    Pets = {},
    Maps = {},
    Eggs = {},
    Trophies = {},
    Ladders = {}
}
local HookedObjects = {}

--// Generic scan function with yield
local function scanFolder(folder, types)
    local results = {}
    for _, obj in ipairs(folder:GetDescendants()) do
        task.wait() -- Prevent freezing
        for _, t in ipairs(types) do
            if obj:IsA(t) then
                table.insert(results, obj)
            end
        end
    end
    return results
end

--// Hook Function
local function hookObject(obj, name)
    if HookedObjects[name] then return end
    HookedObjects[name] = true
    print("[Hooked]:", name)

    task.spawn(function()
        while HookedObjects[name] and obj and obj.Parent do
            if name:lower():find("egg") then
                print("Auto-Hatch:", name)
            elseif name:lower():find("trophy") then
                print("Auto-Claim Trophy:", name)
            elseif name:lower():find("ladder") then
                print("Auto-Climb Ladder:", name)
            end
            task.wait(1)
        end
    end)
end

--// Button Generator
local function addScanButton(name, folder, types, category)
    Tab:CreateButton({
        Name = "Scan " .. name,
        Callback = function()
            Rayfield:Notify({
                Title = "Scanning " .. name,
                Content = "Please wait...",
                Duration = 3
            })

            task.spawn(function()
                local results = scanFolder(folder, types)
                ScanResults[category] = results

                Rayfield:Notify({
                    Title = name .. " Scan Complete",
                    Content = "Found " .. #results .. " items",
                    Duration = 4
                })

                -- Add toggles
                for _, obj in ipairs(results) do
                    if obj.Name and obj:IsDescendantOf(Workspace) then
                        Tab:CreateToggle({
                            Name = obj.Name,
                            CurrentValue = false,
                            Callback = function(enabled)
                                if enabled then
                                    hookObject(obj, obj.Name)
                                else
                                    HookedObjects[obj.Name] = nil
                                end
                            end
                        })
                    end
                end
            end)
        end
    })
end

--// Add Buttons
addScanButton("Pets", ReplicatedStorage:FindFirstChild("Pets") or Workspace, {"Model", "Folder"}, "Pets")
addScanButton("Maps", Workspace, {"Model", "Folder"}, "Maps")
addScanButton("Eggs", Workspace, {"Model", "Part", "Folder"}, "Eggs")
addScanButton("Trophies", Workspace, {"Part", "Model"}, "Trophies")
addScanButton("Ladders", Workspace, {"Part", "Model"}, "Ladders")
