#version 450

layout (location = 0) in vec4 aPosition;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec4 aTexcoord;

// Transform Uniforms
uniform sampler2D tex6;
uniform mat4 uModelMat;
uniform mat4 uViewMat;
uniform mat4 uProjMat;
uniform mat4 uViewProjMat;

// Varying
// Per-Fragment: individual components
out vec4 vNormal;
out vec4 vPosition;
out vec4 vTexcoord;
out vec4 vPos_camera;

void main() {
	// Texcoord Pipeline
    mat4 atlasMap = mat4(0.5, 0.0, 0.0, 0.0,
    					 0.0, 0.5, 0.0, 0.0,
    					 0.0, 0.0, 0.5, 0.0,
    					 0.0, 0.0, 0.0, 0.5);
    vec4 uv_atlas = atlasMap * aTexcoord;
    vTexcoord = uv_atlas;

	// Final Position Pipeline
	vPosition = aPosition;
	mat4 modelViewMat = uViewMat * uModelMat;
	vec4 pos_camera = modelViewMat * aPosition;
	vec4 pos_clip = uProjMat * pos_camera;
	vPos_camera = pos_camera;
	// Required to set this value
	vec4 texture6 = texture(tex6, vTexcoord.xy);
    gl_Position = vec4(pos_clip.x*texture6.x, pos_clip.y*texture6.x, pos_clip.z*texture6.x, pos_clip.w);
    
    // Normal Pipeline
    mat3 normalMatrix = transpose(inverse(mat3(modelViewMat)));
    vec3 norm_camera = normalMatrix * aNormal;
    // Per-Fragment
    vNormal = vec4(norm_camera, 0.0);
}