local EnemyController = Class{}

local Enemy = require('entities.enemy')

function EnemyController:init()
  self.timeUntilSpawn = 4
  Timer.every(self.timeUntilSpawn, function()
    self:spawnEnemy()
  end)

  for i = 1, 8 do self:spawnEnemy() end
end

function EnemyController:update(dt)
end

function EnemyController:spawnEnemy()
  local positionDetermined = false
  local newX = nil
  local newY = nil

  while not positionDetermined do
    local tryAgain = false
    newX = love.math.random(0, map.width)
    newY = love.math.random(0, map.height)

    if not (distanceBetweenPoints(newX, newY, map.fire.x, map.fire.y) < 200) then
      for i, enemy in ipairs(map.enemies) do
        if not enemy.destroyed and (distanceBetweenPoints(newX, newY, enemy.x, enemy.y) < 20) then
          tryAgain = true
          break
        end
      end

      if not tryAgain then
        positionDetermined = true
      end
    end
  end


  local newEnemy = Enemy(newX, newY)

  if #map.enemies == 30 then
    for i, enemy in ipairs(map.enemies) do
      if enemy.destroyed then
        map.enemies[i] = newEnemy
        break
      end
    end
  else
    table.insert(map.enemies, newEnemy)
  end
end

return EnemyController
