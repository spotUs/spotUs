//
//  PhotoMapViewController.h
//  spotUs
//
//  Created by Lizbeth Alejandra Gonzalez on 7/17/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SafariServices/SafariServices.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <MapKit/MapKit.h>
#import "City.h"
@protocol HandleMapSearch
-(void)ZoomInOnLocation:(CLLocation*)location;
@end

@protocol NowPlayingIntermediateDelegate
-(void)didStartPlayingonCityIntermediate:(City*)city;
@end

@interface PhotoMapViewController : UIViewController

@property (strong, nonatomic) NSArray *cities;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) SPTAuth *auth;
@property (nonatomic, weak) id<NowPlayingIntermediateDelegate> nowPlayingIntermediateDelegate;

@end
