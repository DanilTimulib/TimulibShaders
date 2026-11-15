// Created by Danil Timulib

uniform float amount <
    string label = "Sharpness intensity";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 1.0;

float4 mainImage(VertData v_in) : TARGET
{
	float3 color = image.Sample(textureSampler, v_in.uv).rgb;
	
	float max_color = max(color.r, max(color.g, color.b));
	
	float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
	
	luma = abs(luma * 2.0 - 1.0);
	
	float2 inputPt = rcp(uv_size);
	
	float3 s = 0;
	
	s += image.Sample(textureSampler, v_in.uv + float2( inputPt.x,  0.0)).rgb;
	s += image.Sample(textureSampler, v_in.uv + float2(-inputPt.x,  0.0)).rgb;
	s += image.Sample(textureSampler, v_in.uv + float2( 0.0,  inputPt.y)).rgb;
	s += image.Sample(textureSampler, v_in.uv + float2( 0.0, -inputPt.y)).rgb;
	
	s += image.Sample(textureSampler, v_in.uv + float2( inputPt.x,  inputPt.y)).rgb;
	s += image.Sample(textureSampler, v_in.uv + float2(-inputPt.x,  inputPt.y)).rgb;
	s += image.Sample(textureSampler, v_in.uv + float2( inputPt.x, -inputPt.y)).rgb;
	s += image.Sample(textureSampler, v_in.uv + float2(-inputPt.x, -inputPt.y)).rgb;
	
	float3 sharp = color - (s / 8.0);
	
	float sharplum = dot(sharp, float3(0.2126, 0.7152, 0.0722));
	
	float scale = sqrt((uv_size.x * uv_size.y) / 2073600.0);
	
	float clampSharp = max(0.025 / scale, 0.001);
	
	sharplum = clamp(sharplum, -clampSharp, clampSharp);
	
	sharplum = max_color + (7.2 * scale * (1.0 + luma) * sharplum);
	
	sharplum /= max(max_color, 0.001);
	
	color = lerp(color, color * sharplum, amount * (1.0 - luma));
	
	return float4(max(color, 0.0), 1.0);
}