return {
    LrSdkVersion = 5.0,
    LrSdkMinimumVersion = 5.0,
    LrToolkitIdentifier = "com.romulus.sdk.comparator",
    LrPluginName = "Presets to virtual copies",

    LrLibraryMenuItems = {
        {
            title = "Compare photo with presets",
            file = "PresetComparator.lua",
            enabledWhen = "photosSelected",
        },
        {
            title = "Button test",
            file  = "ButtonTest.lua",
            enabledWhen = "photosSelected"
        },
        {
            title = "Create virtual copies",
            file  = "PresetsToVirtualCopiesDialog.lua",
            enabledWhen = "photosSelected"
        }
    }
}
