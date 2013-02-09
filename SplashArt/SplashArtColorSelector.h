//
//  SplashArtColorSelector.h
//  SplashArt
//
//  Created by Mathew Polzin on 2/5/13.
//  Copyright (c) 2013 Mathew Polzin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplashArtFlipView.h"

@interface SplashArtColorSelector : UIButton
{
	SplashArtFlipView* flipView;
}

// will return nil if there is no color selected.
@property (nonatomic, readonly) UIColor* currentColor;
@property (nonatomic, readonly) NSUInteger colorCount;

- (void)setBackgroundColors:(NSUInteger)num fromArray:(NSArray *)colors;

- (void)setSelectedIndex:(NSUInteger)index;

+ (UIView*) generateColorPlateWithColors:(NSArray*)colors;

+ (UIView*) generateColorPlateWithColors:(NSUInteger)colorCount fromArray:(NSArray*)colors;

@end
