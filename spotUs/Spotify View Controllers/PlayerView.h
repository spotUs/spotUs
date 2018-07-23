//
//  PlayerView.h
//  spotUs
//
//  Created by Martin Winton on 7/16/18.
//  Copyright © 2018 Lizbeth Alejandra Gonzalez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SafariServices/SafariServices.h>
#import <SpotifyMetadata/SpotifyMetadata.h>
#import "City.h"

#import <Parse/Parse.h>

@protocol NowPlayingDelegate

-(void)didStartPlayingonCity:(City*)city;

@end

@interface PlayerView : UIViewController
@property (nonatomic, weak) SPTAudioStreamingController *player;
@property (nonatomic, strong) SPTAuth *auth;
@property (nonatomic, strong) City *city;
@property BOOL nowPlaying;
@property BOOL isRepeating;
@property BOOL isPlaying;
@property BOOL didSelect;



@property (nonatomic, weak) id<NowPlayingDelegate> nowPlayingDelegate;


@property NSInteger songIndex;





@end
