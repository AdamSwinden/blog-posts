//
//  ASDrawable.m
//  CrossFadingTextures
//
//  Created by Adam Swinden on 05/01/2013.
//  Copyright (c) 2013 Adam Swinden. All rights reserved.
//

#import "ASDrawable.h"

#import "GLTriangle.h"


// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
	ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};


// Attribute names
#define ATTRIB_VERTEX_NAME		@"position"
#define ATTRIB_NORMAL_NAME		@"normal"
#define ATTRIB_TEXCOORD_NAME	@"texCoord"


// Uniform index.
enum {
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
	UNIFORM_SAMPLER,
	UNIFORM_SAMPLER_TWO,
	UNIFORM_TEXALPHA,
    NUM_UNIFORMS
};


// Uniform names
#define UNIFORM_NORMAL_MATRIX_NAME				@"normalMatrix"
#define UNIFORM_MODELVIEWPROJECTION_MATRIX_NAME	@"modelViewProjectionMatrix"
#define UNIFORM_SAMPLER_NAME					@"texture"
#define UNIFORM_SAMPLER_TWO_NAME				@"textureTwo"
#define UNIFORM_TEXALPHA_NAME					@"texAlpha"


@interface ASDrawable () {
	
	GLint uniforms[NUM_UNIFORMS];
	GLuint vertexBuffer;
	GLuint shaderProgram;
	GLKMatrix4 baseModelViewMatrix;
	GLKMatrix4 modelViewProjectionMatrix;
	GLKMatrix3 normalMatrix;

	GLuint currentTexture;
	GLuint animatingTexture;
	
	BOOL animating;
	float animationProgress;
	NSTimeInterval animationDuration;
	
	NSTimeInterval timestamp;
}


@end


@implementation ASDrawable


#pragma mark - Init

- (id)init {

    self = [super init];
    if (self) {
        
		baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
		_projectionMatrix = GLKMatrix4Identity;
		modelViewProjectionMatrix = GLKMatrix4Identity;
		normalMatrix = GLKMatrix3Identity;
		
		animationProgress = 1.0f;
    }
    return self;
}


#pragma mark - Setup/teardown

- (BOOL)setUp {

	NSArray *attributesArray = [NSArray arrayWithObjects:	ATTRIB_VERTEX_NAME,
															ATTRIB_NORMAL_NAME,
															ATTRIB_TEXCOORD_NAME, nil];
	
	NSArray *uniformsArray = [NSArray arrayWithObjects:	UNIFORM_MODELVIEWPROJECTION_MATRIX_NAME,
														UNIFORM_NORMAL_MATRIX_NAME,
														UNIFORM_SAMPLER_NAME,
														UNIFORM_SAMPLER_TWO_NAME,
														UNIFORM_TEXALPHA_NAME, nil];
	
	return [self loadShader:@"Shader" attributes:attributesArray uniforms:uniformsArray];
}


- (void)setUpVertexBuffer {

	GLfloat *positions = malloc(sizeof(GLfloat) * 48);
	
	// First Triangle
	GLTriangle firstTriangle = GLTriangleMake(GLKVector3Make(-1.0f, 1.0f, 0.0f), GLKVector3Make(-1.0f, -1.0f, 0.0f), GLKVector3Make(1.0f, 1.0f, 0.0f));
	GLTriangleSetNormal(&firstTriangle, GLKVector3Make(0.0f, 0.0f, 1.0f), GLKVector3Make(0.0f, 0.0f, 1.0f), GLKVector3Make(0.0f, 0.0f, 1.0f));
	GLTriangleSetTextureCoords(&firstTriangle, GLKVector2Make(0.0f, 0.0f), GLKVector2Make(0.0f, 1.0f), GLKVector2Make(1.0f, 0.0f));
	GLTriangleArrayPrint(&firstTriangle, positions, 0);
	
	// Second Triangle
	GLTriangle secondTriangle = GLTriangleMake(GLKVector3Make(1.0f, 1.0f, 0.0f), GLKVector3Make(-1.0f, -1.0f, 0.0f), GLKVector3Make(1.0f, -1.0f, 0.0f));
	GLTriangleSetNormal(&secondTriangle, GLKVector3Make(0.0f, 0.0f, 1.0f), GLKVector3Make(0.0f, 0.0f, 1.0f), GLKVector3Make(0.0f, 0.0f, 1.0f));
	GLTriangleSetTextureCoords(&secondTriangle, GLKVector2Make(1.0f, 0.0f), GLKVector2Make(0.0f, 1.0f), GLKVector2Make(1.0f, 1.0f));
	GLTriangleArrayPrint(&secondTriangle, positions, GLTriangleFloatCount);
	
	GLuint buffer;
	glGenBuffers(1, &buffer);
	glBindBuffer(GL_ARRAY_BUFFER, buffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(GL_FLOAT) * 48, positions, GL_STATIC_DRAW);
	
	vertexBuffer = buffer;
	free(positions);
}


