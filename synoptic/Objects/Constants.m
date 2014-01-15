//
//  Constants.m
//  Synoptic
//
//  Created by sjg on 15/01/2014.
//  Copyright (c) 2014 sjg. All rights reserved.
//

#import "Constants.h"

NSString* const GOOGLE_MAPS_SDK_KEY = @"";
NSString* const MET_OFFICE_API_KEY = @"";

NSString* const api_obs_cap = @"http://datapoint.metoffice.gov.uk/public/data/val/wxobs/all/json/capabilities?res=hourly&key=%@";
NSString* const api_obs_hourly = @"http://datapoint.metoffice.gov.uk/public/data/val/wxobs/all/json/all?res=hourly&time=%@&key=%@";
NSString* const api_forecast_layers_cap = @"http://datapoint.metoffice.gov.uk/public/data/layer/wxfcs/all/json/capabilities?key=%@";
NSString* const api_obs_layers_cap = @"http://datapoint.metoffice.gov.uk/public/data/layer/wxobs/all/json/capabilities?key=%@";