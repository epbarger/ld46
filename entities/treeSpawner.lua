local TreeSpawner = Class{}

local Tree = require('entities.tree')

function TreeSpawner:init(heightMap, width, height)
  self.heightMap = heightMap
  self.width = width
  self.height = height
end

function TreeSpawner:spawn(count)
  local trees = {}
  while #trees < count do
    local x = love.math.random(0, self.width)
    local y = love.math.random(0, self.height)
    local h, g, b, a = self.heightMap:getPixel(x, y)
    if h*255 < 10 then
      table.insert(trees, Tree(x, y))
    end
  end
  return trees
end

return TreeSpawner
