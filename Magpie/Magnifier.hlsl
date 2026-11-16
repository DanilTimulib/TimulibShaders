// Created by mhgar https://github.com/mhgar/ReShade-Magnifier
// Edit and Port by Danil Timulib

//!MAGPIE EFFECT
//!VERSION 4

//!PARAMETER
//!LABEL DrawPosition_X
// The position on your on screen where the magnifier will draw (does not work in when the magnifier is set to fullscreen).
//!DEFAULT 0.5
//!MIN 0
//!MAX 1
//!STEP 0.01
float DrawPosition_X;

//!PARAMETER
//!LABEL DrawPosition_Y
// The position on your on screen where the magnifier will draw (does not work in when the magnifier is set to fullscreen).
//!DEFAULT 0.5
//!MIN 0
//!MAX 1
//!STEP 0.01
float DrawPosition_Y;

//!PARAMETER
//!LABEL MagnifyPosition_X
// The position on your screen that the magnifier will magnify (usually (0.5, 0.5)).
//!DEFAULT 0.5
//!MIN 0
//!MAX 1
//!STEP 0.01
float MagnifyPosition_X;

//!PARAMETER
//!LABEL MagnifyPosition_Y
// The position on your screen that the magnifier will magnify (usually (0.5, 0.5)).
//!DEFAULT 0.5
//!MIN 0
//!MAX 1
//!STEP 0.01
float MagnifyPosition_Y;

//!PARAMETER
//!LABEL Shape
// Choose the shape of the magnifier.
//!DEFAULT 0
//!MIN 0
//!MAX 2
//!STEP 1
int Shape;

//!PARAMETER
//!LABEL CircleRadius
// The radius in pixels of the magnifier when it is drawn as a circle.
//!DEFAULT 375
//!MIN 0
//!MAX 1000
//!STEP 1
float UI_CircleRadius;

//!PARAMETER
//!LABEL RectangleHalfExtent_X
// The half size of the magnifier in pixels when it is drawn as a rectangle.
//!DEFAULT 300
//!MIN 0
//!MAX 1000
//!STEP 1
float RectangleHalfExtent_X;

//!PARAMETER
//!LABEL RectangleHalfExtent_Y
// The half size of the magnifier in pixels when it is drawn as a rectangle.
//!DEFAULT 200
//!MIN 0
//!MAX 1000
//!STEP 1
float RectangleHalfExtent_Y;

//!PARAMETER
//!LABEL ZoomLevel
// How much the magnifier will scale things.
//!DEFAULT 3
//!MIN 1
//!MAX 10
//!STEP 0.1
float ZoomLevel;

//!PARAMETER
//!LABEL CircleFeathering
// Size of feathered edges in pixels, only works for the circle setting right now.
//!DEFAULT 26
//!MIN 0
//!MAX 1000
//!STEP 1
float CircleFeathering;

//!PARAMETER
//!LABEL MagnifierOpacity
// How much opacity the magnifier has.
//!DEFAULT 1
//!MIN 0
//!MAX 1
//!STEP 0.01
float MagnifierOpacity;

//!TEXTURE
Texture2D INPUT;

//!TEXTURE
//!WIDTH INPUT_WIDTH
//!HEIGHT INPUT_HEIGHT
Texture2D OUTPUT;

//!SAMPLER
//!FILTER POINT
SamplerState sam;

//!SAMPLER
//!FILTER LINEAR
SamplerState sam1;

//!COMMON
#define MODE_CIRCLE 0
#define MODE_RECTANGLE 1
#define MODE_FULLSCREEN 2

//!PASS 1
//!STYLE PS
//!IN INPUT
//!OUT OUTPUT
float4 Pass1(float2 pos)
{
	float2 screenSize = GetInputSize();
	float2 MagnifyPosition = float2(MagnifyPosition_X, MagnifyPosition_Y);
	float2 DrawPosition = float2(DrawPosition_X, DrawPosition_Y);
	float2 RectangleHalfExtent = float2(RectangleHalfExtent_X, RectangleHalfExtent_Y);
	float scale = sqrt((screenSize.x * screenSize.y) / 2073600);
	float CircleRadius = UI_CircleRadius * scale;
	scale = 1 / ZoomLevel;

	float2 draw_pos = (Shape == MODE_FULLSCREEN) ? float2(0.5, 0.5) : DrawPosition;

	float2 uv_screen = float2(pos.x * screenSize.x, pos.y * screenSize.y);
	float2 draw_pos_screen = float2(draw_pos.x * screenSize.x, draw_pos.y * screenSize.y);

	int magnifiy = 0;

	if (Shape == MODE_CIRCLE) {
		float2 diff = uv_screen - draw_pos_screen;
		float dist2 = diff.x * diff.x + diff.y * diff.y;
		magnifiy = dist2 <= (CircleRadius * CircleRadius);
	} else if (Shape == MODE_RECTANGLE) {
		magnifiy = (abs(uv_screen.x - draw_pos_screen.x) <= RectangleHalfExtent.x) &&
				   (abs(uv_screen.y - draw_pos_screen.y) <= RectangleHalfExtent.y);
	} else if (Shape == MODE_FULLSCREEN) {
		magnifiy = 1;
	}

	if (magnifiy) {
		float2 offset = pos - draw_pos;
		float2 take_pos = MagnifyPosition + offset * scale;

		if (take_pos.x < 0 || take_pos.x > 1 || take_pos.y < 0 || take_pos.y > 1) {
			return float4(0, 0, 0, 1);
		} else {
			float4 behind_pixel = INPUT.SampleLevel(sam, pos, 0);

			float opacity = 0;
			if (Shape == MODE_CIRCLE && CircleFeathering > 0) {
				float2 offset_screen = offset * screenSize;
				float magnitude = sqrt(offset_screen.x * offset_screen.x + offset_screen.y * offset_screen.y);
				float startRadius = CircleRadius - CircleFeathering;

				if (magnitude >= CircleRadius) {
					opacity = 1;
				} else if (magnitude <= startRadius) {
					opacity = 0;
				} else {
					float falloff = (magnitude - startRadius) / CircleFeathering;
					opacity = falloff * falloff;
				}
			}

			float4 LINEAR = INPUT.SampleLevel(sam1, take_pos, 0);
			float4 POINT = INPUT.SampleLevel(sam, take_pos, 0);
			float max_color = max(POINT.r, max(POINT.g, POINT.b));
			LINEAR -= POINT;
			LINEAR += max_color;
			LINEAR /= max(max_color, 0.001);

			return lerp(behind_pixel, lerp(POINT * LINEAR, behind_pixel, opacity), MagnifierOpacity);
		}
	} else {
		return INPUT.SampleLevel(sam, pos, 0);
	}
}