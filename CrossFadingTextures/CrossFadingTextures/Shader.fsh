//
//  Shader.fsh
//  CrossFadingTextures
//
//  Created by Adam Swinden on 05/01/2013.
//  Copyright (c) 2013 Adam Swinden. All rights reserved.
//


varying lowp vec4 colorVarying;
varying lowp vec2 texCoordVarying;

uniform sampler2D texture;
uniform sampler2D textureTwo;

uniform lowp float texAlpha;

void main() {
	
	mediump vec4 texColor = texture2D(texture, texCoordVarying);
	mediump vec4 texTwoColor = texture2D(textureTwo, texCoordVarying);
	
	gl_FragColor = ((texColor * (1.0 - texAlpha)) + (texTwoColor * texAlpha)) * colorVarying;
}
