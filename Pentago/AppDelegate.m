//
//  AppDelegate.m
//  Pentago
//
//  Ryan Shaul on 2/8/12.
//  Copyright (c) 2012 Ryan Shaul. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
	
	GameViewController *gvc = [[GameViewController alloc] init];
	self.window.rootViewController = gvc;
	[gvc release];
	
    [self.window makeKeyAndVisible];
    return YES;
}

@end
