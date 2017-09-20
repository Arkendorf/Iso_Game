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

function mapToIso(x, y)
  return (x-y+#rooms[currentRoom]-1)*mapTileSize, (y+x-2)*mapTileSize/2
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

function giveTurnPts(table)
  for i, v in ipairs(table) do
    v.turnPts = v.actor.item.turnPts
    v.displayTurnPts = v.turnPts
  end
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

function setValidColor(bool)
  if bool then
    love.graphics.setColor(palette.green)
  else
    love.graphics.setColor(palette.red)
  end
end

function pathIsValid(path, actor)
  if #path-1 > actor.turnPts or #path < 2 then -- get rid of path if destination is too far away
    return false
  else
    for i, v in ipairs(currentLevel.actors) do -- check if actors path is colliding with player actor
      if v.x ~= actor.x or v.y ~= actor.y then
        if actor.room == v.room and v.dead == false then
          if v.move == true then
            if path[#path].x == v.path.tiles[#v.path.tiles].x and path[#path].y == v.path.tiles[#v.path.tiles].y then
              return false
            end
          else
            local x, y = tileToCoord(path[#path].x, path[#path].y)
            if x == v.x and y == v.y then
              return false
            end
          end
        end
      end
    end
    for i, v in ipairs(currentLevel.enemyActors) do -- check if actors path is colliding with player actor
      if v.x ~= actor.x or v.y ~= actor.y then
        if actor.room == v.room and v.dead == false then
          if v.move == true then
            if path[#path].x == v.path.tiles[#v.path.tiles].x and path[#path].y == v.path.tiles[#v.path.tiles].y then
              return false
            end
          else
            local x, y = tileToCoord(path[#path].x, path[#path].y)
            if x == v.x and y == v.y then
              return false
            end
          end
        end
      end
    end
  end
  return true
end

function getDirection(a, b)
  local angle = math.deg(math.atan2(a.y-b.y, a.x-b.x))
  if angle > 45 and angle < 135 then
    return {x = 0, y = -1}
  elseif (angle > 135 and angle <= 180) or (angle >= -180 and angle < -135) then
    return {x = 1, y = 0}
  elseif angle > -135 and angle < -45 then
    return {x = 0, y = 1}
  elseif angle > -45 and angle < 45 then
    return {x = -1, y = 0}
  elseif angle == 45 then
    return {x = -1, y = -1}
  elseif  angle == 135 then
    return {x = 1, y = -1}
  elseif angle == -135 then
    return {x = 1, y = 1}
  elseif angle == -45 then
    return {x =-1, y = 1}
  end
end

function getDistance(a, b)
  return math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y))
end

function getAngle(a, b)
  return math.atan2(b.y-a.y, b.x-a.x)
end


function checkIntersect(l1p1, l1p2, l2p1, l2p2) -- Checks if two line segments intersect. Line segments are given in form of ({x=x, y=y},{x=x,y=y}, {x=x,y=y},{x=x,y=y}).
	local function checkDir(pt1, pt2, pt3) return math.sign(((pt2.x-pt1.x)*(pt3.y-pt1.y)) - ((pt3.x-pt1.x)*(pt2.y-pt1.y))) end
	return (checkDir(l1p1,l1p2,l2p1) ~= checkDir(l1p1,l1p2,l2p2)) and (checkDir(l2p1,l2p2,l1p1) ~= checkDir(l2p1,l2p2,l1p2))
end
function math.sign(n) return n>0 and 1 or n<0 and -1 or 0 end

function LoS(a, b, map) -- a and b are coords
  tX1, tY1 = coordToTile(a.x, a.y)
  tX2, tY2 = coordToTile(b.x, b.y)
  local xMin, xMax, yMin, yMax = 0, 0, 0, 0
  if tX1 > tX2 then
    xMin, xMax = tX2, tX1
  else
    xMin, xMax = tX1, tX2
  end
  if tY1 > tY2 then
    yMin, yMax = tY2, tY1
  else
    yMin, yMax = tY1, tY2
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

function isUnderCover(a, b, map) -- a is object under attack
  local tX1, tY1 = coordToTile(a.x, a.y)
  local tX2, tY2 = coordToTile(b.x, b.y)
  local xMin, xMax, yMin, yMax = 0, 0, 0, 0
  if tX1 <= 0 then xMin = 0 else xMin = -1 end
  if tX1 >= #map[1] then xMax = 0 else xMax = 1 end
  if tY1 <= 0 then yMin = 0 else yMin = -1 end
  if tY1 >= #map then yMax = 0 else yMax = 1 end

  for down = yMin, yMax do
    for across = xMin, xMax do
      local x, y = tX1+across, tY1+down
      if tileType[map[y][x]] == 3 then
        if checkIntersect({x = tX1, y = tY1}, {x = tX2, y = tY2}, {x = x-.5, y = y-.5}, {x = x+.5, y = y-.5}) or
           checkIntersect({x = tX1, y = tY1}, {x = tX2, y = tY2}, {x = x+.5, y = y+.5}, {x = x+.5, y = y+.5}) or
           checkIntersect({x = tX1, y = tY1}, {x = tX2, y = tY2}, {x = x+.5, y = y+.5}, {x = x-.5, y = y+.5}) or
           checkIntersect({x = tX1, y = tY1}, {x = tX2, y = tY2}, {x = x-.5, y = y+.5}, {x = x-.5, y = y-.5}) then
          return true
        end
      end
    end
  end
  return false
end

function removeNil(t)
  local ans = {}
  for _,v in pairs(t) do
    ans[ #ans+1 ] = v
  end
  return ans
end

function startNewCanvas(width, height)
  local newCanvas = love.graphics.newCanvas(width, height)
  local oldCanvas = love.graphics.getCanvas()
  love.graphics.setCanvas(newCanvas)
  love.graphics.clear()
  return newCanvas, oldCanvas
end

function resumeCanvas(canvas)
  local oldCanvas = love.graphics.getCanvas()
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  return canvas, oldCanvas
end

function neighbors(a, b)
  if (math.abs(b.x-a.x) <= 1 and math.abs(b.y-a.y) <= 1) then
    return true
  else
    return false
  end
end
