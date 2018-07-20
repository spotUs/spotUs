//
//  CitiesViewController.h
//  spotUs
//
//  Created by Megan Ung on 7/16/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SafariServices/SafariServices.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import <Parse/Parse.h>
#import "City.h"

@protocol NowPlayingIntermediateDelegate

-(void)didStartPlayingonCityIntermediate:(City*)city;

@end
@protocol PlayerRepeatIntermediateDelegate

-(void)didChangeIntermediateRepeatStatusTo:(BOOL)isRepeating;

@end

@interface CitiesViewController : UIViewController

@property (nonatomic, weak) SPTAudioStreamingController *player;
@property (nonatomic, strong) SPTAuth *auth;
@property (nonatomic, weak) id<NowPlayingIntermediateDelegate> nowPlayingIntermediateDelegate;
@property (nonatomic, weak) id<PlayerRepeatIntermediateDelegate> intermediateRepeatDelegate;


@end
