shader_type canvas_item;

uniform vec2 size = vec2(256, 256);
uniform vec2 grid_size = vec2(64, 64);

uniform bool _IsTilable = false;
uniform vec3 _Evolution;
uniform float _RandomSeed;
uniform float v1;
uniform float v2;
uniform float v3;


float lerp(float a, float b, float w)
{
  return a + w*(b-a);
}
float PerlinNoiseLerp(float l, float r, float t) {
    t = ((6.0 * t - 15.0) * t + 10.0) * t * t * t;
    return lerp(l, r, t);
}
vec3 GetRandom3To3_Raw(vec3 param, float randomSeed) {
    vec3 value;
    value.x = length(param) + 58.12 + 79.52 * randomSeed;
    value.y = length(param) + 96.53 + 36.95 * randomSeed;
    value.z = length(param) + 71.65 + 24.58 * randomSeed;
    value.x = fract(sin(value.x));
    value.y = fract(sin(value.y));
    value.z = fract(sin(value.z));
    return value;
}

vec3 GetConstantVector(int blockNumber, ivec3 blockCoord, float randomSeed) {
    if (_IsTilable) {
        if (blockCoord.x == blockNumber) {
            blockCoord.x = 0;
        }

        if (blockCoord.y == blockNumber) {
            blockCoord.y = 0;
        }

        if (blockCoord.z == blockNumber) {
            blockCoord.z = 0;
        }
    }
	
    vec3 vec = GetRandom3To3_Raw(vec3(blockCoord) + _Evolution, length(vec3(blockCoord)) * randomSeed);
    vec = normalize(vec);
    return vec;
}

void fragment()
{
	int grid_count = int(ceil(size.x / grid_size.x));
	vec2 position = UV * size;
	vec2 uv_global = position / grid_size;
	vec2 uv_f = fract(uv_global);
	vec2 uv_i = floor(uv_global);
	
	vec2 ld = uv_i * grid_size;
	vec2 lu = (uv_i + vec2(0, 1)) * grid_size;
	vec2 ru = (uv_i + vec2(1, 1)) * grid_size;
	vec2 rd = (uv_i + vec2(1, 0)) * grid_size;
	
	vec2 AP = position - ld;
	vec2 BP = position - lu;
	vec2 CP = position - ru;
	vec2 DP = position - rd;
	
	AP /= grid_size;
	BP /= grid_size;
	CP /= grid_size;
	DP /= grid_size;
	vec3 a = GetConstantVector(grid_count, ivec3(vec3(uv_i, 0.0)), _RandomSeed);
	vec3 b = GetConstantVector(grid_count, ivec3(vec3(uv_i + vec2(0, 1), 0.0)), _RandomSeed);
	vec3 c = GetConstantVector(grid_count, ivec3(vec3(uv_i + vec2(1, 1), 0.0)), _RandomSeed);
	vec3 d = GetConstantVector(grid_count, ivec3(vec3(uv_i + vec2(1, 0), 0.0)), _RandomSeed);
	float dotA = dot(AP , a.xy);
	float dotB = dot(BP , b.xy);
	float dotC = dot(CP , c.xy);
	float dotD = dot(DP , d.xy);
	
	float temp0 = PerlinNoiseLerp(dotA, dotD, uv_f.x);
	float temp1 = PerlinNoiseLerp(dotB, dotC, uv_f.x);
	float noiseValue = PerlinNoiseLerp(temp0, temp1, uv_f.y);
	noiseValue = (noiseValue + 1.0) / 2.0;
	COLOR.xyz = vec3(noiseValue, noiseValue, noiseValue);
}
