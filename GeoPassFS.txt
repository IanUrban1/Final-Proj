#version 450
#ifdef GL_ES
precision highp float; // If GLSL ES is detected, add required precision setting.
#endif // GL_ES

layout (location = 0) out vec4 rtFragColor;

// Varying
// Per-Vertex: Recieve final color
//in vec4 vColor;
// Per-Fragment: Recieve requirementes for final color
in vec4 vNormal;
in vec4 vTexcoord;
in vec4 vPosition;
in vec4 vPos_camera;

// Uniforms
uniform sampler2D tex5;
uniform mat4 uViewMat;
uniform vec2 mousePosition;

// A struct containing variables for a point light
struct sPointLight {
    vec4 center;
    vec3 color;
    float intensity;
};

// Initializes a point light struct variables with the data passed into the function
//		pl: the point light to be initialized
//		center: the position of the center of the light
//		color: the color of the light
//		intensity: the intensity of the light
void initPointLight(out sPointLight pl, in vec3 center, in vec3 color, in float intensity) {
    pl.center = vec4(center, 1.0);
    pl.color = color;
    pl.intensity = intensity;
}

// Returns the dot product of a 2D vector
// Original code by Daniel Buckstein
float lenSq(vec2 x) {
    return dot(x, x);
}

// Returns the dot product of a 3D vector
// Original code by Daniel Buckstein
// Modified by Michael Kashian
float lenSq(vec3 x) {
    return dot(x, x);
}

// Returns the input variable raised to the 256 power
float pow256(in float specularCoefficient) {
    float sc = specularCoefficient;
    sc *= sc;
    sc *= sc;
    sc *= sc;
    sc *= sc;
    sc *= sc;
    sc *= sc;
    sc *= sc;
    sc *= sc;
    return sc;
}

// Return distance from the mouse to the point in range of [0,1]
// with 1 being closest
float distToPoint(in vec2 p) {
	return max(1.0 - sqrt(lenSq(p - mousePosition)), 0.0);
}

void main()
{
    // Per-Fragment
    vec4 N = normalize(vNormal);
    
    sPointLight pointLights[6];
    initPointLight(pointLights[0], vec3(2.0, 0.0, 0.0), vec3(1.0, 0.0, 0.0), 10.0 * distToPoint(vec2(0.0, 1.0)));
    initPointLight(pointLights[1], vec3(-2.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), 10.0 * distToPoint(vec2(0.5, 1.0)));
    initPointLight(pointLights[2], vec3(0.0, 2.0, 0.0), vec3(0.0, 0.0, 1.0), 10.0 * distToPoint(vec2(1.0, 1.0)));
    initPointLight(pointLights[3], vec3(0.0, -2.0, 0.0), vec3(1.0, 1.0, 0.0), 10.0 * distToPoint(vec2(0.0, 0.0)));
    initPointLight(pointLights[4], vec3(0.0, 0.0, 2.0), vec3(1.0, 0.0, 1.0), 10.0 * distToPoint(vec2(0.5, 0.0)));
    initPointLight(pointLights[5], vec3(0.0, 0.0, -2.0), vec3(0.0, 1.0, 1.0), 10.0 * distToPoint(vec2(1.0, 0.0)));
    
    // Geometry variables
    float diffuseIntensity, specularIntensity;
    vec3 lightingInstensitySum;
    vec3 specularColor = vec3(1.0, 1.0, 1.0);
    
    for (int i = pointLights.length() - 1; i >= 0; --i) {
        // Lambertian Reflectance
	    // Diffuse Coefficient
	    vec3 unitSurfaceNormal = N.xyz;
	    vec4 light_camera = uViewMat * pointLights[i].center;
	    vec3 LightVector = light_camera.xyz - vPos_camera.xyz;
	    float d = sqrt(lenSq(LightVector));
		vec3 unitLightVector = LightVector / d;
	    float diffuseCoefficient = max(0.0, dot(unitSurfaceNormal, unitLightVector));
	    
	    // Attenuated Intensity
	    float inverseIntensity = 1.0 / pointLights[i].intensity;
	    float attenuatedIntensity = 1.0 / (1.0 + (d * inverseIntensity) + ((d * d) * (inverseIntensity * inverseIntensity)));
	    
	    // Diffuse Intensity
	    diffuseIntensity = diffuseCoefficient * attenuatedIntensity;
	    
	    // Blinn-Phong Reflectance
	    // Specular Coefficient
	    vec3 viewVector = normalize(-vPos_camera.xyz);
	    vec3 halfwayVector = normalize(unitLightVector + viewVector);
	    float specularCoefficient = max(0.0, dot(unitSurfaceNormal, halfwayVector));
		
	    // Specular Intensity
	    specularIntensity = pow256(specularCoefficient);
	    vec4 texture5 = vec4(texture(tex5, vTexcoord.xy).x);
	    lightingInstensitySum += ((diffuseIntensity * texture5.xyz) + (specularIntensity * specularColor)) * pointLights[i].color;
	}
	
	float globalAmbientIntensity = 0.05;
	vec3 globalAmbientColor = vec3(1.0, 1.0, 1.0);
    rtFragColor = vec4((globalAmbientIntensity * globalAmbientColor) + lightingInstensitySum, 1.0);
}