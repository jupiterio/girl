local csv = {}

function split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t
end

function csv.parse(str)
    local grid = split(str, "\n")
    for y = 1, #grid do
        grid[y] = split(grid[y], ",")
        if #grid[y] == 0 then grid[y] = nil end
        for x = 1, #grid[y] do
            grid[y][x] = tonumber(grid[y][x]) or grid[y][x]
        end
    end
    return grid
end

function csv.stringify(grid)
    local result = {}
    for y = 1, #grid do
        result[y] = table.concat(grid[y], ",")
    end
    result = table.concat(result, "\n")
    return result
end

return csv