- (void)teardown {
	
	glDeleteBuffers(1, &vertexBuffer);
	vertexBuffer = 0;
	
	glDeleteProgram(shaderProgram);
	shaderProgram = 0;
}


#pragma mark - Texture

- (void)setTexture:(UIImage *)texture {
	
	[self setTexture:texture animationDuration:0.0];
}


- (void)setTexture:(UIImage *)texture animationDuration:(NSTimeInterval)duration {
	
	if (animatingTexture != 0) {
		
		glDeleteTextures(1, &animatingTexture);
		animatingTexture = 0;
	}
	
	animatingTexture = [GLKTextureLoader textureWithCGImage:texture.CGImage options:nil error:nil].name;
	animating = YES;
	animationProgress = 0.0f;
	animationDuration = duration;
}


#pragma mark - Update/draw

- (void)update {
	
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSTimeInterval timeSinceLastUpdate = now - timestamp;

	GLKMatrix4 modelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, GLKMathDegreesToRadians(_rotation), 0.0f, 0.0f, 1.0f);
	normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
	modelViewProjectionMatrix = GLKMatrix4Multiply(_projectionMatrix, modelViewMatrix);
	
	if (animating) {

		animationProgress += timeSinceLastUpdate / animationDuration;
		
		if (animationProgress > 1.0f) {
			
			animationProgress = 0.0;
			animating = NO;

			if (animatingTexture != 0) {

				glDeleteTextures(1, &currentTexture);
				currentTexture = animatingTexture;
				animatingTexture = 0;
			}
		}
	}
	
	timestamp = now;
}


- (void)draw {
	
	glEnable(GL_DEPTH_TEST);
	glDepthMask(GL_TRUE);
	glDisable(GL_BLEND);
	
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	
	GLuint offset = 0;
	
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glEnableVertexAttribArray(ATTRIB_NORMAL);
	glEnableVertexAttribArray(ATTRIB_TEXCOORD);
	
    glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * GLTriangleStride, (const void*)offset);
	offset += 3 * sizeof(GLfloat);
    glVertexAttribPointer(ATTRIB_NORMAL, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * GLTriangleStride, (const void*)offset);
	offset += 3 * sizeof(GLfloat);
	glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * GLTriangleStride, (const void*)offset);
	
    glUseProgram(shaderProgram);
	
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
	glUniform1i(uniforms[UNIFORM_SAMPLER], 0);
	glUniform1i(uniforms[UNIFORM_SAMPLER_TWO], 1);
	if (animating) glUniform1f(uniforms[UNIFORM_TEXALPHA], animationProgress);
	else glUniform1f(uniforms[UNIFORM_TEXALPHA], 0.0f);
	
	glActiveTexture(GL_TEXTURE0); // Sampler 1
	glBindTexture(GL_TEXTURE_2D, currentTexture);
	
	if (animatingTexture != 0) {

		glActiveTexture(GL_TEXTURE1); // Sampler 2
		glBindTexture(GL_TEXTURE_2D, animatingTexture);
	}
	
	glDrawArrays(GL_TRIANGLES, 0, 6);
}


#pragma mark - Shaders

