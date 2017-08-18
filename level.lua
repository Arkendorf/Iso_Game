function level_load()
  levels = {}
  levels[1] = {type = 1,
               doors = {{room1 = 1, room2 = 2, tX1 = 6, tY1 = 6, tX2 = 6, tY2 = 6}, {room1 = 1, room2 = 2, tX1 = 6, tY1 = 1, tX2 = 5, tY2 = 3}},
               hazards = {{room = 1, tX = 4, tY = 4, type = 1}},
               actors = {{actor = 1, room = 1, x= 16, y = 0, path = {}, move = false}, {actor = 2, room = 2, x= 48, y = 48, path = {}, move = false}},
               enemyActors = {{actor = 1, room = 1, x= 80, y = 0, path = {}, move = false}, {actor = 1, room = 1, x= 16, y = 80, path = {}, move = false}, {actor = 2, room = 1, x= 16, y = 64, path = {}, move = false}},
               start = {room = 1, x = 1, y = 1},
               finish = {room = 1, x = 3, y = 3}}
  startLevel(1)
end


function startLevel(level)
  currentLevel = copy(levels[level])
  currentLevelNum = level
  currentRoom = currentLevel.start.room

  for i, v in ipairs(currentLevel.actors) do
    v.turnPts = playerActors[currentLevel.type][v.actor].turnPts
    v.health = playerActors[currentLevel.type][v.actor].health
    v.mode = 0
    v.target = {valid = false, num = 0}
  end
  for i, v in ipairs(currentLevel.enemyActors) do
    v.turnPts = 0
    v.health = playerActors[currentLevel.type][v.actor].health
    v.seen = {}
  end

  startRoom(currentRoom)
  centerCamOnRoom()
end
