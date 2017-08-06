require("rooms")
require("char")
require("mouse")
require("actor")
require("camera")
require("graphics")
require("level")
require("astarV2")
require("door")
require("scanreader")

function love.load()
  graphics_load()
  rooms_load()
  char_load()
  camera_load()
  level_load()
  actor_load()
  scanreader_load()
end

function love.update(dt)
  mouse_update(dt)
  camera_update(dt)
  actor_update(dt)
end

function love.draw()
  love.graphics.push()
  love.graphics.translate(cameraPos.x, cameraPos.y)
  rooms_draw()
  love.graphics.pop()
  love.graphics.print(tostring(scanning))
end

function love.keypressed(key)
  actor_keypressed(key)
  scanreader_keypressed(key)
end

function love.mousepressed(x, y, button)
  actor_mousepressed(x, y, button)
end
