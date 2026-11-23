// Base Code by NVIDIA Corp.
// Gaussian Blur by existical https://www.shadertoy.com/view/Xltfzj
// Edit by Danil Timulib

#include "ReShade.fxh"

uniform float Strength <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 1.0;
> = 1.0;

float3 PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{	
	float3 color = tex2Dlod(ReShade::BackBuffer, float4(texcoord, 0.0, 0.0)).rgb;
	float3 orig = color;
	
	float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
	float lum = abs(luma * 2.0 - 1.0);
	lum = lerp(0.5, 1.0, lum);
	
	float Pi = 6.28318530718;
	
	// GAUSSIAN BLUR SETTINGS {{{
	float Directions = 10.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
	float Quality = 2.0; // BLUR QUALITY (Default 3.0 - More is better but slower)
	float Size = 8.0; // BLUR SIZE (Radius)
	// GAUSSIAN BLUR SETTINGS }}}
	
	float2 Radius = Size/BUFFER_SCREEN_SIZE;
	
	float3 blur = color;
	
	for(float d=0.0; d<Pi; d+=Pi/Directions)
	{
		for(float i=1.0/Quality; i<1.001; i+=1.0/Quality)
		{
			blur += tex2Dlod(ReShade::BackBuffer, float4(texcoord+float2(cos(d),sin(d))*Radius*i, 0.0, 0.0)).rgb;		
		}
	}
	
	blur /= Quality * Directions + 1.0;
	float blurLum = dot(blur, float3(0.2126, 0.7152, 0.0722));
	float max_color = max(color.r, max(color.g, color.b));
	
	float Clarity = (0.5 + luma - blurLum);
	Clarity = lerp(2*Clarity + luma*(1-2*Clarity), 2*(1-Clarity)+(2*Clarity-1)*rsqrt(luma), luma > blurLum);
	color *= Clarity;
	color -= orig;
	color += max_color;
	color /= max(max_color, 0.001);
	color = lerp(orig, orig * color, Strength * 4.2 * lum);
	return max(color, 0.0);
}

technique Clarity
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = PS;
	}
}