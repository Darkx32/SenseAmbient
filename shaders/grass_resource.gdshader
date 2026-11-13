shader_type canvas_item;

uniform float speed = 2.5;
uniform float frequency = 12.0;
uniform float amplitude = 0.002;
uniform float min_diff : hint_range(0.01, 0.2) = 0.03;

bool is_inside_grass_tiles(vec2 uv) {
    return (uv.x >= 0.0625 && uv.x <= 0.1875 && uv.y >= 0.0 && uv.y <= 0.0667);
}

void fragment() {
    vec2 uv = UV;
    vec4 tex = texture(TEXTURE, uv);
    
    if (is_inside_grass_tiles(uv)) {
        vec3 base_green = vec3(0.47, 0.72, 0.36);
        bool is_green = (tex.g > tex.r * 1.15 && tex.g > tex.b * 1.15);
        float diff = distance(tex.rgb, base_green);
        
        if (is_green && diff > min_diff) {
            float wave = sin(TIME * speed + (UV.x + UV.y) * frequency) * amplitude;
            vec2 shifted_uv = uv;
            shifted_uv.x += wave;
            
            if (is_inside_grass_tiles(shifted_uv)) {
                vec4 shifted_tex = texture(TEXTURE, shifted_uv);
                if (distance(shifted_tex.rgb, base_green) > min_diff) {
                    tex = shifted_tex;
                }
            }
        }
    }
    
    COLOR = tex;
}