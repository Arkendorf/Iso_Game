function door_load()
  doors = {}
  doors[1] = {img1 = 1, img2 = 2, drawType = 1}
end

function door_update(dt)
  for i, v in pairs(doorTiles.quadInfo) do
    v.frame = v.frame + dt * v.speed
    if v.frame > v.maxFrame+1 then
      v.frame = 1
    end
  end
end

function queueDoors(room)
  for i, v in ipairs(currentLevel.doors) do
    if (v.room1 == room or v.room2 == room) and doors[v.type].drawType == 2 then
      local x, y = nil
      local img = nil
      if v.room1 == room then
        x, y = tileToIso(v.tX1, v.tY1)
        if isDoorObstructed(i, 1) == true then
          img = doors[v.type].img2
        else
          img = doors[v.type].img1
        end
      else
        x, y = tileToIso(v.tX2, v.tY2)
        if isDoorObstructed(i, 2) == true then
          img = doors[v.type].img2
        else
          img = doors[v.type].img1
        end
      end
      if v.alpha < 255 then -- if door is being hidden, draw a marker
        local r, g, b = unpack(palette.yellow)
        love.graphics.setColor(r, g, b, 255-v.alpha)
        love.graphics.draw(tileTypeImg, x, y)
      end


      local img = doors[v.type].img1
      if doorTiles.quad[img] == nil then
        drawQueue[#drawQueue + 1] = {type = 1, img = doorTiles.img[img], x = x+tileSize*2-doorTiles.width[img]/2, y = y+tileSize/2, z = doorTiles.height[img]-tileSize, alpha = v.alpha}
      else
        drawQueue[#drawQueue + 1] = {type = 1, img = doorTiles.img[img], quad = doorTiles.quad[img][math.floor(doorTiles.quadInfo[img].frame)], x = x+tileSize*2-doorTiles.width[img]/2, y = y+tileSize/2, z = doorTiles.height[img]-tileSize, alpha = v.alpha}
      end
    end
  end
end

function drawFlatDoors(room)
  for i, v in ipairs(currentLevel.doors) do
    if (v.room1 == room or v.room2 == room) and doors[v.type].drawType == 1 then
      local x, y = nil
      local img = nil
      if v.room1 == room then
        x, y = tileToIso(v.tX1, v.tY1)
        if isDoorObstructed(i, 1) == true then
          img = doors[v.type].img2
        else
          img = doors[v.type].img1
        end
      else
        x, y = tileToIso(v.tX2, v.tY2)
        if isDoorObstructed(i, 2) == true then
          img = doors[v.type].img2
        else
          img = doors[v.type].img1
        end
      end
      if v.alpha < 255 then -- if door is being hidden, draw a marker
        local r, g, b = unpack(palette.yellow)
        love.graphics.setColor(r, g, b, 255-v.alpha)
        love.graphics.draw(tileTypeImg, x, y)
      end

      love.graphics.setColor(255, 255, 255, v.alpha)
      if doorTiles.quad[img] == nil then
        love.graphics.draw(doorTiles.img[img], x+tileSize-doorTiles.width[img]/2, y-doorTiles.height[img]+tileSize)
      else
        love.graphics.draw(doorTiles.img[img], doorTiles.quad[img][math.floor(doorTiles.quadInfo[img].frame)], x+tileSize-doorTiles.width[img]/2, y-doorTiles.height[img]+tileSize)
      end
    end
  end
end


function tileDoorInfo(room, tX, tY)
  for i, v in ipairs(currentLevel.doors) do
    if room == v.room1 and tX == v.tX1 and tY == v.tY1 then
      return i, 1
    elseif room == v.room2 and tX == v.tX2 and tY == v.tY2 then
      return i, 2
    end
  end
  return nil
end

function useDoor(door, side)
  if door ~= nil and side ~= nil then
    currentDoor = currentLevel.doors[door]
    if side == 1 then
      local x, y = tileToCoord(currentDoor.tX2, currentDoor.tY2)
      if isDoorObstructed(door, side) == true then
        return
      else
        return {room = currentDoor.room2, x = x, y = y}
      end
    else
      local x, y = tileToCoord(currentDoor.tX1, currentDoor.tY1)
      if isDoorObstructed(door, side) == true then
        return
      else
        return {room = currentDoor.room1, x = x, y = y}
      end
    end
  end
end

function isDoorObstructed(door, side)
  currentDoor = currentLevel.doors[door]
  if side == 1 then
    local x, y = tileToCoord(currentDoor.tX2, currentDoor.tY2)
    for i, v in ipairs(currentLevel.actors) do -- check if player actor is obstructing door on side 1
      if (v.room == currentDoor.room2 and v.x == x and v.y == y) or (v.move == true and v.room == currentDoor.room2 and v.path.tiles[#v.path.tiles].x == currentDoor.tX2 and v.path.tiles[#v.path.tiles].y == currentDoor.tY2) then
        return true
      end
    end
    for i, v in ipairs(currentLevel.enemyActors) do  -- check if enemy actor is obstructing door on side 1
      if (v.room == currentDoor.room2 and v.x == x and v.y == y) or (v.move == true and v.room == currentDoor.room2 and v.path.tiles[#v.path.tiles].x == currentDoor.tX2 and v.path.tiles[#v.path.tiles].y == currentDoor.tY2) then
        return true
      end
    end
  else
    local x, y = tileToCoord(currentDoor.tX1, currentDoor.tY1)
    for i, v in ipairs(currentLevel.actors) do  -- check if player actor is obstructing door on side 2
      if (v.room == currentDoor.room1 and v.x == x and v.y == y) or (v.move == true and v.room == currentDoor.room1 and v.path.tiles[#v.path.tiles].x == currentDoor.tX1 and v.path.tiles[#v.path.tiles].y == currentDoor.tY1) then
        return true
      end
    end
    for i, v in ipairs(currentLevel.enemyActors) do  -- check if enemy actor is obstructing door on side 2
      if (v.room == currentDoor.room1 and v.x == x and v.y == y) or (v.move == true and v.room == currentDoor.room1 and v.path.tiles[#v.path.tiles].x == currentDoor.tX1 and v.path.tiles[#v.path.tiles].y == currentDoor.tY1) then
        return true
      end
    end
  end
  return false
end

function hideDoors(x, y, room, dt)
  local tX1, tY1 = coordToTile(x, y)
  local x2, y2 = coordToIso(x, y)
  for i, v in ipairs(currentLevel.doors) do
    local tX2, tY2 = nil
    if room == v.room1 then
      tX2, tY2 = v.tX1, v.tY1
    else
      tX2, tY2 = v.tX2, v.tY2
    end
    if tX2+2 > tX1 or tY2+2 > tY1 and (room == v.room1 or room == v.room2) then
      local x3, y3 = tileToIso(tX2, tY2)
      if (neighbors({x = tX1, y = tY1}, {x = tX2, y = tY2}) == true) or (y3 > y2 and y3-16+tileSize - y2 <= 0 and math.abs(x3 - x2) <= 32/2) then
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
