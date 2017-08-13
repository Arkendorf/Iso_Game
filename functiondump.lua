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

function pathIsValid(actor)
  if #actor.path.tiles-1 > actor.turnPts then -- get rid of path if destination is too far away
    return false
  else
    for i, v in ipairs(levels[currentLevel].actors) do -- check if actors path is colliding with player actor
      if actor.room == v.room then
        if v.move == true then
          if actor.path.tiles[#actor.path.tiles].x == v.path.tiles[#v.path.tiles].x and actor.path.tiles[#actor.path.tiles].y == v.path.tiles[#v.path.tiles].y then
            return false
          end
        elseif  #actor.path.tiles > 0 then
          local x, y = tileToCoord(actor.path.tiles[#actor.path.tiles].x, actor.path.tiles[#actor.path.tiles].y)
          if x == v.x and y == v.y then
            return false
          end
        end
      end
    end
    for i, v in ipairs(levels[currentLevel].enemyActors) do -- check if actors path is colliding with enemy actor
      if actor.room == v.room then
        if v.move == true then
          if actor.path.tiles[#actor.path.tiles].x == v.path.tiles[#v.path.tiles].x and actor.path.tiles[#actor.path.tiles].y == v.path.tiles[#v.path.tiles].y then
            return false
          end
        elseif  #actor.path.tiles > 0 then
          local x, y = tileToCoord(actor.path.tiles[#actor.path.tiles].x, actor.path.tiles[#actor.path.tiles].y)
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
