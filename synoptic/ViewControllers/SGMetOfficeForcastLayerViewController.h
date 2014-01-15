//
//  SGMetOfficeForcastLayerViewController.h
//  Synoptic
//
//  Created by sjg on 22/07/2013.
//  Copyright (c) 2013 sjg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface SGMetOfficeForcastLayerViewController : UIViewController{
    GMSMapView *mapView;
    NSMutableArray *overlayArray;
    
    NSMutableArray *overlayObjectArray;
    
    NSTimer *checkDownloads;
    NSNumber *imagesExpected;
    NSNumber *currentLayerIndex;
    NSString *layerName;
    
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) GMSMapView *mapView_;
@property (nonatomic, retain) NSString *layerName_;

-(id) initWithLayerName: (NSString *) layerName andTitle: (NSString*) tabTitle andImage: (NSString*) tabImage;

@end
