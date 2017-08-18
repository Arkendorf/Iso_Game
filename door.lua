function drawDoors(room)
  for i, v in ipairs(currentLevel.doors) do
    if v.room1 == room then
      if isDoorObstructed(i, 1) == true then
        love.graphics.setColor(palette.red)
      else
        love.graphics.setColor(palette.purple)
      end
      love.graphics.draw(scanBorderImg, scanBorderQuad[bitmaskFromDoors(room, v.tX1, v.tY1)], tileToIso(v.tX1, v.tY1))
      love.graphics.draw(scanIconImg, scanIconQuad[4], tileToIso(v.tX1, v.tY1))
    elseif v.room2 == room then
      if isDoorObstructed(i, 2) == true then
        love.graphics.setColor(palette.red)
      else
        love.graphics.setColor(palette.purple)
      end
      love.graphics.draw(scanBorderImg, scanBorderQuad[bitmaskFromDoors(room, v.tX2, v.tY2)], tileToIso(v.tX2, v.tY2))
      love.graphics.draw(scanIconImg, scanIconQuad[4], tileToIso(v.tX2, v.tY2))
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
