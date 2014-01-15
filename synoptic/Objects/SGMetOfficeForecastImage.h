//
//  SGMetOfficeForecastImage.h
//  Synoptic
//
//  Created by sjg on 13/01/2014.
//  Copyright (c) 2014 sjg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGMetOfficeForecastImage : NSObject{

}

@property (strong, nonatomic) NSString *timestamp;;
@property (strong, nonatomic) NSNumber *timeStep;
@property (strong, nonatomic) NSString *layerName;
@property (strong, nonatomic) UIImage *image;


@end
