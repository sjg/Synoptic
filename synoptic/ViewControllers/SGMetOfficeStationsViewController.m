//
//  SGMetOfficeStationsViewController.m
//  Synoptic
//
//  Created by sjg on 22/07/2013.
//  Copyright (c) 2013 sjg. All rights reserved.
//

#import "SGMetOfficeStationsViewController.h"
#import "AFJSONRequestOperation.h"

@interface SGMetOfficeStationsViewController ()

@end

@implementation SGMetOfficeStationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Station Map", @"StationMap");
        self.tabBarItem.image = [UIImage imageNamed:@"map-marker"];
    }
    return self;
}

- (void)loadView {
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude: 55.559323
                                                            longitude: -4.174805
                                                                 zoom: 5];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    self.view = mapView_;
    mapView_.mapType = kGMSTypeNone;
    
    //Call UIEdgeInsets so that we're not covering the Copyright information (which would be a TOS violation)
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 5, 58.0, 0);
    mapView_.padding = insets;
    
    //Load Tile Layer
    GMSTileURLConstructor urls = ^(NSUInteger x, NSUInteger y, NSUInteger zoom) {
        NSString *url = [NSString stringWithFormat:@"http://media.stevenjamesgray.com/weather/%d/%d/%d.png", zoom, x, y];
        return [NSURL URLWithString:url];
    };

    GMSURLTileLayer *layer = [GMSURLTileLayer tileLayerWithURLConstructor:urls];
    
    // Display on the map at a specific zIndex
    layer.zIndex = 100;
    layer.map = mapView_;

}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: api_obs_cap, MET_OFFICE_API_KEY]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSLog(@"Calling URL: %@", [url absoluteString]);

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSMutableArray *ts = (NSMutableArray *)[[[JSON valueForKeyPath:@"Resource"] valueForKeyPath: @"TimeSteps"] valueForKeyPath: @"TS"];
        
        //NSLog(@"Last Data Point: %@", [ts objectAtIndex: [ts count] - 1]);
        
        //Make new call
        NSURL *hourlyCall = [NSURL URLWithString: [NSString stringWithFormat: api_obs_hourly, [ts objectAtIndex: [ts count] - 1], MET_OFFICE_API_KEY]];
        
        NSLog(@"Calling URL: %@", [hourlyCall absoluteString]);
        NSURLRequest *request2 = [NSURLRequest requestWithURL:hourlyCall];
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request2 success:^(NSURLRequest *request2, NSHTTPURLResponse *response, id JSON) {
            
            NSMutableArray *stations = (NSMutableArray*)[[[JSON valueForKeyPath:@"SiteRep"] valueForKeyPath:@"DV"] valueForKeyPath:@"Location"];
            
            //NSLog(@"Data: %@", stations);
            for(NSMutableDictionary *obs in stations){
                NSLog(@"Name: %@, Lat:%.2f Lng: %.4f", [obs valueForKeyPath: @"name"],
                      [[obs objectForKey:@"lat"] floatValue],
                      [[obs objectForKey:@"lon"] floatValue]);
                
                double lat;
                double lng;
                
                lat = [[obs objectForKey:@"lat"] floatValue];
                lng = [[obs objectForKey:@"lon"] floatValue];
                
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = CLLocationCoordinate2DMake(lat, lng);
                marker.title = [obs valueForKeyPath: @"name"];
                marker.snippet = [NSString stringWithFormat:@"Lat: %@, Lng: %@", [obs valueForKeyPath: @"lat"], [obs valueForKeyPath: @"lon"]];
                //marker.icon = [UIImage imageNamed: @"red_dot"];
                marker.map = mapView_;
            }
            
            
        } failure:nil];
        
        [operation start];
        
        
    } failure:nil];
    
    [operation start];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
