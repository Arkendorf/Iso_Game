function mouse_load()
  mouse = {}
end

function mouse_update(dt)
  mouse.x = love.mouse.getX() / screen.scale
  mouse.y = love.mouse.getY() / screen.scale
  mouse.transX, mouse.transY = mouse.x, mouse.y
  mouse.transX = mouse.transX-cameraPos.x
  mouse.transY = mouse.transY-cameraPos.y

  cursorPos = roomNodes[1]

  local range = nil
  if currentActor.mode == 1 and weapons[currentActor.actor.item.weapon].range then -- if weapon has a range limit mouse
    range = weapons[currentActor.actor.item.weapon].range
  elseif currentActor.mode > 1 and weapons[currentActor.actor.item.abilities[currentActor.mode-1]].dmgInfo and weapons[currentActor.actor.item.abilities[currentActor.mode-1]].dmgInfo.range then -- if ability has a range limit mouse
    range = weapons[currentActor.actor.item.abilities[currentActor.mode-1]].dmgInfo.range
  end
  for i, v in ipairs(roomNodes) do
    if (not range) or (range and getDistance(v, currentActor)<= 5) then
      if getDistance(v, {x = mouse.transX, y = mouse.transY}) < getDistance(cursorPos, {x = mouse.transX, y = mouse.transY}) then
        cursorPos = v
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
