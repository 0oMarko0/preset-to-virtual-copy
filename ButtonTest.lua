local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'
local LrLogger = import 'LrLogger'
local LrColor = import 'LrColor'
local LrTasks = import 'LrTasks'
local LrSystemInfo = import 'LrSystemInfo'
local LrFunctionContext = import "LrFunctionContext"
local LrApplication = import "LrApplication"
local LrView = import "LrView"
local LrBinding = import "LrBinding"
local LrDialogs = import "LrDialogs"
local LrLogger = import "LrLogger"



local logger = LrLogger("libraryLogger")
logger:enable("logfile")


-- List all preset
-- list all option in a preset
-- select them
-- Get the number of picture to create\
-- Create those with name of the preset
-- Apply preset
-- Add preset name to keyword

-- How to rename a virtual photo ?

local function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end



-- return a list of virtual copy
local function creatVirtualCopy()

end

-- Apply a preset to a virtual copy
-- rename the file when we apply the preset?
local function applyPreset()

end

-- get the resolution of the screen
local function resolution()
    local resolution = LrSystemInfo.displayInfo()
    logger:trace(dump(resolution))
end

local function showDialogue()
    LrFunctionContext.callWithContext("showDialogue", function(context)
        local view = LrView.osFactory()

        local props = LrBinding.makePropertyTable(context)

        logger:trace("Hello")

        local result = LrDialogs.presentModalDialog {
            title = "Hello push the button",
            contents = view:static_text {
                title = "Apply preset"
            },
            windowWillClose = function()
                logger:trace("CLOSE")
            end,
        }


        if result == "ok" then
            logger:trace("test")
            LrTasks.startAsyncTask(function(context)
                logger:trace("inside async")
                LrTasks.execute("C:\\Users\\Kepler\\Documents\\lrplugins\\romulus.lrdevplugin\\virtualcopy.exe")
            end)
        end
    end)
end

showDialogue()
