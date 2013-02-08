//
//  SplashArtRootViewController.m
//  SplashArt
//
//  Created by Mathew Polzin on 2/7/13.
//  Copyright (c) 2013 Mathew Polzin. All rights reserved.
//

#import "SplashArtRootViewController.h"

@interface SplashArtRootViewController ()

@end

@implementation SplashArtRootViewController

- (id)init
{
    self = [super init];
    if (self) {
//        splashArtViewController = [[SplashArtViewController alloc] init];
		self.view.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.view setUserInteractionEnabled:NO];
	[self.view setOpaque:NO];
	
//	splashArtViewController.view.frame = self.view.bounds;
//	
//	[self.view addSubview:splashArtViewController.view];
//	[self addChildViewController:splashArtViewController];
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	[splashArtViewController release], splashArtViewController = nil;
	
	[super dealloc];
}

@end
