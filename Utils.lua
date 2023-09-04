local LrSystemInfo = import "LrSystemInfo"
local LrFileUtils = import "LrFileUtils"

local Json = require("Json")
local Logger = require("Logger")

local Utils = {}

function Utils.chunk(t, size)
    local result = {}
    local j = 0
    for i = 1, #t do
        if (i - 1) % size == 0 then
            j = j + 1
            result[j] = {}
        end

        result[j][#result[j] + 1] = t[i]
    end

    return result
end

function Utils.saveTable(t, filename)
    local path = LrFileUtils.chooseUniqueFileName(filename)
    local file = io.open(filename, "w")

    if file then
        local contents = Json.encode(t)
        Logger.info("CONTENT")
        Logger.info(contents)
        file:write(contents)
        io.close(file)
        return true
    else
        return false
    end
end

function Utils.loadTable(filename)
    local path = system.pathForFile(filename, system.DocumentsDirectory)
    local contents = ""
    local myTable = {}
    local file = io.open(path, "r")

    if file then
        -- read all contents of file into a string
        local contents = file:read("*a")
        myTable = Json.decode(contents);
        io.close(file)
        return myTable
    end
    return nil
end

return Utils
