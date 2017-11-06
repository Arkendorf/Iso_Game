function enemyactor_load()
  enemyTurnSpeed = 1
end

function enemyTargetIsValid(num, actor)
  if num > 0 and actor.turnPts >= weapons[actor.actor.item.weapon].cost then
    local player = currentLevel.actors[num]
    if player.room == actor.room and player.dead == false and player.futureHealth > 0 and LoS({x = actor.x, y = actor.y}, {x = player.x, y = player.y}, rooms[actor.room]) == true then
      return true
    else
      return false
    end
  else
    return false
  end
end

function enemyactor_update(dt)
  if playerTurn == false then
    local nextTurn = true
    for i, v in ipairs(currentLevel.enemyActors) do -- main enemy loop
      if v.dead == false then
        if v.wait == true then
          nextTurn = false
        elseif v.move == true then
          nextTurn = false -- don't end enemies turn if actors are still moving
          enemyFollowPath(i, v, dt)
        else
          if isRoomOccupied(v.room, v.seen) == false and arePlayersSeen(v) then -- use a door if on one and the current room is unoccupied
            local newPos = useDoor(tileDoorInfo(v.room, coordToTile(v.x, v.y)))
            if newPos then
              v.room, v.x, v.y = newPos.room, newPos.x, newPos.y
              v.turnPts = v.turnPts - 1
              moveEnemy(i, v, 0) -- check if enemy should move once in new room
              nextTurn = false
            end
          end

          if enemyAbility(i, v, 10) == true then -- check if ai wants to use ability
            nextTurn = false
            v.mode = 1+v.target.ability.num -- set the mode of the enemy
            v.weapon = abilities[v.actor.item.abilities[v.mode-1]].img -- set the weapon
            v.coolDowns[v.target.ability.num] = abilities[v.target.ability.item].coolDown -- set the cool down for the used ability
            v.turnPts = v.turnPts - abilities[v.target.ability.item].cost -- subtract turnPts for the used ability
            if v.anim.quad ~= 3 and v.anim.quad ~= 4 then -- if gun is not already up, switch to that animation
              v.anim.quad = 3
              v.anim.frame = 1
              v.wait = true -- wait for gun to be up before shooting
              local weaponSpeed = weaponImgs.info[v.weapon].speed[2] -- get the speed of the gun's shoot animation
              v.anim.weaponNext = {quad = 2, t = getAnimTime(charImgs.info[v.actor.item.img], 3)+1/weaponSpeed} -- set gun to firing animation when weapon is up
              newDelay(getAnimTime(charImgs.info[v.actor.item.img], 3)+1/weaponSpeed, function (player) useAbility(v.target.ability.item, v, v.target.item, currentLevel.actors); end, {v}) -- use ability when gun is up
              newDelay(getAnimTime(charImgs.info[v.actor.item.img], 3)+2/weaponSpeed+getAnimTime(weaponImgs.info[v.weapon], 2), function (player) v.wait = false end, {v}) -- stop the wait when ability is finished being used
            else -- if gun is already up
              useAbility(v.target.ability.item, v, v.target.item, currentLevel.actors) -- use the ability

              v.wait = true -- pause between shots
              v.anim.weaponQuad = 2 -- set gun to firing animation
              v.anim.weaponFrame = 1
              local weaponSpeed = weaponImgs.info[v.weapon].speed[2] -- get the speed of the gun's shoot animation
              newDelay(getAnimTime(weaponImgs.info[v.weapon], 2)+1/weaponSpeed, function (player) v.wait = false end, {v}) -- wait until the ability is finished being used
            end
          elseif enemyAttack(i, v) == true then -- same as above, but for attacks (should probably combine these at some point)
            nextTurn = false
            v.mode = 1
            v.weapon = weapons[v.actor.item.weapon].img
            v.turnPts = v.turnPts - weapons[v.actor.item.weapon].cost
            if v.anim.quad ~= 3 and v.anim.quad ~= 4 then
              v.anim.quad = 3
              v.anim.frame = 1
              v.wait = true
              local weaponSpeed = weaponImgs.info[v.weapon].speed[2]
              v.anim.weaponNext = {quad = 2, t = getAnimTime(charImgs.info[v.actor.item.img], 3)+1/weaponSpeed}
              newDelay(getAnimTime(charImgs.info[v.actor.item.img], 3)+1/weaponSpeed, function (player) attack(v, v.target.item, currentLevel.actors) end, {v})
              newDelay(getAnimTime(charImgs.info[v.actor.item.img], 3)+2/weaponSpeed+getAnimTime(weaponImgs.info[v.weapon], 2), function (player) v.wait = false end, {v})
            else
              attack(v, v.target.item, currentLevel.actors)

              v.wait = true -- pause between shots
              v.anim.weaponQuad = 2
              v.anim.weaponFrame = 1
              local weaponSpeed = weaponImgs.info[v.weapon].speed[2]
              newDelay(getAnimTime(weaponImgs.info[v.weapon], 2)+1/weaponSpeed, function (player) v.wait = false end, {v})
            end
          else -- if there are no abilities/weapons to use, or if turnPts are up
            v.turnPts = 0 -- clear any remaining turnPts
            if v.anim.quad == 2 then -- if enemy just finished moving, reset animation to idle
              v.anim.quad = 1
              v.anim.frame = 1
            elseif v.anim.quad == 4 or v.anim.quad == 3 then -- if enemy just finished attacking, put gun down
              v.anim.quad = 5
              v.anim.frame = 1
            end
          end
        end
      end
    end

    if nextTurn == true and #currentLevel.projectiles == 0 then
      startPlayerTurn()
    end
  end

  -- all-time shananigans
  for i, v in ipairs(currentLevel.enemyActors) do
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

