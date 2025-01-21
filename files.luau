local globals = require("globals.luau")

local function files() -- Running this function will just create the directory if not already existant.
    local project = globals.project
    local TAS = `{project}//TAS`

    if not isfolder(project) then
        makefolder(project)
    end

    makefolder(TAS)
end

return {
    files = files
}
