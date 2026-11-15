/**
 * Levels version 1.2
 * by Christian Cann Schuldt Jensen ~ CeeJay.dk
 * Edit and Port by Danil Timulib
 *
 * Allows you to set a new black and a white level.
 * This increases contrast, but clips any colors outside the new range to either black or white
 * and so some details in the shadows or highlights can be lost.
 *
 * The shader is very useful for expanding the 16-235 TV range to 0-255 PC range.
 * You might need it if you're playing a game meant to display on a TV with an emulator that does not do this.
 * But it's also a quick and easy way to uniformly increase the contrast of an image.
 *
 * -- Version 1.0 --
 * First release
 * -- Version 1.1 --
 * Optimized to only use 1 instruction (down from 2 - a 100% performance increase :) )
 * -- Version 1.2 --
 * Added the ability to highlight clipping regions of the image with #define HighlightClipping 1
 */

//!MAGPIE EFFECT
//!VERSION 3
//!OUTPUT_WIDTH INPUT_WIDTH
//!OUTPUT_HEIGHT INPUT_HEIGHT

//!PARAMETER
//!LABEL Strength
//!DEFAULT 1
//!MIN 0
//!MAX 1
//!STEP 0.01
float Strength;

//!PARAMETER
//!LABEL Black Point
// The black point is the new black - literally. Everything darker than this will become completely black.
//!DEFAULT 22
//!MIN 0
//!MAX 255
//!STEP 1
float BlackPoint;

//!PARAMETER
//!LABEL White Point
// The new white point. Everything brighter than this becomes completely white
//!DEFAULT 228
//!MIN 0
//!MAX 255
//!STEP 1
float WhitePoint;

//!PARAMETER
//!LABEL Vibrance
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
//!DESC LevelsPass
//!STYLE PS
//!IN INPUT
float3 Pass1(float2 pos)
{
	float black_point_float = BlackPoint / 255.0;
	float white_point_float = WhitePoint / 255.0;
	white_point_float = max(rcp(white_point_float - black_point_float), 0.001);

	float3 color = INPUT.SampleLevel(sam, pos, 0).rgb;
	float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
	luma = abs(luma * 2.0 - 1.0);
	luma = lerp(0.5, 1.0, luma);
	float max_color = max(color.r, max(color.g, color.b));
	float newMax = saturate(max_color * white_point_float - (black_point_float * white_point_float));
	float scaleMax = newMax / max(max_color, 0.001);
	color = lerp(color, color * scaleMax, Strength * luma);
	float3 levelsCol = color;

	luma = dot(color, float3(0.2126, 0.7152, 0.0722));
	float3 chroma = color - luma;
	max_color = max(chroma.r, max(chroma.g, chroma.b));
	float min_color = min(chroma.r, min(chroma.g, chroma.b));
	float color_saturation = max_color - min_color;
	max_color = max(color.r, max(color.g, color.b));
	color = lerp(luma, color, 1.0 + max(Vibrance * (1.0 - color_saturation), 0.0));

	color -= levelsCol;
	color += max_color;
	color /= max(max_color, 0.001);

	return max(levelsCol * color, 0.0);
}