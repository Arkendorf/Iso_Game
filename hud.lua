function hud_load()
  statusEffectInfoboxNums = {}
  enemyHudInfo = {turnPts = 0, maxTurnPts = 0, displayTurnPts = 0}

  playerHudBoxImg = drawBox(216, 21, 2)
end

function hud_update(dt)
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
  -- Draw minimap
  drawMap(map.x, map.y)


  -- Player Info
  drawPlayerInfoHud()

  if playerTurn == false then
    drawEnemyHud()
  end
end

function startEnemyHud()
  enemyHudInfo.maxTurnPts = 0
  for i, v in ipairs(currentLevel.enemyActors) do
    enemyHudInfo.maxTurnPts = enemyHudInfo.maxTurnPts + v.actor.item.turnPts
  end
  enemyHudInfo.displayTurnPts = enemyHudInfo.maxTurnPts
end

function drawEnemyHud()
  enemyHudInfo.turnPts = 0
  for i, v in ipairs(currentLevel.enemyActors) do
    enemyHudInfo.turnPts = enemyHudInfo.turnPts + v.turnPts
  end
  love.graphics.print(text[11], (screen.w-font:getWidth(text[11]))/2, screen.h/4-9)
  love.graphics.setColor(palette.turnPts)
  enemyHudInfo.displayTurnPts = enemyHudInfo.displayTurnPts - (enemyHudInfo.displayTurnPts-enemyHudInfo.turnPts)/10
  love.graphics.rectangle("fill", screen.w/2-enemyHudInfo.displayTurnPts/enemyHudInfo.maxTurnPts*128, screen.h/4, enemyHudInfo.displayTurnPts/enemyHudInfo.maxTurnPts*256, 10)
  love.graphics.setColor(255, 255, 255)
end

function drawMapKey()
  love.graphics.setColor(palette.yellow)
  love.graphics.print(text[1], 32, 0+4)

  love.graphics.setColor(palette.blue)
  love.graphics.print(text[2], 32, 16+4)

  love.graphics.setColor(palette.cyan)
  love.graphics.print(text[3], 32, 32+4)

  love.graphics.setColor(palette.purple)
  love.graphics.print(text[4], 32, 48+4)

  love.graphics.setColor(palette.red)
  love.graphics.print(text[5], 32, 64+4)
  love.graphics.setColor(255, 255, 255)
end

function drawPlayerInfoHud()
  love.graphics.draw(playerHudBoxImg, 1, screen.h-52)
  love.graphics.print(currentActor.actor.item.name, 4, screen.h-39-font:getHeight())
  love.graphics.setColor(palette.health)
  love.graphics.rectangle("fill", 4, screen.h-39, currentActor.displayHealth/currentActor.actor.item.health*214, 3)--health


  if currentActor.move == true or (currentActor.target.valid == false and currentActor.path.valid == false) then
    love.graphics.setColor(palette.turnPts)
    love.graphics.rectangle("fill", 4, screen.h-34, currentActor.displayTurnPts/currentActor.actor.item.turnPts*214, 3)--turnPts
  else
    love.graphics.setColor(gradient(5, palette.turnPts))
    love.graphics.rectangle("fill", 4, screen.h-34, currentActor.displayTurnPts/currentActor.actor.item.turnPts*214, 3)-- current quantity of turnPts
    if currentActor.turnPts-currentActor.currentCost > 0 then
      love.graphics.setColor(palette.turnPts)
      love.graphics.rectangle("fill", 4, screen.h-34, (currentActor.turnPts-currentActor.currentCost)/currentActor.actor.item.turnPts*214, 3)--turnPts left after subtraction
    end
  end
  love.graphics.setColor(255, 255, 255)

  local abilityNum = #currentActor.actor.item.abilities
  if abilityNum > 0 then -- draw weapon button border
    love.graphics.draw(combatButtonImg, combatButtonQuad[2], 1, screen.h-25)
  else
    love.graphics.draw(combatButtonImg, combatButtonQuad[1], 1, screen.h-25)
  end
  if currentActor.mode == 1 then -- draw weapon button icon
    love.graphics.draw(combatIconImg, combatIconOnQuad[weapons[currentActor.actor.item.weapon].icon], 1, screen.h-25)
  else
    love.graphics.draw(combatIconImg, combatIconOffQuad[weapons[currentActor.actor.item.weapon].icon], 1, screen.h-25)
  end
  for i = 1, abilityNum do
    if i == abilityNum then -- draw weapon button border
      love.graphics.draw(combatButtonImg, combatButtonQuad[4], 1+i*44, screen.h-25)
    else
      love.graphics.draw(combatButtonImg, combatButtonQuad[3], 1+i*44, screen.h-25)
    end
    if currentActor.mode == i+1 then
      love.graphics.draw(combatIconImg, combatIconOnQuad[abilities[currentActor.actor.item.abilities[i]].icon], 1+i*44, screen.h-25)
    else
      love.graphics.draw(combatIconImg, combatIconOffQuad[abilities[currentActor.actor.item.abilities[i]].icon], 1+i*44, screen.h-25)
      if currentActor.coolDowns[i] ~= 0 then -- draw turns left before ability can be used
        love.graphics.setFont(buttonFont)
        love.graphics.print(tostring(currentActor.coolDowns[i]), 4+i*44, screen.h-22)
        love.graphics.setFont(font)
      end
    end
  end
end

function gradient(speed, c1, c2)
  local num = love.timer.getTime()*speed
  if c2 then
    return c1[1]*math.sin(num)+c2[1]*(1-math.sin(num)), c1[2]*math.sin(num)+c2[2]*(1-math.sin(num)), c1[3]*math.sin(num)+c2[3]*(1-math.sin(num))
  else
    return c1[1]*.25*math.sin(num)+c1[1]*.5*(1-math.sin(num)), c1[2]*.25*math.sin(num)+c1[2]*.5*(1-math.sin(num)), c1[3]*.25*math.sin(num)+c1[3]*.5*(1-math.sin(num))
  end
end
