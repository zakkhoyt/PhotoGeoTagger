//
//  VWWMapViewController.m
//  ScaryBugsMac
//
//  Created by Zakk Hoyt on 4/13/13.
//  Copyright (c) 2013 Zakk Hoyt. All rights reserved.
//
//  http://rickfillion.tumblr.com/post/1134987954/pretroducing-mapkit-for-mac

#import "VWWMapViewController.h"
#import <MapKit/MapKit.h>


@interface VWWMapViewController () <NSTextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate>


@property (strong) IBOutlet MKMapView *mapView;
@property (strong) IBOutlet NSTextField *mapTextField;
@property (strong) IBOutlet NSTextField *longitudeTextField;
@property (strong) IBOutlet NSTextField *lattitudeTextField;

@end

@implementation VWWMapViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}

-(void)loadView{
    [super loadView];
    self.mapView.delegate = self;
}

- (IBAction)mapTextField:(id)sender {
    NSTextField *tf = (NSTextField*)sender;
    [self.mapView showAddress:tf.stringValue];
}


#pragma mark Public methods

//-(void)findCurrentLocation{
//    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
//    if ([CLLocationManager locationServicesEnabled])
//    {
//        locationManager.delegate = self;
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        locationManager.distanceFilter = kCLDistanceFilterNone;
//        [locationManager startUpdatingLocation];
//    }
//
//
//    CLLocation *location = [locationManager location];
//    CLLocationCoordinate2D coordinate = [location coordinate];
//
//    NSString *str=[[NSString alloc] initWithFormat:@" latitude:%f longitude:%f",coordinate.latitude,coordinate.longitude];
//    NSLog(@"%@",str);
//
//}



- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    NSLog(@"%s", __FUNCTION__);
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    CLLocationCoordinate2D centerCoordinate = [self.mapView centerCoordinate];
    NSLog(@"%s %f %f", __FUNCTION__, centerCoordinate.latitude, centerCoordinate.longitude);
    self.lattitudeTextField.stringValue = [NSString stringWithFormat:@"%f", centerCoordinate.latitude];
    self.longitudeTextField.stringValue = [NSString stringWithFormat:@"%f", centerCoordinate.longitude];
}


#pragma mark IBActions

- (IBAction)radioButtonsAction:(id)sender {
    NSButtonCell *selCell = [sender selectedCell];
    
    switch([selCell tag]){
        case 100:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 200:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 300:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
    

}

- (IBAction)assignLocationButtonAction:(id)sender {
    CLLocationCoordinate2D centerCoordinate = [self.mapView centerCoordinate];
    
    [self.delegate mapViewController:self assignLocation:centerCoordinate];
}





@end












