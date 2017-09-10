function rooms_load()
  rooms = {}
  rooms[1] = {{2, 1, 2, 1, 1, 1},
              {4, 1, 4, 1, 5, 1},
              {2, 1, 1, 3, 3, 1},
              {2, 1, 5, 1, 5, 1},
              {4, 1, 1, 2, 1, 5},
              {4, 1, 2, 4, 5, 5}}
  rooms[2] = {{1, 1, 1, 1, 1, 1},
              {1, 1, 2, 2, 1, 1},
              {1, 1, 2, 2, 1, 1},
              {1, 1, 2, 2, 1, 1},
              {1, 1, 2, 2, 1, 1},
              {1, 1, 1, 1, 1, 1}}
  tileType = {[0] = 0, [1] = 1, [2] = 2, [3] = 3, [4] = 2, [5] = 1}
  floors = {}
  roomNodes = {}

  drawQueue = {}
end

function rooms_update(dt)
  for i, v in pairs(tiles.quadInfo) do
    v.frame = v.frame + dt * v.speed
    if v.frame > v.maxFrame+1 then
      v.frame = 1
    end
  end
end

function rooms_draw()
  drawRoom()
  mouse_draw()
  love.graphics.setColor(255, 255, 255)
end

function drawRoom()
  drawFloor(currentRoom) -- floor is drawn first so it will be at the bottom

  drawFlatHazards(currentRoom)

  setValidColor(currentActor.path.valid) -- sets color of path indicator

  if currentActor.mode == 0 then
    drawPath(currentActor) -- draws path indicator
  end

  drawQueue = {} -- reset queue
  queueWalls(currentRoom)
  queueCover(currentRoom)
  queueHazards(currentRoom)
  queueChars(currentRoom)
  queueEnemyChars(currentRoom)
  queueParticles(currentRoom)
  queueProjectiles(currentRoom)
  table.sort(drawQueue, function(a, b) return a.y < b.y end) -- sort queue to ensure proper layering
  drawItemsInQueue() -- draw items in queue
end

function drawItemsInQueue()
  for i, v in ipairs(drawQueue) do
    if v.r == nil or v.g == nil or v.b == nil then -- set the color if a color is given
      v.r = 255
      v.g = 255
      v.b = 255
    end
    if v.alpha == nil then
      v.alpha = 255
    end
    love.graphics.setColor(v.r, v.g, v.b, v.alpha)

    if v.type == 1 then
      if v.quad == nil then
        love.graphics.draw(v.img, v.x, v.y-v.z, 0, 1, 1, tileSize, tileSize/2)
      else
        love.graphics.draw(v.img, v.quad, v.x, v.y-v.z, 0, 1, 1, tileSize, tileSize/2)
      end
    elseif v.type == 2 then
      if v.quad == nil then
        local w, h = v.img:getDimensions()
        love.graphics.draw(v.img, v.x, v.y-v.z, v.angle, 1, 1, math.floor(w/2), math.floor(h/2))
      else
        local x, y, w, h = v.quad:getViewport()
        love.graphics.draw(v.img, v.quad, v.x, v.y-v.z, v.angle, 1, 1, math.floor(w/2), math.floor(h/2))
      end
    end
  end
  love.graphics.setColor(225, 255, 255)
end

function queueWalls(room)
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if tileType[rooms[room][i][j]] == 2 then
        local x, y = tileToIso(j, i)
        local tile = rooms[room][i][j]
        if tiles.quad[tile] == nil then
          drawQueue[#drawQueue + 1] = {type = 1, img = tiles.img[tile], x = x+tileSize, y = y+tileSize/2, z = tiles.height[tile]-tileSize}
        else
          drawQueue[#drawQueue + 1] = {type = 1, img = tiles.img[tile], quad = tiles.quad[tile][math.floor(tiles.quadInfo[tile].frame)], x = x+tileSize, y = y+tileSize/2, z = tiles.height[tile]-tileSize}
        end
      end
    end
  end
end

function queueCover(room)
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if tileType[rooms[room][i][j]] == 3 then
        local x, y = tileToIso(j, i)
        local tile = rooms[room][i][j]
        if tiles.quad[tile] == nil then
          drawQueue[#drawQueue + 1] = {type = 1, img = tiles.img[tile], x = x+tileSize, y = y+tileSize/2, z = tiles.height[tile]-tileSize}
        else
          drawQueue[#drawQueue + 1] = {type = 1, img = tiles.img[tile], quad = tiles.quad[tile][math.floor(tiles.quadInfo[tile].frame)], x = x+tileSize, y = y+tileSize/2, z = tiles.height[tile]-tileSize}
        end
      end
    end
  end
end

function startRoom(room)
  roomNodes = createIsoNodes(room)
end

function drawFloor(room)
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if tileType[t] == 1 then
        local x, y = tileToIso(j, i)
        local tile = rooms[room][i][j]
        if tiles.quad[tile] == nil then
          love.graphics.draw(tiles.img[tile], x, y-tiles.height[tile]+tileSize)
        else
          love.graphics.draw(tiles.img[tile], tiles.quad[tile][math.floor(tiles.quadInfo[tile].frame)], x, y-tiles.height[tile]+tileSize)
        end
      end
    end
  end
end

function createIsoNodes(room)
  roomNodes = {}
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if tileType[t] == 1 then
        local x, y = tileToIso(j, i)
        roomNodes[#roomNodes + 1] = {tX = j, tY = i, x = x + tileSize, y = y + tileSize/2}
      end
    end
  end
  return roomNodes
end
