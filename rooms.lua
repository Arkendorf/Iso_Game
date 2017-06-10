function rooms_load()
  rooms = {}
  rooms[1] = {{1, 0, 0, 1, 0, 1},
              {1, 0, 0, 1, 0, 1},
              {1, 0, 0, 1, 0, 1},
              {1, 0, 0, 1, 0, 1},
              {1, 0, 0, 1, 0, 0},
              {1, 0, 0, 1, 0, 1}}
  tileType = {[0] = 0, 1}
end

function rooms_draw()
  for i = 1, #rooms[currentRoom] + #rooms[currentRoom][1] - 1 do
    if i <= #rooms[currentRoom] then
      for j = 1, i do
        if tileType[rooms[currentRoom][i-j+1][j]] == 1 then
          love.graphics.setColor(255, 255, 255)
        else
          love.graphics.setColor(155, 155, 155)
        end
        love.graphics.draw(tile, j * 32 + #rooms[currentRoom]*32 / 2 - i * 16, i * 8)
      end
    elseif i < #rooms[currentRoom][1] then
      for j = 1, #rooms[currentRoom] do
        if tileType[rooms[currentRoom][#rooms[currentRoom]+1-j][i-#rooms[currentRoom]+j]] == 1 then
          love.graphics.setColor(255, 255, 255)
        else
          love.graphics.setColor(155, 155, 155)
        end
        love.graphics.draw(tile, j * 32 + #rooms[currentRoom][1]*32 / 2 - (#rooms[currentRoom] + #rooms[currentRoom][1] - i) * 16, i * 8)
      end
    else
      for j = 1, #rooms[currentRoom] + #rooms[currentRoom][1] - i do
        if tileType[rooms[currentRoom][#rooms[currentRoom]+1-j][i-#rooms[currentRoom]+j]] == 1 then
          love.graphics.setColor(255, 255, 255)
        else
          love.graphics.setColor(155, 155, 155)
        end
        love.graphics.draw(tile, j * 32 + #rooms[currentRoom][1]*32 / 2 - (#rooms[currentRoom] + #rooms[currentRoom][1] - i) * 16, i * 8)
      end
    end
  end
end
