function graphics_load()
  w, h = love.graphics.getDimensions()

  tile = love.graphics.newImage("tile.png")
  wall = love.graphics.newImage("wall.png")
  cursor = love.graphics.newImage("cursor.png")
  tileSize = 8

  pathImg = love.graphics.newImage("path.png")
  pathQuad = {
  love.graphics.newQuad(0, 0, 32, 16, pathImg:getDimensions()),
  love.graphics.newQuad(0, 16, 32, 16, pathImg:getDimensions()),
  love.graphics.newQuad(0, 32, 32, 16, pathImg:getDimensions()),
  love.graphics.newQuad(32, 0, 32, 16, pathImg:getDimensions()),
  love.graphics.newQuad(32, 16, 32, 16, pathImg:getDimensions()),
  love.graphics.newQuad(32, 32, 32, 16, pathImg:getDimensions())
  }
end
