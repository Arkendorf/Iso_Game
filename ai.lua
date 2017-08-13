function ai_load()
  enemyMoveAIs = {}

  enemyMoveAIs[1] = function (enemyNum, enemy)
    local tX, tY = coordToTile(enemy.x, enemy.y)
    local room = rooms[enemy.room]

    local xMin = tX - enemy.turnPts
    if xMin < 1 then xMin = 1 end
    local xMax = tX + enemy.turnPts
    if xMax > #room[1] then xMax = #room[1] end
    local yMin = tY - enemy.turnPts
    if yMin < 1 then yMin = 1 end
    local yMax = tY + enemy.turnPts
    if yMax > #room then yMax = #room end

    local potentialTiles = {}
    for down = yMin, yMax do -- search room within range for potential tile
      for across = xMin, xMax do

        if tileType[room[down][across]] == 3 then
          local playerAngles = {}
          for i, v in ipairs(levels[currentLevel].actors) do -- get angle from player to potential tile
            if v.room ==enemy.room then
              local pTX, pTY = coordToTile(v.x, v.y)
              if LoS({x = tX, y = tY}, {x = pTX, y = pTY}, room) == true then
                playerAngles[#playerAngles + 1] = getDirection({x = pTX, y = pTY}, {x = across, y = down})
              end
            end
          end

          local playersPerSide = {0, 0, 0, 0}
          for i, v in ipairs(playerAngles) do -- figure out how many players can see each side of potential tile
            if v.x == 1 and v.y == 0 then
              playersPerSide[1] = playersPerSide[1] + 1
            elseif v.x == 0 and v.y == 1 then
              playersPerSide[2] = playersPerSide[2] + 1
            elseif v.x == -1 and v.y == 0 then
              playersPerSide[3] = playersPerSide[3] + 1
            elseif v.x == 0 and v.y == -1 then
              playersPerSide[4] = playersPerSide[4] + 1
            end
          end

          -- choose tile opposite most visible side
          if across-1 > 0 and tileType[room[down][across-1]] == 1 then
            potentialTiles[#potentialTiles + 1] = {tX = across-1, tY = down, visibility = playersPerSide[3]}
          end
          if down-1 > 0 and tileType[room[down-1][across]] == 1 then
            potentialTiles[#potentialTiles + 1] = {tX = across, tY = down-1, visibility = playersPerSide[4]}
          end
          if across+1 < #room[1] and tileType[room[down][across+1]] == 1 then
            potentialTiles[#potentialTiles + 1] = {tX = across+1, tY = down, visibility = playersPerSide[1]}
          end
          if down+1 < #room and tileType[room[down+1][across]] == 1 then
            potentialTiles[#potentialTiles + 1] = {tX = across, tY = down+1, visibility = playersPerSide[2]}
          end
        end
      end
    end

    local currentPath = {tiles = {}}
    currentPath.score = #currentPath.tiles + #levels[currentLevel].actors*2
    for i, v in ipairs(potentialTiles) do -- pick closest potential tile that is valid
      local newPath = {tiles = newPath({x = tX, y = tY}, {x = v.tX, y = v.tY}, room)}
      newPath.score = #newPath.tiles + v.visibility*2
      if #newPath.tiles > 0 and pathIsValid(newPath.tiles, room, enemy.turnPts) and (newPath.score < currentPath.score or #currentPath.tiles == 0) then
        currentPath = newPath
      end
    end
    return currentPath.tiles
  end
end
