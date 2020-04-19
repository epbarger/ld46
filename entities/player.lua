local Player = Class{}

function Player:init(x, y)
  self.x = x
  self.y = y
  self.height = 20
  self.angle = 0
  self.horizon = 150
  self.distance = 600
  self.jetpackEnabled = false
  self.jetpackLanded = true
  self.dHeight = 0.1
  self.maxJetpackSeconds = 3
  self.grounded = true
  self.jetpackSeconds = self.maxJetpackSeconds
  self.jspeed = {x=0, y=0}

  self.swinging = false
  self.swingStartTime = nil
  self.swingTime = nil

  self.score = 0
  self.multiplier = 1
  self.multiplierTimer = 1.0
  self.multiplierStartTime = nil
  self.multiplierExpireTime = 8
  self.highestMultiplier = 1
  self.campfireCount = 1

  self:setHeight()
end

function Player:update(dt)
  if self.grounded and not self.jetpackEnabled and self.jetpackLanded then
    local speed = 30
    self.jetpackSeconds = self.maxJetpackSeconds

    if love.keyboard.isDown("w") then
      self.x = self.x - math.sin(self.angle) * speed * dt
      self.y = self.y - math.cos(self.angle) * speed * dt;
    elseif love.keyboard.isDown("s") then
      self.x = self.x + math.sin(self.angle) * speed * dt
      self.y = self.y + math.cos(self.angle) * speed * dt;
    end

    if love.keyboard.isDown("a") then
      self.x = self.x - math.sin(self.angle + math.pi/2) * speed * dt;
      self.y = self.y - math.cos(self.angle + math.pi/2) * speed * dt;
    elseif love.keyboard.isDown("d") then
      self.x = self.x + math.sin(self.angle + math.pi/2) * speed * dt;
      self.y = self.y + math.cos(self.angle + math.pi/2) * speed * dt;
    end

    if love.keyboard.isDown("w") or
       love.keyboard.isDown("s") or
       love.keyboard.isDown("a") or
       love.keyboard.isDown("d") then
      sound:playWalking()
    else
      sound:stopWalking()
    end

    if love.keyboard.isDown("space") then
      if not titleTransitionLock then
        self.jetpackEnabled = true
        self.jetpackLanded = false
        self.jspeed = {x=0, y=0}
      end
    else
      titleTransitionLock = false
    end

    self.dHeight = math.min(100, self.dHeight * 2) 
    self.height = self.height - self.dHeight * dt

    sound:stopJetpack()

  elseif self.jetpackEnabled and self.jetpackSeconds > 0 then
    local speed = 40
    self.jetpackSeconds = self.jetpackSeconds - dt

    local redHeight, g, b, a = map.heightMap:getPixel((self.x + map.width) % map.width, (self.y + map.height) % map.height)
    redHeight = math.max(10/255, redHeight)
    local maxHeight = redHeight * 255 + 100

    if self.height < maxHeight then
      self.height = self.height + speed * dt
      self.dHeight = 0.1
    else
      self.dHeight = math.min(40, self.dHeight * 1.6) 
      self.height = self.height - self.dHeight * dt
    end

    local accel = {x=0, y=0}
    if love.keyboard.isDown("w") then
      accel = {x=accel.x + math.sin(self.angle)*dt*-4, y=accel.y + math.cos(self.angle)*dt*-4}
    elseif love.keyboard.isDown("s") then
      accel = {x=accel.x + math.sin(self.angle)*dt*4, y=accel.y + math.cos(self.angle)*dt*4}
    end
    if love.keyboard.isDown("a") then
      accel = {x=accel.x + math.sin(self.angle + math.pi/2)*dt*-4, y=accel.y + math.cos(self.angle + math.pi/2)*dt*-4}
    elseif love.keyboard.isDown("d") then
      accel = {x=accel.x + math.sin(self.angle + math.pi/2)*dt*4, y=accel.y + math.cos(self.angle + math.pi/2)*dt*4}
    end


    self.jspeed = {x=self.jspeed.x + accel.x, y=self.jspeed.y + accel.y}
    self.x = self.x + self.jspeed.x
    self.y = self.y + self.jspeed.y
    self.jspeed.x = self.jspeed.x - self.jspeed.x * dt
    self.jspeed.y = self.jspeed.y - self.jspeed.y * dt

    self.jetpackLanded = false

    if self.jetpackSeconds < 0 or not love.keyboard.isDown("space") then
      self.jetpackEnabled = false
      self.dHeight = 0.1
    end

    sound:playJetpack()
    sound:stopWalking()

  else -- apply downward force
    self.dHeight = math.min(90, self.dHeight * 1.6) 
    self.height = self.height - self.dHeight * dt

    if not self.jetpackLanded then
      self.x = self.x + self.jspeed.x
      self.y = self.y + self.jspeed.y
      self.jspeed.x = self.jspeed.x - self.jspeed.x * 0.5 * dt
      self.jspeed.y = self.jspeed.y - self.jspeed.y * 0.5 * dt
    end

    if self.jetpackSeconds > 0 and love.keyboard.isDown("space") then
      self.jetpackEnabled = true
    end

    sound:stopJetpack()
  end

  self:checkForPause()
  self:setHeight()

  if self.swinging then
    self.swingTime = self.swingTime + dt
    if (self.swingTime - self.swingStartTime) > 0.15 then
      self.swinging = false
    end
  end

  if self.multiplierStartTime and self.multiplierStartTime > 0 then
    self.multiplierTimer = 1 - (t - self.multiplierStartTime)/self.multiplierExpireTime
    if self.multiplierTimer < 0 then
      self:endMultiplier()
    end
  end

  player.x = math.min(map.width-1, math.max(0, player.x))
  player.y = math.min(map.height-1, math.max(0, player.y))
