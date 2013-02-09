//
//  SplashArtOpenGLView.m
//  SplashArt
//
//  Created by Mathew Polzin on 2/8/13.
//  Copyright (c) 2013 Mathew Polzin. All rights reserved.
//

#import "SplashArtOpenGLView.h"

@interface SplashArtOpenGLView (PrivateMethods)

- (void)allocateOpenGLBuffers;

- (void)drawOpenGLFrame;

- (void)registerDisplayLink;
- (void)unregisterDisplayLink;

@end

@implementation SplashArtOpenGLView (PrivateMethods)

- (void)allocateOpenGLBuffers
{
	glGenFramebuffers(1, &framebuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
	
	glGenRenderbuffers(1, &colorRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	[openGLContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:myEAGLLayer];
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
	
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &glWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &glHeight);
	
	glGenRenderbuffers(1, &depthRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, glWidth, glHeight);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
	
	GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
	if(status != GL_FRAMEBUFFER_COMPLETE) {
		NSLog(@"failed to make complete framebuffer object %x", status);
	}
}

- (void)drawOpenGLFrame
{
	glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
	glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
	
	
}

- (void)registerDisplayLink
{
	[displayLink release], displayLink = nil;
	displayLink = [[self.window.screen displayLinkWithTarget:self selector:@selector(drawFrame)] retain];
	displayLink.frameInterval = 3; // play around with this (how many frames to skip between redraws)
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)unregisterDisplayLink
{
	[displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

@end

@implementation SplashArtOpenGLView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
#warning this will mean twice as many pixels on a retina display... worth it?
		self.contentScaleFactor = [[UIScreen mainScreen] scale];
		
		myEAGLLayer = (CAEAGLLayer*)self.layer;
		myEAGLLayer.opaque = YES;
		
		openGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		[EAGLContext setCurrentContext: openGLContext];
		
		[self allocateOpenGLBuffers];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
	[self allocateOpenGLBuffers];
}

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

- (void)dealloc
{
	[displayLink release], displayLink = nil;
	[openGLContext release], openGLContext = nil;
	
	[super dealloc];
}
@end
