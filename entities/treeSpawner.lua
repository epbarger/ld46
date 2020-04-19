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
    table.insert(trees, self:spawnTree(trees))
  end
  return trees
end

function TreeSpawner:spawnTree(trees)
  local positionDetermined = false
  local newX = nil
  local newY = nil

  while not positionDetermined do
    local breakWhile = false
    newX = love.math.random(0, self.width)
    newY = love.math.random(0, self.height)
    local h, g, b, a = self.heightMap:getPixel(newX, newY)

    if h*255 < 10 then
      for i, tree in ipairs(trees) do
        if (distanceBetweenPoints(newX, newY, tree.x, tree.y) < 50) then
          breakWhile = true
          break
        end
      end

      if breakWhile then break end
      positionDetermined = true 
    end
  end

  return Tree(newX, newY)
end

return TreeSpawner
