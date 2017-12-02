function actor_load()
  newCurrentActor(1)
  playerTurn = true
end


function newCurrentActor(newActorNum)
  currentActorNum = newActorNum
  currentActor = currentLevel.actors[newActorNum]
  newMove = {seers = {}, path = {}, target = {}, cost = 0}
  syncRooms()
  updateCursorReliants()
end

function syncRooms()
  if currentRoom ~= currentActor.room then
    startOldRoom()
    currentRoom =  currentActor.room
    startRoom(currentRoom)
    centerCamOnCoords(currentActor.x, currentActor.y)
  else
    driftCamToCoords(currentActor.x, currentActor.y)
  end
end

function nextActor()
  local newActorNum = currentActorNum + 1
  if newActorNum > #currentLevel.actors then
    newActorNum = 1
  end
  while currentLevel.actors[newActorNum].dead == true do
    newActorNum = newActorNum+1
    if newActorNum > #currentLevel.actors then
      newActorNum = 1
    end
    if currentActorNum == newActorNum then
      break
    end
  end
  newCurrentActor(newActorNum)
end

function actor_keypressed(key)
  if key == controls.switchActor then
    nextActor()
  elseif key == controls.endTurn then
    for i, v in ipairs(currentLevel.actors) do
      v.turnPts = 0
    end
  elseif key == controls.use then
    local tX, tY = coordToTile(currentActor.x, currentActor.y)
    if currentActor.move == false and currentActor.turnPts > 0 then
      newPos = useDoor(tileDoorInfo(currentActor.room, coordToTile(currentActor.x, currentActor.y)))
      if newPos then
        local warp = currentActor.warp
        warp.x, warp.y, warp.room, warp.alpha = currentActor.x, currentActor.y, currentActor.room, 0 -- set old position in warp
        warp.active = true

        currentActor.room, currentActor.x, currentActor.y = newPos.room, newPos.x, newPos.y
        syncRooms()
        currentActor.turnPts = currentActor.turnPts - 1
        checkForObstructions()
      end
    end
    if not newPos then -- if there is no door
      if safe(currentActor) and VIPsSafe() then
        love.event.quit()
      end
    end
  else
    for i = 1, 5 do
      if key == controls.modes[i] then
        button_toggleMode(i)
      end
    end
  end
end

function actor_update(dt)
  if playerTurn == true then
    local nextTurn = true
    for i, v in ipairs(currentLevel.actors) do
      if v.dead == false then
        if v.move == true then
          nextTurn = false -- don't end players turn if actors are still moving
          followPath(i, v, dt)
        elseif v.turnPts > 0 then
          nextTurn = false -- dont end players turn if orders need to be given
        end
      end
    end

    if nextTurn == true and #currentLevel.projectiles == 0 then
      startEnemyTurn()
    end
  end

  -- all-time shananigans
  for i, v in ipairs(currentLevel.actors) do
    if v.warp.active == true then
      if v.warp.alpha <= 255 then
        v.warp.alpha = v.warp.alpha + dt * 60 * 4
      else
        v.warp.active = false
      end
    end

    if v.anim.next then -- switch animations if necessary
      v.anim.next.t = v.anim.next.t - dt
      if v.anim.next.t <= 0 then
        v.anim.quad = v.anim.next.quad
        v.anim.frame = 1
        v.anim.next = nil
      end
    end
    if v.anim.weaponNext then -- switch animations if necessary
      v.anim.weaponNext.t = v.anim.weaponNext.t - dt
      if v.anim.weaponNext.t <= 0 then
        v.anim.weaponQuad = v.anim.weaponNext.quad
        v.anim.weaponFrame = 1
        v.anim.weaponNext = nil
      end
    end

    v.anim.frame = v.anim.frame + dt * charImgs.info[v.actor.item.img].speed[v.anim.quad] -- animate player
    if v.anim.frame >= charImgs.info[v.actor.item.img].maxFrame[v.anim.quad]+1 then
      if v.anim.quad == 3 then
        v.anim.quad = 4
      elseif v.anim.quad == 5 then
        v.anim.quad = 1
      elseif v.anim.quad == 6 then
        v.anim.quad = 7
      end
      v.anim.frame = 1
    end

    v.anim.weaponFrame = v.anim.weaponFrame + dt * weaponImgs.info[v.weapon].speed[v.anim.weaponQuad] -- animate weapon
    if v.anim.weaponFrame >= weaponImgs.info[v.weapon].maxFrame[v.anim.weaponQuad]+1 then
      v.anim.weaponQuad = 1 -- go back to normal anim
      v.anim.weaponFrame = 1
    end
    if v.ragdoll then
      if v.ragdoll.xV == 0 and v.ragdoll.yV == 0 then
        v.ragdoll = nil
      else
        if collideWithRoom(v.x+2, v.y+2, tileSize-4, tileSize-4, rooms[v.room]) then
          v.ragdoll.xV = 0
          v.ragdoll.yV = 0
        else
          v.x = v.x + v.ragdoll.xV
          v.y = v.y + v.ragdoll.yV
          v.ragdoll.xV = v.ragdoll.xV * 0.9
          v.ragdoll.yV = v.ragdoll.yV * 0.9
        end
      end
    end
  end
end

function startPlayerTurn()
  playerTurn = true
  giveTurnPts(currentLevel.actors)
  updateEffects(currentLevel.actors)
  reduceCoolDowns(currentLevel.actors)
  updateCursorReliants()
end

