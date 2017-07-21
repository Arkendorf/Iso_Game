function drawDoors()
  for i, v in ipairs(levels[currentLevel].doors) do
    if v.room1 == currentRoom then
      if isDoorObstructed(i, 1) == true then
        love.graphics.setColor(255, 0, 0)
      else
        love.graphics.setColor(255, 225, 0)
      end
      love.graphics.draw(door, tileToIso(v.tX1-1, v.tY1-1))
    elseif v.room2 == currentRoom then
      if isDoorObstructed(i, 2) == true then
        love.graphics.setColor(255, 0, 0)
      else
        love.graphics.setColor(255, 225, 0)
      end
      love.graphics.draw(door, tileToIso(v.tX2-1, v.tY2-1))
    end
  end
end

function tileDoorInfo(room, tX, tY)
  for i, v in ipairs(levels[currentLevel].doors) do
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
    currentDoor = levels[currentLevel].doors[door]
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
  currentDoor = levels[currentLevel].doors[door]
  if side == 1 then
    local x, y = tileToCoord(currentDoor.tX2, currentDoor.tY2)
    for i, v in ipairs(levels[currentLevel].actors) do
      if (v.room == currentDoor.room2 and v.x == x and v.y == y) or (v.move == true and v.room == currentDoor.room2 and v.path[#v.path].x == currentDoor.tX2 and v.path[#v.path].y == currentDoor.tY2) then
        return true
      end
    end
  else
    local x, y = tileToCoord(currentDoor.tX1, currentDoor.tY1)
    for i, v in ipairs(levels[currentLevel].actors) do
      if (v.room == currentDoor.room1 and v.x == x and v.y == y) or (v.move == true and v.room == currentDoor.room1 and v.path[#v.path].x == currentDoor.tX1 and v.path[#v.path].y == currentDoor.tY1) then
        return true
      end
    end
  end
  return false
end
