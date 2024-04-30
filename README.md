# Preset to virtual copy
This Lightroom plugin enhances your editing workflow by automatically creating multiple virtual copies of an image based on a selected preset. Additionally, it adds the preset name as a keyword, streamlining your metadata management.

![demo.gif](docs%2Fdemo.gif)

# How to Install
1. Download the plugin from the repository.
2. Follow the installation instructions for Lightroom plugins, typically by dragging the plugin file into Lightroom's plugin manager.

# Limitations
Due to limitations in the Lightroom SDK, the plugin can't create virtual copies directly. Instead, it uses a script to simulate the shortcut for creating virtual copies. The code for this script can be found [here](https://github.com/0oMarko0/keypress), along with an executable for Windows, can be found in the release package.
