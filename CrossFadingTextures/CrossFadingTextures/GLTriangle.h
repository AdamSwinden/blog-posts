//
//  GLTriangle.h
//  CrossFadingTextures
//
//  Created by Adam Swinden on 05/01/2013.
//  Copyright (c) 2013 Adam Swinden. All rights reserved.
//

#import <GLKit/GLKMath.h>
#import <GLKit/GLKit.h>

#ifndef GLTriangle_h
#define GLTriangle_h

#pragma mark - GLTriangle Struct and Methods

#define GLTriangleStride	8


typedef struct {
    GLKVector3 vertex[3];
    GLKVector3 normal[3];
    GLKVector2 textureCoords[3];
} GLTriangle;


const int GLTriangleFloatCount;


void GLTriangleSetVertex(GLTriangle *t, GLKVector3 v1, GLKVector3 v2, GLKVector3 v3);
void GLTriangleSetNormal(GLTriangle *t, GLKVector3 v1, GLKVector3 v2, GLKVector3 v3);
void GLTriangleSetTextureCoords(GLTriangle *t, GLKVector2 t1, GLKVector2 t2, GLKVector2 t3);
GLTriangle GLTriangleMake( GLKVector3 v1, GLKVector3 v2, GLKVector3 v3 );
void GLTriangleArrayPrint(GLTriangle *t, GLfloat *array, int offset);

#endif