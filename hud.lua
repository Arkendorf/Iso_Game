function hud_load()
  statusEffectInfoboxNums = {}
end

function hud_update(dt)
  if visiblePlayers[currentActor.room][currentActorNum] == true then
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
  love.graphics.print(playerActors[levels[currentLevel].type][currentActor.actor].name, 1, screen.h-9-font:getHeight())
  love.graphics.setColor(255, 0, 0)
  love.graphics.rectangle("fill", 1, screen.h-9, 128, 3)
  love.graphics.setColor(0, 255, 255)
  love.graphics.rectangle("fill", 1, screen.h-4, 128, 3)
  love.graphics.setColor(255, 255, 255)
  if visiblePlayers[currentActor.room][currentActorNum] == true then
    love.graphics.draw(statusEffectImg, statusEffectQuad[1], 130, screen.h-20)
  end
end
