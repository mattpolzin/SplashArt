//
//  SplashArtFlipView.m
//  SplashArt
//
//  Created by Mathew Polzin on 2/4/13.
//  Copyright (c) 2013 Mathew Polzin. All rights reserved.
//

#import "SplashArtFlipView.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_ANIMATION_DURATION 1.0

@interface SplashArtFlipView (PrivateMethods)

- (NSUInteger)indexOfNextView;

+ (void)flipFromView:(UIView*)v1 toView:(UIView*)v2 xRatio:(CGFloat)xRatio yRatio:(CGFloat)yRatio duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^)(BOOL finished))completion;

- (void)applyStyleToView:(UIView*)v;

@end

@implementation SplashArtFlipView (PrivateMethods)

- (NSUInteger)indexOfNextView
{
	return (_currentViewIndex+1)%self.views.count;
}

+ (void)flipFromView:(UIView*)v1 toView:(UIView*)v2 xRatio:(CGFloat)xRatio yRatio:(CGFloat)yRatio duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^)(BOOL finished))completion
{
	CGFloat halfRotationRadians = 1.57079633;
	
	duration = duration/2;
	v2.layer.transform = CATransform3DMakeRotation(halfRotationRadians, xRatio, yRatio, 0);
	
	[UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
		v1.layer.transform = CATransform3DMakeRotation(halfRotationRadians, -xRatio, -yRatio, 0);
	} completion:^(BOOL finished){
		[v1 setHidden:YES];
		[v2 setHidden:NO];
	}];
	
	[UIView animateWithDuration:duration delay:delay + duration options:UIViewAnimationOptionCurveEaseOut animations:^{
		v2.layer.transform = CATransform3DMakeRotation(0, xRatio, yRatio, 0);
	} completion:completion];
}

- (void)applyStyleToView:(UIView*)v
{
	if (borderWidth > 0) {
		v.layer.borderWidth = borderWidth;
		v.layer.borderColor = [UIColor blackColor].CGColor;
	}
	if (roundCorners) {
		v.layer.cornerRadius = 4;
		v.clipsToBounds = YES;
	}
}

@end

@implementation SplashArtFlipView

@synthesize views = _views;
@synthesize currentViewIndex = _currentViewIndex;

- (id)initWithFrame:(CGRect)frame
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (id)initWithFrame:(CGRect)frame borderWidth:(NSUInteger)width roundCorners:(BOOL)round;
{
    self = [super initWithFrame:frame];
    if (self) {
		roundCorners = round;
		borderWidth = width;
		
		[self setBackgroundColor:[UIColor clearColor]];
		
        _views = [[NSMutableArray alloc] initWithCapacity:4];
		UIView* viewA = [[UIView alloc] initWithFrame:self.bounds];
		[viewA setBackgroundColor:[UIColor redColor]];
		viewA.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self applyStyleToView:viewA];
		
		UIView* viewB = [[UIView alloc] initWithFrame:self.bounds];
		[viewB setBackgroundColor:[UIColor blueColor]];
		viewB.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self applyStyleToView:viewB];
		
		[_views addObject:viewA];
		[_views addObject:viewB];
		
		[self addSubview:viewA];
		[self addSubview:viewB];
		
		// hide view B,C,D initially
		[viewB setHidden:YES];
		
		[viewA release];
		[viewB release];
    }
    return self;
}

- (void)dealloc
{
	[_views release], _views = nil;
	
	[super dealloc];
}

- (void)setBackgroundColorsFromArray:(NSArray*)colors
{
	for (int ii = 0; ii < self.views.count && ii < colors.count; ii++) {
		UIView* v = [self.views objectAtIndex:ii];
		[v setBackgroundColor:[colors objectAtIndex:ii]];
	}
}

- (void)setBackgroundColors:(NSUInteger)num fromArray:(NSArray *)colors
{
	// set colors and add views if needed
	for (int ii = 0; ii < num; ii++) {
		UIView* v;
		if (ii < self.views.count) {
			v = [self.views objectAtIndex:ii];
		} else {
			v = [[UIView alloc] initWithFrame:self.bounds];
			[self.views addObject:v];
			[self addSubview:v];
			[self applyStyleToView:v];
			v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			[v setHidden:YES];
			[v release];
		}
		[v setBackgroundColor:[colors objectAtIndex:ii % colors.count]];
	}
	
	NSUInteger numberOfViews = self.views.count - num;
	
	if (numberOfViews > 0) {
		[self removeLastViews:numberOfViews withAnimation:YES];
	}
}

