//
//  SplashArtViewController.m
//  SplashArt
//
//  Created by Mathew Polzin on 2/4/13.
//  Copyright (c) 2013 Mathew Polzin. All rights reserved.
//

#import "SplashArtViewController.h"
#import "SplashArtFlipView.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_ROWS 30
#define DEFAULT_COLS 30

// defaults for splash animations:
#define DEFAULT_START_DURATION 0.3
#define DEFAULT_FALLOUT 0.01
#define DEFAULT_CUTOFF 150

#define DEFAULT_MIN_MULTITOUCH_DISTANCE 20

#define DEFAULT_NUM_RANDOM_COLORS 8
#define ARC4RANDOM_MAX 0x100000000

#define DEFAULT_COLOR_PALLETE_SIZE 3

@interface SplashArtViewController (PrivateMethods)

- (void)initSplashArtViewController;

- (void)splashAtX:(CGFloat)x y:(CGFloat)y;

// these two functions are inverses:
+ (NSUInteger)linearViewIndexForColumn:(NSUInteger)col row:(NSUInteger)row;
+ (CGPoint)nonlinearViewIndexForLinearIndex:(NSUInteger)index;
- (CGPoint)nonlinearViewIndexForViewX:(CGFloat)x y:(CGFloat)y;

- (void)cyclePrimaryMode:(id)sender;
- (void)cutoffSliderValueChanged:(id)sender;
- (void)colorSelectionChanged:(id)sender;
- (void)colorPalleteSizeSliderValueChanged:(id)sender;
- (void)generateNewColorPallete:(id)sender;

- (void)saveToPhotoAlbum:(id)sender;

+ (CGFloat)distanceFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2;

+ (BOOL) iPad;

@end

@implementation SplashArtViewController (PrivateMethods)

