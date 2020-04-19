local Pause = Class{}

function Pause:init()
end

function Pause:update()
  if love.keyboard.isDown("p") then
    if not pauseTransitionLock then
      pauseTransitionLock = true
      gameState = "playing"
    end
  else
    pauseTransitionLock = false
  end
end

local spaceToStart = "PRESS P TO RESUME"
local spaceToStartWidth = vcrFont:getWidth(spaceToStart)
function Pause:draw()
  love.graphics.setColor({1, 0.4, 0.4})
  love.graphics.setFont(vcrFont)
  love.graphics.print(spaceToStart, w/2 - spaceToStartWidth/2, 150)
end

return Pause
