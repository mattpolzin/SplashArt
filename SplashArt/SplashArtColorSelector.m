//
//  SplashArtColorSelector.m
//  SplashArt
//
//  Created by Mathew Polzin on 2/5/13.
//  Copyright (c) 2013 Mathew Polzin. All rights reserved.
//

#import "SplashArtColorSelector.h"
#import <QuartzCore/QuartzCore.h>

@interface SplashArtColorSelector (PrivateMethods)

- (void)buttonPushed:(id)sender;

- (void)generateColorPlateWithReplacement:(BOOL)replaceLastView;

@end

@implementation SplashArtColorSelector (PrivateMethods)

- (void)buttonPushed:(id)sender
{	
	// flip the view that shows the current color:
	CGFloat horizontal = roundf((arc4random() % 10) / 10.0);
	[flipView flipWithXRatio:horizontal yRatio:(1 - horizontal) duration:0.3];
}

- (void)generateColorPlateWithReplacement:(BOOL)replaceLastView;
{	
	UIView* colorPlate = [[UIView alloc] initWithFrame:self.bounds];
	
	CGFloat width = self.bounds.size.width / flipView.views.count;
	CGFloat height = self.bounds.size.height;
	
	NSUInteger count = flipView.views.count;
	if (replaceLastView) {
		count--;
	}
	
	for (int ii = 0; ii < flipView.views.count; ii++) {
		UIView* v = [flipView.views objectAtIndex:ii];
		UIView* plateView = [[UIView alloc] initWithFrame:CGRectMake(ii * width, 0, width, height)];
		plateView.backgroundColor = v.backgroundColor;
		
		[colorPlate addSubview:plateView];
		
		[plateView release];
	}
	
	if (replaceLastView) {
//		[flipView.views setObject:colorPlate atIndexedSubscript:count];
	} else {
		[flipView addViews:[NSArray arrayWithObject:colorPlate]];
	}
	
	[colorPlate release];
}

@end

@implementation SplashArtColorSelector

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        flipView = [[SplashArtFlipView alloc] initWithFrame:self.bounds borderWidth:2 roundCorners:YES];
		flipView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		[self generateColorPlateWithReplacement:NO];
		
		flipView.userInteractionEnabled = NO;
		[self addSubview:flipView];
		
		[self addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (UIColor*)currentColor
{
	return (flipView.currentViewIndex == flipView.views.count-1 ? nil : [[flipView currentView] backgroundColor]);
}

- (void)setBackgroundColors:(NSUInteger)num fromArray:(NSArray *)colors
{
	//is the color plate currently selected?
	BOOL plateSelected = (flipView.currentViewIndex == flipView.views.count-1);
	
	// remove the color plate
	[flipView removeLastViews:1 withAnimation:NO];
	
	// change the colors
	[flipView setBackgroundColors:num fromArray:colors];
	
	// generate a new plate
	[self generateColorPlateWithReplacement:NO];
	
	if (plateSelected) {
		[self setSelectedIndex:flipView.views.count-1];
	}
}

- (void)setSelectedIndex:(NSUInteger)index
{
	// flip the view that shows the current color:
	CGFloat horizontal = roundf((arc4random() % 10) / 10);
	[flipView flipToIndex:index withXRatio:horizontal yRatio:(1 - horizontal) duration:0.3 delay:0];
}

- (NSUInteger) colorCount
{
	return flipView.views.count-1;
}


- (void)dealloc
{
	[flipView release], flipView = nil;
	
	[super dealloc];
}

@end
