local GameOver = Class{}

function GameOver:init()
end

function GameOver:update()
  if love.keyboard.isDown("space") then
    if not titleTransitionLock then
      titleTransitionLock = true
      gameState = "title"
      game:reset()
    end
  else
    titleTransitionLock = false
  end
end

local corrupted = "CORRUPTED"
local corruptedWidth = vcrTitle:getWidth(corrupted)
function GameOver:draw()
  love.graphics.setColor({1, 0.4, 0.4})
  love.graphics.setFont(vcrTitle)
  love.graphics.print(corrupted, w/2 - corruptedWidth/2, 70)

  love.graphics.setFont(vcrFont)
  local highscoreText = "SCORE - "..player.score
  love.graphics.print(highscoreText, w/2 - vcrFont:getWidth(highscoreText)/2 + 1, 130)
  local comboText = "MAX COMBO - x"..player.highestMultiplier
  love.graphics.print(comboText, w/2 - vcrFont:getWidth(comboText)/2 + 1, 160)
  local firesText = "CAMPFIRES - "..player.campfireCount
  love.graphics.print(firesText, w/2 - vcrFont:getWidth(firesText)/2 + 1, 190)
end

return GameOver
