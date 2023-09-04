local Iter = {}

function Iter.list(list)
    local i = 0

    return function()
        i = i + 1
        return list[i], i
    end
end

return Iter
