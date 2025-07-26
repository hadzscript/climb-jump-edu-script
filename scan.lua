-- Ultimate Movement Recorder for Climb & Jump Tower
-- Uses lightweight UI alternative to Rayfield

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Player setup
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- UI Library (Lightweight alternative to Rayfield)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/vozoid/ui-backups/main/uwuware"))()

-- Movement recording
local Recordings = {
    [1] = {Name = "Slot 1", Data = nil},
    [2] = {Name = "Slot 2", Data = nil},
    [3] = {Name = "Slot 3", Data = nil}
}
local CurrentSlot = 1
local IsRecording = false
local IsPlaying = false

-- Player count tracking
local PlayerCount = #Players:GetPlayers()

-- Create main window
local Window = Library:CreateWindow("Movement Recorder") do
    local TabBox = Window:AddTab("Recorder")
    
    -- Status display
    local StatusLabel = TabBox:AddLabel("Status: Ready")
    local PlayerLabel = TabBox:AddLabel("Players: "..PlayerCount)
    
    -- Slot selection
    local SlotDropdown = TabBox:AddDropdown("Select Slot", {
        Values = {"Slot 1", "Slot 2", "Slot 3"},
        Multi = false,
        Default = 1,
        Callback = function(Value)
            CurrentSlot = tonumber(string.sub(Value, -1))
        end
    })
    
    -- Recording controls
    TabBox:AddButton("Start Recording", function()
        if IsRecording then return end
        
        Recordings[CurrentSlot].Data = {}
        IsRecording = true
        StatusLabel:Set("Status: Recording "..Recordings[CurrentSlot].Name)
        
        local StartTime = os.clock()
        local Connection
        Connection = RunService.Heartbeat:Connect(function()
            if not IsRecording then
                Connection:Disconnect()
                return
            end
            
            table.insert(Recordings[CurrentSlot].Data, {
                Position = RootPart.Position,
                Timestamp = os.clock() - StartTime
            })
        end)
    end)
    
    TabBox:AddButton("Stop Recording", function()
        IsRecording = false
        StatusLabel:Set("Status: Saved to "..Recordings[CurrentSlot].Name)
    end)
    
    -- Playback controls
    TabBox:AddButton("Play Recording", function()
        if not Recordings[CurrentSlot].Data or #Recordings[CurrentSlot].Data == 0 then
            StatusLabel:Set("Status: No data in "..Recordings[CurrentSlot].Name)
            return
        end
        
        if IsPlaying then return end
        IsPlaying = true
        StatusLabel:Set("Status: Playing "..Recordings[CurrentSlot].Name)
        
        local function PlayMovement()
            local StartTime = os.clock()
            local Index = 1
            
            while IsPlaying and Index <= #Recordings[CurrentSlot].Data do
                local Movement = Recordings[CurrentSlot].Data[Index]
                local CurrentTime = os.clock() - StartTime
                
                if CurrentTime >= Movement.Timestamp then
                    RootPart.CFrame = CFrame.new(Movement.Position)
                    Index += 1
                end
                
                RunService.Heartbeat:Wait()
            end
            
            if IsPlaying then -- Loop if still active
                PlayMovement()
            end
        end
        
        PlayMovement()
    end)
    
    TabBox:AddButton("Stop Playback", function()
        IsPlaying = false
        StatusLabel:Set("Status: Stopped")
    end)
    
    -- Slot management
    TabBox:AddButton("Delete Slot", function()
        if Recordings[CurrentSlot].Data then
            Recordings[CurrentSlot].Data = nil
            StatusLabel:Set("Status: Deleted "..Recordings[CurrentSlot].Name)
        else
            StatusLabel:Set("Status: "..Recordings[CurrentSlot].Name.." is empty")
        end
    end)
end

-- Player count updates
Players.PlayerAdded:Connect(function()
    PlayerCount = #Players:GetPlayers()
    Window:GetTab("Recorder"):GetLabel(2):Set("Players: "..PlayerCount)
end)

Players.PlayerRemoving:Connect(function()
    PlayerCount = #Players:GetPlayers()
    Window:GetTab("Recorder"):GetLabel(2):Set("Players: "..PlayerCount)
end)

-- UI customization
Library:SetBackground("rbxassetid://123456789") -- Custom background image ID
Library:SetKey(Enum.KeyCode.RightControl) -- Toggle key

-- Notification
Library:Notify({
    Title = "Movement Recorder",
    Message = "Script loaded successfully!",
    Duration = 3
})
