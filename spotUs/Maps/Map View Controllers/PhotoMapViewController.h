//
//  PhotoMapViewController.h
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/17/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PhotoMapViewController : UIViewController

@property (strong, nonatomic) NSArray *cities;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
