function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

function coordToIso(x, y)
  x = x /tileSize
  y = y /tileSize
  return (x-y+#rooms[currentRoom]-1)*tileSize, (y+x)*tileSize/2
end

function tileToCoord(x, y)
  return (x-1)*tileSize, (y-1)*tileSize
end

function coordToTile(x, y)
  return math.floor(x/tileSize)+1, math.floor(y/tileSize)+1
end

function tileToIso(x, y)
  return (x-y+#rooms[currentRoom]-1)*tileSize, (y+x-2)*tileSize/2
end

function simplifyPath(path)
  local simplePath = {path[1]}
  local oldDir = pathDirection(path[1], path[2])
  for i = 2, #path-1 do
    newDir = pathDirection(path[i], path[i+1]) -- find new direction
    if newDir.x ~= oldDir.x or newDir.y ~= oldDir.y then -- check if path is going in same direction
      simplePath[#simplePath + 1] = path[i]
      oldDir = newDir
    end
  end
  simplePath[#simplePath + 1] = path[#path]
  return simplePath
end

function pathDirection(a, b)
  if a.x > b.x then
    return {x = -1, y = 0}
  elseif a.x < b.x then
    return {x = 1, y = 0}
  elseif a.y > b.y then
    return {x = 0, y = -1}
  else
    return {x = 0, y = 1}
  end
end

function setPathColor()
  if currentActor.path.valid then
    love.graphics.setColor(palette.green)
  else
    love.graphics.setColor(palette.red)
  end
end

function pathIsValid(path, room, turnPts)
  if #path-1 > turnPts then -- get rid of path if destination is too far away
    return false
  else
    for i, v in ipairs(levels[currentLevel].actors) do -- check if actors path is colliding with player actor
      if room == v.room then
        if v.move == true then
          if path[#path].x == v.path.tiles[#v.path.tiles].x and path[#path].y == v.path.tiles[#v.path.tiles].y then
            return false
          end
        elseif  #path > 0 then
          local x, y = tileToCoord(path[#path].x, path[#path].y)
          if x == v.x and y == v.y then
            return false
          end
        end
      end
    end
    for i, v in ipairs(levels[currentLevel].enemyActors) do -- check if actors path is colliding with player actor
      if room == v.room then
        if v.move == true then
          if path[#path].x == v.path.tiles[#v.path.tiles].x and path[#path].y == v.path.tiles[#v.path.tiles].y then
            return false
          end
        elseif  #path > 0 then
          local x, y = tileToCoord(path[#path].x, path[#path].y)
          if x == v.x and y == v.y then
            return false
          end
        end
      end
    end
  end
  return true
end

function getDirection(a, b)
  local angle = math.deg(math.atan2(b.y-a.y, b.x-a.x))
  if angle > 45 and angle <= 135 then
    return {x = 0, y = 1}
  elseif (angle > 135 and angle <= 180) or (angle >= -180 and angle <= -135) then
    return {x = -1, y = 0}
  elseif angle > -135 and angle <= -45 then
    return {x = 0, y = -1}
  else
    return {x = 1, y = 0}
  end
end

function getDistance(a, b)
  return math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y))
end


function checkIntersect(l1p1, l1p2, l2p1, l2p2) -- Checks if two line segments intersect. Line segments are given in form of ({x=x, y=y},{x=x,y=y}, {x=x,y=y},{x=x,y=y}).
	local function checkDir(pt1, pt2, pt3) return math.sign(((pt2.x-pt1.x)*(pt3.y-pt1.y)) - ((pt3.x-pt1.x)*(pt2.y-pt1.y))) end
	return (checkDir(l1p1,l1p2,l2p1) ~= checkDir(l1p1,l1p2,l2p2)) and (checkDir(l2p1,l2p2,l1p1) ~= checkDir(l2p1,l2p2,l1p2))
end
function math.sign(n) return n>0 and 1 or n<0 and -1 or 0 end

function LoS(a, b, map)
  local xMin, xMax, yMin, yMax = 0, 0, 0, 0
  if a.x > b.x then
    xMin, xMax = b.x, a.x
  else
    xMin, xMax = a.x, b.x
  end
  if a.y > b.y then
    yMin, yMax = b.y, a.y
  else
    yMin, yMax = a.y, b.y
  end

  for down = yMin, yMax do
    for across = xMin, xMax do
      if tileType[map[down][across]] == 2 then
        if checkIntersect(a, b, {x = across-.5, y = down-.5}, {x = across+.5, y = down-.5}) or
           checkIntersect(a, b, {x = across+.5, y = down-.5}, {x = across+.5, y = down+.5}) or
           checkIntersect(a, b, {x = across+.5, y = down+.5}, {x = across-.5, y = down+.5}) or
           checkIntersect(a, b, {x = across-.5, y = down+.5}, {x = across-.5, y = down-.5}) then
          return false
        end
      end
    end
  end
  return true
end
