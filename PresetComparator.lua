local LrFunctionContext = import "LrFunctionContext"
local LrApplication = import "LrApplication"
local LrView = import "LrView"
local LrBinding = import "LrBinding"
local LrDialogs = import "LrDialogs"
local LrTasks = import "LrTasks"

local Logger = require("Logger")


local maxPreset = 10;

Logger.setGroup("PresetComparator")

function print_table(node)
    -- to make output beautiful
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
                if (string.find(output_str, "}", output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str, "\n", output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output, output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "[" .. tostring(k) .. "]"
                else
                    key = "['" .. tostring(k) .. "']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. tab(depth) .. key .. " = " .. tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. tab(depth) .. key .. " = {\n"
                    table.insert(stack, node)
                    table.insert(stack, v)
                    cache[node] = cur_index + 1
                    break
                else
                    output_str = output_str .. tab(depth) .. key .. " = '" .. tostring(v) .. "'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. tab(depth - 1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. tab(depth - 1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output, output_str)
    return table.concat(output)
end

local function presetFromFolder(view, presetFolder)
    local presets = presetFolder:getDevelopPresets()

    tmp = {}
    for k, v in pairs(presets) do
        tmp[k] = view:checkbox {
            title = v:getName(),
            value = LrView.bind(v:getUuid()),
        }
        if k == maxPreset then break end
    end

    return unpack(tmp)

    --for k, v in pairs(presets) do
    --    Logger.setGroup(presetFolder:getName())
    --    Logger.info(v:getName())
    --    if k == 10 then return end
    --end
end

local function presetFoldersToGroupBox(view, presetFolders)
    local groupBox = {}
    for k, v in pairs(presetFolders) do
        Logger.info(type(v))
        groupBox[k] = view:group_box {
            title = v:getName(),
            show_title = true,
            presetFromFolder(view, v)
        }
    end
    return unpack(groupBox)
end

local function showDialog()
    Logger.info("test", "une", "deux")
    LrFunctionContext.callWithContext("showDialog", function(context)
        local view = LrView.osFactory()

        local catalog = LrApplication.activeCatalog()
        local presetFolders = LrApplication.developPresetFolders()
        local targetPhoto = catalog:getTargetPhoto()

        -- Create a bindable table.  Whenever a field in this table changes
        -- then notifications will be sent.
        local props = LrBinding.makePropertyTable(context)
        props.checkbox = {}

        local is = LrBinding.makePropertyTable(context);
        is.all = false

        presets = {}


        -- this create each checkbox
        -- add a All checkbox
        local function list(lrDevelopPresets)
            tmp = {}
            for k, v in pairs(lrDevelopPresets) do
                props.checkbox[v:getUuid()] = false
                presets[v:getUuid()] = {
                    name = v:getName(),
                    uuid = v:getUuid(),
                    setting = v:getSetting(),
                }
                tmp[k] = view:checkbox {
                    title = v:getName(),
                    value = LrView.bind(v:getUuid()),
                }
            end

            return unpack(tmp)
        end


        local function presetsFolderToGroupBox(presetsFolder)

        end

        -- this print each preset folder in a group box


        local function myCalledFunction()
            Logger.info("Value change")
            if is.all then
                for k, v in pairs(props.checkbox) do
                    if type(v) == "boolean" then
                        props.checkbox[k] = false
                    end
                end
            end
        end

        is:addObserver("all", myCalledFunction)


        local c = view:column {
            bind_to_object = props.checkbox,
            view:checkbox {
                bind_to_object = is,
                title = "all",
                value = LrView.bind("all")
            },
            list(presetFolders[3]:getDevelopPresets()),
        }

        local t = view:column {
            presetFoldersToGroupBox(view, presetFolders)
        }

        local result = LrDialogs.presentModalDialog {
            title = "Custom Dialog",
            contents = t
        }

        if result == "oko" then
            local toApply = {}
            local i = 1;
            LrTasks.startAsyncTask(function()
                if is.all then
                    for k, v in pairs(props.checkbox) do
                        if type(v) == "boolean" then
                            toApply[i] = presets[k]
                            i = i + 1
                            LrTasks.startAsyncTask(function(context)
                                LrTasks.execute(
                                    "C:\\Users\\Kepler\\Documents\\lrplugins\\romulus.lrdevplugin\\virtualcopy.exe")
                            end)
                            -- Plugin setting
                            LrTasks.sleep(0.2)
                        end
                    end
                else
                    for k, v in pairs(props.checkbox) do
                        if type(v) == "boolean" and v == true then
                            toApply[i] = presets[k]
                            i = i + 1
                            LrTasks.startAsyncTask(function(context)
                                LrTasks.execute(
                                    "C:\\Users\\Kepler\\Documents\\lrplugins\\romulus.lrdevplugin\\virtualcopy.exe")
                            end)
                            -- Plugin settings
                            LrTasks.sleep(0.2)
                        end
                    end
                end

                --

                local copy = targetPhoto:getRawMetadata("countVirtualCopies")
                Logger.info("COPY: ", copy)
                Logger.info("i: ", i)

                local timeout = 0

                -- I think that's useless since the program bloc until the execute is done
                while (copy ~= (i - 1)) do
                    copy = targetPhoto:getRawMetadata("countVirtualCopies")
                    LrTasks.sleep(1)
                    timeout = timeout + 1
                    Logger.info("COPY: ", copy)
                    Logger.info("timeout: ", timeout)

                    if timeout == 10 then
                        return
                    end
                end


                local function keywordExist(keyword)
                    local keywords = catalog:getKeywords()
                    for _, v in ipairs(keywords) do
                        if keyword == v:getName() then
                            return true, v
                        end
                    end

                    return false
                end

                virtualCopies = targetPhoto:getRawMetadata("virtualCopies")
                copy = targetPhoto:getRawMetadata("countVirtualCopies")
                Logger.info("COPY", copy)

                catalog:withWriteAccessDo("test", function(context)
                    for j = 1, copy do
                        virtualCopies[j]:applyDevelopSettings(toApply[j].setting)
                        virtualCopies[j]:setRawMetadata("copyName", toApply[j].name)
                        -- Create keyword if it does not exist
                        local exKeyword, keya = keywordExist(toApply[j].name)

                        if not exKeyword then
                            local k = catalog:createKeyword(toApply[j].name)
                            virtualCopies[j]:addKeyword(k)
                        else
                            Logger.info(keya:getName())
                            virtualCopies[j]:addKeyword(keya)
                        end
                    end
                end)
            end)
        end
    end) -- end main function
end

showDialog()
