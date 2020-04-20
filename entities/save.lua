local Save = Class{}

saveVersion = 2

local Binser = require 'libs.binser.binser'

function Save:init()
  self.highscore = 0

  local info = love.filesystem.getInfo("save.bin")
  if info then
    local contents, size = love.filesystem.read("save.bin")
    local results, len = Binser.deserialize(contents)
    if results[1] == saveVersion then
      s = results[2]
      self.highscore = s.highscore
      self.effect = s.effect
      self.fullscreen = s.fullscreen

      if love.window.getFullscreen() ~= s.fullscreen then
        love.window.setFullscreen(not love.window.getFullscreen())
        CScreen.update(w, h)
      end
    else
      self:newSave()
    end
  else
    self:newSave()
  end
end

function Save:writeOut()
  local content = Binser.serialize(
    saveVersion,
    {
      highscore=self.highscore,
      effect=self.effect,
      fullscreen=self.fullscreen
    }
  )
  local success, message = love.filesystem.write("save.bin", content)
end

function Save:newSave()
  self.highscore = 0
  self.effect = true
  self.fullscreen = true
end

function Save:updateHighscore(score)
  if score > self.highscore then
    self.highscore = score
    self:writeOut()
  end
end

return Save
