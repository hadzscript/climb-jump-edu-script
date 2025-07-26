--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

--// Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Movement Recorder | Climb & Jump Tower",
    LoadingTitle = "Loading Recorder...",
    ConfigurationSaving = {
        Enabled = false
    }
})

local Tab = Window:CreateTab("Movement", 4483362458)

--// Storage
local IsRecording = false
local MovementData = {}
local StartTime = 0
local IsPlaying = false

--// Buttons
Tab:CreateButton({
    Name = "Start Recording",
    Callback = function()
        MovementData = {}
        IsRecording = true
        StartTime = tick()

        Rayfield:Notify({
            Title = "Recording Started",
            Content = "Your movement is now being recorded...",
            Duration = 3
        })

        task.spawn(function()
            while IsRecording do
                local timeElapsed = tick() - StartTime
                table.insert(MovementData, {
                    Time = timeElapsed,
                    Position = HumanoidRootPart.Position
                })
                task.wait(0.1) -- Record every 0.1s
            end
        end)
    end
})

Tab:CreateButton({
    Name = "Stop Recording",
    Callback = function()
        IsRecording = false
        Rayfield:Notify({
            Title = "Recording Stopped",
            Content = "Captured " .. #MovementData .. " points.",
            Duration = 3
        })
    end
})

Tab:CreateButton({
    Name = "Play Recording (Loop)",
    Callback = function()
        if #MovementData < 2 then
            Rayfield:Notify({
                Title = "No Movement Data",
                Content = "Please record something first.",
                Duration = 3
            })
            return
        end

        IsPlaying = true
        Rayfield:Notify({
            Title = "Playback Started",
            Content = "Movement will now repeat in loop.",
            Duration = 3
        })

        task.spawn(function()
            while IsPlaying do
                local startTime = tick()

                for i = 1, #MovementData - 1 do
                    local current = MovementData[i]
                    local next = MovementData[i + 1]
                    local delay = next.Time - current.Time

                    -- Tween to next position
                    local tween = TweenService:Create(
                        HumanoidRootPart,
                        TweenInfo.new(delay, Enum.EasingStyle.Linear),
                        {Position = next.Position}
                    )
                    tween:Play()
                    tween.Completed:Wait()

                    if not IsPlaying then break end
                end

                task.wait(0.5) -- Delay before loop restart
            end
        end)
    end
})

Tab:CreateButton({
    Name = "Stop Playback",
    Callback = function()
        IsPlaying = false
        Rayfield:Notify({
            Title = "Playback Stopped",
            Content = "Movement looping ended.",
            Duration = 2
        })
    end
})
