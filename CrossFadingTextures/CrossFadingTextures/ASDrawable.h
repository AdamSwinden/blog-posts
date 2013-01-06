//
//  ASDrawable.h
//  CrossFadingTextures
//
//  Created by Adam Swinden on 05/01/2013.
//  Copyright (c) 2013 Adam Swinden. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GLKit/GLKMath.h>


@interface ASDrawable : NSObject


@property (nonatomic) CGFloat rotation;
@property (nonatomic) UIImage *texture;
@property (nonatomic) GLKMatrix4 projectionMatrix;


- (void)setTexture:(UIImage *)texture animationDuration:(NSTimeInterval)duration;


#pragma mark - Setup
- (BOOL)setUp;
- (void)setUpVertexBuffer;


#pragma mark - Update and draw
- (void)update;
- (void)draw;


@end
