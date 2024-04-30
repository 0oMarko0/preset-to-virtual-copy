-- https://github.com/musselwhizzle/Focus-Points/blob/master/focuspoints.lrdevplugin/Utils.lua
--[[
  Copyright 2016 Whizzbang Inc

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
--]]

local LrLogger = import("LrLogger")
local LrPrefs = import("LrPrefs")
local json = require("Json")

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
config.loggingLevel = "INFO"

local lrLogger = LrLogger("libraryLogger")
lrLogger:enable("logfile")

local Logger = {}
local group = ""

function Logger.table(node)
    if type(node) ~= "table" then
        log("ERROR", group, "Logger.table with a value that is not a table")
        log("ERROR", group, node)
        return
    end

    if node == null then
        log("ERROR", group, "Logger.table with a null value")
        return
    end

    local function tab(amt)
        local str = ""
        for i = 1, amt do
            str = str .. "\t"
        end
        return str
    end

    local cache, stack, output = {}, {}, {}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k, v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k, v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then
                if string.find(output_str, "}", output_str:len()) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str, "\n", output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output, output_str)
                output_str = ""

                local key
                if type(k) == "number" or type(k) == "boolean" then
                    key = "[" .. tostring(k) .. "]"
                else
                    key = "['" .. tostring(k) .. "']"
                end

                if type(v) == "number" or type(v) == "boolean" then
                    output_str = output_str .. tab(depth) .. key .. " = " .. tostring(v)
                elseif type(v) == "table" then
                    output_str = output_str .. tab(depth) .. key .. " = {\n"
                    table.insert(stack, node)
                    table.insert(stack, v)
                    cache[node] = cur_index + 1
                    break
                else
                    output_str = output_str .. tab(depth) .. key .. " = '" .. tostring(v) .. "'"
                end

                if cur_index == size then
                    output_str = output_str .. "\n" .. tab(depth - 1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if cur_index == size then
                    output_str = output_str .. "\n" .. tab(depth - 1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if #stack > 0 then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output, output_str)
    log("DEBUG", group, table.concat(output))
end

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
        DEBUG = 4,
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
