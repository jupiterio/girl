local detect = {}

local ShapeDetector = require "thirdparty.ShapeDetector"

-- New abilities will be learnt as you go
detect.detector = ShapeDetector.new({}, {threshold = 0.75, rotatable = false})
detect.detected = ""

local maxDistance = 1000
local totaldx
local totaldy
local totaldistance = 0

function detect.getInk()
    return totaldistance / maxDistance
end

function detect.draw()
    local _oWidth = love.graphics.getLineWidth()
    local _oStyle = love.graphics.getLineStyle()
    local _oJoin = love.graphics.getLineJoin()

    love.graphics.setLineWidth(10)
    love.graphics.setLineStyle("smooth")
    love.graphics.setLineJoin("bevel")
    if detect.stroke and #detect.stroke > 2 then
        local result = {}
        for _,v in ipairs(detect.stroke) do
            table.insert(result, v.x)
            table.insert(result, v.y)
        end
        love.graphics.line(result)
    end

    love.graphics.setLineWidth(_oWidth)
    love.graphics.setLineStyle(_oStyle)
    love.graphics.setLineJoin(_oJoin)
end

local mousedown = false
function detect.mousepressed(x, y, button, istouch, presses)
    mousedown = true

    totaldx = 0
    totaldy = 0
    totaldistance = 0

    detect.stroke = {}
    table.insert(detect.stroke, {x=x, y=y})
end

function detect.mousemoved(x, y, dx, dy, istouch)
    if mousedown then
        totaldx = totaldx + dx
        totaldy = totaldy + dy

        local distance = math.sqrt(totaldx*totaldx + totaldy*totaldy)

        if (totaldistance < maxDistance and distance > 10) then
            table.insert(detect.stroke, {x=x, y=y})

            totaldistance = totaldistance + distance
            totaldx = 0
            totaldy = 0
        end
    end
end

function detect.mousereleased(x, y, button, istouch, presses)
    mousedown = false

    local detected = detect.detector:spot({unpack(detect.stroke)})
    detect.detected = detected.pattern or ""
end

return detect