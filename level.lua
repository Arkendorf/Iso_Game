function level_load()
  levels = {}
  levels[1] = {type = 1,
               doors = {{room1 = 1, room2 = 2, tX1 = 6, tY1 = 6, tX2 = 6, tY2 = 6}, {room1 = 1, room2 = 2, tX1 = 6, tY1 = 1, tX2 = 5, tY2 = 3}},
               hazards = {},
               actors = {{actor = 1, room = 1, x= 16, y = 0}, {actor = 2, room = 2, x= 0, y = 0}},
               enemyActors = {{actor = 1, room = 1, x= 64, y = 16}, {actor = 1, room = 1, x= 16, y = 64},
                              {actor = 2, room = 2, x= 64, y = 32, patrol = {room = 2, tiles = {{x = 2, y = 1}, {x = 5, y = 1}, {x = 5, y = 6}, {x = 2, y = 6}}}}},
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
    v.displayTurnPts = v.turnPts
    v.health = playerActors[currentLevel.type][v.actor].health
    v.displayHealth = v.health
    v.futureHealth = v.health
    v.mode = 0
    v.target = {valid = false}
    v.path = {}
    v.move = false
    v.dead = false
    v.canvas = startNewCanvas(tileSize*2, charHeight)
    v.targetMode = 0
    v.currentCost = 0
    v.weapon = playerActors[currentLevel.type][v.actor].weapon
  end
  for i, v in ipairs(currentLevel.enemyActors) do
    v.turnPts = 0
    v.displayTurnPts = v.turnPts
    v.health = enemyActors[currentLevel.type][v.actor].health
    v.displayHealth = v.health
    v.futureHealth = v.health
    v.seen = {}
    v.path = {}
    v.move = false
    v.dead = false
    v.canvas = startNewCanvas(tileSize*2, enemyHeight+9)
    v.weapon = enemyActors[currentLevel.type][v.actor].weapon
  end

  startRoom(currentRoom)
  centerCamOnCoords(#rooms[currentRoom][1] * 16, #rooms[currentRoom] * 16)
end
