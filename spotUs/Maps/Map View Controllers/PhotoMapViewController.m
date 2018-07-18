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

@interface PhotoMapViewController ()

@end

@implementation PhotoMapViewController

- (void)viewDidLoad {
    MKCoordinateRegion sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(90,90), MKCoordinateSpanMake(0.1, 0.1));
    [self.mapView setRegion:sfRegion animated:false];
    
    PFQuery *query = [PFQuery queryWithClassName:@"City"];
    query.limit = 20;
    [query includeKey:@"lng"];
    [query includeKey:@"lat"];
    [query includeKey:@"name"];
    [query includeKey:@"tracks"];
    [query orderByAscending:@"name"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *cities, NSError *error) {
        
        if (cities) {
            for(PFObject *c in cities) {
                [self.cities addObject:c];
                double longi = [c[@"lng"] doubleValue];
                double lat = [c[@"lat"] doubleValue];
                CLLocationCoordinate2D location;
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                location.latitude = lat;
                location.longitude = longi;
                annotation.coordinate = location;
                [self.mapView addAnnotation: annotation];
            }
        }
        else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation





@end
