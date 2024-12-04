shader_type canvas_item;

// Pulse var inits
uniform float speed = 2.0;
uniform float amount = 0.4;
const float PIh = 3.14159265359 * 0.5;

// Colour information
uniform vec4 new_colour : source_color; // Target color
uniform float interpolation_speed = 1.0; // Speed of color interpolation
uniform vec4 original_colour = vec4(1.0, 1.0, 1.0, 1.0); // Original color (white)

// Variable to track interpolation progress (must be managed externally in the script)
uniform float interpolation_progress = 0.0; // 0.0 to 1.0

void vertex() {
    VERTEX += VERTEX * abs(sin(PIh * TIME * speed)) * amount;
}

void fragment() {
    vec4 current_colour = texture(TEXTURE, UV);

    if (current_colour.a > 0.0) {
        // Interpolate between the original and target colors
        vec4 interpolated_color = mix(original_colour, new_colour, interpolation_progress);

        // Apply the interpolated color
        COLOR = vec4(interpolated_color.rgb, current_colour.a);
	}
}



//shader_type canvas_item;
////render_mode unshaded;
//
//// Pulse var inits
//uniform float speed = 2;
//uniform float amount = 0.4;
//const float PIh = 3.14159265359 * 0.5;
//
//// Colour information
//uniform vec4 new_colour: source_color;
//
//void vertex(){
	//VERTEX += VERTEX * abs(sin(PIh * TIME * speed)) * amount;
	////VERTEX += VERTEX * (sin(PI * TIME * speed)*0.5 + 0.5) * amount; //sine version
//}
//
//void fragment(){
	//vec4 current_colour = texture(TEXTURE, UV);
	//if (current_colour.a > 0.0){
		//COLOR.rgb = new_colour.rgb;
	//}
//}