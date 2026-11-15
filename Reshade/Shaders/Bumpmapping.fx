/*
   Bumpmapping Shader
   
   Copyright (C) 2019 guest(r)
   Edit by Danil Timulib

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

#include "ReShade.fxh"

uniform float EMBOSS <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 1.0;
	ui_label = "BumpMapping Strength";
	ui_tooltip = "BumpMapping Strength";
> = 1.0;  
 
float3 GetWeight(float3 dif1)
{
	return lerp(float3(1.0,1.0,1.0), 0.7*dif1 + 0.3, 0.75);
}

float3 BUMP(float4 pos : SV_Position, float2 uv : TexCoord) : SV_Target
{
	// Calculating texel coordinates
	float2 inv_size = ReShade::PixelSize;	

	float2 dx = float2(inv_size.x,0.0);
	float2 dy = float2(0.0, inv_size.y);
	float2 g1 = float2(inv_size.x,inv_size.y);
		
	// Reading the texels
	float3 c00 = tex2Dlod(ReShade::BackBuffer,float4(uv - g1,0.0,0.0)).rgb; 
	float3 c10 = tex2Dlod(ReShade::BackBuffer,float4(uv - dy,0.0,0.0)).rgb;
	float3 c01 = tex2Dlod(ReShade::BackBuffer,float4(uv - dx,0.0,0.0)).rgb;
	float3 c11 = tex2Dlod(ReShade::BackBuffer,float4(uv,0.0,0.0)).rgb;
	float3 c21 = tex2Dlod(ReShade::BackBuffer,float4(uv + dx,0.0,0.0)).rgb;
	float3 c12 = tex2Dlod(ReShade::BackBuffer,float4(uv + dy,0.0,0.0)).rgb;
	float3 c22 = tex2Dlod(ReShade::BackBuffer,float4(uv + g1,0.0,0.0)).rgb;
	
	float scale = sqrt((BUFFER_WIDTH * BUFFER_HEIGHT) / 2073600.0);
	
	float max_color = max(c11.r, max(c11.g, c11.b));
	
	float luma = dot(c11, float3(0.2126, 0.7152, 0.0722));
	luma = abs(luma * 2.0 - 1.0);
	luma = lerp(0.5, 1.0, luma);

	float3 w00 = GetWeight(saturate(2.25*abs(c00-c22)/(c00+c22+0.25)));
	float3 w01 = GetWeight(saturate(2.25*abs(c01-c21)/(c01+c21+0.25)));
	float3 w10 = GetWeight(saturate(2.25*abs(c10-c12)/(c10+c12+0.25)));
	
	float3 b11 = (w00*(c00-c22) + w01*(c01-c21) + w10*(c10-c12));
	float bumplum = dot(b11, float3(0.2126, 0.7152, 0.0722));
	bumplum += max_color;
	bumplum /= max(max_color, 0.001);

	c11 = clamp(lerp(c11,c11*bumplum,-EMBOSS*2.0*scale*luma),-c11*max(3.0*scale,3.0),c11*max(3.0*scale,3.0));  
	
	return max(c11, 0.0);
}

technique Bumpmapping
{
	pass bump
	{
		VertexShader = PostProcessVS;
		PixelShader = BUMP;
	}
}
