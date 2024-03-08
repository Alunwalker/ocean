shader_type spatial;

render_mode cull_disabled, ensure_correct_normals;
uniform vec4 wave_param_a = vec4(1, 1, 1, 1);
uniform vec4 wave_param_b = vec4(1, 1, 1, 1);
uniform vec4 wave_param_c = vec4(1, 1, 1, 1);
uniform float speed_param = 1.0;

uniform float p_wavelengthMax = 1.0;
uniform float p_wavelengthMin = 1.0;
uniform float p_steepnessMax = 1.0;
uniform float p_steepnessMin = 1.0;
varying float shadow_factor;
uniform sampler2D wavesSampler;
varying vec3 normal;
uniform vec3 albeo_color = vec3(0.1, 0.3, 0.5);
const float PI = 3.14159;

float SineWave(vec4 waveParam,  float speed, float x, float z, out vec3 tangent, out vec3 bitangent)
        {
            float amplitude = waveParam.x;
			float waveLength = waveParam.y;
			float k = 2.0 * PI / waveLength;
			float fx = k * (x - speed);
			float fz = k * (z - speed + 0.5);
//            float waveOffset = amplitude * sin(k * (x - speed));
			float waveOffset = amplitude * sin(fx) + amplitude * sin(fz);
			tangent = normalize(vec3(1, amplitude * k * cos(fx), 0));
            bitangent = normalize(vec3(0, amplitude * k * cos(fz), 1));
            return waveOffset;
        }
		
vec3 GerstnerWave(vec4 waveParam, float time, vec3 positionOS, out vec3 tangent, out vec3 bitangent)
 {
    vec3 position = vec3(0);

    vec2 direction = normalize(waveParam.xy);
            
    float waveLength = waveParam.w;
            
    float k = 2.0 * PI / max(1, waveLength);

    // 这里限制一下z让z永远不超过1
    waveParam.z = abs(waveParam.z) / (abs(waveParam.z) + 1.0);
    float amplitude = waveParam.z / k;

    float speed = sqrt(9.8 / k);
            
    float f = k * (dot(direction, positionOS.xz) - speed * time);
            
    position.y = amplitude * sin(f);
    position.x = amplitude * cos(f) * direction.x;
    position.z = amplitude * cos(f) * direction.y;

    float yy = amplitude * k * cos(f);
//    tangent =  normalize(vec3(1.0 - amplitude * k * sin(f) * direction.x * direction.x, yy, 0));
//    bitangent =  normalize(vec3(0, yy, 1.0 - amplitude * k * sin(f) * direction.y * direction.y));
	tangent += vec3(-amplitude * k * sin(f) * direction.x * direction.x, yy * direction.x, -amplitude * sin(f) * direction.y * k * direction.x);

    bitangent += vec3(-amplitude * k * sin(f) * direction.x * direction.y, yy * direction.y, -amplitude * k * sin(f) * direction.y * direction.y);
	return position;
}
float random(float x)
{
    float y = fract(sin(x)*10000.0);
    return y;
}
vec3 GerstnerWave2(vec2 direction,vec3 positionWS,float waveCount,float wavelengthMax,float wavelengthMin,float steepnessMax,float steepnessMin,float randomdirection, out vec3 tangent, out vec3 bitangent)
{
	vec3 position = vec3(0);
//    Gerstner gerstner;

    vec3 P = vec3(0.0, 0.0, 0.0);
    vec3 B;
    vec3 T;

    for (float i = 0.0; i < waveCount; ++i)
    {
		vec4 wt = textureLod(wavesSampler, vec2((i + 0.5) / waveCount, 0), 0.0);
        float step0 =  i / waveCount;

//        vec2 d = vec2(random(i),random(i));
		float f = random(i);
//		vec2 d = vec2(0.5,0.5);
		 vec2 d = wt.zw;
        d = normalize(mix(normalize(direction.xy), d, randomdirection));

        //step = pow(step, 0.75f);可以使用线性插值或其他插值曲线
        float wavelength = mix(wavelengthMax, wavelengthMin, step0);
        float steepness = mix(steepnessMax, steepnessMin, step0) / waveCount;

        float k = 2.0 * PI / wavelength;
        float g = 9.81f;
        float w = sqrt(g * k);
        float a = steepness / k;
        vec2 wavevector = k * d;
        float val = dot(wavevector, positionWS.xz) - w * TIME * speed_param;

        P.x += d.x * a * cos(val);
        P.z += d.y * a * cos(val);
        P.y += a * sin(val);

        T.x += d.x * d.x * k * a * -sin(val);
        T.y += d.x * k * a * cos(val);
        T.z += d.x * d.y * k * a * -sin(val);

        B.x += d.x * d.y * k * a * -sin(val);
        B.y += d.y * k * a * cos(val);
        B.z += d.y * d.y * k * a * -sin(val);
    }
    
    position.x = positionWS.x + P.x;
    position.y = P.y;
    position.z = positionWS.z + P.z;
    tangent = vec3(1.0 + T.x, T.y, T.z);
    bitangent = vec3(B.x,B.y,1.0 + B.z);

    return position;               
}

void vertex()
{
//	vec4 waveParam = vec4(0.02, 1, 1, 1);
	vec3 tangent = vec3(0);
	vec3 bitangent = vec3(0);
//	VERTEX.y = SineWave(wave_param_a, TIME * speed_param, VERTEX.x, VERTEX.z, tangent, bitangent);
	
//	vec3 N = cross(bitangent, tangent);
//	vec3 V = normalize((INV_CAMERA_MATRIX * WORLD_MATRIX * vec4(VERTEX.xyz, 1.0)).xyz);
//	V = normalize((inverse(WORLD_MATRIX) * CAMERA_MATRIX * vec4(V.xyz, 0.0)).xyz);
//	vec3 L = vec3(0, 1, 0);
//	float dotNV = max(1e-6, dot(N, V));
//	float dotNL = max(1e-6, dot(N, L));
//	shadow_factor = dotNL / (dotNL + dotNV);
	
	vec3 wavePos = GerstnerWave(wave_param_a, TIME * speed_param, VERTEX, tangent, bitangent);
	wavePos += GerstnerWave(wave_param_b, TIME * speed_param, VERTEX, tangent, bitangent);
	wavePos += GerstnerWave(wave_param_c, TIME * speed_param, VERTEX, tangent, bitangent);
	VERTEX.y = wavePos.y;
	VERTEX.x += wavePos.x;
	VERTEX.z += wavePos.z;
	
//	VERTEX = GerstnerWave2(wave_param_a.xy, VERTEX, 60, p_wavelengthMax, p_wavelengthMin, p_steepnessMax, p_steepnessMin, 0.1, tangent, bitangent);
	NORMAL = normalize(cross((tangent),(bitangent)));
//	vec3 pp = VERTEX;
}



void fragment()
{
	
//	METALLIC = 0.5;
	vec3 tangent = vec3(0);
	vec3 bitangent = vec3(0);
	
//	ALBEDO = (CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	ALBEDO = normal;
//	ALPHA = 0.9;
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
//    ROUGHNESS = 0.01 * (1.0 - fresnel);
}