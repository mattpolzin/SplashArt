//
//  SplashArtOpenGLView.h
//  SplashArt
//
//  Created by Mathew Polzin on 2/8/13.
//  Copyright (c) 2013 Mathew Polzin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <QuartzCore/QuartzCore.h>

@interface SplashArtOpenGLView : UIView
{
	CAEAGLLayer* myEAGLLayer;
	
	EAGLContext* openGLContext;
	
	GLint glWidth;
	GLint glHeight;
	
	GLuint framebuffer;
	GLuint colorRenderbuffer;
	GLuint depthRenderbuffer;
	
	CADisplayLink* displayLink;
}

@end
