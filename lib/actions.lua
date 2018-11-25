local actions = {}

function actions.doting()
    return {tile=-1, deco=-1, onJump=function(self, player) print("woo!", player.name, self.x, self.y) end}
end

return actions