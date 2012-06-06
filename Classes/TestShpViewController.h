//
//  TestShpViewController.h
//  TestShp
//
//  Created by iphone4 on 11-4-27.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArcGIS.h"
#import "ClusterManager.h"
@interface TestShpViewController : UIViewController<ClusterManagerDelegate> {
	AGSMapView *_mapView;
	AGSGraphicsLayer *graphicsLayer;
	UIImage *image;
    ClusterManager *_clusterManager;
	
}

@property (nonatomic, retain) IBOutlet AGSMapView *mapView;
@property (nonatomic, retain) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic, retain) UIImage *image;

@end

