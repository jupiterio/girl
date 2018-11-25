local actions = {}

function actions.test()
    return {
        tile = -1,
        deco = -1,
        onJump = function(self) print("activated!", self.x, self.y) end,
        onVisible = function(self) print("visible!", self.x, self.y) end,
        onTouched = function(self) print("touched!", self.x, self.y) end
    }
end

return actions