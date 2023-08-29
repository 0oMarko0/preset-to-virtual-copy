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

local Logger = require("Logger")
local Iter = require("Iterator")


local function showDialog()
    Logger.setGroup("PresetVirtualCopy-Dialog")
    Logger.info("test")
    LrFunctionContext.callWithContext("showDialogue", function(context)
        local view = LrView.osFactory()

        local catalog = LrApplication.activeCatalog()
        local presetFolders = LrApplication.developPresetFolders()
        local targetPhoto = catalog:getTargetPhoto()

        local props = LrBinding.makePropertyTable(context)
        props.isAllSelected = false
        props.presets = {}

        local function checkboxFromPresets(lrDevelopPresets)
            Logger.info("start")
            local checkbox = {}
            for preset in Iter.presets(lrDevelopPresets) do
                props.presets[preset:getUuid()] = {
                    name = preset:getName(),
                    uuid = preset:getUuid(),
                    isChecked = false
                }


                -- create coll of 10 preset

                --table.insert(checkbox, view:checkbox {
                --    title = preset:getName(),
                --    value = false
                --})
                checkbox[preset:getUuid()] = view:checkbox {
                    title = preset:getName(),
                    value = false
                }
            end
            Logger.info("end")

            return unpack(checkbox)
        end

        Logger.info(checkboxFromPresets(presetFolders[3]:getDevelopPresets()))

        local c = view:column {
            checkboxFromPresets(presetFolders[7]:getDevelopPresets()),
            view:static_text {
                title = "Presets to virtual copies"
            }
        }

        LrDialogs.presentModalDialog {
            title = "Test",
            contents = c
        }
    end)
end

showDialog()
