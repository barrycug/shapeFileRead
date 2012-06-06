//
//  ShpHelper.m
//  TestShp
//
//  Created by baocai zhang on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShpHelper.h"
#import "shapefil.h"
#import "ArcGIS.h"

NSMutableArray * shp2AGSGraphics(NSString * shpPath,NSString * shpName)
{
    SHPHandle	hSHP;
    DBFHandle   hDBF;
    int		nShapeType, nEntities, i;
    int		nWidth, nDecimals;
    double 	adfMinBound[4], adfMaxBound[4];
    /*
    NSString *shpPath = [[NSBundle mainBundle] pathForResource:@"XianCh_point" ofType:@"shp" inDirectory:@"res4_4m"];
     */
    /* -------------------------------------------------------------------- */
    /*      Open the passed shapefile.                                      */
    /* -------------------------------------------------------------------- */
    NSString * shpFile = [NSString stringWithFormat:@"%@/%@.shp",shpPath,shpName];
    NSString * dbfFile = [NSString stringWithFormat:@"%@/%@.dbf",shpPath,shpName];
    hSHP = SHPOpen([shpFile UTF8String], "rb" );
    hDBF  = DBFOpen([dbfFile UTF8String], "rb");
    if( hSHP == NULL  || hDBF == NULL)
    {
        return nil;
    }
    
    /* -------------------------------------------------------------------- */
    /*      Print out the file bounds.                                      */
    /* -------------------------------------------------------------------- */
    SHPGetInfo( hSHP, &nEntities, &nShapeType, adfMinBound, adfMaxBound );
    
    
    /* -------------------------------------------------------------------- */
    /*	Skim over the list of shapes, printing all the vertices.	*/
    /* -------------------------------------------------------------------- */
    NSMutableArray * data=[[NSMutableArray alloc] initWithCapacity:1000];
    for( i = 0; i < nEntities; i++ )
    {
        SHPObject	*psShape;		
        psShape = SHPReadObject( hSHP, i );	
        AGSGraphic * gra= nil;
        switch (nShapeType) {
            case SHPT_POINT:
            {
                 AGSPoint *point =	[AGSPoint pointWithX:psShape->padfX[0] y:psShape->padfY[0] spatialReference:nil];
                gra = [AGSGraphic graphicWithGeometry:point symbol:nil attributes:nil infoTemplateDelegate:nil];
            }
                break;
            case SHPT_ARC:
            {
                AGSMutablePolyline * line = [[AGSMutablePolyline alloc] init];
                
                for( int partNumber = 0; partNumber < psShape->nParts; partNumber++ )
                {                      
                    int start = psShape->nParts > 1 ? psShape->panPartStart[partNumber] : 0;
                    int end = psShape->nParts > 1 ? psShape->panPartStart[ partNumber + 1 ] : psShape->nVertices;
                    [line addPathToPolyline];
                    if( partNumber == psShape->nParts-1 )
                    {
                        end = psShape->nVertices;
                    }
                    
                    for( int v = start; v < end; v++ )
                    {
                         AGSPoint *point =	[AGSPoint pointWithX:psShape->padfX[v] y:psShape->padfY[v] spatialReference:nil];
                        [line addPoint:point toPath:partNumber];
                    }
                }
                gra = [AGSGraphic graphicWithGeometry:line symbol:nil attributes:nil infoTemplateDelegate:nil];
                [line release];
            }
                break;
            case SHPT_POLYGON:
            {
                AGSMutablePolygon * polygon = [[AGSMutablePolygon alloc] init];
                
                for( int partNumber = 0; partNumber < psShape->nParts; partNumber++ )
                {                      
                    int start = psShape->nParts > 1 ? psShape->panPartStart[partNumber] : 0;
                    int end = psShape->nParts > 1 ? psShape->panPartStart[ partNumber + 1 ] : psShape->nVertices;
                    
                    if( partNumber == psShape->nParts-1 )
                    {
                        end = psShape->nVertices;
                    }
                    [polygon addRingToPolygon];
                    for( int v = start; v < end; v++ )
                    {
                        AGSPoint *point =	[AGSPoint pointWithX:psShape->padfX[v] y:psShape->padfY[v] spatialReference:nil];
                        [polygon addPointToRing:point];
                    }
                }
                gra = [AGSGraphic graphicWithGeometry:polygon symbol:nil attributes:nil infoTemplateDelegate:nil];
                [polygon release];
            }
                break;
            default:
                break;
        }
         SHPDestroyObject( psShape );
       //read att
        int fCount = DBFGetFieldCount(hDBF);
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithCapacity:10];
        for( int fIndex = 0; fIndex < fCount; fIndex++ )
        {
            char		szTitle[12];
            DBFFieldType	eType = DBFGetFieldInfo( hDBF, fIndex, szTitle, &nWidth, &nDecimals );            
           
            switch (eType ) 
            {
                case FTString:
                {
                    NSString * fName  = [NSString stringWithUTF8String:szTitle];
                   const char * value = DBFReadStringAttribute(hDBF, i, fIndex);
                    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                    NSString * fValue = [NSString stringWithCString: value encoding:enc];
                    [dict setObject:fValue forKey: fName];
                }
                    break;
                    
                case FTInteger:
                    [dict setObject:[NSNumber numberWithInt: DBFReadIntegerAttribute(hDBF, i, fIndex)] forKey:[NSString stringWithUTF8String:szTitle] ];
                    
                    break;
                    
                case FTDouble:
                    [dict setObject:[NSNumber numberWithDouble: DBFReadDoubleAttribute(hDBF, i, fIndex)] forKey:[NSString stringWithUTF8String:szTitle] ];
                    break;
                    
                case FTInvalid:
                 //   strcpy (ftype, "invalid/unsupported");
                    break;
                    
                default:
                 //   strcpy (ftype, "unknown");
                    break;			
            }
        }
        gra.attributes = dict;
        [dict release];
       
        [data addObject:gra];
      
    }
    SHPClose( hSHP );	
    DBFClose( hDBF );
    return  [data autorelease];
}