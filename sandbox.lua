-- Iterator is implemented by using a closure and a factory
--local logger = require("Logger")
--
--logger.info("helo")
--
--function value(t)
--    local i = 0
--    local j = 0
--    return function()
--        -- this increment the closure state
--        i = i + 1
--        j = j + 1
--        return j, t[i]
--    end
--end
--
--
--t = {1,2,3,4,55}
--for j, element in value(t) do
--    print(j, element)
--end


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

local test = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}

function chunk(t, s)
    --we've reach the end
    local result = {}
    local j = 0
    for i = 1, #t do
        if (i-1) % s == 0 then
            j = j + 1
            result[j] = {}
        end

        result[j][#result[j]+1] = t[i]
    end

    return result
end

function IterChunk(chunk)
    local i = 0

    return function()
        i = i + 1
        return chunk[i]
    end
end

local t = chunk(test, 5)
print(type(t))
for preset in IterChunk(t) do
    print(print_table(preset))
end
