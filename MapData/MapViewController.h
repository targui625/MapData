//
//  MapViewController.h
//  MapData
//
//  Created by Norimichi Takagi on 2016/01/14.
//  Copyright © 2016年 NorimichiTakagi. All rights reserved.
//

#import "ViewController.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : ViewController

@property (assign, nonatomic) BOOL isLocation;

// 現在位置記録用
@property (assign, nonatomic) CLLocationDegrees longitude;
@property (assign, nonatomic) CLLocationDegrees latitude;


@end
