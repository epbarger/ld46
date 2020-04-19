Gamestate = require 'libs.hump.gamestate'
Class = require 'libs.hump.class'
CScreen = require 'libs.cscreen.cscreen'
inspect = require 'libs.inspect.inspect'
Vector = require 'libs.hump.vector'
Timer = require 'libs.hump.timer'
Moonshine = require 'libs.moonshine'

w, h = 480, 320

love.event.pump()
love.mouse.setRelativeMode(true)
love.mouse.setVisible(false)
love.event.pump()

function colorBuilder(r, g, b, a)
  return { r/255, g/255, b/255, (a or 255)/255 }
end

function yOnLine(x1, y1, x2, y2, x)
  local m = (y2 - y1) / (x2 - x1)
  local b = y1 - m*x1
  return m*x+b
end

function distanceBetweenPoints(x1, y1, x2, y2)
  return math.sqrt(math.pow(x2 - x1,2) + math.pow(y2 - y1,2))
end

titleTransitionLock = false
pauseTransitionLock = false
gameOverTransitionLock = false
game = require 'gamestates.game'

function love.load()
  CScreen.init(w, h, true)

  Gamestate.registerEvents()
  Gamestate.switch(game)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.push("quit")
  elseif key == "1" then
    local newFS = not love.window.getFullscreen()
    love.window.setFullscreen(newFS)
    CScreen.update(w, h)
    initEffect()
    save.fullscreen = newFS
    save:writeOut()
  elseif key == "2" then
    if love.window.getFullscreen() then
      save.crt = not save.crt
      save:writeOut()
    end
  end
end

function love.resize(width, height)
  CScreen.update(width, height)
end


function love.mousemoved(x, y, dx, dy)
  if player then
    player:mouseMoved(x, y, dx, dy)
  end
end

function love.mousepressed(x, y, button)
  if player then
    player:mousePressed(x, y, button)
  end
end


-- figure out
-- "expired" text when multiplier expires
-- jetpack momentum indicator
