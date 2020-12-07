#version 450
#ifdef GL_ES
precision highp float; // If GLSL ES is detected, add required precision setting.
#endif // GL_ES

layout (location = 0) out vec4 rtFragColor;

// Uniforms
uniform sampler2D tex1;
uniform vec2 uResolution;

// Varying
// Per-Fragment: Recieve requirementes for final color
in vec4 vTexcoord;

// gaussian7: perform a 7 wide/tall gaussian blur on a texture
//    tex:			input texture
//    center:		input center of the blur range
//    direction:	direction to perform the blur
vec4 gaussian7(in sampler2D tex, in vec2 center, in vec2 direction) {
	vec2 cp = center + 0.5 * direction;
	vec2 cn = cp - direction;
	vec4 color = (texture(tex, cp)
				+ texture(tex, cn)) * 35.0
        		+ (texture(tex, cp += direction)
				+ texture(tex, cn -= direction)) * 21.0
                + (texture(tex, cp += direction)
				+ texture(tex, cn -= direction)) * 7.0
				+ (texture(tex, cp += direction)
				+ texture(tex, cn -= direction));
	return (color * 0.0078125);
}

void main() {
	vec2 ps = 1.0 / uResolution;	// Inverse of the channel resolution
    vec2 uv = gl_FragCoord.xy * ps;	// Screensize relative to texture size
    vec2 dirHor = vec2(ps.x, 0.0);	// Direction to perform the Gaussian Blur
    rtFragColor = gaussian7(tex1, uv, dirHor);	// Does the horizontal blur
}