end

local grey = colorBuilder(89, 86, 82)
local swingRange = 200
function Player:draw()
  -- sword
  love.graphics.setLineWidth(20)
  if not self.swinging then
    love.graphics.setColor(grey)
    love.graphics.line(400,50,370,h)

    love.graphics.setLineWidth(35)
    love.graphics.setColor(fireColors[love.math.random(1, #fireColors)])
    local y = yOnLine(400,50,370,h,390)
    love.graphics.line(400,50,390,y)

  else
    love.graphics.setColor(grey)
    love.graphics.line(300,50+swingRange*(self.swingTime - self.swingStartTime)*7,330,h)

    love.graphics.setLineWidth(35)
    love.graphics.setColor(fireColors[love.math.random(1, #fireColors)])
    local y = yOnLine(300,50+swingRange*(self.swingTime - self.swingStartTime)*7,330,h,320)
    love.graphics.line(300,50+swingRange*(self.swingTime - self.swingStartTime)*7,320,y)
  end


  -- jetpack charge
  if self.jetpackSeconds > 0.1 and self.jetpackSeconds < self.maxJetpackSeconds then
    love.graphics.setColor({1, 0.4, 0.4})
    love.graphics.rectangle("fill", 10, h-20, (self.jetpackSeconds/self.maxJetpackSeconds * w)-20, 10)
  end


  -- score
  love.graphics.setFont(vcrFont)
  love.graphics.setColor({1, 0.4, 0.4})
  love.graphics.print(self.score, 10, 10)


  -- warning
  local distance = self:nearestEnemyDistanceToFire()
  if distance < 100 then
    local text = "WARNING "..distance.."m"
    local width = vcrFont:getWidth(text)
    love.graphics.print(text, w/2 - width/2, 10)
    sound:playWarning()
  else
    sound:stopWarning()
  end


  -- multiplier
  if self.multiplier > 1 then
    love.graphics.setColor({1, 0.4, 0.4})
    local multiplier = "x"..self.multiplier
    local width = vcrFont:getWidth(multiplier)
    love.graphics.print(multiplier, w - width - 10, 10)

    love.graphics.stencil(function()
      love.graphics.circle("fill", w-10-width+35, 10, 50)
    end, "replace", 1)

    love.graphics.setStencilTest("less", 1)

    love.graphics.setColor({1, 0.4, 0.4})
    love.graphics.arc( "fill", w-10-width+35, 10, 60, math.pi-((math.pi/2)*(1-self.multiplierTimer)), math.pi/2)
    love.graphics.setStencilTest()
  end
end

function Player:setHeight()
  local redHeight, g, b, a = map.heightMap:getPixel((self.x + map.width) % map.width, (self.y + map.height) % map.height)
  redHeight = math.max(10/255, redHeight)
  if self.height < (redHeight * 255 + 5) then
    self.grounded = true
    self.jetpackLanded = true
    self.height = redHeight * 255 + 5
  end
end

function Player:checkForPause()
  if love.keyboard.isDown("p") then
    if not pauseTransitionLock then
      pauseTransitionLock = true
      gameState = "paused"
    end
  else
    pauseTransitionLock = false
  end
end

function Player:mouseMoved(x, y, dx, dy)
  if gameState == "playing" or gameState == "gameover"then
    self.horizon = self.horizon - 2 * dy / 2
    self.angle = self.angle - 2 * dx / 500
  end
end

function Player:mousePressed(x, y, button)
  if gameState == "playing" then
    self.swinging = true
    self.swingStartTime = t
    self.swingTime = t

    if button == 1 then
      for i, enemy in ipairs(map.enemies) do
        if not enemy.destroyed and (distanceBetweenPoints(player.x, player.y, enemy.x, enemy.y) < 18) then
          self:incrementScore()
          enemy:destroy()
          sound:playEnemyDeath()
        end
      end

    elseif button == 2 then
      for i, tree in ipairs(map.trees) do
        if not tree.burned and distanceBetweenPoints(player.x, player.y, tree.x, tree.y) < 22 then
          map:convertTreeToFire(i)
          self.campfireCount = self.campfireCount + 1
          self:endMultiplier(false)
          sound:playIgnite()
        end
      end
    end
  end
end

function Player:endMultiplier(playSound)
  if playSound == nil then playSound = true end

  if self.multiplier > self.highestMultiplier then
    self.highestMultiplier = self.multiplier
  end

  self.multiplierStartTime = nil
  self.multiplier = 1
  if playSound then
    sound:playComboLost()
  end
end

function Player:incrementScore()
  self.score = self.score + self.multiplier
  self.multiplier = self.multiplier + 1
  self.multiplierStartTime = t
end

function Player:nearestEnemyDistanceToFire()
  local lowest = 1024
  for i, enemy in ipairs(map.enemies) do
    if not enemy.destroyed then
      local d = distanceBetweenPoints(map.fire.x, map.fire.y, enemy.x, enemy.y)
      if d < lowest then lowest = d end
    end
  end
  return math.floor(lowest)
end

return Player
