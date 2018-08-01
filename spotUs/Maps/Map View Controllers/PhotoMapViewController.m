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
#import "PlaylistViewController.h"
@interface PhotoMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, HandleMapSearch>
@property (strong, nonatomic) City *searchCity;
@property (strong, nonatomic) City *locationCity;

@property (strong, nonatomic) UISearchController *resultSearchController;
@property BOOL waitingForLocation;
@property (weak, nonatomic) IBOutlet UIButton *checkInButton;
@end

@implementation PhotoMapViewController
CLLocationManager *locationManager;

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
                self.locationCity = city;
                foundCity = YES;
                self.checkInButton.enabled = YES;
                break;
            }
        }
        if(!foundCity){
            
        
            self.checkInButton.enabled = NO;
            [self.checkInButton setTintColor:[UIColor grayColor]];
        }
    }
}

- (IBAction)showOtherMapTapped:(id)sender {
    if ([self.mapView isHidden]){
    [UIView transitionWithView:self.friendsMapView duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{self.mapView.hidden = NO; self.friendsMapView.hidden = YES;}completion:NULL];
    }
    else
        [UIView transitionWithView:self.mapView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{self.friendsMapView.hidden = NO; self.mapView.hidden = YES;  } completion:NULL];
        }

- (void)ZoomInOnLocation:(CLLocation *)location{
    MKCoordinateSpan span;
    span.latitudeDelta = .2;
    span.longitudeDelta = .2;
    
    MKCoordinateRegion region;
    
    region.center = location.coordinate;
    region.span = span;
    
    self.mapView.region = region;
    self.friendsMapView.region = region;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    self.friendsMapView.delegate = self;
    
    self.cities = QueryManager.citiesarray;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    for(PFObject *c in self.cities) {
        
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
    [self getFriendsLastPlayedLocation];

}

- (void) getFriendsLastPlayedLocation {
    for (NSString *friendname in [PFUser currentUser][@"friends"]){
        [QueryManager getUserfromUsername:friendname withCompletion:^(PFUser *user, NSError *error) {
            if (error){
                NSLog(@"error getting friend's user obj': %@",error.localizedDescription);
            } else {
                NSLog(@"last played city %@",user[@"lastPlayedCity"]);
                if (user[@"lastPlayedCity"] != nil){
                    City *friendloc = (City *)user[@"lastPlayedCity"];
                    double lng = [friendloc[@"lng"] doubleValue];
                    double lat = [friendloc[@"lat"] doubleValue];
                    NSLog(@"%f",lng );
                    CLLocationCoordinate2D location;
                    location.latitude = lat;
                    location.longitude = lng;
                    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                    annotation.coordinate = location;
                    annotation.title = user.username;
                    annotation.subtitle = friendloc.name;
                    [self.friendsMapView addAnnotation:annotation];
                }
            }
        }];
    }
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([mV isEqual:self.friendsMapView]){
    MKAnnotationView *pinView = nil;
    if(annotation != _mapView.userLocation)
    {
        static NSString *defaultPinID = @"Pin";
        pinView = (MKAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        
        //pinView.pinColor = MKPinAnnotationColorGreen;
        pinView.canShowCallout = YES;
        //pinView.animatesDrop = YES;
     
        pinView.image = [UIImage imageNamed:@"friendmusic-black"];
    }
    else {
        [_mapView.userLocation setTitle:@"I am here"];
    }
    return pinView;
    }
    else {
        if(annotation == self.mapView.userLocation){
            // prevent showing pin for current location
            return nil;
        }

        MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mV dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
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
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (mapView == self.friendsMapView){
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(calloutTapped:)];
        [view addGestureRecognizer:tapGesture];
    }
}

-(void)calloutTapped:(UITapGestureRecognizer *) sender
{
    NSLog(@"Callout was tapped");
    MKAnnotationView * view = (MKAnnotationView *) sender.view;
    NSLog(@"%@",view.annotation.subtitle);

    self.searchCity = [QueryManager getCityFromName:view.annotation.subtitle];
    [self performSegueWithIdentifier:@"playlist" sender:self];

    
}


- (void) mapView: (MKMapView *)mapView annotationView:(nonnull MKAnnotationView *)view calloutAccessoryControlTapped:(nonnull UIControl *)control {
    NSLog(@"%@",view.annotation.title);

    self.searchCity = [QueryManager getCityFromName:view.annotation.title];
    [self performSegueWithIdentifier:@"playlist" sender:self];
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
        

        playerController.auth = self.auth;
        playerController.player = self.player;
    }
    
    else if ([[segue destinationViewController] isKindOfClass:[PlaylistViewController class]]){
        
        PlaylistViewController *playlistController = (PlaylistViewController*)[segue destinationViewController];
        if([sender isKindOfClass:UIButton.class]){
         
            playlistController.city = self.locationCity;
            
        }
        
        else{
            playlistController.city = self.searchCity;
            
        }
        
        playlistController.auth = self.auth;
        playlistController.player = self.player;
    }


}

- (void)didStartPlayingonCity:(City *)city{
    [self.nowPlayingIntermediateDelegate didStartPlayingonCityIntermediate:city];
}


@end
