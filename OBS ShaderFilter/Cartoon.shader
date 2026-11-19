/**
 * Cartoon
 * by Christian Cann Schuldt Jensen ~ CeeJay.dk
 * Edit and Port by Danil Timulib
 */

uniform float Power <
    string label = "Power";
    string widget_type = "slider";
    float minimum = 0.1;
    float maximum = 1.0;
    float step = 0.01;
> = 1.0;

uniform float Opacity <
    string label = "Opacity";
    string widget_type = "slider";
    float minimum = 0.1;
    float maximum = 1.0;
    float step = 0.01;
> = 0.76;

float4 mainImage(VertData v_in) : TARGET
{
	float3 color = image.Sample(textureSampler, v_in.uv).rgb;
	float max_color = max(color.r, max(color.g, color.b));
	const float3 coefLuma = float3(0.2126, 0.7152, 0.0722);
	float luma = dot(color, coefLuma);
	luma = abs(luma * 2.0 - 1.0);
	luma = lerp(0.66, 0.62, luma);

	float diff1 = dot(coefLuma, image.Sample(textureSampler, v_in.uv + rcp(uv_size)).rgb);
	diff1 = dot(float4(coefLuma, -1.0), float4(image.Sample(textureSampler, v_in.uv - rcp(uv_size)).rgb , diff1));
	float diff2 = dot(coefLuma, image.Sample(textureSampler, v_in.uv + rcp(uv_size) * float2(1, -1)).rgb);
	diff2 = dot(float4(coefLuma, -1.0), float4(image.Sample(textureSampler, v_in.uv + rcp(uv_size) * float2(-1, 1)).rgb , diff2));

	float edge = dot(float2(diff1, diff2), float2(diff1, diff2));
	float scale = sqrt((uv_size.x * uv_size.y) / 2073600.0);

	float newCol = saturate(pow(max(edge, 0.0), luma) * -Power * 10.2 * scale + max_color);
	newCol /= max(max_color, 0.001);
	return float4(lerp(color, color * newCol, Opacity), 1.0);
}