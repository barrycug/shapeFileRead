//
//  ClusterManager.h
//  TestShp
//
//  Created by baocai zhang on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArcGIS.h"
@protocol ClusterManagerDelegate <NSObject>

@required
-(void) ClusterFinshed;
@end

@interface ClusterManager : NSObject
{
@private
    NSMutableArray  *_sink;
    NSMutableArray  *_source;
    AGSMapView      *_mapView;
    int _radius ; 
    int _diameter  ;
    NSMutableDictionary *_orig;                
    BOOL _overlapExists ;
    id<ClusterManagerDelegate> _delegate;
    BOOL _isStaticCluster;
}
-(id) initWithMapView:(AGSMapView *) mapView andIsStaticCluster:(BOOL)isStaticCluster;
@property(retain,nonatomic) NSMutableArray  *sink;
@property(retain,readonly, nonatomic) NSMutableArray  *source;
@property(assign,nonatomic) int  radius;
@property(assign,nonatomic) id<ClusterManagerDelegate> delegate;
@end
