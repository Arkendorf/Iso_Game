function hazard_load()
  hazards = {}
  hazards[1] = {img = 1, drawType = 1, effect = 1}

  effects = {}
  effects[1] = {func = 1, length = 2, particle = 3, r = 255, g = 0, b = 255, pChance = 64}

  effectFuncs = {}

  effectFuncs[1] = function (v)
    v.turnPts = v.turnPts / 2
    v.displayTurnPts = v.turnPts
  end
end

function hazard_update(dt)
  for i, v in ipairs(currentLevel.actors) do
    for j = 1, #effects do
      if v.effects[j] ~= nil and math.random(1, effects[j].pChance) == 1 then
        newParticle(v.room, v.x, v.y, effects[j].particle, 0, charImgs.height[v.actor.item.img]-tileSize)
      end
    end
  end
  for i, v in ipairs(currentLevel.enemyActors) do
    for j = 1, #effects do
      if v.effects[j] ~= nil and math.random(1, effects[j].pChance) == 1 then
        newParticle(v.room, v.x, v.y, effects[j].particle, 0, charImgs.height[v.actor.item.img]-tileSize)
      end
    end
  end
  for i, v in pairs(hazardTiles.info) do
    v.frame = v.frame + dt * v.speed
    if v.frame > v.maxFrame+1 then
      v.frame = 1
    end
  end
end

function queueHazards(room)
  for i, v in ipairs(currentLevel.hazards) do
    if v.room == room and hazards[v.type].drawType == 2 then
      local x, y = tileToIso(v.tX, v.tY)
      if v.alpha < 255 then -- if hazard is being hidden, draw a marker
        local r, g, b = unpack(palette.red)
        love.graphics.setColor(r, g, b, 255-v.alpha)
        love.graphics.draw(tileTypeImg, x, y)
      end

      local img = hazards[v.type].img
      if hazardTiles.quad[img] == nil then
        drawQueue[#drawQueue + 1] = {type = 1, img = hazardTiles.img[img], x = x+tileSize*2-hazardTiles.width[img]/2, y = y+tileSize/2, z = hazardTiles.height[img]-tileSize, alpha = v.alpha}
      else
        drawQueue[#drawQueue + 1] = {type = 1, img = hazardTiles.img[img], quad = hazardTiles.quad[img][math.floor(hazardTiles.info[img].frame)], x = x+tileSize*2-hazardTiles.width[img]/2, y = y+tileSize/2, z = hazardTiles.height[img]-tileSize, alpha = v.alpha}
      end
    end
  end
end

function drawFlatHazards(room)
  for i, v in ipairs(currentLevel.hazards) do
    if v.room == room and hazards[v.type].drawType == 1 then
      local x, y = tileToIso(v.tX, v.tY)
      if v.alpha < 255 then -- if hazard is being hidden, draw a marker
        local r, g, b = unpack(palette.red)
        love.graphics.setColor(r, g, b, 255-v.alpha)
        love.graphics.draw(tileTypeImg, x, y)
      end

      local img = hazards[v.type].img
      love.graphics.setColor(255, 255, 255, v.alpha)
      if hazardTiles.quad[img] == nil then
        love.graphics.draw(hazardTiles.img[img], x+tileSize-hazardTiles.width[img]/2, y-hazardTiles.height[img]+tileSize)
      else
        love.graphics.draw(hazardTiles.img[img], hazardTiles.quad[img][math.floor(hazardTiles.info[img].frame)], x+tileSize-hazardTiles.width[img]/2, y-hazardTiles.height[img]+tileSize)
      end
    end
  end
end

function updateEffects(table)
  for i, v in ipairs(table) do
    local tX, tY = coordToTile(v.x, v.y)
    local result, item = tileInTable(tX, tY, v.room, currentLevel.hazards)
    if result then
      v.effects[hazards[item.type].effect] = effects[hazards[item.type].effect].length + 1
    end
    for j = 1, #effects do
      if v.effects[j] ~= nil then
        effectFuncs[effects[j].func](v)
        v.effects[j] = v.effects[j] - 1
        if v.effects[j] <= 0 then
          v.effects[j] = nil
        end
      end
    end
  end
end




function hideHazards(tX, tY, room, dt)
  local x, y = tileToIso(tX, tY)
  for i, v in ipairs(currentLevel.hazards) do
    if v.room == room and v.tX+2 > tX or v.tY+2 > tY then
      local img = hazards[v.type].img
      local x2, y2 = tileToIso(v.tX, v.tY)
      if (neighbors({x = tX, y = tY}, {x = v.tX, y = v.tY}) == true) or (y2 > y and y2-hazardTiles.height[img]+tileSize - y <= 0 and math.abs(x2 - x) <= hazardTiles.width[img]/2) then
        if v.alpha > 0 then
          v.alpha = v.alpha - dt * fadeSpeed
        else
          v.alpha = 0
        end
      else
        if v.alpha < 255 then
          v.alpha = v.alpha + dt * fadeSpeed
        else
          v.alpha = 255
        end
      end
    else
      if v.alpha < 255 then
        v.alpha = v.alpha + dt * fadeSpeed
      else
        v.alpha = 255
      end
    end
  end
end
