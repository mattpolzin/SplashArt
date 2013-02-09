//
//  SplashArtPaletteSizeSelector.h
//  SplashArt
//
//  Created by Mathew Polzin on 2/8/13.
//  Copyright (c) 2013 Mathew Polzin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashArtPaletteSizeSelector : UIView
{
	UISlider* paletteSizeSlider;
	
	UIView* lowerColorPlate;
	UIView* upperColorPlate;
}

@property (nonatomic, assign) CGFloat minimumValue;
@property (nonatomic, assign) CGFloat maximumValue;
@property (nonatomic, assign) CGFloat value;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

- (void)setColors:(NSUInteger)num fromArray:(NSArray *)colors;

@end
