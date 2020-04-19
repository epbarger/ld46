local Snow = Class{}

function Snow:init(count, size, color, hmultiplier, wmultiplier, speed)
  self.vOffset = 0
  self.hOffset = 0
  self.count = count
  self.size = size
  self.color = color
  self.hmultiplier = hmultiplier
  self.wmultiplier = wmultiplier
  self.speed = speed
  self.canvas = love.graphics.newCanvas(w, h)
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear(1,1,1,0)
  love.graphics.setColor(1,1,1)
  for i = 0, self.count do
    love.graphics.rectangle("fill", love.math.random(0,w), love.math.random(0,h), self.size, self.size)
  end
  love.graphics.setCanvas()

  self.lastPlayerHeight = nil
end

function Snow:update(dt, player)
  if not self.lastPlayerHeight then self.lastPlayerHeight = player.height end

  self.vOffset = (self.vOffset - ((self.lastPlayerHeight - player.height) * self.hmultiplier) + (self.speed - math.abs(player.horizon - 150)/20) * dt) % h
  self.hOffset = player.angle/self.wmultiplier * w % w

  self.lastPlayerHeight = player.height 
end

function Snow:draw()
  love.graphics.setColor(self.color)

  love.graphics.draw(self.canvas, self.hOffset-w, self.vOffset-h)
  love.graphics.draw(self.canvas, self.hOffset-w, self.vOffset)

  love.graphics.draw(self.canvas, self.hOffset, self.vOffset-h)
  love.graphics.draw(self.canvas, self.hOffset, self.vOffset)

  love.graphics.draw(self.canvas, self.hOffset+w, self.vOffset-h)
  love.graphics.draw(self.canvas, self.hOffset+w, self.vOffset)
end

return Snow
