/**
 * Cartoon
 * by Christian Cann Schuldt Jensen ~ CeeJay.dk
 * Edit by Danil Timulib
 */

uniform float Power <
	ui_type = "slider";
	ui_min = 0.1; ui_max = 1.0;
	ui_tooltip = "Amount of effect you want.";
> = 1.0;

uniform float Opacity <
	ui_type = "slider";
	ui_min = 0.1; ui_max = 1.0;
> = 0.76;

#include "ReShade.fxh"

float3 CartoonPass(float4 position : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float3 color = tex2Dlod(ReShade::BackBuffer, float4(texcoord, 0.0, 0.0)).rgb;
	float max_color = max(color.r, max(color.g, color.b));
	const float3 coefLuma = float3(0.2126, 0.7152, 0.0722);
	float luma = dot(color, coefLuma);
	luma = abs(luma * 2.0 - 1.0);
	luma = lerp(0.66, 0.62, luma);

	float diff1 = dot(coefLuma, tex2Dlod(ReShade::BackBuffer, float4(texcoord + BUFFER_PIXEL_SIZE, 0.0, 0.0)).rgb);
	diff1 = dot(float4(coefLuma, -1.0), float4(tex2Dlod(ReShade::BackBuffer, float4(texcoord - BUFFER_PIXEL_SIZE, 0.0, 0.0)).rgb , diff1));
	float diff2 = dot(coefLuma, tex2Dlod(ReShade::BackBuffer, float4(texcoord + BUFFER_PIXEL_SIZE * float2(1, -1), 0.0, 0.0)).rgb);
	diff2 = dot(float4(coefLuma, -1.0), float4(tex2Dlod(ReShade::BackBuffer, float4(texcoord + BUFFER_PIXEL_SIZE * float2(-1, 1), 0.0, 0.0)).rgb , diff2));

	float edge = dot(float2(diff1, diff2), float2(diff1, diff2));
	float scale = sqrt((BUFFER_WIDTH * BUFFER_HEIGHT) / 2073600.0);

	float newCol = saturate(pow(max(edge, 0.0), luma) * -Power * 10.0 * scale + max_color);
	newCol /= max(max_color, 0.001);
	return lerp(color, color * newCol, Opacity);
}

technique Cartoon
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = CartoonPass;
	}
}
