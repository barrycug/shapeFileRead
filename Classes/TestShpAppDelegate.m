//
//  TestShpAppDelegate.m
//  TestShp
//
//  Created by iphone4 on 11-4-27.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestShpAppDelegate.h"
#import "TestShpViewController.h"

@implementation TestShpAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