- (BOOL)loadShader:(NSString *)name attributes:(NSArray *)attributesArray uniforms:(NSArray *)uniformsArray {
	
	shaderProgram = glCreateProgram();
	
	GLuint vertexShader;
	GLuint fragmentShader;
	
	// Create and compile vertex shader
	NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:name ofType:@"vsh"];
	if (![self compileShader:&vertexShader type:GL_VERTEX_SHADER file:vertexShaderPath]) {
		
		NSLog(@"Failed to compile vertex shader: %@", name);
		shaderProgram = 0;
		return NO;
	}
	
	// Create and compile fragment shader
	NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:name ofType:@"fsh"];
	if (![self compileShader:&fragmentShader type:GL_FRAGMENT_SHADER file:fragmentShaderPath]) {
		
		NSLog(@"Failed to compile fragment shader: %@", name);
		shaderProgram = 0;
		return NO;
	}
	
	// Attach shaders
	glAttachShader(shaderProgram, vertexShader);
	glAttachShader(shaderProgram, fragmentShader);
	
	// Bind attributes
	if ([attributesArray containsObject:ATTRIB_VERTEX_NAME]) glBindAttribLocation(shaderProgram, ATTRIB_VERTEX, [ATTRIB_VERTEX_NAME cStringUsingEncoding:NSUTF8StringEncoding]);
	if ([attributesArray containsObject:ATTRIB_NORMAL_NAME]) glBindAttribLocation(shaderProgram, ATTRIB_NORMAL, [ATTRIB_NORMAL_NAME cStringUsingEncoding:NSUTF8StringEncoding]);
	if ([attributesArray containsObject:ATTRIB_TEXCOORD_NAME]) glBindAttribLocation(shaderProgram, ATTRIB_TEXCOORD, [ATTRIB_TEXCOORD_NAME cStringUsingEncoding:NSUTF8StringEncoding]);
	
	// Link program
	if (![self linkProgram:shaderProgram]) {
		
		NSLog(@"Failed to link program: %@", name);
		if (vertexShader) {
			glDeleteShader(vertexShader);
			vertexShader = 0;
		}
		if (fragmentShader) {
			glDeleteShader(fragmentShader);
			fragmentShader = 0;
		}
		if (shaderProgram != 0) {
			glDeleteProgram(shaderProgram);
			shaderProgram = 0;
		}
		
		return NO;
	}
	
	// Get uniform locations
	if ([uniformsArray containsObject:UNIFORM_MODELVIEWPROJECTION_MATRIX_NAME]) uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(shaderProgram, [UNIFORM_MODELVIEWPROJECTION_MATRIX_NAME cStringUsingEncoding:NSUTF8StringEncoding]);
	if ([uniformsArray containsObject:UNIFORM_NORMAL_MATRIX_NAME]) uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(shaderProgram, [UNIFORM_NORMAL_MATRIX_NAME cStringUsingEncoding:NSUTF8StringEncoding]);
	if ([uniformsArray containsObject:UNIFORM_SAMPLER_NAME]) uniforms[UNIFORM_SAMPLER] = glGetUniformLocation(shaderProgram, [UNIFORM_SAMPLER_NAME cStringUsingEncoding:NSUTF8StringEncoding]);
	if ([uniformsArray containsObject:UNIFORM_TEXALPHA_NAME]) uniforms[UNIFORM_TEXALPHA] = glGetUniformLocation(shaderProgram, [UNIFORM_TEXALPHA_NAME cStringUsingEncoding:NSUTF8StringEncoding]);
	if ([uniformsArray containsObject:UNIFORM_SAMPLER_TWO_NAME]) uniforms[UNIFORM_SAMPLER_TWO] = glGetUniformLocation(shaderProgram, [UNIFORM_SAMPLER_TWO_NAME cStringUsingEncoding:NSUTF8StringEncoding]);
	
	// Release shaders
	if (vertexShader) {
		glDetachShader(shaderProgram, vertexShader);
		glDeleteShader(vertexShader);
	}
	if (fragmentShader) {
		glDetachShader(shaderProgram, fragmentShader);
		glDeleteShader(fragmentShader);
	}
	
	return YES;
}


- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
	
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader: %@", file);
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}


- (BOOL)linkProgram:(GLuint)prog {
	
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}


#pragma mark - Memory management

- (void)dealloc {
	
	[self teardown];
}

@end
