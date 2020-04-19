local Save = Class{}

saveVersion = 1

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
      highscore=self.highscore
    }
  )
  local success, message = love.filesystem.write("save.bin", content)
end

function Save:newSave()
  self.highscore = 0
end

function Save:updateHighscore(score)
  if score > self.highscore then
    self.highscore = score
    self:writeOut()
  end
end

return Save
