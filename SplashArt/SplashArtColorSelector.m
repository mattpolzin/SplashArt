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
	NSUInteger count = flipView.views.count;
	if (replaceLastView) {
		count--;
	}
	
	UIView* colorPlate = [[self class] generateColorPlateWithColors:count fromArray:flipView.views];
	colorPlate.frame = self.bounds;
	
	if (replaceLastView) {
//		[flipView.views setObject:colorPlate atIndexedSubscript:count];
	} else {
		[flipView addViews:[NSArray arrayWithObject:colorPlate]];
	}
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

// accepts an array of UIColor objects /or/ UIView objects (in which case the
// background color of each view is used).
+ (UIView*) generateColorPlateWithColors:(NSUInteger)colorCount fromArray:(NSArray*)colors
{	
	if (colorCount > colors.count) {
		colorCount = colors.count;
	}
	
	UIView* colorPlate = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
	
	// take the ceiling so that no gaps are produced when the cells
	// are autoscaled (because the cells do not have integer sizes).
	CGFloat width = colorPlate.bounds.size.width / colorCount;
	CGFloat height = colorPlate.bounds.size.height;
	
	for (int ii = 0; ii < colorCount; ii++) {
		id colorObj = [colors objectAtIndex:ii];
		UIView* plateView = [[UIView alloc] initWithFrame:CGRectMake(ii * width, 0, width + (ii < colorCount-1 ? 2 : 0), height)];
		plateView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		if (ii > 0) {
			plateView.autoresizingMask |= UIViewAutoresizingFlexibleLeftMargin;
		}
		if (ii < colorCount-1) {
			plateView.autoresizingMask |= UIViewAutoresizingFlexibleRightMargin;
		}
		plateView.backgroundColor = (UIColor*)([colorObj isKindOfClass:[UIView class]] ? [(UIView*)colorObj backgroundColor] : colorObj);
		
		[colorPlate addSubview:plateView];
		
		[plateView release];
	}
	
	colorPlate.clipsToBounds = YES;
	
	return [colorPlate autorelease];
}

+ (UIView*) generateColorPlateWithColors:(NSArray*)colors;
{
	return [self generateColorPlateWithColors:colors.count fromArray:colors];
}

- (void)dealloc
{
	[flipView release], flipView = nil;
	
	[super dealloc];
}

@end
