//
//  MapViewController.m
//  MapData
//
//  Created by Norimichi Takagi on 2016/01/14.
//  Copyright © 2016年 NorimichiTakagi. All rights reserved.
//

#import "MapViewController.h"
#import "CustomAnnotation.h"
#import "DataViewController.h"

@interface MapViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>

// ロケーションマネージャー
@property (strong, nonatomic) CLLocationManager* locationManager;

@property (strong, nonatomic) NSMutableArray *annotationArray;

// マップキット
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

// ボタン
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *dataButton;

- (IBAction)addButtonAction:(id)sender;
- (IBAction)dataButtonAction:(id)sender;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // ロケーションマネージャーを作成
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // 取得頻度（指定したメートル移動したら再取得する）
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    // 5m移動するごとに取得
    self.locationManager.distanceFilter = 5;
    
    // アプリの使用中のみ位置情報を取得
    [self.locationManager requestWhenInUseAuthorization];
    
    self.isLocation = NO;
    
    // 位置情報取得開始
    [self.locationManager startUpdatingLocation];
    
    // 地図の機能を有効化
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    // 航空写真に変更
    _mapView.mapType = MKMapTypeSatelliteFlyover;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 初期情報の取得
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    NSMutableData *data = [nd objectForKey:@"annotationData"];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    self.annotationArray = [[decoder decodeObjectForKey:@"annotation"] mutableCopy];
    [decoder finishDecoding];
    
    if (self.isLocation) {
        // 地図の中心座標に現在地を設定
        CLLocationCoordinate2D co;
        co.latitude = self.latitude; // 経度
        co.longitude = self.longitude; // 緯度
        self.mapView.centerCoordinate = co;
        
        // 表示倍率の設定
        MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
        MKCoordinateRegion region = MKCoordinateRegionMake(co, span);
        [self.mapView setRegion:region animated:YES];
    }
    
    // 画面が表示される時、ピンと経路を消しておく
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    // 保持されているピンがなかった場合などには配列を初期化しておく
    if (self.annotationArray == nil) {
        self.annotationArray = [NSMutableArray arrayWithCapacity:0];
    }
    
    // 配列に保持されたピンを取得しマップ上に表示
    for (CustomAnnotation *annotation in self.annotationArray) {
        
        [self.mapView addAnnotation:annotation];
    }
}


// 位置情報が取得成功した場合にコールされる
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // 位置情報更新
    self.longitude = newLocation.coordinate.longitude;
    self.latitude = newLocation.coordinate.latitude;
    
    self.isLocation = YES;
}

// 位置情報が取得失敗した場合にコールされる。
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
}

-(MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id)annotation {
    
    // 現在地表示なら nil を返す
    if (annotation == mapView.userLocation) {
        return nil;
    }
    else {
    MKAnnotationView *annotationView;
    NSString* identifier = @"Pin";
    annotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if(nil == annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.annotation = annotation;
    annotationView.image = [UIImage imageNamed:@"here.png"];
    return annotationView;
}
}

- (IBAction)addButtonAction:(id)sender {
    
    // 地図の中心座標に現在地を設定
    CLLocationCoordinate2D co;
    co.latitude = self.latitude; // 経度
    co.longitude = self.longitude; // 緯度
    self.mapView.centerCoordinate = co;
    
    // 表示倍率の設定
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(co, span);
    [self.mapView setRegion:region animated:YES];
    
    // リバースジオコーディング
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error) {
            NSLog(@"リバースジオコーディング失敗");
        } else {
            if(0 < [placemarks count]) {
                for(CLPlacemark *placemark in placemarks) {
                    
                    NSString *name = [NSString stringWithFormat:@"%@", placemark.name];
                    NSString *address = [NSString stringWithFormat:@"%@%@%@%@%@", placemark.country, placemark.administrativeArea, placemark.locality, placemark.thoroughfare, placemark.subThoroughfare];
                    
                    CustomAnnotation *annotation;
                    CLLocationCoordinate2D annoLocation;
                    annoLocation.latitude  = self.latitude;
                    annoLocation.longitude = self.longitude;
                    annotation =[[CustomAnnotation alloc] initWithCoordinate:annoLocation];
                    annotation.title = name;
                    annotation.subtitle = address;
                    [self.mapView addAnnotation:annotation];
                    
                    [self.annotationArray addObject:annotation];
                    
                    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
                    NSMutableData *data = [NSMutableData data];
                    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
                    [encoder encodeObject:[self.annotationArray copy] forKey:@"annotation"];
                    [encoder finishEncoding];
                    [nd setObject:data forKey:@"annotationData"];
                    [nd synchronize];
                }
            }
        }
    }];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    CLLocationCoordinate2D fromCoordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    CLLocationCoordinate2D toCoordinate = view.annotation.coordinate;
    
    // CLLocationCoordinate2D から MKPlacemark を生成
    MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:fromCoordinate addressDictionary:nil];
    MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:toCoordinate addressDictionary:nil];
    
    // MKPlacemark から MKMapItem を生成
    MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
    MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
    
    // MKMapItem をセットして MKDirectionsRequest を生成
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = fromItem;
    request.destination = toItem;
    request.requestsAlternateRoutes = YES;
    
    // MKDirectionsRequest から MKDirections を生成
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    // 経路検索を実行
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
     {
         if (error) return;
         
         if ([response.routes count] > 0)
         {
             MKRoute *route = [response.routes objectAtIndex:0];
             
             // 地図上にルートを描画
             [self.mapView addOverlay:route.polyline];
         }
     }];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
}

// 地図上に描画するルートの色などを指定（これを実装しないと何も表示されない）
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.lineWidth = 5.0;
        routeRenderer.strokeColor = [UIColor redColor];
        return routeRenderer;
    }
    else {
        return nil;
    }
}

- (IBAction)dataButtonAction:(id)sender {
    
    [self performSegueWithIdentifier:@"DataView" sender:self];
}

- (IBAction)exitFromDataView:(UIStoryboardSegue *)segue {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DataView"]) {
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
