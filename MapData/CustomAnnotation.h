//
//  CustomAnnotation.h
//  MapData
//
//  Created by Norimichi Takagi on 2016/01/14.
//  Copyright © 2016年 NorimichiTakagi. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomAnnotation : MKAnnotationView <MKAnnotation, NSCoding>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;

- (id) initWithCoordinate:(CLLocationCoordinate2D) coordinate;

- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;


@end
