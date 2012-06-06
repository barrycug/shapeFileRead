//
//  ClusterManager.m
//  TestShp
//
//  Created by baocai zhang on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ClusterManager.h"
#import "Cluster.h"
@interface ClusterManager()
-(void)sink_collectionChange;
-(void)respondToEnvChange: (NSNotification*) notification;
-(void) clusterMapPoints;
-(void)mergeOverlappingClusters;
-(void)searchAndMerge:(Cluster *) cluster ox:(int) ox oy:(int) oy;
-(void)mergeWithLhs:(Cluster*) lhs andRhs:(Cluster*) rhs;
-(void) assignMapPointsToClusters;
- (AGSCompositeSymbol*)clusterSymbolWithNumber:(NSInteger)stopNumber;
@end
@implementation ClusterManager
@synthesize sink=_sink;
@synthesize source=_source;
@synthesize radius=_radius;
@synthesize delegate=_delegate;

-(void) dealloc
{
    if(_mapView !=nil)
    {
        [_mapView release];
        _mapView = nil;
    }
    self.sink = nil;
    if (_source != nil) {
        [_source release];
        _source = nil;
    }
    if (_orig != nil) {
        [_orig release];
        _orig = nil;
    }
    
    [super dealloc];
}
-(id) initWithMapView:(AGSMapView *) mapView andIsStaticCluster:(BOOL)isStaticCluster
{
    if (self =[super init]) {
        _mapView = [mapView retain];
        _radius = 20.0f;
        _isStaticCluster = isStaticCluster;
        if (!_isStaticCluster) {
                  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:)
                                                               name:@"MapDidEndPanning" object:nil];
        }
 
        
        // register for "MapDidEndZooming" notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:) 
                                                     name:@"MapDidEndZooming" object:nil];
        _source = [[NSMutableArray alloc]initWithCapacity:100];
    }
    return self;
}
-(void)setSink:(NSMutableArray *)sink
{
    if (_sink != sink) {
        [_sink release];
        _sink = [sink retain];
        [self sink_collectionChange];
    }
}
- (void)respondToEnvChange: (NSNotification*) notification {
    
   [self clusterMapPoints]; 
    
}

