local Tree = Class{}

function Tree:init(x, y)
  self.x, self.y = x, y
  self.scale = 0.5 + love.math.random()/2 -- 0.42

  self.heightMap = love.image.newImageData('textures/tree3.png')
  self.iMax, self.jMax = self.heightMap:getDimensions()
  self.burned = false
end

function Tree:update(dt)
end

local color = {91/255, 145/255, 121/255}--{0,80/255,0,1}
function Tree:draw(map)
  if not self.burned then
    if not self.originHeight then
      self.originHeight = map:maxHeightOfBox(self.x, self.y, self.iMax, self.jMax)
    end

    for i = 0, self.iMax-1 do
      for j = 0, self.jMax-1 do
        local h, g, b, a = self.heightMap:getPixel(i, j)
        if h > 0 then
          map:insertIntoColorBuffer(self.x+i, self.y+j, color)
          map:insertIntoHeightMap(self.x+i, self.y+j, (h*255*self.scale), true)
        end
      end
    end
  end
end

return Tree
