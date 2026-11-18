// Created by Danil Timulib

#include "ReShade.fxh"

uniform float Strength <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 0.9;
	ui_label = "Motion Blur intensity";
> = 0.52;

texture Tex {Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F;};
texture PrevTex {Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F;};

sampler Sampl {Texture = Tex;};
sampler PrevSampl {Texture = PrevTex;};

float4 PrevTexPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	return tex2Dlod(Sampl, float4(texcoord, 0.0, 0.0));
}

float4 MBPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{	
	float4 curr = tex2Dlod(ReShade::BackBuffer, float4(texcoord, 0.0, 0.0));
	float4 prev = tex2Dlod(PrevSampl, float4(texcoord, 0.0, 0.0));
	float currLum = dot(curr.rgb, float3(0.2126, 0.7152, 0.0722));
	float prevLum = dot(prev.rgb, float3(0.2126, 0.7152, 0.0722));
	float max_color = max(curr.r, max(curr.g, curr.b));
	float luma = abs(currLum * 2.0 - 1.0);
	luma = lerp(0.5, 1.0, luma);
	prevLum = lerp(currLum, prevLum, Strength * luma);
	prevLum -= currLum;
	prevLum += max_color;
	prevLum /= max(max_color, 0.001);
	return float4(curr.rgb * prevLum, curr.a);
}

float4 FinalPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	return tex2Dlod(Sampl, float4(texcoord, 0.0, 0.0));
}

technique MotionBlur
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = PrevTexPS;
		RenderTarget = PrevTex;
	}
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = MBPS;
		RenderTarget = Tex;
	}
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = FinalPS;
	}
}