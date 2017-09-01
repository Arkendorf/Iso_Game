


function map_load()
  map = love.graphics.newCanvas(400, 300)
  mapTileSize = 6
end

function drawMapTiles(room, size) -- what room to draw, size of tiles
  --tiles
  local map = rooms[room]
  for i, v in ipairs(map) do
    for j, k in ipairs(v) do
      if tileType[k] ~= 0 then
        if tileType[k] == 1 then
          love.graphics.setColor(palette.yellow)
        elseif tileType[k] == 2 then
          love.graphics.setColor(palette.red)
        elseif tileType[k] == 3 then
          love.graphics.setColor(palette.cyan)
        end
        love.graphics.draw(mapTileImg, mapToIso(j, i))
        love.graphics.setColor(255, 255, 255)
      end
    end
  end

  -- doors and hazards
  -- for i, v in ipairs(currentLevel.doors) do
  --   if v.room1 == room then
  --     love.graphics.setColor(palette.purple)
  --     love.graphics.rectangle("fill", (v.tX1-1)*size, (v.tY1-1)*size, size-1, size-1)
  --     love.graphics.setColor(255, 255, 255)
  --   elseif v.room2 == room then
  --     love.graphics.setColor(palette.purple)
  --     love.graphics.rectangle("fill", (v.tX2-1)*size, (v.tY2-1)*size, size-1, size-1)
  --     love.graphics.setColor(255, 255, 255)
  --   end
  -- end
  -- for i, v in ipairs(currentLevel.hazards) do
  --   if v.room == room then
  --     love.graphics.setColor(palette.red)
  --     love.graphics.rectangle("fill", (v.tX-1)*size, (v.tY-1)*size, size-1-1, size)
  --     love.graphics.setColor(255, 255, 255)
  --   end
  -- end
  --
  -- --players and enemies
  -- for i, v in ipairs(currentLevel.actors) do
  --   if v.room == room then
  --     love.graphics.setColor(palette.green)
  --     love.graphics.rectangle("fill", math.floor((v.x/tileSize)*size), math.floor((v.y/tileSize)*size), size-1, size-1)
  --     love.graphics.setColor(255, 255, 255)
  --   end
  -- end
  -- for i, v in ipairs(currentLevel.enemyActors) do
  --   if v.room == room then
  --     love.graphics.setColor(palette.red)
  --     love.graphics.rectangle("fill", math.floor((v.x/tileSize)*size), math.floor((v.y/tileSize)*size), size-1, size-1)
  --     love.graphics.setColor(255, 255, 255)
  --   end
  -- end
end

function map_draw()
  local canvas, oldCanvas = resumeCanvas(map)
  love.graphics.push()
  love.graphics.translate(0, 0)
  drawMapTiles(currentRoom, mapTileSize)
  love.graphics.pop()

  love.graphics.setCanvas(oldCanvas)

  love.graphics.draw(mapBoxImg, 0, 0)
  love.graphics.draw(map, 3, 3)
end
