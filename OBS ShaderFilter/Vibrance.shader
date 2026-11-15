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

uniform float Vibrance <
    string label = "Vibrance";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 1.0;

float4 mainImage(VertData v_in) : TARGET
{
	float3 color = image.Sample(textureSampler, v_in.uv).rgb;
	float3 orig = color;
	
	float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
	
	float3 chroma = color - luma;
	
	float max_color = max(chroma.r, max(chroma.g, chroma.b));
	float min_color = min(chroma.r, min(chroma.g, chroma.b));
	
	float color_saturation = max_color - min_color;
	
	max_color = max(color.r, max(color.g, color.b));
	
	color = lerp(luma, color, 1.0 + max(Vibrance * (1.0 - color_saturation), 0.0));
	
	color -= orig;
	color += max_color;
	color /= max(max_color, 0.001);
	
	return float4(orig * color, 1.0);
}