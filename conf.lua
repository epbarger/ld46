function love.conf(t)
  t.window.width = 480*2
  t.window.height = 320*2
  t.version = "11.2"
  t.window.highdpi = true
  t.window.resizable = true
  t.window.vsync = 0
  t.window.fullscreen = false
  t.window.msaa = 0
  t.identity = "CorruptTundra"
  t.audio.mixwithsystem = false
  t.window.title = "CORRUPT TUNDRA"

  t.modules.video = false
  t.modules.joystick = false
  t.modules.physics = false
end
