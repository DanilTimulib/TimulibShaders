//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// EyeAdaption by brussell
// v. 2.32
// License: CC BY 4.0
//
// Credits:
// luluco250 - luminance get/store code from Magic Bloom
// Edit and Port by Danil Timulib
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//!MAGPIE EFFECT
//!VERSION 4

//!PARAMETER
//!LABEL Monitor Refresh Rate
//!DEFAULT 60
//!MIN 30
//!MAX 240
//!STEP 1.0
float FPS;

//!PARAMETER
//!LABEL Adaption Delay
// How fast the image adapts to brightness changes.
// 0 = instantanous adaption
// 2 = very slow adaption
//!DEFAULT 1.6
//!MIN 0
//!MAX 2
//!STEP 0.01
float fAdp_Delay;

//!PARAMETER
//!LABEL Adaption TriggerRadius
// Screen area, whose average brightness triggers adaption.
// 1 = only the center of the image is used
// 7 = the whole image is used
//!DEFAULT 6
//!MIN 1
//!MAX 7
//!STEP 0.1
float fAdp_TriggerRadius;

//!PARAMETER
//!LABEL Y Axis Focal Point
// Where along the Y Axis the Adaption TriggerRadius applies.
// 0 = Top of the screen
// 1 = Bottom of the screen
//!DEFAULT 0.5
//!MIN 0
//!MAX 1
//!STEP 0.01
float fAdp_YAxisFocalPoint;

//!PARAMETER
//!LABEL Adaption Equilibrium
// The value of image brightness for which there is no brightness adaption.
// 0 = early brightening, late darkening
// 1 = late brightening, early darkening
//!DEFAULT 0.5
//!MIN 0
//!MAX 1
//!STEP 0.01
float fAdp_Equilibrium;

//!PARAMETER
//!LABEL Adaption Strength
// Base strength of brightness adaption.
//!DEFAULT 1
//!MIN 0
//!MAX 1
//!STEP 0.01
float fAdp_Strength;

//!PARAMETER
//!LABEL Brighten Highlights
// Brightening strength for highlights.
//!DEFAULT 0.1
//!MIN 0
//!MAX 1
//!STEP 0.01
float fAdp_BrightenHighlights;

//!PARAMETER
//!LABEL Brighten Midtones
// Brightening strength for midtones.
//!DEFAULT 0.2
//!MIN 0
//!MAX 1
//!STEP 0.01
float fAdp_BrightenMidtones;

//!PARAMETER
//!LABEL Brighten Shadows
// Brightening strength for shadows.
// Set this to 0 to preserve pure black.
//!DEFAULT 0.1
//!MIN 0
//!MAX 1
//!STEP 0.01
float fAdp_BrightenShadows;

//!PARAMETER
//!LABEL Darken Highlights
// Darkening strength for highlights.
// Set this to 0 to preserve pure white.
//!DEFAULT 0.1
//!MIN 0
//!MAX 1
//!STEP 0.01
float fAdp_DarkenHighlights;

//!PARAMETER
//!LABEL Darken Midtones
// Darkening strength for midtones.
//!DEFAULT 0.2
//!MIN 0
//!MAX 1
//!STEP 0.01
float fAdp_DarkenMidtones;

//!PARAMETER
//!LABEL Darken Shadows
// Darkening strength for shadows.
//!DEFAULT 0.1
//!MIN 0
//!MAX 1
//!STEP 0.01
float fAdp_DarkenShadows;

//!TEXTURE
Texture2D INPUT;

//!TEXTURE
//!WIDTH INPUT_WIDTH
//!HEIGHT INPUT_HEIGHT
Texture2D OUTPUT;

//!TEXTURE
//!WIDTH 256
//!HEIGHT 256
//!FORMAT R16_FLOAT
// MipLevel = 0
Texture2D TexLuma;

//!TEXTURE
//!WIDTH 128
//!HEIGHT 128
//!FORMAT R16_FLOAT
// MipLevel = 1
Texture2D TexLuma1;

//!TEXTURE
//!WIDTH 64
//!HEIGHT 64
//!FORMAT R16_FLOAT
// MipLevel = 2
Texture2D TexLuma2;

//!TEXTURE
//!WIDTH 32
//!HEIGHT 32
//!FORMAT R16_FLOAT
// MipLevel = 3
Texture2D TexLuma3;

//!TEXTURE
//!WIDTH 16
//!HEIGHT 16
//!FORMAT R16_FLOAT
// MipLevel = 4
Texture2D TexLuma4;

//!TEXTURE
//!WIDTH 8
//!HEIGHT 8
//!FORMAT R16_FLOAT
// MipLevel = 5
Texture2D TexLuma5;

//!TEXTURE
//!WIDTH 4
//!HEIGHT 4
//!FORMAT R16_FLOAT
// MipLevel = 6
Texture2D TexLuma6;

//!TEXTURE
//!WIDTH 1
//!HEIGHT 1
//!FORMAT R16_FLOAT
Texture2D TexAvgLuma;

//!TEXTURE
//!WIDTH 1
//!HEIGHT 1
//!FORMAT R16_FLOAT
Texture2D TexAvgLumaLast;

