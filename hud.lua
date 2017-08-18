function hud_load()
  statusEffectInfoboxNums = {}
end

function hud_update(dt)
  if isPlayerVisible(currentActor, currentActorNum) == true then
    statusEffectInfoboxNums[1] = createInfoBox(130, screen.h-20, 20, 20, text[11])
  elseif statusEffectInfoboxNums[1] ~= nil then
    deleteInfoBox(statusEffectInfoboxNums[1])
    statusEffectInfoboxNums[1] = nil
  end
end

function hud_draw()
  -- Tile Info
  love.graphics.setColor(palette.yellow)
  love.graphics.draw(scanIconImg, scanIconQuad[1])
  love.graphics.print(text[1], 32, 0+4)

  love.graphics.setColor(palette.blue)
  love.graphics.draw(scanIconImg, scanIconQuad[2], 0, 16)
  love.graphics.print(text[2], 32, 16+4)

  love.graphics.setColor(palette.cyan)
  love.graphics.draw(scanIconImg, scanIconQuad[3], 0, 32)
  love.graphics.print(text[3], 32, 32+4)

  love.graphics.setColor(palette.purple)
  love.graphics.draw(scanIconImg, scanIconQuad[4], 0, 48)
  love.graphics.print(text[4], 32, 48+4)

  love.graphics.setColor(palette.red)
  love.graphics.draw(scanIconImg, scanIconQuad[5], 0, 64)
  love.graphics.print(text[5], 32, 64+4)

  love.graphics.setColor(255, 255, 255)


  -- Player Info
  love.graphics.print(playerActors[currentLevel.type][currentActor.actor].name, 1, screen.h-9-font:getHeight())
  love.graphics.setColor(255, 0, 0)
  love.graphics.rectangle("fill", 1, screen.h-9, currentActor.health/playerActors[currentLevel.type][currentActor.actor].health*128, 3)--health

  local num = 0 -- set what is being subtracted from turnPts
  local valid = false
  if currentActor.mode == 0 then
    num = #currentActor.path.tiles-1
    valid = currentActor.path.valid
  elseif currentActor.mode == 1 then
    num = weapons[currentActor.weapon].cost
    valid = currentActor.target.valid
  end

  if currentActor.move == true or valid == false then
  love.graphics.setColor(0, 255, 255)
  love.graphics.rectangle("fill", 1, screen.h-4, currentActor.turnPts/playerActors[currentLevel.type][currentActor.actor].turnPts*128, 3)--turnPts
  else
    love.graphics.setColor(gradient({0, 200, 255}, {0, 0, 255}, 5))
    love.graphics.rectangle("fill", 1, screen.h-4, currentActor.turnPts/playerActors[currentLevel.type][currentActor.actor].turnPts*128, 3)-- current quantity of turnPts
    love.graphics.setColor(0, 255, 255)
    love.graphics.rectangle("fill", 1, screen.h-4, (currentActor.turnPts-num)/playerActors[currentLevel.type][currentActor.actor].turnPts*128, 3)--turnPts left after subtraction
  end
  love.graphics.setColor(255, 255, 255)
  if isPlayerVisible(currentActor, currentActorNum) == true then
    love.graphics.draw(statusEffectImg, statusEffectQuad[1], 130, screen.h-20)
  end
end

function gradient(c1, c2, speed)
  local num = love.timer.getTime()*speed
  return c1[1]*math.sin(num)+c2[1]*(1-math.sin(num)), c1[2]*math.sin(num)+c2[2]*(1-math.sin(num)), c1[3]*math.sin(num)+c2[3]*(1-math.sin(num))
end
