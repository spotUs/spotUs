//
//  BuddyViewController.m
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/31/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import "BuddyViewController.h"
#import <MapKit/MapKit.h>
#import "Parse.h"
#import "PlayerView.h"
#import "City.h"
#import "ErrorAlert.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationSearchTable.h"
#import "QueryManager.h"
#import "PlaylistViewController.h"


@interface BuddyViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) City *locationCity;
@property(strong, nonatomic) PFUser *friend;

@end

#define METERS_PER_MILE 1609.344

@implementation BuddyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.mapView.delegate = self;
  
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 39.281516;
    zoomLocation.longitude= -76.580806;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    [_mapView setRegion:viewRegion animated:YES];
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
