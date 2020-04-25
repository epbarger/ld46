local Fire = Class{}

function Fire:init(x, y)
  self.x, self.y = x, y
  self.scale = 0.4

  self.heightMap = love.image.newImageData('textures/fire2.png')
  self.colorMap = love.image.newImageData('textures/fire2c.png')
  self.iMax, self.jMax = self.heightMap:getDimensions()
  self.iShift = math.floor(self.iMax / 2)
  self.jShift = math.floor(self.jMax / 2)
  self.corrupted = false

  self.random = love.math.newRandomGenerator(love.math.random() * 100000000)
  self.randomState = self.random:getState()

  Timer.every(1/20, function()
    self.random:setSeed(love.math.random() * 100000000)
    self.randomState = self.random:getState()
  end)
end

function Fire:update(dt)
end

fireColors = {
  {1, 0.4, 0.4},
  {1, 0.2, 0.2},
  {1, 0, 0,},
  {233/255, 115/255, 40/255},
  {233/255, 150/255, 40/255},
  {0.5,0.5,0.5},
}

function Fire:draw(map)
  self.random:setState(self.randomState)

  if not self.originHeight then
    self.originHeight = map:maxHeightOfBox(self.x-self.iMax, self.y-self.jMax, self.iMax, self.jMax)
  end

  for i = 0, self.iMax-1 do
    for j = 0, self.jMax-1 do
      local h, g, b, a = self.heightMap:getPixel(i, j)
      local r, g, b, a = self.colorMap:getPixel(i, j)
      if h > 0 then
        local x = self.x+i-self.iShift
        local y = self.y+j-self.jShift
        if r > 0.99 and g > 0.99 and b > 0.99 then
          map:insertIntoColorBuffer(x, y, self:color())
        else
          map:insertIntoColorBuffer(x, y, {r,g,b,a}) --
        end

        if i >= 2 and i <= 7 and j >= 2 and j <= 7 then
          map:insertIntoHeightMap(x, y, (h*255+self.random:random(0, 10))*self.scale, true)
        else
          map:insertIntoHeightMap(x, y, (h*255*self.scale), true)
        end
      end
    end
  end
end

function Fire:color()
  if self.corrupted then
    return corruptionColors[self.random:random(1, #corruptionColors)]
  else
    return fireColors[self.random:random(1, #fireColors)]
  end
end

return Fire
