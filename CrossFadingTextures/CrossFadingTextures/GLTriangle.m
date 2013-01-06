//
//  GLTriangle.m
//  TimesAtlasApp
//
//  Created by Adam Swinden on 11/05/2012.
//  Copyright (c) 2012 The OTHER Media. All rights reserved.
//


#import "GLTriangle.h"


const int GLTriangleFloatCount = GLTriangleStride * 3;


#pragma mark - GLTriangle Method implementation

void GLTriangleSetVertex(GLTriangle *t, GLKVector3 v1, GLKVector3 v2, GLKVector3 v3 ) {
    (*t).vertex[0] = v1;
    (*t).vertex[1] = v2;
    (*t).vertex[2] = v3;
}


void GLTriangleSetNormal(GLTriangle *t, GLKVector3 v1, GLKVector3 v2, GLKVector3 v3 ) {
    (*t).normal[0] = v1;
    (*t).normal[1] = v2;
    (*t).normal[2] = v3;
}

void GLTriangleSetTextureCoords(GLTriangle *t, GLKVector2 t1, GLKVector2 t2, GLKVector2 t3 ) {
    (*t).textureCoords[0] = t1;
    (*t).textureCoords[1] = t2;
    (*t).textureCoords[2] = t3;
}

GLTriangle GLTriangleMake( GLKVector3 v1, GLKVector3 v2, GLKVector3 v3 ) {
    GLTriangle t;
    t.vertex[0] = v1;
    t.vertex[1] = v2;
    t.vertex[2] = v3;
    return t;
}

void GLTriangleArrayPrint(GLTriangle *t, GLfloat *array, int offset) {
    
    for (int v = 0; v < 3; v++) {
        array[offset     + v * GLTriangleStride] = (*t).vertex[v].x;
        array[offset + 1 + v * GLTriangleStride] = (*t).vertex[v].y;
        array[offset + 2 + v * GLTriangleStride] = (*t).vertex[v].z;
        
        array[offset + 3 + v * GLTriangleStride] = (*t).normal[v].x;
        array[offset + 4 + v * GLTriangleStride] = (*t).normal[v].y;
        array[offset + 5 + v * GLTriangleStride] = (*t).normal[v].z;
        
        array[offset + 6 + v * GLTriangleStride] = (*t).textureCoords[v].x;
        array[offset + 7 + v * GLTriangleStride] = (*t).textureCoords[v].y;   
    }
}