function actor_mousepressed(x, y, button)
  if button == 1 and currentActor.mode == 0 and currentActor.move == false and newMove.path.tiles and #newMove.path.tiles > 1 and newMove.path.valid then
    currentActor.path.valid = newMove.path.valid -- set actor's info to info from newMove
    currentActor.path.tiles = newMove.path.tiles
    currentActor.path.tiles = simplifyPath(currentActor.path.tiles) -- reduce path to basic turns
    currentActor.turnPts = currentActor.turnPts - newMove.cost -- reduce turnPts based on how far the actor is moving
    currentActor.move = true
    updateCursorReliants()

    -- set actor animation
    currentActor.anim.quad = 2
    currentActor.anim.frame = 1
    for i, v in ipairs(currentLevel.enemyActors) do -- set if player will be seen in its new position next enemy turn
      v.willSee[currentActorNum] = newMove.seers[i]
    end
    return true
  elseif button == 1 and currentActor.mode == 1 and newMove.target.valid == true then
    local x, y = tileToCoord(cursorPos.tX, cursorPos.tY) -- set dir
    local dir = getDirection(currentActor, {x = x, y = y})
    currentActor.dir = coordToStringDir(dir)

    currentActor.target.item = newMove.target.item -- set actor's info to info from newMove
    currentActor.target.valid = newMove.target.valid
    attack(currentActor, currentActor.target.item, currentLevel.enemyActors)
    currentActor.turnPts = currentActor.turnPts - newMove.cost
    updateCursorReliants()

    -- set actor animation
    currentActor.anim.quad = 4
    currentActor.anim.frame = 1

    -- set weapon animation
    currentActor.anim.weaponQuad = 2
    currentActor.anim.weaponFrame = 1
    return true
  elseif button ==1 and currentActor.mode > 1 and newMove.target.valid == true and currentActor.coolDowns[currentActor.mode-1] == 0 then
    local x, y = tileToCoord(cursorPos.tX, cursorPos.tY) -- set dir
    local dir = getDirection(currentActor, {x = x, y = y})
    currentActor.dir = coordToStringDir(dir)

    currentActor.target.item = newMove.target.item -- set actor's info to info from newMove
    currentActor.target.valid = newMove.target.valid
    useAbility(currentActor.actor.item.abilities[currentActor.mode-1], currentActor, currentActor.target.item, currentLevel.enemyActors)
    currentActor.turnPts = currentActor.turnPts - newMove.cost
    currentActor.coolDowns[currentActor.mode-1] = abilities[currentActor.actor.item.abilities[currentActor.mode-1]].coolDown
    updateCursorReliants()

    -- set actor animation
    currentActor.anim.quad = 4
    currentActor.anim.frame = 1

    -- set weapon animation
    currentActor.anim.weaponQuad = 2
    currentActor.anim.weaponFrame = 1
    return true
  end
  return false
end

function followPath(i, v, dt)
  local path = {x = (v.path.tiles[1].x-1) * tileSize, y = (v.path.tiles[1].y-1) * tileSize}
  if v.x == path.x and v.y == path.y then
    table.remove(v.path.tiles, 1)
    if #v.path.tiles < 1 then -- stop moving the actor
      v.move = false

      if v.mode > 0 then
        v.anim.quad = 3
        v.anim.frame = 1
      else
        v.anim.quad = 1
        v.anim.frame = 1
      end

      checkForObstructions()
    end
  else
    local dir = pathDirection({x = v.x, y = v.y}, path)
    v.dir = coordToStringDir(dir)
    local speed = v.actor.item.speed
    v.x = v.x + dir.x * dt * speed
    v.y = v.y + dir.y * dt * speed
    if (dir.x > 0 and v.x > path.x) or (dir.x < 0 and v.x < path.x) then
      v.x = path.x
    end
    if (dir.y > 0 and v.y > path.y) or (dir.y < 0 and v.y < path.y) then
      v.y = path.y
    end
  end
end

function drawPath(actor, path)
  if actor.move == false and path then -- only draw the path if the actor isn't moving along it
    for i, v in ipairs(path) do
      if i > 1 and i < #path then
        local oldTile = {x = path[i-1].x - v.x, y = path[i-1].y - v.y}
        local newTile = {x = path[i+1].x - v.x, y = path[i+1].y - v.y}

        if math.abs(oldTile.x) == 1 and math.abs(newTile.x) == 1 then
          love.graphics.draw(pathImg, pathQuad[3], tileToIso(v.x, v.y))
        elseif math.abs(oldTile.y) == 1 and math.abs(newTile.y) == 1 then
          love.graphics.draw(pathImg, pathQuad[4], tileToIso(v.x, v.y))
        elseif (oldTile.x == -1 and newTile.y == 1) or (oldTile.y == 1 and newTile.x == -1) then
          love.graphics.draw(pathImg, pathQuad[2], tileToIso(v.x, v.y))
        elseif (oldTile.x == 1 and newTile.y == 1) or (oldTile.y == 1 and newTile.x == 1) then
          love.graphics.draw(pathImg, pathQuad[1], tileToIso(v.x, v.y))
        elseif (oldTile.x == -1 and newTile.y == -1) or (oldTile.y == -1 and newTile.x == -1) then
          love.graphics.draw(pathImg, pathQuad[6], tileToIso(v.x, v.y))
        elseif (oldTile.x == 1 and newTile.y == -1) or (oldTile.y == -1 and newTile.x == 1) then
          love.graphics.draw(pathImg, pathQuad[5], tileToIso(v.x, v.y))
        end
      else
        love.graphics.draw(cursorImg, tileToIso(v.x, v.y))
      end
    end
  end
end
