// Created by Danil Timulib

//!MAGPIE EFFECT
//!VERSION 3

//!PARAMETER
//!LABEL Sharpness intensity
//!DEFAULT 1
//!MIN 0
//!MAX 1
//!STEP 0.01
float amount;

//!TEXTURE
Texture2D INPUT;

//!SAMPLER
//!FILTER LINEAR
SamplerState sam;

//!PASS 1
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 pos)
{
	float3 color = INPUT.SampleLevel(sam, pos, 0).rgb;
	
	float max_color = max(color.r, max(color.g, color.b));
	
	float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
	
	luma = abs(luma * 2 - 1);
	
	float2 outputPt = GetOutputPt();
	
	float3 s = 0;
	
	s += INPUT.SampleLevel(sam, pos + float2( outputPt.x,  0), 0).rgb;
	s += INPUT.SampleLevel(sam, pos + float2(-outputPt.x,  0), 0).rgb;
	s += INPUT.SampleLevel(sam, pos + float2( 0,  outputPt.y), 0).rgb;
	s += INPUT.SampleLevel(sam, pos + float2( 0, -outputPt.y), 0).rgb;
	
	s += INPUT.SampleLevel(sam, pos + float2( outputPt.x,  outputPt.y), 0).rgb;
	s += INPUT.SampleLevel(sam, pos + float2(-outputPt.x,  outputPt.y), 0).rgb;
	s += INPUT.SampleLevel(sam, pos + float2( outputPt.x, -outputPt.y), 0).rgb;
	s += INPUT.SampleLevel(sam, pos + float2(-outputPt.x, -outputPt.y), 0).rgb;
	
	float3 sharp = color - (s / 8);
	
	float sharplum = dot(sharp, float3(0.2126, 0.7152, 0.0722));
	
	float2 outputSize = GetOutputSize();
	
	float scale = sqrt((outputSize.x * outputSize.y) / 2073600);
	
	float clampSharp = max(0.026 / scale, 0.001);
	
	sharplum = clamp(sharplum, -clampSharp, clampSharp);
	
	sharplum = max_color + (7.2 * scale * (1 + luma) * sharplum);
	
	sharplum /= max(max_color, 0.001);
	
	color = lerp(color, color * sharplum, amount * (1 - luma));
	
	return max(color, 0);
}