local builder = {}

local ShapeDetector = require "thirdparty.ShapeDetector"
ShapeDetector.new({}, {threshold = 0.5, rotatable = false, nbSamplePoints = 32})

local touch
function builder:draw()
    if touch and #touch > 2 then
        local result = {}
        for _,v in ipairs(touch) do
            table.insert(result, v.x)
            table.insert(result, v.y)
        end
        love.graphics.setColor(0, 0, 0)
        love.graphics.line(unpack(result))
    end
end

local totaldx = 0
local totaldy = 0
local mousedown = false
function builder:mousepressed(x, y, button, istouch, presses)
    mousedown = true

    touch = {}
    table.insert(touch, {x=x, y=y})
end

function builder:mousemoved(x, y, dx, dy, istouch)
    if mousedown then
        totaldx = totaldx + dx
        totaldy = totaldy + dy

        local distance = math.sqrt(totaldx*totaldx + totaldy*totaldy)
        if (distance > 25) then
            table.insert(touch, {x=x, y=y})

            totaldx = 0
            totaldy = 0
        end
    end
end

local gestureString = {}
function builder:mousereleased(x, y, button, istouch, presses)
    mousedown = false

    table.insert(touch, {x=x, y=y})

    touch = ShapeDetector.Stroke.new(false, touch).points

    for k,v in ipairs(touch) do
        gestureString[k] = "{x=" .. tostring(math.floor(v.x)) .. ",y=" .. tostring(math.floor(v.y)) .. "}"
        v.x = v.x + 200
        v.y = v.y + 200
    end
    print("GESTURE")
    print("{" .. table.concat(gestureString, ",") .. "}")
end

return builder