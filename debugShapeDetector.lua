local debugSD = {}

local ShapeDetector = require "lib.ShapeDetector"
local shapes = require "lib.sampleShapes"
local strictDetector = ShapeDetector.new({}, {threshold = 0.8, rotatable = false})
local detector = ShapeDetector.new({}, {threshold = 0.8})

local touch = {}
local whatisit = ""
local learntShapes = 0
local shapeNames = {"w", "spiral", "caret", "v", "vert", "hor", "circle", "z", "loop", "heart"}
function debugSD.draw()
    for k,v in ipairs({p=detector.patterns}) do
        local stroke = v.points
        if #stroke > 2 then
            local result = {}
            for _,v in ipairs(stroke) do
                table.insert(result, v.x/4+k*20)
                table.insert(result, v.y/4+k*20)
            end
            love.graphics.line(result)
        end
    end
    love.graphics.print(whatisit, 0, 0)

    if #touch > 2 then
        local strictStroke = ShapeDetector.Stroke.new(false, {unpack(touch)}).points
        local stroke = ShapeDetector.Stroke.new(true, {unpack(touch)}).points
        if #stroke > 2 then
            local result = {}
            for _,v in ipairs(stroke) do
                table.insert(result, v.x+200)
                table.insert(result, v.y+200)
            end
            love.graphics.line(result)
            local result = {}
            for _,v in ipairs(strictStroke) do
                table.insert(result, v.x+200)
                table.insert(result, v.y+200)
            end
            love.graphics.line(result)
            local result = {}
            print(#touch)
            for _,v in ipairs(touch) do
                table.insert(result, v.x)
                table.insert(result, v.y)
            end
            print(#result)
            love.graphics.line(result)
        end
    end
end

function debugSD.touchpressed(id, x, y)
    touch = {}
    whatisit = ""
    table.insert(touch, {x=x, y=y})
end

function debugSD.touchmoved(id, x, y)
    table.insert(touch, {x=x, y=y})
end

function debugSD.touchreleased(id, x, y)
    table.insert(touch, {x=x, y=y})
    if learntShapes < #shapeNames then
        learntShapes = learntShapes + 1
        detector:learn(tostring(shapeNames[learntShapes]), {unpack(touch)})
        strictDetector:learn(tostring(shapeNames[learntShapes]), {unpack(touch)})
    else
        local detected = detector:spot({unpack(touch)})
        whatisit = (detected.pattern or "nothing") .. " " .. (detected.score or "")
        local detected = strictDetector:spot({unpack(touch)})
        whatisit = whatisit .. "\n" .. (detected.pattern or "nothing") .. " " .. (detected.score or "")
    end
end

return debugSD