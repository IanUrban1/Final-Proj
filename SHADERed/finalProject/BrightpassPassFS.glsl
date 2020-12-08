#version 450
#ifdef GL_ES
precision highp float; // If GLSL ES is detected, add required precision setting.
#endif // GL_ES

layout (location = 0) out vec4 rtFragColor;

// Uniforms
uniform sampler2D tex0;

// Varying
// Per-Fragment: Recieve requirementes for final color
in vec4 vTexcoord;

// relativeLuminance: calculate the luminance of a pixel
//    c: input pixel
float relativeLuminance (in vec3 c) {
	const vec3 w = vec3(0.2126, 0.7152, 0.0722);
	return dot(w, c);
}

// falloff: perform a falloff operation on a luminence value
//    lum: input luminence
float falloff (in float lum) {
	return lum * lum * (3.0 - 2.0 * lum);
}

void main() {
	vec4 texture0 = texture(tex0, vTexcoord.xy);
	rtFragColor = texture0;
	float rl = relativeLuminance(rtFragColor.xyz);	// Gets the relative luminence of the pixel
    rtFragColor *= falloff(rl * rl);	// Performs the lightpass filter
}