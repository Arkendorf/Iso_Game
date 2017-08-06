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


function love.load()
  graphics_load()
  scanreader_load()
  rooms_load()
  char_load()
  camera_load()
  level_load()
  actor_load()
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
  love.graphics.print(tostring(scanFlicker[1]))
end

function love.keypressed(key)
  actor_keypressed(key)
  scanreader_keypressed(key)
end

function love.mousepressed(x, y, button)
  actor_mousepressed(x, y, button)
end

function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end
