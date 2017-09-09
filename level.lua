function level_load()
  levels = {}
  levels[1] = {type = 1,
               doors = {{room1 = 1, room2 = 2, tX1 = 6, tY1 = 6, tX2 = 6, tY2 = 6}, {room1 = 1, room2 = 2, tX1 = 6, tY1 = 1, tX2 = 5, tY2 = 3}},
               hazards = {{tX = 6, tY = 3, type = 1, room = 1}},
               actors = {{actor = {num = 1}, room = 1, x= 16, y = 0}, {actor = {num = 2}, room = 2, x= 0, y = 0}},
               enemyActors = {{actor = {num = 1}, room = 1, x= 64, y = 16}, {actor = {num = 1}, room = 1, x= 16, y = 64},
                              {actor = {num = 2}, room = 2, x= 64, y = 32, patrol = {room = 2, tiles = {{x = 2, y = 1}, {x = 5, y = 1}, {x = 5, y = 6}, {x = 2, y = 6}}}}},
               start = {room = 1, x = 1, y = 1},
               finish = {room = 1, x = 3, y = 3}}
  startLevel(1)
end


function startLevel(level)
  currentLevel = copy(levels[level])
  currentLevelNum = level
  currentRoom = currentLevel.start.room

  for i, v in ipairs(currentLevel.actors) do
    v.actor.item = playerActors[currentLevel.type][v.actor.num]
    v.turnPts = v.actor.item.turnPts
    v.displayTurnPts = v.turnPts
    v.health = v.actor.item.health
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
    v.coolDowns = {0, 0}
  end
  for i, v in ipairs(currentLevel.enemyActors) do
    v.actor.item = enemyActors[currentLevel.type][v.actor.num]
    v.turnPts = 0
    v.displayTurnPts = v.turnPts
    v.health = v.actor.item.health
    v.displayHealth = v.health
    v.futureHealth = v.health
    v.seen = {}
    v.path = {}
    v.move = false
    v.dead = false
    v.canvas = startNewCanvas(tileSize*2, enemyHeight+9)
    v.coolDowns = {0, 0}
  end

  startRoom(currentRoom)
  centerCamOnCoords(#rooms[currentRoom][1] * 16, #rooms[currentRoom] * 16)
end
