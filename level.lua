function level_load()
  levels = {}
  levels[1] = {type = 1,
               doors = {{room1 = 1, room2 = 2, tX1 = 6, tY1 = 6, tX2 = 6, tY2 = 6}, {room1 = 1, room2 = 2, tX1 = 6, tY1 = 1, tX2 = 5, tY2 = 3}},
               actors = {{actor = 1, room = 1, x= 0, y = 0, move = false}, {actor = 2, room = 2, x= 48, y = 48, move = false}},
               start = {room = 1, x = 1, y = 1},
               finish = {room = 1, x = 3, y = 3}}
  startLevel(1)
end


function startLevel(level)
  currentLevel = level
  currentRoom = levels[currentLevel].start.room
  startRoom(currentRoom)
  centerCamOnRoom()

  for i, v in ipairs(levels[currentLevel].actors) do
    v.turnPts = chars[v.actor].turnPts -- will need to be changed when level mode 2 is added
  end
end
