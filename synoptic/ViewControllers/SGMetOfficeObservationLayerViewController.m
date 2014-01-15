//
//  SGMetOfficeObservationLayerViewController.m
//  Synoptic
//
//  Created by sjg on 22/07/2013.
//  Copyright (c) 2013 sjg. All rights reserved.
//

#import "SGMetOfficeObservationLayerViewController.h"
#import "AFImageRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "SGMetOfficeForecastImage.h"
#import "MBProgressHUD.h"
#import <GoogleMaps/GoogleMaps.h>

@interface SGMetOfficeObservationLayerViewController ()

@end

@implementation SGMetOfficeObservationLayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Rain Forcast", @"Rain");
        self.tabBarItem.image = [UIImage imageNamed:@"raincloud"];
    }
    return self;
}

-(id) initWithLayerName: (NSString *) displayLayer andTitle: (NSString*) tabTitle andImage: (NSString*) tabImage{
    self = [super init];
    if (self) {
        self.title = tabTitle;
        self.tabBarItem.image = [UIImage imageNamed: tabImage];
        
        if(![displayLayer isEqualToString: @""]){
            self.layerName_ = displayLayer;
        }else{
            self.layerName_ = @"Precipitation_Rate";
        }
    }
    return self;
}

-(void) loadView{

    /////////////////////////////////////////////////////////////////////////
    // Met Office Website
    // The map layer is provided without a map, the boundary box for this image is 48° to 61° north and 12° west to 5° east.
    
    //Set Extent of UK Met Office Image
//    CLLocationCoordinate2D UKSouthWest = CLLocationCoordinate2DMake(48.00, -12.00);
//    CLLocationCoordinate2D UKNorthEast = CLLocationCoordinate2DMake(61.00, 5.00);
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude: 55.559323
                                                            longitude: -4.174805
                                                                 zoom: 5];
    
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = NO;
    
    //Call UIEdgeInsets so that we're not covering the Copyright information (which would be a TOS violation)
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 5, 58.0, 0);
    mapView.padding = insets;
    
    // Use Tileset stored on remote server.
    GMSTileURLConstructor urls = ^(NSUInteger x, NSUInteger y, NSUInteger zoom) {
        NSString *url = [NSString stringWithFormat:@"http://media.stevenjamesgray.com/weather/%d/%d/%d.png", zoom, x, y];
        return [NSURL URLWithString:url];
    };
    
    GMSURLTileLayer *layer = [GMSURLTileLayer tileLayerWithURLConstructor:urls];
    
    //Display on the map at a specific zIndex
    layer.zIndex = 5;
    layer.map = mapView;
    
    self.view = mapView;
    mapView.mapType = kGMSTypeNone;
    currentLayerIndex = @0;
    
    //Make new call
    overlayArray = [[NSMutableArray alloc] init];
    overlayObjectArray = [[NSMutableArray alloc] init];

    // Call to get the Sets
    NSURL *layers_url = [NSURL URLWithString: [NSString stringWithFormat: api_obs_layers_cap, MET_OFFICE_API_KEY]];
    NSURLRequest *layers_request = [NSURLRequest requestWithURL: layers_url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest: layers_request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSMutableArray *layer_array_api = [(NSMutableArray *)[JSON valueForKeyPath:@"Layers"] valueForKey: @"Layer"];
        for(NSMutableDictionary *layers in layer_array_api){
            NSLog(@"Name: %@", [layers objectForKey: @"@displayName"]);
            if([[layers objectForKey: @"@displayName"] isEqualToString: self.layerName_]){
                NSLog(@"LayerName: %@",[[layers objectForKey: @"Service"] objectForKey: @"LayerName"]);
                NSLog(@"TimeSteps: %@",[[[layers objectForKey: @"Service"] objectForKey: @"Times"] objectForKey: @"Time"]);
                NSLog(@"Name: %@",[[[layers objectForKey: @"Service"] objectForKey: @"Timesteps"] objectForKey: @"@displayName"]);
                
                NSString *passedLayerName = [[layers objectForKey: @"Service"] objectForKey: @"LayerName"];
                NSArray *timeStep = [[[layers objectForKey: @"Service"] objectForKey: @"Times"] objectForKey: @"Time"];
                
                [self selectLayer: passedLayerName withTimeSteps: timeStep];
            }
        }
    } failure:nil];
    
    [operation start];
    
    // Spin up a Progress spinner to alert user to download
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"Loading";
    HUD.square = YES;
    [self.view addSubview:HUD];
    [HUD show: YES];
    
}

