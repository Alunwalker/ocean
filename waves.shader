shader_type spatial;
uniform sampler2D noise;
uniform int OCTAVE = 6;
uniform float mulscale = 5.0;
uniform float height = 0.6;
uniform float tide = 0.1;
uniform float foamthickness = 0.1;
uniform float timescale = 1.0;
uniform float waterdeep = 0.3;
uniform vec4 WATER_COL : hint_color =  vec4(0.04, 0.38, 0.88, 1.0);
uniform vec4 WATER2_COL : hint_color =  vec4(0.04, 0.35, 0.78, 1.0);
uniform vec4 FOAM_COL : hint_color = vec4(0.8125, 0.9609, 0.9648, 1.0);


float rand(vec2 input){
	return fract(sin(dot(input,vec2(23.53,44.0)))*42350.45);
}

float perlin(vec2 input){
	vec2 i = floor(input);
	vec2 j = fract(input);
	vec2 coord = smoothstep(0.,1.,j);
	
	float a = rand(i);
	float b = rand(i+vec2(1.0,0.0));
	float c = rand(i+vec2(0.0,1.0));
	float d = rand(i+vec2(1.0,1.0));

	return mix(mix(a,b,coord.x),mix(c,d,coord.x),coord.y);
}

float fbm(vec2 input){
	float value = 0.0;
	float scale = 0.5;
	
	for(int i = 0; i < OCTAVE; i++){
		value += perlin(input)*scale;
		input*=2.0;
		scale*=0.5;
	}
	return value;
}
float getheight(vec2 uv, float time)
{
	return texture(noise, uv * mulscale).x;
}
void vertex()
{

	float v = texture(noise, UV * mulscale + TIME * 0.1).x;
//	VERTEX.y += v * height;
	VERTEX.y += v * height;
}

void fragment(){
	float k = texture(noise, UV * mulscale).x;
//	NORMAL = normalize(vec3(k - getheight(UV + vec2(0.2, 0.0), TIME), 0.1, k - getheight(UV + vec2(0.0, 0.2), TIME)));
//	ALBEDO.rgb = 
}