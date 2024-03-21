local shaders = {}
shaders.invert = love.graphics.newShader([[
extern Image tex;
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
    return vec4(1.0 - texturecolor.rgb, texturecolor.a) * color;
}
]])

shaders.ca = love.graphics.newShader([[ 
extern float ch_ab_intensity;
extern float distortion_intensity;
extern float frequencies[32];
extern float time;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec2 resolution = love_ScreenSize.xy;
    vec2 uv = texture_coords;
    vec2 offset = vec2(0.0);
    float distortion = 0.0;

    for (int i = 0; i < 32; i++)
    {
        offset.x += frequencies[i] * cos(float(i) + time);
        offset.y += frequencies[i] * sin(float(i) + time);
    }
    
    distortion = frequencies[0] + (frequencies[1] * 0.5);
    offset *= ch_ab_intensity; 
    distortion *= distortion_intensity; 

    // Apply the distortion
    vec2 direction = uv - vec2(0.5);
    float radius = length(direction);
    direction = normalize(direction);
    uv = vec2(0.5) + direction * (radius + distortion * radius); // Multiply the distortion by the radius

    // Split the color channels and apply offsets
    vec4 texturecolor = Texel(tex, uv);
    vec4 red = Texel(tex, uv + offset);
    vec4 green = texturecolor;
    vec4 blue = Texel(tex, uv - offset);

    return vec4(red.r, green.g, blue.b, texturecolor.a) * color;
}
]])

return shaders
