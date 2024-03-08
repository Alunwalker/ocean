shader_type spatial;

render_mode cull_disabled, vertex_lighting;

		uniform	vec4 _Color : hint_color;
		uniform	float _WaveLength;
		uniform	float _WaveAmplitude;
		uniform	float _WindDirection;
		uniform	float _WindSpeed;

void GerstnerWave(vec2 pos, float waveCount, float waveLen, float amplitude, float direction, float windSpeed, out vec3 vertex, out vec3 normal) 
{
				//方向（D）：垂直于波峰传播的波阵面的水平矢量。
				//波长（L）：世界空间中波之间的波峰到波峰的距离。
				//振幅（A）：从水平面到波峰的高度。
				//速度（S）：波峰每秒向前移动的距离。
				//陡度 (Q) : 控制水波的陡度。

				float time = TIME;
				direction = radians(direction);
				vec2 D = normalize(vec2(sin(direction), cos(direction)));
				float w = 6.28318 / waveLen;
				float L = waveLen;
				float A = amplitude;
				float S = windSpeed * sqrt(9.8 * w);
				float Q = 1.0 / (A * w * waveCount);

				float commonCalc = w * dot(D, pos) + time * S;
		
				float cosC = cos(commonCalc);
				float sinC = sin(commonCalc);
				vertex.xz = Q * A * D.xy * cosC;
				vertex.y = (A * sinC) / waveCount;
				float WA = w * A;
				normal = vec3(-(D.xy * WA * cosC), 1.0 - (Q * WA * sinC));
				normal = normal/waveCount;
}
void  GenWave(vec3 vertex, out vec3 o_vertex, out vec3 o_normal) {
				vec2 pos = vertex.xz;
				float count = 60.0;
//				for (float i = 0.0; i < count; i++) {
					vec3 t_vertex = vec3(0);
					vec3 t_normal = vec3(0);
					
//					GerstnerWave(pos, count, _WaveLength, _WaveAmplitude, _WindDirection, _WindSpeed, t_vertex, t_normal);
					GerstnerWave(pos, count, _WaveLength, _WaveAmplitude, _WindDirection, _WindSpeed,  t_vertex,  t_normal);
					o_vertex += t_vertex;
					o_normal += t_normal;
//				}
			}

void vertex()
{
	vec3 o_vertex = vec3(0);
	vec3 o_normal = vec3(0);
	GenWave(VERTEX, o_vertex, o_normal);
	VERTEX += o_vertex;
	NORMAL = (CAMERA_MATRIX * vec4(o_normal, 1.0)).xyz;
	NORMAL = o_normal;
}