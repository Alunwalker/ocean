shader_type canvas_item;

uniform vec2 size = vec2(256, 256);
//uniform vec2 grid_size = vec2(64, 64);

uniform bool _IsTilable = false;
uniform vec3 _Evolution;
uniform int _FBMIteration = 1;
uniform float _Frequency = 4;
uniform float _RandomSeed;
uniform float uv_scale = 1.0;
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

vec3 grad(float x, float y) {
   vec3 vec;
   vec[0] = x * 127.1 + y * 311.7;
   vec[1] = x * 269.5 + y * 183.3;

   float sin0 = sin(vec[0]) * 43758.5453123;
   float sin1 = sin(vec[1]) * 43758.5453123;
   vec[0] = (sin0 - floor(sin0)) * 2.0 - 1.0;
   vec[1] = (sin1 - floor(sin1)) * 2.0 - 1.0;

    // 归一化，尽量消除正方形的方向性偏差
   float len = sqrt(vec[0] * vec[0] + vec[1] * vec[1]);
   vec[0] /= len;
   vec[1] /= len;

   return vec;
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
	
//    vec3 vec = GetRandom3To3_Raw(vec3(blockCoord) + _Evolution, length(vec3(blockCoord)) * randomSeed);
	vec3 vec = grad((vec3(blockCoord) + _Evolution).x, (vec3(blockCoord) + _Evolution).y);
    vec = normalize(vec);
    return vec;
}

float GetNoise(vec2 uv, float freq, float randomSeed)
{
	int grid_count = int(ceil(freq));
	vec2 grid_size = size / float(grid_count);
	vec2 position = uv * uv_scale * size;
	vec2 uv_global = position / grid_size;
	vec2 uv_f = fract(uv_global);
	vec2 uv_i = floor(uv_global);
	
	vec2 ld = uv_i * grid_size;
	vec2 lu = (uv_i + vec2(0, 1)) * grid_size;
	vec2 ru = (uv_i + vec2(1, 1)) * grid_size;
	vec2 rd = (uv_i + vec2(1, 0)) * grid_size;
//	uv_f.x = (position.x - ld.x) / grid_size.x;
//	uv_f.y = (position.y - ld.y) / grid_size.y;
	
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
	return noiseValue;
}

void fragment()
{
	float noise = 0.0;
	float currentTile = _Frequency;
    float currentStrength = 1.0;
    for(int iii = 0; iii < _FBMIteration; iii++) {
        currentTile *= 2.0;
        currentStrength /= 2.0;
        if(currentTile >= size.x) {
            currentTile /= 2.0;
        }
        noise += GetNoise(UV, currentTile, _RandomSeed + currentTile) * currentStrength;
    }
	COLOR.xyz = vec3(noise, noise, noise);
	
//	int grid_count = int(ceil(size.x / grid_size.x));
//	vec2 position = UV * uv_scale * size;
//	vec2 uv_global = position / grid_size;
//	vec2 uv_f = fract(uv_global);
//	vec2 uv_i = floor(uv_global);
//
//	vec2 ld = uv_i * grid_size;
//	vec2 lu = (uv_i + vec2(0, 1)) * grid_size;
//	vec2 ru = (uv_i + vec2(1, 1)) * grid_size;
//	vec2 rd = (uv_i + vec2(1, 0)) * grid_size;
////	uv_f.x = (position.x - ld.x) / grid_size.x;
////	uv_f.y = (position.y - ld.y) / grid_size.y;
//
//	vec2 AP = position - ld;
//	vec2 BP = position - lu;
//	vec2 CP = position - ru;
//	vec2 DP = position - rd;
//
//	AP /= grid_size;
//	BP /= grid_size;
//	CP /= grid_size;
//	DP /= grid_size;
//	vec3 a = GetConstantVector(grid_count, ivec3(vec3(uv_i, 0.0)), _RandomSeed);
//	vec3 b = GetConstantVector(grid_count, ivec3(vec3(uv_i + vec2(0, 1), 0.0)), _RandomSeed);
//	vec3 c = GetConstantVector(grid_count, ivec3(vec3(uv_i + vec2(1, 1), 0.0)), _RandomSeed);
//	vec3 d = GetConstantVector(grid_count, ivec3(vec3(uv_i + vec2(1, 0), 0.0)), _RandomSeed);
//	float dotA = dot(AP , a.xy);
//	float dotB = dot(BP , b.xy);
//	float dotC = dot(CP , c.xy);
//	float dotD = dot(DP , d.xy);
//
//	float temp0 = PerlinNoiseLerp(dotA, dotD, uv_f.x);
//	float temp1 = PerlinNoiseLerp(dotB, dotC, uv_f.x);
//	float noiseValue = PerlinNoiseLerp(temp0, temp1, uv_f.y);
//	noiseValue = (noiseValue + 1.0) / 2.0;
//	COLOR.xyz = vec3(noiseValue, noiseValue, noiseValue);
//	ivec3 ii = ivec3(vec3(uv_i, 0.0));
//	COLOR.xyz = vec3(uv_f.x, 0.0, 0.0);
//	if(ii.y == 0)
//	{
//		COLOR.xyz = vec3(1, 0, 0);
//	}
//	else if(ii.y == 1)
//	{
//		COLOR.xyz = vec3(1, 1, 0);
//	}
//	else if(ii.y == 2)
//	{
//		COLOR.xyz = vec3(1, 1, 1);
//	}
//	else if(ii.y == 3)
//	{
//		COLOR.xyz = vec3(1, 0, 1);
//	}
//
//	if(uv_i.x == 0.0)
//	{
//		COLOR.xyz = vec3(1, 0, 0);
//	}
//	else if(uv_i.x == 1.0)
//	{
//		COLOR.xyz = vec3(0, 1, 0);
//	}
//	else if(uv_i.x == 2.0)
//	{
//		COLOR.xyz = vec3(1, 1, 1);
//	}
//	else if(uv_i.x == 3.0)
//	{
//		COLOR.xyz = vec3(1, 0, 1);
//	}


	
}
