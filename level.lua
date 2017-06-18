function level_load()
  levels = {}
  levels[1] = {type = 1, rooms = {1, 2}, actors = {{actor = 1, room = 1, x= 0, y = 0, move = false}, {actor = 1, room = 2, x= 48, y = 48, move = false}}, start = {room = 1, x = 1, y = 1}, finish = {room = 1, x = 3, y = 3}}
  currentLevel = 1
  currentRoom = levels[currentLevel].start.room
  startRoom(currentRoom)

  centerCamOnRoom()
end
