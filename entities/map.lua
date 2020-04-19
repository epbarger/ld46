local Map = Class{}

local Tree = require('entities.tree')
local TreeSpawner = require('entities.treeSpawner')
local Fire = require('entities.fire')
local Enemy = require('entities.enemy')
local EnemyController = require('entities.enemyController')

local heightMap = love.image.newImageData('textures/party1.png')

function Map:init()
  self.width = 1024
  self.height = 1024
  self.heightMap = heightMap
  self.staticColorBuffer = {}
  self.colorBuffer = {}
  self.vwidth = 2
  self.backgroundColor = colorBuilder(107, 149, 193)

  self:fillStaticColorBuffer()

  self.trees = TreeSpawner(heightMap, self.width, self.height):spawn(40)
  local initialFire = self.trees[math.random(1, #self.trees)]
  initialFire.burned = true
  self.fire = Fire(initialFire.x, initialFire.y)

  self.enemies = {}
end

function Map:initEnemyController()
  self.enemyController = EnemyController()
end

function Map:update(dt)
  if self.enemyController then self.enemyController.update(dt) end
  self.fire:update(dt)
  for i, enemy in ipairs(self.enemies) do
    enemy:update(dt)
  end
end

function Map:drawBG()
  love.graphics.setColor(self.backgroundColor)
  love.graphics.rectangle("fill", 0, 0, w, h)
end

function Map:draw(player)
  self.heightMap = heightMap:clone()
  self.colorBuffer = {}

  for i, tree in ipairs(self.trees) do
    tree:draw(self)
  end
  for i, enemy in ipairs(self.enemies) do
    enemy:draw(self)
  end
  self.fire:draw(self)

  self:renderVoxels(player)
end

function Map:renderVoxels(player)
  local sinang = math.sin(player.angle)
  local cosang = math.cos(player.angle)

  local hiddeny = {}
  for i = 0, w do hiddeny[i] = h end

  local z = 1
  local deltaz = 1

  -- draw front to back
  while z < player.distance do
    local plx = -cosang * z - sinang * z
    local ply = sinang * z - cosang * z
    local prx = cosang * z - sinang * z
    local pry = -sinang * z - cosang * z

    local dx = (prx - plx) / w
    local dy = (pry - ply) / w
    plx = plx + player.x
    ply = ply + player.y

    local invz = 1 / z * 240
    for i = 0, w, self.vwidth do
      local x = plx -- (plx + self.width) % self.width
      local y = ply -- (ply + self.height) % self.height

      local redHeight, g, b, a
      local r, g, b, a

      if x >= self.width or x < 0 or y >= self.height or y < 0 then
        redHeight = 0
        r, g, b, a = 0, 0, 0, 0
      else
        redHeight, g, b, a = self.heightMap:getPixel(x, y)
        redHeight = math.max(10/255, redHeight) -- raise floor

        local color = map:getColor(x, y)
        r, g, b, a = color[1], color[2], color[3], color[4]

        -- if z / player.distance > 0.1 then
          a = 1 - (z / player.distance)*1.2
        -- end
      end

      local heightonscreen = math.floor((player.height - redHeight*255) * invz + player.horizon)
      self:drawVerticalLine(i, heightonscreen, hiddeny[i], {r,g,b,a}, self.vwidth)

      if heightonscreen < hiddeny[i] then hiddeny[i] = heightonscreen end
      plx = plx + dx * self.vwidth
      ply = ply + dy * self.vwidth
    end

    z = z + deltaz
    deltaz = deltaz + 0.005
  end
end

function Map:getColor(x, y)
  x = math.floor(x)
  y = math.floor(y)

  local staticColor = self.staticColorBuffer[x][y]

  local dynamicColor = nil
  if self.colorBuffer[x] and self.colorBuffer[x][y] then
    dynamicColor = self.colorBuffer[x][y]
  end

  return dynamicColor or staticColor
end


local snowColors = {
  colorBuilder(231, 234, 238),
}
function Map:fillStaticColorBuffer()
  for x = 0, self.width do
    for y = 0, self.height do
      local r, g, b, a = self.heightMap:getPixel(x, y)
      local h = r*255

      self.staticColorBuffer[x] = self.staticColorBuffer[x] or {}
      if h > 2 then
        self.staticColorBuffer[x][y] = white
      else
        self.staticColorBuffer[x][y] = snowColors[love.math.random(1, #snowColors)]
      end
    end 
  end
end

function Map:drawVerticalLine(x, ytop, ybottom, color, width)
  x = math.floor(x)
  ytop = math.floor(math.max(0, ytop))
  ybottom = math.floor(ybottom)
  if ytop > ybottom then return end

  love.graphics.setColor(color)
  love.graphics.rectangle("fill", x, ytop, width, ybottom - ytop)
end

function Map:insertIntoColorBuffer(x, y, color)
  x = math.floor(x)
  y = math.floor(y)
  self.colorBuffer[x] = self.colorBuffer[x] or {}
  self.colorBuffer[x][y] = color
end

function Map:colorAt(x, y)
  return self.colorBuffer[x][y]
end

function Map:insertIntoHeightMap(x, y, red, ontop)
  ontop = ontop or false
  if ontop then
    redHeight, g, b, a = self.heightMap:getPixel(x, y)
    redHeight = math.max(10/255, redHeight) -- raise floor
    self.heightMap:setPixel(x, y, {redHeight + red/255, 0, 0, 1})
  else
    self.heightMap:setPixel(x, y, {red/255, 0, 0, 1})
  end
end

function Map:convertTreeToFire(treeIndex)
  local tree = self.trees[treeIndex]
  tree.burned = true
  self.fire.x = tree.x
  self.fire.y = tree.y
end

function Map:maxHeightOfBox(x, y, width, height)
  local max = 0
  for i = x, x + width do
    for j = y, y + height do
      local redHeight, g, b, a = self.heightMap:getPixel(
        math.max(0, math.min(i, self.width-1)),
        math.max(0, math.min(j, self.height-1))
      )
      redHeight = redHeight * 255
      if redHeight > max then
        max = redHeight
      end
    end
  end
  return max
end

return Map
