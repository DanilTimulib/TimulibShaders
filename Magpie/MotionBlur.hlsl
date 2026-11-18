// Created by Danil Timulib

//!MAGPIE EFFECT
//!VERSION 4

//!PARAMETER
//!LABEL Motion Blur intensity
//!DEFAULT 0.52
//!MIN 0
//!MAX 0.9
//!STEP 0.01
float Strength;

//!TEXTURE
Texture2D INPUT;

//!TEXTURE
//!WIDTH INPUT_WIDTH
//!HEIGHT INPUT_HEIGHT
Texture2D OUTPUT;

//!TEXTURE
//!WIDTH INPUT_WIDTH
//!HEIGHT INPUT_HEIGHT
//!FORMAT R16G16B16A16_FLOAT
Texture2D Tex;

//!TEXTURE
//!WIDTH INPUT_WIDTH
//!HEIGHT INPUT_HEIGHT
//!FORMAT R16G16B16A16_FLOAT
Texture2D PrevTex;

//!SAMPLER
//!FILTER POINT
SamplerState sam;

//!PASS 1
//!DESC PrevTexPS
//!STYLE PS
//!IN Tex
//!OUT PrevTex
float4 Pass1(float2 pos)
{
	return Tex.SampleLevel(sam, pos, 0);
}

//!PASS 2
//!DESC MBPS
//!STYLE PS
//!IN INPUT, PrevTex
//!OUT Tex
float4 Pass2(float2 pos)
{	
	float4 curr = INPUT.SampleLevel(sam, pos, 0);
	float4 prev = PrevTex.SampleLevel(sam, pos, 0);
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

//!PASS 3
//!DESC FinalPS
//!STYLE PS
//!IN Tex
//!OUT OUTPUT
float4 Pass3(float2 pos)
{
	return Tex.SampleLevel(sam, pos, 0);
}