//
//  Cluster.h
//  TestShp
//
//  Created by baocai zhang on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArcGIS.h"
@interface Cluster : AGSMutablePoint
{
    @private
    double _cx;
    double _cy;
    int _n;
}
- (id) initWithX:(double)x y:(double)y cx:(double)cx cy:(double)cy spatialReference:(AGSSpatialReference *)spatialReference;
@property(assign,nonatomic) double cx;
@property(assign,nonatomic) double cy;
@property(assign,nonatomic) int n;
@end
