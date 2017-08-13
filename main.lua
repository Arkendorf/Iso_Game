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

function love.load()
  controls = {panCamera = {left = "a", right = "d", up = "w", down = "s"}, scanreader = "tab", switchActor = "q", use = "e", endTurn = "space"}
  text = {}
  for line in love.filesystem.lines("text.txt") do
  table.insert(text, line)
  end

  graphics_load()
  scanreader_load()
  rooms_load()
  char_load()
  camera_load()
  level_load()
  actor_load()
  mouse_load()
  infobox_load()
  ai_load()
  enemychar_load()
  enemyactor_load()

end

function love.update(dt)
  mouse_update(dt)
  camera_update(dt)
  actor_update(dt)
  enemyactor_update(dt)
  infobox_update(dt)
end

function love.draw()
  love.graphics.push()
  love.graphics.translate(cameraPos.x, cameraPos.y)
  rooms_draw()
  love.graphics.pop()
  hud_draw()
  infobox_draw()
  local test = getDirection({x = 400, y = 300}, {x=mouse.x, y = mouse.y})
  love.graphics.print(tostring(test.x)..", "..tostring(test.y), 100, 0)
end

function love.keypressed(key)
  actor_keypressed(key)
  scanreader_keypressed(key)
end

function love.mousepressed(x, y, button)
  actor_mousepressed(x, y, button)
end
