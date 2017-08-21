function hud_load()
  statusEffectInfoboxNums = {}
  enemyHudInfo = {turnPts = 0, maxTurnPts = 0, displayTurnPts = 0}
end

function hud_update(dt)
  if isPlayerVisible(currentActor, currentActorNum) == true then
    statusEffectInfoboxNums[1] = createInfoBox(209, screen.h-49, 10, 10, text[11])
  elseif statusEffectInfoboxNums[1] ~= nil then
    deleteInfoBox(statusEffectInfoboxNums[1])
    statusEffectInfoboxNums[1] = nil
  end
  for i, v in ipairs(currentLevel.actors) do
    v.displayTurnPts = v.displayTurnPts - (v.displayTurnPts-v.turnPts)/10
    v.displayHealth = v.displayHealth - (v.displayHealth-v.health)/10
  end
  for i, v in ipairs(currentLevel.enemyActors) do
    v.displayTurnPts = v.displayTurnPts - (v.displayTurnPts-v.turnPts)/10
    v.displayHealth = v.displayHealth - (v.displayHealth-v.health)/10
  end
end

function hud_draw()
  -- Tile Info
  drawScanreaderHud()

  -- Player Info
  drawPlayerInfoHud()

  if playerTurn == false then
    drawEnemyHud()
  end
end

function startEnemyHud()
  enemyHudInfo.maxTurnPts = 0
  for i, v in ipairs(currentLevel.enemyActors) do
    enemyHudInfo.maxTurnPts = enemyHudInfo.maxTurnPts + enemyActors[currentLevel.type][v.actor].turnPts
  end
  enemyHudInfo.displayTurnPts = enemyHudInfo.maxTurnPts
end

function drawEnemyHud()
  enemyHudInfo.turnPts = 0
  for i, v in ipairs(currentLevel.enemyActors) do
    enemyHudInfo.turnPts = enemyHudInfo.turnPts + v.turnPts
  end
  love.graphics.print(text[12], (screen.w-font:getWidth(text[12]))/2, screen.h/4-9)
  love.graphics.setColor(palette.turnPts)
  enemyHudInfo.displayTurnPts = enemyHudInfo.displayTurnPts - (enemyHudInfo.displayTurnPts-enemyHudInfo.turnPts)/10
  love.graphics.rectangle("fill", screen.w/2-enemyHudInfo.displayTurnPts/enemyHudInfo.maxTurnPts*128, screen.h/4, enemyHudInfo.displayTurnPts/enemyHudInfo.maxTurnPts*256, 10)

end

function drawScanreaderHud()
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
end

function drawPlayerInfoHud()
  love.graphics.draw(playerHudBoxImg, 1, screen.h-52)
  love.graphics.print(playerActors[currentLevel.type][currentActor.actor].name, 4, screen.h-39-font:getHeight())
  love.graphics.setColor(palette.health)
  love.graphics.rectangle("fill", 4, screen.h-39, currentActor.displayHealth/playerActors[currentLevel.type][currentActor.actor].health*214, 3)--health


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
    love.graphics.setColor(palette.turnPts)
    love.graphics.rectangle("fill", 4, screen.h-34, currentActor.displayTurnPts/playerActors[currentLevel.type][currentActor.actor].turnPts*214, 3)--turnPts
  else
    love.graphics.setColor(gradient(5, palette.turnPts))
    love.graphics.rectangle("fill", 4, screen.h-34, currentActor.displayTurnPts/playerActors[currentLevel.type][currentActor.actor].turnPts*214, 3)-- current quantity of turnPts
    love.graphics.setColor(palette.turnPts)
    love.graphics.rectangle("fill", 4, screen.h-34, (currentActor.turnPts-num)/playerActors[currentLevel.type][currentActor.actor].turnPts*214, 3)--turnPts left after subtraction
  end
  love.graphics.setColor(255, 255, 255)
  if isPlayerVisible(currentActor, currentActorNum) == true then
    love.graphics.draw(statusEffectImg, statusEffectQuad[1], 209, screen.h-49)
  end

  for i = 1, 5 do
    if currentActor.mode == i then
      love.graphics.draw(combatButtonImg, combatButtonQuad[i*2-1], -43+i*44, screen.h-25)
    else
      love.graphics.draw(combatButtonImg, combatButtonQuad[i*2], -43+i*44, screen.h-25)
    end
  end
end

function gradient(speed, c1, c2)
  local num = love.timer.getTime()*speed
  if c2 ~= nil then
    return c1[1]*math.sin(num)+c2[1]*(1-math.sin(num)), c1[2]*math.sin(num)+c2[2]*(1-math.sin(num)), c1[3]*math.sin(num)+c2[3]*(1-math.sin(num))
  else
    return c1[1]*.25*math.sin(num)+c1[1]*.5*(1-math.sin(num)), c1[2]*.25*math.sin(num)+c1[2]*.5*(1-math.sin(num)), c1[3]*.25*math.sin(num)+c1[3]*.5*(1-math.sin(num))
  end
end
