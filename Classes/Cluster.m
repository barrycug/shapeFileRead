//
//  Cluster.m
//  TestShp
//
//  Created by baocai zhang on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Cluster.h"

@implementation Cluster
@synthesize cx=_cx;
@synthesize cy=_cy;
@synthesize n=_n;
- (id) initWithX:(double)x y:(double)y cx:(double)cx cy:(double)cy spatialReference:(AGSSpatialReference *)spatialReference
{
    if (self =[super initWithX:x y:y spatialReference:spatialReference]) {
        _cx = cx;
        _cy = cy;
        _n =1;
    }
    return  self;
}
@end
