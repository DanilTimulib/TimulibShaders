// Created by theagentd https://web.archive.org/web/20180927181721/http://www.java-gaming.org/index.php?topic=35123.0
// Port by Danil Timulib

//!MAGPIE EFFECT
//!VERSION 4

//!TEXTURE
Texture2D INPUT;

//!TEXTURE
Texture2D OUTPUT;

//!SAMPLER
//!FILTER LINEAR
SamplerState sam;

//!PASS 1
//!STYLE PS
//!IN INPUT
//!OUT OUTPUT

float4 cubic(float v)
{
	float4 n = float4(1, 2, 3, 4) - v;
	float4 s = n * n * n;
	float x = s.x;
	float y = s.y - 4 * s.x;
	float z = s.z - 4 * s.y + 6 * s.x;
	float w = 6 - x - y - z;
	return float4(x, y, z, w) * rcp(6);
}

float4 Pass1(float2 pos)
{
	float2 texSize = GetOutputSize();
	float2 invTexSize = GetOutputPt();
	
	pos = pos * texSize - 0.5;
	
	float2 fxy = frac(pos);
	pos -= fxy;
	
	float4 xcubic = cubic(fxy.x);
	float4 ycubic = cubic(fxy.y);
	
	float4 c = pos.xxyy + float2(-0.5, 1.5).xyxy;
    	
	float4 s = float4(xcubic.xz + xcubic.yw, ycubic.xz + ycubic.yw);
	float4 offset = c + float4(xcubic.yw, ycubic.yw) / s;
    	
	offset *= invTexSize.xxyy;
 	
	float4 sample0 = INPUT.SampleLevel(sam, offset.xz, 0);
	float4 sample1 = INPUT.SampleLevel(sam, offset.yz, 0);
	float4 sample2 = INPUT.SampleLevel(sam, offset.xw, 0);
	float4 sample3 = INPUT.SampleLevel(sam, offset.yw, 0);
	
	float sx = s.x / (s.x + s.y);
	float sy = s.z / (s.z + s.w);
	
	return lerp(lerp(sample3, sample2, sx), lerp(sample1, sample0, sx), sy);
}