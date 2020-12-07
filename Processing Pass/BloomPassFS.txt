#version 450
#ifdef GL_ES
precision highp float; // If GLSL ES is detected, add required precision setting.
#endif // GL_ES

layout (location = 0) out vec4 rtFragColor;

// Uniforms
uniform sampler2D tex3;
uniform sampler2D tex4;
uniform vec2 uResolution;

// Varying
// Per-Fragment: Recieve requirementes for final color
in vec4 vTexcoord;

vec4 screenBlend(vec4 a, vec4 b) {
	return 1.0 - ((1.0 - a) * (1.0 - b));
}

void main() {
	vec4 texture3 = texture(tex3, vTexcoord.xy);
	vec4 texture4 = texture(tex4, vTexcoord.xy);
	rtFragColor = screenBlend(texture3, texture4);
}