function rooms_load()
  rooms = {}
  rooms[1] = {{2, 1, 2, 1, 1, 1},
              {4, 1, 4, 1, 5, 1},
              {2, 1, 1, 3, 3, 1},
              {2, 1, 5, 1, 5, 1},
              {4, 1, 1, 2, 1, 5},
              {4, 1, 2, 4, 5, 5}}
  rooms[2] = {{1, 1, 1, 1, 1, 1},
              {1, 1, 4, 4, 1, 1},
              {1, 1, 2, 4, 1, 1},
              {1, 1, 2, 2, 1, 1},
              {1, 1, 2, 4, 1, 5},
              {1, 1, 1, 1, 1, 1}}
  tileType = {[0] = 0, [1] = 1, [2] = 2, [3] = 3, [4] = 2, [5] = 1}
  roomAlphas = {}
  roomNodes = {}

  drawQueue = {}
  fadeSpeed = 500
end

function rooms_update(dt)
  for i, v in pairs(tiles.info) do
    v.frame = v.frame + dt * v.speed
    if v.frame > v.maxFrame+1 then
      v.frame = 1
    end
  end
  hideObstructions(cursorPos.tX, cursorPos.tY, currentRoom, dt)
  hideHazards(cursorPos.tX, cursorPos.tY, currentRoom, dt)
  hideDoors(cursorPos.tX, cursorPos.tY, currentRoom, dt)
end

function rooms_draw()
  drawRoom()
  love.graphics.setColor(255, 255, 255)
end

function drawRoom()
  drawFloor(currentRoom) -- floor is drawn first so it will be at the bottom

  drawFlatHazards(currentRoom) -- draw hazards that will be beneath everything regardless
  drawFlatDoors(currentRoom)
  drawFlatParticles(currentRoom)

  setValidColor(currentActor) -- sets color of path indicator
  if currentActor.mode == 0 then
    drawPath(currentActor) -- draws path indicator
  end
  mouse_draw()

  drawQueue = {} -- reset queue
  queueWalls(currentRoom)
  queueCover(currentRoom)
  queueHazards(currentRoom)
  queueDoors(currentRoom)
  queueChars(currentRoom)
  queueEnemyChars(currentRoom)
  queueParticles(currentRoom)
  queueProjectiles(currentRoom)
  table.sort(drawQueue, function(a, b) return a.y < b.y end) -- sort queue to ensure proper layering
  drawItemsInQueue() -- draw items in queue
end

function drawItemsInQueue()
  for i, v in ipairs(drawQueue) do
    if not v.r or not v.g or not v.b then -- set the color if a color is given
      v.r = 255
      v.g = 255
      v.b = 255
    end
    if not v.alpha then
      v.alpha = 255
    end
    love.graphics.setColor(v.r, v.g, v.b, v.alpha)

    if v.type == 1 then
      if not v.quad then
        love.graphics.draw(v.img, v.x, v.y-v.z, 0, 1, 1, tileSize, tileSize/2)
      else
        love.graphics.draw(v.img, v.quad, v.x, v.y-v.z, 0, 1, 1, tileSize, tileSize/2)
      end
    elseif v.type == 2 then

      if not v.quad then
        if not v.w then
          v.w = v.img:getWidth()
        end
        if not v.h then
          v.h = v.img:getHeight()
        end
        love.graphics.draw(v.img, v.x, v.y-v.z, v.angle, 1, 1, math.floor(v.w/2), math.floor(v.h/2))
      else
        local _, _, w, h = v.quad:getViewport()
        if not v.w then
          v.w = w
        end
        if not v.h then
          v.h = h
        end
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
        local img = rooms[room][i][j]
        if not tiles.quad[img] then
          drawQueue[#drawQueue + 1] = {type = 1, img = tiles.img[img], x = x+tileSize*2-tiles.width[img]/2, y = y+tileSize/2, z = tiles.height[img]-tileSize, alpha = roomAlphas[room][i][j]}
        else
          drawQueue[#drawQueue + 1] = {type = 1, img = tiles.img[img], quad = tiles.quad[img][math.floor(tiles.info[img].frame)], x = x+tileSize*2-tiles.width[img]/2, y = y+tileSize/2, z = tiles.height[img]-tileSize, alpha = roomAlphas[room][i][j]}
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
        local img = rooms[room][i][j]
        if not tiles.quad[img] then
          drawQueue[#drawQueue + 1] = {type = 1, img = tiles.img[img], x = x+tileSize*2-tiles.width[img]/2, y = y+tileSize/2, z = tiles.height[img]-tileSize, alpha = roomAlphas[room][i][j]}
        else
          drawQueue[#drawQueue + 1] = {type = 1, img = tiles.img[img], quad = tiles.quad[img][math.floor(tiles.info[img].frame)], x = x+tileSize*2-tiles.width[img]/2, y = y+tileSize/2, z = tiles.height[img]-tileSize, alpha = roomAlphas[room][i][j]}
        end
      end
    end
  end
end

function startRoom(room)
  roomNodes = createIsoNodes(room)
  if not roomAlphas[room] then
    roomAlphas[room] = createRoomAlpha(room)
  end
end

function createRoomAlpha(room)
  local map = {}
  for i, v in ipairs(rooms[room]) do
    map[i] = {}
    for j, t in ipairs(v) do
      map[i][j] = 255
    end
  end
  return map
end

function drawFloor(room)
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if tileType[t] == 1 then
        local x, y = tileToIso(j, i)
        local img = rooms[room][i][j]
        if not tiles.quad[img] then
          love.graphics.draw(tiles.img[img], x+tileSize-tiles.width[img]/2, y-tiles.height[img]+tileSize)
        else
          love.graphics.draw(tiles.img[img], tiles.quad[img][math.floor(tiles.info[img].frame)], x+tileSize-tiles.width[img]/2, y-tiles.height[img]+tileSize)
        end
      elseif roomAlphas[room][i][j] < 255 then -- if tile is being hidden, draw a marker
        local x, y = tileToIso(j, i)
        if tileType[t] == 2 then
          local r, g, b = unpack(palette.blue)
          love.graphics.setColor(r, g, b, 255-roomAlphas[room][i][j])
        else
          local r, g, b = unpack(palette.cyan)
          love.graphics.setColor(r, g, b, 255-roomAlphas[room][i][j])
        end
        love.graphics.draw(tileTypeImg, x, y)
        love.graphics.setColor(255, 255, 255)
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

function hideObstructions(tX, tY, room, dt)
  local x, y = tileToIso(tX, tY)
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      if j+2 > tX or i+2 > tY then
        local img = rooms[room][i][j]
        local x2, y2 = tileToIso(j, i)
        if (neighbors({x = tX, y = tY}, {x = j, y = i}) == true) or (y2 > y and y2-tiles.height[img]+tileSize - y <= 0 and math.abs(x2 - x) <= tiles.width[img]/2) then
          if roomAlphas[room][i][j] > 0 then
            roomAlphas[room][i][j] = roomAlphas[room][i][j] - dt * fadeSpeed
          else
            roomAlphas[room][i][j] = 0
          end
        else
          if roomAlphas[room][i][j] < 255 then
            roomAlphas[room][i][j] = roomAlphas[room][i][j] + dt * fadeSpeed
          else
            roomAlphas[room][i][j] = 255
          end
        end
      else
        if roomAlphas[room][i][j] < 255 then
          roomAlphas[room][i][j] = roomAlphas[room][i][j] + dt * fadeSpeed
        else
          roomAlphas[room][i][j] = 255
        end
      end
    end
  end
end
