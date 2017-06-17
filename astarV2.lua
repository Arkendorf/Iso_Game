function newPath(start, finish, map)
  local openList = {{x = start.x, y = start.y, g = 0, h = distance(finish.x, finish.y, start.x, start.y)}}
  local closedList = {}
  local result, i = inList(finish.x, finish.y, closedList)
  while result == false and #openList > 0 do
    local currentTile = openList[1] -- lowest F cost will always be sorted to front
    closedList[#closedList+1] = currentTile
    table.remove(openList, 1)

    openList = checkTile(currentTile.x+1, currentTile.y,   currentTile.g+1, currentTile, openList, closedList, finish, map)
    openList = checkTile(currentTile.x-1, currentTile.y,   currentTile.g+1, currentTile, openList, closedList, finish, map)
    openList = checkTile(currentTile.x,   currentTile.y+1, currentTile.g+1, currentTile, openList, closedList, finish, map)
    openList = checkTile(currentTile.x,   currentTile.y-1, currentTile.g+1, currentTile, openList, closedList, finish, map)

    result, i = inList(finish.x, finish.y, closedList)
  end
  if result == false and #openList == 0 then
    return {}
  else
    local path = {}
    local parent = closedList[i]
    while parent ~= nil do
      path[#path+1] = {x = parent.x, y = parent.y}
      parent = parent.parent
    end
    return path
  end
end

function checkTile(x, y, g, parent, openList, closedList, finish, map)
  if inList(x, y, closedList) == false and x > 0 and x <= #map[1] and y > 0 and y <= #map and tileType[map[y][x]] == 0 then
    local result, i = inList(x, y, openList)
    if result == true then
      local item = openList[i]
      if item.g > g then
        item.parent = parent
        item.g = g
        table.remove(openList, i)
        openList = addAndSortF(openList, item)
      end
    else
      openList = addAndSortF(openList, {x = x, y = y, g = g, h = distance(finish.x, finish.y, x, y), parent = parent})
    end
  end
  return openList
end

function addAndSortF(a, item)
  for i, v in ipairs(a) do
    if item.g + item.h < v.g + v.h then
      table.insert(a, i, item)
      return a
    end
  end
  table.insert(a, item)
  return a
end

function inList(x, y, list)
  for i, v in ipairs(list) do
    if v.x == x and v.y == y then
      return true, i
    end
  end
  return false
end

function distance(x1, y1, x2, y2)
  return math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))
end