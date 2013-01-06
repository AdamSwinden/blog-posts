//
//  ASViewController.m
//  CrossFadingTextures
//
//  Created by Adam Swinden on 05/01/2013.
//  Copyright (c) 2013 Adam Swinden. All rights reserved.
//

#import "ASViewController.h"

#import "ASDrawable.h"


@interface ASViewController () {

	ASDrawable *drawable;
	BOOL textureSwitched;
}

@end


@implementation ASViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

		self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		if (!self.context) NSLog(@"Failed to create ES context");
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];

	GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
	
	self.preferredFramesPerSecond = 60;
	
	UIButton *switchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[switchButton setTitle:@"Fade" forState:UIControlStateNormal];
	[switchButton sizeToFit];
	[switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:switchButton];
	
	[self setupGL];
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	[self switchButtonPressed:nil];
}


#pragma mark - Button

- (void)switchButtonPressed:(id)sender {
	
	UIImage *texture = nil;
	
	if (textureSwitched) texture = [UIImage imageNamed:@"texture1.png"];
	else texture = [UIImage imageNamed:@"texture2.png"];
	
	[drawable setTexture:texture animationDuration:1.0];
	
	textureSwitched = !textureSwitched;
}


#pragma mark - OpenGL setup/teardown

- (void)setupGL {
	
	[EAGLContext setCurrentContext:self.context];
	glActiveTexture(GL_TEXTURE0);
	
	drawable = [[ASDrawable alloc] init];
	if (![drawable setUp]) drawable = nil;
	[drawable setUpVertexBuffer];
}


- (void)tearDownGL {
	
	drawable = nil;
}


#pragma mark - Update/draw

- (void)update {
	
	float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
	GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f), aspect, 0.1f, 200.0f);

	drawable.rotation -= 90 * self.timeSinceLastUpdate;
	drawable.projectionMatrix = projectionMatrix;
	[drawable update];
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {

	glDepthMask(GL_TRUE);
	glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	[drawable draw];
}


#pragma mark - Memory management

- (void)dealloc {
	
	[self tearDownGL];
}


@end
