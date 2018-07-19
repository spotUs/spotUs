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
@interface PhotoMapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) City *city;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *latittudeLabel;
@property BOOL waitingForLocation;

@end

@implementation PhotoMapViewController
CLLocationManager *locationManager;

- (IBAction)didClickCheckIn:(id)sender {
    self.waitingForLocation = YES;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];


    [locationManager startUpdatingLocation];
    
    
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
  
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    
    if(self.waitingForLocation){
        
        CLLocation *newLocation = [locations lastObject];
        NSLog(@"didUpdateToLocation: %@", newLocation);
        CLLocation *currentLocation = newLocation;
        
        if (currentLocation != nil) {
          
            BOOL foundCity = NO;
            for(City *city in self.cities){
                
                CLLocation *cityLocation = [[CLLocation alloc] initWithLatitude:city.lat longitude:city.lng];
                
                double distance =  [currentLocation distanceFromLocation:cityLocation];
                
                if(distance < 1000000){
                    
                    self.city = city;
                    foundCity = YES;
                    [self performSegueWithIdentifier:@"gotoplayer" sender:nil];
                    break;

                    
                }
                
                
                
                
            }
            
            
            if(!foundCity){
                
                [ErrorAlert showAlert:@"It seems you are not near a city SpotUS is available in.." inVC:self];
            }

            
     
            self.waitingForLocation = NO;
        }
        
    }
}

- (void)viewDidLoad {
    locationManager = [[CLLocationManager alloc] init];

    locationManager.delegate = self;
    
    self.waitingForLocation = NO;
    
    

    self.mapView.delegate = self;

    
    PFQuery *query = [PFQuery queryWithClassName:@"City"];
    query.limit = 20;
    [query includeKey:@"lng"];
    [query includeKey:@"lat"];
    [query includeKey:@"name"];
    [query includeKey:@"tracks"];
    [query orderByAscending:@"name"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *cities, NSError *error) {
        
        if (cities) {
            self.cities = cities;
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
    //TODO pls make this better
    PFQuery *query = [PFQuery queryWithClassName:@"City"];
    [query whereKey:@"name" equalTo:view.annotation.title];
    query.limit = 1;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *cities, NSError *error) {
        if (error){
            NSLog(@"errorrrr: %@",error.localizedDescription);
        } else {
            self.city = cities[0];
            [self performSegueWithIdentifier:@"gotoplayer" sender:nil];
        }
    }];
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


@end
