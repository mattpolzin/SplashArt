//
//  SplashArtFlipView.h
//  SplashArt
//
//  Created by Mathew Polzin on 2/4/13.
//  Copyright (c) 2013 Mathew Polzin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashArtFlipView : UIView
{
	NSUInteger _currentViewIndex;
	
	BOOL roundCorners;
	NSUInteger borderWidth;
}

@property (nonatomic, readonly) NSMutableArray* views;
@property (nonatomic, readonly) UIView* currentView;
@property (nonatomic, readonly) UIView* nextView;
@property (nonatomic, readonly) NSUInteger currentViewIndex;

- (id)initWithFrame:(CGRect)frame borderWidth:(NSUInteger)width roundCorners:(BOOL)round;

- (void)flipWithXRatio:(CGFloat)xRatio yRatio:(CGFloat)yRatio;
- (void)flipWithXRatio:(CGFloat)xRatio yRatio:(CGFloat)yRatio duration:(NSTimeInterval)animationDuration;
- (void)flipWithXRatio:(CGFloat)xRatio yRatio:(CGFloat)yRatio duration:(NSTimeInterval)animationDuration delay:(NSTimeInterval)animationDelay;

- (void)flipToColor:(UIColor*)color withXRatio:(CGFloat)xRatio yRatio:(CGFloat)yRatio duration:(NSTimeInterval)animationDuration delay:(NSTimeInterval)animationDelay;

- (void)flipToIndex:(NSUInteger)index withXRatio:(CGFloat)xRatio yRatio:(CGFloat)yRatio duration:(NSTimeInterval)animationDuration delay:(NSTimeInterval)animationDelay;

// take colors from array until the current views each have a background color from the array.
- (void)setBackgroundColorsFromArray:(NSArray*)colors;

// make a certain number of views with colors from the array
- (void)setBackgroundColors:(NSUInteger)num fromArray:(NSArray *)colors;

- (void)addViews:(NSArray *)views;

- (void)removeLastViews:(NSUInteger)numberOfViews withAnimation:(BOOL)animation;

@end
