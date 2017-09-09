function hazard_load()
  hazards = {}
  hazards[1] = {img = hazardImg, func = 1, drawType = 1, length = 2, particle = 2}

  hazardParticleChance = 32

  hazardFuncs = {}

  hazardFuncs[1] = function (v)
    v.turnPts = v.turnPts / 2
  end
end

function queueHazards(room)
  for i, v in ipairs(currentLevel.hazards) do
    if v.room == room and hazards[v.type].drawType == 2 then
      local x, y = tileToIso(v.tX, v.tY)
      drawQueue[#drawQueue + 1] = {type = 1, img = hazards[v.type].img, quad = hazards[v.type].quad, x = x+tileSize, y = y+tileSize/2, z= hazards[v.type].img:getHeight()-tileSize}
    end
  end
end

function drawFlatHazards(room)
  for i, v in ipairs(currentLevel.hazards) do
    if v.room == room and hazards[v.type].drawType == 1 then
      local x, y = tileToIso(v.tX, v.tY)
      if hazards[v.type].quad == nil then
        love.graphics.draw(hazards[v.type].img, x, y)
      else
        love.graphics.draw(hazards[v.type].img, hazards[v.type].quad, x, y)
      end
    end
  end
end

function updateEffects(table)
  for i, v in ipairs(table) do
    for j, k in ipairs(currentLevel.hazards) do
      local x, y = tileToCoord(k.tX, k.tY)
      if v.x == x and v.y == y then
        v.effects[k.type] = hazards[k.type].length + 1
      end
    end
    for j = 1, #hazards do
      if v.effects[j] ~= nil then
        hazardFuncs[hazards[j].func](v)
        v.effects[j] = v.effects[j] - 1
        if v.effects[j] <= 0 then
          v.effects[j] = nil
        end
      end
    end
  end
end
