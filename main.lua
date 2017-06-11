require("rooms")
require("char")

function love.load()
  rooms_load()
  char_load()

  tile = love.graphics.newImage("tile.png")
  wall = love.graphics.newImage("wall.png")
  tileSize = 8

  levels = {}
  levels[1] = {type = 1, rooms = {1}, start = {room = 1, x = 1, y = 1}, finish = {room = 1, x = 3, y = 3}}
  currentLevel = 1
  currentRoom = levels[currentLevel].start.room
  startRoom(currentRoom)


end

function love.update()
end

function love.draw()

  rooms_draw()
end
