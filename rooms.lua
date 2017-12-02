function rooms_load()
  rooms = {}
  rooms[1] = {{1, 1, 1, 2, 1, 1},
              {1, 1, 1, 2, 1, 1},
              {1, 1, 1, 3, 3, 1},
              {1, 1, 1, 1, 1, 1},
              {1, 1, 1, 1, 1, 1},
              {2, 2, 2, 2, 1, 1}}
  rooms[2] = {{1, 1, 1, 1, 1, 1},
              {1, 1, 1, 2, 1, 1},
              {1, 1, 1, 2, 1, 1},
              {1, 1, 1, 3, 1, 1},
              {3, 1, 3, 3, 1, 1},
              {1, 1, 1, 1, 1, 1}}
  tileType = {[0] = 0, [1] = 1, [2] = 2, [3] = 3, [4] = 2, [5] = 1}
  roomAlphas = {}
  roomNodes = {}

  drawQueue = {}
  fadeSpeed = 1024
end

function rooms_update(dt)
  for i, v in pairs(tiles.info) do
    v.frame = v.frame + dt * v.speed
    if v.frame > v.maxFrame+1 then
      v.frame = 1
    end
  end
  hideObstructions(cursorPos.tX, cursorPos.tY, currentRoom, dt)

  updateOldRoom(dt)
end

function rooms_draw()
  drawRoom(currentRoom)
end

function drawRoom(room)
  love.graphics.setColor(255, 255, 255)
  drawFloor(room) -- floor is drawn first so it will be at the bottom

  drawFlatHazards(room) -- draw hazards that will be beneath everything regardless
  drawFlatDoors(room)
  drawFinish(room)
  drawFlatParticles(room)

  setValidColor(currentActor, newMove) -- sets color of path indicator
  if currentActor.mode == 0 and room == currentActor.room then
    drawPath(currentActor, newMove.path.tiles) -- draws path indicator
  end
  mouse_draw()

  drawQueue = {} -- reset queue
  queueWalls(room)
  queueCover(room)
  queueHazards(room)
  queueDoors(room)
  queueChars(room)
  queueEnemyChars(room)
  queueParticles(room)
  queueProjectiles(room)
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
    if v.alpha and v.alpha < 255 then
      love.graphics.setShader(shaders.pixelFade) -- if object is partially transparent, set shader accordingly
      shaders.pixelFade:send("a", v.alpha/255)
    end
    love.graphics.setColor(v.r, v.g, v.b)

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
    love.graphics.setShader() -- reset shader
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
  resetHiddenObstructions(room)
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
          love.graphics.setColor(r, g, b)
        else
          local r, g, b = unpack(palette.cyan)
          love.graphics.setColor(r, g, b)
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
  for i, v in ipairs(rooms[room]) do -- set "transparency" for tiles
    for j, t in ipairs(v) do
      local img = rooms[room][i][j]
      local x2, y2 = tileToIso(j, i)
      if (j+2 > tX or i+2 > tY) and ((neighbors({x = tX, y = tY}, {x = j, y = i}) == true) or (y2 > y and y2-tiles.height[img]+tileSize - y <= 0 and math.abs(x2 - x) <= tiles.width[img]/2)) then
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
    end
  end
  for i, v in ipairs(currentLevel.hazards) do -- set "transparency" for hazards
    local img = hazards[v.type].img
    local x2, y2 = tileToIso(v.tX, v.tY)
    if v.room == room and (v.tX+2 > tX or v.tY+2 > tY) and ((neighbors({x = tX, y = tY}, {x = v.tX, y = v.tY}) == true) or (y2 > y and y2-hazardTiles.height[img]+tileSize - y <= 0 and math.abs(x2 - x) <= hazardTiles.width[img]/2)) then
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
  end
  for i, v in ipairs(currentLevel.doors) do -- set "transparency" for doors
    if room == v.room1 then
      local tX2, tY2 = v.tX1, v.tY1
      if v.blocked[1] == true then
        img = doors[v.type].img2
      else
        img = doors[v.type].img1
      end
      local x2, y2 = tileToIso(tX2, tY2)
      if (tX2+2 > tX or tY2+2 > tY) and ((neighbors({x = tX, y = tY}, {x = tX2, y = tY2}) == true) or (y2 > y and y2-doorTiles.height[img]+tileSize - y <= 0 and math.abs(x2 - x1) <= doorTiles.width[img]/2)) then
        if v.alpha1 > 0 then
          v.alpha1 = v.alpha1 - dt * fadeSpeed
        else
          v.alpha1 = 0
        end
      else
        if v.alpha1 < 255 then
          v.alpha1 = v.alpha1 + dt * fadeSpeed
        else
          v.alpha1 = 255
        end
      end
    end
    if room == v.room2 then
      local tX2, tY2 = v.tX2, v.tY2
      if v.blocked[2] == true then
        img = doors[v.type].img2
      else
        img = doors[v.type].img1
      end
      local x2, y2 = tileToIso(tX2, tY2)
      if (tX2+2 > tX or tY2+2 > tY) and ((neighbors({x = tX, y = tY}, {x = tX2, y = tY2}) == true) or (y2 > y and y2-doorTiles.height[img]+tileSize - y <= 0 and math.abs(x2 - x1) <= doorTiles.width[img]/2)) then
        if v.alpha2 > 0 then
          v.alpha2 = v.alpha2 - dt * fadeSpeed
        else
          v.alpha2 = 0
        end
      else
        if v.alpha2 < 255 then
          v.alpha2 = v.alpha2 + dt * fadeSpeed
        else
          v.alpha2 = 255
        end
      end
    end
  end
end

function resetHiddenObstructions(room)
  for i, v in ipairs(rooms[room]) do
    for j, t in ipairs(v) do
      roomAlphas[room][i][j] = 255
    end
  end
  for i, v in ipairs(currentLevel.hazards) do
    if v.room == room then
      v.alpha = 255
    end
  end
  for i, v in ipairs(currentLevel.doors) do
    if v.room1 == room or v.room2 == room then
      v.alpha = 255
    end
  end
end

function drawOldRoom()
  if oldRoom and oldRoom.pos < screen.w then
    love.graphics.setShader(shaders.swap) -- if object is partially transparent, set shader accordingly
    shaders.swap:send("pos", oldRoom.pos)

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, screen.w, screen.h) -- temporary extra background
    love.graphics.setColor(255, 255, 255)

    love.graphics.draw(oldRoom.canvas)

    love.graphics.setShader()
  end
end

function updateOldRoom(dt)
  if oldRoom and oldRoom.pos < screen.w then
    oldRoom.pos = oldRoom.pos + dt * 1440

    oldRoom.canvas, oldCanvas = resumeCanvas(oldRoom.canvas)
    love.graphics.push()
    love.graphics.translate(cameraPos.x, cameraPos.y)
    drawRoom(oldRoom.room)
    love.graphics.setCanvas(oldCanvas)
    love.graphics.pop()
  else
    oldRoom = nil
  end
end

function startOldRoom()
  oldRoom = {pos = 0, room = currentRoom}
  oldRoom.canvas, oldCanvas = startNewCanvas(screen.w, screen.h)
  love.graphics.push()
  love.graphics.translate(cameraPos.x, cameraPos.y)
  drawRoom(oldRoom.room)
  love.graphics.setCanvas(oldCanvas)
  love.graphics.pop()
end
