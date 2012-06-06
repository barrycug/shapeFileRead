//
//  TestShpAppDelegate.h
//  TestShp
//
//  Created by iphone4 on 11-4-27.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestShpViewController;

@interface TestShpAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TestShpViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TestShpViewController *viewController;

@end

