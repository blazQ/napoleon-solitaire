shader_type spatial;
render_mode cull_disabled;

uniform sampler2D front_texture : source_color;
uniform sampler2D back_texture : source_color;

uniform vec2 uv_scale = vec2(3.0, 2.0);
uniform vec2 uv_offset = vec2(1.0, 1.0);

void vertex() {
    UV = UV * uv_scale + uv_offset;
}

void fragment() {
    vec2 uv_coords = UV;
    // Swap texture selection if needed
    vec4 tex_color = FRONT_FACING ? texture(front_texture, uv_coords) : texture(back_texture, uv_coords);

    ALBEDO = tex_color.rgb;
    ALPHA = tex_color.a;
}
