function mouse_load()
  mouse = {}
  updateCursor = false
end

function mouse_update(dt)
  mouse.x = love.mouse.getX() / screen.scale
  mouse.y = love.mouse.getY() / screen.scale
  mouse.transX = mouse.x-cameraPos.x
  mouse.transY = mouse.y-cameraPos.y

  oldCursorPos = cursorPos

  cursorPos = roomNodes[1]
  cursorPos.dist = getDistance(cursorPos, {x = mouse.transX, y = mouse.transY})

  local range = nil
  if currentActor.mode == 1 and weapons[currentActor.actor.item.weapon].range then -- if weapon has a range limit mouse
    range = weapons[currentActor.actor.item.weapon].range
  elseif currentActor.mode > 1 and weapons[currentActor.actor.item.abilities[currentActor.mode-1]].dmgInfo and weapons[currentActor.actor.item.abilities[currentActor.mode-1]].dmgInfo.range then -- if ability has a range limit mouse
    range = weapons[currentActor.actor.item.abilities[currentActor.mode-1]].dmgInfo.range
  end
  local tX, tY = coordToTile(currentActor.x, currentActor.y)
  for i, v in ipairs(roomNodes) do
    if not range or getDistance({x = v.tX, y = v.tY}, {x = tX, y = tY}) <= range then
      if getDistance(v, {x = mouse.transX, y = mouse.transY}) < cursorPos.dist then
        cursorPos = v
        cursorPos.dist = getDistance(cursorPos, {x = mouse.transX, y = mouse.transY})
      end
    end
  end

  if oldCursorPos and (oldCursorPos.tX ~= cursorPos.tX or oldCursorPos.tY ~= cursorPos.tY) then -- if cursor has moved, update stuff like path
    updateCursor = true
  end
  if updateCursor and currentActor.move == false then -- only update if current actor is not moving
    updateCursorReliants()
    updateCursor = false
  end
end

function mouse_draw()
  if currentActor.targetMode == 0 then
    setValidColor(currentActor)
    love.graphics.draw(cursorImg, tileToIso(cursorPos.tX,cursorPos.tY))
  elseif currentActor.targetMode ~= 3 then
    setValidColor(currentActor)
    love.graphics.draw(targetImg, tileToIso(cursorPos.tX,cursorPos.tY))
  end
end

function updateCursorReliants()
  if currentActor.mode == 0 then
    for i, v in ipairs(currentLevel.enemyActors) do
      local x, y = tileToCoord(cursorPos.tX, cursorPos.tY)
      if isPlayerInView(v, {x = x, y = y, dead = currentActor.dead, room = currentActor.room}) then
        newMove.seers[i] = true
      else
        newMove.seers[i] = false
      end
    end

    -- create path
    local tX, tY = coordToTile(currentActor.x, currentActor.y)
    currentActor.path.tiles = newPath({x = tX, y = tY}, {x = cursorPos.tX, y = cursorPos.tY}, rooms[currentRoom])
    currentActor.path.valid = pathIsValid(currentActor.path.tiles, currentActor)
    currentActor.currentCost = #currentActor.path.tiles-1
  elseif currentActor.mode == 1 then -- find weapon target (if any)
    currentActor.currentCost = weapons[currentActor.actor.item.weapon].cost
    currentActor.target.item = findTargetFuncs[currentActor.targetMode](currentActor, cursorPos, currentLevel.enemyActors)
    currentActor.target.valid = targetValidFuncs[currentActor.targetMode](currentActor.target.item, currentActor, currentActor.currentCost)
  elseif currentActor.mode > 1 then -- find ability target (if any)
    currentActor.currentCost = abilities[currentActor.actor.item.abilities[currentActor.mode-1]].cost
    currentActor.target.item = findTargetFuncs[currentActor.targetMode](currentActor, cursorPos, currentLevel.enemyActors)
    currentActor.target.valid = targetValidFuncs[currentActor.targetMode](currentActor.target.item, currentActor, currentActor.currentCost)
  end
end
