
local Iter = {}

function Iter.presets(lrDevelopPresets)
    local i = 0

    return function()
        i = i + 1
        return lrDevelopPresets[i]
    end
end

return Iter