//!SAMPLER
//!FILTER LINEAR
SamplerState SampleLinear;

//!SAMPLER
//!FILTER POINT
SamplerState SamplePoint;

//!COMMON
#define LumCoeff float3(0.212656, 0.715158, 0.072186)

//!PASS 1
//!DESC PS_StoreAvgLuma
//!STYLE PS
//!IN TexAvgLuma
//!OUT TexAvgLumaLast
float Pass1(float2 texcoord) {
    float avgLuma = TexAvgLuma.SampleLevel(SampleLinear, float2(0.0.xx), 0).x;
    return avgLuma;
}

//!PASS 2
//!DESC PS_Luma
//!STYLE PS
//!IN INPUT
//!OUT TexLuma
float Pass2(float2 texcoord) {
    float4 color = INPUT.SampleLevel(SampleLinear, texcoord, 0);
    float luma = dot(color.xyz, LumCoeff);
    return luma;
}

//!PASS 3
//!DESC TexLuma1
//!STYLE PS
//!IN TexLuma
//!OUT TexLuma1
float Pass3(float2 texcoord) {
    return TexLuma.SampleLevel(SampleLinear, texcoord, 0).x;
}

//!PASS 4
//!DESC TexLuma2
//!STYLE PS
//!IN TexLuma1
//!OUT TexLuma2
float Pass4(float2 texcoord) {
    return TexLuma1.SampleLevel(SampleLinear, texcoord, 0).x;
}

//!PASS 5
//!DESC TexLuma3
//!STYLE PS
//!IN TexLuma2
//!OUT TexLuma3
float Pass5(float2 texcoord) {
    return TexLuma2.SampleLevel(SampleLinear, texcoord, 0).x;
}

//!PASS 6
//!DESC TexLuma4
//!STYLE PS
//!IN TexLuma3
//!OUT TexLuma4
float Pass6(float2 texcoord) {
    return TexLuma3.SampleLevel(SampleLinear, texcoord, 0).x;
}

//!PASS 7
//!DESC TexLuma5
//!STYLE PS
//!IN TexLuma4
//!OUT TexLuma5
float Pass7(float2 texcoord) {
    return TexLuma4.SampleLevel(SampleLinear, texcoord, 0).x;
}

//!PASS 8
//!DESC TexLuma6
//!STYLE PS
//!IN TexLuma5
//!OUT TexLuma6
float Pass8(float2 texcoord) {
    return TexLuma5.SampleLevel(SampleLinear, texcoord, 0).x;
}

//!PASS 9
//!DESC PS_AvgLuma
//!STYLE PS
//!IN TexLuma6, TexAvgLumaLast
//!OUT TexAvgLuma
float Pass9(float2 texcoord) {
    float avgLumaCurrFrame = TexLuma6.SampleLevel(SampleLinear, float2(fAdp_YAxisFocalPoint.xx), fAdp_TriggerRadius).x;
    float avgLumaLastFrame = TexAvgLumaLast.SampleLevel(SamplePoint, float2(0.0.xx), 0).x;
    float Frametime = 1000.0 / FPS;
    float delay = sign(fAdp_Delay) * saturate(0.815 + fAdp_Delay / 10.0 - Frametime / 1000.0);
    float avgLuma = lerp(avgLumaCurrFrame, avgLumaLastFrame, delay);
    return avgLuma;
}

//!PASS 10
//!DESC PS_Adaption
//!STYLE PS
//!IN INPUT, TexAvgLuma
//!OUT OUTPUT

float AdaptionDelta(float luma, float strengthMidtones, float strengthShadows, float strengthHighlights)
{
    float midtones = (4.0 * strengthMidtones - strengthHighlights - strengthShadows) * luma * (1.0 - luma);
    float shadows = strengthShadows * (1.0 - luma);
    float highlights = strengthHighlights * luma;
    float delta = midtones + shadows + highlights;
    return delta;
}

float4 Pass10(float2 texcoord) {
    float3 color = INPUT.SampleLevel(SamplePoint, texcoord, 0).xyz;
    float avgLuma = TexAvgLuma.SampleLevel(SampleLinear, float2(0.0.xx), 0).x;

    float max_color = max(color.x, max(color.y, color.z));
    float luma = dot(color, LumCoeff);
    luma = abs(luma * 2.0 - 1.0);
    luma = lerp(0.5, 1.0, luma);

    float avgLumaAdjusted = lerp (avgLuma, 1.4 * avgLuma / (0.4 + avgLuma), fAdp_Equilibrium);
    float delta = 0;

    float curve = fAdp_Strength * 20.0 * luma * pow(abs(avgLumaAdjusted - 0.5), 4.0);
    if (avgLumaAdjusted < 0.5) {
        delta = AdaptionDelta(max_color, fAdp_BrightenMidtones, fAdp_BrightenShadows, fAdp_BrightenHighlights);
    } else {
        delta = -AdaptionDelta(max_color, fAdp_DarkenMidtones, fAdp_DarkenShadows, fAdp_DarkenHighlights);
    }
    delta *= curve;
    delta /= max(max_color, 0.001);

    return float4(color + color * delta, 1);
}