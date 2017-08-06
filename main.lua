require("rooms")
require("char")
require("mouse")
require("actor")
require("camera")
require("graphics")
require("level")
require("astarV2")
require("door")
require("hazard")
require("scanreader")
require("functiondump")
require("hud")

function love.load()
  graphics_load()
  scanreader_load()
  rooms_load()
  char_load()
  camera_load()
  level_load()
  actor_load()

  controls = {panCamera = {left = "a", right = "d", up = "w", down = "s"}, scanreader = "tab", switchActor = "q", use = "e", endTurn = "space"}
  text = {}
  for line in love.filesystem.lines("text.txt") do
  table.insert(text, line)
  end
end

function love.update(dt)
  mouse_update(dt)
  camera_update(dt)
  actor_update(dt)
  scanreader_update(dt)
end

function love.draw()
  love.graphics.push()
  love.graphics.translate(cameraPos.x, cameraPos.y)
  rooms_draw()
  love.graphics.pop()
  hud_draw()
end

function love.keypressed(key)
  actor_keypressed(key)
  scanreader_keypressed(key)
end

function love.mousepressed(x, y, button)
  actor_mousepressed(x, y, button)
end
