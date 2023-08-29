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


local function showDialogue()
    LrFunctionContext.callWithContext("showDialogue", function(context)
        local view = LrView.osFactory()

        local props = LrBinding.makePropertyTable(context)

        props.text = {
            test = false,
            test2 = true
        }

        props.slider = 0

        local c = view:column {
            bind_to_object = props,
            spacing = view:control_spacing(),

            view:static_text {
                title = LrView.bind({
                    bind_to_object = props.text,
                    key = "title",
                    transform = function(value, fromModel)
                        logger:trace("value", value, " -- ", "fromModel", fromModel)
                        value = "YOLO"
                        return "yuyu"
                    end
                })
            }
        }

        LrDialogs.presentModalDialog {
            title = "Test",
            contents = c
        }
    end)
end

showDialogue()
