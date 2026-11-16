// Edit by Danil Timulib

//!MAGPIE EFFECT
//!VERSION 4

//!TEXTURE
Texture2D INPUT;

//!TEXTURE
Texture2D OUTPUT;

//!SAMPLER
//!FILTER POINT
SamplerState sam;

//!SAMPLER
//!FILTER LINEAR
SamplerState sam1;

//!PASS 1
//!STYLE PS
//!IN INPUT
//!OUT OUTPUT
float4 Pass1(float2 pos)
{
	float4 color = INPUT.SampleLevel(sam, pos, 0);
	float max_color = max(color.r, max(color.g, color.b));
	float4 Bilinear = INPUT.SampleLevel(sam1, pos, 0);
	Bilinear -= color;
	Bilinear += max_color;
	Bilinear /= max(max_color, 0.001);
	return color * Bilinear;
}