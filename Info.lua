return {
    LrSdkVersion = 5.0,
    LrSdkMinimumVersion = 5.0,
    LrToolkitIdentifier = "com.romulus.sdk.comparator",
    LrPluginName = "Presets to virtual copies",

    LrLibraryMenuItems = {
        {
            title = "Create virtual copies",
            file = "PresetsToVirtualCopiesDialog.lua",
            enabledWhen = "photosSelected",
        },
    },
}
