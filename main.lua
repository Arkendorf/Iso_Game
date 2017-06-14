require("rooms")
require("char")
require("mouse")
require("actor")
require("camera")
require("graphics")
require("level")

function love.load()
  graphics_load()
  rooms_load()
  char_load()
  actor_load()
  camera_load()
  level_load()
end

function love.update(dt)
  mouse_update(dt)
  camera_update(dt)
end

function love.draw()
  love.graphics.push()
  love.graphics.translate(cameraPos.x, cameraPos.y)
  rooms_draw()
  mouse_draw()
  love.graphics.pop()
end

function love.keypressed(key)
  actor_keypressed(key)
end
