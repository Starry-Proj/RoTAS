local globals = require("globals.luau")

--[[

  The TAS' main logic and functionality. If you find a bug, you can modify the TAS here.

  Clearly, animations aren't being provided to minimize file size, you can add them if you want.

  To get output on any TAS function, you can use the example given below:

  ```lua
  local response = TAS.load(fileName <string>)

  print(response.code) -- Returns either 200 (Success) or 500 (Internal Server Error), indicating something went wrong.
  print(response.message) -- Returns the message provided with the return
  ```

]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local object = nil
local recording = false
local recordingConnection = nil
local data = {}
local fileName = nil
local paused = false
local running = false
local frame = 1

local function getCharacter()
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

    if character then
        return character
    end

    return {
        code = 500,
        message = "Failed to get character"
    }
end

local function getRoot()
    local character = getCharacter()
    local root = character:FindFirstChild("HumanoidRootPart")

    if root then
        return root
    end

    return {
        code = 500,
        message = "Failed to get HumanoidRootPart"
    }
end

local function create(player)
    assert(type(player) == "userdata", `Player Object must be of type: {type(player)}`)

    local success, response = pcall(function()
        if Players:GetPlayerByUserId(player.UserId) then
            object = player
        end
    end)

    if success then
        return {
            code = 200,
            message = "Successfully linked player object"
        }
    else
        return {
            code = 500,
            message = `Failed to link with given response: {response}`
        }
    end
end

local function record(name)
    if not object then
        return {
            code = 500,
            message = "No player object linked"
        }
    end

    fileName = name
    recording = true
    data = {}
    frame = 1

    local rootPart = getRoot()

    recordingConnection = RunService.Heartbeat:Connect(function()
        if recording and not paused then
            table.insert(data, {
                CFrame = `{rootPart.CFrame}`
            })

            frame = #data
        end
    end)

    return {
        code = 200,
        message = "Started recording process"
    }
end

local function stop()
    if not recording then
        return {
            code = 500,
            message = "No TAS is being recorded"
        }
    end

    recording = false
    recordingConnection:Disconnect()

    local file = fileName

    if type(file) == "string" and not string.find(file, ".json") then
        file = `{file}.json`
    end

    if file == nil then
        file = `{globals.variables.game()}+{globals.variables.getTime()}.json`
    end

    if isfile(file) then
        delfile(file)
    end

    writefile(`{globals.files.TAS}//{file}`, HttpService:JSONEncode(data))

    return {
        code = 200,
        message = `Saved recording as: {file}.json`
    }
end

local function load(file)
    if not running then
        running = true

        local data = nil
        local newFile = file

        if type(file) == "string" and not string.find(file, ".json") then
            newFile = `{newFile}.json`
        end

        newFile = `{globals.files.TAS}//{newFile}`

        if not isfile(newFile) then
            return {
                code = 500,
                message = "File must exist to be ran"
            }
        end

        local success, response = pcall(function()
            data = HttpService:JSONDecode(readfile(newFile))
        end)

        if not success then
            return {
                code = 500,
                message = `Failed to load file with given response: {response}`
            }
        end

        local rootPart = getRoot()

        task.spawn(function()
            for _, entry in ipairs(data) do
                rootPart.CFrame = globals.functions.stringToCFrame(entry.CFrame)

                task.wait()
            end

            running = false
        end)

        return {
            code = 200,
            message = "Data loaded successfully"
        }
    else
        return {
            code = 500,
            message = "TAS is already playing, wait for the current one to finish first"
        }
    end
end

local function pause()
    local rootPart = getRoot()

    rootPart.Anchored = true
    paused = true
end

local function play()
    local rootPart = getRoot()

    rootPart.Anchored = false
    paused = false
end

local function backward() -- Move back in the recording by 1 frame, only when paused!
    if not paused then
        return {
            code = 500,
            message = "Recording must be paused before changing frames"
        }
    elseif not recording then
        return {
            code = 500,
            message = "You must be recording to change frames"
        }
    end

    local rootPart = getRoot()

    if frame > 1 then
        frame = frame - 1

        rootPart.CFrame = globals.functions.stringToCFrame(data[frame].CFrame)
    end

    return {
        code = 200,
        message = "Moved backwards in recording by 1 frame"
    }
end

local function forward() -- Move forward in the recording by 1 frame, up to latest position!
    if not paused then
        return {
            code = 500,
            message = "Recording must be paused before changing frames"
        }
    elseif not recording then
        return {
            code = 500,
            message = "You must be recording to change frames"
        }
    end

    local rootPart = getRoot()

    if frame < #data then
        frame = frame + 1

        rootPart.CFrame = globals.functions.stringToCFrame(data[frame].CFrame)
    end

    return {
        code = 200,
        message = "Moved forwards in recording by 1 frame"
    }
end

return {
    create = create,
    record = record,
    stop = stop,
    pause = pause,
    play = play,
    load = load,
    forward = forward,
    backward = backward
}
