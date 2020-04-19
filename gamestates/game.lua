local game = {}

defaultFont = love.graphics.getFont()
vcrFont = love.graphics.newFont('fonts/VCR_OSD_MONO.ttf', 30)

local Map = require 'entities.map'
local Player = require 'entities.player'
local Snow = require 'entities.snow'
local Title = require 'entities.title'
local Pause = require 'entities.pause'
local GameOver = require 'entities.gameOver'
local Save = require 'entities.save'
local Sound = require 'entities.sound'

black = {0,0,0,1}
white = {1,1,1,1}

save = Save()
sound = Sound()

map = Map()
player = Player(512, 800)

snowFG = Snow(100, 3, {1,1,1,0.5}, 3, 3, 40)
snowBG = Snow(500, 2, {1,1,1,0.3}, 0.5, 1.5, 20)
title = Title()
pause = Pause()
gameOver = GameOver()

gameState = "title"

function game:enter()
  game:reset()
  map:initEnemyController()
end

t = nil
function game:update(dt)
  t = love.timer.getTime()
  Timer.update(dt)

  if gameState == "title" then
    snowFG:update(dt, player)
    snowBG:update(dt, player)
    title:update()
  elseif gameState == "playing" then
    player:update(dt)
    map:update(dt)
    snowFG:update(dt, player)
    snowBG:update(dt, player)
  elseif gameState == "paused" then
    pause:update()
  elseif gameState == "gameover" then
    gameOver:update()
    map:update(dt)
    snowFG:update(dt, player)
    snowBG:update(dt, player)
  end
end

function game:draw()
  CScreen.apply()

  map:drawBG()
  snowBG:draw()
  map:draw(player)
  snowFG:draw()

  if gameState == "title" then
    title:draw()
  elseif gameState == "playing" then
    player:draw()
  elseif gameState == "paused" then
    player:draw()
    pause:draw()
  elseif gameState == "gameover" then
    gameOver:draw()
  end

  -- love.graphics.setFont(defaultFont)
  -- love.graphics.setColor(0,0,0)
  -- love.graphics.rectangle("fill", w/2-1, h/2-1, 2, 2)
  -- love.graphics.print(tostring(love.timer.getFPS( )), w/2, 10)
  -- love.graphics.print(''..math.floor(player.x)..', '..math.floor(player.y)..', '..math.floor(player.height), w/2, 22)

  CScreen.cease()
end

function game:reset()
  map = Map()
  player = Player(math.min(map.width-1, map.fire.x + 20), math.min(map.width-1, map.fire.y + 20))
  player:setHeight()
end

return game
