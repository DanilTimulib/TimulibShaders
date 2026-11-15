/**
  Vibrance
  by Christian Cann Schuldt Jensen ~ CeeJay.dk
  Edit and Port by Danil Timulib
 
  Vibrance intelligently boosts the saturation of pixels so pixels that had little color get a larger boost than pixels that had a lot.
  This avoids oversaturation of pixels that were already very saturated.

  History:

  Version 1.0 by Ceejay.dk
  - Original 
  Version 1.1 by CeeJay.dk
  - Introduced RBG balance to help colorblind users
  Version 1.1.1
  - Minor UI improvements for Reshade 3.x
 */

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL Vibrance
// Intelligently saturates the pixels depending on their original saturation.
//!DEFAULT 1
//!MIN 0
//!MAX 1
//!STEP 0.01
float Vibrance;

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
	float3 orig = color;
	
	float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
	
	float3 chroma = color - luma;
	
	float max_color = max(chroma.r, max(chroma.g, chroma.b));
	float min_color = min(chroma.r, min(chroma.g, chroma.b));
	
	float color_saturation = max_color - min_color;
	
	max_color = max(color.r, max(color.g, color.b));
	
	color = lerp(luma, color, 1 + max(Vibrance * (1 - color_saturation), 0));
	
	color -= orig;
	color += max_color;
	color /= max(max_color, 0.001);
	
	return orig * color;
}