- (void)initSplashArtViewController
{	
	randomColors = [[NSMutableArray alloc] initWithCapacity:DEFAULT_NUM_RANDOM_COLORS];
	for (int ii = 0; ii < DEFAULT_NUM_RANDOM_COLORS; ii++) {
		UIColor* rndColor = [UIColor colorWithRed:((double)arc4random() / ARC4RANDOM_MAX) green:((double)arc4random() / ARC4RANDOM_MAX) blue:((double)arc4random() / ARC4RANDOM_MAX) alpha:1.0];
		
		[randomColors addObject:rndColor];
	}
	
	splashArtViews = [[NSMutableArray alloc] initWithCapacity:DEFAULT_ROWS * DEFAULT_COLS];
	
	CGRect parentViewBounds = self.view.bounds;
	cellSize = CGSizeMake(parentViewBounds.size.width / DEFAULT_COLS, parentViewBounds.size.height / DEFAULT_ROWS);
	
	for (int ii = 0; ii < DEFAULT_ROWS; ii++) {
		for (int jj = 0; jj < DEFAULT_COLS; jj++) {
			CGFloat originX = jj * cellSize.width;
			CGFloat originY = ii * cellSize.height;
			CGRect cellFrame = CGRectMake(originX,
									  originY,
									  cellSize.width,
									  cellSize.height);
			SplashArtFlipView* safView = [[SplashArtFlipView alloc] initWithFrame:cellFrame borderWidth:0 roundCorners:NO];
			
			[safView setBackgroundColors:DEFAULT_COLOR_PALLETE_SIZE fromArray:randomColors];
			
			[self.view addSubview:safView];
			[splashArtViews setObject:safView atIndexedSubscript:[[self class] linearViewIndexForColumn:jj row:ii]];
			
			[safView release];
		}
	}
	
	cutoff = DEFAULT_CUTOFF;
	CGFloat margin = 10;
	cutoffSlider = [[UISlider alloc] initWithFrame:CGRectMake(margin, margin + (60 - 44) / 2.0, 100, 44)];
	[cutoffSlider setMinimumValue:cellSize.height];
	[cutoffSlider setMaximumValue:300];
	[cutoffSlider setValue:DEFAULT_CUTOFF];
	[cutoffSlider addTarget:self action:@selector(cutoffSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
	
	[self.view addSubview:cutoffSlider];
	
	colorSelector = [[SplashArtColorSelector buttonWithType:UIButtonTypeCustom] retain];
	colorSelector.frame = CGRectMake(2*margin + 100, margin, 150, 60);
	[colorSelector setBackgroundColors:DEFAULT_COLOR_PALLETE_SIZE fromArray:randomColors];
	[colorSelector addTarget:self action:@selector(colorSelectionChanged:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:colorSelector];
	
	primaryMode = PM_FLIP;
	[colorSelector setSelectedIndex:DEFAULT_COLOR_PALLETE_SIZE];
	
	colorPalletSizeSlider = [[UISlider alloc] initWithFrame:CGRectMake(3*margin + 250, margin + (60 - 44) / 2.0, 100, 44)];
	[colorPalletSizeSlider setMinimumValue:2];
	[colorPalletSizeSlider setMaximumValue:DEFAULT_NUM_RANDOM_COLORS-1];
	[colorPalletSizeSlider setValue:DEFAULT_COLOR_PALLETE_SIZE];
	[colorPalletSizeSlider addTarget:self action:@selector(colorPalletSizeSliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:colorPalletSizeSlider];
	
	UIButton* exportButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	exportButton.frame = CGRectMake(4*margin + 350, margin, 60, 60);
	[exportButton addTarget:self action:@selector(saveToPhotoAlbum:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:exportButton];
	
	UIButton* generatePalleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	generatePalleteButton.frame = CGRectMake(5*margin + 410, margin, 60, 60);
	[generatePalleteButton addTarget:self action:@selector(generateNewColorPallete:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:generatePalleteButton];
	
	self.view.multipleTouchEnabled = YES;
}

- (void)cyclePrimaryMode:(id)sender
{
	if (primaryMode == PM_FLOP) {
		primaryMode = PM_FLIP;
		[primaryModeButton setTitle:@"FLIP" forState:UIControlStateNormal];
	} else if (primaryMode == PM_FLIP) {
		primaryMode = PM_FLOP;
		[primaryModeButton setTitle:@"BOMB" forState:UIControlStateNormal];
	}
}

- (void)cutoffSliderValueChanged:(id)sender
{
	cutoff = cutoffSlider.value;
}

- (void)colorSelectionChanged:(id)sender
{
	UIColor* selectedColor = colorSelector.currentColor;
	
	if (selectedColor) {
		primaryMode = PM_HOP;
	} else {
		primaryMode = PM_FLIP;
	}
}

- (void)colorPalleteSizeSliderValueChanged:(id)sender
{
	NSUInteger newNumColors = roundf(colorPalletSizeSlider.value);
	
	[colorSelector setBackgroundColors:newNumColors fromArray:randomColors];
	
	for (int ii = 0; ii < DEFAULT_ROWS * DEFAULT_COLS; ii++) {
		SplashArtFlipView* artView = (SplashArtFlipView*)[splashArtViews objectAtIndex:ii];
		
		[artView setBackgroundColors:newNumColors fromArray:randomColors];
	}
	
	[self colorSelectionChanged:self];
}

- (void)renderInContext:(CGContextRef)context
{
	SplashArtFlipView* v;
	CGRect rect;
	UIColor* color;
	
	for (int ii = 0; ii < DEFAULT_ROWS; ii++) {
		for (int jj = 0; jj < DEFAULT_COLS; jj++) {
			v = [splashArtViews objectAtIndex:[[self class] linearViewIndexForColumn:jj row:ii]];
			color = v.currentView.backgroundColor;
			
			rect = CGRectMake(ceilf(jj * cellSize.width), ceilf(ii * cellSize.height), ceilf(cellSize.width), ceilf(cellSize.height));
			
			CGContextSetFillColorWithColor(context, color.CGColor);
			CGContextFillRect(context, rect);
		}
	}
}

- (void)saveToPhotoAlbum:(id)sender
{
	CGRect frame = self.view.bounds;
	
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
	
	CGFloat rotation = 0;
	CGFloat xOffset = 0;
	CGFloat yOffset = 0;
	
	if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
		CGFloat tmp = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = tmp;
		xOffset = frame.size.width;
		rotation = M_PI/2;
	} else if(deviceOrientation == UIDeviceOrientationLandscapeRight) {
		CGFloat tmp = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = tmp;
		yOffset = frame.size.height;
		rotation =  -M_PI/2;
	} else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
		xOffset = frame.size.width;
		yOffset = frame.size.height;
		rotation = M_PI;
	}
	
	UIGraphicsBeginImageContextWithOptions(frame.size, YES, [UIScreen mainScreen].scale);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (rotation) {
		CGContextTranslateCTM(context, xOffset, yOffset);
		CGContextRotateCTM(context, rotation);
	}
	
	CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
//	[self.view.layer renderInContext:context];
	[self renderInContext:context];
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObject:image] applicationActivities:nil];
	
	if ([[self class] iPad]) {
		if (popoverController) {
			[popoverController release], popoverController = nil;
		}
		popoverController = [[UIPopoverController alloc] initWithContentViewController:avc];
		[popoverController presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else {
		[self presentViewController:avc animated:YES completion:^{
			
		}];
	}
	[avc release];
}

- (void)generateNewColorPallete:(id)sender
{
	for (int ii = 0; ii < DEFAULT_NUM_RANDOM_COLORS; ii++) {
		UIColor* rndColor = [UIColor colorWithRed:((double)arc4random() / ARC4RANDOM_MAX) green:((double)arc4random() / ARC4RANDOM_MAX) blue:((double)arc4random() / ARC4RANDOM_MAX) alpha:1.0];
		
		[randomColors setObject:rndColor atIndexedSubscript:ii];
	}
	
	for (int ii = 0; ii < splashArtViews.count; ii++) {
		[(SplashArtFlipView*)[splashArtViews objectAtIndex:ii] setBackgroundColors:colorSelector.colorCount fromArray:randomColors];
	}
	
	[colorSelector setBackgroundColors:colorSelector.colorCount fromArray:randomColors];
}

- (void)splashAtX:(CGFloat)x y:(CGFloat)y
{
	CGFloat diffX,diffY,magnitude;
	NSUInteger linearIndex;
	
	for (int ii = 0; ii < DEFAULT_ROWS; ii++) {
		for (int jj = 0; jj < DEFAULT_COLS; jj++) {
			diffX = x - (jj+0.5)*cellSize.width;
			diffY = y - (ii+0.5)*cellSize.height;
			
			magnitude = sqrtf(powf(diffX, 2) + powf(diffY, 2));
			
			if (magnitude < cutoff) {
				linearIndex = [[self class] linearViewIndexForColumn:jj row:ii];
				SplashArtFlipView* artView = (SplashArtFlipView*)[splashArtViews objectAtIndex:linearIndex];
				if (primaryMode == PM_FLOP) {
					[artView.nextView setBackgroundColor:colorSelector.currentColor];
				} else if (primaryMode == PM_HOP) {
					[artView flipToColor:colorSelector.currentColor withXRatio:-(diffY / magnitude) yRatio:(diffX / magnitude) duration:magnitude*DEFAULT_FALLOUT delay:0];
				} else { // PM_FLIP
					[artView flipWithXRatio:-(diffY / magnitude) yRatio:(diffX / magnitude) duration:magnitude*DEFAULT_FALLOUT delay:0];
				}
			}
		}
	}
}

+ (NSUInteger)linearViewIndexForColumn:(NSUInteger)col row:(NSUInteger)row
{	
	return (row % DEFAULT_ROWS) * DEFAULT_COLS + (col % DEFAULT_COLS);
}

+ (CGPoint)nonlinearViewIndexForLinearIndex:(NSUInteger)index
{
	NSUInteger linearIndex = (index % (DEFAULT_ROWS * DEFAULT_COLS));
	NSUInteger x = (linearIndex % DEFAULT_COLS);
	NSUInteger y = ((linearIndex - x) / DEFAULT_COLS);
	return CGPointMake(x, y);
}

- (CGPoint)nonlinearViewIndexForViewX:(CGFloat)x y:(CGFloat)y
{
	return CGPointMake(floorf(x / cellSize.width), floorf(y / cellSize.height));
}

+ (CGFloat)distanceFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2
{
	return sqrtf(powf(p1.x-p2.x, 2) + powf(p1.y-p2.y, 2));
}

+ (BOOL) iPad
{
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

@end

@implementation SplashArtViewController

- (id)init
{
	self = [super init];
	
	if (self) {
		[self initSplashArtViewController];
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	lastTouchTaken = [[NSProcessInfo processInfo] systemUptime];
	
	[touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		UITouch* touch = obj;
		
		CGPoint touchPoint = [touch locationInView:self.view];
		
		[self splashAtX:touchPoint.x y:touchPoint.y];
	}];
	
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	BOOL __block touchTaken = NO;
	
		[touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
			UITouch* touch = obj;
			
			if (touch.timestamp - lastTouchTaken > 0.1) {
				touchTaken = YES;
				
				CGPoint touchPoint = [touch locationInView:self.view];
				
				[self splashAtX:touchPoint.x y:touchPoint.y];
			}
		}];
	
	if (touchTaken) {
		lastTouchTaken = [[NSProcessInfo processInfo] systemUptime];
	}
	
	[super touchesMoved:touches withEvent:event];
}

- (BOOL)shouldAutorotate
{
	return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	[splashArtViews release], splashArtViews = nil;
	[randomColors release], randomColors = nil;
	[primaryModeButton release], primaryModeButton = nil;
	[colorPalletSizeSlider release], colorPalletSizeSlider = nil;
	
	[popoverController release], popoverController = nil;
	
	[super dealloc];
}

@end
