local TAS = require("framework.luau")

local fileName = "MyTAS" -- This is the only variable you'll want to configure.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")

local recording = false
local paused = false
local holdingForward = false
local holdingBackward = false
local forwardConnection = nil
local backwardConnection = nil

local function chat(message)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local TextChannels = TextChatService:FindFirstChild("TextChannels")
        local RBXGeneral = TextChannels:FindFirstChild("RBXGeneral")

        RBXGeneral:SendAsync(message)
    else
        local DefaultChat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        local MessageRequest = DefaultChat:FindFirstChild("SayMessageRequest")

        MessageRequest:FireServer(message, "All")
    end
end

TAS.create(Players.LocalPlayer) -- Bind our TAS to our LocalPlayer, the object we want to record.

chat("Binded TAS to LocalPlayer")
chat("H - Record/Stop | G - Load | F - Play/Pause Recording | Z/X - Forward/Backward 1 Frame | B - Rejoin")

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent then
        local key = input.KeyCode

        if key == Enum.KeyCode.H then -- Feel free to change the keybinds to whatever you'd like, this is just an example.
            recording = not recording

            if recording then
                TAS.record(fileName) -- Starts the recording, records your CFrame per frame.

                chat("Started TAS recording, press H again to stop")
            else
                TAS.stop() -- Stops and saves the TAS with the given name to the folder in the `globals.luau` file.
                paused = false

                chat("Ended TAS recording, check workspace folder")
            end
        elseif key == Enum.KeyCode.Z then
            if not holdingBackward then
                holdingBackward = true
                backwardConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    if paused then
                        TAS.backward()
                    end
                end)

                task.wait(1)
            end
        elseif key == Enum.KeyCode.X then
            if not holdingForward then
                holdingForward = true
                forwardConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    if paused then
                        TAS.forward()
                    end
                end)

                task.wait(1) -- Wait for 1 second before allowing continuous input
            end
        elseif key == Enum.KeyCode.G then
            if recording then
                chat("TAS must be ended to load")
            else
                TAS.load(fileName) -- Plays the TAS, prevemts more than 1 TAS from running at the same time.

                chat(`Now playing TAS: {fileName}`)
            end
        elseif key == Enum.KeyCode.B then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
        elseif key == Enum.KeyCode.F then
            paused = not paused

            if paused then
                TAS.pause() -- Pauses the **recording**, not when the TAS is being played.

                chat("TAS has paused, press again to unpause")
            else
                TAS.play() -- Reverse of the `.pause()` method, unpauses the recording.

                chat("TAS is now playing, press again to pause")
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent then
        local key = input.KeyCode

        if key == Enum.KeyCode.Z then
            holdingBackward = false

            if backwardConnection then
                backwardConnection:Disconnect()
                backwardConnection = nil
            end
        elseif key == Enum.KeyCode.X then
            holdingForward = false

            if forwardConnection then
                forwardConnection:Disconnect()
                forwardConnection = nil
            end
        end
    end
end)
