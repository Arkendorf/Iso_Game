function level_load()
  levels = {}
  levels[1] = {type = 1, rooms = {1, 2}, actors = {{actor = 1, room = 1, x= 0, y = 0, move = false}, {actor = 2, room = 2, x= 48, y = 48, move = false}}, start = {room = 1, x = 1, y = 1}, finish = {room = 1, x = 3, y = 3}}
  startLevel(1)
end


function startLevel(level)
  currentLevel = level
  currentRoom = levels[currentLevel].rooms[levels[currentLevel].start.room] -- current room is set to what start.room refers to in list of rooms used by level
  startRoom(currentRoom)
  centerCamOnRoom()

  for i, v in ipairs(levels[currentLevel].rooms) do -- renders the floor for all rooms in level
    floors[i] = drawFloor(v)
  end

  for i, v in ipairs(levels[currentLevel].actors) do
    v.turnPts = chars[v.actor].turnPts -- will need to be changed when level mode 2 is added
  end
end
