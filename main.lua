require("rooms")
require("char")
require("mouse")
require("actor")

function love.load()
  rooms_load()
  char_load()

  tile = love.graphics.newImage("tile.png")
  wall = love.graphics.newImage("wall.png")
  cursor = love.graphics.newImage("cursor.png")
  tileSize = 8

  levels = {}
  levels[1] = {type = 1, rooms = {1, 2}, actors = {{actor = 1, room = 1, x= 0, y = 0}, {actor = 1, room = 1, x= 32, y = 32}, {actor = 1, room = 2, x= 64, y = 64}}, start = {room = 1, x = 1, y = 1}, finish = {room = 1, x = 3, y = 3}}
  currentLevel = 1
  currentRoom = levels[currentLevel].start.room
  startRoom(currentRoom)



  actor_load()
end

function love.update(dt)
  mouse_update(dt)
end

function love.draw()
  rooms_draw()
  mouse_draw()
end

function love.keypressed(key)
  actor_keypressed(key)
end