- (void)addViews:(NSArray *)views
{
	for (UIView* view in views) {
		[self.views addObject:view];
		[self addSubview:view];
		[self applyStyleToView:view];
		view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[view setHidden:YES];
	}
}

- (void)removeLastViews:(NSUInteger)numberOfViews withAnimation:(BOOL)animation;
{
	NSUInteger count = self.views.count;
	
	NSUInteger lowerBound = count - numberOfViews;
	
	BOOL needToTrimViews = YES;
	if (self.currentViewIndex >= lowerBound) {
		if (animation) {
			needToTrimViews = NO;
			
			[[self class] flipFromView:self.currentView toView:[self.views objectAtIndex:0]  xRatio:1 yRatio:0 duration:DEFAULT_ANIMATION_DURATION delay:0 completion:^(BOOL finished) {
				_currentViewIndex = 0;
				
				// remove extra views after animation completion.
				for (int ii = count-1; ii >= lowerBound; ii--) {
					[[self.views objectAtIndex:ii] removeFromSuperview];
					[self.views removeObjectAtIndex:ii];
				}
			}];
		} else {
			[self.currentView setHidden:YES];
			[[self.views objectAtIndex:0] setHidden:NO];
			_currentViewIndex = 0;
		}
	}
	
	// if we did not need to flip from the current view, then we can remove the
	// views here inline. Otherwise, the views get removed at animation completion
	if (needToTrimViews) {
		for (int ii = count - 1; ii >= lowerBound; ii--) {
			[[self.views objectAtIndex:ii] removeFromSuperview];
			[self.views removeObjectAtIndex:ii];
		}
	}
}

- (void)flipWithXRatio:(CGFloat)xRatio yRatio:(CGFloat)yRatio
{
	[self flipWithXRatio:xRatio yRatio:yRatio duration:DEFAULT_ANIMATION_DURATION];
}

- (void)flipWithXRatio:(CGFloat)xRatio yRatio:(CGFloat)yRatio duration:(NSTimeInterval)animationDuration;
{
	[self flipWithXRatio:xRatio yRatio:yRatio duration:animationDuration delay:0];
}

- (void)flipWithXRatio:(CGFloat)xRatio yRatio:(CGFloat)yRatio duration:(NSTimeInterval)animationDuration delay:(NSTimeInterval)animationDelay
{
	UIView* currentView = self.currentView;
	UIView* nextView = self.nextView;
	
	[[self class] flipFromView:currentView toView:nextView xRatio:xRatio yRatio:yRatio duration:animationDuration delay:animationDelay completion:^(BOOL finished) {
		
	}];
	_currentViewIndex = [self indexOfNextView];
}

- (void)flipToColor:(UIColor*)color withXRatio:(CGFloat)xRatio yRatio:(CGFloat)yRatio duration:(NSTimeInterval)animationDuration delay:(NSTimeInterval)animationDelay
{
	for (int ii = 0; ii< self.views.count; ii++) {
		UIView* v = [self.views objectAtIndex:ii];
		if ([v.backgroundColor isEqual:color]) {
			[self flipToIndex:ii withXRatio:xRatio yRatio:yRatio duration:animationDuration delay:animationDelay];
			return;
		}
	}
}

- (void)flipToIndex:(NSUInteger)index withXRatio:(CGFloat)xRatio yRatio:(CGFloat)yRatio duration:(NSTimeInterval)animationDuration delay:(NSTimeInterval)animationDelay
{
	UIView* currentView = self.currentView;
	UIView* nextView = [self.views objectAtIndex:index];
	
	if (currentView != nextView) {
		[[self class] flipFromView:currentView toView:nextView xRatio:xRatio yRatio:yRatio duration:animationDuration delay:animationDelay completion:^(BOOL finished) {
			
		}];
		
		_currentViewIndex = index;
	}
}

- (UIView*)currentView
{
	return [self.views objectAtIndex:_currentViewIndex];
}

- (UIView*)nextView
{
	return [self.views objectAtIndex:[self indexOfNextView]];
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
