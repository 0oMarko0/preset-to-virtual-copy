local LrApplication = import("LrApplication")
local LrBinding = import("LrBinding")
local LrColor = import("LrColor")
local LrDialogs = import("LrDialogs")
local LrFunctionContext = import("LrFunctionContext")
local LrLogger = import("LrLogger")
local LrPathUtils = import("LrPathUtils")
local LrSystemInfo = import("LrSystemInfo")
local LrTasks = import("LrTasks")
local LrView = import("LrView")

local Logger = require("Logger")
local Iter = require("Iterator")
local Utils = require("Utils")

local config = {
    maxPreset = 40,
    chunkSize = 5,
    scrolledViewHeightRatio = 0.75,
    scrolledViewWidthRatio = 0.50,
    virtualCopyPath = LrPathUtils.child(_PLUGIN.path, "copy.exe"),
    sleepBetweenCopy = 0.2,
}

local function showDialog()
    Logger.setGroup("showDialog")

    Logger.debug("Configuration")
    Logger.table(config)

    LrFunctionContext.callWithContext("showDialogue", function(context)
        local view = LrView.osFactory()

        local catalog = LrApplication.activeCatalog()
        local presetFolders = LrApplication.developPresetFolders()
        local targetPhoto = catalog:getTargetPhoto()
        local displayInfo = {}

        for display in Iter.list(LrSystemInfo:displayInfo()) do
            if display.hasAppMain then
                displayInfo = display
            end
        end

        Logger.debug("Display information")
        Logger.table(displayInfo)

        local props = LrBinding.makePropertyTable(context)
        props.isAllSelected = false
        props.presets = {}

        local function checkboxFromPresets(lrDevelopPresets)
            local col = {}
            local presetChunks = Utils.chunk(lrDevelopPresets, config.chunkSize)
            local total = 0
            for presetChunk in Iter.list(presetChunks) do
                local checkbox = {}
                for preset in Iter.list(presetChunk) do
                    if total > config.maxPreset then
                        return col
                    end
                    total = total + 1
                    props.presets[preset:getUuid()] = {
                        name = preset:getName(),
                        uuid = preset:getUuid(),
                        setting = preset:getSetting(),
                        isChecked = false,
                    }
                    table.insert(
                        checkbox,
                        view:checkbox({
                            title = preset:getName(),
                            value = LrView.bind({
                                bind_to_object = props.presets[preset:getUuid()],
                                key = "isChecked",
                            }),
                        })
                    )
                end

                table.insert(col, view:column(checkbox))
            end
            return col
        end

        local function groupBoxFromPresetFolders(presetFolders)
            local groupBox = {}
            for presetFolder in Iter.list(presetFolders) do
                table.insert(
                    groupBox,
                    view:group_box({
                        title = presetFolder:getName(),
                        show_title = true,
                        view:row(checkboxFromPresets(presetFolder:getDevelopPresets())),
                    })
                )
            end
            return groupBox
        end

        local svHeight = displayInfo["height"] * config.scrolledViewHeightRatio
        local svWidth = displayInfo["width"] * config.scrolledViewWidthRatio

        Logger.debug("scrolled_view['height']=" .. svHeight)
        Logger.debug("scrolled_view['width']=" .. svWidth)

        local c = view:scrolled_view({
            height = svHeight,
            width = svWidth,
            background_color = LrColor(0.95),
            horizontal_scroller = false,
            view:column(groupBoxFromPresetFolders(presetFolders)),
        })

        local result = LrDialogs.presentModalDialog({
            title = "Preset to virtual copies",
            contents = c,
        })

        if result == "ok" then
            local toApply = {}
            local i = 1
            LrTasks.startAsyncTask(function()
                Logger.info("START-")
                for _, preset in pairs(props.presets) do
                    if preset.isChecked then
                        Logger.info(preset.name)
                        toApply[i] = preset
                        i = i + 1
                        LrTasks.startAsyncTask(function(_)
                            LrTasks.execute(config.virtualCopyPath)
                        end)
                        LrTasks.sleep(config.sleepBetweenCopy)
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

                local virtualCopies = targetPhoto:getRawMetadata("virtualCopies")
                local countVirtualCopies = targetPhoto:getRawMetadata("countVirtualCopies")
                Logger.info("Number of virtual copies created: " .. countVirtualCopies)

                catalog:withWriteAccessDo("setKeywordsToPhoto", function(_)
                    for j = 1, countVirtualCopies do
                        virtualCopies[j]:applyDevelopSettings(toApply[j].setting)
                        virtualCopies[j]:setRawMetadata("copyName", toApply[j].name)

                        local exKeyword, keyword = keywordExist(toApply[j].name)
                        if not exKeyword then
                            local newKeyword = catalog:createKeyword(toApply[j].name)
                            virtualCopies[j]:addKeyword(newKeyword)
                        else
                            Logger.info(keyword:getName())
                            virtualCopies[j]:addKeyword(keyword)
                        end
                    end
                end)
            end)
        end
    end)
end

showDialog()
