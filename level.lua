function level_load()
  levels = {}
  levels[1] = {
               doors = {{room1 = 1, room2 = 2, tX1 = 6, tY1 = 6, tX2 = 6, tY2 = 6, type = 1}, {room1 = 1, room2 = 2, tX1 = 6, tY1 = 1, tX2 = 5, tY2 = 3, type = 1}},
               hazards = {{tX = 6, tY = 3, type = 1, room = 1}},
               actors = {{actor = {num = 1}}, {actor = {num = 2}}},
               enemyActors = {{actor = {num = 1}, room = 1, start = {x= 2, y = 5}}, {actor = {num = 1}, room = 1, start = {x= 5, y = 2}},
                              {actor = {num = 2}, room = 2, start = {x= 5, y = 3}, patrol = {room = 2, tiles = {{x = 2, y = 1}, {x = 5, y = 1}, {x = 5, y = 6}, {x = 2, y = 6}}}}},
               start = {room = 1, x = 1, y = 1},
               finish = {room = 2, x = 1, y = 1}
              }
  startLevel(1)
end


function startLevel(level)
  currentLevel = copy(levels[level])
  currentLevelNum = level
  currentRoom = currentLevel.start.room

  currentLevel.particles = {}
  currentLevel.projectiles = {}
  for i, v in ipairs(currentLevel.actors) do
    v.actor.item = playerActors[v.actor.num]
    local x, y = tileToCoord(currentLevel.start.x + i - 3*(math.ceil(i / 3) - 1) - 1, currentLevel.start.y + math.ceil(i / 3) - 1)
    v.x = x
    v.y = y
    v.room = currentLevel.start.room
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
    v.canvas = love.graphics.newCanvas(charImgs.width[v.actor.item.img], charImgs.height[v.actor.item.img]+9)
    v.targetMode = 0
    v.currentCost = 0
    v.coolDowns = {0, 0}
    v.effects = {}
    v.dir = "r"
    v.anim = {quad = 1, frame = 1, weaponQuad = 1, weaponFrame = 1}
    v.weapon = weapons[v.actor.item.weapon].img
  end
  for i, v in ipairs(currentLevel.enemyActors) do
    v.actor.item = enemyActors[v.actor.num]
    local x, y = tileToCoord(v.start.x, v.start.y)
    v.x = x
    v.y = y
    v.turnPts = 0
    v.displayTurnPts = v.turnPts
    v.health = v.actor.item.health
    v.displayHealth = v.health
    v.futureHealth = v.health
    v.mode = 0
    v.target = {}
    v.path = {}
    v.move = false
    v.dead = false
    v.targetMode = weapons[v.actor.item.weapon].targetMode
    v.canvas = love.graphics.newCanvas(charImgs.width[v.actor.item.img], charImgs.height[v.actor.item.img]+9)
    v.coolDowns = {0, 0}
    v.effects = {}
    v.dir = "r"
    v.anim = {quad = 1, frame = 1, weaponQuad = 1, weaponFrame = 1}
    v.weapon = weapons[v.actor.item.weapon].img
    v.seen = {}
    v.willSee = {}
    for j, k in ipairs(currentLevel.actors) do -- check if enemy will see a player next turn
      if isPlayerInView(v, k) then
        v.willSee[j] = true
      else
        v.willSee[j] = false
      end
    end
  end
  for i, v in ipairs(currentLevel.hazards) do
    v.alpha = 255
  end
  for i, v in ipairs(currentLevel.doors) do
    v.alpha = 255
  end

  startRoom(currentRoom)
  centerCamOnCoords(currentLevel.actors[1].x, currentLevel.actors[1].y)
end