-(void) selectLayer: (NSString*)layerID withTimeSteps: (NSArray *)timestep_set{
    for(NSString *timestep in timestep_set){
    
        NSURL *hourlyCall = [NSURL URLWithString: [NSString stringWithFormat: @"http://datapoint.metoffice.gov.uk/public/data/layer/wxobs/%@/png?TIME=%@Z&key=%@", layerID, timestep, MET_OFFICE_API_KEY]];
        
        NSLog(@"Calling URL: %@", [hourlyCall absoluteString]);
        NSURLRequest *request = [NSURLRequest requestWithURL: hourlyCall];
        AFImageRequestOperation *operation = [[AFImageRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            // NSLog(@"Data:  %@", operation.responseData); // Data
            // NSLog(@"Class: %@", [responseObject class]); // UIImage
            
            //Check for a UIImage before adding it to the array
            if([responseObject class] == [UIImage class]){
                
                // Parse the Query String from the original URL when we get data back from the api
                NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                for (NSString *param in [[operation.response.URL query] componentsSeparatedByString:@"&"]) {
                    NSArray *elts = [param componentsSeparatedByString:@"="];
                    if([elts count] < 2) continue;
                    [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
                }
                
                // Setup our image object and write it to our array
                SGMetOfficeForecastImage *serverImage = [[SGMetOfficeForecastImage alloc] init];
                serverImage.image = [UIImage imageWithData: operation.responseData];
                serverImage.timestamp = timestep;
                serverImage.timeStep = nil;
                serverImage.layerName = layerID;
                
                [overlayArray addObject: serverImage];
                
                // Increment our expected count so that we know when to start playing the animation
                imagesExpected = @([imagesExpected intValue] + 1);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //We didn't get the image but that won't stop us!
            imagesExpected = @([imagesExpected intValue] + 1);
            NSLog(@"Couldn't download image.");
        }];
        
        [operation start];
    }
    
    // Start the Time to check that we have all the images we requested downloaded and stored in the layer array
    checkDownloads = [NSTimer scheduledTimerWithTimeInterval: 1 target:self selector:@selector(checkAllImagesHaveDownloaded:) userInfo: [NSNumber numberWithInt: [timestep_set count]] repeats: YES];
}

-(void) checkAllImagesHaveDownloaded: (NSTimer*)sender{
    NSNumber *imageFiles = sender.userInfo;
    NSLog(@"Checking for %d images downloaded ...", [imageFiles intValue]);
    
    // Update the HUD progress
    HUD.detailsLabelText = [NSString stringWithFormat: @"Fetched %d of %d", [imagesExpected intValue], [imageFiles intValue]];
    HUD.square = YES;

    if([imagesExpected isEqualToNumber: imageFiles]){
        [checkDownloads invalidate];
        
        NSArray *sortedArray;
        sortedArray = [overlayArray sortedArrayUsingComparator:^NSComparisonResult(SGMetOfficeForecastImage *a, SGMetOfficeForecastImage *b) {
            return [a.timestamp compare: b.timestamp];
        }];
        
        overlayArray = [NSMutableArray arrayWithArray: sortedArray];
        
        NSLog(@"Starting Loop");
        
        CGRect deviceBounds = [[UIScreen mainScreen] bounds];
        UIView *redBack = [[UIView alloc] initWithFrame: CGRectMake(deviceBounds.size.width - 150, deviceBounds.size.height - 84, 150, 25)];
        redBack.backgroundColor = [UIColor redColor];
        redBack.alpha = 0.7f;
        
        UILabel *timeStampLabel = [[UILabel alloc] initWithFrame: CGRectMake(0,0, 150, 25)];
        timeStampLabel.tag = 100;
        timeStampLabel.text = @"";
        timeStampLabel.textColor = [UIColor whiteColor];
        timeStampLabel.font = [UIFont boldSystemFontOfSize:16.0];
        timeStampLabel.textAlignment = NSTextAlignmentCenter;
        
        [redBack addSubview: timeStampLabel];
        [self.view addSubview: redBack];
        
        // Remove the loading screen
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        //Start Layer Animation
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateLayer:) userInfo:nil repeats: YES];
    }
}

-(void) updateLayer: (id)selector{
    //Setup the bounds of our layer to place on the map
    CLLocationCoordinate2D UKSouthWest = CLLocationCoordinate2DMake(48.00, -12.00);
    CLLocationCoordinate2D UKNorthEast = CLLocationCoordinate2DMake(61.00, 5.00);
    
    //Get next layer and place it on the map
    SGMetOfficeForecastImage *layerObject = [overlayArray objectAtIndex: [currentLayerIndex intValue]];
    
    //Clear the Layers in the MapView
    for(GMSGroundOverlay *gO in overlayObjectArray){
        gO.map = nil;
        [overlayObjectArray removeObject: gO];
    }
    
    // Get the UILabel to display the time and change the timestamp
    NSDate *timestampDate = [self formatDateWithString:  [layerObject.timestamp stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE HH:mm"];
    
    UILabel *textLabel = (UILabel*)[self.view viewWithTag: 100];
    textLabel.text = [formatter stringFromDate: timestampDate];
    
    
    GMSCoordinateBounds *uk_overlayBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:UKSouthWest
                                                                                 coordinate:UKNorthEast];
    
    GMSGroundOverlay *layerOverlay = [GMSGroundOverlay groundOverlayWithBounds: uk_overlayBounds icon: layerObject.image];
    layerOverlay.bearing = 0;
    layerOverlay.zIndex = 5  * ([currentLayerIndex intValue] + 1);
    layerOverlay.map = mapView;
    
    [overlayObjectArray addObject: layerOverlay];
    
    // Check if we're at the end of the layerArray and then loop
    if([currentLayerIndex intValue] < [overlayArray count] - 1){
        currentLayerIndex = @([currentLayerIndex intValue] + 1);
    }else{
        currentLayerIndex = @0;
    }
}

-(NSDate *)formatDateWithString:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate* date = [dateFormatter dateFromString:dateString];
    return date;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
