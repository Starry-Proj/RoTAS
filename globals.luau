local MarketplaceService = game:GetService("MarketplaceService")

local variables = {
    project = "RoTAS", -- THe name of your TAS project, NOT the file's name.
    version = "1.0.a",

    getTime = function()
        return os.time()
    end,

    game = function()
        return MarketplaceService:GetProductInfo(game.PlaceId).Name
    end
}

local functions = {
    stringToCFrame = function(data)
        local components = {}

        for value in string.gmatch(data, "([^,]+)") do
            table.insert(components, tonumber(value))
        end

        if #components == 12 then
            return CFrame.new(
                components[1], components[2], components[3],
                components[4], components[5], components[6],
                components[7], components[8], components[9],
                components[10], components[11], components[12]
            )
        else
            return {
                code = 500,
                message = "Invalid CFrame string format"
            }
        end
    end
}

local files = {
    TAS = `{variables.project}//TAS` -- The folder to which your TAS files will be saved to.
}

return {
    variables = variables,
    functions = functions,
    files = files
}
