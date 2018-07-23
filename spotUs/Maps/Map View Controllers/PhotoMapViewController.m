//
//  PhotoMapViewController.m
//  PhotoMap
//
//  Created by emersonmalca on 7/8/18.
//  Copyright © 2018 Codepath. All rights reserved.
//

#import "PhotoMapViewController.h"
#import <MapKit/MapKit.h>
#import "Parse.h"
#import "PlayerView.h"
#import "City.h"
#import "ErrorAlert.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationSearchTable.h"
#import "QueryManager.h"
@interface PhotoMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, HandleMapSearch, NowPlayingDelegate>
@property (strong, nonatomic) City *city;
@property (strong, nonatomic) UISearchController *resultSearchController;
@property BOOL waitingForLocation;
@property (weak, nonatomic) IBOutlet UIButton *checkInButton;

@end

@implementation PhotoMapViewController
CLLocationManager *locationManager;

- (IBAction)didClickCheckIn:(id)sender {
    [self performSegueWithIdentifier:@"gotoplayer" sender:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
  
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    if (currentLocation != nil) {
        BOOL foundCity = NO;
        for(City *city in self.cities){
            CLLocation *cityLocation = [[CLLocation alloc] initWithLatitude:city.lat longitude:city.lng];
            double distance =  [currentLocation distanceFromLocation:cityLocation];
            if(distance < 300000){
                self.city = city;
                foundCity = YES;
                self.checkInButton.enabled = YES;
                [self.checkInButton setTintColor:[UIColor greenColor]];
                [self.checkInButton setTitle:[NSString stringWithFormat:@"Discover %@",self.city.name] forState:UIControlStateNormal];
                break;
            }
        }
        if(!foundCity){
            
            [self.checkInButton setTitle:@"No SpotUs City Nearby" forState:UIControlStateNormal];
            self.checkInButton.enabled = NO;
            [self.checkInButton setTintColor:[UIColor grayColor]];
        }
    }
}


- (void)ZoomInOnLocation:(CLLocation *)location{
    MKCoordinateSpan span;
    span.latitudeDelta = .2;
    span.longitudeDelta = .2;
    
    MKCoordinateRegion region;
    
    region.center = location.coordinate;
    region.span = span;
    
    self.mapView.region = region;
}

- (void)viewDidLoad {
    [self.checkInButton.layer setBorderWidth:3.0];
    [self.checkInButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.checkInButton setTitle:@"No SpotUs City Nearby" forState:UIControlStateNormal];
    self.checkInButton.enabled = NO;
    [self.checkInButton setTintColor:[UIColor grayColor]];

    LocationSearchTable *locationSearchTable = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationSearchTable"];
    
    
    self.resultSearchController = [[UISearchController alloc ] initWithSearchResultsController:locationSearchTable];
    self.resultSearchController.searchResultsUpdater = locationSearchTable;
    locationSearchTable.handleMapsearchDelegate = self;
    
    UISearchBar *searchBar = self.resultSearchController.searchBar;
    [searchBar sizeToFit];
    self.navigationItem.titleView = self.resultSearchController.searchBar;
    searchBar.placeholder = @"Search for cities";
    
    self.resultSearchController.hidesNavigationBarDuringPresentation = NO;
    self.resultSearchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;

    self.mapView.delegate = self;

    
    [QueryManager fetchCities:^(NSArray *cities, NSError *error) {
        if (cities) {
            self.cities = cities;
            locationManager = [[CLLocationManager alloc] init];
            
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            [locationManager requestWhenInUseAuthorization];
            [locationManager startUpdatingLocation];
            for(PFObject *c in cities) {
                
                double longi = [c[@"lng"] doubleValue];
                double lat = [c[@"lat"] doubleValue];
                CLLocationCoordinate2D location;
                location.latitude = lat;
                location.longitude = longi;
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
                annotation.coordinate = location;
                annotation.title = c[@"name"];
                [self.mapView addAnnotation:annotation];
            }
        }
        else {
            NSLog(@"%@", error.localizedDescription);
        }
        
    }];
}

//mapview delegate method
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if(annotation == self.mapView.userLocation){
        // prevent showing pin for current location
        return nil;
    }
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
        annotationView.canShowCallout = true;
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    UIImage *btnImage = [UIImage imageNamed:@"next-btn"];
    [btn setImage:btnImage forState:UIControlStateNormal];
    annotationView.rightCalloutAccessoryView = btn;
    
    return annotationView;
}

- (void) mapView: (MKMapView *)mapView annotationView:(nonnull MKAnnotationView *)view calloutAccessoryControlTapped:(nonnull UIControl *)control {
    NSLog(@"%@",view.annotation.title);
    self.city = [QueryManager getCityFromName:view.annotation.title];
    [self performSegueWithIdentifier:@"gotoplayer" sender:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue destinationViewController] isKindOfClass:[PlayerView class]]){
        PlayerView *playerController = (PlayerView*)[segue destinationViewController];
      
        playerController.city = self.city;
        playerController.auth = self.auth;
        playerController.player = self.player;
    }

}

- (void)didStartPlayingonCity:(City *)city{
    [self.nowPlayingIntermediateDelegate didStartPlayingonCityIntermediate:city];
}


@end
