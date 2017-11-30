function shaders_load()
  shaders = {}
  shaders.pixelFade = love.graphics.newShader[[
      extern number a;
      vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
        vec4 pixel = Texel(texture, texture_coords);//This is the current pixel color
        number random =  fract(sin(dot(screen_coords.xy ,vec2(12.9898,78.233))) * 43758.5453);
        if (random >= a) {
          return vec4(0.0, 0.0, 0.0, 0.0);
        }
        else {
          return pixel * color;
        }

      }
    ]]

  shaders.pixelFadeOpp = love.graphics.newShader[[
      extern number a;
      vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
        vec4 pixel = Texel(texture, texture_coords);//This is the current pixel color
        number random =  fract(sin(dot(screen_coords.xy ,vec2(12.9898,78.233))) * 43758.5453);
        if (random < a) {
          return vec4(0.0, 0.0, 0.0, 0.0);
        }
        else {
          return pixel * color;
        }

      }
    ]]

  shaders.swap = love.graphics.newShader[[
      extern number pos;
      vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
        vec4 pixel = Texel(texture, texture_coords);//This is the current pixel color
        if (screen_coords.x < pos) {
          return vec4(0.0, 0.0, 0.0, 0.0);
        }
        else {
          return pixel * color;
        }

      }
    ]]
end
