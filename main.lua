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
require("functiondump")
require("hud")
require("infobox")
require("enemychar")
require("enemyactor")
require("ai")
require("combat")
require("button")
require("particle")
require("map")
require("delay")
require("ability")

function love.load()
  controls = {panCamera = {left = "a", right = "d", up = "w", down = "s"}, switchActor = "q", use = "e", endTurn = "space", modes = {"1", "2", "3"}}
  text = {}
  for line in love.filesystem.lines("text.txt") do
  table.insert(text, line)
  end
  palette = {green = {0, 255, 0}, yellow = {255, 255, 0}, blue = {0, 0, 255}, cyan = {0, 255, 255}, purple = {255, 0, 255}, red = {255, 0, 0},
             health = {255, 0, 0}, turnPts = {0, 255, 255}}

  graphics_load()
  infobox_load()
  map_load()
  rooms_load()
  char_load()
  enemychar_load()
  camera_load()
  level_load()
  actor_load()
  enemyactor_load()
  mouse_load()
  ai_load()
  hud_load()
  combat_load()
  button_load()
  particle_load()
  delay_load()
  ability_load()
  hazard_load()

  window = love.graphics.newCanvas(screen.w, screen.h)
end

function love.update(dt)
  delay_update(dt)
  mouse_update(dt)
  camera_update(dt)
  actor_update(dt)
  enemyactor_update(dt)
  infobox_update(dt)
  hud_update(dt)
  combat_update(dt)
  particle_update(dt)
  ability_update(dt)
  hazard_update(dt)
end

function love.draw()
  canvas, oldCanvas = resumeCanvas(window)

  love.graphics.push()
  love.graphics.translate(cameraPos.x, cameraPos.y)
  rooms_draw()
  love.graphics.pop()
  hud_draw()
  infobox_draw()
  love.graphics.print(love.timer.getFPS())

  love.graphics.setCanvas(oldCanvas)
  love.graphics.draw(window, 0, 0, 0, 2, 2)
end

function love.keypressed(key)
  actor_keypressed(key)
end

function love.mousepressed(x, y, button)
  x = x / screen.scale
  y = y / screen.scale
  local clickUsed = button_mousepressed(x, y, button)
  if clickUsed == false then
    local clickUsed = actor_mousepressed(x, y, button)
  end
end
