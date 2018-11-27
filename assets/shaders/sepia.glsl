// Simple sepia shader for LÖVE
// License: CC0
// Version: 1.0
// Author:  Landon Manning
// Email:   LManning17@gmail.com

const float u_opacity = 1.0;

const vec3 SEPIA = vec3(1.2, 1.0, 0.8);

vec4 effect(vec4 color, sampler2D texture, vec2 texCoords, vec2 screenCoords) {
	vec4 texColor = texture2D(texture, texCoords);

	// NTSC weights
	float grey = dot(texColor.rgb, vec3(0.299, 0.587, 0.114));

	vec3 sepia = vec3(grey);

	sepia *= SEPIA;

	texColor.rgb = mix(
		texColor.rgb,
		sepia,
		u_opacity
	);

	return texColor * color;
}
