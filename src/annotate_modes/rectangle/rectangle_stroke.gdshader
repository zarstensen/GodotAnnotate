// Very simple rectangle shader which supports both hollow and filled rectangles.
shader_type canvas_item;

uniform float border_width = 100.0;
uniform bool fill = true;

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
	
	bool is_fill_color = all(greaterThan(local_pos, fill_rect_tl)) &&
						all(lessThanEqual(local_pos, fill_rect_br));
	
	if(!fill && is_fill_color)
		COLOR.a *= 0.f;
}
