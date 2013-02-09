//
//  SplashArtPaletteSizeSelector.m
//  SplashArt
//
//  Created by Mathew Polzin on 2/8/13.
//  Copyright (c) 2013 Mathew Polzin. All rights reserved.
//

#import "SplashArtPaletteSizeSelector.h"
#import "SplashArtColorSelector.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_COLOR_PLATE_WIDTH 44
#define DEFAULT_COLOR_PLATE_HEIGHT 22
#define DEFAULT_COLOR_PLATE_MARGIN 5

@implementation SplashArtPaletteSizeSelector

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		
		CGRect sliderFrame = self.bounds;
		
		if (sliderFrame.size.height > 44) {
			sliderFrame.origin.y += (sliderFrame.size.height - 44) / 2.0;
			sliderFrame.size.height = 44;
		}
		sliderFrame.origin.x += DEFAULT_COLOR_PLATE_WIDTH;
		sliderFrame.size.width -= DEFAULT_COLOR_PLATE_WIDTH*2;
		
        paletteSizeSlider = [[UISlider alloc] initWithFrame:sliderFrame];
		
		[self addSubview:paletteSizeSlider];
    }
    return self;
}

- (void)setMinimumValue:(CGFloat)minimumValue
{
	[paletteSizeSlider setMinimumValue:minimumValue];
}

- (CGFloat)minimumValue
{
	return paletteSizeSlider.minimumValue;
}

- (void)setMaximumValue:(CGFloat)maximumValue
{
	[paletteSizeSlider setMaximumValue:maximumValue];
}

- (CGFloat)maximumValue
{
	return paletteSizeSlider.maximumValue;
}

- (void)setValue:(CGFloat)value
{
	[paletteSizeSlider setValue:value];
}

- (CGFloat)value
{
	return paletteSizeSlider.value;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
	[paletteSizeSlider addTarget:target action:action forControlEvents:controlEvents];
}

- (void)setColors:(NSUInteger)num fromArray:(NSArray *)colors
{
	CGFloat plateWidth = (self.bounds.size.width - (paletteSizeSlider.frame.size.width + DEFAULT_COLOR_PLATE_MARGIN)) / 2.0;
	
	if (lowerColorPlate) {
		[lowerColorPlate removeFromSuperview];
		[lowerColorPlate release], lowerColorPlate = nil;
	}
	if (upperColorPlate) {
		[upperColorPlate removeFromSuperview];
		[upperColorPlate release], upperColorPlate = nil;
	}
	
	lowerColorPlate = [SplashArtColorSelector generateColorPlateWithColors:self.minimumValue fromArray:colors];
	lowerColorPlate.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
	upperColorPlate = [SplashArtColorSelector generateColorPlateWithColors:num fromArray:colors];
	upperColorPlate.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
	
//	if (borderWidth > 0) {
	lowerColorPlate.layer.borderWidth = 2;//borderWidth;
	lowerColorPlate.layer.borderColor = [UIColor blackColor].CGColor;
	upperColorPlate.layer.borderWidth = 2;//borderWidth;
	upperColorPlate.layer.borderColor = [UIColor blackColor].CGColor;
//	}
//	if (roundCorners) {
	lowerColorPlate.layer.cornerRadius = 4;
	lowerColorPlate.clipsToBounds = YES;
	upperColorPlate.layer.cornerRadius = 4;
	upperColorPlate.clipsToBounds = YES;
//	}
	
	lowerColorPlate.frame = CGRectMake(0, (self.bounds.size.height - DEFAULT_COLOR_PLATE_HEIGHT) / 2.0, plateWidth, DEFAULT_COLOR_PLATE_HEIGHT);
	upperColorPlate.frame = CGRectMake(self.bounds.size.width - plateWidth, (self.bounds.size.height - DEFAULT_COLOR_PLATE_HEIGHT) / 2.0, plateWidth, DEFAULT_COLOR_PLATE_HEIGHT);
	
	[self addSubview:lowerColorPlate];
	[self addSubview:upperColorPlate];
}

- (void)dealloc
{
	[paletteSizeSlider release], paletteSizeSlider = nil;
	[lowerColorPlate release], lowerColorPlate = nil;
	[upperColorPlate release], upperColorPlate = nil;
	
	[super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
