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
require("infobox")
require("enemychar")
require("enemyactor")
require("ai")
require("combat")

function love.load()
  controls = {panCamera = {left = "a", right = "d", up = "w", down = "s"}, scanreader = "tab", switchActor = "q", use = "e", endTurn = "space", mode1 = "1"}
  text = {}
  for line in love.filesystem.lines("text.txt") do
  table.insert(text, line)
  end

  graphics_load()
  scanreader_load()
  rooms_load()
  char_load()
  enemychar_load()
  camera_load()
  level_load()
  actor_load()
  enemyactor_load()
  mouse_load()
  infobox_load()
  ai_load()
  hud_load()
  combat_load()
end

function love.update(dt)
  mouse_update(dt)
  camera_update(dt)
  actor_update(dt)
  enemyactor_update(dt)
  infobox_update(dt)
  hud_update(dt)
  combat_update(dt)
end

function love.draw()
  love.graphics.push()
  love.graphics.translate(cameraPos.x, cameraPos.y)
  rooms_draw()
  love.graphics.pop()
  hud_draw()
  infobox_draw()
  love.graphics.print(tostring(currentActor.target.valid), 100, 0)
end

function love.keypressed(key)
  actor_keypressed(key)
  scanreader_keypressed(key)
end

function love.mousepressed(x, y, button)
  actor_mousepressed(x, y, button)
end