function isRoomOccupied(room, seen)
  for i, v in ipairs(currentLevel.actors) do -- sees if any players are in the room
    if v.room == room and seen[i] == true and v.dead == false then
      return true
    end
  end
  return false
end

function arePlayersSeen(enemy)
  for i, v in ipairs(currentLevel.actors) do
    if enemy.seen[i] == true and v.dead == false then
      return true
    end
  end
  return false
end

function revealPlayers()
  for i, v in ipairs(currentLevel.enemyActors) do
    for j, k in ipairs(currentLevel.actors) do
      if isPlayerInView(v, k) == true then
        v.seen[j] = true
      end
    end
    sharePlayerLocation(v)
  end
end

function isPlayerInView(enemy, player)
  if enemy.room == player.room and player.dead == false and enemy.dead == false and getDistance({x = enemy.x, y = enemy.y}, {x = player.x, y = player.y}) <= enemy.actor.item.eyesight and LoS({x = enemy.x, y = enemy.y}, {x = player.x, y = player.y}, rooms[enemy.room]) == true then
    return true
  else
    return false
  end
end

function sharePlayerLocation(enemy) -- share seen players with rest of room
  for i, v in ipairs(currentLevel.enemyActors) do
    if v.room == enemy.room then
      for j = 1, #currentLevel.actors do
        if enemy.seen[j] == true then
          v.seen[j] = true
        end
      end
    end
  end
end

function isPlayerVisible(player, num)
  for i, v in ipairs(currentLevel.enemyActors) do
    if v.seen[num] == true and player.dead == false then
      return true
    end
  end
  return false
end

function moveEnemy(enemyNum, enemy)
  enemy.wait = false
  enemy.mode = 0
  local move = false
  if arePlayersSeen(enemy) == true and isRoomOccupied(enemy.room, enemy.seen) == true then -- if known players are in the room, perform normal behavior
    enemy.path.tiles = chooseTile(enemyNum, enemy, rankTiles(enemyNum, enemy))
    enemy.anim.quad = 2
    enemy.anim.frame = 1
  elseif arePlayersSeen(enemy) == true and isRoomOccupied(enemy.room, enemy.seen) == false then -- if no known players are in the room, but are elsewhere, find a door to them
    enemy.path.tiles = chooseTile(enemyNum, enemy, goToDoor(enemyNum, enemy))
    enemy.anim.quad = 2
    enemy.anim.frame = 1
  elseif enemy.patrol and enemy.room == enemy.patrol.room then -- if there are no known players, patrol if enemy has a patrol
    enemy.path.tiles = chooseTile(enemyNum, enemy, patrol(enemyNum, enemy))
    enemy.anim.quad = 2
    enemy.anim.frame = 1
  else
    enemy.path.tiles = {}
  end
  if #enemy.path.tiles > 0 then -- if the best course of action is to move
    enemy.turnPts = enemy.turnPts - (#enemy.path.tiles-1)
    enemy.path.tiles = simplifyPath(enemy.path.tiles)
    enemy.move = true
  end
end

function enemyAttack(enemyNum, enemy) -- damages player, returns true if it attacks, false if it doesn't
  local target = findEnemyTarget(enemyNum, enemy, enemyCombatAIs[enemy.actor.item.combatAI], weapons[enemy.actor.item.weapon], weapons[enemy.actor.item.weapon].cost)
  if target then
    enemy.target.item = target

    local dir = getDirection(enemy, enemy.target.item)
    enemy.dir = coordToStringDir(dir) -- face target
    return true
  else
    return false
  end
end

function enemyAbility(enemyNum, enemy, minScore) -- damages player, returns true if it attacks, false if it doesn't
  for i, v in ipairs(enemy.actor.item.abilities) do
    if enemy.coolDowns[i] == 0 then
      local target = findEnemyTarget(enemyNum, enemy, abilityAIs[abilities[v].ai], abilities[v].dmgInfo, abilities[v].cost, minScore)
      if target then
        enemy.target.item = target
        enemy.target.ability = {item = v, num = i}

        local dir = getDirection(enemy, enemy.target.item)
        enemy.dir = coordToStringDir(dir) -- face target
        return true
      end
    end
  end
  return false
end

function startEnemyTurn()
  playerTurn = false
  giveTurnPts(currentLevel.enemyActors)
  updateEffects(currentLevel.enemyActors)
  revealPlayers()
  for i, v in ipairs(currentLevel.enemyActors) do
    if v.dead == false then
      moveEnemy(i, v)
    end
  end
  startEnemyHud()
end

function findEnemyTarget(i, v, func, info, cost, minScore)
  local potentialTargets = rankTargets(i, v, func, info)
  return chooseTarget(i, v, potentialTargets, cost, minScore)
end

function enemyFollowPath(i, v, dt)
  local path = {x = (v.path.tiles[1].x-1) * tileSize, y = (v.path.tiles[1].y-1) * tileSize}
  if v.x == path.x and v.y == path.y then
    table.remove(v.path.tiles, 1)
    if #v.path.tiles < 1 then -- stop moving the actor
      v.move = false

      v.anim.quad = 1
      v.anim.frame = 1
    end
  else
    local dir = pathDirection({x = v.x, y = v.y}, path)
    v.dir = coordToStringDir(dir)
    local speed = v.actor.item.speed*enemyTurnSpeed
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
