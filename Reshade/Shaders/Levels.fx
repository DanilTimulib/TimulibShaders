/**
 * Levels version 1.2
 * by Christian Cann Schuldt Jensen ~ CeeJay.dk
 * Edit by Danil Timulib
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

uniform float Strength <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 1.0;
> = 1.0;

uniform float BlackPoint <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 255.0;
	ui_step = 1.0;
	ui_label = "Black Point";
	ui_tooltip = "The black point is the new black - literally. Everything darker than this will become completely black.";
> = 22.0;

uniform float WhitePoint <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 255.0;
	ui_step = 1.0;
	ui_label = "White Point";
	ui_tooltip = "The new white point. Everything brighter than this becomes completely white";
> = 228.0;

uniform float Vibrance <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 1.0;
> = 1.0;

#include "ReShade.fxh"

float3 LevelsPass(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	float black_point_float = BlackPoint / 255.0;
	float white_point_float = WhitePoint / 255.0;
	white_point_float = max(rcp(white_point_float - black_point_float), 0.001); // Avoid division by zero if the white and black point are the same

	float3 color = tex2Dlod(ReShade::BackBuffer, float4(texcoord, 0.0, 0.0)).rgb;
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

technique Levels
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = LevelsPass;
	}
}
