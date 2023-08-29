-- taken form https://github.com/musselwhizzle/Focus-Points/blob/master/focuspoints.lrdevplugin/Utils.lua
-- TODO ADD license apache 2

local LrLogger = import 'LrLogger'
local LrPrefs = import "LrPrefs"

--[[
-- Logging functions. You are provided 5 levels of logging. Wisely choose the level of the message you want to report
-- to prevent to much messages.
-- Typical use cases:
--   - logDebug - Informations diagnostically helpful to people (developers, IT, sysadmins, etc.)
--   - logInfo - Informations generally useful to log (service start/stop, configuration assumptions, etc)
--   - logWarn - Informations about an unexpected state that won't generate a problem
--   - logError - An error which is fatal to the operation
-- These methods expects 2 parameters:
--   - group - a logical grouping string (limited to 20 chars and converted to upper case) to make it easier to find the messages you are looking for
--   - message - the message to be logged
--]]
local config = LrPrefs.prefsForPlugin(nil)
config.loggingLevel = "DEBUG"

local lrLogger = LrLogger('libraryLogger')
lrLogger:enable( "logfile" )

local Logger = {}
local group = ""

function Logger.debug(...)
    log("DEBUG", group, ...)
end

function Logger.info(...)
    log("INFO", group, ...)
end

function Logger.warn(...)
    log("WARN", group, ...)
end

function Logger.error(...)
    log("ERROR", group, ...)
end

function Logger.setGroup(_group)
    group = _group
end

function log(level, _group, ...)
    local levels = {
        NONE = 0,
        ERROR = 1,
        WARN = 2,
        INFO = 3,
        DEBUG = 4
    }

    if config.loggingLevel == nil or levels[config.loggingLevel] == nil then
        config.loggingLevel = "NONE"
    end

    local configLevel = levels[config.loggingLevel]
    local msgLevel = levels[level]

    if configLevel == 0 or msgLevel == nil or msgLevel > configLevel then
        -- Unknown message log level or level set in preferences higher
        -- No need to log this one, return
        return
    end

    local str = string.format("%10s  %s", string.upper(string.sub(_group, 1, 10)), ...)
    if level == "ERROR" then
        lrLogger:error(str)
    elseif level == "WARN" then
        lrLogger:warn(str)
    elseif level == "INFO" then
        lrLogger:info(str)
    else
        lrLogger:debug(str)
    end
end

return Logger
