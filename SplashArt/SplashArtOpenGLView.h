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

@protocol SplashArtOpenGLViewDataSource <NSObject>

@required
// get the width and height (number of columns and number of rows) on the
// drawing board.
- (CGSize)getNumColumnsAndRows;

// get the color for the given row and column
- (UIColor*)colorForCellAtRow:(NSUInteger)row andColumn:(NSUInteger)column;

@end

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
	
	id <SplashArtOpenGLViewDataSource> datasource;
}

@property (nonatomic, assign) id <SplashArtOpenGLViewDataSource> datasource;

@end
