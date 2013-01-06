//
//  Shader.vsh
//  CrossFadingTextures
//
//  Created by Adam Swinden on 05/01/2013.
//  Copyright (c) 2013 Adam Swinden. All rights reserved.
//


attribute vec4 position;
attribute vec3 normal;
attribute vec2 texCoord;

varying lowp vec4 colorVarying;
varying vec2 texCoordVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main() {
	
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(1.0, 1.0, 1.0);
    vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);
	vec4 ambientColor = vec4(0.1, 0.1, 0.1, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
	
    colorVarying = (diffuseColor * nDotVP) + ambientColor;
	texCoordVarying = texCoord;
    
    gl_Position = modelViewProjectionMatrix * position;
}
