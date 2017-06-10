require("rooms")


function love.load()
  rooms_load()
  levels = {}
  levels[1] = {type = 1, rooms = {1}, start = {room = 1, x = 1, y = 1}, finish = {room = 1, x = 3, y = 3}}
  currentLevel = 1
  currentRoom = levels[currentLevel].start.room

  tile = love.graphics.newImage("tile.png")
end

function love.update()
end

function love.draw()
  rooms_draw()
end
