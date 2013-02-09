//
//  SplashArtViewController.h
//  SplashArt
//
//  Created by Mathew Polzin on 2/4/13.
//  Copyright (c) 2013 Mathew Polzin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplashArtColorSelector.h"
#import "SplashArtPaletteSizeSelector.h"
#import <OpenGLES/EAGL.h>
#import "SplashArtOpenGLView.h"

#define OPENGL_RENDER 0

typedef enum {
	PM_FLIP,
	PM_FLOP,
	PM_HOP
} PRIMARY_MODE;

@interface SplashArtViewController : UIViewController
{
	CGSize cellSize;
	
	NSMutableArray* randomColors;
	
	PRIMARY_MODE primaryMode;
	UIButton* primaryModeButton;
	
	CGFloat cutoff;
	UISlider* cutoffSlider;
	
	SplashArtPaletteSizeSelector* colorPalletSizeSlider;
	
	SplashArtColorSelector* colorSelector;
	
	// use this to space touch events out a bit
	NSTimeInterval lastTouchTaken;
	
	UIPopoverController* popoverController;
	
#if OPENGL_RENDER
	SplashArtOpenGLView* openGLView;
#else
	NSMutableArray* splashArtViews;
#endif
}

@end
