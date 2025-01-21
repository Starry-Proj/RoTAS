local TAS = require("framework.luau")

local fileName = "MyTAS" -- This is the only variable you'll want to configure.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")

local recording = false
local paused = false

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
chat("F - Record/Stop | G - Load | H - Play/Pause Recording")

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent then
        local key = input.KeyCode

        if key == Enum.KeyCode.F then -- Feel free to change the keybinds to whatever you'd like, this is just an example.
            recording = not recording

            if recording then
                TAS.record(fileName) -- Starts the recording, records your CFrame per frame.

                chat("Started TAS recording, press F again to stop")
            else
                TAS.stop() -- Stops and saves the TAS with the given name to the folder in the `globals.luau` file.
                paused = false

                chat("Ended TAS recording, check workspace folder")
            end
        elseif key == Enum.KeyCode.G then
            if recording then
                chat("TAS must be ended to load")
            else
                TAS.load(fileName) -- Plays the TAS, prevemts more than 1 TAS from running at the same time.

                chat(`Now playing TAS: {fileName}`)
            end
        elseif key == Enum.KeyCode.H then
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
