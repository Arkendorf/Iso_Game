function mouse_load()
  mouse = {}
end

function mouse_update(dt)
  mouse.x = love.mouse.getX() / screen.scale
  mouse.y = love.mouse.getY() / screen.scale
  mouse.transX = mouse.x-cameraPos.x
  mouse.transY = mouse.y-cameraPos.y

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