-(void)sink_collectionChange
{
    if (!_isStaticCluster) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MapDidEndPanning" object:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MapDidEndZooming" object:nil];
    [self clusterMapPoints];
    if (!_isStaticCluster) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:)
                                                     name:@"MapDidEndPanning" object:nil];
    }    // register for "MapDidEndZooming" notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:) 
                                                 name:@"MapDidEndZooming" object:nil]; 
}
-(void) clusterMapPoints
{
    _diameter = _radius + _radius;
    
    [self assignMapPointsToClusters];
    do // Keep merging overlapping clusters until none overlap.
    {
        [self mergeOverlappingClusters];
    }
    while( _overlapExists );
    [_source removeAllObjects];
    NSEnumerator *enumerator = [_orig objectEnumerator];  
    id obj;  
    
    while ((obj = [enumerator nextObject]))   
    {  
        Cluster * cluster =obj;
        // Convert clusters to graphics so they can be displayed.
        CGPoint point = CGPointMake(cluster.x, cluster.y);
        AGSPoint * mPoint=[_mapView toMapPoint:point];
        [cluster updateWithX:mPoint.x y:mPoint.y];
                    /*
        AGSGraphic *graphic : Graphic = new ClusterGraphic( cluster, null, {n:cluster.n} );
                      */
        AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry:cluster symbol:[self clusterSymbolWithNumber:cluster.n] attributes:nil infoTemplateDelegate:nil];
        [_source addObject:graphic];  
    }  
    if ([self.delegate respondsToSelector:@selector(ClusterFinshed)]) {
        [self.delegate ClusterFinshed];
    }
    
}
-(void)mergeOverlappingClusters
{
    _overlapExists = NO;
    // Create a new set to hold non-overlapping clusters.            
    NSMutableDictionary *dest=[[NSMutableDictionary alloc] initWithCapacity:1000];
    NSEnumerator *enumerator = [_orig objectEnumerator];  
    id obj;  
    
    while ((obj = [enumerator nextObject]))  
    {
         Cluster * cluster =obj;
        if( cluster.n == 0 )
        {
            continue;
        }
        // Search all immediately adjacent clusters.
        [self searchAndMerge:cluster  ox:1  oy:  0 ];
        [self searchAndMerge:cluster  ox:-1  oy:  0 ];
        [self searchAndMerge:cluster  ox:0  oy:  1 ];
        [self searchAndMerge:cluster  ox:0  oy:  -1 ];
        [self searchAndMerge:cluster  ox:1  oy:  1 ];
        [self searchAndMerge:cluster  ox:1  oy:  -1 ];
        [self searchAndMerge:cluster  ox:-1  oy:  1 ];
        [self searchAndMerge:cluster  ox:-1  oy:  -1 ];
        /*
        [self searchAndMerge( cluster, -1,  0 );
        [self searchAndMerge( cluster,  0,  1 );
        [self searchAndMerge( cluster,  0, -1 );
        [self searchAndMerge( cluster,  1,  1 );
        [self searchAndMerge( cluster,  1, -1 );
        [self searchAndMerge( cluster, -1,  1 );
        [self searchAndMerge( cluster, -1, -1 );
         */
        
        // Find the new cluster centroid values.                
        int cx  = cluster.x / _diameter;
        int cy  = cluster.y / _diameter;
        cluster.cx = cx;
        cluster.cy = cy;
        // Compute new dictionary key.
        int ci  = (cx << 16) | cy;
      //  dest[ci] = cluster;  
         [dest setObject:cluster forKey:[NSString stringWithFormat:@"%ld",ci]];
    }
    if(_orig != nil)
    {
        [_orig release];
        _orig = nil;
    }
    _orig = [dest retain];
    [dest release];
}
-(void)searchAndMerge:(Cluster *) cluster ox:(int) ox oy:(int) oy
{
    int cx = cluster.cx + ox;
    int cy  = cluster.cy + oy;
    int ci  = (cx << 16) | cy;
    Cluster *found   = [_orig objectForKey:[NSString stringWithFormat:@"%ld",ci]];
    if( found && found.n )
    {
        double dx  = found.x - cluster.x;
        double dy  = found.y - cluster.y;
        double dd  = sqrt(dx * dx + dy * dy);
        // Check if there is a overlap based on distance. 
        if( dd < _diameter )
        {
            _overlapExists = true;
            [self mergeWithLhs:cluster andRhs:found ];
        }                                
    }              
}
-(void)mergeWithLhs:(Cluster*) lhs andRhs:(Cluster*) rhs
{
    int nume  = lhs.n + rhs.n;
    [lhs updateWithX:(lhs.n * lhs.x + rhs.n * rhs.x ) / nume y:(lhs.n * lhs.y + rhs.n * rhs.y ) / nume];
    lhs.n += rhs.n; // merge the map points
    rhs.n = 0; // marke the cluster as merged.
} 
-(void) assignMapPointsToClusters
{
    if (_orig != nil) {
        [_orig release];
        _orig = nil;
    }
    _orig = [[NSMutableDictionary alloc] initWithCapacity:1000];
    int i = 0;
    for (i=0; i<[self.sink count]; i++)
    {
        // Cluster only map points in the map extent
        AGSPoint * mapPoint = [self.sink objectAtIndex:i];
   //     AGSEnvelope * env  = _mapView.visibleArea.envelope;
        if(_isStaticCluster|| [_mapView.visibleArea.envelope containsPoint: mapPoint ])
        {
             CGPoint s=[_mapView toScreenPoint:mapPoint];
            // Convert to cluster x/y values.                                        
            int cx  = s.x / _diameter;
            int cy  = s.y / _diameter;
            
            // Convert to cluster dictionary key.                    
            int ci  = (cx << 16) | cy;
            
            // Find existing cluster                    
            Cluster *cluster   = [_orig objectForKey:[NSString stringWithFormat:@"%ld",ci]];
            if( cluster )
            {
                // Average centroid values based on new map point.
             
                [cluster updateWithX:(cluster.x + s.x) / 2.0 y:(cluster.y + s.y) / 2.0];
                // Increment the number map points in that cluster.
                cluster.n++;                    
            }
            else
            {
                // Not found - create a new cluster as that index.
             //   cluster = new Cluster( sx, sy, cx, cy);
               Cluster* newCluster = [[Cluster alloc] initWithX:s.x y:s.y cx:cx cy:cy spatialReference:nil];
                [_orig setObject:newCluster forKey:[NSString stringWithFormat:@"%ld",ci]];
                [newCluster release];
            }
        } 
    }            
}

- (AGSCompositeSymbol*)clusterSymbolWithNumber:(NSInteger)stopNumber {
	AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
	
    // create outline
	AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbol];
	sls.color = [UIColor  whiteColor];
	sls.width = 2;
	sls.style = AGSSimpleLineSymbolStyleSolid;
	
    // create main circle
	AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
	sms.color = [UIColor greenColor];
	sms.outline = sls;
    sms.size = 20;
    
    AGSTextSymbol *ts = [[[AGSTextSymbol alloc] initWithTextTemplate:[NSString stringWithFormat:@"%d", stopNumber] 
															   color:[UIColor whiteColor]] autorelease];
	ts.vAlignment = AGSTextSymbolVAlignmentMiddle;
	ts.hAlignment = AGSTextSymbolHAlignmentCenter;
    if (stopNumber >1000) {
        sms.size = 60;
        sms.color = [UIColor redColor];
        ts.fontSize	= 24;
    }else if(stopNumber>500 && stopNumber<=1000)
    {
       sms.size = 40; 
       sms.color = [UIColor orangeColor];
        ts.fontSize	= 22;
    }else if(stopNumber>100 && stopNumber<=500)
    {
        sms.size = 34; 
        sms.color = [UIColor magentaColor];
        ts.fontSize	= 20;
    }
    else if(stopNumber>50 && stopNumber<=100)
    {
        sms.size = 28; 
        sms.color = [UIColor grayColor];
        ts.fontSize	= 18;
    }
    else if(stopNumber>10 && stopNumber<=50)
    {
        sms.size = 24; 
        sms.color = [UIColor blueColor];
        ts.fontSize	= 16;
    }
    else
    {
        sms.size = 20; 
        sms.color = [UIColor blackColor];
        ts.fontSize	= 12;
    }
	
	sms.style = AGSSimpleMarkerSymbolStyleCircle;
	[cs.symbols addObject:sms];
    // add number as a text symbol

    
	
	ts.fontWeight = AGSTextSymbolFontWeightBold;
	[cs.symbols addObject:ts];
	
	return cs;
}
@end
