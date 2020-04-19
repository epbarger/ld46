local Title = Class{}

vcrTitle = love.graphics.newFont('fonts/VCR_OSD_MONO.ttf', 60)

function Title:init()
end

function Title:update()
  if love.keyboard.isDown("space") then
    if not titleTransitionLock then
      titleTransitionLock = true
      gameState = "playing"
    end
  else
    titleTransitionLock = false
  end
end

local spaceToStart = "PRESS SPACE TO BEGIN"
local spaceToStartWidth = vcrFont:getWidth(spaceToStart)
local titleOne = "CORRUPT"
local titleOneWidth =  vcrTitle:getWidth(titleOne)
local titleTwo = "TUNDRA"
local titleTwoWidth =  vcrTitle:getWidth(titleTwo)
local ld = "\"KEEP IT ALIVE\" - LD46"
local ldWidth = vcrFont:getWidth(ld)
function Title:draw()
  love.graphics.setColor({1, 0.4, 0.4})
  love.graphics.setFont(vcrTitle)
  love.graphics.print(titleOne, w/2 - titleOneWidth/2, 20)
  love.graphics.print(titleTwo, w/2 - titleTwoWidth/2, 80)

  love.graphics.setFont(vcrFont)
  if save.highscore > 0 then
    local hs = "HIGHSCORE - "..save.highscore
    local hsWidth = vcrFont:getWidth(hs)
    love.graphics.print(hs, w/2 - hsWidth/2, 150)
  else
    love.graphics.print(ld, w/2 - ldWidth/2, 150)
  end

  love.graphics.print(spaceToStart, w/2 - spaceToStartWidth/2, 270)
end

return Title
