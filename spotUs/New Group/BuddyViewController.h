//
//  BuddyViewController.h
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/31/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SafariServices/SafariServices.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <MapKit/MapKit.h>
#import "City.h"

@interface BuddyViewController : UIViewController
@property (strong, nonatomic) NSArray *cities;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) SPTAuth *auth;


@end
