//
//  SplashArtAppDelegate.h
//  SplashArt
//
//  Created by Mathew Polzin on 2/4/13.
//  Copyright (c) 2013 Mathew Polzin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SplashArtRootViewController;
@class SplashArtViewController;

@interface SplashArtAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SplashArtRootViewController *viewController;
@property (strong, nonatomic) SplashArtViewController* splashArtViewController;

@end
