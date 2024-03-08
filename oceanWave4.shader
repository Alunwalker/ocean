shader_type spatial;

render_mode cull_disabled;
uniform sampler2D noise;
uniform sampler2D waves;
uniform float param_speed = 1.0;
uniform float wave_a = 0.2;
uniform float wave_b = 0.3;
uniform float wave_c = 0.5;
uniform float wave_d = 0.4;
uniform float uv_scale = 100;
uniform float deep_scale_param = 1.0;
uniform float deep_curve_param = 1.0;
uniform vec4 deep_color:hint_color = vec4(0.1, 0.3, 0.5, 1.0);
uniform vec4 shallow_color:hint_color = vec4(0.1, 0.3, 0.5, 1.0);




vec3 bilinearInterpolation(float x, float y, sampler2D tex)
{
	float x1 = floor(x);
	float x2 = x1 + 1.0;
	float y1 = floor(y);
	float y2 = y1 + 1.0;
	float xs = x - x1;
	float ys = y - y1;
	vec3 pixel1 = texture(tex, vec2(x1, y1)).xyz;
	vec3 pixel2 = texture(tex, vec2(x2, y1)).xyz;
	vec3 pixel3 = texture(tex, vec2(x2, y2)).xyz;
	vec3 pixel4 = texture(tex, vec2(x1, y2)).xyz;
	
	vec3 v1 = pixel1 + (pixel2 - pixel1) * xs;
	vec3 v2 = pixel3 + (pixel4 - pixel3) * xs;
	
	vec3 v = v1 + (v2 - v1) * ys;
	
	return v;
	
}
float wave(vec2 position){
//  position += texture(noise, position / uv_scale).x * 2.0 - 1.0;
//  position += bilinearInterpolation((position * 10000.0).x, (position * 10000.0).y, noise).x * 2.0 - 1.0;
//  vec2 wv = 1.0 - abs(sin(position));
//  return pow(1.0 - pow(wv.x * wv.y, 0.65), 4.0);

	return texture(noise, position / uv_scale).x * 4.0;
}

float height(vec2 position, float time) {
//	float d = wave((position + time * param_speed) * wave_a) * (1.0 / 60.0);
//	for (float i = 0.0; i < 60.0; ++i)
//    {
//		vec4 wt = textureLod(waves, vec2((i + 0.5) / 60.0, 0), 0.0);
//		d += wave((position + wt.xy + time * param_speed) * wave_b) *  (1.0 / 60.0);
//	}
  	float d = wave((position + (time * param_speed)) * wave_a) * 1.0;
//  	d += wave((position - time * param_speed) * wave_b) * 0.3;
//  	d += wave((position + time * param_speed) * wave_c) * 0.2;
//  	d += wave((position - time * param_speed) * wave_d) * 0.2;
  	return d;
}

varying vec2 o_pos;
varying float o_k;
void vertex() {
  vec2 pos = VERTEX.xz;
  float k = height(pos, TIME);
  VERTEX.y = k * sin(k * TIME );
o_pos = pos;
o_k = k;
  NORMAL = normalize(vec3(k - height(pos + vec2(0.2, 0.0), TIME), 0.1, k - height(pos + vec2(0.0, 0.2), TIME)));

}

void fragment() {
  float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
  RIM = 0.1;
  METALLIC = 0.0;
  ROUGHNESS = 0.01 * (1.0 - fresnel);
  ALBEDO = vec3(0.1, 0.3, 0.5) + (0.1 * fresnel);
//ALBEDO = vec3(0.1, 0.3, 0.5);
  
//	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
//
//	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
//	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
//	vec4 world = CAMERA_MATRIX * vec4(view);
//	vec3 world_pos =  world.xyz / world.w;
//	float d = sqrt(world_pos.x * world_pos.x + world_pos.z * world_pos.z);
////	float waterDepth = radius - sqrt((radius - d) * (radius + d));
//	float waterDepth = -world_pos.y;
//	waterDepth = waterDepth / max(deep_scale_param, 1); 
//
//	vec4 world = CAMERA_MATRIX * vec4(view);
//	vec3 world_pos =  world.xyz / world.w + CAMERA_RELATIVE_POS.xyz;
//	float waterDepth = radius - length(world_pos) / max(deep_scale_param, 1); 
//
//    float deepFactor = exp2(-deep_curve_param * waterDepth);
//	ALPHA = clamp(mix(deep_color.a, shallow_color.a, deepFactor), 0, 1);
	vec4 pos = CAMERA_MATRIX * vec4(VERTEX, 1.0);
	pos = inverse(WORLD_MATRIX) * pos;
	float k = height(pos.xz, TIME);
	vec4 normal = (vec4(k - height(pos.xz + vec2(0.1, 0.0), TIME), 0.1, k - height(pos.xz + vec2(0.0, 0.1), TIME), 0.0));
//	vec4 normal = (vec4(o_k - height(o_pos + vec2(0.1, 0.0), TIME), 0.1, o_k - height(o_pos + vec2(0.0, 0.1), TIME), 0.0));
	normal = INV_CAMERA_MATRIX * WORLD_MATRIX * normal;
//	NORMAL = normalize(normal.xyz);
}
