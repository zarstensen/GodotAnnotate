// Capsule shader which supports both hollow and filled capsules.
shader_type canvas_item;

uniform float border_width = 100.0;
uniform float fill = 0.f;

varying vec2 local_pos;

// collision function between point and capsule aligned with x-axis,
// returns 1 if position is inside the capsule described by capsule_rad and capsule_rect_width,
// and 1 if it is inside.
// the capsule is centered at uv coordinates (0.5, 0.5).
// capsule_rect_width is the width of the capsule EXCLUDING the circle caps,
// so the total width of the capsule would be equal to capsule_rect_width + capsule_rad * 2.
float capsuleCollide(float capsule_rad, float capsule_rect_width, vec2 point, vec2 size)
{
	// calculate alpha
	float alpha = 0.0f;

	vec2 circle_center_a = size / 2.f;

	circle_center_a.x += capsule_rect_width / 2.f;

	vec2 circle_center_b = size - circle_center_a;

	vec2 circle_a_pos = circle_center_a - point;
	vec2 circle_b_pos = circle_center_b - point;

	float circle_a_pos_dist_sq = dot(circle_a_pos, circle_a_pos);
	float circle_b_pos_dist_sq = dot(circle_b_pos, circle_b_pos);

	// circle caps
	alpha += step(circle_a_pos_dist_sq, capsule_rad * capsule_rad);
	alpha += step(circle_b_pos_dist_sq, capsule_rad * capsule_rad);
	
	// rectangle body section
	alpha += step((size.x - capsule_rect_width) / 2.f, point.x) *
			step(point.x, (size.x + capsule_rect_width) / 2.f) *
			step(size.y / 2.f - capsule_rad, point.y) *
			step(point.y, size.y / 2.f + capsule_rad);

	return clamp(alpha, 0.f, 1.f);
}

void vertex()
{
	// store the position of the pixel, relative to the node origin,
	// this is needed for determening if the pixel belongs to a the border.
	local_pos = VERTEX;
}

void fragment()
{
	vec2 size = local_pos / UV;

	// capsuleCollide assumes capsule is aligned with x-axis,
	// so if this is not the case we need to first flip the size and pixel location.

	vec2 rotated_size = vec2(max(size.x, size.y), min(size.x, size.y));

	float step_size_x_y = step(size.x, size.y);

	vec2 rotated_point = vec2(
		step_size_x_y * local_pos.y + (1.f - step_size_x_y) * local_pos.x,
		step_size_x_y * local_pos.x + (1.f - step_size_x_y) * local_pos.y
	);

	// calculate capsule dimensions

	float rad = rotated_size.y / 2.f;
	float rect_width = rotated_size.x - rad * 2.f;
	
	// calculate alpha value for the entire capsule, including border and fill.
	float alpha = capsuleCollide(rad, rect_width, rotated_point, rotated_size);

	// calculate alpha for fill section.
	float fill_alpha = capsuleCollide(max(rad - border_width, 0), rect_width, rotated_point, rotated_size);

	// optionally subtracting fill_alpha from alpha, should result in only the border being drawn.
	COLOR.a = alpha - fill_alpha * (1.f - fill);
}
