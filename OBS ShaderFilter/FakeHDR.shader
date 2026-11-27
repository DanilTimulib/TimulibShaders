// Create by Danil Timulib
// ACES by Krzysztof Narkowicz https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/

float4 mainImage(VertData v_in) : TARGET
{
	float3 color = image.Sample(textureSampler, v_in.uv).rgb;
	
	float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
	
	color = pow(max(color, 0.0), 3.08);
	
	float3 orig = color;
	
	float max_color = max(color.r, max(color.g, color.b));
	
	float ACES_A = 2.51;
	float ACES_B = (luma < 0.5) ? lerp(0.12, -0.06, luma) : 0.03;
	float ACES_C = 2.43;
	float ACES_D = 0.59;
	float ACES_E = 0.14;
	
	color = saturate((color*(ACES_A*color+ACES_B))/(color*(ACES_C*color+ACES_D)+ACES_E));
	color -= orig;
	color += max_color;
	color /= max(max_color, 0.001);
	color *= orig;
	
	color = pow(max(color, 0.0), rcp(2.2));
	
	return float4(max(color, 0.0), 1.0);
}