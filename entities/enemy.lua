local Enemy = Class{}

function Enemy:init(x, y, speed)
  self.x, self.y = x, y

  self.heightMap = love.graphics.newCanvas(3,3)
  love.graphics.setCanvas(self.heightMap)
  love.graphics.clear(15/255,0,0,1)
  love.graphics.setCanvas()
  self.heightMap = self.heightMap:newImageData()
  self.scale = {1}

  self.iMax, self.jMax = self.heightMap:getDimensions()
  self.iShift = math.floor(self.iMax / 2)
  self.jShift = math.floor(self.jMax / 2)

  self.speed = speed or 16
  self.destroyed = false
  self.colors = corruptionColors

  self.random = love.math.newRandomGenerator(love.math.random() * 100000000)
  self.randomState = self.random:getState()

  Timer.every(1/20, function()
    self.random:setSeed(love.math.random() * 100000000)
    self.randomState = self.random:getState()
  end)
end

function Enemy:update(dt)
  if not self.destroyed then
    normal = Vector(map.fire.x - self.x, map.fire.y - self.y):normalizeInplace()
    self.x = self.x + normal.x * self.speed * dt
    self.y = self.y + normal.y * self.speed * dt
  end

  if not map.fire.corrupted then
    if distanceBetweenPoints(self.x, self.y, map.fire.x, map.fire.y) < 2 then
      map.fire.corrupted = true
      save:updateHighscore(player.score)
      gameState = "gameover"
      sound:playGameOver()
      titleTransitionLock = true
    end
  end
end

corruptionColors = {
  { 0.5,0.5,0.7},
  { 0.6, 0.6, 0.8},
  { 0.7, 0.7, 0.9}
}
function Enemy:draw(map)
  self.random:setState(self.randomState)

  if self.scale[1] > 0 then
    for i = 0, self.iMax-1 do
      for j = 0, self.jMax-1 do
        local h, g, b, a = self.heightMap:getPixel(i, j)
        if h > 0 then
          map:insertIntoColorBuffer(self.x+i-self.iShift, self.y+j-self.jShift, self.colors[self.random:random(1, #self.colors)])
          map:insertIntoHeightMap(self.x+i-self.iShift, self.y+j-self.jShift, ((h*255) + self.random:random(0, 10) - 5)*self.scale[1], true)
        end
      end
    end
  end
end

function Enemy:destroy()
  self.destroyed = true
  self.colors = fireColors
  Timer.tween(0.35, self.scale, {0}, 'out-quart')
end

return Enemy
