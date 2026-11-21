// Created by Danil Timulib

#include "ReShade.fxh"

uniform float amount <
	ui_type = "slider";
	ui_label = "Sharpness intensity";
> = 1.0;

float3 PS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target
{	
	float3 color = tex2Dlod(ReShade::BackBuffer, float4(texcoord, 0.0, 0.0)).rgb;
	
	float max_color = max(color.r, max(color.g, color.b));
	
	float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
	
	luma = abs(luma * 2.0 - 1.0);
	
	float2 inputPt = BUFFER_PIXEL_SIZE;
	
	float3 s = 0;
	
	s += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2( inputPt.x,  0.0), 0.0, 0.0)).rgb;
	s += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(-inputPt.x,  0.0), 0.0, 0.0)).rgb;
	s += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2( 0.0,  inputPt.y), 0.0, 0.0)).rgb;
	s += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2( 0.0, -inputPt.y), 0.0, 0.0)).rgb;
	
	s += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2( inputPt.x,  inputPt.y), 0.0, 0.0)).rgb;
	s += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(-inputPt.x,  inputPt.y), 0.0, 0.0)).rgb;
	s += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2( inputPt.x, -inputPt.y), 0.0, 0.0)).rgb;
	s += tex2Dlod(ReShade::BackBuffer, float4(texcoord + float2(-inputPt.x, -inputPt.y), 0.0, 0.0)).rgb;
	
	float3 sharp = color - (s / 8.0);
	
	float sharplum = dot(sharp, float3(0.2126, 0.7152, 0.0722));
	
	float scale = sqrt((BUFFER_WIDTH * BUFFER_HEIGHT) / 2073600.0);
	
	float clampSharp = max(0.026 / scale, 0.001);
	
	sharplum = clamp(sharplum, -clampSharp, clampSharp);
	
	sharplum = max_color + (7.2 * scale * (1.0 + luma) * sharplum);
	
	sharplum /= max(max_color, 0.001);
	
	color = lerp(color, color * sharplum, amount * (1.0 - luma));
	
	return max(color, 0.0);
}

technique FastSharp
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = PS;
	}
}