// Create by Danil Timulib
// ACES by Krzysztof Narkowicz https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!TEXTURE
Texture2D INPUT;

//!SAMPLER
//!FILTER POINT
SamplerState sam;

//!PASS 1
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 pos)
{
	float3 color = INPUT.SampleLevel(sam, pos, 0).rgb;
	
	float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
	
	color = pow(max(color, 0.0), 3.08);
	
	float3 orig = color;
	
	float max_color = max(color.r, max(color.g, color.b));
	
	float ACES_A = 2.51;
	float ACES_B = (luma < 0.5) ? lerp(0.12, -0.06, luma) : 0.03;
	float ACES_C = 2.43;
	float ACES_D = 0.59;
	float ACES_E = 0.14;
	
	color = saturate((color*(ACES_A*color+ACES_B))/(color*(ACES_C*color+ACES_D)+ACES_E));
	luma = dot(color, float3(0.2126, 0.7152, 0.0722));
	float3 chroma = color - luma;
	
	float3 newCol = saturate((orig*(ACES_A*orig+ACES_B))/(orig*(ACES_C*orig+ACES_D)+ACES_E));
	newCol -= orig;
	newCol += max_color;
	newCol /= max(max_color, 0.001);
	newCol *= orig;
	luma = dot(newCol, float3(0.2126, 0.7152, 0.0722));
	
	color = pow(max(luma + chroma, 0.0), rcp(2.2));
	
	return max(color, 0.0);
}