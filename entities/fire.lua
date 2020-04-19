local Fire = Class{}

function Fire:init(x, y)
  self.x, self.y = x, y
  self.scale = 0.4

  self.heightMap = love.image.newImageData('textures/fire2.png')
  self.colorMap = love.image.newImageData('textures/fire2c.png')
  self.iMax, self.jMax = self.heightMap:getDimensions()
  self.corrupted = false
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
  if not self.originHeight then
    self.originHeight = map:maxHeightOfBox(self.x-self.iMax, self.y-self.jMax, self.iMax, self.jMax)
  end

  for i = 0, self.iMax-1 do
    for j = 0, self.jMax-1 do
      local h, g, b, a = self.heightMap:getPixel(i, j)
      local r, g, b, a = self.colorMap:getPixel(i, j)
      if h > 0 then
        if r > 0.99 and g > 0.99 and b > 0.99 then
          map:insertIntoColorBuffer(self.x+i, self.y+j, self:color())
        else
          map:insertIntoColorBuffer(self.x+i, self.y+j, {r,g,b,a}) --
        end
        map:insertIntoHeightMap(self.x+i, self.y+j, (h*255*self.scale), true)
      end
    end
  end
end

function Fire:color()
  if self.corrupted then
    return corruptionColors[love.math.random(1, #corruptionColors)]
  else
    return fireColors[love.math.random(1, #fireColors)]
  end
end

return Fire
