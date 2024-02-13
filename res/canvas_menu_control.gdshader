shader_type canvas_item;

void fragment()
{
	vec2 cc = UV - vec2(0.5, 0.5);
	
	if((cc.x * cc.x + cc.y * cc.y) > 0.25f)
		COLOR = vec4(1, 1, 1, 1);
}
