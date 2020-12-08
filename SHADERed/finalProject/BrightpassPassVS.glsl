#version 450

layout (location = 0) in vec4 aPosition;

// Varying
// Per-Fragment: individual components
out vec4 vTexcoord;

void main() {
	// Final Position Pipeline
	// Required to set this value
    gl_Position = aPosition;
    
    // Texcoord Pipeline
    vTexcoord = 0.5 * aPosition + 0.5;
}