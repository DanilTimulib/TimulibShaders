// Created by Danil Timulib
// Gaussian Blur by existical https://www.shadertoy.com/view/Xltfzj

uniform float Strength <
    string label = "Strength";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 1.0;

float4 mainImage(VertData v_in) : TARGET
{
	float3 color = image.Sample(textureSampler, v_in.uv).rgb;
	
	float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
	
	float Pi = 6.28318530718;
	
	// GAUSSIAN BLUR SETTINGS {{{
	float Directions = 10.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
	float Quality = 2.0; // BLUR QUALITY (Default 3.0 - More is better but slower)
	float Size = 8.0; // BLUR SIZE (Radius)
	// GAUSSIAN BLUR SETTINGS }}}
	
	float2 Radius = Size/uv_size;
	
	float3 blur = color;
	
	for(float d=0.0; d<Pi; d+=Pi/Directions)
	{
		for(float i=1.0/Quality; i<1.001; i+=1.0/Quality)
		{
			blur += image.Sample(textureSampler, v_in.uv+float2(cos(d),sin(d))*Radius*i).rgb;		
		}
	}
	
	blur /= Quality * Directions + 1.0;
	
	float max_color = max(color.r, max(color.g, color.b));
	float3 bloom = 1.0 - (1.0 - max_color) * (1.0 - blur);
	bloom /= max(max_color, 0.001);
	bloom *= color;
	return float4(lerp(color, bloom, Strength * max(luma, 0.5)), 1.0);
}