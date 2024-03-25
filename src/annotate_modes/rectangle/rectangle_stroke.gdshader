// Very simple rectangle shader which supports both hollow and filled rectangles.
shader_type canvas_item;

uniform float border_width = 10.0;
uniform float fill = 1.f;

varying vec2 local_pos;

void vertex()
{
	// store the position of the pixel, relative to the node origin,
	// this is needed for determening if the pixel belongs to a the border.
	local_pos = VERTEX;
}

void fragment()
{
	vec2 fill_rect_tl = vec2(border_width);
	vec2 fill_rect_br = local_pos / UV - border_width;
	
	vec2 tl_border = step(fill_rect_tl, local_pos);
	vec2 br_border = step(local_pos, fill_rect_br);

	float fill_alpha = tl_border.x * tl_border.y * br_border.x * br_border.y;
	
	COLOR.a = 1.f - fill_alpha * (1.f - fill);
}
