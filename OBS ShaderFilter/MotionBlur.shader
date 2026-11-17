// Created by Danil Timulib

uniform texture2d previous_output;

uniform float Strength <
    string label = "Motion Blur intensity";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 0.9;
    float step = 0.01;
> = 0.52;

float4 mainImage(VertData v_in) : TARGET
{
	float4 curr = image.Sample(textureSampler, v_in.uv);
	float4 prev = previous_output.Sample(textureSampler, v_in.uv);
	float currLum = dot(curr.rgb, float3(0.2126, 0.7152, 0.0722));
	float prevLum = dot(prev.rgb, float3(0.2126, 0.7152, 0.0722));
	float max_color = max(curr.r, max(curr.g, curr.b));
	float luma = abs(currLum * 2.0 - 1.0);
	luma = lerp(0.5, 1.0, luma);
	prevLum = lerp(currLum, prevLum, Strength * luma);
	prevLum -= currLum;
	prevLum += max_color;
	prevLum /= max(max_color, 0.001);
	return curr * prevLum;
}