local Sound = Class{}


jetpack = love.audio.newSource("sounds/jetpack.ogg", "static")
jetpack:setLooping(true)
enemyDeath = love.audio.newSource("sounds/bfxr2.wav", "static")
ignite = love.audio.newSource("sounds/bfxr3.wav", "static"); ignite:setVolume(0.6); ignite:setPitch(0.8)
comboLost = love.audio.newSource("sounds/combolost.ogg", "static")
warning = love.audio.newSource("sounds/warning.ogg", "static")
warning:setLooping(true)
local gameOver = love.audio.newSource("sounds/bfxr1.wav","static")
step = love.audio.newSource("sounds/step.ogg", "static")

wind = love.audio.newSource("sounds/wind.ogg", "static")
wind:setVolume(0.7)
wind:setLooping(true)


function Sound:init()
  wind:play()
end

function Sound:playJetpack()
  jetpack:play()
end

function Sound:stopJetpack()
  jetpack:stop()
end

function Sound:playEnemyDeath()
  enemyDeath:setPitch(1 - 0.125 + love.math.random()/4)
  enemyDeath:play()
end

function Sound:playGameOver()
  self:stopJetpack()
  self:stopWarning()
  gameOver:play()
end

function Sound:playIgnite()
  ignite:play()
end

function Sound:playComboLost()
  comboLost:play()
end

function Sound:playWarning()
  warning:play()
end

function Sound:stopWarning()
  warning:stop()
end

function Sound:playWalking()
  if not self.walkingTimer then
    step:setPitch(1 - 0.5 + love.math.random())
    step:play()
    self.walkingTimer = Timer.every(0.35, function()
      step:setPitch(1 - 0.5 + love.math.random())
      step:play()
    end)
  end
end

function Sound:stopWalking()
  if self.walkingTimer then
    Timer.cancel(self.walkingTimer)
    self.walkingTimer = nil
  end
end

return Sound
