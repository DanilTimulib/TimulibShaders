/**
 * Cartoon
 * by Christian Cann Schuldt Jensen ~ CeeJay.dk
 * Edit and Port by Danil Timulib
 */

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL Power
// Amount of effect you want.
//!DEFAULT 1
//!MIN 0.1
//!MAX 1
//!STEP 0.01
float Power;

//!PARAMETER
//!LABEL Opacity
//!DEFAULT 0.76
//!MIN 0.1
//!MAX 1
//!STEP 0.01
float Opacity;

//!TEXTURE
Texture2D INPUT;

//!SAMPLER
//!FILTER POINT
SamplerState sam;

//!PASS 1
//!DESC CartoonPass
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 pos)
{
	float3 color = INPUT.SampleLevel(sam, pos, 0).rgb;
	float max_color = max(color.r, max(color.g, color.b));
	const float3 coefLuma = float3(0.2126, 0.7152, 0.0722);
	float luma = dot(color, coefLuma);
	luma = abs(luma * 2 - 1);
	luma = lerp(0.66, 0.62, luma);

	float diff1 = dot(coefLuma, INPUT.SampleLevel(sam, pos + GetInputPt(), 0).rgb);
	diff1 = dot(float4(coefLuma, -1), float4(INPUT.SampleLevel(sam, pos - GetInputPt(), 0).rgb , diff1));
	float diff2 = dot(coefLuma, INPUT.SampleLevel(sam, pos + GetInputPt() * float2(1, -1), 0).rgb);
	diff2 = dot(float4(coefLuma, -1), float4(INPUT.SampleLevel(sam, pos + GetInputPt() * float2(-1, 1), 0).rgb , diff2));

	float edge = dot(float2(diff1, diff2), float2(diff1, diff2));
	float2 inputSize = GetInputSize();
	float scale = sqrt((inputSize.x * inputSize.y) / 2073600);

	float newCol = saturate(pow(max(edge, 0), luma) * -Power * 10 * scale + max_color);
	newCol /= max(max_color, 0.001);
	return lerp(color, color * newCol, Opacity);
}