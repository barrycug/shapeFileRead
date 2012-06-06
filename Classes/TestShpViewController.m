//
//  TestShpViewController.m
//  TestShp
//
//  Created by iphone4 on 11-4-27.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestShpViewController.h"
#import "shapefil.h"

#import "ShpHelper.h"
@implementation TestShpViewController

@synthesize mapView=_mapView;
@synthesize graphicsLayer;
@synthesize image;
/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	/* ##################################################### */
	// TODO
	// Replace the following block of code with your own.
	//
	NSURL *mapUrl = [NSURL URLWithString:@"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"];
	AGSTiledMapServiceLayer *tiledLyr = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:mapUrl];
	[self.mapView addMapLayer:tiledLyr withName:@"Tiled Layer"];
	self.mapView.layerDelegate = self;
	self.mapView.touchDelegate = self;
    AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:102100];
//	AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:12836931.118569 ymin:4773566.12743336 xmax:13092266.2487341 ymax:5033121.81554815 spatialReference:[AGSSpatialReference spatialReferenceWithWKID:102113]];
//	[self.mapView zoomToEnvelope:env animated:YES];
	
	self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
	[self.mapView addMapLayer:self.graphicsLayer withName:@"graphicsLayer"];
		
}
- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    

}
- (void)mapViewDidLoad:(AGSMapView *)mapView
{
    _clusterManager = [[ClusterManager alloc] initWithMapView:self.mapView andIsStaticCluster:YES];
    _clusterManager.radius=20;
 
    _clusterManager.delegate = self;
   // [self readSHP];
  //  NSString *shpPath = [[NSBundle mainBundle] pathForResource:@"XianCh_point" ofType:@"shp" inDirectory:@"res4_4m"];
  //  NSLog(@"%@",shpPath);
    NSString *mainPath =[[NSBundle mainBundle] resourcePath];
    NSString *shpPath = [NSString stringWithFormat:@"%@/res4_4m",mainPath];
    NSMutableArray * data = shp2AGSGraphics(shpPath ,@"XianCh_point");
    NSMutableArray * sinkData = [NSMutableArray arrayWithCapacity:[data count]+1];
    
    for (int i=0 ; i<[data count]; i++) {
        AGSGraphic * gra = [data objectAtIndex:i];
        /*
        
        AGSPictureMarkerSymbol * pSym = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"pushpin.png"];
        gra.symbol = pSym; 
       [self.graphicsLayer addGraphic:gra];
         */
        [sinkData addObject:gra.geometry];
        
    }
    /*
	[self.graphicsLayer dataChanged];
    [self.mapView zoomToEnvelope:self.graphicsLayer.fullEnvelope animated:NO];
     */
    
    _clusterManager.sink = sinkData ;
     
}
-(void) ClusterFinshed
{
    [self.graphicsLayer removeAllGraphics];
    [self.graphicsLayer addGraphics :_clusterManager.source];
	[self.graphicsLayer dataChanged];
  
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    if (_clusterManager != nil) {
        [_clusterManager release];
        _clusterManager = nil;
    }
	self.mapView = nil;
    [super dealloc];
}

@end
