-- // Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

-- // Libraries (Rayfield)
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Climb and Jump Tower | Auto UI",
    LoadingTitle = "Initializing...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "CJTAutoUI",
        FileName = "config"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- // Utility
local function scanFolder(folder, types)
    local results = {}
    for _, obj in ipairs(folder:GetDescendants()) do
        for _, t in ipairs(types) do
            if obj:IsA(t) then
                table.insert(results, obj)
            end
        end
    end
    return results
end

-- // Scan Targets
local ScanResults = {
    Pets = {},
    Maps = {},
    Eggs = {},
    Trophies = {},
    Ladders = {}
}

-- // Scanning Logic
local function scanGame()
    -- You can customize/add known paths
    ScanResults.Pets = scanFolder(ReplicatedStorage:FindFirstChild("Pets") or Workspace, {"Model", "Folder"})
    ScanResults.Maps = scanFolder(Workspace, {"Model", "Folder"})
    ScanResults.Eggs = scanFolder(Workspace, {"Model", "Part", "Folder"})
    ScanResults.Trophies = scanFolder(Workspace, {"Part", "Model"})
    ScanResults.Ladders = scanFolder(Workspace, {"Part", "Model"})
end

scanGame()

-- // Hook Map
local HookedObjects = {}

local function hookObject(obj, name)
    if HookedObjects[name] then return end
    HookedObjects[name] = true
    print("[Hooked]:", name)

    -- Basic hook behavior
    task.spawn(function()
        while HookedObjects[name] and obj and obj.Parent do
            -- Your automation logic here
            -- Example:
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

-- // Auto UI List Options
local HooksTab = Window:CreateTab("Hooks", 4483362458)

local function addToList(category, objects)
    for _, obj in ipairs(objects) do
        if obj.Name and obj:IsDescendantOf(Workspace) then
            HooksTab:CreateToggle({
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
end

addToList("Pets", ScanResults.Pets)
addToList("Maps", ScanResults.Maps)
addToList("Eggs", ScanResults.Eggs)
addToList("Trophies", ScanResults.Trophies)
addToList("Ladders", ScanResults.Ladders)

-- Done
Rayfield:Notify({
    Title = "Scan Complete",
    Content = "All categories scanned and hooked UI created.",
    Duration = 5
})
