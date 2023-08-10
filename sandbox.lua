-- Iterator is implemented by using a closure and a factory

function value(t)
    local i = 0
    local j = 0
    return function()
        -- this increment the closure state
        i = i + 1
        j = j + 1
        return j, t[i]
    end
end


t = {1,2,3,4,55}
for j, element in value(t) do
    print(j, element)
end
