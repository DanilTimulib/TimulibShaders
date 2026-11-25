/*
   Bumpmapping Shader
   
   Copyright (C) 2019 guest(r)
   Edit and Port by Danil Timulib

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

//!MAGPIE EFFECT
//!VERSION 4

//!PARAMETER
//!LABEL BumpMapping Strength
//!DEFAULT 1
//!MIN 0
//!MAX 1
//!STEP 0.01
float EMBOSS;

//!TEXTURE
Texture2D INPUT;

//!TEXTURE
//!WIDTH INPUT_WIDTH
//!HEIGHT INPUT_HEIGHT
Texture2D OUTPUT;

//!SAMPLER
//!FILTER POINT
SamplerState sam;

//!PASS 1
//!STYLE PS
//!IN INPUT
//!OUT OUTPUT

float3 GetWeight(float3 dif1)
{
	return lerp(float3(1.0,1.0,1.0), 0.7*dif1 + 0.3, 0.72);
}

float4 Pass1(float2 pos)
{
	float3 c11 = INPUT.SampleLevel(sam, pos, 0).rgb;
	
	float max_color = max(c11.r, max(c11.g, c11.b));
	
	float luma = dot(c11, float3(0.2126, 0.7152, 0.0722));
	luma = abs(luma * 2 - 1);
	luma = lerp(0.5, 1, luma);
	
	float2 inputPt = GetInputPt();
	
	float3 c21 = INPUT.SampleLevel(sam, pos + float2( inputPt.x,  0), 0).rgb;
	float3 c12 = INPUT.SampleLevel(sam, pos + float2( 0,  inputPt.y), 0).rgb;
	float3 c22 = INPUT.SampleLevel(sam, pos + float2( inputPt.x,  inputPt.y), 0).rgb;
	float3 c00 = INPUT.SampleLevel(sam, pos - float2( inputPt.x,  inputPt.y), 0).rgb;
	float3 c10 = INPUT.SampleLevel(sam, pos - float2( 0,  inputPt.y), 0).rgb;
	float3 c01 = INPUT.SampleLevel(sam, pos - float2( inputPt.x,  0), 0).rgb;
	
	float2 inputSize = GetInputSize();
	float scale = sqrt((inputSize.x * inputSize.y) / 2073600);
	
	float3 w00 = GetWeight(saturate(2.25*abs(c00-c22)/(c00+c22+0.25)));
	float3 w01 = GetWeight(saturate(2.25*abs(c01-c21)/(c01+c21+0.25)));
	float3 w10 = GetWeight(saturate(2.25*abs(c10-c12)/(c10+c12+0.25)));
	
	float3 b11 = (w00*(c00-c22) + w01*(c01-c21) + w10*(c10-c12));
	float bumplum = dot(b11, float3(0.2126, 0.7152, 0.0722));
	bumplum += max_color;
	bumplum /= max(max_color, 0.001);
	
	c11 = clamp(lerp(c11,c11*bumplum,-EMBOSS*2.2*scale*luma),-c11*max(3.2*scale,3.2),c11*max(3.2*scale,3.2));
	
	return float4(max(c11, 0), 1);
}